# 00001_Md_Rules

## 0 Scope

This document applies only to `yoonsul_wait_order_handoff`.

## 1 Encoding Rule

- All Markdown documents must be UTF-8.
- Korean text must be preserved without encoding corruption.
- Special characters must not be rewritten through unsafe encodings.
- All documentation tasks must preserve UTF-8.
- All tasks must include the Korean/encoding safety block defined in `docs/00015_Korean_Document_And_Encoding_Safety_Rules.md`.
- Cursor must not edit Korean body text.
- Do not use PowerShell Set-Content.
- Do not normalize encoding.
- Do not run formatters.

See `docs/00015_Korean_Document_And_Encoding_Safety_Rules.md` for mandatory Korean documentation and encoding safety rules.

## 2 Heading Rule

- Use clear Markdown headings.
- Prefer numbered major sections for governance and design documents.
- A document should expose its purpose near the top.

## 3 Authority Rule

- One document should have one clear authority purpose.
- Avoid duplicate documents with overlapping ownership.
- Move or rename existing documents instead of recreating them when possible.

## 4 Implementation Boundary Rule

- Keep implementation details out of BM patent documents.
- BM patent documents must remain high-level.
- Implementation details belong in development design docs, not BM patent boundary docs.
- Documentation may describe architecture, boundaries, and intent.
- Documentation must not silently become SQL, migration, app, or API implementation.
- Documentation tasks must not create SQL, migrations, app code, Supabase functions, package changes, or runtime implementation.

## 5 Move And Index Rule

- All new documentation files must use five-digit prefixes according to `docs/00002_Naming_Rules.md`.
- Do not create 4-digit-prefixed docs.
- Update `00005_Document_Number_Index.md` whenever documents move, are created, or are renamed.
- Update `00007_Full_Directory_Map.md` whenever folders move, are created, or are renamed.
- After moving or renaming docs, update `docs/00005_Document_Number_Index.md` and `docs/00007_Full_Directory_Map.md`.
- Internal titles should match the filename meaning after a move.

## 6 Quality Rule

- Do not create placeholder nonsense documents.
- Each document should clearly state its scope and current status when appropriate.
- Keep documents readable by both humans and machine-assisted tools.

## 7 External Project Rule

- `yoonsul_os` may be referenced only as external context.
- Do not merge `yoonsul_wait_order_handoff` implementation into `yoonsul_os`.
- Do not index `yoonsul_os` files as internal project documents.

## 8 Current Status

Status: active root governance rule.
