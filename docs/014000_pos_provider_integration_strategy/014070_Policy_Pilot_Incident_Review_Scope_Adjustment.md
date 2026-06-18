# 014070_Policy_Pilot_Incident_Review_Scope_Adjustment

## 1. Purpose

This document defines the pilot incident review, blocker conversion, scope adjustment, waiver linkage, backlog extraction, recurrence prevention, evidence review, and pilot decision update policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined limited customer pilot scope restriction, customer communication, and live safety policy.

This document defines what must happen after pilot incidents, observations, staff confusion, customer feedback, provider failures, payment uncertainty, KDS issues, or support escalations occur during pilot operation.

This document does not resolve real incidents, implement fixes, create tickets, execute rollback, or approve pilot continuation.

It defines pilot incident review and conversion policy only.

---

## 2. Scope

This document covers:

- pilot incident review
- incident classification
- blocker conversion
- backlog extraction
- waiver linkage
- scope adjustment
- pilot pause and resume review
- customer impact review
- staff impact review
- provider impact review
- payment impact review
- KDS impact review
- support impact review
- evidence completeness review
- no-implementation boundary

This document does not cover:

- final incident management tool
- final support ticket system
- final customer compensation rule
- final payment refund execution
- final provider escalation contract
- final KDS hardware repair
- final production incident response
- final legal claim handling
- final commercial SLA

---

## 3. Core Principle

A pilot incident must become structured learning, not scattered memory.

The project must follow this rule:

> Every meaningful pilot incident must be reviewed, classified, linked to evidence, converted into blocker, backlog, waiver, scope change, SOP update, training need, or deferred item.

Pilot incidents are valuable only if they change the system, scope, or operating discipline.

---

## 4. Pilot Incident Definition

A pilot incident is any event during limited pilot that affects or may affect:

- customer trust
- payment certainty
- order acceptance
- KDS handoff
- staff operation
- support recovery
- provider reliability
- Mini Kiosk usability
- tenant/store isolation
- device trust
- evidence completeness
- rollback or pause capability
- pilot scope decision

Not every incident is a failure.

But every meaningful incident should be recorded.

---

## 5. Incident Source Types

Pilot incidents may originate from:

- customer report
- staff observation
- support case
- payment uncertainty
- provider event failure
- KDS duplicate suspicion
- Mini Kiosk timeout
- order acceptance mismatch
- cancel/refund confusion
- device trust issue
- export/report issue
- audit/evidence gap
- UI wording confusion
- staff training gap
- rollback or disable failure

Incident source must be recorded.

---

## 6. Incident Classification Values

Recommended incident classification values:

- `PAYMENT_INCIDENT`
- `ORDER_STATE_INCIDENT`
- `KDS_INCIDENT`
- `PROVIDER_INCIDENT`
- `MINI_KIOSK_INCIDENT`
- `SUPPORT_INCIDENT`
- `DEVICE_TRUST_INCIDENT`
- `TENANT_STORE_BOUNDARY_INCIDENT`
- `EXPORT_INCIDENT`
- `SECURITY_INCIDENT`
- `UI_CONFUSION_INCIDENT`
- `STAFF_TRAINING_INCIDENT`
- `CUSTOMER_COMMUNICATION_INCIDENT`
- `EVIDENCE_GAP_INCIDENT`
- `ROLLBACK_INCIDENT`
- `PILOT_SCOPE_INCIDENT`

Classification helps route review.

---

## 7. Incident Severity Values

Recommended severity values:

- `INCIDENT_CRITICAL`
- `INCIDENT_HIGH`
- `INCIDENT_MEDIUM`
- `INCIDENT_LOW`
- `INCIDENT_OBSERVATION`

Severity should reflect operational impact, customer trust, security risk, and pilot continuation risk.

Severity must not be inflated casually.

But critical incidents must not be softened.

---

## 8. Critical Incident Examples

Critical incidents include:

- duplicate customer charge
- false payment success shown
- raw CI/DI exposure
- support unmasked access without authority
- tenant/store data leakage
- duplicate KDS ticket prepared
- cancelled order prepared
- provider replay accepted as truth
- invalid provider callback accepted
- rollback or disable path failed
- staff cannot stop unsafe flow
- customer materially misled about payment/order status

Critical incidents should trigger pilot pause or severe scope restriction.

---

## 9. High Incident Examples

High incidents include:

- payment uncertainty not clearly explained
- KDS ticket duplicate suspected but caught before preparation
- support escalation delayed
- Mini Kiosk timeout caused customer confusion
- provider unavailable state unclear
- fallback used without complete evidence
- staff needed manager intervention
- UI wording caused wrong expectation
- evidence packet missing non-critical field
- pilot scope exceeded unintentionally

High incidents may not always pause pilot, but require review before scope increase.

---

## 10. Medium And Low Incident Examples

Medium incidents may include:

- minor UI wording confusion
- staff asked repeated clarification
- customer needed additional explanation
- non-critical support note missing
- evidence packet formatting issue
- delayed pilot metric recording
- menu option confusion
- non-critical timeout wording issue

Low incidents may include:

- cosmetic UI issue
- minor typo
- non-blocking workflow friction
- improvement suggestion
- observation for later UX polish

Medium and low incidents still create learning.

---

## 11. Incident Record Fields

Each incident record should include:

- incident id
- pilot run id
- date/time
- store
- incident classification
- severity
- source type
- customer impact
- staff impact
- affected runtime
- affected data flow
- affected provider
- affected UI
- state before
- state after
- triggering event
- action taken
- support case id
- evidence packet id
- blocker conversion decision
- scope impact
- customer recovery action
- reviewer
- status
- notes

The incident record must be traceable.

---

## 12. Incident ID Format

Recommended format:

    PILOT-INCIDENT-[YYYYMMDD]-[NUMBER]

Examples:

    PILOT-INCIDENT-20260612-001
    PILOT-INCIDENT-20260612-002

If store-specific:

    PILOT-INCIDENT-[STORE-ID]-[YYYYMMDD]-[NUMBER]

Final format may be normalized later.

---

## 13. Incident Status Values

Recommended incident status values:

- `OPEN`
- `UNDER_REVIEW`
- `EVIDENCE_REQUIRED`
- `CUSTOMER_RECOVERY_REQUIRED`
- `BLOCKER_CONVERSION_REQUIRED`
- `BACKLOG_EXTRACTION_REQUIRED`
- `SCOPE_REVIEW_REQUIRED`
- `WAIVER_REVIEW_REQUIRED`
- `RESOLVED`
- `CLOSED`
- `DEFERRED`
- `SUPERSEDED`

Incident should not be closed before evidence and decision are recorded.

---

## 14. Evidence Review Requirement

Incident review must verify:

- evidence packet exists
- timestamp is clear
- affected runtime is identified
- state before/after is clear
- customer impact is known
- staff action is recorded
- support action is recorded where applicable
- payment/KDS/provider impact is reviewed
- sensitive data is masked
- missing evidence is identified

If evidence is missing, the incident may become an evidence gap blocker.

---

## 15. Incident To Blocker Conversion Rule

An incident should become a blocker when it indicates:

- unsafe runtime behavior
- repeatable failure risk
- payment/order/KDS truth risk
- support access risk
- security or privacy risk
- staff cannot operate safely
- customer trust risk
- rollback failure
- provider validation failure
- evidence cannot prove what happened

Blockers require explicit resolution, waiver, or scope restriction.

---

## 16. Incident To Backlog Conversion Rule

An incident should become backlog when it indicates a needed:

- runtime fix
- state transition change
- UI wording change
- support workflow change
- KDS guard
- payment guard
- provider adapter improvement
- evidence packet improvement
- test case addition
- staff training item
- SOP update
- fallback improvement
- monitoring item

Backlog item must link to incident and evidence.

---

## 17. Incident To Waiver Rule

An incident may create waiver review when:

- issue is known
- risk is bounded
- pilot can continue with restriction
- compensating control exists
- customer impact is low or controlled
- fix is deferred intentionally
- reviewer accepts risk

Waiver cannot hide critical payment, privacy, tenant, support masking, or duplicate KDS risk without explicit high-level acceptance.

---

## 18. Incident To Scope Adjustment Rule

An incident should trigger scope adjustment when:

- pilot volume is too high
- time window is unsafe
- menu scope is too broad
- provider path is unstable
- Mini Kiosk use is too unsupervised
- KDS automation is premature
- support standby is insufficient
- staff training is insufficient
- customer eligibility is too broad

Scope should shrink before risk grows.

---

## 19. Scope Adjustment Types

Recommended scope adjustment types:

- `REDUCE_VOLUME`
- `REDUCE_TIME_WINDOW`
- `RETURN_TO_STAFF_ONLY`
- `DISABLE_MINI_KIOSK`
- `DISABLE_PROVIDER_PATH`
- `DISABLE_KDS_AUTO_HANDOFF`
- `REQUIRE_MANAGER_APPROVAL`
- `REQUIRE_SUPPORT_STANDBY`
- `LIMIT_MENU`
- `LIMIT_PAYMENT_METHOD`
- `LIMIT_CUSTOMER_TYPE`
- `PAUSE_PILOT`
- `EXIT_PILOT`

Scope adjustment must be visible and recorded.

---

## 20. Incident Review Decision Values

Recommended decision values:

- `NO_ACTION_OBSERVATION`
- `CREATE_BLOCKER`
- `CREATE_BACKLOG_ITEM`
- `CREATE_TEST_CASE`
- `CREATE_SOP_UPDATE`
- `CREATE_TRAINING_ITEM`
- `CREATE_UI_COPY_UPDATE`
- `CREATE_PROVIDER_REVIEW`
- `CREATE_PAYMENT_REVIEW`
- `CREATE_KDS_REVIEW`
- `CREATE_SUPPORT_REVIEW`
- `CREATE_SECURITY_REVIEW`
- `CREATE_WAIVER`
- `ADJUST_SCOPE`
- `PAUSE_PILOT`
- `EXIT_PILOT`

A single incident may produce multiple decisions.

---

## 21. Blocker Conversion Record Fields

If converted to blocker, record:

- blocker id
- source incident id
- source evidence packet
- blocker category
- severity
- affected runtime
- affected data flow
- affected provider
- affected UI
- affected staff role
- required correction
- required test
- required evidence
- pilot impact
- scope restriction
- owner
- status

Blocker must be traceable to incident.

---

## 22. Backlog Extraction Record Fields

If converted to backlog, record:

- backlog id
- source incident id
- source document if any
- source evidence packet
- requirement summary
- affected runtime
- data flow
- provider
- UI surface
- test requirement
- evidence requirement
- priority
- phase
- acceptance criteria
- non-goals
- owner
- status

Backlog from pilot should still obey phase cutline.

---

## 23. Test Case Creation Rule

An incident should create a new test case when:

- current tests did not cover scenario
- failure was surprising
- evidence was hard to verify
- staff action was ambiguous
- provider behavior differed from assumption
- payment/KDS state behaved unexpectedly
- support boundary was unclear
- UI allowed wrong expectation

Pilot incidents should expand the test catalog.

---

## 24. SOP Update Rule

An incident should create SOP update when:

- staff did not know what to do
- customer message was unclear
- fallback path was inconsistent
- support escalation was delayed
- manager approval boundary was unclear
- evidence capture was missed
- pause condition was misunderstood

SOP update may be as important as code change.

---

## 25. UI Copy Update Rule

An incident should create UI copy update when:

- customer misunderstood state
- staff misunderstood state
- uncertainty looked like success
- pending looked like completion
- held ticket looked like accepted ticket
- provider failure looked like user error
- support action wording implied authority
- cancel/refund wording was unclear

UI copy must preserve truth.

---

## 26. Provider Review Rule

An incident should create provider review when:

- provider event was delayed
- callback was duplicated
- signature behavior was unclear
- provider mapping failed
- local daemon timed out
- provider unavailable state was not detected
- provider error was hard to explain
- provider evidence was incomplete

Provider review may lead to integration change or scope restriction.

---

## 27. Payment Review Rule

An incident should create payment review when:

- payment status was uncertain
- duplicate payment suspected
- refund/cancel boundary unclear
- provider approval mismatch occurred
- customer asked about charge status
- payment evidence incomplete
- support could not verify payment state
- KDS handoff depended on ambiguous payment

Payment review is high priority.

---

## 28. KDS Review Rule

An incident should create KDS review when:

- duplicate KDS ticket suspected
- kitchen started unsafe ticket
- held ticket misunderstood
- cancelled order reached kitchen
- KDS unavailable state unclear
- bridge retry caused confusion
- manual kitchen note lacked evidence
- KDS completion was not trustworthy

KDS review protects operations.

---

## 29. Support Review Rule

An incident should create support review when:

- support access scope unclear
- masking failed or was confusing
- support session expired unexpectedly
- break-glass path unclear
- support proposed unsupported action
- support could not find evidence
- resolution was proposed without proof
- support communication delayed customer recovery

Support review protects recovery process.

---

## 30. Customer Recovery Review

Customer recovery review should answer:

- was customer harmed or inconvenienced?
- was apology appropriate?
- was payment/order issue resolved safely?
- was compensation needed?
- was communication honest?
- was provider blamed incorrectly?
- was support involved correctly?
- was evidence captured?
- is follow-up required?

Customer recovery must be humane and factual.

---

## 31. Staff Feedback Conversion

Staff feedback may convert to:

- training item
- SOP update
- UI copy update
- state label change
- support escalation rule
- fallback improvement
- blocker
- backlog item
- deferred item

Staff feedback should not be dismissed.

Staff are part of the runtime.

---

## 32. Customer Feedback Conversion

Customer feedback may convert to:

- UI copy improvement
- flow simplification
- help text improvement
- staff script improvement
- fallback communication improvement
- non-critical UX backlog
- pilot scope note
- deferred feature request

Customer feedback should not directly override runtime safety.

---

## 33. Recurrence Review

If similar incidents repeat, escalate severity.

Recurrence should be checked by:

- same runtime
- same data flow
- same UI label
- same staff confusion
- same provider path
- same payment uncertainty
- same KDS risk
- same support issue
- same customer complaint type

Repeated medium incidents may become high blocker.

---

## 34. Root Cause Classification

Recommended root cause classifications:

- `RUNTIME_STATE_GAP`
- `AUTHORITY_BOUNDARY_GAP`
- `PROVIDER_BEHAVIOR_GAP`
- `PAYMENT_VALIDATION_GAP`
- `KDS_GUARD_GAP`
- `UI_COPY_GAP`
- `STAFF_TRAINING_GAP`
- `SUPPORT_WORKFLOW_GAP`
- `EVIDENCE_PACKET_GAP`
- `SOP_GAP`
- `SCOPE_TOO_BROAD`
- `TEST_COVERAGE_GAP`
- `UNKNOWN`

Root cause should guide correction.

---

## 35. Incident Review Cadence

Recommended cadence during limited pilot:

- immediate review for critical incidents
- same-day review for high incidents
- end-of-day review for medium incidents
- weekly review for low incidents and observations
- before scope increase review for all open incidents
- before pilot resume review for all pause-related incidents

Cadence prevents backlog drift.

---

## 36. Pilot Decision Update Rule

After incident review, update pilot decision if needed.

Possible updates:

- continue unchanged
- continue with monitoring
- continue with scope restriction
- reduce volume
- return to staff-only dry run
- pause pilot
- exit pilot
- convert to internal simulation
- require implementation fix
- require training before resume

Pilot decision must follow evidence.

---

## 37. Incident Closure Rule

Incident may close only when:

- evidence reviewed
- customer impact resolved or acknowledged
- blocker/backlog/waiver/scope decision made
- owner assigned if action needed
- recurrence risk considered
- pilot decision updated if required
- status recorded

Do not close incident merely because the moment passed.

---

## 38. Registers Recommendation

Recommended future files:

    docs/_index/
      Pilot_Incident_Review_Register.md
      Pilot_Blocker_Conversion_Register.md
      Pilot_Backlog_Extraction_Register.md
      Pilot_Waiver_Linkage_Register.md
      Pilot_Scope_Adjustment_Register.md
      Pilot_Recurring_Issue_Register.md
      Pilot_Customer_Recovery_Register.md

This document only recommends these files.

It does not create them.

---

## 39. Anti-Patterns

The following are prohibited:

- treating incident as anecdote only
- closing incident without evidence
- ignoring repeated medium incidents
- converting every customer request directly into feature
- blaming staff without checking UI/SOP
- blaming provider without evidence
- continuing pilot after critical incident without decision
- hiding waiver from pilot record
- expanding scope while incidents remain unresolved
- treating customer recovery as separate from runtime learning
- fixing code without adding test
- updating SOP without training
- changing UI copy without checking authority truth

---

## 40. Non-Goals

This document does not define:

- final incident management software
- final compensation policy
- final legal escalation process
- final production incident response
- final provider support contract
- final customer service SLA
- final release approval process
- final operational dashboard

Those belong to later pilot execution and production operations.

---

## 41. Readiness Check

This document is ready when the project can answer:

1. What is a pilot incident?
2. What incident source types exist?
3. What incident classifications exist?
4. What severity values exist?
5. What are critical incident examples?
6. What are high incident examples?
7. What fields must incident record include?
8. What incident status values exist?
9. What evidence review is required?
10. When does incident become blocker?
11. When does incident become backlog?
12. When does incident create waiver review?
13. When does incident trigger scope adjustment?
14. What scope adjustment types exist?
15. What incident review decisions exist?
16. What blocker conversion fields are required?
17. What backlog extraction fields are required?
18. When should incident create new test case?
19. When should incident create SOP update?
20. When should incident create UI copy update?
21. When should incident create provider review?
22. When should incident create payment review?
23. When should incident create KDS review?
24. When should incident create support review?
25. How is customer recovery reviewed?
26. How is staff feedback converted?
27. How is customer feedback converted?
28. How is recurrence reviewed?
29. What root cause classifications exist?
30. What review cadence applies?
31. How is pilot decision updated?
32. When may incident close?
33. What anti-patterns are prohibited?

If these questions cannot be answered, pilot incident review and blocker conversion planning is incomplete.

---

## 42. Conclusion

Pilot incidents are not interruptions to the project.

They are the project’s evidence engine.

The safe incident flow is:

    incident occurs
        -> evidence captured
        -> classification
        -> severity assignment
        -> customer/staff/runtime impact review
        -> blocker/backlog/waiver/scope decision
        -> test/SOP/UI/support/provider update
        -> pilot decision update
        -> closure only after evidence

This document ensures that limited customer pilot produces structured learning, not scattered memory, and that every incident strengthens Phase 1 runtime safety, staff readiness, customer trust, and future SaaS reliability.