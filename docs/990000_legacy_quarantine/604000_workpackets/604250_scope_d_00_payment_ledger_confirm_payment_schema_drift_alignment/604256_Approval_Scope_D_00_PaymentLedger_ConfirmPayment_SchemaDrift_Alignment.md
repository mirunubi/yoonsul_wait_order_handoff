# 604256_Approval_Scope_D_00_PaymentLedger_ConfirmPayment_SchemaDrift_Alignment.md

## 0. Approval Status

```text
Status: Human Approved For Controlled Implementation
Lifecycle: Human Approval
Gate Classification: Scope D 00 Schema Drift Alignment Human Approval
Runtime Implementation Authorization: Granted Within This Document Boundary Only
Owner: 정영석 / System Owner
Reviewer: 정영석 / Human Reviewer
Approval Authority: Human Owner
Approved Date: 2026-07-02
```

This approval authorizes only the controlled implementation of the Scope D 00 PaymentLedger / ConfirmPayment Schema Drift Alignment slice.

This approval does not authorize Scope D 01 Payment Confirm Idempotency implementation.

This approval does not authorize creation of `604316_Approval_Scope_D_01_Payment_Confirm_Idempotency.md`.

---

## 1. Approved Implementation Scope

Approved implementation scope:

```text
- Align the 0098 confirm_payment path with the actual 0014 payment_ledger physical schema contract.
- Ensure APPROVED payment_ledger insert can satisfy required fields such as intent_id and ledger_entry_type.
- Normalize provider key usage toward provider_payment_key.
- Remove or avoid undefined insert fields such as provider_tx_id, fee_amount, payment_method, and provider_response when not present in the actual DDL.
- Add only the minimum schema or function patch needed to make the 0098 confirm_payment ledger path physically valid.
- Preserve 0027 as reference-only and out of scope.
```

This slice must close before `604310` implementation approval.

---

## 2. Approved Strategy Decision

Approved strategy:

```text
B RPC Alignment first.
C Hybrid only if actual implementation inspection proves that minimal DDL is strictly necessary.
A-only DDL Extension is not approved.
```

Interpretation:

```text
- The default patch should align 0098 confirm_payment to the existing 0014 payment_ledger contract.
- The implementation must not add columns simply because the drifted RPC currently references them.
- Minimal DDL is allowed only if Codex proves that RPC alignment alone cannot satisfy the approved physical contract.
```

Forbidden:

```text
Do not add columns only to satisfy a drifted RPC unless the column is approved as part of the long-term ledger contract.
```

---

## 3. Approved intent_id Binding Decision

Approved intent binding policy:

```text
Lifecycle default:
payment_intent must be created before provider confirm whenever the flow supports it.

RPC binding default:
confirm_payment should receive p_intent_id when available.

Fallback:
strong exactly-one resolver lookup is allowed.

Prohibited by default:
synthetic intent creation during confirm.
```

Mandatory rule:

```text
APPROVED payment_ledger write is prohibited unless intent_id is resolved exactly once.
```

Failure handling:

```text
0 matching intent:
INTENT_BINDING_REQUIRED

More than one matching intent:
INTENT_BINDING_CONFLICT
```

Forbidden lookup:

```text
Do not bind intent_id from weak guesswork such as:
- same order_id, probably this intent
- most recent pending intent
- same session_id, probably this intent
```

---

## 4. Approved Toss MVP Decision

Approved Toss MVP policy:

```text
Toss MVP must create or bind a payment_intent before APPROVED ledger write.
```

If the current Toss MVP path does not create payment_intents upstream:

```text
Implementation must stop and report the blocker.
A pre-confirm intent creation or binding patch must be opened before APPROVED ledger writes are allowed.
```

Target lifecycle:

```text
Order checkout begins
→ payment_intent created
→ toss_payment_request created and linked to payment_intent
→ Toss approval / confirm returns paymentKey
→ confirm_payment binds to existing payment_intent
→ payment_ledger APPROVED row inserted
```

---

## 5. Approved Provider Key Naming Decision

Approved naming policy:

```text
provider_payment_key is authoritative.
provider_tx_id is compatibility alias only.
```

Implementation rule:

```text
provider_tx_id may be accepted as a legacy input alias,
but it must be normalized before ledger insert.
payment_ledger should use provider_payment_key as the standard PG payment identifier.
```

Recommended semantic separation:

```text
provider_payment_key      -- PG payment key, e.g. Toss paymentKey
provider_approval_no      -- VAN/card approval number
provider_tid              -- VAN/POS terminal or transaction TID
provider_transaction_id   -- generic external transaction id only if explicitly needed
```

---

## 6. Approved fee_amount Decision

Approved fee policy:

```text
Do not add fee_amount in Scope D 00.
Remove undefined fee_amount insert from the confirm_payment path.
Defer fee model to settlement/reconciliation slice.
```

Forbidden:

```text
Do not add fee_amount integer not null default 0.
```

Reason:

```text
0 fee and unknown fee are not equivalent.
```

Future fee modeling may use nullable settlement-oriented fields only in a separately approved settlement slice:

```text
provider_fee_amount integer null
fee_source text null
fee_confirmed_at timestamptz null
```

---

## 7. Approved provider_response Decision

Approved provider response policy:

```text
Prefer provider_response_id FK or raw event reference.
Avoid full provider_response jsonb snapshot in payment_ledger unless explicitly approved.
```

Implementation rule:

```text
If a provider response or raw event table exists, payment_ledger should reference it by provider_response_id.
If it does not exist, do not urgently add full provider_response jsonb to payment_ledger in this slice.
Use raw_payload_hash or audit/event evidence where appropriate.
```

---

## 8. Approved refund / downstream Decision

Approved downstream policy:

```text
Include 0109/0130 only if blocking.
Otherwise defer.
```

Implementation rule:

```text
0109/0130 may be inspected for direct compile/runtime blockers caused by the 604250 patch.
Do not redesign refund, cancel, settlement, provider webhook, or downstream reconciliation flows in this slice.
```

---

## 9. Approved 0027 Decision

Approved 0027 policy:

```text
Keep 0027 excluded.
Document it as a future split-brain consolidation target.
```

Forbidden:

```text
Do not modify 0027_create_payment_intent_rpc.sql in this slice.
Do not unify confirm_payment_from_provider with 0098 confirm_payment in this patch.
```

Future direction:

```text
All payment confirmation paths should eventually pass through a shared confirm_payment_core.
That consolidation is future work and is not approved in this slice.
```

---

## 10. Approved Migration Number Decision

Approved migration policy:

```text
Recheck highest migration prefix immediately before implementation.
Create append-only patch migration only.
```

The current expected candidate is:

```text
0140+
```

But this is not a fixed number. The executor must inspect `sql/migrations` immediately before creating the patch.

Forbidden:

```text
Do not modify 0014 in place.
Do not modify 0098 in place.
Do not modify 0027 in place.
Do not reuse existing migration numbers.
Do not renumber existing migrations.
```

---

## 11. Allowed Files For Codex Implementation

Codex may modify or create only the following files after this approval.

Allowed future runtime file pattern:

```text
sql/migrations/<next_available_prefix>_patch_payment_ledger_confirm_payment_schema_alignment.sql
```

The exact migration prefix must be determined immediately before implementation by inspecting `sql/migrations`.

Allowed documentation file:

```text
docs/600000_implementation_lifecycle/604000_workpackets/604250_scope_d_00_payment_ledger_confirm_payment_schema_drift_alignment/604257_Module_Scope_D_00_PaymentLedger_ConfirmPayment_SchemaDrift_Alignment.md
```

No other files are approved.

---

## 12. Forbidden Files

The following files must not be modified in place:

```text
sql/migrations/0014_create_payment_ledger.sql
sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql
sql/migrations/0027_create_payment_intent_rpc.sql
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
604251_ImpactScope...
604252_Overview...
604253_Logic...
604254_TestPlan...
604255_ChangeContract...
604256_Approval...
604258_Verification...
604259_Audit...
604316_Approval...
```

---

## 13. Required Implementation Rules

Codex must follow these rules:

```text
1. Recheck the current highest migration prefix before creating any migration file.
2. Use a new append-only patch migration.
3. Do not edit 0014, 0098, or 0027 in place.
4. Use CREATE OR REPLACE FUNCTION if confirm_payment behavior must be replaced.
5. Use ALTER TABLE only in the new patch migration if minimal DDL is strictly necessary.
6. Do not add fee_amount integer not null default 0.
7. Do not add provider_tx_id to payment_ledger as the authoritative key.
8. Do not modify 0027.
9. Do not implement 604310 idempotency same-success replay in this slice.
10. Do not implement 604310 amount mismatch hard block in this slice unless strictly necessary to prevent impossible ledger writes.
11. Do not redesign refund, cancel, settlement, webhook, Edge Function, or provider consolidation flows.
12. Stop and report if intent_id cannot be resolved exactly once.
```

---

## 14. Required Verification After Implementation

Implementation cannot be accepted unless verification shows:

```text
1. Historical migrations 0014, 0098, and 0027 were not modified.
2. New migration number is sequential and non-conflicting.
3. Sequential migration apply succeeds through the new patch.
4. confirm_payment compiles after the patch.
5. payment_ledger APPROVED insert path satisfies intent_id NOT NULL.
6. payment_ledger APPROVED insert path satisfies ledger_entry_type NOT NULL.
7. confirm_payment no longer references undefined payment_ledger columns.
8. provider_payment_key is used or normalized correctly.
9. fee_amount undefined insert is removed or explicitly deferred.
10. provider_response/provider_response_id handling is physically valid.
11. no-intent path blocks APPROVED ledger insert.
12. multiple-intent path blocks APPROVED ledger insert.
13. KDS release does not occur if APPROVED ledger insert is blocked.
14. 0027 remains unchanged.
15. No Flutter, Edge, Python, config, seed, package, lockfile, or test files were modified.
```

---

## 15. Rollback Policy

Rollback strategy:

```text
- Because historical migrations must remain immutable, rollback must be handled by a new corrective migration if needed.
- If the new patch migration fails in local verification, do not merge.
- If confirm_payment fails to compile after the patch, do not merge.
- If intent_id binding cannot be made deterministic, stop and return to Human Approval.
- If minimal DDL becomes necessary beyond this approval boundary, stop and request additional Human Approval.
```

---

## 16. Boundary With 604310

This approval does not authorize `604310` implementation.

`604310` remains blocked until:

```text
1. 604250 implementation is completed.
2. 604257 Module is written.
3. 604258 Verification passes.
4. 604259 Claude Audit passes.
5. Human confirms that schema drift alignment is closed.
```

Only after that may `604316_Approval_Scope_D_01_Payment_Confirm_Idempotency.md` be created.

---

## 17. Final Human Approval Statement

```text
I, 정영석 / System Owner, approve controlled implementation of Scope D 00 PaymentLedger / ConfirmPayment Schema Drift Alignment under the boundaries listed in this document.

I approve the Decision Register defaults recorded in 604255 unless explicitly overridden in this document.

I do not approve 604310 Payment Confirm Idempotency implementation yet.

I do not approve creation of 604316 Human Approval yet.

I authorize Codex to implement only the allowed append-only migration patch and the 604257 Module document listed above.

Implementation must stop if the actual repo state requires files or decisions outside this approval boundary.
```
