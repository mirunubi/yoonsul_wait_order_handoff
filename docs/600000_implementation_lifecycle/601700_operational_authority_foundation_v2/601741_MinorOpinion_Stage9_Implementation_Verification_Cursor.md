# 601741_MinorOpinion_Stage9_Implementation_Verification_Cursor

Status: Active
Lifecycle: MinorOpinion
Owner: Stage 9 (Cursor) — Verifier B
Last Updated: 2026-08-24

## Change ID

```text
Workpacket    601700  Operational Authority Foundation V2 (0-A 재수행)
Change Scope  ① Person 어휘·물리 식별자 정합화
              ② MerchantAccount foundation 신설 + canonical backfill + Store 구조 부모 연결
Migration     0170 · 0171  (신규 · 번호 미사용 확인: sql/migrations 최신 = 0169)
```

## Reviewed Against

| # | Canonical input | Reference commit / hash | Review method |
|---|---|---|---|
| 1 | `601717_ChangeContract_Operational_Authority_Foundation_V2.md` | 승인 기준 커밋 `01cfd45bab7710b0db2a4957b7e540bebfad7377` · 현재 최종 변경 `accf0666ffedec69241cc93c4c992e0d229e5ecd` | §1 허용 범위 · §10.8 SHA-256 기록값 대조 |
| 2 | Stage 8 implementation delta | `git diff df49eb56..bc4cd14` | `01_git_diff_stat.txt` · `03_git_diff_name_only.txt` · `04_git_diff.patch` · read-only `git diff` |
| 3 | `0170` / `0171` | `b657ec23ce5493c7561cd1139c93c6ee2bc21090` · `bc4cd14deaea6d696d573d437163ab42d4f93619` | migration 전문 · `04_git_diff.patch` · `08_schema_positive.log` · `10_backfill_checks.log` |
| 4 | `601740_VerificationResult_Stage9_Implementation_Verification_ClaudeCode.md` | `1f9b4428` (`docs: 601740 Stage 9 Verifier A result and raw evidence`) | §2~§8 전건 · §5 결과표 235 active Test ID |
| 5 | raw_logs `01`~`15` | `docs/implementation_evidence/601700/raw_logs/` (repo commit `a2e659cdbbd2ecbe3795ea222f7f5764a73d9777` 에 추적) | O-1~O-4 핵심 4종 우선 · FAIL/SKIP 전건 · PASS spot-check |
| Baseline | `601716` §10.8 approved SHA-256 | `00C1376EB1230A4B68F27C1479681C5BC95B23A8801EE70364EAACF22719F102` | worktree · git blob @ `1f9b442` · git blob @ `HEAD` 독립 재측정 |

**B1~B6 를 먼저 잠근 뒤** `601739_Evidence_Stage8_Supplemental_FileScope_Pass_Cowork.md` 를 열람하여 B7 을 수행했다. B1~B6 근거로 `601739` 결론을 사용하지 않았다.

## Concerns

| # | 유형 | 지점 | 내용 | severity |
|---|---|---|---|---|
| 1 | 판본 고정 | `601740` §1.2 L61 | §1.2 는 `601716` SHA-256 실측을 「worktree `00c1376e…f102` · **`git show HEAD:` blob 동일** · **일치**」로 기록한다. 독립 재측정: (a) worktree 파일 SHA-256 = `00C1376EB1230A4B68F27C1479681C5BC95B23A8801EE70364EAACF22719F102` (`601717` §10.8 L1826·L1953 와 일치, 88800 bytes); (b) git blob @ `1f9b442` 및 @ `HEAD` (`4ad4fae535a7858f06c1ef8f0fe21d499518eff6`, 70223 bytes decompressed) SHA-256 = `672ED1D127B2725CC2902EBE4EA155EA1A45765A31754C8FF532EEC6E41D9DC3` — **§10.8 기록값과 불일치**. **`git show HEAD:` blob 동일** 주장은 raw git evidence 로 뒷받침되지 않는다. | MATERIAL_CONCERN |
| 2 | 저장소 상태 | `601716` path · `git ls-files -v` | `601716` 에 skip-worktree 플래그 `H` 가 설정돼 있다. worktree(승인 해시 일치) 와 index/HEAD blob(상이) 이 분리돼 있어 §1.2 서술 혼선 가능성이 있다. Stage 11 판본 감사 시 worktree·index·blob 삼중 대조 권고. | INFORMATIONAL |
| 3 | 알려진 spec conflict 처리 | `601740` §0 · §5.11 AC-13 · §8 | AC-13 = `SKIP(SPEC_CONFLICT_AC13)` · `SPEC_CONFLICT_OBSERVED` 분류는 타당하다. PASS 로 승격하지 않았고 `IMPLEMENTATION_DEVIATION` 으로 분류하지 않았다. (신규 conflict 재발견 아님.) | INFORMATIONAL |
| 4 | 알려진 DocumentType conflict | `000002` §1.2 · `000701` §9 · `05_governance_check.log` L28-L40 | G02 ERROR(VerificationResult DocumentType) 는 이미 기록된 spec conflict 이다. `601740` 본문에 별도 observation 행은 없으나 Stage 9 관측 범위 밖 governance 항목으로, Verifier A 235 Test ID 판정과 직접 충돌하지는 않는다. | INFORMATIONAL |

## 601740 discrepancy review

235/235 active Test ID result rows reviewed (`601740` §2 inventory · §3 · §5).

**판정 불일치 1건** — §1.2 `601716` git blob SHA-256 「일치」행 (위 Concerns #1).

**그 외 전건** — 아래 독립 대조에서 `601740` 판정·수치·raw log 인용이 일치했다.

| Cluster | `601740` claim | Raw / independent evidence | Discrepancy |
|---|---|---|---|
| BL-22 · TP-R-14 | FAIL · 실측 **151** (기대 158) | `11_regression.log` L8-L30 (4 variants 모두 151) | 0 |
| BL-33 · TP-R-19 | FAIL · **243** (기대 241) | `11_regression.log` L62-L66 | 0 |
| TP-M-07 · AC-9 파생 | FAIL · SPEC_CONFLICT | `04_git_diff.patch` L72-L129: D-14…D-21 → M-1 → M-2 (`601740` §6.1 · `601716` TP-M-07 vs `601717` §1.4) | 0 |
| TP-M-08 | FAIL · `0093` 중단 | `14_replay.log` L7-L8 · L47-L49 | 0 |
| RUN 2 supplementary | `0170`/`0171` rc=0 (TP-M-08 아님) | `14_replay.log` L51-L57 | 0 |
| TP-RB-03 · TP-RB-08 | SKIP · disposable baseline | `15_rollback.log` L1-L5 · L46-L99 | 0 |
| IMPLEMENTATION_DEVIATION_OBSERVED | 0 | `04_git_diff.patch` · `601740` §4 D-1~D-21/M-1/M-2 대조 | 0 |
| Stage 8 delta scope | A-1·A-2 only | `git diff df49eb56..bc4cd14 --name-only` → `0170` · `0171` 2 files; `01_git_diff_stat.txt` L9-L12 | 0 |
| FAIL 8 / SKIP 6 / PASS 221 집계 | §3 표 | §5 전건 합산과 일치 (파생 FAIL 포함) | 0 |

## Verifier A status claim review

`601740` claim: Stage 9 = **INCOMPLETE** (`601740` §3.2 L149-L164 · §12 L748).

**Concern: NONE** (서술 자체에 대한 우려만 기록; Cursor 는 INCOMPLETE 를 선언하지 않는다.)

- §3.2 는 TestPlan 결과(§3.1 FAIL 8 · SKIP 6)와 **별개** observation 으로 세 독립 사유를 열거한다: (1) unresolved spec conflict — AC-13 · TP-M-07 · BL-33/TP-R-19 (`601740` §0 · §6.1 · §6.2); (2) TP-M-08 clean replay 미도달 (`14_replay.log`); (3) required SKIP 6건 (`601740` §8).
- §12 L752-L754 는 FAIL 8건 중 `0170`·`0171` 계약 위반 기인 0건을 명시하고 spec conflict / evidence gap 으로 분해한다 — Stage 9 관측 범위 내 서술이다.
- `TESTPLAN_DEFECT` · `CONTRACT_DEFECT` **확정** 문구는 본문에 없다 (`601740` L15 disclaimer only). B6 권한 준수 concern 없음.

## 601739 late comparison

B1~B6 완료 후 `601739` §0 · §1 · §8.1 · §9 · §11 과 `601740` §11 을 대조했다.

| `601740` §11 주장 | `601739` 근거 | 대조 결과 |
|---|---|---|
| TP-M-07 FAIL · SPEC_CONFLICT — **일치** | `601739` §8.1 L681-L692 | **정확** — 양 pass 공통 결론 |
| AC-9 파생 FAIL — **일치** | `601739` §4 AC-9 · §8 L679 | **정확** |
| 판본·EOL — **일치** | `601739` §1 L65-L74 | **부분 정확** — 양 pass 모두 hash/EOL PASS 로 기록했으나, §1.2 의 **`git show HEAD:` blob = §10.8** 주장은 양쪽 모두 git blob 재측정(`672ED1D1…`)과 불일치(Concerns #1). 「pass 간 일치」는 맞고, 「git blob = 승인 해시」 공동 주장의 정확성은 둘 다 의심 |
| TP-M-02/03 · DB 195건 · TP-M-08 — 환경 차이 | `601739` §0.3 L47-L57 · §9 L704-L723 | **정확** — SKIP 사유 분류 적절 |
| BL-22/BL-33 — 601739 SKIP → 601740 FAIL | `601739` §9.1 L714 「함수 158」Stage 9 이관 · L196 · L358 | **정확** — 환경·판정 차이 구분 적절; 601739 가 Stage 9 DB 실측을 요구했고 결과가 FAIL |
| AC-13 — 601739 PASS → 601740 SKIP | `601739` §0.1 L28 · §4 AC-13 L454 | **정확** — 판정 차이 기술 적절 |
| 「어느 쪽이 옳은지 결정하지 않는다」 | `601740` §11 L723 | **준수** — AC-13 에 대해 단정 없음 |

**B7 종합:** `601740` §11 은 Cowork supplemental pass 와의 **차이 분류**(환경 vs 판정)를 대체로 정확히 기술한다. 다만 §11 「판본·EOL · 전건 일치」행은 git blob SHA-256 에 대해 Concerns #1 과 동일한 과대 서술을 `601739` 와 공유한다.

## Not A Verdict

This document is a non-binding second opinion.
It carries no approve/block authority.
Stage 11 must explicitly address each concern.
