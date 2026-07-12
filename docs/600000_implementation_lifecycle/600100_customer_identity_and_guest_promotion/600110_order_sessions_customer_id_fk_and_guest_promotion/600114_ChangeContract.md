# 600114_ChangeContract.md

Status: Draft — requires Stage 3 Human approval before binding
Lifecycle: ChangeContract
Stage: 2 (Claude role — compressed with Stage 1.5 this batch, see `600111_Overview.md` 저자 표기 원칙)
Owner: TBD
Last Updated: 2026-07-11
CHANGE_ID: `order_sessions_customer_id_fk_and_guest_promotion`

## 1. Allowed Files

| 파일 | 동작 |
|---|---|
| `sql/migrations/0148_<name>.sql` (정확한 번호/이름은 Stage 3 승인 시점 재확인) | CREATE — `600112_Logic.md` §2의 DDL |
| `sql/migrations/CHANGELOG.md` | APPEND-ONLY — 이번 migration 적용 기록 (append-only 관례 준수) |
| `docs/600000_implementation_lifecycle/600100_customer_identity_and_guest_promotion/600101_ChangeHistory.md` | UPDATE — Stage 6 ACCEPT 시 첫 항목 추가 (이번 배치는 골격만) |
| `docs/600000_implementation_lifecycle/600100_customer_identity_and_guest_promotion/600102_NavigationMap.md` | UPDATE — Stage 3/7 최소 1회씩 |

## 2. Forbidden Files (명시적 범위 제외)

- `sql/migrations/0081_create_customer_app_rpc.sql` — `customer_order_history` 뷰 재활성화 금지, 별도 WorkPackage
- `sql/migrations/0082_create_saas_billing_rpc.sql` — **REFERENCE ONLY**, 이미 `os.customer_id`를 활성 참조 중이나 이 change의 수정 대상 아님 (`600111_Overview.md` 표 참고)
- `sql/migrations/0083_create_push_notification_rpc.sql` — **REFERENCE ONLY**, 동일 사유
- `sql/migrations/0097_create_auth_login_pipeline_rpc.sql`, `0115_create_waiting_pipeline_rpc.sql`, `0116_create_customer_app_bootstrap_rpc.sql` — 전부 편집 금지, 참조만
- 고객 삭제/탈퇴 보관 로직 — 별도 WorkPackage (Human 결정 #2)
- `docs/.../005015_Policy_Customer_Account_Guest_Merge_Identity_Continuity_Membership_Ready_And_Runtime_Authority_Boundary.md` — 편집 금지, Open Question 1로만 기록
- `.dart`/Flutter 클라이언트 코드 전체 — `600112_Logic.md` §6의 caller-contract 위험은 교차-리포 리스크로만 기록, 이 change는 SQL만
- `docs/600000_implementation_lifecycle/604000_workpackets/604500_order_sessions_customer_id_fk_and_guest_promotion/` — 이동/삭제/quarantine 금지, Open Question 3으로만 기록
- 위 목록에 없는 그 외 모든 `sql/migrations/*.sql`

## 3. Open Items (3개, 재논의 대상 아님 — Human 승인 시 함께 확인만)

1. **005015 충돌** (`600112_Logic.md` Open Question 1) — in-place promotion vs true merge 구분이 005015에 필요한지 여부
2. **익명 게스트 dedupe 부재** (`600112_Logic.md` Open Question 2) — Human 결정 #4로 이번 범위 안에서는 수용, 향후 device-fingerprint 키 도입 여부만 미정
3. **604500/600110 CHANGE_ID 중복** (`600112_Logic.md` Open Question 3) — 폴더 정리 방향 미정, 이번 작업 대상 아님

**추가 Open Item (이번 조사에서 발견)**: `600000_implementation_lifecycle`의 실제 격리 범위가 `000701` §15.1의 서술과 부분적으로 모순됨 (`600111_Overview.md` §15.1 격차 정정 참고) — 이 change의 승인/구현과는 무관하지만 별도로 해소 필요.

## 4. Known Constraint (버그 아님, 설계상 수용)

로컬 DB의 `order_sessions.customer_id` FK가 현재 `ON DELETE NO ACTION`으로 out-of-band 적용되어 있음 (`600112_Logic.md` §4). `0148`은 이를 승인된 `ON DELETE SET NULL`로 재조정하는 `DROP CONSTRAINT`/`ADD CONSTRAINT` 구문을 포함해야 하며, 단순 `ADD COLUMN IF NOT EXISTS`만으로는 이 재조정이 이루어지지 않는다는 점을 Stage 3 승인자가 인지해야 한다.

## 5. Human Boundary Approval (Pending — Stage 3, 미승인)

☑ Approved — proceed to Stage 4 (Codex implementation within the file boundary above) (2026-07-11)
☐ Approved with modifications — see notes: _______________
☐ Not approved — blocked pending: _______________

**`000701` §4 Core Rule 준수**: 이 CHANGE_ID에 대해 `sql/migrations/`에 생성된 파일이 현재 없음 (이번 턴 `find`로 재확인). 이 섹션 서명 전까지 생성하지 않는다.