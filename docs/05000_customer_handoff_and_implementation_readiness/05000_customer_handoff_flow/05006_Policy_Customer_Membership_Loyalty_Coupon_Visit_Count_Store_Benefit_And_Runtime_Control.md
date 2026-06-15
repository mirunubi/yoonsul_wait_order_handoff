# 05006_Policy_Customer_Membership_Loyalty_Coupon_Visit_Count_Store_Benefit_And_Runtime_Control

## 1. Purpose

This policy defines the customer membership, loyalty, coupon, visit count, store benefit, and runtime control boundary.

The purpose is to ensure that membership and loyalty benefits do not interfere with Store Runtime truth, payment correctness, refund/cancel handling, customer identity continuity, finance handoff, support dispute handling, or store operation.

Membership is not merely a marketing layer.  
It can affect price, coupon eligibility, visit count, customer expectation, refund adjustment, compensation, dispute handling, and future store-specific benefit rules.

This policy defines how membership and loyalty must attach to customer account, guest-origin order, store session, order, payment, refund, support, and evidence records without creating financial or operational ambiguity.

## 2. Scope

This policy covers:

- Membership runtime boundary
- Loyalty-ready customer account linkage
- Coupon and benefit eligibility
- Visit count and store-specific benefit tracking
- Guest order claim and benefit attachment
- Coupon use in order/payment flow
- Refund/cancel impact on benefits
- Compensation and goodwill benefit distinction
- Store-specific benefit rules
- Support and dispute impact
- Evidence requirements

This policy does not define final membership tier names, final loyalty point calculation, marketing campaign design, coupon UI, tax treatment, or full CRM implementation.

## 3. Baseline Dependency

This policy depends on:

`05003_Policy_Customer_Web_App_Guest_Session_App_Native_Continuity_Order_Surface_And_Runtime_Control.md`

`05004_Policy_Customer_Native_App_Deep_Link_Push_Account_Continuity_Web_App_Coexistence_And_Runtime_Control.md`

`05005_Policy_Customer_Account_Guest_Merge_Identity_Continuity_Membership_Ready_And_Runtime_Authority_Boundary.md`

06580 defines the customer account, guest merge, identity continuity, and membership-ready boundary.  
This document defines how membership, loyalty, coupon, and benefit rules may safely operate on top of that identity model.

## 4. Core Principle

Membership benefits must be derived from controlled runtime truth.

The system must distinguish:

1. Customer account exists
2. Customer is eligible for membership
3. Customer has a membership state
4. Customer has a store-specific benefit state
5. Customer has a coupon or reward
6. Customer applies a benefit to an order
7. Payment reflects benefit correctly
8. Refund/cancel adjusts benefit correctly
9. Visit count is earned or reversed correctly
10. Support or compensation modifies benefit with evidence

A benefit must not be granted, consumed, restored, reversed, or compensated without traceable evidence.

## 5. Membership Identity Boundary

Membership identity must link to customer account, but must remain distinct from live store sessions.

Membership-related identity may include:

- Customer account ID
- Membership profile ID
- Store-specific benefit profile
- Loyalty wallet
- Coupon wallet
- Visit count record
- Benefit eligibility record
- Consent record
- Support adjustment record
- Fraud or abuse review marker

Membership identity must not replace:

- Guest session
- Waiting session
- Table session
- Order ID
- Payment reference
- Refund/cancel reference
- Support case
- Incident record

## 6. Membership State Families

Membership state must be grouped into families.

| State Family | Meaning |
|---|---|
| Enrollment State | Whether customer is enrolled or eligible |
| Tier State | Customer membership level, if applicable |
| Point State | Loyalty point or equivalent balance, if applicable |
| Coupon State | Coupon issued, active, used, expired, restored, or voided |
| Visit Count State | Count of qualifying visits or orders |
| Store Benefit State | Store-specific benefit such as local visit coupon |
| Campaign State | Benefit linked to promotion, where applicable |
| Compensation State | Goodwill or support-issued benefit |
| Abuse Review State | Benefit use requires review |
| Consent State | Marketing/notification/data-use permission |

Each family must have separate lifecycle and evidence.

## 7. Enrollment Boundary

Membership enrollment may occur through:

- Customer web app
- Native app
- Customer account creation
- Post-order account claim
- Staff-assisted signup, where allowed
- Support-assisted account correction
- Campaign flow, where later approved

Enrollment must not be required for basic guest waiting, menu browse, or store order flow unless business policy changes.

Enrollment must capture:

- Customer account reference
- Enrollment source
- Timestamp
- Consent status, where required
- Terms acceptance marker, where required
- Notification preference
- Marketing preference, where applicable
- Initial membership state

Enrollment must not retroactively alter past orders unless claim rules allow it.

## 8. Guest Order Claim Boundary

A guest-origin order may later be claimed by a customer account.

Claim may be allowed when:

- Customer verifies session or receipt
- Customer opens valid scoped link
- Support validates claim
- Staff assists account attachment under policy
- Native app account opens a web-created guest session

Claim must preserve:

- Original guest session
- Order reference
- Payment reference, if any
- Business date
- Claim timestamp
- Claim method
- Account reference
- Benefit eligibility decision
- Evidence link

A claimed guest order must not automatically earn all benefits unless policy allows retroactive benefit application.

## 9. Visit Count Boundary

Visit count must be based on defined qualifying events.

Possible qualifying events include:

- Completed paid order
- Completed pickup
- Completed dine-in service
- Store-specific minimum spend
- Membership-linked order
- Claimed guest order, where allowed
- Event/campaign-qualified visit

Visit count must exclude or adjust for:

- Cancelled order
- Fully refunded order
- Duplicate order
- Failed payment
- Payment uncertainty
- Fraud/abuse review
- Staff test order
- Training order
- Voided order
- Non-qualifying compensation-only order

Visit count must not be based only on app open, QR scan, waiting session, or table assignment.

## 10. Store-Specific Benefit Boundary

Store-specific benefit rules may include:

- Visit N times at this store and receive coupon
- Store-only campaign reward
- Local repeat-customer benefit
- Store manager goodwill coupon, where allowed
- Franchise-specific benefit, where later governed

Store-specific benefits must define:

- Store scope
- Qualification rule
- Eligible customer/account
- Eligible order/payment condition
- Benefit amount or type
- Expiration
- Use restrictions
- Refund/cancel adjustment
- Evidence requirements

A store-specific benefit must not accidentally become global unless explicitly configured.

## 11. Coupon Lifecycle

Coupon states may include:

| State | Meaning |
|---|---|
| Draft | Coupon rule prepared but not issued |
| Issued | Coupon granted to customer/account |
| Active | Coupon may be used |
| Reserved | Coupon is temporarily held for an order attempt |
| Applied | Coupon applied to order calculation |
| Consumed | Coupon finalized after successful payment/order completion |
| Released | Coupon reservation released after failed attempt |
| Restored | Coupon restored after eligible cancel/refund/failure |
| Expired | Coupon no longer usable |
| Voided | Coupon invalidated by rule, abuse, or correction |
| Manual Review Required | Coupon state is ambiguous |

Coupon must not be consumed only because the customer tapped “use coupon.”  
Consumption should occur only when the qualifying order/payment state supports it.

## 12. Coupon Reservation And Release

Coupon reservation may be required to prevent duplicate use.

Reservation may occur when:

- Customer applies coupon to cart
- Customer submits preorder
- Payment attempt begins
- POS Gateway handoff begins
- Staff-assisted order applies coupon

Coupon must be released when:

- Order submission fails
- Payment fails
- Customer removes coupon before finalization
- Cart expires
- Payment uncertainty is resolved as failed
- Order is cancelled before coupon consumption
- Runtime rejects eligibility

Coupon must not remain stuck in reserved state without expiration and recovery rule.

## 13. Benefit Application Boundary

Benefit application must pass through controlled order calculation.

Benefit application must consider:

- Customer/account eligibility
- Guest claim eligibility
- Store scope
- Channel scope
- Service mode
- Menu/item eligibility
- Time window
- Coupon status
- Visit count status
- Existing discounts
- Payment method restrictions
- Tax or accounting marker, where applicable
- Abuse review marker
- Manager approval, where required

The customer-facing price must not diverge from POS/payment truth.

## 14. POS Gateway And Payment Impact

Membership benefits may affect:

- Discount amount
- Coupon applied amount
- Final payable amount
- Refund amount
- Cancel amount
- Settlement expectation
- Accounting marker
- Receipt display
- Customer dispute evidence

POS Gateway handoff must receive or preserve enough benefit context to reconcile:

- Original price
- Discount/benefit applied
- Final charged amount
- Coupon consumed/restored
- Refund/cancel adjustment
- Manual override, if any

Benefit application must not create payment mismatch.

## 15. Refund And Cancel Impact

Refund and cancel must adjust membership benefit state safely.

Cases include:

- Coupon used then order cancelled
- Coupon used then payment failed
- Coupon used then partial refund
- Coupon used then full refund
- Visit count earned then order refunded
- Compensation benefit granted after dispute
- Coupon restored due to system failure
- Coupon not restored due to customer cancellation rule

Refund/cancel impact must be explicit.

The system must decide whether to:

- Restore coupon
- Keep coupon consumed
- Reverse visit count
- Keep visit count
- Issue compensation
- Mark manual review
- Escalate to support/finance

## 16. Compensation And Goodwill Boundary

Compensation is not the same as normal membership benefit.

Compensation may include:

- Goodwill coupon
- Manual point adjustment
- Replacement benefit
- Apology coupon
- Service recovery reward
- Manager-approved benefit
- Support-issued benefit

Compensation must link to:

- Dispute or support case
- Order/payment reference, where applicable
- Manager/support approval
- Reason
- Financial impact
- Expiration
- Customer acceptance, where applicable
- Evidence

Compensation must not be hidden inside ordinary loyalty accrual.

## 17. Support And Dispute Impact

Membership and loyalty disputes may include:

- Coupon did not apply
- Coupon disappeared
- Coupon was not restored after failed payment
- Visit count missing
- Benefit attached to wrong account
- Guest order could not be claimed
- Refund reduced benefit unexpectedly
- Staff promised coupon
- App showed different benefit than store
- Store-specific benefit expected but not granted

Support cases must link to membership state history, order/payment state, account/guest identity, and customer-facing message evidence.

## 18. Abuse And Fraud Review

Abuse review may be required when:

- Repeated guest claims
- Repeated coupon reservation without purchase
- Duplicate account benefit use
- Shared QR/link used to claim benefits
- Refund/cancel pattern abuses reward
- Staff-issued compensation pattern is abnormal
- Visit count manipulation suspected
- Same payment/order claimed by multiple accounts
- Same support case used for repeated compensation

Abuse review must not block legitimate support recovery without owner review.

## 19. Staff And Manager Authority

Staff may:

- View limited membership status where needed
- Help customer find account
- Explain coupon status using safe wording
- Escalate benefit issue
- Request manager/support adjustment
- Attach customer claim to support case

Manager or support owner may:

- Approve goodwill coupon
- Approve manual benefit correction
- Approve visit count adjustment
- Approve coupon restoration
- Reject unsupported claim
- Escalate abuse review

Staff must not freely create, consume, restore, or adjust benefits without authority.

## 20. Customer-Facing Benefit Status

Customer-facing benefit status must be conservative.

| Internal State | Customer-Facing Boundary |
|---|---|
| Issued | Coupon has been issued |
| Active | Coupon is available |
| Reserved | Coupon is being applied |
| Applied | Coupon applied to this order |
| Consumed | Coupon used |
| Released | Coupon is available again |
| Restored | Coupon has been restored |
| Expired | Coupon has expired |
| Voided | Coupon is no longer available |
| Manual Review Required | Support is checking this benefit |

Customer-facing wording must not imply financial refund, order cancellation, or compensation unless those states are confirmed.

## 21. Daily Closeout And Finance Impact

Daily closeout and finance handoff must review material benefit exceptions.

Closeout may include:

- Coupon consumed
- Coupon restored
- Coupon stuck in reserved state
- Manual benefit adjustment
- Compensation issued
- Visit count adjustment
- Benefit-related customer dispute
- Benefit affecting payment amount
- Benefit causing POS/payment mismatch
- Manager-approved goodwill
- Abuse review marker

Finance handoff must receive benefit references when financial amount is affected.

## 22. Evidence Requirements

The system must preserve evidence for:

- Membership enrollment
- Consent capture or change
- Guest order claim
- Account-benefit linkage
- Visit count creation
- Visit count adjustment
- Coupon issuance
- Coupon reservation
- Coupon application
- Coupon consumption
- Coupon release
- Coupon restoration
- Coupon expiration
- Coupon void
- Benefit eligibility decision
- Benefit calculation
- Refund/cancel adjustment
- Compensation issuance
- Manual benefit adjustment
- Support/dispute linkage
- Abuse review marker
- Customer-facing benefit display

Evidence must include:

- Customer account reference
- Guest reference, where applicable
- Store ID, where applicable
- Business date, where applicable
- Order ID, where applicable
- Payment reference, where applicable
- Coupon/benefit reference
- Actor ID, where applicable
- Action
- Timestamp
- Before state
- After state
- Reason
- Approval reference, where applicable
- Related support/incident/finance reference where applicable

Sensitive customer data must not be exposed in benefit evidence views beyond role scope.

## 23. Acceptance Criteria

This policy is accepted when:

- Membership is treated as benefit continuity, not live store truth
- Guest order claim is controlled and evidenced
- Visit count is based on qualifying operational/payment events
- Store-specific benefit scope is explicit
- Coupon lifecycle is documented
- Coupon reservation and release are controlled
- Benefit application aligns with order/payment truth
- Refund/cancel benefit adjustment is defined
- Compensation is distinguished from normal loyalty benefit
- Support and dispute handling can review benefit history
- Abuse review markers are defined
- Staff and manager authority is separated
- Daily closeout and finance handoff can see material benefit exceptions
- Evidence requirements are traceable

## 24. Out of Scope

This policy does not include:

- Final membership tier names
- Final point earning formula
- Final coupon design
- Full marketing campaign system
- Full CRM implementation
- Full tax/accounting treatment
- Full fraud detection system
- Full legal terms drafting
- Final customer app UI

Those must be handled in membership, loyalty, marketing, CRM, finance, fraud, legal, or UI lanes.

## 25. Related Documents

Related document families include:

- Customer account and guest merge policy
- Customer web app runtime policy
- Customer native app runtime policy
- Customer notification and multilingual guidance policy
- Customer dispute and support handoff WorkPackage
- Finance reconciliation handoff WorkPackage
- Payment uncertainty policy
- Refund and cancel policy
- Runtime evidence policy
- Privacy and data retention policy
- Marketing consent policy

## 26. Final Rule

A benefit is a financial and trust-bearing promise.

Every membership status, coupon, visit count, store benefit, compensation, restoration, reversal, and dispute must remain linked to customer identity, order/payment truth, support context, finance impact, and evidence.

This policy defines the membership and loyalty runtime boundary before final tier design, coupon engine, CRM, marketing, and finance implementation expand the customer benefit layer.