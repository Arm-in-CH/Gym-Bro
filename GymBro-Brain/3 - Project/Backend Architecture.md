---
title: Backend Architecture
type: reference
area: project
status: decided
tags: [gymbro, tech, backend, nestjs]
updated: 2026-09-28
---

# Backend Architecture

## Auth
| Token | User TTL | Trainer TTL |
|-------|----------|-------------|
| access_token | 1 day | 4 hours |
| refresh_token | 30 days | 7 days |

Trainers get shorter TTLs because they access sensitive client data (photos, physical stats). Both tokens go through the `Authorization: Bearer` header; refresh flow follows the standard access/refresh rotation pattern.

## User self-service routes (split by concern, not one giant "update profile")
```
POST   /auth/register
POST   /auth/login
POST   /auth/refresh

PATCH  /users/me/profile    ← first_name, last_name, avatar, birth_date, gender
PATCH  /users/me/body       ← weight, height, fitness_goal, fitness_level
PATCH  /users/me/email      ← rate-limited
PATCH  /users/me/phone      ← rate-limited
PATCH  /users/me/password   ← currentPassword + newPassword + repeatNewPassword
PATCH  /users/me/settings   ← language, notifications_enabled
```
Reasoning: each route has one responsibility, rate limits can be tuned per-field (email/phone changes are higher-risk), and the client only ever sends the fields it actually changed (`@IsOptional()` on every DTO field — a missing field is left untouched, not treated as "clear this value").

## Booking as a state machine, not free-form status
`bookings.status` is a checked string, but the **transition rules** (`pending → confirmed → completed / cancelled`, no arbitrary jumps) are enforced in the NestJS service layer, not the DB. See [[Trainer Marketplace and Booking]].

## Event-driven flows
Two features are explicitly designed as event chains (via NestJS `EventEmitter`), not embedded in one large function:
- Calorie scan → check against `nutrition_plans.daily_calories` → notify user + trainer if exceeded
- Missed gym check-in → check plan type → generate a home-workout equivalent if available

See [[Home Workout Mode]] and [[Calorie Scanning and Nutrition]].

## Related
[[Tech Stack]] · [[Database Overview]] · [[Roles and Permissions]] · [[Code Conventions]]
