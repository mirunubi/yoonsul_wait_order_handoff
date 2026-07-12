# 600111_Overview.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-11

**저자 표기 원칙 (§3 준수 사항 명시)**: 이 문서와 `600112_Logic.md`는 정상적인 Stage 1.5(Claude Code) 산출물이다. `600113_TestPlan.md`와 `600114_ChangeContract.md`는 정상적으로는 Stage 2(Claude)가 별도로 작성해야 하나, 이번 배치에서는 편의상 동일 행위자가 순차 수행했다 — 이는 저자 분리 원칙 위반이 아니라, 압축 수행했다는 사실 자체를 투명하게 기록해 향후 Stage 2 몫의 독립 재검증이 가능하도록 남기는 것이다. 각 파일 헤더의 "Stage" 필드로 원래 소유자를 명시한다.

## Change ID

`order_sessions_customer_id_fk_and_guest_promotion`

## Change Summary

`catchmenu_pos.order_sessions`에 `customer_id`(FK→`customers.id`)와 `phone_hash` 컬럼을, `catchmenu_store.customers`에 `is_guest` 컬럼을 추가한다. 게스트 주문/대기 시 `(tenant_id, phone_hash)` 기준으로 `customers`에 `is_guest=true`인 실제 row를 upsert하고, `order_sessions.customer_id`가 그 row를 참조하게 한다. 회원가입은 같은 row를 `is_guest=false`로 in-place UPDATE — merge가 아니다.

## §0 선행 확인 재검증 결과 (Cursor 스캔 원문 사용 지시에 대한 필수 정정)

지시받은 대로 "Cursor의 Stage 1 스캔 보고 원문을 그대로 입력으로 사용"하려 시도했으나, **이 보고서의 실재를 확인할 수 없었다.** 전체 리포에서 `CursorScan` 명명 패턴의 파일을 검색했고 (`find . -iname "*CursorScan*"`) 0건. 이 대화 세션 내에서도 그런 보고서가 첨부되거나 전달된 적이 없다. 동일하게, "첨부/전달된 `0148_add_order_sessions_customer_id_and_guest_flag.sql`과 `ChangeContract.md`(초안)"도 리포 전체에서 검색했으나 (`find . -iname "0148*"`) 존재하지 않는다.

이 항목들을 액면 그대로 신뢰하지 않고(§25/§26), 대신 **이 에이전트가 직접 이전 세션 턴에서 수행한, 도구로 검증된 조사 결과**(`docs/implementation_evidence/order_sessions_customer_id_fk_and_guest_promotion/DesignPack.md` — 단, `600100_Readme_Customer_Identity_And_Guest_Promotion.md`가 이 파일을 "Out of Scope: authoritative input으로 취급하지 말 것"으로 명시했으므로, 내용만 재활용하고 그 문서 자체를 권위 있는 소스로 인용하지는 않는다)를 실질적 근거로 삼아 이 문서를 작성한다. 아래 "영향 파일 목록"의 각 항목은 이번 턴에 다시 열어서 재확인했다.

## §15.1 격차 정정 (별도 발견 사항)

이번 조사 중 `docs/600000_implementation_lifecycle/`이 실제로는 **완전히 격리되지 않고 살아있는 별도 워크패킷 체계**임을 확인했다 (`604000_workpackets/`, `601000_olm_model/` 등 다수 서브폴더, 다수 활성 workpacket 존재, `990000_legacy_quarantine/600000_Index_Implementation_Lifecycle.md`는 부분 격리 기록일 뿐 전체 격리를 의미하지 않음). 이는 `000701` §15.1이 "600000_implementation_lifecycle 밴드가 990000으로 격리됨"이라고 서술한 것과 부분적으로 모순된다. 이 문서 작성 시점에는 이 모순을 해소하지 않고 Open 사항으로만 기록한다 — `600103_DecisionLog.md`에도 별도로 남긴다.

## Candidate Affected Files (재확인 완료)

| 파일 | 역할 | 확인 방법 |
|---|---|---|
| `sql/migrations/0012_create_pos_order_sessions.sql` | `order_sessions` 원본 정의 — `customer_id`/`phone_hash` 없음, `customer_token text`만 존재 | 이번 턴 직접 재확인 |
| `sql/migrations/0058_create_membership_rpc.sql` | `customers` 원본 정의 — `is_guest` 없음 | 이전 턴 grep 원문 확인 완료 |
| `sql/migrations/0081_create_customer_app_rpc.sql` | `order_sessions.customer_id` 의존 부분을 스스로 DEFERRED 처리 (정확한 판단) | 전체 읽음 |
| `sql/migrations/0082_create_saas_billing_rpc.sql` | L906-908 `os.customer_id` 활성 참조 — **REFERENCE ONLY, 수정 대상 아님** | 이번 턴 `sed`로 직접 재확인: `left join catchmenu_store.customers c on c.id = os.customer_id` 확인됨 |
| `sql/migrations/0083_create_push_notification_rpc.sql` | L690 부근 `os.customer_id` 활성 참조 — **REFERENCE ONLY, 수정 대상 아님** | 이번 턴 `sed`로 직접 재확인: `select o.id, ..., os.customer_id into v_order from ... join catchmenu_pos.order_sessions os` 확인됨 |
| `sql/migrations/0097_create_auth_login_pipeline_rpc.sql` | 전화+OTP `customer_login()`, `auth_sessions` — 이번 변경과 별개, 영향 없음 | 이전 턴 전체 읽음 |
| `sql/migrations/0115_create_waiting_pipeline_rpc.sql` | `register_waiting()`이 존재하지 않는 `order_sessions.customer_id`/`phone_hash`에 INSERT — 이번 migration으로 정상화됨 | 이전 턴 라인별 재확인 |
| `sql/migrations/0116_create_customer_app_bootstrap_rpc.sql` | 5개 함수가 `order_sessions.customer_id`/`p_customer_id` 참조, `bootstrap_customer_app_v2()`의 `if p_customer_id is not null` 게이트가 caller-contract 이슈 있음 | 이전 턴 전체 읽음 |
| `sql/migrations/0148_...sql` (신규, 미생성) | 이번 변경의 실제 DDL — Stage 3 승인 전까지 생성 금지 | N/A |

로컬 DB 상태 (이전 턴 직접 조회): `order_sessions.customer_id`가 out-of-band(비정상 경로, migration_history에 기록 없음)로 이미 부분 적용되어 있음 — `ON DELETE NO ACTION`, `is_guest`는 미적용. `600112_Logic.md` §4에서 상세히 다룬다.

## Direct Dependencies

`catchmenu_pos.order_sessions` → `catchmenu_store.customers` (신규 FK). `customer_app_sessions.customer_id`(0081, 기존 FK, 영향 없음)와는 별개 테이블.

## Indirect Dependencies

`0116`의 `bootstrap_customer_app_v2()` 등 5개 함수 — SQL 자체는 무손상이나 caller-contract(클라이언트가 게스트에게도 `customer_id`를 넘겨야 함) 변경 필요. Flutter/webapp 클라이언트 코드는 이 change의 파일 범위 밖.

## Database Tables

`catchmenu_pos.order_sessions` (ALTER), `catchmenu_store.customers` (ALTER). 읽기 전용 참조: `catchmenu_store.customer_app_sessions`, `catchmenu_common.auth_sessions`.

## Migrations

신규 1개 (`0148_...sql`, 번호는 Stage 3 승인 시점에 재확인). 기존 마이그레이션 수정 없음 (0081/0082/0083/0097/0115/0116 전부 편집 금지, §4 참고).

## RLS Policies

이 변경은 RLS 정책 자체를 수정하지 않는다. 두 ALTER 대상 테이블 모두 이미 RLS가 적용된 상태이며, 신규 컬럼은 기존 정책의 `tenant_id` 기반 격리를 그대로 상속받는다 (컬럼 추가는 정책 재정의를 요구하지 않음).

## Tests Found

`sql/migrations/0073_final_verification.sql`, `catchmenu_common.run_integration_test()` — 기존 통합 테스트 프레임워크. 이번 변경 전용 테스트는 없음 (신규 작성 필요, `600113_TestPlan.md` 참고).

## Tests Missing

`order_sessions.customer_id`/`phone_hash`/`customers.is_guest`에 대한 전용 테스트 전무. 게스트 승격(같은 row in-place UPDATE) 시나리오 테스트 전무.

## Provider / POS / PG / VAN / Bank / Payout Impact

없음 — 이 변경은 결제 프로바이더/PG/정산 로직을 건드리지 않는다.

## Audit Ledger / Evidence Impact

`catchmenu_ledger.events`에 게스트 row 생성/승격 이벤트를 남길지는 `600112_Logic.md`의 Open Question이 아니라 DDL 자체 범위 밖 — 별도 WorkPackage 후보로만 언급.

## Monitoring / Alert Impact

없음.

## Related Documentation References

`docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md` §25, §28, §31, §33. `sql/migrations/CHANGELOG.md` 2026-07-11 항목 (로컬+클라우드 information_schema 조회, `supabase db diff --linked` 재확인 완료 기록).

## Related SOP / Policy / Matrix / Checklist References

`docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005015_Policy_Customer_Account_Guest_Merge_Identity_Continuity_Membership_Ready_And_Runtime_Authority_Boundary.md` — 충돌 지점 있음, `600112_Logic.md` Open Question 참고. **이 파일 자체는 편집 대상 아님.**

## Master / Domain Index References

`docs/000005_Index_Document_Number.md`, `docs/000007_Map_Full_Directory.md` — `600110_...` 폴더가 이미 "folder only" 상태로 등록되어 있음(재확인 완료, 이번 턴 `git diff`로 직접 검증). 실제 문서 생성 후 보완 필요 (§부수 작업 참고, 전면 재갱신 아님).

## Module Domain Tags

- DB
- DOCUMENTATION_ONLY (이번 턴 자체는 문서만 생성, 실제 SQL 미실행)

## Required Context Snapshot Candidates

### Master Anchor

- `docs/000005_Index_Document_Number.md`

### Rule Summaries

- `docs/000001_Md_Rules.md` §5.4.1-§5.4.3 (DocumentType/파일명 규칙, 2026-07-11 개정분 포함)
- `sql/migrations/CHANGELOG.md` 2026-07-11 항목 (DB 컬럼 부재 재확인 결과)

### Full Rules Required

- `docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md` §3 (Stage 소유자 구분), §25 (Reality-Verification), §28 (TestPlan 실행가능성), §30 (ChangeHistory), §31 (Tier), §32 (NavigationMap)

### Domain Indexes

- `docs/600000_implementation_lifecycle/990000_legacy_quarantine/600000_Index_Implementation_Lifecycle.md` (부분 격리 상태 — 위 §15.1 격차 정정 참고)
- `docs/600000_implementation_lifecycle/600100_customer_identity_and_guest_promotion/600100_Readme_Customer_Identity_And_Guest_Promotion.md`

### Excluded Rule Families

| Excluded Rule Family | Reason |
|---|---|
| Payment provider/PG 통합 규칙 | 이 변경은 결제 로직 자체를 건드리지 않음 |
| RLS 정책 상세 규칙 | 컬럼 추가만, 정책 재정의 없음 |
| Flutter/Dart 클라이언트 코딩 규칙 | 이 change의 파일 범위 밖 (§4 참고) |

## Context Budget Decision

NORMAL

## Risk Notes

로컬 DB에 이미 out-of-band로 `order_sessions.customer_id`가 부분 적용돼 있어(§0/§15.1 참고, 상세는 `600112_Logic.md` §4), 정식 `0148` 작성 시 `ADD COLUMN IF NOT EXISTS`로 안전하게 처리해야 하며 `ON DELETE` 정책(현재 실제: NO ACTION, 승인된 설계: SET NULL)의 차이를 반드시 재조정해야 한다.

## Uncertainties

- `600000_implementation_lifecycle`의 실제 격리 범위 (§15.1 격차, 위 참고)
- 604500(잔존 워크패킷)과 600110(신규)의 CHANGE_ID 중복 처리 방향 — Open, 이번 작업 대상 아님

## Known Gaps

- Cursor Stage 1 스캔 보고서 실재 확인 불가
- `0148_...sql` 및 전달됐다는 ChangeContract 초안 실재 확인 불가

## Cursor Scan Corrections

**Cursor의 원본 Stage 1 스캔 보고서를 찾을 수 없어 대조/정정할 대상 자체가 없다.** 대신 이 문서 전체는 이 에이전트가 이전 세션 턴들에서 직접 도구로 검증한 조사(파일 읽기, DB 직접 조회, `sql/migrations/CHANGELOG.md` 대조)를 기반으로 처음부터 작성되었다. 이는 §25/§26이 요구하는 "액면 신뢰 금지" 원칙을 오히려 더 엄격하게 적용한 결과다 — 신뢰할 원본이 없으므로 전부 직접 재확인했다.

## Files Claude Code Must Not Modify

`sql/migrations/0081_*.sql`, `0082_*.sql`, `0083_*.sql`, `0097_*.sql`, `0115_*.sql`, `0116_*.sql` (전부 REFERENCE ONLY), `docs/.../005015_Policy_Customer_Account_Guest_Merge...md`, `docs/600000_implementation_lifecycle/604000_workpackets/604500_order_sessions_customer_id_fk_and_guest_promotion/` (이동/삭제 금지, Open 기록만).

## Snapshot Decision

이 스냅샷으로 Stage 2(TestPlan/ChangeContract, 이번 배치에서는 같은 행위자가 이어서 압축 수행)로 진행 가능. Stage 3 Human 승인 전까지 실제 migration 파일 생성 금지.
