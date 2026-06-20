# 010120_Policy_Payment_Settlement_Refund_Wallet_Financial_Trust_Skeleton

## 1. Purpose

This document defines the Payment, Settlement, Refund, Wallet, and Financial Trust Skeleton Policy.

The previous artifact `10110` defined the Store Runtime, POS, KDS, and Kitchen Execution Skeleton Policy as Side B of the four-side platform skeleton.

This document builds Side C:

`Financial Security And Trust Skeleton`

The purpose is to define the financial-grade trust frame before any payment runtime, settlement logic, refund execution, coupon issuance, point adjustment, wallet/prepaid balance mutation, provider callback handling, or production reconciliation is implemented.

This document is planning-only.

It does not authorize coding.

---

## 2. Side C Definition

Side C represents the financial trust and containment layer of the platform.

It includes:

- payment request boundary
- payment confirmation boundary
- POS accepted versus payment confirmed separation
- settlement boundary
- refund boundary
- cancellation boundary
- coupon boundary
- point boundary
- wallet/prepaid boundary
- compensation value action boundary
- idempotency
- reconciliation
- financial evidence packet
- provider trust boundary
- secret handling
- fraud/abuse review
- audit and legal traceability
- financial containment and quarantine

Side C answers:

How does the platform prevent financial state from being guessed, duplicated, overwritten, falsely confirmed, leaked, or misused?

---

## 3. Core Principle

Financial truth must be verified, reconciled, and auditable.

The correct rule is:

Surface display is not payment truth.
POS accepted is not payment confirmed.
KDS completed is not settled.
Provider callback is not verified state.
Customer claim is not refund approval.
Recovery case is not compensation execution.
Coupon/point/wallet change is financial mutation.
AI summary is not financial evidence.
pgvector similarity is not proof.

Financial state must be verified by approved financial boundaries.

---

## 4. Financial Trust Skeleton

Financial Trust may coordinate:

- payment request status
- payment verification status
- payment provider reference
- POS payment relation reference
- settlement candidate status
- reconciliation status
- refund request status
- refund approval status
- refund execution status
- coupon issue request
- point adjustment request
- wallet/prepaid mutation request
- compensation value action review
- fraud/abuse signal review
- financial evidence packet
- financial audit event

Financial Trust must not be bypassed by product surfaces, Kiosk, POS, KDS, CMS, Support/Admin, AI, pgvector, or Franchise OS.

---

## 5. Payment Boundary Skeleton

Payment boundary should define the difference between request, attempt, authorization, confirmation, failure, cancellation, and reconciliation.

Recommended skeleton states:

| State | Meaning |
|---|---|
| `PAYMENT_NOT_REQUIRED` | No payment required for this flow |
| `PAYMENT_REQUIRED` | Payment required before continuation |
| `PAYMENT_REQUEST_CREATED` | Payment request created |
| `PAYMENT_ATTEMPT_STARTED` | Customer/payment provider attempt started |
| `PAYMENT_PROVIDER_PENDING` | Provider result pending |
| `PAYMENT_AUTHORIZED` | Authorization received if applicable |
| `PAYMENT_CONFIRMED` | Payment confirmed by approved verification |
| `PAYMENT_FAILED` | Payment failed |
| `PAYMENT_CANCELED` | Payment canceled |
| `PAYMENT_UNKNOWN` | Payment state uncertain |
| `PAYMENT_RECONCILIATION_REQUIRED` | Reconciliation required |
| `PAYMENT_RECONCILED` | Reconciled |
| `PAYMENT_DISPUTE_REVIEW_REQUIRED` | Dispute review required |

These states are skeleton states only.

They do not authorize runtime.

---

## 6. POS And Payment Separation Rule

POS accepted and payment confirmed must remain separate.

Examples:

- POS may accept an order before payment is confirmed in some workflows.
- Payment may be confirmed before POS acceptance in some workflows.
- POS receipt reference may not prove payment settlement.
- POS provider status may be delayed or stale.
- Payment provider status may conflict with POS status.
- Store staff may see order completion while financial reconciliation remains pending.

The system must preserve both dimensions:

| Dimension | Owner |
|---|---|
| Order acceptance | POS / Store Runtime boundary |
| Payment confirmation | Financial Trust boundary |
| Settlement reconciliation | Financial Trust boundary |
| Customer-safe display | Safe Projection boundary |

POS accepted != payment confirmed.

---

## 7. Settlement Boundary Skeleton

Settlement boundary should define when money movement is considered ready for accounting or payout review.

Settlement skeleton states may include:

| State | Meaning |
|---|---|
| `SETTLEMENT_NOT_APPLICABLE` | No settlement required |
| `SETTLEMENT_PENDING` | Awaiting settlement data |
| `SETTLEMENT_CANDIDATE` | Candidate settlement identified |
| `SETTLEMENT_PROVIDER_REPORTED` | Provider reported settlement |
| `SETTLEMENT_RECONCILIATION_REQUIRED` | Reconciliation required |
| `SETTLEMENT_RECONCILED` | Reconciled |
| `SETTLEMENT_MISMATCH` | Mismatch detected |
| `SETTLEMENT_HELD` | Held for review |
| `SETTLEMENT_RELEASED` | Released after approval |
| `SETTLEMENT_AUDIT_REQUIRED` | Audit required |

Settlement is not a surface feature.

Settlement requires reconciliation and evidence.

---

## 8. Refund Boundary Skeleton

Refund boundary must separate refund request, refund review, refund approval, refund execution, and refund reconciliation.

Recommended skeleton states:

| State | Meaning |
|---|---|
| `REFUND_NOT_REQUESTED` | No refund requested |
| `REFUND_REQUESTED` | Refund requested |
| `REFUND_REVIEW_REQUIRED` | Review required |
| `REFUND_APPROVED` | Refund approved by authority |
| `REFUND_REJECTED` | Refund rejected |
| `REFUND_EXECUTION_PENDING` | Execution pending |
| `REFUND_EXECUTED` | Refund executed |
| `REFUND_FAILED` | Refund execution failed |
| `REFUND_RECONCILIATION_REQUIRED` | Reconciliation required |
| `REFUND_RECONCILED` | Refund reconciled |
| `REFUND_DISPUTE_REVIEW_REQUIRED` | Dispute review required |

Refund request is not refund approval.

Refund approval is not refund execution.

Refund execution is not refund reconciliation.

---

## 9. Cancellation Boundary Skeleton

Cancellation must be separated from refund.

Cancellation may affect:

- order state
- POS state
- KDS state
- kitchen execution
- payment state
- refund requirement
- customer communication
- recovery case
- inventory/waste status
- settlement/reconciliation

Cancellation states may include:

| State | Meaning |
|---|---|
| `CANCEL_REQUESTED` | Cancellation requested |
| `CANCEL_REVIEW_REQUIRED` | Review required |
| `CANCEL_ALLOWED` | Cancellation allowed |
| `CANCEL_BLOCKED` | Cancellation blocked |
| `CANCEL_APPLIED_TO_ORDER` | Applied to internal order |
| `CANCEL_APPLIED_TO_POS` | Applied to POS if applicable |
| `CANCEL_APPLIED_TO_KDS` | Applied to KDS if applicable |
| `CANCEL_PAYMENT_IMPACT_REVIEW_REQUIRED` | Payment impact review required |
| `CANCEL_RECOVERY_REVIEW_REQUIRED` | Customer recovery review required |

Cancellation does not automatically mean refund.

---

## 10. Coupon Boundary Skeleton

Coupon issuance and redemption are financial-adjacent value actions.

Coupon states may include:

| State | Meaning |
|---|---|
| `COUPON_NOT_APPLICABLE` | No coupon |
| `COUPON_CANDIDATE` | Candidate coupon |
| `COUPON_REVIEW_REQUIRED` | Review required |
| `COUPON_APPROVED` | Approved for issue |
| `COUPON_ISSUED` | Issued |
| `COUPON_REDEEMED` | Redeemed |
| `COUPON_EXPIRED` | Expired |
| `COUPON_REVOKED` | Revoked |
| `COUPON_RECONCILIATION_REQUIRED` | Reconciliation required |

Coupon is not a casual message.

Coupon issue changes customer value state.

---

## 11. Point Boundary Skeleton

Point adjustment must be treated as a value mutation.

Point states may include:

| State | Meaning |
|---|---|
| `POINT_EVENT_CANDIDATE` | Candidate point event |
| `POINT_REVIEW_REQUIRED` | Review required |
| `POINT_APPROVED` | Approved |
| `POINT_GRANTED` | Points granted |
| `POINT_USED` | Points used |
| `POINT_ADJUSTED` | Points adjusted |
| `POINT_REVOKED` | Points revoked |
| `POINT_RECONCILIATION_REQUIRED` | Reconciliation required |
| `POINT_DISPUTE_REVIEW_REQUIRED` | Dispute review required |

Point mutation requires evidence, idempotency, and audit.

---

## 12. Wallet And Prepaid Boundary Skeleton

Wallet/prepaid balance is a high-risk financial area.

Wallet/prepaid states may include:

| State | Meaning |
|---|---|
| `WALLET_NOT_ENABLED` | Wallet not enabled |
| `WALLET_ACCOUNT_CANDIDATE` | Wallet candidate |
| `WALLET_ACTIVE` | Wallet active if approved |
| `WALLET_CHARGE_REQUESTED` | Charge requested |
| `WALLET_CHARGE_CONFIRMED` | Charge confirmed |
| `WALLET_DEBIT_REQUESTED` | Debit requested |
| `WALLET_DEBIT_CONFIRMED` | Debit confirmed |
| `WALLET_REFUND_REVIEW_REQUIRED` | Refund review required |
| `WALLET_BALANCE_RECONCILIATION_REQUIRED` | Balance reconciliation required |
| `WALLET_SUSPENDED` | Suspended |
| `WALLET_DISPUTE_REVIEW_REQUIRED` | Dispute review required |

Wallet/prepaid must not be introduced casually.

It requires stronger legal, financial, security, and reconciliation review.

---

## 13. Compensation Value Action Boundary Skeleton

Compensation is separated from recovery.

Possible compensation value actions:

- apology message only
- service recovery note
- coupon
- point grant
- wallet/prepaid credit
- partial refund
- full refund
- replacement item
- future benefit
- manual goodwill action

Compensation skeleton states:

| State | Meaning |
|---|---|
| `COMPENSATION_NOT_REQUESTED` | No compensation requested |
| `COMPENSATION_CANDIDATE` | Candidate compensation |
| `COMPENSATION_REVIEW_REQUIRED` | Review required |
| `COMPENSATION_APPROVED` | Approved |
| `COMPENSATION_REJECTED` | Rejected |
| `COMPENSATION_EXECUTION_PENDING` | Execution pending |
| `COMPENSATION_EXECUTED` | Executed |
| `COMPENSATION_RECONCILIATION_REQUIRED` | Reconciliation required |
| `COMPENSATION_RECONCILED` | Reconciled |

Recovery case is not compensation execution.

---

## 14. Idempotency Skeleton

Financial and value actions must be idempotent.

Idempotency applies to:

- payment request
- payment confirmation
- refund execution
- coupon issuance
- point adjustment
- wallet credit
- wallet debit
- compensation execution
- settlement reconciliation
- provider callback processing

Idempotency record should distinguish:

- original request
- retry request
- duplicate callback
- delayed callback
- conflicting callback
- manually reviewed action
- rejected duplicate
- accepted replay

Duplicate event must not create duplicate value.

---

## 15. Reconciliation Skeleton

Reconciliation is required when internal state and external/provider state may differ.

Reconciliation may compare:

- internal order reference
- POS reference
- payment provider reference
- settlement reference
- refund reference
- coupon ledger reference
- point ledger reference
- wallet ledger reference
- support/recovery case reference
- manual fallback reference
- provider callback history
- audit event history

Reconciliation must not silently mutate source truth.

Reconciliation produces reviewed correction or verified state.

---

## 16. Financial Evidence Packet Skeleton

Financial evidence packet may include:

- tenant id
- store id
- order id
- payment request id
- payment provider reference
- POS reference
- refund reference
- settlement reference
- coupon/point/wallet reference
- compensation review id
- provider response snapshot
- callback timestamp
- verification method
- reconciliation status
- idempotency key
- actor id
- approval id
- audit event reference
- masking/privacy class
- legal hold flag if applicable

Evidence packet supports review.

Evidence packet is not approval.

---

## 17. Provider Trust Boundary Skeleton

Provider integration must be limited-trust.

Provider data must be treated as:

- externally sourced
- possibly delayed
- possibly duplicated
- possibly partial
- possibly inconsistent
- possibly provider-specific
- possibly stale
- requiring verification
- requiring reconciliation when financial

Provider callback is not verified truth by itself.

Provider capability must be evidence-based.

Provider credentials must be isolated.

---

## 18. Secret Handling Skeleton

Financial and provider secrets must be protected.

Secret handling must include:

- no secrets in static artifacts
- no secrets in client surfaces
- no secrets in logs
- no secrets in screenshots
- no secrets in support views
- scoped server-side access only
- rotation readiness
- revocation readiness
- environment separation
- least privilege
- audit of secret access
- incident containment

Secret visibility must be minimized.

---

## 19. Fraud And Abuse Review Skeleton

Fraud/abuse review may be triggered by:

- repeated refund requests
- repeated compensation requests
- duplicate payment attempts
- mismatched POS/payment states
- unusual coupon/point usage
- wallet/prepaid anomalies
- provider callback conflict
- device compromise
- staff override pattern
- manual fallback abuse
- customer dispute pattern

Fraud signal is not legal conclusion.

Fraud signal requires review.

---

## 20. Financial Safe Projection Skeleton

Financial state must be safely projected to each audience.

| Audience | Financial Visibility |
|---|---|
| Customer | safe payment/refund status only |
| Staff | operational payment availability only |
| Store Owner | masked financial status and exceptions |
| Support | masked evidence and review context |
| Finance Admin | authorized financial review |
| HQ | aggregate and exception view |
| Franchise OS | governed multi-store financial visibility |

Raw payment payloads must not be exposed to normal surfaces.

---

## 21. Financial Containment And Quarantine Skeleton

Financial containment may apply when:

- payment status is uncertain
- refund duplication risk exists
- provider callback conflict exists
- wallet balance mismatch exists
- coupon abuse suspected
- point ledger mismatch exists
- settlement mismatch exists
- device compromise affects payment
- secret exposure suspected
- manual fallback created financial uncertainty

Containment may block new value mutation while preserving review access.

Containment is not resolution.

Quarantine is not deletion.

---

## 22. Relationship To Side A

Side A product surfaces may request or display financial-safe state only.

Examples:

- Catch Menu should not show payment truth.
- Mini Kiosk may show payment unavailable if disabled.
- Full Kiosk may request payment only if authorized later.
- Admin Surface may show masked financial status.
- Franchise OS may aggregate financial exceptions later.

Product surface is not financial authority.

---

## 23. Relationship To Side B

Side B operational runtime must defer financial truth to Side C.

Examples:

- POS accepted must be reconciled with payment.
- KDS completed must not trigger settlement.
- staff assist must not approve refund.
- manual fallback must not overwrite payment truth.
- store incident may open review but not execute compensation.

Operational state is not financial truth.

---

## 24. Relationship To Side D

Side D governance and intelligence may support financial review but cannot replace financial evidence.

Examples:

- AI may summarize a case if authorized.
- pgvector may retrieve similar cases if authorized.
- analytics may detect unusual patterns.
- CMS may publish reviewed customer-safe message.
- i18n controls financial-safe message keys.
- policy registry defines approval rules.

AI is not financial authority.

Similarity is not proof.

Analytics is not approval.

---

## 25. Financial Anti-Patterns

Avoid:

- POS accepted treated as payment confirmed
- payment callback treated as verified truth without reconciliation
- KDS completed treated as settlement
- refund request treated as refund approval
- refund approval treated as refund execution
- compensation review treated as value execution
- coupon issue treated as harmless message
- point adjustment treated as non-financial
- wallet/prepaid introduced without financial controls
- duplicate callback creating duplicate value
- AI deciding refund/compensation
- pgvector similarity approving financial action
- raw payment payload exposed to support surface
- provider credentials stored in static files
- containment released without authority

These anti-patterns create financial, legal, and security risk.

---

## 26. Runtime Deferral

This document defines financial trust skeleton only.

It does not authorize:

- payment integration
- payment verification API
- refund execution
- settlement ledger
- coupon issuance
- point adjustment
- wallet/prepaid system
- compensation execution
- provider callback processing
- financial database schema
- financial admin UI
- secret storage implementation
- fraud engine implementation
- reconciliation engine implementation
- production deployment

All runtime remains deferred.

---

## 27. Recommended Next Documents

The next skeleton documents should be:

| Document | Purpose |
|---|---|
| `10130 CMS i18n AI pgvector Data Governance Skeleton Policy` | Build Side D |
| `10140 Cross-Axis Authority Evidence Audit And Fallback Beam Policy` | Connect all sides |
| `10150 Four-Side Skeleton Closure And Runtime Deferral Policy` | Close skeleton sequence |

This document completes Side C at skeleton level.

---

## 28. Validation Checklist

Validation must confirm:

1. Financial Trust role is defined.
2. Payment boundary is defined.
3. POS/payment separation is defined.
4. Settlement boundary is defined.
5. Refund boundary is defined.
6. Cancellation is separated from refund.
7. Coupon boundary is defined.
8. Point boundary is defined.
9. Wallet/prepaid boundary is high-risk.
10. Compensation is separated from recovery.
11. Idempotency is defined.
12. Reconciliation is defined.
13. Financial evidence packet is defined.
14. Provider trust boundary is limited-trust.
15. Secret handling skeleton is defined.
16. Fraud/abuse review is defined.
17. Financial Safe Projection is audience-scoped.
18. Containment/quarantine are defined.
19. Side A relationship is defined.
20. Side B relationship is defined.
21. Side D relationship is defined.
22. Anti-patterns are listed.
23. Coding remains unauthorized.
24. Runtime remains deferred.

---

## 29. Relationship To Previous Documents

This document follows:

- `10110 Store Runtime POS KDS Kitchen Execution Skeleton Policy`

It references:

- `10100 Four-Side Platform Skeleton And Cross-Axis Construction Policy`
- `10030 Domain Object Core Use Case API And Safe Projection Architecture Policy`
- `10040 Domain Capability Control Plane And Runtime Feature Assembly Policy`
- `10044 Mini Kiosk To Full Kiosk CMS Payment And Device Expansion Policy`
- `10048 SaaS Packaging Pricing Boundary And Feature Entitlement Policy`
- `09790 Compensation Review Authority Matrix And Value Recovery Control Policy`
- `09930 Provider Evidence Registry Static Package Handoff And Capability Traceability Policy`
- `10057 Catch Menu Mini Kiosk Foundation Static Authorization Closure And Next Step Deferral Policy`

It prepares:

- `10130 CMS i18n AI pgvector Data Governance Skeleton Policy`
- `10140 Cross-Axis Authority Evidence Audit And Fallback Beam Policy`
- `10150 Four-Side Skeleton Closure And Runtime Deferral Policy`

This document is skeleton planning only.

It does not authorize coding.

---

## 30. Final Rule

Financial Trust is a separate skeleton side.

Payment confirmation, settlement, refund, coupon, point, wallet/prepaid, and compensation value actions must not be inferred from product surfaces, POS acceptance, KDS completion, provider callbacks, staff assist, support review, AI summaries, pgvector similarity, or SaaS package entitlement.

Financial state requires verification, idempotency, reconciliation, evidence, authority, audit, masking, and containment.

Side C is now framed at skeleton level.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
