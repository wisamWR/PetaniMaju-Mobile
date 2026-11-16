# Gambar konten awal

Salinan gambar di bucket Supabase `content_images`. Unggah ulang ke project baru:

```bash
supabase storage cp -r supabase/seed-images/hama ss:///content_images/hama --experimental
supabase storage cp -r supabase/seed-images/tips ss:///content_images/tips --experimental
```

| File | Sumber | Lisensi |
|------|--------|---------|
| `hama/keong-mas.jpg` | [Pomacea canaliculata 01.JPG](https://commons.wikimedia.org/wiki/File:Pomacea_canaliculata_01.JPG) oleh H. Zell | [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0) |
| `hama/3-penyakit-utama-tanaman-jagung.jpg` | [Typical symptom of maize downy mildew (Peronosclerospora maydis)](https://commons.wikimedia.org/wiki/File:Typical_symptom_of_maize_downy_mildew_(Peronosclerospora_maydis)_Pj_DSC_0774.jpg) oleh Kembangraps (dipotong) | [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0) |
| `hama/penyakit-busuk-batang-terong.jpg` | [Auberginen Verticillium-1](https://commons.wikimedia.org/wiki/File:Auberginen_Verticillium-1-Josef_Schlaghecken.jpg) oleh Josef Schlaghecken | [CC BY 4.0](https://creativecommons.org/licenses/by/4.0) |
| lainnya | Data project Petani Maju V.2 (storage `images/`) | Belum diverifikasi — ganti jika aplikasi dirilis publik |
