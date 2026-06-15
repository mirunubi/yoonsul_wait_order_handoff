# 22350_Policy_Payment_KDS_Provider_Adapter_Package_Planning

## 1. Purpose

This document defines the planning boundary for payment, KDS, and external provider adapter packages before controlled implementation begins.

The purpose is to prevent provider assumptions, hidden payment authority, KDS authority drift, unaudited callbacks, hardcoded provider messages, and premature adapter coding.

Payment, KDS, and provider adapters are integration boundaries.

They must be planned as controlled runtime contracts before any SQL, API handler, Edge Function, Flutter UI, React UI, webhook, SDK integration, or provider-specific implementation is created.

---

## 2. Scope

This policy applies to the following adapter package families:

1. Payment provider adapters
2. Split payment adapters
3. Refund request and refund execution adapters
4. Settlement and reconciliation adapters
5. POS payment event adapters
6. KDS provider adapters
7. KDS bridge adapters
8. POS-to-KDS handoff adapters
9. External menu projection provider adapters
10. Redtable-type partner adapters
11. Global payment candidate adapters
12. Provider callback normalization adapters
13. Provider capability registry adapters
14. Provider evidence review packages

This document does not implement any provider API, webhook, SDK, callback parser, payment flow, KDS connector, or external projection connector.

Coding remains deferred.

---

## 3. Core Principle

Provider adapter planning must separate four things:

1. What the business wants
2. What the architecture allows
3. What the provider actually supports
4. What has been verified by evidence

A desired capability is not an available capability.

A provider marketing page is not enough.

A UI label is not evidence.

A callback is not final settlement.

A KDS event is not payment authority.

A payment provider event is not kitchen execution authority.

---

## 4. Provider Evidence First Rule

No provider capability may be treated as available until evidence is confirmed.

Every provider capability must start with one of the following statuses:

| Status | Meaning |
|---|---|
| `CAPABILITY_NOT_PLANNED` | Not part of current plan |
| `CAPABILITY_PLANNED` | Planned conceptually |
| `CAPABILITY_PROVIDER_EVIDENCE_REQUIRED` | Provider evidence missing |
| `CAPABILITY_CONFIRMED` | Evidence verified |
| `CAPABILITY_LIMITED` | Supported only with constraints |
| `CAPABILITY_REJECTED` | Not supported or unsuitable |
| `CAPABILITY_DEPRECATED` | Previously supported but no longer valid |

Default status for external claims:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

---

## 5. Provider Evidence Requirements

A provider capability may be upgraded only when evidence exists for the relevant category.

Evidence categories include:

- official API documentation
- webhook/callback documentation
- sandbox access confirmation
- production access condition
- commercial agreement
- settlement rule
- refund rule
- cancellation rule
- dispute/chargeback rule
- supported payment method
- supported locale
- supported currency
- supported country
- supported menu projection method
- supported QR/NFC/Google Maps entry method
- data retention rule
- privacy/security requirement
- rate limit
- SLA/support channel
- certification requirement
- legal/compliance boundary

If evidence is incomplete, the capability remains limited or evidence-required.

---

## 6. Adapter Planning Record

Each adapter package must define:

| Field | Required Meaning |
|---|---|
| Adapter package name | Stable planning identifier |
| Provider | External or internal provider name |
| Runtime domain | Payment, KDS, POS, menu projection, support, AI, etc. |
| Capability family | What the adapter claims to support |
| Evidence status | Confirmed, limited, required, rejected |
| Authority boundary | What the adapter may and may not do |
| Input contract | API/RPC/event contract dependency |
| Output contract | Normalized event/result family |
| Callback behavior | If provider sends asynchronous response |
| Audit requirement | Required audit event |
| i18n requirement | Message key/content key for visible states |
| Error mapping | Provider error to internal error code |
| Fallback behavior | Degraded/manual/retry/blocked |
| Data retention | Provider-side and internal retention boundary |
| Coding status | Planned only / blocked / ready later |

---

## 7. Payment Adapter Boundary

Payment adapters must preserve payment authority separation.

Payment adapters may handle:

- payment intent creation
- payment request submission
- payment authorization response
- payment capture response
- payment failure response
- cancellation response
- refund request response
- provider callback normalization
- reconciliation candidate creation
- settlement evidence capture

Payment adapters must not independently decide:

- refund approval
- customer compensation
- final settlement allocation
- legal conclusion
- support case resolution
- menu/order mutation
- KDS completion
- owner payout finalization

Payment provider responses are evidence.

They are not universal business approval.

---

## 8. Payment State Mapping

Payment adapter planning must distinguish at least the following state families:

- `PAYMENT_INTENT_CREATED`
- `PAYMENT_REQUESTED`
- `PAYMENT_AUTH_PENDING`
- `PAYMENT_AUTHORIZED`
- `PAYMENT_CAPTURED`
- `PAYMENT_FAILED`
- `PAYMENT_CANCEL_REQUESTED`
- `PAYMENT_CANCELLED`
- `REFUND_REQUESTED`
- `REFUND_APPROVAL_REQUIRED`
- `REFUND_APPROVED`
- `REFUND_EXECUTION_REQUESTED`
- `REFUND_EXECUTED`
- `REFUND_FAILED`
- `SETTLEMENT_PENDING`
- `SETTLEMENT_RECONCILIATION_REQUIRED`
- `PROVIDER_CALLBACK_DELAYED`
- `PROVIDER_STATE_UNCERTAIN`

Actual enum/table/function implementation is deferred.

---

## 9. Split Payment Boundary

Split payment adapters must preserve the distinction between:

- table identity
- customer identity
- order identity
- payment identity
- partial payment
- full settlement
- unresolved balance
- refund target
- provider transaction id
- internal settlement id

Split payment must not fragment the kitchen order unless the POS/KDS contract explicitly requires it.

One table may have many customers.

One order may have many payment contributors.

One payment may cover partial order value.

One provider callback may not be enough to finalize table settlement.

---

## 10. Refund Boundary

Refund handling must be separated into stages:

1. refund request
2. evidence collection
3. authority review
4. approval or rejection
5. provider execution request
6. provider execution result
7. customer-facing message
8. audit event
9. settlement reconciliation

Provider refund execution does not replace internal approval policy.

Support UI must not directly execute refunds unless the contract grants authority and audit/evidence requirements are satisfied.

---

## 11. Settlement And Reconciliation Boundary

Settlement adapter planning must distinguish:

- provider payment event
- internal order value
- discount/coupon value
- platform fee
- payment fee
- delivery/partner fee if any
- franchise fee if any
- owner/store allocation
- HQ allocation
- refund adjustment
- chargeback/dispute adjustment
- delayed payout
- reconciliation exception

Settlement is not the same as payment success.

Settlement finalization requires reconciliation policy.

---

## 12. KDS Adapter Boundary

KDS adapters must preserve the kitchen execution boundary.

KDS adapters may handle:

- ticket creation request
- ticket routing
- ticket display
- station assignment
- acknowledgement
- preparation state update
- delay marker
- remake marker
- completion marker
- cancellation marker
- degraded/manual kitchen note projection

KDS adapters must not decide:

- payment approval
- refund approval
- final customer settlement
- customer identity authority
- provider payment state
- legal/customer compensation
- menu source-of-truth changes

KDS is operational execution evidence.

KDS is not financial authority.

---

## 13. POS To KDS Handoff Boundary

POS-to-KDS handoff adapters must distinguish:

- POS accepted order
- kitchen ticket candidate
- ticket creation
- ticket routing
- KDS acknowledgement
- kitchen preparation start
- preparation completion
- exception/remake/delay
- cancellation propagation
- degraded/manual fallback

POS accepted order does not automatically equal kitchen completion.

KDS completion does not automatically equal payment settlement.

---

## 14. KDS Bridge Degraded Boundary

KDS bridge adapters must explicitly handle degraded states.

Degraded states include:

- provider unavailable
- POS event delayed
- KDS event delayed
- duplicate ticket risk
- stale ticket state
- station routing failure
- manual kitchen note required
- local cache uncertain
- replay required
- reconciliation required

A degraded KDS bridge must not silently merge uncertain states.

Uncertainty must be visible to the proper staff/admin surface.

---

## 15. Provider Callback Boundary

Provider callbacks must be normalized through controlled contracts.

A provider callback must define:

- provider source
- callback type
- provider event id
- provider timestamp
- received timestamp
- signature/security verification status
- related internal contract
- related payment/order/ticket/menu projection id
- idempotency key
- replay behavior
- duplicate handling
- error mapping
- audit event
- reconciliation requirement

Unsigned, unverified, delayed, or ambiguous callbacks must not mutate final state silently.

---

## 16. Idempotency Rule

All payment, KDS, and provider callback adapters must be planned as idempotent.

Planning must define:

- idempotency key source
- duplicate detection rule
- retry behavior
- provider retry behavior
- internal replay behavior
- conflict resolution rule
- audit event for duplicate/conflict
- final state protection

Retries must not create duplicate charges, duplicate refunds, duplicate kitchen tickets, duplicate projections, or duplicate support actions.

---

## 17. Error Mapping Rule

Provider errors must be mapped to internal error contracts.

Provider error text must not be shown directly to customers.

Each error mapping must define:

- provider error code
- internal error code
- user-facing message key
- staff-facing message key
- support-facing diagnostic key
- severity
- retryability
- escalation condition
- provider evidence requirement
- audit requirement
- fallback instruction

Hardcoded provider error messages are prohibited.

---

## 18. i18n And Content Rule

All provider, payment, and KDS visible states must use i18n/message keys or content registry keys.

This includes:

- payment success/failure
- refund status
- split payment status
- settlement pending status
- KDS ticket status
- kitchen delay message
- provider unavailable message
- external projection status
- capability unavailable message
- foreigner-facing menu/payment text
- support/admin warning text

Provider-specific labels must not bypass i18n.

---

## 19. External Menu Projection Adapter Boundary

External menu projection adapters apply to:

- QR menu projection
- NFC menu projection
- Google Maps-linked menu projection
- partner menu board projection
- foreign-language menu projection
- Redtable-type partner projection
- tourism-facing ordering projection

Projection adapters must preserve:

- internal menu source
- content registry key
- locale
- translation source
- price source
- availability source
- allergen source
- image source
- version
- rollback version
- provider capability status
- publication timestamp
- projection target

External provider projection must not become the menu source of truth.

---

## 20. Redtable-Type Partner Adapter Boundary

Redtable-type partner adapters are planning candidates for foreigner-facing menu projection and global payment bridge.

Candidate capabilities may include:

- foreigner menu translation
- external menu projection
- Google Maps-linked discovery
- QR entry
- NFC entry
- tourism-friendly ordering
- global payment bridge
- Alipay candidate support
- WeChat Pay candidate support
- overseas card candidate support
- partner-side menu board projection

However, all of the following remain evidence-required:

- actual Redtable API availability
- API endpoint structure
- sandbox access
- production access
- Alipay support
- WeChat Pay support
- overseas card support
- payment settlement terms
- refund responsibility
- customer identity sharing
- content ownership
- translation responsibility
- data retention
- rate limits
- fee/commission model
- Google Maps linkage method
- NFC/QR projection method
- support responsibility
- legal/compliance boundary

Default status:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

---

## 21. Global Payment Candidate Boundary

Global payment candidate adapters must not assume availability of:

- overseas card support
- dynamic currency conversion
- Alipay
- WeChat Pay
- UnionPay
- Apple Pay
- Google Pay
- tourist payment flow
- foreign identity handling
- cross-border settlement
- multilingual receipt support
- refund to overseas payment method

Each must be separately verified by provider evidence.

Global payment UI must display only confirmed or clearly marked candidate capability.

---

## 22. Security Boundary

Provider adapters must define security requirements before implementation.

Planning must include:

- authentication method
- API key/secret storage boundary
- webhook signature verification
- transport security
- request signing if required
- replay protection
- IP allowlist if required
- rate limit
- provider credential rotation
- least privilege
- audit of credential use
- test/sandbox vs production separation
- secret exposure prevention

Secrets must never be embedded in UI, mobile app, static content, or documentation examples.

---

## 23. Data Boundary

Provider adapters must define what data leaves the internal system.

Planning must identify:

- customer data sent
- order data sent
- payment data sent
- menu data sent
- staff/admin data sent
- store data sent
- device/session data sent
- locale data sent
- analytics data sent
- support case data sent

Data minimization is required.

Provider-side data retention must be reviewed before coding.

---

## 24. Audit Boundary

Adapter actions must be auditable when they carry operational, financial, support, or external projection impact.

Audit planning must define:

- actor or system actor
- provider
- capability
- request id
- callback id
- internal correlation id
- previous state
- requested state
- accepted state
- rejected state
- evidence reference
- retry/replay record
- degraded state
- reconciliation requirement

Provider adapter audit is mandatory for payment, refund, settlement, KDS exception, and external projection publication.

---

## 25. Adapter Naming Rule

Adapter package planning identifiers should follow:

`adapter.<provider_or_domain>.<capability>.<version>`

Examples:

- `adapter.payment.intent_create.v1`
- `adapter.payment.refund_execute.v1`
- `adapter.payment.callback_normalize.v1`
- `adapter.kds.ticket_route.v1`
- `adapter.kds.bridge_degraded_sync.v1`
- `adapter.pos.kds_handoff.v1`
- `adapter.partner.redtable.menu_projection.v1`
- `adapter.partner.redtable.global_payment_candidate.v1`
- `adapter.provider.capability_registry.v1`

These identifiers are planning names only.

They do not imply implementation exists.

---

## 26. Adapter Readiness Levels

Each adapter package must have a readiness status.

| Status | Meaning |
|---|---|
| `ADAPTER_IDEA` | Candidate only |
| `ADAPTER_PLANNED` | Boundary described |
| `ADAPTER_PROVIDER_EVIDENCE_REQUIRED` | Provider support not confirmed |
| `ADAPTER_SECURITY_REVIEW_REQUIRED` | Security boundary incomplete |
| `ADAPTER_I18N_REQUIRED` | Message/content keys missing |
| `ADAPTER_AUDIT_REQUIRED` | Audit lineage incomplete |
| `ADAPTER_RECONCILIATION_REQUIRED` | Financial reconciliation boundary incomplete |
| `ADAPTER_READY_FOR_IMPLEMENTATION_PLANNING` | Ready for package planning, not coding |
| `ADAPTER_CODING_ALLOWED` | Only after explicit coding entry approval |

Default status for this phase:

`ADAPTER_PLANNED`

External provider capability default:

`ADAPTER_PROVIDER_EVIDENCE_REQUIRED`

Coding is not allowed by this document.

---

## 27. Prohibited Adapter Shortcuts

The following are prohibited:

1. Coding provider adapters before provider evidence exists
2. Treating payment success as final settlement
3. Treating provider callback as final truth without verification
4. Showing raw provider errors to customers
5. Hardcoding payment/KDS/provider messages
6. Creating refund execution without approval boundary
7. Letting KDS mutate payment or settlement authority
8. Letting payment mutate kitchen execution authority
9. Creating duplicate tickets or charges through retries
10. Skipping idempotency planning
11. Skipping webhook signature verification planning
12. Exposing secrets in UI/mobile/static content
13. Treating Redtable-type capabilities as confirmed without evidence
14. Treating external menu projection as menu source of truth
15. Bypassing audit for provider-impacting actions
16. Coding global payment support from assumption
17. Hiding provider degraded state from staff/admin/support surfaces

---

## 28. Minimum Adapter Planning Checklist

Before any payment, KDS, or provider adapter package proceeds, the following must be answered:

- What provider or domain does this adapter belong to?
- What capability is being claimed?
- What evidence confirms the capability?
- What remains evidence-required?
- What authority does the adapter have?
- What authority is explicitly prohibited?
- What API/RPC/event contract does it depend on?
- What callback behavior exists?
- What idempotency rule applies?
- What error mapping applies?
- What i18n/message keys are required?
- What content registry keys are required?
- What audit event is required?
- What security requirement applies?
- What data leaves the system?
- What fallback/degraded behavior applies?
- What reconciliation rule applies?
- What coding entry status applies?

If any answer is missing, the adapter remains planning-only.

---

## 29. Relationship To Previous Documents

This document follows:

- `22023_Index_Controlled_Implementation_Planning_README_And_Package_Decomposition`
- `22024_Policy_Runtime_Package_Decomposition_And_Module_Boundary_Planning`
- `22025_Policy_Data_Model_Planning_Boundary_And_Schema_Design_Readiness`
- `22330 API RPC Event Contract Planning Boundary Policy`
- `22340 UI Implementation Package Planning And I18n Surface Mapping Policy`

This document prepares the boundary for:

- `22360 Support Admin Evidence Audit Package Planning Policy`
- `22370 AI Support Gateway pgvector RAG Package Planning Policy`
- `22380 External Menu Projection Redtable Partner Package Planning Policy`
- `22390 Controlled Implementation Planning Closure And Coding Entry Deferral Policy`

---

## 30. Final Rule

Payment, KDS, and provider adapters are not convenience connectors.

They are authority-sensitive integration boundaries.

At this stage, the correct output is not provider code.

The correct output is a controlled adapter package map that separates desired capability from verified capability, payment from settlement, KDS execution from financial authority, provider callback from final truth, and external projection from source-of-truth content.

Coding remains deferred until provider evidence, contract readiness, i18n/content readiness, security review, audit lineage, idempotency, reconciliation, and explicit package entry gates are approved.
