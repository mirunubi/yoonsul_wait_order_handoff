# 021500_Policy_Financial_Security_Ledger_Foundation_Catalog_And_Status_Value_Addendum

## 1. Purpose

This document defines the foundation catalog addendum required after introducing the external POS financial security and settlement isolation reinforcement.

The purpose is to ensure that the financial-grade concepts introduced in `22490` are not left as narrative architecture only.

They must be reflected into controlled foundation catalogs, status values, capability registries, audit/evidence families, contract families, and readiness blockers before any external POS, payment, settlement, or provider adapter implementation begins.

This document does not authorize coding.

Coding remains deferred unless a specific package has `CODING_ALLOWED`, a completed handoff record, a narrow work order, required tests, and review approval.

---

## 2. Scope

This addendum applies to future foundation catalog entries for:

1. External POS trust classification
2. POS sandbox requirement
3. Tokenization requirement
4. Plain text sensitive data prohibition
5. Encrypted communication requirement
6. Provider callback verification
7. Payment gateway separation
8. Double-entry ledger requirement
9. Immutable append-only ledger requirement
10. Settlement async processing
11. Reconciliation exception tracking
12. Exchange-rate evidence requirement
13. Multi-party settlement routing
14. Partner revenue share settlement
15. Franchise royalty settlement
16. AI/pgvector financial anomaly assistance boundary
17. Patent reinforcement metadata
18. Financial security readiness blockers

This document updates the planning expectations for the foundation catalogs but does not create runtime schema or implementation.

---

## 3. Core Principle

Financial-grade POS/payment/settlement architecture must become controlled catalog vocabulary before implementation.

If a concept affects money, settlement, provider callbacks, customer identity, external POS trust, or partner revenue share, it must not remain informal.

It must be represented as:

- status value
- catalog family
- contract family
- audit family
- evidence family
- security classification
- readiness blocker
- provider evidence requirement
- test/check requirement

Uncataloged financial authority is prohibited.

---

## 4. Required Catalog Families

The following foundation catalog families must be extended or prepared.

| Catalog Family | Required Addition |
|---|---|
| `foundation.status.value_catalog.v1` | Financial security and ledger statuses |
| `foundation.provider.capability_registry.v1` | Payment/settlement/provider evidence statuses |
| `foundation.contract.catalog.v1` | POS/payment/ledger/reconciliation contract families |
| `foundation.event.family_catalog.v1` | Payment, callback, ledger, reconciliation events |
| `foundation.audit.event_catalog.v1` | Financial authority and correction audit families |
| `foundation.evidence.packet_catalog.v1` | Provider callback, ledger, settlement evidence |
| `foundation.security.visibility_catalog.v1` | POS-limited trust and financial data classes |
| `foundation.degraded.state_catalog.v1` | Callback delayed, settlement uncertain, reconciliation required |
| `foundation.ai.source_output_catalog.v1` | Financial anomaly assistance boundaries |
| `foundation.readiness.blocker_inventory.v1` | Financial security blockers |
| `foundation.boundary.test_catalog.v1` | Ledger/security/provider validation tests |

---

## 5. Financial Security Status Values

The status catalog must include financial security statuses.

| Status | Meaning | Default Use |
|---|---|---|
| `POS_TRUST_LIMITED` | External POS is a limited-trust environment | External POS integration |
| `POS_SANDBOX_REQUIRED` | POS module must operate under sandbox boundary | Third-party POS module |
| `TOKENIZATION_REQUIRED` | Sensitive references must be tokenized | Payment/customer/provider/settlement data |
| `PLAINTEXT_STORAGE_PROHIBITED` | Sensitive data must not be stored as plain text | POS, logs, cache, QR/NFC, docs |
| `ENCRYPTED_TRANSPORT_REQUIRED` | Transport encryption is required | POS-backend-provider communication |
| `PAYLOAD_SIGNING_REQUIRED` | Message signing or equivalent verification required | Callback/high-risk message |
| `CALLBACK_VERIFICATION_REQUIRED` | Provider callback must be verified before mutation | Payment/provider callbacks |
| `IDEMPOTENCY_REQUIRED` | Duplicate prevention required | Payment/refund/callback/KDS |
| `LEDGER_APPEND_ONLY_REQUIRED` | Financial ledger must be append-only | Settlement/ledger packages |
| `DOUBLE_ENTRY_REQUIRED` | Double-entry-compatible financial record required | Ledger design |
| `SETTLEMENT_ASYNC_REQUIRED` | Settlement must be decoupled from customer response | Multi-gateway settlement |
| `RECONCILIATION_REQUIRED` | Financial reconciliation is required | Payment/settlement |
| `RECONCILIATION_EXCEPTION_OPEN` | Financial mismatch requires review | Exception workflow |
| `PROVIDER_SETTLEMENT_EVIDENCE_REQUIRED` | Provider settlement evidence missing | Provider capability |
| `EXCHANGE_RATE_EVIDENCE_REQUIRED` | FX source/timestamp required | Overseas payment |
| `FINANCIAL_AUTHORITY_DEFERRED` | Runtime financial authority not allowed yet | Planning phase |

These are planning statuses.

They do not implement runtime behavior.

---

## 6. External POS Trust Catalog

A POS trust catalog must classify external POS environments.

| Code | Meaning | Allowed Authority |
|---|---|---|
| `POS_TRUST_LIMITED` | External POS may provide operational context only | No ledger authority |
| `POS_CONTEXT_PROVIDER` | POS can provide order/table/session context | Context only |
| `POS_EVENT_SOURCE_UNVERIFIED` | POS event must be verified/correlated | Evidence only |
| `POS_EVENT_SOURCE_VERIFIED` | POS event verified by contract | Evidence, not financial truth |
| `POS_LOCAL_CACHE_UNTRUSTED` | POS local cache cannot become source of truth | Display/fallback only |
| `POS_SANDBOX_MODULE_REQUIRED` | Third-party module must isolate memory/storage/network | Controlled module only |

External POS must not be cataloged as trusted financial authority by default.

---

## 7. Tokenization Catalog

A tokenization catalog must define token families.

| Token Family | Purpose | POS Storage Rule | Backend Rule |
|---|---|---|---|
| `TOKEN_PAYMENT_REFERENCE` | Payment correlation | Temporary only | Resolves in secure backend |
| `TOKEN_CUSTOMER_SESSION` | Customer/session continuity | Limited scope | Backend-owned |
| `TOKEN_PROVIDER_SESSION` | Provider session reference | No long-term POS storage | Backend/provider boundary |
| `TOKEN_ORDER_PAYMENT_LINK` | Order-payment correlation | Display-safe only | Ledger correlation |
| `TOKEN_REFUND_REFERENCE` | Refund flow reference | Temporary only | Backend authority |
| `TOKEN_SETTLEMENT_REFERENCE` | Settlement correlation | POS should not resolve | Ledger authority |
| `TOKEN_PARTNER_PROJECTION` | External projection reference | Limited public-safe scope | Registry-owned |

Raw sensitive data must not be replaced by loosely scoped permanent tokens.

Each token requires scope, lifetime, audience, replay policy, and audit linkage.

---

## 8. Plain Text Prohibition Catalog

The security catalog must explicitly classify where plain text sensitive data is prohibited.

| Location | Sensitive Plain Text Rule |
|---|---|
| External POS memory | Prohibited beyond transient processing |
| POS local storage | Prohibited |
| POS logs | Prohibited |
| Browser local storage | Prohibited for sensitive values |
| Mobile insecure storage | Prohibited |
| QR/NFC payload | Prohibited for sensitive values |
| Partner payload | Prohibited unless tokenized/minimized |
| Support notes | Prohibited for secrets/payment data |
| AI prompts | Prohibited |
| Test fixtures | Prohibited |
| Markdown examples | Prohibited |
| Crash dumps | Prohibited |
| Screenshots | Prohibited where sensitive data is visible |

Sensitive data includes credentials, provider secrets, payment references, customer identity secrets, settlement account data, service keys, and payment tokens.

---

## 9. Payment Gateway Separation Catalog

The provider capability registry must separate payment gateway families.

| Gateway Family | Scope | Evidence Requirement |
|---|---|---|
| `GATEWAY_DOMESTIC_PAYMENT` | Domestic payment/capture/refund | Provider evidence required |
| `GATEWAY_OVERSEAS_PAYMENT` | Overseas card/payment network | Provider evidence required |
| `GATEWAY_PARTNER_PAYMENT` | Partner-mediated payment | Provider/commercial evidence required |
| `GATEWAY_GLOBAL_WALLET_ALIPAY` | Alipay candidate | Provider evidence required |
| `GATEWAY_GLOBAL_WALLET_WECHATPAY` | WeChat Pay candidate | Provider evidence required |
| `GATEWAY_OVERSEAS_CARD` | Overseas card candidate | Provider evidence required |
| `GATEWAY_FRANCHISE_ROYALTY` | Internal royalty route | Internal policy required |
| `GATEWAY_PARTNER_REVENUE_SHARE` | Partner revenue share route | Provider/commercial evidence required |

No payment gateway family may default to confirmed.

---

## 10. Ledger Status Catalog

The status catalog must include ledger lifecycle values.

| Ledger Status | Meaning |
|---|---|
| `LEDGER_ENTRY_CANDIDATE` | Candidate entry pending validation |
| `LEDGER_ENTRY_POSTED` | Entry posted to append-only ledger |
| `LEDGER_ENTRY_REVERSED` | Reversal entry posted |
| `LEDGER_ENTRY_ADJUSTED` | Adjustment entry posted |
| `LEDGER_RECONCILIATION_PENDING` | Reconciliation not complete |
| `LEDGER_RECONCILED` | Reconciled against required evidence |
| `LEDGER_RECONCILIATION_EXCEPTION` | Mismatch detected |
| `LEDGER_CORRECTION_REQUIRED` | Correction entry required |
| `LEDGER_PROVIDER_EVIDENCE_MISSING` | Provider evidence absent |
| `LEDGER_EXCHANGE_RATE_EVIDENCE_MISSING` | FX evidence absent |
| `LEDGER_FINALIZATION_DEFERRED` | Finalization not allowed yet |

Ledger statuses must not imply that UPDATE/DELETE mutation is allowed.

---

## 11. Double-Entry Catalog

The ledger catalog must define double-entry fields.

Required planning fields:

| Field | Meaning |
|---|---|
| Ledger entry id | Stable entry id |
| Debit account | Debit side |
| Credit account | Credit side |
| Amount | Monetary amount |
| Currency | Currency code |
| Exchange rate reference | Required if currency conversion applies |
| Fee component | Provider/platform/partner fee if applicable |
| Tax component | Tax/VAT component if applicable |
| Settlement period | Period covered |
| Evidence source | Provider/internal evidence |
| Correlation id | Order/payment/provider correlation |
| Reconciliation status | Reconciliation state |
| Correction reference | Reversal/adjustment linkage |
| Audit event id | Accountability reference |

Actual schema implementation remains deferred.

---

## 12. Settlement Pipeline Catalog

Settlement pipelines must be cataloged separately.

| Pipeline | Purpose | Default Status |
|---|---|---|
| `PIPELINE_DOMESTIC_SETTLEMENT` | Domestic provider settlement | `PROVIDER_SETTLEMENT_EVIDENCE_REQUIRED` |
| `PIPELINE_OVERSEAS_SETTLEMENT` | Overseas/global payment settlement | `PROVIDER_SETTLEMENT_EVIDENCE_REQUIRED` |
| `PIPELINE_PARTNER_SETTLEMENT` | Partner-mediated settlement | `PROVIDER_SETTLEMENT_EVIDENCE_REQUIRED` |
| `PIPELINE_FRANCHISE_ROYALTY` | Franchise royalty allocation | `INTERNAL_POLICY_REQUIRED` |
| `PIPELINE_PLATFORM_FEE` | Platform/HQ fee allocation | `INTERNAL_POLICY_REQUIRED` |
| `PIPELINE_REDTABLE_SHARE` | Redtable-type revenue share candidate | `CAPABILITY_PROVIDER_EVIDENCE_REQUIRED` |
| `PIPELINE_CORRECTION_ADJUSTMENT` | Correction/reversal flow | `AUDIT_REQUIRED` |

Pipelines must not be collapsed into a single payment status.

---

## 13. Reconciliation Exception Catalog

Reconciliation exception families must be cataloged.

| Exception Code | Meaning |
|---|---|
| `RECON_PROVIDER_CAPTURED_LEDGER_MISSING` | Provider captured but ledger missing |
| `RECON_LEDGER_POSTED_CALLBACK_MISSING` | Ledger exists but callback missing |
| `RECON_AMOUNT_MISMATCH` | Provider and internal amounts differ |
| `RECON_FEE_MISMATCH` | Fee calculation differs |
| `RECON_EXCHANGE_RATE_MISMATCH` | FX source/timing differs |
| `RECON_REFUND_WITHOUT_ADJUSTMENT` | Refund executed but ledger adjustment missing |
| `RECON_DUPLICATE_CALLBACK` | Duplicate callback received |
| `RECON_POS_CANCEL_PAYMENT_CAPTURED` | POS cancelled but payment captured |
| `RECON_KDS_COMPLETE_PAYMENT_UNRESOLVED` | KDS completed while payment unresolved |
| `RECON_PARTNER_REPORT_MISSING` | Partner settlement report missing |
| `RECON_PROVIDER_EVIDENCE_INCOMPLETE` | Provider evidence incomplete |

Exceptions require evidence and audit.

Silent overwrite is prohibited.

---

## 14. Callback Verification Catalog

Provider callback contract catalog must include verification states.

| Callback State | Meaning |
|---|---|
| `CALLBACK_RECEIVED` | Callback received |
| `CALLBACK_SIGNATURE_PENDING` | Signature verification pending |
| `CALLBACK_SIGNATURE_VERIFIED` | Signature verified |
| `CALLBACK_SIGNATURE_FAILED` | Signature verification failed |
| `CALLBACK_DUPLICATE_DETECTED` | Duplicate callback detected |
| `CALLBACK_REPLAY_BLOCKED` | Replay attempt blocked |
| `CALLBACK_IDEMPOTENT_RETRY` | Safe retry recognized |
| `CALLBACK_MAPPED_TO_PAYMENT` | Internal payment mapping found |
| `CALLBACK_MAPPED_TO_LEDGER_CANDIDATE` | Ledger candidate identified |
| `CALLBACK_RECONCILIATION_REQUIRED` | Reconciliation required before final state |
| `CALLBACK_REJECTED_UNVERIFIED` | Callback rejected as unverified |

Callback verification must precede financial mutation.

---

## 15. Exchange Rate Evidence Catalog

Overseas payment and partner settlement require exchange-rate evidence.

| Field | Meaning |
|---|---|
| Transaction currency | Currency charged |
| Settlement currency | Currency settled |
| Display currency | Currency shown to customer |
| Exchange-rate source | Provider/internal/source authority |
| Exchange-rate timestamp | Time of rate application |
| Rate lock status | Whether rate was locked |
| Provider-applied rate | Rate from provider |
| Internal accounting rate | Internal accounting rate if different |
| Refund rate rule | Refund exchange handling |
| Discrepancy rule | Difference handling |
| Customer message key | i18n key for explanation |
| Audit evidence | Audit/evidence reference |

Exchange-rate logic must not be hidden in provider parsing code.

---

## 16. Multi-Party Settlement Catalog

The settlement catalog must support routing parties.

| Party Type | Meaning |
|---|---|
| `PARTY_STORE` | Store receiving settlement |
| `PARTY_FRANCHISE_OWNER` | Franchise owner |
| `PARTY_HQ` | HQ/operator |
| `PARTY_PLATFORM` | Platform operator |
| `PARTY_DOMESTIC_PROVIDER` | Domestic payment provider |
| `PARTY_OVERSEAS_PROVIDER` | Overseas payment provider |
| `PARTY_PARTNER_PROVIDER` | External partner provider |
| `PARTY_REDTABLE_TYPE_PARTNER` | Redtable-type partner |
| `PARTY_HOLDING_COMPANY` | Holding company candidate |
| `PARTY_IP_ROYALTY_RECIPIENT` | IP/royalty recipient |
| `PARTY_TAX_FEE_ACCOUNT` | Tax/fee allocation account |

Each route requires effective date, calculation basis, evidence source, audit event, and reconciliation status.

---

## 17. Audit Event Additions

The audit catalog must include financial security audit families.

| Audit Family | Meaning |
|---|---|
| `AUDIT_POS_TOKEN_ISSUED` | Token issued for POS/module use |
| `AUDIT_POS_TOKEN_USED` | Token used |
| `AUDIT_PROVIDER_CALLBACK_RECEIVED` | Provider callback received |
| `AUDIT_PROVIDER_CALLBACK_VERIFIED` | Callback verified |
| `AUDIT_PROVIDER_CALLBACK_REJECTED` | Callback rejected |
| `AUDIT_LEDGER_ENTRY_POSTED` | Ledger entry posted |
| `AUDIT_LEDGER_REVERSAL_POSTED` | Reversal posted |
| `AUDIT_LEDGER_ADJUSTMENT_POSTED` | Adjustment posted |
| `AUDIT_RECONCILIATION_EXCEPTION_CREATED` | Exception created |
| `AUDIT_RECONCILIATION_EXCEPTION_RESOLVED` | Exception resolved |
| `AUDIT_SETTLEMENT_ALLOCATION_REQUESTED` | Allocation requested |
| `AUDIT_SETTLEMENT_ALLOCATION_REVIEWED` | Allocation reviewed |
| `AUDIT_EXCHANGE_RATE_EVIDENCE_ATTACHED` | FX evidence attached |
| `AUDIT_PROVIDER_EVIDENCE_ATTACHED` | Provider evidence attached |

Audit entries must correlate with evidence where required.

---

## 18. Evidence Packet Additions

The evidence catalog must include financial evidence families.

| Evidence Family | Meaning |
|---|---|
| `EVIDENCE_POS_EVENT` | POS event evidence |
| `EVIDENCE_PAYMENT_EVENT` | Payment event evidence |
| `EVIDENCE_PROVIDER_CALLBACK` | Provider callback evidence |
| `EVIDENCE_PROVIDER_SETTLEMENT_REPORT` | Provider settlement report |
| `EVIDENCE_LEDGER_ENTRY` | Ledger entry reference |
| `EVIDENCE_LEDGER_REVERSAL` | Ledger reversal reference |
| `EVIDENCE_LEDGER_ADJUSTMENT` | Ledger adjustment reference |
| `EVIDENCE_EXCHANGE_RATE_SOURCE` | FX source/timestamp evidence |
| `EVIDENCE_RECONCILIATION_EXCEPTION` | Reconciliation mismatch evidence |
| `EVIDENCE_PARTNER_REVENUE_SHARE_RULE` | Partner share rule evidence |
| `EVIDENCE_FRANCHISE_ROYALTY_RULE` | Franchise royalty rule evidence |
| `EVIDENCE_SECURITY_VERIFICATION` | Signature/encryption/security evidence |

AI summaries remain derived evidence only.

---

## 19. Security Visibility Additions

Financial data visibility classes must be added.

| Visibility Class | Meaning |
|---|---|
| `FINANCIAL_PUBLIC_SAFE_STATUS` | Display-safe status only |
| `FINANCIAL_TOKENIZED_REFERENCE` | Tokenized reference only |
| `FINANCIAL_MASKED_PAYMENT` | Masked payment data |
| `FINANCIAL_PROVIDER_DIAGNOSTIC` | Provider diagnostic, restricted |
| `FINANCIAL_LEDGER_RESTRICTED` | Ledger detail restricted |
| `FINANCIAL_SETTLEMENT_RESTRICTED` | Settlement detail restricted |
| `FINANCIAL_EXCHANGE_RATE_REVIEW` | FX review data |
| `FINANCIAL_RECONCILIATION_REVIEW` | Reconciliation review data |
| `FINANCIAL_LEGAL_COMPLIANCE_ONLY` | Legal/compliance-only financial data |
| `FINANCIAL_BLOCKED_FROM_POS` | Must not be sent to POS |

External POS must receive only display-safe or tokenized data.

---

## 20. AI Source And Output Additions

AI catalog must include financial AI boundaries.

Allowed AI source classes:

- `AI_SOURCE_AUDIT_METADATA`
- `AI_SOURCE_LEDGER_METADATA`
- `AI_SOURCE_PROVIDER_CALLBACK_METADATA`
- `AI_SOURCE_RECONCILIATION_EXCEPTION_METADATA`
- `AI_SOURCE_EVIDENCE_SUMMARY`
- `AI_SOURCE_PROVIDER_EVIDENCE_STATUS`
- `AI_SOURCE_APPROVED_SUPPORT_CONTENT`

Blocked AI source classes:

- `AI_SOURCE_RAW_PAYMENT_SECRET`
- `AI_SOURCE_PROVIDER_SECRET`
- `AI_SOURCE_UNMASKED_CUSTOMER_PAYMENT_DATA`
- `AI_SOURCE_SERVICE_ROLE_CREDENTIAL`
- `AI_SOURCE_UNAPPROVED_LEGAL_CONTENT`

Allowed AI output states:

- `AI_FINANCIAL_EXCEPTION_SUMMARY_DRAFT`
- `AI_RECONCILIATION_PATTERN_SUGGESTION`
- `AI_MISSING_EVIDENCE_NOTICE`
- `AI_PROVIDER_EVIDENCE_REQUIRED_NOTICE`
- `AI_SUPPORT_RESPONSE_DRAFT`
- `AI_HUMAN_REVIEW_REQUIRED`

AI must not create ledger entries, approve refunds, execute corrections, or finalize reconciliation.

---

## 21. Readiness Blocker Additions

The blocker inventory must include financial blockers.

| Blocker ID Pattern | Family | Meaning |
|---|---|---|
| `BLOCKER-FINSEC-0001` | Financial security | POS sandbox model missing |
| `BLOCKER-TOKEN-0001` | Tokenization | Token scope/lifetime missing |
| `BLOCKER-LEDGER-0001` | Ledger | Append-only ledger rule missing |
| `BLOCKER-DOUBLEENTRY-0001` | Ledger | Double-entry structure missing |
| `BLOCKER-CALLBACK-0001` | Provider callback | Verification/idempotency missing |
| `BLOCKER-RECON-0001` | Reconciliation | Exception workflow missing |
| `BLOCKER-FX-0001` | Exchange rate | FX evidence rule missing |
| `BLOCKER-SETTLEMENT-0001` | Settlement | Multi-party route rule missing |
| `BLOCKER-POS-0001` | External POS | Limited-trust boundary missing |
| `BLOCKER-AI-FIN-0001` | AI financial boundary | AI financial authority limits missing |

These blockers must prevent runtime coding entry.

---

## 22. Boundary Test Additions

Boundary test catalog must include financial security checks.

Future tests/checks should verify:

- provider capability defaults to evidence-required
- no provider marked confirmed without evidence
- no financial package lacks audit family
- no settlement package lacks reconciliation status
- no ledger package permits silent mutation
- no financial artifact lacks append-only rule
- no payment callback lacks verification state
- no token lacks scope/lifetime metadata
- no sensitive plain text appears in catalog/test/example files
- no external POS data class contains raw secrets
- no AI output state has financial mutation authority
- no package marked coding-ready with financial blocker open

These tests protect future runtime implementation.

---

## 23. Patent Reinforcement Metadata

Patent-supporting architecture entries should include metadata.

| Field | Meaning |
|---|---|
| Patent Concept ID | Candidate patent concept reference |
| Technical Feature | Sandbox, tokenization, ledger, reconciliation, AI anomaly, etc. |
| Provider Evidence Dependency | Whether provider evidence is required |
| Claim Support Status | Draft, attorney review required, approved, rejected |
| Implementation Dependency | Foundation/runtime package dependency |
| Risk | Unsupported claim, provider assumption, legal review needed |
| Review Owner | Patent attorney/project owner |

Patent language must not claim specific provider support without evidence.

---

## 24. Relationship To Previous Documents

This document extends:

- `22450 Foundation Catalog Implementation Order And Dependency Policy`
- `22460 Foundation Catalog File Layout And Naming Convention Policy`
- `22470 Foundation Catalog Header Schema And Required Metadata Policy`
- `22480 Foundation Catalog Validation Checklist And Review Gate Policy`
- `22490 External POS Third-Party Financial Security Ledger And Settlement Isolation Reinforcement Policy`

This document prepares the financial security and ledger additions needed for future foundation catalogs.

It does not authorize coding.

---

## 25. Final Rule

The external POS financial security and settlement architecture must be converted into controlled catalog vocabulary before implementation.

The project must catalog POS trust limits, sandbox requirements, tokenization, plain text prohibition, provider callback verification, ledger append-only rules, double-entry requirements, asynchronous settlement, reconciliation exceptions, exchange-rate evidence, multi-party settlement routing, financial audit/evidence families, AI financial assistance limits, and patent support metadata.

Coding remains deferred until these catalog additions are reviewed, validated, and tied to package-specific entry approval.
