import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/models/chat_models.dart';
import '../../data/services/chat_service.dart';
import '../../widgets/app_ui.dart';

/// Memilih sesi mengembalikan `ChatSession` lewat `context.pop`.
class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final _service = ChatService();
  List<ChatSession>? _sessions;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sessions = await _service.getSessions();
    if (mounted) setState(() => _sessions = sessions);
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Riwayat Chat?'),
        content: const Text('Semua percakapan dengan Asisten Tani akan dihapus.'),
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
      await _service.clearSessions();
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _sessions;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar('Riwayat Chat', actions: [
        if (sessions != null && sessions.isNotEmpty)
          IconButton(
              tooltip: 'Hapus semua',
              onPressed: _clearAll,
              icon: const Icon(Icons.delete_sweep_outlined)),
      ]),
      body: sessions == null
          ? const Center(child: CircularProgressIndicator())
          : sessions.isEmpty
              ? const EmptyState(
                  icon: Icons.forum_outlined,
                  title: 'Belum ada percakapan',
                  subtitle: 'Percakapan dengan Asisten Tani tersimpan di perangkat ini.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final s = sessions[i];
                    return Dismissible(
                      key: ValueKey(s.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                            color: Colors.red, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        setState(() => sessions.removeAt(i));
                        _service.deleteSession(s.id);
                      },
                      child: InkWell(
                        onTap: () => context.pop(s),
                        borderRadius: BorderRadius.circular(16),
                        child: InfoCard(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.green[50], shape: BoxShape.circle),
                                child: const Icon(Icons.chat, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text(s.preview,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${s.messages.length} pesan • ${DateFormat('dd MMM, HH:mm', 'id_ID').format(s.updatedAt)}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
