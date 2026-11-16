import 'package:flutter/material.dart';

class PlantAdvice {
  final String title;
  final String advice;
  final bool isUrgent;
  final IconData icon;

  const PlantAdvice({
    required this.title,
    required this.advice,
    required this.isUrgent,
    required this.icon,
  });
}

class MonthlyActivity {
  final String title;
  final List<String> items;
  const MonthlyActivity(this.title, this.items);
}

/// Saran perawatan tanaman berdasar cuaca & rekomendasi aktivitas bulanan.
class FarmingAdvice {
  /// [iconCode] adalah kode ikon OpenWeather (mis. "10d" = hujan).
  static PlantAdvice plantCare({
    required double temperature,
    required int humidity,
    required double windSpeed,
    required String iconCode,
    required String description,
  }) {
    final desc = description.toLowerCase();
    final isRain = iconCode.startsWith('09') ||
        iconCode.startsWith('10') ||
        iconCode.startsWith('11') ||
        desc.contains('hujan');

    if (temperature > 32) {
      return const PlantAdvice(
        title: 'Suhu Tinggi Terdeteksi',
        advice:
            'Tanaman rentan layu. Siram ekstra di sore hari dan tunda pemupukan kimia.',
        isUrgent: true,
        icon: Icons.thermostat,
      );
    }
    if (isRain) {
      return const PlantAdvice(
        title: 'Hujan Turun',
        advice:
            'Hentikan penyiraman dan buka saluran drainase agar akar tidak busuk. Jangan menebar pupuk.',
        isUrgent: true,
        icon: Icons.water_drop,
      );
    }
    if (humidity > 90) {
      return const PlantAdvice(
        title: 'Kelembapan Tinggi',
        advice:
            'Waspada jamur dan wereng. Cek bagian bawah daun dan kurangi kerapatan tanaman.',
        isUrgent: false,
        icon: Icons.cloud,
      );
    }
    if (windSpeed > 5.5) {
      return const PlantAdvice(
        title: 'Angin Kencang',
        advice: 'Pasang ajir/penyangga pada tanaman tinggi agar batang tidak patah.',
        isUrgent: true,
        icon: Icons.air,
      );
    }
    if (iconCode.startsWith('01')) {
      return const PlantAdvice(
        title: 'Cuaca Cerah',
        advice:
            'Waktu tepat untuk pemupukan dan penyemprotan pestisida organik.',
        isUrgent: false,
        icon: Icons.wb_sunny,
      );
    }
    return const PlantAdvice(
      title: 'Kondisi Normal',
      advice: 'Lakukan pemantauan rutin pada tanaman Anda.',
      isUrgent: false,
      icon: Icons.eco,
    );
  }

  static MonthlyActivity forMonth(int month) => _monthly[month]!;

  static const Map<int, MonthlyActivity> _monthly = {
    1: MonthlyActivity('Januari (Musim Hujan)', [
      'Periksa saluran drainase agar lahan tidak tergenang.',
      'Waspada serangan jamur karena kelembapan tinggi.',
      'Lakukan pemupukan susulan saat cuaca mendung/hujan ringan.',
    ]),
    2: MonthlyActivity('Februari', [
      'Siangi gulma yang tumbuh subur di musim hujan.',
      'Pantau hama wereng coklat secara intensif.',
      'Siapkan alat panen untuk padi awal musim.',
    ]),
    3: MonthlyActivity('Maret (Menjelang Panen)', [
      'Cek kematangan bulir padi secara berkala.',
      'Kurangi debit air pada lahan siap panen.',
      'Siapkan karung dan lumbung penyimpanan.',
    ]),
    4: MonthlyActivity('April (Panen Raya)', [
      'Lakukan panen raya saat cuaca cerah.',
      'Jemur gabah hingga kadar air aman.',
      'Bersihkan sisa jerami untuk dikomposkan.',
    ]),
    5: MonthlyActivity('Mei (Pancaroba)', [
      'Olah tanah untuk tanam palawija (jagung/kedelai).',
      'Berikan kapur dolomit jika tanah terlalu asam.',
      'Waspada perubahan cuaca mendadak.',
    ]),
    6: MonthlyActivity('Juni (Awal Kemarau)', [
      'Mulai tanam palawija yang tahan kering.',
      'Hemat penggunaan air irigasi.',
      'Pasang mulsa untuk menjaga kelembapan tanah.',
    ]),
    7: MonthlyActivity('Juli (Kemarau)', [
      'Waspada kutu kebul dan trips (hama musim kering).',
      'Siram secukupnya untuk efisiensi air.',
      'Berikan pupuk daun untuk nutrisi tambahan.',
    ]),
    8: MonthlyActivity('Agustus (Puncak Kemarau)', [
      'Pastikan sumber air irigasi masih mencukupi.',
      'Panen palawija jangka pendek.',
      'Siapkan lahan untuk musim tanam berikutnya.',
    ]),
    9: MonthlyActivity('September', [
      'Olah lahan kering untuk persiapan musim hujan.',
      'Siapkan pupuk kompos matang.',
      'Periksa dan perbaiki alat-alat pertanian.',
    ]),
    10: MonthlyActivity('Oktober (Labuhan)', [
      'Semai bibit padi seiring hujan mulai turun.',
      'Bersihkan saluran masuk air ke sawah.',
      'Waspada bibit penyakit di awal musim hujan.',
    ]),
    11: MonthlyActivity('November (Musim Hujan)', [
      'Tanam padi serentak untuk menekan hama.',
      'Atur tata air (macak-macak).',
      'Berikan pupuk dasar sebelum tanam.',
    ]),
    12: MonthlyActivity('Desember', [
      'Lakukan pemupukan pertama tanaman padi.',
      'Kendalikan keong mas di genangan air.',
      'Sulam tanaman yang mati atau kerdil.',
    ]),
  };
}
