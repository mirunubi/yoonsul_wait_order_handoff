# 600301_ChangeHistory.md

Per `000701` §30 — single running file, append-only. One row per change.

| Date | Change Description | Reason/Evidence | Outcome | Linked Audit/Test |
|---|---|---|---|---|
| 2026-07-11/12 | Full cloud migration sync: sequential replay of `sql/migrations/0000`–`0150` against cloud project `upzthfwhtvazfftxnyfu` via `tools/apply_migrations_cloud.py`, 19 files skipped/accepted after root-cause review (constraint-widening order, forward references), data backfill of 52 `error_codes` / 22 `documents` / 4 `subscription_plans` rows | Cloud had never been synced to the current local migration history (`catchmenu_meta` schema absent, per Q7); cloud also carried 64 pre-existing dev/test menu rows not reflected in local expectations | ACCEPT — cloud/local verified matching on all three backfilled tables (246/22/8 both sides) as of 2026-07-12 | `600311_Overview.md` |
