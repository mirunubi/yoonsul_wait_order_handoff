# 014136_Policy_POS_Gateway_Customer_Status_Message_Receipt_Proof_Notification_And_Dispute_Communication

## 1. Purpose

This document defines the customer status message, receipt proof, notification, and dispute communication policy for the POS Gateway.

The POS Gateway does not only move data between ordering channels, POS, payment providers, and KDS.  
It also determines what the customer is told when an order, payment, cancellation, refund, receipt, table session, or pickup state is uncertain.

Wrong customer messaging can create more damage than the original technical error.

Examples:

- telling a customer “payment failed” when payment actually succeeded;
- telling a customer “order completed” when POS write failed;
- telling a customer “refund completed” when refund result is unknown;
- asking a customer to pay again before duplicate charge risk is cleared;
- showing a receipt without provider proof;
- hiding cancellation/refund delay;
- failing to preserve customer dispute evidence.

This policy exists to ensure that:

- customer-facing status messages reflect evidence, not assumptions;
- receipt and proof-of-transaction behavior is controlled;
- notification wording is safe during uncertainty;
- dispute communication preserves customer trust and legal defensibility;
- customer support, store staff, POS Gateway, payment, and receipt evidence remain aligned;
- kiosk, QR/table ordering, mobile web, takeout, delivery, and staff-assisted flows use consistent communication boundaries.

---

## 2. Scope

This policy applies to all customer-facing and staff-assisted communication produced or influenced by the POS Gateway, including:

- order status messages;
- payment status messages;
- POS write status messages;
- KDS/preparation status messages;
- cancellation status messages;
- refund status messages;
- receipt/proof messages;
- table/session status messages;
- waiting/preorder handoff messages;
- pickup/takeout messages;
- sold-out/unavailable item messages;
- price mismatch messages;
- duplicate charge risk messages;
- customer dispute intake;
- customer support case notes;
- staff scripts;
- kiosk/QR/table ordering UI messages;
- mobile web/app notifications;
- SMS/Kakao/email/push notifications where applicable.

This document governs communication integrity across customer, store, support, and evidence boundaries.

---

## 3. Core Principle

Customer communication must never claim more certainty than the system can prove.

The POS Gateway must distinguish:

```text
known_success
known_failure
known_pending
known_blocked
known_cancelled
known_refunded
known_requires_staff_confirmation
unknown_but_under_review
disputed
```

If the gateway cannot prove a state, it must communicate controlled uncertainty and route the case to staff, support, reconciliation, or incident handling.

False certainty is prohibited.

---

## 4. Customer Status Authority Model

The system must define what source authorizes each customer-facing status.

Possible authority sources:

| Status Area | Possible Authority |
|---|---|
| Order accepted | Gateway order state, POS confirmation, staff confirmation |
| POS order created | POS response or verified POS lookup |
| Payment completed | Payment provider approval or verified POS/payment evidence |
| KDS preparation started | KDS ticket confirmation or staff confirmation |
| Order ready | KDS/store staff confirmation |
| Order served/picked up | Staff confirmation, pickup confirmation, POS close |
| Cancellation completed | POS/payment cancellation evidence |
| Refund completed | Payment provider refund evidence |
| Receipt available | POS/payment provider receipt evidence |
| Dispute resolved | Support/reconciliation/customer protection decision |

The gateway must not use UI optimistic state as final truth.

---

## 5. Status Confidence Model

Customer-facing statuses must carry confidence.

Recommended confidence levels:

| Confidence | Meaning |
|---|---|
| `confirmed` | Evidence from authoritative source exists |
| `pending` | Process started but final evidence not available |
| `requires_staff_confirmation` | Human review needed |
| `requires_provider_verification` | Provider/POS/payment lookup needed |
| `requires_reconciliation` | Cross-system comparison needed |
| `blocked` | Process cannot proceed safely |
| `failed_confirmed` | Failure is confirmed by evidence |
| `unknown` | System cannot determine state |
| `disputed` | Customer or store disputes current state |

Customer-facing wording must be derived from confidence level.

---

## 6. Order Status Message Policy

Order status messages must reflect actual order state.

Recommended customer-facing statuses:

| Internal State | Customer Message Intent |
|---|---|
| `cart_active` | Customer is selecting items |
| `order_submitted` | Order request received |
| `order_pending_confirmation` | Staff/system confirmation in progress |
| `pos_write_pending` | Order is being sent to store system |
| `pos_write_confirmed` | Store has received the order |
| `kds_confirmed` | Kitchen has received the order |
| `preparing` | Order is being prepared |
| `ready` | Order is ready for pickup/serving |
| `completed` | Order is completed |
| `blocked` | Order cannot proceed |
| `manual_review_required` | Staff is checking the order |
| `failed_confirmed` | Order could not be completed |

The gateway must not show “order completed” unless the required evidence for the channel exists.

---

## 7. Payment Status Message Policy

Payment status messages must be conservative.

Recommended customer-facing payment statuses:

| Internal State | Safe Message Intent |
|---|---|
| `payment_not_started` | Payment has not started |
| `payment_pending` | Payment is processing |
| `payment_authorized` | Payment approval is being confirmed |
| `payment_confirmed` | Payment is confirmed |
| `payment_failed_confirmed` | Payment failed |
| `payment_unknown` | Payment state is being checked |
| `duplicate_payment_risk` | Payment is being checked to avoid duplicate charge |
| `payment_manual_review` | Staff/support is verifying payment |

The system must not say “payment failed” when payment state is unknown.  
The system must not ask for repayment while duplicate payment risk exists.

---

## 8. POS Write Status Message Policy

POS write status is usually not customer-friendly, but it affects customer communication.

Internal POS write states must map to safe customer messages.

Examples:

| POS Write State | Customer Message |
|---|---|
| `not_sent` | 주문 확인 중입니다. |
| `send_pending` | 주문을 매장 시스템에 전달 중입니다. |
| `confirmed` | 주문이 접수되었습니다. |
| `unknown_result` | 주문 상태를 확인 중입니다. |
| `failed_retryable` | 직원이 주문 상태를 확인하고 있습니다. |
| `failed_final` | 주문을 완료할 수 없어 직원이 안내드리겠습니다. |
| `manual_fallback_required` | 직원이 직접 주문을 확인하고 있습니다. |

Provider error codes must not be exposed directly to customers.

---

## 9. KDS / Preparation Status Message Policy

Kitchen preparation messages must be based on KDS or staff evidence.

Allowed statuses:

- 주문이 주방에 전달되었습니다.
- 조리 중입니다.
- 준비가 완료되었습니다.
- 직원이 준비 상태를 확인 중입니다.
- 주문 준비 상태 확인이 필요합니다.

Prohibited behavior:

- showing “preparing” when KDS ticket creation failed;
- showing “ready” without KDS/staff confirmation;
- showing duplicate preparation messages after retry;
- hiding KDS failure while customer waits.

KDS status must be channel-aware.

---

## 10. Cancellation Status Message Policy

Cancellation status must be evidence-based.

Recommended statuses:

| Internal State | Customer Message Intent |
|---|---|
| `cancel_requested` | Cancellation request received |
| `cancel_checking` | Cancellation availability is being checked |
| `cancel_pending_provider` | Cancellation is being processed |
| `cancel_confirmed` | Cancellation completed |
| `cancel_rejected` | Cancellation cannot be completed |
| `cancel_unknown` | Cancellation state is being verified |
| `cancel_manual_review` | Staff/support is reviewing cancellation |

The gateway must not say cancellation is complete unless POS/payment/provider evidence supports it.

---

## 11. Refund Status Message Policy

Refund communication must be strict.

Recommended statuses:

| Internal State | Customer Message Intent |
|---|---|
| `refund_not_started` | Refund has not started |
| `refund_requested` | Refund request received |
| `refund_reviewing` | Refund eligibility is being checked |
| `refund_pending_provider` | Refund is being processed |
| `refund_confirmed` | Refund is confirmed |
| `refund_rejected` | Refund cannot be completed |
| `refund_unknown` | Refund state is being verified |
| `refund_manual_review` | Staff/support is reviewing refund |

The system must not display “refund completed” without provider or payment evidence.

Refund delay messaging must not blame the customer or store staff where system/provider verification is pending.

---

## 12. Receipt and Proof Policy

Receipt and proof-of-transaction must be clearly distinguished.

Receipt types may include:

| Proof Type | Meaning |
|---|---|
| `pos_receipt` | Official POS receipt or bill number |
| `payment_receipt` | Payment provider approval/receipt evidence |
| `gateway_order_confirmation` | Gateway order request confirmation |
| `cancellation_receipt` | Cancellation evidence |
| `refund_receipt` | Refund evidence |
| `external_platform_receipt` | Delivery/platform-owned receipt |
| `manual_staff_confirmation` | Staff-provided evidence note |
| `reconciliation_proof` | Later evidence from reconciliation |

A gateway order confirmation must not be presented as a payment receipt unless payment evidence exists.

---

## 13. Receipt Identity Requirements

Customer-visible receipt proof must include the appropriate identifiers where available.

Required identifiers may include:

```text
gateway_order_id
pos_order_id
pos_receipt_number
bill_number
payment_approval_number
payment_provider_reference
cancellation_reference
refund_reference
external_order_id
store_id
business_date
transaction_time
```

Identifiers must be shown in a customer-safe format.

Sensitive internal IDs may be hidden or shortened, but must remain traceable internally.

---

## 14. Receipt Availability Message Policy

Receipt availability messages must reflect actual proof state.

Allowed messages:

```text
영수증 정보를 확인 중입니다.
결제 승인 내역을 확인했습니다.
매장 영수증 번호를 확인했습니다.
환불 처리 내역을 확인했습니다.
직원이 영수증 정보를 확인 후 안내드리겠습니다.
```

Prohibited messages:

```text
영수증 발급 완료
환불 영수증 발급 완료
결제 승인 완료
```

when those states are not supported by evidence.

---

## 15. Duplicate Payment Risk Communication

Duplicate payment risk must be communicated carefully.

Allowed messages:

```text
중복 결제가 발생하지 않도록 결제 상태를 확인하고 있습니다.
결제 승인 여부를 확인한 뒤 안내드리겠습니다.
추가 결제 전에 직원이 먼저 확인하겠습니다.
```

Prohibited messages:

```text
다시 결제해주세요.
결제 실패입니다.
앱을 닫고 다시 주문해주세요.
```

when payment state is unknown.

Store staff and support must be trained not to request repayment before verification.

---

## 16. Sold-Out / Unavailable Item Communication

Availability messages must be clear and timely.

Allowed messages:

```text
선택하신 메뉴가 방금 품절되었습니다.
현재 해당 옵션은 선택할 수 없습니다.
해당 메뉴는 지금 시간대에 주문할 수 없습니다.
직원이 주문 가능 여부를 확인 중입니다.
```

If the customer already paid before sold-out conflict is detected, the message must include staff/support follow-up and avoid implying customer fault.

---

## 17. Price Change / Price Mismatch Communication

Price change messages must be transparent.

Allowed messages:

```text
메뉴 가격이 변경되어 주문 금액을 다시 확인해야 합니다.
할인/쿠폰 적용 결과가 변경되어 결제 전 금액 확인이 필요합니다.
매장 시스템 금액과 주문 금액을 확인 중입니다.
```

Prohibited behavior:

- silently charging a different amount;
- hiding price mismatch;
- applying new price to already-paid historical transaction without explanation;
- showing discount applied when POS/payment total does not reflect it.

---

## 18. Table / Session Identity Communication

When table/session identity is uncertain, customer messaging must avoid false routing.

Allowed messages:

```text
테이블 정보를 확인 중입니다.
직원이 테이블을 확인한 뒤 주문을 접수하겠습니다.
현재 테이블 주문을 진행할 수 없어 직원 호출이 필요합니다.
```

Prohibited behavior:

- accepting order for unverified QR/NFC object;
- showing table number without validating token;
- telling customer order is sent to table when table/session is uncertain.

---

## 19. Waiting / Preorder Handoff Communication

Waiting/preorder messages must clarify handoff state.

Allowed messages:

```text
대기 주문이 저장되었습니다.
입장 후 테이블이 배정되면 주문을 이어서 진행합니다.
테이블 배정 후 직원 확인이 필요합니다.
주문을 매장에 전달하기 전 최종 확인 중입니다.
```

The system must not tell the customer that dine-in order is completed before table/session handoff is valid.

---

## 20. Delivery / External Platform Communication

External platform communication must respect ownership boundary.

If payment, refund, cancellation, or receipt is owned by a delivery platform, the gateway must not claim direct authority.

Allowed messages:

```text
해당 주문은 외부 주문 플랫폼 기준으로 확인이 필요합니다.
환불/취소는 주문하신 플랫폼의 처리 상태를 함께 확인해야 합니다.
매장 접수 상태를 확인 중입니다.
```

External order ID must be preserved for customer support and dispute investigation.

---

## 21. Notification Channel Policy

Notification channels may include:

- in-app message;
- web screen message;
- kiosk screen;
- staff tablet;
- SMS;
- Kakao/알림톡;
- email;
- push notification;
- receipt print;
- customer support note.

Each channel must define:

```text
notification_channel
allowed_message_types
language_support
retry_policy
delivery_confirmation
customer_privacy_boundary
status
```

Sensitive payment/refund information must not be sent through insecure or inappropriate channels.

---

## 22. Notification Timing Policy

Notification timing must be controlled.

Events that may notify customer:

- order received;
- payment confirmed;
- order accepted by store;
- preparation started;
- ready for pickup;
- cancellation received;
- cancellation confirmed;
- refund requested;
- refund confirmed;
- staff review required;
- dispute update;
- sold-out conflict;
- pickup reminder.

Notifications must not be sent before the underlying state is sufficiently confirmed.

Duplicate notifications must be suppressed or clearly updated.

---

## 23. Multilingual Message Policy

Customer messages should support multilingual output where ordering channel requires it.

Multilingual messages must preserve legal and operational meaning.

Translation must not soften or strengthen uncertainty incorrectly.

For example:

- “확인 중입니다” must not become “completed” in another language;
- “refund requested” must not become “refund completed”;
- “payment being checked” must not become “payment failed.”

Critical customer status messages should be template-based, not ad-hoc translated during incident.

---

## 24. Message Template Versioning

Customer and staff message templates must be versioned.

Required fields:

```text
message_template_id
message_type
language
template_version
allowed_statuses
risk_level
approved_by
effective_from
effective_until
status
```

Templates must be tied to internal state and confidence level.

Changing a message template for payment, refund, cancellation, or dispute requires review.

---

## 25. Staff Script Policy

Staff scripts must be aligned with system status.

Staff scripts must cover:

- payment unknown;
- duplicate charge risk;
- POS order missing;
- order pending staff confirmation;
- sold-out after payment;
- refund review;
- cancellation review;
- table/session mismatch;
- external delivery platform dispute.

Staff scripts must not instruct staff to say unsupported claims.

---

## 26. Customer Dispute Intake

Customer dispute intake must collect enough evidence.

Required intake fields:

```text
dispute_id
customer_reference
store_id
order_channel
order_id
payment_reference
approval_number
receipt_number
external_order_id
dispute_type
customer_claim
customer_evidence_reference
created_at
status
```

Dispute types may include:

- duplicate payment;
- charged but no order;
- order missing;
- wrong table/order;
- refund not received;
- cancellation not reflected;
- receipt missing;
- wrong amount charged;
- coupon/discount missing;
- delivery platform mismatch.

Customer dispute intake must not require the customer to know internal gateway IDs.

---

## 27. Dispute Communication Policy

During dispute investigation, communication must be status-based.

Allowed communication states:

| State | Customer Communication |
|---|---|
| `received` | 문의가 접수되었습니다. |
| `evidence_checking` | 결제/주문 정보를 확인 중입니다. |
| `provider_checking` | 결제사 또는 주문 시스템 확인이 필요합니다. |
| `store_checking` | 매장 처리 상태를 확인 중입니다. |
| `resolved_customer_action` | 고객님께 필요한 조치를 안내합니다. |
| `resolved_store_action` | 매장 처리 결과를 안내합니다. |
| `resolved_provider_action` | 제공사 처리 결과를 안내합니다. |
| `unresolved_followup` | 추가 확인이 필요합니다. |

The system must not close communication until next action or resolution is clear.

---

## 28. Customer Protection Escalation

Certain communication states must trigger customer protection escalation.

Escalation triggers:

- duplicate charge suspected;
- paid but no order evidence;
- refund promised but not confirmed;
- cancellation status unknown after customer request;
- receipt/proof unavailable after payment;
- wrong amount charged;
- order sent to wrong table/customer;
- repeated customer contact for same transaction;
- vulnerable or high-stress customer interaction;
- legal/regulatory complaint language.

Customer protection escalation must link to incident or dispute case.

---

## 29. Communication Evidence Retention

Customer communication must be retained where it affects transaction, refund, cancellation, or dispute.

Evidence to retain:

- message template ID;
- rendered message;
- language;
- channel;
- recipient reference;
- delivery timestamp;
- delivery status;
- related order/payment/refund/cancel ID;
- staff script used where applicable;
- support response record;
- customer reply or evidence where available.

Communication evidence must support dispute investigation.

---

## 30. Privacy and Data Minimization

Customer communication must minimize sensitive data.

Messages must not expose:

- full card number;
- raw payment token;
- internal credentials;
- unrelated customer data;
- internal provider error payload;
- other table/customer information;
- excessive internal IDs.

Customer-visible references should be safe, short, and sufficient for support.

---

## 31. Monitoring Requirements

Customer communication health must be monitored.

Required metrics:

- payment unknown message count;
- duplicate payment risk message count;
- refund pending message count;
- refund confirmed message count;
- cancellation unknown message count;
- receipt unavailable message count;
- dispute intake count;
- dispute resolution time;
- customer recontact count;
- notification delivery failure count;
- message template error count;
- multilingual fallback count;
- staff script override count.

Repeated uncertainty messages may indicate deeper POS Gateway instability.

---

## 32. Dashboard Requirements

Operations dashboard must show:

- active customer-impact messages;
- open customer disputes;
- duplicate payment risk cases;
- refund pending cases;
- receipt proof missing cases;
- notification delivery failures;
- message template version;
- staff script version;
- customer protection escalations;
- unresolved communication cases;
- channel-specific communication issues.

Dashboard must not show customer communication as resolved when transaction evidence is still unresolved.

---

## 33. Incident Requirements

Communication incidents may include:

- wrong payment status shown;
- false refund completion message;
- false order completion message;
- duplicate payment request message;
- receipt proof misrepresented;
- notification sent to wrong customer/session;
- external delivery ownership miscommunicated;
- translated message changed legal meaning;
- staff script contradicted system state.

Communication incidents must classify:

- customer trust impact;
- payment impact;
- refund/cancellation impact;
- dispute/legal impact;
- operational impact;
- correction requirement.

---

## 34. Correction and Apology Policy

When wrong communication is sent, correction must be controlled.

Correction message must:

- avoid blaming customer;
- clarify the current verified state;
- avoid unsupported final claims;
- provide next action;
- link to support or staff confirmation where needed;
- preserve evidence of original wrong message.

An apology or goodwill action may be handled under customer protection or business policy, but must not overwrite transaction evidence.

---

## 35. Kiosk / QR / Table Ordering Reuse

Kiosk, QR, table ordering, and waiting/preorder flows must reuse approved message templates.

They must not create independent wording for:

- payment unknown;
- duplicate payment risk;
- refund pending;
- cancellation pending;
- order confirmation;
- table/session mismatch;
- sold-out after payment;
- price mismatch;
- receipt unavailable.

If channel-specific wording is required, it must remain tied to the same internal status and confidence model.

---

## 36. Prohibited Practices

The following practices are prohibited:

- telling customer to pay again while payment state is unknown;
- showing refund complete without refund evidence;
- showing order complete without POS/KDS/staff evidence required by channel;
- presenting gateway order confirmation as payment receipt;
- exposing raw provider errors to customer;
- hiding customer-impacting uncertainty behind generic success;
- translating uncertain state as final success or failure;
- closing dispute communication without next action;
- deleting communication evidence after dispute;
- allowing kiosk/QR channel to use unapproved payment/refund wording.

---

## 37. Minimum Acceptance Criteria

Customer status message and dispute communication is acceptable only when:

- customer status authority model exists;
- status confidence model exists;
- order/payment/POS/KDS/cancel/refund message policies exist;
- receipt/proof distinction exists;
- duplicate payment risk communication exists;
- sold-out and price mismatch communication exists;
- table/session and waiting handoff communication exists;
- external platform ownership communication exists;
- notification channel and timing policies exist;
- multilingual template versioning exists;
- staff scripts exist;
- customer dispute intake exists;
- communication evidence retention exists;
- privacy/data minimization exists;
- monitoring, dashboard, incident, and correction controls exist.

---

## 38. Implementation Notes

Recommended implementation artifacts:

```text
pos_gateway_customer_status_templates
pos_gateway_message_template_versions
pos_gateway_status_confidence_rules
pos_gateway_notification_channels
pos_gateway_notification_events
pos_gateway_customer_disputes
pos_gateway_customer_communication_records
pos_gateway_staff_scripts
pos_gateway_receipt_proof_records
pos_gateway_customer_protection_escalations
pos_gateway_communication_incidents
pos_gateway_message_corrections
```

Recommended services:

```text
CustomerStatusMessageService
StatusConfidenceService
ReceiptProofService
NotificationChannelService
NotificationTimingService
MessageTemplateVersionService
MultilingualMessageService
StaffScriptService
CustomerDisputeIntakeService
DisputeCommunicationService
CustomerProtectionEscalationService
CommunicationEvidenceService
CommunicationPrivacyGuard
CommunicationMonitoringService
MessageCorrectionService
```

Recommended event types:

```text
pos_gateway.communication.status_message_rendered
pos_gateway.communication.notification_sent
pos_gateway.communication.notification_failed
pos_gateway.communication.receipt_proof_created
pos_gateway.communication.payment_unknown_message_shown
pos_gateway.communication.duplicate_payment_risk_message_shown
pos_gateway.communication.refund_pending_message_shown
pos_gateway.communication.dispute_opened
pos_gateway.communication.dispute_updated
pos_gateway.communication.customer_protection_escalated
pos_gateway.communication.message_template_changed
pos_gateway.communication.message_correction_sent
pos_gateway.communication.incident_detected
```

---

## 39. Relationship To Adjacent Documents

This document is related to:

- 06100 POS Gateway staff operation, manual fallback, override authority, and manager approval policy;
- 06090 POS Gateway table, session, seat, object, QR, NFC, device identity, and handoff integrity policy;
- 06080 POS Gateway order channel separation, dine-in, takeout, delivery, kiosk, table QR, and staff order routing policy;
- 06070 POS Gateway inventory, availability, sold-out, stock sync, and order blocking integrity policy;
- 06060 POS Gateway price, promotion, discount, coupon, tax, service charge, and total calculation integrity policy;
- POS Gateway cancellation, refund, exception, manual override, and customer protection policy;
- POS Gateway incident response, dispute investigation, provider escalation, and postmortem policy;
- POS Gateway audit event, evidence retention, and forensic traceability policy.

Where conflict exists, this document governs customer-facing status, receipt proof, notification, dispute communication, and staff/customer wording integrity.

---

## 40. Summary

Customer communication is part of transaction safety.

The POS Gateway must not create false certainty.

The correct standard is:

- say only what evidence proves;
- communicate uncertainty safely;
- never ask for repayment before duplicate charge risk is cleared;
- never promise refund or cancellation completion without proof;
- distinguish gateway confirmation from receipt/payment proof;
- retain communication evidence;
- align staff scripts, kiosk messages, QR/table messages, and support messages.

A technical failure can be repaired.  
A false message that causes the customer to lose trust is much harder to repair.