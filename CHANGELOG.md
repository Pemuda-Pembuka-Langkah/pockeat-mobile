# Changelog
## V 1.2.0
Release Date: TBD
### Features
- Fitur registrasi dengan email dan password
## v1.1.2 - Enhanced Food Analysis & Label
Release Date: March 17, 2025
### Features
- Add Header & Detailed Description for Food Text Input Form
- Label Mode in Camera Scan - Penambahan mode khusus untuk memindai label nutrisi pada kemasan makanan dengan opsi - pengaturan ukuran porsi
- Dataset-Reinforced Analysis - Implementasi sistem analisis baru dengan penguatan dataset makanan

### Technical
- Reimplementasi service analisis gambar dan teks dengan alur:
- Interaksi dengan model API high temperature untuk nama makanan dan deskripsi
- Pencarian kemiripan pada dataset untuk hasil API sebelumnya
- Analisis final dengan model low temperature untuk hasil yang lebih akurat dan berdasar

## v1.1.1 - Firebase Integration
**Release Date: March 17, 2025**

### Features
- **Firebase App Distribution** - Menambahkan konfigurasi untuk distribusi aplikasi melalui Firebase App Distribution
- **GitHub Release Integration** - Memperbaiki sistem release otomatis dengan GitHub Actions

### Bug Fixes
- Fix error yang menyebabkan release CI tidak berjalan
- Menambahkan build_runner sebagai dependency pada workflow testing

## v1.1.0 - Implementation Release
**Release Date: March 10, 2025**

### Features
- **Food Analysis And Logging** - Analisis dan pencatatan nutrisi makanan menggunakan input teks dan gambar
- **Exercise Logging** - Pencatatan aktivitas latihan dengan kategori cardio dan weight training
- **Smart Exercise Log** - Analisis latihan menggunakan AI untuk estimasi kalori
- **Food History Page** - Implementasi halaman riwayat makanan dengan fitur filter dan pencarian
- **Exercise History** - Pencatatan dan penampilan riwayat latihan dengan fitur pencarian

### Improvements
- Peningkatan UI responsif untuk halaman utama dan komponen exercise
- Optimasi layout pada halaman weightlifting dengan spacing lebih baik
- Konsistensi UI: pesan sukses selalu hijau dan pesan error selalu merah

### Technical
- Implementasi Firebase sebagai backend
- Integrasi Gemini API untuk analisis AI
- Konfigurasi CI/CD dengan GitHub Actions

## v1.0.0 - Initial Mockup
**Release Date: February 15, 2025**

### Features
- Mockup awal Pockeat
- Desain UI dasar aplikasi
- Layout screen utama tanpa implementasi backend
- Prototype interaksi dasar
