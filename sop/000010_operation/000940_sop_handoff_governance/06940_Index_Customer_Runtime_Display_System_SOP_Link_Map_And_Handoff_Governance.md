# 06940_Index_Customer_Runtime_Display_System_SOP_Link_Map_And_Handoff_Governance.md

## 1. Purpose

This document defines the handoff map between the Customer Runtime Display domain lane and the System SOP lane.

The 06900 lane must not contain System SOP body text.

The 06900 lane may contain domain index, handoff, link map, readiness, and source context documents that point to System SOP documents in the 50000~99999 range.

## 2. Approved Filename Rule

All Markdown filenames must follow this format:

```text
NNNNN_DocumentType_Descriptive_Title_In_English.md
```

The DocumentType must appear immediately after the numeric prefix.

Correct examples:

```text
06511_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md
00300_SOP_Entrance_Waiting_Assist_Device_Operation.md
05420_Checklist_First_Store_POS_Equipment_Decision_And_Provider_Procurement.md
```

Wrong examples:

```text
05420_Policy_First_Store_POS_Equipment_Decision_And_Provider_Procurement_Checklist.md
06510 Entrance Waiting Assist Device Policy.md
06510-Policy-Entrance-Waiting-Assist-Device.md
06510_Korean_Title_Policy.md
```

## 3. Approved DocumentType Prefix Values

Approved DocumentType prefix values are:

- `Policy`
- `SOP`
- `Checklist`
- `Readme`
- `Index`
- `Runbook`
- `Evidence`
- `Audit`
- `Governance`
- `Boundary`
- `Matrix`
- `Template`
- `Register`
- `Report`
- `Assessment`
- `WorkPackage`
- `Implementation`
- `Guide`
- `Spec`
- `ADR`

This file uses `Index` because it is a domain-to-System-SOP link map and handoff document, not an executable SOP body.

## 4. SOP Numbering Rule

The approved SOP numbering rule is:

- `00010~49999` = Operation SOP
- `50000~99999` = System SOP
- System, registry, release, runtime governance, emergency disable, approval, versioning, rollback, and system-level change operation SOP documents must be placed at `50000` or above.

## 5. Correction Note

The previous SOP filename below was incorrectly placed in the 06900 range:

```text
06940_SOP_Customer_Runtime_Display_Registry_Change_Review_Approval_And_Version_Operation.md
```

This document must not remain as a System SOP body document under the 06900 lane.

The corrected System SOP target is:

```text
50010_SOP_Customer_Runtime_Display_Registry_System_Change_Review_Approval_Version_And_Rollback_Operation.md
```

The old 06940 number is repurposed as this index and handoff document:

```text
06940_Index_Customer_Runtime_Display_System_SOP_Link_Map_And_Handoff_Governance.md
```

## 6. Domain Lane Role

The 06900 Customer Runtime Display lane is responsible for:

- Customer-facing runtime display policy context
- Registry source documents
- Display composition and surface readiness references
- Domain-specific evidence and handoff notes
- Links to System SOP documents
- Links from System SOP documents back to the originating domain documents

The 06900 lane is not responsible for:

- System SOP procedure body
- Runtime governance execution procedure
- Release authority procedure
- Emergency disable execution procedure
- Registry change approval execution procedure
- Rollback execution procedure

These must be owned by the 50000 System SOP lane.

## 7. System SOP Link Map

| Domain Source Area | 06900 Domain Reference | System SOP Target | Purpose |
|---|---|---|---|
| Customer Runtime Display Registry | `06900` Customer Runtime Display lane | `50010_SOP_Customer_Runtime_Display_Registry_System_Change_Review_Approval_Version_And_Rollback_Operation.md` | Defines system-level registry change, review, approval, versioning, rollback, and evidence procedure |
| Runtime Display Registry Governance | `06900` Customer Runtime Display lane | `50000_Index_System_SOP_Runtime_Display_Registry_Release_Emergency_Disable_And_Governance.md` | Provides root System SOP index for runtime display registry and related release governance SOPs |
| Release / Disable / Rollback Governance | `06900` Customer Runtime Display lane | Future `50020~50090` System SOPs | Reserved for release, emergency disable, rollback, owner approval, and incident handoff SOPs |

## 8. Required Cross-Link Rule

Every 06900 domain handoff document must link to the corresponding 50000 System SOP document.

Every 50000 System SOP document must link back to the originating 06900 domain source document.

This prevents duplicate SOP bodies and preserves source traceability.

## 9. Required Link Direction

### 9.1 From 06900 To 50000

This document links forward to:

- `50000_Index_System_SOP_Runtime_Display_Registry_Release_Emergency_Disable_And_Governance.md`
- `50010_SOP_Customer_Runtime_Display_Registry_System_Change_Review_Approval_Version_And_Rollback_Operation.md`

### 9.2 From 50000 Back To 06900

The 50000 System SOP documents must link back to:

- `06940_Index_Customer_Runtime_Display_System_SOP_Link_Map_And_Handoff_Governance.md`
- The relevant 06900 Customer Runtime Display registry, policy, readiness, or source documents

## 10. Handoff Boundary

A change request discovered in the 06900 Customer Runtime Display lane must be classified as one of the following:

| Change Type | Remains In 06900 | Escalates To 50000 |
|---|---:|---:|
| Display copy clarification | Yes | No, unless registry impact exists |
| Customer surface layout reference | Yes | No, unless runtime registry impact exists |
| Registry key addition | No | Yes |
| Registry key removal | No | Yes |
| Registry default change | No | Yes |
| Runtime display release gate | No | Yes |
| Emergency disable rule | No | Yes |
| Rollback procedure | No | Yes |
| Approval authority rule | No | Yes |
| Evidence retention procedure | No | Yes |

## 11. Source-To-SOP Handoff Flow

The approved flow is:

1. Domain source document identifies registry or runtime display change need.
2. 06900 handoff/index document records the source and target System SOP.
3. 50000 System SOP defines the executable system procedure.
4. Evidence, approval, version, rollback, and audit records are generated according to the System SOP.
5. 06900 document retains only domain context and cross-link reference.
6. 50000 document retains execution procedure and back-link to original domain source.

## 12. Migration Rule For Existing 06940 SOP

The existing 06940 SOP body must be migrated as follows:

| Old File | Action | New File |
|---|---|---|
| `06940_SOP_Customer_Runtime_Display_Registry_Change_Review_Approval_And_Version_Operation.md` | Rename or recreate as System SOP | `50010_SOP_Customer_Runtime_Display_Registry_System_Change_Review_Approval_Version_And_Rollback_Operation.md` |
| Old 06940 number | Reuse as index/handoff document | `06940_Index_Customer_Runtime_Display_System_SOP_Link_Map_And_Handoff_Governance.md` |

The old 06940 SOP body must not remain as the authoritative SOP.

## 13. Index Update Requirement

When this document is created or updated, the following index files must be updated:

- `00005_Document_Number_Index.md`
- `00007_Full_Directory_Map.md`
- Relevant 06900 folder Readme or lane index
- Relevant 50000 System SOP index after creation

## 14. Acceptance Criteria

This handoff structure is valid only when:

- `06940_Index_Customer_Runtime_Display_System_SOP_Link_Map_And_Handoff_Governance.md` exists as an Index/Handoff document, not as SOP body.
- `50000_Index_System_SOP_Runtime_Display_Registry_Release_Emergency_Disable_And_Governance.md` exists as the System SOP root index.
- `50010_SOP_Customer_Runtime_Display_Registry_System_Change_Review_Approval_Version_And_Rollback_Operation.md` exists as the executable System SOP body.
- 06940 links to 50000 and 50010.
- 50010 links back to 06940 and the originating 06900 domain source.
- No System SOP body remains under `00010~49999` unless it is a true Operation SOP.

## 15. Next Documents

The next documents in this sequence are:

1. `50000_Index_System_SOP_Runtime_Display_Registry_Release_Emergency_Disable_And_Governance.md`
2. `50010_SOP_Customer_Runtime_Display_Registry_System_Change_Review_Approval_Version_And_Rollback_Operation.md`

## 16. Governance Statement

The 06900 lane describes customer runtime display domain context.

The 50000 lane executes system-level SOP governance.

The two lanes must remain connected by explicit cross-links, but the SOP body must live only in the correct number band.
