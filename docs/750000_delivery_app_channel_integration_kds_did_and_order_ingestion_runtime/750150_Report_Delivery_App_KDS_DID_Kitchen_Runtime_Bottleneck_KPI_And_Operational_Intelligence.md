# 750150_Report_Delivery_App_KDS_DID_Kitchen_Runtime_Bottleneck_KPI_And_Operational_Intelligence.md

## 1. Purpose

This report defines how delivery app channel integration with KDS and DID creates operational intelligence for `yoonsul_wait_order_handoff`.

The core purpose is to convert kitchen runtime events into measurable operational signals.

A delivery app order is not only an order card.
It is also a timestamped runtime trace that can reveal:

- order intake latency,
- channel-specific delay,
- menu preparation time,
- station-level bottleneck,
- assembly delay,
- packing delay,
- DID callout delay,
- rider waiting delay,
- customer pickup delay,
- manual fallback frequency,
- privacy redaction health,
- and field reliability.

## 2. Scope

This report covers runtime intelligence generated from:

- Baemin / Yogiyo / Coupang Eats / partner delivery channel order intake,
- channel adapter authentication and payload acceptance,
- POS projection,
- KDS card creation,
- station routing,
- station bump,
- assembly completion,
- packing completion,
- DID callout,
- rider or customer pickup,
- manual fallback,
- degraded mode,
- recovery reconciliation,
- audit ledger,
- evidence packet,
- and field KPI aggregation.

## 3. Non-Scope

This document does not define:

- payment capture logic,
- refund logic,
- settlement closeout,
- payout logic,
- production dashboard UI implementation,
- AI model training,
- vendor procurement decision,
- or runtime implementation code.

Those require separate approved Flow Bundle documents.

## 4. Core Thesis

Traditional POS data records only the commercial result:

```text
what was sold, when, and for how much
```

Delivery app + KDS + DID runtime data records the operational process:

```text
when the order arrived,
when it was accepted,
where it waited,
which station processed it,
where the bottleneck occurred,
when it was assembled,
when the customer or rider was called,
and whether the order path was recoverable from evidence
```

For a franchise or SaaS operator, this is the difference between sales reporting and kitchen runtime intelligence.

## 5. Event Timeline Model

A single delivery app order should produce the following event timeline.

```text
T0  Provider order created
T1  Channel adapter received order
T2  Signature / credential validation completed
T3  Order normalized
T4  POS projection created
T5  KDS main card created
T6  Station routing completed
T7  Station cooking started or first visible bump state
T8  Station partial complete
T9  All station complete
T10 Assembly ready
T11 Packing ready
T12 DID callout emitted
T13 Customer / rider pickup confirmed
T14 Provider / internal order closeout reconciled
T15 Privacy masking / retention transition completed
```

Every missing timestamp reduces auditability.

Every duplicated timestamp requires duplicate prevention evidence.

Every manually overwritten timestamp requires owner, reason, and audit event.

## 6. Minimum KPI Set

### 6.1 Order Intake KPI

| KPI | Meaning | Risk Revealed |
|---|---|---|
| Channel Intake Latency | Provider creation to adapter receive | API delay, polling gap, webhook delay |
| Authentication Failure Rate | Rejected credential/signature events | secret drift, partner misconfiguration |
| Payload Rejection Rate | Invalid or unmapped payloads | menu mapping gap, channel schema drift |
| Duplicate Event Rate | Repeated webhook/polling payloads | idempotency weakness |
| Manual Intake Rate | Orders manually entered due to failure | integration unreliability |

### 6.2 KDS Runtime KPI

| KPI | Meaning | Risk Revealed |
|---|---|---|
| KDS Card Creation Time | Normalized order to visible KDS card | queue delay, projection bug |
| Station Routing Time | KDS card to station split | routing rule complexity |
| Station Processing Time | Station assigned to station bump | kitchen bottleneck |
| Assembly Waiting Time | Station complete to assembly ready | coordination delay |
| Packing Time | Assembly ready to packing ready | packaging bottleneck |
| Reopen / Undo Rate | Completed card reopened | mistaken bump, unclear UI |
| Manual Override Rate | Human state override frequency | workflow mismatch |

### 6.3 DID And Pickup KPI

| KPI | Meaning | Risk Revealed |
|---|---|---|
| DID Callout Latency | Packing ready to DID callout | front-of-house delay |
| DID Failure Rate | DID callout failed or stale | device/network issue |
| Rider Wait Time | Rider arrival to pickup | prep prediction mismatch |
| Customer Pickup Delay | DID callout to pickup | customer awareness gap |
| Repeat Callout Rate | Repeated DID calls for same order | pickup confusion |
| Stale Display Rate | Old orders still shown | DID expiration weakness |

### 6.4 Privacy And Evidence KPI

| KPI | Meaning | Risk Revealed |
|---|---|---|
| Redaction Pass Rate | Logs/evidence properly masked | privacy control quality |
| Post-Completion Masking Time | Completion to masking | retention compliance |
| Evidence Completeness Rate | Required evidence files present | audit readiness |
| CHANGE_ID Match Rate | Event/evidence ID consistency | traceability health |
| Raw Log Availability | Raw logs available for incidents | reconstructability |

## 7. Bottleneck Classification

Kitchen runtime bottlenecks should be classified by location.

| Bottleneck Class | Description | Example |
|---|---|---|
| Channel Bottleneck | Provider/API/webhook/polling delay | order arrives late from app |
| Adapter Bottleneck | payload validation or mapping delay | menu option unmapped |
| POS Projection Bottleneck | POS view cannot accept or sync order | local POS bridge failure |
| KDS Queue Bottleneck | card created late or duplicated | KDS sync delay |
| Station Bottleneck | one cooking station overloaded | fryer queue too long |
| Assembly Bottleneck | parts ready but not assembled | burger assembly delay |
| Packing Bottleneck | food ready but not sealed/packed | delivery packing delay |
| DID Bottleneck | order ready but not called | DID offline or stale |
| Pickup Bottleneck | rider/customer does not collect | rider arrival mismatch |
| Recovery Bottleneck | unresolved exception not closed | manual fallback not reconciled |

## 8. Runtime KPI Evidence Requirements

KPI must not be based only on UI screenshots or operator impressions.

Acceptable evidence:

- timestamped event logs,
- KDS state transition logs,
- DID callout logs,
- audit ledger events,
- raw API receive logs with redaction,
- normalized order event records,
- manual fallback records,
- recovery reconciliation records,
- field test evidence packet,
- store-level daily closeout report.

Weak evidence:

- staff memory,
- screenshot without timestamp,
- vendor dashboard number without export,
- summarized AI explanation without raw source,
- incomplete CSV without event IDs,
- KDS photo without matching order ID.

## 9. Recommended Operational Dashboard Sections

A future operational dashboard should separate metrics into the following panels.

### 9.1 Channel Health Panel

- order count by channel,
- channel intake latency,
- webhook duplicate count,
- authentication failure count,
- payload rejection count,
- polling catch-up count,
- degraded mode count.

### 9.2 Kitchen Throughput Panel

- average prep time by menu,
- station processing time,
- peak-time station queue length,
- assembly waiting time,
- packing time,
- reopen/undo count,
- manual override count.

### 9.3 Customer / Rider Experience Panel

- DID callout latency,
- repeat callout count,
- pickup delay,
- rider waiting time,
- stale DID entry count,
- missed callout count.

### 9.4 Privacy / Audit Panel

- privacy redaction failures,
- masking completion time,
- evidence completeness,
- raw log availability,
- CHANGE_ID mismatch,
- unresolved manual fallback records.

## 10. Store-Level Daily Closeout Report

Every pilot store or implementation test store should be able to produce a daily closeout report.

Suggested structure:

```markdown
# delivery_app_kds_did_daily_closeout.md

## Store

## Date

## Channel Order Summary

## KDS Runtime Summary

## DID Callout Summary

## Bottleneck Findings

## Privacy / Redaction Findings

## Manual Fallback Events

## Recovery Reconciliation Status

## Evidence Packet Links

## Open Issues

## Owner Sign-Off
```

## 11. Franchise HQ Intelligence Use Cases

KDS/DID runtime data can support franchise-level decisions.

### 11.1 Menu Engineering

Use KDS station timing to identify menus that cause disproportionate station load.

Potential actions:

- simplify option structure,
- change prep sequence,
- pre-batch ingredients,
- adjust menu availability by time band,
- redesign packaging,
- split kitchen station responsibility.

### 11.2 Labor Planning

Use station-level bottleneck and peak-time prep data to determine staffing needs.

Potential actions:

- assign one extra station worker only at specific time bands,
- train staff on bottleneck menu categories,
- separate delivery packing from dine-in assembly,
- redesign station layout.

### 11.3 Rider Coordination

Use predicted completion and actual pickup delay to improve rider dispatch timing.

Potential actions:

- delay rider call when station backlog rises,
- trigger pickup request only after assembly milestone,
- separate rider DID from customer DID,
- provide reliable pickup window to delivery partners.

### 11.4 Store Training

Use KDS data to identify stores with repeated manual overrides, missed bumps, or delayed packing.

Potential actions:

- retrain bump discipline,
- simplify KDS card UI,
- revise station labels,
- change DID callout procedure.

## 12. High-Risk Misuse Cases

Runtime intelligence can become harmful if used without context.

Blocked misuse:

- ranking staff without accounting for menu complexity,
- penalizing stores based only on raw prep time,
- storing customer personal data for analytics,
- exposing phone/address in KPI export,
- treating provider timestamps as always reliable,
- merging channels without preserving source channel identity,
- using AI predictions to finalize orders without kitchen evidence,
- making settlement or payout decisions from KDS data alone.

## 13. Data Retention And Privacy Rules

KPI data must be privacy-minimized.

Rules:

- use internal order IDs or pickup tokens, not customer identifiers,
- remove phone number and address from analytics tables,
- redact special requests where they contain personal data,
- aggregate store-level metrics when individual detail is not needed,
- preserve raw logs only under approved retention and redaction controls,
- never expose customer personal data in BI dashboard exports,
- separate operational timing data from customer identity data.

## 14. Relationship To 750000 Bundle

This report depends on:

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
- `750140_Evidence_Delivery_App_KDS_DID_Channel_Integration_Verification_And_Field_Test_Packet.md`

## 15. Relationship To 51355 Pipeline

When this report is used in an implementation cycle, it should be treated as a context slice for:

- operational KPI requirements,
- evidence packet requirements,
- privacy-safe analytics,
- KDS/DID timing event design,
- and field rollout acceptance criteria.

It must not be used as an authorization to implement dashboards or analytics code without the 51355 approval process.

## 16. Final Rule

```text
KDS/DID runtime data is not just display data.
It is kitchen process evidence.

No operational KPI is accepted without event timestamps.
No bottleneck claim is accepted without source event trace.
No BI export is accepted if it leaks customer personal data.
No store comparison is accepted without context.
No delivery app channel rollout is accepted without evidence-backed runtime intelligence.
```
