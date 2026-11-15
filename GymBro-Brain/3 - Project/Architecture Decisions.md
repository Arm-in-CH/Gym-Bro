---
title: Architecture Decisions
type: decisions
area: project
status: decided
tags: [gymbro, tech, architecture, decisions]
updated: 2026-09-28
---

# Architecture Decisions

Locked-in choices, with the reasoning, and — just as important — what was explicitly rejected for MVP and why.

## Locked in
| Area | Decision | Why |
|------|----------|-----|
| API style | REST, not GraphQL | Flutter and React admin both work fine with REST; no use case needs GraphQL yet |
| Backend structure | Monolith, not microservices | Team of one; microservices add ops overhead with no current payoff |
| HTTP adapter | Express, not Fastify | ~30% speed gain isn't the bottleneck at MVP scale; revisit past ~10K concurrent requests |
| Primary DB | PostgreSQL, not MySQL | Native UUID, JSONB, and a path to PostGIS for GPS search beat MySQL here |
| ORM | Prisma, not TypeORM | Stronger type safety, cleaner migrations, better autocomplete — switched mid-project (see [[Known Inconsistencies]] #10) |
| Cache | DragonflyDB, not Redis, **from day one** | Redis-API-compatible, faster, lower RAM — no reason to defer to "Phase 2" once the choice was made |
| Enum-like fields | Plain `varchar` + `CHECK` constraints, not native Postgres ENUM or TS enums | Native ENUM needs `ALTER TYPE` to add a value later; TS enums added unwanted ceremony to DTOs |
| Password hashing | argon2id, not bcrypt | Stronger against GPU/brute-force attacks; justified given users upload personal photos and trainers handle sensitive client data |
| Validation | class-validator + class-transformer, not Zod | NestJS-native; mixing both was rejected as pure duplication |
| Auth tokens | JWT access + refresh, not server-side sessions | Stateless, works cleanly for Flutter; sessions need Redis/Dragonfly state that isn't needed otherwise |
| Vision AI | OpenRouter → GPT-4o Vision, not a direct OpenAI/Google call | Direct calls are blocked by Iran filtering; OpenRouter proxies around that |
| Text AI | DeepSeek | No filtering issues from Iran |

## Explicitly rejected (for now)
- **Native Enums** (Postgres ENUM type and TypeScript enums) — migration pain / unnecessary ceremony
- **GraphQL** — no use case justifies the added complexity
- **Microservices** — Phase 3 territory at the earliest
- **Fastify** — only worth it once Express is a measured bottleneck
- **Zod alongside class-validator** — pick one, not both
- **Plain Redis** — DragonflyDB does the same job better, adopted immediately instead of "later"
- **Self-built vision model at MVP stage** — GPU hosting cost and lack of training data make this premature; use an API now, build the in-house model over time (see [[ML Lead - Food Model (Cousin)]])

## Related
[[Project Hub]] · [[Tech Stack]] · [[Database Overview]] · [[AI Architecture]] · [[Code Conventions]]
