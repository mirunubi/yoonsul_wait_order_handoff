# 010642_Guide_Web_RPC_Security.md

## Purpose

This document defines the Web RPC Redirect, Session, Infrastructure, Mobile, and Deep Security Implementation Guide Policy.

The previous artifact `10641 Web App RPC Session Redirect URL And Parameter Exposure Security Policy` defined the boundary rules for redirect control, URL secret prohibition, RPC session management, callback/deep-link handling, CORS, CSRF, QR/NFC URL handling, log redaction, and browser/app route security.

This document extends those rules into an implementation-oriented security checklist and threat-response model for:

1. Safe redirect implementation.
2. URL and parameter protection.
3. RPC session hijacking and fixation prevention.
4. Network and infrastructure-level address hiding.
5. Mobile client and WebView-specific controls.
6. Advanced session lifecycle control.
7. Monitoring, alerting, SIEM routing, and forced session invalidation.
8. BOLA/IDOR and inline resource ownership verification.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Implementation must be centralized, testable, and impossible to bypass casually.

The correct rule is:

Every redirect must pass one safe redirect utility.  
Every RPC request must pass one gateway policy.  
Every session must be revocable server-side.  
Every high-impact command must re-check object ownership.  
Every URL token must be purpose-scoped and short-lived.  
Every client route must be treated as untrusted.  
Every internal service path must be hidden behind gateway routing.  
Every mobile token must be stored in secure OS-backed storage.  
Every suspicious redirect, URL tamper, RPC brute force, replay, or scope mismatch must produce a security event.  
Security header, TLS, CORS, pinning, obfuscation, and rate limiting are defense-in-depth, not substitutes for authority gates.  

Security must be enforced by architecture, not developer discipline alone.

---

## 3. Implementation Control Catalog

The following implementation control families are added:

| Control Family | Purpose |
|---|---|
| `SAFE_REDIRECT_UTILITY` | Centralize all redirect validation and response creation |
| `REDIRECT_TARGET_SCHEMA_VALIDATION` | Validate relative paths, allowed hosts, schemes, and bypass patterns |
| `DESTINATION_ID_MAPPING` | Replace raw redirect URL with server-side destination references |
| `API_GATEWAY_ABSTRACTION` | Hide internal RPC endpoints behind gateway routes |
| `REVERSE_PROXY_ROUTE_HARDENING` | Ensure clients never see internal service layout |
| `POST_BODY_COMMAND_ENFORCEMENT` | Ensure state-changing RPC uses request body, not URL query |
| `NONCE_STATE_REPLAY_GUARD` | Protect redirect, callback, and RPC flows from replay |
| `SESSION_COOKIE_SECURITY` | Enforce HttpOnly, Secure, SameSite, and cache rules |
| `TOKEN_ROTATION_AND_BLACKLIST` | Short access token, controlled refresh, server-side revocation |
| `SESSION_CONTEXT_BINDING` | Detect context drift and suspicious reuse |
| `SIEM_SECURITY_EVENT_ROUTING` | Route suspicious activity to monitoring/security review |
| `INFRA_HEADER_HARDENING` | Remove server technology disclosure |
| `TLS_AND_HOST_VALIDATION` | Enforce secure transport and host allowlist |
| `MOBILE_PINNING_AND_INTEGRITY` | Protect mobile RPC traffic and token storage |
| `GLOBAL_LOGOUT_KILL_SWITCH` | Invalidate distributed sessions during incident |
| `INLINE_OWNERSHIP_VERIFICATION` | Prevent BOLA/IDOR through resource ownership checks |

These controls support the security boundary defined in `10641`.

---

## 4. Safe Redirect Utility Boundary

All redirect responses must be created through a single safe redirect utility.

The utility must:

- reject raw external URL unless explicitly allowlisted
- allow relative path only when safe
- reject protocol-relative URL such as `//example.com`
- reject backslash-based bypass such as `/\example.com`
- reject encoded external URL bypass
- reject `javascript:` and `data:` schemes
- reject nested redirect chains unless explicitly mapped
- verify host if absolute URL is allowed
- use destination ID mapping where possible
- log rejected attempt
- return safe fallback route
- emit security event when suspicious

Developers must not directly set `Location` header for application redirects.

---

## 5. Redirect Validation Rules

Redirect target validation must check:

| Validation | Required Behavior |
|---|---|
| Relative path starts with `/` | Allowed candidate |
| Starts with `//` | Deny |
| Starts with `/\` or encoded equivalent | Deny |
| Contains control characters | Deny |
| Uses `javascript:` | Deny |
| Uses `data:` | Deny |
| Uses unknown scheme | Deny |
| Absolute URL with unknown host | Deny |
| Absolute URL with allowed host | Allow only if policy permits |
| External destination without interstitial | Deny unless provider-reviewed |
| Nested redirect parameter | Deny or unwrap only by strict parser |
| Encoded attacker domain | Deny |
| Path traversal attempt | Deny |

Validation must use canonical parsing, not string checks alone.

String checks may supplement canonical parser.

---

## 6. Safe Redirect Flow

Recommended safe redirect flow:

    Request receives destination candidate
      -> Normalize and parse candidate
      -> If destination id exists, resolve server-side mapping
      -> If internal redirect, enforce safe relative path
      -> If external redirect, check allowlist and interstitial requirement
      -> If validation passes, generate redirect through safe utility
      -> If validation fails, redirect to safe fallback
      -> Log security event and audit context

Redirect failure must not expose the rejected target to the browser in detail.

---

## 7. Destination ID Mapping Boundary

Redirects should prefer indirect destination ID.

Examples:

| Destination ID | Server-Side Target |
|---|---|
| `dest_customer_home` | `/customer/home` |
| `dest_order_status` | `/customer/orders/status` |
| `dest_owner_dashboard` | `/owner/dashboard` |
| `dest_staff_kds` | `/staff/kds` |
| `dest_support_case` | `/support/case` |
| `dest_payment_return` | `/payment/return` |
| `dest_external_provider_help` | External provider help page with warning |

The client sends only the destination ID.

The server resolves the target after authority, scope, and policy checks.

---

## 8. Location Header Control Boundary

HTTP `Location` response header must be controlled.

Rules:

- only safe redirect utility may write `Location`
- header value must be sanitized
- header injection characters must be rejected
- external domains must be allowlisted
- error redirects must use safe fallback
- sensitive state must not be appended to `Location`
- audit must record redirect decision for sensitive flows

Location header injection must route to security event.

---

## 9. Referer And Origin Validation Boundary

Redirect and RPC flows may use Referer/Origin as supporting signals.

Referer/Origin validation should check:

- expected trusted origin
- tenant custom domain mapping
- admin/support origin restrictions
- payment return origin if applicable
- deep link transition state
- mismatch risk

Referer/Origin is supporting evidence.

It must not be the sole authorization mechanism.

Missing Referer may occur legitimately.

High-risk mismatch may require reauthentication or denial.

---

## 10. API Gateway And Reverse Proxy Boundary

External clients must communicate through gateway/proxy.

Gateway/proxy must:

- hide internal RPC service addresses
- hide internal ports
- hide service names
- terminate TLS or pass through according to approved architecture
- enforce host allowlist
- enforce route allowlist
- enforce authentication/authorization hooks
- apply rate limits
- redact logs
- attach request id
- preserve correlation id
- block direct internal route exposure
- route internal gRPC/JSON-RPC privately

The gateway is not the only security layer.

Backend services must still validate authority.

---

## 11. Internal RPC Endpoint Isolation Boundary

Internal RPC endpoints must not be exposed to public internet.

Internal RPC must be:

- private network only
- service-authenticated
- mTLS or signed service token where required
- least-privilege routed
- not callable from browser directly
- hidden behind gateway
- rate-limited internally
- logged with service identity
- denied if Host/header mismatch occurs

Internal endpoint exposure is security incident candidate.

---

## 12. POST And Request Body Enforcement Boundary

State-changing RPC must use request body.

State-changing operations include:

- payment capture
- refund/cancel/void
- order accept/cancel
- KDS ticket creation
- no-show penalty
- settlement release
- payout
- policy activation
- CMS publication
- export request
- supplier order
- IoT command
- account change
- support/admin action

URL query string must not carry sensitive command arguments.

Request body must still be validated server-side.

---

## 13. Payload Encryption Boundary

Transport encryption through HTTPS/TLS is mandatory.

Additional payload encryption may be considered for:

- highly sensitive mobile flows
- device provisioning
- payment-adjacent payloads
- evidence export
- local/offline sync
- internal service-to-service high-risk traffic

Payload encryption must not be used as excuse to skip server-side validation.

Encryption protects confidentiality.

It does not prove authority.

---

## 14. Nonce And State Boundary

Nonce/state values must be used for replay-prone flows.

Applicable flows:

- OAuth login
- payment return
- provider handoff
- deep link
- password reset
- invitation
- QR/NFC token
- device provisioning
- high-risk RPC
- export download
- account change
- support session handoff

Nonce/state must be:

- random
- short-lived
- single-use where possible
- server-stored or verifiable
- scope-bound
- purpose-bound
- consumed on success
- rejected on replay
- audited on failure

Consumed nonce must not be reusable.

---

## 15. Cookie Security Boundary

Cookie-based session must enforce:

- `HttpOnly`
- `Secure`
- `SameSite=Lax` or `SameSite=Strict` depending on flow
- narrow domain
- narrow path if applicable
- short expiry
- server-side revocation
- rotation after privilege change
- no sensitive data inside cookie payload unless encrypted/signed under approved design
- cache-control for sensitive pages

Cookie security attributes are mandatory baseline.

---

## 16. JWT / Token Strategy Boundary

If JWT or bearer token is used:

- access token must be short-lived
- refresh token must be server-managed or revocable
- token must carry minimal claims
- tenant/store/role claims must be revalidated where high-risk
- token rotation must be supported
- reuse detection must be supported
- blacklist/revocation must be supported
- logout must invalidate refresh path
- compromised token must be killable
- token must not be in URL

Stateless token must not become unrevocable authority.

---

## 17. Token Blacklist And Revocation Boundary

Server-side invalidation must support:

- logout
- password change
- MFA change
- session hijack suspicion
- device loss
- root/jailbreak detection
- support session end
- break-glass expiry
- admin privilege downgrade
- tenant role removal
- provider/key compromise
- global incident

Revocation must propagate to gateway, session store, refresh store, and service cache.

---

## 18. Session Context Binding Boundary

Session binding may use:

- device id
- browser fingerprint class
- user agent
- IP risk class
- ASN/network risk
- country/region risk
- auth strength
- surface id
- tenant/store context
- TLS/client attestation where available
- mobile integrity result

Context mismatch actions:

- allow with lower trust
- require step-up authentication
- revoke session
- force logout
- trigger security review
- block high-impact RPC

Context binding must be balanced against mobile network realities.

---

## 19. Access Token Lifetime Boundary

Token lifetime must match risk.

Candidate lifetime classes:

| Class | Candidate Use |
|---|---|
| `VERY_SHORT` | High-risk admin/finance/security actions |
| `SHORT` | Normal authenticated RPC |
| `MEDIUM` | Low-risk customer browsing |
| `SESSION_ONLY` | Web browser session |
| `ONE_TIME` | Reset, invite, QR/NFC, export |
| `DEVICE_BOUND` | Kiosk/tablet/SoftPOS device session |

Exact durations require security review.

This document does not approve specific minute/hour values.

---

## 20. Idle And Absolute Timeout Boundary

Session must support both idle timeout and absolute timeout.

Idle timeout prevents abandoned session abuse.

Absolute timeout prevents indefinitely active stolen session.

Privileged actions may require shorter timeout or reauthentication.

Timeout event must route to security/audit event bus.

---

## 21. Global Logout Kill-Switch Boundary

The platform must support global session invalidation.

Kill-switch use cases:

- suspected account compromise
- stolen device
- leaked token pattern
- gateway compromise
- provider callback abuse
- admin credential compromise
- root/jailbreak detection
- malware/automation detection
- incident response
- tenant breach containment

Kill-switch must invalidate:

- access token path
- refresh token path
- server session store
- API gateway cache
- WebSocket/gRPC stream session
- mobile device session
- support session
- admin session

Global logout must be auditable.

---

## 22. RPC Rate Limit And Abuse Boundary

RPC abuse controls must detect:

- brute force endpoint guessing
- hidden RPC method probing
- parameter tampering
- BOLA/IDOR attempts
- repeated redirect exploit attempts
- token replay
- high-frequency command attempts
- login/reset/invite abuse
- QR/NFC token brute force
- export download abuse
- provider callback flood
- admin/support route scanning

Actions may include:

- throttle
- block IP/session
- expire session
- require reauth
- route to SIEM
- quarantine tenant/device/session
- open circuit breaker for high-risk route

Rate limit must be scope-aware.

---

## 23. BOLA / IDOR Inline Ownership Verification Boundary

Every important RPC must verify target object ownership.

Verification must check:

- object tenant id
- object store id
- object legal entity id if financial
- actor role scope
- customer ownership if customer object
- staff/store assignment if staff object
- provider merchant mapping if provider object
- device assignment if device object
- support case scope if support access
- evidence packet scope if evidence access

URL guessing must not access or mutate another resource.

Database-level ownership check is required for high-risk objects.

---

## 24. Host Header And DNS Rebinding Boundary

Host header must be validated.

Controls:

- allowed host list
- tenant custom domain ownership verification
- reject unknown Host
- reject internal IP Host
- reject localhost/private network Host in production
- validate X-Forwarded-Host only from trusted proxy
- prevent absolute URL generation from untrusted Host
- prevent password reset/invite links using attacker Host
- prevent redirect allowlist bypass through Host manipulation

DNS rebinding and Host header attack must route to security event.

---

## 25. TLS Boundary

Transport security must be enforced.

Controls:

- HTTPS only
- HSTS where appropriate
- modern TLS policy
- weak cipher rejection
- certificate lifecycle monitoring
- gateway certificate rotation
- internal mTLS where applicable
- no mixed content
- no insecure downgrade
- secure cookie only over HTTPS

TLS protects transport.

It does not replace session and authority validation.

---

## 26. Server Header And Technology Disclosure Boundary

Response headers must not disclose unnecessary technology.

Suppress or control:

- `Server`
- `X-Powered-By`
- framework-specific headers
- internal gateway headers
- debug headers
- version banners
- stack traces
- service names

Security through obscurity is not sufficient, but reducing fingerprinting is useful.

---

## 27. CORS Hardening Boundary

CORS must be precise.

CORS rules:

- no wildcard origin with credentials
- allow only approved origins
- tenant custom origins require verification
- admin/support origins separate from customer origins
- methods restricted by endpoint
- headers restricted
- credentials only where required
- preflight cache controlled
- exposed headers minimized
- production disallows arbitrary localhost

CORS error must not reveal sensitive internal route info.

---

## 28. Mobile Certificate Pinning Boundary

Mobile app may use certificate/public key pinning for high-risk flows.

Pinning must consider:

- certificate rotation plan
- backup pins
- incident recovery
- staged rollout
- debug/test environment separation
- accessibility/support impact
- provider SDK constraints
- app update lag

Pinning failure may block session or require fallback policy.

Certificate pinning is defense-in-depth.

---

## 29. Mobile Code Obfuscation Boundary

Mobile client should reduce static reverse engineering.

Controls may include:

- code obfuscation
- string encryption
- endpoint string minimization
- anti-tamper checks
- build integrity markers
- debug flag removal
- log stripping
- secret exclusion from binary

Obfuscation does not protect server if server trusts client.

Server-side gates remain mandatory.

---

## 30. Secure Local Storage Boundary

Mobile tokens must be stored in secure OS-backed storage.

Examples:

- iOS Keychain
- Android Keystore-backed encrypted storage
- platform-approved secure storage
- hardware-backed key where available

Avoid:

- plain SharedPreferences
- plain localStorage
- plain SQLite
- debug logs
- screenshots
- clipboard
- unencrypted file cache

Device compromise must trigger revocation path.

---

## 31. WebView Redirect Intercept Boundary

Hybrid/WebView apps must intercept navigation.

WebView must block:

- unknown external domains
- malicious redirects
- file scheme abuse
- JavaScript bridge abuse
- deep link abuse
- untrusted download
- mixed content
- payment callback spoof
- external app launch without policy
- iframe/frame abuse

WebView navigation must use allowlist and server revalidation.

---

## 32. Root/Jailbreak And App Integrity Boundary

Mobile device integrity may affect session trust.

Signals:

- root/jailbreak detected
- emulator/debugger detected
- app signature mismatch
- tampered binary
- hooked runtime
- insecure screen overlay
- memory instrumentation
- certificate pinning bypass suspected

Actions:

- downgrade trust
- block high-risk RPC
- force reauthentication
- revoke session
- disable SoftPOS/payment functions
- route to security event

Integrity signal is risk evidence.

It must be handled carefully to avoid false positives.

---

## 33. Concurrent Session Control Boundary

Concurrent sessions must be governed.

Policy options:

- allow multiple low-risk customer sessions
- limit admin sessions
- limit finance/security sessions
- block duplicate SoftPOS sessions
- block duplicate staff device sessions
- require approval for new device
- notify user on new login
- revoke old session on high-risk change
- flag impossible travel/concurrent geography

Concurrency policy must be role and risk dependent.

---

## 34. Token Binding Boundary

Token binding may tie application session to lower-layer or device proof.

Possible binding signals:

- device key
- TLS/channel property where available
- mTLS client certificate for service/device
- mobile attestation
- secure enclave/keystore proof
- signed request payload
- session nonce chain

Token binding must not be assumed universally available.

Where unavailable, risk-based compensating controls must apply.

---

## 35. Inline Context Verification Boundary

Important RPC must re-check resource context at execution time.

Before executing:

- load resource from trusted database
- verify tenant/store/legal scope
- verify actor authority
- verify current state
- verify policy version
- verify idempotency
- verify evidence
- verify risk/circuit state
- verify ownership
- verify not stale/soft-deleted
- verify no hold/legal block

Do not trust request path or body alone.

---

## 36. Monitoring And SIEM Boundary

Security events must route to monitoring.

SIEM/security routing candidates:

- redirect target denied
- repeated redirect bypass attempts
- URL secret detected
- token in log detected
- CSRF failure spike
- CORS denial spike
- Host header mismatch
- DNS rebinding pattern
- session context mismatch
- token replay
- nonce replay
- BOLA/IDOR denied
- root/jailbreak high-risk session
- WebView external redirect blocked
- internal RPC endpoint exposure attempt
- brute-force hidden RPC route
- global logout triggered

Monitoring must support triage and containment.

---

## 37. Web Security Evidence Packet

Web security evidence packet may include:

- request id
- actor/session id
- tenant/store scope
- source IP/risk class
- user agent
- device id
- surface id
- attempted URL
- normalized URL
- redirect decision
- Origin/Referer
- Host header
- nonce/state id
- token id reference
- CSRF result
- CORS result
- rate limit result
- ownership check result
- session context binding result
- security event id
- audit reference

Sensitive values must be redacted.

Evidence packet must not store raw secrets.

---

## 38. Attack Scenario Defense Matrix

| Attack Scenario | Defense Mechanism |
|---|---|
| Open redirect using `?next=http://evil` | Safe redirect utility, allowlist, destination ID |
| Protocol-relative redirect `//evil` | Relative path validation and canonical parser |
| Encoded redirect bypass | Normalize before validation |
| Header injection in `Location` | Central redirect API and header sanitization |
| Session id in URL leak | URL secret prohibition and token transport policy |
| CSRF via external site | SameSite, CSRF token, Origin validation |
| CORS credential theft | Strict CORS allowlist |
| BOLA/IDOR by changing `order_id` | Inline resource ownership verification |
| JWT theft | Short access token, refresh revocation, context binding |
| Refresh token replay | Rotation, reuse detection, blacklist |
| Mobile MITM proxy | Certificate pinning and TLS enforcement |
| App reverse engineering | Obfuscation, string protection, server-side gates |
| Token from rooted device | Integrity detection and session revocation |
| QR token replay | Nonce, expiry, server consumed marker |
| Payment success page spoof | Server-side payment state verification |
| Provider callback spoof | Signature, merchant, transaction, amount matching |
| Host header poisoning | Host allowlist and trusted proxy handling |
| Internal RPC scanning | VPC isolation, gateway, service auth |
| Sensitive logs exposure | Log redaction and URL secret detection |
| Admin route guessing | Server-side role/scope/authority gate |
| Export URL sharing | Short-lived scoped export token |
| WebView malicious redirect | WebView intercept allowlist |
| Session fixation | Session regeneration after auth/elevation |
| Concurrent hijack | Session concurrency and global logout |
| Replay attack | Nonce/state and idempotency gates |

Attack defense must be tested.

---

## 39. Security Checklist Registry

The following 35-rule registry is adopted as a planning checklist:

| No. | Rule |
|---:|---|
| 1 | Redirect destination allowlist |
| 2 | Relative path enforcement |
| 3 | Indirect destination ID |
| 4 | URL input validation schema |
| 5 | External link disclaimer/interstitial |
| 6 | Safe `Location` header control |
| 7 | Referer/Origin validation |
| 8 | No session id or token in URL |
| 9 | State-changing RPC uses POST/body |
| 10 | API gateway route abstraction |
| 11 | SPA route separated from backend authority |
| 12 | Directory listing disabled |
| 13 | Error page and stack trace suppression |
| 14 | HttpOnly/Secure/SameSite cookies |
| 15 | Session regeneration after auth/elevation |
| 16 | Session context binding |
| 17 | Short access token and refresh strategy |
| 18 | Server-side blacklist/revocation |
| 19 | Idle and absolute timeout |
| 20 | Abnormal RPC rate limiting |
| 21 | Server technology header suppression |
| 22 | TLS enforcement and secure termination |
| 23 | Strict CORS |
| 24 | Internal RPC VPC/private isolation |
| 25 | DNS rebinding and Host header defense |
| 26 | Mobile certificate pinning |
| 27 | Mobile obfuscation and string protection |
| 28 | Secure local token storage |
| 29 | WebView redirect intercept |
| 30 | Root/jailbreak/app integrity session control |
| 31 | Concurrent session control |
| 32 | Cryptographic nonce/state |
| 33 | Token binding where available |
| 34 | Global logout kill-switch |
| 35 | Inline context ownership verification |

Checklist completion does not equal runtime authorization.

---

## 40. Relationship To Tenant Scope Envelope

Every security control must enforce scope.

Examples:

- redirect destination may depend on tenant custom domain
- session must bind tenant/store context
- CORS origin may be tenant-branded and verified
- export token must be tenant/store/legal scoped
- QR/NFC token must be store/table scoped
- BOLA check must compare target object tenant/store with session
- support/admin route must be case-scoped

Scope failure must deny.

---

## 41. Relationship To Authority Capability Gate

Security validation is not authority by itself.

Even after a request passes redirect/session/CORS/CSRF validation, command must still pass:

- identity gate
- role gate
- scope gate
- entitlement gate
- policy gate
- state transition gate
- evidence gate
- risk gate
- device trust gate
- provider readiness gate
- financial limit gate
- approval gate
- audit gate
- compliance gate
- human review gate

Security passes the door.

Authority decides the action.

---

## 42. Relationship To Event Bus And Audit

Every denied or suspicious security action must route through event/audit rules.

Event examples:

- `REDIRECT_TARGET_DENIED`
- `URL_SECRET_DETECTED`
- `SESSION_CONTEXT_MISMATCH`
- `TOKEN_REPLAY_DETECTED`
- `RPC_RATE_LIMIT_TRIGGERED`
- `BOLA_IDOR_DENIED`
- `HOST_HEADER_DENIED`
- `WEBVIEW_REDIRECT_BLOCKED`
- `MOBILE_INTEGRITY_FAILED`
- `GLOBAL_LOGOUT_TRIGGERED`

Security event must not include raw secrets.

---

## 43. Anti-Patterns

Avoid:

- developer-written ad hoc redirect
- raw redirect URL in query
- URL regex without canonical parser
- gateway hiding internal path but backend trusting client
- JWT with long lifetime and no revocation
- refresh token reuse not detected
- token stored in localStorage/plain storage
- wildcard CORS with credentials
- internal RPC exposed publicly
- app obfuscation treated as real security
- certificate pinning without rotation plan
- root detection blocking all users without review path
- admin route protected only by frontend
- object id ownership not checked in DB
- security logs storing full URL with token
- global logout not propagated to WebSocket/gRPC/session caches
- GET request with hidden mutation
- QR/NFC token reused indefinitely
- payment return page treated as payment proof

These anti-patterns must be blocked in future runtime design.

---

## 44. Runtime Deferral

This document defines implementation guide boundaries for web/RPC redirect, session, infrastructure, mobile, monitoring, and advanced security controls only.

It does not authorize:

- middleware implementation
- redirect utility implementation
- API gateway configuration
- reverse proxy configuration
- CORS configuration
- TLS deployment
- JWT/session runtime
- Redis/session store
- mobile pinning
- app obfuscation
- WebView interceptor
- root/jailbreak detection
- SIEM integration
- global logout runtime
- inline ownership verification implementation
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 45. Validation Checklist

Validation must confirm:

1. Implementation control catalog is defined.
2. Safe redirect utility boundary is defined.
3. Redirect validation rules are defined.
4. Safe redirect flow is defined.
5. Destination ID mapping boundary is defined.
6. Location header control boundary is defined.
7. Referer/Origin validation boundary is defined.
8. API gateway/reverse proxy boundary is defined.
9. Internal RPC endpoint isolation boundary is defined.
10. POST/body enforcement boundary is defined.
11. Payload encryption boundary is defined.
12. Nonce/state boundary is defined.
13. Cookie security boundary is defined.
14. JWT/token strategy boundary is defined.
15. Token blacklist/revocation boundary is defined.
16. Session context binding boundary is defined.
17. Token lifetime boundary is defined.
18. Idle/absolute timeout boundary is defined.
19. Global logout kill-switch boundary is defined.
20. RPC rate limit/abuse boundary is defined.
21. BOLA/IDOR inline ownership verification boundary is defined.
22. Host header/DNS rebinding boundary is defined.
23. TLS boundary is defined.
24. Server header/technology disclosure boundary is defined.
25. CORS hardening boundary is defined.
26. Mobile certificate pinning boundary is defined.
27. Mobile code obfuscation boundary is defined.
28. Secure local storage boundary is defined.
29. WebView redirect intercept boundary is defined.
30. Root/jailbreak/app integrity boundary is defined.
31. Concurrent session control boundary is defined.
32. Token binding boundary is defined.
33. Inline context verification boundary is defined.
34. Monitoring/SIEM boundary is defined.
35. Web security evidence packet is defined.
36. Attack scenario defense matrix is defined.
37. 35-rule security checklist registry is defined.
38. Relationships to Tenant Scope Envelope, Authority Capability Gate, Event Bus, and Audit are defined.
39. Anti-patterns are listed.
40. Coding remains unauthorized.
41. Runtime remains deferred.

---

## 46. Relationship To Previous Documents

This document supplements:

- `10641 Web App RPC Session Redirect URL And Parameter Exposure Security Policy`

It references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10641 Web App RPC Session Redirect URL And Parameter Exposure Security Policy`

It prepares:

- future web gateway security implementation packet
- future redirect utility specification
- future RPC session lifecycle specification
- future CORS/TLS/header hardening checklist
- future mobile client integrity specification
- future BOLA/IDOR ownership verification test matrix
- future SIEM/security event routing matrix

This document is architecture boundary planning only.

It does not authorize coding.

---

## 47. Final Rule

Redirect, URL, session, gateway, mobile, and RPC security must be implemented as centralized platform controls, not scattered developer conventions.

All redirects must pass a safe redirect utility.

All state-changing RPC must pass gateway, session, scope, CSRF/origin, payload, authority, idempotency, and ownership checks.

No token, session id, secret, sensitive object reference, or authority-bearing value may be placed in browser-visible URL, redirect URL, logs, referrer, QR/NFC token, deep link, or export link without strict opaque token controls.

Mobile clients must use secure storage, integrity controls, and network hardening, but server-side authority remains mandatory.

Suspicious redirect, URL tamper, token replay, session mismatch, Host/CORS abuse, BOLA/IDOR attempt, WebView redirect, and mobile integrity failure must generate security events and route to monitoring.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
