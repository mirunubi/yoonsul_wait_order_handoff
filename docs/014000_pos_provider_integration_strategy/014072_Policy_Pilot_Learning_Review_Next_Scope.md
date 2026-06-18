# 014072_Policy_Pilot_Learning_Review_Next_Scope

## 1. Purpose

This document defines the pilot learning daily review, weekly consolidation, scope decision, evidence aggregation, blocker trend review, customer feedback review, staff feedback review, provider reliability review, payment/KDS/support learning review, and next-scope governance policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined pilot incident review, blocker conversion, and scope adjustment.

This document defines how pilot learning should be reviewed over time so that the pilot can safely continue, pause, narrow, expand, or exit.

This document does not run a real pilot, create dashboards, implement analytics, execute customer feedback surveys, or approve commercial rollout.

It defines pilot learning review and next scope decision policy only.

---

## 2. Scope

This document covers:

- daily pilot review
- weekly pilot consolidation
- evidence aggregation
- incident trend review
- blocker trend review
- customer feedback review
- staff feedback review
- payment learning review
- KDS learning review
- provider learning review
- support learning review
- Mini Kiosk learning review
- scope increase/reduction decision
- next pilot stage decision
- no-production boundary

This document does not cover:

- final pilot dashboard implementation
- final analytics schema
- final customer survey form
- final staff survey form
- final SLA
- final production rollout
- final franchise rollout
- final SaaS customer success automation
- final commercial pricing decision

---

## 3. Core Principle

Pilot learning must be reviewed before scope grows.

The project must follow this rule:

> A pilot may expand only after daily evidence, weekly trends, unresolved blockers, customer feedback, staff feedback, provider behavior, payment safety, KDS safety, support readiness, and rollback readiness have been reviewed.

Learning without decision is noise.

Decision without evidence is risk.

---

## 4. Why Daily And Weekly Review Matters

A limited pilot produces many signals:

- incidents
- near misses
- staff confusion
- customer confusion
- provider delays
- payment uncertainty
- KDS handoff issues
- fallback usage
- support escalations
- UI wording issues
- evidence gaps
- training gaps
- scope pressure

Daily review catches immediate risk.

Weekly consolidation detects patterns.

Both are required.

---

## 5. Review Layers

Recommended pilot review layers:

| Layer | Purpose |
| ----- | ------- |
| Real-Time Stop/Pause | handle critical safety issue immediately |
| End-Of-Day Review | capture daily learning and blockers |
| Weekly Consolidation | identify patterns and scope decision |
| Scope Decision Review | decide increase, reduce, pause, or exit |
| Backlog Extraction Review | convert learning into product work |
| Pilot Readiness Recheck | confirm next stage safety |

These layers should not be collapsed into one informal conversation.

---

## 6. Daily Review Purpose

Daily review should answer:

- what happened today?
- how many pilot sessions ran?
- were there incidents?
- were there payment uncertainties?
- were there KDS issues?
- were there provider issues?
- were there support cases?
- did staff use fallback?
- did customers show confusion?
- did staff show confusion?
- was evidence complete?
- should pilot continue tomorrow?

Daily review is operational safety control.

---

## 7. Daily Review Record Fields

Each daily review should record:

- daily review id
- date
- pilot run ids
- store
- time window
- customer session count
- order intent count
- accepted order count
- payment approval count
- payment uncertainty count
- KDS ticket count
- KDS issue count
- support case count
- fallback count
- incidents
- blockers opened
- blockers closed
- customer feedback summary
- staff feedback summary
- evidence completeness
- decision for next day
- reviewer
- notes

This record should be preserved as pilot evidence.

---

## 8. Daily Review ID Format

Recommended format:

    PILOT-DAILY-REVIEW-[YYYYMMDD]-[STORE]

Example:

    PILOT-DAILY-REVIEW-20260612-STORE001

Final format may be normalized later.

---

## 9. Daily Review Status Values

Recommended status values:

- `NOT_STARTED`
- `IN_REVIEW`
- `COMPLETE_CONTINUE`
- `COMPLETE_CONTINUE_WITH_RESTRICTION`
- `COMPLETE_PAUSE_REQUIRED`
- `COMPLETE_SCOPE_REDUCTION_REQUIRED`
- `COMPLETE_STAFF_RETRAINING_REQUIRED`
- `COMPLETE_BLOCKER_REVIEW_REQUIRED`
- `COMPLETE_EXIT_RECOMMENDED`

Daily review must produce a decision.

---

## 10. Weekly Consolidation Purpose

Weekly consolidation should answer:

- what patterns emerged?
- are incidents decreasing or increasing?
- is payment uncertainty manageable?
- is KDS handoff stable?
- is staff confidence improving?
- is customer confusion decreasing?
- is provider behavior reliable?
- is support burden acceptable?
- is evidence complete?
- can scope increase?
- should scope remain?
- should scope reduce?
- should pilot pause or exit?

Weekly consolidation transforms daily signals into strategy.

---

## 11. Weekly Consolidation Record Fields

Each weekly consolidation should record:

- weekly review id
- week start
- week end
- store
- pilot days included
- total sessions
- total order intents
- total accepted orders
- total payment uncertainties
- total KDS issues
- total support cases
- total fallback uses
- total incidents by severity
- open blockers
- resolved blockers
- recurring issues
- customer feedback themes
- staff feedback themes
- provider reliability themes
- payment safety assessment
- KDS safety assessment
- support readiness assessment
- scope decision
- next week recommendation
- reviewer
- notes

Weekly review should be evidence-based.

---

## 12. Weekly Review ID Format

Recommended format:

    PILOT-WEEKLY-REVIEW-[YYYYMMDD]-[STORE]

Example:

    PILOT-WEEKLY-REVIEW-20260612-STORE001

The date may represent the week ending date.

---

## 13. Weekly Review Status Values

Recommended values:

- `NOT_STARTED`
- `IN_REVIEW`
- `PATTERN_REVIEW_REQUIRED`
- `SCOPE_DECISION_REQUIRED`
- `CONTINUE_CURRENT_SCOPE`
- `INCREASE_SCOPE_RECOMMENDED`
- `REDUCE_SCOPE_RECOMMENDED`
- `PAUSE_RECOMMENDED`
- `EXIT_RECOMMENDED`
- `BACKLOG_EXTRACTION_REQUIRED`
- `TRAINING_REQUIRED`
- `IMPLEMENTATION_FIX_REQUIRED`

Weekly review must not be vague.

---

## 14. Learning Categories

Pilot learning should be categorized.

Recommended categories:

- `PAYMENT_LEARNING`
- `ORDER_FLOW_LEARNING`
- `KDS_LEARNING`
- `PROVIDER_LEARNING`
- `MINI_KIOSK_LEARNING`
- `SUPPORT_LEARNING`
- `STAFF_TRAINING_LEARNING`
- `CUSTOMER_COMMUNICATION_LEARNING`
- `UI_COPY_LEARNING`
- `EVIDENCE_PACKET_LEARNING`
- `FALLBACK_LEARNING`
- `ROLLBACK_LEARNING`
- `SCOPE_LEARNING`
- `SAAS_VALUE_LEARNING`

Learning category helps route action.

---

## 15. Payment Learning Review

Payment learning review should check:

- how often payment uncertainty occurred
- whether uncertainty was displayed clearly
- whether customers understood explanation
- whether staff handled uncertainty correctly
- whether duplicate payment risk appeared
- whether refund/cancel boundary was clear
- whether evidence was complete
- whether provider behavior caused ambiguity
- whether support could review payment state safely

Payment learning is high priority.

---

## 16. KDS Learning Review

KDS learning review should check:

- whether KDS ticket creation was safe
- whether duplicate ticket risk appeared
- whether kitchen understood held/pending/accepted states
- whether cancellation after KDS handoff was clear
- whether degraded kitchen note path worked
- whether KDS evidence was complete
- whether kitchen started only safe tickets
- whether staff trusted KDS status correctly

KDS learning protects kitchen execution.

---

## 17. Provider Learning Review

Provider learning review should check:

- provider event delay
- provider timeout frequency
- duplicate callback occurrence
- mapping failure
- signature or validation failure
- local daemon instability if applicable
- provider unavailable state handling
- provider evidence completeness
- provider support/dealer response
- phase 1 provider assumption validity

Provider learning may affect provider cutline.

---

## 18. Mini Kiosk Learning Review

Mini Kiosk learning review should check:

- session creation clarity
- order intent capture clarity
- timeout/abandonment frequency
- customer confusion
- staff intervention count
- payment state display
- provider failure display
- support handoff clarity
- unsupported option pressure
- ghost order risk

Mini Kiosk learning informs UI and runtime refinement.

---

## 19. Support Learning Review

Support learning review should check:

- support case frequency
- masked view effectiveness
- support session timeout behavior
- break-glass usage
- support evidence completeness
- support response time
- support communication clarity
- support overreach risk
- staff dependency on support
- customer recovery quality

Support learning protects recovery without mutation.

---

## 20. Staff Learning Review

Staff learning review should check:

- staff confusion count
- repeated questions
- payment uncertainty confidence
- KDS state confidence
- fallback confidence
- support escalation confidence
- customer communication quality
- evidence capture quality
- stop/pause judgment
- training needs

Staff learning is part of system learning.

---

## 21. Customer Learning Review

Customer learning review should check:

- customer confusion
- customer wait tolerance
- trust in payment status
- understanding of order acceptance
- comfort with Mini Kiosk
- reaction to staff help
- reaction to fallback
- complaint type
- recovery satisfaction
- willingness to use again

Customer learning should not override safety.

---

## 22. Evidence Completeness Review

Evidence completeness review should check:

- daily pilot evidence exists
- incident evidence exists
- payment evidence exists
- KDS evidence exists
- support evidence exists
- fallback evidence exists
- customer recovery evidence exists
- blocker linkage exists
- waiver linkage exists
- sensitive data masked
- missing evidence recorded

Evidence gaps reduce learning reliability.

---

## 23. Fallback Learning Review

Fallback learning review should check:

- how often fallback occurred
- why fallback occurred
- whether fallback was safe
- whether fallback evidence was complete
- whether fallback caused customer confusion
- whether fallback caused staff burden
- whether fallback should become SOP
- whether system should reduce fallback need
- whether fallback indicates scope too broad

Fallback frequency is a signal.

---

## 24. Scope Learning Review

Scope learning review should check:

- was volume too high?
- was time window appropriate?
- was customer eligibility too broad?
- was menu scope too broad?
- was provider scope too broad?
- was KDS automation too early?
- was Mini Kiosk supervision sufficient?
- was support standby sufficient?
- should scope increase, stay, reduce, pause, or exit?

Scope must follow learning.

---

## 25. SaaS Value Learning Review

SaaS value learning review should check:

- did store operation become smoother?
- did staff intervention decrease?
- did owner see value?
- did support burden remain acceptable?
- did payment/KDS safety improve trust?
- did Mini Kiosk reduce friction?
- did evidence help decision-making?
- did pilot suggest paid conversion potential?
- did pricing/package assumption change?

SaaS value learning must be based on operation, not optimism.

---

## 26. Learning To Action Decision Values

Recommended values:

- `NO_ACTION`
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
- `CREATE_SCOPE_CHANGE`
- `CREATE_WAIVER_REVIEW`
- `DEFER_TO_PHASE_2`
- `ARCHIVE_AS_OBSERVATION`

Each learning item should have an action decision.

---

## 27. Scope Decision Values

Recommended values:

- `CONTINUE_CURRENT_SCOPE`
- `REDUCE_VOLUME`
- `REDUCE_TIME_WINDOW`
- `RETURN_TO_STAFF_ONLY`
- `PAUSE_PILOT`
- `EXIT_PILOT`
- `INCREASE_VOLUME`
- `INCREASE_TIME_WINDOW`
- `ADD_MENU_SCOPE`
- `ADD_CUSTOMER_SCOPE`
- `ADD_PAYMENT_SCOPE`
- `ADD_KDS_SCOPE`
- `ADD_PROVIDER_SCOPE`
- `PREPARE_PAID_PILOT_CONVERSION`

Scope decision must be evidence-driven.

---

## 28. Scope Increase Gate

Scope may increase only when:

1. no critical blocker is open
2. payment uncertainty is handled
3. KDS duplicate risk is controlled
4. support masking is stable
5. staff readiness is confirmed
6. evidence packets are complete
7. customer confusion is acceptable
8. fallback use is not excessive
9. rollback path is confirmed
10. weekly review recommends increase

Increase should be incremental.

---

## 29. Scope Reduction Gate

Scope should reduce when:

- repeated incidents occur
- staff confusion persists
- customer confusion persists
- provider instability continues
- payment uncertainty is too frequent
- KDS issues recur
- support burden is too high
- fallback is used too often
- evidence is incomplete
- store manager confidence decreases

Reduction protects pilot credibility.

---

## 30. Pause Gate

Pilot should pause when:

- critical incident occurs
- blocker remains unresolved
- payment truth is unsafe
- KDS duplicate risk is unresolved
- support masking fails
- tenant/store boundary fails
- rollback fails
- customer trust risk rises
- staff readiness drops
- evidence cannot prove what happened

Pause is a safety decision.

---

## 31. Exit Gate

Pilot should exit when:

- scope cannot be made safe
- provider dependency is not viable
- payment truth cannot be controlled
- KDS safety cannot be guaranteed
- support burden is unsustainable
- staff cannot operate reliably
- customer trust risk remains high
- blockers exceed recovery capacity
- pilot goal has been achieved and next stage is different

Exit is not failure if learning is preserved.

---

## 32. Learning Item Record Fields

Each learning item should record:

- learning id
- source daily review
- source weekly review
- source incident if any
- category
- summary
- affected runtime
- affected data flow
- affected provider
- affected UI
- customer impact
- staff impact
- evidence reference
- action decision
- priority
- phase
- owner
- status
- notes

Learning item should be traceable.

---

## 33. Learning ID Format

Recommended format:

    PILOT-LEARNING-[YYYYMMDD]-[NUMBER]

Examples:

    PILOT-LEARNING-20260612-001
    PILOT-LEARNING-20260612-002

Final format may be normalized later.

---

## 34. Learning Status Values

Recommended values:

- `OPEN`
- `UNDER_REVIEW`
- `ACTION_DECISION_REQUIRED`
- `ACTION_ASSIGNED`
- `BACKLOG_CREATED`
- `SOP_CREATED`
- `TRAINING_CREATED`
- `TEST_CREATED`
- `SCOPE_DECIDED`
- `DEFERRED`
- `ARCHIVED`
- `CLOSED`

Learning should not remain permanently open without decision.

---

## 35. Daily Review Decision Rule

Daily review decision should be conservative.

If evidence is incomplete or critical state is unclear, choose:

- continue with restriction
- reduce scope
- pause
- repeat staff dry run

Do not continue normally when the day’s evidence cannot prove safe operation.

---

## 36. Weekly Review Decision Rule

Weekly review decision should identify patterns.

If the same issue appears repeatedly:

- increase severity
- create blocker
- create test case
- create SOP/training update
- prevent scope increase
- consider scope reduction

Patterns matter more than isolated optimism.

---

## 37. Paid Pilot Conversion Signal

Paid pilot conversion may be considered only when:

- operation is stable within scope
- customer trust is not harmed
- owner/store sees value
- support burden is understood
- evidence packets are complete
- pricing boundary is clear
- unresolved blockers are acceptable
- pilot value is repeatable

Paid conversion should not happen only because one demo went well.

---

## 38. Next Store Expansion Signal

Next store expansion may be considered only when:

- current store pilot is stable
- documentation and SOP are updated
- staff training materials improved
- critical blockers resolved
- provider path stable
- payment/KDS/support evidence stable
- rollback path confirmed
- scope expansion decision is approved

Do not expand store count to escape unresolved issues.

---

## 39. Review Cadence

Recommended cadence:

| Review | Cadence |
| ------ | ------- |
| Real-time pause review | immediately |
| Daily review | end of each pilot day |
| Incident review | same day for high/critical |
| Weekly consolidation | weekly |
| Scope decision | weekly or after major incident |
| Backlog extraction | weekly |
| Paid conversion review | after stable pilot evidence |
| Next store review | after current pilot consolidation |

Cadence should match pilot intensity.

---

## 40. Registers Recommendation

Recommended future files:

    docs/_index/
      Pilot_Daily_Review_Register.md
      Pilot_Weekly_Consolidation_Register.md
      Pilot_Learning_Item_Register.md
      Pilot_Scope_Decision_Register.md
      Pilot_SaaS_Value_Learning_Register.md
      Pilot_Next_Store_Expansion_Register.md

This document only recommends these files.

It does not create them.

---

## 41. Anti-Patterns

The following are prohibited:

- expanding pilot scope without weekly review
- treating daily anecdotes as final truth
- ignoring repeated medium incidents
- continuing pilot when evidence is incomplete
- increasing volume because staff feels optimistic only
- converting to paid pilot without operational evidence
- expanding to next store before current store stabilizes
- focusing only on speed metrics
- ignoring support burden
- ignoring fallback frequency
- ignoring customer confusion
- ignoring staff confusion
- treating pilot learning as informal memory
- closing learning items without action decision

---

## 42. Non-Goals

This document does not define:

- final analytics dashboard
- final customer survey
- final staff survey
- final customer success automation
- final pricing decision
- final paid conversion contract
- final next-store onboarding
- final production rollout

Those belong to later SaaS commercialization and rollout planning.

---

## 43. Readiness Check

This document is ready when the project can answer:

1. Why are daily and weekly reviews required?
2. What review layers exist?
3. What is daily review purpose?
4. What fields should daily review record include?
5. What daily review status values exist?
6. What is weekly consolidation purpose?
7. What fields should weekly review record include?
8. What weekly review status values exist?
9. What learning categories exist?
10. How is payment learning reviewed?
11. How is KDS learning reviewed?
12. How is provider learning reviewed?
13. How is Mini Kiosk learning reviewed?
14. How is support learning reviewed?
15. How is staff learning reviewed?
16. How is customer learning reviewed?
17. How is evidence completeness reviewed?
18. How is fallback learning reviewed?
19. How is scope learning reviewed?
20. How is SaaS value learning reviewed?
21. What learning-to-action decisions exist?
22. What scope decision values exist?
23. What scope increase gate applies?
24. What scope reduction gate applies?
25. What pause gate applies?
26. What exit gate applies?
27. What fields should learning item record include?
28. What daily review decision rule applies?
29. What weekly review decision rule applies?
30. When can paid pilot conversion be considered?
31. When can next store expansion be considered?
32. What review cadence applies?
33. What anti-patterns are prohibited?

If these questions cannot be answered, pilot learning review and next scope decision planning is incomplete.

---

## 44. Conclusion

Pilot learning must become structured decision-making.

The safe learning flow is:

    daily pilot evidence
        -> daily review
        -> incident and blocker update
        -> weekly consolidation
        -> learning item decisions
        -> scope decision
        -> backlog/SOP/training/test updates
        -> next pilot stage decision

A pilot becomes valuable when it produces evidence-based learning that improves runtime safety, staff readiness, customer trust, support discipline, provider selection, payment/KDS reliability, SaaS packaging, and rollout strategy.

This document ensures that the project expands only when learning proves it is safe to do so.