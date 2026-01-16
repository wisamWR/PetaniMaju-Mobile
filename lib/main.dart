import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import 'core/constants.dart';
import 'data/models/weather_model.dart';
import 'data/models/tip_model.dart';
import 'data/models/hama_model.dart';
import 'data/models/video_model.dart';
import 'data/models/forum_post_model.dart';
import 'data/models/user_profile.dart';

import 'data/services/notification_service.dart';
import 'data/services/supabase_service.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/tips/tips_list_screen.dart';
import 'screens/tips/tips_detail_screen.dart';
import 'screens/hama/hama_list_screen.dart';
import 'screens/hama/hama_detail_screen.dart';
import 'screens/video/video_list_screen.dart';
import 'screens/video/video_detail_screen.dart';
import 'screens/forum/forum_list_screen.dart';
import 'screens/forum/forum_create_screen.dart';
import 'screens/forum/forum_detail_screen.dart';
import 'screens/weather/weather_detail_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/profile_edit_screen.dart';
import 'screens/profile/change_password_screen.dart';
import 'screens/profile/about_screen.dart';
import 'widgets/scaffold_with_navbar.dart';

// Router Config
final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
        path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen()),

    // ShellRoute for BottomNav
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen()),
        GoRoute(
            path: '/tips',
            builder: (context, state) => const TipsListScreen(),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) {
                  final tip = state.extra as Tip;
                  return TipsDetailScreen(tip: tip);
                },
              ),
            ]),
        GoRoute(
            path: '/hama',
            builder: (context, state) => const HamaListScreen(),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) {
                  final hama = state.extra as Hama;
                  return HamaDetailScreen(hama: hama);
                },
              ),
            ]),
        GoRoute(
            path: '/videos',
            builder: (context, state) => const VideoListScreen(),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) {
                  final video = state.extra as Video;
                  return VideoDetailScreen(video: video);
                },
              ),
            ]),
        GoRoute(
            path: '/forum',
            builder: (context, state) => const ForumListScreen(),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) {
                  final post = state.extra as ForumPost;
                  return ForumDetailScreen(post: post);
                },
              ),
            ]),
        GoRoute(
            path: '/forum/create',
            builder: (context, state) => const ForumCreateScreen()),
        GoRoute(
            path: '/calendar',
            builder: (context, state) => const CalendarScreen()),
        GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                  path: 'edit',
                  builder: (context, state) =>
                      ProfileEditScreen(profile: state.extra as UserProfile?)),
              GoRoute(
                  path: 'change-password',
                  builder: (context, state) => const ChangePasswordScreen()),
              GoRoute(
                  path: 'about',
                  builder: (context, state) => const AboutScreen()),
            ]),
        GoRoute(
          path: '/cuaca',
          builder: (context, state) {
            WeatherModel? weather;
            if (state.extra is WeatherModel) {
              weather = state.extra as WeatherModel;
            } else if (state.extra is Map) {
              try {
                weather =
                    WeatherModel.fromJson(state.extra as Map<String, dynamic>);
              } catch (_) {}
            }
            return WeatherDetailScreen(weather: weather);
          },
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggingIn = state.uri.toString() == '/login' ||
        state.uri.toString() == '/register' ||
        state.uri.toString() == '/onboarding';

    if (session != null && isLoggingIn) {
      return '/dashboard';
    }
    return null;
  },
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  await initializeDateFormatting('id_ID', null);

  // Init Notifications
  final notificationService = NotificationService();
  await notificationService.init(
    onNotificationTap: (payload) {
      if (payload == 'weather') {
        _router.go('/cuaca');
      } else if (payload == 'dashboard') {
        _router.go('/dashboard');
      } else {
        _router.go('/calendar');
      }
    },
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<SupabaseService>(create: (_) => SupabaseService()),
      ],
      child: const PetaniMajuApp(),
    ),
  );
}

// Global Key for SnackBars
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

// ... main() ...

class PetaniMajuApp extends StatefulWidget {
  const PetaniMajuApp({super.key});

  @override
  State<PetaniMajuApp> createState() => _PetaniMajuAppState();
}

class _PetaniMajuAppState extends State<PetaniMajuApp> {
  StreamSubscription? _connectivitySubscription;
  bool? _lastOnlineStatus;

  @override
  void initState() {
    super.initState();

    // Initial check to set baseline status without showing notification
    Connectivity().checkConnectivity().then((result) {
      if (!mounted) return;
      bool isOnline = _parseConnectivityStatus(result);
      setState(() => _lastOnlineStatus = isOnline);
    });

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((dynamic result) {
      bool isOnline = _parseConnectivityStatus(result);

      // Only show notification if status indicates a CHANGE from a known previous state
      if (_lastOnlineStatus != null && _lastOnlineStatus != isOnline) {
        _showConnectionSnackBar(isOnline);
      }
      _lastOnlineStatus = isOnline;
    });
  }

  bool _parseConnectivityStatus(dynamic result) {
    if (result is List<ConnectivityResult>) {
      return !result.contains(ConnectivityResult.none);
    } else if (result is ConnectivityResult) {
      return result != ConnectivityResult.none;
    }
    return false;
  }

  void _showConnectionSnackBar(bool isOnline) {
    // Only show if key is attached
    if (rootScaffoldMessengerKey.currentState != null) {
      rootScaffoldMessengerKey.currentState!.clearSnackBars();
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(isOnline ? Icons.wifi : Icons.wifi_off, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isOnline
                      ? "Terhubung ke internet"
                      : "Koneksi internet terputus",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: isOnline ? Colors.green[700] : Colors.red[700],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'Petani Maju',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF166534)),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
