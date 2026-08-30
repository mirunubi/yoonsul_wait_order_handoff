# 601816_Report_Stage6_Round1_Integration.md

Status: Active
Lifecycle: Report
Last Updated: 2026-08-30

## §0 이 문서의 지위

`000701` §9.16 **Stage 6 Round 1 통합**이다.

```text
Verifier A   Codex    601813   실측 축         blocking 10 / informational  4
Verifier B   Cowork   601814   문서 축         blocking  4 / informational 10
Verifier C   Claude   601815   외부 타당성      blocking 15 / informational 11
```

**세 검증자가 동시에 수행했고 서로의 결과를 참조하지 않았다.**

**통합자는 세 보고서를 액면 그대로 신뢰하지 않고
핵심 주장을 라이브 DB 와 원문에서 재도출했다**(`000701` §13.6).

### §0.1 통합자 직접 재도출 — 3건

**세 검증자의 핵심 주장을 독립 실측했다.**

| 주장 | 실측 | 결과 |
|---|---|---|
| `isolate_tenant` 가 `p_isolate boolean` 을 받는다 | `isolate_tenant(uuid,text,boolean,uuid,text)` | **성립** |
| 신규 함수 기본 ACL 이 PUBLIC EXECUTE 다 | `detect_threat` `proacl` = `{=X/postgres,postgres=X/postgres,authenticated=X/postgres}` — 선두 `=X` 가 PUBLIC | **성립** |
| `D-18` · `D-19` 가 단일 컬럼 FK 다 | `601812` 원문 — `FOREIGN KEY (tenant_id)` · `FOREIGN KEY (isolation_event_id)` 각각 | **성립** |

**추가 실측**

```text
isolate_tenant  prosecdef = t                    SECURITY DEFINER
                proconfig = search_path 4스키마
                proacl = {postgres=X, authenticated=X}
                → authenticated 가 EXECUTE 가능하다

authenticated   catchmenu_common USAGE = t
```

> ⚠️ **`601815` `B-6` 이 확정된다.**
> **`authenticated` 가 EXECUTE 가능한 `SECURITY DEFINER` 함수가
> `p_tenant_id` 를 인자로 받는다.**
> **수리하면 임의 tenant 를 격리 · 해제할 수 있다.**

## §1 종합

```text
blocking        29건 보고 → 중복 제거 후 15건
informational   25건 보고
```

**출처별 흡수 확인**

| 검증자 | blocking | §2 매핑 |
|---|---:|---|
| Codex | 10 | `F-1` ~ `F-10` 전건 |
| Cowork | 4 | `B-1` ~ `B-4` 전건 |
| Claude | 15 | `B-1` ~ `B-15` 전건 |

> ⚠️ **초판이 「29건 → 11건」이라 적고 23건만 흡수했다.**
> **`601807` 이 §0 에서 「전건 재도출」을 선언하고 일부만 수행한 것과 같은 유형이다.**
> **2026-08-30 에 `S6-12` ~ `S6-15` 를 추가해 전건 흡수로 정정했다.**

**Stage 6 Round 1 = INCOMPLETE.**

## §2 blocking 통합 — 15건

| # | 내용 | 출처 | 수렴 |
|---|---|---|---|
| **S6-1** | **계약이 만든 객체에 쓰는 주체 · 호출 경로가 없다.** `D-28 is_tenant_access_allowed` 를 호출하는 경로, `D-2 tenant_isolation_queue` 에 넣는 주체, `D-3 tenant_billing_reviews` 에 행을 만드는 조작이 허용 조작에 없다. 허용 파일은 migration 1건뿐이고 `FO-2`~`FO-4` 가 기존 RPC 수정을, `FO-6` 이 `CREATE POLICY` 를 금지하며 애플리케이션 코드는 허용 파일이 아니다 | Codex `F-4`·`F-5`·`F-6`·`F-8` / Cowork `B-1`·`B-2` / Claude `B-1`·`B-7`·`B-8` | **3/3** |
| **S6-2** | **`p_isolate := false` 가 3요건을 거치지 않는 두 번째 해제 경로다.** `D-26` 본문 요건이 `isolation_state` 를 `ISOLATED` 또는 `NONE` 으로 쓴다고 명시했고 `HG-A-8` 세 요건은 `D-27` 에만 걸려 있다 | Codex `F-1` / Claude `B-2` | 2/3 |
| **S6-3** | **공식 해제 경로가 영구히 성공할 수 없다.** `cause_resolved` · `human_approved` 가 `DEFAULT false` 인데 참으로 만드는 조작이 없다. `D-27` 인자에 승인 입력이 없고 `M-1` 은 「허용 DML 없음」이며 `D-23`·`D-24` FORCE RLS + policy 0 + `FO-7` GRANT 금지로 외부 UPDATE 경로도 없다 | Claude `B-3` | 단독 |
| **S6-4** | **신규 함수 3건이 owner-only 가 되지 않는다.** PostgreSQL 신규 함수 기본 ACL 은 PUBLIC EXECUTE 이고 `authenticated` 는 `catchmenu_common` USAGE 를 가지며 `FO-7` 이 `GRANT`·`REVOKE` 를 금지한다. `D-29` 의 「승인된 Human 역할」 경계를 권한으로 강제하지 못한다 | Codex `F-2` / Claude `B-6` | 2/3 |
| **S6-5** | **네 함수의 보안속성이 계약에 없다.** `RETURNS` · `LANGUAGE` · `SECURITY DEFINER`/`INVOKER` · 소유자 · `SET search_path` · 기본 인자 · 반환 계약 미확정. `CREATE OR REPLACE` 는 미명시 속성을 기본값으로 되돌리므로 `D-26` 을 그대로 적으면 DEFINER 와 search_path 가 소실된다 | Codex `F-3` / Claude `B-5` | 2/3 |
| **S6-6** | **`authenticated` 가 임의 tenant 를 격리 · 해제할 수 있다.** 실측 `proacl` = `{postgres=X, authenticated=X}`, `prosecdef = t`, 인자에 `p_tenant_id`. 현재는 CHECK 위반으로 실행 실패라 가려져 있으나 수리하면 열린다. `FO-7` 이 `REVOKE` 를 금지하고 `TP-R-10` 은 ACL 불변을 PASS 조건으로 삼는다 | Claude `B-6` · 통합자 재도출 | 단독 |
| **S6-7** | **`D-1` 형태가 재발한다.** `D-18` · `D-19` 가 `tenant_id` 와 `isolation_event_id` 를 각각 단일 컬럼 FK 로 건다. `tenant_isolation_events` 에 `(id, tenant_id)` 복합 UNIQUE 도 복합 FK 도 tenant 일치 CHECK 도 없다. tenant A 의 review 가 tenant B 의 사건을 참조하는 행이 제약을 통과한다 | Claude `B-9` | 단독 |
| **S6-8** | **멱등성 키를 어디서 얻는지 미확정이다.** `D-1.idempotency_key` 는 `NOT NULL`, `D-6` 은 그 세 값 UNIQUE 인데 §8.2 가 시그니처 불변(선택지 C)을 판정해 `isolate_tenant` 인자에 키가 없고 `D-27` 에도 없다. 요청 내용의 동일 · 상이를 비교할 hash · snapshot 도 없고 역순 요청 방지 token 도 없다 | Codex `F-7` / Claude `B-4` | 2/3 |
| **S6-9** | **`D-28` 의 `p_operation` 정의역과 `tenant_status` 5값 매핑이 계약에 없다.** 그런데 `TP-S-1`~`TP-S-10` 은 구체 기대값을 요구한다. `TP-S-1` 은 `HG-A-11` 이 정정을 지시한 「`TRIAL` → 체험 서비스」 표현을 되살렸다. `HG-A-10` 「2~4단계가 채우지 않는다」에 걸린다 | Codex `F-4` / Cowork `B-3` / Claude `B-10` | **3/3** |
| **S6-10** | **`D-27` 의 동작이 확정되지 않았다.** 기존 ISOLATE 행을 갱신하는지 RELEASE 행을 추가하는지, 어느 행이 감사 기록인지, 세 요건 확인과 상태 변경을 어떤 단일 조건으로 묶는지 미정. `TP-P-4`~`TP-P-6` 기대와 달라질 수 있다 | Codex `F-9` | 단독 |
| **S6-11** | **`HG-A-15` 가 `601809` 범위 문서에 없다.** A급으로 명시된 선언인데 §2 구현 대상 `A-1`~`A-10` 에도 §3 Out of Scope 에도 없다. 그런데 `I-54`~`I-56` · `TP-P-7`·`TP-P-8` · `D-1` 승인기록 4컬럼 · `D-8` CHECK · `D-29` 가 실제로 구현한다. Stage 7 승인자가 범위 문서만 읽으면 알 수 없다 | Cowork `B-4` | 단독 |
| **S6-12** | **계약이 요구하는 입력이 어디서 오는지 없다 — 3건 묶음.** `D-1.provisional_attribution` 이 `NOT NULL` + CHECK 인데 §8.2 시그니처 불변 판정으로 `isolate_tenant` 에 분류 입력 인자가 없다. `idempotency_key` 도 같다(`S6-8`). `HG-A-15` 의 분리 원칙(자기가 관여한 사건을 자기 혼자 승인 못 함)을 `D-1` 의 `requested_by` · `confirmed_by` 가 제약으로 강제하지 않는다 | Claude `B-14`·`B-15` | 단독 |
| **S6-13** | **`PRE-3` · `V-3` 의 비교 기준이 없다.** `BL-1`~`BL-13` 재측정이 `601802` 기록과 일치해야 중단을 면하는데, `BL-13`(merchant_accounts 행 수 · 연결)이 `601802` 측정 대상 5군과 실행 쿼리에 없고, `BL-7`·`BL-8`·`BL-9`·`BL-10` 은 「착수 직전 실측」이라 비교 대상 자체가 없다 | Codex `F-10` / Claude `B-12` | 2/3 |
| **S6-14** | **`601812` §7 이 상위 문서의 `OUT_OF_SCOPE` 판정을 뒤집었다.** `Q-5` 를 「API + DB/RPC 둘 다」로 판정했으나 `601808` `N-7` 이 「판정 위치를 `0-A-2` 안에서 확정하지 않는다」로 `OUT_OF_SCOPE` 배정했고 `601809` §2.1 `C-1` 도 같다. 하위 문서가 상위 판정을 뒤집었다 | Claude `B-13` | 단독 |
| **S6-15** | **`BL-6` after 값의 계수 근거가 어긋난다.** 근거를 「`D-28` 이 `tenant_status` 를 읽는다」로 적었으나 §2.6 이 `isolate_tenant` 도 읽기만 하도록 정했다. before 7 에 이미 포함된 함수와의 계수 정합이 확인되지 않았다 | Claude `B-11` | 단독 |

## §3 근본 원인

**15건 중 11건이 하나의 원인에서 나온다.**

```text
계약이 허용 파일을 migration 1건으로 좁혔다
그런데 선언된 불변조건은 runtime 동작을 요구한다
```

**`HG-A-2` · `HG-A-5` · `HG-A-7` 이 요구하는 것은 DDL 이 아니라 동작이다.**

> ⚠️ **가장 정확한 표현**
>
> ```text
> 안전한 공식 경로     사용 불가   S6-3
> 위험한 기존 우회경로  사용 가능   S6-2 · S6-6
> ```
>
> **정반대로 설계됐다.**

**나머지 4건은 다른 원인이다.**

```text
S6-12   계약이 요구하는 입력의 출처가 없다
        §8.2 시그니처 불변 판정과 D-1 NOT NULL 컬럼이 충돌한다

S6-13   PRE-3 · V-3 의 비교 기준이 없다
        601811 이 601802 측정 범위를 확인하지 않고 게이트를 걸었다

S6-14   하위 문서가 상위 판정을 뒤집었다
        601812 §7 이 601808 N-7 의 OUT_OF_SCOPE 를 뒤집었다

S6-15   BL-6 계수 근거가 어긋난다
```

## §4 informational — 25건

**세 보고서 원문에 있다. 중복 제거하지 않고 출처만 기록한다.**

```text
601813   I-1 ~ I-4
601814   informational 10건
601815   N-1 ~ N-11
```

**4단계 재작성 시 각 원문을 함께 본다.**

## §5 Stage 6 Round 1 판정

```text
Stage 6 Round 1 = INCOMPLETE

blocking 15건 미해소
601812 는 현 상태로 Stage 7 승인 대상이 아니다
```

## §6 Human 처분 대기

**`601809`~`601812` 를 어떻게 할지는 Human 이 정한다.**

**이 문서는 판정하지 않는다.**

```text
관측된 선택지

A  계약 범위를 넓힌다 — 기존 RPC · 애플리케이션 코드 · GRANT 포함
B  나선 범위를 좁힌다 — 객체 정의까지. 호출 연결은 후속
C  4단계 산출물을 재작성한다
```

## §7 근거 문서 목록 (`000701` §46)

| 문서 | 인용 | 지위 |
|---|---|---|
| `601813_Audit_Stage6_Contract_Verification_Codex.md` | 전문 | ACTIVE |
| `601814_Audit_Stage6_Contract_Verification_Cowork.md` | 전문 | ACTIVE |
| `601815_Audit_Stage6_Contract_Verification_Claude.md` | 전문 | ACTIVE |
| `601809` ~ `601812` | 검증 대상 전문 | ACTIVE |
| `601801` | `HG-A-1` ~ `HG-A-15` · `HD-0-A-2-1` ~ `9` | ACTIVE |
| `601802` | §5 · §6 · §9 실측 | ACTIVE |
| 라이브 PostgreSQL catalog | §0.1 재도출 | — |
| `000701` | §9.16 · §13.6 · §46 | ACTIVE |
