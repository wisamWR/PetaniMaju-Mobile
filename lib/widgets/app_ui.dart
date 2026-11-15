import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warna & komponen kecil yang dipakai ulang agar layar baru
/// konsisten dengan desain PetaniMaju.
class AppColors {
  static const primary = Color(0xFF166534);
  static const primaryLight = Color(0xFF22C55E);
  static const accentBlue = Color(0xFF3B82F6);
}

PreferredSizeWidget buildAppBar(String title, {List<Widget>? actions}) {
  return AppBar(
    title: Text(
      title,
      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
    ),
    backgroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    actions: actions,
  );
}

class FilterChipPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const FilterChipPill(
      {super.key, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: active ? AppColors.primary : Colors.grey[300]!),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const SearchField({super.key, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey[700], fontWeight: FontWeight.bold)),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

/// Kartu putih dengan border abu, radius 16 — gaya kartu dashboard.
class InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;

  const InfoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? Colors.grey[200]!),
      ),
      child: child,
    );
  }
}

/// Bagian berjudul dengan ikon (dipakai di layar detail).
class DetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const DetailSection({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Text(title,
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 12),
            Text(content,
                style: TextStyle(
                    color: Colors.grey[800], height: 1.5, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

/// Efek kilau untuk kerangka loading, tanpa package tambahan.
/// Mati otomatis bila pengguna mengaktifkan "kurangi animasi".
class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1300))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          colors: [Colors.grey[200]!, Colors.grey[50]!, Colors.grey[200]!],
          stops: const [0.35, 0.5, 0.65],
          transform: _SlideGradient(_controller.value * 2 - 1),
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}

class _SlideGradient extends GradientTransform {
  final double percent;

  const _SlideGradient(this.percent);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * percent, 0, 0);
}

/// Kotak abu-abu pengganti konten saat loading.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({super.key, this.width, this.height = 12, this.radius = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Daftar kerangka loading. [card] meniru kartu bergambar besar
/// (tips, video); selain itu meniru baris dengan gambar kecil di kiri.
class SkeletonList extends StatelessWidget {
  final int count;
  final bool card;
  final EdgeInsetsGeometry padding;

  const SkeletonList({
    super.key,
    this.count = 5,
    this.card = false,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 24),
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Memuat',
      child: Shimmer(
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: padding,
          itemCount: count,
          separatorBuilder: (_, __) => SizedBox(height: card ? 16 : 12),
          itemBuilder: (_, __) => card ? _card() : _tile(),
        ),
      ),
    );
  }

  Widget _lines() => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 80, height: 10),
          SizedBox(height: 10),
          FractionallySizedBox(
              widthFactor: 0.9, child: SkeletonBox(height: 14)),
          SizedBox(height: 8),
          FractionallySizedBox(
              widthFactor: 0.6, child: SkeletonBox(height: 12)),
        ],
      );

  // Kartu transparan: ShaderMask mewarnai semua piksel buram, jadi latar
  // putih akan ikut berkilau dan menutupi kotak di dalamnya.
  Widget _card() => InfoCard(
        color: Colors.transparent,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(height: 150, radius: 16),
            Padding(padding: const EdgeInsets.all(16), child: _lines()),
          ],
        ),
      );

  Widget _tile() => InfoCard(
        color: Colors.transparent,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const SkeletonBox(width: 64, height: 64, radius: 12),
            const SizedBox(width: 12),
            Expanded(child: _lines()),
          ],
        ),
      );
}
