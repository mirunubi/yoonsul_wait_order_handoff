// CatchMenu MVP 부트 스모크 테스트.
//
// Supabase 미초기화 상태에서도 부팅 화면이 렌더되는지만 확인한다.
// Scope 별 화면 테스트는 각 Scope 구현과 함께 추가한다 (900103 TestPlan).

import 'package:flutter_test/flutter_test.dart';

import 'package:catchmenu_app/main.dart';
import 'package:catchmenu_app/core/errors/app_error.dart';

void main() {
  testWidgets('부팅 화면 렌더 (초기화 실패 경로)', (WidgetTester tester) async {
    await tester.pumpWidget(
      CatchMenuApp(
        initError: AppError.notInitialized('테스트: Supabase 설정 없음'),
      ),
    );

    expect(find.text('초기화 실패'), findsOneWidget);
  });
}
