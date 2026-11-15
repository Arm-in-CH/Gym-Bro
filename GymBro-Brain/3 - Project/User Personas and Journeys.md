---
title: User Personas and Journeys
type: concept
area: project
status: decided
tags: [gymbro, product, personas]
updated: 2026-09-28
---

# User Personas and Journeys

| Role | Core job in the app |
|------|----------------------|
| User (athlete) | Finds a trainer/gym, receives a workout + nutrition plan, tracks progress, scans meals |
| Trainer | Builds workout/nutrition plans from a shared exercise library, acquires clients, optionally attaches to gyms |
| Gym owner | Lists a gym profile, recruits members and trainers, collects membership fees |
| Admin | Verifies gyms/trainers, approves new exercises, moderates content |
| sales_agent *(Phase 2/3)* | Cold-outreach onboarding of gyms/trainers via the [[CRM and Sales Pipeline]] |

## Key design decision: trainer is a user, not a separate account type
`role = trainer` on the same `users` table; trainer-only data lives in `trainer_profiles`. A **separate Flutter app** exists for trainers (same backend, same auth), so a trainer can also apply to a gym as a private/independent trainer through that dedicated app.

## Registration flow: progressive profiling
1. **Signup only:** phone, optional email, password + repeat password, optional referral code
2. **Later, on demand:** personal info (name, birth date, gender) and body data (weight, height, fitness goal/level) — requested only when the user tries to book a trainer, run a calorie scan, or start a home workout

This keeps signup friction minimal while still collecting what trainers actually need, just later.

## Related
[[Product Vision]] · [[Trainer Marketplace and Booking]] · [[Gym Discovery and Gym Owners]] · [[Roles and Permissions]]
