# 750090_Checklist_Delivery_App_KDS_DID_Hardware_Environmental_Durability_And_Installation_Readiness.md

## 1. Purpose

This checklist defines the field-readiness criteria for installing KDS, station KDS, bump bars, DID displays, network devices, and supporting peripherals in delivery-app connected kitchen environments.

The goal is to prevent hardware failure, data visibility gaps, kitchen workflow interruption, customer pickup confusion, and unsafe field installation when delivery app orders are routed into KDS/DID runtime.

This document belongs to the `750000_delivery_app_channel_integration` bundle and must be used before any delivery-app channel integration is piloted in a real store.

## 2. Scope

This checklist covers:

- Kitchen Display System hardware.
- Station KDS displays.
- Bump bars and input devices.
- DID customer / rider callout displays.
- Kitchen network connectivity.
- Power, cable, and mounting readiness.
- Heat, humidity, oil mist, splash, and dust exposure.
- Local fallback for delivery app order intake.
- Field test evidence collection.

This checklist does not authorize runtime implementation, vendor contracting, payment integration, or production release by itself.

## 3. Related Documents

- `750000_Index_Delivery_App_Channel_Integration_KDS_DID_And_Order_Ingestion_Runtime.md`
- `750010_Assessment_Delivery_App_Channel_API_KDS_DID_And_Omnichannel_Order_Ingestion_Architecture.md`
- `750020_Guide_Delivery_App_API_KDS_DID_Integration_Context_Summary.md`
- `750030_Policy_Delivery_App_Official_API_Integration_And_No_Scraping_Boundary.md`
- `750040_Boundary_POS_API_Gateway_KDS_DID_And_Kitchen_Runtime_Responsibility.md`
- `750050_Matrix_Delivery_App_POS_KDS_DID_Channel_Integration_Map.md`
- `750060_Policy_Delivery_App_Customer_Privacy_Masking_Tokenization_And_Data_Retention.md`
- `750070_SOP_Delivery_App_Order_Intake_KDS_Routing_Bump_And_DID_Callout_Runtime.md`
- `750080_Logic_Delivery_App_KDS_Smart_Routing_Station_Splitting_BOM_And_Assembly_State_Machine.md`
- `51355_Guide_AI_Assisted_Financial_Grade_Development_Pipeline_Cursor_Claude_Codex_Automated_Gate_And_Human_Merge.md`

## 4. Hardware Readiness Principle

KDS/DID installation must be treated as a runtime infrastructure decision, not as a simple monitor purchase.

Kitchen devices operate under:

- Heat.
- Steam.
- Water splash.
- Oil mist.
- Flour / powder / dust.
- Impact from utensils.
- Gloved hand operation.
- Peak-time staff movement.
- Noise.
- Limited mounting space.
- Unstable Wi-Fi and power conditions.

Therefore, every hardware decision must be validated against field conditions before delivery-app order routing depends on it.

## 5. KDS Display Environmental Checklist

| Check Item | Required Condition | Result |
|---|---|---|
| Heat exposure | Display location is not directly above fryer, grill, steam outlet, or oven exhaust | PASS / FAIL |
| Oil mist exposure | Device housing and screen can tolerate continuous oil mist cleaning cycle | PASS / FAIL |
| Water splash exposure | Device is outside direct sink / washdown splash path or has proper protection | PASS / FAIL |
| Dust / powder exposure | Display is not exposed to flour, starch, or powder accumulation without cleaning plan | PASS / FAIL |
| Ventilation | Device does not depend on open fan intake in heavy oil environment unless approved | PASS / FAIL |
| Screen visibility | Order cards are readable from normal working distance | PASS / FAIL |
| Glare | Display is not blocked by hood light glare or window reflection | PASS / FAIL |
| Cleaning method | Approved cleaning method does not damage screen, cable, or casing | PASS / FAIL |
| Touch reliability | Touch screen works with wet/gloved hands or bump bar is provided | PASS / FAIL |
| Cable strain | Cables are strain-relieved and cannot be pulled during kitchen work | PASS / FAIL |

## 6. Station KDS Placement Checklist

Each station KDS must be placed according to the station's actual workflow.

| Station | Placement Rule | Required Evidence |
|---|---|---|
| Intake / dispatch | Visible to order acceptor or expeditor | Field photo |
| Grill / hot line | Visible without crossing unsafe heat zone | Field photo |
| Fryer | Visible without forcing staff to reach over oil | Field photo |
| Beverage / dessert | Visible near assembly point, not customer-facing unless intended | Field photo |
| Assembly / packing | Visible to final checker and bagging station | Field photo |
| Pickup / handoff | Linked to DID and final handoff flow | Field photo |
| Shared kitchen station | Brand/channel badges must be visible | Screenshot / field photo |

## 7. Bump Bar Readiness Checklist

Bump bars or equivalent physical controls should be used when touch operation is unreliable.

| Check Item | Required Condition | Result |
|---|---|---|
| Mounting | Bump bar is fixed and does not move during repeated use | PASS / FAIL |
| Protection | Device tolerates water, oil, and gloved operation | PASS / FAIL |
| Key mapping | Key actions are mapped to KDS state transitions | PASS / FAIL |
| Mis-bump prevention | Accidental complete/cancel input is guarded | PASS / FAIL |
| Station isolation | Bump action affects only the intended station card | PASS / FAIL |
| Assembly dependency | Final order completion is blocked until required station bumps are satisfied | PASS / FAIL |
| Accessibility | Staff can operate without crossing hot or wet zones | PASS / FAIL |
| Training | Store staff understand bump, recall, hold, and exception actions | PASS / FAIL |

## 8. DID Installation Checklist

DID devices must support customer and rider recognition without exposing unnecessary personal information.

| Check Item | Required Condition | Result |
|---|---|---|
| Visibility | Display is visible from pickup waiting zone | PASS / FAIL |
| Distance | Order number is readable from normal waiting distance | PASS / FAIL |
| Audio | Sound is audible but not disruptive | PASS / FAIL |
| Privacy | DID never displays full phone number, address, or customer name unless explicitly approved | PASS / FAIL |
| Channel badge | Delivery / pickup / dine-in distinction is visible where operationally required | PASS / FAIL |
| Rider flow | Rider pickup display does not congest dine-in customer flow | PASS / FAIL |
| Fallback | Staff can manually call order if DID is unavailable | PASS / FAIL |
| Sync | DID state changes only after approved KDS completion event | PASS / FAIL |

## 9. Network Readiness Checklist

Delivery-app connected KDS/DID runtime must not depend on unstable network behavior.

| Check Item | Required Condition | Result |
|---|---|---|
| Primary network | Store has stable primary WAN | PASS / FAIL |
| Wi-Fi coverage | KDS/DID locations have reliable signal if wireless is used | PASS / FAIL |
| Wired preference | Critical KDS/DID endpoints use wired Ethernet where possible | PASS / FAIL |
| VLAN / segmentation | Store runtime devices are separated from guest Wi-Fi where possible | PASS / FAIL |
| Firewall | Required outbound endpoints are allowed and unnecessary inbound access is blocked | PASS / FAIL |
| Static address / reservation | Critical devices have DHCP reservation or static addressing plan | PASS / FAIL |
| Local fallback | Order intake fallback is defined for network interruption | PASS / FAIL |
| Monitoring | Device offline state can be detected | PASS / FAIL |

## 10. Power And Cable Checklist

| Check Item | Required Condition | Result |
|---|---|---|
| Dedicated outlet | Critical display devices are not sharing overloaded extension strips | PASS / FAIL |
| Cable protection | Cables do not cross wet floors, heat zones, or staff walkways | PASS / FAIL |
| UPS / surge | Critical gateway/router equipment has surge protection or UPS where required | PASS / FAIL |
| Labeling | Power/network cables are labeled by device and station | PASS / FAIL |
| Emergency access | Staff can power-cycle device safely when instructed | PASS / FAIL |
| No dangling adapters | Adapters are mounted and not hanging by cable tension | PASS / FAIL |
| Cleaning safety | Cleaning routine cannot soak power connectors | PASS / FAIL |

## 11. Delivery App Channel Hardware Dependency Map

| Runtime Function | Hardware Dependency | Failure Impact |
|---|---|---|
| Order intake visibility | Main KDS / POS projection | Store may miss delivery order |
| Station routing | Station KDS | Station may not start prep |
| Station completion | Bump bar / touch input | Assembly may not know part completion |
| Assembly readiness | Assembly KDS | Packing may be delayed or incorrect |
| Customer/rider callout | DID / audio | Pickup delay and counter congestion |
| Evidence capture | Server / gateway / local logs | Incident reconstruction may fail |
| Network access | Router / firewall / WAN | Order sync may stop or degrade |

## 12. Privacy And Display Rules

KDS/DID hardware placement must comply with privacy rules.

Forbidden by default:

- Full customer phone number on kitchen or public display.
- Full delivery address on public or rider-facing DID.
- Long-term local storage of customer address on unmanaged device.
- Customer special request display on DID when it contains sensitive text.
- Screens placed where non-staff can read private delivery details.
- Photos of screens containing live customer information without redaction.

Allowed by default:

- Masked order number.
- Channel badge.
- Pickup code.
- Menu item and option data necessary for kitchen preparation.
- Rider pickup status without unnecessary customer identity.

## 13. Field Installation Evidence Packet

Before pilot launch, collect:

```text
docs/implementation_evidence/<change_id>/field_installation/
  kds_main_photo_redacted.jpg
  station_kds_photos_redacted/
  did_photo_redacted.jpg
  network_topology.md
  device_inventory.md
  cable_power_checklist.md
  privacy_visibility_check.md
  bump_bar_keymap.md
  staff_training_record.md
  fallback_runbook_acknowledgement.md
```

Do not store unredacted customer data in field evidence.

## 14. Device Inventory Template

```markdown
# device_inventory.md

## Change ID

## Store ID

## Installation Date

## Devices

| Device Role | Vendor / Model | Serial | Network ID | Location | Owner |
|---|---|---|---|---|---|
| Main KDS | | | | | |
| Station KDS - Grill | | | | | |
| Station KDS - Fryer | | | | | |
| Assembly KDS | | | | | |
| DID | | | | | |
| Router / Gateway | | | | | |
| Bump Bar | | | | | |

## Notes
```

## 15. Pre-Pilot Hardware Gate

Pilot may start only when:

- Main KDS is installed and visible.
- Required station KDS devices are installed.
- DID is installed or explicit DID deferral is approved.
- Network path is validated.
- Power/cable risks are resolved.
- Privacy visibility check passes.
- Bump or completion input path is validated.
- Manual fallback is documented.
- Field evidence packet exists.
- Store staff training is recorded.

## 16. Failure Handling

If hardware readiness fails:

1. Do not route real delivery app orders to that station.
2. Mark the device or station as `hardware_not_ready`.
3. Record blocker in field evidence.
4. Use manual fallback only if approved.
5. Do not hide the failure inside a successful software verification result.
6. Re-run readiness check after installation changes.

## 17. Prohibited Behavior

The following are prohibited:

- Treating consumer tablets as production KDS without field durability approval.
- Mounting KDS above direct fryer or steam exhaust without protection.
- Using DID to expose customer personal information.
- Allowing staff to complete orders from the wrong station device.
- Depending on unstable guest Wi-Fi for KDS/DID runtime.
- Launching delivery-app channel routing without fallback procedure.
- Capturing unredacted customer information in field photos.
- Using hardware installation success as proof of API correctness.
- Using API test success as proof of hardware readiness.

## 18. 51355 Pipeline Notes

For implementation under the 51355 development pipeline:

- Cursor Stage 1 must include KDS/DID hardware and field evidence references in `impact_scope.md`.
- Context Snapshot must include this checklist when the change affects KDS/DID runtime devices.
- `change_contract.md` must identify whether hardware readiness is in scope or explicitly out of scope.
- Verification must collect raw logs and field evidence separately.
- Claude Audit must block if production routing depends on unverified KDS/DID hardware.
- Human merge/release must confirm field readiness before store pilot.

## 19. Final Rule

```text
No delivery-app KDS/DID pilot without hardware readiness.
No hardware readiness without field evidence.
No field evidence with unredacted customer data.
No DID callout without privacy-safe display.
No KDS routing without fallback.
No production routing if the kitchen cannot see, bump, assemble, and call out the order safely.
```
