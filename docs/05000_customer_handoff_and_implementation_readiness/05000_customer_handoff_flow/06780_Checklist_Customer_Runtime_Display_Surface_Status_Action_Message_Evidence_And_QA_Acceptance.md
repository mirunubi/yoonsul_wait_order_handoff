# 06780_Checklist_Customer_Runtime_Display_Surface_Status_Action_Message_Evidence_And_QA_Acceptance

## 1. Purpose

This checklist defines the Customer Runtime display surface, status, action, message, evidence, and QA acceptance checklist.

The purpose is to verify that customer-facing screens, notifications, buttons, error states, recovery flows, support surfaces, and benefit displays are correctly bound to runtime state, approved message templates, allowed customer actions, privacy rules, and evidence requirements before pilot or rollout.

Customer display QA must not check only whether the screen “looks correct.”  
It must verify whether the screen tells the truth, allows only safe actions, and leaves evidence.

## 2. Scope

This checklist covers:

- Customer display surface readiness
- Runtime state binding
- Status code binding
- Message template binding
- Customer action permission
- Payment-sensitive display
- Refund/cancel display
- Waiting and table display
- Web app and native app display
- Kiosk and mini kiosk display
- Support case display
- Membership and benefit display
- Privacy-sensitive display
- Stale display and recovery
- Error display
- Display evidence
- QA acceptance and rollout blocking

This checklist does not replace frontend component testing, accessibility testing, visual design QA, performance testing, or full security testing.

## 3. Baseline Dependency

This checklist depends on:

`06770_Template_Customer_Runtime_Display_Status_Code_Action_Permission_Message_Binding_And_Evidence_Template.md`

It also verifies implementation against:

`06760_Matrix_Customer_Runtime_Display_Surface_Status_Action_Message_And_Evidence_Control_Matrix.md`

`06750_Register_Customer_Runtime_Message_Template_Translation_Status_Wording_And_Customer_Display_Control.md`

`06700_Template_Customer_Runtime_Event_Audit_Evidence_Field_Specification_Template.md`

`06690_Matrix_Customer_Runtime_State_Authority_Event_And_Evidence_Coverage_Matrix.md`

## 4. Checklist Result Model

Each checklist item must be marked with one of the following results.

| Result | Meaning |
|---|---|
| Pass | Requirement is implemented, tested, and evidenced |
| Conditional Pass | Requirement works only under restriction or approved waiver |
| Hold | Requirement requires further review before activation |
| Fail | Requirement blocks pilot or rollout |
| Not In Scope | Requirement is intentionally excluded from current scope |

A `Conditional Pass` must include owner, restriction, review trigger, and evidence link.

## 5. QA Scope Confirmation

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Display QA scope defined | Surfaces, flows, languages, and features included in QA are listed |  |  |  |
| Store/pilot scope defined | Store, business date, and pilot/rollout scope are documented |  |  |  |
| Runtime state list available | States to be tested are mapped from matrix/template |  |  |  |
| Status code list available | Display status codes are registered and versioned |  |  |  |
| Message template list available | Approved template IDs and versions are available |  |  |  |
| Action registry available | Allowed and blocked actions are mapped |  |  |  |
| Evidence capture enabled | Display evidence events can be created and reviewed |  |  |  |
| Privacy reviewer assigned | Privacy-sensitive display review owner is assigned |  |  |  |
| Finance reviewer assigned | Payment/refund/cancel display reviewer is assigned where required |  |  |  |
| Support reviewer assigned | Support case display reviewer is assigned where required |  |  |  |

## 6. Runtime State Binding QA

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Status uses authoritative state | Display status is derived from approved runtime state |  |  |  |
| Event trigger is valid | Display update is triggered by approved event |  |  |  |
| Previous/new state handled | Display changes correctly when state transitions |  |  |  |
| Invalid state combination blocked | UI does not show status for invalid runtime state |  |  |  |
| Ambiguous state uses conservative display | Unknown or uncertain state shows checking/recovery status |  |  |  |
| Stale state detected | UI detects or refreshes stale runtime state |  |  |  |
| Superseded display replaced | Old message/status is replaced when new event arrives |  |  |  |
| Manual correction reflected | Staff/manager correction updates customer display safely |  |  |  |
| Closeout-sensitive display flagged | High-risk display states are available for closeout review |  |  |  |

## 7. Status Code QA

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Status code exists | Display status code exists in registry |  |  |  |
| Status version shown in evidence | Display evidence records status version |  |  |  |
| Status family is correct | Status belongs to correct family |  |  |  |
| Risk class assigned | DSP-R1/R2/R3/R4 risk class is defined |  |  |  |
| Privacy class assigned | Display privacy class is defined |  |  |  |
| Surface binding valid | Status appears only on approved surfaces |  |  |  |
| Deprecated status not used | Deprecated/replaced/blocked status is not active |  |  |  |
| Restricted status respects scope | Restricted status appears only under approved scope |  |  |  |
| Rollout blocker rule exists | Unsafe high-risk status has rollout blocker rule |  |  |  |

## 8. Message Template Binding QA

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Approved template used | UI uses approved message template ID |  |  |  |
| Template version captured | Display evidence captures template version |  |  |  |
| Free-form UI string avoided | Customer-facing wording is not hard-coded outside register |  |  |  |
| Surface-specific template valid | Template is approved for the actual surface |  |  |  |
| Language-specific template valid | Language version is approved |  |  |  |
| Translation meaning preserved | Translation does not overstate source state |  |  |  |
| Payment wording reviewed | Payment templates have finance/reconciliation review |  |  |  |
| Refund/cancel wording reviewed | Refund/cancel templates distinguish request, approval, completion |  |  |  |
| Privacy wording reviewed | Privacy templates do not deny exposure before review |  |  |  |
| Support wording reviewed | Support templates do not promise unapproved outcome |  |  |  |
| Blocked phrase absent | Blocked wording patterns are not present |  |  |  |

## 9. Customer Action Permission QA

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Allowed actions mapped | Each screen shows only allowed actions for current state |  |  |  |
| Blocked actions hidden or disabled | Unsafe actions are unavailable or safely blocked |  |  |  |
| Block reason safe | Blocked action message does not expose internal logic |  |  |  |
| Idempotency checked | Submit/pay/claim/recover actions are duplicate-safe |  |  |  |
| Confirm arrival scoped | Arrival confirmation is allowed only for valid waiting state |  |  |  |
| Submit preorder scoped | Preorder submit is allowed only for valid cart/session state |  |  |  |
| Payment retry scoped | Retry payment is blocked during uncertainty or duplicate risk |  |  |  |
| Guest claim scoped | Guest/order/account claim requires valid proof/session |  |  |  |
| Coupon apply scoped | Coupon apply is allowed only when coupon is active and eligible |  |  |  |
| Support contact scoped | Support handoff includes relevant runtime context |  |  |  |
| Recovery scoped | Recovery does not create duplicate order/payment/waiting action |  |  |  |

## 10. Entrance Surface QA

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Static QR/NFC shows no customer data | Public scan does not reveal session/order/payment/account data |  |  |  |
| Correct store context shown | Entrance page resolves correct store |  |  |  |
| Invalid store context safe | Invalid link shows safe error and staff guidance |  |  |  |
| Entry paused display safe | Paused flow does not expose internal rollout reason |  |  |  |
| Entry recovery works | Recovery path is available where allowed |  |  |  |
| Sensitive action blocked | Static entrance page cannot directly pay, claim, or modify session |  |  |  |
| Evidence captured | Entry display/open evidence is recorded |  |  |  |

## 11. Waiting Surface QA

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Waiting registered display correct | Waiting active state shows safe registration message |  |  |  |
| Queue display minimized | Queue display does not reveal other customers |  |  |  |
| Called display correct | Called state shows arrival guidance only after call event |  |  |  |
| Arrival confirmation action scoped | Arrival button appears only when allowed |  |  |  |
| No-show display safe | No-show wording does not erase recovery/support path where allowed |  |  |  |
| No-show reversal updates display | Reversal shows restored/recovered state safely |  |  |  |
| Waiting expired display safe | Expired state blocks old sensitive actions |  |  |  |
| Waiting recovery display safe | Recovery display does not expose duplicate/session internals |  |  |  |
| Waiting dispute surface works | Support status can be shown without staff-only evidence |  |  |  |
| Waiting evidence captured | Display evidence is captured for call/no-show/recovery |  |  |  |

## 12. Table Surface QA

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Table assigned display correct | Table assigned status appears only after table session event |  |  |  |
| Table QR scoped | Table page shows only correct table/session context |  |  |  |
| Preorder linked display conservative | Preorder link does not imply accepted order unless confirmed |  |  |  |
| Order linked display correct | Order status is separated from table assignment |  |  |  |
| Payment display separated | Table page does not infer payment result from table state |  |  |  |
| Reassignment display safe | New table guidance does not expose prior/next party data |  |  |  |
| Merge/split display safe | Merge/split does not expose unrelated customer data |  |  |  |
| Table closed display safe | Closed session blocks active table actions |  |  |  |
| Table support path works | Table dispute can route to support with context |  |  |  |
| Table display evidence captured | Table display status and message evidence is recorded |  |  |  |

## 13. Web App Surface QA

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Guest session display scoped | Guest user sees only own scoped flow |  |  |  |
| Account session display scoped | Account user sees only authorized account/session records |  |  |  |
| Menu availability display safe | Menu display blocks unavailable self-order items without exposing internal stock notes |  |  |  |
| Cart display separate from order | Cart draft is not shown as accepted order |  |  |  |
| Preorder submitted display conservative | Submitted preorder shows checking/review status until accepted |  |  |  |
| Order confirmed display authoritative | Order confirmed appears only after authoritative event |  |  |  |
| Duplicate submit display safe | Duplicate action is blocked with safe wording |  |  |  |
| Payment status display conservative | Payment pending/uncertain/failed/approved states are accurate |  |  |  |
| Browser refresh safe | Refresh does not show stale or another session state |  |  |  |
| Error screen safe | No stack trace, token, internal ID, provider detail is exposed |  |  |  |
| Web display evidence captured | Display and action evidence is recorded |  |  |  |

## 14. Native App Surface QA

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Native scope respected | Native app surfaces are active only if in scope |  |  |  |
| Deep link display scoped | Deep link resolves only allowed session/action |  |  |  |
| Push display minimized | Push does not expose sensitive order/payment/support detail |  |  |  |
| Push landing refreshes state | Opening push checks current runtime state |  |  |  |
| Stale app state blocked | Cached state cannot submit sensitive action |  |  |  |
| Web/native conflict safe | Conflict routes to recovery without duplicate order/payment |  |  |  |
| Account continuity safe | Native account view does not expose unrelated guest session |  |  |  |
| Native evidence captured | Push/deep link/display evidence is recorded where in scope |  |  |  |

## 15. Kiosk And Mini Kiosk Surface QA

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Kiosk session starts clean | Previous customer context is cleared |  |  |  |
| Language selection safe | Language selection does not create identity or consent assumption |  |  |  |
| Cart display safe | Cart is scoped to current kiosk session |  |  |  |
| Order submit duplicate-safe | Repeated tap does not duplicate order |  |  |  |
| Payment display conservative | Payment uncertainty is not shown as success/failure |  |  |  |
| Staff assist display safe | Staff assist message does not expose internal error |  |  |  |
| Kiosk recovery safe | Recovery does not reopen previous customer data |  |  |  |
| Mini kiosk multilingual wording reviewed | Mini kiosk translations preserve meaning |  |  |  |
| Kiosk evidence captured | Kiosk session/display/action evidence is recorded |  |  |  |

## 16. Notification Surface QA

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Recipient scoped | Notification goes to correct recipient/session/device |  |  |  |
| Lock-screen content minimized | Sensitive payment/support/privacy detail is avoided |  |  |  |
| Waiting call message correct | Call notification appears only after call event |  |  |  |
| Table message correct | Table guidance appears only after table event |  |  |  |
| Order message conservative | Order checking/confirmed wording follows runtime truth |  |  |  |
| Payment notification safe | Payment/refund wording is conservative and finance-reviewed |  |  |  |
| Support notification safe | Support wording does not promise outcome |  |  |  |
| Privacy notification safe | Privacy wording does not deny exposure before review |  |  |  |
| Expired notification handled | Old notification landing refreshes current status |  |  |  |
| Notification evidence captured | Send/display/open evidence is recorded where available |  |  |  |

## 17. Support Surface QA

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Case received display correct | Created case shows received/checking status |  |  |  |
| Internal severity hidden | Internal severity is not visible to customer |  |  |  |
| Staff notes hidden | Staff-only notes are not customer-visible |  |  |  |
| Store review wording safe | Store review does not blame staff/customer prematurely |  |  |  |
| Finance review wording safe | Finance/payment review does not promise refund result |  |  |  |
| Benefit review wording safe | Benefit review does not promise coupon restoration |  |  |  |
| Privacy review wording safe | Privacy review does not deny issue prematurely |  |  |  |
| Resolution display evidence-backed | Resolved/rejected state has decision evidence |  |  |  |
| Reopen action scoped | Reopen is allowed only under policy |  |  |  |
| Support display evidence captured | Case status display evidence is recorded |  |  |  |

## 18. Membership And Benefit Surface QA

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Coupon active display correct | Active coupon appears only when eligible |  |  |  |
| Coupon reserved display correct | Reserved coupon does not appear reusable |  |  |  |
| Coupon applied display separate | Applied coupon does not imply consumed before final state |  |  |  |
| Coupon consumed display correct | Consumed coupon cannot be reused |  |  |  |
| Coupon restored display evidence-backed | Restored status appears only after restoration event |  |  |  |
| Visit count display correct | Visit count appears only after qualifying event |  |  |  |
| Compensation benefit display separate | Compensation benefit is distinguished from normal loyalty |  |  |  |
| Benefit dispute display safe | Benefit under review does not promise correction |  |  |  |
| Benefit/payment separation clear | Benefit display does not imply refund/payment success |  |  |  |
| Benefit display evidence captured | Coupon/benefit display evidence is recorded |  |  |  |

## 19. Privacy-Sensitive Display QA

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| No other customer data shown | Customer cannot see another customer/session/order/payment/support data |  |  |  |
| Token value hidden | Raw token is never displayed |  |  |  |
| Internal IDs hidden | Internal IDs are not customer-visible unless explicitly safe |  |  |  |
| Staff note hidden | Staff-only notes are not customer-facing |  |  |  |
| Payment provider detail hidden | Provider internals are not customer-facing |  |  |  |
| Privacy review wording safe | Privacy display does not deny exposure before review |  |  |  |
| Consent display accurate | Consent state and preferences are shown accurately where in scope |  |  |  |
| Data restriction display safe | Restricted data message does not reveal sensitive internal reason |  |  |  |
| Privacy incident path tested | Wrong-session/wrong-display scenario routes to incident |  |  |  |
| Privacy display evidence captured | Access/display evidence is recorded for sensitive screens |  |  |  |

## 20. Error And Recovery QA

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Expired link error safe | Expired link shows recovery/staff guidance without token detail |  |  |  |
| Invalid link error safe | Invalid link does not reveal session existence |  |  |  |
| Scope mismatch error safe | Scope mismatch does not expose target/customer data |  |  |  |
| Duplicate action error safe | Duplicate action blocked without internal details |  |  |  |
| Payment error safe | Payment error avoids unsafe success/failure conclusion |  |  |  |
| App error safe | App error hides stack trace/internal details |  |  |  |
| Recovery action scoped | Recovery does not create duplicate waiting/order/payment |  |  |  |
| Staff assist route available | Staff assist path appears when self-service recovery is unsafe |  |  |  |
| Support route available | Support path appears for unresolved customer issue |  |  |  |
| Error evidence captured | Error/recovery display evidence is recorded |  |  |  |

## 21. Display Evidence QA

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Display event recorded | Customer display event is recorded where required |  |  |  |
| Status code recorded | Evidence includes display status code |  |  |  |
| Status version recorded | Evidence includes status version |  |  |  |
| Message template recorded | Evidence includes message template ID/version |  |  |  |
| Language recorded | Evidence includes display language |  |  |  |
| Surface recorded | Evidence includes display surface |  |  |  |
| Runtime state recorded | Evidence includes runtime state at display |  |  |  |
| Customer action recorded | Evidence captures action selected where applicable |  |  |  |
| Supersession recorded | Evidence records when display is replaced |  |  |  |
| Closeout route present | High-risk display evidence can be reviewed at closeout |  |  |  |
| Sensitive evidence protected | Evidence is redacted or restricted by role where required |  |  |  |

## 22. Blocking Conditions

Display QA must block pilot or rollout when:

- UI can show another customer/session/order/payment/support data
- Payment status can be shown as final without authoritative evidence
- Refund/cancel display collapses request, approval, and completion
- Order confirmation appears before authoritative order event
- No-show display appears without call/no-show evidence
- Table QR opens wrong session
- Stale display allows sensitive action
- Duplicate payment/order action can be triggered
- Support surface exposes internal staff notes or severity
- Privacy wording denies exposure before review
- Raw token/internal ID/provider detail is exposed
- Message template is unapproved or wrong version
- High-risk display evidence is missing

Blocking conditions must route to:

`06670_Register_Customer_Runtime_Risk_Waiver_Blocker_Backlog_Carry_Forward_And_Rollout_Control.md`

## 23. QA Acceptance Record

| Field | Value |
|---|---|
| QA Date |  |
| Store / Pilot Scope |  |
| Surface Scope |  |
| Language Scope |  |
| Reviewed By |  |
| Privacy Reviewer |  |
| Finance Reviewer |  |
| Support Reviewer |  |
| Overall Result | Pass / Conditional Pass / Hold / Fail |
| Conditional Restrictions |  |
| Waivers |  |
| Blockers |  |
| Evidence Packet Link |  |
| Next Review Trigger |  |

## 24. Acceptance Criteria

This checklist is accepted when:

- QA scope is confirmed
- Runtime state binding is verified
- Status code binding is verified
- Message template binding is verified
- Customer action permission is verified
- Entrance, waiting, table, web app, native app, kiosk, notification, support, membership, privacy, error, and recovery surfaces are checked
- Display evidence is checked
- Blocking conditions are documented
- QA acceptance record is completed
- Conditional restrictions or waivers are routed to the risk register

## 25. Related Documents

Related document families include:

- Customer display status code action permission message binding template
- Customer display surface status action message evidence control matrix
- Customer message template translation status wording register
- Customer runtime event audit evidence field specification template
- Customer runtime state authority event evidence matrix
- Privacy consent and link security preflight checklist
- Customer Runtime risk waiver blocker register
- Customer web app runtime policy
- Customer native app runtime policy
- Customer link token QR/NFC security policy
- Customer support case policy
- Membership loyalty coupon benefit policy
- Payment uncertainty policy
- Refund and cancel policy

## 26. Final Rule

Display QA is truth QA.

A customer-facing screen is acceptable only when its status, message, button, error, recovery path, and evidence are all bound to authoritative runtime state and safe customer scope.

This checklist verifies that Customer Runtime UI does not promise, expose, or permit anything the system cannot prove.