# 604283_Logic_Cross_Scope_0042_Delivery_Order_Intake_Baseline_Replay_Blocker.md

Status: Draft
Lifecycle: Logic
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 1 Design
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-05

This Logic document analyzes the 0042 fix strategy and presents a Decision Matrix. It
selects no option on its own authority. Only Human Approval (`604286`, not yet
created) may select and authorize an option.

---

## 0. Purpose

Model precisely why `0042` fails sequential replay, confirm it is a single, isolated
syntax defect rather than a broader design issue, and lay out the fix-strategy options
for Human decision, following the same rigor 604273 applied to 0035/0038.

---

## 1. Replay Chain Logic

```text
Same replay model as established in 604270/604273: a strict sequential migration
  runner (ON_ERROR_STOP=1) applies files in ascending numeric order and halts on the
  first file that fails to parse or apply.

Observed chain (604278 Verification, re-confirmed in 604281 and again here):

  0001 .. 0034   -> apply cleanly
  0035           -> now FIXED under 604276/604277 (604270); applies cleanly, 85/0/85
  0036 .. 0037   -> apply cleanly
  0038           -> now FIXED under 604276/604277 (604270); applies cleanly
  0039 .. 0041   -> apply cleanly (confirmed: "last applied: 0041" in 604278)
  0042           -> FAILS to parse (halts strict sequential run)
  [0043 .. 0141] -> not reached
  0142           -> NOT REACHED

This is again a replay-order problem, not a 0142 defect, and not a 604270 defect --
0035/0038 are confirmed fixed and unrelated to 0042.
```

---

## 2. 0042 Failure Logic

```text
sql/migrations/0042_create_delivery_order_intake_rpc.sql, inside
  catchmenu_integrations.intake_delivery_order (L12-493), at L396:

  update catchmenu_common.idempotency_keys
  set
    processing_status = 'COMPLETED',
    completed_at = now(),
    result_payload := jsonb_build_object(
      'order_id', v_order_id,
      'session_id', v_session_id,
      'order_number', v_order_number
    )
  where ...

`:=` is PL/pgSQL variable-assignment syntax. Inside a SQL UPDATE...SET column list,
the correct assignment operator is `=`. Because this statement is inside the body of
`create or replace function ... language plpgsql`, and PostgreSQL validates PL/pgSQL
function bodies at CREATE-time by default, 0042 fails at the CREATE FUNCTION statement
itself when applied -- the whole file aborts, not just this one branch at call time.
This is the identical failure mechanism 0038 had before its fix (604273 §3).

Side-effect profile: intake_delivery_order, sync_delivery_order_status, and
reject_delivery_order are all defined in this single file (L12-493, L496-612, L615-787
respectively, per 604281 §4). Because the file aborts at L396 (inside the first
function's body, evaluated at CREATE-function-parse time), none of the three functions
nor their EXECUTE grants (L790-834) are created when 0042 fails to apply.
```

---

## 3. SQL Assignment Logic

```text
Independently re-verified in this Logic document (grep of all `:=` occurrences in
0042): every other `:=` in the file is a VALID use --
  - PL/pgSQL variable assignment inside a DECLARE/BEGIN block (e.g.
    v_total_amount := 0, v_order_number := 'D-' || ..., v_kitchen_zone_summary :=
    jsonb_set(...)) -- valid, since `:=` is correct for plpgsql variable assignment.
  - Named-parameter argument passing in function calls (e.g.
    catchmenu_audit.append_audit_record(p_tenant_id := p_tenant_id, ...)) -- valid,
    since PostgreSQL's `:=` named-argument notation is legal syntax in a function CALL
    context, unlike a SQL UPDATE...SET list.

Only line 396's usage sits inside a SQL UPDATE...SET column list, which is the one
context where `:=` is a syntax error rather than a legitimate assignment. This
confirms 604281 §4's claim: exactly one invalid occurrence, isolated to a single
statement, with no other similar defect anywhere else in the file.
```

---

## 4. Why This Is A One-Line Syntax Correction

```text
The defect is bounded to a single token class change on a single line:
  result_payload := jsonb_build_object(...)   ->   result_payload = jsonb_build_object(...)

No other line in the UPDATE statement, the surrounding function body, the function
signature, or any other function in the file needs to change for the parser to accept
this file. This mirrors exactly the 0038 precedent already implemented and
independently audited as PASS in 604279 (0038's actual diff was confirmed to be a
single line, +1/-1).

No business-logic evidence (idempotency semantics, gateway ingest, order/KDS creation,
audit trail, delivery status handling) suggests any defect beyond this single
assignment operator (604281 §4, independently re-confirmed by reading the full
function body in this Logic pass).
```

---

## 5. Why Forward Patch Alone Is Not Sufficient

```text
Same structural constraint as 604273 §5 (0038's case): a forward patch is, by
definition, a migration numbered after 0042 (or after 0142). Under the strict
sequential replay model in §1, the runner halts at 0042 before it ever reaches any
later-numbered file, including a new forward-patch file. A `CREATE OR REPLACE
FUNCTION` forward patch that redefines intake_delivery_order correctly is never
executed by a full sequential replay, because the replay never gets past the broken
0042 file to reach it.

A forward-patch-only strategy could only work if paired with one of:
  (a) a migration-runner-level policy that explicitly skips 0042 during automated
      replay (not proposed as viable -- see §6 below), or
  (b) evidence of some already-applied environment that bypassed 0042's defect by hand
      (not evidenced anywhere in this lifecycle), or
  (c) direct correction of 0042 itself (§7 below).

Any future document proposing "forward patch only" for 0042 must explicitly state
which of (a)/(b)/(c) it relies on; asserting a forward patch is sufficient without
naming one of these is not a valid conclusion.
```

---

## 6. Why 0042 Skip Is Not Allowed

```text
0035 (in 604270) was skip-eligible in principle because it was verification-only --
skipping it changed zero persisted schema state. 0042 is materially different:

1. intake_delivery_order has exactly one definition in the entire migration history
   (0042). Skipping 0042 means this function never exists in the replayed schema.
2. 0043 declares a header dependency on 0042 -- skipping 0042 in an automated harness
   would still need to decide whether 0043 (and everything after it) is attempted
   against a schema missing 0042's objects, which risks silent downstream failures
   rather than a clean, understood boundary.
3. 0057 and 0074 call intake_delivery_order in their function bodies. Even if those
   files happened to apply without 0042 (plpgsql does not validate callee existence at
   CREATE time), any actual runtime invocation of the delivery order intake path would
   fail with an undefined-function error -- a much worse outcome than a clear
   migration-apply-time halt.
4. Unlike 0035, there is no "preserve verification intent some other way" escape valve
   for 0042 -- there is no alternate location where intake_delivery_order is defined
   that a skip could fall back on.

0042 is not safely skippable. This Logic document does not propose a skip policy for
0042 anywhere in its Decision Matrix (§9).
```

---

## 7. Historical Migration Correction Logic

```text
General rule in this lifecycle (604255/604302 append-only discipline, applied again in
604273 §6 for 0035/0038): historical migrations must not be edited in place, because
environments that already applied them would diverge from a rewritten copy of the same
file number.

Narrower fact specific to 0042: like 0035/0038 before their fix, this is an
unconditional parse-time syntax error (a `:=` inside a plain SQL UPDATE...SET list,
which PostgreSQL rejects at CREATE-function validation time by default). 0042 could
not have been successfully applied, in this exact form, by ordinary sequential
execution in ANY environment -- there is no plausible already-applied state that a
corrected rewrite could diverge from, unless some environment previously ran with
check_function_bodies = off or manually patched the file locally before applying it.
That possibility is not evidenced in this lifecycle but must be explicitly ruled out by
Human confirmation before in-place correction is approved, consistent with how 604276
handled the same question for 0035/0038.

This narrows, but does not eliminate, the general append-only risk -- Human Approval
(604286) must explicitly confirm this assumption, as 604276 did for 0035/0038.
```

---

## 8. Dependency Logic

```text
Upstream: all objects intake_delivery_order/sync_delivery_order_status/
  reject_delivery_order depend on (catchmenu_hq.stores, catchmenu_common.
  idempotency_keys, catchmenu_gateway.provider_raw_events, catchmenu_pos.
  order_sessions/orders/order_items/menus, catchmenu_kds.kds_tickets, catchmenu_ledger.
  events, catchmenu_audit.append_audit_record) already exist after 0041 (604281 §6) --
  a corrected 0042 has everything it needs to apply cleanly.

Downstream: 0043 (header dependency), 0057/0074 (body callers), 0078/0106 (later
  redefinitions of two of 0042's three functions). None of these require any change
  themselves -- once 0042 applies cleanly, they consume its objects exactly as
  originally designed. Fixing 0042 does not require touching any of them.
```

---

## 9. Decision Matrix

| Option | Description | Unblocks 0142 replay? | Risk | Fits 0042? |
| --- | --- | --- | --- | --- |
| **A — Direct one-line historical correction** | Edit line 396 of 0042 in place: `result_payload :=` to `result_payload =` | Yes, if no further blocker exists between 0043 and 0142 | Departs from general append-only rule; narrowed because the defect is an unconditional parse error with no plausible divergent already-applied state (pending Human confirmation, per §7) | Yes |
| **B — Forward patch only** | New migration after 0142 redefines intake_delivery_order/etc., without touching 0042 | **No**, per §5 — sequential replay halts at 0042 before any forward-patch file is ever reached, unless combined with (a)/(b)/(c) from §5 | Low file-edit risk, but does not solve the stated problem alone | No |
| **C — Replay skip policy** | Migration runner is configured to skip 0042 during automated replay | **No** — per §6, 0042 is the sole definition of load-bearing functions with real downstream callers; skipping risks silent runtime failures rather than a clear boundary, and does not reliably get replay to 0142 either, since 0043's dependency and later redefinitions assume 0042's objects exist | Not viable |
| **D — Do nothing / accept blocked replay** | Leave 0042 broken; do not pursue any fix at this time | N/A — replay remains blocked | No new risk introduced, but the 604260 runtime-evidence gap and 604250 resume block persist indefinitely | Only viable if Human explicitly deprioritizes 0142 runtime evidence |

```text
Recommendation for Human decision (not self-authorizing): Option A — Direct one-line
historical correction. It is the only option that actually unblocks replay progress
past 0042 (per §5's structural constraint on forward patches and §6's rejection of a
skip policy), it mirrors the already-approved and already-verified 0038 precedent
exactly, and the risk of departing from append-only discipline is narrowed by the same
reasoning 604276 already accepted for 0035/0038 (unconditional parse error, no
plausible divergent already-applied state, pending Human confirmation). Option D
remains available to Human as an explicit, informed choice to defer the fix, but is not
this document's recommendation.
```

---

## 10. Final Logic

```text
0042 fails replay for the same structural reason 0038 did before its fix: an
unconditional SQL syntax error (`:=` where `=` is required in an UPDATE...SET list)
that PostgreSQL rejects at CREATE-function validation time. The defect is isolated to
a single line, independently confirmed by scanning every other `:=` occurrence in the
file and finding all of them valid (variable assignment or named-parameter call
syntax). Neither a forward-patch-only strategy nor a replay-skip policy can unblock
0142 reachability for 0042, for reasons structurally identical to (and in the skip
case, stronger than) those already established for 0035/0038 in 604273. This document
recommends Option A (Decision Matrix, §9) for Human Approval's consideration in
604286. This Logic document does not itself select, approve, or implement any option.
```
