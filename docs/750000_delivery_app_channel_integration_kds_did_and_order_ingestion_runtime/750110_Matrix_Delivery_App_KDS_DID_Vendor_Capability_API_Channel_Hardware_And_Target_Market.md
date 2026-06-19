# 750110_Matrix_Delivery_App_KDS_DID_Vendor_Capability_API_Channel_Hardware_And_Target_Market.md

## 1. Purpose

This matrix compares delivery app, KDS, DID, POS, and kitchen automation vendor capabilities for the `yoonsul_wait_order_handoff` 750000 delivery app channel integration domain.

The goal is not to select a vendor immediately.

The goal is to define a reusable evaluation matrix that can be used when assessing whether a delivery app / KDS / DID / POS integration partner is safe enough for financial-grade and operations-grade runtime flow implementation.

This document supports:

- delivery app channel integration planning;
- official API and no-scraping enforcement;
- KDS / DID installation readiness;
- vendor due diligence;
- runtime flow bundle mapping;
- 51355 pipeline context slicing;
- implementation handoff and audit review.

## 2. Scope

This matrix covers vendors or solution categories that may participate in the following chain:

```text
Delivery App / Channel
  -> Channel Adapter
  -> API Gateway
  -> POS Projection
  -> KDS Runtime
  -> Station KDS
  -> Assembly / Packing
  -> DID / Pickup Display
  -> Audit / Evidence / KPI
```

The matrix covers:

- supported delivery channels;
- official API integration posture;
- authentication and signature model;
- KDS routing capability;
- DID callout capability;
- hardware durability;
- privacy and masking controls;
- evidence export;
- outage fallback;
- target market fit;
- adoption risk.

## 3. Non-Scope

This document does not:

- approve any vendor contract;
- certify any vendor as production-ready;
- define final commercial pricing;
- replace legal review;
- replace security review;
- replace personal information protection review;
- implement any API integration;
- define database schema or Flutter screens.

## 4. Vendor Capability Classification

Vendor capability must be classified using the following tiers.

| Class | Meaning | Runtime Use |
|---|---|---|
| Class A | Official API, structured order data, KDS/DID support, evidence export, privacy controls | Candidate for controlled implementation |
| Class B | Official or semi-official integration with some manual fallback or limited evidence | Candidate for pilot only |
| Class C | Mostly local bridge, weak evidence, limited API guarantees | Use only with strict containment |
| Blocked | scraping, memory hooking, credential sharing, unapproved data replication, weak privacy boundary | Do not integrate |

## 5. Core Vendor Evaluation Matrix

| Vendor / Solution Type | Channel Coverage | API Posture | KDS Capability | DID Capability | Hardware Posture | Evidence / KPI | Privacy Controls | Target Fit | Initial Class |
|---|---|---|---|---|---|---|---|---|---|
| Smartcast / DeepKDS-like enterprise KDS | Delivery app, kiosk, POS, multi-channel | API hub / official partner posture required | Strong station routing, channel merge, kitchen KPI | Strong pickup display integration | Dedicated KDS/DID hardware or managed tablets | Strong if timestamp export exists | Must verify masking and retention | Enterprise franchise, multi-store | Class A candidate |
| Foodtech-like delivery order hub | Delivery apps, delivery agencies, POS/KDS | Official API gateway posture required | Depends on downstream KDS | Depends on downstream DID | Usually software / gateway oriented | Strong if order relay logs are exportable | Must verify channel-specific PII handling | Delivery-heavy stores, multi-brand | Class A/B candidate |
| Toss POS / lightweight POS KDS | POS, app-based KDS, delivery channel connection | Official integrations or partner bridge required | Medium; simple KDS sync and status UI | Medium; depends on display product | App-based tablet/PC posture | Medium; needs export verification | Must verify masking and log retention | SMB, early franchise, pilot | Class B candidate |
| Mate POS / KDS-like app solution | POS, KDS, DID, QR/order channel | App and partner integration posture required | Medium/strong for multi-brand and badges | Medium/strong if DID is native | Tablet/app-based | Medium; needs audit packet export check | Must verify PII redaction | shared kitchen, delivery-first stores | Class B candidate |
| OKPOS delivery manager-like POS ecosystem | POS, delivery app, delivery agency, KDS | POS plugin / official channel module required | Medium/strong depending on configuration | Depends on DID module | POS-terminal dependent | Medium; needs controlled export | Must verify PII storage and masking | broad Korean POS estate | Class A/B candidate |
| Loyverse-like lightweight KDS | POS + local network KDS | Cloud account/local network sync | Basic station grouping | Limited/native only if supported | Tablet-based | Limited unless exported | Must verify local device retention | small independent store | Class C / pilot only |
| Legacy printer-port bridge | Delivery app PC client, virtual printer, ESC/POS parse | Transitional bridge, not strategic | Weak/medium, parser-dependent | Weak/medium | Existing POS printer path | Weak unless separately logged | High risk if raw receipt contains PII | temporary compatibility only | Class C containment |
| Screen scraping / memory hooking | Any visible app screen | Unofficial / prohibited | Unreliable | Unreliable | N/A | Weak or absent | High violation risk | none | Blocked |

## 6. API And Authentication Capability Matrix

| Capability | Required Standard | Acceptable | High Risk | Blocked |
|---|---|---|---|---|
| Official API | Written partner/API approval | documented official partner API | undocumented local bridge | scraping / memory hooking |
| Credential model | merchant-authorized token or partner key | scoped API key with rotation | shared store password | raw account credential sharing |
| Signature | HMAC, OAuth2, signed webhook, timestamped request | static key with IP allowlist | long-lived unrotated token | unsigned payload from unknown origin |
| Webhook handling | idempotent, signed, replay-protected | signed but limited replay protection | polling-only without idempotency | blind accept |
| IP control | allowlist or network policy where applicable | vendor-managed source controls | unknown source IP | public unauthenticated endpoint |
| Secret storage | server-side vault / env-managed secret | encrypted config | local plaintext config | secret in code/docs/logs |
| Token rotation | documented rotation procedure | manual rotation | ad hoc rotation | no rotation |

## 7. KDS Runtime Capability Matrix

| Capability | Required For Production | Pilot Acceptable | Not Acceptable |
|---|---|---|---|
| Structured order object | menu code, option code, quantity, channel, promise time | menu text and option text only | receipt screenshot or raw image only |
| Station routing | configurable by menu/BOM/station | simple category routing | no routing |
| Bump event | station bump and assembly bump captured separately | single complete event | no state event |
| State machine | explicit accepted / cooking / station done / assembly / packed / called | limited accepted / done | text-only status |
| Duplicate prevention | idempotency key by channel order ID | best-effort duplicate filter | no duplicate handling |
| Timeout handling | delayed/stale order state visible | manual alert only | silent failure |
| Offline behavior | degraded mode and reconciliation | manual print fallback | data loss |
| Evidence | timestamped event export | screenshot export | no export |

## 8. DID And Pickup Display Capability Matrix

| Capability | Required For Production | Pilot Acceptable | Not Acceptable |
|---|---|---|---|
| DID callout source | KDS packed/ready state | POS complete state | manual entry only |
| Display payload | masked order number / pickup token | short receipt number | customer name/address/phone |
| Audio callout | configurable and privacy-safe | simple chime | exposes PII |
| Rider/customer split | supported by channel and pickup zone | manually separated | mixed unmanaged queue |
| Recall / re-display | supported with audit event | manual recall | no history |
| Failure fallback | manual callout with event note | manual board | no procedure |

## 9. Hardware And Installation Capability Matrix

| Capability | Required Standard | Notes |
|---|---|---|
| KDS screen durability | kitchen-grade enclosure preferred | high heat, humidity, oil mist, and cleaning exposure must be considered |
| Water / dust resistance | IP-rated where exposed | especially near sink, fryer, prep station |
| Cooling design | fanless or protected cooling preferred | kitchen oil mist can damage consumer hardware |
| Bump bar | recommended for wet/oily/gloved workflow | touchscreen-only workflow may fail during peak operations |
| Mounting | VESA or stable store-specific mount | eye-level and cable safety required |
| Power | protected outlet and cable routing | avoid fryer/sink/cleaning path |
| Network | wired or managed Wi-Fi | kitchen Wi-Fi interference must be tested |
| DID visibility | visible to customer/rider pickup zone | avoid exposing internal kitchen info |

## 10. Privacy And Retention Capability Matrix

| Data Type | KDS Display | DID Display | Logs | Evidence Packet |
|---|---|---|---|---|
| Customer name | Avoid unless operationally required | Forbidden | Mask or tokenize | Redacted |
| Phone number | Forbidden in normal KDS | Forbidden | Mask/tokenize | Redacted |
| Full address | Forbidden in KDS unless delivery dispatch role requires it | Forbidden | Mask/tokenize | Redacted |
| Order number | Allowed | Allowed if not directly identifying | Allowed | Allowed |
| Pickup token | Preferred | Preferred | Allowed | Allowed |
| Special request | Allowed only if kitchen-relevant | Forbidden | Redact sensitive content | Redacted |
| Rider info | limited role-based display | pickup-zone-safe only | role-based | redacted unless required |

## 11. Evidence And KPI Capability Matrix

| Evidence / KPI | Required Events | Reason |
|---|---|---|
| Order received | channel order ID, normalized order ID, timestamp | proves intake |
| POS accepted | store acceptance timestamp | proves store responsibility start |
| KDS card created | KDS order ID, station mapping | proves kitchen visibility |
| Station routed | station ID, item mapping | proves routing logic |
| Station bumped | station ID, bump timestamp | proves station completion |
| Assembly completed | assembly timestamp | proves complete item readiness |
| Packed / ready | packed timestamp | proves pickup readiness |
| DID called | DID token, timestamp | proves customer/rider notification |
| Exception | reason code and actor | proves controlled deviation |
| Masking performed | masking timestamp or retention job | proves privacy control |

## 12. Target Market Fit Matrix

| Store Type | Preferred Vendor Profile | Avoid |
|---|---|---|
| Small independent store | lightweight POS/KDS with simple official channel support | complex enterprise hardware with high setup burden |
| Delivery-first store | delivery hub + KDS with strong channel merge | POS-only system with weak delivery state visibility |
| Shared kitchen / multi-brand | multi-account, multi-brand, item aggregation support | single-store single-brand KDS only |
| Franchise pilot | configurable KDS/DID with evidence export | closed black-box vendor without export |
| Enterprise franchise | official API hub, station KDS, DID, KPI dashboard, hardware management | local-only or scraping-based integration |

## 13. Block Conditions

A vendor or integration path must be blocked if any of the following are true:

- uses screen scraping as the primary order intake method;
- uses memory hooking to extract order data;
- requires store owner raw credentials to be stored by an unapproved third party;
- cannot distinguish official API orders from locally scraped orders;
- cannot provide order event timestamps;
- cannot support privacy masking or redaction;
- exposes customer phone/address on DID;
- cannot produce audit or evidence logs;
- cannot prevent duplicate order intake;
- cannot recover from unknown channel status;
- cannot isolate store-level credentials;
- requires broad database or RLS exceptions;
- cannot support controlled rollback or manual fallback.

## 14. Adoption Decision Template

```markdown
# Vendor Adoption Decision

## Vendor / Solution

## Evaluation Date

## Evaluated By

## Channel Coverage

## API Posture

PASS / FAIL / PARTIAL

## KDS Capability

PASS / FAIL / PARTIAL

## DID Capability

PASS / FAIL / PARTIAL

## Hardware Readiness

PASS / FAIL / PARTIAL

## Privacy / Masking

PASS / FAIL / PARTIAL

## Evidence Export

PASS / FAIL / PARTIAL

## Failure / Degraded Mode

PASS / FAIL / PARTIAL

## Initial Class

Class A / Class B / Class C / Blocked

## Required Conditions Before Pilot

## Required Conditions Before Production

## Final Decision

APPROVE_FOR_RESEARCH / APPROVE_FOR_PILOT / APPROVE_FOR_PRODUCTION / BLOCK
```

## 15. 51355 Pipeline Context Slice

When this document is used inside the 51355 AI-assisted development pipeline, include it only when the change touches:

- delivery app channel adapter;
- KDS vendor selection;
- DID integration;
- official API boundary;
- KDS hardware installation;
- channel-specific evidence export;
- delivery order privacy/masking;
- vendor pilot or production readiness.

Do not include this matrix for unrelated UI-only, membership-only, or unrelated database-only changes.

## 16. Related 750000 Documents

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

## 17. Final Rule

Vendor capability must not be judged by feature marketing.

It must be judged by whether the vendor can safely support:

```text
official channel intake
+ structured order state
+ KDS station routing
+ DID privacy-safe callout
+ duplicate prevention
+ masking and retention
+ evidence export
+ outage fallback
+ controlled implementation scope
```

If these cannot be proven, the integration remains research-only or blocked.
