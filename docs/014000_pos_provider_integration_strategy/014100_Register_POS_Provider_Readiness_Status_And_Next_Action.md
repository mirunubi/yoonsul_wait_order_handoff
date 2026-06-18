# 014100_Register_POS_Provider_Readiness_Status_And_Next_Action.md

## 1. Purpose

This register tracks POS provider readiness status, integration tier, risk, and next action for Catch & Order.

The domestic POS market is fragmented across legacy Windows POS, cloud-native POS, VAN/PG-linked payment systems, hardware-first environments, and franchise-specific custom deployments. Because of this, provider readiness must be managed as a register rather than as informal notes.

This document is a live tracking register.

## 2. Register Rule

Every POS provider or provider-like payment/hardware environment must have one readiness row before any integration work begins.

A provider row may remain in research, blocked, manual fallback, or archive status. Not every provider must become an implementation candidate.

## 3. Status Values

| Status | Meaning |
|---|---|
| Unknown | Provider has not been verified |
| Research | Provider is being investigated |
| Contact Needed | Official provider contact is required |
| Contacted | Provider contact has been made |
| Interface Requested | API/SDK/webhook information has been requested |
| Interface Verified | Official interface confirmed |
| Sandbox Needed | Interface exists but sandbox/test path is missing |
| Sandbox Ready | Test environment is available |
| Pilot Candidate | Provider/store pair may enter controlled pilot |
| Certification Required | Provider approval/certification required |
| Blocked | Integration path is unsafe or unavailable |
| Manual Fallback Only | No direct integration during MVP |
| Evidence Only | Provider is used only as reference/evidence |
| Deferred | Revisit after later phase |
| Approved | Integration may proceed under approved conditions |
| Archived | Retained for historical or market reference only |

## 4. Priority Values

| Priority | Meaning |
|---|---|
| P0 | Field reality provider; must be understood |
| P1 | First verification candidate |
| P2 | Secondary integration or compatibility candidate |
| P3 | Deferred/manual/evidence-only candidate |
| P4 | Archive/monitor only |

## 5. Provider Readiness Register

| Provider / Brand | Class | Priority | Initial Tier | Readiness Status | Key Risk | Next Action | Owner | Due |
|---|---:|---:|---:|---|---|---|---|---|
| OKPOS | A/B/F/G | P0 | Tier 0-1 | Research | Large installed base, closed/hybrid integration, local field dependency | Verify official API/partner route and field fallback assumptions |  |  |
| KIS OKPOS | A/B/F/G | P0 | Tier 0-1 | Research | Franchise/payment-linked custom environment | Confirm KIS-specific integration and certification path |  |  |
| KICC EasyPos | A/B/F | P0 | Tier 0-1 | Research | Legacy/hybrid VAN-linked structure | Verify official technical route and local DB/device constraints |  |  |
| Toss Place | C/F | P1 | Tier 2 | Contact Needed | API/plugin policy and payment boundary dependency | Request official API/plugin/webhook onboarding path |  |  |
| Payhere | C/D | P1 | Tier 2 | Contact Needed | API openness and dashboard/order scope unknown | Verify product/menu/order API and multilingual data scope |  |  |
| PAYCO-related provider flow | F | P1/P2 | Tier 1-2 | Research | Payment authority, callback, refund, settlement boundary | Verify official payment/provider integration route |  |  |
| POSBANK device environment | E | P2 | Tier 0-1 | Deferred | Hardware compatibility and device boundary | Treat as device inventory and future kiosk compatibility review |  |  |
| IMU POS | A/E | P2 | Tier 0-1 | Deferred | Hardware-integrated Windows environment | Review only when pilot store uses IMU/UP POS |  |  |
| Local franchise POS vendor | G | P3 | Tier 0 | Unknown | Custom workflow and unknown openness | Add row when pilot store identifies vendor |  |  |
| Unknown small POS vendor | A/G | P3/P4 | Tier 0 | Unknown | No official route, high field risk | Manual fallback only until official path exists |  |  |

## 6. Required Fields For Each Provider Row

Each provider row must eventually record:

| Field | Required |
|---|---|
| provider_id | Yes |
| provider_name | Yes |
| brand_name | Yes |
| provider_class | Yes |
| priority | Yes |
| target_integration_tier | Yes |
| official_api_status | Yes |
| webhook_status | Yes |
| sdk_plugin_status | Yes |
| sandbox_status | Yes |
| payment_scope | Yes |
| settlement_scope | Yes |
| store_pilot_candidate | Yes |
| fallback_required | Yes |
| readiness_status | Yes |
| next_action | Yes |
| owner | Yes before pilot |
| decision_date | Yes before pilot |

## 7. Readiness Score

Use the following scoring model when a provider becomes a real candidate.

| Score Area | Points |
|---|---:|
| Official API confirmed | 20 |
| Sandbox/test account available | 15 |
| Webhook signature and replay support | 15 |
| Payment boundary clear | 15 |
| Store pilot candidate ready | 10 |
| Support escalation channel exists | 10 |
| Manual fallback verified | 10 |
| Reconciliation evidence possible | 5 |

| Score | Decision |
|---:|---|
| 80-100 | Strong pilot candidate |
| 60-79 | Candidate with conditions |
| 40-59 | Limited test or evidence-only |
| 0-39 | Manual fallback / monitor only |

## 8. Block Reason Codes

| Code | Meaning |
|---|---|
| NO_OFFICIAL_API | No official integration path confirmed |
| NO_SANDBOX | No test environment available |
| CLOSED_PARTNER_ONLY | Integration available only to approved partners |
| PAYMENT_SCOPE_UNCLEAR | Payment responsibility unclear |
| SETTLEMENT_SCOPE_UNCLEAR | Settlement/reconciliation path unclear |
| CALLBACK_UNSAFE | Callback lacks signature/replay protection |
| LOCAL_DB_REQUIRED | Provider requires direct local DB manipulation |
| DEVICE_DEPENDENT | Integration depends on hardware driver/device control |
| SUPPORT_UNAVAILABLE | Provider technical escalation unavailable |
| STORE_NOT_READY | Pilot store lacks fallback/readiness |
| CONTRACT_REQUIRED | Contract/certification gate not complete |
| SECURITY_REVIEW_REQUIRED | Security controls incomplete |

## 9. Next Action Types

| Action | Meaning |
|---|---|
| Verify Official API | Request official documentation and access route |
| Verify Contract Gate | Confirm partner/certification requirement |
| Verify Sandbox | Confirm test account or sandbox |
| Create Evidence Packet | Start provider evidence packet |
| Run Adapter Feasibility Review | Check adapter boundary requirements |
| Run Store Readiness Review | Check store/POS/device/fallback conditions |
| Keep Manual Fallback | Do not integrate directly |
| Defer To Later Phase | Revisit after MVP |
| Archive | Keep as reference only |
| Escalate To Legal/Security | Payment/data/security risk requires review |

## 10. Operating Rule

The register must be updated whenever:

- a new POS provider is discovered at a pilot store
- official API information is obtained
- provider access is denied
- provider access is approved
- sandbox becomes available
- payment scope changes
- provider documentation changes
- integration tier changes
- pilot approval is granted or rejected
- incident or reconciliation mismatch occurs

## 11. MVP Cutline

During MVP, a provider should not move beyond Tier 2 unless all of the following are true:

1. Official provider interface is confirmed.
2. Store owner approval exists.
3. Adapter boundary is configured.
4. Manual fallback is trained.
5. Evidence packet exists.
6. Reconciliation path exists.
7. Security/payment controls are reviewed.
8. Rollback path exists.

Payment-aware Tier 3+ requires additional financial and security review.

## 12. Relationship To Evidence Packet

The register is the summary-level control document.

Each real integration candidate must link to a provider-specific evidence packet.

Register row:

- one row per provider/provider-flow

Evidence packet:

- one packet per provider/store/pilot candidate

## 13. Deferred Backlog

Initial deferred backlog:

| Item | Reason |
|---|---|
| POSBANK hardware environment | hardware compatibility, not core MVP integration |
| IMU POS | field-specific, hardware-integrated |
| unknown local POS vendors | no official interface until identified |
| deep OKPOS/KICC integration | requires official route and certification |
| payment execution integration | not MVP unless financial gate passes |

## 14. Related Documents

- 14020_Report_Domestic_POS_Industry_Ecosystem_Market_Architecture_And_Limitations.md
- 14030_Policy_POS_Provider_Architecture_Classification_And_Gateway_Integration_Strategy.md
- 14040_Checklist_POS_Gateway_Risk_Failure_Mode_And_Field_Readiness.md
- 14050_Matrix_POS_Provider_Priority_Openness_Risk_And_MVP_Fit.md
- 14070_Spec_POS_Provider_Adapter_Boundary_And_Evidence_Contract.md
- 14080_Checklist_POS_Provider_Onboarding_Certification_And_Pilot_Readiness.md
- 14090_Template_POS_Provider_Integration_Evidence_Packet.md
- 20000_Validation_Security_Audit
- 20400_foundation_security
