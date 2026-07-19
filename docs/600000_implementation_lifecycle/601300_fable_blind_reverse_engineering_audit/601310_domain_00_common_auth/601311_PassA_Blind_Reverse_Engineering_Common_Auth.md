# Pass A: Blind Reverse-Engineering — 공통/기반(직원인증)

**Date:** 2026-07-18
**Reviewer:** Claude Fable 5 (blind pass — no design docs shown)
**Input provided:** 01_foundation_input_package.md (149개 RPC 정의 포함, 19개 migration 원본 기반), 01_foundation_migrations_concat.sql

## 1. Reconstructed Domain Purpose

이 도메인은 멀티테넌트 SaaS 형태의 매장 운영 플랫폼의 **인증·권한·감사 기반층(foundation)**으로 보인다. 스키마 분할(`catchmenu_common`, `catchmenu_hq`, `catchmenu_store`, `catchmenu_ledger`, `catchmenu_audit`, `catchmenu_meta` 및 참조되는 `catchmenu_pos`/`catchmenu_payment`/`catchmenu_kds` 등)로 미루어, "본사(HQ) → 테넌트 → 매장(store) → 디바이스/직원" 계층을 가진 프랜차이즈성 구조다.

재구성한 핵심 책임은 다음과 같다:

- **테넌트/매장 격리(isolation).** 거의 모든 운영 테이블에 `enable row level security` + `force row level security`가 걸려 있고(`0021_enable_rls.sql`), 정책은 JWT 클레임에서 뽑아낸 `tenant_id`/`store_id`로 행을 필터링한다(`0022_create_rls_policies.sql`). 기본 태세는 "deny-by-default, 명시적 정책 또는 SECURITY DEFINER RPC로만 접근"이다(0021 주석에 명시).
- **JWT 기반 신원 컨텍스트.** `catchmenu_common.current_tenant_id()`, `current_store_id()`, `current_actor_id()`, `current_actor_type()`, `is_service_role()`, `is_manager_or_above()` 6개 헬퍼가 `current_setting('request.jwt.claims', true)`를 읽어 신원을 파생한다. 이들이 RLS 정책의 술어(predicate) 근간이다.
- **커스텀 세션 로그인 파이프라인.** `staff_login()`, `staff_logout()`, `refresh_auth_session()`, `get_auth_context()`, `customer_login()`, `customer_phone_verify_send()`가 `catchmenu_common.auth_sessions` 테이블을 중심으로 자체 세션/토큰 시스템을 구현한다. 토큰은 `gen_random_bytes(32)`로 생성해 raw는 클라이언트에 반환하고 DB에는 SHA-256 해시만 저장한다.
- **디바이스 신뢰.** `device_registry`(trust_level: UNTRUSTED/PENDING/TRUSTED/SUSPENDED/REVOKED)와 `verify_device_trust()`, `register_device()`로 디바이스 등록/지문(fingerprint) 검증을 수행한다. 로그인은 디바이스 신뢰 검증을 선행 조건으로 건다.
- **직원 권한 모델.** `staff` 테이블(역할 + 개별 boolean 권한 + `allowed_features` jsonb)과 `staff_permission_matrix`(역할×기능 매트릭스), `check_staff_permission()`/`grant_temp_permission()`으로 세분화된 권한 판정을 제공한다.
- **단일 감사 게이트웨이.** `catchmenu_audit.append_audit_record()`가 "모든 고위험 액션의 감사 원장 단일 진입점"으로 설계돼 있고(0023 주석), 클라이언트의 `audit_records` 직접 INSERT는 금지(RLS insert-only + DEFINER 경유)한다.
- **보안 토큰 / 위협 탐지.** `issue_security_token()`/`verify_security_token()`(1회성 해시 토큰), `detect_threat()`, `gateway_audit_entry()`, `run_security_scan()` 등 보안 파이프라인이 있다.
- **부가적으로** 프랜차이즈 본사(`catchmenu_hq`: 브랜드/정책/메뉴템플릿 배포/컴플라이언스), 원장/이벤트(`catchmenu_ledger`), SaaS 구독/과금(`subscription_*`, `tenant_quotas`), 운영 대시보드/헬스체크가 같은 기반층에 얹혀 있다.

주석에 반복 등장하는 "특허1~4"(예: `staff` 주석의 "특허4: Human Authority Runtime", audit 주석의 "특허4: 감사 원장 단일 진입점") 문자열로 보아, 권한 분리와 감사 추적을 특허성 설계 포인트로 의도한 것으로 읽힌다.

## 2. Reconstructed State Machines

코드/제약조건에서 직접 관측되는 상태 전이는 다음과 같다.

### 2.1 인증 세션 (`auth_sessions.session_status`)
- 허용 상태(`chk_auth_session_status`): `ACTIVE`, `EXPIRED`, `LOGGED_OUT`, `REVOKED`, `SUSPENDED`.
- 관측된 전이:
  - (없음) → `ACTIVE`: `staff_login()`이 세션 INSERT 시 `ACTIVE`로 생성. `expires_at = now()+8h`, `refresh_expires_at = now()+7d`.
  - `ACTIVE` → `LOGGED_OUT`: (a) `staff_login()`이 동일 subject의 기존 `ACTIVE` STAFF 세션을 `logout_reason='new_login'`으로 종료(단일 세션 강제), (b) `staff_logout()`이 `logout_reason='user_request'`로 종료.
  - `ACTIVE` → `ACTIVE`(토큰 회전): `refresh_auth_session()`이 `session_token_hash`/`refresh_token_hash`를 새 값으로 교체하고 만료시각 갱신. 상태값 자체는 그대로.
  - `EXPIRED`/`REVOKED`/`SUSPENDED`로의 전이는 이 자료에 **작성하는 코드가 보이지 않는다**(상태값은 스키마에 정의돼 있으나 진입 경로 미관측 — cron/배치가 별도 도메인일 가능성).
- `session_type`(`chk_session_type`): STAFF/CUSTOMER/DEVICE/KIOSK/KDS/DID/ADMIN.
- `subject_type`(`chk_subject_type`): STAFF/CUSTOMER/DEVICE/SYSTEM.

### 2.2 보안 토큰 (`security_tokens.token_status`)
- 허용 상태: `ACTIVE`, `USED`, `EXPIRED`, `REVOKED`, `BLOCKED`.
- 전이(`issue_security_token()` / `verify_security_token()`):
  - (없음) → `ACTIVE`: 발급.
  - `ACTIVE` → `EXPIRED`: 검증 시 `expires_at < now()`이면 EXPIRED로 갱신.
  - `ACTIVE` → `USED`: `p_consume=true`이고 `use_count+1 >= max_uses`이면 USED. 또는 `use_count >= max_uses` 초과 검증 시 USED.
  - `USED` 재사용 시도 → `detect_threat(TOKEN_REPLAY, CRITICAL)` 발생(상태 전이는 아니고 위협 이벤트).
- 토큰 타입(`chk_token_type`): PAYMENT_INTENT/KDS_RELEASE/REFUND_APPROVE/WEBHOOK_VERIFY/EXPORT_PERMIT/ADMIN_ACTION/DEVICE_TRUST/SECRET_ACCESS.

### 2.3 로그인 시도 / 브루트포스 (`login_attempts`)
- `attempt_result`(`chk_attempt_result`): SUCCESS/FAILED/BLOCKED/EXPIRED.
- `staff_login()` 로직: 최근 30분 내 `FAILED` 카운트 집계 → PIN 5회 실패 시 `is_blocked=true`, `blocked_until = now()+30분` 기록. `blocked_until`이 미래면 즉시 `BLOCKED` 기록 후 거부.

### 2.4 디바이스 신뢰 (`device_registry.trust_level`)
- 허용값: UNTRUSTED/PENDING/TRUSTED/SUSPENDED/REVOKED. 기본 `UNTRUSTED`.
- `verify_device_trust()`: `TRUSTED` 또는 `REGISTERED` 중 하나여야 통과 — **주의: `REGISTERED`는 `chk_device_trust` 제약의 허용값 목록에 없다**(§4 참조). fingerprint 불일치 시 `security_audit_log`에 CRITICAL 위반 기록 후 거부.
- `device_status`(`chk_device_status`): ONLINE/OFFLINE/DEGRADED/MAINTENANCE/FAILED.

### 2.5 직원 (`staff.staff_status`)
- 허용값(`chk_staff_status`): ACTIVE/ON_LEAVE/SUSPENDED/TERMINATED. 기본 ACTIVE.
- `staff_login()`은 `staff_status = 'ACTIVE'`가 아니면 거부. 상태를 바꾸는 전이 코드는 이 자료엔 `register_staff`/`update_staff_role` 정도만 있고 상태 머신 전체는 미관측.
- 별도로 `is_active` boolean(기본 true)이 존재 — `staff_status`와 이중 플래그(§4).

### 2.6 임시 권한 (`staff_permission_logs.check_result`)
- 관측값: ALLOWED / DENIED / PIN_REQUIRED / MANAGER_REQUIRED / AMOUNT_EXCEEDED / TEMP_ALLOWED.
- `grant_temp_permission()`: 승인자(OWNER/MANAGER)가 대상 직원에게 기능을 임시 부여 → `staff.allowed_features`에 append + `temp_expires_at` 로깅. **만료 시 회수 코드 미관측**(§4).

## 3. Reconstructed Authorization/Boundary Model

### 3.1 실제 실행 권한(proacl 기준)
149개 RPC의 proacl 분포(§D.1):

| 패턴 | 수 | 의미(재구성) |
|---|---:|---|
| `postgres=X,authenticated=X` | 100 | 소유자 + `authenticated` 롤만 실행 (PUBLIC 회수됨) |
| `=X,postgres=X,authenticated=X` | 26 | **선두 `=X`는 PUBLIC** — 즉 `anon` 포함 누구나 실행 가능 |
| `NULL` | 16 | proacl 미설정 = 스키마 기본(대개 소유자+PUBLIC). 내부 헬퍼/트리거/psql 헬퍼류 |
| `postgres=X,service_role=X` | 6 | 서비스 롤 전용(HQ 대시보드/매출/시스템 헬스/구독관리) |
| `postgres=X,authenticated=X,anon=X` | 1 | `health_check` — anon 명시 허용(헬스 엔드포인트로 타당) |

관측되는 경계 구조:
- **직접 테이블 접근은 `authenticated` 롤 + RLS 정책**을 통해서만. 정책 술어는 대부분 `tenant_id = current_tenant_id() AND store_id = current_store_id()`.
- **매니저 전용 열람**: `audit_records`(SELECT), `reconciliation_cases`, `knowledge.document_versions` 등은 추가로 `is_manager_or_above()`를 요구.
- **service_role 전용**: `catchmenu_gateway.*`, `catchmenu_integrations.toss_webhooks`, `payment_ledger`의 쓰기 경로는 `is_service_role()`만. 또한 `catchmenu_gateway`/`catchmenu_audit` 스키마는 `authenticated`에게 `usage` 권한을 명시적으로 `revoke`.
- **고위험 쓰기는 SECURITY DEFINER RPC로 우회**: 클라이언트가 `audit_records`/`payment_ledger` 등에 직접 INSERT 불가하고, `append_audit_record()` 같은 DEFINER 함수만 삽입 가능.

### 3.2 신원 파생 경계 (JWT 축)
- RLS와 `is_manager_or_above()`/`is_service_role()`는 전적으로 **`request.jwt.claims`**에 의존한다.
  - `current_tenant_id/store_id/actor_type`: `claims -> 'app_metadata' ->> ...`
  - `current_actor_id`: `claims ->> 'sub'` (최상위 sub 클레임)
  - `is_service_role`: `claims ->> 'role' = 'service_role'`
  - `is_manager_or_above`: `claims -> 'app_metadata' ->> 'actor_type' IN (MANAGER, OWNER, HQ_ADMIN)`
- 즉 신원의 근거는 "요청에 실린 JWT가 이미 올바른 app_metadata를 담고 있다"는 전제다. 0022 주석도 "JWT must include app_metadata.tenant_id **set by auth hook**"이라 적는다 — 그 **auth hook 코드는 이 19개 파일 어디에도 없다**(§4/§5).

### 3.3 세션 파생 경계 (토큰 축) — JWT 축과 분리
- `staff_login()`/`customer_login()`은 JWT를 만들거나 클레임을 설정하지 **않는다**. 대신 `auth_sessions`에 행을 넣고 raw `session_token`/`refresh_token`을 반환한다.
- `get_auth_context()`는 신원을 JWT가 아니라 **파라미터로 받은 `p_session_token_hash`**로 조회한다.
- 결론적으로 이 도메인에는 **두 개의 서로 독립적인 신원 축**이 존재한다: (A) RLS가 쓰는 JWT 클레임 축, (B) 로그인 RPC가 쓰는 세션토큰 축. 제공된 자료 범위 안에서 두 축을 연결하는 코드는 관측되지 않는다(§4-1, §5).

### 3.4 애플리케이션 권한 판정 vs. 강제(enforcement)
- `check_staff_permission(p_staff_id, p_feature_code, ...)`는 **판정 결과 JSON을 반환**할 뿐, 스스로 어떤 작업을 막지 않는다. 호출자가 결과를 존중해야 실효가 있다(advisory).
- `p_staff_id`/`p_approver_id`를 파라미터로 받아 `staff` 테이블에서 조회하지만, **호출자가 실제로 그 직원인지**는 검증하지 않는다(§4-3).

## 4. Anomalies / Suspicious Patterns

**4-1. 인증 두 세계의 단절 (가장 두드러짐).**
RLS/권한 헬퍼는 JWT `sub`/`app_metadata`에 의존하는데(`current_actor_id` = `claims->>'sub'`), 실제 로그인 파이프라인(`staff_login`/`auth_sessions`/`get_auth_context`)은 JWT를 전혀 건드리지 않고 자체 토큰 해시로 동작한다. `staff.id`가 JWT `sub`로 흘러 들어가게 만드는 코드가 이 자료엔 없다. 0022 주석이 언급한 "auth hook"이 그 다리로 추정되나 **19개 파일에 부재**. 이대로면 `staff_login` 성공이 곧 RLS가 인식하는 신원으로 이어지지 않는다. (라이브 증거: `auth_sessions` row_count=0 — 실제로 이 경로가 돌아간 흔적 없음.)

**4-2. `staff_status`와 `is_active` 이중 플래그.**
`staff` 테이블에 상태 enum(`staff_status`)과 별도 boolean(`is_active`)이 공존한다. 둘의 정합성을 강제하는 제약/트리거가 없어 "status=TERMINATED인데 is_active=true" 같은 모순 상태가 가능하다. 인덱스 `idx_staff_status`는 `where is_active=true`를, `staff_login`은 `staff_status='ACTIVE'`를 본다 — 서로 다른 플래그를 기준 삼는다.

**4-3. 자기신고(self-asserted) actor/staff 식별.**
- `append_audit_record(p_actor_type, p_actor_id, ...)`는 필수필드 존재만 검사하고, `p_actor_id`가 실제 호출자와 일치하는지 확인하지 않는다. "감사 원장 단일 진입점"이라면서 액터 귀속이 자기신고다.
- `check_staff_permission`/`grant_temp_permission`도 `p_staff_id`/`p_approver_id`를 호출자 검증 없이 신뢰한다. 승인자 역할(OWNER/MANAGER)만 조회로 확인할 뿐, "지금 호출자가 그 승인자냐"는 검증 부재.
- `register_staff`의 `p_actor_type` 기본값이 `'MANAGER'`, `p_actor_id` 기본 `null` — 감사 액터가 기본적으로 위조 가능한 형태.

**4-4. 권한 표현의 삼중화(정합성 위험).**
직원 권한이 (a) `staff`의 개별 boolean 컬럼(`can_override_kds` 등 7종), (b) `staff_permission_matrix`(역할×기능), (c) `staff.allowed_features` jsonb — 세 곳에 분산돼 있다. `check_staff_permission`은 (b)+(c)만 참조하고 (a) boolean들은 무시한다. 세 소스가 어긋날 때 어느 것이 진실인지 코드상 단일 기준이 없다.

**4-5. 임시 권한이 사실상 영구.**
`grant_temp_permission`은 `staff.allowed_features`에 기능을 append하고 `temp_expires_at`을 로그에만 남긴다. 만료 시각이 지나도 `allowed_features`에서 제거하는 회수 코드가 이 자료엔 없다. `check_staff_permission`도 만료를 보지 않고 `allowed_features @> feature`만 확인 → "임시"가 실질 영구가 될 수 있다.

**4-6. `verify_device_trust`가 제약에 없는 값 `REGISTERED`를 허용.**
통과 조건이 `trust_level in ('TRUSTED','REGISTERED')`인데, `chk_device_trust` 제약의 허용 집합은 `UNTRUSTED/PENDING/TRUSTED/SUSPENDED/REVOKED`로 `REGISTERED`가 없다. 즉 `REGISTERED` 분기는 데드코드이거나, 제약과 코드가 서로 다른 시점의 명세를 반영한 흔적.

**4-7. `STABLE`로 선언된 함수가 쓰기를 수행.**
`get_auth_context`(STABLE)가 `auth_sessions.last_active_at`을 UPDATE하고, `verify_device_trust`(STABLE)가 `device_registry.last_seen_at`을 UPDATE한다. STABLE 볼라틸리티는 데이터 변경 없음을 함의하므로 라벨과 실제 동작이 모순. 옵티마이저 가정/재실행 관점에서 잠재 위험.

**4-8. PUBLIC(익명 포함) 실행이 열린 보안 민감 함수 26개.**
`=X`(PUBLIC) proacl을 가진 함수에 `issue_security_token`, `verify_security_token`, `detect_threat`, `gateway_audit_entry`, `run_security_scan`, `get_security_dashboard`, `get_daily_report`, `collect_hourly_metrics` 등이 포함된다. 토큰 발급/검증과 위협탐지가 `anon`에게 열려 있는 것은 의도가 불명확하다(내부 자체 검증 로직이 있으나 진입 자체가 공개). 반면 `append_audit_record` 등 100개는 PUBLIC이 명시적으로 회수돼 있어, 회수 정책이 **일관 적용되지 않았다**.

**4-9. 로그인이 "감사 단일 게이트웨이"를 우회.**
`staff_login`/`staff_logout`은 `catchmenu_ledger.events`에는 기록하지만 `append_audit_record`(catchmenu_audit)를 호출하지 않는다. search_path에도 `catchmenu_audit`가 없다. "모든 고위험 액션은 감사 게이트웨이로"라는 0023 주석과 어긋난다(로그인은 고위험 액션의 전형).

**4-10. `auth_sessions` RLS가 tenant까지만 격리.**
`auth_sessions_isolation` 정책은 `tenant_id = current_tenant_id()`만 검사하고 store/subject를 보지 않는다(다른 운영 테이블은 대부분 store까지 격리). 같은 테넌트 내에서 세션 행 노출 범위가 상대적으로 넓다. (실무 영향은 DEFINER RPC 경유 여부에 달림.)

**4-11. 세션토큰 해시가 곧 베어러 시크릿.**
`get_auth_context`/`refresh_auth_session`이 `p_session_token_hash`를 파라미터로 받는다. DB엔 해시만 저장되므로 "해시를 아는 자 = 세션 소유자". 클라이언트가 해시를 계산해 넘기는 구조라면 해시 자체가 전송되는 비밀이 되어, raw 토큰을 감춘 이점이 약화된다(전송·로깅 경로에서 해시 유출 시 그대로 세션 탈취 가능).

**4-12. 시드 데이터의 비대칭.**
`staff_permission_matrix` 90행이 시드돼 있으나 `staff` 0행, `auth_sessions` 0행, `login_attempts`(샘플상) 0행. 권한 매트릭스는 직원이 하나도 없는 매장에 대해 채워져 있다. 설계상 그럴 수 있으나, 실제 인증 흐름이 한 번도 실행되지 않았음을 시사(이론 설계 vs. 작동 증거 구분 필요).

**4-13. `current_actor_id`만 클레임 최상위(`sub`), 나머지는 `app_metadata`.**
tenant/store/actor_type은 `app_metadata` 하위, actor_id만 최상위 `sub`. 표준 Supabase JWT 관례(`sub`=auth user id)를 따른 것으로 보이나, 나머지 클레임 중첩 위치와 불일치해 hook이 채워야 할 스키마가 두 층으로 갈린다.

## 5. Confidence Notes

- **RLS 정책 조건문**: 추출 도구 오류로 `pg_policy`의 조건 텍스트는 §B에서 누락(PSQL ERROR)이라고 명시돼 있으나, 다행히 정책 본문은 `0022`/`0053`/`0062`/`0065`/`0097`/`0121` 마이그레이션 원문에 그대로 있어 §3의 술어는 **원문 기반으로 재구성**했다(추정 아님). 다만 마이그레이션 이후 라이브 DB에서 정책이 변경/추가됐다면 이 자료로는 알 수 없다 — "RLS 활성화는 확인, 라이브 최신 정책 내용은 부분적으로만 확인".
- **4-1(두 세계 단절)**: "auth hook이 없다"는 것은 **제공된 19개 파일 범위 내 부재**를 뜻한다. 이 감사 패키지에 포함되지 않은 다른 마이그레이션/엣지함수/Supabase 설정(`config.toml`의 custom_access_token hook 등)에 다리가 존재할 가능성은 이 자료만으로 배제할 수 없다. 단정이 아니라 "이 입력 범위에서 연결 코드 미관측"으로 읽어야 한다.
- **상태 머신 완전성**: `EXPIRED`/`REVOKED`/`SUSPENDED` 진입 경로, `staff_status` 전이 대부분은 이 도메인 밖(cron/배치/다른 워크패킷)에 있을 것으로 추정. §2는 관측된 전이만 기술.
- **4-8 PUBLIC 노출의 위험도**: 각 함수가 SECURITY DEFINER + 내부 입력검증을 갖고 있어 실제 악용 가능성은 함수별 로직에 좌우된다. proacl 사실만으로 "취약"이라 단정하지 않고 "진입 경계가 공개됨 + 회수 정책 불일치"라는 사실만 확정.
- **4-11 토큰 해시 전달**: 클라이언트가 raw 토큰을 넘기고 DB가 재해시하는지, 아니면 클라이언트가 해시를 넘기는지는 파라미터명(`p_session_token_hash`)으로 후자로 추정했으나, 호출 측 코드(Flutter/게이트웨이)가 이 패키지에 없어 확정 불가.
- **민감 컬럼 값**(pin_hash 등)은 §C에서 redacted라 값 자체는 못 봤고, 컬럼 존재/사용 방식만으로 판단했다. PIN 비교가 `v_staff.pin_hash <> p_pin_hash` 단순 문자열 비교인 점은 원문에서 확인되나, 해시 알고리즘/솔팅 여부는 호출 측 책임이라 이 자료로는 알 수 없다.
