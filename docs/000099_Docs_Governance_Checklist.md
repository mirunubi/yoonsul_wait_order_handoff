# 000099_Docs_Governance_Checklist

## 0 Scope

This document applies only to `yoonsul_wait_order_handoff`.

## 1 Checklist Before Committing Docs Changes

- `git status -sb` checked.
- UTF-8 preserved.
- five-digit prefix compliance checked.
- 2,000-slot domain band compliance checked.
- no 4-digit-prefixed docs/folders remain.
- no transitional five-digit band paths remain after rebalance.
- no duplicate document number in the same folder.
- moved files reflected in `docs/000005_Index_Document_Number.md`.
- moved folders reflected in `docs/000007_Map_Full_Directory.md`.
- stale 4-digit path references checked.
- README links checked.
- no SQL, migration, app implementation, Supabase function, package change, or runtime implementation included.
- no external project files are indexed as internal files.
- no `yoonsul_os` or `yoonsul_franchise_os` files indexed as internal files.
- temporary tree snapshots excluded or clearly marked.
- Korean/encoding safety block included in task prompt.
- UTF-8 preserved.
- No PowerShell Set-Content used.
- No formatter run.
- No encoding normalization.
- Cursor did not edit Korean body text.
- No unexpected Korean prose rewrite.
- No brand/IP wording rewrite.
- No mojibake introduced.

## 2 Checklist Before Creating Implementation

- MVP boundary approved.
- SaaS tenant boundary approved.
- customer session and handoff state machine approved.
- integration boundary approved.

## 3 Safety Principle

Documentation approval does not equal implementation approval.

## 4 Current Status

Status: active root governance checklist.
