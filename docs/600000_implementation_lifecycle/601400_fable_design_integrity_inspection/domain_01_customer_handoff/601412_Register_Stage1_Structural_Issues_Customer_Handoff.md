# 601412 Register — Stage 1 Structural Issues (Customer Handoff)

- Program: `601400_fable_design_integrity_inspection`
- Domain: `domain_01_customer_handoff`
- Method: Eyes Only — structural facts only (no correctness judgment)
- Created: 2026-07-19

## 1. Filename ↔ H1 mismatch

| Path | Doc# | H1 (first heading) |
|---|---|---|
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601320_domain_01_payment/601321_PassA_Blind_Reverse_Engineering_Payment.md` | 601321 | Pass A: Blind Reverse-Engineering — 결제(600500) |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601331_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice05.md` | 601331 | Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스05 (공통기반) |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601332_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice01.md` | 601332 | Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스01 (대기열 등록/조회) |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601333_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice02.md` | 601333 | Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스02 (호출/도착확인) |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601334_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice03.md` | 601334 | Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스03 (노쇼/유예) |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601335_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice04.md` | 601335 | Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스04 (사전주문/착석/주문본체) |

## 2. Duplicate document numbers in inventory

| Doc# | Paths |
|---|---|
| `601331` | `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601331_PassA_Blind_Reverse_Engineering_Waiting_Order.md`; `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601331_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice05.md` |
| `601332` | `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601332_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice01.md`; `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601332_PassB_Intent_Comparison_Waiting_Order.md` |
| `601333` | `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601333_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice02.md`; `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601333_PassC_Confirmed_Gaps_And_Disposition_Waiting_Order.md` |

## 3. `600600` workpackets — lifecycle artifact presence (folder-level fact)

| Workpacket | Overview | Logic | TestPlan | ChangeContract | Module | Verification | Audit | Nav/Index |
|---|---|---|---|---|---|---|---|---|
| `600610_takeout_session_type_fix` | Y | Y | Y | Y | Y | Y | Y | — |
| `600620_customer_handoff_contract_reconciliation` | Y | Y | Y | Y | Y | Y | Y | — |
| `600630_mark_no_show_overload_and_redesign` | Y | Y | Y | Y | Y | Y | Y | — |
| `600640_call_waiting_customer_contract_recovery` | Y | Y | Y | Y | Y | Y | Y | — |
| `600650_seat_waiting_customer_facade_correction` | Y | Y | Y | Y | — | — | — | — |
| `600660_waiting_pipeline_sibling_functions_correction` | Y | Y | Y | Y | — | — | — | — |
| `600670_record_waiting_call_grant_correction` | Y | Y | Y | Y | — | — | — | — |
| `600680_pre_order_while_waiting_phantom_correction` | Y | Y | Y | Y | — | — | — | — |

## 4. Legacy governance index basename references


## 5. PLACEHOLDER / NOT_STARTED in first ~800 chars

- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601320_domain_01_payment/601322_PassB_Intent_Comparison_Payment.md`
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601320_domain_01_payment/601323_PassC_Confirmed_Gaps_And_Disposition_Payment.md`
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601331_PassA_Blind_Reverse_Engineering_Waiting_Order.md`
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601332_PassB_Intent_Comparison_Waiting_Order.md`
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601333_PassC_Confirmed_Gaps_And_Disposition_Waiting_Order.md`
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601350_domain_04_kds_did/601351_PassA_Blind_Reverse_Engineering_Kds_Did.md`
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601350_domain_04_kds_did/601352_PassB_Intent_Comparison_Kds_Did.md`
- `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601350_domain_04_kds_did/601353_PassC_Confirmed_Gaps_And_Disposition_Kds_Did.md`

## 6. Active-path docs containing `604000_workpackets/` string

- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600200_Readme_Flutter_Waiting_Feature_Implementation.md`
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600214_ChangeContract.md`
- `docs/600000_implementation_lifecycle/600500_payment_confirmation/600550_confirm_payment_column_drift_and_intent_linkage_fix/600551_Overview_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md`
- `docs/600000_implementation_lifecycle/600500_payment_confirmation/600550_confirm_payment_column_drift_and_intent_linkage_fix/600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md`

## 7. Broken relative `.md` links (inventory subset)

- Parsed relative markdown links in inventory markdown set: 9 targets; unresolved: 0 in this pass.

## 8. Cross-track notes (fact)

- Fable blind reverse-engineering track (`601300`) Pass A artifacts overlap scope but are separate program.
- JSON payload/fixture files under scoped paths: 0.