# 08090_Policy_Night_Safety_Staff_Escalation_Abuse_Prevention_And_Store_Closure_Boundary

## 1. Purpose

This document defines the night safety, staff escalation, customer abuse prevention, drunk customer conflict handling, rider conflict handling, service refusal escalation, manager intervention, emergency hold, store closure boundary, evidence, support escalation, and implementation deferral policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined minor access prevention, verification failure, suspected underage access, bypass attempt, service refusal, payment/KDS recovery, and incident response policy.

This document focuses on staff safety and operational containment during night operation, especially when alcohol service, delivery platform pressure, customer dispute, payment conflict, or service refusal creates safety risk.

This document does not implement safety alarms, police reporting, emergency contact workflow, store closure automation, staff monitoring, or incident response system.

It defines night safety escalation and store closure boundary policy only.

---

## 2. Scope

This document covers:

- night safety risk
- staff safety priority
- abusive customer handling
- drunk customer conflict
- delivery rider conflict
- service refusal escalation
- manager escalation
- support escalation
- emergency operation hold
- delivery platform pause
- store closure boundary
- evidence requirement
- no-implementation boundary

This document does not cover:

- final legal emergency response
- final police/security procedure
- final staff safety manual
- final labor law interpretation
- final store insurance procedure
- final camera/security hardware
- final emergency contact integration
- final violence response training
- final delivery platform contract
- final automated closure implementation

---

## 3. Core Principle

Staff safety overrides sales, speed, delivery pressure, and customer convenience.

The project must follow this rule:

> When night operation, alcohol service, intoxication, abuse, service refusal, payment dispute, delivery rider pressure, or staff fear creates safety risk, the system must support escalation, order hold, service refusal, delivery pause, customer recovery, incident evidence, and store closure consideration rather than forcing continued operation.

Revenue is not higher authority than safety.

No order is worth unsafe staff exposure.

---

## 4. Night Safety Meaning

Night safety means protecting staff, customers, store property, and operational integrity during higher-risk operating windows.

Night safety risk may involve:

- intoxicated customer
- abusive language
- harassment
- threat
- group conflict
- payment dispute
- alcohol service refusal
- minor access refusal
- delivery rider pressure
- KDS delay conflict
- closing-time conflict
- staff working alone or understaffed
- repeated customer misoperation
- customer refusing to leave
- unsafe store environment

Night safety must be treated as a runtime condition, not a side note.

---

## 5. Staff Safety Boundary

Staff safety boundary means the point where ordinary customer service stops and protective escalation begins.

Protective escalation may include:

- staff confirmation
- manager call
- order hold
- alcohol service refusal
- refund/recovery review
- delivery platform pause
- customer communication script
- incident creation
- support escalation
- store closure review
- emergency contact under later SOP

Staff must not be expected to solve unsafe conflict alone.

---

## 6. Night Safety Status Values

Recommended night safety status values:

- `NIGHT_SAFETY_NORMAL`
- `NIGHT_SAFETY_WATCH`
- `NIGHT_SAFETY_STAFF_CONCERN`
- `NIGHT_SAFETY_MANAGER_REVIEW_REQUIRED`
- `NIGHT_SAFETY_SERVICE_HOLD`
- `NIGHT_SAFETY_SERVICE_REFUSAL_REVIEW`
- `NIGHT_SAFETY_DELIVERY_PAUSE_REVIEW`
- `NIGHT_SAFETY_CUSTOMER_RECOVERY_REQUIRED`
- `NIGHT_SAFETY_INCIDENT_OPEN`
- `NIGHT_SAFETY_STORE_CLOSURE_REVIEW`
- `NIGHT_SAFETY_EMERGENCY_ESCALATED`
- `NIGHT_SAFETY_CLOSED`

Final values may be normalized later.

---

## 7. Abuse Risk Meaning

Abuse risk means customer, rider, or third-party behavior that may harm staff dignity, safety, or operational control.

Abuse risk may include:

- shouting
- insults
- threats
- harassment
- sexual harassment
- intimidation
- repeated hostile complaint
- refusal to follow safety instruction
- pressure to bypass verification
- pressure to serve alcohol
- pressure to refund immediately
- pressure to release delivery order unsafely
- group confrontation
- property damage risk

Abuse risk should be handled as safety signal.

---

## 8. Abuse Risk Status Values

Recommended abuse risk status values:

- `ABUSE_RISK_NONE`
- `ABUSE_RISK_WATCH`
- `ABUSE_RISK_STAFF_REPORTED`
- `ABUSE_RISK_DE_ESCALATION_REQUIRED`
- `ABUSE_RISK_MANAGER_REQUIRED`
- `ABUSE_RISK_SERVICE_REFUSAL_REQUIRED`
- `ABUSE_RISK_CUSTOMER_REMOVAL_REVIEW`
- `ABUSE_RISK_EMERGENCY_ESCALATION_REQUIRED`
- `ABUSE_RISK_INCIDENT_OPEN`
- `ABUSE_RISK_CLOSED`

Abuse risk status must not be hidden in casual notes.

---

## 9. Drunk Customer Conflict Rule

Drunk customer conflict may occur when:

- customer disputes order intent
- customer disputes payment
- customer refuses adult verification
- customer repeatedly touches order screen
- customer demands alcohol after refusal
- customer becomes loud or abusive
- customer refuses to leave
- table group argues
- staff feels unsafe
- other customers are affected

System must support staff with hold, refusal, escalation, and evidence.

---

## 10. Delivery Rider Conflict Rule

Delivery rider conflict may occur when:

- rider arrives before KDS completion
- order is held due to sold-out conflict
- order is held due to payment/cancel conflict
- platform cancellation is pending
- staff pauses delivery intake
- rider pressures staff
- rider argues over pickup timing
- wrong order handoff risk exists
- platform state differs from store state

Rider pressure must not override KDS, payment, cancellation, or safety state.

---

## 11. Service Refusal Escalation Rule

Service refusal escalation may be required when:

- alcohol verification fails
- underage risk exists
- intoxication risk exists
- customer becomes abusive
- staff safety concern exists
- customer refuses to comply
- payment already occurred
- KDS already prepared item
- group conflict escalates
- legal/compliance risk exists

Service refusal should be respectful, recorded, and supported by manager path.

---

## 12. Staff Escalation Meaning

Staff escalation means moving a safety or conflict situation from ordinary staff handling to higher authority or support.

Escalation targets may include:

- shift leader
- store manager
- owner/operator
- HQ support
- security/legal review
- emergency contact under later SOP
- platform support if delivery-related
- payment/provider support if payment-related

Escalation must not depend on staff memory alone.

---

## 13. Staff Escalation Status Values

Recommended values:

- `ESCALATION_NOT_REQUIRED`
- `ESCALATION_RECOMMENDED`
- `ESCALATION_REQUIRED`
- `ESCALATION_PENDING`
- `ESCALATION_IN_PROGRESS`
- `ESCALATION_MANAGER_CONTACTED`
- `ESCALATION_SUPPORT_CONTACTED`
- `ESCALATION_EMERGENCY_CONTACT_REQUIRED`
- `ESCALATION_COMPLETED`
- `ESCALATION_FAILED`
- `ESCALATION_CLOSED`

Escalation status must be visible to responsible staff.

---

## 14. Manager Intervention Rule

Manager intervention should be required when:

- staff reports fear or pressure
- service refusal may escalate
- customer dispute involves alcohol
- payment/refund conflict is heated
- KDS already prepared disputed alcohol item
- delivery rider conflict disrupts operation
- minor access incident occurs
- customer refuses to leave
- store closure may be needed
- emergency escalation may be needed

Manager intervention must produce evidence.

---

## 15. Manager Intervention Record Fields

Each manager intervention record should include:

- intervention id
- store id
- table/session reference if any
- order reference if any
- risk category
- staff actor
- manager actor
- trigger
- decision
- customer communication
- delivery platform status if relevant
- payment status if relevant
- KDS status if relevant
- service refusal status if relevant
- safety status
- timestamp
- evidence packet reference
- notes

Record should avoid accusatory labels.

---

## 16. Manager Intervention ID Format

Recommended format:

    NIGHT-MANAGER-INTERVENTION-[YYYYMMDD]-[NUMBER]

Example:

    NIGHT-MANAGER-INTERVENTION-20260612-001

Final format may be normalized later.

---

## 17. Emergency Operation Hold Rule

Emergency operation hold means temporarily holding risky flows while staff resolves safety or conflict issue.

Emergency hold may apply to:

- alcohol orders
- new delivery orders
- KDS release
- table add-ons
- partial settlement
- refund approval
- service refusal decision
- manual staff order
- customer self-order screen
- pickup handoff

Emergency hold should be visible and time-scoped where possible.

---

## 18. Emergency Hold Status Values

Recommended values:

- `EMERGENCY_HOLD_NOT_ACTIVE`
- `EMERGENCY_HOLD_REVIEW_REQUIRED`
- `EMERGENCY_HOLD_ACTIVE`
- `EMERGENCY_HOLD_ALCOHOL_ONLY`
- `EMERGENCY_HOLD_DELIVERY_ONLY`
- `EMERGENCY_HOLD_KDS_RELEASE`
- `EMERGENCY_HOLD_PAYMENT_REVIEW`
- `EMERGENCY_HOLD_STORE_WIDE`
- `EMERGENCY_HOLD_RELEASE_REVIEW`
- `EMERGENCY_HOLD_RELEASED`
- `EMERGENCY_HOLD_ESCALATED`

Emergency hold must not be silent.

---

## 19. Delivery Platform Pause Safety Rule

Delivery platform pause may be required for safety when:

- staff is handling abusive customer
- KDS overload creates conflict
- rider pressure becomes unsafe
- store is understaffed
- alcohol refusal incident active
- payment/refund dispute escalated
- sold-out conflicts repeat
- store closure review active
- manager cannot safely handle new orders

Delivery pause is safety containment, not operational failure.

---

## 20. Customer Self-Order Lock Rule

Customer self-order screen may need lock or limitation when:

- drunk misoperation repeats
- customer abuses device/order flow
- table dispute active
- service refusal active
- staff intervention pending
- payment dispute active
- minor access risk active
- store safety incident active

Lock should be controlled, visible, and recoverable.

---

## 21. Self-Order Lock Status Values

Recommended values:

- `SELF_ORDER_LOCK_NOT_REQUIRED`
- `SELF_ORDER_LOCK_REVIEW_REQUIRED`
- `SELF_ORDER_LOCK_ACTIVE`
- `SELF_ORDER_LOCK_ALCOHOL_ONLY`
- `SELF_ORDER_LOCK_TABLE_ONLY`
- `SELF_ORDER_LOCK_PAYMENT_ONLY`
- `SELF_ORDER_LOCK_STAFF_ONLY_MODE`
- `SELF_ORDER_LOCK_RELEASE_REVIEW`
- `SELF_ORDER_LOCK_RELEASED`

Lock status should be visible to staff.

---

## 22. Store Closure Boundary Meaning

Store closure boundary means the point where continuing operation is no longer safe, reliable, or legally/operationally acceptable.

Closure review may involve:

- temporary pause
- early closing
- delivery-only shutdown
- alcohol-only shutdown
- table seating stop
- full store closure
- emergency closure
- next-day incident review

Closure is last resort, but must be available.

---

## 23. Store Closure Review Triggers

Store closure review may be triggered when:

- staff safety cannot be maintained
- abusive customer refuses to leave
- repeated conflict occurs
- staff is alone and high-risk incident active
- alcohol service refusal escalates
- minor access incident escalates
- payment dispute becomes unsafe
- delivery rider conflict becomes unsafe
- KDS/provider failure creates uncontrolled customer conflict
- power/network failure affects safe operation
- emergency event occurs

Closure review must prioritize safety over revenue.

---

## 24. Store Closure Status Values

Recommended values:

- `STORE_CLOSURE_NOT_REQUIRED`
- `STORE_CLOSURE_REVIEW_REQUIRED`
- `STORE_CLOSURE_PARTIAL_PAUSE`
- `STORE_CLOSURE_ALCOHOL_STOP`
- `STORE_CLOSURE_DELIVERY_STOP`
- `STORE_CLOSURE_SEATING_STOP`
- `STORE_CLOSURE_TEMPORARY_HOLD`
- `STORE_CLOSURE_EARLY_CLOSE`
- `STORE_CLOSURE_EMERGENCY_CLOSE`
- `STORE_CLOSURE_REOPEN_REVIEW`
- `STORE_CLOSURE_CLOSED`

Closure status must be evidence-linked.

---

## 25. Alcohol Stop Rule

Alcohol stop may be safer than full closure.

Alcohol stop may apply when:

- verification provider unavailable
- repeated alcohol conflict occurs
- staff cannot safely verify
- service refusal incidents repeat
- intoxicated customer group risk rises
- manager unavailable
- minor access risk active
- payment/refund disputes escalate

Alcohol stop should not necessarily stop non-alcohol food operation.

---

## 26. Delivery Stop Rule

Delivery stop may be safer than full closure.

Delivery stop may apply when:

- kitchen is overloaded
- rider conflict occurs
- platform state unreliable
- sold-out sync fails
- staff is occupied by safety incident
- cancellation conflicts repeat
- provider incident active
- packaging capacity unavailable
- store closure review active

Delivery stop must be recorded and communicated where needed.

---

## 27. Seating Stop Rule

Seating stop may be needed when:

- staff cannot manage additional tables
- conflict affects dining area
- alcohol service risk is high
- closing time risk exists
- KDS/payment recovery backlog exists
- safety incident active
- staffing insufficient
- manager review pending

Seating stop is a safety and capacity control.

---

## 28. Emergency Close Rule

Emergency close may be needed when:

- staff safety is immediately threatened
- customer refuses to leave and escalates
- violence or property damage risk exists
- emergency services may be required
- critical infrastructure failure makes operation unsafe
- store cannot safely process payment/orders
- manager or owner decides operation must stop

Emergency close must create incident evidence.

---

## 29. Reopen Review Rule

After safety-related closure or pause:

- incident must be reviewed
- staff status must be checked
- unresolved orders must be reconciled
- payment/refund issues must be reviewed
- delivery platform state must be checked
- KDS queue must be cleared or reconciled
- alcohol mode may remain disabled
- manager approval may be required
- support/legal review may be needed

Reopen must not be automatic after serious safety incident.

---

## 30. Staff Communication Rule

Staff communication should show:

- safety status
- active risk category
- next safe action
- escalation contact
- service refusal guidance
- delivery pause option
- self-order lock option
- closure review status
- evidence capture requirement
- customer wording

Staff must have a clear path under pressure.

---

## 31. Customer Communication Rule

Customer communication should be calm and non-confrontational.

Examples:

    현재 매장 안전과 원활한 운영을 위해 주문 확인이 필요합니다. 직원 안내에 따라 주시면 가능한 범위에서 도와드리겠습니다.

    현재 매장 상황으로 인해 주류 주문은 일시적으로 중단되었습니다. 음식 주문은 가능한 범위에서 안내드리겠습니다.

Avoid:

    취해서 주문을 막았습니다.
    직원에게 위협적이라 주문 안 됩니다.
    지금 매장 난리라 주문 못 받습니다.
    배달기사 때문에 주문이 밀립니다.

Customer communication should reduce escalation.

---

## 32. Delivery Rider Communication Rule

Delivery rider communication should be short and operational.

Recommended information:

- order is still preparing
- order is held due to store review
- cancellation is pending
- platform status is being checked
- staff will update when ready

Avoid exposing:

- customer identity
- alcohol verification detail
- internal dispute details
- staff safety incident details
- payment secrets
- provider raw data

Rider communication should prevent conflict.

---

## 33. Evidence Requirement

Night safety evidence should include:

- evidence id
- store id
- operation window
- risk category
- staff actor
- manager actor if any
- affected table/session if any
- affected order if any
- alcohol mode status
- delivery platform status if relevant
- KDS status if relevant
- payment status if relevant
- service refusal status if relevant
- emergency hold status
- closure status
- customer communication
- rider communication if relevant
- support escalation if any
- timestamps
- notes

Evidence should be factual and non-accusatory.

---

## 34. Night Safety Evidence ID Format

Recommended format:

    NIGHT-SAFETY-EVIDENCE-[YYYYMMDD]-[NUMBER]

Example:

    NIGHT-SAFETY-EVIDENCE-20260612-001

Final format may be normalized later.

---

## 35. Incident Creation Rule

Night safety incident should be created when:

- staff safety concern is reported
- abuse risk reaches manager level
- service refusal escalates
- customer refuses to leave
- rider conflict disrupts operation
- alcohol stop is activated
- delivery stop is activated for safety
- store closure review is activated
- emergency close occurs
- payment/KDS conflict becomes unsafe

Incident must be linked to evidence.

---

## 36. Night Safety Incident Status Values

Recommended values:

- `NIGHT_SAFETY_INCIDENT_NOT_OPEN`
- `NIGHT_SAFETY_INCIDENT_OPEN`
- `NIGHT_SAFETY_INCIDENT_EVIDENCE_REQUIRED`
- `NIGHT_SAFETY_INCIDENT_MANAGER_REVIEW`
- `NIGHT_SAFETY_INCIDENT_SUPPORT_ESCALATED`
- `NIGHT_SAFETY_INCIDENT_SERVICE_HOLD`
- `NIGHT_SAFETY_INCIDENT_PARTIAL_CLOSURE`
- `NIGHT_SAFETY_INCIDENT_EMERGENCY_CLOSE`
- `NIGHT_SAFETY_INCIDENT_LEGAL_REVIEW_REQUIRED`
- `NIGHT_SAFETY_INCIDENT_RESOLVED`
- `NIGHT_SAFETY_INCIDENT_CLOSED`

Incident status must remain visible until closure.

---

## 37. Support Boundary

Support may assist when:

- staff needs guidance
- service refusal escalates
- payment/refund conflict escalates
- delivery platform conflict occurs
- evidence is incomplete
- closure review is active
- customer recovery needed
- provider incident contributes to risk
- legal/compliance review may be required

Support must not pressure store to continue unsafe operation.

Support must not override staff safety concern.

---

## 38. Admin Console Boundary

Future Admin Console may show:

- night safety status
- abuse risk count
- staff escalation pending
- manager intervention count
- emergency hold status
- delivery pause status
- self-order lock status
- store closure review status
- incident count
- evidence completeness

Admin Console must not expose accusatory customer labels.

Admin Console must not force reopening after safety closure.

---

## 39. Provider Boundary

Provider systems may affect safety when:

- delivery orders continue during pause
- rider app shows wrong pickup time
- platform cancellation is delayed
- platform support pressures store
- payment status conflicts with store status
- provider outage causes customer conflict
- sold-out sync fails repeatedly

Provider risk must be recorded and may trigger incident.

---

## 40. Payment And Refund Boundary

Safety incidents may affect payment/refund when:

- service refusal occurs after payment
- customer dispute escalates
- staff cannot safely continue transaction
- store closes before order completion
- delivery order is cancelled due to safety
- KDS prepared item cannot be handed over safely
- customer recovery is needed

Payment/refund review must consider safety evidence.

---

## 41. KDS Boundary

KDS may need hold or stop when:

- staff safety incident active
- service refusal active
- store closure review active
- delivery pickup unsafe
- customer dispute affects table
- alcohol mode stopped
- kitchen cannot safely continue
- emergency hold active

KDS must not continue to generate executable work if front operation is unsafe.

---

## 42. Training Boundary

Staff training must later cover:

- recognizing safety escalation triggers
- using calm refusal language
- pausing alcohol orders
- pausing delivery orders
- locking self-order flow
- calling manager
- documenting evidence
- not using accusatory language
- protecting personal safety
- post-incident review

Safety policy is ineffective without training.

---

## 43. Commercial Boundary

Night safety handling may affect:

- night operation support tier
- high-risk operation package
- staff training fee
- incident support cost
- alcohol mode eligibility
- delivery integration support
- store safety readiness review
- franchise compliance training
- insurance/legal coordination

Night safety support should not be treated as ordinary SaaS support.

---

## 44. Legal/Compliance Handoff

Legal/compliance review may be needed for:

- service refusal
- abuse incident documentation
- staff safety obligations
- emergency closure
- refund/cancel after safety incident
- alcohol stop policy
- delivery stop policy
- customer removal
- police/security contact
- labor and safety obligations

This document does not provide legal conclusion.

---

## 45. Implementation Deferral Boundary

This document does not authorize:

- emergency alarm implementation
- automated police/security contact
- automatic customer blacklist
- automatic intoxication detection
- automated store closure
- automated delivery platform pause
- staff tracking implementation
- camera/sensor monitoring
- legal incident reporting automation
- Admin Console safety controls

Implementation requires separate legal, safety, privacy, and build approval.

---

## 46. Registers Recommendation

Recommended future files:

    docs/_index/
      Night_Safety_Status_Register.md
      Abuse_Risk_Status_Register.md
      Staff_Escalation_Register.md
      Manager_Intervention_Register.md
      Emergency_Hold_Register.md
      Self_Order_Lock_Register.md
      Store_Closure_Status_Register.md
      Night_Safety_Evidence_Register.md
      Night_Safety_Incident_Register.md

This document only recommends these files.

It does not create them.

---

## 47. Anti-Patterns

The following are prohibited:

- forcing staff to continue unsafe service
- treating abuse as ordinary complaint
- hiding staff safety concern in notes
- letting delivery rider pressure override safety
- forcing alcohol service after refusal risk
- continuing KDS execution during unsafe front operation
- reopening store automatically after emergency closure
- using accusatory customer labels in UI
- pausing delivery without evidence
- closing store without review trail
- allowing support to pressure unsafe operation
- treating safety incident as customer service metric only
- prioritizing revenue over staff safety

---

## 48. Non-Goals

This document does not define:

- final police/security procedure
- final legal emergency process
- final labor safety policy
- final insurance claim process
- final staff safety training script
- final emergency contact implementation
- final camera/security hardware
- final customer blacklist policy
- final automated closure system
- final delivery platform contract handling

Those belong to later legal, safety, HR, operations, and implementation planning.

---

## 49. Readiness Check

This document is ready when the project can answer:

1. What does night safety mean?
2. What is staff safety boundary?
3. What night safety statuses exist?
4. What does abuse risk mean?
5. What abuse risk statuses exist?
6. What drunk customer conflict rule applies?
7. What delivery rider conflict rule applies?
8. What service refusal escalation rule applies?
9. What does staff escalation mean?
10. What staff escalation statuses exist?
11. When is manager intervention required?
12. What fields should manager intervention record include?
13. What is emergency operation hold?
14. What emergency hold statuses exist?
15. When may delivery platform pause be required for safety?
16. When may customer self-order lock be needed?
17. What self-order lock statuses exist?
18. What is store closure boundary?
19. What triggers store closure review?
20. What store closure statuses exist?
21. When may alcohol stop apply?
22. When may delivery stop apply?
23. When may seating stop apply?
24. When may emergency close apply?
25. What reopen review rule applies?
26. What staff communication rule applies?
27. What customer communication rule applies?
28. What delivery rider communication rule applies?
29. What evidence is required?
30. When should night safety incident be created?
31. What night safety incident statuses exist?
32. What support boundary applies?
33. What Admin Console boundary applies?
34. What provider boundary applies?
35. What payment/refund boundary applies?
36. What KDS boundary applies?
37. What training boundary applies?
38. What commercial boundary applies?
39. What legal/compliance handoff is needed?
40. What implementation deferral boundary applies?
41. What anti-patterns are prohibited?

If these questions cannot be answered, night safety, staff escalation, abuse prevention, and store closure boundary planning is incomplete.

---

## 50. Conclusion

Night operation with alcohol, delivery platform pressure, payment disputes, and customer conflict creates safety risk beyond normal ordering.

The safe night safety flow is:

    safety risk detected
        -> staff concern acknowledged
        -> order, alcohol, delivery, KDS, or self-order hold if needed
        -> manager or support escalation
        -> service refusal, customer recovery, or delivery pause
        -> store closure review if safety cannot be maintained
        -> evidence capture
        -> legal/compliance/safety handoff if needed

This document ensures that staff safety, abuse prevention, delivery rider conflict, service refusal escalation, emergency hold, alcohol stop, delivery stop, seating stop, emergency closure, and reopening review are governed before night high-risk operation is enabled.