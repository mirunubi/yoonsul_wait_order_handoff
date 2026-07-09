-- 0092_create_flutter_edge_function_guide_rpc.sql
-- Purpose: Flutter app integration patterns and
--          Edge Function registry completion.
--          Flutter SDK patterns for all major flows,
--          Edge Function definitions for FCM/embedding/AI.
--          개발 가이드 = SQL 내 Flutter 패턴 문서화.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0091_create_saas_readiness_final_rpc.sql
-- Creates:
--   Flutter SDK 패턴 등록 (flutter_sdk_patterns)
--   Edge Function 등록 (edge_function_registry)
--   function catchmenu_common.get_flutter_sdk_guide(...)
--   function catchmenu_common.get_edge_function_list(...)
--   function catchmenu_common.health_check(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('sdk_guide_loaded', 'ko',
  'Flutter SDK 가이드가 로드되었습니다'),
('sdk_guide_loaded', 'en',
  'Flutter SDK guide loaded'),
('edge_function_list_loaded', 'ko',
  'Edge Function 목록이 로드되었습니다'),
('edge_function_list_loaded', 'en',
  'Edge Function list loaded'),
('health_check_ok', 'ko',
  '시스템이 정상 작동 중입니다'),
('health_check_ok', 'en',
  'System is healthy'),
('health_check_degraded', 'ko',
  '일부 시스템에 이상이 있습니다'),
('health_check_degraded', 'en',
  'Some systems are degraded')
on conflict (message_key, locale) do nothing;


-- =============================================
-- Edge Function 완성 등록
-- =============================================
insert into catchmenu_common.edge_function_registry (
  function_code, function_name, function_path,
  function_method, trigger_type,
  requires_auth, timeout_seconds,
  rate_limit_per_minute,
  flutter_invoke_name
) values
-- FCM 푸시 알림
(
  'FCM_PUSH_SENDER',
  'FCM 푸시 알림 발송',
  '/functions/v1/fcm-push',
  'POST', 'HTTP',
  true, 10, 200,
  'fcm-push'
),
-- pgvector 임베딩 생성
(
  'EMBEDDING_GENERATOR',
  'pgvector 임베딩 생성',
  '/functions/v1/generate-embedding',
  'POST', 'HTTP',
  true, 30, 60,
  'generate-embedding'
),
-- AI 답변 생성 (RAG)
(
  'AI_RAG_ANSWER',
  'AI RAG 답변 생성',
  '/functions/v1/ai-rag-answer',
  'POST', 'HTTP',
  true, 30, 100,
  'ai-rag-answer'
),
-- SOP 초안 생성
(
  'SOP_DRAFT_GENERATOR',
  'SOP AI 초안 생성',
  '/functions/v1/sop-draft',
  'POST', 'HTTP',
  true, 60, 10,
  'sop-draft'
),
-- 배달앱 웹훅 수신
(
  'DELIVERY_WEBHOOK',
  '배달앱 웹훅 수신',
  '/functions/v1/delivery-webhook',
  'POST', 'WEBHOOK',
  false, 10, 500,
  null
),
-- POS 동기화 웹훅
(
  'POS_SYNC_WEBHOOK',
  'POS 동기화 웹훅',
  '/functions/v1/pos-sync',
  'POST', 'WEBHOOK',
  false, 10, 300,
  null
),
-- 결제 웹훅 (Toss Payments)
(
  'PAYMENT_WEBHOOK',
  'Toss Payments 웹훅',
  '/functions/v1/payment-webhook',
  'POST', 'WEBHOOK',
  false, 10, 300,
  null
),
-- 매장 상태 브로드캐스트
(
  'STORE_STATUS_BROADCAST',
  '매장 상태 Realtime 브로드캐스트',
  '/functions/v1/store-broadcast',
  'POST', 'SCHEDULED',
  true, 5, 60,
  null
),
-- 일일 리포트 생성
(
  'DAILY_REPORT_GENERATOR',
  '일일 운영 리포트 생성',
  '/functions/v1/daily-report',
  'POST', 'SCHEDULED',
  true, 60, 5,
  null
),
-- 고객 앱 세션 갱신
(
  'SESSION_REFRESH',
  '고객 앱 세션 갱신',
  '/functions/v1/session-refresh',
  'POST', 'HTTP',
  true, 5, 500,
  'session-refresh'
)
on conflict (tenant_id, function_code) do update set
  timeout_seconds = excluded.timeout_seconds;


-- =============================================
-- Flutter SDK 패턴 완성 등록
-- =============================================
insert into catchmenu_common.flutter_sdk_patterns (
  pattern_code, pattern_name,
  pattern_category, device_types,
  description, dependencies, dart_code
) values

-- 1. 직원 앱 부트스트랩
(
  'FLUTTER_STAFF_BOOTSTRAP',
  '직원 앱 부트스트랩 패턴',
  'RPC_CALL',
  '["STAFF_APP","POS_TERMINAL"]'::jsonb,
  '직원 앱 시작 시 매장 상태 + KDS + 대기 로드',
  '["supabase_flutter: ^2.0.0"]'::jsonb,
  $dart$
// lib/services/staff_bootstrap_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class StaffBootstrapService {
  final _sb = Supabase.instance.client;

  Future<Map<String, dynamic>> bootstrap({
    required String tenantId,
    required String storeId,
    required String staffId,
  }) async {
    final res = await _sb.rpc(
      'bootstrap_staff_app',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_staff_id': staffId,
        'p_locale': 'ko',
      },
    );
    return res as Map<String, dynamic>;
  }
}
$dart$
),

-- 2. Realtime 채널 구독 패턴
(
  'FLUTTER_REALTIME_SUBSCRIBE',
  'Realtime 채널 구독 패턴',
  'REALTIME',
  '["STAFF_APP","KDS_DISPLAY","DID_DISPLAY"]'::jsonb,
  'KDS/주문/매장 상태 Realtime 구독',
  '["supabase_flutter: ^2.0.0"]'::jsonb,
  $dart$
// lib/services/realtime_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeService {
  final _sb = Supabase.instance.client;
  final Map<String, RealtimeChannel> _channels = {};

  // KDS 채널 구독
  void subscribeKds({
    required String storeId,
    required Function(Map) onTicketUpdate,
  }) {
    final channel = _sb
      .channel('kds:$storeId')
      .onBroadcast(
        event: 'kds_ticket_updated',
        callback: (payload) =>
          onTicketUpdate(payload),
      )
      .onBroadcast(
        event: 'kds_capacity_changed',
        callback: (payload) =>
          onTicketUpdate(payload),
      )
      .subscribe();
    _channels['kds:$storeId'] = channel;
  }

  // 직원 알림 구독
  void subscribeStaffAlerts({
    required String storeId,
    required Function(Map) onAlert,
  }) {
    final channel = _sb
      .channel('staff:$storeId')
      .onBroadcast(
        event: 'takeout_order_received',
        callback: (payload) => onAlert(payload),
      )
      .onBroadcast(
        event: 'waiting_session_created',
        callback: (payload) => onAlert(payload),
      )
      .onBroadcast(
        event: 'delivery_order_cancelled',
        callback: (payload) => onAlert(payload),
      )
      .subscribe();
    _channels['staff:$storeId'] = channel;
  }

  // DID 채널 구독
  void subscribeDid({
    required String storeId,
    required Function(Map) onDisplayUpdate,
  }) {
    final channel = _sb
      .channel('did:$storeId')
      .onBroadcast(
        event: 'PICKUP_READY',
        callback: (payload) =>
          onDisplayUpdate(payload),
      )
      .onBroadcast(
        event: 'call_dismissed',
        callback: (payload) =>
          onDisplayUpdate(payload),
      )
      .subscribe();
    _channels['did:$storeId'] = channel;
  }

  void unsubscribeAll() {
    for (final ch in _channels.values) {
      ch.unsubscribe();
    }
    _channels.clear();
  }
}
$dart$
),

-- 3. KDS 화면 패턴
(
  'FLUTTER_KDS_SCREEN',
  'KDS 화면 패턴',
  'RPC_CALL',
  '["KDS_DISPLAY","STAFF_APP"]'::jsonb,
  'KDS 티켓 목록 + 상태 변경 + Realtime',
  '["supabase_flutter: ^2.0.0","flutter_riverpod: ^2.0.0"]'::jsonb,
  $dart$
// lib/screens/kds_screen.dart
// KDS 티켓 로드 + 상태 전환
import 'package:supabase_flutter/supabase_flutter.dart';

class KdsService {
  final _sb = Supabase.instance.client;

  // KDS 현황 로드
  Future<Map<String, dynamic>> getKdsState({
    required String tenantId,
    required String storeId,
  }) async {
    return await _sb.rpc(
      'get_kds_state',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
      },
    );
  }

  // 티켓 상태 전환
  Future<Map<String, dynamic>> transitionTicket({
    required String tenantId,
    required String storeId,
    required String ticketId,
    required String newStatus,
    String? staffId,
  }) async {
    return await _sb.rpc(
      'transition_kds_ticket',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_ticket_id': ticketId,
        'p_new_status': newStatus,
        'p_actor_id': staffId,
      },
    );
  }

  // KDS 용량 확인 (특허2 Late Binding)
  Future<Map<String, dynamic>> checkCapacity({
    required String tenantId,
    required String storeId,
  }) async {
    return await _sb.rpc(
      'check_kds_capacity',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
      },
    );
  }
}
$dart$
),

-- 4. 포장 주문 플로우 패턴
(
  'FLUTTER_TAKEOUT_FLOW',
  '포장 주문 플로우 패턴',
  'RPC_CALL',
  '["CUSTOMER_APP"]'::jsonb,
  '고객 앱 포장 주문 엔드투엔드',
  '["supabase_flutter: ^2.0.0"]'::jsonb,
  $dart$
// lib/services/takeout_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class TakeoutService {
  final _sb = Supabase.instance.client;

  // 포장 주문 접수
  Future<Map<String, dynamic>> placeOrder({
    required String tenantId,
    required String storeId,
    String? customerId,
    required List<Map<String, dynamic>> items,
    String? requestMemo,
    String? couponIssueId,
    int usePoints = 0,
    DateTime? requestedPickupAt,
  }) async {
    return await _sb.rpc(
      'place_takeout_order',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_customer_id': customerId,
        'p_items': items,
        'p_request_memo': requestMemo,
        'p_coupon_issue_id': couponIssueId,
        'p_use_points': usePoints,
        'p_requested_pickup_at':
          requestedPickupAt?.toIso8601String(),
        'p_locale': 'ko',
      },
    );
  }

  // 주문 추적
  Future<Map<String, dynamic>> trackOrder({
    required String tenantId,
    required String storeId,
    required String orderId,
  }) async {
    return await _sb.rpc(
      'track_takeout_order',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_order_id': orderId,
        'p_locale': 'ko',
      },
    );
  }

  // 픽업 호출 (직원 앱)
  Future<Map<String, dynamic>> callPickup({
    required String tenantId,
    required String storeId,
    required String orderId,
  }) async {
    return await _sb.rpc(
      'call_customer_pickup',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_order_id': orderId,
        'p_queue_type': 'PICKUP_READY',
        'p_locale': 'ko',
      },
    );
  }
}
$dart$
),

-- 5. 대기 흐름 패턴
(
  'FLUTTER_WAITING_FLOW',
  '대기 흐름 패턴',
  'RPC_CALL',
  '["MINI_KIOSK","STAFF_APP"]'::jsonb,
  '고객 대기 등록 → 착석 → 주문 핸드오프',
  '["supabase_flutter: ^2.0.0"]'::jsonb,
  $dart$
// lib/services/waiting_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class WaitingService {
  final _sb = Supabase.instance.client;

  // 대기 등록 (특허1: Wait/Order Handoff)
  Future<Map<String, dynamic>> registerWaiting({
    required String tenantId,
    required String storeId,
    required int guestCount,
    String? phoneHash,
    String locale = 'ko',
  }) async {
    return await _sb.rpc(
      'register_waiting_session',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_guest_count': guestCount,
        'p_phone_hash': phoneHash,
        'p_locale': locale,
      },
    );
  }

  // 대기 현황 조회
  Future<Map<String, dynamic>> getWaitingStatus({
    required String tenantId,
    required String storeId,
  }) async {
    return await _sb.rpc(
      'get_waiting_dashboard',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
      },
    );
  }

  // 착석 처리 (직원)
  Future<Map<String, dynamic>> seatCustomer({
    required String tenantId,
    required String storeId,
    required String sessionId,
    required String tableNumber,
    String? staffId,
  }) async {
    return await _sb.rpc(
      'seat_waiting_customer',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_session_id': sessionId,
        'p_table_number': tableNumber,
        'p_actor_id': staffId,
        'p_locale': 'ko',
      },
    );
  }
}
$dart$
),

-- 6. 결제 플로우 패턴
(
  'FLUTTER_PAYMENT_FLOW',
  '결제 플로우 패턴',
  'RPC_CALL',
  '["POS_TERMINAL","STAFF_APP"]'::jsonb,
  '토스페이먼츠 결제 요청 + 확인 + 영수증',
  '["supabase_flutter: ^2.0.0","tosspayments_sdk: ^1.0.0"]'::jsonb,
  $dart$
// lib/services/payment_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentService {
  final _sb = Supabase.instance.client;

  // 결제 요청 초기화
  Future<Map<String, dynamic>> initiatePayment({
    required String tenantId,
    required String storeId,
    required String orderId,
    required int amount,
    required String paymentMethod,
    String locale = 'ko',
  }) async {
    return await _sb.rpc(
      'initiate_payment',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_order_id': orderId,
        'p_amount': amount,
        'p_payment_method': paymentMethod,
        'p_locale': locale,
      },
    );
  }

  // 결제 확인 (웹훅 또는 폴링)
  Future<Map<String, dynamic>> confirmPayment({
    required String tenantId,
    required String storeId,
    required String orderId,
    required String providerType,
    required String approvalNumber,
    required int approvedAmount,
  }) async {
    return await _sb.rpc(
      'confirm_payment_from_provider',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_order_id': orderId,
        'p_provider_type': providerType,
        'p_provider_approval_number':
          approvalNumber,
        'p_approved_amount': approvedAmount,
        'p_locale': 'ko',
      },
    );
  }
}
$dart$
),

-- 7. AI 고객센터 패턴
(
  'FLUTTER_AI_CUSTOMER',
  'AI 고객센터 패턴',
  'RPC_CALL',
  '["CUSTOMER_APP","STAFF_APP"]'::jsonb,
  '고객 문의 → AI RAG 검색 → 답변 → 에스컬레이션',
  '["supabase_flutter: ^2.0.0"]'::jsonb,
  $dart$
// lib/services/ai_customer_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AiCustomerService {
  final _sb = Supabase.instance.client;

  // AI RAG 답변 요청 (Edge Function)
  Future<Map<String, dynamic>> askAi({
    required String tenantId,
    required String storeId,
    required String queryText,
    String locale = 'ko',
    String? customerId,
  }) async {
    // 1. Edge Function으로 RAG 검색 + AI 답변
    final res = await _sb.functions.invoke(
      'ai-rag-answer',
      body: {
        'tenant_id': tenantId,
        'store_id': storeId,
        'query_text': queryText,
        'locale': locale,
        'customer_id': customerId,
      },
    );

    final data = res.data as Map<String, dynamic>;

    // 2. 쿼리 로그 기록
    await _sb.rpc(
      'log_ai_query',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_query_text': queryText,
        'p_query_type': 'FAQ_LOOKUP',
        'p_query_locale': locale,
        'p_channel': 'APP',
        'p_search_result_count':
          data['chunk_count'] ?? 0,
        'p_is_grounded':
          data['is_grounded'] ?? false,
        'p_ai_answer': data['answer'],
        'p_cited_document_ids':
          data['cited_document_ids'],
        'p_verdict': data['verdict'],
        'p_customer_id': customerId,
      },
    );

    return data;
  }

  // 문의 접수
  Future<Map<String, dynamic>> submitInquiry({
    required String tenantId,
    required String storeId,
    required String inquiryType,
    required String categoryCode,
    required String inquiryBody,
    String? customerId,
    String? aiAnswer,
    bool aiResolved = false,
    String locale = 'ko',
  }) async {
    return await _sb.rpc(
      'submit_customer_inquiry',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_inquiry_type': inquiryType,
        'p_category_code': categoryCode,
        'p_inquiry_body': inquiryBody,
        'p_customer_id': customerId,
        'p_ai_answer': aiAnswer,
        'p_ai_resolved': aiResolved,
        'p_locale': locale,
      },
    );
  }
}
$dart$
),

-- 8. DID 디스플레이 앱 패턴
(
  'FLUTTER_DID_APP',
  'DID 디스플레이 앱 패턴',
  'REALTIME',
  '["DID_DISPLAY"]'::jsonb,
  'DID Flutter 앱 폴링 + Realtime 호출 표시',
  '["supabase_flutter: ^2.0.0"]'::jsonb,
  $dart$
// lib/screens/did_screen.dart
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class DidDisplayService {
  final _sb = Supabase.instance.client;
  Timer? _pollTimer;

  // DID 표시 데이터 폴링
  Future<Map<String, dynamic>> getDisplayData({
    required String tenantId,
    required String storeId,
    required String didCode,
    String locale = 'ko',
  }) async {
    return await _sb.rpc(
      'get_did_waiting_display',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_did_code': didCode,
        'p_locale': locale,
      },
    );
  }

  // 자동 폴링 시작 (refresh_interval_seconds)
  void startPolling({
    required String tenantId,
    required String storeId,
    required String didCode,
    required int intervalSeconds,
    required Function(Map) onUpdate,
  }) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) async {
        final data = await getDisplayData(
          tenantId: tenantId,
          storeId: storeId,
          didCode: didCode,
        );
        onUpdate(data);
      },
    );
  }

  // Realtime 호출 구독
  void subscribeToCallEvents({
    required String storeId,
    required Function(Map) onCall,
    required Function(Map) onDismiss,
  }) {
    _sb.channel('did:$storeId')
      .onBroadcast(
        event: 'PICKUP_READY',
        callback: (p) => onCall(p),
      )
      .onBroadcast(
        event: 'WAITING_CALL',
        callback: (p) => onCall(p),
      )
      .onBroadcast(
        event: 'call_dismissed',
        callback: (p) => onDismiss(p),
      )
      .subscribe();
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }
}
$dart$
),

-- 9. 멀티 로케일 패턴
(
  'FLUTTER_I18N_PATTERN',
  '다국어(i18n) 처리 패턴',
  'I18N',
  '["STAFF_APP","CUSTOMER_APP","MINI_KIOSK","DID_DISPLAY"]'::jsonb,
  'message_catalog 기반 다국어 메시지 처리',
  '["supabase_flutter: ^2.0.0","flutter_localizations"]'::jsonb,
  $dart$
// lib/services/i18n_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class I18nService {
  final _sb = Supabase.instance.client;
  final Map<String, String> _cache = {};

  // 지원 로케일
  static const supportedLocales = [
    'ko', 'en', 'zh', 'ja', 'vi', 'th'
  ];

  // 메시지 가져오기 (캐시 우선)
  Future<String> getMessage({
    required String messageKey,
    required String locale,
    Map<String, String>? params,
  }) async {
    final cacheKey = '$messageKey:$locale';
    if (_cache.containsKey(cacheKey)) {
      return _applyParams(
        _cache[cacheKey]!, params
      );
    }

    final res = await _sb.rpc(
      'get_message',
      params: {
        'p_message_key': messageKey,
        'p_locale': locale,
        'p_params': params,
      },
    );

    final message = res as String;
    _cache[cacheKey] = message;
    return message;
  }

  // 파라미터 치환
  String _applyParams(
    String template,
    Map<String, String>? params,
  ) {
    if (params == null) return template;
    var result = template;
    params.forEach((key, value) {
      result = result.replaceAll(
        '{$key}', value
      );
    });
    return result;
  }

  // 오류 메시지 처리
  String handleErrorKey(
    String errorKey,
    String locale,
  ) {
    return _cache['$errorKey:$locale']
      ?? errorKey;
  }
}
$dart$
),

-- 10. 오프라인 대응 패턴
(
  'FLUTTER_OFFLINE_PATTERN',
  '오프라인/네트워크 오류 대응 패턴',
  'ERROR_HANDLING',
  '["STAFF_APP","POS_TERMINAL","KDS_DISPLAY"]'::jsonb,
  '네트워크 단절 시 로컬 캐시 + 재연결 처리',
  '["supabase_flutter: ^2.0.0","connectivity_plus: ^5.0.0","hive: ^2.0.0"]'::jsonb,
  $dart$
// lib/services/offline_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OfflineService {
  final _connectivity = Connectivity();
  bool _isOnline = true;

  // 연결 상태 모니터링
  void startMonitoring({
    required Function onOnline,
    required Function onOffline,
  }) {
    _connectivity.onConnectivityChanged.listen(
      (result) {
        final wasOnline = _isOnline;
        _isOnline = result !=
          ConnectivityResult.none;

        if (!wasOnline && _isOnline) {
          onOnline();
          _syncPendingActions();
        } else if (wasOnline && !_isOnline) {
          onOffline();
        }
      }
    );
  }

  // 오프라인 시 로컬 큐에 작업 저장
  Future<void> queueAction({
    required String rpcName,
    required Map<String, dynamic> params,
  }) async {
    // Hive 또는 SQLite에 저장
    // 온라인 복구 시 자동 실행
    print('[Offline] Queued: $rpcName');
  }

  // 온라인 복구 시 대기 작업 동기화
  Future<void> _syncPendingActions() async {
    // 대기 중인 RPC 호출 순서대로 실행
    print('[Offline] Syncing pending actions');
  }

  bool get isOnline => _isOnline;
}
$dart$
)

on conflict (pattern_code) do update set
  dart_code = excluded.dart_code,
  description = excluded.description;


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_common.get_flutter_sdk_guide(
  p_pattern_category text default null,
  p_device_type text default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common
as $$
declare
  v_patterns jsonb;
  v_total int;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'pattern_code', pattern_code,
        'pattern_name', pattern_name,
        'pattern_category', pattern_category,
        'device_types', device_types,
        'description', description,
        'dependencies', dependencies,
        'dart_code', dart_code
      )
      order by pattern_category, pattern_code
    ),
    '[]'::jsonb
  )
  into v_patterns
  from catchmenu_common.flutter_sdk_patterns
  where is_active = true
    and (
      p_pattern_category is null
      or pattern_category = p_pattern_category
    )
    and (
      p_device_type is null
      or device_types @> to_jsonb(p_device_type)
    );

  v_total := jsonb_array_length(
    coalesce(v_patterns, '[]'::jsonb)
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'sdk_guide_loaded',
    p_data := jsonb_build_object(
      'category_filter', p_pattern_category,
      'device_filter', p_device_type,
      'total_patterns', v_total,
      'patterns', v_patterns,
      'supabase_client_init', $code$
// main.dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_ANON_KEY',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;
      $code$,
      'rpc_call_pattern', $code$
// 모든 RPC 호출 기본 패턴
final res = await supabase.rpc(
  'rpc_function_name',
  params: {
    'p_tenant_id': tenantId,
    'p_store_id': storeId,
    // ... 추가 파라미터
  },
);
// res['success'] == true 확인 필수
// res['data'] 에서 실제 데이터
// res['message'] i18n 메시지
      $code$
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.get_edge_function_list(
  p_trigger_type text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common
as $$
declare
  v_functions jsonb;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'function_code', function_code,
        'function_name', function_name,
        'function_path', function_path,
        'function_method', function_method,
        'trigger_type', trigger_type,
        'requires_auth', requires_auth,
        'timeout_seconds', timeout_seconds,
        'rate_limit_per_minute',
          rate_limit_per_minute,
        'flutter_invoke_name',
          flutter_invoke_name,
        'description', description
      )
      order by trigger_type, function_code
    ),
    '[]'::jsonb
  )
  into v_functions
  from catchmenu_common.edge_function_registry
  where is_active = true
    and (
      p_trigger_type is null
      or trigger_type = p_trigger_type
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'edge_function_list_loaded',
    p_data := jsonb_build_object(
      'trigger_filter', p_trigger_type,
      'total_functions',
        jsonb_array_length(
          coalesce(v_functions, '[]'::jsonb)
        ),
      'functions', v_functions,
      'invoke_pattern', $code$
// Flutter에서 Edge Function 호출
final res = await supabase.functions.invoke(
  'function-name',  // flutter_invoke_name
  body: {
    'param1': value1,
    'param2': value2,
  },
);
final data = res.data as Map<String, dynamic>;
      $code$
    ),
    p_locale := 'ko'
  );
end;
$$;


-- add_health was originally (incorrectly) written as a nested procedure
-- inside health_check's DECLARE section -- same invalid pattern as
-- 0073's assert_true and others found this session. Fixed the same way:
-- a real standalone function, logging to a temp table since a
-- standalone routine can't mutate health_check's local variables
-- directly. All 5 `perform catchmenu_common.add_health_check_item(...)` sites below were mechanically
-- changed to `perform add_health_check_item(...)` -- no argument list
-- touched.
create temp table if not exists health_check_items (
  ordinal bigint generated always as identity,
  component text,
  status text,
  detail jsonb,
  checked_at timestamptz
);

create or replace function catchmenu_common.add_health_check_item(
  p_component text,
  p_status text,
  p_detail jsonb default null
)
returns void
language plpgsql
as $$
begin
  insert into pg_temp.health_check_items
    (component, status, detail, checked_at)
    values (p_component, p_status, p_detail, now());
end;
$$;

create or replace function
  catchmenu_common.health_check(
  p_tenant_id uuid default null,
  p_store_id uuid default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common,
                  catchmenu_hq,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_payment
as $$
declare
  v_checks jsonb := '[]'::jsonb;
  v_overall text := 'HEALTHY';
  v_business_day date;
begin
  delete from pg_temp.health_check_items;
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- DB 연결
  perform catchmenu_common.add_health_check_item(
    'DATABASE', 'HEALTHY',
    jsonb_build_object(
      'connection', 'ok',
      'timestamp', now()
    )
  );

  -- 스키마 확인
  declare
    v_schema_count int;
  begin
    select count(*) into v_schema_count
    from information_schema.schemata
    where schema_name like 'catchmenu_%';

    perform catchmenu_common.add_health_check_item(
      'SCHEMAS',
      case v_schema_count >= 9
        when true then 'HEALTHY'
        else 'DEGRADED'
      end,
      jsonb_build_object(
        'schema_count', v_schema_count,
        'expected', 9
      )
    );
  end;

  -- 테넌트별 상태 확인
  if p_tenant_id is not null then
    declare
      v_plan_status text;
      v_store_count int;
    begin
      select plan_status
      into v_plan_status
      from catchmenu_common.tenant_plan_configs
      where tenant_id = p_tenant_id;

      perform catchmenu_common.add_health_check_item(
        'TENANT_PLAN',
        case v_plan_status
          when 'ACTIVE' then 'HEALTHY'
          when 'TRIAL' then 'HEALTHY'
          else 'DEGRADED'
        end,
        jsonb_build_object(
          'plan_status', v_plan_status
        )
      );
    end;
  end if;

  -- KDS 상태
  if p_store_id is not null then
    declare
      v_stuck_tickets int;
    begin
      select count(*) into v_stuck_tickets
      from catchmenu_kds.kds_tickets
      where store_id = p_store_id
        and business_day = v_business_day
        and kds_status = 'COOKING'
        and cooking_started_at
          < now() - interval '60 minutes';

      perform catchmenu_common.add_health_check_item(
        'KDS',
        case v_stuck_tickets
          when 0 then 'HEALTHY'
          else 'DEGRADED'
        end,
        jsonb_build_object(
          'stuck_tickets_60min',
            v_stuck_tickets
        )
      );
    end;
  end if;

  -- 미해결 대사 확인
  if p_store_id is not null then
    declare
      v_open_recon_cases int;
    begin
      select count(*) into v_open_recon_cases
      from catchmenu_payment.reconciliation_cases
      where store_id = p_store_id
        and case_status in (
          'OPEN', 'INVESTIGATING'
        )
        and case_severity = 'CRITICAL';

      perform catchmenu_common.add_health_check_item(
        'RECONCILIATION',
        case v_open_recon_cases
          when 0 then 'HEALTHY'
          else 'DEGRADED'
        end,
        jsonb_build_object(
          'critical_open_cases',
            v_open_recon_cases
        )
      );
    end;
  end if;

  -- populate v_checks/v_overall from the temp table now that all
  -- add_health_check_item() calls above have logged into it
  select
    coalesce(jsonb_agg(
      jsonb_build_object(
        'component', component,
        'status', status,
        'detail', detail,
        'checked_at', checked_at
      )
      order by ordinal
    ), '[]'::jsonb),
    case
      when bool_or(status = 'DOWN') then 'DOWN'
      when bool_or(status = 'DEGRADED') then 'DEGRADED'
      else 'HEALTHY'
    end
  into v_checks, v_overall
  from pg_temp.health_check_items;

  return catchmenu_common.build_success_response(
    p_message_key := case v_overall
      when 'HEALTHY' then 'health_check_ok'
      else 'health_check_degraded'
    end,
    p_data := jsonb_build_object(
      'overall', v_overall,
      'business_day', v_business_day,
      'tenant_id', p_tenant_id,
      'store_id', p_store_id,
      'components', v_checks,
      'component_count',
        jsonb_array_length(v_checks),
      'checked_at', now(),
      'version', jsonb_build_object(
        'schema_version', '0092',
        'project', 'catchmenu',
        'last_migration', '0092_flutter_edge_guide'
      )
    ),
    p_locale := 'ko'
  );
end;
$$;


-- grants
do $$
begin
  revoke all on function
    catchmenu_common.get_flutter_sdk_guide(
      text, text, text
    ) from public;
  grant execute on function
    catchmenu_common.get_flutter_sdk_guide(
      text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.get_edge_function_list(text)
    from public;
  grant execute on function
    catchmenu_common.get_edge_function_list(text)
    to authenticated;

  revoke all on function
    catchmenu_common.health_check(uuid, uuid)
    from public;
  grant execute on function
    catchmenu_common.health_check(uuid, uuid)
    to authenticated;

  -- anon도 health_check 허용 (모니터링용)
  grant execute on function
    catchmenu_common.health_check(uuid, uuid)
    to anon;
end;
$$;

comment on function
  catchmenu_common.get_flutter_sdk_guide(
    text, text, text
  ) is
  'Flutter SDK 개발 가이드 로드.
   등록된 패턴 (10개):
   - FLUTTER_STAFF_BOOTSTRAP: 직원 앱 부트스트랩
   - FLUTTER_REALTIME_SUBSCRIBE: Realtime 구독
   - FLUTTER_KDS_SCREEN: KDS 화면
   - FLUTTER_TAKEOUT_FLOW: 포장 주문
   - FLUTTER_WAITING_FLOW: 대기 흐름
   - FLUTTER_PAYMENT_FLOW: 결제 처리
   - FLUTTER_AI_CUSTOMER: AI 고객센터
   - FLUTTER_DID_APP: DID 디스플레이
   - FLUTTER_I18N_PATTERN: 다국어 처리
   - FLUTTER_OFFLINE_PATTERN: 오프라인 대응
   device_type 필터:
   STAFF_APP / CUSTOMER_APP / KDS_DISPLAY /
   DID_DISPLAY / MINI_KIOSK / POS_TERMINAL';

comment on function
  catchmenu_common.health_check(uuid, uuid)
  is
  '시스템 헬스 체크.
   anon 권한 허용 (모니터링 대시보드용).
   확인 항목:
   - DATABASE: DB 연결
   - SCHEMAS: catchmenu_ 스키마 수
   - TENANT_PLAN: 플랜 상태
   - KDS: 60분 이상 조리 중 티켓
   - RECONCILIATION: CRITICAL 미해결 대사
   overall: HEALTHY / DEGRADED / DOWN.
   Flutter 앱 시작 시 health_check() 먼저 호출.
   DEGRADED → 알림 표시 후 계속 진행.
   DOWN → 오프라인 모드 전환.';