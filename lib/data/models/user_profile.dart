class UserProfile {
  final String id;
  final String? email;
  final String? nama;
  final String? username;
  final String? lokasi; // Legacy or Computed
  final String? avatarUrl;

  final String? noHp;
  final String? alamat;
  final String? kota; // Kabupaten/Kota
  final String? provinsi;
  final String? kecamatan;
  final String? jenisTanaman;

  UserProfile({
    required this.id,
    this.email,
    this.nama,
    this.username,
    this.lokasi,
    this.avatarUrl,
    this.noHp,
    this.alamat,
    this.kota,
    this.provinsi,
    this.kecamatan,
    this.jenisTanaman,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String?,
      nama: json['nama'] ?? json['full_name'],
      username: json['username'],
      lokasi: json['kabupaten'] ?? json['provinsi'],
      avatarUrl: json['avatar_url'],
      noHp: json['no_hp'] ?? json['telepon'],
      alamat: json['alamat'],
      kota: json['kota'] ?? json['kabupaten'],
      provinsi: json['provinsi'],
      kecamatan: json['kecamatan'],
      jenisTanaman: json['jenis_tanaman'] ?? json['tanaman'],
    );
  }
}
