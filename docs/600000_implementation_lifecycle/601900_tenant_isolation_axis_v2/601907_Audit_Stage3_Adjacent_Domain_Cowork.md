# 601907_Audit_Stage3_Adjacent_Domain_Cowork.md

Status: Draft
Lifecycle: Audit
DocumentType: Audit
Gate Classification: Independent Audit Review
Runtime Implementation Authorization: Not Applicable
Owner: Cowork (Verifier B — 문서 축 · 수직 추적성)
Last Updated: 2026-09-04

## §0 성격과 경계

`000701` §47.1 **3단계 인접 도메인 대조** 산출물이다.
`601902`(1단계 업무규칙)와 `601905`(2단계 상태 · 책임 모델)를 **동등한 검증 대상**으로 본다.

```text
Verifier A   Codex    실측 축      → 601906
Verifier B   Cowork   문서 축      → 601907   ← 이 문서
Verifier C   Claude   외부 타당성   → 601908
```

**상호 참조 금지 준수** — `601906` 은 폴더 목록에서 파일명만 확인했고 내용을 열지 않았다.
**권위보류 판정문 열람 0건** — `601801` · `601803` · `601809`~`601815` 를 열지 않았다.
`601816` 은 `600021` 이 승계한 finding 목록 확인 용도로만 `601901` §12.4 를 경유해 확인했고 처분을 승계하지 않는다.

**Eyes-Only 준수** — 파일 수정 0건. 이 결과 파일 1개만 생성했다.
**DB 접속 0건.** **git write 명령 0건.** read-only git 만 사용했다.
**재설계 · 대안 제시 · 처분 판정을 하지 않는다.**

## §1 판본 확인

`git ls-files --eol` 결과 3건 모두 `i/lf  w/lf  attr/` 다.

| 문서 | 지시서 SHA-256 | 실측 | 일치 |
|---|---|---|---|
| `601902_Register_Stage1_Business_Rules.md` | `1A42391B85B878C28876747821D66B3FE6ED95B70576367EFDD3635D857FD585` | `1a42391b85b878c28876747821d66b3fe6ed95b70576367efdd3635d857fd585` | ✅ |
| `601905_Diagram_Tenant_Isolation_Axis_Model.md` | `33106696F0CA32CF814E10FDD5D9C9AB94FD7217431C8F3025B501F73AAB3351` | `33106696f0ca32cf814e10fdd5d9c9ab94fd7217431c8f3025b501f73aab3351` | ✅ |
| `601901_Register_Stage0_Evidence_Collection.md` | `9C494EA29D02A8445976BF7CF38AE79C1AE71F8F0FEB53FF9EE0F5783F0195BE` | `9c494ea29d02a8445976bf7cf38ae79c1ae71f8f0feb53ff9ee0f5783f0195be` | ✅ |

| 항목 | 지시서 | 실측 |
|---|---|---|
| 커밋 | `01dec6c79350c53054616c7179c02b5fc56aa298` | `01dec6c79350c53054616c7179c02b5fc56aa298` |

**대역 working tree 상태** — `601900_tenant_isolation_axis_v2/` 안의 추적 파일 변경 0건.
`601906_Audit_Stage3_Adjacent_Domain_Codex.md` 만 untracked 로 존재한다(열지 않음).

## §2 세션 조건

```text
2단계 작성자 배제   충족 — 601905 를 작성한 세션과 다른 새 대화창이며
                          이 세션은 601905 를 작성하지 않았다
사전 맥락 0        충족 — 이 지시서 이전 대화 0턴.
                          작업 문맥은 지시서 · 열람 허용 문서 · read-only git 에서만 취득했다
```

## §3 종합

| 축 | 발견 | blocking | informational |
|---|---|---:|---:|
| B1 내부 정합성 — `601902` ↔ `601905` | 9 | 1 | 8 |
| B2 수직 추적성 — 원천 → `601901` → `601902` → `601905` | 9 | 2 | 7 |
| B3 상위 문서 어휘 충돌 — `601702` · `000220` · `000221` | 1 | 1 | 0 |
| B4 권위보류 경계 | 0 | 0 | 0 |
| **합계** | **19** | **4** | **15** |

**B4 — `NO CONCERNS FOUND`.**

```text
601902 §7 · §2       601816 · 601801 · 601803 · 601809~601812 를
                     ⛔ AUTHORITY SUSPENDED 로 명시하고 finding 만 처분
601905 §0 · §9       601803 · 601809~601812 를 「열지 않았다」로 명시
601901 §12 · §15.5   601500 · 601600 · 601800 대역을 evidence inventory 로만 기록
000221 §3.2 경계     601502 · 601503 · 601505 · 601510 · 601511 —
                     601902 · 601905 인용 0건.
                     601900 Readme §7 · §10 은 601505 §4 금지조항을
                     600010 §1.1 경유 evidence 로만 인용한다
HG-A-N 이식          TI-1 ~ TI-12 중 HG-A-N 을 사실상 옮긴 것은 확인되지 않는다.
                     TI-2 가 isolation_state 를 2값으로 닫은 결과는
                     600021 §1.1 C-2 가 기록한 HG-A-9.1 과 같아지나
                     도출 경로(601901 Q-P10 · 010650 §4·§18·§36 ·
                     010630 §9 SCOPE_GATE)가 문서에 남아 있고
                     600021 §2 가 「결과적으로 같아지는 것」을 허용한다
601902 §2            S6-1 · S6-10 · S6-12 에서 옛 D-1·D-2·D-3 · D-27 ·
                     provisional_attribution 을 명시적으로 비승계 처리
```

## §4 Findings

| # | 축 | 지점 | 내용 | blocking | rule 근거 |
|---|---|---|---|---|---|
| F-1 | B2 | `601902` 289~313행 · `601905` 269행 | `010004` §19 의 **`cross-scope attempt if any`** 가 `TI-10` 에서 탈락했다 | ✅ | 4 |
| F-2 | B1 | `601905` 70행 · 98~99행 vs `601902` 355~360행 | `601905` 가 `tenant_status` 를 「이 나선이 읽기만 한다」로 선언했다. `TI-12` 는 이 나선의 **소유 축**으로 선언했다 | ✅ | 2 · 1 |
| F-3 | B3 | `000221` §4.1 · `600010` §1.1 vs `601900` 대역 전체 | **Human Gate A**(`tenant` `ACTIVE`+`ISOLATED` 동시상태의 과금 · 서비스 정책)가 재수행 대역 어디에도 없다 | ✅ | 4 |
| F-4 | B2 | `601902` 429~436행 · 550행 vs `600021` §1.1 `C-2` | `C-2` 후단(`010640` §6 `SCOPE_PARTIAL_VALID`)이 어떤 `TI-N` 에서도 다뤄지지 않은 채 「처분됨」으로 기록됐다 | ✅ | 3 |
| I-1 | B2 | `601901` 774행 · 1067행 · 1401행 | `010630` · `010650` · `010660` 의 「전체 절 구조」가 실제 heading 과 불일치하며 같은 문서의 인용 블록과도 모순된다 | — | — |
| I-2 | B2 | `601902` 254행 vs `601901` §6.2 | `TI-8` 이 판정 근거로 든 `010640` §5 필드표가 `601901` 에 채록돼 있지 않다 | — | — |
| I-3 | B1 | `601902` 117~126행 · `601905` 202행 | `TI-3` 본문과 같은 절 ⚠️ 가 `AUTHORITY_PARTIAL_ALLOWED` 에 대해 닫힘/열림으로 상충한다 | — | — |
| I-4 | B2 | `601902` §1 전체 · `601905` 전체 | `ISOLATED` 상태의 **효과**가 어디에도 선언되지 않는다 | — | — |
| I-5 | B1 | `601905` 87행 | 「두 축이 서로 독립」의 출처를 `TI-2`(`TI-2-a`·`TI-2-b`)로 적었으나 `TI-2` 는 `tenant_status` 를 언급하지 않는다 | — | — |
| I-6 | B1 | `601905` 18행 · 34행 · 399행 | `TI-12` · `HD-0-A-2R-10` 이 §0 · §0.1 · §9 에 반영되지 않았다 | — | — |
| I-7 | B1 | `601905` 391행 · 393행 | §8 `TI-12` 행이 2열 표에 3열로 들어갔고, 「11건 전건 기록」이 12건으로 갱신되지 않았다 | — | — |
| I-8 | B2 | `601902` 544~559행 | §7 근거 문서 목록에 `601903` · `601905` 가 없다. §1.12 가 둘을 근거로 인용한다 | — | — |
| I-9 | B2 | `601902` 550행 | §7 이 `010640` §41 을 인용 목록에 올렸으나 §1 어느 규칙도 §41 을 인용하지 않는다 | — | — |
| I-10 | B1 | `601905` 42~47행 vs `601903` §3 | 「Cursor 자산 없음」 목록이 `601903` 판정과 어긋난다 | — | — |
| I-11 | B2 | `601902` 417~427행 | §3 Q-P 처분표가 `Q-P13` 을 누락했다 | — | — |
| I-12 | B2 | `601903` §5.1 · §5.4 | `601702` §1.26 Invariant · §1.43 접점의 반영/미반영 **사유가 어디에도 없다** | — | — |
| I-13 | B1 | `601905` 59행 vs 70행 | 「물리 객체명은 이 문서가 옮기지 않는다」와 §1 노드명이 상충한다 | — | — |
| I-14 | B1 | `601900` Readme 204행 vs 73행 | File List 가 `601902` 를 「11건 · `HD-1`~`9`」로 기록한다 | — | — |
| I-15 | B1 | `601902` 382행 · `601905` 399행 | `601902` §1.12 가 `601905` 검토 의견을 근거로 들고, `601905` 는 `601902` 를 「유일한 선언 출처」라 한다 | — | — |

### §4.1 blocking 상세

#### F-1 — `010004` §19 `cross-scope attempt if any` 탈락 (rule 4)

**원천** — `010004` 504~527행 `## 19. Audit Isolation Rule` 는 14항을 열거하며 마지막 항이
`- cross-scope attempt if any` 이고, 그 직후 두 문장이

```text
Cross-tenant access attempts must be auditable.
Failed access is also security evidence.
```

**`601901` 은 이를 온전히 채록했다.**

```text
601901 227~250행   §19 전문 — cross-scope attempt if any 포함
601901 2237행      Pass 2 실측 — 「원문 열거 필드 중 … cross-scope attempt
                   이름의 컬럼은 없다」
```

**`601902` 에서 탈락했다.**

`601902` 291~298행 은 「`010004` §19 가 audit event 필드를 정한다」고 쓴 뒤
`tenant id · store id · actor id · actor role · surface · device · target object id · type · action ·
previous scope · new scope · authority reference · policy reference · evidence reference` 만 열거한다.
`surface/device` 를 둘로 나누었으므로 항목 수는 14로 같아 보이나 **`cross-scope attempt` 가 없다.**

**하류로 그대로 전파됐다.**

```text
601903 142행   TI-10-a — 동일 목록, cross-scope attempt 없음
601905 269행   §5 Q-2 audit envelope — 동일 목록, cross-scope attempt 없음
```

**대역 전체 문자열 검색 결과** `cross-scope` 는 `601901` 2건(245행 · 2237행)에만 있고
`601902` · `601903` · `601905` 에 0건이다.

**왜 blocking 인가**

`TI-9`(`601902` 256~287행)가 cross-tenant contamination 탐지를 격리 발동 사유로 인정했다.
그 탐지 사실을 남기는 항목이 곧 `cross-scope attempt` 다.
`010004` §19 는 그 항목 뒤에 「실패한 접근도 보안 증거」라고 명시한다.
`601901` 은 원문을 채록했고 실측으로 **부재까지 확인**했는데 `601902` 가 목록에서 뺐다.
`600021` §1.1 `R-6` 가 지적한 것과 같은 계열의 결손이 `R-6` 를 처분하는 규칙 안에서 재발했다.

#### F-2 — `tenant_status` 소유/읽기 상충 (rule 2 · rule 1)

**`601902` 339~373행 `TI-12`**

```text
이 나선이 소유하는 축

tenant_status
isolation_state
```

**`601905` 70행 · 98~99행**

```text
TS["tenant_status<br/>계약 · 고객 lifecycle<br/>이 나선이 읽기만 한다"]

⚠️ tenant_status 값 집합을 그리지 않았다.
   601902 가 그 축을 선언하지 않았고 이 나선은 읽기만 한다.
```

**`601900` Readme 11~16행**

```text
Tenant lifecycle 축과 격리 축을 확정한다.

tenant_status     계약 · 고객 lifecycle
isolation_state   보안 · 장애 대응을 위한 기술적 격리
```

**왜 blocking 인가**

「읽기만 한다」는 `601902` 에 없는 범위 선언이다(rule 2).
`601902` §5 「이 나선이 정하지 않는 것」 6항에도 `tenant_status` 는 없고,
§6 열린 질문 3건에도 없다.
`TI-12` 는 오히려 「나머지 4축」만을 「이 나선의 직접 변경 대상이 아니다」로 분리했고,
그 대비로 소유 2축은 변경 대상임을 함의한다.
`601905` 모델대로 4단계를 진행하면 `tenant_status` 를 읽기 전용으로 취급하게 되며
`TI-12` 소유 선언과 `601900` Readme §1 의 나선 목적을 함께 위반한다(rule 1).

#### F-3 — Human Gate A 소실 (rule 4)

**상위 문서가 요구한 선행 게이트**

`000221` 71~92행 은 나선 순서의 **첫 줄**에 게이트를 둔다.

```text
Human Gate A   ACTIVE + ISOLATED 동시상태의 과금·서비스 정책 결정

0-A-2          Tenant lifecycle / RPC / batch alignment
```

`000221` §4.1 194~199행 —

```text
선행 게이트 — Human Gate A

tenant ACTIVE + ISOLATED 동시상태의 과금·서비스 정책 미정
→ 0-A-2 착수 전 Human 결정 필요
근거: 600010 §1.1 (601511)
```

**그 게이트의 유일한 해소 기록이 권위보류됐다.**

`600010` 84행 —

```text
tenant ACTIVE+ISOLATED 동시상태의 과금정책 미정
→ 0-A-2 착수 전 결정 필요(601511)
→ 2026-08-27 601801 HG-A-1~HG-A-9 로 해소
```

`600021` §2 와 `601902` 14~16행 이 `HG-A-1`~`HG-A-16` 승계를 금지했다.
**따라서 재수행 대역에서 Human Gate A 는 미해소 상태로 되돌아갔다.**

**재수행 대역 어디에도 없다.**

```text
601900 · 601901 · 601902 · 601903 · 601905
  「Human Gate」 0건
  「000221」    0건
  「600010」    601900 Readme 6건 — 전부 「트래커를 authority 로 쓰지 않는다」 취지
```

`601902` §4 `HD-0-A-2R-1`~`10`, §5 「정하지 않는 것」, §6 `OQ-1`~`OQ-3` 어디에도
`ACTIVE`+`ISOLATED` 동시상태 항목이 없다.
`601901` §15.1 통제 · 착수 근거 4건에도 `000221` 과 `600010` 이 없다 — 이 지점에서 빠졌다.

**왜 blocking 인가**

두 축의 동시상태 정책은 이 나선이 소유한 두 축 사이의 문제이며
`000221` §4.1 이 **착수 전** Human 결정으로 못박은 항목이다.
그 결정 없이 `601905` §1 이 두 축을 무조건 독립으로 그리면
`ACTIVE`+`ISOLATED` 조합의 과금 · 서비스 취급이 4단계에서 암묵적으로 결정된다.

> ⚠️ **rule 적합성에 대한 판단을 밝힌다.**
> rule 4 의 사슬은 「원천 → `601901` → `601902` → `601905`」이며
> 이 항목은 원천 8건이 아니라 `000221` · `600010` 에서 온 Human 결정 요구다.
> 「Human 선언이 사슬을 거치며 빠졌다」는 요건에는 해당하고
> 빠진 지점은 `601901` Stage 0 이다.
> B3 축이 `000221` 나선 순서를 명시적 판정 대상으로 두었으므로 blocking 으로 올린다.
> **Human 이 informational 로 재분류할 수 있는 항목임을 함께 기록한다.**

#### F-4 — `600021` §1.1 `C-2` 후단 미처분 (rule 3)

**`C-2` 는 두 절을 근거로 든다.**

`600021` 54행 —

```text
C-2  010004 §20 이 surface 별 부분 containment 를 정의하고
     010640 §6 이 SCOPE_PARTIAL_VALID 를 상태로 요구한다.
     601801 HG-A-9.1 은 isolation_state 를 2값으로 닫아
     부분 containment 를 표현할 수 없다
```

**`601902` 는 `C-2` 를 `TI-2` 로 처분했다고 기록한다**(432~434행).

`TI-2`(70~100행)는 전단(`010004` §20 의 부분 containment)에 답한다 —
「문제는 값의 개수가 아니라 … 책임 혼합이다」.
**후단에는 답하지 않는다.** `TI-2` 는 `010640` §6 도 `SCOPE_PARTIAL_VALID` 도 언급하지 않는다.

**대역 문자열 검색** — `SCOPE_PARTIAL_VALID` 는 `601901` 383행 채록 1건뿐이고
`601902` · `601905` 에 0건이다.

**`601902` §7 은 `010640` §6 을 인용 목록에 올렸다**(550행).
그러나 §1 의 어느 규칙도 §6 을 인용하지 않는다.
`TI-8`(228~254행)이 다루는 것은 `010640` §2 · §5 · §42 의 envelope 보유 의무이며
§6 의 scope validation 상태가 아니다.

**`010640` §36 도 미처리다.**

```text
010640 §36  Scope validation must be audited for high-impact actions.
            Audit should record:
              scope requested / scope resolved / scope validation result / …
```

`601901` §3.1 은 `010640` 관련 절에 §29~§38 을 포함시켰으나 §6.2 는 §31 · §35 만 인용했고
§36 원문은 채록하지 않았다.
`TI-8` 의 「tenant isolation transition 에 적용되는 것」 6항과
`TI-10` 의 audit 항목 어디에도 scope validation 결과가 없다.

**왜 blocking 인가**

`TI-1` 이 `010640` 을 mandatory 로 유지했고 `600021` §2 가 이를 강제했다.
`600021` 이 승계시킨 finding 을 **처분됨으로 기록한 채 절반만 처분**하면
그 finding 은 다음 검증에서 다시 열리지 않는다.
격리 전이는 명백히 high-impact action 이므로 §36 의 scope validation 감사 의무가 걸린다.

### §4.2 informational 상세

**I-1 — `601901` 「전체 절 구조」와 실제 heading 불일치**

`601901` 이 A1' 3건에 기록한 절 구조가 원문과 어긋난다. 대조 결과 일부만 옮긴다.

| 문서 | 절 | `601901` 기록 | 실제 heading |
|---|---|---|---|
| `010650` | §35 | Manual Containment Actions | Relationship To Authority Gate |
| `010650` | §36 | Containment Scope Rules | Relationship To Tenant Scope Envelope |
| `010650` | §38 | Example Containment Scenarios | Anti-Patterns |
| `010650` | §8~§15 | Timeout / Provider / Queue / DLQ / Financial / Authorization Unknown / Sensor / AI | Provider / Payment Route / Refund / Settlement / Store Runtime / Device / Queue / DLQ |
| `010630` | §27 | Authority Evaluation Order | Automated Authority Boundary |
| `010630` | §40~§43 | Observability / Suggested Entities / Example Decisions / Mandatory Failure Rules | Anti-Patterns / Runtime Deferral / Validation Checklist / Relationship To Previous |
| `010660` | §39~§43 | Suggested Entities / Example Flows / Testing / Policy Questions / Boundary | Event Catalog / Anti-Patterns / Runtime Deferral / Validation / Relationship To Previous |

같은 문서 §9.2.2 의 인용 블록은 `## 35. Relationship To Authority Gate` ·
`## 38. Anti-Patterns` 를 **정확히** 옮기고 있어 색인과 본문이 서로 모순된다.
`601902` §6 `OQ-3` 와 `601901` `Q-P13` 이 가리키는 `010650` §38 을
색인만 보고 찾으면 다른 절로 간다.
`TI-5` 가 든 `010650` §35, `TI-4` 가 든 anti-pattern 은
**원문 대조 결과 모두 옳다** — 결손은 색인에만 있다.

**I-2 — `TI-8` 근거 절의 채록 누락**

`601902` 254행 근거 — `601901` `Q-P5` · `010640` §2 · §5 · §42.
`601902` 233행 은 「`010640` §5 의 모든 후보 필드를 무조건 보유 — NOT REQUIRED」를 판정한다.
그런데 `601901` §6.2 가 인용한 `010640` 절은 §2 · §4(부분 행) · §6 · §7 · §31 · §35 · §42 이며
**§5 Mandatory Envelope Fields 표는 채록되지 않았다.**
`601901` §14 `Q-P5` 가 §5 의 "should carry" 문구를 언급할 뿐이다.
지시서가 경고한 「초판 `TI-4` ↔ `010650` §38」과 같은 유형이며 아직 보강되지 않았다.

**I-3 — `TI-3` 내부 상충**

`601902` 117~118행은 닫힌 규칙이다.

```text
모든 경우 authority gate 결과가 AUTHORITY_ALLOWED 일 때만 실행한다.
```

같은 절 122~126행 ⚠️ 는 연다.

```text
AUTHORITY_PARTIAL_ALLOWED 는 이 규칙이 다루지 않는다.
```

`010630` §28(`601901` 978~1011행 채록)의 `DENY_UNLESS_EXPLICITLY_ALLOWED` 를 적용하면
tenant-wide 전이에 대해서는 닫혀 있어야 한다.
`601905` §3 202행이 그 열림을 점선 「미정」 분기로 그대로 옮겼다.
`OQ-1` 의 질문 대상은 **scoped containment** 이므로 tenant-wide gate 의 분기로 그리면
두 축이 한 그림에서 섞인다.

**I-4 — `ISOLATED` 의 효과가 선언되지 않는다**

`TI-2` 는 상태값을, `TI-3`·`TI-4`·`TI-5` 는 전이 주체를, `TI-10` 은 감사를 정한다.
**`isolation_state = ISOLATED` 가 무엇을 막는가는 `TI-1`~`TI-12` 어디에도 없다.**
`010004` §7(`601901` 201~225행 채록)은 접근 허용 조건에
`no containment block` · `no suspension block` 을 요구한다 — 어느 `TI-N` 도 이를 쓰지 않는다.
`601904` §5.1 실측은 `isolation_state` 참조 함수 **0건**이다.
`601900` Readme §6 이 RLS · permission 을 `0-C` 로 두었으므로
「후속 나선이 다루기로 한 사항」으로 볼 여지가 있어 informational 로 둔다.

**I-5 — 「두 축이 서로 독립」의 출처 오기**

`601905` 87행은 출처를 `TI-2`(`TI-2-a` · `TI-2-b`)로 적는다.
`TI-2`(`601902` 70~100행)는 `tenant_status` 를 한 번도 언급하지 않는다.
`601903` 55~56행의 `TI-2-a`·`TI-2-b` 도 `tenant-wide isolation 상태값 집합` 과
`그 상태가 tenant 전체에만 적용된다는 경계` 일 뿐이다.
실제 근거는 `TI-12`(= `601702` §1.28)이며 같은 문서 101~127행이 별도 블록으로 그것을 인용한다.

**I-6 — `TI-12` 반영이 §0 · §0.1 · §9 에 이르지 않았다**

```text
601905 18행   601902 TI-1~TI-11 을 모델로 옮긴 것이며
601905 34행   601902  TI-1 ~ TI-11 · HD-0-A-2R-1 ~ 9 · OQ-1 ~ OQ-3
601905 399행  601902 | TI-1~TI-11 · HD-0-A-2R-1~9 — 모델의 유일한 선언 출처
```

§9 는 `000701` §46 근거 문서 목록이다.
`601905` §1 이 실제로 사용한 `TI-12` · `HD-0-A-2R-10` 이 목록에 없다.

**I-7 — §8 추적표 표 구조와 계수**

```text
601905 391행   | `TI-12` | §1 ⚠️ 계층 상태 분리 | 표현 |
601905 393행   11건 전건 기록. 미표현 2건(TI-1 · TI-11)은 사유를 적었다.
```

§8 은 2열 표인데 `TI-12` 행만 3열이다.
개정 이력(12행)이 「§8 추적표를 12건으로 갱신」이라 적었으나 마무리 문장은 11건으로 남았다.

**I-8 — `601902` §7 근거 목록 결손**

`601902` 382행 `TI-12` 근거 — `601702` §1.27 · §1.28 · **`601903` §5.3** · **`601905` 검토 의견**.
§7 근거 문서 목록(544~559행)에 `601903` 과 `601905` 가 없다.
`000701` §46 은 「참고한 모든 관련 문서를 빠짐없이 기록」을 요구한다.

**I-9 — 인용하지 않은 절이 근거 목록에 올라 있다**

`601902` 550행 — `010640` | §2 · §4 · §5 · §6 · §41 · §42.
§1 의 실제 인용은 `TI-7` → §4, `TI-8` → §2 · §5 · §42 다.
**§6 · §41 을 인용한 규칙이 없다.** §6 은 F-4 와 직접 연결된다.

**I-10 — `601905` §0.2 가 `601903` §3 판정과 어긋난다**

`601905` 43행은 Cursor 「자산 없음」에 `TI-2` · `TI-3` · `TI-4` · `TI-6` 를 넣는다.
`601903` §3 의 판정은 다음과 같다.

| 항목 | `601903` 판정 |
|---|---|
| `TI-2-a` | **기존 자산에 있다** |
| `TI-2-b` · `TI-3-c` · `TI-4-b~e` · `TI-6-a~b` · `TI-6-d` | **부분적으로 있다** |

「이 넷이 모델의 중심이다」(49행)라는 초점 결정이
잘못 요약된 전제 위에 놓여 있다. 결론(수렴 4건) 자체는 `601904` §6 과 대조하면 유지된다.

**I-11 — `Q-P13` 이 처분표에 없다**

`601901` §14 는 `Q-P1`~`Q-P13` 13건이다.
`601902` §3 처분표(417~427행)는 `Q-P1`~`Q-P12` 만 담는다.
`Q-P13` 의 실질 처분은 §6 `OQ-3` 에 있으므로 누락은 표에 한정된다.

**I-12 — `601903` §5 접점 4건 중 2건의 처리 사유가 없다**

| `601903` | 대상 | 처리 |
|---|---|---|
| §5.1 | `601702` §1.26 — 「모든 Store 는 Tenant scope 를 보유하고 검증해야 한다」 Invariant | **반영 · 미반영 사유 모두 없음** |
| §5.2 | `601702` §1.27 — Store 상태 3축 | `TI-12` 가 §1.27 을 인용해 반영 |
| §5.3 | `601702` §1.28 — 계층 상태 분리 | `TI-12` |
| §5.4 | `601702` §1.42 · §1.43 — 네 시스템 경계 · provider 귀속 | **사유 없음.** 실질은 `TI-7` 이 담았으나 `TI-7` 근거가 §1.43 을 인용하지 않는다 |

`TI-7`(`601902` 220~226행)은 「provider event 에서 `merchant_id` 를 사용할 때에는
tenant · store · legal entity · provider mapping 을 통해 내부 customer context 와 연결한다」로
`601702` §1.43 「연결은 tenant/store 단위로 귀속된다」와 같은 내용을 선언하면서
근거에 `601901` `Q-P4` · `010640` §4 · `000170` 만 든다.
**`TI-12` 를 낳은 지적(`601903` §5.3 — 주제가 같은데 상위 선언을 인용하지 않았다)과 같은 유형이다.**
§1.26 Invariant 는 `601902` §2 `S6-7`(여러 tenant identifier 사이 cross-tenant inconsistent relation 금지)이
부분적으로 흡수하고 있어 blocking 으로 올리지 않는다.

**I-13 — `601905` 자기 규약 위반**

59행 — 「물리 객체명은 `601904` §2 · §6 에 실측으로 남아 있다. 이 문서는 옮기지 않는다.」
70행 · 71행 — 다이어그램 노드명이 `tenant_status` · `isolation_state` 다.
두 이름은 `601901` §17.1 · `601904` §3.3 이 측정한 실제 컬럼명이다.

**I-14 — `601900` Readme 내부 불일치**

```text
601900  73행   1단계  TI-12 추가로 제한 재개방 후 재마감 (2026-09-04)
601900 204행   601902 | Active — 1단계 선언 11건(TI-1~TI-11) · HD-0-A-2R-1~9
```

§9 File List 가 §3 현재 위치와 어긋난다.

**I-15 — 1단계와 2단계의 상호 인용**

```text
601902 382행   TI-12 근거 — … 601905 검토 의견
601905 399행   601902 … 모델의 유일한 선언 출처
```

`000701` §47.1 은 1단계 → 2단계 순서를 정한다.
`HD-0-A-2R-10` 이 2026-09-04 Human 판정으로 기록돼 있어 절차상 Human 선언은 성립하나,
근거 방향이 순환한다.

## §5 `TI-N` 추적표

| `TI-N` | 원천 근거 | `601901` 채록 | `601905` 표현 | 완결 |
|---|---|---|---|---|
| `TI-1` | `600021` §2 5건 + `010630`·`010650`·`010660` A1' 승격 | §3.1' · §9.1~§9.3 원문 · §14 `Q-P6`·`Q-P12` | **미표현** — §8 · §6 표 · §7.3 `D-1` 에 사유 기재 | ✅ |
| `TI-2` | `010650` §2·§4(`TENANT`/`STORE`/`DEVICE`/`ROUTE`)·§18·§36 · `010630` §9 SCOPE_GATE | §9.2.2 §2·§4·§18·§36 · §9.1.2 §9 · §14 `Q-P10` | §1 전체 · §5 `Q-9` | ⚠️ **F-4** — `010640` §6 미처리 |
| `TI-3` | `010630` §6 상태값 · §18 · §28 · `010650` §35 | §9.1.2 §6·§18·§28 · §9.2.2 §35 · §14 `Q-P9` | §2 발동 note · §3 gate · §5 `Q-4` | ⚠️ **I-3** — 본문/⚠️ 상충이 §3 으로 전파 |
| `TI-4` | `010650` §35 release stronger authority · §38 anti-pattern · `010630` §18 | §9.2.2 §35·§38 · §14 `Q-P13`(2026-09-02 보강) | §2 해제 note · §5 `Q-1`·`Q-7` | ✅ |
| `TI-5` | `010650` §35 | §9.2.2 §35 | §2 비대칭 다이어그램 | ✅ |
| `TI-6` | `010660` §4·§5·§37 · `010630` §21 | §9.3.2 §4·§5·§37 · §9.1.2 §21 · §14 `Q-P11` | §4 전체 · §5 `Q-5`·`Q-6` | ✅ |
| `TI-7` | `010640` §4 `merchant_id` · `000170` §3·§4 | §6.2 §4 · §8.2 §3·§4 · §14 `Q-P4` | §5 `Q-10` 점선 | ⚠️ **I-12** — `601702` §1.43 미인용 |
| `TI-8` | `010640` §2 · §5 · §42 | §6.2 §2·§42 채록. **§5 표 미채록** · §14 `Q-P5` | §5 `Q-2`·`Q-3` | ⚠️ **I-2 · F-4** |
| `TI-9` | `010004` §20 | §5.2 §20 전문 | §5 `Q-8` → `Q-1` 화살표 · `Q-9` 점선 | ✅ |
| `TI-10` | `010004` §19 — 14항 | §5.2 §19 **전문 채록(`cross-scope attempt` 포함)** · 2237행 부재 실측 | §5 `Q-2` — 13항 | ⛔ **F-1** |
| `TI-11` | `010004` §24 11항 · §26 · §29 | §5.2 §24 11항 전문 | **미표현** — §8 · §6 표 · §7.2 `P-10` · §7.3 `D-1` 에 사유 기재 | ✅ |
| `TI-12` | `601702` §1.27 · §1.28 | §10.2 §1.27·§1.28 전문 · §3.2 관련 절 명시 | §1 ⚠️ 블록 | ⛔ **F-2** · ⚠️ I-6 · I-7 |

## §6 미표현 · 미반영 사유 검토

| 항목 | 문서가 든 사유 | 타당 |
|---|---|---|
| `601905` §8 `TI-1` 미표현 | 정책 채택 지위는 상태 · 책임 모델의 요소가 아니다. `601904` C1 「측정 불가」 | ✅ 타당 |
| `601905` §8 `TI-11` 미표현 | §24 11항 선언은 Stage 4 이후 Stage 7 승인 문서가 기록하는 게이트다 | ✅ 타당 — §6 표 · §7.2 `P-10` · §7.3 `D-1` 3중 기록 |
| `601905` §7.1 `P-1`~`P-3` 미정 유지 | 추정으로 채우지 않았다 | ✅ 타당 — §1 · §3 · §5 에서 방향선을 그리지 않은 처리와 일관 |
| `601905` §1 escalate 를 방향선으로 안 그림 | `TI-2` 가 자동 승격 없음을 선언했으므로 방향 전이로 그리면 어긋난다 | ✅ 타당 |
| `601905` §5 `Q-9`·`Q-10` 점선 · 연결선 없음 | `TI-2-f`·`P-4` / `TI-7-e`·`P-7` Stage 4 유보 | ✅ 타당 |
| `601905` §6 표를 관측으로만 둠 | 「간극을 채우는 방법을 적지 않는다」 — `601904` 와 일관 | ✅ 타당 |
| `601902` §3 `Q-P1`·`Q-P2`·`Q-P3`·`Q-P7` governance 이월 | 문서 provenance 문제이며 설계 결정이 아니다 | ✅ 타당 |
| `601902` §2 승계 안 함 5건(`S6-9`·`11`·`13`·`14`·`15`) | `601800` 설계 결과 / governance precedence / verification bookkeeping | ✅ 타당 |
| `601902` §1.1 A3 5건 유지 | 각 문서가 규율하는 지점에 설계가 실제로 닿으면 재개방 | ✅ 타당 |
| `601903` §5.2 · §5.3(`601702` §1.27·§1.28) | `TI-12` 로 반영 | ✅ 타당 |
| `601903` §5.1(`601702` §1.26 Invariant) 미반영 | **사유 기재 없음** | ⚠️ 부적절 — **I-12**. `S6-7` 이 부분 흡수 |
| `601903` §5.4(`601702` §1.42·§1.43) 미반영 | **사유 기재 없음** | ⚠️ 부적절 — **I-12**. `TI-7` 이 실질을 담되 인용 없음 |
| `600021` §1.1 `C-2` 후단(`010640` §6) | **사유 기재 없음. §3 은 처분됨으로 기록** | ⛔ 부적절 — **F-4** |
| `010004` §19 `cross-scope attempt if any` 누락 | **사유 기재 없음** | ⛔ 부적절 — **F-1** |
| `000221` §4.1 Human Gate A | **사유 기재 없음. 대역 전체 언급 0건** | ⛔ 부적절 — **F-3** |
| `010004` §7 `no containment block` 미사용 | **사유 기재 없음** | ⚠️ 부적절 — **I-4**. `0-C` 소관으로 볼 여지 있음 |
| `tenant_status` 를 모델에 안 그림 | 「`601902` 가 그 축을 선언하지 않았고 이 나선은 읽기만 한다」 | ⛔ 부적절 — **F-2**. `TI-12` 는 소유 축으로 선언했다 |

## §7 이 문서가 하지 않은 것

```text
처분 판정          하지 않았다. blocking / informational 분류까지만 한다
재설계 · 대안 제시  하지 않았다
601906 · 601907 이전 판본 · 601908 열람   0건
601801 · 601803 · 601809~601815 열람       0건
DB 접속            0건
파일 수정 · 삭제    0건. 이 파일 1개만 생성했다
git write          0건
```

## §8 근거 문서 목록 (`000701` §46)

| 문서 | 인용 | 지위 |
|---|---|---|
| `601902_Register_Stage1_Business_Rules.md` | 전문 — 검증 대상 | ACTIVE |
| `601905_Diagram_Tenant_Isolation_Axis_Model.md` | 전문 — 검증 대상 | ACTIVE — Draft |
| `601901_Register_Stage0_Evidence_Collection.md` | §3 · §5.2 · §6.2 · §9.1~§9.3 · §10.2 · §12 · §14 · §15 · §17~§20 | ACTIVE |
| `601903_Evidence_Stage2_ERD_Survey_Cursor.md` | §2 `TI-N-x` · §3 · §5 · §6 · §8 | ACTIVE |
| `601904_Evidence_Stage2_ERD_Survey_Codex.md` | §2 C1 · §3 · §5 · §6 C5 | ACTIVE |
| `601900_Readme_Tenant_Isolation_Axis_V2.md` | §1 · §2 · §3 · §4 · §5 · §6 · §7 · §9 · §10 | ACTIVE |
| `601702_Register_Stage1_Business_Rules.md` | §1.26 · §1.27 · §1.28 · §1.42 · §1.43 | ACTIVE |
| `600021_Governance_Tenant_Isolation_Axis_Authority_Reset.md` | §1 · §1.1 · §1.2 · §2 · §4 · §6 | ACTIVE |
| `600010_Tracker_Spiral_Workpacket_Progress.md` | §1 · §1.1 · §2 — Human Gate A 해소 경위 | ACTIVE |
| `000220_Guide_Shared_Commerce_Kernel_And_Foundation_Axis.md` | §2.1 · §3 Foundation 9축 · §4 — 충돌 미발견 | ACTIVE |
| `000221_Guide_Post_0A_Spiral_Sequence.md` | §3 나선 순서 · §3.2 권위보류 경계 · §4.1 · §6 등급 기준 · §9 | ACTIVE |
| `010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | §4 · §5 · §7 · §19 · §20 · §24 · §26 · §29 | ACTIVE — mandatory |
| `010640_Policy_Tenant_Scope_Envelope.md` | §2 · §4 · §5 · §6 · §36 · §41 · §42 | ACTIVE — mandatory |
| `010630_Policy_Authority_Capability_Gate.md` | §6 · §9 · §18 · §21 · §22 · §26 · §28 | ACTIVE — `TI-1` 채택 |
| `010650_Policy_Failure_Containment_Circuit_Breaker.md` | §2 · §4 · §16 · §18 · §35 · §36 · §38 | ACTIVE — `TI-1` 채택 |
| `010660_Policy_Idempotency_Retry_Replay_Reconciliation.md` | §4 · §5 · §37 · §44 | ACTIVE — `TI-1` 채택 |
| `000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | 원 정책 §3 · §7 · §22 · §23 — 충돌 미발견 | ACTIVE — mandatory |
| `000170_Policy_Merchant_Account_Company_And_Store_Context.md` | 원 정책 §3 · §4 · §7 — `TI-7` 대조 | ACTIVE — mandatory |
| `000190_Policy_Cross_Business_Franchise_OS_And_CatchMenu_Boundary.md` | 원 정책 §3 · §10 · §17 — 충돌 미발견 | ACTIVE — mandatory |
| `000701_Guide_Controlled_AI_Development_Pipeline.md` | §46 · §47.1 · §47.3 · §48 | ACTIVE |
| `000001_Md_Rules.md` | §1 · §2 · §5.4.9 Audit Rule | ACTIVE |
| `000002_Naming_Rules.md` | 파일명 규칙 | ACTIVE |
| `601906_Audit_Stage3_Adjacent_Domain_Codex.md` | — | **열지 않음** — 상호 참조 금지 |
| `601801` · `601803` · `601809`~`601815` | — | ⛔ **AUTHORITY SUSPENDED** — 열지 않음 |
| `601816` | `601901` §12.4 를 경유한 목록 확인만 | ⛔ **AUTHORITY SUSPENDED** — 처분 미승계 |

## §9 Final Rule

```text
Audit is an independent review.
Audit does not authorize implementation.
Audit does not replace Human release approval.

이 문서는 blocking 4건 · informational 15건을 기록한다.
처분은 Human 이 정한다.
```
