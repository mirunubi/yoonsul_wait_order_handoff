# 08030_Policy_Table_Session_Alcohol_Add_On_Partial_Settlement_And_Mid_Meal_Payment

## 1. Purpose

This document defines the table session alcohol add-on, partial settlement, mid-meal payment, split payment, table participant boundary, alcohol re-order, payment/KDS hold, staff confirmation, dispute evidence, and implementation deferral policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined alcohol order identity privacy, CI/DI handling, verification evidence, masking, logs, support visibility, and identity leakage prevention.

This document focuses on table-level operational complexity when alcohol is added to a table session before, during, or after food ordering and payment.

This document does not implement table session logic, POS split payment, payment API, KDS ticketing, identity verification, delivery platform integration, or UI.

It defines table session alcohol add-on and partial settlement boundary policy only.

---

## 2. Scope

This document covers:

- table session boundary
- alcohol add-on order
- mid-meal payment
- partial settlement
- split payment
- table participant ambiguity
- adult verification linkage
- staff confirmation
- KDS hold/release
- payment hold/reconciliation
- refund/cancel dispute
- evidence requirement
- no-implementation boundary

This document does not cover:

- final POS implementation
- final payment gateway implementation
- final KDS implementation
- final table UI
- final split bill UI
- final identity provider integration
- final legal alcohol sale rule
- final delivery alcohol rule
- final accounting treatment

---

## 3. Core Principle

A table session is not the same as one customer, one order, or one payment.

The project must follow this rule:

> Alcohol add-on and partial settlement must preserve table session context, individual eligibility risk, payment truth, KDS truth, staff confirmation, and evidence so that mid-meal changes do not become silent order mutation, disputed payment, illegal service, or kitchen execution error.

One table does not equal one verified adult.

One payment does not equal final table closure.

One add-on does not equal safe fulfillment.

---

## 4. Table Session Meaning

A table session is the operational context connecting:

- physical table
- seated customer group
- customer session
- order session
- staff interaction
- payment state
- KDS tickets
- add-on orders
- partial settlements
- service state
- evidence records

Table session should survive multiple orders and payments until table closure.

---

## 5. Table Session Risk In Alcohol Mode

Alcohol mode increases table session risk because:

- multiple people may share one table
- only one person may be verified
- additional customers may join later
- alcohol may be added after food order
- partial payment may happen before alcohol add-on
- one customer may pay for another
- intoxication may affect intent
- staff may add order manually
- service refusal may occur after partial service
- KDS may prepare before eligibility is clear
- refund/cancel dispute may involve prepared items

Alcohol mode requires stronger table state visibility.

---

## 6. Table Session Status Values

Recommended table session status values:

- `TABLE_SESSION_NOT_STARTED`
- `TABLE_SESSION_OPEN`
- `TABLE_SESSION_ORDERING`
- `TABLE_SESSION_FOOD_ORDERED`
- `TABLE_SESSION_ALCOHOL_REVIEW_REQUIRED`
- `TABLE_SESSION_PARTIAL_SETTLEMENT_ACTIVE`
- `TABLE_SESSION_SPLIT_PAYMENT_ACTIVE`
- `TABLE_SESSION_ADD_ON_ACTIVE`
- `TABLE_SESSION_STAFF_CONFIRMATION_REQUIRED`
- `TABLE_SESSION_SERVICE_REFUSAL_REVIEW`
- `TABLE_SESSION_PAYMENT_REVIEW_REQUIRED`
- `TABLE_SESSION_KDS_HOLD_ACTIVE`
- `TABLE_SESSION_CLOSING`
- `TABLE_SESSION_CLOSED`
- `TABLE_SESSION_DISPUTED`

Final names may be normalized later.

---

## 7. Table Participant Boundary

Table participant boundary means the system should not assume:

- all seated people are verified
- payer is the drinker
- table representative can consent for everyone
- previous verifier remains present
- late-joining person is eligible
- staff knows every participant automatically
- split payer is legally responsible recipient
- delivery pickup person matches order account

Participant ambiguity must be treated conservatively.

---

## 8. Participant Verification Status Values

Recommended participant verification status values:

- `PARTICIPANT_NOT_IDENTIFIED`
- `PARTICIPANT_VERIFICATION_NOT_REQUIRED`
- `PARTICIPANT_VERIFICATION_REQUIRED`
- `PARTICIPANT_VERIFICATION_PENDING`
- `PARTICIPANT_VERIFICATION_PASSED`
- `PARTICIPANT_VERIFICATION_FAILED`
- `PARTICIPANT_VERIFICATION_UNCERTAIN`
- `PARTICIPANT_MANUAL_CONFIRMED`
- `PARTICIPANT_LEFT_TABLE`
- `PARTICIPANT_UNKNOWN`

The project may later decide whether participant-level tracking is implemented.

This document only defines the risk boundary.

---

## 9. Alcohol Add-On Meaning

Alcohol add-on means alcohol is added after an initial table session already exists.

Examples:

- alcohol added after food order
- alcohol added after food payment
- alcohol added after partial settlement
- alcohol added by another customer at same table
- alcohol added by staff
- alcohol added during KDS preparation
- alcohol added after table transfer
- alcohol added after customer appears intoxicated
- alcohol added after delivery platform order conflicts with kitchen capacity

Alcohol add-on is not ordinary quantity increase.

---

## 10. Alcohol Add-On Trigger

Alcohol add-on trigger should occur when:

- alcohol item is added to existing table order
- alcohol quantity increases
- alcohol combo is added
- customer reorders alcohol
- staff adds alcohol manually
- alcohol is added after partial payment
- alcohol is added after KDS already started food
- alcohol is added after verification expired
- alcohol is added by unverified participant
- alcohol is added during service refusal review

Trigger must initiate verification and staff confirmation review as needed.

---

## 11. Add-On Status Values

Recommended alcohol add-on status values:

- `ADD_ON_NOT_STARTED`
- `ADD_ON_REQUESTED`
- `ADD_ON_VERIFICATION_REQUIRED`
- `ADD_ON_STAFF_CONFIRMATION_REQUIRED`
- `ADD_ON_PAYMENT_REQUIRED`
- `ADD_ON_PAYMENT_UNCERTAIN`
- `ADD_ON_KDS_HOLD`
- `ADD_ON_ALLOWED`
- `ADD_ON_REJECTED`
- `ADD_ON_CANCELLED`
- `ADD_ON_SERVICE_REFUSAL_REVIEW`
- `ADD_ON_DISPUTED`

Add-on status must remain visible to staff.

---

## 12. Mid-Meal Payment Meaning

Mid-meal payment means payment occurs while table session remains open.

Examples:

- customer pays food first and orders alcohol later
- customer pays alcohol separately
- one customer leaves and pays their share
- group splits bill before final table close
- customer prepays add-on
- partial settlement occurs before KDS completes
- staff collects payment after service refusal decision

Mid-meal payment must not automatically close the table.

---

## 13. Partial Settlement Meaning

Partial settlement means some but not all financial obligations of a table session are settled.

Partial settlement may apply to:

- selected items
- selected participants
- selected order rounds
- non-alcohol portion only
- alcohol portion only
- deposit/prepayment
- delivery/hall split
- service-refused item adjustment
- cancelled item adjustment

Partial settlement must preserve open balance and item status.

---

## 14. Partial Settlement Status Values

Recommended values:

- `PARTIAL_SETTLEMENT_NOT_STARTED`
- `PARTIAL_SETTLEMENT_REQUESTED`
- `PARTIAL_SETTLEMENT_IN_PROGRESS`
- `PARTIAL_SETTLEMENT_PAYMENT_PENDING`
- `PARTIAL_SETTLEMENT_PAYMENT_CONFIRMED`
- `PARTIAL_SETTLEMENT_PAYMENT_UNCERTAIN`
- `PARTIAL_SETTLEMENT_REVIEW_REQUIRED`
- `PARTIAL_SETTLEMENT_COMPLETED`
- `PARTIAL_SETTLEMENT_FAILED`
- `PARTIAL_SETTLEMENT_DISPUTED`
- `PARTIAL_SETTLEMENT_REVERSED`

Partial settlement status must not be hidden.

---

## 15. Split Payment Boundary

Split payment may involve:

- item-based split
- participant-based split
- equal split
- manual split
- alcohol-only split
- non-alcohol-only split
- staff-assisted split
- platform-assisted split
- refund-adjusted split

Split payment must not alter order truth silently.

Payment split must be linked to item/session evidence.

---

## 16. Split Payment Risk

Split payment risk includes:

- one payer pays for alcohol consumed by another
- unverified participant attempts alcohol payment
- payment succeeds but verification fails
- payment fails after KDS released
- refund applies to wrong participant
- dispute over who ordered
- table representative pays without group clarity
- staff manually allocates wrong item
- provider callback maps to wrong split

Split payment requires conservative evidence.

---

## 17. Alcohol Add-On Verification Rule

For alcohol add-on:

- verification must be checked again if required
- expired verification must not be reused silently
- new participant may require verification
- staff confirmation may be required
- KDS release must wait for eligibility
- payment must not imply eligibility
- service refusal review may block add-on
- evidence must link add-on to table session

Add-on verification should be close to service event.

---

## 18. Alcohol Add-On Staff Confirmation Rule

Staff confirmation should be required when:

- add-on occurs after partial settlement
- add-on occurs after customer appears intoxicated
- add-on quantity exceeds safe threshold
- add-on requester differs from verified person
- add-on is staff-entered
- add-on follows failed/uncertain verification
- add-on occurs near closing/night risk period
- table participant ambiguity exists
- dispute risk is high

Staff confirmation must record reason and actor.

---

## 19. Add-On Payment Boundary

Alcohol add-on payment should not be final service proof.

Payment may be:

- not started
- authorization pending
- confirmed
- uncertain
- failed
- reversed
- split from food
- linked to participant
- linked to table session

Payment confirmed does not override failed verification.

Payment failed should block or hold KDS release where required.

---

## 20. Add-On KDS Boundary

KDS must receive alcohol add-on only when allowed by policy.

KDS hold is required when:

- verification pending
- verification failed
- verification uncertain
- staff confirmation pending
- payment uncertain
- service refusal review active
- participant mismatch exists
- table session disputed
- provider event stale

KDS should receive safe hold/release status, not identity data.

---

## 21. Table Add-On KDS Status Values

Recommended values:

- `ADD_ON_KDS_NOT_CREATED`
- `ADD_ON_KDS_HOLD_VERIFICATION`
- `ADD_ON_KDS_HOLD_STAFF_CONFIRMATION`
- `ADD_ON_KDS_HOLD_PAYMENT`
- `ADD_ON_KDS_HOLD_SERVICE_REFUSAL`
- `ADD_ON_KDS_READY_TO_RELEASE`
- `ADD_ON_KDS_RELEASED`
- `ADD_ON_KDS_CANCELLED`
- `ADD_ON_KDS_DISPUTED`

KDS status must be evidence-linked.

---

## 22. Non-Alcohol Continuation Rule

If alcohol add-on fails or is held:

- non-alcohol food order may continue if safe
- existing KDS food tickets should not be cancelled automatically
- payment split should preserve non-alcohol settlement
- customer communication should explain alcohol hold separately
- evidence should show separated handling

Alcohol failure should not necessarily block entire meal.

But table-level dispute may still require staff review.

---

## 23. Table Transfer Rule

If table changes during alcohol mode:

- table session must preserve lineage
- add-on order must preserve original context
- verification status must be reviewed
- participant presence may need reconfirmation
- partial settlement must not be lost
- KDS tickets must not duplicate
- staff confirmation may be required
- evidence must link old and new table context

Table transfer can create eligibility and payment confusion.

---

## 24. Late Joining Participant Rule

If a participant joins after alcohol ordering started:

- system must not assume they are verified
- staff may need visual/manual confirmation
- additional alcohol order may require new verification
- split payment may need participant review
- service refusal may apply to new participant
- evidence should record ambiguity where relevant

Late joining participant risk must be handled conservatively.

---

## 25. Customer Leaves Before Settlement Rule

If customer leaves before final settlement:

- open balance must remain visible
- paid items and unpaid items must be separated
- alcohol item responsibility must be reviewed
- service/refund/cancel state must be reviewed
- staff note may be required
- dispute evidence must be captured
- store manager escalation may be needed

Table closure must not hide unresolved settlement.

---

## 26. Staff Manual Add-On Rule

When staff manually adds alcohol:

- staff actor must be recorded
- reason must be recorded
- verification status must be checked
- staff confirmation may be required separately
- payment/KDS boundary must be respected
- customer communication should be clear
- evidence must show manual origin

Manual add-on must not bypass customer eligibility.

---

## 27. Mistouch Add-On Rule

If add-on may be accidental:

- confirmation step should be available
- repeated tap should be detected if possible later
- staff review may be required
- payment should not be forced
- KDS should hold until confirmation
- cancellation path should be clear
- evidence should record suspected mistouch category

Mistouch risk is higher in alcohol mode.

---

## 28. Add-On Dispute Rule

Add-on dispute may occur when:

- customer denies ordering
- customer claims wrong quantity
- customer claims wrong participant ordered
- customer claims staff added incorrectly
- customer claims payment was unintended
- customer claims alcohol was not served
- customer claims service refusal after payment
- KDS already prepared item
- partial settlement allocation is disputed

Dispute requires evidence review.

---

## 29. Add-On Dispute Status Values

Recommended values:

- `ADD_ON_DISPUTE_NOT_OPEN`
- `ADD_ON_DISPUTE_OPEN`
- `ADD_ON_DISPUTE_EVIDENCE_REVIEW`
- `ADD_ON_DISPUTE_PAYMENT_REVIEW`
- `ADD_ON_DISPUTE_KDS_REVIEW`
- `ADD_ON_DISPUTE_STAFF_REVIEW`
- `ADD_ON_DISPUTE_CUSTOMER_RECOVERY`
- `ADD_ON_DISPUTE_RESOLVED`
- `ADD_ON_DISPUTE_ESCALATED`

Dispute status should link to support and evidence.

---

## 30. Evidence Requirement

Table alcohol add-on evidence should include:

- table session id
- add-on order reference
- alcohol item classification
- requester or safe session reference
- verification status
- staff confirmation status
- payment status
- partial settlement status
- split payment reference if any
- KDS hold/release status
- service refusal review if any
- customer communication status
- dispute status if any
- staff actor if manual
- timestamps
- masking status

Evidence must avoid raw identity data.

---

## 31. Table Alcohol Evidence ID Format

Recommended format:

    TABLE-ALCOHOL-EVIDENCE-[YYYYMMDD]-[NUMBER]

Example:

    TABLE-ALCOHOL-EVIDENCE-20260612-001

Final format may be normalized later.

---

## 32. Payment Evidence Linkage Rule

Payment evidence should link:

- payment attempt
- payment confirmation
- payment uncertainty
- split allocation
- refund/cancel request
- reversal if any
- provider callback reference
- customer recovery
- disputed item
- table session reference

Payment evidence must not overwrite table session evidence.

---

## 33. KDS Evidence Linkage Rule

KDS evidence should link:

- KDS ticket creation
- KDS hold reason
- KDS release decision
- KDS cancel decision
- staff approval
- duplicate suspicion
- preparation status
- manual kitchen note
- table session reference
- add-on order reference

KDS evidence must preserve kitchen execution timeline.

---

## 34. Customer Communication Rule

Customer communication should be clear:

- alcohol add-on requires confirmation
- adult verification may be required again
- payment and service may be separate steps
- non-alcohol order may continue
- staff may assist partial settlement
- disputed add-on will be reviewed

Avoid blaming customer.

Avoid exposing identity details.

---

## 35. Staff Communication Rule

Staff screen should show:

- table session status
- add-on status
- verification requirement
- staff confirmation requirement
- partial settlement status
- payment uncertainty
- KDS hold reason
- service refusal review
- next safe action
- evidence requirement

Staff should not need to infer state from multiple systems.

---

## 36. Admin Console Boundary

Future Admin Console may show:

- table alcohol add-on count
- partial settlement active count
- disputed add-on count
- staff confirmation pending
- KDS hold count
- payment uncertainty count
- service refusal review
- evidence completeness

Admin Console must not directly approve alcohol add-on without staff/runtime workflow.

Admin Console must not show raw identity data.

---

## 37. Support Boundary

Support may assist when:

- add-on dispute occurs
- partial settlement is unclear
- payment uncertainty exists
- KDS release was wrong
- staff confirmation missing
- customer recovery required
- provider callback mismatched
- evidence incomplete

Support must remain masked and case-scoped.

Support must not rewrite table settlement truth.

---

## 38. Commercial Boundary

Alcohol add-on and partial settlement may affect:

- support workload
- payment provider complexity
- KDS complexity
- staff training fee
- night operation support tier
- incident support cost
- provider gateway complexity
- pilot limitation
- package eligibility

High-risk alcohol settlement should not be bundled casually into basic SaaS package.

---

## 39. Legal/Compliance Handoff

Legal/compliance review may be needed for:

- alcohol sale timing
- eligible recipient
- service refusal
- partial refund after alcohol preparation/service
- table-level adult verification
- manual staff confirmation
- evidence retention
- dispute record handling
- delivery/pickup if involved

This document does not provide legal conclusion.

---

## 40. Implementation Deferral Boundary

This document does not authorize:

- alcohol add-on implementation
- partial settlement implementation
- split payment implementation
- table participant tracking
- alcohol KDS hold logic
- staff confirmation UI
- refund/cancel automation
- Admin Console table alcohol screen
- provider callback implementation
- delivery alcohol integration

Implementation requires separate readiness and build approval.

---

## 41. Registers Recommendation

Recommended future files:

    docs/_index/
      Table_Session_Status_Register.md
      Table_Participant_Verification_Register.md
      Alcohol_Add_On_Status_Register.md
      Partial_Settlement_Register.md
      Split_Payment_Risk_Register.md
      Table_Add_On_KDS_Status_Register.md
      Alcohol_Add_On_Dispute_Register.md
      Table_Alcohol_Evidence_Register.md

This document only recommends these files.

It does not create them.

---

## 42. Anti-Patterns

The following are prohibited:

- treating table as one verified customer
- treating food payment as table closure
- adding alcohol after partial settlement without review
- sending alcohol add-on to KDS before verification
- treating payment success as legal eligibility
- hiding partial settlement uncertainty
- allowing staff manual add-on without evidence
- allowing repeated drunk tap to create final order
- losing table lineage after table transfer
- ignoring late-joining participant risk
- closing table with unresolved alcohol dispute
- exposing raw identity data in settlement view
- merging split payments without item evidence
- refunding/cancelling without KDS and service state review

---

## 43. Non-Goals

This document does not define:

- final table session schema
- final POS split payment flow
- final payment provider logic
- final KDS integration
- final staff UI
- final customer UI
- final identity verification implementation
- final legal compliance rule
- final accounting treatment
- final delivery platform implementation

Those belong to later legal, compliance, UI, payment, KDS, and implementation planning.

---

## 44. Readiness Check

This document is ready when the project can answer:

1. What does table session mean?
2. Why does alcohol mode increase table session risk?
3. What table session status values exist?
4. What is table participant boundary?
5. What participant verification statuses exist?
6. What does alcohol add-on mean?
7. When is alcohol add-on triggered?
8. What add-on status values exist?
9. What does mid-meal payment mean?
10. What does partial settlement mean?
11. What partial settlement statuses exist?
12. What split payment boundary applies?
13. What split payment risks exist?
14. What alcohol add-on verification rule applies?
15. What staff confirmation rule applies?
16. What add-on payment boundary applies?
17. What add-on KDS boundary applies?
18. What table add-on KDS statuses exist?
19. What non-alcohol continuation rule applies?
20. What table transfer rule applies?
21. What late joining participant rule applies?
22. What customer leaves before settlement rule applies?
23. What staff manual add-on rule applies?
24. What mistouch add-on rule applies?
25. What add-on dispute rule applies?
26. What add-on dispute statuses exist?
27. What evidence is required?
28. How is payment evidence linked?
29. How is KDS evidence linked?
30. What customer communication rule applies?
31. What staff communication rule applies?
32. What Admin Console boundary applies?
33. What support boundary applies?
34. What commercial boundary applies?
35. What legal/compliance handoff is needed?
36. What implementation deferral boundary applies?
37. What anti-patterns are prohibited?

If these questions cannot be answered, table session alcohol add-on, partial settlement, and mid-meal payment planning is incomplete.

---

## 45. Conclusion

Alcohol add-on during an active table session creates one of the most complex operational edge cases in the system.

The safe table alcohol flow is:

    table session open
        -> alcohol add-on requested
        -> participant and verification review
        -> staff confirmation if needed
        -> payment and partial settlement review
        -> KDS hold or release
        -> service, refusal, cancel, or dispute handling
        -> evidence linkage
        -> table closure only after unresolved risk is cleared

This document ensures that alcohol add-on, partial settlement, split payment, table transfer, late participants, mistouch, staff manual add-on, KDS release, and payment dispute are handled as high-risk foundation policy before implementation.