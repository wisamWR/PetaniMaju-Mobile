import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_record.dart';

/// Menyimpan riwayat notifikasi secara lokal.
///
/// Notifikasi yang langsung tampil dicatat seketika. Notifikasi terjadwal
/// disimpan sebagai "pending" lalu dipindah ke riwayat saat waktunya lewat.
class NotificationHistoryService {
  static final NotificationHistoryService _instance =
      NotificationHistoryService._internal();
  factory NotificationHistoryService() => _instance;
  NotificationHistoryService._internal();

  static const _historyKey = 'notification_history';
  static const _pendingKey = 'notification_pending';
  static const _maxItems = 100;

  Future<List<NotificationRecord>> _read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => NotificationRecord.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _write(String key, List<NotificationRecord> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        key, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  Future<void> log(NotificationRecord record) async {
    final items = await _read(_historyKey);
    items.insert(0, record);
    await _write(_historyKey, items.take(_maxItems).toList());
  }

  Future<void> addPending(NotificationRecord record) async {
    final items = await _read(_pendingKey);
    items.removeWhere((e) => e.id == record.id);
    items.add(record);
    await _write(_pendingKey, items);
  }

  Future<void> removePending(int id) async {
    final items = await _read(_pendingKey);
    items.removeWhere((e) => e.id == id);
    await _write(_pendingKey, items);
  }

  Future<void> clearPending() => _write(_pendingKey, []);

  /// Riwayat terbaru dulu, termasuk notifikasi terjadwal yang sudah lewat.
  Future<List<NotificationRecord>> getHistory() async {
    final now = DateTime.now();
    final pending = await _read(_pendingKey);
    final due = pending.where((p) => !p.time.isAfter(now)).toList();
    final history = await _read(_historyKey);

    if (due.isNotEmpty) {
      history.addAll(due);
      await _write(_pendingKey, pending.where((p) => p.time.isAfter(now)).toList());
    }
    history.sort((a, b) => b.time.compareTo(a.time));
    final trimmed = history.take(_maxItems).toList();
    if (due.isNotEmpty) await _write(_historyKey, trimmed);
    return trimmed;
  }

  Future<int> unreadCount() async =>
      (await getHistory()).where((e) => !e.read).length;

  Future<void> markAllRead() async {
    final items = await getHistory();
    await _write(_historyKey, items.map((e) => e.copyWith(read: true)).toList());
  }

  Future<void> delete(NotificationRecord record) async {
    final items = await _read(_historyKey);
    items.removeWhere((e) =>
        e.id == record.id && e.time.isAtSameMomentAs(record.time));
    await _write(_historyKey, items);
  }

  Future<void> clear() => _write(_historyKey, []);
}
