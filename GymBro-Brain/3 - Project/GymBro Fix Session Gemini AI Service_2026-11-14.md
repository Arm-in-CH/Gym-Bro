# GymBro — Fix Session: Gemini AI Service (Security & Response Parsing)

**Date:** 2026-11-14
**Source:** Agent 2 — Task 02 (API Design & Contracts), Task 03 (Security & Auth), Task 07 (Integration & Third-Party)
**Severity:** HIGH
**Status:** Fixed (partial — remaining items pending)

---

## Objective

Address HIGH-severity findings in the Gemini AI integration:

1. API key exposure (Security).
2. Fragile / unsafe response parsing (API Design).

---

## Changes Applied

### File: `lib/core/ai/gemini_service.dart`

#### Fix 1 — Security (HIGH): API key transmission
- **Before:** Gemini request URI included API key as query param:
  `.../generateContent?key=$cleanKey`
- **After:** API key sent via header:
  `x-goog-api-key: cleanKey`
- Applied to:
  - `generateContent`
  - `testConnection`

#### Fix 2 — API Design (HIGH): Response parsing hardening
- **Before:**
  - `final data = jsonDecode(utf8.decode(response.bodyBytes));`
  - `final content = candidates[0]['content'];`
  - `if (content != null && content['parts'] != null)`
  - `return parts.map((p) => p['text'] ?? '').join('\n').trim();`
- **After:**
  - `final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;`
  - `final content = (candidates[0] as Map<String, dynamic>)['content'];`
  - `final parts = content?['parts'] as List<dynamic>?;`
  - Build `textParts` from parts, filter non-empty, join, trim.

---

## Remaining (pending)

- OpenRouter API key → secure storage.
- Gemini `stopSequences` + `finishReason` inspection.

## Final aggregation context

- final_score: 60
- critical_issues: []
