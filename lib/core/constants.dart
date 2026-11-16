/// Kredensial dibaca dari `--dart-define-from-file=.env` (lihat `.env.example`).
class AppConstants {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String openWeatherApiKey =
      String.fromEnvironment('OPENWEATHER_API_KEY');

  /// Nama variabel wajib yang belum diisi.
  static List<String> get missingRequired => [
        if (supabaseUrl.isEmpty) 'SUPABASE_URL',
        if (supabaseAnonKey.isEmpty) 'SUPABASE_ANON_KEY',
        if (openWeatherApiKey.isEmpty) 'OPENWEATHER_API_KEY',
      ];
}
