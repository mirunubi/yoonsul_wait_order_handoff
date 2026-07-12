// CatchMenu MVP bootstrap screen test.
//
// Scope-specific screen tests are added with each implementation slice.

import 'package:flutter_test/flutter_test.dart';

import 'package:catchmenu_app/core/errors/app_error.dart';
import 'package:catchmenu_app/main.dart';

void main() {
  testWidgets(
    'bootstrap screen renders initialization failure through router',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        CatchMenuApp(
          initError: AppError.notInitialized('test Supabase config missing'),
        ),
      );
    await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('test Supabase config missing'), findsOneWidget);
    },
  );
}
