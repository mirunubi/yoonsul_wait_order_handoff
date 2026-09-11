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
        migration   0172  2026-09-07 23:13 적용
                    0173  2026-09-08 16:38 적용
        evidence    602010
        판정        PASS (2026-09-08 재실행)

        T1 · T2 · T3 · T5 · T5b   전건 PASS
        T5 가 primary exploit closure — claim 조작 우회 차단
        catalog delta 6항 전건 예상 일치
        governance   G15 만 — RG-F2
```

```text
RG-02   Payment Approval Integrity
        migration   0174  2026-09-08 적용
                    0176  2026-09-08 11:11 적용 — 재개방
        evidence    602020
        판정        PASS

        1차 0174   confirm_payment_from_provider
                   T1 ~ T8 전건 PASS
        재개방 0176 600023 §3.5 — invariant 가 경로 무관 진술이다
                   APPROVAL writer 4개 중 1개만 고쳐져 있었다
                   confirm_payment 가 caller JSON 으로
                   raw event 를 스스로 만들어 그것을 근거로 삼았다
                   T1 ~ T6 PASS · T7 UNVERIFIABLE

        APPROVAL writer 4
          binding 적용 2 · 범위 밖 1 — RG-F7
          미검증 1 — RG-F8
```

```text
RG-03   KDS Payment Precondition
        migration   0175  2026-09-08 10:15 적용
        evidence    602030
        판정        PASS

        §4.1 전수 실측이 COMMITTED writer 를 4개로 확대했다
        지시서 범위는 2개였다 — 600023 §3.5 의 근거
        T1 ~ T9 전건 PASS
        회귀에서 미검증 COMMITTED 경로 0건 확인
```

```text
RG-04   Tenant Lifecycle Order Gate
        migration   0177  2026-09-09 적용
        evidence    602040
        판정        PASS

        orders writer 8개 전부가 lifecycle 두 축을 읽지 않았다
          tenant_status read 0 / 8
          isolation_state read 0 / 8
          assert_caller_tenant_scope 0 / 8

        서버가 두 축을 직접 조회해 판정한다
        ACTIVE · TRIAL 만 허용하고 나머지는 거부한다
        ISOLATED 는 tenant_status 와 무관하게 거부한다

        T1 ~ T9 전건 PASS
        T1 · T2 가 primary exploit closure
        회귀에서 미검증 orders 경로 0건 확인
```

> ⚠️ **`601902` 가 `CONTRACT FROZEN` 으로 enforcement 를 `0-C` 로 이월했다.**
> **`RG-04` 가 그 이월분의 일부를 처음 강제한다.**
>
> ```text
> TI-13   ISOLATED 이면 containment block · 접근 거부
> TI-2 · TI-12   두 축은 독립이며 각각 거부 사유가 된다
> ```
>
> **`600023` §3.4 가 기존 선언 인용을 허용한 첫 사례다.**

> ⚠️ **허용을 열거하고 나머지를 거부했다.**
> **거부를 열거하면 CHECK 에 새 값이 생길 때 열린 채로 남는다.**
> **`010004` §7 deny-by-default 와 같은 구조다.**

> ⚠️ **`CANCELLED` 거부는 유예 기간 모델이 없기 때문이다.**
> **`601902` `TI-14` 가 과금 모델 부재를 선언했다.**
> **유예 기간이 정의되면 이 gate 를 재개방한다.**

```text
RG-05   Order Request Identity
        migration   0178  2026-09-11 적용
        evidence    602050
        판정        PASS

        retry 와 추가 주문을 구분하는 request identity 가 없었다
        번호는 COUNT(*)+1 이었고 UNIQUE 에 날짜가 없었다

        caller 가 stable request_id 를 넘기고 서버가 canonical key 를 파생한다
        payload_hash 는 key 성분이 아니라 대응 보존값이다
        allocator 가 store × business_day 로 번호를 배정한다

        T1 ~ T10 명시 조건 전건 PASS
        T4 · T5 가 primary exploit closure
          동시 동일 request → 주문 1건 · 양쪽 같은 결과
          동시 다른 request → 0002 · 0003 · 충돌 없음

        signature 변경 13 — writer 7 · wrapper 6
        내부 갱신 1 — run_integration_test
        migration 본문 ↔ live prosrc 14/14 exact match
```

> ⚠️ **`601919` 가 미실행한 동시 두 연결을 이 gate 가 재현하고 닫았다.**

> ⚠️ **`T8` 1/7 · `T9` 0/6 만 runtime 완결됐다.**
> **기존 live schema drift 때문이며 `RG-F12` ~ `RG-F14` 로 기록했다.**
> **명시된 FAIL 조건에는 해당하지 않으나
> 「전 경로 runtime 검증 완결」로 표현하지 않는다.**

> ⚠️ **`601902` `TI-6` 을 주문에 적용한 것이다** — `600023` §3.4.
> **`payload_hash` 를 key 에 넣으면 retry 중 items 가 바뀔 때
> 새 주문이 되어 `010660` §6 이 막으려는 사건이 통과한다.**

> ⚠️ **`RG-01` 은 두 번 돌았다.**
>
> ```text
> 1차   0172 — gate 를 만들었다
>       그 gate 의 service_role 면제가 claim 기반이었다
>       CONDITIONAL PASS 로 판정했다가 FAIL 로 재판정
>
> 2차   0173 — 면제를 제거했다
>       T5 가 그 우회를 재현하고 차단을 증명했다
> ```
>
> **재현으로 잡혔고 재현으로 닫혔다.**
## §4 착수 순서 — `600023` §5

| # | 대상 | 근거 | 상태 |
|---|---|---|---|
| `RG-01` | Caller Tenant Scope | `C-01` | **PASS** |
| `RG-02` | Payment 승인 재호출 중복 원장 | `C-02` | **PASS** |
| `RG-03` | 무결제 KDS `COMMITTED` | `C-03` | **PASS** |
| `RG-04` | Lifecycle gate — `TERMINATED + ISOLATED` | `H-01` | **PASS** |
| `RG-05` | Order retry 중복 · 번호 범위 | `H-02` | **PASS** |
| `RG-06` | Ownership chain tenant 일치 | `H-03` | 미착수 |

## §5 이 대역이 발견한 것

| # | 내용 | 출처 | 처분 |
|---|---|---|---|
| `RG-F1` | `service_role` 이 13 / 15 스키마에 `USAGE` 가 없다. `manage_subscription` · `onboard_tenant` 의 `service_role` EXECUTE GRANT 가 도달 불가이며 `is_service_role()` 면제 분기가 죽은 코드다 | `602010` §9 | 미정 |
| `RG-F2` | 체커 `G15` 가 migration 마다 ChangeContract 를 요구하나 Runtime Gate 는 만들지 않는다 | `602010` §9 | `600023` §4 기록 · 처분 미정 |
| `RG-F3` | `is_service_role()` 이 caller 조작 가능한 claim 만 검사해 gate 를 우회했다. `authenticated` 가 `claims.role='service_role'` 을 세팅하면 tenant 대조를 면제받았다 | `602010` §10.1 | **해소 — `0173`** |
| `RG-F4` | 같은 claim 기반 판정을 쓰는 RLS policy 3건. 현재 테이블 GRANT 가 없어 도달 불가 | `602010` §11 | 조건부 · 감시 |
| `RG-F5` | `verify_toss_signature` 가 HMAC 을 계산하지 않고 header 형식만 검사한다. `t=1,v1=` + 임의 32자로 통과한다. 함수 주석이 스스로 「actual HMAC in app layer」라 적으나 그 계층의 존재가 확인되지 않았다. `RG-02` 의 구조적 binding 이 이것을 막지 못한다 | `602020` §11 | 후속 `RG` |
| `RG-F6` | `SECURITY DEFINER` 105개가 `PUBLIC EXECUTE` 다. `601503` §9 가 「0건이어야 함」으로 게이트를 걸었고 `601505` §4 호출 금지 7함수 중 6개가 포함된다. 현재 `anon` 에 schema `USAGE` 가 없어 실질 증가는 없다 | 실측 2026-09-08 | 조건부 · 감시 |
| `RG-F7` | 수기 결제 승인의 근거가 정의되지 않았다. `flush_offline_queue` 가 `RECORD_MANUAL_PAYMENT` 로 `APPROVAL` 을 만들며 provider 검증이 없고 있을 수도 없다. staff 신원 · store 정책 · 금액 한도가 미정이다 | `602020` §12.5 | 별도 gate |
| `RG-F8` | `record_van_transaction` 이 `APPROVAL` writer 인데 `601505` §4 호출 금지라 검증할 수 없다. `PUBLIC EXECUTE` 이며 caller VAN payload 로 raw event 를 직접 생성한다 | `602020` §12.5 | 호출 금지 해제 선행 |
| `RG-F9` | `flush_offline_queue` 가 `business_day` 를 caller payload 에서 받는다. caller 가 주문 번호 범위를 고를 수 있다 | `602050` §11 | 별도 gate |
| `RG-F10` | 4 writer 가 live `orders` 에 없는 `order_source` · `local_temp_id` 를 참조한다 | `602050` §11 | 별도 확인 |
| `RG-F11` | `run_integration_test` 가 기존 non-writer overload 와 signature 가 겹쳐 `0178` public signature 변경에서 제외됐다. 내부 호출은 contract 를 준수하나 `idempotency_keys` 를 쓰지 않아 retry 중복 방지가 없다. `PUBLIC EXECUTE` 이며 실제 `orders` INSERT 를 한다 | `602050` §11 | `RG-F6` 와 함께 처분 |
| `RG-F12` | 추가 live schema drift — `T8` 1/7 만 runtime 완결된 원인 | `602050` §11 | 별도 확인 |
| `RG-F13` | provider intake digest resolution — `T9` 0/6 원인의 일부 | `602050` §11 | 별도 확인 |
| `RG-F14` | kiosk wrapper actor · check mismatch | `602050` §11 | 별도 확인 |

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

### §6.1 Runtime Gate 구간 도구 배치 — 2026-09-08

```text
Codex    실행 · SQL · 카탈로그 전수 실측      주력
Claude   문서 · 형식 · 통합 · 원문 보존        보조
Astra    독립 공격 감사                       checkpoint 4회

Cursor   대기
Cowork   대기
```

> ⚠️ **`Cursor` 는 `000701` §47.1 이 2단계 조사 actor 로 지정한 도구다.**
> **문서 나선을 중단했으므로 그 역할이 없다.**
>
> ```text
> 개념 축 조사   Runtime Gate 의 §4.1 실측이 대체한다
> 문서 대 문서   Codex 가 카탈로그 전수로 한다
> ```
>
> **품질 문제가 아니라 역할 소멸이다.**
> **`601903` · `601706` · `601708` · `601211` 이 그 산출물이며 유효하다.**

> ⚠️ **문서 나선으로 돌아가면 다시 배정한다.**
>
> ```text
> 0-B · 0-C 설계
> Phase 2 Kernel
> frontend
> ```

**`Cowork` 은 장치 연결이 불안정해 대기한다** — `601911` §0 이 세션 미분리를 자진 신고했다.

## §7 File List

| 번호 | 파일 | 상태 |
|---|---|---|
| 602000 | `602000_Readme_Runtime_Gate.md` | Active — 이 문서 |
| 602010 | `602010_Evidence_RuntimeGate_Caller_Tenant_Scope.md` | Active — `RG-01`. PASS (2026-09-08 재실행) |
| 602020 | `602020_Evidence_RuntimeGate_Payment_Approval_Integrity.md` | Active — `RG-02`. PASS |
| 602030 | `602030_Evidence_RuntimeGate_KDS_Payment_Precondition.md` | Active — `RG-03`. PASS |
| 602040 | `602040_Evidence_RuntimeGate_Tenant_Lifecycle_Order_Gate.md` | Active — `RG-04`. PASS |
| 602050 | `602050_Evidence_RuntimeGate_Order_Request_Identity.md` | Active — `RG-05`. PASS |

**migration**

```text
0172_caller_tenant_scope_gate.sql                        RG-01 1차
0173_caller_tenant_scope_remove_claim_exemption.sql      RG-01 2차
0174_payment_approval_integrity.sql                      RG-02 1차
0175_kds_payment_precondition.sql                        RG-03
0176_payment_approval_binding_all_paths.sql              RG-02 재개방
0177_tenant_lifecycle_order_gate.sql                     RG-04
0178_order_request_identity_and_numbering.sql            RG-05
```

## §8 근거 문서 목록 (`000701` §46)

| 문서 | 인용 | 지위 |
|---|---|---|
| `600023_Governance_Runtime_Gate_Spiral.md` | §3 · §4 · §5 | ACTIVE |
| `601919_Audit_Independent_Foundation_Audit.md` | `C-01`~`C-03` · `H-01`~`H-03` · `T01` | ACTIVE |
| `601920` · `601921` | 부속 증거 | ACTIVE |
| `601902_Register_Stage1_Business_Rules.md` | `TI-3` · `TI-14` — `RG-F1` 관련 | ACTIVE |
| `000701` | §46 | ACTIVE |
