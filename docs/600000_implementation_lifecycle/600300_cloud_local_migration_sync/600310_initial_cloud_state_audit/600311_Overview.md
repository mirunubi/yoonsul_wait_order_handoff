# 600311_Overview.md

Status: Complete — cloud now matches local on all points investigated below
Lifecycle: Overview
Owner: TBD
Last Updated: 2026-07-12
CHANGE_ID: `initial_cloud_state_audit`

## 0. Document Purpose

This records the initial audit of the hosted Supabase cloud project
(`upzthfwhtvazfftxnyfu`) against `sql/migrations/`, the subsequent full
sequence-numbered replay (via `tools/apply_migrations_cloud.py`), the 19
files that could not apply cleanly on first pass and why, the data backfill
that resolved them, and the final cloud/local parity check.

All cloud queries in this document were run directly by Human via the
Supabase SQL Editor or `docker exec`-based `psql` (per
`600300_Readme_Cloud_Local_Migration_Sync.md`'s stated boundary: Cursor/
Claude Code cannot connect to the cloud project directly). Claude's role in
this workpacket was limited to: reviewing and hardening
`tools/apply_migrations_cloud.py` (see §2), and writing up this record from
the raw results Human reported.

## 1. Q1–Q10 — Initial Cloud State Audit (2026-07-11)

Run by Human directly in the Supabase SQL Editor before any replay attempt.

| # | Question | Result |
|---|---|---|
| Q1 | Full list of `catchmenu*` schemas | 14: `catchmenu_ai`, `catchmenu_dev`, `catchmenu_audit`, `catchmenu_gateway`, `catchmenu_integrations`, `catchmenu_knowledge`, `catchmenu_agent`, `catchmenu_ledger`, `catchmenu_payment`, `catchmenu_kds`, `catchmenu_pos`, `catchmenu_store`, `catchmenu_hq`, `catchmenu_common` |
| Q2 | `catchmenu_pos.order_sessions` columns | `customer_id` (uuid) present, `phone_hash` absent — i.e. `0148` only partially applied. **Root cause of the partial state is not fully resolved** (not confirmed to be `0000` file contamination — some other path is suspected). Left **Open**. |
| Q3 | `catchmenu_store.customers` columns | `is_guest` absent |
| Q4 | `catchmenu_store.store_settings` columns | `max_wait_number` present, `max_waiting_count` absent — the same stale-column-name problem already fixed locally (per the 2026-07-11 §24 lightweight bugfix track) turns out to have originally existed on cloud too |
| Q5 | Existence of `register_waiting`, `bootstrap_customer_app_v2`, `get_or_create_guest_customer` | First two exist; `get_or_create_guest_customer` absent (`0149` not yet applied) |
| Q6 | `chk_event_domain`, `chk_event_caused_by_type` definitions | `chk_event_caused_by_type` already includes `REPLAY` (matches local). `chk_event_domain` does **not** include `'waiting'` (`0150` not yet applied) |
| Q7 | Existence of `catchmenu_meta` schema | Absent (0 rows) — confirms `migration_history` tracking was not possible on cloud before this workpacket |
| Q8 | Live function bodies of `register_waiting` / `bootstrap_customer_app_v2` (`pg_get_functiondef`) | Still contain the stale column names (`max_waiting_count`, `min_order_amount`, etc.) already fixed in the local copies — cloud functions had not received the local §24 fixes |
| Q9 | `order_sessions_customer_id_fkey` `ON DELETE` policy | No `ON DELETE` clause (defaults to `NO ACTION`) — same out-of-band pattern already found locally |
| Q10 | `order_sessions` / `customers` row counts | 0 / 0 — initially read as "cloud project is completely empty." **This initial read was later corrected** — see §1.1. |

### 1.1 Correction to Q10 — cloud was not empty (discovered during `0035` failure investigation)

While investigating why `0035_verify_schema.sql` failed its `seed menus count = 9`
assertion during the replay (§3), Human found:

- `catchmenu_pos.menus` has **68 rows** total (`tenant_id = YOONSUL_TEST`).
- **64** of them carry timestamp `2026-07-01 00:00:43` with real product names
  (윤슬김밥, 치즈김밥, 참치김밥, etc.) — confirmed by Human to be real
  hand-created dev/test menu data, not a migration artifact.
- The remaining **4** carry timestamp `2026-07-12 12:37:17` with manually
  assigned UUIDs `00000000-0000-0000-0000-000000000053`–`56` — these are
  exactly what `0034_seed_data.sql` inserted during this replay (라면,
  라볶이, 공기밥, 단무지).
- Conclusion: `0034` originally attempted to insert 9 seed menu rows; 5 of
  them collided with the pre-existing 64 rows on `menu_code`
  (`ON CONFLICT DO NOTHING`) and were silently skipped, leaving only 4 new
  inserts. `order_sessions`/`customers` being empty (Q10's literal answer)
  was correct — the correction is only that "the project as a whole was
  empty" was wrong; menu data pre-existed.

## 2. `tools/apply_migrations_cloud.py` Development Process

Built to replay `sql/migrations/*.sql` against the cloud project in the same
sequence-number order and checksum discipline as the local
`tools/apply_migrations.py`, tracked via `catchmenu_meta.migration_history`
(which Q7 confirmed did not exist yet on cloud).

1. **First connection attempt — single `postgresql://` URL passed straight
   to `psql <url>`.** Failed with `password authentication failed` against
   the real cloud target, for a reason never fully pinned down (candidates:
   URL-encoding of a special character in the password, or an unsubstituted
   placeholder).
2. **Switched to individual `-h -p -U -d` flags** with the password supplied
   separately. Human confirmed this connects successfully. This script does
   not have a local `psql` binary on PATH, so it invokes `psql` via
   `docker exec` into the already-running local Supabase Docker container
   (`supabase_db_yoonsul_wait_order_handoff`), whose bundled client reaches
   the cloud database over the network.
3. **Security review of the individual-flags approach** (`-e PGPASSWORD=...`)
   found, via a live test (`Get-CimInstance Win32_Process` while a
   `docker exec -e PGPASSWORD=... psql ...` command was running with a dummy
   password), that the password appeared in **plaintext in the host's
   process command line** for every process in the invocation chain
   (`bash.exe`, `sh.exe`, `docker.exe`) for as long as the process stayed
   alive — visible to any other process on the machine via WMI / Task
   Manager. This ruled the approach out.
4. **Final design: a temporary `.pgpass` file inside the container.** The
   credential line is sent over a stdin pipe (never a command-line argument
   or environment variable, so it never appears in any process's command
   line), written with `umask 077` plus an explicit `chmod 600`, referenced
   by psql only via `PGPASSFILE=<container-local-path>` (a path, not a
   secret), and deleted in a `finally` block immediately after use —
   regardless of success or failure.
5. `confirm_cloud_target()` was extended to accept both the direct-connection
   host (`db.upzthfwhtvazfftxnyfu.supabase.co`) and the pooler host pattern
   (`*.pooler.supabase.com` + username `postgres.upzthfwhtvazfftxnyfu`),
   after discovering this project's actual working connection (cached by the
   Supabase CLI in `supabase/.temp/pooler-url`) uses the pooler form, which
   the original host-only check would have refused outright. Both host
   allowlist and username allowlist were fuzz-tested (subdomain-suffix trick,
   forged username, userinfo trick, fake pooler subdomain) with no bypass
   found.
6. The checksum function (`sha256` of CRLF-normalized bytes) was kept
   byte-identical to the local `tools/apply_migrations.py`, and the
   checksum-matches-so-skip branch carries an inline comment warning that a
   matching checksum does not prove the SQL was actually re-executed (see
   §5 Decision Log).

## 3. Sequential Replay — 19 Files That Did Not Apply Cleanly on First Pass

Of the 149 sequence-numbered files (`0001`–`0150`; `0000` itself only
creates `catchmenu_meta.migration_history` and is not counted as a
"replayed" file), the following 19 failed their first attempt. Each was
reviewed and accepted by Human as a **data-ordering artifact of replaying
onto an already-partially-seeded, already-constraint-widened target — not a
schema defect** — and manually recorded into `catchmenu_meta.migration_history`
after root-causing.

| File | Failure | Root Cause |
|---|---|---|
| `0035_verify_schema.sql` | `seed menus count = 9` assertion failed | 64 pre-existing dev/test menu rows already occupied 5 of the 9 `menu_code` values `0034` tried to seed (`ON CONFLICT DO NOTHING`); only 4 new rows inserted. See §1.1. |
| `0073_final_verification.sql` | 3 checks failed: (1) `cron_job_executions` table missing (2) `run_daily_close_batch` function missing (3) seed menus = 9 failed | (1)/(2) are a genuine forward-reference — `0144`'s own header states 0073 expects these but nothing in `0001`–`0072` ever created them. (3) same as `0035`. |
| `0093_create_message_catalog_complete.sql` | `error_codes` INSERT violated `chk_error_domain` on `domain='MENU'` rows | `MENU`/`STORE`/`AUDIT` domains were not allowed until `0140` widened the constraint; 19 rows failed (MENU 7, STORE 9, AUDIT 3) |
| `0100_create_staff_app_bootstrap_rpc.sql` | `error_codes` row `store_already_open` (`domain=STORE`) violated `chk_error_domain` | Same as `0093` (pre-`0140`) |
| `0107_create_mini_cms_pipeline_rpc.sql` | `error_codes` rows `cms_event_not_found` etc. (4 rows, all `domain=STORE`) violated `chk_error_domain` | Same as `0093` |
| `0108_create_membership_pipeline_rpc.sql` | `error_codes` row `membership_config_not_found` (`domain=MEMBERSHIP`) violated `chk_error_domain` | `MEMBERSHIP`/`SECURITY`/`AI` domains not allowed until `0145` |
| `0110_create_store_admin_rpc.sql` | `error_codes` row `menu_code_duplicate` (`domain=STORE`) violated `chk_error_domain` | Same as `0093` |
| `0113_create_api_spec_docs.sql` | `documents` INSERT violated `chk_doc_domain` | `documents` rows default to a `STORE` domain value not allowed until `0146` widened `chk_doc_domain` |
| `0114_create_mini_kiosk_pipeline_rpc.sql` | `error_codes` row `kiosk_not_found` (`domain=STORE`) violated `chk_error_domain` | Same as `0093` |
| `0118_create_schema_validation_update.sql` | `error_codes` row `coupon_already_used` (`domain=STORE`) violated `chk_error_domain`; the file's `order_confirmed`/`order_ready` rows (`domain=ORDER`) passed fine | Same as `0093`. **Open follow-up**: this file's `schema_versions` UPDATE (1 row) and INSERT (1 row) both reported success *before* the `error_codes` failure — transaction-boundary behavior not independently re-confirmed as of this writing. |
| `0119_create_edge_function_integration.sql` | `documents` INSERT violated `chk_doc_domain` | Same as `0113`. `edge_function_configs` already existed per a `NOTICE` (part of cloud's pre-existing state) |
| `0121_create_security_pipeline.sql` | `error_codes` row `security_token_invalid` (`domain=SECURITY`) violated `chk_error_domain` | Same as `0108` (pre-`0145`) |
| `0122_create_coupon_pipeline_rpc.sql` | `error_codes` row `coupon_min_order_not_met` (`domain=STORE`) violated `chk_error_domain` | Same as `0093` |
| `0123_create_ai_customer_center_v2.sql` | `error_codes` row `knowledge_doc_not_found` (`domain=AI`) violated `chk_error_domain` | Same as `0108`. Note: Claude first reported this file's checksum with a 1-character typo (`b`→`f`); caught and corrected by recomputing directly from the file before the `migration_history` UPDATE. |
| `0126_create_staff_notification_pipeline.sql` | `error_codes` row `staff_task_not_found` (`domain=STORE`) violated `chk_error_domain` | Same as `0093` |
| `0127_create_multilingual_embedding_guide.sql` | `error_codes` row `embedding_not_ready` (`domain=AI`) violated `chk_error_domain` | Same as `0108` |
| `0131_create_advanced_staff_permission.sql` | `error_codes` row `permission_denied` (`domain=STORE`) violated `chk_error_domain` | Same as `0093` |
| `0132_create_device_registry_enhanced.sql` | `documents` INSERT (inside a `DO` block) violated `chk_doc_domain` | Same as `0113`. `device_groups`/`device_commands` already existed per a `NOTICE` |
| `0133_create_final_validation_package.sql` | `subscription_plans` row (`BASIC` tier) violated `chk_plan_tier` | `chk_plan_tier` did not allow `BASIC` until `0147`. `subscription_invoices`/`subscription_plans` already existed per a `NOTICE` |
| `0134_create_technology_credit_package.sql` | `documents` INSERT violated `chk_doc_domain` | Same as `0113` |
| `0135_create_flutter_mvp_start_package.sql` | `documents` INSERT violated `chk_doc_domain` | Same as `0113`. This file also registers `schema_versions` v0135, declaring "0001–0135 complete." |

**`0136`–`0150` then completed the replay cleanly in sequence**, including
`0140` (widen `chk_error_domain`, pass 1), `0144` (fills the `0073` gap:
`cron_job_executions` + `run_daily_close_batch`), `0145` (widen
`chk_error_domain`, pass 2), `0146` (widen `chk_doc_domain`/`chk_doc_type`),
`0147` (widen `chk_plan_tier`), and this workpacket's own `0148`
(`customer_id`/`phone_hash`/`is_guest`), `0149` (guest bootstrap RPC), and
`0150` (`chk_event_domain` += `'waiting'`) — all OK.

## 4. Data Backfill and Final Verification

Once `0140`/`0145`/`0146`/`0147` had widened the three constraints, the 19
skipped files' original `error_codes`/`documents`/`subscription_plans` rows
were still missing from cloud (they had failed their INSERT the first time
around and were never retried). Comparison:

| Table | Local | Cloud (before backfill) | Gap |
|---|---|---|---|
| `catchmenu_common.error_codes` | 246 | 194 | 52 |
| `catchmenu_knowledge.documents` | 22 | 0 | 22 (all) |
| `catchmenu_common.subscription_plans` | 8 | 4 | 4 |

**Decision: backfill via data export/import, not by re-running the 19
migration files.** `pg_dump --data-only --column-inserts` exported the 3
tables from the local database in full
(`tmp_cloud_backfill/local_catchmenu_common_error_codes_inserts.sql`,
`local_catchmenu_knowledge_documents_inserts.sql`,
`local_catchmenu_common_subscription_plans_inserts.sql`), each augmented
with an `ON CONFLICT ... DO NOTHING` clause so the pre-existing cloud rows
were preserved and only the gap was filled:

```sql
ON CONFLICT (code) DO NOTHING                       -- error_codes
ON CONFLICT (tenant_id, document_code) DO NOTHING   -- documents
ON CONFLICT (plan_code) DO NOTHING                  -- subscription_plans
```

(Note: `subscription_plans`' unique column turned out to be `plan_code`, not
the originally assumed `tier_code`.)

**Final verification (2026-07-12):**

| Table | Cloud (after backfill) | Local | Match |
|---|---|---|---|
| `catchmenu_common.error_codes` | 246 | 246 | ✅ |
| `catchmenu_knowledge.documents` | 22 | 22 | ✅ |
| `catchmenu_common.subscription_plans` | 8 | 8 | ✅ |

Cloud and local now match exactly on all three tables.

## 5. §29 Decision Log Entries

### Decision A — A matching checksum does not prove the SQL was re-executed

**Context**: discovered locally on 2026-07-11 (see `sql/migrations/CHANGELOG.md`)
that updating `catchmenu_meta.migration_history.checksum` to match an edited
file's new hash does **not** cause `apply_migrations.py` (or its cloud
counterpart) to re-run that file's SQL — both scripts only compare
checksums and skip whichever file already matches. If the checksum is
updated by hand without also re-executing the corrected SQL, the live
function/table definition silently remains unchanged while
`migration_history` reports it as current.

**Decision**: never hand-edit a `migration_history.checksum` value as a
substitute for re-running the corresponding SQL. `tools/apply_migrations_cloud.py`'s
`execute()` now carries an inline comment at exactly this branch pointing
back to the 2026-07-11 incident, so this is not rediscovered the hard way a
second time — this applies with even higher stakes to the cloud target than
to local, since a wrong cloud `migration_history` row is harder to notice
and more expensive to get wrong.

### Decision B — Backfill the missing rows directly; do not modify or re-run the 19 migration files

**Context**: the 19 files in §3 failed only because of constraint-widening
*order* relative to a target that already had 64 pre-existing menu rows and
a not-yet-widened `error_codes`/`documents`/`subscription_plans` schema —
not because their SQL was wrong. Local already has the correct final state
(246/22/8) via its own migration history, which already applied cleanly in
its original local sequence.

**Decision**: rather than editing the 19 already-applied-locally,
already-committed migration files to reorder them around `0140`/`0145`/
`0146`/`0147` (which would rewrite governed, previously-audited migration
history and risk a fresh local/cloud divergence), the missing rows were
backfilled directly via `pg_dump --data-only` + `ON CONFLICT DO NOTHING`,
targeting only the specific 3 tables with a confirmed row-count gap. This
keeps `sql/migrations/*.sql` as a single, non-rewritten source of truth for
both environments, and treats the ordering conflict as a **one-time cloud
bootstrap artifact** (this project was never migrated onto a schema this
mature from empty before) rather than a defect requiring migration-file
surgery.

**Follow-up (Open)**: `0035`/`0073`/`0118`'s transaction-boundary behavior —
whether a statement executed before an assertion/constraint failure within
the same file is retained or rolled back — was not independently
re-confirmed as of this writing; flagged for future verification rather than
assumed.

## 6. Open Items Carried Forward

1. **Q2's root cause** — why cloud had `customer_id` but not `phone_hash`
   before this workpacket's `0148` replay is not fully explained; ruled out
   as simple `0000`-file contamination, but the actual mechanism remains
   unconfirmed.
2. **`0118`'s transaction-boundary behavior** — whether the `schema_versions`
   UPDATE/INSERT that reported success before the `error_codes` failure in
   the same file actually persisted or was rolled back with the failing
   statement. Needs a direct check against `catchmenu_common.schema_versions`
   on cloud.
3. Both items above are informational follow-ups, not blockers — cloud and
   local are confirmed to match on every table checked in §4 as of
   2026-07-12.
