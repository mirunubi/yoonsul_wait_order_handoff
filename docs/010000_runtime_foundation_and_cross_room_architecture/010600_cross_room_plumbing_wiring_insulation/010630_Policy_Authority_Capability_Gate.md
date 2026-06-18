# 010630_Policy_Authority_Capability_Gate

## 1. Purpose

This document defines the Authority Capability Gate Policy.

The previous artifact `10620 Command Query Projection Separation Policy` separated commands, queries, projections, events, evidence, audit, reconciliation, DLQ, AI output, provider signals, and sensor observations.

This document defines the gate layer that determines whether a command, event reaction, projection build, provider action, AI recommendation, sensor-derived candidate, device action, financial action, or physical execution may proceed.

The purpose is to ensure that no feature, role, device, tenant, provider, AI agent, sensor system, admin surface, support surface, or automated workflow can act merely because it can see data or emit an event.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Capability must be separated from authority.

The correct rule is:

Feature available does not mean actor authorized.  
Role exists does not mean action permitted.  
Device connected does not mean device trusted.  
Provider configured does not mean provider verified.  
AI recommendation does not mean approval.  
Sensor confidence does not mean execution authority.  
Projection visibility does not mean mutation authority.  
Support access does not mean ownership.  
Admin access does not mean financial authority.  
Tenant entitlement does not mean compliance readiness.  
Capability flag does not override policy gate.  
Authority must be explicit, scoped, evidenced, and auditable.  

The platform must gate every high-impact action through context-aware authority checks.

---

## 3. Authority Gate Scope

This policy applies to authority checks for:

- customer commands
- store staff commands
- owner commands
- franchise HQ commands
- platform support commands
- platform finance commands
- platform security commands
- admin commands
- automated system commands
- AI-generated command candidates
- provider callback reactions
- sensor-derived command candidates
- KDS/POS actions
- payment/refund/capture actions
- settlement/payout actions
- no-show penalty actions
- fast payout actions
- policy activation actions
- CMS publication actions
- export actions
- data retention actions
- device provisioning actions
- SoftPOS activation actions
- IoT device commands
- supplier orders
- DR failover promotion
- manual adjustments
- break-glass access

Every action must pass an authority gate before execution.

---

## 4. Capability Gate Catalog

The following gate families are required:

| Gate Family | Purpose |
|---|---|
| `IDENTITY_GATE` | Who is acting |
| `ROLE_GATE` | What role the actor holds |
| `SCOPE_GATE` | Which tenant/store/legal scope applies |
| `FEATURE_ENTITLEMENT_GATE` | Whether tenant/package has feature entitlement |
| `POLICY_GATE` | Whether active policy allows the action |
| `STATE_TRANSITION_GATE` | Whether current state permits action |
| `EVIDENCE_GATE` | Whether required evidence exists |
| `RISK_GATE` | Whether risk state allows action |
| `DEVICE_TRUST_GATE` | Whether device is trusted |
| `PROVIDER_READINESS_GATE` | Whether provider is verified and available |
| `FINANCIAL_LIMIT_GATE` | Whether amount/threshold is allowed |
| `MULTI_PARTY_APPROVAL_GATE` | Whether extra approval is required |
| `PRIVACY_VISIBILITY_GATE` | Whether data may be viewed or exported |
| `SAFETY_GATE` | Whether physical execution is safe |
| `IDEMPOTENCY_GATE` | Whether action is duplicate-safe |
| `AUDIT_GATE` | Whether action can be audited |
| `TIME_WINDOW_GATE` | Whether action is allowed at this time |
| `CIRCUIT_BREAKER_GATE` | Whether route/feature is open, half-open, or blocked |
| `COMPLIANCE_GATE` | Whether legal/compliance readiness exists |
| `HUMAN_REVIEW_GATE` | Whether human review is required before proceeding |

High-impact commands may require multiple gates.

---

## 5. Authority Context Boundary

Every command must carry authority context.

Recommended authority context fields:

| Field | Meaning |
|---|---|
| `actor_id` | Acting user/system |
| `actor_type` | Customer, staff, owner, HQ, support, finance, security, system |
| `role_id` | Role assigned |
| `role_scope` | Scope of role |
| `tenant_id` | Tenant context |
| `store_id` | Store context |
| `brand_id` | Brand context |
| `operating_group_id` | Operating group context |
| `legal_entity_id` | Legal/accounting context |
| `surface_id` | UI/API/device surface |
| `device_id` | Device used |
| `session_id` | Session context |
| `feature_id` | Feature being invoked |
| `capability_id` | Capability being used |
| `policy_version` | Active policy version |
| `risk_state` | Risk state |
| `approval_context` | Approval references |
| `evidence_packet_id` | Supporting evidence |
| `authority_decision_id` | Gate decision id |

No high-impact command may execute without authority context.

---

## 6. Authority Decision State Skeleton

Recommended authority decision states:

| State | Meaning |
|---|---|
| `AUTHORITY_NOT_EVALUATED` | Gate not evaluated |
| `AUTHORITY_EVALUATING` | Gate evaluation in progress |
| `AUTHORITY_ALLOWED` | Allowed |
| `AUTHORITY_DENIED` | Denied |
| `AUTHORITY_PARTIAL_ALLOWED` | Allowed only in limited scope |
| `AUTHORITY_REVIEW_REQUIRED` | Human review required |
| `AUTHORITY_MULTI_PARTY_REQUIRED` | Multi-party approval required |
| `AUTHORITY_EVIDENCE_REQUIRED` | Evidence missing |
| `AUTHORITY_RISK_HOLD` | Held due to risk |
| `AUTHORITY_POLICY_BLOCKED` | Blocked by policy |
| `AUTHORITY_SCOPE_MISMATCH` | Tenant/store/legal scope mismatch |
| `AUTHORITY_DEVICE_UNTRUSTED` | Device trust failed |
| `AUTHORITY_PROVIDER_UNREADY` | Provider not ready |
| `AUTHORITY_CIRCUIT_OPEN` | Circuit breaker blocks route |
| `AUTHORITY_DLQ_REQUIRED` | Gate result must route to DLQ |

Authority denied must be auditable.

---

## 7. Identity Gate Boundary

Identity gate verifies who is acting.

Identity gate may check:

- authenticated user id
- customer account
- staff account
- owner account
- franchise HQ account
- platform admin account
- support session
- service account
- device identity
- AI agent identity
- provider identity
- local hub identity
- system batch identity

Identity exists is not enough.

Identity must be bound to role, scope, session, device, and action.

---

## 8. Role Gate Boundary

Role gate checks role permission.

Role families may include:

- customer
- guest customer
- store staff
- store manager
- store owner
- regional manager
- franchise HQ operator
- franchise HQ finance
- platform support
- platform finance
- platform security
- platform admin
- auditor
- legal/compliance
- system batch
- AI advisory agent
- device agent
- provider adapter

Role permission must be action-specific.

Read role is not write role.

Support role is not owner role.

---

## 9. Scope Gate Boundary

Scope gate checks whether the actor may act in the requested context.

Scope dimensions:

- tenant
- store
- brand
- operating group
- legal entity
- device
- provider
- region
- franchise HQ
- customer session
- financial account
- supplier
- policy family

Default rule:

    DENY_UNLESS_SCOPE_MATCHES

If scope cannot be proven, deny or quarantine.

---

## 10. Feature Entitlement Gate Boundary

Feature entitlement gate checks whether tenant/package has access to the feature.

Feature entitlement examples:

- remote wait
- preorder
- KDS handoff
- payment reconciliation
- no-show deposit
- fast payout
- split payout
- franchise HQ dashboard
- dynamic pricing
- SoftPOS
- Auto-SCM
- kitchen IoT
- UWB
- Vision AI
- Acoustic Intelligence
- dedicated shard
- advanced export
- DR tier
- AI analytics

Entitlement does not mean activation.

Feature also requires readiness, compliance, policy, and scope gates.

---

## 11. Policy Gate Boundary

Policy gate checks active policy.

Policy may govern:

- payment capture timing
- no-show penalty
- cancellation window
- refund threshold
- fast payout limit
- fee calculation
- split payout
- royalty calculation
- dynamic pricing
- KYC/account change
- export approval
- retention
- sensor usage
- AI usage
- supplier auto-order
- IoT execution
- DR failover freeze

Policy must be versioned.

Policy must be active for the relevant scope and time.

---

## 12. State Transition Gate Boundary

State transition gate checks whether the target object may move to requested state.

Examples:

- `AUTH_APPROVED` may allow `CAPTURE_READY`
- `CAPTURE_CONFIRMED` may allow `KDS_HANDOFF_PENDING`
- `ORDER_ACCEPTED` may allow `KDS_TICKET_CREATED`
- `KDS_COMPLETED` does not allow `SETTLEMENT_COMPLETED`
- `REFUND_CONFIRMED` may require value reversal
- `CLOSE_FROZEN` does not allow overwrite
- `POLICY_ACTIVE` does not allow direct edit
- `VIRTUAL_CLOSE_GENERATED` may require reconciliation before finality

Illegal state transition must be rejected or routed to DLQ/reconciliation.

---

## 13. Evidence Gate Boundary

Evidence gate checks required evidence.

Evidence may be required for:

- payment finality
- refund approval
- no-show penalty
- chargeback response
- manual adjustment
- settlement finalization
- fast payout
- account change
- KYC verification
- split payout
- supplier order
- IoT device command
- sensor-derived billing
- DR failover promotion
- policy activation
- export disclosure

Evidence missing must block high-impact action.

Evidence is not approval by itself.

---

## 14. Risk Gate Boundary

Risk gate checks current risk.

Risk factors may include:

- FDS risk
- AML review
- chargeback rate
- refund anomaly
- account change anomaly
- device compromise
- provider route outage
- tenant noisy-neighbor state
- abuse score
- no-show risk
- negative margin
- policy tampering
- DR uncertainty
- sensor confidence risk
- AI low confidence
- manual adjustment risk

Risk gate may allow, deny, hold, throttle, or route to review.

---

## 15. Device Trust Gate Boundary

Device trust gate checks device legitimacy.

Device trust inputs:

- device id
- certificate
- key version
- signature
- HMAC
- provisioning state
- MDM/kiosk state if applicable
- integrity state
- last seen
- clock confidence
- revocation status
- local hub trust
- SoftPOS attestation
- IoT device health
- peripheral state

Untrusted device must not perform high-impact actions.

---

## 16. Provider Readiness Gate Boundary

Provider readiness gate checks external provider readiness.

Provider readiness inputs:

- provider contract
- merchant id mapping
- credential state
- circuit breaker state
- API availability
- maintenance state
- route eligibility
- settlement mapping
- account mapping
- provider certification
- provider feature support
- fallback route readiness

Provider configured does not mean provider ready.

Unverified provider capability must be treated as `CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`.

---

## 17. Financial Limit Gate Boundary

Financial limit gate checks amount thresholds.

Limit examples:

- refund amount
- manual adjustment amount
- fast payout amount
- split payout amount
- no-show penalty amount
- supplier order amount
- promotion budget
- dynamic discount rate
- settlement release amount
- account change risk threshold
- export size
- payout daily limit

Amount limit must use fixed-point integer or approved decimal-safe representation.

Limit breach requires review or denial.

---

## 18. Multi-Party Approval Gate Boundary

Multi-party approval gate applies to high-risk actions.

Actions may include:

- policy activation
- payout rule change
- provider credential change
- settlement account change
- large manual adjustment
- trigger/audit control modification
- WORM/retention change
- DR failover promotion
- split payout configuration
- fast payout risk model activation
- high-value refund approval
- privileged access
- direct DB maintenance window
- security containment release

One person must not control critical financial or security changes alone.

---

## 19. Privacy Visibility Gate Boundary

Privacy visibility gate applies to queries, projections, exports, AI, pgvector, and support views.

It checks:

- audience class
- data class
- masking class
- purpose
- tenant/store/legal scope
- customer consent if required
- staff/customer privacy
- raw media restriction
- export approval
- retention/legal hold
- support session scope
- access audit

Visibility is authority to view only.

It is not mutation authority.

---

## 20. Safety Gate Boundary

Safety gate applies to physical execution.

Physical execution examples:

- kitchen IoT command
- robot task
- smart induction
- oven/boiler command
- local hub command
- UWB-guided service route
- supplier delivery receiving
- SoftPOS device activation
- emergency fallback device

Safety gate checks:

- device readiness
- safety interlock
- emergency stop
- human proximity if relevant
- recipe approval
- firmware version
- local hub trust
- manual override
- hazard state
- staff confirmation if required

Safety gate failure must block execution.

---

## 21. Idempotency Gate Boundary

Idempotency gate checks duplicate-safe execution.

High-risk duplicate cases:

- payment capture
- refund request
- auth release
- payout
- split payout
- supplier order
- KDS ticket
- IoT command
- no-show penalty
- manual adjustment
- policy activation
- DR replay
- export delivery

Duplicate action must return existing result or route to review.

It must not execute twice.

---

## 22. Audit Gate Boundary

Audit gate checks whether the action can be traced.

If required audit cannot be recorded, high-impact action must be blocked or routed to fallback.

Audit gate applies to:

- financial movement
- policy change
- manual adjustment
- privileged access
- provider callback acceptance
- export
- security containment
- sensor-derived billing candidate
- IoT command
- supplier order
- no-show penalty
- fast payout

No audit, no high-impact action.

---

## 23. Time Window Gate Boundary

Time window gate checks whether an action is allowed at a specific time.

Examples:

- cancellation deadline
- pickup grace period
- reservation no-show window
- batch close window
- settlement release window
- provider maintenance window
- policy effective time
- promotion window
- supplier order cutoff
- DR freeze window
- support session window
- break-glass expiration

Device local time is not enough.

Server time, business date, and policy effective time must be considered.

---

## 24. Circuit Breaker Gate Boundary

Circuit breaker gate checks whether route/feature is available.

Circuit breaker may block:

- provider payment route
- bank account verification
- payout route
- supplier API
- SoftPOS route
- AI model route
- vector retrieval
- realtime stream
- local mesh sync
- sensor processing
- dynamic pricing activation
- export delivery

Circuit open means action is blocked, deferred, or rerouted under policy.

---

## 25. Compliance Gate Boundary

Compliance gate checks legal/regulatory readiness.

Compliance-gated actions:

- fast payout/factoring
- stored value/wallet
- split payout
- KYC/account verification
- tax invoice automation
- no-show penalty
- dynamic deposit
- SoftPOS
- OCR payment
- camera/audio sensing
- staff location monitoring
- auto-SCM supplier order
- cross-border/data residency
- DR cross-cloud replication
- export/disclosure

Compliance readiness must be evidenced.

Absence of review means not ready.

---

## 26. Human Review Gate Boundary

Human review gate applies when automation is insufficient.

Human review may be required for:

- sensor-derived billing
- AI low-confidence recommendation
- chargeback dispute response
- high-value refund
- KYC mismatch
- account ownership mismatch
- manual adjustment
- no-show appeal
- supplier order over threshold
- IoT safety conflict
- DR reconciliation gap
- policy conflict
- tenant isolation incident

Human review must produce decision event, audit, and evidence.

---

## 27. Automated Authority Boundary

Automated actions may be allowed only when:

- action is low-risk
- policy explicitly allows
- idempotency is guaranteed
- evidence requirements are met
- audit works
- rollback or compensation exists
- tenant/store scope is proven
- risk gate passes
- circuit breaker allows
- no human review required

This document does not authorize new auto-command runtime.

It only defines the boundary.

---

## 28. Deny-By-Default Rule

Default authority decision is denial.

Recommended default:

    DENY_UNLESS_EXPLICITLY_ALLOWED

For tenant isolation:

    CROSS_TENANT_ACCESS_DENIED

For provider readiness:

    CAPABILITY_PROVIDER_EVIDENCE_REQUIRED

For sensor-derived billing:

    SENSOR_EVENT_REVIEW_REQUIRED

For AI execution:

    AI_AUTHORITY_DENIED

For physical device execution:

    SAFETY_GATE_REQUIRED

For financial finality:

    FINANCIAL_EVIDENCE_REQUIRED

---

## 29. Authority Gate Output

Authority gate must return a structured decision.

Recommended decision fields:

- decision id
- decision state
- command id
- actor id
- role id
- scope checked
- gates evaluated
- policy version
- allowed actions
- denied actions
- required evidence
- required review
- required approvals
- risk markers
- expiration
- audit reference
- reason code
- safe customer/store/admin message key if needed

Decision output must be auditable.

---

## 30. Authority Reason Codes

Recommended reason codes:

| Reason Code | Meaning |
|---|---|
| `ROLE_NOT_ALLOWED` | Role lacks permission |
| `SCOPE_MISMATCH` | Tenant/store/legal scope mismatch |
| `FEATURE_NOT_ENTITLED` | Feature not entitled |
| `POLICY_BLOCKED` | Policy blocks action |
| `STATE_TRANSITION_INVALID` | Illegal state transition |
| `EVIDENCE_MISSING` | Required evidence missing |
| `RISK_HOLD` | Risk requires hold |
| `DEVICE_UNTRUSTED` | Device trust failed |
| `PROVIDER_UNREADY` | Provider capability not ready |
| `LIMIT_EXCEEDED` | Financial/operational limit exceeded |
| `MULTI_PARTY_REQUIRED` | Requires multiple approvals |
| `PRIVACY_DENIED` | Visibility/privacy denied |
| `SAFETY_BLOCKED` | Physical safety gate failed |
| `IDEMPOTENCY_CONFLICT` | Duplicate/conflicting request |
| `AUDIT_UNAVAILABLE` | Audit cannot be recorded |
| `TIME_WINDOW_CLOSED` | Not allowed at this time |
| `CIRCUIT_OPEN` | Circuit breaker blocks |
| `COMPLIANCE_NOT_READY` | Compliance review missing |
| `HUMAN_REVIEW_REQUIRED` | Human decision required |

Reason codes must be used for support, audit, and safe projection.

---

## 31. Authority Gate And Projection Boundary

Projection may show authority result.

Examples:

- “Refund requires manager approval.”
- “Capture blocked because provider state unknown.”
- “No-show penalty requires evidence review.”
- “Fast payout unavailable due to risk hold.”
- “Supplier order requires approval.”
- “SoftPOS unavailable on this device.”

Projection must not expose sensitive security details.

Human-facing text must use i18n keys.

---

## 32. Authority Gate And AI Boundary

AI may recommend authority outcome but cannot decide unless explicitly governed.

AI may provide:

- risk summary
- evidence completeness summary
- likely reason
- recommended next reviewer
- anomaly explanation
- policy comparison

AI must not output final approval for high-impact commands.

AI output must be attached as advisory evidence only.

---

## 33. Authority Gate And Sensor Boundary

Sensor may increase or decrease confidence.

Examples:

- NFC/QR confirms physical arrival.
- UWB supports table match.
- Vision suggests item taken.
- Acoustic suggests kitchen overload.
- IoT sensor confirms device completion.

Sensor cannot directly approve high-impact financial or physical action without required policy gates.

---

## 34. Authority Gate And Provider Boundary

Provider readiness and provider signal are separate.

Provider readiness gate checks whether provider route can be used.

Provider signal validation checks whether a received external event can be accepted.

A route may be ready, but a callback may be invalid.

A callback may be valid, but the action may still require reconciliation.

---

## 35. Authority Gate And Break-Glass Boundary

Break-glass authority is emergency-only.

Break-glass requires:

- emergency reason
- limited scope
- limited duration
- reauthentication
- multi-party or post-review if policy requires
- elevated audit
- notification
- reconciliation
- postmortem

Break-glass must not become normal admin workflow.

---

## 36. Authority Gate And Support Boundary

Support may assist but must not own tenant financial authority.

Support access must be:

- purpose-limited
- time-limited
- masked where possible
- audited
- scoped to case
- unable to execute high-impact financial movement unless separately authorized

Support note is not approval.

Support visibility is not ownership.

---

## 37. Authority Gate And Franchise HQ Boundary

Franchise HQ may have aggregate or royalty rights.

HQ authority must be scoped by:

- brand
- franchise contract
- store affiliation
- legal entity relationship
- role
- visibility class
- royalty policy
- split payout policy
- support delegation
- data minimization

HQ visibility does not imply store-owner financial mutation authority unless explicitly contracted and gated.

---

## 38. Authority Gate And Platform Admin Boundary

Platform admin is powerful but still gated.

Platform admin must not unilaterally:

- change settlement account
- alter ledger
- disable audit
- modify policy
- approve large payout
- release security containment
- access raw media unnecessarily
- export sensitive evidence
- mutate tenant data outside scope

Platform admin actions require audit, policy, and often multi-party approval.

---

## 39. Authority Gate Testing Boundary

Authority gates must be testable.

Test cases must include:

- wrong tenant
- wrong store
- wrong legal entity
- wrong role
- untrusted device
- stale policy
- missing evidence
- duplicate command
- provider unavailable
- circuit open
- high-risk amount
- expired time window
- privacy denied
- safety interlock failure
- human review required
- multi-party approval missing

Any gate that cannot be tested is not ready.

---

## 40. Anti-Patterns

Avoid:

- feature flag used as authority
- admin role bypassing all gates
- support role executing financial correction
- AI output approving action
- sensor confidence directly causing charge
- provider configured treated as provider ready
- device connected treated as device trusted
- projection button mutating without command gate
- tenant entitlement bypassing compliance
- policy parameter edited without approval
- high-impact action without audit
- break-glass used for convenience
- franchise HQ seeing all raw store financial data
- soft-deleted actor still authorized
- local/offline device executing final financial action

These anti-patterns must be blocked in future runtime design.

---

## 41. Runtime Deferral

This document defines authority capability gate boundaries only.

It does not authorize:

- authority service implementation
- permission engine
- RBAC implementation
- feature entitlement implementation
- policy gate runtime
- approval workflow
- break-glass runtime
- device trust runtime
- provider readiness runtime
- financial limit engine
- safety gate runtime
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 42. Validation Checklist

Validation must confirm:

1. Authority gate scope is defined.
2. Capability gate catalog is defined.
3. Authority context boundary is defined.
4. Authority decision state skeleton is defined.
5. Identity gate boundary is defined.
6. Role gate boundary is defined.
7. Scope gate boundary is defined.
8. Feature entitlement gate boundary is defined.
9. Policy gate boundary is defined.
10. State transition gate boundary is defined.
11. Evidence gate boundary is defined.
12. Risk gate boundary is defined.
13. Device trust gate boundary is defined.
14. Provider readiness gate boundary is defined.
15. Financial limit gate boundary is defined.
16. Multi-party approval gate boundary is defined.
17. Privacy visibility gate boundary is defined.
18. Safety gate boundary is defined.
19. Idempotency gate boundary is defined.
20. Audit gate boundary is defined.
21. Time window gate boundary is defined.
22. Circuit breaker gate boundary is defined.
23. Compliance gate boundary is defined.
24. Human review gate boundary is defined.
25. Automated authority boundary is defined.
26. Deny-by-default rule is defined.
27. Authority gate output is defined.
28. Authority reason codes are defined.
29. Authority gate relationships to projection, AI, sensor, provider, break-glass, support, franchise HQ, and platform admin are defined.
30. Authority gate testing boundary is defined.
31. Anti-patterns are listed.
32. Coding remains unauthorized.
33. Runtime remains deferred.

---

## 43. Relationship To Previous Documents

This document follows:

- `10620 Command Query Projection Separation Policy`

It prepares:

- `10640 Tenant Scope Envelope Policy`
- `10650 Failure Containment Circuit Breaker Policy`
- `10660 Idempotency Retry Replay Reconciliation Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10690 Cross-Room Plumbing Closure Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- all prior Store Runtime, Financial Trust, Data Governance, Security, SaaS, Field, Physical, Sensor, and Franchise OS boundary documents where capability and authority must be separated.

This document is architecture boundary planning only.

It does not authorize coding.

---

## 44. Final Rule

Capability is not authority.

A feature may exist, a role may exist, a device may be connected, a provider may be configured, a projection may be visible, an AI may recommend, and a sensor may detect, but none of these alone authorizes action.

Every high-impact action must pass explicit identity, role, scope, entitlement, policy, state, evidence, risk, device, provider, amount, approval, privacy, safety, idempotency, audit, time, circuit breaker, compliance, and human-review gates as applicable.

Default is denial unless explicit authority is proven.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.