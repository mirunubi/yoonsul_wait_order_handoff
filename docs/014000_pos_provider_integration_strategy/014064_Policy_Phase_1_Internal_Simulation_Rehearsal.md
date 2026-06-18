# 014064_Policy_Phase_1_Internal_Simulation_Rehearsal

## 1. Purpose

This document defines the Phase 1 internal simulation, dry run, pre-pilot rehearsal, controlled scenario execution, simulated store flow, simulated provider failure, simulated payment uncertainty, simulated KDS handoff, support recovery rehearsal, and pilot entry preparation policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined Phase 1 pilot readiness required test register and blocker control.

This document defines the rehearsal layer before any real store pilot begins.

This document does not run simulations, create test scripts, configure environments, execute provider calls, connect payment systems, or approve pilot launch.

It defines internal simulation and dry run policy only.

---

## 2. Scope

This document covers:

- internal simulation purpose
- dry run types
- pre-pilot rehearsal
- simulated customer session
- simulated Mini Kiosk flow
- simulated provider event flow
- simulated payment uncertainty
- simulated order acceptance
- simulated KDS handoff
- simulated support recovery
- simulated device trust issue
- simulated export control
- simulated rollback
- evidence capture during simulation
- simulation blocker handling
- no-implementation boundary

This document does not cover:

- final automated simulation engine
- final UI prototype
- final provider sandbox
- final payment certification
- final KDS hardware
- final production monitoring
- final pilot store onboarding
- final customer-facing launch

---

## 3. Core Principle

A real pilot should be preceded by controlled internal rehearsal.

The project must follow this rule:

> Before controlled store pilot, Phase 1 runtime must be rehearsed internally through realistic success, failure, uncertainty, recovery, and rollback scenarios with evidence capture.

A pilot should not be the first time the system experiences failure.

---

## 4. Why Internal Simulation Is Required

Internal simulation reduces risk by proving:

- basic user flow works
- runtime states move correctly
- provider events are validated
- payment uncertainty is visible
- KDS handoff is guarded
- duplicate events are blocked
- support recovery is scoped
- audit evidence is created
- rollback and disable path works
- UI labels do not lie
- blockers are found before real store exposure

Internal rehearsal turns unknown risk into known risk.

---

## 5. Simulation Stages

Recommended simulation stages:

| Stage | Name | Purpose |
| ----- | ---- | ------- |
| 0 | Paper Flow Review | review flow without system execution |
| 1 | Tabletop Scenario | walk through roles and states |
| 2 | Mock Data Dry Run | run with mock data only |
| 3 | Provider Event Simulation | simulate external provider events |
| 4 | Payment Uncertainty Simulation | rehearse ambiguous payment states |
| 5 | KDS Handoff Simulation | test kitchen handoff boundaries |
| 6 | Support Recovery Simulation | rehearse support case workflow |
| 7 | Rollback Disable Simulation | confirm safe stop path |
| 8 | Full Internal Rehearsal | end-to-end internal run |
| 9 | Pilot Entry Review | decide whether real pilot can start |

Stages may be repeated.

---

## 6. Simulation Status Values

Recommended simulation status values:

- `NOT_STARTED`
- `SCENARIO_DEFINED`
- `READY_TO_RUN`
- `RUNNING`
- `PASSED`
- `FAILED`
- `BLOCKED`
- `RETRY_REQUIRED`
- `EVIDENCE_REVIEW_REQUIRED`
- `WAIVED`
- `DEFERRED`
- `COMPLETED`

Simulation result must be recorded.

---

## 7. Simulation Scenario Record Fields

Each simulation scenario should record:

- scenario id
- scenario name
- stage
- runtime families involved
- data flows involved
- roles involved
- provider assumptions
- initial states
- trigger events
- expected transitions
- expected UI display
- expected evidence
- failure condition
- support action
- rollback action
- result
- blocker id if failed
- evidence packet id
- reviewer
- notes

Scenario records make rehearsal repeatable.

---

## 8. Scenario ID Format

Recommended scenario id format:

    SIM-P1-[DOMAIN]-[NUMBER]

Examples:

    SIM-P1-PAYMENT-001
    SIM-P1-KDS-001
    SIM-P1-MINIKIOSK-001
    SIM-P1-SUPPORT-001
    SIM-P1-PROVIDER-001
    SIM-P1-ROLLBACK-001

Final format may be normalized later.

---

## 9. Stage 0 Paper Flow Review

Paper Flow Review should verify:

- data flow is understood
- runtime owner is known
- authority boundary is clear
- required states are named
- required events are named
- expected evidence is identified
- failure path is known
- UI uncertainty display is defined
- support recovery path is defined
- rollback path is defined

Paper review should happen before system execution.

---

## 10. Stage 1 Tabletop Scenario

Tabletop scenario should involve role-based walkthrough.

Possible roles:

- customer
- store staff
- owner
- support operator
- provider integration owner
- payment runtime owner
- KDS operator
- security reviewer
- pilot reviewer

The goal is to confirm that each role knows what they can and cannot do.

---

## 11. Stage 2 Mock Data Dry Run

Mock data dry run should use non-real data.

It should verify:

- tenant/store context exists
- session can be created
- order intent can be captured
- payment state can be simulated
- KDS candidate can be simulated
- support case can be simulated
- audit evidence can be simulated
- no real customer data is used
- no real payment is processed

Mock data protects early rehearsal.

---

## 12. Stage 3 Provider Event Simulation

Provider event simulation should cover:

- valid provider event
- invalid signature
- duplicate event
- replay event
- missing store mapping
- stale event
- provider timeout
- provider unavailable state
- provider event quarantine
- provider disable path

Provider simulation must prove external signals are not trusted blindly.

---

## 13. Stage 4 Payment Uncertainty Simulation

Payment uncertainty simulation should cover:

- payment pending
- payment approved
- payment failed
- provider timeout
- duplicate callback
- invalid callback
- approval mismatch
- uncertain payment display
- support review path
- KDS handoff blocked under uncertainty

Payment uncertainty must be rehearsed as normal risk, not rare exception.

---

## 14. Stage 5 KDS Handoff Simulation

KDS handoff simulation should cover:

- safe KDS ticket candidate
- ticket pending
- ticket accepted
- duplicate handoff event
- stale bridge event
- payment uncertainty blocks handoff
- cancelled order blocks handoff
- KDS unavailable state
- degraded kitchen note path
- KDS evidence packet

KDS rehearsal must prove no duplicate kitchen execution.

---

## 15. Stage 6 Support Recovery Simulation

Support recovery simulation should cover:

- support case created
- support case assigned
- support masked view
- support session timeout
- break-glass request
- break-glass evidence
- payment uncertainty review
- provider failure review
- KDS duplicate suspicion review
- resolution proposed
- resolution confirmed with evidence

Support rehearsal must prove support cannot silently mutate runtime truth.

---

## 16. Stage 7 Rollback Disable Simulation

Rollback and disable simulation should cover:

- provider integration disabled
- Mini Kiosk disabled
- KDS Bridge disabled
- support access revoked
- device trust revoked
- export disabled
- degraded mode entered
- degraded mode exited
- rollback evidence packet
- user-facing safe message

A pilot without a stop path is unsafe.

---

## 17. Stage 8 Full Internal Rehearsal

Full internal rehearsal should combine:

- customer session
- Mini Kiosk order intent
- provider event simulation
- payment approval or uncertainty
- order acceptance or hold
- KDS handoff or block
- support recovery if needed
- audit/evidence capture
- owner/store review
- pilot evidence packet

At least one full success path and one full failure path should be rehearsed.

---

## 18. Stage 9 Pilot Entry Review

Pilot entry review should evaluate:

- simulation results
- failed scenarios
- blockers
- waivers
- evidence packets
- unresolved provider assumptions
- payment uncertainty handling
- KDS safety
- support masking
- rollback readiness
- UI honesty
- pilot scope restriction
- decision to start, pause, or reject pilot

Pilot entry must be evidence-based.

---

## 19. Minimum Required Simulation Set

Minimum required simulations before pilot:

| Domain | Required Scenario |
| ------ | ----------------- |
| Session | create and expire session |
| Mini Kiosk | capture order intent |
| Provider | invalid signature rejected |
| Provider | duplicate event blocked |
| Payment | payment approved after validation |
| Payment | payment uncertainty displayed |
| Order | uncertain payment blocks acceptance |
| KDS | duplicate ticket blocked |
| KDS | unsafe handoff blocked |
| Support | masked support view enforced |
| Support | break-glass produces evidence |
| Device | revoked device blocked |
| Export | export without approval blocked |
| Rollback | provider path disabled |
| Pilot | evidence packet generated |

Minimum set may expand after review.

---

## 20. Simulation Evidence Packet Types

Recommended simulation evidence packet types:

- `SIMULATION_RUN_RECORD`
- `SIMULATION_PROVIDER_EVIDENCE`
- `SIMULATION_PAYMENT_EVIDENCE`
- `SIMULATION_KDS_EVIDENCE`
- `SIMULATION_SUPPORT_EVIDENCE`
- `SIMULATION_DEVICE_EVIDENCE`
- `SIMULATION_EXPORT_EVIDENCE`
- `SIMULATION_ROLLBACK_EVIDENCE`
- `SIMULATION_PILOT_EVIDENCE`

Simulation evidence should be separate from real pilot evidence.

---

## 21. Simulation Evidence Minimum Fields

Simulation evidence should include:

- scenario id
- run id
- run date
- environment
- mock data indicator
- runtime families involved
- initial states
- triggered events
- final states
- expected result
- actual result
- evidence references
- blocker references
- waiver references
- reviewer
- notes

Evidence should avoid real personal or payment data.

---

## 22. Simulation Run ID Format

Recommended format:

    SIMRUN-[YYYYMMDD]-[NUMBER]

Examples:

    SIMRUN-20260612-001
    SIMRUN-20260612-002

Run ID links scenario, evidence, blocker, and decision record.

---

## 23. Simulation Environment Rule

Simulation should run in non-production environment.

Rules:

- no production customer data
- no production payment credential
- no real CI/DI
- no real card data
- no production provider secret
- no live provider mutation unless separately authorized
- no real KDS kitchen execution unless explicitly controlled
- no customer-facing exposure

Simulation protects production.

---

## 24. Mock Data Rule

Mock data must be clearly marked.

Mock data should include:

- mock tenant
- mock store
- mock customer session
- mock order
- mock payment event
- mock provider event
- mock KDS ticket
- mock support case
- mock device
- mock export request

Mock data must not be mistaken for real pilot data.

---

## 25. Role Rehearsal Rule

Simulation should rehearse human roles, not only system states.

Each role should know:

- what they see
- what they can do
- what they cannot do
- when to escalate
- when to stop
- what evidence to check
- what message to give customer/store
- what not to promise

Operational readiness includes people.

---

## 26. UI Rehearsal Rule

UI rehearsal should confirm:

- states display correctly
- uncertainty is not hidden
- forbidden actions are not shown or are disabled
- support path is visible where needed
- error messages are safe
- provider failure state is understandable
- KDS state is not misleading
- payment state is not falsely confirmed
- customer-facing wording is calm

UI must be honest before pilot.

---

## 27. Support Script Rehearsal Rule

Support scripts should be rehearsed for:

- payment uncertainty
- duplicate payment suspicion
- missing KDS ticket
- duplicate KDS ticket suspicion
- provider unavailable
- Mini Kiosk timeout
- order cancellation issue
- refund review
- device lost/revoked
- export request denial

Support script must not overpromise.

---

## 28. Store Staff Rehearsal Rule

Store staff rehearsal should cover:

- what to do if Mini Kiosk fails
- what to do if payment uncertain
- what to do if KDS ticket missing
- what to do if KDS duplicate suspected
- when to use manual fallback
- when to call support
- what to tell customer
- how to record evidence
- how to pause the flow

Staff must know fallback before pilot.

---

## 29. Failure Scenario Rule

Every simulation batch should include failure scenarios.

Failure scenarios should include:

- provider timeout
- invalid provider event
- duplicate provider event
- payment uncertainty
- order validation failure
- KDS unavailable
- support access denied
- device revoked
- export blocked
- rollback required

A rehearsal without failure is incomplete.

---

## 30. Blocker Handling During Simulation

If simulation fails:

1. record failed scenario
2. create blocker
3. link evidence
4. classify severity
5. identify affected runtime
6. identify affected data flow
7. decide fix, waiver, defer, or reject
8. rerun scenario after fix
9. update pilot readiness

Simulation failure is useful.

Hidden failure is dangerous.

---

## 31. Simulation Waiver Rule

Simulation waiver may be allowed only when:

- scenario is not hard blocker
- pilot scope restriction exists
- compensating control exists
- reviewer accepts risk
- waiver is documented
- revisit trigger exists

Waiver must not hide payment, tenant, support masking, or KDS duplication hard risks.

---

## 32. Rehearsal Completion Criteria

Internal rehearsal may be considered complete when:

- minimum required simulations are run
- hard blocker scenarios pass
- critical evidence packets are produced
- failure paths are rehearsed
- support recovery is rehearsed
- rollback is rehearsed
- unresolved issues are classified
- waivers are documented
- pilot entry review is ready

Completion does not mean production readiness.

---

## 33. Pre Pilot Go No-Go Decision

Pre-pilot decision values:

- `NO_GO`
- `GO_INTERNAL_SIMULATION_AGAIN`
- `GO_STAFF_ONLY_DRY_RUN`
- `GO_LIMITED_STORE_PILOT`
- `GO_WITH_SCOPE_RESTRICTION`
- `GO_FULL_PHASE1_PILOT`
- `PAUSE_AND_FIX`

Decision must match simulation evidence.

---

## 34. Dry Run Report

A dry run report should include:

- report id
- run date
- scenario list
- passed scenarios
- failed scenarios
- blockers
- waivers
- evidence packets
- support findings
- staff findings
- UI findings
- provider findings
- payment findings
- KDS findings
- rollback findings
- recommendation
- next action

This may be stored later in an evidence folder.

---

## 35. Dry Run Report ID Format

Recommended format:

    DRYRUN-REPORT-[YYYYMMDD]-[NUMBER]

Examples:

    DRYRUN-REPORT-20260612-001

Final format may be normalized later.

---

## 36. Simulation Register Recommendation

Recommended future files:

    docs/_index/
      Phase_1_Simulation_Scenario_Register.md
      Phase_1_Simulation_Run_Register.md
      Phase_1_Dry_Run_Report_Register.md
      Phase_1_Pre_Pilot_Go_No_Go_Register.md

This document only recommends these files.

It does not create them.

---

## 37. Anti-Patterns

The following are prohibited:

- using real customer data in early simulation
- using production secrets in rehearsal
- running pilot without internal dry run
- rehearsing only happy path
- hiding simulation failure
- treating UI screenshots as full proof
- skipping support rehearsal
- skipping store staff rehearsal
- skipping rollback rehearsal
- skipping payment uncertainty rehearsal
- skipping duplicate KDS ticket rehearsal
- allowing provider signal as truth without simulation
- treating pre-pilot rehearsal as production launch

---

## 38. Non-Goals

This document does not define:

- final simulation engine
- final mock data generator
- final automated test scripts
- final provider sandbox setup
- final KDS hardware setup
- final Flutter implementation
- final real store pilot schedule
- final production monitoring

Those belong to later implementation and pilot planning.

---

## 39. Readiness Check

This document is ready when the project can answer:

1. Why is internal simulation required?
2. What simulation stages exist?
3. What simulation status values exist?
4. What fields should scenario record include?
5. What scenario ID format is recommended?
6. What is paper flow review?
7. What is tabletop scenario?
8. What is mock data dry run?
9. What provider events are simulated?
10. What payment uncertainty scenarios are simulated?
11. What KDS handoff scenarios are simulated?
12. What support recovery scenarios are simulated?
13. What rollback scenarios are simulated?
14. What is full internal rehearsal?
15. What is pilot entry review?
16. What minimum simulation set is required?
17. What simulation evidence packet types exist?
18. What simulation environment rule applies?
19. What mock data rule applies?
20. What role rehearsal rule applies?
21. What UI rehearsal rule applies?
22. What support script rehearsal rule applies?
23. What store staff rehearsal rule applies?
24. What failure scenario rule applies?
25. How are simulation blockers handled?
26. What rehearsal completion criteria apply?
27. What pre-pilot decision values exist?
28. What should dry run report include?
29. What anti-patterns are prohibited?

If these questions cannot be answered, Phase 1 internal simulation and pre-pilot rehearsal planning is incomplete.

---

## 40. Conclusion

A controlled store pilot should not be the first complete operational test.

The safe progression is:

    paper flow review
        -> tabletop scenario
        -> mock data dry run
        -> provider simulation
        -> payment uncertainty simulation
        -> KDS handoff simulation
        -> support recovery rehearsal
        -> rollback disable rehearsal
        -> full internal rehearsal
        -> pilot entry review

This document ensures that Phase 1 pilot begins only after internal rehearsal proves that success, failure, uncertainty, recovery, and rollback can be handled with evidence.

Simulation is not delay.

Simulation is protection.