# 600102_NavigationMap.md

Per `000701` §32 — single structured index, not a narrative log (`600101_ChangeHistory.md` owns "why"; this owns "what exists and what state"). One row per change. Must be updated at Stage 3 (approval) and Stage 7 (release) at minimum.

| Change ID | Date | Tier | Status | Links |
|---|---|---|---|---|
| `order_sessions_customer_id_fk_and_guest_promotion` | 2026-07-11 | Medium (§31 — file structure this batch uses 4-7 separate files rather than Medium's 2-consolidated-file convention; tier classification itself not re-confirmed by Human) | **Audited** (progression this session: approved → implemented → verified → audited, see `600101_ChangeHistory.md` 2026-07-11 항목) | `600110_order_sessions_customer_id_fk_and_guest_promotion/600111_Overview.md`, `600112_Logic.md`, `600113_TestPlan.md`, `600114_ChangeContract.md`, `600115_Module.md`, `600116_Verification.md`, `600117_Audit.md` |
| `guest_customer_bootstrap_rpc` | 2026-07-11 | Medium + §24 lightweight SQL fix track | **Audited** (approved → implemented → verified → audited; final result ACCEPT in `600127_Audit.md`) | `600120_guest_customer_bootstrap_rpc/600121_Overview.md`, `600122_Logic.md`, `600123_TestPlan.md`, `600124_ChangeContract.md`, `600125_Module.md`, `600126_Verification.md`, `600127_Audit.md` |
