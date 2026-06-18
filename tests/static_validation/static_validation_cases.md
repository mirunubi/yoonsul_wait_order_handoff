# Static Validation Cases

## Purpose

Document manual and tooling validation scenarios for WP-10A-001 static validation scripts.

These cases describe expected behavior of read-only validators. They are not pytest cases.

## Cases

| Case ID | Scenario | Command | Expected Result |
| --- | --- | --- | --- |
| SV-001 | Hydration registry validator runs | `python tools/static_validation/validate_hydration_registry.py` | Exit code 0; PASS summary |
| SV-002 | Source module map validator runs | `python tools/static_validation/validate_source_module_map.py` | Exit code 0; PASS summary |
| SV-003 | Hydration registry JSON parse | SV-001 | Committed example parses |
| SV-004 | Hydration registry required fields | SV-001 | All six required top-level fields present |
| SV-005 | Hydration registry secret scan | SV-001 | No secret-like keys or values |
| SV-006 | Hydration registry provider scan | SV-001 | No provider/runtime strings in example content |
| SV-007 | Source module map JSON parse | SV-002 | Committed example parses |
| SV-008 | Source module map required fields | SV-002 | All six required top-level fields present |
| SV-009 | Source module map forbidden_paths | SV-002 | `forbidden_paths` is non-empty list of strings |
| SV-010 | Source module map secret scan | SV-002 | No secret-like keys or values |
| SV-011 | Manifest JSON validity | Read `tools/static_validation/static_validation_manifest.json` | Valid JSON; `stdlib_only: true`; `writes_files: false`; `runtime_behavior: false` |
| SV-012 | No file writes | Run both validators | No repository files modified |

## Forbidden Validation Behavior

- No package install during validation.
- No database access.
- No provider API calls.
- No skeleton mutation.
- No generated docs output.
