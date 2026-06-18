# 020060_Policy_Anonymization_And_Pseudonymization_Standard

## 1 Purpose

Future analytics should prefer aggregated/anonymized/pseudonymized data.

Anonymization and pseudonymization are not the same.

This document defines conceptual rules only, not implementation.

It does not define SQL, migrations, app code, Supabase functions, anonymization pipeline, AI training dataset generation, or external sharing implementation.

## 2 Definitions

- raw personal data: data that contains direct personal identifiers or unprocessed customer-identifiable details.
- customer-identifiable data: data that can identify a customer directly or indirectly through contact data, names, session patterns, notes, or linked context.
- pseudonymized data: data where direct identifiers are replaced, but controlled re-identification may still be possible.
- anonymized data: data transformed so an individual is no longer identifiable under the approved process and risk review.
- aggregated data: data summarized across multiple events, sessions, stores, or periods.
- derived intelligence: interpreted metrics, patterns, or recommendations created from approved data.
- re-identification risk: risk that a person, store, tenant, or sensitive pattern can be inferred from transformed data.

## 3 Preferred Use Cases

- operational support may need scoped identifiable data.
- tenant reporting may use store-level or tenant-level aggregates.
- analytics should prefer aggregated or anonymized data.
- Franchise OS intelligence should prefer anonymized or pseudonymized aggregate data.
- AI or Agent future learning requires policy and legal review.

## 4 Minimum Transformation Principles

- remove direct identifiers where not needed.
- reduce granularity where possible.
- aggregate across enough events where possible.
- preserve tenant/store meaning only when permitted.
- avoid exporting raw session logs by default.
- do not assume anonymization without process.
- pseudonymized data remains controlled data.
- transformed data should preserve distinction between operational signal and financial truth.

## 5 Re-identification Guardrails

- small store or small sample risk.
- rare language or order pattern risk.
- timestamp precision risk.
- unique customer behavior risk.
- cross-dataset linkage risk.
- export recipient risk.
- tourist-zone or rare visitor pattern risk.

## 6 Non-MVP Boundary

The current MVP does not include:

- anonymization pipeline implementation.
- AI training dataset generation.
- external data marketplace.
- cross-tenant benchmark product.

## 7 Open Decisions

- minimum aggregation threshold.
- pseudonym key ownership.
- re-identification review process.
- analytics opt-in/opt-out.
- AI training dataset governance.
- third-party review.

## 8 Current Status

Status: active anonymization and pseudonymization standard draft.
