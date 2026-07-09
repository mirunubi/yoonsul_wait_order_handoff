# 604389_Analysis_SQL_Migration_Residue_Disposition_Before_Scope_D_Resume.md

Status: Complete
Lifecycle: Analysis
Gate Classification: SQL/Migration Residue Disposition — Pre-Scope-D-Resume Stage 1 Analysis
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-05

This is an analysis document only. It classifies SQL/migration working-tree
residue and proposes disposition directions. It performs no SQL edit, migration
edit, reset, discard, rename, staging, or commit. It does not create 0069
Analysis and does not resume Scope D mainline.

Authority:

```text
604388_Human_Decision_Gate_Worktree_Residue_Disposition_Before_Scope_D_Resume.md
Final Human Decision:
  OPEN_SQL_MIGRATION_RESIDUE_DISPOSITION_ANALYSIS_FIRST_WITH_SCOPE_D_MAINLINE_AND_0069_STILL_BLOCKED
```

Starting basis:

```text
604383-604387 quarantine-policy track: CLOSED / committed (ea50da00)
604387 closure accepted; residue manifests adopted as current
```

See `docs/000015_Korean_Document_And_Encoding_Safety_Rules.md` for encoding rules.

---

## 1. Analysis Scope

```text
In scope:
  - Classification of all 21 SQL/migration residue paths
  - Read-only diff inspection and SHA256 pair comparison
  - Disposition recommendations (proposals only)
  - Whether Scope D mainline / 0069 Analysis remain blocked
  - Whether 604390 Approval Gate is required next

Out of scope:
  - SQL/migration modification, staging, reset, discard, rename
  - tools/* remediation (noted as deferred reference only)
  - 0069 Analysis creation
  - Scope D mainline resume
  - runtime code changes
  - Lane assignment certainty for unapproved new migrations (0136/0139/0141/seed)
```

---

## 2. Commands Executed

All commands below were run from repository root on 2026-07-05:

```powershell
git log --oneline -5
git status --short
git diff --check
git diff --cached --name-only
git status --short -- sql/ sql/migrations/
git diff --name-status -- sql/ sql/migrations/
git diff -- sql/migrations/0035_verify_schema.sql
git diff -- sql/migrations/0038_create_toss_webhook_processor_rpc.sql
git diff -- sql/migrations/0042_create_delivery_order_intake_rpc.sql
git diff -- sql/migrations/0046_create_context_builder_rpc.sql
git diff -- sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql
git diff -- sql/migrations/0065_create_security_isolation_rpc.sql
git diff -- sql/migrations/0066_create_ledger_integrity_rpc.sql
git diff -- sql/migrations/0067_create_cron_scheduler_rpc.sql
git diff -- sql/migrations/0068_create_realtime_edge_rpc.sql
git diff -- sql/migrations/0138_patch_integration_functions.sql
git status --short | Select-String '0069|604389|604390|604391|604392|604393'
```

Additional read-only checks:

```text
SHA256 compare HEAD tracked 024/030/032 vs untracked 0024/0030/0032
Read-only first-line / size inspection of 0142, 0136, 0139, 0141, seed
glob search *0069*Analysis*.md under docs/
```

No staging or commit was performed by this Analysis.

---

## 3. Repository Gate State

### 3.1 Recent commits

```text
ea50da00 docs: record worktree quarantine before Scope D resume
9902bd37 docs: add parent workpacket navigation map
62813e10 docs: close directory artifact correction and metadata drift tracks
177007d2 sql: add 0137-0138 patch missing functions
1b123dbd docs: add 900150 phase validation plan
```

### 3.2 Staging and diff --check

```text
git diff --cached --name-only : empty
staged SQL/migration files       : none
git diff --check                 : exit 0 (PASS)
```

### 3.3 Filter scan

```text
git status --short | Select-String '0069|604389|604390|604391|604392|604393'
  : no 0069 Analysis artifact; 604390-604393 not yet created at analysis time
```

---

## 4. SQL / Migration Residue Manifest (21 Paths)

Independent `git status --short -- sql/ sql/migrations/` confirms:

```text
Tracked modified (10):
  M sql/migrations/0035_verify_schema.sql
  M sql/migrations/0038_create_toss_webhook_processor_rpc.sql
  M sql/migrations/0042_create_delivery_order_intake_rpc.sql
  M sql/migrations/0046_create_context_builder_rpc.sql
  M sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql
  M sql/migrations/0065_create_security_isolation_rpc.sql
  M sql/migrations/0066_create_ledger_integrity_rpc.sql
  M sql/migrations/0067_create_cron_scheduler_rpc.sql
  M sql/migrations/0068_create_realtime_edge_rpc.sql
  M sql/migrations/0138_patch_integration_functions.sql

Tracked deleted (3):
  D sql/migrations/024_create_store_bootstrap_rpc.sql
  D sql/migrations/030_create_manual_fallback_rpc.sql
  D sql/migrations/032_create_agent_action_rpc.sql

Tracked added (1):
  A sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql

Untracked (7):
  ?? sql/migrations/0024_create_store_bootstrap_rpc.sql
  ?? sql/migrations/0030_create_manual_fallback_rpc.sql
  ?? sql/migrations/0032_create_agent_action_rpc.sql
  ?? sql/migrations/0136_create_dev_audit_log.sql
  ?? sql/migrations/0139_create_ai_inference_log.sql
  ?? sql/migrations/0141_hyper_personalization_menu_customization.sql
  ?? sql/migrations/seed_yoonsul_menu.sql
```

Match to 604383 / 604387 manifest: **YES** (same 21 paths).

---

## 5. Per-File Classification Table

Legend for **approval trace**: this Analysis does **not** confirm whether a
working-tree change is already Human-approved for commit; it records that an
approval trace must be resolved in 604390+ before any disposition action.

| Path | Git state | Mig # | Category | Lane / relation (candidate only) | Risk | Recommended disposition | Blocks Scope D mainline | Blocks 0069 Analysis | Separate Approval Gate |
|---|---|---:|---|---|---|---|---|---|---|
| 0035_verify_schema.sql | modified | 0035 | REPLAY_BLOCKER_REVIEW_REQUIRED | 604270 baseline replay blocker candidate | HIGH | KEEP_FOR_SEPARATE_APPROVAL after replay evidence review | YES | YES | YES |
| 0038_create_toss_webhook_processor_rpc.sql | modified | 0038 | REPLAY_BLOCKER_REVIEW_REQUIRED | 604270 syntax-fix candidate (:= → =) | MEDIUM | KEEP_FOR_SEPARATE_APPROVAL | YES | YES | YES |
| 0042_create_delivery_order_intake_rpc.sql | modified | 0042 | REPLAY_BLOCKER_REVIEW_REQUIRED | 604280 0042 blocker candidate | MEDIUM | KEEP_FOR_SEPARATE_APPROVAL | YES | YES | YES |
| 0046_create_context_builder_rpc.sql | modified | 0046 | REPLAY_BLOCKER_REVIEW_REQUIRED | 604300 0046 replay-recovery candidate | HIGH | KEEP_FOR_SEPARATE_APPROVAL | YES | YES | YES |
| 0063_patch_core_rpc_i18n_diagnostics.sql | modified | 0063 | REPLAY_BLOCKER_REVIEW_REQUIRED | 604300 0063 provider-payment-key candidate | MEDIUM | KEEP_FOR_SEPARATE_APPROVAL | YES | YES | YES |
| 0065_create_security_isolation_rpc.sql | modified | 0065 | REPLAY_BLOCKER_REVIEW_REQUIRED | 604300 0065 inline-procedure candidate | HIGH | KEEP_FOR_SEPARATE_APPROVAL | YES | YES | YES |
| 0066_create_ledger_integrity_rpc.sql | modified | 0066 | REPLAY_BLOCKER_REVIEW_REQUIRED | 604300 0066 aggregate-limit candidate | HIGH | KEEP_FOR_SEPARATE_APPROVAL | YES | YES | YES |
| 0067_create_cron_scheduler_rpc.sql | modified | 0067 | REPLAY_BLOCKER_REVIEW_REQUIRED | 604300 0067 duplicate-content removal candidate | HIGH | KEEP_FOR_SEPARATE_APPROVAL | YES | YES | YES |
| 0068_create_realtime_edge_rpc.sql | modified | 0068 | REPLAY_BLOCKER_REVIEW_REQUIRED | 604300 0068 unique-constraint candidate | MEDIUM | KEEP_FOR_SEPARATE_APPROVAL | YES | YES | YES |
| 0138_patch_integration_functions.sql | modified* | 0138 | BASELINE_DIFF_PENDING | integration patch lane candidate | LOW | UNKNOWN_REQUIRES_HUMAN_DECISION | INDIRECT | INDIRECT | YES |
| 024_create_store_bootstrap_rpc.sql | deleted | 024 | RENAME_REPAIR_CANDIDATE | paired with 0024; numbering repair candidate | MEDIUM | KEEP_FOR_SEPARATE_APPROVAL (no immediate rename) | YES | YES | YES |
| 030_create_manual_fallback_rpc.sql | deleted | 030 | RENAME_REPAIR_CANDIDATE | paired with 0030 | MEDIUM | KEEP_FOR_SEPARATE_APPROVAL (no immediate rename) | YES | YES | YES |
| 032_create_agent_action_rpc.sql | deleted | 032 | RENAME_REPAIR_CANDIDATE | paired with 0032 | MEDIUM | KEEP_FOR_SEPARATE_APPROVAL (no immediate rename) | YES | YES | YES |
| 0024_create_store_bootstrap_rpc.sql | untracked | 0024 | UNAPPROVED_NEW_MIGRATION_PENDING | paired with deleted 024 | MEDIUM | KEEP_FOR_SEPARATE_APPROVAL | YES | YES | YES |
| 0030_create_manual_fallback_rpc.sql | untracked | 0030 | UNAPPROVED_NEW_MIGRATION_PENDING | paired with deleted 030 | MEDIUM | KEEP_FOR_SEPARATE_APPROVAL | YES | YES | YES |
| 0032_create_agent_action_rpc.sql | untracked | 0032 | UNAPPROVED_NEW_MIGRATION_PENDING | paired with deleted 032 | MEDIUM | KEEP_FOR_SEPARATE_APPROVAL | YES | YES | YES |
| 0142_patch_toss_mvp_payment_intent_binding.sql | added | 0142 | UNAPPROVED_NEW_MIGRATION_PENDING | 604260 Scope D 00A candidate | HIGH | KEEP_FOR_SEPARATE_APPROVAL | YES | YES | YES |
| 0136_create_dev_audit_log.sql | untracked | 0136 | UNAPPROVED_NEW_MIGRATION_PENDING | dev-audit candidate (unassigned lane) | MEDIUM | KEEP_FOR_SEPARATE_APPROVAL | NO direct | NO direct | YES |
| 0139_create_ai_inference_log.sql | untracked | 0139 | UNAPPROVED_NEW_MIGRATION_PENDING | AI inference log candidate (unassigned lane) | MEDIUM | KEEP_FOR_SEPARATE_APPROVAL | NO direct | NO direct | YES |
| 0141_hyper_personalization_menu_customization.sql | untracked | 0141 | UNAPPROVED_NEW_MIGRATION_PENDING | menu customization candidate (unassigned lane) | MEDIUM | KEEP_FOR_SEPARATE_APPROVAL | NO direct | NO direct | YES |
| seed_yoonsul_menu.sql | untracked | seed | UNAPPROVED_NEW_MIGRATION_PENDING | seed data candidate (unassigned lane) | MEDIUM | KEEP_FOR_SEPARATE_APPROVAL | NO direct | NO direct | YES |

\* `0138`: `git status` shows `M`, but `git diff --numstat` and content diff are
empty even with `--ignore-cr-at-eol`. Treat as **baseline diff pending /
possible line-ending or index-stat drift** until Human confirms whether any
semantic change exists.

**Aggregate finding:** All 21 paths require **604390+ separate Approval Gate**
before any commit, discard, reset, or rename action. None are safe to fold into
Scope D mainline resume as-is.

---

## 6. Paired 024/0024, 030/0030, 032/0032 Analysis

### 6.1 Observed git pattern

```text
D  sql/migrations/024_create_store_bootstrap_rpc.sql
?? sql/migrations/0024_create_store_bootstrap_rpc.sql

D  sql/migrations/030_create_manual_fallback_rpc.sql
?? sql/migrations/0030_create_manual_fallback_rpc.sql

D  sql/migrations/032_create_agent_action_rpc.sql
?? sql/migrations/0032_create_agent_action_rpc.sql
```

### 6.2 SHA256 content comparison (read-only)

Reconfirmed independently (same result as 604383 §6):

```text
024 (HEAD tracked blob) vs 0024 (untracked WT): content_hash_match = False
030 (HEAD tracked blob) vs 0030 (untracked WT): content_hash_match = False
032 (HEAD tracked blob) vs 0032 (untracked WT): content_hash_match = False
```

### 6.3 Analysis conclusion

```text
- NOT pure renames.
- Classification: paired delete + separate unapproved untracked pending.
- Basename pattern suggests zero-pad numbering repair intent, but content
  differs; immediate git mv / rename repair is FORBIDDEN without 604390+.
- Recommended future options (604390 decides; not enacted here):
    A) formal rename + content reconciliation under explicit file list
    B) restore tracked 024/030/032 and discard untracked 0024/0030/0032
    C) adopt untracked versions and commit delete+add as separate approved set
    D) defer both sides pending broader numbering governance
- Separate Approval Gate required: YES
- Blocks Scope D mainline: YES (migration chain integrity unresolved)
- Blocks 0069 Analysis: YES (replay baseline order ambiguous while paired)
```

---

## 7. 0142 Tracked-Added Analysis

```text
Path: sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql
Git state: A (tracked added, unstaged, uncommitted)
Size: ~12,064 bytes
Header (read-only): Scope 604260 Toss MVP PaymentIntent Binding Precondition
```

**Classification:** `UNAPPROVED_NEW_MIGRATION_PENDING` — tracked-added but
**unapproved for commit**.

**Findings:**

```text
- Exists in working tree and index as added, but not committed.
- Relation candidate: 604260 Scope D 00A payment-intent binding lane.
- Pre-0142 baseline replay context: 0142 sits after 0138 in sequence; uncommitted
  0142 plus modified 0035-0068 residue means clean replay-to-0142 evidence is
  not trustworthy until disposition is closed.
- Scope D mainline blocker: YES — 604260 closeout/replay evidence cannot be
  judged while 0142 disposition is unresolved alongside earlier blocker edits.
- 0069 blocker: YES — 0069 sits after 0068 in replay chain; unresolved earlier
  migration residue contaminates any 0069 decision.
- Separate Approval Gate before commit: YES
- Must not be mixed with quarantine doc-only commits or tools track
```

**Recommended disposition (proposal only):** `KEEP_FOR_SEPARATE_APPROVAL` —
either commit under an explicit 604260-linked SQL Approval after replay pass,
or discard/defer if Human decides 604260 implementation path changes.

---

## 8. Modified Replay-Blocker Set (0035–0068, 0138)

This section summarizes **read-only** `git diff` character. Approval status is
**requires approval trace** only.

### 8.1 0035_verify_schema.sql

```text
Diff scale: ~681 insertions / 187 deletions
Character: large verification DO-block rewrite; removes nested procedure
  assert_true helper pattern
Relation candidate: 604270 baseline blocker (Class B verification rewrite)
Risk: HIGH
Category: REPLAY_BLOCKER_REVIEW_REQUIRED
Blocks Scope D / 0069: YES until replay evidence and approval trace exist
```

### 8.2 0038_create_toss_webhook_processor_rpc.sql

```text
Diff scale: 1 line
Character: UPDATE SET syntax fix (processing_error := → =)
Relation candidate: 604270 Class A syntax blocker
Risk: MEDIUM
```

### 8.3 0042_create_delivery_order_intake_rpc.sql

```text
Diff scale: 1 line
Character: UPDATE SET syntax fix (result_payload := → =)
Relation candidate: 604280 0042 blocker
Risk: MEDIUM
```

### 8.4 0046_create_context_builder_rpc.sql

```text
Diff scale: ~67 insertions / 60 deletions
Character: context-builder query/limit restructuring (LIMIT placement / subquery)
Relation candidate: 604300 0046 primary/secondary replay blockers
Risk: HIGH
```

### 8.5 0063_patch_core_rpc_i18n_diagnostics.sql

```text
Diff scale: ~15 insertions / 15 deletions
Character: multiple UPDATE SET clauses corrected (:= → =)
Relation candidate: 604300 0063 provider payment key assignment blocker
Risk: MEDIUM
```

### 8.6 0065_create_security_isolation_rpc.sql

```text
Diff scale: ~388 insertions / 146 deletions
Character: removes nested inline procedure helpers; large function-body refactor
Relation candidate: 604300 0065 security isolation replay blockers
Risk: HIGH
```

### 8.7 0066_create_ledger_integrity_rpc.sql

```text
Diff scale: ~139 insertions / 60 deletions
Character: replaces invalid jsonb_agg(id limit 5) with subquery-limited aggregates
Relation candidate: 604300 0066 ledger integrity blocker
Risk: HIGH
```

### 8.8 0067_create_cron_scheduler_rpc.sql

```text
Diff scale: ~11 insertions / 1341 deletions
Character: duplicate 0066 content removed; file replaced by short no-op safety
  migration noting prior duplication under "604320"
Relation candidate: 604300 0067 cron scheduler duplicate migration blocker
Risk: HIGH — sequence integrity critical
```

### 8.9 0068_create_realtime_edge_rpc.sql

```text
Diff scale: 2 lines
Character: UNIQUE constraint changed to UNIQUE NULLS NOT DISTINCT on tenant_id +
  function_code
Relation candidate: 604300 0068 realtime edge blocker (604328 audit context)
Risk: MEDIUM
```

### 8.10 0138_patch_integration_functions.sql

```text
git status: M
git diff content: empty (including ignore-cr-at-eol)
Character: possible line-ending / stat-only drift, or non-textual index delta
Category: BASELINE_DIFF_PENDING
Risk: LOW until proven otherwise
Recommendation: Human confirms whether to normalize line endings or leave untouched
```

### 8.11 Modified-set summary

```text
All nine substantive modified replay files (0035, 0038, 0042, 0046, 0063-0068)
are REPLAY_BLOCKER_REVIEW_REQUIRED and KEEP_FOR_SEPARATE_APPROVAL.
They collectively block Scope D mainline and 0069 Analysis until:
  1) approval trace is reconciled per file or approved path-group, and
  2) clean replay evidence is produced under 604390+ authorized disposition.
0138 is isolated as BASELINE_DIFF_PENDING / UNKNOWN_REQUIRES_HUMAN_DECISION.
```

---

## 9. Untracked 0136 / 0139 / 0141 / seed Analysis

| Path | Size (bytes) | Read-only header hint | Classification |
|---|---:|---|---|
| 0136_create_dev_audit_log.sql | 15,209 | Dev-only audit log; drop before production | UNAPPROVED_NEW_MIGRATION_PENDING |
| 0139_create_ai_inference_log.sql | 15,998 | AI inference logging candidate | UNAPPROVED_NEW_MIGRATION_PENDING |
| 0141_hyper_personalization_menu_customization.sql | 13,417 | Menu customization candidate | UNAPPROVED_NEW_MIGRATION_PENDING |
| seed_yoonsul_menu.sql | 34,871 | Seed data script | UNAPPROVED_NEW_MIGRATION_PENDING |

**Rules applied:**

```text
- No product lane assignment beyond "candidate".
- Must not be mixed into Scope D mainline disposition batch by default.
- Each requires separate Approval Gate if ever committed.
- DISCARD_CANDIDATE is NOT recommended by default — defer to 604390 Human
  policy; unapproved status only recorded here.
```

**Scope D / 0069 blocking:** Indirect only — they increase worktree contamination
risk if bundled with replay-blocker commits, but they are not direct replay-chain
migrations unless Human explicitly ties them into a future lane.

---

## 10. tools Residue (Excluded From This Analysis)

Per 604388, tools remediation is **deferred** to a separate future tooling track.

Reference only — four untracked paths remain present and untouched:

```text
tools/audit_lifecycle_folders.py
tools/compare_directory_tree_index.py
tools/missing_from_000005.txt
tools/sync_docs_index_from_tree.py
```

```text
- Not classified in §5 table.
- Must not be mixed into SQL/migration disposition or Scope D mainline commits.
- 604389 performs no tools inspection beyond existence confirmation.
```

---

## 11. 0069 Analysis And Scope D Mainline Status

```text
0069 Analysis:
  - Search *0069*Analysis*.md under docs/: NONE FOUND
  - Status: DEFERRED; not created by this Analysis

Scope D mainline:
  - 604260 / 604250 / 604400(604310) / 604316: NOT RESUMED
  - Unresolved SQL/migration residue prevents trustworthy replay/resume judgment
  - This Analysis does not authorize resume
```

---

## 12. Boundary Confirmation

Confirmed not performed by this Analysis:

```text
- SQL modification                          : NO
- migration modification                    : NO
- SQL reset / discard / rename              : NO
- SQL staging                               : NO
- tools modification / staging              : NO
- runtime code modification                 : NO
- 0069 Analysis creation                    : NO
- Scope D mainline resume                   : NO
- staging                                   : NO
- commit                                      : NO
```

---

## 13. 604390 Approval Gate Requirement

**Finding: YES — 604390 Approval Gate is required before any disposition action.**

604390 must authorize, per path or explicitly grouped paths:

```text
- discard vs keep vs stage-for-commit vs rename-repair vs defer
- replay verification requirements
- forbidden mixing with tools track or Scope D mainline docs
- whether 0142 may commit alone or only with an approved replay batch
- whether 024/0024 pairs may be reconciled and by which method
```

604390 must **not** authorize 0069 Analysis or Scope D mainline resume unless
Human explicitly adds a separate decision outside the default quarantine policy.

Recommended track numbering (from 604388):

```text
604389 Analysis (this document)
604390 Approval Gate
604391 Implementation
604392 Verification
604393 Audit
```

---

## 14. Final Analysis Result

```text
SQL_MIGRATION_RESIDUE_DISPOSITION_REQUIRES_APPROVAL_GATE_BEFORE_SCOPE_D_RESUME
```

```text
Summary:
  - Started from 604388 Human Decision and accepted 604387 quarantine closure.
  - Staged files: none. git diff --check: PASS.
  - All 21 SQL/migration residue paths preserved and classified.
  - Replay-blocker modified set (0035-0068) requires separate approval + replay
    evidence before Scope D or 0069 reconsideration.
  - 024/0024, 030/0030, 032/0032 pairs remain NOT pure renames (SHA256 mismatch).
  - 0142 remains tracked-added but unapproved for commit.
  - 0136/0139/0141/seed remain unapproved new migration / seed pending.
  - tools residue excluded; separate future tooling track.
  - 0069 Analysis deferred. Scope D mainline blocked.
  - Next step: 604390 Approval Gate.
```

---

## 15. Required Next Step

```text
604390_Approval_Gate_SQL_Migration_Residue_Disposition_Before_Scope_D_Resume.md
```

---

## 16. Final Rule

This Analysis does not authorize SQL/migration remediation.

If this Analysis conflicts with an approved ChangeContract or Approval, the
stricter boundary wins.

Scope D mainline and 0069 Analysis must not resume automatically from this
Analysis.
