import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/drug_model.dart';
import '../screens/drugs/drug_list_screen.dart';

/// Kartu obat ringkas untuk daftar horizontal (hasil scan & chat).
class DrugMiniCard extends StatelessWidget {
  final Drug drug;
  const DrugMiniCard({super.key, required this.drug});

  @override
  Widget build(BuildContext context) {
    final color = drugCategoryColor(drug.kategori);
    return InkWell(
      onTap: () => context.push('/obat/detail', extra: drug),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: drug.gambarUrl ?? '',
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  height: 80,
                  color: color.withValues(alpha: 0.1),
                  child: Icon(Icons.medication, color: color),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(drug.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(drug.kategori,
                      style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w600)),
                  Text(drug.dosis,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrugMiniList extends StatelessWidget {
  final List<Drug> drugs;
  const DrugMiniList({super.key, required this.drugs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: drugs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => DrugMiniCard(drug: drugs[i]),
      ),
    );
  }
}
