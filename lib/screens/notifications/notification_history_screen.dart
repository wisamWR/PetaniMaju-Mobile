import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/models/notification_record.dart';
import '../../data/services/notification_history_service.dart';
import '../../widgets/app_ui.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  final _service = NotificationHistoryService();
  List<NotificationRecord>? _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _service.getHistory();
    if (mounted) setState(() => _items = items);
    await _service.markAllRead();
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Notifikasi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _service.clear();
      _load();
    }
  }

  (IconData, Color) _style(String? payload) {
    switch (payload) {
      case 'weather':
        return (Icons.cloud, Colors.blue);
      case 'calendar':
        return (Icons.calendar_month, Colors.green);
      case 'dashboard':
        return (Icons.wb_sunny, Colors.orange);
      default:
        return (Icons.notifications, AppColors.primary);
    }
  }

  void _open(NotificationRecord r) {
    switch (r.payload) {
      case 'weather':
        context.push('/cuaca');
        break;
      case 'calendar':
        context.push('/calendar');
        break;
      default:
        context.go('/dashboard');
    }
  }

  String _groupLabel(DateTime t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(t.year, t.month, t.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Hari Ini';
    if (diff == 1) return 'Kemarin';
    return DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(t);
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar('Notifikasi', actions: [
        IconButton(
          tooltip: 'Pengaturan notifikasi',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push('/notifikasi/pengaturan'),
        ),
        if (items != null && items.isNotEmpty)
          IconButton(
              tooltip: 'Hapus semua',
              onPressed: _clearAll,
              icon: const Icon(Icons.delete_sweep_outlined)),
      ]),
      body: items == null
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_off_outlined,
                  title: 'Belum ada notifikasi',
                  subtitle: 'Peringatan cuaca & pengingat jadwal akan muncul di sini.',
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final r = items[i];
                      final showHeader =
                          i == 0 || _groupLabel(items[i - 1].time) != _groupLabel(r.time);
                      final (icon, color) = _style(r.payload);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader)
                            Padding(
                              padding: EdgeInsets.only(bottom: 8, top: i == 0 ? 0 : 12),
                              child: Text(_groupLabel(r.time),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, color: Colors.grey[700])),
                            ),
                          Dismissible(
                            key: ValueKey('${r.id}_${r.time.toIso8601String()}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                  color: Colors.red, borderRadius: BorderRadius.circular(16)),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              setState(() => items.removeAt(i));
                              _service.delete(r);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => _open(r),
                                borderRadius: BorderRadius.circular(16),
                                child: InfoCard(
                                  color: r.read ? Colors.white : Colors.green[50],
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: color.withOpacity(0.1),
                                            shape: BoxShape.circle),
                                        child: Icon(icon, size: 20, color: color),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(r.title,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 4),
                                            Text(r.body,
                                                style: TextStyle(
                                                    fontSize: 13, color: Colors.grey[700])),
                                            const SizedBox(height: 4),
                                            Text(DateFormat('HH:mm').format(r.time),
                                                style: TextStyle(
                                                    fontSize: 11, color: Colors.grey[500])),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
    );
  }
}
