# 11020 POS API Integration Truth Boundary

## 1 Purpose

POS API integration may exist only when a POS provider exposes supported order/payment/status interfaces.

POS API attempt must not be confused with POS success.

This document defines integration truth boundary only and does not create POS API implementation.

This document is boundary governance only.
It does not approve POS SDK, webhook, polling, or order mutation runtime.

## 2 POS API Integration Concepts

| concept | meaning |
| --- | --- |
| POS API availability | Provider exposes supported interfaces for the store context. |
| POS API credential/config concept | Store-level configuration candidate for POS API access. |
| POS order creation attempt | Outbound order creation call initiated. |
| POS order creation success | POS authority confirms order creation. |
| POS order creation failure | POS authority rejects, times out, or returns error. |
| POS order number mapping | Link between handoff order candidate and POS order identifier. |
| POS status callback / polling candidate | Future path to observe POS order status. |
| POS cancel/change candidate | Future path to request POS cancel or change. |
| POS integration disabled state | Integration profile disabled with audit record. |

## 3 Truth Rules

- POS API available does not equal integrated.
- POS API configured does not equal validated.
- POS API attempt does not equal POS success.
- POS API success must come from proper POS authority.
- POS order number mapping does not equal payment completion.
- POS status callback does not equal platform authority.
- POS failure does not automatically cancel customer request.
- POS integration success does not make platform financial truth owner.

## 4 Non-Implementation Boundary

- no POS API endpoint implementation.
- no credentials.
- no SDK.
- no webhook implementation.
- no polling job.
- no POS order mutation.
- no POS payment logic.

## 5 Cross-References

- `docs/11000_integration_boundary/11010_POS_Payment_Printer_Integration_Boundary.md`
- `docs/09000_data_model_state_machine/09090_Order_Candidate_And_Confirmation_State_Refinement.md`
- `docs/03000_saas_runtime/03030_Store_Runtime_Profile_Model.md`

## 6 Open Decisions

- supported POS providers.
- order creation API pattern.
- callback vs polling.
- retry policy.
- cancellation/change authority.
- POS order number visibility.
- sandbox validation process.

## 7 Current Status

Status: active POS API integration truth boundary. Not implementation approval.
