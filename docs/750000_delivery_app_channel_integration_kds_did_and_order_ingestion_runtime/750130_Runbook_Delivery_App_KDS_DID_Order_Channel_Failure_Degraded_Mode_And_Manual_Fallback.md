# 750130_Runbook_Delivery_App_KDS_DID_Order_Channel_Failure_Degraded_Mode_And_Manual_Fallback.md

## 1. Purpose

This runbook defines the failure, degraded-mode, and manual fallback procedure for delivery-app order channels connected to POS, API Gateway, KDS, DID, and kitchen runtime flows in `yoonsul_wait_order_handoff`.

The goal is to prevent delivery-app integration failures from becoming:

- lost orders,
- duplicate orders,
- false KDS completion,
- false DID pickup callout,
- privacy leakage,
- provider status mismatch,
- kitchen overload,
- customer or rider misinformation,
- audit/evidence gaps.

This runbook applies to delivery app channels such as Baemin, Yogiyo, Coupang Eats, future delivery partners, order aggregation vendors, POS bridge vendors, KDS vendors, and local fallback operators.

## 2. Scope

In scope:

- Delivery-app API outage.
- Webhook delay or duplicate webhook.
- Polling failure.
- OAuth token expiry.
- HMAC signature verification failure.
- IP whitelist mismatch.
- POS projection delay.
- KDS routing failure.
- Station KDS offline.
- DID callout failure.
- Privacy masking failure.
- Channel adapter degradation.
- Manual order acceptance fallback.
- Evidence capture during incident handling.

Out of scope:

- Runtime code implementation.
- Direct vendor contract negotiation.
- Permanent provider certification.
- Full disaster recovery planning outside delivery-app channel integration.
- Payment settlement reconciliation beyond the delivery-app order channel boundary.

## 3. Operating Principle

Delivery-app channel failure must be handled as a controlled runtime state, not as an ad-hoc field exception.

Core rules:

```text
No silent order loss.
No duplicate kitchen card.
No false DID callout.
No unverified provider status finality.
No customer privacy leakage.
No manual fallback without audit trail.
No recovery without evidence packet.
```

## 4. Severity Levels

| Severity | Condition | Required Action |
|---|---|---|
| S0 | All delivery-app intake unavailable across stores | Enter global degraded mode, block automated completion, escalate owner |
| S1 | One major delivery-app channel unavailable | Channel degraded mode, preserve other channels, notify store operator |
| S2 | One store/KDS/DID path degraded | Store-local fallback, manual KDS/DID handling, evidence capture |
| S3 | Single order uncertain, duplicate, delayed, or malformed | Order hold, manual review, no final customer/rider callout |
| S4 | Non-blocking telemetry or display delay | Monitor, log, no runtime freeze if order safety remains intact |

## 5. Failure Detection Signals

### 5.1 Delivery App API / Webhook

Detect:

- no webhook received within expected interval,
- webhook signature invalid,
- webhook timestamp stale,
- repeated duplicate webhook,
- provider order status missing,
- provider response timeout,
- OAuth token expired,
- refresh token failed,
- IP whitelist rejection,
- API rate limit exceeded.

### 5.2 POS Projection

Detect:

- order accepted by delivery-app channel but not projected to POS,
- POS accepted but KDS card missing,
- store mapping mismatch,
- menu code mismatch,
- tax/service charge mismatch,
- unknown order channel label.

### 5.3 KDS Runtime

Detect:

- main KDS offline,
- station KDS offline,
- routing rule missing,
- station card not created,
- bump event not recorded,
- assembly card stuck,
- kitchen card duplicated,
- same provider order shown twice.

### 5.4 DID Runtime

Detect:

- DID display offline,
- callout queue delayed,
- order number not rendered,
- audio callout failed,
- delivery rider pickup number mismatch,
- DID called before KDS packing complete.

### 5.5 Privacy / Evidence

Detect:

- customer phone/address shown on KDS when not required,
- raw address leaked to DID,
- unmasked data in log,
- evidence packet missing redaction profile,
- incident log missing `CHANGE_ID` or order correlation id.

## 6. Runtime State Model

```text
NORMAL
  ↓
DEGRADED_DETECTED
  ↓
ORDER_INTAKE_GUARDED
  ↓
KDS_FALLBACK_ACTIVE
  ↓
DID_FALLBACK_ACTIVE
  ↓
MANUAL_RECONCILIATION_REQUIRED
  ↓
RECOVERY_VERIFICATION
  ↓
NORMAL_RESTORED
```

Unknown provider state must never be converted directly into success or failure.

## 7. Degraded Mode Entry Criteria

Enter degraded mode when any of the following occurs:

- provider API status cannot be verified,
- webhook signature validation fails,
- duplicate event cannot be safely deduplicated,
- POS/KDS/DID state diverges,
- KDS cannot show a confirmed order,
- DID may call out a wrong order,
- privacy masking cannot be guaranteed,
- field operator must process orders manually.

## 8. Degraded Mode Runtime Rules

When degraded mode is active:

- Continue accepting only orders with verified provider state.
- Mark uncertain orders as `NEEDS_MANUAL_REVIEW`.
- Prevent duplicate KDS card creation by provider order id and idempotency key.
- Disable automatic DID callout for uncertain orders.
- Keep station KDS cards visible only when normalized item mapping is valid.
- Do not expose customer phone/address beyond minimum operational need.
- Record every manual action with actor, timestamp, reason, and evidence reference.
- Preserve raw provider payload in secured/redacted evidence storage where allowed.

## 9. Manual Fallback Procedure

### 9.1 Intake Fallback

1. Confirm whether the delivery-app order exists in the official app/partner console.
2. Record provider order id, channel, store id, displayed menu items, requested time, and current provider status.
3. Do not rely on scraped or unofficial copied data.
4. If POS projection failed, create a manual store-side placeholder only when approved by store operation policy.
5. Mark placeholder as `MANUAL_FALLBACK` and link it to provider order id.

### 9.2 Kitchen Fallback

1. Create a manual KDS card or paper fallback card only after provider order existence is confirmed.
2. Include only kitchen-needed data:
   - order number,
   - item names,
   - options,
   - channel,
   - pickup/delivery marker,
   - allergy or critical request if applicable.
3. Do not include full phone number or full address on kitchen card unless operationally unavoidable and explicitly allowed.
4. Record station routing override if automatic station split failed.
5. Record bump events manually if digital KDS is unavailable.

### 9.3 DID Fallback

1. Do not call customer/rider before packing complete.
2. If DID is offline, call only safe pickup identifier:
   - order number,
   - masked customer name if allowed,
   - delivery channel pickup number.
3. Do not announce phone number, full name, or address.
4. Record manual callout timestamp.

### 9.4 Recovery Fallback

1. Compare provider order list, POS orders, KDS cards, DID callouts, and manual fallback records.
2. Identify missing, duplicate, or unknown orders.
3. Keep unresolved mismatches in `MANUAL_RECONCILIATION_REQUIRED`.
4. Do not close incident until evidence packet is complete.

## 10. Duplicate And Idempotency Rules

Every delivery-app order must be deduplicated by at least:

- channel id,
- provider order id,
- store id,
- normalized order intake timestamp,
- idempotency key if provided,
- internal order correlation id.

Duplicate webhook must update the existing order timeline, not create a new KDS card.

Duplicate manual fallback card must be voided with evidence, not silently deleted.

## 11. DID Safety Rules

DID is customer/rider-facing. Therefore, DID requires stricter finality control.

DID callout is allowed only when:

- provider order exists,
- KDS packing or assembly complete is confirmed,
- order number mapping is verified,
- no duplicate order conflict exists,
- privacy masking is valid,
- callout channel is online or manual callout is logged.

DID callout is forbidden when:

- provider order state is unknown,
- KDS card is duplicated,
- packing state is uncertain,
- order number mapping is ambiguous,
- customer privacy redaction failed.

## 12. Privacy Rules During Incident

During incident handling, privacy risk usually increases because operators copy data manually.

Forbidden:

- screenshots containing full customer address unless secured as evidence,
- posting full phone/address in chat,
- printing full delivery address for kitchen station not needing delivery address,
- exposing customer address on DID,
- storing unredacted provider payload in normal logs.

Required:

- mask phone number,
- mask detailed address after operational need expires,
- separate evidence storage from normal runtime logs,
- record legal/privacy reason for any temporary unmasked access,
- preserve actor and timestamp for manual access.

## 13. Evidence Packet Requirements

Every S0/S1/S2 incident must create evidence packet:

```text
docs/implementation_evidence/<change_id_or_incident_id>/delivery_app_failure/
  01_incident_summary.md
  02_provider_status_snapshot.md
  03_pos_projection_snapshot.md
  04_kds_state_snapshot.md
  05_did_callout_snapshot.md
  06_manual_fallback_log.md
  07_raw_logs_redacted/
  08_reconciliation_result.md
  09_privacy_redaction_check.md
  10_closeout.md
```

Required metadata:

- incident id,
- `CHANGE_ID` if related to implementation,
- channel,
- store id,
- provider order id list,
- affected runtime states,
- owner,
- timestamps,
- final decision,
- unresolved risk if any.

## 14. Raw Log Capture

Raw logs must be collected without AI summarization.

Examples:

```bash
mkdir -p docs/implementation_evidence/<change_id>/raw_logs
npm run lint > docs/implementation_evidence/<change_id>/raw_logs/lint.log 2>&1
npm run typecheck > docs/implementation_evidence/<change_id>/raw_logs/typecheck.log 2>&1
npm test > docs/implementation_evidence/<change_id>/raw_logs/test.log 2>&1
git diff > docs/implementation_evidence/<change_id>/raw_logs/git_diff.patch
```

For delivery-app/KDS/DID incidents, also capture:

```text
provider webhook sample redacted
channel adapter log redacted
POS projection log redacted
KDS event timeline
DID callout timeline
manual fallback operator log
```

## 15. Recovery Verification Checklist

Before returning to normal mode:

- [ ] Provider order list reconciled.
- [ ] POS projection reconciled.
- [ ] KDS cards reconciled.
- [ ] Station bump state reconciled.
- [ ] DID callout list reconciled.
- [ ] Duplicate KDS cards voided with reason.
- [ ] Unknown orders resolved or formally held.
- [ ] Privacy redaction checked.
- [ ] Manual fallback records archived.
- [ ] Raw logs captured.
- [ ] Evidence packet complete.
- [ ] Owner approved normal-mode restoration.

## 16. Escalation Rules

Escalate to owner immediately if:

- duplicate preparation is likely,
- customer/rider may have received false pickup information,
- provider order state cannot be verified,
- customer privacy leak may have occurred,
- payment/order state mismatch is suspected,
- incident affects multiple stores,
- manual fallback exceeds store capacity,
- vendor API is unstable across repeated attempts.

## 17. Prohibited Recovery Behavior

Do not:

- ask Cursor to auto-fix production failure,
- let AI summarize away raw errors,
- delete duplicate KDS card without evidence,
- mark unknown provider order as canceled or completed without proof,
- call DID from unverified state,
- use screen scraping as emergency workaround,
- store customer address in normal logs,
- close incident without reconciliation result.

## 18. 51355 Pipeline Hook

For any code or configuration change arising from this runbook:

- Stage 1 Cursor must search affected source, route, adapter, POS projection, KDS, DID, test, policy, and evidence files.
- Stage 1 must include the relevant 750000 delivery-app rule summary as a context snapshot candidate.
- Stage 2 Claude must create or update `overview.md`, `logic.md`, `test_plan.md`, and `change_contract.md`.
- `change_contract.md` must define both allowed files and allowed operations.
- Stage 4 verification must preserve raw logs and git diff.
- Stage 5 Claude audit must check delivery-app duplicate, privacy, KDS, DID, and evidence risks.
- Human approval is required before merge or release.

## 19. Related Documents

- `750000_Index_Delivery_App_Channel_Integration_KDS_DID_And_Order_Ingestion_Runtime.md`
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
- `51355_Guide_AI_Assisted_Financial_Grade_Development_Pipeline_Cursor_Claude_Codex_Automated_Gate_And_Human_Merge.md`

## 20. Final Rule

Delivery-app KDS/DID fallback is allowed only as a controlled, logged, privacy-safe, and reconciled degraded runtime mode.

Manual fallback is not a bypass.

It is a governed recovery path.
