# 10609_Financial_Regulation_Escrow_FDS_And_Settlement_Lag_Risk_Boundary_Policy

## 1. Purpose

This document defines the Financial Regulation, Escrow, FDS, and Settlement Lag Risk Boundary Policy.

The previous artifact `10608` defined final hidden SaaS edge guards for pseudonymized AI analysis, Noisy Neighbor control, nonce/idempotency, and replay prevention.

This document adds the final financial-regulation and money-flow risk layer for Catch Menu as a fintech-grade restaurant SaaS platform.

It covers:

1. Settlement fund custody, escrow, virtual account mapping, and platform money-handling boundary.
2. External financial institution FDS coordination and risk-score alignment.
3. Refund/cancellation settlement lag, dual-date accounting, and pending settlement tracking.

The purpose is to ensure that the platform does not accidentally become an unapproved money custodian, does not conflict with external PG/VAN/card-company fraud detection, and does not treat refund data date and actual settlement money date as the same thing.

This document is planning-only.

It does not authorize coding.

It is not legal advice.

All financial regulation, electronic financial transaction, payment custody, escrow, wallet, stored value, settlement, and licensing conclusions must be reviewed by qualified legal, compliance, tax, accounting, PG/VAN, banking, and payment-infrastructure experts before implementation or commercialization.

---

## 2. Core Position

A fintech-grade restaurant SaaS must separate data control from money custody.

The correct rule is:

Payment data visibility is not money custody.  
Settlement calculation is not fund possession.  
Platform ledger is not bank balance.  
Tenant receivable is not platform revenue.  
Escrow mapping is not free fund movement.  
Virtual account mapping must be tenant/legal scoped.  
Provider FDS may reject what internal AI considers normal.  
Internal AI score is not card-company authorization.  
Refund approved is not refund settled.  
Cancellation date is not settlement date.  
Pending settlement is not reconciliation error by itself.  
Settlement lag must be tracked as a first-class financial state.  

The platform should control evidence, routing, reconciliation, and visibility without casually touching tenant funds.

---

## 3. Financial Regulation Risk Catalog

The following risks must be treated as mandatory planning constraints:

| Risk | Meaning |
|---|---|
| `UNAPPROVED_FUND_CUSTODY` | Platform unintentionally holds tenant funds |
| `PLATFORM_TENANT_FUND_MIXING` | Platform assets and tenant settlement money are commingled |
| `ESCROW_MAPPING_FAILURE` | Tenant settlement account mapping is wrong or ambiguous |
| `VIRTUAL_ACCOUNT_SCOPE_MISMATCH` | Payment mapped to wrong tenant/store/legal entity |
| `PROVIDER_CONTRACT_MISMATCH` | Tenant/provider contract ownership is unclear |
| `FDS_RULE_MISALIGNMENT` | Internal AI and card/PG fraud rules conflict |
| `FDS_FALSE_POSITIVE_STORE_BLOCK` | External FDS blocks tenant/store/card flow |
| `RISK_SCORE_HEADER_MISMATCH` | Risk metadata sent to provider is missing/wrong |
| `REFUND_SETTLEMENT_LAG` | Refund data and actual fund movement occur on different dates |
| `DUAL_DATE_ACCOUNTING_REQUIRED` | Transaction date and settlement date must both be tracked |
| `PENDING_FUNDS_CONFUSION` | Pending refund/cancel state treated as final money movement |
| `SETTLEMENT_LAG_ATTACK` | Malicious repeated cancellation/refund disrupts settlement |
| `OWNER_PROJECTION_MISLEADING` | Owner dashboard shows final cash when money has not settled |

These risks must be addressed before payment-scale SaaS commercialization.

---

## 4. Money Custody Boundary

The platform must define whether it ever touches money.

Money custody risk increases when:

- customer payment is collected into platform account
- platform later pays tenants
- wallet/stored value is issued by platform
- tenant funds are temporarily held by platform
- platform net-settles multiple tenants
- platform controls payout timing
- platform mixes tenant funds with operating funds
- platform earns float interest or controls pooled balances
- platform processes refunds from its own account
- platform owns the merchant-of-record role

Preferred early SaaS boundary:

- tenant owns payment provider contract where possible
- tenant funds settle directly to tenant-controlled account or provider-managed settlement route
- platform records and reconciles data
- platform does not commingle tenant funds with platform operating cash
- platform does not provide stored value/wallet/custody without legal approval
- platform revenue is SaaS fee, not uncontrolled custody spread

This boundary must be legally reviewed.

---

## 5. Escrow And Virtual Account Mapping Boundary

If escrow, virtual account, or provider-managed settlement mapping is used, mapping must be explicit.

Required mapping dimensions:

- tenant id
- store id
- legal entity id
- merchant id
- provider id
- provider account id
- virtual account id
- escrow account id if applicable
- settlement account id
- payout rule id
- fee rule id
- tax/reporting reference if applicable
- effective date
- status
- verification evidence
- audit reference

Wrong mapping can misdirect money.

Mapping must be versioned, audited, and verified before use.

---

## 6. Tenant Fund Segregation Boundary

Tenant settlement funds must not be treated as platform operating funds.

Controls may include:

- tenant-specific provider account mapping
- virtual account per tenant/store/legal entity
- escrow or trust-style segregation where legally required
- provider-managed direct settlement
- separate accounting ledger
- separate bank reconciliation
- no commingling with platform revenue
- settlement report per legal entity
- payout evidence packet
- exception handling for wrong mapping
- legal/compliance review

Fund segregation is business survival infrastructure.

It is not just accounting preference.

---

## 7. Platform Revenue Versus Tenant Receivable Boundary

The platform must distinguish:

| Category | Meaning |
|---|---|
| `PLATFORM_SAAS_REVENUE` | Subscription or service fee earned by platform |
| `PLATFORM_USAGE_FEE` | Platform fee charged under contract |
| `TENANT_GROSS_SALES` | Tenant sales before refund/fees |
| `TENANT_NET_SALES` | Tenant sales after refund/cancel and adjustments |
| `TENANT_RECEIVABLE` | Amount expected to be paid to tenant |
| `PROVIDER_FEE` | Fee charged by provider |
| `PLATFORM_COLLECTED_FEE` | Platform fee, only if legally and contractually allowed |
| `PENDING_SETTLEMENT_AMOUNT` | Amount not yet finalized |
| `DISPUTED_AMOUNT` | Amount under review |
| `HELD_AMOUNT` | Amount held due to reconciliation/legal/security issue |

Tenant receivable must not be confused with platform revenue.

---

## 8. Provider Contract Ownership Boundary

For SaaS, provider contract ownership must be explicit.

Possible models:

| Model | Description | Risk |
|---|---|---|
| Tenant-owned PG/VAN contract | Tenant controls provider account | Lower platform custody risk |
| Platform-managed connection to tenant account | Platform routes data, tenant owns funds | Moderate operational risk |
| Platform merchant-of-record | Platform collects funds | High regulation/custody risk |
| Provider marketplace/sub-merchant model | Provider manages sub-merchant flow | Requires provider/legal review |
| Wallet/stored value model | Platform stores or issues value | High financial regulation risk |

The selected model must be documented per tenant/package.

Provider contract ownership must not be guessed.

---

## 9. Escrow Evidence Packet Boundary

Escrow or virtual settlement evidence packet may include:

- tenant identity evidence
- legal entity evidence
- provider contract evidence
- bank/virtual account verification
- merchant id mapping
- account ownership verification
- settlement route approval
- fee rule approval
- effective date
- account change history
- test settlement result
- audit event
- legal/compliance approval reference

Settlement route must not activate without evidence.

---

## 10. FDS Coordination Boundary

External FDS may apply rules unknown to internal AI.

External FDS may consider:

- repeated small payments
- repeated cancellation/refund
- card testing pattern
- unusual merchant behavior
- device/IP anomaly
- high refund ratio
- high chargeback risk
- rapid payment/cancel loop
- same card across many terminals
- suspicious time pattern
- abnormal merchant category behavior
- provider/card-company risk models

Internal AI “normal” does not override external FDS.

External FDS “blocked” must be handled safely.

---

## 11. Internal AI Versus External FDS Boundary

The platform must distinguish:

| System | Role |
|---|---|
| Internal Security AI | Detect platform/store/device/order/payment anomaly |
| Provider FDS | Detect provider-side payment fraud risk |
| Card Company FDS | Detect card/cardholder-side risk |
| WAF/Security Gateway | Detect traffic/application attack |
| Financial Reconciliation | Detect ledger mismatch |
| Human Review | Resolve ambiguous business/legal cases |

These systems may disagree.

Disagreement must create evidence, not forced override.

---

## 12. FDS Risk Score Boundary

If the provider supports risk metadata, the platform may send structured risk signals.

Risk score packet may include:

- tenant id pseudonym
- store id pseudonym
- device trust class
- signature status
- nonce validity
- idempotency status
- repeated payment count
- repeated cancel/refund count
- time interval class
- offline recovery marker
- customer session pseudonym
- payload risk class
- prior DLQ count if allowed
- fraud risk score
- confidence class
- source evidence reference

Risk score must not leak raw sensitive data.

Provider format must be verified before use.

---

## 13. FDS Pre-Control Boundary

Before sending approval request to provider/card network, the platform may apply pre-controls.

Examples:

- warn customer after repeated payment/cancel attempts
- require staff confirmation for repeated cancel/refund loop
- block duplicate nonce/idempotency conflict
- delay suspicious rapid retry
- require manager approval for refund threshold
- route suspicious pattern to review
- show customer-safe message
- avoid sending obviously risky repeated provider requests

Pre-control must not become unfair customer denial without policy.

Pre-control must be evidence-based and auditable.

---

## 14. FDS Block Handling Boundary

If provider/card FDS blocks or declines transaction:

Required handling:

- record provider response
- record risk/failure code if available
- do not override as success
- do not create payment truth
- show customer-safe message
- avoid exposing fraud accusation
- route repeated issue to support
- preserve tenant/store/device scope
- create analytics/security signal
- create reconciliation note if pending state exists

Provider block is external evidence.

It is not internal fraud proof by itself.

---

## 15. Repeated Payment Cancellation Boundary

Repeated payment/cancellation loops may be:

- customer confusion
- staff training/test
- NFC behavior issue
- network retry problem
- device bug
- card testing fraud
- refund abuse
- malicious settlement disruption
- provider delay artifact

The system must classify before accusation.

Controls may include:

- frontend warning
- cooldown
- idempotency check
- manager approval
- staff training marker
- test mode separation
- provider risk metadata
- CS review
- security review

Test behavior must not pollute production financial truth.

---

## 16. Refund Settlement Lag Boundary

Refund/cancellation may be approved on one date and settled financially on another date.

The platform must track:

- original payment date
- refund request date
- refund approval date
- provider refund accepted date
- refund settlement expected date
- refund settlement confirmed date
- bank/account movement date if available
- settlement cycle
- owner projection date
- accounting recognition date if applicable

Refund approved is not refund cash settled.

Refund data date and cash movement date must be separated.

---

## 17. Dual-Date Accounting Boundary

Dual-date accounting means tracking both event date and money settlement date.

Required date families:

| Date | Meaning |
|---|---|
| `transaction_event_date` | When customer/payment event occurred |
| `provider_authorization_date` | When provider authorized |
| `provider_capture_date` | When provider captured |
| `refund_request_date` | When refund was requested |
| `refund_provider_accept_date` | When provider accepted refund |
| `refund_settlement_date` | When refund money impact is expected/confirmed |
| `tenant_settlement_date` | When tenant payout is expected/confirmed |
| `business_date` | Store-defined sales day |
| `accounting_date` | Accounting recognition date if separate |
| `batch_reconciliation_date` | When batch reviewed the record |

One date is insufficient.

---

## 18. Pending Settlement State Boundary

Refund, cancel, dispute, and provider adjustment may enter pending state.

Recommended states:

| State | Meaning |
|---|---|
| `REFUND_REQUESTED` | Refund requested |
| `REFUND_ACCEPTED_BY_PROVIDER` | Provider accepted request |
| `REFUND_PENDING_SETTLEMENT` | Financial settlement not yet confirmed |
| `REFUND_SETTLEMENT_CONFIRMED` | Settlement impact confirmed |
| `REFUND_SETTLEMENT_DELAYED` | Expected date missed |
| `REFUND_RECONCILIATION_REQUIRED` | Records disagree |
| `REFUND_DLQ_REQUIRED` | Requires DLQ isolation |
| `REFUND_DISPUTED` | Dispute exists |
| `REFUND_AMENDMENT_REQUIRED` | Append-only correction needed |

Pending is not error by itself.

Pending must be visible.

---

## 19. Settlement Lag Attack Boundary

Settlement lag may be abused.

Attack or abuse patterns may include:

- repeated large cancellations near settlement close
- repeated refund/cancel loop to disrupt payout
- many pending refunds before payout
- provider delay exploited to confuse owner projection
- refund after goods consumed
- repeated card testing via cancel loops
- suspicious tenant-specific refund spike
- staff collusion refund pattern
- refund timing manipulation around business-date cutover

Settlement lag attack suspicion must create security/finance review.

It must not automatically accuse.

---

## 20. Refund Reserve And Hold Boundary

Some refund/cancel patterns may require reserve or hold policy.

Possible controls:

- hold affected amount
- mark pending settlement
- delay payout of disputed amount
- reserve against expected refund
- require manager/HQ approval
- require provider confirmation
- route to DLQ
- route to compliance/security
- show owner-safe pending status

Reserve/hold policy must be contractual and legally reviewed.

Hold is not penalty.

Hold protects settlement correctness.

---

## 21. Owner Projection For Settlement Lag

Owner/franchise dashboard must separate:

- gross sales
- confirmed payment
- confirmed refund
- pending refund
- pending settlement
- held amount
- disputed amount
- estimated payout
- confirmed payout
- settlement date
- reconciliation status

Owner dashboard must not show pending refund as final settled cash.

Owner trust requires visible pending status.

---

## 22. Bank Account And Virtual Account Change Boundary

Changing settlement account is high risk.

Account change must require:

- tenant/legal entity verification
- bank account ownership verification
- authorized actor
- strong authentication
- approval workflow
- cooling period if policy requires
- notification to owner/legal contact
- test deposit or provider verification if applicable
- effective date
- audit
- old/new account reference
- fraud review if suspicious

Account change must not be casual admin edit.

---

## 23. Account Mapping Error Boundary

If payment settles to wrong account or wrong tenant mapping:

Required handling:

- freeze affected settlement route
- create critical incident
- preserve provider/bank evidence
- notify finance/security/compliance
- create reconciliation case
- create legal/compliance case if required
- block further payout using bad mapping
- investigate account change history
- prepare correction/amendment route
- prepare owner communication

Wrong-money-route is critical financial incident.

---

## 24. AML And Suspicious Transaction Boundary

As the platform grows, suspicious money movement patterns must be monitored where legally and contractually required.

Potential suspicious patterns:

- rapid high-volume refund loop
- unusual spike in stored value if enabled
- abnormal payout account changes
- repeated small card tests
- cross-store coordinated refund pattern
- high refund-to-sales ratio
- payout to unrelated account
- suspicious merchant onboarding
- unusual cash-like value movements
- repeated failed authorization attempts

AML/suspicious transaction handling must be legally reviewed.

This document does not define final AML obligations.

It requires legal/compliance review and policy matrix.

---

## 25. Tenant Onboarding Financial Compliance Boundary

Tenant onboarding must verify financial identity.

Possible checks:

- legal entity identity
- business registration
- representative identity under policy
- provider contract ownership
- settlement account ownership
- store ownership/operation authority
- tax/reporting reference if applicable
- risk class
- prohibited business check if applicable
- provider approval status
- bank/virtual account verification
- device certification
- admin authority

Onboarding is a financial risk gate.

It is not only SaaS account creation.

---

## 26. Financial Regulation Safe Product Boundary

Early SaaS product should avoid high-regulation features until reviewed.

Features requiring special caution:

- platform-held wallet
- stored value
- prepaid balance
- platform-controlled tenant payout
- pooled settlement account
- cash-like points
- platform-issued coupons with cash redemption
- cross-tenant value transfer
- platform-funded refund account
- lending/advance payout
- automatic payout withholding without contract
- escrow without bank/provider structure

Product capability must follow legal readiness.

---

## 27. External Financial Partner Boundary

Bank/PG/VAN/card partner integrations require partner-specific compliance.

Partner review may include:

- security assessment
- API certification
- FDS data format
- settlement file format
- refund/cancel rules
- merchant mapping
- sub-merchant rules
- data retention
- encryption requirements
- incident notification
- reconciliation evidence
- audit report
- penetration/security testing
- operational SLA

Provider capability remains evidence-required until certified.

---

## 28. Financial Report And Tax Boundary

Financial reporting must distinguish operational and accounting views.

Reports may include:

- operational sales
- payment-confirmed sales
- settlement-confirmed sales
- refund pending
- refund settled
- fees
- platform SaaS fee
- tax-relevant amount if applicable
- payout amount
- withheld/held amount
- disputed amount
- adjustment/amendment
- business date
- accounting date
- settlement date

Report format must be reviewed by accounting/tax experts before official use.

---

## 29. Financial Regulatory Evidence Packet

Financial regulatory evidence packet may include:

- tenant identity evidence
- provider contract evidence
- settlement account verification
- escrow/virtual account mapping
- fund segregation evidence
- payment flow diagram
- refund flow diagram
- wallet/stored value exclusion or approval evidence
- FDS integration evidence
- reconciliation report
- settlement lag state report
- pending/hold policy
- account change audit
- suspicious transaction review
- legal/compliance approval reference

Evidence packet supports review.

It is not legal approval by itself.

---

## 30. Patent Candidate Boundary

These financial risk controls strengthen the patent candidate.

Potential patent-relevant extensions:

- restaurant SaaS payment platform that separates data reconciliation control from fund custody
- tenant-specific virtual account/escrow mapping linked to four-source reconciliation
- provider/card FDS-aware pre-control and risk-score metadata pipeline
- dual-date accounting for refund/cancel settlement lag in restaurant order/payment SaaS
- pending settlement state projection for owner trust and dispute prevention
- settlement lag attack detection using refund/cancel timing patterns
- financial regulatory evidence packet linked to device/key/audit/reconciliation architecture

Patent attorney review is required.

This document is architecture planning only.

---

## 31. Relationship To Financial Trust

This document extends Financial Trust by adding:

- fund custody boundary
- escrow/virtual account mapping
- provider contract ownership
- FDS coordination
- refund settlement lag
- dual-date accounting
- settlement pending state
- AML/suspicious transaction review
- financial regulatory evidence packet

Financial Trust must not finalize or project money movement without settlement-state clarity.

---

## 32. Relationship To Cross-Room Plumbing

Future event routing must carry:

- fund custody model
- provider contract owner
- merchant id
- virtual account id
- escrow mapping id
- settlement account id
- FDS risk score reference
- provider FDS response code
- refund settlement expected date
- refund settlement confirmed date
- pending settlement state
- hold/reserve marker
- suspicious transaction marker
- regulatory evidence packet reference

These become context envelope candidates.

---

## 33. Relationship To Data Governance

Data Governance must control:

- owner settlement projection
- pending refund messages
- FDS block messages
- compliance dashboard
- financial export
- masking of account identifiers
- masking of provider/card response
- audit of account changes
- retention of regulatory evidence
- AI summary restrictions
- i18n messages for pending/blocked/held states

Financial status visibility must be safe, precise, and non-misleading.

---

## 34. Relationship To Security Agent

Security Agent may detect:

- repeated refund/cancel loop
- card-testing pattern
- FDS mismatch pattern
- payout account change anomaly
- tenant settlement route change
- unusual pending refund spike
- settlement lag abuse
- suspicious onboarding
- provider credential abuse
- virtual account mismatch

Security Agent may alert or contain.

It must not decide legal guilt.

It must not finalize financial truth.

---

## 35. Relationship To SaaS Product Strategy

SaaS product strategy must separate:

- low-regulation order SaaS
- payment handoff SaaS
- provider-connected reconciliation SaaS
- financial-grade settlement reporting
- wallet/stored value features
- platform-controlled payout features
- enterprise escrow/provider settlement features

Do not launch high-regulation financial features before legal readiness.

SaaS fees should be clearly separated from tenant settlement funds.

---

## 36. Anti-Patterns

Avoid:

- platform account collecting all tenant sales without legal review
- tenant funds mixed with platform operating funds
- settlement route changed by casual admin edit
- wrong virtual account mapping ignored
- provider contract owner unclear
- platform wallet launched as “simple points” without legal review
- internal AI overriding provider/card FDS decline
- repeated payment/cancel loop sent endlessly to card network
- FDS block shown as fraud accusation to customer
- refund approved shown as cash-settled immediately
- cancellation date treated as settlement date
- pending refund hidden from owner dashboard
- settlement lag treated as reconciliation error every night
- owner payout finalized while refund settlement is pending
- suspicious transaction pattern ignored because payment technically reconciled
- financial report used for tax/accounting without expert review

These anti-patterns must be blocked in future runtime design.

---

## 37. Runtime Deferral

This document defines financial regulation, escrow, FDS, and settlement lag boundaries only.

It does not authorize:

- escrow implementation
- virtual account implementation
- bank integration
- PG/VAN integration
- FDS integration
- risk-score header implementation
- refund settlement-date engine
- AML monitoring runtime
- financial compliance workflow
- account change workflow
- regulatory evidence packet generation
- wallet/stored value feature
- payout engine
- database schema
- RLS policy
- production deployment

All runtime remains deferred.

---

## 38. Validation Checklist

Validation must confirm:

1. Financial regulation risk catalog is defined.
2. Money custody boundary is defined.
3. Escrow/virtual account mapping boundary is defined.
4. Tenant fund segregation boundary is defined.
5. Platform revenue versus tenant receivable boundary is defined.
6. Provider contract ownership boundary is defined.
7. Escrow evidence packet boundary is defined.
8. FDS coordination boundary is defined.
9. Internal AI versus external FDS boundary is defined.
10. FDS risk score boundary is defined.
11. FDS pre-control boundary is defined.
12. FDS block handling boundary is defined.
13. Repeated payment/cancellation boundary is defined.
14. Refund settlement lag boundary is defined.
15. Dual-date accounting boundary is defined.
16. Pending settlement state boundary is defined.
17. Settlement lag attack boundary is defined.
18. Refund reserve/hold boundary is defined.
19. Owner projection for settlement lag is defined.
20. Bank/virtual account change boundary is defined.
21. Account mapping error boundary is defined.
22. AML/suspicious transaction boundary is defined without final legal assertion.
23. Tenant onboarding financial compliance boundary is defined.
24. Financial regulation safe product boundary is defined.
25. External financial partner boundary is defined.
26. Financial report/tax boundary is defined.
27. Financial regulatory evidence packet is defined.
28. Patent candidate boundary is defined.
29. Relationships to Financial Trust, Cross-Room Plumbing, Data Governance, Security Agent, and SaaS Product Strategy are defined.
30. Anti-patterns are listed.
31. Coding remains unauthorized.
32. Runtime remains deferred.

---

## 39. Relationship To Previous Documents

This document supplements:

- `10400~10480 Financial Trust Room Framing Sequence`
- `10601 Financial-Grade Ledger Reconciliation And Four-Source Closing Audit Policy`
- `10602 Financial Reconciliation Blind Spot Control Time State Offline Log And Auditor Security Policy`
- `10603 Reconciliation DLQ Device Non-Repudiation And Cold Storage Lifecycle Policy`
- `10604 SaaS Scale Constraint Multi-Tenancy Hardware Regulation Noise And Distributed Batch Policy`
- `10605 SaaS Field Resilience Network Provider SLA And Policy-Based Customization Constraint Policy`
- `10606 Extreme Edge Case Power Cut Twenty-Four-Hour Store Hardware Peripheral And Human CS Operations Policy`
- `10607 Long Transaction Concurrency Disaster Recovery And Backup Integrity Edge Case Policy`
- `10608 Pseudonymized AI Analysis Noisy Neighbor Control Nonce Idempotency And Final SaaS Edge Guard Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10530 Safe Projection Masking And Audience Visibility Boundary Policy`
- `10540 AI Advisory Runtime And Non-Authority Boundary Policy`
- `10554 Four-Layer Audit Capture Trigger View OS Log And Nightly Batch Reconciliation Policy`
- `10570 Retention Export And Compliance Data Boundary Policy`
- `10580 Data Governance Closure And Cross-Room Handoff Policy`
- `10600 Cross-Room Plumbing Wiring Insulation Planning Index`

It prepares:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- future financial regulatory review packet
- future fund custody model decision packet
- future provider/FDS integration specification
- future refund settlement lag state machine
- future virtual account/escrow mapping policy
- future financial compliance authorization gate

This document is architecture boundary planning only.

It does not authorize coding.

---

## 40. Final Rule

Catch Menu must not become a financial-risk platform by accident.

The platform should control order, payment evidence, reconciliation, audit, projection, and support workflow without casually taking custody of tenant funds.

Tenant settlement funds must remain segregated from platform operating funds.

Escrow, virtual account, provider contract ownership, wallet, stored value, payout, and fund custody models require legal/compliance review before implementation.

External PG/VAN/card-company FDS decisions must be coordinated, not ignored.

Internal AI does not override external FDS.

Repeated payment/cancel/refund loops require frontend control, risk scoring, evidence, and review.

Refund approval is not refund cash settlement.

Cancellation date is not settlement date.

Dual-date accounting and pending settlement states must be first-class.

Settlement lag must be visible, tracked, held where needed, and projected honestly to owners.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.