# 000510_Guide_Phase_5_AI_Customer_Center_Digital_SOP_RAG_Pgvector_Prelearning_Context.md

## 1. Purpose

Phase 5 explains the AI customer center as a controlled SOP/RAG knowledge gateway, not free chat.

This document is prelearning for Claude, Codex, Cursor, and future AI agents before they work on this phase.

It helps agents understand the phase before implementation planning. It does not authorize implementation.

## 2. Phase Position

Phase 5 is the knowledge, SOP, RAG, pgvector, unresolved inquiry, and SOP evolution phase.

## 3. Core Scope

- AI customer center
- Digital SOP
- Approved knowledge base
- RAG
- pgvector
- Embedding
- SOP/Policy/Runbook/Checklist search
- Answer grounding
- Source document ID/version logging
- Unresolved inquiry event
- Repeated unknown question detection
- SOP creation candidate
- Human approval
- AI Agent SOP draft
- Review/publish/version/rollback

## 4. Non-Scope

- SQL migration creation in this document
- RLS modification
- Free chatbot answer generation
- Auto-publish SOP without approval
- Embedding sensitive data without policy

## 5. Key Runtime Concepts

- Controlled knowledge gateway
- Vector search as retrieval layer
- Approved document context
- Source version logging
- Unresolved inquiry loop
- SOP candidate workflow
- Human approval

## 6. Key Risks

- AI answers outside SOP scope
- pgvector search bypasses authority
- Draft/archive document used as answer basis
- Personal or payment-sensitive data embedded
- Tenant/store data leakage
- SOP auto-created and published without human approval

## 7. Required Pre-Implementation Documents

- impact_scope for AI customer center, Digital SOP, approved knowledge base, RAG, pgvector, embedding, and SOP evolution
- context_snapshot covering document authority, source versioning, tenant/store filters, unresolved inquiry events, and human approval workflow
- overview of AI customer center as a controlled knowledge gateway
- logic for answer grounding, source document ID/version logging, unresolved inquiry detection, repeated unknown question detection, and SOP candidate creation
- test_plan for unapproved source use, unknown question loops, document-status filtering, tenant/store leakage, and rollback
- change_contract that separates vector retrieval from document authority and blocks auto-publish
- human approval before any implementation activity

RAG flow prelearning sequence:

1. Receive question.
2. Normalize question.
3. Generate embedding.
4. Search similar documents through pgvector.
5. Apply tenant, store, RLS, and document-status filters.
6. Inject only approved SOP, policy, and runbook context.
7. Generate AI answer.
8. Record source document ID and version.
9. Record unresolved inquiry event.
10. Detect repeated unresolved question.
11. Create SOP candidate.
12. Request human approval.
13. Generate AI Agent SOP draft.
14. Review, publish, version, or rollback.

New question SOP evolution prelearning sequence:

- One event: log.
- Two events: repeated signal.
- Three or more events: SOP creation candidate.
- Human approval.
- AI Agent draft.
- Review.
- Publish.
- Versioning.
- Rollback.

## 8. Implementation Gate

This document is not an implementation authorization.

Actual implementation must pass through the 51355 pipeline. Implementation is forbidden unless impact_scope, context_snapshot, overview, logic, test_plan, change_contract, and human approval exist.

Allowed files are not enough. Allowed operations must also be specified.

Cursor is only an optional inspection helper for related-file discovery and raw evidence collection.

Claude Cowork is responsible for design, audit, and document classification.

Codex is responsible only for limited implementation or document generation inside approved files and approved operations.

Human is responsible for final approval, merge, and release.

## 9. Related Folders And Documents

Cross-references:

- `000505_Guide_Project_Development_Phase_Roadmap_And_AI_Prelearning_Context.md`
- `051355` AI-assisted financial-grade development pipeline
- `600000` implementation lifecycle
- `700000` runtime flow bundle
- `000500` AI agent prelearning folder


Phase 5 depends on documentation governance, RLS/privacy controls, and the 51355 pipeline. SQL migrations must be handled separately through 51355 approval.

## 10. Final Rule

AI Customer Center is a controlled SOP/RAG gateway, not a free chatbot; pgvector is a vector search layer for finding approved document candidates, not an authority.
