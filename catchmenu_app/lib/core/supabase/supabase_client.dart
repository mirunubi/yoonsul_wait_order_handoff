import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../errors/app_error.dart';

/// Supabase 초기화 및 전역 접근 지점.
///
/// 앱 부팅 시 [ensureInitialized] 를 한 번 호출한 뒤,
/// 어디서든 [client] 로 SupabaseClient 에 접근한다.
///
/// 직접 `Supabase.instance.client.rpc(...)` 를 호출하지 말 것.
/// 모든 RPC 는 반드시 rpc_caller.dart 의 RpcCaller 를 통한다.
class SupabaseInit {
  SupabaseInit._();

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// 멱등. 이미 초기화되어 있으면 아무 것도 하지 않는다.
  static Future<void> ensureInitialized() async {
    if (_initialized) return;

    if (!AppConstants.hasSupabaseConfig) {
      throw AppError.notInitialized(
        'SUPABASE_URL / SUPABASE_ANON_KEY 가 설정되지 않았습니다. '
        '--dart-define 으로 주입하세요.',
      );
    }

    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      debug: AppConstants.isDev,
    );

    _initialized = true;
  }

  /// 초기화된 SupabaseClient. 초기화 전 접근 시 예외.
  static SupabaseClient get client {
    if (!_initialized) {
      throw AppError.notInitialized(
        'Supabase 가 초기화되지 않았습니다. '
        'SupabaseInit.ensureInitialized() 를 먼저 호출하세요.',
      );
    }
    return Supabase.instance.client;
  }
}
