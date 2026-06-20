# 008101_Policy_High_Risk_Store_Operation_Foundation_Readiness_Check_And_Cross_Runtime_Handoff.md

## Purpose

This document defines the readiness check, cross-runtime handoff, open gap register, implementation deferral boundary, pilot restriction, commercial boundary, legal/compliance handoff, and final index for the High Risk Store Operation Foundation lane of the Yoonsul Wait/Order Handoff documentation project.

The previous documents defined alcohol sales, adult verification, CI/DI privacy, table partial settlement, drunk customer mistouch, night delivery concurrency, alcohol KDS hold, alcohol payment disputes, minor access prevention, and night safety escalation.

This document closes the 08000 High Risk Store Operation Foundation lane and prepares its constraints for later POS, KDS, Payment, Provider, Admin Console, Pilot, Legal, Compliance, Training, and Commercial planning.

This document does not authorize implementation.

It defines readiness and handoff policy only.

---

## 2. Scope

This document covers:

- high-risk foundation lane closure
- readiness check
- cross-runtime impact
- required downstream handoff
- unresolved gap tracking
- pilot restriction
- legal/compliance handoff
- commercial packaging boundary
- training handoff
- Admin Console handoff
- no-implementation boundary

This document does not cover:

- final legal interpretation
- final alcohol license procedure
- final identity provider integration
- final POS/KDS/payment implementation
- final delivery platform implementation
- final Admin Console implementation
- final staff training script
- final customer communication script
- final pilot execution

---

## 3. Core Principle

High-risk operation must be proven safe before it becomes product scope.

The project must follow this rule:

> Alcohol sale, adult verification, identity privacy, table partial settlement, drunk customer misoperation, delivery concurrency, KDS hold, refund dispute, minor access prevention, and night safety must pass foundation readiness before any downstream runtime, UI, provider integration, pilot, or SaaS package treats them as enabled functionality.

High-risk operation is disabled by default.

Readiness must precede activation.

---

## 4. Lane Closure Meaning

Lane closure means the foundation has defined enough policy boundaries to prevent downstream teams from treating high-risk features as ordinary ordering features.

Lane closure does not mean:

- implementation approved
- legal review completed
- alcohol sale enabled
- identity integration approved
- delivery alcohol allowed
- pilot approved
- Admin Console build approved
- staff training completed
- franchise package approved

Lane closure means the constraints are ready for handoff.

---

## 5. Documents In This Lane

This lane includes:

| Document | Focus |
| -------- | ----- |
| `08002_Index_High_Risk_Store_Operation_Foundation_README_And_Edge_Case_Constitution` | lane start, principles, index |
| `08010_Policy_Alcohol_Sales_Adult_Verification_And_Legal_Sale_Boundary` | adult verification and legal sale boundary |
| `08020_Policy_Alcohol_Order_Identity_Privacy_CI_DI_And_Verification_Evidence` | identity privacy, CI/DI, evidence masking |
| `08030_Policy_Table_Session_Alcohol_Add_On_Partial_Settlement_And_Mid_Meal_Payment` | table add-on, partial settlement, split payment |
| `08040_Policy_Drunk_Customer_Mistouch_Misoperation_Confirmation_And_Staff_Intervention` | mistouch, repeated tap, staff intervention |
| `08050_Policy_Night_Operation_Delivery_Platform_Concurrent_Order_Synchronization` | Baemin/Coupang Eats concurrency, KDS/sold-out/cancel sync |
| `08060_Policy_Alcohol_KDS_Hold_Staff_Approval_Cancel_And_Service_Refusal_Boundary` | KDS hold, release, staff approval, refusal |
| `08070_Policy_Alcohol_Payment_Refund_Dispute_Chargeback_And_Recovery_Evidence` | payment, refund, chargeback, recovery |
| `08080_Policy_Minor_Access_Prevention_Verification_Failure_And_Incident_Response` | minor prevention, bypass, verification failure |
| `08090_Policy_Night_Safety_Staff_Escalation_Abuse_Prevention_And_Store_Closure_Boundary` | staff safety, abuse, escalation, closure |
| `08101 High Risk Store Operation Foundation Readiness Check And Cross Runtime Handoff` | readiness, handoff, final gate |

---

## 6. High-Risk Operation Coverage Check

The foundation lane must cover:

- alcohol as high-risk mode
- adult verification
- legal sale boundary
- identity privacy
- CI/DI masking
- verification evidence
- table participant ambiguity
- alcohol add-on
- partial settlement
- split payment
- drunk customer mistouch
- repeated tap
- staff intervention
- night delivery concurrency
- KDS hold and release
- payment/refund/chargeback dispute
- minor access prevention
- service refusal
- staff safety escalation
- store closure boundary

If any of these are missing, high-risk foundation is incomplete.

---

## 7. Cross-Runtime Impact

This lane impacts:

- Customer Session Runtime
- Table Session Runtime
- Order Runtime
- Payment Runtime
- Refund/Cancel Runtime
- KDS Runtime
- POS Runtime
- Provider Adapter Runtime
- Delivery Platform Runtime
- Identity Verification Runtime
- Support Runtime
- Incident Runtime
- Evidence Runtime
- Security Runtime
- Admin Console Runtime
- Pilot Runtime
- Commercial Runtime
- Legal/Compliance Runtime
- Training Runtime

No downstream runtime may ignore this foundation.

---

## 8. Customer Session Handoff

Customer session planning must receive:

- alcohol eligibility state
- verification-required state
- verification failure handling
- verification uncertainty handling
- customer confirmation requirement
- mistouch protection
- repeated tap protection
- self-order lock
- customer communication boundary
- non-alcohol continuation rule
- service refusal communication

Customer session must not expose raw identity data.

---

## 9. Table Session Handoff

Table session planning must receive:

- table is not one customer
- table is not one payment
- table-level verification is not universal verification
- late joining participant risk
- table transfer lineage
- alcohol add-on status
- partial settlement status
- split payment evidence
- staff confirmation requirement
- disputed add-on handling
- table closure blocker

Table session must preserve open risk until resolved.

---

## 10. Order Runtime Handoff

Order runtime planning must receive:

- alcohol item classification
- alcohol add-on trigger
- order block rule
- order split rule
- non-alcohol continuation rule
- customer intent ambiguity
- mistouch event categories
- service refusal effect
- delivery platform order candidate rule
- canonical mapping requirement

Order runtime must not treat alcohol item as ordinary menu item.

---

## 11. Payment Runtime Handoff

Payment runtime planning must receive:

- payment before verification risk
- payment after verification rule
- payment uncertainty status
- duplicate payment risk
- partial settlement boundary
- split payment risk
- refund before preparation
- refund after preparation
- refund after service
- service refusal after payment
- chargeback risk
- payment evidence packet

Payment success must not override legal or KDS uncertainty.

---

## 12. Refund Cancel Runtime Handoff

Refund/cancel planning must receive:

- cancel and refund separation
- KDS state dependency
- service state dependency
- verification state dependency
- staff approval dependency
- prepared-but-not-served case
- served alcohol case
- service refusal after payment case
- dispute status
- customer recovery status
- evidence timeline

Refund/cancel must be evidence-led.

---

## 13. KDS Runtime Handoff

KDS planning must receive:

- alcohol KDS classification
- KDS hold trigger
- KDS release condition
- staff approval dependency
- manager approval dependency
- payment dependency
- verification dependency
- service refusal review block
- provider mapping dependency
- cancel before preparation rule
- cancel after preparation review
- kitchen display masking rule

KDS must not receive identity payload.

---

## 14. POS Runtime Handoff

POS planning must receive:

- alcohol item classification
- table session linkage
- partial settlement linkage
- split payment linkage
- payment reconciliation requirement
- service refusal effect
- refund/cancel evidence
- manual staff add-on evidence
- provider-originated order mapping
- POS/payment mismatch handling

POS remains transaction authority but must obey high-risk constraints.

---

## 15. Provider Adapter Handoff

Provider adapter planning must receive:

- provider event validation
- idempotency
- duplicate detection
- stale event review
- canonical order mapping
- delivery provider status
- verification provider failure status
- payment provider uncertainty
- delivery platform cancellation mapping
- sold-out synchronization risk
- provider incident creation
- raw payload masking

Provider signal is not canonical truth until validated.

---

## 16. Delivery Platform Handoff

Delivery platform planning must receive:

- Baemin/Coupang Eats concurrency rule
- order channel classification
- provider-originated order candidate rule
- rider pickup boundary
- delivery pause rule
- sold-out conflict status
- cancellation conflict status
- delivery alcohol placeholder
- delivery recipient verification placeholder
- customer communication boundary
- provider incident escalation

Delivery alcohol remains disabled until separate legal/provider readiness.

---

## 17. Identity Verification Handoff

Identity planning must receive:

- adult verification trigger
- verification subject ambiguity
- verification status values
- verification failure status
- verification uncertainty rule
- CI/DI masking
- ID image prohibition by default
- raw provider payload restriction
- manual verification fallback restriction
- unmask request boundary
- verification evidence packet

Identity verification must minimize data.

---

## 18. Security Handoff

Security planning must receive:

- raw CI/DI prohibited in operational UI
- raw ID image prohibited by default
- provider payload masking
- log masking
- audit masking
- export restriction
- support unmask control
- leakage response boundary
- field-level masking requirement
- access review requirement

High-risk identity data must be security-reviewed before build.

---

## 19. Support Runtime Handoff

Support planning must receive:

- case-scoped access
- masked verification view
- payment dispute support
- refund/cancel support
- service refusal support
- KDS/payment mismatch support
- minor access incident support
- night safety support
- customer recovery support
- support cannot approve alcohol sale after failure

Support is recovery aid, not runtime truth owner.

---

## 20. Incident Runtime Handoff

Incident planning must receive:

- minor access incident
- alcohol payment incident
- night safety incident
- provider incident
- KDS release incident
- identity leakage incident
- staff escalation incident
- service refusal escalation
- delivery cancellation conflict
- sold-out accepted order conflict

Incidents must be evidence-linked and append-only.

---

## 21. Evidence Runtime Handoff

Evidence planning must receive:

- adult verification evidence
- table alcohol evidence
- mistouch evidence
- night delivery concurrency evidence
- alcohol KDS evidence
- alcohol payment evidence
- minor access incident evidence
- night safety evidence
- manager intervention evidence
- provider event evidence

Evidence must avoid raw identity and payment secrets.

---

## 22. Admin Console Handoff

Admin Console planning must receive:

- high-risk status dashboard
- verification required count
- KDS hold count
- payment dispute count
- underage risk count
- night safety status
- delivery pause status
- service refusal review
- evidence completeness
- no direct unsafe approval
- no raw identity display
- no accusatory customer labels

Admin Console is visibility and workflow surface, not unsafe runtime override.

---

## 23. Pilot Runtime Handoff

Pilot planning must receive:

- alcohol mode disabled by default
- delivery alcohol disabled by default
- adult verification readiness required
- KDS hold/release tested
- payment/refund path tested
- service refusal SOP required
- minor access prevention tested
- night safety escalation tested
- staff training completed
- evidence packet verified
- legal/compliance review scheduled or completed

High-risk pilot cannot be ordinary feature pilot.

---

## 24. Commercial Handoff

Commercial planning must receive:

- alcohol mode is premium/high-risk capability
- adult verification provider cost
- staff training cost
- night operation support tier
- delivery platform concurrency complexity
- payment/refund dispute support cost
- incident handling cost
- compliance setup cost
- store safety readiness cost
- high-risk package eligibility

High-risk operation must not be bundled casually into basic SaaS.

---

## 25. Legal Compliance Handoff

Legal/compliance planning must receive:

- alcohol license scope
- adult verification method
- manual verification fallback
- CI/DI handling
- privacy notice and consent
- data retention
- service refusal wording
- minor access prevention
- refund after service
- delivery alcohol restriction
- staff training record
- store safety escalation
- consumer dispute handling

This lane does not provide final legal conclusion.

It defines the legal review input.

---

## 26. Training Handoff

Training planning must receive:

- adult verification failure handling
- calm refusal wording
- avoiding accusation
- handling drunk customer mistouch
- handling repeated tap
- staff confirmation process
- manager escalation
- KDS hold/release meaning
- payment/refund dispute escalation
- delivery rider conflict handling
- store closure review
- evidence recording

High-risk mode requires training before activation.

---

## 27. Store Operations Handoff

Store operations planning must receive:

- alcohol mode enable/disable procedure
- alcohol stop procedure
- delivery stop procedure
- seating stop procedure
- emergency hold procedure
- self-order lock procedure
- staff escalation path
- manager intervention path
- service refusal path
- reopen review path

Store operations must have human-operable procedures.

---

## 28. Required Registers

The following registers are recommended before implementation planning:

    docs/_index/
      High_Risk_Operation_Register.md
      Alcohol_Mode_Status_Register.md
      Alcohol_Item_Classification_Register.md
      Adult_Verification_Status_Register.md
      CI_DI_Privacy_Register.md
      Table_Session_Status_Register.md
      Alcohol_Add_On_Status_Register.md
      Partial_Settlement_Register.md
      Mistouch_Risk_Status_Register.md
      Delivery_Provider_Status_Register.md
      Alcohol_KDS_Status_Register.md
      Alcohol_Payment_Status_Register.md
      Minor_Access_Incident_Register.md
      Night_Safety_Status_Register.md
      Store_Closure_Status_Register.md
      High_Risk_Evidence_Register.md

This document recommends registers only.

It does not create them.

---

## 29. Readiness Categories

Readiness should be reviewed by category:

- `FOUNDATION_READY`
- `LEGAL_REVIEW_REQUIRED`
- `PRIVACY_REVIEW_REQUIRED`
- `SECURITY_REVIEW_REQUIRED`
- `PAYMENT_REVIEW_REQUIRED`
- `KDS_REVIEW_REQUIRED`
- `PROVIDER_REVIEW_REQUIRED`
- `TRAINING_REQUIRED`
- `PILOT_RESTRICTED`
- `IMPLEMENTATION_BLOCKED`
- `COMMERCIAL_REVIEW_REQUIRED`

Multiple categories may apply at once.

---

## 30. Foundation Readiness Checklist

Foundation readiness requires:

1. alcohol sale boundary defined
2. adult verification trigger defined
3. identity privacy boundary defined
4. CI/DI masking rule defined
5. verification evidence defined
6. table session risk defined
7. alcohol add-on rule defined
8. partial settlement rule defined
9. mistouch/misoperation rule defined
10. night delivery concurrency rule defined
11. KDS hold/release rule defined
12. payment/refund/dispute rule defined
13. minor access prevention rule defined
14. night safety escalation rule defined
15. store closure boundary defined

If any item is missing, foundation is not ready.

---

## 31. Legal Readiness Checklist

Legal readiness requires later confirmation of:

1. alcohol license scope
2. sale channel eligibility
3. adult verification method
4. manual verification fallback
5. service refusal wording
6. minor access prevention
7. refund after alcohol service
8. delivery alcohol restriction
9. identity data retention
10. staff training documentation
11. incident retention
12. local jurisdiction rules

This checklist requires legal professional review.

---

## 32. Privacy Security Readiness Checklist

Privacy/security readiness requires:

1. raw CI/DI hidden from operational UI
2. raw ID image prohibited by default
3. provider payload not logged
4. KDS receives no identity data
5. support view masked
6. Admin Console masked
7. export blocked by default
8. unmask request governed
9. leakage response defined
10. retention placeholder defined
11. audit masked
12. error messages safe

Without this, identity verification build is blocked.

---

## 33. Payment Readiness Checklist

Payment readiness requires:

1. payment before verification rule
2. verification before payment rule
3. payment uncertainty state
4. duplicate payment review
5. refund before preparation
6. refund after preparation review
7. refund after service review
8. service refusal after payment
9. partial settlement linkage
10. split payment evidence
11. chargeback risk preservation
12. POS reconciliation boundary

Without this, alcohol payment flow is blocked.

---

## 34. KDS Readiness Checklist

KDS readiness requires:

1. alcohol KDS ticket classification
2. KDS hold triggers
3. KDS release conditions
4. staff approval record
5. manager approval rule
6. verification dependency
7. payment dependency
8. service refusal block
9. cancellation before preparation rule
10. cancellation after preparation review
11. kitchen display masking
12. KDS evidence packet

Without this, alcohol KDS release is blocked.

---

## 35. Provider Readiness Checklist

Provider readiness requires:

1. provider event validation
2. idempotency
3. duplicate detection
4. stale event review
5. canonical mapping
6. provider status display
7. delivery platform cancellation mapping
8. sold-out synchronization
9. delivery pause mechanism
10. provider incident creation
11. raw payload masking
12. delivery alcohol disabled unless separately approved

Without this, provider-linked high-risk operation is blocked.

---

## 36. Staff Training Readiness Checklist

Training readiness requires:

1. adult verification failure script
2. mistouch confirmation handling
3. staff approval process
4. manager escalation process
5. service refusal handling
6. payment dispute escalation
7. KDS hold explanation
8. delivery rider conflict handling
9. night safety escalation
10. store closure review process
11. evidence recording
12. non-accusatory language

Without training, high-risk mode is blocked.

---

## 37. Pilot Readiness Checklist

Pilot readiness requires:

1. high-risk scope explicitly selected
2. alcohol mode default disabled
3. delivery alcohol disabled
4. legal review scheduled or completed as required
5. identity privacy reviewed
6. payment/KDS/provider paths tested
7. staff trained
8. evidence packet tested
9. support escalation ready
10. stop/pause/rollback path ready
11. customer communication approved
12. incident review cadence defined

Without this, pilot cannot include high-risk operation.

---

## 38. Commercial Readiness Checklist

Commercial readiness requires:

1. alcohol mode package boundary
2. adult verification provider cost model
3. high-risk support tier
4. night operation support tier
5. staff training fee
6. incident support boundary
7. delivery concurrency pricing
8. payment dispute support boundary
9. compliance setup boundary
10. store safety readiness review
11. contract scope amendment
12. exclusion from basic package unless approved

Commercial promise must not exceed operational readiness.

---

## 39. Open Gap Register Fields

Each open gap should include:

- gap id
- document reference
- gap category
- description
- affected runtime
- risk severity
- owner
- required decision
- required evidence
- status
- target handoff
- notes

Open gaps must not be hidden.

---

## 40. Open Gap ID Format

Recommended format:

    HIGH-RISK-GAP-[YYYYMMDD]-[NUMBER]

Example:

    HIGH-RISK-GAP-20260612-001

Final format may be normalized later.

---

## 41. Blocker Categories

Recommended blocker categories:

- `LEGAL_BLOCKER`
- `PRIVACY_BLOCKER`
- `SECURITY_BLOCKER`
- `PAYMENT_BLOCKER`
- `KDS_BLOCKER`
- `PROVIDER_BLOCKER`
- `TRAINING_BLOCKER`
- `PILOT_BLOCKER`
- `COMMERCIAL_BLOCKER`
- `STORE_SAFETY_BLOCKER`
- `EVIDENCE_BLOCKER`

Blockers must prevent activation.

---

## 42. Handoff Packet Fields

Each handoff packet should include:

- handoff id
- source document
- target runtime
- affected features
- required constraints
- prohibited actions
- required states
- evidence requirement
- unresolved gaps
- required approvals
- implementation deferral note
- owner
- status
- notes

Handoff packet prevents constraints from being lost.

---

## 43. Handoff ID Format

Recommended format:

    HIGH-RISK-HANDOFF-[TARGET-RUNTIME]-[NUMBER]

Examples:

    HIGH-RISK-HANDOFF-PAYMENT-001
    HIGH-RISK-HANDOFF-KDS-001
    HIGH-RISK-HANDOFF-PROVIDER-001
    HIGH-RISK-HANDOFF-ADMIN-001

Final format may be normalized later.

---

## 44. Implementation Deferral Boundary

This lane does not authorize:

- alcohol menu activation
- adult verification integration
- CI/DI collection
- ID image storage
- alcohol payment flow
- alcohol KDS hold implementation
- delivery platform alcohol handling
- Baemin/Coupang Eats integration
- automated service refusal
- automated store closure
- Admin Console high-risk control
- pilot activation
- legal conclusion

Implementation requires separate readiness, legal, security, runtime, provider, and build authorization.

---

## 45. Activation Gate

High-risk operation may be activated only when:

- foundation readiness passed
- legal readiness passed or approved for limited scope
- privacy/security readiness passed
- payment readiness passed
- KDS readiness passed
- provider readiness passed if provider involved
- staff training completed
- pilot readiness passed
- commercial scope approved
- evidence packet tested
- rollback/pause path ready

Until then:

    HIGH_RISK_OPERATION_DISABLED

must remain the default state.

---

## 46. Deactivation Gate

High-risk operation must be deactivated or suspended when:

- legal uncertainty appears
- identity provider fails repeatedly
- CI/DI leakage suspected
- KDS hold fails
- payment dispute rate unsafe
- minor access incident occurs
- staff safety incident occurs
- delivery platform state unreliable
- evidence capture fails
- staff training incomplete
- support capacity unavailable
- store closure review active

Deactivation protects store, customer, staff, and brand.

---

## 47. Admin Dashboard Summary Boundary

Future Admin Dashboard may summarize:

- high-risk mode status
- alcohol mode eligibility
- verification failure count
- KDS hold count
- payment dispute count
- minor access incident count
- night safety status
- delivery pause status
- evidence completeness
- readiness blockers

Dashboard must not expose:

- raw CI/DI
- ID document data
- provider raw payload
- payment secrets
- accusatory customer labels
- direct unsafe override

---

## 48. Anti-Patterns

The following are prohibited:

- activating alcohol mode as normal menu option
- treating verification uncertainty as pass
- using payment success as legal authority
- sending alcohol to KDS before verification
- exposing CI/DI in staff/KDS/Admin UI
- enabling delivery alcohol without separate review
- ignoring table participant ambiguity
- treating mistouch as customer fault without review
- forcing staff to serve during safety risk
- bundling high-risk operation into basic SaaS without readiness
- running pilot without staff training
- closing high-risk incidents without evidence
- allowing provider signal to bypass canonical mapping
- letting Admin Console override runtime safety
- treating foundation lane closure as implementation approval

---

## 49. Non-Goals

This document does not define:

- final legal interpretation
- final alcohol license procedure
- final identity provider implementation
- final CI/DI schema
- final POS/KDS/payment implementation
- final delivery platform integration
- final Admin Console screen
- final staff script
- final pilot execution
- final SaaS pricing package
- final contract language

Those belong to later legal, security, runtime, implementation, training, commercial, and pilot planning.

---

## 50. Final Readiness Check

This lane is ready for handoff when the project can answer:

1. Which documents belong to the 08000 High Risk Store Operation Foundation lane?
2. What high-risk operation coverage is complete?
3. Which runtimes are affected?
4. What must Customer Session receive?
5. What must Table Session receive?
6. What must Order Runtime receive?
7. What must Payment Runtime receive?
8. What must Refund/Cancel Runtime receive?
9. What must KDS Runtime receive?
10. What must POS Runtime receive?
11. What must Provider Adapter receive?
12. What must Delivery Platform planning receive?
13. What must Identity Verification planning receive?
14. What must Security receive?
15. What must Support receive?
16. What must Incident Runtime receive?
17. What must Evidence Runtime receive?
18. What must Admin Console receive?
19. What must Pilot planning receive?
20. What must Commercial planning receive?
21. What must Legal/Compliance receive?
22. What must Training receive?
23. What must Store Operations receive?
24. What registers are recommended?
25. What readiness categories exist?
26. What foundation readiness checklist applies?
27. What legal readiness checklist applies?
28. What privacy/security readiness checklist applies?
29. What payment readiness checklist applies?
30. What KDS readiness checklist applies?
31. What provider readiness checklist applies?
32. What staff training readiness checklist applies?
33. What pilot readiness checklist applies?
34. What commercial readiness checklist applies?
35. What open gap fields are needed?
36. What blocker categories exist?
37. What handoff packet fields are needed?
38. What implementation deferral boundary applies?
39. What activation gate applies?
40. What deactivation gate applies?
41. What dashboard summary boundary applies?
42. What anti-patterns are prohibited?

If these questions cannot be answered, High Risk Store Operation Foundation handoff is incomplete.

---

## 51. Conclusion

The 08000 High Risk Store Operation Foundation lane defines that alcohol sale and night operation are not ordinary ordering features.

They are high-risk operating modes involving:

- law
- identity
- privacy
- payment
- KDS
- POS
- provider synchronization
- table/session ambiguity
- customer intent uncertainty
- minor access prevention
- staff safety
- incident evidence
- pilot restriction
- commercial packaging
- legal/compliance review

The safe handoff flow is:

    high-risk foundation
        -> readiness checks
        -> cross-runtime handoff
        -> legal/privacy/security review
        -> payment/KDS/provider planning
        -> staff training
        -> limited pilot readiness
        -> commercial scope approval
        -> activation only after evidence-backed gate

This document closes the 08000 High Risk Store Operation Foundation lane and ensures that downstream runtime, UI, provider, payment, KDS, pilot, and commercial work cannot accidentally treat alcohol and night edge cases as normal features.
