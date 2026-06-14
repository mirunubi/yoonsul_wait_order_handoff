# 10734_Legal_Notice_Support_Playbook_And_Case_Reason_Code_Policy

## 1. Purpose

This document defines the Legal Notice Support Playbook and Case Reason Code Policy for Catch Menu.

The previous document `10733 Legal Notice Admin Checklist And Store Onboarding Review Policy` defined how legal notice readiness is checked during store onboarding before SaaS activation.

This document focuses on support and dispute handling after customer-facing use begins.

It defines:

- support case categories
- case reason codes
- evidence packet lookup
- customer response boundaries
- escalation routes
- refund/no-show/alcohol/privacy/allergen/coupon/review/device/payment dispute handling
- support authority limits
- staff/store/HQ/legal handoff
- missing evidence handling
- AI support assistant boundary
- audit and case closure rules

This document is planning-only.

It does not provide legal advice.

It does not authorize coding.

---

## 2. Core Position

Support must resolve cases from evidence, not memory.

The correct rule is:

Support should not guess what notice was shown.  
Support should not rely on current notice text.  
Support should not approve or reject disputes without order/payment/KDS/POS state.  
Support should not mutate historical evidence.  
Support should not promise legal outcomes.  
Support should use controlled reason codes.  
Support should see the exact notice version, locale, surface, trigger, acknowledgement, and store setting active at the time.  
Support should escalate when evidence is missing, high-risk, or authority is insufficient.  
AI may summarize evidence and suggest reason codes.  
AI cannot decide refunds, penalties, alcohol verification, privacy compliance, or legal liability.  

Support is an evidence-driven operational workflow.

---

## 3. Scope

This policy applies to support handling for:

- refund and cancellation disputes
- no-show and deposit disputes
- alcohol age/ID disputes
- privacy consent and marketing disputes
- allergen and food safety disputes
- raw food and freshness complaints
- market price disputes
- payment error and duplicate payment disputes
- coupon, point, event, and promotion disputes
- review/content/IP disputes
- device/hardware damage disputes
- store facility disputes
- staff protection and abusive customer incidents
- disaster/force majeure disputes
- i18n/translation confusion
- missing notice evidence
- support evidence export
- HQ/legal escalation

This policy defines support governance only.

---

## 4. Support Case Families

Recommended support case families:

| Case Family | Meaning |
|---|---|
| `REFUND_CANCEL_CASE` | Refund, cancellation, void, partial refund |
| `NO_SHOW_DEPOSIT_CASE` | Waiting, reservation, pickup, deposit, penalty |
| `ALCOHOL_VERIFICATION_CASE` | Adult confirmation, ID check, alcohol refusal |
| `PRIVACY_CONSENT_CASE` | Terms, privacy, marketing, withdrawal |
| `FOOD_SAFETY_CASE` | Allergen, raw food, hygiene, storage |
| `PAYMENT_ERROR_CASE` | Duplicate payment, PG/VAN error, mismatch |
| `COUPON_POINT_EVENT_CASE` | Coupon, point, event, gift, abuse |
| `REVIEW_CONTENT_CASE` | Review, copyright, moderation, deletion |
| `DEVICE_HARDWARE_CASE` | Tablet, kiosk, QR, printer, damage |
| `STORE_FACILITY_CASE` | CCTV, parking, pet, child, facility |
| `STAFF_PROTECTION_CASE` | Abuse, harassment, refusal, removal |
| `DISASTER_EXCEPTION_CASE` | Outage, force majeure, emergency |
| `I18N_TRANSLATION_CASE` | Translation, fallback, language confusion |
| `EVIDENCE_GAP_CASE` | Missing notice/version/ack evidence |
| `GENERAL_NOTICE_CASE` | General legal notice inquiry |

Case family determines reason code and evidence packet.

---

## 5. Support Case Lifecycle

Recommended lifecycle:

| State | Meaning |
|---|---|
| `CASE_OPENED` | Case created |
| `CASE_TRIAGE_PENDING` | Waiting for classification |
| `EVIDENCE_LOADING` | Evidence being collected |
| `EVIDENCE_COMPLETE` | Required evidence available |
| `EVIDENCE_GAP_FOUND` | Missing evidence found |
| `STORE_RESPONSE_PENDING` | Store response needed |
| `CUSTOMER_RESPONSE_PENDING` | Customer response needed |
| `SUPPORT_DECISION_PENDING` | Support decision needed |
| `MANAGER_APPROVAL_PENDING` | Manager approval needed |
| `HQ_ESCALATION_PENDING` | HQ escalation needed |
| `LEGAL_ESCALATION_PENDING` | Legal/compliance needed |
| `PAYMENT_RECONCILIATION_PENDING` | Payment reconciliation needed |
| `DECISION_RECORDED` | Decision recorded |
| `CUSTOMER_NOTIFIED` | Customer notified |
| `CASE_CLOSED` | Case closed |
| `CASE_REOPENED` | Reopened |
| `LEGAL_HOLD_APPLIED` | Legal hold applied |

Case closure requires decision and audit.

---

## 6. Universal Support Evidence Checklist

Every support case should check:

| Evidence | Required When |
|---|---|
| Tenant and store scope | Always |
| Customer/session reference | Always if available |
| Order ID | Order-related case |
| Payment ID | Payment-related case |
| Notice ID and version | Notice-related case |
| Locale and text hash | High-risk notice case |
| Surface shown | Notice-related case |
| Trigger reason | Triggered notice case |
| Acknowledgement | Consent/confirmation case |
| Store setting snapshot | Store policy case |
| POS state | POS-related case |
| KDS state | Refund/cancel case |
| Provider callback | Payment case |
| Support history | Reopened/escalated case |
| Export/masking profile | Export case |
| Audit reference | Always |

Support must surface missing evidence explicitly.

---

## 7. Reason Code Structure

Recommended reason code structure:

    <CASE_FAMILY>.<DOMAIN>.<REASON>

Examples:

| Reason Code | Meaning |
|---|---|
| `REFUND_CANCEL.CUSTOMER.CHANGED_MIND` | Customer changed mind |
| `REFUND_CANCEL.STORE.SOLD_OUT` | Store sold out |
| `NO_SHOW.RESERVATION.LATE_ARRIVAL` | Late arrival |
| `ALCOHOL.ID.NO_VALID_ID` | No valid ID |
| `PRIVACY.MARKETING.AFTER_WITHDRAWAL` | Marketing after withdrawal |
| `FOOD_SAFETY.ALLERGEN.NOTICE_DISPUTE` | Allergen notice dispute |
| `PAYMENT.PROVIDER.DUPLICATE_CHARGE` | Duplicate payment |
| `COUPON.ABUSE.MULTI_ACCOUNT` | Multi-account abuse |
| `REVIEW.CONTENT.COPYRIGHT_REPORT` | Copyright report |
| `DEVICE.DAMAGE.TABLET_DAMAGE` | Tablet damage |
| `DISASTER.OUTAGE.ORDER_CANCELLED` | Outage cancellation |
| `I18N.TRANSLATION.FALLBACK_CONFUSION` | Fallback confusion |
| `EVIDENCE.MISSING.ACK_REQUIRED` | Required ack missing |

Reason codes must be controlled and auditable.

---

## 8. Refund Cancellation Case Playbook

Refund/cancellation support should check:

1. Order state.
2. KDS state.
3. POS state.
4. Payment state.
5. Refund/cancel notice version.
6. Whether notice was shown before irreversible point.
7. Whether acknowledgement was required and captured.
8. Customer cancel request time.
9. Kitchen accepted/prep started/completed time.
10. Store mistake or customer mistake classification.
11. Sold-out/substitution history.
12. Coupon/point reversal state.
13. Authority needed for decision.

Recommended reason codes:

| Code | Meaning |
|---|---|
| `REFUND_CANCEL.CUSTOMER.CHANGED_MIND` | Simple change of mind |
| `REFUND_CANCEL.CUSTOMER.ORDER_MISTAKE` | Wrong menu/option/quantity |
| `REFUND_CANCEL.STORE.SOLD_OUT` | Sold out |
| `REFUND_CANCEL.STORE.WRONG_ITEM` | Wrong item |
| `REFUND_CANCEL.STORE.MISSING_ITEM` | Missing item |
| `REFUND_CANCEL.STORE.QUALITY_ISSUE` | Quality issue |
| `REFUND_CANCEL.SYSTEM.DUPLICATE_ORDER` | Duplicate system order |
| `REFUND_CANCEL.PAYMENT.PROVIDER_ERROR` | Payment provider issue |
| `REFUND_CANCEL.KDS.CANCEL_LOCKED` | KDS state locks cancel |
| `REFUND_CANCEL.POLICY.NOTICE_MISSING` | Missing policy notice |

AI may suggest classification.

AI cannot approve or reject refund.

---

## 9. No-Show Deposit Case Playbook

No-show/deposit support should check:

1. Reservation or waiting record.
2. Deposit payment state.
3. No-show notice version.
4. Cancellation cutoff.
5. Grace period.
6. Notification logs.
7. Arrival timestamp if any.
8. Store action timestamp.
9. Penalty/deposit forfeiture rule.
10. Owner/HQ override authority.
11. Customer recovery policy.
12. Evidence completeness.

Recommended reason codes:

| Code | Meaning |
|---|---|
| `NO_SHOW.WAITING.CALL_EXPIRED` | Waiting call expired |
| `NO_SHOW.RESERVATION.LATE_ARRIVAL` | Late arrival |
| `NO_SHOW.RESERVATION.NO_ARRIVAL` | No arrival |
| `NO_SHOW.PICKUP.NOT_COLLECTED` | Pickup not collected |
| `NO_SHOW.DEPOSIT.FORFEITURE_DISPUTE` | Deposit forfeiture dispute |
| `NO_SHOW.NOTIFICATION.NOT_RECEIVED` | Customer claims no notification |
| `NO_SHOW.STORE.GRACE_TOO_SHORT` | Grace period dispute |
| `NO_SHOW.EVIDENCE.TIMESTAMP_MISSING` | Timestamp missing |
| `NO_SHOW.POLICY.NOTICE_MISSING` | No-show notice missing |

No-show penalty must be evidence-heavy.

---

## 10. Alcohol Verification Case Playbook

Alcohol support should check:

1. Alcohol item classification.
2. Adult confirmation notice version.
3. Adult confirmation timestamp.
4. Staff ID verification requirement.
5. Staff verification result.
6. Staff actor.
7. ID category checked without raw ID exposure.
8. Refusal reason.
9. Payment/refund action.
10. Proxy purchase risk.
11. Delivery/pickup restriction.
12. Incident escalation if conflict occurred.

Recommended reason codes:

| Code | Meaning |
|---|---|
| `ALCOHOL.ID.NO_VALID_ID` | No valid ID |
| `ALCOHOL.ID.UNDERAGE` | Underage |
| `ALCOHOL.ID.REFUSED_CHECK` | Refused ID check |
| `ALCOHOL.ID.SUSPECTED_FAKE` | Suspected fake ID |
| `ALCOHOL.PROXY.SUSPECTED` | Proxy purchase suspected |
| `ALCOHOL.DELIVERY.BLOCKED` | Delivery blocked |
| `ALCOHOL.PICKUP.VERIFICATION_FAILED` | Pickup verification failed |
| `ALCOHOL.SET.COMPONENT_REMOVED` | Alcohol component removed |
| `ALCOHOL.REFUND.ID_FAILURE` | Refund due to ID failure |
| `ALCOHOL.EVIDENCE.STAFF_CHECK_MISSING` | Staff check evidence missing |

Alcohol cases require conservative escalation when unclear.

---

## 11. Privacy Consent Case Playbook

Privacy support should check:

1. Consent type.
2. Required/optional classification.
3. Notice version.
4. Locale and text hash.
5. Consent accepted/refused.
6. Withdrawal timestamp.
7. Marketing channel scope.
8. Third-party provision recipient.
9. Retention period.
10. Data usage purpose.
11. Customer request type.
12. Export/delete authority.

Recommended reason codes:

| Code | Meaning |
|---|---|
| `PRIVACY.CONSENT.REQUIRED_MISSING` | Required consent missing |
| `PRIVACY.CONSENT.OPTIONAL_BUNDLED` | Optional bundled with required |
| `PRIVACY.MARKETING.NO_CONSENT` | Marketing without consent |
| `PRIVACY.MARKETING.AFTER_WITHDRAWAL` | Sent after withdrawal |
| `PRIVACY.LOCATION.NO_SCOPE` | Location scope dispute |
| `PRIVACY.THIRD_PARTY.RECIPIENT_DISPUTE` | Third-party provision dispute |
| `PRIVACY.WITHDRAWAL.DELETE_REQUEST` | Withdrawal/delete request |
| `PRIVACY.I18N.UNAPPROVED_TRANSLATION` | Translation issue |
| `PRIVACY.EVIDENCE.VERSION_MISSING` | Version missing |

Privacy cases may require privacy/legal escalation.

---

## 12. Food Safety Case Playbook

Food safety support should check:

1. Menu item snapshot.
2. Ingredient/allergen tags at time.
3. Notice version and locale.
4. Menu surface where shown.
5. Customer option/exclusion request.
6. Staff confirmation if any.
7. Raw food/freshness notice.
8. Pickup/delivery time.
9. Storage/reheating notice.
10. Incident report.
11. Store response.
12. QC/legal escalation need.

Recommended reason codes:

| Code | Meaning |
|---|---|
| `FOOD_SAFETY.ALLERGEN.NOTICE_DISPUTE` | Allergen notice dispute |
| `FOOD_SAFETY.ALLERGEN.EXCLUSION_FAILED` | Exclusion request failed |
| `FOOD_SAFETY.RAW_FOOD.WARNING_DISPUTE` | Raw food warning dispute |
| `FOOD_SAFETY.FRESHNESS.PICKUP_DELAY` | Pickup freshness issue |
| `FOOD_SAFETY.STORAGE.TAKEOUT_COMPLAINT` | Storage complaint |
| `FOOD_SAFETY.QUALITY.FOREIGN_OBJECT` | Foreign object |
| `FOOD_SAFETY.QUALITY.SPOILAGE` | Spoilage complaint |
| `FOOD_SAFETY.EVIDENCE.MENU_SNAPSHOT_MISSING` | Menu snapshot missing |
| `FOOD_SAFETY.EVIDENCE.NOTICE_MISSING` | Notice missing |

Food safety cases should escalate if health risk is claimed.

---

## 13. Payment Error Case Playbook

Payment support should check:

1. Payment intent.
2. Provider callback.
3. Authorization state.
4. Capture state.
5. Refund state.
6. Order state.
7. POS state.
8. Duplicate payment possibility.
9. Split payment balance.
10. Receipt state.
11. Reconciliation state.
12. Provider escalation route.

Recommended reason codes:

| Code | Meaning |
|---|---|
| `PAYMENT.PROVIDER.DUPLICATE_CHARGE` | Duplicate charge |
| `PAYMENT.PROVIDER.AUTH_ONLY` | Authorization only |
| `PAYMENT.PROVIDER.CAPTURE_FAILED` | Capture failed |
| `PAYMENT.PROVIDER.REFUND_PENDING` | Refund pending |
| `PAYMENT.POS.MISMATCH` | POS mismatch |
| `PAYMENT.ORDER.NOT_CREATED` | Payment succeeded, order missing |
| `PAYMENT.ORDER.UNPAID_ACCEPTED` | Order accepted, payment missing |
| `PAYMENT.SPLIT.BALANCE_MISMATCH` | Split balance mismatch |
| `PAYMENT.RECEIPT.NOT_AVAILABLE` | Receipt issue |
| `PAYMENT.RECONCILIATION.REQUIRED` | Reconciliation required |

Unknown provider state must not be treated as success or failure.

---

## 14. Coupon Point Event Case Playbook

Coupon/point/event support should check:

1. Coupon/event policy version.
2. Coupon validity.
3. Expiry.
4. Store/franchise scope.
5. Stacking rule.
6. First-order rule.
7. Screenshot invalid rule.
8. Point used/earned.
9. Refund reversal state.
10. Abuse flags.
11. Customer notice shown.
12. Support authority.

Recommended reason codes:

| Code | Meaning |
|---|---|
| `COUPON.EXPIRY.EXPIRED` | Expired coupon |
| `COUPON.STACKING.NOT_ALLOWED` | Stacking not allowed |
| `COUPON.SCOPE.STORE_ONLY` | Store-only coupon |
| `COUPON.SCREENSHOT.INVALID` | Screenshot invalid |
| `COUPON.FIRST_ORDER.NOT_ELIGIBLE` | First-order not eligible |
| `COUPON.REFUND.REVERSAL_DISPUTE` | Benefit reversal dispute |
| `POINT.ACCRUAL.MISSING` | Point accrual missing |
| `POINT.REVERSAL.REFUND` | Point reversed after refund |
| `EVENT.GIFT.NO_CASH_EXCHANGE` | Gift exchange/cash dispute |
| `COUPON.ABUSE.MULTI_ACCOUNT` | Multi-account abuse |

Coupon notice must match coupon engine behavior.

---

## 15. Review Content Case Playbook

Review/content support should check:

1. Review eligibility.
2. Review notice version.
3. Content submitted.
4. Photo/copyright notice.
5. Portrait rights notice.
6. Profanity/moderation flags.
7. Review event rule.
8. Store reply.
9. Deletion request.
10. Rights infringement report.
11. Moderation decision.
12. Appeal/escalation route.

Recommended reason codes:

| Code | Meaning |
|---|---|
| `REVIEW.ELIGIBILITY.NOT_PURCHASER` | Not eligible |
| `REVIEW.CONTENT.PROFANITY` | Profanity issue |
| `REVIEW.CONTENT.COPYRIGHT_REPORT` | Copyright report |
| `REVIEW.CONTENT.PORTRAIT_RIGHTS` | Portrait rights |
| `REVIEW.EVENT.REWARD_DISPUTE` | Review event reward dispute |
| `REVIEW.DELETE.NON_RESTORE` | Deleted review non-restoration |
| `REVIEW.MODERATION.REMOVED` | Removed by moderation |
| `REVIEW.STORE.REPLY_DISPUTE` | Store reply dispute |
| `REVIEW.RIGHTS.INFRINGEMENT_REPORT` | Rights report |
| `REVIEW.EVIDENCE.NOTICE_MISSING` | Notice evidence missing |

Review handling must not suppress legitimate criticism.

---

## 16. Device Hardware Case Playbook

Device/hardware support should check:

1. Device ID.
2. Table/kiosk ID.
3. Device notice version.
4. Session/order reference.
5. Incident time.
6. Staff report.
7. Device state before/after.
8. Photo evidence if permitted.
9. Repair estimate if claimed.
10. Customer response.
11. Store manager decision.
12. Support/HQ escalation.

Recommended reason codes:

| Code | Meaning |
|---|---|
| `DEVICE.TABLET.DAMAGE` | Tablet damage |
| `DEVICE.KIOSK.DAMAGE` | Kiosk damage |
| `DEVICE.PRINTER.RECEIPT_FAIL` | Receipt/printer failure |
| `DEVICE.QR.EXTERNAL_LINK_CONFUSION` | QR/external link issue |
| `DEVICE.TIMEOUT.ORDER_LOSS` | Timeout issue |
| `DEVICE.NETWORK.ORDER_DELAY` | Network delay |
| `DEVICE.EVIDENCE.NOTICE_MISSING` | Device notice missing |
| `DEVICE.EVIDENCE.INCIDENT_MISSING` | Incident evidence missing |

Device claims must remain fair and evidence-based.

---

## 17. Disaster Exception Case Playbook

Disaster/exception support should check:

1. Incident record.
2. Incident type.
3. Affected orders.
4. Force majeure notice version.
5. Customer notification time.
6. Store action.
7. Payment/refund state.
8. Delay/cancel reason.
9. Support guidance at time.
10. Recovery state.
11. Postmortem if high severity.

Recommended reason codes:

| Code | Meaning |
|---|---|
| `DISASTER.POWER.OUTAGE` | Power outage |
| `DISASTER.WATER.OUTAGE` | Water outage |
| `DISASTER.WEATHER.FORCE_MAJEURE` | Weather disaster |
| `DISASTER.SERVER.OVERLOAD` | Server overload |
| `DISASTER.KITCHEN.EQUIPMENT_FAILURE` | Kitchen equipment failure |
| `DISASTER.FIRE.EVACUATION` | Fire/evacuation |
| `DISASTER.INGREDIENT.SHORTAGE` | Ingredient shortage |
| `DISASTER.REFUND.DELAYED` | Refund delayed |
| `DISASTER.EVIDENCE.NOTICE_MISSING` | Notice missing |

Disaster notice must not overclaim immunity.

---

## 18. i18n Translation Case Playbook

i18n support should check:

1. Customer locale.
2. Notice version.
3. Translation state.
4. Fallback state.
5. Korean controlling text.
6. Text hash.
7. Customer misunderstanding claim.
8. Translation review queue state.
9. Support language route.
10. Re-notice/re-consent need.

Recommended reason codes:

| Code | Meaning |
|---|---|
| `I18N.TRANSLATION.MEANING_MISMATCH` | Meaning mismatch |
| `I18N.TRANSLATION.MISSING` | Missing translation |
| `I18N.FALLBACK.CONFUSION` | Fallback confusion |
| `I18N.KOREAN.CONTROLLING_TEXT_DISPUTE` | Korean controlling text dispute |
| `I18N.VARIABLE.FORMATTING_ERROR` | Variable formatting issue |
| `I18N.MACHINE_DRAFT.EXPOSED` | Machine draft exposed |
| `I18N.EVIDENCE.LOCALE_MISSING` | Locale missing |

Translation disputes may require i18n/legal review.

---

## 19. Evidence Gap Case Playbook

Evidence gap support should check:

1. Expected evidence.
2. Missing field.
3. Case family.
4. Risk class.
5. Whether flow should have been blocked.
6. Whether compliance incident is needed.
7. Whether emergency review is needed.
8. Whether affected orders exist.
9. Whether support can decide with remaining evidence.
10. Whether legal/HQ escalation is required.

Recommended reason codes:

| Code | Meaning |
|---|---|
| `EVIDENCE.MISSING.NOTICE_VERSION` | Notice version missing |
| `EVIDENCE.MISSING.LOCALE` | Locale missing |
| `EVIDENCE.MISSING.SURFACE` | Surface missing |
| `EVIDENCE.MISSING.SHOWN_AT` | Shown timestamp missing |
| `EVIDENCE.MISSING.ACK_REQUIRED` | Required ack missing |
| `EVIDENCE.MISSING.ORDER_LINK` | Order link missing |
| `EVIDENCE.MISSING.PAYMENT_LINK` | Payment link missing |
| `EVIDENCE.MISSING.KDS_STATE` | KDS state missing |
| `EVIDENCE.MISSING.STORE_SETTING` | Store setting missing |
| `EVIDENCE.MISSING.AUDIT_REF` | Audit ref missing |

Missing evidence must be surfaced, not hidden.

---

## 20. Decision Types

Recommended support decision types:

| Decision | Meaning |
|---|---|
| `INFORMATION_PROVIDED` | Information only |
| `REFUND_APPROVED` | Refund approved |
| `REFUND_REJECTED` | Refund rejected |
| `PARTIAL_REFUND_APPROVED` | Partial refund approved |
| `REPLACEMENT_APPROVED` | Replacement approved |
| `SUBSTITUTION_APPROVED` | Substitute accepted |
| `COUPON_REISSUED` | Coupon reissued |
| `POINT_ADJUSTED` | Point adjusted |
| `NO_SHOW_PENALTY_MAINTAINED` | Penalty maintained |
| `NO_SHOW_PENALTY_REVERSED` | Penalty reversed |
| `ALCOHOL_ORDER_BLOCK_CONFIRMED` | Alcohol block upheld |
| `PRIVACY_ACTION_COMPLETED` | Privacy request handled |
| `EVIDENCE_GAP_ESCALATED` | Evidence gap escalated |
| `LEGAL_ESCALATED` | Legal escalation |
| `HQ_ESCALATED` | HQ escalation |
| `STORE_ACTION_REQUIRED` | Store action required |
| `RECONCILIATION_REQUIRED` | Payment reconciliation needed |
| `CASE_CLOSED_NO_ACTION` | Closed without action |

Decision must match authority.

---

## 21. Authority Matrix

Recommended support authority:

| Action | Support Agent | Support Manager | Store Owner | HQ | Legal/Compliance |
|---|---:|---:|---:|---:|---:|
| Provide notice explanation | Yes | Yes | Yes scoped | Yes scoped | Yes |
| View case evidence | Yes scoped | Yes scoped | Store scoped | Tenant scoped | Yes |
| Approve small refund | Limited | Yes | Store policy | HQ policy | Yes |
| Approve large refund | No | Limited | Owner | HQ | Yes |
| Reverse no-show penalty | No/Limited | Limited | Owner/HQ | Yes | Yes |
| Decide privacy request | No | No | No | Limited | Yes |
| Decide alcohol legal dispute | No | Limited | Store/HQ scoped | Yes | Yes |
| Export evidence | No | Limited | No | Limited | Yes |
| Apply legal hold | No | No | No | Limited | Yes |
| Modify notice setting | No | No | Store admin flow only | HQ flow | Legal/admin flow |
| Mutate evidence | No | No | No | No | No |

Support authority must be amount- and risk-limited.

---

## 22. Customer Response Boundary

Support responses must:

- be factual
- reference policy without overclaiming
- avoid legal conclusions unless approved
- avoid blaming customer without evidence
- avoid promising refund before authority
- avoid admitting liability without review
- explain next steps
- provide escalation route
- use approved templates for high-risk cases
- respect customer language
- not expose internal evidence details unnecessarily

Customer response is part of compliance record.

---

## 23. Store Response Boundary

Store response requests should include:

- case summary
- evidence needed
- deadline
- allowed response types
- prohibited unsupported claims
- photo/report upload guidance
- refund/replacement options
- escalation route

Store response must not overwrite evidence.

---

## 24. Escalation Rules

Escalate to HQ/legal/privacy/payment/QC when:

- privacy data request
- alcohol minor/ID dispute
- allergen or health complaint
- repeated refund dispute pattern
- no-show deposit legal challenge
- large refund amount
- payment reconciliation mismatch
- missing critical evidence
- translation legal confusion
- staff abuse incident
- legal threat
- regulator inquiry
- media/social escalation
- franchise policy conflict

Escalation must be recorded.

---

## 25. Support AI Assistant Boundary

AI may help support by:

- summarizing evidence packets
- suggesting case family
- suggesting reason code
- identifying missing evidence
- drafting customer response for review
- identifying escalation need
- comparing current notice and historical version
- clustering similar disputes
- flagging policy mismatch
- translating support guidance draft

AI must not:

- send final response without approval where restricted
- approve refund
- reject refund
- reverse penalty
- decide privacy request
- approve alcohol dispute
- modify evidence
- close legal case
- apply legal hold
- suppress escalation
- fabricate missing evidence

AI is support assistant only.

---

## 26. Support Audit Events

Recommended events:

| Event Type | Meaning |
|---|---|
| `SUPPORT_CASE_OPENED` | Case opened |
| `SUPPORT_CASE_CLASSIFIED` | Case family/reason assigned |
| `SUPPORT_EVIDENCE_VIEWED` | Evidence viewed |
| `SUPPORT_EVIDENCE_GAP_FOUND` | Missing evidence found |
| `SUPPORT_REASON_CODE_CHANGED` | Reason code changed |
| `SUPPORT_STORE_RESPONSE_REQUESTED` | Store response requested |
| `SUPPORT_CUSTOMER_RESPONSE_SENT` | Customer response sent |
| `SUPPORT_REFUND_DECISION_RECORDED` | Refund decision |
| `SUPPORT_NO_SHOW_DECISION_RECORDED` | No-show decision |
| `SUPPORT_PRIVACY_ESCALATED` | Privacy escalation |
| `SUPPORT_ALCOHOL_ESCALATED` | Alcohol escalation |
| `SUPPORT_LEGAL_ESCALATED` | Legal escalation |
| `SUPPORT_HQ_ESCALATED` | HQ escalation |
| `SUPPORT_PAYMENT_RECONCILIATION_REQUESTED` | Payment reconciliation |
| `SUPPORT_CASE_CLOSED` | Case closed |
| `SUPPORT_CASE_REOPENED` | Reopened |

Events must route through `10610`.

---

## 27. Security Boundary

Support playbook is security-sensitive.

Rules:

- support access must be case-scoped
- evidence access must be audited
- privacy data must be masked
- alcohol ID details must be minimized
- payment provider data must be protected
- legal notes may be restricted
- store owner view must be scoped
- HQ view must be tenant/franchise-scoped
- export requires authority
- support cannot edit evidence
- support cannot edit notice settings
- AI cannot decide or mutate
- case closure must be audited

Support workflows must preserve both fairness and compliance.

---

## 28. Anti-Patterns

Avoid:

- handling disputes from memory
- using current notice text for historical dispute
- free-text reason without controlled code
- approving refund without payment state
- denying refund without KDS/order evidence
- applying no-show penalty without timestamp evidence
- defending alcohol refusal without staff verification evidence
- ignoring privacy withdrawal evidence
- ignoring translation confusion
- hiding missing evidence
- letting support edit legal notice settings
- letting support mutate acknowledgement records
- letting AI decide cases
- exporting unmasked evidence casually
- closing high-risk cases without escalation

These anti-patterns must be blocked in future runtime design.

---

## 29. Runtime Deferral

This document defines legal notice support playbook and case reason code governance only.

It does not authorize:

- support console implementation
- case reason code database implementation
- AI support assistant implementation
- evidence packet runtime
- refund decision runtime
- no-show penalty runtime
- privacy request runtime
- payment reconciliation runtime
- customer response automation
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 30. Validation Checklist

Validation must confirm:

1. Support case families are defined.
2. Support case lifecycle is defined.
3. Universal support evidence checklist is defined.
4. Reason code structure is defined.
5. Refund/cancellation case playbook is defined.
6. No-show/deposit case playbook is defined.
7. Alcohol verification case playbook is defined.
8. Privacy consent case playbook is defined.
9. Food safety case playbook is defined.
10. Payment error case playbook is defined.
11. Coupon/point/event case playbook is defined.
12. Review/content case playbook is defined.
13. Device/hardware case playbook is defined.
14. Disaster/exception case playbook is defined.
15. i18n/translation case playbook is defined.
16. Evidence gap case playbook is defined.
17. Decision types are defined.
18. Authority matrix is defined.
19. Customer response boundary is defined.
20. Store response boundary is defined.
21. Escalation rules are defined.
22. Support AI assistant boundary is defined.
23. Support audit events are defined.
24. Security boundary is defined.
25. Anti-patterns are listed.
26. Coding remains unauthorized.
27. Runtime remains deferred.

---

## 31. Relationship To Previous Documents

This document supplements:

- `10716 Legal Notice Master Toggle Disclosure Consent And Compliance Governance Policy`
- `10717 Legal Notice Master Data Usage Flow And Runtime Retrieval Governance Policy`
- `10718 Legal Notice Master Data Table Static Specification Policy`
- `10719 Legal Notice Trigger Matrix And UI Surface Mapping Policy`
- `10720 Privacy Consent Evidence Packet And Retention Policy`
- `10721 Alcohol Age Gate Legal Notice And Staff Verification SOP Policy`
- `10722 Refund Cancellation No-Show Notice And Dispute Evidence SOP Policy`
- `10723 Legal Notice i18n Review And Controlled Translation Policy`
- `10724 Legal Notice Admin Toggle Permission And HQ Lock Policy`
- `10725 Legal Notice Static Seed Review And Approval Workflow Policy`
- `10726 Legal Notice Evidence Export Support And Dispute Packet Policy`
- `10727 Legal Notice Customer Display UX And Popup Fatigue Control Policy`
- `10728 Legal Notice Emergency Lock And Regulatory Change Response Policy`
- `10729 Legal Notice Static Registry Closure And Runtime Deferral Policy`
- `10730 Legal Notice Evidence Packet Static Field Map Policy`
- `10731 Customer Notice Center UX Static Surface Index Policy`
- `10732 Regulatory Change Watchlist And Legal Notice Review Queue Policy`
- `10733 Legal Notice Admin Checklist And Store Onboarding Review Policy`

It also references:

- `10410 Payment Intent And Authorization Boundary Policy`
- `10420 Payment Confirmation And Provider Callback Boundary Policy`
- `10430 Refund Cancellation And Void Boundary Policy`
- `10440 Coupon Point Wallet And Stored Value Boundary Policy`
- `10450 Settlement Allocation And Reconciliation Boundary Policy`
- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`

It prepares possible future documents:

- `10735 Legal Notice Static Registry Readiness Check Policy`
- `10736 Legal Notice Implementation Authorization Draft Policy`
- `10800 Store Onboarding And Sales Setup Axis Index`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 32. Final Rule

Catch Menu support must handle legal notice disputes through controlled case families, reason codes, evidence packets, authority boundaries, escalation rules, and audit events.

Support must not guess, rewrite, or fabricate evidence.

Support must not use current legal notice text to explain historical customer actions.

Support must verify notice version, locale, surface, trigger, acknowledgement, store setting, order state, payment state, KDS/POS state, and support authority before decision.

AI may assist support classification, summarization, and draft preparation.

AI cannot approve refunds, deny refunds, reverse penalties, decide privacy requests, approve alcohol disputes, mutate evidence, or close high-risk legal cases.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.