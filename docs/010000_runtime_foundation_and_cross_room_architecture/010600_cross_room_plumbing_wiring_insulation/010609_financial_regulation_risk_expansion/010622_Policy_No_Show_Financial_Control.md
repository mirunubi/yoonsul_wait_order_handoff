# 010622_Policy_No_Show_Financial_Control

## 1. Purpose

This document defines the No-Show Deposit, Penalty, Abuse Scoring, Booking Circuit Breaker, and Reservation Financial Control Policy.

The previous artifact `10609K` defined remote wait, preorder queue, authorization/capture, NFC/QR physical handshake, and peak traffic control boundaries.

This document adds the reservation and preorder loss-prevention layer for:

1. Takeout preorder no-show prevention.
2. Table reservation / waitlist deposit and cancellation penalty control.
3. Frequent cancellation and no-show abuse scoring.
4. Booking circuit breaker and dynamic reservation throttling.
5. No-show penalty ledger, settlement, and owner projection governance.

The purpose is to protect store inventory, labor, table capacity, and reservation availability while preserving legal fairness, payment correctness, customer notice, refund integrity, and ledger transparency.

This document is planning-only.

It does not authorize coding.

It is not legal, consumer protection, payment, refund, tax, accounting, privacy, platform policy, or card-network advice.

Any no-show deposit, penalty, cancellation fee, deposit capture, customer restriction, blacklist, risk scoring, or differentiated customer treatment must be reviewed by qualified legal, compliance, consumer protection, privacy, PG/VAN, card-network, accounting, and operations experts before implementation.

---

## 2. Core Position

No-show control is financial loss prevention, but it must be governed carefully.

The correct rule is:

Reservation intent is not penalty consent.  
Deposit authorization is not penalty capture.  
No-show penalty is not ordinary food sale.  
Takeout prepared food has different risk than table reservation.  
Customer notice must precede penalty.  
Penalty rule must be policy-versioned.  
AI abuse score is not punishment authority by itself.  
Restriction must be explainable, auditable, and appealable where policy requires.  
No-show revenue must be ledger-separated.  
Cancellation timing must be evidence-based.  
Refund button disabled is not legal compliance.  

The platform must protect merchants without creating unfair, opaque, or legally unsafe customer billing.

---

## 3. No-Show Financial Control Catalog

The following control families are added:

| Control Family | Purpose |
|---|---|
| `TAKEOUT_PREPAY_CAPTURE` | Capture full payment for prepared takeout orders |
| `PICKUP_TIMEOUT_RULE` | Define pickup grace window and no-show transition |
| `NO_SHOW_TERMINATION_STATE` | Close unclaimed prepared orders with evidence |
| `RESERVATION_DEPOSIT_AUTH` | Authorize deposit for table reservation / waitlist |
| `SLIDING_CANCELLATION_PENALTY` | Capture deposit partially or fully based on timing |
| `AUTH_RELEASE_FOR_ALLOWED_CANCEL` | Release deposit authorization when cancellation is allowed |
| `NO_SHOW_PENALTY_LEDGER` | Separate penalty revenue from ordinary sales |
| `ABUSE_SCORE_ENGINE` | Score repeated no-show/cancel behavior |
| `BOOKING_CIRCUIT_BREAKER` | Restrict abusive reservation/preorder behavior |
| `CUSTOMER_NOTICE_AND_APPEAL` | Provide transparent customer-facing policy and review route |

These controls must be contract-, policy-, evidence-, and jurisdiction-aware.

---

## 4. Takeout Preorder Boundary

Takeout preorder is different from table reservation.

Takeout preorder may involve:

- prepared fresh food
- inventory allocation
- kitchen labor
- pickup time commitment
- food safety window
- waste risk
- refund/cancel restrictions after preparation
- pickup identity verification
- customer communication evidence

Takeout preorder may require immediate capture depending on policy and legal review.

Takeout no-show creates product waste, not just unused seat time.

---

## 5. Takeout Payment Capture Boundary

Takeout preorder may use immediate capture only when policy allows.

Immediate capture requires:

- clear customer notice
- order content confirmation
- pickup time confirmation
- cancellation window notice
- preparation start policy
- refund limitation policy
- store acceptance state
- inventory availability
- payment confirmation
- receipt evidence
- tax/accounting treatment review
- dispute handling route

Immediate capture is payment truth candidate.

It still requires acquiring, settlement, and reconciliation.

---

## 6. Takeout Pickup Timeout Boundary

Pickup timeout must be policy-defined.

Timeout policy may include:

- scheduled pickup time
- grace period
- reminder cadence
- store-specific extension
- food safety cutoff
- staff override
- customer contact attempt
- late pickup acceptance policy
- disposal/waste evidence
- no-show termination state
- refund limitation rule

Timeout must be based on recorded time and policy version.

Timeout must not be arbitrary.

---

## 7. Takeout No-Show State Skeleton

Recommended states:

| State | Meaning |
|---|---|
| `TAKEOUT_ORDER_ACCEPTED` | Store accepted takeout order |
| `TAKEOUT_PAYMENT_CAPTURED` | Payment captured |
| `TAKEOUT_PREPARING` | Kitchen preparing |
| `TAKEOUT_READY_FOR_PICKUP` | Ready for pickup |
| `TAKEOUT_PICKUP_WINDOW_ACTIVE` | Pickup window active |
| `TAKEOUT_PICKUP_REMINDER_SENT` | Reminder sent |
| `TAKEOUT_PICKUP_GRACE_ACTIVE` | Grace period active |
| `TAKEOUT_PICKED_UP` | Customer picked up |
| `TAKEOUT_NO_SHOW_CANDIDATE` | Pickup window expired |
| `TAKEOUT_NO_SHOW_TERMINATED` | No-show closed under policy |
| `TAKEOUT_LATE_PICKUP_REVIEW` | Late pickup requires staff decision |
| `TAKEOUT_REFUND_REVIEW_REQUIRED` | Refund exception review |
| `TAKEOUT_DISPUTE_REQUIRED` | Dispute handling required |
| `TAKEOUT_DLQ_REQUIRED` | DLQ isolation required |

No-show termination must not delete the order.

It is a state transition with evidence.

---

## 8. Takeout Ownership And Disposal Evidence Boundary

If policy treats prepared/unclaimed food as customer-responsibility loss, evidence must be preserved.

Evidence may include:

- customer order confirmation
- payment capture evidence
- pickup time
- policy version
- reminder messages
- ready-for-pickup timestamp
- pickup grace end timestamp
- staff confirmation
- food safety/disposal note
- customer communication
- store photo reference if policy allows
- refund exception review
- audit reference

Legal review is required before using ownership-loss or refund-limitation language.

---

## 9. Table Reservation Deposit Boundary

Table reservation deposit is different from takeout capture.

Reservation deposit may use authorization or deposit capture depending on policy and provider rules.

Deposit purpose:

- reserve scarce table capacity
- reduce no-show
- compensate store for lost time slot
- support cancellation fairness
- prevent multi-store reservation abuse

Deposit must have clear policy, customer notice, and cancellation rules.

Deposit is not ordinary meal revenue until capture/settlement treatment is defined.

---

## 10. Reservation Deposit State Skeleton

Recommended states:

| State | Meaning |
|---|---|
| `DEPOSIT_NOT_REQUIRED` | No deposit required |
| `DEPOSIT_AUTH_REQUIRED` | Authorization required |
| `DEPOSIT_AUTH_REQUESTED` | Authorization requested |
| `DEPOSIT_AUTH_APPROVED` | Authorization approved |
| `DEPOSIT_AUTH_DECLINED` | Authorization declined |
| `DEPOSIT_AUTH_UNKNOWN` | Provider state unknown |
| `DEPOSIT_RELEASE_REQUIRED` | Release required |
| `DEPOSIT_RELEASE_CONFIRMED` | Release confirmed |
| `DEPOSIT_CAPTURE_CANDIDATE` | Penalty/deposit capture candidate |
| `DEPOSIT_PARTIAL_CAPTURED` | Partial capture confirmed |
| `DEPOSIT_FULL_CAPTURED` | Full capture confirmed |
| `DEPOSIT_REFUND_REQUIRED` | Refund required |
| `DEPOSIT_DISPUTE_REQUIRED` | Dispute handling required |
| `DEPOSIT_RECONCILIATION_REQUIRED` | Reconciliation required |
| `DEPOSIT_DLQ_REQUIRED` | DLQ isolation required |

Deposit lifecycle must be separate from meal payment lifecycle.

---

## 11. Sliding Cancellation Penalty Boundary

Sliding penalty may depend on cancellation timing.

Example policy structure:

| Cancellation Timing | Candidate Treatment |
|---|---|
| Before free-cancel deadline | Full authorization release or full refund |
| Within intermediate window | Partial deposit capture if legally/policy allowed |
| Same-day cancellation | Higher capture or penalty if allowed |
| No-show after grace window | Full deposit capture if allowed |
| Store-caused cancellation | Full release/refund and possibly compensation |
| Force majeure / exceptional reason | Review route |

Exact percentages, times, and terms require legal and operations review.

This document does not approve any specific penalty rate.

---

## 12. Cancellation Timestamp Evidence Boundary

Cancellation penalty requires reliable timestamp evidence.

Evidence must include:

- reservation id
- customer request timestamp
- server received timestamp
- reservation time
- store local time zone
- business date
- cancellation policy version
- customer notice version
- provider auth/capture state
- prior reminders
- staff override if any
- audit reference

Device local time alone is insufficient.

Server timestamp and policy version are required.

---

## 13. Reservation No-Show Boundary

Reservation no-show may occur when:

- customer does not arrive within grace period
- customer fails NFC/QR/table check-in
- customer ignores arrival reminder
- customer cancels after cutoff
- staff marks no-show with evidence
- table was held and unavailable to others

No-show must be evidence-based.

No-show must not be inferred from a single weak signal if the customer may have arrived through another route.

---

## 14. Reservation No-Show Evidence Packet

Reservation no-show evidence packet may include:

- reservation id
- customer pseudonym
- reservation time
- arrival window
- grace period
- reminder messages
- check-in attempts
- NFC/QR arrival evidence or absence
- staff no-show confirmation
- table hold evidence
- cancellation attempts
- deposit authorization evidence
- capture decision
- customer notice version
- audit reference

Evidence supports penalty, dispute defense, and merchant trust.

---

## 15. Penalty Capture Boundary

Penalty capture must be state-controlled.

Before penalty capture:

- policy must allow capture
- customer must have accepted terms
- deposit authorization or payment route must exist
- timing rule must match
- no-show/cancel evidence must exist
- store-caused failure must be excluded
- provider route must be available
- idempotency must be enforced
- amount must be fixed-point
- capture result must be provider-verified
- audit must be recorded

Penalty capture requested is not penalty captured.

---

## 16. Penalty Ledger Boundary

Penalty revenue must be ledger-separated.

Ledger categories may include:

- ordinary food/beverage sales
- takeout captured sales
- reservation deposit capture
- no-show penalty
- cancellation penalty
- platform fee on penalty if legally allowed
- store compensation amount
- refunded deposit
- disputed penalty
- penalty reversal

No-show penalty must not be hidden inside ordinary menu sales.

Tax/accounting treatment requires expert review.

---

## 17. Penalty Settlement Formula Boundary

Owner projection may use a formula such as:

    Merchant payout candidate =
      ordinary fulfilled sales
      + takeout captured sales
      + approved no-show/cancellation penalty
      - refunds and releases
      - platform fees
      - provider fees
      - holds and disputes

This formula is only a projection structure.

Exact legal, tax, and accounting treatment must be reviewed.

---

## 18. Abuse Scoring Boundary

Abuse scoring may detect repeated harmful behavior.

Signals may include:

- no-show count
- same-day cancellation count
- late cancellation count
- repeated multi-store booking
- repeated preorder abandonment
- deposit authorization failure
- chargeback/dispute after no-show penalty
- QR/NFC arrival mismatch
- bot-like booking pattern
- repeated booking and cancellation within short windows
- queue hoarding
- repeated no-show during peak time
- device/session anomaly

Abuse score is advisory unless policy converts it into a rule through approved governance.

---

## 19. Abuse Score State Skeleton

Recommended states:

| State | Meaning |
|---|---|
| `ABUSE_SCORE_NORMAL` | Normal risk |
| `ABUSE_SCORE_WATCH` | Watch state |
| `ABUSE_SCORE_ELEVATED` | Elevated risk |
| `ABUSE_SCORE_HIGH_RISK` | High risk |
| `ABUSE_REVIEW_REQUIRED` | Human review required |
| `ABUSE_RESTRICTION_CANDIDATE` | Restriction candidate |
| `ABUSE_RESTRICTION_ACTIVE` | Restriction active under policy |
| `ABUSE_RESTRICTION_EXPIRED` | Restriction expired |
| `ABUSE_APPEAL_REVIEW` | Appeal or correction review |
| `ABUSE_FALSE_POSITIVE` | False positive closed |

Risk score must not become irreversible blacklist without governance.

---

## 20. Booking Circuit Breaker Boundary

Booking circuit breaker limits risky reservation behavior.

Possible actions:

- require deposit
- increase deposit within legal/policy limits
- restrict same-day remote wait
- restrict multiple concurrent bookings
- require stronger identity verification
- require phone/app confirmation
- require staff approval
- cooldown period
- show warning
- route to manual review
- deny booking temporarily if policy allows

Actions must be proportionate, transparent, and appealable where required.

---

## 21. Dynamic Deposit Boundary

Dynamic deposit may depend on risk but must be governed.

Risk-based deposit changes require:

- legal review
- customer notice
- policy version
- non-discrimination review
- privacy review
- explanation rule
- maximum cap
- expiration
- appeal/review route
- audit

Dynamic deposit must not be arbitrary or discriminatory.

---

## 22. Customer Restriction Boundary

Customer restrictions may affect access to:

- remote wait
- same-day reservation
- preorder
- peak-time booking
- deposit-free booking
- multi-store reservation
- reservation modification
- cancellation convenience

Restriction must not block lawful rights or required customer support routes.

Restriction must be transparent enough for customer trust.

---

## 23. Privacy And Fairness Boundary

Abuse scoring and booking restrictions involve customer behavior data.

Privacy/fairness controls must include:

- data minimization
- pseudonymization where possible
- retention limit
- purpose limitation
- no raw sensitive data in AI prompt
- explanation policy
- false-positive review
- bias/fairness review
- access audit
- deletion/anonymization policy where applicable

Behavioral risk control must not become uncontrolled surveillance.

---

## 24. AI Abuse Detection Boundary

AI may assist abuse detection.

AI may identify:

- repeated cancellation patterns
- suspicious multi-store booking
- no-show clusters
- bot-like behavior
- table hoarding
- deposit avoidance
- chargeback after penalty pattern
- store-specific abuse trend

AI must not autonomously impose high-impact penalties or long restrictions without approved deterministic policy or human review.

---

## 25. Store Abuse Protection Boundary

Stores also need controls to prevent misuse.

Store-side abuse may include:

- falsely marking no-show
- imposing penalty despite store delay
- refusing valid cancellation
- failing to update table availability
- marking ready-for-pickup too early
- using no-show penalties as revenue tool
- inconsistent staff overrides

No-show governance protects both store and customer.

Store actions must be audited.

---

## 26. Customer Notice Boundary

Customer-facing no-show/cancel policy must be explicit.

Notice should include:

- deposit amount
- authorization or capture type
- cancellation deadline
- partial penalty rule
- no-show definition
- arrival grace period
- pickup grace period
- refund/release rule
- appeal/support route
- exceptional circumstance route
- store-specific policy if applicable

Notice version must be recorded.

No penalty should be applied without traceable notice.

---

## 27. Dispute And Appeal Boundary

Customer may dispute penalty.

Dispute/appeal process must support:

- customer claim intake
- evidence bundle review
- store evidence review
- policy version check
- payment state check
- refund/release decision
- reversal/amendment if needed
- CS explanation
- audit
- owner projection update

Appeal is not automatic refund.

Appeal result must be evidence-linked.

---

## 28. No-Show Evidence Packet

No-show evidence packet may include:

- reservation/preorder id
- customer pseudonym
- store id
- policy version
- customer notice version
- deposit/payment state
- pickup/reservation time
- grace period
- reminders
- arrival/NFC/QR evidence
- staff confirmation
- kitchen/preparation status
- table hold status
- cancellation timestamp
- penalty capture state
- dispute/appeal state
- audit reference

Evidence packet supports settlement and dispute handling.

---

## 29. No-Show Batch Reconciliation Boundary

Nightly batch must reconcile no-show-related records.

Batch checks:

- deposit authorizations
- deposit releases
- penalty captures
- takeout captures
- no-show terminations
- cancellation timestamps
- provider states
- settlement states
- refund/reversal states
- dispute holds
- penalty ledger
- owner projection
- tax/accounting flags
- DLQ records

No-show penalty must not bypass financial reconciliation.

---

## 30. No-Show Penalty Account Boundary

Accounting may require a separate no-show/penalty account.

Candidate accounts:

- `TAKEOUT_SALES_CAPTURED`
- `RESERVATION_DEPOSIT_AUTHORIZED`
- `RESERVATION_DEPOSIT_RELEASED`
- `NO_SHOW_PENALTY_CAPTURED`
- `CANCELLATION_PENALTY_CAPTURED`
- `PENALTY_REFUND_OR_REVERSAL`
- `PENALTY_DISPUTED`
- `PENALTY_PLATFORM_FEE`
- `PENALTY_STORE_PAYABLE`

Exact account treatment must be accounting/tax reviewed.

---

## 31. Owner Projection Boundary

Owner dashboard must show:

- fulfilled sales
- takeout no-show closed amount
- reservation penalty amount
- canceled with release amount
- pending deposit amount
- disputed penalty amount
- abuse-related blocked bookings
- no-show rate
- cancellation rate
- recovered loss estimate
- refund/reversal after appeal
- platform fee
- net payout impact

Owner projection must separate penalty from ordinary sales.

---

## 32. Relationship To Remote Wait And Preorder

This document extends `10609K` by adding:

- takeout immediate capture rules
- reservation deposit lifecycle
- no-show termination
- sliding cancellation penalty
- abuse scoring
- booking circuit breaker
- no-show penalty ledger
- appeal and dispute handling

Remote wait/preorder flow must not treat no-show control as an afterthought.

---

## 33. Relationship To Financial Trust

Financial Trust must enforce:

- deposit authorization/capture separation
- takeout immediate capture state
- penalty capture idempotency
- auth release reconciliation
- no-show penalty ledger
- dispute hold
- refund/reversal amendment
- fixed-point calculation
- provider reconciliation
- settlement projection

Financial Trust must not mix penalty revenue silently with ordinary sales.

---

## 34. Relationship To Store Runtime

Store Runtime must provide:

- pickup ready state
- pickup timeout evidence
- staff no-show confirmation
- table hold evidence
- arrival/NFC/QR evidence
- cancellation acceptance state
- store-caused delay marker
- preparation status
- staff override audit

Store Runtime evidence is required before penalty where policy demands it.

---

## 35. Relationship To Data Governance

Data Governance must control:

- no-show policy messages
- customer notices
- abuse score visibility
- customer restriction messages
- owner projection
- CS evidence timeline
- privacy limits
- behavioral data retention
- AI output boundary
- i18n keys
- evidence export

Customer risk data is sensitive.

It must be scoped and minimized.

---

## 36. Relationship To Security Agent

Security Agent may detect:

- reservation bot abuse
- repeated no-show pattern
- multi-store hoarding
- abuse of cancellation window
- store-side false no-show pattern
- penalty capture anomaly
- deposit authorization attack
- QR/NFC arrival fraud
- chargeback after penalty pattern
- customer restriction evasion

Security Agent may alert or contain.

It must not finalize customer guilt or legal penalty.

---

## 37. Relationship To Cross-Room Plumbing

Future event routing must carry:

- reservation id
- preorder id
- deposit authorization id
- penalty capture id
- auth release id
- cancellation policy id
- no-show policy id
- customer notice version
- pickup timeout id
- arrival evidence id
- abuse score id
- booking circuit breaker state
- appeal/dispute id
- no-show evidence packet id
- penalty ledger id
- owner projection id

These become context envelope and evidence packet candidates.

---

## 38. Anti-Patterns

Avoid:

- penalty without clear customer notice
- treating no-show penalty as ordinary sales without separate ledger
- immediate capture for reservation deposit without legal review
- using AI score alone to impose heavy restriction
- permanent blacklist without review or expiration
- dynamic deposit without fairness/privacy review
- disabling refund button as substitute for legal policy
- store manually marking no-show without evidence
- geofence absence treated as no-show proof
- penalty capture without idempotency
- no-show capture not reconciled with provider
- appeal/refund handled by direct mutation
- hiding penalty disputes from owner projection
- using abuse score across tenants without lawful/policy basis

These anti-patterns must be blocked in future runtime design.

---

## 39. Runtime Deferral

This document defines no-show deposit, penalty, abuse scoring, booking circuit breaker, and reservation financial control boundaries only.

It does not authorize:

- no-show penalty implementation
- reservation deposit implementation
- takeout immediate capture runtime
- cancellation penalty runtime
- AI abuse scoring
- blacklist/restriction system
- booking circuit breaker
- customer notice UI
- appeal workflow
- no-show ledger table
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 40. Validation Checklist

Validation must confirm:

1. No-show financial control catalog is defined.
2. Takeout preorder boundary is defined.
3. Takeout payment capture boundary is defined.
4. Takeout pickup timeout boundary is defined.
5. Takeout no-show state skeleton is defined.
6. Takeout ownership/disposal evidence boundary is defined.
7. Table reservation deposit boundary is defined.
8. Reservation deposit state skeleton is defined.
9. Sliding cancellation penalty boundary is defined.
10. Cancellation timestamp evidence boundary is defined.
11. Reservation no-show boundary is defined.
12. Reservation no-show evidence packet is defined.
13. Penalty capture boundary is defined.
14. Penalty ledger boundary is defined.
15. Penalty settlement formula boundary is defined.
16. Abuse scoring boundary is defined.
17. Abuse score state skeleton is defined.
18. Booking circuit breaker boundary is defined.
19. Dynamic deposit boundary is defined.
20. Customer restriction boundary is defined.
21. Privacy/fairness boundary is defined.
22. AI abuse detection boundary is defined.
23. Store abuse protection boundary is defined.
24. Customer notice boundary is defined.
25. Dispute/appeal boundary is defined.
26. No-show evidence packet is defined.
27. No-show batch reconciliation boundary is defined.
28. No-show penalty account boundary is defined.
29. Owner projection boundary is defined.
30. Relationships to Remote Wait/Preorder, Financial Trust, Store Runtime, Data Governance, Security Agent, and Cross-Room Plumbing are defined.
31. Anti-patterns are listed.
32. Coding remains unauthorized.
33. Runtime remains deferred.

---

## 41. Relationship To Previous Documents

This document supplements:

- `10609K Remote Wait Preorder Queue Authorization Capture NFC Handshake And Peak Traffic Control Policy`

It references:

- `10210 Order Intake Room Boundary Policy`
- `10220 Order Validation Room Boundary Policy`
- `10250 Kitchen Execution Room Boundary Policy`
- `10330 Fulfillment Visibility Room Boundary Policy`
- `10400~10480 Financial Trust Room Framing Sequence`
- `10530 Safe Projection Masking And Audience Visibility Boundary Policy`
- `10540 AI Advisory Runtime And Non-Authority Boundary Policy`
- `10580 Data Governance Closure And Cross-Room Handoff Policy`
- `10600 Cross-Room Plumbing Wiring Insulation Planning Index`
- `10608 Pseudonymized AI Analysis Noisy Neighbor Control Nonce Idempotency And Final SaaS Edge Guard Policy`
- `10609K Remote Wait Preorder Queue Authorization Capture NFC Handshake And Peak Traffic Control Policy`

It prepares:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- future no-show deposit policy review packet
- future cancellation penalty legal review packet
- future booking circuit breaker specification
- future abuse scoring privacy/fairness packet
- future no-show evidence packet
- future reservation/preorder financial control specification

This document is architecture boundary planning only.

It does not authorize coding.

---

## 42. Final Rule

No-show prevention must protect merchant assets without weakening customer fairness, payment correctness, or ledger integrity.

Takeout prepared-food no-show, table reservation no-show, remote wait abandonment, late cancellation, and abusive repeated booking are different cases and require different states, evidence, payment treatment, and customer notice.

Deposit authorization is not penalty capture.

Penalty capture must be policy-based, customer-noticed, idempotent, provider-verified, evidence-linked, ledger-separated, and dispute-capable.

AI may detect abuse patterns, but high-impact restrictions require governed policy, privacy controls, fairness review, expiration, and appeal/review route where required.

No-show penalty revenue must be separated from ordinary sales and reconciled through the financial batch system.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
