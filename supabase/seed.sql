-- Konten awal (tips & hama) diambil dari project Petani Maju V.2.
-- Gambar yang dulu di storage V.2 kini ada di bucket content_images
-- (salinannya di supabase/seed-images/, unggah dengan `supabase storage cp`).
-- Idempoten: baris dengan judul/nama yang sama tidak diduplikasi.

insert into public.tips (title, description, content, category, image_url, created_at)
select * from (values
  ('Tips Menjaga Tanaman Tetap Sehat', 'Lakukan penyiraman secara teratur, berikan pupuk sesuai kebutuhan, dan pastikan tanaman mendapatkan cukup sinar matahari.', 'Lakukan penyiraman secara teratur, berikan pupuk sesuai kebutuhan, dan pastikan tanaman mendapatkan cukup sinar matahari. Bersihkan gulma serta daun yang sudah rusak agar tidak menjadi tempat berkembangnya hama dan penyakit.

### 🌐 Sumber
Redaksi Petani Maju', 'Tips Tani', 'https://lmbsryezpadlsbxznezl.supabase.co/storage/v1/object/public/content_images/tips/tips-menjaga-tanaman-tetap-sehat.jpg', '2026-08-28T09:15:00+00:00'::timestamptz),
  ('Cara Pemupukan yang Tepat', 'Gunakan pupuk sesuai jenis tanaman dan dosis yang dianjurkan.', 'Gunakan pupuk sesuai jenis tanaman dan dosis yang dianjurkan. Hindari pemberian pupuk nitrogen secara berlebihan karena dapat membuat tanaman lebih rentan terhadap beberapa penyakit.

### 🌐 Sumber
Redaksi Petani Maju', 'Tips Tani', 'https://lmbsryezpadlsbxznezl.supabase.co/storage/v1/object/public/content_images/tips/cara-pemupukan-yang-tepat.jpg', '2026-08-28T09:17:00+00:00'::timestamptz),
  ('Yuk, Kenalan dengan BPP di Demak: Sumber Ilmu Tani Kita!', 'BPP adalah tempat petani bisa belajar banyak hal baru dan dapat bantuan soal pertanian.', '### ⚡ Solusi Cepat
BPP adalah tempat petani bisa belajar banyak hal baru dan dapat bantuan soal pertanian. Jangan sungkan mampir ke BPP terdekat di wilayah Demak untuk ngobrol dan cari solusi!

### 📖 Panduan Lengkap
Halo Bapak/Ibu Petani di Demak dan sekitarnya! 👋

Pernah dengar atau sudah sering mampir ke Balai Penyuluhan Pertanian (BPP)? Nah, BPP ini ibarat ''sekolah'' atau ''pusat informasi'' buat kita para petani, lho!

Di wilayah Demak, kita punya beberapa BPP yang siap membantu dan mendampingi Bapak/Ibu semua. Beberapa di antaranya yang sering kita dengar adalah:
*   **BPP Demak**
*   **BPP Dempet**
*   **BPP Guntur**
*   **BPP Karanganyar**

### Apa Saja yang Bisa Kita Dapatkan di BPP? 🤔
Di BPP, Bapak/Ibu bisa dapat banyak ilmu dan bantuan, seperti:
*   **Informasi Terbaru:** Soal cara tanam yang lebih baik, jenis pupuk yang pas, atau bibit unggul.
*   **Konsultasi Hama & Penyakit:** Kalau tanaman diserang hama atau sakit, bisa tanya ke penyuluh di BPP.
*   **Pelatihan & Penyuluhan:** Sering ada acara belajar bareng atau pelatihan gratis untuk meningkatkan hasil panen.
*   **Jaringan Petani:** Bisa ketemu dan tukar pengalaman dengan petani lain dari desa sebelah.

Jadi, jangan ragu ya untuk mampir ke BPP terdekat. Para penyuluh di sana siap membantu kita semua agar pertanian makin maju dan hasilnya melimpah! 💪 Mari bersama-sama majukan pertanian kita!

### 🌐 Sumber
[Dinas Pertanian & Pangan Kab. Demak](https://dinpertanpangan.demakkab.go.id)', 'Lainnya', 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=800', '2026-08-31T04:28:13+00:00'::timestamptz),
  ('Mengenal Balai Penyuluhan Pertanian (BPP) di Sekitar Kita', 'Konten yang diberikan adalah informasi umum dan tautan ke Balai Penyuluhan Pertanian (BPP) di beberapa wilayah, bukan panduan bercocok tanam…', '### ⚡ Solusi Cepat
Konten yang diberikan adalah informasi umum dan tautan ke Balai Penyuluhan Pertanian (BPP) di beberapa wilayah, bukan panduan bercocok tanam atau info hama. BPP adalah tempat petani bisa mencari informasi dan konsultasi pertanian.

### 📖 Panduan Lengkap
Assalamualaikum Bapak/Ibu Petani sekalian, 👋

Dari tulisan yang kami terima, sepertinya ini adalah informasi umum atau daftar tautan dari sebuah lembaga, mungkin universitas atau Balai Penyuluhan Pertanian (BPP).

### Apa Itu BPP?
BPP adalah singkatan dari Balai Penyuluhan Pertanian. Ini adalah kantor atau pusat di tingkat kecamatan yang tugasnya membantu Bapak/Ibu petani. Di BPP, ada para penyuluh pertanian yang siap memberikan informasi, pelatihan, dan bimbingan seputar pertanian. Mulai dari cara menanam yang baik, memilih bibit unggul, mengatasi hama, sampai cara memasarkan hasil panen.

### Informasi yang Ada:
Isinya menyebutkan beberapa nama BPP, seperti:
*   `BERITA BPP DEMAK`
*   `BPP DEMPET`
*   `BPP GUNTUR`
*   `BPP KARANGANYAR`

Ini menunjukkan adanya kantor-kantor BPP di daerah Demak, Dempet, Guntur, dan Karanganyar. Kalau Bapak/Ibu tinggal di sekitar wilayah tersebut, bisa coba kunjungi BPP terdekat untuk mendapatkan informasi atau konsultasi langsung dengan penyuluh.

### Bukan Tips Bertani Langsung
Jadi, konten ini bukan tips langsung tentang cara menanam padi, mengatasi hama, atau memilih pupuk ya, Bapak/Ibu. Ini lebih ke informasi keberadaan pusat penyuluhan pertanian yang bisa Bapak/Ibu kunjungi untuk mendapatkan bantuan. 🧑‍🌾

Kalau Bapak/Ibu butuh informasi spesifik tentang cara bertani atau mengatasi masalah di lahan, silakan sampaikan pertanyaan yang lebih detail. Kami siap bantu! 🙏

### 🌐 Sumber
Redaksi Petani Maju', 'Lainnya', 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=800', '2026-08-31T04:47:10+00:00'::timestamptz),
  ('PTPN Group Garap Lahan Bawang Putih Besar-besaran di Jawa Barat, Petani Diajak Ikut Makmur!', 'PTPN Group sedang gencar mengembangkan budidaya bawang putih di Jawa Barat seluas 10.000 hektare, bahkan akan diperluas lagi.', '### ⚡ Solusi Cepat
PTPN Group sedang gencar mengembangkan budidaya bawang putih di Jawa Barat seluas 10.000 hektare, bahkan akan diperluas lagi. Program ini bertujuan agar Indonesia tidak perlu impor bawang putih lagi dan petani lokal bisa ikut menikmati hasilnya lewat pola kemitraan.

### 📖 Panduan Lengkap
Halo Sedulur Tani! Ada kabar gembira nih dari PTPN Group. Mereka lagi serius banget mau mengembangkan budidaya bawang putih di Jawa Barat. Nggak main-main, target awalnya 10.000 hektare lahan akan digarap, dan nanti bisa sampai 24.000 hektare lho sampai tahun 2029!

### Kenapa Bawang Putih Penting? 🧅

Kita tahu kan, bawang putih itu bumbu dapur wajib. Tapi sayangnya, hasil panen bawang putih di negeri kita masih jauh banget dari kebutuhan. Bayangkan, kita butuh sekitar 600.000 ton per tahun, tapi baru bisa panen sekitar 39.000-40.000 ton saja. Nah, ini dia peluang besar buat kita para petani untuk ikut serta dan bikin Indonesia mandiri bawang putih, nggak perlu impor lagi!

### Gimana Caranya PTPN Group Mengembangkan Ini? 🤔

PTPN Group nggak sendirian kok. Mereka menggandeng banyak pihak, mulai dari mitra usaha, kelompok tani, sampai masyarakat umum. Jadi, kita para petani juga diajak untuk ikut bagian dalam program ini.

1.  **Fokus Utama: Benih Berkualitas! 🌱**
    Langkah awal yang paling penting adalah menyediakan benih bawang putih yang bagus dan berkualitas. Kalau benihnya sudah oke, hasil panen pasti lebih maksimal. Setelah benihnya kuat, baru deh kita fokus untuk memenuhi kebutuhan bawang putih konsumsi nasional.

2.  **Soal Lahan? Jangan Khawatir! 🏞️**
    Mungkin ada yang mikir, ''Lahannya dari mana?'' Nah, PTPN Group bilang mereka siap berkoordinasi dengan pemerintah untuk mencari dan menyediakan lahan yang cocok. Kalau ada lahan yang sudah siap, langsung digarap. Kalau ada lahan yang masih dikelola masyarakat, PTPN akan pakai pola kemitraan. Artinya, masyarakat dan petani yang punya lahan diajak kerja sama, biar sama-sama untung dan ikut menikmati hasilnya.

3.  **Target Panen Makin Banyak! 📈**
    Program ini juga punya target peningkatan hasil panen. Di tahun pertama, diharapkan bisa panen sekitar 10,8 ton bawang putih kering per hektare. Nanti di tahun keempat, targetnya naik jadi 12,1 ton per hektare. Ini menunjukkan kalau program ini nggak cuma nambah luas lahan, tapi juga bikin hasil panen kita makin optimal.

4.  **Ekosistem Lengkap dari Awal Sampai Akhir 🔄**
    PTPN Group ingin membangun ''ekosistem'' bawang putih yang terintegrasi. Maksudnya, dari mulai penyediaan benih, cara menanam yang bagus (teknologi budidaya), pengolahan hasil panen, sampai pemasarannya, semua akan diatur dengan baik. Jadi, bawang putih yang kita tanam bisa sampai ke pasar dengan lancar dan harganya bagus.

5.  **Ramah Lingkungan dan Didukung Banyak Pihak 🤝**
    Dalam pelaksanaannya, PTPN Group juga bekerja sama dengan Institut Pertanian Bogor (IPB) untuk mengembangkan cara budidaya yang lebih ramah lingkungan. Program ini juga didukung penuh oleh pemerintah pusat, pemerintah daerah, akademisi, BUMN lain, dan pelaku usaha.

### Apa Manfaatnya Buat Petani? 🧑‍🌾

Tujuan utama program ini bukan cuma mengejar swasembada, tapi juga membangun industri bawang putih nasional yang sehat, berkelanjutan, dan yang paling penting, bisa meningkatkan kesejahteraan petani Indonesia. Dengan pola kemitraan, petani diharapkan bisa jadi bagian dari ekosistem ini dan ikut menikmati manfaat ekonominya.

Jadi, mari kita sambut baik program ini dan semoga bawang putih kita bisa berjaya di negeri sendiri!

### 🌐 Sumber
[Horti Indonesia](https://hortiindonesia.com)', 'Lainnya', 'https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?w=800', '2026-08-31T04:55:43+00:00'::timestamptz),
  ('Panen Jagung Untung, Ternak Sehat, Tanah Subur: Jurus Tani Terpadu!', 'Jangan cuma ambil biji jagungnya!', '### ⚡ Solusi Cepat
Jangan cuma ambil biji jagungnya! Batang, daun, tongkol, sampai kulit jagung itu bisa jadi pakan ternak yang murah dan bergizi. Kotoran ternaknya pun bisa jadi pupuk alami buat jagung lagi. Jadi, jagung dan ternak bisa saling bantu, bikin usaha tani makin untung dan lestari!

### 📖 Panduan Lengkap
Halo Sedulur Petani! 👋

Jagung itu tanaman penting banget buat negara kita. Bukan cuma buat makan kita sehari-hari, tapi juga buat pakan ternak dan sumber energi. Pemerintah juga gencar dukung petani jagung biar kita nggak kekurangan makanan dan bisa mandiri, sekaligus bikin petani makin makmur dan desa makin maju.

Biasanya, kita cuma ambil biji jagungnya aja, kan? Nah, sisa-sisa jagung kayak batang, daun, tongkol, sama kulitnya itu sering dibuang percuma atau dibakar. Padahal, limbah jagung ini punya potensi besar lho, bisa jadi pakan ternak murah yang banyak gizinya! 🌱🐄🐔

**Apa Aja Manfaat Jagung dan Limbahnya?**

Yuk, kita bedah satu per satu:

### 1. Biji Jagung: Sumber Energi Utama Ternak

Biji jagung itu ibarat bensin buat ternak. Kenapa? Karena:

*   **Sumber Tenaga Utama:** Banyak karbohidrat dan patinya, bikin ternak punya energi buat tumbuh, produksi susu, atau daging. 💪
*   **Bikin Gemuk & Produktif:** Kandungan protein dan lemaknya bantu bentuk otot, jadi produksi daging, susu, dan telur ternak bisa meningkat.
*   **Nafsu Makan Nambah:** Rasa manis alami biji jagung bikin ternak doyan makan, jadi asupan gizinya cukup.
*   **Pencernaan Lancar:** Ada serat kasarnya, penting banget buat ternak pemamah biak kayak sapi atau kambing.
*   **Telur Makin Kuning:** Buat ayam petelur, lemak dan santofil di jagung bisa bikin warna kuning telurnya makin cerah. 🥚✨
*   **Pakan Lebih Efisien:** Ternak jadi lebih cepat besar atau gemuk dengan pakan yang sama.
*   **Gampang Disimpan:** Biji jagung relatif mudah disiapkan, disimpan, dan dicampur jadi pakan.

### 2. Tebon Jagung (Batang dan Daun): Pakan Alternatif Murah

Tebon jagung itu sisa batang dan daun jagung setelah dipanen. Sering dibuang, padahal bisa jadi pakan ternak yang ekonomis, apalagi pas musim kemarau rumput susah dicari. ☀️

*   **Sumber Serat & Karbohidrat:** Murah dan gampang didapat.
*   **Bisa Diawetkan:** Kalau diolah jadi silase (fermentasi), tebon jagung jadi gampang dicerna dan awet disimpan sampai 6-8 bulan! Jadi nggak khawatir ternak kelaparan pas kemarau.
*   **Kurangi Limbah:** Nggak perlu bakar-bakar limbah lagi, lingkungan jadi bersih. ♻️

**Catatan:** Tebon segar memang tinggi serat (25-35%) tapi proteinnya rendah (6-8%). Jadi, kalau cuma dikasih tebon segar aja, gizinya kurang. Makanya perlu diolah atau dicampur bahan lain.

### 3. Tongkol Jagung (Bonggol): Kaya Serat

Tongkol jagung itu bagian tengah tempat biji jagung nempel. Sering dianggap sampah, padahal kaya serat dan selulosa. Sekarang banyak yang olah jadi pakan ternak, pupuk kompos, briket arang, bahkan kerajinan tangan!

*   **Baik untuk Pencernaan:** Sumber serat kasar yang bagus buat sapi.
*   **Hemat Biaya Pakan:** Bisa jadi campuran konsentrat, apalagi kalau sudah digiling atau difermentasi.

**Catatan:** Tongkol jagung ini rendah protein, vitamin, dan mineral. Jadi, wajib dicampur sama bahan pakan lain yang lebih bergizi, misalnya dedak padi, biar ternak tetap sehat.

### 4. Klobot Jagung (Kulit Jagung): Serat untuk Ruminansia

Klobot atau kulit jagung juga limbah yang potensial jadi pakan alternatif, terutama buat ternak pemamah biak kayak sapi dan kambing.

*   **Sumber Serat:** Bagus buat pencernaan ternak.

**Catatan:** Klobot ini serat kasarnya tinggi dan proteinnya rendah (sekitar 4-5%), serta seratnya agak keras. Jadi, perlu diolah khusus, misalnya difermentasi (silase), biar lebih gampang dicerna ternak dan gizinya meningkat.

### 5. Kotoran Ternak (Kohe): Pupuk Alami Terbaik!

Nah, ini dia bagian terakhir dari sistem terpadu kita. Setelah ternak makan limbah jagung, mereka akan menghasilkan kotoran. Jangan dibuang! Kotoran ternak (kohe) ini adalah pupuk organik alami yang kaya nutrisi penting buat tanaman. 💩➡️🌱

*   **Menyuburkan Tanah:** Kohe yang sudah matang atau difermentasi bisa bikin tanah jadi gembur, subur, dan sehat.
*   **Rangsang Pertumbuhan:** Bantu akar, daun, dan buah tanaman tumbuh lebih baik.

**Kesimpulan:**

Jadi, sedulur petani, menanam jagung itu nggak cuma dapat bijinya aja. Kita bisa manfaatkan semua bagian tanaman jagung untuk pakan ternak, dan kotoran ternaknya bisa jadi pupuk buat jagung lagi. Ini namanya sistem pertanian terpadu yang saling mendukung, bikin usaha tani kita makin produktif, pendapatan nambah, dan lingkungan juga lestari! Yuk, kita coba! 👍

### 🌐 Sumber
[Horti Indonesia](https://hortiindonesia.com)', 'Tips Tani', 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=800', '2026-08-31T04:56:06+00:00'::timestamptz),
  ('Irigasi Tetes: Rahasia Lidah Buaya Subur, Pelepah Tebal, dan Hemat Air!', 'Untuk budidaya lidah buaya yang optimal, pakai irigasi tetes!', '### ⚡ Solusi Cepat
Untuk budidaya lidah buaya yang optimal, pakai irigasi tetes! Cara ini memastikan tanaman dapat air pas, tidak kurang tidak lebih, sehingga pelepah jadi tebal dan berisi gel banyak. Selain itu, air jadi lebih hemat dan bisa sekalian memupuk.

### 🛠️ Alat & Bahan
- Sumber air
- Pompa air
- Sistem penyaringan (hydrocyclone filter & filter Y)
- Tangki fertigasi (opsional, untuk pupuk cair)
- Pipa utama (misal: PVC)
- Pipa lateral (misal: Polyethylene/PE)
- Drip emitter (lubang tetes)
- Stop valve (kran pengatur)
- Toren/tangki penampungan air (misal: 1.000 liter)

### 📖 Panduan Lengkap
Halo Bapak/Ibu Petani! 👋

Pernah dengar soal lidah buaya? Tanaman ini memang bandel, tahan kering. Tapi, biar pelepahnya tebal, berdaging, dan gelnya banyak, dia tetap butuh air yang pas. Nah, kalau kebanyakan air, akarnya bisa busuk lho! 😱

Makanya, Kelompok Wanita Tani (KWT) Sumber Rejeki di Bantul, Yogyakarta, punya cara jitu: pakai **sistem irigasi tetes**. Cara ini bikin lidah buaya mereka tumbuh subur dan hasilnya melimpah!

### Kenapa Lidah Buaya Cocok Pakai Irigasi Tetes? 🤔

Lidah buaya itu tanaman sukulen, artinya dia bisa nyimpan air. Dia memang tahan kering, tapi bukan berarti nggak butuh air sama sekali. Justru, air itu penting banget buat bikin gel di pelepahnya.

Tapi ingat, lidah buaya nggak suka tanah yang becek terus-menerus. Dia butuh tanah yang kadang basah, kadang kering sedikit. Kalau kebanyakan disiram, akarnya gampang busuk. Nah, di sinilah irigasi tetes jadi juara! Airnya bisa diatur pas, langsung ke akar, jadi tanah nggak sampai becek.

### Gimana Sih Cara Kerja Irigasi Tetes Ini? 💧

Sistem irigasi tetes itu sebenarnya sederhana, tapi cerdas! Begini bagian-bagian utamanya:

*   **Sumber Air & Pompa**: Air diambil dari sumur atau penampungan, lalu dipompa biar tekanannya cukup.
*   **Saringan Air**: Sebelum masuk pipa, air disaring dulu. Ada saringan buat pasir (hydrocyclone filter) dan saringan buat kotoran kecil (filter Y). Ini penting biar lubang tetesnya nggak mampet.
*   **Tangki Pupuk (Fertigasi)**: Kalau mau sekalian mupuk, pupuk cair bisa dicampur di tangki ini, lalu dialirkan bareng air. Praktis kan?
*   **Jaringan Pipa**: Air mengalir dari pipa utama, lalu ke pipa-pipa kecil (pipa lateral) yang ada di dekat tanaman.
*   **Lubang Tetes (Emitter)**: Di setiap tanaman, ada lubang kecil yang meneteskan air langsung ke tanah di dekat akar. Debit airnya bisa diatur, misalnya 1-2 liter per jam per tanaman.

Dengan cara ini, air langsung sampai ke akar, nggak nyebar kemana-mana, dan tanah tetap lembap tanpa becek.

### Contoh Penerapan di KWT Sumber Rejeki 🌿

Di KWT Sumber Rejeki, sistem ini dipakai buat 300 tanaman lidah buaya yang ditanam di pot. Mereka pakai:

*   **Toren air** kapasitas 1.000 liter.
*   **Pipa PVC** sebagai pipa utama.
*   **Pompa air**.
*   **Stop valve** (kran) buat ngatur air.
*   **Pipa PE** sebagai pipa lateral yang dipasang di antara barisan pot.
*   **Drip emitter** di setiap pot, langsung di zona akar.

Setiap tanaman lidah buaya di sana dapat air 0,3 liter per sesi. Penyiraman dilakukan 3 kali sehari (jam 8 pagi, 12 siang, dan 4 sore), masing-masing sekitar 9 menit. Total air yang dipakai sekitar 300 liter per sesi untuk 300 tanaman. Hemat banget kan?

### Apa Saja Manfaatnya Buat Lidah Buaya Kita? ✨

1.  **Tanaman Lebih Subur**: Lidah buaya jadi tumbuh sehat, pelepahnya tebal, berdaging, dan warnanya hijau segar.
2.  **Akar Aman dari Busuk**: Karena airnya pas, risiko akar busuk akibat kebanyakan air jadi berkurang drastis.
3.  **Hemat Air**: Air langsung ke akar, jadi nggak banyak yang nguap atau terbuang percuma.
4.  **Bisa Sekalian Mupuk (Fertigasi)**: Pupuk cair bisa dicampur air irigasi. Nutrisi jadi lebih merata diserap tanaman, dan akar nggak gosong karena pupuk kebanyakan.
5.  **Pelepah Tetap Bersih**: Air nggak nyemprot ke daun atau pelepah, jadi nggak ada bercak air, endapan tanah, atau penyebaran penyakit lewat percikan air. Ini penting banget buat menjaga kualitas gel lidah buaya!

### Teknologi Sederhana, Hasil Luar Biasa! 🚀

Pengalaman KWT Sumber Rejeki membuktikan, teknologi sederhana seperti irigasi tetes ini bisa bikin budidaya lidah buaya jadi lebih efisien dan hasilnya memuaskan. Air dan pupuk bisa diatur sesuai kebutuhan tanaman.

Semoga pengalaman ini bisa jadi inspirasi buat Bapak/Ibu Petani lainnya yang juga menanam lidah buaya atau tanaman lain yang butuh perhatian khusus soal air. Mari kita majukan pertanian Indonesia! 💪

### 🌐 Sumber
[Horti Indonesia](https://hortiindonesia.com)', 'Teknologi Tani', 'https://images.unsplash.com/photo-1596547609652-9cf5d8d76921?w=800', '2026-08-31T04:56:28+00:00'::timestamptz),
  ('Rumah Kaca Pintar INSTIPER: Melon Panen Melimpah dengan Teknologi Canggih!', 'INSTIPER mengembangkan rumah kaca pintar (Smart Greenhouse) yang pakai teknologi internet (IoT) dan sistem pemberi saran otomatis (DSS)…', '### ⚡ Solusi Cepat
INSTIPER mengembangkan rumah kaca pintar (Smart Greenhouse) yang pakai teknologi internet (IoT) dan sistem pemberi saran otomatis (DSS) untuk budidaya melon. Dengan ini, petani bisa memantau kondisi tanaman secara akurat dan mendapat rekomendasi perawatan, sehingga panen melon jadi lebih banyak dan berkualitas.

### 🛠️ Alat & Bahan
- Rumah Kaca Pintar (Smart Greenhouse)
- Sensor Otomatis
- Sistem Internet (IoT)
- Sistem Pemberi Saran (DSS)
- Pupuk Cair (Fertigasi)

### 📖 Panduan Lengkap
Halo Sedulur Tani!

Ada kabar gembira dari dunia pertanian kita! Institut Pertanian STIPER (INSTIPER) Yogyakarta baru saja dapat bantuan dana dari pemerintah untuk mengembangkan **Rumah Kaca Pintar** khusus buat budidaya melon. Ini bukan rumah kaca biasa, lho, tapi sudah pakai teknologi canggih yang namanya **Internet of Things (IoT)** dan **Decision Support System (DSS)**. Tujuannya jelas, biar panen melon kita makin bagus dan melimpah!

### Apa Itu Rumah Kaca Pintar?

Bayangkan, di dalam rumah kaca ini, semua hal penting buat pertumbuhan melon bisa dipantau secara otomatis. Mulai dari suhu udara, kelembapan, kadar asam tanah (pH), sampai nutrisi yang dibutuhkan tanaman. Semua data ini langsung terekam dan bisa dilihat lewat HP atau komputer kita kapan saja.

Dengan begitu, kita bisa tahu persis kondisi tanaman dan lingkungan budidaya. Jadi, kalau ada yang kurang atau berlebih, kita bisa langsung ambil tindakan yang pas, nggak pakai kira-kira lagi. Ini yang namanya **bertani presisi**, alias bertani yang terukur dan tepat sasaran.

### Bagaimana Cara Kerjanya?

Sistem ini punya dua bagian utama yang bikin dia pintar:

1.  **Sensor Otomatis**: Alat-alat kecil ini dipasang di dalam rumah kaca untuk terus-menerus mengukur kondisi lingkungan dan tanaman. Misalnya, kalau sensor mendeteksi kadar nutrisi di air (EC) kurang, sistem akan langsung tahu.
2.  **Sistem Pemberi Saran (DSS)**: Nah, ini bagian yang paling keren! Data dari sensor tadi akan diolah oleh sistem ini. Kalau ada masalah, misalnya nutrisi kurang, DSS akan langsung kasih rekomendasi. Contohnya, ''Tambahkan pupuk cair sekarang juga lewat sistem irigasi (fertigasi)!'' Jadi, kita nggak perlu pusing mikir lagi.

Semua data dari budidaya juga akan tersimpan rapi sebagai catatan. Catatan ini penting banget buat belajar, riset, atau evaluasi supaya panen berikutnya bisa lebih baik lagi.

### Manfaatnya Buat Petani Apa?

Banyak sekali manfaatnya, antara lain:

*   **Panen Lebih Optimal**: Karena semua terkontrol dan terukur, hasil panen melon diharapkan bisa lebih banyak dan berkualitas.
*   **Lebih Efisien**: Penggunaan pupuk dan air bisa lebih hemat karena diberikan sesuai kebutuhan tanaman.
*   **Belajar Langsung**: Mahasiswa INSTIPER bisa langsung praktik bertani modern berbasis data. Nantinya, ilmu ini juga bisa dibagikan ke petani lain.
*   **Solusi Masa Depan**: Teknologi ini diharapkan bisa jadi solusi untuk tantangan pertanian di masa depan, bikin pertanian kita makin modern, efisien, dan berkelanjutan.

INSTIPER bahkan berencana menjadikan fasilitas ini sebagai tempat pelatihan bagi petani, pelaku usaha hortikultura, dan mitra industri. Jadi, teknologi canggih ini nggak cuma buat di kampus, tapi bisa langsung diterapkan di lapangan oleh kita semua.

Saat ini, di rumah kaca pintar ini sedang dibudidayakan melon jenis **Dalmation** dan **Sweet Humi**. Semoga inovasi ini bisa terus berkembang dan membawa kemajuan besar bagi pertanian Indonesia! 🌱🍈

### 🌐 Sumber
[Horti Indonesia](https://hortiindonesia.com)', 'Teknologi Tani', 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=800', '2026-08-31T04:56:48+00:00'::timestamptz),
  ('Jinawi: Pupuk Lebih Pas, Panen Makin Beras!', 'Jinawi bantu petani pupuk lebih tepat dan hemat pakai teknologi canggih, biar tanah subur dan panen melimpah.', '### ⚡ Solusi Cepat
Jinawi bantu petani pupuk lebih tepat dan hemat pakai teknologi canggih, biar tanah subur dan panen melimpah. Nggak ada lagi pupuk terbuang sia-sia!

### 🛠️ Alat & Bahan
- Sensor pintar Jinawi
- Aplikasi RiTx Jinawi (di HP)
- Web Dashboard Jinawi (di komputer/laptop)

### 📖 Panduan Lengkap
Halo Bapak/Ibu Petani Hebat!

Seringkali kita bingung, pupuk yang pas itu seberapa banyak ya? Kapan waktu yang tepat? Kalau salah, bisa-bisa pupuk jadi boros, tanaman kurang subur, bahkan tanah jadi rusak. Nah, sekarang ada solusi cerdas dari Jinawi!

### 🌾 Masalah Pupuk yang Sering Kita Hadapi:

1.  **Boros Duit**: Kadang pupuk kebanyakan, kadang kurang. Soalnya kita nggak tahu persis kebutuhan tanah kita.
2.  **Panen Kurang Maksimal**: Tanaman nggak dapat nutrisi yang pas, jadinya pertumbuhan terhambat dan hasil panen nggak sesuai harapan.
3.  **Tanah Rusak Jangka Panjang**: Kalau pupuknya nggak terukur terus-menerus, kesuburan tanah bisa hilang dan kualitasnya menurun.

### ✨ Jinawi Hadir Sebagai Solusi Pintar!

Jinawi ini sistem pintar yang pakai teknologi canggih (IoT) untuk bantu kita memupuk. Dengan sensor pintar dan aplikasi RiTx Jinawi, kita bisa memupuk:

*   **Tepat Waktu**: Nggak telat, nggak kecepetan.
*   **Tepat Jumlah**: Nggak kurang, nggak kebanyakan.
*   **Tepat Kebutuhan**: Sesuai banget sama apa yang tanah dan tanaman kita butuhkan.

### 🛠️ Apa Saja yang Bisa Jinawi Lakukan?

1.  **Cek Tanah Lengkap**: Jinawi bisa mengukur 7 hal penting di tanah kita secara langsung (real-time):
    *   Kadar N (Nitrogen)
    *   Kadar P (Fosfor)
    *   Kadar K (Kalium)
    *   Tingkat keasaman tanah (pH)
    *   Daya hantar listrik (EC)
    *   Suhu tanah
    *   Kelembaban tanah
2.  **Resep Pupuk Otomatis**: Setelah tanah dicek, Jinawi langsung kasih rekomendasi resep pupuk yang pas di Aplikasi RiTx Jinawi kita.
3.  **Dosis Pas Buat Lahan Kita**: Sistemnya otomatis menyesuaikan jenis dan dosis pupuk. Ini disesuaikan dengan jenis tanaman, jenis tanah, cara kita bertani, dan hasil cek tanah yang terbaru.
4.  **Panduan Sepanjang Musim**: Kita akan dapat panduan memupuk dari sebelum tanam sampai masa pertumbuhan tanaman.

### 📱 Data di Tangan Kita, Kontrol Penuh!

Jinawi ini terhubung dengan sistem digital yang gampang banget dipakai:

*   **Aplikasi RiTx Jinawi (di HP)**:
    *   Bisa langsung aksi cepat dan dapat rekomendasi di lapangan.
    *   Akses instan, riwayat cek tanah tersimpan, dan tampilannya gampang dimengerti.
*   **Web Dashboard Jinawi (di komputer/laptop)**:
    *   Untuk analisis lebih dalam dan mengelola lahan.
    *   Bisa pantau data secara langsung, lihat grafik, petakan lahan, dan cetak laporan (Excel/CSV).

### 👍 Kenapa Petani Pintar Pilih Jinawi?

*   **Hemat Pupuk Sampai 40%**: Pemupukan jadi lebih pas, nggak ada lagi pupuk yang terbuang sia-sia. Dompet lebih tebal!
*   **Gampang Dipakai**: Alatnya ringan, tampilannya sederhana, jadi siapa saja bisa mengoperasikannya dengan nyaman.
*   **Data Tersimpan Rapi**: Semua riwayat pemupukan tersimpan dan gampang dipantau lewat aplikasi. Jadi kita punya catatan lengkap.
*   **Panen Maksimal**: Nutrisi yang pas bikin tanaman lebih sehat dan hasil panen jadi lebih banyak dan berkualitas.
*   **Produk Asli Indonesia**: Jinawi ini buatan anak bangsa dengan kualitas teruji dan ada dukungan teknis yang terpercaya. Bangga pakai produk sendiri!

Banyak petani sudah merasakan manfaatnya, biaya pupuk lebih hemat dan hasil panen meningkat!

Yuk, saatnya bertani lebih cerdas dan presisi dengan Jinawi! Kalau mau tahu lebih lanjut, jangan sungkan hubungi kami ya!

### 🌐 Sumber
[MSMB Indonesia](https://msmbindonesia.com)', 'Teknologi Tani', 'https://images.unsplash.com/photo-1536657464919-892534f60d6e?w=800', '2026-08-31T05:02:15+00:00'::timestamptz),
  ('Petani Siap Hadapi Kemarau: Tips Jitu Agar Panen Tetap Berlimpah!', 'Musim kemarau memang tantangan, tapi dengan persiapan matang seperti hemat air, pilih bibit tahan kering, dan siapkan pakan ternak…', '### ⚡ Solusi Cepat
Musim kemarau memang tantangan, tapi dengan persiapan matang seperti hemat air, pilih bibit tahan kering, dan siapkan pakan ternak alternatif, hasil panen dan ternak kita tetap bisa aman dan melimpah.

### 🛠️ Alat & Bahan
- Sistem irigasi hemat air (tetes/sprinkler)
- Bibit tanaman unggul yang tahan kekeringan
- Pupuk organik untuk menjaga kelembaban tanah
- Bahan baku pakan hijauan alternatif (jerami, limbah pertanian)
- Alat pemadam api sederhana (untuk pencegahan karhutla)

### 📖 Panduan Lengkap
Halo para petani hebat di seluruh Indonesia! 👋

Musim kemarau seringkali jadi momok yang bikin khawatir. Air susah, tanaman layu, pakan ternak menipis. Tapi jangan khawatir! Dengan persiapan yang tepat, kita bisa kok tetap panen melimpah dan ternak sehat. Yuk, simak tips-tips praktis dari kami:

### 💧 **Hemat Air Itu Kunci!**

Saat kemarau, air jadi harta karun. Jangan boros ya! Coba pakai sistem irigasi yang lebih hemat air seperti irigasi tetes atau sprinkler. Kalau bisa, manfaatkan sumur bor atau tampungan air hujan. Menyiramnya di pagi atau sore hari juga lebih baik agar air tidak cepat menguap.

### 🌱 **Pilih Bibit yang Kuat dan Tahan Banting**

Untuk tanaman seperti jagung atau kopi, penting banget pilih bibit yang sudah terbukti tahan kekeringan dan cocok dengan kondisi tanah di daerah kita. Bibit yang adaptif ini bisa bikin tanaman tetap produktif walau air terbatas. Jangan lupa juga pakai pupuk organik untuk menjaga tanah tetap gembur dan bisa menahan air lebih lama.

### 🐄 **Pakan Ternak Aman Saat Kemarau**

Rumput dan hijauan pasti berkurang drastis. Nah, ini saatnya kita kreatif! Siapkan pakan alternatif seperti silase (fermentasi hijauan), ampas tahu, atau limbah pertanian lainnya. Dengan begitu, ternak kita tetap kenyang dan sehat, tidak kelaparan di musim kering.

### 🔥 **Waspada Kebakaran Lahan!**

Musim kemarau juga rawan kebakaran hutan dan lahan (karhutla). Hati-hati ya, jangan membakar sampah atau sisa tanaman sembarangan. Bersihkan area sekitar kebun dari semak belukar kering yang mudah terbakar. Lebih baik mencegah daripada menyesal!

### ☕ **Kopi Tetap Berbuah Manis**

Bagi petani kopi, kemarau bukan berarti hasil panen menurun. Pastikan pohon kopi mendapatkan nutrisi cukup, lakukan pemangkasan yang tepat, dan kalau memungkinkan, berikan mulsa di sekitar pangkal pohon untuk menjaga kelembaban tanah.

Dengan persiapan yang matang dan semangat gotong royong, kita pasti bisa melewati musim kemarau dengan hasil yang memuaskan. Semangat terus para pejuang pangan Indonesia! 💪🇮🇩

### 🌐 Sumber
[IPB Digitani](https://digitani.ipb.ac.id)', 'Cuaca & Musim', 'https://images.unsplash.com/photo-1534274988757-a28bf1a57c17?w=800', '2026-08-31T05:02:53+00:00'::timestamptz),
  ('PTPN Group Ajak Petani Garap Bawang Putih Besar-besaran di Jawa Barat, Siap Swasembada!', 'PTPN Group sedang gencar mengembangkan kebun bawang putih di Jawa Barat seluas 10.000 hektar, bahkan akan diperluas lagi.', '### ⚡ Solusi Cepat
PTPN Group sedang gencar mengembangkan kebun bawang putih di Jawa Barat seluas 10.000 hektar, bahkan akan diperluas lagi. Program ini bertujuan agar Indonesia tidak perlu impor bawang putih lagi dan petani bisa ikut sejahtera dengan pola kemitraan.

### 📖 Panduan Lengkap
Halo Sedulur Tani di seluruh Indonesia, khususnya di Jawa Barat! Ada kabar gembira nih dari PTPN Group. Mereka lagi serius banget mau mengembangkan kebun bawang putih di Jawa Barat. Tujuannya mulia, biar negara kita nggak perlu impor bawang putih lagi alias bisa swasembada!

### Program Besar Bawang Putih PTPN Group

PTPN Group ini punya rencana besar, lho. Mereka mau menanam bawang putih di lahan seluas 10.000 hektar di Jawa Barat sebagai tahap awal. Nantinya, sampai tahun 2029, targetnya bisa sampai 24.000 hektar! Wah, luas sekali ya?

Kenapa kok PTPN Group semangat banget? Soalnya, kebutuhan bawang putih di Indonesia ini besar sekali, sekitar 600.000 ton per tahun. Tapi, produksi dalam negeri kita baru sekitar 39.000-40.000 ton saja. Jauh banget kan bedanya? Nah, ini jadi peluang besar buat kita para petani untuk ikut menanam dan memenuhi kebutuhan nasional.

### Petani Diajak Bermitra, Dijamin Untung!

PTPN Group nggak sendirian kok. Mereka menggandeng banyak pihak, termasuk kelompok tani dan masyarakat. Jadi, kalau ada lahan yang masih dikelola masyarakat, PTPN siap ajak bermitra. Tujuannya jelas, biar masyarakat dan petani juga ikut merasakan manfaat ekonominya.

Kata Pak Denaldy Mulino Mauna, Direktur Utama PTPN III, program ini bukan cuma kejar target luas lahan, tapi mau bangun industri bawang putih yang sehat, berkelanjutan, dan bikin petani sejahtera.

### Fokus Utama: Benih Berkualitas dan Lahan yang Pas

Salah satu kunci sukses menanam bawang putih itu benihnya harus bagus. Nah, PTPN Group akan fokus menyediakan benih bawang putih yang berkualitas dulu. Kalau benihnya sudah kuat, baru deh kita genjot produksinya buat memenuhi kebutuhan konsumsi.

Soal lahan, PTPN juga siap bantu mencarikan. Mereka akan koordinasi sama pemerintah daerah untuk identifikasi lahan yang cocok. Jadi, petani nggak perlu pusing mikirin lahan.

### Target Hasil Panen yang Menggiurkan

Dengan dukungan penuh dari Holding Perkebunan Nusantara dan pemerintah daerah, PTPN menargetkan hasil panen bawang putih bisa meningkat. Awalnya, ditargetkan 10,8 ton bawang putih kering per hektar, lalu di tahun keempat bisa naik jadi 12,1 ton per hektar. Lumayan banget kan hasilnya?

### Persiapan Matang, dari Hulu sampai Hilir

PTPN Group ini kerjanya nggak main-main. Mereka sudah cek lokasi dan lahan sampai 100% di pertengahan Agustus 2026. Persiapan benih, pembukaan lahan, sampai urusan izin juga terus dikebut.

Mereka juga mau bangun ekosistem bawang putih yang terintegrasi, mulai dari:
*   **Perbenihan**: Menyediakan benih unggul.
*   **Produksi**: Cara tanam yang baik.
*   **Teknologi Budidaya**: Pakai cara-cara modern dan ramah lingkungan (bekerja sama dengan IPB).
*   **Pengolahan**: Setelah panen mau diapakan.
*   **Pemasaran**: Biar hasil panen petani ada yang beli dan harganya bagus.

Semua pihak diajak kerja sama, mulai dari pemerintah, petani, akademisi, BUMN, sampai pengusaha. Harapannya, rantai pasok bawang putih nasional jadi kuat dan produksi kita makin berkelanjutan.

Jadi, buat para petani di Jawa Barat, ini kesempatan emas untuk ikut serta dalam program besar ini. Mari kita sukseskan swasembada bawang putih nasional dan tingkatkan kesejahteraan bersama!

### 🌐 Sumber
[Horti Indonesia](https://hortiindonesia.com)', 'Lainnya', 'https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?w=800', '2026-08-31T05:28:46+00:00'::timestamptz),
  ('Jinawi: Teknologi Pintar untuk Pertanian Makin Maju dan Panen Melimpah!', 'Teknologi Jinawi hadir untuk bantu petani memupuk lebih tepat dan efisien.', '### ⚡ Solusi Cepat
Teknologi Jinawi hadir untuk bantu petani memupuk lebih tepat dan efisien. Dengan info tanah real-time di HP, petani bisa ambil keputusan akurat, bikin hasil panen makin bagus dan hemat biaya.

### 🛠️ Alat & Bahan
- Sistem Jinawi
- Aplikasi RiTx Jinawi
- Smartphone

### 📖 Panduan Lengkap
Halo, Sedulur Petani Pintar di seluruh Indonesia! 👋

Pernah dengar soal Pekan Agro Digital & Inovasi (PADI) Jawa Tengah 2026? Nah, ini dia acara keren yang baru saja digelar di Agro Center Soropadan, dari tanggal 23 sampai 27 April 2026 kemarin. Acara ini jadi ajang kumpulnya para petani, anak muda inovator, dan semua pihak yang peduli pertanian, buat sama-sama belajar dan kenalan sama teknologi baru yang bisa bikin pertanian kita makin maju dan hasilnya melimpah ruah! 🌾

PADI 2026 ini digagas sama anak-anak muda petani dari berbagai daerah di Jawa Tengah lho. Mereka punya semangat tinggi buat bikin pertanian kita lebih modern, efisien, dan berkelanjutan. Temanya juga keren banget: ''Mewujudkan Regenerasi Petani Unggul dan Akselerasi Swasembada Pangan melalui Inovasi Pertanian Berkelanjutan''. Intinya, mereka mau ngajak petani muda dan senior buat bareng-bareng bangun pertanian yang lebih baik, biar kita semua bisa mandiri pangan! 💪

Pemerintah daerah juga ikut mendukung penuh acara ini, lho. Tujuannya jelas, biar petani makin sejahtera dan pertanian kita makin kuat. Di sini, banyak banget teknologi canggih yang diperkenalkan, yang bisa bantu kita mengatasi berbagai tantangan di sawah atau ladang, terutama biar budidaya makin efisien dan hasilnya makin akurat.

Salah satu bintangnya di acara PADI 2026 kemarin adalah teknologi *smart farming* namanya **Jinawi** dari MSMB Indonesia. Apa itu Jinawi? 🤔

**Jinawi itu ibarat asisten pintar buat urusan pupuk di lahan kita!** 🧑‍🌾
Ini adalah sistem canggih yang pakai teknologi IoT (Internet of Things) buat kasih rekomendasi pemupukan. Jinawi bisa kasih tahu kondisi tanah kita secara langsung (real-time) lewat HP, mulai dari:
*   Kandungan unsur hara N, P, K (yang penting buat pertumbuhan tanaman)
*   Tingkat keasaman tanah (pH)
*   Daya hantar listrik tanah (EC)
*   Suhu tanah
*   Sampai kelembaban tanah

Hebatnya lagi, Jinawi ini sudah terhubung sama aplikasi **RiTx Jinawi** di *smartphone* kita. Jadi, semua data dan rekomendasi pupuk bisa langsung kita lihat di HP. Gampang banget kan? Dengan begitu, kita bisa ambil keputusan yang lebih tepat dan cepat soal pupuk, nggak perlu lagi kira-kira. Hasilnya? Tanaman sehat, panen melimpah, dan biaya pupuk bisa lebih hemat! 💰

Seperti kata Pak Farid Meisa, Head of Marketing MSMB, ''Partisipasi kami di PADI 2026 ini penting banget buat ngenalin teknologi pertanian yang sudah kami kembangin, biar bisa dipakai lebih luas sama petani dan semua pihak di sektor pertanian. Harapannya, solusi ini bisa ningkatin hasil panen dan bikin budidaya makin efisien.'' 👍

MSMB berkomitmen terus mendukung pertanian Indonesia lewat solusi digital. Ke depannya, teknologi *smart farming* kayak Jinawi ini diharapkan jadi pondasi utama buat bikin pertanian kita makin maju, tangguh, dan siap menghadapi tantangan zaman. Yuk, kita manfaatkan teknologi biar pertanian kita makin jaya! 🚀

### 🌐 Sumber
[MSMB Indonesia](https://msmbindonesia.com)', 'Teknologi Tani', 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=800', '2026-08-31T05:29:13+00:00'::timestamptz),
  ('Kamus Istilah Hidroponik untuk Pemula: Kenali Istilah Ini Biar Praktik Makin Lancar!', 'Bagi Petani yang baru mau mencoba sistem hidroponik (tanam tanpa tanah), penting untuk mengenal istilah dasar seperti jenis nutrisi, media…', '### ⚡ Solusi Cepat
Bagi Petani yang baru mau mencoba sistem hidroponik (tanam tanpa tanah), penting untuk mengenal istilah dasar seperti jenis nutrisi, media tanam, dan model instalasinya. Dengan memahami istilah-istilah ini, kita bisa merawat sayuran hidroponik dengan lebih tepat dan terhindar dari salah takar pupuk.

### 🛠️ Alat & Bahan
- Nutrisi AB Mix
- Media tanam Rockwool
- Netpot (pot berlubang)
- Kain flanel / sumbu
- EC Meter / TDS Meter
- Instalasi pipa atau talang air

### 📖 Panduan Lengkap
Halo Sahabat Tani! Bertani hidroponik atau menanam sayuran menggunakan media air kini makin digemari karena hemat lahan dan hasilnya bersih. Tapi buat yang baru mulai, kadang suka bingung dengan istilah-istilah teknisnya. 

Yuk, kita kenali istilah penting hidroponik dengan bahasa yang gampang dipahami:

### 🥗 1. Nutrisi & Air
* **Nutrisi AB Mix**: Pupuk khusus hidroponik yang terdiri dari pekatan A dan B. Keduanya harus dilarutkan terpisah dulu, baru dicampur ke bak air sesuai takaran agar tanaman sehat dan subur.
* **TDS / PPM**: Angka yang menunjukkan kepekatan/kandungan pupuk di dalam air. Semakin tinggi PPM, artinya larutan pupuk semakin kental.
* **pH Air**: Tingkat keasaman air nutrisi. Sayuran hidroponik paling cocok di pH kisaran **5,5 - 6,5** agar akar gampang menyerap makanan.
* **EC Meter**: Alat pengukur kepekatan nutrisi dalam air secara praktis dan akurat.

### 🪴 2. Wadah & Media Semai
* **Rockwool**: Busa serat khusus yang ringan dan sangat bagus menahan air. Cocok sekali dipakai untuk menyemai benih sayuran.
* **Netpot**: Pot plastik kecil berlubang-lubang untuk tempat duduk tanaman. Lubangnya berguna agar akar leluasa keluar menyerap air nutrisi.

### 💧 3. Jenis Sistem Hidroponik
* **Wick System (Sistem Sumbu)**: Cara paling sederhana dan murah. Menggunakan sumbu kain flanel untuk mengalirkan nutrisi dari wadah bawah ke akar tanaman tanpa butuh pompa listrik.
* **NFT (Nutrient Film Technique)**: Sistem aliran tipis berkelanjutan. Air nutrisi dialirkan tipis-tipis seperti lapisan film di dalam pipa/talang secara terus-menerus.
* **DFT (Deep Flow Technique)**: Sistem genangan dangkal. Mirip NFT, tapi lapisan airnya lebih dalam sehingga masih ada cadangan air jika listrik padam.

**Tips Praktis:**
Untuk pemula, mulailah mencoba dari sistem sumbu (*Wick System*) yang sederhana terlebih dahulu. Selalu pantau kondisi air dan kepekatan nutrisi agar sayuran tumbuh subur dan panen melimpah!

### 🌐 Sumber
[MSMB Indonesia](https://msmbindonesia.com)', 'Teknologi Tani', 'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?w=800', '2026-08-31T07:17:44+00:00'::timestamptz),
  ('Tips Menjaga Air Kolam Koi Tetap Bening dan Cara Aman Pindah Ikan Tanpa Stres', 'Gunakan sistem filtrasi fisik (pompa dan busa/dakron) yang dibersihkan setiap hari agar air tetap jernih dan kaya oksigen.', '### ⚡ Solusi Cepat
Gunakan sistem filtrasi fisik (pompa dan busa/dakron) yang dibersihkan setiap hari agar air tetap jernih dan kaya oksigen. Endapkan air baru minimal 1 hari di tandon sebelum digunakan, dan pindahkan ikan menggunakan serokan jaring halus secara cepat namun lembut.

### 🛠️ Alat & Bahan
- Pompa celup air
- Filter mekanik (busa / dakron)
- Bak tandon penampungan air
- Serokan atau seser jaring berbahan halus
- Antibiotik / obat antistres khusus ikan (jika diperlukan)

### 📖 Panduan Lengkap
Halo Sobat Tani dan Pembudidaya! Memelihara ikan koi memang butuh perhatian khusus, terutama pada kebersihan air dan cara penanganan saat memilah ukuran ikan. Ikan koi sangat menyukai air yang mengalir, jernih, dan kaya akan oksigen.

Berikut langkah mudah dan praktis mengelola kolam koi agar air tidak cepat keruh dan ikan tidak mudah mati saat dipindahkan:

### 1. Pasang dan Bersihkan Filter Fisik Kolam 💧
* Pasang pompa celup dengan kapasitas aliran air yang sesuai dengan ukuran kolam dan jumlah ikan.
* Alirkan air melewati filter fisik seperti busa atau dakron untuk menyaring kotoran padat.
* **Rutin bersihkan filter fisik setiap hari** agar kotoran tidak menumpuk dan mencemari air kembali. Dengan cara ini, Sobat tidak perlu terlalu sering menguras air kolam.

### 2. Selalu Endapkan Air Baru Sebelum Masuk Kolam 🪣
* Jangan langsung memasukkan air sumur atau air PDAM langsung ke kolam saat pergantian air.
* Siapkan **bak tandon khusus** dan endapkan air lebih dari 1 hari. Tujuannya agar gas beracun dari tanah atau zat kaporit PDAM menguap terlebih dahulu sehingga aman untuk ikan.

### 3. Teknik Memindahkan Ikan Koi yang Aman (Cegah Stres) 🐟
* Gunakan serokan atau wadah penangkap yang berbahan lembut/halus agar tidak melukai sisik dan lendir pelindung tubuh ikan.
* Lakukan proses pemindahan secara **cepat namun tetap hati-hati dan lembut**, jangan membuat ikan kaget atau melompat.
* Jika ikan terlihat lemas atau luka setelah dipindah, berikan antibiotik atau obat antistres khusus ikan sesuai takaran/dosis yang tertera pada kemasan.

Dengan menjaga kebersihan filter dan memperlakukan ikan secara halus, koi kesayangan akan tetap sehat, lincah, dan warnanya semakin indah!

### 🌐 Sumber
[IPB Digitani](https://digitani.ipb.ac.id)', 'Tips Tani', 'https://images.unsplash.com/photo-1522069169874-c58ec4b76be5?w=800', '2026-08-31T07:34:20+00:00'::timestamptz),
  ('Sawah Tetap Menghasilkan di Musim Kemarau: Tanam Kacang Hijau Hemat Air', 'Saat musim kemarau dan pasokan air terbatas (Musim Tanam 3), petani disarankan beralih menanam kacang hijau.', '### ⚡ Solusi Cepat
Saat musim kemarau dan pasokan air terbatas (Musim Tanam 3), petani disarankan beralih menanam kacang hijau. Tanaman ini sangat hemat air dan berumur genjah sehingga cepat dipanen dalam waktu 60–70 hari.

### 🛠️ Alat & Bahan
- Benih kacang hijau unggul
- Lahan sawah/kebun setelah panen utama
- Cangkul / alat olah tanah sederhana
- Pupuk dasar secukupnya

### 📖 Panduan Lengkap
Halo Sobat Tani! Memasuki musim kemarau (Musim Tanam 3), banyak lahan sawah yang sering dibiarkan menganggur atau *bera* karena pasokan air irigasi yang mulai surut. Padahal, lahan tetap bisa menghasilkan pemasukan tanpa perlu khawatir kekurangan air.

### 🌱 Mengapa Pilih Kacang Hijau?
Kacang hijau adalah pilihan paling cocok untuk ditanam saat musim kering sebagai tanaman sela (palawija). Berikut keunggulannya:

* 💧 **Hemat Air:** Kacang hijau tidak membutuhkan genangan air seperti padi dan tahan terhadap kondisi tanah yang agak kering.
* ⏱️ **Cepat Panen:** Umur tanamnya sangat singkat, hanya butuh waktu sekitar **60 hingga 70 hari** sudah bisa dipanen.
* 💰 **Nilai Jual Bagus:** Permintaan pasar untuk kacang hijau selalu stabil, cocok untuk menjaga perputaran uang dapur.
* 🌿 **Menyuburkan Tanah:** Tanaman kacang-kacangan mampu mengikat nitrogen bebas, sehingga tanah menjadi lebih subur untuk musim tanam padi berikutnya.

### 💡 Tips Menanam Kacang Hijau di Musim Kemarau:
1. **Manfaatkan Sisa Kelembapan:** Segera tanam setelah panen padi saat tanah masih menyimpan sedikit sisa kelembapan.
2. **Olah Tanah Minimal (TOT):** Tidak perlu membajak terlalu dalam agar kelembapan air tanah tidak cepat menguap.
3. **Perhatikan Saluran Drainase:** Buat parit kecil untuk antisipasi jika sewaktu-waktu ada hujan kiriman agar akar tidak busuk.

### 🌐 Sumber
[IPB Digitani](https://digitani.ipb.ac.id)', 'Cuaca & Musim', 'https://images.unsplash.com/photo-1536657464919-892534f60d6e?w=800', '2026-08-31T07:53:21+00:00'::timestamptz),
  ('Cara Mudah Merawat Air Kolam Koi Tetap Bening dan Pindah Ikan Tanpa Bikin Stres', 'Gunakan filter mekanik (busa/dakron) yang dicuci rutin setiap hari dan selalu endapkan air baru di tandon minimal 24 jam sebelum dipakai.', '### ⚡ Solusi Cepat
Gunakan filter mekanik (busa/dakron) yang dicuci rutin setiap hari dan selalu endapkan air baru di tandon minimal 24 jam sebelum dipakai. Saat memilah atau memindahkan koi, gunakan seser halus dengan gerakan perlahan agar ikan tidak panik dan lecet.

### 🛠️ Alat & Bahan
- Pompa celup air
- Busa atau dakron filter
- Tandon/bak penampung endapan air
- Seser atau wadah pemindah berpori halus
- Obat antistres atau antibiotik ikan (bila perlu)

### 📖 Panduan Lengkap
Halo Sobat Pembudidaya! Memelihara ikan koi memang butuh ketelatenan ekstra karena koi menyukai air yang bening dan beroksigen tinggi. Bila kolam cepat keruh, bau, atau ikan sering lemas dan mati sehabis disortir, yuk ikuti tips mudah berikut:

### 💧 1. Kunci Air Bersih Tanpa Sering Kuras Habis
* **Pasang Filter Fisik:** Pasang pompa celup yang mengalirkan air kolam ke kotak filter berisi busa atau dakron. Filter ini bertugas menyaring kotoran padat dan sisa pakan.
* **Rutin Cuci Filter:** Bersihkan busa/dakron penyaring setiap hari agar kotoran tidak menumpuk kembali ke kolam.
* **Atur Kepadatan Kolam:** Jangan tebar ikan terlalu padat. Semakin padat kolam, semakin cepat air kotor dan kadar oksigen turun.

### 🚰 2. Jangan Langsung Pakai Air Keran/Sumur Baru!
* Sebelum menambah atau mengganti air kolam, tampung dulu air di dalam tandon minimal **1 hari (24 jam)**.
* Pengendapan ini berguna agar zat berbahaya seperti kaporit atau gas beracun menguap alami, serta suhu air menjadi lebih stabil.

### 🐟 3. Trik Memindahkan Ikan Koi Agar Tidak Stres & Mati
* **Gunakan Alat yang Lembut:** Pakai seser atau jaring dengan jaring yang halus dan basahi wadah penampung agar sisik koi tidak rontok atau luka.
* **Gerakan Pelan dan Tenang:** Hindari mengejar-ngejar ikan secara kasar. Tangkap dengan tenang tapi mantap.
* **Perlakuan Ekstra:** Jika ada ikan yang tampak kelelahan atau lecet ringan setelah pemindahan, berikan obat penenang/antibiotik khusus ikan sesuai takaran pada kemasan.

Dengan menjaga kebersihan filter dan cara pemindahan yang lembut, ikan koi kesayangan akan tetap lincah, sehat, dan tidak gampang mati!

### 🌐 Sumber
[IPB Digitani](https://digitani.ipb.ac.id/bagaimana-cara-pengelolaan-kualitas-air-dan-penanganan-stres-pada-budidaya-ikan-koi/)', 'Lainnya', 'https://images.unsplash.com/photo-1522069169874-c58ec4b76be5?w=800', '2026-09-17T02:57:37+00:00'::timestamptz),
  ('Mengenal Jinawi: Alat Cerdas untuk Cek Kesuburan Tanah dan Takaran Pupuk Lewat HP', 'Gunakan teknologi sensor pintar seperti Jinawi untuk mengecek kondisi dan kebutuhan hara tanah langsung lewat HP.', '### ⚡ Solusi Cepat
Gunakan teknologi sensor pintar seperti Jinawi untuk mengecek kondisi dan kebutuhan hara tanah langsung lewat HP. Dengan takaran pupuk yang tepat dan pas, biaya pemupukan jadi lebih hemat dan hasil panen lebih maksimal.

### 🛠️ Alat & Bahan
- Perangkat sensor tanah pintar (Jinawi)
- Smartphone / HP Android
- Aplikasi RiTx Jinawi

### 📖 Panduan Lengkap
Halo Sedulur Tani!

Saat ini dunia pertanian kita makin maju dan modern. Di acara Pekan Agro Digital & Inovasi (PADI) Jawa Tengah 2026, hadir inovasi baru yang sangat bermanfaat untuk mempermudah kerja kita di sawah atau kebun, yaitu teknologi smart farming bernama **Jinawi**.

### 🌾 Apa Itu Teknologi Jinawi?
Jinawi adalah alat sensor pintar yang bisa membaca kondisi tanah secara langsung di lahan. Selama ini, kita sering kali mengira-ngira takaran pupuk, sehingga kadang kebanyakan atau malah kurang. Nah, alat Jinawi ini bertugas ''memeriksa kesehatan'' tanah kita secara nyata dan akurat.

### 🔍 Apa Saja yang Bisa Dicek?
Alat ini bisa membaca kondisi penting tanah, antara lain:
* **Kandungan Hara N, P, dan K**: Mengetahui apakah tanah kurang pupuk urea, SP-36, atau KCL.
* **pH Tanah (Tingkat Keasaman)**: Memastikan tanah tidak terlalu asam agar tanaman bisa menyerap pupuk dengan baik.
* **Kelembapan dan Suhu Tanah**: Membantu kita tahu kapan waktu yang pas untuk pengairan.

### 📱 Terhubung Langsung ke Layar HP
Data yang dibaca oleh sensor Jinawi langsung dikirim ke aplikasi **RiTx Jinawi** di smartphone Sedulur. Lewat aplikasi ini, kita langsung diberi tahu rekomendasi takaran pupuk yang pas sesuai kebutuhan tanaman.

### 💡 Manfaat untuk Petani:
1. **Hemat Biaya Pupuk**: Tidak ada lagi pupuk yang terbuang sia-sia karena dosis sudah pas.
2. **Tanah Tetap Subur**: Mencegah tanah rusak atau terlalu asam akibat kelebihan pupuk kimia.
3. **Hasil Panen Meningkat**: Tanaman tumbuh lebih sehat karena mendapat nutrisi yang tepat pada waktu yang tepat.

Mari kita sambut kemajuan teknologi ini agar pertanian kita semakin maju, hemat, dan menguntungkan!

### 🌐 Sumber
[MSMB Indonesia](https://msmbindonesia.com/smart-farming-jinawi-padi-jateng-2026/)', 'Teknologi Tani', 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800', '2026-09-17T03:00:48+00:00'::timestamptz),
  ('Benih Sawi Belum Tumbuh Setelah Ditanam? Ini Penyebab dan Solusinya!', 'Diamkan olahan tanah, kapur dolomit, dan kotoran ayam selama minimal 1-2 minggu sebelum tanam agar tanah tidak panas.', '### ⚡ Solusi Cepat
Diamkan olahan tanah, kapur dolomit, dan kotoran ayam selama minimal 1-2 minggu sebelum tanam agar tanah tidak panas. Saat menyemai, kubur benih tipis-tipis saja (sekitar 0,5–1 cm) dan jaga tanah tetap lembap, tidak kekeringan dan jangan sampai tergenang/becek.

### 🛠️ Alat & Bahan
- Benih sawi berkualitas
- Kotoran ayam yang sudah matang/difermentasi
- Kapur dolomit
- Sekam padi
- Tisu basah dan wadah tertutup (untuk tes benih)

### 📖 Panduan Lengkap
Halo Sedulur Tani! Wajar sekali jika merasa cemas saat benih sawi yang disebar belum juga menunjukkan tanda-tanda tumbuh setelah 5 hari. Normalnya, benih sawi mulai berkecambah dalam waktu 2 sampai 5 hari, tapi jika belum muncul tunas, jangan buru-buru dibongkar dulu ya. 

Berikut beberapa penyebab umum benih sawi lambat atau gagal tumbuh beserta solusinya:

### 🌾 1. Tanah Masih ''Panas'' Akibat Pupuk Kandang & Dolomit
Kotoran ayam yang kering belum tentu matang sempurna, sedulur. Jika belum terfermentasi penuh, kotoran ayam masih mengeluarkan gas amonia dan hawa panas yang bisa membuat embrio benih mati atau busuk. Begitu juga kapur dolomit yang baru diaduk.
* **Solusinya:** Setelah tanah dicampur kotoran ayam dan dolomit, jangan langsung ditanami. Siram dan diamkan (inkubasi) dulu selama 1–2 minggu agar tanah dingin dan netral.

### 🌱 2. Benih Tertanam Terlalu Dalam
Ukuran biji sawi itu sangat kecil. Kalau tertimbun tanah terlalu tebal, tenaga benih tidak cukup kuat untuk mendorong tunas keluar ke permukaan.
* **Solusinya:** Cukup tabur atau benamkan benih sedalam 0,5 sampai 1 cm saja, lalu tutup tipis-tipis dengan tanah halus atau abu sekam.

### 💧 3. Tanah Terlalu Kering atau Malah Becek
Benih butuh kelembapan pas untuk ''membangunkan'' tunasnya. Kalau tanah terlalu kering, benih tidak bisa pecah. Tapi kalau terlalu basah dan tergenang air, benih akan kekurangan udara lalu membusuk.
* **Solusinya:** Jaga tanah selalu lembap seperti spons yang diperas. Siram pakai semprotan halus (gembor/sprayer) agar benih tidak hanyut.

### ☀️ 4. Suhu Terlalu Panas atau Dingin
Benih sawi tumbuh optimal di suhu 20–30°C. Terik matahari siang yang membakar tanah semaian bisa membuat benih gagal tumbuh.
* **Solusinya:** Beri naungan ringan (seperti paranet atau dedaunan) di atas bedengan semai selama masa berkecambah.

### 🧪 Cara Mudah Tes Benih: Uji Tisu Basah
Jika sudah menunggu 7–10 hari dan sawi tetap tidak tumbuh, yuk cek apakah benihnya masih bagus:
1. Ambil 10 butir benih sawi.
2. Letakkan di atas tisu basah di dalam wadah atau piring tertutup.
3. Simpan di tempat teduh selama 2-3 hari.
* **Hasil:** Jika di tisu benih berkecambah tapi di tanah tidak, berarti tanah/media tanam Anda yang bermasalah. Namun jika di tisu juga tidak bertunas, berarti kualitas benih memang sudah rusak atau kedaluwarsa.

### 🌐 Sumber
[IPB Digitani](https://digitani.ipb.ac.id/apa-yang-menyebabkan-tanaman-sawit-tidak-tumbuh/)', 'Tips Tani', 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=800', '2026-09-17T03:02:19+00:00'::timestamptz),
  ('Resep Rahasia Pupuk AB Mix Melon Sendiri, Panen Pasti Melimpah!', 'Pak Tani dan Bu Tani, mau melonnya subur dan buahnya banyak?', '### ⚡ Solusi Cepat
Pak Tani dan Bu Tani, mau melonnya subur dan buahnya banyak? Kuncinya ada di pupuk AB Mix yang pas! Yuk, kita bikin sendiri pupuk cair khusus melon ini, gampang kok, biar tanaman sehat dan panen melimpah ruah!

### 🛠️ Alat & Bahan
- 2 buah wadah atau ember bersih (untuk larutan A dan B)
- Pengaduk
- Air bersih (kalau bisa air hujan atau air sumur yang jernih, bukan air PAM yang banyak kaporitnya)
- Paket bahan pupuk AB Mix khusus melon (biasanya ada kantong A dan kantong B)
- Botol atau jerigen gelap untuk menyimpan larutan stok
- Alat ukur PPM atau EC meter (penting untuk hasil maksimal)

### 📖 Panduan Lengkap
Halo Pak Tani dan Bu Tani semua! 👋 Mau tanaman melonnya sehat, subur, dan buahnya banyak? Nah, salah satu rahasianya ada di nutrisi atau pupuk AB Mix yang pas. Pupuk ini khusus untuk melon yang ditanam secara hidroponik atau sistem irigasi tetes. Jangan khawatir, bikinnya gampang kok! Yuk, kita ikuti langkah-langkahnya.

### 🛠️ Apa Saja yang Perlu Disiapkan?

Sebelum mulai meracik, siapkan dulu alat dan bahannya ya:
*   **2 buah wadah atau ember bersih** (untuk larutan A dan larutan B, jangan sampai tertukar!)
*   **Pengaduk** (bisa pakai kayu atau sendok besar)
*   **Air bersih** (penting! Kalau bisa pakai air hujan atau air sumur yang jernih, yang kandungan mineralnya sedikit, di bawah 100 ppm. Jangan pakai air PAM yang banyak kaporitnya ya.)
*   **Paket bahan pupuk AB Mix khusus melon** (biasanya sudah dipisah jadi kantong A dan kantong B)
*   **Botol atau jerigen gelap** untuk menyimpan larutan stok (supaya tidak kena sinar matahari langsung)
*   **Alat ukur PPM atau EC meter** (ini penting banget biar takaran nutrisinya pas, melon jadi sehat!)

### 🧪 Cara Bikin Larutan Stok (Induk) AB Mix

Larutan stok ini nantinya akan kita campur lagi dengan air saat mau menyiram tanaman. Kita akan bikin masing-masing 5 liter larutan stok A dan 5 liter larutan stok B.

1.  **Siapkan Wadah dan Air Dasar**
    *   Ambil Wadah A dan Wadah B. Isi masing-masing wadah dengan air hangat atau air bersih sekitar 3-4 liter.

2.  **Larutkan Stok A**
    *   Masukkan semua isi kantong bahan A (biasanya isinya Kalsium Nitrat, Kalium Nitrat, dan Fe-EDTA) ke dalam Wadah A.
    *   Aduk terus sampai semua serbuk larut sempurna, tidak ada yang menggumpal.
    *   Setelah larut, tambahkan lagi air bersih ke Wadah A sampai volumenya tepat 5 liter.

3.  **Larutkan Stok B**
    *   Lakukan hal yang sama untuk kantong bahan B (biasanya isinya Magnesium Sulfat, MKP, Unsur Mikro, dll.) ke dalam Wadah B.
    *   Aduk sampai benar-benar larut semua.
    *   Tambahkan air bersih ke Wadah B sampai volumenya tepat 5 liter.

4.  **Penyimpanan Stok (Penting!)**
    *   Pindahkan kedua larutan stok (Stok A dan Stok B) ke botol atau jerigen terpisah yang tidak tembus cahaya matahari langsung.
    *   **INGAT! Jangan pernah menggabungkan Stok A dan Stok B dalam bentuk pekat ini!** Kenapa? Karena nanti kalsium di Stok A bisa bereaksi dengan sulfat/fosfat di Stok B dan malah jadi endapan atau kerak yang tidak bisa diserap tanaman. Jadi, simpan terpisah ya!

### 💧 Cara Pakai ke Tanaman Melon (Larutan Siap Siram)

Setelah larutan stok jadi, sekarang kita siap menyiram tanaman melon kesayangan. Ini cara mencampurnya untuk larutan siap siram di tangki atau tandon air:

1.  **Takaran Standar**
    *   Campurkan **5 mL Stok A** + **5 mL Stok B** ke dalam **1 Liter air bersih**. Ini takaran standar ya.
    *   Kalau mau bikin banyak, tinggal dikalikan saja. Misalnya, untuk 10 liter air, berarti 50 mL Stok A + 50 mL Stok B.

2.  **Ukur dengan TDS/EC Meter**
    *   Setelah dicampur, aduk rata. Lalu, ukur larutan ini pakai alat ukur PPM atau EC meter.
    *   Sesuaikan angkanya dengan fase pertumbuhan melon Anda. Ini penting banget biar melon dapat nutrisi yang pas!

### 📈 Panduan Takaran Nutrisi (PPM/EC) Sesuai Umur Melon

Setiap fase pertumbuhan melon butuh nutrisi yang berbeda-beda lho. Perhatikan panduan ini ya:

*   **🌱 Fase Penyemaian/Bibit (1–10 HST)**
    *   PPM: 400–600
    *   EC: 0,8–1,2
    *   *Artinya: Saat bibit masih kecil, nutrisinya jangan terlalu pekat.*

*   **🌿 Fase Pertumbuhan (11–30 HST)**
    *   PPM: 800–1.200
    *   EC: 1,6–2,4
    *   *Artinya: Melon mulai tumbuh daun dan batang, butuh nutrisi lebih banyak.*

*   **🍈 Fase Pembentukan Buah (31–50 HST)**
    *   PPM: 1.400–1.800
    *   EC: 2,8–3,6
    *   *Artinya: Ini fase krusial! Melon butuh nutrisi paling banyak untuk membentuk buah yang besar dan manis.*

*   **🧡 Fase Pematangan (51 HST–Panen)**
    *   PPM: 1.800–2.200
    *   EC: 3,6–4,4
    *   *Artinya: Jelang panen, nutrisi tetap tinggi untuk mematangkan buah dan meningkatkan kualitas rasa.*

**Keterangan Penting:**
*   **HST**: Hari Setelah Tanam (umur tanaman dihitung sejak bibit ditanam).
*   **PPM (Parts per Millions)**: Ukuran seberapa banyak konsentrasi nutrisi yang terlarut di dalam air.
*   **EC (Electrical Conductivity)**: Indikator seberapa pekat nutrisi di air. Semakin tinggi EC, semakin pekat nutrisinya.

Semoga panduan ini bermanfaat ya, Pak Tani dan Bu Tani! Dengan pupuk AB Mix yang tepat, semoga panen melonnya melimpah ruah dan hasilnya memuaskan! Selamat mencoba! 💪

### 🌐 Sumber
[IPB Digitani](https://digitani.ipb.ac.id/bagaimana-cara-membuat-nutrisi-pupuk-ab-mix-melon/)', 'Pupuk & Tanah', 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=800', '2026-09-17T03:07:19+00:00'::timestamptz),
  ('Pupuk Makro dan Mikro: Apa Bedanya dan Kenapa Penting Buat Tanaman Kita?', 'Pahami bahwa tanaman butuh dua jenis pupuk utama: Makro (jumlah besar) dan Mikro (jumlah kecil).', '### ⚡ Solusi Cepat
Pahami bahwa tanaman butuh dua jenis pupuk utama: Makro (jumlah besar) dan Mikro (jumlah kecil). Keduanya sama pentingnya dan harus diberikan secara seimbang agar tanaman tumbuh sehat, kuat, dan hasil panennya melimpah.

### 📖 Panduan Lengkap
Assalamualaikum, Bapak/Ibu Petani Hebat! 👋

Pasti tahu kan, pupuk itu penting banget buat tanaman kita? Ibaratnya kayak makanan buat manusia. Kalau makannya pas, tanaman jadi sehat, subur, dan panennya melimpah. Nah, kadang kita cuma tahu pupuk NPK aja. Padahal, pupuk itu ada dua jenis besar lho: Pupuk Makro dan Pupuk Mikro. Keduanya punya tugas masing-masing, tapi sama-sama pentingnya biar tanaman kita tumbuh sempurna. Yuk, kita bedah bareng biar makin pintar mupuknya!

### 🌱 Pupuk Makro: Si "Makanan Pokok" Tanaman

Pupuk makro ini ibarat nasi dan lauk pauk utama buat kita. Tanaman butuh dalam jumlah **BANYAK**.

**Isinya apa saja?**

*   **N (Nitrogen):** Buat daun jadi hijau royo-royo dan batangnya kuat. Kalau kurang, daunnya kuning dan tanaman kerdil.
*   **P (Fosfor):** Penting buat akar biar kokoh, bunga cepat muncul, dan buahnya banyak. Kalau kurang, akarnya lemah, bunga dan buah sedikit.
*   **K (Kalium):** Bikin tanaman tahan banting dari penyakit dan cuaca ekstrem. Kalau kurang, tanaman gampang sakit dan layu.
*   **Ca (Kalsium), Mg (Magnesium), S (Sulfur):** Ini juga penting buat kekuatan batang, warna daun, dan proses penting lainnya di tanaman.

**Gampang Dilihat Kalau Kurang:** Kalau tanaman kekurangan pupuk makro, biasanya langsung kelihatan: pertumbuhan lambat, daun menguning, atau buahnya kecil-kecil.

### 🤏 Pupuk Mikro: Si "Bumbu Dapur" yang Penting Banget

Nah, kalau pupuk mikro ini ibarat bumbu dapur. Dibutuhkan sedikit, tapi kalau nggak ada, masakan jadi hambar! Tanaman butuh dalam jumlah **KECIL**, tapi perannya **VITAL**.

**Isinya apa saja?**

*   **Fe (Zat Besi), Mn (Mangan), Zn (Seng), Cu (Tembaga), B (Boron), Mo (Molibdenum), Cl (Klorin):** Ini semua bantu tanaman memproses makanan, bikin daun tetap hijau, dan banyak lagi.

**Susah Dilihat Kalau Kurang:** Kekurangan pupuk mikro ini seringnya nggak langsung kelihatan jelas. Tahu-tahu tanaman jadi pucat, pertumbuhannya mandek, atau hasil panennya kurang bagus. Makanya sering terlewatkan.

### ⚖️ Keduanya Penting, Harus Seimbang!

Seringkali kita cuma fokus sama pupuk NPK (makro) aja. Padahal, kalau pupuk mikro-nya kurang, tanaman juga nggak bisa tumbuh maksimal. Ibaratnya, sudah makan nasi lauk pauk, tapi nggak ada garam atau bumbu lain, rasanya jadi kurang pas.

Jadi, jangan cuma mikir mana yang lebih penting. Keduanya itu saling melengkapi, kayak tim kerja. Kalau salah satu kurang, kerja timnya jadi nggak beres.

### 💡 Tips Mupuk Biar Hasilnya Maksimal:

1.  **Pilih Pupuk yang Pas:** Sesuaikan dengan jenis tanaman dan kondisi tanah Bapak/Ibu.
2.  **Dosisnya Seimbang:** Jangan kebanyakan atau kekurangan. Ikuti anjuran atau konsultasi dengan penyuluh.
3.  **Waktu yang Tepat:** Mupuk di waktu yang pas biar nutrisinya terserap sempurna.
4.  **Perhatikan Tanah:** pH tanah, kelembapan, dan drainase juga ngaruh banget lho ke penyerapan pupuk.

Dengan memahami pupuk makro dan mikro ini, Bapak/Ibu Petani bisa lebih jitu dalam merawat tanaman. Hasilnya? Tanaman sehat, panen melimpah, dan kualitasnya juara! 💪

### 🌐 Sumber
[MSMB Indonesia](https://msmbindonesia.com/perbedaan-pupuk-makro-dan-mikro/)', 'Pupuk & Tanah', 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800', '2026-09-17T03:08:24+00:00'::timestamptz),
  ('Sawit Itu Gimana Sih? Yuk, Kupas Tuntas Mitos dan Faktanya!', 'Kelapa sawit sering disalahpahami.', '### ⚡ Solusi Cepat
Kelapa sawit sering disalahpahami. Penting untuk membedakan mitos dan fakta seputar sawit, mulai dari isu lingkungan, kesehatan, hingga teknologi budidaya modern, agar kita bisa melihatnya secara objektif dan bijak.

### 📖 Panduan Lengkap
Halo, Sedulur Petani Pintar!

Kelapa sawit ini sering banget jadi omongan, tapi kadang kita belum paham betul. Ada yang bilang bagus, ada juga yang bilang jelek. Nah, biar kita nggak salah paham dan bisa melihat sawit ini secara utuh, yuk kita bedah mana yang cuma mitos dan mana yang fakta sebenarnya!

### 🌳 Sawit dan Isu Hutan Gundul

*   **Mitos:** "Sawit selalu bikin hutan gundul!"
*   **Fakta:** Memang, kalau buka lahan sawitnya sembarangan dan tanpa aturan, hutan bisa rusak. Tapi, bukan cuma sawit lho yang bikin hutan gundul. Tanaman lain kayak kedelai, peternakan sapi, atau industri kayu juga punya andil besar. Intinya, persoalan lingkungan itu bukan cuma gara-gara jenis tanamannya, tapi *cara* kita mengelola lahan dan komitmen kita terhadap lingkungan.

    Makanya, sekarang ada yang namanya **sawit berkelanjutan**. Ini adalah cara budidaya sawit yang ramah lingkungan, diatur ketat, dan bahkan ada sertifikasinya (kayak RSPO) biar hutan dan ekosistem tetap terjaga. Jadi, sawit bisa kok berdampingan dengan alam!

### 🥗 Minyak Sawit dan Kesehatan Kita

*   **Mitos:** "Minyak sawit itu bahaya buat kesehatan!"
*   **Fakta:** Eits, jangan salah! Minyak sawit itu punya kandungan gizi penting lho, kayak **vitamin E** (yang bagus buat kulit dan antioksidan) dan **karoten** (yang bikin warnanya oranye dan baik buat mata). Sama kayak minyak goreng lainnya, kalau makannya kebanyakan atau pola makan kita nggak seimbang secara keseluruhan, ya tentu saja bisa jadi masalah kesehatan.

    Jadi, masalah kesehatan itu biasanya karena pola makan kita yang nggak teratur dan berlebihan, bukan cuma gara-gara satu jenis minyak. Kalau dipakai secukupnya dan bijak, minyak sawit itu bermanfaat kok sebagai salah satu bahan pangan kita!

### 📱 Sawit dan Teknologi Budidaya Modern

*   **Mitos:** "Nanam sawit itu masih pakai cara-cara lama dan tradisional!"
*   **Fakta:** Sekarang mah udah canggih, Lur! Pengelolaan kelapa sawit itu udah berkembang pesat pakai teknologi modern, namanya **''pertanian presisi''**. Ini artinya, kita pakai data dan teknologi biar semua keputusan jadi lebih tepat dan efisien.

    Banyak teknologi pintar yang bisa dipakai, contohnya:
    *   **Jinawi:** Sistem yang kasih rekomendasi pupuk yang pas, jadi nggak boros dan tanaman sehat.
    *   **Amerta:** Sistem yang ngatur air dan pupuk cair secara presisi, biar tanaman nggak kekurangan atau kelebihan.
    *   **RiTx AWS:** Alat pemantau cuaca dan kondisi lingkungan di kebun, jadi kita bisa antisipasi perubahan cuaca.

    Semua teknologi ini terhubung jadi satu, bikin kerjaan lebih efisien, hemat biaya, dan sawitnya juga makin subur serta ramah lingkungan. Jadi, sawit itu udah nggak ketinggalan zaman, malah makin maju!

### Kesimpulan

Nah, jadi intinya, jangan cuma denger dari satu sisi aja ya. Sawit itu banyak ceritanya, mulai dari lingkungan, kesehatan, sampai teknologi. Kalau kita paham semua, kita bisa lihat sawit ini lebih jelas dan nggak gampang kemakan isu yang belum tentu benar. Semoga bermanfaat, Petani Pintar!

### 🌐 Sumber
[MSMB Indonesia](https://msmbindonesia.com/mitos-dan-fakta-kelapa-sawit/)', 'Lainnya', 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=800', '2026-09-17T05:50:12+00:00'::timestamptz),
  ('Tani Tetap Jalan Saat Kemarau: Coba Tanam Kacang Hijau!', 'Saat musim kemarau dan air terbatas, menanam kacang hijau bisa jadi pilihan tepat.', '### ⚡ Solusi Cepat
Saat musim kemarau dan air terbatas, menanam kacang hijau bisa jadi pilihan tepat. Tanaman ini cepat panen (sekitar 60-70 hari) dan tidak butuh banyak air, sehingga petani tetap bisa beraktivitas dan menghasilkan.

### 📖 Panduan Lengkap
Halo Pak Tani dan Bu Tani di seluruh Indonesia! 👋

Seringkali, pas musim kemarau tiba, kita bingung mau tanam apa ya? Air jadi susah, lahan jadi kering, akhirnya kegiatan pertanian jadi terhenti. Betul tidak?

Nah, ada kabar baik nih! Ada satu tanaman yang bisa jadi solusi jitu buat kita semua, terutama di daerah yang airnya terbatas saat kemarau, seperti yang dialami Pak Pajar Setiawan dari Majalengka. Tanaman itu adalah **Kacang Hijau**! 🌱

Kenapa sih kacang hijau ini cocok banget buat musim kemarau? Gini lho alasannya:

*   **Cepat Panen!** ⏱️
    Kacang hijau ini tidak bikin kita nunggu lama, Pak Tani. Dari mulai tanam sampai panen, cuma butuh waktu sekitar 60 sampai 70 hari saja. Jadi, kita bisa cepat merasakan hasilnya!

*   **Hemat Air!**💧
    Ini dia yang paling penting! Kacang hijau itu tidak rewel soal air. Dia tidak butuh air sebanyak tanaman pangan lain. Cocok banget buat lahan yang airnya terbatas atau pasokan airnya lagi susah.

*   **Bisa Jadi Tanaman Sela!** 🌾
    Setelah panen tanaman utama, lahan kita bisa langsung ditanami kacang hijau. Jadi, tanah tidak nganggur dan tetap bisa menghasilkan uang. Ekonomi keluarga pun tetap jalan!

Jadi, jangan khawatir lagi ya kalau musim kemarau tiba. Dengan menanam kacang hijau, kegiatan pertanian kita tetap bisa berjalan, dan dapur pun tetap ngebul! 💪

Semoga tips ini bermanfaat ya, Pak Tani dan Bu Tani! Mari terus bertani dengan semangat! 😊

### 🌐 Sumber
[IPB Digitani](https://digitani.ipb.ac.id/bagaimana-agar-kegiatan-pertanian-tetap-bisa-berjalan-di-musim-kemarau/)', 'Cuaca & Musim', 'https://images.unsplash.com/photo-1534274988757-a28bf1a57c17?w=800', '2026-09-17T05:50:50+00:00'::timestamptz),
  ('Petani Makin Canggih: Jinawi Bikin Pupuk Pas, Panen Melimpah!', 'Lewat acara PADI 2026, petani di Jawa Tengah dikenalkan teknologi Jinawi dari MSMB.', '### ⚡ Solusi Cepat
Lewat acara PADI 2026, petani di Jawa Tengah dikenalkan teknologi Jinawi dari MSMB. Alat pintar ini bisa kasih tahu kondisi tanah secara langsung dan bantu kita mupuk lebih tepat, biar hasil panen makin bagus dan irit biaya.

### 📖 Panduan Lengkap
Halo, Bapak/Ibu Petani Hebat di seluruh Indonesia! 👋

Pertanian kita sekarang ini makin maju, lho. Nggak cuma ngandelin cara lama, tapi juga pakai teknologi canggih biar hasilnya makin mantap. Nah, ini terbukti banget di acara *Pekan Agro Digital & Inovasi (PADI) Jawa Tengah 2026* kemarin.

Acara PADI 2026 ini seru banget, diadakan tanggal 23-27 April 2026 di Agro Center Soropadan. Di sini, para petani, anak muda inovator, sama pemerintah kumpul bareng. Tujuannya? Biar kita semua makin melek teknologi buat ningkatin hasil panen dan kerja jadi lebih efisien.

### Kenapa PADI 2026 Penting?
Acara ini digagas sama petani-petani muda dari berbagai daerah di Jawa Tengah yang udah sukses di sawahnya masing-masing. Temanya keren: ''Mewujudkan Regenerasi Petani Unggul dan Akselerasi Swasembada Pangan melalui Inovasi Pertanian Berkelanjutan''. Ini nunjukkin kalau peran petani muda (milenial dan Gen Z) itu penting banget buat masa depan pertanian kita. Petani senior dan junior harus saling dukung biar pertanian kita makin kuat dan ngasih nilai tambah.

Pemerintah daerah juga ikut dukung, lho! Ini jadi langkah bagus buat bangun pertanian yang lestari dan jadi tempat kenalan sama teknologi-teknologi baru yang bisa jawab tantangan pertanian sekarang, terutama biar budidaya makin efisien dan akurat.

### Jinawi: Teknologi Pintar Buat Pupuk Lebih Pas! 💡
Di acara PADI 2026 ini, MSMB Indonesia ikutan pamer teknologi andalannya, namanya **Jinawi**. Apa itu Jinawi? Ini adalah sistem pintar yang bisa kasih rekomendasi pemupukan pakai teknologi IoT (Internet of Things).

Gampangnya gini, Jinawi bisa kasih tahu kita kondisi tanah di sawah secara langsung (real-time). Mulai dari:
*   Kandungan unsur hara N, P, K
*   Tingkat keasaman (pH)
*   Daya hantar listrik (EC)
*   Suhu
*   Kelembaban tanah

Lengkap banget, kan?

Nggak cuma itu, Jinawi juga udah nyambung sama aplikasi **RiTx Jinawi** di HP kita. Jadi, Bapak/Ibu Petani bisa langsung lihat data tanah dan rekomendasi pupuk lewat *smartphone*. Ini bikin kita makin gampang ambil keputusan, mupuknya jadi lebih akurat dan nggak buang-buang pupuk. Hemat biaya, panen melimpah!

Kata Pak Farid Meisa, Head of Marketing MSMB, "Ikut PADI 2026 ini penting banget buat MSMB biar teknologi pertanian yang kami kembangin bisa dikenal dan dipakai lebih luas sama petani. Harapannya, solusi ini bisa ningkatin hasil panen dan bikin kerja budidaya makin efisien."

MSMB ini serius banget dukung pertanian kita maju lewat solusi digital. Ke depannya, teknologi *smart farming* kayak Jinawi ini diharapkan jadi pondasi utama buat pertanian Indonesia yang lebih modern, tangguh, dan siap hadapi tantangan dunia. Yuk, kita bareng-bareng maju dengan teknologi! 🌱

### 🌐 Sumber
[MSMB Indonesia](https://msmbindonesia.com/smart-farming-jinawi-padi-jateng-2026/)', 'Teknologi Tani', 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800', '2026-09-18T04:23:47+00:00'::timestamptz),
  ('Pupuk Makro dan Mikro: Pentingnya Tahu Beda Keduanya Biar Panen Makin Jos!', 'Pupuk makro dan mikro sama-sama penting untuk tanaman.', '### ⚡ Solusi Cepat
Pupuk makro dan mikro sama-sama penting untuk tanaman. Pupuk makro dibutuhkan dalam jumlah besar untuk membangun struktur tanaman, sedangkan pupuk mikro dibutuhkan sedikit tapi vital untuk mengatur proses di dalamnya. Keduanya harus diberikan secara seimbang agar tanaman tumbuh sehat dan hasil panen optimal.

### 📖 Panduan Lengkap
Assalamualaikum, Bapak/Ibu Petani Hebat! 👋

Pupuk itu ibarat makanan utama buat tanaman kita. Kalau makannya pas, tanaman pasti sehat dan hasilnya melimpah. Tapi, jangan salah sangka, pupuk itu ada dua jenis lho: **pupuk makro** dan **pupuk mikro**. Keduanya beda tugas, tapi sama-sama pentingnya. Yuk, kita kenalan biar makin paham!

### Pupuk Makro: Si Pembangun Utama 🏗️

Pupuk makro itu nutrisi yang dibutuhkan tanaman dalam jumlah **BANYAK**, kayak nasi buat kita. Ini penting banget buat bangun ''badan'' tanaman, mulai dari akar yang kuat, batang yang kokoh, sampai daun yang rimbun. Juga biar buahnya banyak dan besar!

Contoh pupuk makro ada:
*   **Nitrogen (N)**: Bikin daun hijau royo-royo dan tumbuh subur.
*   **Fosfor (P)**: Penting buat akar kuat, biar bunga dan buahnya jadi banyak.
*   **Kalium (K)**: Bikin tanaman tahan penyakit dan cuaca ekstrem.
*   Kalsium (Ca), Magnesium (Mg), dan Sulfur (S).

Kalau tanaman kurang pupuk makro, gampang kelihatan: tumbuhnya lambat, daunnya kuning, atau badannya kecil.

### Pupuk Mikro: Si Pengatur Penting, Walau Sedikit 🤏

Nah, kalau pupuk mikro ini beda. Dibutuhkan tanaman cuma **sedikit**, kayak garam atau bumbu dapur. Tapi, jangan salah, perannya **PENTING BANGET**! Dia yang ngatur semua ''mesin'' di dalam tanaman biar kerjanya bener, kayak bikin daun hijau atau ngolah makanan.

Contoh pupuk mikro ada:
*   Zat Besi (Fe)
*   Mangan (Mn)
*   Seng (Zn)
*   Tembaga (Cu)
*   Boron (B)
*   Molibdenum (Mo)
*   Klorin (Cl)

Walaupun sedikit, kalau kurang, tanaman bisa sakit: daunnya pucat, tumbuhnya macet, atau hasil panennya kurang bagus. Seringnya gejala ini nggak langsung kelihatan, jadi kadang kita nggak sadar.

### Jangan Sampai Salah Kaprah! ⚠️

Seringnya, kita para petani cuma fokus sama pupuk makro kayak NPK aja. Padahal, pupuk makro dan mikro itu kayak dua sisi mata uang, saling melengkapi. Kalau salah satu kurang, pertumbuhan tanaman bisa terganggu semua.

Jadi, bukan mana yang lebih penting, tapi harus **SEIMBANG**!

### Tips Pemupukan yang Pas Biar Panen Maksimal ✨

Biar tanaman kita sehat dan panennya melimpah ruah, ingat tips ini:

1.  **Pilih pupuk yang pas**: Sesuaikan dengan kebutuhan tanaman dan kondisi tanah.
2.  **Dosisnya seimbang**: Jangan kebanyakan, jangan kedikitan. Ikuti anjuran.
3.  **Waktu yang tepat**: Beri pupuk di waktu yang pas, sesuai fase pertumbuhan tanaman.
4.  **Perhatikan tanah**: pH tanah, kelembapan, dan saluran air juga penting. Tanah yang sehat bikin nutrisi gampang diserap.

Dengan paham bedanya pupuk makro dan mikro, kita bisa lebih jitu mupuknya. Tanaman sehat, panen melimpah, petani senang! 🎉

### 🌐 Sumber
[MSMB Indonesia](https://msmbindonesia.com/perbedaan-pupuk-makro-dan-mikro/)', 'Pupuk & Tanah', 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800', '2026-09-18T04:31:01+00:00'::timestamptz)
) as v(title, description, content, category, image_url, created_at)
where not exists (select 1 from public.tips t where t.title = v.title);

insert into public.hama_penyakit (name, type, description, solution_organic, image_url, created_at)
select * from (values
  ('Keong Mas', 'Hama', 'Hama yang memakan bibit padi muda.

Ciri-ciri: Cangkang berwarna kuning keemasan.

Dampak: Bibit habis dimakan sehingga perlu tanam ulang.', 'Pengumpulan manual dan penggunaan umpan.', 'https://lmbsryezpadlsbxznezl.supabase.co/storage/v1/object/public/content_images/hama/keong-mas.jpg', '2026-06-03T07:09:38.625376+00:00'::timestamptz),
  ('Kutu Daun', 'Hama', 'Hama penghisap cairan tanaman hortikultura.

Ciri-ciri: Koloni kecil berwarna hijau atau hitam pada daun muda.

Dampak: Pertumbuhan tanaman terhambat.', 'Semprot pestisida nabati dan manfaatkan predator alami.', 'https://lmbsryezpadlsbxznezl.supabase.co/storage/v1/object/public/content_images/hama/kutu-daun.jpg', '2026-06-03T07:09:38.625376+00:00'::timestamptz),
  ('Penggerek Batang Padi', 'Hama', 'Larva menyerang bagian dalam batang padi.

Ciri-ciri: Batang mudah patah dan mengering.

Dampak: Menyebabkan puso atau gagal panen.', 'Gunakan perangkap feromon dan tanam serempak.', 'https://lmbsryezpadlsbxznezl.supabase.co/storage/v1/object/public/content_images/hama/penggerek-batang-padi.jpg', '2026-06-03T07:09:38.625376+00:00'::timestamptz),
  ('Tikus Sawah', 'Hama', 'Hama pengerat yang menyerang tanaman sejak awal tanam hingga panen.

Ciri-ciri: Terdapat bekas gigitan dan lubang sarang di sekitar sawah.

Dampak: Kerusakan tanaman dalam jumlah besar.', 'Gropyokan, pemasangan perangkap, dan sanitasi lahan.', 'https://lmbsryezpadlsbxznezl.supabase.co/storage/v1/object/public/content_images/hama/tikus-sawah.jpg', '2026-06-03T07:09:38.625376+00:00'::timestamptz),
  ('Ulat Grayak', 'Hama', 'Ulat pemakan daun yang aktif pada malam hari.

Ciri-ciri: Daun berlubang besar, ditemukan ulat berwarna hijau kecoklatan.

Dampak: Mengurangi luas daun sehingga fotosintesis terganggu.', 'Pengendalian mekanis, penggunaan musuh alami, dan insektisida biologis.', 'https://lmbsryezpadlsbxznezl.supabase.co/storage/v1/object/public/content_images/hama/ulat-grayak.jpg', '2026-06-03T07:09:38.625376+00:00'::timestamptz),
  ('Wereng Batang Coklat', 'Hama', 'Hama utama tanaman padi yang menyerang batang dan menghisap cairan tanaman.

Ciri-ciri: Warna coklat, ukuran kecil, bergerombol di pangkal batang.

Dampak: Tanaman menguning, kering, dan gagal panen.', 'Gunakan varietas tahan wereng, musnahkan tanaman terserang, dan aplikasikan insektisida sesuai dosis.', 'https://lmbsryezpadlsbxznezl.supabase.co/storage/v1/object/public/content_images/hama/wereng-batang-coklat.jpg', '2026-06-03T07:09:38.625376+00:00'::timestamptz),
  ('Penyakit Busuk Batang Terong', 'Penyakit', 'Penyakit ini bikin batang tanaman terong jadi busuk, Sobat Tani. Penyebabnya adalah jamur jahat yang hidup di dalam tanah dan gampang menyebar lewat air. Kalau sudah kena, tanaman terong bisa layu dan akhirnya mati.

Ciri-ciri: Batang tanaman terong terlihat busuk, lembek, dan warnanya berubah. Tanaman yang terserang biasanya akan layu dan tidak bisa tumbuh lagi.', '**1. Cabut dan Musnahkan Tanaman Sakit** 💀
Segera cabut tanaman terong yang sudah jelas kena penyakit ini sampai ke akarnya. Pastikan tanah di sekitar akarnya tidak berceceran ke mana-mana, ya. Setelah dicabut, musnahkan tanaman itu dengan cara dibakar atau dikubur dalam-dalam, jangan dibiarkan di kebun.

**2. Beri Kompos di Bekas Lubang Tanam** 🌱
Di bekas lubang tanam yang tadi ada tanaman sakitnya, taburkan pupuk kompos yang banyak. Kompos ini bagus untuk menyuburkan tanah dan bisa bantu menekan pertumbuhan jamur jahat.

**3. Hindari Penyiraman Berlebihan** 💧
Saat menyiram tanaman, jangan sampai air menggenang terlalu lama di sekitar batang terong. Siram secukupnya saja supaya tanah tidak terlalu lembap, karena jamur penyebab busuk batang ini suka sekali tempat yang basah.', 'https://lmbsryezpadlsbxznezl.supabase.co/storage/v1/object/public/content_images/hama/penyakit-busuk-batang-terong.jpg', '2026-08-31T05:02:30.845225+00:00'::timestamptz),
  ('3 Penyakit Utama Tanaman Jagung', 'Penyakit', 'Salam Petani Hebat! Jagung kita memang kelihatan gagah, tapi hati-hati ya, dia gampang kena penyakit, apalagi kalau cuaca lagi mendukung bibit penyakitnya. Seringnya, gejala awal penyakit ini nggak kita sadari, tahu-tahu panen sudah anjlok. Nah, biar nggak nyesel belakangan, yuk kita kenali 3 penyakit jagung yang paling sering bikin pusing!

Ciri-ciri: Berikut ciri-ciri penyakit yang sering menyerang jagung:

*   **1. Bulai (Downy Mildew):** Daun jagung jadi kuning belang-belang, terus pucat atau putih, apalagi kalau cuaca lembap. Tanaman jadi kerdil, tongkolnya nggak jadi atau kecil.
*   **2. Busuk Tongkol (Ear Rot):** Biji jagung berubah warna jadi putih kusam, merah, atau kehijauan. Bijinya gampang rapuh.
*   **3. Hawar Daun (Leaf Blight):** Muncul bercak cokelat atau keabu-abuan memanjang di daun, lama-lama daunnya kering.', 'Intinya, ketiga penyakit ini suka banget sama tempat yang lembap dan gampang nyebar kalau kebun kita nggak terawat. Jadi, selain pilih benih yang bagus, kita juga harus rajin ngurus lahan: pastikan air nggak menggenang, jarak tanam pas, dan kebun selalu bersih. Kalau kita tahu gejalanya dari awal, kita bisa cepat bertindak biar panen nggak rugi besar!

Berikut cara mengatasi tiap penyakit:

*   **1. Untuk Bulai:** Pilih benih yang sehat dan tahan penyakit. Kalau bisa, benihnya dikasih perlakuan dulu sebelum tanam. Bersihkan sisa tanaman yang sakit.
*   **2. Untuk Busuk Tongkol:** Pastikan lahan nggak terlalu lembap, air bisa mengalir lancar (drainase bagus). Jaga sirkulasi udara di kebun. Habis panen, biji jagung harus dikeringkan dengan baik.
*   **3. Untuk Hawar Daun:** Atur jarak tanam biar nggak terlalu rapat. Pakai varietas jagung yang tahan hawar daun. Bersihkan sisa-sisa tanaman yang sudah kena penyakit.', 'https://lmbsryezpadlsbxznezl.supabase.co/storage/v1/object/public/content_images/hama/3-penyakit-utama-tanaman-jagung.jpg', '2026-09-17T05:49:52.745613+00:00'::timestamptz)
) as v(name, type, description, solution_organic, image_url, created_at)
where not exists (select 1 from public.hama_penyakit p where p.name = v.name);

-- Video edukasi (YouTube, sudah dicek ada & boleh di-embed per 2026-11-15).
insert into public.videos (title, video_url, description)
select * from (values
  ('Cara Menanam Padi dari Awal hingga Panen', 'https://www.youtube.com/watch?v=px3vCA4Tf5c', 'Tahapan lengkap budidaya padi sawah termasuk jadwal pemupukan. Kanal: Kentar Kentir.'),
  ('Cara Tanam Padi agar Cepat Tumbuh Setelah Pindah Tanam', 'https://www.youtube.com/watch?v=wiJg9_tz3Fw', 'Tips pindah tanam bibit padi supaya cepat pulih dan anakan lebih banyak. Kanal: Eko Budi youtube Farm.'),
  ('Cara Semai Cabai hingga Siap Tanam', 'https://www.youtube.com/watch?v=dproMYRFFr8', 'Menyemai benih cabai dari biji sampai bibit siap dipindah ke lahan. Kanal: Daun Talas Chanel.'),
  ('Cara Menanam Cabai dari Awal hingga Panen', 'https://www.youtube.com/watch?v=YCCy3i7Agak', 'Budidaya cabai rawit dari persiapan lahan sampai panen. Kanal: HERI PETANI INDONESIA.'),
  ('Membuat Pupuk Kompos Metode Berkeley', 'https://www.youtube.com/watch?v=_9ILrBQzfjk', 'Kompos cepat dari campuran bahan hijau, bahan coklat, dan aktivator. Kanal: Tani Ponik.'),
  ('Membuat Pupuk dari Kotoran Sapi', 'https://www.youtube.com/watch?v=i_uB0bZ58A0', 'Mengolah kotoran sapi menjadi pupuk organik, dijelaskan oleh penyuluh pertanian. Kanal: jabung official.'),
  ('Mengenal Wereng Hijau Penyebar Virus Tungro', 'https://www.youtube.com/watch?v=7_pGIBSgc3Q', 'Ciri serangan wereng hijau, kaitannya dengan penyakit tungro, dan cara pengendaliannya. Kanal: Zona Pertanian.'),
  ('Cara Mengatasi Hama Wereng pada Padi', 'https://www.youtube.com/watch?v=ybZMNPqWonk', 'Langkah praktis menekan serangan wereng di sawah. Kanal: Ogieq GD.')
) as v(title, video_url, description)
where not exists (select 1 from public.videos x where x.video_url = v.video_url);
