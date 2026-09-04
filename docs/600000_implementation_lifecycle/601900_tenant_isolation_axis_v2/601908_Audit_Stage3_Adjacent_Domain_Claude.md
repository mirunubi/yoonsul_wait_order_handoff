# 601908_Audit_Stage3_Adjacent_Domain_Claude.md

Status: Active
Lifecycle: Audit
Last Updated: 2026-09-04

## §0 수행 조건

`000701` §47.1 이 3단계 actor 를 `Opus/Fable` 로 지정한다.
**이 검증이 그 요건을 충족한다.**

```text
수행        Claude (Opus), 새 대화창
사전 맥락    0
저장소 접근  없음. 첨부 7건으로만 판단
결과 전달    답변 출력. Human 이 이 파일로 편입
```

**첨부**

```text
검증 대상   601902 · 601905
근거        601901 · 601903 · 601904 · 601702 · 600021
```

> ⚠️ **`finding acceptance rule` 과 출력 형식이 첨부되지 않았다.**
> **Verifier C 는 등급을 추정하지 않고 `[대조]` · `[해석]` 표식만 붙였다.**
> **등급 부여는 `601909` 통합이 실제 rule 로 수행한다.**

**동시 수행 — 상호 참조 없음**

```text
Verifier A   Codex    601906   blocking 1 / informational 2
Verifier B   Cowork   601907   blocking 4 / informational 15
Verifier C   Claude   이 문서   finding 25 · 우려 없음 9 · 확인 불가 12
```

## §1 검증 결과 — VERBATIM

**아래는 답변 원문이다. 편집하지 않았다.**

````text
첨부 7건을 모두 수령했다. 판정을 수행한다.

---

# Verifier C — 외부 타당성 판정

## 0. 이 보고서의 형식에 대한 사전 고지

워크패킷은 **finding acceptance rule** 과 **출력 형식**을 「Verifier A 와 동일」로 지정했으나, 이 세션은 사전 맥락 0이고 Verifier A 의 rule·형식 본문이 첨부되지 않았다. **알 수 없는 채택 기준을 추정으로 적용하지 않는다.**

따라서 각 finding 에 심각도 등급을 붙이지 않고, 대신 다음 두 표식만 붙인다. 등급 부여는 Human 이 601908 편입 시 실제 rule 로 수행한다.

```text
[대조]   첨부 7건만으로 사실관계가 확정된다. 해석 여지 없음
[해석]   사실은 확정되나 그것이 결함인지는 acceptance rule 에 달렸다
```

**처분·재설계·대안은 적지 않는다.**

---

## C1 외부 타당성 — 주축

> 이 모델대로 구현하면 `601902` 가 선언한 것이 실제로 강제되는가

### C1-1 `ISOLATED` 상태의 효과가 어느 문서에도 선언되지 않았다 [대조]

`601902` `TI-2`~`TI-11` 과 `601905` §1~§5 전체를 통독하면 다음이 규정된다.

```text
누가 전이시킬 수 있는가        TI-3 · TI-4 · TI-5
어떤 gate 를 통과해야 하는가    TI-3 · §3
중복을 어떻게 식별하는가        TI-6 · §4
무엇을 audit 에 남기는가        TI-10 · §5 Q-2
```

**`ISOLATED` 인 tenant 에게 무엇이 금지되는지를 규정하는 항목은 `TI-1`~`TI-12` 및 `601905` §1~§8 어디에도 없다.**

`601901` §17.2 실측:

```text
isolation_state 를 참조하는 FUNCTION   0건
VIEW · MATVIEW · TRIGGER               각 0건
다른 테이블의 관련 제약                0건
```

현재 `isolation_state` 는 소비자가 0건인 컬럼이다. 모델은 그 상태로 전이하는 절차만 정의하고, 그 상태가 무엇을 차단하는지는 정의하지 않는다. **`601905` 를 그대로 Stage 4 로 넘기면 전이가 감사·멱등·권한통제되는 상태 컬럼이 생기고, 그 값을 읽는 경로는 여전히 0건일 수 있다.**

이것은 `601902` §2 가 **재적용**으로 승계한 `S6-1` 이 지목한 유형이다.

> `S6-1` 객체를 만들면 실제 producer · caller 가 있어야 한다

C1 축 경고문(「네 문서가 서로 일치했으나 설계 자체가 선언한 불변조건을 강제하지 못한 사례」)에 해당하는 후보로 기록한다.

---

### C1-2 `601902` §2 S6 재적용 10건이 `601905` 의 입력·추적 대상이 아니다 [대조]

`601905` §0.1 입력 선언:

```text
601902   TI-1 ~ TI-11 · HD-0-A-2R-1 ~ 9 · OQ-1 ~ OQ-3
```

`601902` §2 가 **재적용**으로 처분한 `S6-1`·`S6-2`·`S6-3`·`S6-4`·`S6-5`·`S6-6`·`S6-7`·`S6-8`·`S6-10`·`S6-12` 10건은 입력 목록에 없다. `601905` §8 추적표도 `TI-N` 12행만 있고 `S6-N` 행이 없다.

특히 다음 3건은 상태·책임 모델에서 표현 가능한 성격이다.

| # | 내용 | `601905` 내 표현 |
|---|---|---|
| `S6-2` | release gate 를 우회하는 두 번째 해제 경로 금지 | §2 는 해제 경로를 하나만 그렸으나 「두 번째 경로 금지」를 선언하지 않았다 |
| `S6-3` | 안전한 공식 release 경로가 실제 실행 가능해야 한다 | 없음 |
| `S6-6` | 일반 `authenticated` 사용자가 arbitrary tenant 를 격리·해제할 수 없어야 한다 | §2 note 의 「금지 주체」가 인접하나 `601904` §2 `TI-3` 실측(`authenticated` 에 EXECUTE 존재)과 연결되지 않았다 |

---

### C1-3 §3 gate — 거부된 전이 시도에 audit 요구가 없다 [대조]

`601905` §3 은 `AUTHORITY_REVIEW_REQUIRED` · `AUTHORITY_MULTI_PARTY_REQUIRED` 를 `STOP1` · `STOP2` 종단 노드로 그린다. 두 노드에서 나가는 간선은 없다.

상위 원천:

```text
010630 §6 말미     Authority denied must be auditable.
010004 §19 말미    Cross-tenant access attempts must be auditable.
                   Failed access is also security evidence.
```

`TI-10` 은 「격리 발동 · 해제 시」 audit 을 요구한다. **발동이 거부된 경우는 발동도 해제도 아니므로 `TI-10` 의 적용 범위 밖이다.** `601905` §5 `Q-2` 로 들어오는 간선도 `Q-1`(격리 사건) 하나뿐이다.

모델대로 구현하면 gate 가 거부한 격리 시도는 아무 기록도 남기지 않는다.

---

### C1-4 §3 gate — 15개 canonical 상태 중 4개만 분기하고 기본값 규칙이 없다 [대조]

`601901` §9.1.2 가 채록한 `010630` §6 은 15개 상태를 정의한다. `601905` §3 「읽는 법」 표는 4행이다.

경로가 정의되지 않은 11개:

```text
AUTHORITY_NOT_EVALUATED      AUTHORITY_EVALUATING
AUTHORITY_DENIED             AUTHORITY_EVIDENCE_REQUIRED
AUTHORITY_RISK_HOLD          AUTHORITY_POLICY_BLOCKED
AUTHORITY_SCOPE_MISMATCH     AUTHORITY_DEVICE_UNTRUSTED
AUTHORITY_PROVIDER_UNREADY   AUTHORITY_CIRCUIT_OPEN
AUTHORITY_DLQ_REQUIRED
```

`AUTHORITY_DENIED` — 가장 기본적인 거부 상태 — 가 모델에 없다.

`601902` `TI-3` 본문은 「`AUTHORITY_ALLOWED` 일 때만 실행한다」로 **닫힌 규칙**을 선언했다. `601905` §3 은 이를 열거형 분기표로 옮겼다. 열거된 4개 밖의 상태에 대한 동작이 모델 표면에서 사라졌다.

관련 상위 선언 — `601902` 도 `601905` 도 인용하지 않았다.

```text
010630 §28   DENY_UNLESS_EXPLICITLY_ALLOWED
010004 §7    If context cannot be resolved, access must fail closed.
             Fail closed is mandatory.
010640 §42   denied, quarantined, or routed to DLQ
```

> 참고 — §3 이 `010630` §6 을 **「canonical 상태값」**이라 부른다. 원문 heading 은 `Recommended authority decision states` 다.

---

### C1-5 §4 idempotency — key 를 파생하고 그 다음이 없다 [대조]

`601905` §4 의 마지막 노드는 `K`(파생 입력 집합)다. 파생된 key 가 기존 key 와 일치했을 때의 동작을 그린 간선이 없다.

상위 원천이 요구하는 동작:

```text
010630 §21   Duplicate action must return existing result or route to review.
             It must not execute twice.
010660 §6    Same key with different payload must not execute.
             (12개 IDEMPOTENCY_* 상태 skeleton)
```

`601902` `TI-6` 도 파생 규칙만 선언하고 중복 검출 시 행위를 선언하지 않는다. `601905` §5 `Q-6` 은 「server 가 파생한 값」이라는 정보 요소일 뿐이다.

`TI-6` 이 든 예시(9월 2일 격리 / 10월 7일 별건 격리)는 **서로 다른 key 가 나와야 한다**는 요구이며, **같은 key 가 나왔을 때 무엇을 하는가**는 다루지 않는다. 모델은 후자를 표현하지 않는다.

---

### C1-6 §3 과 §4 의 순서가 선언되지 않았다 [해석]

`601905` §3(gate)과 §4(idempotency)는 서로 참조하지 않는 두 다이어그램이다. `REQ` → `GATE` 와 `A1/A2` → `V` → `D` 사이에 순서 관계가 없다.

```text
010660 §2   Idempotency key protects action, not authority.
            Idempotency pass does not bypass policy.
```

멱등 검사가 먼저 수행되고 중복 판정 시 기존 결과를 반환하는 구현과, gate 가 먼저 수행되는 구현은 이 인용문에 대해 결과가 다르다. 모델은 둘을 구분하지 않는다.

`010630` §27 `Authority Evaluation Order` 는 `601901` §9.1.1 전체 절 구조에 이름만 있고 원문이 채록되지 않았다 — §5 「확인 불가」 참조.

---

### C1-7 `TI-8-e`(필요 scope 누락 시 mutation 금지)가 모델에 표현되지 않았다 [대조]

`601905` §8 추적표:

```text
TI-8   §5 Q-2 · Q-3
```

`Q-2`·`Q-3` 은 §5 「정보 요소 — 개념 수준」의 항목이다. `TI-8` 의 규범적 핵심은 정보 요소가 아니라 **금지**다.

```text
601902 §1.8   필요한 scope 가 빠진 경우 → 처리 · mutation 금지
```

이 금지를 표현한 다이어그램 요소가 §1~§5 어디에도 없다. §3 gate 는 authority 결과만 분기하고 scope 충족 여부를 분기하지 않는다.

`010640` §2 원문(`No tenant scope, no processing.` 이하 9행)과 §42, `010004` §7 이 모두 같은 금지를 요구한다.

---

### C1-8 `TI-4` 의 「필요 시 multi-party」와 `010630` §18 의 무조건 선언 [대조]

`601902` `TI-4` · `601905` §2 note:

```text
필요 시 independent / multi-party approval
```

`601901` §9.1.2 가 채록한 `010630` §18:

```text
Actions may include:
  ...
  - security containment release      ← 명시 열거
  ...
One person must not control critical financial or security changes alone.
```

마지막 문장은 조건절이 없다. `TI-4` 는 「수동으로 격리를 발동한 **동일 actor** 가 자기 단독 승인만으로 release 하지 못한다」까지만 금지한다. **발동자가 아닌 다른 1인이 단독으로 해제하는 경로**는 `TI-4` 와 `601905` §2 어느 쪽도 금지하지 않는다.

`010650` §35 「Release often requires stronger authority」는 `often` 이므로 이 지점을 닫지 않는다.

---

## C2 상위 선언 위반

> `601702` · `601901` 이 채록한 원천 8건과 어긋나는가

### C2-1 `010004` §19 의 `cross-scope attempt if any` 가 소실됐다 [대조]

`601901` §5.2 채록 원문 14항 중 마지막:

```text
- cross-scope attempt if any
```

`601901` §21.1 은 이 항목이 현재 스키마에 없다는 것도 명시 기록했다.

> 원문 열거 필드 중 actor role, surface/device, previous/new scope, authority/policy/evidence reference, **cross-scope attempt** 이름의 컬럼은 없다

`601902` `TI-10` 열거:

```text
tenant id · store id · actor id · actor role ·
surface · device · target object id · type · action ·
previous scope · new scope ·
authority reference · policy reference · evidence reference
```

`cross-scope attempt` 없음. `601904` §2 `TI-10` 행, `601905` §5 `Q-2` 도 같다.

`601901` 이 두 곳에서 채록한 항목이 `601902` 에서 탈락하고 이후 두 문서로 전파됐다.

---

### C2-2 `010004` §20 의 발동 사유 10건 → 4건, containment action 9건 → 3건 [대조]

`601901` §5.2 채록 원문 — 발동 사유(`Possible triggers`) **10건**:

```text
unexpected tenant id in response / wrong store data rendered /
vector result from wrong tenant / support view shows wrong tenant /
export row scope mismatch / provider callback attached to wrong store /
device context mismatch / CMS target mismatch /
financial report mismatch / audit context missing
```

`601902` `TI-9` 는 4건만 옮기고 「`010004` §20 이 containment 의 1차 발동 사유를 **정한다**」로 제시한다. 부분 인용 표식(`등`·`일부`)이 없다. `601903` `TI-9-a` 는 `등` 을 붙였고, `601905` §5 `Q-8` 은 「오염 유형과 탐지 사실」로 추상화했다.

`containment actions` **9건** 중 `TI-9` 가 다룬 것은 3건이다.

```text
TI-9 가 「tenant-wide 보다 작은 것」으로 분류    block projection · disable export ·
                                                disable vector retrieval
TI-9 · TI-2 어느 쪽에도 귀속되지 않은 6건       suspend affected view
                                                quarantine event
                                                disable AI context
                                                require admin/security review
                                                preserve evidence
                                                notify internal incident route
```

`601905` §5 는 `Q-9`(scoped containment 기록)를 「어느 scope 를 어느 범위로 막았는가」로 정의한다. `preserve evidence` 와 `notify internal incident route` 는 scope 차단이 아니므로 `Q-9` 에도 들어가지 않는다. 모델 안에 자리가 없는 상위 원천 항목 6건이 남는다.

---

### C2-3 `010650` 이 별도 상태로 요구한 recovery 가 2값 모델에 표현되지 않는다 [대조]

`601901` §9.2.2 채록:

```text
§5   CIRCUIT_HALF_OPEN / CIRCUIT_RECOVERING / CIRCUIT_CLOSED_VERIFIED
     Circuit close must require verification.
§29  Recovery starts after containment.
     Recovery is not complete until verified.
§42  Circuit breaker, DLQ, quarantine, financial hold, degraded mode,
     fallback, and recovery are separate states.
§38  Avoid: closing circuit without verification
```

`601905` §2 는 `ISOLATED --> NONE` 단일 간선이다. 「해제 승인은 났으나 recovery 검증이 끝나지 않은 tenant」를 표현하는 상태가 없다.

`601902` `TI-2` 는 2값 고정을 `600021` `C-2`(부분 containment) 에 대한 응답으로 정당화했다. **recovery 축은 scope 축과 다른 축이며 `TI-2` 의 논거가 그 축을 다루지 않는다.** `TI-1` 이 `010650` 을 직접 구속으로 채택했으므로 §42 는 이 나선에 적용된다.

> 대응 관측 — `TI-4-a` 가 「원인 · 위험 해소 evidence」를 해제 요건으로 요구하므로 §38 anti-pattern(`closing circuit without verification`)의 **요건 층위**는 닫혀 있다. 열려 있는 것은 §42 가 요구한 **상태 층위**의 분리다. acceptance rule 이 이 구분을 어떻게 다루는지는 확인 불가.

---

### C2-4 `600021` `C-2` 의 처분이 `010640` §6 을 남긴다 [대조]

`600021` §1.1 `C-2` 원문:

> `010004` §20 이 surface 별 부분 containment 를 정의하고 **`010640` §6 이 `SCOPE_PARTIAL_VALID` 를 상태로 요구한다.**

`601902` §3 은 `C-2` 를 `TI-2` 로 처분했다. `TI-2` 는 부분 containment 의 **책임 분리**를 선언하고 물리 표현을 Stage 4 로 유보한다.

`010640` §6 이 요구한 것은 책임 분리가 아니라 **scope validation 상태 집합 16개**다(`SCOPE_NOT_EVALUATED` ~ `SCOPE_DLQ_REQUIRED`). `TI-8` 은 scope envelope 의 **존재 의무**만 선언하고 상태 집합을 다루지 않는다. `601901` §21.1 실측: `SCOPE_*` 문자열 포함 함수 0건.

`C-2` 는 「처분됨」으로 기록됐으나 그 지적이 인용한 §6 요구는 어느 `TI-N` 에도 승계되지 않았다.

---

### C2-5 `600021` §2 강제 5건 중 `000150` · `000190` 이 어느 규칙의 근거로도 인용되지 않았다 [대조]

`601902` §1 의 12개 규칙 근거 행 전수:

| `TI-N` | 근거로 인용된 원천 |
|---|---|
| `TI-1` | `601901` |
| `TI-2` | `601901` · `010650` · `010630` |
| `TI-3` | `010630` · `010650` |
| `TI-4` | `010650` · `010630` |
| `TI-5` | `010650` |
| `TI-6` | `601901` · `010660` |
| `TI-7` | `601901` · `010640` · **`000170`** |
| `TI-8` | `601901` · `010640` |
| `TI-9` | `600021` · `010004` |
| `TI-10` | `600021` · `010004` · `601901` |
| `TI-11` | `600021` · `010004` · `601900` |
| `TI-12` | `601702` · `601903` · `601905` |

```text
000150   §1 인용 0건
000190   §1 인용 0건
```

두 문서는 `601902` §7 근거 목록에 `ACTIVE — mandatory` 로 등재돼 있고, `601901` §7·§9 가 Stage 0 에서 원문을 채록했다. `600021` §1.2 가 「판정에 필요한 것은 「봤는가」이며 「몇 번 봤는가」가 아니다」라고 정했으므로 **Stage 0 이 봤다는 사실은 확인된다.**

기록하는 사실은 다음이다 — **Stage 1 의 12개 선언 중 이 두 문서에서 도출된 것이 0건이고, `601905` 에 이 두 문서로 소급되는 요소가 0건이다.**

`601901` 이 채록한 두 문서의 원문 중 `TI-3`·`TI-4` 의 주체 정의와 맞닿는 지점:

```text
000150 §5    Parent group is not automatic access authority.
000150 §22   A link is not authority. Authority requires role and scope.
000150 §23   Franchise OS admin → no CatchMenu admin authority by default
000190 §17   No implicit cross-business authority.
000190 §27   A suspended or invalidated link must not continue to grant
             data flow or inferred relationship. Broken link must fail closed.
```

`TI-3` 의 「Authorized platform-security Human」이 어느 business boundary 에 속하는지, `ISOLATED` tenant 의 cross-business link 가 어떻게 되는지를 이 두 문서가 다룬다.

> ⚠️ `600021` §1 사유 3 이 무효화 사유로 든 것과 같은 유형이다.
> ```text
> 601801 및 4단계 산출물 4건에서 000150 · 000170 인용 0건
> ```
> 이번에는 `000170` 이 `TI-7` 에서 1회 인용됐고 `000150` · `000190` 이 0건이다. **동일하지는 않으나 같은 계열이다.**

---

## C3 수직 추적성

> 원천 → `601901` → `601902` → `601905` — 어느 단계에서 의미가 바뀌었는가

### C3-1 `601901` 이 실측한 축 혼용 실물 사례가 `601904` · `601905` 로 넘어가지 않았다 [대조]

`601901` §18 · §21 실측:

> phantom — 참조 테이블·컬럼 phantom 0건; **`tenant_status` 에 `ISOLATED` 를 쓰는 본문 경로가 있고 해당 CHECK 허용값에는 `ISOLATED` 가 없음**

즉 현행 `isolate_tenant` 는

```text
isolation_state       참조 0건
tenant_status         'ISOLATED' 를 쓰는 경로 존재
chk_tenants_status    ACTIVE · TRIAL · SUSPENDED · CANCELLED · TERMINATED
                      ISOLATED 없음
```

**이것은 `TI-12`(계층 상태 분리) 가 금지한 「상위 상태를 하위 상태의 대체물로 사용」의 실물 사례이자, 실행 시 CHECK 위반이 되는 경로다.**

전파 상태:

| 문서 | 이 사실의 기록 |
|---|---|
| `601901` §18 · §21 | 기록됨 |
| `601903` | `TI-4-g` 행이 `p_isolate boolean` 양방향 경로만 언급. `ISOLATED` write 는 없음 |
| `601904` §2 `TI-2` · §5.1 · §6 C5 | 없음. §5.1 은 `참조·WRITE 문자열 관측` 으로만 기록 |
| `601905` §6 | 없음 |

`601905` §6 은 「현재 상태 대 모델」 표이며 Stage 4 가 간극을 볼 지점이다. 이 표에 이 사실이 없다.

---

### C3-2 `601905` §0.2 의 「수렴 4건」이 `601904` 의 두 표 중 한쪽만 사용해 계산됐다 [대조]

`601904` 는 같은 `TI-N` 에 대해 두 곳에서 다른 표현을 쓴다.

| `TI-N` | `601904` §2 C1 「측정 결과」 | `601904` §6 C5 「현재 강제」 |
|---|---|---|
| `TI-2` | **강제되지 않는다** | 2값 CHECK만 강제 |
| `TI-7` | **강제되지 않는다** | 별도 컬럼·타입만 존재 |
| `TI-3`~`TI-6` · `TI-8`~`TI-10` | 강제되지 않는다 | 강제되지 않음 |

`601905` §0.2:

```text
Codex 「강제 안 됨」  TI-3 · TI-4 · TI-5 · TI-6 · TI-8 · TI-9 · TI-10     7건
```

7건은 §6 C5 의 문자열 일치 결과다. §2 C1 기준이면 `TI-2`·`TI-7` 을 포함한 9건이다.

`601905` §0.1 은 입력을 「`C1` 강제 가능성 · `C5` 간극표」로 **둘 다** 선언했다. 두 표가 어긋난다는 사실도, 어느 쪽을 채택했다는 선언도 없다.

수렴 집합에 미치는 영향:

```text
601905 가 적은 수렴          TI-3 · TI-4 · TI-5 · TI-6              4건
§2 C1 기준 교집합            TI-2 · TI-3 · TI-4 · TI-5 · TI-6 · TI-7  6건
```

§0.2 는 이어서 「**이 넷이 모델의 중심이다. §2 · §3 · §4 가 그 넷을 그린다**」고 선언한다. 모델의 분량 배분이 이 계산 위에 놓여 있다.

---

### C3-3 `601903` 이 의도적으로 약하게 쓴 문구가 `601905` 에서 강해졌다 [대조]

`601903` §3 서두 문구 규칙:

> 「새로 만들어야 한다」고 쓰지 않는다. **「기존 자산에서 확인되지 않는다」로만 쓴다.**

`601905` §0.2 의 라벨:

```text
Cursor 「자산 없음」
```

「확인되지 않는다」(측정의 한계를 포함하는 표현)와 「자산 없음」(존재의 부정)은 다른 주장이다.

집계 규칙 문제도 함께 있다. `601905` 는 `TI-2` 를 「자산 없음」 목록에 넣었으나 `601903` §3 은 `TI-2-a` 를 **「기존 자산에 있다」**, `TI-2-b` 를 「부분적으로 있다」로 기록했다. `TI-6` 도 `TI-6-a~b` · `TI-6-d` 가 「부분적으로 있다」다.

`601903` 의 sub-item 별 판정을 `TI-N` 단위로 접는 규칙(예: 「하나라도 확인되지 않으면 전체를 자산 없음으로」)이 `601905` 어디에도 선언돼 있지 않다.

---

### C3-4 `601902` `TI-12` 가 `601905` 를 근거로 인용한다 [대조]

`601902` §1.12 마지막 행:

```text
근거 — 601702 §1.27 · §1.28 · 601903 §5.3 · 601905 검토 의견
```

`601905` §0 은 자신을 「`000701` §47.1 의 **2단계** ERD 초안 산출물」로, `601902` 를 「**1단계** 업무규칙 선언」이자 「모델의 유일한 선언 출처」로 규정한다. `601905` §0.1 은 `601902` 를 입력으로 선언한다.

**1단계 문서가 2단계 문서를 자신의 근거로 인용하고, 2단계 문서가 1단계 문서를 유일한 출처로 선언한다.**

`601902` §0 은 1단계를 「Human 전담이며 AI 위임 불가」로 규정한다.

> `600021` §2 ⛔ 는 하류 산출물을 상류의 답안지로 쓰는 것을 금지했다. 대상은 `601800` 이었으나 방향의 문제는 같다. 이 인용이 그 금지에 해당하는지는 acceptance rule 소관이다.

---

### C3-5 「두 축이 서로 독립」이 `TI-2-a` · `TI-2-b` 로 귀속됐다 [대조]

`601905` §1 다이어그램 제목: 「**tenant 이 가지는 두 축 — 서로 독립**」

§1 읽는 법 표: 「두 축이 서로 독립 | `TI-2` (`TI-2-a` · `TI-2-b`)」

`601903` §2 원문:

```text
TI-2-a   tenant-wide isolation 상태값 집합 (NONE · ISOLATED)
TI-2-b   그 상태가 tenant 전체에만 적용된다는 경계
```

**두 항목 모두 `tenant_status` 를 언급하지 않는다.** `601902` `TI-2` 본문에도 `tenant_status` 가 없다. `TI-12` 는 「나머지 4축이 두 소유 축에서 파생되지 않는다」를 선언하며, 소유 2축 **사이**의 관계는 선언하지 않는다.

「서로 독립」은 (`tenant_status` 5값 × `isolation_state` 2값) 10개 조합이 모두 유효하다는 함의를 갖는다. `TERMINATED` + `ISOLATED`, `CANCELLED` + `ISOLATED` 로의 전이 가부를 선언한 `TI-N` 은 없다.

관련 상위 선언 — `601702` §2.1 은 특정 조합을 미결 항목으로 명시한다.

```text
`ACTIVE`+`ISOLATED` 상태의 과금 처리는 미결이며 사업 정책 결정 사항이다
```

`601905` §0 자기 제약: 「**`601902` 에 없는 선언을 만들지 않는다.**」

---

### C3-6 `tenant_status` — `TI-12` 는 「소유」, `601905` 는 「읽기만」 [대조]

```text
601902 TI-12    이 나선이 소유하는 축
                  tenant_status
                  isolation_state
601905 §1       TS "tenant_status ... 이 나선이 읽기만 한다"
601905 §1 ⚠️    tenant_status 값 집합을 그리지 않았다.
                601902 가 그 축을 선언하지 않았고 이 나선은 읽기만 한다
```

소유 축의 값 집합·전이가 어느 나선에서도 선언되지 않은 상태로 남는다. C3-1 의 실측(현행 함수가 `tenant_status` 에 CHECK 밖 값을 쓴다)과 함께 읽으면, **「읽기만 한다」는 서술과 실측 상태가 어긋난다.**

---

## C4 모델 자체의 정합

### C4-1 `ISOLATED` 상태에서 발동 요청이 들어오는 경로가 없다 [대조]

`601905` §2 의 간선은 `NONE → ISOLATED`, `ISOLATED → NONE` 둘뿐이다. self-loop 없음.

`TI-9` 는 cross-tenant contamination 탐지를 발동 사유로 인정한다. 이미 `ISOLATED` 인 tenant 에서 두 번째 오염이 탐지될 경우:

```text
TI-6 파생 입력에 stable action identity 가 들어가므로
새 trigger_event_id 는 새 canonical key 를 만든다
→ 중복이 아니다 → 실행 대상이다
→ ISOLATED → ISOLATED 전이는 §2 에 없다
```

멱등 중복(§4 소관)과 상태 중복(§2 소관)이 다른 사건인데 모델이 후자를 다루지 않는다.

---

### C4-2 §6 표에 `TI-12` 행이 없고 §8 요약 계수가 어긋난다 [대조]

```text
§6 「현재 상태 대 모델」   TI-1 ~ TI-11        11행
§8 「TI-N 추적표」         TI-1 ~ TI-12        12행
§8 요약문                  "11건 전건 기록"
```

`601905` 개정 이력이 `TI-12` 반영 범위를 명시한다.

> `601702` §1.28 계층 상태 분리를 **§1 에 추가하고 §8 추적표를 12건으로 갱신**

§6 은 갱신 대상에서 빠졌고, §8 요약 계수는 갱신되지 않았다. §6 의 출처인 `601904` §6 C5 가 `TI-12` 이전 산출물이라는 사정은 §6 에 기록돼 있지 않다.

---

### C4-3 §0.1 과 §9 가 입력을 「`TI-1`~`TI-11`」로 유지한다 [대조]

```text
§0.1 입력        601902   TI-1 ~ TI-11 · HD-0-A-2R-1 ~ 9 · OQ-1 ~ OQ-3
§9 근거 목록     601902   TI-1~TI-11 · HD-0-A-2R-1~9 · OQ-1~OQ-3
                          — 모델의 유일한 선언 출처
```

`601902` 현재 상태는 `TI-1`~`TI-12` · `HD-0-A-2R-1`~`10` 이다. §1·§8 은 `TI-12` 를 담고 있으므로 문서 내부에서 입력 선언과 본문이 어긋난다.

---

### C4-4 §8 `TI-12` 행이 2열 표에 3셀로 들어가 있다 [대조]

```text
| `TI-12` | §1 ⚠️ 계층 상태 분리 | 표현 |
```

같은 표의 다른 11행은 2셀이다. 렌더링 시 세 번째 셀이 소실되거나 헤더와 어긋난다.

---

### C4-5 `D-4` 가 `TI-12` 로 「부분적으로 답했다」고 기록한다 [대조]

`D-4` 원 질문:

> `Q-4`(authority 판정)를 이 나선이 소유하는지, `0-C` 가 소유하고 이 나선은 결과만 소비하는지 정해지지 않았다

`TI-12` 의 여섯 축:

```text
TenantStatus · MerchantAccountStatus · StoreServiceStatus ·
StoreOperatingStatus · TrialStatus · IsolationState
```

**authority 판정은 이 여섯 축에 없다.** `TI-12` 의 「나머지 4축은 직접 변경 대상이 아니다」는 authority 판정의 소유권 질문에 닿지 않는다.

`D-4` 본문 자신도 마지막에 「「authority 판정을 이 나선이 소유하는가」는 여전히 열려 있다」고 적어, 「부분적으로 답했다」와 같은 항목 안에서 상충한다.

---

### C4-6 §3 의 `OQ-1` 분기가 모델이 자기 밖으로 둔 대상을 가리킨다 [해석]

`601905` §1 은 scoped containment 를 「별도 책임 · 물리 형태 미정」 점선 상자로 두고, `TI-2-d` 를 근거로 이 모델의 소유 밖에 놓는다.

`601905` §3 은 gate 의 적용 대상을 「transition 요청 — 발동 또는 해제」로, 즉 `isolation_state` 전이로 규정한다. 그 gate 의 `AUTHORITY_PARTIAL_ALLOWED` 분기가 「scoped containment 를 허용하는가」로 나간다.

`isolation_state` 전이에 대한 gate 판정이 다른 representation 의 동작을 허가하는 구조가 되며, 모델은 `OQ-1` 이 자기 경계 안쪽 질문인지 바깥쪽 질문인지 선언하지 않는다. §7.3 `D-3` 이 같은 미정(「scoped containment 가 이 나선의 범위 안인지 밖인지」)을 별도로 기록하고 있으나 §3 과 연결되지 않았다.

---

## 우려가 없는 지점 — 명시

침묵 금지 조항에 따라, 검토했으나 문제를 찾지 못한 항목을 기록한다.

| # | 항목 | 관측 |
|---|---|---|
| 1 | 초기 상태 선언 | §2 가 `[*] --> NONE` 을 명시했다. `601901` §17.1 실측 DEFAULT `'NONE'` 과 일치한다. 선행 나선 `C-B2`(미선언 초기값) 유형의 재발을 찾지 못했다 |
| 2 | `TI-5` 비대칭 | §2 note 와 별도 flowchart 두 곳에 표현됐다. `A -.x C` 로 권한 비상속을 명시적으로 끊었다 |
| 3 | escalate 를 방향선으로 그리지 않은 처리 | `TI-2` 의 「자동 승격 없음」 선언과 어긋나지 않는다. §1 · §5 `Q-8`—`Q-9` 두 곳에서 일관된다 |
| 4 | `P-1`~`P-13` 처리 | §7.1 · §7.2 가 13건 전건에 대해 「모델의 어디에서 미정으로 남겼는가」를 기록했다. 추정으로 채운 흔적을 찾지 못했다 |
| 5 | 조사 독립성 | `601903` 은 `601904` 를, `601904` 는 `601903` 을 각각 열람 0건으로 기록했다. 두 실측의 측정 환경(컨테이너 ID · 이미지 · 최신 migration)이 일치한다 |
| 6 | `600021` §2 ⛔ 준수 | `601902` §0 · `601905` §0 · `601903` §0 · `601904` §0 모두 `601801`·`601803`·`601809`~`601812` 미열람·미승계를 명시했다. `HG-A-N` 식별자가 어느 문서에도 나타나지 않는다 |
| 7 | `TI-11` · `TI-1` 미표현 처리 | §8 이 두 건을 「모델에 나타나지 않는다」로 사유와 함께 기록했다. 표현할 수 없는 것을 억지로 그린 흔적이 없다 |
| 8 | `TI-6` 신뢰 경계 표현 | §4 의 `OUT` / `IN` subgraph 분리가 `TI-6-c`(신뢰 경계 안 검증)와 `TI-6-e`(caller 가 정하지 않음)를 정확히 반영한다 |
| 9 | 물리명 유보 | §0 · §5 · §6 이 물리 객체명을 옮기지 않았고 `Q-N` 을 개념 식별자로 명시했다. `601902` §5 유보 목록과 어긋나는 확정을 찾지 못했다 |

---

## 확인 불가 항목

**추정으로 채우지 않는다.**

| # | 항목 | 사유 |
|---|---|---|
| U-1 | **finding acceptance rule** | 「Verifier A 와 동일」로 지정됐으나 rule 본문 미첨부. 각 finding 의 채택 여부·등급을 판정할 수 없다 |
| U-2 | **출력 형식** | 동일 사유. 이 보고서는 Verifier A 형식이 아니다 |
| U-3 | 원천 정책 8건 원본 | `010004`·`010640`·`010630`·`010650`·`010660`·`000150`·`000170`·`000190` 미첨부. **`601901` 채록본만으로 대조했다.** 채록되지 않은 절에 상충 선언이 있는지 확인 불가 |
| U-4 | `010004` §19 항목 수 | `600021` §1.1 `R-6` 은 「13필드」, `601901` §5.2 채록 원문은 bullet 14개다. 원본 미첨부로 어느 쪽이 정확한지 확인 불가. C2-1 은 「`cross-scope attempt` 항목의 소실」이라는 사실만 기록하며 총 개수를 확정하지 않는다 |
| U-5 | `010630` §27 `Authority Evaluation Order` | `601901` §9.1.1 전체 절 구조에 이름만 있고 §9.1.2 원문 채록에서 제외됐다. C1-6(gate ↔ idempotency 순서)에 대한 상위 선언 존재 여부 확인 불가 |
| U-6 | `010650` §30 `Reclose` | `601901` §11.1 이 0-A-2 관련 지점으로 지목했으나 §9.2.2 원문 채록에 없다. C2-3(recovery 상태)에 대한 추가 요구 확인 불가 |
| U-7 | `601900_Readme_Tenant_Isolation_Axis_V2.md` | 미첨부. `601902` `TI-11` 과 `601905` §9 가 §3·§4·§5 를 인용한다. 재수행 대역의 자체 구속과의 정합 확인 불가 |
| U-8 | `000701` §46 · §47.1 | 미첨부. 단계 정의, 4단계 evidence pack 요구, 근거 목록 형식 요건을 확인할 수 없다. C3-4(1단계↔2단계 방향)의 절차 위반 여부를 규정 원문으로 확정할 수 없다 |
| U-9 | `601816` finding 15건 원문 | 미첨부. `601902` §2 의 재적용 10건 / 미승계 5건 분류가 원 finding 내용과 맞는지 확인 불가. C1-2 는 **`601902` 가 스스로 재적용으로 선언한 10건이 `601905` 에 없다**는 사실만 기록한다 |
| U-10 | 라이브 DB | 접근 없음. `601903` · `601904` 의 실측치를 재현·반증할 수 없다. C3-1 은 `601901` §18 기록을 사실로 전제한다 |
| U-11 | `010630` §41 `Suggested Conceptual Entities` | 미채록. `601905` §5 `Q-N` 집합이 상위 정책의 개념 엔티티 제안과 어긋나는지 확인 불가 |
| U-12 | `601702` §1.1~§1.45 중 `601901` 이 채록하지 않은 절 | `601901` §3.2 는 관련 절을 「§1 전건」으로 적고 6개만 채록했다. `601702` 원본은 첨부됐으나 **`601901` 이 어느 절을 검토하고 제외했는지의 판단 근거가 문서에 없다.** 미채록 39개 절과 `TI-N` 의 상충 여부는 이 세션에서 전수 대조하지 않았다 |

---

## 판정 요약

```text
수행한 축     C1 · C2 · C3 · C4  전 4축
finding       C1  8건
              C2  5건
              C3  6건
              C4  6건
              계 25건
우려 없음     9건 명시
확인 불가     12건
```

**처분·재설계·대안은 적지 않았다.**
**등급 부여는 `U-1` 로 인해 수행하지 않았다. Human 이 실제 acceptance rule 로 수행한다.**

**Verifier C** — Claude (Opus), 2026-09-04
````

## §2 Status

```text
Audit evidence only.
```

**통합은 `601909` 가 수행한다. 처분은 Human 이 정한다.**
