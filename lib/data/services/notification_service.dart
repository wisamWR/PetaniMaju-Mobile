import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init({Function(String?)? onNotificationTap}) async {
    tz.initializeTimeZones();
    // Set default location generally to WIB/Jakarta as a safe default for Indonesia users
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (e) {
      debugPrint("Error setting timezone: $e");
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

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

    if (androidImplementation != null) {
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

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_farming_schedule',
            'Jadwal Pertanian',
            channelDescription: 'Pengingat harian jadwal pertanian',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'calendar',
      );
    } catch (e) {
      debugPrint("ERROR Scheduling Notification: $e");
      // Fallback for exact alarm permission issues
      if (e.toString().contains("exact_alarms_not_permitted")) {
        debugPrint("Falling back to inexact scheduling...");
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tzScheduled,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_farming_schedule',
              'Jadwal Pertanian',
              channelDescription: 'Pengingat harian jadwal pertanian',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'calendar',
        );
      }
    }
  }

  Future<void> scheduleDailyBrief({bool isEnabled = true}) async {
    const int id = 888;
    if (!isEnabled) {
      await flutterLocalNotificationsPlugin.cancel(id);
      return;
    }

    // Schedule for 06:00 AM
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 6, 0);
    // If 6 AM passed, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint("DEBUG: Scheduling Daily Brief at $scheduledDate");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
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
    const int id = 887;
    if (!isEnabled) {
      await flutterLocalNotificationsPlugin.cancel(id);
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
      id,
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

  Future<void> showWeatherAlert(String title, String body) async {
    // ID 777 for general alerts.
    // Use random ID if we want multiple alerts to stack, but 777 avoids spamming/stacking too much.
    // Let's use a dynamic ID based on time to allow multiple alerts (e.g. Rain AND Wind).
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weather_alert_channel',
          'Peringatan Cuaca',
          channelDescription: 'Notifikasi cuaca ekstrem',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
      payload: 'weather',
    );
  }

  Future<void> showTestMorningBrief() async {
    const int id = 889;
    await flutterLocalNotificationsPlugin.show(
      id,
      "Selamat Pagi, Petani! ☀️ (Test)",
      "Cek prakiraan cuaca dan jadwal tani hari ini sebelum ke sawah.",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_brief_channel',
          'Sapaan Pagi',
          channelDescription: 'Notifikasi harian sapaan pagi',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      payload: 'dashboard',
    );
  }

  Future<void> showTestWeatherReminder() async {
    const int id = 887;
    await flutterLocalNotificationsPlugin.show(
      id,
      "Sudah Cek Cuaca Sore Ini? 🌦️ (Test)",
      "Buka aplikasi sebentar untuk update prediksi hujan & hama.",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weather_reminder_channel',
          'Pengingat Cuaca',
          channelDescription: 'Pengingat harian untuk cek cuaca sore',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      payload: 'weather',
    );
  }

  Future<void> cancelType(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
