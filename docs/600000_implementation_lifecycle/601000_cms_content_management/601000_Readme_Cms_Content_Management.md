# 601000_Readme_Cms_Content_Management.md

Status: Active
Lifecycle: Readme
Domain: CMS Content Management

## Purpose

This folder owns the content-management-system domain: the device registry for physical display hardware (digital signage, DID units), the content library and scheduling-rule engine, the delivery/routing pipeline that pushes KDS- and CMS-sourced content to the correct device group in real time or on a cache/schedule basis, and kiosk-facing content feeds (inventory availability, discount policy). This is a **new** domain (2026-07-14) — no prior workpacket owned this scope; the closest existing pieces (`get_kds_realtime_state()`, `get_did_display_state()`, `call_customer_pickup()`, `did_display_queue`, `update_did_display()`) were scattered across the KDS/DID/Payment domains and are catalogued, not owned, by this folder until a workpacket formally migrates or wraps them.

## In Scope

- Device registry and physical port/hardware mapping for signage and DID units.
- CMS content library (menu items, prices, photos, ads/promotions, multilingual/seasonal content).
- Scheduling-rule engine (time-of-day + day-of-week + date-range combinations, manual priority-number conflict resolution, device-group targeting).
- Content delivery/routing engine (real-time vs. cache-with-invalidation hybrid, KDS-sourced vs. CMS-sourced content).
- Kiosk-facing feeds sourced from CMS/store-settings (discount policy) and KDS (stock/sold-out availability).

## Out of Scope

- KDS ticket lifecycle itself (owned by `600400_kds_did_implementation/`).
- DID overload/signature cleanup already completed (`600800_did_implementation/`).
- Payment confirmation (`600500_payment_confirmation/`).
- Physical installation of signage/DID hardware — Human-performed, not a software workpacket.

## Subfolder Map

| Folder | Role | Status |
|---|---|---|
| `601010_cms_device_content_routing_architecture/` | Stage 1.5 architecture overview for the 4-layer CMS structure (device registry → content core → delivery engine → kiosk integration). | New, Overview drafted 2026-07-14. |

## Numbering Note

`601000` reuses a number that previously belonged to `docs/990000_legacy_quarantine/601000_olm_model/` (retired, generic documentation-template scaffolding, index status `moved`) — see `000002_Naming_Rules.md`'s "`601000` band reuse" clarification (2026-07-14, Human decision) for the confirmation basis.
