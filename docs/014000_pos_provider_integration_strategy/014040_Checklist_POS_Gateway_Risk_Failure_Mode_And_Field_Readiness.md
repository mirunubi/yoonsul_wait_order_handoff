# 014040_Checklist_POS_Gateway_Risk_Failure_Mode_And_Field_Readiness.md

## 1. Purpose

This checklist converts the domestic POS industry ecosystem analysis into a practical readiness checklist for Catch & Order POS Gateway planning.

The goal is to prevent the project from underestimating POS integration risk.

This document is not a provider implementation guide. It is a risk checklist used before provider selection, pilot launch, and store rollout.

## 2. Core Assumption

Domestic POS integration is not a simple API connection problem.

It is a combined field-risk problem involving:

- local POS database behavior
- payment terminal behavior
- printer and KDS hardware behavior
- provider API openness
- VAN/PG settlement boundaries
- store network quality
- staff operation habits
- franchise-specific customization
- legacy Windows client dependencies
- cloud POS outage patterns

Catch & Order must treat POS integration as an operational safety layer, not only a technical adapter.

## 3. Provider Readiness Checklist

| Check | Required Status | Notes |
|---|---|---|
| Provider architecture identified | Required | Windows, Android, cloud, hybrid, hardware-first, VAN/PG-linked |
| Official API confirmed | Required | Do not rely on rumor or sales material |
| API access condition known | Required | Partner contract, certification, store-level approval |
| Webhook/callback support confirmed | Required if payment/order status is observed | Must include signature and replay control |
| SDK/plugin policy confirmed | Required for plugin-type POS | Versioning and sandbox policy must be known |
| Provider document source stored | Required | Official docs or verified technical guide |
| Test account/sandbox available | Required before implementation | No sandbox means controlled pilot only |
| Support escalation contact known | Required before pilot | Sales contact is not enough |
| Provider outage behavior known | Recommended | Must know whether API fails open, fails closed, or delays |
| Provider certification path known | Required for payment-aware integration | Do not enter Tier 3+ without this |

## 4. Store Environment Checklist

| Check | Required Status | Risk If Missing |
|---|---|---|
| POS model/version captured | Required | Wrong adapter or incompatible workflow |
| POS OS captured | Required | Windows/Android/iOS behavior differs |
| Local DB dependency known | Required | Sync loss and settlement mismatch |
| Payment terminal type captured | Required | Payment boundary unclear |
| Printer/KDS devices listed | Required | Kitchen failure hidden until launch |
| Store network quality checked | Required | Retry storm and duplicate handoff |
| Staff manual fallback trained | Required | Store paralysis during outage |
| Owner approval flow confirmed | Required | Integration blocked by operating habit |
| Franchise customization checked | Required if franchise store | Provider default docs may not apply |
| Offline operation scenario tested | Required for pilot | Loss of order/payment evidence |

## 5. Windows Legacy POS Failure Modes

Windows local-client POS systems must be assumed fragile until tested.

| Failure Mode | Expected Impact | Required Guard |
|---|---|---|
| Local DB alias/registry loss | POS login or sales screen failure | Manual fallback and support escalation |
| Local DB file corruption | Daily settlement mismatch | Evidence capture and reconciliation |
| DLL/device driver mismatch | Printer/CAT/signpad failure | Device boundary isolation |
| Windows update impact | POS component failure | Store-side rollback or bypass plan |
| Serial/USB port remapping | Payment/printer device not found | Hardware inventory and field checklist |
| Local-first then batch-sync delay | Provider server mismatch | Delayed reconciliation |
| Power loss during write | Transaction loss or duplicate | Idempotency and recovery evidence |
| Store PC replacement | Provider credentials and DB paths lost | Setup checklist and credential vaulting |

## 6. Android And Cloud POS Failure Modes

Cloud-native POS systems reduce local DB risk but increase API, cloud, and policy dependency.

| Failure Mode | Expected Impact | Required Guard |
|---|---|---|
| Cloud API outage | Many stores affected at once | Provider outage fallback |
| Webhook delay | Late order/payment status | State timeout and reconciliation |
| Callback replay | Duplicate order/payment event | Signature and replay protection |
| Provider SDK version change | Integration breakage | Version registry and adapter boundary |
| Plugin sandbox limitation | Feature cannot run as expected | Tier classification before build |
| Store tablet app update | UI/workflow changed | Pilot regression checklist |
| Cloud DB delay | Status mismatch | Event ledger and delayed matching |
| Provider policy change | API access revoked or narrowed | Contract and fallback plan |

## 7. Payment And Settlement Risk Checklist

Payment-related integration requires stricter rules than order-only integration.

| Check | Required Status |
|---|---|
| Payment execution separated from order handoff | Required |
| Payment observation separated from settlement confirmation | Required |
| Refund/cancel/correction flow documented | Required |
| Provider approval number captured | Required if payment-aware |
| VAN/PG reference captured | Required if available |
| Duplicate approval prevention tested | Required |
| Callback replay tested | Required |
| Daily reconciliation test executed | Required |
| Manual correction audit trail defined | Required |
| Customer-facing state wording approved | Required |

## 8. Gateway Adapter Checklist

Every POS provider must be isolated behind an adapter.

| Adapter Control | Required |
|---|---|
| Provider-specific endpoint registry | Yes |
| Provider credential isolation | Yes |
| Request mapping | Yes |
| Response mapping | Yes |
| Error normalization | Yes |
| Timeout policy | Yes |
| Retry policy | Yes |
| Idempotency key mapping | Yes |
| Webhook signature verification | Yes if webhook exists |
| Replay protection | Yes |
| Provider version metadata | Yes |
| Evidence payload storage | Yes |
| Feature flag / kill switch | Yes |
| Manual fallback trigger | Yes |

## 9. Field Pilot Entry Gate

A store may enter POS-integrated pilot only when the following are true:

1. Provider class has been assigned.
2. Integration tier has been assigned.
3. Store POS model/version has been captured.
4. Payment terminal dependency is known.
5. Printer/KDS dependency is known.
6. Official provider interface is confirmed or fallback-only scope is declared.
7. Manual fallback SOP exists.
8. Staff has completed fallback training.
9. Evidence packet template exists.
10. Daily reconciliation plan exists.
11. Incident escalation path exists.
12. Rollback or disable path exists.

## 10. Integration Tier Gate

| Tier | Required Before Entry |
|---|---|
| Tier 0 | No POS dependency; manual workflow confirmed |
| Tier 1 | Evidence/export path verified |
| Tier 2 | Order handoff idempotency and staff confirmation verified |
| Tier 3 | Payment observation and reconciliation verified |
| Tier 4 | Provider official API/webhook verified |
| Tier 5 | Franchise contract, settlement, reporting, and multi-store governance verified |

Do not allow a provider to skip tiers without written approval and test evidence.

## 11. Red Flags

The following conditions should block or downgrade integration scope:

- Provider cannot confirm official API availability.
- Provider has API but no sandbox or test account.
- Provider requires undocumented local DB access.
- Provider asks Catch & Order to write directly into POS local database.
- Provider callback has no signature or replay protection.
- Payment state is mixed with order state.
- Store has no manual fallback plan.
- Store staff refuses fallback training.
- Provider support escalation is only sales-channel based.
- Franchise store has custom POS workflow not reflected in provider documentation.
- Printer/KDS failure causes order loss.
- Cancellation/refund behavior cannot be reconciled.

## 12. Required Evidence Packet

Each POS integration candidate must keep an evidence packet containing:

- provider classification result
- integration tier decision
- official provider documentation source
- API/webhook/SDK availability proof
- store POS model/version
- terminal/printer/KDS inventory
- test transaction logs
- failure-mode test result
- retry/replay test result
- reconciliation test result
- manual fallback training record
- incident owner and escalation route
- approval or rejection decision

## 13. Recommended Immediate Action For Catch & Order

Before deep implementation, create a provider readiness matrix for:

- OKPOS
- KIS OKPOS
- KICC EasyPos
- Toss Place
- Payhere
- IMU POS
- POSBANK-related device environments
- PAYCO-related payment/provider flows
- Any local franchise POS provider encountered during pilot

Each row must be classified by provider class, integration tier, official interface status, and MVP suitability.

## 14. Non-Goals

This checklist does not decide:

- final provider priority
- final commercial partnership
- final API schema
- final payment execution implementation
- final certified provider package
- final franchise rollout sequence
- final settlement accounting design

Those decisions require separate policy, implementation, and evidence documents.

## 15. Related Documents

- 14020_Report_Domestic_POS_Industry_Ecosystem_Market_Architecture_And_Limitations.md
- 14030_Policy_POS_Provider_Architecture_Classification_And_Gateway_Integration_Strategy.md
- 14000_Readme_POS_Provider_Integration_Strategy.md
- 04000_Store_Runtime_POS_KDS_Operations
- 05000_Customer_Handoff_And_Implementation_Readiness
- 11000_Integration_Boundary
- 20000_Validation_Security_Audit
