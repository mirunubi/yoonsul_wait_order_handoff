# 004900_Readme_Security_Runtime_Test_Catalog.md

## 1 Purpose

This folder owns the security runtime test catalog for the `004900~004999` document range.

The documents in this folder define verification coverage, abuse cases, audit evidence, readiness gates, and implementation handoff checks. They do not implement runtime code, SQL, API logic, Flutter/Dart logic, CI jobs, deployment logic, or automated tests.

## 2 Scope

- security runtime test catalog governance
- tenant/store RLS and access control test catalog
- audit append-only and tamper-resistance evidence test catalog
- POS/KDS/RPC bridge idempotency and replay test catalog
- payment webhook, refund, settlement, and reconciliation test catalog
- CI/DI identity callback masking leakage test catalog
- support access masking and break-glass scoped session test catalog
- device trust, session revocation, and lost-device test catalog
- local agent degraded recovery and sync conflict test catalog
- export, report, benchmark, and external sharing test catalog
- AI analytics dataset minimization and recommendation boundary test catalog
- vendor/partner access and external integration test catalog
- secure deployment, release gate, and rollback test catalog
- Toss POS integration implementation approach and test mapping

## 3 Folder-Owned Number Range

This folder owns `004900~004999` until the next sibling folder, `005000_customer_handoff_and_implementation_readiness/`, begins.

Files whose canonical number belongs to the `005000` customer handoff and implementation readiness band must not remain active in this folder.

## 4 Active File Roles

| File | Role |
| --- | --- |
| `004900_Readme_Security_Runtime_Test_Catalog.md` | Defines the security runtime test catalog folder purpose, scope, number range, and active file roles. |
| `004910_Policy_Security_And_Runtime_Test_Catalog_Lane_Start_And_Verification_Governance.md` | Defines the start, governance, and verification rules for the security/runtime test catalog lane. |
| `004920_Policy_Tenant_Store_RLS_Access_Control_Test_Catalog.md` | Defines tenant/store RLS and access-control verification coverage. |
| `004930_Audit_Append_Only_Evidence_And_Tamper_Resistance_Test_Catalog.md` | Defines append-only audit evidence and tamper-resistance verification coverage. |
| `004940_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Test_Catalog.md` | Defines POS/KDS/RPC bridge idempotency, replay, and duplicate-prevention verification coverage. |
| `004950_Policy_Payment_Webhook_Refund_Settlement_Reconciliation_Test_Catalog.md` | Defines payment webhook, refund, settlement, and reconciliation verification coverage. |
| `004960_Policy_CI_DI_Identity_Callback_Masking_Leakage_Test_Catalog.md` | Defines CI/DI identity callback masking and leakage verification coverage. |
| `004970_Policy_Support_Access_Masking_Break_Glass_Scoped_Session_Test_Catalog.md` | Defines support access masking and break-glass scoped-session verification coverage. |
| `004980_Policy_Device_Trust_Session_Revocation_Lost_Device_Test_Catalog.md` | Defines device trust, session revocation, and lost-device verification coverage. |
| `004990_Policy_Local_Agent_Degraded_Recovery_Sync_Conflict_Test_Catalog.md` | Defines local agent degraded recovery and sync-conflict verification coverage. |
| `004991_Policy_Export_Report_Benchmark_External_Sharing_Test_Catalog.md` | Defines export, report, benchmark, and external sharing verification coverage. |
| `004992_Policy_AI_Analytics_Dataset_Minimization_Recommendation_Boundary_Test_Catalog.md` | Defines AI analytics dataset minimization and recommendation-boundary verification coverage. |
| `004993_Policy_Vendor_Partner_Access_External_Integration_Test_Catalog.md` | Defines vendor/partner access and external integration verification coverage. |
| `004994_Policy_Secure_Deployment_Release_Gate_Rollback_Test_Catalog.md` | Defines secure deployment, release gate, and rollback verification coverage. |
| `004995_Policy_Toss_POS_Integration_Implementation_Approach_And_Test_Mapping.md` | Defines Toss POS integration implementation approach and test mapping policy. |
| `004999_Policy_Test_Catalog_Lane_Index_Readiness_Check_And_Evidence_Handoff.md` | Closes the test catalog lane with readiness, evidence handoff, blocker, and next-phase preparation rules. |

## 5 Migration History Note

Escaped Markdown duplicates and stale duplicate review copies were moved out of the active folder into `docs/_migration_history/004900_security_runtime_test_catalog_duplicate_review/` for reference.

Those files are not canonical active policy locations for this folder.

## 6 Relationship Notes

- `004000_store_runtime_pos_kds_operations/` owns store runtime POS/KDS operational execution.
- `004900_security_runtime_test_catalog/` owns security and runtime verification catalog policy before implementation entry.
- `005000_customer_handoff_and_implementation_readiness/` owns customer handoff and implementation readiness documents.
- Foundation Security governs identity, access, audit/evidence, incident response, and data retention across these verification catalogs.

## 7 Boundary

These documents are governance and verification catalogs only.

They do not approve implementation, production rollout, POS integration, payment settlement, runtime enforcement, or automated deployment.
