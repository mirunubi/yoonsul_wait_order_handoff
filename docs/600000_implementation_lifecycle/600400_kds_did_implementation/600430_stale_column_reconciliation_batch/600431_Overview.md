# 600431_Overview.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`stale_column_reconciliation_batch`

## §0 확정된 범위 재확인 (Human 결정, 재논의 금지 — Cursor 최종 치환 표 기준)

**10개 파일, 30건 치환** (아래 건수는 Cursor가 파일당 `grep -n` 매치 라인 수 기준으로 집계한 것 — 이번 턴에 전부 재검산해 정확히 일치함을 확인했다):

- `request_memo` → `memo`: `0081`(5 — L508/L805는 파라미터명, L796/L1007/L1142은 컬럼명), `0092`(1, 예시 텍스트 — 이번 결정으로 수정 대상 전환), `0099`(1), `0102`(2), `0104`(2), `0109`(2) — 소계 13
- `case_severity` → `severity`: `0084`(6), `0092`(1), `0099`(1), `0111`(2), `0120`(2), `0133`(1) — 소계 13
- `'INVESTIGATING'` → `'UNDER_INVESTIGATION'`: `0084`(1), `0092`(1), `0099`(1), `0133`(1) — 소계 4
- 총 13+13+4 = **30건**, 고유 파일 10개(`0081`/`0084`/`0092`/`0099`/`0102`/`0104`/`0109`/`0111`/`0120`/`0133`)

**`0133`의 phantom DDL도 이번 배치에 포함해서 수정한다(Human 결정)** — 라이브에는 영향이 없지만(§4), 소스 일관성 유지 목적으로 명시적으로 포함하기로 확정됐다. 지난 초안에서 Open Question이었던 사항이 이번 지시로 해소됨.

**추가 Human 결정(2026-07-11, 제미나이 의견 반영, 재논의 금지)**: `0081`의 `place_takeout_order()` RPC 파라미터명 `p_request_memo`도 `p_memo`로 함께 변경한다(L508 파라미터 선언, L805 VALUES 전달) — 컬럼명뿐 아니라 파라미터명까지 일치시키는 것으로 범위가 명확화됐다. 이에 따라 `0092` L380의 Dart 클라이언트 예시 코드(`'p_request_memo': requestMemo,`)도 실제 함수 시그니처와 어긋나지 않도록 함께 수정한다 — 이전 판단(§1의 "수정 안 해도 됨")을 뒤집는 것이다. 치환 대상 라인 수 자체는 늘지 않는다(L508/L805는 원래부터 `0081`의 5건 안에 포함돼 있었으나, 종전 §1 표에는 3곳만 itemize돼 있었음 — 이번에 바로잡음).

**검증 사실과의 차이 — 투명 공개**: 이번 지시 문구는 "place_takeout_order/track_takeout_order 파라미터명 p_request_memo"라고 표현했으나, 이번 턴에 `0081` 전체를 재검색한 결과 `p_request_memo`(파라미터명, `p_` 접두사 포함)는 L508/L805 두 곳뿐이며 둘 다 `place_takeout_order()`(L500-978) 안에 있다. `track_takeout_order()`(L979-1148)는 `request_memo`를 **컬럼**으로만 읽을 뿐(L1007, L1142) `p_request_memo`라는 파라미터 자체를 갖고 있지 않다 — 이번 턴에 직접 확인한 이 함수의 파라미터는 `p_tenant_id`/`p_store_id`/`p_order_id`/`p_locale` 4개뿐이다. 따라서 "파라미터명 변경"은 `place_takeout_order()` 한 곳에만 해당하며, `track_takeout_order()`의 L1007/L1142는 원래부터 §0의 컬럼명 치환 대상이었을 뿐 파라미터명 변경과는 무관하다.

**A안 확정 반영(Human 결정, 2026-07-11, 재논의 금지) — DB 컬럼명(`memo`)과 시스템 전체 용어 통일**: `0081`의 `place_takeout_order()` 파라미터명(`p_request_memo`→`p_memo`, 위 문단에서 이미 확정)에 더해, `track_takeout_order()`의 **응답 JSON 출력 키**(L1142, `'request_memo', v_order.request_memo` → `'memo', v_order.memo`)도 이번 결정으로 함께 변경한다 — 종전에는 "응답 계약 보존을 위해 출력 키만 유지"로 판단했던 것을 뒤집는 것이다(`600432_Logic.md` §2.1에서 파라미터 계약(요청 방향)과 응답 키(응답 방향)를 구분해 판단 근거를 기록함). 이에 따라 `0092` L380의 Dart 예시는 파라미터 키(`p_memo`)만 대상이며 응답 키와는 무관 — 지난 턴에 이미 반영 완료.

이번 산출물(Stage 1.5)은 문서만 — `.sql` 파일은 이번 턴에 생성/수정하지 않는다.

## 1. `request_memo` → `memo` — 파일별 정확한 위치 (Cursor 스캔 결과 재확인)

| 파일 | 라인 | 함수 | 성격 |
|---|---|---|---|
| `0081_create_customer_app_rpc.sql` | L508(파라미터 선언), L805(VALUES 전달), L796(INSERT 컬럼) — 이상 3곳 `place_takeout_order()`; L1007(SELECT 컬럼), L1142(SELECT 컬럼 + 응답 JSON 출력 키) — 이상 2곳 `track_takeout_order()` | `place_takeout_order()`(L500-978), `track_takeout_order()`(L979-1148) — 이번 턴 함수 경계 직접 확인 | **실제 SQL, 실행에 영향 있음** — `catchmenu_pos.orders`에 실제로 없는 컬럼. L508/L805는 파라미터명(`p_request_memo`→`p_memo`, Human 결정), L796/L1007은 컬럼명만, **L1142는 컬럼명과 응답 JSON 출력 키를 모두 변경**(A안, Human 결정 — 아래 A안 단락 참고) |
| `0092_create_flutter_edge_function_guide_rpc.sql` | L380 | (Dart 클라이언트 예시 코드 블록 내부) | **문서/가이드 텍스트, 이번 결정으로 수정 대상 전환** — `'p_request_memo': requestMemo`는 SQL 컬럼 참조가 아니라 RPC 파라미터명 예시이지만, `0081`의 실제 파라미터명이 `p_memo`로 바뀌므로 예시도 `'p_memo': requestMemo`로 동기화해야 함(Dart 로컬 변수명 `requestMemo` 자체는 무관하여 유지). 실행에는 영향 없음(문자열 리터럴) |
| `0099_create_realtime_pipeline_rpc.sql` | L448 | `get_kds_realtime_state()` | **실제 SQL** — 이전 워크패킷(`600420`) Stage 5에서 직접 호출 시 `ERROR: column o.request_memo does not exist`로 실증 확인된 바로 그 결함(`600423_Audit.md` Open Item (e)) |
| `0102_create_okpos_integration_pipeline_rpc.sql` | L667(SELECT), L728(`'memo', coalesce(v_order.request_memo, '')` — 출력 키는 이미 `'memo'`로 올바르나 소스 컬럼 참조가 stale) | OKPOS 연동 파이프라인 | **실제 SQL** |
| `0104_create_toss_pos_pipeline_rpc.sql` | L601(SELECT), L661 | Toss POS 파이프라인 | **실제 SQL** |
| `0109_create_network_handoff_fallback_rpc.sql` | L860(INSERT 컬럼), L878(오프라인 큐 payload에서 `->>'request_memo'` 추출) | 네트워크 장애 폴백/오프라인 큐 동기화 | **실제 SQL** — `catchmenu_pos.orders`에 직접 INSERT |

## 2. `case_severity` → `severity` — 파일별 정확한 위치

| 파일 | 라인 | 함수 | 성격 |
|---|---|---|---|
| `0084_create_reconciliation_advanced_rpc.sql` | L547, L993(INSERT 컬럼), L1182, L1189, L1214, L1285(SELECT/jsonb/CASE) | 대사(reconciliation) 관련 여러 함수 | **실제 SQL** |
| `0092_create_flutter_edge_function_guide_rpc.sql` | L1193 | 헬스체크 함수(L1075에서 시작하는 `create or replace function` 본문 내부, `declare...begin...end` 블록) | **실제 SQL** — 같은 파일이라도 `request_memo`(L380, 텍스트)와 달리 이 부분은 실행 대상 함수 본문 |
| `0099_create_realtime_pipeline_rpc.sql` | L1005 | `get_staff_alert_feed()` | **실제 SQL** — 이번 턴 직접 재확인. `600423_Audit.md` Open Item (f) |
| `0111_create_franchise_admin_rpc.sql` | L1119, L1124(jsonb 출력 + ORDER BY) | 프랜차이즈 관리자 RPC | **실제 SQL** |
| `0120_create_reconciliation_pipeline.sql` | L815, L820(동일 패턴) | 대사 파이프라인 | **실제 SQL** |
| `0133_create_final_validation_package.sql` | L281 | `reconciliation_cases` 테이블 정의 시도 | **Phantom DDL — 해결됨(포함 결정, `600432_Logic.md` §5 #1 참고), 실행에 영향 없음** |

## 3. `'INVESTIGATING'` → `'UNDER_INVESTIGATION'` — 파일별 정확한 위치

| 파일 | 라인 | 성격 |
|---|---|---|
| `0084_create_reconciliation_advanced_rpc.sql` | L1202, `case_status in ('OPEN', 'INVESTIGATING')` | **실제 SQL(WHERE 필터)** — INSERT/UPDATE 아님, 읽기 조건이라 하드 에러는 안 나지만 `UNDER_INVESTIGATION` 상태 케이스를 조용히 누락시킴 |
| `0092_create_flutter_edge_function_guide_rpc.sql` | L1191, 헬스체크 함수 내부 동일 패턴 | **실제 SQL(WHERE 필터)**, 동일 성격 |
| `0099_create_realtime_pipeline_rpc.sql` | L1004 | **실제 SQL(WHERE 필터)** — 이번 턴 직접 재확인, `600423_Audit.md` Open Item (f)의 일부 |
| `0133_create_final_validation_package.sql` | L290, `chk_case_status`의 phantom CHECK 제약 내부 | **Phantom DDL** — 해결됨(포함 결정, `600432_Logic.md` §5 #1 참고), 실행에 영향 없음 |

## 4. `0133`의 Phantom DDL — 포함 결정 (Human 결정, 재논의 금지)

`0133`(L273-292)의 `create table if not exists catchmenu_payment.reconciliation_cases (...)`는 **`0015_create_payment_reconciliation.sql`(L10-)이 이미 이 테이블을 먼저 생성해뒀기 때문에 실제로는 아무 것도 하지 않는 no-op**이다(`IF NOT EXISTS`가 조건을 만족시키지 못해 스킵됨). `0133`의 컬럼 정의(`case_severity`, `chk_case_status`의 `'INVESTIGATING'` 포함 4개 허용값)는 **라이브 스키마에 단 한 번도 반영된 적이 없다** — 이번 턴에 라이브 `\d`로 재확인한 실제 컬럼은 `0015`가 정의한 `severity`이며, 실제 `chk_recon_case_status` 제약은 `0015` 계열이 정의한 8개 값(`OPEN`, `UNDER_INVESTIGATION`, `PENDING_PROVIDER`, `PENDING_HQ`, `RESOLVED`, `WRITTEN_OFF`, `ESCALATED`, `CLOSED`)이다 — `0133`이 상정한 4개 값(`OPEN`/`INVESTIGATING`/`RESOLVED`/`WAIVED`)과 전혀 다르다.

**결정됨**: 라이브 영향은 없지만(no-op이므로), 소스 코드 일관성 유지를 위해 `0133`의 `case_severity`/`'INVESTIGATING'`도 이번 배치에서 함께 치환한다(`600432_Logic.md` §2.2/§2.3).

## 5. 범위 밖(이번엔 안 건드림) — 추가 발견된 stale 참조

이번 조사 중 §0의 3개 치환 대상과는 별개로, `0084`/`0111`/`0120`에서 **다른** stale 컬럼 참조를 추가로 발견했다. Human 결정에 따라 **이번 배치에서는 손대지 않고 기록만** 한다(`600432_Logic.md` Open Items로 이월, 별도 후속 워크패킷 후보):

- `gap_amount`(`0111` L1120/L1125, `0120` L816/L821에서 `rc.gap_amount`로 참조) — 실제 컬럼은 `0015`가 정의한 `amount_diff`. 이번 턴 `grep`으로 실제 SQL(jsonb 출력 + `ORDER BY`) 참조임을 확인.
- `layer_number`, `amount_difference`, `case_description`(`0084` L993 INSERT 컬럼 목록) — `0015`의 실제 컬럼은 각각 `reconciliation_layer`, `amount_diff`이며, `case_description`에 대응하는 컬럼은 `0015`에 존재하지 않는다(추가 확인 필요 사항으로 이월).

**`0121_create_security_pipeline.sql`의 `security_threats.threat_status`에 있는 `'INVESTIGATING'`은 이번 범위가 아니다.** 이번 턴에 직접 확인한 결과 `catchmenu_common.security_threats`는 `reconciliation_cases`와 **완전히 별개의 테이블**이며(L213에서 독립적으로 `create table`), 그 테이블 자체의 `chk_threat_status` 제약(L285-287)이 `'INVESTIGATING'`을 정상적으로 허용하고 있다 — 즉 **이건 버그가 아니라 그 테이블의 정상적인 자체 값일 가능성이 높다.** 다만 이번 턴에는 "다른 테이블이라 범위 밖"이라는 사실만 확인했을 뿐, 정상 값인지 100% 확정 검증하지는 않았다(지시대로 손대지 않음).

## Module Domain Tags

- SQL
- DOCUMENTATION_ONLY

## Snapshot Decision

이 스냅샷으로 `600432_Logic.md` 작성 진행 가능.
