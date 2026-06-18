# Source Module Map Validation Cases

## Purpose

List manual/static validation scenarios for the source-to-module map skeleton.

These are Markdown-only validation notes. They are not executable tests.

## Cases

| Case ID | Scenario | Expected Result |
|---|---|---|
| SMM-001 | Source module map JSON parses as valid JSON | JSON parser accepts the file |
| SMM-002 | Map includes `map_version` | Field is present and non-empty |
| SMM-003 | Map includes `source_files` | Entries use placeholder-safe paths |
| SMM-004 | Map includes `modules` | Module records include ID, name, and domain |
| SMM-005 | Map includes `ownership` | Owner entries are explicit or marked TBD |
| SMM-006 | Map includes `test_mapping` | Test mapping points to non-executable validation notes |
| SMM-007 | Map includes `forbidden_paths` | Forbidden paths include app, backend, data, and package config boundaries |
| SMM-008 | Map excludes production IDs | No production ID, secret, credential, or provider data appears |
| SMM-009 | Map excludes runtime behavior | No SQL, endpoint, package manager, or app runtime behavior appears |

## Forbidden Validation Behavior

- No executable test runner.
- No generated files.
- No database access.
- No provider access.
- No secret inspection.
- No runtime mutation.
