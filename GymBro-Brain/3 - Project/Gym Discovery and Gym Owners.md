---
title: Gym Discovery and Gym Owners
type: feature
area: project
status: decided
tags: [gymbro, product, gyms]
updated: 2026-09-28
---

# Gym Discovery and Gym Owners

## User side
- GPS-based "gyms near me" (also useful while traveling)
- Browse by amenities, at least 8 photos per gym, equipment list
- Choose a gym based on fitness goals; optionally pick a trainer from within that gym, or book a private trainer separately
- Pay membership fees **in-app**

## Gym owner side
- Gym listing flow compared by Armin to Divar's advanced listing form: minimum 8 photos, ideally shot when the gym is empty, as complete an equipment list as possible
- Verification: a GymBro "representative" is sent to confirm the listing isn't fake and to help complete missing details — staffing/scaling approach is an [[Open Questions|open question]]
- Once verified, the gym is listed with its full amenity set (e.g. a dedicated café/bar area)

## Data model highlights
- `gyms.status`: pending → active → suspended
- `gym_media`: up to many photos/videos, one marked as cover
- `trainer_gyms` and `user_gyms`: separate join tables for trainer affiliation vs. user membership

## Commission
**5%** of the user's payment on gym membership fees → [[Monetization Model]]

## Related
[[Feature Map]] · [[User Personas and Journeys]] · [[Database Overview]] · [[Monetization Model]]
