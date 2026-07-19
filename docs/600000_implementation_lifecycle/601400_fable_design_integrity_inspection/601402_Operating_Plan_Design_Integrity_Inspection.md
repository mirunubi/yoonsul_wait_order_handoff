# CatchMenu 일회성 설계 무결성 및 역설계 검사 운영안

## 1. 목적

CatchMenu 프로젝트에 축적된 약 2,600개의 일반 Markdown 설계문서와 해당 문서가 참조하거나 규정하는 SQL 및 JSON 파일을 대상으로 일회성 전수 검사를 수행한다.

이번 검사의 목적은 새로운 기능을 설계하거나 기존 파일을 수정하는 것이 아니다.

목적은 다음과 같다.

1. 설계문서 내부의 논리 오류와 누락을 찾는다.
2. 설계문서 간 정책·상태·책임 충돌을 찾는다.
3. 설계문서와 SQL·JSON 구현 사이의 불일치를 찾는다.
4. 현재 유효한 설계, 과거 설계, 폐기 후보 설계를 구분할 근거를 만든다.
5. 실제 실행 장애로 이어질 가능성이 있는 결함을 식별한다.
6. 발견된 결함을 향후 정규 개발 Workpacket으로 이관할 수 있도록 증거와 우선순위를 정리한다.

Fable은 이번 검사에서 분석과 보고만 담당한다.

---

## 2. Fable의 위치

Fable은 CatchMenu의 정규 개발 파이프라인에 포함하지 않는다.

정규 개발 절차는 기존 체계를 유지한다.

```text
Cursor Impact Scope
→ Claude Architecture
→ Claude + Owner Approval
→ Codex Implementation
→ Local Automated Verification
→ Claude Independent Audit
→ NavigationMap / Index Sync
```

Fable은 위 절차의 설계자, 구현자, 승인자 또는 감사자가 아니다.

이번에 한하여 정규 개발 절차 바깥에 별도의 특별 검사 트랙을 둔다.

```text
[일회성 특별 검사 트랙]

전체 대상 파일 목록과 증거 수집
→ Fable 읽기 전용 전수 검사
→ 검사 결과 및 Finding Register 제출
→ 정영석 Owner 검토·분류·우선순위 결정
→ 필요한 항목만 정규 Workpacket으로 이관
```

Fable이 발견한 오류는 자동으로 수정 대상으로 확정되지 않는다.

모든 수정은 Owner가 검토한 뒤 기존 정규 개발 절차를 새로 시작해야 한다.

---

## 3. 검사 대상

이번 검사는 다음 세 종류의 파일만 다룬다.

### 3.1 일반 Markdown 설계문서

대상 예시는 다음과 같다.

* README
* Index
* NavigationMap
* Overview
* Logic
* Architecture
* Policy
* Guide
* TestPlan
* ChangeContract
* Approval
* Implementation
* Verification
* Audit
* Module
* 운영 흐름 및 상태 정의 문서
* 데이터·RPC·보안·장애 복구 설계문서

단순 참고자료라 하더라도 현행 설계나 구현에서 참조한다면 검사 대상에 포함한다.

### 3.2 SQL 파일

Markdown 문서에서 참조하거나 설계 계약과 직접 관련된 SQL만 검사한다.

대상 예시는 다음과 같다.

* migration
* table DDL
* function 및 RPC
* trigger
* view
* RLS policy
* GRANT·REVOKE
* constraint
* verification SQL
* seed 또는 baseline replay 관련 SQL

SQL은 설계문서와의 정합성을 확인하기 위해 읽는다.

Fable은 SQL을 실행하거나 수정하지 않는다.

### 3.3 JSON 파일

설계문서 또는 SQL 실행 계약과 관련된 JSON만 검사한다.

대상 예시는 다음과 같다.

* 설정 파일
* 상태·이벤트 정의
* API 또는 RPC payload 예시
* 메뉴·정책·워크플로 정의
* 테스트 fixture
* 스키마 또는 계약 파일
* 시스템·에이전트 구성 정보

JSON 역시 읽기와 계약 대조만 허용한다.

---

## 4. 검사 제외 대상

이번 특별 검사는 다음 작업을 수행하지 않는다.

* Markdown 파일 수정
* SQL 파일 수정
* JSON 파일 수정
* 신규 파일 생성
* 파일 이동 또는 이름 변경
* 폴더 구조 변경
* 코드 리팩터링
* migration 작성
* 테스트 실행
* 데이터베이스 접속 또는 변경
* Git commit·stage·branch 변경
* Index나 NavigationMap 자동 동기화
* canonical 정책의 임의 확정
* 새로운 기능이나 아키텍처 제안 확대
* 정규 Workpacket 대신 직접 구현

분석 결과를 저장할 필요가 있다면 Fable이 저장소에 직접 파일을 생성해서는 안 된다.

Fable의 출력은 화면 또는 외부 대화 결과로만 전달하고, 필요할 경우 Owner가 검토한 뒤 Codex 등 승인된 도구가 별도 문서로 옮긴다.

---

## 5. 파일 수정 권한에 대한 최종 결정

### 결정

**Fable에는 모든 파일에 대해 읽기 전용 권한만 부여한다.**

Markdown, SQL, JSON을 포함하여 어떠한 저장소 파일도 생성·수정·삭제·이동·이름 변경할 수 없다.

### 이유

#### 5.1 검사자가 증거를 변경하면 안 된다

Fable이 오류를 발견한 직후 해당 파일을 수정하면 최초 결함의 증거가 사라질 수 있다.

그 결과 다음을 구분하기 어려워진다.

* 원래 존재했던 결함
* Fable이 새로 만든 변경
* 변경 과정에서 발생한 2차 오류
* 어떤 정책이 Owner에게 승인됐는지

#### 5.2 발견과 정책결정을 분리해야 한다

설계 충돌은 기술적 오류처럼 보여도 실제로는 사업정책 결정인 경우가 많다.

예:

* 노쇼 시 주문 취소 또는 HOLD 유지
* 결제 후 KDS 전송의 권위 데이터
* 예약 선주문과 대기 중 선주문의 통합 여부
* 장애 시 영업 지속 범위
* 취소 후 재결제 허용 여부

Fable이 파일을 직접 고치면 대안 중 하나를 사실상 임의 승인하게 된다.

#### 5.3 대규모 검사 중 범위 확장을 막아야 한다

2,600개 문서를 검사하다 보면 수많은 연관 문제를 발견할 수 있다.

수정 권한이 있으면 모델이 다음 행동을 할 위험이 있다.

* 오래된 문서를 임의로 현행화
* historical 문서를 삭제 또는 변경
* 문서 표현을 정책 변경으로 확대
* 관련 SQL까지 연쇄 수정
* Index와 NavigationMap을 광범위하게 변경
* 현재 검사 목적을 정리·리팩터링 작업으로 변질

읽기 전용은 이러한 범위 확장을 구조적으로 차단한다.

#### 5.4 독립 검사자의 신뢰성을 유지해야 한다

Fable은 이번에 시스템 전체를 외부 관점에서 재구성하는 역설계 검사자다.

검사 대상의 설계와 구현을 직접 수정하게 되면 독립성이 훼손된다.

따라서 결론은 명확하다.

> Fable은 오류를 발견하고 설명하며 수정 방향의 선택지를 제시할 수 있지만, 실제 파일을 변경할 수는 없다.

---

## 6. 전체 검사 방식

약 2,600개의 문서를 모두 동일한 깊이로 읽고 즉시 결론을 내리는 방식은 사용하지 않는다.

검사는 네 단계로 수행한다.

### 6.1 단계 1: 전체 파일 인벤토리와 구조 검사

모든 대상 파일의 기본 정보를 수집한다.

* 실제 경로
* 파일명
* 문서 번호
* H1
* 문서 유형
* 소속 폴더 및 Workpacket
* 참조 문서
* 참조 SQL·JSON
* 상태 표기
* 승인·구현·검증·감사 관계
* 현행·과거·미확정 후보

이 단계에서는 설계의 옳고 그름을 확정하지 않는다.

다음과 같은 구조적 문제를 찾는다.

* 파일명과 H1 불일치
* 중복 문서 번호
* 존재하지 않는 파일 참조
* 오래된 경로 참조
* 고립된 문서
* Index 누락
* NavigationMap 누락
* 승인 없는 구현문서
* 구현 없는 검증문서
* 검증 없는 감사문서
* 완료됐는데 pending으로 남은 문서
* 폐기된 파일이나 폴더를 현행처럼 참조하는 문서

### 6.2 단계 2: 도메인 분류와 참조 관계 재구성

문서를 주요 업무 도메인별로 분류한다.

예:

* Customer Handoff
* Waiting / Queue
* Pre-order
* Order
* Payment / Ledger
* KDS
* DID
* Menu / Option / Personalization
* Inventory / SCM
* SOP / Agent / Fallback
* POS / Provider Gateway
* Franchise HQ
* AI Customer Center
* SaaS / Multi-tenant
* Physical AI
* Security / RLS / Audit

각 도메인 안에서 문서를 다음 순서로 재구성한다.

```text
상위 정책
→ 도메인 설계
→ Workpacket 설계
→ 승인
→ 구현
→ 검증
→ 감사
→ 현행 운영 기준
```

Fable은 이를 통해 문서가 실제로 설명하는 시스템 구조를 역으로 복원한다.

### 6.3 단계 3: 설계문서 간 의미적 충돌 검사

다음 항목을 중심으로 검사한다.

* 동일 용어의 정의 차이
* 동일 상태의 의미 충돌
* 서로 다른 상태 전이
* 동일 기능의 복수 canonical 후보
* Source of Truth 중복
* 상위 설계와 하위 설계 불일치
* 승인 후 구현문서에서 정책 변경
* 구현문서가 승인 범위를 재정의한 경우
* 현행 문서와 historical 문서의 혼재
* MVP와 미래 단계의 범위 혼합
* 정상 흐름과 예외 흐름의 단절
* 실패·재시도·보상·복구 경로 누락
* 멱등성 및 중복 실행 정책 충돌
* 감사·권한·RLS 경계 누락

### 6.4 단계 4: Markdown–SQL–JSON 계약 대조

설계문서에서 주장하는 내용과 관련 SQL·JSON을 비교한다.

검사 항목은 다음과 같다.

#### 데이터 계약

* 문서에 적힌 테이블·컬럼이 실제 SQL에 존재하는가
* 필수 컬럼이 함수 또는 payload에서 누락됐는가
* 존재하지 않는 phantom column을 참조하는가
* 상태값이 CHECK constraint와 일치하는가
* FK·NOT NULL·UNIQUE 조건과 문서가 일치하는가
* JSON 구조와 문서상 payload가 일치하는가

#### RPC 계약

* 함수명과 signature가 문서와 일치하는가
* 입력·출력 계약이 일치하는가
* 읽는 테이블과 쓰는 테이블이 설계와 일치하는가
* 상태 전이가 문서와 일치하는가
* 동일 이름의 오버로드가 충돌하는가
* 문서가 지정한 canonical RPC와 실제 호출자가 일치하는가

#### 보안·권한 계약

* GRANT·REVOKE가 설계와 일치하는가
* SECURITY DEFINER 사용이 의도와 일치하는가
* search_path가 안전한가
* RLS와 tenant/store 경계가 문서와 일치하는가
* service role 전용 기능이 일반 사용자에게 노출되는가

#### 실행 및 복구 계약

* 결제·주문·KDS 권한 흐름이 연결되는가
* 취소·환불·노쇼·재시도 경로가 일관적인가
* 장애 폴백이 보안 또는 결제 정책을 우회하는가
* audit event가 설계대로 남도록 되어 있는가
* JSON 설정과 SQL 상태·이벤트 이름이 일치하는가

---

## 7. Finding 분류 체계

Fable은 발견사항을 다음 유형으로 분류한다.

### STRUCTURAL DEFECT

파일 번호, H1, 경로, 참조, Index, 단계 체인의 구조적 오류

### DESIGN CONTRADICTION

두 개 이상의 설계문서가 동일한 업무를 서로 다르게 정의하는 오류

### CANONICAL AMBIGUITY

어느 문서 또는 함수가 현행 기준인지 확정할 수 없는 상태

### DOCUMENT–SQL DRIFT

Markdown 설계와 SQL 구현이 일치하지 않는 상태

### DOCUMENT–JSON DRIFT

Markdown 설계와 JSON 설정·계약이 일치하지 않는 상태

### SQL–JSON DRIFT

SQL의 상태·이벤트·payload 계약과 JSON이 일치하지 않는 상태

### IMPLEMENTATION DEFECT CANDIDATE

설계는 비교적 명확하지만 SQL 또는 JSON 구현에 결함이 있는 것으로 보이는 항목

### MISSING DESIGN CONTRACT

필수 상태, 실패 조건, 권한, 멱등성, 복구 절차가 설계문서에 없는 상태

### HISTORICAL OR SUPERSEDED CANDIDATE

현재 설계로 사용해서는 안 될 가능성이 있는 문서

### RUNTIME BLOCKER CANDIDATE

실제 실행 시 즉각적인 실패·데이터 훼손·권한 우회로 이어질 가능성이 있는 항목

### OUT-OF-SCOPE OR FUTURE

문제 가능성은 있으나 현재 운영 단계나 검사의 핵심 범위에서 분리해야 하는 항목

---

## 8. Finding 작성 규칙

모든 발견사항은 최소한 다음 구조로 기록한다.

```text
Finding ID:
Domain:
Classification:
Severity:
Affected MD files:
Related SQL files:
Related JSON files:
Exact evidence:
Conflicting or missing contract:
Operational impact:
Runtime impact:
Canonical ambiguity:
Owner decision required:
Possible resolution options:
Recommended next action:
Suggested regular Workpacket:
Confidence:
```

### Severity

* CRITICAL: 데이터 훼손, 결제·권한 우회, 운영 중단 가능성
* HIGH: 핵심 업무 흐름 실패 또는 명백한 설계 충돌
* MEDIUM: 비핵심 기능 오류, 상태·문서 드리프트
* LOW: 구조적 위생, 경로·표기·참조 문제

Fable은 Finding마다 가능한 해결 선택지를 제시할 수 있다.

다만 추천안은 승인이나 수정 명령이 아니다.

---

## 9. Fable의 최종 산출물

Fable은 파일 수정본이 아니라 다음 보고 결과를 제출한다.

### 9.1 Master Inspection Summary

* 검사한 파일 수
* 제외하거나 읽지 못한 파일
* 도메인별 문서 수
* SQL·JSON 연결 현황
* 전체 Finding 요약
* 신뢰도와 검사 한계

### 9.2 Structural Defect Register

파일명, H1, 번호, 경로, 참조, Index 및 단계 체인 오류

### 9.3 Design Conflict Register

문서 간 정책, 상태, 책임, 업무 흐름 충돌

### 9.4 Canonical Ambiguity Register

현재 기준 문서를 확정할 수 없는 영역

### 9.5 MD–SQL–JSON Drift Register

설계문서와 관련 SQL·JSON 사이의 불일치

### 9.6 Historical and Superseded Candidate Register

과거 기록 또는 폐기 후보 문서

### 9.7 Runtime Risk Register

실제 장애, 결제 오류, 권한 문제, 데이터 불일치로 이어질 수 있는 항목

### 9.8 Owner Decision Queue

기술적으로 자동 결정할 수 없는 사업·운영 정책

### 9.9 Regular Workpacket Recommendation Queue

Owner 검토 후 정규 개발 절차로 넘길 수정 후보

---

## 10. 검사 결과 처리 절차

Fable의 결과를 받은 후 다음 순서를 따른다.

```text
Fable Finding 제출
→ 정영석 Owner 1차 검토
→ 오탐·중복·historical 항목 제거
→ 정책결정 필요사항 분리
→ 수정 필요도와 우선순위 확정
→ Finding별 정규 Workpacket 개설 여부 결정
```

수정이 필요한 항목은 반드시 기존 개발 절차를 거친다.

```text
승인된 Fable Finding
→ Cursor Impact Scope
→ Claude Architecture / Logic / TestPlan / ChangeContract
→ Owner Approval
→ Codex Implementation
→ Local Verification
→ Claude Independent Audit
→ NavigationMap / Index Sync
```

Fable 보고서는 Workpacket의 참고 증거가 될 수 있지만, Impact Scope·Approval·Implementation·Verification·Audit 문서를 대체하지 않는다.

---

## 11. 검사의 우선순위

전체 파일은 전수 검사하되, 심층 분석과 결과 정리는 운영 위험 순서로 수행한다.

1. Customer Handoff
2. Payment–Ledger–KDS authorization
3. Waiting–Call–No-show
4. Order cancellation–refund
5. Menu–Option–Personalization
6. POS–Provider Gateway
7. SOP–Agent–Fallback
8. Inventory–SCM
9. Security–RLS–Audit
10. Franchise HQ
11. AI Customer Center
12. SaaS / Multi-tenant
13. Physical AI

이는 검사 순서일 뿐 수정 순서가 아니다.

수정 우선순위는 Fable이 아닌 Owner가 결정한다.

---

## 12. 향후 Fable 사용 원칙

이번 검사는 현재 누적된 약 2,600개 설계문서와 관련 SQL·JSON을 대상으로 하는 일회성 검사다.

Fable은 이후 정규 개발에 포함하지 않는다.

향후에는 일정한 설계 구간 또는 Phase가 충분히 완성된 뒤에만 별도의 역설계 검사를 수행할 수 있다.

예:

* Customer Handoff 설계 구간 완료 후
* Payment–KDS 구간 완료 후
* Menu–Personalization 구간 완료 후
* Franchise OS 설계 구간 완료 후
* 전체 Phase 종료 전

향후 검사에서도 원칙은 동일하다.

* 읽기 전용
* 파일 수정 금지
* 정규 Workpacket 외부에서 수행
* 진단 결과만 제출
* 수정은 기존 개발 파이프라인으로 이관

---

## 13. 최종 권한 선언

### Fable 허용 권한

* Markdown 읽기
* 관련 SQL 읽기
* 관련 JSON 읽기
* 파일 간 참조 분석
* 논리·상태·데이터·권한 계약 비교
* 오류와 충돌 보고
* 대안 및 위험 분석
* Workpacket 후보 제안

### Fable 금지 권한

* 모든 파일 생성
* 모든 파일 수정
* 모든 파일 삭제
* 파일명 변경
* 파일 이동
* 폴더 변경
* SQL 실행
* 데이터베이스 변경
* Git 변경
* 정책 승인
* canonical 문서 임의 확정
* 구현 및 리팩터링
* 정규 개발 게이트 대체

## 최종 결론

Fable은 이번 한 번에 한해 CatchMenu 설계 전체를 외부 관점에서 역으로 재구성하고, 일반 Markdown 설계문서와 그에 관련된 SQL·JSON 사이의 오류·충돌·누락·드리프트를 찾아내는 독립 검사자로 사용한다.

Fable에는 파일 수정 권한을 전혀 부여하지 않는다.

이는 편의상의 제한이 아니라 다음을 보장하기 위한 핵심 통제다.

* 원본 증거 보존
* 검사와 정책결정의 분리
* 검사와 구현의 분리
* AI의 범위 확장 차단
* Owner 승인권 유지
* 기존 정규 개발 파이프라인의 무결성 유지

따라서 이번 특별 트랙의 원칙은 다음 한 문장으로 확정한다.

> **Fable은 전체 설계를 읽고 오류를 찾아 보고하지만, 어떤 파일도 건드리지 않는다. 발견된 수정사항은 Owner의 검토 후 기존 정규 개발 절차를 통해서만 반영한다.**
