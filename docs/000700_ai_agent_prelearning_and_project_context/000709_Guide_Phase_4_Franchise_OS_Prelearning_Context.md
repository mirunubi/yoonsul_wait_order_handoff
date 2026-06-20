# 000509_Guide_Phase_4_Franchise_OS_Prelearning_Context.md

## 1. Purpose

Phase 4 explains Franchise_OS as the headquarters and branch operation control system.

This document is prelearning for Claude, Codex, Cursor, and future AI agents before they work on this phase.

It helps agents understand the phase before implementation planning. It does not authorize implementation.

## 2. Phase Position

Phase 4 is the governance control room phase for franchise operations, approvals, evidence, compliance, and controlled rollout.

## 3. Core Scope

- HQ control
- Store onboarding
- Branch/store management
- Menu distribution
- Policy distribution
- Store configuration
- Approval workflow
- Evidence review
- Compliance control
- Incident tracking
- Operational monitoring
- Rollout/rollback governance

## 4. Non-Scope

- Unapproved provider credential changes
- Unscoped store runtime implementation
- Payment mutation
- Branch policy rollout without evidence
- Production release without approval

## 5. Key Runtime Concepts

- Control room
- HQ authority
- Branch/store boundary
- Policy distribution
- Evidence review
- Approval workflow
- Rollout governance

## 6. Key Risks

- HQ setting change creates store operation accident
- Menu or price policy distribution error
- Unauthorized admin change
- Provider credential exposure
- Rollout/rollback evidence missing

## 7. Required Pre-Implementation Documents

- impact_scope for HQ, branch, store, menu/policy distribution, approval, evidence, compliance, rollout, and rollback governance
- context_snapshot covering store onboarding, branch/store management, policy authority, and compliance control dependencies
- overview of Franchise OS as the headquarters and franchise operation control room
- logic for approval workflow, evidence review, compliance control, rollout, rollback, and policy distribution
- test_plan for unauthorized admin change, bad policy rollout, evidence gaps, and rollback governance
- change_contract that identifies allowed control-room actions and forbidden direct runtime mutations
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


Phase 4 builds on Phase 2 store runtime and governs Phase 6 SaaS-wide integration.

## 10. Final Rule

Franchise OS Admin is a governance control room for headquarters and franchise operations, not an admin CRUD panel.
