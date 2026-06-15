# 14166_WorkPackage_Store_Runtime_Customer_Dispute_Complaint_Compensation_Support_Handoff_And_Evidence_Control

## 1. Purpose

This WorkPackage defines the Store Runtime customer dispute, complaint, compensation, support handoff, and evidence control boundary.

The purpose is to ensure that customer complaints and disputes are not handled only by staff memory, verbal apology, ad-hoc refund, or disconnected customer support notes.

In a live store, customer disputes may involve waiting, table matching, kiosk failure, payment uncertainty, duplicate charge, wrong order, kitchen delay, sold-out conflict, refund/cancel failure, staff correction, manager override, or POS Gateway mismatch.

This WorkPackage defines how Store Runtime captures, classifies, routes, resolves, and evidences customer-facing disputes and support cases.

## 2. Scope

This WorkPackage covers:

- Customer dispute intake boundary
- Complaint classification
- Store staff and manager response boundary
- Payment-related dispute control
- Order and kitchen-related dispute control
- Waiting/table/kiosk-related dispute control
- Compensation and goodwill action boundary
- Refund/cancel support handoff
- Customer support case creation
- Evidence preservation
- Daily closeout and finance handoff impact

This WorkPackage does not define full customer support platform implementation, final compensation policy, loyalty point policy, legal dispute handling, or enterprise CRM design.

## 3. Baseline Dependency

This WorkPackage depends on:

`14161_WorkPackage_Store_Runtime_Integration_Control_Tower_And_Operational_Command_Boundary.md`

`06410_WorkPackage_Store_Runtime_Customer_Session_Waiting_Preorder_Table_Matching_And_Order_State_Control.md`

`14162_WorkPackage_Store_Runtime_Kiosk_Mini_Kiosk_Device_Session_Order_Assist_And_Customer_Flow_Control.md`

`14163_WorkPackage_Store_Runtime_Staff_Tablet_Manager_Console_Override_Manual_Control_And_Evidence_Boundary.md`

`06440_WorkPackage_Store_Runtime_KDS_Kitchen_Ticket_Preparation_Remake_Ready_Served_And_Manual_Kitchen_Continuity.md`

`14164_WorkPackage_Store_Runtime_Daily_Closeout_End_Of_Day_Evidence_Exception_Carry_Forward_And_Manager_Approval.md`

`14165_WorkPackage_Store_Runtime_Finance_Reconciliation_Accounting_Settlement_Handoff_And_Exception_Control.md`

`06470_WorkPackage_Store_Runtime_Inventory_Soldout_Menu_Availability_Kitchen_Production_Signal_And_Exception_Control.md`

06470 defines live availability and production signals.  
This document defines how customer-facing disputes and complaints are controlled when store runtime promises fail, become unclear, or require support follow-up.

## 4. Core Principle

A customer dispute is not just a complaint.

It is a runtime exception that may affect customer trust, financial correctness, kitchen execution, staff accountability, legal evidence, and brand reputation.

The system must answer:

1. What did the customer claim?
2. Which session, order, payment, table, kiosk, staff action, or kitchen ticket is involved?
3. What did the system believe at the time?
4. What did the customer see?
5. What did staff or manager do?
6. Was compensation, refund, remake, cancellation, or apology offered?
7. Is finance or reconciliation affected?
8. Is support follow-up required?
9. Is the dispute resolved, rejected, carried forward, or escalated?

No customer dispute may be resolved by silently changing operational or financial state without evidence.

## 5. Dispute Families

Customer disputes must be grouped into families.

| Dispute Family | Meaning |
|---|---|
| Waiting Dispute | Queue, call, no-show, seating, or table matching issue |
| Order Dispute | Wrong item, missing item, option error, duplicate order, or order not found |
| Payment Dispute | Duplicate charge, failed confirmation, refund missing, payment uncertainty |
| Kiosk Dispute | Customer-facing device showed confusing or incorrect state |
| Kitchen Dispute | Delay, wrong preparation, remake, readiness, served/pickup issue |
| Availability Dispute | Item was shown available but could not be prepared or sold |
| Staff Handling Dispute | Staff action, explanation, correction, or service issue |
| Compensation Dispute | Coupon, refund, remake, goodwill, or promised benefit issue |
| Support Follow-Up Dispute | Case requires post-store customer support handling |
| Compliance-Sensitive Dispute | Legal, safety, privacy, payment, or audit-sensitive issue |

A dispute may belong to more than one family.

## 6. Dispute Intake Boundary

A dispute may be created from:

- Staff Tablet
- Manager Console
- Customer web app
- Kiosk or Mini Kiosk assist flow
- POS/payment exception
- KDS/kitchen exception
- Daily closeout review
- Finance reconciliation review
- Customer support channel
- Manual manager note
- Incident register escalation

Dispute intake must capture:

- Customer claim
- Store ID
- Business date
- Time of claim
- Intake channel
- Staff or manager actor, if applicable
- Customer/session/order/payment reference, if known
- Urgency
- Initial classification
- Customer-facing status
- Evidence links available at intake

Dispute intake must not require perfect information before a case can be opened.

## 7. Dispute Identity Boundary

A customer dispute must preserve separate references.

Possible references include:

- Dispute ID
- Customer account ID
- Guest session ID
- Waiting session ID
- Table session ID
- Order ID
- Payment attempt ID
- POS Gateway reference
- Refund/cancel reference
- Kiosk device session ID
- KDS ticket ID
- Staff actor ID
- Manager approval ID
- Incident ID
- Daily closeout ID
- Finance exception ID

The dispute ID must not replace the order, payment, incident, or support case ID.

## 8. Dispute Severity Model

Customer disputes must be classified by severity.

| Severity | Description | Example |
|---|---|---|
| CD-1 | High-risk financial, legal, safety, or major customer impact | Customer charged twice and order failed |
| CD-2 | Material customer impact requiring manager or support follow-up | Wrong order served and refund/remake needed |
| CD-3 | Operational complaint with limited financial impact | Kitchen delay complaint |
| CD-4 | Low-risk feedback or service improvement note | Customer says wording was confusing |

Payment uncertainty, duplicate charge, safety issue, and privacy issue must not be treated as low-risk feedback.

## 9. Waiting And Table Dispute Control

Waiting and table disputes may include:

- Customer says they were skipped
- Customer missed call due to unclear notification
- No-show was incorrectly applied
- Table was assigned to wrong party
- Preorder was not linked to table
- Staff manually changed party order
- Customer arrived but session expired
- Customer was seated but order context did not follow

Resolution may require:

- Staff correction
- Manager approval
- Session recovery
- No-show reversal
- Table reassignment
- Customer explanation
- Support follow-up

All corrections must preserve before/after state.

## 10. Order Dispute Control

Order disputes may include:

- Wrong item ordered
- Wrong item prepared
- Missing item
- Duplicate order
- Order not found
- Customer submitted order but store did not receive it
- POS accepted order but customer saw failure
- Customer saw confirmation but POS/KDS state is missing
- Staff corrected order incorrectly

Order disputes must be linked to order-state evidence, POS Gateway state, KDS state, staff correction history, and customer-visible status where available.

## 11. Payment Dispute Control

Payment disputes are high-risk and must follow payment uncertainty and finance handoff rules.

Payment disputes may include:

- Duplicate charge claim
- Customer says payment succeeded but order failed
- Customer says refund was not received
- Customer says cancelled order was charged
- Payment terminal showed success but app/kiosk showed failure
- POS Gateway timeout occurred after payment attempt
- Settlement evidence does not match customer claim
- Staff manually verified payment without formal evidence

Payment disputes must not be closed without payment or reconciliation evidence.

## 12. Kiosk And Device Dispute Control

Kiosk/device disputes may include:

- Kiosk froze during payment
- Kiosk showed wrong status
- Mini Kiosk translation caused confusion
- Customer submitted twice due to unclear loading state
- Device session expired during order/payment
- Customer saw sold-out after payment attempt
- Customer saw confirmation but staff could not find order
- Staff assisted kiosk flow but action was not recorded

Device disputes must link to device session, customer-visible status, order/payment reference, and staff assist evidence.

## 13. Kitchen And Service Dispute Control

Kitchen/service disputes may include:

- Order delayed
- Food not prepared
- Wrong item prepared
- Wrong option applied
- Remake required
- Ready state shown too early
- Staff marked served but customer did not receive order
- KDS ticket missing or duplicated
- Manual kitchen note was unclear
- Item unavailable after order acceptance

Kitchen disputes must link to KDS ticket, kitchen state, staff action, manager approval, and remake/refund/cancel decision where applicable.

## 14. Availability Dispute Control

Availability disputes may include:

- Customer ordered item that later became unavailable
- Kiosk showed item available but kitchen could not prepare it
- Option sold out was not reflected in customer channel
- Staff sold restricted item without approval
- Manager restored item incorrectly
- Customer was offered substitution without clear consent
- Sold-out state changed after customer confirmation

Availability disputes must link to availability state history, channel, service mode, staff action, manager override, and affected order.

## 15. Staff And Manager Response Boundary

Staff may:

- Intake complaint
- Apologize using approved wording
- Record claim
- Attach customer/session/order reference
- Escalate to manager
- Request remake or correction where allowed
- Provide non-financial explanation
- Mark customer-facing follow-up required

Manager may:

- Approve compensation
- Approve refund/cancel exception
- Resolve service dispute
- Reclassify severity
- Assign support owner
- Approve financial hold
- Close or carry forward dispute
- Attach final resolution note

Staff must not independently promise refund, compensation, or final payment resolution unless policy explicitly allows it.

## 16. Compensation Boundary

Compensation actions may include:

- Apology only
- Remake
- Replacement item
- Discount
- Coupon
- Loyalty point adjustment
- Partial refund
- Full refund
- Manual goodwill benefit
- Support follow-up promise

Compensation must be controlled by authority and evidence.

Compensation record must include:

- Compensation type
- Reason
- Customer/session/order/payment reference
- Actor
- Manager approval, if required
- Financial impact
- Whether refund/cancel path is involved
- Whether customer accepted resolution
- Whether support follow-up remains open

Compensation must not be confused with refund.

## 17. Refund And Cancel Support Handoff

When dispute resolution requires refund or cancellation, Store Runtime must route through controlled refund/cancel paths.

Support handoff must include:

- Customer claim
- Original order
- Original payment
- Refund/cancel request
- Approval status
- Provider response
- POS Gateway response
- Settlement impact
- Customer-facing message
- Evidence link
- Owner

Support must not be asked to resolve a refund case without operational and payment evidence.

## 18. Customer-Facing Status Boundary

Customer-facing dispute status must be conservative.

Possible statuses include:

| Status | Meaning |
|---|---|
| Received | Claim has been recorded |
| Checking | Staff or manager is reviewing |
| Payment Review | Payment/reconciliation check required |
| Store Review | Store operation evidence is being checked |
| Support Follow-Up | Case is routed beyond store operation |
| Resolved | Resolution completed and evidenced |
| Rejected | Claim not accepted with reason |
| Carried Forward | Case remains open after closeout |

Customer-facing status must not reveal sensitive internal blame, staff notes, provider credentials, or audit-only information.

## 19. Support Handoff Boundary

A dispute must be handed to support when:

- Case cannot be resolved in store
- Customer requests post-visit follow-up
- Payment/reconciliation review is required
- Compensation requires non-store processing
- Customer account or loyalty action is required
- Legal/privacy/safety sensitivity exists
- Provider investigation is required
- Manager cannot close before daily closeout

Support handoff must include enough evidence to avoid asking the customer to repeat everything.

## 20. Daily Closeout Impact

Daily closeout must review open disputes.

Closeout must classify disputes as:

- Resolved before closeout
- Resolved with compensation
- Rejected with reason
- Support follow-up required
- Payment/reconciliation hold
- Customer dispute carry-forward
- Compliance-sensitive escalation
- Missing evidence issue

A store day must not be marked Clean Close when material unresolved payment or customer dispute cases exist.

## 21. Finance And Reconciliation Impact

Customer disputes may affect finance when they involve:

- Refund
- Cancel
- Duplicate charge
- Payment uncertainty
- Compensation with financial value
- Loyalty credit
- Manual POS correction
- Settlement mismatch
- Chargeback or payment provider inquiry
- Customer claim of non-service after payment

Finance handoff must receive dispute references when financial state may be affected.

## 22. Evidence Requirements

The system must preserve evidence for:

- Dispute creation
- Customer claim
- Intake channel
- Staff response
- Manager response
- Customer/session/order/payment linkage
- Kiosk/device status, where applicable
- KDS/kitchen status, where applicable
- Availability state, where applicable
- Payment/reconciliation state, where applicable
- Compensation decision
- Refund/cancel handoff
- Support handoff
- Final resolution
- Rejection reason
- Carry-forward owner

Evidence must include:

- Store ID
- Business date
- Timestamp
- Actor ID
- Customer or guest reference, where available
- Affected entity references
- Dispute family
- Severity
- Status
- Resolution
- Evidence links

## 23. Integrated Pilot Requirements

This WorkPackage may enter integrated pilot only when:

- Dispute families are defined
- Dispute intake boundary is defined
- Dispute identity references are defined
- Severity model is defined
- Waiting/table dispute rules are defined
- Order dispute rules are defined
- Payment dispute rules are defined
- Kiosk/device dispute rules are defined
- Kitchen/service dispute rules are defined
- Availability dispute rules are defined
- Staff and manager response authority is defined
- Compensation boundary is defined
- Support handoff requirements are defined
- Daily closeout and finance impact rules are defined
- Evidence fields are defined

## 24. Acceptance Criteria

This WorkPackage is accepted when:

- Customer disputes are treated as runtime exceptions, not informal notes
- Payment disputes cannot be closed without evidence
- Staff and manager response authority is separated
- Compensation is distinguished from refund
- Support handoff includes operational and payment context
- Daily closeout reviews open disputes
- Finance handoff receives financial-impact dispute references
- Customer-facing dispute status is conservative
- Evidence requirements are traceable
- Open risks are routed to backlog, waiver, or blocker register

## 25. Out of Scope

This WorkPackage does not include:

- Full customer support CRM implementation
- Final compensation amount policy
- Final coupon or loyalty point engine
- Chargeback platform integration
- Legal claim handling workflow
- Privacy incident response workflow
- Full customer sentiment analytics
- Marketing review management

Those must be handled in support, finance, compliance, legal, loyalty, or marketing lanes.

## 26. Related Documents

Related document families include:

- Store Runtime Control Tower WorkPackage
- Customer session and order-state control WorkPackage
- Kiosk and Mini Kiosk runtime WorkPackage
- Staff Tablet and Manager Console WorkPackage
- KDS kitchen execution WorkPackage
- Daily closeout WorkPackage
- Finance reconciliation handoff WorkPackage
- Inventory and availability control WorkPackage
- Payment uncertainty policy
- Refund and cancel policy
- Manager override governance
- Runtime evidence policy
- Incident register template
- Customer support handoff policy

## 27. Final Rule

A customer dispute is a test of whether Store Runtime can prove what happened.

The system must preserve the customer claim, the operational truth, the financial state, the staff response, the manager decision, the support handoff, and the final resolution.

This WorkPackage defines the dispute and support handoff boundary before customer support, compensation, legal, and rollout expansion lanes consume store runtime evidence.