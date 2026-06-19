# 750160_Guide_Delivery_App_KDS_DID_Context_Snapshot_Rules_Summary_For_51355_Pipeline.md

## 1. Purpose

This guide defines the lightweight context snapshot rules for using the `750000_delivery_app_channel_integration` bundle inside the `51355` AI-assisted financial-grade development pipeline.

The purpose is to prevent context bloat when implementing delivery app, KDS, DID, kitchen routing, and order ingestion flows.

This file is designed to be a thin rule summary.

It should be injected into Claude or other architecture/audit agents when the implementation target touches:

- delivery app channel intake,
- webhook or polling order ingestion,
- official delivery app API integration,
- POS projection,
- KDS routing,
- KDS station splitting,
- station bump,
- DID callout,
- delivery app customer privacy,
- KDS/DID failure mode,
- field evidence,
- or kitchen runtime KPI.

## 2. Core Rule

```text
Do not inject the whole 750000 bundle by default.

Inject this guide first.
Then inject only the documents selected by the current module tag, impact scope, and risk class.
```

The context snapshot must remain narrow enough for the AI agent to focus on the current implementation without being distracted by unrelated POS, payment, settlement, or UI policy documents.

## 3. Context Budget Levels

| Budget | Use When | Max Context |
|---|---|---|
| LEAN | small design review, prompt prep, naming, context confirmation | this file + 1 target doc |
| NORMAL | typical 51355 Stage 2 design or Stage 5 audit | this file + 3 to 5 selected docs |
| FULL | high-risk runtime implementation, field rollout, privacy/security review | this file + all required docs from the selected risk class |

FULL must be used if the change affects:

- customer personal data,
- official API credential handling,
- HMAC / OAuth / IP allowlist,
- KDS/DID field rollout,
- manual fallback,
- degraded mode,
- audit/evidence packet,
- or production runtime state transition.

## 4. Module Tags

Use these tags in `impact_scope.md`, `context_snapshot.md`, and `change_contract.md`.

```text
DELIVERY_APP_API
ORDER_INGESTION
WEBHOOK_SECURITY
POLLING_SECURITY
POS_PROJECTION
KDS_ROUTING
KDS_STATION_SPLIT
KDS_BUMP_STATE
DID_CALLOUT
CUSTOMER_PRIVACY
DATA_RETENTION
VENDOR_CONNECTOR
FIELD_EVIDENCE
DEGRADED_MODE
MANUAL_FALLBACK
RECOVERY_RECONCILIATION
KITCHEN_KPI
OPERATIONAL_INTELLIGENCE
```

A module may have multiple tags.

The selected tags determine which 750000 documents must be included in the context snapshot.

## 5. Context Slicing Matrix

| Module Tag | Required Context Docs | Exclude By Default |
|---|---|---|
| DELIVERY_APP_API | `750020`, `750030`, `750050`, `750120` | hardware checklist, KPI report |
| ORDER_INGESTION | `750010`, `750020`, `750040`, `750050`, `750070` | vendor ecosystem, KPI report |
| WEBHOOK_SECURITY | `750030`, `750050`, `750120`, `750140` | KDS hardware, vendor market analysis |
| POLLING_SECURITY | `750030`, `750050`, `750120`, `750140` | DID hardware, KPI report |
| POS_PROJECTION | `750040`, `750050`, `750070`, `750140` | vendor ecosystem unless vendor-specific |
| KDS_ROUTING | `750040`, `750070`, `750080`, `750140` | API vendor market analysis |
| KDS_STATION_SPLIT | `750070`, `750080`, `750090`, `750140` | OAuth/HMAC unless API intake also changes |
| KDS_BUMP_STATE | `750070`, `750080`, `750130`, `750140` | vendor ecosystem |
| DID_CALLOUT | `750040`, `750060`, `750070`, `750130`, `750140` | deep API security unless callout source changes |
| CUSTOMER_PRIVACY | `750030`, `750060`, `750120`, `750140` | vendor capability unless procurement is involved |
| DATA_RETENTION | `750060`, `750140`, `750150` | KDS hardware |
| VENDOR_CONNECTOR | `750100`, `750110`, `750120`, `750140` | KPI report unless pilot includes analytics |
| FIELD_EVIDENCE | `750130`, `750140`, `750150` | vendor ecosystem unless field issue is vendor-related |
| DEGRADED_MODE | `750070`, `750120`, `750130`, `750140` | hardware checklist unless device failure involved |
| MANUAL_FALLBACK | `750070`, `750130`, `750140` | vendor matrix unless vendor behavior differs |
| RECOVERY_RECONCILIATION | `750050`, `750130`, `750140`, `750150` | hardware checklist |
| KITCHEN_KPI | `750070`, `750080`, `750140`, `750150` | HMAC/OAuth unless data source changes |
| OPERATIONAL_INTELLIGENCE | `750060`, `750140`, `750150` | hardware checklist unless field rollout |

## 6. Always Include Rules

For any delivery app channel integration context snapshot, always include:

- this file,
- the current target implementation request,
- current `impact_scope.md`,
- current `change_contract.md` if available,
- `CHANGE_ID`,
- allowed files,
- forbidden files,
- allowed operations,
- and the exact selected module tags.

Do not include the whole repository tree unless the task is a migration or global refactor review.

## 7. Never Omit For High-Risk Changes

If the change touches real or production-like customer data, never omit:

- `750060_Policy_Delivery_App_Customer_Privacy_Masking_Tokenization_And_Data_Retention.md`
- `750120_Policy_Delivery_App_Webhook_Polling_HMAC_OAuth_And_IP_Whitelist_Security.md`
- `750140_Evidence_Delivery_App_KDS_DID_Channel_Integration_Verification_And_Field_Test_Packet.md`

If the change touches field rollout, never omit:

- `750090_Checklist_Delivery_App_KDS_DID_Hardware_Environmental_Durability_And_Installation_Readiness.md`
- `750130_Runbook_Delivery_App_KDS_DID_Order_Channel_Failure_Degraded_Mode_And_Manual_Fallback.md`
- `750140_Evidence_Delivery_App_KDS_DID_Channel_Integration_Verification_And_Field_Test_Packet.md`

If the change touches kitchen KPI or BI, never omit:

- `750060_Policy_Delivery_App_Customer_Privacy_Masking_Tokenization_And_Data_Retention.md`
- `750140_Evidence_Delivery_App_KDS_DID_Channel_Integration_Verification_And_Field_Test_Packet.md`
- `750150_Report_Delivery_App_KDS_DID_Kitchen_Runtime_Bottleneck_KPI_And_Operational_Intelligence.md`

## 8. Context Snapshot Template

```markdown
# context_snapshot.md

## Change ID

## Target Module

## Module Tags

## Risk Class

LOW / MEDIUM / HIGH / CRITICAL

## Context Budget

LEAN / NORMAL / FULL

## Included 750000 Documents

| Document | Reason |
|---|---|

## Explicitly Excluded 750000 Documents

| Document | Reason |
|---|---|

## Required Rules Summary

## Privacy / Security Rules

## Evidence Rules

## Raw Log Rules

## CHANGE_ID Traceability Rules

## Notes For Claude

## Notes For Codex

## Notes For Human Approval
```

## 9. Cursor Stage 1 Prompt Add-On

Add this to the Stage 1 Cursor impact search prompt when the target may touch delivery app, KDS, DID, or kitchen runtime.

```text
Also identify the minimum 750000 delivery app channel integration documents required for the next context snapshot.

Do not include the entire 750000 bundle by default.

Return:
- module tags,
- required 750000 documents,
- excluded 750000 documents,
- privacy/security relevance,
- evidence relevance,
- and whether FULL context is required.
```

## 10. Claude Stage 2 Prompt Add-On

Add this to the Stage 2 Claude design prompt.

```text
Use only the selected 750000 context documents.

Do not infer rules from unrelated 750000 documents that were not included.

If the selected context is insufficient, request a context expansion instead of inventing a rule.

Preserve:
- official API only,
- no scraping,
- idempotency,
- signature validation,
- privacy masking,
- DID safe display,
- raw log evidence,
- CHANGE_ID traceability,
- and manual fallback auditability.
```

## 11. Codex Stage 3 Prompt Add-On

Add this to the Codex implementation prompt.

```text
You may not add new delivery app, KDS, DID, or privacy behavior unless it is explicitly allowed in change_contract.md.

Allowed files do not imply allowed operations.

Allowed operations must name the exact function, state branch, migration, test, or configuration field that may be changed.

Do not introduce:
- scraping,
- unofficial API,
- broad connector abstraction,
- unapproved vendor-specific branch,
- customer data persistence,
- DID customer data exposure,
- or silent fallback.
```

## 12. Claude Audit Prompt Add-On

Add this to the Stage 5 Claude audit prompt.

```text
Assume the delivery app channel implementation is wrong.

Find whether this change could cause:
- duplicate KDS card,
- duplicate DID callout,
- order lost between provider and KDS,
- provider unknown state treated as final,
- invalid signature accepted,
- replayed webhook accepted,
- customer phone/address exposed on KDS or DID,
- privacy masking skipped after completion,
- manual fallback without owner,
- field recovery without reconciliation,
- KPI generated from incomplete timestamps,
- or CHANGE_ID traceability failure.
```

## 13. Minimal Context Examples

### 13.1 Webhook Signature Fix

```text
Module Tags:
- DELIVERY_APP_API
- WEBHOOK_SECURITY
- CUSTOMER_PRIVACY

Include:
- 750020
- 750030
- 750060
- 750120
- 750140

Exclude:
- 750090
- 750100
- 750110
- 750150
```

### 13.2 KDS Station Routing Fix

```text
Module Tags:
- KDS_ROUTING
- KDS_STATION_SPLIT
- KDS_BUMP_STATE

Include:
- 750040
- 750070
- 750080
- 750130
- 750140

Exclude:
- 750100
- 750110
- 750150 unless KPI changes
```

### 13.3 DID Privacy Fix

```text
Module Tags:
- DID_CALLOUT
- CUSTOMER_PRIVACY
- DATA_RETENTION

Include:
- 750040
- 750060
- 750070
- 750130
- 750140

Exclude:
- 750090 unless physical DID device behavior is affected
- 750100 unless vendor-specific
```

### 13.4 Kitchen KPI Dashboard Design

```text
Module Tags:
- KITCHEN_KPI
- OPERATIONAL_INTELLIGENCE
- CUSTOMER_PRIVACY

Include:
- 750060
- 750140
- 750150

Exclude:
- 750090
- 750100
- 750110 unless vendor export is part of the change
```

## 14. Block Rules

Block the context snapshot if:

- no module tag is assigned,
- selected documents do not match the module tag,
- customer privacy changes omit `750060`,
- webhook or credential changes omit `750120`,
- field rollout changes omit `750140`,
- KPI/BI changes omit privacy redaction rules,
- Codex receives the whole 750000 bundle without reason,
- Claude is asked to infer from excluded documents,
- or `CHANGE_ID` is missing.

## 15. Relationship To Other 750000 Documents

This guide is the routing document for context selection.

It does not replace the detailed documents.

It points to them only when needed.

## 16. Final Rule

```text
For delivery app channel implementation, context must be sliced, not dumped.

Use this guide first.
Select only the required 750000 documents.
Escalate to FULL context only for high-risk privacy, security, field rollout, or evidence work.
Never let AI infer from documents that were not included.
Never let Codex implement beyond allowed operations.
```
