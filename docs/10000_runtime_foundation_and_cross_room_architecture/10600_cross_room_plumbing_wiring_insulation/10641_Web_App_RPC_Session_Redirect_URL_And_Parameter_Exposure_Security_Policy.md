# 10641_Web_App_RPC_Session_Redirect_URL_And_Parameter_Exposure_Security_Policy

## 1. Purpose

This document defines the Web App RPC Session, Redirect, URL, and Parameter Exposure Security Policy.

The previous artifact `10640 Tenant Scope Envelope Policy` defined the tenant, store, legal entity, provider, device, actor, role, surface, authority, visibility, and policy scope envelope that must wrap all data movement.

This document adds a web/app security layer for:

1. Preventing unvalidated redirects and unsafe forwarding.
2. Preventing sensitive data leakage through URL paths, query strings, fragments, and logs.
3. Protecting RPC sessions from hijacking, fixation, replay, and cross-surface abuse.
4. Separating browser-visible routing from authority-bearing backend RPC.
5. Ensuring that redirect, callback, deep link, and return URL flows remain tenant-scoped, allowlisted, and auditable.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Web URLs, redirects, and RPC sessions are security boundaries.

The correct rule is:

Redirect target is untrusted until validated.  
URL parameter is public unless proven otherwise.  
Browser address is not authority.  
Client route is not backend permission.  
SPA route is projection only.  
Session id must not appear in URL.  
Return URL must not be arbitrary.  
OAuth/payment callback target must be allowlisted.  
RPC method name must not expose internal authority.  
GET query must not carry sensitive command payload.  
Hidden URL is not security.  
Server-side validation is mandatory.  
Redirect is a controlled transition, not user-provided navigation.  

The platform must treat redirect, URL, callback, deep link, and RPC session handling as financial-grade attack surfaces.

---

## 3. Web Security Control Catalog

The following control families are added:

| Control Family | Purpose |
|---|---|
| `REDIRECT_ALLOWLIST_CONTROL` | Prevent unvalidated redirect and forwarding |
| `RELATIVE_PATH_ENFORCEMENT` | Force internal navigation to relative paths |
| `INDIRECT_DESTINATION_REFERENCE` | Use destination ids instead of raw URLs |
| `EXTERNAL_LINK_INTERSTITIAL` | Warn users before leaving trusted domain |
| `URL_SECRET_PROHIBITION` | Prevent session/token/secret leakage in URL |
| `RPC_METHOD_ABSTRACTION` | Hide internal procedure/function names |
| `RPC_SESSION_BINDING` | Bind session to actor/device/context |
| `SESSION_REGENERATION` | Regenerate session after login/elevation |
| `SESSION_TIMEOUT_CONTROL` | Enforce idle and absolute timeouts |
| `CSRF_AND_ORIGIN_CONTROL` | Prevent cross-site command abuse |
| `DEEP_LINK_CALLBACK_GUARD` | Protect app deep link and callback flows |
| `PARAMETER_TAMPERING_GUARD` | Validate every URL/body parameter server-side |
| `WEB_LOG_REDACTION` | Prevent sensitive data from entering logs |
| `SAFE_ERROR_ROUTING` | Prevent error pages from leaking internal paths |
| `TENANT_SCOPED_WEB_CONTEXT` | Bind every web/app request to tenant/store/surface scope |

These controls apply to web, mobile web, admin web, owner app, staff web, kiosk web, table tablet web, support console, franchise HQ console, and API gateway surfaces.

---

## 4. Redirect Boundary

Redirect is a high-risk operation.

Redirect may occur after:

- login
- logout
- password reset
- OAuth callback
- payment callback
- account verification callback
- deep link open
- admin session timeout
- support session handoff
- external provider flow
- export download
- invitation acceptance
- no-show appeal flow
- order/payment return flow

Every redirect target must be validated server-side.

Unvalidated redirect is prohibited.

---

## 5. Redirect Allowlist Boundary

Redirect target must match an allowlist.

Allowlist may include:

- trusted domain
- trusted subdomain
- allowed path prefix
- allowed scheme
- allowed port
- allowed environment
- allowed app deep link scheme
- allowed universal link
- allowed tenant-branded domain if verified
- allowed provider callback path
- allowed payment return path

Deny by default:

    REDIRECT_TARGET_DENIED

Wildcard domains must be avoided or heavily constrained.

---

## 6. Relative Path Enforcement Boundary

Internal redirects should use relative paths.

Allowed examples:

- `/dashboard`
- `/orders`
- `/owner/settlement`
- `/staff/kds`
- `/customer/wait`
- `/auth/complete`

Blocked examples:

- `http://attacker.example`
- `//attacker.example`
- `https://unknown-domain.example`
- `javascript:...`
- `data:...`
- encoded external URL
- nested redirect URL
- path traversal redirect

If external destination is needed, use indirect reference and warning flow.

---

## 7. Indirect Destination Reference Boundary

Raw destination URL must not be accepted from untrusted input.

Use destination reference:

| Input | Meaning |
|---|---|
| `dest_owner_dashboard` | Owner dashboard |
| `dest_staff_kds` | Staff KDS |
| `dest_customer_order_status` | Customer order status |
| `dest_payment_return` | Payment return |
| `dest_support_case` | Support case |
| `dest_external_provider_help` | External provider help page after warning |

Server maps destination id to approved target.

Client-provided raw URL must be rejected unless explicitly allowlisted and validated.

---

## 8. External Link Interstitial Boundary

External links must not silently redirect when risk is material.

External warning page should show:

- destination domain
- reason for leaving platform
- warning that external site is not controlled by platform
- continue button
- cancel/back button
- timestamp
- audit reference if high-risk flow
- i18n message key

External link warning is required for finance, account, support, provider, KYC, and sensitive flows unless provider flow requires direct redirect and has been reviewed.

---

## 9. URL Secret Prohibition Boundary

Sensitive data must never be placed in:

- URL path
- query string
- fragment
- redirect URL
- referrer header
- browser history
- QR code URL unless token is scoped and short-lived
- deep link URL unless token is scoped and short-lived
- email link beyond safe one-time token
- log-visible route
- analytics URL
- error page URL

Prohibited URL data includes:

- session id
- access token
- refresh token
- payment token
- card data
- provider secret
- customer PII
- staff private data
- settlement account number
- KYC document reference
- raw evidence packet id if sensitive
- admin privilege token
- device secret
- API key
- RPC internal function name with authority implication

URL is not a secret container.

---

## 10. Safe URL Token Boundary

Some flows require tokens in URLs.

Examples:

- password reset
- email verification
- invitation
- one-time device registration
- payment return correlation
- support case access link
- export download link
- QR/NFC table token

URL token must be:

- opaque
- random
- short-lived
- single-use where possible
- scoped to tenant/store/surface
- bound to purpose
- non-guessable
- revocable
- auditable
- not containing raw data
- not reusable as session token

A URL token is not a session.

---

## 11. RPC Session Boundary

RPC session governs authenticated remote procedure calls.

RPC session must carry:

- actor id
- session id
- tenant id
- store id if applicable
- role id
- surface id
- device id if applicable
- issued at
- last active at
- absolute expiry
- idle expiry
- auth strength
- risk state
- reauth requirement
- session version
- revocation state
- authority context

RPC session must not be passed through URL query string.

---

## 12. Session Token Transport Boundary

Session and access tokens must use secure transport.

Allowed patterns may include:

- HttpOnly secure cookie
- Authorization header
- platform-approved mobile secure storage
- short-lived access token plus refresh control
- CSRF-protected cookie-based session
- service-to-service signed token

Prohibited:

- `?sid=...`
- `?token=...`
- URL fragment access token for sensitive app flows unless specifically reviewed
- localStorage for high-risk web session without review
- long-lived bearer token in browser-accessible storage
- token in referrer-leaking URL
- token in logs

Token transport must match surface risk.

---

## 13. Session Regeneration Boundary

Session id must regenerate when risk changes.

Regeneration required after:

- login
- privilege elevation
- tenant/store context switch
- owner/admin mode entry
- support mode entry
- payment authority access
- KYC/account change access
- policy admin access
- export approval access
- break-glass access
- suspicious activity recovery
- password/MFA change

Old session must be invalidated or downgraded.

Regeneration prevents session fixation.

---

## 14. Session Context Binding Boundary

Session may be bound to context.

Binding signals may include:

- device id
- browser fingerprint class
- user agent family
- IP risk class
- geolocation risk class
- tenant/store context
- surface id
- auth strength
- token issuance time
- session risk score

Binding must be risk-aware.

Strict IP binding may harm mobile users and must be balanced with risk scoring.

Context mismatch must trigger reauthentication, step-up authentication, or session revocation.

---

## 15. Session Timeout Boundary

Session timeout must be explicit.

Timeout types:

| Timeout | Meaning |
|---|---|
| `IDLE_TIMEOUT` | No activity for configured period |
| `ABSOLUTE_TIMEOUT` | Maximum session lifetime |
| `PRIVILEGED_TIMEOUT` | Shorter timeout for admin/finance/security actions |
| `SUPPORT_SESSION_TIMEOUT` | Scoped support access expiry |
| `BREAK_GLASS_TIMEOUT` | Emergency session expiry |
| `DEVICE_SESSION_TIMEOUT` | Device-bound session expiry |
| `ANONYMOUS_SESSION_TIMEOUT` | Guest/customer temporary session expiry |

Logout must invalidate server-side session state where applicable.

Client-side logout alone is insufficient.

---

## 16. RPC Method Abstraction Boundary

RPC endpoint must not expose internal implementation.

Avoid:

- `/rpc/deleteSettlementLedger`
- `/rpc/disableTrigger`
- `/rpc/adminRootAction`
- `/api/run_sql`
- `/api/internal/payments/captureRaw`
- `/functions/refundWithoutReview`

Prefer abstracted action endpoints:

- `/api/v1/commands`
- `/api/v1/queries`
- `/api/v1/events`
- `/api/v1/payments/actions`
- `/api/v1/admin/actions`

Even abstracted endpoints require authority gate.

URL hiding is not security.

---

## 17. RPC Payload Boundary

RPC payload must be validated server-side.

Payload validation checks:

- schema
- command type
- actor
- tenant/store/legal scope
- target object id
- idempotency key
- state transition
- policy version
- amount/currency
- evidence packet
- authority context
- CSRF/origin if browser-based
- signature if service/device-based
- rate limit
- replay/nonces if applicable

Client validation is not enough.

---

## 18. GET vs POST Boundary

GET should be safe and idempotent.

GET must not:

- mutate state
- capture payment
- refund payment
- accept order
- cancel order
- impose penalty
- activate policy
- publish CMS
- create export
- submit supplier order
- send IoT command
- change account
- mark KDS completed

Sensitive command payload should use POST/PUT/PATCH with secure body and server validation.

GET query string must not carry secrets.

---

## 19. Parameter Tampering Boundary

All parameters are untrusted.

Tamperable parameters include:

- tenant id
- store id
- role
- amount
- discount
- payment id
- order id
- settlement id
- return URL
- next path
- export scope
- evidence packet id
- policy version
- no-show penalty rate
- coupon id
- table id
- device id

Server must derive authority from trusted session and database, not from user-provided parameter alone.

---

## 20. CSRF And Origin Boundary

Browser-based commands must defend against CSRF and origin abuse.

Controls may include:

- SameSite cookies
- CSRF token
- Origin/Referer validation
- CORS allowlist
- preflight restrictions
- non-simple request requirement where appropriate
- double-submit or synchronizer token pattern
- reauthentication for high-risk commands

CORS is not authentication.

CSRF token is not authorization.

Both are supporting controls.

---

## 21. CORS Boundary

CORS must be allowlist-based.

CORS must not allow:

- wildcard origin with credentials
- unknown tenant custom domain without verification
- arbitrary localhost in production
- broad methods for public endpoints
- sensitive headers exposed unnecessarily
- admin API exposed to customer origins

Tenant-branded domains require ownership verification and explicit mapping.

CORS misconfiguration can bypass browser boundary.

---

## 22. Deep Link And App Link Boundary

Mobile app deep links and universal links must be controlled.

Deep link must include:

- allowed scheme/domain
- purpose
- token type
- expiry
- one-time status if needed
- tenant/store scope
- target surface
- fallback behavior
- replay control
- audit if high-risk

Deep link must not carry raw session or long-lived token.

App link open must revalidate on server.

---

## 23. Payment Callback And Return URL Boundary

Payment provider callback and customer return URL are different.

Provider callback:

- server-to-server
- signature verified
- provider scope validated
- financial matching required

Customer return URL:

- browser/app navigation
- not financial proof
- may be manipulated
- must show pending/verified status based on server state

Customer returning to success page does not mean payment confirmed.

---

## 24. OAuth And Identity Callback Boundary

OAuth/identity callback must validate:

- state parameter
- nonce
- PKCE where applicable
- redirect URI exact match
- issuer
- audience
- token signature
- token expiry
- session binding
- tenant/app context
- replay status

OAuth callback must not accept arbitrary redirect URI or missing state.

---

## 25. Admin And Support Console URL Boundary

Admin/support URLs are high-risk.

Admin/support routes must not expose:

- raw tenant id without scope validation
- raw evidence object without case scope
- direct database object path
- privileged action id that can be replayed
- export URL without authorization
- break-glass token
- internal provider secret
- raw media URL

Admin route visibility must be rechecked server-side.

---

## 26. Export Download URL Boundary

Export download links must be protected.

Export URL token must be:

- scoped
- short-lived
- single-use or limited-use
- actor-bound where possible
- masked according to approval
- logged
- revocable
- inaccessible after expiry
- not guessable

Export file must not be publicly accessible by raw URL.

---

## 27. QR/NFC URL Boundary

QR/NFC URLs are visible to customers and attackers.

QR/NFC token must be:

- table/store scoped
- short-lived or rotating if needed
- nonce-protected
- replay-detected
- not a session token
- not a payment token
- not containing raw table secrets
- bound to server-side state
- invalidated on misuse where policy allows

QR screenshot must not become permanent authority.

---

## 28. Referrer Leakage Boundary

URLs may leak through referrer headers.

Sensitive pages must use:

- referrer policy control
- no secrets in URL
- external link interstitial
- token minimization
- download isolation
- safe redirect
- log redaction

Referrer leakage can expose query parameters to third-party domains.

---

## 29. Web Log Redaction Boundary

Logs must not store sensitive URL or payload data.

Redact:

- token
- session id
- payment id if sensitive
- card-related data
- customer PII
- settlement account
- KYC data
- evidence packet secret
- export token
- reset token
- invitation token
- device secret
- authorization header
- cookie
- raw media URL

Log redaction failure is security incident candidate.

---

## 30. Browser History Boundary

Browser history persists URLs.

Therefore:

- no secrets in URL
- no sensitive command payload in URL
- no raw evidence references in URL
- use POST body for sensitive action
- use short-lived opaque references
- use history replacement after sensitive callback where appropriate
- use server-verified state display

Browser history must not become evidence leak.

---

## 31. SPA Route Boundary

SPA route is UI state.

SPA route must not:

- prove authentication
- prove role
- prove tenant scope
- authorize command
- expose hidden admin feature
- bypass backend checks
- carry sensitive payload

Client-side route guard is UX only.

Server-side authority gate is mandatory.

---

## 32. Error Page Boundary

Error pages must not leak:

- stack trace
- internal path
- SQL/function name
- RPC method name
- provider secret
- tenant existence
- account existence
- permission internals
- raw redirect target
- token validation detail
- security rule detail

Use safe error codes and i18n message keys.

Internal details go to audit/security logs with redaction.

---

## 33. Security Header Boundary

Web surfaces should consider security headers.

Candidate controls:

- HSTS
- Content-Security-Policy
- X-Frame-Options or frame-ancestors
- X-Content-Type-Options
- Referrer-Policy
- Permissions-Policy
- Cache-Control for sensitive pages
- Secure and HttpOnly cookies
- SameSite cookies

Headers are defense-in-depth.

They do not replace authority checks.

---

## 34. Cache Boundary

Sensitive web/app responses must not be cached unsafely.

Sensitive responses include:

- settlement dashboard
- payment status
- admin pages
- support cases
- evidence packets
- export links
- KYC/account pages
- policy admin
- sensor evidence
- raw media
- no-show dispute
- customer account pages

Cache must respect authentication, scope, and expiry.

Shared caches must not serve one tenant’s data to another tenant.

---

## 35. Web Rate Limit Boundary

Web/RPC requests must be rate-limited.

Rate limit dimensions:

- IP risk class
- actor id
- tenant id
- store id
- device id
- session id
- endpoint/action
- provider route
- support/admin surface
- login/reset/invite flow
- QR/NFC token flow
- payment callback flow

Rate limiting must not block emergency operational recovery without fallback policy.

---

## 36. Web Security Event Catalog

Recommended event types:

| Event Type | Meaning |
|---|---|
| `REDIRECT_TARGET_DENIED` | Unsafe redirect blocked |
| `EXTERNAL_LINK_INTERSTITIAL_SHOWN` | External warning displayed |
| `URL_SECRET_DETECTED` | Secret detected in URL/log |
| `SESSION_REGENERATED` | Session regenerated |
| `SESSION_CONTEXT_MISMATCH` | Session binding mismatch |
| `SESSION_TIMEOUT_OCCURRED` | Session expired |
| `RPC_AUTHORITY_DENIED` | RPC command denied |
| `RPC_SCOPE_MISMATCH` | RPC tenant/store scope mismatch |
| `CSRF_VALIDATION_FAILED` | CSRF failed |
| `ORIGIN_DENIED` | Origin/CORS denied |
| `DEEP_LINK_REPLAY_DETECTED` | Deep link replay |
| `PAYMENT_RETURN_UNVERIFIED` | Customer return not yet verified |
| `EXPORT_TOKEN_EXPIRED` | Export token expired |
| `QR_TOKEN_REPLAY_DETECTED` | QR/NFC replay |
| `WEB_LOG_REDACTION_FAILURE` | Sensitive log exposure |
| `SPA_ROUTE_AUTH_BYPASS_ATTEMPT` | Client route bypass attempt |
| `ERROR_DETAIL_SUPPRESSED` | Sensitive error detail suppressed |

These events must route through `10610` event bus rules.

---

## 37. Relationship To Tenant Scope Envelope

Every web/RPC request must resolve scope envelope.

Request must resolve:

- tenant
- store if applicable
- actor
- role
- surface
- device/session
- authority context
- visibility context
- policy version

URL parameter must not be trusted as final scope.

Scope must be validated server-side.

---

## 38. Relationship To Command Query Projection Separation

Web/RPC interaction must respect `10620`.

- GET query reads only.
- POST/PUT/PATCH command requests mutation.
- Projection shows safe visibility.
- Dashboard button creates command.
- Redirect creates navigation, not authority.
- Callback creates event, not final state.
- Session creates identity context, not unlimited authority.

No web route may mix query and hidden mutation.

---

## 39. Relationship To Authority Capability Gate

Every RPC command must pass `10630`.

Authority gate must check:

- identity
- role
- scope
- entitlement
- policy
- state transition
- evidence
- risk
- device trust
- provider readiness
- financial limit
- approval
- privacy
- safety
- idempotency
- audit
- time window
- circuit breaker
- compliance
- human review

Session exists is not enough.

---

## 40. Anti-Patterns

Avoid:

- `?next=http://attacker.example`
- raw return URL accepted from client
- session id in URL
- token in query string
- payment token in redirect URL
- GET endpoint mutating state
- hidden RPC method name in URL
- client-side route guard as only protection
- tenant id from URL trusted without server check
- wildcard CORS with credentials
- redirect after login without allowlist
- provider callback treated as customer browser return
- QR code token reused forever
- export file public by URL
- evidence packet id exposed in raw URL
- stack trace on error page
- logs storing Authorization header or cookie
- support console URL granting authority by path

These anti-patterns must be blocked in future runtime design.

---

## 41. Runtime Deferral

This document defines web/app RPC session, redirect, URL, and parameter exposure security boundaries only.

It does not authorize:

- web middleware implementation
- redirect handler implementation
- session storage implementation
- cookie configuration
- CORS configuration
- CSRF implementation
- OAuth callback implementation
- deep link runtime
- export URL runtime
- QR/NFC token runtime
- RPC gateway implementation
- security header deployment
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 42. Validation Checklist

Validation must confirm:

1. Web security control catalog is defined.
2. Redirect boundary is defined.
3. Redirect allowlist boundary is defined.
4. Relative path enforcement boundary is defined.
5. Indirect destination reference boundary is defined.
6. External link interstitial boundary is defined.
7. URL secret prohibition boundary is defined.
8. Safe URL token boundary is defined.
9. RPC session boundary is defined.
10. Session token transport boundary is defined.
11. Session regeneration boundary is defined.
12. Session context binding boundary is defined.
13. Session timeout boundary is defined.
14. RPC method abstraction boundary is defined.
15. RPC payload boundary is defined.
16. GET vs POST boundary is defined.
17. Parameter tampering boundary is defined.
18. CSRF/origin boundary is defined.
19. CORS boundary is defined.
20. Deep link/app link boundary is defined.
21. Payment callback/return URL boundary is defined.
22. OAuth/identity callback boundary is defined.
23. Admin/support console URL boundary is defined.
24. Export download URL boundary is defined.
25. QR/NFC URL boundary is defined.
26. Referrer leakage boundary is defined.
27. Web log redaction boundary is defined.
28. Browser history boundary is defined.
29. SPA route boundary is defined.
30. Error page boundary is defined.
31. Security header boundary is defined.
32. Cache boundary is defined.
33. Web rate limit boundary is defined.
34. Web security event catalog is defined.
35. Relationships to Tenant Scope Envelope, Command Query Projection Separation, and Authority Capability Gate are defined.
36. Anti-patterns are listed.
37. Coding remains unauthorized.
38. Runtime remains deferred.

---

## 43. Relationship To Previous Documents

This document supplements:

- `10640 Tenant Scope Envelope Policy`

It references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`

It prepares:

- `10650 Failure Containment Circuit Breaker Policy`
- future web gateway security policy
- future RPC session security specification
- future redirect allowlist specification
- future callback/deep-link security packet
- future URL/token/log redaction test matrix

This document is architecture boundary planning only.

It does not authorize coding.

---

## 44. Final Rule

Web and app routes must not leak authority, secrets, or scope.

Redirect targets must be server-side allowlisted, relative-path preferred, or indirect-reference mapped.

Session tokens must not appear in URLs.

Sensitive RPC payloads must not be carried in query strings.

GET must not mutate state.

Browser route, SPA route, redirect path, callback URL, deep link, QR/NFC URL, and return URL are not authority.

Every RPC command must resolve tenant scope, pass authority gates, validate parameters server-side, enforce session security, resist CSRF/origin abuse, protect tokens, redact logs, and produce audit events.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.