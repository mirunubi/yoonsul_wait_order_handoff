# 006720_SOP_Customer_Runtime_Table_Matching_Preorder_Link_And_Service_Context_Operation

## 1. Purpose

This SOP defines the Customer Runtime table matching, preorder link, and service context operating procedure.

The purpose is to ensure that waiting, preorder, table session, order, payment, KDS, staff service, and customer support context remain connected when a customer is seated or moved.

Table matching is not simply assigning a physical table.  
It is the controlled creation of a service context where customer identity, party identity, waiting session, preorder, order, payment status, KDS ticket, staff action, and closeout evidence remain traceable.

## 2. Scope

This SOP covers:

- Table availability review
- Table candidate selection
- Table session creation
- Waiting-to-table transition
- Preorder-to-table linkage
- Order-to-table linkage
- Payment-sensitive table context
- KDS and kitchen ticket linkage
- Table reassignment
- Table merge
- Table split
- Table session close
- Staff correction
- Manager escalation
- Support handoff
- Evidence capture
- Daily closeout review

This SOP does not define final table layout UI, final seat optimization algorithm, final POS table map, or full dining service SOP.

## 3. Baseline Dependency

This SOP depends on:

`006530_Policy_Entrance_Table_Matching_Table_Session_Preorder_Link_Service_Context_And_Seating_Control.md`

`006520_Policy_Entrance_Waiting_Queue_Call_Arrival_No_Show_Seating_And_Recovery_Control.md`

`006620_Policy_Customer_Runtime_Evidence_Audit_Trail_Traceability_Closeout_Handoff.md`

`06690_Matrix_Customer_Runtime_State_Authority_Event_And_Evidence_Coverage_Matrix.md`

`006700_Template_Customer_Runtime_Event_Audit_Evidence_Field_Specification_Template.md`

`006710_SOP_Customer_Runtime_Waiting_Call_No_Show_Recovery_And_Staff_Correction_Operation.md`

## 4. Core Operating Principle

A table session must preserve service truth.

Staff must ensure:

1. Physical table identity and table session identity are separate.
2. Waiting session is linked before or during seating where applicable.
3. Preorder or cart context is linked only through controlled validation.
4. Order, payment, and KDS references remain attached to the correct service context.
5. Table reassignment preserves before/after evidence.
6. Merge and split do not erase original references.
7. Payment-sensitive states are not hidden by table movement.
8. Daily closeout can reconstruct the table journey.

## 5. Roles And Authority

| Role | Allowed Actions |
|---|---|
| Store Staff | Review table readiness, seat customer, create table session, attach waiting context, request correction |
| Staff Lead | Coordinate table flow, approve ordinary table correction where allowed |
| Store Manager | Approve sensitive reassignment, merge/split exception, compensation, disputed table correction, closeout exception |
| KDS / Kitchen Owner | Review kitchen ticket linkage and service state conflict |
| Support Owner | Receive unresolved customer dispute related to table/order/service context |
| Finance/Reconciliation Owner | Review payment-sensitive table/order/refund/cancel impact |
| Evidence Owner | Verify table session evidence packet completeness |
| Release Owner | Pause or restrict table flow if context-loss risk is material |

Staff must not erase table session history or silently move order/payment context.

## 6. Table Availability Review Procedure

Before assigning a table, staff must review:

- Physical table availability
- Table cleanliness or readiness
- Active table sessions
- Closing or payment-pending table sessions
- Reserved or held tables
- Party size
- Waiting priority
- Preorder readiness
- KDS/kitchen status, where applicable
- Staff service capacity
- Accessibility or language note, where visible and allowed

A table must not be marked available merely because the physical seat is empty if an active table session, payment, support case, or closeout conflict remains.

Expected event examples:

- `table_available`
- `table_candidate_selected`

## 7. Table Candidate Selection Procedure

When selecting a candidate table:

1. Select waiting session or customer party.
2. Review party size and service mode.
3. Review preorder or cart linkage, if any.
4. Confirm physical table readiness.
5. Confirm no active conflicting table session exists.
6. Select candidate table.
7. Record candidate selection if customer-facing or operationally material.
8. Continue to table session creation.

Expected event:

- `table_candidate_selected`

Evidence should include:

- Waiting session reference
- Party reference
- Physical table reference
- Staff actor
- Timestamp
- Candidate reason, where required

## 8. Table Session Creation Procedure

A table session must be created when a party is seated or service context becomes active.

Procedure:

1. Confirm physical table ID.
2. Confirm business date.
3. Confirm waiting session, if applicable.
4. Confirm guest/customer/party context.
5. Create table session.
6. Link waiting session to table session.
7. Attach preorder/cart/order references, where valid.
8. Confirm customer-facing status.
9. Confirm evidence creation.

Expected events:

- `table_session_created`
- `waiting_linked_to_table_session`

Table session evidence must include:

- Store ID
- Business date
- Physical table ID
- Table session ID
- Waiting session ID, where applicable
- Party ID
- Guest/customer reference, where available
- Actor
- Timestamp
- Initial service context

## 9. Waiting-To-Table Transition Procedure

When seating a waiting customer:

1. Open waiting session.
2. Confirm waiting state is active, called, or arrival confirmed.
3. Confirm no no-show final state is active unless reversal or recovery has occurred.
4. Confirm party identity using safe method.
5. Create or select table session.
6. Link waiting session to table session.
7. Update waiting state to seated or table-linked.
8. Record transition evidence.
9. Confirm customer-facing seating message is safe.

Expected event:

- `waiting_linked_to_table_session`

A waiting session must not be closed without table linkage evidence if the customer was seated through the waiting flow.

## 10. Preorder-To-Table Linkage Procedure

When a customer has a preorder or cart before seating:

1. Locate preorder/cart reference.
2. Confirm it belongs to the same guest/account/party/session context.
3. Confirm preorder is not already linked to another active table session.
4. Confirm preorder is not cancelled, expired, or already consumed.
5. Confirm order/payment status.
6. Link preorder to table session.
7. Notify staff/KDS/POS flow as required.
8. Record linkage evidence.
9. Show conservative customer-facing status.

Expected event:

- `preorder_linked_to_table_session`

Preorder linkage must not imply POS acceptance, kitchen acceptance, or payment completion unless those states are separately confirmed.

## 11. Order-To-Table Linkage Procedure

When an order exists or is accepted after seating:

1. Confirm table session is active.
2. Confirm order reference.
3. Confirm order source:
   - Customer web app
   - Kiosk
   - Mini kiosk
   - Staff tablet
   - POS terminal
   - POS Gateway
4. Confirm order belongs to the table session or approved customer/party context.
5. Link order to table session.
6. Confirm KDS ticket linkage if kitchen execution starts.
7. Confirm payment status linkage if payment exists.
8. Record evidence.

Expected event:

- `order_linked_to_table_session`

A table session may contain multiple orders, but each order must remain independently traceable.

## 12. Payment-Sensitive Table Context Procedure

Payment state must remain separate from table assignment.

When payment status is involved:

1. Confirm payment attempt ID or POS Gateway reference.
2. Confirm payment state:
   - Not started
   - Pending
   - Approved
   - Failed
   - Uncertain
   - Refund pending
   - Refund completed
   - Cancel pending
   - Cancel completed
3. Confirm payment is linked to the correct order and table session.
4. Do not present payment success if uncertainty remains.
5. Escalate to manager/finance if table session cannot close due to payment state.
6. Record evidence.

Expected events:

- `payment_evidence_linked`
- `customer_payment_status_displayed`
- `support_finance_handoff_attached`, where applicable

Table movement must not hide payment uncertainty.

## 13. KDS And Kitchen Ticket Linkage Procedure

When an order becomes kitchen-executable:

1. Confirm accepted order reference.
2. Confirm table session reference.
3. Confirm KDS ticket creation.
4. Confirm kitchen ticket belongs to correct table/service context.
5. Confirm ready/served state is linked to correct table session.
6. If remake or delay occurs, preserve table/order/KDS references.
7. Record evidence.

Expected events:

- `kds_ticket_linked_to_table_session`
- `kitchen_ready_status_linked_to_table`
- `kitchen_served_status_linked_to_table`

KDS status must not be treated as payment status.

## 14. Table Reassignment Procedure

Table reassignment may occur when:

- Customer moves table
- Staff seats customer incorrectly
- Larger party needs different table
- Accessibility need arises
- Table issue occurs
- Service recovery requires movement
- Store operation changes seating plan

Procedure:

1. Open existing table session.
2. Confirm current physical table.
3. Confirm target physical table.
4. Confirm order/payment/KDS/support references.
5. Confirm no conflicting active session exists on target table.
6. Request manager approval if sensitive.
7. Apply reassignment.
8. Preserve previous table reference.
9. Update customer-facing guidance.
10. Record before/after evidence.

Expected event:

- `table_session_reassigned`

Reassignment must not create a new unlinked table session unless intentionally split or recovered.

## 15. Table Merge Procedure

Table merge may occur when:

- Two parties become one service context
- Split waiting groups are seated together
- Adjacent tables are combined
- Staff needs operationally combined service view
- Orders should remain separate but table service context is shared

Procedure:

1. Identify table sessions to merge.
2. Confirm all affected parties.
3. Confirm active orders.
4. Confirm payment states.
5. Confirm KDS tickets.
6. Confirm support/dispute cases.
7. Determine merge type:
   - Service-context merge only
   - Order-view merge
   - Payment grouping request
   - Physical table merge only
8. Obtain manager approval when financial/order context may be affected.
9. Complete merge.
10. Preserve original session references.
11. Record merge evidence.

Expected events:

- `table_merge_requested`
- `table_merge_completed`

Merge must not automatically merge payments, customer accounts, coupons, or support cases.

## 16. Table Split Procedure

Table split may occur when:

- Party separates
- Orders must be separated
- Payment must be separated
- Table physically splits
- Staff created combined session incorrectly
- Customer dispute requires separation

Procedure:

1. Identify original table session.
2. Identify target split sessions.
3. Confirm affected orders.
4. Confirm affected payment states.
5. Confirm KDS ticket ownership.
6. Confirm customer/party identity.
7. Determine split type:
   - Physical table split
   - Service-context split
   - Order split
   - Payment split request
   - Support/dispute split
8. Obtain manager approval when payment/order/support context may be affected.
9. Apply split.
10. Preserve original table session reference.
11. Record split evidence.

Expected events:

- `table_split_requested`
- `table_split_completed`

Split must not erase original service history.

## 17. Table Session Close Procedure

A table session may be closed when:

- Service is complete
- Orders are complete or intentionally carried forward
- Payment status is resolved or assigned to owner
- KDS tickets are served, cancelled, or reconciled
- Support cases are closed or carried forward
- Table is physically released
- Closeout evidence is recorded

Procedure:

1. Review table session.
2. Confirm active orders.
3. Confirm payment state.
4. Confirm KDS/kitchen state.
5. Confirm support/dispute state.
6. Confirm coupon/benefit impact, where applicable.
7. Confirm no privacy or wrong-session issue remains unresolved.
8. Close table session or mark exception close.
9. Record close evidence.

Expected events:

- `table_session_closing`
- `table_session_closed`
- `customer_closeout_exception_found`, where applicable

A table session must not be clean-closed while payment uncertainty or support ownerless dispute remains.

## 18. Staff Correction Procedure

Staff correction may be required for:

- Wrong table assignment
- Wrong party attached
- Wrong preorder linked
- Wrong order attached
- Incorrect table status
- Missed table reassignment
- Wrong merge/split
- Lost table session
- Incorrect served/ready state
- Customer-facing status mismatch

Procedure:

1. Open table session.
2. Identify correction type.
3. Review current references.
4. Confirm staff authority.
5. Request manager approval if sensitive.
6. Record before state.
7. Apply correction.
8. Record after state.
9. Enter reason code.
10. Link support/incident if customer impact occurred.
11. Confirm evidence.

Expected event:

- `table_staff_correction_applied`

Staff correction must not silently alter order, payment, KDS, coupon, or support records.

## 19. Manager Escalation Criteria

Escalate to manager when:

- Table reassignment affects another customer
- Preorder linked to wrong table
- Order linked to wrong table
- Payment state conflicts with table session
- Table merge/split affects payment or order ownership
- Customer disputes seating or table movement
- Staff correction changes customer-facing promise
- Support case requires compensation
- Privacy or wrong-session issue appears
- Evidence is missing for material action
- Table cannot be closed cleanly

Manager decision must be recorded.

Expected events:

- `manager_table_exception_review_started`
- `manager_table_exception_approved`
- `manager_table_exception_rejected`

## 20. Support Handoff Criteria

Create support handoff when:

- Customer claims wrong table/order linkage
- Preorder disappeared after seating
- Customer says table QR opened wrong session
- Customer disputes order/payment attached to table
- Staff cannot determine correct service context
- Table merge/split created customer confusion
- Compensation or refund follow-up is needed
- Privacy-sensitive table/session issue occurred
- Customer requests follow-up

Support handoff must include:

- Table session ID
- Waiting session ID, where applicable
- Customer or guest reference
- Order/payment/KDS references, where applicable
- Staff note
- Manager decision, where applicable
- Customer claim
- Evidence links
- Requested support action

Expected event:

- `table_support_handoff_created`

## 21. Privacy-Sensitive Table Issues

Privacy-sensitive table issues include:

- Table QR opens another table session
- Customer sees another party’s order
- Customer sees another party’s payment status
- Staff attaches wrong account to table
- Table merge exposes unrelated customer data
- Support case links wrong table/customer
- Customer-facing display reveals internal notes or IDs

Procedure:

1. Stop affected link/display path if exposure is active.
2. Notify manager.
3. Create privacy incident.
4. Escalate privacy/compliance owner.
5. Preserve link, display, table, and staff action evidence.
6. Use safe customer-facing wording.
7. Do not delete evidence casually.

Expected event:

- `privacy_incident_created`

## 22. Customer-Facing Wording Rules

Allowed examples:

- “좌석 정보를 확인해 안내드리겠습니다.”
- “주문 연결 상태를 확인 중입니다.”
- “테이블 이동 기록을 확인하고 있습니다.”
- “결제 상태는 별도 확인 후 안내드리겠습니다.”
- “현장 매니저가 확인 후 처리하겠습니다.”

Avoid unsupported statements:

- “주문이 무조건 이 테이블로 들어갔습니다.”
- “결제까지 다 정상입니다.”
- “이동했으니 이전 기록은 없어졌습니다.”
- “다른 테이블 주문이지만 그냥 처리해드릴게요.”
- “시스템에는 안 보이지만 문제없습니다.”

Customer-facing wording must not overstate table, order, payment, or kitchen truth.

## 23. Evidence Requirements

Table SOP must preserve evidence for:

- Table availability review
- Table candidate selection
- Table session creation
- Waiting-to-table linkage
- Preorder-to-table linkage
- Order-to-table linkage
- Payment-state-to-table linkage
- KDS-to-table linkage
- Table reassignment
- Table merge
- Table split
- Table session close
- Staff correction
- Manager approval
- Support handoff
- Privacy incident
- Daily closeout review

Evidence fields must include:

- Store ID
- Business date
- Physical table ID
- Table session ID
- Waiting session ID, where applicable
- Preorder/order/payment/KDS references, where applicable
- Guest/customer/party reference, where applicable
- Actor ID
- Event name
- Previous state
- New state
- Reason code
- Customer-facing status
- Timestamp
- Evidence record ID
- Support/incident/closeout reference, where applicable

## 24. Daily Closeout Procedure

At daily closeout, review:

- Active table sessions
- Table sessions closing
- Closed table sessions
- Table sessions with unresolved payment status
- Table sessions with unresolved KDS status
- Table reassignment records
- Table merge/split records
- Lost preorder or order linkage
- Support cases tied to table sessions
- Privacy-sensitive table issues
- Staff corrections
- Manager approvals
- Evidence gaps

Closeout result must classify:

- Clean
- Exception Close
- Carry-Forward
- Blocked

A table session exception must not be closed without owner or evidence.

## 25. Blocking Conditions

Table flow must be paused, restricted, or escalated when:

- Table QR opens wrong session
- Preorder links to wrong table
- Order attaches to wrong party/table
- Payment state is lost during reassignment
- Table merge/split creates financial ambiguity
- KDS ticket loses table/order context
- Customer-facing table status contradicts Store Runtime
- Staff cannot reconstruct table movement
- Privacy exposure is suspected
- Daily closeout cannot reconstruct table exceptions

Blocking conditions must route to risk register.

## 26. Training Checklist

Staff training must cover:

- Physical table vs table session distinction
- Waiting-to-table linkage
- Preorder-to-table linkage
- Order/payment/KDS table linkage
- Table reassignment
- Table merge
- Table split
- Table session close
- Staff correction rules
- Manager escalation
- Support handoff
- Privacy-sensitive table issues
- Customer-facing wording
- Evidence importance
- Daily closeout review

Training must include at least one normal seating flow and one exception table movement flow.

## 27. Acceptance Criteria

This SOP is accepted when:

- Table availability review procedure is defined
- Table candidate selection procedure is defined
- Table session creation procedure is defined
- Waiting-to-table transition is defined
- Preorder-to-table linkage is defined
- Order-to-table linkage is defined
- Payment-sensitive table context is defined
- KDS/kitchen linkage is defined
- Table reassignment procedure is defined
- Table merge procedure is defined
- Table split procedure is defined
- Table session close procedure is defined
- Staff correction procedure is defined
- Manager escalation criteria are defined
- Support handoff criteria are defined
- Privacy-sensitive issue handling is defined
- Evidence requirements are traceable
- Daily closeout procedure is defined
- Blocking conditions are documented
- Training checklist is included

## 28. Related Documents

Related document families include:

- Table matching table session preorder link service context policy
- Waiting queue call no-show recovery SOP
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
- KDS kitchen ticket policy
- POS Gateway handoff policy
- Finance reconciliation handoff policy

## 29. Final Rule

A table is furniture.  
A table session is operational truth.

Every table assignment, preorder link, order link, payment state, KDS ticket, reassignment, merge, split, support case, and closeout decision must remain tied to a traceable table session with evidence.

This SOP defines how staff operate table context without losing customer, order, kitchen, payment, or support truth.