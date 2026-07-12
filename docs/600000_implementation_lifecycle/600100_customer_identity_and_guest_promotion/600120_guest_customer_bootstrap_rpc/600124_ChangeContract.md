# 600124_ChangeContract.md

Status: Draft — requires Stage 3 Human approval before binding
Lifecycle: ChangeContract
Stage: 2 (Claude role — compressed with Stage 1.5 this batch, see `600121_Overview.md` 저자 표기 원칙)
Owner: TBD
Last Updated: 2026-07-11
CHANGE_ID: `guest_customer_bootstrap_rpc`

## 1. Allowed Files

| 파일 | 동작 |
|---|---|
| `sql/migrations/0149_<name>.sql` (정확한 번호/이름은 Stage 3 승인 시점 재확인 — `0148`이 현재 최신 적용분임을 이번 세션에서 재확인 완료) | CREATE — `600122_Logic.md` §2의 `get_or_create_guest_customer()` DDL |
| `sql/migrations/0115_create_waiting_pipeline_rpc.sql` | **PATCH** (신규 forward migration의 `CREATE OR REPLACE FUNCTION`으로 — 기존 파일 자체를 직접 수정하지 않음) — `600122_Logic.md` §3.1의 정확히 5줄 삽입만 |
| `sql/migrations/0116_create_customer_app_bootstrap_rpc.sql` | **PATCH** (동일 방식) — `600122_Logic.md` §3.2의 정확히 5줄 삽입만 |
| `sql/migrations/CHANGELOG.md` | APPEND-ONLY — 이번 migration 적용 기록 |
| `docs/600000_implementation_lifecycle/600100_customer_identity_and_guest_promotion/600101_ChangeHistory.md` | UPDATE — Stage 6 ACCEPT 시 항목 추가, `600113_TestPlan.md` §4 네거티브 컨트롤이 이번 patch로 "의도된 개선"으로 뒤집힌다는 점 명시 (`600123_TestPlan.md` §6 참고) |
| `docs/600000_implementation_lifecycle/600100_customer_identity_and_guest_promotion/600102_NavigationMap.md` | UPDATE — Stage 3/7 최소 1회씩 |

## 2. Forbidden Files (명시적 범위 제외)

- `docs/600000_implementation_lifecycle/600100_customer_identity_and_guest_promotion/600110_order_sessions_customer_id_fk_and_guest_promotion/600111_Overview.md` ~ `600117_Audit.md` (전부) — **이미 Audited(ACCEPT)된 산출물, 이번 change에서도 편집 금지.** 참조만 한다.
- `sql/migrations/0081_create_customer_app_rpc.sql`, `0097_create_auth_login_pipeline_rpc.sql`, `0148_add_order_sessions_customer_id_and_guest_flag.sql` — 편집 금지, 참조만
- `sql/migrations/0082_create_saas_billing_rpc.sql`, `0083_create_push_notification_rpc.sql` — REFERENCE ONLY (600110에서 이미 확립된 분류 유지)
- 고객 삭제/탈퇴 보관 로직 — 별도 WorkPackage
- `docs/.../005015_Policy_Customer_Account_Guest_Merge_Identity_Continuity_Membership_Ready_And_Runtime_Authority_Boundary.md` — 편집 금지
- `docs/600000_implementation_lifecycle/604000_workpackets/604500_order_sessions_customer_id_fk_and_guest_promotion/` — 이동/삭제/quarantine 금지
- `.dart`/Flutter 클라이언트 코드 전체 — `600200_flutter_waiting_feature_implementation/` 쪽 범위, 이 change는 SQL만 (`600203_DecisionLog.md` Decision 1 참고: `600210`은 이 change의 RPC 시그니처 확정 후 별도 작업)
- 위 목록에 없는 그 외 모든 `sql/migrations/*.sql`

## 3. Open Items

1. **tenant_id 내부 검증** (`600122_Logic.md` §5) — `security definer` 함수 내부에서 `p_tenant_id`가 호출 컨텍스트와 일치하는지 검증할지 미확정. `current_tenant_id()`(0022/0035/0049에 이미 존재 확인됨)를 활용할지가 후보.
2. **GRANT 범위** (`600122_Logic.md` §6) — **REVOKE 권장** (직접 노출 최소화, `0115`/`0116`을 통한 간접 호출만 허용). 최종 확정은 Stage 3.
3. **0058 컬럼 대조** (`600122_Logic.md` §2) — 이미 이번 세션에서 확인 완료(NOT NULL-무기본값 컬럼은 `tenant_id`/`customer_code`뿐, 둘 다 채워짐) — Open이 아니라 CLOSED로 표기.

## 4. Known Constraint — `is_guest` UPDATE 절 제외 확인됨 (버그 아님)

이번 턴 작업 시작 전 필수 확인 사항: `600122_Logic.md` §2의 `on conflict ... do update set updated_at = now()`에 `is_guest`가 포함되어 있지 않음을 재확인했다 (원본 라인 그대로). 회원가입 완료(`is_guest=false`)한 고객이 같은 `phone_hash`로 헬퍼를 다시 호출해도 `is_guest`가 `true`로 되돌아가지 않는다 — `600123_TestPlan.md` §2.3이 이 사실을 실행 가능한 쿼리로 검증한다.

## 5. Human Boundary Approval (Pending — Stage 3, 미승인)

☑ Approved — proceed to Stage 4 (Codex implementation within the file boundary above)
☐ Approved with modifications — see notes: _______________
☐ Not approved — blocked pending: _______________

**`000701` §4 Core Rule 준수**: 이 CHANGE_ID에 대해 `sql/migrations/`에 생성된 파일이 현재 없음 (이번 턴 `find`로 재확인, `0149` 미존재). 이 섹션 서명 전까지 생성하지 않는다.
