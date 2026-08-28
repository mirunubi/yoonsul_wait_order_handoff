# 000221_Guide_Post_0A_Spiral_Sequence.md

Status: Active
Lifecycle: Guide
Last Updated: 2026-08-27

## 1. Purpose

**0-A 이후의 나선 순서를 정한다.**

`000220` §4 가 Foundation 9축 중 ②~⑨ 의 나선 배정을 이월했다.
**이 문서가 그 후속이다.**

> ⚠️ **이 문서는 각 나선의 구현 내용을 정하지 않는다.**
> **순서와 착수 조건, 그리고 검증 등급 기준만 정한다.**
> 각 나선의 범위·설계·계약은 그 나선의 1~4단계가 정한다.

## 2. 현재 상태 실측 (2026-08-27)

```text
스키마    15
테이블    193
```

**권위 판정 상태**

```text
판정됨    catchmenu_hq 21   0-A 재수행이 검증
미판정    나머지 172        0001~0167 이 만들었고 지위가 정해진 적 없다
```

**데이터 — seed 만 존재한다**

| 테이블 | 행 |
|---|---:|
| `catchmenu_hq.tenants` | 1 |
| `catchmenu_hq.stores` | 1 |
| `catchmenu_hq.merchant_accounts` | 1 |
| `catchmenu_pos.menus` | 9 |
| `catchmenu_pos.orders` | 2 |
| `catchmenu_store.customers` | 15 |
| `catchmenu_store.staff` | 0 |
| `catchmenu_store.inventory_items` | 0 |
| `catchmenu_payment.payment_intents` | 0 |
| `catchmenu_kds.kds_tickets` | 0 |

```text
tenants   …0001  YOONSUL_TEST  윤슬 테스트 브랜드
stores    …0002  ULSAN_01      윤슬 울산 1호점
menus     …0050~0058           tenant_id …0001 / store_id …0002
```

**UUID 가 연번 하드코딩이며 seed 계열이다.**
**orphan 은 아니다** — 실제 tenant · store 를 가리킨다.

> ⚠️ **운영 데이터가 없다는 것이 이 계획의 전제다.**
> **마이그레이션 부담이 없으므로 rename 이 아니라 재설계도 선택지다.**

**없는 것**

```text
대기 / waiting / queue / visit / reservation
→ 테이블 0건

catchmenu_common.offline_queue      네트워크 오프라인 큐 — 무관
catchmenu_store.did_display_queue   DID 표시 큐 — 무관
```

**CatchMenu 의 이름이 된 기능이 테이블도 설계도 없다.**

## 3. 나선 순서

```text
Human Gate A   ACTIVE + ISOLATED 동시상태의 과금·서비스 정책 결정

0-A-2          Tenant lifecycle / RPC / batch alignment
0-A-3          Provisioning Integrity
0-B            Identity / Auth / Session / Invitation
0-C            Role / Permission / Scope / RLS

Phase 0 Exit Demo   나선이 아닌 통합 게이트

Phase 1   기존 자산 판정
  1-A   Schema Census
  1-B   Kernel 후보 상세 판정

Phase 2   Kernel 확정
Phase 3   Waiting 신규 설계
Phase 4   Late Binding
Phase 5   외부 provider 연동
Phase 6   YS-OS 모듈 — 2차 개발. 별도 제품
```

> ⚠️ **Phase 0 이 끝나기 전에는 신규 tenant · store 를 만들 수 없고,
> 0-A 가 만든 5테이블은 어떤 화면도 읽을 수 없다.**
>
> ```text
> 쓰기 경로
>   provisioning RPC 3건이 phantom 참조로 실행 불가
>   → 두 번째 tenant 나 store 를 만들 수 없다
>
> 읽기 경로
>   0-A 5테이블   RLS ENABLE + FORCE / policy 0 / grant 는 owner 만
>     persons · legal_entities · legal_entity_person_roles ·
>     legal_entity_representatives · merchant_accounts
>   → 어떤 명명 role 로도 도달 불가
>
>   그 외 catchmenu_hq 16테이블에는 policy 18건이 존재한다
>   → tenants · stores 등은 조건에 따라 읽힐 수 있다
> ```
>
> **읽기 전체가 막힌 것이 아니다.**
> **막힌 것은 쓰기 경로와 0-A 가 새로 만든 5테이블이다.**

> ⚠️ **Phase 6 YS-OS 는 CatchMenu 나선이 아니다.**
>
> ```text
> CatchMenu   platform of record
>             tenant · store · merchant account · identity · role
>             catalog · order · payment · waiting · late binding
>             provider boundary
>
> YS-OS       2차 개발. 별도 제품 · 별도 PostgreSQL · 별도 tenant registry
>             직원 · 재고 · 멤버십 · 포인트를 자기 DB 에 둔다
>             CatchMenu 의 윤슬김밥 tenant 자격으로 CatchMenu API 를 호출한다
> ```
>
> **현실의 동일 사업자 윤슬김밥이 양쪽에 각각 존재한다.**
>
> ```text
> catchmenu_tenant_id ≠ ys_os_tenant_id
> catchmenu_store_id  ≠ ys_os_store_id
> ```
>
> **cross-DB FK 나 공용 tenant PK 를 사용하지 않는다.**
> **API mapping 으로 연결한다.**
>
> **1-1 개발 범위**
>
> ```text
> CatchMenu 자체 웹앱(앱)
> + 외부 제품이 붙일 tenant-scoped API
> ```
>
> ⚠️ **`catchmenu_store` 50테이블은 CatchMenu DB 안에 있다.**
> **어느 것이 CatchMenu 소관이고 어느 것이 YS-OS 로 이관될지는
> Phase 1 Census 가 판정한다.**

### 3.1 초안 명칭과 공식 명칭의 매핑

**이 문서 초판(2026-08-27)이 `Phase 0-1`~`0-4` 를 새로 명명했다.**
**기존 체계에 이미 식별자가 있었으므로 공식 명칭으로 통일한다.**

| 초판 명칭 | 공식 명칭 | 처분 |
|---|---|---|
| Phase 0-1 | `0-A-3` | 초안 별칭 폐기 |
| — | `0-A-2` | **누락. 선행 나선으로 복원** |
| Phase 0-2 | `0-B` | 공식명 사용 |
| Phase 0-3 | `0-C` | 공식명 사용 |
| Phase 0-4 | `Phase 0 Exit Demo` | 나선이 아닌 종료 게이트 |

> ⚠️ **이 매핑은 여기서 한 번만 기록한다.**
> **이후 문서에서 「0-1 (구 0-A-3)」 식으로 병기하지 않는다.**
> 병기가 이어지면 어느 쪽이 canonical 인지 다시 모호해진다.

**`0-A-2` · `0-A-3` 은 `601502` §3.2 의 범위 절단으로 분리된 파생 워크패킷이며
`000701` §47.3 원문에는 없다**(`600010` §2).

### 3.2 권위보류 경계

```text
600010 · 601502 · 601503 · 601505 · 601510 · 601511
```

**위 문서를 추적 · 충돌 · 미완료 범위의 evidence 로 인용한다.**
**그 과거 결론을 현재 authority 로 자동 승계하지 않는다.**

> ⚠️ **`0-A-2` 라는 식별자를 유지하는 것과
> `601502` 의 과거 설계 결론을 권위로 복원하는 것은 다르다.**
>
> ```text
> 식별자        트래커 · 금지조항 · 감사기록을 연결하는 주소
> 권위보류 대상  그 주소에서 내린 과거 판단
> ```
>
> `600020` 이 정지시킨 것은 후자다.

**각 나선의 범위와 업무규칙은 신규 Human declaration 및 계약에서 재판정한다.**

## 4. Phase 0

### 4.1 0-A-2 — Tenant lifecycle / RPC / batch alignment

**선행 게이트 — Human Gate A**

```text
tenant ACTIVE + ISOLATED 동시상태의 과금·서비스 정책 미정
→ 0-A-2 착수 전 Human 결정 필요
근거: 600010 §1.1 (601511)
```

**candidate scope**

```text
isolate_tenant
manage_subscription
tenant_status 필터
is_registered
601505 §4 호출 금지 해제조건 검증
```

> ⚠️ **final scope 는 신규 ImpactScope 와 Human declaration 에서 재검증한다.**
> **권위보류 문서에서 그대로 복사해 확정하지 않는다**(§3.2).

**`601505` §4 의 금지 조항 — 호출 금지 · `ACTIVE` 승격 금지 · 신규 호출자 배포 금지 —
은 `0-A-2` 완료까지 계속 유효하다**(`600010` §1.1).

### 4.2 0-A-3 — Provisioning Integrity

**포함**

```text
C-3                      Store ↔ MerchantAccount tenant 일치 강제
phantom 참조 복구        tenants.owner_name · owner_email · owner_phone
                         stores.extra_metadata
                         tenants.business_number (onboard_tenant)
store_type 정합          provision_tenant 의 'RESTAURANT' 가 chk_stores_type 밖
RPC alignment            H-1 · H-2 · H-3 · H-3a
tenant + merchant_account 동시 생성
store merchant_account binding
stores.merchant_account_id NOT NULL 승격
교차 tenant fault injection
```

**제외**

```text
로그인 / role / permission / UI / 메뉴 · 주문 / provider 연동
```

**완료 조건**

```text
DB · RPC 경로로 신규 tenant 와 store 를 한 번 정상 생성한다
다른 tenant 의 merchant account 연결은 실패한다
```

> ⚠️ **C-3 와 RPC alignment 를 같은 나선에 두는 이유**
>
> ```text
> RPC 가 올바른 tenant 의 MerchantAccount 를 공급한다
>                          +
> DB 가 다른 tenant 의 MerchantAccount 연결을 거부한다
> ```
>
> **C-3 만 먼저 만들면 데이터 입력자가 없다.**
> **RPC 만 고치면 잘못된 연결을 DB 가 허용한다.**
>
> `601748` §8 Mandatory Gates 게이트 1 이 이 순서를 강제한다 —
> **C-3 는 H-2 · H-3 · RLS policy · grant · RPC write path 보다 선행한다.**

> ⚠️ **`owner_name` 복구는 어휘 판정을 수반한다.**
> `601702` §1.37 이 `owner_name` 을 `person_name` 으로 정규화했다.
> **`tenants` 에 사람 정보를 두는 것이 맞는지부터 1단계가 판정한다.**

### 4.3 0-B — Identity Foundation

```text
User / Auth / Session
601702 §1.18 이 0-B 로 이월한 축
```

**선행 판정**

```text
catchmenu_common.auth_sessions
catchmenu_common.login_attempts
catchmenu_common.phone_verify_codes
catchmenu_common.security_tokens
```

**네 테이블이 이미 존재한다.**
**0-B 가 그 위에서 시작하는지 새로 만드는지를 1단계가 판정한다.**

**출구 조건**

```text
0-3 이 사용할 actor_id · session · scope 인터페이스를 고정한다
```

### 4.4 0-C — Authorization Foundation

```text
Role / Permission / Scope / RLS policy
601702 §1.19 · §1.20 이 0-C 로 이월한 축
```

**선행 판정**

```text
catchmenu_store.staff
catchmenu_store.staff_permission_matrix
catchmenu_store.staff_permission_logs
```

**여기서 처음으로 RLS policy 를 만든다.**

> ⚠️ **`601702` §1.45 가 0-A 를 fail-closed baseline 으로 못박았다.**
> **0-C 는 그 위에 필요한 접근 정책만 추가한다.**
> **기본 폐쇄 자체는 계속 유지된다.**

> ⚠️ **`601744` F-7 · `601746` §2.11 a · c 를 여기서 다룬다.**
> `merchant_accounts` 는 현재 어떤 명명 role 로도 도달 불가하며,
> RLS deny-all 은 누출에 안전하나 usable authorization 이 아니다.

**필수 선행조건 — `601503` §9 게이트**

```text
Stage 11B(601510) 4개 조건 중 ② 가 0-A 에서 이행 불가로 0-C 로 이월됐다
  search_path / PUBLIC EXECUTE / tenant 경계

0-A 에는 함수가 없어 조건 ② 의 적용 대상 자체가 없었다
0-C 가 이행하지 않으면 영구히 미충족으로 남는다
```

> ⚠️ **`601503` · `601510` 은 권위보류 대역이다.**
> **이 항목은 finding 으로 승계하며 그 문서의 설계 결론을 복원하지 않는다**(§3.2).

### 4.5 0-B 와 0-C 를 합치지 않는 이유

```text
0-B   누구인가
0-C   무엇을 어디까지 할 수 있는가
```

**합치면 사용자 · 세션 · 초대 · 권한 · RLS 가 한꺼번에 움직여
다시 0-A 규모가 된다.**

### 4.6 Phase 0 Exit Demo

**이 한 장면이 작동해야 다음 Phase 로 넘어간다.**

```text
관리자 로그인
  → tenant 선택
  → store 생성
  → 다른 tenant 접근 거부
  → 생성된 store 가 화면에 표시
```

> ⚠️ **기반공사만 계속하면 지친다.**
> **0-1 ~ 0-3 이 실제로 작동한다는 것을 눈으로 확인하는 단계다.**
>
> 완성도가 아니라 **경로가 뚫렸는지**를 본다.

## 5. Phase 1 — Schema Census 방침

### 5.1 스키마 분류

| 분류 | 스키마 | 처리 |
|---|---|---|
| Kernel 후보 | `pos` · `payment` · `gateway` · `integrations` · `kds` | 우선 일괄 판정 |
| YS-OS 후보 | `store` | 기능군별 분할 판정. 특히 `staff` 계열 9테이블은 제품 귀속부터 판정한다 — `staff` · `staff_shifts` · `staff_attendance` · `staff_schedules` · `staff_tasks` · `staff_memos` · `staff_permission_matrix` · `staff_permission_logs` · `pay_basis_records` |
| 공통 기반 | `common` · `ledger` | 실제 참조되는 일부만 승격 |
| 보조 · 미래 | `ai` · `agent` · `knowledge` | 당분간 동결 |
| 개발 · 증거 | `dev` · `audit` · `meta` | 제품 모델과 분리 |

> ⚠️ **`staff` 계열은 두 제품의 개념이 섞여 있을 수 있다.**
>
> ```text
> CatchMenu   user · role · store 소속
>             누가 이 매장을 CatchMenu 에서 조작할 수 있는가
>             → 0-B · 0-C 소관
>
> YS-OS       employee · shift · attendance · 급여 기준
>             2차 소관. 별도 제품
> ```
>
> **`staff_permission_matrix` 와 `pay_basis_records` 가 같은 스키마에 있다.**
> **Census 가 제품 귀속부터 판정한다.**

> ⚠️ **`catchmenu_common` 41개를 전부 핵심 기반으로 인정하지 않는다.**
>
> ```text
> flutter_sdk_patterns / deployment_checklist / sop_runbooks /
> saas_launch_checklist / integration_test_results
> ```
>
> **런타임 authority 가 아닌 것이 섞여 있다.**

### 5.2 판정표 — 테이블당 1행

| 항목 | 값 |
|---|---|
| disposition | `KEEP` / `REDESIGN` / `DEFER` / `DROP` |
| authority | `CANONICAL` / `SUPPORTING` / `NONE` |
| grade | `A` / `B` / `C` |
| tenant boundary | `tenant` / `global` / `unknown` |
| data | row count |
| dependencies | incoming / outgoing |
| target phase | `Kernel` / `Waiting` / `YS-OS` / `None` |

> ⚠️ **172개에 설계문서 172개를 만들지 않는다.**
> **코드를 바꾸지 않는 census 워크패킷이며 1~2주 안에 닫는다.**
> **여기서 전건 완전 검증을 시도하면 다시 늪에 빠진다.**

### 5.3 3단계 심사

```text
1차   15 schema 일괄 분류
2차   Kernel 후보 schema 의 테이블 관계망 분류
3차   해당 Phase 착수 시 dependency closure 만 상세 검증
```

## 6. 검증 등급

| 등급 | 대상 | 절차 |
|---|---|---|
| **A** | tenant · auth · RLS · 주문 · 결제 · 포인트 · 재고 원장 · late binding | blind design review + 계약 + fault injection + audit |
| **B** | 직원 스케줄 · 회원 프로필 · 쿠폰 · 재고 품목 · 영업시간 | 축약 계약 + 자동 테스트 + 1회 독립검증 |
| **C** | 조회 · 검색 · 화면 배치 · 문구 · 일반 리포트 | 구현계획 + 회귀검사 |

### 6.1 A급 판별 — 7질문

**컬럼 수나 SQL 줄 수로 등급을 정하지 않는다.**
**아래 중 하나라도 YES 면 A급이다.**

```text
tenant 경계를 바꿀 수 있는가
돈 · 포인트 · 재고 수량을 바꿀 수 있는가
주문 상태를 되돌릴 수 없게 만드는가
권한을 확대할 수 있는가
외부 시스템과 한쪽만 성공할 수 있는가
중복 · 재시도 · 동시성이 발생하는가
잘못 연결하면 다른 고객 데이터가 섞이는가
```

> ⚠️ **`601746` D-1 이 이 기준으로 A급이다.**
> **컬럼 하나 추가로 보였으나 tenant 경계를 바꿀 수 있었다.**
> **등급 판정 자체가 판단이며 틀릴 수 있다.**

## 7. Waiting 의 위치

**대기는 독립 bounded context 다. Order 안에 넣지 않는다.**

```text
Waiting                     Order
입장 전 고객 흐름            구매 의사 · 가격 · 상품
호출 · 노쇼 · 입장           주문 · 결제 · 취소
인원 · 좌석 요구             품목 · 옵션 · 금액
```

**둘은 연결되지만 같은 생명주기가 아니다.**

**원칙 3건**

```text
1  대기표는 주문 없이 존재할 수 있다
2  주문은 대기표 없이 존재할 수 있다
3  둘의 결합은 직접 컬럼 덮어쓰기가 아니라 이력이 남는 Late Binding 으로 한다
```

> ⚠️ **`orders.wait_id` 하나를 급히 추가하는 방식을 쓰지 않는다.**
> **결합 · 해제 · 재결합 · 오결합 수정 이력이 필요하다.**

**물리 위치**

```text
확정   catchmenu_store 에 넣지 않는다
       50테이블이 이미 과밀하고, 대기는 000220 상 CatchMenu 모듈이지 YS-OS 가 아니다

미정   스키마명 · 테이블명 — Phase 3 설계가 정한다
```

## 8. 이 문서가 정하지 않는 것

```text
각 나선의 구현 범위 · 물리 스키마 · 테이블 · 컬럼
172테이블 개별 판정 결과
Waiting 의 물리 구조
외부 provider 벤더
일정 · 기간
```

## 9. 근거 문서 목록 (`000701` §46)

| 문서 | 인용 |
|---|---|
| `000220_Guide_Shared_Commerce_Kernel_And_Foundation_Axis.md` | §3 Foundation 9축 · §4 나선 배정 이월 |
| `000718_Governance_Execution_Layer_Externalization_Roadmap_Revision.md` | §1 · §3 · §4 |
| `601702_Register_Stage1_Business_Rules.md` | §1.18 · §1.19 · §1.20 · §1.37 · §1.41 · §1.45 |
| `601746_Report_Stage11C_Conflict_Analysis.md` | §2.1 C-3 · §2.11 · §4 |
| `601744_AuditReview_Operational_Authority_Foundation_V2.md` | F-7 |
| `601748_Evidence_Stage12_Human_Merge_Decision.md` | §8 Mandatory Gates |
| `000705_Guide_Project_Development_Phase_Roadmap_And_AI_Prelearning_Context.md` | 상위 로드맵 |
| `600010_Tracker_Spiral_Workpacket_Progress.md` | §1 · §1.1 · §1.2 · §2 — 나선 식별자 · 게이트 · 금지 조항 |
| `601502` §3.2 | `0-A-2` · `0-A-3` 파생 경위 — **권위보류. evidence 로만 인용** |
| `601503` §9 · `601510` | 0-C 필수 선행조건 — **권위보류. finding 승계** |
| `601505` §4 · §8A | 호출 금지 조항 · 순서 — **권위보류. evidence 로만 인용** |
