---
title: Home Workout Mode
type: feature
area: project
status: decided
tags: [gymbro, product, workouts]
updated: 2026-09-28
---

# Home Workout Mode

## Purpose
If a user can't get to the gym on a given day but still wants to keep burning calories, their existing trainer-assigned plan is converted into equipment-free (no dumbbells, nothing) home exercises. A dedicated home-training section also exists for **Pro users**.

## Why this is treated as a workflow, not plain CRUD
This — along with the calorie-scan-to-alert chain — was explicitly identified as one of the few real event-driven flows in the app:

```
user.gym_checkin_missed
  → check workout_plan.type
  → if a home-equivalent exists → generate home_workout
```

Planned to be implemented with NestJS's `EventEmitter` (the same course chapter covers event-driven architecture), keeping this logic in its own listener rather than bloating a single service method.

## Data gap
The current [[Database Overview|schema]] doesn't yet model which exercises have a bodyweight/no-equipment alternative — needed before this can actually be auto-generated. See [[Open Questions]] #18.

## Related
[[Feature Map]] · [[Backend Architecture]] · [[Database Overview]] · [[Open Questions]]
