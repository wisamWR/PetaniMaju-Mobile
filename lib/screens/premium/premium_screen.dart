import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/services/premium_service.dart';
import '../../widgets/app_ui.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> with WidgetsBindingObserver {
  final _service = PremiumService();
  PremiumStatus? _status;
  PremiumPlan _selected = PremiumService.plans.last;
  String? _pendingOrderId;
  bool _busy = false;

  final _rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Saat kembali dari browser pembayaran, cek status otomatis.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _pendingOrderId != null && !_busy) {
      _verify();
    }
  }

  Future<void> _loadStatus() async {
    final s = await _service.getStatus(refresh: true);
    if (mounted) setState(() => _status = s);
  }

  void _snack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Future<void> _pay() async {
    setState(() => _busy = true);
    try {
      final order = await _service.createPayment(_selected);
      _pendingOrderId = order.orderId;
      final opened = await _service.openPayment(order);
      if (!opened) _snack('Tidak dapat membuka halaman pembayaran', color: Colors.red);
    } catch (e) {
      _snack('Gagal membuat pembayaran: ${e.toString().replaceFirst('Exception: ', '')}',
          color: Colors.red);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    final orderId = _pendingOrderId;
    if (orderId == null) return;
    setState(() => _busy = true);
    try {
      final status = await _service.verifyPayment(orderId);
      switch (status) {
        case 'settlement':
        case 'capture':
          _pendingOrderId = null;
          _snack('Pembayaran berhasil! PetaniMaju PRO aktif 🎉', color: Colors.green);
          await _loadStatus();
          break;
        case 'pending':
          _snack('Pembayaran masih menunggu. Selesaikan lalu tekan "Cek Status".');
          break;
        default:
          _snack('Status pembayaran: $status', color: Colors.orange);
      }
    } catch (e) {
      _snack('Gagal cek status: $e', color: Colors.red);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: buildAppBar('PetaniMaju PRO'),
      body: status == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildHero(status),
                const SizedBox(height: 24),
                Text('Keuntungan PRO',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                InfoCard(
                  child: Column(
                    children: PremiumService.benefits
                        .map((b) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(children: [
                                const Icon(Icons.check_circle,
                                    color: AppColors.primary, size: 20),
                                const SizedBox(width: 12),
                                Expanded(child: Text(b)),
                              ]),
                            ))
                        .toList(),
                  ),
                ),
                if (!status.isActive) ...[
                  const SizedBox(height: 24),
                  Text('Pilih Paket',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ...PremiumService.plans.map(_buildPlan),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _busy ? null : _pay,
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.payment),
                    label: Text('Bayar ${_rupiah.format(_selected.price)}'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  if (_pendingOrderId != null) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _verify,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Cek Status Pembayaran'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Pembayaran diproses aman oleh Midtrans (QRIS, e-wallet, transfer bank). '
                    'Status PRO aktif setelah pembayaran terverifikasi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildHero(PremiumStatus status) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.workspace_premium, color: Colors.amber, size: 40),
          const SizedBox(height: 12),
          Text(status.isActive ? 'PRO Aktif' : 'Upgrade ke PRO',
              style: GoogleFonts.plusJakartaSans(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            status.isActive
                ? 'Paket ${status.plan ?? 'PRO'}${status.until != null ? ' • berlaku sampai ${DateFormat('dd MMM yyyy', 'id_ID').format(status.until!.toLocal())}' : ''}'
                : 'Konsultasi Asisten Tani tanpa batas kuota harian.',
            style: const TextStyle(color: Colors.white, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildPlan(PremiumPlan plan) {
    final active = plan.id == _selected.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selected = plan),
        borderRadius: BorderRadius.circular(16),
        child: InfoCard(
          borderColor: active ? AppColors.primary : null,
          color: active ? Colors.green[50] : null,
          child: Row(
            children: [
              Icon(active ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (plan.badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                          child: Text(plan.badge!,
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ]),
                    Text('${plan.days} hari',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Text(_rupiah.format(plan.price),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
