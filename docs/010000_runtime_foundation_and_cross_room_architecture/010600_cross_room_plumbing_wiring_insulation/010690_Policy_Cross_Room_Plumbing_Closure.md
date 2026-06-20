# 010690_Policy_Cross_Room_Plumbing_Closure.md

## Purpose

This document closes the Cross-Room Plumbing, Wiring, Insulation, Routing, Containment, Reconciliation, Projection, and Audit Planning Sequence.

The previous artifacts defined:

- `10600 Cross-Room Plumbing Wiring Insulation Planning Index`
- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10641 Web App RPC Session Redirect URL And Parameter Exposure Security Policy`
- `10642 Web RPC Redirect Session Infrastructure Mobile And Deep Security Implementation Guide Policy`
- `10643 Zero Trust M2M Queue Database DevSecOps And Security Checklist Completion Policy`
- `10650 Failure Containment Circuit Breaker Policy`
- `10660 Idempotency Retry Replay Reconciliation Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`

This document closes the axis and defines the cross-room construction completion rules before the next architectural axis is opened.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

The cross-room infrastructure skeleton is now defined at architecture boundary level.

The correct rule is:

Rooms own truth.  
Pipes move events and evidence.  
Wires move commands, queries, projections, and notifications.  
Insulation protects tenant, store, legal, provider, device, actor, audience, and data scope.  
Valves enforce authority and capability gates.  
Circuit breakers contain failure.  
Meters audit and batch-check what happened.  
Filters mask and i18n-route what humans see.  
Backflow preventers stop replay, duplicate execution, and silent mutation.  
Inspection ports preserve evidence for reconciliation and review.  
Fire doors quarantine security and tenant isolation incidents.  

No room may directly mutate another room’s source truth without command, scope, authority, evidence, audit, idempotency, containment, and reconciliation rules.

---

## 3. Closed Planning Scope

This closure covers the following cross-room infrastructure concerns:

| Area | Closed At Boundary Level |
|---|---|
| Event bus | Yes |
| Evidence packet routing | Yes |
| Command/query/projection separation | Yes |
| Authority/capability gate | Yes |
| Tenant scope envelope | Yes |
| Web/RPC redirect/session/URL security | Yes |
| Zero Trust/M2M/queue/DB/DevSecOps security | Yes |
| Failure containment/circuit breaker | Yes |
| Idempotency/retry/replay/reconciliation | Yes |
| Safe projection/i18n routing | Yes |
| Audit correlation/nightly batch | Yes |

This closure means the planning skeleton exists.

It does not mean implementation is approved.

---

## 4. Cross-Room Infrastructure Map

The platform now has the following cross-room infrastructure map:

| Construction Analogy | Platform Meaning |
|---|---|
| Plumbing | Event and evidence flow |
| Wiring | Command, query, projection, notification, and policy flow |
| Insulation | Tenant isolation, masking, visibility, privacy, and authority separation |
| Valves | Capability gates, authority gates, feature gates |
| Circuit breakers | Failure containment and route blocking |
| Backflow preventers | Idempotency, replay control, duplicate suppression |
| Meters | Audit, metrics, reconciliation, and batch |
| Fire doors | Security quarantine, tenant containment, provider isolation |
| Inspection ports | Evidence packets, DLQ, reconciliation cases, review surfaces |
| Labels | i18n message keys, state markers, reason codes |
| Blueprints | Policy version, scope envelope, schema version |
| Shutoff valves | Circuit open, financial hold, security quarantine, policy freeze |
| Maintenance hatch | Break-glass, manual fallback, recovery workflow |
| Structural beams | Tenant scope, authority separation, source ownership, auditability |

This infrastructure supports all rooms but owns none of their source truth.

---

## 5. Cross-Room Golden Rules

The following golden rules are now adopted for this axis:

1. Event is not command.
2. Command is not authority by itself.
3. Query must not mutate.
4. Projection is not source truth.
5. Evidence is not approval.
6. Audit is not execution.
7. Retry is not new intent.
8. Replay is not overwrite.
9. Reconciliation is not silent correction.
10. Fallback is not silent mutation.
11. Timeout is not success.
12. Timeout is not final failure.
13. Provider callback is not verified state until matched.
14. Sensor signal is not billing authority.
15. AI output is not authority.
16. pgvector similarity is not proof.
17. CMS message is not policy authority.
18. i18n rendering is not business logic.
19. Tenant scope missing means deny.
20. Cross-tenant mismatch is high severity.
21. Device connected is not device trusted.
22. Provider configured is not provider ready.
23. Session exists is not permission.
24. Support visibility is not owner authority.
25. Admin power still requires gate, audit, and scope.
26. Batch must not overwrite source truth.
27. Frozen close must not be silently changed.
28. DLQ is not deletion.
29. Quarantine is not resolution.
30. Containment is not recovery.

These rules must be referenced by later implementation documents.

---

## 6. Source Ownership Closure

Source truth ownership remains separated.

| Source Truth | Owner |
|---|---|
| Order lifecycle | Store Runtime / Order Validation |
| POS handoff | POS Handoff Room |
| KDS ticket state | KDS Ticket Room |
| Kitchen execution | Kitchen Execution Room |
| Payment state | Financial Trust |
| Refund/cancel/void state | Financial Trust |
| Coupon/point/wallet ledger | Financial Trust |
| Settlement/payout/split/royalty | Financial Trust |
| Device identity and trust | Device Runtime |
| Local/offline chain | Device Runtime / Reconciliation |
| Sensor raw evidence | Data Governance / Store Runtime / Security |
| IoT execution evidence | Store Runtime / Device Runtime |
| CMS content | CMS Governance |
| i18n message key | i18n Governance |
| Safe projection | Data Governance |
| AI advisory output | AI Advisory Runtime |
| pgvector retrieval | pgvector Governance |
| Analytics read model | Analytics Governance |
| Export/retention | Retention/Export Governance |
| Security containment | Security Governance |
| Audit/WORM/hash | Audit/Security Governance |
| Batch/reconciliation | Reconciliation Governance |
| Policy version | Policy Governance |
| Supplier/SCM state | SCM/Supplier Governance |
| DR/failover state | DR Governance |

Routing across owners requires envelope, evidence, and audit.

---

## 7. Event Bus Closure

The event bus boundary is closed with the following rules:

- All events require event family and event type.
- All events require scope envelope.
- All events require correlation id where cross-room.
- All events require causation id where caused by prior event/command.
- High-impact events require evidence packet reference.
- Malformed events go to DLQ.
- Cross-tenant events are denied or quarantined.
- Provider events are verified before becoming internal truth.
- Sensor events are candidate evidence.
- AI/vector events are advisory/contextual.
- Security events are not ordinary telemetry.
- Financial events require stricter audit and reconciliation readiness.
- Event bus itself must be audited and batch-checked.

Event bus does not own domain truth.

---

## 8. Evidence Packet Closure

Evidence packet boundary is closed with the following rules:

- Evidence packet bundles references, not uncontrolled raw secrets.
- Evidence supports review and reconciliation.
- Evidence does not approve action.
- Evidence must be tenant/store/legal scoped.
- Evidence access must be audience-scoped and masked.
- High-impact financial, security, policy, export, and sensor cases require evidence.
- Evidence must survive retries, replays, DLQ, batch, and reconciliation.
- Evidence packet must be auditable.
- WORM/hash references are required for critical trails where policy requires.

Evidence packet is inspection infrastructure.

It is not source mutation.

---

## 9. Command Query Projection Closure

CQP separation is closed with the following rules:

| Type | Closure Rule |
|---|---|
| Command | Requests mutation, must pass authority |
| Query | Reads, must not mutate |
| Projection | Shows safe visibility, not source truth |
| Event | Records fact/observation/state transition |
| Evidence | Supports review, not approval |
| Audit | Records trace, not execution |
| Reconciliation | Resolves uncertainty through evidence |
| DLQ | Contains unsafe/unprocessable messages |
| AI output | Advisory only |
| Sensor observation | Evidence candidate only |
| Provider signal | External evidence until matched |

No later design may collapse these categories without explicit override.

---

## 10. Authority Gate Closure

Authority gate boundary is closed with the following rule set:

Every high-impact command must evaluate:

- identity
- role
- scope
- feature entitlement
- policy version
- state transition
- evidence
- risk
- device trust
- provider readiness
- financial limits
- approval requirements
- privacy/visibility
- physical safety
- idempotency
- audit availability
- time window
- circuit breaker state
- compliance readiness
- human review requirement

Default is:

    DENY_UNLESS_EXPLICITLY_ALLOWED

Capability is not authority.

---

## 11. Tenant Scope Envelope Closure

Tenant scope envelope boundary is closed with the following rules:

- Every object must carry scope.
- Every route must preserve scope.
- Every command must validate scope.
- Every query must enforce visibility scope.
- Every projection must preserve audience scope.
- Every evidence packet must be scoped.
- Every export must be scoped.
- Every AI/vector input must be scoped.
- Every provider event must map to tenant/store/legal scope.
- Every device event must match device registry scope.
- Every queue message must preserve scope.
- Every batch run must validate scope.
- Cross-tenant mismatch fails closed.

Default is:

    CROSS_TENANT_ACCESS_DENIED

No SaaS feature is ready if isolation cannot be proven.

---

## 12. Web RPC Security Closure

The web/RPC security supplemental boundary is closed with the following rules:

- Redirect targets must be allowlisted or indirect-reference mapped.
- Internal navigation should prefer safe relative path.
- Session id and tokens must not appear in URL.
- GET must not mutate state.
- Sensitive RPC payload must not live in query string.
- RPC method names must be abstracted.
- Session must be revocable server-side.
- Session must regenerate after login/elevation.
- CORS must be allowlisted.
- CSRF/origin controls must protect browser commands.
- Host header and DNS rebinding must be defended.
- Deep links, QR/NFC, export links, reset links, invite links, and signed URLs must be scoped and short-lived.
- Logs must redact secrets.
- SPA route is UX, not authority.
- Admin/support URL is not permission.

These controls protect the outer wall and internal corridors.

---

## 13. Zero Trust Closure

Zero Trust supplemental boundary is closed with the following rules:

- Internal service is not trusted by private IP alone.
- M2M communication requires service identity.
- mTLS or equivalent strong service authentication is required where risk demands.
- Context must propagate end-to-end.
- Client-supplied internal headers must be stripped or ignored.
- Service-to-service routes must be explicitly allowed.
- Micro-segmentation must prevent lateral movement.
- Queue payload must not carry raw session authority.
- Session store must protect sensitive data.
- Security audit must be isolated from mutable app logs.
- DevSecOps gates must scan secrets, code, dependencies, dynamic surfaces, and headers.
- Threat modeling is required for high-risk route/session/callback/API changes.

Zero Trust extends beyond the gateway.

---

## 14. Failure Containment Closure

Failure containment boundary is closed with the following rules:

- Failure must be contained at smallest safe scope.
- Circuit breaker state must be explicit.
- Timeout creates uncertainty.
- Provider failure does not become internal truth.
- Tenant overload must not harm other tenants.
- Store failure must not harm other stores.
- Device compromise must quarantine device.
- Queue backpressure protects core systems.
- DLQ contains unsafe events.
- Security quarantine contains suspected attack.
- Financial hold preserves uncertainty.
- Fallback must be marked and reconciled.
- Recovery requires evidence and verification.
- Circuit reclose must be controlled.

Containment protects the platform.

It does not resolve the case by itself.

---

## 15. Idempotency Retry Replay Reconciliation Closure

Idempotency and reconciliation boundary is closed with the following rules:

- Every high-impact action requires idempotency boundary.
- Same key with different payload is conflict.
- Retry must preserve idempotency and backoff.
- Retry must not duplicate payment, refund, payout, supplier order, KDS ticket, or IoT command.
- Replay must not overwrite original history.
- Timeout requires verification.
- Offline sync is provisional until central acceptance.
- Provider callback must be matched.
- Batch replay must be deterministic and append-only.
- Reconciliation compares evidence.
- Amendment is append-only.
- Frozen truth requires restatement, not overwrite.
- DLQ may route to reconciliation.
- Uncertainty must be projected safely.

Duplicate execution is architecture failure.

---

## 16. Safe Projection i18n Closure

Safe projection and i18n boundary is closed with the following rules:

- Projection is visibility, not truth.
- All human-visible text must use i18n keys.
- Hardcoded operational text is prohibited.
- Audience class is mandatory.
- Masking class is mandatory.
- Customer projection must not expose internal security detail.
- Owner projection must be store/tenant scoped.
- Support projection must be case scoped.
- Finance projection must preserve legal entity scope.
- Security projection must avoid unnecessary business data.
- AI advisory must be labeled.
- Sensor evidence must be redacted.
- Financial uncertainty must not be rendered as confirmation.
- Missing high-risk message key blocks readiness.
- High-risk legal/financial/privacy/security wording requires review.

Friendly language must remain truthful.

---

## 17. Audit Batch Closure

Audit correlation and nightly batch boundary is closed with the following rules:

- Runtime event must be batch-checkable.
- Audit must correlate across rooms.
- Financial batch must compare internal ledger, provider ledger, POS/terminal record, and OS runtime audit where applicable.
- Batch mismatch creates reconciliation, hold, DLQ, review, or amendment candidate.
- Batch must not mutate source truth silently.
- Batch replay must not overwrite prior batch report.
- Batch hash root may support integrity.
- WORM/hash must protect critical closure.
- Audit gap is incident candidate.
- Cross-tenant audit mismatch is high severity.
- Nightly close must not finalize unresolved truth.
- Period close must preserve amendment lineage.

Batch is inspection.

It is not hidden mutation.

---

## 18. Cross-Room Gate Order

For high-impact flows, recommended gate order is:

1. Request/session validation.
2. Tenant scope envelope validation.
3. Command/query/projection classification.
4. Authority/capability gate.
5. Policy version check.
6. Idempotency check.
7. State transition check.
8. Evidence requirement check.
9. Risk/circuit breaker check.
10. Device/provider readiness check.
11. Execution or routing.
12. Event emission.
13. Audit capture.
14. Projection update.
15. Batch inspection.
16. Reconciliation if needed.

Gate order may vary by domain, but no high-impact flow may skip these concerns.

---

## 19. Cross-Room Failure Escalation Path

Recommended escalation path:

1. Detect anomaly.
2. Mark uncertain state.
3. Contain route/scope.
4. Create event.
5. Create audit.
6. Create evidence packet.
7. Apply financial hold if financial.
8. Apply security quarantine if security.
9. Route to DLQ if malformed.
10. Create reconciliation case if mismatch.
11. Show safe projection.
12. Assign owner.
13. Review evidence.
14. Apply amendment or release hold.
15. Verify recovery.
16. Close with audit.

Escalation must not skip evidence.

---

## 20. Cross-Room Readiness Registry

A room is not ready for runtime if it lacks:

| Requirement | Required |
|---|---|
| Source ownership defined | Yes |
| Event family defined | Yes |
| Command/query/projection separation | Yes |
| Scope envelope | Yes |
| Authority gate | Yes |
| Evidence packet rule | Yes |
| Idempotency rule | Yes |
| Retry/replay rule | Yes |
| DLQ/quarantine rule | Yes |
| Circuit breaker rule | Yes |
| Safe projection rule | Yes |
| i18n key coverage | Yes |
| Audit rule | Yes |
| Batch/reconciliation rule | Yes |
| Security event rule | Yes |
| Tenant isolation test | Yes |

Missing any critical item blocks implementation readiness.

---

## 21. Integration Readiness Matrix

| Integration Type | Required Cross-Room Controls |
|---|---|
| Payment provider | Scope, provider readiness, idempotency, reconciliation, audit, batch |
| POS integration | Scope, device/provider mapping, retry, DLQ, safe projection |
| KDS integration | Source ownership, duplicate ticket prevention, fallback, audit |
| Coupon/point/wallet | Ledger, idempotency, projection, reconciliation |
| No-show deposit | Policy, evidence, legal wording, financial hold, dispute path |
| SoftPOS | Device trust, attestation, token security, provider reconciliation |
| QR/NFC | Token scope, replay control, session boundary, safe projection |
| UWB/spatial | Sensor evidence, review gate, privacy, no billing authority |
| Vision/Acoustic | Privacy, redaction, review, evidence, no direct authority |
| Kitchen IoT | Safety gate, device trust, idempotency, physical containment |
| SCM/Supplier | Supplier idempotency, invoice reconciliation, authority |
| AI advisory | Scope, masking, source refs, non-authority, projection label |
| pgvector | Scope filter, source refs, similarity not proof |
| CMS/i18n | Approval, locale coverage, safe publication |
| Export/retention | Scope, approval, token expiry, audit, legal hold |
| Franchise OS | Tenant/store/brand/legal scope, aggregate masking, authority |
| Web/RPC | Redirect, session, URL, CORS, CSRF, BOLA/IDOR, logs |
| M2M/queue | mTLS, context propagation, queue minimization, audit |

Every integration must declare its matrix before implementation.

---

## 22. Open Implementation Packages

The following runtime packages remain unopened:

- event envelope schema
- evidence packet schema
- command gateway
- query gateway
- projection builder
- authority gate engine
- tenant scope validation service
- redirect/session/RPC gateway security
- Zero Trust M2M context propagation
- DLQ and reconciliation engine
- idempotency store
- retry scheduler
- replay engine
- circuit breaker engine
- financial hold engine
- safe projection/i18n runtime
- audit correlation store
- nightly batch scheduler
- WORM/hash chain integration
- DevSecOps release gate
- security event SIEM routing

These require separate explicit authorization.

---

## 23. Runtime Deferral Confirmation

This closure does not authorize:

- coding
- schema creation
- migrations
- service implementation
- queue creation
- gateway implementation
- security middleware
- RLS/security rules
- mobile client changes
- API contracts
- provider integration
- production configuration
- deployment
- CI/CD changes
- WORM storage setup
- monitoring/SIEM setup

All runtime remains deferred.

---

## 24. Boundary Completion Status

The boundary planning status is:

| Area | Status |
|---|---|
| Cross-room event/evidence routing | Boundary complete |
| CQP separation | Boundary complete |
| Authority/capability gate | Boundary complete |
| Tenant scope envelope | Boundary complete |
| Web/RPC security supplement | Boundary complete |
| Zero Trust/DevSecOps supplement | Boundary complete |
| Failure containment/circuit breaker | Boundary complete |
| Idempotency/retry/replay/reconciliation | Boundary complete |
| Safe projection/i18n routing | Boundary complete |
| Audit correlation/nightly batch | Boundary complete |
| Runtime implementation | Not authorized |
| Static artifact implementation | Not authorized |
| Database schema | Not authorized |
| Production deployment | Not authorized |

Planning closure does not equal runtime readiness.

---

## 25. Recommended Next Axis

After this closure, the next architectural axis may be one of the following:

| Candidate Axis | Purpose |
|---|---|
| `10700 Security And Trust Foundation Index` | Consolidate security foundation across web, tenant, financial, device, provider, audit, DevSecOps |
| `10800 Provider Integration Adapter Skeleton Index` | Define provider adapter rooms for POS, KDS, PG, VAN, bank, supplier |
| `10900 Device Trust And Local Runtime Skeleton Index` | Define device identity, kiosk/tablet/SoftPOS/local hub/IoT runtime |
| `11000 Financial Ledger And Settlement Kernel Skeleton Index` | Define financial ledger internals more deeply |
| `11100 Runtime Authorization Candidate Index` | Prepare carefully selected first static implementation packet |
| `11200 Store Degraded Operation And Manual Recovery SOP Index` | Convert degraded/fallback into SOP documents |

Recommended next axis:

    10700 Security And Trust Foundation Index

Reason:

The recent web/RPC, Zero Trust, tenant isolation, provider trust, device trust, financial trust, audit/WORM, AI/vector, sensor, and DevSecOps rules have become large enough to justify a dedicated security foundation axis before any implementation packet is reopened.

---

## 26. Validation Checklist

Validation must confirm:

1. Cross-room infrastructure map is defined.
2. Golden rules are listed.
3. Source ownership closure is defined.
4. Event bus closure is defined.
5. Evidence packet closure is defined.
6. CQP closure is defined.
7. Authority gate closure is defined.
8. Tenant scope envelope closure is defined.
9. Web/RPC security closure is defined.
10. Zero Trust closure is defined.
11. Failure containment closure is defined.
12. Idempotency/retry/replay/reconciliation closure is defined.
13. Safe projection/i18n closure is defined.
14. Audit/batch closure is defined.
15. Cross-room gate order is defined.
16. Cross-room failure escalation path is defined.
17. Cross-room readiness registry is defined.
18. Integration readiness matrix is defined.
19. Open implementation packages are listed.
20. Runtime deferral is confirmed.
21. Boundary completion status is recorded.
22. Recommended next axis is declared.
23. Coding remains unauthorized.
24. Runtime remains deferred.

---

## 27. Relationship To Previous Documents

This document closes the sequence opened by:

- `10600 Cross-Room Plumbing Wiring Insulation Planning Index`

It closes and consolidates:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10641 Web App RPC Session Redirect URL And Parameter Exposure Security Policy`
- `10642 Web RPC Redirect Session Infrastructure Mobile And Deep Security Implementation Guide Policy`
- `10643 Zero Trust M2M Queue Database DevSecOps And Security Checklist Completion Policy`
- `10650 Failure Containment Circuit Breaker Policy`
- `10660 Idempotency Retry Replay Reconciliation Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`

It prepares the next architectural axis:

- `10700 Security And Trust Foundation Index`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 28. Final Rule

The cross-room plumbing, wiring, insulation, gate, containment, reconciliation, projection, and audit skeleton is now closed at planning level.

All future rooms, integrations, surfaces, providers, devices, ledgers, queues, AI/vector flows, sensors, CMS/i18n flows, exports, and admin/support surfaces must obey this cross-room infrastructure.

No room may bypass tenant scope, authority gate, evidence packet, event routing, idempotency, containment, reconciliation, safe projection, i18n, audit, and batch inspection.

No runtime implementation is authorized by this closure.

The next recommended axis is `10700 Security And Trust Foundation Index`.
