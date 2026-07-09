# 604262_Overview_Scope_D_00A_Toss_MVP_PaymentIntent_Binding_Precondition.md

Status: Draft
Lifecycle: Overview
Gate Classification: Scope D 00A Toss MVP PaymentIntent Binding Precondition Overview Draft
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-02

**Owner rule:** `Owner` must be assigned before Human Approval. No implementation may proceed while Owner remains TBD.

This document does not authorize implementation.
Codex must not implement from this Overview.

**604260 must close before 604250 implementation can resume.**
**604260 does not authorize 604250 implementation.** Closing this slice removes the blocker `604256`-approved implementation ran into; it does not itself restart `604250`'s Codex work, and it does not authorize any new `604250` file beyond what `604256` already named.

---

## 0. Purpose

This is the slice-specific Overview for **604260 — Toss MVP PaymentIntent Binding Precondition** (Scope D sub-workpacket 00A). It verifies the claims in `604261_ImpactScope_Scope_D_00A_Toss_MVP_PaymentIntent_Binding_Precondition.md` against the actual repository state and frames why this slice exists: `604256`-approved implementation of `604250` (schema drift alignment) stopped because the Toss MVP path (`0103` `initiate_toss_payment` → `confirm_toss_payment` → `0098` `confirm_payment`) never creates or links a `payment_intents` row, so `payment_ledger.intent_id NOT NULL` and `604256` §3's "resolved exactly once" rule cannot be satisfied on that path.

This Overview is Stage 2 output (Claude), built on Stage 1 (Cursor) discovery in `604261`. It does not replace `604261`; it confirms which of its findings are load-bearing for design.

---

## 1. Slice Boundary

```text
In scope:
  toss_payment_requests <-> payment_intents linkage strategy
  initiate_toss_payment / confirm_toss_payment binding behavior (design only)
  Coordination interface between this slice's future patch and 604250's future patch
    (specifically: how confirm_payment eventually receives p_intent_id)

Out of scope (owned by other slices, or already closed elsewhere):
  payment_ledger column drift itself (provider_payment_key, fee_amount, provider_response) → 604250,
    blocked until this slice closes, not re-opened by this document
  Idempotency same-success / TC-102                                    → 604310
  confirm_payment_from_provider (0027) / 0038 webhook legacy            → excluded, reference only
  604250 Codex implementation resumption                                → not authorized here
  Edge Function / Flutter source                                        → not in repo or separate slices
```

604260 may only investigate and propose binding strategy candidates for the Toss MVP intent-creation gap. It does not decide `604250`'s own remaining implementation details, and it does not restart `604250`'s Codex work — that requires a separate, explicit re-authorization once this precondition closes.

---

## 2. Relationship To 604250

```text
604250_Index / 604255 §8 (Boundary With 604310) established 604250 as a precondition
  slice for 604310. 604256 then approved 604250 for controlled implementation.
604256 §3-§4 (approved intent_id binding + Toss MVP decisions) already set the rules
  this slice must design against — it does not re-litigate them:
    payment_intent must exist before provider confirm whenever the flow supports it.
    confirm_payment should receive p_intent_id when available.
    Synthetic intent creation at confirm time is prohibited by default.
    0 matching intent -> INTENT_BINDING_REQUIRED; >1 matching intent -> INTENT_BINDING_CONFLICT.
    Weak guesswork (order_id-only, most recent pending, session-id-only) is forbidden.
604261 §2.1 records that Codex, implementing under 604256, hit exactly this wall:
  the Toss path supplies no intent, so 604250's patch cannot make confirm_payment's
  intent_id-bound INSERT succeed for the primary MVP path without this slice's work.
604256 §11 Allowed Files do not include 0103 — so even if 604250's own patch is
  otherwise complete, it cannot close the Toss binding gap by itself. This slice (604260)
  or an expanded Human Approval is required.
```

**Sequencing implication (604261 §11.3):** this slice's eventual patch (if approved) is expected to be a **separate migration that lands before or alongside** `604250`'s patch resumes, not a replacement for it. `604250`'s own remaining work (the `0098` `INSERT`/`WHERE` alignment) is unaffected in scope by this slice.

---

## 3. Current Repo Evidence

Verified directly against `sql/migrations/` on 2026-07-02 (not taken from `604261` on trust alone):

| 604261 claim | Verification | Result |
| --- | --- | --- |
| `payment_intents` DDL `0014` L14–151: `order_id` NOT NULL FK (L18), `idempotency_key` NOT NULL (L40), `provider_order_id` unique (L32), `payment_method`/`payment_channel`/`requested_amount`/`provider_type` required (L23–31), comment recording multiple intents per order (L135) | Read `0014` L1–151 directly | **Confirmed**, exact lines match |
| `toss_payment_requests` `0103` L92–164: `order_id` nullable FK, `order_id_toss` NOT NULL unique (L106), `idempotency_key` NOT NULL unique (L107), `payment_key` nullable until confirm (L105), **no** `payment_intent_id`/`intent_id` column, **no** FK to `payment_intents` | Read `0103` L85–221 directly | **Confirmed** |
| `initiate_toss_payment` (`0103` L315–517): inserts only `toss_payment_requests`; never calls `create_payment_intent` | Grepped `0103` for `create_payment_intent` and `insert into ... payment_intents` | **Confirmed — zero matches** |
| `confirm_toss_payment` (`0103` L522–731): looks up request, updates `payment_key`/`DONE`, calls `confirm_payment` at L695–710 without any `intent_id` | Grepped for `confirm_payment(` inside `0103` | **Confirmed** — single call site at L695, matches the argument list `604261` §6.3 records |
| `process_toss_webhook` `DONE` path calls `confirm_toss_payment` (same binding gap) | Grepped for `confirm_toss_payment` call sites | **Confirmed** — `process_toss_webhook` invokes `confirm_toss_payment` (`0103` L1021 region) |
| `0098` `confirm_payment` has no `p_intent_id` and never queries `payment_intents` | Re-verified against prior full read of `0098` (this session, `604251`/`604253` verification) | **Confirmed**, consistent with prior sessions' verification |
| `create_payment_intent` (`0027` L15–187): creates `payment_intents` row, updates session to `PAYMENT_PENDING`, sets `toss_order_id`; only caller repo-wide is Kiosk `0052` (L271); Toss path (`0103`) never calls it | Grepped repo-wide for `create_payment_intent(` | **Confirmed** — the only call site outside `0027`'s own definition is `sql/migrations/0052_create_kiosk_session_rpc.sql` L271 |

All six `604261` claim groups listed in the task are verified accurate against the current repo state. No factual error was found.

---

## 4. Business Risk

```text
604250 implementation is stalled, not just theoretically blocked:
  This is not a hypothetical precondition — 604261 §2.1 documents that Codex, operating
  under a real 604256 approval, actually attempted 604250's patch and stopped because
  the Toss path cannot supply intent_id. Every day this slice remains open, 604250's
  approved implementation work sits incomplete.

Downstream risk if bypassed:
  If a future patch relaxed intent_id to nullable, or resolved it via order_id-only
  lookup, just to unblock 604250 without doing this slice's work, it would violate
  604256 §3's explicit rules (forbidden weak guesswork; synthetic-at-confirm
  prohibited) and reintroduce exactly the correctness risk 604256 was written to
  prevent: a payment_ledger row that cannot be traced to a single, deterministic
  payment attempt.

Multiple-intent risk:
  0014's own schema comment (L135) and 0027's active-intent guard (blocks concurrent
  non-terminal intents, but not historical CONFIRMED-then-new-CREATED sequences after
  a retry) together mean that even after this slice's binding mechanism exists, a
  naive order_id lookup at confirm time would still be unsafe — the binding must be
  established once, upstream, and carried through as a stable reference (id, not a
  re-derived guess).

Toss-Kiosk asymmetry:
  0052 (Kiosk) already proves create_payment_intent works as a pre-payment hook.
  0103 (Toss MVP, the higher-traffic path per 604301) never adopted that pattern.
  This asymmetry is itself evidence that closing the gap is a known-working pattern
  extension, not a novel mechanism this slice must invent from scratch.
```

---

## 5. Toss MVP Binding Gap Summary

```text
Approved target lifecycle (604256 §4, restated):
  Order checkout begins
  -> payment_intent created
  -> toss_payment_request created and linked to payment_intent
  -> Toss approval / confirm returns paymentKey
  -> confirm_payment binds to existing payment_intent
  -> payment_ledger APPROVED row inserted

Current repo lifecycle (verified §3 above):
  Order checkout begins
  -> toss_payment_request created (initiate_toss_payment) -- NO payment_intent step
  -> Toss approval / confirm returns paymentKey
  -> confirm_toss_payment updates the request row, calls confirm_payment WITHOUT intent_id
  -> (604250, once its own patch resumes) would require intent_id NOT NULL -- unsatisfiable
     on this path today
```

Steps 2–4 of the approved lifecycle do not exist in the current implementation. This is the single, precise gap this slice exists to close at the design level.

---

## 6. payment_intents Contract

Restates `604261` §4, verified in §3 above:

```text
id, tenant_id, store_id, order_id (NOT NULL FK), session_id (nullable FK)
intent_status (NOT NULL, default CREATED)
payment_method, payment_channel (both NOT NULL)
requested_amount (NOT NULL, > 0), currency (default KRW)
provider_type (NOT NULL), provider_order_id (unique, nullable)
payment_token (unique, nullable)
idempotency_key (NOT NULL)
business_day, business_timezone (NOT NULL)

One order may have multiple intents (retry after failure) -- schema comment, L135.
```

This is the contract any binding strategy must satisfy when creating or referencing an intent for the Toss MVP path.

---

## 7. toss_payment_requests Contract

Restates `604261` §5, verified in §3 above:

```text
id, tenant_id, store_id, order_id (nullable FK)
payment_key (nullable until Toss confirms)
order_id_toss (NOT NULL, unique -- Toss-facing order id, format CATCH-...)
idempotency_key (NOT NULL, unique -- SHA256(order_id + amount + order_id_toss), 0103 L419-427)
payment_method, amount, order_name
request_status (READY..EXPIRED)

No payment_intent_id / intent_id column. No FK to payment_intents.
idempotency_key namespace is independent of payment_intents.idempotency_key.
```

Any binding strategy must either add a link column here, or establish an equally strong reference mechanism (`604263` §3 evaluates options).

---

## 8. confirm_toss_payment Flow Problem

```text
initiate_toss_payment (0103 L315-517): loads order, guards against a DONE duplicate
  request, builds order_id_toss and a toss-local idempotency_key, inserts
  toss_payment_requests ONLY, notifies the Edge layer. No payment_intents interaction.

confirm_toss_payment (0103 L522-731): looks up the request by order_id_toss, checks
  idempotency via request_status, verifies amount, updates the request row (payment_key,
  DONE), then calls confirm_payment with:
    p_order_id, p_provider_type='TOSS_PAYMENTS', p_provider_approval_number,
    p_provider_tx_id := p_payment_key, p_approved_amount, p_payment_method,
    p_provider_response, p_actor_type='PG_WEBHOOK', p_correlation_id
  -- no p_intent_id, no payment_intents lookup anywhere in this call chain.

process_toss_webhook's DONE branch calls confirm_toss_payment directly, so it inherits
  the identical gap -- this is not a client-path-only problem.
```

`0098`'s own confirm_payment (read-only from this slice's perspective) has no `p_intent_id` parameter today; even a `604250`-patched version needs *something* to pass into that parameter from the Toss side, and nothing in the current call chain can supply it.

---

## 9. Existing create_payment_intent Path

```text
create_payment_intent (0027 L15-187): creates a payment_intents row, requires
  p_session_id, p_payment_method, p_payment_channel, p_provider_type,
  p_requested_amount, p_idempotency_key; blocks if a non-terminal intent already
  exists for the same order (L44-56); on success, updates order_sessions to
  PAYMENT_PENDING and sets a provider_order_id in format CM-{store8}-{epoch}-{random6}
  (L107-110) -- NOT the same format as Toss's order_id_toss (CATCH-...).

Only caller repo-wide (verified §3): 0052_create_kiosk_session_rpc.sql L271-283
  (Kiosk flow). initiate_toss_payment and confirm_toss_payment (0103) never call it.
```

`create_payment_intent` is a working, DDL-conformant hook that the Toss path could adopt — it is not a new mechanism this slice must invent, but its `provider_order_id` format and idempotency-key generation are independent of Toss's own conventions, so adopting it is not a zero-decision change (`604263` §5–§6).

---

## 10. Candidate Future Change Boundary

Reference only — restates `604261` §11, not an authorization:

```text
P0 candidate: link column on toss_payment_requests (e.g. payment_intent_id uuid FK),
              added via a new append-only patch migration.
P0 candidate: CREATE OR REPLACE for initiate_toss_payment (or a new wrapper RPC) to
              call create_payment_intent and store the resulting id.
P0 candidate: CREATE OR REPLACE for confirm_toss_payment to resolve payment_intent_id
              from the request row and pass it toward confirm_payment's eventual
              p_intent_id parameter (a 604250-patch dependency, not decided here).
Existing 0014, 0098, 0103, 0027: read/reference only. No in-place edits, ever.
```

---

## 11. Required Gates Before Implementation

```text
1. This Overview (604262) — done, Stage 2.
2. Logic (604263) — this pass.
3. TestPlan (604264) — this pass.
4. ChangeContract (604265) — this pass, candidate boundaries only.
5. Human Approval (604266) — NOT part of this pass. Requires Owner assigned, strategy
   choice made, and every Required Human Decision in 604265 §5 resolved.
6. Codex implementation — only after 5, within the file list 604266 explicitly names.
7. Verification (verification_result.md) — per 600179 Stage 5.
8. Claude audit (audit_review.md) — per 600179 Stage 6. Mandatory; a module file alone
   is never sufficient closeout.

Only after 604260's own 604266 closes, AND 604250's remaining implementation work
(under 604256's existing approval, or a re-scoped one) completes, does 604310's Human
Approval (604316) become eligible for the reassessment 604255/604256 already describe.
This document does not shorten that chain.
```

---

## 12. Final Rule

```text
This Overview exists to confirm that 604261's factual claims about the Toss MVP path's
missing payment_intent binding hold, and to frame why this gap — not a defect in
604250's own patch design — is what stopped 604256-approved implementation. It does not
decide the binding strategy, does not create a migration, does not instruct Codex, and
does not itself resume 604250. Design proceeds to 604263 Logic under the same
restriction.
```
