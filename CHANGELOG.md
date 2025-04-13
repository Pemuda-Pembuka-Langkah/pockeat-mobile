# Changelog
## v1.2.1
**Release Date: April 11, 2025**

### Features
- Hadir Fitur Profil Pengguna. Pada fitur tersebut, pengguna dapat mengubah profil, password, dan logout

### Technical
= Implementasi fitur profil display dan edit, ganti password, dan logout

## v1.2.0
**Release Date: April 10, 2025**

### Features
- Fitur registrasi dengan email dan password
- Social Media Sharing
- Sync Fitness Tracker
- Reverse Proxy AI API system
- Daily Consumed Calorie
- User Health Metrics Form
- User Progress (calories and nutrition)
- Change Password
- Google Login
- Push Notifications
  - Set up push notification service
  - Implement notification permission handling
  - Create notification delivery system
  - Design notification templates
  - Implement notification triggers (workout reminders, goals)
  - Build notification scheduling system

### Technical
- Implementasi fitur registrasi, verifikasi email, dan deeplink untuk in-app verification
- Integrasi login dengan Google
- Implementasi sistem reverse proxy untuk API AI
- Pengembangan fitur sinkronisasi dengan fitness tracker
- Sistem perhitungan dan pelacakan kalori harian
- Backend untuk form metrik kesehatan pengguna
- Implementasi fitur progress tracking untuk kalori dan nutrisi
- Sistem untuk reset dan perubahan password
- Set up push notification service dengan Firebase Cloud Messaging
- Implementasi sharing ke media sosial

## v1.1.2 - Enhanced Food Analysis & Label
**Release Date: March 17, 2025**

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
