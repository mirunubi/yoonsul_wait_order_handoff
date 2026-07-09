# 604282_Overview_Cross_Scope_0042_Delivery_Order_Intake_Baseline_Replay_Blocker.md

Status: Draft
Lifecycle: Overview
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 1 Design
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-05

This Overview does not authorize implementation. It restates and organizes the
verified facts from `604281` ImpactScope into a design-facing narrative. It does not
approve any SQL, migration, or runtime change to `0042` or `0142`.

---

## 0. Purpose

Explain, for Human decision-making, why **604280** exists as its own cross-scope
workpacket rather than as a re-opened item under 604270, and what the confirmed 0042
blocker means for 604260 and 604250.

---

## 1. Why This Workpacket Exists

`604270` was created to resolve two pre-existing baseline migration replay blockers
(`0035`, `0038`) discovered during `604260`'s Supabase local replay attempt. `604277`
implemented, and `604278` verified, that both corrections were applied correctly and
within boundary — independently confirmed in `604279` Audit
(`PASS_WITH_NEW_BASELINE_BLOCKER`). However, re-running the full clean sequential
replay past the fixed 0035/0038 exposed a **third**, previously unreached, baseline
migration replay blocker: `0042_create_delivery_order_intake_rpc.sql`. Because 0042 is
not named in 604270's own Approval (`604276`) or any of its documents, no existing
document can authorize touching it. 604280 is the minimum-scope container for
investigating and proposing a fix for exactly this one file.

---

## 2. Relationship To 604270

```text
604270 resolved 0035/0038.
0042 is a newly exposed blocker after 0035/0038 were fixed -- it was not visible to
  604270 or to 604260's original replay attempt because sequential replay with
  ON_ERROR_STOP=1 never got past 0035 (and, in continued inspection, 0038) until
  604277's corrections were in place.
604270's own Approval (604276) explicitly limited its Approved Files to 0035, 0038,
  and the 604277 Module -- it did not, and could not, anticipate 0042, since 0042 was
  undiscovered at the time 604276 was authored.
604280 is therefore a new, separate cross-scope workpacket, not an amendment to 604270.
604279 Audit's own "Required Follow-Up" (§12) anticipated exactly this: "a new,
  separately-scoped design/approval package ... is required before 0042 may be
  modified."
```

---

## 3. Relationship To 604260

```text
604260 (Scope D 00A, Toss MVP PaymentIntent Binding Precondition) still needs SQL
  compile / migration apply / runtime dry-run evidence for 0142, per its own 604269
  Audit. That evidence can only come from a full valid sequential replay that reaches
  0142.
0042 sits between 0038 and 0142 in migration order (0042 < 0142). Full sequential
  replay cannot skip it under a strict ON_ERROR_STOP=1 runner (604281 §7, consistent
  with the replay model already established in 604270/604273).
0042 blocks clean replay before 0142 -- exactly the same structural role 0035/0038
  played before 604270, now occupied by a different file.
```

---

## 4. Confirmed 0042 Blocker

| Field | Value |
| --- | --- |
| File | `sql/migrations/0042_create_delivery_order_intake_rpc.sql` |
| Location | Line 396, inside `catchmenu_integrations.intake_delivery_order`'s body |
| Defect | `update catchmenu_common.idempotency_keys set ..., result_payload := jsonb_build_object(...)` — `:=` is PL/pgSQL assignment syntax, invalid inside a plain SQL `UPDATE ... SET` column list |
| Correct form | `result_payload = jsonb_build_object(...)` |
| Same defect class as | Pre-fix `0038` (`processing_error :=` → `processing_error =`, corrected under 604276/604277) |
| Repo-wide scan | Exactly one match for `result_payload :=` across all migrations — this single line |
| Other `:=` in this file | Confirmed, independently re-checked in this Overview: all other `:=` occurrences in `0042` are either valid PL/pgSQL variable assignment (e.g. `v_total_amount := 0`) or valid named-parameter function-call syntax (e.g. `p_tenant_id := p_tenant_id` when calling `catchmenu_audit.append_audit_record`) — neither is a defect; only the line-396 `UPDATE ... SET` usage is invalid |

Both 604278 (verbatim psql error) and 604281 (independent line-level source review)
agree on this single defect and its correct fix. This Overview independently
re-confirmed the same finding by re-reading the file directly.

---

## 5. Why This Is Not A 604260 Implementation Failure

```text
604269 Audit already found 0142 itself free of structural defects via deep static
  cross-reference.
0042 predates 0142 by 100 migration numbers and was authored long before 604260's
  0142 patch. There is no relationship between 0042's defect and anything 604260 or
  604270 authored.
0042 was never executed in any blocked replay attempt before 604277's fix to 0035/0038
  -- it was simply never reached. Its failure is not new in the sense of being newly
  introduced; it is newly *exposed* by clearing the blockers in front of it.
```

---

## 6. Why 0042 Cannot Be Skipped

```text
1. intake_delivery_order has exactly one definition in the entire migration history --
   sql/migrations/0042_create_delivery_order_intake_rpc.sql. If 0042 fails to apply,
   this function is never created anywhere in the replayed schema.
2. 0043_create_did_display_rpc.sql declares a header dependency: "Depends on:
   0042_create_delivery_order_intake_rpc.sql" -- a strict sequential replay runner
   using ON_ERROR_STOP=1 halts at 0042 and never reaches 0043 or anything after it,
   including 0142.
3. 0057_create_delivery_platform_rpc.sql and 0074_create_pos_provider_registry.sql
   both call catchmenu_integrations.intake_delivery_order(...) inside their own
   function bodies (confirmed at 0057 L250/401/552 and 0074 L1514/1784). PostgreSQL
   does not require a called function to exist at CREATE-time for a plpgsql body, so
   these files could in principle still apply even with intake_delivery_order missing
   -- but any actual runtime call to process_baemin_order/process_yogiyo_order/
   process_coupang_order or the provider-registry delivery path would fail at call
   time with an undefined-function error.
4. Because of (2), the question of whether 0057/0074 could apply without 0042 is moot
   for the actual replay goal: a strict sequential ON_ERROR_STOP=1 replay never
   reaches 0057 or 0074 either, since it halts at 0042 itself, well before 0043.
```

---

## 7. Downstream Dependencies

| Migration | Relationship to 0042 |
| --- | --- |
| `0043_create_did_display_rpc.sql` | Header-declared dependency; unreachable while 0042 fails |
| `0057_create_delivery_platform_rpc.sql` | Calls `intake_delivery_order` in 3 function bodies |
| `0074_create_pos_provider_registry.sql` | Calls `intake_delivery_order` in 2 locations |
| `0078_create_delivery_sync_rpc.sql` | Redefines `sync_delivery_order_status` (first defined in 0042) |
| `0106_create_delivery_platform_pipeline_rpc.sql` | Redefines `reject_delivery_order` (first defined in 0042) |
| `0142_patch_toss_mvp_payment_intent_binding.sql` | No direct reference to 0042's delivery functions; blocked only by replay *order*, not by any functional coupling |

---

## 8. Non-Goals

```text
604280 does NOT:
  - Modify 0042 or 0142.
  - Resume 604250 implementation.
  - Close 604260.
  - Implement 604310.
  - Create 604286 Human Approval (a Human-authored document, not Claude/Cursor).
  - Redesign delivery order intake business logic, idempotency-key table design, or
    delivery status mapping.
  - Decide, on its own authority, the final fix strategy -- 604283 Logic proposes
    options and a recommendation; only Human Approval (604286) can select one.
```

---

## 9. Recommended Path

```text
Design-only recommendation (subject to Human decision in 604286, not self-authorizing):
  1. 0042's defect is a single invalid assignment operator inside an UPDATE ... SET
     list, structurally identical to the already-approved and already-verified 0038
     fix. A direct, minimal historical correction (result_payload := -> result_payload
     =) is the lowest-risk, narrowest path, consistent with the 604270/0038 precedent.
  2. No skip policy is proposed for 0042, for the same structural reasons 0038 could
     not be skipped under 604270/604273: it is the sole definition of a load-bearing
     function that later migrations and callers depend on, and a strict sequential
     replay runner halts at 0042 regardless of any skip policy applied to a
     verification-only file like 0035.
  3. Neither action is authorized by this Overview. See 604283 Logic §9 Decision
     Matrix and 604285 ChangeContract for the full policy question set Human Approval
     must resolve.
```

---

## 10. Final Overview

```text
604270 resolved 0035/0038. 0042 is a newly exposed blocker after 0035/0038 were fixed
-- it was not visible to any prior workpacket until the replay could get past those
two files. 0042 blocks clean replay before 0142, for the same structural reason 0035/
0038 did: a strict sequential ON_ERROR_STOP=1 replay runner halts at the first
file-level parse failure. 604260 closeout remains blocked, and 604250 resume remains
blocked, for the same underlying category of reason as before -- now specifically
0042. This Overview recommends a direct one-line historical correction (604283 §9
Decision Matrix, Option A) for Human Approval's consideration in a future 604286. No
SQL, migration, or runtime change is made or authorized by this document.
```
