---
title: Tech Stack
type: reference
area: project
status: decided
tags: [gymbro, tech, stack]
updated: 2026-11-04
---

# Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile Client (Users) | Flutter 3.24.5 / Dart 3.5.4 (Material Design 3, Persian RTL) |
| Mobile Architecture | StateNotifier/ChangeNotifier pattern, SharedPreferences local storage |
| Mobile Client (Trainers) | Separate Flutter app, shared design tokens & auth |
| Web Simulator | Xiaomi Redmi Note 15 Pro simulator with HyperOS Dynamic Island & Web Audio API Synthesizer |
| Backend | NestJS (REST, monolith, Express adapter) |
| Admin Panel | React |
| Primary DB | PostgreSQL |
| Secondary DB | MongoDB |
| ORM | Prisma |
| Cache | DragonflyDB (Redis-compatible) |
| Auth | JWT — access + refresh tokens |
| Password Hashing | argon2id |
| Validation | class-validator + class-transformer |
| AI — Vision | Google AI Studio Gemini 1.5 Flash Vision (low-token base64) / OpenRouter fallback |
| AI — Text & Coach | Google Gemini 1.5 Flash & Pro / DeepSeek with Biometric Context Builder |
| Hosting | ParsPack VPS (Iran) |

See [[Architecture Decisions]] for the reasoning behind each choice and what was rejected.

## Related
[[Project Hub]] · [[Architecture Decisions]] · [[Backend Architecture]] · [[Database Overview]] · [[Infrastructure and Hosting]] · [[Current Build Status]]
