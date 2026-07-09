# 604285_ChangeContract_Cross_Scope_0042_Delivery_Order_Intake_Baseline_Replay_Blocker.md

Status: Draft
Lifecycle: ChangeContract
Gate Classification: Cross-Scope Baseline Migration Replay Blocker ��� Stage 1 Design
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-05

**This document does not approve implementation.** It defines the candidate change
boundary Human Approval (`604286`, not yet created) must resolve before any SQL,
migration, or runtime change is made to `0042`.

0042 must not be modified until 604286 Approval is created.

604260 must not be closed by this document. 604250 must not resume by this document.
604286 Approval is required before implementation.

---

## 0. Purpose

Give Human Approval a complete, self-contained boundary for deciding how to correct
`0042_create_delivery_order_intake_rpc.sql` so that full valid sequential migration
replay can progress past it toward `0142`.

---

## 1. Change Boundary

```text
In scope for a FUTURE authorized change (not this document):
  - sql/migrations/0042_create_delivery_order_intake_rpc.sql (single-line correction
    candidate, per 604283 §9 Option A)

Out of scope, unconditionally:
  - sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql
  - sql/migrations/0035_verify_schema.sql, 0038_create_toss_webhook_processor_rpc.sql
    (already resolved under 604270/604276/604277; not reopened here)
  - Any 604250, 604260, 604270, or 604310 document or Approval
  - Any Flutter, Edge Function, Python, or config file
  - Any file not explicitly named in a future 604286 Allowed Files list
```

---

## 2. Approved Files Candidate

```text
CANDIDATE ONLY -- not authorized by this document. Final Allowed Files list is set by
604286 Human Approval, which may narrow (but should not widen) this candidate list:

  1. sql/migrations/0042_create_delivery_order_intake_rpc.sql (one-line correction)
  2. A future 604287 Module document (implementation self-report, authored after 604286)
```

---

## 3. Forbidden Files

```text
The following must NOT be touched under any 604280/604286 authorization:

sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql
sql/migrations/0035_verify_schema.sql
sql/migrations/0038_create_toss_webhook_processor_rpc.sql
sql/migrations/0014_create_payment_ledger.sql
sql/migrations/0027_create_payment_intent_rpc.sql
sql/migrations/0052_create_kiosk_session_rpc.sql
sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql
sql/migrations/0103_create_toss_payments_pipeline_rpc.sql
docs/600000_implementation_lifecycle/604000_workpackets/604250_scope_d_00_payment_ledger_confirm_payment_schema_drift_alignment/**
docs/600000_implementation_lifecycle/604000_workpackets/604260_scope_d_00a_toss_mvp_payment_intent_binding_precondition/**
docs/600000_implementation_lifecycle/604000_workpackets/604270_cross_scope_local_migration_replay_baseline_blockers/**
docs/600000_implementation_lifecycle/604000_workpackets/604400_scope_d_01_payment_confirm_idempotency/**

Also implicitly forbidden, since not listed in §2:
sql/migrations/0057_create_delivery_platform_rpc.sql
sql/migrations/0074_create_pos_provider_registry.sql
sql/migrations/0078_create_delivery_sync_rpc.sql
sql/migrations/0106_create_delivery_platform_pipeline_rpc.sql
sql/migrations/0073_final_verification.sql
Any replay-harness / migration-runner configuration file
```

---

## 4. 0042 Change Contract

```text
Allowed correction:
- result_payload := jsonb_build_object(...)
+ result_payload = jsonb_build_object(...)

No other delivery intake logic change is approved.
No function signature change is approved.
No idempotency table design change is approved.
No delivery status mapping change is approved.
No caller/callee change is approved.
No 0057/0074 change is approved.

Additional constraints:
- The correction must be limited to exactly this one line (L396). Any broader diff in
  a future 604287 Module report is out of the boundary this ChangeContract anticipates
  and would require a ChangeContract revision, not a same-boundary Module report.
- 0042 must NOT be skipped in place of a fix (604283 §6) -- it is the sole definition
  of intake_delivery_order, sync_delivery_order_status, and reject_delivery_order, and
  0043 declares a header dependency on it; skipping would silently remove load-bearing
  objects and later migrations would still fail to reach 0142 in a strict sequential
  replay.
- Human must explicitly confirm, before approving an in-place edit, whether any
  environment has ever successfully applied the current (broken) 0042 file as-is. Per
  604283 §7, this is believed not possible given the parse-time validation default,
  but that belief must be confirmed by Human, not assumed.
```

---

## 5. Historical Migration Policy

```text
General rule in this lifecycle: historical migrations must not be edited in place, to
avoid divergence from environments that already successfully applied them.

Narrower fact specific to 0042 (604283 §7, independently re-derived in this
ChangeContract): the defect is an unconditional parse-time syntax error inside a
plain SQL UPDATE...SET list, validated by PostgreSQL at CREATE-function time by
default. 0042 could not have been successfully applied, in its current broken form,
by ordinary sequential execution in any environment -- narrowing, but not eliminating,
the general append-only risk. This is the same reasoning 604276 already applied to
0035/0038, and the same Human-confirmation requirement applies here before any
in-place edit is approved.

Forward-patch-only and replay-skip alternatives were both evaluated in 604283 §5/§6
and found not viable for 0042 (forward patch cannot be reached by a halted sequential
replay; skip would remove the sole definition of load-bearing, actively-called
functions). Direct historical correction (604283 §9, Option A) is the only option that
both unblocks replay and does not require an unproven runner-level mechanism.
```

---

## 6. Runtime Verification Contract

```text
Once 604286 authorizes the correction, the corresponding tests in 604284 TestPlan
(TC-042-001 through TC-042-062) define the required evidence before any closeout claim
is made. At minimum: 0042 must apply cleanly, its three functions and grants must be
confirmed to exist, and replay must be able to continue at least through 0043 before
any statement about progress toward 0142 is made.
```

---

## 7. Downstream Re-Enablement Contract

```text
Passing 604284's tests authorizes ONLY:
  - A future, separate 604288 Verification document recording the new replay evidence
    (how far replay now proceeds, and whether 0142 is reached).
  - A future, separate 604289 Audit reviewing 604287/604288 before any closeout
    decision.
It does NOT, by itself:
  - Close 604260 or 604270 (separate, 604260/604270-owned decisions).
  - Resume 604250 (a separate, later Human reauthorization decision).
  - Authorize 604310 implementation or 604316 creation.
  - Authorize fixing any further blocker discovered between 0043 and 0142 (e.g. 0073)
    -- any such blocker requires its own new workpacket, following the same precedent
    604280 itself follows relative to 604270.
```

---

## 8. Rollback / Recovery

```text
If a 604286-authorized fix to 0042 is applied and any test in 604284 fails:
  - The fix must be reverted (git revert of the specific commit, not a fresh undo edit)
    rather than patched further in place mid-investigation.
  - 604280 stays open; a revised ChangeContract or Approval is required before retrying.
  - No partial or unverified fix may be represented as closing 604280 -- closure
    requires the full authorized scope to pass its required tests.
```

---

## 9. Human Approval Requirements

```text
604286 Human Approval, when created, must at minimum:
  1. Select Option A from 604283 §9 Decision Matrix, or an explicit variant.
  2. Confirm or refute the "no plausible divergent already-applied 0042 state"
     assumption in §4/§5 above.
  3. Set the final Allowed Files list (may narrow but not widen §2's candidate list).
  4. Explicitly state that it does not, by itself, close 604260/604270 or resume
     604250, unless a separate, explicit decision to do so is also documented there.
Codex or any implementer may touch 0042 only once 604286 has been created and
authorizes it. No such Approval has been created at the time this ChangeContract is
written.
```

---

## 10. Explicitly Not Approved

```text
- 0142 edits of any kind.
- Any change to 0035, 0038, 0014, 0027, 0052, 0098, or 0103.
- Any file under the 604250, 604260, or 604310 workpacket folders.
- Any change to 0057, 0074, 0078, or 0106.
- A replay-harness/migration-runner skip policy for 0042.
- Broad delivery-intake redesign, consolidation, or refactor beyond the one-line fix.
- Forward-patch-only strategy (604283 §5 established this cannot reach past 0042
  alone; it is not what this ChangeContract anticipates being authorized).
- 604250 resume, 604260/604270 closeout, or 604310 implementation.
```

---

## 11. Final ChangeContract

```text
This document does not approve implementation. 0042 must not be modified until 604286
Human Approval is created and names the authorized option.

604260 must not be closed by this document. 604250 must not resume by this document.

This ChangeContract's role is limited to presenting the change boundary and the
candidate files, plus a recommended candidate (Option A, direct one-line historical
correction) that Human may accept, modify, or reject via 604286 Approval.
```
