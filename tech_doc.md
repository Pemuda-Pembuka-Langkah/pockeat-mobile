# PockEat - Technical Document

## Table of Contents
1. [System Overview](#system-overview)
2. [System Architecture](#system-architecture)
3. [Implementation Modules](#implementation-modules)
4. [Development Environment Setup](#development-environment-setup)
5. [Configuration Guide](#configuration-guide)
6. [Run & Testing Instructions](#run--testing-instructions)
7. [Deployment Guide](#deployment-guide)
8. [Project Limitations & Future Development](#project-limitations--future-development)
9. [Appendix](#appendix)

---

## System Overview

### Project Description
**PockEat** is a mobile application for health and fitness tracking, built with Flutter/Dart. It acts as a digital companion that helps users monitor their nutritional intake, physical activities, and overall health progress, enhanced by AI-powered analysis. To further encourage user engagement, PockEat features a virtual pet companion that motivates and accompanies users on their wellness journey.

### Key Features
- **AI-Powered Food Logging**: Smart food analysis using AI through image scanning, text input, or nutrition label recognition.
- **Physical Activity Tracking**: Log cardio, strength training, and other workouts with burned calories analysis and activity recognition using AI.
- **Virtual Pet Companion**: A gamified system that motivates users through interactions with a virtual pet that evolves with your health progress.
- **Health Tracking & Analytics**: Record key health metrics like height, weight, age, and fitness goals. Visualize progress with trend graphs, including weight fluctuations.
- **Homescreen Widget**: Instantly view users' nutrition summaries and progress directly from their device’s homescreen.
- **Smart Notifications**: Scheduled reminders and personalized motivational messages based on users' activity patterns.
- **Favorite Foods Library**: Save frequently consumed foods for quicker and easier logging in the future.
- **Social Sharing**: Share food logs and activity records on social media to celebrate progress.

### Tech Stack

#### Frontend Mobile (Flutter)
- **Framework**: Flutter 3.x with Dart
- **State Management**: BLoC Pattern combined with Provider
- **Dependency Injection**: GetIt service locator
- **Testing**: Unit testing with Mockito, widget tests, and integration tests
- **Target Platform**: Android (primary development focus)

PockEat uses BLoC architecture to separate UI and business logic cleanly. Provider handles lightweight dependency injection at the widget level, while GetIt serves as a global service locator in the core layer to enhance modularity and facilitate testing.

#### Backend API (FastAPI)
- **Framework**: FastAPI (Python)
- **Runtime**: Python 3.12
- **Server**: Uvicorn with full async/await support
- **Authentication Middleware**: Firebase Admin SDK with custom middleware
- **API Documentation**: Auto-generated via OpenAPI/Swagger UI
- **CORS**: Configured for cross-origin requests from the mobile app
- **Testing**: `pytest`, `pytest-asyncio`, and `pytest-cov` for test coverage report
- **Code Quality**: Enforced using `black` (formatter) and `flake8` (linter)

#### AI Services & Backend Integrations
- **AI Integration**: Google Gemini Pro Vision API via LangChain
- **Backend Services**: Firebase (Authentication, Firestore, Cloud Messaging)
- **Database**: Firebase Firestore for mobile app data and Supabase PostgreSQL for food dataset queries via the API
- **Payment Gateway**: DOKU for payment processing and subscription handling

#### Infrastructure & DevOps
- **CI/CD**: GitHub Actions for automated testing and deployment
- **Deployment Targets**: Firebase App Distribution & Docker containers
- **Monitoring Tools**: Firebase Analytics, Performance Monitoring, and Crash Reporting
- **Notifications System**: Firebase Cloud Messaging integrated with `flutter_local_notifications`
- **Environment Management**: `dotenv` for environment-specific configurations

---

## System Architecture

### C4 Level 1 – System Context Diagram
```
┌────────────────────────────────────────────────────────────────────────┐
│                           PockEat Ecosystem                            │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│  ┌──────────────────┐         ┌──────────────────┐         ┌─────────┐ │
│  │                  │         │                  │         │         │ │
│  │   Mobile User    │ ──────▶   PockEat Mobile   ──────▶  | Google  │ │
│  │                  │         │   Application    │         │ Gemini  │ │
│  └──────────────────┘         └──────────────────┘         │   AI    │ │
│                                         │                  └─────────┘ │
│                                         │                              │
│                                         ▼                              │
│  ┌──────────────────┐         ┌──────────────────┐         ┌─────────┐ │
│  │                  │         │                  │         │         │ │
│  │    Firebase      │ ◀──────   FastAPI Backend  ──────▶  │Supabase │ │
│  │ (Auth, Firestore,│         │   (Python 3.12)  |         │ Dataset │ │
│  │  FCM, Storage)   │         │                  │         └─────────┘ │
│  └──────────────────┘         └──────────────────┘                     │
│                                         │                              │
│                                         ▼                              │
│                               ┌──────────────────┐                     │
│                               │                  │                     │
│                               │   DOKU Payment   │                     │
│                               │     Gateway      │                     │
│                               └──────────────────┘                     │
└────────────────────────────────────────────────────────────────────────┘
```

### C4 Level 2 - Container Diagram

#### PockEat Mobile App (Flutter)

The mobile app follows Clean Architecture principles with the following layered structure:
- **Presentation Layer**: Handles UI rendering and user interaction.
- **Business Logic Layer**: Manages application logic using BLoC and service classes.
- **Data Layer**: Interfaces with external data sources such as APIs and local storage.


```
┌─────────────────────────────────────────────────────────────────┐
│                   PockEat Mobile Application                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐   │
│ │ Presentation    │  │ Business Logic  │  │      Data       │   │
│ │ Layer           │  │ Layer           │  │ Layer           │   │
│ │ • Screens       │  │ • Services      │  │ • Repositories  │   │
│ │ • Widgets       │  │ • BLoC/Cubits   │  │ • Data Sources  │   │
│ │ • Components    │  │ • Use Cases     │  │ • Models        │   │
│ └─────────────────┘  └─────────────────┘  └─────────────────┘   │
│                                                                 │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │                    Core Infrastructure                      │ │
│ │                                                             │ │
│ │ • Dependency Injection (GetIt)                              │ │
│ │ • Navigation Service                                        │ │
│ │ • Analytics Service                                         │ │
│ │ • Notification Service                                      │ │
│ │ • Background Services                                       │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ HTTP/HTTPS API Calls
┌─────────────────────────────────────────────────────────────────┐
│                    FastAPI Backend Server                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐   │
│ │    API Routes   │  │     Services    │  │   Dependencies  │   │
│ │ • Food Module   │  │ • Gemini AI     │  │ • Auth Layer    │   │
│ │ • Exercise      │  │ • Database Ops  │  │ • Database ORM  │   │
│ │ • User Module   │  │ • Payment Svc   │  │ • Configuration │   │
│ │ • Health Module │  │ • Email Svc     │  │ • Logging       │   │
│ │ • Payment       │  │                 │  │                 │   │
│ └─────────────────┘  └─────────────────┘  └─────────────────┘   │
└─────────────────────────────────────────────────────────────────┘

```

### Software Architecture Patterns
- **Clean Architecture**: Clear separation between presentation, business logic, and data layers to promote testability and scalability.
- **Feature-Based Modular Structure**: Each feature is self-contained, consisting of its own presentation, domain, and data layers.
- **Repository Pattern**: Acts as an abstraction between the business logic and data sources (remote or local).
- **Service Locator Pattern**: Uses GetIt for centralized and test-friendly dependency management.
- **BLoC Pattern**: Enables reactive state management and predictable UI behavior.

### Backend API Architecture (FastAPI)

#### API Backend Structure Overview
```
pockeat-api/
├── main.py                 # Application entry point with FastAPI and middleware setup
├── requirements.txt        # Python dependencies
├── runtime.txt            # Runtime specification for deployment
├── nixpacks.toml          # Deployment configuration (e.g., for Railway)
├── pytest.ini            # Pytest configuration
├── Procfile               # Process specification for deployment
├── api/
│   ├── routes.py          # Central router that aggregates all route modules
│   ├── dependencies/
│   │   └── auth.py        # Firebase authentication middleware
│   ├── route_modules/
│   │   ├── food_module.py      # Endpoints for food analysis
│   │   ├── exercise_module.py  # Endpoints for exercise analysis
│   │   ├── user_module.py      # Endpoints for user account management
│   │   ├── health_module.py    # Endpoints for system health monitoring
│   │   └── payment_module.py   # Endpoints for DOKU payment gateway integration
│   ├── services/
│   │   ├── gemini_service.py   # Google Gemini service logic
│   │   ├── database/          # Supabase database service
│   │   ├── email/             # Email notification service
│   │   ├── gemini/            # Gemini service with error handling exceptions
│   │   └── payment/           # DOKU payment service
│   └── models/
│       ├── food_analysis.py    # Data model for food analysis
│       ├── exercise_analysis.py # Data model for exercise analysis
│       └── subscription.py     # Data model for user subscriptions
├── tests/                      # Full testing suite using pytest
│   ├── conftest.py            # Pytest configuration and shared fixtures
│   ├── fixtures/              # Test data fixtures
│   ├── integration/           # Integration tests
│   ├── middleware/            # Middleware tests
│   └── unit/                  # Unit tests
└── scripts/                   # Deployment and utility scripts
```

#### Backend API Features
- **AI-Powered Food Analysis**: Endpoints for analyzing food from images, text, and nutrition labels using Google Gemini API.

- **AI-Powered Workout Analysis**: Exercise analysis processing using Gemini Pro Vision, including calorie estimation and classification.

- **Firebase Authentication**: Integrated authentication middleware with documentation bypass for Swagger access.

- **Payment Integration**: DOKU gateway for subscription payments, including support for webhook-based notifications.

- **Server Health Monitoring**: Dedicated endpoints to monitor server health and performance.

- **CORS Configuration**: Cross-origin support for mobile development environments.

- **Auto-Generated Documentation**: OpenAPI-compliant interactive documentation available at /docs and /redoc.

- **Robust Error Handling**: Global exception management and structured logging for consistent API behavior.

- **Comprehensive Testing**: Full suite of unit, integration, and middleware tests with code coverage reports and CI/CD integration.


#### Backend Technologies
- **Framework**: FastAPI with full async/await support
- **Python Version**: 3.12
- **AI Integration**: Google Gemini Pro Vision API via LangChain
- **Authentication**: Firebase Admin SDK with custom middleware
- **Database**: Supabase PostgreSQL for food dataset storage and retrieval
- **Payments**: DOKU Payment Gateway with webhook support
- **Testing Tools**: `pytest`, `pytest-asyncio`, `pytest-cov` for thorough testing and coverage reporting
- **Code Quality**: `black` for formatting and `flake8` for linting
- **Deployment**: Uvicorn server with Docker container support for flexible deployment

---

## Implementation Modules

### Core Modules

#### 1. Authentication Module (`lib/features/authentication/`)
**Purpose**: Handles user registration, login, profile management, and basic security features.

**Key Components**:
- `LoginService`: Handles user authentication using Firebase Auth
- `UserRepository`: Manages user data operations
- `ProfilePage`: UI for user profile management
- `BugReportService`: Integrates Instabug for in-app user feedback and bug reporting

**Dependencies**: Firebase Auth, Instabug Flutter SDK

#### 2. Health Metrics Module (`lib/features/health_metrics/`)
**Purpose**: Collects comprehensive user health data and manages the onboarding flow.

**Key Components**:
- `HealthMetricsService`: Core health data management logic
- `HealthMetricsFormCubit`: State management for health input forms
- Onboarding screens: Height/Weight, Activity Level, Goals, Dietary Preferences
- `OnboardingProgressIndicator`: Visual progress tracker for onboarding steps

**Dependencies**: BLoC, SharedPreferences

#### 3. Food Logging & AI Analysis Modules

This group of modules enables food input through three methods: image scanning, manual text entry, and food database search. All input types are processed through AI-powered nutrition analysis.

##### a. Food Scan AI (`lib/features/food_scan_ai/`)
**Purpose**: Identify and analyze food using AI via camera input.

**Key Components**:
- `FoodScanPage`: Camera interface for food scanning
- `FoodImageAnalysisService`: Image-based food recognition
- `NutritionLabelAnalysisService`: Parses nutrition labels
- Camera controls including flash and mode toggling

##### b. Food Text Input (`lib/features/food_text_input/`)
**Purpose**: Log food intake via manual text input.

**Key Components**:
- `FoodTextInputPage`: UI for text-based food entry
- `FoodTextAnalysisService`: AI-based food description analysis
- `FoodTextInputRepository`: Handles data persistence

##### c. Food Database Input (`lib/features/food_database_input/`)
**Purpose**: Browse and log foods from Pockeat's food database.

**Key Components**:
- `FoodDatabasePage`: Tabbed UI for searching food and building meals
- Search functionality integrated with food dataset
- Meal composition and portion management

#### 4. Exercise Logging Modules

##### Cardio Log (`lib/features/cardio_log/`)
**Purpose**: Track cardiovascular activities.

**Key Components**:
- `CardioInputPage`: Input form for cardio activities
- `CardioRepository`: Data persistence and retrieval
- `CalorieCalculator`: Calorie burn estimation engine
- Supports running, cycling, and swimming

##### Weight Training Log (`lib/features/weight_training_log/`)
**Purpose**: Log strength training and weightlifting sessions.

**Key Components**:
- `WeightliftingPage`: Manages workout sessions
- Exercise selection by muscle group
- Set and repetition tracking
- Workout summary generation

##### Smart Exercise Log (`lib/features/smart_exercise_log/`)
**Purpose**: AI-based detection and logging of workouts.

**Key Components**:
- `SmartExerciseLogPage`: Smart exercise detection interface
- `ExerciseAnalysisService`: AI-based exercise recognition and analysis
- Integration with health metrics for calorie computation

#### 5. Progress Tracking Module (`lib/features/progress_charts_and_graphs/`)
Purpose: Provide visual analytics and track user progress over time.

**Key Components**:
- `ProgressPage`: Main analytics dashboard
- `FoodLogDataService`: Aggregates data for visual graphs
- Tracks weight progression
- Visualizes daily/weekly calorie intake
- Displays BMI trends and calculations

#### 6. Virtual Pet Companion Module (`lib/features/pet_companion/`)
**Purpose**: Gamified motivation system using a virtual pet companion.

**Key Components**:
- `PetService`: Manages pet state and interactions
- Motivation system with reward triggers

#### 7. Home Screen Widget Module (`lib/features/home_screen_widget/`)
**Purpose**: Native integration with device home screen widgets.

**Key Components**:
- `WidgetManagerScreen`: UI for widget setup and configuration
- `SimpleFoodTrackingController`: Basic calorie tracking widget
- `DetailedFoodTrackingController`: Advanced nutritional summary widget
- `WidgetInstallationService`: Handles widget lifecycle and system integration

#### 8. Notification Module (`lib/features/notifications/`)
**Purpose**: Push notifications and user engagement.

**Key Components**:
- `NotificationService`: Handles both local and push notifications
- `UserActivityService`: Triggers notifications based on user behavior
- `NotificationSettingsScreen`: User preferences for notification settings
- Background notification scheduling and logic

### Core Infrastructure

#### Dependency Injection (`lib/core/di/service_locator.dart`)
**Purpose**: Centralized dependency management using the GetIt service locator.

**Key Features**:
- Service registration and resolution

- Support for both singleton and factory patterns

- Modular registration structure for maintainability

- Test environment isolation for easier mocking and unit testing

This setup ensures loose coupling between components, improves scalability, and enhances testability across modules.

#### Background Services (`lib/core/service/`)
**Purpose**: Manage background tasks and integrate with system-level services.

**Key Components**:
- `BackgroundServiceManager`: Orchestrates background task scheduling and execution
- `PermissionService`: Handles runtime device permissions (e.g., location, notifications)
- `AnalyticsService`: Tracks user behavior and app usage patterns
- Widget update service: Triggers background updates for home screen widgets

---

## Development Environment Setup

### Prerequisites
To contribute or run the project locally, ensure the following tools and environments are installed:

#### Frontend - Mobile App (Flutter)
- **Flutter SDK**: Version 3.16.0 or higher
- **Dart SDK**: Version 3.2.0 or higher
- **Android Studio** or **VS Code** with Flutter and Dart extensions
- **Git** for version control and source code management

#### Backend - API Server (FastAPI)
- **Python**: Version 3.12 or higher
- **pip**: Python package manager
- **Virtual Environment**: For managing isolated Python dependencies
- **Docker** (optional): For containerized development and deployment

**Note**: Development is currently focused on Android. iOS support has not been actively developed by the team at this stage.


### Environment Configuration
This section outlines how to configure both the frontend (Flutter) and backend (FastAPI) environments for local development.

#### 1. Flutter Installation
```bash
# Clone the Flutter SDK (macOS/Linux)
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

#### 2. Project Setup

##### Frontend (Flutter) Settings
```bash
# Clone the repository
git clone <repository-url>
cd pockeat-mobile

# Install dependencies
flutter pub get

# Generate necessary code (e.g., freezed, json_serializable)
flutter packages pub run build_runner build --delete-conflicting-outputs
```

##### Backend (FastAPI) Settings
```bash
# Navigate to the backend folder
cd pockeat-api

# Create a virtual environment
python -m venv venv

# Activate the virtual environment
# For Windows
venv\Scripts\activate
# For macOS/Linux
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the development server
python main.py
# or using Uvicorn
uvicorn main:app --reload --host 0.0.0.0 --port 8080
```

#### 3. Environment Files
Both the frontend and backend require environment variable configuration using a `.env` file located in their respective project roots.

##### Frontend `.env` located in `pockeat-mobile/`
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

# iOS Configuration (for future implementation)
STAGING_FIREBASE_IOS_APP_ID="1:123456789:ios:abcdef123456"
STAGING_FIREBASE_IOS_API_KEY="AIzaSyExampleKey123456789"
STAGING_FIREBASE_IOS_BUNDLE_ID="com.example.pockeat"

# macOS Configuration (for future implementation)
STAGING_FIREBASE_MACOS_APP_ID="1:123456789:ios:abcdef123456"
STAGING_FIREBASE_MACOS_API_KEY="AIzaSyExampleKey123456789"
STAGING_FIREBASE_MACOS_BUNDLE_ID="com.example.pockeat"

# Web Configuration (for future implementation)
STAGING_FIREBASE_WEB_APP_ID="1:123456789:web:abcdef123456"
STAGING_FIREBASE_WEB_API_KEY="AIzaSyExampleKey123456789"

# Backend API Configuration
API_BASE_URL="https://your-api-domain.com/api"

# Supabase Configuration (used by API for food dataset)
SUPABASE_URL="https://your-project.supabase.co"
SUPABASE_ANON_KEY="your_supabase_anon_key_here"

# Google Gemini Configuration
GOOGLE_GEMINI_PROJECT_ID="your_project_id"
GOOGLE_GEMINI_API_KEY="your_gemini_api_key_here"
```

##### Backend `.env` located in `pockeat-api/`
```env
# Google Gemini API Configuration
GOOGLE_API_KEY="your_google_gemini_api_key_here"

# Firebase Admin Configuration
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

#### 4. Platform-Specific Configuration

##### Android Setup
To enable full Android functionality and prepare for release builds, follow these steps:
1. Configure signing in `android/app/build.gradle` for release builds (include `signingConfigs` and `buildTypes`).
2. Add Firebase configuration file `google-services.json` to the `android/app/` directory.
3. Set up ProGuard rules to avoid stripping essential classes during release builds (especially for Firebase, Retrofit, or third-party SDKs).

##### iOS Setup (Currently Not Implemented)
**Note**: Although iOS-related files exist in the project structure (as part of Flutter's default project generation), active iOS development has not been carried out by the team. These files have not been configured or tested and are not part of the current deployment target.

### IDE Configuration
To ensure a smooth and consistent development experience, we recommend using **Visual Studio Code (VS Code)** with the following setup:

#### Recommended VS Code Extensions
- Flutter
- Dart
- GitLens
- Flutter Widget Snippets
- Bracket Pair Colorizer

#### Suggested VS Code Settings
Add the following to your project’s or personal VS Code settings (settings.json) to standardize formatting and improve development workflow:
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
**Tip**: Set `"dart.flutterSdkPath"` to the full path of your local Flutter SDK directory.

---

## Configuration Guide

### Firebase Configuration

#### Authentication Setup
To enable user authentication:
1. In the Firebase Console, activate the following sign-in providers:
   - Email/Password
   - Google Sign-In (optional)
2. Configure the authorized domains under the Authentication settings.
3. Set up the password reset email template for user recovery.

#### Firestore Database Setup

##### Firestore Collection Structure

PockEat uses the following Firestore collections to store user data:

**1. `users` Collection**
- **Path**: `/users/{userId}`
- **Purpose**: Stores user profile and authentication data
- **Key Fields**:
  - `uid`: User's unique identifier, generated by Firebase Authentication. Used as the document ID.
  - `email`: Email address used for login and verification.
  - `displayName`: User’s display name, typically filled in during signup or profile editing.
  - `photoURL`: URL to the user's profile photo, can be uploaded via Firebase Storage or a third-party provider.
  - `emailVerified`: Boolean indicating whether the email has been verified through a confirmation link.
  - `createdAt`: Timestamp of account creation, used to track when the user first registered.

**2. `health_metrics` Collection**
- **Path**: `/health_metrics/{userId}`
- **Purpose**: Stores user health metrics
- **Key Fields**:
  - `height`: User's height in centimeters (cm)
  - `weight`: User's weight in kilograms (kg)
  - `age`: User's age in years 
  - `gender`: User's gender identity
  - `activityLevel`: User’s average daily physical activity level (e.g., sedentary, moderate, active)
  - `fitnessGoal`: User’s overall fitness goal (e.g., lose weight, maintain, gain weight)
  - `bmi`: Calculated Body Mass Index (BMI) based on height and weight
  - `bmiCategory`: Category derived from BMI (e.g., underweight, normal, overweight)
  - `desiredWeight`: Target weight the user wants to achieve

**3. `caloric_requirements` Collection**
- **Path**: `/caloric_requirements/{userId}`
- **Purpose**: Stores the user’s calculated daily caloric and macronutrient requirements
- **Key Fields**:
  - `basalMetabolicRate`: User’s basal metabolic rate (BMR), in kilocalories/day
  - `dailyCaloricNeeds`: Total daily energy expenditure (TDEE), in kilocalories/day
  - `proteinNeeds`: Daily protein requirement, in grams (g)
  - `carbNeeds`: Daily carbohydrate requirement, in grams (g)
  - `fatNeeds`: Daily fat requirement, in grams (g)

**4. `calorie_stats` Collection**
- **Path**: `/calorie_stats/{docId}`
- **Purpose**: Tracks daily calorie intake, calories burned, and net calorie balance for each user
- **Key Fields**:
  - `userId`: Unique identifier of the user associated with the log
  - `date`: Date of the calorie log (format: DD-MM-YYYY)
  - `targetCalories`:  Daily calorie target set for the user
  - `consumedCalories`: Total calories consumed on that day
  - `burnedCalories`: Total calories burned through physical activity
  - `netCalories`: Net calorie value (`consumedCalories` - `burnedCalories`)

**5. `food_analysis` Collection**
- **Path**: `/food_analysis/{docId}`
- **Purpose**: Stores results of AI-powered food analysis from images, text input, or database lookup
- **Key Fields**:
  - `foodName`: Name of the analyzed food item
  - `calories`: Total energy content (kcal)
  - `protein`: Protein content in grams (g)
  - `carbohydrates`: Carbohydrate content in grams (g)
  - `fat`: Fat content in grams (g)
  - `sodium`: Sodium content in milligrams (mg)
  - `fiber`: Dietary fiber content in grams (g)
  - `sugar`: Sugar content in grams (g)
  - `timestamp`: Date and time of the analysis
  - `userId`: ID of the user associated with the food entry 

**6. `saved_meals` Collection**
- **Path**: `/saved_meals/{docId}`
- **Purpose**: Stores users’ favorite or frequently consumed meals for easy reuse
- **Key Fields**:
  - `userId`: Unique identifier of the user who saved the meal
  - `name`: Name of the saved meal
  - `foodAnalysis`: Full nutritional breakdown of the meal (calories, macros, etc.)
  - `createdAt`: Timestamp indicating when the meal was saved
  - `updatedAt`: Timestamp of the most recent update to the meal entry

**7. `exerciseAnalysis` Collection**
- **Path**: `/exerciseAnalysis/{docId}`
- **Purpose**: Stores AI-generated exercise analysis based on user-provided text input
- **Key Fields**:
  - `exerciseType`: Type of exercise (e.g., running, cycling)
  - `duration`: Duration of the exercise session (in minutes)
  - `intensity`: Intensity level of the activity (Low, Medium, or High)
  - `estimatedCalories`: Estimated number of calories burned
  - `timestamp`: Date and time when the log was created
  - `originalInput`: Raw text input provided by the user
  - `userId`: Unique identifier of the user who logged the activity

**8. `weight_lifting_logs` Collection**
- **Path**: `/weight_lifting_logs/{docId}`
- **Purpose**: Stores logs of strength training and weightlifting sessions
- **Key Fields**:
  - `name`: Name of the workout or exercise
  - `bodyPart`: Targeted body part or muscle group (e.g., chest, legs)
  - `metValue`: MET (Metabolic Equivalent of Task) value used for calorie calculation
  - `userId`: Unique identifier of the user who performed the workout
  - `sets`: Array of workout sets, each containing:
    - `weight`: Weight lifted in kilograms (kg)
    - `reps`: Number of repetitions performed
    - `duration`: Duration of the set in seconds

**9. Koleksi `cardioActivities`**
- **Path**: `/cardioActivities/{docId}`
- **Purpose**: Stores logs of cardiovascular activities such as running, cycling, or swimming
- **Key Fields**:
  - `activityType`: Type of cardio activity (e.g., running, walking, swimming)
  - `duration`: Duration of the activity in minutes
  - `intensity`: Intensity level of the activity (e.g., low, moderate, high)
  - `caloriesBurned`: Estimated calories burned during the session
  - `date`: Date of the activity (format: DD-MM-YYYY)
  - `userId`: Unique identifier of the user who performed the activity

**10. `weights_history` Subcollection**
- **Path**: `/health_metrics/{userId}/weights_history/{docId}`
- **Purpose**: Stores the historical log of the user's body weight changes over time
- **Key Fields**:
  - `weight`: Recorded body weight in kilograms (kg)
  - `timestamp`: Date and time when the weight was logged

##### Firestore Security Rules
To secure user data, apply the following rules in your Firebase console under Firestore Rules:
```javascript
// Security Rules for Firebase Firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Health metrics and weight history
    match /health_metrics/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /weights_history/{docId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Caloric Requirements
    match /caloric_requirements/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Calorie Stats
    match /calorie_stats/{docId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Food Analysis
    match /food_analysis/{docId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Saved Meals
    match /saved_meals/{docId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Exercise Analysis
    match /exerciseAnalysis/{docId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Weight Lifting Logs
    match /weight_lifting_logs/{docId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Cardio Activities
    match /cardioActivities/{docId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

#### Firebase Cloud Messaging (FCM) Configuration
To enable push notifications within the app:
1. Configure FCM in the Firebase Console for this project.
2. Download the Firebase service account key. This is required for sending notifications from the backend (server-side).
3. Set up notification channels for Android to support grouped notifications and control importance levels.

### Supabase Configuration (Backend-Only)

**Note**: Supabase is used exclusively by the `pockeat-api` backend service to store a structured nutrition dataset. All user-related data in the Flutter app is managed through Firebase Firestore.

#### Database Schema (Nutrition Dataset Only)
The following schema defines the structure of the food and nutrition dataset stored in Supabase:
```sql
-- Table: nutrition_data – complete food dataset with detailed nutritional information
CREATE TABLE nutrition_data (
  id INTEGER PRIMARY KEY,
  food TEXT NOT NULL,
  
  -- Macronutrients
  caloric_value DECIMAL,
  protein DECIMAL,
  carbohydrates DECIMAL,
  fat DECIMAL,
  saturated_fats DECIMAL,
  
  -- Key Nutritional Info
  sodium DECIMAL,
  dietary_fiber DECIMAL,
  sugars DECIMAL,
  cholesterol DECIMAL,
  nutrition_density DECIMAL,
  
  -- Vitamins
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
  
  -- Minerals
  calcium DECIMAL,
  copper DECIMAL,
  iron DECIMAL,
  magnesium DECIMAL,
  manganese DECIMAL,
  phosphorus DECIMAL,
  potassium DECIMAL,
  selenium DECIMAL,
  zinc DECIMAL,
  
  -- Additional Information
  water DECIMAL,
  monounsaturated_fats DECIMAL,
  polyunsaturated_fats DECIMAL,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Indexes for food search optimization
CREATE INDEX idx_nutrition_data_food ON nutrition_data(food);
CREATE INDEX idx_nutrition_data_caloric_value ON nutrition_data(caloric_value);

-- Table: food_synonyms – optional synonyms for alternative search queries
CREATE TABLE food_synonyms (
  id SERIAL PRIMARY KEY,
  food_id INTEGER REFERENCES nutrition_data(id),
  synonym TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
```

### Environment-Specific Configuration
Properly separating development environments helps ensure stability, security, and scalability across your app lifecycle. Below are the key settings and behaviors configured for each environment.

#### Development Environment
- Debug mode is enabled for easier testing and hot reload

- Uses a Firebase staging project with mock/test data

- Verbose logging is enabled for detailed debugging

- External API calls are mocked to isolate test behavior and avoid rate limits

#### Staging Environment
- Configured to mirror production settings closely

- External API access is limited or throttled

- Performance monitoring is enabled for pre-release evaluations

- Only accessible to beta testers or internal QA users

#### Production Environment
- Release builds are optimized using ProGuard or R8

- Uses the official Firebase production project

- Analytics and crash reporting are fully enabled

**Future Plan**: Deployment to App Store and Google Play (not yet implemented)

### Feature Flags
Feature flags are used to toggle app features dynamically for testing, gradual rollout, or beta access:
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

## Run & Testing Instructions
This section outlines how to run and test both the frontend (Flutter) and backend (FastAPI) components of the PockEat project across different environments and use cases.

### Running the Application

#### Frontend - Mobile App (Flutter)

##### Development Mode
```bash
# Run on a connected device or emulator
flutter run

# Run with a specific flavor
flutter run --flavor development -t lib/main.dart

# Run with hot reload enabled (default in debug mode)
flutter run --hot
```

##### Debug vs Release Builds
```bash
# Debug build (default)
flutter run --debug

# Profile build (for performance testing)
flutter run --profile

# Release build
flutter run --release
```

##### Platform-Specific Commands
```bash
# Run on Android (primary development platform)
flutter run -d android

# Run on a specific device
flutter run -d device_id
```

**Note**: iOS commands are excluded as the team has not yet actively developed for iOS.

#### Backend - API Server (FastAPI)

##### Running The Development Server
```bash
# Navigate to the backend directory
cd pockeat-api

# Activate virtual environment
# Windows
venv\Scripts\activate
# macOS/Linux
source venv/bin/activate

# Start the development server with hot reload
python main.py
# Or using Uvicorn directly
uvicorn main:app --reload --host 0.0.0.0 --port 8080

# Run with environment variable
ENVIRONMENT=development python main.py
```

##### Running The Production Server
```bash
# Using Gunicorn for production
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8080

# Using Docker
docker build -t pockeat-api .
docker run -p 8080:8080 pockeat-api
```

##### API Documentation Access
Once the server is running, API documentation can be accessed at:
- Swagger UI: `http://localhost:8080/docs`
- ReDoc: `http://localhost:8080/redoc`
- OpenAPI JSON: `http://localhost:8080/openapi.json`

### Testing Strategy

#### Unit Tests
```bash
# Run all unit tests
flutter test

# Run a specific test file
flutter test test/features/authentication/services/login_service_test.dart

# Run with test coverage
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
```

#### Widget Tests
```bash
# Run all widget tests
flutter test test/features/*/presentation/screens/*_test.dart

# Run with verbose output
flutter test --verbose
```

#### Integration Tests
```bash
# Run integration tests with Flutter Driver
flutter drive --target=test_driver/app.dart
```

### Test Configuration
This section describes the structure of the test directory and the utilities used to facilitate mocking and widget testing across the PockEat project.

#### Test Directory Structure
```
test/
├── features/
│   ├── authentication/
│   │   ├── services/
│   │   │   └── login_service_test.dart # Unit test for login logic
│   │   └── presentation/
│   │       └── screens/
│   │           └── login_page_test.dart # Widget test for login UI
│   ├── health_metrics/ # Tests related to health metrics input
│   └── food_scan_ai/ # Tests for AI-based food scanning
├── core/
│   ├── services/ # Tests for core services (e.g., analytics)
│   └── di/ # Tests for dependency injection
└── test_helpers/
    ├── mock_services.dart # Mock implementations for dependencies
    └── test_utils.dart # Shared utility functions for tests
```

#### Test Helpers & Mock Services
To enable isolated and efficient testing, we use mockito-based mocks for services, and shared utility functions for widget pumping and navigation handling.
```dart
// test_helpers/mock_services.dart
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirestore extends Mock implements FirebaseFirestore {}
class MockUserRepository extends Mock implements UserRepository {}

/// Pumps a widget into the test environment with optional navigation observer
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

### Performance Testing
This section outlines the tools and techniques used to evaluate and optimize the performance of PockEat, including UI rendering, memory usage, and app size.

#### Flutter Performance Tools
Use the following commands to analyze and monitor the performance of PockEat:
```bash
# # Run with performance overlay to visualize rendering stats (e.g., FPS, frame times)
flutter run --enable-software-rendering

# Run in profile mode with startup tracing enabled
flutter run --profile --trace-startup

# Analyze the build size of the APK
flutter build apk --analyze-size
```

#### Memory & CPU Profiling
To inspect runtime performance in more detail:
1. Use Flutter Inspector in Android Studio or VS Code to view widget rebuilds and layout performance.
2. Enable the performance overlay while running in debug mode to monitor rendering performance in real time.
3. Open DevTools (automatically available when running flutter run) for advanced profiling of:
    - Widget rebuilds

    - Frame timings

    - Memory allocations

    - CPU usage
4. Monitor memory leaks and allocation spikes using:
    ``` bash
    flutter pub global activate devtools
    flutter pub global run devtools
    ```
    or directly:
    ``` bash
    flutter memory
    ```


---

## Deployment Guide
This section outlines how to prepare and deploy PockEat specifically for Android. iOS deployment is not yet implemented.

### Build Preparation

#### Version Management
Versioning should follow semantic versioning (`major.minor.patch+build_number`) in `pubspec.yaml`:
```yaml
# pubspec.yaml
# Initial release
version: 1.0.0+1  # version+build_number

# Update example for the next release
version: 1.1.0+2
```

#### Build Optimization
Before building the app, always perform a clean and regenerate required files:
```bash
# Clean previous build artifacts
flutter clean

# Fetch dependencies
flutter pub get

# Generate necessary files
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Android Deployment

#### Release Builds
```bash
# Build a release APK
flutter build apk --release

# Build an Android App Bundle (AAB) for future Play Store submission
flutter build appbundle --release

# Build APKs split by ABI (smaller APK sizes)
flutter build apk --release --split-per-abi
```

#### Signing Configuration
Make sure your signing credentials are properly configured in `android/app/build.gradle`:
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

#### Play Store Deployment (Planned)
**Status**: Not yet implemented. The app has not been published to the Google Play Store.

**Planned deployment steps**:
1. Generate a signed App Bundle (`.aab`)

2. Upload to Google Play Console

3. Configure store listing (app name, screenshots, description)

4. Set up release tracks (internal, alpha, beta, production)

5. Enable Google Play App Signing

### iOS Deployment (Not Yet Implemented)

**Status**: iOS development has not been actively pursued by the team.
While the Flutter project structure includes iOS configuration files, they have not been configured, tested, or prepared for deployment.

### CI/CD Pipeline
This section outlines the automated testing and deployment workflow using GitHub Actions and Firebase App Distribution. It ensures consistency, test reliability, and smooth delivery across development, staging, and production environments.

#### GitHub Actions Workflow
```yaml
# File: .github/workflows/ci.yml
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

#### Setup Instructions
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase (if not already done)
firebase init hosting

# Manually distribute APK to testers
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:123456789:android:abcd1234 \
  --groups "testers"
```

### Environment Deployment Strategy

#### Branching Model
- `main`: Production release branch
- `develop`: Active staging environment
- `feature/*`: Feature-specific development branches

#### Environment Deployment Flow
1. **Development**: 
- Auto-deployed from the `develop` branch

- Used for internal testing and rapid iteration
2. **Staging**: 
- Weekly releases for QA validation

- Triggered from `develop` after manual or scheduled merge
3. **Production**: 
- Bi-weekly releases post-staging approval

- Deployed from `main` after successful QA validation

---

## Project Limitations & Future Development

### Current Limitations

#### Technical Constraints
1. **Offline Capability**: Most features require an internet connection; offline support is limited.
2. **Platform Support**: Android is the primary target platform; iOS is not yet implemented.
3. **Camera Performance**: Food scanning may be slightly unreliable in low-light conditions.
4. **Database Synchronization**: Potential conflicts between Firebase and Supabase during sync operations
5. **Widget Platform Support**: Homescreen widget support is limited to Android 8+; iOS support is not available.

#### Functional Limitations
1. **AI Accuracy**: Food recognition accuracy depends on image quality and dataset coverage.
2. **Exercise Library**: More limited than dedicated fitness apps in terms of available activities.
3. **Social Media Sharing Features**: Basic social media sharing functionality; no advanced community features yet.
4. **Internationalization**: Currently supports English only.
5. **Accessibility**: Limited support for users with disabilities.

#### Performance Constraints
1. **Memory Usage**: Processing large food images may cause memory issues on older devices.
2. **Battery Consumption**: Background services may impact battery life.
3. **Network Dependency**: Strong reliance on active internet connection.
4. **Storage Constraints**: Limited local caching for offline use.

### Future Development Roadmap

#### Phase 1: Core Enhancements (Q3–Q4 2025)
**Priority Level: High**

1. **Offline Capabilities**
   - Local database caching
   - Offline food logging with sync support
   - Basic functionality without internet access

2. **Performance Optimization**
   - Image compression for scanning
   - Background service optimization
   - Improved memory management

3. **UI/UX Improvements**
   - Dark mode support
   - Accessibility enhancements
   - Streamlined onboarding experience

#### Phase 2: Feature Expansion (Q1–Q2 2026)
**Priority Level: Medium**

1. **Advanced Analytics**
   - ML (Machine Learning)-powered health insights
   - Predictive wellness analysis
   - Custom health report generation

2. **Enhanced Social Features**
   - Friend connections for users
   - Challenge & reward system
   - Community food recipe sharing

3. **Integration Ecosystem**
   - Integration with Apple Health and Google Fit
   - Fitness tracker sync
   - Third-party diet app integrations

#### Phase 3: Platform Expansion (Q3–Q4 2026)
**Priority Level: Medium**

1. **Web Application**
   - Progressive Web App (PWA)
   - Companion desktop dashboard
   - Admin analytics panel

2. **Wearable Device Support**
   - Apple Watch integration
   - Android Wear support
   - Smart fitness tracker compatibility

#### Phase 4: Advanced Capabilities (Q1–Q2 2027)
**Priority Level: Low**

1. **AI & Machine Learning**
   - Personalized food recommendations
   - Predictive health insights
   - Enhanced food recognition capabilities

2. **Healthcare Integration**
   - Healthcare provider portals
   - User medical records data syncing
   - Telehealth support features

3. **Enterprise Features**
   - Corporate wellness program tools
   - Bulk user management
   - Advanced analytics for organizational health

### Technology Upgrade Path

#### Flutter Framework
- **Current**: Flutter 3.16.x
- **Target**: Flutter 4.x (once stable)
- **Benefits**: Performance gains, new widgets, improved web support

#### State Management Evolution
- **Current**: BLoC + Provider
- **Future Consideration**: Migration to Riverpod
- **Benefits**: Improved testability, reduced boilerplate, better performance

#### Backend Architecture
- **Current**: Hybrid Firebase + Supabase
- **Future Plan**: Microservices architecture
- **Benefits**: Greater scalability, service isolation, tech stack flexibility

#### Database Strategy
- **Current**: Firestore (for user data) + PostgreSQL via Supabase (for nutrition data)
- **Future Plan**: Multi-database strategy with caching layers
- **Benefits**: Improved performance, data redundancy, cost optimization

### Scalability Considerations

#### User Growth Projections
- **Year 1**: 10.000 active users (projected)
- **Year 2**: 100.000 active users (projected)
- **Year 3**: 1.000.000 active users (projected)

#### Infrastructure Scaling Plan
1. **Database Scaling**: 
    - Sharding and horizontal scaling

    - Read replicas for high-throughput reads
2. **API SCaling**: Microservices architecture with auto-scaling deployment
3. **Content Delivery**: CDN integration for faster image and asset delivery worldwide
4. **Caching Strategy**: Implement Redis for frequently accessed data

#### Cost Optimization Strategies
1. **Firestore Usage**: 
    - Optimize query patterns and indexing

    - Efficient storage structuring
2. **Supabase Scaling**: 
    - Enable connection pooling

    - Query optimization and view indexing
3. **Cloud Functions**: Optimize execution time and memory usage
4. **Storage Optimization**: 
    - Image compression

    - CDN integration for static asset delivery

---

## Appendix

### Deployment Scripts

#### Android Release Script
```bash
#!/bin/bash
# scripts/deploy_android.sh

set -e

echo "🚀 Starting Android Release Build..."

# Clean previous builds
flutter clean
flutter pub get

# Generate necessary files
flutter packages pub run build_runner build --delete-conflicting-outputs

# Build APK
echo "📱 Building APK..."
flutter build apk --release

# Build App Bundle
echo "📦 Building App Bundle..."
flutter build appbundle --release

# Upload to Firebase App Distribution
echo "🔥 Uploading ke Firebase App Distribution..."
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app "$FIREBASE_ANDROID_APP_ID" \
  --groups "internal-testers" \
  --release-notes "Release build $(date)"

echo "✅ Android deployment complete!"
```

#### iOS Release Script (Planned for Future Implementation)
```bash
#!/bin/bash
# scripts/deploy_ios.sh (not implemented yet)

set -e

echo "🚀 Memulai iOS Release Build..."

# Note: This script is a placeholder for future iOS support

flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter build ios --release --no-codesign

echo "✅ iOS deployment is not yet available."
```

### Configuration Templates

#### Firebase Configuration Templates 
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

#### Environment Configuration Templates
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

### Testing Configuration

#### Test Environment Setup
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
    // Add additional mock services as needed
  }
  
  static void tearDown() {
    GetIt.instance.reset();
  }
}

// Widget test helper
Widget createTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
    navigatorKey: GlobalKey<NavigatorState>(),
  );
}
```

### Monitoring & Analytics

#### Analytics Events Definition
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
  
  // Exercise logging events
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

### API Documentation Example

#### Food Analysis Endpoint
```dart
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

### Troubleshooting Guide

#### Common Issues

1. **Build Failures**
   ```bash
   # Clear Flutter cache
   flutter clean
   flutter pub get
   
   # Clear iOS build cache (For future iOS support)
   cd ios && rm -rf build/ && cd ..
   
   # Clear Android build cache (Android-specific cleanup)
   cd android && ./gradlew clean && cd ..
   ```

2. **Firebase Connection Issues**
   - Ensure `google-services.json` is correctly placed
   - Check Firebase project settings
   - Verify SHA-1 fingerprint configuration

3. **Widget Testing Errors**
   ```dart
   // Common test setup
   testWidgets('should render correctly', (tester) async {
     await tester.pumpWidget(createTestWidget(MyWidget()));
     await tester.pumpAndSettle(); // Wait for animations
     
     expect(find.text('Expected Text'), findsOneWidget);
   });
   ```

4. **Performance Issues**
    - Use `flutter run --profile` for profiling

    - Enable performance overlay with `flutter run --enable-software-rendering`

    - Use DevTools to monitor memory usage

### Security Considerations

#### Data Protection
1. **Encryption**: All sensitive data is encrypted both at rest and in transit
2. **Authentication**: Supports multi-factor authentication (MFA)
3. **API Security**: Rate limiting and request validation
4. **Privacy Compliance**: GDPR and CCPA aligned

#### Code Security
1. **Secret Management**: Uses environment variables for sensitive data
2. **Code Obfuscation**: Enabled via ProGuard for Android builds
3. **Certificate Pinning**: Ensures secure SSL/TLS connections
4. **Dependency Scanning**: Regular vulnerability scans

---

*This documentation is actively maintained and updated. For the latest details, please refer to the project repository and internal documentation system.*

* **Last Updated**: June 2025
* **Version**: 1.0.1  
* **Maintainers**: PockEat Development Team
