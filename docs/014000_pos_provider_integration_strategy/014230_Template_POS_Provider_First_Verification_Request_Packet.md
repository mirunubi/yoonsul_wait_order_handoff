# 014230_Template_POS_Provider_First_Verification_Request_Packet.md

## 1. Purpose

This packet contains first-wave official verification request drafts for POS and payment provider candidates.

It converts the general provider verification template into provider-specific first-contact messages.

The goal is to confirm official integration feasibility before any implementation work begins.

## 2. Core Rule

These messages must not promise production integration, payment execution, or commercial partnership.

They only ask whether an official and safe integration route exists.

## 3. Common Request Scope

Each request asks for:

- official API availability
- SDK/plugin availability
- webhook/callback availability
- sandbox or test account
- partner/certification requirement
- order handoff support
- order status support
- payment observation support
- cancellation/refund/correction support
- credential/security requirements
- support escalation path
- production activation process

## 4. Toss Place Verification Request Draft

```text
안녕하세요.

저희는 외식 매장의 대기, 주문, 입장, 테이블 매칭, POS/KDS 핸드오프를 단계적으로 연결하는 Catch & Order 서비스를 준비하고 있습니다.

토스플레이스/토스포스와 공식적으로 연동 가능한 API, Plugin, SDK, Webhook 또는 파트너 연동 절차가 있는지 확인하고자 문의드립니다.

확인 요청 항목은 아래와 같습니다.

1. 외부 서비스가 주문 정보를 토스포스에 전달할 수 있는 공식 API 또는 Plugin 구조가 있습니까?
2. 주문 상태 변경, 주문 수락, 주문 취소, 정정 이벤트를 Webhook으로 받을 수 있습니까?
3. Webhook 서명 검증, timestamp, replay 방지 키가 제공됩니까?
4. 개발용 sandbox 또는 test store를 제공합니까?
5. 파트너 계약, 심사, 인증 또는 별도 승인 절차가 필요합니까?
6. 결제 상태는 외부 서비스가 관찰할 수 있습니까?
7. 결제 승인, 취소, 환불 관련 이벤트를 받을 수 있습니까?
8. production 전환은 매장 단위로 제한 activation이 가능합니까?
9. 기술 지원 escalation 채널이 별도로 있습니까?
10. 공식 API/Plugin/Webhook 문서 또는 파트너 안내 자료를 제공받을 수 있습니까?

저희는 비공식 로컬 DB 접근이나 화면 스크래핑을 전제로 하지 않습니다.
귀사에서 승인한 공식 연동 경로가 있는지 확인하려는 목적입니다.

감사합니다.
```

## 5. Payhere Verification Request Draft

```text
안녕하세요.

저희는 외식 매장의 대기, 주문, 입장, 테이블 매칭, POS/KDS 핸드오프를 단계적으로 연결하는 Catch & Order 서비스를 준비하고 있습니다.

페이히어 POS/대시보드/주문 관련 기능과 공식적으로 연동 가능한 API, Webhook, SDK 또는 파트너 절차가 있는지 확인하고자 문의드립니다.

확인 요청 항목은 아래와 같습니다.

1. 외부 서비스가 주문 정보를 페이히어 POS 또는 대시보드로 전달할 수 있는 공식 API가 있습니까?
2. 메뉴, 상품, 옵션, 다국어 상품 정보를 조회하거나 동기화할 수 있는 API가 있습니까?
3. 주문 상태, 취소, 정정 이벤트를 조회하거나 수신할 수 있습니까?
4. Webhook 또는 callback을 제공합니까?
5. Webhook 서명 검증 및 replay 방지 기능이 있습니까?
6. 개발용 sandbox 또는 test account를 제공합니까?
7. 외부 서비스가 결제 상태를 관찰할 수 있는 공식 범위가 있습니까?
8. 파트너 계약, 심사, 인증 절차가 필요합니까?
9. production activation을 매장 단위로 제한할 수 있습니까?
10. 공식 기술 문서 또는 파트너 안내 자료를 제공받을 수 있습니까?

저희는 귀사에서 승인한 공식 연동 경로만 검토하고 있습니다.

감사합니다.
```

## 6. OKPOS Verification Request Draft

```text
안녕하세요.

저희는 외식 매장의 대기, 주문, 입장, 테이블 매칭, POS/KDS 핸드오프를 단계적으로 연결하는 Catch & Order 서비스를 준비하고 있습니다.

오케이포스와 외부 서비스가 공식적으로 연동할 수 있는 API, 파트너 연동, 인증 절차가 있는지 확인하고자 문의드립니다.

확인 요청 항목은 아래와 같습니다.

1. 외부 서비스가 주문 정보를 오케이포스에 전달할 수 있는 공식 API 또는 승인된 연동 방식이 있습니까?
2. 주문 상태, 취소, 정정, 결제 상태를 조회하거나 수신할 수 있는 공식 경로가 있습니까?
3. 매장 POS 단말의 로컬 DB 직접 접근 없이 연동 가능한 방식이 있습니까?
4. KDS, 주방 프린터, CAT 단말, 결제 단말 상태와 관련된 공식 연동 범위가 있습니까?
5. 개발용 테스트 환경 또는 테스트 매장을 제공합니까?
6. 파트너 계약, 심사, 인증 또는 대리점 협의가 필요합니까?
7. Webhook 또는 callback 방식이 있다면 서명 검증 및 replay 방지를 지원합니까?
8. production 적용을 매장 단위로 제한할 수 있습니까?
9. 장애 발생 시 기술 지원 escalation 채널이 있습니까?
10. 공식 연동 문서 또는 파트너 안내 자료를 제공받을 수 있습니까?

저희는 비공식 로컬 DB 수정, 화면 스크래핑, 단말 직접 조작 방식은 검토하지 않습니다.
공식적으로 승인 가능한 연동 경로가 있는지 확인하려는 목적입니다.

감사합니다.
```

## 7. KIS OKPOS Verification Request Draft

```text
안녕하세요.

저희는 외식 매장의 대기, 주문, 입장, 테이블 매칭, POS/KDS 핸드오프를 단계적으로 연결하는 Catch & Order 서비스를 준비하고 있습니다.

KIS OKPOS 환경에서 외부 서비스가 공식적으로 주문, 결제 상태, KDS/프린터 흐름과 연동할 수 있는 범위가 있는지 확인하고자 문의드립니다.

확인 요청 항목은 아래와 같습니다.

1. KIS OKPOS 전용 공식 API 또는 승인된 외부 연동 방식이 있습니까?
2. 주문 생성, 주문 상태, 취소, 정정 이벤트 연동이 가능합니까?
3. 결제 승인, 취소, 환불, 정산 관련 상태를 외부 서비스가 관찰할 수 있습니까?
4. KIS 결제 단말 또는 VAN 연동과 관련된 인증 절차가 필요합니까?
5. 개발용 테스트 환경 또는 테스트 매장 설정이 가능합니까?
6. Webhook/callback이 있다면 서명 검증 및 replay 방지를 지원합니까?
7. 프랜차이즈 본부 단위 연동과 개별 매장 단위 연동의 절차가 다릅니까?
8. production activation을 매장 단위로 제한할 수 있습니까?
9. 기술 지원 escalation 채널이 있습니까?
10. 공식 연동 문서 또는 파트너 절차 안내를 제공받을 수 있습니까?

저희는 승인되지 않은 로컬 DB 접근이나 단말 직접 조작을 전제로 하지 않습니다.

감사합니다.
```

## 8. KICC EasyPos Verification Request Draft

```text
안녕하세요.

저희는 외식 매장의 대기, 주문, 입장, 테이블 매칭, POS/KDS 핸드오프를 단계적으로 연결하는 Catch & Order 서비스를 준비하고 있습니다.

이지포스 또는 한국정보통신 결제/VAN 연동 환경에서 외부 서비스가 공식적으로 연동할 수 있는 API, ASP, Webhook, 파트너 절차가 있는지 확인하고자 문의드립니다.

확인 요청 항목은 아래와 같습니다.

1. 외부 서비스가 주문 정보를 이지포스 또는 관련 서버 시스템에 전달할 수 있는 공식 경로가 있습니까?
2. 주문 상태, 취소, 정정, 결제 상태를 조회하거나 수신할 수 있습니까?
3. 매장 단말 로컬 DB 또는 구형 클라이언트 구조와 무관하게 안전한 연동 방식이 있습니까?
4. 개발용 테스트 환경 또는 테스트 매장 구성이 가능합니까?
5. VAN/PG 결제 상태 관찰 또는 정산 대사에 필요한 데이터 접근이 가능합니까?
6. Webhook/callback 방식이 있다면 보안 서명 및 replay 방지를 지원합니까?
7. 파트너 계약, 보안 심사, 인증 절차가 필요합니까?
8. production 적용을 매장 단위로 제한할 수 있습니까?
9. 장애 시 기술 지원 escalation 채널이 있습니까?
10. 공식 연동 문서 또는 파트너 안내 자료를 제공받을 수 있습니까?

저희는 비공식 로컬 DB 직접 수정이나 화면 스크래핑 방식은 사용하지 않으려 합니다.

감사합니다.
```

## 9. PAYCO-Related Provider Flow Verification Request Draft

```text
안녕하세요.

저희는 외식 매장의 대기, 주문, 입장, 테이블 매칭, POS/KDS 핸드오프를 단계적으로 연결하는 Catch & Order 서비스를 준비하고 있습니다.

PAYCO 관련 결제/주문/가맹점 연동 흐름에서 외부 서비스가 공식적으로 사용할 수 있는 API, Webhook, 파트너 연동 절차가 있는지 확인하고자 문의드립니다.

확인 요청 항목은 아래와 같습니다.

1. 외부 서비스가 PAYCO 관련 결제 상태를 공식적으로 조회하거나 수신할 수 있습니까?
2. 결제 승인, 취소, 환불, 정정 이벤트를 Webhook 또는 API로 받을 수 있습니까?
3. Webhook 서명 검증, timestamp, replay 방지 키가 제공됩니까?
4. 주문 상태와 결제 상태를 분리하여 관리할 수 있는 공식 이벤트 구조가 있습니까?
5. 가맹점/매장 단위 credential 발급이 가능합니까?
6. 개발용 sandbox 또는 test merchant 환경을 제공합니까?
7. production 적용 전 보안 심사, 파트너 계약, 인증 절차가 필요합니까?
8. 일마감/정산/대사에 필요한 reference 데이터를 제공합니까?
9. 장애 발생 시 기술 지원 escalation 채널이 있습니까?
10. 공식 연동 문서 또는 파트너 안내 자료를 제공받을 수 있습니까?

저희는 결제 실행보다 우선 결제 상태 관찰, 취소/환불 증적, 정산 대사 가능성을 확인하려는 목적입니다.

감사합니다.
```

## 10. Provider Response Intake Table

| Provider | Sent Date | Response Date | Official API | Sandbox | Webhook Security | Payment Scope | Contract Required | Disposition |
|---|---|---|---|---|---|---|---|---|
| Toss Place |  |  |  |  |  |  |  |  |
| Payhere |  |  |  |  |  |  |  |  |
| PAYCO-related flow |  |  |  |  |  |  |  |  |
| OKPOS |  |  |  |  |  |  |  |  |
| KIS OKPOS |  |  |  |  |  |  |  |  |
| KICC EasyPos |  |  |  |  |  |  |  |  |

## 11. Internal Processing After Response

After receiving any response:

1. Save response reference.
2. Update 14220 contact log.
3. Complete 14120 response assessment.
4. Update 14100 readiness register.
5. Open 14130 blocker if missing facts remain.
6. Create 14090 evidence packet if provider becomes a candidate.
7. Keep provider manual fallback or evidence-only if official path is not confirmed.

## 12. Non-Goals

This packet does not approve integration.

It does not define:

- final provider priority
- final provider adapter code
- final payment execution
- final commercial contract
- final pilot activation

It only prepares official verification requests.

## 13. Related Documents

- 14220_Register_POS_Provider_First_Verification_Contact_Log.md
- 14210_WorkPackage_POS_Provider_First_Verification_Wave_And_Contact_Backlog.md
- 14110_Template_POS_Provider_Official_Verification_Request.md
- 14120_Assessment_POS_Provider_Official_Response_And_Integration_Disposition.md
- 14100_Register_POS_Provider_Readiness_Status_And_Next_Action.md
- 14130_Register_POS_Provider_Blocker_Risk_And_Resolution_Tracking.md
