# 024120_Policy_Pilot_Store_Register_Test_Partner_Selection_And_Scope_Control

Legacy path: $old.

## 1. Purpose

This document defines the pilot store register, test partner selection criteria, pilot eligibility rule, pilot scope control, store risk classification, provider stack classification, and pilot acceptance/rejection policy for the Yoonsul Wait/Order Handoff project.

The previous document defined the pilot rollout and evidence collection policy.

This document defines how pilot stores should be selected, registered, classified, scoped, and controlled before the project expands toward SaaS and Franchise OS linkage.

This document does not recruit pilot stores, sign pilot agreements, install devices, implement provider integration, or launch SaaS.

It defines pilot partner selection and scope control policy only.

---

## 2. Scope

This document covers:

- pilot store register
- friendly test store selection
- pilot store eligibility
- provider stack classification
- store risk classification
- pilot scope definition
- pilot acceptance rule
- pilot rejection rule
- pilot pause rule
- pilot scope creep control
- test partner evidence requirement
- no-implementation boundary

This document does not cover:

- final pilot contract
- final store list
- final pilot pricing
- final equipment installation
- final POS integration
- final Mini Kiosk implementation
- final KDS implementation
- final payment implementation
- final Franchise OS rollout

---

## 3. Core Principle

A pilot store is not just a customer.

The project must follow this rule:

> A pilot store must be selected because it can generate useful, controlled, comparable evidence without forcing the project to abandon phase discipline.

Bad pilot stores create noise.

Good pilot stores create evidence.

---

## 4. Pilot Store Register Purpose

The pilot store register exists to track:

- candidate store identity
- store type
- location
- owner relationship
- provider stack
- POS provider
- payment provider
- kiosk/table order vendor
- KDS/kitchen output path
- staff readiness
- owner readiness
- test scope
- data collection permission
- support burden
- risk level
- pilot status
- evidence status
- next action

The register prevents informal pilot promises from becoming uncontrolled implementation obligations.

---

## 5. Pilot Store Register ID Format

Recommended pilot store register ID format:

    PILOT-STORE-[YYYYMMDD]-[NUMBER]

Examples:

    PILOT-STORE-20260612-001
    PILOT-STORE-20260612-002

Alternative short format:

    PSTORE-001

Final naming may be normalized later during PC import.

---

## 6. Pilot Store Register Fields

Each pilot store register entry should include:

| Field | Description |
| ----- | ----------- |
| Pilot Store ID | Internal pilot register id |
| Store Name | Candidate store name |
| Location | General area, not sensitive address in broad docs |
| Store Type | cafe, kimbap, restaurant, retail, etc. |
| Owner Relationship | direct, friendly, external, unknown |
| Current POS | Toss, OKPOS, Smartro, KICC, etc. |
| Payment Stack | Toss, VAN, PAYCO, card terminal, unknown |
| Kiosk Vendor | none, Toss, small vendor, table order, unknown |
| Kitchen Output | printer, KDS, manual, unknown |
| Store Volume | low, medium, high, unknown |
| Staff Readiness | high, medium, low |
| Owner Readiness | high, medium, low |
| Data Permission | approved, pending, denied |
| Pilot Scope | modules to test |
| Excluded Scope | modules not included |
| Provider Complexity | low, medium, high |
| Support Risk | low, medium, high |
| Evidence Value | high, medium, low |
| Pilot Status | candidate, accepted, paused, rejected, completed |
| Blockers | linked blocker ids |
| Next Action | contact, quote, inspect, defer, reject |
| Review Owner | responsible reviewer |
| Last Reviewed At | review date |

---

## 7. Pilot Status Values

Recommended pilot status values:

- `CANDIDATE`
- `INITIAL_CONTACT`
- `NEEDS_STORE_VISIT`
- `NEEDS_PROVIDER_INFO`
- `NEEDS_OWNER_CONFIRMATION`
- `NEEDS_DATA_PERMISSION`
- `ACCEPTED_FOR_DISCOVERY`
- `ACCEPTED_FOR_PILOT`
- `PILOT_ACTIVE`
- `PILOT_PAUSED`
- `PILOT_COMPLETED`
- `PILOT_FAILED`
- `PILOT_REJECTED`
- `PILOT_DEFERRED`
- `SUPERSEDED`

Status must be evidence-based.

---

## 8. Store Relationship Classification

Pilot store relationship should be classified.

| Relationship | Meaning |
| ------------ | ------- |
| Direct Store | Yoonsul-owned or controlled store |
| Friendly Store | owner relationship is positive and cooperative |
| Nearby Store | physically close enough for support |
| Strategic Store | provider or market value is high |
| External Store | no prior relationship |
| High-Demand Store | operationally attractive but risky |
| Unknown Store | insufficient information |

Preferred early pilot order:

1. Direct Store
2. Friendly Nearby Store
3. Strategic Nearby Store
4. External Store

Avoid starting with high-risk external stores.

---

## 9. Store Type Classification

Store type affects pilot value.

Recommended classifications:

- kimbap / light meal
- cafe / brunch
- Korean restaurant
- casual dining
- bar / alcohol service
- delivery-heavy store
- pickup-heavy store
- retail store
- specialty store
- franchise candidate
- multi-store operator
- unknown

Yoonsul should prioritize store types close to its own operational model first.

---

## 10. Provider Stack Classification

Provider stack should be classified.

Recommended values:

- `TOSS_FIRST`
- `OKPOS_INSTALLED`
- `OKPOS_WITH_SMALL_KIOSK`
- `TOSS_WITH_OKPOS`
- `PAYCO_PAYMENT_CHANNEL`
- `SMARTRO_INSTALLED`
- `KICC_INSTALLED`
- `NICE_PAYMENT`
- `SMALL_KIOSK_ONLY`
- `MANUAL_POS`
- `UNKNOWN_PROVIDER_STACK`

Phase 1 preferred stacks:

- Toss-first
- OKPOS-installed
- Toss with OKPOS if boundaries are clear
- PAYCO only as payment channel test

Phase 2 and Phase 3 stacks should be deferred unless authorized.

---

## 11. Pilot Eligibility Criteria

A pilot candidate is eligible when:

1. Owner is cooperative.
2. Store is reachable for support.
3. Pilot scope can be limited.
4. Provider stack is known or discoverable.
5. Store volume is manageable.
6. Data collection is allowed.
7. Staff can be trained.
8. Failure impact is acceptable.
9. Support ownership can be defined.
10. Rollback path exists.
11. Evidence value is meaningful.
12. Pilot does not force unsupported provider implementation.
13. Pilot does not require urgent custom features.
14. Pilot aligns with Phase 1 or authorized Phase 2 scope.

Eligibility is not based on sales opportunity alone.

---

## 12. Preferred Early Pilot Profile

Preferred early pilot store:

- nearby
- friendly owner
- moderate order volume
- simple menu
- limited staff count
- clear POS/payment stack
- willing to test
- willing to provide feedback
- no complex franchise politics
- no heavy custom requirement
- no critical SLA requirement
- rollback possible
- staff open to training

This type of store maximizes learning while limiting risk.

---

## 13. Stores To Avoid Early

Avoid early pilot stores that:

- demand full custom integration
- use unknown or unsupported POS
- have high peak complexity
- have hostile staff
- have unclear owner authority
- have no data permission
- cannot tolerate failure
- need immediate production SLA
- require many devices
- require multi-branch rollout immediately
- expect free permanent service
- require unsupported payment provider
- require hardware certification immediately
- refuse written scope

These stores may be revisited later.

---

## 14. Evidence Value Scoring

Score evidence value from 0 to 5.

| Score | Meaning |
| ----- | ------- |
| 5 | Highly relevant evidence for Phase 1 and SaaS |
| 4 | Useful evidence with manageable complexity |
| 3 | Some evidence value but limited |
| 2 | Low evidence value or too narrow |
| 1 | Mostly operational noise |
| 0 | No useful evidence |

Evidence value should consider:

- provider relevance
- store type relevance
- customer flow relevance
- KDS relevance
- payment recovery relevance
- Mini Kiosk relevance
- owner dashboard relevance
- support learning value

---

## 15. Support Risk Scoring

Score support risk from 0 to 5.

| Score | Meaning |
| ----- | ------- |
| 5 | Very high support burden |
| 4 | High support burden |
| 3 | Moderate support burden |
| 2 | Manageable support burden |
| 1 | Low support burden |
| 0 | Minimal support burden |

Early pilots should prefer support risk 0 to 2.

A high evidence value store with high support risk may be deferred.

---

## 16. Provider Complexity Scoring

Score provider complexity from 0 to 5.

| Score | Meaning |
| ----- | ------- |
| 5 | Unsupported provider / custom integration required |
| 4 | Phase 2/3 provider required |
| 3 | OKPOS with unclear OKDC or kiosk vendor |
| 2 | OKPOS known or Toss+OKPOS with clear boundaries |
| 1 | Toss-first stack |
| 0 | manual/controlled internal test |

Early pilots should avoid provider complexity 4 or 5.

---

## 17. Pilot Acceptance Rule

A candidate may be accepted for pilot when:

- eligibility criteria are met
- evidence value is medium or high
- support risk is manageable
- provider complexity is within authorized phase
- owner agrees to written scope
- data permission is clear
- rollback path exists
- excluded scope is written
- pilot end condition is defined

Acceptance must be recorded.

---

## 18. Pilot Rejection Rule

A candidate should be rejected or deferred when:

- owner authority is unclear
- data permission is denied
- provider stack is unsupported
- support burden is too high
- store demands production SLA
- store requires Phase 2/3 implementation during Phase 1
- custom feature demand is excessive
- rollback is impossible
- vendor/dealer support is unclear
- payment/refund responsibility is unclear
- KDS path is unsafe
- staff adoption risk is extreme

Rejected pilot should still be recorded with reason.

---

## 19. Pilot Pause Rule

An active pilot must be paused when:

- payment truth becomes unclear
- duplicate orders occur repeatedly
- duplicate payments occur
- KDS/kitchen output becomes unsafe
- staff bypass system entirely
- vendor/dealer refuses support
- hardware failure blocks operation
- owner revokes data permission
- support burden exceeds scope
- pilot scope expands without approval
- customer harm risk appears
- legal/compliance risk appears

Pause is not failure.

Pause protects evidence and operations.

---

## 20. Pilot Scope Definition

Each pilot must define included and excluded scope.

Included scope examples:

- order handoff observation
- payment recovery observation
- KDS visibility test
- Mini Kiosk customer flow test
- provider data access test
- owner dashboard feedback
- staff workflow test

Excluded scope examples:

- automated refund
- full POS replacement
- production-grade SLA
- multi-store rollout
- custom provider integration
- full Franchise OS
- universal POS support
- hardware certification
- permanent pricing commitment

Excluded scope prevents misunderstanding.

---

## 21. Scope Creep Control

Scope creep occurs when pilot expands into:

- custom feature requests
- additional provider integration
- additional store rollout
- new hardware support
- unsupported payment flow
- full analytics dashboard
- franchise contract discussion
- permanent discount promise
- unplanned support SLA

Scope creep must be handled by:

1. recording request
2. classifying phase
3. checking blockers
4. approving or deferring
5. updating pilot scope if approved
6. rejecting if unsafe

Do not expand pilot by verbal agreement.

---

## 22. Data Permission Requirement

Pilot data permission must cover:

- order data
- payment status data
- error/recovery data
- staff workflow feedback
- customer flow observations
- device/hardware incidents
- provider incident records
- owner dashboard feedback
- anonymized learning use
- evidence packet creation

Sensitive data must be minimized.

No raw payment secrets, CI/DI, or unnecessary personal data should be collected.

---

## 23. Staff Readiness Review

Staff readiness should be reviewed before pilot.

Check:

- number of staff
- shift complexity
- training availability
- technology comfort
- resistance risk
- peak-time pressure
- manager support
- ability to report issues
- willingness to follow pilot procedure

A cooperative owner with unready staff may still fail.

---

## 24. Owner Readiness Review

Owner readiness should be reviewed.

Check:

- decision authority
- willingness to test
- willingness to provide feedback
- understanding of pilot scope
- acceptance of temporary limitations
- patience with controlled testing
- agreement on data collection
- agreement on rollback
- interest in SaaS value
- pricing sensitivity

Owner readiness is critical.

---

## 25. Provider Stack Discovery Checklist

Before accepting a pilot, discover:

- current POS provider
- payment provider
- VAN/PG provider
- kiosk vendor
- table order vendor
- kitchen printer/KDS setup
- dealer/support contact
- contract constraints
- API/export possibility
- device ownership
- support responsibility
- known failure history

Unknown provider stack increases risk.

---

## 26. Pilot Store Evidence Packet

Each accepted pilot should create evidence packet.

Recommended fields:

    Pilot Store ID:
    Store Type:
    Relationship:
    Provider Stack:
    Pilot Scope:
    Excluded Scope:
    Data Permission:
    Staff Readiness:
    Owner Readiness:
    Evidence Value:
    Support Risk:
    Provider Complexity:
    Accepted Reason:
    Blockers:
    Rollback Path:
    Start Criteria:
    Pause Criteria:
    Completion Criteria:
    Reviewer:

---

## 27. Completion Criteria

Pilot may be completed when:

- pilot duration ends
- agreed scope is tested
- evidence packet is complete
- incidents are reviewed
- owner feedback is recorded
- staff feedback is recorded
- support burden is measured
- provider stack issues are documented
- SaaS value hypothesis is updated
- next decision is recorded

Completion must lead to one of:

- convert to paid pilot
- continue pilot
- pause
- reject future rollout
- move to next store
- create new document/blocker

---

## 28. Pilot Outcome Values

Recommended outcome values:

- `SUCCESS_CONTINUE`
- `SUCCESS_CONVERT_TO_PAID`
- `PARTIAL_SUCCESS_NEEDS_SCOPE_CHANGE`
- `PAUSED_DUE_TO_RISK`
- `FAILED_PROVIDER_LIMITATION`
- `FAILED_STAFF_ADOPTION`
- `FAILED_OWNER_VALUE`
- `FAILED_SUPPORT_BURDEN`
- `FAILED_HARDWARE_RELIABILITY`
- `DEFERRED_FOR_PHASE2`
- `DEFERRED_FOR_PHASE3`

Outcome must be recorded.

---

## 29. Pilot Register Storage Recommendation

Recommended future folder:

    docs/
      docs/005000_customer_handoff_and_implementation_readiness/
        pilot_rollout/
          024120_Policy_Pilot_Store_Register_Test_Partner_Selection_And_Scope_Control.md
          Pilot_Store_Register.md
          Pilot_Store_Evidence_Packets/
          Pilot_Store_Blockers.md
          Pilot_Store_Outcomes.md

This is a future PC-side organization recommendation only.

Do not create folders during documentation drafting phase.

---

## 30. Anti-Patterns

The following are prohibited:

- accepting pilot because owner is enthusiastic but scope is unclear
- accepting pilot because store is attractive but provider stack is unsupported
- accepting pilot with no data permission
- accepting pilot that requires Phase 2 provider during Phase 1
- promising production SLA in pilot
- allowing custom feature requests to define product roadmap
- continuing pilot after payment truth becomes unsafe
- ignoring staff resistance
- ignoring support burden
- hiding failed pilot outcome
- treating one friendly store as market proof
- letting pilot become free permanent service
- expanding to multiple stores before one pilot is stable

---

## 31. Non-Goals

This document does not define:

- final pilot store list
- final pilot contract
- final pilot pricing
- final implementation plan
- final installation schedule
- final provider integration
- final SaaS launch decision
- final franchise rollout decision

Those belong to later rollout execution.

---

## 32. Readiness Check

This document is ready when the project can answer:

1. What is the pilot store register?
2. What fields must a pilot store entry contain?
3. What pilot status values exist?
4. How are store relationships classified?
5. What store types are prioritized?
6. How is provider stack classified?
7. What makes a pilot eligible?
8. What is preferred early pilot profile?
9. What stores should be avoided early?
10. How is evidence value scored?
11. How is support risk scored?
12. How is provider complexity scored?
13. When is pilot accepted?
14. When is pilot rejected?
15. When is pilot paused?
16. What must pilot scope define?
17. How is scope creep controlled?
18. What data permission is required?
19. How are staff and owner readiness reviewed?
20. What provider stack discovery is required?
21. What evidence packet is created?
22. What completion criteria apply?
23. What outcome values exist?
24. What anti-patterns are prohibited?

If these questions cannot be answered, pilot store selection and scope control planning is incomplete.

---

## 33. Conclusion

Pilot stores must be selected for evidence value and controlled scope, not only for sales opportunity.

The project should start with:

- direct store
- friendly nearby store
- manageable provider stack
- cooperative owner
- trainable staff
- clear data permission
- clear rollback
- Phase 1-aligned scope

The project must avoid:

- uncontrolled custom pilots
- unsupported provider demands
- unclear payment/KDS boundaries
- excessive support burden
- premature franchise-scale promises
- pilot scope creep

This document prepares the pilot store register and test partner selection process for disciplined evidence-based SaaS expansion.
