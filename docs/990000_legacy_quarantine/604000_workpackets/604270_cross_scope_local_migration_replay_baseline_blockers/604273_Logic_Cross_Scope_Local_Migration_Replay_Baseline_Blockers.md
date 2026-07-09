# 604273_Logic_Cross_Scope_Local_Migration_Replay_Baseline_Blockers.md

Status: Draft
Lifecycle: Logic
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 1 Design
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-04

This Logic document analyzes fix strategies and presents a Decision Matrix. It selects
no option on its own authority. Only Human Approval (`604276`, not yet created) may
select and authorize an option.

---

## 0. Purpose

Model precisely why `0035` and `0038` each fail sequential replay, why they fail
*differently*, what a forward-patch-only strategy can and cannot achieve given how a
strict sequential migration runner behaves on a file-level parse/apply error, and lay
out the fix-strategy options for Human decision.

---

## 1. Replay Chain Model

```text
Assumption (consistent with 604268's observed replay and 0034's own guard): the
  migration runner applies files 0001..N in strict ascending numeric order, each file
  in isolation, and halts the sequential run on the first file that fails to parse or
  apply -- it does not skip a failing file and continue to the next by default.

Observed chain (604268 Addendum, independently re-confirmed against source in 604271
  and again in this document):

  0001 .. 0034   -> apply cleanly (0034 seed guard requires db name to match
                    %dev%/%test%/%local%; catchmenu_local_verify_604260 satisfies this)
  0035           -> FAILS to parse (halts strict sequential run)
  [0036 .. 0037] -> not reached in strict sequential run
  0038           -> FAILS to parse when reached via targeted/continued inspection
  [0039 .. 0141] -> not reached in strict sequential run
  0142           -> NOT REACHED

This is a *replay-order* problem, not a 0142 defect. 0142's own content was already
independently audited in 604269 against every function/table it references and found
structurally sound.
```

---

## 2. 0035 Failure Logic

```text
sql/migrations/0035_verify_schema.sql, L8-28:

  do $$
  declare
    v_error_count int := 0;
    ...
    procedure assert_true(p_label text, p_condition boolean) as
    $inner$ ... $inner$;
  begin
    ...
  end $$;

A DO block's DECLARE section may declare variables only. PostgreSQL's PL/pgSQL parser
rejects a `procedure ... as $inner$ ... $inner$;` declaration inside DECLARE -- this is
not a runtime/logic bug, it is a parse-time syntax error, so the DO block can never
have executed successfully as written, in any environment, at any prior time.

Side-effect profile: 0035 contains no CREATE TABLE/FUNCTION, no ALTER, no INSERT/
UPDATE/DELETE, no DROP (confirmed by direct read, matching 604271 §4.1). It is a
read-only verification pass over information_schema/pg_tables and seed rows, ending in
a RAISE EXCEPTION if any check fails. Its failure blocks replay *progress* only; it
does not indicate any missing or corrupted persistent schema object.
```

---

## 3. 0038 Failure Logic

```text
sql/migrations/0038_create_toss_webhook_processor_rpc.sql, L395-399 (inside
  catchmenu_integrations.process_toss_webhook's unknown-status/quarantine branch):

  update catchmenu_integrations.toss_webhooks
  set processing_status = 'FAILED',
      processing_error := 'unknown_toss_status: ' || v_status,   -- invalid
      processed_at = now()
  where id = v_webhook_id;

`:=` is PL/pgSQL variable-assignment syntax. Inside a SQL UPDATE...SET column list, the
correct assignment operator is `=`. Because this statement is inside the body of
`create or replace function ... language plpgsql`, and PostgreSQL validates PL/pgSQL
function bodies at CREATE-time by default (check_function_bodies = on by default),
`0038` fails at the CREATE FUNCTION statement itself when applied -- the whole file
aborts, not just the unknown-status branch at call time.

Side-effect profile: unlike 0035, 0038's *intent* is to create two functions
(verify_toss_signature, process_toss_webhook) that read/write toss_webhooks,
toss_payments, payment_intents, payment_ledger, and provider_raw_events. Because the
file fails to apply, none of that intended state exists from this file; whatever
webhook-processing capability exists in the current schema comes only from 0103's later
redefinition of process_toss_webhook, confirm_toss_payment, and toss_webhook_log -- but
0103 is only reachable in strict sequential replay *after* 0038 succeeds.
```

---

## 4. Why 0035 And 0038 Are Different

| Dimension | 0035 | 0038 |
| --- | --- | --- |
| Persistent side effects if corrected | None (verification-only) | Creates 2 functions read/written by later migrations (0039 depends on 0038) and by 604260/0142's webhook convergence narrative |
| Downstream file dependency | No later file's *objects* depend on 0035 succeeding, only replay *order* | `0039_create_kds_bulk_commit_rpc.sql` header declares `Depends on: 0038_create_toss_webhook_processor_rpc.sql`; later files assert `process_toss_webhook` exists (per 604271 §5.5) |
| Safe to skip for a *targeted* manual jump | Yes, for manual investigation only — does not fix clean bootstrap | No — skipping loses the intended webhook-processing objects that later migrations and 604260's own webhook-DONE convergence path assume exist |
| Fix shape | Rewrite (nested EXECUTE / extracted helper function / nested block) or an explicit, approved skip-in-automated-replay policy | Single-character-class correction (`:=` to `=`) is the entire known defect |
| Same pattern reappears elsewhere | Yes — `0073_final_verification.sql` L9-14 uses the identical inline-procedure-in-DECLARE pattern (not yet reached in replay, but same class of blocker) | No known recurrence found in this pass |

---

## 5. Forward Patch Limitation

```text
Policy Question 4/5 (explicitly addressed): can a forward patch migration (e.g. a new
0143+ file) resolve this without touching 0035/0038 directly?

No, not by itself, and the reason is structural, not a matter of preference:

A forward patch is, by definition, a migration numbered *after* 0142 (or after whatever
number is next free). Under the strict sequential replay model in §1, the runner halts
at 0035 (and, in a targeted continued run, at 0038) BEFORE it ever reaches any file
numbered 39 or higher -- including any new forward-patch file. A `CREATE OR REPLACE
FUNCTION` forward patch that redefines process_toss_webhook correctly is never executed
by a full sequential replay, because the replay never gets past the broken 0038 file to
reach it.

A forward-patch-only strategy could only work if paired with one of:
  (a) a migration-runner-level policy that explicitly skips 0035/0038 during automated
      replay (shifting the problem to Option C, Replay Harness / Skip Policy), or
  (b) an already-applied environment where 0035/0038 were somehow bypassed by hand
      (not evidenced anywhere in this lifecycle, and not something 604270 assumes), or
  (c) direct correction of 0035/0038 themselves (Option A / Option D).

Forward patch migrations alone, with no change to how the runner treats 0035/0038 and
no change to 0035/0038 themselves, do not resolve the replay-order blocker. Any future
document proposing "forward patch only" must explicitly state which of (a)/(b)/(c) it
relies on to get past 0038's file-level parse failure; asserting a forward patch is
sufficient without naming one of these is not a valid conclusion.
```

---

## 6. Historical Migration Correction Logic

```text
Policy Question 1/2 (explicitly addressed): can 0035/0038 be edited in place, and what
is the risk of doing so?

General rule in this lifecycle (604302 §append-only discipline, 604255 Decision
Register): historical migrations must not be edited in place, because environments that
already applied them would diverge from a rewritten copy of the same file number.

Narrower fact specific to 0035/0038: both defects are unconditional parse-time syntax
errors (an invalid DECLARE-section procedure in 0035; an invalid `:=` inside a plain SQL
UPDATE SET in 0038's function body, which PostgreSQL validates at CREATE-function time
by default). Neither file could have been successfully applied, in this exact form, by
ordinary sequential execution in ANY environment -- there is no plausible already-applied
state that a corrected rewrite could diverge from, unless some environment previously
ran with `check_function_bodies = off` or manually patched the file locally before
applying it. That possibility is not evidenced in this lifecycle but must be explicitly
ruled out by Human confirmation, not assumed, before in-place correction is approved.

This narrows, but does not eliminate, the general append-only risk. It is why 604275
frames Human Approval as required specifically to confirm no divergent already-applied
copy exists before authorizing any in-place edit.
```

---

## 7. Replay Harness / Skip Policy Logic

```text
Policy Question 6/7 (explicitly addressed): can a replay harness simply skip 0035 (and/
or 0038) instead of editing either file?

0035: skip is defensible for *automated/CI* replay specifically because 0035 is
  verification-only -- skipping it changes zero persisted schema state. It does forgo
  the schema-integrity assertions 0035 exists to make, so a skip policy should be paired
  with either a rewritten replacement check or an explicit acceptance that automated
  replay does not get 0035's assertions until it is fixed.

0038: skip is NOT acceptable as a substitute for a fix. 0038 is where
  process_toss_webhook and verify_toss_signature are first created; 0039 declares a
  header dependency on 0038; later migrations assert process_toss_webhook exists; and
  604260/0142's own webhook-DONE convergence narrative assumes a working webhook
  processing path exists somewhere in the applied chain. Skipping 0038 in a harness
  would silently remove real, load-bearing objects from the replayed schema, which is a
  materially different risk than skipping a verification-only DO block. A harness-skip
  policy for 0038 is not proposed as viable in this Logic document.
```

---

## 8. Hybrid Option

```text
Given §4-§7, the two files do not need the same fix strategy:
  - 0038's defect is a single, unconditional syntax error with one obvious correction
    and no plausible divergent already-applied state (pending Human confirmation) --
    direct historical correction is the narrowest, lowest-ambiguity fix.
  - 0035's defect is also unconditional, but the file carries no persisted side effects,
    so it additionally has a *safe-skip-for-automated-replay* option that 0038 does not
    have; either a rewrite or an approved skip policy resolves it.
A hybrid treats these differently rather than forcing one policy onto both.
```

---

## 9. Decision Matrix

| Option | Description | Unblocks 0142 replay? | Risk | Fits 0035? | Fits 0038? |
| --- | --- | --- | --- | --- | --- |
| **A — Direct historical migration correction** | Edit 0035 and 0038 files in place to fix the parse errors | Yes, if both are corrected | Departs from general append-only rule; requires Human confirmation no divergent already-applied copy exists for either file | Yes (works, but forgoes the safe-skip alternative) | Yes |
| **B — Forward patch only** | New migration(s) after 0142 redefine the intended objects, without touching 0035/0038 | **No**, per §5 — sequential replay halts at 0035/0038 before any forward-patch file is ever reached, unless combined with (a)/(b)/(c) from §5 | Low file-edit risk, but does not actually solve the stated problem alone | No (0035 never reached) | No (0038 never reached) |
| **C — Replay harness skip/prepatch policy** | Migration runner is configured to skip/override 0035 and/or 0038 during automated replay, without editing the historical files | Yes for 0035 (verification-only, safe to skip); **not viable for 0038** per §7 (would drop load-bearing webhook objects) | Adds runner complexity and a second source of truth if used for 0038; acceptable narrow risk if scoped to 0035 only | Yes | No (see §7) |
| **D — Hybrid: direct correction for 0038 + rewrite/skip policy for 0035** | Correct 0038 in place (§6); for 0035, either rewrite it to valid PL/pgSQL or adopt an explicit skip-in-automated-replay policy while preserving verification intent some other way | Yes | Bounded: only the two files with unconditional parse errors and no plausible divergent applied state are touched; 0035's own risk is further reduced by its lack of persisted side effects | Yes | Yes |

```text
Recommendation for Human decision (not self-authorizing): Option D. It is the only
option that (a) actually unblocks 0142 replay, per the structural constraint in §5, and
(b) treats 0035 and 0038 according to their materially different side-effect and
dependency profiles established in §4, rather than applying one policy uniformly to
both. Option A also unblocks replay but forgoes 0035's safe-skip alternative without a
clear benefit. Option B, standing alone, does not unblock replay at all. Option C is
sound for 0035 but not viable for 0038.
```

---

## 10. Final Logic

```text
0035 and 0038 fail replay for structurally different reasons with structurally
different side-effect profiles. A forward-patch-only strategy cannot, by itself, get a
strict sequential replay runner past either file's parse-time failure to reach 0142 --
this is a mechanical consequence of how the replay halts on first file-level error, not
a matter of preference. Direct historical correction is narrowed from a generally
disfavored action to a bounded, lower-risk one specifically because both defects are
unconditional parse errors with no plausible divergent already-applied state -- subject
to Human confirmation of that assumption. This document recommends Option D (Decision
Matrix, §9) for Human Approval's consideration in 604276. This Logic document does not
itself select, approve, or implement any option.
```
