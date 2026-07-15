# 600502_NavigationMap_Payment_Confirmation.md

Status: Active
Lifecycle: NavigationMap
Domain: Payment Confirmation

## Workpacket Flow

| Workpacket | Scope | Local flow |
|---|---|---|
| `600510_confirm_payment_from_provider_overload_ambiguity/` | Drop legacy 9-param `confirm_payment_from_provider()` overload and keep the canonical 8-param provider confirmation path. | `600511_Overview.md` → `600512_Logic.md` → `600513_TestPlan.md` → `600514_ChangeContract.md` → `600515_Module.md` → `600516_Verification.md` → `600517_Audit.md` |
| `600540_mark_payment_uncertain_overload_ambiguity/` | Drop legacy 6-param `mark_payment_uncertain()` overload (`p_locale` variant, independently broken by `chk_intent_status`/`exception_code` NOT NULL defects) and keep the canonical 5-param path — same pattern as `600510`. First workpacket completed under `000701` §43's mandatory triple-verification standard (Claude Code + Antigravity + Codex). | `600541_Overview_Mark_Payment_Uncertain_Overload.md` → `600542_Logic_Mark_Payment_Uncertain_Overload.md` → `600543_TestPlan_Mark_Payment_Uncertain_Overload.md` → `600544_ChangeContract_Mark_Payment_Uncertain_Overload.md` → `600545_Module.md` → `600546_Verification.md` → `600547_Audit.md` |
| `600550_confirm_payment_column_drift_and_intent_linkage_fix/` | Fix `confirm_payment()`(`0098`)'s `payment_ledger` INSERT: 4 phantom columns (`payment_method`/`provider_tx_id`/`fee_amount`/`provider_response`, none exist live), 2 missing NOT NULL columns (`intent_id`/`ledger_entry_type`), and the structural absence of a `p_intent_id` parameter — discovered as an URGENT Open Item during `601020_authorize_kds_release_overload_and_redesign`'s Stage 5/6 (`601026_Verification.md` §5 / `601027_Audit.md`). Uses `confirm_payment_from_provider()`(`0027`) as the working reference pattern. | `600551_Overview_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` → `600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` → `600553_TestPlan_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` → `600554_ChangeContract_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` → `600555_Module.md` → `600556_Verification.md` → `600557_Audit.md` |

