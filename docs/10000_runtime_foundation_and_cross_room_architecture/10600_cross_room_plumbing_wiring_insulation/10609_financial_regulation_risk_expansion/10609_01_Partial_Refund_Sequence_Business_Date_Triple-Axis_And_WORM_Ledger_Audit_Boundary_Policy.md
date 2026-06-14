# 10609_01_Partial_Refund_Sequence_Business_Date_Triple-Axis_And_WORM_Ledger_Audit_Boundary_Policy

## 1. Purpose

This document defines the Partial Refund Sequence, Business Date Triple-Axis, and WORM Ledger Audit Boundary Policy.

The previous artifact `10609` defined financial regulation, escrow, FDS, and settlement lag boundaries.

This document adds three additional financial-grade edge controls:

1. Partial refund and chained cancellation sequence control.
2. Separation of timestamp, business date, and settlement date.
3. Insider-resistant WORM / ledger-style immutable audit trail.

The purpose is to ensure that the platform does not collapse under partial refund chains, restaurant business-day ambiguity, or privileged insider manipulation of audit evidence.

This document is planning-only.

It does not authorize coding.

It is not legal advice.

---

## 2. Core Position

Financial-grade SaaS must protect the ledger even when transactions are partially reversed, dated across multiple time axes, or attacked by insiders.

The correct rule is:

Partial refund is not simple refund.  
Multiple partial refunds must preserve sequence.  
Full cancellation after partial refund is not the same as original full cancellation.  
Arrival order is not business order.  
Calendar date is not business date.  
Business date is not settlement date.  
Audit log in ordinary mutable DB is not sufficient insider protection.  
Admin privilege is not audit privilege.  
WORM record is evidence, not operational mutation.  
Ledger hash chain broken means review, not automatic truth correction.  

The system must preserve sequence, date semantics, and immutable audit evidence.

---

## 3. Ultimate Financial Edge Catalog

The following edge cases must be treated as mandatory design risks:

| Edge Case | Risk |
|---|---|
| `PARTIAL_REFUND_SEQUENCE_DRIFT` | Partial refund events arrive out of order |
| `PARTIAL_REFUND_OVER_AMOUNT` | Refund chain exceeds captured amount |
| `FULL_CANCEL_AFTER_PARTIAL_REFUND` | Full cancel conflicts with prior partial refund |
| `REFUND_REPLAY_AFTER_PARTIAL` | Old partial refund packet is replayed |
| `ORDER_LINE_REFUND_MISMATCH` | Menu-line refund does not match payment amount |
| `POINT_REWARD_PARTIAL_REVERSAL` | Points/coupons/wallet value not reversed correctly |
| `CALENDAR_BUSINESS_DATE_MISMATCH` | Report date and store business date diverge |
| `SETTLEMENT_DATE_LAG_MISMATCH` | Money movement date differs from sales/refund date |
| `WEEKEND_HOLIDAY_SETTLEMENT_SHIFT` | Provider/bank settlement shifts after weekend/holiday |
| `INSIDER_AUDIT_DELETE` | Privileged operator deletes audit evidence |
| `INSIDER_LEDGER_UPDATE` | Privileged operator mutates financial source record |
| `AUDIT_CHAIN_BREAK` | Hash chain indicates tampering or missing record |
| `WORM_ARCHIVE_FAILURE` | Immutable archive does not receive required audit packet |

Each edge case must have evidence, review, and reconciliation routing.

---

## 4. Partial Refund Boundary

Partial refund means only part of an original payment is reversed.

Partial refund may be based on:

- one canceled menu item
- unavailable item
- wrong item
- customer complaint
- discount adjustment
- point compensation
- coupon correction
- delivery/service issue
- staff override
- duplicate item correction
- settlement dispute correction

Partial refund must not be treated as a simple negative sale.

It is a sub-transaction linked to an original payment ledger.

---

## 5. Payment Ledger Version Sequence Boundary

Each financial ledger root must have version sequence control.

A payment root may have:

| Version | Example |
|---|---|
| `v1` | Original authorization/capture |
| `v2` | Partial refund 1 |
| `v3` | Partial refund 2 |
| `v4` | additional adjustment |
| `v5` | full remaining cancellation |
| `v6` | amendment after reconciliation |

Every child transaction must reference:

- original payment id
- parent ledger root id
- expected current version
- next version
- operation type
- amount delta
- remaining refundable amount
- actor/system
- provider reference
- evidence packet
- audit reference

Version sequence prevents unordered mutation.

---

## 6. Optimistic Versioning Boundary

Partial refund and cancellation must use optimistic versioning or equivalent control.

Required checks:

- original payment exists
- payment is eligible for refund/cancel
- expected version matches current version
- prior refund/cancel operation is complete or explicitly pending
- requested refund amount does not exceed remaining refundable amount
- currency matches
- tenant/store/legal scope matches
- provider reference matches
- idempotency key is valid
- nonce is valid
- audit route exists
- settlement impact is calculated
- state transition is allowed

If expected version differs, the operation must fail closed or enter review.

Version conflict is not silent retry.

---

## 7. Partial Refund State Skeleton

Recommended states:

| State | Meaning |
|---|---|
| `REFUND_NOT_STARTED` | No refund exists |
| `PARTIAL_REFUND_REQUESTED` | Partial refund requested |
| `PARTIAL_REFUND_REVIEW_REQUIRED` | Review required |
| `PARTIAL_REFUND_APPROVED` | Internal approval completed |
| `PARTIAL_REFUND_SENT_TO_PROVIDER` | Sent to provider |
| `PARTIAL_REFUND_PROVIDER_ACCEPTED` | Provider accepted |
| `PARTIAL_REFUND_PENDING_SETTLEMENT` | Money impact not settled |
| `PARTIAL_REFUND_SETTLED` | Settlement impact confirmed |
| `PARTIAL_REFUND_FAILED` | Verified failure |
| `PARTIAL_REFUND_VERSION_CONFLICT` | Version mismatch |
| `PARTIAL_REFUND_RECONCILIATION_REQUIRED` | Reconciliation required |
| `PARTIAL_REFUND_DLQ_REQUIRED` | DLQ isolation required |

Partial refund state must not be collapsed into simple refund status.

---

## 8. Full Cancellation After Partial Refund Boundary

If full cancellation occurs after partial refund, the system must calculate only the remaining refundable amount.

Required controls:

- check original payment amount
- subtract already accepted partial refunds
- subtract pending partial refunds if policy requires
- check provider status
- check remaining refundable amount
- validate sequence version
- block over-refund
- preserve line-item linkage
- create settlement adjustment
- create owner-safe explanation
- reconcile provider response

Full cancel after partial refund is not original full cancel.

It is cancellation of remaining balance.

---

## 9. Out-of-Order Refund Arrival Boundary

Distributed systems may deliver refund/cancel packets out of order.

Examples:

- full cancel arrives before partial refund packet
- provider callback arrives before internal state update
- retry of old partial refund arrives after later version
- offline device sync sends stale refund event
- failover region replays old cancellation
- provider settlement file includes delayed refund

Arrival order must not define ledger order.

Ledger version and state transition define ledger order.

Out-of-order events must be held, reconciled, or DLQ-routed.

---

## 10. Over-Refund Prevention Boundary

Over-refund is critical.

System must prevent:

- partial refunds exceeding captured amount
- coupon/point reversal exceeding issued value
- wallet credit duplicated
- refund after full cancellation
- replayed refund packet
- provider callback duplication
- manual refund plus automated refund duplicate
- refund across wrong payment root
- refund under wrong tenant/store/legal entity

Over-refund must create financial/security review.

---

## 11. Order-Line Refund Linkage Boundary

Partial refund should preserve item-level or reason-level linkage where possible.

Linkage may include:

- order id
- order line id
- menu item id
- quantity
- original line amount
- tax/fee if applicable
- discount allocation
- coupon allocation
- point allocation
- wallet allocation
- refund reason
- staff/manager approval
- customer complaint reference
- provider refund reference

Payment refund without order-line context weakens CS and settlement evidence.

---

## 12. Value Instrument Reversal Boundary

Partial refund may affect value instruments.

Affected instruments may include:

- coupon redemption
- point accrual
- point redemption
- wallet debit
- wallet credit
- stored value
- compensation credit
- promotional benefit
- membership tier progress

The system must define whether each value instrument is:

- reversed immediately
- held pending settlement
- recalculated after refund settlement
- manually reviewed
- excluded by policy
- amended later

Value reversal must not silently diverge from payment refund.

---

## 13. Triple-Date Financial Boundary

Every financial transaction may require three independent time axes.

| Date Axis | Meaning |
|---|---|
| `transaction_timestamp` | Actual event timestamp |
| `business_date` | Store-defined sales/operation date |
| `settlement_date` | Provider/bank money movement date |

These must be independent fields.

One receipt may have:

- calendar timestamp on Saturday 01:30
- business date as Friday trading day
- settlement date as Monday or later

The platform must not assume these dates are identical.

---

## 14. Calendar Day Boundary

Calendar day is the civil date based on timestamp.

It is useful for:

- raw event chronology
- audit timeline
- provider timestamp comparison
- security analysis
- OS/runtime event ordering
- legal timestamp evidence
- replay detection
- cutoff analysis

Calendar day is not always store sales day.

Calendar day is not always settlement day.

---

## 15. Business Day Boundary

Business day is the store-defined operating date.

Business day may be determined by:

- store close time
- tenant policy
- twenty-four-hour store cutover
- franchise group rule
- legal entity rule
- holiday schedule
- manual close event
- open transaction rule
- after-midnight rule
- provider mapping rule if applicable

Business day is owner-facing sales reality.

It must be policy-versioned and auditable.

---

## 16. Settlement Date Boundary

Settlement date is when money is expected or confirmed to move through provider/bank.

Settlement date may depend on:

- provider policy
- card company policy
- bank business day
- weekend
- public holiday
- refund lag
- cancellation timing
- merchant contract
- settlement cycle
- provider adjustment
- dispute/chargeback
- hold/reserve
- compliance review

Settlement date is financial cash reality.

It must not be confused with business date.

---

## 17. Business Date And Settlement Projection Boundary

Owner dashboard must separate:

- calendar sales timestamp
- business date sales
- provider authorization date
- refund/cancel request date
- settlement expected date
- settlement confirmed date
- payout date
- pending settlement amount
- held amount
- disputed amount

Owner view must not imply that business-date sales equal bank deposit on the same date.

---

## 18. Weekend Holiday Settlement Shift Boundary

Weekend/holiday settlement shift must be modeled.

Shift cases include:

- Friday late-night sale settled next business day
- Saturday/Sunday card settlement delayed
- holiday settlement delayed
- refund accepted but settlement delayed
- provider file delayed after bank holiday
- store business date differs from provider batch date

Shift is not reconciliation error.

Shift is a pending settlement state with expected date.

---

## 19. Immutable Audit Boundary

Critical financial/security audit must not be stored only in mutable operational DB.

Immutable audit candidates:

- payment creation
- provider callback
- refund/cancel request
- partial refund state transition
- settlement candidate
- settlement finalization
- amendment
- DLQ creation/resolution
- device key issuance/revocation
- account/virtual account change
- provider credential access
- export delivery
- admin override
- batch report
- WORM archive write
- security containment
- restore/failover event

Mutable audit alone is insufficient for insider-resistant design.

---

## 20. WORM Storage Boundary

WORM or equivalent immutable storage may be required for high-risk audit records.

WORM record must preserve:

- event id
- tenant/store/legal scope
- source object id
- event type
- event payload hash
- previous hash if chained
- actor/system
- timestamp
- DB transaction reference
- signature if applicable
- batch reference if applicable
- archive location
- retention class
- legal hold marker

WORM storage is evidence preservation.

It is not business state mutation.

---

## 21. Hash Chain Boundary

Audit records may be chained.

Hash chain fields may include:

- chain id
- sequence number
- previous record hash
- current payload hash
- current record hash
- tenant/store partition
- business date partition
- event family
- created timestamp
- signer/system identity
- WORM write reference

If one record is changed, hash chain breaks.

Broken chain creates critical review.

---

## 22. Ledger Database Boundary

A ledger-style database or append-only ledger mechanism may be considered for audit/financial evidence.

Ledger mechanism may provide:

- append-only records
- cryptographic verification
- record history
- tamper evidence
- verification API
- immutable digest
- audit chain
- exportable proof

Ledger DB is not a substitute for business logic.

It is evidence infrastructure.

---

## 23. Insider Threat Boundary

Insider threat includes:

- developer modifying DB record
- DBA deleting audit trail
- infra operator disabling log pipeline
- admin changing settlement account
- support staff hiding DLQ case
- batch operator suppressing mismatch
- deployer modifying batch code
- privileged user changing provider credential
- manual script bypassing application authority

Insider threat must be treated as real.

Privileged access must be audited, scoped, approved, and reviewed.

---

## 24. Privileged Access Boundary

Privileged access must be controlled.

Required principles:

- least privilege
- separation of duties
- break-glass procedure
- time-limited access
- purpose-limited session
- reauthentication
- approval
- session recording where applicable
- command audit
- export audit
- post-access review
- no direct silent mutation
- immutable audit of privileged action

Admin is not above audit.

---

## 25. Direct DB Mutation Boundary

Direct DB mutation of financial records must be prohibited by default.

If emergency mutation is unavoidable:

- break-glass approval required
- reason required
- before/after snapshot required
- immutable audit required
- amendment record required
- reconciliation required
- postmortem required
- tenant/store/legal scope required
- affected owner projection required if material

Direct update must never silently replace ledger history.

---

## 26. Audit Chain Break Boundary

Audit chain break may indicate:

- missing record
- corrupted archive
- failed WORM write
- privileged tampering
- storage issue
- deployment bug
- hash algorithm mismatch
- partition boundary issue
- recovery/restore mismatch

Chain break is critical evidence incident.

It must create security, finance, and compliance review.

Chain break is not automatic fraud proof.

---

## 27. WORM Failure Boundary

If WORM write fails for critical event:

Required handling:

- mark event as `IMMUTABLE_AUDIT_PENDING`
- retry via controlled queue
- preserve local/DB audit reference
- block finalization if required by policy
- alert security/finance
- create reconciliation note
- prevent deletion of source evidence
- include in nightly batch report

Critical event without immutable audit may be incomplete.

---

## 28. Audit Retention Boundary

Immutable audit retention must align with:

- financial record retention
- security event retention
- legal hold
- compliance hold
- dispute window
- provider contract
- tax/accounting policy
- internal governance
- archive cost policy

Exact legal period must be confirmed separately.

Retention must not be guessed in code.

---

## 29. Audit Verification Batch Boundary

Nightly or periodic audit verification should check:

- DB audit versus WORM audit
- WORM hash chain continuity
- ledger digest validity
- missing critical event
- unexpected direct update
- privileged access session
- batch report hash
- archive write success
- DLQ chain continuity
- settlement amendment history
- account change evidence

Audit verification is separate from payment reconciliation but linked to it.

---

## 30. VC / Tech Due Diligence Boundary

Large investors, enterprise partners, PGs, or auditors may ask:

- Can tenants be isolated?
- Can one tenant exhaust another tenant’s resources?
- Can an insider alter settlement records?
- Can audit logs be deleted?
- Can partial refunds exceed original payment?
- Can business date and settlement date be explained?
- Can restore be proven?
- Can DR be tested?
- Can all financial actions be traced?
- Can support explain disputes without raw DB access?
- Can legal/compliance evidence be exported safely?

Architecture must be able to answer with evidence, not slogans.

---

## 31. Patent Candidate Boundary

These controls strengthen the patent candidate.

Potential patent-relevant extensions:

- version-sequenced partial refund ledger for restaurant order/payment SaaS
- optimistic versioning for chained partial refund and cancellation operations
- triple-date restaurant fintech ledger separating timestamp, business date, and settlement date
- WORM-backed audit hash chain for insider-resistant restaurant settlement records
- nightly verification of DB trigger audit against immutable ledger records
- human-readable dispute timeline backed by immutable chain evidence
- combined partial refund, business date, settlement lag, and WORM audit architecture

Patent attorney review is required.

This document is architecture planning only.

---

## 32. Relationship To Financial Trust

This document extends Financial Trust by adding:

- version-sequenced partial refund
- chained cancellation protection
- over-refund prevention
- order-line refund linkage
- value instrument reversal
- triple-date accounting
- immutable audit trail
- WORM failure handling
- insider threat controls

Financial Trust must not allow mutable direct updates to replace ledger history.

---

## 33. Relationship To Data Governance

Data Governance must control:

- owner-facing date explanations
- partial refund status messages
- settlement date projection
- audit evidence masking
- CS timeline projection
- WORM archive retrieval
- export of immutable evidence
- legal/compliance hold
- AI summary of refund chains
- i18n messages for pending/held/settled states

Human-readable projection must not weaken evidence.

---

## 34. Relationship To Security Agent

Security Agent may detect:

- over-refund attempt
- refund sequence conflict
- repeated partial refund loop
- audit chain break
- WORM write failure
- privileged access anomaly
- direct DB mutation attempt
- account change anomaly
- batch suppression pattern
- audit deletion attempt

Security Agent may alert or contain.

It must not finalize legal guilt or financial truth.

---

## 35. Relationship To Cross-Room Plumbing

Future event routing must carry:

- payment root id
- ledger version
- expected version
- operation sequence
- remaining refundable amount
- order-line refund reference
- value reversal reference
- transaction timestamp
- business date
- settlement date
- WORM reference
- audit chain id
- previous hash
- current hash
- privileged action marker
- chain verification status

These become context envelope candidates.

---

## 36. Anti-Patterns

Avoid:

- treating partial refund as simple negative sale
- allowing partial refund without version sequence
- processing full cancel before prior partial refund is resolved
- allowing refund amount to exceed captured amount
- ignoring point/coupon/wallet reversal after partial refund
- using calendar date as business date automatically
- using business date as settlement date automatically
- hiding settlement date lag from owner dashboard
- storing critical audit only in mutable DB
- allowing DBA/admin to delete audit trail silently
- permitting direct DB UPDATE as correction
- ignoring WORM write failure
- treating broken hash chain as harmless
- investor/auditor answers based on claims rather than evidence

These anti-patterns must be blocked in future runtime design.

---

## 37. Runtime Deferral

This document defines partial refund, triple-date accounting, WORM audit, and insider-resistant ledger boundaries only.

It does not authorize:

- partial refund engine
- optimistic versioning implementation
- refund sequence table
- triple-date schema
- WORM storage integration
- ledger database integration
- hash chain implementation
- privileged access workflow
- audit verification batch
- direct DB mutation controls
- owner dashboard changes
- database schema
- RLS policy
- production deployment

All runtime remains deferred.

---

## 38. Validation Checklist

Validation must confirm:

1. Ultimate financial edge catalog is defined.
2. Partial refund boundary is defined.
3. Payment ledger version sequence boundary is defined.
4. Optimistic versioning boundary is defined.
5. Partial refund state skeleton is defined.
6. Full cancellation after partial refund boundary is defined.
7. Out-of-order refund arrival boundary is defined.
8. Over-refund prevention boundary is defined.
9. Order-line refund linkage boundary is defined.
10. Value instrument reversal boundary is defined.
11. Triple-date financial boundary is defined.
12. Calendar day boundary is defined.
13. Business day boundary is defined.
14. Settlement date boundary is defined.
15. Business date and settlement projection boundary is defined.
16. Weekend/holiday settlement shift boundary is defined.
17. Immutable audit boundary is defined.
18. WORM storage boundary is defined.
19. Hash chain boundary is defined.
20. Ledger database boundary is defined.
21. Insider threat boundary is defined.
22. Privileged access boundary is defined.
23. Direct DB mutation boundary is defined.
24. Audit chain break boundary is defined.
25. WORM failure boundary is defined.
26. Audit retention boundary is defined.
27. Audit verification batch boundary is defined.
28. VC/Tech Due Diligence boundary is defined.
29. Patent candidate boundary is defined.
30. Relationships to Financial Trust, Data Governance, Security Agent, and Cross-Room Plumbing are defined.
31. Anti-patterns are listed.
32. Coding remains unauthorized.
33. Runtime remains deferred.

---

## 39. Relationship To Previous Documents

This document supplements:

- `10609 Financial Regulation Escrow FDS And Settlement Lag Risk Boundary Policy`

It references:

- `10400~10480 Financial Trust Room Framing Sequence`
- `10530 Safe Projection Masking And Audience Visibility Boundary Policy`
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

It prepares:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- future partial refund versioning specification
- future triple-date accounting schema packet
- future immutable audit/WORM design packet
- future privileged access governance packet
- future due diligence evidence packet

This document is architecture boundary planning only.

It does not authorize coding.

---

## 40. Final Rule

Financial-grade SaaS must protect partial refunds, date semantics, and audit immutability.

Every partial refund and cancellation chain must preserve ledger root, version sequence, expected version, amount delta, remaining refundable amount, order-line linkage, value reversal, provider evidence, idempotency, audit, and reconciliation state.

Calendar timestamp, business date, and settlement date must be separate first-class fields.

Weekend, holiday, after-midnight, and provider settlement lag must not be treated as reconciliation errors when they are expected date-axis differences.

Critical audit must not live only in mutable operational tables.

WORM, ledger-style append-only records, hash chains, privileged access audit, and periodic verification are required design boundaries for insider-resistant financial evidence.

Admin privilege must not bypass audit.

Direct DB mutation must not replace append-only amendment.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.