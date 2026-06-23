# API Map

A reusable catalog of the application's API endpoints — built once and reused **anytime**
for **data seeding** (the default provisioning path) and API-level checks. Built by the
**map-api** skill: discover from an OpenAPI/Swagger spec, the browser network tab during
the equivalent UI action, or observed requests; confirm inferred entries.

- Reuse the logged-in **Admin session's auth** at runtime — **no tokens/secrets in this file**.
- Test environment only (see `context.md`) — never production.
- Mark inferred endpoints `?` and confirm; stated ones `✓`.

## Base
- Base URL(s): see `context.md`. API base path: `TBD`
- Auth model (cookie/session/bearer; reuse the Admin session, never hardcode a token): `TBD`
- OpenAPI / Swagger location, if any (e.g. `/swagger`, `/openapi.json`, `/api-docs`): `TBD`

## Endpoints
| Purpose | Entity | Method + path | Auth | Request / payload | Response / id field | ✓/? | Notes |
|---------|--------|---------------|------|-------------------|---------------------|-----|-------|
| _create order (example)_ | Order | `POST /api/orders` | session | `{customerId, lines[]}` | `201 {id}` | ? | use `id` to link children |
| `TBD` | | | | | | | |

## How it's used
- **Seeding (default):** `execute-test-cases` seeds needed data through these endpoints
  before testing; fall back to the UI only when no usable endpoint exists.
- **Ordering:** create parents before children (cross-check entity edges in `system-graph.md`).
- **Cleanup:** where a delete endpoint exists, use it to remove this run's residue.

Empty until **map-api** runs. Replace the EXAMPLE row with your endpoints.
