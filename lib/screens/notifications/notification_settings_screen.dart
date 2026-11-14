import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/notification_settings.dart';
import '../../data/services/notification_service.dart';
import '../../widgets/app_ui.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _service = NotificationService();
  NotificationSettings? _settings;
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await _service.getSettings();
    final enabled = await _service.isGloballyEnabled();
    if (mounted) {
      setState(() {
        _settings = s;
        _enabled = enabled;
      });
    }
  }

  Future<void> _update(NotificationSettings s) async {
    setState(() => _settings = s);
    await _service.saveSettings(s);
  }

  Future<void> _toggleGlobal(bool val) async {
    setState(() => _enabled = val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', val);
    if (val) {
      await _service.requestPermissions();
      await _service.applySettings();
    } else {
      await _service.cancelAll();
    }
  }

  String _fmt(int h, [int m = 0]) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

  Future<TimeOfDay?> _pickTime(int hour, int minute) => showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: hour, minute: minute),
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = _settings;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: buildAppBar('Pengaturan Notifikasi'),
      body: s == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _group(null, [
                  _switch(Icons.notifications_active, 'Aktifkan Notifikasi',
                      'Izinkan PetaniMaju mengirim pengingat', _enabled, _toggleGlobal),
                ]),
                const SizedBox(height: 16),
                Opacity(
                  opacity: _enabled ? 1 : 0.5,
                  child: IgnorePointer(
                    ignoring: !_enabled,
                    child: Column(children: [
                      _group('Rutin Harian', [
                        _switch(Icons.wb_sunny, 'Sapaan Pagi',
                            'Ringkasan cuaca & jadwal setiap pagi', s.morningBriefingEnabled,
                            (v) => _update(s.copyWith(morningBriefingEnabled: v))),
                        _tile(
                          Icons.schedule,
                          'Jam Sapaan Pagi',
                          _fmt(s.morningBriefingHour, s.morningBriefingMinute),
                          () async {
                            final t = await _pickTime(
                                s.morningBriefingHour, s.morningBriefingMinute);
                            if (t != null) {
                              _update(s.copyWith(
                                  morningBriefingHour: t.hour, morningBriefingMinute: t.minute));
                            }
                          },
                          enabled: s.morningBriefingEnabled,
                        ),
                        _switch(Icons.cloud_queue, 'Pengingat Cek Cuaca Sore',
                            'Setiap hari pukul 16:00', s.weatherReminderEnabled,
                            (v) => _update(s.copyWith(weatherReminderEnabled: v))),
                      ]),
                      const SizedBox(height: 16),
                      _group('Peringatan Cuaca', [
                        _switch(Icons.thunderstorm, 'Hujan Lebat', null, s.heavyRainAlertEnabled,
                            (v) => _update(s.copyWith(heavyRainAlertEnabled: v))),
                        _switch(Icons.air, 'Angin Kencang', null, s.strongWindAlertEnabled,
                            (v) => _update(s.copyWith(strongWindAlertEnabled: v))),
                        _switch(Icons.thermostat, 'Panas Ekstrem', null,
                            s.extremeHeatAlertEnabled,
                            (v) => _update(s.copyWith(extremeHeatAlertEnabled: v))),
                      ]),
                      const SizedBox(height: 16),
                      _group('Pengingat Jadwal Tani', [
                        _switch(Icons.event, 'H-1 (sehari sebelum)', null,
                            s.reminder1DayBefore,
                            (v) => _update(s.copyWith(reminder1DayBefore: v))),
                        _switch(Icons.timer, '1 jam sebelum', null, s.reminder1HourBefore,
                            (v) => _update(s.copyWith(reminder1HourBefore: v))),
                        _switch(Icons.alarm, 'Tepat waktu', null, s.reminderAtTime,
                            (v) => _update(s.copyWith(reminderAtTime: v))),
                      ]),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: Text(
                          'Berlaku untuk jadwal baru yang ditambahkan setelah pengaturan diubah.',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _group('Mode Tenang', [
                        _switch(Icons.bedtime, 'Mode Tenang Malam',
                            'Tahan notifikasi di jam istirahat', s.quietModeEnabled,
                            (v) => _update(s.copyWith(quietModeEnabled: v))),
                        _tile(Icons.nightlight, 'Mulai', _fmt(s.quietStartHour), () async {
                          final t = await _pickTime(s.quietStartHour, 0);
                          if (t != null) _update(s.copyWith(quietStartHour: t.hour));
                        }, enabled: s.quietModeEnabled),
                        _tile(Icons.wb_twilight, 'Selesai', _fmt(s.quietEndHour), () async {
                          final t = await _pickTime(s.quietEndHour, 0);
                          if (t != null) _update(s.copyWith(quietEndHour: t.hour));
                        }, enabled: s.quietModeEnabled),
                      ]),
                      const SizedBox(height: 16),
                      _group('Uji Coba', [
                        _tile(Icons.send, 'Kirim notifikasi uji', 'Sapaan pagi', () async {
                          await _service.showTestMorningBrief();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Notifikasi uji dikirim')));
                          }
                        }),
                      ]),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _group(String? title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _leading(IconData icon) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 20, color: AppColors.primary),
      );

  Widget _switch(IconData icon, String title, String? subtitle, bool value,
      ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: _leading(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      value: value,
      activeThumbColor: AppColors.primary,
      onChanged: onChanged,
    );
  }

  Widget _tile(IconData icon, String title, String value, VoidCallback onTap,
      {bool enabled = true}) {
    return ListTile(
      enabled: enabled,
      leading: _leading(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Text(value,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
      onTap: onTap,
    );
  }
}
