import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'notification_service.dart';
import 'weather_service.dart';

/// Cek cuaca berkala di background supaya peringatan cuaca ekstrem tetap
/// muncul walau aplikasi tidak dibuka. Memakai koordinat terakhir yang
/// berhasil dimuat di aplikasi, jadi tidak butuh izin lokasi background.
class BackgroundWeather {
  static const String uniqueName = 'weather-alert-check';
  static const String taskName = 'weatherAlertCheck';
  static const Duration frequency = Duration(hours: 3);

  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  /// Daftarkan atau batalkan tugas sesuai saklar notifikasi.
  static Future<void> sync() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? false;
    if (enabled) {
      await Workmanager().registerPeriodicTask(
        uniqueName,
        taskName,
        frequency: frequency,
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      );
    } else {
      await Workmanager().cancelByUniqueName(uniqueName);
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await NotificationService().init(requestPermissions: false);
      final checked = await WeatherService().checkAlertsInBackground();
      debugPrint('BackgroundWeather: $task selesai (checked=$checked)');
      return true;
    } catch (e) {
      debugPrint('BackgroundWeather: $task gagal: $e');
      return false; // WorkManager akan mencoba lagi dengan backoff
    }
  });
}
