# 014250_Register_POS_Provider_First_Verification_Blocker_Summary.md

## 1. Purpose

This register summarizes blockers discovered during the first POS provider verification wave.

It is used after provider contact logs and response summaries have been created.

The purpose is to convert unanswered provider questions into explicit blocker records, follow-up actions, owner assignments, and tier limits.

## 2. Core Rule

Unknown is a blocker.

If a provider has not clearly answered a required technical, security, payment, sandbox, or contract question, the provider must remain blocked from higher integration tiers.

## 3. Blocker Summary Table

| Provider | Blocker Area | Current Answer | Severity | Blocks Tier | Owner | Next Action | Status |
|---|---|---|---:|---:|---|---|---|
| Toss Place | Official API / Plugin route | Unknown | S2 | Tier 2+ |  | Request technical docs | Open |
| Toss Place | Webhook security | Unknown | S2 | Tier 2+ |  | Ask signature/timestamp/replay details | Open |
| Toss Place | Sandbox/test store | Unknown | S2 | Prototype |  | Request sandbox/test path | Open |
| Payhere | API/menu/order scope | Unknown | S2 | Tier 2+ |  | Request API scope | Open |
| Payhere | Sandbox/test account | Unknown | S2 | Prototype |  | Request test account | Open |
| Payhere | Payment/cancel/refund observation | Unknown | S1 | Tier 3+ |  | Escalate payment review | Open |
| PAYCO-related flow | Payment callback scope | Unknown | S1 | Tier 3+ |  | Request payment event docs | Open |
| PAYCO-related flow | Settlement/reconciliation data | Unknown | S1 | Tier 3+ |  | Request settlement reference data | Open |
| PAYCO-related flow | Credential/store scope | Unknown | S1 | Tier 3+ |  | Request credential model | Open |
| OKPOS | Official API/partner route | Unknown | S1 | Tier 2+ |  | Request official partner route | Open |
| OKPOS | Local DB prohibition/allowed route | Unknown | S1 | Tier 2+ |  | Confirm no unofficial local DB path | Open |
| OKPOS | Certification requirement | Unknown | S1 | Tier 2+ |  | Ask partner/certification path | Open |
| KIS OKPOS | KIS-specific certification | Unknown | S1 | Tier 2+ |  | Ask KIS certification route | Open |
| KIS OKPOS | Payment/VAN boundary | Unknown | S1 | Tier 3+ |  | Escalate finance/security review | Open |
| KICC EasyPos | Legacy/VAN official route | Unknown | S1 | Tier 2+ |  | Request official technical route | Open |
| KICC EasyPos | Sandbox/test environment | Unknown | S2 | Prototype |  | Request test path | Open |

## 4. Blocker Severity Rule

| Severity | Meaning | Default Action |
|---|---|---|
| S0 | Unsafe or prohibited | Block provider or downgrade to manual fallback |
| S1 | Critical unknown for integration | Block Tier 2+ or Tier 3+ |
| S2 | Missing readiness evidence | Block prototype or pilot |
| S3 | Monitoring issue | Track but does not block current tier |

## 5. Tier Limit By Blocker

| Blocker | Maximum Allowed Tier |
|---|---:|
| Official API route unknown | Tier 1 |
| Sandbox/test path unknown | Tier 1 |
| Webhook security unknown | Tier 1 |
| Payment/cancel/refund scope unknown | Tier 2 maximum, Tier 3 blocked |
| Settlement/reconciliation data unknown | Tier 2 maximum, Tier 3 blocked |
| Credential scope unknown | Tier 1 |
| Contract/certification unknown | Tier 1 or evidence-only |
| Provider support path unknown | No pilot |
| Local DB access required | Manual fallback only unless official approval exists |

## 6. Provider Follow-Up Queue

| Follow-Up ID | Provider | Question | Required Output | Due | Owner | Status |
|---|---|---|---|---|---|---|
| FU-001 | Toss Place | Is there an official API/plugin/webhook route? | Official docs or unsupported statement |  |  | Open |
| FU-002 | Toss Place | Is sandbox/test store available? | Sandbox/test path |  |  | Open |
| FU-003 | Payhere | What API scopes exist for menu/order/payment observation? | API scope summary |  |  | Open |
| FU-004 | PAYCO-related flow | What payment/refund/callback/settlement events are available? | Payment event docs |  |  | Open |
| FU-005 | OKPOS | What is the official partner/certification route? | Partner/certification path |  |  | Open |
| FU-006 | KIS OKPOS | What approval is needed for KIS OKPOS and payment-linked integration? | Certification/security answer |  |  | Open |
| FU-007 | KICC EasyPos | Is there a safe official route outside local DB or screen scraping? | Official technical answer |  |  | Open |

## 7. Escalation Rules

Escalate blockers as follows:

| Blocker Area | Escalation Owner |
|---|---|
| Payment/cancel/refund/settlement | Payment/finance owner |
| Credential/webhook/security | Security owner |
| Contract/certification | Business/legal owner |
| Local DB/device dependency | Architecture owner |
| Store fallback readiness | Store operation owner |
| Provider support gap | Support owner |
| Tier decision conflict | Product owner |

## 8. Decision Impact

| Provider | Current Recommended Disposition |
|---|---|
| Toss Place | Research / follow-up; possible candidate if API+webhook+sandbox confirmed |
| Payhere | Research / follow-up; possible candidate if API+test path confirmed |
| PAYCO-related flow | Payment/security review required before Tier 3 |
| OKPOS | Manual fallback/evidence until official route confirmed |
| KIS OKPOS | Manual fallback/evidence until certification/payment boundary confirmed |
| KICC EasyPos | Manual fallback/evidence until official route confirmed |
| POSBANK | Device/hardware review only |
| IMU POS / UP POS | Store-specific review only |

## 9. Blocker Close Conditions

A blocker can be closed only when one of the following exists:

- provider provides official documentation
- provider confirms unsupported path
- provider confirms sandbox/test path
- provider confirms contract/certification route
- provider confirms webhook security model
- provider confirms payment/refund/cancel/settlement scope
- internal owner formally accepts limited risk
- decision gate downgrades provider to manual fallback/evidence-only

## 10. Required Register Updates

After this summary:

1. Update 14130 provider blocker register.
2. Update 14220 contact log.
3. Update 14240 response summary.
4. Update 14100 readiness register.
5. Create follow-up messages where needed.
6. Prepare 14090 evidence packet only for providers with sufficient official route.

## 11. Non-Goals

This summary does not resolve blockers.

It does not approve:

- provider implementation
- payment execution
- production pilot
- franchise rollout
- provider contract

It only makes unresolved verification risks visible and actionable.

## 12. Related Documents

- 14240_Assessment_POS_Provider_First_Verification_Response_Summary.md
- 14230_Template_POS_Provider_First_Verification_Request_Packet.md
- 14220_Register_POS_Provider_First_Verification_Contact_Log.md
- 14210_WorkPackage_POS_Provider_First_Verification_Wave_And_Contact_Backlog.md
- 14130_Register_POS_Provider_Blocker_Risk_And_Resolution_Tracking.md
- 14140_Governance_POS_Provider_Integration_Decision_Gate.md
- 14100_Register_POS_Provider_Readiness_Status_And_Next_Action.md
- 14090_Template_POS_Provider_Integration_Evidence_Packet.md
