# 750140_Evidence_Delivery_App_KDS_DID_Channel_Integration_Verification_And_Field_Test_Packet.md

## 1. Purpose

This evidence packet defines the verification and field-test evidence requirements for delivery app channel integration with POS, API Gateway, KDS, DID, kitchen routing, and manual fallback runtime.

This document belongs to the `750000_delivery_app_channel_integration` bundle under `700000_runtime_flow_bundle`.

The goal is to ensure that delivery app orders are accepted, normalized, routed, displayed, completed, called out, redacted, logged, and reconciled with enough evidence to support:

- field rollout,
- vendor acceptance,
- security review,
- privacy review,
- operational audit,
- incident reconstruction,
- rollback decision,
- and future implementation handoff through the `51355` development pipeline.

## 2. Scope

This evidence packet applies to delivery app channel flows involving:

- delivery app official API connection,
- channel adapter authentication,
- webhook or polling intake,
- HMAC / OAuth / API key verification,
- IP allowlist verification where applicable,
- order normalization,
- POS projection,
- KDS card creation,
- kitchen station routing,
- bump / assembly / packing transitions,
- DID customer or rider callout,
- customer privacy masking,
- tokenization and retention control,
- degraded mode,
- manual fallback,
- recovery reconciliation,
- audit ledger,
- raw logs,
- and field test sign-off.

## 3. Non-Scope

This packet does not approve:

- unofficial scraping,
- memory hooking,
- undocumented private API usage,
- customer personal data long-term storage,
- direct runtime implementation,
- production release without separate approval,
- payment capture or refund logic,
- settlement closeout,
- or provider certification by assumption.

## 4. Required Evidence Folder Structure

Recommended evidence folder:

```text
docs/implementation_evidence/<CHANGE_ID>/
  delivery_app_channel/
    00_manifest.md
    01_context_snapshot.md
    02_impact_scope.md
    03_test_plan.md
    04_api_authentication_evidence.md
    05_order_intake_evidence.md
    06_kds_routing_evidence.md
    07_did_callout_evidence.md
    08_privacy_redaction_evidence.md
    09_failure_degraded_mode_evidence.md
    10_recovery_reconciliation_evidence.md
    11_vendor_field_test_evidence.md
    12_raw_log_index.md
    raw_logs/
      api_auth.log
      webhook_receive.log
      polling_receive.log
      signature_validation.log
      order_normalization.log
      pos_projection.log
      kds_routing.log
      station_bump.log
      did_callout.log
      privacy_redaction.log
      failure_mode.log
      recovery_reconciliation.log
```

## 5. Evidence Manifest Requirements

`00_manifest.md` must include:

| Field | Required | Notes |
|---|---:|---|
| Change ID | Yes | Must match all runtime evidence. |
| Store / Test Store ID | Yes | Use masked or synthetic identifier if needed. |
| Channel | Yes | Baemin / Yogiyo / Coupang Eats / partner gateway / simulator. |
| Vendor / Adapter | Yes | POS, KDS, DID, order aggregator, or custom adapter. |
| Test Date | Yes | Include timezone. |
| Test Owner | Yes | Human owner, not AI-only. |
| Environment | Yes | local / staging / pilot / production-like. |
| Personal Data Used | Yes | synthetic / masked / real approved. |
| Raw Log Path | Yes | Must point to `raw_logs/`. |
| Approval Status | Yes | PASS / FAIL / BLOCKED / FIELD_RETEST_REQUIRED. |

## 6. CHANGE_ID Traceability Rule

Every evidence file must include the same `CHANGE_ID`.

The following artifacts must match:

- `context_snapshot.md`,
- `impact_scope.md`,
- `test_plan.md`,
- API authentication log,
- order intake event,
- normalized order object,
- POS projection event,
- KDS routing event,
- station bump event,
- DID callout event,
- privacy redaction event,
- recovery reconciliation result,
- audit ledger entry,
- final field test sign-off.

If any artifact has a missing, inconsistent, duplicated, or stale `CHANGE_ID`, the evidence packet is blocked.

## 7. Official API Integration Evidence

### 7.1 Required Proof

The evidence packet must prove that the delivery app order was received through an approved channel.

Acceptable sources:

- official platform API,
- approved partner gateway,
- approved vendor connector,
- documented local bridge approved by the provider,
- controlled simulator that matches the official payload contract.

Blocked sources:

- scraping,
- screen capture parsing,
- memory hooking,
- undocumented endpoint,
- manual copy of customer data,
- local database sniffing,
- direct credential reuse outside approved adapter.

### 7.2 Authentication Evidence

Record:

```markdown
## API Authentication Evidence

- Channel:
- Adapter:
- Credential Type:
- Credential Storage Location:
- Secret Exposed In Logs: YES / NO
- Signature Verified: PASS / FAIL / N/A
- OAuth Token Scope Verified: PASS / FAIL / N/A
- IP Allowlist Verified: PASS / FAIL / N/A
- Replay Protection Verified: PASS / FAIL / N/A
- Raw Log Path:
```

## 8. Order Intake Evidence

The order intake test must prove that the system can receive a delivery app order and create a normalized internal event without losing required operational fields or over-retaining personal data.

Required evidence:

- raw provider payload sample with redaction,
- normalized order object sample,
- channel order ID,
- internal order ID,
- store mapping result,
- menu mapping result,
- option mapping result,
- customer request handling,
- pickup / delivery type,
- expected prep time if available,
- duplicate detection result,
- idempotency key result,
- unknown payload field handling,
- rejection reason if rejected.

## 9. KDS Routing Evidence

KDS routing evidence must show that the order reached the correct KDS view and, where applicable, the correct kitchen station.

Required evidence:

| Evidence Item | Required |
|---|---:|
| KDS main card created | Yes |
| Station split result | Yes |
| BOM / recipe mapping result | If applicable |
| Menu option routing result | Yes |
| Out-of-stock handling | If applicable |
| Priority / SLA timer displayed | Yes |
| Duplicate card prevented | Yes |
| Card state synchronized | Yes |
| Raw KDS event log path | Yes |

## 10. Station Bump And Assembly Evidence

The evidence must prove that a bump action changes only the intended state.

Required bump scenarios:

- station partial complete,
- all station complete,
- assembly ready,
- packing ready,
- final ready for pickup,
- mistaken duplicate bump,
- bump after cancellation,
- bump when channel status is unknown,
- bump during degraded mode.

Blocked behavior:

- marking provider order completed before kitchen completion evidence,
- calling DID before final ready state,
- losing station-level completion history,
- hiding manual override without audit event.

## 11. DID Callout Evidence

DID callout evidence must show that the customer or rider-facing display receives only safe and necessary information.

Required DID evidence:

- callout trigger event,
- callout order number or pickup token,
- no full customer name unless approved,
- no phone number,
- no full address,
- audio callout behavior if enabled,
- repeat callout behavior,
- cancelled order removal,
- stale callout expiration,
- DID offline fallback.

## 12. Privacy Redaction Evidence

Privacy evidence must prove that customer data is minimized, masked, tokenized, and retained only for the approved period.

Required checks:

```markdown
## Privacy Evidence

- Phone number visible on KDS: YES / NO
- Full address visible on KDS: YES / NO
- Phone number visible on DID: YES / NO
- Full address visible on DID: YES / NO
- Customer request redacted where needed: PASS / FAIL
- Log redaction profile applied: PASS / FAIL
- Evidence packet redaction applied: PASS / FAIL
- Retention timer configured: PASS / FAIL
- Post-completion masking verified: PASS / FAIL
- Privileged export blocked or approved: PASS / FAIL
```

Any failure in DID or log privacy redaction blocks the packet.

## 13. Failure And Degraded Mode Evidence

The packet must include failure scenarios, not only happy path.

Required failure tests:

| Scenario | Required Evidence |
|---|---|
| Delivery app API timeout | raw log, retry behavior, no duplicate order |
| Webhook duplicate | duplicate prevention log |
| Webhook delay | state reconciliation log |
| Polling gap | catch-up behavior |
| Signature failure | rejection log |
| Store mapping missing | quarantine / rejection evidence |
| Menu mapping missing | manual review evidence |
| KDS offline | fallback kitchen ticket or manual mode evidence |
| DID offline | manual callout fallback evidence |
| POS projection failure | hold / retry / rejection evidence |
| Privacy redaction failure | block evidence |
| Manual fallback used | human owner and timestamp |

## 14. Recovery Reconciliation Evidence

After degraded mode or failure, recovery must prove that the system did not lose, duplicate, or falsely complete orders.

Required reconciliation fields:

- provider channel order ID,
- internal order ID,
- KDS card ID,
- DID callout ID,
- final provider status,
- final internal status,
- manual fallback flag,
- duplicate prevention result,
- unresolved exception flag,
- owner,
- closeout timestamp.

## 15. Raw Log Requirements

Raw logs must not be summarized away.

Required raw log rules:

- store raw logs under `raw_logs/`,
- preserve command output,
- preserve timestamps,
- redact secrets,
- redact customer personal data,
- never paste raw secrets into Markdown,
- record failed commands exactly,
- record tool versions where possible,
- include `git diff --stat` and `git diff --check` when code changes are involved.

Recommended command examples:

```bash
git diff --stat > docs/implementation_evidence/<CHANGE_ID>/delivery_app_channel/raw_logs/git_diff_stat.log
git diff --check > docs/implementation_evidence/<CHANGE_ID>/delivery_app_channel/raw_logs/git_diff_check.log

npm run lint > docs/implementation_evidence/<CHANGE_ID>/delivery_app_channel/raw_logs/lint.log 2>&1
npm run typecheck > docs/implementation_evidence/<CHANGE_ID>/delivery_app_channel/raw_logs/typecheck.log 2>&1
npm test > docs/implementation_evidence/<CHANGE_ID>/delivery_app_channel/raw_logs/test.log 2>&1
```

## 16. Field Test Checklist

### 16.1 Pre-Test

- [ ] Test store selected.
- [ ] Test channel selected.
- [ ] Provider/vendor approval confirmed.
- [ ] Synthetic or approved data prepared.
- [ ] KDS device installed.
- [ ] DID device installed.
- [ ] Network checked.
- [ ] Timezone checked.
- [ ] Raw log folder created.
- [ ] Rollback plan prepared.

### 16.2 Happy Path

- [ ] Delivery app order received.
- [ ] Order normalized.
- [ ] POS projection created.
- [ ] KDS card created.
- [ ] Correct station routing shown.
- [ ] Bump works.
- [ ] Assembly state works.
- [ ] Packing state works.
- [ ] DID callout works.
- [ ] Audit ledger event written.
- [ ] Evidence file written.

### 16.3 Negative Path

- [ ] Duplicate order does not create duplicate KDS card.
- [ ] Duplicate webhook does not double-call DID.
- [ ] Signature failure is rejected.
- [ ] Unknown provider state is held, not finalized.
- [ ] KDS offline fallback works.
- [ ] DID offline fallback works.
- [ ] Manual fallback is auditable.
- [ ] Privacy redaction holds in failure logs.

## 17. Evidence Decision

The field test packet may produce one of four decisions:

| Decision | Meaning |
|---|---|
| PASS | Evidence complete and no blocking issue remains. |
| PASS_WITH_NOTES | Minor non-blocking issues documented. |
| FIELD_RETEST_REQUIRED | Field behavior uncertain or partial evidence missing. |
| BLOCKED | Security, privacy, duplicate, state, or evidence failure found. |

## 18. Block Criteria

Block the packet if:

- unofficial scraping or memory hooking is used,
- provider authorization is unclear,
- API secrets appear in logs,
- signature validation is missing where required,
- duplicate order creates duplicate KDS card,
- unknown provider state is treated as final success,
- KDS/DID displays unnecessary customer personal data,
- post-completion masking cannot be proven,
- manual fallback has no owner or timestamp,
- recovery reconciliation is missing,
- raw logs are absent,
- `CHANGE_ID` mapping fails,
- or audit/evidence cannot reconstruct the order path.

## 19. Relationship To Other 750000 Documents

This evidence packet depends on:

- `750010_Assessment_Delivery_App_Channel_API_KDS_DID_And_Omnichannel_Order_Ingestion_Architecture.md`
- `750020_Guide_Delivery_App_API_KDS_DID_Integration_Context_Summary.md`
- `750030_Policy_Delivery_App_Official_API_Integration_And_No_Scraping_Boundary.md`
- `750040_Boundary_POS_API_Gateway_KDS_DID_And_Kitchen_Runtime_Responsibility.md`
- `750050_Matrix_Delivery_App_POS_KDS_DID_Channel_Integration_Map.md`
- `750060_Policy_Delivery_App_Customer_Privacy_Masking_Tokenization_And_Data_Retention.md`
- `750070_SOP_Delivery_App_Order_Intake_KDS_Routing_Bump_And_DID_Callout_Runtime.md`
- `750080_Logic_Delivery_App_KDS_Smart_Routing_Station_Splitting_BOM_And_Assembly_State_Machine.md`
- `750090_Checklist_Delivery_App_KDS_DID_Hardware_Environmental_Durability_And_Installation_Readiness.md`
- `750100_Assessment_Delivery_App_KDS_DID_Vendor_Ecosystem_Smartcast_Foodtech_Toss_Mate_OKPOS_And_Loyverse.md`
- `750110_Matrix_Delivery_App_KDS_DID_Vendor_Capability_API_Channel_Hardware_And_Target_Market.md`
- `750120_Policy_Delivery_App_Webhook_Polling_HMAC_OAuth_And_IP_Whitelist_Security.md`
- `750130_Runbook_Delivery_App_KDS_DID_Order_Channel_Failure_Degraded_Mode_And_Manual_Fallback.md`

## 20. Final Rule

```text
No delivery app KDS/DID integration is accepted without field evidence.
No field evidence is accepted without raw logs.
No raw log is accepted if it exposes secrets or customer personal data.
No DID callout is accepted if it leaks customer information.
No recovered order is accepted without reconciliation.
No implementation is accepted if CHANGE_ID traceability breaks.
```
