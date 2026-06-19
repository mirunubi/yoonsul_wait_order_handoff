# 750180_Checklist_Delivery_App_KDS_DID_Pre_Implementation_Claude_Codex_Handoff_Readiness.md

## 1. Purpose

This checklist defines the pre-implementation handoff readiness gate for delivery app, KDS, DID, and kitchen runtime changes.

It is used after Claude design and before Codex implementation inside the `51355` AI-assisted financial-grade development pipeline.

The purpose is to prevent Codex from implementing delivery app or KDS/DID behavior without:

- approved impact scope,
- sliced context snapshot,
- explicit allowed files,
- explicit allowed operations,
- privacy and security rules,
- failure mode coverage,
- raw log requirements,
- and evidence packet requirements.

## 2. Scope

This checklist applies when the change touches any of the following:

- delivery app official API integration,
- webhook / polling intake,
- HMAC / OAuth / API key / IP allowlist,
- order normalization,
- POS projection,
- KDS card creation,
- KDS station routing,
- station bump state,
- assembly / packing state,
- DID callout,
- customer privacy masking,
- degraded mode,
- manual fallback,
- recovery reconciliation,
- field evidence,
- or runtime KPI / BI data.

## 3. Handoff Gate Rule

```text
No Codex implementation may start until this checklist is complete.

If any CRITICAL item is unchecked, return to Claude design or Human approval.
If any approved file lacks an allowed operation, implementation is blocked.
If any high-risk privacy/security item lacks a test and evidence path, implementation is blocked.
```

## 4. Required Input Documents

Before handoff, confirm all required documents exist.

| Document | Required | Status |
|---|---:|---|
| `impact_scope.md` or `750170` packet | Yes | TODO |
| `context_snapshot.md` | Yes | TODO |
| `overview.md` | Yes | TODO |
| `logic.md` | Yes | TODO |
| `test_plan.md` | Yes | TODO |
| `change_contract.md` | Yes | TODO |
| `implementation_approval.md` | Yes | TODO |
| Selected 750000 context docs | Yes | TODO |
| Evidence requirements | Yes | TODO |
| Rollback notes | Yes | TODO |

## 5. CHANGE_ID Readiness

| Check | Required | Status |
|---|---:|---|
| `CHANGE_ID` assigned | Yes | TODO |
| Same `CHANGE_ID` appears in all design docs | Yes | TODO |
| Same `CHANGE_ID` appears in test plan | Yes | TODO |
| Same `CHANGE_ID` appears in evidence plan | Yes | TODO |
| Runtime audit/event naming references `CHANGE_ID` where applicable | Yes | TODO |
| Raw log folder path includes `CHANGE_ID` | Yes | TODO |
| No stale or copied `CHANGE_ID` remains | Yes | TODO |

## 6. Context Snapshot Readiness

Confirm that context was sliced, not dumped.

| Check | Required | Status |
|---|---:|---|
| Module tags are assigned | Yes | TODO |
| Context budget selected: LEAN / NORMAL / FULL | Yes | TODO |
| Selected 750000 docs match module tags | Yes | TODO |
| Excluded docs are explicitly listed | Yes | TODO |
| Claude was not given the whole 750000 bundle without reason | Yes | TODO |
| High-risk triggers escalated to FULL context where needed | Yes | TODO |
| Privacy/security changes include `750060`, `750120`, `750140` | If applicable | TODO |
| Field rollout changes include `750090`, `750130`, `750140` | If applicable | TODO |
| KPI/BI changes include `750060`, `750140`, `750150` | If applicable | TODO |

## 7. Delivery App Channel Readiness

| Check | Required | Status |
|---|---:|---|
| Channel identified | Yes | TODO |
| Connector type identified | Yes | TODO |
| Official API or approved connector confirmed | Yes | TODO |
| Scraping / memory hooking explicitly forbidden | Yes | TODO |
| Webhook or polling mode identified | Yes | TODO |
| Store mapping behavior defined | Yes | TODO |
| Menu / option mapping behavior defined | Yes | TODO |
| Duplicate event handling defined | Yes | TODO |
| Unknown provider state handling defined | Yes | TODO |
| Provider status mapping is explicit | Yes | TODO |

## 8. Security Readiness

| Check | Required | Status |
|---|---:|---|
| Credential type identified | If applicable | TODO |
| Secret storage location approved | If applicable | TODO |
| Secret logging forbidden | If applicable | TODO |
| Signature validation required | If applicable | TODO |
| Timestamp / nonce / replay protection defined | If applicable | TODO |
| OAuth scope checked | If applicable | TODO |
| IP allowlist checked | If applicable | TODO |
| Invalid signature rejection behavior defined | If applicable | TODO |
| Raw authentication log path defined | If applicable | TODO |

## 9. Privacy Readiness

| Check | Required | Status |
|---|---:|---|
| Customer personal data presence identified | Yes | TODO |
| KDS display fields defined | Yes | TODO |
| DID display fields defined | Yes | TODO |
| Phone number display forbidden unless approved | Yes | TODO |
| Full address display forbidden unless approved | Yes | TODO |
| Customer request redaction rule defined | Yes | TODO |
| Evidence packet redaction rule defined | Yes | TODO |
| Raw log redaction rule defined | Yes | TODO |
| Retention / post-completion masking rule defined | Yes | TODO |
| BI / KPI export privacy rule defined if applicable | If applicable | TODO |

## 10. KDS Runtime Readiness

| Check | Required | Status |
|---|---:|---|
| KDS main card creation rule defined | If applicable | TODO |
| Station routing rule defined | If applicable | TODO |
| BOM / recipe splitting rule defined | If applicable | TODO |
| Option routing rule defined | If applicable | TODO |
| Station bump states defined | If applicable | TODO |
| Assembly / packing states defined | If applicable | TODO |
| Duplicate KDS card prevention defined | If applicable | TODO |
| Cancellation after KDS card creation defined | If applicable | TODO |
| Unknown provider state after KDS progress defined | If applicable | TODO |
| Manual override audit rule defined | If applicable | TODO |

## 11. DID Runtime Readiness

| Check | Required | Status |
|---|---:|---|
| DID callout trigger defined | If applicable | TODO |
| DID visible fields defined | If applicable | TODO |
| DID audio callout behavior defined | If applicable | TODO |
| Repeat callout behavior defined | If applicable | TODO |
| Cancelled order removal defined | If applicable | TODO |
| Stale callout expiration defined | If applicable | TODO |
| DID offline fallback defined | If applicable | TODO |
| DID privacy leak test defined | If applicable | TODO |

## 12. Failure Mode Readiness

At least the relevant negative paths must be defined.

| Scenario | Required If Relevant | Status |
|---|---:|---|
| Delivery app API timeout | Yes | TODO |
| Webhook duplicate | Yes | TODO |
| Webhook delayed after retry | Yes | TODO |
| Polling catch-up gap | If polling | TODO |
| Signature failure | If signed API | TODO |
| Store mapping missing | Yes | TODO |
| Menu mapping missing | Yes | TODO |
| POS projection failure | If POS projection | TODO |
| KDS offline | If KDS | TODO |
| DID offline | If DID | TODO |
| Manual fallback | If field runtime | TODO |
| Recovery reconciliation | If degraded mode | TODO |
| Privacy redaction failure | Yes | TODO |

## 13. Allowed Files Readiness

Every file must have an exact allowed operation.

| File | Allowed Operation | Status |
|---|---|---|
| TODO | TODO | TODO |

Rules:

- Allowed file is not broad edit permission.
- Allowed operation must name the function, branch, state transition, migration, test, or config field.
- Unrelated formatting is forbidden.
- Broad refactor is forbidden.
- New abstraction is forbidden unless explicitly approved.
- Generated files are forbidden unless explicitly approved.
- Lock files are forbidden unless explicitly approved.

## 14. Forbidden Files And Operations

Default forbidden:

- unrelated modules,
- generated files,
- lock files,
- production secrets,
- broad configuration changes,
- broad formatters,
- Korean Markdown rewrite,
- migration files unless approved,
- RLS files unless approved,
- vendor credential storage changes unless approved,
- new unofficial API connector,
- scraping code,
- memory hooking code,
- customer PII persistence,
- DID PII exposure,
- silent manual fallback.

## 15. Test Plan Readiness

| Test Area | Required | Status |
|---|---:|---|
| Unit tests | Yes | TODO |
| Integration tests | If runtime path | TODO |
| Webhook / polling tests | If applicable | TODO |
| Signature / replay tests | If applicable | TODO |
| Duplicate order tests | Yes | TODO |
| KDS routing tests | If KDS | TODO |
| Station bump tests | If KDS | TODO |
| DID safe display tests | If DID | TODO |
| Privacy redaction tests | Yes | TODO |
| Manual fallback tests | If fallback | TODO |
| Recovery reconciliation tests | If degraded mode | TODO |
| Evidence packet tests | If field/runtime | TODO |
| Raw log capture checks | Yes | TODO |

## 16. Raw Log Readiness

Required raw logs must be declared before implementation.

| Raw Log | Required | Path |
|---|---:|---|
| `git_diff_stat.log` | Yes | TODO |
| `git_diff_check.log` | Yes | TODO |
| `lint.log` | If applicable | TODO |
| `typecheck.log` | If applicable | TODO |
| `test.log` | Yes | TODO |
| `api_auth.log` | If applicable | TODO |
| `webhook_receive.log` | If applicable | TODO |
| `signature_validation.log` | If applicable | TODO |
| `order_normalization.log` | If applicable | TODO |
| `kds_routing.log` | If applicable | TODO |
| `did_callout.log` | If applicable | TODO |
| `privacy_redaction.log` | Yes | TODO |
| `recovery_reconciliation.log` | If applicable | TODO |

Rules:

- Raw logs must be preserved.
- Secrets must be redacted.
- Customer data must be redacted.
- Failed command output must not be summarized away.
- Missing raw logs block evidence-based approval.

## 17. Evidence Packet Readiness

| Evidence Item | Required | Status |
|---|---:|---|
| API authentication evidence | If applicable | TODO |
| Order intake evidence | Yes | TODO |
| Normalization evidence | Yes | TODO |
| POS projection evidence | If applicable | TODO |
| KDS routing evidence | If applicable | TODO |
| Station bump evidence | If applicable | TODO |
| DID callout evidence | If applicable | TODO |
| Privacy redaction evidence | Yes | TODO |
| Failure mode evidence | Yes | TODO |
| Manual fallback evidence | If applicable | TODO |
| Recovery reconciliation evidence | If applicable | TODO |
| `CHANGE_ID` traceability evidence | Yes | TODO |

## 18. Codex Prompt Readiness

Before Codex implementation, the prompt must include:

- `CHANGE_ID`,
- allowed files,
- allowed operations,
- forbidden files,
- forbidden operations,
- selected context docs only,
- explicit non-goals,
- required tests,
- raw log requirements,
- evidence requirements,
- rollback requirements,
- no scraping,
- no customer PII exposure,
- no broad refactor,
- no unapproved abstraction,
- no changes outside scope.

## 19. Handoff Decision

Choose one:

| Decision | Meaning |
|---|---|
| READY_FOR_CODEX | Codex may implement within allowed operations only. |
| NEEDS_CLAUDE_REVISION | Design/test/evidence requirements incomplete. |
| NEEDS_HUMAN_APPROVAL | File/operation/risk boundary changed. |
| BLOCKED | Privacy/security/runtime/evidence issue prevents implementation. |

## 20. Human Approval Statement

```text
Approved for Codex implementation.

CHANGE_ID:
<CHANGE_ID>

Allowed files:
- <file>

Allowed operations:
- <operation>

Forbidden:
- all other files
- all other operations
- scraping
- unofficial API
- customer PII exposure
- broad refactor
- silent fallback

Required verification:
- <commands>

Required evidence:
- <evidence>

Owner:
<name/date>
```

## 21. Relationship To Other 750000 Documents

This checklist depends on:

- `750160_Guide_Delivery_App_KDS_DID_Context_Snapshot_Rules_Summary_For_51355_Pipeline.md`
- `750170_Template_Delivery_App_KDS_DID_Module_Impact_Scope_And_Context_Slicing_Packet.md`
- `750140_Evidence_Delivery_App_KDS_DID_Channel_Integration_Verification_And_Field_Test_Packet.md`
- `750130_Runbook_Delivery_App_KDS_DID_Order_Channel_Failure_Degraded_Mode_And_Manual_Fallback.md`
- `750120_Policy_Delivery_App_Webhook_Polling_HMAC_OAuth_And_IP_Whitelist_Security.md`
- `750060_Policy_Delivery_App_Customer_Privacy_Masking_Tokenization_And_Data_Retention.md`

## 22. Final Rule

```text
No delivery app KDS/DID implementation starts without handoff readiness.
No handoff is ready without allowed operations.
No privacy or security change is ready without tests and evidence.
No field runtime change is ready without raw logs and fallback plan.
No Codex prompt may exceed approved scope.
```
