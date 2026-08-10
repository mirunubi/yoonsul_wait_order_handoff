# 601505_ChangeContract_Operational_Authority_Foundation_Ddl.md

Status: **v3** (사전 게이트를 마이그레이션별로 분리 — `0169` 착수 게이트 신설)
Lifecycle: ChangeContract
Stage: 5 (Contract Drafting — Claude Code, `000701` §3 L253)
Domain: Operational Authority Foundation (0단계 / 하위 나선 0-A)
Last Updated: 2026-08-09

## Change ID

`operational_authority_foundation_ddl`

## §0 계약 요약

0단계 하위 나선 0-A의 **DDL만** 적용한다. 신규 테이블 4개와 신규 컬럼 3개를 **가법적으로** 추가하고,
그 외 어떤 기존 객체도 건드리지 않는다.

**한 줄 경계**: 이 워크패킷은 **구조를 만들 뿐, 그 구조를 쓰는 코드는 하나도 만들지 않는다.**

> ### ⚠️ 이 문서를 다음 버전으로 갱신할 때의 필수 원칙 (v3 신설)
>
> **마이그레이션을 추가할 때마다(`0169`, `0170`, …), 그 마이그레이션 착수 **직전의 정확한 DB 상태**를
> 사전 게이트(§6)에 **새로 적어야 한다.** 앞선 마이그레이션의 게이트를 재사용하지 말 것.**
>
> 이유: 사전 게이트는 *"지금 적용하려는 변경이 아직 없는 상태"* 를 기술한다.
> `0168`이 적용된 뒤 `0168`의 게이트를 그대로 돌리면 **이미 적용된 변경을 "있으면 안 되는 것"으로 판정**해
> **정상 상태에서 Stop이 발동**한다. 실제로 `0169` 착수 시 이 문제가 발생했다(§6.1.1).
>
> 갱신 시 체크: ① 새 게이트 절 신설(§6.N) ② 이전 게이트는 "통과 완료, 재실행 금지"로 표시
> ③ 실측값으로 기대치를 채울 것(문서에서 추정하지 말 것).

### §0.2 개정 이력

| 버전 | 변경 | 근거 |
|---|---|---|
| 원안 | 신규 테이블 4 + 컬럼 3, `0168` 단독. **모든 GRANT 금지** | Stage 5 |
| **v2** | **`0169` 범위 추가**(§1.5) — SOLE 부분 UNIQUE + `catchmenu_authority_owner` role/GRANT. §2.1의 GRANT 금지를 **"클라이언트 도달 가능 역할" 기준으로 정밀화**(§2.1.1 예외). §6.4 `BYPASSRLS` Stop Condition 신설 | `601510`(Stage 11B) 조건 ①③ + **Human 승인 2026-08-10** |
| **v3** | **사전 게이트를 마이그레이션별로 분리** — 기존 §6.1(0168 기준)을 **§6.0(통과 완료·재실행 금지)** 으로 보존하고, **§6.1을 `0169` 착수 게이트로 신설**(2026-08-10 실측 기준 12항목 + 검증 쿼리). 서두에 **재발방지 원칙** 추가 | `0169` 착수 시 오발동한 Stop(§6.1.1, `TEST_SCOPE_ERROR`) |

**대상 마이그레이션 2개**:

| 파일 | 상태 | 내용 |
|---|---|---|
| `0168_create_operational_authority_foundation.sql` | **적용 완료**(2026-08-09), Stage 9 검증 통과 | 신규 테이블 4 + 컬럼 3 |
| **`0169_authority_owner_role_and_sole_representative_uniqueness.sql`** | **미작성** — Stage 8 대기 | SOLE 부분 UNIQUE + 전용 owner role (§1.5) |

| 항목 | 값 |
|---|---|
| 설계 원본 | `601501_ERD` v4 (충돌 시 ERD 우선) |
| 맥락 | `601502_Overview` v4 |
| 상세 설계 | `601503_Logic` v4 |
| 검증 계획 | `601504_TestPlan` |
| 후속 워크패킷 | **0-A-2(필수 다음 착수 — §8A)**, 0-A-3(`onboard_tenant`/`provision_tenant` 재설계) |

### §0.1 `isolate_tenant()` 의도적 장애 — 안전장치 5가지 색인

Human 최종 승인(2026-08-09): **"DDL만 진행하고, `isolate_tenant()`는 0-A-2까지 의도적 장애 상태로 둔다."**

이 결정은 "실호출자 0건이니 괜찮다"에 기대지 않는다. 실호출자 0건은 **현재 시점의 관측**일 뿐이므로,
아래 5가지 안전장치로 **관측을 계약으로 바꾼다**.

| # | 안전장치 | 위치 | 무엇을 막는가 |
|---|---|---|---|
| ① | 호출 금지 단정 | **§4.1.1** | "어떤 경로로도 호출 금지" — 애매한 권고가 아닌 금지. **간접 경로 2개 함수/3지점**(`manage_subscription` 0112, **`detect_threat` 0121**) |
| ② | 병합 직전 최종 재확인 게이트 | **§7.1** | 확인 시점과 적용 시점 사이에 생긴 호출자 |
| ③ | 신규 호출자 배포 금지 | **§4.5** | 0-A~0-A-2 기간 중 봉인이 조용히 무력화되는 것 |
| ④ | 0-A-2를 다음 필수 워크패킷으로 지정 | **§8A** | 부채가 무기한 이월되는 것 |
| ⑤ | 운영 안내(버그 아님 명시) | **§8B** | 미래의 누군가가 23514를 보고 즉석 수정하는 것 |

> ①③⑤가 함께 작동해야 의미가 있다. ①만으로는 잊히고, ③이 없으면 새 코드가 뚫고,
> ⑤가 없으면 오류를 본 사람이 CHECK에 `'ISOLATED'`를 추가해 **2컬럼 분리 자체를 되돌린다.**

---

## §1 Allowed — 허용 대상

### §1.1 허용 파일

**신규 마이그레이션 파일 1개**만 생성한다.

- 위치: `sql/migrations/`
- 번호: `000005_Index_Document_Number.md` 및 기존 마이그레이션 최대번호 기준 **다음 빈 번호**
  (구현 시점에 확정 — 번호 충돌은 `000701`이 반복 지적해 온 결함이므로 반드시 사전 확인)
- 성격: **DDL 전용**. `CREATE OR REPLACE FUNCTION`을 **한 줄도 포함하지 않는다**.

**기존 마이그레이션 파일은 단 한 개도 수정하지 않는다** — 배포된 migration 수정 금지 원칙(§49.2).

### §1.2 허용 DDL — 신규 테이블 4개

| # | 객체 | 스키마 |
|---|---|---|
| 1 | `owners` | `catchmenu_hq` |
| 2 | `legal_entities` | `catchmenu_hq` |
| 3 | `legal_entity_person_roles` | `catchmenu_hq` |
| 4 | `legal_entity_representatives` | `catchmenu_hq` |

각 테이블에 딸린 것만 함께 허용:
PK / FK / **인라인 CHECK**(§6.1 멱등성) / 부분 UNIQUE 인덱스 / 보조 인덱스 /
생성컬럼(`brn_normalized`, `crn_normalized`) / `set_updated_at` 트리거 / `comment on` /
`enable row level security` + `force row level security`.

### §1.3 허용 DDL — 신규 컬럼 3개

| # | 대상 | 컬럼 | 형태 |
|---|---|---|---|
| 1 | `catchmenu_hq.tenants` | `tenant_status` | `text NOT NULL DEFAULT 'TRIAL'` + CHECK 5값 |
| 2 | `catchmenu_hq.tenants` | `isolation_state` | `text NOT NULL DEFAULT 'NONE'` + CHECK 2값 |
| 3 | `catchmenu_hq.stores` | `legal_entity_id` | `uuid` **nullable** + FK + 부분 인덱스 |

`tenants`의 CHECK 2개와 `stores`의 FK 1개는 **`pg_constraint` 가드 안에서** 추가한다(§6.2).

### §1.4 허용 동사 (narrow verbs)

```text
create table if not exists          (신규 4테이블만)
alter table ... add column if not exists   (신규 3컬럼만)
alter table ... add constraint      (pg_constraint 가드 내부에서만, CHECK 2 + FK 1)
create index / create unique index if not exists
create trigger  (drop trigger if exists 선행, 신규 4테이블의 set_updated_at만)
alter table ... enable/force row level security   (신규 4테이블만)
comment on table / column           (신규 대상만)
```

이 목록에 없는 동사는 전부 §4 Forbidden이다.

---

### §1.5 ⭐ `0169` 허용 범위 (v2 신설 — Stage 11B BLOCK 조건 ①③, Human 승인 2026-08-10)

`0168`은 **이미 적용됐으므로 수정하지 않는다**(배포된 migration 불변 원칙).
Stage 11B 보강은 **신규 파일 `0169` 단독**으로 수행한다.

**파일(안)**: `sql/migrations/0169_authority_owner_role_and_sole_representative_uniqueness.sql`

| # | 허용 항목 | 조건 | 멱등성 |
|---|---|---|---|
| 1 | `uq_ler_sole_active` **부분 UNIQUE 인덱스** — `legal_entity_representatives (legal_entity_id) WHERE representation_mode='SOLE' AND is_active=true` | ③ | `create unique index **if not exists**` |
| 2 | `catchmenu_authority_owner` **role 생성** — `NOLOGIN` + **`BYPASSRLS`** | ① | `pg_roles` 존재 가드(`DO` 블록) |
| 3 | 위 role에 `catchmenu_hq` **스키마 USAGE** | ① | `grant`는 반복 실행 무해 |
| 4 | 위 role에 **신규 4테이블 `SELECT/INSERT/UPDATE/DELETE`** | ① | 동상 |
| 5 | **`grant catchmenu_authority_owner to postgres`** (향후 `ALTER FUNCTION … OWNER TO` 수행에 필요한 멤버십) | ① | 동상 |

**허용 동사 추가**(§1.4에 대한 0169 한정 확장):

```text
create role … nologin bypassrls   (pg_roles 가드 내부에서만)
grant usage on schema …           (catchmenu_authority_owner 대상만)
grant select, insert, update, delete on <신규 4테이블>   (catchmenu_authority_owner 대상만)
grant <role> to postgres          (catchmenu_authority_owner 대상만)
create unique index if not exists (uq_ler_sole_active 하나만)
comment on role                   (선택)
```

**적용 순서**: 1(인덱스) → 2(role 가드) → 3·4·5(GRANT) → comment.
`0169`에는 `ADD COLUMN`이 없으므로 §49.2의 컬럼 선행 규칙은 해당 사항이 없다.
워크패킷 간 순서는 유지된다: `0168` → **`0169`** → 0-A-2(RPC) → 0-C(함수·정책).

#### §1.5.1 `0169`가 **하지 않는** 것 (조건 ②는 0-C 소관)

| 하지 않음 | 이유 |
|---|---|
| **함수 생성** | **0-A에는 함수가 하나도 없다.** 본 워크패킷은 DDL 전용 |
| **`ALTER FUNCTION … OWNER TO`** | 대상 함수가 없다 → 0-C가 함수를 만들 때 수행 |
| **`REVOKE … FROM PUBLIC` / `GRANT EXECUTE`** | 동상 |
| **`SET search_path` 고정** | 동상 |
| **함수 내부 tenant 경계 검증 구현** | 동상 |
| 기존 4테이블 **소유권 이전**(`ALTER TABLE … OWNER TO`) | 0169 범위 밖. 테이블 소유자는 `postgres` 유지, 접근은 GRANT로 |
| `0168` 수정 | 배포된 migration 불변 |

> **조건 ②(search_path / PUBLIC EXECUTE / tenant 경계)는 0169에서 이행할 수 없다** —
> 대상이 되는 함수가 존재하지 않기 때문이다. 대신 **0-C의 필수 규칙으로 명문화**되어 있다:
> `601503` **§9**(필수 6항목·표준 골격·CI 검증 쿼리 3종), `601501` §2.7.6.
> **0-C가 이 규칙을 지키지 않으면 조건 ②는 미충족 상태로 남는다.**

## §2 명시적 설계 결정 — 계약 조항

### §2.1 신규 4테이블에 **클라이언트 도달 가능 역할의 GRANT를 부여하지 않는다** (v2 정정)

> **v2 변경(2026-08-10)**: 원안 제목은 "**어떤** GRANT도 부여하지 않는다"였으나,
> Stage 11B 조건 ①에 따라 **함수 전용 소유자 role 하나에 대한 예외**가 생겼다(§2.1.1).
> 금지의 **취지는 그대로**다 — 바뀐 것은 대상 범위의 정밀화이지 완화가 아니다.

`owners` / `legal_entities` / `legal_entity_person_roles` / `legal_entity_representatives`에 대해
**`authenticated` · `service_role` · `anon` 등 클라이언트가 될 수 있는 어떤 역할에도**
`SELECT`/`INSERT`/`UPDATE`/`DELETE`/`ALL`을 부여하지 않는다.

**근거**: 0-A는 구조 확정까지이며, 이 테이블을 읽고 쓰는 RPC는 후속 워크패킷 소관이다(§47.6-1).
접근이 필요해지는 시점에 최소 권한만 부여하는 것이 순서다. 지금 GRANT를 주면 "쓰는 곳이 없는데
열려 있는 테이블"이 생기고, 0-C가 접근제어를 설계할 때 **이미 열린 문을 닫는 작업**부터 해야 한다.

#### §2.1.1 ⭐ 유일한 예외 — `catchmenu_authority_owner` (Human 승인 2026-08-10)

| 항목 | 값 |
|---|---|
| 역할명 | `catchmenu_authority_owner` |
| 속성 | **`NOLOGIN`** + **`BYPASSRLS`** |
| 부여 범위 | `catchmenu_hq` 스키마 `USAGE` + 신규 4테이블 `SELECT/INSERT/UPDATE/DELETE` + `postgres`에 역할 멤버십 |
| 근거 | `601510`(Stage 11B) **조건 ①** — SECURITY DEFINER 소유자를 전용 NOLOGIN role로 고정 |
| 이행 | **`0169`** (§1.5) |

**왜 §2.1의 금지에 저촉되지 않는가**:

- 이 역할은 **`NOLOGIN`이다.** PostgREST·JWT·클라이언트 어느 경로로도 **이 역할이 될 수 없다.**
- 금지의 목적은 *"클라이언트가 base table에 직접 도달하는 것"* 을 막는 것이며,
  로그인 불가 역할에는 그 위험이 존재하지 않는다.
- **현행보다 권한이 좁아진다** — 지금은 함수가 `postgres`(슈퍼유저급) 권한으로 돌지만,
  0169 이후에는 `catchmenu_hq` 4테이블로 범위가 한정된 전용 역할로 돈다.
  또한 소유권이 "관행"이 아니라 **migration에 명시**된다.

> **`BYPASSRLS`가 필수인 이유**: §6.4 및 `601503` §2.9.3 참조. 이것이 빠지면
> **함수가 오류 없이 0행을 반환**한다(로컬 실측 확인).

**검증**: `601504` §3.1의 GRANT 0행 확인은 이제
**`grantee NOT IN ('postgres', 'catchmenu_authority_owner')`** 기준으로 수행한다.
그 외 grantee가 1행이라도 있으면 계약 위반이다.

### §2.2 RLS 정책(policy)을 만들지 않는다

`enable`+`force`만 걸고 정책은 만들지 않는다. 이는 이 저장소 **최초의 "force RLS + 정책 0개" 사례**이며
(0021은 0022가 정책을 붙이는 짝 구조다), **의도된 신규 설계 결정**이다(`601501` §2.7.2).
정책식 설계는 0-C 소관이다.

### §2.3 ⚠️ 배포 전제 조건 — `SECURITY DEFINER` 함수 소유자 (Open Item (o))

> **v2 갱신(2026-08-10)**: 아래 원안은 *"소유자를 `postgres`로 유지"* 를 전제로 삼았다.
> Stage 11B 조건 ①에 따라 **목표 소유자가 `catchmenu_authority_owner`로 바뀐다**(§2.1.1).
> `0169`가 역할을 신설하고, **실제 소유권 이전은 함수가 생기는 0-C에서 수행**한다(§1.5.1).
> 그때까지는 아래 원안(=`postgres` 소유)이 여전히 현행 상태이며, 원안의 위험 분석도 그대로 유효하다.
> 최종 규칙은 `601503` §9.1(필수 6항목)이 정의한다.

§2.1에 따라 GRANT를 주지 않으므로, **이 4개 테이블의 유일한 접근 경로는
`postgres` 소유의 `SECURITY DEFINER` 함수뿐**이다.

**확인된 사실**(`601503` §2.8.4):

| 확인 대상 | 결과 |
|---|---|
| `sql/migrations/*.sql`의 명시적 소유자 지정(`owner to postgres`) | **0건** |
| 클라우드 백업 덤프의 `ALTER FUNCTION ... OWNER TO "postgres"` | 623건 |

즉 **소유자를 고정하는 선언이 코드에 없다.** 현재 `postgres` 소유인 것은 "마이그레이션을 `postgres`로
실행해 왔다"는 **운영 관행의 결과**일 뿐 계약이 아니다.

**계약 조항**:

1. 본 마이그레이션은 **`postgres` 역할로 실행**되어야 한다(신규 테이블의 소유자가 `postgres`가 되도록).
2. 후속 워크패킷이 이 테이블을 쓰는 RPC를 만들 때, 그 함수의 소유자가 `postgres`인지 확인해야 한다.
3. 이 전제가 깨지면 **오류가 아니라 조용히 "아무도 못 쓰는 테이블"** 이 된다 — 실패가 눈에 띄지 않는
   유형의 사고이므로 `601504` §4.1이 명시적으로 소유자를 확인한다.

**미해결로 남기는 것**: "소유자를 `postgres`로 유지한다"를 코드로 명문화할지 여부는 배포 정책 판단이며
본 워크패킷 범위 밖이다 — Open Item (o)로 이월한다.

### §2.4 백필하지 않는다

`stores.legal_entity_id`는 DDL 적용 시점에 **전 행 `NULL`로 둔다**.
백필은 시드 `legal_entities` 행 생성 시점에 수행한다(`601503` §4.2).

### §2.5 `NOT NULL` 승격은 이번에 하지 않는다

`stores.legal_entity_id`의 `NOT NULL` 승격 판정은 **5단계 말미**로 이관한다(Open Item (h)).
승격은 **가법적이지 않으므로**(`stores`에 INSERT하는 기존 RPC가 이 컬럼을 채우지 않으면 즉시 실패)
**`stores` INSERT 경로 전수 조사가 선행**돼야 한다. 조사 없이 승격하지 않는다.

---

## §3 Allowed Operations (좁은 동사)

| 허용 | 대상 |
|---|---|
| 신규 테이블 4개 생성 | §1.2 목록 그대로 |
| 신규 컬럼 3개 추가 | §1.3 목록 그대로 |
| 위 대상에 딸린 제약·인덱스·트리거·주석·RLS 활성화 | §1.2/§1.3 |
| `601504` 실행을 위한 **임시**(`pg_temp`) 프로브 함수 | 트랜잭션 내에서만, 반드시 rollback/drop |
| 문서 갱신 | `000005`/`000007` 등록, `601500` 폴더 내 문서 |

### §3.1 적용 순서 (§49.2 — 위반 시 반려)

1. `legal_entities` → 2. `owners` → 3. `legal_entity_person_roles` → 4. `legal_entity_representatives`
→ 5. `tenants` 컬럼 2개 + CHECK(가드) → 6. `stores.legal_entity_id` + FK(가드) + 인덱스
→ 7. RLS enable/force(**GRANT 없음**) → 8. `comment on` / 트리거

`ADD COLUMN`은 어떤 `CREATE OR REPLACE FUNCTION`보다 먼저다 — 본 워크패킷은 함수를 만들지 않으므로
이 순서는 **워크패킷 간 순서**로 확장된다: 본 워크패킷 → 0-A-2 → 0-A-3.

---

## §4 Forbidden Operations — 금지 (위반 시 즉시 반려)

### §4.1 기존 RPC 수정 금지

**다음 파일의 어떤 함수도 수정하지 않는다**:

| 파일 | 왜 건드리고 싶어지는가 | 왜 금지인가 |
|---|---|---|
| `0082_create_saas_billing_rpc.sql` | `provision_tenant`이 phantom 컬럼에 INSERT | **0-A-3 소관** |
| `0090_create_multitenant_isolation_rpc.sql` | `isolate_tenant`이 `tenant_status`를 덮어씀 | **0-A-2 소관** |
| `0112_create_hq_admin_rpc.sql` | `tenant_status` 21개 지점 + `onboard_tenant` | **0-A-2/0-A-3 소관** |
| `0120_create_reconciliation_pipeline.sql` | `sql_command` 내 `tenant_status='ACTIVE'` 필터 | **0-A-2 소관** |
| `0123_create_ai_customer_center_v2.sql` | 동상(L636) | **0-A-2 소관** |
| `0129_create_launch_readiness_package.sql` | 동상(L873–885, L885) | **0-A-2 소관** |

**금지 근거**: DDL과 RPC 재작성을 한 마이그레이션에 섞으면 §49.2 순서 요건이 파일 내부 순서 문제로 숨고,
실패 시 "스키마 문제인가 로직 문제인가"를 분리할 수 없다(`601502` §3.2).

#### §4.1.1 ⚠️ `isolate_tenant()` 의도적 장애 상태 — 안전장치 ① (Human 최종 승인, 2026-08-09)

`0090`의 `catchmenu_common.isolate_tenant()`는 본 DDL 적용 후 **CHECK 위반(23514)으로 실패한다**
(`v_new_status`가 계산하는 `'ISOLATED'`가 `chk_tenants_status`의 허용 5값에 없다 — 0090 L1283–1295).

**이 함수는 0-A-2 완료 전까지 어떤 경로로도 호출되어서는 안 된다.**

"경로"에는 예외가 없다 — RPC 직접 호출, 다른 함수를 통한 간접 호출, 관리자 화면, 배치,
수동 SQL, 테스트 스크립트 전부를 포함한다.

**알려진 간접 호출 지점 — SQL 함수 3곳 / 2개 함수**(라인 직접 확인, 2026-08-09):

| # | 호출 함수 | 파일·라인 | 호출 지점 | 인자 |
|---|---|---|---|---|
| 1 | `manage_subscription()` **SUSPEND** 분기 | 0112 L592–606 | **L600–606** | `p_isolate := true` → `'ISOLATED'` 기록 시도 |
| 2 | `manage_subscription()` **ACTIVATE** 분기 | 0112 L608–619 | **L616–620** | `p_isolate := false` → `'ACTIVE'` 기록(**CHECK에 안 걸림** — §4.5.1) |
| 3 | **`detect_threat()`** | **0121 L872–882** | **L876–882** | `p_isolate := true`, FATAL 위협 시 자동 격리 |

**3번 `detect_threat()`(0121)은 사전 게이트에서 뒤늦게 발견된 경로다.**
`p_threat_severity = 'FATAL'`이고 `p_tenant_id`가 있을 때 **테넌트를 자동 격리**한다 — 즉
사람이 의도적으로 호출하지 않아도 **보안 이벤트가 트리거하는 경로**다.
`manage_subscription()`과 **동일한 금지가 그대로 적용된다.**

> **현재 상태**: `detect_threat()`도 실호출자 0건(dormant)이다 — 0121 보안 파이프라인 전체가
> 인프라만 깔리고 실제 연동되지 않았다. 또한 §4.1.2의 파라미터명 불일치로 **호출 자체가 이미 깨져 있다.**
> 그러나 이는 **우연한 방벽**이지 설계된 보호가 아니다. 금지는 방벽의 존재와 무관하게 유효하다.

> **⚠️ 이 목록이 완전하다고 단정하지 않는다.** 3번은 v4 계약 작성 시점에 **누락됐다가 게이트에서 발견됐다.**
> 같은 누락이 또 있을 수 있으므로, §7.1의 재확인은 **매번 grep을 새로 실행**해야 하며
> 이 표를 근거로 생략할 수 없다.

#### §4.1.2 ⚠️ 세 호출부 전부 파라미터명이 틀려 있다 (신규 발견)

`isolate_tenant()`의 **실제 시그니처**(0090 L1256–1263):

```sql
catchmenu_common.isolate_tenant(
  p_tenant_id        uuid,
  p_isolation_reason text,                 -- ← 기본값 없음 = 필수 인자
  p_isolate          boolean default true,
  p_actor_id         uuid    default null,
  p_locale           text    default 'ko'
)
```

**그런데 위 3개 호출부가 전부 `p_reason :=`을 쓴다** — 존재하지 않는 파라미터명이며,
필수 인자 `p_isolation_reason`은 전달되지 않는다:

| 호출부 | 전달 인자 | 결과 |
|---|---|---|
| 0112 L600–606 (SUSPEND) | `p_tenant_id`, `p_isolate`, **`p_reason`** | **42883** function does not exist |
| 0112 L616–620 (ACTIVATE) | `p_tenant_id`, `p_isolate`, **`p_reason`** | **42883** |
| 0121 L876–882 (`detect_threat`) | `p_tenant_id`, `p_isolate`, **`p_reason`** | **42883** |

**함의**: `isolate_tenant()`에 실제로 도달해 `23514`를 발생시키려면 **파라미터명을 올바르게 지정한
직접 호출**이어야 한다. 간접 경로 3곳은 그 전에 `42883`으로 죽는다.

이 불일치는 **이번 워크패킷 범위 밖**(0090/0112/0121 수정 금지 — §4.1)이며, Open Item (p)로 기록한다.

**이것은 "실호출자가 0건이니 괜찮다"가 아니다.** 실호출자 0건은 **현재 시점의 관측 사실**일 뿐
장래를 보장하지 않는다. 계약이 요구하는 것은 관측이 아니라 **금지**다 —
0-A와 0-A-2 사이에 새 호출자가 생기지 않도록 §4.5가 신규 배포까지 함께 막는다.

**이 상태는 버그가 아니라 의도된 임시 배포 상태다.** 상세 운영 안내는 §9A.

> "고쳐야 할 것 같아 보이는" 강한 유혹이 생기는 지점이다 — **고치지 않는다.**
> 고치는 것이 곧 0-A-2이며, 그것은 별도 계약·별도 승인을 받아야 한다.

### §4.2 `franchise_brands` 수정 금지

`catchmenu_hq.franchise_brands`(0085 L123–160) 및 `franchise_policies`/`franchise_kpi_targets` 등
브랜드 축 객체를 **읽는 것 외에 어떤 변경도 하지 않는다**. 브랜드 축은 미래 나선 소관(§47.2).

### §4.3 ⚠️ tenant를 `ACTIVE`로 승격하는 행위 금지

**0-A-2 완료 전까지 어떤 tenant의 `tenant_status`도 `'ACTIVE'`로 설정하지 않는다.**

**금지 근거**(`601502` §4.2, `601503` §5): 컬럼 추가로 `WHERE tenant_status='ACTIVE'` 필터가 문법적으로
유효해진다. `default 'TRIAL'`이므로 지금은 매칭 0건이지만, tenant를 `ACTIVE`로 올리는 순간
대사(reconciliation)/감사패킷/시간별메트릭 배치가 **예고 없이 실제 대상을 갖게 된다**.
게다가 2컬럼 분리로 `ACTIVE`+`ISOLATED`가 표현 가능해졌으므로, 필터에 `AND isolation_state='NONE'`이
보강되기 전에는 **격리된 테넌트까지 배치 대상에 포함**된다.

**적용 범위**: 마이그레이션, 시드 스크립트, 수동 SQL, 테스트 — **예외 없음**.
`601504` §6.2의 직교 조합 테스트는 트랜잭션 안에서 `rollback`으로 종료하므로 이 금지에 저촉되지 않는다.

**해제 조건**: 0-A-2가 §5의 승계 항목을 완료한 후, 별도 Human 판단으로 해제한다.

### §4.4 그 밖의 금지

| 금지 | 이유 |
|---|---|
| 신규 4테이블에 **클라이언트 도달 가능 역할**(`authenticated`/`service_role`/`anon` 등)의 **GRANT 부여** | §2.1 설계 결정. **`catchmenu_authority_owner`는 예외**(§2.1.1 / §1.5) |
| **`catchmenu_authority_owner` 외의 신규 role 생성** | 0169가 허용하는 role은 **이 하나뿐**(§1.5) |
| **`catchmenu_authority_owner`에 `LOGIN` 속성 부여** | 로그인 가능해지는 순간 §2.1의 금지 취지가 무너진다 — **NOLOGIN 필수** |
| 신규 4테이블에 **RLS 정책 생성** | §2.2 — 0-C 소관 |
| `CREATE OR REPLACE FUNCTION` **일체** | 본 워크패킷은 DDL 전용. **0169도 함수를 만들지 않는다**(§1.5.1) |
| **`ALTER FUNCTION … OWNER TO` / `REVOKE … FROM PUBLIC` / `GRANT EXECUTE` / `SET search_path`** | 대상 함수가 존재하지 않는다. **0-C 필수 규칙**(`601503` §9)으로 이월 |
| 기존 4테이블 **소유권 이전**(`ALTER TABLE … OWNER TO`) | §1.5.1 — 0169 범위 밖 |
| `stores.legal_entity_id`를 **NOT NULL로 생성/승격** | §2.5 — 전수 조사 선행 필요 |
| `stores.extra_metadata` / `stores.brand_id` 추가 | 후속/브랜드 나선 소관 |
| `tenants.is_active` 삭제·의미 변경 | 가법 원칙, 진실원천 정리는 0-A-2 |
| `uq_stores_tenant_code`에 `legal_entity_id` 추가 | tenant 단위 유지 선언(`601501` §2.6) |
| `owners.contact_phone_hash`에 UNIQUE 부여 | D-2 판정 — 존재탐지 오라클 |
| 기존 마이그레이션 파일 수정 | 배포된 migration 불변 원칙 |
| `pg_cron_jobs` 행 수정 / `is_registered` 결함 수정 | **0-A-2 승계**(`601503` §5.3) |
| 시드 데이터 실투입 | `601503` §4.1은 **설계**다. 투입 시점은 별도 판단 |
| 대표권 **행간** 정합성 트리거 생성 | Open Item (c) — 후속 소관 |

### §4.5 ⚠️ 신규 호출자 배포 금지 — 안전장치 ③ (0-A ~ 0-A-2 기간 전체)

§4.1.1의 금지가 **시간이 지나며 조용히 무력화되는 것**을 막는 조항이다.
DDL 병합 시점의 "실호출자 0건"은 그 시점의 사실일 뿐이다. 그 사이 누군가 호출자를 추가하면
**계약 문구는 지켜졌는데 장애는 실제로 발생**한다.

**금지 기간**: 본 워크패킷 병합 시점부터 **0-A-2 완료·검증 통과 시점까지.**

**금지 대상 — 아래를 호출하는 어떤 신규 코드도 배포하지 않는다** (라인번호 직접 확인):

| # | 대상 | 위치 | DDL 적용 후 실제 거동 |
|---|---|---|---|
| 1 | `catchmenu_common.isolate_tenant(p_isolate := true)` **직접 호출** | 0090 L1283–1295 | `tenant_status`에 `'ISOLATED'` 기록 시도 → **23514로 시끄럽게 실패** |
| 2 | `manage_subscription()` **SUSPEND** 분기 | 0112 L592–606 | **분기에 도달하지 못한다** — L533에서 먼저 42703(§4.5.1) |
| 3 | `manage_subscription()` **ACTIVATE** 분기 | 0112 L608–619 | **분기에 도달하지 못한다** — 그러나 **잠재(latent) 위험**(§4.5.1) |

#### §4.5.1 ⚠️ `manage_subscription()`은 **현재 모든 분기가 도달 불가**다 — 그러나 ACTIVATE는 잠재 위험이다

**현재 시점의 정확한 사실 (직접 확인)**:

`manage_subscription()`은 `case p_action` 분기(L548)에 들어가기 **전에**, L533에서 테넌트를 조회한다:

```sql
-- 0112 L532-536
-- 테넌트 조회
select id, company_name, tenant_status      -- L533  ← company_name은 phantom
into v_tenant
from catchmenu_hq.tenants
where id = p_tenant_id;
```

`tenants.company_name`은 **존재하지 않는 컬럼**이며(`601501` §4), 이번 워크패킷 범위 밖이다.
따라서 이 SELECT는 실행 시 **`42703 undefined_column`으로 실패**하고,
`SUSPEND`/`ACTIVATE`/`CANCEL`/`UPGRADE` **어느 분기도 도달하지 못한다.**

> **v4 초안 정정**: 앞선 서술은 "ACTIVATE가 DDL 적용 후 즉시 조용히 성공한다"고 적었으나 **부정확했다.**
> 42703이 L533에서 먼저 발생하므로 **지금 당장의 실질 위험은 낮다.**
> 이 정정은 SUSPEND 경로에도 동일하게 적용된다 — SUSPEND 역시 23514가 아니라 **42703으로 먼저 실패**한다.
> **23514가 실제로 발생하는 것은 `isolate_tenant()`를 직접 호출할 때뿐이다.**

**그러나 이것은 잠재(latent) 위험이다 — 사라진 것이 아니다**:

`isolate_tenant()`는 `p_isolate = false`일 때 `v_new_status := 'ACTIVE'`를 계산하며(0090 L1283–1286),
`'ACTIVE'`는 `chk_tenants_status`의 **허용값**이다. 즉 **ACTIVATE 경로에는 CHECK라는 안전망이 없다.**
지금 막고 있는 것은 전부 **우연한 방벽**이다.

**현재 ACTIVATE를 막고 있는 방벽 2겹** (둘 다 설계된 보호가 아님):

| 방벽 | 위치 | 오류 | 성격 |
|---|---|---|---|
| ① `tenants.company_name` phantom | 0112 **L533** (분기 도달 전) | **42703** | 별개의 기존 결함 |
| ② `p_reason` 파라미터명 불일치 | 0112 **L616–620** (분기 내부) | **42883** | §4.1.2 — 별개의 기존 결함 |

방벽 ②의 작동 방식: `perform isolate_tenant(... p_reason := ...)`이 예외를 던지면 **PL/pgSQL 함수 전체가
중단되고 롤백**되므로, L608–613에서 이미 실행된 `update tenants set tenant_status='ACTIVE'`도 **함께 되돌려진다.**
즉 방벽 ①만 제거해도 ACTIVATE는 여전히 `tenant_status`를 남기지 못한다.

**위험이 현실화되는 시점 — 방벽 ①과 ②가 모두 제거될 때**:

두 방벽이 모두 사라지면 ACTIVATE 분기는 **CHECK 위반 없이 조용히 `tenant_status='ACTIVE'`를 기록**하며
(L608–613 직접 UPDATE + L616–620 `isolate_tenant(false)`, **두 번 기록**) §4.3을 위반한다.

> **방벽이 2겹이라는 사실이 안심의 근거가 되어서는 안 된다.** 둘 다 **다른 목적의 결함**이며,
> 그 결함을 고치는 것은 **정상적이고 바람직한 작업**이다 — 즉 두 방벽은 언젠가 반드시 제거된다.
> 특히 방벽 ②는 `p_reason` → `p_isolation_reason` **기계적 일괄 치환**으로 제거되기 쉽고,
> 그 치환은 3개 호출부(§4.1.2)를 **한 번에** 뚫는다.

**가장 위험한 시나리오 — 부분 수정(partial fix)**:

L533은 `manage_subscription()` **내부**에 있으므로 이 함수를 통째로 재작성하는 **0-A-2**가 정상 경로다.
0-A-2는 ACTIVATE 로직도 함께 고치므로 위험이 발생하지 않는다.
**진짜 위험은 "phantom 컬럼만 정리하는" 좁은 수정**이다 — `company_name` 참조만 걷어내고
ACTIVATE 분기의 `tenant_status` 기록은 그대로 두면, **방벽만 제거되고 위험만 남는다.**

**따라서 다음을 0-A-2와 0-A-3 **양쪽의 필수 완료조건**에 추가한다**(§8A):

> **`tenants.company_name` phantom 참조(0112 L533 포함)를 해소하는 어떤 워크패킷도,
> 같은 변경 안에서 ACTIVATE 분기의 `tenant_status='ACTIVE'` 기록 문제를 반드시 함께 해결해야 한다.
> 둘을 분리해서 배포하지 않는다.**

#### §4.5.2 CANCEL 분기

CANCEL 분기(0112 L622–634)는 `'CANCELLED'`(허용값)를 기록하고 `isolate_tenant()`를 **호출하지 않는다**.
방벽이 걷힌 뒤에도 CHECK 위반·§4.3 위반이 없다. 다만 `manage_subscription()` 전체가 0-A-2 재작성
대상이므로 **신규 호출자를 추가하지 않는다**는 원칙은 동일하게 적용한다.

**적용 범위**: SQL 마이그레이션, RPC, Flutter/앱 코드, 관리자 화면, 배치·cron, 운영 스크립트 — **전부**.
"임시로 한 번만", "테스트 목적으로"도 포함한다.

**기존 코드에 대하여**: 현재 실호출자는 0건이며 §7.1이 병합 직전 최종 재확인한다.
이 조항은 **신규 추가를 막는 것**이지 기존 코드를 고치라는 뜻이 아니다 — 수정은 §4.1이 금지한다.

---

## §5 Forbidden Scope — 범위 밖 파일

다음 경로는 **읽기만 허용**하고 변경하지 않는다:

```text
sql/migrations/0001 ~ (현재 최대번호)   -- 전부 (신규 파일 1개만 추가)
catchmenu_app/**                        -- 앱 계층 전체
supabase/config.toml                    -- PostgREST 노출 스키마 (§6 Stop Condition 참조)
docs/ (601500 폴더 및 000005/000007 외)  -- 다른 도메인 문서
```

> `supabase/config.toml`을 수정해 `catchmenu_hq`를 노출하는 것은 **명시적 금지**다 —
> 이는 §2.1/§2.2가 세운 접근 경계를 한 줄로 무너뜨린다.

---

## §6 Stop Conditions — 즉시 중단하고 재승인 받을 것

다음 중 **하나라도** 발생하면 구현을 중단하고, 발견 사실을 기록해 Human 재승인을 받는다.
"작은 차이니 맞춰서 진행"은 금지한다 — 라이브와 설계의 불일치는 이 프로젝트가 반복적으로 당해온 결함 유형이다.

> ### ⚠️ 사전 게이트는 **마이그레이션마다 따로** 있다 (v3 구조 변경, 2026-08-10)
>
> 사전 게이트는 **"그 마이그레이션을 적용하기 직전의 DB 상태"** 를 기술한다.
> 따라서 **마이그레이션이 늘어나면 게이트도 함께 늘어나야 한다** — 앞선 게이트를 그대로 재사용하면
> **이미 적용된 변경을 "있으면 안 되는 것"으로 판정**해 잘못된 Stop이 발동한다.
>
> | 게이트 | 대상 | 상태 |
> |---|---|---|
> | **§6.0** | `0168` 적용 직전 | **통과 완료(2026-08-09)** — 역사적 기록으로 보존, 재실행 대상 아님 |
> | **§6.1** | **`0169` 적용 직전** | **현행 게이트** |

### §6.0 `0168` 사전 게이트 — 이미 통과함 (역사적 기록, 재실행 금지)

> **이 표는 `0168` 적용 **전**의 상태 기준이다. `0168`이 적용된 지금 이 표로 검사하면
> 전 항목이 "어긋남"으로 나오며, 그것은 **정상**이다.** 재실행하지 말 것.

| 확인 지점 | 당시 기대 | 결과 |
|---|---|---|
| `tenants` 컬럼 수 | 8개 | ✅ 통과 |
| `stores` 컬럼 수 | 15개 | ✅ 통과 |
| `catchmenu_hq` 테이블 수 | 16개 | ✅ 통과 |
| `uq_stores_tenant_code` 정의 | `(tenant_id, store_code)` | ✅ 통과 |
| `tenant_status`/`isolation_state`/`legal_entity_id` | 존재하지 않아야 함 | ✅ 통과 |
| 신규 4테이블 | 존재하지 않아야 함 | ✅ 통과 |
| `catchmenu_hq` 테이블 권한 GRANT | 0건 | ✅ 통과(`grantee <> 'postgres'` 기준 — `601504` §1.3.1) |
| `service_role`의 `catchmenu_hq` USAGE | 없음 | ✅ 통과 |
| `franchise_brands` 정의 | 0085 L123–160과 동일 | ✅ 통과 |

### §6.1 `0169` 사전 게이트 — **현행** (v3 신설, 2026-08-10 실측 기준)

`0169`는 **`0168`이 이미 적용된 상태에서** 진행한다. 따라서 아래가 **착수 전 정상 상태**다.

| # | 확인 지점 | 기대 (0169 착수 전) | 어긋나면 |
|---|---|---|---|
| 1 | `catchmenu_hq` 테이블 수 | **20개** (기존 16 + `0168` 신규 4) | 중단 |
| 2 | `tenants` 컬럼 수 | **10개** (8 + `tenant_status` + `isolation_state`) | 중단 |
| 3 | `stores` 컬럼 수 | **16개** (15 + `legal_entity_id`) | 중단 |
| 4 | 신규 4테이블 | **4개 전부 존재** | **없으면 중단**(`0168` 미적용) |
| 5 | `uq_ler_sole_active` 인덱스 | **미존재** | **존재하면 중단**(`0169` 이미 적용됨) |
| 6 | `catchmenu_authority_owner` role | **미존재** | **존재하면 중단**(동상) |
| 7 | `legal_entity_representatives` 행수 | **0행** | 0행이 아니면 중단 — SOLE 인덱스가 기존 데이터와 충돌할 수 있음 |
| 8 | `uq_stores_tenant_code` 정의 | `(tenant_id, store_code)` **불변** | 중단 |
| 9 | 신규 4테이블 GRANT (`grantee <> 'postgres'`) | **0건** | 0건이 아니면 중단 |
| 10 | `service_role`의 `catchmenu_hq` USAGE | **없음** | 있으면 중단 |
| 11 | `franchise_brands` 정의 | 0085 L123–160과 동일 | 중단 |
| 12 | `tenant_status='ACTIVE'`인 tenant | **0건** (§4.3) | 있으면 중단 |

**검증 쿼리**:

```sql
select (select count(*) from pg_tables where schemaname='catchmenu_hq')                            as hq_tables,          -- 20
       (select count(*) from information_schema.columns
          where table_schema='catchmenu_hq' and table_name='tenants')                              as tenants_cols,       -- 10
       (select count(*) from information_schema.columns
          where table_schema='catchmenu_hq' and table_name='stores')                               as stores_cols,        -- 16
       (select count(*) from pg_tables where schemaname='catchmenu_hq'
          and tablename in ('owners','legal_entities',
                            'legal_entity_person_roles','legal_entity_representatives'))           as new4_present,       -- 4
       (select count(*) from pg_indexes
          where schemaname='catchmenu_hq' and indexname='uq_ler_sole_active')                      as uq_sole_exists,     -- 0
       (select count(*) from pg_roles where rolname='catchmenu_authority_owner')                   as authority_role,     -- 0
       (select count(*) from catchmenu_hq.legal_entity_representatives)                            as ler_rows,           -- 0
       (select count(*) from catchmenu_hq.tenants where tenant_status='ACTIVE')                    as active_tenants;     -- 0
```

**2026-08-10 실측 결과**: `20 / 10 / 16 / 4 / 0 / 0 / 0` — **전 항목 기대와 일치**(항목 12 별도 확인 0건).

#### §6.1.1 이 게이트가 신설된 경위 (`TEST_SCOPE_ERROR`)

`0169` 착수 전 Codex가 §6.1 체크를 실행해 **Stop Condition이 발동**했다.
원인은 §6.1이 **`0168` 적용 *전*** 기준(16테이블 / 8컬럼 / 15컬럼 / 신규객체 없음)으로 작성돼 있었고,
`0169`는 **`0168` 적용 *후*** 에 진행되므로 **기준 시점 자체가 어긋난 것**이었다.

**분류: `TEST_SCOPE_ERROR` — `REAL_DEFECT`가 아니다.**
스키마·설계·구현에는 문제가 없었고, **문서를 v2로 갱신할 때 사전 게이트의 기준 시점을 함께 옮기지 않은 것**이 원인이다.

> **`601504` §1.3.1의 GRANT 오판과 같은 계열의 실패**다 — 둘 다 *"검사 기준이 실제와 어긋나 정상을 결함으로 판정"* 했다.
> 이번에는 **기준의 시점(when)** 이, 그때는 **기준의 범위(who)** 가 어긋났다.

### §6.2 검증 중 중단 조건

| 조건 | 의미 |
|---|---|
| `service_role`의 직접 SELECT가 **성공** | `601501` §2.7.1의 차단 계층 서술이 틀림 — 설계 정정 필요 |
| `SECURITY DEFINER` 경유 접근이 **실패** | 유일한 접근 경로 부재 — "아무도 못 쓰는 테이블" |
| `postgres` 아닌 소유자의 `SECURITY DEFINER` 함수 발견 | §2.3 배포 전제 붕괴 |
| DDL 재실행이 **오류** | 멱등성 미성립 — 가드 누락 |
| `cron.job`이 0행이 **아니게 됨** | 예상치 못한 부작용 |
| `business_registration_number` NULL 2건이 **충돌** | `nullif` 누락 — 시드 생성 불가 |

### §6.3 범위 이탈 징후

- 신규 컬럼을 쓰려면 기존 RPC를 고쳐야 한다는 판단이 드는 순간 → **그것이 0-A-2의 정의다.** 중단하고 이월.
- 인접 도메인 4개 이상을 동시에 건드려야 하는 상황 → §47.4 탈출조건 5번. 중단하고 Human 판단.

### §6.4 ⚠️ `0169` 전용 Stop Condition — `BYPASSRLS` 누락 (v2 신설, 실증된 함정)

**`catchmenu_authority_owner`를 `NOLOGIN`만 주고 `BYPASSRLS` 없이 생성하면 안 된다.**

**실증 근거**(로컬, 2026-08-10, `legal_entities`에 행 1건 삽입 후 `authenticated`로 SECDEF 함수 호출, 전부 ROLLBACK):

| 함수 소유 role | 테이블 `SELECT` 권한 | 결과 |
|---|---|---|
| `NOLOGIN`, **`BYPASSRLS` 없음** | 부여함 | **`0`** ← 오류가 아니라 **조용히 전량 필터** |
| `NOLOGIN`, **`BYPASSRLS` 있음** | 부여함 | **`1`** ← 정상 |

원인: 신규 4테이블은 `FORCE ROW LEVEL SECURITY` + **정책 0개**(§2.2)다.
`FORCE`는 소유자에게도 RLS를 적용하므로, 정책이 없으면 `BYPASSRLS` 없는 역할은 **모든 행이 걸러진다.**
`postgres`가 지금 동작하는 이유도 오직 `rolbypassrls = t` 때문이다.

**이것이 Stop Condition인 이유**: 실패가 **조용하다.** 예외도, 로그도, 오류코드도 없이
빈 결과만 돌아온다. 0-C에서 함수를 만든 뒤에야 증상이 나타나고, 그때는 원인이 0169까지 거슬러 올라간다.

**Stage 8 체크 항목 (0169 적용 직후 필수)**:

```sql
select rolname, rolcanlogin, rolbypassrls
from pg_roles where rolname = 'catchmenu_authority_owner';
```

| 기대 | 값 |
|---|---|
| `rolcanlogin` | **`f`** (LOGIN이면 §4.4 위반 — 즉시 중단) |
| `rolbypassrls` | **`t`** (`f`이면 본 Stop Condition 발동 — 즉시 중단) |

**해제 경로**: 0-C가 이 역할을 위한 RLS 정책을 만들면 `BYPASSRLS`를 회수할 수 있다 → Open Item (o).
**그전까지는 `BYPASSRLS`를 회수하지 않는다.**

---

## §7 Required Verification

### §7.1 ⚠️ Stage 8 착수 직전 최종 호출자 재확인 — 안전장치 ② (필수 게이트)

**`isolate_tenant()`/`manage_subscription()`의 실호출자가 0건임을 DDL 적용 직전에 마지막으로 1회 더 확인한다.**

이미 여러 차례 확인된 사실이나, **확인 시점과 적용 시점 사이의 간격**이 이 게이트의 존재 이유다.
설계~승인 과정에서 시간이 흘렀고 그 사이 새 호출자가 생겼다면, 지금까지의 모든 확인은 무효다.
**"전에 확인했으니 괜찮다"로 대체할 수 없다** — 이 절차는 생략 불가다.

**실행 시점**: Stage 8 구현 착수 직전, DDL을 적용하기 **전**.

**확인 명령 (전부 실행하고 결과 원문을 캡처)**:

> **⚠️ 이 절차는 아래 "알려진 경로" 표를 근거로 생략할 수 없다.** 표는 2026-08-09 시점의 관측이며,
> 실제로 `detect_threat()`(0121)는 **v4 계약 작성 시 누락됐다가 이 게이트에서 발견됐다**(§4.1.1).
> **매번 grep을 새로 실행**해서 목록 자체를 다시 만든다. "지난번에 2개였으니 2개일 것"으로 처리하지 않는다.

```bash
# (a) 저장소 전체 — 앱/스크립트/SQL 어디에도 호출자가 없는가
grep -rn "isolate_tenant" --include=* . | grep -v "^./docs" | grep -v cloud_backup | grep -v "^./sql/scratch"
grep -rn "manage_subscription" --include=* . | grep -v "^./docs" | grep -v cloud_backup | grep -v "^./sql/scratch"
grep -rn "detect_threat" --include=* . | grep -v "^./docs" | grep -v cloud_backup | grep -v "^./sql/scratch"
```

```sql
-- (b) DB 내부 — 다른 함수 본문이 호출하지 않는가 (⭐ 목록을 여기서 새로 만든다)
select n.nspname, p.proname
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname like 'catchmenu%'
  and p.prosrc ilike '%isolate_tenant%'
  and p.proname <> 'isolate_tenant';

-- (c) pg_cron 작업 문자열이 호출하지 않는가
select job_code from catchmenu_common.pg_cron_jobs
where sql_command ilike '%isolate_tenant%'
   or sql_command ilike '%manage_subscription%'
   or sql_command ilike '%detect_threat%';
```

**기대 결과**:

| 확인 | 기대 |
|---|---|
| (a) 앱·스크립트·운영 스크립트의 **실호출자** | **0건**. (0090의 정의 자체, 0112/0121의 내부 호출, 0095 L791/809/827의 **주석·문자열 언급**은 실호출이 아니므로 제외) |
| (b) 다른 함수 본문의 호출 | **`manage_subscription`(0112)과 `detect_threat`(0121) 2개만** — 그 외가 나오면 **신규 경로 발견** |
| (c) cron `sql_command` | **0건** |

**알려진 경로 (2026-08-09 관측 — 이 표는 기대값이지 완전성 보증이 아니다)**:

| 함수 | 파일·라인 | 상태 |
|---|---|---|
| `manage_subscription()` | 0112 L600–606(SUSPEND), L616–620(ACTIVATE) | 실호출자 0건(dormant) + §4.1.2 파라미터 불일치 |
| `detect_threat()` | 0121 L876–882 | 실호출자 0건(dormant — 0121 보안 파이프라인 전체가 인프라만 존재) + §4.1.2 파라미터 불일치 |

**하나라도 예상과 다르면 §6의 Stop Condition으로 처리한다.** 특히 **(b)에서 위 2개 외의 함수가 나오면
세 번째 경로 발견**이며, DDL을 적용하지 않고 Human 판단을 받는다.
선택지는 (i) 그 호출자를 제거·비활성화 후 진행, (ii) 0-A-2를 먼저 착수, (iii) 범위 재조정이며,
**"호출자가 있지만 그냥 진행"은 선택지가 아니다.**

발견된 경로가 2개보다 많으면 **§4.1.1의 표를 갱신하고 재승인**을 받는다 — 계약서가 실제보다
좁은 경로만 금지하고 있는 상태로 구현에 들어가지 않는다.

### §7.2 구현 후 검증

Stage 8 구현 후 다음을 **전부** 수행해야 완료로 간주한다:

1. `601504_TestPlan` §1~§8 전 항목 실행 및 **원문 증거 캡처**(오류코드·행수 포함, §48 D단계).
2. `601504` §9.1의 **핵심 5항목** 전부 PASS.
3. `git diff` 상 변경 파일이 **신규 마이그레이션 + 문서**뿐임을 확인 — 기존 `.sql` 수정 0건
   (`0168` 적용분 + **`0169` 신규**, `0168` 자체 수정은 0건이어야 함).

### §7.3 `0169` 전용 검증 항목 (v2 신설)

| # | 확인 | 기대 |
|---|---|---|
| 1 | `catchmenu_authority_owner` 속성 (§6.4) | `rolcanlogin = f`, **`rolbypassrls = t`** |
| 2 | 신규 4테이블 GRANT (`grantee NOT IN ('postgres','catchmenu_authority_owner')`) | **0행** |
| 3 | `catchmenu_authority_owner`의 4테이블 권한 | `SELECT/INSERT/UPDATE/DELETE` 존재 |
| 4 | `uq_ler_sole_active` 존재 및 술어 | `WHERE representation_mode='SOLE' AND is_active=true` |
| 5 | **SOLE 2명 거부 실동작** — 같은 법인에 활성 `SOLE` 2건 INSERT | **두 번째가 `23505`** (트랜잭션 후 ROLLBACK) |
| 6 | `SOLE` 1명 + `JOINT` 1명 동시 | **허용됨**(알려진 미해소 — `601501` §2.5.4) |
| 7 | `0169` 재실행 멱등성 | 오류 0건 |
| 8 | 신규 함수 생성 0건 | `catchmenu%` 함수 수 불변 |
4. `000005`/`000007` 트리플 업데이트 완료.
5. §9.2의 "FAIL이 아닌 것" 목록을 검증자가 결함으로 오보고하지 않았는지 확인.

---

## §8 Open Items (승계)

`601501` §7 / `601503` §7의 (a)~(o)를 그대로 승계한다. 본 계약과 직접 관련된 것:

| # | 항목 | 처리 시점 |
|---|---|---|
| (c) | 대표권 행간 모순(SOLE 2명 등) 방지 | 후속(트리거/RPC) |
| (h) | `stores.legal_entity_id` NOT NULL 승격 + INSERT 경로 전수조사 | **5단계 말미** |
| (m) | 클라우드 확인 3건(`pg_cron` 상태 / 카탈로그 값 / PG 버전) | **5단계 착수 전** |
| (n) | `pg_cron_jobs.is_registered` 역논리 결함 | **0-A-2** |
| (o) | **`SECURITY DEFINER` 소유자 `postgres` 배포 계약 명문화** | 배포 정책 판단 |
| (p) | **`isolate_tenant()` 호출부 3곳의 파라미터명 불일치**(`p_reason` → `p_isolation_reason`) | **§8A.2 참조** |

### §8.1 Open Item (p) — `isolate_tenant()` 파라미터명 불일치 (신규)

**사실**(§4.1.2): `isolate_tenant()`의 필수 인자는 `p_isolation_reason`(0090 L1259)인데,
알려진 호출부 **3곳 전부**가 존재하지 않는 `p_reason`을 쓴다 —
0112 L600–606(SUSPEND), 0112 L616–620(ACTIVATE), 0121 L876–882(`detect_threat`).
세 곳 모두 실행 시 **42883**으로 실패한다.

**본 워크패킷 범위 밖이다** — 0090/0112/0121 수정은 §4.1이 금지한다.

**처리 규정 — 워크패킷 이름이 아니라 행위로 규정한다**(§8A.1과 동일한 방식):

> **`isolate_tenant()` 호출부의 파라미터명을 수정하는 어떤 작업이든**
> (0-A-2든, 0121 보안 파이프라인 실연동 작업이든, 기계적 일괄 치환이든)
> **같은 변경 안에서 `tenant_status`/`isolation_state` 분리 문제를 반드시 함께 해결해야 한다.
> 파라미터명만 고쳐 배포하지 않는다.**

**근거**: 파라미터명 불일치는 현재 ACTIVATE를 막는 **방벽 ②**다(§4.5.1).
`p_reason` → `p_isolation_reason` 치환은 **가장 기계적이고 무해해 보이는 수정**이면서
**3개 호출부를 한 번에 뚫는다.** "이름만 맞춰놨다"는 커밋 하나가 §4.3 위반 경로를 열 수 있다.

**0121 보안 파이프라인 실연동 시 특히 주의**: `detect_threat()`는 사람이 호출하는 함수가 아니라
**FATAL 위협 이벤트가 자동 트리거**하는 경로다(0121 L872–882). 연동되는 순간 사람의 의도와 무관하게
호출되므로, 연동 작업은 **반드시 0-A-2 완료 이후**여야 한다.

---

## §8A ⚠️ 0-A-2는 다음 **필수** 착수 워크패킷이다 — 안전장치 ④

**본 워크패킷 병합 후 다음에 착수할 워크패킷은 0-A-2로 고정한다.** 다른 도메인(0-B 이후, 1-1 등)으로
넘어가기 전에 0-A-2를 완료해야 한다.

**근거**: 본 워크패킷은 `isolate_tenant()`를 **의도적 장애 상태**로 남긴 채 병합된다(§4.1.1).
이 상태는 §4.3/§4.5의 금지 조항들로 봉인되어 있으나, **그 봉인은 시간이 갈수록 약해진다** —
사람은 잊고, 새 코드는 계속 들어오며, "왜 안 되지?"라는 질문이 언젠가 반드시 나온다.
0-A-2를 뒤로 미루는 것은 **부채에 이자를 붙이는 일**이다.

**0-A-2가 완료해야 할 항목** (`601503` §5.5에서 승계):

| # | 항목 |
|---|---|
| 1 | `isolate_tenant()` 재작성 — `isolation_state`만 변경, `tenant_status` 미접근 |
| 2 | `manage_subscription()` 재작성 — `tenant_status`만 변경, 격리 해제 시 구독상태 자동 복구 금지 |
| 3 | `0120`/`0123`/`0129` 필터에 `AND isolation_state='NONE'` 보강 (**`pg_cron_jobs.sql_command` 행 값 직접 수정** 포함) |
| 4 | `0112` L248 `p_tenant_status` 공개 파라미터의 API 시그니처 결정 |
| 5 | `0112` 집계 6곳의 "격리된 ACTIVE 테넌트" 분류 정의 |
| 6 | `pg_cron_jobs.is_registered` 역논리 결함 수정(Open Item (n)) |
| 7 | `is_active` vs `tenant_status` 진실원천 정리(Open Item (a)) |
| 8 | **⚠️ ACTIVATE 분기의 `tenant_status='ACTIVE'` 기록 문제 해결** — §8A.1 |

### §8A.1 ⚠️ 0-A-2 / 0-A-3 **공통** 필수 완료조건 — phantom 해소와 ACTIVATE는 함께 고친다

> **`tenants.company_name` phantom 참조(0112 **L533** 포함)를 해소하는 어떤 워크패킷도,
> 같은 변경 안에서 ACTIVATE 분기(L608–619)의 `tenant_status='ACTIVE'` 기록 문제를
> 반드시 함께 해결해야 한다. 둘을 분리해서 배포하지 않는다.**

**근거**(§4.5.1): 현재 ACTIVATE 경로를 막고 있는 것은 CHECK가 아니라 **L533의 phantom 컬럼이라는 우연한 방벽**뿐이다.
`isolate_tenant(p_isolate := false)`가 기록하는 `'ACTIVE'`는 `chk_tenants_status`의 허용값이므로
**CHECK는 이 경로를 막지 못한다.**

따라서 `company_name`만 정리하는 **부분 수정(partial fix)** 은 **방벽만 제거하고 위험을 남긴다** —
그 순간부터 ACTIVATE는 오류 없이 조용히 §4.3을 위반한다.

| 워크패킷 | 이 조건이 적용되는 이유 |
|---|---|
| **0-A-2** | `manage_subscription()` 전체를 재작성한다 → L533과 ACTIVATE를 **동시에** 다루므로 정상 경로. 다만 "tenant_status 로직만 고치고 company_name은 나중에" 식 분할 금지 |
| **0-A-3** | `tenants.company_name` phantom 계열(`onboard_tenant`/`provision_tenant`)을 다룬다 → **0112 L533을 함께 건드릴 가능성이 높다.** 건드린다면 ACTIVATE도 함께 해결해야 한다 |
| **0121 보안 파이프라인 실연동 작업** | `detect_threat()`를 실제로 연동한다 → **FATAL 위협이 자동으로 `isolate_tenant()`를 트리거**하게 된다. §8.1 참조 — **0-A-2 완료 이후에만 착수** |

### §8A.2 방벽 ②(파라미터명) 제거에도 같은 규칙이 적용된다

§8A.1은 방벽 ①(phantom 컬럼)에 대한 규칙이다. **방벽 ②(파라미터명 불일치)에도 동일한 규칙이 적용된다** —
상세는 **§8.1 Open Item (p)**. 요약하면:

> `isolate_tenant()` 호출부의 **파라미터명을 수정하는 어떤 작업이든**,
> 같은 변경 안에서 `tenant_status`/`isolation_state` 문제를 함께 해결해야 한다.

두 방벽은 서로 다른 결함이므로 **서로 다른 작업이 각각 제거할 수 있다.** 따라서 규칙도 양쪽에 건다.

**0-A-2 완료가 해제하는 금지 조항**: §4.1.1(호출 금지), §4.3(ACTIVE 승격 금지), §4.5(신규 호출자 배포 금지).
셋 다 **0-A-2 검증 통과 + 별도 Human 판단**으로만 해제된다.

**후속 문서 작업(본 워크패킷 범위 밖) — 2026-08-10 정정**:

> ⚠️ 본 문단은 원래 "이 의존관계를 `601401_Master_Tracker.md`에도 기록할 것"이라고 적었으나
> **잘못된 지시였다.** Stage 10에서 확인한 결과 `601401`은 **`601400_fable_design_integrity_inspection`
> 프로그램(13개 도메인 설계무결성 *검사*) 전용 트래커**이며, 0-A 나선의 **구현 워크패킷**인 601500과는
> 계보가 다르다. 해당 트래커에 기록하면 잘못된 프로그램의 진행표를 오염시킨다.

의존관계(`601500` → `0-A-2`)가 계약서 안에만 있으면 밖에서 보이지 않는다는 **문제의식 자체는 유효**하다.
현재 이 의존관계가 기록된 위치는 다음과 같으며, 별도의 구현 워크패킷 마스터 트래커는 **존재하지 않는다**:

| 위치 | 내용 |
|---|---|
| 본 문서 §8A | 0-A-2 필수 착수 지정 + 완료 항목 8개 |
| `601512_Baseline_Summary.md` §6 | "0-A-2가 다음 필수 착수 워크패킷" |
| `000005` / `000007` | 문서 색인 (진행 상태는 담지 않음) |

**미결 판단**: 구현 워크패킷 전용 진행 트래커를 신설할지 여부는 Human 결정 사항으로 남긴다.

---

## §8B 운영 안내 — `isolate_tenant()` 실패는 버그가 아니다 — 안전장치 ⑤

> **이 절은 향후 이 오류를 마주칠 사람을 위한 것이다. 삭제하지 말 것.**

### 증상

`catchmenu_common.isolate_tenant(p_isolate := true)` 또는 이를 호출하는
`manage_subscription(p_action := 'SUSPEND')`를 실행하면 다음으로 실패한다:

```text
ERROR: new row for relation "tenants" violates check constraint "chk_tenants_status"
SQLSTATE: 23514
DETAIL: Failing row contains (..., tenant_status = 'ISOLATED', ...)
```

### 이것은 버그가 아니다

**0-A(DDL) 병합과 0-A-2(RPC 재작성) 완료 사이의 의도된 임시 배포 상태다.**

이유: `tenant_status` 하나가 **구독 생명주기**와 **보안 격리**라는 직교하는 두 축을 함께 담고 있어,
두 RPC가 같은 컬럼을 서로 다른 의미로 덮어쓰는 결함이 있었다(`601501` §3).
0-A는 이를 `tenant_status` + `isolation_state` **2개 컬럼으로 분리**했고,
`'ISOLATED'`는 이제 `isolation_state`의 값이지 `tenant_status`의 값이 아니다.
`isolate_tenant()`는 아직 옛 구조(`tenant_status`에 `'ISOLATED'` 기록)로 작성돼 있어 CHECK에 걸린다.

### 하지 말아야 할 것

| 하지 말 것 | 왜 |
|---|---|
| `chk_tenants_status`에 `'ISOLATED'`를 추가 | 2컬럼 분리를 무효화한다. **원래 결함으로 되돌아간다** |
| `isolate_tenant()`를 즉석에서 수정 | 0-A-2의 설계 대상이다. 즉석 수정은 계약 위반(§4.1) |
| CHECK 제약을 제거 | 동상 |
| `manage_subscription('ACTIVATE')`로 우회 | 현재는 42703으로 먼저 실패하나(§4.5.1), **방벽이 걷히면 조용히 §4.3을 위반한다** |
| `tenants.company_name`만 추가/우회해 `manage_subscription()`을 되살리기 | **가장 위험한 부분 수정**(§8A.1) — ACTIVATE 방벽만 제거된다 |

### 해야 할 것

1. 지금이 0-A-2 착수 시점인지 확인한다(§8A — 0-A-2는 **다음 필수 워크패킷**이다).
2. 격리 기능이 **지금 당장** 필요한 상황이라면, 임시 수정이 아니라 **0-A-2를 착수**한다.
3. 이 문서(`601505` §8A/§8B)와 `601503` §5.5를 0-A-2의 입력으로 사용한다.

### 참고 — 어떤 것이 실패하고 어떤 것이 성공하는가

| 호출 | 현재(0-A 병합 직후) | 방벽 ①(L533 phantom) 해소 후 | 방벽 ①+②(파라미터명) 모두 해소 후 |
|---|---|---|---|
| `isolate_tenant(..., p_isolation_reason := ...)` **직접·인자 정확** | **23514 실패**(시끄러움 — 즉시 인지) | 동일 | 동일 (0-A-2가 고칠 때까지) |
| `isolate_tenant(..., p_reason := ...)` **직접·인자 오류** | **42883 실패** | 동일 | — |
| `manage_subscription('SUSPEND')` | **42703** — 분기 도달 전 | **42883**(방벽 ②) | 23514 실패 |
| `manage_subscription('ACTIVATE')` | **42703** — 분기 도달 전 | **42883**(방벽 ②, 롤백됨) | ⚠️ **조용히 성공 → §4.3 위반** |
| `manage_subscription('CANCEL')` | **42703** — 분기 도달 전 | 성공(허용값, `isolate_tenant` 미호출) | 동일. 신규 호출은 §4.5로 금지 |
| `detect_threat(p_threat_severity := 'FATAL', ...)` | 42883(방벽 ②) — 그 전에 dormant | 동일 | 23514 실패 |

> **읽는 법**:
> - 지금 `manage_subscription()`의 어떤 액션을 호출해도 `42703 undefined_column (tenants.company_name)`이 뜬다 —
>   `tenant_status`와 무관한 **별개의 기존 결함**이다.
> - `23514`를 실제로 보려면 `isolate_tenant()`를 **파라미터명까지 정확히 지정해 직접** 호출해야 한다.
>   간접 경로 3곳은 그 전에 `42883`으로 죽는다(§4.1.2).
> - **가장 오른쪽 열이 위험 지점이다.** 두 방벽은 모두 "고쳐야 마땅한 별개 결함"이므로 언젠가 제거된다.

---

## §9 Human Approval

### §9.1 승인이 뜻하는 것

이 계약을 승인하면 다음이 허가된다:

- `sql/migrations/`에 **신규 파일 1개** 생성 (§1.1)
- 그 파일 안에서 **§1.2/§1.3의 대상에 대한 §1.4의 동사만** 사용
- `601504`의 검증 실행

승인이 허가하지 **않는** 것:

- 기존 RPC·마이그레이션 수정 (§4.1)
- tenant를 `ACTIVE`로 승격 (§4.3)
- GRANT 부여·RLS 정책 생성 (§2.1/§2.2)
- 시드 데이터 실투입

### §9.2 승인 전 Human이 확인할 것

| # | 확인 항목 | 상태 |
|---|---|---|
| 1 | **범위 절단** — DDL만 하고 RPC를 전부 미루는가? (미루면 `isolate_tenant()`가 장애 상태로 남는다) | ✅ **승인됨(2026-08-09)** — 단 §0.1의 안전장치 5가지를 계약에 명시하는 조건. Cursor+Codex 교차검증 반영 |
| 2 | **GRANT 미부여 결정**(§2.1)에 동의하는가? | ✅ **승인됨(2026-08-10)** — 단 `catchmenu_authority_owner` 예외 포함(§2.1.1). Stage 11B 조건 ① 이행을 위한 **`0169` GRANT 확장 승인** |
| 3 | **`ACTIVE` 승격 금지**(§4.3)를 0-A-2 완료까지 유지하는 데 동의하는가? | 대기 |
| 4 | **소유자 배포 전제**(§2.3)를 코드로 명문화할지, Open Item(o)로 둘지? | 대기 |
| 5 | **0-A-2를 다음 필수 착수 워크패킷으로 고정**(§8A)하는 데 동의하는가? | 대기 |

### §9.3 승인 기록

```text
Approved by:
Date:
Decision:            [ ] APPROVE   [ ] APPROVE WITH CONDITIONS   [ ] REJECT
Conditions:
```

---

## §10 Approval State

| 단계 | 상태 |
|---|---|
| Stage 5 (Contract Drafting, Claude Code) | **완료 — 본 문서** |
| Stage 6 (Contract Verification) | **대기** — §37에 따라 **Claude Code 제외**(계약 작성자) |
| Stage 7 (Human Approval) | 대기 |
| Stage 8 (Implementation, Codex) | 미착수 |

> **Stage 6 주의(§37)**: 본 계약과 `601504` TestPlan은 Claude Code가 작성했으므로,
> Claude Code는 계약 검증에 참여하지 않는다. Codex + Antigravity(Normal) 또는
> Cursor + Codex + Antigravity(Critical)가 검증한다.

## §11 근거 문서 목록 (§46)

| 문서/파일 | 인용 | 역할 |
|---|---|---|
| `000701` §3(L92/L253/L254 단계 소유자), §13.7–§13.8(Dual Anchor / Stage 11B 의무), §37(계약검증 작성자 제외), §46, §47.2, §47.4, §47.6, §48, §49.2 | — | 파이프라인·가드레일·근거목록 |
| **`601510_AuditReview_Stage11B_Blind_Audit.md`** | §3(BLOCKER 방어선 5개), §4(SOLE partial unique), 최종판정 조건 ①~④ | **v2 개정의 직접 근거** |
| `601509_AuditReview_...md` | Stage 11A 판정(`APPROVE_WITH_NOTES`) | 11B와의 대조 대상(§13.9 Stage 11C) |
| `000001_Md_Rules.md` §5.4.1~§5.4.3 | — | ChangeContract 문서 규격 |
| `601501_ERD...md` (v4) | §0.1, §2.1–§2.7, §3, §7 | 설계 원본 (충돌 시 우선) |
| `601502_Overview...md` (v4) | §3.1, §3.2, §4.2, §4.3, §5 | 범위 절단·위험 승계 |
| `601503_Logic...md` (v4) | §2.1–§2.8, §3, §4, §5, §6, §7 | 의사 DDL·적용 순서 |
| `601504_TestPlan...md` | §1, §3, §4, §9 | 검증 계획·Stop Condition 연동 |
| **`supabase/config.toml`** | `[api] schemas`(L7–13) | §5 수정 금지 대상 / 접근 경계 |
| `0002_create_hq_tenant_store.sql` | L8–24, L43–76, L60 | §6.1 baseline |
| `0021`/`0022` | 0022 L614–623, L78–89 | §2.2 최초 사례 근거, USAGE 분포 |
| `0072_create_pg_cron_schedules.sql` | L201–206, L219–230 | §4.4 cron 금지 근거 |
| `0082`/`0090`/`0112`/`0120`/`0123`/`0129` | `601501` §8의 지점 목록 | §4.1 금지 대상 |
| `0090_create_multitenant_isolation_rpc.sql` | **L1256–1263**(`isolate_tenant` 실제 시그니처, `p_isolation_reason` 필수), L1283–1286, L1293–1295 | **§4.1.2 파라미터 불일치 근거** |
| `0112_create_hq_admin_rpc.sql` | L533, L548, L592–606(**호출 L600–606**), L608–619(**호출 L616–620**), L622–634 | §4.1.1/§4.5.1 방벽 ①② 근거 |
| **`0121_create_security_pipeline.sql`** | **L872–882**(FATAL 시 `isolate_tenant` 자동 호출, **호출 L876–882**), L1589(주석) | **§4.1.1 세 번째 경로 — 게이트에서 발견** |
| `0095_create_pgcron_monitoring_rpc.sql` | L791, L809, L827 | `isolate_tenant` **문자열 언급만**(실호출 아님) — §7.1 판정 시 오탐 방지 |
| `0085_...franchise_os_foundation_rpc.sql` | L123–160 | §4.2 금지 대상 |
| `0034_seed_data.sql` | L24–25, L52–55 | §2.4 백필 대상 |

## Module Domain Tags

`hq`, `tenant`, `store`, `legal_entity`, `owner`, `representative`, `rls`, `grant`, `ddl`, `contract`
