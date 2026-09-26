# ChangeContract.md — CTN-1a

## Change ID

`ctn1a_isolate_tenant_execute_containment`

Workpacket: 603010 (Stage 3 결정)
Status: Draft
Draft Status: Draft (Claude Code)
Stage: 000701 Stage 5 Contract Drafting
Lifecycle: ChangeContract
Gate Classification: CTN-1a Containment Change Contract Draft
Runtime Implementation Authorization: Not Granted
Owner: 정영석
Last Updated: 2026-09-25

> 이 ChangeContract 는 구현을 승인하지 않는다 (`000001` §5.4.5).
> Stage 6 이 검증하고, Stage 7 에서 Human 이 아래 Human Boundary Approval 절을 채운 뒤에만 Stage 8 이 구현한다.

### 파일 위치와 G15

이 계약 파일은 `docs/600000_implementation_lifecycle/603000_containment/603010_ctn1a_isolate_tenant_execute_containment/` 로 옮겨진다 (Stage 3 결정 IS-2). **폴더 생성과 이동 시점은 Stage 10 이다** (Stage 6 처분 F-13 — 이전 초안의 "Stage 7 승인 직후 · Stage 8 전" 표기를 통일했다).

그때 `tools/Check-Governance.ps1` 의 G15 가 규칙 ①(폴더)로 이 계약을 찾는다 — `Find-ChangeContract` L951~967 은 워크패킷 번호로 시작하는 폴더 아래의 첫 `*ChangeContract*.md` 를 쓴다. migration 쪽 연결은 `0180` 파일 첫 5행의 `-- Workpacket: 603010` 이다 (`Check-Governance.ps1` L971 정규식 · L977 첫 5행 읽기 · L979 는 헤더 없음 분기 · `000701` §6.11.1). 따라서 **G15 판정은 Stage 10 폴더 이동 후에 확인한다** (04_TestPlan M-8).

## Purpose

`catchmenu_common.isolate_tenant` 와 `catchmenu_common.detect_threat` 의 직접 진입(EXECUTE)을 `PUBLIC` · `anon` · `authenticated` 에서 닫는 임시 containment 의 구현 경계를 고정한다. 발견 경위와 설계는 02_Overview · 03_Logic 에 있다.

## Contract Status

| 항목 | 상태 |
|---|---|
| Stage 3 설계 검토 | 반영 완료 (2026-09-22) |
| Stage 4 아키텍처 검증 | 반영 완료 (2026-09-25 · Codex F-1~F-7 · Cursor 1~6 전건 수용) |
| Stage 5 계약 초안 | 이 문서 |
| Stage 6 계약 검증 | 미수행 |
| Stage 7 Human Approval | 아래 절 — 비어 있음 |
| Stage 8 구현 | 미수행 |

## Allowed Files

### A. Stage 8 이 만들거나 고칠 수 있는 파일 (Stage 6 처분 F-3 으로 확장)

| 파일 | 종류 | 비고 |
|---|---|---|
| `sql/migrations/0180_ctn1a_isolate_tenant_execute_containment.sql` | **신규** | 이 변경의 유일한 구현 파일 |
| `docs/implementation_evidence/ctn1a_isolate_tenant_execute_containment/raw_logs/stage8/` | **신규 폴더** | Stage 8 이 만든다. 파일 9개 — 04_TestPlan 절차 8 |
| `docs/implementation_evidence/ctn1a_isolate_tenant_execute_containment/06_ImplementationModule.md` | **신규** | Stage 8 self-report (`000701` §15 L2384) |

### B. Stage 9 가 만들거나 고칠 수 있는 파일

| 파일 | 종류 | 비고 |
|---|---|---|
| `docs/implementation_evidence/ctn1a_isolate_tenant_execute_containment/raw_logs/stage9/` | **신규 폴더** | Stage 9 가 만든다. 파일 10개 — 04_TestPlan 절차 8 |
| `docs/implementation_evidence/ctn1a_isolate_tenant_execute_containment/07_VerificationResult.md` | **신규** | Stage 9 교차 재검증 (`000701` §15 L2385) |

### C. Stage 10 문서 · 색인 — **조건부**

**Stage 7 에서 선택된 항목만 허용된다** (아래 「Stage 7 확정 대상」 ② · ③ · ⑤). 선택되지 않은 파일은 Forbidden Files 로 남는다.

| 파일 | 작업 | 조건 |
|---|---|---|
| `docs/600000_implementation_lifecycle/603000_containment/603000_Readme_Containment.md` | 신규 — 폴더 Readme + **HD-CTN-02 예외 레지스트리** | ⑤ |
| `…/603000_containment/603010_ctn1a_isolate_tenant_execute_containment/` | 신규 폴더 — 이 패킷 문서 이동 | 무조건 (Stage 3 결정 IS-2) |
| `docs/000005_Index_Document_Number.md` | 행 추가 · prototype 601513 행 처리 | 무조건 + ③ |
| `docs/000007_Map_Full_Directory.md` | 행 추가 | 무조건 |
| `docs/600000_implementation_lifecycle/600010_Tracker_Spiral_Workpacket_Progress.md` | **1행 추가** (예외 기록) | ⑤ |
| `sql/migrations/0179_ctn1a_revoke_isolate_tenant_execute.sql` | 이동 · 보존 · 삭제 중 선택된 처분 | ② |
| `docs/…/601500_…/601513_Evidence_Containment_Isolate_Tenant_Execute_Revocation.md` · `601500_Readme…` L104 행 | 선택된 처분 | ③ |
| `sql/migrations/CHANGELOG.md` | 이 변경과 prototype 처분 기록 | ② · ③ |

**Stage 8 이 건드릴 수 있는 것은 A 뿐이다.** B 는 Stage 9, C 는 Stage 10 소관이며, C 는 Stage 7 선택에 따라 범위가 정해진다.

## Forbidden Files

### 조건 없는 Forbidden (어느 단계에서도 건드리지 않는다)

- `sql/migrations/0000_*.sql` ~ `0178_*.sql` **전부** (`000701` §14.5 불변 경계)
- `docs/…/601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` (`000001` §5.10 · `600020` §1.4 L81)
- `docs/…/602060_…md` · `docs/…/602061_…md` (비권위 · RG-06 소관)
- `tools/apply_migrations.py` · `tools/Check-Governance.ps1` (도구 수정은 범위 밖)
- `business_day_probe_out.txt`
- 그 밖 모든 파일

### 조건부 (Stage 7 선택에 달린 파일 · 대상)

- **위 Allowed Files C 의 조건부 파일 중 Stage 7 에서 선택되지 않은 것은 Forbidden 으로 남는다.** 해당: `sql/migrations/0179_ctn1a_revoke_isolate_tenant_execute.sql`(②) · `docs/…/601513_Evidence_Containment_Isolate_Tenant_Execute_Revocation.md` 와 `000005` · `601500_Readme` 의 601513 행(③) · `sql/migrations/CHANGELOG.md`(② · ③).
- prototype `0179` · `601513` 은 **처분(이동 · 보존 · 삭제)과 무관하게 내용을 구현 · 문서의 근거로 재사용하지 않는다** (HD-CTN-03 · Forbidden Operations 13).
- **현재 local DB** `supabase_db_yoonsul_wait_order_handoff` / database `postgres` (Stage 6 재재검증 NC-1 — 단계별로 나눈다):
  - **Stage 8 · Stage 9 는 어떤 경우에도 현재 local DB 를 건드리지 않는다.** 모든 적용 · 검증은 B5 disposable 환경에서만 한다. 조회도 read-only 로만 한다.
  - **Stage 10 은 Stage 7 ④ 에서 "되돌린다" 를 선택한 경우에만** 현재 local DB 의 prototype 효과를 되돌릴 수 있다. 선택하지 않았으면 Stage 10 도 건드리지 않는다.

### 우선순위 규칙 (Stage 6 재검증 N-3)

같은 파일이 C 조건부와 Forbidden 에 함께 나오면 **Stage 7 선택이 우선한다. 선택되지 않았으면 Forbidden 이다.** 조건 없는 Forbidden 목록은 Stage 7 선택으로 열리지 않는다.

이 우선순위 규칙은 Allowed Files C 의 파일과 **현재 local DB 처분에 함께 적용된다** (Stage 6 재재검증 NC-1).

## Allowed Operations

`sql/migrations/0180_ctn1a_isolate_tenant_execute_containment.sql` 안에서만:

- `catchmenu_common.isolate_tenant(uuid,text,boolean,uuid,text)` 의 EXECUTE 를 `PUBLIC` · `anon` · `authenticated` 에서 REVOKE 한다.
- `catchmenu_common.detect_threat(text,integer,text,text,jsonb,uuid,uuid,uuid,text,text)` 의 EXECUTE 를 `PUBLIC` · `anon` · `authenticated` 에서 REVOKE 한다.

그리고 적용 결과 기록으로 (Stage 6 처분 · Cursor 7):

- `catchmenu_meta.migration_history` 에 `0180` 적용 결과 **1행을 INSERT** 한다 (**B5 환경에서만** · `tools/apply_migrations.py` L160~169 와 같은 형태 · 04_TestPlan 절차 6). 이 문장은 migration 파일 안이 아니라 Stage 8 이 psql 로 직접 실행한다.

그 밖에 이 파일에 들어갈 수 있는 것은 **`BEGIN;` · `COMMIT;` · 머리 주석뿐**이다. 머리 주석은 5행 안에 `-- Workpacket: 603010` 을 포함한다 (`000701` §6.11.1).

다른 실행문(추가 `GRANT` · `ALTER` · `CREATE` · `SET` · `DO` · `SELECT` 포함)은 허용되지 않는다.

| Operation Type | Decision | Notes |
|---|---|---|
| New source file creation | **ALLOWED** | `0180_ctn1a_isolate_tenant_execute_containment.sql` 하나만 |
| New test file creation | **FORBIDDEN** | 04_TestPlan 은 카탈로그 조회로 검증한다. 새 테스트 파일을 만들지 않는다 |
| New SQL migration | **ALLOWED** | 위 한 파일. Human Boundary Approval 로 승인된 경우에만 |
| Existing function body edit | **FORBIDDEN** | `isolate_tenant` · `detect_threat` · 상위 호출자 5개 전부 (HD-CTN-02) |
| Public interface change | **FORBIDDEN** | signature · 인자명 변경 금지 |
| Route/API contract change | **FORBIDDEN** | |
| RLS policy edit | **FORBIDDEN** | |
| Generated file edit | **FORBIDDEN** | |
| Lock file edit | **FORBIDDEN** | |
| Formatting-only changes | **FORBIDDEN** | |
| Korean Markdown rewrite | **FORBIDDEN** | `000015` |
| Helper abstraction creation | **FORBIDDEN** | wrapper 함수 금지 (HD-CTN-02) |
| 기존 migration 수정 | **FORBIDDEN** | `000701` §14.5 |
| 현재 local DB 적용 | **FORBIDDEN** | B5 환경에서만 (HD-CTN-03) |

## Forbidden Operations

### 프로젝트 기본 금지 (`000701` §9.14)

Broad refactor · 새 아키텍처 계층 · 범용 helper framework · 요청하지 않은 renaming · formatting-only diff · 인코딩 정규화 · 생성 파일 편집 · lock 파일 편집 · 한국어 Markdown 재작성 · 승인 파일 밖 편집 · Allowed Operations 에 없는 편집.

### 이 변경의 금지 — HD-CTN-02 원문 9항목

1. 두 함수 **본문** 변경
2. **signature** 변경
3. **`p_reason`** 인자명 불일치 수정
4. **wrapper** 함수 추가
5. **새 authority model** (내용은 `601902` §5 L1081 「role ID · approver 수 · EXECUTE ACL」)
6. **`service_role` grant**
7. **간접 경로 복구**
8. **0-A-2 재개방**
9. **0-C 재개방**

### 추가 금지

10. **간접 경로 차단** — DEFINER 상위 호출자 5개 경로를 막지 않는다 (CTN-1b 후보)
11. **`42883` 방벽 수정** — 「우연한 방벽」(`601505` §4.1.1 L331 · 사실은 §4.1.2 L351~358)을 고치지도 없애지도 않는다
12. **기존 migration(`0000`~`0179`) 수정**
13. **prototype `0179` · `601513` 재사용** — 내용을 구현 · 문서의 근거로 쓰지 않는다 (HD-CTN-03)
14. **현재 local DB 를 증거로 쓰기** — 현재 DB 의 ACL 상태는 prototype 효과를 품고 있다
15. **`catchmenu_*` 함수 호출** (`601505` §4.1.1 L311~314) — 검증은 카탈로그 · 권한 함수로만

## Operation Granularity Rule

Stage 8 이 받는 실행 가능한 최소 작업은 다음뿐이다.

```text
Allowed Operations:
- Create sql/migrations/0180_ctn1a_isolate_tenant_execute_containment.sql.
- In that file, REVOKE EXECUTE on catchmenu_common.isolate_tenant(uuid,text,boolean,uuid,text)
  from PUBLIC, anon, authenticated.
- In that file, REVOKE EXECUTE on catchmenu_common.detect_threat(text,integer,text,text,jsonb,
  uuid,uuid,uuid,text,text) from PUBLIC, anon, authenticated.
- Wrap both statements in BEGIN; ... COMMIT;.
- Put "-- Workpacket: 603010" in the first five lines.
- After applying in the B5 environment only, INSERT one row into
  catchmenu_meta.migration_history (same shape as apply_migrations.py L160-169).

Forbidden Operations:
- Do not add GRANT statements.
- Do not touch function bodies, signatures, or parameter names.
- Do not create wrappers, roles, or policies.
- Do not apply to the current local DB.
- Do not read or reuse prototype 0179 / 601513.
```

## 예외 기록 (Stage 3 결정 IS-6 · E1)

### Human 결정 원문 — 2026-09-22 09:41 KST

```text
HD-CTN-01  CTN-1a 에 000701 Full tier 를 공식 적용한다
HD-CTN-02  601505 §4.4 · 600020 HOLD 에 대한 좁은 containment exception
           허용: isolate_tenant · detect_threat 의 PUBLIC · anon · authenticated EXECUTE 회수만
           금지: 본문 · signature · p_reason · wrapper · 새 authority model · service_role grant ·
                 간접 경로 복구 · 0-A-2 / 0-C 재개방
           성격: 임시 containment. 0-C 최종 caller-authorization 설계를 대체하지 않는다
HD-CTN-03  기존 0179 와 그 적용 결과는 prototype · discovery material. 정규 Stage 8 · 9 증거 아님
           정규 구현은 clean migration baseline(0178 까지)에서 Codex 가 Stage 8 로 다시 수행한다
           prototype 처분과 clean baseline 구축 방식은 Stage 1 ~ 6 에서 조사 · 검증, Stage 7 에서 확정
HD-CTN-04  RG-06 은 H03-F2 만. H03-F1 은 finding 유지, 수정 소관만 CTN-1a 로 이관
```

### `601505` §4.4 의 현행 효력 — Stage 3 보정

- `600020` L98 이 효력을 유지한다고 적은 `601505` §4 조항은 §4.1.1(호출 금지) · §4.3(`ACTIVE` 승격 금지) · §4.5(신규 호출자 배포 금지) 셋이다. **§4.4 는 그 목록에 없다.**
- `000221` L499 는 `601505` §4 · §8A 를 권위 보류로 분류하고 evidence 로만 인용하게 한다.
- 따라서 §4.4 는 02_Overview 가 적은 해석 1 · 2 어느 쪽이든 이 변경을 막는 현행 효력이 없다. 해석 판정은 불필요하다 (Stage 3 결정 OQ-OV-1).
- 그럼에도 HD-CTN-02 는 승인 문구 그대로 **"좁은 containment exception"** 으로 기록한다 (보수적 기록).
- 이 변경은 효력이 유지되는 §4.1.1 을 해제하지 않고 **집행하는** 방향이다 — 직접 호출 주체를 줄인다.

### 기록 위치 (E1 + Stage 10)

| 위치 | 내용 | 단계 |
|---|---|---|
| 이 계약 (E1) | 위 원문 · §4.4 보정 · `600020` L98 과의 관계 | Stage 5 (이 문서) |
| `603000_Readme_Containment.md` 예외 레지스트리 | HD-CTN-02 1행 + 이 계약 링크 | **Stage 10** |
| `600010_Tracker_Spiral_Workpacket_Progress.md` | 1행 | **Stage 10** |

E2(새 governance 문서 `600022` · `600024`)는 보류다 (Stage 3 결정).

## Required Business Rules

1. 두 함수의 직접 EXECUTE 는 적용 후 owner `postgres` 만 갖는다.
2. 간접 경로(DEFINER 상위 호출자 5개)는 이 변경으로 닫히지 않는다 — 알려진 채로 남긴다.
3. 이 변경은 임시 containment 이며 0-C 최종 caller-authorization 설계를 대체하지 않는다.

## Required State Rules

03_Logic 의 S0 → S1 만 허용된 상태 전이다. 그 밖의 catalog 상태는 I-1 ~ I-11 로 불변이어야 한다.

## Required Idempotency Rules

`0180` 을 두 번 적용해도 S1 과 I-1 ~ I-11 이 같아야 한다. `migration_history` 의 `0180` 행은 1건을 유지한다 (`ON CONFLICT (filename) DO UPDATE` — `tools/apply_migrations.py` L166~168).

## Required Audit Rules

- 이 변경의 감사 흔적은 `catchmenu_meta.migration_history` 의 `0180` 행 1건이다 (04_TestPlan 절차 6).
- 두 함수의 audit · ledger 쓰기 경로는 바뀌지 않는다 (I-1).
- Stage 8 · Stage 9 의 raw log 를 보존한다 (04_TestPlan 절차 8).

## Required Tests

`04_TestPlan.md` 전건. 요약:

| 묶음 | 항목 |
|---|---|
| Positive | S1 역할 행렬 6개 role + PUBLIC |
| Negative | N-1 ~ N-4 (I-6 · I-7 · `service_role` · USAGE) |
| Regression | I-1 ~ I-11 |
| Migration | M-1 ~ M-8 |
| Idempotency | ID-1 · ID-2 |
| Unknown State | U-1 |
| Rollback | RB-1 ~ RB-3 (문서로만) |
| Audit / Evidence | A-1 · A-2 · E-1 ~ E-3 |
| Forbidden | FB-1 ~ FB-5 |

## Required Verification Commands

04_TestPlan 절차 4 의 쿼리 묶음을 적용 전 · 후 두 번 실행한다. 명령 수준은 04_TestPlan 절차 1 ~ 9 에 있다.

| # | 명령 · 쿼리 | 확인 |
|---|---|---|
| V-CMD-1 | `git archive HEAD sql/migrations` → manifest SHA-256 (**산출 방식은 03_Logic B5 절** · 검산 절차는 04_TestPlan 절차 2) | `8958ad05…a6e389` · 18321바이트 · 파일 177개 |
| V-CMD-2 | B5 2단계 replay (psql 직접) | 177/177 성공 |
| V-CMD-3 | S0 ACL · 역할 행렬 · I-6 · I-7 · I-8 · I-10 · I-11 쿼리 | 03_Logic S0 기대와 일치 |
| V-CMD-4 | `psql -X -v ON_ERROR_STOP=1 -f 0180_…sql` | 종료코드 0 |
| V-CMD-5 | `migration_history` INSERT + 조회 | 1행 · `success = true` |
| V-CMD-6 | S1 실측 · I-1 ~ I-11 대조 | 전건 일치 |
| V-CMD-7 | `git status --porcelain` · `git diff --name-only` | Allowed Files 밖 0건 |
| V-CMD-8 | `tools\Check-Governance.ps1 -Top 0` | 합계 증가 0 (기준선은 OQ-CC-4) |
| V-CMD-9 | 현재 DB 무변경 2시점 비교 — **Stage 8 · Stage 9 구간 한정** (각 Stage 시작 · 종료) | 같음 |
| V-CMD-10 | `docker ps -a --filter label=ctn1a_disposable=true` | 0건 (정리 완료) |

## Rollback Requirements

- 되돌리기는 회수한 EXECUTE 를 다시 주는 것이며, 그 결과는 **S0 로의 복귀**다. `authenticated` 가 두 함수를 직접 호출할 수 있게 되고 `detect_threat` 는 PUBLIC EXECUTE 로 돌아간다 — 즉 **H03-F1 이 다시 열린다** (`602061` §3.1 L243~256).
- 따라서 rollback 은 자동 절차로 두지 않는다. **Human 결정 없이 하지 않는다.**
- 불변 경계를 넘은 뒤의 정정은 새 forward migration 으로만 한다 (`000701` §14.5 L2363).
- Stage 8 · Stage 9 는 rollback 을 **실행하지 않는다.** 문서로만 확인한다 (04_TestPlan RB-1 ~ RB-3).
- B5 환경 자체는 disposable 이므로, 적용 실패 시 복구는 환경 폐기 · 재생성이다.

## Boundary With Related Workpackets

| 워크패킷 | 경계 |
|---|---|
| RG-06 (`602060` · `602061`) | H03-F2 만 RG-06 소관. H03-F1 수정 소관은 CTN-1a (HD-CTN-04). RG-06 의 migration 번호는 Stage 7 승인 순서에 따라 `0180` 다음 |
| CTN-1b (후보) | 간접 경로 차단 · `42883` 방벽 |
| 0-A-2 · 0-C | 재개방하지 않는다 (HD-CTN-02) |
| `F-REPLAY` (후보) | replay 재현성 결함 — 별도 워크패킷. 이 계약에서 고치지 않는다 |

## Codex Instruction Boundary (Stage 8 제약)

1. prototype `0179` · `601513` 을 **보지 않고**, 승인된 이 계약만으로 구현한다.
2. **B5 환경에서만** 적용한다. 현재 local DB 에 적용하지 않는다.
3. `catchmenu_*` 함수를 호출하지 않는다.
4. Allowed Files A 밖을 건드리지 않는다.
5. 실패하면 멈추고 보고한다. 파일 순서 변경 · 건너뛰기 · 우회를 하지 않는다.

## Acceptance Criteria

1. `0180` 이 Allowed Operations 두 문장 + `BEGIN`/`COMMIT` + 머리 주석만 담는다.
2. 04_TestPlan 전건 통과 (Stage 8 1차 · Stage 9 독립 재현).
3. **Stage 8 · Stage 9 구간에서** 현재 local DB 무변경이 증명된다 (각 Stage 시작 · 종료 시점 대조 — 04_TestPlan 절차 9). Stage 10 에서 Stage 7 ④ "되돌린다" 를 집행하는 경우의 변경은 **이 요건의 대상이 아니다.** 그 변경은 Stage 10 이 별도로 절차와 증거를 남긴다 (Stage 6 최종 확인).
4. raw log 와 `Change ID` 가 보존된다.
5. **Stage 10 폴더 이동 후** G15 가 이 계약을 찾아 Stage 7 승인을 읽을 수 있다 (M-8 · Stage 6 재검증 N-4).

## Open Questions For Claude

- **OQ-CC-1** Stage 8 · Stage 9 산출물 파일명(`06_ImplementationModule.md` · `07_VerificationResult.md`)을 이 임시 폴더의 `NN_` 방식으로 이어갈지, `000001` §5.4.2 의 `<DocumentType>.md` 로 둘지 (OQ-IS-7 의 연장). — **결정: `06_ImplementationModule.md` · `07_VerificationResult.md` (앵커, 2026-09-25 · `000701` §15 L2384~2385)** → Allowed Files B · Expected Final Deliverables
- **OQ-CC-2** prototype `0179` 처분(D1 · D2 · D3)과 현재 local DB 의 prototype 효과 처리는 Stage 7 결정 사항이다. 이 계약은 그 결정을 담지 않는다 — 별도 Approval 문서로 남길지. — **결정: 이 계약의 「Stage 7 확정 대상 (Human 결정)」 절에 선택지와 빈칸으로 담는다 (앵커, 2026-09-25)**
- **OQ-CC-3** raw log 의 Stage 10 이전 보존 위치 (04_TestPlan OQ-TP-3 과 같은 건). — **결정: `docs/implementation_evidence/ctn1a_isolate_tenant_execute_containment/raw_logs/stage8/` (Stage 8) · `…/raw_logs/stage9/` (Stage 9) · `000701` §7.4 (앵커, 2026-09-25 · 하위 폴더 분리는 Stage 6 처분 F-5)**
- **OQ-CC-4** V-CMD-8 의 Check-Governance 기준선을 무엇으로 고정하는가 (현재 511 · prototype 처분 결과에 따라 달라진다). — **결정: Stage 8 착수 직전 재측정값 (앵커, 2026-09-25 · 현재 511 은 2026-09-25 값)**
- **OQ-S6-1** `600020` §4 네 요건이 새 워크패킷 CTN-1a 에도 적용되는가 (§1.3 L44~45 는 「기존 구현 Lifecycle 산출물」을 대상으로 한다). — **Stage 6 검증자 둘 다 `UNVERIFIABLE` 판정 → Human 해석으로 올린다** (위 「Stage 7 확정 대상」 ⑥).
- **OQ-S6-2** `603000` 이 `000002` §2.1 L322 의 폴더 번호 대역 소유와 충돌하는가. 대안(`604000` 이후 대역) 포함. — **종결 — 충돌 없음 (Stage 6).** `600023` §6 L264~270 이 Runtime Gate 를 `602000 ~ 602999` 로 한정한다.

## Expected Final Deliverables

| # | 산출물 | 단계 |
|---|---|---|
| 1 | `sql/migrations/0180_ctn1a_isolate_tenant_execute_containment.sql` | Stage 8 |
| 2 | `06_ImplementationModule.md` (Stage 8 self-report · 완료 증명이 아니다 — `000701` §15 L2384) | Stage 8 |
| 3 | `raw_logs/stage8/` 9개 · `raw_logs/stage9/` 10개 | Stage 8 · Stage 9 |
| 4 | `07_VerificationResult.md` (Stage 9 · `000701` §15 L2385) | Stage 9 |
| 5 | `603000` Readme 예외 레지스트리 · `600010` Tracker 1행 · 색인 등록 | Stage 10 |

## Stage 7 확정 대상 (Human 결정)

이 절의 ① ~ ⑥ 은 Stage 6 검증 후 Stage 7 에서 Human 이 채운다.

아래 여섯 항목은 **Human 이 Stage 7 에서 결정한다.** 앵커도 Claude Code 도 고르지 않는다. **이 항목들이 결정되기 전에는 Stage 8 을 시작할 수 없다** — ①은 구현 환경 자체이고, ② ~ ④ 는 baseline 이 clean 인지와 직결되며, ⑤ 는 이 변경이 예외로 남는 기록이고, ⑥ 은 이 워크패킷이 권위를 갖는 근거의 해석이기 때문이다.

### ① clean baseline 방식

**B5 승인 / 보류** — `B1` · `B2` · `B3` 은 TestPlan 에 실행 절차가 없어, 선택하면 Stage 5 로 되돌아가 절차를 설계해야 한다 (Stage 6 발견 F-11). 앵커 권고는 **B5** (disposable 컨테이너 + `CHANGELOG` L177 2단계 절차 · 2026-09-23 두 차례 177/177 · 03_Logic B5 절).

```text
결정: ____
```

### ② prototype `0179` 파일 처분

선택지 (03_Logic "Prototype 처분 선택지" 표). **집행 단계는 Stage 10** 이며, 선택된 항목만 Allowed Files C 로 열린다.

| 선택지 | 내용 | 결과 |
|---|---|---|
| **D1** | `sql/_excluded_from_local_replay/` 로 이동 (`0073` 선례) | `CHANGELOG` 에 이동 기록 필요 · 파일이 `sql/migrations` 밖으로 나가 G15 대상에서 빠지고 현재 WARN(`CONTRACT_NOT_FOUND`)이 사라진다 · 현재 DB 의 history `success=t` 행은 그대로 남아 파일 없는 행이 된다 |
| **D2** | 문서 폴더 보존 | `CHANGELOG` 기록 권고 · G15 대상에서 빠짐 · history 행은 D1 과 같이 남는다 · `.sql` 이 docs 에 들어간다 |
| **D3** | 삭제 | `CHANGELOG` 기록 필요(행이 가리킬 파일이 사라진다) · G15 대상에서 빠짐 · untracked 라 git 에 원문이 없어 복구 불가 |

```text
결정: ____
```

### ③ `601513` 과 색인 2행의 처분

대상: `docs/…/601513_Evidence_Containment_Isolate_Tenant_Execute_Revocation.md` (untracked) · `docs/000005_Index_Document_Number.md` 의 601513 행 · `601500_Readme_Operational_Authority_Foundation.md` L104 의 601513 행 (둘 다 tracked · 미커밋). 정규 문서로 승격하지 않는다 (HD-CTN-03). **집행 단계는 Stage 10** 이며, 선택된 항목만 Allowed Files C 로 열린다.

| 선택지 | 결과 |
|---|---|
| 보존 + 색인 2행 유지 | 비권위 문서가 색인에 남아 이후 작업자가 권위 자료로 오인할 여지 · `CHANGELOG` 영향 없음 |
| 보존 + 색인 2행 제거 | tracked 두 파일의 미커밋 수정을 되돌린다 · 문서 자체는 남는다 |
| 이동 (패킷 폴더 등) | 색인 2행 제거 + 경로 변경 기록 필요 |
| 삭제 | untracked 라 복구 불가 · 색인 2행도 함께 제거 |

```text
결정: ____
```

### ④ 현재 local DB 의 prototype 효과를 되돌릴 것인가

되돌리면 `H03-F1` 직접 경로가 local 에서 **다시 열린다** (03_Logic Rollback Rule · `602061` §3.1 L243~256). 되돌리지 않으면 현재 DB 는 prototype 효과를 품은 채로 남는다 (어느 쪽이든 정규 Stage 9 에는 쓰지 않는다). **집행 단계는 Stage 10** 이다 — Stage 8 · Stage 9 는 현재 DB 를 건드리지 않는다 (Forbidden Files 의 조건부 항목).

되돌리기의 구체 절차(무엇을 어떤 순서로 되돌리는가 · `migration_history` 행 처리)는 **Stage 10 에서 정한다. 이 계약은 되돌리기를 허용할지만 정한다.**

```text
결정: ____
```

### ⑤ HD-CTN-02 예외의 영구 기록 위치

Stage 3 결정 IS-6: **E1**(이 계약) + `603000_Readme_Containment.md` 예외 레지스트리 + `600010_Tracker_Spiral_Workpacket_Progress.md` 1행. E2(새 governance 문서)는 보류. Human 이 이 구성을 확정한다. 집행 단계는 Stage 10 (Allowed Files C).

```text
결정: ____
```

### ⑥ `600020` §4 의 적용 범위 해석 (Stage 6 에서 올라온 항목)

`600020` §4 네 요건이 reset 이후 **신규** 워크패킷인 CTN-1a 에도 직접 적용되는가. Stage 6 검증자 둘 다 `UNVERIFIABLE` 로 판정했다 — §1.3(L44~45 「기존 구현 Lifecycle 산출물」)과 §4(L192 「개별 워크패킷 단위로 해제」)의 적용 범위가 문면상 일치하지 않는다. Human 해석이 필요하다.

| 선택 | 결과 | 근거 문서 |
|---|---|---|
| **적용한다** | Source · Order · Validation · Gate 네 요건을 이 워크패킷이 충족했음을 **Stage 10 문서에 기록해야 한다.** Order(prototype `0179` 가 설계보다 먼저 있었고 local 에 적용됐다는 사실)에 대한 **Human 판단도 필요하다** | `600020` §4 L190~201 · L203~207(Order 는 사후 판정이 어렵다) · 02_Overview 「600020 §4 권위 요건 충족 계획」 |
| **적용하지 않는다** | CTN-1a 는 reset 이후 **신규** 워크패킷이므로 §4 해제 절차의 대상이 아니라는 해석을 기록한다. 이 해석은 **이후 신규 워크패킷에도 선례가 된다** | `600020` §1.3 L42~47 (「기존 구현 Lifecycle 산출물」 · 「개별 워크패킷을 무효로 판정한 것이 아니다」) |
| **보류** | Stage 10 에서 다시 판단한다. 단 **그때까지 이 워크패킷의 권위 지위가 미정으로 남는다** | `600020` §1.3 · §4 |

```text
결정: ____
```

## Human Boundary Approval

> 이 절은 **Stage 7 에서 Human 이 채운다.** Claude Code 가 미리 채우지 않는다.

**판독 안내 (Stage 6 처분 F-10)**: `Get-Stage7State` 는 Stage 7 표를 먼저 읽고 즉시 반환한다 (`Check-Governance.ps1` L913~925). 따라서 아래 Decision checkbox 만 체크하면 표의 "대기" 때문에 계속 `PENDING` 이다. `APPROVED` 가 되려면 **표의 상태 셀을 "승인" 또는 "APPROVED" 로 바꿔야 한다.**

| 게이트 | 상태 |
|---|---|
| Stage 7 (Human Approval) | 대기 |

```text
Decision:            [ ] APPROVE   [ ] APPROVE WITH CONDITIONS   [ ] REJECT

Approver:
Timestamp:
Approval Notes:
```

승인과 함께 Human 이 확정하는 것: 위 「Stage 7 확정 대상 (Human 결정)」 절의 ① ~ ⑥ (HD-CTN-03 · ⑥ 은 Stage 6 에서 올라온 해석 항목). 여섯 항목이 모두 채워지기 전에는 Stage 8 을 시작하지 않는다.

## Final Rule

```text
This ChangeContract does not authorize implementation.
It defines candidate future boundaries only.
Codex may implement only after Human Approval explicitly lists allowed files.
```

## Stage 6 Contract Review 반영 (2026-09-25)

Stage 6 계약 검증(Codex F-1 ~ F-14 · Cursor 1 ~ 7)의 처분을 Stage 5 로 loopback 해 반영했다 (`000701` §18). 앵커 판단이며 Human 결정이 아니다.

| 발견 | 처분 | 이 문서에서 바뀐 곳 |
|---|---|---|
| F-1 manifest 기대값 검증 | **해소 (2026-09-25)** | V-CMD-1 에 산출 방식 위치(03_Logic B5)와 바이트 수 18321 추가 |
| F-3 Allowed Files 가 Stage 8 · 9 산출물을 담지 못함 | 수용 | Allowed Files 를 A(Stage 8) · B(Stage 9) · C(Stage 10 · 조건부)로 재구성 |
| F-5 raw log 경로 충돌 | 수용 | A · B 에 `raw_logs/stage8/` · `raw_logs/stage9/` |
| F-10 Stage 7 판독 오해 소지 | 수용 | Human Boundary Approval 에 판독 안내 (`L913~925` · checkbox 만으로는 PENDING) |
| F-11 B1 · B2 · B3 에 실행 절차 없음 | 수용 | Stage 7 ① 을 "B5 승인 / 보류"로 · 다른 선택 시 Stage 5 로 되돌아간다고 명시 |
| F-13 폴더 생성 시점 | 수용 | 「파일 위치와 G15」를 **Stage 10** 으로 · G15 판정도 그 이후 |
| Cursor 3 인용 줄 | 수용 | L971 정규식 · **L977** 첫 5행 읽기 · L979 는 헤더 없음 분기 |
| Cursor 7 history INSERT 가 Allowed Operations 에 없음 | 수용 | Allowed Operations 에 B5 환경 한정 `INSERT` 1행 추가 |
| Stage 7 확정 대상 보강 | 수용 | ② · ③ 에 선택별 결과(CHANGELOG · G15 · history) · ② ③ ④ 집행 단계 **Stage 10** · **⑥ 신규**(`600020` §4 적용 범위 — 검증자 둘 다 `UNVERIFIABLE`) |
| OQ-S6-2 | 종결 | 충돌 없음 — `600023` §6 이 RG 를 `602000~602999` 로 한정 |

## Draft Status

Draft (Claude Code) — Stage 6 Contract Review 반영 2026-09-25 · Stage 6 재검증 대기
