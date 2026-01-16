import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/supabase_service.dart';
import '../../data/services/weather_service.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/tip_model.dart';
import '../../data/models/forum_post_model.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/custom_showcase.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: (context) => const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  final _user = SupabaseService().currentUser;
  late Future<WeatherModel> _weatherFuture;
  late Future<List<Tip>> _tipsFuture;
  late Future<List<ForumPost>> _forumFuture;

  // Store profile for Header & Weather Display
  UserProfile? _userProfile;

  final WeatherService _weatherService = WeatherService();
  final SupabaseService _supabaseService = SupabaseService();

  // Tutorial Keys
  final GlobalKey _weatherKey = GlobalKey();
  final GlobalKey _tipsKey = GlobalKey();
  final GlobalKey _forumKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _weatherFuture = _fetchWeather();
    _tipsFuture = _supabaseService.getTips();
    _forumFuture = _supabaseService.getForumPosts();

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkTutorial());
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    // Use v3 key to force show for new design
    final bool isTutorialShown =
        prefs.getBool('dashboard_tutorial_shown_v3') ?? false;

    if (!isTutorialShown) {
      if (mounted) {
        ShowCaseWidget.of(context)
            .startShowCase([_weatherKey, _tipsKey, _forumKey]);
        await prefs.setBool('dashboard_tutorial_shown_v3', true);
      }
    }
  }

  void _refreshData() {
    setState(() {
      _weatherFuture = _fetchWeather();
      _tipsFuture = _supabaseService.getTips();
      _forumFuture = _supabaseService.getForumPosts();
    });
  }

  Future<WeatherModel> _fetchWeather() async {
    try {
      String? cityName;
      String? provinceName;
      String? displayLocation; // Untuk kecamatan

      try {
        final profile = await _supabaseService.getUserProfile();
        if (profile != null) {
          if (mounted) {
            setState(() {
              _userProfile = profile;
            });
          }
          cityName = profile.kota;
          provinceName = profile.provinsi;
          displayLocation = profile.kecamatan;
        }
      } catch (e) {
        debugPrint("Error fetching profile: $e");
      }

      final locationQuery =
          cityName != null && cityName.isNotEmpty ? cityName : 'Semarang';

      // Fetch cuaca berdasarkan Kota (lebih akurat untuk pencarian API)
      WeatherModel weather;
      try {
        weather = await _weatherService.getWeatherByCity(locationQuery);
      } catch (e) {
        debugPrint(
            "DEBUG: Failed to fetch by City '$locationQuery'. Trying Province...");
        // Fallback to Province if City fails (e.g. Gunung Kidul issue)
        if (provinceName != null && provinceName.isNotEmpty) {
          try {
            weather = await _weatherService.getWeatherByCity(provinceName);
          } catch (e2) {
            debugPrint("DEBUG: Failed to fetch by Province '$provinceName'.");
            rethrow; // If province also fails, show error state
          }
        } else {
          rethrow; // If no province available, show error state
        }
      }

      // Override nama kota di model dengan Kecamatan untuk tampilan UI (sesuai request)
      if (displayLocation != null && displayLocation.isNotEmpty) {
        return WeatherModel(
            cityName: displayLocation,
            temperature: weather.temperature,
            description: weather.description,
            iconCode: weather.iconCode);
      }

      return weather;
    } catch (e) {
      debugPrint("Error fetching weather: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Construct location string for Header
    String locationString = "Lokasi belum diatur";
    if (_userProfile != null) {
      final parts = [
        _userProfile?.kecamatan != null
            ? "Kec. ${_userProfile!.kecamatan}"
            : null,
        _userProfile?.kota,
        _userProfile?.provinsi
      ].whereType<String>().toList();

      if (parts.isNotEmpty) {
        locationString = parts.join(", ");
      }
    } else if (_user?.userMetadata?['lokasi'] != null) {
      locationString = _user!.userMetadata!['lokasi'];
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // No standard AppBar, Custom Header like Web
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refreshData(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80), // Space for FAB/Nav
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Like Web)
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getGreeting(),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        _userProfile?.nama ??
                            _user?.userMetadata?['nama'] ??
                            'Petani Maju',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              locationString,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Weather Card
                      CustomShowcase(
                        showcaseKey: _weatherKey,
                        title: 'Prediksi Cuaca',
                        description:
                            'Cek kondisi cuaca dan rekomendasi tanam di sini.',
                        child: _buildWeatherCard(),
                      ),

                      const SizedBox(height: 24),

                      // Quick Access Grid (2 Columns like web)
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                        children: [
                          _buildQuickAccess(context, "Cuaca", Icons.wb_sunny,
                              Colors.blue, '/cuaca'),
                          _buildQuickAccess(context, "Info Hama",
                              Icons.bug_report, Colors.red, '/hama'),
                          _buildQuickAccess(context, "Kalender",
                              Icons.calendar_month, Colors.green, '/calendar'),
                          _buildQuickAccess(context, "Video",
                              Icons.play_circle_fill, Colors.purple, '/videos'),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Tips Section (Horizontal Scroll)
                      CustomShowcase(
                        showcaseKey: _tipsKey,
                        title: 'Tips Harian',
                        description:
                            'Dapatkan ilmu bertani terbaru setiap hari.',
                        child: _buildSectionHeader("Tips Hari Ini",
                            "Lihat Semua", () => context.push('/tips')),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 240,
                        child: FutureBuilder<List<Tip>>(
                          future: _tipsFuture,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return const Center(
                                  child: CircularProgressIndicator());
                            final tips = snapshot.data!.take(5).toList();
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: tips.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 16),
                              itemBuilder: (context, index) =>
                                  _buildTipCard(tips[index]),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Forum Section (Vertical)
                      CustomShowcase(
                        showcaseKey: _forumKey,
                        title: 'Forum Diskusi',
                        description:
                            'Tanya jawab dan berbagi pengalaman dengan petani lain.',
                        isLast: true,
                        child: _buildSectionHeader("Diskusi Terbaru",
                            "Lihat Forum", () => context.push('/forum')),
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<ForumPost>>(
                        future: _forumFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox.shrink();
                          final posts = snapshot.data!.take(3).toList();
                          return Column(
                            children: posts
                                .map((post) => _buildForumCard(post))
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return FutureBuilder<WeatherModel>(
      future: _weatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
              child: SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator())));
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 8),
                Text(
                  "Gagal memuat cuaca",
                  style: TextStyle(
                      color: Colors.red[900], fontWeight: FontWeight.bold),
                ),
                Text(
                  "Cek koneksi atau lokasi anda",
                  style: TextStyle(color: Colors.red[700], fontSize: 12),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _refreshData,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text("Coba Lagi"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                )
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final weather = snapshot.data!;
        return InkWell(
          onTap: () => context.push('/cuaca', extra: weather),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF22C55E), Color(0xFF3B82F6)], // Green to Blue
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5)),
              ],
            ),
            child: Stack(
              children: [
                // Decorative blur circle (mocked with simple container for now)
                Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle))),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wb_sunny,
                            color: Colors.yellow,
                            size: 24), // Mock Condition Icon
                        const SizedBox(width: 8),
                        const Text("Cuaca Hari Ini",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text("${weather.temperature.toStringAsFixed(1)}°C",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("${weather.description} • ${weather.cityName}",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Lihat prakiraan lengkap",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                        Icon(Icons.arrow_forward,
                            color: Colors.white, size: 16),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAccess(BuildContext context, String title, IconData icon,
      Color color, String route) {
    return InkWell(
      onTap: () => context.push(route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(title,
                style: TextStyle(
                    color: Colors.grey[800], fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(Tip tip) {
    return InkWell(
      onTap: () => context.push('/tips/detail', extra: tip),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: tip.imageUrl ?? 'https://placehold.co/600x400',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 120,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 120,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tip.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(tip.kategori,
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForumCard(ForumPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.comment, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text("${post.likes} Diskusi",
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey)), // Mock 'likes' as interaction count
              const SizedBox(width: 12),
              Text(DateFormat('dd MMM yyyy').format(post.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, String action, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        InkWell(
            onTap: onAction,
            child: Text(action,
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF166534),
                    fontWeight: FontWeight.bold))),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return "Selamat Pagi,";
    if (hour < 15) return "Selamat Siang,";
    if (hour < 18) return "Selamat Sore,";
    return "Selamat Malam,";
  }
}
