# DingDong - Development Setup Guide

## Prerequisites

### Required Software
1. **Flutter SDK** (Latest stable version)
   - Download from: https://docs.flutter.dev/get-started/install
   - Minimum version: Flutter 3.16.0+
   - Add Flutter to PATH

2. **Dart SDK** (comes with Flutter)
   - Minimum version: Dart 3.2.0+

3. **IDE** (choose one)
   - VS Code with Flutter extension
   - Android Studio with Flutter plugin
   - IntelliJ IDEA with Flutter plugin

4. **Platform-Specific Tools**

   **For iOS development:**
   - Xcode 15.0+ (macOS only)
   - CocoaPods (`sudo gem install cocoapods`)
   - iOS Simulator or physical iOS device

   **For Android development:**
   - Android Studio
   - Android SDK (API level 23+)
   - Android Emulator or physical Android device
   - Java JDK 11+

   **For Web development:**
   - Chrome browser

   **For Desktop development:**
   - macOS: Xcode Command Line Tools
   - Windows: Visual Studio 2022 with C++ desktop development tools
   - Linux: Build essentials, GTK, etc.

5. **Git**
   - Git 2.0+

6. **Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

7. **FlutterFire CLI**
   ```bash
   dart pub global activate flutterfire_cli
   ```

---

## Initial Setup Steps

### Step 1: Verify Flutter Installation

```bash
flutter doctor -v
```

Ensure all checkmarks are green. Fix any issues reported.

### Step 2: Create Flutter Project

```bash
# Navigate to the DingDong directory
cd /path/to/DingDong

# Create Flutter project
flutter create --org com.dingdong --project-name dingdong .

# Or if the directory already has content:
flutter create --org com.dingdong --project-name dingdong --platforms=ios,android,web,macos,windows,linux .
```

### Step 3: Enable All Platforms

```bash
# Enable web
flutter config --enable-web

# Enable macOS desktop
flutter config --enable-macos-desktop

# Enable Windows desktop
flutter config --enable-windows-desktop

# Enable Linux desktop
flutter config --enable-linux-desktop
```

### Step 4: Set Up Firebase

1. **Create Firebase Project**
   - Go to https://console.firebase.google.com/
   - Create new project named "DingDong"
   - Enable Google Analytics (optional)

2. **Add Apps to Firebase Project**
   - Add iOS app (com.dingdong.app)
   - Add Android app (com.dingdong.app)
   - Add Web app

3. **Configure Firebase for Flutter**
   ```bash
   # Login to Firebase
   firebase login

   # Configure FlutterFire
   flutterfire configure
   ```

4. **Enable Firebase Services**
   In Firebase Console, enable:
   - Authentication (Email/Password, Google, Apple, Microsoft)
   - Cloud Firestore
   - Cloud Storage
   - Cloud Functions
   - Firebase Hosting
   - Crashlytics
   - Analytics

### Step 5: Install Dependencies

The `pubspec.yaml` file has been pre-configured with all required dependencies.

```bash
# Get all dependencies
flutter pub get
```

### Step 6: Project Structure Setup

The project follows Clean Architecture with this structure:

```
lib/
├── core/                 # Core utilities, constants, errors
│   ├── constants/       # App constants, strings, etc.
│   ├── errors/          # Error classes and exceptions
│   ├── network/         # Network utilities
│   ├── theme/           # Theme data
│   ├── utils/           # Utility functions
│   └── widgets/         # Reusable widgets
├── data/                # Data layer
│   ├── datasources/     # Local & remote data sources
│   ├── models/          # Data models (serialization)
│   └── repositories/    # Repository implementations
├── domain/              # Business logic layer
│   ├── entities/        # Business entities
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business use cases
├── presentation/        # Presentation layer
│   ├── providers/       # Riverpod providers (state management)
│   ├── screens/         # Screen widgets
│   ├── widgets/         # Screen-specific widgets
│   └── routes/          # Navigation routes
├── config/              # App configuration
│   ├── routes/          # Route configuration
│   └── theme/           # Theme configuration
└── main.dart            # App entry point
```

### Step 7: Code Generation Setup

For build_runner (JSON serialization, code generation):

```bash
# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Or watch for changes (development)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Step 8: Configure Platform-Specific Settings

**iOS (ios/Runner/Info.plist):**
```xml
<!-- Camera permission -->
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan notes and create tasks from images</string>

<!-- Photo library permission -->
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to import images and create tasks</string>

<!-- Location permission -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need location access for location-based reminders</string>

<!-- Microphone permission (for voice input) -->
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access for voice task creation</string>

<!-- Notification permission -->
<key>NSUserNotificationAlertStyle</key>
<string>alert</string>
```

**Android (android/app/src/main/AndroidManifest.xml):**
```xml
<!-- Camera permission -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- Storage permission -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!-- Location permission -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Notification permission (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- Internet permission -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Microphone permission -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

### Step 9: Run the App

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Run in debug mode
flutter run

# Run in profile mode (performance testing)
flutter run --profile

# Run in release mode
flutter run --release

# Run on web
flutter run -d chrome

# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android
```

### Step 10: Testing Setup

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# View coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
start coverage/html/index.html  # Windows
```

---

## Development Workflow

### 1. Before Starting Development

```bash
# Pull latest changes
git pull origin develop

# Create feature branch
git checkout -b feature/your-feature-name

# Install/update dependencies
flutter pub get

# Run code generation if needed
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. During Development

```bash
# Hot reload (press 'r' in terminal)
# Hot restart (press 'R' in terminal)
# Open DevTools (press 'o' in terminal)

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Run linter
dart analyze
```

### 3. Before Committing

```bash
# Run tests
flutter test

# Check code formatting
flutter format --set-exit-if-changed lib/

# Run analyzer
flutter analyze

# If all pass, commit
git add .
git commit -m "feat(scope): your commit message"
```

### 4. Building for Production

**iOS:**
```bash
# Build iOS app
flutter build ios --release

# Build IPA for distribution
flutter build ipa --release
```

**Android:**
```bash
# Build APK
flutter build apk --release

# Build App Bundle (preferred for Play Store)
flutter build appbundle --release
```

**Web:**
```bash
# Build web app
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

**Desktop:**
```bash
# macOS
flutter build macos --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release
```

---

## Environment Configuration

### Development Environment

Create `.env.development` file:
```env
API_BASE_URL=https://dev-api.dingdong.com
FIREBASE_PROJECT_ID=dingdong-dev
GOOGLE_VISION_API_KEY=your-dev-api-key
OPENAI_API_KEY=your-dev-api-key
SENTRY_DSN=your-dev-sentry-dsn
```

### Production Environment

Create `.env.production` file:
```env
API_BASE_URL=https://api.dingdong.com
FIREBASE_PROJECT_ID=dingdong-prod
GOOGLE_VISION_API_KEY=your-prod-api-key
OPENAI_API_KEY=your-prod-api-key
SENTRY_DSN=your-prod-sentry-dsn
```

**Note:** Never commit `.env` files to Git. Add to `.gitignore`.

---

## Troubleshooting

### Common Issues

**1. "Flutter command not found"**
```bash
# Add Flutter to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$PATH:/path/to/flutter/bin"
source ~/.bashrc  # or source ~/.zshrc
```

**2. "CocoaPods not found" (iOS)**
```bash
sudo gem install cocoapods
pod setup
```

**3. "Android licenses not accepted"**
```bash
flutter doctor --android-licenses
```

**4. "Gradle build failed" (Android)**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**5. "Build runner conflicts"**
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

**6. "Firestore permission denied"**
- Check Firebase security rules
- Ensure user is authenticated
- Verify Firestore indexes are created

---

## Useful Commands

```bash
# Clean build files
flutter clean

# Update dependencies
flutter pub upgrade

# Outdated dependencies
flutter pub outdated

# Create new screen/widget
flutter create --template=package my_package

# Analyze dependencies
flutter pub deps

# Check for unused dependencies
dart pub global activate dependency_validator
dependency_validator

# Performance profiling
flutter run --profile
# Then open DevTools: flutter pub global run devtools

# Generate icons
flutter pub run flutter_launcher_icons:main

# Generate splash screen
flutter pub run flutter_native_splash:create
```

---

## IDE Configuration

### VS Code

Install extensions:
- Flutter
- Dart
- Dart Data Class Generator
- Flutter Intl
- GitLens
- Error Lens
- Better Comments

**settings.json:**
```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "dart.lineLength": 100,
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true
}
```

### Android Studio

Install plugins:
- Flutter
- Dart
- Rainbow Brackets
- Key Promoter X

---

## Next Steps

1. Follow SOP.md for development process
2. Refer to WBS.md for feature implementation order
3. Check REQUIREMENTS.md for detailed specifications
4. Start with Phase 1: Foundation (WBS Section 1.0)

---

**Ready to build something amazing! 🚀**
