# 070470_Audit_External_Response_Correction_Evidence_Manager_Approval_And_Replay_Log.md

## Purpose

This audit document defines the evidence, approval, replay, and tamper-check requirements for any correction or normalization applied to external integration responses.

External responses from POS, VAN, PG, payment providers, order apps, delivery apps, membership providers, kiosk vendors, KDS vendors, accounting systems, and tax systems must not be silently corrected. Every correction must be traceable from the raw inbound payload to the canonical internal state update.

## Scope

This document applies to:

- External RPC responses
- External API responses
- Webhook callbacks
- Payment approval responses
- Payment cancel/refund/reversal responses
- Inquiry responses
- Settlement file rows
- Delivery/order channel events
- Membership/coupon/point events
- Vendor device status events
- Accounting/tax integration responses

## Parent And Related Documents

- Parent: `70400_Index_External_Response_Validation_Correction_And_Canonical_Mapping.md`
- Previous: `70460_Runbook_External_Response_Mismatch_Review_Correction_And_Escalation_Action.md`
- Next: `70480_Register_External_Response_Correction_Exception_Gap_And_Open_Issue.md`
- Related: `70280_Audit_External_RPC_API_Webhook_Event_Raw_Log_Replay_Evidence_And_Tamper_Check.md`
- Related: `70370_Audit_External_Payment_Inquiry_Recovery_Evidence_And_Manager_Decision_Log.md`
- Related: `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md`

## Audit Principle

External response correction is allowed only as a controlled interpretation layer. It must never erase, overwrite, or hide the original external payload.

The system must preserve:

1. The original raw payload
2. The parsed provider-specific fields
3. The canonical mapped values
4. The correction decision
5. The manager or system approval basis
6. The replay or reprocessing action
7. The final state transition result
8. The tamper-check hash chain

## Correction Evidence Record

Every correction event must create a correction evidence record.

Required fields:

| Field | Requirement |
|---|---|
| correction_evidence_id | Unique correction evidence identifier |
| external_event_id | Source external event identifier |
| provider_id | External provider identifier |
| integration_type | POS, VAN, PG, delivery app, membership, tax, etc. |
| raw_payload_hash | Hash of original raw payload |
| raw_payload_location | Immutable storage pointer |
| original_field_name | Provider field before correction |
| original_field_value | Provider value before correction |
| canonical_field_name | Internal canonical field |
| corrected_value | Corrected or normalized value |
| correction_type | normalization, mapping, enrichment, quarantine_release, replay_result |
| correction_reason_code | Standard reason code |
| severity | low, medium, high, critical |
| auto_or_manual | auto / manual |
| approver_id | Required for manual correction |
| approval_timestamp | Required for manual correction |
| replay_required | yes / no |
| replay_run_id | Replay identifier if applicable |
| final_state | Resulting canonical state |
| evidence_packet_id | Dispute/audit packet pointer |

## Correction Reason Codes

Allowed reason code families:

| Reason Code Family | Description |
|---|---|
| FORMAT_NORMALIZATION | Safe format conversion without business meaning change |
| PROVIDER_CODE_MAPPING | Provider code mapped to approved canonical code |
| FIELD_ALIAS_MAPPING | Provider field alias mapped to standard field |
| TIMEZONE_NORMALIZATION | Timestamp converted to canonical timezone |
| CURRENCY_FORMAT_NORMALIZATION | Currency or decimal format normalized |
| RECEIPT_METADATA_ENRICHMENT | Receipt metadata added from verified source |
| TRACE_ID_ENRICHMENT | Trace metadata added from approved source |
| INQUIRY_CONFIRMED_CORRECTION | Correction based on successful inquiry result |
| SETTLEMENT_CONFIRMED_CORRECTION | Correction based on settlement file or deposit evidence |
| MANAGER_APPROVED_EXCEPTION | Manual correction approved by authorized manager |
| VENDOR_CONFIRMED_EXCEPTION | Vendor-confirmed correction with evidence |

## Prohibited Silent Correction

The following must never be silently corrected:

- Approved amount mismatch
- Tax amount mismatch affecting settlement
- Discount or coupon amount mismatch affecting customer charge
- Store ID mismatch
- Terminal ID mismatch
- Merchant ID mismatch
- Approval number conflict
- Cancel approval conflict
- Duplicate payment approval
- Duplicate refund approval
- Provider trace ID collision
- Settlement deposit mismatch
- Customer-facing payment status conflict

These cases must be routed to manual review, quarantine, recovery, or reconciliation exception handling.

## Manager Approval Requirement

Manual correction requires an authorized manager approval when the correction affects:

- Payment status
- Order status
- Refund or cancel status
- Customer charge amount
- Store settlement amount
- Membership point balance
- Coupon/voucher redemption status
- Accounting ledger entry
- Tax reporting data

The approval record must include:

- Approver identity
- Role and authority scope
- Before/after values
- Supporting evidence
- Customer impact statement
- Settlement impact statement
- Reason for not using automatic correction

## Replay Log Requirement

If correction requires replay, the replay action must be logged separately from the correction decision.

Replay log fields:

| Field | Requirement |
|---|---|
| replay_run_id | Unique replay run identifier |
| source_event_id | Original event being replayed |
| correction_evidence_id | Linked correction evidence |
| replay_actor | system worker or operator |
| replay_mode | dry_run, controlled_replay, forced_replay |
| previous_state | State before replay |
| target_state | Intended state after replay |
| actual_state | Result after replay |
| idempotency_key | Replay idempotency key |
| replay_started_at | Start timestamp |
| replay_completed_at | Completion timestamp |
| replay_result | success, failed, partial, quarantined |
| failure_reason | Required if not success |

## Tamper Check

Correction evidence must be tamper-evident.

Minimum requirements:

- Raw payload hash must be generated at ingestion time.
- Correction evidence hash must include before/after values.
- Manager approval hash must include approver identity and timestamp.
- Replay log hash must include replay result and state transition.
- Evidence records must be append-only.
- Corrections must never mutate prior evidence records.

## Audit Review Cadence

| Review Type | Cadence | Owner |
|---|---|---|
| Critical correction review | Same business day | Payment integrity owner |
| Manual correction review | Daily | Operations manager |
| Replay review | Daily | Integration owner |
| Settlement-impacting correction review | Daily close / settlement close | Finance owner |
| Provider mapping drift review | Weekly | External integration owner |
| Audit packet completeness review | Monthly | Governance owner |

## Exit Criteria

A correction event is closed only when:

1. Raw payload is preserved.
2. Before/after correction values are recorded.
3. Correction reason code is assigned.
4. Required approval is captured.
5. Replay result is logged when applicable.
6. Final canonical state is validated.
7. Settlement or customer impact is reviewed if applicable.
8. Evidence packet is available for dispute, audit, and vendor escalation.

## Handoff

This document hands off unresolved correction exceptions and open issues to:

`70480_Register_External_Response_Correction_Exception_Gap_And_Open_Issue.md`
