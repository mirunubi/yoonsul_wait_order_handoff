# features/kds — KDS 화면 (Scope C)

900102 ChangeContract 기준. **Scope D 통과 후** 구현.

## 예정 파일
- `kds_screen.dart`
- `kds_ticket_card.dart`
- `kds_state_notifier.dart`
- `kds_repository.dart`

## 표시 규칙
- `HOLD`: 회색 배경 + 조리 버튼 disabled + 타이머 미표시 → "결제 대기 중 / Payment Pending"
- `COMMITTED`: Realtime 수신 후 녹색 + 버튼 활성 + 타이머 시작
- `COOKING/READY/SERVED`: `transition_kds_ticket()` 전환 버튼

## 금지 (INV)
- KDS UI 에서 `release_kds_after_payment()` 호출 금지 (INV-004)
- `HOLD → COOKING` 직접 전환 금지 (INV-001)
- `kds_status` 를 로컬 상태로 임의 변경 금지 (INV-006)
- HOLD 티켓에 "강제 해제"/"시작" 버튼 없음
