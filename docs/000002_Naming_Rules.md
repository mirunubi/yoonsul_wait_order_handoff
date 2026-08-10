# 000002_Naming_Rules

## 0 Scope

This document applies only to `yoonsul_wait_order_handoff`.

## 1 File Number Prefix Rule

- This project uses six-digit document numbering as the canonical documentation numbering model.
- The six-digit model supports development documentation, SOP namespaces, implementation lifecycle documents, runtime-flow bundles, audit evidence, agent automation, patent packets, reclassification, and legacy quarantine without crowding narrow bands.
- Markdown governance and design files use a six-digit numeric prefix.
- The prefix should reflect the document band and read order.
- Do not reuse a file number for a different purpose inside the same folder.
- File names must start with a numeric prefix inside `docs/`.
- New docs must use six-digit prefixes.
- New docs must not use 5-digit prefixes.
- New docs must not use 4-digit prefixes.
- Existing 5-digit-prefixed files are migration targets and must not be renamed except through an approved migration batch.

## 1.1 Markdown Filename Canonical Format

The canonical Markdown filename format is:

```text
xxxxxx_DocumentType_Title_In_English_Title_Case.md
```

Where:

- `xxxxxx` is the mandatory six-digit numeric prefix.
- `DocumentType` is an approved DocumentType Prefix.
- `Title_In_English_Title_Case` is the English document title with words separated by underscores.
- `.md` is the lowercase Markdown extension.

DocumentType must appear immediately after the numeric prefix.

Correct:

```text
006510_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md
100300_SOP_Entrance_Waiting_Assist_Device_Operation.md
005420_Checklist_First_Store_POS_Equipment_Decision_And_Provider_Procurement.md
```

Wrong:

```text
0006510_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md   <- 7자리, 자릿수 초과
005420_Policy_First_Store_POS_Equipment_Decision_And_Provider_Procurement_Checklist.md   <- DocumentType 중복 (앞 Policy + 뒤 Checklist)
06510 Entrance Waiting Assist Device Policy.md   <- 공백 구분 + 5자리
06510-Policy-Entrance-Waiting-Assist-Device.md   <- 하이픈 구분
06510_Korean_Title_Policy.md   <- DocumentType이 맨 뒤
```

## 1.2 Approved DocumentType Prefix Values

DocumentType values are divided into three groups. See `000001_Md_Rules.md` Section 5.4 for full definitions.

**Group A — General Documents**

- `Readme`
- `Index`
- `Guide`
- `Policy`
- `Spec`
- `Implementation`
- `Boundary`
- `Governance`
- `Diagram`
- `Map`
- `Matrix`
- `Register`
- `Template`
- `Assessment`

**Group B — Execution / Work Documents**

- `Plan`
- `Checklist`
- `SOP`
- `Runbook`
- `Report`
- `Evidence`
- `Audit`
- `ADR`
- `WorkPackage`
- `Closeout`

**Group C — Implementation Lifecycle Only (600000 band)**

- `Overview`
- `Logic`
- `TestPlan`
- `ChangeContract`
- `Approval`
- `Module`
- `Verification`
- `NavigationMap`

Multi-word DocumentType values use PascalCase with no separator (e.g., WorkPackage, ChangeContract, TestPlan, NavigationMap) — capitalize each meaningful word, no underscore between them.

`Audit` remains listed in Group B because it is also used outside implementation lifecycle workpackets. Within the 600000 lifecycle, it is the independent final review type after `Verification`.

**600000 band filename clarification (2026-07-14, CONFIRMED — full §15.1/§33 review plus empirical basename-collision test completed; not open for re-litigation)**: 600000 band files also follow §1.1's full canonical format (`xxxxxx_DocumentType_Title_In_English_Title_Case.md`) — the number-prefix-plus-DocumentType-only shorthand (e.g. `600411_Overview.md`, with no title component) is not a sanctioned exception. Some 600xxx files created before 2026-07-14 exist in that title-less shorthand form; these are **not retroactively renamed** — reference integrity (existing documents, commit messages, and cross-links already point at those exact paths) takes priority over retroactive naming consistency for files created before this clarification. Every 600xxx file created **on or after 2026-07-14** must include the title component without exception.

**Confirmation basis, item 1 — §15.1's "entire band dropped" claim does not match current repository state**: `docs/600000_implementation_lifecycle/` was directly re-verified this turn to be a live, active folder (115 governed files as of 2026-07-14, including this project's entire `600400_kds_did_implementation/` workpacket series) — not dropped, contradicting §15.1's/§22's present-tense claim that this path "is no longer a valid alternative placement." A more precise statement, correcting an earlier oversimplification considered during this review (that only `604xxx` was quarantined): `docs/990000_legacy_quarantine/` was directly checked and does contain both a `600xxx` band (81 files — a distinct earlier meta-governance numbering scheme under `600100_readme_governance/`, e.g. `600101_Overview_Implementation_Lifecycle_Documentation_Readiness_Model.md`) and a `604xxx` band (166 files, the old workpacket-archive numbering). What actually happened is that an **earlier incarnation** of the `600000_implementation_lifecycle/` path (using that different `600100_readme_governance/` meta-governance scheme plus an early `604000_workpackets/` archive layout) was quarantined; the folder path was then **reused** for the current, structurally different, actively-maintained content (`600100_customer_identity_and_guest_promotion/`, `600200_flutter_waiting_feature_implementation/`, `600300_cloud_local_migration_sync/`, `600400_kds_did_implementation/`, plus its own separate, currently-active `604000_workpackets/604500_...`). §15.1 was accurate at the moment the quarantine happened but was never updated to reflect that the path was later reused — it no longer describes current reality.

**Confirmation basis, item 2 — empirical basename-collision test**: directly counted this turn — `docs/600000_implementation_lifecycle/600400_kds_did_implementation/` alone contains exactly **8** files matching `*_Overview.md` and exactly **9** files matching `*_Audit.md` (one per workpacket subfolder, e.g. `600411_Overview.md`, `600911_Overview.md`, `600441_Overview.md`, ... `600417_Audit.md`, `600423_Audit.md`, `600917_Audit.md`, ...). Git tracks these safely by full path with no collision (confirmed no ambiguity at the tooling level) — the risk is human-facing: any chat, log, or commit message that refers to a file by basename alone (`"Overview.md"`, `"Audit.md"`) is ambiguous among 8-9 candidates within this one domain folder, and this ambiguity has concretely occurred multiple times within this project's own session history. This is the practical justification for requiring the title component going forward, independent of Git-level safety.

Correct (from 2026-07-14 onward):

```text
600411_Overview_Kds_Capacity_Gate.md
```

Legacy form (created before 2026-07-14, not retroactively renamed):

```text
600411_Overview.md
```

**Basis for this clarification**: a direct re-read of `000701_Guide_Controlled_AI_Development_Pipeline.md` §15 and §33, and of `000009_Report_Root_Governance_Rules_Correction_Readme_Index_And_Overview_Logic_Module_Model.md`, found no explicit exception permitting a title-less 600xxx `Overview`/`Logic`/etc. filename anywhere in those three documents — see `000054_Assessment_Workpacket_Overview_Logic_Filename_Convention_Governance_Gap.md` for the full re-verification record, including the further finding that §1.2.2 below (the prefix-less `docs/implementation_evidence/<change_id>/<DocumentType>.md` scheme) is this project's current lifecycle-artifact convention as of 2026-07-10, and that the 600000-band six-digit-prefixed form predates and does not match it either. This 2026-07-14 clarification governs 600000-band files specifically; it does not change or supersede §1.2.2's own scheme.

Definitions:

| Group | DocumentType | 판정 기준 |
| --- | --- | --- |
| A | `Readme` | 폴더 진입점. 폴더 역할, 소유 경계, 번호 밴드 설명. 폴더당 1개. |
| A | `Index` | 번호/문서/항목 목록. 중앙 등록 카탈로그. |
| A | `Guide` | 프로젝트/시스템 설명, 온보딩, 선행학습, 사용 지침. 절차 없음. |
| A | `Policy` | 반드시 지켜야 할 규칙, 금지사항, 운영 정책. must/must not 언어 중심. |
| A | `Spec` | 공식 계약, 인터페이스 스펙, 스키마 스펙, 프로토콜 스펙, 이벤트 페이로드 계약. |
| A | `Implementation` | 코드 작성 전 기술 설계. API 행동, 런타임 모델, 데이터 모델, 인터페이스 설계. |
| A | `Boundary` | 시스템 소유권 경계, 통합 경계, 책임 분리. |
| A | `Governance` | 문서 체계, 번호 체계, 명명 표준, 메타 규칙. 체계 자체를 정의. |
| A | `Diagram` | 구조도, 흐름도, 관계도 (텍스트 기반 포함). |
| A | `Map` | 디렉토리 구조, 파일 트리, 시스템 배치 구조. Diagram보다 공간/위치 중심. |
| A | `Matrix` | 매핑 표, 상태 표, 책임 표, 호환성 표. 셀 기반 대응 관계. |
| A | `Register` | 공식 등록부. 코드, 이벤트, 결정, 예외 목록. 인스턴스 등록. |
| A | `Template` | 반복 작성 양식. |
| A | `Assessment` | 평가, 위험 분석, 적합성 분석, 비교 검토. |
| B | `Plan` | 실행 전 계획. 작업 계획, 테스트 계획, 배치 계획. |
| B | `Checklist` | 실행 전후 확인 항목 목록. |
| B | `SOP` | 반복 가능한 운영/시스템 절차. 순서 있는 절차. |
| B | `Runbook` | 장애, 예외, 복구, 운영 대응 절차. |
| B | `Report` | 실행 후 결과, 검증 결과, 배치 closeout 보고. |
| B | `Evidence` | 검증 증거, raw log, 증거 패킷. |
| B | `Audit` | 감사, 독립 리뷰, 컴플라이언스 검토 결과. |
| B | `ADR` | 아키텍처 결정 기록. 결정 시점의 맥락, 선택지, 결정 이유를 보존. |
| B | `WorkPackage` | 구현/검증 작업 묶음 게이트. Plan+Checklist+Evidence 컨테이너. |
| B | `Closeout` | 묶음 종료, 승인, 닫힘 기록. |
| C | `Overview` | 구현 WorkPackage 전 맥락. 어떤 파일을 함께 봐야 하는지. **구현 전용.** |
| C | `Logic` | 구현 변경 로직. 상태 전이, 예외 처리, 권한, 감사 로직. **구현 전용.** |
| C | `Module` | 구현 결과 기록. 소스 파일, 테스트 결과, 롤백 노트. **구현 후 기록.** |
| C | `ChangeContract` | Allowed/forbidden file and operation boundary contract that locks Codex's implementation scope before execution; the Stage 3 human-approval boundary artifact in the controlled AI development pipeline. |
| C | `TestPlan` | Verification and test-scenario coverage plan for an implementation change, defining test scenarios, exception cases, and financial-accident cross-checks before implementation begins. |
| C | `NavigationMap` | Cross-document, cross-workpacket lifecycle flow map showing how stages, documents, and cross-references connect within a bounded scope. Records flow and sequence, not physical file location. |
| A | `Map` | Project- or folder-wide structural map of physical file/directory layout. Records where things live, not how lifecycle stages flow. Distinct from NavigationMap: Map = structure, NavigationMap = flow. |

### 1.2.1 Group C Usage Rule

- `Overview`, `Logic`, `Module`은 코드 구현 WorkPackage 전용입니다.
- 프로젝트 설명, 온보딩, 시스템 설명 문서에는 `Guide`를 사용합니다.
- `Overview`를 일반 설명 문서나 계획 문서에 사용하지 않습니다.
- `Logic` is implementation change logic. It answers: what control logic, data logic, exception logic, permission logic, fallback logic, audit logic, or reconciliation logic will be changed?
- `Module` is an implemented result record. It answers: what was actually implemented, where, with what evidence, tests, risks, and rollback notes?
- `Overview`, `Logic`, and `Module` are independent approved DocumentType values. They must not be treated as subtypes of `Spec`.
- A small implementation or work package may include Overview, Logic, and Module sections inside one governed document when separate files would add unnecessary overhead.
- Core flow, financial, payment, POS, KDS, audit, and security documents should prefer separate Overview, Logic, and Module files when traceability and review evidence matter.

### 1.2.2 Development Lifecycle Naming And Order

The lifecycle order is:

```text
Index
ImpactScope
Overview
Logic
TestPlan
ChangeContract
Approval
Module
Verification
Audit
```

Lifecycle documents use a PascalCase-joined filename with **no six-digit prefix**, placed under a per-change evidence folder:

```text
docs/implementation_evidence/<change_id>/<DocumentType>.md
```

The recommended folder shape uses a local two-digit ordinal prefix for filesystem sort order only (not a project document number):

```text
docs/implementation_evidence/<change_id>/04_TestPlan.md
docs/implementation_evidence/<change_id>/05_ChangeContract.md
docs/implementation_evidence/<change_id>/06_ImplementationModule.md
docs/implementation_evidence/<change_id>/07_VerificationResult.md
docs/implementation_evidence/<change_id>/09_AuditReview.md
```

The canonical name for each artifact (used in prose, cross-references, and the `H1`) is the PascalCase-joined form without the ordinal, e.g.:

```md
# TestPlan.md
```

See `docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md` §15 and §33 for the authoritative full artifact list, folder shape, and rationale. This scheme superseded the six-digit `604xxx`-band numbering convention when that band was quarantined to `990000_legacy_quarantine/` on 2026-07-10 — see `000701` §15.1.

- `TestPlan` and `ChangeContract` are pre-implementation and never authorize implementation.
- `Approval` is Human-owned and authorizes only its explicit boundary.
- `Module` is implementer self-report.
- `Verification` is command and test evidence.
- `Audit` is independent review.
- Module, Verification, and Audit must not be collapsed when lifecycle separation is required.

### 1.2.3 NavigationMap Naming Rule

`NavigationMap` is an approved development documentation route-map type. It uses a PascalCase-joined filename with **no six-digit prefix**, placed in the domain/module folder it tracks (one per governed domain, not per change) — see `000701` §32-§33:

```md
# NavigationMap.md
```

This scheme superseded the six-digit `604xxx`-band numbering convention when that band was quarantined to `990000_legacy_quarantine/` on 2026-07-10 — see `000701` §15.1.

`NavigationMap` explains reading and dependency routes. It is not an Index, Approval, implementation instruction, Verification, or Audit.

## 1.3 Markdown Filename Format Rules

- File names must use English only.
- File names must use underscores only as word separators.
- File names must not contain spaces.
- File names must not contain Korean characters.
- File names must not contain parentheses.
- File names must not contain commas.
- File names must not contain colons.
- File names must not contain shell-sensitive special characters.
- File names must use `.md` lowercase extension.
- The six-digit numeric prefix is mandatory for new governed Markdown files.
- Existing five-digit numeric prefixes are migration targets.
- DocumentType must appear immediately after the numeric prefix.
- DocumentType must be one of the approved values.
- DocumentType must not appear again at the end unless it is naturally part of the title, which should be avoided.
- Do not use `Work_Package`; use `WorkPackage`.
- Do not use lowercase document type prefixes such as `policy`, `sop`, or `checklist`.
- Do not use kebab-case for governed Markdown filenames.
- Do not rename existing files without index and README synchronization.
- Do not perform bulk rename without a dry-run manifest and duplicate-prefix check.

## 1.4 Linux And Cross-Platform Filename Safety

The naming rule is designed for future Linux-based operation and cross-platform Git safety.

Avoid:

- spaces.
- Korean file names.
- special characters.
- case-only filename differences.
- path names that differ only by uppercase/lowercase.
- very long paths where avoidable.
- punctuation-heavy filenames.
- shell-sensitive characters.

Underscores are allowed and remain the project standard.

Kebab-case is not adopted for this project because the repository uses numeric-prefix underscore-based document governance.

## 1.5 Migration Policy

Existing files do not need to be renamed immediately.

Existing five-digit files are migration targets. The default migration rule is:

```text
xxxxx -> 0xxxxx
```

Examples:

```text
000001_Md_Rules.md -> 000001_Md_Rules.md
000002_Naming_Rules.md -> 000002_Naming_Rules.md
12090_pos_gateway_runtime_flow_implementation_package/ -> 012090_pos_gateway_runtime_flow_implementation_package/
```

Future migration must be performed by controlled waves. Each migration wave must:

1. Select a bounded folder or prefix range.
2. Generate a dry-run manifest.
3. Detect duplicate target paths.
4. Detect case-only conflicts.
5. Detect path length risks.
6. Detect existing six-digit files.
7. Detect bad four-digit and five-digit files.
8. Detect Korean filename risks.
9. Detect internal link references to old paths.
10. Prepare an update plan for `docs/000005_Index_Document_Number.md`.
11. Prepare an update plan for `docs/000007_Map_Full_Directory.md`.
12. Prepare an update plan for folder README files.
13. Rename files only with an approved migration batch.
14. Update the document heading only if explicitly approved and required by the batch.
15. Validate UTF-8.
16. Validate Korean readability.
17. Report remaining bad filenames.
18. Do not stage or commit unless explicitly instructed.

This naming-rule update does not rename existing files. Large filename migration must happen in a separate task with an explicit manifest and validation report.

## 2 Folder Number Prefix Rule

- Documentation domain folders under `docs/` use a numeric prefix.
- Folder names should be lower snake case after the numeric prefix.
- Folder names must start with a numeric prefix inside `docs/`.
- New governed folders should use six-digit prefixes.
- Existing five-digit-prefixed folders are migration targets.
- Current folders remain flat unless a domain grows large enough to require subfolders.

## 2.1 Folder Number Range Ownership Rule

- A governed docs folder owns the numeric document range from its own folder prefix up to, but not including, the next sibling folder prefix.
- Files inside a governed docs folder should use numbers within that folder-owned range.
- This rule exists so that the document number, physical folder location, directory map, and folder Readme remain aligned.
- A file whose number belongs to another folder band should not be placed in the wrong folder.
- A folder Readme should state or imply the folder-owned number range when practical.

Example:

If these sibling folders exist:

```text
docs/000100_project_foundation/
docs/000500_ai_agent_prelearning_and_project_context/
```

Then `docs/000100_project_foundation/` owns `000100~000499`, and `docs/000500_ai_agent_prelearning_and_project_context/` owns `000500` up to the next sibling folder prefix.

Therefore:

- `000160_Policy_Internal_Team_Role_And_Responsibility.md` belongs under `docs/000100_project_foundation/`.
- `000505_Guide_Project_Development_Phase_Roadmap_And_AI_Prelearning_Context.md` belongs under `docs/000500_ai_agent_prelearning_and_project_context/`.
- `000505_Guide_Project_Development_Phase_Roadmap_And_AI_Prelearning_Context.md` should not be placed under `docs/000100_project_foundation/`.

## 3 Root Governance Reservation

Root governance numbers are reserved for `000000~000099`.

Root governance files:

- `000000_Project_Overview.md`
- `000001_Md_Rules.md`
- `000002_Naming_Rules.md`
- `000003_Project_Context.md`
- `000005_Index_Document_Number.md`
- `000007_Map_Full_Directory.md`
- `000015_Korean_Document_And_Encoding_Safety_Rules.md`
- `000099_Docs_Governance_Checklist.md`

Existing five-digit root governance files are migration targets and must not be renamed in this governance-rule update.

## 4 Six-Digit Namespace Reservation

The six-digit namespace reservation is:

- `000000~099999`: docs development governance, domain design, architecture, security, runtime, validation.
- `100000~199999`: operation SOP.
- `200000~299999`: system SOP.
- `300000~399999`: recipe, menu, QC, and kitchen SOP.
- `400000~499999`: franchise, training, and field operation SOP.
- `500000~599999`: evidence, audit, legal hold, export, retention, and compliance packet.
- `600000~699999`: implementation lifecycle, code handoff, Overview, Logic, Module, WorkPackage, and implementation evidence.
- `700000~799999`: runtime flow bundle, dependency graph, execution trace, and runtime mapping.
- `800000~899999`: agent, AI automation, knowledge evolution, and NPU readiness.
- `900000~949999`: patent, BM claim, external submission, and attorney packet.
- `950000~989999`: reclassification, duplicate, conflict, and manual review.
- `990000~999999`: legacy, quarantine, import archive, and delete candidate hold.

Legacy five-digit landing folders are migration targets:

- `docs/15000_membership_loyalty/` — membership / loyalty / coupon / point band reserved.
- `docs/17000_ui_screen_composition/` — UI screen composition / wording / wireframe / design band reserved.
- `docs/22000_implementation_planning/` — implementation planning / build sequence / QA band reserved.
- `docs/24000_deployment_operations/` — deployment / operations / support planning band reserved.
- `docs/26000_analytics_reporting_bi/` — analytics / report / BI band reserved.
- `docs/28000_future_expansion/` — active future expansion reference folder.
- `docs/30000_future_saas_modules/` — future SaaS modules / long-term reserved band.

New docs must use the six-digit namespace reservation.

## 4.1 Docs And SOP Separation Principle

- `docs` is for development documentation only.
- `docs` owns development documents, architecture, specifications, boundaries, implementation lifecycle, validation, security, financial control, and audit documents.
- `sop` owns operation SOP, system SOP, temporary QC SOP, field training SOP, and repeated operating procedure documents.
- SOP documents must not be mixed into `docs` except for cross-reference stubs when explicitly required.
- Recipe SOP, operation SOP, and system SOP must be separated from development docs.
- `docs` and `sop` use the same six-digit naming discipline even when their paths are different.

## 5 Readme Naming Rule

Readme documents use the folder number and domain name.

Examples:

- `000100_Readme_Project_Foundation.md`
- `001000_Readme_MVP_Scope.md`
- `005000_Readme_Customer_Handoff_Flow.md`
- `003000_Readme_SaaS_Runtime.md`

## 5.1 Filename Casing Note

- Filename casing may use readable Title Case for acronyms such as Ui, Api, Pos, Scm unless a domain later standardizes otherwise.
- Filename casing must remain consistent with actual paths in `00005` and `00007`.
- Case-only renames should be handled manually and carefully because Git/Windows may not detect them reliably.

## 6 Internal Title Rule

Internal document title should match the filename meaning after a move.

Do not use `yoonsul_os` document numbers as canonical numbers in this project.

## 7 Project Terminology

Preferred terms:

- waiting handoff
- order handoff
- Mini Kiosk
- SaaS tenant
- store runtime
- customer session
- waiting session
- handoff session
- integration boundary

## 8 Current Status

Status: active root governance rule.
