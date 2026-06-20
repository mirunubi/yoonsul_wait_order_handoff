# 000508_Guide_Phase_3_Kiosk_KDS_DID_CMS_POS_Integration_Prelearning_Context.md

## 1. Purpose

Phase 3 explains kiosk, KDS, DID, CMS, POS integration, Toss, OKPOS, and financial-grade runtime hardening.

This document is prelearning for Claude, Codex, Cursor, and future AI agents before they work on this phase.

It helps agents understand the phase before implementation planning. It does not authorize implementation.

## 2. Phase Position

Phase 3 is the financial-grade runtime phase where POS, payment, and KDS workflows can create financial and operating accidents.

## 3. Core Scope

- Kiosk
- KDS
- DID
- CMS
- POS integration
- Toss
- OKPOS
- POS Gateway
- Payment recovery boundary
- KDS operation boundary
- Provider adapter governance
- Idempotency
- Duplicate prevention
- Unknown provider state
- Audit/evidence
- Rollback

## 4. Non-Scope

- Unapproved payment mutation
- Provider integration without evidence
- Direct production runtime change
- SQL migration without 51355 approval
- KDS/payment state mutation without test plan

## 5. Key Runtime Concepts

- Financial-grade hardening
- Provider state authority
- Idempotency key
- Duplicate prevention
- Unknown state inquiry
- Audit ledger
- Evidence packet
- Rollback and replay

## 6. Key Risks

- Duplicate payment
- Duplicate cancellation
- POS/KDS/payment state mismatch
- Unknown provider state treated as success or failure
- False finality shown to customer
- KDS completion conflicts with payment failure
- Audit/evidence missing

## 7. Required Pre-Implementation Documents

- impact_scope for kiosk, KDS, DID, CMS, POS Gateway, Toss, OKPOS, and payment recovery boundaries
- context_snapshot covering provider state authority, KDS operation boundary, payment evidence, and rollback dependencies
- overview of financial-grade integration and operating accident prevention
- logic for idempotency, duplicate prevention, unknown provider state, audit/evidence, rollback, and replay prevention
- test_plan for duplicate payment, duplicate cancellation, provider timeout, unknown state, KDS mismatch, and recovery
- change_contract that names allowed provider, POS Gateway, KDS, and evidence operations
- human approval before any implementation activity

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


Phase 3 depends on Phase 2 store runtime and connects to Phase 3-B delivery channels through controlled event contracts.

## 10. Final Rule

Kiosk, KDS, DID, CMS, POS, Toss, and OKPOS integration is financial-grade runtime, not simple adapter work.
