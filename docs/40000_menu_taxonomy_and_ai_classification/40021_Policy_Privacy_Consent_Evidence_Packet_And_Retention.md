# 40021_Policy_Privacy_Consent_Evidence_Packet_And_Retention

## 1. Purpose

This document defines the Privacy Consent Evidence Packet and Retention Policy for Catch Menu.

The previous document `40020 Legal Notice Trigger Matrix And UI Surface Mapping Policy` defined how legal notices are triggered and shown across UI surfaces.

This document focuses on privacy-related consent evidence:

- service terms consent
- personal data collection and use consent
- third-party provision consent
- personal data processing outsourcing notice
- marketing consent
- advertising message receipt consent
- push/SMS/email consent
- location-based service consent
- app permission notice
- non-member order data consent
- withdrawal and deletion notice
- dormant/inactive account notice
- breach notification evidence
- consent version retention
- consent withdrawal evidence

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Privacy consent is not a checkbox alone.

The correct rule is:

Consent text must be versioned.  
Consent must be separated by purpose.  
Required consent and optional consent must not be bundled.  
Marketing consent must be separately withdrawable.  
Location consent must be feature-scoped.  
Third-party provision must identify recipient, purpose, items, and retention.  
Outsourcing notice must identify processor and task.  
Consent evidence must record the exact version shown.  
Withdrawal must not erase historical consent evidence.  
Personal data retention must follow purpose, law, and deletion policy.  
Support cannot alter consent evidence.  

Privacy consent is a controlled evidence system.

---

## 3. Scope

This policy applies to:

- member signup
- non-member order
- table order customer session
- app order
- waiting registration
- reservation
- pickup notification
- payment and receipt delivery
- coupon and membership
- marketing push/SMS/email
- location-based store recommendation
- review writing
- customer support
- account withdrawal
- dormant/inactive account handling
- privacy policy version change
- data breach notification
- consent evidence retention
- consent withdrawal

This policy defines governance only.

It is not a legal opinion.

---

## 4. Privacy Consent Types

Recommended consent types:

| Consent Code | Meaning |
|---|---|
| `TERMS_OF_SERVICE_REQUIRED` | Required service terms |
| `PRIVACY_COLLECTION_REQUIRED` | Required personal data collection/use |
| `THIRD_PARTY_PROVISION_REQUIRED` | Required third-party provision |
| `NON_MEMBER_ORDER_PRIVACY` | Non-member order data use |
| `LOCATION_SERVICE_OPTIONAL` | Location-based service |
| `MARKETING_USE_OPTIONAL` | Marketing purpose data use |
| `AD_PUSH_OPTIONAL` | Advertising push notification |
| `AD_SMS_OPTIONAL` | Advertising SMS |
| `AD_EMAIL_OPTIONAL` | Advertising email |
| `APP_PERMISSION_NOTICE` | App permission notice |
| `COOKIE_LOG_NOTICE` | Log/cookie collection notice |
| `PROCESSING_OUTSOURCING_NOTICE` | Processing outsourcing notice |
| `OVERSEAS_TRANSFER_NOTICE` | Overseas/cloud transfer notice |
| `WITHDRAWAL_DELETE_NOTICE` | Withdrawal/deletion notice |
| `DORMANT_ACCOUNT_NOTICE` | Dormant/inactive account notice |
| `BREACH_NOTIFICATION_NOTICE` | Breach notification notice |

Each consent must have its own purpose and evidence.

---

## 5. Required Versus Optional Consent Boundary

Consent must be separated.

| Type | Blocking Behavior |
|---|---|
| Required service terms | Can block signup/service |
| Required privacy collection/use | Can block signup/order if necessary |
| Required third-party provision | Can block order/payment if necessary |
| Non-member order privacy | Can block non-member order |
| Location service | Must not block core service unless feature requires it |
| Marketing use | Must not block core service |
| Advertising push/SMS/email | Must not block core service |
| App permission | Feature-specific; OS-level permission separate |
| Cookie/log notice | Usually notice, not explicit consent unless required |
| Outsourcing notice | Notice/review; not always checkbox |
| Overseas transfer | Requires applicable review and consent/notice policy |

Optional refusal must be respected.

---

## 6. Consent Evidence Packet

When consent is collected, the evidence packet should include:

| Field | Meaning |
|---|---|
| `consent_evidence_id` | Unique evidence ID |
| `tenant_id` | Tenant |
| `store_id` | Store if store-scoped |
| `customer_id` | Customer if member |
| `session_id` | Session |
| `device_id` | Device |
| `surface_id` | Signup, checkout, settings, etc. |
| `consent_type` | Consent code |
| `notice_id` | Legal notice master |
| `notice_version_id` | Exact version |
| `locale` | Language shown |
| `text_hash` | Hash of shown text |
| `shown_at` | When shown |
| `consented_at` | When consented |
| `consent_method` | Checkbox, button, OS permission, staff confirm |
| `required_flag` | Required/optional |
| `accepted` | True/false |
| `withdrawn_at` | Withdrawal time if later withdrawn |
| `withdrawal_method` | App settings, support, email, etc. |
| `source_ip_hash` | Optional privacy-safe network evidence |
| `user_agent_hash` | Optional device evidence |
| `retention_class` | Retention class |
| `audit_ref` | Audit reference |

Evidence must be append-only.

---

## 7. Consent Version Snapshot Rule

Consent evidence must reference:

- notice ID
- notice version ID
- consent type
- locale
- text hash
- time shown
- time accepted or refused
- surface
- customer/session
- policy version

The system must not rely on current notice text to explain past consent.

When text changes materially, new consent or re-notice policy may be required.

---

## 8. Consent Method Candidates

Recommended consent methods:

| Method | Meaning |
|---|---|
| `CHECKBOX` | User checked box |
| `MULTI_CHECKBOX` | Multiple purpose-specific checkboxes |
| `BUTTON_CONFIRM` | Confirm button |
| `TOGGLE_ON` | User toggled setting ON |
| `TOGGLE_OFF` | User toggled setting OFF |
| `OS_PERMISSION_GRANTED` | OS-level permission granted |
| `OS_PERMISSION_DENIED` | OS-level permission denied |
| `STAFF_ASSISTED` | Staff-assisted consent |
| `SUPPORT_REQUEST` | Consent/withdrawal through support |
| `MIGRATION_NOTICE` | Legacy migration notice |
| `SYSTEM_NOTICE_ONLY` | Notice shown, no consent |

---

## 9. Signup Consent Flow

Signup flow should separate:

1. Service terms.
2. Required privacy collection and use.
3. Required third-party provision if needed.
4. Optional location service.
5. Optional marketing use.
6. Optional advertising channel consent.
7. App permission guidance after feature access.

Required and optional consent must be visually separated.

Optional refusal must not prevent signup unless the refused feature is necessary.

---

## 10. Non-Member Order Privacy Flow

Non-member order may collect minimal data.

Required handling:

| Item | Requirement |
|---|---|
| Phone number | Only if needed for order notification |
| Name/nickname | Optional unless needed |
| Table/session ID | Operational context |
| Payment data | Payment provider scoped |
| Retention | Minimal and purpose-limited |
| Consent | Shown at order or checkout |
| Deletion | After purpose/legal retention ends |

Non-member data must not silently become marketing data.

---

## 11. Third-Party Provision Flow

Third-party provision consent must identify:

| Field | Meaning |
|---|---|
| recipient | Store, PG, delivery provider, notification provider |
| provided_items | Name, phone, order, payment reference, etc. |
| purpose | Order processing, payment, delivery, notification |
| retention_period | Recipient retention |
| required_or_optional | Consent status |
| withdrawal_effect | What happens if refused |
| version | Text version |

Third-party provision must be specific.

Generic blanket consent is weak.

---

## 12. Processing Outsourcing Notice Flow

Outsourcing notice must identify:

- processor
- task
- data handled
- security responsibility
- retention or destruction policy
- change notice route
- policy link

Examples:

- SMS provider
- push notification provider
- cloud hosting provider
- customer support tool
- payment support processor
- analytics processor if applicable

Outsourcing notice may be displayed in privacy policy and admin/legal center.

---

## 13. Marketing Consent Flow

Marketing consent must be granular.

Recommended channel split:

| Consent | Channel |
|---|---|
| `AD_PUSH_OPTIONAL` | App push |
| `AD_SMS_OPTIONAL` | SMS |
| `AD_EMAIL_OPTIONAL` | Email |
| `AD_KAKAO_OPTIONAL` | Kakao/AlimTalk marketing if applicable |
| `PERSONALIZED_OFFER_OPTIONAL` | Personalized benefit recommendation |

Marketing consent must include:

- purpose
- items used
- channel
- withdrawal method
- optional status
- refusal consequence
- nighttime advertising rule if applicable
- consent timestamp

Marketing consent withdrawal must be easy.

---

## 14. Marketing Withdrawal Flow

Withdrawal flow:

1. Customer opens notification/settings.
2. Customer toggles off channel.
3. System records withdrawal evidence.
4. Marketing delivery list updates.
5. Future marketing send excludes customer/channel.
6. Service-required transactional notices may remain allowed if legally permitted.
7. Support can verify withdrawal time.

Withdrawal must not delete historical consent record.

---

## 15. Location Service Consent Flow

Location consent applies to:

- nearby store search
- distance sorting
- location-based benefits
- pickup/store recommendation
- map navigation
- local event recommendation

Location consent must define:

- precise or approximate location
- collection timing
- purpose
- retention
- third-party map provider if any
- withdrawal method
- service limitation if refused

Location consent should be requested only when feature is used.

---

## 16. App Permission Notice Flow

App permissions may include:

| Permission | Purpose |
|---|---|
| Camera | Menu scan, QR scan, receipt/photo review |
| Location | Nearby store search |
| Notification | Order status, waiting call, coupon |
| Photos | Review image upload |
| Microphone | Usually avoid unless required |
| Bluetooth | Device proximity if used |
| Contacts | Avoid unless absolutely required |

Permission notice must be purpose-limited.

OS permission grant is separate from privacy consent.

---

## 17. Cookie Log And Analytics Notice

Log/cookie notice may include:

- access logs
- device information
- user agent
- session ID
- cookie/local storage
- crash logs
- analytics events
- fraud/abuse prevention
- service improvement

Analytics must respect privacy minimization.

Behavioral advertising requires separate review.

---

## 18. Dormant Or Inactive Account Flow

Dormant/inactive account handling may include:

1. Identify inactivity period.
2. Send pre-notice if required by policy.
3. Separate, delete, or deactivate data according to policy.
4. Record notice evidence.
5. Provide reactivation route if allowed.
6. Preserve legally required transaction records separately.

Dormant handling must not conflict with current law and platform policy.

---

## 19. Withdrawal And Deletion Flow

Withdrawal flow:

1. Customer requests account withdrawal.
2. System shows deletion and retention notice.
3. Customer confirms.
4. Service account is deactivated or deleted.
5. Data eligible for deletion is deleted or anonymized.
6. Legally retained data is separated.
7. Consent evidence is retained as required.
8. Marketing consent is disabled.
9. Customer receives confirmation if applicable.

Withdrawal does not mean all records vanish immediately where legal retention applies.

---

## 20. Breach Notification Evidence Flow

If a data breach occurs, notification evidence should capture:

- incident ID
- affected user/customer
- notification channel
- notification sent time
- notification content version
- affected data categories
- mitigation guidance
- support contact
- regulatory report reference if applicable
- delivery success/failure
- follow-up notice
- audit reference

Breach handling requires separate security incident policy.

---

## 21. Retention Class Mapping

Recommended retention mapping:

| Consent / Evidence Type | Retention Class |
|---|---|
| Service terms consent | `PRIVACY_RETENTION` |
| Required privacy consent | `PRIVACY_RETENTION` |
| Third-party provision consent | `PRIVACY_RETENTION` |
| Non-member order consent | `ORDER_LIFECYCLE` or `PAYMENT_RETENTION` |
| Marketing consent | `PRIVACY_RETENTION` |
| Marketing withdrawal | `PRIVACY_RETENTION` |
| Location consent | `PRIVACY_RETENTION` |
| App permission notice | `PRIVACY_RETENTION` or feature-specific |
| Payment/refund consent | `PAYMENT_RETENTION` |
| Alcohol adult confirmation | `ALCOHOL_RETENTION` |
| Support dispute evidence | `DISPUTE_RETENTION` |
| Legal hold | `LEGAL_HOLD` |

Retention periods require legal review before implementation.

---

## 22. Consent State Registry

Recommended consent states:

| State | Meaning |
|---|---|
| `NOT_SHOWN` | Not shown |
| `SHOWN` | Shown |
| `ACCEPTED` | Accepted |
| `REFUSED` | Refused |
| `WITHDRAWN` | Withdrawn |
| `EXPIRED` | Expired |
| `SUPERSEDED` | Replaced by newer consent |
| `RECONSENT_REQUIRED` | New consent required |
| `BLOCKED` | Flow blocked due to missing required consent |
| `MIGRATED` | Legacy consent migrated |
| `UNKNOWN_REVIEW_REQUIRED` | Unclear state |

Unknown consent must not be treated as accepted.

---

## 23. Consent Query Usage

Runtime should query consent by:

- customer
- session
- consent type
- notice version
- required/optional flag
- channel
- purpose
- tenant/store scope
- effective date
- withdrawal state
- feature context

Example:

- Can send marketing SMS?
  - Must have accepted `AD_SMS_OPTIONAL`
  - Must not be withdrawn
  - Must be within valid policy scope
  - Must respect nighttime sending restriction if applicable

Consent check must be deterministic.

---

## 24. Consent Evidence And Support

Support may need to verify:

- what consent was shown
- what version was shown
- whether user accepted or refused
- when withdrawal occurred
- which channel was covered
- whether marketing message was sent after withdrawal
- whether third-party provision was allowed
- whether non-member order data use was disclosed

Support can view evidence by case scope.

Support cannot change evidence.

---

## 25. Consent And POS Payment Boundary

Privacy consent connects to payment when:

- payment provider receives customer/payment data
- receipt is sent by SMS/email/Kakao
- refund requires contact
- non-member order requires phone number
- table order session maps to payment
- PG/VAN error support needs transaction reference

Payment data use must follow payment and privacy policy.

Do not reuse payment contact for marketing without marketing consent.

---

## 26. Consent And Marketing Coupon Boundary

Marketing/coupon systems must check:

- marketing consent accepted
- channel consent accepted
- not withdrawn
- coupon eligibility
- store/tenant scope
- message purpose
- time restriction
- frequency cap
- opt-out route

Coupon issuance for service operation and advertising message are different.

The system must distinguish them.

---

## 27. Consent And i18n Boundary

Consent text must use approved i18n variants.

Rules:

- show customer's locale when approved
- record locale shown
- record text version
- do not rely on unreviewed machine translation for legal consent
- Korean controlling version may be referenced
- re-consent may be needed when translated meaning changes materially

Consent in the wrong language may weaken evidence.

---

## 28. Consent And Tenant Scope Boundary

Consent must be scoped.

Scope examples:

| Scope | Example |
|---|---|
| Platform | Catch Menu account terms |
| Tenant | Franchise tenant membership |
| Store | Store-specific reservation/no-show |
| Feature | Location, marketing, review |
| Channel | SMS, push, email |
| Purpose | Order, payment, delivery, marketing |
| Third party | PG, delivery provider, store |

Consent for one tenant or purpose must not be reused for unrelated purpose without policy.

---

## 29. Consent Migration Boundary

If legacy consent exists:

1. Identify source.
2. Identify consent text/version if available.
3. Map to new consent types.
4. Mark as migrated.
5. Require re-consent if evidence is insufficient.
6. Do not infer optional marketing consent without evidence.
7. Record migration audit.

Migration must be conservative.

---

## 30. Data Minimization Boundary

Consent does not justify unnecessary collection.

Rules:

- collect only needed fields
- avoid sensitive data unless required
- avoid collecting resident registration number unless legally necessary
- avoid storing full ID image for alcohol unless legally reviewed
- avoid storing raw location history unless needed
- avoid storing payment card data unless handled by certified provider
- avoid using order data for marketing without consent
- avoid indefinite retention

Consent is not a blanket license.

---

## 31. Security Boundary

Privacy consent evidence is sensitive.

Security rules:

- evidence append-only
- role-based access
- support case-scoped view
- export requires authority
- sensitive fields masked
- customer data encrypted where needed
- audit every access to evidence
- reauthentication for bulk export
- tenant isolation mandatory
- deletion/anonymization governed by retention policy

Privacy evidence must be protected like compliance records.

---

## 32. Anti-Patterns

Avoid:

- bundling required and optional consent together
- making marketing consent mandatory for basic service
- reusing order phone number for marketing without consent
- storing consent as one boolean only
- losing notice version
- losing consent purpose
- losing channel distinction
- treating OS push permission as marketing consent
- treating location permission as all-purpose tracking consent
- deleting consent evidence during account withdrawal
- using current privacy text to explain past consent
- using unreviewed machine translation for legal consent
- inferring consent from service use without evidence
- allowing support to edit consent history
- sharing tenant consent across unrelated tenants

These anti-patterns must be blocked in future runtime design.

---

## 33. Runtime Deferral

This document defines privacy consent evidence packet and retention governance only.

It does not authorize:

- privacy consent database implementation
- consent runtime
- marketing consent runtime
- location consent runtime
- app permission runtime
- withdrawal/deletion automation
- dormant account automation
- breach notification runtime
- support console implementation
- export runtime
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 34. Validation Checklist

Validation must confirm:

1. Privacy consent types are defined.
2. Required versus optional consent boundary is defined.
3. Consent evidence packet is defined.
4. Consent version snapshot rule is defined.
5. Consent method candidates are defined.
6. Signup consent flow is defined.
7. Non-member order privacy flow is defined.
8. Third-party provision flow is defined.
9. Processing outsourcing notice flow is defined.
10. Marketing consent flow is defined.
11. Marketing withdrawal flow is defined.
12. Location service consent flow is defined.
13. App permission notice flow is defined.
14. Cookie/log and analytics notice is defined.
15. Dormant/inactive account flow is defined.
16. Withdrawal and deletion flow is defined.
17. Breach notification evidence flow is defined.
18. Retention class mapping is defined.
19. Consent state registry is defined.
20. Consent query usage is defined.
21. Consent evidence and support usage is defined.
22. Consent and POS/payment boundary is defined.
23. Consent and marketing/coupon boundary is defined.
24. Consent and i18n boundary is defined.
25. Consent and tenant scope boundary is defined.
26. Consent migration boundary is defined.
27. Data minimization boundary is defined.
28. Security boundary is defined.
29. Anti-patterns are listed.
30. Coding remains unauthorized.
31. Runtime remains deferred.

---

## 35. Relationship To Previous Documents

This document supplements:

- `40017 Legal Notice Master Toggle Disclosure Consent And Compliance Governance Policy`
- `40018 Legal Notice Master Data Usage Flow And Runtime Retrieval Governance Policy`
- `40019 Legal Notice Master Data Table Static Specification Policy`
- `40020 Legal Notice Trigger Matrix And UI Surface Mapping Policy`

It also references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10700 Security And Trust Foundation Index`

It prepares possible future documents:

- `10721 Alcohol Age Gate Legal Notice And Staff Verification SOP`
- `10722 Refund Cancellation No-Show Notice And Dispute Evidence SOP`
- `10723 Legal Notice i18n Review And Controlled Translation Policy`
- `10724 Legal Notice Admin Toggle Permission And HQ Lock Policy`
- `10725 Privacy Consent Static Table And Evidence Seed Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 36. Final Rule

Catch Menu privacy consent must be captured as versioned, purpose-specific, channel-specific, tenant-scoped, and evidence-backed records.

Required service consent, privacy collection/use consent, third-party provision consent, optional marketing consent, advertising channel consent, location consent, app permission notice, non-member order consent, withdrawal, dormant account, and breach notification evidence must be separated.

Optional consent refusal must not block core service unless the feature itself requires that data.

Consent evidence must record the exact notice version, locale, surface, timestamp, method, accepted/refused state, withdrawal state, and audit reference.

Historical evidence must never be rewritten.

Consent is a compliance evidence system, not a single checkbox.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.