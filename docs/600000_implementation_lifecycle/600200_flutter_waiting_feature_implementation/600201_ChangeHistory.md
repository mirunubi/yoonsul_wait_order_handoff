# 600201_ChangeHistory.md

Per `000701` §30 — single running file, append-only. One row per change.

| Date | Change Description | Reason/Evidence | Outcome | Linked Audit/Test |
|---|---|---|---|---|
| 2026-07-11/12 | `waiting_feature_guest_customer_id_integration`: `go_router` wiring (`main.dart`/`app/router.dart`), guest `customer_id`/`session_id` persistence (`core/storage/guest_session_storage.dart`), and two waiting screens (`register`/`status`) consuming `600120`'s guest bootstrap RPCs in the corrected call order (`bootstrap_customer_app_v2()` first, `register_waiting()` second) | `600203_DecisionLog.md` Decision 1 unblocked by `600120` ACCEPT (`f697e52`); `600213_TestPlan.md` §0 discovered `register_waiting()` does not return `customer_id`, requiring the call-order correction recorded in `600211_Overview.md` §0.3 | ACCEPT — `600215_Module.md`(Stage 4)/`600216_Verification.md`(Stage 5, `flutter analyze`+`flutter test` PASS)/`600217_Audit.md`(Stage 6) all complete | `600215_Module.md`, `600216_Verification.md`, `600217_Audit.md` |
