# Shrex - Focus App 🔥

A production-ready Flutter Android app that locks your phone for productive focus sessions, tracks streaks & analytics, provides rewards/animations, and optionally syncs to Firebase leaderboard.

## Features ✨

### Core Functionality
- **Device Locking**: Native Kotlin integration to lock device during focus sessions
- **Offline-First**: SQLite database for session history and streak tracking
- **Ambient Audio**: Background audio during focus sessions
- **Notifications**: Daily reminders and session completion notifications
- **Firebase Sync**: Optional cloud synchronization and leaderboard

### UI/UX
- **Material 3 Design**: Modern gradients and glassmorphism effects
- **Confetti Animations**: Celebration effects for completed sessions
- **Progress Visualization**: Beautiful progress rings and countdown timers
- **Responsive Layout**: Optimized for Android devices

### Gamification
- **Streak Tracking**: Daily streak milestones and rewards
- **Achievement Badges**: Unlock badges for various milestones
- **Leaderboard**: Compete with other users (Firebase optional)
- **Level System**: Progress through levels based on streaks and sessions

## Project Structure 📁

```
shrex/
├── android/                    # Android native code
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── kotlin/com/example/shrex/
│   │   │   │   ├── MainActivity.kt      # Platform channel implementation
│   │   │   │   └── BootReceiver.kt     # Boot receiver for notifications
│   │   │   └── AndroidManifest.xml      # Permissions and services
│   │   ├── build.gradle                 # App-level build configuration
│   │   └── google-services.json         # Firebase configuration
│   └── build.gradle                     # Project-level build configuration
├── lib/                        # Flutter Dart code
│   ├── main.dart               # App entry point
│   ├── app.dart                # Main app widget
│   ├── screens/                # UI screens
│   │   ├── home_screen.dart
│   │   ├── lock_screen.dart
│   │   ├── rewards_screen.dart
│   │   ├── analytics_screen.dart
│   │   ├── leaderboard_screen.dart
│   │   └── settings_screen.dart
│   ├── services/               # Core services
│   │   ├── app_services.dart
│   │   ├── platform_service.dart
│   │   ├── timer_service.dart
│   │   ├── db_service.dart
│   │   ├── audio_service.dart
│   │   ├── notification_service.dart
│   │   └── firebase_service.dart
│   ├── models/                # Data models
│   │   ├── session_model.dart
│   │   └── user_model.dart
│   ├── widgets/                # Custom widgets
│   │   ├── progress_ring.dart
│   │   ├── gradient_button.dart
│   │   ├── confetti_widget.dart
│   │   └── leaderboard_tile.dart
│   └── utils/                  # Utilities
│       ├── constants.dart
│       └── theme.dart
├── assets/                     # App assets
│   ├── audio/                  # Audio files
│   │   ├── ambient.mp3        # Background audio
│   │   └── victory.mp3        # Victory sound
│   └── animations/             # Lottie animations
│       └── confetti.json
└── pubspec.yaml               # Dependencies and configuration
```

## Prerequisites 🛠️

### Required Software
- **Flutter SDK**: Latest stable version (3.10.0+)
- **Android Studio**: Latest version with Android SDK
- **Android Device**: Physical device with USB debugging enabled
- **Java/Kotlin**: Android development environment

### Android Requirements
- **API Level**: 21+ (Android 5.0+)
- **Permissions**: Overlay, Notification, System Alert Window
- **Developer Options**: USB debugging enabled

## Installation & Setup 🚀

### 1. Clone and Setup
```bash
# Clone the repository
git clone <repository-url>
cd shrex

# Get Flutter dependencies
flutter pub get

# Verify Flutter installation
flutter doctor
```

### 2. Android Configuration
```bash
# Connect Android device via USB
# Enable Developer Options and USB Debugging

# Verify device connection
flutter devices
```

### 3. Firebase Setup (Optional)
1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add Android app with package name: `com.example.shrex`
3. Download `google-services.json` and replace the placeholder file
4. Enable Authentication and Firestore in Firebase Console

### 4. Audio Assets
Replace placeholder audio files in `assets/audio/`:
- `ambient.mp3`: 10+ minute ambient audio (nature sounds, white noise, etc.)
- `victory.mp3`: 2-5 second victory sound effect

## Running the App ▶️

### Development Mode
```bash
# Run on connected device
flutter run

# Run in debug mode with hot reload
flutter run --debug

# Run in release mode
flutter run --release
```

### Build APK
```bash
# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```

## Usage Guide 📱

### First Launch
1. **Grant Permissions**: Allow overlay and notification permissions when prompted
2. **Choose Duration**: Select your preferred focus session duration (5-60 minutes)
3. **Start Session**: Tap "Start Focus Session" to begin

### During Focus Session
- **Device Locked**: Phone is locked to prevent distractions
- **Ambient Audio**: Background audio plays continuously
- **Progress Tracking**: Visual countdown and progress ring
- **Emergency Unlock**: Long-press back button for emergency unlock

### After Session
- **Celebration**: Confetti animation and victory sound
- **Streak Update**: Automatic streak calculation and milestone checks
- **Statistics**: Session data saved to local database
- **Notifications**: Completion notification with streak info

### Settings & Customization
- **Audio Volume**: Adjust ambient audio volume
- **Daily Reminders**: Set custom reminder times
- **Firebase Sync**: Enable/disable cloud synchronization
- **Data Export**: Export session data for backup

## Permissions Explained 🔐

### Required Permissions
- **SYSTEM_ALERT_WINDOW**: Required for device locking functionality
- **WAKE_LOCK**: Keeps screen on during focus sessions
- **FOREGROUND_SERVICE**: Maintains lock service in background
- **POST_NOTIFICATIONS**: Sends daily reminders and completion notifications
- **RECEIVE_BOOT_COMPLETED**: Restarts notifications after device reboot

### Permission Flow
1. App requests permissions on first launch
2. User grants permissions through Android system dialogs
3. If denied, app shows in-app instructions for manual permission granting
4. Settings screen provides permission status and re-request options

## Testing Checklist ✅

### Core Functionality
- [ ] App launches without crashes
- [ ] Permissions are requested and granted
- [ ] Focus session starts and locks device
- [ ] Ambient audio plays during session
- [ ] Timer counts down correctly
- [ ] Session completes automatically
- [ ] Device unlocks when session ends
- [ ] Confetti animation plays on completion
- [ ] Session data is saved to database
- [ ] Streak is calculated correctly

### UI/UX Testing
- [ ] All screens navigate correctly
- [ ] Progress ring updates smoothly
- [ ] Settings can be modified and saved
- [ ] Notifications appear at scheduled times
- [ ] Dark/light theme switching works
- [ ] Responsive design on different screen sizes

### Firebase Integration (Optional)
- [ ] Google Sign-In works
- [ ] User data syncs to Firestore
- [ ] Leaderboard displays correctly
- [ ] Data persists across app restarts

### Edge Cases
- [ ] App handles missing audio files gracefully
- [ ] Emergency unlock works correctly
- [ ] App recovers from background/foreground transitions
- [ ] Database handles concurrent access
- [ ] Notifications work after device restart

## Troubleshooting 🔧

### Common Issues

#### App Won't Start
```bash
# Check Flutter installation
flutter doctor

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### Device Locking Not Working
1. Check if overlay permission is granted
2. Verify device supports screen pinning
3. Check Android logs: `adb logcat | grep Shrex`

#### Audio Not Playing
1. Replace placeholder audio files with actual MP3 files
2. Check audio permissions
3. Verify file paths in `assets/audio/`

#### Firebase Issues
1. Verify `google-services.json` is correctly placed
2. Check Firebase project configuration
3. Ensure Authentication and Firestore are enabled

#### Build Errors
```bash
# Clean build cache
flutter clean
cd android && ./gradlew clean && cd ..

# Update dependencies
flutter pub upgrade

# Rebuild
flutter run
```

### Debug Mode
```bash
# Enable debug logging
flutter run --debug

# View Android logs
adb logcat | grep -E "(Shrex|Flutter)"
```

## Architecture Overview 🏗️

### State Management
- **Riverpod**: Reactive state management
- **Hooks**: Custom hooks for component logic
- **ChangeNotifier**: Timer service state management

### Data Layer
- **SQLite**: Local session storage with `sqflite`
- **SharedPreferences**: User settings and preferences
- **Firestore**: Optional cloud synchronization

### Platform Integration
- **Method Channels**: Flutter ↔ Kotlin communication
- **Foreground Service**: Maintains device lock
- **Native Audio**: Platform-specific audio handling

### UI Architecture
- **Material 3**: Modern design system
- **Custom Widgets**: Reusable UI components
- **Responsive Design**: Adaptive layouts

## Contributing 🤝

### Development Setup
1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Make changes and test thoroughly
4. Commit changes: `git commit -m 'Add amazing feature'`
5. Push to branch: `git push origin feature/amazing-feature`
6. Open Pull Request

### Code Style
- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Write unit tests for core functionality

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support 💬

For support, feature requests, or bug reports:
1. Check existing issues in the repository
2. Create a new issue with detailed description
3. Include device information and error logs
4. Provide steps to reproduce the issue

## Roadmap 🗺️

### Planned Features
- [ ] iOS support
- [ ] Widget support for quick access
- [ ] Advanced analytics with charts
- [ ] Custom focus themes
- [ ] Social features and challenges
- [ ] Integration with calendar apps
- [ ] Pomodoro technique support
- [ ] Focus music recommendations

---

**Built with ❤️ using Flutter and Kotlin**

*Focus better, achieve more! 🎯*
