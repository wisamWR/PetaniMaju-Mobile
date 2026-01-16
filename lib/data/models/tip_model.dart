class Tip {
  final int id;
  final String judul;
  final String deskripsi;
  final String kategori;
  final String? konten;
  final String? imageUrl;
  final String? sumber;
  final DateTime createdAt;

  Tip({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.kategori,
    this.konten,
    this.imageUrl,
    this.sumber,
    required this.createdAt,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    String rawTitle = json['title'] ?? 'Tanpa Judul';
    String rawDesc = json['description'] ?? '';
    String rawContent = json['content'] ?? '';

    // 1. Clean HTML tags
    rawDesc = _stripHtml(rawDesc);
    rawContent = _stripHtml(rawContent);

    // 2. Check for Professional Content Override (Hybrid Approach)
    final proContent = _getProContent(rawTitle);
    if (proContent != null) {
      rawDesc = proContent['deskripsi']!;
      rawContent = proContent['konten']!;
    }

    return Tip(
      id: json['id'],
      judul: rawTitle,
      deskripsi: rawDesc,
      kategori: json['category'] ?? 'Umum',
      konten: rawContent,
      imageUrl: json['image_url'],
      sumber: json['source'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static String _stripHtml(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
  }

  static Map<String, String>? _getProContent(String title) {
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('jajar legowo')) {
      return {
        'deskripsi':
            'Metode tanam cerdas dengan lorong berselang-seling untuk melipatgandakan hasil panen dan menekan serangan hama.',
        'konten':
            'Sistem Tanam Jajar Legowo (Jarwo) adalah rekayasa teknik tanam dengan mengatur jarak tanam antar rumpun dan antar barisan.\n\n✅ Keunggulan Utama:\n1. Efek Tanaman Pinggir: Semua barisan rumpun tanaman berada di pinggir lorong, sehingga mendapatkan sinar matahari optimal untuk fotosintesis. Ini membuat batang lebih kokoh dan bulir lebih bernas.\n2. Peningkatan Populasi: Jumlah rumpun tanaman per hektar meningkat hingga 30% dibanding sistem tegel biasa.\n3. Pengendalian Hama & Penyakit: Lorong kosong melancarkan sirkulasi udara dan menurunkan kelembapan, sehingga tidak disukai tikus dan menghambat perkembangan jamur serta wereng.\n4. Efisiensi Perawatan: Lorong memudahkan petani masuk untuk memupuk dan menyiangi gulma tanpa merusak tanaman.',
      };
    } else if (lowerTitle.contains('pemupukan') ||
        lowerTitle.contains('pupuk')) {
      return {
        'deskripsi':
            'Strategi pemberian nutrisi "4 Tepat" (Jenis, Dosis, Waktu, Cara) untuk tanaman sehat dan tanah yang tetap subur.',
        'konten':
            'Pemupukan bukan sekadar menebar pupuk, tapi memberi makan tanaman sesuai kebutuhannya.\n\n🌱 Panduan Pemupukan Berimbang:\n1. Gunakan BWD (Bagan Warna Daun): Alat sederhana untuk mengukur "rasa lapar" tanaman akan Nitrogen (Urea). Jangan memupuk jika daun masih hijau gelap.\n2. Pupuk Dasar: Berikan SP-36 (Fosfor) dan sebagian KCl (Kalium) saat pengolahan tanah atau 0-14 hari setelah tanam (HST) untuk merangsang akar.\n3. Pupuk Susulan: Berikan Urea dan sisa KCl pada fase anakan aktif (20-25 HST) dan fase primordia/bunting (40-45 HST).\n4. Organik Wajib: Selalu tambahkan pupuk organik/kandang minimal 2 ton/ha setiap musim untuk menjaga gemburnya tanah dan daya ikat air.',
      };
    } else if (lowerTitle.contains('air') ||
        lowerTitle.contains('irigasi') ||
        lowerTitle.contains('pengairan')) {
      return {
        'deskripsi':
            'Teknik Intermittent (Basah-Kering) untuk menghemat air, mengurangi emisi gas, dan memperkuat perakaran padi.',
        'konten':
            'Mitos bahwa "Padi adalah tanaman air" tidak sepenuhnya benar. Padi butuh air, tapi tidak harus selalu tergenang.\n\n💧 Cara Penerapan Intermittent:\n1. Fase Tanam Awal: Genangi tipis (2-5 cm) selama 10-15 hari agar gulma tidak tumbuh.\n2. Fase Anakan: Biarkan lahan mengering hingga tanah retak rambut (selama 5-7 hari), lalu genangi lagi. Ulangi siklus ini.\n3. Manfaat Kering: Saat tanah kering, akar padi akan tumbuh memanjang mencari air ke dalam tanah. Ini membuat tanaman lebih kokoh (tidak mudah rebah) dan menyerap nutrisi lebih banyak.\n4. Fase Bunting: Genangi kembali hingga panen untuk pengisian bulir.',
      };
    } else if (lowerTitle.contains('benih') || lowerTitle.contains('bibit')) {
      return {
        'deskripsi':
            'Seleksi benih dengan larutan garam untuk memastikan hanya bibit bernas dan sehat yang masuk ke persemaian.',
        'konten':
            'Kualitas panen dimulai dari kualitas benih. Jangan semai benih kosong!\n\n🌾 Langkah Seleksi Benih:\n1. Siapkan Larutan Garam: Larutkan garam dapur dalam air. Indikator pas: sebutir telur ayam mentah bisa mengapung di permukaan air.\n2. Perendaman: Masukkan benih padi ke dalam larutan. Aduk perlahan.\n3. Pemisahan: Benih yang MENGAPUNG adalah benih hampa/gepeng/sakit (buang). Benih yang TENGGELAM adalah benih bernas (ambil).\n4. Pencucian: Segera cuci bersih benih yang tenggelam dengan air tawar mengalir untuk menghilangkan garam sebelum diperam/disemai.',
      };
    } else if (lowerTitle.contains('rotasi') ||
        lowerTitle.contains('palawija')) {
      return {
        'deskripsi':
            'Memutus mata rantai hama dengan berganti menu tanaman (Padi-Padi-Palawija) untuk kesehatan tanah jangka panjang.',
        'konten':
            'Menanam padi terus-menerus sepanjang tahun adalah "karpet merah" bagi hama wereng dan tikus.\n\n🔄 Mengapa Harus Rotasi?\n1. Memutus Siklus Hama: Hama padi akan mati kelaparan atau pergi saat tidak ada tanaman padi (diganti Jagung/Kedelai/Kacang Hijau).\n2. Mengembalikan Hara Tanah: Tanaman kacang-kacangan (Legum) memiliki bintil akar yang mampu menambat Nitrogen bebas dari udara, menyuburkan tanah secara alami untuk musim tanam padi berikutnya.\n3. Menghemat Air: Palawija membutuhkan air jauh lebih sedikit dibanding padi, cocok ditanam saat musim kemarau (MK 2).',
      };
    } else if (lowerTitle.contains('panen')) {
      return {
        'deskripsi':
            'Menentukan waktu panen presisi untuk mendapatkan rendemen beras giling tertinggi dan kualitas nasi terbaik.',
        'konten':
            'Panen terlalu muda membuat banyak butir kapur/hijau. Panen terlalu tua membuat beras mudah patah (menir) saat digiling.\n\n✂️ Ciri Siap Panen:\n1. Visual: 90-95% malai sudah menguning. Daun bendera (daun paling atas) mulai mengering.\n2. Tekstur: Butir padi keras bila ditekan dengan kuku, tidak lagi berair/susu.\n3. Waktu: Sekitar 30-35 hari setelah padi berbunga rata.\n\n⚠️ Tips Pasca Panen: Segera rontokkan gabah (threshing) setelah dipotong. Jangan tumpuk potongan padi terlalu lama di sawah karena panas tumpukan akan membuat butir padi kuning/rusak.',
      };
    }
    return null;
  }

  String getFallbackImage() {
    final lowerTitle = judul.toLowerCase();
    if (lowerTitle.contains('padi') || lowerTitle.contains('gabah')) {
      return 'https://images.unsplash.com/photo-1746106388675-4a5cb72db549?q=80&w=2070&auto=format&fit=crop';
    } else if (lowerTitle.contains('wereng') || lowerTitle.contains('hama')) {
      return 'https://images.unsplash.com/photo-1688892039994-37ee71aa23bc?q=80&w=1332&auto=format&fit=crop';
    } else if (lowerTitle.contains('pupuk') || lowerTitle.contains('organik')) {
      return 'https://ik.trn.asia/uploads/2021/09/sistem-tanam-jajar-legowo.jpg';
    } else if (lowerTitle.contains('panen')) {
      return 'https://images.unsplash.com/photo-1625246333195-58405079a496?auto=format&fit=crop&q=80&w=1000';
    }
    return 'https://images.unsplash.com/photo-1625246333195-58405079a496?auto=format&fit=crop&q=80&w=1000';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': judul,
      'description': deskripsi,
      'content': konten,
      'category': kategori,
      'image_url': imageUrl,
      'source': sumber,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
