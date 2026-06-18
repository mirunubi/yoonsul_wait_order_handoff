# 014020_Report_Domestic_POS_Industry_Ecosystem_Market_Architecture_And_Limitations.md

> Source material整理본.
> 원문은 국내 POS 산업 생태계, 시장 점유 구조, Windows/Android 기반 POS 아키텍처, 주요 사업자, 고질적 병목, 성장 전망을 종합한 긴 분석 텍스트이다.
> 이 문서는 원문을 그대로 보관하는 문서가 아니라, `yoonsul_wait_order_handoff` / Catch & Order / POS Gateway 전략 문서에 재사용하기 위한 Markdown 소재 문서이다.
> 수치·매출·시장전망·보안규격 관련 내용은 원문 기반 요약이며, 실제 사업계획·투자자료·특허자료에 넣기 전에는 출처별 재검증이 필요하다.

---

## 1. 문서 목적

이 문서는 국내 POS 산업 분석 원문을 다음 용도로 재분류한다.

1. 국내 POS 사업자 생태계 파악
2. Windows 레거시 POS와 Android/Cloud POS의 기술 차이 정리
3. POS Gateway / KDS / 결제 연동에서 우리가 방어해야 할 구조적 리스크 도출
4. `Catch & Order`가 단순 테이블오더가 아니라 POS/KDS/정산/보안 Gateway 계층을 가져야 하는 이유 정리
5. 향후 문서화 후보, 특허 소재, 보안/감사 정책 보강 지점 추출

---

## 2. 핵심 결론

국내 POS 시장은 단말기 중심의 폐쇄형 레거시 시장에서 클라우드·모바일·플러그인·정산 데이터 기반 플랫폼 시장으로 이동하고 있다. 그러나 매장 현장은 여전히 Windows POS, 로컬 DB, VAN 단말기, 프린터, KDS, 키오스크, 테이블오더, 간편결제, 정산 원장 등이 뒤섞여 있다.

따라서 우리 시스템은 특정 POS 한 곳에 직접 붙는 방식이 아니라, 다음 구조를 전제로 해야 한다.

```text
Customer / Waiting / Order Runtime
        ↓
Catch & Order Gateway
        ↓
POS Provider Adapter Layer
        ↓
POS / KDS / Payment / Staff Manual Fallback
        ↓
Audit / Settlement / Reconciliation / Evidence Ledger
```

핵심 경쟁력은 POS를 대체하는 것이 아니라, POS와 외식 운영 OS 사이에 안전한 표준 Gateway를 두는 것이다.

---

## 3. 국내 POS 시장 구도 요약

| 구분 | 대표 사업자 | 성격 | 우리 관점의 의미 |
|---|---|---|---|
| 레거시 시장 선도 | 오케이포스, KICC 이지포스, KIS OKPOS | Windows/로컬 DB/VAN 기반 강자 | 직접 대체보다 Gateway·Adapter·Fallback 전략 필요 |
| 클라우드 POS 성장 | 토스플레이스, 페이히어 | Android/iOS/Web, Cloud Native, API/Plugin 지향 | Open API/Plugin 연동 가능성, 그러나 정책·권한·승인 검증 필요 |
| 하드웨어 제조 | 포스뱅크, 아임유, 하나시스 등 | POS/키오스크/주변기기 제조 및 OEM/ODM | 3차 Kiosk/Device 전략에서 협력 또는 공급망 리스크 검토 필요 |
| VAN/PG 기반 결제망 | KICC, NICE 계열 등 | 결제망·정산망·가맹점 네트워크 | 결제·정산·취소·대사·보안 정책과 직접 연결 |

---

## 4. 주요 사업자별 시사점

### 4.1 오케이포스 / OKPOS

원문은 오케이포스를 국내 POS 솔루션 시장의 강한 기존 사업자로 설명한다. Windows 기반 레거시와 Android/모바일 전환을 함께 가져가는 하이브리드 성격이 강하다.

우리에게 주는 시사점은 다음과 같다.

- POS 교체보다 POS 주변 Gateway 전략이 현실적이다.
- 대형 가맹점·프랜차이즈는 기존 OKPOS 운영 프로세스를 쉽게 버리지 않는다.
- 주문/대기/테이블 매칭 시스템은 POS가 아니라 **POS 앞단 또는 옆단의 운영 보조 계층**으로 들어가야 한다.
- 취소, 분할결제, 재전송, 영수증, 정산 재처리 같은 edge case를 반드시 정책화해야 한다.

### 4.2 토스플레이스 / Toss Place

원문은 토스플레이스를 Android 중심 클라우드 POS와 플러그인 생태계의 성장 주자로 설명한다.

시사점:

- 토스 POS류는 API/Plugin 전략이 열릴 가능성이 있다.
- 하지만 결제·정산·가맹점 데이터는 금융 플랫폼으로 귀속될 수 있다.
- 우리 시스템은 특정 금융 플랫폼에 종속되지 않는 중립 Gateway를 유지해야 한다.
- Plugin 방식이 열리더라도 결제 확정, 환불, 취소, 매출 대사 권한은 별도 검증 대상이다.

### 4.3 페이히어 / Payhere

원문은 페이히어를 스마트폰/태블릿 POS와 다국어 대시보드, 클라우드 기반 소상공인 인프라 혁신의 사례로 다룬다.

시사점:

- 다국어 메뉴/옵션/카테고리 구조는 우리 0A/0B/0C 고객 진입 흐름과 직접 연결된다.
- 테이블오더·키오스크·외국인 고객 흐름에서는 i18n message key와 메뉴 translation layer가 필수다.
- 클라우드 POS라도 매장 주변기기와 결제 주변기기 오류는 완전히 사라지지 않는다.

### 4.4 KICC / 이지포스 / KIS OKPOS

원문은 KICC를 VAN/PG/TRS/AOS 결제 인프라 중심의 대형 사업자로 설명한다. 이지포스·KIS OKPOS는 레거시 프랜차이즈와 VAN 단말 연동 기반을 가진다.

시사점:

- 가맹점 네트워크와 결제망을 가진 회사는 단순 POS 기능보다 정산/결제 인프라가 핵심이다.
- 우리 시스템은 주문 원장과 결제 원장을 혼동하면 안 된다.
- POS accepted order, KDS ticket, payment authorization, settlement reconciliation을 분리해야 한다.

### 4.5 포스뱅크 / POSBANK

원문은 포스뱅크를 하드웨어 제조 1위권 사업자로 다루며, 재고·미수금·거래처 집중 리스크를 언급한다.

시사점:

- 3차 Kiosk나 Mini Kiosk 확장 시 하드웨어 재고 리스크를 우리가 직접 떠안으면 안 된다.
- Device package는 SW-first 전략 이후 선택적으로 붙여야 한다.
- POS/Kiosk 제조사와 협력하더라도 재고·A/S·부품 공급·현장 설치·반품 리스크는 별도 계약 정책이 필요하다.

### 4.6 아임유 / IMU POS

원문은 아임유를 고성능 일체형 하드웨어, 네이버 예약/주문 연동 등 이종 하드웨어 통합에 강점이 있는 사업자로 정리한다.

시사점:

- 네이버 예약/주문/플레이스 연동은 우리 외부 주문·예약 Gateway 후보와 연결된다.
- 하드웨어 통합형 POS는 특정 vendor-specific behavior가 강하므로 Adapter 분리가 필요하다.

---

## 5. POS 아키텍처 유형 비교

| 항목 | Windows 레거시 POS | Android/Cloud POS | 우리 설계 방향 |
|---|---|---|---|
| 운영체제 | Windows 10/11 IoT, x86 | Android, iOS, iPadOS, Web | POS별 Adapter 추상화 |
| 개발 환경 | C#, WPF, C++, MFC, Delphi 계열 | Kotlin, Swift, TypeScript, Spring Boot, WebView | Provider-specific SDK 격리 |
| 데이터 저장 | 로컬 DB, MS-SQL Express, PostgreSQL, BDE 파일 DB | Cloud DB, Redis, MongoDB, MySQL, local cache | 내부 canonical ledger 유지 |
| 통신 | DLL, serial, socket, XML/JSON API | REST API, MSA, Plugin SDK | Gateway contract + retry/idempotency |
| 장애 양상 | 로컬 DB 깨짐, 레지스트리/BDE 오류, 정전 시 유실 | 네트워크 장애, API rate limit, cloud auth failure | degraded mode + manual fallback |
| 강점 | 오프라인 내구성, 주변기기 제어 | 빠른 업데이트, UX, cloud sync | 양쪽 모두 대응하는 bridge 계층 |
| 위험 | 폐쇄성, 복구 난이도, 현장 의존 | 플랫폼 종속, API 정책 변경 | Provider lock-in 방지 |

---

## 6. 구조적 병목과 우리 대응 방향

### 6.1 로컬 DB / BDE / 레거시 드라이버 종속

원문은 이지포스류 레거시 구조에서 BDE, 로컬 폴더, 레지스트리, POSDB alias, 로컬 파일 DB 깨짐 문제를 위험으로 제시한다.

우리 대응:

- POS를 source of truth로 단정하지 않는다.
- Catch & Order 내부에는 주문 후보, POS 전송 상태, KDS 확인 상태, 결제 상태, 수동 처리 상태를 별도 원장으로 둔다.
- POS failure는 곧 서비스 failure가 아니라 degraded mode로 전환되어야 한다.

관련 문서 후보:

```text
04000_store_runtime_pos_kds_operations
11000_integration_boundary
20000_validation_security_audit
21000_financial_security_monitoring_catalog
```

### 6.2 전원 종료 / 네트워크 단절 / 트랜잭션 유실

원문은 정전·단선·비정상 종료 시 로컬 입력과 중앙 서버 동기화가 어긋나는 문제를 언급한다.

우리 대응:

- 모든 POS/KDS 전송은 idempotency key를 가진다.
- 중복 전송, 지연 전송, 수동 재입력, POS callback replay를 모두 별도 상태로 기록한다.
- 실시간 완결보다 evidence-preserving recovery가 중요하다.

### 6.3 클라우드 POS의 API/Plugin 종속성

토스플레이스류 plugin 생태계는 장점이지만, 핵심 결제 프로세스는 provider control 아래 있다.

우리 대응:

- Plugin이 열려도 핵심 runtime은 독립 원장과 audit trail을 유지한다.
- provider API policy 변경을 전제로 adapter boundary를 둔다.
- 동적 라우팅, provider fallback, manual fallback 문서를 분리한다.

### 6.4 하드웨어 공급망 리스크

원문은 제조사 재고·미수금·거래처 집중 리스크를 언급한다.

우리 대응:

- Kiosk/Device package는 핵심 제품이 아니라 옵션으로 둔다.
- Mini Kiosk는 고객-facing 명칭이 아니라 내부 모듈로 관리한다.
- 하드웨어 판매/리스/A/S/교체/분실/파손은 운영 SOP와 계약 정책으로 분리한다.

### 6.5 보안 규격과 노후 단말 격차

원문은 PCI-PTS 6.x, EMV 비접촉식 보안 규격, 노후 단말 교체 비용 문제를 언급한다.

우리 대응:

- 결제 수행형 모델은 MVP 범위를 엄격히 잘라야 한다.
- 결제는 초기에 provider/POS 위임형으로 두고, 직접 결제 수행은 readiness gate 후 진입한다.
- CI/DI, secret coding, credential rotation, masking, audit immutability는 foundation security lane에서 관리한다.

---

## 7. Catch & Order 전략 반영

### 7.1 포지셔닝

Catch & Order는 POS를 대체하는 제품이 아니라, 다음 문제를 해결하는 운영 Gateway이다.

```text
대기 등록
주문 후보 생성
좌석/테이블 매칭
POS 전달
KDS 전달
수동 fallback
정산/감사 evidence
```

핵심 문장은 다음과 같다.

```text
우리는 POS를 직접 통제하지 않는다.
우리는 POS 앞단의 고객/매장 운영 흐름을 표준화하고,
POS/KDS/Payment Provider별 차이를 Gateway와 Adapter로 흡수한다.
```

### 7.2 POS Provider 전략

| Provider 유형 | 전략 |
|---|---|
| API 제공 POS | Provider Adapter + idempotency + callback verification |
| 폐쇄형 POS | staff-confirmed manual entry + evidence packet |
| Cloud Plugin POS | Plugin boundary + provider policy review |
| VAN/POS 일체형 | 결제 원장과 주문 원장 분리 |
| POS 없음 | 자체 order candidate + manual kitchen note |

### 7.3 Gateway가 반드시 가져야 할 기능

- provider credential isolation
- webhook signature verification
- idempotent order handoff
- retry queue
- dead letter queue
- manual fallback state
- reconciliation audit
- POS/KDS confirmation status
- payment boundary separation
- settlement evidence packet
- fraud/anomaly signal capture

---

## 8. 문서 보강 후보

### 8.1 04000 Store Runtime POS/KDS Operations

보강 후보:

```text
040xx Policy_POS_Local_DB_Failure_Manual_Recovery_And_Evidence.md
040xx Policy_POS_Power_Loss_Transaction_Replay_And_Staff_Fallback.md
040xx Runbook_POS_Printer_Serial_Port_And_Device_Disconnection_Response.md
```

### 8.2 11000 Integration Boundary

보강 후보:

```text
110xx Boundary_POS_Provider_API_Plugin_And_DLL_Adapter.md
110xx Matrix_POS_Provider_Integration_Mode_And_Risk_Profile.md
110xx ADR_POS_Gateway_Provider_Lock_In_Prevention.md
```

### 8.3 14000 POS Provider Integration Strategy

보강 후보:

```text
140xx Assessment_OKPOS_TossPlace_Payhere_KICC_And_IMU_Provider_Strategy.md
140xx Matrix_DOMESTIC_POS_Provider_Architecture_And_Openness.md
140xx Report_DOMESTIC_POS_Industry_Ecosystem_Source_Material.md
```

### 8.4 20000 / 20400 Security and Audit

보강 후보:

```text
204xx Policy_POS_Security_Baseline_PCI_PTS_EMV_And_Legacy_Device_Gap.md
204xx Policy_POS_Credential_DLL_Plugin_And_Device_Trust_Boundary.md
210xx Audit_POS_Transaction_Reconciliation_And_Local_DB_Recovery_Evidence.md
```

### 8.5 24000 Deployment Operations

보강 후보:

```text
240xx Runbook_First_Store_POS_Provider_Field_Test_And_Fallback_Check.md
240xx Checklist_POS_Device_Network_Power_And_Printer_Field_Readiness.md
```

---

## 9. 리스크 레지스터 초안

| Risk ID | 리스크 | 원인 | 영향 | 대응 |
|---|---|---|---|---|
| POS-RISK-001 | 레거시 로컬 DB 손상 | BDE/로컬 DB/레지스트리 손상 | 로그인 불가, 정산 불일치 | manual fallback + evidence packet |
| POS-RISK-002 | 정전/단선 중 거래 유실 | 로컬 write 중단, sync 실패 | 중복 과금 또는 주문 누락 | idempotency + replay queue |
| POS-RISK-003 | Provider API 정책 변경 | Cloud POS/Plugin 정책 변경 | 연동 중단 | adapter contract + provider matrix |
| POS-RISK-004 | 결제/주문 원장 혼동 | POS accepted order와 payment authorization 혼합 | 회계/환불/소비자 분쟁 | order/payment/settlement ledger 분리 |
| POS-RISK-005 | 주변기기 드라이버 오류 | printer/CAT/signpad serial/DLL 오류 | 주방 전달 실패, 현장 혼란 | degraded operation SOP |
| POS-RISK-006 | 하드웨어 공급 리스크 | 재고, A/S, 미수금, 거래처 집중 | 설치 지연, 비용 폭탄 | SW-first, hardware optional boundary |
| POS-RISK-007 | 노후 단말 보안 격차 | PCI/EMV 미준수 단말 | 보안/결제 심사 위험 | provider readiness checklist |
| POS-RISK-008 | 금융 플랫폼 종속 | Super-app/financial provider lock-in | 데이터 주권 상실 | neutral gateway + export policy |

---

## 10. 특허/전략 소재

이 원문은 다음 특허·전략 소재로 전환 가능하다.

1. 이기종 POS Provider를 위한 runtime gateway abstraction
2. POS/KDS/Payment 상태 분리 기반 handoff ledger
3. 로컬 DB 손상·전원 종료·네트워크 실패에 대한 evidence-preserving replay
4. POS provider openness scoring matrix
5. Cloud POS plugin과 legacy DLL adapter를 동시에 수용하는 dual-mode integration boundary
6. financial-grade audit trail을 가진 주문-결제-정산 분리 원장
7. POS 없는 매장, 폐쇄형 POS 매장, API POS 매장을 하나의 SaaS runtime으로 흡수하는 staged integration model

---

## 11. 작업 지시용 요약

다음 문서화 wave에서 사용할 압축 지시문:

```text
국내 POS 산업 분석 원문을 기반으로, Catch & Order는 POS 대체 제품이 아니라 이기종 POS/KDS/Payment Provider를 흡수하는 Gateway SaaS로 정의한다. Windows 레거시 POS는 로컬 DB·BDE·DLL·시리얼 주변기기 리스크가 크고, Android/Cloud POS는 API/Plugin 종속성과 금융 플랫폼 lock-in 리스크가 있다. 따라서 시스템은 provider-specific adapter, idempotent handoff, manual fallback, reconciliation audit, security credential isolation, payment/order ledger separation을 기본 전제로 한다.
```

---

## 12. 원문 기반 주요 참고 키워드

- OKPOS
- Toss Place / Toss POS
- Payhere
- KICC / EasyPos / KIS OKPOS
- POSBANK
- IMU POS
- Windows POS
- Android Cloud POS
- BDE / POSDB / Local DB
- C# WPF / C++ MFC / Delphi
- Kotlin / Swift / TypeScript / Spring Boot
- Plugin SDK
- VAN / PG / TRS / AOS
- PCI-PTS 6.x
- EMV contactless
- SoftPOS
- 2-Phase Commit
- Idempotency
- Reconciliation
- Manual Fallback
- Evidence Ledger

---

## 13. 검증 필요 사항

원문에는 2025년/2026년 기준 매출, 시장 규모, 성장률, 점유율, 보안 규격, 업체별 기술 스택 등 시간 민감한 정보가 포함되어 있다. 따라서 다음 자료에 넣기 전에는 별도 검증이 필요하다.

| 사용처 | 검증 수준 |
|---|---|
| 내부 아이디어 문서 | 원문 기반 요약 가능 |
| 투자/IR 자료 | 공시·리포트·기업자료 재검증 필요 |
| 특허 명세서 | 수치보다 구조적 문제와 기술 해결수단 중심으로 재작성 필요 |
| 개발 스펙 | provider 공식 API/SDK 문서 확인 필요 |
| 보안 정책 | PCI/EMV/금융보안 관련 최신 규격 확인 필요 |

---

## 14. 결론

국내 POS 시장은 단일 표준으로 수렴하지 않고, 레거시 Windows POS, VAN 결제망, 클라우드 Android POS, 모바일 POS, 하드웨어 제조사, 프랜차이즈 수발주 시스템이 병존하는 구조로 갈 가능성이 높다.

따라서 Catch & Order의 장기 승부처는 다음이다.

```text
POS와 직접 싸우지 않는다.
POS/KDS/Payment/Staff Operation 사이의 불일치를 흡수한다.
모든 provider 차이를 Gateway와 Evidence Ledger로 통제한다.
```

이 방향이 맞다면, POS 연동을 단순 API 기능으로 보지 말고, 금융권 수준의 감사·대사·장애복구·보안정책을 포함한 runtime foundation으로 계속 문서화해야 한다.
