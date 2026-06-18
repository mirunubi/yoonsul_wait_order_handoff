# Report Six Digit Documentation Numbering Dry Run Manifest

Status: Implemented
Lifecycle: Module
Owner: TBD
Last Updated: 2026-06-18

## 0 Scope

This report summarizes the dry-run scan for converting five-digit documentation prefixes to six-digit prefixes.

This task created dry-run outputs only.

- No file rename was executed.
- No folder rename was executed.
- No file move was executed.
- No delete was executed.
- No H1, body, or internal link edit was executed.
- No runtime implementation was created.
- No formatter was run.
- PowerShell `Set-Content` was not used.

## 1 Scan Inputs

Scanned roots:

- `docs/`
- `sop/`

Reference documents:

- `docs/000001_Md_Rules.md`
- `docs/000002_Naming_Rules.md`
- `docs/000005_Document_Number_Index.md`
- `docs/000007_Full_Directory_Map.md`
- `docs/000015_Korean_Document_And_Encoding_Safety_Rules.md`
- `docs/000010_Report_Six_Digit_Documentation_Numbering_Governance_Update.md`

## 2 Scan Summary

| Metric | Count |
| --- | ---: |
| Total scanned items | 1520 |
| Five-digit prefix files | 1424 |
| Five-digit prefix folders | 70 |
| Already six-digit items | 1 |
| Four-digit prefix anomalies | 0 |
| No-prefix anomalies | 3 |
| Excluded manual delete candidates | 22 |
| Duplicate target path candidates | 0 |
| Long path risk candidates | 193 |
| Case-only conflict candidates | 0 |

## 3 Dry-Run Conversion Rule

The proposed migration rule is:

```text
xxxxx -> 0xxxxx
```

The rule applies to five-digit-prefixed files and folders only. Already six-digit items are left unchanged. Four-digit-prefixed items and no-prefix items require manual review.

## 4 Exclusion Handling

The following categories were excluded from auto-rename and recorded in the anomaly register:

- `*-1.md` duplicate files
- Recipe, mobile, temporary SOP, and date-based SOP files marked for manual cleanup
- Image files
- Directory tree output files
- Downloadfile temporary files
- Termux test files

## 5 Risk Notes

- Duplicate target paths must be resolved before any rename batch.
- Case-only conflicts must be resolved manually because Windows and Git may not detect them safely.
- Long path candidates should be reviewed before rename, especially for deeply nested runtime flow package files.
- Existing five-digit files remain valid migration targets until an approved rename batch is run.

## 6 Recommended Next Batch

Recommended next step:

1. User reviews `docs/000012_Register_Six_Digit_Rename_Dry_Run_Manifest.md`.
2. User reviews `docs/000013_Register_Six_Digit_Rename_Anomaly_And_Manual_Review.md`.
3. Execute Batch 1 only after approval: root governance files rename.
4. Update `docs/000005_Document_Number_Index.md`, `docs/000007_Full_Directory_Map.md`, and affected folder `Readme` files during the approved rename batch.
