# 010455_Policy_Acquiring_Ledger_Kernel.md

## Purpose

This document defines the Acquiring State, Fixed-Point Arithmetic, Append-Only Ledger Continuity, and Financial Kernel Map Policy.

The previous artifacts defined:

- `10609 Financial Regulation Escrow FDS And Settlement Lag Risk Boundary Policy`
- `10609A Partial Refund Sequence Business Date Triple-Axis And WORM Ledger Audit Boundary Policy`
- `10609B Commercial Platform Benchmark Order Payment Hardware Financial Tax And Compliance Verification Boundary Policy`
- `10609C Double-Entry Ledger Money Flow AML FDS Freezing And Merkle Integrity Kernel Policy`

This document adds three additional financial-kernel controls:

1. Card acquiring state tracking beyond simple authorization.
2. Fixed-point integer arithmetic for fee, VAT, refund, settlement, and payout calculation.
3. Log-structured append-only ledger continuity with hash-linked balance verification.

The purpose is to ensure that Catch Menu does not confuse authorization with acquiring completion, does not allow floating-point arithmetic to create ledger drift, and does not allow ledger continuity to break silently through data loss, hardware corruption, direct mutation, or partial record damage.

This document is planning-only.

It does not authorize coding.

It is not legal, accounting, tax, financial regulatory, PG/VAN, card-network, or banking advice.

External acquiring, merchant settlement, provider file, tax, and compliance requirements must be verified through PG/VAN/card partner documentation, contracts, legal review, accounting review, and technical due diligence.

---

## 2. Core Position

Financial-grade systems must verify authorization, acquiring, settlement, arithmetic, and ledger continuity separately.

The correct rule is:

Authorization approved is not acquiring completed.  
Acquiring requested is not acquiring confirmed.  
Acquiring confirmed is not payout completed.  
Settlement available is not bank-settled cash.  
Floating-point money arithmetic is prohibited.  
Rounding policy must be explicit and auditable.  
Append-only ledger means INSERT-only financial events.  
Correction is reversal or amendment, not UPDATE.  
Ledger continuity must be hash-verifiable.  
Missing ledger row is not a small defect.  
A one-won error is a financial integrity signal.  

The system must preserve acquiring state, exact arithmetic, and ledger continuity before settlement finality.

---

## 3. Financial Kernel Extension Catalog

The following kernel extensions are added:

| Kernel Extension | Purpose |
|---|---|
| `ACQUIRING_STATE_TRACKING` | Track authorization through acquiring and settlement availability |
| `ACQUIRING_EXCEPTION_RECONCILIATION` | Detect acquiring hold, rejection, missing file, or delayed confirmation |
| `SETTLEMENT_AVAILABLE_FILTER` | Allow payout/settlement only from confirmed eligible records |
| `FIXED_POINT_MONEY_ARITHMETIC` | Prevent floating-point rounding drift |
| `ROUNDING_POLICY_REGISTRY` | Make every fractional allocation explainable |
| `LOG_STRUCTURED_APPEND_ONLY_LEDGER` | Prohibit financial UPDATE/DELETE and preserve event history |
| `RUNNING_BALANCE_HASH_CHAIN` | Detect missing or altered ledger records |
| `LEDGER_CONTINUITY_VERIFICATION` | Verify that prior ledger output feeds next ledger input |
| `FINANCIAL_KERNEL_MAP` | Map edge, server, DB, batch, compliance, and storage layers |

These extensions must be reflected before runtime authorization.

---

## 4. Card Authorization Versus Acquiring Boundary

Card authorization and acquiring are different states.

Authorization means the payment request was approved by the payment network or provider route.

Acquiring means the authorized sales slip or transaction has been accepted into the acquiring/clearing process for merchant settlement.

The platform must not treat authorization as final settlement availability.

Possible states:

| State | Meaning |
|---|---|
| `AUTHORIZATION_REQUESTED` | Authorization request was sent |
| `AUTHORIZATION_APPROVED` | Authorization approved |
| `AUTHORIZATION_DECLINED` | Authorization declined |
| `ACQUIRING_REQUEST_PENDING` | Acquiring submission not yet confirmed |
| `ACQUIRING_REQUEST_SENT` | Acquiring request sent |
| `ACQUIRING_ACCEPTED` | Acquiring accepted |
| `ACQUIRING_HELD` | Acquiring held/pending review |
| `ACQUIRING_REJECTED` | Acquiring rejected/returned |
| `ACQUIRING_RETRY_REQUIRED` | Retry required |
| `SETTLEMENT_AVAILABLE` | Eligible for settlement calculation |
| `SETTLEMENT_COMPLETED` | Settlement completed |
| `ACQUIRING_RECONCILIATION_REQUIRED` | Requires reconciliation |
| `ACQUIRING_DLQ_REQUIRED` | Requires DLQ isolation |

Authorization is not enough for payout.

---

## 5. Acquiring State Machine Boundary

The acquiring lifecycle must be state-machine controlled.

Recommended flow:

    AUTHORIZATION_APPROVED
      -> ACQUIRING_REQUEST_PENDING
      -> ACQUIRING_REQUEST_SENT
      -> ACQUIRING_ACCEPTED
      -> SETTLEMENT_AVAILABLE
      -> SETTLEMENT_COMPLETED

Exception paths:

    ACQUIRING_HELD
    ACQUIRING_REJECTED
    ACQUIRING_RETRY_REQUIRED
    ACQUIRING_RECONCILIATION_REQUIRED
    ACQUIRING_DLQ_REQUIRED

State transition must verify:

- tenant/store/legal scope
- merchant id
- provider id
- TID/approval number
- amount
- currency
- business date
- provider batch date
- acquiring file/reference
- provider response
- idempotency key
- audit reference
- evidence packet

Invalid acquiring transition must fail closed.

---

## 6. Acquiring Log Matching Boundary

The nightly or provider-aware batch must match authorization records with acquiring confirmation records.

Matching keys may include:

- tenant id
- store id
- legal entity id
- provider id
- merchant id
- terminal id
- TID
- approval number
- provider transaction id
- authorization date
- acquiring batch id
- acquiring file id
- amount
- currency
- transaction timestamp
- business date
- settlement expected date

Acquiring log missing means settlement availability is not proven.

Acquiring log mismatch creates reconciliation.

---

## 7. Acquiring Hold And Rejection Boundary

Acquiring may be held or rejected due to:

- provider file format issue
- merchant mapping error
- invalid terminal id
- duplicate authorization
- amount mismatch
- cancellation/refund conflict
- card company rejection
- risk/FDS review
- provider batch delay
- network/file transfer error
- legal/compliance hold
- provider settlement exception

Held/rejected acquiring record must not be included in settlement available funds unless later resolved.

---

## 8. Settlement Available Fund Boundary

Settlement available fund must include only records that pass required filters.

Candidate filters:

- authorization approved
- acquiring accepted
- cancellation/refund state checked
- partial refund version checked
- provider clearing matched
- tenant/store/legal scope verified
- merchant/account mapping verified
- DLQ not unresolved
- hold/reserve not applied
- settlement lag state understood
- fee/VAT calculation snapshot valid
- audit/WORM requirement satisfied where required

Settlement available is a derived controlled state.

It is not the same as gross approved sales.

---

## 9. Advance Payout Risk Boundary

If settlement is paid before acquiring or provider cash confirmation, the platform may create receivable risk.

Advance payout risks:

- acquiring rejection after payout
- refund lag after payout
- chargeback after payout
- provider delay after payout
- wrong account mapping
- suspicious transaction hold
- settlement file mismatch
- merchant contract issue

Advance payout must be legally and financially approved if ever used.

Default early SaaS posture should avoid uncontrolled advance payout.

---

## 10. Fixed-Point Arithmetic Boundary

All money arithmetic must avoid binary floating-point.

Money-related arithmetic includes:

- order total
- payment amount
- refund amount
- partial refund amount
- coupon allocation
- point allocation
- wallet movement
- VAT/tax allocation
- provider fee
- platform fee
- franchise fee
- settlement amount
- payout amount
- reserve/hold amount
- adjustment/amendment amount
- rounding difference
- FX amount if ever applicable

Floating-point arithmetic is prohibited for financial truth.

---

## 11. Integer Money Unit Boundary

Money should be represented as integer minor units or approved fixed-point units.

Examples:

| Representation | Meaning |
|---|---|
| `amount_minor_unit` | Integer won or currency minor unit |
| `amount_scaled_10000` | Integer scaled by 10,000 for fractional rate calculation |
| `rate_basis_points` | Integer basis points |
| `rate_scaled_1000000` | Integer rate scale for higher precision |
| `tax_rate_scaled` | Integer tax rate scale |
| `fee_rate_scaled` | Integer fee rate scale |
| `rounding_policy_id` | Policy that explains final rounding |

The chosen scale must be documented and consistent.

---

## 12. Rate Calculation Boundary

Fees and VAT may require fractional rates.

Rate calculation must define:

- rate scale
- multiplication order
- division order
- rounding step
- rounding direction
- cumulative adjustment rule
- line-level versus order-level rule
- provider-specific fee rule
- tenant-specific policy if allowed
- policy version
- audit reference

Example principle:

    Do not calculate 10000 * 1.235% using binary float.

Use integer scaled arithmetic or approved decimal/fixed-point library.

---

## 13. Rounding Difference Boundary

Rounding differences must be explicit.

Rounding difference handling may include:

- allocate to largest line
- allocate to final line
- create rounding adjustment line
- carry to settlement adjustment
- block if above threshold
- create reconciliation case
- record policy version
- record before/after calculation
- audit rounding result

Rounding difference must not disappear.

One won difference must be explainable.

---

## 14. VAT And Fee Snapshot Boundary

VAT/fee calculation must be based on immutable snapshot.

Snapshot must include:

- order line amounts
- discounts
- coupons
- points
- wallet/stored value
- taxable class
- tax rate
- fee rate
- provider fee rule
- platform fee rule
- rounding policy
- refund state
- partial refund version
- business date
- settlement date
- policy version
- calculation hash

Recalculation from mutable current menu/fee settings is prohibited.

---

## 15. Calculation Audit Boundary

Every high-risk calculation must preserve audit evidence.

Calculation audit may include:

- input snapshot id
- algorithm version
- scale
- rate
- intermediate integer values if needed
- rounding step
- final amount
- difference/adjustment
- actor/system
- timestamp
- evidence reference
- WORM/hash reference if required

Calculation result is not trustworthy without reproducibility.

---

## 16. Append-Only Ledger Boundary

Financial ledger must be append-only.

Allowed:

- insert original event
- insert refund event
- insert reversal event
- insert adjustment event
- insert amendment event
- insert freeze event
- insert hash verification event

Prohibited by default:

- update posted financial amount
- delete financial event
- rewrite prior ledger row
- overwrite settlement status without history
- directly patch balance
- remove DLQ trace
- alter audit chain silently

Append-only protects history.

---

## 17. Log-Structured Ledger Boundary

Log-structured ledger stores every financial event as a sequence of append-only records.

Ledger record may include:

- ledger sequence number
- ledger root id
- tenant/store/legal scope
- event type
- amount
- currency
- debit/credit line reference
- previous balance
- amount delta
- resulting balance
- previous record hash
- current payload hash
- current record hash
- source event id
- evidence packet id
- audit reference
- created timestamp

The ledger line is both event and continuity proof.

---

## 18. Running Balance Hash Boundary

Each ledger append may compute:

- prior balance
- delta amount
- resulting balance
- prior record hash
- current payload hash
- current record hash

This enables detection of:

- missing row
- altered amount
- reordered event
- deleted event
- duplicate insertion
- hash mismatch
- corrupted storage
- restore inconsistency

Running balance hash is not source mutation.

It is integrity proof.

---

## 19. Ledger Continuity Verification Boundary

Continuity verification must check:

- sequence is continuous
- previous hash matches
- current hash recomputes
- prior balance plus delta equals resulting balance
- debit/credit balance remains valid
- frozen period hash matches
- WORM/archive reference exists
- no unauthorized gap exists
- no direct mutation occurred
- restored ledger matches hash chain

Continuity failure creates critical review.

Continuity failure must not be silently repaired.

---

## 20. Ledger Gap Boundary

Ledger gap may indicate:

- missing insert
- failed write
- storage corruption
- restore issue
- direct deletion
- partition routing issue
- sequence generator error
- batch replay bug
- insider tampering
- archive migration failure

Ledger gap must create:

- security review
- finance review
- reconciliation case
- affected period hold if required
- DLQ or incident
- owner-safe projection if material
- postmortem

Gap is not harmless.

---

## 21. Append-Only Amendment Boundary

Corrections must use append-only amendment.

Amendment must include:

- original ledger record
- reason
- correction type
- reversal amount
- replacement amount if applicable
- evidence
- reviewer
- approver
- timestamp
- business date impact
- settlement date impact
- tax/report impact
- new hash chain entry
- WORM reference

Amendment must never delete original.

---

## 22. Database-Level Mutation Guard Boundary

Database-level controls should block unsafe mutations.

Candidate controls:

- no UPDATE on posted ledger table
- no DELETE on financial ledger table
- restricted INSERT-only role
- trigger blocking prohibited mutation
- audit trigger for attempted mutation
- break-glass process
- immutable audit on failed attempt
- RLS/permission separation
- privileged access review

Database should enforce financial invariants, not rely only on application discipline.

---

## 23. Acquiring And Append-Only Ledger Relationship

Acquiring state changes must be append-only.

Each acquiring transition should create:

- state transition event
- ledger/journal impact if applicable
- evidence packet
- provider reference
- audit record
- hash-chain entry
- settlement availability projection update

Acquiring rejected after authorization must not overwrite authorization.

It must append rejection/hold state.

---

## 24. Fixed-Point And Append-Only Relationship

Financial amount cannot be corrected by overwriting the old result.

If calculation policy was wrong:

- append reversal/adjustment
- preserve original calculation snapshot
- preserve corrected calculation snapshot
- record algorithm/policy version
- record reviewer/approver
- update projections from derived ledger state

Calculation error becomes amendment history.

It is not hidden.

---

## 25. Master Verification Layer Map

The financial verification layers may be mapped as follows:

| Layer | Core Verification | Protected Risk |
|---|---|---|
| Edge / Client | Device key, nonce, timestamp, peripheral health | Fake packets, replay, printer/POS failure |
| Application / Server | State machine, order-payment atomicity, network cancel | Money/order split, illegal lifecycle jumps |
| Database / Core | DB trigger, read-only view, fixed-point arithmetic | Backend bypass, data leakage, arithmetic drift |
| Batch / Financial | Four-source reconciliation, double-entry balance, DLQ | Provider mismatch, ledger imbalance, batch crash |
| Compliance / Storage | Acquiring state, append-only ledger, WORM/hash chain, tax cross-check | Acquiring failure, historical mutation, reporting mismatch |

This map is architecture planning only.

It is not proof of implementation.

---

## 26. Acquiring Evidence Packet

Acquiring evidence packet may include:

- authorization record
- TID/approval number
- provider transaction id
- acquiring request record
- acquiring response record
- acquiring batch/file id
- acquiring accepted/held/rejected status
- amount/currency
- merchant id
- terminal id
- business date
- settlement expected date
- provider raw payload hash
- adapter version
- audit reference
- DLQ/reconciliation reference if any

Acquiring evidence determines settlement availability.

---

## 27. Arithmetic Evidence Packet

Arithmetic evidence packet may include:

- calculation type
- input snapshot id
- amount scale
- rate scale
- input amounts
- fee/VAT rates
- policy version
- rounding policy
- intermediate calculation hash
- final amount
- adjustment line if any
- reviewer/approver if manual
- audit reference

Arithmetic evidence enables reproducibility.

---

## 28. Ledger Continuity Evidence Packet

Ledger continuity evidence packet may include:

- ledger partition
- start sequence
- end sequence
- start hash
- end hash
- balance start
- balance end
- recomputation result
- gap list
- mutation attempt list
- WORM/archive reference
- verification timestamp
- batch id
- reviewer if failed

Continuity evidence supports audit and due diligence.

---

## 29. Tech Due Diligence Boundary

A financial due diligence reviewer may ask:

- Do you track acquiring status separately from authorization?
- Can you prove which authorized records are settlement-available?
- Do you ever pay before acquiring confirmation?
- Are all money calculations fixed-point or decimal-safe?
- Can you reproduce fee/VAT calculations?
- Can you explain every rounding difference?
- Is financial ledger append-only?
- Are UPDATE/DELETE blocked?
- Can you detect missing ledger rows?
- Can you verify ledger hash continuity?
- Can you preserve original records after correction?

The platform must answer with evidence, not claims.

---

## 30. Patent Candidate Boundary

These controls strengthen the patent candidate.

Potential patent-relevant extensions:

- restaurant fintech acquiring-state machine linked to settlement availability filtering
- provider acquiring log reconciliation before tenant settlement
- fixed-point fee/VAT settlement arithmetic for multi-store order/payment SaaS
- calculation snapshot and rounding evidence packet for restaurant fintech reports
- log-structured append-only ledger with running balance and hash continuity
- acquiring transitions recorded as append-only ledger events
- financial kernel map combining device, application, DB, batch, compliance, and immutable ledger controls

Patent attorney review is required.

This document is architecture planning only.

---

## 31. Relationship To Previous Financial Kernel Documents

This document extends:

- `10609C Double-Entry Ledger Money Flow AML FDS Freezing And Merkle Integrity Kernel Policy`

It also reinforces:

- `10609 Financial Regulation Escrow FDS And Settlement Lag Risk Boundary Policy`
- `10609A Partial Refund Sequence Business Date Triple-Axis And WORM Ledger Audit Boundary Policy`
- `10609B Commercial Platform Benchmark Order Payment Hardware Financial Tax And Compliance Verification Boundary Policy`

Together, `10609` through `10609D` define the pre-`10610` financial-regulatory and fintech-kernel layer.

---

## 32. Relationship To Cross-Room Plumbing

Future event routing must carry:

- authorization state
- acquiring state
- acquiring batch id
- settlement availability marker
- fixed-point scale
- rate scale
- rounding policy id
- calculation snapshot id
- ledger sequence number
- previous ledger hash
- current ledger hash
- resulting balance
- continuity verification status
- mutation guard event id
- acquiring evidence packet id
- arithmetic evidence packet id
- ledger continuity evidence packet id

These become context envelope and evidence packet candidates.

---

## 33. Relationship To Financial Trust

Financial Trust must enforce:

- authorization/acquiring separation
- acquiring confirmation before settlement availability
- held/rejected acquiring state handling
- fixed-point money arithmetic
- explicit rounding policy
- reproducible fee/VAT calculation
- append-only ledger
- ledger continuity verification
- mutation guard
- amendment-only correction

Financial Trust must not trust gross authorization totals as settlement-available money.

---

## 34. Relationship To Data Governance

Data Governance must control:

- owner-facing acquiring status
- settlement availability projection
- pending/held/rejected acquiring messages
- calculation evidence visibility
- rounding explanation
- ledger continuity reports
- audit/export permissions
- masking of provider/card identifiers
- i18n messages
- CS explanations
- retention of calculation and ledger evidence

Financial kernel visibility must be safe and precise.

---

## 35. Relationship To Security Agent

Security Agent may detect:

- repeated acquiring rejection
- acquiring state mismatch
- unauthorized mutation attempt
- floating-point calculation anomaly
- rounding anomaly spike
- ledger gap
- hash continuity break
- direct UPDATE/DELETE attempt
- suspicious amendment pattern
- provider acquiring file anomaly

Security Agent may alert or contain.

It must not finalize financial truth.

---

## 36. Anti-Patterns

Avoid:

- treating authorization approval as settlement-available cash
- paying tenant before acquiring status is known without approved advance policy
- ignoring acquiring hold/rejection
- using JavaScript floating-point for money calculations
- hiding rounding differences
- recalculating historical VAT from current menu policy
- allowing UPDATE/DELETE on posted ledger
- fixing ledger error by editing old row
- running balance without hash continuity
- hash chain stored without verification
- ledger gap ignored because totals appear close
- compliance report based only on gross approval amount
- due diligence response without acquiring/arithmetic/continuity evidence

These anti-patterns must be blocked in future runtime design.

---

## 37. Runtime Deferral

This document defines acquiring state, fixed-point arithmetic, append-only ledger continuity, and financial kernel mapping boundaries only.

It does not authorize:

- acquiring integration
- acquiring state machine implementation
- card/provider acquiring file ingestion
- fixed-point arithmetic library implementation
- fee/VAT engine
- rounding policy engine
- append-only ledger table creation
- hash-chain ledger implementation
- DB mutation guard implementation
- continuity verification batch
- evidence packet generation
- database schema
- RLS policy
- production deployment

All runtime remains deferred.

---

## 38. Validation Checklist

Validation must confirm:

1. Financial kernel extension catalog is defined.
2. Card authorization versus acquiring boundary is defined.
3. Acquiring state machine boundary is defined.
4. Acquiring log matching boundary is defined.
5. Acquiring hold/rejection boundary is defined.
6. Settlement available fund boundary is defined.
7. Advance payout risk boundary is defined.
8. Fixed-point arithmetic boundary is defined.
9. Integer money unit boundary is defined.
10. Rate calculation boundary is defined.
11. Rounding difference boundary is defined.
12. VAT/fee snapshot boundary is defined.
13. Calculation audit boundary is defined.
14. Append-only ledger boundary is defined.
15. Log-structured ledger boundary is defined.
16. Running balance hash boundary is defined.
17. Ledger continuity verification boundary is defined.
18. Ledger gap boundary is defined.
19. Append-only amendment boundary is defined.
20. Database-level mutation guard boundary is defined.
21. Acquiring/append-only ledger relationship is defined.
22. Fixed-point/append-only relationship is defined.
23. Master verification layer map is defined.
24. Acquiring evidence packet is defined.
25. Arithmetic evidence packet is defined.
26. Ledger continuity evidence packet is defined.
27. Tech due diligence boundary is defined.
28. Patent candidate boundary is defined.
29. Relationships to previous financial kernel docs, Cross-Room Plumbing, Financial Trust, Data Governance, and Security Agent are defined.
30. Anti-patterns are listed.
31. Coding remains unauthorized.
32. Runtime remains deferred.

---

## 39. Relationship To Previous Documents

This document supplements:

- `10609C Double-Entry Ledger Money Flow AML FDS Freezing And Merkle Integrity Kernel Policy`

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
- `10609A Partial Refund Sequence Business Date Triple-Axis And WORM Ledger Audit Boundary Policy`
- `10609B Commercial Platform Benchmark Order Payment Hardware Financial Tax And Compliance Verification Boundary Policy`
- `10609C Double-Entry Ledger Money Flow AML FDS Freezing And Merkle Integrity Kernel Policy`

It prepares:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- future acquiring state machine specification
- future settlement availability filter packet
- future fixed-point arithmetic and rounding policy packet
- future append-only ledger continuity specification
- future database mutation guard authorization packet
- future financial kernel due diligence evidence packet

This document is architecture boundary planning only.

It does not authorize coding.

---

## 40. Final Rule

Catch Menu must not treat authorization, acquiring, settlement, arithmetic, and ledger continuity as the same concern.

Authorization approved is not acquiring confirmed.

Acquiring confirmed is not payout completed.

Settlement available funds must be filtered by acquiring state, provider evidence, refund/cancel state, DLQ state, hold/reserve state, and audit readiness.

All money arithmetic must use fixed-point integer or approved decimal-safe methods.

Floating-point financial truth is prohibited.

Every rounding difference must be policy-based, reproducible, and auditable.

Financial ledger records must be append-only.

Correction must be reversal or amendment.

Ledger continuity must be verifiable through sequence, running balance, previous hash, current hash, WORM/archive reference, and periodic continuity verification.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
