# Static Validation Tooling

This folder contains minimal Python static validation tooling for WP-10A-001.

## Purpose

Local, read-only validation of committed hydration registry and source module map JSON skeletons.

## Boundary

- Python standard library only.
- No package manager files in this lane.
- No file writes.
- No network access.
- No database access.
- No app runtime behavior.
- No skeleton mutation under `packages/` or existing `tests/hydration_registry/`, `tests/source_module_map/`.

## Allowed Commands

```text
python tools/static_validation/validate_hydration_registry.py
python tools/static_validation/validate_source_module_map.py
```

Run from repository root.

## Forbidden Actions

- `pip install`, `npm install`, or other package installs.
- App build or run commands.
- Database migration or Supabase CLI commands.
- Modifying skeleton JSON under `packages/`.
- Writing generated output under `docs-generated/`.
- Production runtime execution.

## Files

| File | Role |
| --- | --- |
| `validate_hydration_registry.py` | Validates hydration registry example against schema path and HR-style rules |
| `validate_source_module_map.py` | Validates source module map example against schema path and SMM-style rules |
| `static_validation_manifest.json` | Neutral manifest listing validators and targets |

## Owner Notes

- Human owner approves scope expansion beyond Batch 10C allowlist.
- Tooling owner maintains read-only validation boundary until a later authorized batch.
