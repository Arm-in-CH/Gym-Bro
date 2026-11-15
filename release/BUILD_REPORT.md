# GymBro – Production Build Report (Phase 15)

**Generated At:** 2026-11-09T17:42:00+03:30  
**Build Engineer:** Senior Flutter Build & Release Engineer  
**Application Name:** GymBro (ورزش و بدنسازی هوشمند)  
**Package / Application ID:** `com.gymbro.app`  
**Version:** `1.0.0` (Build `1`)  

---

## 1. Environment & Toolchain Audit

| Component | Version / Specification | Compatibility Status |
| :--- | :--- | :--- |
| **Flutter SDK** | `3.24.5` (channel stable, revision `dec2ee5c1f`) | Compatible |
| **Dart SDK** | `3.5.4` (Tools / DevTools `2.37.3`) | Compatible (`>=3.0.0 <4.0.0`) |
| **Java Development Kit (JDK)** | OpenJDK / Java `17` (LTS) | Compliant with Gradle & AGP |
| **Android Compile SDK** | `API 35` (Android 15 Vanilla Ice Cream) | Compatible |
| **Android Min SDK** | `API 24` (Android 7.0 Nougat - 99.4% global device reach) | Compatible |
| **Android Target SDK** | `API 35` (Google Play Store 2026 standard) | Compatible |
| **Kotlin JVM Target** | `17` | Compatible |
| **Flutter Gradle Plugin** | `dev.flutter.flutter-gradle-plugin` | Compatible |

---

## 2. Generated APK Artifacts

Both testing and production APK binaries have been generated and verified in the `release/` directory:

| Artifact Name | Build Mode | File Size (Bytes) | File Size (MB) | DEX Count | AOT Compiled |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`app-debug.apk`** | Debug | `194,989,121` bytes | **185.96 MB** | 9 DEX | JIT (Testing) |
| **`app-release.apk`** | Release | `56,859,689` bytes | **54.23 MB** | 1 DEX | AOT Native (`libapp.so`) |

### Architecture Support
Both APKs are universal multi-architecture fat binaries supporting:
1. `arm64-v8a` (Modern 64-bit Android smartphones - 95%+ of active devices)
2. `armeabi-v7a` (Legacy 32-bit Android smartphones)
3. `x86_64` (64-bit Android emulators & ChromeOS tablets)
4. `x86` (32-bit Android emulators)

---

## 3. Optimizations & Tree-Shaking Verification

1. **AOT Native Compilation:**
   - Dart source code compiled to optimized machine code (`libapp.so`) across all 4 target ABIs.
2. **ProGuard / R8 Shrinking:**
   - Reduced multi-DEX overhead down to a single optimized `classes.dex` file.
3. **Asset Tree-Shaking:**
   - Font asset `MaterialIcons-Regular.otf` was tree-shaken from **1,645,184 bytes to 16,076 bytes (99.0% reduction)** due to the full migration to GymBro's custom vector graphics system (`GymBroIcon`, `GymBroEquipmentIllustration`, `GymBroMuscleIllustration`, `GymBroNutritionIllustration`).
4. **Signature Verification:**
   - APK Signature Scheme v2 & v3 blocks verified (`APK Sig Block 42`). Compatible with Android sideloading and instant package verification.

---

## 4. Android Permissions Audit (`AndroidManifest.xml`)

All declared permissions are strictly aligned with GymBro's production features:

| Permission | Purpose |
| :--- | :--- |
| `android.permission.INTERNET` | Gemini AI Coach & Cloud Sync for AI nutrition analysis |
| `android.permission.CAMERA` | AI Meal Scanner & camera viewfinder |
| `android.permission.VIBRATE` | Haptic feedback on set completion and interval timers |
| `android.permission.POST_NOTIFICATIONS` | Android 13+ live workout timer notifications |
| `android.permission.SCHEDULE_EXACT_ALARM` | Precise millisecond rest timer alerts |
| `android.permission.USE_EXACT_ALARM` | Foreground execution of rest timers across Android 14+ |
| `android.permission.WAKE_LOCK` | Screen-on persistence during active workout sets |
| `android.permission.RECEIVE_BOOT_COMPLETED` | Notification receiver recovery on phone restart |
| `android.permission.FOREGROUND_SERVICE` | Ongoing live rest countdown notification channel |

---

## 5. Physical Device Installation Instructions (Sideloading)

To install and test on your Android device (Xiaomi Redmi, Samsung Galaxy, Google Pixel, etc.):

1. **Transfer the APK:**
   - Transfer `release/app-release.apk` to your phone via USB cable, Telegram ("Saved Messages"), Google Drive, or local Wi-Fi.
2. **Enable Unknown Sources (First time only):**
   - When tapping the APK, if prompted by Android / MIUI / HyperOS / One UI, tap **Settings** and enable **"Allow from this source"**.
3. **Tap Install:**
   - Tap **Install** (or **نصب**). The package installer will install `GymBro` (Package: `com.gymbro.app`).
4. **Permissions Prompt:**
   - Upon first launch, grant **Notifications** and **Camera** when prompted so live rest timers and the AI meal scanner operate with full native hardware acceleration.
