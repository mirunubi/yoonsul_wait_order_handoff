# 022006_Policy_MVP_Candidate_Prioritization_Phase_Tag_And_Scope_Cutline

## 1. Purpose

This document defines MVP candidate prioritization, phase tagging, scope cutline, required versus deferred backlog classification, pilot dependency, runtime safety dependency, test/evidence dependency, blocker handling, commercial readiness dependency, and implementation deferral policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined test/evidence backlog linkage, verification candidate register, evidence packet candidate register, failure severity, blocker linkage, review packet linkage, pilot readiness linkage, and build gate linkage.

This document focuses on deciding which extracted backlog candidates may become MVP candidates, which must remain pilot-only, which must be deferred, which are not for implementation, and which are blocked until legal, security, provider, payment, KDS, support, UI, evidence, or test readiness is complete.

This document does not authorize implementation, sprint planning, coding, UI build, database creation, provider integration, or production pilot.

It defines MVP prioritization and scope cutline policy only.

---

## 2. Scope

This document covers:

- MVP candidate meaning
- phase tag values
- scope cutline meaning
- required candidate classification
- pilot candidate classification
- deferred candidate classification
- not-for-implementation classification
- priority placeholder
- runtime safety criteria
- payment/KDS/provider criteria
- support/Admin criteria
- AI support gateway criteria
- pgvector/RAG criteria
- high-risk exclusion
- commercial readiness boundary
- blocker handling
- no-code boundary

This document does not cover:

- final sprint planning
- final engineering ticket creation
- final code implementation
- final UI design
- final payment gateway implementation
- final KDS integration
- final provider adapter build
- final production launch

---

## 3. Core Principle

MVP is the smallest safe operating system, not the smallest visible feature set.

The project must follow this rule:

> A backlog candidate may enter MVP only when it is required for controlled operation, runtime safety, evidence, support recovery, provider/payment/KDS trust, tenant/store boundary, or pilot readiness, and when its blockers, tests, evidence, and ownership are known.

MVP should not mean shortcut.

MVP should mean safe first version.

---

## 4. MVP Candidate Meaning

MVP candidate means a backlog item that may be required for the first controlled build, dry run, staff rehearsal, limited customer pilot, or early SaaS proof.

An MVP candidate should be:

- source-backed
- runtime-owned
- phase-tagged
- test-linked if critical
- evidence-linked if high-risk or dispute-sensitive
- blocker-aware
- support-aware
- UI-aware if user-facing
- safe under failure
- not dependent on unresolved high-risk activation

MVP candidate is still not implementation approval.

---

## 5. Scope Cutline Meaning

Scope cutline means the boundary between:

- must be included
- may be included
- should be deferred
- must be blocked
- not for implementation

Scope cutline protects the project from uncontrolled expansion.

Cutline should be recorded, not assumed.

---

## 6. Phase Tag Values

Recommended phase tag values:

- `PHASE_1_MVP_REQUIRED`
- `PHASE_1_MVP_CANDIDATE`
- `PHASE_1_PILOT_REQUIRED`
- `PHASE_1_ADMIN_MINIMUM`
- `PHASE_1_SUPPORT_MINIMUM`
- `PHASE_1_PAYMENT_KDS_REQUIRED`
- `PHASE_1_PROVIDER_REQUIRED`
- `PHASE_1_SECURITY_REQUIRED`
- `PHASE_1_EVIDENCE_REQUIRED`
- `PHASE_1_TEST_REQUIRED`
- `PHASE_1_COMMERCIAL_MINIMUM`
- `PHASE_2`
- `PHASE_3`
- `FUTURE`
- `DEFERRED`
- `BLOCKED`
- `NOT_FOR_IMPLEMENTATION`

Phase tag must be explicit.

---

## 7. Priority Placeholder Values

Recommended priority placeholders:

- `PRIORITY_UNSET`
- `PRIORITY_CRITICAL_SAFETY`
- `PRIORITY_PAYMENT_KDS`
- `PRIORITY_PROVIDER`
- `PRIORITY_SECURITY`
- `PRIORITY_SUPPORT`
- `PRIORITY_ADMIN_MINIMUM`
- `PRIORITY_PILOT`
- `PRIORITY_COMMERCIAL_MINIMUM`
- `PRIORITY_AI_SUPPORT_FOUNDATION`
- `PRIORITY_DEFERRED`
- `PRIORITY_BLOCKED`
- `PRIORITY_NOT_FOR_IMPLEMENTATION`

Priority placeholder is not final sprint priority.

---

## 8. MVP Required Candidate Rule

A backlog candidate may be marked `PHASE_1_MVP_REQUIRED` only when it is required to avoid unsafe or impossible first operation.

Examples:

- tenant/store context
- session continuity
- order handoff minimum
- payment safety boundary
- KDS ticket boundary
- provider event validation minimum
- duplicate prevention
- audit event minimum
- support recovery minimum
- evidence packet minimum
- Admin visibility minimum
- security masking minimum
- pilot blocker handling

MVP required means first build is unsafe without it.

---

## 9. MVP Candidate Rule

A backlog candidate may be marked `PHASE_1_MVP_CANDIDATE` when it improves first build safety or usability but can be reviewed against cutline.

Examples:

- enhanced dashboard
- additional support case type
- additional payment review view
- expanded KDS status
- provider incident dashboard
- AI support draft assist
- training surface
- advanced evidence search
- commercial health signal

Candidate must still be source-backed.

---

## 10. Pilot Required Rule

A backlog candidate may be marked `PHASE_1_PILOT_REQUIRED` when it is not strictly required for internal build but required before limited customer pilot.

Examples:

- customer communication copy
- staff dry run checklist
- pilot incident review
- pilot evidence packet
- customer recovery path
- rollback/pause decision
- support on-call process
- pilot dashboard
- daily learning log

Pilot required does not mean initial internal build required.

---

## 11. Admin Minimum Rule

Admin minimum should include only what is needed for controlled operation.

Admin minimum may include:

- tenant/store context view
- runtime status visibility
- support case visibility
- payment/KDS/provider review queue links
- evidence link display
- blocker visibility
- audit summary
- role/context boundary
- no unsafe override buttons

Admin minimum should not become enterprise console.

---

## 12. Support Minimum Rule

Support minimum should include only what is needed for safe recovery.

Support minimum may include:

- support case creation
- case-scoped masked view
- customer recovery note
- payment/KDS/provider timeline link
- escalation path
- support session audit
- evidence link
- safe customer response draft

Support minimum must remain privacy-preserving.

---

## 13. Payment KDS Required Rule

Payment/KDS items should be MVP-required when they prevent:

- double payment
- duplicate KDS ticket
- payment/KDS mismatch
- refund/cancel confusion
- KDS release under uncertainty
- POS/payment reconciliation gap
- provider signal causing kitchen execution without validation
- customer dispute without evidence

Payment and KDS are MVP safety core.

---

## 14. Provider Required Rule

Provider items should be MVP-required when they affect first provider-connected operation.

Provider MVP required may include:

- provider event validation
- idempotency
- duplicate handling
- stale event handling
- mapping rule
- evidence capture
- provider incident state
- provider official evidence tracking

Provider integration without validation is not MVP-safe.

---

## 15. Security Required Rule

Security items should be MVP-required when they protect:

- tenant/store isolation
- support access
- masking
- export/unmask boundary
- payment data
- provider secrets
- CI/DI
- audit integrity
- device/session trust

Security minimum is not optional.

---

## 16. Evidence Required Rule

Evidence items should be MVP-required when they support:

- payment dispute
- refund/cancel decision
- KDS hold/release
- provider mismatch
- support recovery
- pilot incident
- security access
- Admin approval
- customer trust recovery

Evidence minimum prevents unresolved blame.

---

## 17. Test Required Rule

Test items should be MVP-required when failure would affect:

- payment safety
- KDS execution
- provider mapping
- tenant isolation
- support access
- export/unmask
- AI support data boundary
- pilot launch
- high-risk blocker

Critical tests must exist before build gate.

---

## 18. Commercial Minimum Rule

Commercial minimum should include only what is needed to avoid confusion.

Commercial minimum may include:

- pilot scope statement
- included/excluded capabilities
- support tier placeholder
- billing responsibility placeholder
- provider cost visibility placeholder
- renewal/churn not required for first MVP
- commercial promise boundary

Commercial minimum must not oversell.

---

## 19. AI Support Foundation Rule

AI support backlog may enter MVP only if it is bounded.

MVP AI support may include:

- internal SOP retrieval
- support answer draft
- source citation
- confidence/freshness indicator
- human review requirement
- masked case context
- escalation suggestion

MVP AI support must not include:

- autonomous refund
- autonomous KDS action
- unrestricted DB query
- raw identity exposure
- legal conclusion
- production customer-facing final answer without review

AI support should start as assistive, not autonomous.

---

## 20. pgvector RAG Foundation Rule

pgvector/RAG backlog may enter MVP only as controlled knowledge retrieval.

MVP pgvector/RAG may include:

- sanitized SOP index
- policy document retrieval
- internal support knowledge search
- source citation
- freshness metadata
- access-scoped retrieval
- no sensitive raw operational embedding

It must not include:

- raw CI/DI embedding
- payment secret embedding
- provider raw payload embedding
- final runtime truth replacement
- legal answer generation without review

pgvector is foundation retrieval, not authority.

---

## 21. High-Risk Exclusion Rule

High-risk operation is excluded from MVP by default.

Default exclusions:

- alcohol sales activation
- delivery alcohol
- adult verification live provider integration
- minor access live workflow
- alcohol KDS release flow
- high-risk payment/refund flow
- service refusal automation
- night safety store closure automation

High-risk policies may remain documented as constraints.

---

## 22. High-Risk Exception Rule

High-risk item may enter MVP only if:

- business decision explicitly requires it
- legal review is complete
- security review is complete
- payment/KDS review is complete
- support workflow is ready
- staff training is ready
- evidence packet is defined
- tests are mapped
- activation gate is approved
- rollback/disable path exists

Exception must be rare and documented.

---

## 23. Deferred Rule

A backlog candidate should be marked `DEFERRED` when:

- not required for MVP
- not required for pilot
- legal/security review pending
- provider evidence unavailable
- test/evidence mapping missing
- advanced UI not needed
- automation can wait
- commercial package not ready
- high-risk operation disabled
- future data required

Deferred item must have re-entry trigger.

---

## 24. Blocked Rule

A backlog candidate should be marked `BLOCKED` when:

- source unclear
- owner missing
- authority unclear
- legal review required
- security review required
- provider evidence missing
- critical test missing
- evidence missing
- payment/KDS dependency unresolved
- high-risk activation unsafe
- commercial promise exceeds readiness

Blocked item cannot reach build gate.

---

## 25. Not For Implementation Rule

A backlog candidate should be marked `NOT_FOR_IMPLEMENTATION` when it is:

- principle only
- anti-pattern only
- legal review question
- documentation hygiene note
- future caution
- architecture reminder
- archive rule
- source-of-truth rule
- training philosophy
- range governance note

Not every extracted statement becomes software.

---

## 26. Cutline Decision Values

Recommended cutline decision values:

- `INCLUDE_MVP_REQUIRED`
- `INCLUDE_MVP_CANDIDATE`
- `INCLUDE_PILOT_REQUIRED`
- `INCLUDE_ADMIN_MINIMUM`
- `INCLUDE_SUPPORT_MINIMUM`
- `INCLUDE_TEST_EVIDENCE_REQUIRED`
- `DEFER_PHASE_2`
- `DEFER_PHASE_3`
- `DEFER_FUTURE`
- `BLOCK_UNTIL_REVIEW`
- `BLOCK_UNTIL_EVIDENCE`
- `BLOCK_UNTIL_TEST`
- `NOT_FOR_IMPLEMENTATION`
- `REJECT`

Cutline decision must include reason.

---

## 27. Cutline Record Fields

Each cutline record should include:

- cutline id
- backlog id
- source reference
- runtime owner
- surface owner if any
- phase tag
- priority placeholder
- cutline decision
- decision reason
- required tests
- required evidence
- blockers
- deferred trigger
- reviewer
- status
- notes

Cutline record preserves decision history.

---

## 28. Cutline ID Format

Recommended format:

    CUTLINE-[YYYYMMDD]-[NUMBER]

Example:

    CUTLINE-20260612-001

Final format may be normalized later.

---

## 29. MVP Scoring Placeholder Rule

MVP scoring may be used later.

Possible scoring dimensions:

- safety criticality
- runtime dependency
- payment/KDS impact
- provider dependency
- support recovery need
- pilot necessity
- customer visibility
- evidence necessity
- testability
- legal/security blocker
- implementation complexity
- deferrability

This document does not define final scoring formula.

---

## 30. Required Versus Nice-To-Have Rule

A backlog candidate is required when absence creates:

- unsafe operation
- unverifiable payment
- uncontrolled KDS execution
- provider ambiguity
- support inability
- security exposure
- pilot failure
- customer trust failure

A backlog candidate is nice-to-have when absence creates inconvenience but not unsafe operation.

Nice-to-have should usually defer.

---

## 31. Manual Fallback Consideration Rule

A backlog item may defer if manual fallback exists.

Manual fallback must be:

- defined
- staff-operable
- evidence-backed
- auditable
- safe under peak operation
- not legally risky
- not privacy-invasive

Manual fallback is acceptable only when realistic.

---

## 32. Peak Operation Consideration Rule

MVP cutline must consider peak operation.

Backlog should be prioritized when it prevents:

- order bottleneck
- payment ambiguity
- KDS overload
- support chaos
- staff confusion
- duplicate work
- customer queue growth
- provider mismatch
- untracked incident

MVP should protect the busy hour, not only normal hour.

---

## 33. Store Revenue Protection Rule

Backlog may be prioritized when it protects store revenue without compromising safety.

Revenue-protecting items may include:

- fast order intake
- payment reliability
- KDS queue clarity
- sold-out visibility
- provider failure handling
- support recovery
- pilot blocker visibility
- customer communication

Revenue protection must not override security, payment truth, or staff safety.

---

## 34. Commercial Cutline Rule

Commercial backlog should be cut conservatively.

MVP commercial may include:

- pilot package definition
- capability inclusion/exclusion
- provider cost awareness
- support tier placeholder
- billing responsibility placeholder
- no overpromise statement

Advanced commercial workflows should defer.

---

## 35. UI Cutline Rule

UI backlog should be cut by operational need.

MVP UI should include:

- customer flow minimum
- staff flow minimum
- KDS visibility minimum
- support case minimum
- Admin visibility minimum
- payment/KDS/provider review minimum
- evidence link minimum
- error/recovery minimum

Advanced dashboards and analytics should defer.

---

## 36. AI Cutline Rule

AI backlog should be cut by risk.

MVP AI may support:

- internal search
- support draft
- SOP lookup
- document retrieval
- incident pattern suggestion

MVP AI must not:

- perform autonomous action
- make final legal decision
- mutate runtime state
- expose raw sensitive data
- bypass human review

AI should enter as assist layer.

---

## 37. Documentation Governance Cutline Rule

Documentation governance backlog may be MVP-required when it protects:

- source-of-truth
- PC import
- open gap visibility
- blocker tracking
- test/evidence mapping
- build gate input
- patch/supersession traceability

Documentation governance is part of system reliability.

---

## 38. Cutline Review Rule

Cutline should be reviewed before:

- MVP build gate
- pilot planning
- provider integration
- Admin Console wireframe
- support process design
- payment/KDS implementation
- AI support gateway planning
- commercial package confirmation

Cutline review prevents scope creep.

---

## 39. Cutline Change Rule

Cutline may change when:

- blocker is resolved
- provider evidence arrives
- legal/security review changes
- pilot scope changes
- business priority changes
- payment/KDS risk increases
- support capacity changes
- revenue strategy changes
- UI risk is discovered
- manual fallback proves unrealistic

Cutline change must be recorded.

---

## 40. MVP Candidate Register Fields

Each MVP candidate record should include:

- backlog id
- source reference
- runtime owner
- surface owner
- phase tag
- priority placeholder
- reason for MVP inclusion
- required tests
- required evidence
- blockers
- manual fallback if any
- pilot dependency
- commercial dependency
- status
- notes

MVP candidate register prepares build gate.

---

## 41. Deferred Candidate Register Fields

Each deferred candidate record should include:

- backlog id
- source reference
- runtime owner
- reason for deferral
- deferred phase
- re-entry trigger
- blocker if any
- required future evidence
- required future test
- commercial dependency
- status
- notes

Deferred backlog must not disappear.

---

## 42. Not For Implementation Register Fields

Each not-for-implementation record should include:

- source reference
- extracted statement
- reason
- related backlog if any
- related documentation range
- review need if any
- status
- notes

Not-for-implementation items preserve architectural wisdom.

---

## 43. Build Gate Input Rule

Build gate should receive:

- MVP required list
- MVP candidate list
- pilot required list
- deferred list
- blocked list
- not-for-implementation list
- test/evidence linkage
- review packet status
- cutline decisions
- unresolved gaps
- manual fallback assumptions

Build gate must not receive unclassified backlog.

---

## 44. Anti-Patterns

The following are prohibited:

- treating all extracted backlog as MVP
- treating visible UI as MVP priority over runtime safety
- putting high-risk alcohol mode into MVP by default
- ignoring payment/KDS/provider blockers
- ignoring evidence/test requirements
- using commercial urgency to override safety
- allowing AI autonomy in MVP
- deferring source-of-truth governance
- moving nice-to-have dashboard into MVP while support recovery is missing
- changing cutline without record
- calling MVP complete without pilot readiness

---

## 45. No-Code Boundary

This document does not authorize:

- sprint creation
- implementation ticket execution
- database schema creation
- payment integration
- KDS integration
- POS integration
- provider adapter build
- Admin Console build
- AI support gateway build
- pgvector index build
- production pilot

This document governs prioritization and cutline only.

---

## 46. Registers Recommendation

Recommended future files:

    docs/_index/
      MVP_Candidate_Register.md
      MVP_Required_Register.md
      Pilot_Required_Register.md
      Deferred_Candidate_Register.md
      Not_For_Implementation_Register.md
      Cutline_Decision_Register.md
      MVP_Scoring_Placeholder_Register.md
      Manual_Fallback_Assumption_Register.md
      Cutline_Change_Register.md
      Build_Gate_Input_Register.md

This document only recommends these files.

It does not create them.

---

## 47. Readiness Check

This document is ready when the project can answer:

1. What is MVP candidate?
2. What is scope cutline?
3. What phase tag values exist?
4. What priority placeholders exist?
5. What MVP required candidate rule applies?
6. What MVP candidate rule applies?
7. What pilot required rule applies?
8. What Admin minimum rule applies?
9. What Support minimum rule applies?
10. What Payment/KDS required rule applies?
11. What Provider required rule applies?
12. What Security required rule applies?
13. What Evidence required rule applies?
14. What Test required rule applies?
15. What Commercial minimum rule applies?
16. What AI support foundation rule applies?
17. What pgvector/RAG foundation rule applies?
18. What high-risk exclusion rule applies?
19. What high-risk exception rule applies?
20. What deferred rule applies?
21. What blocked rule applies?
22. What not-for-implementation rule applies?
23. What cutline decision values exist?
24. What fields should cutline record include?
25. What MVP scoring placeholder rule applies?
26. What required versus nice-to-have rule applies?
27. What manual fallback consideration rule applies?
28. What peak operation consideration rule applies?
29. What store revenue protection rule applies?
30. What commercial cutline rule applies?
31. What UI cutline rule applies?
32. What AI cutline rule applies?
33. What documentation governance cutline rule applies?
34. What cutline review rule applies?
35. What cutline change rule applies?
36. What fields should MVP candidate register include?
37. What fields should deferred candidate register include?
38. What fields should not-for-implementation register include?
39. What build gate input rule applies?
40. What anti-patterns are prohibited?
41. What no-code boundary applies?
42. What registers are recommended?

If these questions cannot be answered, MVP candidate prioritization, phase tagging, and scope cutline planning is incomplete.

---

## 48. Conclusion

MVP is not the smallest demo.

MVP is the smallest safe operating system that can survive real store conditions, peak-hour pressure, payment ambiguity, KDS load, provider uncertainty, support recovery, evidence needs, and pilot learning.

The safe cutline flow is:

    backlog candidate
        -> runtime owner
        -> phase tag
        -> priority placeholder
        -> test and evidence linkage
        -> blocker review
        -> required, candidate, pilot, deferred, blocked, or not-for-implementation decision
        -> build gate input

This document ensures that MVP selection is driven by operational safety, payment/KDS/provider reliability, support recovery, evidence, security, peak-hour survivability, and controlled pilot readiness rather than feature excitement or commercial pressure.