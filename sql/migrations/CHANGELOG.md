# sql/migrations Changelog

Single running file, append-only (per [000701 §30](../../docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md)). `catchmenu_meta.migration_history` is the data-level record (was X applied, when, checksum). This file is the narrative record (why X was necessary). Read this file in full before attempting any further fix to a migration listed here — do not re-litigate a decision already made below.

Backfilled 2026-07-10 covering the SQL migration verification pass (0034-0147).

## Constraint Widenings

Recognizable pattern across this pass: several `chk_*` enum constraints were written without anticipating later, legitimate values that later files needed. Resolved via evidence-based widening (confirmed zero prior DB precedent for the new values before adding them), never by guessing a remap into an existing value. Each required an out-of-band apply ahead of its file number, since no integer exists between two adjacent already-numbered files — each was flagged for explicit confirmation before touching the live DB.

- **0140** — `catchmenu_common.error_codes.chk_error_domain` += `MENU`, `STORE`, `AUDIT`. Needed by 0093's consolidated message/error catalog.
- **0145** — same constraint += `MEMBERSHIP`, `SECURITY`, `AI`. Needed by 0108 (membership pipeline), 0121 (security pipeline), 0123/0127 (AI customer center + embedding guide).
- **0146** — `catchmenu_knowledge.documents.chk_doc_type` += `SPEC`, `GUIDE`, `REPORT`, `EVIDENCE`; `chk_doc_domain` += `architecture`, `flutter`, `project`, `operation` (lowercased to match the existing all-lowercase domain convention; the 5 consumer files — 0113, 0119, 0132, 0134, 0135 — were updated in the same pass to use lowercase domain literals). Needed after restructuring those files' document INSERTs from a stale assumed schema (`document_title`/`content_ko`+`content_en`/`version_number`/`is_tenant_approved`/`effective_from`/`created_by`) to the real one (`title`/`content`+`content_locale`/`current_version`, no approval-boolean or author-tracking columns) — each bilingual document row was split into two rows (`_KO`/`_EN` suffixed codes).
- **0147** — `catchmenu_common.subscription_plans.chk_plan_tier` += `BASIC`, `FRANCHISE`. Needed by 0133's 5-tier pricing seed (TRIAL/STARTER/BASIC/PRO/FRANCHISE); `FRANCHISE` kept distinct from `ENTERPRISE` rather than merged, to preserve the original business intent (multi-store/franchise-specific tier vs. custom top-tier).

## Recurring Bug Classes

Each class below was found at least twice; on the second occurrence the rest of the not-yet-applied file range was proactively grep-scanned for the same pattern and fixed in one batch, per the §24 lightweight-track rule.

- **Nested procedure/function declared inside a `DECLARE` block** — PL/pgSQL has no syntax for this; the parser misreads the nested name as a variable and its parameter list as an attempted type. Compounded by a separate restriction: `CALL` cannot accept subquery expressions as arguments, so the fix is always a standalone function invoked via `PERFORM`, never a standalone procedure invoked via `CALL`. Two sub-patterns used depending on whether the nested block needs to feed accumulated state back to the caller (temp-table pattern) or just performs a direct UPDATE/INSERT (explicit-parameter pattern). Found and fixed in: 0073 (`assert_true`), 0090 (`run_security_audit`'s `add_audit_item`), 0091 (`run_saas_launch_checklist`'s `update_check`, `run_integration_test`'s `assert_test` — two separate instances in one file), 0092 (`health_check`'s `add_health`), 0096 (missed removing the old broken nested block after adding the replacement — caught via a `grep -n "^\s*procedure "` sweep).
- **jsonb cast-precedence**: `'frag1' || 'frag2'::jsonb` parses as `'frag1' || ('frag2'::jsonb)`, casting only the last fragment. Fix: wrap the full concatenation in parens before casting. Found in 0074 (1), 0075 (2), 0082 (4), 0083 (1), 0099 (7), 0110 (1) — 16 instances total, found via proactive repo-wide scan after the 2nd occurrence.
- **`ON CONFLICT` target column mismatch vs. the table's actual composite unique constraint** — most commonly `ON CONFLICT (function_code)` when the real constraint is `UNIQUE NULLS NOT DISTINCT (tenant_id, function_code)` on `edge_function_registry`. Fixed in 0071 (original diagnosis), 0075, 0083, 0092, 0119 (proactive scan finds). 0119 was a distinct sub-case: a copy-pasted `ON CONFLICT (tenant_id, function_code)` mistakenly applied to `edge_function_configs`, a different, tenant-less table with only a `function_code` unique constraint — fixed to `ON CONFLICT (function_code)`.
- **Function signature collision with an already-applied version of the same function** — a later file redefines a function with a different parameter order/defaults than an earlier already-applied file; Postgres refuses `CREATE OR REPLACE` when an existing parameter is renamed (`cannot change name of input parameter`). Each case confirmed no already-applied code depends on the old signature via explicit named/positional args before superseding via `DROP FUNCTION IF EXISTS` + fresh `CREATE OR REPLACE`. Found in: 0100 (`bootstrap_staff_app`, vs. 0070's original), 0116 (`get_customer_home`, vs. 0081's original), 0120 (`run_layer1_reconciliation`, vs. 0036's original — verified both already-applied cron-job callers in 0072/0095 only pass the unaffected leading params by name), 0123 (`submit_customer_inquiry`, vs. 0088's original — this one also had a genuine internal ordering bug, see below).
- **`:=` used where plain SQL `=` is required** — `:=` is PL/pgSQL assignment syntax, invalid inside a plain `UPDATE ... SET` clause. Found in 0109 (`offline_queue.server_result_id`), 0123 (`customer_inquiries.ai_confidence`).
- **Missing required `p_store_id` parameter in `log_diagnostic()` calls** — every other call site in the codebase passes `p_store_id` immediately after `p_tenant_id` (no default exists for it). Fixed in 0093 (2 calls), 0094, 0095, 0096 (system-wide events → `p_store_id := null`), 0112 (a real `v_store_id` variable was already in scope → used that instead of `null`), 0121 (global security scan, no store context → `null`). Also found in already-applied 0069, inside a stored function body — left unfixed since it's a latent runtime bug (dormant until that specific function is actually invoked), not a migration-blocking one; touching an already-applied file would break its checksum.
- **`sop_runbook_code`/`sop_document_code` name confusion on `error_codes`** — the real column is `sop_document_code`; `sop_runbook_code` doesn't exist on this table (it's a real column on the unrelated `operation_alerts` and `sop_runbooks` tables, which is what caused the confusion). Fixed in 0093 (established the mapping), then proactively batch-fixed in 0098, 0102, 0103, 0104, 0105, 0106, 0109, 0121, 0130 (9 files, identical copy-pasted INSERT column list).
- **`pg_cron_jobs.is_active` vs. the real `is_registered` column** — fixed in 0095 (established the mapping, both the INSERT column list and its `ON CONFLICT DO UPDATE SET` clause), then proactively batch-fixed in 17 more files sharing the identical copy-pasted INSERT template: 0097, 0102, 0103, 0104, 0107, 0109, 0118, 0120, 0121, 0122, 0123, 0124, 0126, 0129, 0130, 0131, 0132. Also found the same `is_active` confusion against `flutter_sdk_patterns` (0096) and `store_settings` (0132) — those two tables have no active/inactive concept at all, so the fix was to drop the filter / rename to the real closest column (`max_wait_number`) rather than assume a shared root cause with the `pg_cron_jobs` case.
- **Duplicate `error_key` registrations** — several files re-declared error keys already registered by an earlier already-applied file, always with identical category/status/severity, differing only in code number/domain (confirms accidental re-declaration, not a deliberate second condition). Batch-deduplicated in 0093 (22 rows), 0118 (11 of 14 rows), 0123 (2 of 4 rows), 0130 (1 of 6 rows) — kept the earlier, already-applied, canonical registration each time.
- **`schema_versions` seed using a stale assumed column set** (`version_name`/`migration_range`/`deployed_at` instead of the real `description`/`migration_count`/`applied_at`, with `migration_count` — a required `NOT NULL` column — entirely absent from the stale version) — fixed in 0096 (established the table's real shape + added `ON CONFLICT (version_code) DO UPDATE` for idempotent re-run safety after a self-inflicted partial-commit), then the same INSERT-side mapping applied to 0118, 0133, 0134, 0135.
- **`sop_runbooks` seed using a stale assumed column set** (`runbook_title`/`target_domain`/`trigger_condition`/`steps`/`escalation_path`/`estimated_resolution_minutes` instead of the real `runbook_name`/`runbook_domain`/`symptom_description`/`recovery_steps`/`escalation_contact`/`escalation_threshold_minutes`) — the `escalation_path` field was originally a jsonb array of tiered escalation rules, but the real `escalation_contact` column is a single text field, so each array was collapsed into one `' / '`-joined string. Fixed in 0118 (established the mapping), then 0121, 0129, 0130 (proactive scan finds).

## One-Off Fixes (not part of a recurring class)

- **0034** — removed a SQL-level safety guard (`do $$ ... if current_database() not like '%dev%' and not like '%test%' and not like '%local%' then raise exception ... end $$;`) that was structurally broken: Supabase local and hosted projects both default to a database literally named `postgres`, so a name-substring check can never reliably distinguish dev/test/local from production. Enforcement moved to the application layer instead — `tools/apply_migrations.py`'s `confirm_local_target()` does a live `docker inspect` check of the running container's `com.supabase.cli.project` label before allowing any seed-named file to run. This is the precedent [000701 §24](../../docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md)'s AUTO-FIX criterion (c) — "a guard/check structurally wrong the same way as 0034's DB-name guard" — refers back to directly.
  - Verified via `git diff HEAD -- sql/migrations/0034_seed_data.sql` (19 lines changed) 2026-07-10; this is the only file in the 0034-0064 range with any working-tree diff — 0035-0064 all applied cleanly with no fix needed (confirmed via `git diff --stat HEAD` across the full range, and `catchmenu_meta.migration_history` showing all as `success = true` with no recorded error message).
- **0069** — split the original single `document_embeddings` table (hardcoded `vector(1536)`) into `document_embeddings_1536`/`_3072`/`_4096` with `embedding_models` registry-driven dimension routing. This was a deliberate redesign, not a bugfix, but it rippled into 0073 (6 stale references), 0089 (deferred — see below), and 0096 (3 stale references).
- **0071** — `edge_function_templates.function_id` added as a `NOT NULL` FK to `edge_function_registry(id)` (keeping `function_code` as a denormalized display column); this rippled into 0075, which also inserts into `edge_function_templates` and needed the new column + a lookup subquery added.
- **0092** — `edge_function_registry` INSERT included a `description` column that doesn't exist on the already-applied table. Stripped from the INSERT and its `ON CONFLICT` clause (data discarded, not persisted) rather than creating a one-off forward migration mid-batch, per the "batch schema additions, don't apply them ad hoc" rule. Also fixed: `'SCHEDULE'` → `'SCHEDULED'` (typo, `chk_trigger_type` only allows the latter), and `flutter_sdk_patterns.pattern_category` invalid values `'UI_PATTERN'`/`'UTILITY'` (×2) remapped to `'RPC_CALL'`/`'I18N'`/`'ERROR_HANDLING'` based on each row's actual Dart code content.
- **0110** — `idx_store_holidays` partial index predicate used `current_date`, a `STABLE`-not-`IMMUTABLE` function; Postgres disallows non-immutable functions in index predicates. Fixed by dropping the predicate (full index instead of partial).
- **0132** — 1호점 seed's `store_settings` UPDATE referenced `max_waiting_count` (real: `max_wait_number`) and three columns with no equivalent anywhere in the schema at all (`min_order_amount`, `receipt_print_enabled`, `cash_receipt_auto` — confirmed `min_order_amount` only exists on the unrelated `coupons`/`promotions` tables). Renamed the one real match, dropped the three non-existent assignments.
- **0133** — `subscription_plans` INSERT used `monthly_price_krw`/`max_menus` (real: `monthly_fee`/`max_menu_items`); the `FRANCHISE` row passed `null` for the `NOT NULL` `max_stores`/`max_menu_items` columns, fixed by applying the same "effectively unlimited" sentinel convention already established by 0082's already-applied `ENTERPRISE_CUSTOM` seed row (`99`/`9999`).
- **0141** — `ADD CONSTRAINT IF NOT EXISTS` is not valid Postgres syntax (unlike `ADD COLUMN IF NOT EXISTS`); rewritten as `DROP CONSTRAINT IF EXISTS` + plain `ADD CONSTRAINT`. Separately, three `menu_option_groups`/`menu_option_items` seed INSERTs omitted required `NOT NULL` columns (`store_id`, `group_code`, `tenant_id`, `item_code`) entirely; fixed by pulling `tenant_id`/`store_id` from the joined menu/group row and generating deterministic codes (`KB001_<TYPE>[_ord]`).

## Duplicate/Partial-Commit Self-Healing

- **0096** — a prior failed run had already committed the `schema_versions` INSERT's target row before failing later in the same file; re-running hit a duplicate-key error on retry. Fixed by adding `ON CONFLICT (version_code) DO UPDATE` (idempotent re-run safety), then applied the same idiom preventively to the 0118/0133/0134/0135 `schema_versions` inserts.
- **0091** — self-inflicted: explanatory comments written before a mechanical `call X(` → `perform Y(` regex swap contained literal old-pattern text, which the regex then also corrupted, breaking two `--` continuation-comment blocks. Fixed by rewriting the comments as prose, avoiding literal code-shaped fragments before any future regex-based mechanical edit.

## Deferred (Architecture/Content Decisions, Not Resolved This Pass)

- **0081** — `customer_order_history` view + 3 dependent query blocks commented out; `customer_id`/`customer_token` relationship to `order_sessions`/`orders` is undesigned. Do not re-enable until that linkage is explicitly designed.
- **0089** — entire file deferred; duplicates 0069's already-validated pgvector knowledge infrastructure (own `document_embeddings` table, own `register_embedding`/`search_knowledge`/`verify_answer_grounding` with a different signature). 0069 is canonical. This file's genuine unique value (SOP document lifecycle) should eventually be rewritten to call into 0069's storage/search functions instead of duplicating them.
- **0099** — table/seed/`get_realtime_config` deferred; 0068 (already applied, live, already validated by 0073's passing seed-count assertion) established `realtime_channels` with a Postgres-CDC + role-based-access model. This file's incompatible broadcast-based redesign (device-type + role targeting) never took effect. If device-type targeting is genuinely needed, it requires a new forward migration extending 0068's actual live schema, not a competing table definition. Note: `broadcast_store_event` (kept active in this same file) still references `last_broadcast_at`/`broadcast_count` on `realtime_channels`, columns that don't exist on 0068's schema either — a latent runtime bug, not fixed (out of the deferral's stated scope), only flagged.
- **0101** — entire vision-document INSERT deferred; the source file is genuinely truncated mid-generation (opens a `$ko$` dollar-quote, cuts off mid-sentence, no closing tag, no `content_en`, no remaining columns). Not recoverable from elsewhere in the repo. Investor/partner-facing business narrative content — must be authored by a human, not reconstructed by AI.

## 2026-07-11 — order_sessions.customer_id 컬럼 부재 확인 및 원인 재분류 (환경 드리프트 아님, 순수 SQL 결함으로 확정)

d9d90ce 커밋 메시지("SQL migration verification 0000-0147, 147/147
succeeded")를 근거로 0115/0116이 order_sessions.customer_id를
참조하는 게 정합적이라고 잠정 판단했었으나, 다음 5개 독립 확인을
통해 해당 self-report가 이 항목에 한해 부정확했음을 확정함:

1. 0012_create_pos_order_sessions.sql 원본 컬럼 목록에 customer_id
   없음 (customer_token text만 존재)
2. 전체 sql/migrations/*.sql grep — 해당 컬럼을 추가하는 ALTER 없음
3. 로컬 Supabase(127.0.0.1:54322) information_schema 조회 — 컬럼 없음
4. 클라우드 Supabase(upzthfwhtvazfftxnyfu) information_schema 조회 —
   컬럼 없음
5. supabase db diff --linked 결과 "No schema changes found" —
   로컬/클라우드 스키마 완전 동일, 드리프트 아님을 재확인

0081_create_customer_app_rpc.sql의 자체 DEFERRED 주석(컬럼 없음)은
정확했음. 0115/0116_...sql은 이 사실을 인지하지 못한 채 작성되어
order_sessions.customer_id를 전제로 한 INSERT/SELECT를 다수 포함 —
현재 라이브 실행 시 "column does not exist" 에러 발생 대상.

세 조각(0097 전화+OTP 로그인, 0081 customer_app_sessions,
0115/0116 order_sessions.customer_id)의 고객 정체성 모델
(catchmenu_store.customers) 자체는 상호 정합적이며 폐기 대상 없음.
필요한 조치는 단 하나의 forward migration (order_sessions에
customer_id uuid FK 컬럼 추가)뿐.

부수 확인: sql/migrations/ 아래 4자리 순번 SQL 파일 관례는 처음부터
일관되게 사용되어 왔으며 000701 §28/§30/§33과 990000_legacy_quarantine의
다수 선행 워크패킷(604250-604526 등)에 이미 광범위하게 문서화·실증되어
있음. 다만 Supabase CLI의 표준 마이그레이션 추적(supabase/migrations/,
supabase migration list/db push)은 이 관례와 처음부터 별개로 전혀
사용된 적이 없었음 — 선행 워크패킷들도 전부 ls/docker cp 방식의 직접
검증만 사용했음. config.toml에도 sql/migrations 경로 참조가 없어,
CLI가 이 이력을 인식하지 못하는 것은 설계상 당연한 결과였음. 결함이
아니라 두 개의 독립적인 도구 체계가 처음부터 공존해온 것.

Supersedes: d9d90ce 커밋 메시지의 "147/147 succeeded" 주장을
order_sessions.customer_id 관련 부분에 한해 정정함 (다른 146개
항목의 정확성에 대해서는 판단하지 않음 — 이번 조사는 이 1개 항목만
재검증했음).

Next: order_sessions.customer_id 추가 forward migration — 별도
DesignPack.md 초안 작성 완료, Human Approval 대기.

## 2026-07-11 — 0148 order_sessions customer identity FK and guest flag

- **0148** — adds the approved forward migration for `catchmenu_pos.order_sessions.customer_id`, `catchmenu_pos.order_sessions.phone_hash`, and `catchmenu_store.customers.is_guest`.
- Required because 0115/0116 already reference `order_sessions.customer_id`/`phone_hash`, while 0012 did not create those columns and the earlier local DB state had only an out-of-band, untracked partial application.
- Cleans the local out-of-band `order_sessions.customer_id` FK/index/column first, then recreates the canonical spec with `ON DELETE SET NULL` rather than the previous local `ON DELETE NO ACTION`.
- Recreates `idx_order_sessions_customer` as the approved partial index (`WHERE customer_id IS NOT NULL`) and records comments for the new columns.
- Does **not** resolve the three open items from the approved design packet: 005015 wording/policy revision, anonymous guest dedupe, or the duplicate 604500 folder/workpacket issue.

## 2026-07-11 — 0149 guest customer bootstrap helper and RPC entry patch

- **0149** — creates `catchmenu_store.get_or_create_guest_customer(p_tenant_id uuid, p_phone_hash text default null)` and forward-patches `catchmenu_pos.register_waiting(...)` plus `catchmenu_store.bootstrap_customer_app_v2(...)` with `CREATE OR REPLACE FUNCTION`.
- Required because 0148 made `order_sessions.customer_id`/`phone_hash` real, but callers that omitted `p_customer_id` still needed a DB-side guest customer bootstrap path.
- The helper uses `ON CONFLICT (tenant_id, phone_hash) DO UPDATE SET updated_at = now()` and intentionally keeps `is_guest` out of the `DO UPDATE SET` list, preserving already-promoted `is_guest = false` customers on repeat same-phone_hash guest calls.
- Direct helper execution is not granted to `authenticated`; access is intended through the existing SECURITY DEFINER entry RPCs.
- Verification note: helper-only scenarios passed (new phone_hash creates `is_guest=true`, same phone_hash returns the same id, promoted `is_guest=false` is preserved, anonymous no-phone calls create distinct rows). The full 0115/0116 entry-RPC scenarios were blocked by pre-existing runtime column references outside the approved 0149 logic: `register_waiting()` still references missing `store_settings.max_waiting_count` (real column: `max_wait_number`), and `bootstrap_customer_app_v2()` still references missing `store_settings.min_order_amount`.

## 2026-07-11 — 0115/0116/0149 live-function column audit and 0150 waiting event domain widening

- **§24 live-function lesson** — checksum updates only change `catchmenu_meta.migration_history`; they do not re-run already-applied function DDL. Any future §24 in-place SQL function fix must update source, sync checksum, and then explicitly re-execute the affected live function definition (for this round, `0149_create_guest_customer_bootstrap_rpc.sql` was re-run with `docker exec ... psql`) before treating the runtime as fixed.
- **Column audit fixes across 0115/0116/0149** — audited the live `pg_get_functiondef()` bodies for `catchmenu_pos.register_waiting(...)`, `catchmenu_store.bootstrap_customer_app_v2(...)`, and `catchmenu_store.get_or_create_guest_customer(...)` against actual table columns. Fixed stale references: `store_settings.max_waiting_count` → `max_wait_number`; removed nonexistent `store_settings.min_order_amount` and emitted payload literal `0`; removed nonexistent `order_sessions.memo` and `order_sessions.pre_order_amount` from the target register_waiting insert path; mapped `customers.total_points` → `point_balance`; mapped `customers.locale` → `preferred_locale`; mapped menu preview `m.thumbnail_url` → `m.image_url`.
- **0150** — widens `catchmenu_ledger.events.chk_event_domain` to include `waiting`, preserving every existing allowed value. This is required because `register_waiting()` records `event_domain = 'waiting'`; without 0150, the §24 function fixes and 0149 guest-customer bootstrap path still fail at the ledger insert constraint even after the target stale column references are corrected.
- **Total points/spend follow-up audit** — extended the same §24 procedure to every live function still carrying `customers.total_points` / `customers.total_spent_amount` lineage. Confirmed actual columns are `catchmenu_store.customers.point_balance` and `catchmenu_store.customers.lifetime_spend`. Updated source/live definitions for `0081_create_customer_app_rpc.sql`, `0097_create_auth_login_pipeline_rpc.sql`, `0108_create_membership_pipeline_rpc.sql`, `0116_create_customer_app_bootstrap_rpc.sql`, and `0149_create_guest_customer_bootstrap_rpc.sql` as applicable. The corrected live functions are `bootstrap_customer_app`, `place_takeout_order`, `customer_login`, `get_auth_context`, `earn_points_after_order`, `get_customer_membership`, `get_membership_dashboard`, `bootstrap_customer_app_v2`, and `get_customer_home`. JSON payload keys such as `total_points` and `total_spent_amount` were preserved for response compatibility while backing column reads now use `point_balance` / `lifetime_spend`.
- **Post-total-audit verification result** — helper scenarios pass, `bootstrap_customer_app_v2()` now completes successfully through the former `get_customer_membership(...)` total-column blocker, and `pg_get_functiondef()` confirms no audited live function has stale `total_points` / `total_spent_amount` column references. `register_waiting()` initially hit `chk_event_caused_by_type` because the verification SQL passed `p_source := 'LOCAL_VERIFICATION'`, which the function intentionally writes to `caused_by_type`. Re-running the same scenario with the allowed value `p_source := 'STAFF'` succeeded end-to-end. Final conclusion: `register_waiting()` and `bootstrap_customer_app_v2()` both work end-to-end after 0149/0150 plus the Human-approved §24 stale-column fixes.

Supersession note for the older lightweight-bugfix memo below: that memo was
written before the subsequent §24 live-function audit. As of the total-points
follow-up pass, `0149_create_guest_customer_bootstrap_rpc.sql` has been updated,
checksum-synced, and directly re-executed against the local Docker database with
`docker exec ... psql`; `pg_get_functiondef()` confirms the target live
functions no longer contain the audited stale references. The former downstream
`catchmenu_store.get_customer_membership(...)` `customers.total_points` /
`customers.total_spent_amount` blocker has also been fixed and directly
re-executed. The remaining blocker observed by `600123_TestPlan.md` is now
`chk_event_caused_by_type` on the `register_waiting()` ledger insert path, not
a stale customer total column.

## 2026-07-11 — Lightweight Bugfix: register_waiting/bootstrap_customer_app_v2 stale column names (§24, Human-authorized)

- 발견 경위: 600123_TestPlan.md(600120 워크패킷) 전체 검증 실행 중 (위 0149 항목의 "Verification note" 참고)
- register_waiting(): `store_settings.max_waiting_count` 참조 → 실제 컬럼 `max_wait_number`로 정정 (`\d catchmenu_store.store_settings` 재확인: `max_wait_number integer not null default 999`, "대기 최대 인원 제한" 의미와 일치)
- bootstrap_customer_app_v2(): `store_settings.min_order_amount` 참조 → `store_settings`에 대응 컬럼이 전혀 없음을 전체 컬럼 목록으로 확인 (`minimum_order_amount`, `min_pre_order_amount` 등 유사명도 없음). 해당 필드를 SELECT에서 제거하고, 응답 JSON의 `min_order_amount` 키는 이 개념이 애초에 구현된 적 없다는 주석과 함께 하드코딩된 `0`으로 대체
- 근본 원인: 이 컬럼들은 원래부터 존재한 적 없음 — 함수 작성 시 의도한 컬럼명과 실제 0049(`store_settings` 정의)의 컬럼명이 처음부터 불일치했던 것으로 추정 (신규 회귀 아님)
- 이 fix는 600120(guest_customer_bootstrap_rpc)의 승인 범위 밖이지만, 그 워크패킷의 TestPlan 실행 중 발견되어 §24 트랙으로 Human 승인 하에 즉시 수정함. **600120과 무관한 독립 §24 fix** — 600120의 Module/Verification/Audit 문서와 혼동하지 말 것
- **중요한 범위 제약**: `0115`/`0116` 파일 자체를 패치했으나, 라이브 DB에서 실제 실행되는 함수 본문은 이미 `0149`가 `CREATE OR REPLACE FUNCTION`으로 재선언한 버전이며, `0149`는 이 fix의 대상이 아니었다(Human 결정 — 0149는 건드리지 않음). 따라서 **이 fix는 0115/0116 파일의 소스 정합성만 복원하며, 라이브 DB의 버그(0149 안의 동일한 stale 컬럼 참조)는 여전히 미해결 상태로 남아있다.** 라이브 버그 해결은 별도 결정 필요.
- 영향받은 파일의 migration_history 체크섬 갱신 필요 (아래 참고)

## 2026-07-11/12 — Cloud migration full replay (0000-0150) and data backfill

- Full sequential replay of sql/migrations/0000-0150 against cloud project upzthfwhtvazfftxnyfu via tools/apply_migrations_cloud.py (newly created this session, pooler-connection + .pgpass based)
- Cloud project was NOT empty prior to replay: contained 64 pre-existing dev/test menu rows (created 2026-07-01) and several already-existing tables (edge_function_configs, device_groups, device_commands, subscription_plans/invoices)
- 19 files (0035, 0073, 0093, 0100, 0107, 0108, 0110, 0113, 0114, 0118, 0119, 0121, 0122, 0123, 0126, 0127, 0131, 0132, 0133, 0134, 0135) hit constraint-widening-order issues (chk_error_domain, chk_doc_domain, chk_plan_tier all widened later by 0140/0145/0146/0147) or forward-referenced objects (0073 expecting 0144's cron_job_executions/run_daily_close_batch). All manually accepted into catchmenu_meta.migration_history with documented reasons after Human review - NOT fixed by editing the source files, since local files were already correct and verified.
- Post-0147, backfilled 52 error_codes rows, 22 documents rows, and 4 subscription_plans rows into cloud via pg_dump --data-only --column-inserts with ON CONFLICT DO NOTHING, restoring local/cloud parity (246/22/8 on both sides, verified).
- Full detail: docs/600000_implementation_lifecycle/600300_cloud_local_migration_sync/600310_initial_cloud_state_audit/600311_Overview.md

## 2026-07-18 — 0160-0164 (backfilled; full narrative lives in each workpacket's ChangeContract, not duplicated here)

Note: entries for `0151`-`0159` are also missing from this file and were **not** backfilled in this pass (out of scope for the turn that added this section) — see the "Convention status" note at the end of this file.

- **0160** — `call_waiting_customer_contract_recovery` (`600640`). Replaces phantom `order_sessions` concepts (`called_at`/`table_number`/`call_count`/`pre_order_amount`) referenced by `catchmenu_pos.call_waiting_customer()` with `session_events`-derived values, request/response payload, and `orders.final_amount` LEFT JOIN. Adds internal `_record_waiting_call()`, new `call_next_waiting_customer()` with `SKIP LOCKED`, drops the legacy `0050` `call_next_waiting()` overload. Full detail: `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600644_ChangeContract.md`.
- **0161** — `mark_no_show_overload_and_redesign` (`600630`). Registers no-show error keys, adds `kds_tickets.hold_expires_at`, creates shared `apply_no_show_transition()` core plus manual/automatic/KDS-grace functions, drops the legacy `0050` `mark_no_show()` overload, rewrites `0118`'s `WAITING_SESSION_EXPIRE` batch job to call store-scoped functions instead of phantom-column inline updates. Full detail: `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600634_ChangeContract.md`.
- **0162** — `dining_table_crud_creation` (`601120`). Creates `catchmenu_store.upsert_dining_table()`/`set_dining_table_active()`/`get_dining_table_admin_list()` — dining table admin CRUD did not exist before this (tables were seed-only via `0034`). Full detail: `docs/600000_implementation_lifecycle/601100_store_admin_console/601120_dining_table_crud_creation/601124_ChangeContract_Dining_Table_Crud_Creation.md`.
- **0163** — `seat_waiting_customer_facade_correction` (`600650`). Rewrites `catchmenu_pos.seat_waiting_customer()` (crashed on every call, phantom `order_sessions.table_number` write) as a thin facade delegating to the canonical `catchmenu_pos.bind_table_to_session()` (`0025`, unmodified) via a new resolver `_resolve_dining_table_by_number()`. Full detail: `docs/600000_implementation_lifecycle/600600_waiting_order_session/600650_seat_waiting_customer_facade_correction/600654_ChangeContract_Seat_Waiting_Customer_Facade_Correction.md`.
- **0164** — `waiting_pipeline_sibling_functions_correction` (`600660`). Corrects the remaining 4 `0115` functions broken by the same phantom-`order_sessions`-column class as `0160`/`0163`: `confirm_arrival()` rewritten as a facade delegating to the previously-orphaned `catchmenu_pos.mark_session_arrived()` (`0025`, unmodified); `get_waiting_status()`/`get_waiting_admin_view()` corrected via `orders`/`dining_tables` LEFT JOINs and `session_events`-derived `called_at`/`call_count`; `cancel_waiting()`'s phantom `cancel_reason` write dropped (ledger event is the sole source of truth). Also removes `get_waiting_admin_view()`'s hardcoded `patent_note` response field (a separate, independently Human-approved response-contract change, not a phantom-column fix). Full detail: `docs/600000_implementation_lifecycle/600600_waiting_order_session/600660_waiting_pipeline_sibling_functions_correction/600664_ChangeContract_Waiting_Pipeline_Sibling_Functions_Correction.md`.

**Convention status**: this file's stated purpose ("single running file, append-only... read before any further fix") has not actually been kept current — the previous entry above is dated 2026-07-11/12, and by the time this backfill pass ran, migrations `0151` through `0164` (14 files) had shipped with no entry here, including two in-place-synchronization workpackets (`601110`/`601140`, both touching `0110`) that this file's own model does not obviously cover (it documents *new numbered files*, not in-place edits to an already-numbered file). In practice, the `docs/600000_implementation_lifecycle/` per-workpacket documentation (Overview/Logic/TestPlan/ChangeContract, or ChangeContract-embedded Module/Verification/Audit) has become the actual narrative record for every migration since at least `0151` — each is far more detailed than this file's format. This suggests the convention is **de facto superseded**, not actively dead by decision — no one decided to stop, the more rigorous per-workpacket system simply made this file redundant in practice. Recommend Human decide explicitly: (a) formally retire this file with a pointer to the per-workpacket system, or (b) resume maintaining it and backfill `0151`-`0159` separately. Not resolved by this pass.
