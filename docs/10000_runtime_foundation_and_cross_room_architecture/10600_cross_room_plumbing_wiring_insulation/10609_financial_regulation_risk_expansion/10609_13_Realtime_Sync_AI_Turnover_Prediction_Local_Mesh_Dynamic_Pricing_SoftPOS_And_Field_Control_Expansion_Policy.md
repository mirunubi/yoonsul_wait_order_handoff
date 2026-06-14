# 10609_13_Realtime_Sync_AI_Turnover_Prediction_Local_Mesh_Dynamic_Pricing_SoftPOS_And_Field_Control_Expansion_Policy

## 1. Purpose

This document defines the Realtime Sync, AI Turnover Prediction, Local Mesh, Dynamic Pricing, SoftPOS, and Field Control Expansion Policy.

The previous artifact `10609L` defined no-show deposit, penalty, abuse scoring, booking circuit breaker, and reservation financial control boundaries.

This document adds the field-control and revenue-optimization technology layer for:

1. Low-latency realtime synchronization between customer devices, tablets, POS, KDS, kitchen, staff, and owner surfaces.
2. AI-based table turnover prediction and virtual waiting time estimation.
3. Local mesh / local relay operation during internet outage.
4. Dynamic pricing, time-sale, occupancy-based promotion, and demand-shaping policy.
5. SoftPOS, app-to-app payment, NFC-based payment, and OCR payment boundary governance.

The purpose is to strengthen Catch Menu’s field execution, waiting experience, offline survivability, revenue optimization, and hardware-cost reduction without compromising financial truth, security, privacy, provider compliance, or operational authority.

This document is planning-only.

It does not authorize coding.

This document does not assert that any named external competitor uses the exact architecture described here.

All realtime protocol, AI prediction, local mesh, dynamic pricing, SoftPOS, NFC payment, OCR card capture, PCI/payment security, customer consent, provider certification, and legal requirements must be reviewed by qualified security, payment, PG/VAN, card-network, legal, privacy, and infrastructure experts before implementation.

---

## 2. Core Position

Field-control technology must improve speed and resilience without becoming uncontrolled authority.

The correct rule is:

Realtime message is not source truth.  
WebSocket connection is not business authority.  
gRPC stream is not payment confirmation.  
AI prediction is not promised wait time.  
Estimated departure is not table availability.  
Local mesh event is provisional until reconciled.  
Offline operation is not silent central mutation.  
Dynamic pricing is not arbitrary price manipulation.  
Promotion visibility is not coupon issuance.  
SoftPOS capability is not automatic payment compliance.  
OCR card capture is high-risk payment data processing.  
NFC payment acceptance requires provider and security approval.  

Every realtime, AI, local, pricing, and payment-device capability must remain evidence-linked, scoped, and reconciled.

---

## 3. Field Control Expansion Catalog

The following capability families are added:

| Capability Family | Purpose |
|---|---|
| `REALTIME_SYNC_STREAM` | Low-latency device, POS, KDS, staff, and customer state propagation |
| `WEBSOCKET_GRPC_CHANNEL` | Persistent bidirectional communication channel |
| `STREAM_BACKPRESSURE_CONTROL` | Prevent realtime channel overload |
| `AI_TURNOVER_PREDICTION` | Predict table departure and wait duration |
| `VIRTUAL_WAIT_QUEUE_ESTIMATION` | Provide dynamic wait-time estimates |
| `LOCAL_MESH_RELAY` | Preserve store operations when external internet is unavailable |
| `OFFLINE_LOCAL_LEDGER_BUFFER` | Temporarily store signed local events until sync |
| `DYNAMIC_PRICING_RULE_ENGINE` | Adjust promotion/discount/deposit rules based on occupancy and demand |
| `TIME_SALE_TRIGGER` | Convert dead-time capacity into demand |
| `SOFTPOS_PAYMENT_BOUNDARY` | Govern software-based payment terminal capability |
| `OCR_PAYMENT_BOUNDARY` | Govern optical card-data capture risk |
| `NFC_APP_TO_APP_PAYMENT_BOUNDARY` | Govern NFC/app-to-app payment flows |

These capabilities are not runtime permissions.

They are architectural boundary candidates.

---

## 4. Realtime Sync Boundary

Realtime sync propagates state changes quickly.

Realtime sync may deliver:

- new order event
- order accepted event
- KDS ticket created event
- kitchen started event
- kitchen completed event
- staff call event
- customer call acknowledgement
- table status update
- preorder arrival event
- NFC/QR handshake event
- payment state projection
- printer failure event
- local outage event
- degraded mode event
- queue position update
- wait time estimate update
- owner dashboard update

Realtime sync is projection and notification.

It must not bypass source-of-truth state machines.

---

## 5. WebSocket / gRPC Channel Boundary

Persistent channels may be used for low-latency synchronization.

Channel identity must include:

- tenant id
- store id
- device id
- user/session id
- surface id
- role
- connection id
- auth context
- capability scope
- stream type
- heartbeat timestamp
- channel state
- revocation status

Open channel is not authorization to perform all actions.

Every command must still be authorized.

---

## 6. Stream State Skeleton

Recommended realtime stream states:

| State | Meaning |
|---|---|
| `STREAM_CONNECTING` | Connection being established |
| `STREAM_AUTHENTICATING` | Authentication and scope check |
| `STREAM_ACTIVE` | Active stream |
| `STREAM_DEGRADED` | High latency or partial updates |
| `STREAM_BACKPRESSURE` | Flow control active |
| `STREAM_RECONNECTING` | Reconnect attempt |
| `STREAM_STALE` | No heartbeat within threshold |
| `STREAM_REVOKED` | Session/device revoked |
| `STREAM_OFFLINE_FALLBACK` | Local fallback in use |
| `STREAM_CLOSED` | Closed normally |
| `STREAM_SECURITY_REVIEW_REQUIRED` | Abnormal stream behavior |

Stream state must be observable.

---

## 7. Realtime Event Ordering Boundary

Realtime events can arrive out of order.

Controls must include:

- event sequence number
- server timestamp
- source timestamp
- causation id
- correlation id
- idempotency key
- version
- last known state
- replay marker
- stale marker
- gap detection
- reconciliation route

Realtime ordering cannot be assumed.

State machines must reject stale or illegal transitions.

---

## 8. Stream Backpressure Boundary

High traffic may overload realtime streams.

Backpressure controls may include:

- per-store event rate limit
- per-device event rate limit
- coalescing repeated updates
- priority channels
- dropping non-critical telemetry first
- preserving financial/security events
- delayed analytics updates
- KDS/POS priority routing
- customer projection throttling
- reconnect jitter
- queue depth monitoring

Backpressure must protect critical operations.

Backpressure must not drop financial truth.

---

## 9. KDS/POS Realtime Handoff Boundary

KDS/POS updates require stronger controls.

Realtime KDS/POS handoff must verify:

- order accepted
- payment/auth state appropriate
- store/kitchen route available
- idempotency key
- ticket sequence
- duplicate ticket check
- printer/KDS state
- staff visibility
- fallback route
- tenant/store scope

Realtime speed must not create duplicate or premature kitchen tickets.

---

## 10. AI Turnover Prediction Boundary

AI may estimate table departure and waiting time.

Input candidates:

- table seated time
- order time
- menu type
- course/stage if applicable
- kitchen completion time
- average dwell time by day/time
- party size
- reservation time
- staff signals
- payment requested/completed signal
- historical queue conversion
- weather/event context if legally and operationally appropriate
- store-specific behavior pattern

AI prediction is estimate.

It must not be represented as guaranteed entry time.

---

## 11. Wait-Time Prediction State Skeleton

Recommended states:

| State | Meaning |
|---|---|
| `PREDICTION_NOT_AVAILABLE` | No prediction |
| `PREDICTION_COMPUTING` | Prediction running |
| `PREDICTION_READY` | Estimate ready |
| `PREDICTION_LOW_CONFIDENCE` | Estimate uncertain |
| `PREDICTION_STALE` | Estimate outdated |
| `PREDICTION_UPDATED` | New estimate available |
| `PREDICTION_CONFLICT` | Input conflict detected |
| `PREDICTION_DISABLED` | Prediction disabled by policy |
| `PREDICTION_REVIEW_REQUIRED` | Human review required |

Customer-facing wait estimates must show uncertainty or range when appropriate.

---

## 12. AI Prediction Evidence Boundary

Prediction evidence may include:

- model version
- input feature snapshot
- prediction timestamp
- predicted wait range
- confidence score
- table state snapshot
- menu/service context
- queue position
- last update time
- fallback baseline estimate
- error after actual seating
- audit reference

Prediction must be measurable against actual results.

---

## 13. Virtual Queue Optimization Boundary

Virtual queue optimization may recommend:

- updated wait estimate
- customer notification timing
- arrival request timing
- table assignment candidate
- preorder timing
- kitchen prep timing
- queue cutoff
- deposit adjustment candidate if policy allows
- no-show risk marker

Recommendation is not execution.

Store Runtime or approved policy must decide.

---

## 14. Local Mesh / Local Relay Boundary

Local mesh or local relay mode preserves store operation during external internet failure.

Local mode may support:

- table order intake
- staff call
- KDS ticket handoff
- local POS note
- printer routing
- kitchen status update
- local queue visibility
- limited manual payment evidence
- offline event buffer
- later cloud sync

Local mode must not silently finalize external payment, payout, settlement, or central ledger truth.

---

## 15. Local Mesh Authority Boundary

Local mesh authority must be limited.

Allowed local provisional states:

- local order candidate
- local kitchen ticket candidate
- local staff acknowledgement
- local fulfillment note
- local printer evidence
- local manual payment note
- offline sync pending

Not allowed without central/provider confirmation:

- final payment confirmed
- acquiring confirmed
- settlement available
- payout completed
- tax report finalized
- cross-store transfer
- irreversible account change
- final financial close

Local mesh is survivability.

It is not central financial authority.

---

## 16. Local Mesh Event Envelope Boundary

Local mesh event must include:

- tenant id
- store id
- device id
- local session id
- offline sequence number
- previous local hash
- current payload hash
- signature/HMAC
- created local timestamp
- received local timestamp
- later server sync timestamp
- event type
- idempotency key
- source device role
- target device role
- sync status
- conflict marker

Local events must be signed, sequenced, and later reconciled.

---

## 17. Local Sync Recovery Boundary

When internet returns, local events must sync safely.

Recovery process must:

- verify device identity
- verify sequence chain
- verify hash chain
- verify tenant/store scope
- detect duplicates
- detect conflict with central state
- apply idempotency
- mark provisional events
- route conflicts to DLQ
- create reconciliation evidence
- update projections only after acceptance

Sync is not blind merge.

---

## 18. Dynamic Pricing Boundary

Dynamic pricing or time-sale capability modifies offers based on context.

Potential signals:

- occupancy rate
- table availability
- wait queue length
- weather/time/day
- historical demand
- inventory surplus
- kitchen capacity
- promotion budget
- customer segment if legally/policy allowed
- store policy
- franchise campaign
- platform campaign

Dynamic pricing must be policy-governed.

It must not become arbitrary, discriminatory, or legally unsafe.

---

## 19. Dynamic Pricing State Skeleton

Recommended states:

| State | Meaning |
|---|---|
| `PRICING_RULE_INACTIVE` | Rule inactive |
| `PRICING_RULE_CANDIDATE` | Candidate rule generated |
| `PRICING_RULE_SIMULATING` | Simulation running |
| `PRICING_RULE_APPROVED` | Approved |
| `PRICING_RULE_ACTIVE` | Active |
| `PRICING_RULE_PAUSED` | Paused |
| `PRICING_RULE_EXPIRED` | Expired |
| `PRICING_RULE_CONFLICT` | Conflicts with another rule |
| `PRICING_RULE_REVIEW_REQUIRED` | Human review required |
| `PRICING_RULE_ROLLBACK_REQUIRED` | Rollback required |

Pricing rule activation must be audited.

---

## 20. Time-Sale Trigger Boundary

Time-sale trigger may activate when:

- occupancy below threshold
- dead-time window detected
- inventory aging threshold reached
- weather demand drop detected
- reservation cancellation spike
- kitchen underutilized
- campaign budget available
- owner/franchise policy allows
- margin floor is protected
- customer notice is valid

Time-sale must not create negative margin unless explicitly authorized and budgeted.

---

## 21. Promotion And Coupon Distinction Boundary

Dynamic pricing must distinguish:

- menu price change
- promotion display
- coupon issuance
- coupon redemption
- deposit reduction
- service fee waiver
- bundle offer
- loyalty point multiplier
- targeted notification

Promotion visible is not coupon issued.

Coupon issued is not redeemed.

Discount applied is financial event.

---

## 22. Dynamic Pricing Evidence Packet

Dynamic pricing evidence packet may include:

- pricing rule id
- policy version
- trigger signal snapshot
- occupancy snapshot
- inventory snapshot
- margin simulation
- approved discount
- effective period
- target audience
- customer message version
- coupon/promotion linkage
- redemption result
- owner approval reference
- audit reference

Dynamic pricing must be reproducible.

---

## 23. SoftPOS Boundary

SoftPOS converts approved mobile/tablet device into payment acceptance terminal.

SoftPOS requires:

- provider approval
- card-network compliance
- device attestation
- secure key management
- tamper detection
- certified payment SDK
- transaction encryption
- no raw card data exposure
- PCI/payment standard review
- device eligibility
- merchant onboarding
- audit trail

SoftPOS is not ordinary app feature.

It is regulated payment acceptance infrastructure.

---

## 24. NFC App-to-App Payment Boundary

NFC payment through phone/tablet must verify:

- device capability
- merchant identity
- payment SDK certification
- secure element or certified software path
- tap event evidence
- transaction cryptogram if applicable
- provider authorization
- idempotency
- receipt
- chargeback evidence
- settlement/acquiring flow

NFC tap evidence is not settlement truth.

Provider confirmation is required.

---

## 25. OCR Payment Boundary

OCR card capture is high-risk.

OCR payment may involve sensitive card data.

Before considering OCR:

- legal/payment provider approval required
- PCI/security review required
- raw card data storage prohibited unless certified
- memory handling controlled
- no logging of card number
- masking enforced
- tokenization required
- customer consent required
- fraud risk reviewed
- fallback/manual entry rules governed

OCR convenience must not create payment security exposure.

---

## 26. SoftPOS State Skeleton

Recommended SoftPOS states:

| State | Meaning |
|---|---|
| `SOFTPOS_NOT_AVAILABLE` | Capability unavailable |
| `SOFTPOS_DEVICE_CHECKING` | Device capability checking |
| `SOFTPOS_PROVIDER_APPROVED` | Provider approved |
| `SOFTPOS_SECURITY_ATTESTED` | Device/security attested |
| `SOFTPOS_READY` | Ready for payment |
| `SOFTPOS_PAYMENT_REQUESTED` | Payment requested |
| `SOFTPOS_AUTH_PENDING` | Authorization pending |
| `SOFTPOS_AUTH_CONFIRMED` | Authorization confirmed |
| `SOFTPOS_CAPTURE_CONFIRMED` | Capture confirmed if applicable |
| `SOFTPOS_FAILED` | Payment failed |
| `SOFTPOS_RECONCILIATION_REQUIRED` | Reconciliation required |
| `SOFTPOS_SECURITY_REVOKED` | Device/security revoked |

SoftPOS must have revocation path.

---

## 27. Hardware Cost Reduction Boundary

SoftPOS or local device reuse may reduce hardware cost.

Cost reduction must not compromise:

- payment security
- device trust
- durability
- offline operation
- printer/KDS integration
- customer privacy
- merchant supportability
- provider certification
- chargeback evidence
- reconciliation

Cheap hardware is not acceptable if it weakens financial trust.

---

## 28. Relationship To Remote Wait And Preorder

This document extends `10609K` by adding:

- realtime stream for wait/preorder state propagation
- AI wait-time prediction
- local mesh for offline preorder/store operation
- dynamic pricing for dead-time demand shaping
- SoftPOS options for lower hardware adoption barrier

Remote wait/preorder must remain financially governed even when realtime and AI features are added.

---

## 29. Relationship To Financial Trust

Financial Trust must enforce:

- realtime projection separation from financial truth
- SoftPOS payment verification
- OCR/NFC payment compliance boundary
- dynamic pricing discount ledger
- coupon/promotion redemption state
- local offline event reconciliation
- payment provider confirmation
- chargeback evidence linkage

Financial Trust must not accept local or realtime messages as final payment truth.

---

## 30. Relationship To Store Runtime

Store Runtime must support:

- realtime order/KDS/staff updates
- local mesh degraded operation
- physical device health state
- AI wait estimate projection
- kitchen completion event
- table status updates
- staff acknowledgement
- dynamic pricing operational state
- SoftPOS availability state

Store Runtime owns execution state.

It does not own financial finality.

---

## 31. Relationship To Data Governance

Data Governance must control:

- realtime projection visibility
- AI prediction explanation
- customer wait estimate message
- local mesh event retention
- dynamic pricing message
- promotion/coupon visibility
- SoftPOS evidence masking
- OCR data handling prohibition/controls
- i18n messages
- export restrictions

Realtime and AI data must be scoped and privacy-aware.

---

## 32. Relationship To Security Agent

Security Agent may detect:

- stream hijacking
- abnormal reconnect storm
- event ordering anomaly
- local mesh spoofing
- offline event injection
- AI prediction manipulation
- dynamic pricing abuse
- promotion fraud
- SoftPOS device compromise
- OCR payment data leak risk
- NFC replay/tap anomaly

Security Agent may alert or contain.

It must not finalize payment truth or policy legality.

---

## 33. Relationship To Cross-Room Plumbing

Future event routing must carry:

- stream id
- connection id
- event sequence
- realtime projection id
- AI prediction id
- prediction confidence
- local mesh session id
- offline event sequence
- local hash chain ref
- dynamic pricing rule id
- promotion/coupon id
- SoftPOS device id
- SoftPOS transaction id
- OCR attempt id
- NFC tap evidence id
- field control evidence packet id

These become context envelope and evidence packet candidates.

---

## 34. Anti-Patterns

Avoid:

- using realtime message as source truth
- allowing websocket command without authorization check
- assuming event arrival order
- promising exact AI wait time as guarantee
- starting kitchen solely from AI estimate
- silently merging local offline events
- treating local mesh as central ledger authority
- dynamic pricing without margin and fairness controls
- coupon display treated as redemption
- SoftPOS without provider/security certification
- raw OCR card data logging
- NFC tap treated as settled payment
- reducing hardware cost at the expense of payment trust
- customer-facing message claiming certainty when state is provisional

These anti-patterns must be blocked in future runtime design.

---

## 35. Runtime Deferral

This document defines realtime sync, AI turnover prediction, local mesh, dynamic pricing, SoftPOS, OCR, and NFC field-control boundaries only.

It does not authorize:

- WebSocket implementation
- gRPC implementation
- realtime stream runtime
- AI turnover prediction model
- local mesh/P2P implementation
- offline local ledger runtime
- dynamic pricing engine
- time-sale engine
- SoftPOS integration
- OCR payment flow
- NFC payment acceptance
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 36. Validation Checklist

Validation must confirm:

1. Field control expansion catalog is defined.
2. Realtime sync boundary is defined.
3. WebSocket/gRPC channel boundary is defined.
4. Stream state skeleton is defined.
5. Realtime event ordering boundary is defined.
6. Stream backpressure boundary is defined.
7. KDS/POS realtime handoff boundary is defined.
8. AI turnover prediction boundary is defined.
9. Wait-time prediction state skeleton is defined.
10. AI prediction evidence boundary is defined.
11. Virtual queue optimization boundary is defined.
12. Local mesh/local relay boundary is defined.
13. Local mesh authority boundary is defined.
14. Local mesh event envelope boundary is defined.
15. Local sync recovery boundary is defined.
16. Dynamic pricing boundary is defined.
17. Dynamic pricing state skeleton is defined.
18. Time-sale trigger boundary is defined.
19. Promotion/coupon distinction boundary is defined.
20. Dynamic pricing evidence packet is defined.
21. SoftPOS boundary is defined.
22. NFC app-to-app payment boundary is defined.
23. OCR payment boundary is defined.
24. SoftPOS state skeleton is defined.
25. Hardware cost reduction boundary is defined.
26. Relationships to Remote Wait/Preorder, Financial Trust, Store Runtime, Data Governance, Security Agent, and Cross-Room Plumbing are defined.
27. Anti-patterns are listed.
28. Coding remains unauthorized.
29. Runtime remains deferred.

---

## 37. Relationship To Previous Documents

This document supplements:

- `10609K Remote Wait Preorder Queue Authorization Capture NFC Handshake And Peak Traffic Control Policy`
- `10609L No-Show Deposit Penalty Abuse Scoring Booking Circuit Breaker And Reservation Financial Control Policy`

It references:

- `10210 Order Intake Room Boundary Policy`
- `10230 POS Handoff Room Boundary Policy`
- `10240 KDS Ticket Room Boundary Policy`
- `10250 Kitchen Execution Room Boundary Policy`
- `10270 Device Runtime Room Boundary Policy`
- `10290 Degraded Operation Room Boundary Policy`
- `10330 Fulfillment Visibility Room Boundary Policy`
- `10400~10480 Financial Trust Room Framing Sequence`
- `10530 Safe Projection Masking And Audience Visibility Boundary Policy`
- `10540 AI Advisory Runtime And Non-Authority Boundary Policy`
- `10550 pgvector Context Retrieval And Similarity Boundary Policy`
- `10580 Data Governance Closure And Cross-Room Handoff Policy`
- `10600 Cross-Room Plumbing Wiring Insulation Planning Index`
- `10608 Pseudonymized AI Analysis Noisy Neighbor Control Nonce Idempotency And Final SaaS Edge Guard Policy`
- `10609G External Financial Network Circuit Breaker Saga Fallback KYC And Account Ownership Verification Policy`
- `10609K Remote Wait Preorder Queue Authorization Capture NFC Handshake And Peak Traffic Control Policy`
- `10609L No-Show Deposit Penalty Abuse Scoring Booking Circuit Breaker And Reservation Financial Control Policy`

It prepares:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- future realtime sync specification
- future AI wait-time prediction specification
- future local mesh/offline sync specification
- future dynamic pricing and time-sale policy review packet
- future SoftPOS/NFC/OCR payment feasibility review packet
- future field-control evidence packet

This document is architecture boundary planning only.

It does not authorize coding.

---

## 38. Final Rule

Field-control expansion must improve speed, resilience, revenue, and hardware flexibility without weakening authority separation.

Realtime streaming reduces latency but does not become source truth.

AI wait-time prediction improves queue experience but does not guarantee seating time.

Local mesh preserves store operation during internet outage but remains provisional until central reconciliation.

Dynamic pricing converts unused capacity into revenue only through governed, simulated, margin-protected, and customer-safe policy.

SoftPOS, NFC app-to-app payment, and OCR payment are payment-security-sensitive capabilities requiring provider certification, compliance review, device attestation, evidence, and reconciliation.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.