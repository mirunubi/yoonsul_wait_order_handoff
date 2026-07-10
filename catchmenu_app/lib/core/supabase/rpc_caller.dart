import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../errors/app_error.dart';
import 'supabase_client.dart';

/// RPC 호출 결과.
///
/// 성공이면 [data], 실패면 [error] 중 하나만 채워진다.
/// 어느 쪽이든 [correlationId] 는 항상 존재한다 (로그 추적용).
class RpcResult<T> {
  final T? data;
  final AppError? error;
  final String correlationId;

  const RpcResult._({
    this.data,
    this.error,
    required this.correlationId,
  });

  factory RpcResult.success(T? data, String correlationId) =>
      RpcResult._(data: data, correlationId: correlationId);

  factory RpcResult.failure(AppError error, String correlationId) =>
      RpcResult._(error: error, correlationId: correlationId);

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  /// 성공을 가정하고 데이터를 꺼낸다. 실패면 error 를 throw.
  T get requireData {
    if (error != null) throw error!;
    return data as T;
  }
}

/// 모든 Supabase RPC 의 공통 진입점.
///
/// 원칙 (900102 ChangeContract / INV-001~006):
///  - 앱의 어떤 코드도 `supabase.rpc()` 를 직접 호출하지 않는다. 이 클래스만 사용.
///  - correlation_id 를 항상 자동 생성한다.
///  - dev 환경에서는 호출 결과를 catchmenu_dev.write_audit_log() 로 남긴다.
///  - INV-004: 서버 전용 RPC(release_kds_after_payment 등)는 여기서 차단한다.
///  - 실패는 항상 표준 [AppError] 로 정규화한다.
class RpcCaller {
  final SupabaseClient _client;
  final Uuid _uuid;

  /// 이 caller 인스턴스의 dev audit 로그 그룹 키.
  /// 보통 앱 세션 1개당 caller 1개 → 세션 단위로 로그가 묶인다.
  final String logSessionId;

  RpcCaller(
    this._client, {
    String? logSessionId,
    Uuid? uuid,
  })  : _uuid = uuid ?? const Uuid(),
        logSessionId = logSessionId ?? const Uuid().v4();

  /// RPC 호출.
  ///
  /// [fnName]  : Postgres 함수명 (스키마 접두사 없이).
  /// [schema]  : 함수가 속한 스키마. 기본 public. 예) AppConstants.schemaPos.
  /// [params]  : 함수 인자 (p_ 접두사 포함, jsonb 는 Map/List 로).
  /// [pipeline]/[module]/[flutterScreen] : dev audit 분류용 메타.
  /// [correlationId] : 지정하지 않으면 자동 생성.
  /// [injectCorrelationIdAs] : 지정하면 해당 키로 correlation_id 를 params 에 주입
  ///   (예: 'p_correlation_id'). RPC 가 그 인자를 받을 때만 사용할 것.
  Future<RpcResult<T>> call<T>(
    String fnName, {
    Map<String, dynamic>? params,
    String schema = AppConstants.schemaPublic,
    String pipeline = AppConstants.pipelineSession,
    String module = 'unknown',
    String? flutterScreen,
    String? correlationId,
    String? injectCorrelationIdAs,
  }) async {
    final cid = correlationId ?? _uuid.v4();
    final stopwatch = Stopwatch()..start();

    // --- INV-004 가드: 서버 전용 RPC 직접 호출 차단 ---
    if (AppConstants.forbiddenClientRpcs.contains(fnName)) {
      final err = AppError.forbiddenClientCall(fnName, correlationId: cid);
      await _writeAudit(
        pipeline: pipeline,
        module: module,
        fnName: fnName,
        flutterScreen: flutterScreen,
        status: 'ERROR',
        eventType: 'FORBIDDEN_CLIENT_CALL',
        durationMs: stopwatch.elapsedMilliseconds,
        error: err,
      );
      return RpcResult.failure(err, cid);
    }

    final effectiveParams = <String, dynamic>{...?params};
    if (injectCorrelationIdAs != null) {
      effectiveParams[injectCorrelationIdAs] = cid;
    }

    try {
      final dynamic raw = await _rpc(
        schema: schema,
        fnName: fnName,
        params: effectiveParams.isEmpty ? null : effectiveParams,
      );

      stopwatch.stop();
      await _writeAudit(
        pipeline: pipeline,
        module: module,
        fnName: fnName,
        flutterScreen: flutterScreen,
        status: 'SUCCESS',
        eventType: 'RPC_CALL',
        durationMs: stopwatch.elapsedMilliseconds,
        inputPayload: params,
      );

      return RpcResult.success(raw as T, cid);
    } on PostgrestException catch (e) {
      stopwatch.stop();
      final err = AppError.rpc(
        e.message,
        code: e.code ?? AppError.codeRpc,
        correlationId: cid,
        details: {
          if (e.code != null) 'pg_code': e.code,
          if (e.hint != null) 'hint': e.hint,
          if (e.details != null) 'pg_details': e.details,
        },
        cause: e,
      );
      await _writeAudit(
        pipeline: pipeline,
        module: module,
        fnName: fnName,
        flutterScreen: flutterScreen,
        status: 'ERROR',
        eventType: 'RPC_CALL',
        durationMs: stopwatch.elapsedMilliseconds,
        inputPayload: params,
        error: err,
      );
      return RpcResult.failure(err, cid);
    } catch (e) {
      stopwatch.stop();
      // Postgrest 외 실패는 대체로 네트워크/전송 계층.
      final err = AppError.network(e, correlationId: cid);
      await _writeAudit(
        pipeline: pipeline,
        module: module,
        fnName: fnName,
        flutterScreen: flutterScreen,
        status: 'ERROR',
        eventType: 'RPC_CALL',
        durationMs: stopwatch.elapsedMilliseconds,
        inputPayload: params,
        error: err,
      );
      return RpcResult.failure(err, cid);
    }
  }

  /// 스키마에 맞춰 rpc 빌더를 선택한다.
  Future<dynamic> _rpc({
    required String schema,
    required String fnName,
    Map<String, dynamic>? params,
  }) {
    if (schema == AppConstants.schemaPublic) {
      return _client.rpc(fnName, params: params);
    }
    return _client.schema(schema).rpc(fnName, params: params);
  }

  /// dev audit 로그 기록. prod 에서는 no-op.
  /// audit 실패가 절대 주 흐름을 깨지 않도록 조용히 삼킨다.
  Future<void> _writeAudit({
    required String pipeline,
    required String module,
    required String fnName,
    required String status,
    required String eventType,
    required int durationMs,
    String? flutterScreen,
    Map<String, dynamic>? inputPayload,
    AppError? error,
  }) async {
    if (!AppConstants.isDev) return;
    try {
      await _client.schema(AppConstants.schemaDev).rpc(
        'write_audit_log',
        params: {
          'p_pipeline': pipeline,
          'p_module': module,
          'p_event_type': eventType,
          'p_event_status': status,
          'p_log_session_id': logSessionId,
          'p_rpc_name': fnName,
          'p_flutter_screen': ?flutterScreen,
          'p_input_payload': ?inputPayload,
          if (error != null) 'p_error_detail': error.toJson(),
          'p_duration_ms': durationMs,
          'p_app_version': AppConstants.appVersion,
          'p_flutter_platform': defaultTargetPlatform.name,
        },
      );
    } catch (_) {
      // dev 편의 로깅일 뿐. 실패해도 무시한다.
    }
  }
}

/// 전역 RpcCaller 프로바이더.
///
/// 모든 repository / service 는 이 프로바이더를 통해 RpcCaller 를 얻는다.
final rpcCallerProvider = Provider<RpcCaller>((ref) {
  return RpcCaller(SupabaseInit.client);
});
