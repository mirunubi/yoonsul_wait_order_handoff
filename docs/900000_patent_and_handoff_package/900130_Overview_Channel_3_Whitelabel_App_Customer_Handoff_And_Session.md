# 900130_Overview_Channel_3_Whitelabel_App_Customer_Handoff_And_Session

Status: In_Progress
Lifecycle: Overview
Owner: TBD
Last Updated: 2026-06-21

---

## 0. Document Purpose

이 Overview 는 Channel 3 화이트라벨 캐치메뉴 앱의 고객 Handoff 구현 컨텍스트를 정의한다.

화이트라벨 앱은 가맹점이 자체 브랜드로 배포하는 앱이다.
캐치메뉴 SaaS 위에 가맹점 브랜딩이 얹힌 구조다.

세션 관리의 핵심 추가 복잡성:
  tenant_id 격리 — 가맹점 A 고객이 가맹점 B 데이터 접근 불가
  멤버십 이관 — 가맹점 자체 멤버십 ↔ 캐치메뉴 원장 연동

Related Logic: 900131_Logic_Channel_3_Whitelabel_App_Customer_Handoff_And_Session.md

---

## 1. 채널 정의

```text
채널명: Whitelabel Catch Menu App (화이트라벨 캐치메뉴 앱)
접근 방법: 가맹점 브랜드 앱 설치 후 실행
인증 요구: 전화번호 OTP 로그인 (최초 1회)
대상 고객: 해당 가맹점 브랜드 고객
KDS 접근: 없음 (고객 전용)
멤버십: FRANCHISE_LINK / STANDALONE / HYBRID
테넌트 격리: tenant_id + brand_id 기반 RLS
```

---

## 2. Channel 2 와의 차이점

```text
같은 것:
  인증 방식 (전화번호 OTP)
  세션 저장 (SecureStorage)
  JWT 자동 갱신
  대기/주문/결제 파이프라인

다른 것:
  브랜딩: 가맹점 로고/색상/앱 이름
  멤버십 원장: 가맹점 자체 또는 연동
  tenant_id: 가맹점별 고정
  포인트 이관: FRANCHISE_LINK 모드 시 외부 시스템으로 이관
  메뉴 템플릿: 본부 배포 템플릿 기반
  정책 준수: run_compliance_check() 연동
```

---

## 3. 멤버십 모드별 세션 동작

### STANDALONE 모드

```text
가맹점 독자 멤버십.
캐치메뉴 원장만 사용.
Channel 2 와 동일한 방식.

earn_points_after_order():
  membership_mode = 'STANDALONE'
  → 캐치메뉴 point_ledger 에만 적립
  → 외부 이관 없음
```

### FRANCHISE_LINK 모드

```text
가맹점이 기존 외부 멤버십 시스템 보유.
포인트를 외부로 이관.

earn_points_after_order():
  membership_mode = 'FRANCHISE_LINK'
  → 캐치메뉴 point_ledger 에 HOLD_INTERNAL 기록
  → Edge Function → 외부 멤버십 API 호출
  → 성공: point_transfer_log TRANSFERRED
  → 실패: HOLD_INTERNAL 유지 (수동 처리 대기)

세션 영향:
  이관 실패해도 고객 앱은 정상 작동
  "포인트 적립 처리 중" 표시 후
  성공 시 "포인트 적립 완료" 갱신
```

### HYBRID 모드

```text
일부 포인트는 캐치메뉴, 일부는 외부.
정책 설정에 따라 분기.
```

---

## 4. tenant_id 격리 세션 로직

```text
앱 설치 시 tenant_id 고정:
  화이트라벨 앱 빌드 시 tenant_id 하드코딩
  또는 앱 첫 실행 시 서버에서 tenant_id 수신

RLS 보장:
  모든 API 호출에 tenant_id 자동 포함
  다른 tenant_id 의 데이터 접근 불가 (RLS)

brand_id 격리:
  가맹점 A 고객 ≠ 가맹점 B 고객
  같은 테넌트 내 다른 브랜드도 격리
```

---

## 5. 관련 RPC (Channel 2 기반 + 추가)

| 단계 | RPC | Channel 2 대비 |
|---|---|---|
| 포인트 적립 | earn_points_after_order | 멤버십 모드 분기 추가 |
| 이관 확인 | point_transfer_log 조회 | 신규 |
| 메뉴 조회 | get_kiosk_menu | 본부 템플릿 기반 |
| 정책 준수 | (백그라운드) | run_compliance_check |

---

## 6. Out Of Scope

```text
윤슬김밥 통합 멤버십 (Channel 4)
본부 관리자 화면
가맹점 운영 현황 대시보드
```
