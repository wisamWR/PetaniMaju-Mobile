import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

import '../models/notification_record.dart';
import '../models/notification_settings.dart';
import 'notification_history_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const int dailyBriefId = 888;
  static const int weatherReminderId = 887;
  static const String _settingsKey = 'notification_settings';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final NotificationHistoryService _history = NotificationHistoryService();

  /// [requestPermissions] false untuk isolate background (tidak ada Activity).
  Future<void> init(
      {Function(String?)? onNotificationTap,
      bool requestPermissions = true}) async {
    tz.initializeTimeZones();
    // Set default location generally to WIB/Jakarta as a safe default for Indonesia users
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (e) {
      debugPrint("Error setting timezone: $e");
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        debugPrint("Notification tapped: ${response.payload}");
        if (onNotificationTap != null) {
          onNotificationTap(response.payload);
        }
      },
    );

    // Explicitly request permissions via plugin for Android 13+ and 12+
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (requestPermissions && androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      try {
        await androidImplementation.requestExactAlarmsPermission();
      } catch (e) {
        debugPrint("Error requesting specific exact alarm permission: $e");
      }
    }
  }

  Future<void> requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    // For Android 12+ exact alarm scheduling
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  // --- Settings ---

  Future<NotificationSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null) return const NotificationSettings();
    try {
      return NotificationSettings.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw)));
    } catch (_) {
      return const NotificationSettings();
    }
  }

  Future<void> saveSettings(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
    await applySettings();
  }

  Future<bool> isGloballyEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? false;
  }

  /// Jadwalkan ulang notifikasi harian sesuai pengaturan terbaru.
  Future<void> applySettings() async {
    final settings = await getSettings();
    final enabled = await isGloballyEnabled();
    await scheduleDailyBrief(
      isEnabled: enabled && settings.morningBriefingEnabled,
      hour: settings.morningBriefingHour,
      minute: settings.morningBriefingMinute,
    );
    await scheduleWeatherReminder(
        isEnabled: enabled && settings.weatherReminderEnabled);
  }

  // --- Scheduling ---

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime date,
    TimeOfDay? time,
  }) async {
    // Schedule for specific time on the specific date
    final targetTime = time ?? const TimeOfDay(hour: 7, minute: 0);
    final scheduledDate = DateTime(
      date.year,
      date.month,
      date.day,
      targetTime.hour,
      targetTime.minute,
      0,
    );

    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) {
      debugPrint("Skipping scheduling for past date: $scheduledDate");
      return;
    }

    // Calculate relative duration to avoid timezone issues
    final durationToWait = scheduledDate.difference(now);
    final tzScheduled = tz.TZDateTime.now(tz.local).add(durationToWait);

    debugPrint(
        "DEBUG: Scheduling ID $id at $scheduledDate (in ${durationToWait.inMinutes} mins)");

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_farming_schedule',
        'Jadwal Pertanian',
        channelDescription: 'Pengingat harian jadwal pertanian',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'calendar',
      );
    } catch (e) {
      debugPrint("ERROR Scheduling Notification: $e");
      // Fallback for exact alarm permission issues
      if (!e.toString().contains("exact_alarms_not_permitted")) return;
      debugPrint("Falling back to inexact scheduling...");
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'calendar',
      );
    }

    await _history.addPending(NotificationRecord(
      id: id,
      title: title,
      body: body,
      payload: 'calendar',
      time: scheduledDate,
    ));
  }

  /// Pengingat jadwal tani: H-1, H-1 jam, dan tepat waktu (sesuai pengaturan).
  /// Pengingat H-1 / H-1 jam dilewati bila jatuh di jam mode tenang.
  Future<void> scheduleCalendarReminders({
    required int eventId,
    required String title,
    required String type,
    required DateTime eventTime,
  }) async {
    final settings = await getSettings();
    final timeLabel =
        "${eventTime.hour.toString().padLeft(2, '0')}:${eventTime.minute.toString().padLeft(2, '0')}";

    Future<void> schedule(int id, DateTime at, String t, String body,
        {bool respectQuiet = true}) async {
      if (respectQuiet && settings.isQuietAt(at)) return;
      await scheduleDailyNotification(
        id: id,
        title: t,
        body: body,
        date: at,
        time: TimeOfDay(hour: at.hour, minute: at.minute),
      );
    }

    if (settings.reminder1DayBefore) {
      await schedule(
        calendarReminderId(eventId, 1),
        eventTime.subtract(const Duration(days: 1)),
        "Besok: $type 📅",
        "Jangan lupa, besok pukul $timeLabel ada kegiatan '$title'.",
      );
    }
    if (settings.reminder1HourBefore) {
      await schedule(
        calendarReminderId(eventId, 2),
        eventTime.subtract(const Duration(hours: 1)),
        "1 Jam Lagi: $type ⏰",
        "Kegiatan '$title' dimulai pukul $timeLabel. Siapkan peralatan!",
      );
    }
    if (settings.reminderAtTime) {
      await schedule(
        calendarReminderId(eventId, 0),
        eventTime,
        "Pengingat Jadwal Tani 🌱",
        "Saatnya melakukan kegiatan '$type' - $title. Semangat bertani!",
        respectQuiet: false,
      );
    }
  }

  /// ID notifikasi unik per pengingat kalender. slot 0 = tepat waktu.
  static int calendarReminderId(int eventId, int slot) =>
      slot == 0 ? eventId : 1000000 + eventId * 10 + slot;

  Future<void> cancelCalendarReminders(int eventId) async {
    for (final slot in [0, 1, 2]) {
      await cancelType(calendarReminderId(eventId, slot));
    }
  }

  Future<void> scheduleDailyBrief(
      {bool isEnabled = true, int hour = 6, int minute = 0}) async {
    if (!isEnabled) {
      await flutterLocalNotificationsPlugin.cancel(dailyBriefId);
      return;
    }

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint("DEBUG: Scheduling Daily Brief at $scheduledDate");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      dailyBriefId,
      "Selamat Pagi, Petani! ☀️",
      "Cek prakiraan cuaca dan jadwal tani hari ini sebelum ke sawah.",
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_brief_channel',
          'Sapaan Pagi',
          channelDescription: 'Notifikasi harian sapaan pagi',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeats daily
      payload: 'dashboard',
    );
  }

  Future<void> scheduleWeatherReminder({bool isEnabled = true}) async {
    if (!isEnabled) {
      await flutterLocalNotificationsPlugin.cancel(weatherReminderId);
      return;
    }

    // Schedule for 16:00 (4 PM)
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 16, 0);
    // If 16:00 passed, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint("DEBUG: Scheduling Weather Reminder at $scheduledDate");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      weatherReminderId,
      "Sudah Cek Cuaca Sore Ini? 🌦️",
      "Buka aplikasi sebentar untuk update prediksi hujan & hama.",
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weather_reminder_channel',
          'Pengingat Cuaca',
          channelDescription: 'Pengingat harian untuk cek cuaca sore',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeats daily
      payload: 'weather',
    );
  }

  // --- Immediate notifications ---

  Future<void> _showNow({
    required int id,
    required String title,
    required String body,
    required NotificationDetails details,
    required String payload,
    bool respectQuiet = true,
  }) async {
    if (respectQuiet) {
      final settings = await getSettings();
      if (settings.isQuietAt(DateTime.now())) {
        debugPrint("DEBUG: Quiet mode aktif, notifikasi '$title' ditahan.");
        return;
      }
    }
    await flutterLocalNotificationsPlugin.show(id, title, body, details,
        payload: payload);
    await _history.log(NotificationRecord(
      id: id,
      title: title,
      body: body,
      payload: payload,
      time: DateTime.now(),
    ));
  }

  /// Menampilkan peringatan cuaca bila jenisnya diizinkan di pengaturan.
  Future<bool> showWeatherAlert(String title, String body) async {
    final settings = await getSettings();
    if (!settings.allowsWeatherAlert(title)) return false;

    // Dynamic ID based on time to allow multiple alerts (e.g. Rain AND Wind).
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _showNow(
      id: id,
      title: title,
      body: body,
      payload: 'weather',
      details: const NotificationDetails(
        android: AndroidNotificationDetails(
          'weather_alert_channel',
          'Peringatan Cuaca',
          channelDescription: 'Notifikasi cuaca ekstrem',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
    );
    return true;
  }

  Future<void> showTestMorningBrief() async {
    await _showNow(
      id: 889,
      title: "Selamat Pagi, Petani! ☀️ (Test)",
      body: "Cek prakiraan cuaca dan jadwal tani hari ini sebelum ke sawah.",
      payload: 'dashboard',
      respectQuiet: false,
      details: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_brief_channel',
          'Sapaan Pagi',
          channelDescription: 'Notifikasi harian sapaan pagi',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  Future<void> showTestWeatherReminder() async {
    await _showNow(
      id: weatherReminderId,
      title: "Sudah Cek Cuaca Sore Ini? 🌦️ (Test)",
      body: "Buka aplikasi sebentar untuk update prediksi hujan & hama.",
      payload: 'weather',
      respectQuiet: false,
      details: const NotificationDetails(
        android: AndroidNotificationDetails(
          'weather_reminder_channel',
          'Pengingat Cuaca',
          channelDescription: 'Pengingat harian untuk cek cuaca sore',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  Future<void> cancelType(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    await _history.removePending(id);
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    await _history.clearPending();
  }
}
