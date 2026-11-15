---
title: CRM and Sales Pipeline
type: feature
area: project
status: idea
tags: [gymbro, product, crm, sales, phase2]
updated: 2026-09-28
---

# CRM and Sales Pipeline (Phase 2/3)

Internal admin-panel tool for the future [[Sales Team (Future)|sales_agent]] team to cold-call and onboard gyms and trainers — modeled on Snapp's business-development approach to recruiting drivers and restaurants.

## Tables
- **`leads`** — type (gym/trainer), name, phone, city, status (`new → contacted → negotiating → demo_scheduled → onboarded → rejected`), source (cold_call/referral/inbound/instagram), assigned sales_agent, link to the real record once onboarded
- **`lead_activities`** — call/message/meeting/note log per lead, who logged it

## Access
`sales_agent` role should see only these two tables — no financial or general user data. Enforced via RBAC/PBAC, see [[Roles and Permissions]].

## Status
Designed, not built — this is explicitly Phase 2/3, kicking in once the [[Trainer Partnership Program|personal-network trainer pipeline]] is exhausted.

## Related
[[Sales Team (Future)]] · [[Database Overview]] · [[Roadmap and Phases]] · [[Go-To-Market Strategy]]
