# GymBro – Remaining Issues & Backlog Roadmap (Post-Phase 24)

**Document Version:** 1.0.0  
**Date:** November 9, 2026  
**Status:** All P0 (Blockers) and P1 (Critical) Bugs Resolved (0 Open P0/P1).

This document details the categorized non-blocking items, polish enhancements (P2/P3), and technical debt intentionally deferred for future roadmap iterations.

---

## 1. Issue Severity Classification Summary

| Severity | Description | Count | Current Status |
| :--- | :--- | :---: | :---: |
| **P0 – Blocker** | Crashes, data corruption, layout freeze, broken builds | **0** | **All Resolved** |
| **P1 – Critical** | Overflow on supported screens, broken navigation, missing core features | **0** | **All Resolved** |
| **P2 – Minor Polish** | UI edge-case refinements, animation smoothing, accessibility enhancements | **3** | Backlog / Post-Launch |
| **P3 – Enhancement** | Cloud synchronization, hardware integrations, advanced analytics | **4** | Roadmap Features |

---

## 2. P2 Issues (Minor Polish & Edge-Case Optimizations)

### Issue P2-01: Custom Canvas Chart Semantic Traversal
- **Component:** `BodyProgressChart`, `MacroRatioDonutChart`
- **Severity:** P2 (Accessibility Polish)
- **Description:** While all interactive buttons and text satisfy TalkBack / Screen Reader semantic trees, custom `CustomPainter` vector charts currently announce general summary strings rather than allowing node-by-node exploration of individual data points.
- **Impact:** Visually impaired users using screen readers hear the overall average and trend rather than tapping each individual monthly dot.
- **Recommended Solution:** Wrap chart touch areas in a `Semantics(container: true)` widget with children using `CustomPainterSemantics` to expose individual data point milestones to the accessibility engine.

### Issue P2-02: Hero Shared Element Transitions
- **Component:** `WorkoutPlansScreen` -> `ActiveWorkoutScreen`
- **Severity:** P2 (Visual Delight)
- **Description:** Transition between workout plan cards and the active workout session is currently an animated slide-fade route transition rather than a shared-element hero expansion.
- **Impact:** Minor aesthetic opportunity; does not affect usability or performance.
- **Recommended Solution:** Add `Hero` widgets tagged with `plan.id` on the plan header badge and thumbnail.

### Issue P2-03: Tablet Master-Detail Dual Pane View
- **Component:** `MainNavigationScreen` on tablet / wide foldable landscape (> 900dp width)
- **Severity:** P2 (Responsive Enhancement)
- **Description:** On wide desktop or tablet screens, the layout maintains a centered max-width container (600dp) with black letterboxing rather than switching to a split-screen master-detail layout (e.g., list on left, detail on right).
- **Impact:** Application functions cleanly and responsively without overflow, but does not exploit excess horizontal space on 11-inch tablets.
- **Recommended Solution:** Implement a `LayoutBuilder` breakpoint at `maxWidth > 800` to render a two-pane layout for workout selection and active tracking.

---

## 3. P3 Enhancements (Roadmap & Hardware Capabilities)

### Enhancement P3-01: Native Camera Barcode & AI Food Vision
- **Category:** Hardware Integration
- **Current State:** Meal scanning relies on high-fidelity offline simulated scanning with rich mock food datasets and manual macro adjustments.
- **Proposed Enhancement:** Integrate `camera` and `google_mlkit_barcode_scanning` packages with a cloud-backed nutrition vision API (Open Food Facts / Nutritionix) to scan real grocery product barcodes directly.

### Enhancement P3-02: Cloud Sync & Multi-Device Backup
- **Category:** Cloud Architecture
- **Current State:** 100% offline-first architecture via `LocalStorageService` (SharedPreferences JSON, schema v4). Fast, private, and requires zero internet connection.
- **Proposed Enhancement:** Implement Firebase Auth / Supabase sync allowing users to seamlessly transition between Android phone, tablet, and smart watch.

### Enhancement P3-03: WearOS Companion App & BLE Heart Rate Monitor
- **Category:** Wearables & Sensors
- **Current State:** Heart rate and calories are calculated based on user METs, duration, and RPE formulas.
- **Proposed Enhancement:** Bluetooth Low Energy (BLE) integration for chest straps (Polar H10, Garmin HRM) and a standalone Wear OS rest-timer companion tile.

### Enhancement P3-04: True 3D glTF Mesh Rendering for Anatomy
- **Category:** Graphics & Rendering
- **Current State:** High-performance, lightweight 2D procedural vector canvas wireframe (`HumanBodySvgViewer`) with glowing muscle group overlays.
- **Proposed Enhancement:** Embed `flutter_3d_controller` or Filament engine for interactive 360-degree rotation of 3D anatomical human models with skeletal muscle depth mapping.

---

## 4. Verification & Sign-off

All remaining items are documented, classified, and confirmed non-blocking for version 1.0.0. The application meets all release standards with zero unhandled exceptions.
