---
title: Trainer Marketplace and Booking
type: feature
area: project
status: decided
tags: [gymbro, product, trainers, booking]
updated: 2026-09-28
---

# Trainer Marketplace and Booking

## How it works
- Trainers set their **own price** (`hourly_rate` on `trainer_profiles`) — GymBro does not set trainer pricing
- Session type: online / in-person / both
- Booking lifecycle: `pending → confirmed → completed / cancelled` — enforced as a state machine in the NestJS service layer, not just a free-form status column (see [[Backend Architecture]])
- `bookings.commission_amount` is **stored at booking time**, not recomputed later — preserves historical accuracy if the commission rate changes in the future

## Verification
- `trainer_profiles.is_verified`, `verified_by`, `verified_at` — an admin approves trainers before they're bookable
- Exact verification process (documents, reviewer, turnaround) is an [[Open Questions|open question]]

## Trainer ↔ gym relationship
- A trainer can be independent, attached to one or more gyms, or both (`trainer_gyms` join table, status `pending/active/rejected`)
- This is why a **separate trainer app** exists — a trainer can apply to a gym as a private trainer through it

## Commission
- **10%** of the user's payment on trainer bookings → [[Monetization Model]]
- First 12–15 trainers get a temporary zero-commission period → [[Trainer Partnership Program]]

## Related
[[Feature Map]] · [[User Personas and Journeys]] · [[Monetization Model]] · [[Database Overview]] · [[Trainer Partnership Program]]
