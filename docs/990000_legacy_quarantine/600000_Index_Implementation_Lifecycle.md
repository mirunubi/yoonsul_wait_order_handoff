# 600000_Index_Implementation_Lifecycle.md

This is the primary active index for `docs/600000_implementation_lifecycle/`.
It is the only active navigation index for this folder.

The former `600000_Index_Implementation_Lifecycle_Expansion_Wave_1.md` is not an active index.
It is a historical batch manifest and is archived as:
`609000_archive_review/609001_Archive_Implementation_Lifecycle_Expansion_Wave_1_Manifest.md`.

## Governance Foundation

The active governance foundation document now lives at
`docs/000700_ai_agent_prelearning_and_project_context/000714_Readme_Implementation_Lifecycle_Governance.md`.

The former `600100_readme_governance/` folder (79 unfilled boilerplate documents, plus the
now-relocated governance file) has been dropped to
`docs/990000_legacy_quarantine/600100_readme_governance/`.

| 번호 | 파일명 | 상태 | 역할 |
|---|---|---|---|
| 600179 | Guide_Controlled_AI_Development_Pipeline | Foundation Governance | Cursor impact scope, Claude architecture, Codex limited implementation, local verification, Claude audit, Human merge/release를 통제하는 AI 개발 파이프라인 Foundation |

Runtime implementation: Not granted
SOP promotion: Future decision only

## Source Map Static Validation

### 602100_wp_9b_001_source_module_map_static_validation/

| 번호 | 파일명 | 상태 | 역할 |
|---|---|---|---|
| 602101 | Report_Batch_9F_WP_9B_001_Artifact_Pack_Closeout | Complete | WP-9B-001 artifact pack closeout |
| 602102 | Evidence_WP_9B_001_SMM_001_To_SMM_009_Static_Validation_Result_Packet | PASS-GATE | SMM-001~SMM-009 정적 검증 증거 |
| 602103 | Matrix_WP_9B_001_Source_Module_Map_Static_Validation_Findings_Map | PASS-GATE | Source Module Map 정적 검증 findings map |
| 602104 | Report_Batch_9F_Combined_WP_9B_001_Static_Validation_Full_Closeout | Complete | Batch 9F Combined closeout |

WP-9B-001 Source Module Map Static Validation And Evidence Gate.
Static validation only.
Runtime implementation blocked.
Aggregate gate: PASS-GATE.

## Flutter MVP Foundation Workpacket

Canonical location:

`604000_workpackets/604100_flutter_mvp_foundation/`

| 번호 | 파일명 | 상태 | 역할 |
|---|---|---|---|
| 604101 | Overview_Flutter_MVP_Project_Structure | Draft | Flutter MVP 폴더 구조 / 채널 진입점 / DROP-A~E 모듈 맵 |
| 604102 | Logic_Flutter_MVP_Core_Implementation | Draft | rpc_caller.dart 설계 / INV-001~006 클라이언트 적용 / 세션 복구 |
| 604103 | Module_Flutter_MVP_Foundation_Scaffold_Implementation | Implemented / Pre-Gate Foundation Bootstrap | Foundation 스캐폴드 구현 결과 / INV-004 가드 / dev audit 배선 |
| 604104 | Audit_Flutter_MVP_Foundation_Scaffold_Retrospective_Gate | Planned | 604103 사후 감사 / pre-gate 구현 봉인 |
| 604105 | Module_Flutter_MVP_Foundation_Document_Relocation_And_Index_Cleanup | Implemented / This task | 문서 이동 / 번호 정리 / index cleanup 기록 |

`604104` is planned only and was not created by this cleanup.

## WP-10A-001 Workpacket

### 604200_wp_10a_001_minimal_static_validation_tooling/

| 번호 | 파일명 | 상태 | 역할 |
|---|---|---|---|
| 604201 | Report_Batch_10A_Runtime_Stack_Decision_And_First_Real_Implementation_Lane_Selection | Decision Only | 첫 실제 구현 진입로 결정 / Minimal Python static validation tooling lane 선택 |
| 604202 | Report_Batch_10B_WP_10A_001_Implementation_Authorization_Packet | Authorization Only | Batch 10C에서 허용될 정확한 파일 목록과 명령 경계 정의 |

WP-10A-001 Minimal Static Validation Tooling For Hydration Registry And Source Module Map.
Status: Authorization only.
Tooling creation not yet executed.
Runtime implementation: Not granted.

## Scope D Server Runtime Guard Workpacket

Canonical location:

`604000_workpackets/604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/`

| 번호 | 파일명 | 상태 | 역할 |
|---|---|---|---|
| 604300 | Index_Scope_D_Server_Runtime_Guard | Active | Scope D master documentation pack navigation and authorization boundary |
| 604301 | Overview_Scope_D_Server_Runtime_Guard | Complete | Scope D server runtime guard master overview |
| 604302 | Logic_Scope_D_Server_Runtime_Guard | Complete | Scope D master logic |
| 604303 | TestPlan_Scope_D_Server_Runtime_Guard | Complete | Scope D master test obligations and mapping |
| 604304 | ChangeContract_Scope_D_Server_Runtime_Guard | Complete | Scope D master change boundary and authorization contract |
| 604306 | 604306_NavigationMap_Scope_D_Server_Runtime_Guard_Workpacket_Flow.md | Active | Scope D reading, dependency, handoff, audit, and error-backtracking route |

Master documentation pack completed. Runtime implementation and sub-workpacket implementation are not authorized.

### 604250 Scope D 00: PaymentLedger / ConfirmPayment Schema Drift Alignment

Canonical location:

`604000_workpackets/604250_scope_d_00_payment_ledger_confirm_payment_schema_drift_alignment/`

| 번호 | 파일명 | 상태 | 역할 |
|---|---|---|---|
| 604250 | 604250_Index_Scope_D_00_PaymentLedger_ConfirmPayment_SchemaDrift_Alignment.md | Active | Slice navigation and authorization boundary |
| 604251 | 604251_ImpactScope_Scope_D_00_PaymentLedger_ConfirmPayment_SchemaDrift_Alignment.md | Complete | Impact scope; Claude-verified |
| 604252 | 604252_Overview_Scope_D_00_PaymentLedger_ConfirmPayment_SchemaDrift_Alignment.md | Complete | Slice overview |
| 604253 | 604253_Logic_Scope_D_00_PaymentLedger_ConfirmPayment_SchemaDrift_Alignment.md | Complete | Slice logic |
| 604254 | 604254_TestPlan_Scope_D_00_PaymentLedger_ConfirmPayment_SchemaDrift_Alignment.md | Complete | Slice test plan |
| 604255 | 604255_ChangeContract_Scope_D_00_PaymentLedger_ConfirmPayment_SchemaDrift_Alignment.md | Complete | Slice change contract |

604250 Scope D 00 PaymentLedger / ConfirmPayment Schema Drift Alignment is a precondition slice for 604310.
604250 must close before 604310 implementation approval.
604316 Human Approval for 604310 remains deferred.

### 604260 Scope D 00A: Toss MVP PaymentIntent Binding Precondition

Canonical location:

`604000_workpackets/604260_scope_d_00a_toss_mvp_payment_intent_binding_precondition/`

| 번호 | 파일명 | 상태 | 역할 |
|---|---|---|---|
| 604260 | 604260_Index_Scope_D_00A_Toss_MVP_PaymentIntent_Binding_Precondition.md | Active | Slice navigation and authorization boundary |
| 604261 | 604261_ImpactScope_Scope_D_00A_Toss_MVP_PaymentIntent_Binding_Precondition.md | Complete | Impact scope; Claude-verified |
| 604262 | 604262_Overview_Scope_D_00A_Toss_MVP_PaymentIntent_Binding_Precondition.md | Complete | Slice overview |
| 604263 | 604263_Logic_Scope_D_00A_Toss_MVP_PaymentIntent_Binding_Precondition.md | Complete | Slice logic |
| 604264 | 604264_TestPlan_Scope_D_00A_Toss_MVP_PaymentIntent_Binding_Precondition.md | Complete | Slice test plan |
| 604265 | 604265_ChangeContract_Scope_D_00A_Toss_MVP_PaymentIntent_Binding_Precondition.md | Complete | Slice change contract |

604260 Scope D 00A Toss MVP PaymentIntent Binding Precondition is a blocking precondition discovered during 604250 implementation.
604260 must close before 604250 implementation can resume.
604250 must close before 604310 implementation approval.

### 604310 Scope D Slice 01: Payment Confirm Idempotency

Canonical location:

`604000_workpackets/604400_scope_d_01_payment_confirm_idempotency/`

| 번호 | 파일명 | 상태 | 역할 |
|---|---|---|---|
| 604404 | 604404_Index_Scope_D_01_Payment_Confirm_Idempotency.md | Active | Slice navigation and authorization boundary |
| 604405 | 604405_ImpactScope_Scope_D_01_Payment_Confirm_Idempotency.md | Pre-Implementation | Impact scope |
| 604406 | 604406_Overview_Scope_D_01_Payment_Confirm_Idempotency.md | Pre-Implementation | Slice overview |
| 604407 | 604407_Logic_Scope_D_01_Payment_Confirm_Idempotency.md | Pre-Implementation | Slice logic |
| 604408 | 604408_TestPlan_Scope_D_01_Payment_Confirm_Idempotency.md | Pre-Implementation | Slice test plan |
| 604409 | 604409_ChangeContract_Scope_D_01_Payment_Confirm_Idempotency.md | Pre-Implementation | Slice change contract |

Runtime and Codex implementation are not authorized until Human-approved `604316` exists.

## Folder Structure

| 폴더 | 역할 |
|---|---|
| 601000_olm_model/ | Overview / Logic / Module 템플릿 |
| 602000_source_map/ | Source Module Map, dependency map, static validation evidence, source-to-module traceability 관련 문서를 둔다. |
| 603000_ai_handoff/ | AI 도구 핸드오프 지시어 |
| 604000_workpackets/ | 실제 구현 단위 묶음. Overview / Logic / TestPlan / ChangeContract / Module / Audit 문서는 개별 workpacket 하위 폴더에 둔다. |
| 605000_pos_gateway_package/ | POS Gateway 구현 패키지. `605100_core_flows/`와 `605200_read_only_dry_run/`만 현재 위치에 남아 있다. `605300_authorization_execution/`부터 `605900_final_closeout_archive/`까지는 `docs/990000_legacy_quarantine/605000_pos_gateway_package/`로 이동되었다. |
| 605100_core_flows/ | 결제 핵심 흐름 |
| 605200_read_only_dry_run/ | 구현 전 검증 |
| 606000_evidence_diff/ | 구현 증거 diff |
| 607000_repair_closeout/ | 수리 클로즈아웃 |
| 608000_release_gate/ | Scope 통과 조건 |
| 609000_archive_review/ | Historical manifests, retrospective reviews, archived batch indexes, and post-closeout review records. |

`600100_readme_governance/` was dropped to `docs/990000_legacy_quarantine/600100_readme_governance/`; its one non-boilerplate document now lives at `000714_Readme_Implementation_Lifecycle_Governance.md` (see Governance Foundation above).

## Controlled Implementation Gate

```text
1. Cursor Impact Scope
   - 영향 파일 검색
   - dependency / import / route / SQL / RLS / test 위치 확인
   - 절대 수정 금지
   - Output: impact_scope.md

2. Claude Architecture
   - overview.md
   - logic.md
   - test_plan.md
   - change_contract.md
   - 위험 분석
   - 허용/금지 파일 목록
   - rollback 기준

3. Claude + Human Approval
   - overview / logic / test_plan / change_contract 검증
   - 허용 파일 확정
   - “이 파일만 고쳐라” 승인
   - Output: implementation_approval.md

4. Codex Implementation
   - 제한된 파일만 구현
   - 작은 diff 유지
   - 불필요한 리팩토링 금지
   - Output: implementation_module.md

5. Local Automated Verification Gate
   - lint / typecheck / test / migration dry-run / RLS/security check
   - idempotency / duplicate / unknown-state test
   - Output: verification_result.md

6. Claude Audit
   - implementation_module.md + verification_result.md + git diff 검토
   - 설계 대비 코드 검토
   - 금융 사고 반례 검토
   - 감사로그 / 권한 / rollback / evidence 확인
   - Output: audit_review.md

7. Human Merge / Release
   - diff 직접 확인
   - commit
   - merge
   - release evidence 남김
```

Module 파일이 없으면 구현 완료로 인정하지 않는다.
이 Index에 등록되지 않은 파일은 공식 문서가 아니다.

## Root Placement Rules

- Do not place implementation workpacket documents directly under `600000_implementation_lifecycle/` root.
- Do not create another `600000_*` active index file in this folder.
- Keep `600000_Index_Implementation_Lifecycle.md` as the sole active index.
- Historical manifests must be moved to `609000_archive_review/` with a unique prefix.
- Governance foundation documents belong under `600100_readme_governance/`.
- Source Module Map static validation documents belong under `602000_source_map/`.
- Flutter MVP Foundation documents belong under `604000_workpackets/604100_flutter_mvp_foundation/`.
- WP-10A-001 static validation tooling authorization documents belong under `604000_workpackets/604200_wp_10a_001_minimal_static_validation_tooling/`.
- POS Gateway implementation package documents remain under `605000_pos_gateway_package/`.
