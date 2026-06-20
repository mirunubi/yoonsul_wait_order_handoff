-- 0113_create_api_spec_docs.sql (PART 1)
-- Purpose: API specification and Flutter dev guide
--          registration in knowledge base.
-- Depends on: 0112_create_hq_admin_rpc.sql
-- Note: $ko$ 내부 코드블록 금지 — 일반 텍스트로 처리

-- =============================================
-- API 명세 문서 등록
-- =============================================
insert into catchmenu_knowledge.documents (
  tenant_id, store_id,
  document_code, document_title,
  document_type, domain,
  content_ko, content_en,
  version_number, document_status,
  is_tenant_approved,
  approved_at, effective_from, created_by
) values

-- -----------------------------------------------
-- 1. 전체 RPC 매핑표
-- -----------------------------------------------
(
  '00000000-0000-0000-0000-000000000001',
  null,
  'API_SPEC_RPC_MAP_001',
  'Catch Menu RPC 전체 매핑표',
  'SPEC', 'ARCHITECTURE',
  $ko$
# Catch Menu RPC 전체 매핑표

## 0. 기본 원칙

모든 RPC는 아래 표준 응답 구조를 반환한다.

성공 시 반환 필드:
  success: true
  message: 메시지 문자열 (i18n key 기반)
  data: 응답 데이터 객체
  error_code: null
  error_key: null
  correlation_id: 요청 추적 UUID

오류 시 반환 필드:
  success: false
  message: 오류 메시지 문자열
  data: null
  error_code: 숫자 코드 (예: 1001)
  error_key: 오류 키 문자열 (예: auth_required)
  correlation_id: 요청 추적 UUID

모든 RPC 호출 시 correlation_id 를 반드시 포함한다.
모든 상태 변경은 ledger event 로 기록된다.
모든 테이블에 RLS 가 활성화되어 있다.
SQL 내 한글 하드코딩 금지 — i18n key 로 처리한다.

## 1. 인증 파이프라인

RPC: catchmenu_common.register_device
설명: 디바이스 등록
권한: authenticated

RPC: catchmenu_common.verify_device_trust
설명: 디바이스 신뢰 검증
권한: authenticated

RPC: catchmenu_common.staff_login
설명: 직원 PIN 로그인
권한: authenticated

RPC: catchmenu_common.staff_logout
설명: 직원 로그아웃
권한: authenticated

RPC: catchmenu_common.refresh_auth_session
설명: 세션 갱신
권한: authenticated

RPC: catchmenu_common.customer_phone_verify_send
설명: 고객 전화 인증 발송
권한: authenticated

RPC: catchmenu_common.customer_login
설명: 고객 로그인
권한: authenticated

RPC: catchmenu_common.get_auth_context
설명: 인증 컨텍스트 조회
권한: authenticated

## 2. 직원 앱 부트스트랩

RPC: catchmenu_common.bootstrap_staff_app
설명: 직원 앱 전체 초기화
권한: authenticated

RPC: catchmenu_store.open_store
설명: 매장 오픈
권한: authenticated

RPC: catchmenu_store.close_store
설명: 매장 마감
권한: authenticated

RPC: catchmenu_store.change_store_mode
설명: 매장 모드 변경
권한: authenticated

RPC: catchmenu_store.get_store_dashboard
설명: 매장 대시보드 조회
권한: authenticated

## 3. 메뉴 / 주문

RPC: catchmenu_pos.get_menu_catalog_i18n
설명: 메뉴 카탈로그 i18n 조회
권한: authenticated

RPC: catchmenu_pos.place_takeout_order
설명: POS 포장 주문
권한: authenticated

RPC: catchmenu_store.bootstrap_customer_app
설명: 고객 앱 초기화
권한: authenticated

RPC: catchmenu_store.place_takeout_order
설명: 고객 포장 주문
권한: authenticated

## 4. KDS 파이프라인

특허2 원칙 적용:
  결제 전: KDS 티켓 상태 = HOLD
  결제 후: catchmenu_payment.release_kds_after_payment 호출로 COMMITTED 전환
  HOLD 상태에서는 주방 실행 불가

RPC: catchmenu_kds.get_kds_realtime_state
설명: KDS 실시간 상태 조회
권한: authenticated

RPC: catchmenu_kds.transition_kds_ticket
설명: KDS 상태 전환 (HOLD → COMMITTED → IN_PROGRESS → DONE)
권한: authenticated

RPC: catchmenu_kds.check_kds_capacity
설명: KDS 용량 확인
권한: authenticated

## 5. 결제 파이프라인

RPC: catchmenu_payment.confirm_payment
설명: 결제 확인 (핵심 RPC)
권한: authenticated

RPC: catchmenu_payment.release_kds_after_payment
설명: KDS Late Binding 해제 — 결제 후 HOLD → COMMITTED 전환
권한: authenticated

RPC: catchmenu_payment.request_refund
설명: 환불 요청
권한: authenticated

RPC: catchmenu_payment.confirm_refund
설명: 환불 확인
권한: authenticated

RPC: catchmenu_payment.get_payment_status
설명: 결제 상태 조회
권한: authenticated

RPC: catchmenu_integrations.initiate_toss_payment
설명: 토스페이먼츠 결제 시작
권한: authenticated

RPC: catchmenu_integrations.confirm_toss_payment
설명: 토스페이먼츠 결제 확인
권한: authenticated

RPC: catchmenu_integrations.cancel_toss_payment
설명: 토스페이먼츠 취소
권한: authenticated

RPC: catchmenu_integrations.process_toss_webhook
설명: 토스 웹훅 처리
권한: authenticated

## 6. 대기 파이프라인

RPC: catchmenu_pos.get_waiting_realtime_state
설명: 대기 실시간 상태 조회
권한: authenticated

RPC: catchmenu_pos.estimate_wait_time
설명: 대기 시간 예측
권한: authenticated

RPC: catchmenu_store.call_customer_pickup
설명: 고객 호출
권한: authenticated

## 7. Realtime 파이프라인

RPC: catchmenu_common.get_realtime_config
설명: Realtime 설정 조회
권한: authenticated

RPC: catchmenu_common.broadcast_store_event
설명: 이벤트 브로드캐스트
권한: authenticated

RPC: catchmenu_common.get_staff_alert_feed
설명: 직원 알림 피드 조회
권한: authenticated

## 8. POS 연동

RPC: catchmenu_integrations.sync_okpos_menu
설명: OKpos 메뉴 동기화
권한: authenticated

RPC: catchmenu_integrations.send_order_to_okpos
설명: OKpos 주문 전송
권한: authenticated

RPC: catchmenu_integrations.confirm_okpos_payment
설명: OKpos 결제 확인
권한: authenticated

RPC: catchmenu_integrations.sync_toss_pos_menu
설명: 토스POS 메뉴 동기화
권한: authenticated

RPC: catchmenu_integrations.send_order_to_toss_pos
설명: 토스POS 주문 전송
권한: authenticated

RPC: catchmenu_integrations.confirm_toss_pos_payment
설명: 토스POS 결제 확인
권한: authenticated

## 9. 배달 플랫폼

RPC: catchmenu_integrations.receive_delivery_order
설명: 배달 주문 수신 (배민/요기요/쿠팡이츠)
권한: authenticated

RPC: catchmenu_integrations.accept_delivery_order
설명: 배달 주문 수락
권한: authenticated

RPC: catchmenu_integrations.reject_delivery_order
설명: 배달 주문 거절
권한: authenticated

RPC: catchmenu_integrations.update_delivery_status
설명: 배달 상태 업데이트
권한: authenticated

RPC: catchmenu_integrations.get_delivery_dashboard
설명: 배달 대시보드 조회
권한: authenticated

## 10. 현금영수증

RPC: catchmenu_integrations.issue_cash_receipt
설명: 현금영수증 발급
권한: authenticated

RPC: catchmenu_integrations.auto_issue_cash_receipt
설명: 자동 발급 판단
권한: authenticated

RPC: catchmenu_integrations.confirm_cash_receipt
설명: 발급 확인
권한: authenticated

RPC: catchmenu_integrations.cancel_cash_receipt
설명: 현금영수증 취소
권한: authenticated

## 11. CMS / 이벤트

RPC: catchmenu_store.create_cms_event
설명: 이벤트 생성
권한: authenticated

RPC: catchmenu_store.publish_cms_event
설명: 이벤트 발행
권한: authenticated

RPC: catchmenu_store.create_cms_banner
설명: 배너 생성
권한: authenticated

RPC: catchmenu_store.create_cms_popup
설명: 팝업 생성
권한: authenticated

RPC: catchmenu_store.get_cms_display_bundle
설명: CMS 표시 번들 조회
권한: authenticated

RPC: catchmenu_store.get_cms_dashboard
설명: CMS 대시보드 조회
권한: authenticated

## 12. 멤버십

RPC: catchmenu_store.earn_points_after_order
설명: 주문 후 포인트 적립
권한: authenticated

RPC: catchmenu_store.stamp_visit
설명: 스탬프 적립
권한: authenticated

RPC: catchmenu_store.get_customer_membership
설명: 고객 멤버십 조회
권한: authenticated

RPC: catchmenu_store.get_membership_dashboard
설명: 멤버십 대시보드 조회
권한: authenticated

## 13. 네트워크 / 오프라인

RPC: catchmenu_common.report_network_status
설명: 네트워크 상태 보고
권한: authenticated

RPC: catchmenu_common.enqueue_offline_action
설명: 오프라인 큐 등록
권한: authenticated

RPC: catchmenu_common.flush_offline_queue
설명: 오프라인 큐 동기화
권한: authenticated

RPC: catchmenu_common.get_fallback_config
설명: Fallback 설정 조회
권한: authenticated

## 14. 매장 관리자

RPC: catchmenu_store.upsert_menu
설명: 메뉴 등록/수정
권한: authenticated

RPC: catchmenu_store.set_menu_status
설명: 메뉴 상태 변경
권한: authenticated

RPC: catchmenu_store.get_menu_admin_list
설명: 메뉴 목록 조회
권한: authenticated

RPC: catchmenu_store.upsert_staff
설명: 직원 등록/수정
권한: authenticated

RPC: catchmenu_store.get_staff_admin_list
설명: 직원 목록 조회
권한: authenticated

RPC: catchmenu_store.set_store_hours
설명: 영업시간 설정
권한: authenticated

RPC: catchmenu_store.set_holiday
설명: 휴무일 설정
권한: authenticated

RPC: catchmenu_store.update_store_settings
설명: 매장 설정 변경
권한: authenticated

RPC: catchmenu_store.setup_pos_integration
설명: POS 연동 설정
권한: authenticated

RPC: catchmenu_store.get_store_admin_dashboard
설명: 매장 관리 대시보드 조회
권한: authenticated

## 15. 가맹점 관리자

RPC: catchmenu_hq.get_franchise_admin_dashboard
설명: 가맹 대시보드 조회
권한: authenticated

RPC: catchmenu_hq.get_brand_store_overview
설명: 브랜드 매장 현황 조회
권한: authenticated

RPC: catchmenu_hq.compare_store_revenue
설명: 매장별 매출 비교
권한: authenticated

RPC: catchmenu_hq.broadcast_brand_cms
설명: 브랜드 CMS 배포
권한: authenticated

RPC: catchmenu_hq.get_franchise_compliance_report
설명: 컴플라이언스 리포트 조회
권한: authenticated

RPC: catchmenu_hq.get_franchise_settlement_report
설명: 정산 리포트 조회
권한: authenticated

RPC: catchmenu_hq.distribute_menu_to_stores
설명: 메뉴 템플릿 배포
권한: authenticated

RPC: catchmenu_hq.run_compliance_check
설명: 정책 준수 검사 실행
권한: authenticated

## 16. HQ 관리자 (service_role 전용)

이 섹션의 RPC 는 service_role 전용이다.
Flutter 앱에서 직접 호출 불가.
Supabase Edge Function 또는 서버 측에서만 호출한다.

RPC: catchmenu_common.get_hq_dashboard
설명: HQ 전체 대시보드
권한: service_role

RPC: catchmenu_common.get_tenant_list
설명: 테넌트 목록 조회
권한: service_role

RPC: catchmenu_common.onboard_tenant
설명: 테넌트 온보딩
권한: service_role

RPC: catchmenu_common.manage_subscription
설명: 구독 관리
권한: service_role

RPC: catchmenu_common.get_saas_revenue_report
설명: SaaS 매출 리포트
권한: service_role

RPC: catchmenu_common.get_system_health_all
설명: 전체 시스템 헬스 조회
권한: service_role

## 17. AI / SOP

RPC: catchmenu_knowledge.search_knowledge
설명: RAG 지식 검색
권한: authenticated

RPC: catchmenu_knowledge.verify_answer_grounding
설명: 답변 근거 검증
권한: authenticated

RPC: catchmenu_knowledge.publish_sop_document
설명: SOP 발행
권한: authenticated

RPC: catchmenu_knowledge.submit_customer_inquiry
설명: 고객 문의 등록
권한: authenticated

RPC: catchmenu_knowledge.get_ai_center_dashboard
설명: AI 고객센터 대시보드 조회
권한: authenticated
  $ko$,
  $en$
# Catch Menu RPC Complete Mapping Table

## Standard Response Structure

Success response fields:
  success: true
  message: i18n message string
  data: response data object
  error_code: null
  error_key: null
  correlation_id: request trace UUID

Error response fields:
  success: false
  message: error message string
  data: null
  error_code: numeric code (e.g. 1001)
  error_key: error key string (e.g. auth_required)
  correlation_id: request trace UUID

All RPCs require correlation_id.
All state changes are recorded as ledger events.
RLS is active on all tables.
No Korean hardcoding in SQL — use i18n keys.

See Korean version for full RPC table.
Section 16 (HQ Admin) RPCs are service_role only.
Flutter apps must not call service_role RPCs directly.
  $en$,
  1, 'PUBLISHED', true, now(), current_date, null
)
;
-- 0113_create_api_spec_docs.sql (PART 2)
-- Purpose: Flutter dev guide registration in knowledge base.
-- Depends on: 0113 PART 1

insert into catchmenu_knowledge.documents (
  tenant_id, store_id,
  document_code, document_title,
  document_type, domain,
  content_ko, content_en,
  version_number, document_status,
  is_tenant_approved,
  approved_at, effective_from, created_by
) values

-- -----------------------------------------------
-- 2. Flutter 개발 가이드
-- -----------------------------------------------
(
  '00000000-0000-0000-0000-000000000001',
  null,
  'API_SPEC_FLUTTER_GUIDE_001',
  'Flutter 개발 가이드 — Catch Menu',
  'GUIDE', 'FLUTTER',
  $ko$
# Flutter 개발 가이드 — Catch Menu

## 1. 프로젝트 구조

lib/
  core/
    supabase/
      supabase_client.dart        -- Supabase 클라이언트 싱글톤
      rpc_caller.dart             -- RPC 공통 호출 래퍼
      correlation.dart            -- correlation_id 생성 유틸
      realtime_manager.dart       -- Realtime 구독 관리자
    error/
      app_error.dart              -- AppError 모델
      error_handler.dart          -- 전역 에러 핸들러
    offline/
      offline_queue.dart          -- 오프라인 큐 관리자
      sync_manager.dart           -- 동기화 매니저
    i18n/
      app_localizations.dart      -- 다국어 처리
  features/
    auth/                         -- 인증 기능
    kds/                          -- KDS 기능
    order/                        -- 주문 기능
    payment/                      -- 결제 기능
    waiting/                      -- 대기 기능
    menu/                         -- 메뉴 기능
    membership/                   -- 멤버십 기능
    cms/                          -- CMS 기능
    store_admin/                  -- 매장 관리
    franchise_admin/              -- 가맹점 관리
  shared/
    models/                       -- 공통 모델
    widgets/                      -- 공통 위젯
    constants/                    -- 상수

## 2. Supabase 클라이언트 초기화

초기화 위치: main.dart 진입점
초기화 순서:
  1. WidgetsFlutterBinding.ensureInitialized() 호출
  2. Supabase.initialize() 호출
    - url: 환경변수 SUPABASE_URL
    - anonKey: 환경변수 SUPABASE_ANON_KEY
  3. 오프라인 큐 초기화
  4. Realtime 매니저 초기화

클라이언트 접근:
  Supabase.instance.client 로 전역 접근
  싱글톤 패턴 사용 — 재생성 금지

환경 분리:
  dev / staging / prod 각각 별도 Supabase 프로젝트
  환경변수 파일로 분리 (.env.dev / .env.staging / .env.prod)
  flutter_dotenv 패키지 사용 권장

## 3. correlation_id 생성 및 전달

원칙:
  모든 RPC 호출에 correlation_id 를 포함한다.
  correlation_id 는 호출 측에서 생성한다.
  UUID v4 형식 사용.
  하나의 사용자 액션에 하나의 correlation_id 를 부여한다.
  연속 RPC 호출(예: 결제 후 KDS 해제)은 동일 correlation_id 를 전달한다.

생성 방법:
  uuid 패키지 사용
  생성: final correlationId = const Uuid().v4();

전달 방법 (RPC 파라미터에 포함):
  파라미터 맵에 p_correlation_id 키로 전달
  예시 파라미터 구조:
    p_correlation_id: correlationId
    p_tenant_id: tenantId
    p_store_id: storeId
    ... (기타 파라미터)

## 4. RPC 공통 호출 패턴

모든 RPC 는 rpc_caller.dart 의 공통 래퍼를 통해 호출한다.
직접 supabase.rpc() 호출은 금지한다.

래퍼 역할:
  correlation_id 자동 주입 (미전달 시)
  응답 success 필드 검사
  error_code / error_key 파싱
  AppError 변환
  ledger event 기록 (클라이언트 측 로그)
  오프라인 여부 감지 및 큐 전환

RPC 호출 흐름:
  1. correlation_id 생성 또는 수신
  2. 파라미터 맵 구성 (p_correlation_id 포함)
  3. rpc_caller.call() 호출
  4. 응답 success 확인
  5. success: false 시 AppError 생성 및 throw
  6. success: true 시 data 파싱 및 반환

응답 파싱 원칙:
  data 필드는 항상 null 체크 후 파싱
  응답 모델은 fromJson() 팩토리 메서드로 파싱
  알 수 없는 필드는 무시 (unknownEnumValue 패턴 적용)

## 5. 에러 처리 패턴

AppError 모델 필드:
  errorCode: int (서버 numeric code)
  errorKey: String (서버 error_key)
  message: String (i18n 처리된 메시지)
  correlationId: String (추적용)

에러 처리 계층:
  RPC 레이어: AppError throw
  Repository 레이어: AppError 재throw 또는 변환
  ViewModel / Provider 레이어: 상태에 에러 반영
  UI 레이어: 에러 상태 표시 (SnackBar / Dialog)

i18n 에러 메시지 처리:
  error_key 를 i18n 카탈로그에서 조회
  미존재 시 서버 message 필드 fallback 사용
  UI 에 error_code 직접 노출 금지

에러 코드 분류:
  1000번대: 인증 / 권한 오류
  2000번대: 입력 / 유효성 오류
  3000번대: 비즈니스 로직 오류
  4000번대: 결제 오류
  5000번대: 외부 연동 오류
  9000번대: 시스템 오류

## 6. KDS Late Binding 호출 순서 (특허2)

원칙:
  결제 완료 전 KDS 티켓은 HOLD 상태로 유지된다.
  HOLD 상태에서는 주방 실행 불가.
  결제 완료 후 반드시 release_kds_after_payment 를 호출한다.
  동일 correlation_id 를 결제와 KDS 해제에 모두 전달한다.

Flutter 호출 순서:
  단계 1: 결제 시작
    catchmenu_integrations.initiate_toss_payment 호출
    correlation_id 생성 및 보관

  단계 2: 결제 확인
    catchmenu_payment.confirm_payment 호출
    동일 correlation_id 전달
    응답 success 확인

  단계 3: KDS Late Binding 해제
    catchmenu_payment.release_kds_after_payment 호출
    동일 correlation_id 전달
    이 호출 실패 시 재시도 큐에 등록

  단계 4: UI 갱신
    결제 완료 화면 표시
    KDS 실시간 상태 갱신 (Realtime 구독)

단계 3 실패 처리:
  네트워크 오류 시 오프라인 큐에 등록
  앱 재기동 시 flush_offline_queue 로 재시도
  재시도 한도 초과 시 직원 알림 발송

## 7. Realtime 구독 패턴

Supabase Realtime 구독 채널 목록:
  store:{store_id}:orders       -- 주문 변경
  store:{store_id}:kds          -- KDS 상태 변경
  store:{store_id}:waiting      -- 대기 상태 변경
  store:{store_id}:alerts       -- 직원 알림
  store:{store_id}:cms          -- CMS 변경

구독 초기화 시점:
  직원 앱: bootstrap_staff_app 응답 후
  고객 앱: bootstrap_customer_app 응답 후

구독 해제 시점:
  앱 백그라운드 전환 시 — 필요에 따라 유지 또는 해제
  로그아웃 시 — 반드시 전체 해제
  매장 마감(close_store) 후 — 해제

Realtime 수신 처리:
  이벤트 타입 확인 (INSERT / UPDATE / DELETE)
  로컬 상태 업데이트 (Provider / Riverpod 상태 갱신)
  UI 자동 갱신 (watch 패턴)

중복 이벤트 처리:
  이벤트 id 기반 중복 제거
  처리된 이벤트 id 를 로컬 Set 에 보관
  일정 시간 후 Set 정리

## 8. 오프라인 큐 처리 패턴

오프라인 감지:
  connectivity_plus 패키지 사용
  네트워크 변경 이벤트 구독
  RPC 호출 실패(네트워크 오류) 시에도 오프라인 판정

큐 등록 대상 액션:
  주문 전송
  결제 확인
  KDS Late Binding 해제
  포인트 / 스탬프 적립
  직원 로그아웃

큐 등록 금지 액션:
  결제 시작 (중복 결제 위험)
  환불 요청 (직원 확인 필요)
  매장 오픈 / 마감

큐 등록 방법:
  catchmenu_common.enqueue_offline_action RPC 호출
  파라미터: action_type, payload, correlation_id, priority

큐 동기화 방법:
  네트워크 복구 감지 시 catchmenu_common.flush_offline_queue 호출
  앱 포그라운드 복귀 시 자동 동기화
  동기화 결과 직원 알림 표시

## 9. 직원 앱 부트스트랩 흐름

앱 기동 시 호출 순서:
  단계 1: catchmenu_common.verify_device_trust
    디바이스 신뢰 검증
    실패 시 디바이스 등록 화면으로 이동

  단계 2: catchmenu_common.staff_login
    PIN 입력 후 호출
    응답에서 staff_role 확인

  단계 3: catchmenu_common.bootstrap_staff_app
    매장 전체 초기 데이터 로드
    메뉴 카탈로그 / KDS 상태 / 대기 상태 / 설정 포함
    로컬 캐시에 저장

  단계 4: Realtime 구독 시작
    get_realtime_config 로 채널 목록 확인 후 구독

  단계 5: 오프라인 큐 동기화
    flush_offline_queue 호출
    미처리 큐 항목 처리

## 10. 고객 앱 부트스트랩 흐름

QR / NFC / 링크 진입 시 호출 순서:
  단계 1: catchmenu_store.bootstrap_customer_app
    테이블 / 대기 / 메뉴 초기 데이터 로드
    store_id 와 table_code 파라미터 전달

  단계 2: catchmenu_common.customer_phone_verify_send
    전화번호 인증 코드 발송 (로그인 필요 시)

  단계 3: catchmenu_common.customer_login
    인증 코드 확인 후 로그인

  단계 4: Realtime 구독 시작
    테이블 채널 구독

## 11. 메뉴 카탈로그 i18n 처리

메뉴 조회:
  catchmenu_pos.get_menu_catalog_i18n 호출
  파라미터: p_locale (ko / en / zh / ja / vi / th)

응답 구조:
  categories: 카테고리 목록
    name: 해당 locale 메뉴명
    description: 해당 locale 설명
  items: 메뉴 항목 목록
    name: 해당 locale 메뉴명
    allergens: 알레르기 코드 목록 (법정 22종)
    options: 옵션 목록

알레르기 표시 원칙:
  법정 22종 알레르기 코드를 i18n 카탈로그로 변환하여 표시
  SQL 내 한글 알레르기명 하드코딩 금지
  코드 예: ALLERGEN_EGG / ALLERGEN_MILK / ALLERGEN_WHEAT 등

## 12. 결제 흐름 Flutter 구현 원칙

토스페이먼츠 연동:
  toss_payments_sdk 또는 WebView 방식 선택
  결제 위젯 초기화: initiate_toss_payment 응답의 clientKey 사용
  결제 완료 콜백에서 confirm_payment 호출

VAN 결제 (카드단말기):
  POS 연동 시 VAN 결제 흐름 별도 처리
  catchmenu_integrations.confirm_okpos_payment 또는
  catchmenu_integrations.confirm_toss_pos_payment 호출

결제 UI 원칙:
  결제 진행 중 UI 잠금 (중복 탭 방지)
  결제 완료 전까지 뒤로가기 차단
  결제 실패 시 재시도 버튼 표시
  네트워크 오류와 결제 거절을 구분하여 안내

## 13. 다국어 지원 원칙

지원 언어: 한국어 / 영어 / 중국어 / 일본어 / 베트남어 / 태국어
기본 언어: 한국어

i18n 파일 위치:
  assets/i18n/ko.json
  assets/i18n/en.json
  assets/i18n/zh.json
  assets/i18n/ja.json
  assets/i18n/vi.json
  assets/i18n/th.json

에러 메시지 i18n:
  error_key 를 i18n 파일에서 조회
  미존재 시 서버 message fallback

메뉴 i18n:
  서버 응답에서 locale 별 번역 수신
  클라이언트 측 번역 테이블 미사용

## 14. RLS 및 테넌트 격리 원칙

Flutter 앱 책임:
  로그인 후 발급된 JWT 를 모든 요청에 포함
  Supabase 클라이언트가 자동으로 Authorization 헤더 처리
  tenant_id / store_id 를 RPC 파라미터로 명시적 전달

금지 사항:
  다른 테넌트 tenant_id 를 파라미터로 전달 시도 금지
  service_role 키를 Flutter 앱 번들에 포함 금지
  anon 키를 이용한 RLS 우회 시도 금지

## 15. 개발 체크리스트

신규 RPC 연동 시 확인 항목:
  [ ] correlation_id 전달 여부
  [ ] 응답 success 필드 확인 로직
  [ ] error_code / error_key 처리 로직
  [ ] 오프라인 큐 등록 필요 여부 판단
  [ ] Realtime 이벤트 연동 여부 확인
  [ ] i18n 에러 메시지 등록 여부
  [ ] 알레르기 코드 표시 여부 (메뉴 관련 시)
  [ ] KDS Late Binding 흐름 적용 여부 (결제 관련 시)
  [ ] RLS 테넌트 격리 파라미터 포함 여부

배포 전 확인 항목:
  [ ] service_role 키 앱 번들 미포함
  [ ] 환경변수 파일 git 제외 (.gitignore)
  [ ] prod 환경 Supabase URL / Key 분리
  [ ] 오프라인 큐 동기화 테스트
  [ ] Realtime 구독 해제 테스트 (로그아웃 시)
  [ ] KDS HOLD → COMMITTED 흐름 E2E 테스트
  [ ] 다국어 6개 언어 메뉴 표시 테스트
  $ko$,
  $en$
# Flutter Developer Guide — Catch Menu

## Project Structure
See Korean version for full directory layout.

## Core Principles

All RPC calls must include correlation_id.
Use rpc_caller.dart wrapper — do not call supabase.rpc() directly.
All state changes are recorded as ledger events.
RLS is active on all tables — always pass tenant_id and store_id.
Never include service_role key in Flutter app bundle.

## KDS Late Binding (Patent 2)
KDS ticket status is HOLD before payment.
Call release_kds_after_payment after payment confirmation.
Use the same correlation_id for both payment and KDS release calls.

## Offline Queue
Enqueue: catchmenu_common.enqueue_offline_action
Flush: catchmenu_common.flush_offline_queue
Do not enqueue payment initiation (duplicate payment risk).

## i18n
Supported: ko / en / zh / ja / vi / th
Error messages use error_key lookup in i18n catalog.
No Korean hardcoding in SQL.

See Korean version for full guide.
  $en$,
  1, 'PUBLISHED', true, now(), current_date, null
),

-- -----------------------------------------------
-- 3. RPC 입출력 매핑표 — 핵심 RPC 상세
-- -----------------------------------------------
(
  '00000000-0000-0000-0000-000000000001',
  null,
  'API_SPEC_RPC_IO_MAP_001',
  'Catch Menu RPC 입출력 매핑표 — 핵심 RPC 상세',
  'SPEC', 'ARCHITECTURE',
  $ko$
# Catch Menu RPC 입출력 매핑표 — 핵심 RPC 상세

## 0. 표기 규칙

입력 파라미터명은 p_ 접두사를 사용한다.
출력 필드명은 응답 data 객체 내 필드명이다.
필수 여부: 필수 / 선택
타입: uuid / text / int / bool / jsonb / timestamptz

## 1. catchmenu_common.register_device

입력:
  p_correlation_id    uuid      필수
  p_tenant_id         uuid      필수
  p_store_id          uuid      필수
  p_device_type       text      필수   -- POS / KDS / STAFF / CUSTOMER_KIOSK
  p_device_name       text      필수
  p_os_type           text      필수   -- android / ios / web
  p_os_version        text      선택
  p_app_version       text      필수
  p_push_token        text      선택

출력 (data):
  device_id           uuid
  trust_level         text      -- TRUSTED / PENDING / BLOCKED
  registered_at       timestamptz

ledger event: DEVICE_REGISTERED

## 2. catchmenu_common.staff_login

입력:
  p_correlation_id    uuid      필수
  p_tenant_id         uuid      필수
  p_store_id          uuid      필수
  p_device_id         uuid      필수
  p_staff_pin         text      필수   -- 암호화 전달

출력 (data):
  staff_id            uuid
  staff_name          text
  staff_role          text      -- OWNER / MANAGER / STAFF / PART_TIME
  session_token       text
  expires_at          timestamptz

ledger event: STAFF_LOGIN

## 3. catchmenu_common.bootstrap_staff_app

입력:
  p_correlation_id    uuid      필수
  p_tenant_id         uuid      필수
  p_store_id          uuid      필수
  p_staff_id          uuid      필수
  p_locale            text      필수   -- ko / en / zh / ja / vi / th

출력 (data):
  store_info          jsonb     -- 매장 기본 정보
  menu_catalog        jsonb     -- 메뉴 카탈로그 (locale 적용)
  kds_state           jsonb     -- KDS 현재 상태
  waiting_state       jsonb     -- 대기 현재 상태
  realtime_channels   jsonb     -- 구독할 채널 목록
  offline_queue_count int       -- 미처리 오프라인 큐 수

ledger event: STAFF_APP_BOOTSTRAPPED

## 4. catchmenu_payment.confirm_payment

입력:
  p_correlation_id    uuid      필수
  p_tenant_id         uuid      필수
  p_store_id          uuid      필수
  p_order_id          uuid      필수
  p_payment_method    text      필수   -- CARD / CASH / TOSS / VAN_NICE / VAN_KIS
  p_amount            int       필수   -- 원 단위
  p_pg_transaction_id text      선택   -- PG 거래 ID (토스 등)
  p_staff_id          uuid      선택   -- 직원 결제 시

출력 (data):
  payment_id          uuid
  payment_status      text      -- CONFIRMED / FAILED
  receipt_number      text
  confirmed_at        timestamptz
  kds_release_required bool     -- true 시 release_kds_after_payment 호출 필요

ledger event: PAYMENT_CONFIRMED

## 5. catchmenu_payment.release_kds_after_payment

입력:
  p_correlation_id    uuid      필수   -- confirm_payment 와 동일 값
  p_tenant_id         uuid      필수
  p_store_id          uuid      필수
  p_order_id          uuid      필수
  p_payment_id        uuid      필수

출력 (data):
  released_ticket_ids uuid[]    -- COMMITTED 로 전환된 KDS 티켓 ID 목록
  released_at         timestamptz

ledger event: KDS_LATE_BINDING_RELEASED

## 6. catchmenu_kds.transition_kds_ticket

입력:
  p_correlation_id    uuid      필수
  p_tenant_id         uuid      필수
  p_store_id          uuid      필수
  p_ticket_id         uuid      필수
  p_from_status       text      필수   -- HOLD / COMMITTED / IN_PROGRESS / DONE
  p_to_status         text      필수
  p_staff_id          uuid      필수
  p_reason            text      선택

출력 (data):
  ticket_id           uuid
  new_status          text
  transitioned_at     timestamptz

상태 전환 허용표:
  HOLD        → COMMITTED    (release_kds_after_payment 호출 시 자동)
  COMMITTED   → IN_PROGRESS  (주방 직원 수동)
  IN_PROGRESS → DONE         (주방 직원 수동)
  IN_PROGRESS → CANCELLED    (취소 시)
  COMMITTED   → CANCELLED    (취소 시)

HOLD 상태에서 IN_PROGRESS 직접 전환 금지.

ledger event: KDS_TICKET_TRANSITIONED

## 7. catchmenu_pos.place_takeout_order

입력:
  p_correlation_id    uuid      필수
  p_tenant_id         uuid      필수
  p_store_id          uuid      필수
  p_staff_id          uuid      필수
  p_items             jsonb     필수   -- 주문 항목 배열
  p_order_type        text      필수   -- TAKEOUT / DINE_IN / DELIVERY
  p_table_id          uuid      선택   -- DINE_IN 시 필수
  p_customer_memo     text      선택
  p_locale            text      선택

p_items 구조 (배열 항목):
  menu_item_id        uuid      필수
  quantity            int       필수
  options             jsonb     선택   -- 선택 옵션 배열
  item_memo           text      선택

출력 (data):
  order_id            uuid
  kds_ticket_ids      uuid[]    -- 생성된 KDS 티켓 목록 (HOLD 상태)
  total_amount        int
  order_number        text      -- 표시용 주문번호
  created_at          timestamptz

ledger event: ORDER_PLACED / KDS_TICKET_CREATED (HOLD)

## 8. catchmenu_store.call_customer_pickup

입력:
  p_correlation_id    uuid      필수
  p_tenant_id         uuid      필수
  p_store_id          uuid      필수
  p_waiting_id        uuid      필수
  p_staff_id          uuid      필수
  p_call_method       text      선택   -- PUSH / SMS / DISPLAY

출력 (data):
  waiting_id          uuid
  call_status         text      -- CALLED / FAILED
  called_at           timestamptz

ledger event: CUSTOMER_CALLED

## 9. catchmenu_knowledge.search_knowledge

입력:
  p_correlation_id    uuid      필수
  p_tenant_id         uuid      필수
  p_store_id          uuid      선택
  p_query             text      필수
  p_locale            text      필수
  p_top_k             int       선택   -- 기본값 5
  p_domain_filter     text[]    선택   -- 도메인 필터

출력 (data):
  results             jsonb[]
    document_code     text
    document_title    text
    chunk_text        text
    similarity_score  float
    citation_ref      text

pgvector 검색 원칙:
  검색 결과는 retrieval 전용 — 생성 권한 없음
  반드시 published / approved 문서만 검색
  tenant_id / store_id RLS 필터 적용
  hallucination 방지를 위해 verify_answer_grounding 병행 호출 권장

ledger event: KNOWLEDGE_SEARCHED

## 10. catchmenu_common.enqueue_offline_action

입력:
  p_correlation_id    uuid      필수
  p_tenant_id         uuid      필수
  p_store_id          uuid      필수
  p_action_type       text      필수   -- ORDER_PLACE / PAYMENT_CONFIRM / KDS_RELEASE 등
  p_payload           jsonb     필수   -- 원본 RPC 파라미터 전체
  p_priority          int       선택   -- 높을수록 먼저 처리 (기본 0)
  p_retry_limit       int       선택   -- 재시도 한도 (기본 3)

출력 (data):
  queue_id            uuid
  queued_at           timestamptz

ledger event: OFFLINE_ACTION_QUEUED
  $ko$,
  $en$
# Catch Menu RPC Input/Output Mapping Table — Core RPCs

See Korean version for full parameter details.

## Key Points

All RPCs require p_correlation_id (UUID v4).
All RPCs require p_tenant_id and p_store_id for RLS isolation.
All state changes emit ledger events.

KDS ticket is created in HOLD status on order placement.
HOLD to COMMITTED transition happens only via release_kds_after_payment.
Direct HOLD to IN_PROGRESS transition is forbidden.

pgvector search is retrieval only — no generative authority.
Only published and approved documents are searchable.
  $en$,
  1, 'PUBLISHED', true, now(), current_date, null
)
;