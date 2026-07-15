# 601012_Logic_Cms_Device_Registry_Edid_Mapping.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`cms_device_registry_edid_mapping`

## §0 전제 — `601011_Overview.md` 갱신 반영

`601011_Overview_Cms_Device_Content_Routing_Architecture.md` §1/§4.1이 이번 턴 확정한 물리 계층 설계를 그대로 전제한다: Windows + 멀티 그래픽카드 + 확장 데스크탑, EDID 기반 디바이스 식별(포트 번호 고정 기각), 부팅 런처가 EDID 스캔 → DB 매핑 조회 → 앱 창 배치 → 그 앱이 자기 `device_id`로 콘텐츠 요청하는 흐름.

## §1 `did_devices` 컬럼 추가 설계 (초안, 결정 아님)

| 컬럼명 | 타입(제안) | 용도 |
|---|---|---|
| `edid_serial` | `text` | 이 디바이스로 등록된 "기대되는" EDID 기반 고유 식별자. EDID 원본은 제조사 ID/제품 코드/시리얼번호/제조연월 등 여러 필드로 구성되므로, 이 컬럼은 그 중 안정적으로 유지되는 필드들을 조합한 정규화된 문자열(예: `제조사ID:제품코드:시리얼번호`)로 설계하는 것을 제안한다 — EDID 전체 원본 블록을 그대로 저장하는 것은 불필요하게 크고 파싱 로직을 소비 측(런처)과 저장 측(DB) 양쪽에 중복시킨다. 스토어 범위 내 UNIQUE 제약 후보(같은 스토어 안에서 동일 EDID가 두 디바이스로 등록되는 것 방지). |
| `last_detected_edid` | `text` | 가장 최근 런처 스캔에서 실제로 감지된 EDID 식별자(같은 정규화 형식). 부팅/하트비트마다 런처가 갱신. `edid_serial`과 다르면 "이 포지션에 원래 등록된 디바이스가 아닌 다른 모니터가 연결됨"을 의미 — 드리프트(청소/수리 중 재배치, 고장으로 인한 임시 교체 등) 감지의 근거 데이터. |
| `last_edid_check_at` | `timestamptz` | `last_detected_edid`가 마지막으로 갱신된 시각 — 오래 갱신되지 않은 디바이스(런처가 죽었거나 네트워크 단절)를 구분하기 위한 보조 컬럼(제안, 필수 아님). |
| `physical_position_label` | `text` | 관리자 화면에 노출할 사람이 읽기 쉬운 설명(예: "홀 입구 좌측 사이니지", "주방 앞 DID"). `zone`(기존 컬럼, ENUM형 대분류)과는 별개로 자유 텍스트 세부 설명을 담당 — `zone`이 "WAITING_AREA" 같은 카테고리라면 이 컬럼은 그 카테고리 안에서 사람이 실제로 위치를 특정할 수 있는 설명. |

**불일치 플래그 자체는 별도 컬럼으로 저장하지 않는 것을 제안(초안)**: `edid_serial ≠ last_detected_edid`라는 조건 자체가 곧 불일치 상태이므로, 이를 별도의 boolean 컬럼(`has_edid_mismatch` 등)으로 중복 저장하면 두 소스가 어긋날 위험(컬럼 갱신을 깜빡하는 경우)이 생긴다 — §3의 조회 RPC가 매번 두 컬럼을 비교해 판정 결과를 계산해 반환하는 방식을 제안한다. 다만 "불일치가 얼마나 오래 지속됐는가"를 추적하려면 별도 이력 테이블이 필요할 수 있음 — Open Question(§5)으로 남긴다.

## §2 §6(기존 `did_devices`/`device_registry` 불일치 옵션) 재검토 — 확정: 옵션 3 채택 (Human 결정 2026-07-14, 재논의 금지)

`601011_Overview.md` §6이 제시한 3개 옵션을 EDID 컬럼 추가라는 새 사실에 비추어 재검토한다.

**핵심 관찰**: EDID는 물리적으로 연결된 **디스플레이 장치**의 속성이다. `device_registry`는 POS/KIOSK/DID/CMS/PRINTER/PAYMENT_TERMINAL/SENSOR/ROBOT 등 화면이 없는 디바이스 타입까지 포괄하는 범용 테이블인 반면, `did_devices`는 이미 `display_mode`/`resolution`/`orientation` 같은 디스플레이 전용 속성을 갖고 있다 — EDID 컬럼은 개념적으로 `did_devices` 쪽에 훨씬 자연스럽게 속한다(`device_registry`에 추가하면 프린터/센서/로봇 행에도 의미 없는 EDID 컬럼이 존재하게 됨).

**옵션별 재검토**:

- **옵션 1(`update_did_display()`를 `did_devices` 기준으로 수정)** — EDID 추가로 오히려 **더 자연스러워진다**. 런처의 핵심 조회 흐름 자체가 "EDID → `did_devices` 조회 → `device_id` 확보"이므로, `did_devices`가 런타임 식별의 실질적 시작점이 된다. 그런데 `update_did_display()`(`0043`)는 여전히 `device_registry`만 검증하므로 — `did_devices.device_id`가 null인 채로 EDID 매핑만으로 운영되는 디바이스는 `update_did_display()`가 아예 찾지 못하는 상황이 발생한다. EDID 도입 이전보다 이 옵션의 필요성이 더 명확해졌다.
- **옵션 2(`did_devices`를 `device_registry`에 흡수)** — EDID 추가로 오히려 **덜 자연스러워진다**. EDID/해상도/방향 같은 디스플레이 전용 속성이 늘어날수록, 이를 화면 없는 디바이스까지 포함하는 범용 테이블에 흡수하는 것은 그 테이블의 "범용성"이라는 원래 설계 의도와 더 어긋나게 된다.
- **옵션 3(현행 유지 + 조회 뷰/래퍼)** — 여전히 유효하지만, 이제 그 뷰/래퍼의 **1차 조회 키가 사실상 EDID(→`did_devices`)가 되어야 한다**는 점이 명확해졌다 — `device_registry`는 있으면 참조하는 보조 정보로 격하되는 모양새가 된다.

**확정(Human 결정, 2026-07-14, 재논의 금지)**: **옵션 3** 채택 — 지금은 EDID 조회(§3)를 `did_devices` 우선으로 설계하고, `update_did_display()`(`0043`)를 `device_registry` 대신 `did_devices` 기준으로 고치는 작업(옵션 1)은 **별도 워크패킷으로 이월**한다. 이번 워크패킷(`cms_device_registry_edid_mapping`)은 범위를 최소화 — `0043`은 이번 워크패킷 전체에서 **절대 수정하지 않는다**(`601014_ChangeContract.md`의 Forbidden 항목으로 명시).

**근거(재검토 결과 그대로 채택)**: 옵션 1이 EDID 도입으로 더 자연스러워졌다는 §2 재검토 결론 자체는 유효하나, "더 자연스럽다"는 것과 "지금 이 워크패킷에서 함께 처리한다"는 것은 별개다 — `0043` 수정은 기존에 안정적으로 동작 중인 `update_did_display()`의 검증 로직을 바꾸는 것이라 별도의 위험 평가·TestPlan이 필요한 독립적 변경이며, EDID 매핑 도입 자체(순수 신규 컬럼+신규 함수, 기존 함수 무수정)와 리스크 프로파일이 다르다. 옵션 2는 이전 재검토대로 기각 상태 유지.

## §3 런처용 조회 API/RPC 초안 (결정 아님, 설계 스케치)

### §3.1 `get_did_device_by_edid()` — 읽기 전용 조회

```
catchmenu_store.get_did_device_by_edid(
  p_tenant_id uuid,
  p_store_id uuid,
  p_edid_serial text,
  p_locale text default 'ko'
) returns jsonb
```

**역할**: 런처가 부팅 시 스캔한 EDID로 등록된 디바이스 정보를 조회. `edid_serial = p_edid_serial`인 `did_devices` 행을 찾아 `device_id`/`display_mode`/`zone`/`physical_position_label`/(§1 컬럼 확정 시)해상도·방향 등을 반환. 찾지 못하면 `error_key := 'edid_not_registered'` 같은 명시적 에러(런처가 "이 모니터는 아직 등록 안 됨" UI를 보여줄 수 있게).

### §3.2 `report_did_device_edid_scan()` — 스캔 결과 보고 + 드리프트 판정

```
catchmenu_store.report_did_device_edid_scan(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_detected_edid text,
  p_correlation_id text default null
) returns jsonb
```

**역할**: 런처가 (이미 §3.1로 device_id를 확보한 이후) 주기적으로 "지금 이 포지션에 실제로 연결된 EDID"를 보고 — `last_detected_edid`/`last_edid_check_at` 갱신, `edid_serial`과 비교해 `is_mismatch: true/false`를 응답에 포함. 불일치 시 관리자 알림/예외 기록으로 이어질 수 있으나, 그 알림 메커니즘 자체는 이번 문서 범위 밖(Open Question).

**두 함수로 나눈 이유**: §3.1은 "이 EDID가 누구 것인가"를 찾는 최초 부팅 조회, §3.2는 "이미 아는 디바이스가 계속 같은 화면에 붙어 있는가"를 반복 확인하는 하트비트성 호출 — 목적이 다르므로 함수를 분리하는 것을 제안한다(단일 함수로 합칠 수도 있음, 결정 아님).

## §4 Windows EDID 판독 기술 제약 — Open Question (조사 필요, 이번 문서에서 해결 안 됨)

이 문서는 소프트웨어(DB/RPC) 설계 범위이지만, 그 설계가 실제로 구현 가능한지는 런처가 Windows 환경에서 EDID를 실제로 읽어올 수 있는지에 달려 있다 — 아래를 조사 대상 Open Question으로 명시한다(이번 턴에서 조사·해결하지 않음):

(a) Windows 표준 API(WMI `WmiMonitorID` 클래스, `SetupAPI`, 또는 DXGI/디스플레이 열거 API)만으로 연결된 각 모니터의 EDID(제조사 ID/제품 코드/시리얼 번호)를 그래픽카드-포트별로 정확히 읽어올 수 있는지.
(b) 확장 데스크탑 환경에서 "이 EDID가 물리적으로 어느 모니터 좌표(원점 오프셋)에 배치됐는가"까지 API로 알아낼 수 있는지 — 단순 EDID 목록 조회와 "좌표에 매핑된 EDID" 조회는 다른 API일 가능성.
(c) 표준 API로 부족할 경우 별도 유틸리티/드라이버(예: 서드파티 모니터 관리 SDK)가 필요한지, 필요하다면 라이선스/설치 부담.
(d) 그래픽카드 제조사(멀티 그래픽카드 구성이므로 서로 다른 제조사 카드가 섞일 가능성)에 따라 EDID 판독 API 동작이 달라지는지.

**이번 문서의 입장**: DB 스키마(§1)와 RPC 계약(§3)은 "런처가 어떤 방식으로든 EDID 문자열을 얻어 문자열로 넘겨준다"는 인터페이스 경계만 가정하며, 그 안쪽(Windows API 세부사항)에 의존하지 않도록 설계했다 — 즉 (a)-(d)의 조사 결과가 무엇이든 §1/§3의 설계 자체는 크게 바뀌지 않을 것으로 예상되나, 확답은 실제 조사 후에나 가능하다.

## §5 Open Questions (해결 안 됨)

(a) §4의 Windows EDID 판독 기술 조사 — 별도 조사 태스크 필요.
(b) ~~§2의 옵션 1 vs 3 최종 선택~~ — **해소됨(2026-07-14 Human 결정)**: 옵션 3 확정, `0043` 수정(옵션 1)은 별도 워크패킷으로 이월. §2 참고.
(c) EDID 정규화 문자열 포맷(§1의 `edid_serial`) 확정 — 어떤 EDID 필드 조합을 쓸지 기술 조사(§4)와 함께 결정 필요.
(d) 불일치 지속 시간 추적을 위한 별도 이력 테이블 필요 여부(§1).
(e) `report_did_device_edid_scan()`의 호출 주기(부팅 시 1회만인지, 주기적 하트비트인지) — 미정.
(f) EDID 불일치 발생 시 관리자 알림 메커니즘(§3.2에서 범위 밖으로 명시) — 별도 워크패킷 후보.
(g) **신규** — `update_did_display()`(`0043`)를 `did_devices` 기준으로 수정하는 작업(옵션 1) 자체 — 별도 워크패킷 후보로 명시적으로 이월.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `601011_Overview_Cms_Device_Content_Routing_Architecture.md`(이번 턴 갱신된 §1/§4.1, 이 문서의 직접 전제)

### Full Rules Required

- `sql/migrations/0079_create_did_advanced_rpc.sql` — `did_devices` 현재 컬럼 정의(§1 추가 대상 테이블).
- `sql/migrations/0043_create_did_display_rpc.sql` — `update_did_display()`(§2 재검토의 대상).

### Domain Indexes

- `601002_NavigationMap_Cms_Content_Management.md`.

### Excluded Rule Families

- Windows API/EDID 판독 구현 세부사항 — §4에서 Open Question으로만 명시, 이 문서는 그 기술 조사 자체를 수행하지 않음.
- 콘텐츠 라우팅 매트릭스(§2 in `601011`)의 실제 전달 엔진(단계 C) 구현 — 이 문서는 단계 A(디바이스 레지스트리)만 다룸.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정(§2), 나머지는 Stage 2로 구체화 완료.** §2(옵션 3 채택, `0043` 수정 별도 이월)는 Human 결정으로 확정. §1(컬럼 설계 4개)/§3(RPC 2개)은 `601013_TestPlan.md`/`601014_ChangeContract.md`(Stage 2)의 구현 대상으로 그대로 채택. §4(Windows EDID 기술 조사)는 여전히 Open Question(§5(a))으로 이월. `.sql` 파일은 이번 턴에도 생성·수정하지 않았다 — Stage 4 구현 대상은 `601014_ChangeContract.md` §9에 명시.
