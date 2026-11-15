---
title: Calorie Scanning and Nutrition
type: feature
area: project
status: decided
tags: [gymbro, product, ai, nutrition]
updated: 2026-11-04
---

# Calorie Scanning and Nutrition

## Flow
1. User photographs a meal or selects a food photo.
2. The **Cabbage Mascot Loader (`CabbageMascotLoader`)** engages with a 60fps chewing animation, eating floating dumbbells and protein shakers.
3. Photo goes to the vision model via **Google AI Studio Gemini 1.5 Flash Vision** (encoded as compact inline base64, consuming ~260 tokens per scan) or [[AI Architecture|OpenRouter]].
4. AI extracts structured JSON containing:
   - `food_name_fa` and English name
   - Estimated calories (`kcal`)
   - Macronutrient breakdown: protein (`g`), carbs (`g`), fat (`g`)
   - Serving portion (`g`) and nutritional confidence score
5. User reviews the estimated values and can adjust any field before confirming.
6. The meal log is deducted from the daily calorie budget and macro bars.
7. Over-limit alerts notify the user if daily limits are exceeded.

## Verified Baseline Diet (Armin Chinipardaz)
Extracted directly from `rejim/رژیم غذایی-533.pdf` as the reference active profile:
- **Daily Calorie Target**: 2,250 kcal
- **Protein**: 160 g (7.0 g per kg of LBM)
- **Carbohydrates**: 220 g
- **Fat**: 55 g
- **Hydration**: 3,500 ml (~8 large glasses; supported by the 1-tap +250ml water logger)
- **Core Supplements**: Whey isolate post-workout, Creatine monohydrate (5g), Milk Protein Concentrate (MPC casein) before sleep, daily multivitamin.

## Access and pricing
- Free tier: capped daily scans; Pro tier: higher daily cap; extra scans can be bought as coins
- Coins earned from workout completions (e.g. +5 coins per finished session) can be redeemed for scans.
- See [[Monetization Model]] for current figures

## Nutrition plans (trainer side)
- Trainer selects meals from a shared food database, sets timing, specifies supplements and amounts, adds notes
- `nutrition_plans`: daily_calories, protein_g, carbs_g, fat_g, start/end date

## Future
- Snappfood integration: order the trainer-prescribed meal directly, or tick it off an existing menu to deduct calories (non-Pro users) — see [[Ideas Parking Lot]]

## Related
[[Feature Map]] · [[AI Architecture]] · [[Monetization Model]] · [[ML Lead - Food Model (Cousin)]] · [[Database Overview]] · [[Current Build Status]]
