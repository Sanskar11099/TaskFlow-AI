# TaskFlow AI

A premium AI-powered task manager built with Flutter and Firebase — featuring a glassmorphic dark UI, Pomodoro focus sessions, analytics, and an AI productivity assistant.

---

## Features

- **Task Management** — Create, edit, and delete tasks with priority levels (low / medium / high / urgent), due dates, tags, and completion tracking
- **Home Dashboard** — Productivity score, daily motivational quote, quick-action shortcuts, and task statistics (streak, focus hours, completion %)
- **Pomodoro Focus Mode** — 25-minute work sessions with 5-minute breaks, ambient sound selection (Deep Space, Rain Forest, White Noise, Ocean Waves), and session tracking
- **Calendar View** — Visual task scheduling with week/month overview and per-day task filtering
- **AI Assistant** — Chat interface for productivity suggestions, task prioritization, and study planning (mock integration, ready for real LLM API)
- **Analytics Dashboard** — Weekly completion charts, task stats, and 30-day trends powered by `fl_chart`
- **Search** — Full-text search across task titles, descriptions, and tags
- **Notifications** — Task reminder and notification center
- **User Profile** — Display name, avatar, join date, focus hours, and streak tracking
- **Settings** — Light/dark theme toggle and app preferences
- **Authentication** — Firebase Auth with email/password sign-up, login, and password reset

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter (Dart SDK ^3.10.8) |
| State Management | Riverpod 2.6.1 |
| Navigation | GoRouter 14.6.2 |
| Backend / Auth | Firebase Auth + Cloud Firestore |
| Error Tracking | Firebase Crashlytics |
| Charts | fl_chart 0.70.2 |
| Calendar | table_calendar 3.1.3 |
| Animations | flutter_animate 4.5.2 |
| Fonts | Google Fonts (Poppins + Inter, bundled offline) |
| External API | Quotable.io (daily motivational quotes) |
| Design | Material 3 + Glassmorphism |

---

## Project Structure

```
lib/
├── models/
│   ├── task_model.dart           # Task entity (id, title, priority, status, dueDate, tags)
│   ├── quote_model.dart          # Motivational quote
│   └── user_profile_model.dart   # User profile with streak & focus tracking
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── forgot_password_screen.dart
│   ├── home_screen.dart          # Main dashboard
│   ├── task_detail_screen.dart
│   ├── edit_task_screen.dart
│   ├── task_creation_sheet.dart
│   ├── calendar_screen.dart
│   ├── focus_screen.dart         # Pomodoro timer
│   ├── ai_assistant_screen.dart
│   ├── analytics_screen.dart
│   ├── search_screen.dart
│   ├── notifications_screen.dart
│   ├── profile_screen.dart
│   └── settings_screen.dart
├── services/
│   ├── auth_service.dart         # Firebase Auth wrapper
│   ├── task_service.dart         # Firestore CRUD for tasks
│   ├── user_profile_service.dart
│   └── quote_service.dart        # Quotable.io API
├── widgets/
│   ├── task_card.dart
│   ├── glass_card.dart           # Glassmorphism container
│   ├── bottom_nav.dart
│   ├── ai_orb.dart               # Animated AI avatar
│   ├── priority_chip.dart
│   ├── skeleton_loader.dart
│   └── animated_checkbox.dart
├── app_router.dart               # GoRouter — 18 named routes
├── app_theme.dart                # Material 3 light & dark themes
├── app_colors.dart               # Centralized color palette
└── main.dart                     # Entry point (Firebase init, ProviderScope)
```

---

## Architecture

- **Services** — Handle all Firebase/API I/O (`auth_service`, `task_service`, `user_profile_service`, `quote_service`)
- **Providers** — Riverpod `StateNotifierProvider` and `StreamProvider` expose reactive state to the UI; tasks stream directly from Firestore
- **Screens** — Pure UI, consume providers via `ConsumerWidget` / `ConsumerStatefulWidget`
- **Models** — Immutable Dart classes with `copyWith()`, `toMap()`, and Firestore deserialization

**Firestore schema:**
```
users/{userId}/
  ├── (UserProfile fields)
  └── tasks/{taskId}   ← TaskModel documents
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.10
- [Firebase CLI](https://firebase.google.com/docs/cli) — `npm install -g firebase-tools`
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli) — `dart pub global activate flutterfire_cli`
- Android Studio / Xcode for device emulators

### Clone & Install

```bash
git clone https://github.com/Sanskar11099/TaskFlow-AI.git
cd TaskFlow-AI
flutter pub get
```

---

## Firebase Setup

1. Go to the [Firebase Console](https://console.firebase.google.com) and create a new project.

2. Enable **Email/Password** authentication:
   Firebase Console → Authentication → Sign-in method → Email/Password → Enable

3. Create a **Firestore** database:
   Firebase Console → Firestore Database → Create database → Start in production mode

4. Run FlutterFire to regenerate `firebase_options.dart` for your project:
   ```bash
   flutterfire configure
   ```

5. Deploy Firestore security rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

---

## Running the App

```bash
# Run on a connected device or emulator
flutter run

# Build release APK (Android)
flutter build apk --release

# Build for web
flutter build web
```

---

## License

MIT
