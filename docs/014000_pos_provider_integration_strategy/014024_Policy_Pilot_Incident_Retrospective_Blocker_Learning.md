# 014024_Policy_Pilot_Incident_Retrospective_Blocker_Learning

## 1. Purpose

This document defines the pilot incident retrospective, blocker conversion, next-store learning, rollout correction, provider issue classification, support improvement, pricing feedback conversion, and Franchise OS readiness update policy for the Yoonsul Wait/Order Handoff project.

The previous document defined the pilot evidence packet and store test result recording policy.

This document defines what must happen after evidence is collected.

A pilot is useful only when its incidents, failures, support burden, staff feedback, owner feedback, provider limitations, and SaaS value signals are converted into structured decisions.

This document does not perform pilot retrospectives, modify software, update provider adapters, change prices, or launch the next pilot.

It defines retrospective and learning conversion policy only.

---

## 2. Scope

This document covers:

- pilot retrospective structure
- incident review
- blocker conversion
- next-store checklist update
- provider issue classification
- staff adoption learning
- support burden learning
- hardware learning
- SaaS pricing learning
- Mini Kiosk learning
- KDS learning
- Franchise OS readiness learning
- next pilot decision
- no-implementation boundary

This document does not cover:

- final implementation fix
- final product roadmap execution
- final provider adapter change
- final store rollout
- final pricing decision
- final SaaS launch
- final Franchise OS implementation
- final hardware partner agreement

---

## 3. Core Principle

Pilot learning must become controlled project input.

The project must follow this rule:

> A pilot incident is not only a problem. It is a controlled input that must become a blocker, requirement, deferred item, provider risk, support rule, pricing insight, or next-store checklist correction.

If the project does not convert pilot learning, every new store will repeat the same mistakes.

---

## 4. Retrospective Timing

Pilot retrospective should occur:

- after first-store internal test period
- after each friendly store pilot
- after each major incident
- after pilot pause
- after pilot completion
- before expanding to next store
- before changing package pricing
- before adding new provider
- before preparing Franchise OS linkage

Do not wait until many pilots are complete.

Learning must be captured while context is fresh.

---

## 5. Retrospective Participants

Recommended participants:

- product/runtime owner
- store operation owner
- support owner
- provider integration reviewer
- payment/recovery reviewer
- KDS/kitchen reviewer
- Mini Kiosk reviewer
- security/data reviewer where needed
- business/pricing reviewer
- store owner or manager where appropriate
- staff representative where appropriate

Not every retrospective needs every role.

Critical incidents require broader review.

---

## 6. Retrospective Input Sources

Retrospective should use:

- pilot evidence packet
- incident log
- support messages
- provider/dealer messages
- staff feedback
- owner feedback
- customer flow observation
- payment recovery cases
- KDS/kitchen notes
- Mini Kiosk session notes
- hardware failure notes
- pricing feedback
- blocked feature requests
- scope creep requests
- rollback notes

Do not rely only on memory.

---

## 7. Retrospective Output Types

Each retrospective should produce one or more outputs:

| Output Type | Meaning |
| ----------- | ------- |
| Blocker | Must be resolved or accepted before next phase |
| Requirement | New required behavior for future design |
| Deferred Item | Valid idea but not now |
| Rejected Item | Not aligned or unsafe |
| Checklist Update | Next-store preparation change |
| Support Rule | New support handling rule |
| Training Update | Staff/owner training correction |
| Provider Risk | Provider-specific issue |
| Pricing Insight | SaaS package or fee learning |
| Hardware Note | Device or installation learning |
| Franchise OS Signal | Future HQ/governance relevance |
| Document Gap | Missing policy or template |
| Test Gap | Missing test case |
| Rollback Update | Recovery or disable change |

Every significant retrospective finding must become an output.

---

## 8. Incident Review Classification

Incidents should be classified by source.

Recommended incident source values:

- `PROVIDER_EVENT`
- `PAYMENT_STATE`
- `ORDER_STATE`
- `KDS_STATE`
- `MINI_KIOSK_UI`
- `STAFF_OPERATION`
- `OWNER_EXPECTATION`
- `CUSTOMER_FLOW`
- `HARDWARE_DEVICE`
- `NETWORK`
- `SUPPORT_PROCESS`
- `DATA_ACCESS`
- `SECURITY_PRIVACY`
- `PRICING_SCOPE`
- `FRANCHISE_GOVERNANCE`
- `UNKNOWN`

Incident classification helps identify repeated patterns.

---

## 9. Incident Severity Review

Incident severity should be reviewed after the pilot.

Severity values:

- `CRITICAL`
- `HIGH`
- `MEDIUM`
- `LOW`
- `INFO`

Severity may change after review.

Example:

- a small UI bug may become high severity if it causes payment uncertainty
- a provider delay may be low severity if recovery is clear
- a staff workaround may be high severity if it bypasses audit
- a kitchen print duplicate may be critical if it causes repeated wrong production

Severity should be based on operational impact, not emotional reaction.

---

## 10. Blocker Conversion Rule

An incident must become a blocker when it prevents safe next-step rollout.

Convert to blocker if:

- payment truth is unclear
- refund/cancel responsibility is unclear
- duplicate order risk remains unresolved
- duplicate payment risk remains unresolved
- KDS/kitchen output is unsafe
- provider mapping is unreliable
- support owner is unclear
- staff cannot operate safely
- owner expectation conflicts with product scope
- hardware failure cannot be mitigated
- sensitive data exposure risk exists
- rollback path is missing
- pilot pricing creates future obligation
- Franchise OS data is not reliable enough

Blockers must be recorded with owner and next action.

---

## 11. Blocker ID Format

Recommended blocker ID format:

    PILOT-BLOCK-[STORE-ID]-[NUMBER]

Examples:

    PILOT-BLOCK-PSTORE-001-001
    PILOT-BLOCK-PSTORE-002-003

Cross-provider blocker format:

    PROVIDER-BLOCK-[PROVIDER]-[NUMBER]

Examples:

    PROVIDER-BLOCK-TOSS-001
    PROVIDER-BLOCK-OKPOS-002

Final naming may be normalized later during PC import.

---

## 12. Blocker Fields

Each blocker should include:

- blocker id
- source pilot
- source incident
- category
- severity
- description
- affected module
- affected provider
- affected store
- operational impact
- customer impact
- staff impact
- data/security impact
- current workaround
- required resolution
- owner
- status
- due timing
- next decision
- linked documents
- linked test cases

Blocker without owner is not actionable.

---

## 13. Blocker Status Values

Recommended blocker status values:

- `OPEN`
- `UNDER_REVIEW`
- `WAITING_PROVIDER`
- `WAITING_STORE`
- `WAITING_SUPPORT`
- `WAITING_LEGAL_REVIEW`
- `WAITING_SECURITY_REVIEW`
- `DEFERRED`
- `ACCEPTED_RISK`
- `RESOLVED`
- `REJECTED`
- `SUPERSEDED`

Accepted risk must be explicit.

Do not silently ignore blockers.

---

## 14. Requirement Conversion Rule

Pilot learning becomes a requirement when:

- repeated store behavior shows necessary function
- staff cannot operate without it
- owner value depends on it
- support burden is too high without it
- provider integration requires it
- Mini Kiosk recovery depends on it
- KDS handoff safety depends on it
- Franchise OS data consistency depends on it

Requirement must be separated from immediate implementation.

Requirement does not automatically mean build now.

---

## 15. Deferred Item Rule

A finding should be deferred when:

- useful but not Phase 1
- belongs to Phase 2 provider expansion
- belongs to Phase 3 hardware ecosystem
- requires Franchise OS maturity
- requires multi-store data
- requires legal review
- requires external provider contract
- requires AI/analytics later
- is too expensive for current stage

Deferred item must include reason.

---

## 16. Rejected Item Rule

A finding should be rejected when:

- it violates payment truth
- it weakens audit
- it bypasses provider verification
- it creates unsafe shortcut
- it locks into one vendor unnecessarily
- it conflicts with SaaS model
- it harms staff workflow
- it collects unnecessary sensitive data
- it creates hidden support burden
- it is only a one-store custom demand

Rejected item should still be documented.

---

## 17. Next-Store Checklist Update

Every retrospective should ask:

    What must we check before the next store?

Possible checklist updates:

- provider stack discovery
- payment refund boundary
- KDS kitchen path
- staff training
- owner expectation
- data permission
- hardware layout
- network stability
- support contact
- dealer responsibility
- rollback path
- pilot scope exclusions
- Mini Kiosk placement
- dashboard expectation
- pricing explanation

If a problem can be prevented next time, update checklist.

---

## 18. Provider Learning Conversion

Provider-related learning should update:

- provider register
- provider blocker register
- provider evidence packet
- adapter test matrix
- quarantine scenario catalog
- provider status
- phase gate status
- support runbook
- rollback rule

Provider learning examples:

- Toss webhook delay observed
- OKPOS local daemon timeout unclear
- PAYCO callback not final approval
- dealer support slow
- unknown POS data export unavailable
- small kiosk vendor refuses API explanation

Provider learning must not remain only in pilot notes.

---

## 19. Staff Learning Conversion

Staff-related learning should update:

- training material
- staff quick guide
- screen copy
- support script
- shift procedure
- peak-time procedure
- recovery procedure
- manager escalation rule
- role/permission plan

Examples:

- staff bypassed KDS during peak
- staff did not understand payment uncertainty
- staff used manual note instead of recovery state
- staff could not explain kiosk timeout to customer

Staff learning is core SaaS readiness evidence.

---

## 20. Owner Learning Conversion

Owner feedback should update:

- dashboard design
- pricing hypothesis
- SaaS package language
- support package scope
- onboarding explanation
- billing responsibility
- value proposition
- sales message
- Franchise OS roadmap

Examples:

- owner values payment recovery more than analytics
- owner does not understand Provider Gateway
- owner wants simple monthly bundle
- owner worries about hardware replacement
- owner wants staff training included

Owner value determines SaaS viability.

---

## 21. Customer Flow Learning Conversion

Customer flow learning should update:

- Mini Kiosk UI
- menu organization
- payment guidance
- timeout message
- staff assistance trigger
- waiting/table/pickup context
- multilingual priority
- accessibility need
- cancellation explanation
- receipt/status message

Examples:

- customers abandon at payment method selection
- customers confuse table order and pickup
- customers tap twice during payment delay
- customers need staff help for options

Customer flow learning affects Mini Kiosk product value.

---

## 22. Payment Recovery Learning Conversion

Payment recovery learning should update:

- payment state model
- provider lookup rule
- duplicate payment prevention
- refund/cancel workflow
- support escalation
- evidence packet
- customer message
- staff script
- reconciliation rule

Payment learning must be treated as high priority.

Payment uncertainty can harm trust quickly.

---

## 23. KDS Learning Conversion

KDS learning should update:

- kitchen ticket policy
- duplicate ticket prevention
- delay/remake/retry state
- cancellation after kitchen start rule
- external POS kitchen output boundary
- staff kitchen procedure
- KDS screen layout
- degraded kitchen note procedure

KDS learning must be based on kitchen reality, not only product design.

---

## 24. Hardware Learning Conversion

Hardware learning should update:

- hardware profile
- device placement guide
- printer requirement
- network requirement
- power requirement
- mounting rule
- replacement rule
- warranty rule
- hardware partner checklist
- certified hardware candidate list

Hardware problems can destroy software value if ignored.

---

## 25. Support Learning Conversion

Support learning should update:

- support category list
- response guide
- support owner matrix
- vendor/dealer escalation list
- after-hours policy
- incident severity rule
- documentation gap
- training gap
- pricing support tier
- support cost estimate

Support burden affects SaaS margin directly.

---

## 26. Pricing Learning Conversion

Pricing feedback should update:

- package tier hypothesis
- module value ranking
- support package value
- setup fee expectation
- hardware fee sensitivity
- provider gateway willingness-to-pay
- Mini Kiosk willingness-to-pay
- KDS willingness-to-pay
- Franchise OS fee readiness
- pilot-to-paid conversion rule

Pricing learning must be evidence-based.

Do not set final price from one store.

---

## 27. Franchise OS Learning Conversion

Franchise OS signals should update:

- HQ dashboard requirements
- multi-store comparison plan
- SOP distribution needs
- training governance
- incident governance
- menu governance
- owner/store role model
- provider performance comparison
- audit/evidence model
- billing responsibility

Franchise OS learning begins at store runtime level.

But Franchise OS linkage should wait until store runtime is stable.

---

## 28. Document Gap Conversion

If pilot reveals missing policy, create document candidate.

Examples:

- payment customer message policy
- KDS duplicate ticket recovery policy
- staff kiosk assistance SOP
- provider dealer escalation policy
- hardware replacement policy
- pilot pricing conversion policy
- owner dashboard expectation policy
- SaaS cancellation data retention policy

Document gap should be recorded before writing new docs.

---

## 29. Test Gap Conversion

If pilot reveals missing test case, update test catalog.

Examples:

- duplicate payment after kiosk freeze
- POS accepts order but kitchen output fails
- payment succeeds but provider webhook delayed
- staff manual recovery creates duplicate
- owner dashboard shows stale data
- provider gateway disabled during active order
- Mini Kiosk abandoned cart after payment start
- KDS ticket cancelled after prep started

Test gap must be linked to future verification.

---

## 30. Rollout Decision Values

After retrospective, choose rollout decision.

Recommended values:

- `CONTINUE_SAME_SCOPE`
- `CONTINUE_WITH_SCOPE_REDUCTION`
- `CONTINUE_WITH_SCOPE_EXPANSION`
- `PAUSE_UNTIL_BLOCKER_RESOLVED`
- `RETEST_REQUIRED`
- `MOVE_TO_NEXT_STORE`
- `ADD_PROVIDER_REVIEW`
- `CHANGE_HARDWARE`
- `CHANGE_TRAINING`
- `CHANGE_SUPPORT_MODEL`
- `CHANGE_PRICING_HYPOTHESIS`
- `DEFER_FRANCHISE_LINKAGE`
- `PREPARE_PAID_PILOT`
- `STOP_PILOT`

Decision must be recorded.

---

## 31. Next Store Entry Gate

Before moving to the next pilot store, confirm:

1. previous evidence packet reviewed
2. critical incidents classified
3. blockers created
4. high severity blockers resolved or accepted
5. next-store checklist updated
6. support burden understood
7. provider risks updated
8. staff training updated
9. rollback path updated
10. scope exclusions clarified
11. pricing feedback recorded
12. decision impact recorded

Do not start next store by ignoring previous learning.

---

## 32. Retrospective Template

Recommended Markdown template:

    # Pilot Retrospective

    ## Header
    Retrospective ID:
    Pilot Store ID:
    Evidence Packet ID:
    Date:
    Reviewer:
    Participants:
    Status:

    ## Summary
    What was tested:
    What worked:
    What failed:
    What surprised us:

    ## Incidents Reviewed
    Incident ID:
    Severity:
    Source:
    Decision:

    ## Blockers Created
    Blocker ID:
    Category:
    Owner:
    Status:

    ## Requirements Created
    Requirement:
    Reason:
    Phase:

    ## Deferred Items
    Item:
    Reason:
    Target Phase:

    ## Rejected Items
    Item:
    Reason:

    ## Checklist Updates
    Next-store checklist change:

    ## Provider Learning
    Provider:
    Learning:
    Register update needed:

    ## Staff Learning
    Learning:
    Training update needed:

    ## Owner / Pricing Learning
    Learning:
    Pricing hypothesis impact:

    ## Customer Flow Learning
    Learning:
    Mini Kiosk impact:

    ## Payment / KDS Learning
    Learning:
    Runtime impact:

    ## Hardware / Support Learning
    Learning:
    Support impact:

    ## Franchise OS Signal
    Signal:
    Readiness impact:

    ## Decision
    Rollout decision:
    Next action:
    Owner:

---

## 33. Anti-Patterns

The following are prohibited:

- finishing pilot without retrospective
- recording only positive learning
- hiding failed incidents
- failing to convert incidents into blockers
- starting next store before critical blockers are reviewed
- treating staff resistance as minor inconvenience
- treating payment uncertainty as acceptable noise
- treating provider/dealer delay as unrelated
- accepting scope creep without phase review
- changing pricing based only on emotion
- ignoring support cost
- treating one pilot as Franchise OS readiness
- deleting failed evidence
- letting same incident repeat across stores

---

## 34. Non-Goals

This document does not define:

- final implementation changes
- final product roadmap
- final pricing
- final support SLA
- final provider contract
- final hardware partner decision
- final Franchise OS linkage
- final rollout schedule

Those belong to later controlled planning and implementation authorization.

---

## 35. Readiness Check

This document is ready when the project can answer:

1. When does retrospective occur?
2. Who should participate?
3. What input sources are used?
4. What output types can retrospective produce?
5. How are incidents classified?
6. How is severity reviewed?
7. When does incident become blocker?
8. What blocker fields are required?
9. What blocker status values exist?
10. When does learning become requirement?
11. When is item deferred?
12. When is item rejected?
13. How is next-store checklist updated?
14. How is provider learning converted?
15. How is staff learning converted?
16. How is owner learning converted?
17. How is customer flow learning converted?
18. How is payment recovery learning converted?
19. How is KDS learning converted?
20. How is hardware learning converted?
21. How is support learning converted?
22. How is pricing learning converted?
23. How is Franchise OS learning converted?
24. How are document gaps converted?
25. How are test gaps converted?
26. What rollout decisions exist?
27. What is next store entry gate?
28. What anti-patterns are prohibited?

If these questions cannot be answered, pilot retrospective and blocker conversion planning is incomplete.

---

## 36. Conclusion

Pilot evidence must become structured learning.

The correct flow is:

    Pilot Incident
        -> Evidence Packet
        -> Retrospective
        -> Blocker / Requirement / Deferred Item / Rejected Item
        -> Checklist Update
        -> Provider Register Update
        -> Support Rule Update
        -> Pricing Hypothesis Update
        -> Next Store Entry Gate

The project must not repeat the same mistake across stores.

This document ensures that every pilot improves the next pilot, strengthens SaaS readiness, protects payment/KDS/runtime truth, and prepares future Franchise OS linkage only after store runtime is stable.