# 06870_Spec_Customer_Runtime_Error_Recovery_Stale_State_And_Safe_Fallback_Display_Spec

## 1. Purpose

This specification defines the Customer Runtime error, recovery, stale state, and safe fallback display rules.

The purpose is to ensure that customer-facing runtime errors, expired links, stale sessions, duplicate actions, payment uncertainty, wrong-scope access, table QR mismatch, app/web conflicts, kiosk recovery, native push staleness, support handoff, and privacy-sensitive display blocks are handled safely.

A customer error screen must not become a second incident.

When the system cannot prove the current runtime state, it must show a conservative fallback, block unsafe action, preserve evidence, and route the customer to recovery, staff assist, support, finance, privacy, or incident handling as appropriate.

## 2. Scope

This specification covers:

- Error display classification
- Recovery display classification
- Stale state detection
- Safe fallback display
- Expired link and invalid token display
- Scope mismatch display
- Duplicate action display
- Payment uncertainty fallback
- Refund/cancel uncertainty fallback
- Waiting and no-show recovery
- Table QR and table session recovery
- Web app session recovery
- Native app push/deep link stale recovery
- Kiosk and mini kiosk recovery
- Support handoff fallback
- Privacy-sensitive display block
- Evidence and audit requirements
- QA and rollout blocking conditions

This specification does not define full incident response, backend retry algorithms, payment provider reconciliation, frontend component design, or final support staffing procedure.

## 3. Baseline Dependency

This specification depends on:

`06860_Spec_Customer_Runtime_Display_Evidence_Event_And_Audit_Schema_Spec.md`

It must remain consistent with:

`06850_Spec_Customer_Runtime_Message_Template_Localization_Key_And_Versioning_Spec.md`

`06840_Spec_Customer_Runtime_Action_Permission_Button_Guard_And_Idempotency_Spec.md`

`06830_Spec_Customer_Runtime_Display_Status_Code_Registry_And_UI_State_Binding_Spec.md`

`06760_Matrix_Customer_Runtime_Display_Surface_Status_Action_Message_And_Evidence_Control_Matrix.md`

## 4. Core Principle

When customer-facing runtime truth is uncertain, the system must become conservative.

The system must not:

- Guess payment success
- Guess payment failure
- Guess refund completion
- Guess order acceptance
- Guess no-show finality
- Guess table ownership
- Guess coupon restoration
- Guess support resolution
- Guess privacy safety
- Continue sensitive action from stale state
- Reveal internal error details
- Expose another customer’s context

The system must:

1. Detect uncertainty.
2. Stop unsafe action.
3. Show safe wording.
4. Offer allowed recovery.
5. Route to support, staff, finance, privacy, or incident if needed.
6. Preserve evidence.
7. Mark rollout risk when repeated or high-risk.

## 5. Error And Recovery Families

| Family | Description |
|---|---|
| Link Error | Expired, invalid, revoked, replayed, or wrong-scope link |
| Session Error | Lost, expired, stale, duplicated, or mismatched session |
| Waiting Error | Waiting state mismatch, call/no-show conflict, recovery required |
| Table Error | Table QR mismatch, table closed, reassigned, wrong session |
| Cart/Order Error | Cart stale, duplicate submit, order state changed, unavailable item |
| Payment Error | Pending, failed, uncertain, duplicate risk, retry blocked |
| Refund/Cancel Error | Request/completion ambiguity, finance review required |
| Benefit Error | Coupon reserved/consumed/expired/restoration ambiguity |
| Support Error | Case state changed, reopen unavailable, support owner review required |
| Privacy Error | Display blocked due to possible wrong-session or restricted data |
| Notification Error | Old notification opened, wrong landing state, superseded message |
| Native App Error | Deep link stale, push stale, app/web conflict |
| Kiosk Error | Previous session risk, payment uncertainty, staff assist required |
| System Error | Generic safe failure without internal detail |
| Rollout Restriction | Feature paused, disabled, or restricted for pilot/scope |

Each error family must have a safe fallback status and recovery route.

## 6. Error Severity Model

| Severity | Meaning | Handling |
|---|---|---|
| ERR-S1 | Payment, privacy, wrong-session, duplicate charge/order, or sensitive exposure risk | Block action, preserve evidence, route to owner, possible incident |
| ERR-S2 | Material customer trust or operational state mismatch | Show safe fallback, recover or support/staff assist |
| ERR-S3 | Normal recoverable runtime error | Retry, refresh, or recover |
| ERR-S4 | Low-risk informational issue | Safe message and retry where allowed |

ERR-S1 errors must not be hidden as generic UI issues.

## 7. Safe Fallback Status Codes

Safe fallback display statuses include:

| Status Code | Meaning |
|---|---|
| ERROR_SAFE_RETRY | Retry is safe after refresh or non-sensitive failure |
| ERROR_STAFF_ASSIST_REQUIRED | Staff assistance is required |
| ERROR_SUPPORT_HANDOFF_REQUIRED | Support handoff is required |
| ERROR_FINANCE_REVIEW_REQUIRED | Payment/refund/cancel finance review is required |
| ERROR_PRIVACY_REVIEW_REQUIRED | Privacy-sensitive review is required |
| ERROR_ACTION_NOT_ALLOWED | Action is not allowed in current state |
| ERROR_STATE_CHANGED | Runtime state changed after screen was shown |
| ERROR_TEMPORARILY_UNAVAILABLE | Feature or flow temporarily unavailable |
| SESSION_RECOVERY_REQUIRED | Session recovery is required |
| SESSION_EXPIRED | Session expired |
| LINK_EXPIRED | Link expired |
| LINK_INVALID | Link invalid |
| LINK_SCOPE_MISMATCH | Link cannot be used for this context |
| TOKEN_REPLAY_BLOCKED | Repeated or already-used token action blocked |
| PAYMENT_UNCERTAIN | Payment result requires review |
| REFUND_REVIEW_REQUIRED | Refund status requires review |
| SUPPORT_REVIEW_REQUIRED | Support case requires owner review |
| PRIVACY_DISPLAY_BLOCKED | Display is blocked for privacy protection |

Fallback statuses must be registered in the display status registry.

## 8. Safe Message Rule

Error, recovery, and fallback messages must be:

- Conservative
- Non-technical
- Non-accusatory
- Privacy-minimized
- Actionable where possible
- Evidence-backed where high-risk
- Free of internal IDs
- Free of raw token values
- Free of provider details
- Free of stack traces
- Free of staff-only notes
- Free of security rule details

Examples:

| Situation | Safe Message Meaning |
|---|---|
| Link expired | “이 링크는 더 이상 사용할 수 없습니다.” |
| State changed | “최신 상태를 다시 확인하고 있습니다.” |
| Duplicate action | “이미 처리 중인 요청이 있습니다.” |
| Payment uncertainty | “결제 상태 확인이 필요합니다.” |
| Staff assist | “직원에게 확인을 요청해 주세요.” |
| Support handoff | “담당자가 기록을 확인하고 안내드리겠습니다.” |
| Privacy block | “정보 보호를 위해 일부 내용을 표시할 수 없습니다.” |

## 9. Forbidden Error Output

Customer-facing error surfaces must not display:

- Raw token
- Token validation result
- JWT payload
- Provider payment reference
- Provider error code, unless explicitly customer-safe
- Stack trace
- SQL error
- Internal exception class
- Internal order ID where unsafe
- Internal support severity
- Staff-only note
- Access log detail
- Fraud/abuse classification
- Other customer/session existence
- Security rule reason
- Rollout feature flag name

Internal diagnostic data must remain in restricted evidence, not customer UI.

## 10. Stale State Detection Rule

A stale state exists when the customer-facing surface was rendered from an older or invalid runtime state.

Stale sources include:

| Source | Example |
|---|---|
| Browser Cache | Customer refreshes old page |
| Native App Cache | Push opens stale app state |
| Notification | Old call/payment/support message opened |
| Kiosk Session | Previous customer session remains |
| Token Expiration | Link/token expired after display |
| Runtime Transition | Order/payment/table/support state changed |
| Payment Timeout | Provider result unknown |
| Table Reassignment | Customer keeps old table page |
| Coupon State Change | Coupon reserved/consumed elsewhere |
| Support Closure | Customer acts on old support page |
| Privacy Restriction | Display became restricted after review |

Stale state must trigger refresh, block, recovery, support, finance, privacy, or incident routing.

## 11. Stale State Handling Matrix

| Stale Condition | Safe Display | Allowed Action | Blocked Action | Handoff |
|---|---|---|---|---|
| Runtime state changed | ERROR_STATE_CHANGED | Refresh | Sensitive submit/pay/claim | Support if disputed |
| Token expired | LINK_EXPIRED / SESSION_RECOVERY_REQUIRED | Recover if allowed | Continue sensitive action | Staff/support if needed |
| Payment pending became uncertain | PAYMENT_UNCERTAIN | Wait / contact support | Retry payment | Finance |
| Cart submitted already | ORDER_CHECKING | View existing status | Submit duplicate | Support if disputed |
| Table reassigned | TABLE_REASSIGNED / ERROR_STATE_CHANGED | View new guidance | Continue old table action | Staff/support |
| Coupon consumed | COUPON_CONSUMED / BENEFIT_REVIEW_REQUIRED | View/support | Apply duplicate | Support/benefit owner |
| Support case closed | SUPPORT_RESOLVED / SUPPORT_REOPENED if allowed | Reopen if allowed | Modify closed case | Support |
| Privacy restriction applied | PRIVACY_DISPLAY_BLOCKED | Contact support | View restricted data | Privacy |

Sensitive stale action must be blocked until the current state is revalidated.

## 12. Link Expiration And Invalid Link Rule

When a customer opens an expired or invalid link:

1. Do not expose the original token.
2. Do not reveal whether another customer/session exists.
3. Check whether safe recovery is allowed.
4. If recovery is allowed, show recovery option.
5. If recovery is not allowed, show staff/support guidance.
6. Preserve error evidence.
7. If repeated or suspicious, route to abuse/incident review without customer-facing accusation.

Allowed display statuses:

- `LINK_EXPIRED`
- `LINK_INVALID`
- `SESSION_RECOVERY_REQUIRED`
- `ERROR_STAFF_ASSIST_REQUIRED`
- `ERROR_SUPPORT_HANDOFF_REQUIRED`

## 13. Scope Mismatch Rule

Scope mismatch occurs when:

- Link belongs to another store/context
- Link belongs to another table/session
- Link belongs to another order/support/benefit context
- Token action does not match requested action
- Customer account does not match guest/session claim
- QR/NFC placement is wrong
- Native deep link opens wrong context

Handling:

1. Block sensitive display.
2. Do not show target data.
3. Show safe mismatch message.
4. Offer staff/support route.
5. Create evidence.
6. Escalate to privacy if wrong-session access may have occurred.
7. Escalate to rollout blocker if systemic.

Allowed display status:

- `LINK_SCOPE_MISMATCH`
- `PRIVACY_DISPLAY_BLOCKED`
- `ERROR_STAFF_ASSIST_REQUIRED`
- `ERROR_SUPPORT_HANDOFF_REQUIRED`

## 14. Token Replay And Duplicate Action Rule

When a token or customer action is repeated:

1. Check idempotency result.
2. If previous result is safe to show, show existing state.
3. If pending, show existing pending state.
4. If duplicate is unsafe, block action.
5. If payment-related, route to finance if uncertain.
6. If identity/session-related, route to support/privacy.
7. Preserve duplicate guard evidence.

Allowed display status:

- `TOKEN_REPLAY_BLOCKED`
- `ACTION_DUPLICATE_BLOCKED`
- `ORDER_CHECKING`
- `PAYMENT_UNCERTAIN`
- `ERROR_SUPPORT_HANDOFF_REQUIRED`
- `ERROR_FINANCE_REVIEW_REQUIRED`

Duplicate handling must not create a second order, payment, refund, coupon consumption, support case, or privacy request unless explicitly allowed.

## 15. Payment Error And Recovery Rule

Payment errors are high risk.

Payment recovery must distinguish:

- Payment not started
- Payment pending
- Payment approved
- Payment failed
- Payment uncertain
- Retry allowed
- Retry blocked
- Finance review required
- Duplicate charge review

Rules:

1. Frontend timeout must not display final failure by itself.
2. Provider delay must not display final approval unless confirmed.
3. Payment uncertainty must block unsafe retry.
4. Retry may be shown only when duplicate guard approves it.
5. Payment error must preserve payment attempt evidence.
6. Finance/support handoff must be created when customer-facing certainty cannot be provided.
7. Customer wording must not say “refund complete” unless refund completion is confirmed.

Allowed display statuses:

- `PAYMENT_PENDING`
- `PAYMENT_FAILED`
- `PAYMENT_UNCERTAIN`
- `PAYMENT_RETRY_ALLOWED`
- `PAYMENT_RETRY_BLOCKED`
- `ERROR_FINANCE_REVIEW_REQUIRED`

## 16. Refund And Cancel Recovery Rule

Refund/cancel recovery must distinguish:

- Cancel requested
- Cancel approved
- Cancel completed
- Cancel rejected
- Refund requested
- Refund approved
- Refund processing
- Refund completed
- Refund failed
- Finance review required

Rules:

1. Cancel request must not be shown as cancel completion.
2. Cancel completion must not imply refund completion.
3. Refund request must not be shown as refund completion.
4. Refund processing must remain conservative.
5. Refund display uncertainty must route to finance/support.
6. Repeated refund request should show existing review status or route to support.

Allowed display statuses:

- `CANCEL_REQUESTED`
- `CANCEL_COMPLETED`
- `REFUND_REQUESTED`
- `REFUND_PROCESSING`
- `REFUND_COMPLETED`
- `REFUND_REVIEW_REQUIRED`
- `ERROR_FINANCE_REVIEW_REQUIRED`

## 17. Waiting And No-Show Recovery Rule

Waiting recovery must handle:

- Lost waiting page
- Expired waiting link
- Call notification opened late
- No-show pending
- No-show confirmed
- No-show reversal
- Duplicate waiting attempt
- Waiting dispute

Rules:

1. Do not restore queue position automatically without authority.
2. Preserve original waiting and no-show evidence.
3. Show safe recovery or staff/support route.
4. Arrival confirmation must not be allowed after no-show finality unless recovery is authorized.
5. Duplicate waiting creation must return existing state or block safely.
6. Customer must not see other waiting records.

Allowed display statuses:

- `WAITING_RECOVERY_REQUIRED`
- `WAITING_NO_SHOW_PENDING`
- `WAITING_NO_SHOW_CONFIRMED`
- `WAITING_NO_SHOW_REVERSED`
- `WAITING_DISPUTED`
- `ERROR_STAFF_ASSIST_REQUIRED`
- `ERROR_SUPPORT_HANDOFF_REQUIRED`

## 18. Table Recovery Rule

Table recovery must handle:

- Wrong table QR
- Reassigned table
- Closed table session
- Expired table session
- Merge/split stale display
- Previous party data risk
- Table order/payment context mismatch

Rules:

1. Table number alone is not identity authority.
2. Previous party context must never be shown.
3. Old table page must refresh or block after reassignment.
4. Closed table session must block active table actions.
5. Merge/split display must not reveal unrelated party data.
6. Wrong-session risk must route to privacy/support.
7. Store staff assist must be available when self-recovery is unsafe.

Allowed display statuses:

- `TABLE_REASSIGNED`
- `TABLE_CLOSED`
- `SESSION_RECOVERY_REQUIRED`
- `PRIVACY_DISPLAY_BLOCKED`
- `ERROR_STAFF_ASSIST_REQUIRED`
- `ERROR_SUPPORT_HANDOFF_REQUIRED`

## 19. Web App Recovery Rule

Web app recovery must handle:

- Browser refresh
- Back button
- Lost local session
- Expired guest session
- Stale cart
- Duplicate submit
- Payment uncertainty
- Account/session conflict
- Support handoff

Rules:

1. Browser state must not be authoritative.
2. Refresh must re-resolve runtime state.
3. Stale cart must not submit duplicate preorder.
4. Payment retry must be blocked during uncertainty.
5. Account/session conflict must route to support/privacy where needed.
6. Error screen must not expose stack trace or internal IDs.

Allowed display statuses:

- `SESSION_RECOVERY_REQUIRED`
- `ERROR_STATE_CHANGED`
- `ORDER_CHECKING`
- `PAYMENT_UNCERTAIN`
- `ACTION_DUPLICATE_BLOCKED`
- `ERROR_SUPPORT_HANDOFF_REQUIRED`

## 20. Native App Recovery Rule

Native app recovery must handle:

- Deep link expired
- Push opened after state changed
- App cache stale
- Web/native conflict
- Account continuity mismatch
- Native out-of-scope flow

Rules:

1. Push opening must refresh current runtime state.
2. Deep link must verify token/scope.
3. Native cached state must not submit sensitive action.
4. App/web conflict must show recovery or current state.
5. Native out-of-scope flows must route to web/staff/support safely.
6. Notification content must remain privacy-minimized.

Allowed display statuses:

- `ERROR_STATE_CHANGED`
- `LINK_EXPIRED`
- `SESSION_RECOVERY_REQUIRED`
- `ERROR_SUPPORT_HANDOFF_REQUIRED`
- `ERROR_TEMPORARILY_UNAVAILABLE`

## 21. Kiosk And Mini Kiosk Recovery Rule

Kiosk recovery must handle:

- Previous customer context risk
- Kiosk session timeout
- Payment uncertainty
- Duplicate order submit
- Language switch
- Staff assist required
- Mini kiosk low-context error

Rules:

1. New kiosk session must start clean.
2. Timeout must clear or lock sensitive state.
3. Payment uncertainty must block duplicate payment.
4. Language switch must not change identity or consent.
5. Staff assist must be available for unresolved error.
6. Kiosk evidence must prove previous session clearing.

Allowed display statuses:

- `SESSION_EXPIRED`
- `SESSION_RECOVERY_REQUIRED`
- `ACTION_DUPLICATE_BLOCKED`
- `PAYMENT_UNCERTAIN`
- `ERROR_STAFF_ASSIST_REQUIRED`
- `ERROR_SAFE_RETRY`

## 22. Support Recovery Rule

Support recovery must handle:

- Existing open case
- Duplicate support case
- Case resolved
- Case rejected
- Reopen allowed
- Reopen not allowed
- Support owner review required
- Finance/privacy attached case

Rules:

1. Duplicate support submission should show existing case when safe.
2. Reopen must preserve original closure.
3. Resolved/rejected state must not be modified without reopen.
4. Internal severity and staff notes must not be shown.
5. Payment/privacy cases must route to proper owner.
6. Support recovery evidence must be recorded.

Allowed display statuses:

- `SUPPORT_CASE_RECEIVED`
- `SUPPORT_REVIEW_REQUIRED`
- `SUPPORT_RESOLVED`
- `SUPPORT_REJECTED`
- `SUPPORT_REOPENED`
- `ERROR_SUPPORT_HANDOFF_REQUIRED`

## 23. Privacy-Sensitive Fallback Rule

Privacy fallback must be used when:

- Wrong-session access is suspected
- Wrong table QR may expose data
- Account/session mismatch occurs
- Support case may be visible to wrong account
- Payment display may be tied to wrong customer
- Staff note or internal evidence might be exposed
- Consent or data restriction state is unclear

Rules:

1. Block sensitive display.
2. Do not deny exposure before review.
3. Do not show internal access logs.
4. Route to privacy/support owner.
5. Create privacy display evidence.
6. Mark rollout blocker if systemic.

Allowed display statuses:

- `PRIVACY_DISPLAY_BLOCKED`
- `PRIVACY_REVIEW_STARTED`
- `ERROR_PRIVACY_REVIEW_REQUIRED`
- `ERROR_SUPPORT_HANDOFF_REQUIRED`

## 24. Rollout Restriction Fallback Rule

When a feature, surface, language, payment display, kiosk flow, native app flow, or action is restricted:

1. Hide or disable restricted action.
2. Show safe unavailable message.
3. Do not expose internal release flag.
4. Provide staff/support route where needed.
5. Preserve restriction evidence.
6. Update rollout handoff record.

Allowed display statuses:

- `ERROR_TEMPORARILY_UNAVAILABLE`
- `ERROR_STAFF_ASSIST_REQUIRED`
- `ERROR_SUPPORT_HANDOFF_REQUIRED`

## 25. Fallback Decision Tree

The fallback resolver should evaluate in this order:

1. Is there possible privacy exposure?
   - If yes, block display and route to privacy/support.
2. Is there payment/refund/cancel uncertainty?
   - If yes, block unsafe action and route to finance/support.
3. Is the action duplicate-sensitive?
   - If yes, check idempotency and duplicate guard.
4. Is the link/session expired?
   - If yes, attempt safe recovery or staff/support route.
5. Is the surface stale?
   - If yes, refresh and re-evaluate.
6. Is the feature restricted?
   - If yes, show rollout restriction fallback.
7. Is safe retry allowed?
   - If yes, show safe retry.
8. If no safe self-service path exists:
   - Show staff assist or support handoff.

Privacy and payment risks outrank convenience.

## 26. Error Evidence Rule

Every ERR-S1 and ERR-S2 fallback must create evidence.

Evidence must capture:

- Error/recovery event ID
- Error family
- Display status code
- Message template ID/version
- Surface
- Customer/session scope
- Runtime state before fallback
- Runtime state after refresh, where available
- Guard result
- Blocked action, where applicable
- Token reference hash, where applicable
- Duplicate guard result, where applicable
- Support/finance/privacy handoff reference, where applicable
- Incident reference, where applicable
- Correlation ID
- Evidence visibility class
- Timestamp

## 27. Support / Staff / Finance / Privacy Handoff Rule

Fallback must create handoff when self-service cannot safely continue.

| Handoff Target | Use When |
|---|---|
| Staff Assist | Store context issue, table confusion, kiosk recovery, waiting ambiguity |
| Support | Customer dispute, unresolved state, duplicate support context |
| Finance | Payment, refund, cancel, duplicate charge, settlement ambiguity |
| Privacy | Wrong-session, wrong account, data restriction, support visibility risk |
| Incident | Systemic, repeated, high-risk, rollout-sensitive defect |
| Release Owner | Feature restriction, pilot blocker, repeated display defect |

Handoff must include safe runtime context and evidence, not just customer complaint text.

## 28. Emergency Disable Rule

The system must support emergency disabling of:

- Message template
- Display status
- Customer action
- Payment retry button
- Table QR flow
- Static QR/NFC entry flow
- Native app deep link
- Push notification
- Kiosk payment flow
- Coupon apply button
- Guest claim button
- Support reopen
- Language variant
- Surface family

Emergency disable must:

1. Record owner and reason.
2. Show safe fallback.
3. Preserve evidence.
4. Route affected scope to QA/defect register.
5. Require review before reactivation.

## 29. Example Fallback Records

### 29.1 Payment Uncertainty Fallback

| Field | Value |
|---|---|
| Error Family | Payment Error |
| Detected Condition | Provider timeout after payment attempt |
| Display Status | PAYMENT_UNCERTAIN |
| Blocked Action | ACT_PAYMENT_RETRY |
| Allowed Action | ACT_PAYMENT_CONTACT_SUPPORT |
| Handoff | Finance / Support |
| Message Template | MSG_PAYMENT_UNCERTAIN_PRIMARY_v1 |
| Evidence Required | Yes |
| Rollout Impact | Block if repeated or evidence missing |

### 29.2 Expired Link Recovery

| Field | Value |
|---|---|
| Error Family | Link Error |
| Detected Condition | Token expired |
| Display Status | LINK_EXPIRED |
| Blocked Action | Continue sensitive action |
| Allowed Action | ACT_SESSION_RECOVER if allowed |
| Handoff | Staff / Support if recovery unavailable |
| Message Template | MSG_LINK_EXPIRED_ERROR_v1 |
| Evidence Required | Yes |
| Rollout Impact | Conditional if frequent |

### 29.3 Wrong Table QR Fallback

| Field | Value |
|---|---|
| Error Family | Table Error / Privacy Error |
| Detected Condition | Table QR opens mismatched table session |
| Display Status | PRIVACY_DISPLAY_BLOCKED |
| Blocked Action | View table/order/payment context |
| Allowed Action | ACT_STAFF_ASSIST_REQUEST |
| Handoff | Staff / Privacy / Support |
| Message Template | MSG_PRIVACY_DISPLAY_BLOCKED_PRIMARY_v1 |
| Evidence Required | Yes |
| Rollout Impact | Block until resolved |

## 30. Implementation Requirements

Implementation must provide:

- Error family classifier
- Stale state detector
- Link/token expiration handler
- Scope mismatch handler
- Duplicate action fallback resolver
- Payment uncertainty fallback resolver
- Refund/cancel fallback resolver
- Waiting recovery resolver
- Table recovery resolver
- Web app recovery resolver
- Native app recovery resolver where in scope
- Kiosk recovery resolver where in scope
- Privacy fallback resolver
- Rollout restriction fallback resolver
- Safe message resolver
- Fallback evidence emitter
- Handoff creator
- Emergency disable mechanism
- QA/defect register routing hook

## 31. QA Requirements

QA must verify:

- Expired link displays safe fallback
- Invalid link does not expose session existence
- Scope mismatch blocks sensitive display
- Token replay is blocked or idempotently resolved
- Payment uncertainty blocks retry
- Refund/cancel ambiguity routes to finance/support
- Waiting/no-show recovery preserves evidence
- Table QR mismatch blocks data exposure
- Web app stale state refreshes or blocks
- Native push/deep link refreshes state where in scope
- Kiosk timeout clears previous customer context
- Support duplicate case resolves safely
- Privacy fallback does not deny exposure prematurely
- Error messages hide internal details
- Fallback evidence is emitted
- Emergency disable works for high-risk messages/actions/surfaces

QA must use:

`06780_Checklist_Customer_Runtime_Display_Surface_Status_Action_Message_Evidence_And_QA_Acceptance.md`

`06790_Runbook_Customer_Runtime_Display_QA_Execution_Defect_Retest_Acceptance_And_Rollout_Handoff.md`

## 32. Blocking Conditions

Implementation or rollout must be blocked when:

- Error screen exposes raw token, stack trace, provider detail, internal ID, or security logic
- Expired link can continue sensitive action
- Scope mismatch can show customer/session/order/payment data
- Payment uncertainty allows retry without duplicate guard
- Refund/cancel ambiguity is displayed as completion
- Waiting/no-show recovery erases evidence
- Table QR mismatch exposes previous or wrong party data
- Browser/native stale state can submit sensitive action
- Kiosk timeout leaves previous customer data visible
- Support fallback exposes internal severity or staff notes
- Privacy fallback denies exposure before review
- Fallback lacks evidence for ERR-S1 or ERR-S2 condition
- Handoff lacks runtime context
- Emergency disable cannot remove unsafe message/action/surface

Blocking conditions must route to:

`06810_Register_Customer_Runtime_Display_QA_Defect_Retest_Waiver_Blocker_Rollout_And_Backlog_Control.md`

and where rollout-sensitive:

`06670_Register_Customer_Runtime_Risk_Waiver_Blocker_Backlog_Carry_Forward_And_Rollout_Control.md`

## 33. Acceptance Criteria

This specification is accepted when:

- Error and recovery families are defined
- Error severity model is defined
- Safe fallback status codes are defined
- Safe message and forbidden output rules are defined
- Stale state detection and handling are defined
- Link expiration, invalid link, scope mismatch, token replay, and duplicate action rules are defined
- Payment and refund/cancel fallback rules are defined
- Waiting/no-show and table recovery rules are defined
- Web app, native app, kiosk, support, privacy, and rollout restriction recovery rules are defined
- Fallback decision tree is defined
- Error evidence rule is defined
- Handoff rule is defined
- Emergency disable rule is defined
- Example fallback records are included
- Implementation requirements are defined
- QA requirements are defined
- Blocking conditions are documented

## 34. Related Documents

Related document families include:

- Customer Runtime display evidence event and audit schema spec
- Customer Runtime message template localization key and versioning spec
- Customer Runtime action permission button guard and idempotency spec
- Customer Runtime display status code registry and UI state binding spec
- Customer Runtime display control index
- Customer Runtime display QA checklist
- Customer Runtime display QA execution runbook
- Customer Runtime display QA defect register
- Customer Runtime risk waiver blocker register
- Customer link token QR/NFC security policy
- Customer support case policy
- Customer privacy consent data retention policy
- Payment uncertainty policy
- Refund and cancel policy
- Membership loyalty coupon benefit policy
- Store Runtime incident degraded operation policy

## 35. Final Rule

An error screen must protect the customer and the system.

When Customer Runtime cannot prove the current state, it must stop unsafe action, show conservative wording, preserve evidence, route to the right owner, and prevent rollout of unsafe recovery behavior.

Safe fallback is not a UX afterthought.  
It is the customer-facing boundary between uncertainty and incident.