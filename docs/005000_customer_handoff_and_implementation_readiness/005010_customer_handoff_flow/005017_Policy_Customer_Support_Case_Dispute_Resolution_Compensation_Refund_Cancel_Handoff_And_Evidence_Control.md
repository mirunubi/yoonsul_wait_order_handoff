# 005007_Policy_Customer_Support_Case_Dispute_Resolution_Compensation_Refund_Cancel_Handoff_And_Evidence_Control

## 1. Purpose

This policy defines the customer support case, dispute resolution, compensation, refund/cancel handoff, and evidence control boundary.

The purpose is to ensure that customer support does not become disconnected from Store Runtime, waiting state, table session, order state, payment state, POS Gateway, KDS, membership benefit, finance handoff, and daily closeout evidence.

Customer support is not only a post-visit communication layer.  
It is the controlled continuation of customer-facing exceptions that could not be safely resolved inside the store runtime.

This policy defines how support cases must be created, classified, linked, resolved, escalated, compensated, and evidenced.

## 2. Scope

This policy covers:

- Customer support case creation
- Dispute resolution boundary
- Store-to-support handoff
- Support-to-finance handoff
- Refund/cancel support routing
- Compensation and goodwill control
- Membership/loyalty support adjustment
- Payment uncertainty support handling
- Customer communication status
- Case closure and carry-forward
- Evidence requirements

This policy does not define full CRM implementation, legal claim handling, chargeback platform integration, privacy incident response, or final compensation amount policy.

## 3. Baseline Dependency

This policy depends on:

`014166_WorkPackage_Store_Runtime_Customer_Dispute_Complaint_Compensation_Support_Handoff_And_Evidence_Control.md`

`014165_WorkPackage_Store_Runtime_Finance_Reconciliation_Accounting_Settlement_Handoff_And_Exception_Control.md`

`005005_Policy_Customer_Account_Guest_Merge_Identity_Continuity_Membership_Ready_And_Runtime_Authority_Boundary.md`

`005006_Policy_Customer_Membership_Loyalty_Coupon_Visit_Count_Store_Benefit_And_Runtime_Control.md`

06480 defines the Store Runtime dispute and support handoff boundary.  
06590 defines membership, loyalty, coupon, and benefit impact.  
This document defines the support case policy that consumes those handoffs.

## 4. Core Principle

A customer support case must preserve what happened before support became involved.

The system must answer:

1. What did the customer claim?
2. Which store, business date, session, order, payment, table, KDS ticket, coupon, or staff action is involved?
3. What did Store Runtime believe at the time?
4. What did the customer see?
5. What did staff or manager do?
6. Is payment, refund, cancel, benefit, or compensation involved?
7. Is finance or reconciliation review required?
8. Is legal, privacy, safety, or compliance sensitivity present?
9. What resolution was offered?
10. What evidence supports closure?

Support must not rely only on customer retelling or staff memory.

## 5. Support Case Families

Support cases must be grouped into families.

| Case Family | Meaning |
|---|---|
| Waiting Case | Queue, call, no-show, arrival, or seating issue |
| Table Case | Table assignment, table movement, table session, or service context issue |
| Order Case | Wrong order, missing item, duplicate order, failed order, or order not found |
| Payment Case | Payment uncertainty, duplicate charge, refund/cancel, or settlement-related issue |
| Kiosk/App Case | Web app, native app, kiosk, mini kiosk, link, token, or push issue |
| Kitchen Case | Delay, remake, wrong item, ready/served, or KDS issue |
| Availability Case | Sold-out, unavailable item, substitution, or menu availability issue |
| Membership Case | Coupon, loyalty, visit count, benefit, or account claim issue |
| Compensation Case | Goodwill, coupon, refund, replacement, or service recovery issue |
| Compliance-Sensitive Case | Legal, privacy, safety, payment, or audit-sensitive issue |

A support case may belong to multiple families.

## 6. Support Case Identity Boundary

A support case must preserve separate references.

Possible references include:

- Support case ID
- Customer account ID
- Guest identity reference
- Waiting session ID
- Table session ID
- Order ID
- Payment attempt ID
- POS Gateway reference
- Refund/cancel reference
- Kiosk or web app session ID
- Native app session ID
- KDS ticket ID
- Coupon or benefit ID
- Staff actor ID
- Manager approval ID
- Incident ID
- Finance exception ID
- Daily closeout ID

The support case ID must not replace operational, payment, finance, or membership references.

## 7. Case Creation Boundary

A support case may be created from:

- Customer web app
- Native app
- Staff tablet
- Manager console
- Kiosk or mini kiosk recovery flow
- Customer dispute intake
- Incident workflow
- Daily closeout
- Finance reconciliation review
- Membership/benefit review
- Manual support channel
- Compliance or audit review

Case creation must capture:

- Customer claim or issue summary
- Intake channel
- Store ID, where applicable
- Business date, where applicable
- Customer or guest reference
- Affected session/order/payment/benefit references
- Initial case family
- Initial severity
- Intake actor, if any
- Customer-facing status
- Evidence links available at intake

Case creation must be allowed even when some references are unknown, but unresolved identity or payment references must remain visible.

## 8. Case Severity Model

Support cases must be classified by severity.

| Severity | Meaning | Example |
|---|---|---|
| CS-SEV-1 | High-risk financial, legal, safety, privacy, or severe trust impact | Duplicate charge claim with unclear payment state |
| CS-SEV-2 | Material customer impact requiring owner follow-up | Wrong order and refund/remake dispute |
| CS-SEV-3 | Normal support issue with limited risk | Coupon did not appear as expected |
| CS-SEV-4 | Low-risk feedback or improvement note | Customer says wording was confusing |

Payment uncertainty, duplicate charge, privacy issue, safety issue, and unresolved refund/cancel issue must not be classified as low-risk without evidence.

## 9. Store-To-Support Handoff

Store-to-support handoff is required when:

- Store cannot resolve customer claim during visit
- Payment or reconciliation evidence is needed
- Refund/cancel requires follow-up
- Compensation requires support processing
- Customer account or membership adjustment is needed
- Customer dispute remains open at daily closeout
- Incident affects customer trust
- Manager cannot close case with available authority
- Customer requests later follow-up

Store-to-support handoff must include:

- Store manager note
- Staff action history
- Customer-facing message history, where available
- Order/payment/table/KDS references
- Payment uncertainty marker, if any
- Refund/cancel marker, if any
- Compensation request, if any
- Evidence packet links
- Owner recommendation
- Urgency

Support must not receive only a free-text complaint with no runtime context.

## 10. Support-To-Finance Handoff

Support-to-finance handoff is required when a case affects:

- Refund
- Cancel
- Duplicate charge claim
- Payment uncertainty
- Settlement mismatch
- Manual POS entry
- Coupon or benefit financial value
- Compensation with financial impact
- Customer chargeback or payment provider inquiry
- Accounting hold

Support-to-finance handoff must include:

- Support case ID
- Customer claim
- Order/payment references
- Refund/cancel request
- POS Gateway references
- Finance exception reference, where available
- Evidence links
- Customer communication status
- Requested finance action
- Owner and due condition

Finance must not be asked to act without support case context.

## 11. Payment Case Control

Payment cases are high-risk.

Payment cases may include:

- Customer claims duplicate charge
- Customer says payment succeeded but order failed
- Customer says refund did not arrive
- Customer says cancelled order was charged
- Customer says app/kiosk showed wrong payment state
- Provider timeout occurred during payment
- POS Gateway result and customer claim conflict
- Settlement data does not match expected runtime state

Payment case closure requires payment/reconciliation evidence or documented owner-approved decision.

Support must not close a payment case merely because the customer stopped responding if financial uncertainty remains.

## 12. Refund And Cancel Case Control

Refund and cancel support cases must distinguish:

- Cancel request
- Cancel approval
- Refund request
- Refund approval
- Refund pending
- Refund failed
- Partial refund
- Full refund
- Coupon/benefit restoration
- Visit count adjustment
- Customer communication completion

A cancelled order does not automatically mean a refund was completed.  
A refund does not automatically mean the kitchen/order/service state was cancelled cleanly.

Support case must preserve both operational and financial truth.

## 13. Compensation Case Control

Compensation may include:

- Apology only
- Replacement item
- Remake
- Discount
- Coupon
- Loyalty point adjustment
- Visit count adjustment
- Partial refund
- Full refund
- Goodwill benefit
- Manager-approved exception
- Support-approved exception

Compensation must record:

- Compensation type
- Reason
- Authority
- Financial impact
- Customer acceptance, where applicable
- Order/payment/benefit reference
- Whether refund/cancel is separate
- Whether finance handoff is required
- Evidence link

Compensation must not be hidden as normal loyalty accrual.

## 14. Membership And Benefit Support Control

Membership or benefit cases may include:

- Coupon missing
- Coupon not applied
- Coupon consumed incorrectly
- Coupon not restored after failed payment
- Visit count missing
- Benefit attached to wrong account
- Guest order claim failed
- Duplicate account benefit issue
- Staff promised coupon or benefit
- Compensation coupon not received

Support must link benefit cases to:

- Customer account
- Guest identity
- Coupon/benefit reference
- Order/payment reference
- Store/business date
- Customer-facing benefit display
- Staff/manager/support adjustment history

Manual benefit adjustment requires authority and evidence.

## 15. Customer Communication Boundary

Support communication must be conservative and evidence-aligned.

Customer-facing support statuses may include:

| Status | Meaning |
|---|---|
| Received | Case has been received |
| Checking | Support is reviewing |
| Store Review | Store operation evidence is being checked |
| Payment Review | Payment or reconciliation review is needed |
| Finance Review | Finance action or confirmation is needed |
| Benefit Review | Membership/coupon/benefit state is being checked |
| Waiting For Customer | Customer response is needed |
| Resolved | Case resolution is complete |
| Rejected | Claim was not accepted with reason |
| Carried Forward | Case remains open under assigned owner |

Support must not promise refund, compensation, coupon restoration, or payment conclusion before the relevant owner confirms it.

## 16. Case Owner Assignment

Every active support case must have an owner.

Possible owners include:

- Store Manager
- Customer Support Owner
- Payment/Reconciliation Owner
- Finance Owner
- Membership/Loyalty Owner
- POS Gateway Runtime Owner
- KDS/Kitchen Owner
- Compliance/Audit Owner
- Legal/Privacy Owner, where applicable
- Provider Contact Owner

Owner assignment must be visible and updated when the case moves between domains.

## 17. Case Status Lifecycle

Support case states may include:

| State | Meaning |
|---|---|
| Created | Case has been opened |
| Intake Review | Case is being classified |
| Evidence Gathering | Runtime/support evidence is being collected |
| Store Review | Store manager or operation owner must respond |
| Finance Review | Financial or payment review is required |
| Benefit Review | Membership/coupon review is required |
| Customer Response Needed | Waiting for customer input |
| Resolution Proposed | Resolution is ready for customer or approval |
| Resolved | Case resolved with evidence |
| Rejected | Claim rejected with reason |
| Escalated | Higher-level owner required |
| Carried Forward | Case remains open after closeout |
| Closed | Case is complete and no further action is expected |
| Reopened | Case reopened due to new claim or evidence |

Case closure must not erase history.

## 18. Case Closure Rules

A support case may be closed only when:

- Customer claim is documented
- Required evidence is reviewed or missing evidence is explicitly recorded
- Financial impact is resolved or handed to owner
- Refund/cancel status is final or owner-assigned
- Compensation decision is recorded
- Customer-facing response is completed or not required by policy
- Membership/benefit adjustments are completed, rejected, or assigned
- Compliance-sensitive issues are escalated where needed
- Closure reason is recorded

Payment, privacy, legal, and safety-sensitive cases may require additional approval before closure.

## 19. Reopen Rules

A case may be reopened when:

- Customer disputes resolution
- Payment evidence changes
- Refund/cancel fails after promised status
- Benefit restoration fails
- Store discovers new evidence
- Finance finds mismatch
- Provider response contradicts prior assumption
- Customer provides new proof
- Legal/compliance review requires action

Reopen must preserve previous closure state and reason.

## 20. Daily Closeout Impact

Daily closeout must review store-origin support cases.

Closeout should include:

- Cases created today
- Cases resolved today
- Cases carried forward
- Payment-related cases
- Refund/cancel cases
- Compensation cases
- Membership/benefit cases
- Incident-linked cases
- Missing evidence cases
- Owner assignment status

A Clean Close must not be declared when material customer support cases remain unresolved without owner assignment.

## 21. Finance And Accounting Impact

Support cases may affect finance/accounting when they involve:

- Refund
- Cancel
- Compensation
- Coupon/benefit financial value
- Manual adjustment
- Duplicate charge
- Payment uncertainty
- Settlement mismatch
- Customer dispute hold
- Chargeback risk

Finance handoff must receive support case references when financial state is affected.

## 22. Compliance And Privacy Boundary

Support cases may contain sensitive information.

Support views must protect:

- Customer identity
- Contact information
- Payment references
- Staff notes
- Internal incident classification
- Audit-only evidence
- Provider references
- Legal/privacy-sensitive claims

Support evidence access must be role-scoped.

Compliance-sensitive cases must be escalated to the appropriate owner.

## 23. Evidence Requirements

The system must preserve evidence for:

- Case creation
- Customer claim
- Intake classification
- Case severity
- Case owner assignment
- Store-to-support handoff
- Support-to-finance handoff
- Payment review
- Refund/cancel review
- Compensation decision
- Benefit adjustment
- Customer communication
- Staff/manager response
- Evidence review
- Missing evidence marker
- Case resolution
- Case rejection
- Case closure
- Case reopen
- Carry-forward owner assignment

Evidence must include:

- Support case ID
- Customer or guest reference
- Store ID, where applicable
- Business date, where applicable
- Order/payment/table/KDS/benefit references where applicable
- Actor ID
- Owner
- Timestamp
- Before state
- After state
- Reason
- Customer-facing status
- Related incident/finance/closeout reference where applicable

Sensitive evidence must be protected by role and purpose.

## 24. Acceptance Criteria

This policy is accepted when:

- Support cases preserve Store Runtime context
- Store-to-support handoff includes operational evidence
- Support-to-finance handoff includes financial context
- Payment cases cannot be closed without evidence or owner-approved decision
- Refund and cancel are distinguished
- Compensation is distinguished from refund and normal loyalty
- Membership and benefit cases link to account and order/payment evidence
- Customer communication status is conservative
- Active cases require owner assignment
- Case closure and reopen rules are defined
- Daily closeout reviews support cases
- Finance handoff receives financial-impact case references
- Compliance and privacy boundaries are documented
- Evidence requirements are traceable

## 25. Out of Scope

This policy does not include:

- Full CRM implementation
- Call center tooling
- Chatbot automation
- Chargeback platform integration
- Legal claim workflow
- Privacy incident response program
- Final compensation amount matrix
- Full coupon engine implementation
- Full accounting ledger implementation

Those must be handled in CRM, support tooling, finance, legal, privacy, loyalty, or accounting lanes.

## 26. Related Documents

Related document families include:

- Customer dispute and support handoff WorkPackage
- Finance reconciliation handoff WorkPackage
- Customer account and guest merge policy
- Membership loyalty coupon benefit policy
- Customer notification and multilingual guidance policy
- Customer web app runtime policy
- Customer native app runtime policy
- Payment uncertainty policy
- Refund and cancel policy
- Runtime evidence policy
- Privacy and data retention policy
- Daily closeout WorkPackage

## 27. Final Rule

Support is where unresolved customer-facing truth is carried forward.

A support case must preserve the customer claim, the store runtime state, the payment and benefit impact, the staff and manager actions, the finance handoff, the customer communication, and the evidence needed to close the matter safely.

This policy defines the support case boundary before CRM, legal, finance, loyalty, and customer success systems expand the customer support layer.