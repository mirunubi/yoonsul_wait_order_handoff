# 005022_Runbook_Customer_Runtime_Pilot_Execution_Observation_Closeout_Incident_And_Rollout_Decision.md

## 1. Purpose

This runbook defines the execution procedure for Customer Runtime pilot operation.

The purpose is to provide a practical operating guide for running the customer-facing runtime pilot under controlled conditions, observing live behavior, recording incidents, performing daily closeout, and preparing rollout decision evidence.

This runbook converts the Customer Runtime pilot readiness policy and checklist into an execution sequence.

## 2. Scope

This runbook covers:

- Pilot day preparation
- Opening checks
- Entrance and waiting observation
- QR/NFC and customer link observation
- Web app and kiosk continuation observation
- Table matching observation
- Customer notification observation
- Identity and guest-account observation
- Membership and benefit observation, where included
- Support case and dispute observation
- Privacy and visibility observation
- Incident handling
- Daily closeout
- Pilot closeout and rollout decision support

This runbook does not replace detailed incident, support, finance, privacy, or store runtime policies.

## 3. Baseline Dependency

This runbook depends on:

`005011_Checklist_Customer_Runtime_Pilot_Readiness_Entry_Closeout_Rollout_And_Evidence_Acceptance.md`

It also operationalizes the customer runtime lane from:

`006511_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md`

through:

`005009_Policy_Customer_Runtime_Pilot_Readiness_Closeout_Rollout_Acceptance_And_Governance.md`

## 4. Operating Principle

The pilot must be run as a controlled observation, not as an uncontrolled soft launch.

The pilot team must verify:

1. Customers can enter safely.
2. Waiting, call, arrival, no-show, and seating are traceable.
3. Customer-facing messages do not overpromise.
4. Links and tokens remain scoped.
5. Web app and customer surfaces do not create duplicate truth.
6. Staff can recover ambiguous states.
7. Support cases preserve runtime context.
8. Privacy-sensitive display does not leak data.
9. Daily closeout can prove what happened.
10. Rollout expansion is based on evidence, not impressions.

## 5. Required Roles

The following roles must be assigned before pilot execution.

| Role | Responsibility |
|---|---|
| Pilot Lead | Owns pilot execution and decision preparation |
| Store Manager | Owns store operation, staff action, and customer-facing exception approval |
| Staff Lead | Coordinates staff tablet, waiting, seating, and customer assist actions |
| Runtime Observer | Observes customer runtime state, app/link behavior, and evidence creation |
| Support Owner | Receives customer dispute or unresolved follow-up cases |
| Finance/Reconciliation Owner | Reviews payment-sensitive or refund/cancel-related customer cases |
| Privacy/Compliance Owner | Reviews customer data visibility, consent, and privacy-sensitive incidents |
| Release Owner | Approves pause, rollback, remediation, or expansion decision |
| Evidence Owner | Confirms pilot evidence packet completeness |

One person may hold multiple roles in small pilots, but the role responsibility must still be explicit.

## 6. Pre-Pilot Preparation

Before pilot opening, confirm:

- Pilot scope is approved
- Store and business date are correct
- QR/NFC entry points are placed and tested
- Customer web app entry path is reachable
- Waiting session creation works
- Staff tablet can view and correct waiting/session state
- Manager approval path is available
- Customer-facing message templates are active
- Link expiration and recovery behavior are known
- Support case intake path is available
- Daily customer closeout packet can be generated or assembled
- Incident escalation contact list is available
- Rollback or pause authority is assigned

No pilot should start if payment-sensitive customer messaging, waiting/no-show evidence, or privacy-sensitive link behavior is unknown.

## 7. Opening Procedure

At pilot opening:

1. Confirm pilot start time.
2. Confirm Store Runtime is operating under the correct business date.
3. Confirm customer entry links point to the correct store.
4. Confirm staff devices are logged in under correct roles.
5. Confirm manager approval path is active.
6. Confirm support handoff path is available.
7. Confirm evidence capture is active.
8. Confirm staff know customer-facing wording for uncertainty.
9. Confirm the pilot observer has access to required monitoring or evidence views.
10. Record opening status in the pilot log.

## 8. Entrance Flow Observation

Observe the first customer entries through:

- QR/NFC link
- Entrance assist device, if used
- Customer web app
- Staff-created waiting session
- Kiosk or mini kiosk continuation, if in scope

For each path, confirm:

- Correct store context
- Correct business date
- Guest or customer session is created
- Waiting/session identity is not duplicated
- Customer-facing status is conservative
- Evidence is recorded
- Staff can see the session where appropriate

If customer entry creates wrong store, wrong session, duplicate session, or privacy exposure, stop expansion of that path and create incident record.

## 9. Waiting Flow Observation

During waiting operation, observe:

- Waiting session creation
- Queue order
- Customer call
- Arrival confirmation
- No-show pending
- No-show confirmation
- No-show reversal
- Waiting recovery
- Staff correction
- Customer dispute linkage

Confirm that:

- Waiting state is not just a number
- Call attempts create evidence
- No-show does not erase history
- Reversal preserves original state
- Staff correction has reason and actor
- Customer-facing status does not expose internal queue conflict

Any skipped-customer claim, unclear call evidence, or disputed no-show must create support or incident linkage.

## 10. Table Flow Observation

When seating begins, observe:

- Table candidate selection
- Table assignment
- Table session creation
- Waiting-to-table linkage
- Preorder/cart/order linkage
- Table reassignment
- Table merge or split, if it occurs
- Table-linked support or dispute case, if it occurs

Confirm that:

- Table session is separate from physical table
- Waiting/session references are preserved
- Order/payment/KDS context is not lost
- Table correction creates before/after evidence
- Customer-facing table status is safe

If table assignment causes lost preorder, wrong table, wrong party, or wrong order linkage, create incident and block expansion of the table flow until reviewed.

## 11. Customer Notification Observation

Observe customer-facing messages for:

- Waiting created
- Waiting active
- Called
- Arrival pending
- Table preparing
- Table assigned
- Preorder submitted
- Order checking
- Order confirmed
- Payment pending
- Payment uncertain
- Ready or served
- Support received
- Link expired or recovery required

Confirm that:

- “Confirmed” appears only when authoritative state allows it
- Payment uncertainty is not shown as success or failure
- Expired messages are superseded by current safe state
- Multilingual wording does not overstate source meaning
- Message evidence is recorded

Any misleading customer-facing message must be recorded as pilot defect and, if material, incident or support case.

## 12. Customer Link And Token Observation

Observe link behavior for:

- Static QR/NFC entry
- Dynamic waiting link
- Arrival confirmation link
- Table context link
- Kiosk continuation link
- Support or recovery link
- Expired link
- Reopened link
- Repeated link open

Confirm that:

- Static links do not expose customer/session/payment data
- Dynamic links are scoped
- Expired links block sensitive action
- Repeated opens do not duplicate waiting/order/payment action
- Invalid links show privacy-safe error messages
- Token evidence stores safe reference or hash, not raw sensitive value

Any wrong-session access, token replay, or privacy exposure blocks rollout expansion.

## 13. Web App Observation

Observe web app behavior for:

- Guest session creation
- Customer account attachment, if in scope
- Menu availability display
- Cart draft
- Preorder submission
- Order status display
- Payment status display
- Browser refresh
- Duplicate tap
- Link expiration
- Recovery flow
- Staff/support handoff

Confirm that:

- Web app is not treated as source of truth
- Cart draft is not accepted order
- Preorder submission waits for Store Runtime validation
- Payment state is conservative
- Duplicate submission is blocked
- Recovery does not create duplicate order or payment
- Error screens do not expose internal details

Any duplicate order/payment risk must be escalated immediately.

## 14. Native App Continuity Observation

If native app is included or simulated, observe:

- Deep link behavior
- Push wording
- Account continuity
- Guest-to-account upgrade
- Web/native handoff
- Offline or stale state handling
- Duplicate prevention across app and web

If native app is excluded, confirm:

- Native app is explicitly out of pilot scope
- Future compatibility assumptions are documented
- No customer is directed to unavailable native app flow

Native app must not create a separate customer, waiting, order, payment, or support truth.

## 15. Identity Observation

Observe identity behavior for:

- Guest session
- Customer account session
- Party identity
- Device session
- Waiting session
- Table session
- Order identity
- Payment identity
- Support case identity

Confirm that:

- Guest and account are distinct
- Party and customer account are distinct
- Payment identity is not inferred from table, device, or account alone
- Guest-to-account merge preserves original guest evidence
- Duplicate identity is reviewed, not automatically merged unsafely

Wrong account attachment or identity conflict must create review record.

## 16. Membership And Benefit Observation

If membership, coupon, visit count, or benefit is in scope, observe:

- Coupon issuance
- Coupon reservation
- Coupon application
- Coupon consumption
- Coupon release
- Coupon restoration
- Visit count creation
- Guest order claim
- Compensation benefit
- Benefit support case

Confirm that:

- Coupon is not consumed before qualifying order/payment state
- Failed or expired flow releases reservation
- Refund/cancel impact is visible
- Compensation is separate from normal loyalty
- Benefit evidence is traceable
- Finance handoff receives benefit impact where relevant

If membership is out of pilot scope, confirm benefit surfaces are hidden or disabled.

## 17. Support And Dispute Observation

Observe support/dispute behavior for:

- Waiting dispute
- Table dispute
- Order dispute
- Payment dispute
- Kiosk/app dispute
- Kitchen/service dispute
- Benefit dispute
- Privacy dispute
- Compensation request

Confirm that:

- Support case preserves Store Runtime context
- Customer claim is recorded
- Owner is assigned
- Payment-related case routes to finance/reconciliation owner
- Refund and cancel are distinguished
- Compensation authority is recorded
- Case closure requires reason and evidence

Any payment dispute without evidence or owner must block clean closeout.

## 18. Privacy And Visibility Observation

Observe privacy-sensitive behavior for:

- Customer-facing waiting status
- Table QR/NFC display
- Web app session display
- Support case display
- Staff tablet customer data visibility
- Manager sensitive view
- Finance/support evidence access
- Guest-to-account merge
- Link expiration/error message
- Notification recipient

Confirm that:

- No other customer/session/order/payment data is exposed
- Staff views only live-operation data needed
- Support sees case-relevant context only
- Finance does not receive broad customer profile unnecessarily
- Sensitive evidence access is logged where required
- Privacy incident path is available

Wrong-session display or unauthorized customer data exposure must be treated as high-risk.

## 19. Incident Handling During Pilot

Create a customer runtime incident when:

- Customer-facing confirmation is wrong or premature
- Payment status is uncertain or misleading
- Waiting/no-show cannot be evidenced
- Link/token exposes wrong context
- Web app duplicates order/payment
- Table session loses order/payment/KDS context
- Guest/account merge attaches wrong identity
- Coupon/benefit causes financial ambiguity
- Support case lacks owner for material issue
- Privacy-sensitive data is exposed
- Evidence capture fails for high-risk flow

Incident record must include:

- Incident family
- Severity
- Affected customer/session/order/payment/table/support reference
- Staff action
- Manager action
- Customer-facing message
- Owner
- Evidence link
- Decision: continue, restrict, pause, rollback, or remediate

## 20. Pause Or Rollback Procedure

Pause or rollback affected customer flow when:

- Wrong customer/session data is shown
- Duplicate order/payment risk is active
- Payment uncertainty wording is unsafe
- No-show rule cannot be evidenced
- Link/token replay is unsafe
- Support/finance handoff cannot receive required context
- Evidence capture is failing
- Staff cannot safely recover customer-facing exceptions

Pause or rollback record must include:

- Scope
- Trigger
- Approver
- Customer-facing impact
- Temporary workaround
- Recovery condition
- Evidence link

Rollback must not delete affected customer journey evidence.

## 21. End-Of-Day Customer Closeout Procedure

At daily closeout:

1. Review open waiting sessions.
2. Review no-show and reversal cases.
3. Review table exceptions.
4. Review customer-facing message exceptions.
5. Review link/token expiration, replay, or privacy cases.
6. Review web/native app recovery or duplicate-prevention cases.
7. Review identity merge/conflict cases.
8. Review membership/benefit cases, if in scope.
9. Review support cases created or carried forward.
10. Review payment-sensitive customer cases.
11. Review privacy or visibility exceptions.
12. Review customer runtime incidents.
13. Confirm evidence packet completeness.
14. Assign owners for carry-forward cases.
15. Record manager or pilot lead closeout approval.

A clean customer closeout must not be declared while material customer-facing exceptions lack owner or evidence.

## 22. Pilot Log Requirements

The pilot log must record:

- Pilot date
- Store
- Business date
- Start time
- End time
- Active scope
- Staff and manager on duty
- Runtime observer
- Customer entry observations
- Waiting observations
- Table observations
- Notification observations
- Link/token observations
- Web/native observations
- Identity observations
- Support/privacy observations
- Incidents
- Pauses or rollbacks
- Closeout result
- Evidence packet reference
- Open risks
- Next action

## 23. Pilot Closeout Procedure

At pilot closeout:

1. Assemble customer runtime pilot evidence packet.
2. Review normal customer journey evidence.
3. Review exception customer journey evidence.
4. Review support and dispute cases.
5. Review privacy-sensitive cases.
6. Review payment-sensitive customer cases.
7. Review evidence gaps.
8. Review staff and manager feedback.
9. Review customer-facing wording defects.
10. Review rollout blocking conditions.
11. Classify decision as Pass, Conditional Pass, Hold, Remediate, Rollback, or Reject.
12. Record restrictions or waivers.
13. Route backlog items.
14. Prepare rollout decision record.

Pilot closeout must not rely only on sales result or absence of complaints.

## 24. Rollout Decision Inputs

Rollout decision must consider:

- Customer journey continuity
- Waiting/no-show fairness and evidence
- Table session continuity
- Customer-facing message safety
- Link/token privacy and replay safety
- Web app duplicate prevention
- Native app compatibility
- Guest/account identity safety
- Membership/benefit financial safety
- Support case handoff quality
- Privacy exception status
- Evidence packet completeness
- Staff readiness
- Manager readiness
- Store-specific risk differences
- Open incidents
- Waivers and restrictions

## 25. Output Records

This runbook produces:

- Pilot execution log
- Customer runtime incident records
- Customer support handoff records
- Privacy exception records
- Daily customer closeout packet
- Evidence gap list
- Pause or rollback records
- Pilot closeout record
- Rollout decision input record
- Post-pilot backlog routing record

## 26. Acceptance Criteria

This runbook is accepted when:

- Pilot roles are assigned
- Pre-pilot preparation is completed
- Opening procedure is recorded
- Entrance, waiting, table, notification, link, web, identity, support, and privacy flows are observed
- Incidents are recorded and owned
- Pause or rollback path is available
- Daily customer closeout is completed
- Pilot evidence packet is assembled
- Pilot closeout decision is recorded
- Rollout decision inputs are complete
- Open risks are routed to backlog, waiver, remediation, or blocker register

## 27. Related Documents

Related document families include:

- Customer Runtime pilot readiness checklist
- Customer Runtime pilot readiness policy
- Customer runtime evidence packet policy
- Customer privacy consent data retention policy
- Customer support case policy
- Membership loyalty coupon benefit policy
- Customer account and guest merge policy
- Customer web app runtime policy
- Customer native app runtime policy
- Customer link token and QR/NFC security policy
- Customer notification and multilingual guidance policy
- Table matching policy
- Waiting queue policy
- Store Runtime pilot readiness WorkPackage
- Runtime evidence policy
- Incident register template
- Rollout approval policy

## 28. Final Rule

Pilot execution must prove the customer journey under real operational pressure.

The pilot is complete only when customer entry, waiting, table, link, app, identity, benefit, support, privacy, incident, evidence, closeout, and rollout decision records are complete enough to justify the next step.