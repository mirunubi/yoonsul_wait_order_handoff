# 08040_Policy_Drunk_Customer_Mistouch_Misoperation_Confirmation_And_Staff_Intervention

## 1. Purpose

This document defines the drunk customer mistouch, misoperation, repeated tap, wrong item selection, wrong quantity, unclear payment intent, staff confirmation, staff intervention, service refusal review, customer recovery, evidence, and implementation deferral policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined table session alcohol add-on, partial settlement, mid-meal payment, split payment, table participant ambiguity, payment/KDS hold, and dispute evidence.

This document focuses on customer intent ambiguity and operational safety when alcohol consumption may increase the likelihood of accidental or disputed touch-based ordering and payment behavior.

This document does not implement UI confirmation, touch detection, drunk detection, payment prevention, KDS hold logic, staff alerting, or customer behavior scoring.

It defines mistouch, misoperation, confirmation, and staff intervention boundary policy only.

---

## 2. Scope

This document covers:

- drunk customer mistouch risk
- repeated tap risk
- wrong item selection
- wrong quantity selection
- wrong table/session selection
- unclear payment intent
- alcohol reorder confirmation
- staff intervention
- staff confirmation
- service refusal review
- customer recovery
- evidence requirement
- no-implementation boundary

This document does not cover:

- final UI design
- final intoxication detection algorithm
- final staff safety SOP
- final legal service refusal standard
- final payment API logic
- final KDS implementation
- final customer scoring
- final camera/sensor detection
- final incident reporting system

---

## 3. Core Principle

Alcohol mode must treat customer intent as potentially less reliable.

The project must follow this rule:

> When alcohol mode is active or intoxication risk exists, repeated taps, unusual quantities, late-night add-ons, payment attempts, cancellation requests, and disputed order actions must be protected by confirmation, hold, staff review, or recovery workflows before becoming final payment, KDS, or service truth.

Mistouch is not customer fraud by default.

Misoperation is not valid intent by default.

Staff intervention is risk control, not blame.

---

## 4. Mistouch Meaning

Mistouch means a customer touch interaction that may not represent reliable order or payment intent.

Mistouch may include:

- accidental tap
- double tap
- repeated tap
- wrong menu item tap
- wrong quantity tap
- wrong table/session tap
- unintended payment button tap
- unintended cancel button tap
- unintentional alcohol reorder
- confusion caused by drunk state
- confusion caused by small screen
- confusion caused by night operation environment

Mistouch risk must be handled before dispute.

---

## 5. Misoperation Meaning

Misoperation means customer or staff operation that results in an unintended or unsafe workflow.

Misoperation may include:

- customer adds wrong alcohol item
- customer adds excessive quantity
- customer attempts payment without understanding
- customer cancels wrong item
- customer reorders after service refusal
- staff selects wrong table
- staff manually adds wrong item
- support changes wrong case
- provider callback maps to wrong order
- payment/KDS state is misunderstood

Misoperation must be detected, held, reviewed, or recovered.

---

## 6. Drunk Customer Risk Indicators

Potential drunk customer risk indicators:

- repeated alcohol reorder
- repeated touch or rapid tap
- excessive quantity selection
- repeated cancel/reorder cycle
- payment attempt followed by immediate dispute
- staff reports intoxication concern
- customer communication confusion
- customer cannot confirm order
- table dispute over who ordered
- late-night operation period
- service refusal review active
- customer behavior incident

These indicators are signals, not legal conclusions.

---

## 7. Mistouch Risk Status Values

Recommended mistouch risk status values:

- `MISTOUCH_RISK_NONE`
- `MISTOUCH_RISK_LOW`
- `MISTOUCH_RISK_WATCH`
- `MISTOUCH_RISK_CONFIRMATION_REQUIRED`
- `MISTOUCH_RISK_STAFF_REVIEW_REQUIRED`
- `MISTOUCH_RISK_PAYMENT_HOLD`
- `MISTOUCH_RISK_KDS_HOLD`
- `MISTOUCH_RISK_SERVICE_REFUSAL_REVIEW`
- `MISTOUCH_RISK_DISPUTED`
- `MISTOUCH_RISK_CLOSED`

Risk status must remain evidence-linked.

---

## 8. Misoperation Event Categories

Recommended misoperation event categories:

- `REPEATED_TAP_EVENT`
- `WRONG_ITEM_SELECTION_EVENT`
- `WRONG_QUANTITY_EVENT`
- `WRONG_TABLE_EVENT`
- `UNINTENDED_PAYMENT_EVENT`
- `UNINTENDED_CANCEL_EVENT`
- `ALCOHOL_REORDER_CONFUSION_EVENT`
- `STAFF_MANUAL_INPUT_ERROR_EVENT`
- `PAYMENT_STATE_CONFUSION_EVENT`
- `KDS_STATE_CONFUSION_EVENT`
- `SERVICE_REFUSAL_RETRY_EVENT`
- `UNKNOWN_MISOPERATION_EVENT`

Event category guides recovery.

---

## 9. Repeated Tap Rule

Repeated tap should be treated as risk when:

- same alcohol item is tapped repeatedly
- same payment button is tapped repeatedly
- quantity increases rapidly
- customer repeats order after error
- customer repeats cancel/reorder cycle
- network delay may have caused repeated tap
- device lag may have caused repeated tap
- night/alcohol mode is active

Repeated tap should not create duplicate order or duplicate payment without confirmation.

---

## 10. Quantity Escalation Rule

Quantity escalation should trigger confirmation when:

- alcohol quantity exceeds defined threshold
- quantity increases too quickly
- quantity is unusual for table size
- quantity increases after partial settlement
- quantity increases after staff warning
- quantity increases after service refusal review
- quantity increases late at night
- customer appears confused

Thresholds may be defined later.

This document defines the governance requirement only.

---

## 11. Wrong Item Selection Rule

Wrong item selection may be suspected when:

- customer immediately cancels after selection
- customer changes item repeatedly
- alcohol item selected while browsing non-alcohol category
- staff reports customer confusion
- table disputes item
- item is added in unusual sequence
- selected item conflicts with previous preference or restriction
- customer claims not intended

Wrong item suspicion should create review before irreversible fulfillment.

---

## 12. Wrong Table Or Session Rule

Wrong table/session risk may occur when:

- customer scans wrong table object
- staff moves table
- table transfer occurred
- customer uses old session
- shared device is used
- QR/NFC context stale
- multiple tables are open nearby
- support/staff selects wrong table
- customer joins another table

Wrong table risk must block alcohol fulfillment until context is verified.

---

## 13. Payment Intent Ambiguity Rule

Payment intent ambiguity exists when:

- customer taps payment repeatedly
- customer disputes immediately after payment
- customer appears confused
- payment occurs after service refusal review started
- payment occurs for alcohol while verification is pending
- partial settlement is unclear
- split payer differs from alcohol recipient
- provider callback is delayed or duplicated
- payment screen was stale

Payment intent ambiguity should trigger payment review, not automatic blame.

---

## 14. Confirmation Requirement Rule

Confirmation should be required when:

- alcohol order is added in high-risk context
- repeated tap detected
- quantity escalation detected
- verification uncertain
- staff reports intoxication concern
- customer appears confused
- payment intent ambiguous
- KDS release would be irreversible
- service refusal review active
- table participant ambiguity exists
- late-night mode active with risk signal

Confirmation should be clear and low-friction but safety-oriented.

---

## 15. Confirmation Types

Recommended confirmation types:

- `CUSTOMER_CONFIRMATION`
- `STAFF_CONFIRMATION`
- `MANAGER_CONFIRMATION`
- `PAYMENT_CONFIRMATION`
- `KDS_RELEASE_CONFIRMATION`
- `SERVICE_REFUSAL_CONFIRMATION`
- `CANCEL_CONFIRMATION`
- `REFUND_REVIEW_CONFIRMATION`
- `TABLE_CONTEXT_CONFIRMATION`
- `MANUAL_RECOVERY_CONFIRMATION`

Confirmation type must match risk.

---

## 16. Customer Confirmation Boundary

Customer confirmation may be used for low or medium risk.

Customer confirmation should:

- show item
- show quantity
- show price if applicable
- show alcohol verification requirement
- show payment implication
- show cancellation limitation if prepared
- avoid confusing text
- avoid hidden checkbox
- avoid accidental one-tap confirmation

Customer confirmation may not be sufficient for high-risk alcohol or intoxication cases.

---

## 17. Staff Confirmation Boundary

Staff confirmation is required when customer confirmation is insufficient.

Staff confirmation should record:

- staff actor
- reason
- table/session
- item/quantity
- verification status
- payment status
- KDS status
- customer communication
- decision
- timestamp

Staff confirmation must not bypass legal verification.

---

## 18. Manager Confirmation Boundary

Manager confirmation may be required when:

- service refusal risk exists
- customer dispute escalates
- payment/refund dispute involves alcohol
- staff safety risk exists
- high quantity alcohol order is requested
- intoxication concern is serious
- repeated misoperation continues
- KDS already prepared disputed item
- store closure or police/security escalation may be needed

Manager confirmation should be evidence-linked.

---

## 19. Confirmation Status Values

Recommended confirmation status values:

- `CONFIRMATION_NOT_REQUIRED`
- `CONFIRMATION_REQUIRED`
- `CONFIRMATION_PENDING`
- `CONFIRMATION_COMPLETED`
- `CONFIRMATION_REJECTED`
- `CONFIRMATION_EXPIRED`
- `CONFIRMATION_ESCALATED`
- `CONFIRMATION_BLOCKED`
- `CONFIRMATION_DISPUTED`

Confirmation status must be visible to staff.

---

## 20. Confirmation Expiration Rule

Confirmation should expire when:

- table session changes
- customer leaves table
- payment state changes
- KDS state changes
- verification expires
- service refusal review starts
- staff shift changes if required
- time limit passes
- suspicious activity appears

Expired confirmation must not authorize later fulfillment.

---

## 21. KDS Hold Rule

KDS hold is required when:

- mistouch risk requires confirmation
- misoperation is suspected
- verification is pending
- staff confirmation is pending
- payment intent is ambiguous
- table context is uncertain
- service refusal review is active
- customer dispute is open
- provider event is stale or duplicate

KDS hold protects kitchen execution.

---

## 22. Payment Hold Rule

Payment hold or review may be required when:

- repeated payment tap occurs
- verification incomplete
- customer intent unclear
- split payment ambiguous
- partial settlement unclear
- service refusal review active
- provider callback duplicated
- customer disputes immediately
- table/session context uncertain

Payment should not convert ambiguous intent into final dispute.

---

## 23. Cancel And Refund Boundary

Cancel/refund review is required when:

- customer claims mistouch
- alcohol item already KDS released
- alcohol item already served
- payment confirmed but intent disputed
- verification failed after payment
- service refusal occurs after payment
- split settlement involved
- table dispute exists
- provider callback mismatch exists

Refund/cancel should consider payment, KDS, service, and evidence state.

---

## 24. Staff Intervention Meaning

Staff intervention means a trained staff member steps into the flow to assess and resolve high-risk ambiguity.

Intervention may include:

- confirming order
- explaining verification
- holding KDS release
- cancelling alcohol item
- splitting non-alcohol order
- requesting manager
- refusing service
- starting customer recovery
- recording evidence
- escalating support or safety issue

Staff intervention must be supported by clear system state.

---

## 25. Staff Intervention Status Values

Recommended values:

- `INTERVENTION_NOT_REQUIRED`
- `INTERVENTION_REQUIRED`
- `INTERVENTION_PENDING`
- `INTERVENTION_IN_PROGRESS`
- `INTERVENTION_COMPLETED`
- `INTERVENTION_ESCALATED`
- `INTERVENTION_FAILED`
- `INTERVENTION_CUSTOMER_RECOVERY_REQUIRED`
- `INTERVENTION_SAFETY_ESCALATION_REQUIRED`

Intervention status should be visible in staff operations.

---

## 26. Staff Intervention Record Fields

Each staff intervention record should include:

- intervention id
- table/session reference
- order reference
- risk category
- staff actor
- manager actor if any
- reason
- verification status
- payment status
- KDS status
- customer communication
- decision
- evidence packet
- timestamp
- notes

Staff intervention must be auditable.

---

## 27. Staff Intervention ID Format

Recommended format:

    STAFF-INTERVENTION-[YYYYMMDD]-[NUMBER]

Example:

    STAFF-INTERVENTION-20260612-001

Final format may be normalized later.

---

## 28. Customer Recovery Rule

Customer recovery should be considered when:

- customer made accidental order
- customer disputes payment intent
- customer is embarrassed by verification failure
- customer is refused alcohol service
- customer’s non-alcohol order is delayed by review
- staff must de-escalate confusion
- table group disputes responsibility
- refund/cancel review takes time

Recovery should be respectful and safety-oriented.

---

## 29. Customer Communication Rule

Customer communication should:

- acknowledge confusion calmly
- confirm item and quantity
- explain that alcohol order requires confirmation
- explain staff will help if needed
- avoid accusing intoxication
- avoid exposing verification details
- avoid legal threats
- avoid blaming system/provider
- separate food order from alcohol hold where possible

Example:

    주문 내용 확인이 필요합니다. 중복 주문이나 잘못된 선택이 없도록 직원이 확인 후 도와드리겠습니다.

---

## 30. Staff Communication Rule

Staff communication should show:

- risk category
- table/session
- item and quantity
- verification status
- payment status
- KDS status
- required confirmation
- suggested customer wording
- safe next actions
- escalation path
- evidence requirement

Staff should not guess from scattered signals.

---

## 31. Service Refusal Review Rule

Service refusal review may be required when:

- customer appears heavily intoxicated
- customer cannot confirm order
- repeated misoperation continues
- customer becomes abusive
- verification fails
- verification is refused
- staff safety risk exists
- manager determines service is unsafe
- legal/compliance risk exists

Service refusal must be recorded respectfully.

---

## 32. Abuse And Safety Escalation Boundary

If customer behavior threatens staff or other customers:

- operational flow should prioritize safety
- alcohol service may be held or refused
- manager escalation should be available
- store closure or police/security contact may be considered under later SOP
- evidence should be recorded safely
- staff should not be forced to continue service

Safety overrides sales.

---

## 33. Evidence Requirement

Mistouch/misoperation evidence should include:

- table/session reference
- order reference
- alcohol item reference
- risk category
- touch or operation pattern summary
- verification status
- confirmation status
- staff intervention status
- payment status
- KDS status
- cancel/refund status
- customer communication status
- service refusal status if any
- support case if any
- timestamps
- masking status

Evidence must avoid accusatory language.

---

## 34. Mistouch Evidence ID Format

Recommended format:

    MISTOUCH-EVIDENCE-[YYYYMMDD]-[NUMBER]

Example:

    MISTOUCH-EVIDENCE-20260612-001

Final format may be normalized later.

---

## 35. Admin Console Boundary

Future Admin Console may show:

- mistouch risk count
- confirmation required count
- staff intervention count
- disputed alcohol order count
- KDS hold due to misoperation
- payment hold due to ambiguity
- customer recovery required
- safety escalation required

Admin Console must not label customer as drunk in casual dashboards.

Use safe categories such as:

- confirmation required
- customer intent unclear
- staff review required
- safety review required

---

## 36. Support Boundary

Support may assist when:

- payment dispute occurs
- refund/cancel review is needed
- customer recovery escalates
- evidence is incomplete
- staff is unsure how to proceed
- provider callback contributed to confusion
- KDS release happened prematurely
- billing dispute later appears

Support must remain case-scoped and masked.

Support must not blame customer or rewrite runtime truth.

---

## 37. Provider Boundary

Provider events may contribute to misoperation risk when:

- UI lag creates repeated tap
- payment callback is delayed
- payment callback duplicated
- table session context stale
- KDS event delayed
- platform order appears simultaneously
- provider error causes retry

Provider uncertainty must not be treated as customer intent.

---

## 38. Training Boundary

Staff training must later cover:

- recognizing confirmation-required states
- explaining alcohol confirmation calmly
- handling verification failure
- handling mistouch claims
- holding KDS safely
- avoiding blame language
- escalating to manager
- recording evidence
- refusing service respectfully
- protecting staff safety

Training is mandatory before alcohol mode.

---

## 39. Commercial Boundary

Mistouch and staff intervention may affect:

- support tier
- staff training fee
- high-risk operation package
- night operation support
- incident support cost
- customer recovery cost
- provider gateway complexity
- payment/KDS review burden

Alcohol mode should not be priced as ordinary ordering.

---

## 40. Legal/Compliance Handoff

Legal/compliance review may be needed for:

- service refusal wording
- handling intoxicated customers
- payment dispute after alcohol service
- refund/cancel rules
- evidence language
- adult verification failure
- staff safety escalation
- local jurisdiction alcohol rules

This document does not provide legal conclusion.

---

## 41. Implementation Deferral Boundary

This document does not authorize:

- drunk customer detection
- automated intoxication scoring
- touch-pattern scoring
- customer behavior profiling
- automatic alcohol refusal
- payment blocking logic
- KDS hold implementation
- staff intervention UI
- service refusal automation
- Admin Console mistouch dashboard

Implementation requires later readiness and legal/security review.

---

## 42. Registers Recommendation

Recommended future files:

    docs/_index/
      Mistouch_Risk_Status_Register.md
      Misoperation_Event_Register.md
      Confirmation_Type_Register.md
      Staff_Intervention_Register.md
      Mistouch_Evidence_Register.md
      Service_Refusal_Review_Register.md
      Alcohol_Customer_Recovery_Register.md
      Safety_Escalation_Register.md

This document only recommends these files.

It does not create them.

---

## 43. Anti-Patterns

The following are prohibited:

- treating repeated tap as confirmed intent
- creating duplicate alcohol orders from repeated touch
- sending suspicious alcohol order directly to KDS
- treating payment tap as valid intent under confusion
- labeling customer as drunk in casual UI
- blaming customer for mistouch
- refusing service without evidence
- hiding staff intervention
- letting support rewrite payment/KDS truth
- ignoring provider lag as cause of repeated tap
- using automated drunk scoring without governance
- forcing staff to serve during safety risk
- treating confirmation as permanent after context changes

---

## 44. Non-Goals

This document does not define:

- final touch detection algorithm
- final drunk detection method
- final staff intervention UI
- final payment blocking implementation
- final KDS hold implementation
- final legal service refusal standard
- final training script
- final safety escalation SOP
- final incident automation

Those belong to later legal, safety, UI, runtime, and training planning.

---

## 45. Readiness Check

This document is ready when the project can answer:

1. What does mistouch mean?
2. What does misoperation mean?
3. What drunk customer risk indicators exist?
4. What mistouch risk statuses exist?
5. What misoperation event categories exist?
6. What repeated tap rule applies?
7. What quantity escalation rule applies?
8. What wrong item selection rule applies?
9. What wrong table/session rule applies?
10. What payment intent ambiguity rule applies?
11. When is confirmation required?
12. What confirmation types exist?
13. What customer confirmation boundary applies?
14. What staff confirmation boundary applies?
15. What manager confirmation boundary applies?
16. What confirmation statuses exist?
17. What confirmation expiration rule applies?
18. What KDS hold rule applies?
19. What payment hold rule applies?
20. What cancel/refund boundary applies?
21. What does staff intervention mean?
22. What staff intervention statuses exist?
23. What fields should intervention record include?
24. When is customer recovery considered?
25. What customer communication rule applies?
26. What staff communication rule applies?
27. When is service refusal review required?
28. What abuse and safety escalation boundary applies?
29. What evidence is required?
30. What Admin Console boundary applies?
31. What support boundary applies?
32. What provider boundary applies?
33. What training boundary applies?
34. What commercial boundary applies?
35. What legal/compliance handoff is needed?
36. What implementation deferral boundary applies?
37. What anti-patterns are prohibited?

If these questions cannot be answered, drunk customer mistouch, misoperation, confirmation, and staff intervention planning is incomplete.

---

## 46. Conclusion

Alcohol mode makes customer intent less certain and operational mistakes more expensive.

The safe mistouch and misoperation flow is:

    risky touch or operation detected
        -> risk classification
        -> confirmation requirement
        -> staff or manager intervention if needed
        -> payment/KDS hold if required
        -> allow, cancel, refuse, or recover
        -> evidence capture
        -> support/legal/safety handoff if needed

This document ensures that accidental touch, repeated tap, wrong quantity, wrong table, ambiguous payment intent, staff manual error, and intoxication-related confusion are handled as high-risk operational states before they become disputed payment, unsafe KDS execution, customer conflict, or staff safety incidents.