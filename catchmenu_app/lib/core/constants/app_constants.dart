/// 앱 전역 상수 및 환경 설정.
///
/// 비밀값(Supabase URL / anon key)은 소스에 하드코딩하지 않고
/// 컴파일 타임 `--dart-define` 으로 주입한다.
///
///   flutter run \
///     --dart-define=APP_ENV=dev \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJ...
class AppConstants {
  AppConstants._();

  // --- 환경 ---
  /// 'dev' | 'staging' | 'prod'. 기본은 dev.
  static const String appEnv =
      String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  static bool get isProd => appEnv == 'prod';

  /// prod 가 아니면 개발 모드로 간주 (dev audit 로깅 활성).
  static bool get isDev => !isProd;

  // --- Supabase (--dart-define 주입) ---
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  // --- 앱 메타 ---
  static const String appName = 'CatchMenu';
  static const String appVersion = '1.0.0';

  // --- Postgres 스키마 (PostgREST 노출 필요) ---
  // 주의: public 이외 스키마는 Supabase 프로젝트 설정의
  //       "Exposed schemas" 에 등록되어 있어야 rpc 호출이 가능하다.
  static const String schemaPublic = 'public';
  static const String schemaPos = 'catchmenu_pos'; // register_waiting, seat, call
  static const String schemaPayment = 'catchmenu_payment'; // confirm_payment
  static const String schemaCommon = 'catchmenu_common'; // run_integration_test
  static const String schemaKds = 'catchmenu_kds';
  static const String schemaDev = 'catchmenu_dev'; // write_audit_log (dev only)

  // --- dev audit pipeline 값 (0136_create_dev_audit_log.sql 주석 기준) ---
  static const String pipelineWaiting = 'WAITING_HANDOFF';
  static const String pipelineKds = 'KDS_LATE_BINDING';
  static const String pipelinePayment = 'PAYMENT';
  static const String pipelineSession = 'SESSION_MGMT';
  static const String pipelineRealtime = 'REALTIME';
  static const String pipelinePos = 'POS_INTEGRATION';
  static const String pipelineMembership = 'MEMBERSHIP';
  static const String pipelineDid = 'DID';

  // --- INV-004: 클라이언트가 절대 직접 호출하면 안 되는 서버 전용 RPC ---
  // rpc_caller 가 이 목록을 강제 차단한다.
  static const Set<String> forbiddenClientRpcs = {
    'release_kds_after_payment',
  };
}
