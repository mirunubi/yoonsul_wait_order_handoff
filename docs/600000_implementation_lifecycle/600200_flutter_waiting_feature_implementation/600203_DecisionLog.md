# 600203_DecisionLog.md

Recorded Human decisions for the `600200_flutter_waiting_feature_implementation` module. 재논의 대상 아님 — 향후 세션은 이 로그를 먼저 읽고 이미 결정된 사항을 재검토하지 않는다.

## Decision 1 — 게스트 customer_id 생성 로직은 600120에서 먼저 처리, 600210은 그 이후 설계

게스트 `customer_id` 생성 로직(SQL, 신규)은 `600100_customer_identity_and_guest_promotion/600120_guest_customer_bootstrap_rpc/`에서 먼저 처리한다. `600210_waiting_feature_guest_customer_id_integration/`(Flutter 측)의 `Overview.md` 작성은 `600120`의 RPC 시그니처가 확정된 뒤, 그 RPC를 소비하는 형태로 설계한다 — 순서를 바꾸지 않는다.

## Decision 2 — 게스트 customer_id는 SharedPreferences에 session_id와 함께 저장, SecureStorage와 분리

게스트 `customer_id`는 `session_id`와 함께 `SharedPreferences`에 저장하여 기기 재시작 후에도 유지한다. `SecureStorage`는 JWT 전용으로 분리하고, 게스트 `customer_id`는 그쪽에 저장하지 않는다.

## Decision 3 — go_router 배선을 이번 waiting feature 작업 범위에 포함

`go_router` 배선(`lib/app/router.dart` 생성 및 배선 포함)을 이번 waiting feature 작업 범위에 포함한다.
