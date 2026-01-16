class Hama {
  final int id;
  final String nama;
  final String deskripsi;
  final String penanganan;
  final String? imageUrl;
  final String type; // Hama, Penyakit, Gulma
  final DateTime createdAt;

  Hama({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.penanganan,
    this.imageUrl,
    required this.type,
    required this.createdAt,
  });

  factory Hama.fromJson(Map<String, dynamic> json) {
    String rawName = json['name'] ?? 'Tanpa Nama';
    String rawDesc = json['description'] ?? '';
    String rawSolution = json['solution_organic'] ??
        json['prevention'] ??
        'Belum ada data penanganan.';

    // 1. Clean HTML tags
    rawDesc = _stripHtml(rawDesc);
    rawSolution = _stripHtml(rawSolution);

    // 2. Check for Professional Content Override (Hybrid Approach)
    // Matches by name to provide better content while keeping DB images
    final proContent = _getProContent(rawName);
    if (proContent != null) {
      rawDesc = proContent['deskripsi']!;
      rawSolution = proContent['penanganan']!;
    }

    return Hama(
      id: json['id'],
      nama: rawName,
      deskripsi: rawDesc,
      penanganan: rawSolution,
      imageUrl: json['image_url'],
      type: json['type'] ?? 'Hama',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static String _stripHtml(String text) {
    // Replaces HTML tags and entities with space
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
  }

  static Map<String, String>? _getProContent(String name) {
    final lowerName = name.toLowerCase();

    if (lowerName.contains('wereng')) {
      return {
        'deskripsi':
            'Wereng Batang Coklat adalah hama penghisap cairan batang padi yang berbahaya. Serangan parah menyebabkan tanaman menguning dan kering seperti terbakar (hopperburn), serta dapat menularkan virus kerdil rumput dan kerdil hampa.',
        'penanganan':
            '✅ Pencegahan:\n- Gunakan varietas tahan wereng (VUTW).\n- Tanam serempak dalam satu hamparan.\n- Hindari penggunaan pupuk Urea berlebihan.\n\n🛠️ Pengendalian:\n- Lakukan pengamatan rutin setiap minggu.\n- Jika populasi rendah, lestarikan musuh alami (laba-laba, kumbang).\n- Jika populasi tinggi, gunakan insektisida nabati (biopestisida) dari daun mimba atau gadung.\n- Gunakan insektisida kimia sebagai langkah terakhir (bijaksana).'
      };
    } else if (lowerName.contains('tikus')) {
      return {
        'deskripsi':
            'Tikus sawah adalah hama pengerat utama yang merusak batang padi di semua fase pertumbuhan, mulai dari persemaian hingga panen. Kerusakan terparah biasanya terjadi pada fase bunting hingga keluar malai.',
        'penanganan':
            '✅ Pencegahan:\n- Bersihkan gulma di pematang sawah (sanitasi).\n- Lakukan gropyokan (perburuan massal) sebelum masa tanam.\n\n🛠️ Pengendalian:\n- Pasang Trap Barrier System (TBS) atau pagar plastik dengan bubu perangkap.\n- Manfaatkan musuh alami seperti Burung Hantu (Tyto alba) dengan mendirikan rumah burung (agupon) di sawah.\n- Gunakan umpan beracun (rodentisida) jika populasi meledak.'
      };
    } else if (lowerName.contains('sundep') ||
        lowerName.contains('beluk') ||
        lowerName.contains('penggerek')) {
      return {
        'deskripsi':
            'Penggerek batang padi adalah larva ngengat yang memakan bagian dalam batang. Gejala "Sundep" terjadi pada fase vegetatif (pucuk tanaman mati/kering). Gejala "Beluk" terjadi pada fase generatif (malai hampa berwarna putih).',
        'penanganan':
            '✅ Pencegahan:\n- Tanam serempak untuk memutus siklus hidup.\n- Kumpulkan dan musnahkan kelompok telur ngengat di persemaian.\n\n🛠️ Pengendalian:\n- Pasang lampu perangkap (light trap) untuk menangkap ngengat dewasa di malam hari.\n- Lepaskan parasitoid Trichogramma sp. untuk memparasit telur penggerek.\n- Aplikasikan insektisida butiran (seperti karbofuran) pada area perakaran jika serangan melebihi ambang batas.'
      };
    } else if (lowerName.contains('walang')) {
      return {
        'deskripsi':
            'Walang Sangit adalah hama yang menghisap cairan bulir padi pada fase masak susu. Akibatnya, bulir padi menjadi hampa, keriput, atau berwarna coklat (berbintik), yang menurunkan kualitas beras.',
        'penanganan':
            '✅ Pencegahan:\n- Bersihkan gulma/rumput liar di sekitar sawah yang menjadi inang alternatif.\n- Tanam serempak.\n\n🛠️ Pengendalian:\n- Pasang umpan berbau busuk (bangkai keong, kepiting, atau ikan asin) untuk menarik walang sangit, lalu musnahkan yang terkumpul.\n- Lakukan penyemprotan air sabun atau insektisida nabati (ekstrak daun sirsak/tembakau) pada pagi atau sore hari saat hama aktif.'
      };
    } else if (lowerName.contains('keong')) {
      return {
        'deskripsi':
            'Keong Mas memakan bibit padi muda yang baru ditanam, menyebabkan rumpun padi hilang atau rusak parah. Serangan biasanya terjadi pada sawah yang tergenang air.',
        'penanganan':
            '✅ Pencegahan:\n- Pasang saringan pada saluran masuk air irigasi.\n- Buat parit kecil di tepi sawah untuk memudahkan pengumpulan keong saat air surut.\n\n🛠️ Pengendalian:\n- Ambil dan musnahkan keong serta telur berwarna merah muda secara manual.\n- Gunakan itik/bebek untuk memakan keong di sawah sebelum tanam atau setelah panen.\n- Gunakan daun pepaya atau daun talas sebagai umpan untuk mengumpulkan keong.'
      };
    } else if (lowerName.contains('kresek') || lowerName.contains('bakteri')) {
      return {
        'deskripsi':
            'Hawar Daun Bakteri (Kresek) disebabkan oleh bakteri Xanthomonas oryzae. Gejalanya adalah daun mengering mulai dari tepi atau ujung, berwarna abu-abu keputihan, dan melipat. Penyakit ini dapat menurunkan hasil panen secara signifikan.',
        'penanganan':
            '✅ Pencegahan:\n- Gunakan varietas padi yang tahan terhadap hawar daun.\n- Hindari pemupukan Nitrogen (Urea) yang berlebihan.\n- Atur jarak tanam agar tidak terlalu rapat (Legowo).\n\n🛠️ Pengendalian:\n- Hindari penggenangan air yang terlalu tinggi (lakukan pengairan berselang).\n- Semprotkan bakterisida berbahan aktif tembaga jika serangan meluas.'
      };
    } else if (lowerName.contains('blast') ||
        lowerName.contains('potong leher')) {
      return {
        'deskripsi':
            'Penyakit Blast disebabkan oleh jamur Pyricularia oryzae. Menyerang daun (bercak belah ketupat) dan leher malai (busuk leher/potong leher), menyebabkan malai patah dan hampa.',
        'penanganan':
            '✅ Pencegahan:\n- Hindari tanam benih dari daerah terserang.\n- Bakar jerami sisa panen yang terinfeksi.\n\n🛠️ Pengendalian:\n- Gunakan fungisida sistemik berbahan aktif trisiklasol atau isoprotiolan saat anakan maksimum dan awal berbunga jika cuaca mendukung perkembangan jamur (lembap/hujan).'
      };
    }
    return null;
  }

  String getFallbackImage() {
    final lowerName = nama.toLowerCase();
    if (lowerName.contains('wereng')) {
      return 'https://images.unsplash.com/photo-1596464539674-325cb19e4860?q=80&w=2670&auto=format&fit=crop';
    } else if (lowerName.contains('tikus')) {
      return 'https://images.unsplash.com/photo-1452570053594-1b985d6ea890?q=80&w=2574&auto=format&fit=crop';
    } else if (lowerName.contains('walang')) {
      return 'https://images.unsplash.com/photo-1596464539674-325cb19e4860?q=80&w=2670&auto=format&fit=crop';
    } else if (lowerName.contains('burung')) {
      return 'https://images.unsplash.com/photo-1555169062-013468b47731?q=80&w=2574&auto=format&fit=crop';
    } else if (lowerName.contains('penggerek')) {
      return 'https://imgs.mongabay.com/wp-content/uploads/sites/20/2019/02/13095337/ulat-grayak-Jagung-Faperta-UGM.jpg';
    }
    return 'https://images.unsplash.com/photo-1596464539674-325cb19e4860?q=80&w=2670&auto=format&fit=crop';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nama,
      'description': deskripsi,
      'solution_organic': penanganan,
      'image_url': imageUrl,
      'type': type,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
