# 014110_Template_POS_Provider_Official_Verification_Request.md

## 1. Purpose

This template defines the official verification request format used when Catch & Order contacts a POS provider, VAN/PG-linked provider, payment provider, or hardware/POS vendor to confirm integration feasibility.

The purpose is to avoid informal assumptions about API availability, webhook support, sandbox access, certification, payment scope, and production activation.

This template may be used as an email, support-ticket body, partner inquiry memo, or internal checklist before contacting the provider.

## 2. When To Use

Use this template when verifying:

- OKPOS integration route
- KIS OKPOS integration route
- KICC EasyPos integration route
- Toss Place API/plugin/webhook availability
- Payhere API/dashboard/order integration availability
- PAYCO-related payment/provider integration
- POSBANK or hardware-first environment compatibility
- IMU POS / UP POS integration route
- local franchise POS vendor integration feasibility
- unknown POS provider discovered during pilot-store onboarding

## 3. Request Header

| Field | Value |
|---|---|
| request_id |  |
| provider_name |  |
| provider_brand |  |
| requested_by |  |
| company/project | Catch & Order / Yoonsul Wait Order Handoff |
| request_date |  |
| target_store_or_franchise |  |
| requested_integration_tier | Tier 0 / 1 / 2 / 3 / 4 / 5 |
| urgency | Research / Pilot Candidate / Production Candidate |
| contact_channel | Email / Support Ticket / Partner Portal / Sales Contact / Technical Contact |

## 4. Short Introduction

Use the following short introduction when contacting a provider.

```text
안녕하세요.

저희는 외식 매장의 대기, 주문, 입장, 테이블 매칭, POS/KDS 핸드오프를 단계적으로 연결하는 Catch & Order 서비스를 준비하고 있습니다.

귀사의 POS/결제/매장 운영 시스템과 공식적으로 연동 가능한 범위가 있는지 확인하고자 문의드립니다. 비공식 로컬 DB 접근이나 화면 스크래핑이 아니라, 귀사에서 승인한 공식 API, SDK, Webhook, Plugin, Partner 연동 절차가 있는지 확인하려는 목적입니다.

아래 항목에 대해 가능한 범위에서 안내 부탁드립니다.
```

## 5. Provider Classification Questions

| Question | Provider Answer |
|---|---|
| 귀사 POS/서비스의 기본 운영 환경은 Windows, Android, iOS, Web, Cloud 중 무엇입니까? |  |
| 매장 단말 내부 로컬 DB에 주문/결제 데이터가 저장됩니까? |  |
| 중앙 서버/클라우드와 실시간 동기화 구조입니까, 배치 동기화 구조입니까? |  |
| 프랜차이즈별 커스텀 POS 흐름이 별도 존재합니까? |  |
| KDS, 주방 프린터, CAT 단말기, 싸인패드, 현금함 연동을 공식 지원합니까? |  |

## 6. Official API Questions

| Question | Provider Answer |
|---|---|
| 외부 서비스가 주문 정보를 전송할 수 있는 공식 API가 있습니까? |  |
| 외부 서비스가 주문 상태를 조회할 수 있는 공식 API가 있습니까? |  |
| 외부 서비스가 취소/정정 요청을 전달할 수 있는 공식 API가 있습니까? |  |
| 결제 상태를 조회하거나 수신할 수 있는 공식 API가 있습니까? |  |
| 매출/정산/마감 데이터를 조회할 수 있는 공식 API가 있습니까? |  |
| 메뉴/상품/옵션 데이터를 조회하거나 동기화할 수 있는 공식 API가 있습니까? |  |
| API 문서 제공 방식은 공개 문서, 파트너 문서, NDA 문서 중 무엇입니까? |  |
| API 사용을 위해 파트너 계약 또는 심사가 필요합니까? |  |

## 7. Webhook / Callback Questions

| Question | Provider Answer |
|---|---|
| 주문 생성/수락/취소/변경 이벤트 Webhook을 제공합니까? |  |
| 결제 승인/취소/환불 이벤트 Webhook을 제공합니까? |  |
| Webhook 서명 검증 방식을 제공합니까? |  |
| Webhook timestamp 또는 replay 방지 키를 제공합니까? |  |
| Webhook 재전송 정책이 있습니까? |  |
| Webhook 실패 시 retry 정책은 어떻게 됩니까? |  |
| 중복 callback 발생 시 권장 처리 방식이 있습니까? |  |

## 8. SDK / Plugin Questions

| Question | Provider Answer |
|---|---|
| 외부 서비스가 POS 화면 또는 기능을 확장할 수 있는 SDK/Plugin 구조가 있습니까? |  |
| Plugin이 WebView, native module, app marketplace, partner app 중 어떤 방식으로 동작합니까? |  |
| Plugin sandbox 정책이 있습니까? |  |
| Plugin이 결제/주문 핵심 흐름에 접근할 수 있는 범위는 어디까지입니까? |  |
| SDK/Plugin 버전 변경 시 하위 호환 정책이 있습니까? |  |

## 9. Sandbox And Test Questions

| Question | Provider Answer |
|---|---|
| 개발용 sandbox 또는 test store를 제공합니까? |  |
| 테스트용 주문/결제/취소/환불 시나리오를 제공합니까? |  |
| 실제 결제 없이 테스트 가능한 환경이 있습니까? |  |
| 테스트 계정 발급 조건은 무엇입니까? |  |
| production 전환 절차는 어떻게 됩니까? |  |
| pilot store 단위로 제한 activation이 가능합니까? |  |

## 10. Payment And Settlement Questions

| Question | Provider Answer |
|---|---|
| 외부 서비스가 결제를 직접 실행할 수 있습니까? |  |
| 외부 서비스는 결제 상태 관찰만 가능한 구조입니까? |  |
| 결제 승인번호, VAN/PG reference, 거래번호를 받을 수 있습니까? |  |
| 취소/환불/정정 이벤트를 받을 수 있습니까? |  |
| 일마감/정산 대사에 필요한 데이터를 받을 수 있습니까? |  |
| 결제 데이터 처리와 관련하여 별도 보안 심사 또는 계약이 필요합니까? |  |
| 소비자 보호 또는 분쟁 대응을 위한 증적 보관 정책이 있습니까? |  |

## 11. Security And Credential Questions

| Question | Provider Answer |
|---|---|
| API 인증 방식은 무엇입니까? | API Key / OAuth / HMAC / mTLS / Other |
| 매장별 credential과 파트너 credential이 분리됩니까? |  |
| credential rotation 정책이 있습니까? |  |
| IP allowlist 또는 domain allowlist가 필요합니까? |  |
| 요청 서명 또는 payload hash 검증을 지원합니까? |  |
| API 접근 로그 또는 감사 로그를 제공합니까? |  |
| 개인정보/결제정보 관련 보안 기준 문서가 있습니까? |  |

## 12. Operational Questions

| Question | Provider Answer |
|---|---|
| 장애 발생 시 기술 지원 escalation 채널이 있습니까? |  |
| API 장애 공지 또는 status page가 있습니까? |  |
| 매장 단위 기능 비활성화 또는 rollback이 가능합니까? |  |
| POS 단말 교체, OS 업데이트, 앱 업데이트 시 연동 영향이 있습니까? |  |
| 프린터/KDS/CAT 단말 장애 시 외부 서비스에 전달되는 상태가 있습니까? |  |
| 영업 중 장애 발생 시 권장 fallback 절차가 있습니까? |  |

## 13. Requested Documents

Ask the provider for the following documents if available:

| Document | Requested |
|---|---|
| API documentation | Yes |
| Webhook specification | Yes |
| SDK/plugin documentation | If applicable |
| Sandbox/test guide | Yes |
| Partner onboarding guide | Yes |
| Certification checklist | If required |
| Security/credential guide | Yes |
| Payment/refund/cancel guide | If payment-aware |
| Settlement/reconciliation guide | If available |
| Incident escalation guide | If available |
| Production activation checklist | Yes |

## 14. Provider Response Summary

After receiving the provider response, summarize it here.

| Item | Result |
|---|---|
| Official interface status | Confirmed / Not available / Unknown |
| Sandbox status | Available / Not available / Unknown |
| Webhook status | Available / Not available / Unknown |
| Payment scope | None / Observe / Execute / Unknown |
| Certification required | Yes / No / Unknown |
| Contract required | Yes / No / Unknown |
| Support escalation | Available / Not available / Unknown |
| MVP integration fit | High / Medium / Low / Blocked |
| Recommended next action |  |

## 15. Internal Disposition

| Decision | Meaning |
|---|---|
| Proceed To Evidence Packet | Official path is clear enough to create provider evidence packet |
| Keep Research | More information required |
| Evidence-Only | API path limited; keep as reference/fallback |
| Manual Fallback Only | No safe integration route |
| Contract Review Required | Legal/partner contract required |
| Security Review Required | Credential/payment/data control required |
| Blocked | Unsafe or unavailable integration |
| Deferred | Revisit later |

## 16. Internal Notes For Catch & Order

When using this template:

- Do not promise production integration.
- Do not promise payment execution.
- Do not accept undocumented local DB access as official integration.
- Do not use owner credentials as system credentials.
- Do not proceed without fallback.
- Do not treat webhook presence as sufficient unless signature and replay controls exist.
- Do not move beyond Tier 2 if payment/settlement scope is unclear.
- Always convert provider response into an evidence packet and readiness register update.

## 17. Related Documents

- 14020_Report_Domestic_POS_Industry_Ecosystem_Market_Architecture_And_Limitations.md
- 14030_Policy_POS_Provider_Architecture_Classification_And_Gateway_Integration_Strategy.md
- 14040_Checklist_POS_Gateway_Risk_Failure_Mode_And_Field_Readiness.md
- 14050_Matrix_POS_Provider_Priority_Openness_Risk_And_MVP_Fit.md
- 14070_Spec_POS_Provider_Adapter_Boundary_And_Evidence_Contract.md
- 14080_Checklist_POS_Provider_Onboarding_Certification_And_Pilot_Readiness.md
- 14090_Template_POS_Provider_Integration_Evidence_Packet.md
- 14100_Register_POS_Provider_Readiness_Status_And_Next_Action.md
