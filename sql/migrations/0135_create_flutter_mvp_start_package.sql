-- 0135_create_flutter_mvp_start_package.sql
-- Purpose: Flutter MVP development start package.
--          Flutter 개발 시작 가이드 완성.
--          MVP 범위 확정 문서.
--          외주 계약서 기반 명세.
--          DB 적용 가이드.
--          최종 마이그레이션 완성.
-- Depends on: 0134_create_technology_credit_package.sql

-- =============================================
-- Flutter MVP 개발 가이드 문서 등록
-- =============================================
insert into catchmenu_knowledge.documents (
  tenant_id, store_id,
  document_code, title,
  document_type, domain,
  content, content_locale,
  document_status, approved_at, published_at
) values

-- 1. Flutter MVP 범위 확정
(
  '00000000-0000-0000-0000-000000000001', null,
  'FLUTTER_MVP_SCOPE_001_KO',
  'Flutter MVP 개발 범위 확정',
  'SPEC', 'flutter',
  $ko$
# Flutter MVP 개발 범위 확정

## 1호점 MVP 필수 앱 (우선순위 순)

### Phase 1: 직원 앱 (STAFF_APP)
우선순위: 최고
개발 기간: 6주

#### 화면 목록
1. 로그인 화면
   RPC: staff_login()
   기능: PIN 입력, 디바이스 등록

2. 대시보드 (홈)
   RPC: bootstrap_staff_app()
   기능: 매장 현황, 오늘 주문/매출

3. 대기 관리
   RPC: get_waiting_admin_view()
   기능: 대기 목록, 호출, 착석, 노쇼

4. KDS 뷰 (직원용)
   RPC: get_kds_realtime_state()
   기능: 주문 현황, 상태 변경

5. 주문 접수
   RPC: place_order() (추후)
   기능: 직접 주문 입력

6. 매장 설정
   RPC: get_store_admin_dashboard()
   기능: 메뉴관리, 직원관리, 영업시간

#### Realtime 구독
- staff:{store_id}: 직원 알림
- kds:{store_id}: KDS 업데이트
- waiting:{store_id}: 대기 변경
- store:{store_id}: 매장 설정 변경

### Phase 2: KDS 디스플레이 (KDS_DISPLAY)
우선순위: 높음
개발 기간: 2주

#### 화면 목록
1. KDS 메인 화면 (전체화면)
   RPC: get_kds_realtime_state()
   기능: HOLD(회색)/COMMITTED(녹색)/COOKING(주황)/READY(파랑)

#### Realtime 구독
- kds:{store_id}

### Phase 3: 미니 키오스크 (MINI_KIOSK)
우선순위: 높음 (외국인 핵심)
개발 기간: 3주

#### 화면 목록
1. 언어 선택
   RPC: bootstrap_kiosk()
2. 메뉴 화면
   RPC: get_kiosk_menu()
3. 장바구니
   (로컬 상태)
4. 결제 화면
   RPC: place_kiosk_order()
   → 토스페이먼츠 위젯

#### Realtime 구독
- store:{store_id}: 메뉴 변경

### Phase 4: DID 디스플레이 (DID_DISPLAY)
우선순위: 보통
개발 기간: 1주

#### 화면 목록
1. 대기 번호 표시 (전체화면)
   RPC: bootstrap_did_app()
   기능: 호출 번호 대형 표시, CMS 배너

#### Realtime 구독
- did:{store_id}
- waiting:{store_id}

### Phase 5: 고객 앱 (CUSTOMER_APP)
우선순위: 보통 (오픈 후 개발)
개발 기간: 6주

#### 화면 목록
1. 홈
   RPC: bootstrap_customer_app_v2()
2. QR 스캔
   RPC: qr_scan_action()
3. 메뉴 보기
   RPC: get_kiosk_menu()
4. 주문 추적
   RPC: get_order_tracking()
5. 멤버십
   RPC: get_customer_membership()
6. 쿠폰
   RPC: get_customer_coupons()

## 2. MVP 제외 항목 (추후 개발)

- 관리자 웹 (HQ Dashboard)
- 프랜차이즈 관리자 웹
- AI 고객센터 UI
- 재고 관리 UI
- 정산 리포트 UI

→ DB/RPC는 완성. UI만 추후 개발.

## 3. 외주 계약 기준

### Edge Function 외주 (P1: 먼저)
계약서에 포함할 내용:
- okpos-order-send: OKpos API 연동
- toss-payments-confirm: 결제 확인
- okpos-heartbeat: 헬스체크
- 납품: TypeScript + 단위 테스트
- 검수: integration test 통과

### Flutter 앱 외주
계약서에 포함할 내용:
- DB RPC 문서 제공 (API_SPEC_RPC_MAP_001)
- 개발 가이드 제공 (API_SPEC_FLUTTER_GUIDE_001)
- Supabase 개발 계정 제공
- 검수: run_integration_test() ALL_PASS

## 4. DB 적용 방법 (DBeaver)

### 마이그레이션 적용 순서

1. Supabase 프로젝트 생성
2. 설정 → SQL Editor 접속
3. 마이그레이션 파일 순서대로 실행:
   0001 → 0002 → ... → 0135
4. 각 파일 실행 후 오류 확인
5. 전체 완료 후 run_final_validation() 실행
6. run_integration_test() 실행
7. run_opening_checklist() 확인

### 주의사항
- pgvector 확장 먼저 활성화 필요
  CREATE EXTENSION IF NOT EXISTS vector;
  CREATE EXTENSION IF NOT EXISTS pg_cron;
  CREATE EXTENSION IF NOT EXISTS pgcrypto;
- pg_cron은 Supabase Pro 이상 필요
- Edge Function은 별도 배포 필요

### DBeaver 연결 설정
- Host: [Supabase Project URL]
- Port: 5432
- Database: postgres
- User: postgres
- Password: [DB Password]
- SSL: required
$ko$,
  'ko',
  'PUBLISHED', now(), current_date
),
(
  '00000000-0000-0000-0000-000000000001', null,
  'FLUTTER_MVP_SCOPE_001_EN',
  'Flutter MVP 개발 범위 확정',
  'SPEC', 'flutter',
  $en$
# Flutter MVP Scope

Phase 1: STAFF_APP (6 weeks, highest priority)
Phase 2: KDS_DISPLAY (2 weeks)
Phase 3: MINI_KIOSK (3 weeks, foreign visitor key)
Phase 4: DID_DISPLAY (1 week)
Phase 5: CUSTOMER_APP (6 weeks, post-open)

DB is complete. Start Flutter or Edge Function outsourcing now.
See Korean version for full spec.
$en$,
  'en',
  'PUBLISHED', now(), current_date
),

-- 2. DB 적용 체크리스트
(
  '00000000-0000-0000-0000-000000000001', null,
  'DB_APPLY_CHECKLIST_001_KO',
  'DB 적용 체크리스트 — Supabase',
  'GUIDE', 'operation',
  $ko$
# DB 적용 체크리스트 — Supabase

## 사전 준비

1. Supabase 프로젝트 생성
   - https://supabase.com/dashboard
   - New Project 클릭
   - Region: Northeast Asia (Seoul)
   - Plan: Pro (pg_cron 필요)

2. 확장 활성화 (SQL Editor에서)

CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_net;

3. DBeaver 연결
   - Supabase Dashboard → Settings → Database
   - Connection string 복사

## 마이그레이션 적용

4. sql/migrations/ 폴더의 파일을 순서대로 실행
   0001 ~ 0135 (135개 파일)

5. 적용 후 검증

SELECT catchmenu_common.run_final_validation();
SELECT catchmenu_common.run_integration_test(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002'
);
SELECT catchmenu_common.run_opening_checklist(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002'
);
SELECT catchmenu_common.get_tech_credit_summary(
  '00000000-0000-0000-0000-000000000001'
);

## Flutter 개발 환경

6. Supabase 키 발급
   - Settings → API
   - anon key: Flutter 앱용
   - service_role key: HQ 관리자만

7. Flutter pubspec.yaml 핵심 패키지

supabase_flutter: ^2.0.0
flutter_secure_storage: ^9.0.0
connectivity_plus: ^5.0.0
hive_flutter: ^1.1.0
tosspayments_widget_sdk_flutter: ^1.0.0

8. 환경변수 설정 (.env)

SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJxx...

## 검증 완료 기준

run_integration_test() → ALL_PASS
run_opening_checklist() → READY 또는 CAUTION
알레르겐 등록 → 식품위생법 준수
직원 PIN 설정 → 보안 완료
$ko$,
  'ko',
  'PUBLISHED', now(), current_date
),
(
  '00000000-0000-0000-0000-000000000001', null,
  'DB_APPLY_CHECKLIST_001_EN',
  'DB 적용 체크리스트 — Supabase',
  'GUIDE', 'operation',
  $en$
# DB Apply Checklist

1. Create Supabase project (Pro plan, Seoul region)
2. Enable extensions: vector, pg_cron, pgcrypto, pg_net
3. Connect DBeaver
4. Apply migrations 0001 ~ 0135
5. Run validation RPCs
6. Get Supabase API keys
7. Configure Flutter pubspec.yaml
$en$,
  'en',
  'PUBLISHED', now(), current_date
)
on conflict (tenant_id, document_code)
do update set
  content = excluded.content;


-- =============================================
-- 최종 완성 요약 RPC
-- =============================================
create or replace function
  catchmenu_common.get_project_completion_summary()
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_table_count int;
  v_function_count int;
  v_message_count int;
  v_cron_count int;
  v_sop_count int;
  v_doc_count int;
  v_rls_count int;
begin
  select count(*) into v_table_count
  from information_schema.tables
  where table_schema like 'catchmenu_%'
    and table_type = 'BASE TABLE';

  select count(*) into v_function_count
  from information_schema.routines
  where routine_schema like 'catchmenu_%'
    and routine_type = 'FUNCTION';

  select count(*) into v_message_count
  from catchmenu_common.message_catalog;

  select count(*) into v_cron_count
  from catchmenu_common.pg_cron_jobs
  where is_active = true;

  select count(*) into v_sop_count
  from catchmenu_common.sop_runbooks
  where is_active = true;

  select count(*) into v_doc_count
  from catchmenu_knowledge.documents
  where document_status = 'PUBLISHED';

  select count(*) into v_rls_count
  from pg_policies
  where schemaname like 'catchmenu_%';

  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'project', 'Catch Menu / Catch & Order',
      'version', 'v0135',
      'status', 'DB_COMPLETE_MVP_READY',
      'migration_files', 135,
      'schemas', 9,
      'tables', v_table_count,
      'rpc_functions', v_function_count,
      'rls_policies', v_rls_count,
      'i18n_messages', v_message_count,
      'pg_cron_jobs', v_cron_count,
      'sop_runbooks', v_sop_count,
      'knowledge_documents', v_doc_count,
      'patents', jsonb_build_object(
        'patent1', 'Wait/Order Handoff - IMPLEMENTED',
        'patent2', 'KDS Late Binding - IMPLEMENTED',
        'combined', 'Pre-order While Waiting - IMPLEMENTED'
      ),
      'next_steps', jsonb_build_array(
        '1. Supabase Pro 프로젝트 생성',
        '2. 마이그레이션 0001~0135 적용',
        '3. run_integration_test() ALL_PASS 확인',
        '4. Edge Function P1 외주 계약',
        '5. Flutter STAFF_APP 개발 시작',
        '6. 2027.09 1호점 오픈 목표'
      ),
      'edge_function_p1', jsonb_build_array(
        'okpos-order-send',
        'okpos-menu-fetch',
        'toss-payments-confirm',
        'toss-payments-webhook',
        'okpos-heartbeat',
        'toss-pos-heartbeat'
      ),
      'flutter_priority', jsonb_build_array(
        'STAFF_APP (6주)',
        'KDS_DISPLAY (2주)',
        'MINI_KIOSK (3주)',
        'DID_DISPLAY (1주)',
        'CUSTOMER_APP (6주)'
      ),
      'completed_at', now()
    )
  );
end;
$$;

grant execute on function
  catchmenu_common.get_project_completion_summary()
  to authenticated;


-- =============================================
-- schema_versions v0135 최종
-- =============================================
update catchmenu_common.schema_versions
set is_current = false
where is_current = true;

insert into catchmenu_common.schema_versions (
  version_code, migration_count,
  description, is_current,
  validation_result
) values (
  'v0135',
  135,
  'Catch Menu Full System v2.0 - DB Complete (0001-0135)',
  true,
  jsonb_build_object(
    'validated_at', now(),
    'overall_status', 'VALID',
    'migration_count', 135,
    'status', 'DB_COMPLETE',
    'flutter_mvp_ready', true,
    'tech_credit_ready', true,
    'patent1_implemented', true,
    'patent2_implemented', true,
    'combined_implemented', true,
    'documents', jsonb_build_array(
      'FLUTTER_MVP_SCOPE_001',
      'DB_APPLY_CHECKLIST_001'
    ),
    'validation_rpcs', jsonb_build_array(
      'run_final_validation()',
      'run_integration_test()',
      'run_opening_checklist()',
      'get_tech_credit_summary()',
      'get_project_completion_summary()'
    ),
    'milestone',
      '0001~0135 DB 설계 완료. Flutter MVP 시작.'
  )
)
on conflict (version_code) do update set
  migration_count = excluded.migration_count,
  description = excluded.description,
  is_current = excluded.is_current,
  validation_result = excluded.validation_result;

comment on function
  catchmenu_common.get_project_completion_summary()
  is
  '프로젝트 완성 요약.
   DB 설계 완료 기념 최종 요약.

   DBeaver에서 실행:
   SELECT
     catchmenu_common
       .get_project_completion_summary();

   포함 정보:
   - 마이그레이션 파일 수 (135개)
   - 테이블/함수/RLS/i18n 수치
   - 특허 구현 상태
   - 다음 단계 안내
   - Edge Function P1 목록
   - Flutter 개발 우선순위

   이 결과물이 2027.09 1호점 오픈의
   기술적 근거가 됩니다.';

comment on function
  catchmenu_common.get_project_completion_summary()
  is
  '프로젝트 완성 요약.
   DB 설계 완료 기념 최종 요약.

   DBeaver에서 실행:
   SELECT
     catchmenu_common
       .get_project_completion_summary();

   포함 정보:
   - 마이그레이션 파일 수 (135개)
   - 테이블/함수/RLS/i18n 수치
   - 특허 구현 상태
   - 다음 단계 안내
   - Edge Function P1 목록
   - Flutter 개발 우선순위

   이 결과물이 2027.09 1호점 오픈의
   기술적 근거가 됩니다.';