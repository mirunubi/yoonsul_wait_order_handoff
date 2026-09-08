# 600023_Governance_Runtime_Gate_Spiral.md

Status: Active
Lifecycle: Governance
Last Updated: 2026-09-08

## §0 목적

**runtime 으로 재현 가능한 결함에 대해 문서 나선을 돌지 않는다.**

**`000701` §47 파이프라인을 대체하지 않는다. 대상을 나눈다.**

## §1 판정 (2026-09-08, Human)

### §1.1 실측

**문서 나선의 산출**

| 나선 | 기간 | 산출 | 결과 |
|---|---|---|---|
| `0-A` | 08-13 ~ 08-24 · 12일 | 테이블 1 · 개명 1 · migration 2 | 완주. Stage 6 에서 5라운드 |
| `0-A-2` 1차 | 08-27 ~ 08-31 · 5일 | 문서 16 · SQL 0줄 | 권위보류 — `600021` |
| `0-A-2` 재수행 | 09-01 ~ 09-08 · 8일 | 문서 21 · SQL 0줄 | 계약 동결 — `HD-0-A-2R-14` |

**3단계 검증 라운드**

```text
Round 1   blocking 8
Round 2   blocking 8
Round 3   blocking 10

Round 3 미처분 8건 중 4건이 Round 2 처분의 불완전이었다 — 601918 §3
```

**독립 감사 — `601919`, 2026-09-08**

```text
하루
CRITICAL 3 · HIGH 3
전부 runtime 재현
```

### §1.2 원인

**반증 조건이 없는 대상을 검증했다.**

```text
문서 대 문서
  불일치가 무한히 나온다
  고쳐도 새 불일치가 생긴다
  PASS 조건이 「더 이상 못 찾겠다」다

runtime
  PASS 조건이 「같은 공격이 실패한다」다
  반증 가능하고 유한하다
```

> ⚠️ **`0-A` 도 같은 문제였고 5단계에서 SQL 이 나와 끝났다.**
> **`0-A-2` 는 SQL 에 도달하기 전에 3단계를 세 번 돌았다.**

## §2 대상 구분

**둘을 섞지 않는다.**

| 성격 | 절차 |
|---|---|
| runtime 재현 가능한 결함 | **Runtime Gate** — §3 |
| runtime 재현 불가능한 결정 | `000701` §47 기존 파이프라인 |

**기존 파이프라인이 다루는 것**

```text
정책 · 경계 · 어휘
상태 축의 의미
소관 분할
원천 정책의 채택
```

**Runtime Gate 가 다루는 것**

```text
공격이 성공한다
같은 입력이 두 번 실행된다
제약이 강제되지 않는다
함수가 실행 실패한다
```

> ⚠️ **`TI-13` 의 「`ISOLATED` 면 거부」는 정책이다. 문서로 정한다.**
> **「`TERMINATED + ISOLATED` 에서 주문이 된다」는 결함이다. runtime 으로 닫는다.**

## §3 Runtime Gate 형식

**`RG-N` 하나가 파일 하나다.**

```text
§1  공격                  .sql — BEGIN / ROLLBACK
§2  재현 로그              현재 상태에서 성공한다
§3  invariant             무엇이 참이어야 하는가. Human 이 정한다
§4  근거                  원천 문서 절 1개
§5  migration             수정
§6  재실행 로그            같은 공격이 실패한다
§7  회귀                  기존 테스트 통과
```

### §3.1 PASS 조건

```text
§2 의 공격이 §6 에서 실패한다
§7 이 통과한다
```

**그것뿐이다. 검증자 3주체를 돌리지 않는다.**

### §3.2 Human 이 반드시 하는 것

```text
§3 invariant
```

> ⚠️ **`invariant` 를 AI 가 만들면 현재 구현을 정당화하는 것이 나온다.**
> **`601702` §1.27 이 그것을 금지했다 —
> 현재 DB default 를 설계 근거로 승격하지 않는다.**

### §3.3 원천 근거는 절 하나면 된다

```text
§4 는 전문 채록이 아니다
원천 문서의 절 하나를 인용한다
```

> ⚠️ **`601800` 이 `010004` 를 한 번도 인용하지 않아 권위보류됐다** — `600021`.
> **그 재발은 막되 채록 나선을 다시 돌지는 않는다.**

### §3.4 기존 선언을 invariant 로 인용할 수 있다

**정책이 `invariant` 를 정하고 Runtime Gate 가 그것을 닫는 것이 정상 경로다.**

```text
000701 §47 파이프라인   무엇이 옳은가를 정한다
Runtime Gate           그것이 강제되는지 닫는다
```

**`§3` `invariant` 는 새로 만들 수도 있고 기존 선언을 인용할 수도 있다.**

```text
새로 만든다   기존 선언이 그 결함을 다루지 않을 때
             Human 이 정한다 — §3.2

인용한다      기존 선언이 이미 정했을 때
             출처를 적는다. 다시 정하지 않는다
```

> ⚠️ **`RG-04` 가 그 사례다.**
> **`TI-1` ~ `TI-15` 가 `TERMINATED + ISOLATED` 의 invariant 를 이미 정했고,**
> **`RG-04` 는 그것을 인용해 gate 를 닫는다.**

> ⚠️ **인용하는 경우에도 `§4` 원천 근거는 별도로 적는다.**
> **선언의 근거와 gate 의 근거가 같지 않을 수 있다.**

### §3.5 결과로 진술된 invariant 는 경로를 전수 열거한다

**`invariant` 가 결과로 진술되면 그 결과에 도달하는 모든 경로를 찾는다.**

```text
「X 는 Y 없이 도달하지 않는다」는 경로 무관 진술이다
한 함수만 고치고 PASS 를 선언하면
invariant 가 거짓인 채로 gate 가 닫힌다
```

**`§4.1` 실측에 아래를 포함한다.**

```text
그 결과를 기록 · 변경하는 객체 전수

카탈로그 전수 대조다
지정 목록 검사가 아니다
```

> ⚠️ **`RG-03` 이 이것을 실증했다.**
>
> ```text
> 지시서 범위        commit_kds_ticket · bulk_commit_kds_tickets
> §4.1 전수 실측     release_kds_after_payment · accept_delivery_order 추가 발견
>
> 넷 중 둘만 고쳤으면
> 「COMMITTED 는 결제 승인 없이 도달하지 않는다」가
> 거짓인 채로 PASS 였다
> ```
>
> **그중 하나는 존재하지 않는 ledger id 로도 통과했다** —
> `RG-02` 가 닫은 것과 같은 형태였다.

> ⚠️ **`§7` 회귀에 「미검증 경로 0건」을 포함한다.**
> **수정한 경로만 확인하고 끝내지 않는다.**

**`601918` §3 이 문서 나선에서 같은 패턴을 지적했다.**

```text
한 finding 을 고칠 때
같은 형태가 다른 곳에 있는지 보지 않았다
```

**Runtime Gate 에서 그것이 재발하지 않도록 이 절을 둔다.**

## §4 이 판정이 바꾸지 않는 것

```text
000701 §47 파이프라인        유지. 대상이 다를 뿐이다
000001 인코딩 · 명명 규칙     유지
삼중 색인                    유지
Human 이 invariant 를 정한다  유지
원천 근거 인용                유지
```

**`601505` §4 호출 금지 조항은 계속 유효하다.**

> ⚠️ **체커 규칙과의 충돌 1건 — `602010` `RG-F2`**
>
> ```text
> 체커 G15       migration 마다 ChangeContract 문서를 요구한다
> Runtime Gate   ChangeContract 를 만들지 않는다
>                RG 문서 1개가 그 역할을 겸한다
> ```
>
> **`600023` 채택 시 이 충돌을 확인하지 않았다.**
> **`RG-01` 이 실행되면서 드러났다.**
>
> **처분 — 미정**
>
> ```text
> A  체커 G15 에 Runtime Gate 예외를 넣는다
>    tools/ 수정. 별건 워크패킷
>
> B  RG 문서를 ChangeContract 로도 인정하게 한다
>    DocumentType 을 ChangeContract 로 바꾸거나
>    체커가 RG 문서를 찾도록 한다
>
> C  Runtime Gate 가 ChangeContract 를 함께 만든다
>    600023 §3 형식이 바뀐다
> ```
>
> **그때까지 `RG` migration 은 `G15` WARN 을 낸다.**
> **그 WARN 은 예상 finding 이며 gate FAIL 사유가 아니다.**

## §5 착수 순서

**`601919` 감사가 정한 Top 5 blocker 를 따른다.**

| # | 대상 | 근거 |
|---|---|---|
| `RG-01` | Caller Authority — 업무 RPC 경계 | `C-01` |
| `RG-02` | Payment 승인 재호출 중복 원장 | `C-02` |
| `RG-03` | 무결제 KDS `COMMITTED` | `C-03` |
| `RG-04` | Lifecycle gate — `TERMINATED + ISOLATED` 주문 | `H-01` |
| `RG-05` | Order retry 중복 · 번호 범위 | `H-02` |
| `RG-06` | Ownership chain tenant 일치 | `H-03` |

> ⚠️ **`RG-01` 이 나머지의 전제다.**
> **caller 를 모르면 다른 gate 가 무엇을 거부할지 정할 수 없다.**

> ⚠️ **`RG-04` 가 `0-A-2` 가 하려던 것이다.**
> **`TI-1` ~ `TI-15` 가 그 invariant 를 이미 정했다** — `601902`.

## §6 대역

```text
602000 ~ 602999   Runtime Gate
```

**`RG-N` 은 `602010` 부터 10단위로 배정한다.**

## §7 이 판정의 해제 조건

**해제하지 않는다.**

```text
Runtime Gate 가 기존 파이프라인을 대체하지 않는다
둘은 대상이 다르며 함께 쓴다
```

## §8 근거 문서 목록 (`000701` §46)

| 문서 | 인용 | 지위 |
|---|---|---|
| `601919_Audit_Independent_Foundation_Audit.md` | 전문 — `C-01`~`C-03` · `H-01`~`H-03` · Top 5 | ACTIVE |
| `601920` · `601921` | 부속 증거 | ACTIVE |
| `601902_Register_Stage1_Business_Rules.md` | `TI-1`~`TI-15` · `HD-0-A-2R-14` · §8 | ACTIVE |
| `601918_Report_Stage3_Round3_Integration.md` | §1 · §3 — 라운드 수치 | ACTIVE |
| `600021_Governance_Tenant_Isolation_Axis_Authority_Reset.md` | §1 — `601800` 권위보류 | ACTIVE |
| `601702_Register_Stage1_Business_Rules.md` | §1.27 | ACTIVE |
| `601200_Readme_Caller_Authorization_Foundation.md` | §1 — `0-C` 소관 | ACTIVE |
| `000701_Guide_Controlled_AI_Development_Pipeline.md` | §46 · §47 | ACTIVE |

## §9 판정

```text
Runtime Gate Spiral 채택 (2026-09-08)

runtime 재현 가능한 결함은 Runtime Gate 로 닫는다
그 밖의 결정은 000701 §47 을 따른다

착수   RG-01 Caller Authority
```

**판정자** — 정영석, 2026-09-08
