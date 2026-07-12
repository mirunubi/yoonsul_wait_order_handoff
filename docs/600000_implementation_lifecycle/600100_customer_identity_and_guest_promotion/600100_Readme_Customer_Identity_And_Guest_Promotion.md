# 600100_Readme_Customer_Identity_And_Guest_Promotion.md

Status: Draft  
Lifecycle: Readme  
Owner: TBD  
Last Updated: 2026-07-11

## Purpose

This folder owns controlled implementation lifecycle documentation for **customer identity, guest session, and guest-to-customer promotion** work in the CatchMenu wait/order handoff lane.

## In Scope

- Workpacket subfolders for customer identity / guest promotion changes (starting with `600110_order_sessions_customer_id_fk_and_guest_promotion/`)
- Stage 1 (Eyes Only) raw scope and inventory reports
- Future Overview / Logic / TestPlan / ChangeContract / Module documents when authorized

## Out of Scope

- Runtime implementation (SQL migrations, RLS edits, Flutter/Dart, Supabase Edge) unless explicitly authorized via Controlled Implementation Gate
- Architecture or DB standard decisions in Stage 1
- Treating `docs/implementation_evidence/order_sessions_customer_id_fk_and_guest_promotion/DesignPack.md` as authoritative input

## Owned Number Band

- Folder band: `600100`–`600199`
- Parent: `docs/600000_implementation_lifecycle/`
- Distinct from quarantined `docs/990000_legacy_quarantine/600100_readme_governance/` (historical governance band; different active path)

## Subfolder Map

| Folder | CHANGE_ID / Topic | Status |
| --- | --- | --- |
| `600110_order_sessions_customer_id_fk_and_guest_promotion/` | `order_sessions_customer_id_fk_and_guest_promotion` | Audited |
| `600120_guest_customer_bootstrap_rpc/` | `guest_customer_bootstrap_rpc` | Draft / Stage 1 |

## Boundary Reference Documents

`000001_Md_Rules.md` §5.2.1 — 이 모듈 산하 모든 변경건(`600110`, `600120` 등)이 Stage 1 스캔 시 반드시 대조해야 하는 경계 정의 문서. 각 변경건의 `Overview.md`가 갖는 "Required Context Snapshot Candidates"(1회성 스냅샷)와 달리, 이 표는 모듈 전체에 걸쳐 영구 누적된다.

| 문서 | 필요한 이유 |
| --- | --- |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005015_Policy_Customer_Account_Guest_Merge_Identity_Continuity_Membership_Ready_And_Runtime_Authority_Boundary.md` | 게스트/계정 병합 모델 정의 — 이번 in-place promotion 설계와 충돌 지점 있음 (`600112_Logic.md` §5 OQ-1 참고) |
| `docs/020000_validation_security_audit/020310_Policy_User_Account_And_Login.md` | 로그인/세션 정책, `PUBLIC_GUEST_SESSION` 전환 개념 |
| `docs/900000_patent_and_handoff_package/900102_ChangeContract_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` | INV-001~006, 결제-KDS 경계 (특허 보호 로직). `rpc_caller.dart`의 근거 문서이기도 함 |

## File List

| Number | File | Status |
| --- | --- | --- |
| 600100 | `600100_Readme_Customer_Identity_And_Guest_Promotion.md` | Draft |

## Add / Move Rule

1. New workpacket subfolders use `{6-digit-band}_{snake_case_topic}/` under this folder.
2. The first official document in each new workpacket subfolder should use that subfolder's number band; add a subfolder Readme when the subfolder receives its first governed document.
3. Any create, rename, or move must update **this Readme**, `docs/000005_Index_Document_Number.md`, and `docs/000007_Map_Full_Directory.md` in the same batch (per `docs/000001_Md_Rules.md` §5.11).
4. Also update `600000_Readme_Implementation_Lifecycle.md` when this folder's role or membership changes.

## Non-Implementation Boundary

This folder does not grant Codex, Cursor, or Claude permission to modify SQL, migrations, application code, or runtime configuration. Human Approval and ChangeContract are required before any implementation stage.
