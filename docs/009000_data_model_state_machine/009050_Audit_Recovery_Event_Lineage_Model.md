# 009050_Audit_Recovery_Event_Lineage_Model

## 1 Purpose

Recovery must not overwrite original events.

Audit lineage must preserve what happened, who acted, why, and what changed.

Evidence does not equal approval.

Dismiss does not equal resolved.

This document is conceptual only.
It does not define SQL, migrations, app code, Supabase functions, immutable storage implementation, physical audit table, or production compliance behavior.

## 2 Core Principles

- append-only recovery.
- original event remains immutable conceptually.
- correction creates new event.
- rollback creates new event.
- support action creates evidence but not approval.
- printer retry does not equal POS order creation.
- POS API retry must avoid duplicate external order.
- manual recovery must link to original event.

## 3 Event Lineage Families

- `order_candidate_lineage`: customer creation, staff review, confirmation/rejection, cancellation, recovery.
- `printer_failure_lineage`: printer attempt, failure, recovery item, retry, manual path, resolution.
- `pos_api_failure_lineage`: POS API attempt, failure, idempotency/retry review, recovery, success or manual fallback.
- `manual_pos_input_lineage`: manual POS needed marker, staff entry marker, proof/review, audit.
- `staff_correction_lineage`: wrong item/table/status correction, original event reference, new correction event.
- `customer_no_show_lineage`: waiting, call, not arrived, no-show candidate, review, close/cancel.
- `config_change_lineage`: request, validation, approval, activation, rollback, disable.
- `export_request_lineage`: request, review, approval/rejection, generation, delivery, expiry/revocation, audit.
- `support_access_lineage`: request, approval, scoped access, action, audit review, close.
- `future_franchise_recommendation_lineage`: intelligence material, recommendation, review, approval/rejection, controlled application, outcome.

## 4 Example Lineages

```text
order candidate created
  -> printer failed
  -> recovery opened
  -> printer retry requested
  -> staff manual POS input confirmed
  -> recovery resolved
```

```text
waiting registered
  -> customer called
  -> customer not arrived
  -> no-show candidate
  -> staff review
  -> closed
```

```text
package change requested
  -> validation pending
  -> approved
  -> activated
  -> rollback required
  -> disabled
```

```text
support access requested
  -> approved
  -> support action taken
  -> audit reviewed
  -> closed
```

## 5 Recovery Item Rules

- recovery item has lifecycle separate from original event.
- recovery resolution does not erase failure.
- recovery closure requires reason.
- duplicate candidate suspected must not silently delete candidate.
- manual POS input completed must not invent POS transaction ID unless sourced from POS or staff proof.
- recovery assignment should remain visible until resolved, escalated, or closed with reason.

## 6 Audit Evidence Rules

- evidence packet may support review.
- evidence packet is not approval.
- audit event is not mutation.
- export evidence must record purpose/scope/recipient.
- support evidence must record time window and reason.
- correction evidence must reference original event and correction reason.

## 7 Conceptual Model Consolidation Cross-Reference

- Admin/support/audit lineage is further refined in `docs/09000_data_model_state_machine/009100_Admin_Support_Audit_Entity_Lineage_Model.md`.
- Runtime profile change events are defined in `docs/09000_data_model_state_machine/009080_Runtime_Profile_And_Change_Request_Entity_Model.md`.
- Recovery must still not overwrite original events.

## 8 Open Decisions

- immutable audit storage strategy.
- evidence packet shape.
- recovery SLA.
- recovery assignment ownership.
- customer notification after recovery.
- duplicate prevention strategy.

## 9 Current Status

Status: active audit and recovery lineage model.
