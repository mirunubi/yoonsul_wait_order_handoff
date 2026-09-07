# 601919_Audit_Independent_Foundation_Audit.md

Status: Active
Lifecycle: Audit
Last Updated: 2026-09-08

## §0 수행 조건

**`0-A-2` 나선의 3단계 검증자가 아니다.**
**저장소 전체를 대상으로 한 독립 감사다.**

```text
감사일   2026-09-08
Git      05e81f119fd03f25d15366448a145d7b10c2acdd
DB       supabase_db_yoonsul_wait_order_handoff · PostgreSQL 17.6

수행     저장소 수정 · commit 없음
         mutation 검증은 로컬 합성 행 + BEGIN/ROLLBACK
         클라우드 · 운영 데이터 미변경
```

**판정** — `CRITICAL ARCHITECTURAL RISK` · `C. Freeze feature development and repair foundation`

### §0.1 이 감사가 선행 검증과 다른 점

```text
601906 ~ 601918   문서 대 문서 · 문서 대 카탈로그
이 감사            runtime 재현
```

> ⚠️ **`C-01` · `C-02` · `C-03` 이 `VERIFIED` 다.**
> **정적 분석이 아니라 실행으로 재현했다.**
>
> ```text
> A 의 JWT claim 으로 B 의 주문 · payment intent 처리
> 가짜 provider key · NULL raw_event_id 로 승인 원장 생성
> 결제 없는 KDS COMMITTED
> TERMINATED + ISOLATED tenant 에서 주문 생성
> ```

> ⚠️ **감사가 스스로 경계를 지켰다.**
>
> ```text
> 증명한 것    DB authenticated 역할 경계
> 증명 안 한 것  JWT 위조 · 공개 HTTP 침해
>              anon 은 application schema USAGE 가 없다
> ```

### §0.2 기존 finding 과의 관계

```text
C-01   601200 · 601211 이 2026-07 에 기록한 것과 같은 축
       601211 실측 486 중 1 (0143)
       2026-09 재측정 465 중 1 — 같은 함수
       이 감사가 runtime 으로 재현했다

H-01   601802 · 601901 이 실측한 provisioning phantom 과 같은 축
```

**새 발견은 `C-02` · `C-03` · `H-02` · `H-03` 쪽이다.**

## §1 감사 결과 — VERBATIM

**아래는 원문이다. 편집하지 않았다.**

````text
# Executive Verdict

**CRITICAL ARCHITECTURAL RISK**

**C. Freeze feature development and repair foundation.**

로컬 DB에서 타 tenant 결제 승인, 동일 결제의 원장 중복, 무결제 KDS COMMITTED를 재현했다.
Provisioning·onboarding·franchise store 생성·subscription management는 실제 컬럼과 맞지 않아 실패한다.
`TERMINATED + ISOLATED` tenant에도 주문을 생성할 수 있다.
전체 E2E 완료 및 운영 가능한 foundation을 인정할 수 없다.
다만 migration 체크섬은 일치하며 최근 문서는 여러 공백을 명시적으로 이월하고 있다.
전체 재설계의 필요성이 입증된 것은 아니다. 현재 권한·상태·멱등성 계약 복구가 우선이다.
**Confidence: HIGH — local code + DB runtime evidence. Cloud/production 실측 완료 판정은 아니다.**

# Current Real Implementation Status

감사일: 2026-09-08. Git: `05e81f119fd03f25d15366448a145d7b10c2acdd`.
DB: `supabase_db_yoonsul_wait_order_handoff`, PostgreSQL 17.6. Docker project label도 확인했다.
기존 소스·migration·문서 수정 및 commit은 하지 않았다. 보고서만 저장소 밖에 새로 작성했다.
Mutation 검증은 로컬 합성 행과 BEGIN/ROLLBACK으로 수행했다. 클라우드/운영 데이터는 변경하지 않았다.

| Area | Status | Confidence / 실제 근거 |
|---|---|---|
| Tenant | Partial | HIGH — 테이블 실재, provision/onboard 실패, lifecycle 차단 실패 |
| Legal Entity | Schema only | HIGH — legal_entities/persons/role/representative 실재, legal_entities 0행 |
| Store | Partial | HIGH — 기존 매장 1행, create_franchise_store 실패, ownership 제약 공백 |
| Auth | Partial | MEDIUM — SQL 로그인/custom auth_sessions 존재. 실제 Supabase JWT·앱 연결 미검증 |
| Staff | Partial | MEDIUM — staff/permission matrix/RPC 존재. 호출자 authority 연결 미완성 |
| Waiting | Partial | MEDIUM — SQL·Flutter 등록 호출 존재. 상태 화면은 저장 ID 표시만 구현 |
| Order | Partial | HIGH — create_order 성공과 동일 요청 중복을 재현 |
| Late Binding | Partial | MEDIUM — session→table 및 KDS 조건 commit 코드 존재. 전체 정상 E2E 미검증 |
| Payment | Partial | HIGH — intent/ledger 존재, 위조 호출과 duplicate ledger 재현 |
| KDS | Partial | HIGH — 내부 ticket/event/commit 존재, 무결제 commit 재현. 외부 전달 미검증 |
| Membership | Partial | MEDIUM — customer/point/coupon/stamp 및 RPC 존재. 앱 E2E·경쟁 미검증 |
| Inventory | Partial | MEDIUM — inventory/transaction 및 row-lock RPC 존재. 주문 차감 E2E 미검증 |

**범위:** 전체 catalog를 수집·검사했지만 474개 함수의 모든 분기와 192개 테이블의 모든 공격을 실행한 전수 의미 검증은 아니다. 검증하지 않은 경로는 아래에서 명시한다. 클라우드 연결 자격정보와 HTTP/Edge 배포 증거는 확보되지 않아 `BLOCKED — insufficient evidence`이다. 로컬 결과를 실제 public endpoint 침해 증거로 확대하지 않는다.

# Critical Findings

## C-01 — Caller authority가 업무 RPC 경계에 강제되지 않는다

- **Severity:** CRITICAL
- **Verdict / Confidence:** VERIFIED / HIGH — local DB role execution
- **Observed:** A의 JWT claim을 설정한 authenticated 역할이 B의 tenant health를 조회하고 B의 주문 및 payment intent를 처리했다. 결제 확인에 임의 provider key와 NULL raw_event_id를 전달해 승인 원장이 생성됐다.
- **Evidence:** E01–E04, runtime T01/T02/T04. Catalog의 함수 EXECUTE/schema USAGE, owner 및 BYPASSRLS.
- **Why dangerous:** 입력 tenant/store와 대상 행의 일치만 확인하면, 요청자가 입력 전체를 B의 값으로 바꿔 우회할 수 있다. owner postgres는 BYPASSRLS이므로 FORCE RLS도 함수 내부의 경계를 대신하지 않는다.
- **Reproduction / reasoning:** SET LOCAL ROLE authenticated와 A의 request.jwt.claims 설정 후 B tenant/store/intent를 전달했다. approved_amount=1000, fake provider key, raw event NULL인 confirmation이 true를 반환했다.
- **Required decision:** 신뢰 가능한 호출자 identity/tenant/store/role을 강제하는 실행 경계를 먼저 확정해야 한다. 문서의 호출 금지는 접근제어가 아니다.

동일 권한 노출 root cause의 추가 사례:

- `catchmenu_dev.drop_dev_schema(text)`도 authenticated에게 schema USAGE+EXECUTE가 있다. body는 schema DROP CASCADE를 수행한다(E05). **파괴적 함수는 실행하지 않았다.** 확인 문자열은 authorization이 아니며 NULL 기본값에서 `if p_confirm != ...` 조건도 NULL이다. 실제 삭제 성공은 NOT VERIFIED.
- `catchmenu_ai.ai_inference_logs`는 tenant_id와 입력/출력 요약을 가지면서 RLS OFF, authenticated SELECT/INSERT이다. Catalog 권한 공백은 VERIFIED, 실제 타 tenant 데이터 반환은 NOT VERIFIED(업무 내용 조회 안 함).

**노출 제한:** anon EXECUTE인 definer는 126개지만 anon의 application schema USAGE는 모두 false다. 이를 익명 HTTP exploit 126개로 계산하지 않았다. config의 exposed schemas도 public/graphql_public이다. 증명한 것은 DB authenticated 역할 경계이며 실제 JWT 위조나 공개 HTTP 침해가 아니다.

## C-02 — Provider confirmation 성공 재호출이 결제 원장을 중복 생성한다

- **Severity:** CRITICAL
- **Verdict / Confidence:** VERIFIED / HIGH
- **Observed:** 동일 intent·provider key·승인액 1000으로 2회 확인하면 모두 true. 원장 **2행 / distinct key 1 / 승인 합계 2000**.
- **Evidence:** E04의 FOR UPDATE 이후 상태 검사 없는 CONFIRMED UPDATE 및 ledger INSERT, catalog의 ledger unique index는 PK뿐. T02/T03.
- **Why dangerous:** 실제 하나의 결제에 내부 승인 기록이 두 번 누적되어 정산·환불의 전제가 깨진다.
- **Reproduction / reasoning:** 같은 confirm_payment_from_provider를 순차 2회 호출했다. row lock은 직렬화만 하고 두 번째 INSERT를 막지 않는다. 동시 두 세션 실험은 미실행이며 순차 replay만으로 결함이 확정된다.
- **Required decision:** canonical 승인 경로와 provider event/key·intent·order별 성공 replay 계약을 정하고 모든 경로에 동일 invariant를 증명해야 한다.

반대 증거: resolve_or_create_payment_intent의 UNIQUE(idempotency_key)+ON CONFLICT는 실재한다(E06). **Intent 생성 race fix는 ledger confirmation 멱등성 보장이 아니다.** confirm_payment의 별도 replay/order-lock 로직과 provider confirmation은 다른 경로로 공존한다.

## C-03 — 단일 KDS commit 경로가 결제 원장 gate를 우회한다

- **Severity:** CRITICAL — authorization/integrity bypass
- **Verdict / Confidence:** VERIFIED / HIGH
- **Observed:** payment_ledger **0행**인 HOLD ticket에 arrived/table_confirmed/payment_confirmed=true를 전달하자 COMMITTED로 저장됐다.
- **Evidence:** E07/E08, catalog ACL, T05.
- **Why dangerous:** 요청자가 제출한 JSON이 결제 사실을 대체한다. 승인 원장의 gate가 모든 kitchen-action 경로에 적용되지 않는다.
- **Reproduction / reasoning:** authenticated/A claim으로 합성 B ticket의 commit_kds_ticket 호출. 이 함수는 JSON과 capacity를 확인하지만 approved ledger를 조회하지 않는다. bulk_commit_kds_tickets의 ledger gate를 직접 단일 commit으로 우회한다.
- **Required decision:** 모든 COMMITTED 전환 경로에 공통 invariant와 호출 권한을 강제해야 한다. 특정 orchestration 함수 추가만으로 전체 경로가 안전하다고 판정할 수 없다.

살아 있는 release_kds_after_payment도 ledger UPDATE 성공행 수·order 연결·APPROVED 상태를 확인하지 않고 HOLD→COMMITTED를 수행한다(E08). 이 추가 경로는 code/catalog 기준 PARTIALLY VERIFIED이며 별도 mutation은 실행하지 않았다. 같은 KDS gate root cause로 묶었다.

# High Findings

## H-01 — Provisioning/lifecycle 함수와 실제 schema/state 계약 불일치

- **Severity:** HIGH
- **Verdict / Confidence:** VERIFIED / HIGH
- **Observed:** 아래 실함수 호출이 실패한다.

| RPC | DB observed result |
|---|---|
| provision_tenant | 42703: tenants.owner_name 없음 |
| onboard_tenant | 42703: tenants.business_number 없음 |
| create_franchise_store | 42703: stores.extra_metadata 없음 |
| manage_subscription | 42703: tenants.company_name 없음 |
| isolate_tenant(true) | 23514: chk_tenants_status 위반 |

- **Evidence:** E09–E12, E15, T06–T10.
- **Why dangerous:** tenant 생성·매장 확장·계약 정지/복구가 실행 불능이다. isolation_state 추가 후에도 옛 함수는 tenant_status='ISOLATED'를 쓰고 새 CHECK는 이를 허용하지 않는다.
- **Reproduction / reasoning:** 없는 컬럼 SELECT는 read-only로도 재현했다. isolate는 합성 tenant만 대상으로 transaction 내 재현했다. 추가 latent mismatch로 provision의 RESTAURANT는 store CHECK와 충돌하고 onboard named args는 실제 provision signature와 다르다. 선행 오류 때문에 이 후속 경로는 code-only다.
- **Required decision:** DDL 완료와 실행 계약 완료를 분리하고 provisioning/lifecycle 정합성을 먼저 복구해야 한다.

`TERMINATED + ISOLATED` tenant에 create_order가 성공했다(T04). 업무 함수 body에서 isolation_state를 읽는 함수는 발견되지 않았고 tenant_status 참조는 관리/조회 계열에 집중됐다. SUSPENDED/CANCELLED의 모든 경로를 실험한 것은 아니지만 create_order body에는 상태 차단이 없다. 실제 발급 token 자동 무효화는 NOT VERIFIED.

**Phantom provisioning:** 이번 provision/franchise 실패의 잔여 tenant/store는 0행이었다. 따라서 partial tenant가 남았다고 주장하지 않는다. 그러나 tenant→legal entity→merchant→store→staff→auth user의 성공 생성 경로는 확인하지 못했다. Onboard의 best-effort brand 처리까지 원자성을 일괄 인증하지 않는다.

## H-02 — Order retry가 새 주문을 만들고 번호 생성 범위도 맞지 않는다

- **Severity:** HIGH
- **Verdict / Confidence:** retry VERIFIED/HIGH; concurrency·일자 경계 PARTIALLY VERIFIED
- **Observed:** 동일 session/items/correlation_id로 2회 create_order: 다른 order_id, 번호 0001/0002, 주문 2행.
- **Evidence:** E03/E13, T04.
- **Why dangerous:** 재전송으로 주문이 증가하고 session.order_id가 마지막 주문으로 바뀐다. 추가 주문과 재전송을 구분하는 request identity가 없다.
- **Reproduction / reasoning:** session lock은 있으나 ORDERING 재호출을 허용한다. 번호는 당일 count(*)+1인데 UNIQUE는 날짜 없는 (store_id,order_number)다. 다른 session 동시 요청은 같은 번호를 계산할 수 있고 다음 날 0001은 이전 0001과 충돌한다. UNIQUE가 있으므로 중복 번호 저장이 아니라 요청 실패 위험이다. 동시 두 연결 및 다음 날 실험은 미실행.
- **Required decision:** request identity와 추가 주문 의미, 번호의 일자 범위를 정하고 실함수로 retry/concurrency를 증명해야 한다.

## H-03 — FK가 ownership chain의 tenant 일치와 완전성을 보장하지 않는다

- **Severity:** HIGH — schema integrity; 일반 client write exploit과 구분
- **Verdict / Confidence:** VERIFIED / HIGH
- **Observed:** 합성 Tenant A store가 B merchant account를 참조하는 INSERT를 DB가 수락했다. 현재 existing store의 merchant는 존재하지만 legal_entity_id는 NULL, legal_entities는 0행이다.
- **Evidence:** E14/E15, catalog FK/nullable, T11.
- **Why dangerous:** tenant와 merchant를 독립적인 FK로 검사하면 두 소속이 달라도 각각 유효하다. 1회 backfill은 향후 write invariant가 아니다.
- **Reproduction / reasoning:** privileged fixture INSERT로 제약 공백을 확인했다. authenticated의 stores direct write는 허용되지 않아 이것만으로 direct client write bypass를 주장하지 않는다. orders/items도 tenant/store/order/session 단일 FK이므로 관계 일치 검토가 필요하다.
- **Required decision:** store tenant/merchant/legal relation의 DB 필수 조건과 이월 범위를 명확히 정해야 한다.

merchant_accounts.tenant_id UNIQUE NOT NULL은 tenant당 **최대 1개**를 보장한다. 모든 tenant의 merchant 존재는 보장하지 않는다. Person/LegalEntity에 tenant_id가 없는 global identity 모델 자체는 오류로 단정하지 않는다.

# Medium / Low Findings

| ID | Severity / Confidence | Finding / evidence |
|---|---|---|
| M-01 | MEDIUM / MEDIUM | create_order는 (price+options_amount)*quantity, item CHECK는 price*quantity+options_amount. quantity>1, option!=0에서 충돌. E03 L145–148, E13 L212–213. runtime 미실행 |
| M-02 | MEDIUM / HIGH | completion summary는 pg_cron_jobs.is_active, final validation은 s.schema_name 때문에 각각 42703. Readiness test로 사용 불가. E16/E17, T12/T13 |
| M-03 | MEDIUM / MEDIUM | get_auth_context가 STABLE인데 내부 UPDATE. 정상 session 분기 E2E 미실행. E18 |
| M-04 | MEDIUM / MEDIUM | generic payment webhook는 signature 존재만 기록하고 NULL 허용; inner confirm 결과를 성공 wrapper로 감쌈. Toss overload별 signature/dedup 계약도 상이. E19/E20. 실제 webhook 10회 미검증 |
| L-01 | LOW / HIGH | assert_true live body는 active migrations 밖의 excluded 0073에서 확인. 체크섬 일치와 replay 재현성은 별개. E21 |

Application FK catalog에서 ON DELETE CASCADE는 발견하지 못했다. 파괴적 cascade를 추측하지 않았다. nullable/독립 FK의 불완전 관계와 참조 대상 자체가 없는 orphan은 구분한다.

# Document Hallucination / Drift

최근 문서의 모든 COMPLETE/PASS를 허위로 보지 않았다. 좁은 DDL 구현 완료와 제품 실행 완료를 구분한다. 작성자가 AI였다는 원인은 확정할 수 없다.

| Document Claim | Actual Implementation | Verdict | Evidence |
|---|---|---|---|
| 906010: approved ledger 없이 KDS release 금지, client direct release 금지 | 원장 0행에서 authenticated direct commit 성공 | CONTRADICTED | E22/T05 |
| 0135: DB_COMPLETE_MVP_READY, patent IMPLEMENTED | 고정 문자열; 함수 자체 missing column 실패; 앱 E2E 없음 | CONTRADICTED — readiness 증거로 부적합 | E16/T12 |
| 600567: payment intent race fixed | UNIQUE(idempotency_key), ON CONFLICT RETURNING 존재 | PARTIALLY VERIFIED — 동시 실험은 이번 미실행 | E06/E23 |
| 601031: webhook 멱등성 high-priority open item | provider confirmation 재호출 중복 | VERIFIED — 미해결 기록과 일치 | E24/T03 |
| 601748: conditional merge, production/runtime 승인 아님 | schema 구현과 critical runtime 공백 공존 | PARTIALLY VERIFIED — approval 원본 진위 재인증 안 함 | E25 |
| 601747: merchant/store cross-tenant FK 저장 가능 | 현재 local 전체 schema에서도 수락 | VERIFIED | E26/T11 |
| 601512 옛 0-A 완료 | 상단 AUTHORITY SUSPENDED로 명시 철회 | 옛 완료 해석은 CONTRADICTED; 현재 배너는 일치 | E27 |
| 600010: 0-B 미착수, 0-A-2 권위보류/재수행 | caller/session/lifecycle 공백 유지 | PARTIALLY VERIFIED | E28/H-01 |

**Phantom object:** 906010의 orders.order_source, order_sessions.status, payment_ledger.status, CALL_EXPIRED/PAYMENT_FAILED session states는 현재 물리 계약과 맞지 않는다. 실제 column은 order_channel/session_status/ledger_status이다. 개념 표기를 물리 구현 완료 증거로 받아들이면 오류다.

**Phantom fix / circular evidence:** 600567의 제한된 intent fix를 허위로 판정할 증거는 없다. 그러나 전체 결제 retry 안전성으로 확장할 수 없다. 문서 간 인용만으로 PASS하지 않고 catalog와 runtime을 별도로 사용했다. 전체 문서 인용 그래프는 전수 분석하지 않아 circular evidence 전체 부재도 주장하지 않는다.

# Architecture Reality Map

```text
catchmenu_hq.tenants
 ├─ stores.tenant_id → tenants.id
 │   ├─ legal_entity_id? → legal_entities.id          [현재 NULL]
 │   └─ merchant_account_id? → merchant_accounts.id   [tenant 일치 미강제]
 ├─ merchant_accounts.tenant_id → tenants.id          [NOT NULL + UNIQUE, 최대 1]
 ├─ tenant_plan_configs / onboarding / quota / rate-limit
 ├─ store.staff / customers / inventory / point / coupon
 └─ pos.order_sessions → orders → order_items
       ├─ payment.payment_intents → payment_ledger
       └─ kds.kds_tickets / kds_events

legal_entities ↔ legal_entity_person_roles ↔ persons
legal_entities ↔ legal_entity_representatives ↔ persons
 [기존 provisioning과 이어지는 실행 경로 미확인]

Flutter bootstrap + waiting register + stored-ID status
 → RpcCaller → schema(...).rpc(...)
 → PostgreSQL SECURITY DEFINER 업무 함수
 → catchmenu_* tables / ledger / audit
```

LegalEntity는 tenant의 직접 FK 자식이 아니다. Store를 통해 연결된다. Staff/custom auth session과 Supabase JWT helper도 별개 구조이며 연결 E2E 증거가 없다.

**실측:** application schema 15, table 192, function 474, SECURITY DEFINER 465, RLS+FORCE table 173, policies 181, tenant_id column table 171.
Definer owner는 전부 postgres, search_path 설정 누락은 0개다. 이것은 caller validation의 증거가 아니다. authenticated/anon의 application/public schema CREATE는 없다. implicit pg_temp/unqualified relation shadowing은 호출별 NOT VERIFIED이며 fixed path만으로 일괄 SAFE 판정하지 않는다.

**현재 복수 경로:**

- confirm_payment → release_kds_after_payment
- confirm_payment_from_provider → request_kds_release_after_payment → bulk_commit_kds_tickets → commit_kds_ticket
- process_toss_webhook는 signature/body 2개. 하나는 provider-confirm, 다른 하나는 confirm_toss_payment 계열 호출
- authorize_kds_release/no-payment release 등도 실재. 모두 제거된 legacy라고 할 수 없음
- 13개 함수 이름에 overload 존재. overload 자체는 결함이 아니지만 production caller가 무엇을 쓰는지 확인 필요

Membership/inventory는 문서만은 아니다. register_customer는 재방문에서 visit_count를 증가시켜 재시도가 완전 no-op가 아니다. update_inventory는 FOR UPDATE를 사용하지만 request dedup 없이 반복 수량 변경이 가능하다. 전체 membership/stock movement 동시성은 미검증이다.

# End-to-End Capability

**전체 목표 흐름: FAIL.** 사용자 앱부터 신뢰 가능한 payment, 외부 KDS 전달까지 완주를 증명하지 못했다.

| Step | Verdict | 실제 상태 |
|---|---|---|
| Tenant 생성 | FAIL | provision/onboard 42703 |
| Tenant 로그인 | BLOCKED | custom auth 존재, 실제 tenant JWT·앱 연결 E2E 미검증 |
| Waiting | PARTIAL | bootstrap_customer_app_v2/register_waiting 호출. 상태 화면은 local 저장 ID만 표시 |
| Order | PARTIAL | 생성 성공. 중복 및 번호 범위 문제 |
| Late Binding | PARTIAL | session/table row lock 및 prebinding 검증 후 SEATED/OCCUPIED. 정상 E2E 미검증 |
| Payment | FAIL | fake confirmation·same-success 원장 중복. 직접 금액 mismatch는 정상 거절 |
| KDS 전달 | FAIL | 내부 COMMITTED 가능하지만 gate 우회. 외부 수신/ACK/retry 미검증 |

bind_table_to_session은 WAITING/ARRIVAL_PENDING/ORDERING의 미바인딩 session과 AVAILABLE/RESERVED table을 잠그고 변경한다. duplicate binding 방어가 있으므로 무잠금 race로 부풀리지 않았다. 재호출 성공 replay와 binding 후 모든 admin 수정 경로는 미검증이다.

| Attack scenario | Verdict | 증거/한계 |
|---|---|---|
| A: A user→B store | VERIFIED vulnerability | B 주문·결제 처리 성공 |
| B: 같은 주문 동시 2회 | PARTIALLY VERIFIED | 순차 2회 중복 확정; 동시 두 연결은 미실행 |
| C: 동일 webhook 10회 | NOT VERIFIED | overload body 분석. provider confirm 2회만 runtime 재현 |
| D: payment amount mismatch | VERIFIED direct rejection | 1000 intent/999 approval → amount_mismatch; wrapper 전체 미검증 |
| E: 성공 후 confirm 재호출 | VERIFIED vulnerability | 원장 2행/키 1/합계 2000 |
| F: provisioning 중간 실패 | PARTIALLY VERIFIED | 조기 schema 실패 후 잔여 0; 정상 중간단계에는 도달 불가 |
| G: ISOLATED direct RPC | VERIFIED vulnerability | TERMINATED+ISOLATED에서 주문 성공 |
| H: SUSPENDED store RPC | PARTIALLY VERIFIED | create_order 상태 gate 없음; 별도 runtime 미실행 |
| I: CANCELLED/TERMINATED 기존 session | PARTIALLY VERIFIED | TERMINATED 업무 session 주문 성공; 실제 발급 auth token E2E 미검증 |
| J: A staff→B order UUID | VERIFIED DB-role vulnerability | A STAFF claim으로 B intent/order confirm; HTTP token 발급 공격 아님 |

# Top 5 Blockers

1. Caller authority 및 tenant/store boundary: RPC와 직접 table 경로를 포함한 C-01.
2. Payment approval/replay의 단일 invariant: provider 증거·키·intent/order 중복 방지(C-02).
3. 모든 KDS COMMITTED 경로의 승인 gate(C-03).
4. 실행 가능한 provisioning/lifecycle/auth 계약과 stale session 차단(H-01).
5. Ownership/order retry·번호 정합성과 실제 앱→DB→provider→KDS E2E gate(H-02/H-03).

# Recommended Next Gate

이번에는 수정 코드를 작성하거나 적용하지 않았다. 새 기능 착수 전에 다음 증거가 필요하다.

1. **Baseline:** catalog/ACL/function body/migration hash와 배포 target 고정. Cloud/local 차이 실측.
2. **Boundary:** 실제 발급 A/B token으로 SELECT/INSERT/UPDATE/DELETE/RPC를 각각 실행하고 최종 DB 상태와 감사 기록으로 차단 증명. Schema exposure와 EXECUTE도 함께 확인.
3. **Payment/KDS:** 동일 성공 2회, webhook 10회, 동시 confirm, 다른 order의 같은 provider key, 금액 mismatch, 응답 소실, 취소/confirm 경쟁을 canonical 실함수에서 검증.
4. **Lifecycle/provisioning:** 상태 조합별 허용/차단 matrix, 전체 생성, 중간단계 실패·재시도·기존 token 검증. LegalEntity/merchant/store/staff 관계를 DB 최종 행으로 검증.
5. **Product:** clean replay 및 tenant→login→waiting→order→binding→payment→KDS ACK 실앱 실행. 테스트 수·상수 COMPLETE 대신 부정 시나리오와 invariant를 gate로 사용.

**질문 1:** 증거는 단순 복잡성보다 **정합성 공백을 이월하면서 같은 경계를 다시 검토하는 문제**를 지지한다. 복수 결제 경로, isolation schema와 옛 함수 충돌, 문서의 0-A 완료 후 권위보류/재수행, 다시 0-A-2 권위보류가 확인된다(E24/E27/E28). 개발시간의 원인별 비중은 측정 자료가 없어 수치화하거나 개인 책임을 판단하지 않는다.

**질문 2: C. Freeze feature development and repair foundation.** 판단 근거는 재현된 C-01~C-03이다. 모든 개발을 중단하라는 의미가 아니라 신규 기능 확장보다 foundation 복구와 위 gate 통과를 우선하라는 판정이다.


# Appendix A — 주요 RPC 상세 검사표

단일 PostgreSQL 함수 호출의 transaction 경계를 기준으로 한다. HTTP handler 전체나 외부 provider와의 분산 transaction을 보장한다는 의미는 아니다. 정확한 전체 signature/body는 db-catalog-evidence.json에 있다.

## provision_tenant

| Item | Result |
|---|---|
| Inputs | tenant code/name, owner fields, plan/store/channel/correlation |
| Authentication | authenticated EXECUTE 있음; body caller identity 미검증 |
| Authorization | role/tenant authority gate 없음 |
| tenant verification | active plan 확인, tenant INSERT |
| store verification | 새 store INSERT. RESTAURANT와 CHECK 불일치 |
| transaction boundary | 한 SQL 함수 호출 |
| failure rollback | 42703 owner_name; 잔여 tenant 0 실측 |
| idempotency | tenant_code UNIQUE만; 성공 replay 계약 없음 |
| concurrency safety | UNIQUE로 중복 code 방어; 성공 provisioning 경쟁 미검증 |
| duplicate execution | 현재는 owner_name 오류로 불능 |
| partial state risk | 이번 실패 잔여 없음; 완전 생성 경로 미실행 |
| cross-tenant risk | caller authorization 부재; 조기 오류는 보호 장치 아님 |

## onboard_tenant

| Item | Result |
|---|---|
| Inputs | company/business number/CEO/plan/store/brand/actor/locale |
| Authentication | authenticated/anon direct EXECUTE 없음 |
| Authorization | body role gate 없음; indirect server path 미검증 |
| tenant verification | 없는 business_number duplicate query로 즉시 실패 |
| store verification | provision 호출 named args와 반환 data shape도 불일치 |
| transaction boundary | 한 SQL 함수 호출; auth user 생성 없음 |
| failure rollback | read-only early error 재현 |
| idempotency | business_number 사전조회만 작성; 실행 불능 |
| concurrency safety | 성공 경로 미도달 |
| duplicate execution | 현재 실행 불능 |
| partial state risk | best-effort brand error JSON 처리; 완전 원자성 미인증 |
| cross-tenant risk | 일반 role direct call 제한; indirect reachability 미검증 |

## create_franchise_store

| Item | Result |
|---|---|
| Inputs | tenant/store code/name/type/address/timezone/franchisee/actor/correlation |
| Authentication | authenticated EXECUTE |
| Authorization | p_actor_type 기본 HQ_ADMIN은 role 검증 아님 |
| tenant verification | FK/대상 parameter만; caller tenant 검사 없음 |
| store verification | code/type/duplicate validation |
| transaction boundary | 한 SQL 함수 + settings/point rule helper |
| failure rollback | extra_metadata 42703; 신규 store 잔여 0 |
| idempotency | UNIQUE(tenant_id,store_code); replay 성공 반환 없음 |
| concurrency safety | 사전 EXISTS race 가능, UNIQUE가 중복을 오류로 막음 |
| duplicate execution | 기존 code 오류; 새 code도 schema 오류 |
| partial state risk | 이번 실패 잔여 없음; merchant/legal/staff 생성 없음 |
| cross-tenant risk | caller guard 부재; 실제 create는 조기 오류로 미성공 |

## isolate_tenant

| Item | Result |
|---|---|
| Inputs | tenant/reason/isolate boolean/actor/locale |
| Authentication | authenticated EXECUTE |
| Authorization | HQ_ADMIN 기록만, caller role 검사 없음 |
| tenant verification | UPDATE id=parameter; caller tenant 확인 없음 |
| store verification | tenant scope operation |
| transaction boundary | tenant UPDATE+security log+ledger+audit |
| failure rollback | 23514 CHECK 위반 확인 |
| idempotency | 동일 상태 재설정 및 새 로그; dedup 없음 |
| concurrency safety | UPDATE row lock; lifecycle CAS/version 없음 |
| duplicate execution | true 호출은 현재 CHECK 오류 |
| partial state risk | 현재 UPDATE에서 실패; false는 ACTIVE 재설정 설계 |
| cross-tenant risk | caller guard 부재; true 실패가 isolation enforcement 아님 |

## manage_subscription

| Item | Result |
|---|---|
| Inputs | tenant/action/plan/reason/actor/locale |
| Authentication | authenticated/anon direct EXECUTE 없음 |
| Authorization | body role gate 없음; server caller 미검증 |
| tenant verification | 없는 company_name 조회로 42703 |
| store verification | tenant scope operation |
| transaction boundary | 함수 안 plan/invoice/event 처리 |
| failure rollback | read-only early failure |
| idempotency | request key 없음; invoice dedup 미확정 |
| concurrency safety | plan 변경 explicit lock/CAS 안 보임 |
| duplicate execution | 현재 조기 실패; 성공 replay 미구현 |
| partial state risk | 현재 잔여 생성 없음; full path 미실행 |
| cross-tenant risk | 일반 role direct call 제한; indirect path 미검증 |

# Appendix B — Migration / security / test quality coverage

- 정규 번호 migration 170개 전부 history success 존재 및 LF-normalized SHA-256 일치. missing-history/history-only/mismatch 각각 0.
- 번호 0073/0128은 현재 sequence에 없다. 0073은 excluded 디렉터리에 존재한다. 번호 gap 자체를 실패로 단정하지 않았다. non-numbered seed는 정규 history 비교 밖이다.
- 함수 body 473/474는 whitespace-normalized 비교로 현재 migration 중 적어도 하나와 일치했다. assert_true는 excluded 0073에 있다. 이 비교는 full schema replay 동일성 증명이 아니다.
- 최신 실함수는 pg_get_functiondef로 확인했다. 파일 존재만으로 배포 완료 판정을 내리지 않았다. clean replay/rollback 복구/cloud divergence는 이번 미실행이다.
- 전체 tables/columns/FK/CHECK/index/trigger/policy/function ACL은 JSON에 수록했다. 각 테이블의 모든 CRUD 공격을 수행한 것은 아니다.
- SECURITY DEFINER 465개 목록의 owner/search_path/ACL은 catalog 실측. 개별 caller/tenant/role/injection/shadowing 의미 검증 미완료는 NOT VERIFIED로 보존했다.
- tests/는 static validation 사례 문서 중심. Flutter widget test는 bootstrap 초기화 오류 표시를 검증하며 tenant/payment/concurrency invariant를 증명하지 않는다(E31).
- SQL 검증 package의 존재·개수 검사와 고정 verdict는 runtime 업무 검증과 다르다. run_final_validation와 completion summary는 실제 오류다.
- 과거 pg_temp 복제 함수 테스트는 실제 signature/grant/caller wiring까지 자동 증명하지 않는다. 이번 핵심 증명은 patch한 함수가 아닌 현재 실함수로 수행했다.
- Flutter test/build는 이번에 실행하지 않았다. 단일 widget test의 통과는 본 감사의 핵심 위험을 해소하지 못한다.

# Appendix C — Runtime evidence register

합성 tenant: eeeeeeee-0000-4000-8000-000000000001, store: ...0002, order: ...0003, intent: ...0004, session: ...0005, menu: ...0006, ticket: ...0007.
호출자 claim: tenant/store/sub=aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa, role=authenticated, actor_type=STAFF.
관리자가 SET LOCAL로 설정한 DB 역할 시뮬레이션이며 실제 JWT 위조 실험이 아니다. 아래 결과는 이 감사의 tool 실행에서 직접 관측한 결과의 요약이다.

| Test | Query / method | Observed result |
|---|---|---|
| T01 | authenticated/A claims, get_tenant_health(B,'ko')->>'success' | true. direct tenants SELECT는 permission denied; 별도 transaction에서 RPC 재실행 |
| T02 | confirm_payment_from_provider(B,storeB,intent,'AUDIT_FAKE_KEY','AUDIT',1000,NULL,'AUDIT') | true; provider 네트워크 호출 없이 ledger 생성 |
| T03 | T02 동일 인자 재호출, ledger count/distinct key/sum | true; 2 rows / 1 key / approved sum 2000 |
| T04 | TERMINATED+ISOLATED tenant/session, 동일 items/correlation create_order 2회 | true 2회; UUID 다름, 0001/0002, count=2 |
| T05 | commit_kds_ticket(B,storeB,ticket,arrived/table_confirmed/payment_confirmed=true,'AUDIT') | COMMITTED; 해당 tenant payment ledger count=0 |
| T06 | 실제 active plan code로 provision_tenant 전체 입력 제공 | 42703 owner_name; residual tenant=0 |
| T07 | onboard_tenant의 전체 입력, read-only | 42703 business_number |
| T08 | 합성 tenant로 create_franchise_store 전체 표준 actor/correlation 제공 | 42703 extra_metadata; residual store=0 |
| T09 | manage_subscription(existing tenant,'SUSPEND',NULL,'AUDIT',NULL,'ko'), read-only | 42703 company_name |
| T10 | isolate_tenant(synthetic tenant,'AUDIT',true,actor,'ko') | 23514 chk_tenants_status |
| T11 | 합성 A store→B merchant FK INSERT, privileged role | 수락; s.tenant_id<>ma.tenant_id=true |
| T12 | get_project_completion_summary(), read-only | 42703 pg_cron_jobs.is_active |
| T13 | run_final_validation(), 별도 read-only transaction | 42703 s.schema_name |
| T14 | T02의 같은 intent에 approved_amount=999 | amount_mismatch; 이어서 1000 정상 승인 실험 |

모든 mutation fixture transaction을 ROLLBACK했다. 함수/constraint/policy/trigger 정의 변경, DROP/TRUNCATE, dev schema 삭제 함수 실행은 하지 않았다. Provider external request도 발생시키지 않았다.

# Appendix D — Source evidence

JSON에 live 함수 본문과 migration body 범위가 함께 있다. 코드 원문 핵심: `FOR UPDATE`, `tenant_status = v_new_status`, `kds_status = 'COMMITTED'`, `UNIQUE (idempotency_key)`, `ON CONFLICT (idempotency_key)`를 각 인용 위치와 대조했다.

| ID | Source file / start line | Relevant range / object |
|---|---|---|
| E01 | [0022_create_rls_policies.sql L20](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0022_create_rls_policies.sql:20) | 20–104 JWT helpers; RLS와 caller authority 분리 |
| E02 | [0090_create_multitenant_isolation_rpc.sql L1100](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0090_create_multitenant_isolation_rpc.sql:1100) | get_tenant_health body 1109–1253, grant 1444 |
| E03 | [0026_create_order_rpc.sql L13](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0026_create_order_rpc.sql:13) | create_order; count(*)+1, session lock, items/options 계산 |
| E04 | [0166_canonical_kds_release_orchestration.sql L145](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0166_canonical_kds_release_orchestration.sql:145) | 145–426 provider confirmation; 179 lock, 196–233 UPDATE/ledger INSERT |
| E05 | [0136_create_dev_audit_log.sql L502](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0136_create_dev_audit_log.sql:502) | drop_dev_schema 502–543; NULL default/confirm and DROP body |
| E06 | [0159_fix_payment_intent_idempotency_key_race.sql L24](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0159_fix_payment_intent_idempotency_key_race.sql:24) | UNIQUE(idempotency_key); 238 ON CONFLICT |
| E07 | [0028_create_kds_capacity_commit_rpc.sql L68](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0028_create_kds_capacity_commit_rpc.sql:68) | commit_kds_ticket 68–376; 136–177 JSON 조건, ledger 조회 없음 |
| E08 | [0157_authorize_kds_release_overload_and_redesign.sql L53](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0157_authorize_kds_release_overload_and_redesign.sql:53) | 53–164 live release_kds_after_payment body; bulk gate는 0039 |
| E09 | [0082_create_saas_billing_rpc.sql L426](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0082_create_saas_billing_rpc.sql:426) | provision_tenant 426–648; 479 owner_name, 528 RESTAURANT |
| E10 | [0112_create_hq_admin_rpc.sql L393](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0112_create_hq_admin_rpc.sql:393) | onboard 393–503, subscription 522–698 |
| E11 | [0060_create_franchise_hq_rpc.sql L166](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0060_create_franchise_hq_rpc.sql:166) | franchise store 166–322, extra_metadata INSERT |
| E12 | [0090_create_multitenant_isolation_rpc.sql L1257](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0090_create_multitenant_isolation_rpc.sql:1257) | 1257–1385 isolate; 1295 tenant_status=v_new_status |
| E13 | [0013_create_pos_orders.sql L63](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0013_create_pos_orders.sql:63) | UNIQUE(store_id,order_number); 212–213 item CHECK |
| E14 | [0171_merchant_account_foundation.sql L6](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0171_merchant_account_foundation.sql:6) | merchant tenant UNIQUE, nullable store single FK, backfill |
| E15 | [0168_create_operational_authority_foundation.sql L152](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0168_create_operational_authority_foundation.sql:152) | 152–201 lifecycle axes/legal relation constraints |
| E16 | [0135_create_flutter_mvp_start_package.sql L314](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0135_create_flutter_mvp_start_package.sql:314) | summary; 365 DB_COMPLETE_MVP_READY constant |
| E17 | [0118_create_schema_validation_update.sql L336](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0118_create_schema_validation_update.sql:336) | final validation; 364 alias error; 480 VERIFIED constant |
| E18 | [0097_create_auth_login_pipeline_rpc.sql L1438](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0097_create_auth_login_pipeline_rpc.sql:1438) | get_auth_context STABLE+UPDATE; staff_login 655, PIN check 785 |
| E19 | [0098_create_payment_confirm_pipeline_rpc.sql L951](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql:951) | generic payment webhook; nullable signature, success wrapper |
| E20 | [0038_create_toss_webhook_processor_rpc.sql L294](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0038_create_toss_webhook_processor_rpc.sql:294) | PERFORM provider confirm; second overload in 0103 catalog |
| E21 | [0073_final_verification.sql L49](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/_excluded_from_local_replay/0073_final_verification.sql:49) | assert_true live helper outside active migration directory |
| E22 | [906010_ChangeContract_Catch_Menu_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md L96](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/900000_patent_and_handoff_package/906010_ChangeContract_Catch_Menu_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md:96) | INV-001–005 |
| E23 | [600567_Audit.md L19](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/600500_payment_confirmation/600560_payment_intent_race_condition_fix/600567_Audit.md:19) | intent uniqueness/resolver/race fix scope |
| E24 | [601031_Overview_Canonical_Kds_Release_Orchestration.md L94](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/600500_payment_confirmation/601030_canonical_kds_release_orchestration/601031_Overview_Canonical_Kds_Release_Orchestration.md:94) | webhook retry high-priority open item |
| E25 | [601748_Evidence_Stage12_Human_Merge_Decision.md L49](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601748_Evidence_Stage12_Human_Merge_Decision.md:49) | conditional merge; no production/runtime activation |
| E26 | [601747_Evidence_Stage11C_FaultInjection_CrossTenant_Codex.md L135](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601747_Evidence_Stage11C_FaultInjection_CrossTenant_Codex.md:135) | single-column FK, independent fault injection |
| E27 | [601512_Baseline_Summary.md L3](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601512_Baseline_Summary.md:3) | AUTHORITY SUSPENDED banner, historical COMPLETE below |
| E28 | [600010_Tracker_Spiral_Workpacket_Progress.md L38](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/600010_Tracker_Spiral_Workpacket_Progress.md:38) | current stages/repeated authority suspension/deferred gates |
| E29 | [router.dart L7](D:/Workspace/Yoonsul_Wait_Order_Handoff/catchmenu_app/lib/app/router.dart:7) | bootstrap/waiting-register/waiting-status routes only |
| E30 | [waiting_status_screen.dart L23](D:/Workspace/Yoonsul_Wait_Order_Handoff/catchmenu_app/lib/features/waiting/screens/waiting_status_screen.dart:23) | storage-only screen, no status RPC |
| E31 | [widget_test.dart L11](D:/Workspace/Yoonsul_Wait_Order_Handoff/catchmenu_app/test/widget_test.dart:11) | bootstrap initialization error widget test |
| E32 | [config.toml L10](D:/Workspace/Yoonsul_Wait_Order_Handoff/supabase/config.toml:10) | exposed schemas vs application custom schema reachability |

# Appendix E — Evidence files

- [db-catalog-evidence.json](C:/Users/USER/.codex/visualizations/2026/09/07/01a07de5-7724-75a2-aa93-b033b64189d3/catchmenu-audit-20260908/db-catalog-evidence.json): 전체 catalog와 body/constraint/index/policy/trigger/ACL/migration hash
- [security-definer-inventory.md](C:/Users/USER/.codex/visualizations/2026/09/07/01a07de5-7724-75a2-aa93-b033b64189d3/catchmenu-audit-20260908/security-definer-inventory.md): SECURITY DEFINER 465개 전체 목록 및 개별 미검증 상태
- [table-isolation-inventory.md](C:/Users/USER/.codex/visualizations/2026/09/07/01a07de5-7724-75a2-aa93-b033b64189d3/catchmenu-audit-20260908/table-isolation-inventory.md): 192개 테이블별 RLS/FORCE/policy/직접 CRUD 권한


# Appendix F — Idempotency / concurrency 요약 및 종료 검증

| Operation | 동일 요청 2회 분석 | DB 방어 / 확인 한계 |
|---|---|---|
| Tenant provisioning | 현재 42703으로 성공 불가 | tenant_code UNIQUE; 성공 replay 계약 검증 불가 |
| Store creation | 현재 42703으로 성공 불가 | tenant/store_code UNIQUE; EXISTS와 INSERT 사이 race는 오류로 귀결 가능 |
| Membership enrollment | 등록 대응 경로 register_customer는 기존 고객 반환 시 visit_count 증가 | 별도 enroll 이름의 함수는 catalog에서 확인 못함. 동시 등록 미실행; customer/code 관련 UNIQUE는 JSON에 수록 |
| Order creation | 실제 2회 → 주문 2행 | session row lock 있어도 request dedup 아님 |
| Payment initiate | create_payment_intent는 기존 active intent에 active_intent_exists 반환 | idempotency_key UNIQUE 존재; 다른 key로 같은 order 경쟁은 별도 보장 미확인. resolver의 ON CONFLICT는 개선 증거 |
| Payment confirm | 실제 동일 intent/key 2회 → ledger 2행 | provider-confirm row lock만으로 dedup 안 됨. 다른 confirm 경로와 계약 불일치 |
| Webhook | overload별 EXISTS 기반 dedup/처리 상태와 signature 계약이 다름 | 실제 provider HTTP 재전송 10회/경쟁 미검증 |
| KDS release | bulk gate와 단일 commit 경로가 다름. 단일 commit은 이미 COMMITTED이면 holdable 오류 분기 | ticket row lock과 상태 조건은 있음. ledger 기반 전체 경로 gate는 실제 우회됨. 외부 전송의 exactly-once 보장 없음/미검증 |

현재 onboarding/provisioning 관련 생성 경로는 catalog body의 tenants/stores INSERT 검색으로 provision_tenant/create_franchise_store, 이를 호출하는 onboard_tenant를 확인했다. 단순 이름 추정으로 RPC를 추가하지 않았다.

**종료 재검증 결과:**

- 감사 catalog 수집 이후 함수 474개의 body 변경 0.
- SECURITY DEFINER inventory 실제 행 465, table inventory 실제 행 192.
- 보고서의 source 파일/line 링크 존재 및 범위 오류 0.
- 합성 AUDIT tenant 잔여 0, AUDIT_FAKE_KEY payment ledger 잔여 0.
- 원래 tenant/store 각 1행 유지. store legal_entity_id NULL 1, merchant NULL 0.
- git status --porcelain 출력 없음; git diff --exit-code = 0.

이 종료 검증은 모든 application business row의 before/after checksum을 대조한 전수 데이터 비교는 아니다. 테스트 transaction 롤백과 사용한 fixture의 비잔존, 함수 무변경, 저장소 무변경을 확인한 것이다.
````

## §2 Status

```text
Audit evidence only.
```

**처분은 Human 이 정한다.**
