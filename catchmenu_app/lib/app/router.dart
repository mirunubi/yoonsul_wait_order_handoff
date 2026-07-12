import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/waiting/screens/waiting_register_screen.dart';
import '../features/waiting/screens/waiting_status_screen.dart';

GoRouter createAppRouter({required Widget bootScreen}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => bootScreen),
      GoRoute(
        path: '/waiting/register',
        builder: (context, state) => const WaitingRegisterScreen(),
      ),
      GoRoute(
        path: '/waiting/status',
        builder: (context, state) => const WaitingStatusScreen(),
      ),
    ],
  );
}
