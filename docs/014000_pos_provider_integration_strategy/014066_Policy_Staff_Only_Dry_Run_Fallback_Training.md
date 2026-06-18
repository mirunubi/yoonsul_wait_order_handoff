# 014066_Policy_Staff_Only_Dry_Run_Fallback_Training

## 1. Purpose

This document defines the staff-only dry run, store role rehearsal, operational fallback training, simulated customer handling, Mini Kiosk rehearsal, payment uncertainty rehearsal, KDS handoff rehearsal, support escalation practice, and pre-pilot staff readiness policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined internal simulation, dry run, and pre-pilot rehearsal policy.

This document defines the staff-only rehearsal layer before limited customer pilot exposure.

This document does not train real staff, create training materials, implement UI, run POS/KDS integration, or approve pilot start.

It defines staff-only dry run and operational fallback training policy only.

---

## 2. Scope

This document covers:

- staff-only dry run purpose
- store role assignment
- simulated customer role
- owner/store manager role
- kitchen/KDS role
- counter/service role
- support escalation role
- Mini Kiosk rehearsal
- payment uncertainty rehearsal
- KDS handoff rehearsal
- manual fallback rehearsal
- incident evidence capture
- staff readiness decision
- no-implementation boundary

This document does not cover:

- final staff training manual
- final labor scheduling
- final real customer pilot
- final POS vendor training
- final KDS hardware setup
- final Mini Kiosk production UI
- final payroll or HR training
- final store opening checklist

---

## 3. Core Principle

Staff must experience the system before customers do.

The project must follow this rule:

> Before customer-facing pilot, store staff must rehearse normal flow, failure flow, uncertainty flow, manual fallback, support escalation, and evidence capture in a staff-only dry run.

Operational safety is not only software correctness.

It requires trained human response.

---

## 4. Why Staff-Only Dry Run Is Required

Staff-only dry run reduces risk by proving:

- staff understand the customer flow
- staff know what Mini Kiosk does and does not do
- staff understand payment uncertainty
- kitchen understands KDS handoff states
- staff know when not to prepare food
- support escalation is understood
- fallback path is usable
- customer wording is calm and accurate
- incident evidence can be captured
- store can pause the flow safely

A system that works technically may still fail operationally if staff are not ready.

---

## 5. Staff-Only Dry Run Stages

Recommended stages:

| Stage | Name | Purpose |
| ----- | ---- | ------- |
| 0 | Staff Briefing | explain scope, roles, and boundaries |
| 1 | Role Assignment | assign customer, counter, kitchen, owner, support roles |
| 2 | Happy Path Rehearsal | simulate normal flow |
| 3 | Payment Uncertainty Rehearsal | simulate ambiguous payment |
| 4 | KDS Handoff Rehearsal | simulate kitchen ticket flow |
| 5 | Mini Kiosk Timeout Rehearsal | simulate session timeout and abandonment |
| 6 | Provider Failure Rehearsal | simulate provider unavailable state |
| 7 | Manual Fallback Rehearsal | simulate non-digital fallback |
| 8 | Support Escalation Rehearsal | simulate support case creation |
| 9 | Incident Evidence Review | verify evidence capture |
| 10 | Staff Readiness Review | decide if customer pilot may proceed |

Stages may be repeated.

---

## 6. Dry Run Status Values

Recommended status values:

- `NOT_STARTED`
- `BRIEFING_READY`
- `ROLES_ASSIGNED`
- `RUNNING`
- `PASSED`
- `FAILED`
- `RETRY_REQUIRED`
- `BLOCKER_FOUND`
- `TRAINING_REQUIRED`
- `EVIDENCE_REVIEW_REQUIRED`
- `READY_FOR_LIMITED_CUSTOMER_PILOT`
- `NOT_READY_FOR_CUSTOMER_PILOT`

Dry run result must be recorded.

---

## 7. Staff Dry Run Record Fields

Each dry run should record:

- dry run id
- date
- store or simulated store
- participants
- roles assigned
- scenarios executed
- normal flow result
- failure flow result
- fallback result
- support escalation result
- evidence captured
- blockers found
- staff confusion points
- training required
- decision
- next action
- reviewer

This record should be preserved as pilot readiness evidence.

---

## 8. Dry Run ID Format

Recommended format:

    STAFF-DRYRUN-[YYYYMMDD]-[NUMBER]

Examples:

    STAFF-DRYRUN-20260612-001
    STAFF-DRYRUN-20260612-002

Final format may be normalized later.

---

## 9. Staff Roles

Recommended dry run roles:

| Role | Responsibility |
| ---- | -------------- |
| Simulated Customer | acts as customer using Mini Kiosk or order flow |
| Counter Staff | responds to customer and monitors order/payment state |
| Kitchen Staff | watches KDS state and prepares only when safe |
| Store Manager | decides pause/fallback/escalation |
| Support Operator | handles support case and evidence review |
| Provider Observer | watches provider event state if applicable |
| Payment Observer | watches payment uncertainty and recovery |
| Dry Run Recorder | records evidence and issues |

One person may play multiple roles in early rehearsal.

But role boundaries should still be explicit.

---

## 10. Staff Briefing Content

Staff briefing should explain:

- this is not a live customer pilot
- no real customer data should be used
- no real payment should be required unless explicitly controlled
- Mini Kiosk creates intent, not final truth
- payment uncertainty must not be hidden
- KDS ticket should not be prepared unless safe
- support can review but not silently mutate truth
- fallback is allowed when system is unsafe
- evidence must be recorded
- stop/pause is acceptable

The goal is learning, not pretending everything works.

---

## 11. Normal Flow Rehearsal

Normal flow should rehearse:

1. session starts
2. customer enters order intent
3. order intent is validated
4. payment is approved or simulated as approved
5. order acceptance condition is met
6. KDS ticket candidate is created
7. KDS ticket is accepted
8. kitchen starts preparation
9. order is completed
10. evidence is reviewed

Expected outcome:

    Staff understand normal handoff flow.

Normal flow alone is insufficient for readiness.

---

## 12. Payment Uncertainty Rehearsal

Payment uncertainty rehearsal should simulate:

- payment pending too long
- provider timeout
- duplicate callback suspicion
- approval mismatch
- invalid callback
- customer asks if payment succeeded
- staff sees uncertainty state
- KDS handoff is blocked or held
- support review is requested
- evidence is captured

Expected staff behavior:

- do not say payment is complete unless confirmed
- do not send order to kitchen if unsafe
- explain calmly that payment is being confirmed
- escalate if needed
- record evidence

Payment uncertainty must be treated as normal operational scenario.

---

## 13. KDS Handoff Rehearsal

KDS handoff rehearsal should simulate:

- valid KDS ticket candidate
- KDS ticket pending
- KDS ticket accepted
- KDS ticket held
- duplicate KDS event suspicion
- cancelled order after KDS candidate
- KDS unavailable
- degraded kitchen note path
- manual kitchen fallback

Expected staff behavior:

- kitchen starts only when ticket state is safe
- duplicate ticket is not prepared twice
- held ticket is not treated as accepted
- cancellation impact is reviewed
- evidence is captured

KDS rehearsal protects kitchen operations.

---

## 14. Mini Kiosk Timeout Rehearsal

Mini Kiosk timeout rehearsal should simulate:

- customer starts but does not finish
- session timeout warning
- session expired
- order intent abandoned
- customer returns and asks what happened
- staff checks state
- support handoff if needed

Expected staff behavior:

- do not assume abandoned intent is accepted order
- do not prepare abandoned order
- guide customer to restart or recover
- record session evidence if issue occurs

Timeout must not create ghost orders.

---

## 15. Provider Failure Rehearsal

Provider failure rehearsal should simulate:

- provider unavailable
- provider timeout
- invalid provider event
- duplicate provider event
- provider mapping failure
- provider event quarantine
- provider disable path

Expected staff behavior:

- recognize provider unavailable state
- avoid promising confirmed payment/order when uncertain
- use fallback path if approved
- escalate to support/provider observer
- preserve evidence

Provider failure must not become store confusion.

---

## 16. Manual Fallback Rehearsal

Manual fallback rehearsal should simulate:

- Mini Kiosk unavailable
- provider unavailable
- KDS bridge unavailable
- payment uncertainty
- kitchen note fallback
- staff-written manual note
- manager approval for fallback
- evidence capture after fallback
- later reconciliation

Expected staff behavior:

- fallback does not bypass security
- fallback is marked as fallback-originated
- manual note is clear
- customer explanation is calm
- recovery is logged

Manual fallback is a controlled safety path, not a hidden shortcut.

---

## 17. Support Escalation Rehearsal

Support escalation rehearsal should simulate:

- support case creation
- masked support view
- support evidence review
- support session expiration
- break-glass request if needed
- escalation to manager/HQ
- resolution proposal
- resolution confirmation with evidence

Expected staff behavior:

- call support when boundary is unclear
- avoid self-solving payment truth
- do not share sensitive data unnecessarily
- record support case reference
- wait for authorized resolution

Support exists to reduce panic, not to bypass controls.

---

## 18. Customer Communication Rehearsal

Staff should rehearse calm customer messages.

Examples:

    결제 확인이 잠시 지연되고 있습니다. 확인 후 바로 안내드리겠습니다.

    주문은 접수 중이며, 결제 확인이 완료되면 주방으로 전달됩니다.

    현재 시스템 확인이 필요해서 직원이 도와드리겠습니다.

    같은 주문이 중복 처리되지 않도록 확인 중입니다.

Customer communication must not overpromise.

Do not say:

    결제됐어요.

unless payment is confirmed.

Do not say:

    주방에 들어갔어요.

unless KDS handoff is accepted.

---

## 19. Stop And Pause Rehearsal

Staff must rehearse when to stop the flow.

Stop or pause conditions:

- payment uncertainty not resolvable
- duplicate payment suspected
- duplicate KDS ticket suspected
- provider failure persists
- Mini Kiosk creates confusing state
- support access issue occurs
- customer data exposure suspected
- device trust issue occurs
- rollback/disable required
- staff does not understand current state

Pause protects customers and store.

---

## 20. Evidence Capture Rehearsal

Staff should rehearse evidence capture for:

- payment uncertainty
- duplicate payment suspicion
- KDS duplicate suspicion
- provider failure
- Mini Kiosk timeout
- manual fallback
- support escalation
- customer complaint
- cancellation/refund review
- device issue

Evidence should include:

- scenario
- time
- role
- state shown
- action taken
- support case if any
- result
- note

Sensitive data must be masked.

---

## 21. Staff Confusion Log

Staff confusion must be recorded.

Confusion categories:

- state label unclear
- UI button unclear
- payment wording unclear
- KDS state unclear
- fallback path unclear
- support escalation unclear
- customer message unclear
- responsibility unclear
- evidence capture unclear
- stop/pause rule unclear

Confusion is not blame.

Confusion is design feedback.

---

## 22. Training Required Flag

Training required flag should be set when:

- staff cannot explain payment uncertainty
- staff cannot distinguish order intent and accepted order
- kitchen starts unsafe ticket
- staff ignores held KDS state
- support escalation is unclear
- fallback is used without evidence
- customer communication overpromises
- device revocation meaning is unclear
- staff cannot identify stop condition

Training must occur before customer pilot.

---

## 23. Dry Run Blocker Categories

Recommended blocker categories:

- `STAFF_PAYMENT_CONFUSION`
- `STAFF_ORDER_STATE_CONFUSION`
- `STAFF_KDS_STATE_CONFUSION`
- `STAFF_FALLBACK_CONFUSION`
- `STAFF_SUPPORT_ESCALATION_CONFUSION`
- `STAFF_CUSTOMER_MESSAGE_RISK`
- `STAFF_EVIDENCE_CAPTURE_GAP`
- `STAFF_STOP_RULE_GAP`
- `UI_STATE_LABEL_CONFUSION`
- `OPERATIONAL_ROLE_BOUNDARY_GAP`

Staff blockers may be as important as software blockers.

---

## 24. Dry Run Blocker Severity

Recommended severity values:

- `STAFF_BLOCKER_CRITICAL`
- `STAFF_BLOCKER_HIGH`
- `STAFF_BLOCKER_MEDIUM`
- `STAFF_BLOCKER_LOW`
- `STAFF_OBSERVATION`

Critical examples:

- staff treats uncertain payment as approved
- kitchen prepares duplicate KDS ticket
- staff bypasses support for payment truth
- staff exposes sensitive data
- staff cannot stop unsafe flow

Critical staff blockers must be resolved before customer pilot.

---

## 25. Staff Readiness Criteria

Staff may be considered ready when:

1. normal flow is understood
2. payment uncertainty is understood
3. order intent versus accepted order is understood
4. KDS ticket states are understood
5. manual fallback is understood
6. support escalation is understood
7. stop/pause conditions are understood
8. evidence capture is understood
9. customer communication is safe
10. no critical staff blocker remains

Staff readiness must be demonstrated, not assumed.

---

## 26. Staff Not Ready Indicators

Staff is not ready if:

- they rely only on memory
- they cannot explain uncertainty
- they rush food preparation under unsafe state
- they treat UI display as final authority without state check
- they ignore support boundary
- they skip evidence capture
- they overpromise to customer
- they cannot identify when to pause
- they cannot handle Mini Kiosk timeout
- they cannot handle provider failure

Customer pilot should not start under these conditions.

---

## 27. Rehearsal Repeat Rule

Staff-only dry run should repeat when:

- major UI changes occur
- state labels change
- provider behavior changes
- payment flow changes
- KDS handoff changes
- support workflow changes
- fallback path changes
- new staff are added
- critical blocker was found
- pilot was paused

One rehearsal is not permanent readiness.

---

## 28. Role-Specific Checklists

Role-specific checklists should be prepared later.

Recommended checklists:

- counter staff checklist
- kitchen/KDS checklist
- store manager checklist
- support operator checklist
- provider observer checklist
- payment observer checklist
- dry run recorder checklist

This document does not create final checklists.

It defines the need.

---

## 29. Staff Dry Run Evidence Packet

Recommended evidence packet fields:

- dry run id
- store
- date
- participants
- roles
- scenarios
- normal flow result
- failure flow result
- fallback result
- support result
- evidence captured
- blockers
- training required
- readiness decision
- reviewer
- next action

This packet supports pilot entry decision.

---

## 30. Staff Dry Run Decision Values

Recommended decision values:

- `REHEARSAL_NOT_STARTED`
- `REHEARSAL_REPEAT_REQUIRED`
- `TRAINING_REQUIRED`
- `STAFF_READY_FOR_INTERNAL_SIMULATION`
- `STAFF_READY_FOR_STAFF_ONLY_DRY_RUN`
- `STAFF_READY_FOR_LIMITED_CUSTOMER_PILOT`
- `STAFF_NOT_READY_FOR_CUSTOMER_PILOT`
- `PILOT_PAUSE_RECOMMENDED`

Decision must be evidence-based.

---

## 31. Limited Customer Pilot Entry Dependency

Limited customer pilot may begin only if:

- staff dry run passed
- critical staff blockers resolved
- payment uncertainty rehearsal passed
- KDS duplicate rehearsal passed
- support escalation rehearsal passed
- manual fallback rehearsal passed
- stop/pause rule understood
- evidence packet reviewed
- pilot scope restriction recorded if any

Staff readiness is a pilot gate.

---

## 32. Customer-Facing Script Boundary

Customer-facing scripts should be:

- calm
- short
- truthful
- uncertainty-aware
- non-technical
- not blaming provider
- not exposing internal architecture
- not promising unverified result

Examples may be refined later.

Scripts must follow runtime truth.

---

## 33. Manual Fallback Boundary

Manual fallback must follow:

- manager or authorized staff awareness
- reason recorded
- fallback-originated marker
- evidence capture
- later reconciliation
- no silent merge
- no payment truth assumption
- no KDS duplicate preparation
- no support bypass if support is required

Fallback is controlled degraded operation.

---

## 34. Training Material Candidate

Future training materials may include:

- one-page state guide
- payment uncertainty script
- KDS state guide
- Mini Kiosk timeout guide
- provider failure guide
- support escalation guide
- manual fallback guide
- stop/pause checklist
- evidence capture guide
- role-specific quick cards

This document does not create final training materials.

---

## 35. Dry Run Register Recommendation

Recommended future files:

    docs/_index/
      Staff_Only_Dry_Run_Register.md
      Staff_Role_Rehearsal_Register.md
      Staff_Training_Required_Register.md
      Staff_Dry_Run_Blocker_Register.md
      Staff_Readiness_Decision_Register.md

This document only recommends these files.

It does not create them.

---

## 36. Anti-Patterns

The following are prohibited:

- exposing real customers before staff rehearsal
- rehearsing only happy path
- ignoring staff confusion
- treating staff mistake as individual blame instead of design signal
- letting kitchen prepare held or duplicate ticket
- telling customer payment is approved when uncertain
- using manual fallback without evidence
- allowing support bypass for payment truth
- skipping stop/pause rehearsal
- skipping customer communication rehearsal
- treating one dry run as permanent readiness
- starting limited customer pilot with critical staff blockers

---

## 37. Non-Goals

This document does not define:

- final staff handbook
- final onboarding curriculum
- final HR training workflow
- final KDS hardware training
- final POS vendor training
- final customer script library
- final support SOP
- final pilot launch approval

Those belong to later operational readiness documents.

---

## 38. Readiness Check

This document is ready when the project can answer:

1. Why is staff-only dry run required?
2. What dry run stages exist?
3. What dry run status values exist?
4. What fields should staff dry run record include?
5. What roles are rehearsed?
6. What briefing content is required?
7. How is normal flow rehearsed?
8. How is payment uncertainty rehearsed?
9. How is KDS handoff rehearsed?
10. How is Mini Kiosk timeout rehearsed?
11. How is provider failure rehearsed?
12. How is manual fallback rehearsed?
13. How is support escalation rehearsed?
14. How is customer communication rehearsed?
15. When should staff stop or pause?
16. How is evidence captured?
17. How is staff confusion logged?
18. When is training required?
19. What dry run blocker categories exist?
20. What staff readiness criteria apply?
21. What are staff not-ready indicators?
22. When should rehearsal repeat?
23. What evidence packet is required?
24. What decision values exist?
25. What is limited customer pilot dependency?
26. What manual fallback boundary applies?
27. What anti-patterns are prohibited?

If these questions cannot be answered, staff-only dry run and operational fallback training planning is incomplete.

---

## 39. Conclusion

Customer pilot should not begin until staff have rehearsed the system.

The safe progression is:

    internal simulation
        -> staff briefing
        -> role rehearsal
        -> normal flow dry run
        -> failure flow dry run
        -> payment uncertainty rehearsal
        -> KDS handoff rehearsal
        -> manual fallback rehearsal
        -> support escalation rehearsal
        -> evidence review
        -> staff readiness decision

This document ensures that store staff understand not only how the system works, but also how it fails, when to stop, when to fallback, when to escalate, and how to protect customers through clear communication and evidence capture.