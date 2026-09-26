# Overview.md — CTN-1a

Change ID: ctn1a_isolate_tenant_execute_containment (Stage 3 확정 — 2026-09-22)
Status: Draft
Draft Status: Verified (Claude) — Stage 3 검토 반영 2026-09-22
Stage: 000701 Stage 2 Design Draft
Written: 2026-09-22

> 구속력 없음. Stage 3 에서 Claude(앵커)가 검토한다.
> 비권위 자료(`602060` · `602061` · `601513` · prototype `0179`)는 §0 발견 경위의 사실 인용에만 쓴다.

## §0 발견 경위 (Stage 0 사실)

형식을 갖춘 Stage 0 Issue Record 는 없다 (`000701` L112 「Issue Record (선택, 형식 자유)」). 발견 사실은 RG-06 Impact Scope `602061` 에 있다. `602061` 은 커밋 `8c86a4d` (2026-09-21 14:50 KST) 로 들어갔다.

| # | 사실 | 근거 |
|---|---|---|
| 0-1 | `602061` §3.1 `H03-F1` — VERIFIED · BLOCKER. 「`catchmenu_common.isolate_tenant` 가 타 tenant 의 lifecycle 을 바꾼다」 | `602061` L243~245 |
| 0-2 | 재현 방식: `set local role authenticated` · JWT claims tenant `…00aa` · `select catchmenu_common.isolate_tenant('1111...1111','probe',false,null,'ko');` → `ERROR: cannot execute UPDATE in a read-only transaction` (본문 line 22 도달) | `602061` L247~256 |
| 0-3 | `p_isolate=false` 는 `tenant_status` 를 `'ACTIVE'` 로 덮는다 — RG-04(`0177`) lifecycle gate 우회 가능 | `602061` L274~276 |
| 0-4 | §3.4: named-arg `p_reason := 'x'` 호출 → `42883` 계열 `does not exist`. `p_isolation_reason` 으로 바꾸면 본문 진입 | `602061` L383~391 |
| 0-5 | **금지 호출 기록**: 0-2 (L250) · 0-4 (L383 · L390) 는 이 Claude Code 세션이 실행한 `isolate_tenant` 호출이다. `601505` §4.1.1 L311~314 는 「수동 SQL, 테스트 스크립트 전부를 포함」해 모든 호출을 금지한다. read-only 트랜잭션이어서 쓰기는 없었지만 호출은 일어났다. 절차 위반 finding 등록은 미완 (OQ-OV-7) | `602061` L250 · L383 · L390 · `601505` L311~314 |
| 0-6 | 이후 이 세션이 prototype `0179` 를 local DB 에 적용했다 (`migration_history` applied_at `2026-09-21 11:15:56.588353+00`) — HD-CTN-03 이 prototype · discovery material 로 분류 | `catchmenu_meta.migration_history` 원출력 (01_ImpactScope "Migrations") |
| 0-7 | HD-CTN-04 가 `H03-F1` 의 수정 소관을 RG-06 에서 CTN-1a 로 옮겼다 | 아래 Human Decision |

## Change ID

`ctn1a_isolate_tenant_execute_containment` — 제안 근거는 01_ImpactScope P-1.

## Human Decision (원문 · Human 층)

아래는 Human 결정 원문이다. Claude Code 의 판단이 아니다.

```text
【Human Approved — 2026-09-22 09:41 KST】
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
【운영 결정 — Human, 2026-09-22】
  Antigravity 는 모든 Stage 에서 제외
  Critical tier 검증: Stage 4 · 6 = Cursor + Codex / Stage 9 = Claude Code + Cursor
  문서 · 보고서 작성 지시의 수행 주체는 Codex (Cursor 는 검증 참여만)
```

승인 시각: 2026-09-22 09:41 KST (Stage 2 지시문 기재).

### 앵커 판단과의 구분

이 문서의 나머지 절(해석 · 선택지 · 기울기)은 Claude Code 초안이다. Human 결정의 범위를 넓히거나 좁히지 않는다. Stage 3 앵커 판단은 문서 끝 "Stage 3 Review (Claude 앵커)" 절에 있으며, Human 결정이 아니다.

## HD-CTN-02 는 `601505` §8A.2 의 "금지 해제"가 아니다 — 근거

| # | 사실 | 근거 |
|---|---|---|
| X-1 | §8A.2 가 해제 대상으로 적은 조항은 §4.1.1(호출 금지) · §4.3(ACTIVE 승격 금지) · §4.5(신규 호출자 배포 금지) 셋뿐이고, 해제 조건은 「0-A-2 검증 통과 + 별도 Human 판단」이다 | `601505` L840~841 |
| X-2 | HD-CTN-02 가 가리키는 조항은 §4.4 와 `600020` HOLD 다. §4.4 는 §8A.2 해제 목록에 없다 | HD-CTN-02 원문 · L840 |
| X-3 | HD-CTN-02 는 호출을 허용하지 않는다. 직접 호출 주체를 줄인다 — §4.1.1 의 취지(「어떤 경로로도 호출되어서는 안 된다」 L311)와 같은 방향이다 | L311 · HD-CTN-02 「허용: … 회수만」 |
| X-4 | HD-CTN-02 는 0-A-2 · 0-C 재개방을 금지한다. 0-A-2 가 끝나지 않았으므로 §8A.2 의 해제 조건은 성립할 수 없다 | HD-CTN-02 「금지」 · `601505` §10 L968 Stage 7 대기 |
| X-5 | §4.1.1 · §4.3 · §4.5 의 현재 효력은 `600020` §1.5 L98 이 유지한다. HD-CTN-02 는 이 셋을 해제한다고 적지 않았다 | `600020` L98 |

따라서 이 초안은 HD-CTN-02 를 승인된 대로 **"좁은 containment exception"** 으로 적는다.

### Stage 3 보정 — §4.4 의 현행 효력 (2026-09-22)

`600020` L98 이 효력을 유지한다고 적은 `601505` §4 조항은 셋이다.

```text
98: `601505` §4의 금지 조항(호출 금지·`ACTIVE` 승격 금지·신규 호출자 배포 금지)은 계속 유효하다.
```

즉 §4.1.1 · §4.3 · §4.5 다. §4.4 는 이 목록에 없다.

`000221` L499 는 `601505` §4 전체를 권위 보류로 분류한다.

```text
499: | `601505` §4 · §8A | 호출 금지 조항 · 순서 — 권위보류. evidence 로만 인용 |
```

따라서 §4.4 는 위 두 해석 중 어느 쪽이든 이 변경을 막는 **현행 효력이 없다.** 해석 판정은 불필요하다 (OQ-OV-1 결정).

그럼에도 HD-CTN-02 는 승인 문구 그대로 **"좁은 containment exception"** 으로 기록한다 (보수적 기록). 그리고 이 변경은 효력이 유지되는 §4.1.1 을 해제하지 않고 **집행하는** 방향이다 — 직접 호출 주체를 줄인다.

### `601505` §4.4 원문 (L394 · L403)

```text
394: ### §4.4 그 밖의 금지
402: | `CREATE OR REPLACE FUNCTION` **일체** | 본 워크패킷은 DDL 전용. **0169도 함수를 만들지 않는다**(§1.5.1) |
403: | **`ALTER FUNCTION … OWNER TO` / `REVOKE … FROM PUBLIC` / `GRANT EXECUTE` / `SET search_path`** | 대상 함수가 존재하지 않는다. **0-C 필수 규칙**(`601503` §9)으로 이월 |
```

두 해석 (판정하지 않음):

| | 해석 1 | 해석 2 |
|---|---|---|
| 내용 | §4.4 L403 은 0-A 가 **새로 만들 함수**에 대한 금지다. 이유가 「대상 함수가 존재하지 않는다」이므로, 이미 있는 `0090` `isolate_tenant` · `0121` `detect_threat` 는 적용 대상이 아니다 | §4.4 L403 은 함수 ACL 변경 **일반**을 0-C(`601503` §9)로 이월한 금지다. 이번 변경은 그 금지의 예외다 |
| 이 해석에서 HD-CTN-02 의 역할 | §4.4 에 대해서는 확인적 · `600020` HOLD 에 대한 예외가 중심 | §4.4 와 `600020` HOLD 둘 다에 대한 예외 |
| 문면 단서 | L403 이유 문장 · L402 가 「본 워크패킷은 DDL 전용」으로 워크패킷 범위를 말함 | L403 이 "0-C 필수 규칙으로 이월"이라고 적음 · `601902` §5 L1081 이 EXECUTE ACL 을 정하지 않은 항목으로 둠 |

어느 해석이든 HD-CTN-02 는 이 변경을 허용한다. 해석은 예외를 **어디에 어떻게 기록하는가**(01_ImpactScope P-4)에 영향을 준다 → OQ-OV-1.

## 600020 §4 권위 요건 충족 계획 (Stage 3 추가)

`600020` §1.3 은 600000 대역의 기본 지위를 정한다.

```text
42: ### §1.3 600000 대역 전체 — NON-AUTHORITATIVE BY DEFAULT
44~45: **기존 구현 Lifecycle 산출물은 설계 근거 provenance가 재검증되기 전까지
       정식 설계 근거로 사용하지 않는다.**
47: 이는 개별 워크패킷을 무효로 판정한 것이 **아니다.**
```

§4 는 그 해제 조건을 넷으로 적는다.

```text
190: ## §4 이 판정의 해제 조건
192: §1.3의 NON-AUTHORITATIVE 지위는 다음이 충족될 때 개별 워크패킷 단위로 해제할 수 있다.
196: | Source | 어떤 원천 설계문서를 근거로 했는가 |
197: | Order | 설계·검증이 SQL보다 먼저였는가 |
198: | Validation | 원천 설계 자체의 오류·충돌을 검사했는가 |
199: | Gate | 그 뒤 Stage 7 Approval을 거쳐 구현했는가 |
201: 넷 모두 충족해야 한다. **Approval 하나만으로는 해제하지 않는다.**
```

| 요건 | 이 워크패킷에서 충족하는 단계 · 산출물 | 상태 |
|---|---|---|
| Source | 원천: `010004` §7(fail closed · containment) · Human HD-CTN-02 · 발견 사실 `602061` §3.1. 기록 위치: 02_Overview §0 · §46 근거 문서 목록 · 01_ImpactScope 의 Required Context Snapshot Candidates 절 | 계획됨 |
| Order | 설계(Stage 2 · 3) → 계약(Stage 5) → 승인(Stage 7) → 구현(Stage 8) 순서. 정규 migration `0180` 은 승인 뒤에 작성한다 (HD-CTN-03). 다만 prototype `0179` 가 설계보다 먼저 있었고 local 에 적용됐다는 사실이 남는다 — 이 사실이 Order 요건 판정에 어떻게 들어가는지 | **Open Question for Stage 6 (OQ-S6-1 과 함께 본다)** |
| Validation | Stage 3 보정(위 「§4.4 의 현행 효력」 · `000221` L499) · Stage 4 아키텍처 검증(Cursor + Codex) · Stage 6 계약 검증 · 01_ImpactScope "Codex Scan Corrections" C-1 ~ C-18 | 일부 완료 · 나머지 계획됨 |
| Gate | Stage 7 Human Approval → ChangeContract 의 Stage 7 기록 → G15 가 `Workpacket: 603010` 으로 그 계약을 찾는다 (폴더 생성 · 이동은 **Stage 10** · G15 판정도 그 이후 — Stage 6 처분 F-13) | 계획됨 |

`600020` §4 는 Order 에 대해 「사후 판정이 어려운 항목」이며 기존 워크패킷은 「참고자료로 열람하되 근거로 인용하지 않는 것」을 원칙으로 하고 필요한 내용은 재도출하라고 적는다(L203~207). 이 워크패킷은 Stage 2 지시대로 prototype 과 권위 보류 문서를 근거로 쓰지 않고 migration 원문 · 정책 문서 · live 카탈로그에서 다시 도출했다.

- **OQ-S6-1 (Stage 6)**: `600020` §4 는 "기존 워크패킷의 NON-AUTHORITATIVE 지위 해제" 조건이다. 새로 만드는 CTN-1a 에 이 네 요건을 그대로 적용하는 것이 맞는지, 아니면 이 워크패킷은 애초에 §1.3 대상이 아닌지 (§1.3 문면은 「기존 구현 Lifecycle 산출물」을 대상으로 한다).

## Business Purpose

`authenticated` JWT 한 개로 다른 tenant 의 lifecycle 을 바꿀 수 있는 직접 진입점(0-1 ~ 0-3)을 닫는다. 최종 caller-authorization 설계(0-C)가 올 때까지의 임시 containment 다 (HD-CTN-02 「성격」).

## User / Store / Provider Impact

- 앱: 두 함수의 직접 참조 0 (`grep -rln` 출력 없음). 앱이 이 두 함수를 부르는 경로는 없다.
- 운영자 수동 호출: 금지 상태 유지(`601505` §4.1.1). 변화 없음.
- Provider(POS · PG · VAN · Bank): 직접 영향 없음. `record_van_transaction` 은 DEFINER 로 계속 `detect_threat` 를 부른다.

## Financial Impact Class

직접 금전 이동 없음. 간접: tenant lifecycle(`catchmenu_hq.tenants.tenant_status`) 오염이 주문 수락(RG-04 `0177`)에 미치는 경로를 직접 호출 쪽에서 닫는다.

## Affected Domains

DB 권한(ACL) · Audit/Evidence(migration_history) · Governance(예외 기록)

## Affected Files From Claude Code

01_ImpactScope "Candidate Affected Files" 참조. 요약: 새 migration 1개 · Stage 5 ChangeContract/TestPlan · 예외 기록 문서 · (Stage 10) 색인. 기존 migration 수정 없음.

## Context Snapshot Used

01_ImpactScope 의 Required Context Snapshot Candidates 절과 아래 §6.5.

## Non-Goals

HD-CTN-02 금지 목록 전부:

1. 두 함수 **본문** 변경
2. **signature** 변경
3. **`p_reason`** 인자명 불일치 수정 (`601505` §8.1 Open Item (p) 본문 L764 · §8A.2)
4. **wrapper** 함수 추가
5. **새 authority model** — HD-CTN-02 원문은 「새 authority model」까지다. 그 내용이 무엇인지는 `601902` §5 L1081 이 미결정 항목으로 적은 「role ID · approver 수 · EXECUTE ACL」을 가리킨다 (Stage 4 정정 · Cursor 4 — 이전 초안의 괄호 부연은 HD-CTN-02 원문에 없다)
6. **`service_role` grant**
7. **간접 경로 복구** — DEFINER 상위 호출자 5개 경로를 살리거나 고치지 않는다
8. **0-A-2 재개방** (`isolate_tenant` 재작성 · phantom · ACTIVATE)
9. **0-C 재개방** — 0-C 최종 caller-authorization 설계를 대체하지 않는다

그리고:

10. 간접 경로 **차단** 도 이번 범위가 아니다 (CTN-1b 후보)
11. `42883` 방벽을 고치지도 · 없애지도 않는다
12. `detect_threat` 연동 활성화 없음 (`601505` §8A.1 L828)

## Expected Behavior

적용 후 두 함수의 직접 EXECUTE 는 owner `postgres` 만 가진다. 역할별 행렬 · 불변 조건은 03_Logic.

## Out Of Scope

- cloud (`upzthfwhtvazfftxnyfu`) 적용 — 이번 지시에 없음. cloud 는 별도 도구(`tools/apply_migrations_cloud.py`, `600301` L7)
- `000701` Antigravity 문면 동기화
- `602061` 절차 위반 finding 등록 (별도)

## Risk Summary

1. 간접 경로(DEFINER 5개)는 열린 채로 남는다. `isolate_tenant` 간접 호출 3개를 막는 것은 `42883` 뿐이다.
2. 정규 구현은 clean 0178 baseline 이 필요하다. 순수 번호순 재생은 지금도 `0093` 에서 `23514` 로 실패한다 (2026-09-23 실측). `CHANGELOG.md` L177 의 2단계 절차로는 두 차례 모두 177/177 성공 · `0178` 도달했다. 따라서 앵커는 clean baseline 을 B5 절차(03_Logic)로 만들 것을 권고한다 — 확정은 Stage 7 (HD-CTN-03). 남는 위험은 baseline 재현 가능성이 아니라, 재현에 문서화된 2단계 절차가 필요하다는 사실 자체다 (별도 finding `F-REPLAY` — 01_ImpactScope).
3. untracked prototype 이 `sql/migrations` 에 있는 한 `apply_migrations.py` 가 집는다 (L91).
4. 예외 기록 위치가 정해지지 않으면 이후 0-A-2 · 0-C 작업자가 예외를 모르고 지나칠 수 있다.

## §6.5 Required Context Snapshot Candidates (`000701` §42)

### 1. Master Anchor

- HD-CTN-01 ~ HD-CTN-04 · 운영 결정 (2026-09-22 09:41 KST)
- `600020` §1 (L19 AUTHORITY SUSPENDED · L98 금지 효력 유지)
- `000701` (Full tier 절차)

### 2. Full Rules Required

| 문서 | 범위 | full-read 이유 |
|---|---|---|
| `601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` | §4.1.1 · §4.1.2 · §4.3 · §4.4 · §4.5 · §8.1(p) · §8A.1 · §8A.2 · §10 | 예외의 대상과 해제 규칙 |
| `601503_Logic_…_Ddl.md` | §9 | §4.4 L403 이 이월한 0-C 규칙 |
| `601902_Register_Stage1_Business_Rules.md` | §0.3 · §5 | EXECUTE ACL 미결정 상태 |
| `600020_Governance_Implementation_Lifecycle_Authority_Reset.md` | §1 · §4 | HOLD 와 해제 조건 |
| `600023_Governance_Runtime_Gate_Spiral.md` | §2 · §4 · §6 | RG 와 분리 · 대역 |
| `000221_Guide_Post_0A_Spiral_Sequence.md` | §4.1 · L499 | 601505 §4 권위 보류 |
| `010004_Policy_SaaS_Tenant_Isolation_…` | §7 | fail closed 원칙 |
| `000701` | §3 · §6.5 · §8.5~§8.10 · §14.5 · §37 · §42 · §44 · §46 | 절차 |
| `000001` · `000002` · `000015` | §5.4 · §5.10 / §1.1 · §2.1 / 전체 | 문서 규격 |
| `0090` · `0112` · `0121` · `0130` · `0131` | 정의 · ACL · 호출부 | 적용 전 상태 도출 |
| `tools/apply_migrations.py` · `tools/Check-Governance.ps1` G15 | 전체 · L879~1023 | baseline · G15 |

파일명만 언급(full-read 아님): `601920` · `601801` · `601512` · `604278` · `600311` · `602010` §7.4.

### 3. Domain Indexes

- `601500_Readme_Operational_Authority_Foundation.md` · `601900_Readme_Tenant_Isolation_Axis_V2.md` · `602000_Readme_Runtime_Gate.md` · `601200_Readme_Caller_Authorization_Foundation.md`
- `000005_Index_Document_Number.md` · `000007_Map_Full_Directory.md` · `600000_Readme_Implementation_Lifecycle.md` · `600010_Tracker_Spiral_Workpacket_Progress.md`
- `sql/migrations/CHANGELOG.md`

### 4. Excluded Rule Families

| 제외 | 이유 |
|---|---|
| `602060` · `602061` · `601513` · prototype `0179` | 비권위 — §0 사실 인용에만 |
| `601800` 대역 판정 (`601801` 등) | `600021` 권위 보류 |
| 0-C caller-authorization 설계 | HD-CTN-02 재개방 금지 |
| 0-A-2 재작성 규칙 | HD-CTN-02 재개방 금지 |
| payment · KDS · order runtime gate | 두 함수 ACL 과 직접 무관 |
| Flutter UI 규칙 | 앱 직접 참조 0 |
| Antigravity 병행 규정 (`000701` L3047~3088 등) | 운영 결정으로 제외 · 동기화는 범위 밖 |

애매: `601920` (SECURITY DEFINER inventory, `NOT VERIFIED` 표시) — Full Rules 인지 참조인지 → OQ-OV-5.

## §46 근거 문서 목록 (Stage 1 Codex 조사 기반)

### Stage 1 이 찾은 문서

| 문서 | 사용 | 비고 |
|---|---|---|
| `000001_Md_Rules.md` | 참고 | §1 · §5 · §5.4.2 L162 · §5.10 L444 |
| `000002_Naming_Rules.md` | 참고 | §1.1 · §1.2 · §2.1 |
| `000015_Korean_Document_And_Encoding_Safety_Rules.md` | 참고 | 인코딩 |
| `000701_Guide_Controlled_AI_Development_Pipeline.md` | 참고 | 절차 전체 |
| `601505_ChangeContract_…_Ddl.md` | 참고 | 권위 보류 문서 — 금지 조항 원문 확인용 |
| `601902_Register_Stage1_Business_Rules.md` | 참고 | §0.3 · §5 |
| `600020_Governance_…_Authority_Reset.md` | 참고 | Master Anchor |
| `600023_Governance_Runtime_Gate_Spiral.md` | 참고 | §2 · §4 · §6 |
| `010004_Policy_SaaS_Tenant_Isolation_…` | 참고 | §7 |
| `000221_Guide_Post_0A_Spiral_Sequence.md` | 참고 | L215~216 · L499 |
| `602000_Readme_Runtime_Gate.md` | 참고 | §5 RG-F2 · RG-F15 |
| `601920_Evidence_Security_Definer_Inventory.md` | 참고 | L67 · L105 |
| `601801_Register_Stage1_Business_Rules.md` | 배제 | `600021` 권위 보류 — 사실 위치만 확인 |
| `601500_Readme_Operational_Authority_Foundation.md` | 참고 | 배너 · §5 L143 |
| `601512_Baseline_Summary.md` | 배제 | 배너로 §2 효력 정지 — 이번 판단에 불필요 |
| `601900_Readme_Tenant_Isolation_Axis_V2.md` | 참고 | Domain Index |
| `000000_Readme_Root.md` · `000005` · `000007` | 참고 | 색인 · cloud ref L16 |
| `sql/migrations/CHANGELOG.md` | 참고 | L167~181 |
| `604278_Verification_…_Replay_Baseline_Blockers.md` | 참고 | clean replay 선례 (legacy) |
| `600311_Overview.md` | 참고 | cloud replay — clean local 증거 아님 |
| `601034` · `601422` · `601430` (Antigravity 검색 결과) | 배제 | 워크패킷 단위 검증자 구성 — 전역 결정 아님 |
| `601502` · `601503` ~ `601511` (명명 선례) | 참고(형식만) | 권위 보류 — 형식 선례로만 |
| `601710` · `601713` · `601716` · `601717` · `601722` · `601740` · `601743` | 참고(형식만) | 명명 · Change ID 선례 |
| `601809` ~ `601815` | 참고(형식만) | 명명 선례 · 권위 보류 |
| `implementation_evidence/order_sessions_customer_id_fk_and_guest_promotion/DesignPack.md` · `TestAndContract.md` | 참고(형식만) | CHANGE_ID 선례 |
| `602060_Evidence_RuntimeGate_Ownership_Chain_Tenant_Consistency.md` | 배제 | 비권위 · untracked |
| `602061_Report_RuntimeGate_Ownership_Chain_Impact_Scope.md` | §0 사실만 | 비권위 |
| `601513_Evidence_Containment_Isolate_Tenant_Execute_Revocation.md` | 배제 | 이 세션의 prototype — 재사용 금지 |

### Stage 2 가 더한 문서

| 문서 | 사용 | 이유 |
|---|---|---|
| `601503_Logic_…_Ddl.md` §9 | 참고 | §4.4 이월 대상 |
| `600021_Governance_Tenant_Isolation_Axis_Authority_Reset.md` | 참고 | 601800 권위 보류 근거 |
| `600000_Readme_Implementation_Lifecycle.md` · `600010_Tracker_…` | 참고 | Domain Index |
| `601200_Readme_Caller_Authorization_Foundation.md` | 참고 | 0-C 소관 — 재개방 금지 확인 |
| `602010_…` §7.4 | 참고 | 회귀 검증 도구 선례 |
| `600300_Readme_Cloud_Local_Migration_Sync.md` · `600301_ChangeHistory.md` | 참고 | cloud 적용 경로 분리 |

## Open Questions For Claude

- OQ-OV-1 `601505` §4.4 L403 해석 1 · 해석 2 중 어느 쪽인가. 결과에 따라 예외 기록 문면(01_ImpactScope P-4)이 달라진다. — **결정: 판정 불필요 (Stage 3).** §4.4 는 `600020` L98 의 유지 목록에 없고 `000221` L499 가 §4 전체를 권위 보류로 분류하므로 현행 효력이 없다. 위 「Stage 3 보정 — §4.4 의 현행 효력」 참조
- OQ-OV-2 HD-CTN-02 가 `600020` §4 L190 의 해제 조건(4요건)과 어떤 관계인가 — 해제가 아닌 예외로 적는 것으로 충분한가. — **결정: 위 「600020 §4 권위 요건 충족 계획」 절로 정리 (Stage 3).** 네 요건의 충족 단계를 표로 적고, Order 요건과 적용 대상 여부는 Stage 4 로 넘긴다
- OQ-OV-3 Stage 0 Issue Record 를 형식 문서로 남길 것인가, `602061` §3.1 인용으로 충분한가. — **결정: Overview §0 으로 충분 (Stage 3)**
- OQ-OV-4 cloud 적용 여부 · 시점 (이번 지시에 없음). — **결정: 이 워크패킷 밖. Human 정보 대기 (Stage 3)**
- OQ-OV-5 `601920` 의 분류 (§6.5 애매 항목). — **결정: 참조(파일명만) (Stage 3)**
- OQ-OV-6 Critical tier 로 지정할 것인가 (운영 결정은 Critical 구성만 정함 — tier 결정은 Stage 3). — **결정: Critical tier 확정 (Stage 3).** 근거: DB migration · ACL 보안 경계 · cross-tenant 경로 (`000701` §9.5 · §31). Stage 4 · 6 = Cursor + Codex / Stage 9 = Claude Code + Cursor
- OQ-OV-7 `602061` L250 · L383 · L390 금지 호출의 절차 위반 finding 등록 위치. — **결정: CTN-1a 밖 (Stage 3).** RG-06 정정 묶음에서 `RG-F16` 으로 다룬다
- 01_ImpactScope OQ-IS-1 ~ OQ-IS-8 · 03_Logic OQ-LG-* 참조.

### Stage 6 로 넘기는 Open Question (Stage 4 반영)

- **OQ-S6-1** `600020` §4 네 요건이 새 워크패킷 CTN-1a 에도 적용되는가 (§1.3 문면은 「기존 구현 Lifecycle 산출물」을 대상으로 한다). Order 요건에 prototype `0179` 선행 사실을 어떻게 넣을지도 함께 본다.
- **OQ-S6-2** `603000` 이 `000002` §2.1 의 폴더 번호 대역 소유(`602000` 이 다음 형제 `604000` 직전까지 소유)와 충돌하는가. 대안(`604000` 이후 대역) 검토 포함. — **종결 — 충돌 없음 (Stage 6).** `600023` §6 L264~270 이 Runtime Gate 를 `602000 ~ 602999` 로 한정한다.

## Required Approvals

- Stage 3 Claude 설계 검토 · tier 결정
- Stage 4 · 6 (Critical 이면 Cursor + Codex)
- Stage 7 Human — prototype 처분 · clean baseline 방식 · 번호 · 예외 기록 위치 확정 (HD-CTN-03)
- Stage 9 (Critical 이면 Claude Code + Cursor)

## Draft Status

Verified (Claude) — Stage 4 반영 2026-09-25

## Stage 3 Review (Claude 앵커)

Stage 3 검토 · 결정은 2026-09-22. 본문에 반영된 HD-CTN-06 · SP-4 실측은 그 결정에서 지시한 후속 실측이며 2026-09-23 에 수행됐다.

이 절은 **앵커 판단**이다. Human 결정이 아니다. Human 결정은 위 "Human Decision (원문 · Human 층)" 절에만 있다.

| 항목 | 결정 | 근거 | 반영 위치 |
|---|---|---|---|
| tier | Critical 확정 | DB migration · ACL 보안 경계 · cross-tenant 경로 (`000701` §9.5 · §31) | OQ-OV-6 · Required Approvals |
| OQ-OV-1 | §4.4 해석 판정 불필요 | `600020` L98 유지 목록에 §4.4 없음 · `000221` L499 권위 보류 | 「Stage 3 보정 — §4.4 의 현행 효력」 |
| OQ-OV-2 | 네 요건 충족 계획을 표로 기록 | `600020` §1.3 · §4 | 「600020 §4 권위 요건 충족 계획」 |
| OQ-OV-3 | Overview §0 으로 충분 | `000701` L112 (Issue Record 선택) | OQ 목록 |
| OQ-OV-4 | 워크패킷 밖 · Human 정보 대기 | — | OQ 목록 |
| OQ-OV-5 | `601920` 은 참조(파일명만) | — | §6.5 · OQ 목록 |
| OQ-OV-7 | CTN-1a 밖 — RG-06 정정 묶음 `RG-F16` | HD-CTN-04 | §0 0-5 · OQ 목록 |
| CHANGE_ID | `ctn1a_isolate_tenant_execute_containment` 확정 | 01_ImpactScope P-1 | 머리 · Change ID 절 |
| 워크패킷 | `603000_containment/` 대역 + `603010_ctn1a_isolate_tenant_execute_containment/` | 01_ImpactScope P-2 (후보 B) | 01_ImpactScope P-2 |
| migration | `0180_ctn1a_isolate_tenant_execute_containment.sql` (M1) | 01_ImpactScope P-3 | 01_ImpactScope P-3 · 03_Logic |
| clean baseline | 앵커 권고 B5 · 확정은 Stage 7 (Stage 4 에서 지위 정정 · Cursor 2) | HD-CTN-03 | Risk Summary 2 · 03_Logic B5 |
| 예외 기록 | E1 ChangeContract + `603000` Readme 예외 레지스트리 + `600010` Tracker 1행 (E2 보류) | 01_ImpactScope P-4 | 01_ImpactScope P-4 |
| SP-4 정정 | 앵커가 앞서 "현재 DB 에만 있는 role" 로 적은 추론은 실측(SP-4, 2026-09-23)으로 철회됐다 | SP-4 실측 | 03_Logic 역할 행렬 주석 |

### 2026-09-23 실측으로 PASS 한 것

```text
committed migration 0000 ~ 0178 의 replay 재현성
  (disposable 컨테이너 + CHANGELOG L177 2단계 절차 · 두 차례 177/177)
clean baseline 의 S0 ACL 이 03_Logic 도출값과 일치
clean baseline 의 role parity (catchmenu_authority_owner 는 0169 가 생성)
```

### 아직 PASS 하지 않은 것

```text
CTN-1a 최종 설계 (Stage 4 · 6 검증 전)
TestPlan · ChangeContract (Stage 5)
Human Boundary Approval (Stage 7)
정규 migration 0180 (Stage 8)
Stage 9 독립 검증 · Stage 11 감사
```

"clean baseline PASS" 를 "CTN-1a 가 PASS 했다" 로 읽지 않는다.

## Stage 4 Architecture Review 반영 (2026-09-25)

이 절은 **앵커 판단**이다. Human 결정이 아니다. Stage 4 검증(Codex F-1 ~ F-7 · Cursor 1 ~ 6)을 앵커가 전건 수용했고, 전체 목록은 01_ImpactScope "Stage 4 Architecture Review (2026-09-25)" 절에 있다.

이 문서에서 바뀐 것:

| 발견 | 바뀐 곳 |
|---|---|
| Cursor 4 | Non-Goals 5 의 괄호 부연을 뺐다. HD-CTN-02 원문은 「새 authority model」까지이고, 그 내용은 `601902` §5 L1081 「role ID · approver 수 · EXECUTE ACL」을 가리킨다고 적었다 |
| Cursor 2 | Risk Summary 2 에서 B5 를 "확정" 대신 "앵커 권고 · 확정은 Stage 7 (HD-CTN-03)"로 낮췄다. Stage 3 Review 표에도 같은 행을 넣었다 |
| Cursor 2절 발견 | "01_ImpactScope §6.5" 참조를 "01_ImpactScope 의 Required Context Snapshot Candidates 절"로 고쳤다 (두 곳) |
| Cursor 인용 정정 | Non-Goals 3 의 `601505` §8.1(p) 인용을 절 제목 L762 → 본문 L764 로 고쳤다 |
| Stage 6 이관 | 「600020 §4 권위 요건 충족 계획」의 "Open Question for Stage 4" 표기를 `OQ-S6-1` 로 바꾸고, Open Questions 에 `OQ-S6-1` · `OQ-S6-2` 절을 추가했다 |
