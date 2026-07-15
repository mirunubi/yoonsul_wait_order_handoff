# 601002_NavigationMap_Cms_Content_Management.md

Status: Active
Lifecycle: NavigationMap
Domain: CMS Content Management

## Workpacket Flow

| Workpacket | Scope | Local flow |
|---|---|---|
| `601010_cms_device_content_routing_architecture/` | 4-layer architecture overview: device registry (A) → CMS content core (B) → delivery/routing engine (C) → kiosk integration (D). Stage A (EDID-based device identification, Option 3 — `update_did_display()`/`0043` correction deferred to a separate future workpacket) implemented via `0156_add_did_device_edid_mapping.sql` — **ACCEPT**. Stage B/C/D not yet started. | `601011_Overview_Cms_Device_Content_Routing_Architecture.md` → `601012_Logic_Cms_Device_Registry_Edid_Mapping.md` → `601013_TestPlan_Cms_Device_Registry_Edid_Mapping.md` → `601014_ChangeContract_Cms_Device_Registry_Edid_Mapping.md` → `601015_Module.md` → `601016_Verification.md` → `601017_Audit.md` |
