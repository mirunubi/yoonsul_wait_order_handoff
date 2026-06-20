# 000087_Logic_WP_9A_001_Hydration_Registry_Schema_Validation_Rules_And_Evidence_Gate

## Purpose

Define validation rules and static evidence gate logic for WP-9A-001 hydration registry schema validation.

This document is logic design only. It does not execute validation and does not modify skeleton files.

## WorkPackage ID

`WP-9A-001 Hydration Registry Schema Validation And Static Evidence Gate`

## Schema Validation Rule Categories

| Category ID | Category | Description |
| --- | --- | --- |
| CAT-01 | Syntax | JSON document must parse without error |
| CAT-02 | Root shape | Root object must match schema root type and `additionalProperties: false` |
| CAT-03 | Required fields | All schema-required top-level fields must be present |
| CAT-04 | Type conformance | Each field must match declared JSON Schema type |
| CAT-05 | Nested object shape | Nested objects must satisfy required subfields and disallow extra properties |
| CAT-06 | Array item shape | Array entries must satisfy item schema |
| CAT-07 | Placeholder safety | Values must remain placeholder-safe and non-production |
| CAT-08 | Forbidden content | Document must not contain secrets, credentials, or runtime behavior markers |
| CAT-09 | Evidence gate | Aggregate pass/fail classification for static evidence acceptance |

## Required Field Checks

Top-level required fields per committed schema:

| Field | Required | Type | Rule |
| --- | --- | --- | --- |
| `registry_version` | Yes | string | Non-empty; placeholder version format acceptable |
| `generated_at` | Yes | string | Non-empty; ISO-like or explicit placeholder timestamp |
| `source_scope` | Yes | object | Must include `included_paths` and `excluded_paths` arrays |
| `modules` | Yes | array | At least one module entry in example fixture |
| `evidence` | Yes | array | At least one evidence entry in example fixture |
| `restrictions` | Yes | array | At least one restriction entry in example fixture |

Missing any required top-level field is a **FAIL-STRUCT** failure.

## Type Checks

| Path | Expected Type | Failure If |
| --- | --- | --- |
| `registry_version` | string | number, boolean, object, array, or null |
| `generated_at` | string | non-string type |
| `source_scope` | object | non-object type |
| `source_scope.included_paths` | array of strings | missing, non-array, or non-string items |
| `source_scope.excluded_paths` | array of strings | missing, non-array, or non-string items |
| `modules` | array of objects | missing, non-array, or item missing required module fields |
| `evidence` | array of objects | missing, non-array, or item missing required evidence fields |
| `restrictions` | array of objects | missing, non-array, or item missing required restriction fields |

Type mismatch is a **FAIL-TYPE** failure.

## Evidence Object Checks

Each `evidence[]` item must satisfy:

| Field | Required | Rule |
| --- | --- | --- |
| `evidence_id` | Yes | Non-empty string; placeholder ID format acceptable |
| `description` | Yes | Non-empty string; must describe documentation evidence, not runtime output |
| `path` | Yes | Non-empty string; must reference `docs/` path or approved documentation lane |

Evidence validation rules:

1. Every `path` value must start with `docs/` or be an explicitly approved documentation-relative path.
2. No `path` may reference `apps/`, `supabase/`, `data/`, secrets, or provider endpoints.
3. No `path` may reference generated runtime output unless a future batch explicitly approves that lane.
4. Evidence entries must not duplicate production IDs or live credentials.

Evidence object violation is **FAIL-EVIDENCE** failure.

## Restrictions Object Checks

Each `restrictions[]` item must satisfy:

| Field | Required | Rule |
| --- | --- | --- |
| `restriction_id` | Yes | Non-empty string |
| `path_pattern` | Yes | Non-empty path prefix or pattern string |
| `rule` | Yes | Non-empty human-readable restriction rule |

Restrictions validation rules:

1. `path_pattern` must align with WP-8A-001 forbidden boundaries (for example `apps/`, `supabase/`, `data/`).
2. `rule` must describe forbidden modification or access, not grant runtime permission.
3. Restrictions must not contradict committed example excluded paths without documented human review.

Restriction object violation is **FAIL-RESTRICTION** failure.

## Version Field Checks

| Field | Check | Pass Condition | Fail Condition |
| --- | --- | --- | --- |
| `registry_version` | Presence and format | Present, non-empty, placeholder-safe (for example `0.1-placeholder`) | Missing, empty, or production semver implying live deployment |
| `generated_at` | Presence and placeholder safety | Present; uses placeholder timestamp or neutral ISO string | Missing, empty, or live production timestamp tied to secret/system identity |

Version field violation is **FAIL-VERSION** failure.

## Placeholder-Only Data Checks

Placeholder-safe values are required for the committed example fixture.

| Area | Placeholder-Safe Examples | Not Placeholder-Safe |
| --- | --- | --- |
| Module IDs | `MODULE-PLACEHOLDER-001` | Live tenant IDs, store IDs, user IDs |
| Module owner | `TBD`, role name | Personal email, API key owner, live account |
| Module status | `placeholder`, `draft` | `production`, `live`, `deployed` |
| Evidence IDs | `EVIDENCE-PLACEHOLDER-001` | Ticket numbers tied to live incidents with secrets |
| Timestamps | `YYYY-MM-DDTHH:MM:SSZ` | Actual runtime log timestamps used as secrets |
| Paths | Committed docs paths, skeleton paths | Live URLs, webhook endpoints, DB connection strings |

Placeholder violation is **FAIL-PLACEHOLDER** failure.

## Forbidden Secret, Provider, And Runtime Checks

Manual content scan must reject registry JSON containing any of the following patterns or equivalents:

| Forbidden Class | Examples / Patterns | Failure Code |
| --- | --- | --- |
| Secrets | `password`, `secret`, `api_key`, `token`, `credential`, `Bearer ` | FAIL-FORBIDDEN-SECRET |
| Provider runtime | Provider API base URLs, webhook URLs, OAuth endpoints | FAIL-FORBIDDEN-PROVIDER |
| SQL / database | `SELECT `, `INSERT `, `CREATE TABLE`, connection strings | FAIL-FORBIDDEN-SQL |
| App runtime | `http://`, `https://` service endpoints under app scope | FAIL-FORBIDDEN-RUNTIME |
| Package manager | `package.json`, `pubspec.yaml`, lockfile references as runtime config | FAIL-FORBIDDEN-STACK |
| Production identifiers | Live UUIDs presented as production tenant/store/customer IDs | FAIL-FORBIDDEN-PROD-ID |

Scan is static string and field review only. No secret store access is authorized.

## Static Evidence Gate Logic

The static evidence gate evaluates aggregate readiness of a hydration registry record for documentation reference.

### Gate Inputs

1. Committed schema file.
2. Committed example JSON file.
3. HR-001 through HR-009 case results (manual review).
4. WP-8A-001 boundary maps and hydration evidence references.

### Gate Evaluation Steps

| Step | Action | Outcome |
| --- | --- | --- |
| G-01 | Confirm JSON syntax valid | Proceed or FAIL-STRUCT |
| G-02 | Confirm schema required fields present | Proceed or FAIL-STRUCT |
| G-03 | Confirm type conformance for all required paths | Proceed or FAIL-TYPE |
| G-04 | Confirm evidence objects reference docs-only paths | Proceed or FAIL-EVIDENCE |
| G-05 | Confirm restrictions align with forbidden boundaries | Proceed or FAIL-RESTRICTION |
| G-06 | Confirm placeholder-only data policy | Proceed or FAIL-PLACEHOLDER |
| G-07 | Confirm forbidden content scan clean | Proceed or FAIL-FORBIDDEN-* |
| G-08 | Confirm HR-001 through HR-009 all mapped and reviewed | Proceed or FAIL-COVERAGE |
| G-09 | Classify aggregate gate result | PASS-GATE or FAIL-GATE |

### Gate Pass Rule

Gate passes only if steps G-01 through G-09 complete with no failure classification.

### Gate Fail Rule

Any single failure classification yields **FAIL-GATE**. Failed gate blocks executable validation authorization and blocks downstream WorkPackage implementation gates.

## Failure Classification

| Code | Severity | Meaning | Remediation |
| --- | --- | --- | --- |
| FAIL-STRUCT | High | JSON or required structure invalid | Fix structure in approved skeleton batch only |
| FAIL-TYPE | High | Field type mismatch | Fix types in approved skeleton batch only |
| FAIL-EVIDENCE | High | Evidence path or description invalid | Correct evidence entries under approved batch |
| FAIL-RESTRICTION | Medium | Restriction entry invalid or inconsistent | Correct restrictions under approved batch |
| FAIL-VERSION | Medium | Version or timestamp field invalid | Correct version fields under approved batch |
| FAIL-PLACEHOLDER | Medium | Production-like values in placeholder fixture | Replace with placeholder-safe values |
| FAIL-FORBIDDEN-SECRET | Critical | Secret or credential pattern detected | Remove forbidden content; security review |
| FAIL-FORBIDDEN-PROVIDER | Critical | Provider runtime reference detected | Remove provider runtime references |
| FAIL-FORBIDDEN-SQL | Critical | SQL or DB runtime reference detected | Remove SQL references |
| FAIL-FORBIDDEN-RUNTIME | Critical | App/runtime endpoint reference detected | Remove runtime references |
| FAIL-FORBIDDEN-STACK | High | Stack/config selection implied | Remove stack references |
| FAIL-FORBIDDEN-PROD-ID | High | Production identifier detected | Replace with placeholder IDs |
| FAIL-COVERAGE | Medium | HR case not mapped or reviewed | Complete coverage matrix review |
| FAIL-GATE | High | Aggregate gate failure | Resolve underlying failure codes |
| PASS-GATE | N/A | Aggregate gate pass | Eligible for next planning gate only |

Critical failures block all downstream authorization until human security review is recorded.
