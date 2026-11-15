# 07 — ENVIRONMENT SETUP, RUNTIME & MIGRATION GUIDE

> **Audience:** Developers, DevOps engineers, and Autonomous AI Agents.  
> **Purpose:** Provide complete technical details on the runtime environment, SDK configurations, dependencies, platform runners, and step-by-step instructions for changing environments (database, AI providers, platforms, styling, and localization).

---

## 1. Current Host & SDK Specifications

| Component | Specification / Location | Notes |
| :--- | :--- | :--- |
| **Operating System** | Windows 10/11 x64 (PowerShell Core / Windows PowerShell) | Path separator `\`, UTF-8 |
| **Flutter SDK** | `E:\dev\flutter\bin\flutter.bat` (Channel `stable`) | Can be run via absolute path or system `flutter` |
| **Dart SDK** | Embedded inside Flutter SDK (`>=3.0.0 <4.0.0`) | Null safety enforced |
| **App Architecture** | Clean UI Layer + Pure State/Service Model | Minimal external dependencies |
| **Workspace Root** | `c:\Users\Armin\Desktop\GymBro` | Source code in `lib/`, tests in `test/` |

---

## 2. Project Dependencies (`pubspec.yaml`)

GymBro intentionally maintains a lean dependency tree to avoid framework lock-in:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  shared_preferences: ^2.2.2    # Local persistence (key-value JSON)
  intl: ^0.19.0                 # Date/time formatting and LTR/RTL helpers

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0         # Static analysis and style guide rules
```

> [!NOTE]
> No heavy architecture frameworks (no Riverpod, Bloc, MobX) are used. State is managed reactively via `AppState` inheriting from Flutter's native `ChangeNotifier`.

---

## 3. How to Run, Test, and Build

### 3.1 Static Analysis (0 Warnings Guarantee)
```powershell
E:\dev\flutter\bin\flutter.bat analyze
# Expected output: "No issues found!"
```

### 3.2 Automated Test Suite (100% Pass)
```powershell
E:\dev\flutter\bin\flutter.bat test
# Runs all 227+ unit and widget tests
```

To run a specific test group:
```powershell
E:\dev\flutter\bin\flutter.bat test test/fitness_calculator_test.dart
E:\dev\flutter\bin\flutter.bat test test/app_state_persistence_test.dart
```

### 3.3 Running the Application
Check available devices:
```powershell
E:\dev\flutter\bin\flutter.bat devices
```

- **Run in Chrome (Web):**
  ```powershell
  E:\dev\flutter\bin\flutter.bat run -d chrome
  ```
- **Run on Windows Desktop:**
  ```powershell
  E:\dev\flutter\bin\flutter.bat run -d windows
  ```
- **Run on Connected Android Device or Emulator:**
  ```powershell
  E:\dev\flutter\bin\flutter.bat run -d <device_id>
  ```

### 3.4 Production Builds
- **Android APK:**
  ```powershell
  E:\dev\flutter\bin\flutter.bat build apk --release
  # Output: build/app/outputs/flutter-apk/app-release.apk
  ```
- **Android App Bundle (Play Store):**
  ```powershell
  E:\dev\flutter\bin\flutter.bat build appbundle --release
  ```
- **Web App:**
  ```powershell
  E:\dev\flutter\bin\flutter.bat build web --release
  ```

---

## 4. How to Change & Migrate Environments

### 4.1 Changing the Storage Backend (Mock/SharedPreferences -> Remote DB/Supabase/Firebase)

Currently, persistence is handled in `lib/services/local_storage_service.dart`. It persists state slices using JSON strings stored in `SharedPreferences`.

#### To migrate to Supabase or Firebase:
1. **Define a clean Storage/Repository Interface:**
   Create `lib/core/contracts/storage_contract.dart`:
   ```dart
   abstract class IStorageService {
     Future<void> init();
     Future<void> saveWorkoutLogs(List<WorkoutSession> sessions);
     Future<List<WorkoutSession>> loadWorkoutLogs();
     Future<void> saveHydration(int amountMl);
     Future<int> loadHydration();
     // ...
   }
   ```
2. **Implement the Remote Repository:**
   e.g., `lib/services/supabase_storage_service.dart` implementing `IStorageService`.
3. **Inject into `AppState`:**
   In `lib/state/app_state.dart`, inject `IStorageService` into the constructor instead of the concrete `LocalStorageService`:
   ```dart
   class AppState extends ChangeNotifier {
     final IStorageService storage;
     AppState({required this.storage});
     // ...
   }
   ```
4. **Initialize in `main.dart`:**
   Swap `LocalStorageService` with `SupabaseStorageService`. UI screens remain completely unchanged!

---

### 4.2 Changing AI Engine & API Providers

External AI endpoints (Gemini, OpenRouter, Claude) are decoupled from the UI.
- In `AppState`:
  - `geminiApiKey`: Stored and updated via `setGeminiApiKey(String key)`.
  - `openRouterApiKey`: Stored and updated via `setOpenRouterApiKey(String key)`.
  - `aiMode`: `AiCoachMode.demo` vs `AiCoachMode.live`.

#### To change the AI Provider (e.g., to OpenAI, Local Ollama, or a Custom Backend):
1. **Never hardcode secrets** in client code.
2. Direct client calls to an intermediary proxy server or cloud function rather than client-direct API calls when deploying to production.
3. Update `lib/screens/ai_coach_screen.dart` and `AppState.sendCoachMessage()`:
   - Configure the base URL (e.g., `http://localhost:11434/api/generate` for local Ollama, or your custom API gateway).
   - Use `AppState.aiMode` to ensure the app cleanly falls back to offline simulated coaching when no network or keys are present without crashing.

---

### 4.3 Switching Theme Tokens & Visual Modes

GymBro uses an atomic design system located in `lib/theme/`:
- `app_colors.dart`: Primary neon green (`#B8FF00`), obsidian dark backgrounds (`#0F1115`), high-contrast surface greys.
- `app_typography.dart`: Persian Vazirmatn typography scale (`h1`, `h2`, `body`, `label`).
- `app_tokens.dart`: Radius tokens (`r8`, `r12`, `r16`, `r24`) and spacing units (`space4` to `space48`).

#### To re-skin or customize branding:
- Modify `AppColors.brandPrimary` in `lib/theme/app_colors.dart`.
- The entire application dynamically references these tokens. No hardcoded hex codes exist in the primary screen widgets!

---

### 4.4 Switching Locale & Directionality (RTL / LTR)

- GymBro is architected with first-class **RTL (Persian)** support while maintaining full **LTR (English)** compatibility.
- In `lib/main.dart`:
  ```dart
  MaterialApp(
    locale: appState.locale, // Locale('fa') or Locale('en')
    supportedLocales: const [Locale('fa'), Locale('en')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    // ...
  )
  ```
- To toggle locale programmatically:
  ```dart
  appState.setLocale(const Locale('en')); // or Locale('fa')
  ```
- All directional icons (arrows, chevrons) must respect RTL via `Directionality.of(context)` or `.autoDirectional`.

---

### 4.5 Testing in CI/CD Environments (GitHub Actions / GitLab CI)

Below is the standard headless verification pipeline script:

```yaml
name: GymBro CI

on: [push, pull_request]

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          cache: true
      - name: Install Dependencies
        run: flutter pub get
      - name: Code Quality & Lints
        run: flutter analyze --fatal-infos
      - name: Run All Tests
        run: flutter test --coverage
```

---

## 5. Summary of Architecture Guarantees

1. **Deterministic State:** No side-effects inside build methods.
2. **Decoupled Math:** Pure calculations reside in `lib/core/algorithms/fitness_calculator.dart` without Flutter dependencies.
3. **Resilient Offline Mode:** Complete app functionality works without internet or API keys.
4. **Zero-Warning Codebase:** Always keep `flutter analyze` at 0 issues.
