# 004013_Policy_Alcohol_KDS_Hold_Staff_Approval_Cancel_And_Service_Refusal_Boundary.md

## 1. Purpose

This document defines the alcohol KDS hold, staff approval, kitchen release, cancel, service refusal, KDS evidence, payment dependency, verification dependency, customer recovery, and implementation deferral policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined night operation delivery platform concurrency, KDS synchronization, sold-out conflict, cancellation synchronization, provider validation, and delivery platform pause policy.

This document focuses on the KDS execution boundary for alcohol-related orders and alcohol-adjacent orders.

This document does not implement KDS, POS, payment, staff approval UI, alcohol verification integration, kitchen routing, or service refusal automation.

It defines alcohol KDS hold, staff approval, cancel, and service refusal boundary policy only.

---

## 2. Scope

This document covers:

- alcohol KDS hold
- KDS release condition
- staff approval
- manager approval
- payment dependency
- adult verification dependency
- service refusal review
- cancellation before preparation
- cancellation after preparation
- kitchen evidence
- customer recovery
- no-implementation boundary

This document does not cover:

- final KDS implementation
- final POS implementation
- final payment implementation
- final staff UI
- final kitchen screen UI
- final adult verification provider
- final legal service refusal standard
- final kitchen SOP
- final delivery platform integration
- final refund execution

---

## 3. Core Principle

Alcohol-related KDS execution must be held until legal, payment, staff, and service conditions are safe.

The project must follow this rule:

> Alcohol-related orders must not be released to kitchen execution when adult verification, payment certainty, staff confirmation, table context, service refusal review, provider mapping, or customer intent remains uncertain.

KDS execution is operational commitment.

Alcohol KDS release must be conservative.

---

## 4. Alcohol KDS Boundary Meaning

Alcohol KDS boundary means the point where an alcohol-related order becomes executable by kitchen or staff.

This boundary must consider:

- adult verification
- legal sale eligibility
- payment status
- table/session context
- staff confirmation
- manager confirmation
- service refusal review
- customer intent ambiguity
- KDS workload
- provider event validity
- delivery/pickup context
- cancellation/refund state
- evidence readiness

Alcohol KDS boundary must not be treated as ordinary food ticket creation.

---

## 5. Alcohol KDS Ticket Classification

Recommended alcohol KDS ticket classifications:

- `ALCOHOL_KDS_TICKET`
- `ALCOHOL_PAIRING_TICKET`
- `ALCOHOL_SET_MENU_TICKET`
- `ALCOHOL_ADJACENT_FOOD_TICKET`
- `NON_ALCOHOL_TICKET`
- `AGE_RESTRICTED_KDS_TICKET`
- `SERVICE_REFUSAL_RELATED_TICKET`
- `ALCOHOL_UNKNOWN_KDS_CLASSIFICATION`

Classification determines hold and release policy.

---

## 6. Alcohol KDS Status Values

Recommended alcohol KDS status values:

- `ALCOHOL_KDS_NOT_CREATED`
- `ALCOHOL_KDS_HOLD_VERIFICATION`
- `ALCOHOL_KDS_HOLD_PAYMENT`
- `ALCOHOL_KDS_HOLD_STAFF_CONFIRMATION`
- `ALCOHOL_KDS_HOLD_MANAGER_APPROVAL`
- `ALCOHOL_KDS_HOLD_SERVICE_REFUSAL_REVIEW`
- `ALCOHOL_KDS_HOLD_CUSTOMER_INTENT`
- `ALCOHOL_KDS_HOLD_PROVIDER_MAPPING`
- `ALCOHOL_KDS_READY_TO_RELEASE`
- `ALCOHOL_KDS_RELEASED`
- `ALCOHOL_KDS_CANCELLED_BEFORE_PREP`
- `ALCOHOL_KDS_CANCEL_REVIEW_AFTER_PREP`
- `ALCOHOL_KDS_SERVICE_REFUSED`
- `ALCOHOL_KDS_DISPUTED`
- `ALCOHOL_KDS_CLOSED`

Final names may be normalized later.

---

## 7. KDS Hold Meaning

KDS hold means the order exists as a pending operational candidate but is not executable by kitchen or service staff.

KDS hold may apply to:

- alcohol item
- alcohol set menu
- alcohol pairing item
- alcohol-related table add-on
- alcohol-related delivery item if later allowed
- alcohol-adjacent food item if fulfillment depends on alcohol decision
- disputed item
- service-refusal-related item

Hold protects kitchen from executing unsafe order.

---

## 8. KDS Hold Triggers

Alcohol KDS hold should be triggered when:

- adult verification required
- adult verification pending
- adult verification failed
- adult verification uncertain
- verification provider unavailable
- staff confirmation required
- manager confirmation required
- payment uncertain
- payment failed
- table context uncertain
- customer intent unclear
- mistouch risk active
- service refusal review active
- provider mapping incomplete
- cancellation pending
- delivery recipient unclear
- legal review required

Hold should be automatic where policy requires.

---

## 9. KDS Release Meaning

KDS release means the alcohol-related item may proceed to preparation, service, or fulfillment.

KDS release does not mean:

- legal conclusion beyond policy
- customer identity exposure
- refund impossibility
- dispute impossibility
- manager approval for all future orders
- permanent verification

KDS release is scoped to a specific order/session/item.

---

## 10. KDS Release Required Conditions

KDS release requires:

- alcohol item classification known
- adult verification passed or valid manual confirmation
- staff confirmation completed if required
- manager confirmation completed if required
- payment state acceptable under policy
- table/session context valid
- no active service refusal review
- no active mistouch dispute
- no provider mapping uncertainty
- no cancellation pending
- evidence packet created or linked
- KDS ticket duplication ruled out

If any required condition is missing, hold remains.

---

## 11. Staff Approval Meaning

Staff approval means a trained staff member confirms that an alcohol-related order may proceed within store operating policy.

Staff approval may confirm:

- customer-facing confirmation occurred
- adult verification status reviewed
- table/session context is correct
- payment/KDS hold reason resolved
- customer intent seems clear enough
- service refusal not required
- KDS may be released

Staff approval must not bypass legal verification.

---

## 12. Staff Approval Status Values

Recommended values:

- `STAFF_APPROVAL_NOT_REQUIRED`
- `STAFF_APPROVAL_REQUIRED`
- `STAFF_APPROVAL_PENDING`
- `STAFF_APPROVAL_COMPLETED`
- `STAFF_APPROVAL_REJECTED`
- `STAFF_APPROVAL_ESCALATED`
- `STAFF_APPROVAL_EXPIRED`
- `STAFF_APPROVAL_DISPUTED`

Staff approval status must be evidence-linked.

---

## 13. Staff Approval Record Fields

Each staff approval record should include:

- staff approval id
- order/session reference
- KDS ticket reference
- table reference
- staff actor
- approval reason
- verification status
- payment status
- customer intent status
- service refusal status
- decision
- timestamp
- evidence packet reference
- notes

Staff approval must be auditable.

---

## 14. Staff Approval ID Format

Recommended format:

    ALCOHOL-STAFF-APPROVAL-[YYYYMMDD]-[NUMBER]

Example:

    ALCOHOL-STAFF-APPROVAL-20260612-001

Final format may be normalized later.

---

## 15. Manager Approval Rule

Manager approval may be required when:

- service refusal is possible
- customer is visibly intoxicated
- high quantity alcohol order exists
- staff safety risk exists
- customer disputes order intent
- payment/refund dispute exists
- KDS already prepared disputed item
- minor access risk exists
- repeated misoperation continues
- delivery/pickup recipient mismatch exists

Manager approval must be recorded separately from ordinary staff approval.

---

## 16. Manager Approval Status Values

Recommended values:

- `MANAGER_APPROVAL_NOT_REQUIRED`
- `MANAGER_APPROVAL_REQUIRED`
- `MANAGER_APPROVAL_PENDING`
- `MANAGER_APPROVAL_COMPLETED`
- `MANAGER_APPROVAL_REJECTED`
- `MANAGER_APPROVAL_ESCALATED`
- `MANAGER_APPROVAL_EXPIRED`
- `MANAGER_APPROVAL_DISPUTED`

Manager approval is high-risk evidence.

---

## 17. Payment Dependency Rule

Alcohol KDS release must consider payment state.

Payment states that may block release:

- payment not started
- payment pending
- payment uncertain
- payment failed
- duplicate payment suspicion
- refund/cancel review active
- split payment unresolved
- partial settlement unclear
- provider callback stale
- provider callback duplicate

Payment success does not override verification failure.

Payment uncertainty must not be hidden from KDS release decision.

---

## 18. Adult Verification Dependency Rule

Alcohol KDS release must consider verification state.

Verification states that block release:

- verification required
- verification pending
- verification failed
- verification uncertain
- verification expired
- verification provider unavailable
- manual verification not recorded
- recipient mismatch
- service refusal review active

Verification must be resolved before alcohol execution.

---

## 19. Customer Intent Dependency Rule

Alcohol KDS release must consider intent ambiguity.

Intent risk may exist when:

- repeated tap occurred
- quantity escalation occurred
- wrong item suspected
- wrong table suspected
- customer disputed order
- staff reported confusion
- customer appears intoxicated
- payment intent unclear
- add-on occurred after partial settlement

Intent risk may require staff or manager approval before KDS release.

---

## 20. Provider Mapping Dependency Rule

Provider-originated alcohol or alcohol-adjacent orders must not be released until:

- provider event validated
- store mapping confirmed
- item mapping confirmed
- duplicate ruled out
- stale event reviewed
- cancellation status checked
- payment state understood
- delivery alcohol policy confirmed if applicable

Provider signal is not direct KDS authority.

---

## 21. Service Refusal Review Meaning

Service refusal review means staff or manager evaluates whether alcohol service should be refused due to legal, safety, verification, or customer behavior risk.

Service refusal review may be triggered by:

- verification failure
- verification uncertainty
- customer refusal to verify
- intoxication concern
- abusive behavior
- minor access risk
- payment dispute
- repeated misoperation
- staff safety risk
- legal restriction

During service refusal review, KDS release must be blocked.

---

## 22. Service Refusal Decision Values

Recommended values:

- `SERVICE_ALLOWED`
- `SERVICE_ALLOWED_WITH_WARNING`
- `SERVICE_ALLOWED_WITH_MANAGER_APPROVAL`
- `SERVICE_REFUSED_VERIFICATION`
- `SERVICE_REFUSED_INTOXICATION_RISK`
- `SERVICE_REFUSED_MINOR_RISK`
- `SERVICE_REFUSED_SAFETY_RISK`
- `SERVICE_REFUSED_PAYMENT_RISK`
- `SERVICE_REFUSED_LEGAL_REVIEW`
- `SERVICE_ESCALATED`

Decision must be respectful and evidence-linked.

---

## 23. Service Refusal Evidence Fields

Service refusal evidence should include:

- service refusal id
- order/session reference
- table reference
- staff actor
- manager actor if any
- trigger
- decision
- verification status
- payment status
- KDS status
- customer communication
- safety risk if any
- recovery action
- timestamp
- notes

Evidence should avoid accusatory language.

---

## 24. Service Refusal ID Format

Recommended format:

    ALCOHOL-SERVICE-REFUSAL-[YYYYMMDD]-[NUMBER]

Example:

    ALCOHOL-SERVICE-REFUSAL-20260612-001

Final format may be normalized later.

---

## 25. Cancel Before Preparation Rule

Alcohol-related cancellation before preparation may be allowed when:

- KDS not released
- KDS held
- payment can be reversed or adjusted
- verification failed before service
- customer cancels before confirmation
- staff rejects order before kitchen execution
- service refusal occurs before service
- duplicate provider event is detected before ticket creation

Cancellation before preparation should preserve evidence.

---

## 26. Cancel After Preparation Rule

Cancellation after preparation requires review because:

- kitchen labor occurred
- product may be wasted
- alcohol may have been served or opened
- payment/refund rule may differ
- customer intent may be disputed
- service refusal may occur after preparation
- delivery rider may be waiting
- provider cancellation may arrive late
- table partial settlement may be involved

Cancel after preparation must not be automatic.

---

## 27. Alcohol KDS Cancel Status Values

Recommended values:

- `KDS_CANCEL_NOT_REQUIRED`
- `KDS_CANCEL_REQUESTED`
- `KDS_CANCEL_BEFORE_PREP_ALLOWED`
- `KDS_CANCEL_AFTER_PREP_REVIEW`
- `KDS_CANCEL_PAYMENT_REVIEW`
- `KDS_CANCEL_SERVICE_REFUSAL`
- `KDS_CANCEL_PROVIDER_CONFLICT`
- `KDS_CANCEL_CUSTOMER_RECOVERY`
- `KDS_CANCEL_REJECTED`
- `KDS_CANCEL_COMPLETED`
- `KDS_CANCEL_DISPUTED`

Cancel status must link payment and service evidence.

---

## 28. KDS Already Prepared Rule

If KDS already prepared alcohol-related item:

- service status must be checked
- verification status must be checked
- payment status must be checked
- customer dispute must be reviewed
- service refusal decision must be reviewed
- refund/cancel path must be escalated
- waste evidence may be required
- manager approval may be required

Prepared state changes recovery options.

---

## 29. Alcohol Service Completed Rule

If alcohol was already served:

- refund/cancel must be reviewed carefully
- verification and staff approval evidence must be preserved
- customer dispute must be documented
- service refusal after service requires manager review
- payment dispute may require support escalation
- legal/compliance review may be needed
- evidence must preserve timeline

Served alcohol cannot be treated like unprepared food item.

---

## 30. Non-Alcohol KDS Continuation Rule

If alcohol item is held or refused:

- non-alcohol KDS tickets may continue if safe
- non-alcohol items should not be cancelled automatically
- staff should see separated status
- payment split may be needed
- customer communication should separate food and alcohol handling
- table session remains open if needed

Alcohol hold should not automatically disrupt entire meal unless risk affects table safety.

---

## 31. Kitchen Display Rule

Kitchen display should show:

- safe item name
- hold/release status
- reason category if operationally needed
- staff approval required
- manager approval required
- cancellation status
- service refusal status if relevant
- safe table/order reference

Kitchen display must not show:

- raw CI/DI
- raw identity data
- ID verification payload
- accusatory drunk label
- detailed legal commentary
- private customer notes

Kitchen needs execution instruction, not sensitive context.

---

## 32. Staff Display Rule

Staff display should show:

- alcohol KDS status
- verification status summary
- payment status summary
- staff approval requirement
- manager approval requirement
- KDS hold reason
- cancellation status
- service refusal review
- customer communication guidance
- next safe action

Staff display must be clear enough to prevent guessing.

---

## 33. Customer Communication Rule

Customer communication should be:

- calm
- respectful
- simple
- non-accusatory
- clear about hold/cancel/refusal status
- clear that staff will assist
- separate food from alcohol when possible

Example:

    주류 주문은 확인이 필요한 상태라 직원이 확인 후 안내드리겠습니다. 음식 주문은 가능한 범위에서 계속 진행됩니다.

Do not say:

    술 주문은 문제 있어서 주방에 못 보냅니다.
    취하신 것 같아서 막았습니다.
    신분증 문제가 있습니다.

---

## 34. Evidence Requirement

Alcohol KDS evidence should include:

- KDS evidence id
- order/session reference
- table reference
- alcohol item classification
- KDS status
- hold reason
- release decision
- staff approval reference
- manager approval reference
- verification status
- payment status
- cancellation status
- service refusal reference
- customer communication status
- timestamps
- masking status
- notes

Evidence must preserve KDS timeline.

---

## 35. Alcohol KDS Evidence ID Format

Recommended format:

    ALCOHOL-KDS-EVIDENCE-[YYYYMMDD]-[NUMBER]

Example:

    ALCOHOL-KDS-EVIDENCE-20260612-001

Final format may be normalized later.

---

## 36. Support Boundary

Support may assist when:

- KDS release occurred incorrectly
- alcohol ticket was held too long
- cancellation/refund dispute occurs
- payment and KDS states conflict
- service refusal escalates
- provider event caused duplicate KDS
- staff cannot resolve status
- evidence is incomplete

Support must remain case-scoped and masked.

Support must not directly release alcohol KDS without authorized workflow.

---

## 37. Admin Console Boundary

Future Admin Console may show:

- alcohol KDS hold count
- staff approval pending count
- manager approval pending count
- service refusal review count
- alcohol KDS cancel review count
- KDS already prepared dispute count
- evidence completeness
- support escalation status

Admin Console must not include direct unsafe release button.

Admin Console must not show raw identity data or accusatory customer labels.

---

## 38. Provider Boundary

Provider-originated alcohol KDS events require special caution.

Rules:

- provider event must be validated
- duplicate event must not create duplicate KDS ticket
- stale event must be reviewed
- delivery alcohol must remain disabled unless separately approved
- provider cancellation must be reconciled with KDS state
- provider payment state must be mapped conservatively
- provider mapping error must trigger incident

Provider signal cannot bypass alcohol KDS hold.

---

## 39. Training Boundary

Staff training must cover:

- recognizing alcohol KDS hold states
- verifying release conditions
- recording staff approval
- escalating manager approval
- cancelling before preparation
- handling cancellation after preparation
- explaining service refusal calmly
- separating food and alcohol KDS flow
- preserving evidence
- avoiding identity exposure

Alcohol KDS operation requires training before activation.

---

## 40. Commercial Boundary

Alcohol KDS boundary may affect:

- KDS module complexity
- staff training cost
- support tier
- high-risk operation package
- incident support cost
- night operation premium
- provider gateway complexity
- legal/compliance setup

Alcohol KDS support should not be treated as ordinary KDS feature.

---

## 41. Legal/Compliance Handoff

Legal/compliance review may be needed for:

- service refusal after preparation
- refund after alcohol service
- customer verification failure after payment
- staff manual approval
- evidence retention
- KDS hold wording
- delivery alcohol exclusion
- local jurisdiction alcohol handling

This document does not provide legal conclusion.

---

## 42. Implementation Deferral Boundary

This document does not authorize:

- alcohol KDS ticket implementation
- alcohol KDS hold logic
- staff approval UI
- manager approval UI
- service refusal automation
- alcohol cancel/refund automation
- provider alcohol order routing
- delivery alcohol KDS routing
- Admin Console alcohol KDS control
- legal sale activation

Implementation requires separate readiness, legal, and build approval.

---

## 43. Registers Recommendation

Recommended future files:

    docs/_index/
      Alcohol_KDS_Status_Register.md
      Alcohol_KDS_Hold_Register.md
      Alcohol_Staff_Approval_Register.md
      Alcohol_Manager_Approval_Register.md
      Alcohol_Service_Refusal_Register.md
      Alcohol_KDS_Cancel_Register.md
      Alcohol_KDS_Evidence_Register.md
      Alcohol_Kitchen_Display_Field_Register.md

This document only recommends these files.

It does not create them.

---

## 44. Anti-Patterns

The following are prohibited:

- sending alcohol item to KDS before verification
- using payment success to override verification failure
- using staff approval to bypass legal boundary
- releasing KDS during service refusal review
- hiding KDS hold reason from staff
- showing raw CI/DI in kitchen display
- labeling customer as drunk on KDS
- cancelling after preparation without review
- deleting KDS evidence after refusal
- allowing provider event to bypass KDS hold
- treating alcohol KDS as ordinary food ticket
- allowing Admin Console to directly release held alcohol without workflow
- closing dispute without payment/KDS timeline

---

## 45. Non-Goals

This document does not define:

- final KDS UI
- final kitchen SOP
- final POS/KDS API
- final payment integration
- final identity provider
- final service refusal legal standard
- final refund/cancel automation
- final delivery alcohol handling
- final Admin Console implementation

Those belong to later legal, runtime, UI, KDS, payment, provider, and implementation planning.

---

## 46. Readiness Check

This document is ready when the project can answer:

1. What is alcohol KDS boundary?
2. What alcohol KDS ticket classifications exist?
3. What alcohol KDS status values exist?
4. What does KDS hold mean?
5. What triggers KDS hold?
6. What does KDS release mean?
7. What conditions are required for KDS release?
8. What does staff approval mean?
9. What staff approval statuses exist?
10. What fields should staff approval record include?
11. When is manager approval required?
12. What manager approval statuses exist?
13. What payment dependency rule applies?
14. What adult verification dependency rule applies?
15. What customer intent dependency rule applies?
16. What provider mapping dependency rule applies?
17. What does service refusal review mean?
18. What service refusal decision values exist?
19. What service refusal evidence fields are needed?
20. When may cancellation before preparation be allowed?
21. Why does cancellation after preparation require review?
22. What alcohol KDS cancel statuses exist?
23. What KDS already prepared rule applies?
24. What alcohol service completed rule applies?
25. What non-alcohol KDS continuation rule applies?
26. What kitchen display rule applies?
27. What staff display rule applies?
28. What customer communication rule applies?
29. What evidence is required?
30. What support boundary applies?
31. What Admin Console boundary applies?
32. What provider boundary applies?
33. What training boundary applies?
34. What commercial boundary applies?
35. What legal/compliance handoff is needed?
36. What implementation deferral boundary applies?
37. What anti-patterns are prohibited?

If these questions cannot be answered, alcohol KDS hold, staff approval, cancel, and service refusal boundary planning is incomplete.

---

## 47. Conclusion

Alcohol-related KDS execution must be more conservative than normal food execution.

The safe alcohol KDS flow is:

    alcohol order candidate
        -> verification and payment review
        -> staff or manager approval if required
        -> KDS hold if any uncertainty exists
        -> KDS release only when safe
        -> cancel, refuse, or recover if not safe
        -> evidence capture
        -> support/legal/compliance handoff if needed

This document ensures that alcohol items are not prepared or served while verification, payment, customer intent, provider mapping, service refusal, cancellation, or staff approval remains unresolved.