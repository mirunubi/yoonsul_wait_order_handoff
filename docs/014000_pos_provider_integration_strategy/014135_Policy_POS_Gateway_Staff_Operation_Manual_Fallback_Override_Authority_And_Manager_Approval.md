# 014135_Policy_POS_Gateway_Staff_Operation_Manual_Fallback_Override_Authority_And_Manager_Approval

## 1. Purpose

This document defines the staff operation, manual fallback, override authority, and manager approval policy for the POS Gateway.

The POS Gateway must not assume that all transaction problems can be solved automatically.

In real store operation, staff may need to intervene when:

- POS write result is uncertain;
- payment state is unclear;
- customer claims payment completed;
- order appears in gateway but not in POS;
- POS order exists but gateway did not receive confirmation;
- KDS ticket is missing or duplicated;
- table/session identity is wrong;
- menu mapping fails;
- item becomes sold out after payment;
- cancellation/refund requires human judgment;
- provider is unstable;
- manual POS entry is required;
- customer communication is needed.

This policy exists to ensure that:

- staff manual actions are controlled and auditable;
- override authority is role-based and scoped;
- manager approval is required for sensitive actions;
- manual fallback preserves transaction evidence;
- manual actions do not hide system failures;
- customer protection is maintained during uncertainty;
- store operations can continue safely when automation is degraded.

---

## 2. Scope

This policy applies to all staff and manager actions related to POS Gateway operation, including:

- manual order confirmation;
- manual POS entry;
- manual payment verification;
- manual receipt verification;
- manual cancellation;
- manual refund review;
- manual KDS ticket handling;
- manual table/session correction;
- manual sold-out handling;
- manual menu mapping exception;
- manual price adjustment;
- manual fallback activation;
- manual retry approval;
- manual incident escalation;
- manager override;
- emergency route disablement;
- rollback support;
- customer dispute handling.

This document governs human intervention at the POS Gateway operational boundary.

---

## 3. Core Principle

Manual fallback must preserve truth, not erase uncertainty.

When automation fails, staff may act to keep the store running.  
However, staff action must not rewrite history or hide what happened.

The gateway must preserve:

```text
what the system believed
what the provider returned
what the staff observed
what manual action was taken
who approved it
what evidence supported it
what customer impact existed
what reconciliation follow-up is required
```

Manual fallback is an operational safety valve, not a shortcut around audit and financial controls.

---

## 4. Staff Operation Role Model

The POS Gateway must define staff operation roles.

Recommended roles:

| Role | Purpose |
|---|---|
| `front_staff` | Customer-facing order/payment status handling |
| `cashier` | POS/payment/receipt handling |
| `kitchen_staff` | KDS/order preparation confirmation |
| `store_manager` | Sensitive approval and incident coordination |
| `shift_lead` | Limited manager substitute during shift |
| `support_operator` | Remote operational support |
| `reconciliation_owner` | Closing, settlement, and variance review |
| `payment_owner` | Payment/cancellation/refund verification |
| `technical_operator` | Gateway runtime and provider diagnostics |
| `incident_commander` | Incident response command |
| `tenant_admin` | Tenant-level configuration authority |

One person may hold multiple roles, but actions must still be executed under an explicit role context.

---

## 5. Authority Scope

Staff authority must be scoped.

Required authority dimensions:

```text
actor_id
role
tenant_id
store_id
shift_id
device_id
action_type
transaction_type
amount_limit
time_scope
approval_requirement
status
```

Staff authority must not be global by default.

A staff member authorized for order confirmation is not automatically authorized for refund approval.  
A store manager authorized for one store is not automatically authorized for another store.

---

## 6. Manual Action Classification

Manual actions must be classified.

Recommended action classes:

| Action Class | Description |
|---|---|
| `manual_confirm` | Staff confirms observed state |
| `manual_pos_entry` | Staff enters order into POS manually |
| `manual_payment_check` | Staff verifies payment in provider/POS |
| `manual_receipt_check` | Staff verifies receipt or proof |
| `manual_kds_action` | Staff creates, cancels, or confirms kitchen ticket |
| `manual_table_correction` | Staff corrects table/session context |
| `manual_sold_out_action` | Staff blocks or restores availability |
| `manual_price_adjustment` | Staff adjusts price or discount |
| `manual_cancel_review` | Staff reviews cancellation safety |
| `manual_refund_review` | Staff reviews refund safety |
| `manual_customer_resolution` | Staff resolves customer-facing issue |
| `manual_escalation` | Staff escalates to manager/support |
| `manual_route_disable` | Staff or manager disables automation path |
| `manual_reconciliation_note` | Staff adds evidence for later reconciliation |

Manual action classification must be visible in audit and incident records.

---

## 7. Manual Fallback State Model

The gateway must classify manual fallback state.

Recommended states:

| State | Meaning |
|---|---|
| `not_required` | Automation is operating normally |
| `suggested` | System recommends staff review |
| `required` | Automation cannot proceed without staff |
| `in_progress` | Staff action is being performed |
| `completed` | Staff completed fallback action |
| `failed` | Staff fallback failed or could not be completed |
| `escalated` | Manager/support/provider escalation required |
| `reconciliation_required` | Later reconciliation is required |
| `closed` | Manual fallback case closed with evidence |

Manual fallback status must not be hidden from operations dashboard.

---

## 8. Manual Fallback Trigger Conditions

Manual fallback must be triggered when automation is unsafe.

Trigger conditions include:

- POS write result unknown;
- payment success but POS order missing;
- POS order exists but payment state unknown;
- cancellation result unknown;
- refund result unknown;
- duplicate candidate detected;
- idempotency failure;
- retry exhaustion;
- dead-letter transaction entry;
- unmapped item after payment;
- price mismatch after cart confirmation;
- sold-out conflict after payment;
- table/session identity mismatch;
- KDS ticket uncertainty;
- provider outage or credential failure;
- monitoring blind spot;
- customer dispute.

The gateway should prefer manual fallback over unsafe automatic retry.

---

## 9. Manual POS Entry Policy

Manual POS entry may be used when automated POS write is unavailable or unsafe.

Manual POS entry requires:

- original gateway order reference;
- reason for manual entry;
- staff actor;
- POS receipt/order reference after entry;
- item and total verification;
- payment state verification;
- customer communication state;
- reconciliation flag.

Manual POS entry must not create duplicate POS order if the automated write may have succeeded.

If automated write result is unknown, provider/POS lookup must be attempted before manual entry where possible.

---

## 10. Manual Payment Verification Policy

Manual payment verification is required when payment state is uncertain.

Verification sources may include:

- payment provider dashboard;
- POS payment record;
- VAN/PG approval reference;
- customer receipt;
- approval SMS/app evidence;
- settlement report;
- gateway payment log.

Manual payment verification must record:

```text
manual_payment_check_id
order_id
payment_reference
verification_source
verified_state
verified_amount
verified_by
verified_at
evidence_reference
```

Staff must not ask the customer to pay again until duplicate charge risk is cleared.

---

## 11. Manual Receipt Verification Policy

Receipt verification may be required when proof of transaction is uncertain.

Verification must preserve:

- POS receipt number;
- bill number;
- approval number;
- cancellation receipt;
- refund receipt;
- reissue evidence;
- staff actor;
- verification timestamp.

A receipt must not be fabricated by gateway-only evidence when provider/POS receipt is required for dispute or accounting.

---

## 12. Manual KDS Action Policy

Manual KDS action may be required when kitchen state is uncertain.

Manual KDS actions may include:

- confirm ticket received;
- create manual kitchen instruction;
- cancel duplicate ticket;
- mark remake;
- hold order;
- release held order;
- annotate wrong table/channel.

Manual KDS action must record:

- order ID;
- ticket reference;
- kitchen staff actor;
- action reason;
- food preparation state;
- customer impact;
- waste/remake impact where applicable.

Manual KDS action must not hide duplicate cook risk.

---

## 13. Manual Cancellation Review

Manual cancellation review is required when cancellation automation is unsafe.

Manual cancellation review must verify:

- original transaction identity;
- current payment state;
- current POS order state;
- KDS/preparation state;
- cancellation eligibility;
- duplicate cancellation risk;
- customer communication state.

Cancellation must not be marked complete without evidence.

---

## 14. Manual Refund Review

Manual refund review is required when refund automation is unsafe or restricted.

Manual refund review must verify:

- original payment reference;
- refundable amount;
- prior refund history;
- partial refund allocation;
- coupon/membership restoration;
- provider refund capability;
- duplicate refund risk;
- customer evidence;
- approval authority.

Refund must not be executed or marked complete blindly.

Manager approval should be required for:

- high-value refund;
- partial refund with allocation uncertainty;
- duplicate charge claim;
- refund after provider state unknown;
- manual goodwill refund;
- refund outside normal window.

---

## 15. Manual Table / Session Correction

Manual table/session correction may be required when identity is wrong.

Correction may include:

- attach order to correct table session;
- transfer order;
- split/merge session;
- mark wrong table issue;
- suspend QR/NFC object;
- reassign waiting/preorder handoff;
- request staff confirmation.

Correction must preserve original object scan and original session evidence.

Staff must not simply overwrite original table ID without correction record.

---

## 16. Manual Sold-Out and Availability Action

Staff may manually block or restore item availability.

Manual availability action must include:

- item/modifier/component identity;
- reason;
- affected channels;
- effective time;
- actor;
- approval where required;
- customer-visible flag;
- order blocking flag.

Manual sold-out action must propagate to ordering channels as quickly as possible.

Restoring availability after safety or quality block may require manager approval.

---

## 17. Manual Price / Discount Adjustment

Manual price or discount adjustment is sensitive.

Manual adjustment requires:

- original calculated amount;
- adjusted amount;
- reason;
- actor;
- manager approval where required;
- customer communication;
- receipt treatment;
- reconciliation treatment.

Manual adjustment must not modify original calculation snapshot.  
It must create an adjustment record.

---

## 18. Manager Approval Policy

Manager approval is required for sensitive actions.

Actions typically requiring approval:

- refund execution or refund confirmation;
- cancellation after payment;
- manual price adjustment beyond threshold;
- manual discount override;
- duplicate charge resolution;
- high-value manual POS correction;
- table/session correction after payment;
- restriction removal;
- rollback removal;
- safety block removal;
- provider route override;
- manual reconciliation closure;
- incident closure involving customer payment.

Manager approval must be explicit, auditable, and scoped.

---

## 19. Approval Thresholds

Approval thresholds must be configurable.

Threshold dimensions:

```text
tenant_id
store_id
action_type
amount_threshold
role_required
second_approval_required_flag
time_window
status
```

Examples:

- refunds above threshold require store manager;
- duplicate charge resolution requires payment owner;
- manual discount above threshold requires manager;
- after-business-day correction requires reconciliation owner;
- safety block removal requires authorized manager.

Threshold changes must be audited.

---

## 20. Emergency Override Policy

Emergency override may be required to protect store operations or customers.

Allowed emergency overrides:

- disable automated order write;
- disable refund automation;
- disable cancellation automation;
- force manual confirmation;
- suspend QR/NFC object;
- suspend kiosk;
- disable provider route;
- pause retry worker;
- enable manual fallback mode.

Emergency override must create:

- override record;
- reason;
- actor;
- approval if available;
- affected scope;
- expiration or review condition;
- incident link.

Emergency override must not delete transaction evidence.

---

## 21. Override Expiry and Review

Overrides must be time-bounded or review-bounded.

Override record must include:

```text
override_id
override_type
affected_scope
reason
actor_id
approved_by
created_at
expires_at
review_required_at
status
```

Expired overrides must not remain active silently.

Long-lived overrides must become formal restrictions or configuration changes.

---

## 22. Staff Device and Session Requirements

Manual actions must be tied to staff device/session identity.

Required context:

- staff actor ID;
- role at time of action;
- device ID;
- store ID;
- shift/session ID;
- authentication state;
- action timestamp.

Sensitive manual actions should require reauthentication or manager PIN/approval depending on risk.

---

## 23. Customer Communication During Manual Fallback

Staff-facing workflow must include safe customer communication.

Allowed messages:

```text
주문 상태를 확인 중입니다.
결제 중복이 발생하지 않도록 확인하고 있습니다.
직원이 직접 확인 후 처리해드리겠습니다.
환불 가능 여부와 처리 상태를 확인한 뒤 안내드리겠습니다.
```

Prohibited messages without evidence:

```text
결제 실패입니다.
다시 결제해주세요.
환불 완료입니다.
주문 완료입니다.
```

Manual fallback must protect customer rights before internal speed.

---

## 24. Manual Fallback Evidence Record

Every transaction-critical manual fallback must create an evidence record.

Required fields:

```text
manual_fallback_id
tenant_id
store_id
order_id
transaction_id
action_class
fallback_reason
system_state_before
staff_observed_state
manual_action_taken
actor_id
approver_id
evidence_reference
customer_impact
financial_impact
reconciliation_required_flag
created_at
status
```

This record must be linked to audit, incident, and reconciliation where applicable.

---

## 25. Reconciliation Impact

Manual fallback may affect reconciliation.

Manual fallback records must be included in reconciliation when they involve:

- manual POS entry;
- manual payment verification;
- manual cancellation;
- manual refund;
- manual price adjustment;
- manual receipt correction;
- manual table/session correction;
- manual provider portal action.

Reconciliation must distinguish automated gateway transactions from manual fallback actions.

---

## 26. Incident Linkage

Manual fallback must link to incident workflow when risk is significant.

Incident linkage is required when:

- customer payment impact exists;
- duplicate risk exists;
- refund/cancellation uncertainty exists;
- POS/payment mismatch exists;
- provider escalation is required;
- staff action corrects system failure;
- repeated fallback occurs;
- safety block or availability failure caused customer impact.

Manual fallback without incident linkage may be acceptable only for minor, expected operational adjustments.

---

## 27. Audit Requirements

Manual staff actions must emit audit events.

Audit event must include:

```text
event_id
event_type
actor_id
role
tenant_id
store_id
device_id
order_id
transaction_id
action_class
before_state
after_state
approval_id
reason
created_at
```

Audit logs must not expose secrets or unnecessary customer information.

---

## 28. Monitoring Requirements

Manual fallback must be monitored.

Required metrics:

- manual fallback count;
- manual POS entry count;
- manual payment verification count;
- manual refund review count;
- manual cancellation review count;
- manual table correction count;
- manual sold-out action count;
- manager approval count;
- emergency override count;
- fallback by store;
- fallback by provider;
- repeated fallback pattern;
- unresolved manual fallback count.

High manual fallback rate may indicate automation, provider, mapping, or training failure.

---

## 29. Dashboard Requirements

Operations dashboard must show:

- active manual fallback cases;
- required staff actions;
- pending manager approvals;
- active overrides;
- expired overrides;
- repeated fallback patterns;
- reconciliation-required manual actions;
- customer-impact manual cases;
- store/provider fallback rate;
- fallback closure status.

Dashboard must not hide manual fallback behind normal transaction status.

---

## 30. Training Requirements

Staff training must cover:

- how to identify uncertain transaction state;
- when not to ask customer to pay again;
- when to call manager;
- how to perform manual POS entry safely;
- how to verify payment;
- how to handle missing receipt;
- how to handle refund/cancellation exception;
- how to suspend sold-out item;
- how to escalate incident;
- what customer messages are safe.

Training must be practical and short enough for shift operation.

---

## 31. Prohibited Practices

The following practices are prohibited:

- asking customer to pay again before duplicate payment risk is cleared;
- marking refund complete without provider evidence;
- deleting failed gateway order after manual POS entry;
- overwriting original transaction state to match manual action;
- hiding manual fallback from reconciliation;
- allowing staff to execute high-risk refund without approval;
- leaving emergency override active indefinitely;
- using manual action to bypass provider restriction;
- correcting wrong table/session by deleting original evidence;
- closing manual fallback case without evidence.

---

## 32. Minimum Acceptance Criteria

Staff operation and manual fallback control is acceptable only when:

- staff role model exists;
- authority scope is explicit;
- manual action classification exists;
- manual fallback state model exists;
- trigger conditions are defined;
- manual POS entry is auditable;
- manual payment and receipt verification exist;
- manual KDS, table/session, sold-out, and price adjustment policies exist;
- manager approval policy exists;
- emergency override is controlled;
- override expiry/review exists;
- staff device/session identity is recorded;
- customer communication boundary exists;
- manual fallback evidence record exists;
- reconciliation and incident linkage exist;
- monitoring and dashboard visibility exist.

---

## 33. Implementation Notes

Recommended implementation artifacts:

```text
pos_gateway_staff_roles
pos_gateway_staff_authority_scopes
pos_gateway_manual_action_records
pos_gateway_manual_fallback_cases
pos_gateway_manual_pos_entries
pos_gateway_manual_payment_checks
pos_gateway_manual_receipt_checks
pos_gateway_manual_kds_actions
pos_gateway_manual_table_corrections
pos_gateway_manual_availability_actions
pos_gateway_manual_price_adjustments
pos_gateway_manager_approvals
pos_gateway_emergency_overrides
pos_gateway_override_reviews
pos_gateway_staff_training_records
```

Recommended services:

```text
StaffAuthorityService
ManualFallbackService
ManualPosEntryService
ManualPaymentVerificationService
ManualReceiptVerificationService
ManualKdsActionService
ManualTableCorrectionService
ManualAvailabilityActionService
ManualPriceAdjustmentService
ManagerApprovalService
EmergencyOverrideService
OverrideReviewService
ManualFallbackEvidenceService
ManualFallbackMonitoringService
StaffTrainingService
```

Recommended event types:

```text
pos_gateway.staff.manual_fallback_required
pos_gateway.staff.manual_fallback_started
pos_gateway.staff.manual_fallback_completed
pos_gateway.staff.manual_pos_entry_recorded
pos_gateway.staff.payment_verified
pos_gateway.staff.receipt_verified
pos_gateway.staff.kds_action_recorded
pos_gateway.staff.table_correction_recorded
pos_gateway.staff.sold_out_action_recorded
pos_gateway.staff.price_adjustment_recorded
pos_gateway.staff.manager_approval_requested
pos_gateway.staff.manager_approval_granted
pos_gateway.staff.emergency_override_applied
pos_gateway.staff.emergency_override_expired
```

---

## 34. Relationship To Adjacent Documents

This document is related to:

- 06090 POS Gateway table, session, seat, object, QR, NFC, device identity, and handoff integrity policy;
- 06080 POS Gateway order channel separation, dine-in, takeout, delivery, kiosk, table QR, and staff order routing policy;
- 06070 POS Gateway inventory, availability, sold-out, stock sync, and order blocking integrity policy;
- 06060 POS Gateway price, promotion, discount, coupon, tax, service charge, and total calculation integrity policy;
- POS Gateway cancellation, refund, exception, manual override, and customer protection policy;
- POS Gateway incident response, dispute investigation, provider escalation, and postmortem policy;
- POS Gateway reconciliation, settlement, closing report, and accounting linkage policy;
- store operation, staff training, and authorization policies.

Where conflict exists, this document governs staff operation, manual fallback, override authority, and manager approval behavior at the POS Gateway operational boundary.

---

## 35. Summary

Automation cannot cover every store reality.

The POS Gateway must support staff intervention without sacrificing financial integrity, customer protection, or audit truth.

The correct standard is:

- give staff safe manual fallback;
- require manager approval for sensitive actions;
- preserve system state and staff-observed state;
- never erase uncertainty;
- link manual action to reconciliation and incidents;
- monitor repeated fallback as a signal of deeper failure.

Manual fallback is not a weakness.  
Uncontrolled manual fallback is.