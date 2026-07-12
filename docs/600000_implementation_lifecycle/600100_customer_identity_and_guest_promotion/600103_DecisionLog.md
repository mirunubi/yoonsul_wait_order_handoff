# 600103_DecisionLog.md

이 세션에서 `customer_identity_and_guest_promotion` 모듈에 내려진 Human 결정 기록. 재논의 대상 아님 — 향후 세션은 이 로그를 먼저 읽고 이미 결정된 사항을 재검토하지 않는다.

## Decision 1 — customer_id FK 추가 승인

`order_sessions.customer_id`를 `customers(id)` 참조 FK로 추가하는 것을 승인.

## Decision 2 — 삭제 시 ON DELETE SET NULL, 탈퇴 보관은 별도 WorkPackage

고객 삭제 시 `order_sessions`는 `ON DELETE SET NULL`로 row를 보존하고 `customer_id`만 null화한다. 탈퇴 보관(retention) 메커니즘 자체는 이번 범위 밖, 별도 WorkPackage로 분리한다.

## Decision 3 — 게스트 승격은 in-place UPDATE, merge 아님

게스트 주문 시 `customers`에 `is_guest=true`인 실제 row를 `(tenant_id, phone_hash)` 기준 upsert 생성. 회원가입 시 같은 row를 `is_guest=false`로 UPDATE — 병합 마이그레이션 없이 과거 `order_sessions`가 그대로 이어진다. 같은 `customer_id`를 계속 사용한다.

## Decision 4 — 익명 게스트는 dedupe 없이 세션마다 신규 row 허용

`phone_hash`가 없는 완전 익명 게스트는 세션마다 새 `is_guest=true` row 생성을 허용한다. dedupe 키는 없으며, 이는 알려진 제약으로만 기록하고 이번 범위에서 해결하지 않는다.

## Decision 5 — Backfill 불필요

`order_sessions.customer_id`/`phone_hash`, `customers.is_guest` 컬럼은 처음부터 존재하지 않았으므로 채울 과거 데이터가 없다. Backfill 문 불필요.

## Decision 6 — 005015 개정은 이번 범위 밖

005015(게스트/계정 merge 정책)의 개정 여부는 이번 change의 범위 밖이다. `600112_Logic.md` Open Question 1로만 표시하고, 005015 파일 자체는 편집하지 않는다.

## Decision 7 — 604500/600110 CHANGE_ID 중복은 Open 기록만, 폴더 정리는 이번 작업 아님

`604500_order_sessions_customer_id_fk_and_guest_promotion/`(604000_workpackets 잔존)과 `600100`/`600110`(신규)이 같은 CHANGE_ID로 중복 존재하는 것을 확인했다. 이번 문서 작성 대상이 아니며, 실제 폴더 이동/quarantine도 이번 작업에서 수행하지 않는다. Open 항목으로만 기록한다.

---

## 부기 — 이번 세션에서 추가로 발견된, 아직 Human 결정이 내려지지 않은 사항

이 항목들은 위 7개 결정과 달리 **아직 Human 결정이 아니다** — 이번 문서 작성 중 이 에이전트가 직접 발견한 사실이며, 별도 Human 판단이 필요하다:

- `docs/600000_implementation_lifecycle/`이 `000701` §15.1이 서술하는 것과 달리 완전히 격리되지 않고 실제로 살아있는 별도 워크패킷 체계임 (`600111_Overview.md` §15.1 격차 정정 참고)
- 로컬 DB에 `order_sessions.customer_id`가 out-of-band로 이미 부분 적용되어 있으며(`ON DELETE NO ACTION`), 승인된 설계(`ON DELETE SET NULL`)와 다름 (`600112_Logic.md` §4)
- "Cursor Stage 1 스캔 보고서"와 "`0148_...sql`/ChangeContract 초안"이 첨부/전달되었다는 전제로 작업 지시가 왔으나, 리포 전체에서 실재를 확인할 수 없었음
