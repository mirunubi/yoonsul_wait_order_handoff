# 600826_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5
Owner: Claude Code
Date: 2026-07-14

## Verification Result

Final result: **PASS.**

## §0 Scope Note — No Verbatim Codex Text Available This Turn

The task instruction referenced "Codex 이중 검증(1차+재확인)" (a first Codex pass plus a recheck), but no verbatim Codex report text was included with the request. Consistent with this project's established practice (`600536_Verification.md` §0, `600926_Verification.md` §0/§3), this document does not fabricate or reconstruct a Codex report it was not given — it records only what Claude Code directly re-derived this turn, all against the live database and source files. If Codex's actual output for this workpacket exists, it should be added to this document with its own verifiable evidence, matching the pattern already established for the sibling `mark_payment_uncertain` and `workpacket_renumbering` workpackets.

## §1 `0155` Migration — Checksum / Live State

| Check | Result |
|---|---|
| Migration file content matches `600822_Logic.md`/`600824_ChangeContract.md`'s approved design | PASS — single `DROP FUNCTION` statement for the 3-param signature only. |
| Checksum (manual recompute vs. `migration_history`) | PASS — `64caf3f0e2c3be754338dcdde2573ebf11175a3dc988a31f80a84b36d35a2e57`, both methods identical. |
| `count(*)` for `get_did_display_state` | PASS — `1`. |
| Surviving signature | PASS — `p_tenant_id uuid, p_store_id uuid, p_did_id uuid, p_locale text` (`0117` 4-param canonical). |

## §2 `600823_TestPlan.md` Test 1–6 Reproduction, Including Two Corrected Predictions

| Test | TestPlan Prediction | Actual Result (this turn) | Assessment |
|---|---|---|---|
| 1 — pre-implementation baseline | `overload_count = 2` | Historically true (confirmed in earlier turns before `0155`) | PASS |
| 2 — post-DROP overload count | `1`, canonical 4-param remains | PASS — confirmed via `§1` above | PASS |
| 3 — canonical named-argument call (`bootstrap_did_app()`-style) | No ambiguity, normal JSON response | PASS — resolves cleanly to `0117` | PASS |
| **4 — positional 3-argument call rejection** | Predicted the call would **fail** (`function ... does not exist`) once the 3-param overload was dropped | **Prediction was wrong — the call actually succeeds.** Reproduced live: `select get_did_display_state('...'::uuid, '...'::uuid, null::uuid)` returns `{"success": true, "data": {...}, ...}`. Root cause: `p_locale` on the surviving 4-param function has `default 'ko'` — PostgreSQL resolves a 3-positional-argument call against a 4-param function whose last parameter has a default, treating the 3rd argument as `p_did_id` and defaulting `p_locale`. This was not accounted for when TestPlan §4 was written. | **Not a defect — corrected understanding.** The "is not unique" ambiguity is gone (the TestPlan's actual PASS-relevant condition) and no 0043 nested-aggregate error occurs (also PASS-relevant) — the TestPlan's literal "must fail with does-not-exist" expectation was simply an incorrect prediction of *which* success/failure shape would occur, not a sign anything is broken. Recorded as a corrected prediction, not carried forward as an Open Item. |
| **5 — `bootstrap_did_app()` E2E** | Either full success, or "a normal business/fixture error, not overload ambiguity and not 0043 nested aggregate failure" | Reproduced live with a minimal `did_devices` fixture (inside `BEGIN...ROLLBACK`): `ERROR: column "show_waiting_count" does not exist` at `bootstrap_did_app()`'s very first `did_devices` SELECT (source line ~127-136 of `0117_create_did_pipeline_rpc.sql`). | **Matches the TestPlan's own PASS condition exactly** — this is a genuine "normal business/fixture error," specifically a stale-column defect, not overload ambiguity and not the 0043 nested-aggregate error. The TestPlan anticipated *some* non-ambiguity failure class without predicting which one; this turn identifies the specific one. See §3 for the underlying defect and its disposition. |
| 6 — static boundary (`0043`/`0117` untouched, only `0155` new) | 0 diff on both source files, `0155` the only new migration | PASS — `git diff --stat` empty for both; `git status --short -- sql/migrations/` shows only `0155` as `??`. | PASS |

**Additional boundary re-check (beyond TestPlan §6)**: `mark_payment_uncertain()` (1 overload, unaffected), `authorize_kds_release()` (2 overloads, unaffected), `mark_no_show()` (2 overloads, unaffected) — all re-queried live this turn, none touched by `0155`.

## §3 `did_devices` Stale-Column Defect — Root Cause (surfaced by Test 5, out of this workpacket's scope)

`bootstrap_did_app()`'s device-lookup query (`0117_create_did_pipeline_rpc.sql`, the `select ... into v_did_device from catchmenu_store.did_devices` block) selects 4 columns that do not exist on the live table:

```sql
select id, did_code, display_mode,
       zone, call_display_seconds,
       call_repeat_count,
       show_waiting_count,
       show_cms_content,
       supported_locales,
       default_locale
into v_did_device
from catchmenu_store.did_devices
where ...
```

Live schema re-query (`information_schema.columns` for `catchmenu_store.did_devices`, 23 columns total) confirms **`show_waiting_count`, `show_cms_content`, `supported_locales`, `default_locale` are all absent**. These 4 columns are referenced not just in the lookup but throughout the rest of `bootstrap_did_app()`'s body (the `show_cms_content` branch gating a `get_cms_display_bundle()` call, `default_locale` used as a coalesce fallback for locale, `show_waiting_count`/`supported_locales` echoed into the response payload) — this is a coherent, intentional design that was never matched by an actual schema migration, not a typo.

**This is confirmed out of scope for `600820`/`0155`** (`600823_TestPlan.md` §8 explicitly excludes "editing `bootstrap_did_app()`"; `600822_Logic.md`'s Option A never proposed touching `did_devices`'s schema). It is carried into `600827_Audit.md`'s Open Items with an explicit cross-reference to `601010_cms_device_content_routing_architecture` (Overview `601011_Overview_...md` §5.6/§6), since all 4 missing columns are directly CMS-content-routing-shaped (`show_cms_content`/`supported_locales`/`default_locale` describe exactly the per-device content/locale configuration that workpacket's Stage B/C design is meant to own; `show_waiting_count` is DID-display configuration adjacent to the same device-registry layer that workpacket's Stage A is meant to own).

## Scenario Summary

| Scenario | Result |
|---|---|
| `0155` checksum/live=source | PASS |
| `count(*) = 1` | PASS |
| Surviving signature = `0117` 4-param | PASS |
| Test 3 (canonical named call) | PASS |
| Test 4 (positional 3-arg) | PASS (prediction corrected, no defect) |
| Test 5 (`bootstrap_did_app()` E2E) | PASS (prediction's PASS condition met; underlying stale-column defect identified and cross-referenced, not fixed here) |
| Test 6 (boundary) | PASS |
| Other overload-bearing functions unaffected | PASS |
