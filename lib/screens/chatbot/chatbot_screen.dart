import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/env.dart';
import '../../data/models/chat_models.dart';
import '../../data/services/chat_service.dart';
import '../../data/services/premium_service.dart';
import '../../widgets/app_ui.dart';
import 'chat_bubble.dart';

/// [initial] boleh berupa `String` (pertanyaan awal) atau `ChatSession`
/// (lanjutkan percakapan dari riwayat).
class ChatbotScreen extends StatefulWidget {
  final Object? initial;
  const ChatbotScreen({super.key, this.initial});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _chat = ChatService();
  final _premium = PremiumService();
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _picker = ImagePicker();

  late ChatSession _session;
  ChatContext _context = const ChatContext();
  String? _attachedImage;
  bool _sending = false;
  bool _isPremium = false;
  int _remaining = PremiumService.freeDailyChatQuota;
  StreamSubscription<String>? _sub;

  static const _suggestions = [
    'Kapan waktu terbaik memupuk padi?',
    'Cara mengatasi wereng coklat secara organik',
    'Apakah hari ini cocok untuk menyiram?',
    'Rekomendasi fungisida untuk bercak daun cabai',
  ];

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    _session = init is ChatSession ? init : _newSession();
    _loadMeta();
    _chat.loadContext().then((c) {
      if (mounted) _context = c;
    });
    if (init is String && init.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(text: init));
    }
  }

  ChatSession _newSession() {
    final now = DateTime.now();
    return ChatSession(
      id: 'chat_${now.millisecondsSinceEpoch}',
      title: 'Konsultasi Baru',
      createdAt: now,
      updatedAt: now,
      messages: const [],
    );
  }

  Future<void> _loadMeta() async {
    final status = await _premium.getStatus();
    final remaining = await _premium.remainingFreeChats();
    if (mounted) {
      setState(() {
        _isPremium = status.isActive;
        _remaining = remaining;
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  void _snack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
        source: source, imageQuality: 60, maxWidth: 1080, maxHeight: 1080);
    if (picked == null) return;
    final error = _chat.validateImage(File(picked.path));
    if (error != null) {
      _snack(error, color: Colors.red);
      return;
    }
    setState(() => _attachedImage = picked.path);
  }

  Future<void> _showUpgradeDialog() async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.workspace_premium, color: Colors.amber, size: 40),
        title: const Text('Kuota Chat Gratis Habis'),
        content: const Text(
            'Akun gratis dapat ${PremiumService.freeDailyChatQuota} jawaban Asisten Tani per hari. '
            'Kuota terisi ulang besok. Upgrade ke PetaniMaju PRO untuk konsultasi tanpa batas.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Nanti Saja')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Lihat PRO'),
          ),
        ],
      ),
    );
    if (go == true && mounted) {
      await context.push('/premium');
      _loadMeta();
    }
  }

  Future<void> _send({String? text}) async {
    if (_sending) return;
    if (!Env.hasGeminiKey) {
      _snack('Asisten Tani belum aktif: GEMINI_API_KEY belum diatur.', color: Colors.red);
      return;
    }

    final raw = text ?? _input.text;
    final image = _attachedImage;
    if (raw.trim().isEmpty && image == null) return;

    final clean = _chat.sanitizeInput(raw);
    if (raw.trim().isNotEmpty && clean.isEmpty) {
      _snack('Pesan tidak dapat diproses. Coba tulis ulang pertanyaan seputar pertanian.',
          color: Colors.orange);
      return;
    }

    if (!await _premium.canChat()) {
      _showUpgradeDialog();
      return;
    }

    final now = DateTime.now();
    final userMsg = ChatMessage(
      id: 'u_${now.microsecondsSinceEpoch}',
      role: MessageRole.user,
      content: clean,
      timestamp: now,
      imagePath: image,
    );
    final botMsg = ChatMessage(
      id: 'b_${now.microsecondsSinceEpoch}',
      role: MessageRole.bot,
      content: '',
      timestamp: now,
      isStreaming: true,
    );

    final isFirst = _session.messages.isEmpty;
    setState(() {
      _sending = true;
      _input.clear();
      _attachedImage = null;
      _session = _session.copyWith(
        title: isFirst
            ? (clean.isNotEmpty
                ? (clean.length > 40 ? '${clean.substring(0, 40)}...' : clean)
                : 'Analisis Foto Tanaman')
            : null,
        messages: [..._session.messages, userMsg, botMsg],
        updatedAt: now,
      );
    });
    _scrollToBottom();

    final history = _session.messages.where((m) => m.id != botMsg.id).toList();
    var buffer = '';
    final completer = Completer<void>();

    _sub = _chat.send(messages: history, context: _context).listen(
      (chunk) {
        buffer += chunk;
        _updateBot(botMsg.id, buffer, streaming: true);
        _scrollToBottom();
      },
      onError: (e) {
        _updateBot(botMsg.id,
            '⚠️ Maaf, Asisten Tani sedang tidak bisa menjawab.\n\n_${e.toString().replaceFirst('Exception: ', '')}_',
            streaming: false, error: true);
        completer.complete();
      },
      onDone: () {
        if (!completer.isCompleted) {
          if (buffer.trim().isEmpty) {
            _updateBot(botMsg.id, '⚠️ Asisten Tani tidak memberi jawaban. Coba ulangi.',
                streaming: false, error: true);
            completer.complete();
            return;
          }
          _updateBot(botMsg.id, buffer, streaming: false);
          _premium.consumeChat().then((_) => _loadMeta());
          completer.complete();
        }
      },
      cancelOnError: true,
    );

    await completer.future;
    if (!mounted) return;
    setState(() => _sending = false);
    await _chat.saveSession(_session);
  }

  void _updateBot(String id, String content, {required bool streaming, bool error = false}) {
    if (!mounted) return;
    setState(() {
      _session = _session.copyWith(
        messages: _session.messages
            .map((m) => m.id == id
                ? m.copyWith(content: content, isStreaming: streaming, isError: error)
                : m)
            .toList(),
      );
    });
  }

  void _startNewChat() {
    if (_sending) return;
    setState(() => _session = _newSession());
  }

  Future<void> _openHistory() async {
    if (_sending) return;
    final selected = await context.push<ChatSession>('/asisten/riwayat');
    if (selected != null && mounted) {
      setState(() => _session = selected);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFDCFCE7),
              child: Icon(Icons.eco, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Asisten Tani',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  _isPremium ? 'PRO • Tanpa batas' : 'Sisa $_remaining chat gratis hari ini',
                  style: TextStyle(
                      fontSize: 11,
                      color: _isPremium ? Colors.amber[800] : Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
              tooltip: 'Riwayat chat',
              onPressed: _openHistory,
              icon: const Icon(Icons.history)),
          IconButton(
              tooltip: 'Chat baru',
              onPressed: _startNewChat,
              icon: const Icon(Icons.add_comment_outlined)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _session.messages.isEmpty
                ? _buildWelcome()
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: _session.messages.length,
                    itemBuilder: (_, i) => ChatBubble(
                      message: _session.messages[i],
                      onPrompt: (p) => _send(text: p),
                    ),
                  ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryLight, AppColors.accentBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.support_agent, color: Colors.white, size: 36),
              const SizedBox(height: 12),
              Text('Halo, Petani! 👋',
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text(
                'Tanya apa saja seputar budidaya, hama, obat, cuaca, atau minta dibuatkan jadwal tanam. '
                'Kamu juga bisa kirim foto tanaman.',
                style: TextStyle(color: Colors.white, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Coba tanyakan:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _send(text: s),
                borderRadius: BorderRadius.circular(16),
                child: InfoCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(children: [
                    const Icon(Icons.chat_bubble_outline,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text(s)),
                  ]),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_attachedImage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 8),
                child: Row(children: [
                  Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(_attachedImage!),
                          width: 64, height: 64, fit: BoxFit.cover),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: InkWell(
                        onTap: () => setState(() => _attachedImage = null),
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.close, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ]),
                ]),
              ),
            Row(
              children: [
                PopupMenuButton<ImageSource>(
                  tooltip: 'Lampirkan foto',
                  icon: const Icon(Icons.add_photo_alternate_outlined,
                      color: AppColors.primary),
                  enabled: !_sending,
                  onSelected: _pickImage,
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: ImageSource.camera,
                        child: ListTile(
                            leading: Icon(Icons.camera_alt), title: Text('Kamera'))),
                    PopupMenuItem(
                        value: ImageSource.gallery,
                        child: ListTile(
                            leading: Icon(Icons.photo_library), title: Text('Galeri'))),
                  ],
                ),
                Expanded(
                  child: TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: ChatService.maxInputLength,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Tulis pertanyaan...',
                      counterText: '',
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton.filled(
                  onPressed: _sending ? null : () => _send(),
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
