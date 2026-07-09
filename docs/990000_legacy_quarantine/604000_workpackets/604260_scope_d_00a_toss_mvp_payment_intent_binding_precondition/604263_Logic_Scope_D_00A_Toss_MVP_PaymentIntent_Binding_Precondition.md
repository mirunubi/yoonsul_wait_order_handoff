# 604263_Logic_Scope_D_00A_Toss_MVP_PaymentIntent_Binding_Precondition.md

Status: Draft
Lifecycle: Logic
Gate Classification: Scope D 00A Toss MVP PaymentIntent Binding Precondition Logic Draft
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-02

**Owner rule:** `Owner` must be assigned before Human Approval. No implementation may proceed while Owner remains TBD.

This document is not a change_contract. It does not authorize SQL, migration, Edge Function, Flutter, or config edits. Codex must not implement from this Logic document.

**Boundary reminder:**

```text
Do not modify 0014, 0098, 0103, or 0027 in place.
Do not resume 604250 Codex implementation from this document.
payment_intent must exist or be strongly bound before APPROVED ledger write.
confirm_toss_payment must be able to pass or expose intent_id to the 604250 confirm_payment patch.
```

---

## 0. Purpose

Design, at the logic level only, candidate strategies for closing the Toss MVP payment_intent binding gap identified in `604261`/`604262`, so that `604250`'s already-approved implementation can resume with a Toss path that supplies a deterministic `intent_id` — without deciding the final strategy, and without touching any historical migration file.

---

## 1. Existing Toss MVP Physical Flow

Verified directly against `sql/migrations/0103_create_toss_payments_pipeline_rpc.sql` and `0027_create_payment_intent_rpc.sql`:

```text
initiate_toss_payment(...):
  load order (+ optional order_sessions)
  guard: existing DONE request for this order -> reject as duplicate
  build order_id_toss := CATCH-{YYYYMMDD}-{order_number}-{epoch}
  build idempotency_key := SHA256(order_id + final_amount + order_id_toss)
  INSERT toss_payment_requests (no payment_intents interaction)
  notify Edge: toss_payment_initiate_requested

confirm_toss_payment(...):
  lookup toss_payment_requests by order_id_toss
  guard: request_status = DONE -> idempotent error
  verify amount strictly against v_request.amount
  UPDATE toss_payment_requests SET payment_key, request_status = DONE, ...
  CALL confirm_payment(p_order_id, p_provider_type='TOSS_PAYMENTS',
                        p_provider_tx_id := p_payment_key, p_approved_amount,
                        p_payment_method, p_provider_response, p_correlation_id)
    -- no p_intent_id, no payment_intents read anywhere in this call chain

process_toss_webhook(...): DONE branch calls confirm_toss_payment directly -- same gap.

create_payment_intent(...) [0027, reference only]:
  requires p_session_id, p_payment_method, p_payment_channel, p_provider_type,
    p_requested_amount, p_idempotency_key
  blocks if a non-terminal intent already exists for the order
  on success: INSERT payment_intents, UPDATE order_sessions to PAYMENT_PENDING,
    sets provider_order_id := CM-{store8}-{epoch}-{random6}
  only current caller repo-wide: 0052 (Kiosk), NOT 0103 (Toss)
```

---

## 2. Required Target Binding Contract

Restates `604256` §3–§4 (already-approved policy, not re-decided here):

```text
payment_intent must be created before provider confirm whenever the flow supports it.
confirm_payment should receive p_intent_id when available.
Synthetic intent creation during confirm is prohibited by default.
APPROVED payment_ledger write is prohibited unless intent_id is resolved exactly once.
0 matching intent -> INTENT_BINDING_REQUIRED.
More than one matching intent -> INTENT_BINDING_CONFLICT.
Weak guesswork (order_id-only, most-recent-pending, session-id-only) is forbidden.

Approved target lifecycle:
  Order checkout begins
  -> payment_intent created
  -> toss_payment_request created and linked to payment_intent
  -> Toss approval / confirm returns paymentKey
  -> confirm_payment binds to existing payment_intent
  -> payment_ledger APPROVED row inserted
```

This slice's job is to design **how** the Toss MVP path satisfies this contract — not to change the contract itself.

---

## 3. Binding Strategy Options

**Design-only options. Codex must not select or implement any of these without slice-specific Human Approval.**

```text
Option A: Patch initiate_toss_payment to call existing create_payment_intent and store
  payment_intent_id on toss_payment_requests.
  Mechanism: CREATE OR REPLACE initiate_toss_payment (new migration) calls
    create_payment_intent(...) before/alongside the toss_payment_requests INSERT,
    then stores the returned intent id in a new payment_intent_id column on the
    request row. confirm_toss_payment reads that column and passes it toward
    confirm_payment's p_intent_id.
  Reuses the already-working, DDL-conformant create_payment_intent hook (proven by
    0052's Kiosk usage) rather than inventing new intent-creation logic.

Option B: Introduce a dedicated helper/wrapper that creates/binds payment_intent
  before Toss request creation.
  Mechanism: a new RPC (e.g. initiate_toss_payment_with_intent, or a smaller helper
    called by a lightly-patched initiate_toss_payment) that wraps
    create_payment_intent + the existing toss_payment_requests insert logic, without
    replacing initiate_toss_payment's own signature/behavior for any other caller.
  Isolates the new intent-binding logic in one place; slightly larger surface (new
    function name) but avoids changing initiate_toss_payment's existing contract for
    any caller that might depend on its current behavior.

Option C: Resolver-only approach during confirm_toss_payment.
  Mechanism: at confirm time, attempt to resolve an existing payment_intents row via
    some identifier available then (order_id, provider_order_id, etc.) without any
    upstream creation step.
  604261 §9.4 and 604256 §3 both already establish that no available Toss-confirm-time
    identifier resolves an intent with the required exactly-one guarantee: order_id
    alone can match multiple historical intents (0014 comment, L135); order_id_toss
    and payment_key exist only on the request row, with no stored link to
    payment_intents. This option is only viable if paired with a new, deterministic
    link established upstream -- at which point it collapses into Option A or B.

Option D: Synthetic intent creation at confirm time.
  Mechanism: confirm_toss_payment (or confirm_payment itself) creates a payment_intents
    row inline if none exists, immediately before the ledger insert.
  Directly contradicts 604256 §3's explicit prohibition ("Prohibited by default:
    synthetic intent creation during confirm"). Not a viable option under current
    policy without a separate policy override, which this slice does not request.
```

---

## 4. Recommended Strategy

**Recommendation, not a decision.** The final strategy choice is a Required Human Decision (`604265` §5 item 1) and is not made by this document.

```text
Preferred: Option A or B.
Rejected by default: Option C, if it depends on weak order_id lookup (per 604256 §3's
  explicit prohibition and 604261 §9.4's finding that no strong resolver exists today).
Rejected by default: Option D, synthetic confirm-time intent (per 604256 §3's explicit
  prohibition).

Between A and B: Option A is smaller (patches one function, reuses create_payment_intent
  as-is) but changes initiate_toss_payment's existing behavior in place (via
  CREATE OR REPLACE in a new migration -- not an in-place edit of 0103's committed
  text, per policy). Option B avoids touching initiate_toss_payment's existing name/
  behavior at the cost of a new function surface. Both satisfy 604256 §3-§4's contract;
  neither is selected here.

Core principles that apply regardless of A vs. B:
  payment_intent must exist or be strongly bound before APPROVED ledger write.
  confirm_toss_payment must be able to pass or expose intent_id to the 604250
    confirm_payment patch -- this is the interface contract between this slice and
    604250's own remaining work (§8 below).
```

---

## 5. payment_intent Creation Logic

**Design-only pseudocode. Codex must not transcribe this block into SQL without slice-specific Human Approval.**

```text
function initiate_toss_payment(...):  -- or a wrapper, per Option A/B
  # existing behavior: load order, guard duplicate DONE request, build order_id_toss
  intent_result := create_payment_intent(
    p_session_id       := <resolved from order, see §10 null handling>,
    p_payment_method   := <mapped from Toss context>,
    p_payment_channel  := <e.g. CUSTOMER_APP -- 604265 §5 item, not fixed here>,
    p_provider_type    := 'TOSS_PAYMENTS',
    p_requested_amount := v_order.final_amount,
    p_idempotency_key  := <coordination decision, §9 below>
  )
  if intent_result.blocked (active_intent_exists):
    # 0027's own active-intent guard already fires here -- this slice must decide
    # how to react (reuse existing active intent id? surface as a distinct error?)
    # not decided here -- 604265 §5 item 7
  else:
    v_intent_id := intent_result.intent_id

  # existing behavior continues: build/insert toss_payment_requests, but now also
  # store v_intent_id on the request row (new column, §6 below)
```

---

## 6. toss_payment_requests Link Logic

```text
Candidate: add payment_intent_id uuid references payment_intents(id) to
  toss_payment_requests via a new append-only patch migration.
Populated at the same time initiate_toss_payment (or its wrapper) creates/resolves
  the intent (§5 above).
confirm_toss_payment then reads payment_intent_id from the already-loaded request row
  (it already does a lookup by order_id_toss, §1 above) -- no new lookup mechanism is
  needed beyond adding this column to the existing SELECT.

Whether this is a nullable or NOT NULL column, and whether existing (pre-migration)
  request rows need a backfill policy, is not decided here -- 604265 §5 item 3.
```

---

## 7. confirm_toss_payment Binding Logic

**Design-only pseudocode. Codex must not transcribe this block into SQL without slice-specific Human Approval.**

```text
function confirm_toss_payment(...):
  # existing behavior: lookup request by order_id_toss, idempotency guard, amount check,
  # update request row (payment_key, DONE)

  v_intent_id := v_request.payment_intent_id   -- new column, from §6

  if v_intent_id is null:
    return INTENT_BINDING_REQUIRED   -- per 604256 §3; do not proceed to confirm_payment

  v_result := confirm_payment(
    ...,                       -- existing arguments unchanged
    p_intent_id := v_intent_id -- NEW argument, depends on 604250's own patch adding
                               -- this parameter to confirm_payment (§8 below)
  )
```

This makes explicit the **interface dependency**: this slice can guarantee `confirm_toss_payment` has a resolved `intent_id` to offer, but it cannot itself add the `p_intent_id` parameter to `confirm_payment` — that parameter is `604250`'s own patch surface. The two patches must agree on this interface; see §8.

---

## 8. confirm_payment Interface Coordination With 604250

```text
604250 (604253 §6, already designed but not yet re-verified against this slice) already
  anticipated needing an intent-binding mechanism on confirm_payment's signature. This
  slice's job is narrower: guarantee the Toss caller HAS an intent_id to supply, once
  604250's patch exposes a parameter to receive it.

Coordination points (not decided here -- 604265 §5 item 10):
  - Does 604250's patch add p_intent_id directly to confirm_payment's signature, or
    does it resolve intent_id itself by reading toss_payment_requests.payment_intent_id
    (i.e., confirm_payment reaches into a table this slice's patch modifies)?
  - If 604250 adds p_intent_id, this slice's confirm_toss_payment patch must pass it
    (§7 above). If 604250 instead resolves it internally, this slice's contribution is
    limited to guaranteeing the column exists and is populated (§6), and
    confirm_toss_payment's own patch may be smaller or unnecessary beyond passing
    p_provider_tx_id as it already does.
  - Migration ordering: whichever patch lands first must not assume the other's schema
    changes exist yet, unless the two patches are combined into one migration --
    604261 §11.3 records this as an open sequencing question.
```

---

## 9. Retry / Idempotency Coordination

```text
Two independent idempotency namespaces exist today:
  toss_payment_requests.idempotency_key := SHA256(order_id + amount + order_id_toss)
    (0103 L419-427)
  payment_intents.idempotency_key (0014 L40, NOT NULL, no uniqueness constraint on the
    column itself per the DDL read in this slice)

Candidate directions (604265 §5 item 4, not selected here):
  (a) Share one key: pass the same computed value into create_payment_intent's
      p_idempotency_key as initiate_toss_payment already computes for the request row.
  (b) Derive a linked-but-namespaced key: e.g. a deterministic transform of the Toss
      key, so the two remain distinguishable in audit but are traceably related.
  (c) Independent keys with an explicit mapping: rely solely on the new
      payment_intent_id FK column (§6) as the link, and let each table keep its own
      independently-generated key with no shared derivation.

Retry scenario this must handle: a customer retries payment on the same order after a
  FAILED Toss attempt. Whether this creates a new payment_intent (matching 0014's own
  "multiple intents per order" comment) or reuses an existing one interacts directly
  with create_payment_intent's active-intent guard (§5 above, item "intent_result.blocked")
  -- this slice records the interaction, it does not resolve it (604265 §5 item 7).
```

---

## 10. session_id Null Handling

```text
create_payment_intent requires p_session_id (604261 §9.1, 0027 L19-24 parameter list).
initiate_toss_payment reads v_order.session_id (0103 L374) as an optional value today
  (order_sessions is loaded "+ optional" per 604261 §6.1).

If an order can legitimately have no session_id at Toss-initiate time, calling
  create_payment_intent as designed in §5 would fail or require a null-tolerant path.

Candidate directions (604265 §5 item 6, not selected here):
  (a) Block initiate_toss_payment if no session_id is resolvable -- treat it as a
      precondition failure for the Toss flow, not a silent gap.
  (b) Allow payment_intents.session_id to be null for this flow (the column is already
      nullable per 0014) and accept an intent with no session linkage.
  (c) Create a fallback/synthetic session before calling create_payment_intent -- this
      is a different kind of "synthetic" than the prohibited synthetic INTENT
      (604256 §3 only prohibits synthetic intents, not synthetic sessions), but still
      needs its own justification and is not assumed safe by default here.
```

---

## 11. Existing create_payment_intent Reuse Logic

```text
create_payment_intent (0027) is read-only reference for this slice, same as it is for
  604250 -- it is called, never modified. Its existing behavior (active-intent guard,
  provider_order_id generation, order_sessions update to PAYMENT_PENDING) is treated as
  a black box this slice's initiate_toss_payment patch (Option A) or wrapper
  (Option B) invokes as-is.

provider_order_id format mismatch: create_payment_intent generates
  CM-{store8}-{epoch}-{random6}; Toss's own order_id_toss is CATCH-{date}-{order}-{epoch}.
  These are NOT reconciled by calling create_payment_intent -- the resulting
  payment_intents row will carry a provider_order_id in the CM- format regardless of
  what order_id_toss looks like, unless this slice's patch explicitly overrides that
  parameter to something Toss-consistent. Whether that override is needed, or whether
  the mismatch is acceptable (since the FK link, §6, is what actually ties the two rows
  together, not string matching on provider_order_id), is 604265 §5 item 5.
```

---

## 12. Migration Patch Logic

```text
Confirmed via ls sql/migrations/ (2026-07-02, re-verified this session): 0136-0139
taken; no file present at 0140+. 604250's own patch has not yet merged (still blocked
by this precondition), so 0140 remains the leading candidate for whichever patch (this
slice's or 604250's) lands first -- re-verify immediately before implementation, and
again if the other patch merges first.

Policy (604256 §10, §13, unchanged, and applying equally to this slice): no in-place
edit of 0014, 0098, 0103, or 0027. Any future implementation is a NEW append-only patch
migration -- CREATE OR REPLACE FUNCTION for initiate_toss_payment/confirm_toss_payment
(or new wrapper RPC names, per Option A/B) inside that patch, and ALTER TABLE (for the
payment_intent_id link column) only inside that same new patch file.

Sequencing with 604250 (604261 §11.3, restated): this slice's patch is expected to
close before or alongside 604250's patch resumes, since 604250's patched
confirm_payment needs a Toss caller that already has an intent_id to offer. Whether
both changes land in one migration or two is itself a Required Human Decision
(604265 §5 item 8), not decided here.
```

---

## 13. Out Of Scope

```text
- payment_ledger column drift itself (provider_payment_key, fee_amount, provider_response)
  -- remains 604250's problem, this slice does not re-open or re-decide it
- Idempotency same-success / TC-102 payload logic -- 604310's problem
- Amount mismatch hard block / TC-110 enforcement mechanics -- 604310's problem
- release_kds_after_payment internals -- 604320's problem
- GRANT/REVOKE changes -- 604350's problem
- Edge Function source -- 604360's problem
- 0027 modification of any kind -- reference only, permanently, in this schema-drift
  lineage
- Flutter/Dart, Python, config/seed changes of any kind
- Resuming 604250's own Codex implementation -- this document only removes a
  precondition; restarting 604250 requires its own separate authorization step
```

---

## 14. Final Rule

```text
604260's logic is correct when it can show, without deciding: what the Toss MVP path's
actual physical flow is today (§1), what target contract 604256 already approved (§2),
what binding strategies exist and why C/D are rejected by default (§3-§4), how intent
creation, link storage, and confirm-time resolution would work under Option A/B (§5-§7),
how the interface to 604250's own confirm_payment patch is coordinated rather than
assumed (§8), and what session/idempotency/retry questions remain genuinely open
(§9-§10). It does not select a strategy, does not write SQL, and does not resume 604250
-- only a human, via 604266 Human Approval on this slice, followed by whatever
re-authorization 604250 itself separately requires, can do that.
```
