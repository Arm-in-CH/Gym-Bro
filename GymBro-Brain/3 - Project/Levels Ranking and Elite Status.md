---
title: Levels Ranking and Elite Status
type: feature
area: project
status: decided
tags: [gymbro, product, gamification]
updated: 2026-09-28
---

# Levels, Ranking, and Elite Status

## The four levels
`member → athlete → pro → elite` — stored as `users.level`, separate from `users.subscription_type` (free/pro billing flag). These are two different axes; see [[Known Inconsistencies]] #6 for the naming overlap between `level = pro` and `subscription_type = pro`.

| Level | Condition |
|-------|-----------|
| member | signup |
| athlete | 3 months active |
| pro | monthly subscription |
| elite | 6+ months active **and** trainer approval |

The exact free-scan perk tied to "athlete" is inconsistent across earlier discussions — treat `level` primarily as a **status/social-proof mechanic**, not a scan-count lever. See [[Known Inconsistencies]] #2.

## Elite — earned, not bought
Originally discussed as a paid tier (990,000 Toman), deliberately changed to an **earned** status: 6+ months of activity plus explicit trainer approval. Grants unlimited scans and a gold badge.

Design intent: a bought status doesn't build trust; an *earned* one does — modeled after Duolingo/Strava-style status mechanics, chosen specifically because it drives daily engagement (habit loop) rather than a one-time purchase.

## Related
[[Feature Map]] · [[Monetization Model]] · [[Known Inconsistencies]] · [[Database Overview]]
