# 06790_Runbook_Customer_Runtime_Display_QA_Execution_Defect_Retest_Acceptance_And_Rollout_Handoff

## 1. Purpose

This runbook defines the Customer Runtime display QA execution, defect handling, retest, acceptance, and rollout handoff procedure.

The purpose is to provide a practical operating sequence for testing customer-facing displays, messages, buttons, recovery flows, error screens, and evidence capture before pilot or rollout.

This runbook ensures that Customer Runtime display QA verifies not only visual correctness, but runtime truth, action safety, privacy scope, message approval, evidence capture, and rollout readiness.

## 2. Scope

This runbook covers:

- Display QA preparation
- Test scope confirmation
- Runtime state setup
- Surface-by-surface execution
- Message and translation verification
- Customer action permission testing
- Payment-sensitive display testing
- Privacy-sensitive display testing
- Error and recovery testing
- Display evidence verification
- Defect classification
- Retest procedure
- Acceptance and rollout handoff

This runbook does not replace automated frontend tests, accessibility tests, load tests, security penetration tests, or final legal review.

## 3. Baseline Dependency

This runbook depends on:

`06780_Checklist_Customer_Runtime_Display_Surface_Status_Action_Message_Evidence_And_QA_Acceptance.md`

It operationalizes:

`06770_Template_Customer_Runtime_Display_Status_Code_Action_Permission_Message_Binding_And_Evidence_Template.md`

`06760_Matrix_Customer_Runtime_Display_Surface_Status_Action_Message_And_Evidence_Control_Matrix.md`

`06750_Register_Customer_Runtime_Message_Template_Translation_Status_Wording_And_Customer_Display_Control.md`

`06700_Template_Customer_Runtime_Event_Audit_Evidence_Field_Specification_Template.md`

## 4. Core Operating Principle

Display QA must prove that the customer sees only safe runtime truth.

QA execution must verify:

1. Display status is bound to authoritative runtime state.
2. Message template and version are approved.
3. Customer action buttons appear only when allowed.
4. Payment, refund, cancel, coupon, and support wording is conservative.
5. Privacy-sensitive data is not exposed.
6. Stale state is detected or recovered safely.
7. Error pages hide internal details.
8. Display evidence is recorded.
9. High-risk display defects block pilot or rollout until resolved, waived, or restricted.

## 5. Required Roles

| Role | Responsibility |
|---|---|
| QA Lead | Owns display QA execution and acceptance record |
| Runtime Owner | Provides runtime state setup and event verification |
| Frontend Owner | Fixes UI/status/action/message binding defects |
| Message Owner | Confirms template IDs, wording, and version control |
| Translation Reviewer | Reviews multilingual display meaning |
| Privacy Reviewer | Reviews customer data exposure and privacy-sensitive display |
| Finance/Reconciliation Reviewer | Reviews payment, refund, cancel, and benefit financial wording |
| Support Reviewer | Reviews support case display and customer communication safety |
| Evidence Owner | Verifies display evidence capture and access |
| Release Owner | Approves rollout handoff, restrictions, or blockers |

A small team may combine roles, but responsibility must remain explicit.

## 6. QA Preparation Procedure

Before executing QA:

1. Confirm QA scope.
2. Confirm included customer surfaces.
3. Confirm included languages.
4. Confirm included customer actions.
5. Confirm test store or test environment.
6. Confirm runtime state fixtures or test scenarios.
7. Confirm message template register is current.
8. Confirm status code registry is current.
9. Confirm action permission registry is current.
10. Confirm display evidence capture is enabled.
11. Confirm defect logging route.
12. Confirm blocker escalation route.

QA must not begin if message template versions, status codes, or allowed actions are unknown.

## 7. Test Environment Setup

Set up the test environment with:

- Test store context
- Test business date
- Test QR/NFC entry link
- Test guest session
- Test account session
- Test waiting session states
- Test table session states
- Test cart and preorder states
- Test order states
- Test payment states
- Test refund/cancel states
- Test coupon/benefit states
- Test support case states
- Test privacy-sensitive scenarios
- Test stale-state scenarios
- Test error/recovery scenarios
- Evidence access view

All test data must be clearly marked as test data and must not expose real customer data.

## 8. QA Execution Log

The QA lead must maintain an execution log.

| Field | Value |
|---|---|
| QA Run ID |  |
| QA Date |  |
| Environment |  |
| Store / Test Store |  |
| Business Date |  |
| Surface Scope |  |
| Language Scope |  |
| Runtime Scenario Set |  |
| QA Lead |  |
| Runtime Owner |  |
| Frontend Owner |  |
| Privacy Reviewer |  |
| Finance Reviewer |  |
| Support Reviewer |  |
| Evidence Owner |  |
| Overall Result | Pass / Conditional Pass / Hold / Fail |

## 9. Runtime State Setup Procedure

For each state to be tested:

1. Create or load runtime state.
2. Trigger the approved event.
3. Confirm state transition.
4. Open allowed customer surface.
5. Confirm expected display status code.
6. Confirm expected message template and version.
7. Confirm expected action buttons.
8. Confirm blocked actions are not available or safely blocked.
9. Confirm display evidence is created.
10. Record result.

Expected test record fields:

- Scenario ID
- Runtime state
- Event trigger
- Surface
- Expected status
- Actual status
- Expected action
- Actual action
- Expected message
- Actual message
- Evidence link
- Result

## 10. Entrance Surface QA Procedure

For QR/NFC and entrance surfaces:

1. Open static QR/NFC entry.
2. Confirm no customer-specific data appears.
3. Confirm correct store context.
4. Test invalid store context.
5. Test paused entry flow.
6. Test repeated scan.
7. Test unsupported device/browser, where applicable.
8. Confirm sensitive actions are blocked.
9. Confirm safe error wording.
10. Confirm evidence capture.

Defects must be created if:

- Customer data appears on public entry page
- Store context is wrong
- Static link can perform sensitive action
- Error reveals internal IDs or token details
- Repeated scan creates duplicate session

## 11. Waiting Surface QA Procedure

For waiting surfaces:

1. Create waiting draft.
2. Activate waiting session.
3. Assign queue position.
4. Trigger customer call.
5. Confirm arrival pending display.
6. Confirm arrival confirmation action.
7. Trigger no-show pending.
8. Trigger no-show confirmed.
9. Trigger no-show reversal.
10. Trigger waiting expiration.
11. Trigger recovery.
12. Trigger waiting dispute.
13. Verify message templates and evidence for each state.

High-risk defects include:

- Called display appears without call event
- No-show display appears without evidence
- Arrival confirm action appears in invalid state
- Queue display exposes other customers
- Recovery creates duplicate waiting
- Waiting status contradicts runtime state

## 12. Table Surface QA Procedure

For table surfaces:

1. Create table candidate state.
2. Create table session.
3. Link waiting to table.
4. Link preorder to table.
5. Link order to table.
6. Attach payment status to table.
7. Reassign table.
8. Test merge display.
9. Test split display.
10. Close table session.
11. Trigger table dispute.
12. Confirm table QR scope and wrong-table protection.

High-risk defects include:

- Table QR opens wrong session
- Table assignment implies order acceptance incorrectly
- Table movement loses payment/KDS context
- Merge/split exposes another party’s data
- Table closed state still allows active order action

## 13. Web App Surface QA Procedure

For web app surfaces:

1. Create guest web session.
2. Attach account session where in scope.
3. Display menu.
4. Create cart draft.
5. Modify cart.
6. Submit preorder.
7. Confirm checking status.
8. Confirm order accepted/rejected display.
9. Test duplicate submission.
10. Test payment pending/approved/failed/uncertain display.
11. Test browser refresh.
12. Test stale session.
13. Test safe error page.
14. Test support handoff.

High-risk defects include:

- Cart shown as confirmed order
- Payment uncertainty shown as success or failure
- Duplicate submit creates new order/payment
- Browser refresh opens wrong session
- Error exposes stack trace, token, internal ID, or provider detail

## 14. Native App Surface QA Procedure

If native app is in scope:

1. Open deep link.
2. Resolve session.
3. Test push send and open.
4. Test stale push landing.
5. Test app/web conflict.
6. Test account continuity.
7. Test recovery.
8. Confirm evidence.

If native app is out of scope:

1. Confirm native app surface is disabled or hidden.
2. Confirm no customer is directed to unavailable native flow.
3. Confirm future compatibility assumptions are documented.

High-risk defects include:

- Native app acts on stale state
- Push exposes sensitive payment/support data
- Deep link opens wrong session
- App/web conflict allows duplicate order/payment

## 15. Kiosk And Mini Kiosk QA Procedure

For kiosk and mini kiosk surfaces:

1. Start kiosk session.
2. Confirm previous customer context is cleared.
3. Select language.
4. Browse menu.
5. Create cart.
6. Submit order/preorder.
7. Test duplicate submit.
8. Test payment pending/uncertain display.
9. Test staff assist path.
10. Close session.
11. Confirm new session starts clean.
12. Confirm multilingual message versions.

High-risk defects include:

- Previous customer data remains visible
- Payment uncertainty is shown as final
- Language selection creates wrong identity/consent assumption
- Kiosk recovery reopens previous customer data
- Mini kiosk translation overstates state

## 16. Notification QA Procedure

For customer notifications:

1. Trigger waiting created message.
2. Trigger customer called message.
3. Trigger table assigned message.
4. Trigger order checking message.
5. Trigger payment review message.
6. Trigger refund requested/completed message.
7. Trigger support received/review/resolved message.
8. Trigger privacy review message.
9. Test old notification landing after state change.
10. Confirm recipient/session correctness.
11. Confirm lock-screen-safe content.

High-risk defects include:

- Notification sent to wrong recipient
- Payment/refund message overstates finality
- Old notification opens stale action
- Privacy message denies issue prematurely
- Notification contains sensitive order/payment/support details

## 17. Support Surface QA Procedure

For support surfaces:

1. Create support case.
2. Classify case.
3. Assign severity internally.
4. Assign owner.
5. Attach store review.
6. Attach finance review.
7. Attach benefit review.
8. Attach privacy review.
9. Propose resolution.
10. Resolve case.
11. Reject case.
12. Reopen case.
13. Carry forward case.
14. Confirm customer sees only allowed information.

High-risk defects include:

- Internal severity visible to customer
- Staff-only notes visible
- Finance review implies refund before decision
- Privacy review denies exposure before investigation
- Reopen creates unrelated duplicate case without linkage

## 18. Membership And Benefit Surface QA Procedure

For membership/benefit surfaces:

1. Show membership eligible state.
2. Show enrolled state.
3. Issue coupon.
4. Activate coupon.
5. Reserve coupon.
6. Apply coupon.
7. Consume coupon.
8. Release coupon.
9. Restore coupon.
10. Expire coupon.
11. Earn visit count.
12. Issue compensation benefit.
13. Trigger benefit dispute.
14. Confirm refund/cancel impact wording.

High-risk defects include:

- Coupon restored display appears before restoration event
- Coupon consumed appears reusable
- Benefit display implies refund/payment success
- Visit count appears before qualifying event
- Compensation benefit hidden as normal loyalty

## 19. Privacy-Sensitive Display QA Procedure

For privacy-sensitive scenarios:

1. Attempt cross-session access.
2. Attempt wrong table QR access.
3. Attempt expired token access.
4. Attempt wrong account/session linkage.
5. Test staff-only note exposure.
6. Test support case visibility.
7. Test payment provider detail exposure.
8. Test data restriction display.
9. Test consent display and withdrawal display.
10. Confirm privacy incident creation path.

High-risk defects include:

- Another customer’s data is visible
- Raw token is visible
- Internal IDs are exposed
- Staff note is customer-facing
- Privacy incident cannot be created
- Wrong-session access does not block rollout

## 20. Error And Recovery QA Procedure

For error and recovery surfaces:

1. Test expired link.
2. Test invalid link.
3. Test scope mismatch.
4. Test replay blocked.
5. Test lost session.
6. Test duplicate action.
7. Test payment error.
8. Test app/web error.
9. Test recovery action.
10. Test staff assist route.
11. Test support route.
12. Confirm evidence.

High-risk defects include:

- Error exposes internal reason
- Recovery creates duplicate order/payment/waiting
- Payment error allows unsafe retry
- Scope mismatch reveals target session
- Staff/support route lacks runtime context

## 21. Display Evidence Verification Procedure

For each high-risk display:

1. Locate display event.
2. Confirm status code.
3. Confirm status version.
4. Confirm message template ID.
5. Confirm message template version.
6. Confirm language.
7. Confirm surface.
8. Confirm runtime state at display.
9. Confirm event trigger.
10. Confirm customer action shown.
11. Confirm customer action taken, where applicable.
12. Confirm supersession or expiration, where applicable.
13. Confirm closeout route.
14. Confirm sensitive evidence is role-protected.

Display evidence failure for DSP-R1 or DSP-R2 status must be treated as blocker or waiver-required item.

## 22. Defect Classification

Display QA defects must be classified.

| Defect Class | Meaning |
|---|---|
| DQA-1 | Blocks pilot/rollout due to payment, privacy, wrong-session, duplicate action, or high-risk evidence failure |
| DQA-2 | Material customer trust or operational defect requiring remediation or restriction |
| DQA-3 | Normal defect with workaround or limited scope |
| DQA-4 | Low-risk wording, layout, or improvement item |
| DQA-5 | Observation or future improvement |

DQA-1 examples:

- Payment uncertainty shown as success
- Wrong customer data visible
- Table QR opens wrong session
- Duplicate payment action possible
- Raw token visible
- Refund completed shown before completion
- High-risk display has no evidence

## 23. Defect Record Template

| Field | Value |
|---|---|
| Defect ID |  |
| QA Run ID |  |
| Surface |  |
| Runtime State |  |
| Status Code |  |
| Message Template |  |
| Defect Class | DQA-1 / DQA-2 / DQA-3 / DQA-4 / DQA-5 |
| Description |  |
| Expected Result |  |
| Actual Result |  |
| Customer Impact |  |
| Privacy Impact |  |
| Financial Impact |  |
| Evidence Link |  |
| Owner |  |
| Required Action | Fix / Restrict / Waive / Block / Retest |
| Retest Required | Yes / No |
| Register Route |  |

DQA-1 and DQA-2 defects must route to risk register or blocker record.

## 24. Retest Procedure

For each defect requiring retest:

1. Confirm fix or restriction is deployed.
2. Confirm affected status code or message template version.
3. Recreate original runtime scenario.
4. Reproduce original customer surface.
5. Confirm expected display.
6. Confirm blocked actions.
7. Confirm evidence capture.
8. Confirm no regression on adjacent states.
9. Update defect record.
10. Update QA acceptance record.

Retest must include both normal state and nearest exception state when defect was high-risk.

## 25. Conditional Pass Procedure

A Conditional Pass may be allowed only when:

- Defect does not affect excluded scope, or
- Restriction prevents customer exposure, or
- Workaround is staff-controlled and evidenced, or
- Waiver is approved with owner and review trigger, or
- Feature is disabled for pilot/rollout scope

Conditional Pass record must include:

- Defect ID
- Restriction
- Allowed scope
- Blocked scope
- Owner
- Review trigger
- Evidence link
- Approval

Conditional Pass must not be used for active wrong-session exposure, duplicate payment risk, or uncontrolled privacy defect.

## 26. Acceptance Procedure

Display QA may be accepted when:

1. All scoped surfaces have been tested.
2. All scoped states have been tested.
3. All message bindings are approved.
4. All customer actions are verified.
5. Payment-sensitive displays are finance-reviewed.
6. Privacy-sensitive displays are privacy-reviewed.
7. Support surfaces are support-reviewed.
8. Display evidence is verified.
9. DQA-1 defects are resolved or blocking.
10. DQA-2 defects are resolved, restricted, or waiver-approved.
11. Conditional restrictions are recorded.
12. Rollout handoff is prepared.

## 27. Rollout Handoff Procedure

Before rollout handoff:

1. Prepare QA acceptance record.
2. Attach defect summary.
3. Attach retest summary.
4. Attach unresolved restriction summary.
5. Attach waiver summary.
6. Attach display evidence summary.
7. Attach message template version list.
8. Attach language scope list.
9. Attach surface scope list.
10. Route unresolved risks to register.
11. Request release owner approval.

Rollout handoff must not hide display defects in informal notes.

## 28. Output Records

This runbook produces:

- Display QA execution log
- Surface test result records
- Runtime state test records
- Message binding verification records
- Customer action permission verification records
- Display evidence verification records
- Display QA defect records
- Retest records
- Conditional pass records
- QA acceptance record
- Rollout handoff record
- Risk register routing records

## 29. Blocking Conditions

Display QA must block pilot or rollout when:

- Customer-facing status can show wrong customer/session/order/payment/support data
- Payment or refund state can be shown as final without authoritative evidence
- Sensitive action can duplicate order/payment/waiting/support record
- Table QR or link can open wrong session
- Error or recovery surface exposes token/internal/provider detail
- Support surface exposes internal staff note or severity
- Privacy review wording denies exposure before review
- Message template is unapproved or unversioned
- High-risk display evidence is missing
- DQA-1 defect remains unresolved without approved full restriction

Blocking conditions must route to:

`06670_Register_Customer_Runtime_Risk_Waiver_Blocker_Backlog_Carry_Forward_And_Rollout_Control.md`

## 30. Acceptance Criteria

This runbook is accepted when:

- QA roles are defined
- QA preparation procedure is defined
- Test environment setup is defined
- Runtime state setup procedure is defined
- Entrance, waiting, table, web app, native app, kiosk, notification, support, membership, privacy, error, and recovery QA procedures are defined
- Display evidence verification procedure is defined
- Defect classification is defined
- Defect record template is included
- Retest procedure is defined
- Conditional pass procedure is defined
- Acceptance procedure is defined
- Rollout handoff procedure is defined
- Output records are defined
- Blocking conditions are documented

## 31. Related Documents

Related document families include:

- Customer display surface QA checklist
- Customer display status code action permission message binding template
- Customer display surface status action message evidence control matrix
- Customer message template translation status wording register
- Customer runtime event audit evidence field specification template
- Customer runtime state authority event evidence matrix
- Privacy consent and link security preflight checklist
- Customer Runtime risk waiver blocker register
- Customer Runtime pilot readiness checklist
- Customer Runtime pilot execution runbook
- Customer web app runtime policy
- Customer native app runtime policy
- Customer support case policy
- Payment uncertainty policy
- Refund and cancel policy

## 32. Final Rule

A display is accepted only after it is tested against runtime truth.

This runbook ensures that every customer-facing status, message, action, error, recovery path, and evidence record is verified before pilot or rollout.

If a customer can see it, press it, rely on it, or dispute it, it must be tested and evidenced.