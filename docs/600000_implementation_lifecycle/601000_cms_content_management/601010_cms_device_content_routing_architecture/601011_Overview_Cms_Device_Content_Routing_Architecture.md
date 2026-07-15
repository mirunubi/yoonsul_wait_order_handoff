# 601011_Overview_Cms_Device_Content_Routing_Architecture.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`cms_device_content_routing_architecture`

## §0 위치/번호 확인

`601000_cms_content_management/`는 신규 도메인 — `000005`/`000007` 재조회 결과 `601000`이 `docs/990000_legacy_quarantine/601000_olm_model/`(범용 문서 템플릿 스캐폴드, 인덱스 상태 `moved`)에 이미 쓰이고 있음을 확인, Human 결정으로 그대로 재사용(600000 대역 재사용 선례와 동일 논리, `000002_Naming_Rules.md`에 근거 기록 완료). 도메인 폴더(`601000_Readme_...md`/`601002_NavigationMap_...md`)와 워크패킷 폴더(`601010_cms_device_content_routing_architecture/`) 생성 완료.

## §1 물리 구조 (Human 확정, 2026-07-14 물리 계층 설계 확정 반영)

- 디지털 사이니지 4대 + 주방/대기 DID 4~5대.
- 멀티 그래픽카드 + 4포트 이상 — 물리 설치는 Human이 직접 수행(소프트웨어 워크패킷 범위 밖).
- **운영체제**: Windows, 멀티 그래픽카드 + 확장 데스크탑(extended desktop) 방식.
- **물리 디바이스 식별 방식**: EDID(Extended Display Identification Data) 기반. **포트 번호 고정 방식은 기각됨** — 케이블 재배치·청소·수리 등으로 물리적 연결이 바뀌어도 올바른 디바이스 식별이 유지되어야 한다는 것이 기각 근거.
- **아키텍처 개념(확정)**: 부팅 시 런처 프로그램이 EDID 스캔 → DB의 EDID-디바이스 매핑 조회 → 각 모니터에 맞는 전용 앱 창을 정확한 위치(확장 데스크탑 좌표)에 배치 → 그 앱이 자기 `device_id`를 인지하고 §2 콘텐츠 라우팅 매트릭스에 따라 콘텐츠를 요청하는 흐름.

## §2 콘텐츠 라우팅 매트릭스 (Human 확정)

| 콘텐츠 | 출처 | 목적지 | 전달방식 |
|---|---|---|---|
| 주방 티켓/조리 상태 | KDS | 대기·주방 DID | 실시간 |
| 고객 호출(픽업) | KDS | 대기 DID | 실시간 |
| 품절/재고 가용성 | KDS | 키오스크 | 실시간 |
| 매장 할인 정책 | CMS/매장설정 | 키오스크 | 실시간 |
| 광고/프로모션 | CMS | 디지털 사이니지 | 캐시(주기적) |
| 메뉴판(가격/사진) | CMS | 디지털사이니지+키오스크 | 혼합(평소 캐시, 가격변경시 실시간 무효화) |
| 다국어/계절 콘텐츠 스케줄 | CMS | 디지털 사이니지 | 캐시(스케줄기반) |

## §3 스케줄링 요구사항 (Human 확정)

- 시간대 + 요일 + 계절(날짜범위) 전부 조합 가능.
- 규칙 충돌 시 관리자 지정 수동 우선순위 숫자로 해결.
- 디바이스 그룹 타겟팅(전체 사이니지 vs 특정 구역) 가능해야 함.

## §4 4단계 아키텍처 개관 및 의존관계

```
A. 디바이스 레지스트리 + 물리 포트 매핑 (기반 계층)
        │
        ├──────────────┐
        ▼              ▼
B. CMS 콘텐츠 핵심   (독립적으로 병행 개발 가능 — A와 직접 의존 없음)
   (콘텐츠 라이브러리 + 스케줄 규칙 엔진)
        │              │
        └──────┬───────┘
               ▼
C. 콘텐츠 전달 엔진 (A + B 둘 다 필요)
   KDS/CMS → 디바이스군 라우팅, 실시간/캐시 하이브리드
               │
               ▼
D. 키오스크 연동 (A 필요, C는 선택적 — 아래 §4.4 참고)
```

### §4.1 단계 A — 디바이스 레지스트리 + EDID 기반 물리 식별

**역할**: 사이니지 4대 + DID 4~5대를 소프트웨어적으로 식별·관리하는 기반 계층.

**식별 원칙(확정, §1)**: 포트 번호 고정 방식이 아니라 **EDID 기반 식별**을 원칙으로 한다 — 디바이스의 물리적 정체성은 "어느 그래픽카드의 몇 번 포트에 꽂혀 있는가"가 아니라 "그 모니터/디스플레이 장치 고유의 EDID"로 판별한다. 부팅 시 런처가 EDID를 스캔해 DB의 EDID-디바이스 매핑을 조회하고, 그 결과로 각 전용 앱 창을 올바른 확장 데스크탑 위치에 배치하는 흐름이 이 단계의 핵심 산출물이다. 상세 컬럼/RPC 설계는 `601012_Logic_Cms_Device_Registry_Edid_Mapping.md`.

**핵심 발견 — `did_devices`/`device_registry` 불일치(§5에서 상세)**: 이 계층을 설계하려면 기존 두 테이블의 불일치를 반드시 다뤄야 한다. EDID 컬럼을 어느 테이블에 추가할지는 이 불일치 처리 방향(§6)과 직접 연결되므로, 결정은 `601012_Logic.md`로 이월한다.

**하위 산출물 후보(결정 아님, 범위 스케치)**: 디바이스 그룹(존/구역) 정의, EDID-디바이스 매핑 컬럼(`601012_Logic.md`에서 상세 설계), 디바이스 그룹 타겟팅을 위한 그룹-멤버십 구조(§3의 "전체 사이니지 vs 특정 구역" 요구사항 지원), 부팅 런처의 EDID 조회 RPC.

### §4.2 단계 B — CMS 콘텐츠 핵심 (콘텐츠 라이브러리 + 스케줄 규칙 엔진)

**역할**: 광고/프로모션/메뉴판/다국어·계절 콘텐츠를 저장하고, §3의 스케줄 규칙(시간대+요일+날짜범위 조합, 수동 우선순위 충돌 해결)을 평가하는 엔진.

**A와의 관계**: 콘텐츠 자체와 스케줄 규칙은 "어떤 디바이스가 물리적으로 존재하는가"와 독립적으로 설계·구현 가능하다 — 콘텐츠 라이브러리 스키마와 규칙 평가 로직은 A의 디바이스 레지스트리 완성을 기다릴 필요가 없다. 다만 "디바이스 그룹 타겟팅"(스케줄 규칙이 대상으로 삼는 디바이스 그룹)은 A가 정의하는 그룹 구조를 참조하므로, **콘텐츠 스키마 자체는 A와 독립적이나, 스케줄 규칙의 "타겟" 필드는 A의 그룹 정의를 전제**한다 — 이는 완전한 독립이 아니라 느슨한 의존(설계는 병행 가능, 최종 통합 시점에 A의 그룹 스키마 확정 필요)임을 명시한다.

### §4.3 단계 C — 콘텐츠 전달 엔진 (A + B 필요)

**역할**: §2 매트릭스의 "전달방식" 컬럼을 실제로 구현 — KDS발 실시간 콘텐츠(조리상태/고객호출)와 CMS발 캐시/스케줄 콘텐츠(광고/메뉴판/다국어)를 각각의 목적지 디바이스군으로 라우팅.

**기존 조각과의 관계**: `call_customer_pickup()`(`0079`/`0094`)이 "KDS 이벤트 → `did_display_queue` 삽입 → realtime 브로드캐스트"라는 이 단계의 **실시간 경로 선례**를 이미 구현하고 있다 — 재사용/일반화 검토 대상. 다만 `did_display_queue.queue_type` CHECK 제약(`WAITING_CALL`/`PICKUP_READY`/`TABLE_READY`/`DELIVERY_READY`/`CUSTOM_MESSAGE`)은 픽업 호출류 실시간 메시지만 상정하고 있어, §2의 캐시성 콘텐츠(광고/메뉴판/스케줄)를 그대로 태울 수 있는 구조가 아니다 — 이 큐를 확장할지, 별도 캐시 전달 경로를 신설할지는 이번 문서에서 결정하지 않는다(Open Question, §6).

**명시적 의존**: A(디바이스가 어디 있는지 알아야 라우팅 가능) + B(무엇을 보낼지 콘텐츠/스케줄이 있어야 라우팅 가능) 둘 다 선행되어야 한다.

### §4.4 단계 D — 키오스크 연동

**역할**: §2의 "품절/재고 가용성"(KDS발, 실시간)과 "매장 할인 정책"(CMS발, 실시간) 두 피드를 키오스크에 제공.

**의존관계 — C를 반드시 거치지 않을 수 있음**: §2 매트릭스에서 키오스크로 가는 두 콘텐츠는 전부 "실시간"이며, C 단계가 다루는 "캐시/스케줄 하이브리드" 성격이 아니다 — `get_kds_realtime_state()`(이미 동작 확인, §5) 같은 실시간 조회 함수를 키오스크가 직접 호출하는 구조로 충분할 가능성이 높다. 따라서 D는 **A(키오스크도 디바이스 레지스트리의 한 device_type이므로 식별 필요)에는 의존하지만, C(캐시/스케줄 전달 엔진)에는 반드시 의존하지 않을 수 있다** — 다만 메뉴판(§2에서 "혼합", 시니지+키오스크 공용)처럼 C의 캐시-무효화 메커니즘을 공유해야 하는 콘텐츠가 있으므로, **완전히 무관하지는 않다**. 이 경계를 정확히 어디에 그을지는 Open Question(§6).

## §5 기존 조각 재확인 (직접 실증, 오늘 세션 신규 확인분 포함)

### §5.1 `get_kds_realtime_state()` — 동작 확인

`0099_create_realtime_pipeline_rpc.sql`, `catchmenu_kds.get_kds_realtime_state(p_tenant_id, p_store_id, p_locale default 'ko')`. 직접 호출 재확인 — 정상 동작(`success: true`, capacity/ticket/stats 필드 포함). §2의 "품절/재고 가용성→키오스크 실시간" 경로 후보로 재사용 가능성 있음(다만 이 함수 자체가 재고/품절 필드를 갖고 있는지는 이번 조사에서 본문까지 대조하지 않았음 — Open Question).

### §5.2 `get_did_display_state()` — 중요 정정: 여전히 2개 라이브 오버로드 존재

**배경 문서의 "오늘 오버로드 정리 완료"라는 전제를 그대로 받아들이지 않고 라이브 재확인한 결과, 이 전제는 부정확하다.** `pg_get_function_identity_arguments()` 직접 조회 결과:

```
p_tenant_id uuid, p_store_id uuid, p_device_id uuid              (0043, 3-param, 구 버전)
p_tenant_id uuid, p_store_id uuid, p_did_id uuid, p_locale text  (0117, 4-param, 신 버전)
```

**정확한 상태**: `600512_Logic_Did_Display_State_Overload.md`(→ `600822`)에서 "Option A: 0043 DROP" 결정은 확정됐으나(Stage 2), 그 워크패킷(`600820_did_display_state_overload_and_legacy_defect/`)은 **아직 Stage 4 구현이 실행되지 않았다** — TestPlan/ChangeContract까지만 존재, Module/Verification/Audit 없음. "오늘 정리 완료"는 설계 결정(Stage 2) 완료를 가리키는 것이지 구현(Stage 4) 완료가 아니다 — 이 CMS 설계 문서는 **현재 라이브 상태(2개 오버로드 공존, 3-param은 nested-aggregate 버그로 크래시)** 를 전제로 해야 하며, `600820`의 Stage 4가 먼저 완료되기를 기다리거나, 이 CMS 워크패킷이 그 완료를 전제조건으로 명시해야 한다(Open Question, §6).

### §5.3 `call_customer_pickup()` — 실시간 전달 선례로 확인

`0079_create_did_advanced_rpc.sql`(원본) + `0094_fix_i18n_hardcoded_strings.sql`(현재 라이브 버전, 함수 본문 교체). 라이브 시그니처: `p_tenant_id, p_store_id, p_order_id, p_queue_type default 'PICKUP_READY', p_target_zone default null, p_locale default 'ko', p_correlation_id default null`. 동작: `did_devices`에서 대상 디바이스 조회(zone/display_mode 매칭) → `did_display_queue`에 삽입 → realtime 브로드캐스트 → `PICKUP_READY`시 주문 상태 갱신 → 원장 이벤트 기록. §4.3에서 언급한 "실시간 경로 선례"의 실제 근거.

### §5.4 `did_display_queue` 테이블 — 스키마 확인

`catchmenu_store.did_display_queue`(`0079`에서 생성). `did_device_id`(FK → `did_devices`, **`device_registry` 아님**), `queue_type`(CHECK: 픽업호출류 5종만), `priority`, `display_message jsonb`, `display_locale`, `queue_status`(PENDING/DISPLAYING/DISMISSED/EXPIRED/CANCELLED) 등. §4.3에서 언급했듯 캐시성 CMS 콘텐츠를 태우기엔 `queue_type` CHECK가 좁다.

### §5.5 `update_did_display()` — 미해결 발견 재확인 및 정확한 근거

`0043_create_did_display_rpc.sql`, `catchmenu_store.update_did_display(p_tenant_id, p_store_id, p_device_id, p_display_mode, p_display_content default '{}', p_actor_type default 'STAFF', p_actor_id default null, p_correlation_id default null)`. 본문 L427-436을 직접 인용:

```sql
-- device validation
select id, device_code, device_name,
       device_type, device_status
into v_device
from catchmenu_store.device_registry
where id = p_device_id
  and store_id = p_store_id
  and tenant_id = p_tenant_id
  and device_type in ('DID', 'CMS')
  and is_active = true;
```

**`did_devices`를 전혀 참조하지 않는다** — `device_registry`만 사용. 오늘 어떤 DID 정리 마이그레이션도 이 함수를 건드리지 않았다(전체 `sql/migrations/` grep 결과 `update_did_display`는 `0043` 한 곳에만 정의, 이후 패치/오버라이드 없음). 라이브에서도 여전히 이 시그니처 그대로 1개만 존재.

### §5.6 `did_devices` vs `device_registry` — 불일치의 정확한 성격 (역사적 기원까지 확인)

- `device_registry`(`0003`, 가장 오래됨): POS/KDS/KIOSK/DID/CMS 등 모든 디바이스 타입을 포괄하는 범용 테이블. `device_type` CHECK에 이미 `DID`/`CMS`/`KIOSK` 포함. 약 20개 이상의 다른 테이블이 여기 FK를 건다.
- `did_devices`(`0079`, `device_registry`보다 나중에 생성): DID 전용 특화 테이블. `device_id`가 `device_registry(id)`를 가리키는 **nullable** FK — 즉 `did_devices` 행이 반드시 `device_registry` 행을 가질 필요가 없다.
- **불일치의 실제 형태**: 두 테이블이 서로 대체 관계가 아니라 "베이스+특화" 관계로 설계된 것으로 보이나, `update_did_display()`(`0043`, `did_devices`보다 먼저 작성됨)는 옛 방식(`device_registry`만 검증)을 그대로 쓰고 있고, `0079` 이후 작성된 모든 DID 관련 함수(`call_customer_pickup`, `did_display_queue`의 FK, `0117`의 파이프라인 RPC들)는 `did_devices`를 쓴다. **`did_devices.device_id`가 null인 디바이스는 `update_did_display()`가 찾지 못하고, `device_registry`에만 등록되고 `did_devices`에 없는 디바이스는 큐/호출 계열 함수가 찾지 못한다** — 두 계열의 함수가 서로 다른 테이블을 진실의 원천으로 삼고 있다.
- **참고**: `did_devices.display_mode`의 CHECK 값(`WAITING`/`PICKUP`/`MENU`/`PROMOTION`/`MIXED`/`SLIDESHOW`)에는 이미 디지털 사이니지 성격의 값(`MENU`/`PROMOTION`/`SLIDESHOW`)이 포함되어 있다 — 즉 이 테이블은 애초에 "DID(대기/픽업 호출)"과 "디지털 사이니지"를 하나의 테이블로 포괄할 의도로 설계됐을 가능성이 있다(§6에서 옵션으로 재확인).

## §6 단계 A 설계 방향 — `did_devices`/`device_registry` 불일치 처리 옵션 (결정 아님)

세 가지 옵션을 근거와 함께 제시한다. Human 결정 대기.

**옵션 1 — `update_did_display()`를 `did_devices` 기준으로 수정**: `0043`의 device validation 쿼리를 `device_registry` 대신(또는 함께) `did_devices`를 조회하도록 바꾼다. 장점: `did_devices`가 이미 사실상 진실의 원천으로 굳어진 최신 함수들(`call_customer_pickup`, `0117` 계열)과 일관성 확보. 단점: `.sql` 수정 필요(이번 턴 범위 밖), `update_did_display()`의 실제 호출자가 있는지 아직 조사 안 됨(Open Question).

**옵션 2 — `did_devices`를 `device_registry`에 흡수 통합**: `did_devices`의 DID 특화 컬럼(`did_code`/`zone`/`display_mode`/`call_*` 등)을 `device_registry`에 nullable 컬럼으로 병합하고 `did_devices` 자체를 폐기. 장점: 단일 진실 원천, `update_did_display()` 수정 불필요. 단점: 대규모 스키마 변경, `did_display_queue` 등 `did_devices` FK를 가진 기존 테이블 다수 영향, 이번 CMS 신규 워크패킷 범위를 크게 넘어섬.

**옵션 3 — 현행 유지 + CMS 신규 레이어(단계 A)가 양쪽을 모두 아우르는 조회 뷰/래퍼 함수 신설**: 두 테이블 구조는 그대로 두고, 새로 만들 디바이스 레지스트리 조회 계층(단계 A)이 `did_devices`와 `device_registry`를 조인한 뷰(또는 래퍼 함수)를 통해 "디바이스가 실제로 사용 가능한지"를 판단하게 한다. `update_did_display()`는 손대지 않는다. 장점: 기존 함수 무엇도 건드리지 않아 가장 낮은 리스크, `.sql` 신규 추가만으로 가능. 단점: 근본 불일치는 해소되지 않고 새 레이어가 그 위에 우회로를 하나 더 얹는 것 — 향후 세 번째 관점(뷰)까지 관리해야 하는 복잡도 증가.

**디지털 사이니지 테이블 자체에 대한 부수 질문(§5.6 참고)**: `did_devices.display_mode`가 이미 사이니지 유즈케이스(`MENU`/`PROMOTION`/`SLIDESHOW`)를 포괄하므로, 별도 "signage_devices" 테이블을 새로 만들 필요 없이 `did_devices`를 사이니지 4대 + DID 4~5대 전부의 물리 디바이스 테이블로 그대로 쓸 수 있을 가능성이 있다 — 이는 옵션 1/2/3 중 무엇을 택하든 별개로 검토 가능한 질문이며, 이번 문서는 결정하지 않는다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `000701_Guide_Controlled_AI_Development_Pipeline.md`(§42/§43/§44)
- Human이 이번 턴 확정한 물리 구조/라우팅 매트릭스/스케줄링 요구사항(§1-§3, 이 문서 자체가 최초 기록)

### Full Rules Required

- `000053_Matrix_Domain_To_Artifact_Traceability.md` §D(DID) 섹션 — DID 도메인의 기존 산출물 전수 매핑(오늘 신설, 이 워크패킷의 직접 선행 조사).
- `sql/migrations/0079_create_did_advanced_rpc.sql` — `did_devices`/`did_display_queue`/`call_customer_pickup()` 원본 정의.
- `sql/migrations/0043_create_did_display_rpc.sql` — `update_did_display()`/`device_registry` 검증 로직.
- `sql/migrations/0003_create_store_device_agent_registry.sql`/`0132_create_device_registry_enhanced.sql` — `device_registry`의 범용 설계.
- `600512_Logic_Did_Display_State_Overload.md`(→`600822`) — `get_did_display_state()` Option A 결정(Stage 2, 미구현) 원문.

### Domain Indexes

- `601000_Readme_Cms_Content_Management.md`/`601002_NavigationMap_Cms_Content_Management.md`(이 도메인 자체, 이번 턴 신설).
- `600802_NavigationMap_Did_Implementation.md`(DID 도메인 현황 — `600820` 워크패킷이 아직 Stage 2임을 보여줌).

### Excluded Rule Families

- KDS 티켓 라이프사이클 자체의 재설계 — `get_kds_realtime_state()`를 소비만 하고 그 내부 로직은 재론하지 않음.
- 결제 도메인(`600500_payment_confirmation/`) — 이번 CMS 아키텍처와 무관.
- 물리 하드웨어 설치 절차 — Human 직접 수행, 소프트웨어 설계 범위 밖.

## Module Domain Tags

- SQL (예정, 이번 턴은 설계만 — 지시대로 `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY (이번 턴 실제 산출물)

## Open Questions (해결 안 됨, Stage 2 이후로 이월)

(a) 단계 A의 `did_devices`/`device_registry` 불일치 처리 — 옵션 1/2/3 중 미결정(§6).
(b) `did_display_queue.queue_type`을 확장할지, CMS 캐시 콘텐츠용 별도 전달 경로를 신설할지(§4.3).
(c) 단계 D(키오스크)가 단계 C(전달 엔진)의 캐시-무효화 메커니즘을 어디까지 공유해야 하는지 — 메뉴판(혼합형)만 공유, 나머지는 완전 분리 가능성(§4.4).
(d) `get_did_display_state()`의 `600820` 워크패킷 Stage 4 구현이 이 CMS 워크패킷의 선행조건인지, 병행 가능한지(§5.2).
(e) `get_kds_realtime_state()`가 실제로 재고/품절 필드를 반환하는지 — 이번 조사에서 존재 확인만 하고 본문 필드까지 대조하지 않음(§5.1).
(f) `update_did_display()`의 실제 호출자(있는지 여부) — 이번 조사에서 확인하지 않음, 옵션 1의 리스크 판단에 필요.

## Snapshot Decision

**확정 아님 — Stage 1.5 개관.** §1-§3(Human 확정 요구사항)은 그대로 반영, §4(4단계 구조와 의존관계)는 설계 골격으로 제시, §5(기존 조각)는 전부 라이브 재확인 완료(단, §5.2에서 배경 전제 하나를 정정), §6(단계 A 옵션)은 결정하지 않고 3가지 옵션만 제시. `.sql` 파일은 이번 턴에 생성·수정하지 않았다(읽기 전용 조사만 수행).
