import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/errors/app_error.dart';
import 'core/supabase/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase 초기화. 설정 누락 시 부팅 화면에서 안내한다.
  AppError? initError;
  try {
    await SupabaseInit.ensureInitialized();
  } on AppError catch (e) {
    initError = e;
  }

  runApp(
    ProviderScope(
      child: CatchMenuApp(initError: initError),
    ),
  );
}

class CatchMenuApp extends StatelessWidget {
  const CatchMenuApp({super.key, this.initError});

  final AppError? initError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: _BootScreen(initError: initError),
    );
  }
}

/// 부팅 화면 (placeholder).
/// 라우팅(go_router) 및 각 Scope 화면은 Scope D 통과 후 연결한다.
class _BootScreen extends StatelessWidget {
  const _BootScreen({this.initError});

  final AppError? initError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppConstants.appName} · ${AppConstants.appEnv}'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: initError == null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.teal, size: 48),
                    const SizedBox(height: 12),
                    Text('${AppConstants.appName} MVP 부트스트랩 완료'),
                    const SizedBox(height: 4),
                    Text('Supabase 연결됨 · v${AppConstants.appVersion}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.redAccent, size: 48),
                    const SizedBox(height: 12),
                    const Text('초기화 실패'),
                    const SizedBox(height: 8),
                    Text(
                      initError!.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
