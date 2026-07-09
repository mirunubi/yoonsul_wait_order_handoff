# 604253_Logic_Scope_D_00_PaymentLedger_ConfirmPayment_SchemaDrift_Alignment.md

Status: Draft
Lifecycle: Logic
Gate Classification: Scope D 00 Schema Drift Alignment Logic Draft
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-01

**Owner rule:** `Owner` must be assigned before Human Approval. No implementation may proceed while Owner remains TBD.

This document is not a change_contract. It does not authorize SQL, migration, Edge Function, Flutter, or config edits. Codex must not implement from this Logic document.

**Boundary reminder:**

```text
Do not modify 0014, 0098, or 0027 in place.
Do not modify 0027 in this slice — reference only.
Do not implement idempotency same-success logic here — that is 604310's problem, and
  remains blocked until this slice closes.
Do not implement amount mismatch hard block here, unless it is strictly necessary to
  prevent an impossible/inconsistent ledger write (e.g., a NOT NULL or CHECK constraint
  the alignment itself introduces) — this slice fixes the write PATH, not confirm_payment's
  business policy.
```

---

## 0. Purpose

Design, at the logic level only, candidate strategies for reconciling `payment_ledger`'s physical schema (`0014`) with `confirm_payment`'s `INSERT`/`WHERE` contract (`0098`), so that `604310` can later build idempotency logic on a write path that is known to compile and execute — without deciding which strategy is correct, and without touching any historical migration file.

---

## 1. Existing Physical Contract

Verified directly against `sql/migrations/0014_create_payment_ledger.sql` (L154–248):

```text
payment_ledger columns (authoritative):
  id, tenant_id, store_id, order_id, session_id
  intent_id            uuid NOT NULL  -> payment_intents(id)
  ledger_entry_type     text NOT NULL  (CHECK: APPROVAL | PARTIAL_CANCEL | FULL_CANCEL |
                                        REFUND | PARTIAL_REFUND | ADJUSTMENT |
                                        MANUAL_CORRECTION)
  ledger_status         text NOT NULL  (CHECK: APPROVED | CANCELLED | REFUNDED | ...)
  approved_amount       int NOT NULL
  cancelled_amount      int NOT NULL default 0
  refunded_amount       int NOT NULL default 0
  net_amount            int NOT NULL  (CHECK: net = approved - cancelled - refunded)
  provider_type         text NOT NULL
  provider_payment_key  text nullable
  provider_approval_number text nullable
  provider_approved_at  timestamptz nullable
  provider_response_id  uuid nullable -> catchmenu_gateway.provider_raw_events(id)
  reconciliation_status text NOT NULL default 'PENDING'
  kds_release_authorized boolean NOT NULL default false
  business_day, business_timezone, approved_at, created_at

NOT present: provider_tx_id, fee_amount, payment_method (on this table), provider_response (jsonb)
```

`payment_intents` (binding context, same file): `idempotency_key` NOT NULL (L40), `intent_status` includes terminal states, and a comment (L135) records that one order may have multiple intents across retries.

---

## 2. Existing 0098 Insert Contract

Verified directly against `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`:

```text
confirm_payment(p_tenant_id, p_store_id, p_order_id, p_provider_type,
                 p_provider_approval_number, p_provider_tx_id, p_approved_amount,
                 p_payment_method, p_provider_response jsonb, ..., p_correlation_id)
  -- no p_intent_id

INSERT INTO payment_ledger (
  tenant_id, store_id, order_id, session_id,
  provider_type, payment_method,
  provider_tx_id,
  provider_approval_number,
  approved_amount, fee_amount, net_amount,
  ledger_status,                      -- 'APPROVED' only, no ledger_entry_type
  approved_at,
  provider_response,                  -- jsonb, not provider_response_id
  reconciliation_status,
  business_day, business_timezone
)

WHERE clause (idempotency check, L192-199) also references provider_tx_id, a column
  that does not exist per §1.
```

Downstream in the same file, `request_refund` (L774–777, L823–841) and `get_payment_status` (L1214–1219) read/write the same non-DDL column names (`provider_tx_id`, `payment_method`, `fee_amount`), so the drift is not confined to the `INSERT` statement analyzed above.

---

## 3. Drift Classification

| Class | Item | Consequence if unaddressed |
| --- | --- | --- |
| **CRITICAL — missing required value** | `intent_id` omitted, column is `NOT NULL` with no default | `INSERT` fails (`null value in column "intent_id" violates not-null constraint`) if the DDL is applied as committed |
| **CRITICAL — missing required value** | `ledger_entry_type` omitted, column is `NOT NULL` | Same failure class as above |
| **CRITICAL — undefined column** | `provider_tx_id` referenced in `INSERT` and `WHERE`, column does not exist | `column "provider_tx_id" of relation "payment_ledger" does not exist` |
| **CRITICAL — undefined column** | `fee_amount` referenced in `INSERT`, column does not exist | `column "fee_amount" of relation "payment_ledger" does not exist` |
| **CRITICAL — undefined column** | `payment_method` referenced in `INSERT` on `payment_ledger`, column does not exist on this table (it exists on `payment_intents`) | Same class as above |
| **TYPE + NAME mismatch** | `provider_response` (jsonb) inserted vs. `provider_response_id` (uuid FK) defined | `column "provider_response" of relation "payment_ledger" does not exist` |
| **SEMANTIC** | `net_amount` set to `approved - fee` in `0098` vs. DDL's `approved - cancelled - refunded` constraint | If `fee_amount` itself is invalid, this is moot until the column question is resolved; if resolved by keeping fee out of the ledger row, the constraint is satisfiable as long as `cancelled_amount`/`refunded_amount` default to 0 |

Every "CRITICAL" row above is a plausible cause of `confirm_payment` failing either at `CREATE OR REPLACE FUNCTION` time (Postgres validates column references for plain SQL inside `plpgsql` at parse time only partially — column-existence errors for static references typically surface at first execution, not creation, for `plpgsql`) or at first `INSERT` execution. This document does not claim certainty about which failure mode occurs first; both are covered as risks in `604254`.

---

## 4. Target Alignment Strategy Options

**Design-only options. Codex must not select or implement any of these without slice-specific Human Approval.**

```text
Option A: DDL extension to support 0098 fields
  Add provider_tx_id (or an alias/compatibility mechanism), fee_amount, payment_method,
  and a provider_response jsonb column to payment_ledger via a new append-only patch
  migration. intent_id and ledger_entry_type would still need a binding rule (§6) since
  extension alone does not supply values 0098 never computes today.
  Audit trail: existing 0098 code shape is preserved; ledger table gains breadth.
  Change size: smaller RPC diff, larger schema diff; downstream 0109/0130 already use
  the same "extended" column names, so this option aligns the DDL to what most of the
  codebase already assumes.

Option B: Rewrite 0098 INSERT to match 0014 DDL
  Change confirm_payment's INSERT to use intent_id, ledger_entry_type = 'APPROVAL',
  provider_payment_key, provider_response_id — mirroring 0027's already-DDL-conformant
  pattern (604251 §10). Requires solving intent_id binding (§6) as a precondition to
  the RPC rewrite itself, and requires a fee_amount decision (§8) since 0014 has no
  column for it at all.
  Audit trail: single column contract across 0027 and 0098 going forward.
  Change size: larger RPC diff (signature and INSERT both change), no DDL diff for the
  drift columns themselves — but likely still needs some DDL work for intent binding
  unless synthetic/pre-created intents fully solve it.

Option C: Hybrid — DDL extension + 0098 INSERT fix + intent backfill/synthetic intent policy
  Extend DDL only for what genuinely cannot be avoided (e.g., a documented fee tracking
  need), fix 0098's INSERT to use the correct existing column names where a direct
  1:1 mapping exists (provider_payment_key instead of provider_tx_id), and add an
  explicit intent-binding mechanism (server-derived synthetic intent row created inline,
  or a required upstream call) rather than either extending intent_id to nullable or
  assuming order_id resolves a unique intent.
  Audit trail: requires the most design care since it draws a line per-field rather
  than applying one rule uniformly, but avoids both "abandon the FK model" (Option A's
  risk if provider_tx_id is added without normalizing to provider_payment_key) and
  "silently drop fee tracking" (Option B's risk if fee_amount is simply deleted from
  the RPC without a replacement).
```

---

## 5. Recommended Strategy

**Recommendation, not a decision.** The final strategy choice is a Required Human Decision (`604255` §5 item 1) and is not made by this document.

```text
Recommended direction: Option C (Hybrid), evaluated on two criteria — auditability and
minimal change:

Auditability:
  Option A alone risks perpetuating two names for one concept (provider_payment_key AND
    provider_tx_id) if the new column is added under the RPC's name instead of the DDL's
    existing name — this would make future grep-based audits (already a pattern this
    project relies on, e.g. 900103 §13, 604303 §15) less reliable, not more.
  Option B alone forces the intent-binding question to be solved immediately and
    globally, which is the single largest unresolved design question in this slice
    (604251 §7) — bundling it with every other column fix in one patch increases the
    chance of an under-reviewed decision on the highest-risk item.
  Option C isolates the intent-binding decision as its own explicit, reviewable rule
    (§6) rather than an implicit side effect of "rewrite everything to match 0014."

Minimal change:
  A hybrid can reuse provider_payment_key directly (zero DDL change for that field,
  since 0027 already proves the DDL-correct pattern works) while still making a
  narrow, explicit decision about fee_amount (§8) and provider_response (§9) rather
  than silently carrying forward either the DDL or the RPC's current shape by default.

This recommendation does not pre-select sub-decisions within Option C (e.g., exact
intent-binding mechanism, exact fee_amount treatment) — those remain open per §6-§9
and 604255 §5.
```

---

## 6. intent_id Binding Logic

### 6.1 604250 Interface Coordination

```text
604260 produces the strong Toss-side payment_intent binding, primarily through toss_payment_requests.payment_intent_id.

604250 consumes that binding through an explicit p_intent_id handoff or equivalent strong non-provider-specific contract.

Per 604266 Decision 10, 604250 should add p_intent_id to confirm_payment and should not depend directly on Toss-specific table lookup unless separately approved.
```

**Design-only pseudocode. Codex must not transcribe this block into SQL without slice-specific Human Approval.**

```text
Candidate mechanisms (604251 §7.2, not selected here):
  A. Direct param: add p_intent_id to confirm_payment; caller (Edge/webhook/staff) must
     supply it. Requires every caller, including the Toss MVP path (0103), to create or
     resolve a payment_intents row first.
  B. order_id lookup: SELECT payment_intents WHERE order_id = p_order_id AND
     intent_status NOT IN (FAILED, CANCELLED, EXPIRED). NOT safe alone — 0014's own
     comment (L135) and create_payment_intent's active-intent check (0027 L44-56)
     together imply multiple historical intents can exist per order after a retry.
  C. provider key match: join on provider_tx_id/provider_payment_key against
     payment_intents.provider_order_id or an equivalent field. No such join exists in
     0098 today; would need to be added.
  D. idempotency_key match: payment_intents.idempotency_key is NOT NULL, but confirm_payment
     never receives or reads it today.
  E. Toss request row: toss_payment_requests has its own idempotency_key (0103 L107),
     but this table has no FK to payment_intents (604251 §7.2-E) — using it to resolve
     intent_id would require a new join path, not just a parameter pass-through.
  F. correlation_id: trace-only (604302 §2.8) — cannot identify an intent by itself.

MVP gap: 0103's confirm_toss_payment calls confirm_payment without creating or linking
  any payment_intents row (604251 §7.3). Mechanism A cannot work for this path unless
  something upstream of confirm_payment starts creating intents for Toss — which is a
  scope question this slice raises but does not decide (604255 §5 item 3).

no-intent vs multiple-intent discrimination (604251 §7.4):
  no-intent for an order is detectable today (zero payment_intents rows for order_id).
  multiple-intent (retries) is possible per schema comment and is NOT fully prevented
    by create_payment_intent (which blocks concurrent *active* intents, not historical
    CONFIRMED-then-new-CREATED sequences).
  Whatever binding mechanism is chosen must explicitly handle both the no-intent case
    and the multiple-intent case — silently picking "the most recent" or "the first"
    row without an explicit rule is not acceptable per this slice's own required tests
    (604254 items 12-13).
```

---

## 7. provider_payment_key Naming Logic

```text
0014 (DDL, authoritative): provider_payment_key text nullable, indexed.
0098 (drifted): p_provider_tx_id parameter, provider_tx_id column reference (not in DDL).
0027 (DDL-conformant reference): p_provider_payment_key parameter, correctly targets
  provider_payment_key.

Candidate directions (604251 §16 item 3, not selected here):
  - Rename 0098's INSERT/WHERE to use provider_payment_key (matches 0014/0027, zero
    DDL change for this field).
  - Add a provider_tx_id column to the DDL (perpetuates two names for one concept
    unless documented as an explicit, intentional alias).
  - Introduce a compatibility view or generated column (adds a layer of indirection;
    increases audit complexity per §5's auditability criterion).

This slice records these options; it does not select one. Whichever is chosen must be
consistent with whatever the confirm_payment idempotency design (604313 §3-bis
effective_idempotency_key) eventually keys off — a naming decision here has direct
downstream effect on 604310's own design once unblocked.
```

---

## 8. fee_amount Handling Logic

```text
0014: no fee_amount column on payment_ledger.
0098: computes v_fee_amount (provider-rate-based estimate) and inserts it.
0027: does not track fee at all (net_amount = approved_amount, no fee concept).
0109, 0130: insert fee_amount = 0 (placeholder, not computed).
Downstream reads (604251 §9: 0111, 0100, 0120, 0084) already assume pl.fee_amount exists.

Candidate directions (604255 §5 item 5, not selected here):
  - Do not add a fee_amount column; drop 0098's fee computation from the INSERT and
    handle settlement-level fee reconciliation elsewhere (a separate settlement slice's
    problem, not confirm_payment's).
  - Add a nullable fee_amount column via the append-only patch, accepting the
    net_amount semantic question this raises (0014's net_amount constraint assumes
    cancelled/refunded only — fee would need to be excluded from that constraint's
    inputs, not silently folded in).
  - Defer to a settlement-specific future slice entirely, and have this slice's patch
    treat fee_amount as strictly out of scope (0098's fee computation would then need
    to move elsewhere, which is itself a decision this slice does not make unilaterally).
```

---

## 9. provider_response Handling Logic

```text
0014: provider_response_id uuid, FK to catchmenu_gateway.provider_raw_events(id).
0098: provider_response jsonb, inline snapshot of the provider payload.
0027: uses provider_response_id (p_provider_raw_event_id parameter, L269/283) —
  DDL-conformant.

Candidate directions (604255 §5 item 6, not selected here):
  - provider_response_id FK only: confirm_payment's caller must first persist the raw
    provider event into catchmenu_gateway.provider_raw_events and pass the resulting id
    — mirrors 0027's already-working pattern exactly.
  - provider_response jsonb snapshot: add a jsonb column to payment_ledger matching
    0098's current behavior — smaller RPC change, but diverges from 0027's model and
    from the gateway event table's apparent purpose as the canonical raw-event store.
  - Both: keep provider_response_id as the FK of record and add a jsonb column purely
    for fast-path debugging/trace — increases storage and audit surface, needs its own
    justification.
```

---

## 10. 0027 Exclusion Logic

```text
0027 confirm_payment_from_provider is read-only reference material for this slice and
  for 604310. It is never an edit target here.

Rationale (604251 §10.1, restated):
  1. 604310_Index already excludes confirm_payment_from_provider from 604310 as a
     future split-brain consolidation concern.
  2. 604315 scopes 604310's eventual patch to 0098's confirm path, not 0027.
  3. 0027's INSERT is useful precisely because it already satisfies the 0014 DDL —
     it is the template this slice studies, not a file this slice changes.
  4. Editing 0027 would pull in VAN/webhook (0038) and the broader intent pipeline,
     expanding blast radius without closing the primary MVP drift in 0098.

This slice may cite 0027's exact column/parameter shape (§1-§2, §7-§9 above) as
precedent when describing alignment options. It may not modify 0027 under any
approval this slice's own ChangeContract could grant.
```

---

## 11. Migration Patch Logic

```text
Confirmed via `ls sql/migrations/` (2026-07-01, re-verified this session): 0136, 0137,
0138 (single file), 0139 are taken. No open number below 0140 exists. Next candidate:
0140, re-verified immediately before Human Approval and again immediately before Codex
implementation.

Policy (900102 / 604302 §10, 604301 §9 append-only rule, unchanged): no in-place edit
of 0014, 0098, 0027, or any other existing migration. Any future implementation is a
NEW append-only patch migration only — CREATE OR REPLACE FUNCTION for confirm_payment
inside that patch, and ALTER TABLE only inside that same new patch file if a DDL-
extension-inclusive option (A or C) is approved.

This slice's own patch (if approved) is logically prior to 604310's own future patch:
whatever schema shape this slice's patch produces becomes the foundation 604310's
idempotency patch is designed against. The two patches are not required to be the same
migration file, but their ordering is not interchangeable.
```

---

## 12. Out Of Scope

```text
- Idempotency same-success / TC-102 payload logic (604310's problem; blocked on this slice)
- Amount mismatch hard block / TC-110 enforcement mechanics (604310's problem), except
  where a schema-level constraint this slice's patch introduces incidentally prevents an
  impossible write (e.g., a NOT NULL this alignment must satisfy regardless of amount
  policy) — this slice does not add new business-rule enforcement beyond what the
  physical schema already requires
- release_kds_after_payment internals (604320's problem)
- GRANT/REVOKE changes (604350's problem)
- Edge Function source (604360's problem)
- 0027 modification of any kind (§10 above)
- Flutter/Dart, Python, config/seed changes of any kind
- Downstream 0109/0130/refund-path alignment beyond recording that the same drift
  pattern exists there (604255 §5 item 7 — include-or-defer decision, not made here)
```

---

## 13. Final Rule

```text
604250's logic is correct when it can show, without deciding: which physical drift items
are CRITICAL (§3), what alignment strategies exist and their auditability/change-size
tradeoffs (§4-§5), what intent-binding mechanisms are possible and why order_id-only
lookup is unsafe (§6), what naming/fee/provider-response options exist (§7-§9), and that
0027 remains untouched throughout (§10). It does not select a strategy, does not write
SQL, and does not unblock 604310 — only a human, via 604256 Human Approval on this
slice, can do that.
```
