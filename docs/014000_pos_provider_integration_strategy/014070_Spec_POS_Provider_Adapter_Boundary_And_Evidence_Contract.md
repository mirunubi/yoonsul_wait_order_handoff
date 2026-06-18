# 014070_Spec_POS_Provider_Adapter_Boundary_And_Evidence_Contract.md

## 1. Purpose

This specification defines the boundary contract for POS provider adapters used by Catch & Order.

The domestic POS ecosystem contains Windows local-client POS, Android/cloud POS, VAN/PG-linked providers, hardware-first POS/kiosk environments, and franchise-specific customized deployments. Because each provider exposes different integration surfaces, Catch & Order must never bind the core order domain directly to a provider-specific API, SDK, local database, webhook, or device driver.

Every provider integration must pass through a provider adapter boundary.

## 2. Scope

This document applies to:

- OKPOS-style Windows/hybrid POS integration candidates
- KIS OKPOS and franchise-custom POS variants
- KICC/EasyPos-style legacy and VAN-linked systems
- Toss Place-style cloud/plugin POS systems
- Payhere-style mobile/tablet/cloud POS systems
- PAYCO or payment-provider-adjacent flows
- POSBANK/IMU or hardware-first environments
- unknown local POS vendors encountered during pilot

This specification does not approve any specific provider integration.

## 3. Core Rule

The Catch & Order core domain must not depend on provider-specific objects.

The following must remain outside the core domain:

- provider API request shape
- provider response shape
- provider SDK object
- provider plugin state
- provider callback payload
- provider local DB field
- provider terminal state
- provider printer/KDS driver state
- provider-specific payment code
- provider-specific settlement code

All such details must be translated by the provider adapter.

## 4. Adapter Responsibility

Each provider adapter is responsible for:

| Area | Responsibility |
|---|---|
| Credential | Store and use scoped provider credentials only |
| Endpoint | Manage provider endpoint/version metadata |
| Request mapping | Convert Catch & Order command into provider request |
| Response mapping | Convert provider response into normalized event |
| Error mapping | Normalize provider errors into gateway error codes |
| Idempotency | Map internal idempotency key to provider request |
| Timeout | Apply provider-specific timeout rules |
| Retry | Apply provider-specific retry policy |
| Webhook | Verify signature, timestamp, and replay protection |
| Evidence | Store request, response, callback, and operator evidence |
| Versioning | Record provider API/SDK/plugin version |
| Kill switch | Allow provider integration to be disabled quickly |
| Fallback | Trigger manual fallback when provider state is unsafe |

## 5. Adapter Inputs

The adapter may receive only normalized Catch & Order commands.

| Command | Meaning |
|---|---|
| CreateOrderHandoff | Send an order candidate or confirmed order to provider |
| CancelOrderHandoff | Request cancellation or correction |
| QueryOrderStatus | Ask provider for current order state |
| ObservePaymentStatus | Pull or receive payment-related state |
| RequestPrintOrKitchenHandoff | Request printer/KDS-side handoff if supported |
| ReplayProviderEvent | Reprocess provider callback safely |
| DisableProviderIntegration | Stop provider integration for a store/provider |
| MarkManualFallback | Enter manual operation mode |

Commands must include:

- internal_order_id
- store_id
- tenant_id
- provider_id
- integration_tier
- idempotency_key
- requested_by
- request_reason
- created_at
- correlation_id

## 6. Adapter Outputs

The adapter must return normalized gateway events.

| Event | Meaning |
|---|---|
| ProviderHandoffRequested | Internal command was sent or queued |
| ProviderHandoffAccepted | Provider accepted the request |
| ProviderHandoffRejected | Provider rejected the request |
| ProviderHandoffUnknown | Provider result cannot be trusted |
| ProviderOrderVisible | Provider confirms order visibility |
| ProviderPaymentObserved | Payment event was observed |
| ProviderCancellationObserved | Cancellation or correction was observed |
| ProviderCallbackRejected | Callback failed verification |
| ProviderReplayIgnored | Duplicate callback was safely ignored |
| ProviderTimeout | Provider response timed out |
| ProviderIntegrationDisabled | Provider adapter was disabled |
| ManualFallbackRequired | Staff fallback must be used |
| ReconciliationRequired | State mismatch requires later matching |

Outputs must not expose raw provider fields as domain state. Raw payloads are stored only as evidence.

## 7. Required Evidence Contract

Every adapter action must create an evidence record.

Minimum evidence fields:

| Field | Required |
|---|---|
| evidence_id | Yes |
| correlation_id | Yes |
| provider_id | Yes |
| store_id | Yes |
| tenant_id | Yes |
| internal_order_id | Yes if order-related |
| internal_payment_id | Yes if payment-related |
| integration_tier | Yes |
| adapter_version | Yes |
| provider_api_version | If known |
| request_type | Yes |
| request_payload_hash | Yes |
| request_payload_storage_ref | Yes if payload stored |
| response_status | If response received |
| response_payload_hash | If response received |
| response_payload_storage_ref | If response stored |
| callback_payload_hash | If callback received |
| callback_signature_valid | If callback received |
| idempotency_key | Yes |
| replay_key | If callback received |
| operator_id | If manual action involved |
| result_state | Yes |
| created_at | Yes |
| retained_until | Yes |

## 8. Idempotency Rule

Every provider request that can create, change, cancel, refund, print, or dispatch an order must carry an idempotency key.

If the provider does not support idempotency natively, the adapter must emulate idempotency internally.

Required behavior:

- Same internal command + same idempotency key must not create duplicate provider action.
- Callback replay must not create duplicate internal events.
- Timeout followed by retry must not duplicate payment/order action.
- Manual fallback must record whether an adapter request was already attempted.
- Reconciliation must be able to identify duplicate or delayed provider events.

## 9. Webhook And Callback Rule

If the provider sends callbacks, the adapter must verify:

- signature
- timestamp
- replay key
- provider id
- store id or merchant id
- event type
- payload hash
- idempotency/replay status
- allowed source if applicable

If verification fails, the adapter must emit:

- ProviderCallbackRejected

It must not update final order or payment state.

## 10. Payment Boundary Rule

Payment-related provider events must be handled with stricter rules than order-only events.

The adapter must distinguish:

| State | Meaning |
|---|---|
| PaymentObserved | Provider/payment event was seen |
| PaymentApproved | Approval evidence exists |
| PaymentCancelled | Cancellation evidence exists |
| RefundObserved | Refund or correction evidence exists |
| SettlementMatched | Settlement/reconciliation matched |
| SettlementMismatch | Mismatch requires investigation |

The adapter must not collapse payment observation into business completion.

## 11. Local POS And Device Boundary Rule

For Windows local-client, hardware-first, printer, KDS, CAT, signpad, or cash-drawer environments:

- Adapter must not write directly to undocumented local DB tables.
- Adapter must not depend on private DLLs unless provider-approved.
- Adapter must not assume printer/KDS completion equals POS order acceptance.
- Device failure must be recorded as operational evidence.
- Manual fallback must remain available.

If provider integration requires direct local DB manipulation, the provider must be downgraded to evidence-only or manual fallback until an official interface is available.

## 12. Adapter Configuration

Provider adapter configuration must include:

```yaml
provider_id: string
provider_name: string
provider_class: A|B|C|D|E|F|G
integration_tier: 0|1|2|3|4|5
enabled: boolean
sandbox_enabled: boolean
official_interface_confirmed: boolean
credential_scope: string
api_base_url: string
webhook_enabled: boolean
signature_required: boolean
idempotency_mode: native|emulated|required_but_missing
timeout_ms: integer
retry_policy_id: string
kill_switch_id: string
fallback_mode: manual|evidence_only|order_handoff|payment_observation
evidence_retention_policy_id: string
```

## 13. Adapter Error Taxonomy

Adapters must normalize errors into the following categories:

| Error Code | Meaning |
|---|---|
| PROVIDER_UNAVAILABLE | Provider cannot be reached |
| PROVIDER_TIMEOUT | Provider did not respond in time |
| PROVIDER_REJECTED | Provider rejected the request |
| PROVIDER_UNKNOWN_RESULT | Result is ambiguous |
| PROVIDER_DUPLICATE_EVENT | Duplicate event detected |
| PROVIDER_CALLBACK_INVALID | Callback failed verification |
| PROVIDER_UNAUTHORIZED | Credential or permission failure |
| PROVIDER_UNSUPPORTED_OPERATION | Provider does not support requested operation |
| PROVIDER_VERSION_MISMATCH | Provider API/SDK version mismatch |
| PROVIDER_RATE_LIMITED | Provider rate limit reached |
| DEVICE_FAILURE | Device-side failure observed |
| LOCAL_POS_UNSAFE | Local POS state cannot be trusted |
| MANUAL_FALLBACK_REQUIRED | Manual operation must take over |
| RECONCILIATION_REQUIRED | Later matching is required |

## 14. Integration Tier Enforcement

Adapters must enforce integration tier limits.

| Tier | Allowed Adapter Behavior |
|---|---|
| Tier 0 | No provider call |
| Tier 1 | Evidence/export/reference only |
| Tier 2 | Order handoff only |
| Tier 3 | Payment observation only, no payment execution unless approved |
| Tier 4 | Official provider API/webhook integration |
| Tier 5 | Franchise-level deep integration |

If a command exceeds the configured tier, the adapter must reject it and emit an evidence record.

## 15. Kill Switch Requirement

Each provider adapter must support a kill switch.

Kill switch may apply to:

- provider
- tenant
- store
- integration tier
- operation type
- payment-aware operation
- webhook processing
- retry processing

When kill switch is active:

- new provider calls are blocked
- callbacks may be recorded but not trusted
- manual fallback is triggered
- evidence continues to be stored
- owner/admin visibility must show degraded state

## 16. Reconciliation Contract

The adapter must support reconciliation by preserving enough evidence to compare:

- Catch & Order ledger
- provider order state
- provider payment state
- VAN/PG evidence if available
- manual staff correction record
- settlement record
- cancellation/refund record

Reconciliation is not optional for payment-aware or settlement-aware integrations.

## 17. Provider Onboarding Checklist

Before enabling a provider adapter:

1. Provider class assigned.
2. Integration tier assigned.
3. Official interface status confirmed.
4. Credentials scoped and stored.
5. Timeout/retry/idempotency policy configured.
6. Webhook verification configured if applicable.
7. Evidence storage configured.
8. Manual fallback route configured.
9. Kill switch tested.
10. Sandbox/test transaction completed.
11. Reconciliation test completed.
12. Owner/admin visibility checked.
13. Pilot approval recorded.

## 18. Non-Goals

This specification does not define:

- provider-specific API schema
- final provider credentials
- final payment execution logic
- final settlement accounting logic
- final POS certification package
- final KDS implementation
- final franchise rollout policy

Those must be handled by provider-specific implementation documents.

## 19. Related Documents

- 14020_Report_Domestic_POS_Industry_Ecosystem_Market_Architecture_And_Limitations.md
- 14030_Policy_POS_Provider_Architecture_Classification_And_Gateway_Integration_Strategy.md
- 14040_Checklist_POS_Gateway_Risk_Failure_Mode_And_Field_Readiness.md
- 14050_Matrix_POS_Provider_Priority_Openness_Risk_And_MVP_Fit.md
- 11000_Integration_Boundary
- 20000_Validation_Security_Audit
- 20400_foundation_security
