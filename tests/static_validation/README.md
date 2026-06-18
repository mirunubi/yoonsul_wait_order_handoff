# Static Validation Test Lane

This folder documents non-runtime validation cases for WP-10A-001 static validation tooling.

## Boundary

- Markdown-only case notes in this lane.
- Not a CI test suite.
- Not an executable pytest/unittest package.
- No package manager configuration.
- No generated output.

Executable validation lives under `tools/static_validation/` and must remain read-only with respect to skeleton JSON.

## Allowed Commands

```text
python tools/static_validation/validate_hydration_registry.py
python tools/static_validation/validate_source_module_map.py
```

## Forbidden Actions

- Package installs.
- App build or runtime execution.
- Database migration.
- Skeleton file mutation.
- Writing files from validators.

## Related Artifacts

- `static_validation_cases.md` — tooling case descriptions
- `tools/static_validation/static_validation_manifest.json` — validator manifest
