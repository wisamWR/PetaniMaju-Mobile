/// Konfigurasi yang dibaca dari `--dart-define` saat build/run.
///
/// Contoh:
///   flutter run --dart-define=GEMINI_API_KEY=xxxx
/// atau
///   flutter run --dart-define-from-file=.env
class Env {
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;

  /// Email tujuan tombol "Hubungi Kami" di layar Bantuan.
  static const String supportEmail = String.fromEnvironment('SUPPORT_EMAIL');

  /// Model Gemini yang dicoba berurutan (fallback bila model sibuk / 503).
  static const List<String> geminiModels = [
    'gemini-3.6-flash',
    'gemini-3.5-flash',
    'gemini-3.1-flash-lite',
  ];
}
