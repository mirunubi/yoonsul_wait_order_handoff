# 010601_Policy_Financial_Grade_Ledger_Reconciliation_And_Four_Source_Closing_Audit.md

## Purpose

This document defines the Financial-Grade Ledger Reconciliation and Four-Source Closing Audit Policy.

The previous artifact `10600` began the Cross-Room Plumbing, Wiring, and Insulation Planning Index.

This document supplements the Cross-Room Plumbing axis by adding a financial-institution-grade ledger reconciliation principle for Catch Menu, Mini Kiosk, POS handoff, payment provider integration, store terminal records, OS/runtime logs, DB trigger audit, view-based reconciliation, and nightly closing batch audit.

The purpose is to ensure that the system does not treat payment success, POS acceptance, provider callback, terminal log, or internal DB state as complete financial truth until the ledger is reconciled through multiple independent sources.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Catch Menu must be treated as a financial-grade order/payment platform.

The correct rule is:

Payment confirmed is not settlement completed.  
Provider approval is not internal ledger truth by itself.  
Internal DB state is not external provider truth by itself.  
Store terminal OS log is not financial truth by itself.  
POS record is not payment truth by itself.  
View summary is not source ledger by itself.  
Nightly batch is not silent correction.  
Reconciliation mismatch is not resolved.  
Correction is append-only amendment.  

The system must reconcile internal ledger, external PG/VAN/provider ledger, store terminal/POS ledger, and OS/runtime/audit evidence before final settlement confidence.

---

## 3. Four-Source Ledger Reconciliation Model

The financial closing model uses four major evidence sources.

| Source | Role |
|---|---|
| `INTERNAL_CATCH_MENU_LEDGER` | Internal payment/order/value/settlement records captured by DB triggers and source tables |
| `EXTERNAL_PROVIDER_LEDGER` | PG/VAN/payment provider approval, cancellation, refund, and settlement records |
| `STORE_TERMINAL_POS_LEDGER` | Store POS, kiosk, device, terminal, and local DB records |
| `OS_RUNTIME_AUDIT_LOG` | OS, runtime, device, process, network, app lifecycle, and security logs |

The nightly batch reconciles all four sources.

No single source may finalize financial truth alone.

---

## 4. Reconciliation Triangle Plus Audit Mesh

The financial reconciliation structure is:

    Internal Catch Menu Ledger
        <-> External PG/VAN/Provider Ledger
        <-> Store Terminal/POS Ledger
        <-> OS/Runtime Audit Log
        <-> Nightly Batch Reconciliation

This creates:

- internal ledger validation
- external provider validation
- store terminal validation
- runtime/device validation
- audit-layer validation
- nightly batch validation
- mismatch case creation
- append-only amendment route

This is stronger than single-provider matching.

---

## 5. Ledger Source 1: Internal Catch Menu Ledger

The internal ledger may include:

- payment intent
- authorization request
- payment confirmation candidate
- provider callback intake
- order reference
- POS handoff reference
- KDS reference if relevant
- refund/cancellation/void
- coupon/point/wallet/stored value movement
- compensation value action
- settlement candidate
- reconciliation case
- amendment
- audit trigger event
- safe projection state

Internal ledger must be append-only where financial truth is involved.

Internal ledger must be tenant/store/legal scoped.

---

## 6. Ledger Source 2: External PG VAN Provider Ledger

External provider ledger may include:

- authorization approval
- authorization failure
- capture record
- cancellation record
- refund record
- settlement report
- provider transaction id
- approval number
- merchant id
- store mapping
- amount
- currency
- timestamp
- fee/commission if available
- provider status
- provider batch date
- provider adjustment

Provider ledger is external evidence.

Provider ledger is not internal truth until matched.

---

## 7. Ledger Source 3: Store Terminal POS Ledger

Store terminal/POS ledger may include:

- kiosk payment attempt
- POS accepted order
- local approval marker
- terminal approval number
- local DB payment record
- offline/local order capture
- NFC tag event
- staff-assisted terminal event
- device sync marker
- local fallback marker
- receipt print marker
- terminal closing summary
- POS daily total
- store device identity

Store terminal/POS ledger is store-side evidence.

It may reveal missing central records.

It must not automatically overwrite central truth.

---

## 8. Ledger Source 4: OS Runtime Audit Log

OS/runtime audit log may include:

- app start/stop
- kiosk crash
- local process restart
- device reboot
- network disconnect
- network reconnect
- local agent sync attempt
- provider callback receipt
- API timeout
- payment screen transition
- receipt print process
- device storage write
- firewall/WAF block
- security containment
- file/log tamper signal
- batch job start/end
- service health event

OS/runtime log is independent evidence.

OS/runtime log helps distinguish technical failure from financial mismatch.

---

## 9. Nightly Closing Batch Role

The nightly closing batch performs financial-grade reconciliation.

It may check:

- internal ledger vs provider ledger
- internal ledger vs store terminal/POS ledger
- provider ledger vs store terminal/POS ledger
- OS/runtime log vs internal ledger
- OS/runtime log vs provider callback timeline
- DB trigger audit completeness
- view summary consistency
- duplicate payment/refund/value risk
- timeout/unknown payment cases
- missing provider callback cases
- local offline records not synced
- settlement candidate correctness
- unresolved review carry-forward

Nightly batch must not silently correct records.

It creates reconciliation cases or amendment candidates.

---

## 10. Daily Closing Reconciliation Stages

Recommended closing stages:

| Stage | Name | Purpose |
|---|---|---|
| `R1_INTERNAL_LEDGER_CLOSE` | Internal ledger close | Freeze internal day candidate |
| `R2_PROVIDER_LEDGER_IMPORT` | Provider import | Import PG/VAN/provider daily records |
| `R3_INTERNAL_PROVIDER_MATCH` | Internal-provider match | Match transaction IDs, amounts, timestamps |
| `R4_STORE_TERMINAL_MATCH` | Store terminal match | Compare POS/kiosk/local records |
| `R5_OS_RUNTIME_CORRELATION` | OS/runtime correlation | Correlate crash, timeout, network, sync logs |
| `R6_EXCEPTION_CASE_CREATION` | Exception case creation | Create mismatch/review cases |
| `R7_SETTLEMENT_CANDIDATE_BUILD` | Settlement candidate build | Build settlement after verified matches |
| `R8_AMENDMENT_QUEUE_BUILD` | Amendment queue build | Queue corrections requiring review |
| `R9_AUDIT_PACKET_CLOSE` | Audit packet close | Create daily closing evidence packet |
| `R10_NEXT_DAY_WARNING_EXPORT` | Warning handoff | Prepare next-day finance/security/admin warnings |

Each stage must be audited.

---

## 11. Transaction Matching Key Boundary

Transaction matching may use multiple keys.

Recommended matching keys:

- tenant id
- store id
- legal entity id
- provider id
- merchant id
- terminal id
- device id
- payment intent id
- internal transaction id
- provider transaction id
- approval number
- POS order id
- local terminal record id
- order reference
- amount
- currency
- timestamp window
- idempotency key
- customer/session reference if allowed
- batch date
- settlement date

One weak key is insufficient.

Transaction ID alone may be insufficient if scope is ambiguous.

---

## 12. Amount Matching Boundary

Amount matching must compare:

- internal expected amount
- internal captured amount
- provider approved amount
- provider captured amount
- provider canceled amount
- provider refunded amount
- POS terminal amount
- local device amount
- coupon/point/wallet applied amount
- final settlement amount
- fee/commission if applicable

Amount mismatch must create reconciliation case.

Amount mismatch must not be silently rounded away unless approved policy permits and records it.

---

## 13. Time Window Matching Boundary

Time matching must handle:

- provider callback delay
- terminal offline delay
- network reconnect delay
- timezone/day boundary
- store closing after midnight
- batch date vs transaction date
- provider settlement date
- refund after original sale day
- cancellation after close
- manual fallback after timeout

Exact timestamp match is not always required.

But time window policy must be explicit.

---

## 14. Unknown Payment State Boundary

Unknown payment state is a high-risk reconciliation target.

Unknown state may occur when:

- customer payment screen timed out
- provider callback delayed
- provider callback missing
- terminal approved but server missing
- server approved but provider missing
- POS printed receipt but payment record missing
- OS log shows crash during payment
- network disconnected during authorization
- duplicate retry occurred

Unknown is not success.

Unknown is not failure.

Unknown requires reconciliation.

---

## 15. Missing Provider Record Boundary

Case:

Internal ledger says payment succeeded, but provider ledger has no matching record.

Required handling:

- create reconciliation case
- mark provider missing
- block settlement finalization for the record
- inspect provider callback logs
- inspect OS/runtime logs
- inspect store terminal/POS logs
- preserve internal evidence
- require finance/security review if unresolved

Internal success alone is insufficient.

---

## 16. Missing Internal Record Boundary

Case:

Provider ledger or terminal/POS ledger shows approval, but internal ledger has no matching record.

Required handling:

- create reconciliation case
- inspect OS/runtime logs
- inspect provider callback history
- inspect terminal local DB
- inspect network disconnect logs
- create missing-ledger review candidate
- prevent silent insertion without review
- route amendment if verified

Provider success can reveal missing internal record.

But correction must be append-only and reviewed.

---

## 17. Store Terminal Mismatch Boundary

Case:

Store terminal/POS record differs from internal or provider record.

Possible causes:

- local offline approval
- receipt print without server sync
- app crash after approval
- duplicate terminal attempt
- manual fallback record
- terminal clock drift
- device identity mismatch
- POS mapping error
- staff-assisted payment outside normal flow

Terminal mismatch must create review.

Terminal record is evidence, not automatic truth.

---

## 18. OS Log Mismatch Boundary

Case:

OS/runtime log shows crash, reconnect, process kill, local sync error, or network anomaly around a payment/refund event.

Required handling:

- attach OS log to evidence packet
- mark technical uncertainty
- compare internal/provider/terminal records
- prevent automatic false success/failure
- route to reconciliation
- preserve device log
- mark affected store/device scope

OS log explains failure context.

OS log does not finalize financial state.

---

## 19. Duplicate Payment Boundary

Duplicate payment risk may occur when:

- customer double taps
- kiosk retries
- provider callback delayed
- terminal offline retry
- staff retries manually
- network timeout causes repeated authorization
- internal/provider state diverges
- local DB sync repeats

Duplicate risk requires:

- idempotency review
- provider ledger match
- terminal ledger match
- internal ledger match
- customer impact review
- refund candidate if duplicate captured
- compensation review if customer impacted

Duplicate payment is critical.

It must not be handled by silent deletion.

---

## 20. Refund And Cancellation Reconciliation Boundary

Refund/cancellation reconciliation must match:

- original payment
- refund request
- refund approval
- provider refund record
- terminal/POS refund record if applicable
- internal refund ledger
- OS/runtime logs
- settlement adjustment
- customer-safe projection

Refund requested is not refund completed.

Provider refund callback is not verified truth by itself.

Refund mismatch must create reconciliation case.

---

## 21. Coupon Point Wallet Reconciliation Boundary

Value ledger reconciliation must match:

- coupon issue
- coupon reservation
- coupon redemption
- coupon release
- point accrual
- point redemption
- wallet credit
- wallet debit
- stored value movement
- payment/refund relation
- settlement impact
- customer projection

Value movement must be ledger-bound.

Wallet display is not ledger truth unless reconciled.

---

## 22. Settlement Finalization Boundary

Settlement finalization may occur only after:

- payment records reconciled
- refund records reconciled
- value ledger impact reconciled
- provider fee records matched
- store/POS totals compared
- legal entity scope verified
- unresolved exceptions excluded or marked
- audit packet complete
- authority approval if required

Settlement calculated is not settlement paid.

Settlement candidate is not final settlement.

---

## 23. Reconciliation Exception Catalog

Recommended exception catalog:

| Exception | Meaning |
|---|---|
| `INTERNAL_SUCCESS_PROVIDER_MISSING` | Internal success but provider missing |
| `PROVIDER_SUCCESS_INTERNAL_MISSING` | Provider success but internal missing |
| `TERMINAL_SUCCESS_SERVER_MISSING` | Terminal success but server missing |
| `SERVER_SUCCESS_TERMINAL_MISSING` | Server success but terminal missing |
| `AMOUNT_MISMATCH` | Amount differs |
| `CURRENCY_MISMATCH` | Currency differs |
| `TIMESTAMP_WINDOW_MISMATCH` | Time window mismatch |
| `DUPLICATE_PAYMENT_RISK` | Possible duplicate capture |
| `REFUND_PROVIDER_MISSING` | Refund missing at provider |
| `VALUE_LEDGER_MISMATCH` | Coupon/point/wallet mismatch |
| `SETTLEMENT_FEE_MISMATCH` | Fee mismatch |
| `LEGAL_ENTITY_SCOPE_MISMATCH` | Legal entity mismatch |
| `TENANT_STORE_SCOPE_MISMATCH` | Tenant/store mismatch |
| `OS_RUNTIME_UNCERTAINTY` | OS/runtime anomaly affects confidence |
| `AUDIT_LAYER_MISSING` | Required audit layer missing |

Exceptions are review cases.

They are not automatic corrections.

---

## 24. Amendment Boundary

Verified corrections must be append-only.

Amendment must record:

- original record
- exception type
- evidence sources
- reviewer
- approver
- correction reason
- before state
- after state
- effective date
- settlement impact
- customer impact if any
- audit reference

Correction is not overwrite.

Amendment preserves original and corrected truth.

---

## 25. Daily Closing Evidence Packet

Daily closing evidence packet should include:

- tenant id
- store id
- legal entity id
- business date
- internal ledger total
- provider ledger total
- terminal/POS total
- OS/runtime anomaly count
- payment match count
- refund match count
- value ledger match count
- settlement candidate total
- mismatch count
- unresolved exception count
- amendment candidate count
- export/report reference
- batch job audit reference

Evidence packet supports settlement review.

It is not settlement approval by itself.

---

## 26. Owner And Franchise Projection Boundary

Owner/franchise-facing projection may show:

- daily sales candidate
- verified payment total
- refund total
- unresolved exception count
- settlement candidate amount
- reconciliation status
- payout not yet final marker
- warning if records are under review

Projection must not show:

- raw provider payload
- internal security log
- unrelated store data
- cross-tenant data
- unverified final payout claim
- hidden unresolved mismatch

Owner view is not settlement authority unless separately governed.

---

## 27. Security And Tamper Detection Boundary

Four-source reconciliation helps detect tampering.

Tamper indicators may include:

- DB update without trigger audit
- provider approval missing but internal success exists
- terminal log exists but DB missing
- OS log shows process kill during payment
- view summary differs from source table
- export generated without approval
- settlement amendment without evidence
- tenant/store mismatch in payment record

Tamper signal is not final breach proof.

It requires security review.

---

## 28. Financial-Grade Trust Statement Boundary

The system may later support a business statement such as:

- financial-grade reconciliation
- multi-source payment verification
- store terminal and provider matching
- nightly closing audit
- append-only amendment trace
- tenant-isolated settlement evidence

However, marketing claims must be carefully reviewed.

The system must not claim:

- zero error guaranteed
- hacking impossible
- all attacks prevented
- automatic correction without human review
- provider truth always available
- settlement always immediate

Correct claim direction:

The system is designed to detect, isolate, reconcile, and review discrepancies through multi-source evidence and audit.

---

## 29. Relationship To Four-Layer Audit Mesh

This document extends `10554`.

Four-layer audit mesh captures:

- DB trigger audit
- view/projection audit
- OS/runtime log
- nightly batch audit

This document adds financial-grade ledger reconciliation across:

- internal Catch Menu ledger
- external PG/VAN/provider ledger
- store terminal/POS ledger
- OS/runtime evidence

Together they create a financial reconciliation mesh.

---

## 30. Relationship To Cross-Room Plumbing

This document prepares `10610`.

Event and evidence flows must carry:

- internal ledger references
- provider ledger references
- terminal/POS references
- OS log references
- audit references
- reconciliation exception references
- amendment references
- settlement candidate references

Cross-room event routing must preserve reconciliation identity.

---

## 31. Relationship To Financial Trust

Financial Trust remains owner of financial truth.

This document strengthens Financial Trust by requiring:

- provider reconciliation
- terminal/POS reconciliation
- OS/runtime correlation
- nightly closing batch
- exception handling
- append-only amendment
- settlement readiness checks

Financial Trust must not finalize settlement from a single source.

---

## 32. Relationship To Store Runtime

Store Runtime provides:

- order reference
- POS handoff reference
- KDS reference if relevant
- manual fallback evidence
- device local evidence
- store terminal evidence
- staff-assisted flow evidence

Store Runtime is not financial truth.

It provides operational evidence for financial reconciliation.

---

## 33. Relationship To Data Governance

Data Governance provides:

- Safe Projection
- masking
- i18n messages
- export control
- retention
- compliance hold
- analytics
- AI advisory review
- pgvector source governance

Reconciliation results must be projected safely.

Financial details must remain scoped and masked.

---

## 34. Anti-Patterns

Avoid:

- internal DB success treated as final payment truth
- provider success treated as internal ledger truth without matching
- terminal approval treated as automatic central truth
- OS log treated as payment confirmation
- view total treated as source ledger
- nightly batch silently correcting records
- mismatch ignored because totals roughly match
- amount mismatch rounded away without policy
- duplicate payment hidden by deleting one record
- refund timeout treated as completed
- wallet display treated as ledger truth
- settlement finalized before reconciliation
- owner dashboard showing final payout while exception remains
- provider missing record ignored
- missing DB trigger audit ignored
- amendment overwriting original record
- cross-tenant records included in daily batch

These anti-patterns must be blocked in future runtime design.

---

## 35. Runtime Deferral

This document defines financial-grade ledger reconciliation architecture only.

It does not authorize:

- DB trigger creation
- reconciliation tables
- provider API integration
- POS terminal integration
- OS log ingestion
- nightly batch implementation
- settlement engine
- amendment workflow
- owner dashboard
- export/report generation
- database schema
- RLS policy
- production deployment

All runtime remains deferred.

---

## 36. Validation Checklist

Validation must confirm:

1. Financial-grade reconciliation principle is defined.
2. Four-source ledger model is defined.
3. Internal ledger source is defined.
4. External provider ledger source is defined.
5. Store terminal/POS ledger source is defined.
6. OS/runtime audit log source is defined.
7. Nightly closing batch role is defined.
8. Daily closing reconciliation stages are defined.
9. Transaction matching key boundary is defined.
10. Amount matching boundary is defined.
11. Time window matching boundary is defined.
12. Unknown payment state boundary is defined.
13. Missing provider record boundary is defined.
14. Missing internal record boundary is defined.
15. Store terminal mismatch boundary is defined.
16. OS log mismatch boundary is defined.
17. Duplicate payment boundary is defined.
18. Refund/cancellation reconciliation boundary is defined.
19. Coupon/point/wallet reconciliation boundary is defined.
20. Settlement finalization boundary is defined.
21. Reconciliation exception catalog is defined.
22. Amendment boundary is defined.
23. Daily closing evidence packet is defined.
24. Owner/franchise projection boundary is defined.
25. Security/tamper detection boundary is defined.
26. Financial-grade trust statement boundary is defined.
27. Relationships to audit mesh, Cross-Room Plumbing, Financial Trust, Store Runtime, and Data Governance are defined.
28. Anti-patterns are listed.
29. Coding remains unauthorized.
30. Runtime remains deferred.

---

## 37. Relationship To Previous Documents

This document supplements:

- `10554 Four-Layer Audit Capture Trigger View OS Log And Nightly Batch Reconciliation Policy`
- `10600 Cross-Room Plumbing Wiring Insulation Planning Index`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10350 Store Runtime Room Framing Closure And Next Axis Handoff Policy`
- `10400~10480 Financial Trust Room Framing Sequence`
- `10530 Safe Projection Masking And Audience Visibility Boundary Policy`
- `10554 Four-Layer Audit Capture Trigger View OS Log And Nightly Batch Reconciliation Policy`
- `10570 Retention Export And Compliance Data Boundary Policy`
- `10580 Data Governance Closure And Cross-Room Handoff Policy`
- `10600 Cross-Room Plumbing Wiring Insulation Planning Index`

It prepares:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- future reconciliation exception registry
- future financial closing batch specification
- future settlement readiness checklist
- future ledger amendment authorization packet

This document is architecture boundary planning only.

It does not authorize coding.

---

## 38. Final Rule

Catch Menu must reconcile financial truth like a financial-grade system.

Internal DB ledger, external PG/VAN/provider ledger, store terminal/POS ledger, and OS/runtime audit logs must be cross-checked by nightly closing batch.

No single source finalizes payment, refund, value movement, settlement, or payout truth.

Unknown state is not success.

Unknown state is not failure.

Mismatch is not correction.

Nightly batch is not silent mutation.

Correction is append-only amendment.

Settlement must not finalize while unresolved reconciliation exceptions remain.

The reconciliation system must preserve tenant/store/legal/customer scope, transaction identity, amount matching, time-window matching, duplicate detection, provider verification, terminal/POS evidence, OS/runtime evidence, DB trigger audit, view/projection audit, nightly batch audit, evidence packets, safe owner/franchise projection, security tamper detection, retention, export control, and runtime deferral.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
