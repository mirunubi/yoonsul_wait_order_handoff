# 604407_Logic_Scope_D_01_Payment_Confirm_Idempotency.md

Status: Draft
Lifecycle: Logic
Gate Classification: Scope D Slice 01 Logic Draft
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-01

**Owner rule:** `Owner` must be assigned before Human Approval. No implementation may proceed while Owner remains TBD.

This document is not a change_contract. It does not authorize SQL, migration, Edge Function, Flutter, or config edits. Codex must not implement from this Logic document.

**Target / excluded (policy update, 2026-07-01):** the only current target is `0098` `confirm_payment`. `0027` `confirm_payment_from_provider`, provider webhook callback redesign, Edge Function webhook integration, provider-specific callback routing, and full provider pipeline consolidation are explicitly out of scope for this slice (see §10, and `604301` §7.7).

**Boundary reminder:**

```text
604404 must not rewrite the release_kds_after_payment function.
604404 must not solve the full payment-to-KDS transaction boundary.
604404 may only define the confirm_payment-side behavior required before later 604320 and 604330 slices.
```

---

## 0. Purpose

Design, at the logic level only, the target behavior for `catchmenu_payment.confirm_payment`'s duplicate-confirm handling, amount verification, correlation/idempotency key strategy, and ledger/audit evidence — scoped strictly to the confirm side, not the release side.

---

## 1. Existing Behavior

Verified directly against `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` (L145–458):

```text
1. If p_correlation_id is not null:
     look up payment_ledger WHERE provider_tx_id = p_provider_tx_id AND provider_type = p_provider_type
       AND ledger_status = 'APPROVED'
     if found: log CRITICAL 'payment_idempotency_violation', return ERROR 'payment_already_confirmed'
   If p_correlation_id is null: this check does not run at all.

2. Look up order by order_id; if not found, return ERROR 'order_not_found'.

3. If payment_ledger WHERE order_id = p_order_id AND ledger_status = 'APPROVED' exists:
     return ERROR 'payment_already_confirmed' (regardless of correlation_id).

4. If |p_approved_amount - orders.final_amount| > 10:
     log ERROR 'payment_amount_mismatch' — but DO NOT return; execution continues.

5. Compute fee/net amount, INSERT payment_ledger (status APPROVED), UPDATE orders status,
   CALL release_kds_after_payment(...), INSERT audit record, INSERT catchmenu_ledger.events,
   notify realtime channel, RETURN success payload.
```

No branch in the current function returns a success payload for a duplicate call. Every duplicate path is an error response.

---

## 2. Target Behavior

Per `604302` §2.3 and `900103` TC-102, a duplicate confirm should be indistinguishable in outcome from the original call, from the caller's point of view:

```text
Duplicate confirm (safe case) → SAME success payload as the original APPROVED call,
                                  not an error, and no new payment_ledger row, no second
                                  release_kds_after_payment side effect.
Duplicate confirm (conflicting order_id for the same provider_tx_id) → remains a hard
                                  error / human-review state, NOT a same-result return
                                  (604302 §2.3 step 5 — this is a fraud/bug signal,
                                  not a benign retry).
Amount mismatch → must not silently proceed to APPROVED + release (604407 §4 below).
```

---

## 3. Duplicate Confirm Logic

**Design-only pseudocode. Codex must not transcribe this block into SQL without slice-specific Human Approval.**

```text
function confirm_payment(...):
  existing_by_order = lookup payment_ledger WHERE order_id = p_order_id AND ledger_status = 'APPROVED'
  if existing_by_order:
    if existing_by_order.provider_tx_id == p_provider_tx_id:
      return SAME success payload built from existing_by_order (idempotent = true)
    else:
      # different provider_tx_id claiming the same order — conflict, not a safe duplicate
      log CRITICAL, return error / human-review state (unchanged from current behavior)

  if p_correlation_id is not null:
    existing_by_tx = lookup payment_ledger WHERE provider_tx_id = p_provider_tx_id
                       AND provider_type = p_provider_type AND ledger_status = 'APPROVED'
    if existing_by_tx:
      if existing_by_tx.order_id == p_order_id:
        return SAME success payload (idempotent = true)
      else:
        log CRITICAL diagnostic, return error / human-review state (unchanged)

  # ... proceed to amount check (§4) and insert path only if no existing APPROVED row found
```

This reorders the existing two duplicate checks (order-based, tx-based) so that **either one, if it finds an existing APPROVED row for the same order+tx pairing, returns success instead of error** — without changing the conflict-detection behavior for mismatched pairings, which correctly remains a hard stop.

**Open dependency:** building "the same success payload" from an existing row requires reading back `v_kds_result`-equivalent data (e.g., current `kds_tickets` state for the order) rather than the value computed at original insert time, since this is a fresh call. This read-back detail is itself part of what Human Approval must scope precisely — see `604409` §5 item 1.

### 3-bis. Effective Idempotency Key And Request Fingerprint (Policy Update, 2026-07-01)

This supersedes the provider_tx_id/order_id-only framing above with the model from `604302` §2.7–§2.10. **Design-only pseudocode. Codex must not transcribe this block into SQL without slice-specific Human Approval.**

```text
raw idempotency_key is evidence, not final authority.
effective_idempotency_key is the final duplicate-defense key: deterministic,
  namespaced, source-verified, tenant/store scoped, non-null.

Key source priority (highest confidence first):
  1. internal payment_intent_id
  2. provider payment key
  3. provider request row
  4. VAN TID + approval number
  5. adapter-derived deterministic key
  6. server-derived transitional key
  7. unresolved identity -> reject / reconciliation_required

request_fingerprint is separate from effective_idempotency_key:
  amount must NOT be part of effective_idempotency_key.
  amount belongs to request_fingerprint.
  request_fingerprint compares request content (e.g. amount, provider_type,
    payment_method — exact field set is a slice-level decision, not fixed here).
```

```text
function confirm_payment(...):
  key = resolve_effective_idempotency_key(inputs)   // per priority list above
  if key is unresolved (tier 7):
    return reconciliation_required / pending_confirm   // never a blind proceed or blind reject

  existing = lookup payment_ledger WHERE effective_idempotency_key = key AND ledger_status = 'APPROVED'
  if existing:
    fingerprint = compute_request_fingerprint(inputs)
    if fingerprint == existing.request_fingerprint:
      return SAME success payload (idempotent = true)          // same-success replay
    elif fingerprint.amount != existing.request_fingerprint.amount:
      return HARD REJECT (amount differs under the same identity)   // never silently proceed
    else:
      return HARD CONFLICT / human-review state (content differs, not just amount)

  # ... proceed to amount enforcement (§4) and insert path only if no existing row found
```

**Same-success replay and conflict rules (strengthened, policy update):**

```text
Same effective_idempotency_key + same request_fingerprint  -> same-success replay:
  return original terminal success payload.
  must not create duplicate payment_ledger rows.
  must not trigger duplicate KDS release.
  must not duplicate inventory, point, notification, printer, POS sync, or outbox
    side effects.
Same effective_idempotency_key + different request_fingerprint -> hard conflict.
Same effective_idempotency_key + different amount             -> hard reject.
```

**Weak identity reconciliation:** when `effective_idempotency_key` cannot be resolved with sufficient confidence (priority tiers 6–7), the system must not guess — route to `reconciliation_required` or `pending_confirm` instead of proceeding to APPROVED or hard-rejecting a possibly-legitimate payment. This applies symmetrically to duplicate detection above and to `p_correlation_id` absence (§5 below).

Exact SQL/column shape for `effective_idempotency_key` and `request_fingerprint` (new column vs. computed value vs. existing column reuse) is not decided here — that is a Required Human Decision (`604409` §5 item 1, reframed).

---

## 4. Amount Mismatch Logic

**Design-only pseudocode. Codex must not transcribe this block into SQL without slice-specific Human Approval.**

**Policy decision (2026-07-01):** amount mismatch is a hard payment integrity failure, not warning-only. This replaces the prior "option A vs option B, undecided" framing:

```text
Amount mismatch is a hard payment integrity failure.
It must not be warning-only.
It must block APPROVED ledger insert.
It must block the payment_confirmed event.
It must block KDS release.
It must trigger cancel_required or reconciliation_required evidence where applicable.

Default MVP tolerance = 0 KRW.
Provider-specific tolerance is not introduced without separate approval.
```

```text
if p_approved_amount != orders.final_amount:   # 0 KRW default tolerance, not ±10
  log ERROR 'payment_amount_mismatch' (unchanged mechanism)
  return ERROR / cancel_required / reconciliation_required as applicable
  # do NOT insert payment_ledger APPROVED, do NOT release KDS — this is now mandatory,
  # not option A/B.
```

This replaces the current repo behavior (`0098` L267–290: log only, continue to APPROVED insert at L305+) as the **design target**. The remaining Required Human Decision (`604409` §5 item 2) is narrowed from "which enforcement option" to "exact rejection/reconciliation mechanics and whether any provider-specific tolerance is ever approved" — the hard-block direction itself is no longer open.

`confirm_payment_from_provider` (`0027` L244–251) already implements comparable hard-block behavior (`kds_release_authorized = false`) for a different code path — useful precedent, but `0027` remains out of scope for this slice's edits (§10, `604301` §7.7).

---

## 5. Correlation ID Logic

**Policy decision (2026-07-01) — supersedes the prior undecided (a)/(b)/(c) framing:**

```text
Current: provider_tx_id-based duplicate check only runs `if p_correlation_id is not null`.
Problem: a caller that omits correlation_id skips that specific check (the order_id-based
         check at L252-264 still runs regardless of correlation_id).

Policy: p_correlation_id is a trace value, not the final idempotency key.
p_correlation_id null must not, by itself, be grounds for rejecting confirm_payment.
The system must resolve a non-null effective_idempotency_key (§3-bis) from stronger
  identity evidence when available (payment_intent_id, provider payment key, provider
  request row, VAN TID + approval number, adapter-derived key, server-derived
  transitional key — priority order per §3-bis).
If identity cannot be resolved or is weak, route to reconciliation_required or
  pending_confirm — not a hard reject solely because correlation_id was absent.
```

This resolves former option (a) ("reject outright") in the negative and folds former options (b)/(c) into the `effective_idempotency_key` resolution model in §3-bis, rather than treating correlation_id normalization as a standalone mechanism. Required Human Decision #3 (`604409` §5) is narrowed to: which specific identity sources are available at each call site (Edge confirm, webhook, staff manual entry) and in what order they should be tried.

---

## 6. Idempotency Key Logic

```text
payment_intents.idempotency_key (0014 L40, NOT NULL) and toss_payment_requests.idempotency_key
(0103 L107, UNIQUE, generated L419-427) both exist upstream of confirm_payment but are not
read or written by confirm_payment itself.
```

**Policy update (2026-07-01) — supersedes the prior undecided (a)/(b) framing:** these two existing keys are candidate **inputs** to `effective_idempotency_key` resolution (§3-bis), not a binary "use directly or defer" choice:

```text
raw idempotency_key (payment_intents.idempotency_key, toss_payment_requests.idempotency_key)
  is evidence, not final authority by itself.
effective_idempotency_key is derived from the highest-confidence identity source
  available at the call site (§3-bis priority list), which may or may not be one of
  these two raw keys directly.
Required Human Decision #4 (604409 §5) is narrowed to: which raw key(s) map to which
  priority tier, and whether confirm_payment's signature needs a new parameter to
  receive them, versus deriving effective_idempotency_key server-side from existing
  parameters (provider_tx_id, provider_type, order_id).
```

---

## 7. Ledger / Audit Logic

```text
Unchanged by this slice's design intent (confirmed working, in scope only to NOT duplicate
on the new success-return path):
  payment_ledger insert (0098 L306-331) — must occur exactly once per real approval, and
    NOT again on a duplicate-safe return (§3 above returns without re-inserting).
  append_audit_record (0098 L359-383) — an audit event should still exist for a recognized
    duplicate (distinguishable from the original 'payment_confirmed' record), so the
    duplicate is not silently invisible to audit. Exact audit_type/event naming for this
    case is a 604340 concern (proposed event contract) — this slice only requires that
    SOME audit trace exists, not the final name.
  catchmenu_ledger.events insert (0098 L386-415) — same non-duplication requirement as
    payment_ledger; the specific event_type name for a duplicate-ignored case is deferred
    to 604340, consistent with 604302 §5.2 and 604303 §13.
```

---

## 8. Release Boundary Guard

```text
confirm_payment currently calls release_kds_after_payment internally (0098 L348-356) exactly
once, only after a fresh APPROVED insert. Under the target duplicate-confirm behavior (§3),
a recognized duplicate returns SAME success WITHOUT re-inserting payment_ledger and THEREFORE
without a second call to release_kds_after_payment.

This slice does not modify release_kds_after_payment's own idempotency (its HOLD-only guard is
604320's responsibility). This slice's only obligation at the boundary is: do not call it a
second time for a call this slice recognizes as a duplicate. If a genuinely new APPROVED path
is taken, the existing single call remains unchanged.
```

---

## 9. Migration Patch Logic

```text
Confirmed via `ls sql/migrations/` (2026-07-01): 0136, 0137, 0138, 0139 are taken.
No open number below 0140 exists. Next candidate: 0140, re-verified immediately before
Human Approval and again immediately before Codex implementation (numbers may shift if other
work lands in between).

Schema drift (604405 §9 item 4, confirmed in 604406 §3): 0014's payment_ledger.intent_id is
NOT NULL with no default found, and the column is provider_payment_key — but 0098's INSERT
omits intent_id and uses provider_tx_id. No reconciling ALTER TABLE was found anywhere in
sql/migrations/. **Policy update (2026-07-01): this is now a required Schema Drift Alignment
precondition, not merely Required Human Decision #5** — no patch migration may be written,
and no 604316 Human Approval may be finalized, until this drift is resolved or explicitly
understood (604300_Index, 604301 §7.6, 604303 §5.1). A patch that touches confirm_payment's
INSERT statement without first closing this precondition would implement idempotency on top
of a physically broken ledger insert path.

Policy (900102 / 604302 §10, unchanged): no in-place edit of 0098, 0014, 0103, or any existing
migration. Any future implementation is a NEW patch file only.
```

---

## 10. Out Of Scope

```text
- release_kds_after_payment internals (604320)
- confirm→release transaction/split-brain handling beyond "do not double-call" (604330)
- New ledger/audit event type names (604340)
- GRANT/REVOKE changes (604350)
- Edge Function source (604360)
- Flutter/Dart, Python, config/seed changes of any kind
- Deciding confirm_payment_from_provider's (0027) fate (Required Human Decision #6)
```

---

## 11. Final Rule

```text
604404's logic is correct when confirm_payment can prove: a recognized duplicate (same
effective_idempotency_key + same request_fingerprint) returns the same terminal result
without a second ledger row or a second release call, an amount mismatch hard-blocks
APPROVED and KDS release (0 KRW default tolerance) rather than proceeding silently,
p_correlation_id absence alone never causes a reject, and every remaining open item above
(exact key-source mapping, request_fingerprint field set, schema drift alignment,
migration number, confirm_payment_from_provider's fate) is resolved by a human before any
SQL is written — not decided by this document. Target is 0098 confirm_payment only; 0027
confirm_payment_from_provider remains excluded from this slice's edits.
```
