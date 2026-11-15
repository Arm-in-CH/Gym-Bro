---
title: Roles and Permissions
type: reference
area: project
status: decided
tags: [gymbro, tech, rbac, roles]
updated: 2026-09-28
---

# Roles and Permissions

## The five roles
`user / trainer / gym_owner / admin / sales_agent`

- `trainer` is a `user` with `role = trainer` — not a separate table; trainer-specific data lives in `trainer_profiles`
- `sales_agent` is a Phase 2/3 addition for the [[CRM and Sales Pipeline]] — see [[Sales Team (Future)]]

## Access model
RBAC/PBAC (role-based + permission-based access control), matching the NestJS course chapter Armin is working through. Planned enforcement pattern: `sales_agent` should see only `leads` and `lead_activities` — no access to financial data or general user records.

## Related
[[User Personas and Journeys]] · [[Backend Architecture]] · [[CRM and Sales Pipeline]] · [[Sales Team (Future)]]
