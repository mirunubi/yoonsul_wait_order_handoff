# features/waiting — 대기 관리 (Scope A: 고객 앱)

900102 ChangeContract 기준. **Scope D(서버 Guard) 통과 후** 구현.

## 예정 파일
- `waiting_register_screen.dart` — 대기 등록
- `waiting_status_screen.dart` — 대기 현황
- `pre_order_screen.dart` — 사전 주문
- `pre_order_state_notifier.dart`
- `waiting_repository.dart` — RpcCaller 경유 (`schema: catchmenu_pos`)

## 관련 RPC
- `register_waiting` (catchmenu_pos)
- `seat_waiting_customer` (catchmenu_pos)
- `call_waiting_customer` (catchmenu_pos)

## 금지 (INV)
- onSuccess 직후 완료 UI 표시 금지 → 서버 APPROVED 확인 후에만 (INV-001)
- `release_kds_after_payment()` 직접 호출 금지 (INV-004)
- SEATED 이벤트만으로 결제 완료 처리 금지 (INV-002)
