# 601505_ChangeContract_Operational_Authority_Foundation_Ddl.md

Status: Draft (Human 승인 대기 / Stage 6 계약검증 대기)
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
| ① | 호출 금지 단정 | **§4.1.1** | "어떤 경로로도 호출 금지" — 애매한 권고가 아닌 금지 |
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

## §2 명시적 설계 결정 — 계약 조항

### §2.1 신규 4테이블에 **어떤 GRANT도 부여하지 않는다** (`601501` §2.7.3)

`owners` / `legal_entities` / `legal_entity_person_roles` / `legal_entity_representatives`에 대해
`authenticated`·`service_role`·`anon` **어느 역할에도** `SELECT`/`INSERT`/`UPDATE`/`DELETE`/`ALL`을
부여하지 않는다.

**근거**: 0-A는 구조 확정까지이며, 이 테이블을 읽고 쓰는 RPC는 후속 워크패킷 소관이다(§47.6-1).
접근이 필요해지는 시점에 최소 권한만 부여하는 것이 순서다. 지금 GRANT를 주면 "쓰는 곳이 없는데
열려 있는 테이블"이 생기고, 0-C가 접근제어를 설계할 때 **이미 열린 문을 닫는 작업**부터 해야 한다.

**검증**: `601504` §3.1이 GRANT 0행을 확인한다. 1행이라도 있으면 계약 위반이다.

### §2.2 RLS 정책(policy)을 만들지 않는다

`enable`+`force`만 걸고 정책은 만들지 않는다. 이는 이 저장소 **최초의 "force RLS + 정책 0개" 사례**이며
(0021은 0022가 정책을 붙이는 짝 구조다), **의도된 신규 설계 결정**이다(`601501` §2.7.2).
정책식 설계는 0-C 소관이다.

### §2.3 ⚠️ 배포 전제 조건 — `SECURITY DEFINER` 함수 소유자는 `postgres`여야 한다 (Open Item (o))

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

"경로"에는 예외가 없다 — RPC 직접 호출, `manage_subscription()`을 통한 간접 호출, 관리자 화면, 배치,
수동 SQL, 테스트 스크립트 전부를 포함한다. 간접 호출 지점은 다음 두 곳이다(라인 직접 확인):

| 분기 | 분기 범위 | `isolate_tenant()` 호출 지점 | 인자 |
|---|---|---|---|
| `SUSPEND` | 0112 **L592–606** | L599–605 | `p_isolate := true` → `'ISOLATED'` 기록 시도 |
| `ACTIVATE` | 0112 **L608–619** | L615–619 | `p_isolate := false` → `'ACTIVE'` 기록 (**CHECK에 걸리지 않음** — §4.5.1) |

두 분기 모두 현재는 L533의 phantom 컬럼 때문에 도달 불가하나(§4.5.1), 그것은 **우연한 방벽**이지
설계된 보호가 아니다. 금지는 방벽의 존재와 무관하게 유효하다.

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
| 신규 4테이블에 **GRANT 부여** | §2.1 설계 결정 |
| 신규 4테이블에 **RLS 정책 생성** | §2.2 — 0-C 소관 |
| `CREATE OR REPLACE FUNCTION` **일체** | 본 워크패킷은 DDL 전용 |
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
`'ACTIVE'`는 `chk_tenants_status`의 **허용값**이다. 즉 ACTIVATE 경로에는 **CHECK라는 안전망이 없다.**
지금 막고 있는 것은 오직 L533의 phantom 컬럼이라는 **우연한 방벽**뿐이다.

**위험이 현실화되는 시점**: 누군가 L533의 `company_name` 참조를 해소하는 순간,
ACTIVATE 분기가 정상 도달 가능해지고 **CHECK 위반 없이 조용히 `tenant_status='ACTIVE'`를 기록**하며
(L608–613 직접 UPDATE + L615–619 `isolate_tenant(false)`, **두 번 기록**) §4.3을 위반한다.

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

### §6.1 라이브 스키마가 `601501`/`601502`/`601503` 서술과 어긋남 (핵심 조건)

| 확인 지점 | 설계 서술 | 어긋나면 |
|---|---|---|
| `tenants` 컬럼 수 | 8개 | 중단 |
| `stores` 컬럼 수 | 15개 | 중단 |
| `catchmenu_hq` 테이블 수 | 16개 | 중단 |
| `uq_stores_tenant_code` 정의 | `(tenant_id, store_code)` | 중단 |
| `tenant_status`/`isolation_state`/`legal_entity_id` | **존재하지 않아야 함** | **존재하면 중단** |
| 신규 4테이블 | **존재하지 않아야 함** | **존재하면 중단** |
| `catchmenu_hq` 테이블 권한 GRANT | 0건 | **0건이 아니면 중단** |
| `service_role`의 `catchmenu_hq` USAGE | 없음 | **있으면 중단** |
| `franchise_brands` 정의 | 0085 L123–160과 동일 | 중단 |

(`601504` §1이 이 전부를 pre-flight로 실행한다.)

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

---

## §7 Required Verification

### §7.1 ⚠️ Stage 8 착수 직전 최종 호출자 재확인 — 안전장치 ② (필수 게이트)

**`isolate_tenant()`/`manage_subscription()`의 실호출자가 0건임을 DDL 적용 직전에 마지막으로 1회 더 확인한다.**

이미 여러 차례 확인된 사실이나, **확인 시점과 적용 시점 사이의 간격**이 이 게이트의 존재 이유다.
설계~승인 과정에서 시간이 흘렀고 그 사이 새 호출자가 생겼다면, 지금까지의 모든 확인은 무효다.
**"전에 확인했으니 괜찮다"로 대체할 수 없다** — 이 절차는 생략 불가다.

**실행 시점**: Stage 8 구현 착수 직전, DDL을 적용하기 **전**.

**확인 명령 (전부 실행하고 결과 원문을 캡처)**:

```bash
# (a) 저장소 전체 — 앱/스크립트/SQL 어디에도 호출자가 없는가
grep -rn "isolate_tenant" --include=* . | grep -v "^./docs" | grep -v cloud_backup
grep -rn "manage_subscription" --include=* . | grep -v "^./docs" | grep -v cloud_backup
```

```sql
-- (b) DB 내부 — 다른 함수 본문이 호출하지 않는가
select n.nspname, p.proname
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname like 'catchmenu%'
  and p.prosrc ilike '%isolate_tenant%'
  and p.proname <> 'isolate_tenant';

-- (c) pg_cron 작업 문자열이 호출하지 않는가
select job_code from catchmenu_common.pg_cron_jobs
where sql_command ilike '%isolate_tenant%'
   or sql_command ilike '%manage_subscription%';
```

**기대 결과**:

| 확인 | 기대 |
|---|---|
| (a) 앱·스크립트·SQL 호출자 | **0건** (`0112`의 `manage_subscription` 내부 호출과 `0090`의 정의 자체는 제외) |
| (b) 다른 함수 본문의 호출 | **`manage_subscription`만** (0112) — 그 외 0건 |
| (c) cron `sql_command` | **0건** |

**하나라도 예상과 다르면 §6의 Stop Condition으로 처리한다** — 새 호출자가 발견되면 DDL을 적용하지 않고
Human 판단을 받는다. 선택지는 (i) 그 호출자를 제거·비활성화 후 진행, (ii) 0-A-2를 먼저 착수,
(iii) 본 워크패킷 범위 재조정이며, **"호출자가 있지만 그냥 진행"은 선택지가 아니다.**

### §7.2 구현 후 검증

Stage 8 구현 후 다음을 **전부** 수행해야 완료로 간주한다:

1. `601504_TestPlan` §1~§8 전 항목 실행 및 **원문 증거 캡처**(오류코드·행수 포함, §48 D단계).
2. `601504` §9.1의 **핵심 5항목** 전부 PASS.
3. `git diff` 상 변경 파일이 **신규 마이그레이션 1개 + 문서**뿐임을 확인 — 기존 `.sql` 수정 0건.
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

**0-A-2 완료가 해제하는 금지 조항**: §4.1.1(호출 금지), §4.3(ACTIVE 승격 금지), §4.5(신규 호출자 배포 금지).
셋 다 **0-A-2 검증 통과 + 별도 Human 판단**으로만 해제된다.

**후속 문서 작업(본 워크패킷 범위 밖, 별도 수행)**: 이 의존관계(`601500` → `0-A-2`)를
`601401_Master_Tracker.md`에도 기록할 것. 워크패킷 간 순서 의존이 계약서 안에만 있으면
트래커만 보는 사람에게는 보이지 않는다.

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

| 호출 | 현재(0-A 병합 직후) | L533 phantom 해소 후 |
|---|---|---|
| `isolate_tenant(p_isolate := true)` **직접** | **23514 실패**(시끄러움 — 즉시 인지) | 동일 (0-A-2가 고칠 때까지) |
| `manage_subscription('SUSPEND')` | **42703 실패** — L533에서 분기 도달 전 | 23514 실패 |
| `manage_subscription('ACTIVATE')` | **42703 실패** — 분기 도달 전 | ⚠️ **조용히 성공 → §4.3 위반**(§8A.1) |
| `manage_subscription('CANCEL')` | **42703 실패** — 분기 도달 전 | 성공(허용값). 신규 호출은 §4.5로 금지 |

> **읽는 법**: 지금 `manage_subscription()`의 어떤 액션을 호출해도 `42703 undefined_column
> (tenants.company_name)`이 뜬다 — 이는 `tenant_status`와 무관한 **별개의 기존 결함**이다.
> `23514`를 실제로 보려면 `isolate_tenant()`를 직접 호출해야 한다.

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
| 2 | **GRANT 미부여 결정**(§2.1)에 동의하는가? | 대기 |
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
| `000701` §3(L92/L253/L254 단계 소유자), §37(계약검증 작성자 제외), §46, §47.2, §47.4, §47.6, §48, §49.2 | — | 파이프라인·가드레일·근거목록 |
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
| `0085_...franchise_os_foundation_rpc.sql` | L123–160 | §4.2 금지 대상 |
| `0034_seed_data.sql` | L24–25, L52–55 | §2.4 백필 대상 |

## Module Domain Tags

`hq`, `tenant`, `store`, `legal_entity`, `owner`, `representative`, `rls`, `grant`, `ddl`, `contract`
