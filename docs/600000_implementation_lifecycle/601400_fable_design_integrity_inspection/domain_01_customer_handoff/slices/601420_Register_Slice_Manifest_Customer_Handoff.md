# 601420 Register — Customer Handoff Fable Delivery Slices

- Program: `601400_fable_design_integrity_inspection`
- Domain: `domain_01_customer_handoff`
- Method: 6-slice split (601300 waiting 5-slice pattern)
- Regenerate: `python tools/build_601400_customer_handoff_slices.py`
- Created: 2026-07-19

## Slice summary

| Slice | Package | MD files | SQL files | MD bytes | SQL concat | Est. payload | Fable 1-pass? | Core payload (excl scratch/601300) | Core 1-pass? |
|---|---|---:|---:|---:|---:|---:|---|---:|---|
| `slice_01_waiting` | `601421` | 65 | 15 | 1,659,194 | 279,504 | 1,938,698 | NO/OVER | 1,006,324 | YES |
| `slice_02_payment` | `601422` | 53 | 23 | 618,161 | 396,533 | 1,014,694 | YES | 998,336 | YES |
| `slice_03_kds_did` | `601423` | 52 | 16 | 712,777 | 309,005 | 1,021,782 | YES | 698,899 | YES |
| `slice_04_customer_handoff_policy` | `601424` | 73 | 3 | 925,022 | 120,980 | 1,046,002 | YES | 1,046,002 | YES |
| `slice_05_runtime_flow` | `601425` | 81 | 2 | 273,631 | 26,251 | 299,882 | YES | 299,882 | YES |
| `slice_06_app_layer` | `601426` | 24 | 3 | 130,812 | 95,359 | 226,171 | YES | 226,171 | YES |

## Duplicate SQL note

Migrations may appear in multiple slices (601300 pattern). Counts above are per-slice membership, not globally unique.

## slice_01_waiting delivery note

Full payload exceeds 1.5 MiB because `sql/scratch/fable_pass_a/` concat duplicates are included in inventory scope.
For Fable single-pass delivery, use **Core payload** (600600 lifecycle docs + `slice_01_migrations_concat.sql` only; exclude scratch/601300 duplicates).
