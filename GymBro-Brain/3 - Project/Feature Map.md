---
title: Feature Map
type: concept
area: project
status: decided
tags: [gymbro, product, features]
updated: 2026-09-28
---

# Feature Map

Grouped by domain. "Now" = MVP scope (backed by the 14 core [[Database Overview|tables]]); "Later" = Phase 2/3+, see [[Roadmap and Phases]] and [[Ideas Parking Lot]].

## Now (MVP - Fully Implemented in Flutter Client)
- Trainer discovery + booking → [[Trainer Marketplace and Booking]]
- Gym discovery (GPS) + membership payment → [[Gym Discovery and Gym Owners]]
- Digital workout plans with a shared, admin-moderated exercise library (video demos)
- **In-workout live set/rep/weight logging ("رفتن به تمرین")** with pyramid progression, actuals tracking, and manual rest chronograph
- **Brzycki 1RM Calculator**: instant 1-rep max calculation with 95%, 85%, 75%, 65% target training zones
- **AI Calorie & Meal Scanner**: image recognition via Google Gemini 1.5 Flash Vision (low-token inline base64) with macro breakdown and manual overrides → [[Calorie Scanning and Nutrition]]
- **Cabbage Mascot Gamification (`CabbageMascotLoader`)**: cute animated gym cabbage eating dumbbells into pure protein during analysis and loading
- **Smart Hydration Tracker**: daily water target (3,500ml) with single-tap +250ml logging
- Nutrition plans linked to the calorie scanner, with over-limit alerts and Armin Chinipardaz's verified diet budget (2,250 kcal)
- Home-workout fallback with 1-tap conversion when the user can't reach the gym → [[Home Workout Mode]]
- Status system: member → athlete → pro → elite → [[Levels Ranking and Elite Status]]
- Reviews/ratings for trainers and gyms
- Coin purchases + Pro subscription → [[Monetization Model]]
- Offline-first resilience: local state persistence via `SharedPreferences`

## Later (Phase 2/3)
- CRM/leads for the sales team → [[CRM and Sales Pipeline]]
- Ranking/rewards system, competitive leaderboards against friends
- **SportBro**: same marketplace model extended to other sports (e.g. renting a futsal pitch for a time slot, finding a coach/team, matches)
- Trainer competitions with prizes; temporary zero-commission reward for top performers
- Snappfood API integration matched to a user's diet plan
- Diet-focused food sections, supplement ordering, sports-equipment store
- Vending machines with diet-compliant meals in high-office/student-density Tehran areas

## Not currently modeled (gaps, not decisions)
- Broader trust & safety: medical disclaimers, unsafe-advice handling, abuse moderation beyond a `is_visible` flag on reviews

## Related
[[Project Hub]] · [[Product Vision]] · [[Roadmap and Phases]] · [[Ideas Parking Lot]] · [[Open Questions]] · [[Current Build Status]]
