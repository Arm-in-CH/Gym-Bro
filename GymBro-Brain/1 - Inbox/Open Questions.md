---
title: Open Questions
type: log
area: inbox
status: open
tags: [gymbro, inbox, open-questions]
updated: 2026-09-28
---

# Open Questions

Nothing here is decided. Ask Armin (one question at a time) before assuming an answer.

## Business and product
| # | Question | Why it matters | Related |
|---|----------|----------------|---------|
| 1 | Who bears the marketplace commission — deducted from the trainer's payout, or added on top of the user's price? | Armin once said "a very small share of the user's payment"; pricing pages and payouts depend on it | [[Monetization Model]] |
| 2 | Final free-tier scan allowance (2/day vs 5/day) and daily vs monthly reset | Biggest API-cost lever | [[Known Inconsistencies]] |
| 3 | What does the **Athlete** level actually unlock, if anything? | Earlier tables gave conflicting perks | [[Levels Ranking and Elite Status]] |
| 4 | Formal MVP cut line. Working assumption: features backed by the 14 core tables | Scope control | [[Roadmap and Phases]] |
| 5 | Trainer verification: which documents, who reviews, how fast | Trust and supply quality | [[Trainer Marketplace and Booking]] |
| 6 | Gym verification visits: who is the "representative" and how does it scale | Armin's fraud-prevention idea has a staffing cost | [[Gym Discovery and Gym Owners]] |
| 7 | Local competitor analysis has not been done | Positioning claims are unverified | [[Competitive Landscape]] |
| 8 | No validation with real trainers or users yet | Pricing and commission are untested | [[Validation Plan]] |
| 9 | GymBro brand account vs Armin's personal account only | Content plan | [[Social Media Hub]] |

## Technical
| # | Question | Related |
|---|----------|---------|
| 10 | Payment gateway (Zarinpal / Zibal / other) and how trainer and gym payouts and commission splits are settled | [[Monetization Model]] |
| 11 | SMS provider for OTP | [[Backend Architecture]] |
| 12 | Object storage for photos, videos, and 3D assets (marked "TBD") | [[Infrastructure and Hosting]] |
| 13 | Amount unit stored in the DB: Toman or Rial | [[Known Inconsistencies]] |
| 14 | How OpenRouter / DeepSeek credits will be bought from Iran, and whether the VPS can reach them without a proxy | [[AI Architecture]] |
| 15 | Vision model must be benchmarked on Persian food (GPT-4o vs alternatives) | [[AI Architecture]] |
| 16 | Workout logging (performed sets/reps, progress tracking) is not modeled | [[Database Overview]] |
| 17 | Subscription history: only `users.subscription_type`, `pro_expires_at`, and `payments` exist | [[Database Overview]] |
| 18 | Home-workout conversion needs exercise metadata (equipment, bodyweight alternative) the schema lacks | [[Home Workout Mode]] |
| 19 | Offline-first / low-bandwidth strategy (in the original brief) has not been designed | [[Backend Architecture]] |
| 20 | Trust and safety beyond verification flags: medical disclaimers, unsafe-advice handling, fake trainers/gyms, abusive content | [[Backend Architecture]] |

## Team and process
| # | Question | Related |
|---|----------|---------|
| 21 | Who builds the Flutter apps (user + trainer) and the React admin/CRM? | [[Team Hub]] |
| 22 | Armin mentioned an existing ready-made design (including an admin panel with a CRM section). How does it map to this vault? | [[Project Hub]] |
| 23 | Written agreement / compensation with the ML lead | [[ML Lead - Food Model (Cousin)]] |
| 24 | Legal and regulatory review (payments, health claims) has not been discussed | [[Roadmap and Phases]] |

## Related
[[Inbox Hub]] · [[Known Inconsistencies]] · [[Current Build Status]]
