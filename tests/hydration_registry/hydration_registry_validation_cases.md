# Hydration Registry Validation Cases

## Purpose

List manual/static validation scenarios for the hydration registry skeleton.

These are Markdown-only validation notes. They are not executable tests.

## Cases

| Case ID | Scenario | Expected Result |
|---|---|---|
| HR-001 | Registry JSON parses as valid JSON | JSON parser accepts the file |
| HR-002 | Registry includes `registry_version` | Field is present and non-empty |
| HR-003 | Registry includes `generated_at` | Field is present and placeholder-safe |
| HR-004 | Registry includes `source_scope` | Included and excluded paths are explicit |
| HR-005 | Registry includes `modules` | Module entries use placeholder-safe values |
| HR-006 | Registry includes `evidence` | Evidence paths point to documentation evidence only |
| HR-007 | Registry includes `restrictions` | Forbidden paths are explicit |
| HR-008 | Registry excludes secrets | No secret, credential, token, or production ID appears |
| HR-009 | Registry excludes runtime behavior | No endpoint, SQL, provider, or app runtime behavior appears |

## Forbidden Validation Behavior

- No executable test runner.
- No generated files.
- No database access.
- No provider access.
- No secret inspection.
- No runtime mutation.
