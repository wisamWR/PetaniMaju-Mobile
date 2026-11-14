class Drug {
  final String id;
  final String nama;
  final String kategori;
  final String produsen;
  final String bahanAktif;
  final String dosis;
  final String deskripsi;
  final List<String> tanaman;
  final List<String> sasaran;
  final String caraPakai;
  final String peringatan;
  final String? gambarUrl;
  final String? linkPembelian;

  Drug({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.produsen,
    required this.bahanAktif,
    required this.dosis,
    required this.deskripsi,
    required this.tanaman,
    required this.sasaran,
    required this.caraPakai,
    required this.peringatan,
    this.gambarUrl,
    this.linkPembelian,
  });

  factory Drug.fromJson(Map<String, dynamic> json) {
    List<String> asList(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      if (v == null) return [];
      return [v.toString()];
    }

    return Drug(
      id: json['id']?.toString() ?? '',
      nama: json['nama_obat'] ?? 'Tanpa Nama',
      kategori: json['kategori'] ?? 'Lainnya',
      produsen: json['produsen'] ?? '-',
      bahanAktif: json['bahan_aktif'] ?? '-',
      dosis: json['dosis'] ?? '-',
      deskripsi: json['deskripsi'] ?? '',
      tanaman: asList(json['tanaman']),
      sasaran: asList(json['sasaran']),
      caraPakai: json['cara_pakai'] ?? '-',
      peringatan: json['peringatan'] ?? '-',
      gambarUrl: json['gambar_url'],
      linkPembelian: json['link_pembelian'],
    );
  }
}
