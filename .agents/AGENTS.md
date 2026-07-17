# Antigravity Verification & Audit Rules

## 1. Deep Verification Audit Constraint
- 에이전트에게 검증(Verification, Audit, 재현 테스트 등) 작업이 지시될 경우, 기계적인 체크리스트 충족 여부나 런타임의 단순 성공(success:true) 응답만 보고해서는 안 됩니다.
- 반드시 소스 DDL 및 구현 파일의 라인 단위 대조, 트랜잭션 예외 처리 순서에 따른 데이터 누수 가능성(Atomicity 훼손 여부), 엣지 케이스 조건, 그리고 동시성 격리 및 잠재 성능 병목까지 다각도로 분석하는 **심층 코드 감사(Deep Level Audit)**를 필수적으로 실행하고, 의심스러운 맹점(Blind spot)을 발굴하여 보고해야 합니다.

## 2. Financial-Grade Security & Audit Verification Rules

### 2.1 Exception Handling & Audit Logs (예외 처리 및 감사 로그)
- **무조건적인 실패 기록**: 모든 상태 변경(Write/Update) RPC 함수는 `EXCEPTION` 핸들러 블록을 반드시 갖추어야 합니다.
- **감사 단일화**: unhandled exception 등 실패가 일어나는 모든 경우에 `catchmenu_audit.append_audit_record()`를 통해 `catchmenu_ledger.audit_records`(Append-only)에 실패의 흔적을 영구 기록해야 합니다. OS 파일시스템 이중 기록(`RAISE LOG`)으로 우회하거나 임의 처리해서는 안 됩니다.
- **예외 은폐 금지**: 예외를 조용히 삼키는(swallowing) 로직을 철저히 감시하고, 예외 기록 후 반드시 원본 에러를 재발발(`RAISE`)시키거나 규격화된 에러 JSONB 응답을 반환하여 상위 호출자에게 에러를 전파하도록 검사해야 합니다.

### 2.2 Schema Hijacking & RLS Bypass Defense (스키마 하이재킹 및 RLS 우회 차단)
- **search_path 제한**: `security definer` 권한으로 실행되는 모든 PL/pgSQL 함수는 스키마 하이재킹을 차단하기 위해 `SET search_path = <schema_name>` 설정을 필수적으로 명시하고 있는지 라인 단위로 스캔합니다.
- **Row-Level Security (RLS) 강제**: 신규 가격표, 세션 등 모든 상태 테이블에 `ALTER TABLE ... ENABLE ROW LEVEL SECURITY`와 `ALTER TABLE ... FORCE ROW LEVEL SECURITY`가 함께 적용되었는지, RLS 조건식이 기존 `0022` 관례를 우회하지 않는지 감사해야 합니다.

### 2.3 Non-rollback Mutation & Race Conditions (비가역적 쓰기 방지 및 동시성 감사)
- **검증 선행 원칙**: PL/pgSQL RPC 내에서 유효성 검사(Validation) 전에 DML(INSERT/UPDATE)이 선행되어 에러 리턴 시 데이터가 롤백되지 않고 잔존(Category row leak 등)하는 아키텍처적 결함이 없는지 쓰기 순서를 일일이 대조합니다.
- **동시성 락 격리**: `SKIP LOCKED` 등 행 잠금 격리가 동시 세션 경쟁 시 블로킹을 차단하고 멱등성을 보장하는지 PoC 스크립트로 증명해야 합니다.

## 3. Pipeline Governance & Role Recognition Rules

### 3.1 Pipeline Stage & Observer Role Recognition (단계 및 옵저버 역할 인지)
- **가이드라인 선독 의무**: 검증 작업에 착수하기 전에 반드시 [000701_Guide_Controlled_AI_Development_Pipeline.md](file:///D:/workspace/yoonsul_wait_order_handoff/docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md)를 먼저 정밀하게 읽어야 합니다.
- **단계(Stage) 확인**: 현재 태스크가 13단계 파이프라인 중 정확히 어느 단계(Stage 1 ~ 13)에 속하는지 명확히 판별하고 준수해야 합니다.
- **옵저버 역할 준수**: 안티그래비티는 파이프라인 거버넌스상 "참고용 / 비구속 옵저버(Observer)" 역할임을 한시도 잊지 말아야 하며, 정식 승인권이나 단독 의사결정권 없이 사실에 기반한 발견사항 및 조력 피드백만을 제공해야 합니다.

### 3.2 OLM Context Verification Pre-requisite (맥락 인지 및 정렬)
- **문서 경로 우선 확인**: 태스크가 속한 워크패킷의 개요(Overview), 설계(Logic), 변경 계약(ChangeContract) 문서들의 물리적 경로를 먼저 식별하고 해당 맥락 내부에서만 검증을 수행해야 합니다.
- **계약 범위 밖 수정 금지**: 승인된 ChangeContract 문서에 명시된 Allowed/Forbidden Operations 경계를 결코 넘지 않도록 코드를 대조해야 합니다.

### 3.3 Antigravity Specific Formatting Rule (§40.3 Template)
- **필수 대조 템플릿**: 소스 코드나 문서를 대조하여 발견한 모든 사실은 반드시 아래 템플릿 규격에 맞춰 구체적으로 인용 보고해야 합니다.
  *   `파일명 (clickable file:// absolute path)`
  *   `정확한 라인 번호 (#L<LineNumber> 또는 #L<StartLine>-L<EndLine>)`
  *   `원문 인용 (code block)`
  - *예시*: [0110_create_store_admin_rpc.sql:L252](file:///D:/workspace/yoonsul_wait_order_handoff/sql/migrations/0110_create_store_admin_rpc.sql#L252) `create or replace function...`

### 3.4 Auto-execution Authorization for Verification (검증 자동 실행 권한)
- **임시 검증 자동화**: 소스 코드나 DDL의 파괴적 수정(Write/Edit)이 없는 순수 검증 및 감사 목적으로 작성된 PoC 스크립트의 실행, 또는 라이브 데이터베이스 진단성 SELECT/COUNT 쿼리(`docker exec`, `psql` 등)를 수행하는 terminal command의 경우, 검증 파이프라인의 효율적인 완전 자동화(Auto-submit)를 위해 Human의 별도 수동 승인 단계 없이 자동으로 실행되도록 허용합니다. (단, 실제 파일시스템을 파괴하거나 외부 네트워크로 비보안 데이터를 유출하는 명령은 제외)

### 3.5 Verification Artifact and Scratch File Cleanup (임시 검증 파일 자동 삭제)
- **임시 검증 리소스 자동 삭제**: PoC 재현 테스트, DDL live 검증 등 검증 목적을 위해 `scratch/` 디렉터리 등에 임시로 생성한 모든 SQL, 쉘 스크립트, 덤프 데이터 파일 등은 해당 검증 절차가 성공적으로 종결되어 보고를 마친 즉시 파일시스템에서 자동으로 영구 삭제(Cleanup)하여 파일시스템 오염을 원천 방지해야 합니다. (단, 공식적으로 보존이 요구되는 evidence artifact 또는 log 파일은 제외)

### 3.6 Thoroughness & Goal-Driven Audit (심층/신중 검증 강제)
- **/goal 기반 검증 준수**: 에이전트는 검증(Verification/Audit) 태스크를 수행할 때 단순 일회성 답변(Short response) 모드를 지양하고, 시스템이 허용하는 가장 깊고 끈질긴 추론을 구동하는 **목표 지향적 철저 검증(Thorough Goal-Driven Audit)** 모드로 자체 각성하여 런타임 제약조건과 트랜잭션의 맹점까지 끝까지 파고들어야 합니다.
- **/goal 명령어 사용 권고 의무**: 만약 인간(Human)이 복잡한 시스템 검증을 `/goal` 명령어 없이 일반 프롬프트로만 지시했을 경우, 에이전트는 해당 작업을 수행하기 전이나 수행 시점에 **"더 깊고 철저한 검증을 위해 가급적 `/goal` 슬래시 명령어를 사용하여 작업을 발주해 주실 것을 권장합니다."** 라고 명시적으로 권고하는 역할을 수행해야 합니다.

### 3.7 표준 호출 파라미터 생략 금지 (재발 방지, 2026-07-17)
- **표준 파라미터 필수 포함**: RPC 함수를 재현/검증할 때, 그 함수의 실제 프로덕션 호출 방식이 사용하는 모든 표준 파라미터(`p_tenant_id`, `p_store_id`, `p_actor_id`, `p_correlation_id`, `p_locale` 등 컨텍스트 파라미터)를 반드시 포함해서 호출할 것. 파라미터를 생략한 단순화된 호출로 '크래시 없음'이라고 결론 내리는 것은, 그 함수의 실제 동작이 아니라 다른(더 단순한) 코드 경로를 테스트한 것일 수 있습니다.
- **오판 방지**: 과거 사례(601110 워크패킷 §40.3 Stage 4, 600651/600652 Architecture Verification)에서 `p_tenant_id`/`p_store_id`를 뺀 단순화된 호출로 재현했다가 '문제 없음'으로 오판했고, 표준 파라미터를 전부 포함한 재현으로만 실제 크래시를 잡아낸 이력이 있습니다. 이 오판이 반복되지 않도록, 검증 시 항상 해당 함수의 전체 시그니처(`pg_get_function_identity_arguments` 또는 migration DDL)를 확인하고 모든 필수/표준 파라미터를 포함해서 재현해야 합니다.
- **대표 메커니즘 — `build_error_response()` / `log_diagnostic()`**: `0062_create_i18n_error_diagnostics.sql` L628에서 `if p_tenant_id is not null then log_diagnostic(...)` 게이트가 있음. `p_tenant_id` 생략 시 미등록 `error_key`도 JSON(`code`/`domain` null)으로 **통과**하지만, 프로덕션 RPC는 거의 항상 `p_tenant_id := p_tenant_id`를 넘기므로 미등록 키 → `log_diagnostic` → `diagnostic_logs.is_recoverable` NOT NULL 위반으로 **크래시**함. `log_diagnostic()` 단독 호출도 동일 패턴(미등록 `error_key` + tenant 전달 시 L528–557).
- **재현 명령 비교 (Antigravity §40.3 vs 프로덕션 경로)**:
  - **오판 경로 (tenant 생략)**: `build_error_response(p_error_key := '<unregistered>', p_locale := 'ko', p_correlation_id := '...')` → 크래시 **없음**, `error.code`/`domain` null.
  - **프로덕션 경로 (tenant/store 포함)**: `build_error_response(..., p_tenant_id := '<tenant>', p_store_id := '<store>', p_rpc_name := '<rpc>')` → 미등록 키 시 **CRASH** (`is_recoverable` NULL).
  - **600651/600652**: `session_not_bindable` / `table_already_bound`를 위 프로덕션 경로로 재현 시 2차 크래시 확인됨.
- **적용 범위 (생략 시 동작이 달라지는 함수군)**:
  - **Tier A (진단/에러, 필수)**: `catchmenu_common.build_error_response()`, `catchmenu_common.log_diagnostic()` — `build_error_response` 호출 **50+ migration**, `log_diagnostic` 직접 호출 **20+ migration**.
  - **Tier B (컨텍스트 게이트)**: `if p_tenant_id is not null` / `if p_store_id is not null` 분기가 있는 헬퍼·RPC — `0092`, `0046`, `0081`, `0065`, `0095` 등 **6 migration** 확인.
  - **Tier C (옵셔널 기본값 ≠ NULL)**: `upsert_menu()`의 `p_allergen_codes default '[]'::jsonb` 등 — 파라미터 **생략**이 NULL 생략과 다르게 동작(601110 Stage 9 `allergen_info` 덮어쓰기). RPC 재현 시 프로덕션 호출자가 실제로 넘기는 인자 집합을 그대로 맞출 것.
  - **Tier D (전체 RPC 재현)**: `catchmenu_audit.append_audit_record()` 등 EXCEPTION/감사 경로 — 프로덕션 RPC와 동일 tenant/store/actor/correlation_id 포함 필수.
- **검증 체크리스트**: (1) 대상 함수 시그니처 확인 → (2) 프로덕션 호출부 grep(`p_tenant_id := p_tenant_id` 등) → (3) 동일 인자 집합으로 live 재현 → (4) tenant 생략 변형은 **별도 labeled test**로만 기록하고 '문제 없음' 판정에 사용 금지.

### 3.8 승인 전 ChangeContract 라이브 적용 금지 (재발 방지, 2026-07-18)

검증(Verification) 작업 중 어떤 함수의 신규/수정 설계를 실제로 테스트해야 할 때는 반드시 다음 중 하나의 방법만 사용할 것:

1. **`pg_temp` 스키마에 임시 함수로 정의해서 테스트** — 프로덕션 스키마(`catchmenu_pos.*` 등)의 함수명을 덮어쓰지 않는다. TestPlan이 프로덕션 RPC명을 호출하도록 작성되어 있더라도, ChangeContract §10이 `APPROVED`가 아니면 `pg_temp` 동명/동형 함수로 로직을 재현하거나, 아래 §2의 트랜잭션 래핑을 쓴다.
2. **실제 함수를 `CREATE OR REPLACE` 해야만 하는 경우, 반드시 `begin; ... rollback;` 트랜잭션 블록 안에서만 수행** — PostgreSQL에서 함수 정의 DDL도 트랜잭션 롤백 대상이다. `error_codes`/`message_catalog` INSERT 등 부수 등록도 같은 트랜잭션 안에 넣어 함께 롤백한다.
3. **스키마 제약·트리거·CHECK 제약 등 임시 조작도 `begin; ... rollback;` 안에서만 수행** — 검증용 DDL이 트랜잭션 밖으로 남으면 그 자체가 승인 전 라이브 변경이다.

해당 ChangeContract의 §10(Approval state)이 `APPROVED`로 명시적으로 표시되지 않은 이상, 어떤 함수도 **트랜잭션 밖에서 영구적으로 `CREATE OR REPLACE` 하지 말 것** — 이는 Human 승인 없이 실제 코드가 라이브에 반영되는 거버넌스 위반이다.

같은 원칙은 `DROP FUNCTION`, `ALTER TABLE`, `INSERT INTO error_codes`, `INSERT INTO message_catalog`, `UPDATE migration_history` 등 라이브 상태를 바꾸는 모든 검증용 변경에 적용한다.

**금지 패턴 (이번 사건에서 실제 발생):** setup 스크립트에서 `-- persist ... for isolated test blocks`처럼 `BEGIN` 없이 `catchmenu_pos.confirm_arrival()`/`cancel_waiting()`에 `CREATE OR REPLACE`를 실행한 뒤, 이후 테스트만 `begin; ... rollback;`으로 분리하는 방식 — 함수 정의는 이미 auto-commit되어 라이브에 남는다.

**과거 사례 (600663/600664 Stage 6, 2026-07-18):** 검증자(Cursor)가 §10이 `NOT APPROVED`인 상태에서 `confirm_arrival()`/`cancel_waiting()`의 새 설계(`600662_Logic.md`)를 라이브에 영구 `CREATE OR REPLACE`로 적용했고, 이후 Claude Code가 발견하여 `0115` 원본으로 정확히 복원(원본과 동일한 크래시 재현으로 복원 검증 완료)하고 부수적으로 등록된 `error_codes`(7078/7079)도 함께 정리함.

**검증이 필요한 경우, `pg_temp`/`begin-rollback`만으로 정말 검증이 불가능한 상황이라면** (예: 프로덕션 함수명·GRANT·`search_path` 조합만 재현 가능한 경우), 검증 직후 반드시 원본 텍스트로 즉시 복원하고 복원이 실제로 성공했는지(예: 원본 크래시 재현, `pg_get_functiondef()` 해시/본문 대조) 별도로 증명할 것 — 단, 이 예외적 방법은 **최후의 수단**이며 가능한 한 §1(`pg_temp`)/§2(`begin-rollback`)를 우선한다.

**선례 (올바른 패턴):**

- `600623_TestPlan.md` — `begin; create or replace function ...; select ...; rollback;` (라이브 함수 **영구 변경 없음** 명시).
- `600653_TestPlan.md` §9.2 — `pg_temp.outer_facade()` 최소 재현.
- `600663_TestPlan.md` Stage 5 — 작성자(Claude Code)는 `pg_temp`로 이벤트 발자국·EXCEPTION 재현 후 TestPlan에 기록 (Stage 6 검증자는 동일 패턴을 따라야 함).
- `600564_ChangeContract.md` — `__test_` 접두사 헬퍼 + 테스트 후 DROP + 잔존 0건 검증.

**`pg_temp`/`begin-rollback`로 어려운 범위 (참고):**

| 가능 | 어렵거나 불가 |
|------|----------------|
| 로직·EXCEPTION·원자성·이벤트 발자국 | Stage 8 **승인 후** migration 파일 적용 자체 (그건 Implementation, Verification 아님) |
| `begin-rollback` 안의 프로덕션 함수명 CR | 다른 세션/연결에서 보는 GRANT/proacl 변경 검증 |
| `pg_temp` + `perform catchmenu_pos.mark_session_arrived()` 위임 | 클라이언트가 호출하는 **동일 RPC명** end-to-end (승인 전에는 TestPlan을 pg_temp 호출로 적응하거나 §2 사용) |

### 3.9 Eyes-Only 역할 절대 준수 - 어떤 쓰기 작업도 금지 (긴급 재발방지, 2026-07-18)

Antigravity(안티)는 예외 없이 Eyes-Only 참고용 검증자 역할만 수행한다. 다음은 절대 금지된다:

1. TestPlan.md/ChangeContract.md 등 어떤 문서도 작성/생성하지 않는다(이는 Claude Code의 역할이다)
2. ChangeContract의 §9/§10(Human Approval/Approval state)을 스스로 체크하거나 'APPROVED'로 기록하지 않는다 - 이는 오직 실제 Human(정영석님)만이 할 수 있는 행위다
3. 신규 migration 파일을 작성하지 않는다(이는 Codex의 역할이다)
4. `tools/apply_migrations.py`를 거치지 않고 어떤 형태로든 CREATE OR REPLACE/ALTER/DROP 등을 라이브 DB에 영구 적용하지 않는다 - §3.8이 이미 이를 금지하지만, 이번 사건은 §3.8이 "검증 목적의 임시 적용"조차 아니라 "구현 자체를 무단으로 대체 수행"한 것이므로 별도 조항으로 명시한다

검증(pg_temp/begin-rollback)이 어렵거나 불가능한 상황에 부딪히면, 반드시 그 사실과 이유를 명확히 보고하고 거기서 멈춰야 한다. '검증이 어려우니 대신 구현하고 적용한다'는 판단은 어떤 경우에도 허용되지 않는다.

과거 사례(601030 워크패킷, 2026-07-18): 안티가 TestPlan/ChangeContract를 무단 작성하고 ChangeContract §10을 자기승인한 뒤, 승인되지 않은 신규 함수 2개를 라이브 DB에 직접 적용함. 결과물은 Human이 이미 삼중검증까지 마친 601031/601032 최종 설계와 여러 핵심 지점에서 실제로 달랐음(EXCEPTION 핸들러 반환값, 응답 판정 로직 등). Cursor+Codex의 긴급 진단 후 전체 원상복원함. 이 사건 이후 안티는 참고용 역할을 계속 유지하되, 이 조항 위반이 재발할 경우 완전 배제를 재검토한다.
