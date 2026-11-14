/// Preferensi notifikasi pengguna (disimpan lokal di SharedPreferences).
class NotificationSettings {
  // Sapaan pagi
  final bool morningBriefingEnabled;
  final int morningBriefingHour;
  final int morningBriefingMinute;

  // Pengingat cek cuaca sore
  final bool weatherReminderEnabled;

  // Peringatan cuaca
  final bool heavyRainAlertEnabled;
  final bool strongWindAlertEnabled;
  final bool extremeHeatAlertEnabled;

  // Pengingat kalender
  final bool reminder1DayBefore;
  final bool reminder1HourBefore;
  final bool reminderAtTime;

  // Mode tenang
  final bool quietModeEnabled;
  final int quietStartHour;
  final int quietEndHour;

  const NotificationSettings({
    this.morningBriefingEnabled = true,
    this.morningBriefingHour = 6,
    this.morningBriefingMinute = 0,
    this.weatherReminderEnabled = true,
    this.heavyRainAlertEnabled = true,
    this.strongWindAlertEnabled = true,
    this.extremeHeatAlertEnabled = true,
    this.reminder1DayBefore = true,
    this.reminder1HourBefore = true,
    this.reminderAtTime = true,
    this.quietModeEnabled = true,
    this.quietStartHour = 22,
    this.quietEndHour = 5,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    const d = NotificationSettings();
    return NotificationSettings(
      morningBriefingEnabled:
          json['morningBriefingEnabled'] ?? d.morningBriefingEnabled,
      morningBriefingHour: json['morningBriefingHour'] ?? d.morningBriefingHour,
      morningBriefingMinute:
          json['morningBriefingMinute'] ?? d.morningBriefingMinute,
      weatherReminderEnabled:
          json['weatherReminderEnabled'] ?? d.weatherReminderEnabled,
      heavyRainAlertEnabled:
          json['heavyRainAlertEnabled'] ?? d.heavyRainAlertEnabled,
      strongWindAlertEnabled:
          json['strongWindAlertEnabled'] ?? d.strongWindAlertEnabled,
      extremeHeatAlertEnabled:
          json['extremeHeatAlertEnabled'] ?? d.extremeHeatAlertEnabled,
      reminder1DayBefore: json['reminder1DayBefore'] ?? d.reminder1DayBefore,
      reminder1HourBefore: json['reminder1HourBefore'] ?? d.reminder1HourBefore,
      reminderAtTime: json['reminderAtTime'] ?? d.reminderAtTime,
      quietModeEnabled: json['quietModeEnabled'] ?? d.quietModeEnabled,
      quietStartHour: json['quietStartHour'] ?? d.quietStartHour,
      quietEndHour: json['quietEndHour'] ?? d.quietEndHour,
    );
  }

  Map<String, dynamic> toJson() => {
        'morningBriefingEnabled': morningBriefingEnabled,
        'morningBriefingHour': morningBriefingHour,
        'morningBriefingMinute': morningBriefingMinute,
        'weatherReminderEnabled': weatherReminderEnabled,
        'heavyRainAlertEnabled': heavyRainAlertEnabled,
        'strongWindAlertEnabled': strongWindAlertEnabled,
        'extremeHeatAlertEnabled': extremeHeatAlertEnabled,
        'reminder1DayBefore': reminder1DayBefore,
        'reminder1HourBefore': reminder1HourBefore,
        'reminderAtTime': reminderAtTime,
        'quietModeEnabled': quietModeEnabled,
        'quietStartHour': quietStartHour,
        'quietEndHour': quietEndHour,
      };

  NotificationSettings copyWith({
    bool? morningBriefingEnabled,
    int? morningBriefingHour,
    int? morningBriefingMinute,
    bool? weatherReminderEnabled,
    bool? heavyRainAlertEnabled,
    bool? strongWindAlertEnabled,
    bool? extremeHeatAlertEnabled,
    bool? reminder1DayBefore,
    bool? reminder1HourBefore,
    bool? reminderAtTime,
    bool? quietModeEnabled,
    int? quietStartHour,
    int? quietEndHour,
  }) {
    return NotificationSettings(
      morningBriefingEnabled:
          morningBriefingEnabled ?? this.morningBriefingEnabled,
      morningBriefingHour: morningBriefingHour ?? this.morningBriefingHour,
      morningBriefingMinute:
          morningBriefingMinute ?? this.morningBriefingMinute,
      weatherReminderEnabled:
          weatherReminderEnabled ?? this.weatherReminderEnabled,
      heavyRainAlertEnabled:
          heavyRainAlertEnabled ?? this.heavyRainAlertEnabled,
      strongWindAlertEnabled:
          strongWindAlertEnabled ?? this.strongWindAlertEnabled,
      extremeHeatAlertEnabled:
          extremeHeatAlertEnabled ?? this.extremeHeatAlertEnabled,
      reminder1DayBefore: reminder1DayBefore ?? this.reminder1DayBefore,
      reminder1HourBefore: reminder1HourBefore ?? this.reminder1HourBefore,
      reminderAtTime: reminderAtTime ?? this.reminderAtTime,
      quietModeEnabled: quietModeEnabled ?? this.quietModeEnabled,
      quietStartHour: quietStartHour ?? this.quietStartHour,
      quietEndHour: quietEndHour ?? this.quietEndHour,
    );
  }

  /// Apakah [time] berada di rentang mode tenang (mendukung lintas tengah malam).
  bool isQuietAt(DateTime time) {
    if (!quietModeEnabled) return false;
    final h = time.hour;
    if (quietStartHour > quietEndHour) {
      return h >= quietStartHour || h < quietEndHour;
    }
    return h >= quietStartHour && h < quietEndHour;
  }

  /// Apakah jenis peringatan cuaca (berdasar judul alert) diizinkan.
  bool allowsWeatherAlert(String title) {
    final t = title.toLowerCase();
    if (t.contains('hujan')) return heavyRainAlertEnabled;
    if (t.contains('angin')) return strongWindAlertEnabled;
    if (t.contains('panas')) return extremeHeatAlertEnabled;
    return true;
  }
}
