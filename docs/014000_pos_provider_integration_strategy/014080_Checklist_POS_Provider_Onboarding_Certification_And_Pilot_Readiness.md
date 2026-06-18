# 014080_Checklist_POS_Provider_Onboarding_Certification_And_Pilot_Readiness.md

## 1. Purpose

This checklist defines the onboarding and certification readiness requirements before Catch & Order begins POS provider integration or field pilot work.

The domestic POS ecosystem contains closed Windows client systems, hybrid ASP systems, cloud-native POS platforms, VAN/PG-linked payment networks, and hardware-first environments. Because of this fragmentation, provider onboarding must be treated as a controlled readiness process rather than an informal API connection task.

## 2. Core Rule

No POS provider may enter implementation unless the provider has passed a documented readiness gate.

If readiness is incomplete, the provider must remain in one of the following limited scopes:

- manual fallback only
- evidence-only reference
- order-handoff candidate only
- provider-openness research
- archive/monitor status

## 3. Provider Onboarding Status

| Status | Meaning | Allowed Action |
|---|---|---|
| Unknown | Provider not yet verified | Research only |
| Contacted | Provider sales/support contacted | No build |
| Technical Path Requested | API/SDK/webhook information requested | No build |
| Interface Verified | Official interface confirmed | Adapter planning allowed |
| Sandbox Ready | Test account or sandbox exists | Prototype allowed |
| Pilot Candidate | Store/provider conditions known | Controlled pilot allowed |
| Certification Required | Provider approval required | Wait for approval |
| Blocked | No official path or unsafe path | Manual fallback only |
| Approved | Provider-specific pilot approved | Implementation allowed |

## 4. Minimum Provider Data

Each provider must have the following recorded:

| Field | Required |
|---|---|
| provider_id | Yes |
| provider_name | Yes |
| brand_name | Yes |
| provider_class | Yes |
| expected_integration_tier | Yes |
| official_api_status | Yes |
| official_docs_source | Yes if available |
| contact_channel | Yes |
| technical_contact | Recommended |
| contract_required | Yes/No/Unknown |
| certification_required | Yes/No/Unknown |
| sandbox_available | Yes/No/Unknown |
| webhook_available | Yes/No/Unknown |
| payment_scope | None / Observe / Execute / Unknown |
| settlement_scope | None / Observe / Reconcile / Unknown |
| local_device_dependency | High / Medium / Low / Unknown |
| pilot_store_candidate | Yes/No/Unknown |
| readiness_status | Yes |

## 5. Official Interface Verification

Before any build begins, verify the provider's official integration route.

| Check | Required Result |
|---|---|
| Official API documentation exists | Yes or explicitly unavailable |
| API access condition known | Yes |
| API rate limits known | Required if API exists |
| API auth method known | Required if API exists |
| Sandbox/test environment known | Required for implementation |
| Webhook/callback availability known | Required if events are needed |
| SDK/plugin availability known | Required if provider uses SDK/plugin |
| Provider versioning policy known | Recommended |
| Provider support channel known | Required |
| Partner or certification process known | Required for Tier 3+ |

If official interface is not confirmed, the provider cannot exceed Tier 1.

## 6. Contract And Authorization Gate

The following must be known before provider integration planning:

| Item | Required For |
|---|---|
| Provider partner approval | Tier 4+ |
| Payment-related authorization | Tier 3+ |
| Store owner consent | Any store-level integration |
| Franchise HQ approval | Franchise-custom environment |
| Data processing agreement | Any customer/payment data transfer |
| Credential issuance policy | Any API/webhook |
| Production activation policy | Any live pilot |
| Termination or disable policy | Any provider adapter |

Do not use undocumented credentials, shared accounts, or store owner passwords as integration credentials.

## 7. Sandbox And Test Gate

A provider may enter prototype work only if one of the following exists:

1. Official sandbox
2. Official test store
3. Provider-approved pilot store
4. Offline mock contract with no production call

The following must be tested before live pilot:

- authentication
- idempotency
- timeout
- retry
- webhook signature
- replay protection
- cancellation
- refund or correction if payment-aware
- reconciliation evidence
- manual fallback trigger
- kill switch

## 8. Payment And Settlement Certification Gate

If the provider integration touches payment, cancellation, refund, or settlement state, the provider must pass the financial control gate.

Required checks:

| Check | Required |
|---|---|
| Payment execution separated from order handoff | Yes |
| Payment observation separated from settlement matching | Yes |
| Approval number captured | Yes if available |
| Cancellation/refund event captured | Yes |
| Duplicate approval prevention tested | Yes |
| Callback replay tested | Yes |
| Daily reconciliation path defined | Yes |
| Manual correction audit trail defined | Yes |
| Customer-visible state wording reviewed | Yes |
| Provider financial responsibility boundary known | Yes |

If these are not complete, the provider must not exceed Tier 2.

## 9. Store Pilot Readiness

Provider readiness alone is not enough. The store must also be ready.

| Store Check | Required |
|---|---|
| Store owner approval | Yes |
| POS model/version recorded | Yes |
| Payment terminal type recorded | Yes |
| Printer/KDS device list recorded | Yes |
| Store network quality checked | Yes |
| Staff fallback SOP trained | Yes |
| Manual order path available | Yes |
| Daily reconciliation owner assigned | Yes |
| Incident escalation channel known | Yes |
| Rollback path tested | Yes |

## 10. Adapter Readiness Gate

Before enabling the provider adapter:

| Adapter Check | Required |
|---|---|
| Provider class assigned | Yes |
| Integration tier configured | Yes |
| Credentials scoped | Yes |
| Endpoint configured | Yes |
| Timeout policy configured | Yes |
| Retry policy configured | Yes |
| Idempotency mode configured | Yes |
| Webhook verification configured | If webhook exists |
| Evidence storage configured | Yes |
| Error taxonomy mapped | Yes |
| Kill switch tested | Yes |
| Manual fallback trigger tested | Yes |
| Reconciliation evidence tested | Yes |

## 11. Pilot Entry Decision

A provider/store pair may enter pilot only when all of the following are true:

1. Provider status is Pilot Candidate or Approved.
2. Store readiness checklist is complete.
3. Adapter readiness checklist is complete.
4. Manual fallback SOP is available.
5. Evidence packet template is available.
6. Financial control gate is complete if payment-aware.
7. Incident owner is assigned.
8. Disable/rollback path is confirmed.
9. Daily reconciliation process is defined.
10. Pilot approval is recorded.

## 12. Block Conditions

Do not proceed with implementation if any of the following are true:

- Provider requires direct writes to undocumented local DB.
- Provider has no official API but asks for screen scraping.
- Provider callback has no signature or replay protection for critical events.
- Payment state cannot be distinguished from order state.
- Refund/cancellation behavior is unknown.
- Store has no manual fallback.
- Store staff cannot operate fallback flow.
- Provider support escalation is unavailable.
- Credentials are shared or unmanaged.
- Production test requires real customer payment without approval.
- Provider contract responsibility is unclear.

## 13. Evidence Packet

Every onboarding decision must produce an evidence packet.

Minimum packet:

- provider classification result
- onboarding status
- official docs/source link or note
- API/webhook/SDK verification result
- contract/certification requirement
- sandbox/test availability
- store readiness result
- adapter readiness result
- payment/settlement gate result
- pilot approval or block reason
- incident owner
- fallback owner
- next action

## 14. Provider Readiness Score

Use this simple score for prioritization:

| Score Area | Points |
|---|---:|
| Official API confirmed | 20 |
| Sandbox/test account available | 15 |
| Webhook signature/replay support | 15 |
| Payment boundary clear | 15 |
| Store pilot candidate ready | 10 |
| Support escalation channel exists | 10 |
| Manual fallback verified | 10 |
| Reconciliation evidence possible | 5 |

Score interpretation:

| Score | Readiness |
|---:|---|
| 80-100 | Strong pilot candidate |
| 60-79 | Candidate with conditions |
| 40-59 | Research and limited test only |
| 0-39 | Manual fallback / monitor only |

## 15. Recommended Initial Provider Records

Create initial onboarding records for:

- OKPOS
- KIS OKPOS
- KICC EasyPos
- Toss Place
- Payhere
- PAYCO-related provider flow
- POSBANK hardware environment
- IMU POS
- local franchise POS vendor
- unknown pilot-store POS vendor

## 16. Non-Goals

This checklist does not define:

- provider-specific API schema
- commercial partnership terms
- final implementation sprint
- final payment execution logic
- final settlement accounting logic
- final franchise rollout plan

Those must be handled by provider-specific implementation and legal documents.

## 17. Related Documents

- 14020_Report_Domestic_POS_Industry_Ecosystem_Market_Architecture_And_Limitations.md
- 14030_Policy_POS_Provider_Architecture_Classification_And_Gateway_Integration_Strategy.md
- 14040_Checklist_POS_Gateway_Risk_Failure_Mode_And_Field_Readiness.md
- 14050_Matrix_POS_Provider_Priority_Openness_Risk_And_MVP_Fit.md
- 14070_Spec_POS_Provider_Adapter_Boundary_And_Evidence_Contract.md
- 11000_Integration_Boundary
- 20000_Validation_Security_Audit
- 20400_foundation_security
