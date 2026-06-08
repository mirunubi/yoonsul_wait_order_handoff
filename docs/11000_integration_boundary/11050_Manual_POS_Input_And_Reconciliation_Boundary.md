# 11050 Manual POS Input And Reconciliation Boundary

## 1 Purpose

Many stores may have POS but no external POS API.

Manual POS input is a realistic MVP/early path.

Manual POS input marker must not be confused with POS financial truth.

This document defines boundary only and does not create reconciliation runtime.

## 2 Concepts

| concept | meaning |
| --- | --- |
| manual POS input needed | Staff must enter order into POS manually. |
| manual POS input completed | Staff marks manual entry completed. |
| staff POS input checklist | Structured checklist for manual entry steps. |
| staff confirmation | Operational staff confirmation of order handling. |
| order candidate reconciliation | Compare handoff order candidate with POS evidence. |
| POS receipt comparison candidate | Compare handoff record with POS receipt evidence. |
| daily close reconciliation candidate | End-of-day comparison candidate. |
| mismatch review | Review when handoff and POS evidence diverge. |
| manual recovery item | Recovery queue item for manual POS/reconciliation gap. |

## 3 Truth Rules

- manual POS input needed does not equal POS input completed.
- manual POS input completed is staff assertion unless POS evidence exists.
- staff assertion does not equal financial truth.
- reconciliation candidate does not equal verified settlement.
- mismatch review must preserve original events.
- manual recovery must link to original order/session.
- POS receipt evidence must be reviewed before financial claim.

## 4 Non-Implementation Boundary

- no POS scraping.
- no receipt OCR.
- no reconciliation engine.
- no settlement report generation.
- no accounting integration.
- no financial dashboard.

## 5 Cross-References

- `docs/11000_integration_boundary/11010_POS_Payment_Printer_Integration_Boundary.md`
- `docs/11000_integration_boundary/11040_Payment_And_Financial_Truth_Boundary.md`
- `docs/09000_data_model_state_machine/09090_Order_Candidate_And_Confirmation_State_Refinement.md`
- `docs/09000_data_model_state_machine/09100_Admin_Support_Audit_Entity_Lineage_Model.md`

## 6 Open Decisions

- manual POS checklist fields.
- evidence attachment rules.
- daily close comparison depth.
- mismatch handling owner.
- staff assertion audit depth.
- whether photo evidence is allowed.

## 7 Current Status

Status: active manual POS input and reconciliation boundary. Not implementation approval.
