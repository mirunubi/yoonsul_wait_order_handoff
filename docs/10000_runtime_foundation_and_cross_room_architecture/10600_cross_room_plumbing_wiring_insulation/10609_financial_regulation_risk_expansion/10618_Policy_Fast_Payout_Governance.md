# 10618_Policy_Fast_Payout_Governance

## 1. Purpose

This document defines the Fast Payout, Virtual Business Close, Offsetting, Auto-Billing, and Operational Asset Optimization Governance Policy.

The previous artifact `10609G` defined external financial network circuit breaker, Saga fallback, KYC, and account ownership verification boundaries.

This document adds the operational governance and asset optimization layer for:

1. Fast payout / early settlement candidate governance.
2. Virtual business close and time-gap reconciliation.
3. Platform fee offsetting and auto-billing / tax evidence governance.
4. Merchant liquidity optimization and SaaS lock-in through governed financial services.

The purpose is to ensure that Catch Menu can support merchant cash-flow benefits and operational convenience without weakening ledger integrity, regulatory boundaries, tax evidence, payout safety, or owner trust.

This document is planning-only.

It does not authorize coding.

It is not legal, tax, accounting, credit, lending, factoring, electronic financial transaction, banking, PG/VAN, card-network, or regulatory advice.

Any fast payout, factoring, advance settlement, offsetting, tax invoice, auto-billing, or financial product must be reviewed by qualified legal, accounting, tax, finance, credit-risk, banking, PG/VAN, and compliance experts before implementation.

---

## 2. Core Position

Operational asset optimization must not bypass financial governance.

The correct rule is:

Fast payout is not ordinary settlement.  
Early payment creates credit risk.  
Factoring is not a simple UI feature.  
Acquiring confirmed is not always cash received.  
Risk score is not legal credit approval by itself.  
Virtual close is not physical POS close.  
Missing close log is not automatic fraud.  
Offsetting is not invisible deduction.  
Platform fee is not tenant settlement money.  
Auto-billing is not tax compliance by itself.  
Tax evidence must be legally reviewed.  
Merchant benefit must not compromise ledger truth.  

The platform may optimize liquidity and operations only through governed, auditable, legally reviewed, and evidence-linked processes.

---

## 3. Operational Asset Optimization Catalog

The following governance families are added:

| Governance Family | Purpose |
|---|---|
| `FAST_PAYOUT_ENGINE` | Provide earlier merchant liquidity under controlled risk |
| `CREDIT_RISK_SCORING` | Assess merchant eligibility and exposure |
| `ADVANCE_SETTLEMENT_LIMIT` | Cap early payout exposure |
| `RECEIVABLE_FACTORIZATION_BOUNDARY` | Govern whether receivables may be assigned/advanced |
| `VIRTUAL_BUSINESS_CLOSE` | Create provisional close when store fails to close properly |
| `TIME_GAP_RECONCILIATION` | Reconcile virtual close with later physical close evidence |
| `OFFSETTING_ENGINE` | Deduct platform fees or approved charges from settlement |
| `AUTO_BILLING_EVIDENCE` | Produce invoice/tax evidence for platform-to-tenant charges |
| `TAX_AND_ACCOUNTING_REVIEW_GATE` | Prevent unreviewed tax automation |
| `MERCHANT_LOCK_IN_ETHICS` | Ensure lock-in is built on value, not opaque financial dependency |

These are governance boundaries, not implementation authorization.

---

## 4. Fast Payout Boundary

Fast payout means paying the merchant before normal external cash settlement would otherwise complete.

Fast payout may be based on:

- acquiring accepted
- provider clearing matched
- refund/cancel state checked
- chargeback risk assessed
- FDS/AML risk checked
- merchant history reviewed
- account ownership verified
- settlement route verified
- platform or financial partner funding approved
- contract terms accepted

Fast payout is not the same as standard settlement.

It creates liquidity benefit and financial exposure.

---

## 5. Fast Payout Eligibility Boundary

Fast payout eligibility must be controlled.

Eligibility inputs may include:

- tenant identity verification
- store operating history
- provider acquiring state
- settlement available amount
- refund ratio
- partial refund ratio
- chargeback/dispute ratio
- FDS signal history
- AML/suspicious signal history
- DLQ history
- manual adjustment history
- payout account stability
- sales volatility
- business date consistency
- network/device reliability
- KYC/account ownership status
- contract/package entitlement

Eligibility must be evidence-based.

Eligibility is not permanent.

---

## 6. Credit Risk Scoring Boundary

Credit risk scoring may support fast payout.

Risk score may consider:

- average daily sales
- sales volatility
- refund/cancel rate
- chargeback rate
- dispute loss rate
- acquiring rejection rate
- settlement lag history
- DLQ frequency
- manual adjustment frequency
- suspicious transaction history
- account change frequency
- device/network anomaly history
- merchant tenure
- provider reliability
- sector/menu risk class if legally appropriate

AI may assist scoring.

Final eligibility, limit, and financial product decision must follow approved policy and legal/compliance review.

---

## 7. Advance Settlement Limit Boundary

Fast payout must have limits.

Limit controls may include:

- per-tenant daily limit
- per-store daily limit
- rolling weekly limit
- rolling monthly exposure limit
- percentage of settlement available fund
- reserve percentage
- risk-tier cap
- chargeback reserve
- refund reserve
- provider-specific cap
- legal entity cap
- suspension threshold

Limit exceeded means payout remains standard settlement or review required.

Limit must not be bypassed manually without governance.

---

## 8. Receivable Factoring Boundary

If fast payout resembles receivable factoring, loan, advance, or credit product, it must be reviewed separately.

Possible models:

| Model | Description | Risk |
|---|---|---|
| Internal early settlement | Platform pays before external cash arrival | Platform credit/liquidity risk |
| Partner-funded advance | Financial partner funds merchant early | Partner contract/regulatory risk |
| Receivable assignment | Merchant receivable assigned to financer | Legal/accounting/regulatory complexity |
| Fee-based fast payout | Merchant pays fee for faster payout | Tax/legal/consumer fairness review |
| Standard settlement only | No advance; lower risk | Less liquidity benefit |

This document does not approve any model.

Model selection requires legal, accounting, tax, and financial partner review.

---

## 9. Fast Payout State Skeleton

Recommended states:

| State | Meaning |
|---|---|
| `FAST_PAYOUT_NOT_ELIGIBLE` | Merchant or transaction not eligible |
| `FAST_PAYOUT_ELIGIBILITY_CHECKING` | Eligibility being checked |
| `FAST_PAYOUT_ELIGIBLE` | Eligible under policy |
| `FAST_PAYOUT_LIMIT_CALCULATED` | Limit calculated |
| `FAST_PAYOUT_REQUESTED` | Merchant/platform requested fast payout |
| `FAST_PAYOUT_APPROVED` | Approved under policy |
| `FAST_PAYOUT_SENT` | Payout instruction sent |
| `FAST_PAYOUT_UNKNOWN` | Payout result unknown |
| `FAST_PAYOUT_COMPLETED` | Payout completed |
| `FAST_PAYOUT_RECONCILIATION_REQUIRED` | Reconciliation required |
| `FAST_PAYOUT_HELD` | Held due to risk |
| `FAST_PAYOUT_REVERSED_OR_RECOVERED` | Recovery/reversal event recorded |
| `FAST_PAYOUT_DLQ_REQUIRED` | DLQ isolation required |

Fast payout must have its own lifecycle.

It must not be hidden inside ordinary settlement.

---

## 10. Fast Payout Evidence Packet

Fast payout evidence packet may include:

- settlement available amount
- acquiring confirmation references
- provider clearing references
- refund/cancel state
- chargeback/dispute state
- risk score inputs
- merchant eligibility result
- limit calculation
- funding source
- approval reference
- payout transfer UUID
- account ownership verification
- fee/charge policy if any
- contract acceptance reference
- audit reference
- WORM/hash reference if required

Fast payout evidence is required for financial due diligence.

---

## 11. Fast Payout Hold And Recovery Boundary

If later provider cash, refund, dispute, or chargeback contradicts fast payout assumptions, the system must support:

- hold future payout
- create receivable recovery
- apply reserve if contractually allowed
- create adjustment journal
- notify merchant safely
- route to finance review
- route to legal/compliance if needed
- update risk score
- suspend eligibility
- create evidence packet

Recovery must be legal, contractual, and auditable.

Recovery must not be silent deduction without evidence and policy.

---

## 12. Virtual Business Close Boundary

Virtual business close is a provisional close generated when store close evidence is missing.

Virtual close may be triggered when:

- scheduled close time passes
- no formal POS close log received
- last payment occurred sufficiently before close window
- device/ping status indicates offline or closed
- no active order/payment state remains
- store policy allows virtual close
- provider data supports provisional close
- staff close reminder failed or timed out

Virtual close is provisional unless later reconciled.

It is not physical POS close.

---

## 13. Virtual Close State Skeleton

Recommended states:

| State | Meaning |
|---|---|
| `PHYSICAL_CLOSE_RECEIVED` | Store close evidence received |
| `PHYSICAL_CLOSE_MISSING` | Expected close log missing |
| `VIRTUAL_CLOSE_CANDIDATE` | Candidate for virtual close |
| `VIRTUAL_CLOSE_GENERATED` | Provisional close generated |
| `VIRTUAL_CLOSE_PENDING_STORE_CONFIRMATION` | Waiting for next-day store confirmation |
| `VIRTUAL_CLOSE_RECONCILED` | Later physical evidence matched |
| `VIRTUAL_CLOSE_CONFLICT` | Later evidence conflicts |
| `VIRTUAL_CLOSE_AMENDMENT_REQUIRED` | Amendment required |
| `VIRTUAL_CLOSE_REVIEW_REQUIRED` | Human review required |
| `VIRTUAL_CLOSE_DLQ_REQUIRED` | DLQ isolation required |

Virtual close must be transparent.

---

## 14. Virtual Close Evidence Boundary

Virtual close evidence may include:

- store close policy
- expected close time
- last transaction timestamp
- active order count
- active payment count
- device ping status
- POS status
- KDS/printer status
- staff action log
- offline sync status
- provider records through cutoff
- internal ledger snapshot
- generated close timestamp
- audit reference

Virtual close must be generated from evidence, not assumption.

---

## 15. Time-Gap Reconciliation Boundary

When physical close evidence later arrives, it must be reconciled with virtual close.

Reconciliation checks:

- physical close timestamp
- physical close totals
- internal virtual close totals
- POS/terminal close totals
- provider records
- offline backlog
- refunds/cancels after virtual close
- business date assignment
- settlement date impact
- amendments required
- owner projection impact

If mismatch exists, create amendment or DLQ.

Do not overwrite virtual close silently.

---

## 16. Human Error Grace Boundary

Store close failure may be human error.

System should distinguish:

- forgotten close
- power failure
- network outage
- device offline
- POS close delayed
- staff training issue
- malicious avoidance
- repeated pattern
- suspicious adjustment

First-time or explainable error may route to reminder/recovery.

Repeated or suspicious pattern may route to review.

---

## 17. Offsetting Boundary

Offsetting means deducting platform-authorized amounts from tenant settlement.

Offsettable items may include only legally and contractually approved items, such as:

- SaaS subscription fee
- platform transaction fee
- provider pass-through fee if contractually allowed
- franchise fee if applicable
- approved promotion cost share
- chargeback fee if applicable
- adjustment recovery if legally allowed
- fast payout fee if approved
- tax invoice amount if legally appropriate

Offsetting must be explicit, auditable, and contract-backed.

Offsetting must not hide tenant settlement truth.

---

## 18. Offsetting Formula Boundary

Owner-facing formula must be clear.

Example structure:

    Net payout = Gross confirmed settlement
                 - Refunds and cancellations
                 - Holds and reserves
                 - Approved platform fees
                 - Approved provider/pass-through fees
                 - Approved adjustments
                 + Approved corrections

Each component must have evidence.

No opaque deduction is allowed.

---

## 19. Offsetting State Skeleton

Recommended states:

| State | Meaning |
|---|---|
| `OFFSET_NOT_APPLICABLE` | No offset applies |
| `OFFSET_CANDIDATE` | Offset candidate created |
| `OFFSET_EVIDENCE_REQUIRED` | Evidence or contract required |
| `OFFSET_APPROVED` | Offset approved |
| `OFFSET_APPLIED` | Offset applied to settlement |
| `OFFSET_INVOICE_REQUIRED` | Billing/tax evidence required |
| `OFFSET_INVOICE_ISSUED` | Invoice/billing evidence issued |
| `OFFSET_DISPUTED` | Tenant disputes offset |
| `OFFSET_REVERSED` | Offset reversed through amendment |
| `OFFSET_RECONCILIATION_REQUIRED` | Reconciliation required |
| `OFFSET_DLQ_REQUIRED` | DLQ isolation required |

Offsetting must be state-controlled.

---

## 20. Auto-Billing And Tax Evidence Boundary

Platform fees and charges may require billing or tax evidence.

Auto-billing may include:

- invoice candidate
- tax invoice candidate
- receipt candidate
- billing statement
- offset statement
- settlement deduction statement
- platform revenue recognition reference
- tenant expense evidence reference

Exact document type and process must be reviewed by tax/accounting/legal experts.

This document does not authorize automatic tax invoice issuance.

---

## 21. Auto-Billing Evidence Packet

Auto-billing evidence packet may include:

- tenant id
- legal entity id
- billing period
- billing item
- contract reference
- fee policy
- calculation snapshot
- VAT/tax treatment if reviewed
- invoice candidate id
- issuance status
- delivery status
- offset reference
- settlement reference
- platform revenue journal reference
- tenant expense projection reference
- audit reference

Billing evidence must be consistent with settlement and accounting ledgers.

---

## 22. Reverse Issuance / Auto-Issuance Caution Boundary

Any reverse issuance, auto-issuance, or tax authority integration must be treated as high-risk.

Before implementation, confirm:

- legal authority
- tax authority interface availability
- tenant consent/contract
- issuer/recipient role
- document type
- cancellation/correction process
- timing
- VAT/tax treatment
- storage/retention
- dispute handling
- audit and export requirements

Tax automation must not be guessed.

It must be approved by experts.

---

## 23. Platform Revenue Recognition Boundary

Platform revenue must be separated from tenant settlement.

Platform revenue may arise from:

- SaaS subscription
- transaction fee
- support/service fee
- premium analytics fee
- fast payout fee if approved
- device rental/management fee
- franchise OS fee if applicable

Platform revenue recognition must not be mixed with tenant gross sales.

Revenue recognition must be accounting-reviewed.

---

## 24. Merchant Lock-In Ethics Boundary

Operational asset optimization can create strong lock-in.

Lock-in must be based on:

- faster liquidity
- transparent settlement
- reliable reporting
- reduced tax/admin burden
- strong fraud defense
- better CS evidence
- predictable payout
- clear fee structure

Lock-in must not be based on:

- opaque deductions
- inability to export data
- hidden settlement delay
- confusing tax documents
- punitive holds without evidence
- forced financial dependency
- misleading fast payout terms

Trust-based lock-in is durable.

Opaque lock-in creates legal and reputational risk.

---

## 25. Owner Dashboard Boundary

Owner dashboard must show:

- gross confirmed settlement
- standard payout date
- fast payout eligibility
- fast payout amount
- fast payout fee if any
- holds/reserves
- pending refunds
- pending disputes
- platform fee
- offset amount
- invoice/tax evidence status
- net payout
- virtual close status
- physical close status
- time-gap reconciliation status

Owner must understand why payout differs from gross sales.

---

## 26. Governance Risk Catalog

Operational asset optimization may create new risks:

| Risk | Meaning |
|---|---|
| `FAST_PAYOUT_CREDIT_LOSS` | Merchant receives funds before provider cash fails |
| `FAST_PAYOUT_ABUSE` | Merchant manipulates sales/refunds for early cash |
| `OFFSET_DISPUTE` | Tenant disputes deducted platform fee |
| `TAX_EVIDENCE_MISMATCH` | Billing/tax document mismatches settlement |
| `VIRTUAL_CLOSE_FALSE_POSITIVE` | Virtual close generated while store still operating |
| `VIRTUAL_CLOSE_MISSING_TRANSACTION` | Late/offline transaction excluded |
| `OWNER_DASHBOARD_MISLEADING` | Merchant cannot understand payout calculation |
| `LOCK_IN_REPUTATION_RISK` | Merchant feels trapped by opaque financial controls |

Each risk must have review, evidence, and reversal/amendment route.

---

## 27. Governance Evidence Packet

Governance evidence packet may include:

- fast payout eligibility evidence
- risk score reference
- fast payout limit calculation
- payout transfer UUID
- virtual close evidence
- time-gap reconciliation result
- offset calculation snapshot
- auto-billing evidence
- tax/accounting review reference
- owner dashboard projection reference
- dispute/review record
- amendment reference
- audit/WORM reference

Governance evidence supports trust and due diligence.

---

## 28. Relationship To Financial Kernel Documents

This document extends:

- `10609C Double-Entry Ledger Money Flow AML FDS Freezing And Merkle Integrity Kernel Policy`
- `10609D Acquiring State Fixed-Point Arithmetic Append-Only Ledger Continuity And Financial Kernel Map Policy`
- `10609E Chargeback Dispute Social Engineering Multi-Party Approval And Manual Adjustment Governance Policy`
- `10609F Fixed-Point Batch Snapshot Fan-Out And Hash-Chain Monitoring Action Policy`
- `10609G External Financial Network Circuit Breaker Saga Fallback KYC And Account Ownership Verification Policy`

It adds operational asset optimization and merchant benefit governance.

---

## 29. Relationship To Cross-Room Plumbing

Future event routing must carry:

- fast payout eligibility id
- risk score id
- fast payout limit id
- fast payout state
- virtual close id
- physical close id
- time-gap reconciliation id
- offset id
- auto-billing evidence id
- platform fee id
- invoice candidate id
- tax evidence state
- owner dashboard projection id
- governance evidence packet id
- amendment id
- hold/reserve id

These become context envelope and evidence packet candidates.

---

## 30. Relationship To Financial Trust

Financial Trust must enforce:

- fast payout eligibility
- advance exposure limit
- settlement available filtering
- risk-based hold
- virtual close provisional state
- time-gap reconciliation
- offset approval
- auto-billing evidence linkage
- platform revenue separation
- amendment-only correction

Financial Trust must not allow liquidity optimization to bypass ledger integrity.

---

## 31. Relationship To Data Governance

Data Governance must control:

- owner payout explanation
- fast payout eligibility message
- fee/offset visibility
- invoice/tax evidence status
- virtual close messages
- time-gap reconciliation messages
- CS explanation
- export of settlement/billing evidence
- masking of sensitive financial data
- i18n messages
- retention of governance evidence

Owner-facing financial explanations must be clear and non-misleading.

---

## 32. Relationship To Security Agent

Security Agent may detect:

- fast payout abuse
- refund spike after fast payout
- dispute spike after fast payout
- suspicious virtual close pattern
- repeated missing physical close
- offset manipulation
- invoice evidence mismatch
- payout account change before fast payout
- abnormal risk score override
- manual adjustment linked to offset or fast payout

Security Agent may alert or contain.

It must not decide legal guilt or accounting truth.

---

## 33. Anti-Patterns

Avoid:

- paying early before acquiring/settlement evidence without approved risk model
- calling fast payout risk “0%” without evidence and reserves
- hiding fast payout fee from owner
- virtual close treated as physical close
- virtual close overwriting later physical close
- missing close log treated as fraud automatically
- offsetting platform fee without contract/evidence
- tax invoice automation without tax/legal review
- platform revenue mixed with tenant settlement
- owner dashboard showing only net payout without deduction details
- locking in merchants through opaque deductions
- automatic billing document issued with wrong legal party
- fast payout recovery through silent deduction without policy

These anti-patterns must be blocked in future runtime design.

---

## 34. Runtime Deferral

This document defines fast payout, virtual close, offsetting, auto-billing, and operational asset optimization governance boundaries only.

It does not authorize:

- fast payout engine
- credit scoring engine
- factoring product
- financial partner integration
- virtual close runtime
- time-gap reconciliation runtime
- offsetting engine
- auto-billing engine
- tax authority integration
- invoice issuance
- owner dashboard implementation
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 35. Validation Checklist

Validation must confirm:

1. Operational asset optimization catalog is defined.
2. Fast payout boundary is defined.
3. Fast payout eligibility boundary is defined.
4. Credit risk scoring boundary is defined.
5. Advance settlement limit boundary is defined.
6. Receivable factoring boundary is defined.
7. Fast payout state skeleton is defined.
8. Fast payout evidence packet is defined.
9. Fast payout hold/recovery boundary is defined.
10. Virtual business close boundary is defined.
11. Virtual close state skeleton is defined.
12. Virtual close evidence boundary is defined.
13. Time-gap reconciliation boundary is defined.
14. Human error grace boundary is defined.
15. Offsetting boundary is defined.
16. Offsetting formula boundary is defined.
17. Offsetting state skeleton is defined.
18. Auto-billing/tax evidence boundary is defined.
19. Auto-billing evidence packet is defined.
20. Reverse issuance/auto-issuance caution boundary is defined.
21. Platform revenue recognition boundary is defined.
22. Merchant lock-in ethics boundary is defined.
23. Owner dashboard boundary is defined.
24. Governance risk catalog is defined.
25. Governance evidence packet is defined.
26. Relationships to Financial Kernel, Cross-Room Plumbing, Financial Trust, Data Governance, and Security Agent are defined.
27. Anti-patterns are listed.
28. Coding remains unauthorized.
29. Runtime remains deferred.

---

## 36. Relationship To Previous Documents

This document supplements:

- `10609G External Financial Network Circuit Breaker Saga Fallback KYC And Account Ownership Verification Policy`

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
- `10609G External Financial Network Circuit Breaker Saga Fallback KYC And Account Ownership Verification Policy`

It prepares:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- future fast payout eligibility specification
- future credit-risk scoring review packet
- future virtual close and time-gap reconciliation packet
- future offsetting and auto-billing legal/tax review packet
- future merchant liquidity governance packet

This document is architecture boundary planning only.

It does not authorize coding.

---

## 37. Final Rule

Operational asset optimization must increase merchant value without weakening financial integrity.

Fast payout may improve merchant liquidity, but it creates credit, refund, chargeback, settlement, legal, and accounting risk.

Virtual close may reduce human error, but it remains provisional until reconciled with physical evidence.

Offsetting may simplify platform billing, but it must be contract-backed, evidence-linked, tax-reviewed, and clearly visible to the merchant.

Auto-billing and tax evidence automation must not be guessed.

Platform revenue must be separated from tenant settlement funds.

Merchant lock-in must be earned through transparency, speed, accuracy, and trust.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
