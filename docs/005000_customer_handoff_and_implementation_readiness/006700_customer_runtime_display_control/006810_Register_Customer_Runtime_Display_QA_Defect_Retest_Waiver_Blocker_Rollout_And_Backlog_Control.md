# 006810_Register_Customer_Runtime_Display_QA_Defect_Retest_Waiver_Blocker_Rollout_And_Backlog_Control.md

## 1. Purpose

This register defines the Customer Runtime display QA defect, retest, waiver, blocker, rollout restriction, and backlog control record.

The purpose is to ensure that display QA findings do not disappear after a QA run, pilot test, retest, or conditional rollout decision.

Customer-facing display defects may affect customer trust, payment truth, refund/cancel clarity, privacy exposure, support handling, coupon/benefit expectation, waiting fairness, or rollout safety.

This register tracks display QA defects until they are resolved, retested, waived, restricted, blocked, transferred, or routed to backlog with owner and evidence.

## 2. Scope

This register covers:

- Display QA defects
- Retest requirements
- Failed retests
- Message template defects
- Translation defects
- Status code defects
- Action permission defects
- Payment-sensitive display defects
- Refund/cancel display defects
- Privacy-sensitive display defects
- Support surface defects
- Error and recovery defects
- Evidence capture defects
- Waivers and conditional passes
- Rollout blockers and restrictions
- Backlog routing

This register does not replace the engineering defect tracker, customer runtime risk register, support case system, privacy incident register, or release approval record.

It provides the display-specific control layer that links QA findings to rollout readiness.

## 3. Baseline Dependency

This register depends on:

`006800_Template_Customer_Runtime_Display_QA_Defect_Retest_Acceptance_Rollout_Handoff_And_Evidence_Record.md`

It receives records from:

`006790_Runbook_Customer_Runtime_Display_QA_Execution_Defect_Retest_Acceptance_And_Rollout_Handoff.md`

`006780_Checklist_Customer_Runtime_Display_Surface_Status_Action_Message_Evidence_And_QA_Acceptance.md`

It routes high-risk unresolved items to:

`06670_Register_Customer_Runtime_Risk_Waiver_Blocker_Backlog_Carry_Forward_And_Rollout_Control.md`

## 4. Core Principle

A display QA defect is not closed because the UI was changed.

It is closed only when:

1. The defect has an owner.
2. The affected runtime state, surface, message, action, and evidence are identified.
3. The fix, restriction, waiver, or backlog route is documented.
4. Retest is completed where required.
5. High-risk customer, payment, privacy, support, and evidence impacts are reviewed.
6. Rollout implication is updated.
7. Closure evidence is linked.

No high-risk display defect may remain ownerless during pilot or rollout.

## 5. Register Record Model

Each display QA register item must include:

| Field | Description |
|---|---|
| Register ID | Unique display QA register item ID |
| Source QA Run ID | QA run that found the issue |
| Source Defect ID | Defect record reference |
| Surface | Customer surface affected |
| Runtime State | Runtime state involved |
| Status Code | Display status code involved |
| Message Template | Message template involved |
| Action Code | Customer action involved, where applicable |
| Defect Family | Status, Message, Translation, Action, Privacy, Payment, Support, Evidence, Error, Recovery |
| Defect Class | DQA-1 to DQA-5 |
| Description | Clear defect statement |
| Customer Impact | What customer may see, believe, press, or dispute |
| Privacy Impact | Whether customer data or visibility risk exists |
| Financial Impact | Whether payment/refund/cancel/benefit value is affected |
| Support Impact | Whether support handling or customer communication is affected |
| Evidence Impact | Whether display evidence is missing, wrong, or insufficient |
| Owner | Responsible owner |
| Status | Open, In Review, Fix Pending, Retest Required, Passed Retest, Waived, Restricted, Blocked, Backlog, Closed |
| Review Trigger | Date, rollout gate, retest, pilot, incident, or scope change |
| Evidence Link | Supporting evidence |
| Rollout Impact | Pass, Conditional, Restricted, Blocked, Not In Scope |

## 6. Defect Families

Display QA defects must be grouped by family.

| Defect Family | Meaning |
|---|---|
| Status Binding | Wrong display status, missing status code, wrong runtime-state binding |
| Message Template | Wrong template, unapproved template, wrong version, hard-coded wording |
| Translation | Translation changes meaning or overstates runtime truth |
| Action Permission | Unsafe button/action appears or allowed action missing |
| Payment Display | Payment state shown incorrectly or unsafely |
| Refund/Cancel Display | Refund/cancel request, approval, completion, or failure wording unclear |
| Privacy Display | Wrong customer/session visibility or sensitive data exposure |
| Support Display | Support status, staff note, severity, resolution, or reopen visibility issue |
| Membership Display | Coupon, benefit, visit count, compensation, or loyalty status issue |
| Waiting Display | Waiting, call, arrival, no-show, or recovery status issue |
| Table Display | Table QR, table session, reassignment, merge/split, service context issue |
| Kiosk Display | Kiosk or mini kiosk session, cleanup, language, or recovery issue |
| Native Display | Push, deep link, stale state, or app/web conflict issue |
| Error Display | Error reveals internal data or blocks safe recovery |
| Recovery Display | Recovery creates duplicate risk or unclear customer path |
| Evidence Capture | Display/action/message evidence missing or insufficient |
| Rollout Control | Defect affects pilot/rollout restriction or acceptance |

A defect may reference multiple families, but one primary family must be assigned.

## 7. Defect Class Model

| Defect Class | Meaning | Required Handling |
|---|---|---|
| DQA-1 | Blocks pilot/rollout due to payment, privacy, wrong-session, duplicate action, or high-risk evidence failure | Immediate block, fix, or full restriction |
| DQA-2 | Material customer trust or operational defect | Fix, restrict, or waiver with owner |
| DQA-3 | Normal defect with workaround or limited scope | Fix or backlog before next gate |
| DQA-4 | Low-risk wording, layout, or improvement item | Backlog |
| DQA-5 | Observation or future improvement | Track or defer |

DQA-1 and DQA-2 defects must not be silently downgraded without reviewer approval.

## 8. Status Model

| Status | Meaning |
|---|---|
| Open | Defect recorded but not yet reviewed |
| In Review | Owner is investigating |
| Fix Pending | Fix is planned or in progress |
| Retest Required | Fix or restriction requires retest |
| Retest Failed | Retest failed and further action is needed |
| Passed Retest | Retest passed with evidence |
| Waiver Requested | Temporary acceptance requested |
| Waived | Accepted under documented waiver |
| Restricted | Scope restricted to prevent customer exposure |
| Blocked | Blocks pilot, rollout, surface, action, language, or feature |
| Backlog | Routed to backlog with owner and review trigger |
| Transferred | Moved to another governance lane with traceable handoff |
| Closed | Completed with evidence and reviewer acceptance |
| Reopened | Reopened due to regression, new evidence, or rollout impact |

Every status change must include actor, timestamp, reason, and evidence link.

## 9. Register Table

| Register ID | Defect ID | Family | Class | Surface | Status Code | Owner | Status | Rollout Impact | Evidence Link |
|---|---|---|---|---|---|---|---|---|---|
| DQAR-0001 |  |  |  |  |  |  |  |  |  |
| DQAR-0002 |  |  |  |  |  |  |  |  |  |
| DQAR-0003 |  |  |  |  |  |  |  |  |  |

## 10. High-Risk Display Defect Rules

A defect is high-risk when it involves:

- Wrong customer/session/order/payment/support data display
- Payment approval shown without authoritative payment evidence
- Payment failure shown while state is uncertain
- Refund completion shown before refund completion
- Cancel completion shown before cancel completion
- Duplicate order or payment action allowed
- Table QR opens wrong table session
- Static QR/NFC displays customer-specific data
- Raw token or internal ID exposed
- Staff-only note or internal severity exposed
- Privacy review denied before investigation
- Coupon restoration shown before restoration event
- Support resolution shown before owner decision
- Display evidence missing for DSP-R1 or DSP-R2 status

High-risk defects must route to blocker, restriction, waiver, or risk register.

## 11. Retest Control Table

| Retest ID | Linked Register ID | Defect ID | Fix / Restriction Version | Retest Result | Retested By | Evidence Link | Next Action |
|---|---|---|---|---|---|---|---|
| DQART-0001 |  |  |  |  |  |  |  |
| DQART-0002 |  |  |  |  |  |  |  |

## 12. Retest Rules

Retest is required when:

- Status binding changes
- Message template changes
- Translation changes
- Customer action permission changes
- Payment/refund/cancel display changes
- Privacy-sensitive display changes
- Support surface visibility changes
- Error/recovery behavior changes
- Evidence capture changes
- Fix affects a DSP-R1 or DSP-R2 status
- Defect was DQA-1 or DQA-2
- Defect affects rollout restriction

Retest must reproduce the original scenario and verify nearest adjacent states.

## 13. Retest Failure Rules

If retest fails:

1. Mark item as `Retest Failed`.
2. Preserve failed retest evidence.
3. Confirm whether severity increases.
4. Update rollout impact.
5. Route DQA-1/DQA-2 failures to blocker or restriction.
6. Reassign owner if needed.
7. Define next fix or waiver request.

A failed retest must not be overwritten by a later successful run without preserving history.

## 14. Waiver Control Table

| Waiver ID | Linked Register ID | Defect Class | Risk | Temporary Control | Allowed Scope | Review Trigger | Approval | Status |
|---|---|---|---|---|---|---|---|---|
| DQAW-0001 |  |  |  |  |  |  |  |  |
| DQAW-0002 |  |  |  |  |  |  |  |  |

## 15. Waiver Rules

A waiver may be used only when:

- Customer exposure is controlled
- Affected scope is limited
- Temporary control exists
- Owner is assigned
- Review trigger is defined
- Evidence impact is understood
- Approval authority accepts the risk

Waiver must not be used for:

- Active wrong-session display
- Duplicate payment risk
- Raw token exposure
- Internal staff note exposure to customer
- Payment/refund finality without evidence
- Privacy issue denial before review
- High-risk display evidence completely missing
- Uncontrolled support surface exposure

Waiver must route to 06670 if it affects customer runtime rollout decision.

## 16. Restriction Control Table

| Restriction ID | Linked Register ID | Restricted Surface | Restricted State / Action | Allowed Scope | Blocked Scope | Owner | Review Trigger |
|---|---|---|---|---|---|---|---|
| DQARST-0001 |  |  |  |  |  |  |  |
| DQARST-0002 |  |  |  |  |  |  |  |

## 17. Restriction Types

Display QA restrictions may include:

- Surface disabled
- Language disabled
- Payment display restricted
- Refund/cancel display restricted
- Native app push disabled
- Table QR disabled
- Kiosk payment disabled
- Coupon display disabled
- Guest claim button hidden
- Payment retry button disabled
- Support reopen disabled
- Stale-state action blocked
- Staff-assisted-only mode
- Pilot-only internal review mode

Restrictions must be visible in rollout handoff.

## 18. Blocker Control Table

| Blocker ID | Linked Register ID | Blocked Scope | Blocking Reason | Required Resolution | Owner | Evidence Link | Status |
|---|---|---|---|---|---|---|---|
| DQAB-0001 |  |  |  |  |  |  |  |
| DQAB-0002 |  |  |  |  |  |  |  |

## 19. Blocker Rules

A blocker must be created when:

- DQA-1 defect remains unresolved
- Wrong-session display is possible
- Payment/refund display is unsafe
- Duplicate order/payment action is possible
- Privacy-sensitive exposure is uncontrolled
- High-risk display evidence is missing
- Message template is unapproved for live surface
- Display status is bound to wrong runtime state
- Stale state allows sensitive action
- Support surface exposes internal information
- Rollout owner cannot accept risk with restriction

A blocker must identify whether it blocks pilot, rollout, surface, language, status, action, or store expansion.

## 20. Backlog Routing Table

| Backlog ID | Linked Register ID | Target Backlog | Priority | Owner | Target Action | Review Trigger |
|---|---|---|---|---|---|---|
| DQABL-0001 |  | Customer App |  |  |  |  |
| DQABL-0002 |  | Message Template |  |  |  |  |
| DQABL-0003 |  | Translation |  |  |  |  |
| DQABL-0004 |  | Display Evidence |  |  |  |  |
| DQABL-0005 |  | Privacy / Consent |  |  |  |  |
| DQABL-0006 |  | Payment / Refund Display |  |  |  |  |
| DQABL-0007 |  | Support Surface |  |  |  |  |
| DQABL-0008 |  | Kiosk / Mini Kiosk |  |  |  |  |
| DQABL-0009 |  | Native App |  |  |  |  |
| DQABL-0010 |  | Staff Training |  |  |  |  |

Backlog routing is allowed only when the issue does not block the approved scope or is covered by restriction/waiver.

## 21. Rollout Impact Table

| Register ID | Surface | Status / Action | Defect Class | Rollout Impact | Restriction | Approval Needed | Notes |
|---|---|---|---|---|---|---|---|
|  |  |  |  | Pass / Conditional / Restricted / Blocked / Not In Scope |  |  |  |

Rollout impact must be updated after fix, retest, waiver, or restriction.

## 22. Review Cadence

This register must be reviewed:

- After every display QA run
- After every DQA-1 or DQA-2 defect
- Before pilot entry
- Before rollout expansion
- After payment/refund/cancel wording changes
- After privacy-sensitive display change
- After message template version change
- After translation update
- After native app/push/deep link inclusion
- After kiosk/mini kiosk expansion
- After support surface change
- After failed retest
- Before closing any waiver or restriction

Review outcome must be recorded.

## 23. Review Record

| Review Date | Scope | Reviewer | Open Defects | Blockers | Waivers | Restrictions | Rollout Impact |
|---|---|---|---:|---:|---:|---:|---|
|  |  |  |  |  |  |  |  |

## 24. Closure Rules

A display QA register item may be closed only when:

- Defect impact is understood
- Fix, restriction, waiver, or backlog route is documented
- Retest is completed where required
- Display evidence is verified
- Payment/privacy/support reviewer has approved where required
- Rollout impact is updated
- Linked blocker or waiver is closed or carried forward
- Closure reason is recorded
- Evidence link is attached

Closure must not erase defect history.

## 25. Reopen Rules

A closed item must be reopened when:

- Same defect recurs
- Related runtime state changes
- Message template meaning changes
- Translation changes
- Payment/refund logic changes
- Privacy review changes classification
- Support case reveals customer confusion
- Rollout scope expands to affected surface/action
- Retest evidence is found insufficient
- Production/pilot incident links to the defect

Reopen must preserve original closure state.

## 26. Escalation Rules

Escalate when:

- Owner is missing
- Review trigger passes without action
- DQA-1 remains open
- Retest fails
- Waiver expires
- Restriction is bypassed
- Defect affects payment or privacy
- Defect repeats across surfaces
- Release owner asks for rollout decision
- Evidence gap prevents closeout

Escalation target may be frontend owner, runtime owner, message owner, privacy owner, finance owner, support owner, evidence owner, or release owner.

## 27. Acceptance Criteria

This register is accepted when:

- Register record model is defined
- Defect families are defined
- Defect class model is defined
- Status model is defined
- Register table is available
- High-risk display defect rules are defined
- Retest control and retest rules are defined
- Waiver rules are defined
- Restriction rules are defined
- Blocker rules are defined
- Backlog routing is defined
- Rollout impact tracking is defined
- Review cadence is defined
- Closure, reopen, and escalation rules are documented
- All unresolved display QA issues require owner and review trigger

## 28. Related Documents

Related document families include:

- Customer Runtime display QA evidence record template
- Customer Runtime display QA execution runbook
- Customer Runtime display surface QA checklist
- Customer display status code action permission message binding template
- Customer display surface status action message evidence control matrix
- Customer message template translation status wording register
- Customer runtime event audit evidence field specification template
- Customer Runtime risk waiver blocker register
- Customer Runtime pilot readiness checklist
- Customer web app runtime policy
- Customer native app runtime policy
- Customer support case policy
- Payment uncertainty policy
- Refund and cancel policy

## 29. Final Rule

A display defect is a customer promise defect.

Every wrong status, unsafe button, misleading message, stale display, privacy exposure, payment wording error, support visibility defect, and missing display evidence must remain visible until it is fixed, retested, restricted, waived, blocked, or routed with owner and evidence.

This register keeps Customer Runtime display rollout controlled after QA execution.