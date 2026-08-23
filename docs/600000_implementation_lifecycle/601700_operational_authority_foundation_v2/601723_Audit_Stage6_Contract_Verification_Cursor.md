# 601723_Audit_Stage6_Contract_Verification_Cursor.md

> ⚠️ **Stage 6 Contract Verification · Eyes-Only · 판정문이 아니다**
>
> `000701` §9.16 Stage 6 독립 계약 검증(Critical tier)의 Verifier A 보고서다.
> 원작자 Claude Code 는 §37 에 따라 검증자 풀에서 제외되었다.
>
> **이 보고서는 계약을 승인하지도 차단하지도 않는다.** 발견사항만 기록한다.
>
> **같은 작업을 Codex 도 독립 수행했다 — `601724`**(`000701` §35).
>
> ⚠️ **두 검증자의 결론이 갈렸다.**
>
> ```text
> 601723 Cursor   blocking 0건 — NO CONCERNS FOUND
> 601724 Codex    blocking 5건 / 고유 findings 7건
> ```
>
> **이 불일치 자체가 Stage 6 의 산출물이다.** 어느 쪽이 옳은지는
> Claude 통합(`000701` §9.19)과 §9.20 원문 직접 재검토가 판정한다.
>
> 수행: Cursor, 2026-08-23.

**수행 주체**: Cursor (Verifier A)  
**근거**: `000701` §9.16 Stage 6 Contract Verification (Critical tier) / §37  
**역할**: Eyes-Only — `601716` / `601717` 및 기타 파일 **미수정**  
**검증 일시**: 2026-08-23  
**대조 기준**: `601702` · `601705` · `601710` · `601713`  
**참조 증거**(필요 시): `601711`/`601712` · `601714`/`601715` · `601718`/`601719` · `601720`/`601721`

---

## V1. Allowed Files 경계

`601717` §1 의 허용 파일 목록이 `601710`/`601713` 이 서술한 경계와 **정확히 일치하는가.**

| # | 항목 | 판정 | 근거 위치 |
|---|---|---|---|
| 1 | 구현 대상 5건(Overview §2) ↔ migration 2건(A-1·A-2) | **일치** | `601710` §2 L42–48 · `601717` §1.1 L244–247 |
| 2 | Person 계열 = `0170` 전용 | **일치** | `601713` §1.1 I-1~I-16 · `601717` §1.3 D-1~D-13 |
| 3 | MerchantAccount + backfill = `0171` 전용 | **일치** | `601713` §1.5 I-47~I-51 · `601717` §1.4 D-14~D-21 · §4.5 M-1·M-2 |
| 4 | A-3 = `601722_Module_…V2.md` 확정 | **일치** | `601717` §1.2 L253 — 「파일명 확정 — 와일드카드 아님」·「다음 빈 번호」 지시 폐기 |
| 5 | `601710` §3 Out of Scope 가 허용 목록에 없음 | **일치** | `601710` §3 L141–155 · `601717` §6 FO-21~FO-33(범위 밖 조작 금지) — RPC 재작성·Store 상태 3축·Staff/User 등 §1.1에 없음 |
| 6 | External Provider Mapping 물리 구현 미허용 | **일치** | `601710` §3.1 L157–177 · `601717` §4.6 · FO-21 |
| 7 | Stage 10 문서 동기화 = A-3~A-6 만 | **일치** | `601717` §1.2 L249–256 · B-9 DEFERRED(§7.2 L834) — 27~30건 legacy 문서는 Stage 8 에서 수정 금지 |

**특히 확인**

- **A-3 → `601722` 확정**: `601717` §1.2 L253·§10.1 항목 1 L1066.
- **와일드카드·「다음 빈 번호」**: §1.2 L261–262 에 명시적 폐기.
- **§3 Out of Scope 침범**: 허용 파일·DDL·DML 목록에 RPC·앱 코드·provider mapping 경로 없음.

---

## V2. Allowed Operations 동사 입도

`601717` §4(§1.6) 의 각 항목이 **narrow verb** 인가.

| # | 조작 ID | narrow 인가 | 근거 |
|---|---|---|---|
| 1 | D-1~D-13 (Person) | **예** | `601717` §1.3 L270–282 — `ALTER TABLE … RENAME TO/COLUMN/CONSTRAINT`, `ALTER TRIGGER … RENAME TO`, `ALTER INDEX … RENAME TO`, `DROP COLUMN/CONSTRAINT`, `COMMENT ON TABLE` |
| 2 | D-14~D-21 (MerchantAccount) | **예** | `601717` §1.4 L298–305 — `CREATE TABLE`, `UNIQUE`/`CREATE UNIQUE INDEX`, `CREATE TRIGGER`, `ENABLE/FORCE ROW LEVEL SECURITY`, `ADD COLUMN/CONSTRAINT`, `CREATE INDEX`, `COMMENT` |
| 3 | M-1 · M-2 (backfill) | **예** | `601717` §4.5 L637–640 — `INSERT … SELECT FROM tenants`, `UPDATE … FROM merchant_accounts` (구문 §4.5.1 확정) |
| 4 | §1.6 허용 동사 목록 | **예** | `601717` §1.6 L337–347 — broad 「stores 테이블 수정」류 없음 |
| 5 | 금지 동사 `SET NOT NULL` | **예 (명시적 금지)** | `601717` §1.6 L349–350 · FO-13 L766 |

---

## V3. TestPlan coverage

`601713` Logic 의 **I-1~I-51** 불변조건이 `601716` 에서 검증되는가.

### I-1~I-51 매핑 요약

| 불변조건 | 대응 Test ID | 미검증이면 사유 |
|---|---|---|
| I-1 · I-2 | TP-P-05 | — |
| I-3 | TP-P-06 | — |
| I-4 | TP-P-08 · TP-P-32 · TP-R-03 | 구조·함수 정의만 검사. UPDATE 시 `updated_at` 갱신 **기능** 테스트는 없음 |
| I-5 · I-6 · I-7 | TP-P-09 · TP-P-10 · TP-P-11 | — |
| I-8 | TP-P-12 | — |
| I-9 | TP-P-02 | — |
| I-10 · I-11 | TP-P-14 · TP-N-09 | — |
| I-12 · I-13 | TP-P-15 · TP-P-16 · TP-N-14 | — |
| I-14 · I-15 | TP-P-19 · TP-P-23 | — |
| I-16 | TP-B-03 · TP-M-04 · TP-M-10 | — |
| I-17 | TP-N-15 | — |
| I-18 · I-19 | *(명시 TP 없음)* | 다Store·다LegalEntity **운영 의미** 불변. 0-A 는 schema/backfill 범위(`601716` §14) |
| I-20 | TP-N-16 (간접) | `merchant_accounts` 에 LegalEntity FK 없음으로 I-38 과 공유 |
| I-21 · I-22 | *(명시 TP 없음)* | Tenant 오용·향후 1:N 정책 — migration 검증 범위 밖 |
| I-23 | TP-P-37 | — |
| I-24 · I-25 · I-26 | TP-N-22 · TP-P-34 (간접) | Tenant 역참조·Store 구조 부모 = `merchant_account_id` 쪽 |
| I-27 | §5.6 TP-N-40~43 · §12.4 C-1/H-2 | enforcement 는 **negative + 이월** (`601716` §0.2 L130–145) |
| I-28 · I-30 | TP-N-26~28 | — |
| I-31 · I-32 | *(명시 TP 없음)* | Store–LegalEntity 개수 미정·LegalEntity 전역성 — 이번 나선이 물리 강제하지 않음(`601713` §1.5 I-31) |
| I-33 | TP-N-29 · §12.2 B-5 | 시점 이력 미구현 — blocker 로 기록 |
| I-34~I-37 | TP-P-03~04 · TP-P-17~21 | — |
| I-38 · I-39 | TP-N-16~21 · TP-N-60 | — |
| I-40~I-42 | §5.4 TP-N-25~30 · §12.4 C-2 | C-2 `DEFERRED` — negative 만 |
| I-43~I-46 | TP-P-08 · TP-P-18 · TP-N-07 · TP-N-08 | — |
| I-47 | TP-D-02 · TP-D-08 | **검증 시점 상태**만. 강제 장치 부재 = §12.3 N-1″ (`601717` §10.4) |
| I-48 | TP-D-01 · TP-D-07 | — |
| I-49 | TP-P-29 · TP-D-02 · TP-N-22 | — |
| I-50 | TP-P-25 · TP-N-24 | — |
| I-51 | TP-P-33 · TP-N-11 · TP-N-13 | — |

### X-1~X-11 · E-1~E-4 · 기타

| 항목 | 대응 | 비고 |
|---|---|---|
| X-1 | TP-P-05 | — |
| X-2 | TP-P-06 | — |
| X-3 | TP-P-08 · TP-P-32 | — |
| X-4 | TP-P-09~11 | — |
| X-5 | TP-P-12 | — |
| X-6 · X-7 · X-8 | TP-P-14~15 · TP-N-09~14 | — |
| X-9 | B-9 DEFERRED · TP-B-06 | 문서 정합화는 **별도 나선** — `601717` §7.2 L834 · `601713` §3 X-9 L415–419 |
| X-10 | TP-B-03 · TP-M-10 | — |
| X-11 | PRE-1 · TP-M-01~03 | Stage 7 승인 전 적용 금지 |
| E-1~E-4 | §5.4 TP-N-25~28 · `601717` §3.2 | C-2 부적격 조건 — negative 로 검증 |
| idempotency / rollback | TP-M-08 · §11 TP-RB-01~08 | clean baseline replay (`601717` §10.2) |
| audit / evidence | PRE-3~7 · BL-1~38 · TP-N-50~53 | environment drift 게이트 |
| **negative test** | §5 전체 · §5.6 · §5.7 · §7 TP-X-01~13 | 금지 조작·NOT NULL·RPC 무변경 |

**판정**: **대부분 일치.** I-18·I-19·I-21·I-22·I-25·I-26·I-31·I-32 는 명시 Test ID 없음 — 다만 `601716` §14·§0.2 가 0-A schema/backfill 범위를 한정하고, 해당 불변조건은 운영·정책 축 또는 C-1/C-2/B-5 이월로 처리됨.

---

## V4. Forbidden Operations 우회 경로

| # | 금지 조항 | 우회 가능성 | 근거 |
|---|---|---|---|
| 1 | FO-A~FO-B1 — 두 INSERT RPC 전면 금지 | **닫힘** | `601717` §6.1 L743–745 — 생성·수정·삭제·재정의 + phantom 교정(FO-B1) |
| 2 | FO-C — INSERT 컬럼 목록에 `merchant_account_id` 추가 | **닫힘** | `601717` §6.1 L746 · `601716` TP-N-52 |
| 3 | FO-D — `onboard_tenant` / `update_business_hours` | **닫힘** | `601717` §6.1 L747 · `601716` TP-N-53 |
| 4 | FO-E — 우회 store 생성 함수·트리거 | **닫힘** | `601717` §6.1 L748 · `601716` TP-N-54~56 |
| 5 | FO-13 — `SET NOT NULL` | **닫힘** | `601717` §6.2 L766 · `601716` TP-N-40~42 |
| 6 | FO-15 · TP-M-11 — migration 내 함수 재정의 | **닫힘** | `601717` §6.2 L768 · `601716` TP-M-11 L647 |
| 7 | FO-36 / X-18 — 검증 도구 조작 | **닫힘** | `601717` §5.3 L729 · §6.4 L799 |
| 8 | `create_franchise_store` 실패를 수정 근거로 사용 | **닫힘** | `601717` FO-B1 L745 · §4.4.1.1 L581–585 · `601716` TP-RT-08 L674 |

---

## V5. C-1 · C-2 이월 판정

| # | 항목 | 판정 | 근거 |
|---|---|---|---|
| 1 | C-1 표기 | **`DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT`** | `601717` §1.5 L313 · §12.4 L773 |
| 2 | C-2 표기 | **동일** | `601717` §1.5 L314 · §3.1 L409 |
| 3 | `RESOLVED` 기록 여부 | **없음** | `601717` §1.5 L316–324 · `601716` §12.4 L782–784 |
| 4 | `601702` §1.24 · §1.26 · §1.34 · §1.45 요구 생존 | **살아 있음** | `601717` §1.5 L328–331 · §4.4.3 H-1~H-4 · `601716` §12.4 L771–780 |

---

## V6. H-1~H-5 handoff

| # | 이월 항목 | `601717` | `601716` | 축소·누락 |
|---|---|---|---|---|
| H-1 | `provision_tenant` → `merchant_accounts` 동시 생성 | §4.4.3 L614 | §12.4 L775 | **없음** |
| H-2 | `provision_tenant` stores INSERT `merchant_account_id` | §4.4.3 L615 | §12.4 L776 | **없음** |
| H-3 | `create_franchise_store` 동일 | §4.4.3 L616 | §12.4 L777 | **없음** |
| H-3a | phantom `extra_metadata` 선행 교정 | §4.4.3 L617 | §12.4 L779 | **없음** |
| H-4 | H-1~3 후 C-1 재판정 | §4.4.3 L619 | §12.4 L778 | **없음** |
| H-5 | name synchronization 정책 | §4.4.3 L618 · §4.5.1 L654–662 | §12.4 L780 · AC-17 L808 | **없음** |

---

## V7. blocker 처분

| # | 항목 | 판정 | 근거 |
|---|---|---|---|
| 1 | 구현자 판단으로 새 정책을 만들 blocker | **없음** | 미해소 blocker(B-5·B-6·B-9·N-1″·N-2′·N-3″·N-4″·N-5″) 전부 **처분·이월·negative 검사**로 고정 |
| 2 | `601717` §7 ↔ `601716` §12 일관성 | **일치** | 해소 목록(§7.1 ↔ §12.1) · 잔존(§7.2 ↔ §12.2) · 신규(§7.3 ↔ §12.3) · 이월 C/H(§1.5 ↔ §12.4) 대응 |
| 3 | C-1·C-2 위치 | **일치** | blocker 가 아닌 §1.5 판정 상태 — `601717` §7.3 L864–865 · `601716` §12.4 L768 |

---

## V8. 두 문서 간 모순

| # | 대조 항목 | 판정 | 근거 |
|---|---|---|---|
| 1 | 허용 파일 A-1~A-6 | **일치** | `601717` §1 · `601716` TP-B-01~08 L624–631 |
| 2 | 금지 RPC 4건 | **일치** | `601717` §6.1 · `601716` §5.7 · TP-M-11 |
| 3 | C-1·C-2 · H-1~H-5 | **일치** | `601717` §1.5 · §4.4.3 · `601716` §12.4 |
| 4 | Stage 7 현재 상태 | **일치 (배너 기준)** | `601717` §10 L1054–1056 · `601716` PRE-1 L252 |
| 5 | 기준선 md5 · 컬럼 · 행 수 | **일치** | `601717` §0.1.2 L106–113 · `601716` §2.1 BL-21·BL-35~37 · PRE-5~7 L97–100 |
| 6 | §12.4 「Stage 7 APPROVED」 vs PRE-1 「대기」 | **표면 긴장 — 문서가 자체 해석** | `601716` §12.4 L769 vs PRE-1 L252 · `601717` §10 L1023–1025(pre-decision 승계) · §10 L1062(효력 없음) |

---

## V9. Stage 7 선행조건

| # | 항목 | 판정 | 근거 |
|---|---|---|---|
| 1 | §10 무효화 배너 ↔ Stage 표 | **일치** | `601717` §10 L1000–1009 — Stage 6 NOT COMPLETED · Stage 7 NOT EFFECTIVE · Stage 8 MUST NOT START |
| 2 | Human 판단 가능 형태 (§10.1 9건) | **예** | `601717` §10.1 L1064–1074 — 파일명·C-1/C-2·H-1~5·§4.1 5컬럼·blocker·환경·I-47 해석 |
| 3 | environment drift 게이트 | **예** | `601717` §10.3 L1105–1116 · `601716` PRE-3·5~7 L254–258 |
| 4 | §10.1 pre-decision 보존 ↔ 재승인 경로 | **명시** | `601717` §10 L1027–1043 |

---

## V10. Stage 8 착수 차단

| # | 항목 | 판정 | 근거 |
|---|---|---|---|
| 1 | §9.3 구현자 지시 vs §10 배너 | **일치 (9판 G-2 정정)** | `601717` §9.3 L946 「Stage 7 미승인 … Stage 8 을 착수하지 않는다」·§10 L1009 MUST NOT START |
| 2 | 「Stage 7 승인 완료」 잔존 (§9.3) | **없음** | 9판 §0.3 G-2 L216–222 — 종전 1행 제거 확인 |
| 3 | `601716` PRE-1 | **일치** | `601716` PRE-1 L252 — 「대기」·착수 조건 미충족 |

---

## 종합

| 항목 | 발견 | 그중 blocking |
|---|---|---:|
| V1 Allowed Files | 0 | 0 |
| V2 Allowed Operations | 0 | 0 |
| V3 TestPlan coverage | 2 (비명시 invariant · I-4 기능) | 0 |
| V4 Forbidden / 우회 | 0 | 0 |
| V5 C-1/C-2 이월 | 0 | 0 |
| V6 H-1~H-5 | 0 | 0 |
| V7 blocker | 0 | 0 |
| V8 문서 간 | 1 (pre-decision 표기 긴장) | 0 |
| V9 Stage 7 선행 | 0 | 0 |
| V10 Stage 8 차단 | 0 | 0 |
| **합계** | **3** | **0** |

**blocking concern: 없음** — Stage 6 Contract Verification 관점에서 계약·TestPlan 은 authority 와 정합하며, 발견 3건은 문서화된 범위 한정·pre-decision 관행으로 설명 가능하다.

---

## Findings

| # | 유형 | 지점 | 내용 | blocking |
|---|---|---|---|---|
| 1 | missing test | `601716` §4 · `601713` I-18·I-19·I-21·I-22·I-25·I-26·I-31·I-32 | 운영·정책 축 불변조건에 **명시 Test ID 없음**. `601716` §14·§0.2 가 schema/backfill 범위를 한정하고 FO/negative 로 우회 구현을 막음 | **no** |
| 2 | missing test | `601716` TP-P-08 · `601713` I-4 | `updated_at` 트리거 **존재**만 검사. UPDATE 시 갱신 **동작** 테스트 없음 (TP-R-03 은 함수 정의 불변) | **no** |
| 3 | document conflict | `601716` §12.4 L769 vs PRE-1 L252 | §12.4 「Stage 7 APPROVED」와 PRE-1 「대기」 표면 불일치. `601717` §10 배너·pre-decision 승계(L1023–1025)로 **의도적 병기**로 해석 | **no** |

---

## Verifier Statement

- **Eyes-Only** 준수: `601716` / `601717` 및 기타 repo 파일 **미수정**.
- **승인·차단 판정 없음** — 발견사항만 기록 (`000701` §9.18).
- **Stage 7 blocking issue: NO CONCERNS FOUND** (non-blocking informational findings 3건 위 표 참조).
