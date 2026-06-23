# App Map & Known UI Behaviors

Reusable, **non-SRS** knowledge about the application under test, captured once so
future runs don't re-derive it by trial and error. This is **observed UI behavior**,
not a requirement — expected results still come from the SRS. **Fill it in for your
app** and update it as the app changes.

- App URL & environments: see `docs/ai/context.md` (never production).

## Login / entry
- Default language / locale + how to switch: `TBD`
- Post-login landing page per role: `TBD`
- Role switch (login-as): how to log out and back in as another role; note any quirk
  (e.g. a menu that only renders at a wide viewport): `TBD`

## Navigation map: feature → route → roles
Fill from your app so execution can navigate without guessing.

| Feature | Menu path | Route | Seen by (roles) |
|---------|-----------|-------|-----------------|
| `TBD`   | `TBD`     | `TBD` | `TBD`           |

> Capture "gotchas learned the hard way" here — e.g. a capability nested under an
> unexpected menu — so they aren't rediscovered each run.

## Per-area specifics
Record per-screen quirks that affect testing: button order, what a disabled control
means, required fields, server validation codes, etc. `TBD`

## API endpoints
The API catalog (for data seeding and API checks) lives in its own file:
`docs/ai/api-map.md` — build/refresh it with the **map-api** skill.

## Known UI gotchas (common — confirm which apply to your app)
These are frequently true of web apps. Verify each against your app and keep the ones
that apply (delete the rest):

1. **Lists may not auto-refresh** after Add/Update/Delete — reload or re-sort before
   asserting a create/edit/delete result; don't judge from the un-refreshed grid.
2. **Dropdowns/lists may lazy-load a subset**, and in-field search may filter only the
   loaded subset — a value can look "absent" when it exists. You cannot reliably prove
   absence via search; scroll to load, use a non-UI check, or record INCONCLUSIVE.
3. **Menus/overlays may render off-screen at small viewports** — set a generous
   viewport (e.g. ≥1600×900) before opening them.
4. **Inputs may reject special characters** — prefer plain alphanumeric names for
   created test data.
5. **Derived / calendar / aggregate views may only show items meeting a configuration
   precondition** — note the config a record needs in order to surface there.

Record app-specific gotchas below as you find them. `TBD`
