# 070320_Policy_External_Payment_Inquiry_Channel_Requirement_And_Response_Authority.md

## Document Metadata

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff |
| Document No. | 70320 |
| Document Type | Policy |
| Domain | External Integration Control Plane / Payment Inquiry / Unknown State Recovery |
| Parent Index | 70300_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Governance.md |
| Previous | 70310_Policy_External_Payment_Unknown_State_Detection_And_Classification.md |
| Next | 70330_Runbook_External_Payment_Inquiry_Request_Retry_Escalation_And_Manager_Action.md |
| Status | Draft |

---

## 1. Purpose

This policy defines the mandatory inquiry channel requirements and response authority model for external payment integrations.

The system shall not resolve an external payment `UNKNOWN`, `AMBIGUOUS`, `INQUIRY_PENDING`, `REVERSAL_PENDING`, or `CANCEL_PENDING` state solely based on UI state, client timeout, POS screen message, store staff statement, or partial gateway response.

A payment state may only be finalized after the External Integration Control Plane receives, stores, validates, and authoritatively classifies an eligible inquiry response from the relevant external provider or settlement source.

---

## 2. Core Principle

External payment request failure does not equal payment failure.

External payment timeout does not equal payment cancellation.

External payment success response does not equal internal order confirmation until the response is matched, validated, and accepted by the internal state authority.

Therefore, every external payment provider that can create money movement shall provide a usable inquiry path or an equivalent settlement evidence path.

---

## 3. Scope

This policy applies to all external payment-related providers and channels, including but not limited to:

- POS provider
- VAN provider
- PG provider
- card acquirer
- card issuer response path
- simple payment provider
- Alipay / WeChat Pay / cross-border payment provider
- kiosk payment agent
- membership app payment provider
- external order app payment provider
- settlement file provider
- deposit file provider
- refund / reversal provider

---

## 4. Required Inquiry Channels

Each external payment integration shall be evaluated against the following inquiry capability requirements.

| Inquiry Type | Requirement | Purpose |
|---|---|---|
| Approval inquiry | Mandatory | Determine whether a payment authorization exists after timeout or response loss |
| Cancel inquiry | Mandatory | Determine whether cancellation or reversal actually succeeded |
| Last transaction inquiry | Required where supported | Recover from local device crash or response loss |
| Transaction ID inquiry | Mandatory | Query by provider transaction ID, payment key, VAN trace ID, or approval number |
| Merchant / terminal scoped inquiry | Mandatory for POS/VAN | Detect terminal-local approval not recorded in cloud ledger |
| Time-window inquiry | Required | Search unknown payment by amount, store, terminal, and time range |
| Settlement file inquiry | Mandatory for final reconciliation | Confirm provider-side final financial state |
| Receipt / slip inquiry | Required where supported | Preserve customer dispute and audit evidence |
| Refund / reversal inquiry | Mandatory where refund is supported | Confirm external refund, reversal, or net cancel outcome |

---

## 5. Provider Acceptance Rule

A provider shall not be classified as production-ready unless at least one of the following is true:

1. It provides synchronous transaction inquiry APIs.
2. It provides asynchronous transaction status callback plus retryable query API.
3. It provides settlement file exports sufficient to close unresolved states within a defined SLA.
4. It provides an official support escalation path with traceable response evidence for unresolved financial states.

If none of the above exists, the provider shall be marked as `INQUIRY_CAPABILITY_INSUFFICIENT` and may only be used under restricted pilot scope with explicit risk acceptance.

---

## 6. Response Authority Model

Inquiry responses are classified into authority tiers.

| Authority Tier | Source | Usage |
|---|---|---|
| Tier 1 | Direct provider transaction inquiry | May resolve payment state when matched and validated |
| Tier 2 | Official provider callback / webhook | May update state only after signature, replay, and order validation |
| Tier 3 | Settlement / deposit file | May finalize financial reconciliation and override unresolved operational state after audit review |
| Tier 4 | Provider support written evidence | May support manual resolution but shall not bypass ledger evidence requirements |
| Tier 5 | Store staff statement / screenshot | Supporting evidence only; never authoritative alone |

---

## 7. Inquiry Response Validation

An inquiry response shall not resolve an unknown payment state unless all required fields are validated.

Minimum validation fields:

- internal payment intent ID or mapped external transaction ID
- order ID or equivalent order reference
- provider name
- merchant ID
- store ID or mapped store code
- terminal ID where applicable
- amount
- currency
- approval number where applicable
- approval or cancellation timestamp
- provider transaction status
- provider trace ID
- raw response payload hash
- response received timestamp

If any required matching field is missing or contradictory, the state shall remain `INQUIRY_REVIEW_REQUIRED`.

---

## 8. Status Resolution Rules

| Inquiry Result | Internal Resolution |
|---|---|
| Approved and matched | `PAYMENT_CONFIRMED` after validation gate acceptance |
| Not found, within provider processing window | Remain `INQUIRY_PENDING` |
| Not found, after provider finality SLA | `PAYMENT_NOT_FOUND_FINAL` with audit record |
| Approved but order missing | `PAYMENT_CONFIRMED_ORDER_RECOVERY_REQUIRED` |
| Approved amount mismatch | `PAYMENT_MISMATCHED_MANUAL_REVIEW` |
| Cancelled and matched | `PAYMENT_CANCELLED_CONFIRMED` |
| Cancel unknown | `CANCEL_UNKNOWN_INQUIRY_PENDING` |
| Refund completed | `REFUND_CONFIRMED` |
| Provider response inconsistent | `PROVIDER_RESPONSE_CONFLICT_QUARANTINED` |

---

## 9. Prohibited Practices

The following practices are prohibited:

- Marking timeout as payment failure without inquiry.
- Marking cancellation as complete without cancel inquiry or settlement evidence.
- Retrying payment blindly when the previous payment is `UNKNOWN`.
- Creating a new payment intent for the same order before resolving the prior intent.
- Accepting POS screen text as final financial evidence.
- Allowing store operators to manually force `CONFIRMED` without evidence packet.
- Deleting unknown payment records after operational closure.
- Overwriting raw inquiry payloads after receipt.

---

## 10. Inquiry SLA Classes

| Class | Example | Expected Handling |
|---|---|---|
| Real-time inquiry | PG / API-based payment | Query immediately after timeout and retry by policy |
| Near-real-time inquiry | VAN / POS provider | Query after delay window to avoid false not-found |
| Batch inquiry | settlement file, deposit file | Hold unresolved state until batch arrival or SLA breach |
| Manual inquiry | provider support desk | Open evidence ticket and keep state in manual review |

---

## 11. Unknown State Release Conditions

An unknown state may be released only when one of the following conditions is satisfied:

1. A valid inquiry response confirms approval and matches the internal payment intent.
2. A valid inquiry response confirms no transaction exists after the provider finality window.
3. A valid cancel or reversal inquiry confirms the transaction was reversed.
4. Settlement/deposit evidence confirms final financial disposition.
5. Manual review approves resolution with evidence packet and manager authorization.

---

## 12. Evidence Requirements

Every inquiry attempt shall create an immutable inquiry evidence record.

Minimum evidence fields:

- inquiry request ID
- related payment intent ID
- inquiry channel
- provider
- request payload hash
- response payload hash
- raw request payload storage reference
- raw response payload storage reference
- request timestamp
- response timestamp
- response code
- interpreted canonical status
- validation result
- operator or system actor
- retry count
- resolution decision

---

## 13. Relationship To Adjacent Documents

This policy is linked to:

- `70300_Index_External_Payment_Inquiry_Unknown_State_And_Recovery_Governance.md`
- `70310_Policy_External_Payment_Unknown_State_Detection_And_Classification.md`
- `70330_Runbook_External_Payment_Inquiry_Request_Retry_Escalation_And_Manager_Action.md`
- `70150_Policy_External_Payment_Timeout_Unknown_State_Inquiry_And_Ambiguous_Result_Control.md`
- `70280_Audit_External_RPC_API_Webhook_Event_Raw_Log_Replay_Evidence_And_Tamper_Check.md`
- `75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md`

---

## 14. Implementation Notes

Implementation shall provide:

- inquiry request table
- inquiry response table
- provider inquiry capability registry
- unknown payment queue
- inquiry retry scheduler
- inquiry evidence packet builder
- manual review workflow
- finality SLA configuration per provider
- canonical status mapping registry

---

## 15. Closeout Criteria

This policy is complete when:

- all external payment providers have inquiry capability profiles;
- UNKNOWN state cannot be resolved without evidence;
- inquiry responses are stored as raw payload plus canonical interpretation;
- provider finality windows are configured;
- manager overrides require evidence packet attachment;
- unresolved states are visible in admin console and reconciliation reports.
