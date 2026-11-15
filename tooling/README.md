# GymBro Device Features Testing Lab

This directory contains standalone, pure HTML/CSS/JavaScript simulators developed to test and visualize GymBro's device-specific native integrations:

1. **`tooling/device_features_lab.html`** (Combined Master Testing Laboratory)
2. **`tooling/foldable_preview.html`** (Foldable Posture & Secret Easter Egg Prototype)
3. **`tooling/android_live_timer_preview.html`** (Android Live Notification & Dynamic Island Prototype)

> [!NOTE]
> These HTML simulators are strictly for visual inspection, UX testing, and QA demonstrations. The real production implementations are coded natively in Flutter Dart and Android Kotlin.

---

## 1. How to Run the Testing Lab

### Method 1: Direct File Opening

Double-click or open any of the HTML files directly in your web browser:

- `tooling/device_features_lab.html`
- `tooling/foldable_preview.html`
- `tooling/android_live_timer_preview.html`

### Method 2: Local HTTP Server (PowerShell / Python / Node)

From the GymBro root folder:

**Using Python:**

```bash
python -m http.server 8080
```

Then navigate to: `http://localhost:8080/tooling/device_features_lab.html`

**Using Node.js (npx serve):**

```bash
npx serve .
```

---

## 2. Features Included in `device_features_lab.html`

### A. Xiaomi HyperOS & Android 14 Ongoing Notification Simulator

- **Focus Notification / Dynamic Capsule (HyperIsland)**:
  - Renders in the status bar around the camera cutout.
  - Interactive: Click to expand into rich workout controls.
  - Shows animated pulse indicator and ticking countdown timer.
- **Android Ongoing Notification Shade**:
  - Simulates notification channel `gymbro_live_timer_channel` (Importance.low, category `CATEGORY_WORKOUT`, ID: 772).
  - Interactive action buttons: **Pause**, **Resume**, **+15s**, **+30s**, and **Reset/Dismiss**.
- **Real Audible Sound**:
  - Synthesizes exact alarm beeps when the timer expires via the Web Audio API without requiring external audio assets.

### B. Foldable Phone & Posture Simulator

- **3D Interactive Device Frame**:
  - Realistic 3D perspective folding along a central metallic hinge crease.
  - Device presets:
    - **Samsung Galaxy Z Fold 6** (Book fold: 340px cover vs 580px dual-pane inner).
    - **Samsung Galaxy Z Fold 8** (manual CSS viewport calibration; defaults are placeholders, not published device measurements).
    - **Google Pixel Fold** (Wide book fold: 360px cover vs 660px inner).
    - **Samsung Galaxy Z Flip 6** (Clamshell: 320px outer vs 700px vertical inner).
    - **Samsung Galaxy Tab S9** (Demonstrates tablet exclusion: non-foldable devices will **never** trigger the Easter Egg!).
- **Posture Controls**:
  - **Cover (Folded - 0°)**: Outer screen active.
  - **Flex / Tabletop (90°)**: Upper preview pane & lower workout controls.
  - **Flat (Unfolded - 180°)**: Full inner display with dual-pane layout.
  - **Hinge Angle Slider**: Continuous 0° to 180° real-time manipulation.

### C. Secret Easter Egg Verification (Scenarios A through E)

The simulator includes one-click scenario triggers:

- **Scenario A**: App opened while already unfolded -> Triggers Easter Egg once inner screen stabilizes.
- **Scenario B**: App opened while folded on cover screen -> Suppressed; awaits unfold.
- **Scenario C**: App opened folded, then unfolded -> Detects posture transition and fires Easter Egg.
- **Scenario D**: Device folded and reopened in the same session -> Session deduplication prevents repeat popups.
- **Scenario E**: Workout active toggle -> Confirms active exercises and timers are never interrupted.
- **Easter Egg Modal**:
  - Persian Title: _"اوه، ببین کی داره پُز می‌ده بابا!"_
  - Subtitle: _"حالا برو تمرینتو بکن."_
  - HTML5 Canvas particle confetti physics.
  - Auto-dismiss countdown bar (6s) and manual dismiss button.

The HTML device labs validate browser-side layout and interaction logic only. Their PASS status does not establish physical hinge-sensor, OEM, or Android behavior. Z Fold 8 viewport dimensions must be measured on the device and entered in the manual calibration fields.

---

## 3. Architecture & Code References

- **Native Android Integration**:
  - Kotlin MethodChannel: [`android/app/src/main/kotlin/com/gymbro/app/MainActivity.kt`](file:///c:/Users/Armin/Desktop/GymBro/android/app/src/main/kotlin/com/gymbro/app/MainActivity.kt)
  - Manifest & Permissions: [`android/app/src/main/AndroidManifest.xml`](file:///c:/Users/Armin/Desktop/GymBro/android/app/src/main/AndroidManifest.xml)
- **Flutter Services**:
  - Foldable Posture Service: [`lib/core/services/foldable_device_service.dart`](file:///c:/Users/Armin/Desktop/GymBro/lib/core/services/foldable_device_service.dart)
  - Live Timer Notification Service: [`lib/core/services/android_live_timer_notification_service.dart`](file:///c:/Users/Armin/Desktop/GymBro/lib/core/services/android_live_timer_notification_service.dart)
  - Master Countdown Service: [`lib/core/services/workout_timer_service.dart`](file:///c:/Users/Armin/Desktop/GymBro/lib/core/services/workout_timer_service.dart)
- **Widgets**:
  - Easter Egg Overlay: [`lib/widgets/foldable_easter_egg.dart`](file:///c:/Users/Armin/Desktop/GymBro/lib/widgets/foldable_easter_egg.dart)
  - Adaptive Dual-Pane Layout: [`lib/widgets/foldable_adaptive_layout.dart`](file:///c:/Users/Armin/Desktop/GymBro/lib/widgets/foldable_adaptive_layout.dart)
- **Tests**:
  - Foldable Test Suite: [`test/foldable_phase9_test.dart`](file:///c:/Users/Armin/Desktop/GymBro/test/foldable_phase9_test.dart)
  - Live Timer Test Suite: [`test/android_live_timer_phase8_test.dart`](file:///c:/Users/Armin/Desktop/GymBro/test/android_live_timer_phase8_test.dart)
