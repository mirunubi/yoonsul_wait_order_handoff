# 600121_Overview.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-11

## Change ID

`guest_customer_bootstrap_rpc`

## Change Summary

신규 헬퍼 함수 `catchmenu_store.get_or_create_guest_customer(p_tenant_id uuid, p_phone_hash text default null) returns uuid`를 만들어, `0115`(`register_waiting`)와 `0116`(`bootstrap_customer_app_v2`)가 게스트 호출 시(`p_customer_id is null`) 이 헬퍼를 통해 실제 `is_guest=true` `customers` row를 얻도록 최소 패치한다. `600112_Logic.md` §3.1의 예시 로직(개념 설명용, "illustrative, not the final migration"이라고 스스로 명시함)을 실제 구현 스펙으로 격상하는 작업이다 — `600112_Logic.md` 자체는 참조만 하고 편집하지 않는다.

## Affected Files (이번 턴 직접 재확인)

| 파일 | 역할 | 확인 방법 |
|---|---|---|
| `sql/migrations/0149_...sql` (신규, 번호 미정) | `get_or_create_guest_customer()` 헬퍼 정의 | `migration_history`에서 `0148`이 최신 적용분임을 이번 턴 재확인 (`SELECT filename FROM catchmenu_meta.migration_history ORDER BY filename DESC LIMIT 3` → `0148`, `0147`, `0146`) — 다음 빈 번호는 `0149`, Stage 3 승인 시점 재확인 필요 |
| `sql/migrations/0115_create_waiting_pipeline_rpc.sql` | `register_waiting()` 최소 패치 — `p_customer_id is null`이면 헬퍼 호출 | 이번 턴 재확인: `p_customer_id` INSERT 지점이 L294(컬럼 목록)/L304(값) — `600110`의 재검증(600111/600116)과 동일 라인 |
| `sql/migrations/0116_create_customer_app_bootstrap_rpc.sql` | `bootstrap_customer_app_v2()` 최소 패치 — 동일 패턴 | 이번 턴 재확인: `if p_customer_id is not null then` 게이트가 L185. 이 게이트 자체는 그대로 두고, 그 앞단(게이트 진입 전)에 헬퍼 호출을 추가하는 형태가 됨 (§ 상세는 `600122_Logic.md`) |

**0115/0116이 `600110`(이미 Audited)의 영향 파일 목록과 겹친다는 점 명시**: `600111_Overview.md`의 Forbidden Files/영향 파일 표에서도 이 두 파일이 이미 REFERENCE ONLY로 다뤄졌었다. 이번 `600120`은 그 두 파일에 대한 **실제 편집 권한**을 갖는 첫 change다 — Human이 이 범위 포함을 명시적으로 승인했다(작업 지시 §0). `600110`의 산출물(`600111`~`600117`)은 이번 턴에도 편집하지 않는다.

## Direct Dependencies

`catchmenu_store.customers`(0058, `register_customer`의 `customer_code` 생성 패턴 재사용 대상), `catchmenu_pos.order_sessions`(0148에서 이미 `customer_id`/`phone_hash` 컬럼 확보됨 — 이 change는 그 컬럼을 실제로 채우는 헬퍼를 만드는 것).

## Indirect Dependencies

없음 — 이 change는 SQL 함수 1개 신설 + 기존 함수 2개의 최소 패치로 범위가 명확히 제한된다.

## Database Tables

`catchmenu_store.customers` (INSERT/UPSERT 대상, 스키마 변경 없음 — `0148`에서 이미 `is_guest` 컬럼 추가 완료). `catchmenu_pos.order_sessions`(FK 대상, 스키마 변경 없음).

## Migrations

신규 1개(`0149` 후보, Stage 3 재확인). 기존 마이그레이션 수정 없음 — `0115`/`0116`은 **새 forward migration의 `CREATE OR REPLACE FUNCTION`으로 패치**하는 것이지, 기존 `0115_*.sql`/`0116_*.sql` 파일 자체를 편집하는 게 아니다 (이 프로젝트 관례상 이미 적용된 migration 파일은 사후 편집하지 않고 새 번호의 forward migration으로 `CREATE OR REPLACE`하는 방식 — `CHANGELOG.md`의 "Function signature collision" 항목에서 `0116`이 `0081`의 `get_customer_home`을 이 방식으로 대체했던 선례와 동일).

## RLS Policies

변경 없음. 헬퍼 함수는 `security definer`로 RLS를 우회하므로, RLS 정책 자체를 건드리지 않는 대신 함수 내부 `tenant_id` 검증이 필요한지가 `600122_Logic.md`의 Open Question이다.

## Tests Found / Missing

기존 `catchmenu_common.run_integration_test()` 프레임워크 존재. 이 헬퍼 전용 테스트, 동시 요청(같은 phone_hash) 시 upsert 경합 테스트는 전무 — 신규 작성 필요 (TestPlan은 이번 산출물 범위 밖, 후속 Stage 2 작업).

## Provider / POS / PG / VAN / Bank / Payout Impact

없음.

## Audit Ledger / Evidence Impact

헬퍼 자체는 게스트 customers row 생성/조회만 하며 `catchmenu_ledger.events` 기록 여부는 이번 스펙에 포함하지 않음 (600110의 Open Question들과 마찬가지로 별도 결정 필요 사항으로만 남김, 이번 change의 확정 범위 아님).

## Related Documentation References

`600100_Readme_Customer_Identity_And_Guest_Promotion.md`, `600110_.../600112_Logic.md` §3.1(참조만, 편집 안 함), `600110_.../600117_Audit.md`(ACCEPT 상태, 이 change가 그 위에 이어짐), `sql/migrations/0058_create_membership_rpc.sql`의 `register_customer()`(L276-, `customer_code` 생성 로직 L325-).

## Related SOP / Policy / Matrix / Checklist References

`005015_Policy_Customer_Account_Guest_Merge...md` — 이번 change도 편집하지 않는다 (지시 사항).

## Module Domain Tags

- DB
- DOCUMENTATION_ONLY (이번 턴 자체는 문서만)

## Risk Notes

`0115`/`0116` 패치는 "최소화" 원칙(`p_customer_id IS NULL이면 헬퍼 호출` 한 줄 수준)이 지켜지지 않으면 이미 Audited된 `600110`의 검증 범위를 벗어난 회귀 위험이 생긴다 — `600122_Logic.md`의 diff가 실제로 최소한인지가 Stage 2 검증의 핵심.

## Uncertainties

- ON CONFLICT 전략(DO NOTHING vs DO UPDATE) — `600122_Logic.md`에서 확정
- 헬퍼 GRANT 범위 — Open Question, `600122_Logic.md`에서 권장안 제시
- security definer 내부 tenant_id 검증 필요 여부 — Open Question

## Known Gaps

없음 — 이번 조사는 `600110`/`600112` 대비 새로 추가되는 파일/함수만 다루므로 이미 검증된 배경 사실을 재조사하지 않았다(작업 지시 §0 "재논의 금지" 준수).

## Snapshot Decision

이 스냅샷으로 `600122_Logic.md` 작성 진행 가능.
