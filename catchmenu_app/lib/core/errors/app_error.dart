/// 표준 에러 포맷.
///
/// rpc_caller 를 통과하는 모든 실패는 반드시 이 타입으로 정규화된다.
/// 화면/상태 계층은 raw PostgrestException 이나 dynamic 을 직접 다루지 않는다.
class AppError implements Exception {
  /// 기계가 분기할 수 있는 안정적인 코드 (아래 code* 상수 중 하나 권장).
  final String code;

  /// 사람이 읽는 메시지 (개발/로그용, UI 는 별도 문구 매핑 권장).
  final String message;

  /// 이 실패를 낳은 호출의 correlation_id. 로그 추적용.
  final String? correlationId;

  /// 원인 예외 (있으면).
  final Object? cause;

  /// 서버가 준 추가 정보 (postgres code, hint, details 등).
  final Map<String, dynamic>? details;

  const AppError({
    required this.code,
    required this.message,
    this.correlationId,
    this.cause,
    this.details,
  });

  // --- 잘 알려진 코드 ---
  static const String codeNetwork = 'NETWORK_ERROR';
  static const String codeRpc = 'RPC_ERROR';
  static const String codeForbiddenClientCall = 'FORBIDDEN_CLIENT_CALL';
  static const String codeNotInitialized = 'NOT_INITIALIZED';
  static const String codeUnknown = 'UNKNOWN_ERROR';

  /// 네트워크/전송 계층 실패.
  factory AppError.network(
    Object cause, {
    String? correlationId,
  }) =>
      AppError(
        code: codeNetwork,
        message: '네트워크 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.',
        correlationId: correlationId,
        cause: cause,
      );

  /// 서버 RPC / Postgres 실패.
  factory AppError.rpc(
    String message, {
    String? code,
    String? correlationId,
    Map<String, dynamic>? details,
    Object? cause,
  }) =>
      AppError(
        code: code ?? codeRpc,
        message: message,
        correlationId: correlationId,
        details: details,
        cause: cause,
      );

  /// INV-004 위반: 클라이언트가 서버 전용 RPC 를 직접 호출하려 함.
  factory AppError.forbiddenClientCall(
    String fnName, {
    String? correlationId,
  }) =>
      AppError(
        code: codeForbiddenClientCall,
        message:
            'INV-004 위반: "$fnName" 은 서버 전용(SYSTEM) RPC 이므로 클라이언트에서 호출할 수 없습니다.',
        correlationId: correlationId,
        details: {'fn': fnName},
      );

  /// Supabase 미초기화 / 설정 누락.
  factory AppError.notInitialized(String message) => AppError(
        code: codeNotInitialized,
        message: message,
      );

  /// 정체 불명 실패.
  factory AppError.unknown(
    Object cause, {
    String? correlationId,
  }) =>
      AppError(
        code: codeUnknown,
        message: '알 수 없는 오류가 발생했습니다.',
        correlationId: correlationId,
        cause: cause,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        if (correlationId != null) 'correlation_id': correlationId,
        if (details != null) 'details': details,
        if (cause != null) 'cause': cause.toString(),
      };

  @override
  String toString() =>
      'AppError($code: $message${correlationId != null ? ', cid=$correlationId' : ''})';
}
