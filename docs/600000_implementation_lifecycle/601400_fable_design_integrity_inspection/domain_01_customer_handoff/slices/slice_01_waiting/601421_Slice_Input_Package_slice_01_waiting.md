# 601421 Input Package — slice_01 — Waiting (600600 + waiting SQL)

- Program: `601400_fable_design_integrity_inspection`
- Domain: `domain_01_customer_handoff` / `slice_01_waiting`
- Method: Eyes Only — Fable single-pass delivery slice
- Created: 2026-07-19

## Slice size summary

| Metric | Value |
|---|---|
| Markdown files | 65 |
| SQL migration files | 15 |
| MD bytes (source) | 1,659,194 |
| SQL concat bytes | 279,504 |
| **Estimated Fable payload** | **1,938,698** (~1.85 MiB) |
| Single-pass feasible? | BORDERLINE/OVER — consider sub-split |

## Structural issues excerpt — slice_01_waiting

(From 601412_Register_Stage1_Structural_Issues_Customer_Handoff.md — slice-relevant rows only)

| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601331_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice05.md` | 601331 | Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스05 (공통기반) |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601332_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice01.md` | 601332 | Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스01 (대기열 등록/조회) |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601333_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice02.md` | 601333 | Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스02 (호출/도착확인) |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601334_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice03.md` | 601334 | Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스03 (노쇼/유예) |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601335_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice04.md` | 601335 | Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스04 (사전주문/착석/주문본체) |
| `601331` | `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601331_PassA_Blind_Reverse_Engineering_Waiting_Order.md`; `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601331_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice05.md` |
| `601332` | `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601332_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice01.md`; `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601332_PassB_Intent_Comparison_Waiting_Order.md` |
| `601333` | `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601333_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice02.md`; `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601333_PassC_Confirmed_Gaps_And_Disposition_Waiting_Order.md` |
## 3. `600600` workpackets — lifecycle artifact presence (folder-level fact)
| `600640_call_waiting_customer_contract_recovery` | Y | Y | Y | Y | Y | Y | Y | — |
| `600650_seat_waiting_customer_facade_correction` | Y | Y | Y | Y | — | — | — | — |
| `600660_waiting_pipeline_sibling_functions_correction` | Y | Y | Y | Y | — | — | — | — |
| `600670_record_waiting_call_grant_correction` | Y | Y | Y | Y | — | — | — | — |
| `600680_pre_order_while_waiting_phantom_correction` | Y | Y | Y | Y | — | — | — | — |
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601331_PassA_Blind_Reverse_Engineering_Waiting_Order.md`
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601332_PassB_Intent_Comparison_Waiting_Order.md`
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601333_PassC_Confirmed_Gaps_And_Disposition_Waiting_Order.md`
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600200_Readme_Flutter_Waiting_Feature_Implementation.md`
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600214_ChangeContract.md`

## Stage 2 classification excerpt — slice_01_waiting

(From 601413 — lines mentioning slice scope paths only)

- `docs/005000_customer_handoff_and_implementation_readiness/005400_pos_waiting_entry_sync/005410_Policy_POS_Waiting_Entry_NoShow_And_Prepaid_Cancel_Sync.md` (15,607 bytes; type=Policy)
- `docs/005000_customer_handoff_and_implementation_readiness/005400_pos_waiting_entry_sync/005400_Readme_POS_Waiting_Entry_Sync.md` (801 bytes; type=Readme)
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600200_Readme_Flutter_Waiting_Feature_Implementation.md` (3,785 bytes; type=Readme)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600600_Readme_Waiting_Order_Session.md` (1,136 bytes; type=Readme)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600602_NavigationMap_Waiting_Order_Session.md` (5,588 bytes; type=NavigationMap)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600631_Overview_Mark_No_Show_Overload_And_Redesign.md` (19,638 bytes; type=Overview)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600641_Overview_Call_Waiting_Customer_Contract_Recovery.md` (18,426 bytes; type=Overview)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600642_Logic_Call_Waiting_Customer_Contract_Recovery.md` (30,685 bytes; type=Logic)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600650_seat_waiting_customer_facade_correction/600651_Overview_Seat_Waiting_Customer_Facade_Correction.md` (21,073 bytes; type=Overview)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600650_seat_waiting_customer_facade_correction/600652_Logic_Seat_Waiting_Customer_Facade_Correction.md` (36,582 bytes; type=Logic)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600660_waiting_pipeline_sibling_functions_correction/600661_Overview_Waiting_Pipeline_Sibling_Functions_Correction.md` (23,312 bytes; type=Overview)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600660_waiting_pipeline_sibling_functions_correction/600662_Logic_Waiting_Pipeline_Sibling_Functions_Correction.md` (36,630 bytes; type=Logic)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600670_record_waiting_call_grant_correction/600671_Overview_Record_Waiting_Call_Grant_Correction.md` (22,369 bytes; type=Overview)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600670_record_waiting_call_grant_correction/600672_Logic_Record_Waiting_Call_Grant_Correction.md` (12,470 bytes; type=Logic)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600680_pre_order_while_waiting_phantom_correction/600681_Overview_Pre_Order_While_Waiting_Phantom_Correction.md` (12,418 bytes; type=Overview)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600680_pre_order_while_waiting_phantom_correction/600682_Logic_Pre_Order_While_Waiting_Phantom_Correction.md` (14,403 bytes; type=Logic)
- `docs/900000_patent_and_handoff_package/900100_Overview_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md` (9,142 bytes; type=Overview)
- `docs/900000_patent_and_handoff_package/900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md` (16,242 bytes; type=Logic)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600650_seat_waiting_customer_facade_correction/600653_TestPlan_Seat_Waiting_Customer_Facade_Correction.md` (39,772 bytes; type=TestPlan)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600650_seat_waiting_customer_facade_correction/600654_ChangeContract_Seat_Waiting_Customer_Facade_Correction.md` (25,228 bytes; type=ChangeContract)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600660_waiting_pipeline_sibling_functions_correction/600663_TestPlan_Waiting_Pipeline_Sibling_Functions_Correction.md` (37,658 bytes; type=TestPlan)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600660_waiting_pipeline_sibling_functions_correction/600664_ChangeContract_Waiting_Pipeline_Sibling_Functions_Correction.md` (26,593 bytes; type=ChangeContract)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600670_record_waiting_call_grant_correction/600673_TestPlan_Record_Waiting_Call_Grant_Correction.md` (16,568 bytes; type=TestPlan)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600670_record_waiting_call_grant_correction/600674_ChangeContract_Record_Waiting_Call_Grant_Correction.md` (16,336 bytes; type=ChangeContract)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600680_pre_order_while_waiting_phantom_correction/600683_TestPlan_Pre_Order_While_Waiting_Phantom_Correction.md` (8,316 bytes; type=TestPlan)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600680_pre_order_while_waiting_phantom_correction/600684_ChangeContract_Pre_Order_While_Waiting_Phantom_Correction.md` (7,144 bytes; type=ChangeContract)
- `docs/900000_patent_and_handoff_package/900102_ChangeContract_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` (12,853 bytes; type=ChangeContract)
- `docs/900000_patent_and_handoff_package/900103_TestPlan_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` (14,385 bytes; type=TestPlan)
- `docs/900000_patent_and_handoff_package/906000_TestPlan_Catch_Menu_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` (14,047 bytes; type=TestPlan)
- `docs/900000_patent_and_handoff_package/906010_ChangeContract_Catch_Menu_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` (10,758 bytes; type=ChangeContract)
- `sql/migrations/0050_create_waiting_queue_rpc.sql` (22,496 bytes; type=sql)
- `sql/migrations/0115_create_waiting_pipeline_rpc.sql` (53,373 bytes; type=sql)
- `sql/migrations/0160_call_waiting_customer_contract_recovery.sql` (11,786 bytes; type=sql)
- `sql/migrations/0163_seat_waiting_customer_facade_correction.sql` (13,629 bytes; type=sql)
- `sql/migrations/0164_waiting_pipeline_sibling_functions_correction.sql` (17,451 bytes; type=sql)
- `sql/migrations/0167_record_waiting_call_grant_correction.sql` (724 bytes; type=sql)
- `sql/scratch/cursor_blind_audit_call_waiting_customer_verify.sql` (3,390 bytes; type=sql)
- `sql/scratch/cursor_blind_audit_call_waiting_customer_verify2.sql` (4,390 bytes; type=sql)
- `sql/scratch/fable_pass_a/03_waiting_600600_migrations_concat.sql` (257,307 bytes; type=sql)
- `sql/scratch/fable_pass_a/600600_slices/slice_01_waiting_queue_migrations_concat.sql` (113,794 bytes; type=sql)
- `sql/scratch/fable_pass_a/600600_slices/slice_04_pre_order_order_session_migrations_concat.sql` (134,541 bytes; type=sql)
- `sql/scratch/fable_pass_a/600600_slices/verify_pre_order_while_waiting_live.sql` (8,420 bytes; type=sql)
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601320_domain_01_payment/601321_PassA_Blind_Reverse_Engineering_Payment.md` (15,693 bytes; type=PassA)
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601320_domain_01_payment/601322_PassB_Intent_Comparison_Payment.md` (326 bytes; type=PassB)
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601320_domain_01_payment/601323_PassC_Confirmed_Gaps_And_Disposition_Payment.md` (339 bytes; type=PassC)
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601331_PassA_Blind_Reverse_Engineering_Waiting_Order.md` (340 bytes; type=PassA)
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601331_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice05.md` (15,172 bytes; type=PassA)
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601332_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice01.md` (11,611 bytes; type=PassA)
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601332_PassB_Intent_Comparison_Waiting_Order.md` (332 bytes; type=PassB)
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601333_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice02.md` (11,506 bytes; type=PassA)
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601333_PassC_Confirmed_Gaps_And_Disposition_Waiting_Order.md` (345 bytes; type=PassC)
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601334_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice03.md` (11,547 bytes; type=PassA)
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601335_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice04.md` (12,263 bytes; type=PassA)
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601350_domain_04_kds_did/601351_PassA_Blind_Reverse_Engineering_Kds_Did.md` (334 bytes; type=PassA)
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601350_domain_04_kds_did/601352_PassB_Intent_Comparison_Kds_Did.md` (326 bytes; type=PassB)
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601350_domain_04_kds_did/601353_PassC_Confirmed_Gaps_And_Disposition_Kds_Did.md` (339 bytes; type=PassC)
- `catchmenu_app/lib/features/waiting/README.md` (778 bytes; type=md)
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600201_ChangeHistory.md` (2,333 bytes; type=md)
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600202_NavigationMap.md` (1,606 bytes; type=md)
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600203_DecisionLog.md` (1,329 bytes; type=md)
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600211_Overview.md` (14,886 bytes; type=md)
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600212_Logic.md` (16,817 bytes; type=md)
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600213_TestPlan.md` (11,081 bytes; type=md)
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600214_ChangeContract.md` (5,649 bytes; type=md)
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600215_Module.md` (5,102 bytes; type=md)
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600216_Verification.md` (4,341 bytes; type=md)
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600217_Audit.md` (7,399 bytes; type=md)
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600221_Overview.md` (5,762 bytes; type=md)
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600222_Logic.md` (6,971 bytes; type=md)
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600223_TestPlan.md` (11,665 bytes; type=md)
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600224_ChangeContract.md` (6,596 bytes; type=md)
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600225_Module.md` (3,393 bytes; type=md)
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600226_Verification.md` (4,580 bytes; type=md)
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600227_Audit.md` (5,355 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600611_Overview.md` (10,426 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600612_Logic.md` (13,475 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600613_TestPlan.md` (10,434 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600614_ChangeContract.md` (8,843 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600615_Module.md` (3,350 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600616_Verification.md` (6,873 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600617_Audit.md` (6,963 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600621_Overview.md` (17,882 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600622_Logic.md` (14,390 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600623_TestPlan.md` (11,826 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600624_ChangeContract.md` (11,013 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600625_Module.md` (3,519 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600626_Verification.md` (7,364 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600627_Audit.md` (8,233 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600632_Logic.md` (70,766 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600633_TestPlan.md` (18,172 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600634_ChangeContract.md` (9,313 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600635_Module.md` (6,027 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600636_Verification.md` (7,607 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600637_Audit.md` (4,646 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600643_TestPlan.md` (16,435 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600644_ChangeContract.md` (10,080 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600645_Module.md` (4,549 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600646_Verification.md` (6,702 bytes; type=md)
- `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600647_Audit.md` (5,587 bytes; type=md)
- `sql/scratch/fable_pass_a/03_waiting_600600_input_package.md` (202,958 bytes; type=md)
- `sql/scratch/fable_pass_a/600600_slices/00_waiting_slices_manifest.md` (1,355 bytes; type=md)
- `sql/scratch/fable_pass_a/600600_slices/slice_01_waiting_queue_input_package.md` (28,124 bytes; type=md)
- `sql/scratch/fable_pass_a/600600_slices/slice_04_pre_order_order_session_input_package.md` (102,358 bytes; type=md)
- `catchmenu_app/lib/features/waiting/screens/waiting_register_screen.dart` (7,741 bytes; type=dart)
- `catchmenu_app/lib/features/waiting/screens/waiting_status_screen.dart` (2,082 bytes; type=dart)
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/.gitkeep` (0 bytes; type=none)
- `sql/scratch/fable_pass_a/build_waiting_slices.py` (12,621 bytes; type=py)

## §A — File inventory (this slice)

| Path | Bytes | Doc# | Type | Status |
|---|---:|---|---|---|
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600600_Readme_Waiting_Order_Session.md` | 1136 | 600600 | Readme | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600602_NavigationMap_Waiting_Order_Session.md` | 5588 | 600602 | NavigationMap | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600611_Overview.md` | 10426 | 600611 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600612_Logic.md` | 13475 | 600612 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600613_TestPlan.md` | 10434 | 600613 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600614_ChangeContract.md` | 8843 | 600614 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600615_Module.md` | 3350 | 600615 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600616_Verification.md` | 6873 | 600616 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600617_Audit.md` | 6963 | 600617 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600621_Overview.md` | 17882 | 600621 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600622_Logic.md` | 14390 | 600622 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600623_TestPlan.md` | 11826 | 600623 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600624_ChangeContract.md` | 11013 | 600624 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600625_Module.md` | 3519 | 600625 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600626_Verification.md` | 7364 | 600626 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600627_Audit.md` | 8233 | 600627 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600631_Overview_Mark_No_Show_Overload_And_Redesign.md` | 19638 | 600631 | Overview | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600632_Logic.md` | 70766 | 600632 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600633_TestPlan.md` | 18172 | 600633 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600634_ChangeContract.md` | 9313 | 600634 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600635_Module.md` | 6027 | 600635 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600636_Verification.md` | 7607 | 600636 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600637_Audit.md` | 4646 | 600637 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600641_Overview_Call_Waiting_Customer_Contract_Recovery.md` | 18426 | 600641 | Overview | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600642_Logic_Call_Waiting_Customer_Contract_Recovery.md` | 30685 | 600642 | Logic | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600643_TestPlan.md` | 16435 | 600643 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600644_ChangeContract.md` | 10080 | 600644 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600645_Module.md` | 4549 | 600645 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600646_Verification.md` | 6702 | 600646 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600647_Audit.md` | 5587 | 600647 | md | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600650_seat_waiting_customer_facade_correction/600651_Overview_Seat_Waiting_Customer_Facade_Correction.md` | 21073 | 600651 | Overview | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600650_seat_waiting_customer_facade_correction/600652_Logic_Seat_Waiting_Customer_Facade_Correction.md` | 36582 | 600652 | Logic | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600650_seat_waiting_customer_facade_correction/600653_TestPlan_Seat_Waiting_Customer_Facade_Correction.md` | 39772 | 600653 | TestPlan | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600650_seat_waiting_customer_facade_correction/600654_ChangeContract_Seat_Waiting_Customer_Facade_Correction.md` | 25228 | 600654 | ChangeContract | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600660_waiting_pipeline_sibling_functions_correction/600661_Overview_Waiting_Pipeline_Sibling_Functions_Correction.md` | 23312 | 600661 | Overview | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600660_waiting_pipeline_sibling_functions_correction/600662_Logic_Waiting_Pipeline_Sibling_Functions_Correction.md` | 36630 | 600662 | Logic | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600660_waiting_pipeline_sibling_functions_correction/600663_TestPlan_Waiting_Pipeline_Sibling_Functions_Correction.md` | 37658 | 600663 | TestPlan | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600660_waiting_pipeline_sibling_functions_correction/600664_ChangeContract_Waiting_Pipeline_Sibling_Functions_Correction.md` | 26593 | 600664 | ChangeContract | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600670_record_waiting_call_grant_correction/600671_Overview_Record_Waiting_Call_Grant_Correction.md` | 22369 | 600671 | Overview | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600670_record_waiting_call_grant_correction/600672_Logic_Record_Waiting_Call_Grant_Correction.md` | 12470 | 600672 | Logic | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600670_record_waiting_call_grant_correction/600673_TestPlan_Record_Waiting_Call_Grant_Correction.md` | 16568 | 600673 | TestPlan | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600670_record_waiting_call_grant_correction/600674_ChangeContract_Record_Waiting_Call_Grant_Correction.md` | 16336 | 600674 | ChangeContract | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600680_pre_order_while_waiting_phantom_correction/600681_Overview_Pre_Order_While_Waiting_Phantom_Correction.md` | 12418 | 600681 | Overview | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600680_pre_order_while_waiting_phantom_correction/600682_Logic_Pre_Order_While_Waiting_Phantom_Correction.md` | 14403 | 600682 | Logic | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600680_pre_order_while_waiting_phantom_correction/600683_TestPlan_Pre_Order_While_Waiting_Phantom_Correction.md` | 8316 | 600683 | TestPlan | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600680_pre_order_while_waiting_phantom_correction/600684_ChangeContract_Pre_Order_While_Waiting_Phantom_Correction.md` | 7144 | 600684 | ChangeContract | current |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601331_PassA_Blind_Reverse_Engineering_Waiting_Order.md` | 340 | 601331 | PassA | current |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601331_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice05.md` | 15172 | 601331 | PassA | current |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601332_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice01.md` | 11611 | 601332 | PassA | current |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601332_PassB_Intent_Comparison_Waiting_Order.md` | 332 | 601332 | PassB | current |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601333_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice02.md` | 11506 | 601333 | PassA | current |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601333_PassC_Confirmed_Gaps_And_Disposition_Waiting_Order.md` | 345 | 601333 | PassC | current |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601334_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice03.md` | 11547 | 601334 | PassA | current |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601335_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice04.md` | 12263 | 601335 | PassA | current |
| `sql/migrations/0012_create_pos_order_sessions.sql` | 10350 | — | sql | current |
| `sql/migrations/0013_create_pos_orders.sql` | 11601 | — | sql | current |
| `sql/migrations/0025_create_session_rpc.sql` | 19795 | — | sql | current |
| `sql/migrations/0026_create_order_rpc.sql` | 21137 | — | sql | current |
| `sql/migrations/0049_create_store_settings_rpc.sql` | 22119 | — | sql | current |
| `sql/migrations/0050_create_waiting_queue_rpc.sql` | 22496 | — | sql | current |
| `sql/migrations/0051_create_pre_order_rpc.sql` | 26047 | — | sql | current |
| `sql/migrations/0115_create_waiting_pipeline_rpc.sql` | 53373 | — | sql | current |
| `sql/migrations/0148_add_order_sessions_customer_id_and_guest_flag.sql` | 3437 | — | sql | current |
| `sql/migrations/0149_create_guest_customer_bootstrap_rpc.sql` | 19006 | — | sql | current |
| `sql/migrations/0160_call_waiting_customer_contract_recovery.sql` | 11786 | — | sql | current |
| `sql/migrations/0161_mark_no_show_overload_and_redesign.sql` | 19774 | — | sql | current |
| `sql/migrations/0163_seat_waiting_customer_facade_correction.sql` | 13629 | — | sql | current |
| `sql/migrations/0164_waiting_pipeline_sibling_functions_correction.sql` | 17451 | — | sql | current |
| `sql/migrations/0167_record_waiting_call_grant_correction.sql` | 724 | — | sql | current |
| `sql/scratch/cursor_blind_audit_call_waiting_customer_verify.sql` | 3390 | — | sql | current |
| `sql/scratch/cursor_blind_audit_call_waiting_customer_verify2.sql` | 4390 | — | sql | current |
| `sql/scratch/fable_pass_a/03_waiting_600600_input_package.md` | 202958 | — | md | current |
| `sql/scratch/fable_pass_a/03_waiting_600600_migrations_concat.sql` | 257307 | — | sql | current |
| `sql/scratch/fable_pass_a/600600_slices/00_waiting_slices_manifest.md` | 1355 | — | md | current |
| `sql/scratch/fable_pass_a/600600_slices/slice_01_waiting_queue_input_package.md` | 28124 | — | md | current |
| `sql/scratch/fable_pass_a/600600_slices/slice_01_waiting_queue_migrations_concat.sql` | 113794 | — | sql | current |
| `sql/scratch/fable_pass_a/600600_slices/slice_04_pre_order_order_session_input_package.md` | 102358 | — | md | current |
| `sql/scratch/fable_pass_a/600600_slices/slice_04_pre_order_order_session_migrations_concat.sql` | 134541 | — | sql | current |
| `sql/scratch/fable_pass_a/600600_slices/verify_pre_order_while_waiting_live.sql` | 8420 | — | sql | current |
| `sql/scratch/fable_pass_a/build_waiting_slices.py` | 12621 | — | py | current |

## §B — SQL migrations (concat)

Full text: [`slice_01_waiting_migrations_concat.sql`](slice_01_waiting_migrations_concat.sql)

## §C — Markdown sources

MD total exceeds 800 KiB embed threshold — full paths listed in §A; read from repo paths.