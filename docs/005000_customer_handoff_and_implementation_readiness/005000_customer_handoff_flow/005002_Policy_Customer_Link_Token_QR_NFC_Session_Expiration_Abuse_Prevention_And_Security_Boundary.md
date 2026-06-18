# 005002_Policy_Customer_Link_Token_QR_NFC_Session_Expiration_Abuse_Prevention_And_Security_Boundary

## 1. Purpose

This policy defines the customer link, token, QR/NFC session, expiration, abuse prevention, and security boundary.

The purpose is to ensure that customer-facing links used for waiting, preorder, kiosk continuation, table context, customer notification, support follow-up, and recovery do not become uncontrolled access paths into Store Runtime.

A customer link is not merely a URL.  
It is a scoped runtime continuation channel that may expose waiting state, order state, table state, payment-related status, customer action, or support recovery.

This policy defines how customer links must be created, scoped, expired, validated, revoked, audited, and protected against misuse.

## 2. Scope

This policy covers:

- Customer link security boundary
- QR and NFC link behavior
- Scoped token rules
- Guest session continuation
- Waiting and table link control
- Kiosk and mini kiosk continuation link control
- Payment-sensitive link restrictions
- Expiration and revocation
- Link reuse and abuse prevention
- Staff-generated link control
- Incident and dispute linkage
- Evidence requirements

This policy does not define full authentication architecture, native app login, membership identity, payment provider security, or enterprise IAM implementation.

## 3. Baseline Dependency

This policy depends on:

`006511_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md`

`006520_Policy_Entrance_Waiting_Queue_Call_Arrival_No_Show_Seating_And_Recovery_Control.md`

`006530_Policy_Entrance_Table_Matching_Table_Session_Preorder_Link_Service_Context_And_Seating_Control.md`

`006540_Policy_Entrance_Customer_Notification_Status_Display_Multilingual_Guidance.md`

06510 defines the customer link and entrance runtime boundary.  
06520 defines waiting lifecycle control.  
06530 defines table session linkage.  
06540 defines customer-facing message and notification behavior.  
This document defines how those links and tokens are secured.

## 4. Core Principle

A customer link must carry authority, not just information.

Every customer link must define:

1. Who or what session it belongs to
2. What action it allows
3. What state it may display
4. What state it may not display
5. When it expires
6. Whether it can be reused
7. Whether it can be transferred
8. Whether it requires additional verification
9. Whether it may affect order, payment, table, support, or staff flow
10. What evidence must be recorded

No customer link may grant broad or permanent access to Store Runtime.

## 5. Link Families

Customer links must be grouped into families.

| Link Family | Meaning |
|---|---|
| Entrance Link | Starts or continues entrance/waiting flow |
| Waiting Status Link | Shows waiting and call status |
| Arrival Confirmation Link | Allows customer to confirm or request arrival review |
| Table Context Link | Opens table-linked customer flow |
| Cart Link | Continues cart or preorder draft |
| Preorder Review Link | Allows review or confirmation of preorder state |
| Kiosk Continuation Link | Continues a kiosk or mini kiosk session |
| Payment Status Link | Shows limited payment status or routes to approved payment flow |
| Support Case Link | Continues customer dispute or support follow-up |
| Recovery Link | Allows scoped recovery after expired, failed, or uncertain session |
| Staff-Generated Assist Link | Link created by staff to help customer continue flow |

Each link family must have its own scope and expiration rule.

## 6. Token Scope Boundary

A token must be scoped to a limited purpose.

Token scope may include:

- Store ID
- Business date
- Session ID
- Waiting session ID
- Table session ID
- Guest session ID
- Customer account ID, where authenticated
- Order draft ID
- Payment attempt reference, where safe
- Support case reference
- Allowed action
- Allowed display state
- Expiration timestamp
- Issuer
- Channel
- Language preference

A token must not expose unrestricted internal IDs or authority.

Where internal IDs are required, the link must use opaque references or scoped tokens rather than direct unsafe identifiers.

## 7. QR And NFC Boundary

QR and NFC may be used to initiate customer flow.

QR/NFC links may be:

- Static store entrance link
- Static table link
- Dynamic waiting link
- Dynamic kiosk continuation link
- Dynamic support/recovery link

Static QR/NFC links must be treated as public entry points.

Static links must not contain:

- Customer identity
- Payment identity
- Staff authority
- Manager authority
- Internal provider reference
- Long-lived session authority
- Sensitive order state

Static links may create or request a new scoped session only after runtime validation.

## 8. Static Link Rules

Static links are expected to be reusable by many customers.

Static links may allow:

- Store identification
- Language selection
- Waiting start
- Menu browse
- Staff help request
- Table context request, if table-specific
- Session creation

Static links must not allow:

- Viewing another customer’s waiting state
- Viewing order/payment state without session validation
- Performing payment-sensitive action
- Modifying existing session without proof
- Accessing staff or manager functions
- Reusing prior customer session context

Static links must create a fresh runtime session or require scoped continuation validation.

## 9. Dynamic Link Rules

Dynamic links are created for a specific session or action.

Dynamic links may support:

- Waiting status continuation
- Arrival confirmation
- Cart continuation
- Preorder review
- Kiosk recovery
- Table session continuation
- Payment status review
- Refund/cancel status review
- Support follow-up
- Dispute evidence continuation

Dynamic links must define:

- Target session or case
- Allowed actions
- Expiration
- Replay behavior
- Device/session binding, where applicable
- Verification requirement, where applicable
- Revocation condition

Dynamic links must not be permanent.

## 10. Payment-Sensitive Link Restriction

Payment-sensitive links require stricter control.

A payment-sensitive link may relate to:

- Payment attempt
- Payment status
- Payment uncertainty
- Refund status
- Cancel status
- Duplicate charge claim
- Payment dispute
- Settlement review

Payment-sensitive links must not allow:

- Arbitrary payment state change
- Staff-like confirmation
- Manager override
- Viewing sensitive provider details
- Viewing full payment credentials
- Reusing old payment action
- Replaying payment submission without idempotency protection

Payment status shown to customers must be conservative and based on authoritative runtime state.

## 11. Customer Verification Boundary

Some links may require additional verification.

Verification may include:

- Session-bound browser continuity
- Short code
- Phone verification, where policy allows
- Customer account login
- Staff confirmation
- Manager confirmation
- Support case verification
- Payment reference verification, where safe

Verification requirement must increase when:

- Link is expired
- Link is opened from a new device
- Payment-sensitive state is involved
- Customer dispute exists
- Table/order/payment references are ambiguous
- Staff or manager action is requested
- Recovery could affect financial state

Guest flow must remain possible where policy allows, but guest access must remain scoped.

## 12. Expiration Rules

Customer links must expire according to risk.

Expiration may be short for:

- Payment action
- Arrival confirmation
- Kiosk continuation
- Staff-generated assist link
- Recovery link
- Refund/cancel action
- Support case sensitive action

Expiration may be longer for:

- Public store entry link
- Public menu browsing link
- Static table link
- Non-sensitive support status link

Expired links must not delete evidence.

Expired links may allow:

- Safe status message
- New session creation
- Staff help request
- Recovery request
- Support contact request

Expired links must not allow sensitive action without validation.

## 13. Revocation Rules

A link or token must be revoked when:

- Session is merged
- Session is split
- Waiting is cancelled
- Table session is closed
- Order is cancelled
- Payment becomes uncertain
- Dispute escalates
- Staff detects misuse
- Manager revokes access
- Customer requests support-controlled follow-up
- Security risk is detected
- Token was issued incorrectly

Revocation must preserve audit evidence.

## 14. Link Reuse And Replay Prevention

The system must prevent unsafe reuse.

Reuse and replay risk may occur when:

- Customer refreshes payment page
- Customer taps submit repeatedly
- QR/NFC link is shared
- Dynamic link is forwarded
- Kiosk continuation link is opened twice
- Arrival confirmation is replayed
- Refund/cancel link is reused
- Staff-generated link remains open after issue resolved

Unsafe replay must be blocked by idempotency, token state, expiration, and runtime validation.

A repeated link open may be allowed for display-only status if safe.

## 15. Device And Session Binding

Certain links may be bound to device or session context.

Binding may include:

- Browser session
- Device session
- Kiosk device ID
- Table QR context
- Staff-generated link source
- Customer account login
- Temporary guest identity

Binding must not be so strict that normal customers cannot recover, but must be strict enough to prevent another person from taking over sensitive action.

When binding fails, the system should route to verification or staff recovery rather than silently showing sensitive data.

## 16. Staff-Generated Assist Link Control

Staff may create assist links when helping customers.

Staff-generated links may be used for:

- Waiting continuation
- Cart continuation
- Kiosk recovery
- Table context continuation
- Support follow-up
- Payment status checking, where safe
- Customer dispute continuation

Staff-generated links must record:

- Staff actor
- Reason
- Customer/session/order reference
- Allowed actions
- Expiration
- Whether manager approval was required
- Delivery method
- Evidence link

Staff-generated links must not grant staff authority to the customer.

## 17. Support And Recovery Link Control

Support and recovery links may be used after store operation or during dispute handling.

Support/recovery links must distinguish:

- Status-only link
- Customer response link
- Evidence upload or statement link, if later supported
- Refund/cancel status link
- Compensation acceptance link, if later supported
- Reopen or follow-up request link

Support/recovery links must not allow financial or operational state change without controlled workflow and owner review.

## 18. Abuse And Misuse Patterns

The system must detect or review possible abuse patterns.

Examples include:

- Excessive waiting session creation from one device
- Repeated QR scans creating duplicate sessions
- Repeated payment attempt opens
- Link sharing across unrelated users
- Attempt to access expired dynamic link
- Attempt to enumerate token-like URLs
- Repeated support case access failures
- Repeated arrival confirmation from conflicting devices
- Kiosk continuation link used outside expected store context
- Staff-generated link used after expiration

Abuse signals may create incident, staff review, support review, or security backlog.

## 19. Privacy Boundary

Customer links must minimize exposed data.

Customer-facing links should not expose:

- Full phone number
- Full customer identity
- Other party members
- Other customers’ queue position details
- Full payment reference
- Provider transaction details
- Staff-only notes
- Internal incident classification
- Audit-only data

The link may show only the safe minimum needed for the customer to continue the flow.

## 20. Customer-Facing Error Boundary

When link validation fails, customer-facing messages must be conservative.

Possible messages include:

- This link has expired
- Staff can help continue your request
- Please reopen from the store link
- This action can no longer be completed from this link
- Payment status requires staff confirmation
- Support will help check this request

The system must not reveal whether a token exists, belongs to another customer, or exposes internal validation logic.

## 21. Incident And Dispute Linkage

Customer link issues must create or link incident/dispute records when:

- Customer claims link showed wrong state
- Customer claims link expired too early
- Customer claims payment status was unclear
- Customer claims order disappeared after link failure
- Link led to wrong waiting/table/order context
- Duplicate sessions were created through repeated link use
- Shared link caused privacy or service confusion
- Staff-generated assist link caused incorrect action

Link-related incidents must preserve token event evidence without exposing sensitive token values broadly.

## 22. Daily Closeout Impact

Daily closeout should review material link exceptions.

Closeout review may include:

- Expired arrival links affecting no-show
- Duplicate waiting from QR/NFC reuse
- Kiosk continuation link failures
- Payment-sensitive link errors
- Staff-generated assist link usage
- Recovery link usage
- Support link handoff cases
- Link abuse signals
- Missing link evidence
- Customer disputes caused by link behavior

Link problems may affect waiting fairness, payment disputes, and support follow-up.

## 23. Evidence Requirements

The system must preserve evidence for:

- Link creation
- Token issuance
- Token scope
- Token expiration
- Token revocation
- Link open
- Link validation success
- Link validation failure
- Allowed action executed
- Blocked action
- Device/session binding result
- Verification attempt
- Staff-generated link creation
- Support/recovery link creation
- Abuse signal
- Customer-facing error display
- Incident/dispute linkage

Evidence must include:

- Store ID
- Business date
- Link family
- Token reference or hash
- Session reference
- Customer or guest reference, where available
- Device/session reference
- Actor ID, where applicable
- Issuer
- Channel
- Timestamp
- Allowed action
- Result
- Reason for failure, internally
- Related waiting/table/order/payment/support/incident/dispute reference

Sensitive token values must not be stored or displayed in unsafe form.

## 24. Acceptance Criteria

This policy is accepted when:

- Customer links are treated as scoped runtime authority
- Static QR/NFC links cannot expose sensitive session data
- Dynamic links have explicit scope and expiration
- Payment-sensitive links have stricter restrictions
- Expired links preserve evidence but block sensitive action
- Revocation rules are defined
- Replay and unsafe reuse are controlled
- Staff-generated assist links are auditable
- Support and recovery links are scoped
- Abuse patterns are detectable
- Privacy and customer-facing error boundaries are documented
- Daily closeout reviews material link exceptions
- Evidence requirements are traceable

## 25. Out of Scope

This policy does not include:

- Full authentication implementation
- Full native app login
- Full customer account security model
- Payment provider credential security
- Enterprise IAM
- Full WAF or bot mitigation implementation
- Legal privacy notice text
- Final QR/NFC hardware procurement

Those must be handled in authentication, native app, payment security, IAM, infrastructure security, legal, or hardware lanes.

## 26. Related Documents

Related document families include:

- Entrance waiting assist and customer link policy
- Waiting queue, call, arrival, no-show, seating policy
- Table matching and table session policy
- Customer notification and multilingual guidance policy
- Store Runtime Customer Session WorkPackage
- Kiosk and Mini Kiosk runtime WorkPackage
- Customer dispute and support handoff WorkPackage
- Store Runtime incident command WorkPackage
- Runtime evidence policy
- Privacy and data retention policy
- Security audit governance

## 27. Final Rule

A customer link is a temporary key into Store Runtime.

It must be scoped, expiring, revocable, replay-safe, privacy-preserving, and evidence-backed.

This policy defines the customer link security boundary before deeper authentication, native app, payment, support, and security governance lanes expand customer identity and access control.