# 601014_ChangeContract_Cms_Device_Registry_Edid_Mapping.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2 (Claude review / boundary contract)
Owner: TBD
Last Updated: 2026-07-14

## §0 Authority

Based on `601011_Overview_...md`(물리 계층 설계 확정 — Windows/EDID 식별/부팅 런처 흐름), `601012_Logic_...md`(최종 확정 — **옵션 3** 채택, `0043` 수정은 별도 워크패킷으로 이월), `601013_TestPlan_...md`.

**이 계약은 옵션 3 채택 자체를 재논의하지 않는다.** 이번 워크패킷의 범위는 명시적으로 최소화된다: 신규 컬럼 4개 + 신규 함수 2개만 다루며, 기존 함수(`update_did_display()`)는 절대 건드리지 않는다.

- `catchmenu_store.did_devices`에 컬럼 4개 추가: `edid_serial`, `last_detected_edid`, `last_edid_check_at`, `physical_position_label`(전부 nullable).
- 신규 함수 2개 생성: `get_did_device_by_edid()`(읽기 전용 조회), `report_did_device_edid_scan()`(스캔 보고 + 불일치 판정).
- 단일 forward migration으로 구현.

## §1 Allowed Files And Operations

| Operation | Scope |
|---|---|
| 신규 `sql/migrations/XXXX_*.sql` 파일 1개 | `ALTER TABLE catchmenu_store.did_devices ADD COLUMN` ×4(`edid_serial text`, `last_detected_edid text`, `last_edid_check_at timestamptz`, `physical_position_label text`, 전부 nullable, 기본값 없음) + `CREATE FUNCTION catchmenu_store.get_did_device_by_edid(...)` + `CREATE FUNCTION catchmenu_store.report_did_device_edid_scan(...)`. 마이그레이션 번호는 Stage 4 착수 직전 `tools/apply_migrations.py` 기준 다음 빈 번호로 확정(이 계약 작성 시점엔 아직 확정하지 않음 — Open Item 아님, 단순 실행 시점 확인 사항). |
| 해당 마이그레이션 파일의 grant/comment 문 | 신규 함수 2개에 대한 `grant execute`/`comment on function` — 이 프로젝트의 기존 마이그레이션 관례를 따름(예: `0117`/`0154`/`0155` 패턴). |

## §2 Forbidden Files And Operations

| Forbidden item | Reason |
|---|---|
| `sql/migrations/0043_create_did_display_rpc.sql`(`update_did_display()`) | **옵션 3의 핵심 — 이번 워크패킷에서 절대 수정 금지.** `update_did_display()`를 `did_devices` 기준으로 고치는 작업(옵션 1)은 명시적으로 별도 워크패킷으로 이월됐다(`601012_Logic.md` §2, §5(g)). 단 1줄이라도 이 파일에 diff가 생기면 이 계약의 범위를 벗어난 것이다. |
| `sql/migrations/0117_create_did_pipeline_rpc.sql` | `bootstrap_did_app()`/기존 `get_did_display_state()` 등 이번 워크패킷과 무관 — 수정 대상 아님. |
| `catchmenu_store.device_registry` 스키마 | 옵션 3은 이 테이블을 전혀 건드리지 않는 방향으로 확정됨. |
| 콘텐츠 전달 엔진(단계 C, `601011_Overview.md` §4.3) 로직 | 이번 워크패킷은 단계 A(디바이스 레지스트리)만 다룬다 — 전달 엔진 구현은 범위 밖. |
| `did_devices`의 기존 컬럼(`device_id`/`did_code`/`zone`/`display_mode`/`resolution` 등) 변경 | 신규 컬럼 추가만 승인, 기존 컬럼은 손대지 않는다. |
| Flutter/런타임 코드, `tools/` 스크립트 | 범위 밖. |

Implementation must not:

- `0043_create_did_display_rpc.sql`에 어떤 형태로든 diff를 남기지 않는다 — grant/comment 재실행도 포함하여 전혀 건드리지 않는다.
- 신규 4개 컬럼을 `NOT NULL`로 만들지 않는다 — 기존 `did_devices` 행에는 EDID 데이터가 없으므로 `NOT NULL`은 기존 행을 깨뜨린다.
- `edid_serial`/`last_detected_edid`의 정규화 포맷을 이 워크패킷에서 최종 확정된 것처럼 문서화하지 않는다 — `601012_Logic.md` §5(c)가 Open Question으로 남긴 대로, 이번 구현은 텍스트 컬럼 자체만 만들고 포맷 검증(CHECK 제약 등)은 추가하지 않는다(향후 포맷 확정 시 별도 변경으로 추가).

## §3 Required Behavior Preservation

- `did_devices`의 기존 23개 컬럼, 기존 행 데이터는 전혀 변경되지 않는다(4개 컬럼 추가는 순수 확장).
- `update_did_display()`/`get_did_display_state()`/`bootstrap_did_app()`/`call_customer_pickup()` 등 기존 함수의 동작은 이 워크패킷 전후로 완전히 동일해야 한다.
- `device_registry` 스키마와 그 위에 의존하는 ~20개 이상의 다른 테이블은 전혀 영향받지 않는다.

## §4 Required New Behavior

- `catchmenu_store.get_did_device_by_edid(p_tenant_id, p_store_id, p_edid_serial, p_locale default 'ko')`가 등록된 EDID에 대해 디바이스 정보를 반환하고, 미등록 EDID에 대해 명시적 에러를 반환한다.
- `catchmenu_store.report_did_device_edid_scan(p_tenant_id, p_store_id, p_device_id, p_detected_edid, p_correlation_id default null)`이 `last_detected_edid`/`last_edid_check_at`을 갱신하고, `edid_serial`과의 일치/불일치를 `is_mismatch`로 정확히 판정해 반환한다.
- `did_devices`에 4개 신규 컬럼이 nullable로 존재한다.

## §5 Verification Requirements

`601013_TestPlan.md` §1-§6(Acceptance Criteria) 전부 PASS. 특히 §5(Boundary)의 `0043` 무변경 확인은 예외 없이 필수.

## §6 Open Items Not Approved In This Contract

### §6.1 `update_did_display()`를 `did_devices` 기준으로 수정 (옵션 1, 별도 워크패킷)

`601012_Logic.md` §2가 확정한 대로, 이 작업은 이번 계약에 포함되지 않는다. 향후 별도 워크패킷에서 `600820`/`601010`과 같은 방식(Overview → Logic → TestPlan → ChangeContract)으로 다시 다뤄야 한다 — 이번 계약이 그 필요성을 없애지 않는다는 점을 명시(EDID 매핑이 `did_devices`를 사실상 1차 진실 원천으로 만들수록, `update_did_display()`가 여전히 `device_registry`만 보는 불일치는 그대로 남는다).

### §6.2 Windows EDID 판독 기술 조사

`601012_Logic.md` §4/§5(a) — WMI/SetupAPI/DXGI로 실제 EDID·좌표를 읽어올 수 있는지, 멀티 그래픽카드 벤더 간 차이, 서드파티 유틸리티 필요 여부. 소프트웨어 설계 범위 밖의 별도 조사 태스크.

### §6.3 EDID 불일치 알림 메커니즘

`601012_Logic.md` §3.2/§5(f) — `is_mismatch: true`가 보고된 이후 관리자에게 어떻게 알릴지(대시보드, 예외 테이블 기록, 실시간 알림 등)는 이번 계약이 다루지 않는다. `report_did_device_edid_scan()`은 판정 결과를 반환할 뿐, 그 결과를 소비하는 알림 파이프라인은 별도.

### §6.4 EDID 정규화 포맷 확정

`601012_Logic.md` §5(c) — `edid_serial`이 정확히 어떤 EDID 필드 조합으로 구성될지는 §6.2의 기술 조사와 함께 확정되어야 한다. 이번 워크패킷은 형식-불문 `text` 컬럼만 만든다.

### §6.5 불일치 지속 시간 이력 추적

`601012_Logic.md` §1/§5(d) — 별도 이력 테이블 필요 여부, 이번 계약은 다루지 않는다(현재 상태 컬럼 2개로 충분한 범위만 구현).

## §7 Risk

Risk level: **LOW.**

Reasons:

- 순수 추가형 변경(신규 컬럼 4개 nullable, 신규 함수 2개) — 기존 함수/테이블 수정 없음.
- 가장 큰 리스크였을 `0043` 수정(옵션 1)이 명시적으로 이번 범위에서 제외됨 — Option 3 채택의 직접적 효과.
- `device_registry`(20개 이상 테이블이 의존하는 핵심 테이블)는 전혀 손대지 않는다.

Risk controls:

- `601013_TestPlan.md` §5의 `0043` 무변경 확인을 "예외 없는" 필수 조건으로 명시.
- 4개 신규 컬럼 전부 nullable — 기존 데이터 무결성 리스크 없음.

## §8 Human Boundary Approval

Human 승인이 Stage 4 착수 전 필요하다.

☑ `did_devices` 4개 컬럼 추가(전부 nullable) + 신규 함수 2개(`get_did_device_by_edid`/`report_did_device_edid_scan`)를 §1에 명시된 그대로 승인한다. (승인일자: 2026-07-15)
☑ `0043_create_did_display_rpc.sql` 절대 무수정 원칙(옵션 3, §2)을 재확인한다.
☑ §6의 5개 Open Item(0043 수정 별도 워크패킷/Windows EDID 기술조사/불일치 알림/정규화 포맷/이력 추적)이 이번 계약 범위 밖임에 동의한다.

## §9 Stage 4 Instruction If Approved

**§8의 3개 박스가 전부 체크되면 Stage 4를 시작한다.** 신규 forward migration 1개(다음 빈 번호, 실행 시점에 `tools/apply_migrations.py` 기준 확정) 작성 → 로컬 컨테이너 적용 → `601013_TestPlan.md` §1-§6 전체 재현 → `0043` 무변경 최종 재확인 순으로 진행한다.
