# features/staff — 직원 앱 (Scope B)

900102 ChangeContract 의 `waiting_admin` Scope 에 해당. **Scope D 통과 후** 구현.

> 문서(900102)에서는 `lib/features/waiting_admin/` 로 명명. 본 프로젝트는
> 핸드오프 지시에 따라 `features/staff/` 로 통합한다. (impact_scope.md 참고)

## 예정 파일
- `waiting_admin_screen.dart`
- `waiting_list_tile.dart`
- `waiting_admin_state_notifier.dart`
- `waiting_admin_repository.dart`

## 허용 동작
- 대기 목록 관리, 호출, 도착 확인, 착석/테이블 배정, 노쇼/호출만료 처리
- 사전주문/결제/KDS 상태 **read-only** 표시

## 금지 (INV)
- KDS 수동 release 금지 (INV-004)
- 결제 처리 금지
- `kds_status` 직접 변경 금지 (INV-006)
- 착석/호출만으로 KDS release 금지 (INV-002, INV-003)
