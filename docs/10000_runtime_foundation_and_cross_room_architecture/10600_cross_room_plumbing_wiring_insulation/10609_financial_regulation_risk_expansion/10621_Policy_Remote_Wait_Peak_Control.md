# 10621_Policy_Remote_Wait_Peak_Control

## 1. Purpose

This document defines the Remote Wait, Preorder Queue, Authorization/Capture, NFC/QR Handshake, and Peak Traffic Control Policy.

The previous artifact `10609J` defined multi-tenant sharding, take-rate optimization, split payout, and franchise finance SaaS architecture boundaries.

This document adds the customer-flow and peak-traffic conversion layer for:

1. Remote waiting and remote preorder traffic bursts.
2. Message queue buffering and asynchronous order/payment intake.
3. Authorization-first and capture-later payment flow for no-show and inventory-risk control.
4. NFC/QR physical handshake for arrival, table matching, and kitchen execution.
5. Safe conversion from online intent to offline store execution.

The purpose is to ensure that Catch Menu can handle famous-store opening rushes, lunch peak preorder spikes, no-show risk, order/payment state consistency, and physical store arrival matching without overloading the core payment system or corrupting financial truth.

This document is planning-only.

It does not authorize coding.

It is not legal, payment, PG/VAN, card-network, consumer protection, refund, privacy, or tax advice.

All authorization/capture, no-show fee, cancellation, customer notice, payment timing, and provider route rules must be reviewed by legal, PG/VAN, card-network, compliance, and operations experts before implementation.

---

## 2. Core Position

Remote wait and preorder are not simple order forms.

They are high-traffic conversion systems where online demand becomes offline store execution.

The correct rule is:

Wait intent is not order.  
Preorder intent is not accepted order.  
Queued request is not payment truth.  
Authorization is not capture.  
Capture is not settlement.  
Customer arrival signal is not physical verification by itself.  
Geofence is not table presence.  
NFC/QR handshake is physical evidence, not financial authority by itself.  
Kitchen start must be state-controlled.  
No-show prevention must not corrupt refund/cancel accounting.  
Peak traffic must be buffered before it reaches financial core.  

The system must separate demand intake, queue admission, payment authorization, store acceptance, physical arrival, kitchen handoff, capture, and settlement.

---

## 3. Remote Wait And Preorder Risk Catalog

The following risks must be treated as mandatory design constraints:

| Risk | Meaning |
|---|---|
| `PEAK_TRAFFIC_SPIKE` | Many customers hit wait/preorder at the same time |
| `CORE_PAYMENT_OVERLOAD` | Heavy payment/order writes overload the core system |
| `STORE_RECORD_LOCK_CONTENTION` | Many requests compete for the same store/order capacity record |
| `QUEUE_DUPLICATE_REQUEST` | Same customer submits repeated requests |
| `AUTH_WITHOUT_ACCEPTANCE` | Payment authorization exists but store rejects order |
| `CAPTURE_BEFORE_READINESS` | Money is captured before inventory/store acceptance |
| `NO_SHOW_LOSS` | Customer never arrives after holding queue/preorder slot |
| `INVENTORY_UNAVAILABLE_AFTER_AUTH` | Authorized preorder cannot be fulfilled |
| `GEOFENCE_FALSE_POSITIVE` | Customer appears near store but is not physically present |
| `WRONG_TABLE_MATCH` | Preorder is matched to wrong table/customer |
| `KDS_PREMATURE_START` | Kitchen starts before confirmed arrival or acceptance |
| `AUTH_RELEASE_FAILURE` | Authorization release fails or provider state unknown |
| `CAPTURE_DUPLICATION` | Capture retried or duplicated |
| `ARRIVAL_HANDSHAKE_REPLAY` | NFC/QR arrival token is replayed |
| `QUEUE_FAIRNESS_DISPUTE` | Customer disputes queue order or priority |

Each risk must have state, evidence, and recovery routing.

---

## 4. Remote Intent Boundary

Remote customer actions create intent, not final execution.

Intent types:

- remote wait intent
- remote preorder intent
- table join intent
- arrival check-in intent
- payment authorization intent
- order modification intent
- cancellation intent
- no-show release intent

Intent must not mutate financial or kitchen truth until validated by the appropriate state gate.

---

## 5. Message Queue Buffer Boundary

Peak wait/preorder traffic must be buffered.

The queue layer may receive:

- wait join request
- preorder request
- authorization preparation request
- arrival check-in request
- store acceptance event
- capture request
- auth release request
- KDS handoff request
- customer notification request

Queue accepts workload.

Queue is not final business truth.

A queued message must still pass idempotency, tenant/store scope, state transition, capacity, and payment checks before execution.

---

## 6. Queue Intake State Skeleton

Recommended queue intake states:

| State | Meaning |
|---|---|
| `INTAKE_RECEIVED` | Customer request received |
| `INTAKE_DEDUP_CHECKING` | Duplicate request checking |
| `INTAKE_RATE_LIMITED` | Intake throttled |
| `INTAKE_QUEUED` | Message queued |
| `INTAKE_PROCESSING` | Worker processing |
| `INTAKE_ACCEPTED_FOR_REVIEW` | Candidate accepted for next stage |
| `INTAKE_REJECTED` | Rejected safely |
| `INTAKE_TIMEOUT` | Intake processing timed out |
| `INTAKE_RETRY_SCHEDULED` | Retry scheduled |
| `INTAKE_DLQ_REQUIRED` | Queue message requires DLQ |

Intake state is not payment/order state.

---

## 7. Queue Deduplication Boundary

Queue deduplication must prevent repeated button taps from creating duplicate effects.

Deduplication keys may include:

- tenant id
- store id
- customer session id
- customer pseudonym
- device id
- wait request id
- preorder request id
- cart hash
- idempotency key
- nonce
- requested time slot
- business date
- queue channel

Duplicate request should return existing status rather than creating duplicate order, wait number, authorization, or capture.

---

## 8. Queue Throttling Boundary

The queue system must throttle processing into core systems.

Throttle dimensions may include:

- store id
- tenant id
- region
- event type
- payment provider
- preorder channel
- waitlist channel
- customer risk class
- device trust class
- current kitchen capacity
- current provider circuit state
- current DB/batch load

Throttling protects the core.

Throttling must not silently drop requests.

---

## 9. Backpressure Boundary

When system load is high, backpressure must be visible.

Backpressure actions may include:

- show “request received, processing” status
- delay non-critical processing
- pause new preorder intake
- switch to wait-only mode
- disable payment authorization temporarily
- offer alternate time slots
- limit per-customer retry
- degrade analytics/AI features
- preserve financial evidence priority
- alert store/admin

Backpressure is controlled degradation.

It must not pretend immediate success.

---

## 10. Waitlist Queue Boundary

Remote wait queue must define fairness and scope.

Waitlist record may include:

- tenant id
- store id
- business date
- queue id
- customer pseudonym
- party size
- requested time
- created timestamp
- queue position
- priority policy
- no-show policy
- arrival window
- cancellation state
- notification state
- evidence reference

Queue position must be reproducible.

Manual priority changes must be audited.

---

## 11. Preorder Queue Boundary

Preorder queue must define order candidate and store capacity constraints.

Preorder candidate may include:

- tenant id
- store id
- business date
- customer pseudonym
- cart snapshot
- requested pickup/dine-in time
- inventory availability snapshot
- kitchen capacity estimate
- authorization state
- store acceptance state
- arrival handshake state
- capture state
- cancellation state
- KDS handoff state
- evidence packet id

Preorder candidate is not accepted order until state gates pass.

---

## 12. Authorization Capture Boundary

Authorization/capture separates payment hold from final capture.

Recommended flow:

1. Customer submits preorder/wait-linked payment candidate.
2. System requests authorization only if provider and policy allow.
3. Store verifies inventory/capacity.
4. Store accepts order.
5. Arrival or readiness condition is met under policy.
6. Capture is requested.
7. Capture is verified.
8. Order proceeds to KDS/POS fulfillment.

Authorization is not capture.

Capture must be idempotent and provider-verified.

---

## 13. Authorization State Skeleton

Recommended authorization states:

| State | Meaning |
|---|---|
| `AUTH_NOT_STARTED` | No authorization |
| `AUTH_REQUESTED` | Authorization requested |
| `AUTH_APPROVED` | Authorization approved |
| `AUTH_DECLINED` | Authorization declined |
| `AUTH_UNKNOWN` | Provider result unknown |
| `AUTH_HELD_FOR_STORE_ACCEPTANCE` | Hold exists pending acceptance |
| `AUTH_RELEASE_REQUESTED` | Release requested |
| `AUTH_RELEASE_CONFIRMED` | Hold released |
| `AUTH_RELEASE_UNKNOWN` | Release result unknown |
| `AUTH_EXPIRED` | Authorization expired |
| `AUTH_RECONCILIATION_REQUIRED` | Reconciliation required |
| `AUTH_DLQ_REQUIRED` | DLQ isolation required |

Authorization lifecycle must be separate from capture lifecycle.

---

## 14. Capture State Skeleton

Recommended capture states:

| State | Meaning |
|---|---|
| `CAPTURE_NOT_ALLOWED` | Capture gate not satisfied |
| `CAPTURE_READY` | Capture conditions satisfied |
| `CAPTURE_REQUESTED` | Capture requested |
| `CAPTURE_CONFIRMED` | Capture confirmed |
| `CAPTURE_DECLINED` | Capture declined |
| `CAPTURE_UNKNOWN` | Provider result unknown |
| `CAPTURE_DUPLICATE_RISK` | Duplicate capture risk |
| `CAPTURE_RETRY_SCHEDULED` | Retry scheduled |
| `CAPTURE_RECONCILIATION_REQUIRED` | Reconciliation required |
| `CAPTURE_DLQ_REQUIRED` | DLQ isolation required |

Capture confirmed is payment truth candidate.

Settlement still requires acquiring/clearing/reconciliation.

---

## 15. Store Acceptance Boundary

Store acceptance must be explicit.

Store acceptance may depend on:

- inventory
- kitchen capacity
- store open state
- business date
- item availability
- staff capacity
- current wait queue
- provider authorization state
- customer arrival policy
- no-show policy
- degraded operation state

Store acceptance is operational authority.

It must not be silently inferred from customer payment authorization.

---

## 16. No-Show Boundary

No-show handling must be governed.

No-show policy may define:

- arrival window
- grace period
- reminder cadence
- cancellation deadline
- authorization release rule
- capture/no-show fee rule if legally allowed
- store discretion
- customer notice requirement
- evidence requirement
- dispute handling
- refund/release state

No-show penalty or capture must be legally and contractually reviewed.

No-show prevention must not become unfair or opaque billing.

---

## 17. Auth Release Boundary

Authorization release should occur when order is canceled before capture or when store cannot accept.

Release candidates:

- customer cancels within allowed window
- store rejects due to inventory
- store is closed
- wait slot expires
- authorization expires
- provider route unavailable
- customer fails arrival policy where release is required
- duplicate request detected

Auth release requested is not release confirmed.

Provider state must be reconciled.

---

## 18. Geofence Boundary

Geofence may support arrival estimation but must not be final physical proof.

Geofence may indicate:

- customer is near store
- customer is approaching
- customer has left area
- estimated arrival time

Geofence must not alone trigger:

- final table assignment
- capture if policy requires physical proof
- kitchen start for sensitive items
- serving completed state
- no-show penalty without notice and policy

Geofence is advisory context.

---

## 19. NFC/QR Physical Handshake Boundary

NFC/QR handshake provides stronger physical presence evidence.

Physical handshake may include:

- NFC tag id
- QR token id
- table id
- kiosk id
- device id
- customer app session
- preorder id
- wait queue id
- timestamp
- nonce
- signature
- location/context if allowed
- tenant/store scope
- replay status
- evidence packet id

Physical handshake is evidence.

It still requires state validation.

---

## 20. Arrival Matching Boundary

Arrival matching must reconcile:

- customer preorder/wait id
- customer session pseudonym
- NFC/QR table token
- table availability
- store id
- business date
- authorization state
- store acceptance state
- time window
- party size if relevant
- duplicate/replay status
- prior arrival status

Wrong arrival match must fail closed or route to staff review.

---

## 21. Physical Handshake Replay Boundary

NFC/QR handshake must prevent replay.

Controls:

- one-time token
- nonce
- timestamp window
- table token rotation if needed
- device signature
- session binding
- server-side consumed marker
- idempotency key
- replay attempt audit
- suspicious pattern review

A screenshot of QR or copied URL must not become unlimited table authority.

---

## 22. Table Binding Boundary

Table binding must be explicit.

Table binding may define:

- table id
- store id
- floor/zone
- current session id
- customer session id
- order/preorder id
- party size
- binding timestamp
- expiration
- staff override
- split payment eligibility
- merge/split table state
- evidence packet id

Table binding is operational state.

It is not customer identity truth by itself.

---

## 23. KDS/POS Handoff Trigger Boundary

KDS/POS handoff should occur only after required gates pass.

Possible gates:

- store acceptance
- authorization approved or payment route approved
- capture confirmed if required before kitchen start
- physical arrival handshake if required
- table binding if dine-in
- inventory still available
- kitchen capacity available
- idempotency key valid
- no duplicate ticket exists
- degraded operation route known

KDS/POS ticket must not be created solely from unverified preorder intent.

---

## 24. Kitchen Start Timing Boundary

Kitchen start timing may vary by menu and service model.

Possible policies:

| Policy | Use |
|---|---|
| `START_AFTER_STORE_ACCEPTANCE` | Make-ahead preorder |
| `START_AFTER_CUSTOMER_ARRIVAL` | Dine-in freshness-sensitive items |
| `START_AFTER_CAPTURE_CONFIRMED` | Payment-critical flow |
| `START_AFTER_STAFF_CONFIRMATION` | High-risk or degraded mode |
| `START_AFTER_TIME_WINDOW` | Scheduled pickup |
| `START_AFTER_PHYSICAL_HANDSHAKE` | Table-service preorder |

Policy must be menu/store/service specific.

Kitchen start must be auditable.

---

## 25. Remote Preorder Evidence Packet

Preorder evidence packet may include:

- customer preorder request
- queue intake event
- cart snapshot
- authorization evidence
- store acceptance evidence
- inventory snapshot
- no-show/cancel policy
- arrival handshake evidence
- table binding evidence
- capture evidence
- KDS/POS handoff evidence
- fulfillment evidence
- refund/auth release evidence if applicable
- audit reference

Evidence packet supports CS, dispute, chargeback, and reconciliation.

---

## 26. Peak Traffic Evidence Packet

Peak traffic evidence packet may include:

- event timestamp
- store/tenant
- queue depth
- intake rate
- processing rate
- throttle status
- rejected/accepted counts
- duplicate count
- provider circuit state
- DB pressure marker
- worker timeout count
- DLQ count
- customer message version
- operational incident reference

Peak traffic must be observable.

Traffic spike must not become mystery failure.

---

## 27. Queue DLQ Boundary

Queue DLQ receives messages that cannot be safely processed.

DLQ candidates:

- missing tenant/store scope
- invalid idempotency key
- duplicate conflict
- expired auth state
- provider unknown state
- invalid physical handshake
- replay detected
- table mismatch
- store closed
- capacity unavailable
- worker timeout
- schema mismatch
- policy mismatch
- payment/order state conflict

DLQ isolation prevents queue poison from crashing the system.

---

## 28. Customer Message Boundary

Customer-facing messages must be safe and precise.

Allowed examples:

- request received and waiting to be processed
- order is being reviewed by the store
- payment authorization is pending
- store accepted the order
- please confirm arrival with NFC/QR
- selected payment route is temporarily busy
- authorization was released
- order could not be accepted and no capture was made
- order is pending staff confirmation

Disallowed:

- payment completed before capture/confirmation
- kitchen started before KDS state exists
- table confirmed before physical handshake
- fraud accusation
- provider internal error detail
- false settlement promise

All messages must be i18n key-governed.

---

## 29. Store Operator Message Boundary

Store-facing messages must separate:

- wait queue count
- preorder candidates
- authorization held
- capture ready
- customer arrived
- physical handshake complete
- table bound
- KDS handoff pending
- auth release required
- no-show candidate
- queue overload
- provider route issue

Store UI must not force staff to infer financial state from unclear labels.

---

## 30. Owner / Franchise Projection Boundary

Owner and HQ projections must show:

- remote wait demand
- preorder volume
- authorization held amount
- captured amount
- auth release count
- no-show rate
- queue abandonment rate
- conversion rate
- peak traffic queue depth
- KDS handoff delay
- capture/reconciliation issues
- DLQ count
- refund/auth release risk
- customer dispute count

Projection is analytics.

It is not source truth.

---

## 31. Relationship To Wait/Order Handoff BM

This document strengthens the Wait/Order Handoff BM by defining:

- remote demand intake
- queue-based overload protection
- late binding between customer intent and store execution
- authorization/capture separation
- physical arrival handshake
- table/token/order matching
- dynamic KDS/POS trigger
- no-show and auth release governance

The BM should emphasize that the invention reduces waiting/order lead time while preserving financial and operational consistency.

---

## 32. Relationship To Financial Trust

Financial Trust must enforce:

- authorization/capture separation
- capture idempotency
- auth release reconciliation
- no-show policy control
- provider route state
- payment/order linkage
- settlement/acquiring continuation after capture
- refund/cancel state if capture already occurred

Financial Trust must not treat wait/preorder intent as payment truth.

---

## 33. Relationship To Store Runtime

Store Runtime must enforce:

- wait queue state
- store acceptance
- inventory/capacity check
- table availability
- physical handshake
- KDS/POS handoff
- kitchen start policy
- staff override
- degraded fallback route

Store Runtime owns operational execution evidence.

It does not own payment finality.

---

## 34. Relationship To Data Governance

Data Governance must control:

- customer messages
- store messages
- owner analytics projection
- queue status visibility
- NFC/QR token masking
- customer pseudonymization
- evidence bundle retention
- CS timeline projection
- i18n keys
- AI explanation boundary
- export restrictions

Arrival and table data may be sensitive and must be scoped.

---

## 35. Relationship To Security Agent

Security Agent may detect:

- queue abuse
- bot traffic
- repeated preorder spam
- duplicate authorization attempts
- arrival token replay
- NFC/QR abuse
- abnormal no-show pattern
- store-specific peak attack
- provider route abuse during peak
- queue worker failure pattern
- customer/session anomaly

Security Agent may alert or contain.

It must not finalize payment or order truth.

---

## 36. Relationship To Cross-Room Plumbing

Future event routing must carry:

- wait request id
- preorder id
- queue message id
- queue partition id
- intake state
- authorization id
- capture id
- auth release id
- store acceptance id
- arrival handshake id
- NFC/QR token id
- table binding id
- KDS/POS handoff id
- no-show policy id
- kitchen start policy id
- peak traffic evidence packet id
- preorder evidence packet id

These become context envelope and evidence packet candidates.

---

## 37. Anti-Patterns

Avoid:

- direct DB write for every wait/preorder button tap during peak
- payment capture before store acceptance when policy requires acceptance first
- treating authorization as captured payment
- accepting no-show penalty without legal/customer notice review
- relying on geofence alone for table arrival
- creating KDS ticket from unverified preorder intent
- allowing QR screenshots to act as permanent table authority
- duplicate capture from repeated preorder retry
- queue success shown as order confirmed
- hidden auth release failure
- customer arrival matched without tenant/store/table scope
- kitchen start without idempotency and state gate
- store owner analytics treated as financial truth

These anti-patterns must be blocked in future runtime design.

---

## 38. Runtime Deferral

This document defines remote wait, preorder, queue buffering, authorization/capture, NFC/QR handshake, and peak traffic control boundaries only.

It does not authorize:

- message queue implementation
- Pub/Sub implementation
- waitlist runtime
- preorder runtime
- authorization/capture integration
- no-show fee logic
- NFC/QR table binding
- KDS/POS handoff runtime
- queue worker implementation
- customer messaging implementation
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 39. Validation Checklist

Validation must confirm:

1. Remote wait/preorder risk catalog is defined.
2. Remote intent boundary is defined.
3. Message queue buffer boundary is defined.
4. Queue intake state skeleton is defined.
5. Queue deduplication boundary is defined.
6. Queue throttling boundary is defined.
7. Backpressure boundary is defined.
8. Waitlist queue boundary is defined.
9. Preorder queue boundary is defined.
10. Authorization/capture boundary is defined.
11. Authorization state skeleton is defined.
12. Capture state skeleton is defined.
13. Store acceptance boundary is defined.
14. No-show boundary is defined.
15. Auth release boundary is defined.
16. Geofence boundary is defined.
17. NFC/QR physical handshake boundary is defined.
18. Arrival matching boundary is defined.
19. Physical handshake replay boundary is defined.
20. Table binding boundary is defined.
21. KDS/POS handoff trigger boundary is defined.
22. Kitchen start timing boundary is defined.
23. Remote preorder evidence packet is defined.
24. Peak traffic evidence packet is defined.
25. Queue DLQ boundary is defined.
26. Customer message boundary is defined.
27. Store operator message boundary is defined.
28. Owner/franchise projection boundary is defined.
29. Relationships to Wait/Order Handoff BM, Financial Trust, Store Runtime, Data Governance, Security Agent, and Cross-Room Plumbing are defined.
30. Anti-patterns are listed.
31. Coding remains unauthorized.
32. Runtime remains deferred.

---

## 40. Relationship To Previous Documents

This document supplements:

- `10609J Multi-Tenant Sharding Take-Rate Optimization Split Payout And Franchise Finance SaaS Architecture Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10210 Order Intake Room Boundary Policy`
- `10220 Order Validation Room Boundary Policy`
- `10230 POS Handoff Room Boundary Policy`
- `10240 KDS Ticket Room Boundary Policy`
- `10250 Kitchen Execution Room Boundary Policy`
- `10330 Fulfillment Visibility Room Boundary Policy`
- `10400~10480 Financial Trust Room Framing Sequence`
- `10530 Safe Projection Masking And Audience Visibility Boundary Policy`
- `10540 AI Advisory Runtime And Non-Authority Boundary Policy`
- `10580 Data Governance Closure And Cross-Room Handoff Policy`
- `10600 Cross-Room Plumbing Wiring Insulation Planning Index`
- `10608 Pseudonymized AI Analysis Noisy Neighbor Control Nonce Idempotency And Final SaaS Edge Guard Policy`
- `10609 Financial Regulation Escrow FDS And Settlement Lag Risk Boundary Policy`
- `10609D Acquiring State Fixed-Point Arithmetic Append-Only Ledger Continuity And Financial Kernel Map Policy`
- `10609G External Financial Network Circuit Breaker Saga Fallback KYC And Account Ownership Verification Policy`
- `10609J Multi-Tenant Sharding Take-Rate Optimization Split Payout And Franchise Finance SaaS Architecture Policy`

It prepares:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- future remote wait/preorder queue specification
- future authorization/capture workflow packet
- future NFC/QR physical handshake specification
- future no-show policy review packet
- future peak-traffic load test matrix
- future Wait/Order Handoff BM evidence packet

This document is architecture boundary planning only.

It does not authorize coding.

---

## 41. Final Rule

Remote waiting and preorder must be designed as high-traffic, asynchronous, financially controlled, physically verified handoff flows.

A customer tap creates intent, not final order or payment truth.

Peak traffic must enter a queue before reaching core payment, order, or database mutation paths.

Authorization and capture must be separated where no-show, inventory, and store acceptance risks require it.

Authorization is not capture.

Auth release is not refund.

Geofence is advisory.

NFC/QR physical handshake is stronger presence evidence but must still pass tenant, store, table, session, nonce, replay, and state checks.

KDS/POS handoff and kitchen start must occur only after the required gates are satisfied.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
