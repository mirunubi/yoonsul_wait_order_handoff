# 008010_Policy_Alcohol_Sales_Adult_Verification_And_Legal_Sale_Boundary

## 1. Purpose

This document defines the alcohol sales adult verification, legal sale boundary, verification trigger, verification failure handling, verification uncertainty handling, staff confirmation, sale hold, service refusal, evidence, and implementation deferral policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document started the High Risk Store Operation Foundation lane and defined alcohol sale, adult verification, table partial settlement, drunk customer misoperation, night delivery concurrency, and store safety as foundation-level edge cases.

This document focuses specifically on the adult verification and legal sale boundary for alcohol-related operation.

This document does not provide legal advice and does not decide final alcohol licensing, identity verification vendor, government compliance procedure, or local jurisdiction interpretation.

It defines adult verification and legal sale boundary policy only.

---

## 2. Scope

This document covers:

- alcohol sale eligibility boundary
- adult verification trigger
- verification subject
- verification timing
- verification status
- verification failure
- verification uncertainty
- staff confirmation
- sale hold
- service refusal
- evidence requirement
- privacy boundary
- no-implementation boundary

This document does not cover:

- final alcohol license procedure
- final legal interpretation
- final ID verification vendor
- final CI/DI integration
- final government API integration
- final identity storage schema
- final POS implementation
- final payment implementation
- final KDS implementation
- final UI design
- final delivery alcohol sale rule

---

## 3. Core Principle

Alcohol sale requires verified eligibility before order fulfillment.

The project must follow this rule:

> Alcohol-related order flow must not proceed to payment completion, KDS release, service, delivery handoff, or staff-confirmed fulfillment unless adult verification, legal sale eligibility, staff authority, and evidence requirements are satisfied or a legally valid manual fallback is recorded.

Alcohol sale is not a normal menu flow.

Verification uncertainty must block automatic fulfillment.

---

## 4. Alcohol Sale Boundary Meaning

Alcohol sale boundary means the set of conditions that must be satisfied before an alcohol item may move from customer intent to fulfillment.

The boundary includes:

- customer eligibility
- adult verification status
- sale time restriction if any
- store license scope
- dine-in or delivery mode
- table/session context
- staff confirmation requirement
- payment certainty
- KDS release rule
- service refusal rule
- evidence capture
- legal/compliance review

Alcohol item must be governed separately from ordinary food item.

---

## 5. Alcohol Item Classification

Menu items should be classified before sale.

Recommended alcohol-related classifications:

- `ALCOHOL_ITEM`
- `ALCOHOL_BEVERAGE`
- `LOW_ALCOHOL_ITEM`
- `ALCOHOL_SET_MENU`
- `ALCOHOL_INCLUDED_COMBO`
- `ALCOHOL_ADJACENT_ITEM`
- `NON_ALCOHOL_ITEM`
- `AGE_RESTRICTED_ITEM`
- `ALCOHOL_SERVICE_ITEM`
- `ALCOHOL_UNKNOWN_CLASSIFICATION`

Alcohol classification must be explicit.

Do not infer alcohol risk from menu name alone.

---

## 6. Alcohol Mode Status Values

Recommended alcohol mode status values:

- `ALCOHOL_MODE_DISABLED`
- `ALCOHOL_MODE_REVIEW_REQUIRED`
- `ALCOHOL_MODE_CONFIGURED`
- `ALCOHOL_MODE_STAFF_ONLY`
- `ALCOHOL_MODE_CUSTOMER_ORDER_ALLOWED`
- `ALCOHOL_MODE_DELIVERY_DISABLED`
- `ALCOHOL_MODE_SUSPENDED`
- `ALCOHOL_MODE_BLOCKED`
- `ALCOHOL_MODE_LEGAL_REVIEW_REQUIRED`

Alcohol mode must remain disabled until required readiness is satisfied.

---

## 7. Alcohol Sale Eligibility Inputs

Alcohol sale eligibility may depend on:

- store alcohol license status
- customer adult verification status
- customer table/session context
- sale mode
- dine-in or delivery
- time of day
- staff availability
- payment certainty
- KDS hold/release state
- customer behavior risk
- service refusal status
- legal restriction
- delivery platform restriction
- local jurisdiction rule

Eligibility should be conservative.

---

## 8. Verification Subject Rule

Adult verification may apply to:

- individual customer
- account holder
- person receiving alcohol
- person paying
- person seated at table
- person picking up
- person receiving delivery
- staff-confirmed recipient

The project must not assume that payer, account holder, table representative, and drinker are always the same person.

---

## 9. Table-Level Verification Warning

A table-level verification summary may be useful, but it must not imply all people at the table are verified.

Examples:

- one verified adult at table does not verify all guests
- group order may involve mixed ages
- late-joining customer may need separate handling
- split payment may involve unverified participant
- staff may need visual confirmation

Table context must preserve individual eligibility risk.

---

## 10. Adult Verification Trigger

Adult verification should be triggered when:

- alcohol item is selected
- alcohol item is added to table order
- alcohol item is included in combo
- alcohol item is reordered
- alcohol quantity increases
- alcohol is added after partial settlement
- delivery or pickup order contains alcohol
- staff manually adds alcohol
- customer changes recipient
- age-restricted promotion is selected
- verification has expired
- verification status is uncertain

Trigger must happen before fulfillment.

---

## 11. Verification Timing

Verification may occur at:

- account onboarding
- order intent
- checkout
- table arrival
- staff confirmation
- pickup
- delivery handoff
- re-order
- dispute review

For alcohol mode, verification timing must be close enough to sale and recipient context to be meaningful.

Old verification may not be sufficient without policy.

---

## 12. Verification Status Values

Recommended adult verification status values:

- `VERIFICATION_NOT_REQUIRED`
- `VERIFICATION_REQUIRED`
- `VERIFICATION_PENDING`
- `VERIFICATION_PASSED`
- `VERIFICATION_FAILED`
- `VERIFICATION_UNCERTAIN`
- `VERIFICATION_EXPIRED`
- `VERIFICATION_STAFF_REVIEW_REQUIRED`
- `VERIFICATION_MANUAL_CONFIRMED`
- `VERIFICATION_BLOCKED`
- `VERIFICATION_PROVIDER_UNAVAILABLE`

Status must be visible to authorized staff in safe summary form.

---

## 13. Verification Failure Rule

If verification fails:

- alcohol item must not proceed to KDS release
- alcohol payment path should be blocked or reversed according to policy
- staff should receive safe explanation
- customer should receive calm message
- evidence should be recorded
- service refusal path should be available
- support escalation may be created
- non-alcohol items may continue if safe
- raw identity data must not be exposed

Failure must not be treated as technical inconvenience.

---

## 14. Verification Uncertainty Rule

If verification is uncertain:

- automatic alcohol fulfillment must be blocked
- KDS release must be held
- staff confirmation may be required
- provider retry may be allowed if safe
- manual verification fallback may be allowed only under policy
- payment should not imply service commitment
- customer communication should avoid blame
- evidence must show uncertainty reason

Uncertainty should default to hold, not approval.

---

## 15. Verification Expiration Rule

Verification may expire based on:

- time
- session end
- table transfer
- customer logout
- device change
- pickup/delivery handoff delay
- support/security event
- suspicious activity
- staff judgement
- legal rule

Expired verification should return to required or review status.

---

## 16. Verification Provider Failure Rule

If verification provider is unavailable:

- alcohol order should not auto-proceed
- verification status should be provider unavailable
- staff should see fallback guidance
- customer should see safe delay or staff check message
- KDS should hold alcohol-related ticket
- support/provider incident may be created
- alcohol mode may be suspended if repeated

Provider failure is not customer eligibility proof.

---

## 17. Manual Verification Fallback Rule

Manual verification fallback may be allowed only when:

- staff is trained
- legal/compliance policy allows it
- staff can inspect acceptable ID
- result is recorded as manual confirmation
- raw ID copy is not stored unless legally required and approved
- reason is recorded
- timestamp and staff actor are recorded
- scope is limited to current sale/session
- audit evidence is created

Manual fallback must not become casual bypass.

---

## 18. Staff Confirmation Requirement

Staff confirmation may be required when:

- verification is manual
- verification is uncertain
- customer behavior risk exists
- customer appears intoxicated
- high alcohol quantity is ordered
- alcohol is added after partial settlement
- table includes mixed group risk
- delivery/pickup recipient mismatch exists
- provider verification failed
- service refusal is being considered

Staff confirmation must produce evidence.

---

## 19. Staff Confirmation Status Values

Recommended status values:

- `STAFF_CONFIRMATION_NOT_REQUIRED`
- `STAFF_CONFIRMATION_REQUIRED`
- `STAFF_CONFIRMATION_PENDING`
- `STAFF_CONFIRMATION_COMPLETED`
- `STAFF_CONFIRMATION_REJECTED`
- `STAFF_CONFIRMATION_ESCALATED`
- `STAFF_CONFIRMATION_EXPIRED`
- `STAFF_CONFIRMATION_BLOCKED`

Staff confirmation is not the same as legal conclusion.

---

## 20. Sale Hold Rule

Alcohol sale should be held when:

- verification required but not passed
- verification failed
- verification uncertain
- verification provider unavailable
- staff confirmation required but pending
- payment uncertainty exists
- KDS release not allowed
- customer behavior risk exists
- service refusal review is active
- delivery recipient eligibility unclear
- legal restriction applies

Hold means no fulfillment until safe release or cancellation.

---

## 21. Sale Hold Status Values

Recommended status values:

- `ALCOHOL_SALE_NOT_HELD`
- `ALCOHOL_SALE_HOLD_VERIFICATION`
- `ALCOHOL_SALE_HOLD_STAFF_CONFIRMATION`
- `ALCOHOL_SALE_HOLD_PAYMENT`
- `ALCOHOL_SALE_HOLD_KDS`
- `ALCOHOL_SALE_HOLD_SERVICE_REFUSAL_REVIEW`
- `ALCOHOL_SALE_HOLD_PROVIDER`
- `ALCOHOL_SALE_HOLD_DELIVERY_RECIPIENT`
- `ALCOHOL_SALE_HOLD_LEGAL_REVIEW`

Hold reason must be visible.

---

## 22. KDS Release Boundary

Alcohol-related KDS release requires:

- verification passed or valid manual confirmation
- staff confirmation if required
- payment certainty if required by flow
- no active service refusal review
- no unresolved legal restriction
- no delivery recipient mismatch
- no critical provider uncertainty
- evidence packet created or linked

KDS must not prepare alcohol item during eligibility uncertainty.

---

## 23. Payment Boundary

Alcohol payment flow must avoid implying guaranteed service when verification is incomplete.

Possible policy options:

- verify before payment
- authorize after verification only
- hold payment until verification
- refund automatically if verification fails
- allow non-alcohol split order to continue
- require staff-assisted payment for alcohol

Final implementation is deferred.

But payment design must not charge customer for alcohol that cannot legally be served without recovery path.

---

## 24. Order Split Rule

If alcohol verification fails or is uncertain, the system should consider separating:

- non-alcohol food order
- alcohol order
- alcohol-related combo
- table add-on
- delivery platform order
- payment portion
- KDS ticket portion

Order split must preserve evidence and avoid silent mutation.

---

## 25. Customer Communication Rule

Customer communication should be:

- calm
- respectful
- non-accusatory
- clear that verification is required
- clear that staff can assist
- clear that alcohol cannot proceed until verification
- avoiding unnecessary legal details
- avoiding raw provider error
- avoiding identity data exposure

Example:

    주류 주문은 성인 확인이 필요합니다. 확인이 완료되면 주문이 계속 진행됩니다. 확인이 어려운 경우 직원이 도와드리겠습니다.

Do not say:

    신분증 오류라서 주문이 막혔습니다.
    미성년자로 나옵니다.
    시스템이 안 되니 알아서 하세요.

---

## 26. Staff Communication Rule

Staff communication should show:

- alcohol verification required
- current safe status
- hold reason
- action required
- customer-facing guidance
- escalation path
- service refusal option if applicable
- evidence capture requirement

Staff screen must not show raw identity payload.

---

## 27. Service Refusal Trigger

Service refusal review may be triggered when:

- verification failed
- verification uncertain and manual fallback unavailable
- customer refuses verification
- customer appears underage
- customer appears heavily intoxicated
- customer becomes abusive
- recipient mismatch occurs
- delivery/pickup eligibility unclear
- repeated misoperation creates risk
- legal restriction applies

Service refusal must be recorded respectfully.

---

## 28. Service Refusal Status Values

Recommended status values:

- `SERVICE_REFUSAL_NOT_REQUIRED`
- `SERVICE_REFUSAL_REVIEW`
- `SERVICE_REFUSAL_RECOMMENDED`
- `SERVICE_REFUSAL_CONFIRMED`
- `SERVICE_REFUSAL_ESCALATED`
- `SERVICE_REFUSAL_CANCELLED`
- `SERVICE_REFUSAL_CUSTOMER_RECOVERY_REQUIRED`
- `SERVICE_REFUSAL_CLOSED`

Service refusal status must be evidence-linked.

---

## 29. Evidence Requirement

Adult verification boundary evidence should include:

- alcohol order id or safe reference
- table/session reference
- verification status
- verification trigger
- verification provider status
- verification timestamp
- staff confirmation if any
- hold reason if any
- service refusal review if any
- customer communication status
- payment status
- KDS release status
- support escalation if any
- privacy/masking status

Evidence must not include unnecessary raw identity data.

---

## 30. Verification Evidence ID Format

Recommended format:

    ADULT-VERIFICATION-EVIDENCE-[YYYYMMDD]-[NUMBER]

Example:

    ADULT-VERIFICATION-EVIDENCE-20260612-001

Final format may be normalized later.

---

## 31. Alcohol Sale Decision Values

Recommended decision values:

- `ALLOW_ALCOHOL_ORDER`
- `ALLOW_WITH_STAFF_CONFIRMATION`
- `HOLD_FOR_VERIFICATION`
- `HOLD_FOR_PAYMENT`
- `HOLD_FOR_KDS_RELEASE`
- `REQUIRE_MANUAL_VERIFICATION`
- `REFUSE_ALCOHOL_SERVICE`
- `CANCEL_ALCOHOL_ITEM`
- `SPLIT_NON_ALCOHOL_ORDER`
- `ESCALATE_TO_MANAGER`
- `SUSPEND_ALCOHOL_MODE`

Decision must be linked to status and evidence.

---

## 32. Privacy Boundary

Adult verification must minimize privacy exposure.

Rules:

- raw ID document data should not appear in operational UI
- raw CI/DI should not appear in staff UI
- verification result should be abstracted
- support view should be masked
- export should be restricted
- KDS should not receive identity data
- payment screen should not expose verification payload
- logs should avoid raw identity data
- evidence should store status, not excessive identity details unless legally required

Privacy is part of legal sale boundary.

---

## 33. Support Boundary

Support may assist when:

- verification provider unavailable
- verification status unclear
- staff cannot resolve
- customer disputes failure
- alcohol order is held
- payment was attempted
- refund/cancel needed
- service refusal escalates
- evidence is incomplete

Support must remain scoped and masked.

Support must not approve alcohol sale without authorized staff/legal process.

---

## 34. Admin Console Boundary

Future Admin Console may display:

- alcohol mode status
- verification required count
- verification failed count
- verification uncertain count
- staff confirmation pending
- service refusal review
- evidence status
- support cases
- provider verification incident

Admin Console must not display:

- raw ID image
- raw CI/DI
- full identity payload
- hidden verification provider secret
- direct override to approve alcohol sale
- casual unmask button

Admin visibility must follow foundation policy.

---

## 35. Delivery Boundary Placeholder

Delivery alcohol sale requires separate review.

This document does not approve alcohol delivery.

Delivery boundary must later define:

- whether alcohol delivery is allowed
- recipient verification at handoff
- platform policy
- rider handoff risk
- recipient mismatch
- refund/cancel
- store responsibility
- platform responsibility
- evidence
- legal review

Until defined, delivery alcohol mode should remain disabled or restricted.

---

## 36. Legal Compliance Handoff

Legal/compliance review must later confirm:

- license scope
- sale mode
- adult verification method
- manual verification fallback
- data retention
- privacy notice
- customer consent if required
- staff training
- service refusal policy
- delivery restriction
- local jurisdiction rule

This document does not make final legal conclusion.

---

## 37. Pilot Restriction

Alcohol sale pilot must not start unless:

- alcohol mode readiness gate is passed
- staff training is complete
- verification flow is tested
- manual fallback is defined
- payment/refund/cancel path is tested
- KDS hold/release path is tested
- service refusal SOP exists
- support escalation exists
- evidence packet exists
- legal review is scheduled or completed as required

Alcohol pilot is high-risk pilot.

---

## 38. Implementation Deferral Boundary

This document does not authorize:

- alcohol menu activation
- customer alcohol ordering
- ID verification integration
- CI/DI integration
- manual ID capture
- alcohol payment flow
- alcohol KDS release
- service refusal automation
- Admin Console alcohol controls
- delivery alcohol ordering

Implementation requires separate approval after readiness review.

---

## 39. Registers Recommendation

Recommended future files:

    docs/_index/
      Alcohol_Mode_Status_Register.md
      Alcohol_Item_Classification_Register.md
      Adult_Verification_Status_Register.md
      Staff_Confirmation_Register.md
      Alcohol_Sale_Hold_Register.md
      Service_Refusal_Register.md
      Adult_Verification_Evidence_Register.md
      Alcohol_Sale_Decision_Register.md

This document only recommends these files.

It does not create them.

---

## 40. Anti-Patterns

The following are prohibited:

- treating alcohol item as normal menu item
- allowing alcohol KDS release before verification
- assuming one table verification covers all customers
- showing raw CI/DI to staff
- showing raw ID data in KDS
- using provider failure as verification pass
- letting payment imply legal service commitment
- refusing service without evidence
- blaming customer for verification failure
- allowing support to approve sale without authority
- enabling alcohol delivery without separate boundary
- using manual verification as casual bypass
- hiding verification uncertainty
- marking alcohol sale allowed without audit trail

---

## 41. Non-Goals

This document does not define:

- final legal standard
- final ID verification method
- final CI/DI storage
- final verification vendor
- final government API integration
- final POS/KDS/payment implementation
- final delivery alcohol policy
- final staff legal script
- final alcohol license procedure

Those belong to later legal, compliance, vendor, implementation, and training planning.

---

## 42. Readiness Check

This document is ready when the project can answer:

1. What is alcohol sale boundary?
2. What alcohol item classifications exist?
3. What alcohol mode status values exist?
4. What inputs affect alcohol sale eligibility?
5. Who is verification subject?
6. What table-level verification warning applies?
7. When is adult verification triggered?
8. When does verification occur?
9. What verification statuses exist?
10. What happens when verification fails?
11. What happens when verification is uncertain?
12. When does verification expire?
13. What happens when verification provider fails?
14. When is manual verification fallback allowed?
15. When is staff confirmation required?
16. What staff confirmation statuses exist?
17. When is alcohol sale held?
18. What sale hold statuses exist?
19. What KDS release boundary applies?
20. What payment boundary applies?
21. What order split rule applies?
22. What customer communication rule applies?
23. What staff communication rule applies?
24. When is service refusal triggered?
25. What service refusal statuses exist?
26. What evidence is required?
27. What sale decision values exist?
28. What privacy boundary applies?
29. What support boundary applies?
30. What Admin Console boundary applies?
31. What delivery boundary placeholder applies?
32. What legal compliance handoff is needed?
33. What pilot restriction applies?
34. What implementation deferral boundary applies?
35. What anti-patterns are prohibited?

If these questions cannot be answered, alcohol sales adult verification and legal sale boundary planning is incomplete.

---

## 43. Conclusion

Alcohol sale begins with legal eligibility, adult verification, privacy minimization, staff confirmation, and evidence.

The safe alcohol sale boundary flow is:

    alcohol item selected
        -> adult verification trigger
        -> verification status
        -> hold if failed or uncertain
        -> staff confirmation if required
        -> payment and KDS boundary review
        -> allow, split, cancel, or refuse service
        -> evidence capture
        -> support/legal/compliance handoff if needed

This document ensures that alcohol-related ordering cannot be treated as ordinary menu selection and that adult verification, privacy, staff confirmation, KDS release, payment handling, service refusal, and legal sale boundaries are defined before implementation.