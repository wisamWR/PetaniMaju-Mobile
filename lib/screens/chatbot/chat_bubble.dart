import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/models/chat_models.dart';
import '../../data/models/drug_model.dart';
import '../../data/services/drug_service.dart';
import '../../data/services/supabase_service.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/drug_mini_card.dart';
import 'chat_parser.dart';
import '../../core/weather_icons.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<String> onPrompt;

  const ChatBubble({super.key, required this.message, required this.onPrompt});

  bool get _isUser => message.role == MessageRole.user;

  void _handleAction(BuildContext context, ChatAction action) {
    if (action.isPrompt) {
      onPrompt(action.prompt);
      return;
    }
    switch (action.target) {
      case 'drugs':
        context.push('/obat');
        break;
      case 'calendar':
        context.push('/calendar');
        break;
      case 'scanner':
        context.push('/scan');
        break;
      case 'weather':
        context.push('/cuaca');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUser) return _buildUser(context);
    return _buildBot(context);
  }

  Widget _buildUser(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 48),
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.imagePath != null && File(message.imagePath!).existsSync())
              Padding(
                padding: EdgeInsets.only(bottom: message.content.isEmpty ? 0 : 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(message.imagePath!),
                      width: 200, height: 160, fit: BoxFit.cover),
                ),
              ),
            if (message.content.isNotEmpty)
              Text(message.content, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Text(DateFormat('HH:mm').format(message.timestamp),
                style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildBot(BuildContext context) {
    if (message.isStreaming && message.content.isEmpty) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: _TypingIndicator(),
      );
    }

    final parsed = ChatParser.parse(message.content, streaming: message.isStreaming);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFDCFCE7),
              child: Icon(Icons.eco, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message.isError ? Colors.red[50] : Colors.white,
                      border: Border.all(
                          color: message.isError ? Colors.red[200]! : Colors.grey[200]!),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: MarkdownBody(
                      data: parsed.text.isEmpty ? '...' : parsed.text,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                            color: message.isError ? Colors.red[900] : Colors.grey[850],
                            fontSize: 14,
                            height: 1.45),
                      ),
                    ),
                  ),
                  if (!message.isStreaming) ...[
                    if (parsed.weather != null) ...[
                      const SizedBox(height: 8),
                      WeatherRecommendationCard(data: parsed.weather!),
                    ],
                    if (parsed.schedules.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ScheduleProposalCard(schedules: parsed.schedules),
                    ],
                    if (parsed.drugNames.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _RecommendedDrugs(names: parsed.drugNames),
                    ],
                    if (parsed.actions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: parsed.actions
                            .map((a) => ActionChip(
                                  label: Text(a.label,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600)),
                                  backgroundColor: Colors.green[50],
                                  side: BorderSide(color: Colors.green[200]!),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  onPressed: () => _handleAction(context, a),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedDrugs extends StatelessWidget {
  final List<String> names;
  const _RecommendedDrugs({required this.names});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Drug>>(
      future: DrugService().findByNames(names),
      builder: (_, snap) {
        final drugs = snap.data ?? [];
        if (drugs.isEmpty) return const SizedBox.shrink();
        return DrugMiniList(drugs: drugs);
      },
    );
  }
}

class WeatherRecommendationCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const WeatherRecommendationCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    String v(String key) => (data[key] ?? '-').toString();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.accentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(WeatherIcons.iconForText(v('kondisi')),
                color: WeatherIcons.colorForText(v('kondisi')), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(v('lokasi'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Text(v('suhu'),
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 4),
          Text('${v('kondisi')} • Kelembapan ${v('kelembapan')}',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const Divider(color: Colors.white24, height: 20),
          _row(Icons.water_drop, 'Irigasi', v('rekomendasi_irigasi')),
          const SizedBox(height: 6),
          _row(Icons.grass, 'Pemupukan', v('saran_pemupukan')),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(TextSpan(children: [
            TextSpan(
                text: '$label: ',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            TextSpan(text: value, style: const TextStyle(color: Colors.white)),
          ]), style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}

class ScheduleProposalCard extends StatefulWidget {
  final List<ProposedSchedule> schedules;
  const ScheduleProposalCard({super.key, required this.schedules});

  @override
  State<ScheduleProposalCard> createState() => _ScheduleProposalCardState();
}

class _ScheduleProposalCardState extends State<ScheduleProposalCard> {
  bool _saving = false;
  bool _saved = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      for (final s in widget.schedules) {
        await SupabaseService().createCalendarEvent(
          title: s.title,
          date: s.date,
          type: s.type,
          notes: s.notes,
          notificationTime: TimeOfDay(hour: s.date.hour, minute: s.date.minute),
        );
      }
      if (mounted) setState(() => _saved = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal menyimpan jadwal: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      borderColor: Colors.green[200],
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text('Usulan Jadwal Tanam', style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          ...widget.schedules.map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.green[50], borderRadius: BorderRadius.circular(4)),
                      child: Text(s.type,
                          style: const TextStyle(fontSize: 10, color: AppColors.primary)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.title,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(DateFormat('EEE, dd MMM yyyy • HH:mm', 'id_ID').format(s.date),
                              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: _saved
                ? OutlinedButton.icon(
                    onPressed: () => context.push('/calendar'),
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    label: const Text('Tersimpan • Lihat Kalender'),
                  )
                : FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.add_task),
                    label: Text('Simpan ${widget.schedules.length} Jadwal'),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 40),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = ((_c.value * 3) - i).clamp(0.0, 1.0);
            final opacity = 0.3 + 0.7 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: opacity,
                child: const CircleAvatar(radius: 4, backgroundColor: AppColors.primary),
              ),
            );
          }),
        ),
      ),
    );
  }
}
