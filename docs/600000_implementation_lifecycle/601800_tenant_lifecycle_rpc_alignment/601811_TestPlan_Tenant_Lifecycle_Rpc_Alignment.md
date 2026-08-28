# 601811_TestPlan_Tenant_Lifecycle_Rpc_Alignment.md

Status: Active
Lifecycle: TestPlan
Last Updated: 2026-08-29

## §0 성격과 범위

`000701` §47.1 의 **4단계 설계문서 정합화** 산출물이다.

**무엇을 PASS 라 할 것인가를 정한다.**

```text
601810 I-1 ~ I-56 · X-1 ~ X-8 의 검증 방법
```

> ⚠️ **물리 객체명을 신규 확정하지 않는다.**
> **허용 파일 · 금지 조작 · 물리 경계는 ChangeContract(`601812`) 소관이다.**

**검증 등급 — A**(`HD-0-A-2-1`). blind design review · fault injection · 독립 감사를 생략하지 않는다.

### §0.1 Test ID 규칙

```text
BL-N      기준선 — 착수 전 · 후 실측
PRE-N     착수 직전 게이트
TP-P-N    Positive — 있어야 할 것이 있는가
TP-N-N    Negative — 없어야 할 것이 없는가
TP-S-N    상태 조합
TP-C-N    멱등성 · 동시성
TP-E-N    외부 이벤트
TP-R-N    Regression
TP-RB-N   Rollback
AC-N      Acceptance Criteria
```

**각 Test 는 검증 대상 `I-N` 또는 `X-N` 을 갖는다.**

## §1 검사하는 것과 검사하지 않는 것

**`601716` §0.2 형식을 따른다.**

> ⚠️ **미래 목표를 검사하면 통과할 수 없는 시험이 된다.**
> **지워버리면 요구 자체가 사라진 것으로 읽힌다.**
> **금지(negative)로 검사하고 이월 항목에 남긴다.**

### §1.1 검사하지 않는 것 — 이월

| 대상 | 이월처 | 근거 |
|---|---|---|
| `manage_subscription` 의 전이 | 별도 Subscription Lifecycle 워크패킷 | `HD-0-A-2-7` |
| `tenant_status` 5값 사이의 전이 | 동상 | `HD-0-A-2-7` · `601810` `I-28` |
| RLS policy 존재 · 기능별 차단 9행 | `0-C` | `000221` §4.4 · `601803` `U-7`·`U-16` |
| 구체적 역할 이름 · 권한 · 승인권자 배정 | `0-C` | `HG-A-10` · `HG-A-15` |
| provisioning RPC 재설계 · `C-3` · `NOT NULL` 승격 | `0-A-3` | `601809` §3 |
| 과금 금액 계산 · 정산 | 별도 | `601810` §8.1 `U-13` |
| 포인트 provider 전환 절차 | 후속 포인트 워크패킷 | `HG-A-14` |
| isolation queue · billing review task 의 물리 구조 | `601812` | `601803` `U-8`·`U-10` |

### §1.2 대신 negative 로 검사한다

```text
0-A-2 가 manage_subscription 을 수정하지 않았는가        prosrc md5 불변
0-A-2 가 RLS policy 를 만들지 않았는가                   policy 수 불변
0-A-2 가 tenant_status 를 변경하지 않았는가              값 분포 불변
0-A-2 가 나머지 4축을 건드리지 않았는가                   관련 객체 불변
0-A-2 가 merchant_account 를 생성 · 연결 변경하지 않았는가  행 수 · 연결 불변
```

> ⚠️ **이월 항목이 「이월로 명시되어 있는가」 자체를 `AC` 로 검사한다** — §11.

## §2 기준선 (`BL-N`)

**`601802` 가 기록한 값을 기준선으로 삼되 착수 직전 재측정을 요구한다.**

| # | 측정 대상 | before 기대 | after 기대 | 검증 `I-N`/`X-N` |
|---|---|---|---|---|
| BL-1 | `isolate_tenant` prosrc md5 | `601802` §5.1 값 | **변경됨** — 수리 대상 | `X-1` · `601809` §4.2 |
| BL-2 | `manage_subscription` prosrc md5 | `601802` §5.1 값 | **불변** | `I-9` · `X-4`·`X-5` |
| BL-3 | `detect_threat` prosrc md5 | `601802` §9.1 값 | **불변** | `X-6` |
| BL-4 | 나머지 호출 금지 4함수 prosrc md5 | `601802` §9.1 값 | **불변** | `601809` §4.4 |
| BL-5 | `isolation_state` 를 참조하는 함수 수 | **0** | **1 이상** | `I-13` · `X-2` |
| BL-6 | `tenant_status` 를 참조하는 함수 수 | 7 | 7 이상 — 감소 0 | `I-9` |
| BL-7 | `catchmenu_hq` 함수 수 | 착수 직전 실측 | 불변 또는 증가분 명시 | `TP-R` |
| BL-8 | `tenants` 행 수 | 착수 직전 실측 | **불변** | `I-9` |
| BL-9 | `tenants.isolation_state` 값 분포 | 착수 직전 실측 | **불변** — migration 이 상태를 바꾸지 않는다 | `I-2` · `I-21` |
| BL-10 | `tenants.tenant_status` 값 분포 | 착수 직전 실측 | **불변** | `I-9` |
| BL-11 | RLS policy 수 — 전 스키마 | 착수 직전 실측 | **불변** | `I-6` · §1.2 |
| BL-12 | `tenant_status` · `isolation_state` CHECK 허용값 | 5값 / 2값 | **불변** | `I-4` · `I-5` |
| BL-13 | `merchant_accounts` 행 수 · `stores.merchant_account_id` 연결 | 착수 직전 실측 | **불변** | `I-10` · `I-11` |

> ⚠️ **`BL-1` 만 「변경됨」이 기대값이다.**
> **나머지는 전부 불변이 기대값이며, 불일치는 environment drift 로 본다.**

> ⚠️ **`601802` 기록값과 착수 직전 실측이 다르면 중단한다.**
> **문서 값을 기준으로 삼지 않고 실측을 기준으로 삼는다.**

## §3 착수 직전 게이트 (`PRE-N`)

| # | 게이트 | 미충족 시 |
|---|---|---|
| PRE-1 | Stage 7 Human 승인이 기록돼 있다 | 착수 금지 |
| PRE-2 | 환경이 최신 migration 까지 적용돼 있다 | 착수 금지 |
| PRE-3 | `BL-1` ~ `BL-13` 재측정이 `601802` 기록과 일치한다 | **environment drift — 중단** |
| PRE-4 | 검증자가 `601809` · `601810` · `601811` 의 원작자가 아니다 | 검증자 교체 — `000701` §37 |
| PRE-5 | `601812` ChangeContract 가 `Q-2` · `Q-3` · `Q-5` 를 닫았다 | `TP-C` · `TP-E` 일부 실행 불가 — §12 |
| PRE-6 | `601812` 가 `M-1` 파라미터명 처분을 정했다 | `TP-P` 일부 실행 불가 — `X-3` |
| PRE-7 | `601812` 가 `X-7` 조합 제약 신설 여부를 판정했다 | `TP-S` 일부 판정 기준 부재 |
| PRE-8 | canonical DB 는 read-only 로만 접속한다. 쓰기 검증은 disposable 환경에서 수행한다 | 검증 무효 |

> ⚠️ **`PRE-5` ~ `PRE-7` 은 `601812` 산출을 전제로 한다.**
> **TestPlan 이 ChangeContract 보다 먼저 확정되므로 게이트로만 둔다.**

## §4 Positive Test (`TP-P-N`)

| # | 검사 | 기대 | 검증 `I-N`/`X-N` |
|---|---|---|---|
| TP-P-1 | `isolation_state` 를 읽는 경로가 존재한다 | 참조 함수 1건 이상 | `X-2` · `I-13` |
| TP-P-2 | `isolate_tenant` 가 `isolation_state` 를 `ISOLATED` 로 변경한다 | 변경 성공 | `I-26` · `X-1` |
| TP-P-3 | `isolate_tenant` 호출이 실행 가능하다 — 파라미터명 일치 | 호출 성공 | `X-3` · `X-1` |
| TP-P-4 | 격리 해제가 원인 해소 확인 · Human 승인 · 감사 기록 세 요건을 모두 거친다 | 세 요건 충족 시에만 `NONE` | `I-22` · `X-8` |
| TP-P-5 | 세 요건 중 하나라도 미충족이면 `ISOLATED` 가 유지된다 | 해제 거부 | `I-23` |
| TP-P-6 | 격리 · 해제 시 감사 기록이 남는다 | 감사 행 생성 | `I-31` · `I-56` |
| TP-P-7 | 격리 원인의 임시 분류값이 기록되고 임시임이 표시된다 | 임시 표시 존재 | `I-54` |
| TP-P-8 | 귀책 최종 확정 이력이 감사 기록에 남는다 | 확정 이력 존재 | `I-55` · `I-56` |
| TP-P-9 | `ISOLATED` 상태에서 CatchMenu 일반 runtime 접근이 거부된다 | 거부 | `I-12` · `I-14` |
| TP-P-10 | 외부가 해당 tenant 자격으로 호출하는 CatchMenu API 가 fail-closed 로 거부된다 | 거부 | `I-17` |

> ⚠️ **`TP-P-3` 은 `PRE-6`(`M-1` 처분)에 종속된다.**
> **`TP-P-7` · `TP-P-8` 은 임시 분류값의 물리 표현이 `601812` 에서 정해진 뒤 실행한다.**

## §5 Negative Test (`TP-N-N`)

| # | 검사 | 기대 | 검증 `I-N`/`X-N` |
|---|---|---|---|
| TP-N-1 | `isolate_tenant` 가 `tenant_status` 를 변경하지 않는다 | `BL-10` 불변 | `I-9` · `I-26` |
| TP-N-2 | `isolate_tenant` 가 subscription 상태 · 청구조건을 변경하지 않는다 | 관련 테이블 불변 | `I-26` |
| TP-N-3 | `manage_subscription` prosrc md5 불변 | `BL-2` 일치 | `X-4` · `X-5` |
| TP-N-4 | `detect_threat` 및 나머지 호출 금지 5함수 prosrc md5 불변 | `BL-3` · `BL-4` 일치 | `X-6` |
| TP-N-5 | RLS policy 수 불변 | `BL-11` 일치 | `I-6` |
| TP-N-6 | `tenant_status` · `isolation_state` CHECK 허용값 밖 값이 들어가지 않는다 | 삽입 거부 | `I-4` · `X-1` |
| TP-N-7 | 격리 해제가 `tenant_status` 를 변경하지 않는다 — `SUSPENDED` 는 `SUSPENDED` 로 남는다 | 값 유지 | `I-25` |
| TP-N-8 | `TERMINATED` tenant 가 일반 격리 복구 경로로 해제되지 않는다 | 복구 경로 진입 거부 | `I-24` |
| TP-N-9 | `merchant_accounts` 행 수와 `stores.merchant_account_id` 연결이 불변이다 | `BL-13` 일치 | `I-10` · `I-11` |
| TP-N-10 | `StoreServiceStatus` · `StoreOperatingStatus` · `TrialStatus` · `MerchantAccountStatus` 관련 객체가 변경되지 않는다 | 불변 | `I-7` |
| TP-N-11 | 두 축 중 한 축 변경이 다른 축을 자동 변경하지 않는다 | 상대 축 값 유지 | `I-2` |
| TP-N-12 | 자동 분류값만으로 과금 조정이 실행되지 않는다 | 과금 조정 0건 | `I-54` · `I-48` |
| TP-N-13 | 환불 · 크레딧 · 청구중단이 Human 승인 없이 실행되지 않는다 | 실행 0건 | `I-48` |
| TP-N-14 | 격리 중 이벤트 폐기가 0건이다 | 폐기 0 | `I-35` |
| TP-N-15 | 격리 중 KDS release 가 발생하지 않는다 | release 0 | `I-38` |
| TP-N-16 | CatchMenu 밖 대상에 대한 차단 조작이 0건이다 — 외부 제품 DB · 외부 시스템 자체 운영 | 조작 0 | `I-15` · `I-16` · `I-18` |
| TP-N-17 | 고객의 자발적 사용 중지를 `ISOLATED` 로 기록하는 경로가 없다 | 경로 0 | `I-20` |
| TP-N-18 | 격리 중 응답 실패 반복이 발생하지 않는다 | 재시도 정책 준수 | `I-36` |

> ⚠️ **`TP-N-16` 은 이 저장소 안에서만 검사한다.**
> **외부 제품의 DB 를 관측할 수 없으므로 「CatchMenu 코드가 그 대상을 조작하지 않는다」로 검사한다.**

## §6 상태 조합 Test (`TP-S-N`)

**10 조합 각각에서 접근 판단이 `I-13` 대로 작동하는지 본다.**

| # | 조합 | 기대 | 검증 `I-N` |
|---|---|---|---|
| TP-S-1 | `TRIAL` + `NONE` | `tenant_status` 축 허용. `isolation_state` 축 허용 | `I-5` · `I-13` |
| TP-S-2 | `TRIAL` + `ISOLATED` | `isolation_state` 축 거부 → 접근 거부 | `I-13` · `I-14` |
| TP-S-3 | `ACTIVE` + `NONE` | 두 축 모두 허용 → 접근 허용 | `I-13` |
| TP-S-4 | `ACTIVE` + `ISOLATED` | `isolation_state` 축 거부 → 접근 거부 | `I-12` · `I-14` |
| TP-S-5 | `SUSPENDED` + `NONE` | `tenant_status` 축 거부 → 접근 거부 | `I-13` |
| TP-S-6 | `SUSPENDED` + `ISOLATED` | 두 축 모두 거부 → 접근 거부 | `I-13` |
| TP-S-7 | `CANCELLED` + `NONE` | `tenant_status` 축 거부 → 접근 거부 | `I-13` |
| TP-S-8 | `CANCELLED` + `ISOLATED` | 두 축 모두 거부 → 접근 거부 | `I-13` |
| TP-S-9 | `TERMINATED` + `NONE` | `tenant_status` 축 거부 → 접근 거부 | `I-13` |
| TP-S-10 | `TERMINATED` + `ISOLATED` | 두 축 모두 거부. 일반 복구 대상 아님 | `I-13` · `I-24` |
| TP-S-11 | 10 조합 전부가 저장 가능하다 | 저장 성공 | `I-5` |
| TP-S-12 | 두 축을 하나의 전순위로 합친 판정 로직이 존재하지 않는다 | 전순위 비교 0건 | `I-1` · `I-13` |

> ⚠️ **`TP-S-1` ~ `TP-S-10` 은 「두 축의 허용조건을 각각 검사했는가」를 본다.**
> **결과가 같아도 단일 축 분기로 구현됐다면 `TP-S-12` 가 FAIL 이다.**

> ⚠️ **판정 위치(API · 함수 · RLS)는 `Q-5` 로 열려 있다**(`601812` 소관).
> **`TP-S` 는 판정이 어디서 일어나든 결과가 `I-13` 과 같은지만 본다.**

## §7 멱등성 · 동시성 Test (`TP-C-N`)

| # | 검사 | 기대 | 검증 `I-N` |
|---|---|---|---|
| TP-C-1 | 동일 격리 요청을 재실행하면 같은 결과로 성공한다 | 중복 부작용 0 | `I-29` |
| TP-C-2 | 동일 해제 요청을 재실행하면 같은 결과로 성공한다 | 중복 부작용 0 | `I-29` |
| TP-C-3 | 오래된 요청이 최신 상태를 되돌리지 못한다 | 되돌림 0 | `I-30` |
| TP-C-4 | 실패 시 상태 변경과 감사 기록이 함께 rollback 된다 | 부분 반영 0 | `I-31` |
| TP-C-5 | 성공 시 상태 변경과 감사 기록이 함께 commit 된다 | 한쪽만 남는 경우 0 | `I-31` |

> ⚠️ **`Q-2` · `Q-3` 이 열려 있다.**
> **멱등성 단위와 원자성 경계가 `601812` 에서 정해진다.**
> **여기서는 「무엇이 참이어야 하는가」로만 쓰고 구체적 키와 트랜잭션 경계를 지정하지 않는다.**

> ⚠️ **`TP-C` 는 fault injection 으로 검증한다** — A급(`HD-0-A-2-1`).
> **`601747` 이 `0-A` 에서 쓴 disposable container 방식을 따른다.**

## §8 외부 이벤트 Test (`TP-E-N`)

| # | 검사 | 기대 | 검증 `I-N` |
|---|---|---|---|
| TP-E-1 | 격리 중에도 외부 provider 의 확정 사실이 수신 · 보존된다 | 원문 보존 | `I-33` |
| TP-E-2 | 격리 중에도 서명 검증과 중복 검증이 수행된다 | 검증 수행 | `I-34` |
| TP-E-3 | tenant 영업 side effect 가 보류 상태로 남는다 | 보류 표시 존재 | `I-37` |
| TP-E-4 | 보류 사유가 기술 격리인지 네트워크 단절인지 구분된다 | 구분 가능 | `I-41` |
| TP-E-5 | 해제 후 재처리에서 동일 이벤트가 중복 적용되지 않는다 | 중복 0 | `I-39` |
| TP-E-6 | 외부 webhook 이 격리 중 직접 반영되지 않는다 | 직접 반영 0 | `I-40` |
| TP-E-7 | 거래 provider 와 실행 provider 가 구분돼 기록된다 | 구분 존재 | `I-33` · `601702` §1.43 |
| TP-E-8 | 격리 중 차단된 요청이 사용량 산정에 포함되지 않는다 | 미산정 | `I-44` |
| TP-E-9 | 보류 후 복구 시 확정된 이벤트만 사용량에 산정된다 | 확정분만 | `I-45` |

> ⚠️ **`TP-E-3` ~ `TP-E-5` · `TP-E-7` 은 isolation queue 의 물리 표현에 종속된다**(`U-8` · `601812`).
> **물리가 정해지기 전에는 `SKIP` 사유를 명시하고 PASS 로 추정하지 않는다.**

## §9 Regression Test (`TP-R-N`)

| # | 검사 | 기대 | 검증 |
|---|---|---|---|
| TP-R-1 | `catchmenu_hq` 함수 수 | `BL-7` 대비 증감 명시 | 범위 이탈 탐지 |
| TP-R-2 | 전 스키마 테이블 수 · 컬럼 수 | 계약 밖 증감 0 | 범위 이탈 탐지 |
| TP-R-3 | RLS policy 수 | `BL-11` 불변 | `I-6` |
| TP-R-4 | 호출 금지 7함수가 **catalog 에 존재**한다 | 7/7 존재 | `601809` §4.4 |
| TP-R-5 | 호출 금지 6함수 prosrc md5 불변 — `isolate_tenant` 제외 | 불변 | `601809` §4.4 |
| TP-R-6 | `tenants` 행 수 불변 | `BL-8` 일치 | `I-9` |
| TP-R-7 | 두 축 CHECK 허용값 불변 | `BL-12` 일치 | `I-4` |
| TP-R-8 | `stores` · `merchant_accounts` 구조 불변 | 불변 | `I-11` |
| TP-R-9 | 과금 · 구독 7테이블 구조 불변 | 불변 | `I-46` |
| TP-R-10 | EXECUTE ACL 이 축소되거나 확대되지 않는다 — `isolate_tenant` 포함 | `601802` §9.2 대비 불변 | `I-32` · `0-C` 경계 |

> ⚠️ **「유효」를 검사하지 않는다.**
> **catalog 존재와 runtime executability 를 분리한다.**
> **known phantom(`tenants.company_name` 등)은 FAIL 사유가 아니다** — `X-4`.

## §10 Rollback Test (`TP-RB-N`)

| # | 검사 | 기대 | 검증 |
|---|---|---|---|
| TP-RB-1 | 역방향 적용 후 `isolate_tenant` prosrc md5 가 `BL-1` before 값으로 복원된다 | 복원 | `X-1` |
| TP-RB-2 | 역방향 적용 후 `isolation_state` 참조 함수 수가 `BL-5` before 값(0)으로 복원된다 | 복원 | `X-2` |
| TP-RB-3 | 역방향 적용이 `tenants` 데이터를 변경하지 않는다 | `BL-8` · `BL-9` · `BL-10` 불변 | `I-9` |
| TP-RB-4 | 역방향 적용이 RLS policy 수를 변경하지 않는다 | `BL-11` 불변 | `I-6` |
| TP-RB-5 | 역방향 적용은 disposable 환경에서 검증한다. canonical DB 는 read-only | canonical 전후 실측 동일 | `PRE-8` |
| TP-RB-6 | 역방향 적용 후 migration ledger 상태가 문서화된다 | 기록 존재 | `601746` §2.7 이 지적한 결함 |

> ⚠️ **`TP-RB-6` 은 `601746` §2.7 「rollback 후 migration history 불일치」를 승계한 것이다.**
> **`0-A` 에서 미입증으로 남은 항목을 이 나선에서 반복하지 않는다.**

## §11 Acceptance Criteria (`AC-N`)

| # | 조건 | 검증 |
|---|---|---|
| AC-1 | `BL-1` ~ `BL-13` 이 착수 전 · 후 모두 측정되고 기대와 일치한다 | §2 |
| AC-2 | `PRE-1` ~ `PRE-8` 이 착수 전 전건 충족됐다 | §3 |
| AC-3 | `TP-P` · `TP-N` · `TP-S` · `TP-C` · `TP-E` · `TP-R` · `TP-RB` 전건이 판정됐다 — 누락 0 | §4~§10 |
| AC-4 | `SKIP` 이 있으면 사유가 기록됐고 PASS 로 추정되지 않았다 | §12 |
| AC-5 | `I-1` ~ `I-56` · `X-1` ~ `X-8` 각각이 검증 또는 미검증 사유를 갖는다 | §12 |
| AC-6 | **`Q-2` · `Q-3` · `Q-5` 가 `601812` 소관으로 기록되어 있다** | `601810` §8.2 |
| AC-7 | **`manage_subscription` 절단이 명시되어 있다** | `601809` §3 · `601810` §0 · `601801` §1.6 병기 |
| AC-8 | **`HG-A-6` 이 이 나선에 검증 대상이 없음이 기록되어 있다** | `601801` §1.6 병기 · `601810` 검토 |
| AC-9 | **`HG-A-14` 가 이 나선에 검증 대상이 없음이 기록되어 있다** | `601809` §3 · `601801` §4 |
| AC-10 | `0-A-2` 가 `0-C` · `0-A-3` 범위를 침범하지 않았다 | `TP-N-5` · `TP-N-9` · `TP-N-10` · `TP-R-10` |
| AC-11 | `601505` §4 호출 금지 해제가 `isolate_tenant` 1건으로 한정됐다 | `601809` §4.4 · `TP-R-5` |
| AC-12 | 검증자가 `601809` · `601810` · `601811` 원작자가 아니다 | `PRE-4` · `000701` §37 |
| AC-13 | A급 절차가 생략되지 않았다 — blind design review · fault injection · 독립 감사 | `HD-0-A-2-1` |

> ⚠️ **`AC-6` ~ `AC-9` 는 「이월이 이월로 명시되어 있는가」를 검사한다.**
> **요구가 사라지지 않았음을 문서로 확인하는 항목이다**(§1).

## §12 미해결

### §12.1 `I-N` 커버리지 — 미검증 항목

| `I-N` | 미검증 사유 |
|---|---|
| I-3 | 「각각 별도 권한」의 권한 주체가 `0-C` 소관이다. 감사 기록 부분만 `TP-P-6` 가 검사한다 |
| I-8 | 「명시적 precondition 으로만 참조」는 참조 방식의 검사이며 `Q-5`(판정 위치)가 정해져야 검사 지점을 특정할 수 있다 |
| I-19 | 플랫폼 특권 경로는 `0-C` 가 정한다 |
| I-27 | 「각 전이가 허용/금지·주체·사유·전제를 명시한다」는 문서 요건이며 `601812` 가 전이 목록을 확정한 뒤 검사한다 |
| I-28 | 미선언 전이가 미정으로 남았는지는 `601812` 문서 검사로만 확인한다 |
| I-32 | 격리 실행 권한과 해제 권한의 분리는 `0-C` 소관. `TP-R-10` 이 ACL 불변만 검사한다 |
| I-42 · I-43 · I-46 · I-47 | 과금 금액 계산이 이 나선 밖이다. `TP-R-9` 가 구조 불변만 검사한다 |
| I-49 · I-50 · I-51 · I-52 · I-53 | billing review task 의 물리 표현이 `601812` 에서 정해진다. 물리 확정 전에는 `SKIP` |
| I-21 | 초기값 `NONE` 은 `BL-9` 로 검사하나 **bootstrap 경로 자체는 `0-A-3` 소관**이다 |

### §12.2 `X-N` 커버리지

| `X-N` | 검증 | 비고 |
|---|---|---|
| X-1 | `TP-P-2` · `TP-N-6` · `TP-RB-1` | 수리 결과 검증 |
| X-2 | `TP-P-1` · `BL-5` · `TP-RB-2` | 참조 함수 0 → 1 이상 |
| X-3 | `TP-P-3` | **`PRE-6`(`M-1` 처분)에 종속** |
| X-4 | `TP-N-3` · `TP-R-5` | negative 만. phantom 은 FAIL 사유 아님 |
| X-5 | `TP-N-3` | negative 만. guard 신설은 이월 워크패킷 |
| X-6 | `TP-N-4` | negative 만. 발동 권한 주체는 `U-6` 미선언 |
| X-7 | — | **`PRE-7` 이 `601812` 판정을 요구한다.** 판정 전에는 검사 기준이 없다 |
| X-8 | `TP-P-4` · `TP-P-5` | 복구 경로 성립 검증 |

### §12.3 열린 질문

```text
Q-2   멱등성의 단위          601812 ChangeContract 소관 — PRE-5
Q-3   원자성의 경계          동상
Q-5   fail-closed 판정 계층   동상
```

> ⚠️ **`Q-2` · `Q-3` · `Q-5` 는 `TP-C` · `TP-S` 의 **판정 기준**을 좁힌다.**
> **검증 항목 자체는 이 문서가 확정했고 실행 방법이 `601812` 에 종속된다.**

## §13 근거 문서 목록 (`000701` §46)

### §13.1 인용한 문서

| 문서 | 인용 | 지위 |
|---|---|---|
| `601810_Logic_Tenant_Lifecycle_Rpc_Alignment.md` | `I-1`~`I-56` · `X-1`~`X-8` · `Q-2`·`Q-3`·`Q-5` · §8.1 | ACTIVE |
| `601809_Overview_Tenant_Lifecycle_Rpc_Alignment.md` | §2 `A-1`~`A-10` · §3 · §4.2 수리 판정 · §4.3 `M-1`·`M-2` · §4.4 | ACTIVE |
| `601801_Register_Stage1_Business_Rules.md` | `HG-A-1`~`HG-A-15` · `HD-0-A-2-1` · `HD-0-A-2-7` · §1.6 병기 · §4 | ACTIVE |
| `601802_Register_Stage0_Evidence_Collection.md` | §5.1 · §5.2 · §6.1 · §6.2 · §7 · §9.1 · §9.2 — 기준선 | ACTIVE |
| `601803_Diagram_Tenant_Lifecycle_State_Machine.md` | §2 · §3.2 · §3.3 · §7 `U-6`·`U-7`·`U-8`·`U-10`·`U-13` | ACTIVE |
| `601716_TestPlan_Operational_Authority_Foundation_V2.md` | §0.2 — 미래 목표를 negative 로 검사하는 형식 | ACTIVE |
| `601746_Report_Stage11C_Conflict_Analysis.md` | §2.7 rollback 미입증 5건 — `TP-RB-6` | ACTIVE |
| `601747_Evidence_Stage11C_FaultInjection_CrossTenant_Codex.md` | disposable container fault injection 방식 — `TP-C` | ACTIVE |
| `601702_Register_Stage1_Business_Rules.md` | §1.43 provider 2종 — `TP-E-7` | ACTIVE |
| `000221_Guide_Post_0A_Spiral_Sequence.md` | §4.4 `0-C` 배정 · §6.1 A급 판별 | ACTIVE |
| `000701_Guide_Controlled_AI_Development_Pipeline.md` | §37 원작자 배제 · §46 · §47.1 | ACTIVE |
| `000001_Md_Rules.md` | §5.4.2 증거 패킷 경로 | ACTIVE |

### §13.2 확인했으나 배제한 문서

| 문서 | 배제 사유 |
|---|---|
| `601804` · `601805` · `601806` · `601807` | 3단계 검증자 원본과 통합본. `601808` 이 승계했고 `601810` 이 불변조건으로 옮겼다 |
| `601808_Report_Stage3_Impact_Reconciliation.md` | 4단계 착수 범위를 정한 문서. `601809` · `601810` 이 이미 반영했으므로 TestPlan 이 다시 인용하지 않는다 |
| `601713_Logic_Operational_Authority_Foundation_V2.md` | 0-A 구조 불변조건. 이 나선의 검사 대상이 아니다 |
| `601748_Evidence_Stage12_Human_Merge_Decision.md` | §8 게이트 1 은 `0-A-3` 순서 조항이며 이 나선이 RLS policy 를 만들지 않으므로 검사 대상이 없다 |
| `000220_Guide_Shared_Commerce_Kernel_And_Foundation_Axis.md` | Foundation 축 귀속은 `000220` §4 소관. 검사 대상이 아니다 |
| `600010_Tracker_Spiral_Workpacket_Progress.md` | `601505` §4 금지 유효성은 `601809` §4.4 가 판정했다 |
| `601502` · `601503` · `601505` · `601510` · `601511` | 권위보류 대역. 설계 결론을 승계하지 않는다 — `000221` §3.2 |

## §14 다음 단계

```text
601812   ChangeContract   허용 파일 · 금지 조작 · M-1 · M-2 · X-7 · Q-2 · Q-3 · Q-5
Stage 5 ~ 12              A급 절차 전체 — HD-0-A-2-1
```

**이 TestPlan 은 구현을 승인하지 않는다.**

> ⚠️ **`PRE-5` ~ `PRE-7` 이 `601812` 산출을 요구한다.**
> **`601812` 확정 전에는 `TP-P-3` · `TP-C` · `TP-E` 일부 · `X-7` 을 실행할 수 없다.**
