# 600202_NavigationMap.md

Per `000701` §32 — single structured index, not a narrative log (`600201_ChangeHistory.md` owns "why"; this owns "what exists and what state"). One row per change.

| Change ID | Date | Tier | Status | Links |
|---|---|---|---|---|
| `waiting_feature_guest_customer_id_integration` | 2026-07-11/12 | Full (Overview/Logic/TestPlan/ChangeContract/Module/Verification/Audit, 7 separate files) | **audited** (progression this session: unblocked → drafted (1.5/2) → implemented (4) → verified (5, `flutter analyze`+`flutter test` PASS) → audited (6, ACCEPT), see `600201_ChangeHistory.md` 2026-07-11/12 항목) | `600210_waiting_feature_guest_customer_id_integration/600211_Overview.md`, `600212_Logic.md`, `600213_TestPlan.md`, `600214_ChangeContract.md`, `600215_Module.md`, `600216_Verification.md`, `600217_Audit.md` |
| `platform_deployment_strategy` (platform strategy confirmed + `flutter build web` first-ever execution, web scope only — Android APK compile test still pending) | 2026-07-13 | Full (Overview/Logic/TestPlan/ChangeContract/Module/Verification/Audit, 7 separate files) | **audited** (progression: drafted(1.5/2) → approved(3) → implemented(4, Human execution) → verified(5, Human + Claude Code independent live-browser/static/analyze verification) → audited(6, ACCEPT — web scope only), see `600201_ChangeHistory.md` 2026-07-13 항목) | `600220_platform_deployment_strategy/600221_Overview.md`, `600222_Logic.md`, `600223_TestPlan.md`, `600224_ChangeContract.md`, `600225_Module.md`, `600226_Verification.md`, `600227_Audit.md` |
