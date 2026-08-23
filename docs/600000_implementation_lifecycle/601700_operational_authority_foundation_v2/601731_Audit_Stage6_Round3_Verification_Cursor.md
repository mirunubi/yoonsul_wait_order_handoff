# 601731_Audit_Stage6_Round3_Verification_Cursor.md

> ⚠️ **Stage 6 Round 3 Contract Verification · Eyes-Only**
>
> `000701` §38.4 에 따라 두 검증자에게 **다른 검증 방법**을 배정했다.
>
> ```text
> Verifier A (Cursor)   경계 · 범위 · handoff · blocker lifecycle
> Verifier B (Codex)    계약 ↔ TestPlan 실행 가능성 line-by-line 대조
> ```
>
> 이번 라운드부터 **finding acceptance rule** 이 적용되었다 —
> blocking 은 "Stage 8 에서 다른 코드를 만들 수 있는가"를 기준으로 한다.
>
> 수행: Cursor, 2026-08-23.

**Scope:** `601716` TestPlan 11판 · `601717` ChangeContract 11판  
**Perspective:** A1–A7 — 구조·경계·lifecycle·handoff  
**Date:** 2026-08-23  
**Authority read:** `601710` §2·§3 · `601717` §1·§4.4.3·§6·§7·§9·§10 · `601716` §2·§5.9·§12·§13  
**Not read:** Codex/other verifier result files · `601716`/`601717` 미수정

---

## 종합

| 항목 | 발견 | blocking | informational |
|---|---:|---:|---:|
| A1 허용 파일 경계 | 0 | 0 | 0 |
| A2 Scope 침범 | 0 | 0 | 0 |
| A3 Handoff lifecycle | 2 | 0 | 2 |
| A4 Blocker lifecycle | 0 | 0 | 0 |
| A5 Stage 게이트 | 0 | 0 | 0 |
| A6 두 문서 간 경계 일치 | 0 | 0 | 0 |
| A7 R2-F1~F5 범위 완결성 | 2 | 0 | 2 |
| **합계** | **4** | **0** | **4** |

**Blocking 종합: NO CONCERNS FOUND**

---

## A1. 허용 파일 경계

| 검사 | 결과 | 근거 |
|---|---|---|
| `601717` §1.1 이 `601710` §3 Out of Scope 를 침범하지 않는가 | **PASS** | §1.1 은 `0170`/`0171` migration 2건만 허용 (`601717` §1.1 L242–249). `601710` §3 의 RPC 재작성·Store 3축·0-B/0-C·External Provider 물리 구현은 §6 FO-A~FO-40·§14 및 `601716` §14 로 금지·이월 |
| 허용 목록이 필요 범위보다 넓지 않은가 | **PASS** | Stage 8 SQL 은 A-1·A-2 전부 (`601717` §1.1 L249). Stage 10 문서 동기화는 §1.2 A-3~A-6 로 분리·기계적 범위 고정 |
| 허용 목록이 필요 범위보다 좁지 않은가 | **PASS** | Person rename(D-1~D-13) + MerchantAccount foundation(D-14~D-21) + backfill(M-1·M-2) 이 `601710` §2 Implementation Target 과 일치 |

---

## A2. Scope 침범

| 검사 | 결과 | 근거 |
|---|---|---|
| 0-B / 0-C 가 이번 계약 구현에 들어오지 않았는가 | **PASS** | FO-33 · `601716` §14 L955–957 · `601717` §9.2 L1130–1131 |
| 후속 RPC alignment 가 이번 나선에 끌려 들어오지 않았는가 | **PASS** | FO-A · FO-B · FO-B1 · FO-C · FO-D · `601717` §4.4.2 · `601716` §14 L958 |
| 이번 나선 책임(H-1~H-5 prerequisite·C-1/C-2 deferral)이 후속으로 밀리지 않았는가 | **PASS** | §4.4.3 H-1~H-5 · §1.5 C-1/C-2 · AC-10(`601717` §9.4 L1186) · AC-12(`601716` §13 L937) · §12.4 양쪽 |

---

## A3. Handoff lifecycle

| 검사 | 결과 | 근거 |
|---|---|---|
| H-1~H-5 가 후속 나선을 닫는가 | **PASS** | `601717` §4.4.3 L702–707 · `601716` §12.4 L831–838 |
| H-3a 선행이 명시되어 순서 오류를 막는가 | **PASS** | §4.4.3 L705 · AC-10 · AC-12 (R2-F5) |
| H-1 prerequisite (N-6″·N-8″) 가 권위 절에 닫혀 있는가 | **PASS** | `601717` §4.4.3 Prerequisite L712–726 · §7.3 N-6″ L951 · N-8″ L953 |
| H-4 (NOT NULL 재판정) 가 H-1~H-3 이후임이 명시되는가 | **PASS** | §4.4.3 H-4 L707 |

---

## A4. Blocker lifecycle

| Blocker | 소관 | 구현자 자율 정책 필요? | 근거 |
|---|---|---|---|
| C-1 · C-2 | `DEFERRED — INELIGIBLE` · 후속 RPC alignment | **아니오** | §1.5 · §12.4 · §10.1 항목 2 |
| N-1″ | H-1 이월 · FAIL 아님 | **아니오** | §7.3 L947 · AC-14(`601716` §13 L938) |
| N-4″ · N-6″ · N-7″ · N-8″ | 후속 RPC alignment · FO-A/D | **아니오** | §7.3 · FO-A · FO-D |
| N-5″ | 측정 범위 밖 · FO-D | **아니오** | §7.3 L950 · `601716` §12.3 L797 |
| B-9 | DEFERRED Documentation Reconciliation | **아니오** | §7.3 L939 · §10.2 |

---

## A5. Stage 게이트

| 검사 | 결과 | 근거 |
|---|---|---|
| §10 무효화 배너 ↔ Stage 8 금지 | **PASS** | `601717` §10 L1195–1204 · L1251 · §9.3 L1140 |
| §9.3 구현자 지시 ↔ 배너 모순 없음 | **PASS** | §9.3 「Stage 7 미승인 … Stage 8 을 착수하지 않는다」(L1140). G-2 처분(`601717` §0.3 L218) |
| `601716` PRE-1 착수 게이트 ↔ 배너 | **PASS** | `601716` §2 PRE-1 L254 — 「대기」·착수 금지 |
| Stage 6 Round 3 상태 표기 | **PASS** | `601717` §10 L1249 「Round 3 대기 — R2-F1~F5 반영 완료」 · `601716` 개정 이력 L24 「Round 3 재검증 필요」 |
| §12.4 「Stage 7 APPROVED」 ↔ PRE-1 「대기」 | **의도적 병기 (non-issue)** | `601716` §12.5·§12.6 항목 3 · `601717` §7.5·§7.6 — pre-decision 보존 vs 효력 부재 구분 |

---

## A6. 두 문서 간 경계 일치

| 대상 | 일치 | 근거 |
|---|---|---|
| 허용 SQL 파일 | **일치** | `601717` §1.1 A-1·A-2 ↔ `601716` TP-B-08 L657 |
| 허용 DDL D-15 형태 | **일치** | D-15 L301 · §1.6 L343 · §4.2 #1 L526 ↔ TP-P-29 L395 |
| COMMENT literal | **일치** | §4.2.1 L532–545 ↔ TP-P-23 L379 · TP-P-38 L404 |
| 기준선 PRE-5~7 | **일치** | `601716` §2 L100–103 ↔ `601717` §8.1 V-4·V-5 L1070–1071 |
| RPC 무변경 | **일치** | FO-A/B/D · §6.1 ↔ TP-N-50~53 · AC-6 · V-13 |
| H-3a · TP-D-09 AC | **일치** | AC-10(`601717` §9.4 L1186) ↔ AC-4·AC-12(`601716` §13 L929·L937) — R2-F5 |

---

## A7. Round 2 수정 (R2-F1~F5) 범위 완결성

| R2-F | 처분 | 잔존 여부 | 근거 |
|---|---|---|---|
| **R2-F1** | `CREATE UNIQUE INDEX` 제거 · `ADD CONSTRAINT … UNIQUE` 통일 | **잔존 없음** | §1.6 L343–347 `CREATE INDEX` 만(非 UNIQUE). D-15 L301 · §4.2 #1 L526. `CREATE UNIQUE INDEX` 문자열은 제외 설명·처분 기록에만 존재 |
| **R2-F2** | §4.2.1 exact literal | **잔존 없음** | §4.2.1 L532–552 · D-13 L284 · D-21 L307 · S-13 L1169 |
| **R2-F3** | TP-N-63 정적 증거 | **잔존 없음** | `601716` §5.9 TP-N-63 L572 · 폐기 정의 보존 L573 |
| **R2-F4** | H-1 prerequisite 에 N-8″ 연결 | **권위 절 완료 · 요약 잔존** | §4.4.3 L716–726 완료. **잔존:** §9.2 L1132 는 N-6″ 만 열거 — 아래 Findings #3 |
| **R2-F5** | AC TP-D-09 · H-3a | **잔존 없음** | `601716` AC-4 L929 · AC-12 L937 · `601717` AC-10 L1186 |

---

## Findings

| # | 유형 | 지점 | 내용 | blocking | acceptance rule 근거 |
|---|---|---|---|---|---|
| 1 | document conflict (stale summary) | `601716` §0.1 L112–114 · `601717` §0.1.2 L127–129 · `601717` §4.4.1 L579 | `provision_tenant` 를 「phantom 없음 · **정상**」으로 표기. §4.4.1.2(L618–675) · N-6″(`601717` §7.3 L951 · `601716` §12.3 L798) · §5.9(L565–584) 와 **사실모델 불일치** — 함수는 tenants phantom 3건으로 실행 불가 | **no** | Stage 8 허용 구현(RPC 무변경·md5 불변)은 TP-N-62~64·TP-N-50 과 **일치**; stale 표기는 TestPlan FAIL 을 유발하지 않음. rule 1 해당 없음 |
| 2 | document conflict (historical §) | `601717` §4.4.1.1 L596–608 | 「`provision_tenant` 호출 가능」 서술이 §4.4.1.2 L673–674 에서 **철회 대상**으로 명시됐으나 본문은 역사 기록으로 잔존. 인접 §4.4.1 표 L579 도 「정상」 유지 | **no** | 철회·새 사유가 §4.4.1.2·§7.3 N-6″ 에 권위 있게 기록. Stage 8 구현 분기를 바꾸지 않음 — rule 3 해당 없음 |
| 3 | handoff summary residual (R2-F4 pattern) | `601717` §9.2 L1132 | R2-F4 가 §4.4.3 Prerequisite(L716–726)에 N-8″ 를 연결했으나 §9.2 요약은 「H-1 prerequisite = N-6″」**만** 기재. N-8″(`store_type='RESTAURANT'`) 누락 | **no** | 권위 handoff 절 §4.4.3·§7.3 N-8″ L953 가 N-6″·N-8″ **둘 다** 닫음. §9.2 는 경계 요약. 후속 RPC 나선이 §4.4.3 만 따르면 순서·범위 **유일**. rule 3 해당 없음 |
| 4 | AC 표현 (non-blocking) | `601716` §13 AC-6 L931 | AC-6 이 §5.6·§5.7 만 열거하고 §5.9(TP-N-62~64) 는 생략. AC-5 L930 이 「§5 Negative **전** 항목」으로 §5.9 포함 | **no** | 실행 의미 중복 — AC-5 가 §5.9 를 이미 전건 PASS 로 요구. rule 1·2·3 해당 없음 |

---

## Closed facts — 재개방 없음

아래는 본 라운드에서 **재판정·재설계하지 않음**:

- C-1 · C-2 `DEFERRED — INELIGIBLE` (`601717` §1.5 · §4.4.1.2)
- B-7 · B-8 CLOSED (`601717` §10.2 · §10.3 · `601716` §12.2 L774–775)
- N-2″ · N-3′ CLOSED (`601716` §12.1 · §12.2 L776)
- `601717` §10.1 Human pre-decision 9건 — 재논쟁 금지 (§10 L1218–1220)

---

## R2-F1 회귀 검사 (A7 핵심)

1차 F-1 패턴(D-15 만 수정 · §1.6 잔존)에 대한 11판 확인:

```text
601717 §1.4 D-15 L301     ADD CONSTRAINT … UNIQUE 만 허용 · CREATE UNIQUE INDEX 제외
601717 §1.6 L343–347      ADD CONSTRAINT (D-15) · CREATE INDEX (D-20) — CREATE UNIQUE INDEX 없음
601717 §4.2 #1 L526       ALTER TABLE … ADD CONSTRAINT … UNIQUE (R2-F1)
601716 TP-P-29 L395       UNIQUE 제약 · unique index 단독 FAIL
```

**R2-F1 blocking 잔존: 없음.**

---

## Validation

| Check | Result |
|---|---|
| `601716` / `601717` 수정 | **없음** (Eyes-Only) |
| 지정 외 파일 생성·수정 | **없음** (본 결과 파일 1건만 생성) |
| git 명령 | **미실행** (지시 금지) |
| Codex 결과 파일 참조 | **없음** |

---

## Verifier A disposition (Round 3)

**Blocking: NO CONCERNS FOUND**

Informational 4건 — 모두 Stage 8 에서 **서로 다른 코드**를 만들 가능성이 없는 stale summary·요약 잔존·AC 중복 표현이다. R2-F1~F5 권위 정합화는 완료된 것으로 본다. R2-F4 의 §9.2 요약 잔존은 A7 「인접 조항 잔존」 패턴이나, handoff 권위(§4.4.3)가 N-8″ 를 이미 닫아 **blocking 아님**.
