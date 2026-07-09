# 604266_Approval_Scope_D_00A_Toss_MVP_PaymentIntent_Binding_Precondition.md

## 0. Approval Status

```text
Status: Human Approved For Controlled Implementation
Lifecycle: Human Approval
Gate Classification: Scope D 00A Toss MVP PaymentIntent Binding Precondition Human Approval
Runtime Implementation Authorization: Granted Within This Document Boundary Only
Owner: 정영석 / System Owner
Reviewer: 정영석 / Human Reviewer
Approval Authority: Human Owner
Approved Date: 2026-07-02
```

This approval authorizes only the controlled implementation of the Scope D 00A Toss MVP PaymentIntent Binding Precondition slice.

This approval does not authorize 604250 implementation resume.

This approval does not authorize 604310 Payment Confirm Idempotency implementation.

This approval does not authorize creation of `604316_Approval_Scope_D_01_Payment_Confirm_Idempotency.md`.

---

## 1. Approved Implementation Scope

Approved implementation scope:

```text
- Ensure the Toss MVP payment request path creates or strongly binds a payment_intent before Toss confirm.
- Add a strong binding from toss_payment_requests to payment_intents where approved.
- Ensure confirm_toss_payment can load or preserve the bound payment_intent_id for the later 604250 confirm_payment interface.
- Ensure the webhook DONE path uses the same safe binding path as direct confirm_toss_payment.
- Preserve the append-only migration discipline.
- Preserve 604250 as blocked until 604260 closes and explicit reauthorization is granted.
```

This slice exists because 604250 implementation stopped under 604256 after Codex confirmed that the Toss MVP path does not create or link a payment_intent before calling confirm_payment.

---

## 2. Approved Strategy Decision

Approved strategy:

```text
Option A is the default strategy.
Patch initiate_toss_payment so that it creates or strongly binds a payment_intent during Toss request creation.

Option B helper/wrapper is allowed only as an implementation detail.

Option C resolver-only is not approved unless it uses a strong pre-existing intent binding.

Option D synthetic confirm-time intent is prohibited.
```

Implementation interpretation:

```text
- The payment_intent must exist before APPROVED ledger write.
- The payment_intent should be created or bound when the Toss request is created.
- The implementation must not rely on order_id-only lookup.
- The implementation must not create a synthetic intent only after provider confirm succeeds.
```

---

## 3. Approved PaymentIntent Creation Timing

Approved timing:

```text
Create or bind payment_intent during Toss request creation.
```

Target flow:

```text
Order checkout begins
→ initiate_toss_payment is called
→ payment_intent is created or strongly bound
→ toss_payment_request is created and linked to payment_intent
→ Toss approval / confirm returns paymentKey
→ confirm_toss_payment loads the bound payment_intent_id
→ 604250 confirm_payment patch can consume p_intent_id
→ payment_ledger APPROVED row can satisfy intent_id NOT NULL
```

Not approved:

```text
- Create or bind payment_intent only at confirm time.
- Create synthetic payment_intent after provider approval as a way to satisfy ledger intent_id.
```

---

## 4. Approved toss_payment_requests Schema Decision

Approved schema decision:

```text
Add payment_intent_id FK to toss_payment_requests.
```

Compatibility rule:

```text
Prefer nullable FK for append-only migration compatibility,
while patched initiate_toss_payment must populate payment_intent_id for new Toss requests.
```

Reason:

```text
- Existing rows may not have payment_intent_id.
- New Toss requests must have a strong binding.
- provider_order_id or order_id_toss alone must not be treated as the primary intent binding.
```

---

## 5. Approved Idempotency Coordination Decision

Approved idempotency coordination:

```text
Use linked but namespaced idempotency keys.
```

Policy:

```text
- Do not treat Toss request idempotency_key and payment_intents idempotency_key as identical by default.
- They may share a common base identity.
- Their namespaces and meanings must remain explicit.
```

Example policy direction:

```text
payment_intents.idempotency_key:
internal:intent:{base_identity}

toss_payment_requests.idempotency_key:
pg:toss:request:{base_identity}
```

The exact formatting may follow existing repository conventions, but the semantic separation must be preserved.

---

## 6. Approved provider_order_id / order_id_toss Decision

Approved policy:

```text
Keep provider_order_id and order_id_toss as separate fields for now.
Document the mapping explicitly.
Do not rename or merge these fields in 604260.
```

Rationale:

```text
- payment_intents.provider_order_id and toss_payment_requests.order_id_toss may use different prefixes and meanings.
- 604260 is a binding precondition slice, not a naming-normalization migration.
- Renaming or merging these fields would expand scope.
```

---

## 7. Approved session_id Null Decision

Approved policy:

```text
Default policy is to block Toss initiate when session_id is required but missing.
Nullable session intent may be allowed only if the order type legitimately has no session.
Automatic fallback session creation is not approved in 604260.
```

Implementation rule:

```text
- If the order/session model requires session_id for this Toss MVP flow, block initiate when session_id is missing.
- If the order type legitimately has no session, the implementation may preserve nullable session semantics.
- Do not create fallback sessions automatically without separate Human Approval.
```

---

## 8. Approved Failed Intent Retry Decision

Approved retry policy:

```text
Reuse an existing active payment_intent for Toss initiate retry when it belongs to the same order and active payment attempt.
Create a new attempt only after the previous intent is terminal failed, cancelled, or expired under an approved status policy.
Do not create duplicate active intents for the same order payment attempt.
```

Implementation rule:

```text
- Retry must be idempotent where possible.
- Existing active intent should remain the binding authority for the same payment attempt.
- Terminal failed/cancelled/expired handling must be explicit and auditable.
```

---

## 9. Approved confirm_toss_payment Patch Scope

Approved patch scope:

```text
CREATE OR REPLACE confirm_toss_payment is allowed in 604260 only to the extent needed to load and preserve the bound payment_intent_id.
```

Boundary:

```text
- confirm_toss_payment may load the payment_intent_id from toss_payment_requests.
- confirm_toss_payment may prepare the value needed by the later 604250 confirm_payment interface.
- Passing p_intent_id into confirm_payment must be coordinated with the 604250 confirm_payment interface patch.
- Do not redesign the Toss provider flow beyond this binding requirement.
```

Not approved:

```text
- Full Toss provider redesign.
- Full webhook redesign.
- 604310 idempotency implementation.
- effective_idempotency_key registry implementation.
- request_fingerprint registry implementation.
```

---

## 10. Approved Webhook DONE Path Decision

Approved webhook policy:

```text
The webhook DONE path must use the same safe binding path as direct confirm_toss_payment.
```

Implementation rule:

```text
- Do not create a separate webhook-only payment confirmation path in 604260.
- If process_toss_webhook DONE already delegates to confirm_toss_payment, preserve that convergence.
- Webhook and direct confirm must not diverge on payment_intent binding behavior.
```

---

## 11. Approved 604250 Interface Dependency Decision

Approved 604250 dependency:

```text
604250 should add p_intent_id to confirm_payment.
604260 should prepare and pass or expose the bound payment_intent_id from toss_payment_requests.
Do not make confirm_payment depend directly on Toss-specific table lookup unless separately approved.
```

Boundary:

```text
- 604260 may prepare the Toss-side binding.
- 604250 remains responsible for the confirm_payment/payment_ledger schema alignment.
- 604250 implementation may resume only after 604260 implementation, verification, audit, and explicit reauthorization.
```

---

## 12. Approved Migration Number Decision

Approved migration policy:

```text
Recheck highest migration prefix immediately before implementation.
Create append-only patch migration only.
```

The current expected candidate is:

```text
0140+
```

This is not a fixed number. The executor must inspect `sql/migrations` immediately before creating the patch.

Forbidden:

```text
Do not modify existing historical migrations in place.
Do not reuse existing migration numbers.
Do not renumber existing migrations.
```

---

## 13. Approved Owner Decision

Approved ownership:

```text
Owner: 정영석 / System Owner
Reviewer: 정영석 / Human Reviewer
Approval Authority: Human Owner
```

This ownership applies to this 604260 approval only.

---

## 14. Allowed Files For Codex Implementation

Codex may modify or create only the following files after this approval.

Allowed future runtime file pattern:

```text
sql/migrations/<next_available_prefix>_patch_toss_mvp_payment_intent_binding.sql
```

The exact migration prefix must be determined immediately before implementation by inspecting `sql/migrations`.

Allowed documentation file:

```text
docs/600000_implementation_lifecycle/604000_workpackets/604260_scope_d_00a_toss_mvp_payment_intent_binding_precondition/604267_Module_Scope_D_00A_Toss_MVP_PaymentIntent_Binding_Precondition.md
```

No other files are approved.

---

## 15. Forbidden Files

The following historical migrations must not be modified in place:

```text
sql/migrations/0014_create_payment_ledger.sql
sql/migrations/0027_create_payment_intent_rpc.sql
sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql
sql/migrations/0103_create_toss_payments_pipeline_rpc.sql
```

The following areas are forbidden unless separately approved:

```text
supabase/**
catchmenu_app/**
*.dart
*.py
package.json
pubspec.yaml
pubspec.lock
config/**
seed/**
test/**
```

The following documents must not be created or modified by Codex in this implementation:

```text
604260_Index...
604261_ImpactScope...
604262_Overview...
604263_Logic...
604264_TestPlan...
604265_ChangeContract...
604266_Approval...
604268_Verification...
604269_Audit...
604250 implementation documents except for read-only reference
604257_Module...
604258_Verification...
604259_Audit...
604316_Approval...
```

---

## 16. Forbidden Operations

Codex must not perform the following operations:

```text
- Modify 0014, 0027, 0098, or 0103 in place.
- Resume 604250 implementation.
- Create 604257 Module.
- Create 604316 Approval.
- Implement 604310 idempotency.
- Implement same-success replay.
- Implement full amount mismatch hard block.
- Implement effective_idempotency_key registry.
- Implement request_fingerprint registry.
- Redesign refund, cancel, settlement, webhook, Edge Function, or provider consolidation flows.
- Add provider-specific lookup logic inside confirm_payment unless separately approved.
- Create synthetic payment_intent at confirm time.
- Use order_id-only lookup as the primary intent binding.
- Create fallback sessions automatically.
```

---

## 17. Required Implementation Rules

Codex must follow these rules:

```text
1. Recheck the current highest migration prefix before creating any migration file.
2. Use a new append-only patch migration.
3. Do not edit 0014, 0027, 0098, or 0103 in place.
4. Add or establish toss_payment_requests.payment_intent_id binding according to this approval.
5. Patch Toss request creation so new Toss requests create or bind payment_intent.
6. Preserve linked but namespaced idempotency semantics.
7. Preserve provider_order_id and order_id_toss as separate fields.
8. Preserve direct confirm and webhook DONE convergence through the same safe binding path.
9. Stop and report if session_id policy cannot be implemented within this boundary.
10. Stop and report if patched confirm_toss_payment cannot coordinate with the later 604250 p_intent_id contract.
11. Do not resume 604250.
```

---

## 18. Required Verification After Implementation

Implementation cannot be accepted unless verification shows:

```text
1. Historical migrations 0014, 0027, 0098, and 0103 were not modified.
2. New migration number is sequential and non-conflicting.
3. toss_payment_requests has a strong payment_intent binding for new Toss requests.
4. initiate_toss_payment creates or binds payment_intent.
5. duplicate Toss initiate retry does not create duplicate active payment_intents for the same payment attempt.
6. confirm_toss_payment can load the bound payment_intent_id.
7. webhook DONE path uses the same safe binding path.
8. no weak order_id-only binding is used as primary intent binding.
9. no confirm-time synthetic intent creation occurs.
10. provider_order_id and order_id_toss remain separate and explicitly mapped.
11. session_id null policy is enforced or documented as a legitimate no-session order case.
12. 604250 was not resumed.
13. 604310 was not implemented.
14. 604316 was not created.
15. No Flutter, Edge, Python, config, seed, package, lockfile, or test files were modified.
```

---

## 19. Rollback Policy

Rollback strategy:

```text
- Because historical migrations must remain immutable, rollback must be handled by a new corrective migration if needed.
- If the new patch migration fails local verification, do not merge.
- If Toss request creation cannot create or bind payment_intent safely, do not merge.
- If duplicate active payment_intents can be created for the same order payment attempt, do not merge.
- If confirm_toss_payment cannot load the bound payment_intent_id, do not merge.
- If the solution requires 604250 implementation changes, stop and request explicit 604250 reauthorization.
```

---

## 20. Boundary With 604250

This approval does not authorize 604250 implementation resume.

604250 remains blocked until:

```text
1. 604260 implementation is completed.
2. 604267 Module is written.
3. 604268 Verification passes.
4. 604269 Claude Audit passes.
5. Human explicitly reauthorizes 604250 implementation resume.
```

Only after that may 604250 implementation be retried under an updated or revalidated approval boundary.

---

## 21. Boundary With 604310 And 604316

This approval does not authorize 604310 implementation.

This approval does not authorize creation of 604316.

604310 remains blocked until:

```text
1. 604260 closes.
2. 604250 resumes and closes.
3. 604250 verification and audit pass.
4. Human confirms that schema drift alignment and Toss payment_intent binding preconditions are closed.
```

Only after that may `604316_Approval_Scope_D_01_Payment_Confirm_Idempotency.md` be considered.

---

## 22. Final Human Approval Statement

```text
I, 정영석 / System Owner, approve controlled implementation of Scope D 00A Toss MVP PaymentIntent Binding Precondition under the boundaries listed in this document.

I approve the 12 Required Human Decisions recorded in this approval.

I authorize Codex to implement only the allowed append-only migration patch and the 604267 Module document listed above.

I do not approve 604250 implementation resume yet.

I do not approve 604310 Payment Confirm Idempotency implementation yet.

I do not approve creation of 604316 Human Approval yet.

Implementation must stop if the actual repo state requires files or decisions outside this approval boundary.
```
