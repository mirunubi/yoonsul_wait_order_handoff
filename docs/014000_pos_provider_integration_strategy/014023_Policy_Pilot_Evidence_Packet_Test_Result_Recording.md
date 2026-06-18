# 014023_Policy_Pilot_Evidence_Packet_Test_Result_Recording

## 1. Purpose

This document defines the pilot evidence packet template, store test result recording rule, incident recording structure, operational value evidence, provider evidence, staff adoption evidence, customer flow evidence, SaaS value evidence, and Franchise OS readiness evidence policy for the Yoonsul Wait/Order Handoff project.

The previous document defined pilot store selection and scope control.

This document defines how pilot results must be recorded after a store test begins.

This document does not run pilot tests, create software, collect actual customer data, install devices, implement provider adapters, or launch SaaS.

It defines evidence recording policy only.

---

## 2. Scope

This document covers:

- pilot evidence packet structure
- store test result recording
- module test result recording
- order/payment/KDS evidence
- Provider Gateway evidence
- Mini Kiosk evidence
- staff adoption evidence
- owner feedback evidence
- customer flow evidence
- support burden evidence
- hardware evidence
- SaaS value evidence
- Franchise OS readiness evidence
- pilot retrospective
- no-implementation boundary

This document does not cover:

- final pilot test execution
- final data collection tool
- final analytics implementation
- final SaaS billing system
- final provider integration
- final KDS implementation
- final Mini Kiosk implementation
- final Franchise OS rollout

---

## 3. Core Principle

Pilot evidence must be structured enough to support future decisions.

The project must follow this rule:

> A pilot test that produces only impressions is not enough. Every pilot must produce structured evidence that can guide product scope, provider strategy, pricing, support design, and Franchise OS readiness.

Good evidence can justify scale.

Poor evidence creates false confidence.

---

## 4. Evidence Packet ID Format

Recommended evidence packet ID format:

    PILOT-EVIDENCE-[STORE-ID]-[YYYYMMDD]-[NUMBER]

Examples:

    PILOT-EVIDENCE-PSTORE-001-20260612-001
    PILOT-EVIDENCE-PSTORE-002-20260612-001

Alternative short format:

    PEVID-001

Final naming may be normalized later during PC import.

---

## 5. Evidence Packet Status Values

Recommended status values:

- `DRAFT`
- `IN_PROGRESS`
- `READY_FOR_REVIEW`
- `REVIEWED`
- `NEEDS_MORE_DATA`
- `BLOCKED`
- `SUPERSEDED`
- `ARCHIVED`

Evidence packet should not be marked reviewed until the test result, incident notes, support burden, and decision summary are complete.

---

## 6. Evidence Packet Header

Each evidence packet should begin with:

    Evidence Packet ID:
    Pilot Store ID:
    Store Name:
    Store Type:
    Location Area:
    Pilot Stage:
    Provider Stack:
    Device Stack:
    Modules Tested:
    Pilot Start Date:
    Pilot End Date:
    Evidence Period:
    Reviewer:
    Evidence Status:
    Sensitive Data Review:
    Decision Impact:

The header lets later reviewers understand what was tested and under what conditions.

---

## 7. Pilot Scope Summary

Evidence packet must restate pilot scope.

Required fields:

- included modules
- excluded modules
- provider stack
- device stack
- staff group involved
- customer flow tested
- payment flow tested
- KDS/kitchen flow tested
- support scope
- data permission
- rollback path
- pause criteria
- completion criteria

Pilot results must be interpreted only within agreed scope.

---

## 8. Module Test Summary

Each tested module should have a result summary.

Recommended module result table:

| Module | Tested | Result | Evidence Quality | Notes |
| ------ | ------ | ------ | ---------------- | ----- |
| Store OS | Yes/No | Pass/Partial/Fail | High/Medium/Low | Notes |
| Provider Gateway | Yes/No | Pass/Partial/Fail | High/Medium/Low | Notes |
| Toss Adapter | Yes/No | Pass/Partial/Fail | High/Medium/Low | Notes |
| OKPOS Compatibility | Yes/No | Pass/Partial/Fail | High/Medium/Low | Notes |
| PAYCO Channel | Yes/No | Pass/Partial/Fail | High/Medium/Low | Notes |
| Mini Kiosk | Yes/No | Pass/Partial/Fail | High/Medium/Low | Notes |
| KDS | Yes/No | Pass/Partial/Fail | High/Medium/Low | Notes |
| Payment Recovery | Yes/No | Pass/Partial/Fail | High/Medium/Low | Notes |
| Owner Dashboard | Yes/No | Pass/Partial/Fail | High/Medium/Low | Notes |
| Support Flow | Yes/No | Pass/Partial/Fail | High/Medium/Low | Notes |

---

## 9. Result Values

Recommended result values:

- `PASS`
- `PARTIAL_PASS`
- `FAIL`
- `NOT_TESTED`
- `BLOCKED`
- `INCONCLUSIVE`
- `REQUIRES_RETEST`
- `DEFERRED`

Result must include reason.

Do not mark pass only because no incident was noticed.

---

## 10. Evidence Quality Values

Recommended evidence quality values:

- `HIGH`
- `MEDIUM`
- `LOW`
- `ANECDOTAL`
- `MISSING`
- `CONFLICTING`

Examples:

- HIGH: structured logs plus staff/owner confirmation
- MEDIUM: structured observation with partial logs
- LOW: informal observation only
- ANECDOTAL: single comment or impression
- MISSING: no usable evidence
- CONFLICTING: evidence sources disagree

Evidence quality affects decision weight.

---

## 11. Order Evidence Section

Order evidence should include:

- total orders observed
- order source breakdown
- kiosk orders
- counter orders
- table orders
- mobile/preorder orders where applicable
- order intent creation result
- order acceptance result
- order failure count
- duplicate order count
- cancellation count
- manual correction count
- order status visibility
- staff confusion cases
- customer confusion cases

Order evidence should answer:

    Did the order flow become clearer, faster, safer, or more recoverable?

---

## 12. Payment Evidence Section

Payment evidence should include:

- payment attempts
- approved payments
- failed payments
- uncertain payments
- duplicate payment attempts
- customer cancellation after payment
- refund requests
- payment provider delay
- payment verification source
- payment lookup result
- manual payment intervention
- settlement issue
- support case count
- sensitive data masking confirmation

Payment evidence should answer:

    Did the system improve payment certainty and recovery?

---

## 13. POS / Provider Evidence Section

Provider evidence should include:

- provider used
- provider architecture family
- provider mapping success
- merchant/store mapping result
- provider event received
- provider event validation result
- provider idempotency result
- provider timeout result
- provider failure case
- provider support interaction
- provider data access limitation
- provider evidence quality
- provider blocker created

Provider evidence should answer:

    Can this provider support future SaaS integration safely?

---

## 14. KDS / Kitchen Evidence Section

KDS or kitchen evidence should include:

- tickets created
- tickets accepted
- ticket delay cases
- retry/remake cases
- kitchen confusion cases
- duplicate ticket cases
- cancelled order after kitchen start
- external POS kitchen output
- kitchen printer issue
- KDS screen issue
- staff adoption
- peak-time behavior
- kitchen feedback

KDS evidence should answer:

    Did kitchen execution become more visible and controllable?

---

## 15. Mini Kiosk Evidence Section

Mini Kiosk evidence should include:

- customer sessions
- completed sessions
- abandoned sessions
- cart creation count
- payment start count
- payment completion count
- timeout count
- duplicate tap count
- staff assistance count
- language issue
- menu readability issue
- customer confusion point
- device usability issue
- table/waiting/pickup context issue
- customer feedback

Mini Kiosk evidence should answer:

    Did customer self-order reduce friction without hiding recovery risk?

---

## 16. Staff Adoption Evidence Section

Staff adoption evidence should include:

- staff trained
- staff active users
- training time
- staff errors
- manual workaround count
- staff resistance
- staff positive feedback
- staff negative feedback
- peak-time usage
- manager intervention
- support requests by staff
- procedure compliance

Staff evidence should answer:

    Can normal staff operate this without founder-level intervention?

---

## 17. Owner / Manager Feedback Section

Owner or manager feedback should include:

- perceived value
- daily usage intention
- willingness to pay
- most useful feature
- least useful feature
- missing feature
- confusing feature
- support expectation
- pricing sensitivity
- provider concern
- hardware concern
- franchise readiness perception

Owner evidence should answer:

    Would this store pay for the system after pilot?

---

## 18. Customer Flow Evidence Section

Customer flow evidence should include:

- customer entry path
- waiting path
- order path
- payment path
- pickup/table path
- confusion point
- abandonment reason
- staff assistance reason
- complaint
- positive comment
- repeated use
- accessibility issue
- multilingual issue

Customer evidence should answer:

    Did customer experience improve without increasing operational risk?

---

## 19. Support Burden Evidence Section

Support burden evidence should include:

- total support incidents
- incident categories
- who resolved each incident
- time to resolve
- recurrence
- vendor/dealer involvement
- Yoonsul involvement
- training issue
- documentation gap
- hardware issue
- provider issue
- staff issue
- customer issue

Support evidence should answer:

    Is this support burden sustainable under a SaaS price?

---

## 20. Hardware Evidence Section

Hardware evidence should include:

- device list
- device uptime
- failures
- reboot events
- printer issue
- scanner issue
- payment terminal issue
- network issue
- power issue
- mounting/space issue
- installation difficulty
- replacement difficulty
- warranty/support contact
- durability observation

Hardware evidence should answer:

    Is the device stack repeatable for future rollout?

---

## 21. SaaS Value Evidence Section

SaaS value evidence should include:

- feature store would pay for
- feature store would not pay for
- strongest pain solved
- weak or unused module
- support value
- dashboard value
- recovery value
- provider integration value
- Mini Kiosk value
- KDS value
- suggested package tier
- pricing feedback
- pilot-to-paid conversion likelihood

SaaS evidence should answer:

    What exactly is the recurring value?

---

## 22. Franchise OS Readiness Evidence Section

Franchise OS readiness evidence should include:

- data usable by HQ
- store comparison potential
- SOP/training linkage
- menu governance potential
- incident governance potential
- owner dashboard relevance
- cross-store provider comparison potential
- KDS performance data
- staff workflow data
- support case data
- compliance/audit evidence
- multi-store reporting readiness

Franchise OS evidence should answer:

    Can this store runtime eventually feed HQ governance?

---

## 23. Incident Log Section

Each incident should be recorded.

Recommended fields:

    Incident ID:
    Date/Time:
    Module:
    Severity:
    Description:
    Customer Impact:
    Staff Impact:
    Provider Involved:
    Hardware Involved:
    Root Cause Known:
    Recovery Action:
    Time To Resolve:
    Evidence Link:
    Blocker Created:
    Follow-Up Required:

Incident severity values:

- `CRITICAL`
- `HIGH`
- `MEDIUM`
- `LOW`
- `INFO`

---

## 24. Blocker Linkage

Evidence packet must link blockers.

Blocker categories:

- provider blocker
- payment blocker
- KDS blocker
- Mini Kiosk blocker
- staff adoption blocker
- support blocker
- hardware blocker
- data access blocker
- pricing blocker
- Franchise OS readiness blocker

If evidence reveals unresolved risk, create or update blocker.

---

## 25. Retrospective Section

Each evidence packet should include retrospective.

Recommended questions:

1. What worked?
2. What failed?
3. What surprised us?
4. What was harder than expected?
5. What was easier than expected?
6. What should be changed before next pilot?
7. What should be removed from scope?
8. What should be added later?
9. What should remain deferred?
10. What does this teach about SaaS pricing?
11. What does this teach about Franchise OS readiness?

Retrospective turns pilot into learning.

---

## 26. Decision Impact Section

Evidence packet must state decision impact.

Possible decision impacts:

- continue pilot
- expand to next store
- pause pilot
- change provider
- change hardware
- change module scope
- change pricing hypothesis
- create new blocker
- create new document
- defer feature
- reject provider
- reject store type
- prepare paid pilot
- prepare Franchise OS linkage later

Evidence without decision impact is incomplete.

---

## 27. Sensitive Data Rule

Evidence packet must not contain:

- raw card number
- payment secret
- provider secret
- webhook secret
- raw CI/DI
- full customer phone number
- unnecessary customer identity
- staff private data
- vendor confidential document copied beyond allowed scope
- unrestricted local POS logs
- service role key
- WebView cookie

Sensitive details should be masked or referenced by controlled evidence id.

---

## 28. Evidence Attachment Rule

Allowed attachments:

- masked screenshots
- masked logs
- incident summaries
- support messages where permitted
- vendor confirmations
- quote references
- configuration notes
- photos of hardware layout where privacy-safe
- staff feedback summary
- owner feedback summary
- anonymized customer flow notes

Attachment must be labeled.

Attachment must not expose secrets or unnecessary personal data.

---

## 29. Pilot Evidence Review

Pilot evidence should be reviewed by:

- product/runtime owner
- provider integration owner where applicable
- operations owner
- support owner
- security/data reviewer where sensitive data exists
- business/pricing reviewer where SaaS value is evaluated

Review should produce:

- accepted evidence
- missing evidence
- blockers
- next action
- decision impact

---

## 30. Evidence Storage Recommendation

Recommended future folder:

    docs/
      05000_provider_integration_and_kiosk_reuse/
        pilot_rollout/
          evidence_packets/
            PILOT-EVIDENCE-PSTORE-001-YYYYMMDD-001.md
          incident_logs/
          pilot_retrospectives/
          blocker_links/

This is a future PC-side organization recommendation only.

Do not create folders during documentation drafting phase.

---

## 31. Evidence Packet Template

Recommended Markdown template:

    # Pilot Evidence Packet

    ## Header
    Evidence Packet ID:
    Pilot Store ID:
    Store Name:
    Store Type:
    Provider Stack:
    Device Stack:
    Modules Tested:
    Evidence Period:
    Reviewer:
    Status:

    ## Scope Summary
    Included Scope:
    Excluded Scope:
    Data Permission:
    Pause Criteria:
    Completion Criteria:

    ## Module Test Summary
    Module:
    Result:
    Evidence Quality:
    Notes:

    ## Order Evidence
    Summary:
    Issues:
    Metrics:
    Evidence Quality:

    ## Payment Evidence
    Summary:
    Issues:
    Metrics:
    Evidence Quality:

    ## Provider Evidence
    Summary:
    Issues:
    Metrics:
    Evidence Quality:

    ## KDS / Kitchen Evidence
    Summary:
    Issues:
    Metrics:
    Evidence Quality:

    ## Mini Kiosk Evidence
    Summary:
    Issues:
    Metrics:
    Evidence Quality:

    ## Staff Adoption Evidence
    Summary:
    Issues:
    Metrics:
    Evidence Quality:

    ## Owner Feedback
    Summary:
    Willingness To Pay:
    Pricing Feedback:
    Missing Value:

    ## Customer Flow Evidence
    Summary:
    Issues:
    Metrics:

    ## Support Burden Evidence
    Summary:
    Incident Count:
    Average Resolution:
    Support Owner:

    ## Hardware Evidence
    Summary:
    Issues:
    Repeatability:

    ## SaaS Value Evidence
    Summary:
    Strongest Value:
    Weakest Value:
    Suggested Package:

    ## Franchise OS Readiness
    Summary:
    HQ Data Potential:
    Not Ready Areas:

    ## Incident Log
    Incident ID:
    Severity:
    Description:
    Resolution:

    ## Blockers
    Blocker ID:
    Description:
    Owner:

    ## Retrospective
    Worked:
    Failed:
    Surprised:
    Change Before Next Pilot:

    ## Decision Impact
    Decision:
    Next Action:
    Reviewer:

---

## 32. Anti-Patterns

The following are prohibited:

- recording only positive pilot feedback
- hiding failed incidents
- treating anecdotal comment as strong evidence
- collecting raw sensitive data unnecessarily
- failing to link blockers
- failing to record support burden
- failing to record staff resistance
- failing to record owner willingness to pay
- treating technical success as SaaS value proof
- treating one pilot as franchise readiness
- skipping retrospective
- storing evidence without decision impact

---

## 33. Non-Goals

This document does not define:

- final pilot analytics tool
- final database schema
- final evidence UI
- final customer survey
- final staff survey
- final SaaS pricing
- final Franchise OS rollout
- final provider implementation

Those belong to later controlled implementation and rollout execution.

---

## 34. Readiness Check

This document is ready when the project can answer:

1. What is pilot evidence packet?
2. What ID format is used?
3. What status values exist?
4. What header fields are required?
5. What scope summary is required?
6. How is module test summarized?
7. What result values exist?
8. What evidence quality values exist?
9. What order evidence is required?
10. What payment evidence is required?
11. What provider evidence is required?
12. What KDS evidence is required?
13. What Mini Kiosk evidence is required?
14. What staff adoption evidence is required?
15. What owner feedback is required?
16. What customer flow evidence is required?
17. What support burden evidence is required?
18. What hardware evidence is required?
19. What SaaS value evidence is required?
20. What Franchise OS readiness evidence is required?
21. What incident log is required?
22. How are blockers linked?
23. What retrospective is required?
24. What decision impact is required?
25. What sensitive data is prohibited?
26. What anti-patterns are prohibited?

If these questions cannot be answered, pilot evidence packet and store test result recording is incomplete.

---

## 35. Conclusion

Pilot evidence must be structured, comparable, and decision-ready.

The project must preserve the following rules:

- pilot evidence is not just screenshots or impressions
- each pilot must record scope, results, incidents, blockers, support burden, and decision impact
- payment, order, KDS, provider, Mini Kiosk, staff, owner, customer, hardware, SaaS, and Franchise OS evidence must be separated
- sensitive data must be minimized
- failed evidence must be preserved
- technical success is not automatically SaaS value
- one pilot is not franchise readiness
- retrospective is required
- decision impact is required

This document prepares pilot evidence recording for disciplined SaaS and Franchise OS expansion.