# 014280_WorkPackage_POS_KDS_Manual_Fallback_And_First_Store_Readiness_Bridge.md

## 1. Purpose

This work package bridges POS provider verification with first-store operational readiness.

Provider verification may take time. Catch & Order must not wait for POS providers to approve APIs before preparing safe first-store operations.

This work package defines how manual POS/KDS fallback, first-store readiness, staff operation, evidence capture, and provider verification are connected.

## 2. Core Principle

The first store must be able to operate safely without deep POS integration.

POS/KDS integration is valuable, but the MVP must remain viable under:

- no official POS API
- delayed provider response
- provider sandbox unavailable
- local POS constraints
- payment scope unknown
- KDS/printer not integrated
- staff manual entry required
- provider outage
- temporary adapter disable

## 3. Scope

This work package covers:

- first-store POS/KDS manual fallback
- staff entry flow
- order handoff boundary
- payment/order separation
- KDS/printer fallback
- evidence capture
- provider verification dependency map
- pilot-store readiness bridge
- next documents to create

This does not define provider-specific adapter code.

## 4. Operating Modes

| Mode | Meaning | MVP Allowed |
|---|---|---|
| Manual POS Entry | Staff enters Catch & Order order into POS manually | Yes |
| Manual KDS / Kitchen Note | Staff prints or writes kitchen ticket manually | Yes |
| Evidence-Only Provider Mode | Provider data is used for evidence/reference only | Yes |
| Order Handoff Adapter | Catch & Order sends order to POS officially | Only after gate |
| Payment Observation | Catch & Order observes payment state | Only after security/payment review |
| Full Provider Integration | Official API/webhook/settlement integration | Later phase |

## 5. First-Store Readiness Checklist

| Readiness Item | Required For MVP | Owner | Status |
|---|---|---|---|
| POS vendor identified | Yes | Store owner | Open |
| POS version/model captured | Yes | Store owner | Open |
| Payment terminal/CAT identified | Yes | Store owner | Open |
| Printer/KDS hardware identified | Yes | Store owner | Open |
| Manual order entry SOP drafted | Yes | Operations | Open |
| Manual kitchen handoff SOP drafted | Yes | Operations | Open |
| Payment/order separation rule drafted | Yes | Product/Finance | Open |
| Staff correction evidence rule drafted | Yes | Operations | Open |
| Fallback status wording drafted | Yes | Product/Support | Open |
| Daily reconciliation sheet drafted | Yes | Finance/Ops | Open |
| Provider verification contact queued | Yes | Product | Open |
| Rollback/disable rule drafted | Yes | Technical/Ops | Open |

## 6. Manual POS Entry Flow

Baseline flow:

1. Customer enters waiting/order flow in Catch & Order.
2. Catch & Order records order intent and customer/session state.
3. Staff receives order handoff screen or printed summary.
4. Staff manually enters order into store POS.
5. Staff confirms POS entry in Catch & Order.
6. Catch & Order stores manual confirmation evidence.
7. Kitchen receives KDS/print/manual note according to store setup.
8. Payment is handled by POS/payment terminal unless officially integrated.
9. Daily reconciliation compares Catch & Order, POS, payment, and manual corrections.

## 7. Manual KDS / Kitchen Handoff Flow

If KDS is not integrated:

1. Staff receives order summary.
2. Staff prints kitchen note or writes manual ticket.
3. Staff marks kitchen handoff done.
4. Kitchen prepares order.
5. Staff updates fulfillment state manually.
6. Catch & Order records manual kitchen event.

If printer is integrated later, this flow becomes fallback.

## 8. Payment / Order Separation Rule

Catch & Order must not claim payment completion unless payment state is officially observed or confirmed by staff.

MVP rule:

| State | Allowed Source |
|---|---|
| Order intent | Catch & Order |
| POS entry confirmed | Staff confirmation or official POS response |
| Payment complete | POS/payment terminal or official payment event |
| Payment observed | Official provider/payment event only |
| Refund/cancel observed | Official provider/payment event or manual staff evidence |
| Settlement complete | Finance reconciliation only |

## 9. Evidence Requirements

Manual fallback must still create evidence.

Required evidence:

- order session id
- order summary
- staff confirmation id
- POS entry timestamp if available
- kitchen handoff timestamp
- payment confirmation source
- manual correction reason
- cancellation/refund reason if any
- reconciliation result
- fallback operator

## 10. First Store Daily Reconciliation

Daily reconciliation must compare:

| Source | Purpose |
|---|---|
| Catch & Order order records | Customer/order intent |
| POS sales/order records | Official store sales record |
| Payment terminal/VAN/PG record | Payment evidence |
| Manual staff correction log | Operational corrections |
| Kitchen/KDS/print note | Fulfillment evidence |
| Refund/cancel records | Financial correction evidence |

Any mismatch must be logged into the incident/reconciliation register if provider pilot exists, or first-store operation issue log if manual-only.

## 11. Provider Dependency Map

| Provider Fact | Required Before |
|---|---|
| Official order API | Tier 2 order handoff |
| Sandbox/test path | Adapter prototype |
| Webhook security | Callback-based status |
| Payment event scope | Tier 3 payment observation |
| Settlement reference data | payment/finance reconciliation |
| Contract/certification | official pilot |
| Support escalation | store pilot |
| Store-scoped credentials | production activation |

If any fact is unknown, manual fallback remains the default.

## 12. Staff Training Scope

Staff must be trained on:

- reading Catch & Order order summary
- entering order into POS manually
- marking POS entry confirmation
- sending kitchen note
- handling sold-out/unavailable menu
- correcting mistaken entry
- handling cancellation/refund requests
- using fallback status
- escalating mismatch
- recording evidence

## 13. First-Store Failure Modes

| Failure | Manual Fallback Response |
|---|---|
| POS API unavailable | manual POS entry |
| KDS unavailable | kitchen note/manual ticket |
| Printer failure | verbal/manual kitchen confirmation |
| Payment event unknown | rely on POS/payment terminal only |
| Provider outage | disable provider adapter |
| Staff entry mistake | correction evidence and reconciliation |
| Customer status mismatch | safe wording and support escalation |
| Duplicate order risk | pause order handoff and reconcile |

## 14. Required Outputs

This work package should produce:

- first-store manual POS entry SOP
- first-store manual KDS/kitchen note SOP
- first-store payment/order separation policy
- first-store daily reconciliation template
- staff fallback training checklist
- fallback evidence packet template
- first-store POS/KDS readiness register
- support answer map for fallback issues

## 15. Recommended Next Documents

Recommended next numbered documents:

| No. | Document |
|---:|---|
| 14290_SOP_First_Store_Manual_POS_Entry_And_Order_Confirmation.md |
| 14300_SOP_First_Store_Manual_KDS_Kitchen_Note_And_Fulfillment_Handoff.md |
| 14310_Policy_First_Store_Payment_Order_Separation_And_Reconciliation.md |
| 14320_Checklist_First_Store_POS_KDS_Staff_Training_And_Fallback_Readiness.md |
| 14330_Template_First_Store_Daily_Reconciliation_And_Manual_Correction_Log.md |

## 16. Non-Goals

This work package does not define:

- provider-specific adapter code
- production API integration
- payment execution
- franchise rollout
- final accounting system
- final KDS implementation

It defines the bridge between provider verification and first-store readiness.

## 17. Related Documents

- 14270_Index_POS_Provider_First_Verification_Wave_Closeout_And_Handoff.md
- 14260_Register_POS_Provider_First_Verification_Next_Action_And_Owner_Queue.md
- 14250_Register_POS_Provider_First_Verification_Blocker_Summary.md
- 14240_Assessment_POS_Provider_First_Verification_Response_Summary.md
- 14230_Template_POS_Provider_First_Verification_Request_Packet.md
- 14160_Register_POS_Provider_Incident_Reconciliation_And_Mismatch_Tracking.md
- 14150_Runbook_POS_Provider_First_Pilot_Activation_Monitoring_And_Rollback.md
- 14040_Checklist_POS_Gateway_Risk_Failure_Mode_And_Field_Readiness.md
