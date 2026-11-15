---
title: AI Collaboration Guide
type: guide
area: team
status: decided
tags: [gymbro, team, ai, guide]
updated: 2026-09-28
---

# AI Collaboration Guide

For any AI assistant picking up GymBro work from this vault.

## Language and tone
- Armin writes in Persian; this vault is in English on purpose, so any AI (Persian or not) can use it
- Be direct and concrete. Give one clear recommendation, not a menu of "it depends" options
- Skip filler and unnecessary hedging — but flag genuine uncertainty (see [[Known Inconsistencies]] and [[Open Questions]])

## Complexity discipline
- MVP-first is a hard rule. Explicitly rejected for now: native Postgres/TypeScript Enums (plain strings + CHECK constraints instead), GraphQL, Zod alongside class-validator, microservices, Fastify, native Redis (using DragonflyDB from day one instead) — see [[Architecture Decisions]]
- Don't propose "advanced" architecture unless Armin asks or a real bottleneck appears — note it in [[Ideas Parking Lot]] instead

## Treat as unverified
- Numbers and claims produced by an AI during discussion (API costs, competitor gaps, server pricing, filtering behavior) are **hypotheses**, not facts, until Armin confirms them or a source is checked. See [[Known Inconsistencies]] item 13
- Never state a contested figure (e.g. free scan count) as settled — check [[Known Inconsistencies]] first

## Practical constraints to always factor in
- Iran internet filtering blocks direct calls to some providers (e.g. OpenAI) — route through intermediaries like OpenRouter
- Prices are in **Toman** (1 Toman = 10 Rial), not Rial — see [[Glossary]]
- Armin frequently moves this project between AI tools/tabs by exporting files — keep this vault (and the exported context files) as the portable source of truth

## Related
[[Team Hub]] · [[About Me - Armin]] · [[Known Inconsistencies]] · [[Architecture Decisions]]
