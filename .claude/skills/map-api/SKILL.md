---
name: map-api
description: Discover the application's API endpoints and record them in docs/ai/api-map.md for reuse — data seeding (default provisioning) and API-level checks.
---

# Skill: Map API

Build (or refresh) `docs/ai/api-map.md` — a reusable catalog of the app's API endpoints.
Run it once up front, or anytime a needed endpoint isn't mapped yet.

## Steps
1. Find a spec first: look for OpenAPI/Swagger (e.g. `/swagger`, `/swagger.json`,
   `/openapi.json`, `/api-docs`). If present, parse it for endpoints, payloads, responses.
2. Otherwise OBSERVE: with the Admin session, perform the relevant UI actions via the
   Playwright MCP and capture the network requests they fire (method, path, request body,
   response, the id field returned). Cover at least the create/setup calls per entity.
3. RECORD each endpoint in `docs/ai/api-map.md`: purpose, entity, method+path, auth model,
   request/payload shape, response/id field, notes. Mark `✓` (from a spec/confirmed) or
   `?` (inferred from observation) and confirm `?` entries with the user.
4. Capture the base URL + auth model (reuse the Admin session's auth — **never** write a
   token/secret into the file).

## Rules
- Discover on the **test environment only** (`context.md`) — never production.
- Prefer read-only discovery; if discovery triggers create calls, tag data `QA_<runid>_`
  and clean it up.
- Keep the file token-light — a table, not raw spec dumps.

## Output
- Updated `docs/ai/api-map.md` + a short list of which endpoints are confirmed vs inferred,
  and any entity still lacking a seeding endpoint (so seeding falls back to the UI there).
