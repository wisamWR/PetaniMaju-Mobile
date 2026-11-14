# 🌾 PetaniMaju

![PetaniMaju Banner](assets/images/logo.png)

> **Platform Informasi Cuaca & Teknik Pertanian Praktis**

![Flutter](https://img.shields.io/badge/Flutter-3.16.0-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.2.0-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen)

---

## 📖 Deskripsi

**PetaniMaju** adalah aplikasi asisten digital yang dirancang khusus untuk membantu petani di Indonesia, khususnya di daerah 3T (Tertinggal, Terdepan, dan Terluar). Aplikasi ini bertujuan untuk meningkatkan produktivitas pertanian dengan menyediakan informasi yang relevan, akurat, dan mudah dipahami.

### Masalah Utama yang Diselesaikan
*   Kurangnya akses informasi cuaca yang akurat di tingkat lokal.
*   Keterbatasan pengetahuan tentang teknik pertanian modern dan penanganan hama.
*   Sulitnya mendapatkan jadwal tanam yang tepat.
*   Minimnya wadah diskusi antar petani untuk berbagi pengalaman.

### Fitur Utama
*   🌤️ **Prediksi Cuaca Akurat:** Informasi cuaca real-time dan prediksi 7 hari ke depan berbasis lokasi.
*   🚨 **Peringatan Dini:** Notifikasi cuaca ekstrem untuk antisipasi gagal panen.
*   💡 **Tips Pertanian:** Artikel dan panduan praktis tentang teknik bertani.
*   🐛 **Info Hama & Penyakit:** Ensiklopedia hama lengkap dengan cara penanganannya.
*   📅 **Kalender Tanam:** Jadwal tanam yang dapat disesuaikan.
*   🎥 **Video Edukasi:** Tutorial visual untuk pembelajaran yang lebih mudah.
*   💬 **Forum Komunitas:** Ruang diskusi untuk bertanya dan berbagi solusi.
*   👤 **Profil Pengguna:** Personalisasi pengalaman berdasarkan jenis tanaman dan lokasi.
*   🔬 **Scan Penyakit Tanaman (AI):** Foto daun → diagnosa penyakit, penanganan, pencegahan, dan rekomendasi obat (Gemini Vision).
*   🤖 **Asisten Tani:** Chatbot pertanian (Gemini) dengan konteks cuaca & jadwal, bisa membuat jadwal kalender langsung dari chat.
*   💊 **Katalog Obat Tanaman:** 40 obat/pestisida lengkap dengan dosis & cara pakai, bisa dibuka tanpa internet.
*   🔔 **Riwayat & Pengaturan Notifikasi:** Jam sapaan pagi, filter peringatan cuaca, pengingat H-1/H-1 jam, dan mode tenang malam.
*   ⭐ **PetaniMaju PRO:** Langganan via Midtrans untuk chat Asisten Tani tanpa batas (gratis: 3 jawaban/hari).

---

## 🛠️ Tech Stack

*   **Frontend Mobile:** [Flutter](https://flutter.dev/) (Dart)
*   **Backend:** [Supabase](https://supabase.com/) (PostgreSQL, Auth, Storage)
*   **APIs:** [OpenWeatherMap API](https://openweathermap.org/api)
*   **State Management:** `setState` & `Provider`
*   **Local Storage:** `shared_preferences`
*   **Notifications:** `flutter_local_notifications`
*   **Navigation:** `go_router`

---

## 📱 Fitur Detail

1.  **Weather Forecast (7-day):** Menampilkan suhu, kondisi cuaca, kelembaban, dan kecepatan angin.
2.  **Weather Alerts:** Sistem peringatan dini untuk hujan lebat, panas ekstrem, atau angin kencang.
3.  **Daily Agricultural Tips:** Tips harian yang berganti setiap hari untuk menambah wawasan.
4.  **Pest & Disease Info:** Database hama dan penyakit dengan foto dan solusi penanganan.
5.  **Planting Calendar:** Fitur untuk mencatat dan memantau fase tanam.
6.  **Video Tutorials:** Integrasi video YouTube untuk panduan visual.
7.  **Community Forum:** Fitur sosial untuk membuat postingan (dengan foto), like, dan komentar.
8.  **User Profile & Auth:** Login/Register, lupa kata sandi, edit profil, ubah kata sandi, dan hapus akun permanen (verifikasi kata sandi).
9.  **Bookmarks:** Simpan tips, video, atau info hama favorit untuk dibaca nanti.
10. **Showcase Tutorial:** Panduan interaktif untuk pengguna baru.

---

## 📋 Prasyarat

Sebelum memulai, pastikan Anda telah menginstal:

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0.0+)
*   [Android Studio](https://developer.android.com/studio) (untuk Android Emulator/SDK)
*   [VS Code](https://code.visualstudio.com/) (Recommended IDE)
*   Akun [Supabase](https://supabase.com/)
*   API Key [OpenWeatherMap](https://openweathermap.org/)

---

## 🚀 Instalasi & Setup

### 1. Clone Repository
```bash
git clone https://github.com/username/PetaniMaju.git
cd PetaniMaju
```

### 2. Instalasi Dependencies
```bash
flutter pub get
```

### 3. Konfigurasi
Aplikasi ini menggunakan konfigurasi hardcoded di `lib/core/constants.dart` untuk kemudahan demo. Untuk produksi, disarankan menggunakan environment variables.

Buka `lib/core/constants.dart` dan sesuaikan jika perlu:
```dart
class AppConstants {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String openWeatherApiKey = 'YOUR_OPENWEATHER_API_KEY';
}
```

### 4. Konfigurasi Fitur AI (Gemini)
Scanner penyakit dan Asisten Tani butuh Gemini API key yang **tidak** disimpan di kode:
```bash
cp .env.example .env        # isi GEMINI_API_KEY
flutter run --dart-define-from-file=.env
```

### 5. Backend Fitur Baru
1. Jalankan semua file di `supabase/migrations/` (urut nama file) di SQL Editor Supabase,
   atau `supabase db push`:
   - `20260919000000_agrinova_features.sql` — tabel `prediction_history`, bucket `scan_images`, tabel `user_premium` & `premium_orders`.
   - `20260919100000_base_schema.sql` — profil, tips, hama, video, forum, kalender, bookmark + RLS.
   - `20261115000000_delete_account.sql` — fungsi `delete_my_account()` untuk fitur **Hapus Akun**.
   - Lalu jalankan `supabase/seed.sql` untuk mengisi konten awal (24 tips & 8 hama/penyakit). Aman dijalankan ulang.
2. (Untuk PRO) deploy Edge Function lalu set secret Midtrans:
```bash
supabase functions deploy create-midtrans-payment
supabase functions deploy check-midtrans-payment
supabase secrets set MIDTRANS_SERVER_KEY=SB-Mid-server-xxx MIDTRANS_IS_PRODUCTION=false
```

---

## 🗄️ Database Setup (Supabase)

Aplikasi ini membutuhkan tabel-tabel berikut di Supabase:

### Tabel Utama
*   `profiles`: Menyimpan data pengguna (nama, lokasi, jenis tanaman).
*   `tips`: Artikel tips pertanian.
*   `hama_penyakit`: Data hama dan penyakit.
*   `videos`: Link video tutorial.
*   `calendar_events`: Jadwal tanam pengguna.
*   `forum_posts`: Postingan forum.
*   `saved_items`: Bookmark pengguna (relasi ke tips, video, hama).
*   `prediction_history`: Riwayat hasil scan penyakit tanaman.
*   `user_premium`: Status langganan PRO (hanya ditulis Edge Function).
*   `premium_orders`: Order langganan PRO (hanya ditulis Edge Function).

### SQL Schema (Contoh Singkat)
```sql
-- Create Profiles Table
create table profiles (
  id uuid references auth.users not null,
  updated_at timestamp with time zone,
  username text unique,
  full_name text,
  avatar_url text,
  website text,
  primary key (id),
  constraint username_length check (char_length(username) >= 3)
);

-- Set up Row Level Security (RLS)
alter table profiles enable row level security;
```

---

## ▶️ Menjalankan Aplikasi

### Development Mode
```bash
flutter run --dart-define-from-file=.env
```

### Production Build (APK)
Untuk membuat file APK rilis:
```bash
flutter build apk --release
```
File APK akan berada di: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📚 API Documentation

### A. Supabase Services (`SupabaseService`)
Service ini menangani semua interaksi database:
*   `getTips()`: Mengambil daftar tips.
*   `getHama()`: Mengambil data hama.
*   `getVideos()`: Mengambil daftar video.
*   `getForumPosts()`: Mengambil postingan forum.
*   `saveItem()`: Menyimpan item ke bookmark.

### B. Weather Service (`WeatherService`)
Menggunakan OpenWeatherMap API:
*   `getCurrentWeather()`: Mendapatkan cuaca saat ini berdasarkan GPS.
*   `getWeatherByCity(String city)`: Mendapatkan cuaca berdasarkan nama kota/kecamatan.
*   **Endpoints Used:**
    *   `/weather`: Current weather data
    *   `/forecast`: 5 day / 3 hour forecast data

### C. Notification Service (`NotificationService`)
*   `showWeatherAlert()`: Menampilkan notifikasi lokal untuk peringatan cuaca.
*   `scheduleDailyBrief()`: Menjadwalkan sapaan pagi harian.

---

```
.
├── android/        # Android native code
├── assets/         # Images, icons, fonts
├── lib/
│   ├── core/       # Constants, themes, utils
│   ├── data/       # Models & Services
│   ├── screens/    # UI Screens
│   ├── widgets/    # Reusable widgets
│   └── main.dart   # Entry point
└── pubspec.yaml    # Dependencies
└── README.md       # Project documentation
```

---

## 🧪 Testing

### Manual Testing Checklist
- [ ] Login & Register flow
- [ ] Dashboard weather load (GPS & City fallback)
- [ ] Tips & Hama detail view
- [ ] Video player functionality
- [ ] Calendar add/remove event
- [ ] Profile update & photo upload
- [ ] Notification toggle

---

## 🤝 Contributing

Kontribusi sangat diterima! Silakan ikuti langkah berikut:

1.  Fork repository ini.
2.  Buat branch fitur baru (`git checkout -b fitur-keren`).
3.  Commit perubahan Anda (`git commit -m 'Menambah fitur keren'`).
4.  Push ke branch (`git push origin fitur-keren`).
5.  Buat Pull Request.

---

## ⚠️ Troubleshooting

*   **Error: Location permissions are denied**
    *   Pastikan GPS aktif dan izin lokasi diberikan di pengaturan HP.
*   **Error: Connection refused / Network error**
    *   Pastikan koneksi internet stabil.
    *   Cek apakah URL Supabase di `constants.dart` sudah benar.
*   **APK Size too big?**
    *   Gunakan `flutter build apk --release --split-per-abi` untuk ukuran yang lebih optimal per arsitektur CPU.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Contact & Support

**Tim Pengembang PetaniMaju**

Mohammad Wisam Wiraghina (A11.2024.15739)

Riziq Izza Lathif Hilman (A11.2024.16012)

Muhammad Abid (A11.2024.15597)

Aulia Rahman Afryansyah (A11.2024.15810)


*   Email: petanimaju911@gmail.com
*   Website: https://petani-maju-web-download-303lx2dk6-minjeongs-projects-f023e36f.vercel.app/

---

![PetaniMaju Banner asli](assets/images/banner_PetaniMaju.png)

*Dibuat dengan ❤️ untuk Petani Indonesia*
