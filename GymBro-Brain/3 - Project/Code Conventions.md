---
title: Code Conventions
type: reference
area: project
status: decided
tags: [gymbro, tech, conventions]
updated: 2026-09-28
---

# Code Conventions

## Naming
- snake_case, plural table names in PostgreSQL
- Field naming is currently **mixed** and should be reconciled: `CreateUserDto` uses `phoneNumber` (camelCase) while the DB/entity layer and other update DTOs use snake_case (`first_name`). Prisma's `@map()` can bridge this cleanly. See [[Known Inconsistencies]] #9

## Validation
- class-validator + class-transformer, applied per-DTO
- Custom `@Match(property)` decorator validates two fields are equal (used for password confirmation)
- `ValidationPipe` configured globally with `whitelist: true` and `forbidNonWhitelisted: true` — unknown fields are rejected outright, protecting against a client trying to set fields like `role` or `is_elite` directly

## DTO split pattern
Update endpoints are split by concern rather than one large "update user" DTO — see the route list in [[Backend Architecture]]. Each DTO only validates the fields it owns; `@IsOptional()` throughout so partial updates work without clearing untouched fields.

## Tooling
- ESLint: several `@typescript-eslint/no-unsafe-*` rules turned off specifically because of class-validator/class-transformer decorator patterns (not a general leniency policy)
- tsconfig: `strict: true`, `noImplicitAny: true`, `module: commonjs` (not `nodenext` — caused compatibility issues with NestJS)

## Related
[[Architecture Decisions]] · [[Backend Architecture]] · [[Database Overview]]
