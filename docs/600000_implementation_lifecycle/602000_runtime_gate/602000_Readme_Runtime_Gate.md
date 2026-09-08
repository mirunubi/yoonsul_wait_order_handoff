# 602000_Readme_Runtime_Gate.md

Status: Active
Lifecycle: Readme
Last Updated: 2026-09-08

## §1 목적

`600023` 이 채택한 **Runtime Gate Spiral** 의 대역이다.

```text
공격 재현 → Human invariant → 최소 수정 → 동일 공격 재실행 → 회귀
```

**PASS 조건 둘** — `600023` §3.1

```text
1  §2 에서 성공한 동일 공격이 §6 에서 실패한다
2  §7 회귀 검증이 통과한다
```

> ⚠️ **한 `RG` 를 닫기 전 다음 `RG` 를 시작하지 않는다.**
>
> **닫혔다는 것은 문서가 완성됐다는 뜻이 아니다.**
> **공격이 실패하고 정상 경로가 살아 있고 회귀가 통과했다는 뜻이다.**

## §2 대역

```text
602000 ~ 602999
RG-N 은 602010 부터 10단위
```

## §3 현재 위치

```text
RG-01   Caller Tenant Scope
        migration   0172_caller_tenant_scope_gate.sql
                    2026-09-07 23:13 적용 · success
        evidence    602010
        판정        CONDITIONAL PASS (2026-09-08 재판정)

        T1 · T2 · T3   PASS
        T4             UNVERIFIABLE — RG-F1
        catalog delta  PASS
        governance     G11 · G12 예상 · G15 별건 — RG-F2
```

> ⚠️ **`0172` 가 evidence 작성 전에 적용됐다.**
> **`602010` §2 는 사후 재현이며 `601919` `T01` 이 1차 증거다.**

## §4 착수 순서 — `600023` §5

| # | 대상 | 근거 | 상태 |
|---|---|---|---|
| `RG-01` | Caller Tenant Scope | `C-01` | **CONDITIONAL PASS** |
| `RG-02` | Payment 승인 재호출 중복 원장 | `C-02` | 미착수 |
| `RG-03` | 무결제 KDS `COMMITTED` | `C-03` | 미착수 |
| `RG-04` | Lifecycle gate — `TERMINATED + ISOLATED` | `H-01` | 미착수 |
| `RG-05` | Order retry 중복 · 번호 범위 | `H-02` | 미착수 |
| `RG-06` | Ownership chain tenant 일치 | `H-03` | 미착수 |

## §5 이 대역이 발견한 것

| # | 내용 | 출처 | 처분 |
|---|---|---|---|
| `RG-F1` | `service_role` 이 13 / 15 스키마에 `USAGE` 가 없다. `manage_subscription` · `onboard_tenant` 의 `service_role` EXECUTE GRANT 가 도달 불가이며 `is_service_role()` 면제 분기가 죽은 코드다 | `602010` §9 | 미정 |
| `RG-F2` | 체커 `G15` 가 migration 마다 ChangeContract 를 요구하나 Runtime Gate 는 만들지 않는다 | `602010` §9 | `600023` §4 에 기록 · 처분 미정 |

> ⚠️ **`RG-F1` 은 `601919` 독립 감사가 기록하지 않았다.**
> **함수별 EXECUTE ACL 만 보고 schema `USAGE` 를 보지 않으면
> GRANT 가 도달 불가인 것이 안 보인다.**

## §6 Astra checkpoint

**독립 공격 감사자로만 쓴다. 문서 생성 · 코드 수정을 시키지 않는다.**

```text
①  RG-01 완료 후        caller tenant scope 를 깨뜨려봐라
②  RG-01 ~ RG-06 완료   foundation 전체 재감사
③  E2E 한 바퀴 후       tenant → 로그인 → 주문 → 결제 → KDS
④  Release 직전         production readiness
```

**호출 형식**

```text
invariant 는 Human 이 확정했다   — 602010 §3
공격 스크립트가 있다              — 602010 §1
migration 이 적용됐다             — 0172

현재 fix 가 invariant 를 보장하는지 깨뜨려라

코드 수정 금지 · 문서 생성 금지 · findings 만 보고
```

## §7 File List

| 번호 | 파일 | 상태 |
|---|---|---|
| 602000 | `602000_Readme_Runtime_Gate.md` | Active — 이 문서 |
| 602010 | `602010_Evidence_RuntimeGate_Caller_Tenant_Scope.md` | Active — `RG-01`. CONDITIONAL PASS |

**migration**

```text
0172_caller_tenant_scope_gate.sql   RG-01
```

## §8 근거 문서 목록 (`000701` §46)

| 문서 | 인용 | 지위 |
|---|---|---|
| `600023_Governance_Runtime_Gate_Spiral.md` | §3 · §4 · §5 | ACTIVE |
| `601919_Audit_Independent_Foundation_Audit.md` | `C-01`~`C-03` · `H-01`~`H-03` · `T01` | ACTIVE |
| `601920` · `601921` | 부속 증거 | ACTIVE |
| `601902_Register_Stage1_Business_Rules.md` | `TI-3` · `TI-14` — `RG-F1` 관련 | ACTIVE |
| `000701` | §46 | ACTIVE |
