# 010721_Policy_Alcohol_Age_Gate_Legal_Notice_And_Staff_Verification_SOP

## 1. Purpose

This document defines the Alcohol Age Gate, Legal Notice, Adult Confirmation, Staff ID Verification, Alcohol Order Blocking, Alcohol Cancellation, Evidence Packet, and Compliance SOP Policy for Catch Menu.

The previous document `10720 Privacy Consent Evidence Packet And Retention Policy` defined privacy consent evidence, consent types, withdrawal, retention, i18n, tenant scope, and data minimization governance.

This document focuses on alcohol-related legal notice and staff verification flows:

- alcohol menu detection
- adult confirmation popup
- ID verification requirement
- mobile ID handling
- foreign customer ID handling
- student ID rejection
- fake ID escalation
- proxy alcohol order prohibition
- alcohol order blocking
- staff confirmation evidence
- table order alcohol flow
- kiosk alcohol flow
- delivery alcohol restriction
- refund/cancellation when alcohol verification fails
- support/dispute evidence

This document is planning-only.

It does not provide legal advice.

It does not authorize coding.

---

## 2. Core Position

Alcohol ordering must be treated as a regulated flow, not an ordinary beverage flow.

The correct rule is:

Alcohol menu detection is not alcohol sale authorization.  
Customer adult self-confirmation is not sufficient by itself where staff verification is required.  
Staff ID verification must be evidence-backed.  
Student ID or captured image is not reliable identity proof unless policy allows.  
Alcohol must be blocked if adult status cannot be verified.  
Alcohol delivery must be disabled unless a separate approved legal and operational policy explicitly enables it.  
Alcohol set menus must inherit alcohol restrictions.  
Alcohol refund and cancellation must follow payment state and verification failure state.  
AI may detect alcohol items, but AI cannot approve alcohol sale.  

Alcohol flow must fail closed.

---

## 3. Scope

This policy applies to:

- alcohol menu registration
- alcohol category display
- alcohol item detail
- alcohol set menu
- alcohol pairing option
- corkage/bottle charge
- table order alcohol order
- kiosk alcohol order
- app order alcohol item
- pickup alcohol order
- delivery alcohol attempt
- adult confirmation popup
- staff ID check
- alcohol refusal
- alcohol order cancellation
- POS mapping
- payment/refund
- receipt
- support/dispute evidence
- incident escalation
- admin configuration

This policy defines operational governance only.

It is not a runtime implementation.

---

## 4. Alcohol Item Classification

Alcohol items must be classified separately from ordinary drinks.

Alcohol candidates include:

- soju
- beer
- draft beer
- imported beer
- makgeolli
- traditional liquor
- sake
- wine
- whisky
- highball
- cocktail
- spirits
- alcohol set
- alcohol pairing
- corkage
- bottle charge if tied to alcohol service

Alcohol-adjacent non-alcohol items include:

- tonic water
- lemon slice
- ice
- hangover drink
- zero-alcohol beverage
- non-alcohol adult beverage
- mixer
- corkage service fee

Alcohol-adjacent does not automatically equal alcohol, but may require policy review.

---

## 5. Alcohol State Registry

Recommended alcohol states:

| State | Meaning |
|---|---|
| `NOT_ALCOHOL` | Not alcohol |
| `ALCOHOL_CANDIDATE` | AI/system suspects alcohol |
| `ALCOHOL_CONFIRMED` | Confirmed alcohol item |
| `ALCOHOL_SET_CONFIRMED` | Set includes alcohol |
| `ALCOHOL_PAIRING_OPTION` | Optional alcohol pairing |
| `CORKAGE_SERVICE_FEE` | Service fee for brought alcohol |
| `NON_ALCOHOL_ADULT_BEVERAGE` | Adult-only non-alcohol beverage |
| `ALCOHOL_REVIEW_REQUIRED` | Needs review |
| `ALCOHOL_DISABLED` | Alcohol ordering disabled |
| `ALCOHOL_BLOCKED_BY_POLICY` | Cannot order due to policy |

Unknown alcohol state must not be treated as ordinary beverage.

---

## 6. Admin Alcohol Setup Flow

Admin alcohol setup flow:

1. AI/menu dictionary detects alcohol candidates.
2. Admin reviews candidates.
3. Admin confirms alcohol items.
4. Admin confirms store alcohol sale flag.
5. System checks legal notice requirements.
6. Adult confirmation notice is attached.
7. Staff ID verification workflow is enabled if required.
8. POS alcohol category mapping is reviewed.
9. Delivery/pickup policy is reviewed.
10. Alcohol surfaces are previewed.
11. Alcohol setup remains pending until approved.

Admin confirmation must create audit events.

---

## 7. Alcohol Notice Requirements

Alcohol-related notice types:

| Notice | Purpose |
|---|---|
| Adult confirmation | Customer declares adult status |
| ID required notice | Staff may require ID |
| Minor sale prohibition | 19세 미만 sale prohibited |
| Proxy purchase prohibition | Adult cannot purchase for minor |
| Fake ID warning | Forged/borrowed ID escalation |
| Mobile ID standard | Acceptable digital ID guidance |
| Foreign ID standard | Passport/alien registration card guidance |
| Alcohol delivery restriction | Delivery restriction notice |
| Intoxication refusal | Staff may refuse sale |
| Alcohol sale time notice | Sale time restriction |
| Non-alcohol adult beverage notice | Adult-only non-alcohol beverage |
| Corkage fee notice | Corkage is service fee |

Notice requirements must be configurable but high-risk notices may be locked.

---

## 8. Alcohol Order Entry Flow

Recommended alcohol order entry flow:

1. Customer selects alcohol item.
2. System detects alcohol flag.
3. Alcohol item detail shows age/legal notice.
4. Customer adds item to cart.
5. Adult confirmation popup appears or is deferred to checkout.
6. Customer confirms adult status.
7. If staff ID check is required, order enters verification pending state.
8. Staff verifies ID before final service or before order transmission depending store policy.
9. If verification succeeds, alcohol order proceeds.
10. If verification fails, alcohol item is removed or cancelled.
11. Evidence is attached to order.

Alcohol flow must be auditable.

---

## 9. Adult Confirmation Popup

Adult confirmation popup should capture:

| Field | Meaning |
|---|---|
| `notice_id` | Adult confirmation notice |
| `notice_version_id` | Exact notice version |
| `order_id` | Order if available |
| `session_id` | Customer session |
| `device_id` | Device |
| `table_id` | Table |
| `customer_id` | Customer if known |
| `locale` | Language shown |
| `shown_at` | Display time |
| `confirmed_at` | Confirmation time |
| `confirm_method` | Button, checkbox |
| `adult_declared` | True/false |
| `audit_ref` | Audit reference |

Adult confirmation is customer declaration.

It is not staff ID verification.

---

## 10. Staff ID Verification Flow

Staff ID verification flow:

1. Alcohol order is flagged.
2. Staff screen shows pending ID verification.
3. Staff requests acceptable ID.
4. Staff confirms acceptable ID type.
5. Staff confirms adult eligibility.
6. Staff records pass/fail.
7. If pass, alcohol service can continue.
8. If fail, alcohol item is blocked/cancelled.
9. Evidence is recorded.
10. Incident escalation is available for fake ID or conflict.

Staff verification must be simple but evidence-backed.

---

## 11. Staff Verification Evidence Packet

Recommended staff verification evidence:

| Field | Meaning |
|---|---|
| `verification_id` | Unique verification record |
| `tenant_id` | Tenant |
| `store_id` | Store |
| `order_id` | Order |
| `table_id` | Table |
| `staff_actor_id` | Staff who checked |
| `alcohol_item_ids` | Alcohol items |
| `verification_required_reason` | Alcohol order, policy, suspicion |
| `id_type_checked` | Resident card, mobile ID, passport, etc. |
| `id_validity_result` | Pass, fail, refused, unclear |
| `adult_confirmed` | True/false |
| `checked_at` | Time |
| `failure_reason` | No ID, minor, fake, refused |
| `action_taken` | Proceed, cancel, remove item, escalate |
| `notice_version_id` | Notice shown |
| `audit_ref` | Audit correlation |

Do not store full ID image unless explicitly approved by legal/privacy policy.

---

## 12. Acceptable ID Guidance

Acceptable ID policy should be configurable.

Common accepted examples may include:

- physical resident registration card
- physical driver license
- physical passport
- official mobile ID app
- official government/pass app where allowed
- alien registration card for foreign customers

Common rejected examples may include:

- screenshot
- photo copy
- edited image
- student ID
- employee ID without birth verification
- social media profile
- verbal claim
- borrowed ID
- unclear damaged ID

Final accepted list requires legal review.

---

## 13. Mobile ID Boundary

Mobile ID must be governed.

Rules:

- official app only if policy allows
- screenshot is not accepted
- captured photo is not accepted
- expired or unverifiable mobile ID is rejected
- staff should not store unnecessary ID image
- verification result is recorded, not raw ID copy
- unclear case escalates to manager

Mobile ID policy must be updated when regulations/platform standards change.

---

## 14. Foreign Customer ID Boundary

Foreign customer alcohol verification may require:

- passport
- alien registration card
- accepted government ID if policy allows
- birth date verification
- original document
- no screenshot/photo copy
- staff guidance in multiple languages
- manager escalation if unclear

Foreign customer ID handling should be supported by i18n staff guidance.

---

## 15. Proxy Purchase Prohibition

Proxy purchase risk:

- adult orders alcohol for minor
- adult shares alcohol with minor at table
- minor asks adult to order
- mixed adult/minor group
- table order hides actual drinker

System response:

- show proxy purchase warning
- staff may check table composition
- staff may refuse alcohol service
- staff may remove alcohol item
- staff may escalate incident
- evidence records reason

Adult confirmation alone is insufficient if table context creates risk.

---

## 16. Mixed Group Table Boundary

Mixed adult/minor table handling must define:

| Situation | Recommended Behavior |
|---|---|
| All adults verified | Alcohol may proceed |
| Minor present at table | Staff caution notice |
| Adult orders alcohol | Staff may verify adult drinker |
| Minor attempts alcohol order | Block |
| Adult gives alcohol to minor | Staff refusal/incident |
| ID unclear | Block or manager review |

This must be staff-guided, not fully automated.

---

## 17. Alcohol Set Menu Boundary

Alcohol set examples:

- 삼겹살 3인분 + 소주 1병
- 사시미 + 화요 세트
- 하이볼 1+1
- 와인 페어링
- 맥주 피처 세트

Rules:

- set inherits alcohol flag
- alcohol notice applies to whole set
- adult confirmation required
- staff verification may be required
- alcohol component must be separately visible to POS
- delivery restriction applies
- refund/cancel rule must handle alcohol component

Alcohol cannot be hidden inside food set.

---

## 18. Corkage Boundary

Corkage is not alcohol inventory.

Corkage requires:

- service fee notice
- fee unit
- bottle/glass/table scope
- allowed alcohol type
- free bottle limit if any
- staff confirmation
- POS service fee category
- no inventory deduction unless store provides alcohol
- legal review if alcohol handling policy requires

Corkage notice should appear before fee is charged.

---

## 19. Alcohol Delivery Boundary

Default rule:

    Alcohol delivery is disabled unless separate legal, payment, age verification, handoff, and operational policy explicitly enables it.

If alcohol delivery is attempted:

| Condition | Behavior |
|---|---|
| Alcohol delivery disabled | Block order |
| Alcohol included in set | Block entire alcohol component or set |
| Pickup only allowed | Show pickup-only notice |
| Age verification unavailable | Block |
| Delivery provider unsupported | Block |
| Legal review missing | Block |
| Staff override attempted | Escalate/review |

Alcohol delivery must fail closed.

---

## 20. Pickup Alcohol Boundary

Pickup alcohol may require:

- adult confirmation
- staff ID check at pickup
- pickup customer identity matching
- no proxy pickup if policy restricts
- cancellation if ID fails
- refund policy for failed verification
- evidence capture

Pickup flow must not release alcohol without verification where required.

---

## 21. Table Order Alcohol Boundary

Table order alcohol may require:

- adult confirmation on tablet
- staff ID check before serving
- table-level verification status
- per-customer verification if split table
- minor presence warning
- staff refusal action
- alcohol item removal
- audit

Table ID is not customer identity.

Seat/customer identity may be needed for advanced flows.

---

## 22. Kiosk Alcohol Boundary

Kiosk alcohol ordering should be conservative.

Kiosk flow may require:

- alcohol item hidden unless enabled
- adult confirmation
- staff call for ID check
- payment hold or no payment until verification
- no unattended alcohol release
- receipt flag for staff
- cancellation/refund flow if ID fails

Unstaffed kiosk alcohol sale should remain disabled unless separately approved.

---

## 23. Alcohol Payment And Refund Boundary

Payment handling must consider verification timing.

Possible models:

| Model | Meaning |
|---|---|
| `VERIFY_BEFORE_PAYMENT` | ID check before payment |
| `AUTHORIZE_THEN_VERIFY` | Payment authorization before ID check |
| `PAY_AFTER_VERIFY` | Payment after verification |
| `REMOVE_ALCOHOL_IF_FAIL` | Remove alcohol from order if fail |
| `CANCEL_ORDER_IF_FAIL` | Cancel full order if alcohol set cannot split |
| `REFUND_ALCOHOL_COMPONENT` | Partial refund alcohol component |
| `MANUAL_REVIEW_REQUIRED` | Staff/HQ review required |

Refund behavior must match actual payment provider and POS state.

---

## 24. Alcohol POS Mapping Boundary

Alcohol POS mapping must preserve:

- alcohol item category
- alcohol tax category if applicable
- bottle/glass/volume unit
- set component
- promotion component
- corkage service fee
- staff verification state
- sale time restriction
- refund/cancel state
- receipt display
- inventory deduction

Alcohol should not be mapped as generic beverage.

---

## 25. Alcohol KDS / Bar Routing Boundary

Alcohol-related KDS/bar routing may include:

- bar station
- service station
- staff verification pending marker
- do-not-serve-until-verified marker
- corkage service marker
- set component split
- pickup verification marker
- cancellation marker

Kitchen/bar execution must not override age verification.

---

## 26. Alcohol Evidence Packet For Disputes

Alcohol dispute evidence may include:

- alcohol item
- alcohol notice shown
- adult confirmation
- staff ID verification result
- staff actor
- order time
- payment state
- table/device/session
- customer if known
- cancellation/refund action
- incident record if any
- policy version
- store alcohol setting at time

Support must view evidence case-scoped.

Support cannot modify evidence.

---

## 27. Failure Handling

Failure cases:

| Failure | Response |
|---|---|
| Customer refuses adult confirmation | Block alcohol |
| Customer refuses ID check | Cancel/remove alcohol |
| Customer has no ID | Cancel/remove alcohol |
| ID appears underage | Cancel/remove alcohol |
| ID appears fake | Escalate to manager/policy |
| Staff cannot determine validity | Manager review or block |
| System cannot record evidence | Block alcohol or create incident |
| POS accepts alcohol without notice | Compliance incident |
| Alcohol item misclassified | Admin/legal review |
| Delivery flow includes alcohol | Block or legal review |

Unknown state must not allow alcohol sale.

---

## 28. Incident Escalation

Escalation triggers:

- fake ID suspicion
- proxy purchase suspicion
- minor present with alcohol
- customer aggression after refusal
- repeated attempt
- staff override conflict
- POS/payment mismatch
- missing notice evidence
- alcohol served without verification
- complaint after refusal

Escalation may route to:

- manager
- HQ
- legal/compliance
- support
- incident log
- police only where appropriate and lawful

Escalation must be documented.

---

## 29. Admin Configuration Requirements

Admin alcohol settings should include:

| Setting | Meaning |
|---|---|
| Alcohol sales enabled | Store sells alcohol |
| Alcohol menu visible | Show alcohol category |
| Adult popup required | Customer adult confirmation |
| Staff ID check required | Staff verification |
| Delivery alcohol allowed | Default false |
| Pickup alcohol allowed | Store policy |
| Alcohol sale time | Allowed hours |
| Mobile ID policy | Accepted/rejected |
| Foreign ID policy | Accepted documents |
| Mixed group warning | Enable staff caution |
| Alcohol set handling | Split/cancel rules |
| Refund model | Verification failure refund |
| Corkage enabled | Corkage service fee |
| HQ lock | Franchise lock if any |

High-risk settings require authority and audit.

---

## 30. Staff UX Requirements

Staff screen should show:

- alcohol verification pending list
- table/order ID
- alcohol items
- required notice summary
- acceptable ID guide
- pass/fail buttons
- refusal reason options
- manager escalation
- cancellation/removal action
- customer message
- audit completion state

Staff flow must be fast during peak operation.

---

## 31. Customer UX Requirements

Customer screen should show:

- alcohol age warning
- adult confirmation
- ID check possibility
- refusal/cancellation rule
- delivery restriction if applicable
- pickup verification notice
- non-alcohol item distinction
- refund behavior if verification fails
- legal notice link

Wording should be clear and not unnecessarily hostile.

---

## 32. Audit Event Catalog

Recommended events:

| Event Type | Meaning |
|---|---|
| `ALCOHOL_ITEM_DETECTED` | Alcohol candidate detected |
| `ALCOHOL_ITEM_CONFIRMED` | Admin confirmed alcohol |
| `ALCOHOL_NOTICE_SHOWN` | Alcohol notice shown |
| `ALCOHOL_ADULT_CONFIRM_SHOWN` | Adult confirmation popup shown |
| `ALCOHOL_ADULT_CONFIRMED` | Customer confirmed adult |
| `ALCOHOL_STAFF_ID_CHECK_REQUIRED` | Staff ID check required |
| `ALCOHOL_STAFF_ID_CHECK_PASSED` | Staff passed ID |
| `ALCOHOL_STAFF_ID_CHECK_FAILED` | Staff failed ID |
| `ALCOHOL_ORDER_BLOCKED` | Alcohol order blocked |
| `ALCOHOL_ITEM_REMOVED` | Alcohol item removed |
| `ALCOHOL_ORDER_CANCELLED` | Alcohol order cancelled |
| `ALCOHOL_REFUND_TRIGGERED` | Refund triggered |
| `ALCOHOL_PROXY_PURCHASE_SUSPECTED` | Proxy risk suspected |
| `ALCOHOL_FAKE_ID_SUSPECTED` | Fake ID suspected |
| `ALCOHOL_DELIVERY_BLOCKED` | Delivery blocked |
| `ALCOHOL_POLICY_OVERRIDE_ATTEMPTED` | Override attempt |
| `ALCOHOL_COMPLIANCE_INCIDENT_CREATED` | Compliance incident |

Events must route through `10610`.

---

## 33. Security And Privacy Boundary

Alcohol verification evidence is sensitive.

Rules:

- do not store full ID image by default
- do not store resident registration number unless legally reviewed
- mask personal identity data
- store verification result, not raw ID data where possible
- case-scoped support access
- audit evidence access
- tenant/store scope mandatory
- staff action logged
- reauthentication for policy override
- retention policy legally reviewed

Alcohol compliance must not create unnecessary privacy risk.

---

## 34. Anti-Patterns

Avoid:

- treating alcohol as ordinary beverage
- allowing alcohol order without adult confirmation
- relying only on customer self-declaration where staff check is required
- accepting screenshots as ID without policy
- hiding alcohol inside set menu
- allowing delivery alcohol by default
- processing alcohol refund without payment-state check
- storing full ID image unnecessarily
- letting staff bypass verification without audit
- allowing support to edit verification evidence
- showing alcohol notice only in footer
- using AI to approve alcohol sale
- mapping alcohol to generic drink POS category
- allowing unknown alcohol state to proceed
- failing to block if evidence capture fails

These anti-patterns must be blocked in future runtime design.

---

## 35. Runtime Deferral

This document defines alcohol age gate, legal notice, staff verification, evidence, and compliance SOP governance only.

It does not authorize:

- alcohol runtime implementation
- age-gate popup implementation
- staff ID verification UI
- alcohol POS mapping implementation
- alcohol delivery policy implementation
- refund automation
- evidence storage implementation
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 36. Validation Checklist

Validation must confirm:

1. Alcohol item classification is defined.
2. Alcohol state registry is defined.
3. Admin alcohol setup flow is defined.
4. Alcohol notice requirements are defined.
5. Alcohol order entry flow is defined.
6. Adult confirmation popup is defined.
7. Staff ID verification flow is defined.
8. Staff verification evidence packet is defined.
9. Acceptable ID guidance is defined.
10. Mobile ID boundary is defined.
11. Foreign customer ID boundary is defined.
12. Proxy purchase prohibition is defined.
13. Mixed group table boundary is defined.
14. Alcohol set menu boundary is defined.
15. Corkage boundary is defined.
16. Alcohol delivery boundary is defined.
17. Pickup alcohol boundary is defined.
18. Table order alcohol boundary is defined.
19. Kiosk alcohol boundary is defined.
20. Alcohol payment/refund boundary is defined.
21. Alcohol POS mapping boundary is defined.
22. Alcohol KDS/bar routing boundary is defined.
23. Alcohol evidence packet for disputes is defined.
24. Failure handling is defined.
25. Incident escalation is defined.
26. Admin configuration requirements are defined.
27. Staff UX requirements are defined.
28. Customer UX requirements are defined.
29. Audit event catalog is defined.
30. Security/privacy boundary is defined.
31. Anti-patterns are listed.
32. Coding remains unauthorized.
33. Runtime remains deferred.

---

## 37. Relationship To Previous Documents

This document supplements:

- `10716 Legal Notice Master Toggle Disclosure Consent And Compliance Governance Policy`
- `10717 Legal Notice Master Data Usage Flow And Runtime Retrieval Governance Policy`
- `10718 Legal Notice Master Data Table Static Specification Policy`
- `10719 Legal Notice Trigger Matrix And UI Surface Mapping Policy`
- `10720 Privacy Consent Evidence Packet And Retention Policy`

It also references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10714 Pub Pocha Late Night Delivery Alcohol Anju Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `10715 AI Menu Review Option Builder Set Combo Course And Special Sales Pattern Governance Policy`

It prepares possible future documents:

- `10722 Refund Cancellation No-Show Notice And Dispute Evidence SOP`
- `10723 Legal Notice i18n Review And Controlled Translation Policy`
- `10724 Legal Notice Admin Toggle Permission And HQ Lock Policy`
- `10725 Alcohol POS Payment Refund And Delivery Restriction Boundary Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 38. Final Rule

Catch Menu alcohol ordering must be governed as a regulated, evidence-backed flow.

Alcohol item detection, adult confirmation, staff ID verification, delivery restriction, pickup verification, alcohol set inheritance, corkage handling, POS mapping, refund behavior, customer notice, and dispute evidence must be separated and auditable.

AI may detect alcohol candidates.

AI cannot approve alcohol sales.

Customer self-confirmation alone is not sufficient where staff verification is required.

Alcohol delivery must remain disabled by default unless a separate approved legal, payment, age verification, handoff, and operational policy explicitly enables it.

Unknown alcohol state must fail closed.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.