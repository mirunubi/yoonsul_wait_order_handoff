# 006760_Matrix_Customer_Runtime_Display_Surface_Status_Action_Message_And_Evidence_Control_Matrix.md

## 1. Purpose

This matrix defines the Customer Runtime display surface, status, action, message, and evidence control structure.

The purpose is to ensure that every customer-facing surface displays only the allowed status, message, action, and guidance for the current runtime state.

Customer-facing display is not a cosmetic UI layer.  
It can imply waiting priority, table assignment, order confirmation, payment result, refund completion, coupon restoration, support decision, privacy conclusion, or staff obligation.

This matrix defines which customer-visible surfaces may show which statuses and actions, and what evidence must be created when those statuses or actions are displayed.

## 2. Scope

This matrix covers:

- QR/NFC entrance page
- Waiting status page
- Table session page
- Customer web app
- Native app surface
- Kiosk and mini kiosk customer surface
- Customer notification surface
- Support case surface
- Membership and benefit surface
- Recovery/error surface
- Privacy-sensitive customer display
- Customer action button control
- Display evidence control

This matrix does not define final UI design, visual style, layout, brand copy, accessibility implementation, or frontend component code.

## 3. Baseline Dependency

This matrix depends on:

`006750_Register_Customer_Runtime_Message_Template_Translation_Status_Wording_And_Customer_Display_Control.md`

It also supports:

`006540_Policy_Entrance_Customer_Notification_Status_Display_Multilingual_Guidance.md`

`06690_Matrix_Customer_Runtime_State_Authority_Event_And_Evidence_Coverage_Matrix.md`

`006710_Template_Customer_Runtime_Event_Audit_Evidence_Field_Specification_Template.md`

`006740_Checklist_Customer_Runtime_Privacy_Consent_And_Link_Security_Preflight_Check.md`

## 4. Core Principle

A customer surface may display only what the runtime can prove.

Every display must answer:

1. Which runtime state is being shown?
2. Which surface is allowed to show it?
3. Which message template and version are used?
4. Which customer action is allowed?
5. Which action must be blocked?
6. Which evidence proves the displayed state?
7. Does the display expose sensitive customer, payment, support, or staff data?
8. Does stale display need refresh, expiration, or recovery?
9. Does display failure create support, privacy, or incident review?
10. Does this display affect pilot or rollout risk?

## 5. Display Surface Families

Customer-facing display surfaces include:

| Surface Family | Description |
|---|---|
| Entrance Surface | QR/NFC entry, store entry page, public customer link |
| Waiting Surface | Waiting status, queue guidance, call, arrival, no-show, recovery |
| Table Surface | Table QR/NFC page, table session view, table guidance |
| Web App Surface | Browser-based menu, cart, preorder, order status, payment status |
| Native App Surface | Mobile app deep link, push landing, account session, app status |
| Kiosk Surface | Main kiosk self-service display |
| Mini Kiosk Surface | Mini kiosk, multilingual assisted flow, lightweight order surface |
| Notification Surface | SMS, push, in-app message, web notification, call message |
| Support Surface | Customer support case status and response page |
| Membership Surface | Coupon, visit count, benefit, compensation, wallet status |
| Recovery Surface | Expired link, invalid session, duplicate action, safe error |
| Privacy Surface | Privacy review, data restriction, wrong-session concern response |

Each surface must have allowed statuses and blocked statuses.

## 6. Display Risk Classes

| Risk Class | Meaning | Example |
|---|---|---|
| DSP-R1 | High-risk financial, privacy, legal, or irreversible trust implication | Payment approved, refund completed, privacy resolved |
| DSP-R2 | Material operational promise | Table assigned, order confirmed, customer called |
| DSP-R3 | Normal guidance | Please wait, checking status |
| DSP-R4 | Low-risk informational text | Refresh page, ask staff |

DSP-R1 and DSP-R2 displays require stronger evidence and review.

## 7. Customer Action Classes

Customer actions must be classified.

| Action Class | Meaning |
|---|---|
| View Only | Customer can view status only |
| Confirm | Customer can confirm arrival, receipt, or acknowledgement |
| Submit | Customer can submit cart/preorder/support claim |
| Modify | Customer can modify cart, party info, or profile where allowed |
| Cancel | Customer can cancel waiting/cart/request where allowed |
| Pay | Customer can begin or continue payment where allowed |
| Claim | Customer can claim guest/order/benefit/account linkage where allowed |
| Recover | Customer can start recovery for expired/lost session |
| Contact Support | Customer can create or continue support case |
| Blocked | Customer action is not allowed under current state |

Sensitive action classes must require scoped authorization or token validation.

## 8. Entrance Surface Matrix

| Runtime State | Allowed Display | Allowed Action | Blocked Action | Message Risk | Evidence Required |
|---|---|---|---|---|---|
| Entry Link Available | Store entry available | Start waiting / open menu where allowed | Payment / account claim | DSP-R3 | Link config evidence |
| Store Context Resolved | Correct store shown | Continue | Sensitive session action without scope | DSP-R2 | Store context evidence |
| Store Context Invalid | Safe error | Ask staff / retry | Waiting/order/payment action | DSP-R2 | Invalid context evidence |
| Entry Flow Paused | Temporarily unavailable | Ask staff | Self-service continuation | DSP-R2 | Pause evidence |
| Entry Recovery Required | Recovery guidance | Recover / ask staff | Duplicate create | DSP-R3 | Recovery evidence |
| Entry Failed | Safe error | Retry / ask staff | Sensitive action | DSP-R2 | Failure evidence |

Entrance surface must not display customer-specific data from static QR/NFC scan.

## 9. Waiting Surface Matrix

| Runtime State | Allowed Display | Allowed Action | Blocked Action | Message Risk | Evidence Required |
|---|---|---|---|---|---|
| Waiting Draft | Waiting being prepared | Confirm details / submit | Claim seat | DSP-R3 | Draft evidence |
| Waiting Active | Waiting registered | View / cancel if allowed | Confirm arrival before call if not allowed | DSP-R2 | Waiting session evidence |
| Queue Position Assigned | Queue status | View | See other customer details | DSP-R2 | Queue evidence |
| Customer Called | Called / please arrive | Confirm arrival | Reorder queue | DSP-R2 | Call evidence |
| Arrival Pending | Arrival confirmation needed | Confirm arrival | Payment/order confirmation | DSP-R2 | Arrival pending evidence |
| Arrival Confirmed | Arrival confirmed | Wait for seating | Modify queue position | DSP-R3 | Arrival evidence |
| No-Show Pending | Staff checking arrival | Ask staff / recover if allowed | Force restore | DSP-R2 | No-show pending evidence |
| No-Show Confirmed | Waiting no longer active / ask staff | Contact staff/support | Reenter same queue position without authority | DSP-R2 | No-show evidence |
| No-Show Reversed | Waiting restored / staff guidance | View / follow staff | Erase no-show history | DSP-R2 | Reversal evidence |
| Waiting Expired | Waiting expired | Recover / create new if allowed | Continue old sensitive action | DSP-R3 | Expiration evidence |
| Waiting Recovered | Waiting recovered | Continue | Duplicate waiting | DSP-R2 | Recovery evidence |
| Waiting Disputed | Support checking | View support status | Force queue correction | DSP-R2 | Support/dispute evidence |

Waiting surface must not expose other parties or internal staff notes.

## 10. Table Surface Matrix

| Runtime State | Allowed Display | Allowed Action | Blocked Action | Message Risk | Evidence Required |
|---|---|---|---|---|---|
| Table Candidate Selected | Table being prepared | Wait | Claim table as final | DSP-R2 | Candidate evidence |
| Table Session Created | Table assigned | View table guidance | Payment/order claim without scope | DSP-R2 | Table session evidence |
| Waiting Linked To Table | Seating confirmed | Proceed to table | Reopen waiting | DSP-R2 | Waiting-table evidence |
| Preorder Linked To Table | Preorder linked | View checking status | Assume order accepted if not accepted | DSP-R2 | Preorder linkage evidence |
| Order Linked To Table | Order linked | View order status | Modify paid/accepted order without rule | DSP-R2 | Order linkage evidence |
| Payment Linked To Table | Payment status available | View conservative status | Infer final payment if uncertain | DSP-R1 | Payment evidence |
| Table Reassigned | Updated table guidance | Follow new table guidance | View previous party context | DSP-R2 | Reassignment evidence |
| Table Merge Completed | Service context updated | View allowed grouped context | Merge accounts/payments automatically | DSP-R2 | Merge evidence |
| Table Split Completed | Service context separated | View own separated context | View other split party context | DSP-R2 | Split evidence |
| Table Session Closing | Service closing | Request support / view status | Create new order unless allowed | DSP-R2 | Closing evidence |
| Table Session Closed | Service complete | View receipt/support path where allowed | Continue active table action | DSP-R2 | Close evidence |
| Table Disputed | Support checking | Contact support | Force reassignment | DSP-R2 | Dispute evidence |

Table surface must treat table number as insufficient identity proof.

## 11. Web App Surface Matrix

| Runtime State | Allowed Display | Allowed Action | Blocked Action | Message Risk | Evidence Required |
|---|---|---|---|---|---|
| Web Session Created | Session started | Browse / continue | Access other session | DSP-R3 | Web session evidence |
| Guest Session Attached | Continue as guest | Browse / cart / waiting | Membership claim without scope | DSP-R3 | Guest linkage evidence |
| Account Session Attached | Account linked | View scoped account benefits | View unrelated guest/order history | DSP-R2 | Account linkage evidence |
| Menu Displayed | Menu available | Add available item | Add unavailable item | DSP-R3 | Menu display evidence |
| Cart Draft Created | Cart started | Modify / submit | Treat as accepted order | DSP-R3 | Cart evidence |
| Preorder Submitted | Order being checked | View / wait / support if delayed | Duplicate submit | DSP-R2 | Submission evidence |
| Preorder Accepted For Review | Store checking | View status | Assume POS accepted order | DSP-R2 | Review evidence |
| Order Confirmed | Order accepted | View order status | Modify confirmed order without rule | DSP-R2 | Order evidence |
| Order Rejected | Order unavailable/rejected | Modify / ask staff | Show order confirmed | DSP-R2 | Rejection evidence |
| Payment Pending | Payment checking | Wait / retry if allowed | Assume paid | DSP-R1 | Payment pending evidence |
| Payment Approved | Payment confirmed | View receipt/status | Refund/cancel without rule | DSP-R1 | Payment approval evidence |
| Payment Failed | Payment failed | Retry if allowed | Show success | DSP-R1 | Payment failure evidence |
| Payment Uncertain | Payment result checking | Wait / contact support | Retry in a way that duplicates charge | DSP-R1 | Uncertainty evidence |
| Duplicate Submission Blocked | Already submitted/checking | View existing status | Submit duplicate | DSP-R2 | Duplicate prevention evidence |
| Web Recovery Required | Recovery needed | Recover / ask staff | Continue stale action | DSP-R2 | Recovery evidence |
| Web Error Displayed | Safe error | Retry / ask staff | Expose internal details | DSP-R3 | Error evidence |

Web app surface must never make browser state authoritative.

## 12. Native App Surface Matrix

| Runtime State | Allowed Display | Allowed Action | Blocked Action | Message Risk | Evidence Required |
|---|---|---|---|---|---|
| Native Scope Excluded | App not available for this flow | Use web/staff path | Force app-only action | DSP-R4 | Scope evidence |
| Native Deep Link Opened | App link opened | Resolve current state | Act on stale link | DSP-R3 | Deep link evidence |
| Native Deep Link Resolved | Correct context loaded | Continue | Cross-session action | DSP-R2 | Resolution evidence |
| Push Sent | Notification sent | Open app/link | Infer delivery/open as action | DSP-R3 | Push send evidence |
| Push Opened | Push opened | View current status | Act on stale push state | DSP-R3 | Push open evidence |
| App State Stale | Refresh required | Refresh / recover | Submit stale action | DSP-R2 | Stale evidence |
| App/Web Conflict Detected | Status being refreshed | Recover / ask support | Duplicate order/payment action | DSP-R2 | Conflict evidence |
| Native Recovery Required | Recovery guidance | Recover | Continue unsafe state | DSP-R2 | Recovery evidence |

Native app surface must not create a second customer truth layer.

## 13. Kiosk And Mini Kiosk Surface Matrix

| Runtime State | Allowed Display | Allowed Action | Blocked Action | Message Risk | Evidence Required |
|---|---|---|---|---|---|
| Kiosk Session Started | Kiosk flow started | Browse / select language | Access previous customer session | DSP-R3 | Kiosk session evidence |
| Mini Kiosk Language Selected | Language selected | Continue | Treat as identity | DSP-R3 | Language evidence |
| Cart Draft Created | Cart started | Modify / submit | Treat as accepted order | DSP-R3 | Cart evidence |
| Order Submitted | Order being checked | Wait / staff assist | Duplicate submit | DSP-R2 | Submission evidence |
| Staff Assist Required | Staff help needed | Request staff | Continue sensitive action | DSP-R2 | Assist evidence |
| Kiosk Recovery Required | Recovery guidance | Recover / restart | Reuse previous customer data | DSP-R2 | Recovery evidence |
| Payment Pending | Payment checking | Wait | Start duplicate charge | DSP-R1 | Payment evidence |
| Payment Uncertain | Payment result checking | Ask staff/support | Show paid/failed conclusively | DSP-R1 | Uncertainty evidence |
| Session Closed | Session closed | Start new clean session | Reopen previous customer data | DSP-R2 | Session close evidence |

Kiosk surfaces must aggressively clear previous customer context.

## 14. Notification Surface Matrix

| Runtime State | Allowed Display | Allowed Action | Blocked Action | Message Risk | Evidence Required |
|---|---|---|---|---|---|
| Waiting Created | Waiting registered | Open waiting page | Confirm arrival unless allowed | DSP-R2 | Message evidence |
| Customer Called | Please arrive/confirm | Confirm arrival | Force seating | DSP-R2 | Call message evidence |
| Table Assigned | Table guidance | Open table page | View other table data | DSP-R2 | Table message evidence |
| Order Checking | Order being checked | Open order page | Assume accepted | DSP-R2 | Order message evidence |
| Payment Review | Payment checking | Open status/support | Retry duplicate payment | DSP-R1 | Payment message evidence |
| Refund Requested | Refund request received | View support/status | Assume completed | DSP-R1 | Refund request evidence |
| Refund Completed | Refund completed | View status | N/A | DSP-R1 | Refund completion evidence |
| Coupon Restored | Coupon restored | View coupon | N/A | DSP-R2 | Benefit evidence |
| Support Received | Case received | View case | Assume outcome | DSP-R2 | Support evidence |
| Privacy Review Started | Privacy issue under review | View support guidance | Assume no exposure | DSP-R1 | Privacy evidence |

Notifications must minimize sensitive data because they may appear on lock screens or shared devices.

## 15. Support Surface Matrix

| Support State | Allowed Display | Allowed Action | Blocked Action | Message Risk | Evidence Required |
|---|---|---|---|---|---|
| Case Created | Case received | Add info | Demand outcome | DSP-R2 | Case evidence |
| Case Classified | Checking issue | Wait / add info | View internal severity | DSP-R2 | Classification evidence |
| Store Review | Store record being reviewed | Wait | View staff-only notes | DSP-R2 | Store handoff evidence |
| Finance Review | Payment/refund review | Wait / add payment proof if allowed | Assume refund complete | DSP-R1 | Finance handoff evidence |
| Benefit Review | Benefit status checking | Wait / add info | Force coupon restoration | DSP-R2 | Benefit evidence |
| Privacy Review | Privacy issue under review | Wait / add info | View internal access logs | DSP-R1 | Privacy evidence |
| Resolution Proposed | Resolution proposed | Accept/respond | Treat as completed if action pending | DSP-R2 | Resolution evidence |
| Case Resolved | Case resolved | View result / reopen if allowed | Modify resolved state without reopen | DSP-R2 | Closure evidence |
| Case Rejected | Case rejected with reason | Reopen if allowed | Erase rejection history | DSP-R2 | Rejection evidence |
| Case Reopened | Case reopened | Add info / wait | Duplicate unrelated case | DSP-R2 | Reopen evidence |
| Case Carried Forward | Follow-up pending | Wait / contact support | Assume closed | DSP-R2 | Carry-forward evidence |

Support surface must not expose internal notes, severity, or unrelated customer records.

## 16. Membership And Benefit Surface Matrix

| Benefit State | Allowed Display | Allowed Action | Blocked Action | Message Risk | Evidence Required |
|---|---|---|---|---|---|
| Membership Eligible | Eligible / join prompt | Enroll if allowed | Auto-enroll without consent | DSP-R3 | Eligibility evidence |
| Membership Enrolled | Membership active | View benefits | Use restricted benefit | DSP-R3 | Enrollment evidence |
| Coupon Issued | Coupon available soon/issued | View | Use if not active | DSP-R2 | Coupon issue evidence |
| Coupon Active | Coupon available | Apply | Apply to ineligible order | DSP-R2 | Coupon state evidence |
| Coupon Reserved | Coupon being applied | Wait / remove if allowed | Reuse duplicate coupon | DSP-R2 | Reservation evidence |
| Coupon Applied | Coupon applied | Continue order/payment | Treat as consumed before final state | DSP-R2 | Application evidence |
| Coupon Consumed | Coupon used | View history | Reuse coupon | DSP-R2 | Consumption evidence |
| Coupon Released | Coupon available again | Apply if eligible | Duplicate restoration claim | DSP-R2 | Release evidence |
| Coupon Restored | Coupon restored | Use if active | Claim refund automatically | DSP-R2 | Restoration evidence |
| Coupon Expired | Coupon expired | View terms/support if allowed | Use expired coupon | DSP-R3 | Expiration evidence |
| Visit Count Earned | Visit counted | View count | Assume coupon issued unless threshold met | DSP-R2 | Visit evidence |
| Compensation Benefit Issued | Compensation granted | Use under terms | Treat as refund completion | DSP-R2 | Compensation evidence |
| Benefit Disputed | Benefit under review | Contact support | Force adjustment | DSP-R2 | Support evidence |

Benefit display must distinguish benefit state from payment/refund state.

## 17. Recovery And Error Surface Matrix

| Error/Recovery State | Allowed Display | Allowed Action | Blocked Action | Message Risk | Evidence Required |
|---|---|---|---|---|---|
| Link Expired | Link expired | Recover / ask staff | Continue old sensitive action | DSP-R2 | Expiration evidence |
| Link Invalid | Link unavailable | Retry / ask staff | Reveal reason/session | DSP-R2 | Invalid evidence |
| Scope Mismatch | Cannot use this link here | Ask staff | Show matched session details | DSP-R2 | Scope evidence |
| Replay Blocked | Request already handled | View current status / ask staff | Submit duplicate | DSP-R2 | Replay evidence |
| Session Lost | Session needs recovery | Recover | Create duplicate order/payment | DSP-R2 | Recovery evidence |
| App Error | Safe error | Retry / ask staff | Display internal error | DSP-R3 | Error evidence |
| Payment Error | Payment result checking or failed | Safe retry/support based on state | Duplicate charge path | DSP-R1 | Payment evidence |
| Privacy-Sensitive Error | Unable to display | Ask support | Reveal data existence | DSP-R1 | Privacy evidence |

Error surfaces must be privacy-safe and operationally useful.

## 18. Privacy Surface Matrix

| Privacy State | Allowed Display | Allowed Action | Blocked Action | Message Risk | Evidence Required |
|---|---|---|---|---|---|
| Privacy Review Started | Privacy-related issue is being checked | Add info / wait | Conclude no exposure | DSP-R1 | Privacy incident evidence |
| Data Restricted | Some data is restricted | Contact support | View restricted data | DSP-R1 | Restriction evidence |
| Consent Captured | Consent recorded | Manage consent | Assume marketing if not opted in | DSP-R2 | Consent evidence |
| Consent Withdrawn | Consent updated | Manage preferences | Delete required evidence | DSP-R2 | Withdrawal evidence |
| Data Expired | Session no longer visible | Ask support | Reopen sensitive session | DSP-R3 | Expiration evidence |
| Privacy Incident Resolved | Review completed | View result where allowed | View internal access log | DSP-R1 | Resolution evidence |

Privacy surface must never deny exposure before review.

## 19. Customer Action Permission Matrix

| Action | Allowed When | Blocked When | Evidence Required |
|---|---|---|---|
| Create Waiting | Store context valid and waiting flow available | Store invalid, paused, duplicate-sensitive state | Waiting creation evidence |
| Confirm Arrival | Waiting called/arrival pending and valid session | Expired, wrong session, no-show final without recovery | Arrival evidence |
| Cancel Waiting | Waiting active and cancellation allowed | Already seated, payment/order-sensitive linkage active | Cancel evidence |
| Submit Preorder | Cart valid and preorder flow open | Duplicate submission, unavailable item, stale session | Submission evidence |
| Modify Cart | Cart draft active | Order accepted, payment pending, expired session | Cart evidence |
| Start Payment | Order/payment preconditions met | Payment pending/uncertain, duplicate risk, invalid session | Payment attempt evidence |
| Retry Payment | Prior state safely retryable | Payment uncertainty unresolved, duplicate charge risk | Retry evidence |
| Claim Guest Order | Valid claim proof/session/support flow | Ambiguous identity, wrong account risk, expired claim | Claim evidence |
| Apply Coupon | Coupon active and eligible | Reserved/consumed/expired/ineligible | Benefit evidence |
| Contact Support | Customer flow active or claim available | Abuse restriction or invalid context without safe path | Support evidence |
| Reopen Support Case | Reopen window/rule allows | Case locked/legal/privacy restriction | Reopen evidence |
| Recover Session | Recovery token/session valid | Scope mismatch, privacy risk, duplicate-sensitive state | Recovery evidence |

Sensitive customer actions must be idempotent or duplicate-protected.

## 20. Stale Display Control

A display is stale when:

- Runtime state changed after display
- Message was superseded
- Token expired
- Payment state changed or became uncertain
- Order was accepted/rejected after checking state
- Table assignment changed
- No-show was reversed
- Coupon state changed
- Support case state changed
- Privacy restriction was applied

Stale display must:

1. Refresh automatically where possible.
2. Show safe “checking latest status” message.
3. Block sensitive action until current state is verified.
4. Preserve evidence of stale display if customer dispute may arise.

Expected event:

- `customer_display_state_stale`

## 21. Display Evidence Requirements

For each customer-facing display, evidence should capture:

- Display event ID
- Customer/session reference
- Surface
- Runtime state displayed
- Message template ID
- Message version
- Language
- Display timestamp
- Display expiration or supersession
- Customer action shown
- Customer action taken, where applicable
- State correlation reference
- Evidence visibility class
- Support/incident/closeout link, where applicable

DSP-R1 and DSP-R2 displays must have stronger evidence.

## 22. Display Defect Routing

Display defect must route when:

- Customer sees wrong session
- Customer sees stale payment result
- Customer sees order confirmed before confirmation
- Customer sees refund completed before completion
- Customer sees privacy issue denied before review
- Customer sees coupon restored before restoration
- Customer action is allowed under invalid state
- Customer action creates duplicate order/payment
- Translation changes status meaning
- Display lacks evidence for high-risk state

Routing targets:

- Support case
- Privacy incident
- Finance review
- Runtime incident
- Message register correction
- Risk register
- Pilot closeout exception
- Rollout blocker

## 23. Blocking Conditions

Customer display surface must be blocked or restricted when:

- Surface can expose another customer/session/order/payment
- Payment state can be displayed incorrectly
- Refund/cancel status is ambiguous but shown as final
- Order confirmation display lacks authoritative event
- No-show status lacks call evidence
- Table QR opens wrong session
- Stale display allows sensitive action
- Error screen exposes internal data
- Support surface exposes internal staff notes
- Message version cannot be proven
- High-risk display evidence is missing

Blocking conditions must route to:

`06670_Register_Customer_Runtime_Risk_Waiver_Blocker_Backlog_Carry_Forward_And_Rollout_Control.md`

## 24. Implementation Follow-Up

This matrix should later be converted into:

- Customer display state machine
- UI status code registry
- UI action permission registry
- Message template binding registry
- Surface-specific privacy rule map
- Stale-state handling specification
- Display evidence schema
- Frontend error boundary specification
- Notification display policy
- Kiosk session cleanup specification
- Native app push/deep link display policy

## 25. Acceptance Criteria

This matrix is accepted when:

- Display surface families are defined
- Display risk classes are defined
- Customer action classes are defined
- Entrance surface matrix is defined
- Waiting surface matrix is defined
- Table surface matrix is defined
- Web app surface matrix is defined
- Native app surface matrix is defined
- Kiosk and mini kiosk surface matrix is defined
- Notification surface matrix is defined
- Support surface matrix is defined
- Membership and benefit surface matrix is defined
- Recovery/error surface matrix is defined
- Privacy surface matrix is defined
- Customer action permission matrix is defined
- Stale display control is defined
- Display evidence requirements are defined
- Display defect routing is defined
- Blocking conditions are documented

## 26. Related Documents

Related document families include:

- Customer message template translation status wording register
- Customer notification multilingual guidance policy
- Customer privacy consent data retention policy
- Privacy consent and link security preflight checklist
- Customer runtime state authority event evidence matrix
- Customer runtime event audit evidence field specification template
- Customer Runtime risk waiver blocker register
- Customer web app runtime policy
- Customer native app runtime policy
- Customer link token QR/NFC security policy
- Waiting queue policy
- Table matching policy
- Customer support case policy
- Membership loyalty coupon benefit policy
- Payment uncertainty policy
- Refund and cancel policy

## 27. Final Rule

A display is a runtime claim.

Every customer-facing surface must show only the status and action that the system can prove, authorize, evidence, and safely recover.

This matrix controls the bridge between runtime truth and customer-visible UI behavior.