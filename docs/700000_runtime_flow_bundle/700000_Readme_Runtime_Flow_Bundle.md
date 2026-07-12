# 700000_Readme_Runtime_Flow_Bundle

## Purpose

This folder is the documentation-only, external-integration evidence and release-readiness bundle for `yoonsul_wait_order_handoff`'s runtime flow governance. It is distinct from `700900_runtime_flow`, which holds the AI-implementation-governance control infrastructure (registry, dependency graph, module map, code-handoff templates, exception governance, human approval, release gate) — see `docs/000000_Readme_Root.md` §3 for that boundary (as of this writing, `700900_runtime_flow` itself is still pending its own compliant Readme; see its registry index for the current entry point).

This folder is documentation-only: it may describe expected flows, evidence, failure modes, rollback notes, and verification requirements, but it must not create code, SQL, Flutter/Dart changes, Supabase runtime changes, provider integrations, or operational automation.

## Scope

- Runtime Flow Bundle master governance, external integration boundary, and provider contact/owner register
- POS provider, VAN/PG runtime evidence flows (approval, cancel, request/response state)
- Payment authorization/capture/cancel/refund flow evidence
- KDS event projection, kiosk order submission, and external order app intake flow overviews
- Webhook receive/verify/retry/replay flow and settlement file intake/reconciliation flow
- Idempotency/duplicate-prevention control, dead-letter replay recovery, partial-failure/timeout/provider-outage runbooks
- Financial audit trail, consumer protection, and security signature verification evidence
- Runtime owner/escalation matrix, test coverage evidence, release/rollback gate, post-incident evidence

## File List

- `700179_Governance_Runtime_Flow_Bundle_External_Integration_Evidence_Expansion_Wave_1.md` — full manifest of the 80-document Wave 1 batch (Batch 7D), reclassified from Index to Governance
- `700100`-`700178` — governance, overview, boundary, register, checklist, matrix, report, template, audit, evidence, and runbook documents per the areas listed above

## Non-Scope

- Code, SQL, Flutter/Dart, Supabase runtime changes, or operational automation
