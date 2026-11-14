import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumPlan {
  final String id;
  final String name;
  final int price;
  final int days;
  final String? badge;

  const PremiumPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.days,
    this.badge,
  });
}

class PremiumStatus {
  final bool isActive;
  final String? plan;
  final DateTime? until;

  const PremiumStatus({this.isActive = false, this.plan, this.until});
}

class PaymentOrder {
  final String orderId;
  final String redirectUrl;
  PaymentOrder({required this.orderId, required this.redirectUrl});
}

/// Langganan PetaniMaju PRO.
///
/// Status premium disimpan di tabel `user_premium` dan hanya bisa diubah oleh
/// Edge Function (service role) setelah pembayaran diverifikasi ke Midtrans.
class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  static const int freeDailyChatQuota = 3;

  /// Harga final ditentukan server; daftar ini untuk tampilan saja.
  static const List<PremiumPlan> plans = [
    PremiumPlan(id: 'monthly', name: 'PRO Bulanan', price: 15000, days: 30),
    PremiumPlan(
        id: 'yearly',
        name: 'PRO Tahunan',
        price: 150000,
        days: 365,
        badge: 'Hemat 17%'),
  ];

  static const List<String> benefits = [
    'Konsultasi Asisten Tani tanpa batas',
    'Analisis foto tanaman lewat chat',
    'Prioritas fitur baru',
    'Dukung pengembangan PetaniMaju',
  ];

  SupabaseClient get _client => Supabase.instance.client;

  PremiumStatus? _cached;
  String? _cachedUserId;

  Future<PremiumStatus> getStatus({bool refresh = false}) async {
    final user = _client.auth.currentUser;
    if (user == null) return const PremiumStatus();
    if (_cached != null && !refresh && _cachedUserId == user.id) return _cached!;
    _cachedUserId = user.id;
    try {
      final data = await _client
          .from('user_premium')
          .select('is_premium, premium_until, premium_plan')
          .eq('user_id', user.id)
          .maybeSingle();
      final until = DateTime.tryParse(data?['premium_until'] ?? '');
      final active = (data?['is_premium'] == true) &&
          (until == null || until.isAfter(DateTime.now()));
      _cached = PremiumStatus(
          isActive: active, plan: data?['premium_plan'], until: until);
    } catch (e) {
      debugPrint('PremiumService: gagal cek status: $e');
      _cached = const PremiumStatus();
    }
    return _cached!;
  }

  // --- Kuota chat gratis ---

  String _quotaKey() {
    final uid = _client.auth.currentUser?.id ?? 'guest';
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return 'chat_quota_${uid}_$today';
  }

  Future<int> remainingFreeChats() async {
    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getInt(_quotaKey()) ?? 0;
    return (freeDailyChatQuota - used).clamp(0, freeDailyChatQuota);
  }

  Future<bool> canChat() async {
    if ((await getStatus()).isActive) return true;
    return await remainingFreeChats() > 0;
  }

  Future<void> consumeChat() async {
    if ((await getStatus()).isActive) return;
    final prefs = await SharedPreferences.getInstance();
    final key = _quotaKey();
    await prefs.setInt(key, (prefs.getInt(key) ?? 0) + 1);
  }

  // --- Pembayaran (Midtrans via Edge Function) ---

  /// Memanggil Edge Function dan mengubah error server menjadi pesan terbaca.
  Future<Map<String, dynamic>> _invoke(String fn, Map<String, dynamic> body) async {
    try {
      final response = await _client.functions.invoke(fn, body: body);
      return Map<String, dynamic>.from(response.data as Map);
    } on FunctionException catch (e) {
      final details = e.details;
      final message = details is Map ? details['error'] : null;
      throw Exception(message ?? 'Layanan pembayaran belum tersedia (${e.status}).');
    }
  }

  Future<PaymentOrder> createPayment(PremiumPlan plan) async {
    final data = await _invoke('create-midtrans-payment', {'planId': plan.id});
    final url = data['redirect_url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception(data['error'] ?? 'URL pembayaran tidak diterima.');
    }
    return PaymentOrder(orderId: data['order_id'] as String, redirectUrl: url);
  }

  Future<bool> openPayment(PaymentOrder order) async {
    final uri = Uri.parse(order.redirectUrl);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Minta server memverifikasi status transaksi ke Midtrans.
  /// Mengembalikan status transaksi: settlement / pending / expire / ...
  Future<String> verifyPayment(String orderId) async {
    final data = await _invoke('check-midtrans-payment', {'orderId': orderId});
    final status = (data['status'] ?? 'unknown').toString();
    if (data['premium'] == true) {
      await getStatus(refresh: true);
    }
    return status;
  }

  void clearCache() => _cached = null;
}
