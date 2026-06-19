# 750170_Template_Delivery_App_KDS_DID_Module_Impact_Scope_And_Context_Slicing_Packet.md

## 1. Purpose

This template defines the combined impact scope and context slicing packet for delivery app, KDS, DID, and kitchen runtime modules.

It is designed for use in the `51355` AI-assisted financial-grade development pipeline.

The packet is created after Cursor Stage 1 impact search and before Claude Stage 2 design.

Its purpose is to prevent broad context dumping by converting Cursor findings into a narrow, auditable, module-specific context snapshot.

## 2. When To Use

Use this template when a change touches any of the following:

- delivery app channel API,
- webhook or polling order intake,
- official API authentication,
- HMAC / OAuth / IP allowlist,
- POS projection,
- KDS order card creation,
- KDS station routing,
- station bump state,
- assembly or packing state,
- DID customer or rider callout,
- customer privacy masking,
- tokenization or data retention,
- degraded mode,
- manual fallback,
- recovery reconciliation,
- field evidence,
- or kitchen runtime KPI.

## 3. Packet Output Name

Recommended file name:

```text
docs/implementation_evidence/<CHANGE_ID>/01_delivery_app_kds_did_impact_scope_and_context_slicing_packet.md
```

For early planning only:

```text
docs/planning/<CHANGE_ID>/delivery_app_kds_did_context_slicing_packet.md
```

## 4. Packet Template

```markdown
# delivery_app_kds_did_impact_scope_and_context_slicing_packet.md

## 1. Change ID

`<CHANGE_ID>`

## 2. Change Summary

Describe the requested change in one paragraph.

## 3. Target Runtime Flow

Select all that apply:

- [ ] Delivery app API intake
- [ ] Webhook receive
- [ ] Polling receive
- [ ] Signature / credential verification
- [ ] Order normalization
- [ ] Store mapping
- [ ] Menu / option mapping
- [ ] POS projection
- [ ] KDS main card creation
- [ ] KDS station routing
- [ ] Station bump
- [ ] Assembly / packing
- [ ] DID callout
- [ ] Customer privacy masking
- [ ] Manual fallback
- [ ] Recovery reconciliation
- [ ] Runtime KPI / BI
- [ ] Evidence packet

## 4. Module Tags

Use tags from `750160`.

```text
<DELIVERY_APP_API>
<ORDER_INGESTION>
<WEBHOOK_SECURITY>
<KDS_ROUTING>
<DID_CALLOUT>
<CUSTOMER_PRIVACY>
```

## 5. Risk Class

Choose one:

```text
LOW / MEDIUM / HIGH / CRITICAL
```

### Risk Escalation Triggers

Mark all that apply:

- [ ] Real or production-like customer personal data
- [ ] API credential handling
- [ ] HMAC / OAuth / IP allowlist
- [ ] Webhook replay / duplicate prevention
- [ ] KDS field rollout
- [ ] DID customer/rider display
- [ ] Manual fallback
- [ ] Degraded mode
- [ ] Recovery reconciliation
- [ ] Runtime KPI / BI export
- [ ] Audit / evidence path
- [ ] Production release

## 6. Cursor Impact Scope

### 6.1 Candidate Affected Source Files

| File | Reason | Direct / Indirect |
|---|---|---|

### 6.2 Candidate Affected Test Files

| File | Test Type | Existing / Missing |
|---|---|---|

### 6.3 Candidate Affected SQL / Migration / RLS Files

| File | Reason | Risk |
|---|---|---|

### 6.4 Candidate Affected Runtime Config Files

| File | Reason | Secret / Non-Secret |
|---|---|---|

### 6.5 Candidate Affected Docs

| Document | Reason |
|---|---|

## 7. Delivery App Channel Mapping

| Field | Value |
|---|---|
| Channel | Baemin / Yogiyo / Coupang Eats / partner gateway / simulator |
| Connector Type | official API / approved bridge / vendor gateway |
| Intake Mode | webhook / polling / local bridge / simulator |
| Credential Type | HMAC / OAuth / API key / vendor token / N/A |
| Store Mapping Required | YES / NO |
| Menu Mapping Required | YES / NO |
| Personal Data Present | YES / NO |
| DID Output Affected | YES / NO |
| Field Device Affected | YES / NO |

## 8. Required 750000 Context Documents

| Document | Required? | Reason |
|---|---:|---|
| 750010 Assessment | YES / NO | |
| 750020 Context Summary | YES / NO | |
| 750030 Official API / No Scraping Policy | YES / NO | |
| 750040 Runtime Responsibility Boundary | YES / NO | |
| 750050 Channel Integration Matrix | YES / NO | |
| 750060 Privacy / Masking / Retention Policy | YES / NO | |
| 750070 Runtime SOP | YES / NO | |
| 750080 Smart Routing State Machine Logic | YES / NO | |
| 750090 Hardware Readiness Checklist | YES / NO | |
| 750100 Vendor Ecosystem Assessment | YES / NO | |
| 750110 Vendor Capability Matrix | YES / NO | |
| 750120 Webhook / HMAC / OAuth Security Policy | YES / NO | |
| 750130 Failure / Degraded Mode Runbook | YES / NO | |
| 750140 Field Evidence Packet | YES / NO | |
| 750150 Runtime KPI Report | YES / NO | |
| 750160 Context Snapshot Rules Summary | YES | Always include |

## 9. Explicitly Excluded Context Documents

| Document | Exclusion Reason |
|---|---|

Rules:

- Exclusion must be intentional.
- Excluded documents must not be inferred from by AI.
- If an omitted document becomes necessary, return to context expansion before design.

## 10. Context Budget Decision

Choose one:

```text
LEAN / NORMAL / FULL
```

### Budget Rationale

Explain why this budget is sufficient.

### FULL Required?

```text
YES / NO
```

If YES, explain the high-risk trigger.

## 11. Allowed Files

| File | Allowed Operation |
|---|---|

Allowed file does not imply broad edit permission.

Each row must include the exact allowed operation.

## 12. Forbidden Files

| File / Pattern | Reason |
|---|---|

Default forbidden unless explicitly approved:

- unrelated modules,
- generated files,
- lock files,
- Korean Markdown docs,
- secrets files,
- production config,
- migration files unless approved,
- broad formatter changes.

## 13. Allowed Operations

| Operation ID | File | Exact Allowed Operation | Limit |
|---|---|---|---|

Example:

| Operation ID | File | Exact Allowed Operation | Limit |
|---|---|---|---|
| OP-001 | `src/channel/baemin_webhook.ts` | Add signature timestamp validation branch inside `verifyBaeminWebhook()` | No new abstraction |
| OP-002 | `test/channel/baemin_webhook_test.ts` | Add replay attack test case | Test only |

## 14. Forbidden Operations

- [ ] Create broad connector abstraction
- [ ] Introduce unofficial API branch
- [ ] Add scraping / screen parsing / memory hooking
- [ ] Store customer phone or address in analytics
- [ ] Display phone/address on DID
- [ ] Treat provider unknown state as final
- [ ] Auto-finalize order without KDS evidence
- [ ] Hide manual fallback from audit log
- [ ] Modify unrelated formatting
- [ ] Run formatter on broad tree
- [ ] Modify files outside approval

## 15. Required Tests

| Test | Required? | Target File | Notes |
|---|---:|---|---|
| Official API intake | YES / NO | | |
| Signature validation | YES / NO | | |
| Replay prevention | YES / NO | | |
| Duplicate webhook | YES / NO | | |
| Store mapping failure | YES / NO | | |
| Menu mapping failure | YES / NO | | |
| KDS routing | YES / NO | | |
| Station bump | YES / NO | | |
| DID safe display | YES / NO | | |
| Privacy redaction | YES / NO | | |
| Manual fallback | YES / NO | | |
| Recovery reconciliation | YES / NO | | |
| Evidence packet | YES / NO | | |

## 16. Required Raw Logs

| Raw Log | Required? | Path |
|---|---:|---|
| git_diff_stat.log | YES / NO | |
| git_diff_check.log | YES / NO | |
| lint.log | YES / NO | |
| typecheck.log | YES / NO | |
| test.log | YES / NO | |
| api_auth.log | YES / NO | |
| webhook_receive.log | YES / NO | |
| signature_validation.log | YES / NO | |
| kds_routing.log | YES / NO | |
| did_callout.log | YES / NO | |
| privacy_redaction.log | YES / NO | |
| recovery_reconciliation.log | YES / NO | |

## 17. Privacy And Security Notes

### Customer Data Present?

```text
YES / NO
```

### Required Redaction

- [ ] phone number
- [ ] full address
- [ ] customer name
- [ ] customer request
- [ ] delivery memo
- [ ] rider contact
- [ ] API secret
- [ ] OAuth token
- [ ] HMAC secret
- [ ] vendor token

### DID Safety Rule

State what may be shown on DID.

## 18. Evidence Requirements

Required evidence:

- [ ] API authentication evidence
- [ ] order intake evidence
- [ ] normalization evidence
- [ ] POS projection evidence
- [ ] KDS routing evidence
- [ ] station bump evidence
- [ ] DID callout evidence
- [ ] privacy redaction evidence
- [ ] degraded mode evidence
- [ ] manual fallback evidence
- [ ] recovery reconciliation evidence
- [ ] CHANGE_ID traceability evidence

## 19. Loopback Decision

Return to Stage 1 if:

- affected files are incomplete,
- a new vendor branch is discovered,
- a migration/RLS file appears,
- a new KDS/DID device path appears,
- required 750000 docs were omitted.

Return to Stage 2 if:

- state logic is unclear,
- privacy handling is unclear,
- fallback behavior is unclear,
- evidence requirements are incomplete.

Return to Human Approval if:

- allowed files must expand,
- allowed operations must expand,
- real customer data is involved,
- production config is touched,
- vendor credential handling changes.

## 20. Approval Statement

```text
Approved for Claude Stage 2 design.

Approved 750000 context documents:
- <doc>

Approved module tags:
- <tag>

Approved files:
- <file>

Approved operations:
- <operation>

Forbidden:
- all other files and operations unless re-approved.
```
```

## 5. Operator Notes

This packet should be filled by Cursor output plus human review.

Cursor may search and list candidates, but must not decide approval.

Claude may use the packet for design, but must not infer from excluded documents.

Codex may implement only after the packet is converted into `change_contract.md` and approved.

## 6. Final Rule

```text
No delivery app KDS/DID implementation enters design without impact scope.
No impact scope enters design without context slicing.
No context slicing is valid without module tags.
No allowed file is valid without allowed operation.
No field change is valid without evidence requirements.
```
