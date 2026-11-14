import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/drug_model.dart';

/// Katalog obat tanaman dari aset lokal (bisa dipakai tanpa internet).
class DrugService {
  static final DrugService _instance = DrugService._internal();
  factory DrugService() => _instance;
  DrugService._internal();

  List<Drug>? _cache;

  Future<List<Drug>> getDrugs() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/katalog_obat_tanaman.json');
    final data = jsonDecode(raw) as List<dynamic>;
    _cache = data
        .map((e) => Drug.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return _cache!;
  }

  Future<List<String>> getCategories() async {
    final drugs = await getDrugs();
    final set = drugs.map((d) => d.kategori).toSet().toList()..sort();
    return set;
  }

  Future<List<Drug>> findByNames(List<String> names) async {
    final drugs = await getDrugs();
    final wanted = names.map((n) => n.trim().toLowerCase()).where((n) => n.isNotEmpty);
    final result = <Drug>[];
    for (final name in wanted) {
      for (final d in drugs) {
        final dn = d.nama.toLowerCase();
        if ((dn == name || dn.contains(name) || name.contains(dn)) &&
            !result.contains(d)) {
          result.add(d);
          break;
        }
      }
    }
    return result;
  }

  /// Rekomendasi obat berdasarkan tanaman & nama penyakit.
  /// Fallback: semua obat untuk tanaman tersebut.
  Future<List<Drug>> recommend({
    required String plantType,
    required String disease,
    int limit = 6,
  }) async {
    final lowerDisease = disease.toLowerCase();
    if (lowerDisease.contains('sehat') || lowerDisease.contains('healthy')) {
      return [];
    }

    final drugs = await getDrugs();
    final qPlant = plantType.toLowerCase();
    final diseaseTokens = lowerDisease
        .split(RegExp(r'[^a-z0-9]'))
        .where((t) => t.length > 4)
        .toSet();

    bool matchPlant(Drug d) =>
        d.tanaman.any((t) => t.toLowerCase().contains(qPlant) || qPlant.contains(t.toLowerCase()));

    bool matchDisease(Drug d) {
      final target = d.sasaran.join(' ').toLowerCase();
      if (target.contains(lowerDisease)) return true;
      return diseaseTokens.any(target.contains);
    }

    var result = drugs.where((d) => matchPlant(d) && matchDisease(d)).toList();
    if (result.isEmpty) {
      result = drugs.where(matchDisease).toList();
    }
    if (result.isEmpty) {
      result = drugs.where(matchPlant).toList();
    }
    return result.take(limit).toList();
  }
}
