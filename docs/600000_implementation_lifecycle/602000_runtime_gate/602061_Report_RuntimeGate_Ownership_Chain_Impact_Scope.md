# 602061_Report_RuntimeGate_Ownership_Chain_Impact_Scope.md

Status: Active
Lifecycle: RuntimeGate
DocumentType: Report
Last Updated: 2026-09-21

## §0 성격

`RG-06` 의 **Impact Scope** 다. gate 문서가 아니다.

```text
600023 §3 의 RG 형식      §1 공격 ~ §7 회귀
이 문서                   그 앞 단계 — 무엇을 건드리고 무엇을 안 건드릴지 정한다
```

**구현하지 않는다.** migration 을 만들지 않고, 함수·constraint·ACL 을 바꾸지 않는다.

**번호 근거** — `600023` §6 이 `RG-N` 을 `602010` 부터 10단위로 배정한다. `RG-06` 의 앵커는 `602060` 이며 그것은 gate 문서 몫이다. 이 문서는 부속 문서이므로 다음 번호 `602061` 을 쓴다. 부속 문서가 뒤 번호를 받는 선례는 `601919` → `601920` · `601921` 이다.

**실측 환경**

```text
container              supabase_db_yoonsul_wait_order_handoff
container id           b67400e8c73e...35ec
PostgreSQL             17.6
transaction_read_only  on — 전 세션. 쓰기 0건
Git HEAD               9e8d5a5 · working tree clean
migration              0178 까지 적용 (success=t)
측정일                  2026-09-21
```

> ⚠️ **local/dev 실측이다.** cloud(`upzthfwhtvazfftxnyfu`)는 접속하지 않았다. **둘이 같다고 가정하지 않는다.**

## §1 Problem Statement

`601919` `H-03` — ownership chain 에서 서로 다른 tenant 의 객체가 연결될 수 있는가.

실측 결과 문제의 형태는 **FK 부재가 아니었다.**

```text
FK 는 전부 있다            object existence 는 보장된다
tenant consistency 는 없다  어느 FK 도 두 객체의 tenant 가 같은지 보지 않는다
trigger 는 없다            7개 체인 테이블의 trigger 는 전부 set_updated_at() 뿐이다
```

더 중요한 것은 **caller authority 와 target tenant 가 분리되지 않았다는 것**이다.

```text
writer 가 p_tenant_id 를 인자로 받는다
그 인자를 처리 대상으로도 쓰고 권한의 근거로도 쓴다
caller 가 그 값을 고른다
```

`RG-01` 이 order · payment · KDS 경로에서 닫은 것과 같은 결함이 **ownership · lifecycle 경로에는 남아 있다.**

```text
assert_caller_tenant_scope 를 호출하는 함수   15개
  전부 order · payment · KDS · integrations
ownership chain writer 6개 중 호출               0개
```

## §2 Human Decision H-03

`2026-09-21`, Human 확정.

### §2.1 `H-03-1` — 법적 주체 축은 tenant authority 축이 아니다

`legal_entities` · `persons` 에 `tenant_id` 가 반드시 존재해야 한다고 **선언하지 않는다.**

```text
법적 주체 축     legal_entities · persons · 두 관계 테이블
tenant authority 축   tenants · stores

같은 개념으로 취급하지 않는다
```

따라서 **`legal_entities` 에 `tenant_id` 가 없다는 사실만으로 결함으로 판정하지 않는다.** `legal_entity` · `person` 관계를 tenant-scoped object 로 **재설계하지 않는다.**

### §2.2 `H-03-2` — 독립 FK 두 개는 pair consistency 가 아니다

`tenant_id` 와 `store_id` 를 함께 처리하는 writer 는 mutation 전에 아래를 검증해야 한다.

```text
stores.id        = target store
AND
stores.tenant_id = target tenant
```

```text
독립 FK   tenant_id → tenants(id)
          store_id  → stores(id)

두 개가 각각 유효하다는 사실만으로
pair consistency 가 보장됐다고 보지 않는다
```

### §2.3 `H-03-3` — caller authority 와 target tenant 를 분리한다

```text
p_tenant_id 는 처리 대상이다
caller 권한의 근거가 아니다
```

`authenticated` caller 가 임의 `p_tenant_id` 를 넘겨 **다른 tenant 의 lifecycle 또는 설정을 변경할 수 있어서는 안 된다.**

가능하면 `RG-01` 의 tenant scope contract 와 `assert_caller_tenant_scope` 를 재사용한다. **단 이 단계에서 재사용 여부를 구현 결정하지 않는다** — §5 에서 적합성만 조사한다.

### §2.4 `H-03-4` — finding 처분

| finding | 대상 | 처분 |
|---|---|---|
| `H03-F1` | `catchmenu_common.isolate_tenant` | **`RG-06` BLOCKER** |
| `H03-F2` | `catchmenu_store.update_business_hours` → `ensure_store_settings` | **`RG-06` BLOCKER** |
| `H03-F3` | `catchmenu_hq.create_franchise_store` | **latent finding** — 이번 blocker fix 에 포함하지 않는다 |

> ⚠️ **`H03-F3` 은 `stores.extra_metadata` 부재라는 schema drift 때문에 실행 불가능하다.**
> **그러나 tenant authority check 없이 INSERT 단계까지 진행하는 구조적 사실은 보존한다.**
> **`RG-F10` · `RG-F12` 계열의 schema-drift / latent-path finding 으로 별도 추적한다.**

### §2.5 `H-03-5` — 범위 제한

```text
138개 (tenant_id, store_id) 쌍 보유 테이블 전수를
이번 RG-06 에서 재검증하거나 수정하지 않는다
```

**결과형 전역 invariant 를 선언하지 않는다.**

```text
선언하지 않는 것   「서로 다른 tenant 객체는 어디에서도 연결되지 않는다」
대신 쓰는 것       path-scoped invariant — §4
```

> ⚠️ **`600023` §3.5 와의 관계를 명시한다.**
> **§3.5 는 결과로 진술된 invariant 에 경로 전수 열거를 요구한다.**
> **`H-03-5` 는 그 요구가 발동하지 않도록 invariant 를 경로형으로 좁힌 것이다.**
> **회피가 아니라 범위 선언이다 — §4 `I-3` 가 닫는 경로를 명시한다.**

### §2.6 2차 Human Decision — `HD-1` ~ `HD-5` · 2026-09-21

> ⚠️ **§2.1 ~ §2.5 는 `H-03-1` ~ `H-03-5` 다.**
> **이 절은 `602061` 초판의 `OQ` 를 받아 내려진 2차 결정이다.**
> **초판의 조사 사실과 섞지 않는다 — 아래는 전부 Human 결정이다.**
>
> **`HD-5` 는 지시서의 「caller authority 와 pair integrity 를 분리한다」 조항이다.**
> **지시서가 번호를 붙이지 않아 이 문서가 `HD-5` 로 번호만 부여했다. 내용은 그대로다.**

#### `HD-1` — `isolate_tenant` authority

**선택 — 별도의 platform-security authority gate**

```text
isolate_tenant 는 일반 tenant-scope RPC 가 아니다

tenant-wide isolation 발동 권한은 601902 TI-3 의
두 platform-level authority 에만 있다
  ①  Automatic platform / security system
  ②  Authorized platform-security Human

일반 authenticated tenant caller 는
자기 tenant 라도 isolate_tenant 발동 권한이 없다

assert_caller_tenant_scope 에서
RG-01 · 0173 이 제거한 claim 기반 service_role exemption 을
되살리지 않는다

platform-security authority 의 물리적 runtime 표현은
아직 확정하지 않는다
```

```text
OQ-1   policy decision        CLOSED
       runtime representation OPEN
```

#### `HD-2` — tenant × store pair 검사 위치

**선택 — `catchmenu_store.ensure_store_settings`**

```text
ensure_store_settings 는 writer 이므로 H-03-2 의 적용 대상이다

mutation 전에 반드시 검증한다
  stores.id        = p_store_id
  AND
  stores.tenant_id = p_tenant_id

실패하면 INSERT · UPDATE 전에 fail closed 한다
```

**새로 증명된 executable entry point 를 `H03-F2` attack surface 에 포함한다.**

```text
update_business_hours
toggle_store_mode
update_kds_capacity_threshold
```

> ⚠️ **셋을 별도 세 결함으로 분리하지 않는다.**
> **공통 write primitive 인 `ensure_store_settings` 의 pair-integrity defect 로 묶는다.**

#### `HD-3` — pair integrity 강제 계층

**선택 — 이번 `RG-06` 에서는 function-level guard**

```text
composite FK 도입하지 않는다
consistency trigger 도입하지 않는다
stores UNIQUE (id, tenant_id) 도입하지 않는다
```

> ⚠️ **schema-level integrity 를 영구 기각한 것이 아니다.**
> **이번 `RG-06` 의 verified executable path 를 최소 범위로 닫는 결정이다.**
> **138개 tenant · store pair table 의 schema-level consistency 문제는 이번 Gate 범위 밖으로 유지한다.**

#### `HD-4` — verification environment

**선택 — local/dev**

```text
RG-06 PASS 는 local/dev runtime verification 으로 닫는다
cloud DB parity 는 RG-06 PASS 필수조건이 아니다
local/dev 결과를 cloud 결과라고 표현하지 않는다
cloud verification 은 별도 deployment · parity 책임으로 남긴다
```

#### `HD-5` — 책임 분리 (문서 서술 규칙)

```text
Entry point responsibility    caller authority 검증
Shared helper responsibility  tenant × store pair consistency 검증
```

> ⚠️ **`ensure_store_settings` 의 pair guard 가**
> **외부 entry point 의 caller authority 검사를 대체한다고 쓰지 않는다.**
> **두 책임을 혼합해 서술하지 않는다.**

## §3 Verified Findings

증명 방식 — `default_transaction_read_only=on` 세션에서 `set local role authenticated` 로 호출하고, **함수 본문 안쪽 write 문에서 `25006` 으로 멈추는 것**을 확인했다. 권한과 검사를 전부 통과해 쓰기 직전까지 도달했다는 뜻이다. 쓰기는 0건이다.

### §3.1 `H03-F1` — VERIFIED · BLOCKER

`catchmenu_common.isolate_tenant` 가 타 tenant 의 lifecycle 을 바꾼다.

```text
set local role authenticated;
set local "request.jwt.claims" = '{"app_metadata":{"tenant_id":"...00aa"},...}';
select catchmenu_common.isolate_tenant('1111...1111','probe',false,null,'ko');

ERROR: cannot execute UPDATE in a read-only transaction
CONTEXT: SQL statement "update catchmenu_hq.tenants
           set tenant_status = v_new_status, updated_at = now()
           where id = p_tenant_id"
         PL/pgSQL function isolate_tenant(...) line 22
```

claims tenant 와 인자 tenant 가 다른데 **아무 검사 없이 UPDATE 에 도달했다.**

```text
전제조건    authenticated JWT 1개 · 대상 tenant_id 1개
            자기 tenant 소속일 필요 없음
```

**깨지는 invariant**

```text
010630 §28    DENY_UNLESS_EXPLICITLY_ALLOWED
601902 TI-3   AUTHORITY_ALLOWED 일 때만 실행한다
RG-04 (0177)  ACTIVE · TRIAL 만 주문을 받는다
```

> ⚠️ **`p_isolate=false` 는 `tenant_status` 를 `'ACTIVE'` 로 덮는다.**
> **`TERMINATED` · `CANCELLED` · `SUSPENDED` tenant 를 되살려 `0177` 의 lifecycle gate 를 정문으로 통과시킨다.**
> **`RG-04` 가 닫은 것을 `RG-06` 대상 함수가 되연다.**

### §3.2 `H03-F2` — VERIFIED · BLOCKER

`update_business_hours` → `ensure_store_settings` 가 타 tenant × 타 store 쌍으로 행을 만든다.

```text
select catchmenu_store.update_business_hours(
  '1111...1111'::uuid,   -- 타 tenant
  '2222...2222'::uuid,   -- 그 tenant 소유가 아닌 store
  '{"mon":"09-18"}'::jsonb,'HQ_ADMIN',null,null);

ERROR: cannot execute INSERT in a read-only transaction
CONTEXT: SQL statement "insert into catchmenu_store.store_settings (
           tenant_id, store_id) values (p_tenant_id, p_store_id)"
         PL/pgSQL function ensure_store_settings(uuid,uuid) line 11
         PL/pgSQL function update_business_hours(...) line 25
```

> ⚠️ **`update_business_hours` 는 `stores` 를 읽기는 한다.**
>
> ```text
> select timezone into v_timezone
> from catchmenu_hq.stores
> where id = p_store_id and tenant_id = p_tenant_id;
> ```
>
> **그러나 결과를 검사하지 않는다.** 불일치면 `v_timezone` 이 `NULL` 이 되고 `coalesce(...,'Asia/Seoul')` 로 흡수된 뒤 **그대로 진행한다.**
> **읽기는 있는데 gate 가 없다.**

```text
전제조건    authenticated JWT · 대상 tenant_id · 임의 store_id
            store_id 는 FK 때문에 실재해야 한다
```

**깨지는 invariant** — `010004` §7 `DENY_UNLESS_CONTEXT_MATCHES` · `601902` `TI-2` · `H-03-2`.

> ⚠️ **attack surface 재정의 — `HD-2` · 2026-09-21**
>
> **초판은 `H03-F2` 를 `update_business_hours` 의 결함으로 적었다.**
> **`OQ-3` 실측(§3.5)이 같은 write primitive 에 닿는 entry point 2개를 더 증명했다.**
>
> ```text
> H03-F2 의 결함 지점    catchmenu_store.ensure_store_settings
>                        pair-integrity defect
>
> 증명된 entry point      update_business_hours
>                        toggle_store_mode
>                        update_kds_capacity_threshold
> ```
>
> **셋을 별도 결함으로 분리하지 않는다 — `HD-2`.**
> **위 §3.2 본문의 재현 로그는 그 셋 중 하나의 기록이며 그대로 보존한다.**

### §3.3 `H03-F3` — CONDITIONALLY VERIFIED · latent

`catchmenu_hq.create_franchise_store` 는 검사가 아니라 drift 로 막혀 있다.

```text
select catchmenu_hq.create_franchise_store('1111...1111'::uuid,'PROBE',...);

ERROR: column "extra_metadata" of relation "stores" does not exist
CONTEXT: PL/pgSQL function create_franchise_store(...) line 42
```

```text
current signature   catchmenu_hq.create_franchise_store(
                      uuid, text, text, text, text, text, text, date,
                      text, text, jsonb, text, uuid, text)
                    SECURITY DEFINER · authenticated=X/postgres
                    overload 0건

drift               stores 에 extra_metadata 컬럼 0건 (실측)
                    함수는 그 컬럼에 INSERT 한다

authority check     current_tenant_id 0회
                    assert_caller_tenant_scope 0회
                    tenant_status 0회 · isolation_state 0회

현재 실행 불가 이유   tenant 검사가 아니다. 컬럼 부재다.
                    store_code 중복 검사까지 통과한 뒤 INSERT 파싱에서 멈춘다
```

**별도 추적 근거** — drift 가 해소되는 순간 `H03-F1` · `H03-F2` 와 같은 등급의 경로가 된다. drift 해소는 `RG-06` 의 범위가 아니다. `RG-F10`(`order_source`·`local_temp_id`) · `RG-F12` 와 같은 계열이다.

### §3.4 조사 중 새로 드러난 사실 — `H03-F4` 후보

`isolate_tenant` 의 **내부 호출자 2개가 이미 깨져 있다.**

```text
호출자   catchmenu_common.detect_threat(...)        DEFINER · anon·authenticated·service_role EXECUTE
         catchmenu_common.manage_subscription(...)  DEFINER · service_role EXECUTE

두 곳 모두 아래 형태로 호출한다
  perform catchmenu_common.isolate_tenant(
    p_tenant_id := ..., p_isolate := true, p_reason := ...)

live signature 는
  isolate_tenant(p_tenant_id uuid, p_isolation_reason text,
                 p_isolate boolean default true,
                 p_actor_id uuid default null,
                 p_locale text default 'ko')
```

실측 — 같은 named-arg 형태를 재현했다.

```text
select catchmenu_common.isolate_tenant(
  p_tenant_id := '...0001', p_isolate := true, p_reason := 'x');

ERROR: function catchmenu_common.isolate_tenant(
         p_tenant_id => uuid, p_isolate => boolean, p_reason => unknown)
       does not exist

같은 호출을 p_isolation_reason 으로 바꾸면
ERROR: cannot execute UPDATE in a read-only transaction   ← 본문 진입
```

> ⚠️ **`p_reason` 이라는 인자는 존재하지 않는다. 두 자동 격리 경로는 `42883` 으로 죽어 있다.**
> **`0112` 600·616행 · `0121` 876행이 그 호출부다.**
> **이것은 `RG-06` 의 설계 판단을 바꾼다** — §5.1 을 보라.

### §3.5 `OQ-3` 실측 — 2026-09-21

`ensure_store_settings` 의 나머지 caller 3개를 초판과 같은 방식으로 실행했다. read-only 세션 · `set local role authenticated` · 타 tenant claims · 쓰기 0건.

```text
get_store_settings(tenant B, store C)
  → {"success": false, "error_key": "store_not_found"}
  쓰기 전에 반환한다.  GUARDED

toggle_store_mode(tenant B, store C, 'PEAK', ...)
  → ERROR: cannot execute INSERT in a read-only transaction
    CONTEXT: insert into catchmenu_store.store_settings (tenant_id, store_id)
             values (p_tenant_id, p_store_id)
             PL/pgSQL function ensure_store_settings(uuid,uuid) line 11
             PL/pgSQL function toggle_store_mode(...) line 35
  NOT GUARDED

update_kds_capacity_threshold(tenant B, store C, 10,10,10, ...)
  → 동일 ERROR
             PL/pgSQL function ensure_store_settings(uuid,uuid) line 11
             PL/pgSQL function update_kds_capacity_threshold(...) line 49
  NOT GUARDED
```

**증명된 신규 executable entry point**

| # | entry point | 도달 지점 | 판정 |
|---|---|---|---|
| `E-1` | `catchmenu_store.update_business_hours(uuid,uuid,jsonb,text,uuid,text)` | `ensure_store_settings` 11행 INSERT | 초판 §3.2 에서 증명 |
| `E-2` | `catchmenu_store.toggle_store_mode(uuid,uuid,text,text,text,uuid,text)` | 동일 | **신규 증명** |
| `E-3` | `catchmenu_store.update_kds_capacity_threshold(uuid,uuid,integer,integer,integer,text,uuid,text)` | 동일 | **신규 증명** |
| — | `catchmenu_store.get_store_settings(uuid,uuid)` | 도달 전 반환 | GUARDED — entry point 아님 |
| — | `catchmenu_hq.create_franchise_store(...)` | drift 로 도달 전 실패 | `H03-F3` latent |

> ⚠️ **`600023` §3.5 가 말한 형태다.**
> **한 결과에 닿는 경로가 하나가 아니었고, 초판 지시 범위는 그중 하나만 보고 있었다.**

> ⚠️ **네 caller 가 같은 helper 를 쓰면서 검사 유무가 갈린다.**
> **`get_store_settings` 만 자체 검사를 갖는다.**
> **검사가 entry point 마다 흩어져 있어 helper 자신은 무방비였다** — `HD-2` 의 근거.

### §3.6 `OQ-7` 실측 — 2026-09-21

```text
merchant_accounts 를 prosrc 에 언급하는 함수        0개 (전 schema)
merchant_account_id 를 prosrc 에 언급하는 함수      0개
stores.merchant_account_id 를 대입하는 함수         0개
anon · authenticated · service_role 의 테이블 권한   전부 f
현재 RG-06 verified path 와의 연결                  없음
```

**실행 가능한 writer 가 존재하지 않는다. 구조 관측으로 유지하고 blocker 로 승격하지 않는다.**

## §4 Invariant

`600023` §3.2 — Human 이 정한다. 아래는 `H-03` 에서 직접 도출한 초안이며 `602060` gate 문서가 §3 으로 확정한다.

### §4.1 `I-1` Caller Authority

```text
tenant-scoped ownership / lifecycle writer 는
caller tenant authority 를 신뢰 가능한 session context 에서 확인한다

target tenant parameter 는 authority 의 근거가 아니다

caller tenant 와 target tenant 가 다르면
명시적 trusted-service exception 이 없는 한 거부한다

claims 부재 · malformed context 는 fail closed 한다
```

> ⚠️ **`HD-1` 반영 개정 — 2026-09-21. 위 초안은 그대로 둔다.**
>
> **`isolate_tenant` 는 `I-1` 이 말한 「tenant-scoped writer」가 아니다.**
>
> ```text
> 601902 TI-3  tenant-wide isolation 발동 권한은
>              ① Automatic platform / security system
>              ② Authorized platform-security Human
>              두 platform-level authority 에만 있다
>
> 따라서      caller tenant == target tenant 는
>            isolate_tenant 의 올바른 판정식이 아니다
>            일반 tenant caller 는 자기 tenant 라도 발동 권한이 없다
> ```
>
> **`I-1` 을 두 갈래로 읽는다.**
>
> ```text
> I-1a  tenant-scoped ownership writer
>       caller tenant 와 target tenant 의 일치를 요구한다
>       assert_caller_tenant_scope 가 그 판정식이다
>
> I-1b  platform-level lifecycle writer — isolate_tenant
>       platform-security authority 를 요구한다
>       caller tenant 일치는 판정식이 아니다
>       물리적 runtime 표현은 미확정 — §9 OQ-1
> ```
>
> **`claims` 부재 · malformed context 의 fail closed 는 두 갈래 모두에 적용된다.**

> ⚠️ **`0173` 경계는 유지한다** — `HD-1`.
> **`assert_caller_tenant_scope` 안에 claim 기반 면제를 되넣지 않는다.**
> **`I-1b` 의 authority 판정은 helper 바깥에 둔다.**

### §4.2 `I-2` Tenant × Store Pair Integrity

```text
tenant_id 와 store_id 를 함께 받아
tenant-scoped child / configuration row 를 생성·변경하는 writer 는
mutation 전에 아래를 증명해야 한다

  stores.id        = p_store_id
  AND
  stores.tenant_id = p_tenant_id

독립 FK 두 개만으로 이 invariant 를 만족했다고 보지 않는다
```

### §4.3 `I-3` Path Scope

이번 `RG-06` 이 닫는 verified path 는 둘이다.

```text
H03-F1   catchmenu_common.isolate_tenant
H03-F2   catchmenu_store.update_business_hours
         → catchmenu_store.ensure_store_settings
```

```text
H03-F3 및 138개 테이블 전체는 이번 gate 의 구현 범위가 아니다
```

> ⚠️ **`HD-2` 반영 개정 — 2026-09-21. 위 초안은 그대로 둔다.**
>
> **`I-3` 이 닫는 것은 경로 둘이 아니라 결함 둘이다.**
>
> ```text
> 결함 1   H03-F1   catchmenu_common.isolate_tenant
>                   caller authority failure
>
> 결함 2   H03-F2   catchmenu_store.ensure_store_settings
>                   tenant × store pair failure
>
>          증명된 entry point 3개를 이 결함 하나로 묶는다
>            E-1  update_business_hours
>            E-2  toggle_store_mode
>            E-3  update_kds_capacity_threshold
> ```
>
> **범위 밖은 그대로다.**
>
> ```text
> H03-F3                     latent · schema drift
> OQ-4                        축 불일치 · 별도 finding
> OQ-7                        구조 관측 · executable path 없음
> 138개 테이블 schema 정합     HD-3
> cloud parity                HD-4
> ```

> ⚠️ **`HD-5` — 두 책임을 섞지 않는다.**
>
> ```text
> entry point     caller authority 를 검증한다
> shared helper   tenant × store pair consistency 를 검증한다
> ```
>
> **helper 의 pair guard 가 entry point 의 caller authority 검사를 대체하지 않는다.**

## §5 Direct Impact Scope

### §5.1 `H03-F1` — `catchmenu_common.isolate_tenant`

**직접 수정 후보 객체**

| 객체 | 왜 후보인가 |
|---|---|
| `catchmenu_common.isolate_tenant(uuid,text,boolean,uuid,text)` | `I-1` 을 위반하는 본체다. caller authority 검사가 0회다 |
| 그 함수의 `catchmenu_hq.tenants` UPDATE 문 (본문 22행) | `tenant_status` 를 caller 가 고른 tenant 에 쓴다 |
| 새 migration 1개 | 함수 본문 교체용. 다음 순번은 `0179` 이나 이 문서에서 확정하지 않는다 |

**현재 상태 실측**

```text
signature            catchmenu_common.isolate_tenant(
                       p_tenant_id uuid,
                       p_isolation_reason text,
                       p_isolate boolean default true,
                       p_actor_id uuid default null,
                       p_locale text default 'ko')
overload             0건
SECURITY             DEFINER
search_path          catchmenu_common, catchmenu_hq, catchmenu_ledger, catchmenu_audit
EXECUTE ACL          postgres=X/postgres | authenticated=X/postgres
                     anon f · service_role f
tenant_id 입력 위치   1번째 인자 — caller 제공
current_tenant_id             0회
claims 사용                   0회
assert_caller_tenant_scope    0회
정의 migration        0090_create_multitenant_isolation_rpc.sql:1256
ACL migration         0090 1448~1455 — revoke public 후 grant authenticated
```

**`assert_caller_tenant_scope` 재사용 가능 여부 — 적합**

```text
catchmenu_common.assert_caller_tenant_scope(p_tenant_id uuid) returns void
  SECURITY INVOKER
  search_path = pg_catalog
  proacl = postgres=X/postgres          PUBLIC · authenticated EXECUTE 없음
  본문
    v := catchmenu_common.current_tenant_id();
    IF v IS NULL OR v IS DISTINCT FROM p_tenant_id THEN
      RAISE EXCEPTION USING ERRCODE = 42501, MESSAGE = caller tenant scope denied
```

```text
적합 근거 1   isolate_tenant 는 postgres 소유 SECURITY DEFINER 다.
              helper 의 EXECUTE 가 postgres 뿐이어도 본문 안에서는 호출된다.
              현행 15개 사용처가 모두 같은 형태다.
적합 근거 2   claims NULL 을 거부한다 — I-1 의 fail closed 와 일치한다.
적합 근거 3   RG-01 이 0173 에서 claim 기반 면제를 제거했다.
              trusted-service 면제를 helper 안에 되넣으면 RG-F3 를 되연다.
```

**`service_role` · trusted internal caller 존재 여부 — 실측**

| 후보 | 실측 | 판정 |
|---|---|---|
| `service_role` 직접 호출 | `isolate_tenant` EXECUTE `f`. 나아가 `service_role` 은 `catchmenu_common` schema `USAGE` 가 없다 — `RG-F1` | **존재하지 않는다** |
| `catchmenu_common.detect_threat(...)` | DEFINER · anon·auth·svc EXECUTE. `FATAL` 위협 시 호출 | **호출부가 오인자로 `42883` — 이미 죽어 있다** |
| `catchmenu_common.manage_subscription(...)` | DEFINER · service_role EXECUTE. `SUSPEND` · `ACTIVATE` 에서 호출 | **동일하게 `42883`. 게다가 `service_role` schema USAGE 부재로 진입 자체가 불가** |

> ⚠️ **「기존 `RG-01` helper 를 그대로 호출하면 정상 administrative isolation path 가 깨지는 caller 가 있는가」**
>
> ```text
> 깨질 수 있는 caller          존재한다 — detect_threat · manage_subscription
> 그 caller 가 지금 동작하는가   아니다. 이미 42883 으로 죽어 있다 — §3.4 실측
> ```
>
> **따라서 helper 를 무조건 호출해도 「현재 동작하는 정상 경로」를 깨뜨리지 않는다.**
> **그러나 두 경로의 의도는 caller tenant 가 없는 자동·관리 격리다.**
> **그 둘이 언젠가 고쳐지면 무조건 gate 가 그것을 막는다.**
> **`I-1` 의 trusted-service exception 을 어떻게 표현할지는 §9 `OQ-1`.**

**호출자 · wrapper · 내부 호출 전수**

```text
DB 내 호출자      2개 — detect_threat · manage_subscription. 둘 다 §3.4 상태
public wrapper    0건
PostgREST 노출    PGRST_DB_SCHEMAS = public, graphql_public
                  catchmenu_common 미노출 → HTTP 도달 경로 0건
app · test 코드   저장소 내 ts · tsx · js · py 참조 0건
```

**함수 변경 시 영향받는 test · 문서 · migration**

```text
migration 참조    0090 정의·ACL · 0095 주석 · 0112 호출 · 0121 호출
                  000701 §14.5 — 기존 migration 을 고치지 않는다.
                  새 migration 에서 CREATE OR REPLACE 한다
in-DB 테스트       run_integration_test 2 overload 모두 isolate_tenant 미참조 — 실측 0회
docs 참조          42개 파일. 내용 갱신 여부는 gate 종료 후 판단
```

> ⚠️ **`HD-1` 반영 — 2026-09-21. 위 조사 사실은 그대로 둔다.**
>
> **`assert_caller_tenant_scope` 재사용은 `isolate_tenant` 에 대해 기각됐다.**
>
> ```text
> 기각 사유   helper 의 판정식은 caller tenant == target tenant 다
>            601902 TI-3 의 두 적법 주체는 platform-level 이며
>            그 caller tenant 는 정의상 target tenant 와 다르다
>            helper 를 그대로 걸면 TI-3 의 적법 경로를 영구 차단하고
>            TI-3 이 금지한 주체만 통과시키게 된다
> ```
>
> **위 「적합」 판정은 `2026-09-11` 시점의 기술적 적합성 조사였다.**
> **`HD-1` 은 그 조사를 부정하지 않고 적용 대상을 바꾼 것이다** — `isolate_tenant` 는 `I-1b` 다.
>
> ```text
> 따라서 직접 수정 후보가 바뀐다
>   isolate_tenant 본문에 platform-security authority gate 를 둔다
>   그 gate 의 물리적 표현은 미확정 — §9 OQ-1
>   0173 경계 유지 — helper 안에 claim 면제를 되넣지 않는다
> ```
>
> **`service_role` · trusted internal caller 실측표는 그대로 유효하다.**
> **`detect_threat` · `manage_subscription` 을 이번 gate 에서 고치지 않는다** — §7.

### §5.2 `H03-F2` — `update_business_hours` → `ensure_store_settings`

**직접 수정 후보 객체**

| 객체 | 왜 후보인가 |
|---|---|
| `catchmenu_store.ensure_store_settings(uuid,uuid)` | pair 검사 0회. `H03-F2` 의 실제 write 지점이다 |
| `catchmenu_store.update_business_hours(uuid,uuid,jsonb,text,uuid,text)` | `I-1` caller authority 0회. `stores` 를 읽지만 결과를 검사하지 않는다 |
| 새 migration 1개 | 위 함수 본문 교체용. 번호 미확정 |
| `catchmenu_store.store_settings` 의 새 제약 | §5.3 의 migration-level 가능성 판단 대상 |

**현재 상태 실측**

```text
update_business_hours(p_tenant_id uuid, p_store_id uuid,
                      p_business_hours jsonb, p_actor_type text,
                      p_actor_id uuid, p_correlation_id text)
  DEFINER · authenticated=X/postgres · overload 0건
  current_tenant_id 0회 · assert_caller_tenant_scope 0회
  tenant_status 0회 · isolation_state 0회
  정의 migration 0049_create_store_settings_rpc.sql
  ACL           0049 700~703

ensure_store_settings(p_tenant_id uuid, p_store_id uuid) returns uuid
  DEFINER · proacl = postgres=X/postgres | authenticated=X/postgres
  overload 0건
  본문  store_settings 를 (store_id, tenant_id) 로 조회하고
        없으면 (p_tenant_id, p_store_id) 를 그대로 INSERT 한다
        stores 를 전혀 읽지 않는다
  정의 migration 0049_create_store_settings_rpc.sql
  ACL           0049 686~689
```

**`ensure_store_settings` 는 공유 helper 다 — 호출자 전수 5개**

| caller | SECURITY | authenticated EXECUTE | `stores` 읽기 | pair 로 gate 하는가 |
|---|---|---|---|---|
| `catchmenu_store.update_business_hours(...)` | DEFINER | `t` | 있음 | **아니다** — `H03-F2` |
| `catchmenu_store.get_store_settings(uuid,uuid)` | DEFINER | `t` | 있음 | 미실측 — §9 `OQ-3` |
| `catchmenu_store.toggle_store_mode(...)` | DEFINER | `t` | 있음 | 미실측 — §9 `OQ-3` |
| `catchmenu_store.update_kds_capacity_threshold(...)` | DEFINER | `t` | 있음 | 미실측 — §9 `OQ-3` |
| `catchmenu_hq.create_franchise_store(...)` | DEFINER | `t` | 있음 | **아니다** — `H03-F3`. drift 로 도달 전 실패 |

> ⚠️ **pair 검사를 `ensure_store_settings` 에 넣으면 5개 caller 전부에 적용된다.**
>
> ```text
> 이득   H03-F2 를 한 곳에서 닫는다. 나머지 3개 caller 도 함께 닫힌다
> 위험   H-03-5 가 정한 path scope 를 넘는다
>        get_store_settings · toggle_store_mode ·
>        update_kds_capacity_threshold 의 정상 경로가 회귀 대상이 된다
>        create_franchise_store 는 drift 로 여전히 도달 못 한다
> ```
>
> **pair 검사를 `update_business_hours` 에만 넣으면 `I-3` 범위와 정확히 맞지만,**
> **`ensure_store_settings` 는 여전히 무방비 helper 로 남는다.**
> **어느 쪽인지 정하지 않는다 — §9 `OQ-2`.**

**`store_settings` 의 제약 실측**

```text
store_settings_pkey            PRIMARY KEY (id)
uq_store_settings              UNIQUE (store_id)
store_settings_store_id_fkey   FOREIGN KEY (store_id)  → catchmenu_hq.stores(id)
store_settings_tenant_id_fkey  FOREIGN KEY (tenant_id) → catchmenu_hq.tenants(id)
chk_kds_threshold · chk_peak_time_array · chk_pre_order_minutes · chk_store_mode
  전부 값 범위 CHECK. tenant 정합과 무관
```

> ⚠️ **`HD-2` 반영 — 2026-09-21. 위 조사 사실은 그대로 둔다.**
>
> **pair guard 위치는 `catchmenu_store.ensure_store_settings` 로 확정됐다.**
>
> ```text
> 근거   ensure_store_settings 는 (p_tenant_id, p_store_id) 를 받아
>        store_settings 에 INSERT 하는 writer 다
>        H-03-2 의 적용 대상이다
>
> 검증식  stores.id = p_store_id AND stores.tenant_id = p_tenant_id
> 실패    INSERT · UPDATE 전에 fail closed
> ```
>
> **직접 수정 후보가 하나로 좁혀진다.**
>
> ```text
> 확정    catchmenu_store.ensure_store_settings(uuid,uuid)   pair guard
> 확정    새 migration 1개 — 번호 미확정
>
> 제외    store_settings 의 새 schema 제약        HD-3 이 기각
> ```
>
> **`update_business_hours` 의 caller authority 검사는 별개 책임이다** — `HD-5`.
> **`I-1a` 를 어느 entry point 에 거는지는 `602060` 이 §3 으로 확정한다.**
>
> **§5.2 의 caller 전수표 5행은 그대로 유효하며, §3.5 가 그중 3개를 증명된 entry point 로 승격했다.**

### §5.3 migration-level 강제가 가능한가 — 후보만

**결정하지 않는다.** 가능성만 적는다.

```text
후보 A   stores 에 UNIQUE (id, tenant_id) 를 만들고
         store_settings 에 FOREIGN KEY (store_id, tenant_id)
         REFERENCES stores (id, tenant_id) 복합 FK 를 건다

         모든 writer 를 독립적으로 안전하게 만든다.
         함수를 고치지 않아도 direct SQL 까지 막힌다.

         전제 실측
           stores 의 UNIQUE · PK          (id) · (tenant_id, store_code)
           (id, tenant_id) UNIQUE          없음 — 먼저 만들어야 한다
           (tenant_id, store_id) 쌍 보유 테이블   138개
           그중 stores 로의 2-컬럼 복합 FK 보유    0개
           선례가 없다. store_settings 가 첫 사례가 된다

후보 B   store_settings 에 CHECK 로 강제한다
         불가. CHECK 는 다른 테이블을 참조할 수 없다

후보 C   store_settings 에 BEFORE INSERT OR UPDATE trigger 를 단다
         가능하나 체인 7개 테이블의 현행 trigger 는 전부 set_updated_at() 뿐이다
         이 저장소에 정합 검사 trigger 선례가 없다

후보 D   function-level guard 만 둔다
         H03-F1 과 형태가 같아 일관된다
         그러나 direct SQL 은 막지 못한다
         현재 anon · authenticated · service_role 모두 테이블 권한 0이라
         실익은 제한적이다
```

**기존 데이터가 새 constraint 를 통과하는가 — 실측**

```text
store_settings 총 행        0
  orphan store_id           0
  tenant · store mismatch   0
stores 총 행                1
tenants 총 행               1

후보 A · C 어느 쪽도 기존 데이터에 걸리지 않는다
```

> ⚠️ **데이터가 반증력을 갖지 못한다.**
> **「mismatch 0」은 「막혀 있다」가 아니라 「아직 만들어진 적 없다」다.**

> ⚠️ **`HD-3` 반영 — 2026-09-21. 위 후보 비교는 조사 사실로 그대로 둔다.**
>
> **선택은 후보 D — function-level guard 다.**
>
> ```text
> 채택   D   ensure_store_settings 안의 function-level guard
>
> 기각   A   stores UNIQUE (id, tenant_id) + composite FK
>        B   CHECK — 원래 불가
>        C   consistency trigger
> ```
>
> **schema-level integrity 를 영구 기각한 것이 아니다.**
> **이번 `RG-06` 의 verified executable path 를 최소 범위로 닫는 결정이다.**
> **138개 테이블의 schema-level consistency 문제는 Gate 범위 밖으로 유지한다.**
>
> ```text
> 따라서 이번 gate 의 catalog delta 예상
>   constraint · index · trigger   0
>   pg_proc prosrc 변경            N건
>   signature 변경                 0
> ```
>
> **기존 데이터 실측(`store_settings` 0행 · mismatch 0)은 어느 선택지에도 영향을 주지 않았다.**

### §5.4 `H03-F3` — 기록만 한다

`create_franchise_store` 를 **수정하지 않는다.** §3.3 에 current signature · drift · authority check 부재 · 현재 실행 불가 이유 · 별도 추적 근거를 기록했다. 이 절에서 추가로 정하는 것은 없다.

## §6 Indirect Impact Scope

### §6.1 caller · wrapper

| 객체 | 관계 | 영향 |
|---|---|---|
| `catchmenu_common.detect_threat(...)` | `isolate_tenant` 호출 | 이미 `42883`. gate 추가로 **새로 깨지는 것은 없다**. 나중에 호출부를 고치면 gate 에 걸린다 |
| `catchmenu_common.manage_subscription(...)` | `isolate_tenant` 호출 | 동일. 추가로 `service_role` schema USAGE 부재(`RG-F1`)로 진입 불가 |
| `catchmenu_store.get_store_settings(uuid,uuid)` | `ensure_store_settings` 호출 | `OQ-2` 에서 helper 를 고치기로 하면 회귀 대상 |
| `catchmenu_store.toggle_store_mode(...)` | 동일 | 동일 |
| `catchmenu_store.update_kds_capacity_threshold(...)` | 동일 | 동일 |
| `catchmenu_hq.create_franchise_store(...)` | 동일 | drift 로 도달 전 실패. 실질 영향 0 |
| public wrapper | — | **0건.** `public` schema 에 해당 이름 함수 0개 |

> ⚠️ **`HD-2` 반영 — 2026-09-21.**
>
> **위 표의 `caller` 중 셋이 간접 영향이 아니라 `I-3` 범위 안의 entry point 가 됐다.**
>
> ```text
> update_business_hours           E-1   증명됨 — §3.2
> toggle_store_mode               E-2   증명됨 — §3.5
> update_kds_capacity_threshold   E-3   증명됨 — §3.5
>
> get_store_settings              GUARDED — 간접 영향으로 남는다
>                                 helper 에 guard 가 들어가면 이중 검사가 된다
> create_franchise_store          drift 로 미도달 — H03-F3 latent
> ```

### §6.2 helper

```text
catchmenu_common.assert_caller_tenant_scope(uuid)
  0172 가 만들고 0173 이 claim 면제를 제거했다
  현재 15개 함수가 사용한다
  RG-06 이 재사용하면 17개가 된다 — isolate_tenant + update_business_hours
  helper 본문은 고치지 않는다 — §7

catchmenu_common.current_tenant_id()
  request.jwt.claims -> app_metadata ->> tenant_id
  assert_caller_tenant_scope 의 유일한 입력원
  고치지 않는다

catchmenu_common.set_updated_at()
  체인 7개 테이블의 유일한 trigger 함수
  이번 범위 밖
```

### §6.3 ACL

```text
변경 후보 0건
  isolate_tenant               authenticated EXECUTE 유지
                               I-1 은 런타임 검사이지 ACL 이 아니다
  update_business_hours        동일
  ensure_store_settings        동일
  assert_caller_tenant_scope   postgres 전용 유지

ACL 을 좁히는 것은 RG-06 의 수단이 아니다
RG-F6 — SECURITY DEFINER 105개 PUBLIC EXECUTE — 와 섞지 않는다
```

### §6.4 test

```text
in-DB    run_integration_test(uuid,uuid,text)
         run_integration_test(uuid,uuid,text,text)
         두 overload 모두 isolate_tenant · update_business_hours ·
         ensure_store_settings 참조 0회 — 실측
         회귀 자동 검증 장치가 없다. §8 을 수기로 수행해야 한다

저장소     ts · tsx · js · py 에서 세 함수 참조 0건
```

> ⚠️ **`RG-F11` 이 지적한 `run_integration_test` 의 한계가 여기서도 드러난다.**
> **`RG-06` 의 회귀는 자동 harness 가 아니라 §8 의 수기 목록으로 증명해야 한다.**

### §6.5 documentation

```text
docs 참조 파일 수 — 실측
  isolate_tenant          42
  update_business_hours   15
  ensure_store_settings    7

이번 단계에서 만지는 문서
  602061   이 문서 — 신규
  602000 Readme        RG-06 행 · migration 목록 — gate 종료 후
  000005 · 000007      이 문서 색인 — 별도 지시 대기
  600023               변경 없음
```

## §7 Explicit Exclusions

이번 `RG-06` 에서 **건드리지 않는다.**

| # | 제외 대상 | 근거 |
|---|---|---|
| 1 | `legal_entities` schema 재설계 | `H-03-1` — 법적 주체 축은 tenant authority 축이 아니다 |
| 2 | `persons` schema 재설계 | `H-03-1` |
| 3 | `legal_entity_person_roles` · `legal_entity_representatives` | `H-03-1`. writer 0건 · 3 role 테이블 권한 0 — 실행 경로 미증명 |
| 4 | 138개 tenant · store 쌍 보유 테이블 전수 | `H-03-5` |
| 5 | `create_franchise_store` drift fix — `stores.extra_metadata` | `H-03-4`. `RG-F10` · `RG-F12` 계열로 별도 추적 |
| 6 | `merchant_account` cross-tenant 구조 | writer 0건 · 실행 경로 미증명. `OQ-7` 로만 남긴다 |
| 7 | cloud DB | 실측하지 않았다. 같다고 가정하지 않는다 |
| 8 | `RG-01` ~ `RG-05` 기존 migration `0172` ~ `0178` | `H-03-4` · `000701` §14.5. 재개방하지 않는다 |
| 9 | `assert_caller_tenant_scope` 본문 | `0173` 이 확정한 계약이다. 면제를 되넣지 않는다 |
| 10 | `isolate_tenant` 의 ISOLATED 값과 `chk_tenants_status` 불일치 | 별건. 쓰기 없이 runtime 확인이 불가능했다 — `OQ-4` |
| 11 | ACL 변경 | §6.3 |
| 12 | `detect_threat` · `manage_subscription` 의 오인자 호출 | 별건 finding 후보. `RG-06` 의 blocker 가 아니다 — `OQ-1` |

**`HD-1` ~ `HD-4` 반영 추가 제외 — 2026-09-21**

| # | 제외 대상 | 근거 |
|---|---|---|
| 13 | `stores` 에 `UNIQUE (id, tenant_id)` 신설 | `HD-3` — 이번 gate 는 function-level guard 로 닫는다 |
| 14 | `store_settings` 복합 FK (`store_id, tenant_id`) | `HD-3` |
| 15 | pair consistency trigger | `HD-3` |
| 16 | cloud DB parity 검증 | `HD-4` — `RG-06` PASS 의 필수조건이 아니다. 별도 deployment · parity 책임 |
| 17 | `assert_caller_tenant_scope` 를 `isolate_tenant` 에 거는 안 | `HD-1` — `TI-3` 의 두 적법 주체를 차단한다 |
| 18 | `isolate_tenant` 의 platform-security authority 물리 표현 확정 | `HD-1` — runtime representation 은 OPEN. `602060` 또는 별건이 정한다 |

> ⚠️ **`HD-3` · `HD-4` 는 영구 기각이 아니다.**
> **schema-level integrity 와 cloud parity 는 이번 Gate 범위 밖으로 유지되는 것이며 별도 책임으로 남는다.**

## §8 Regression Surface

fix 이후 **반드시 다시 검증해야 할 경로.** `600023` §3.5 에 따라 「미검증 경로 0건」을 §7 회귀에 포함한다.

### §8.1 `H03-F1` — `isolate_tenant`

| # | 경로 | 기대 |
|---|---|---|
| `R-1` | 자기 tenant 를 격리 (`p_isolate` 참) | 정상 동작 유지 |
| `R-2` | 자기 tenant 를 해제 (`p_isolate` 거짓) | 정상 동작 유지 |
| `R-3` | 타 tenant 를 격리 | **`42501` 거부** |
| `R-4` | 타 tenant 를 해제 | **`42501` 거부** — `RG-04` 우회 차단 |
| `R-5` | claims 없음 | **fail closed · `42501`** |
| `R-6` | claims malformed — `app_metadata` 없음 · `tenant_id` 가 uuid 아님 | **fail closed** |
| `R-7` | 존재하지 않는 `p_tenant_id`. claims 와는 일치 | 기존 `tenant_not_found` 응답 유지 |
| `R-8` | `detect_threat` · `manage_subscription` 경유 호출 | **여전히 `42883`.** gate 때문이 아님을 명시한다 |

### §8.2 `H03-F2` — `update_business_hours` · `ensure_store_settings`

| # | 경로 | 기대 |
|---|---|---|
| `R-9` | 자기 tenant · 자기 store 의 영업시간 변경 | 정상 동작 유지 |
| `R-10` | `store_settings` row 가 이미 있는 store 를 다시 변경 | 정상 — INSERT 아닌 기존 row 경로 |
| `R-11` | `store_settings` row 가 없는 자기 store 를 처음 변경 | 정상 — 최초 INSERT |
| `R-12` | tenant 와 store 가 불일치하는 쌍 | **거부** — `I-2` |
| `R-13` | 타 tenant · 그 tenant 의 실제 store | **거부** — `I-1` |
| `R-14` | 존재하지 않는 `store_id` | 기존 오류 형태 유지 |
| `R-15` | 존재하지 않는 `p_tenant_id` | 기존 오류 형태 유지 |
| `R-16` | claims 없음 · malformed | **fail closed** |

### §8.3 `OQ-2` 를 helper 쪽으로 정할 경우 추가되는 회귀

| # | 경로 | 기대 |
|---|---|---|
| `R-17` | `get_store_settings` 자기 tenant · 자기 store | 정상 유지 |
| `R-18` | `toggle_store_mode` 자기 tenant · 자기 store | 정상 유지 |
| `R-19` | `update_kds_capacity_threshold` 자기 tenant · 자기 store | 정상 유지 |
| `R-20` | 위 3개를 불일치 쌍으로 호출 | 거부 |

### §8.4 catalog delta

```text
예상 delta 를 먼저 적고 실측과 대조한다 — RG-01 ~ RG-05 와 같은 방식

함수 본문 교체만 하는 경우
  pg_proc prosrc 변경 N건 · signature 변경 0건
  constraint · index · trigger delta 0

§5.3 후보 A 를 채택하는 경우
  UNIQUE index +1 — stores
  FOREIGN KEY +1 — store_settings
  나머지 0
```

### §8.5 `HD` 반영 회귀 재정리 — 2026-09-21

`HD-2` 가 entry point 3개를 `I-3` 범위로 넣었다. `§8.3` 의 `R-17` ~ `R-20` 은 **조건부가 아니라 필수**가 된다.

| # | 경로 | 기대 | 책임 |
|---|---|---|---|
| `R-18` | `toggle_store_mode` 자기 tenant · 자기 store | 정상 유지 | helper pair guard |
| `R-19` | `update_kds_capacity_threshold` 자기 tenant · 자기 store | 정상 유지 | helper pair guard |
| `R-20` | 위 둘을 불일치 쌍으로 호출 | **거부 · fail closed** | helper pair guard |
| `R-17` | `get_store_settings` 자기 tenant · 자기 store | 정상 유지 — 이중 검사 회귀 확인 | helper pair guard |
| `R-21` | `create_franchise_store` | **여전히 `extra_metadata` 로 실패.** guard 때문이 아님을 명시 | — |

**`HD-1` 반영 — `isolate_tenant` 회귀의 기대값이 바뀐다.**

| # | 경로 | 초판 기대 | `HD-1` 반영 기대 |
|---|---|---|---|
| `R-1` | 자기 tenant 격리 (`p_isolate` 참) | 정상 동작 유지 | **`TI-3` 에 따라 일반 tenant caller 는 거부.** platform authority 가 있을 때만 허용 |
| `R-2` | 자기 tenant 해제 (`p_isolate` 거짓) | 정상 동작 유지 | **동일하게 거부** |
| `R-3` · `R-4` | 타 tenant 격리 · 해제 | 거부 | 거부 — 변함 없음 |
| `R-5` · `R-6` | claims 없음 · malformed | fail closed | fail closed — 변함 없음 |
| `R-7` | 없는 tenant (claims 일치) | `tenant_not_found` | **authority 판정이 먼저다.** 기대값은 `602060` 이 확정한다 |
| `R-8` | 내부 호출자 경유 | 여전히 `42883` | 변함 없음 — §7 12번 |

> ⚠️ **`R-1` · `R-2` 의 기대값 반전이 이번 `HD` 의 가장 큰 회귀 영향이다.**
> **초판은 「자기 tenant 격리는 정상 경로」로 적었고 `HD-1` 은 그것을 권한 없음으로 판정했다.**
> **초판 문면은 §8.1 에 그대로 두고 여기서 병기한다.**

> ⚠️ **`R-1` · `R-2` 를 거부로 바꾸면 현재 동작하는 경로 하나가 사라진다.**
> **`detect_threat` · `manage_subscription` 이 `42883` 으로 죽어 있으므로**
> **그 시점에 tenant-wide isolation 을 발동할 수 있는 경로가 0이 된다.**
> **그 상태를 허용할지는 `602060` §3 이 `OQ-1` 과 함께 판단한다.**

## §9 Open Questions

결정하지 않는다. 논점만 남긴다.

| # | 질문 | 왜 지금 못 정하는가 |
|---|---|---|
| `OQ-1` | `I-1` 의 trusted-service exception 을 무엇으로 표현하는가 | `detect_threat` · `manage_subscription` 이 의도한 자동·관리 격리 경로가 `42883` 으로 죽어 있다. 그 둘을 고칠지, 고친다면 어떤 권한 축으로 통과시킬지가 미정이다. `RG-F1` — service_role 도달 불가 — 와 얽힌다 |
| `OQ-2` | pair 검사를 `ensure_store_settings` 에 넣는가 `update_business_hours` 에만 넣는가 | helper 는 caller 5개를 가진다. helper 에 넣으면 `H-03-5` 의 path scope 를 넘고, caller 에만 넣으면 helper 가 무방비로 남는다 |
| `OQ-3` | `get_store_settings` · `toggle_store_mode` · `update_kds_capacity_threshold` 도 cross-tenant 로 실행 가능한가 | 네 함수 모두 `stores` 를 tenant 조건으로 읽지만 `update_business_hours` 는 그 결과를 검사하지 않았다. 나머지 3개는 **실행 증명을 하지 않았다.** 증명 전에는 finding 으로 올리지 않는다 |
| `OQ-4` | `isolate_tenant` 가 쓰는 ISOLATED 값이 `chk_tenants_status` 를 위반하는가 | 정적 대조상 허용 목록에 없어 `23514` 가 예상되나, read-only 가 `25006` 으로 먼저 막아 **runtime 확인이 불가능했다** |
| `OQ-5` | `stores` 에 `(id, tenant_id)` UNIQUE 를 만드는 것이 이 저장소의 방향인가 | 138개 테이블 중 복합 FK 선례가 0개다. 첫 사례를 만드는 결정이며 `H-03-5` 의 범위 제한과 긴장한다 |
| `OQ-6` | cloud DB 도 같은 상태인가 | `DATABASE_URL` 미설정으로 접속하지 않았다. 접속 권한을 누가 부여하는지 미정 |
| `OQ-7` | `merchant_account` cross-tenant 를 언제 다루는가 | 대조 제약 0건 · writer 0건 · 3 role 테이블 권한 0. 실행 경로 미증명이라 finding 이 아니다. 그러나 구조는 열려 있다 |

### §9.1 `HD` 반영 상태 — 2026-09-21

| # | 상태 | 처분 |
|---|---|---|
| `OQ-1` | **policy CLOSED · runtime representation OPEN** | `HD-1`. 유일한 미결 사항이다 — §9.2 |
| `OQ-2` | **CLOSED** | `HD-2` — `ensure_store_settings` 에 pair guard 를 둔다 |
| `OQ-3` | **CLOSED — 실측으로 닫았다** | §3.5. `E-2` · `E-3` 신규 증명 · `get_store_settings` GUARDED |
| `OQ-4` | **CLOSED — 이번 Gate 범위 밖** | 별도 finding 유지. `H03-F1` 의 증명된 위험 방향과 직접 관련 없다. 고치지 않는다 |
| `OQ-5` | **CLOSED** | `HD-3` — composite FK · UNIQUE · trigger 전부 이번 Gate 에서 도입하지 않는다 |
| `OQ-6` | **CLOSED** | `HD-4` — local/dev 로 닫는다. cloud parity 는 별도 책임 |
| `OQ-7` | **CLOSED — 실측으로 닫았다** | §3.6. writer 0 · executable path 0 → 구조 관측 유지. blocker 아님 |

### §9.2 남은 미결 — 1건

| # | 질문 | 왜 아직 못 정하는가 |
|---|---|---|
| `OQ-1` (runtime) | `601902` `TI-3` 의 두 platform-level authority 를 런타임에서 **무엇으로 식별하는가** | `HD-1` 이 정책은 닫았다. 물리 표현은 열려 있다. `RG-F1` — `service_role` 이 13 / 15 스키마에 `USAGE` 가 없다 — 가 후보 하나를 물리적으로 막고 있고, `0173` 경계가 claim 기반 표현을 금지한다. `010640` §5 `authority_scope` · `010630` §6 15 상태가 후보 어휘이나 어느 것도 물리 표현을 지정하지 않는다 |

> ⚠️ **초판 §9 의 `OQ-1` ~ `OQ-7` 원문은 위 표 앞에 그대로 보존돼 있다.**
> **이 절은 그 상태를 갱신한 것이며 원문을 고치지 않았다.**


## §10 Approval Boundary

이 문서가 **하지 않은 것**을 명시한다.

```text
invariant 를 확정하지 않았다      §4 는 초안이다. 600023 §3.2 에 따라 Human 이 확정한다
migration 을 만들지 않았다        번호도 확정하지 않았다
함수를 고치지 않았다              SQL · constraint · ACL 변경 0건
방법을 채택하지 않았다            §5.3 의 A · B · C · D 는 후보다
H03-F3 를 처분하지 않았다         §2.4 의 latent 유지
OQ 7건을 닫지 않았다
```

**다음 단계에 필요한 Human 승인**

```text
1   §4 invariant 확정 — I-1 · I-2 · I-3
2   OQ-1  trusted-service exception 표현
3   OQ-2  pair 검사 위치
4   OQ-5  복합 FK 채택 여부
5   RG-06 gate 문서 번호 602060 배정 확인
6   migration 번호 배정
```

> ⚠️ **승인 전에는 `602060` gate 문서를 만들지 않는다.**
> **`600023` §3.1 의 PASS 조건은 「§2 의 공격이 §6 에서 실패한다」이며**
> **그 §2 공격 재현은 `602060` 의 몫이다. 이 문서는 그 앞에 선다.**

### §10.1 `HD` 반영 갱신 — 2026-09-21

**닫힌 것**

```text
HD-1   isolate_tenant 는 platform-security authority 를 요구한다   policy CLOSED
HD-2   pair guard 위치 = ensure_store_settings                     CLOSED
HD-3   이번 Gate 는 function-level guard 로 닫는다                 CLOSED
HD-4   local/dev 로 PASS 를 닫는다                                 CLOSED
HD-5   entry point authority 와 helper pair 책임을 분리한다         CLOSED
```

**여전히 하지 않은 것**

```text
invariant 를 확정하지 않았다     §4 초안 + HD 개정 병기 상태다
                                602060 이 §3 으로 확정한다
migration 을 만들지 않았다       번호도 확정하지 않았다
함수를 고치지 않았다             SQL · constraint · ACL 변경 0건
OQ-1 runtime representation     열려 있다 — §9.2
```

**다음 단계에 필요한 Human 승인 — 갱신**

```text
1   OQ-1 runtime representation — platform-security authority 의 물리 표현
2   I-1a 를 어느 entry point 에 거는가
      HD-5 가 책임을 분리했으므로 helper pair guard 와 별개 결정이다
3   R-1 · R-2 기대값 반전 수용 여부
      tenant-wide isolation 발동 경로가 일시적으로 0이 되는 상태
4   RG-06 gate 문서 번호 602060 배정 확인
5   migration 번호 배정
```

> ⚠️ **초판 §10 의 목록은 위에 그대로 있다.**
> **`HD-1` ~ `HD-5` 로 닫힌 항목은 이 절이 갱신한다.**

## §11 근거 문서 목록 (`000701` §46)

| 문서 | 인용 | 지위 |
|---|---|---|
| `600023_Governance_Runtime_Gate_Spiral.md` | §3 · §3.1 · §3.2 · §3.4 · §3.5 · §6 | ACTIVE |
| `601919_Audit_Independent_Foundation_Audit.md` | `H-03` | ACTIVE |
| `601902_Register_Stage1_Business_Rules.md` | `TI-2` · `TI-3` · `TI-12` · `TI-13` | ACTIVE — CONTRACT FROZEN |
| `602010_Evidence_RuntimeGate_Caller_Tenant_Scope.md` | §9 `RG-F1` · §10.1 `RG-F3` | ACTIVE |
| `602040_Evidence_RuntimeGate_Tenant_Lifecycle_Order_Gate.md` | `RG-04` lifecycle gate | ACTIVE |
| `602050_Evidence_RuntimeGate_Order_Request_Identity.md` | `RG-F10` · `RG-F11` · `RG-F12` | ACTIVE |
| `010004` | §7 DENY_UNLESS_CONTEXT_MATCHES | ACTIVE |
| `010630` | §28 DENY_UNLESS_EXPLICITLY_ALLOWED | ACTIVE |
| `000701` | §14.5 · §46 · §47 | ACTIVE |
