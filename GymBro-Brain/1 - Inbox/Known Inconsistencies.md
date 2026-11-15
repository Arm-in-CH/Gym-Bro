---
title: Known Inconsistencies
type: log
area: inbox
status: open
tags: [gymbro, inbox, inconsistencies]
updated: 2026-09-28
---

# Known Inconsistencies

Places where earlier statements, chats, or exported files disagree. Do not quote the contested value as fact.

| # | Topic | What differs | Best current record | Action |
|---|-------|--------------|---------------------|--------|
| 1 | Free scans per day | Armin proposed 5/day; the AI suggested 3, then 5, then 2 after a cost check | Exported context says **2/day**; Armin never explicitly confirmed it | Decide → [[Monetization Model]] |
| 2 | Athlete perks | Earlier tables said "5 free scans", later "2 free scans" | Treat level as status only | Decide → [[Levels Ranking and Elite Status]] |
| 3 | Pro plan cap vs cost | 15 scans/day at ~1,780 Toman per scan is ~801,000 Toman/month vs a 490,000 price; break-even ≈ 9 scans/day | Cap is a working assumption | Get real usage data |
| 4 | Old profit projection | A chat estimate of ~367M Toman/month profit at 3,000 active users assumed only ~15M Toman of API cost | **Unreliable — discard** | Recompute from per-user scan behaviour |
| 5 | Currency label | Earlier exports used "IRR" for figures that are Toman | Vault uses Toman; earlier exports were corrected on 2026-09-28 | Choose the DB storage unit (Toman vs Rial) |
| 6 | `level = pro` vs `subscription_type = pro` | Two fields express overlapping ideas | Both exist in the schema | Decide whether level derives from subscription |
| 7 | Pricing origin | Armin's first proposal: 245,000 Toman/month with 5 scans/day. Current: 490,000 with 15 scans, plus 10% / 5% commissions | Current numbers are AI-proposed, accepted as baseline | Validate → [[Validation Plan]] |
| 8 | Elite | First discussed as a paid tier (990,000 Toman) → now an earned status | Earned status | — |
| 9 | Field naming | DTO uses `phoneNumber` (camelCase) while DB/entity uses `phone`; Update DTOs use snake_case (`first_name`) | Mixed | Pick one convention; map with Prisma `@map` → [[Code Conventions]] |
| 10 | ORM | The Sabzlearn course teaches TypeORM; the project chose Prisma; an early User entity was written TypeORM-style | Prisma is decided; TypeORM code is obsolete | Rewrite as `schema.prisma` |
| 11 | AI stack | The original design brief assumed Llama (RAG, fine-tuning); the plan now uses APIs (OpenRouter, DeepSeek) with an in-house food model later | API-based | — |
| 12 | Dollar rate | 178,000 Toman/USD as stated in chat; volatile | Recheck before costing | Update when used |
| 13 | Unverified claims | "OpenRouter is reachable from Iran", "DeepSeek vision is weaker for food", the ~$0.01/scan cost, the ParsPack VPS price range, and the PhonePipe operator table were AI statements, not verified | Treat as hypotheses | Verify → [[AI Architecture]] |

## Related
[[Inbox Hub]] · [[Open Questions]] · [[Monetization Model]] · [[Code Conventions]]
