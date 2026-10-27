# Smart Student Companion — Flutter Android Application

A complete, modern, beginner-friendly Android companion application built with **Flutter 3.x**, **Dart (Null Safety)**, and **Material 3 Design** for university students.

---

## 📁 Project Architecture & File Hierarchy

```
smart_student_companion/
│
├── pubspec.yaml                  # Project metadata, dependencies (shared_preferences, sqflite, intl)
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml   # Android permissions and MainActivity configuration
│
├── lib/
│   ├── main.dart                 # App entry point, WidgetsFlutterBinding, MaterialApp
│   │
│   ├── models/                   # Strongly-typed Dart Object-Oriented Models
│   │   ├── student.dart          # Encapsulated student profile with getters/setters & validation
│   │   ├── course.dart           # University course model with credit system & schedules
│   │   ├── attendance_record.dart# Attendance calculations, percentage formulas, & shortage warnings
│   │   ├── assignment.dart       # Assignment deadlines, status enum (Pending, Submitted, Overdue)
│   │   ├── note.dart             # Notes model with CRUD serialization & timestamps
│   │   ├── university_event.dart # Event model demonstrating OOP inheritance & polymorphism
│   │   └── app_notification.dart # Campus alert notifications model with categorization
│   │
│   ├── services/                 # Business logic and persistent data services
│   │   ├── storage_service.dart  # Singleton async service for SharedPreferences & JSON storage
│   │   └── mock_data_service.dart# Initial university sample dataset
│   │
│   ├── utils/                    # Styling, theming, and constants
│   │   ├── app_theme.dart        # Academic Blue & White Material 3 ThemeData
│   │   └── constants.dart        # Global keys and constants
│   │
│   ├── widgets/                  # Reusable Flutter Widgets
│   │   ├── stat_card.dart        # Rounded statistic tile with icons & elevation
│   │   ├── attendance_indicator.dart # Threshold-reactive progress bar (<75% warning)
│   │   └── empty_state.dart      # Clean visual placeholder for empty lists and search
│   │
│   └── screens/                  # Application screens
│       ├── splash_screen.dart    # Animated university logo screen with auto-routing
│       ├── main_navigation_screen.dart # 5-Tab Material 3 BottomNavigationBar container
│       ├── home_dashboard_screen.dart  # Welcome banner, metrics grid, classes & quick actions
│       ├── attendance_screen.dart# Subject attendance list, +/- buttons, <75% advice
│       ├── course_registration_screen.dart # Registered vs Available tabs, add/drop
│       ├── notes_screen.dart     # Searchable notes list with delete confirmation
│       ├── note_editor_screen.dart # Note creation and editing form with validation
│       ├── assignments_screen.dart # Pending, Submitted, and Overdue tabs with submit toggles
│       ├── notifications_screen.dart # Campus alerts with unread dots & mark all read
│       ├── events_screen.dart    # Category-filtered events with bookmarking
│       └── profile_screen.dart   # Student profile with modal edit dialog & form validation
```

---

## 🎯 Dart Concepts Demonstrated in Code

| Concept | File / Implementation | Explanation |
| :--- | :--- | :--- |
| **Encapsulation & Private Fields** | `lib/models/student.dart` | `_name`, `_email` fields with validation in setters |
| **Default, Named, Factory Constructors** | `lib/models/student.dart`, `note.dart` | `Student.initial()`, `Note.fresh()`, `Student.fromMap()` |
| **Inheritance & Polymorphism** | `lib/models/university_event.dart` | `UniversityEvent` extends `BaseCalendarItem`, overrides `@override String get summary` |
| **Enums & Switch Statements** | `lib/models/assignment.dart`, `app_notification.dart` | `AssignmentStatus` (`pending`, `submitted`, `overdue`) with `switch(status)` |
| **Arithmetic & Logical Operators** | `lib/models/attendance_record.dart` | `(attended / total) * 100.0`, `percentage < 75.0` |
| **Async / Await & Future** | `lib/services/storage_service.dart` | `Future<void> init() async`, `await SharedPreferences.getInstance()` |
| **Singleton Pattern** | `lib/services/storage_service.dart` | Private constructor `StorageService._internal()`, single `_instance` |
| **Stateful vs Stateless Widgets** | `lib/widgets/stat_card.dart` vs `screens/*.dart` | Reusable presentation widgets vs dynamic stateful screens with `setState()` |
| **Null Safety** | Throughout entire project | Non-nullable types with `?` where nullable (`DateTime? submittedAt`) |

---

## 🚀 How to Run in Android Studio & Terminal

### Prerequisites
1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.19 or later).
2. Install [Android Studio](https://developer.android.com/studio) with:
   - Android SDK
   - Android SDK Command-line Tools
   - Flutter and Dart plugins (Settings > Plugins > Search "Flutter")

### Step 1: Open the Project
1. Launch Android Studio.
2. Select **Open** and choose the `smart_student_companion` folder.
3. Wait for Android Studio to sync the Dart Analysis Server.

### Step 2: Install Dependencies
Open the built-in terminal at the bottom of Android Studio (or your system terminal in the project directory) and run:
```bash
flutter pub get
```

### Step 3: Launch an Android Virtual Device (Emulator)
1. In Android Studio, go to **Tools** > **Device Manager** (or click the Phone icon in the top toolbar).
2. Click **Create Device**.
3. Choose **Pixel 7** or **Pixel 8** and click **Next**.
4. Select a system image (e.g., **UpsideDownCake** / API 34 or **Tiramisu** / API 33) and click **Download** if not downloaded.
5. Click **Finish**.
6. Click the green **Play (▶)** button next to the created emulator to start it.

### Step 4: Run the Application
Once the emulator has booted up:
In terminal:
```bash
flutter run
```
Or simply click the green **Run (▶)** button in the top toolbar of Android Studio.

The app will compile and install on the Android emulator!

---

## 🛠️ Troubleshooting Guide

1. **`Target of URI doesn't exist: 'package:shared_preferences/shared_preferences.dart'`**:
   - Solution: Run `flutter pub get` in terminal, or in Android Studio click "Pub get" in the top bar of `pubspec.yaml`.

2. **Gradle build daemon fails or Java version mismatch**:
   - Ensure Android Studio is using JDK 17 (File > Settings > Build, Execution, Deployment > Build Tools > Gradle > Gradle JDK).

3. **Android license status unknown**:
   - Run: `flutter doctor --android-licenses` and accept the prompts with `y`.

4. **Emulator shows black screen or crashes on launch**:
   - Open Device Manager > Click the 3 dots on the emulator > **Cold Boot Now**.
