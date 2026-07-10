# features/payment — 결제 (Scope A: 고객 앱)

900102 ChangeContract 기준. **Scope D 통과 후** 구현.

## 예정 파일
- `payment_screen.dart`
- `toss_payment_widget.dart`
- `payment_result_handler.dart`
- `payment_repository.dart` — RpcCaller 경유 (`schema: catchmenu_payment`)

## 흐름
1. 토스 결제 위젯 `onSuccess`
2. 서버 `confirm_payment()` 호출 (catchmenu_payment)
3. 서버 응답 전까지 "결제 확인 중..." 표시
4. 서버 `payment_ledger.status = APPROVED` 확인 후에만 완료 UI

## 핵심 (INV)
- 클라이언트 결제 성공 화면 ≠ 결제 완료. 서버 APPROVED 만이 완료 (INV-001)
- KDS release 는 서버 `confirm_payment()` 내부에서만 (INV-004)
- 결제 이벤트 idempotent (INV-005): 중복 confirm/webhook → release 재실행 없음
