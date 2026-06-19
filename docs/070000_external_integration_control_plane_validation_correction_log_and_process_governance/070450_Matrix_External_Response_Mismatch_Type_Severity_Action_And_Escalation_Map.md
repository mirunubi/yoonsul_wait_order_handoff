# 070450_Matrix_External_Response_Mismatch_Type_Severity_Action_And_Escalation_Map.md

## 1. Purpose

This matrix defines how the External Integration Control Plane classifies external response mismatches, assigns severity, selects allowed recovery actions, and escalates unresolved conflicts.

The document prevents external POS, VAN, PG, payment provider, webhook, delivery app, kiosk vendor, KDS vendor, membership, coupon, tax, or accounting responses from being automatically trusted when their fields conflict with internal ledgers, canonical mappings, or prior accepted state.

## 2. Scope

This matrix applies to all inbound external responses and events handled under the 70000 External Integration Control Plane, including:

- POS / VAN / PG payment responses
- Payment approval, cancel, refund, reversal, inquiry, and settlement responses
- Webhook and callback events
- External order app and delivery app events
- Kiosk and KDS vendor events
- Membership, coupon, point, voucher, and promotion responses
- Tax, accounting, ERP, and settlement file responses

## 3. Parent And Related Documents

- Parent Index: `70400_Index_External_Response_Validation_Correction_And_Canonical_Mapping.md`
- Previous: `70440_Policy_External_Response_Field_Mismatch_Conflict_And_Manual_Review_Control.md`
- Next: `70460_Runbook_External_Response_Mismatch_Review_Correction_And_Escalation_Action.md`
- Related: `70230_Spec_External_RPC_API_Webhook_Event_Envelope_Canonical_Field_And_Signature_Registry.md`
- Related: `70360_Matrix_External_Payment_Recovery_Decision_State_Evidence_And_Action_Map.md`
- Related: `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md`

## 4. Core Principle

An external mismatch is not a formatting inconvenience. It may represent money loss, customer claim exposure, order duplication, settlement error, device contamination, replay attack, provider defect, or accounting misstatement.

Therefore:

1. Raw external values must be preserved.
2. Canonical values must be derived only through approved mapping rules.
3. Automatic correction is allowed only for low-risk normalization cases.
4. Money, approval, cancel, refund, store, terminal, customer, tax, or settlement conflicts must not be silently corrected.
5. Manual review must leave evidence.
6. Escalation must occur before unresolved mismatch becomes business state.

## 5. Severity Levels

| Severity | Label | Meaning | Auto Correction | State Change Allowed |
|---|---|---|---|---|
| S0 | Informational | No business impact; formatting-only difference | Allowed | Allowed after validation |
| S1 | Low | Non-financial canonical mismatch with safe mapping | Allowed with evidence | Allowed after mapping |
| S2 | Medium | Requires controlled normalization or operator review | Conditional | Hold until review or rule match |
| S3 | High | Payment/order/customer/terminal conflict possible | Not allowed | Blocked until manual review |
| S4 | Critical | Money, approval, cancel, refund, settlement, fraud, or tamper risk | Not allowed | Blocked; escalate immediately |

## 6. Mismatch Type Matrix

| Mismatch Type | Example | Severity | Default Action | Escalation Owner | Evidence Required |
|---|---|---:|---|---|---|
| Whitespace / casing mismatch | `approved` vs `APPROVED` | S0 | Normalize by canonical mapping | None | Raw payload hash, mapping version |
| Date format mismatch | `2026-06-17` vs `20260617` | S0/S1 | Normalize if timezone is known | Integration owner | Raw timestamp, received_at, provider timezone |
| Provider code alias | `00`, `SUCCESS`, `APPROVED` | S1 | Map to canonical success only if registry version approves | Integration owner | Provider code registry, mapping version |
| Unknown provider code | New response code not registered | S2 | Quarantine and register gap | Integration owner | Raw code, provider doc reference, review log |
| Missing optional field | Optional memo or display label absent | S1 | Accept with warning | Integration owner | Missing field log |
| Missing required trace id | Provider trace id absent | S3 | Hold and request provider inquiry | Payment integrity owner | Raw payload, request id, provider inquiry result |
| Missing approval number on success | Success response without approval_no | S4 | Block confirmation; move to manual review/inquiry | Payment integrity owner | Raw response, inquiry evidence |
| Amount mismatch | Expected 25,000 / approved 24,900 | S4 | Block; never auto-correct | Payment integrity + finance | Intent, response, receipt, inquiry evidence |
| Tax mismatch | Internal VAT differs from provider settlement base | S3/S4 | Hold settlement confirmation | Finance/accounting owner | Tax basis, receipt data, settlement file |
| Discount mismatch | Coupon/discount differs from order ledger | S3 | Hold order/payment finalization | Order + promotion owner | Promotion ledger, coupon ledger, response payload |
| Currency mismatch | KRW request but response says CNY/USD | S4 | Block; cross-border review | Finance + provider owner | FX data, provider trace, settlement currency |
| Store id mismatch | Response belongs to another store | S4 | Quarantine; security incident review | Security + payment integrity | Store registry, terminal registry, raw payload |
| Terminal id mismatch | Unknown or different terminal id | S4 | Quarantine; device/provider inquiry | Store ops + security | Terminal registry, device log, provider response |
| Duplicate approval | Same order has multiple approvals | S4 | Confirm one only after review; cancel/reverse duplicates | Payment integrity owner | Approval numbers, timestamps, receipts |
| Duplicate cancel/refund | Same cancel event repeated | S3/S4 | Apply idempotency; hold if amount or target differs | Payment integrity owner | Idempotency key, prior event hash |
| Late event conflict | Older event arrives after final state | S3 | Quarantine; do not roll back state automatically | Integration owner | State history, event timestamp, received_at |
| Out-of-order webhook | Refund arrives before approval webhook | S2/S3 | Park until dependency resolved | Integration owner | Event sequence, dependency graph |
| Signature mismatch | Webhook HMAC invalid | S4 | Reject/quarantine; security escalation | Security owner | Signature input, header, raw payload hash |
| Timestamp outside window | Event older/newer than allowed clock window | S3/S4 | Quarantine; replay review | Security + integration | Timestamp, received_at, provider clock note |
| Replay detected | Same event id/payload hash repeated suspiciously | S3/S4 | Idempotent ignore or security quarantine | Security owner | Replay key, prior processing record |
| Receipt mismatch | Receipt amount differs from canonical payment | S4 | Block confirmation or settlement match | Payment integrity + finance | Receipt/slip, approval, settlement file |
| Settlement file mismatch | Provider settlement differs from internal ledger | S4 | Create reconciliation exception | Finance owner | Settlement file, internal ledger, fee model |
| Fee mismatch | Fee/tax/VAT differs from expected contract | S3/S4 | Hold settlement closeout | Finance + contract owner | Contract fee table, provider statement |
| Customer identity mismatch | Membership/customer id differs | S3/S4 | Block loyalty/point application | Membership owner | Customer ledger, token mapping, consent record |
| Coupon/voucher mismatch | Voucher already used externally | S3 | Hold benefit application | Promotion owner | Coupon ledger, external response, event log |
| Delivery order id mismatch | Delivery app id does not match internal order | S3 | Hold fulfillment and operator review | Store ops + channel owner | External order payload, internal order record |
| KDS ticket mismatch | Kitchen ticket differs from paid order | S3 | Hold kitchen state correction | Store ops + KDS owner | Order ledger, KDS event, ticket log |
| Accounting export mismatch | Accounting line differs from financial ledger | S4 | Block accounting close | Finance/accounting owner | Journal entry, ledger entry, export hash |

## 7. Allowed Actions By Severity

| Severity | Allowed Actions | Prohibited Actions |
|---|---|---|
| S0 | Normalize, accept, log | Silent discard of raw value |
| S1 | Normalize with mapping version, accept after validation | Updating registry without review |
| S2 | Quarantine, request review, apply approved rule | Direct financial state change |
| S3 | Manual review, inquiry, provider escalation, hold state | Auto-confirm, auto-refund, auto-settle |
| S4 | Immediate hold, incident/escalation, reconciliation exception, security/finance review | Any silent correction or direct ledger mutation |

## 8. Escalation Map

| Condition | First Owner | Second Owner | Final Authority |
|---|---|---|---|
| Field mapping uncertainty | Integration owner | Architecture owner | External Integration Governance |
| Payment amount/approval/cancel conflict | Payment integrity owner | Finance owner | Payment Integrity Governance |
| Settlement/deposit/fee conflict | Finance owner | Accounting owner | Financial Closeout Authority |
| Signature/replay/tamper suspicion | Security owner | Integration owner | Security Governance |
| Store/terminal/provider identity conflict | Store operations owner | Security owner | Incident Commander |
| Customer claim exposure | Store manager | CS/payment support | Customer Claim Review Authority |
| Provider contract ambiguity | Provider owner | Legal/compliance owner | Contract Governance |

## 9. Evidence Packet Requirements

Every S2/S3/S4 mismatch must produce an evidence packet with at least:

- Raw request payload
- Raw response payload
- Canonical envelope
- Payload hash
- Mapping registry version
- Provider id and provider trace id
- Internal request id / payment intent id / order id
- Received timestamp
- Processing timestamp
- Validation result
- Correction or quarantine decision
- Reviewer id, if manually reviewed
- Escalation ticket id, if escalated
- Final state transition, if released

## 10. Review And Release Rules

A mismatch may be released only when:

1. The mismatch type is classified.
2. Severity is assigned.
3. Required evidence is attached.
4. Canonical mapping or correction rule is approved.
5. No S4 conflict remains unresolved.
6. State transition is allowed by the current state machine.
7. Audit log is complete.

## 11. Closeout Criteria

This matrix is complete when:

- All known external response mismatch types are registered.
- Severity and default action are assigned to each mismatch type.
- Escalation owners are defined.
- Auto-correction boundaries are explicit.
- Manual review evidence requirements are defined.
- The next runbook can execute mismatch handling without inventing new rules.
