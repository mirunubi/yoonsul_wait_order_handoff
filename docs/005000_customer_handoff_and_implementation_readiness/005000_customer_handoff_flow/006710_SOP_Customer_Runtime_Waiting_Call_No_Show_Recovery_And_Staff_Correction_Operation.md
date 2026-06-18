# 006710_SOP_Customer_Runtime_Waiting_Call_No_Show_Recovery_And_Staff_Correction_Operation

## 1. Purpose

This SOP defines the Customer Runtime waiting, call, no-show, recovery, and staff correction operating procedure.

The purpose is to ensure that entrance waiting flow is operated fairly, recoverably, and with sufficient evidence under live-store conditions.

Waiting operation must not depend only on staff memory, verbal instruction, or customer claim.  
Every call, arrival, no-show, reversal, recovery, and staff correction must preserve operational truth and customer-facing trust.

## 2. Scope

This SOP covers:

- Waiting session creation
- Queue review
- Customer call
- Arrival confirmation
- No-show pending
- No-show confirmation
- No-show reversal
- Waiting recovery
- Duplicate waiting handling
- Staff correction
- Manager escalation
- Support handoff
- Evidence capture
- Daily closeout review

This SOP does not define full customer app implementation, final queue algorithm, final staff tablet UI, or full customer support workflow.

## 3. Baseline Dependency

This SOP depends on:

`006520_Policy_Entrance_Waiting_Queue_Call_Arrival_No_Show_Seating_And_Recovery_Control.md`

`006540_Policy_Entrance_Customer_Notification_Status_Display_Multilingual_Guidance.md`

`006620_Policy_Customer_Runtime_Evidence_Audit_Trail_Traceability_Closeout_Handoff.md`

`06690_Matrix_Customer_Runtime_State_Authority_Event_And_Evidence_Coverage_Matrix.md`

`006700_Template_Customer_Runtime_Event_Audit_Evidence_Field_Specification_Template.md`

## 4. Core Operating Principle

Waiting operation must be fair, stateful, and reversible.

Staff must ensure:

1. Waiting session is created under correct store and business date.
2. Queue position is visible to staff and traceable.
3. Customer call creates evidence.
4. Arrival confirmation is recorded.
5. No-show is not applied without call evidence or staff action evidence.
6. No-show reversal preserves original no-show record.
7. Recovery creates a new trace or controlled restored state.
8. Customer dispute is linked to support or manager review.
9. Daily closeout reviews unresolved waiting exceptions.

## 5. Roles And Authority

| Role | Allowed Actions |
|---|---|
| Store Staff | Create staff-assisted waiting, call customer, confirm arrival, request correction, create support handoff |
| Staff Lead | Review queue, coordinate seating, approve ordinary waiting correction where allowed |
| Store Manager | Approve no-show reversal, disputed queue correction, compensation request, exception closeout |
| Customer Support Owner | Receive unresolved customer dispute after store handoff |
| Runtime Observer / Evidence Owner | Verify waiting evidence and packet completeness during pilot |
| Release Owner | Pause or restrict waiting flow if evidence or fairness risk is material |

Staff must not erase waiting history.

## 6. Waiting Session Creation Procedure

When a customer enters waiting flow:

1. Confirm store context.
2. Confirm business date.
3. Confirm waiting source:
   - QR/NFC
   - Customer web app
   - Entrance assist device
   - Staff tablet
   - Kiosk or mini kiosk continuation
   - Support/recovery link
4. Confirm party information required by current policy.
5. Create or validate waiting session.
6. Confirm customer-facing waiting status is safe.
7. Confirm event and evidence were created.

Expected event examples:

- `waiting_draft_created`
- `waiting_activated`
- `waiting_queue_position_assigned`

Evidence must include:

- Store ID
- Business date
- Waiting session ID
- Guest or customer reference, where available
- Source
- Timestamp
- Initial state
- Customer-facing status

## 7. Queue Review Procedure

Before calling customers, staff must review:

- Current queue
- Arrival-ready customers
- Staff-created waiting sessions
- Duplicate waiting warnings
- Expired or stale waiting sessions
- Table availability
- Special service context notes
- Customer language or accessibility note, where visible and allowed

Staff must not reorder queue casually.

Queue reorder requires:

- Actor
- Reason
- Before queue state
- After queue state
- Customer-facing impact
- Evidence record

Expected event:

- `waiting_queue_reordered`

## 8. Customer Call Procedure

When calling a customer:

1. Select the waiting session from staff device or approved runtime surface.
2. Confirm customer/session is active.
3. Confirm table or seating readiness condition.
4. Trigger call through approved channel or record staff verbal call.
5. Confirm call state is recorded.
6. Confirm customer-facing status changed to called or arrival pending.
7. Observe whether arrival confirmation is received.

Expected event:

- `waiting_customer_called`

Call evidence must include:

- Waiting session ID
- Call channel
- Actor or system source
- Timestamp
- Message/template reference, where applicable
- Customer-facing status
- Delivery/display result, where available
- Staff verbal call note, where recorded

A customer must not be marked no-show if call evidence is missing unless manager-approved exceptional recovery is recorded.

## 9. Arrival Confirmation Procedure

Arrival may be confirmed by:

- Customer action
- Staff confirmation
- Entrance assist device
- Table assignment action
- Manager correction

Procedure:

1. Open waiting session.
2. Confirm customer or party identity with safe operational method.
3. Mark arrival confirmed.
4. Confirm arrival timestamp.
5. Confirm next action:
   - Seat now
   - Hold arrival-ready
   - Merge with table assignment
   - Escalate if duplicate/unclear

Expected event:

- `waiting_arrival_confirmed`

Arrival evidence must include:

- Waiting session ID
- Actor or customer action
- Timestamp
- Previous state
- New state
- Related call reference
- Table candidate or table session reference, where applicable

## 10. No-Show Pending Procedure

No-show must pass through controlled judgment.

Before marking no-show pending, staff must confirm:

- Customer was called
- Sufficient wait interval or local rule is satisfied
- Call evidence exists
- No arrival confirmation exists
- Customer is not already seated
- Customer is not attached to active order/table flow
- There is no ongoing support or staff correction for the same waiting session

Procedure:

1. Review waiting session.
2. Review call evidence.
3. Confirm no arrival.
4. Mark no-show pending if system supports staged state.
5. Record reason.
6. Keep recovery path available.

Expected event:

- `waiting_no_show_pending`

No-show pending should not immediately destroy customer recovery.

## 11. No-Show Confirmation Procedure

No-show confirmation should occur only after no-show pending or approved direct no-show rule.

Procedure:

1. Review no-show pending state.
2. Confirm no arrival.
3. Confirm no active table/order/payment/KDS linkage.
4. Confirm no staff dispute or support handoff is already open.
5. Confirm no-show action.
6. Record reason and actor.
7. Confirm customer-facing state is safe and recoverable where allowed.
8. Preserve evidence.

Expected event:

- `waiting_no_show_confirmed`

No-show evidence must include:

- Waiting session ID
- Call evidence reference
- Actor
- Timestamp
- Previous state
- New state
- Reason
- Customer-facing status
- Recovery eligibility
- Dispute/support linkage, where applicable

## 12. No-Show Reversal Procedure

No-show reversal is sensitive.

No-show reversal may be required when:

- Customer was present but not confirmed
- Staff called wrong party
- Message delivery failed
- Customer could not respond due to system issue
- Queue/table state was wrong
- Manager accepts customer claim
- Evidence shows no-show was applied incorrectly

Procedure:

1. Open no-show waiting session.
2. Review call evidence.
3. Review customer claim or staff note.
4. Confirm table/order/payment state.
5. Request manager approval if required.
6. Apply reversal or recovery action.
7. Preserve original no-show state.
8. Record reversal reason.
9. Update customer-facing status safely.
10. Link support case if customer dispute remains.

Expected events:

- `waiting_no_show_reversed`
- `waiting_recovered`
- `waiting_dispute_created`, where applicable

No-show reversal must not delete original no-show evidence.

## 13. Waiting Recovery Procedure

Waiting recovery may be used when:

- Customer link expired
- Browser session was lost
- Duplicate waiting was detected
- Customer was incorrectly no-showed
- Customer says waiting disappeared
- Staff created wrong waiting session
- Store network/device issue interrupted waiting
- Customer changed party size or service mode

Procedure:

1. Identify original waiting reference if available.
2. Confirm customer or party context with safe method.
3. Check for active duplicate waiting.
4. Check for active table/order/payment linkage.
5. Choose recovery action:
   - Restore waiting
   - Create new waiting linked to original evidence
   - Merge duplicate waiting
   - Cancel duplicate waiting
   - Escalate to manager/support
6. Record recovery reason.
7. Preserve before/after state.
8. Update customer-facing status conservatively.

Expected events:

- `waiting_recovered`
- `waiting_duplicate_detected`
- `waiting_duplicate_resolved`
- `customer_link_recovery_started`

Recovery must not create duplicate order/payment risk.

## 14. Duplicate Waiting Handling Procedure

When duplicate waiting is suspected:

1. Compare guest/account/session references.
2. Compare device/link references.
3. Compare party label and party size.
4. Compare customer contact reference where allowed.
5. Check whether either waiting session is already called, arrived, seated, or cancelled.
6. Do not auto-merge if identity is ambiguous.
7. Choose action:
   - Keep both
   - Cancel duplicate
   - Merge with manager approval
   - Create support review
8. Record decision.

Expected events:

- `duplicate_waiting_detected`
- `duplicate_waiting_review_required`
- `duplicate_waiting_resolved`

Duplicate handling must preserve both original records.

## 15. Staff Correction Procedure

Staff correction may be needed for:

- Wrong party size
- Wrong service mode
- Wrong waiting source
- Queue reorder
- Missed call
- Arrival correction
- No-show correction
- Duplicate waiting
- Lost customer link
- Incorrect staff note
- Wrong table handoff

Procedure:

1. Open affected waiting session.
2. Identify correction type.
3. Confirm staff authority.
4. If sensitive, request manager approval.
5. Record before state.
6. Apply correction.
7. Record after state.
8. Enter reason code.
9. Add note if required.
10. Confirm customer-facing status.
11. Link incident/support if customer impact is material.

Expected event:

- `waiting_staff_correction_applied`

Correction evidence must include actor, reason, before/after, and customer-facing impact.

## 16. Manager Escalation Criteria

Escalate to manager when:

- Customer disputes no-show
- Queue fairness is challenged
- Staff wants to restore a no-showed customer
- Duplicate waiting affects seating priority
- Waiting state conflicts with table/order/payment state
- Staff action would affect another customer’s place
- Compensation or apology coupon is requested
- Privacy or wrong-session issue appears
- Evidence is missing for material decision
- Customer is visibly upset or complaint may continue

Manager decision must be recorded.

Expected events:

- `manager_waiting_exception_review_started`
- `manager_waiting_exception_approved`
- `manager_waiting_exception_rejected`

## 17. Support Handoff Criteria

Create support handoff when:

- Customer dispute cannot be resolved immediately
- Waiting call evidence is disputed
- Customer says they were skipped
- No-show reversal is rejected
- Customer claims app/link showed different status
- Staff cannot determine original waiting state
- Privacy-sensitive waiting issue occurred
- Compensation requires later review
- Customer requests follow-up

Support handoff must include:

- Waiting session ID
- Customer or guest reference
- Store and business date
- Customer claim
- Staff note
- Manager decision, where applicable
- Call/no-show/recovery evidence
- Customer-facing message evidence
- Requested support action

Expected event:

- `waiting_support_handoff_created`

## 18. Privacy-Sensitive Waiting Issues

Privacy-sensitive issues include:

- Customer sees another party’s waiting status
- Wrong customer receives call message
- Staff attaches wrong account to waiting
- Link opens wrong waiting session
- Waiting display exposes personal data
- Support case links wrong guest/account
- QR/NFC link leaks session-specific data

Procedure:

1. Stop affected flow if exposure is active.
2. Record incident.
3. Notify manager.
4. Escalate privacy/compliance owner.
5. Preserve evidence.
6. Use safe customer-facing wording.
7. Do not delete evidence casually.

Expected event:

- `privacy_incident_created`

## 19. Customer-Facing Wording Rules

Staff should use conservative wording.

Allowed examples:

- “확인 후 안내드리겠습니다.”
- “호출 상태를 확인하고 있습니다.”
- “대기 기록을 확인해 보겠습니다.”
- “시스템상 상태와 현장 상황을 같이 확인하겠습니다.”
- “필요하면 매니저가 확인해 드리겠습니다.”

Avoid unsupported statements:

- “무조건 고객님 차례가 맞습니다.”
- “시스템 오류니까 바로 앞에 넣어드릴게요.”
- “결제/주문까지 문제없습니다.”
- “기록은 없지만 처리해 드렸습니다.”
- “대기 기록은 없어졌습니다.”

Customer-facing wording must not overstate unverified runtime truth.

## 20. Evidence Requirements

Waiting SOP must preserve evidence for:

- Waiting creation
- Queue assignment
- Queue reorder
- Customer call
- Arrival confirmation
- No-show pending
- No-show confirmation
- No-show reversal
- Waiting recovery
- Duplicate waiting detection
- Duplicate waiting resolution
- Staff correction
- Manager approval
- Support handoff
- Privacy incident
- Daily closeout review

Evidence fields must include:

- Store ID
- Business date
- Waiting session ID
- Guest or customer reference, where available
- Actor ID, where applicable
- Event name
- Previous state
- New state
- Timestamp
- Reason code
- Customer-facing status
- Evidence record ID
- Support/incident/closeout reference, where applicable

## 21. Daily Closeout Procedure

At daily closeout, review:

- Active waiting sessions
- Called but not arrived sessions
- No-show pending sessions
- No-show confirmed sessions
- No-show reversals
- Waiting recoveries
- Duplicate waiting records
- Staff corrections
- Queue reorders
- Waiting disputes
- Support handoffs
- Privacy-sensitive waiting issues
- Missing call/no-show evidence

Closeout result must classify:

- Clean
- Exception Close
- Carry-Forward
- Blocked

A waiting exception must not be closed without owner or evidence.

## 22. Blocking Conditions

Waiting flow must be paused, restricted, or escalated when:

- Customers are being called without evidence
- No-show is applied without call evidence
- Wrong customer receives waiting status
- Link opens wrong waiting session
- Duplicate waiting causes unfair seating
- Staff cannot recover lost waiting state
- Queue reorder lacks before/after evidence
- Customer-facing waiting status contradicts staff runtime state
- Privacy exposure is suspected
- Daily closeout cannot reconstruct waiting exceptions

Blocking conditions must route to risk register.

## 23. Training Checklist

Staff training must cover:

- Waiting state lifecycle
- Customer call procedure
- Arrival confirmation
- No-show pending and confirmation
- No-show reversal
- Recovery process
- Duplicate waiting handling
- Staff correction rules
- Manager escalation
- Support handoff
- Privacy-sensitive waiting issues
- Customer-facing wording
- Evidence importance
- Daily closeout review

Training must include at least one normal flow and one exception flow.

## 24. Acceptance Criteria

This SOP is accepted when:

- Waiting creation procedure is defined
- Queue review procedure is defined
- Customer call procedure is defined
- Arrival confirmation procedure is defined
- No-show pending and confirmation procedures are defined
- No-show reversal procedure is defined
- Waiting recovery procedure is defined
- Duplicate waiting handling is defined
- Staff correction procedure is defined
- Manager escalation criteria are defined
- Support handoff criteria are defined
- Privacy-sensitive issue handling is defined
- Evidence requirements are traceable
- Daily closeout procedure is defined
- Blocking conditions are documented
- Training checklist is included

## 25. Related Documents

Related document families include:

- Waiting queue call arrival no-show seating and recovery policy
- Customer notification multilingual guidance policy
- Customer link token QR/NFC security policy
- Customer support case policy
- Customer privacy consent data retention policy
- Customer runtime evidence packet policy
- Customer runtime state authority event evidence matrix
- Customer runtime event audit evidence field specification template
- Customer Runtime pilot readiness checklist
- Customer Runtime pilot execution runbook
- Customer Runtime risk waiver blocker register

## 26. Final Rule

Waiting operation is customer trust operation.

A customer may forgive a delay, but not an unfair, unprovable, or unrecoverable waiting decision.

Every waiting call, no-show, recovery, and correction must be stateful, evidenced, reversible where allowed, and reviewable at closeout.