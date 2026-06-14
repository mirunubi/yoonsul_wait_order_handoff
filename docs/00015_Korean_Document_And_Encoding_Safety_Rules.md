# 00010 Korean Document And Encoding Safety Rules

## 0 Scope

This document applies only to `yoonsul_wait_order_handoff`.

## 1 Purpose

This repository contains Korean-heavy business, brand, UI wording, and governance documents.

Korean wording is part of the project's brand/IP asset.

Encoding corruption or broad rewrite can destroy design value.

These rules apply to all future documentation tasks.

## 2 Executor Role Separation

| executor | allowed work |
| --- | --- |
| Cursor | File moves, folder checks, path/reference updates, git status checks, English-only short metadata, and structure-only work. |
| Codex | Korean-containing document edits, long markdown body edits, policy/boundary document writing, and semantic document edits. |
| Manual/direct editing | Brand philosophy, emotional Korean prose, naming, customer-facing phrases, menu/membership names, and worldview language. |

When in doubt, prefer Codex or manual editing for any task that changes Korean meaning.

## 3 Cursor Restrictions

- If you are Cursor, do not edit Korean body text.
- Cursor must not rewrite full markdown files.
- Cursor must not modify Korean brand wording.
- Cursor must not modify Korean menu names.
- Cursor must not modify membership names.
- Cursor must not modify customer-facing Korean wording.
- Cursor must not summarize or rephrase Korean prose.
- Cursor must report when a task requires Codex/manual Korean editing.

## 4 Mandatory Encoding Rules

- Preserve UTF-8.
- Do not normalize encoding.
- Do not run formatters.
- Do not use PowerShell Set-Content.
- Do not convert line endings intentionally.
- Do not strip BOM intentionally.
- Do not rewrite files only to change encoding.

## 5 Allowed Safe Operations

- file/folder existence checks.
- git status checks.
- path updates in index/map files.
- creating English-only structural Readmes if explicitly requested.
- adding new files when task explicitly requires it.
- editing non-Korean metadata lines when safe.
- reporting required Korean edits instead of performing them.

Path/reference/index/map updates are allowed only when they do not rewrite Korean prose.

## 6 Forbidden Operations

- full document rewrite.
- broad search-and-replace over Korean docs.
- semantic rewrite of Korean prose.
- reformatting markdown tables globally.
- formatter execution.
- encoding normalization.
- Korean brand/IP term replacement.
- invisible mass edits.
- unreviewed script-based content rewriting.

## 7 Required Task Prompt Safety Block

All documentation tasks should include this exact block:

```text
KOREAN / ENCODING SAFETY:
- Preserve UTF-8.
- Do not normalize encoding.
- Do not run formatters.
- Do not use PowerShell Set-Content.
- Do not rewrite full markdown files.
- Do not perform broad search-and-replace over Korean text.
- Do not modify Korean prose, Korean brand wording, menu names, membership names, customer-facing wording, or philosophy text unless explicitly instructed.
- If you are Cursor, do not edit Korean body text. Only report the required change.
- If a file contains Korean body text and the requested change requires semantic editing, STOP and report: "Requires Codex or manual Korean document editing."
- Path/reference/index/map updates are allowed only when they do not rewrite Korean prose.
```

## 8 Escalation Rule

- If task requires Korean semantic edit, use Codex or manual editing.
- If Cursor cannot safely perform the task, it must stop and report.
- If encoding damage is suspected, stop and inspect diff before continuing.
- Never continue after mojibake appears.

When a file contains Korean body text and the requested change requires semantic editing, STOP and report: `Requires Codex or manual Korean document editing.`

## 9 Validation

Before considering a documentation task complete:

- run `git diff --check`.
- review changed files.
- confirm no unexpected Korean rewrite.
- confirm no encoding-only changes.
- confirm no formatter-generated mass diff.

## 10 Current Status

Status: active root governance rule for Korean documentation and encoding safety.
