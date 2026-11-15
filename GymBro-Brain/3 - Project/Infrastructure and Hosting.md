---
title: Infrastructure and Hosting
type: reference
area: project
status: decided
tags: [gymbro, tech, infra, hosting]
updated: 2026-09-28
---

# Infrastructure and Hosting

## Hosting
- **ParsPack VPS**, Iran — chosen for domestic hosting given the app targets Iranian users
- Specific VPS tier/pricing discussed only in general terms, not finalized — treat any figure mentioned in chat as illustrative, not a quote

## Cache
- **DragonflyDB**, Redis-API-compatible, adopted from project start (not deferred to "Phase 2")
- Planned use cases: OTP/SMS verification (high priority), calorie-scan rate limiting (high), trainer/gym list caching (medium), GPS results caching (medium), JWT blacklist on logout (medium), trainer online-status (low)

## Not yet decided
- Object/file storage for photos, videos, and future 3D exercise assets — marked TBD
- Payment gateway — Zarinpal, Zibal, or another provider not yet chosen
- SMS provider for OTP not yet chosen

See [[Open Questions]] #10–12.

## Related
[[Tech Stack]] · [[Architecture Decisions]] · [[Backend Architecture]]
