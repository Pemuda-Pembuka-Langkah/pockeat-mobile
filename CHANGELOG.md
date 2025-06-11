# Changelog
## v1.3.4
**Release Date: June 11, 2025**

### Features
- **Technical Documentation**
  - Added comprehensive technical documentation in English
  - Translated tech documentation from Indonesian to English

### Improvements
- **Performance Optimization**
  - Improved homepage performance from 6.7 seconds to 2.7 seconds
  - Enhanced skeleton loading with skeletonizer for better user experience

### Bug Fixes
- **Onboarding and Navigation**
  - Fixed free trial page edge cases
  - Corrected navigation handling on food input page
  - Fixed duplicate entry for vitamin and mineral section in nutrition page
  - Resolved issue with pop navigation to welcome page
  - Added proper back button functionality to registration flow

### Technical
- **Health Metrics Integration**
  - Implemented health metrics service with service locator
  - Added user health metrics to smart exercise log page
  - Integrated BMI auto-update when updating current weight
  - Improved caloric requirements calculation with auto-updates
  - Added macronutrient (protein, carbs, fat) requirements calculation

### Refactoring
- **UI/UX Enhancements**
  - Refactored pet name handling in user preferences
  - Updated food database input method for portion selection
  - Improved weight progress and goals calculation
  - Refined widget background service calculation logic
  - Added widget update triggers for various user actions

## v1.3.3
**Release Date: May 11, 2025**

# CHANGELOG

## v1.3.3
**Release Date: May 11, 2025**

### Features
- **Onboarding Experience Enhancement**
  - Implemented health value proposition page
  - Added onboarding progress indicator
  - Redesigned welcome page with updated assets
  - Refactored birthday and height/weight pages for better user experience
  - Implemented feature card for improved guidance

### Improvements
- **Exercise Tracking Refinement**
  - Improved routing to recent exercise tab
  - Added tabIndex and subTabIndex on recent exercise log for instant routing
  - Enhanced Cardio Log's Save Activity button to prevent multiple saving actions

### Bug Fixes
- Fixed bug where email verification status was outdated from Firestore
- Corrected user account creation date
- Updated widget installation status refresh timer to 5 minutes
- Changed SnackBar duration from 1 day to 5 seconds

### Technical
- **Pet Companion System**
  - Implemented pet information model
  - Added integration of pet over calories for heart bar and mood state
  - Created getPetInformation and getIsOverCalorie in pet service
  - Integrated pet information with homepage
- **CI/CD Enhancements**
  - Added automatic tag creation workflow
  - Included APK upload to Pockeat web on release
  - Improved changelog generation formatting

## v1.3.2
**Release Date: May 07, 2025**

### Features
- **Widget System Integration** - Implementation of home screen widgets for food tracking
  - Simple and detailed food widget preview with drawable preview
  - Widget manager screen for customization and installation
  - Widget preview card factory for different widget types
  - Native code integration for widget installation

### Improvements
- **Profile Page Enhancement**
  - Integration of BMI and user weight data from database
  - Addition of widget setting shortcut on profile page
  - Refactoring to use English instead of Indonesian
  - Increased code coverage for profile page components

### Bug Fixes
- Fixed timezone bug on calories chart
- Fixed widget installation and update issues
- Corrected desiredWeight field implementation

### Technical
- **Widget Architecture**
  - Implementation of widget installation controller and service
  - Widget preview info DTO and constants
  - Widget installation status model and handler
- **Pet Companion Enhancement**
  - Implementation of integration with caloric requirements
  - Tests for pet integration with calorie requirements
- Setup automatic changelog updates using AI

## v1.3.1
**Release Date: May 5, 2025**

### Features
- **Food Database Input** - Implementasi sistem input database makanan lengkap dengan antarmuka pengguna yang intuitif
- **Health Score Analysis** - Penambahan fitur analisis health score dan parameter nutrisi tambahan

### Bug Fixes
- Memperbaiki integrasi antara Google Auth dan proses onboarding 
- Perbaikan bug di mana homescreen widget tidak terupdate dengan baik
- Memperbaiki masalah blank screen pada aplikasi

## v1.3.0
**Release Date: April 26, 2025**

### Features
- **Meal Reminder Notifications** - Implementasi sistem notifikasi untuk pengingat waktu makan (breakfast, lunch, dan dinner)
  - Konfigurasi waktu reminder terpisah untuk breakfast, lunch, dan dinner
  - Sistem validasi waktu reminder berdasarkan jenis meal
  - Customizable message berdasarkan jenis makanan
- **Pet Companion System** - Integrasi pet companion pada homepage dengan mood changes dan heart bar
  - Implementasi sistem heart bar yang menunjukkan kondisi pet berdasarkan streak
  - Animasi berbeda untuk setiap status streak (menggunakan Lottie animation)
  - Pet service untuk mengelola interaksi dan status pet
- **Daily Streak Enhancement** - Peningkatan sistem streak harian dengan notifikasi dan UI feedback
  - Streak celebration page yang menampilkan animasi dan prestasi streak
  - Factory pattern untuk berbagai streak messages berdasarkan jumlah hari
  - Notifikasi pengingat harian untuk mempertahankan streak
- **Google Analytics Integration** - Implementasi analitik untuk tracking user behavior
  - Event tracking untuk login, registrasi, food input, dan progress page
  - Performance monitoring untuk fitur-fitur utama
  - Reporting untuk user engagement metrics
- **Home Screen Widget** - Widget Android untuk tracking makanan dari home screen
  - Simple Food Tracking Widget yang menampilkan status kalori harian
  - Detailed Food Tracking Widget dengan informasi makronutrien
  - Deep linking dari widget ke aplikasi utama
- **Welcome Page** - Implementasi halaman welcome baru untuk meningkatkan user onboarding
  - UI yang lebih intuitif untuk pengguna baru
  - Flow navigasi yang lebih baik untuk login dan register
- **Splash Screen & App Icon** - Custom splash screen dengan logo Pockeat dan animasi panda
  - Optimasi loading time pada startup
  - Konfigurasi app icon yang konsisten di semua perangkat

### Improvements
- **UI/UX Enhancements**
  - Perbaikan bug pada tampilan kamera saat food scan
  - Reorganisasi tampilan homepage dengan pet section di bagian atas
  - Perubahan tata letak tab history pada Progress Page
  - Implementasi subtab untuk food dan exercise di history page
  - Peningkatan UI pada notification settings
- **Performance Optimization**
  - Peningkatan efisiensi dalam perhitungan food logging streak
  - Optimasi rendering dengan addPostFrameCallback
  - Pengurangan resource penggunaan dengan asset management yang lebih baik
- **Code Quality**
  - Implementasi Husky untuk pre-commit hooks (TDD support)
  - Perbaikan berbagai lint issues untuk meningkatkan maintainability
  - Perubahan struktur kode untuk mendukung clean architecture

### Technical
- **Background Processing**
  - Migrasi background service ke WorkManager untuk pengelolaan task lebih efisien
  - Unifikasi dispatcher antara notification handler dan app widget handler
  - Implementasi periodic task scheduling untuk streak notification
- **Notification System Refactoring**
  - Centralisasi notification constants untuk maintainability yang lebih baik
  - Implementasi notification background displayer service untuk berbagai jenis notifikasi
  - Refactoring channel management untuk modularitas yang lebih baik
- **Integration Improvements**
  - Peningkatan integrasi deeplink untuk handling notification actions
  - Implementasi method channel untuk komunikasi antara native dan Flutter
  - Perbaikan Firebase AppCheck untuk keamanan API
- **Testing & Stability**
  - Peningkatan test coverage untuk semua fitur baru
  - Fix issue yang menyebabkan codecov tidak berjalan dengan benar
  - Perbaikan compatibility issues dengan dependency resolution
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
