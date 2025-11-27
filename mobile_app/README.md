# mobile_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Mobile App (Flutter)

This directory contains the Flutter mobile application for the e-Fine SL Traffic Management System.

## Project Structure
```
mobile_app/
├── analysis_options.yaml
├── android/
│   ├── app/
│   │   └── src/
│   │       ├── debug/
│   │       ├── main/
│   │       └── profile/
│   ├── build.gradle.kts
│   ├── gradle/
│   ├── gradle.properties
│   ├── gradlew
│   ├── gradlew.bat
│   ├── local.properties
│   ├── mobile_app_android.iml
│   └── settings.gradle.kts
├── assets/
│   └── icons/
│       └── app_icon/
│           └── app_logo.png
├── ios/
│   ├── Flutter/
│   ├── Runner/
│   │   ├── Assets.xcassets/
│   │   └── Base.lproj/
│   ├── Runner.xcodeproj/
│   ├── Runner.xcworkspace/
│   └── RunnerTests/
├── lib/
│   ├── config/
│   │   ├── constants.dart
│   │   └── theme.dart
│   ├── main.dart
│   ├── models/
│   ├── providers/
│   ├── screens/
│   │   ├── auth/
│   │   │   └── login_screen.dart
│   │   ├── driver/
│   │   │   └── driver_home_screen.dart
│   │   ├── police/
│   │   │   └── police_home_screen.dart
│   │   └── splash/
│   │       └── splash_screen.dart
│   ├── services/
│   └── widgets/
│       ├── custom_button.dart
│       └── custom_textfield.dart
├── linux/
├── macos/
├── pubspec.lock
├── pubspec.yaml
├── test/
│   └── widget_test.dart
├── web/
│   ├── favicon.png
│   ├── icons/
│   │   ├── Icon-192.png
│   │   ├── Icon-512.png
│   │   ├── Icon-maskable-192.png
│   │   └── Icon-maskable-512.png
│   ├── index.html
│   └── manifest.json
├── windows/
└── README.md
```

## Current Stage
- Material 3 design implemented.
- Main screen and counter demo working.
- App successfully builds and runs on Android (V2419) and other platforms.
- Launcher icons configured.
- Project structure updated for better organization (see `lib/config/constants.dart`).
- Recent commits include configuration improvements and code cleanup.

## How to Run
1. Connect your Android device and enable USB debugging.
2. Run `flutter devices` to verify device connection.
3. Run `flutter run` to launch the app.

## Next Steps
- Add authentication and user profile screens.
- Integrate with backend API for real data.
- Implement additional features (fine management, notifications, etc.).
- Continue improving code structure and configuration.

---
