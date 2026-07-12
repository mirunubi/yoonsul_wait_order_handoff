# 600414_ChangeContract.md

Status: Draft — requires Stage 3 Human approval before binding
Lifecycle: ChangeContract
Stage: 2 (Claude role)
Owner: TBD
Last Updated: 2026-07-13
CHANGE_ID: `kds_capacity_gate_and_status_reconciliation`

## 1. Allowed Files

| 파일 | 동작 |
|---|---|
| `sql/migrations/0151_create_check_kds_capacity_function.sql` (신규, 번호는 이번 턴 `0150`이 최신임을 재확인한 결과 — Stage 3 승인 시점 재확인 필요) | `catchmenu_kds.check_kds_capacity(p_tenant_id, p_store_id)` 신규 생성. `catchmenu_kds.evaluate_kds_capacity(...)`를 zone별로 순회 호출(§0.1 zone 목록 도출 방법)해 개별 zone 결과 배열 + 매장 전체 집계(`600413_TestPlan.md` §0의 "하나라도 초과 시 전체 false" 규칙)를 반환하는 wrapper. `kitchen_zone`이 `null`인 티켓은 `'UNASSIGNED'` 가상 구역으로 취급(Human 결정, 2026-07-13)하되, `evaluate_kds_capacity()`로 위임하지 않고 wrapper 내부에서 `kitchen_zone is null` 직접 카운트로 별도 처리(`600412_Logic.md` §2, `600413_TestPlan.md` §1.2 참고). `600412_Logic.md`/`600413_TestPlan.md` 참고 |

## 2. Forbidden Files (명시적 범위 제외)

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` — **편집 금지.** 호출부(`p_tenant_id :=`, `p_store_id :=` 2-param)가 이미 신규 함수 시그니처와 일치하므로 손댈 필요가 없다. 건드리면 이미 맞는 코드를 불필요하게 재작성하는 것.
- `sql/migrations/0099_create_realtime_pipeline_rpc.sql` — 동일 이유로 편집 금지. `get_kds_realtime_state()`가 `check_kds_capacity()`를 직접 호출하지만(`600413_TestPlan.md` §3 재확인), 호출 형태 자체는 이미 올바르므로 이 함수 생성만으로 연결된다.
- `sql/migrations/0106_create_delivery_platform_pipeline_rpc.sql` — 동일 이유로 편집 금지.
- `sql/migrations/0016_create_kds_tickets.sql`, `0028_create_kds_capacity_commit_rpc.sql`, `0029_create_kds_cooking_rpc.sql` — `evaluate_kds_capacity()`/`chk_kds_status`/상태 전이 로직의 원본. **참조만, 편집 금지**(지시 사항 "다른 KDS 파일 건드리지 말 것").
- `sql/migrations/0092`, `0096`, `0113`, `0119`, `0129` — 문자열/문서 텍스트로만 `check_kds_capacity`를 언급하는 5개 파일(`600411_Overview.md` 참고). 편집 불필요·금지.
- 위 목록에 없는 그 외 `sql/migrations/**` 전체.

## 3. Open Items

1. **`chk_kds_status`가 `'COMMITTED'`를 허용하지 않는 문제** — `600413_TestPlan.md` §2에서 예상·재현할 다음 결함. 이번 change 범위 밖이며, **`600400` 모듈의 다음 변경건 후보로 예고**한다(§0 원칙에 따라 다음 결함이 실제로 다뤄질 때 그 변경건의 `Overview.md`가 근거 문서를 다시 링크한다).
2. **`0099`(`get_kds_realtime_state()`)의 다른 stale 컬럼 문제 가능성** — 이번 change로 `check_kds_capacity` 관련 에러는 해소되지만, 그 이후 다른 참조가 남아있을 수 있음 — 실행 시 새 에러가 나오면 별도 결함으로 기록(§0 원칙: 결함 하나씩 처리, 미리 전수 스캔하지 않음).
3. ~~`600412_Logic.md`와의 설계 동기화 필요~~ — **해결됨**: `600412_Logic.md` §2가 zone별 순회·집계 설계 및 `UNASSIGNED` 처리로 갱신되어 600412/600413/600414 세 문서가 동기화됨.
4. **(신규, 이번 범위 밖) `UNASSIGNED` 티켓의 운영자 가시성 UX** — 구역 미지정 티켓 존재를 직원 앱/KDS 화면에서 알아볼 수 있게 하는 UX는 이번 SQL 함수 신설 워크패킷 범위 밖 — 별도 후속 workpacket으로 이월.

## 4. Human Boundary Approval (Pending — Stage 3, 미승인)

☑ Approved — proceed to Stage 4 (Codex implementation within the file boundary above) (승인일자: 2026-07-11)
☐ Approved with modifications — see notes: _______________
☐ Not approved — blocked pending: _______________

**`000701` §4 Core Rule 준수**: 이 CHANGE_ID에 대해 `sql/migrations/`에 생성된 파일이 현재 없음(이번 턴 `git status`/`ls`로 재확인, `0151` 미존재). 이 섹션 서명 전까지 생성하지 않는다.
