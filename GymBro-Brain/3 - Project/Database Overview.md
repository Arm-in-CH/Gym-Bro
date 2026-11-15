---
title: Database Overview
type: reference
area: project
status: decided
tags: [gymbro, tech, database, postgresql, mongodb]
updated: 2026-09-28
---

# Database Overview

Full CREATE TABLE statements live in the exported `gymbro-postgresql-schema.sql` file (17 tables, with indexes, CHECK constraints, and `updated_at` triggers). This note is the map, not the SQL itself.

## PostgreSQL — 14 MVP tables
`users`, `trainer_profiles`, `gyms`, `gym_media`, `trainer_gyms`, `user_gyms`, `bookings`, `payments`, `workout_plans`, `exercises`, `workout_plan_exercises`, `nutrition_plans`, `coin_transactions`, `reviews`

## PostgreSQL — 3 Phase 2/3 tables
`leads`, `lead_activities` (see [[CRM and Sales Pipeline]]), `referrals` (see [[Trainer Partnership Program]])

## Design principles baked into the schema
- UUID primary keys, `gen_random_uuid()`
- `timestamptz` everywhere, never plain `timestamp`
- Enum-like fields are `varchar` + `CHECK`, not native Postgres ENUM — see [[Architecture Decisions]]
- `ON DELETE` behavior is deliberately varied: `CASCADE` for tightly-owned child records (e.g. `gym_media`, `trainer_profiles`), `SET NULL` for "who did this" audit columns (`verified_by`, `cancelled_by`), `RESTRICT` for core financial/business records (`bookings`, `payments`) — reflecting a soft-delete philosophy (`users.status = banned/inactive` rather than hard deletes)
- `bookings.commission_amount` is stored at booking time (frozen), not recomputed from the current rate later
- `reviews.target_id` and `payments.related_id` are intentionally polymorphic with **no formal FK** — documented in SQL comments rather than solved with trigger-based integrity checks (judged not worth the complexity at MVP stage)

## MongoDB collections
`chat_messages`, `ai_conversations`, `calorie_scan_logs`, `food_database`, `notifications`, `user_activity_logs`, `gym_media_metadata` — chosen for high write volume and/or variable structure that doesn't fit a relational shape well.

## Known gaps
- No table for logging *performed* sets/reps/weight (only the *planned* `workout_plan_exercises`) — see [[Open Questions]] #16
- No dedicated subscription-history table — `subscription_type` + `pro_expires_at` on `users` plus `payments` is what exists today — see [[Open Questions]] #17
- Storage unit for money (Toman vs Rial) needs a final decision — see [[Known Inconsistencies]] #5

## Related
[[Project Hub]] · [[Architecture Decisions]] · [[Backend Architecture]] · [[AI Architecture]] · [[Code Conventions]]
