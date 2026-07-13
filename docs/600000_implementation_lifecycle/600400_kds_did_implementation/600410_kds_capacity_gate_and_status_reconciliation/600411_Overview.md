# 600411_Overview.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`kds_capacity_gate_and_status_reconciliation`

## §0 확정된 결함 사실 (재검증 불필요, Codex 실증 확인)

`catchmenu_kds.check_kds_capacity()`가 `release_kds_after_payment()` 등 여러 파일에서 호출되나 라이브 DB에 정의 자체가 없다("does not exist" 에러, Codex 실증 확인). 이번 턴에 `CREATE FUNCTION check_kds_capacity` 패턴을 `sql/migrations/*.sql` 전체에서 재확인했고, 실제로 어디에도 정의가 없음을 재확인했다(재검증이 아니라 §1 조사의 일부로서 영향 파일 목록을 만들기 위한 전제 확인).

## Change Summary

`check_kds_capacity()`를 호출하는 8개 파일과, 이름이 비슷한 기존 함수 `evaluate_kds_capacity()`(`0028_create_kds_capacity_commit_rpc.sql`)의 관계를 조사한 결과, **둘은 같은 함수의 다른 이름이 아니라 반환 계약(return contract)이 다른 별개 함수**임을 확인했다(§Logic.md §1 상세). 이번 change는 `check_kds_capacity()`를 `evaluate_kds_capacity()`를 내부에서 재사용하는 **신규 wrapper 함수**로 설계한다(§Logic.md §2). 이번 산출물(Stage 1.5)은 문서만 — `.sql` 파일은 생성하지 않는다.

## Affected Files (8개, `check_kds_capacity` 문자열 검색 결과 재사용)

### 실제 함수 호출(런타임에 "does not exist" 에러 발생) — 3개

| 파일 | 호출 위치 | 비고 |
|---|---|---|
| `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` | L496 `catchmenu_kds.check_kds_capacity(p_tenant_id :=, p_store_id :=)` | 결제 확인 → KDS 릴리즈 경로(INV-001 핵심), `v_capacity_check->'data'` 형태로 결과 소비(L562, L575) |
| `sql/migrations/0099_create_realtime_pipeline_rpc.sql` | L464 동일 시그니처 호출 | `v_capacity->'data'`, `(v_capacity->'data'->>'is_overloaded')` 형태로 소비(L548, L550) |
| `sql/migrations/0106_create_delivery_platform_pipeline_rpc.sql` | L323 동일 시그니처 호출 | `(v_kds_capacity->'data'->>'is_overloaded')::boolean`로 자동거절 판단(배달 주문 KDS 과부하 체크) |

### 문서/스펙 텍스트 내 언급뿐(실제 호출 아님) — 5개

| 파일 | 성격 |
|---|---|
| `sql/migrations/0092_create_flutter_edge_function_guide_rpc.sql` | 문자열 리터럴 `'check_kds_capacity'`(RPC 목록 가이드 데이터) |
| `sql/migrations/0096_schema_final_validation.sql` | 문자열 리터럴 `'catchmenu_kds.check_kds_capacity'`(검증 목록) |
| `sql/migrations/0113_create_api_spec_docs.sql` | 주석/텍스트 `RPC: catchmenu_kds.check_kds_capacity`(API 스펙 문서 데이터) |
| `sql/migrations/0119_create_edge_function_integration.sql` | 문자열 리터럴 `'check_kds_capacity()'`(트리거 설명 텍스트) |
| `sql/migrations/0129_create_launch_readiness_package.sql` | 텍스트 `'1. KDS 용량 확인 (check_kds_capacity)'`(체크리스트 항목) |

이 5개는 함수를 실제로 호출하지 않으므로 이번 change의 실행 우선순위는 위 3개(런타임 실패 대상)에 있다 — 다만 5개도 `check_kds_capacity`라는 이름을 그대로 참조하고 있어, 함수가 실제로 생성되면 그 이름과 계속 일치한다(정정 불필요).

## Direct Dependencies

- `catchmenu_kds.evaluate_kds_capacity(p_tenant_id uuid, p_store_id uuid, p_kitchen_zone text default null)`(`0028_create_kds_capacity_commit_rpc.sql` L13) — 이번 change의 신규 wrapper가 내부에서 호출할 기존 함수. **편집하지 않는다**(지시 사항, 다른 KDS 파일 손대지 말 것).
- `catchmenu_common.build_success_response(...)` — 0098/0099/0106의 다른 응답 패턴과 동일하게, wrapper의 `{data: {...}}` 봉투 구조가 이 컨벤션을 따르는지 Stage 2에서 확인 필요(참조만, 이번 문서에서는 계약 형태만 명시).

## Required Context (§0 원칙에 따라 이 결함과 직접 관련된 문서만 선별 링크)

- `900102_ChangeContract_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md`, `900160_Overview_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System.md`, `900161_Logic_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System.md` — 이번 턴에 `check_kds_capacity`/`evaluate_kds_capacity`/`is_overloaded`/`capacity_ok`/"과부하" 키워드로 3개 문서 전체를 재확인했으나 **어디에도 언급이 없음을 확인했다.** 즉 이 결함은 이 3개 문서로부터 직접적인 근거를 얻지 못한다 — §0 원칙("연결이 확인된 문서는 살아있는 문서로 남고, 끝까지 연결 안 되는 문서는 고아 문서 후보로 드러난다")에 따라, 이 3개 문서는 **이번 결함에 한해서는 연결되지 않는 문서로 기록**한다(다른 결함에서는 여전히 연결될 수 있음 — 이번 change 하나만으로 "고아 문서"로 확정하지 않는다).
- `sql/migrations/0028_create_kds_capacity_commit_rpc.sql` — `evaluate_kds_capacity()`의 원본 정의. §Logic.md §1의 비교 근거.
- `sql/migrations/CHANGELOG.md` — 이 결함에 대한 기존 기록이 있는지 재확인한 결과 없음(신규 발견으로 취급).

## Module Domain Tags

- SQL
- DOCUMENTATION_ONLY (이번 턴 자체는 문서만)

## Risk Notes

`check_kds_capacity()`를 단순히 `evaluate_kds_capacity()`로 이름만 바꿔 호출하도록 고치면(§Logic.md §1에서 확인한 반환 계약 불일치 때문에) **조용히 틀린 결과**가 난다 — 예: `0106`의 `(v_kds_capacity->'data'->>'is_overloaded')::boolean`은 `evaluate_kds_capacity()`의 평평한 반환값(`data` 키 없음)에 대해 `NULL`을 얻고, PL/pgSQL의 `if (null) then`은 조용히 거짓으로 평가되어 **KDS 과부하 자동거절 로직이 항상 비활성 상태**가 된다. 이는 단순 호출 실패(즉시 발견됨)보다 **더 위험한 침묵 실패**다 — 단순 리네임이 정답이 아닌 이유.

## Uncertainties

- wrapper 함수의 정확한 반환 스키마(`data.is_overloaded` 외에 `cooking_count`/`hold_count` 등을 그대로 노출할지)는 `600412_Logic.md`에서 확정.
- `catchmenu_common.build_success_response()` 사용 여부는 Stage 2에서 실제 함수 시그니처 확정 시 재확인.

## Known Gaps

없음 — 이번 조사는 이 결함(§0)에 직접 관련된 파일/문서만 다루며, §0 원칙에 따라 전수 스캔을 다시 하지 않았다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `900102_ChangeContract_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` — 본문 §Required Context에서 직접 재확인한 특허/핸드오프/KDS release 기준 문서. 이번 결함에 대한 직접 키워드 연결은 없었지만, KDS release 계열 change의 상위 경계 후보로 기록한다.

### Full Rules Required

- `sql/migrations/0028_create_kds_capacity_commit_rpc.sql` — `evaluate_kds_capacity()` 원본 정의이며, `check_kds_capacity()` wrapper가 재사용할 반환 계약 비교의 직접 근거.
- `900160_Overview_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System.md` — 본문 §Required Context에서 `check_kds_capacity`/`evaluate_kds_capacity`/`is_overloaded`/`capacity_ok`/`과부하` 키워드로 전체 재확인했으나 직접 언급이 없음을 확인한 full-read 후보.
- `900161_Logic_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System.md` — 본문 §Required Context에서 같은 방식으로 전체 재확인했으나 직접 언급이 없음을 확인한 full-read 후보.
- `sql/migrations/CHANGELOG.md` — 이 결함에 대한 기존 기록이 없음을 확인한 근거.

### Domain Indexes

- 해당 없음 — 본문에 별도 KDS 도메인 Index/NavigationMap/Readme 인용은 없다.

### Excluded Rule Families

- 다른 KDS RPC 수정군 — 본문 §Direct Dependencies에서 `evaluate_kds_capacity()` 원본 정의는 편집하지 않는다고 명시했으며, 이번 change는 신규 wrapper 함수 설계로 한정한다.
- 900160/900161 직접 설계 근거화 — full-read 확인은 했으나 이번 결함에 한해서 직접 연결은 없으므로, 이 문서들을 근거로 새 설계를 확장하지 않는다.

## Snapshot Decision

이 스냅샷으로 `600412_Logic.md` 작성 진행 가능.
