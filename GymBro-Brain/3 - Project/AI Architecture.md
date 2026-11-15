---
title: AI Architecture
type: reference
area: project
status: decided
tags: [gymbro, tech, ai]
updated: 2026-11-04
---

# AI Architecture

## Vision (Calorie & Food Scanning)
- **Primary: Google AI Studio Gemini 1.5 Flash Vision** (`gemini-1.5-flash`), with client-side inline base64 image encoding. Consumes only ~260 tokens per scan, making it extremely cost-effective and ultra-fast.
- **Secondary / Fallback: OpenRouter → GPT-4o Vision**, available as an alternative routing proxy.
- **Client-Side Secret Isolation**: Gemini API Key is configured by the user locally via the AI Settings screen and saved to encrypted `SharedPreferences`. Keys are **never hardcoded in source code, never committed to git, and never exposed in application logs or release APKs**.
- Structured JSON output format enforces strict extraction of: calories (`kcal`), protein (`g`), carbs (`g`), fat (`g`), and serving portion (`g`).

## Text & Persian AI Coach
- **Google Gemini 1.5 Flash / Pro** or **DeepSeek** via configurable provider.
- **Personalized AI Context Builder (`AiContextBuilder`)**:
  - Automatically constructs high-context Persian system prompts utilizing the user's verified biometric baseline (Armin Chinipardaz: 20 yo, 165 cm, 72.6 kg, 27.2% body fat, 2,250 kcal budget, 3-day split).
  - Enforces strict safety guardrails: The AI assistant **must never silently modify personal workout or nutrition plans**. Suggestions are advisory only.
  - Understands colloquial Iranian fitness terminology, bodybuilding slang, and Persian food preparations.

## Mascot Gamification Layer
- During vision scanning and long AI prompt generation, the **Cabbage Mascot Loader (`CabbageMascotLoader`)** entertains the user with a 60fps animation eating floating dumbbells and converting them into pure protein.

## Explicitly not used (for now)
- Self-hosted models via Ollama (e.g. LLaVA/BakLLaVA) — rejected because Persian/Iranian food training data is essentially nonexistent for these, and GPU hosting costs more than the API approach at MVP scale.

## Related
[[Calorie Scanning and Nutrition]] · [[ML Lead - Food Model (Cousin)]] · [[Architecture Decisions]] · [[Known Inconsistencies]] · [[Current Build Status]]
