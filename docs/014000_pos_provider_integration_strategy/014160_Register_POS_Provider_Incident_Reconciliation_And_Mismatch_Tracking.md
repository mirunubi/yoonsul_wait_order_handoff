# 014160_Register_POS_Provider_Incident_Reconciliation_And_Mismatch_Tracking.md

## 1. Purpose

This register tracks incidents, reconciliation mismatches, duplicate events, callback failures, payment/order mismatches, and manual corrections that occur during POS provider pilots or integrations.

The purpose is to ensure that provider integration issues are not treated as temporary support noise. Each mismatch must become evidence for integration tier decisions, provider blocker updates, adapter fixes, fallback SOP improvements, or pilot rollback.

## 2. Core Rule

Any mismatch between Catch & Order, POS provider, payment provider, store staff action, and customer-visible state must be recorded.

Do not rely on chat messages or informal memory for reconciliation issues.

## 3. Register Scope

This register applies to:

- order handoff mismatch
- POS acceptance mismatch
- provider callback failure
- duplicate provider event
- payment/order mismatch
- cancellation/refund mismatch
- settlement mismatch
- printer/KDS handoff mismatch
- manual staff correction
- provider outage
- rollback trigger
- kill switch activation
- evidence packet gap

## 4. Incident Severity

| Severity | Meaning | Required Action |
|---|---|---|
| I0 | Customer/payment harm risk | Immediate rollback and escalation |
| I1 | Critical integration mismatch | Stop expansion and reconcile |
| I2 | Controlled pilot issue | Track, fix, and retest |
| I3 | Monitoring issue | Log and review |
| I4 | Informational | Keep as evidence only |

## 5. Incident Status

| Status | Meaning |
|---|---|
| Open | Incident identified |
| Investigating | Evidence is being reviewed |
| Waiting Provider | Waiting for provider response |
| Waiting Store | Waiting for store/staff confirmation |
| Waiting Reconciliation | Matching records pending |
| Mitigated | Temporary control applied |
| Resolved | Cause and fix confirmed |
| Accepted Risk | Known issue accepted with limits |
| Deferred | Not blocking current scope |
| Closed | No further action |

## 6. Incident Register

| Incident ID | Provider | Store | Severity | Status | Type | Description | First Detected | Owner | Next Action |
|---|---|---|---:|---|---|---|---|---|---|
| INC-POS-001 |  |  |  | Open |  |  |  |  |  |

## 7. Incident Types

| Type | Meaning |
|---|---|
| ORDER_HANDOFF_MISMATCH | Catch & Order handoff and provider state differ |
| PROVIDER_ACCEPTANCE_UNKNOWN | Provider response cannot be trusted |
| CALLBACK_INVALID | Callback signature/timestamp/replay validation failed |
| CALLBACK_DUPLICATE | Duplicate callback received |
| CALLBACK_DELAYED | Callback arrived outside expected window |
| PAYMENT_ORDER_MISMATCH | Payment and order states diverged |
| CANCELLATION_MISMATCH | Cancellation state differs across systems |
| REFUND_MISMATCH | Refund/correction state differs |
| SETTLEMENT_MISMATCH | Daily reconciliation does not match |
| PRINTER_KDS_MISMATCH | Kitchen/print state differs from order state |
| MANUAL_CORRECTION | Staff corrected state manually |
| DEVICE_FAILURE | POS terminal, printer, KDS, CAT, signpad, or network failure |
| PROVIDER_OUTAGE | Provider system outage or degraded response |
| KILL_SWITCH_USED | Adapter kill switch activated |
| FALLBACK_USED | Store used manual fallback |
| EVIDENCE_GAP | Required evidence was missing |

## 8. Required Incident Fields

Each incident must include:

| Field | Required |
|---|---|
| incident_id | Yes |
| provider_id | Yes |
| store_id | Yes |
| severity | Yes |
| status | Yes |
| incident_type | Yes |
| description | Yes |
| detected_at | Yes |
| detected_by | Yes |
| affected_order_id | If order-related |
| affected_payment_id | If payment-related |
| correlation_id | If available |
| evidence_reference | Yes |
| owner | Yes |
| next_action | Yes |
| resolution_condition | Yes for I0-I2 |

## 9. Reconciliation Mismatch Table

Use this table for daily pilot reconciliation.

| Reconciliation ID | Provider | Store | Business Date | Mismatch Type | Internal Count | Provider Count | Payment Count | Manual Corrections | Status | Owner |
|---|---|---|---|---|---:|---:|---:|---:|---|---|
| REC-POS-001 |  |  |  |  |  |  |  |  | Open |  |

## 10. Mismatch Types

| Mismatch Type | Meaning |
|---|---|
| INTERNAL_ONLY_ORDER | Exists in Catch & Order only |
| PROVIDER_ONLY_ORDER | Exists in provider only |
| DUPLICATE_PROVIDER_ORDER | Provider has duplicated order |
| MISSING_PROVIDER_ACCEPTANCE | Handoff attempted but no provider acceptance |
| PAYMENT_WITHOUT_ORDER | Payment exists but order state missing |
| ORDER_WITHOUT_PAYMENT | Order visible but payment missing or unclear |
| CANCEL_INTERNAL_ONLY | Cancel exists only internally |
| CANCEL_PROVIDER_ONLY | Cancel exists only in provider |
| REFUND_INTERNAL_ONLY | Refund exists only internally |
| REFUND_PROVIDER_ONLY | Refund exists only in provider/payment system |
| SETTLEMENT_AMOUNT_MISMATCH | Daily amount mismatch |
| STAFF_CORRECTION_MISMATCH | Staff correction not reflected consistently |
| CALLBACK_LEDGER_MISMATCH | Callback ledger and order/payment state differ |

## 11. Required Evidence For Reconciliation

Each reconciliation mismatch must link to:

- internal order ledger record
- provider order evidence
- provider response or callback payload
- payment approval/cancel/refund reference if applicable
- manual staff correction record if applicable
- customer-facing status snapshot if relevant
- reconciliation calculation note
- owner decision

## 12. Immediate Rollback Triggers

The following incident patterns require immediate rollback or downgrade:

| Pattern | Required Action |
|---|---|
| Duplicate paid order | Disable provider handoff and payment-aware operation |
| Payment approved but order not visible | Stop Tier 3+ and reconcile |
| Order visible but payment not approved | Stop customer-facing completion wording |
| Callback replay changes state | Disable callback trust |
| Provider result unknown after retry | Enter manual fallback |
| Store staff cannot recover manually | Stop pilot |
| Customer harm or dispute risk | Escalate and rollback |
| Credential/security incident | Disable adapter and rotate credential |

## 13. Incident Resolution Conditions

| Incident Type | Resolution Condition |
|---|---|
| ORDER_HANDOFF_MISMATCH | Internal and provider state matched or corrected |
| CALLBACK_INVALID | Cause confirmed and verification rule updated |
| CALLBACK_DUPLICATE | Idempotency/replay rule confirmed |
| PAYMENT_ORDER_MISMATCH | Payment and order evidence reconciled |
| CANCELLATION_MISMATCH | Cancellation/refund evidence reconciled |
| SETTLEMENT_MISMATCH | Daily close amount matched or correction recorded |
| DEVICE_FAILURE | Device issue isolated and fallback confirmed |
| FALLBACK_USED | Fallback result entered and reconciled |
| EVIDENCE_GAP | Missing evidence captured or gap accepted with risk note |

## 14. Provider Feedback Loop

If an incident depends on provider behavior, update:

- provider readiness register
- provider blocker register
- official response assessment if provider clarification changes facts
- evidence packet
- adapter spec or implementation backlog
- pilot runbook
- decision gate status

## 15. Store Feedback Loop

If an incident depends on store operation, update:

- manual fallback SOP
- staff training record
- store readiness checklist
- support runbook
- customer-facing message rule
- owner/admin dashboard issue note

## 16. Daily Pilot Reconciliation Procedure

At the end of each pilot day:

1. Export Catch & Order order ledger.
2. Export provider order evidence.
3. Export payment/cancel/refund references if applicable.
4. Compare order counts.
5. Compare payment counts.
6. Compare cancellation/refund counts.
7. List mismatches.
8. Assign owner.
9. Mark pilot status: continue, hold, rollback, or block.
10. Update evidence packet and incident register.

## 17. Weekly Provider Review

For active provider pilots, review weekly:

- incident count by type
- unresolved I0/I1 incidents
- duplicate callback count
- timeout/retry count
- fallback usage count
- reconciliation mismatch count
- provider response time
- staff correction count
- adapter bug count
- readiness/blocker status changes

## 18. Non-Goals

This register does not define:

- final API implementation
- final payment settlement accounting
- final provider commercial terms
- final production rollout approval
- legal dispute process

It only tracks operational incidents and reconciliation mismatches.

## 19. Related Documents

- 14150_Runbook_POS_Provider_First_Pilot_Activation_Monitoring_And_Rollback.md
- 14140_Governance_POS_Provider_Integration_Decision_Gate.md
- 14130_Register_POS_Provider_Blocker_Risk_And_Resolution_Tracking.md
- 14120_Assessment_POS_Provider_Official_Response_And_Integration_Disposition.md
- 14100_Register_POS_Provider_Readiness_Status_And_Next_Action.md
- 14090_Template_POS_Provider_Integration_Evidence_Packet.md
- 14070_Spec_POS_Provider_Adapter_Boundary_And_Evidence_Contract.md
- 20000_Validation_Security_Audit
- 20400_foundation_security
