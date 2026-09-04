# 601902_Register_Stage1_Business_Rules.md

Status: Active
Lifecycle: Register
Last Updated: 2026-09-02

## §0 성격

`000701` §47.1 의 **1단계 업무규칙 선언** 산출물이다.
Human 전담이며 AI 위임 불가다.

**이 문서는 「무엇을 사실로 삼을지」를 선언한다.** 설계도 구현도 아니다.

> ⚠️ **선행 `601801` 을 승계하지 않는다.**
> **`600021` 이 `601800` 대역을 권위보류했고 `HG-A-1`~`HG-A-16` 은 승계 대상이 아니다.**
> **식별자를 `TI-N` 으로 바꾼 것은 그 때문이다.**

**선행 증거** — `601901_Register_Stage0_Evidence_Collection.md`

### §0.1 식별자 규칙

```text
canonical   TI-N
절 인용      601902 §1.N (TI-N)
```

### §0.2 도출 순서

```text
601901 Pass 1     원천 정책 8건
601901 Pass 1.5   discovered direct source 3건
601901 Pass 2     라이브 실측
이 문서            그 위에서 Human 이 선언
```

**개정 이력**

| 일자 | 내용 |
|---|---|
| 2026-09-02 | 초안 — `TI-1` ~ `TI-8` |
| 2026-09-02 | `TI-9`~`TI-11` 추가 — 초판이 `010004` 를 어느 규칙의 근거로도 쓰지 않았다. `600021` 이 `601800` 을 권위보류한 사유와 같은 유형이다. `601900` Readme §5 승계 finding `C-1`·`M-9`·`R-6` 을 처분했다. `TI-3` authority state 이름을 canonical 로 정정 |
| 2026-09-04 | `TI-12` 추가 — 2단계 조사(`601903` §5.3)가 `TI-2` 가 `601702` §1.28 을 인용하지 않았음을 확인했다. 주제가 같으므로 상위 선언을 승계한다. `601800` 에서 같은 지적이 3단계 `C-B4` 로 나왔고 사후에 닫혔다 |

## §1 업무규칙

### §1.1 TI-1 — Source Doctrine 채택

**`010630` · `010650` · `010660` 을 이 나선의 직접 구속으로 채택한다.**

```text
010630   Authority Capability Gate
010650   Failure Containment Circuit Breaker
010660   Idempotency Retry Replay Reconciliation
```

**`600021` §2 가 강제한 5건에 더해 위 3건을 구속으로 삼는다.**

**아래 5건은 `A3` reference 로 유지한다.**

```text
010610   Stage 4 가 containment event · evidence packet · outbox 를 만들면 재개방
010620   새 command / query / projection boundary 를 만들면 재개방
010670   고객 · 직원에게 isolation · degraded 상태를 투영하면 재개방
010680   audit correlation · batch audit 가 설계에 들어오면 재개방
010690   cross-room plumbing closeout 단계에서 참조
```

**근거** — `601901` `Q-P12` · `Q-P6`.

### §1.2 TI-2 — tenant-wide isolation 과 scoped containment 의 책임 분리

**`tenant.isolation_state` 는 tenant 전체에 적용되는 tenant-wide isolation 만 표현한다.**

```text
NONE
ISOLATED
```

**store · route · device · actor · session · provider 등
부분 containment 를 `tenant.isolation_state` 에 추가 enum 값으로 넣지 않는다.**

**부분 containment 는 해당 scope 를 명시적으로 가진
별도의 scoped containment representation 이 책임진다.**

**부분 containment 가 tenant-wide isolation 으로 확대되는 것은
별도의 escalation rule 이며 자동으로 승격되지 않는다.**

> ⚠️ **`010650` 이 `TENANT_CIRCUIT_BREAKER` · `STORE_CIRCUIT_BREAKER` ·
> `DEVICE_CIRCUIT_BREAKER` · route containment 를 구분하고
> 「가장 작은 안전한 경계에서 막으라」고 요구한다.**
>
> **store 장애가 불필요하게 tenant 전체 장애가 되어서는 안 된다.**

> ⚠️ **`600021` §1.1 `C-2` 는 「2값으로 표현 불가」라고 지적했다.**
> **문제는 값의 개수가 아니라 tenant-wide state 하나에
> 모든 containment scope 를 표현시키려는 책임 혼합이다.**

**scoped containment 의 물리 표현은 Stage 4 가 정한다.**

**근거** — `601901` `Q-P10` · `010650` · `010630` SCOPE_GATE.

### §1.3 TI-3 — 격리 발동 권한

**tenant-wide isolation 은 아래 두 주체만 발동할 수 있다.**

```text
1  Automatic platform / security system
   policy-defined trigger + evidence + tenant scope +
   idempotency + audit 조건 아래 발동 가능

2  Authorized platform-security Human
   수동 발동 가능
```

**일반 tenant user · store staff · support 는 tenant-wide isolation 발동 권한이 없다.**

**모든 경우 authority gate 결과가 `AUTHORITY_ALLOWED` 일 때만 실행한다.**
**`AUTHORITY_REVIEW_REQUIRED` · `AUTHORITY_MULTI_PARTY_REQUIRED` 상태에서는 실행하지 않는다.**

**근거** — `010630` high-impact action gate · `010650` 자동 containment.

> ⚠️ **`AUTHORITY_PARTIAL_ALLOWED` 는 이 규칙이 다루지 않는다.**
> **`601901` 848행이 「Allowed only in limited scope」로 기록한다.**
> **`TI-2` 가 부분 containment 를 별도 책임으로 분리했으므로
> partial-allowed 가 scoped containment 를 허용하는지는 열린 질문이다.**
> **§6 에 남긴다.**

### §1.4 TI-4 — 격리 해제 권한

**tenant-wide isolation 의 자동 단독 해제를 허용하지 않는다.**

**해제에는 아래가 필요하다.**

```text
원인 · 위험 해소 evidence
explicit Human authority
tenant scope 검증
audit
필요 시 independent / multi-party approval
```

**수동으로 격리를 발동한 동일 actor 가
자기 단독 승인만으로 release 하지 못한다.**

> ⚠️ **`010650` 이 「자신이 발동한 quarantine 을 혼자 release 하는 것」을
> anti-pattern 으로 명시한다.**

**정확한 role ID 와 approver 수는 Stage 4 · `0-C` 가 정한다.**

**근거** — `010650` release stronger authority · `010630` multi-party approval.

### §1.5 TI-5 — 발동과 해제의 비대칭

**발동과 해제는 대칭이 아니다.**

```text
발동   확산 방지가 목적이다. 신속해야 한다. 자동화를 허용한다
해제   다시 신뢰하는 행위다. 더 위험하다. TI-4 를 따른다
```

**자동 발동 주체가 격리를 해제할 권한을 자동으로 갖지 않는다.**

**근거** — `010650` §35.

### §1.6 TI-6 — idempotency key 파생

**RPC transition boundary 는 caller · system 으로부터
stable action identity 를 입력받는다.**

```text
automatic containment       trigger_event_id 또는 evidence_packet_id
Human · manual transition   command_request_id 또는 authority_decision_id
```

**RPC · server 는 이 값을 신뢰 경계 안에서 검증한 뒤
canonical idempotency key 를 파생한다.**

```text
tenant_id
+ operation
+ target identity
+ stable action identity
+ payload_hash
+ policy_version
```

**caller 가 canonical idempotency key 자체를 자유롭게 결정하지 않는다.**

> ⚠️ **`tenant_id + operation + payload_hash` 만으로 파생하면
> 서로 다른 시점의 정상적인 동일 행위가 같은 key 가 된다.**
>
> ```text
> 9월 2일 보안사고 → tenant X 격리
> 10월 7일 별도 사고 → tenant X 격리
> ```
>
> **`010660` §4 가 key 는 「one business action」을 식별해야 한다고 요구한다.**

> ⚠️ **이 선언은 기존 `isolate_tenant` 시그니처 변경 가능성을 받아들인다.**
> **시그니처를 보존하려고 업무규칙을 바꾸면
> 현재 구현이 정책을 결정하는 역방향 설계가 된다.**

**파라미터명 · 타입 · hash 조합 · 기존 함수 유지 여부는 Stage 4 가 정한다.**

**근거** — `601901` `Q-P11` · `010660` §4 · §5 · `010630`.

### §1.7 TI-7 — merchant 어휘 구분

```text
010640 의 merchant_id        PG · VAN · 은행 등 외부 provider 측 merchant identifier
000170 의 Merchant Account   CatchMenu SaaS 고객 관계
```

**둘은 서로 다른 identity domain 이다.**

**이름이 비슷하다는 이유로
`merchant_id` 와 `merchant_account_id` 를
동일 식별자 또는 직접 alias 로 취급하지 않는다.**

**provider event 에서 `merchant_id` 를 사용할 때에는
tenant · store · legal entity · provider mapping 을 통해
CatchMenu 내부 customer context 와 연결한다.**

**물리 컬럼명과 FK 구조는 Stage 4 가 정한다.**

**근거** — `601901` `Q-P4` · `010640` §4 · `000170`.

### §1.8 TI-8 — scope envelope 의무 강도

```text
scope envelope 존재                       MUST
해당 action 에 필요한 scope dimension      MUST
010640 §5 의 모든 후보 필드를 무조건 보유    NOT REQUIRED
applicable 하지 않은 dimension             생략 가능
필요한 scope 가 빠진 경우                   처리 · mutation 금지
```

**tenant isolation transition 에 적용되는 것**

```text
tenant scope
actor · system identity
authority context
policy context
evidence context
audit context
```

**`store` · legal entity · provider 는 해당 사건이 실제 그 scope 에 걸릴 때 필수가 된다.**

> ⚠️ **여기서 「필드」는 반드시 DB 컬럼을 뜻하지 않는다.**
> **물리 운반 방법은 Stage 4 가 정한다.**

**근거** — `601901` `Q-P5` · `010640` §2 · §5 · §42.

### §1.9 TI-9 — 격리 발동 사유에 cross-tenant contamination 을 포함한다

**`010004` §20 이 containment 의 1차 발동 사유를 정한다.**

```text
unexpected tenant id in response
vector result from wrong tenant
export row scope mismatch
audit context missing
```

**cross-tenant contamination 탐지는 이 나선이 인정하는 격리 발동 사유다.**

> ⚠️ **`010004` 는 파일명 자체가
> `Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam` 이다.**
> **격리의 존재 이유가 cross-tenant 오염 차단이다.**

**다만 `010004` §20 이 열거한 containment action 중
tenant-wide isolation 보다 작은 것들이 있다.**

```text
projection block
export disable
vector retrieval disable
```

**그것들은 `TI-2` 가 정한 scoped containment 책임이며
tenant-wide isolation 으로 자동 승격되지 않는다.**

**어느 오염 유형이 tenant-wide 로 escalate 되는지는 Stage 4 가 정한다.**

**근거** — `600021` §1.1 `M-9` · `010004` §20 · `TI-2`.

### §1.10 TI-10 — 격리 전이의 audit 필드

**`010004` §19 가 audit event 필드를 정한다.**

```text
tenant id · store id · actor id · actor role ·
surface · device · target object id · type · action ·
previous scope · new scope ·
authority reference · policy reference · evidence reference
```

**`isolation_state` 변경은 §19 가 말하는
「new scope if changed」 사건 자체다.**

**격리 발동 · 해제 시 위 항목을 감사 가능하게 남긴다.**

> ⚠️ **`601901` Pass 2 실측** — 기존 `security_audit_log` 에는
> tenant · store · actor · resource · action · detail 이 있으나
> actor role · authority reference · policy reference ·
> evidence reference · previous scope · new scope 가 없다.

**기존 테이블을 확장할지 별도로 만들지는 Stage 4 가 정한다.**
**「필드」가 반드시 DB 컬럼을 뜻하지 않는 것은 `TI-8` 과 같다.**

**근거** — `600021` §1.1 `R-6` · `010004` §19 · `601901` Pass 2.

### §1.11 TI-11 — `010004` §24 게이트 판정

**`010004` §26 · §29 가 runtime 구현을 유보하고
§24 가 11항 선언을 해제 조건으로 요구한다.**

**이 나선은 §24 가 적용된다고 판정한다.**

```text
0-A-2 는 tenant isolation 의 runtime 동작을 만든다
010004 가 유보한 바로 그 영역이다
```

**따라서 Stage 7 Human Approval 전에 §24 11항을 선언한다.**

> ⚠️ **11항의 구체적 내용은 이 문서가 채우지 않는다.**
> **`601901` 이 §24 원문을 채록했고,
> 각 항에 대한 선언은 Stage 4 산출물이 갖춘 뒤
> Stage 7 승인 문서가 기록한다.**

**`601900` Readme §4 의 4번 구속이 이것을 요구했다.**

**근거** — `600021` §1.1 `C-1` · `010004` §24 · §26 · §29 ·
`601900` Readme §4.

### §1.12 TI-12 — 계층 상태 분리

**`601702` §1.28 이 상태축 여섯을 열거한다.**

```text
TenantStatus
  ≠ MerchantAccountStatus
  ≠ StoreServiceStatus
  ≠ StoreOperatingStatus
  ≠ TrialStatus
  ≠ IsolationState
```

**각 계층은 자신의 상태를 갖는다.**
**상위 상태를 하위 상태의 대체물로 사용하지 않는다.**

**이 나선이 소유하는 축**

```text
tenant_status
isolation_state
```

**나머지 4축**

```text
MerchantAccountStatus
StoreServiceStatus
StoreOperatingStatus
TrialStatus

이 나선의 직접 변경 대상이 아니다
두 소유 축에서 자동으로 파생되지 않는다
접근 판단에서 참조가 필요하면 명시적 precondition 으로만 사용한다
```

> ⚠️ **`601702` §1.27 이 「한 축의 값으로 다른 축의 상태를 추론하지 않는다」고 정한다.**
> **`tenant_status` 가 `TRIAL` 이라는 사실로 `TrialStatus` 를 추론하지 않는다.**

> ⚠️ **`TI-2` 는 tenant-wide isolation 과 scoped containment 의 책임을 나눴다.**
> **`TI-12` 는 그 위에 계층 상태 사이의 파생 금지를 더한다.**
> **둘은 다른 축이며 서로를 대체하지 않는다.**

**근거** — `601702` §1.27 · §1.28 · `601903` §5.3 · `601905` 검토 의견.

## §2 `601816` finding 처분

**`601901` `Q-P8` 이 정했다.**

**재적용 10건**

| # | 내용 |
|---|---|
| S6-1 | 객체를 만들면 실제 producer · caller 가 있어야 한다. **옛 `D-1`·`D-2`·`D-3` 객체 자체는 승계하지 않는다** |
| S6-2 | release gate 를 우회하는 두 번째 해제 경로 금지 |
| S6-3 | 안전한 공식 release 경로가 실제로 실행 가능해야 한다 |
| S6-4 | authority 를 실제 권한으로 강제할 수 있어야 한다. 물리 ACL · RBAC 조작이 `0-C` 이면 hard precondition 으로 둔다 |
| S6-5 | 수정하는 isolation RPC 의 security attributes · return contract 를 Stage 4 가 명시해야 한다 |
| S6-6 | 일반 `authenticated` 사용자가 arbitrary tenant 를 격리 · 해제할 수 있어서는 안 된다 |
| S6-7 | 새 isolation 관련 객체가 여러 tenant identifier 를 가질 경우 cross-tenant inconsistent relation 을 허용하지 않는다 |
| S6-8 | idempotency action identity 출처 — `TI-6` 이 답한다 |
| S6-10 | release 의 의미와 atomic transition 조건을 확정해야 한다. **옛 `D-27` 객체 자체는 승계하지 않는다** |
| S6-12 | 필수 입력은 producer 가 있어야 한다. **옛 `provisional_attribution` 컬럼은 자동 승계하지 않는다** |

**승계하지 않는 5건**

```text
S6-9    old D-28 operation domain — D-28 자체가 601800 설계 결과
S6-11   HG-A-15 traceability defect — HG-A-15 를 승계하지 않는다
S6-13   baseline comparison 기준 누락 — governance · verification
S6-14   하위 문서가 상위 OUT_OF_SCOPE 를 뒤집음 — governance precedence
S6-15   BL-6 계수 오류 — verification bookkeeping
```

> ⚠️ **어떠한 `601816` 설계 해법도 승계하지 않는다.**

## §3 `601901` unresolved 처분

| # | 처분 |
|---|---|
| Q-P1 · Q-P2 · Q-P3 · Q-P7 | governance 이월 — 문서 provenance 표기 문제이며 설계 결정이 아니다 |
| Q-P4 | `TI-7` |
| Q-P5 | `TI-8` |
| Q-P6 | `TI-1` |
| Q-P8 | §2 |
| Q-P9 | `TI-3` · `TI-4` |
| Q-P10 | `TI-2` |
| Q-P11 | `TI-6` |
| Q-P12 | `TI-1` |

**`601900` Readme §5 승계 finding 처분**

| # | 처분 |
|---|---|
| C-1 | `TI-11` |
| C-2 | `TI-2` |
| M-9 | `TI-9` |
| R-6 | `TI-10` |

## §4 Human Decision

```text
HD-0-A-2R-1 — Source Doctrine

010630, 010650 and 010660 are adopted as direct binding source for this
spiral, in addition to the five the ruling made mandatory. The remaining
five discovered documents stay as reference and are reopened when the
design actually reaches what each governs.

HD-0-A-2R-2 — Containment Responsibility

The tenant isolation state carries tenant-wide isolation only. Partial
containment at store, route, device, actor, session or provider scope is
the responsibility of a separate scoped representation, not additional
values on the tenant state. Escalation from partial to tenant-wide is a
separate rule and never automatic.

HD-0-A-2R-3 — Initiation And Release Authority

Isolation may be initiated by an approved automated security path or an
approved platform-security human, and by nobody else; ordinary tenant
users, store staff and support have no such authority. Release is never
automatic and never unilateral, and the actor who manually initiated an
isolation may not approve its release alone.

HD-0-A-2R-4 — Idempotency Key Derivation

The transition boundary accepts a stable action identity and derives the
canonical key from it inside the trust boundary. The caller does not
choose the key. This accepts that the existing function signature may
have to change; preserving a signature by weakening the rule would let
the current implementation decide the policy.

HD-0-A-2R-5 — Merchant Vocabulary

The provider-side merchant identifier and the SaaS customer relationship
are different identity domains and are never treated as aliases.

HD-0-A-2R-6 — Scope Envelope Strength

Carrying a scope envelope is mandatory; carrying every candidate field is
not. A dimension that does not apply may be omitted, but a required scope
that is missing forbids processing.

HD-0-A-2R-7 — Contamination As Initiation Cause

Cross-tenant contamination detected at runtime is an accepted cause for
containment. The isolation policy exists for exactly this, and the first
attempt at this spiral did not list it among its five causes. Where the
policy's response is narrower than a whole tenant - blocking a
projection, disabling an export - that is scoped containment and does not
escalate on its own.

HD-0-A-2R-8 — Audit Fields

An isolation transition is a scope change, and the isolation policy names
what a scope-change audit event must carry. The existing audit table
carries about half of it. Whether to extend that table or build
alongside it is a design decision; that the fields must exist is not.

HD-0-A-2R-9 — Section 24 Gate Applies

The isolation policy defers runtime implementation and sets an
eleven-item declaration as the condition for lifting that deferral. This
spiral builds the runtime behaviour it defers, so the gate applies. The
declarations are made before human approval, not here.

HD-0-A-2R-10 — Layer State Separation

The foundation spiral declared six status axes and forbade using one
layer's state as a substitute for another's. This spiral owns two of
them. The other four are not derived from the two it owns and are not
changed here; where access needs them they are read as explicit
preconditions. The stage-two survey found that the rule separating
containment responsibility had been written without citing the
declaration that separates the layers, and the omission is closed here
rather than absorbed quietly into the model.
```

**판정자** — 정영석, 2026-09-02

**HD-0-A-2R-7 ~ HD-0-A-2R-9 판정자** — 정영석, 2026-09-02

**HD-0-A-2R-10 판정자** — 정영석, 2026-09-04

## §5 이 나선이 정하지 않는 것

```text
테이블 · 컬럼 · 제약명 · 인덱스명
함수 signature · 파라미터명 · 타입
scoped containment 의 물리 표현
role ID · approver 수 · EXECUTE ACL
hash 조합 · policy_version 의 형태
provider merchant mapping 의 물리 구조
```

**Stage 4 · `0-C` 가 정한다.**

## §6 열린 질문

| # | 내용 |
|---|---|
| OQ-1 | `AUTHORITY_PARTIAL_ALLOWED` 가 scoped containment 를 허용하는가 — `TI-3` · `TI-2` |
| OQ-2 | `010004` §20 의 어느 오염 유형이 tenant-wide 로 escalate 되는가 — `TI-9` · Stage 4 |
| OQ-3 | `010650` §38 anti-pattern 중 이 나선이 강제할 범위 — `601901` `Q-P13` |
## §7 근거 문서 목록 (`000701` §46)

| 문서 | 인용 | 지위 |
|---|---|---|
| `601901_Register_Stage0_Evidence_Collection.md` | 전문 — 선행 증거 | ACTIVE |
| `010004` | §19 · §20 · §24 · §26 · §29 | ACTIVE — mandatory |
| `010640` | §2 · §4 · §5 · §6 · §41 · §42 | ACTIVE — mandatory |
| `000150` · `000170` · `000190` | 조직 · merchant · 경계 | ACTIVE — mandatory |
| `010630` | authority gate family · SCOPE_GATE · multi-party | ACTIVE — `TI-1` 채택 |
| `010650` | circuit breaker scope · §35 containment/release 비대칭 · anti-pattern | ACTIVE — `TI-1` 채택 |
| `010660` | §4 one business action · §5 submitted or derived | ACTIVE — `TI-1` 채택 |
| `601702_Register_Stage1_Business_Rules.md` | 선언 45건 — 상위 근거. §1.27 · §1.28 은 `TI-12` | ACTIVE |
| `600021_Governance_Tenant_Isolation_Axis_Authority_Reset.md` | §1.1 · §2 | ACTIVE |
| `601816` | finding 15건 — §2 처분 | ⛔ **AUTHORITY SUSPENDED** |
| `601801` · `601803` · `601809`~`601812` | 승계하지 않는다 | ⛔ **AUTHORITY SUSPENDED** |
| `000701` | §46 · §47.1 | ACTIVE |
