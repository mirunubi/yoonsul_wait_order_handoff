# 21550_Policy_Universal_Alert_Routing_Severity_Escalation_And_Acknowledgement

## 1. Purpose

This document defines the universal alert routing, severity, escalation, acknowledgement, and resolution policy for all integration domains.

The purpose is to ensure that alert generation does not stop at logging.

When an integration event becomes risky, the system must know:

- how severe the event is
- who should see it first
- who should be escalated next
- who may acknowledge it
- who may resolve it
- what evidence is required
- what audit is required
- what message keys are required
- when escalation is triggered
- when the alert must be reopened

This applies to financial, membership, coupon, wallet, identity, POS, KDS, inventory, content, i18n, AI, support/admin, provider, supplier, SCM, WMS, workforce, and Franchise OS integrations.

This document does not authorize coding.

Coding remains deferred unless a specific package has `CODING_ALLOWED`, a completed handoff record, a narrow work order, required tests, and review approval.

---

## 2. Scope

This policy applies to alert routing and severity planning for:

1. Universal integration alerts
2. Financial and settlement alerts
3. Membership and customer identity alerts
4. Coupon, promotion, and wallet alerts
5. POS and provider alerts
6. Payment and refund alerts
7. KDS and order alerts
8. Inventory and sold-out alerts
9. Content registry and i18n alerts
10. AI governance alerts
11. External projection alerts
12. Support/admin alerts
13. Supplier, SCM, and WMS alerts
14. Workforce and HR alerts
15. Franchise OS alerts
16. Security and privacy alerts
17. Legal/compliance review alerts

This document defines planning rules only.

It does not implement alert queues, notification workers, dashboards, push notifications, emails, SMS, Slack, webhooks, or escalation jobs.

---

## 3. Core Principle

Alert routing is authority-sensitive.

The system must not send every alert to everyone.

The system must not hide high-risk alerts from the proper actor.

The system must not let acknowledgement become resolution.

The system must not let support convenience bypass evidence, audit, reconciliation, provider review, or legal review.

Every alert must have controlled routing, severity, acknowledgement, escalation, and resolution rules.

---

## 4. Universal Severity Catalog

The universal severity catalog should use controlled values.

| Severity | Meaning | Default Behavior |
|---|---|---|
| `INFO` | Normal informational event | Log only |
| `NOTICE` | Low-risk abnormal event | Dashboard visibility |
| `WARNING` | Operational risk | Notify domain owner |
| `HIGH_RISK` | Value, identity, support, privacy, or provider risk | Alert domain owner and support/admin |
| `CRITICAL` | Security, financial, identity, allergen, legal, or authority-critical risk | Immediate escalation |
| `REVIEW_REQUIRED` | Human review required before action | Route to reviewer |
| `RECONCILIATION_REQUIRED` | Cross-system mismatch requires reconciliation | Route to reconciliation owner |
| `CUSTOMER_RECOVERY_REQUIRED` | Customer impact likely | Route to support/customer recovery |
| `PROVIDER_REVIEW_REQUIRED` | Provider capability/callback/settlement issue | Route to provider owner |
| `LEGAL_COMPLIANCE_REVIEW_REQUIRED` | Legal, privacy, safety, or compliance review required | Route to legal/compliance |

Severity values must not be replaced by vague labels such as `normal`, `urgent`, `done`, or `problem`.

---

## 5. Severity Escalation Factors

Severity may be escalated based on risk factors.

Escalation factors include:

- financial value affected
- wallet/prepaid value affected
- membership value affected
- customer identity affected
- privacy or consent affected
- allergen or safety information affected
- support decision affected
- provider callback verification failure
- repeated duplicate events
- unresolved prior alert
- stale state duration
- cross-store or cross-tenant risk
- public external projection impact
- AI authority overreach
- restricted data exposure
- legal/compliance sensitivity
- peak operational time window
- franchise/HQ policy impact

Severity escalation must be policy-driven, not ad hoc UI logic.

---

## 6. Universal Alert Routing Record

Every alert family must have a routing record.

Minimum fields:

| Field | Required Meaning |
|---|---|
| Alert family | Controlled alert code |
| Domain | Membership, payment, KDS, etc. |
| Default severity | Controlled severity |
| Primary route | First responsible actor/team/surface |
| Secondary route | Escalation target |
| Emergency route | Critical escalation target if any |
| Customer visibility | Internal only, support-mediated, or customer-visible |
| Evidence requirement | Required, optional, or blocked |
| Audit requirement | Required or not |
| Acknowledgement owner | Who may acknowledge |
| Resolution owner | Who may resolve |
| Escalation window | Time or condition trigger |
| Message key family | i18n/message key family |
| Suppression rule | Duplicate suppression rule |
| Reopen rule | Reopen condition |

No alert family should exist without a routing record.

---

## 7. Alert Route Catalog

Recommended route categories:

| Route | Meaning |
|---|---|
| `ROUTE_STORE_OPS` | Store staff/manager operational route |
| `ROUTE_SUPPORT` | Customer support route |
| `ROUTE_SUPPORT_LEAD` | Support lead escalation |
| `ROUTE_HQ_ADMIN` | HQ admin route |
| `ROUTE_FINANCE` | Finance/settlement route |
| `ROUTE_RECONCILIATION` | Reconciliation owner route |
| `ROUTE_SECURITY` | Security review route |
| `ROUTE_PRIVACY` | Privacy/customer identity route |
| `ROUTE_LEGAL_COMPLIANCE` | Legal/compliance route |
| `ROUTE_PROVIDER_OPS` | External provider review route |
| `ROUTE_CONTENT` | Content registry route |
| `ROUTE_LOCALIZATION` | i18n/translation route |
| `ROUTE_AI_GOVERNANCE` | AI governance route |
| `ROUTE_PROJECTION_OPS` | External projection route |
| `ROUTE_SCM` | Supplier/SCM route |
| `ROUTE_WMS` | WMS/inventory route |
| `ROUTE_HR` | Workforce/HR route |
| `ROUTE_FRANCHISE_OPS` | Franchise OS route |
| `ROUTE_QC_SAFETY` | Quality/allergen/safety route |

Routes are planning categories.

They do not implement notification channels.

---

## 8. Notification Channel Boundary

Future notification channels may include:

- admin dashboard
- support case inbox
- finance reconciliation queue
- store tablet warning
- owner dashboard
- HQ dashboard
- provider review queue
- AI governance queue
- content/localization review queue
- security review queue
- legal/compliance review queue
- email
- SMS
- push notification
- messenger/Slack-like channel

Channel selection must depend on alert severity, audience, and data sensitivity.

High-risk diagnostic data must not be sent through insecure or customer-visible channels.

---

## 9. Customer Visibility Rule

Most alerts are internal.

Customer-visible messages must be mediated through approved support or customer communication policies.

Customer visibility categories:

| Category | Meaning |
|---|---|
| `CUSTOMER_NOT_VISIBLE` | Internal only |
| `CUSTOMER_SUPPORT_MEDIATED` | Support may communicate using approved keys |
| `CUSTOMER_STATUS_VISIBLE` | Customer may see safe status message |
| `CUSTOMER_ACTION_REQUIRED` | Customer must take action |
| `CUSTOMER_RECOVERY_VISIBLE` | Customer recovery message may be shown |
| `CUSTOMER_BLOCKED_LEGAL_REVIEW` | No customer message before legal/compliance review |

Customer-facing alert text must use approved i18n/message keys or content registry keys.

---

## 10. Acknowledgement Rule

Acknowledgement means the alert has been seen or accepted for review.

Acknowledgement does not mean the issue is fixed.

Acknowledgement must define:

- who may acknowledge
- whether role/authority is required
- whether reason is required
- whether evidence must already exist
- whether acknowledgement creates audit
- whether acknowledgement pauses escalation
- whether acknowledgement assigns ownership
- whether acknowledgement affects customer visibility

Acknowledgement must never mutate financial, membership, coupon, wallet, identity, KDS, projection, provider, or support final state by itself.

---

## 11. Acknowledgement State Catalog

| State | Meaning |
|---|---|
| `ACK_NOT_REQUIRED` | No acknowledgement needed |
| `ACK_REQUIRED` | Acknowledgement required |
| `ACK_PENDING` | Waiting for acknowledgement |
| `ACK_ACCEPTED` | Acknowledged by authorized actor |
| `ACK_REJECTED` | Acknowledgement rejected |
| `ACK_ESCALATED_DUE_TO_DELAY` | Escalated because not acknowledged |
| `ACK_INVALID_AUTHORITY` | Actor lacked authority |
| `ACK_REASON_REQUIRED` | Reason missing |
| `ACK_AUDIT_REQUIRED` | Audit required before acknowledgement valid |

These states must not be collapsed into a simple `seen` flag.

---

## 12. Resolution Rule

Resolution means the alert has been reviewed and the required domain-specific action has been completed or explicitly rejected/deferred.

Resolution must define:

- who may resolve
- what authority is required
- what evidence is required
- what audit is required
- what reconciliation record is affected
- what correction/rollback/replay may be required
- what customer recovery may be required
- what provider evidence may be required
- what legal review may be required
- what reopen condition remains

Resolution must not silently mutate underlying state.

Domain-specific contracts must control the actual action.

---

## 13. Resolution State Catalog

| State | Meaning |
|---|---|
| `RESOLUTION_NOT_REQUIRED` | No resolution needed |
| `RESOLUTION_PENDING` | Waiting for resolution |
| `RESOLUTION_EVIDENCE_REQUIRED` | Evidence missing |
| `RESOLUTION_REVIEW_REQUIRED` | Review required |
| `RESOLUTION_RECONCILIATION_REQUIRED` | Reconciliation required |
| `RESOLUTION_PROVIDER_EVIDENCE_REQUIRED` | Provider evidence required |
| `RESOLUTION_CUSTOMER_RECOVERY_REQUIRED` | Customer recovery needed |
| `RESOLUTION_LEGAL_REVIEW_REQUIRED` | Legal/compliance review needed |
| `RESOLUTION_RESOLVED` | Resolved |
| `RESOLUTION_DEFERRED_WITH_REASON` | Deferred with reason |
| `RESOLUTION_REJECTED_FALSE_POSITIVE` | Rejected as false positive |
| `RESOLUTION_REOPENED` | Reopened after new evidence |

Resolution states must remain auditable where authority is involved.

---

## 14. Escalation Rule

Escalation occurs when an alert is not acknowledged or resolved within policy, or when severity requires a higher route immediately.

Escalation must define:

- severity threshold
- elapsed time threshold
- repeated occurrence threshold
- unresolved prior alert trigger
- customer impact trigger
- provider SLA trigger
- financial value threshold
- identity/privacy trigger
- legal/compliance trigger
- emergency route
- escalation message key
- audit event requirement

Escalation must be visible in alert history.

---

## 15. Escalation State Catalog

| State | Meaning |
|---|---|
| `ESCALATION_NOT_REQUIRED` | No escalation needed |
| `ESCALATION_PENDING` | Escalation condition approaching |
| `ESCALATION_TRIGGERED` | Escalation triggered |
| `ESCALATION_SENT` | Escalation sent |
| `ESCALATION_DELIVERY_FAILED` | Escalation delivery failed |
| `ESCALATION_ACKNOWLEDGED` | Escalation acknowledged |
| `ESCALATION_CHAIN_ADVANCED` | Escalated to next level |
| `ESCALATION_HALTED_WITH_REASON` | Stopped with reason |
| `ESCALATION_LEGAL_COMPLIANCE` | Escalated to legal/compliance |
| `ESCALATION_EMERGENCY` | Emergency escalation triggered |

Escalation must not be hidden by duplicate suppression.

---

## 16. Suppression And Deduplication Rule

Duplicate alert suppression is allowed only when it does not hide worsening risk.

Suppression must define:

- suppression key
- event family
- correlation id
- time window
- severity threshold
- repeated count
- escalation override
- manual suppression authority
- audit requirement for high-risk suppression
- reopen condition

Suppression is prohibited when:

- severity is `CRITICAL`
- legal/compliance risk exists
- customer identity risk exists
- allergen/safety risk exists
- value duplication risk exists
- provider callback verification failed
- cross-store/cross-tenant risk exists
- AI authority overreach exists

unless explicit review authority allows temporary suppression.

---

## 17. Reopen Rule

An alert must reopen when new evidence changes the risk state.

Reopen triggers include:

- new provider callback
- new reconciliation mismatch
- customer complaint
- repeated duplicate event
- evidence packet updated
- AI summary contradicted by source
- projection mismatch persists
- support case reopened
- legal/compliance review requested
- customer recovery failed
- manual resolution contradicted by later event

Reopened alerts must preserve prior history.

Reopen must not overwrite the old resolution record.

---

## 18. Domain Routing Matrix

Initial routing recommendations:

| Domain | Primary Route | Secondary Route | Emergency Route |
|---|---|---|---|
| Membership | `ROUTE_SUPPORT` | `ROUTE_PRIVACY` | `ROUTE_LEGAL_COMPLIANCE` |
| Coupon/Promotion | `ROUTE_SUPPORT` | `ROUTE_HQ_ADMIN` | `ROUTE_FINANCE` |
| Wallet/Prepaid | `ROUTE_FINANCE` | `ROUTE_SUPPORT_LEAD` | `ROUTE_SECURITY` |
| Customer Identity | `ROUTE_PRIVACY` | `ROUTE_SUPPORT_LEAD` | `ROUTE_LEGAL_COMPLIANCE` |
| POS | `ROUTE_STORE_OPS` | `ROUTE_SUPPORT` | `ROUTE_SECURITY` |
| Payment | `ROUTE_FINANCE` | `ROUTE_PROVIDER_OPS` | `ROUTE_SECURITY` |
| Settlement/Ledger | `ROUTE_RECONCILIATION` | `ROUTE_FINANCE` | `ROUTE_HQ_ADMIN` |
| KDS/Order | `ROUTE_STORE_OPS` | `ROUTE_SUPPORT` | `ROUTE_HQ_ADMIN` |
| Inventory | `ROUTE_STORE_OPS` | `ROUTE_WMS` | `ROUTE_QC_SAFETY` |
| Content | `ROUTE_CONTENT` | `ROUTE_SUPPORT` | `ROUTE_HQ_ADMIN` |
| i18n | `ROUTE_LOCALIZATION` | `ROUTE_CONTENT` | `ROUTE_SUPPORT` |
| AI | `ROUTE_AI_GOVERNANCE` | `ROUTE_SECURITY` | `ROUTE_HQ_ADMIN` |
| External Projection | `ROUTE_PROJECTION_OPS` | `ROUTE_CONTENT` | `ROUTE_LEGAL_COMPLIANCE` |
| Provider | `ROUTE_PROVIDER_OPS` | `ROUTE_SECURITY` | `ROUTE_HQ_ADMIN` |
| SCM/WMS | `ROUTE_SCM` | `ROUTE_WMS` | `ROUTE_QC_SAFETY` |
| Workforce/HR | `ROUTE_HR` | `ROUTE_SECURITY` | `ROUTE_LEGAL_COMPLIANCE` |
| Franchise OS | `ROUTE_FRANCHISE_OPS` | `ROUTE_HQ_ADMIN` | `ROUTE_FINANCE` |

This routing matrix is a starting catalog.

Final routing requires later review.

---

## 19. High-Risk Immediate Escalation Families

The following alert families should normally trigger immediate escalation:

- `ALERT_POS_CROSS_STORE_EVENT_RISK`
- `ALERT_POS_TOKEN_SCOPE_VIOLATION`
- `ALERT_PAYMENT_DUPLICATE_CAPTURE_RISK`
- `ALERT_PAYMENT_REFUND_WITHOUT_APPROVAL`
- `ALERT_WALLET_DUPLICATE_CHARGE`
- `ALERT_WALLET_UNAUTHORIZED_ADJUSTMENT`
- `ALERT_IDENTITY_WRONG_ACCOUNT_RISK`
- `ALERT_IDENTITY_CONSENT_MISSING`
- `ALERT_PROJECTION_ALLERGEN_MISMATCH`
- `ALERT_PROVIDER_CALLBACK_SIGNATURE_FAILED`
- `ALERT_AI_AUTHORITY_OVERREACH`
- `ALERT_SUPPORT_UNAUTHORIZED_MUTATION`
- `ALERT_SUPPORT_EXPORT_REQUESTED`
- `ALERT_I18N_CUSTOMER_VISIBLE_UNTRANSLATED`
- `ALERT_CONTENT_RUNTIME_BOUNDARY_VIOLATION`

Immediate escalation must still preserve evidence and audit.

---

## 20. Customer Recovery Routing

Customer recovery may be required when alerts affect:

- payment result
- refund expectation
- coupon use
- point balance
- wallet balance
- wrong membership identity
- unavailable menu order
- allergen/safety information
- external projection mismatch
- support case misclassification
- AI unapproved response
- order/KDS delay or failure

Customer recovery routing must distinguish:

- customer-facing status message
- support-mediated response
- compensation request
- refund request
- manual review
- legal/compliance blocked response

Customer recovery is not automatic compensation.

---

## 21. Legal And Compliance Routing

Legal/compliance routing is required for:

- privacy/identity conflict
- customer consent missing
- allergen/safety mismatch
- export of restricted data
- financial dispute above threshold
- provider contract dispute
- overseas payment/settlement legal uncertainty
- employment eligibility/workforce sensitive issue
- customer data sharing with partner
- AI output that may create legal claim
- patent/provider capability claim risk

Legal/compliance review may block customer-facing messaging until approved.

---

## 22. Provider Review Routing

Provider review is required for:

- callback signature failure
- provider callback unmapped
- provider API contract change
- provider settlement report missing
- provider capability evidence missing
- Redtable-type capability uncertainty
- Alipay/WeChat Pay/overseas card evidence missing
- Google Maps/NFC/QR provider capability uncertainty
- partner sync stale
- provider rate limit risk
- provider refund status mismatch

Provider review must preserve `CAPABILITY_PROVIDER_EVIDENCE_REQUIRED` until evidence is confirmed.

---

## 23. AI Governance Routing

AI governance routing is required for:

- AI restricted source request
- AI untraceable output
- AI customer-facing unapproved response
- AI wrong-locale response risk
- AI provider capability invention
- AI authority overreach
- AI evidence summary misuse
- AI masking boundary risk
- AI use of unapproved SOP/content
- AI-generated external projection text without approval

AI governance review must not allow AI to resolve its own alert.

---

## 24. Acknowledgement Audit Rule

Acknowledgement requires audit when the alert involves:

- financial value
- wallet/prepaid value
- membership points or benefits
- customer identity
- restricted data
- security incident
- provider callback verification
- support/admin authority
- legal/compliance risk
- external projection publication
- AI output used in customer/support context
- override or backup authority

Audit must record actor, role, timestamp, alert id, reason if required, and evidence state.

---

## 25. Resolution Audit Rule

Resolution requires audit when the alert involves:

- any correction
- any replay
- any rollback
- any customer recovery
- any refund or compensation request
- any membership/coupon/wallet adjustment
- any identity relinking
- any provider evidence acceptance
- any content/projection correction
- any support/admin override
- any legal/compliance review
- any AI output approval

Resolution audit must not be optional.

---

## 26. Alert Message Key Families

Every alert family must define message key families.

Recommended key pattern:

`alert.<domain>.<family>.<surface>.<message_type>`

Examples:

- `alert.payment.reconciliation_required.support.title`
- `alert.membership.identity_conflict.support.summary`
- `alert.kds.ticket_duplicate.store.action`
- `alert.projection.allergen_mismatch.hq.title`
- `alert.ai.authority_overreach.admin.summary`
- `alert.provider.callback_signature_failed.security.action`

Message types may include:

- `title`
- `summary`
- `action`
- `ack_prompt`
- `escalation_notice`
- `resolution_notice`
- `customer_safe_status`
- `support_diagnostic`

Hardcoded alert text is prohibited.

---

## 27. Alert Routing Readiness Blockers

The blocker inventory must include alert routing blockers.

| Blocker ID Pattern | Family | Meaning |
|---|---|---|
| `BLOCKER-ROUTING-0001` | Routing | Primary route missing |
| `BLOCKER-ROUTING-0002` | Routing | Escalation route missing |
| `BLOCKER-ROUTING-0003` | Routing | Customer visibility rule missing |
| `BLOCKER-SEVERITY-0001` | Severity | Severity mapping missing |
| `BLOCKER-ACK-0001` | Acknowledgement | Acknowledgement owner missing |
| `BLOCKER-ACK-0002` | Acknowledgement | Ack audit rule missing |
| `BLOCKER-RESOLUTION-0001` | Resolution | Resolution owner missing |
| `BLOCKER-RESOLUTION-0002` | Resolution | Resolution evidence/audit rule missing |
| `BLOCKER-ESCALATION-0001` | Escalation | Escalation window missing |
| `BLOCKER-MESSAGE-ALERT-0001` | i18n | Alert message key missing |

Open routing blockers must prevent runtime alert implementation.

---

## 28. Boundary Test Additions

Future tests/checks should verify:

- every alert family has severity
- every alert family has primary route
- every high-risk alert has escalation route
- every customer-visible alert has message keys
- acknowledgement does not equal resolution
- acknowledgement owner is defined
- resolution owner is defined
- high-risk acknowledgement creates audit
- high-risk resolution creates audit
- legal/compliance alerts cannot be customer-visible without approval
- provider review alerts preserve evidence-required state
- AI governance alerts cannot be resolved by AI
- duplicate suppression cannot hide critical alerts
- no package marked coding-ready with routing blocker open

These tests are planning expectations until implementation is approved.

---

## 29. Relationship To Previous Documents

This document follows:

- `21530 Universal Integration Event Catalog And Alert Family Index Policy`
- `21540 Universal Integration Reconciliation And Idempotency Catalog Policy`

It also reinforces:

- `21520 Universal Integration Event Alert Logging And Evidence Policy`
- `21510 Financial Event Alert Logging And Automated Warning System Policy`
- `22480 Foundation Catalog Validation Checklist And Review Gate Policy`
- `22360 Support Admin Evidence Audit Package Planning Policy`
- `22370 AI Support Gateway pgvector RAG Package Planning Policy`

This document prepares alert routing, severity, escalation, acknowledgement, and resolution catalog discipline for all integration domains.

It does not authorize coding.

---

## 30. Final Rule

Every alert family must have controlled severity, routing, acknowledgement, escalation, resolution, evidence, audit, customer visibility, suppression, reopen, and i18n message-key rules.

Acknowledgement is not resolution.

Suppression must not hide worsening risk.

AI may assist alert review but must not suppress, acknowledge, resolve, mutate, approve, reconcile, publish, or confirm provider capability.

Coding remains deferred until alert routing records, severity mappings, escalation rules, acknowledgement rules, resolution authority, audit/evidence requirements, message keys, blockers, and boundary tests are reviewed and approved.
