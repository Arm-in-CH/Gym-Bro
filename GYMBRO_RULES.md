# GYMBRO — PRODUCT DESIGN & ENGINEERING RULEBOOK

## PRODUCT VISION

GymBro is a distinctive fitness companion, not a generic fitness dashboard.

The goal is to build an application that feels carefully designed by an experienced product team, with a recognizable personality and a practical understanding of how people actually exercise.

The product should feel:

- Professional
- Human
- Athletic
- Energetic
- Friendly
- Confident
- Premium
- Easy to use every day

The design must not look like an automatically generated Flutter template.

## 1. HUMAN-CENTERED DESIGN RULES

Avoid repetitive layouts across different screens.

Do not use the same card structure everywhere.

Do not fill every empty area with cards, charts, badges, or statistics.

Do not add components just because they look visually impressive.

Every element must have a purpose.

Give every screen its own composition based on the user's task.

Use visual hierarchy, whitespace, typography, imagery, and controlled contrast to create a natural reading flow.

Design for real usage situations, especially during workouts.

## 2. VISUAL IDENTITY

Brand direction:

Human-crafted Athletic Technology.

Use the GymBro lime identity, but do not overuse it.

Suggested starting palette:

- Background: #0B0E13
- Secondary background: #111720
- Surface: #171D27
- Elevated surface: #202A37
- Main text: #F4F6F8
- Secondary text: #A7AFBD
- Primary lime: #C9F36A
- Warm amber: #FFB86B
- Soft cyan: #78CFE0
- Error: #FF6B70

These are design tokens, not rigid rules for every component.

Use tonal variation and warmth. Avoid making the entire application pure black.

Use shadows sparingly. Prefer visual depth through layered surfaces, spacing, contrast, and subtle borders.

Do not make every button glow.

## 3. TYPOGRAPHY

Use Vazirmatn for Persian when available.

Use distinct typography roles for:

- Screen headings
- Section headings
- Large numerical metrics
- Body text
- Supporting labels
- Buttons

Do not use heavy typography everywhere.

Prioritize readability, proper Persian shaping, correct RTL layout, and consistent numerical formatting.

## 4. BRAND PERSONALITY

Preserve the GymBro cabbage mascot as a recognizable brand asset.

Do not turn it into a repetitive loading animation.

Use it intentionally in meaningful moments, such as achievements, encouragement, and empty states.

Preserve the identity of the original concept while improving its visual execution.

## 5. INTERACTION DESIGN

Every interaction must provide meaningful feedback.

Use appropriate transitions, animations, and haptic feedback.

Avoid unnecessary animation, artificial bouncing, constant glow, and decorative motion.

Important workout controls must be easy to use with one hand.

Use approximately 48 logical pixels as the minimum touch-target guideline for important interactive controls.

## 6. TECHNICAL RULES

Use a feature-first structure appropriate for an experimental MVP.

Do not impose strict Clean Architecture or create unnecessary abstraction layers.

Use the existing state-management and routing solutions if they are healthy.

Introduce repositories and services when they solve a real separation or testing problem.

Do not migrate to Riverpod, Bloc, or GoRouter just for fashion.

Do not duplicate business state inside widgets.

Do not fake real API operations.

Keep demo functionality explicitly identified.

Do not expose private API keys in the mobile application.

## 7. HTML REFERENCE RULES

The HTML simulator is a reference for product ideas, visual identity, and selected interaction concepts.

It is NOT the source of truth for Flutter architecture.

Do not automatically migrate web-only simulator features.

Do not implement the simulated Foldable Mode or fake Dynamic Island in the actual application.

Developer-only testing tools must remain outside the user-facing application.

Do not remove meaningful brand features merely because they originated in the HTML prototype.

## 8. DEVELOPMENT RULES

Inspect before editing.

Plan before implementing.

Change one feature group at a time.

Avoid unrelated modifications.

Preserve working behavior.

Run tests after meaningful changes.

Report failures honestly.

Never claim a feature is complete without verifying it.

The final result should feel deliberately designed, not generated from a template.
