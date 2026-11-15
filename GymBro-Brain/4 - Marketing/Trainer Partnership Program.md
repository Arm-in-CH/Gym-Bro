---
title: Trainer Partnership Program
type: strategy
area: marketing
status: decided
tags: [gymbro, marketing, trainers, incentive]
updated: 2026-09-28
---

# Trainer Partnership Program

The supply-side subsidy for the first 12–15 trainers, recruited from Armin's personal network — modeled on how Uber initially subsidized driver acquisition risk.

## Mechanic
```
Base: 6 months at zero commission
+ 2 bonus days added per QUALIFIED referred user, via the trainer's referral code
  Qualified = user received a workout plan AND is still active 7 days later
  (not just signup — this closes an easy fraud loop)
Cap: 100 qualified users per trainer
→ max runway ≈ 6 months + (100 × 2 days) ≈ 12.6 months at the cap
After the cap or the time runs out (whichever first): standard 10% commission applies
```

## Why "still active after 7 days," not just signup
Counting bare signups would let a trainer send a referral code to friends who never actually use the app — inflating the trainer's numbers without creating a real retained user. The 7-day activity check ties the reward to genuine retention.

## Why this isn't just a discount
Three real reasons a trainer keeps using GymBro after the free period, discussed directly:
1. **Discovery** of new clients (weak for this very first cohort, stronger later)
2. **Reduced support load** — clean templates and demo videos cut repeated explanation
3. **Data lock-in** — a trainer's full client history lives in the app; leaving means losing that organization

For this first cohort specifically, the honest pitch leans on reasons 2 and 3, since reason 1 isn't real yet with zero existing users.

## Reuse for the sales_agent channel
The same mechanic is intended to extend to trainers recruited later by the future [[Sales Team (Future)|sales_agent]] team via the [[CRM and Sales Pipeline]] — when a `lead` reaches `status: onboarded`, its `partnership_ends_at` and `referral_code` are meant to auto-generate.

## Data model
Tracked via `trainer_profiles.referral_code` / `partnership_ends_at` / `partnership_users_count`, plus a dedicated `referrals` table logging each referred user's qualification. See [[Database Overview]].

## Related
[[Go-To-Market Strategy]] · [[Positioning and Differentiation]] · [[Database Overview]] · [[Monetization Model]]
