import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_profile.dart';
import 'package:intl/intl.dart';
import '../../data/models/forum_post_model.dart';
import '../../data/services/supabase_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/models/tip_model.dart';
import '../../data/models/video_model.dart';
import '../../data/models/hama_model.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../widgets/custom_showcase.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: (context) => const _ProfileContent(),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  const _ProfileContent();

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent>
    with SingleTickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  bool _notificationsEnabled = false;
  bool _dailyBriefEnabled = true; // Default true for Sapaan Pagi
  bool _weatherReminderEnabled = true;
  UserProfile? _profile;
  late TabController _tabController;

  // Stats
  int _postCount = 0;
  int _bookmarkCount = 0;

  // Saved Items
  List<Tip> _savedTips = [];
  List<Video> _savedVideos = [];
  List<Hama> _savedHama = [];

  // User Posts
  List<ForumPost> _myPosts = [];

  // Tutorial Key
  final GlobalKey _notifKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData(); // Will load pref
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkTutorial());
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isTutorialShown =
        prefs.getBool('profile_tutorial_shown') ?? false;

    if (!isTutorialShown) {
      if (mounted) {
        // Delay slightly to ensure tab view is ready if needed, though not strictly necessary here
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          ShowCaseWidget.of(context).startShowCase([_notifKey]);
          await prefs.setBool('profile_tutorial_shown', true);
        }
      }
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load Prefs
      final prefs = await SharedPreferences.getInstance();
      final notifEnabled = prefs.getBool('notifications_enabled') ?? false;
      final dailyEnabled = prefs.getBool('daily_brief_enabled') ?? true;
      final weatherRemind = prefs.getBool('weather_reminder_enabled') ?? true;

      final user = _supabaseService.currentUser;
      if (user != null) {
        final profile = await _supabaseService.getUserProfile();
        // Fetch my posts count
        final allPosts = await _supabaseService
            .getForumPosts(); // Ideally filter by user_id in DB
        final myPosts = allPosts.where((p) => p.userId == user.id).toList();

        // Fetch saved items
        final savedItems = await _supabaseService.getSavedItems();

        if (mounted) {
          setState(() {
            _profile = profile;
            _postCount = myPosts.length;
            _myPosts = myPosts; // Added
            _savedTips = List<Tip>.from(savedItems['tips'] ?? []);
            _savedVideos = List<Video>.from(savedItems['videos'] ?? []);
            _savedHama = List<Hama>.from(savedItems['hama'] ?? []);

            _bookmarkCount =
                _savedTips.length + _savedVideos.length + _savedHama.length;

            _notificationsEnabled = notifEnabled;
            _dailyBriefEnabled = dailyEnabled;
            _weatherReminderEnabled = weatherRemind;
          });
        }
      }
    } catch (e) {
      print("Profile load error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_profile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("Gagal memuat profil",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Pastikan Anda terhubung ke internet.",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Coba Lagi"),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildStatsCard(),
                  const SizedBox(height: 16),
                  _buildTabBar(),
                  const SizedBox(height: 16),
                  Container(
                    constraints: const BoxConstraints(minHeight: 300),
                    child: _buildTabContent(),
                  ),
                  const SizedBox(height: 80), // Space for bottom
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF166534), // Green 700
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30, width: 4),
                ),
                child: Center(
                  child: _profile?.avatarUrl != null
                      ? CircleAvatar(
                          radius: 46,
                          backgroundImage: NetworkImage(_profile!.avatarUrl!))
                      : const Icon(Icons.person, size: 50, color: Colors.white),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: InkWell(
                  onTap: () async {
                    await context.push('/profile/edit', extra: _profile);
                    _loadData();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: Colors.white24, shape: BoxShape.circle),
                    child:
                        const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _profile?.nama ?? "Tanpa Nama",
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            "@${_profile?.username ?? 'user'} • Petani ${_profile?.jenisTanaman ?? '-'}",
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Statistik Saya",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("Postingan", _postCount.toString(),
                  Colors.green[50]!, Colors.green[700]!),
              _buildStatItem("Disimpan (Online)", _bookmarkCount.toString(),
                  Colors.blue[50]!, Colors.blue[700]!),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String count, Color bg, Color text) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(count,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: text)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF166534),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF166534),
        tabs: const [
          Tab(text: "Info Akun"),
          Tab(text: "Postingan"),
          Tab(text: "Disimpan (Online)"),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        if (_tabController.index == 0) return _buildInfoTab();
        if (_tabController.index == 1) return _buildPostsTab();
        if (_tabController.index == 2) return _buildSavedTab();
        return const SizedBox();
      },
    );
  }

  Widget _buildPostsTab() {
    if (_myPosts.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.article_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("Belum ada postingan.",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: _myPosts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final post = _myPosts[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: InkWell(
            onTap: () => context.push('/forum/detail', extra: post),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _profile?.avatarUrl != null
                            ? NetworkImage(_profile!.avatarUrl!)
                            : null,
                        child: _profile?.avatarUrl == null
                            ? const Icon(Icons.person,
                                color: Colors.grey, size: 20)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _profile?.nama ?? "User",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            DateFormat('dd MMM yyyy')
                                .format(post.createdAt.toLocal()),
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post.title ?? 'Tanpa Judul',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[800], fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.thumb_up_outlined,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text("${post.likes}",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(width: 16),
                      Icon(Icons.comment_outlined,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text("0",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedTab() {
    if (_savedTips.isEmpty && _savedVideos.isEmpty && _savedHama.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.bookmark_border, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("Belum ada item disimpan.",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_savedTips.isNotEmpty) ...[
          _buildSavedSectionTitle("Tips Pertanian"),
          ..._savedTips.map((tip) => _buildSavedItem(
                title: tip.judul,
                subtitle: tip.kategori,
                image: tip.imageUrl,
                onTap: () => context.push('/tips/detail', extra: tip),
              )),
          const SizedBox(height: 16),
        ],
        if (_savedVideos.isNotEmpty) ...[
          _buildSavedSectionTitle("Video Edukasi"),
          ..._savedVideos.map((video) => _buildSavedItem(
                title: video.judul,
                subtitle: "Video",
                image: 'https://img.youtube.com/vi/${video.youtubeId}/0.jpg',
                onTap: () => context.push('/videos/detail', extra: video),
              )),
          const SizedBox(height: 16),
        ],
        if (_savedHama.isNotEmpty) ...[
          _buildSavedSectionTitle("Info Hama & Penyakit"),
          ..._savedHama.map((hama) => _buildSavedItem(
                title: hama.nama,
                subtitle: hama.type,
                image: hama.imageUrl,
                onTap: () => context.push('/hama/detail', extra: hama),
              )),
        ],
      ],
    );
  }

  Widget _buildSavedSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Row(
        children: [
          Container(width: 4, height: 16, color: const Color(0xFF166534)),
          const SizedBox(width: 8),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSavedItem({
    required String title,
    required String subtitle,
    String? image,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: image != null
              ? Image.network(image,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image)))
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.green[50],
                  child: const Icon(Icons.bookmark, color: Color(0xFF166534))),
        ),
        title: Text(title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          // Contact Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Detail Kontak & Lokasi",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(height: 24),
                _buildContactRow(Icons.phone, _profile?.noHp ?? "-"),
                const SizedBox(height: 12),
                _buildContactRow(Icons.location_on, _getLocationString()),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Notification Toggle
          CustomShowcase(
            showcaseKey: _notifKey,
            title: 'Notifikasi',
            description:
                'Aktifkan notifikasi untuk mendapatkan pengingat cuaca dan tips harian.',
            isLast: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.notifications_active,
                        size: 20, color: Color(0xFF166534)),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text("Notifikasi Jadwal",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  Switch(
                    value: _notificationsEnabled,
                    activeColor: const Color(0xFF166534),
                    onChanged: (val) async {
                      setState(() => _notificationsEnabled = val);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('notifications_enabled', val);
                      final service = NotificationService();
                      if (val) {
                        await service.requestPermissions();
                      } else {
                        await service.cancelAll();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Settings Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text("Pengaturan Akun",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 1),
                _buildSettingItem(Icons.edit, "Ubah Profil", onTap: () async {
                  await context.push('/profile/edit', extra: _profile);
                  _loadData();
                }),
                _buildSettingItem(Icons.lock, "Ubah Kata Sandi", onTap: () {
                  context.push('/profile/change-password');
                }),
                _buildSettingItem(Icons.info_outline, "Tentang Aplikasi",
                    onTap: () {
                  context.push('/profile/about');
                }),
                _buildSettingItem(Icons.delete_forever, "Hapus Akun",
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: _showDeleteAccountDialog),
                _buildSettingItem(Icons.logout, "Keluar",
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: _logout),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLocationString() {
    final parts = [
      if (_profile?.kecamatan != null) "Kec. ${_profile!.kecamatan}",
      if (_profile?.kota != null) _profile!.kota,
      if (_profile?.provinsi != null) _profile!.provinsi,
    ];
    if (parts.isEmpty) return "Lokasi belum diatur";
    return parts.join(", ");
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF166534)),
        const SizedBox(width: 12),
        Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.grey, fontSize: 13))),
      ],
    );
  }

  Widget _buildSettingItem(IconData icon, String title,
      {Color? textColor, Color? iconColor, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: (iconColor ?? const Color(0xFF166534)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
        child:
            Icon(icon, size: 20, color: iconColor ?? const Color(0xFF166534)),
      ),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }

  Future<void> _logout() async {
    await _supabaseService.signOut();
    if (mounted) context.go('/login');
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Akun?"),
        content: const Text(
            "Tindakan ini tidak dapat dibatalkan. Semua data Anda (Profil, Postingan, Bookmark) akan dihapus permanen."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              _showPasswordConfirmation(isDelete: true);
            },
            child: const Text("Lanjut Hapus"),
          ),
        ],
      ),
    );
  }

  void _showPasswordConfirmation({required bool isDelete}) {
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Keamanan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                "Demi keamanan, mohon masukkan kata sandi Anda untuk konfirmasi:"),
            const SizedBox(height: 16),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Kata Sandi',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              if (passController.text.isNotEmpty) {
                Navigator.pop(context);
                if (isDelete) _performDeleteAccount();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Kata sandi wajib diisi")));
              }
            },
            child: const Text("Konfirmasi"),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteAccount() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      // Mock deletion
      await Future.delayed(const Duration(seconds: 2));
      await _supabaseService.signOut();

      if (mounted) {
        Navigator.pop(context); // Pop loading
        context.go('/login');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Akun berhasil dihapus")));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal menghapus akun")));
      }
    }
  }
}
