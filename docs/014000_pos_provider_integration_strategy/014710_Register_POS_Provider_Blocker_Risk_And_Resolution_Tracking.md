# 014710_Register_POS_Provider_Blocker_Risk_And_Resolution_Tracking.md

## 1. Purpose

This register tracks blockers, unresolved risks, and required resolution actions discovered during POS provider verification, onboarding, official response assessment, adapter planning, and pilot readiness review.

The domestic POS ecosystem includes legacy Windows POS, Android/cloud-native POS, VAN/PG-linked payment systems, hardware-first POS/kiosk environments, and franchise-specific custom deployments. Because of this fragmentation, provider blockers must be tracked explicitly rather than handled through informal notes.

## 2. Core Rule

A provider blocker must be recorded when it can prevent or limit integration tier advancement.

No provider may move to a higher integration tier while an unresolved critical blocker exists.

## 3. Blocker Severity

| Severity | Meaning | Integration Impact |
|---|---|---|
| S0 | Critical unsafe condition | Blocks all integration except manual fallback |
| S1 | Major unresolved risk | Blocks Tier 2+ or Tier 3+ depending on scope |
| S2 | Conditional risk | Allows limited pilot with controls |
| S3 | Monitoring risk | Does not block pilot but must be tracked |

## 4. Blocker Status

| Status | Meaning |
|---|---|
| Open | Blocker has been identified and is unresolved |
| In Review | Owner is reviewing evidence or provider response |
| Waiting Provider | Waiting for POS/provider answer |
| Waiting Contract | Waiting for legal/partner/certification step |
| Waiting Security | Waiting for credential/payment/security review |
| Waiting Store | Waiting for store readiness or owner approval |
| Mitigated | Temporary control exists |
| Resolved | Blocker is fully resolved |
| Accepted Risk | Owner accepted risk with documented condition |
| Deferred | Moved to later phase |
| Closed | No longer applicable |

## 5. Blocker Register

| Blocker ID | Provider | Severity | Status | Blocker Type | Description | Blocks Tier | Owner | Due | Resolution Condition |
|---|---|---:|---|---|---|---:|---|---|---|
| BLK-POS-001 | OKPOS | S1 | Open | OFFICIAL_INTERFACE | Official API/partner route not yet verified | Tier 2+ |  |  | Official route confirmed or MVP limited to manual/evidence |
| BLK-POS-002 | KIS OKPOS | S1 | Open | CERTIFICATION | KIS-specific approval/certification route unknown | Tier 2+ |  |  | Partner/certification path confirmed |
| BLK-POS-003 | KICC EasyPos | S1 | Open | LEGACY_DEPENDENCY | Local/hybrid architecture and device dependency unknown | Tier 2+ |  |  | Field architecture and official interface confirmed |
| BLK-POS-004 | Toss Place | S2 | Open | API_OPENNESS | Official API/plugin/webhook route must be verified | Tier 3+ |  |  | Official docs and sandbox confirmed |
| BLK-POS-005 | Payhere | S2 | Open | API_OPENNESS | Product/menu/order API scope unknown | Tier 3+ |  |  | API scope and sandbox confirmed |
| BLK-POS-006 | PAYCO Flow | S1 | Open | PAYMENT_SCOPE | Payment/callback/refund/settlement boundary unclear | Tier 3+ |  |  | Payment responsibility and reconciliation controls confirmed |
| BLK-POS-007 | Unknown Local POS | S0 | Open | UNKNOWN_PROVIDER | No official provider path known | Tier 1+ |  |  | Provider identified and official route verified |

## 6. Blocker Types

| Type | Meaning |
|---|---|
| OFFICIAL_INTERFACE | API/SDK/webhook route is missing or unverified |
| CONTRACT | Contract or partner approval is required |
| CERTIFICATION | Provider certification is required |
| SECURITY | Credential, signature, replay, data, or access control issue |
| PAYMENT_SCOPE | Payment execution/observation responsibility unclear |
| SETTLEMENT_SCOPE | Settlement/reconciliation data unclear |
| CALLBACK_UNSAFE | Webhook/callback lacks required controls |
| SANDBOX | Test account or sandbox unavailable |
| LEGACY_DEPENDENCY | Local DB, DLL, driver, or Windows client dependency |
| DEVICE_DEPENDENCY | Printer, KDS, terminal, signpad, cash drawer dependency |
| STORE_READINESS | Store owner/staff/network/fallback readiness incomplete |
| SUPPORT | Provider escalation channel unavailable |
| FRANCHISE_CUSTOM | Franchise-specific workflow unknown |
| UNKNOWN_PROVIDER | Provider not yet identified or classified |

## 7. Required Blocker Fields

Each blocker must include:

| Field | Required |
|---|---|
| blocker_id | Yes |
| provider_id | Yes |
| provider_name | Yes |
| blocker_type | Yes |
| severity | Yes |
| status | Yes |
| description | Yes |
| affected_integration_tier | Yes |
| risk_if_unresolved | Yes |
| owner | Yes before pilot |
| due_date | Yes for active provider |
| resolution_condition | Yes |
| evidence_reference | Yes if available |
| decision_reference | Yes if accepted/deferred |

## 8. Integration Tier Impact Rule

| Blocker Type | Default Tier Impact |
|---|---|
| NO_OFFICIAL_API | Blocks Tier 2+ |
| NO_SANDBOX | Blocks prototype/pilot |
| CALLBACK_UNSAFE | Blocks webhook-based Tier 2+ and Tier 3+ |
| PAYMENT_SCOPE_UNCLEAR | Blocks Tier 3+ |
| SETTLEMENT_SCOPE_UNCLEAR | Blocks settlement/reconciliation claim |
| LOCAL_DB_REQUIRED | Blocks direct integration unless official |
| DEVICE_DEPENDENT | Blocks automation beyond controlled pilot |
| SUPPORT_UNAVAILABLE | Blocks production pilot |
| STORE_NOT_READY | Blocks store pilot |
| CONTRACT_REQUIRED | Blocks official integration |
| CERTIFICATION_REQUIRED | Blocks Tier 4+ |

## 9. Resolution Evidence

A blocker can be marked resolved only when evidence exists.

Acceptable evidence includes:

- official provider documentation
- provider technical email or support ticket
- sandbox/test account confirmation
- partner/certification approval
- signed contract or written authorization
- security review approval
- payment/settlement control review
- store owner approval
- completed fallback training record
- successful test transaction evidence
- reconciliation test evidence
- approved risk acceptance record

## 10. Risk Acceptance Rule

A blocker may be accepted only if:

1. The affected tier is explicitly limited.
2. The risk owner is named.
3. Manual fallback exists.
4. Evidence logging remains active.
5. Customer-facing wording is safe.
6. Rollback/disable path exists.
7. The acceptance has an expiry or review date.

Accepted risk must not silently become permanent architecture.

## 11. Blocker Escalation

Escalate blocker when:

| Condition | Escalation |
|---|---|
| Payment scope unclear | Finance/security owner |
| Credential handling unclear | Security owner |
| Provider contract required | Legal/business owner |
| Store cannot fallback | Operations owner |
| Provider requires local DB write | Architecture owner |
| Callback unsafe | Security + gateway owner |
| Pilot date at risk | Product owner |

## 12. Provider Blocker Review Cadence

| Provider Status | Review Cadence |
|---|---|
| P1 active verification | Weekly |
| Pilot candidate | Twice weekly until resolved |
| Blocked but strategic | Monthly |
| Deferred | Per phase planning |
| Archive/monitor | No regular review |

## 13. Relationship To Other Documents

This register must link to:

- provider readiness register
- official response assessment
- evidence packet
- adapter boundary spec
- pilot checklist
- security review queue
- implementation backlog

## 14. Current Known Initial Blockers

Initial blockers based on POS ecosystem analysis:

| Provider / Area | Blocker |
|---|---|
| OKPOS | Official integration route and local/hybrid field behavior must be confirmed |
| KIS OKPOS | Certification and KIS-specific integration constraints must be confirmed |
| KICC EasyPos | Legacy architecture, local DB behavior, and official route must be confirmed |
| Toss Place | Official plugin/API/webhook route and sandbox must be confirmed |
| Payhere | API openness, product/menu/order scope, and sandbox must be confirmed |
| PAYCO-related flow | Payment/refund/callback/settlement responsibility must be confirmed |
| Hardware-first environments | Device dependency must be separated from software MVP |
| Unknown local POS | Manual fallback only until provider is identified |

## 15. Non-Goals

This register does not resolve blockers by itself.

It does not define:

- implementation design
- legal contract terms
- payment execution logic
- settlement accounting design
- production rollout decision

It only tracks unresolved provider risks and required resolution actions.

## 16. Related Documents

- 14120_Assessment_POS_Provider_Official_Response_And_Integration_Disposition.md
- 14110_Template_POS_Provider_Official_Verification_Request.md
- 14100_Register_POS_Provider_Readiness_Status_And_Next_Action.md
- 14090_Template_POS_Provider_Integration_Evidence_Packet.md
- 14080_Checklist_POS_Provider_Onboarding_Certification_And_Pilot_Readiness.md
- 14070_Spec_POS_Provider_Adapter_Boundary_And_Evidence_Contract.md
- 14040_Checklist_POS_Gateway_Risk_Failure_Mode_And_Field_Readiness.md
- 20000_Validation_Security_Audit
- 20400_foundation_security
