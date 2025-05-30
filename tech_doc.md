# Aplikasi Mobile PockEat - Dokumentasi Teknis

## Daftar Isi
1. [Gambaran Sistem](#gambaran-sistem)
2. [Arsitektur Sistem](#arsitektur-sistem)
3. [Modul Implementasi](#modul-implementasi)
4. [Pengaturan Lingkungan Pengembangan](#pengaturan-lingkungan-pengembangan)
5. [Panduan Konfigurasi](#panduan-konfigurasi)
6. [Instruksi Menjalankan & Pengujian](#instruksi-menjalankan--pengujian)
7. [Panduan Deployment](#panduan-deployment)
8. [Keterbatasan Proyek & Pengembangan Masa Depan](#keterbatasan-proyek--pengembangan-masa-depan)
9. [Lampiran](#lampiran)

---

## Gambaran Sistem

### Deskripsi Proyek
**PockEat** adalah aplikasi mobile pelacakan kesehatan dan kebugaran yang komprehensif yang dibangun dengan Flutter/Dart. Aplikasi ini berfungsi sebagai pendamping digital bagi pengguna yang ingin melacak nutrisi, olahraga, dan perjalanan kesehatan mereka secara keseluruhan dengan bantuan sistem pendamping hewan peliharaan bertenaga AI.

### Fitur Utama
- **Pelacakan Metrik Kesehatan**: Proses onboarding yang komprehensif untuk menangkap data kesehatan pengguna
- **Pencatatan Makanan Bertenaga AI**: Pengenalan makanan pintar melalui pemindaian gambar, input teks, dan analisis label nutrisi
- **Pelacakan Olahraga**: Dukungan untuk kardio, latihan beban, dan pencatatan olahraga pintar
- **Sistem Pendamping Hewan Peliharaan**: Sistem motivasi gamifikasi dengan interaksi hewan peliharaan virtual
- **Analitik Kemajuan**: Grafik dan diagram visual untuk melacak kemajuan kesehatan
- **Widget Layar Utama**: Akses cepat ke data nutrisi dari layar utama perangkat
- **Notifikasi**: Pengingat cerdas dan pesan motivasi
- **Makanan Tersimpan**: Menyimpan dan menggunakan kembali makanan yang sering dikonsumsi
- **Fitur Sosial**: Berbagi makanan dan interaksi komunitas

### Stack Teknologi

#### Frontend Mobile (Flutter)
- **Framework**: Flutter 3.x dengan Dart
- **Manajemen State**: Pola BLoC dengan Provider
- **Dependency Injection**: GetIt service locator
- **Pengujian**: Unit tests dengan mockito, Widget tests, Integration tests
- **Platform Target**: Android (fokus pengembangan utama)

#### Backend API (FastAPI)
- **Framework**: FastAPI (Python)
- **Runtime**: Python 3.12
- **Server**: Uvicorn dengan dukungan async/await
- **Middleware Autentikasi**: Firebase Admin SDK dengan custom middleware
- **Dokumentasi API**: OpenAPI/Swagger UI otomatis
- **CORS**: Konfigurasi cross-origin untuk aplikasi mobile
- **Testing**: pytest, pytest-asyncio, pytest-cov dengan coverage reporting
- **Code Quality**: black (formatting), flake8 (linting)

#### Layanan AI & Backend
- **Integrasi AI**: Google Gemini Pro Vision API melalui LangChain
- **Layanan Backend**: Firebase (Authentication, Firestore, Cloud Messaging)
- **Database**: Firebase Firestore (aplikasi mobile), Supabase PostgreSQL (dataset makanan di API)
- **Payment Gateway**: DOKU untuk pemrosesan pembayaran dan langganan

#### Infrastructure & DevOps
- **CI/CD**: GitHub Actions dengan automated testing dan deployment
- **Deployment**: Firebase App Distribution, Docker containerization
- **Monitoring**: Firebase Analytics, Performance Monitoring, dan Crash Reporting
- **Notifikasi**: Firebase Cloud Messaging dengan flutter_local_notifications
- **Manajemen Environment**: dotenv untuk konfigurasi environment-specific

---

## Arsitektur Sistem

### Diagram Konteks Sistem C4 Level 1
```
┌────────────────────────────────────────────────────────────────────────┐
│                           Ekosistem PockEat                            │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│  ┌──────────────────┐         ┌──────────────────┐         ┌─────────┐ │
│  │                  │         │                  │         │         │ │
│  │  Pengguna Mobile │ ──────▶ │ Aplikasi Mobile  │ ──────▶│ Google  │ │
│  │                  │         │     PockEat      │         │ Gemini  │ │
│  └──────────────────┘         └──────────────────┘         │   AI    │ │
│                                         │                  └─────────┘ │
│                                         │                              │
│                                         ▼                              │
│  ┌──────────────────┐         ┌──────────────────┐         ┌─────────┐ │
│  │                  │         │                  │         │         │ │
│  │    Firebase      │ ◀────── │  FastAPI Backend │ ──────▶│Supabase │ │
│  │(Auth, Firestore, │         │   (Python 3.12)  │         │(Dataset)│ │
│  │   FCM, Storage)  │         │                  │         └─────────┘ │
│  └──────────────────┘         └──────────────────┘                     │
│                                         │                              │
│                                         ▼                              │
│                               ┌──────────────────┐                     │
│                               │                  │                     │
│                               │ DOKU Payment     │                     │
│                               │   Gateway        │                     │
│                               └──────────────────┘                     │
└────────────────────────────────────────────────────────────────────────┘
```

### Diagram Container C4 Level 2

#### Aplikasi Mobile PockEat (Flutter)
```
┌─────────────────────────────────────────────────────────────────┐
│                   Aplikasi Mobile PockEat                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐   │
│ │     Layer       │  │     Logika      │  │     Layer       │   │
│ │   Presentasi    │  │     Bisnis      │  │      Data       │   │
│ │                 │  │                 │  │                 │   │
│ │ • Layar/Halaman │  │ • Layanan       │  │ • Repository    │   │
│ │ • Widget        │  │ • BLoC/Cubit    │  │ • Sumber Data   │   │
│ │ • Komponen      │  │ • Use Cases     │  │ • Model         │   │
│ └─────────────────┘  └─────────────────┘  └─────────────────┘   │
│                                                                 │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │                Infrastruktur Inti                           │ │
│ │                                                             │ │
│ │ • Dependency Injection (GetIt)                              │ │
│ │ • Layanan Navigasi                                          │ │
│ │ • Layanan Analitik                                          │ │
│ │ • Layanan Notifikasi                                        │ │
│ │ • Layanan Background                                        │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ HTTP/HTTPS API Calls
┌─────────────────────────────────────────────────────────────────┐
│                    FastAPI Backend Server                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐   │
│ │   API Routes    │  │     Services    │  │   Dependencies  │   │
│ │                 │  │                 │  │                 │   │
│ │ • Food Module   │  │ • Gemini Service│  │ • Authentication│   │
│ │ • Exercise      │  │ • Database Svc  │  │ • Database      │   │
│ │ • User Module   │  │ • Payment Svc   │  │ • Configuration │   │
│ │ • Health Module │  │ • Email Service │  │ • Logging       │   │
│ │ • Payment       │  │                 │  │                 │   │
│ └─────────────────┘  └─────────────────┘  └─────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Pola Arsitektur
- **Clean Architecture**: Pemisahan yang jelas antara layer presentasi, logika bisnis, dan data
- **Struktur Modul Berbasis Fitur**: Setiap fitur berdiri sendiri dengan layer presentasi, domain, dan data masing-masing
- **Pola Repository**: Layer abstraksi antara logika bisnis dan sumber data
- **Pola Service Locator**: Manajemen dependency terpusat menggunakan GetIt
- **Pola BLoC**: Manajemen state reaktif untuk komponen UI

### Arsitektur Backend API (FastAPI)

#### Struktur API Backend
```
pockeat-api/
├── main.py                 # Entry point aplikasi FastAPI dengan middleware
├── requirements.txt        # Dependencies Python
├── runtime.txt            # Runtime specification untuk deployment
├── nixpacks.toml          # Konfigurasi deployment
├── pytest.ini            # Konfigurasi testing
├── Procfile               # Process file untuk deployment
├── api/
│   ├── routes.py          # Router utama yang menggabungkan semua route
│   ├── dependencies/
│   │   └── auth.py        # Middleware autentikasi Firebase
│   ├── route_modules/
│   │   ├── food_module.py      # Endpoint analisis makanan
│   │   ├── exercise_module.py  # Endpoint analisis olahraga
│   │   ├── user_module.py      # Endpoint manajemen pengguna
│   │   ├── health_module.py    # Endpoint kesehatan sistem
│   │   └── payment_module.py   # Endpoint gateway pembayaran DOKU
│   ├── services/
│   │   ├── gemini_service.py   # Service Google Gemini AI
│   │   ├── database/          # Service database Supabase
│   │   ├── email/             # Service notifikasi email
│   │   ├── gemini/            # Service Gemini dengan exceptions
│   │   └── payment/           # Service DOKU payment gateway
│   └── models/
│       ├── food_analysis.py    # Model analisis makanan
│       ├── exercise_analysis.py # Model analisis olahraga
│       └── subscription.py     # Model langganan pengguna
├── tests/                      # Test suite dengan pytest
│   ├── conftest.py            # Konfigurasi pytest
│   ├── fixtures/              # Test fixtures
│   ├── integration/           # Integration tests
│   ├── middleware/            # Middleware tests
│   └── unit/                  # Unit tests
└── scripts/                   # Deployment dan utility scripts
```

#### Fitur API Backend
- **Analisis Makanan AI**: Endpoint untuk analisis gambar, teks, dan label nutrisi menggunakan Google Gemini
- **Analisis Olahraga AI**: Pemrosesan data olahraga dengan Google Gemini Pro Vision
- **Autentikasi Firebase**: Middleware autentikasi terintegrasi dengan authentication bypass untuk dokumentasi
- **Payment Gateway**: Integrasi DOKU untuk pembayaran langganan dengan webhook support
- **Health Monitoring**: Endpoint kesehatan sistem dan monitoring performa server
- **CORS Support**: Konfigurasi cross-origin untuk aplikasi mobile development
- **Dokumentasi Otomatis**: OpenAPI/Swagger UI otomatis di `/docs` dan `/redoc`
- **Error Handling**: Global exception handling dan logging dengan structured output
- **Testing Suite**: Comprehensive testing dengan pytest, coverage, dan CI/CD integration

#### Teknologi Backend
- **Framework**: FastAPI dengan dukungan async/await
- **Versi Python**: 3.12
- **Integrasi AI**: Google Gemini Pro Vision API melalui LangChain
- **Autentikasi**: Firebase Admin SDK dengan custom middleware
- **Database**: Supabase PostgreSQL untuk penyimpanan dataset makanan
- **Payment**: DOKU Payment Gateway dengan notifikasi webhook
- **Testing**: pytest, pytest-asyncio, pytest-cov untuk comprehensive testing
- **Code Quality**: black untuk formatting, flake8 untuk linting
- **Deployment**: Uvicorn server dengan dukungan Docker containerization

---

## Modul Implementasi

### Modul Inti

#### 1. Modul Autentikasi (`lib/features/authentication/`)
**Tujuan**: Registrasi pengguna, login, manajemen profil, dan fitur keamanan.

**Komponen Utama**:
- `LoginService`: Menangani autentikasi pengguna dengan Firebase Auth
- `UserRepository`: Mengelola operasi data pengguna
- `ProfilePage`: Interface manajemen profil pengguna
- `BugReportService`: Integrasi dengan Instabug untuk umpan balik pengguna

**Dependencies**: Firebase Auth, Instabug Flutter

#### 2. Modul Metrik Kesehatan (`lib/features/health_metrics/`)
**Tujuan**: Pengumpulan data kesehatan yang komprehensif dan proses onboarding.

**Komponen Utama**:
- `HealthMetricsService`: Manajemen data kesehatan inti
- `HealthMetricsFormCubit`: Manajemen state untuk form kesehatan
- Layar onboarding: Tinggi/Berat, Level Aktivitas, Tujuan, Preferensi diet
- `OnboardingProgressIndicator`: Pelacakan progres visual

**Dependencies**: BLoC, SharedPreferences

#### 3. Modul Pencatatan Makanan

##### Food Scan AI (`lib/features/food_scan_ai/`)
**Tujuan**: Pengenalan dan analisis makanan bertenaga AI.

**Komponen Utama**:
- `FoodScanPage`: Interface kamera untuk pemindaian makanan
- `FoodImageAnalysisService`: Pengenalan makanan berbasis gambar
- `NutritionLabelAnalysisService`: Parsing label nutrisi
- Kontrol kamera dengan flash dan switching mode

##### Food Text Input (`lib/features/food_text_input/`)
**Tujuan**: Input makanan manual melalui input teks.

**Komponen Utama**:
- `FoodTextInputPage`: Interface pencatatan makanan berbasis teks
- `FoodTextAnalysisService`: Analisis makanan berbasis teks
- `FoodTextInputRepository`: Persistensi data

##### Food Database Input (`lib/features/food_database_input/`)
**Tujuan**: Pencarian dan pemilihan makanan dari database.

**Komponen Utama**:
- `FoodDatabasePage`: Interface tab untuk pencarian makanan dan pembuatan meal
- Fungsionalitas pencarian dengan integrasi database makanan
- Komposisi meal dan manajemen porsi

#### 4. Modul Pencatatan Olahraga

##### Cardio Log (`lib/features/cardio_log/`)
**Tujuan**: Pelacakan olahraga kardiovaskular.

**Komponen Utama**:
- `CardioInputPage`: Input data olahraga
- `CardioRepository`: Persistensi dan pengambilan data
- `CalorieCalculator`: Perhitungan pembakaran kalori olahraga
- Dukungan untuk lari, bersepeda, berenang

##### Weight Training Log (`lib/features/weight_training_log/`)
**Tujuan**: Pelacakan latihan kekuatan dan angkat beban.

**Komponen Utama**:
- `WeightliftingPage`: Manajemen sesi workout
- Pemilihan olahraga berdasarkan bagian tubuh
- Pelacakan set dan repetisi
- Generasi ringkasan workout

##### Smart Exercise Log (`lib/features/smart_exercise_log/`)
**Tujuan**: Pengenalan dan pencatatan olahraga bertenaga AI.

**Komponen Utama**:
- `SmartExerciseLogPage`: Deteksi olahraga cerdas
- `ExerciseAnalysisService`: Analisis olahraga berbasis AI
- Integrasi dengan metrik kesehatan untuk perhitungan kalori

#### 5. Modul Pelacakan Kemajuan (`lib/features/progress_charts_and_graphs/`)
**Tujuan**: Pelacakan kemajuan visual dan analitik.

**Komponen Utama**:
- `ProgressPage`: Dashboard analitik utama
- `FoodLogDataService`: Agregasi data untuk grafik
- Pelacakan kemajuan berat badan
- Visualisasi asupan kalori
- Perhitungan dan tren BMI

#### 6. Modul Pendamping Hewan Peliharaan (`lib/features/pet_companion/`)
**Tujuan**: Sistem motivasi gamifikasi dengan hewan peliharaan virtual.

**Komponen Utama**:
- `PetService`: Manajemen state dan interaksi hewan peliharaan
- `PetStorePage`: Toko virtual untuk aksesoris hewan peliharaan
- Mekanik pemberian makan dan perawatan hewan peliharaan
- Sistem motivasi dan reward

#### 7. Modul Widget Layar Utama (`lib/features/home_screen_widget/`)
**Tujuan**: Integrasi widget perangkat native.

**Komponen Utama**:
- `WidgetManagerScreen`: Interface konfigurasi widget
- `SimpleFoodTrackingController`: Widget kalori dasar
- `DetailedFoodTrackingController`: Widget nutrisi komprehensif
- `WidgetInstallationService`: Manajemen lifecycle widget

#### 8. Modul Notifikasi (`lib/features/notifications/`)
**Tujuan**: Push notifications dan keterlibatan pengguna.

**Komponen Utama**:
- `NotificationService`: Penanganan notifikasi lokal dan push
- `UserActivityService`: Pemicu notifikasi berbasis aktivitas
- `NotificationSettingsScreen`: Preferensi notifikasi pengguna
- Penjadwalan notifikasi background

### Infrastruktur Inti

#### Dependency Injection (`lib/core/di/service_locator.dart`)
**Tujuan**: Manajemen dependency terpusat menggunakan GetIt.

**Fitur Utama**:
- Registrasi dan resolusi layanan
- Pola singleton dan factory
- Registrasi berbasis modul
- Isolasi lingkungan pengujian

#### Layanan Background (`lib/core/service/`)
**Tujuan**: Manajemen tugas background dan integrasi sistem.

**Komponen Utama**:
- `BackgroundServiceManager`: Koordinasi tugas background
- `PermissionService`: Manajemen izin perangkat
- `AnalyticsService`: Pelacakan perilaku pengguna
- Layanan update widget

---

## Pengaturan Lingkungan Pengembangan

### Prasyarat

#### Frontend Mobile (Flutter)
- **Flutter SDK**: Versi 3.16.0 atau lebih tinggi
- **Dart SDK**: Versi 3.2.0 atau lebih tinggi
- **Android Studio** atau **VS Code** dengan ekstensi Flutter
- **Git** untuk version control

#### Backend API (FastAPI)
- **Python**: Versi 3.12 atau lebih tinggi
- **pip**: Package manager untuk Python
- **Virtual Environment**: Untuk isolasi dependencies Python
- **Docker** (opsional): Untuk containerization

**Catatan**: Pengembangan saat ini terfokus pada platform Android saja. Pengembangan iOS belum secara aktif dilakukan oleh tim.

### Konfigurasi Lingkungan

#### 1. Instalasi Flutter
```bash
# Install Flutter (macOS/Linux)
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"

# Verifikasi instalasi
flutter doctor
```

#### 2. Pengaturan Proyek

##### Pengaturan Frontend (Flutter)
```bash
# Clone repository
git clone <repository-url>
cd pockeat-mobile

# Install dependencies
flutter pub get

# Generate file kode
flutter packages pub run build_runner build --delete-conflicting-outputs
```

##### Pengaturan Backend (FastAPI)
```bash
# Navigate ke folder backend
cd pockeat-api

# Buat virtual environment
python -m venv venv

# Aktifkan virtual environment
# Windows
venv\Scripts\activate
# macOS/Linux
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Jalankan server development
python main.py
# atau
uvicorn main:app --reload --host 0.0.0.0 --port 8080
```

#### 3. File Environment
Buat file `.env` di root proyek untuk kedua aplikasi:

##### Frontend (.env di pockeat-mobile/)
```env
# Environment Configuration
FLAVOR="staging"

# Firebase Configuration (Staging)
STAGING_FIREBASE_PROJECT_ID="your-project-id"
STAGING_FIREBASE_MESSAGING_SENDER_ID="123456789"
STAGING_FIREBASE_STORAGE_BUCKET="your-project.firebasestorage.app"

# Android Configuration
STAGING_FIREBASE_ANDROID_APP_ID="1:123456789:android:abcdef123456"
STAGING_FIREBASE_ANDROID_API_KEY="AIzaSyExampleKey123456789"

# iOS Configuration (untuk implementasi masa depan)
STAGING_FIREBASE_IOS_APP_ID="1:123456789:ios:abcdef123456"
STAGING_FIREBASE_IOS_API_KEY="AIzaSyExampleKey123456789"
STAGING_FIREBASE_IOS_BUNDLE_ID="com.example.pockeat"

# macOS Configuration (untuk implementasi masa depan)
STAGING_FIREBASE_MACOS_APP_ID="1:123456789:ios:abcdef123456"
STAGING_FIREBASE_MACOS_API_KEY="AIzaSyExampleKey123456789"
STAGING_FIREBASE_MACOS_BUNDLE_ID="com.example.pockeat"

# Web Configuration (untuk implementasi masa depan)
STAGING_FIREBASE_WEB_APP_ID="1:123456789:web:abcdef123456"
STAGING_FIREBASE_WEB_API_KEY="AIzaSyExampleKey123456789"

# Backend API Configuration
API_BASE_URL="https://your-api-domain.com/api"

# Supabase Configuration (digunakan oleh API untuk dataset makanan)
SUPABASE_URL="https://your-project.supabase.co"
SUPABASE_ANON_KEY="your_supabase_anon_key_here"

# Google Services Configuration
GOOGLE_GEMINI_PROJECT_ID="your_project_id"
GOOGLE_GEMINI_API_KEY="your_gemini_api_key_here"
```

##### Backend (.env di pockeat-api/)
```env
# Google Gemini API Configuration
GOOGLE_API_KEY="your_google_gemini_api_key_here"

# Firebase Configuration
FIREBASE_WEB_API_KEY="your_firebase_web_api_key"
FIREBASE_CREDENTIALS_JSON={"type": "service_account","project_id": "your-project-id","private_key_id": "your_private_key_id","private_key": "-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n","client_email": "firebase-adminsdk-xxx@your-project.iam.gserviceaccount.com","client_id": "your_client_id","auth_uri": "https://accounts.google.com/o/oauth2/auth","token_uri": "https://oauth2.googleapis.com/token","auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs","client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxx%40your-project.iam.gserviceaccount.com","universe_domain": "googleapis.com"}

# API Configuration
SECRET_KEY="your_secret_key_here"
DATABASE_URL="sqlite:///app.db"

# Server Configuration
PORT=8000
ENVIRONMENT="development"
GLOBAL_AUTH_ENABLED=true

# Email Configuration
SMTP_HOST="smtp.gmail.com"
SMTP_PORT="465"
SMTP_USER="your-email@gmail.com"
SMTP_PASSWORD="your_app_password_here"
SMTP_FROM_EMAIL="your-email@gmail.com"

# DOKU Payment Gateway
DOKU_API_URL="https://api-sandbox.doku.com"
DOKU_CLIENT_ID="your_doku_client_id"
DOKU_SECRET_KEY="your_doku_secret_key"
DOKU_CALLBACK_URL="https://your-domain.com/api/payment/callback"
DOKU_NOTIFICATION_URL="https://your-domain.com/payment/notification"
```

#### 4. Pengaturan Spesifik Platform

##### Pengaturan Android
1. Konfigurasi `android/app/build.gradle` dengan konfigurasi signing
2. Tambahkan file konfigurasi Google Services (`google-services.json`)
3. Konfigurasi aturan ProGuard untuk build release

##### Pengaturan iOS (Tidak Diimplementasikan Saat Ini)
**Catatan**: Meskipun file konfigurasi iOS ada dalam struktur proyek, pengembangan iOS aktif belum dilakukan oleh tim pengembang. File-file terkait iOS dihasilkan oleh struktur proyek default Flutter tetapi belum dikonfigurasi atau diuji secara aktif.

### Konfigurasi IDE

#### Ekstensi VS Code
- Flutter
- Dart
- GitLens
- Flutter Widget Snippets
- Bracket Pair Colorizer

#### Pengaturan VS Code yang Direkomendasikan
```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.enableSdkFormatter": true,
  "dart.lineLength": 80,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  }
}
```

---

## Panduan Konfigurasi

### Konfigurasi Firebase

#### Pengaturan Autentikasi
1. Aktifkan provider Autentikasi di Firebase Console:
   - Email/Password
   - Google Sign-In (opsional)
2. Konfigurasi domain yang diotorisasi
3. Siapkan template reset password

#### Pengaturan Database Firestore

##### Struktur Koleksi Firestore

Aplikasi PockEat menggunakan struktur koleksi Firestore berikut:

**1. Koleksi `users`**
- **Path**: `/users/{userId}`
- **Fungsi**: Menyimpan profil pengguna dan informasi autentikasi
- **Field Utama**:
  - `uid`: ID unik pengguna
  - `email`: Email pengguna
  - `displayName`: Nama tampilan
  - `photoURL`: URL foto profil
  - `emailVerified`: Status verifikasi email
  - `createdAt`: Timestamp pembuatan akun

**2. Koleksi `health_metrics`**
- **Path**: `/health_metrics/{userId}`
- **Fungsi**: Menyimpan data kesehatan pengguna
- **Field Utama**:
  - `height`: Tinggi badan (cm)
  - `weight`: Berat badan (kg)
  - `age`: Usia
  - `gender`: Jenis kelamin
  - `activityLevel`: Tingkat aktivitas
  - `fitnessGoal`: Tujuan kebugaran
  - `bmi`: Body Mass Index
  - `bmiCategory`: Kategori BMI
  - `desiredWeight`: Target berat badan

**3. Koleksi `caloric_requirements`**
- **Path**: `/caloric_requirements/{userId}`
- **Fungsi**: Menyimpan kebutuhan kalori harian pengguna
- **Field Utama**:
  - `basalMetabolicRate`: Metabolisme basal
  - `dailyCaloricNeeds`: Kebutuhan kalori harian
  - `proteinNeeds`: Kebutuhan protein
  - `carbNeeds`: Kebutuhan karbohidrat
  - `fatNeeds`: Kebutuhan lemak

**4. Koleksi `calorie_stats`**
- **Path**: `/calorie_stats/{docId}`
- **Fungsi**: Menyimpan statistik kalori harian
- **Field Utama**:
  - `userId`: ID pengguna
  - `date`: Tanggal statistik
  - `targetCalories`: Target kalori
  - `consumedCalories`: Kalori yang dikonsumsi
  - `burnedCalories`: Kalori yang dibakar
  - `netCalories`: Kalori bersih

**5. Koleksi `food_analysis`**
- **Path**: `/food_analysis/{docId}`
- **Fungsi**: Menyimpan hasil analisis makanan (scan foto, input teks, database)
- **Field Utama**:
  - `foodName`: Nama makanan
  - `calories`: Kalori
  - `protein`: Protein (g)
  - `carbohydrates`: Karbohidrat (g)
  - `fat`: Lemak (g)
  - `sodium`: Sodium (mg)
  - `fiber`: Serat (g)
  - `sugar`: Gula (g)
  - `timestamp`: Waktu analisis
  - `userId`: ID pengguna

**6. Koleksi `saved_meals`**
- **Path**: `/saved_meals/{docId}`
- **Fungsi**: Menyimpan makanan favorit pengguna
- **Field Utama**:
  - `userId`: ID pengguna
  - `name`: Nama makanan yang disimpan
  - `foodAnalysis`: Data analisis makanan lengkap
  - `createdAt`: Waktu penyimpanan
  - `updatedAt`: Waktu update terakhir

**7. Koleksi `exerciseAnalysis`**
- **Path**: `/exerciseAnalysis/{docId}`
- **Fungsi**: Menyimpan hasil analisis olahraga dari input teks
- **Field Utama**:
  - `exerciseType`: Jenis olahraga
  - `duration`: Durasi olahraga
  - `intensity`: Intensitas (Rendah/Sedang/Tinggi)
  - `estimatedCalories`: Estimasi kalori yang dibakar
  - `timestamp`: Waktu logging
  - `originalInput`: Input asli pengguna
  - `userId`: ID pengguna

**8. Koleksi `weight_lifting_logs`**
- **Path**: `/weight_lifting_logs/{docId}`
- **Fungsi**: Menyimpan log latihan beban
- **Field Utama**:
  - `name`: Nama latihan
  - `bodyPart`: Bagian tubuh yang dilatih
  - `metValue`: Nilai MET untuk kalkulasi kalori
  - `userId`: ID pengguna
  - `sets`: Array set latihan
    - `weight`: Berat (kg)
    - `reps`: Repetisi
    - `duration`: Durasi set (detik)

**9. Koleksi `cardioActivities`**
- **Path**: `/cardioActivities/{docId}`
- **Fungsi**: Menyimpan aktivitas kardio
- **Field Utama**:
  - `activityType`: Jenis aktivitas kardio
  - `duration`: Durasi (menit)
  - `intensity`: Intensitas aktivitas
  - `caloriesBurned`: Kalori yang dibakar
  - `date`: Tanggal aktivitas
  - `userId`: ID pengguna

**10. Sub-koleksi `weights_history`**
- **Path**: `/health_metrics/{userId}/weights_history/{docId}`
- **Fungsi**: Menyimpan riwayat perubahan berat badan
- **Field Utama**:
  - `weight`: Berat badan (kg)
  - `timestamp`: Waktu pencatatan

##### Aturan Keamanan Firestore
```javascript
// Security Rules untuk Firebase Firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Pengguna hanya dapat mengakses data mereka sendiri
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Metrik kesehatan bersifat spesifik pengguna
    match /health_metrics/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Sub-koleksi riwayat berat badan
      match /weights_history/{docId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Kebutuhan kalori pengguna
    match /caloric_requirements/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Statistik kalori - hanya untuk pengguna sendiri
    match /calorie_stats/{docId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Analisis makanan - hanya untuk pengguna sendiri
    match /food_analysis/{docId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Makanan tersimpan - hanya untuk pengguna sendiri
    match /saved_meals/{docId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Analisis olahraga - hanya untuk pengguna sendiri
    match /exerciseAnalysis/{docId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Log latihan beban - hanya untuk pengguna sendiri
    match /weight_lifting_logs/{docId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Aktivitas kardio - hanya untuk pengguna sendiri
    match /cardioActivities/{docId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

#### Pengaturan Cloud Messaging
1. Konfigurasi FCM di Firebase Console
2. Download service account key untuk notifikasi server-side
3. Siapkan notification channels untuk Android

### Konfigurasi Supabase (hanya untuk API)

**Catatan**: Supabase hanya digunakan oleh pockeat-api untuk menyimpan dataset makanan. Aplikasi Flutter menggunakan Firebase Firestore untuk semua data pengguna.

#### Skema Database (khusus untuk dataset makanan)
```sql
-- Tabel nutrition_data untuk dataset makanan lengkap dengan informasi nutrisi
CREATE TABLE nutrition_data (
  id INTEGER PRIMARY KEY,
  food TEXT NOT NULL,
  
  -- Makronutrien utama
  caloric_value DECIMAL,
  protein DECIMAL,
  carbohydrates DECIMAL,
  fat DECIMAL,
  saturated_fats DECIMAL,
  
  -- Nutrisi penting
  sodium DECIMAL,
  dietary_fiber DECIMAL,
  sugars DECIMAL,
  cholesterol DECIMAL,
  nutrition_density DECIMAL,
  
  -- Vitamin
  vitamin_a DECIMAL,
  vitamin_b1 DECIMAL,
  vitamin_b2 DECIMAL,
  vitamin_b3 DECIMAL,
  vitamin_b5 DECIMAL,
  vitamin_b6 DECIMAL,
  vitamin_b11 DECIMAL,
  vitamin_b12 DECIMAL,
  vitamin_c DECIMAL,
  vitamin_d DECIMAL,
  vitamin_e DECIMAL,
  vitamin_k DECIMAL,
  
  -- Mineral
  calcium DECIMAL,
  copper DECIMAL,
  iron DECIMAL,
  magnesium DECIMAL,
  manganese DECIMAL,
  phosphorus DECIMAL,
  potassium DECIMAL,
  selenium DECIMAL,
  zinc DECIMAL,
  
  -- Informasi tambahan
  water DECIMAL,
  monounsaturated_fats DECIMAL,
  polyunsaturated_fats DECIMAL,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Index untuk pencarian makanan
CREATE INDEX idx_nutrition_data_food ON nutrition_data(food);
CREATE INDEX idx_nutrition_data_caloric_value ON nutrition_data(caloric_value);

-- Tabel food_synonyms untuk pencarian alternatif (opsional)
CREATE TABLE food_synonyms (
  id SERIAL PRIMARY KEY,
  food_id INTEGER REFERENCES nutrition_data(id),
  synonym TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
```

### Konfigurasi Spesifik Environment

#### Environment Development
- Aktifkan debug mode
- Gunakan proyek Firebase staging
- Aktifkan verbose logging
- Mock panggilan API eksternal untuk pengujian

#### Environment Staging
- Konfigurasi mirip production
- Panggilan API eksternal terbatas
- Monitoring performa diaktifkan
- Akses user beta testing

#### Environment Production
- Build yang dioptimasi dengan ProGuard/R8
- Proyek Firebase production
- Analitik dan crash reporting diaktifkan
- **Masa Depan**: Distribusi App Store/Play Store (belum diimplementasikan)

### Feature Flags
```dart
class FeatureFlags {
  static const bool enablePetStore = true;
  static const bool enableAdvancedAnalytics = false;
  static const bool enableSocialFeatures = true;
  
  static bool isFeatureEnabled(String feature) {
    switch (feature) {
      case 'pet_store':
        return enablePetStore;
      case 'advanced_analytics':
        return enableAdvancedAnalytics;
      case 'social_features':
        return enableSocialFeatures;
      default:
        return false;
    }
  }
}
```

---

## Instruksi Menjalankan & Pengujian

### Menjalankan Aplikasi

#### Frontend Mobile (Flutter)

##### Mode Development
```bash
# Jalankan pada perangkat/emulator yang terhubung
flutter run

# Jalankan dengan flavor spesifik
flutter run --flavor development -t lib/main.dart

# Jalankan dengan hot reload diaktifkan (default di debug mode)
flutter run --hot
```

##### Debug vs Release Builds
```bash
# Debug build (default)
flutter run --debug

# Profile build (pengujian performa)
flutter run --profile

# Release build
flutter run --release
```

##### Perintah Spesifik Platform
```bash
# Android (Platform pengembangan utama)
flutter run -d android

# Perangkat spesifik
flutter run -d device_id
```

**Catatan**: Perintah iOS dihilangkan karena tim belum secara aktif mengembangkan untuk platform iOS.

#### Backend API (FastAPI)

##### Development Server
```bash
# Navigate ke direktori backend
cd pockeat-api

# Aktifkan virtual environment
# Windows
venv\Scripts\activate
# macOS/Linux
source venv/bin/activate

# Jalankan development server dengan hot reload
python main.py
# atau menggunakan uvicorn langsung
uvicorn main:app --reload --host 0.0.0.0 --port 8080

# Jalankan dengan environment spesifik
ENVIRONMENT=development python main.py
```

##### Production Server
```bash
# Jalankan dengan gunicorn (production)
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8080

# Dengan Docker
docker build -t pockeat-api .
docker run -p 8080:8080 pockeat-api
```

##### API Documentation
Setelah server berjalan, akses dokumentasi API di:
- Swagger UI: `http://localhost:8080/docs`
- ReDoc: `http://localhost:8080/redoc`
- OpenAPI JSON: `http://localhost:8080/openapi.json`

### Strategi Pengujian

#### Unit Tests
```bash
# Jalankan semua unit tests
flutter test

# Jalankan file test spesifik
flutter test test/features/authentication/services/login_service_test.dart

# Jalankan tests dengan coverage
flutter test --coverage

# Generate laporan coverage
genhtml coverage/lcov.info -o coverage/html
```

#### Widget Tests
```bash
# Jalankan widget tests
flutter test test/features/*/presentation/screens/*_test.dart

# Jalankan dengan output verbose
flutter test --verbose
```

#### Integration Tests
```bash
# Jalankan integration tests
flutter drive --target=test_driver/app.dart
```

### Konfigurasi Test

#### Struktur Test
```
test/
├── features/
│   ├── authentication/
│   │   ├── services/
│   │   │   └── login_service_test.dart
│   │   └── presentation/
│   │       └── screens/
│   │           └── login_page_test.dart
│   ├── health_metrics/
│   └── food_scan_ai/
├── core/
│   ├── services/
│   └── di/
└── test_helpers/
    ├── mock_services.dart
    └── test_utils.dart
```

#### Test Helpers dan Mocks
```dart
// test_helpers/mock_services.dart
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirestore extends Mock implements FirebaseFirestore {}
class MockUserRepository extends Mock implements UserRepository {}

// Utilitas test
Future<void> pumpTestWidget(
  WidgetTester tester,
  Widget widget, {
  NavigatorObserver? observer,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: widget,
      navigatorObservers: observer != null ? [observer] : [],
    ),
  );
}
```

### Pengujian Performa

#### Tools Performa Flutter
```bash
# Jalankan dengan performance overlay
flutter run --enable-software-rendering

# Profile widget builds
flutter run --profile --trace-startup

# Analisis ukuran bundle
flutter build apk --analyze-size
```

#### Profiling Memory dan CPU
1. Gunakan Flutter Inspector di IDE
2. Aktifkan performance overlay di debug mode
3. Gunakan DevTools untuk profiling detail
4. Monitor memory leaks dengan `flutter memory`

---

## Panduan Deployment

### Persiapan Build

#### Manajemen Versi
```yaml
# pubspec.yaml
version: 1.0.0+1  # versi+build_number

# Update untuk releases
version: 1.1.0+2
```

#### Optimasi Build
```bash
# Bersihkan build artifacts
flutter clean

# Dapatkan dependencies
flutter pub get

# Generate file yang diperlukan
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Deployment Android

#### Release Build
```bash
# Build APK
flutter build apk --release

# Build App Bundle (untuk submission Play Store masa depan)
flutter build appbundle --release

# Build dengan split per ABI
flutter build apk --release --split-per-abi
```

#### Konfigurasi Signing
```gradle
// android/app/build.gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### Deploy Play Store (Implementasi Masa Depan)
**Status**: Belum diimplementasikan. Aplikasi belum di-deploy ke Google Play Store.

**Langkah-langkah deployment masa depan**:
1. Buat signed app bundle
2. Upload ke Play Console
3. Konfigurasi store listing
4. Setup release tracks (internal, alpha, beta, production)
5. Konfigurasi App Signing by Google Play

### Deployment iOS (Belum Diimplementasikan)

**Status**: Tim belum secara aktif mengembangkan untuk platform iOS. Meskipun struktur proyek Flutter menyertakan file konfigurasi iOS, file-file tersebut belum dikonfigurasi, diuji, atau di-deploy secara aktif.

### Pipeline CI/CD

#### Workflow GitHub Actions
```yaml
# .github/workflows/ci.yml
name: Pipeline CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test
      
      - name: Generate coverage
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3

  build_android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Upload to Firebase App Distribution
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_APP_ID }}
          token: ${{ secrets.FIREBASE_TOKEN }}
          groups: testers
          file: build/app/outputs/flutter-apk/app-release.apk
```

### Firebase App Distribution

#### Setup
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login dan initialize
firebase login
firebase init hosting

# Deploy ke App Distribution
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:123456789:android:abcd1234 \
  --groups "testers"
```

### Strategi Deployment Environment

#### Strategi Branch
- `main`: Rilis production
- `develop`: Environment staging
- `feature/*`: Branch development

#### Environment Deployment
1. **Development**: Deployment berkelanjutan dari branch `develop`
2. **Staging**: Rilis mingguan untuk pengujian QA
3. **Production**: Rilis dua mingguan setelah validasi staging

---

## Keterbatasan Proyek & Pengembangan Masa Depan

### Keterbatasan Saat Ini

#### Keterbatasan Teknis
1. **Kemampuan Offline**: Fungsionalitas offline terbatas, memerlukan internet untuk sebagian besar fitur
2. **Dukungan Platform**: Saat ini terfokus pada pengembangan Android, iOS belum diimplementasikan
3. **Performa Kamera**: Pemindaian makanan mungkin kesulitan dalam kondisi cahaya rendah
4. **Sinkronisasi Database**: Potensi konflik sinkronisasi antara Firebase dan Supabase
5. **Platform Widget**: Widget layar utama terbatas pada Android 8+ (iOS belum diimplementasikan)

#### Keterbatasan Fungsional
1. **Akurasi AI**: Akurasi pengenalan makanan bergantung pada kualitas gambar dan cakupan database
2. **Perpustakaan Olahraga**: Database olahraga terbatas dibandingkan aplikasi fitness khusus
3. **Fitur Sosial**: Fungsionalitas sosial dasar tanpa fitur komunitas lanjutan
4. **Internasionalisasi**: Saat ini hanya mendukung bahasa Inggris
5. **Aksesibilitas**: Fitur aksesibilitas terbatas untuk pengguna dengan disabilitas

#### Keterbatasan Performa
1. **Penggunaan Memori**: Pemrosesan gambar besar dapat menyebabkan masalah memori pada perangkat lama
2. **Konsumsi Baterai**: Layanan background dapat berdampak pada daya tahan baterai
3. **Ketergantungan Jaringan**: Sangat bergantung pada konektivitas jaringan
4. **Storage**: Keterbatasan penyimpanan lokal untuk data cache

### Roadmap Pengembangan Masa Depan

#### Fase 1: Peningkatan Inti (Q3-Q4 2025)
**Prioritas: Tinggi**

1. **Peningkatan Fungsionalitas Offline**
   - Caching database lokal
   - Pencatatan makanan offline dengan sinkronisasi
   - Fungsionalitas dasar tanpa internet

2. **Optimasi Performa**
   - Kompresi gambar untuk pemindaian makanan
   - Optimasi layanan background
   - Peningkatan penggunaan memori

3. **Peningkatan UI/UX**
   - Dukungan dark mode
   - Peningkatan aksesibilitas
   - Alur onboarding yang diperbaiki

#### Fase 2: Ekspansi Fitur (Q1-Q2 2026)
**Prioritas: Sedang**

1. **Analitik Lanjutan**
   - Wawasan berbasis machine learning
   - Analitik kesehatan prediktif
   - Generasi laporan kustom

2. **Peningkatan Fitur Sosial**
   - Koneksi teman
   - Sistem tantangan
   - Berbagi resep komunitas

3. **Ekspansi Integrasi**
   - Integrasi aplikasi kesehatan (Apple Health, Google Fit)
   - Sinkronisasi fitness tracker
   - Integrasi aplikasi diet pihak ketiga

#### Fase 3: Ekspansi Platform (Q3-Q4 2026)
**Prioritas: Sedang**

1. **Aplikasi Web**
   - Progressive Web App (PWA)
   - Aplikasi pendamping desktop
   - Dashboard admin

2. **Dukungan Wearable**
   - Integrasi Apple Watch
   - Dukungan Android Wear
   - Kompatibilitas smart fitness tracker

3. **Integrasi Smart Home**
   - Konektivitas smart scale
   - Integrasi peralatan dapur
   - Sinkronisasi perangkat IoT

#### Fase 4: Fitur Lanjutan (Q1-Q2 2027)
**Prioritas: Rendah**

1. **AI dan Machine Learning**
   - Rekomendasi makanan yang dipersonalisasi
   - Wawasan kesehatan prediktif
   - Pengenalan makanan lanjutan

2. **Integrasi Healthcare**
   - Portal penyedia layanan kesehatan
   - Integrasi data medis
   - Fitur telehealth

3. **Fitur Enterprise**
   - Program wellness korporat
   - Manajemen pengguna bulk
   - Dashboard analitik lanjutan

### Path Upgrade Teknologi

#### Framework Flutter
- **Saat Ini**: Flutter 3.16.x
- **Target**: Flutter 4.x (ketika tersedia)
- **Manfaat**: Peningkatan performa, widget baru, dukungan web yang lebih baik

#### Evolusi State Management
- **Saat Ini**: BLoC + Provider
- **Pertimbangan**: Migrasi Riverpod
- **Manfaat**: Testing yang lebih baik, boilerplate berkurang, performa meningkat

#### Arsitektur Backend
- **Saat Ini**: Hybrid Firebase + Supabase
- **Masa Depan**: Arsitektur microservices
- **Manfaat**: Skalabilitas lebih baik, isolasi layanan, fleksibilitas teknologi

#### Strategi Database
- **Saat Ini**: Firestore + PostgreSQL (Supabase)
- **Masa Depan**: Strategi multi-database dengan caching layers
- **Manfaat**: Performa meningkat, redundansi data, optimasi biaya

### Pertimbangan Skalabilitas

#### Proyeksi Pertumbuhan Pengguna
- **Tahun 1**: 10.000 pengguna aktif
- **Tahun 2**: 100.000 pengguna aktif
- **Tahun 3**: 1.000.000 pengguna aktif

#### Scaling Infrastruktur
1. **Scaling Database**: Implementasi database sharding dan read replicas
2. **Scaling API**: Arsitektur microservices dengan auto-scaling
3. **Implementasi CDN**: Content delivery global untuk gambar dan aset
4. **Strategi Caching**: Implementasi Redis untuk data yang sering diakses

#### Optimasi Biaya
1. **Penggunaan Firebase**: Optimasi query Firestore dan storage
2. **Scaling Supabase**: Implementasi connection pooling dan optimasi query
3. **Cloud Functions**: Optimasi waktu eksekusi dan penggunaan memori
4. **Optimasi Storage**: Kompresi gambar dan integrasi CDN

---

## Lampiran

### Script Deployment

#### Script Release Android
```bash
#!/bin/bash
# scripts/deploy_android.sh

set -e

echo "🚀 Memulai Android Release Build..."

# Bersihkan build sebelumnya
flutter clean
flutter pub get

# Generate file yang diperlukan
flutter packages pub run build_runner build --delete-conflicting-outputs

# Build release APK
echo "📱 Building APK..."
flutter build apk --release

# Build App Bundle
echo "📦 Building App Bundle..."
flutter build appbundle --release

# Upload ke Firebase App Distribution
echo "🔥 Uploading ke Firebase App Distribution..."
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app "$FIREBASE_ANDROID_APP_ID" \
  --groups "internal-testers" \
  --release-notes "Release build $(date)"

echo "✅ Deployment Android selesai!"
```

#### Script Release iOS (Implementasi Masa Depan)
```bash
#!/bin/bash
# scripts/deploy_ios.sh (belum diimplementasikan)

set -e

echo "🚀 Memulai iOS Release Build..."

# Catatan: Script ini belum diimplementasikan dan diuji
# Akan dikembangkan ketika tim mulai mengerjakan platform iOS

flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter build ios --release --no-codesign

echo "✅ iOS deployment belum tersedia."
```

### Template Konfigurasi

#### Template Konfigurasi Firebase
```json
{
  "project_info": {
    "project_number": "PROJECT_NUMBER",
    "firebase_url": "https://PROJECT_ID-default-rtdb.firebaseio.com",
    "project_id": "PROJECT_ID",
    "storage_bucket": "PROJECT_ID.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "APP_ID",
        "android_client_info": {
          "package_name": "com.example.pockeat"        }
      },
      "oauth_client": [
        {
          "client_id": "CLIENT_ID",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "API_KEY"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": [
            {
              "client_id": "CLIENT_ID",
              "client_type": 3
            }
          ]
        }
      }
    }
  ],
  "configuration_version": "1"
}
```

#### Template Konfigurasi Environment
```yaml
# config/environments/development.yaml
environment: development
debug: true
api_base_url: "https://api-dev.pockeat.com"

firebase:
  project_id: "pockeat-dev"
  app_id: "1:123456789:android:abcd1234"

supabase:
  url: "https://your-project.supabase.co"
  anon_key: "your-anon-key"

features:
  enable_analytics: false
  enable_crash_reporting: true
  enable_performance_monitoring: false
  enable_debug_logging: true

api_limits:
  requests_per_minute: 1000
  max_image_size_mb: 10
  max_concurrent_uploads: 3
```

### Konfigurasi Testing

#### Pengaturan Environment Test
```dart
// test/test_config.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:pockeat/core/di/service_locator.dart';

class TestConfig {
  static void setupTestEnvironment() {
    // Reset service locator
    GetIt.instance.reset();
    
    // Register mock services
    _registerMockServices();
  }
  
  static void _registerMockServices() {
    final getIt = GetIt.instance;
    
    // Register mocks
    getIt.registerSingleton<MockFirebaseAuth>(MockFirebaseAuth());
    getIt.registerSingleton<MockFirestore>(MockFirestore());
    // ... layanan mock lainnya
  }
  
  static void tearDown() {
    GetIt.instance.reset();
  }
}

// Test helper untuk widget tests
Widget createTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
    navigatorKey: GlobalKey<NavigatorState>(),
  );
}
```

### Monitoring dan Analitik

#### Analytics Events Configuration
```dart
// lib/core/analytics/analytics_events.dart
class AnalyticsEvents {
  // User events
  static const String userLogin = 'user_login';
  static const String userRegister = 'user_register';
  static const String userLogout = 'user_logout';
  
  // Food logging events
  static const String foodScanned = 'food_scanned';
  static const String foodLogged = 'food_logged';
  static const String mealSaved = 'meal_saved';
  
  // Exercise events
  static const String exerciseLogged = 'exercise_logged';
  static const String workoutCompleted = 'workout_completed';
  
  // Pet interaction events
  static const String petFed = 'pet_fed';
  static const String petItemPurchased = 'pet_item_purchased';
  
  // Health metrics events
  static const String weightUpdated = 'weight_updated';
  static const String goalUpdated = 'goal_updated';
  
  // App usage events
  static const String appOpened = 'app_opened';
  static const String featureUsed = 'feature_used';
  static const String screenViewed = 'screen_viewed';
}
```

#### Performance Monitoring Configuration
```dart
// lib/core/monitoring/performance_monitor.dart
class PerformanceMonitor {
  static void trackAppStart() {
    // Track app startup time
  }
  
  static void trackScreenLoad(String screenName) {
    // Track screen loading performance
  }
  
  static void trackAPICall(String endpoint, Duration duration) {
    // Track API call performance
  }
  
  static void trackImageProcessing(Duration duration, int imageSize) {
    // Track food scanning performance
  }
}
```

### Dokumentasi API

#### API Analisis Makanan
```dart
// Dokumentasi endpoint API contoh
/*
POST /api/v1/food/analyze
Content-Type: application/json

Request:
{
  "image": "base64_encoded_image",
  "mode": "food|label",
  "user_id": "string"
}

Response:
{
  "success": true,
  "data": {
    "food_name": "Grilled Chicken Breast",
    "confidence": 0.95,
    "nutrition": {
      "calories": 165,
      "protein": 31,
      "carbs": 0,
      "fat": 3.6,
      "fiber": 0,
      "sugar": 0
    },
    "ingredients": [
      {
        "name": "Chicken Breast",
        "quantity": 100,
        "unit": "g"
      }
    ]
  }
}
*/
```

### Panduan Troubleshooting

#### Masalah Umum

1. **Kegagalan Build**
   ```bash
   # Clear Flutter cache
   flutter clean
   flutter pub get
   
   # Clear iOS build cache (untuk implementasi masa depan)
   cd ios && rm -rf build/ && cd ..
   
   # Clear Android build cache
   cd android && ./gradlew clean && cd ..
   ```

2. **Masalah Koneksi Firebase**
   - Verifikasi `google-services.json` berada di lokasi yang benar
   - Periksa konfigurasi proyek Firebase
   - Pastikan SHA-1 fingerprints telah dikonfigurasi

3. **Masalah Testing Widget**
   ```dart
   // Setup test umum
   testWidgets('should render correctly', (tester) async {
     await tester.pumpWidget(createTestWidget(MyWidget()));
     await tester.pumpAndSettle(); // Wait for animations
     
     expect(find.text('Expected Text'), findsOneWidget);
   });
   ```

4. **Masalah Performa**
   - Gunakan `flutter run --profile` untuk testing performa
   - Aktifkan performance overlay: `flutter run --enable-software-rendering`
   - Monitor penggunaan memori dengan DevTools

### Pertimbangan Keamanan

#### Perlindungan Data
1. **Enkripsi**: Semua data sensitif dienkripsi saat rest dan in transit
2. **Autentikasi**: Dukungan multi-factor authentication
3. **Keamanan API**: Rate limiting dan validasi request
4. **Privasi**: Langkah-langkah kepatuhan GDPR dan CCPA

#### Keamanan Kode
1. **Manajemen Secret**: Environment variables untuk data sensitif
2. **Code Obfuscation**: Aturan ProGuard untuk Android release builds
3. **Certificate Pinning**: Validasi sertifikat SSL/TLS
4. **Dependency Scanning**: Pemindaian kerentanan keamanan secara berkala

---

*Dokumentasi ini dipelihara dan diperbarui secara berkala. Untuk informasi terbaru, silakan merujuk ke repository proyek dan sistem dokumentasi internal.*

**Terakhir Diperbarui**: Mei 2025
**Versi**: 1.0.0  
**Maintainers**: Tim Pengembangan PockEat