# 604306_NavigationMap_Scope_D_Server_Runtime_Guard_Workpacket_Flow.md

Status: Active
Lifecycle: NavigationMap
Gate Classification: Scope D Server Runtime Guard Navigation
Runtime Implementation Authorization: Not Granted By This Document
Owner: TBD
Last Updated: 2026-07-05

## 0. Purpose

Provide the reading, dependency, handoff, blocked-state, resume, verification, audit, and error-backtracking route for Scope D Server Runtime Guard.

This NavigationMap does not authorize implementation.

## 1. Navigation Scope

This map connects the Scope D master pack with these active lanes:

- 604260 — Toss MVP PaymentIntent Binding Precondition
- 604250 — PaymentLedger / ConfirmPayment Schema Drift Alignment
- 604310 — Payment Confirm Idempotency (canonical folder: `604400_scope_d_01_payment_confirm_idempotency/`)
- 604316 — future Human Approval for 604310

## 1.1 Pre-0142 Baseline Replay Recovery / Cross-Scope Replay Blocker Chain

```text
0042 -> 0046 primary -> 0046 secondary -> 0063 -> 0065 primary
     -> 0065 secondary -> 0066 -> 0067 -> 0068 -> 0069 deferred
```

- This chain records clean-replay blocker cleanup for migrations 0042, 0046, 0063,
  0065, 0066, 0067, and 0068.
- 604328 Audit accepted the 0068 correction and classified 0069 as the next blocker.
- 604373 completed the independent Audit, accepted the repair, and CLOSED the
  directory/index/navigation artifact correction track.
- 0069 Analysis and correction remain deferred pending a separate explicit Human
  resume decision; closure of 604373 does not resume 0069 automatically.
- 0142 has not yet been reached because 0069 remains an earlier replay blocker.
- 604329-604333 record the folder-hygiene sequence; 604334-604338 record the
  directory/index/navigation correction through independent Audit.
- 604339 is retained as the historical/superseded approval-numbering record.
- 604370 is the Approval Gate for the stale-folder-path repair, 604371 is the
  Codex implementation record, 604372 is the PASS verification record, and
  604373 is the created, accepted, and CLOSED independent Audit record.
- The completed repair route is:

```text
604370 Human Approval -> 604371 Codex Implementation
  -> 604372 Verification PASS -> 604373 independent Audit CLOSED
```
- Post-audit closeout metadata drift is handled separately under:

```text
604374 Approval Gate -> 604375 Codex Implementation
  -> 604376 Verification next -> 604377 independent Audit pending
```
- Residual 604290-origin documents are canonicalized as 604350-604359 with
  intentional gaps at 604351 and 604355. Collision-resolution records remain
  604341-604344.
- This lane belongs to
  `604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/`.
- It is separate from Payment Confirm Idempotency. That Scope D 01 slice is stored
  under `604400_scope_d_01_payment_confirm_idempotency/` with independent gates.

## 2. Current Workpacket Route

```text
604260 Toss MVP payment_intent binding precondition
  -> 604250 PaymentLedger / ConfirmPayment schema drift alignment
  -> 604310 Payment Confirm Idempotency
  -> 604316 Human Approval for 604310
```

Each arrow is conditional. Closing an upstream lane does not automatically authorize the downstream lane.

## 3. Reading Order For Humans

1. Read `604300_Index` and this NavigationMap.
2. Read the 604260 Index, ImpactScope, Overview, Logic, TestPlan, ChangeContract, and any Human Approval in lifecycle order.
3. Read the 604250 Index and its lifecycle documents, including its stopped implementation and reauthorization boundary.
4. Read 604310 documents only against the outputs actually closed by 604260 and 604250.
5. Create or approve 604316 only after all upstream gates and remaining Human decisions are satisfied.

## 4. Reading Order For Codex

1. Read the applicable Index and NavigationMap for route context.
2. Read ImpactScope through ChangeContract.
3. Require explicit Human Approval before implementation.
4. Implement only allowed files.
5. Write Module after implementation.
6. Do not self-audit; hand off to Verification and independent Audit.

## 5. Reading Order For Claude

1. Review Overview, Logic, TestPlan, and ChangeContract against upstream evidence.
2. Review producer and consumer contracts across workpackets.
3. After implementation, independently review Approval, Module, Verification, and git diff.
4. Do not treat this NavigationMap as implementation authority.

## 6. 604260 To 604250 Handoff Route

604260 produces:

- Toss-side `payment_intent` binding
- `toss_payment_requests.payment_intent_id`
- `confirm_toss_payment` ability to load the bound intent

604250 consumes:

- bound `payment_intent_id` / `p_intent_id` handoff
- strong non-provider-specific `payment_intent` binding
- no `order_id`-only resolver
- no confirm-time synthetic intent

604260 closure is only prerequisite closure. 604250 requires explicit Human reauthorization before resuming.

## 7. 604250 To 604310 Route

604250 produces:

- `payment_ledger` / `confirm_payment` schema alignment
- a `confirm_payment` interface capable of satisfying `payment_ledger.intent_id NOT NULL`
- `provider_payment_key` alignment
- removal or avoidance of drifted ledger columns

604310 consumes:

- stable `confirm_payment` schema alignment
- `p_intent_id` or equivalent strong idempotency-ready identity
- a payment-ledger path that no longer fails on schema drift

604310 implementation remains blocked until 604250 is implemented, verified, audited, closed, and the 604310 approval gate is separately satisfied.

## 8. 604310 To 604316 Route

604310 produces design decisions for:

- same-success idempotency behavior
- `effective_idempotency_key` or equivalent policy
- request fingerprint or equivalent policy
- amount-mismatch hard block if approved

604316 depends on:

- 604260 closed
- 604250 explicitly reauthorized, implemented, verified, audited, and closed
- 604310 documents updated against the resulting interface
- remaining Human decisions resolved
- explicit Human approval

## 9. Producer / Consumer Contract Map

| Producer | Output contract | Consumer |
|---|---|---|
| 604260 | Strong Toss-side `payment_intent_id` binding | 604250 |
| 604250 | DDL-aligned `confirm_payment` interface and ledger write path | 604310 |
| 604310 | Approved idempotency and amount-verification design | 604316 Human decision |

Consumers must verify the producer output rather than infer it from folder status or Index presence.

## 10. Blocked State Map

- 604260 has been implemented under the 604266 Approval boundary, and the 604267 Module and 604268 Verification exist. Verification remains PARTIAL because SQL compile, migration apply, and runtime dry-run were not performed. 604260 is not audited or closed, and 604250 must still not resume automatically.
- 604250 is blocked while 604260 remains open and remains blocked afterward until explicit Human reauthorization.
- 604310 implementation is blocked until 604250 closes and its own approval conditions are satisfied.
- 604316 must not be created merely because upstream documents exist.

## 11. Resume Conditions

- 604260 resumes only under its explicit Approval boundary.
- 604250 resumes only after 604260 implementation, Verification, Audit, closure, and explicit Human reauthorization for 604250.
- 604310 resumes only after 604250 closure and a separately approved 604310 implementation boundary.
- No lane resumes automatically from this NavigationMap.

## 12. Error Backtracking Guide

If `payment_ledger` insert fails due to missing `intent_id`:

- Go to the 604260 navigation and lifecycle documents.
- Check whether `toss_payment_requests.payment_intent_id` exists and is populated.
- Then check the 604250 `p_intent_id` handoff.

If `confirm_payment` cannot compile due to missing columns:

- Go to 604250 ImpactScope, Logic, and ChangeContract.
- Check `provider_tx_id`, `fee_amount`, `payment_method`, and `provider_response` drift.

If Toss direct confirm and webhook behave differently:

- Go to 604260 Logic and TestPlan.
- Check whether the webhook DONE path reuses `confirm_toss_payment`.

If duplicate confirmation returns an error instead of same-success:

- Go to 604310 ChangeContract.
- Do not patch 604310 until 604250 closes.

If amount mismatch still approves payment:

- Go to 604310 ChangeContract.
- Confirm whether amount-mismatch hard block has Human Approval.

If Codex tries to implement 604250 immediately after 604260:

- Stop.
- Check the 604250 explicit reauthorization requirement.

## 13. Verification And Audit Route

```text
Approval -> Implementation -> Module -> Verification -> independent Audit -> Human closeout
```

Verification records commands and results. Audit interprets Verification and git diff. Module remains implementer self-report.

## 14. Human Approval Route

- Human Approval is required for every implementation boundary.
- Approval must list allowed and forbidden files and blocking conditions.
- If Approval conflicts with ChangeContract or this NavigationMap, the stricter boundary wins.
- Human decides final resume, release, and merge.

## 15. Forbidden Shortcuts

- Do not jump from 604260 implementation directly into 604250 implementation.
- Do not create 604257 until 604250 is explicitly reauthorized and implemented.
- Do not create 604316 until 604310 Human Approval is explicitly authorized.
- Do not treat Index as implementation approval.
- Do not treat NavigationMap as implementation approval.
- Do not let Codex audit its own implementation.
- Do not resolve `intent_id` from `order_id`-only lookup.
- Do not create synthetic `payment_intent` at confirm time.

## 16. Out Of Scope

- SQL, migration, Edge Function, Flutter, Dart, Python, config, seed, package, lockfile, and test changes
- implementation of 604260, 604250, or 604310
- creation of 604267, 604257, or 604316
- replacement of any Index, lifecycle document, Approval, Module, Verification, or Audit

## 17. Final Rule

This NavigationMap does not authorize implementation.

This NavigationMap does not replace Index, Overview, Logic, TestPlan, ChangeContract, Approval, Module, Verification, or Audit.

If this NavigationMap conflicts with an approved ChangeContract or Approval, the stricter boundary wins.

Implementation must not resume automatically from a NavigationMap.
