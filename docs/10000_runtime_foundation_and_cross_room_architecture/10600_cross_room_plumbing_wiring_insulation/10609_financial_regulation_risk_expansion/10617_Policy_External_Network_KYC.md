# 10617_Policy_External_Network_KYC

## 1. Purpose

This document defines the External Financial Network Circuit Breaker, Saga Fallback, KYC, and Account Ownership Verification Policy.

The previous artifacts defined:

- `10609 Financial Regulation Escrow FDS And Settlement Lag Risk Boundary Policy`
- `10609A Partial Refund Sequence Business Date Triple-Axis And WORM Ledger Audit Boundary Policy`
- `10609B Commercial Platform Benchmark Order Payment Hardware Financial Tax And Compliance Verification Boundary Policy`
- `10609C Double-Entry Ledger Money Flow AML FDS Freezing And Merkle Integrity Kernel Policy`
- `10609D Acquiring State Fixed-Point Arithmetic Append-Only Ledger Continuity And Financial Kernel Map Policy`
- `10609E Chargeback Dispute Social Engineering Multi-Party Approval And Manual Adjustment Governance Policy`
- `10609F Fixed-Point Batch Snapshot Fan-Out And Hash-Chain Monitoring Action Policy`

This document adds the final external financial network resilience layer for:

1. External PG/VAN/card/bank API delay or outage.
2. Circuit breaker and payment route fallback.
3. Saga-style compensating transactions for distributed order/payment/fulfillment flows.
4. KYC and settlement account ownership verification.
5. One-won or account-name verification before settlement account activation.

The purpose is to ensure that external financial network failure, external provider outage, payment route timeout, compensating transaction failure, or fraudulent settlement account registration cannot collapse the Catch Menu ledger, payment flow, or tenant settlement process.

This document is planning-only.

It does not authorize coding.

It is not legal, financial regulatory, KYC, AML, banking, PG/VAN, card-network, or tax advice.

All KYC, account ownership verification, one-won authentication, escrow, settlement account validation, external financial API fallback, and regulatory duties must be reviewed by qualified legal, compliance, banking, PG/VAN, card-network, accounting, security, and financial infrastructure experts before implementation.

---

## 2. Core Position

Financial SaaS must survive external financial network failure without corrupting internal truth.

The correct rule is:

External provider timeout is not internal failure.  
External provider outage must not cascade into platform outage.  
Circuit breaker protects the platform from dependency collapse.  
Fallback route must not duplicate payment.  
Saga compensation is not ordinary rollback.  
Payment approved but kitchen handoff failed requires compensation or recovery.  
Compensation requested is not compensation completed.  
Settlement account registered is not account ownership verified.  
Business owner identity is not bank account identity by default.  
KYC passed is not permanent trust.  
Account change is high-risk financial action.  

The platform must isolate external dependency failure, preserve idempotency, and block settlement to unverified accounts.

---

## 3. External Financial Network Risk Catalog

The following risks must be treated as mandatory design constraints:

| Risk | Meaning |
|---|---|
| `PROVIDER_API_TIMEOUT` | External PG/VAN/card/bank API does not respond |
| `PROVIDER_API_OUTAGE` | External payment provider route is unavailable |
| `CARD_NETWORK_OUTAGE` | Specific card-company route fails |
| `BANK_API_OUTAGE` | Bank/virtual account verification or transfer API fails |
| `CASCADING_FAILURE` | External outage consumes platform workers and causes wider outage |
| `RETRY_STORM` | Repeated retries overload provider and platform |
| `FALLBACK_DUPLICATE_PAYMENT` | Fallback route creates second authorization |
| `COMPENSATION_FAILURE` | Cancel/refund compensation request fails after prior step succeeded |
| `SAGA_STUCK_STATE` | Distributed transaction cannot complete or compensate |
| `ACCOUNT_OWNERSHIP_MISMATCH` | Settlement account owner differs from tenant/legal owner |
| `KYC_BYPASS` | Tenant settlement account activated without ownership verification |
| `ACCOUNT_CHANGE_FRAUD` | Fraudster changes settlement account |
| `SANCTIONS_AML_RISK` | Platform used for suspicious fund flow |
| `EXTERNAL_DEPENDENCY_SLA_GAP` | Platform SLA depends on external network without clear boundary |

Each risk must have state, evidence, and containment routing.

---

## 4. External Provider Circuit Breaker Boundary

Circuit breaker protects the platform from external dependency failure.

Circuit breaker may be applied per:

- PG provider
- VAN provider
- card company
- bank API
- account verification API
- payout API
- provider settlement file API
- provider dispute API
- provider acquiring API
- provider FDS/risk API

Circuit breaker must be scoped.

One failing card or provider route must not disable unrelated providers, tenants, stores, or features.

---

## 5. Circuit Breaker State Skeleton

Recommended circuit breaker states:

| State | Meaning |
|---|---|
| `CIRCUIT_CLOSED` | Provider route operating normally |
| `CIRCUIT_WARNING` | Error/latency threshold approaching |
| `CIRCUIT_OPEN` | Route blocked temporarily |
| `CIRCUIT_HALF_OPEN` | Limited probe traffic allowed |
| `CIRCUIT_RECOVERING` | Route recovering with controlled load |
| `CIRCUIT_FORCED_OPEN` | Manually or security-forced blocked |
| `CIRCUIT_PROVIDER_MAINTENANCE` | Known provider maintenance |
| `CIRCUIT_UNKNOWN` | Route status uncertain |
| `CIRCUIT_REVIEW_REQUIRED` | Human/provider review required |

Circuit state must be visible to routing, monitoring, CS, and owner-safe projections where relevant.

---

## 6. Circuit Breaker Trigger Boundary

Circuit breaker may trigger on:

- consecutive timeout count
- error rate threshold
- latency threshold
- provider maintenance notice
- provider status page/API signal
- failed acquiring response spike
- failed payout status spike
- bank verification failure spike
- security signal
- FDS block spike
- retry storm
- platform resource exhaustion caused by provider route

Trigger thresholds must be provider-specific, route-specific, and risk-specific.

A payment provider route must not be retried indefinitely.

---

## 7. Circuit Breaker Action Boundary

When a circuit opens, possible actions include:

- stop sending new requests to failing route
- fail fast with safe message
- route to secondary provider if legally and technically configured
- offer alternate payment method
- hold affected pending transactions
- schedule provider status probe
- mark route unavailable
- alert operations
- mark SLA dependency
- record audit event
- avoid retry storm
- protect unrelated tenants and stores

Circuit breaker is containment.

It is not final settlement truth.

---

## 8. Secondary Payment Route Boundary

Fallback to secondary provider is high risk.

Before secondary route is allowed, system must verify:

- tenant has secondary provider contract
- merchant id mapping exists
- settlement account mapping exists
- provider credential is active
- fee/VAT policy for route exists
- acquiring and settlement reconciliation can handle route
- idempotency is shared across routes
- original route status is known enough to avoid duplicate authorization
- customer consent/notice if required
- fallback route is allowed by package and contract

Fallback route must not create duplicate payment.

Fallback route is not automatic unless pre-authorized.

---

## 9. Payment Route Fallback State Skeleton

Recommended fallback states:

| State | Meaning |
|---|---|
| `PRIMARY_ROUTE_SELECTED` | Primary route selected |
| `PRIMARY_ROUTE_TIMEOUT` | Primary route timed out |
| `PRIMARY_ROUTE_UNKNOWN` | Primary route result unknown |
| `FALLBACK_ELIGIBILITY_CHECKING` | Checking fallback eligibility |
| `FALLBACK_NOT_ALLOWED` | Fallback blocked |
| `FALLBACK_ALLOWED` | Fallback possible |
| `FALLBACK_REQUESTED` | Fallback request initiated |
| `FALLBACK_COMPLETED` | Fallback completed |
| `FALLBACK_RECONCILIATION_REQUIRED` | Reconciliation required |
| `FALLBACK_DUPLICATE_RISK` | Duplicate risk detected |
| `FALLBACK_DLQ_REQUIRED` | DLQ isolation required |

Primary route unknown must be resolved before unsafe fallback.

---

## 10. Retry Storm Prevention Boundary

Retry storm may occur when many tenants/devices retry failing external API.

Controls must include:

- exponential backoff
- jitter
- provider-specific throttle
- tenant-specific throttle
- queue isolation
- global provider route limiter
- circuit breaker
- fail-fast response
- offline/pending state
- retry budget
- retry audit
- DLQ after threshold

Retry must preserve idempotency.

Retry must not duplicate payment, refund, payout, or account verification.

---

## 11. Saga Pattern Boundary

Saga pattern governs distributed transactions across systems that cannot share one database transaction.

Candidate saga steps:

1. create order candidate
2. create payment intent
3. request provider authorization
4. verify provider response
5. commit order acceptance
6. send POS/KDS/printer handoff
7. receive fulfillment ACK
8. create settlement candidate
9. reconcile provider/acquiring result

If a later step fails, compensating transaction may be required.

Saga is not simple rollback.

Each step must be idempotent, auditable, and compensatable where possible.

---

## 12. Saga State Skeleton

Recommended saga states:

| State | Meaning |
|---|---|
| `SAGA_STARTED` | Saga started |
| `SAGA_STEP_PENDING` | Step waiting |
| `SAGA_STEP_COMPLETED` | Step completed |
| `SAGA_STEP_FAILED` | Step failed |
| `SAGA_COMPENSATION_REQUIRED` | Compensation required |
| `SAGA_COMPENSATION_REQUESTED` | Compensation requested |
| `SAGA_COMPENSATION_COMPLETED` | Compensation completed |
| `SAGA_COMPENSATION_FAILED` | Compensation failed |
| `SAGA_RETRY_SCHEDULED` | Retry scheduled |
| `SAGA_RECONCILIATION_REQUIRED` | Reconciliation required |
| `SAGA_DLQ_REQUIRED` | DLQ isolation required |
| `SAGA_MANUAL_REVIEW_REQUIRED` | Manual review required |
| `SAGA_CLOSED_VERIFIED` | Closed with verified evidence |

Saga state must be explicit.

No step failure should disappear.

---

## 13. Compensating Transaction Boundary

Compensating transaction may include:

- payment authorization cancel
- refund request
- void request
- order cancellation
- POS/KDS cancel ticket
- printer retraction or correction notice
- coupon/point reversal
- wallet reversal
- settlement hold
- owner/customer notification
- DLQ case
- manual review

Compensation requested is not compensation completed.

Compensation must be provider-verified and reconciled.

---

## 14. Payment Approved But Fulfillment Failed Boundary

If payment succeeds but POS/KDS/printer handoff fails:

Required flow:

- mark fulfillment path failed or pending
- alert staff immediately
- attempt idempotent re-handoff if safe
- check alternate route
- if impossible to fulfill, trigger compensation candidate
- request provider cancel/void/refund as allowed
- mark settlement hold until resolved
- create evidence packet
- route unresolved case to DLQ
- generate CS/owner-safe explanation

Customer money and store execution must converge through recovery or compensation.

---

## 15. Compensation Failure Boundary

Compensation may fail due to:

- provider timeout
- provider rejection
- acquiring already completed
- refund window closed
- circuit breaker open
- bank/provider outage
- duplicate request conflict
- amount/version mismatch
- partial refund sequence issue
- account/merchant mapping issue

Compensation failure must create reconciliation and manual review.

Compensation failure must not be hidden by marking the original saga complete.

---

## 16. Stand-In And Pending Mode Boundary

When external financial network is down, the platform may offer limited pending mode only if policy allows.

Pending mode may:

- save order intent
- show payment route unavailable
- allow customer to choose alternate payment
- allow staff-assisted external terminal payment
- create manual payment evidence
- create later reconciliation case
- delay order acceptance until payment verified
- use stand-in mode only under approved provider/bank rules

Pending mode must not fake authorization.

Pending mode must not mark settlement available.

---

## 17. KYC And Account Ownership Boundary

Settlement account registration or change must verify ownership.

Account ownership checks may include:

- tenant legal entity identity
- representative identity under policy
- business registration reference
- provider merchant id ownership
- bank account holder name check
- one-won transfer verification if legally/technically available
- bank account status check
- account type check
- settlement account authorization
- multi-party approval for change
- risk review for mismatch

Settlement account owner must match approved tenant/legal rules.

Mismatch must block settlement activation until reviewed.

---

## 18. One-Won Verification Boundary

One-won verification or equivalent micro-deposit verification may be used where legally and technically available.

Verification may require:

- bank account number
- bank code
- account holder name
- micro-deposit transaction
- verification code or depositor text
- verification attempt count
- timeout
- lockout after failed attempts
- audit
- KYC review
- owner notification
- fraud review if suspicious

One-won verification success is evidence.

It is not permanent trust forever.

---

## 19. Settlement Account Change Boundary

Changing settlement account is critical.

Required controls:

- strong authentication
- multi-party approval for high-risk accounts
- account ownership verification
- old account notification
- new account verification
- cooling period if policy requires
- payout hold during change window
- risk scoring
- immutable audit
- WORM reference if required
- post-change monitoring

Account change must not become social-engineering payout theft.

---

## 20. Account Ownership Mismatch Boundary

If account ownership mismatch is detected:

Required handling:

- block settlement activation
- block payout route
- create KYC review case
- alert finance/compliance
- request additional evidence
- preserve submitted account evidence
- prevent repeated abuse
- notify tenant safely
- audit event
- route to legal/compliance if required

Mismatch is high-risk.

Mismatch is not automatically criminal intent.

---

## 21. Provider/Bank Outage And KYC Boundary

If bank/KYC verification API is down:

- account activation remains pending
- payout route must not activate blindly
- retry schedule must be controlled
- tenant must see safe pending message
- support must see provider outage marker
- circuit breaker applies to verification API
- manual override requires strong governance

Verification unavailable is not verification passed.

---

## 22. External Dependency SLA Boundary

The platform SLA must distinguish:

- platform outage
- provider API outage
- card network outage
- bank API outage
- account verification API outage
- tenant network outage
- provider maintenance
- circuit breaker protective open state
- fallback route unavailable due to tenant package
- manual review hold

SLA must not promise external network availability as if it were internal platform uptime.

---

## 23. External Network Evidence Packet

External network evidence packet may include:

- provider id
- route id
- circuit state
- timeout/error metrics
- failed request ids
- fallback eligibility
- fallback route decision
- saga id
- compensation request id
- compensation result
- provider status evidence
- affected tenants/stores
- affected transaction ids
- SLA dependency marker
- audit references
- owner/customer message references

Evidence packet supports incident review and partner negotiation.

---

## 24. KYC Evidence Packet

KYC/account ownership evidence packet may include:

- tenant id
- legal entity id
- representative reference
- business registration reference
- settlement account reference
- bank code
- masked account number
- account holder verification result
- one-won verification result
- verification timestamp
- failed attempt count
- approval reference
- risk review reference
- account change history
- audit reference
- WORM reference if required

KYC evidence must be masked and access-controlled.

---

## 25. Circuit Breaker Monitoring View Boundary

Admin monitoring view should show:

- provider route
- circuit state
- error rate
- timeout rate
- latency
- affected tenants/stores
- fallback availability
- retry backlog
- pending saga count
- compensation failure count
- SLA impact
- provider maintenance marker
- next probe time
- responsible team

Monitoring view is projection.

It must not be used as financial truth.

---

## 26. External Outage Customer And Owner Message Boundary

Messages must be safe.

Allowed messages:

- selected payment route is temporarily unavailable
- please use another card/payment method
- provider maintenance is affecting confirmation
- transaction is pending verification
- settlement account verification is pending
- payout is held pending account verification
- settlement is delayed due to provider/bank response delay

Disallowed messages:

- accusing customer/cardholder of fraud
- exposing provider internals
- exposing bank/account details
- claiming payment success while provider result unknown
- claiming settlement complete while payout route is blocked
- hiding provider outage as platform success

All reusable messages must be i18n key-governed.

---

## 27. Cross-Room External Network Impact Boundary

External financial network failure may affect:

- Store Runtime
- Financial Trust
- Data Governance
- Security Agent
- CS dashboard
- Owner dashboard
- Batch reconciliation
- DLQ
- Provider adapter
- Payout engine
- KYC/account verification
- SLA reporting
- Audit/WORM

Impact must be scoped and propagated through events.

It must not become silent inconsistency.

---

## 28. Patent Candidate Boundary

These controls strengthen the patent candidate.

Potential patent-relevant extensions:

- provider/card/bank circuit breaker for restaurant fintech SaaS payment routing
- saga-based compensating transaction engine for order-payment-kitchen fulfillment consistency
- payment route fallback with duplicate authorization prevention
- external financial outage evidence packet linked to reconciliation and SLA projection
- KYC/account ownership verification gate for tenant settlement activation
- one-won verification and settlement account change governance for restaurant SaaS payouts
- circuit breaker plus Saga plus KYC combined into financial network resilience architecture

Patent attorney review is required.

This document is architecture planning only.

---

## 29. Relationship To Financial Kernel Documents

This document extends:

- `10609C Double-Entry Ledger Money Flow AML FDS Freezing And Merkle Integrity Kernel Policy`
- `10609D Acquiring State Fixed-Point Arithmetic Append-Only Ledger Continuity And Financial Kernel Map Policy`
- `10609E Chargeback Dispute Social Engineering Multi-Party Approval And Manual Adjustment Governance Policy`
- `10609F Fixed-Point Batch Snapshot Fan-Out And Hash-Chain Monitoring Action Policy`

It adds the external financial network defense layer.

---

## 30. Relationship To Cross-Room Plumbing

Future event routing must carry:

- provider route id
- circuit state
- fallback route id
- provider timeout marker
- provider outage marker
- retry budget
- saga id
- saga step id
- compensation id
- compensation state
- KYC verification id
- account ownership state
- one-won verification state
- account change risk marker
- payout route activation state
- SLA dependency marker
- external network evidence packet id
- KYC evidence packet id

These become context envelope and evidence packet candidates.

---

## 31. Relationship To Financial Trust

Financial Trust must enforce:

- circuit breaker state before provider call
- route fallback eligibility
- duplicate authorization prevention
- Saga compensation state
- compensation reconciliation
- settlement hold during unknown provider state
- KYC/account ownership verification before payout activation
- account change governance
- payout block on account mismatch

Financial Trust must not treat provider timeout as success or failure without evidence.

---

## 32. Relationship To Store Runtime

Store Runtime must support:

- payment route unavailable message
- alternate payment route display
- pending verification status
- staff-assisted fallback if policy allows
- order acceptance rule during provider outage
- recovery route when payment/fulfillment saga is incomplete
- local evidence capture
- customer-safe degraded state

Store Runtime must not fake payment confirmation.

---

## 33. Relationship To Data Governance

Data Governance must control:

- outage messaging
- provider status projection
- circuit breaker monitoring view
- KYC status projection
- owner payout hold messages
- masked account display
- evidence packet export
- i18n messages
- CS explanations
- retention of external outage evidence
- audit access

External dependency status must be visible without exposing sensitive infrastructure details.

---

## 34. Relationship To Security Agent

Security Agent may detect:

- provider timeout storm
- fallback abuse
- retry storm
- suspicious compensation pattern
- repeated provider route failure by tenant
- KYC verification abuse
- repeated one-won verification attempts
- settlement account change anomaly
- payout route activation anomaly
- external outage exploited for fraud

Security Agent may alert or contain.

It must not finalize payment truth or legal guilt.

---

## 35. Anti-Patterns

Avoid:

- waiting indefinitely for external PG/card/bank response
- allowing one provider outage to consume all platform workers
- retry storm against failing provider
- fallback route without duplicate authorization guard
- fallback route without tenant/provider contract
- treating Saga as ordinary DB rollback
- marking compensation requested as compensation completed
- order accepted as paid while payment route is unknown
- activating settlement account without ownership verification
- payout to third-party account without review
- account verification API outage treated as verification success
- SLA claiming external provider uptime as platform uptime
- hiding circuit breaker state from operations
- customer message implying fraud without evidence

These anti-patterns must be blocked in future runtime design.

---

## 36. Runtime Deferral

This document defines external financial network circuit breaker, Saga fallback, KYC, and account ownership verification boundaries only.

It does not authorize:

- circuit breaker implementation
- provider route fallback implementation
- Saga engine implementation
- compensating transaction runtime
- KYC integration
- bank account holder inquiry
- one-won verification
- settlement account activation workflow
- payout route activation
- provider status monitoring
- customer/owner messaging implementation
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 37. Validation Checklist

Validation must confirm:

1. External financial network risk catalog is defined.
2. External provider circuit breaker boundary is defined.
3. Circuit breaker state skeleton is defined.
4. Circuit breaker trigger boundary is defined.
5. Circuit breaker action boundary is defined.
6. Secondary payment route boundary is defined.
7. Payment route fallback state skeleton is defined.
8. Retry storm prevention boundary is defined.
9. Saga pattern boundary is defined.
10. Saga state skeleton is defined.
11. Compensating transaction boundary is defined.
12. Payment approved but fulfillment failed boundary is defined.
13. Compensation failure boundary is defined.
14. Stand-in and pending mode boundary is defined.
15. KYC/account ownership boundary is defined.
16. One-won verification boundary is defined.
17. Settlement account change boundary is defined.
18. Account ownership mismatch boundary is defined.
19. Provider/bank outage and KYC boundary is defined.
20. External dependency SLA boundary is defined.
21. External network evidence packet is defined.
22. KYC evidence packet is defined.
23. Circuit breaker monitoring view boundary is defined.
24. External outage customer/owner message boundary is defined.
25. Cross-room external network impact boundary is defined.
26. Patent candidate boundary is defined.
27. Relationships to Financial Kernel, Cross-Room Plumbing, Financial Trust, Store Runtime, Data Governance, and Security Agent are defined.
28. Anti-patterns are listed.
29. Coding remains unauthorized.
30. Runtime remains deferred.

---

## 38. Relationship To Previous Documents

This document supplements:

- `10609F Fixed-Point Batch Snapshot Fan-Out And Hash-Chain Monitoring Action Policy`

It references:

- `10400~10480 Financial Trust Room Framing Sequence`
- `10530 Safe Projection Masking And Audience Visibility Boundary Policy`
- `10540 AI Advisory Runtime And Non-Authority Boundary Policy`
- `10554 Four-Layer Audit Capture Trigger View OS Log And Nightly Batch Reconciliation Policy`
- `10570 Retention Export And Compliance Data Boundary Policy`
- `10580 Data Governance Closure And Cross-Room Handoff Policy`
- `10600 Cross-Room Plumbing Wiring Insulation Planning Index`
- `10601 Financial-Grade Ledger Reconciliation And Four-Source Closing Audit Policy`
- `10602 Financial Reconciliation Blind Spot Control Time State Offline Log And Auditor Security Policy`
- `10603 Reconciliation DLQ Device Non-Repudiation And Cold Storage Lifecycle Policy`
- `10604 SaaS Scale Constraint Multi-Tenancy Hardware Regulation Noise And Distributed Batch Policy`
- `10605 SaaS Field Resilience Network Provider SLA And Policy-Based Customization Constraint Policy`
- `10606 Extreme Edge Case Power Cut Twenty-Four-Hour Store Hardware Peripheral And Human CS Operations Policy`
- `10607 Long Transaction Concurrency Disaster Recovery And Backup Integrity Edge Case Policy`
- `10608 Pseudonymized AI Analysis Noisy Neighbor Control Nonce Idempotency And Final SaaS Edge Guard Policy`
- `10609 Financial Regulation Escrow FDS And Settlement Lag Risk Boundary Policy`
- `10609A Partial Refund Sequence Business Date Triple-Axis And WORM Ledger Audit Boundary Policy`
- `10609B Commercial Platform Benchmark Order Payment Hardware Financial Tax And Compliance Verification Boundary Policy`
- `10609C Double-Entry Ledger Money Flow AML FDS Freezing And Merkle Integrity Kernel Policy`
- `10609D Acquiring State Fixed-Point Arithmetic Append-Only Ledger Continuity And Financial Kernel Map Policy`
- `10609E Chargeback Dispute Social Engineering Multi-Party Approval And Manual Adjustment Governance Policy`
- `10609F Fixed-Point Batch Snapshot Fan-Out And Hash-Chain Monitoring Action Policy`

It prepares:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- future provider circuit breaker specification
- future payment route fallback authorization packet
- future Saga compensation engine specification
- future KYC/account ownership verification packet
- future external financial network SLA evidence packet

This document is architecture boundary planning only.

It does not authorize coding.

---

## 39. Final Rule

Catch Menu must not depend on external financial networks behaving perfectly.

A PG, VAN, card company, bank, account verification API, payout API, or provider settlement route may fail, delay, timeout, or return unknown state.

Circuit breaker must isolate failing routes.

Fallback must be contract-authorized, idempotency-protected, and duplicate-payment-safe.

Saga must coordinate order, payment, POS/KDS/printer handoff, settlement, and compensation as explicit state transitions.

Compensation requested is not compensation completed.

Unknown provider state must trigger hold, reconciliation, retry governance, or DLQ.

Settlement account activation must require KYC and account ownership verification.

One-won verification or equivalent account proof must be treated as evidence, not permanent trust.

External network outage must be visible, scoped, audited, and projected safely.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
