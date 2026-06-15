# 05021_Policy_CI_DI_Identity_Callback_Masking_Leakage_Test_Catalog

## 1. Purpose

This document defines the test catalog policy for CI / DI identity linkage, identity provider callback validation, callback idempotency, callback replay detection, account linkage, duplicate account candidate handling, account merge authority, identity masking, support identity visibility, export restriction, AI dataset exclusion, leakage detection, leakage response, audit, evidence, and deployment gate requirements in the Yoonsul Wait/Order Handoff project.

CI / DI and verified identity linkage are highly sensitive.

If identity handling is not tested, raw identity data may leak into staff screens, support views, POS/KDS payloads, payment records, exports, logs, audit, AI datasets, or vendor sharing paths.

Therefore, CI / DI identity behavior must have explicit positive tests, negative tests, abuse-case tests, callback tests, idempotency tests, replay tests, masking tests, leakage response tests, audit tests, evidence tests, and deployment gate tests before implementation is allowed.

This document does not implement identity provider integration, callback handlers, RLS policies, masking functions, leakage scanners, export filters, AI pipelines, or automated test code.

It defines the test catalog that future identity implementation must satisfy.

---

## 2. Scope

This test catalog applies to:

- CI / DI handling
- identity provider callback validation
- state parameter validation
- nonce validation where applicable
- session binding
- provider transaction id handling
- identity callback idempotency
- identity callback replay detection
- verified account linkage
- public service identity versus tenant identity
- duplicate account candidate detection
- account merge request
- account merge approval
- identity correction
- identity masking
- support identity view
- HQ identity view
- store staff identity restriction
- POS/KDS identity exclusion
- payment identity separation
- export restriction
- AI dataset exclusion
- log masking
- audit masking
- identity leakage detection
- identity leakage response
- evidence packet linkage
- deployment gate requirements
- implementation blockers

This document focuses on test catalog design, not identity implementation.

---

## 3. Core Principle

CI / DI must be verified, minimized, masked, scoped, and excluded from ordinary runtime by default.

The project must follow this rule:

> CI / DI may support verified identity linkage, but raw CI / DI must not appear in ordinary staff views, POS/KDS payloads, support browsing, payment runtime, logs, exports, AI datasets, or audit payloads by default.

Tests must prove both allowed linkage and prohibited exposure.

---

## 4. Source Mapping Documents

This test catalog verifies constraints from:

- 04831_Implementation_Mapping_Lane_Start_And_Policy_To_Code_Constraint_Handoff_Policy
- 04841_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping
- 04851_Audit_Event_Taxonomy_Append_Only_And_Evidence_Implementation_Mapping_Policy
- 04871_Policy_Payment_Webhook_Refund_Settlement_And_Reconciliation_Implementation_Mapping
- 04881_Policy_CI_DI_Identity_Linkage_Callback_Masking_And_Leakage_Response_Implementation_Mapping
- 04891_Policy_Support_Access_Masking_Break_Glass_And_Scoped_Session_Implementation_Mapping
- 04921_Policy_Export_Report_Benchmark_External_Sharing_And_Data_Extraction_Implementation_Mapping
- 04931_Policy_AI_Analytics_Dataset_Minimization_Model_Output_And_Recommendation_Boundary_Implementation_Mapping
- 04941_Policy_Vendor_Partner_Access_Third_Party_Risk_And_External_Integration_Implementation_Mapping
- 04951_Policy_Secure_Deployment_Environment_Separation_Release_Gate_And_Rollback_Implementation_Mapping
- 04971_Policy_Security_And_Runtime_Test_Catalog_Lane_Start_And_Verification_Governance
- 04981_Policy_Tenant_Store_RLS_Access_Control_Test_Catalog
- 04991_Audit_Append_Only_Evidence_And_Tamper_Resistance_Test_Catalog_Policy
- 05011_Policy_Payment_Webhook_Refund_Settlement_Reconciliation_Test_Catalog

---

## 5. Affected Runtime

This test catalog affects:

- Identity Runtime
- Customer Runtime
- Membership Runtime
- Support Runtime
- HQ Admin Runtime
- Store Staff Runtime
- POS Runtime
- KDS Runtime
- Payment Runtime
- Export Runtime
- AI Analytics Runtime
- Vendor Integration Runtime
- Audit Runtime
- Incident Runtime
- Deployment Runtime

Identity runtime may create linkage, but ordinary operational runtimes must receive only derived, masked, or purpose-limited identity information.

---

## 6. Risk Categories

This catalog covers the following risk categories:

- raw CI leakage
- raw DI leakage
- invalid identity callback accepted
- replayed identity callback accepted
- duplicate callback creates duplicate account linkage
- wrong customer session linked
- wrong tenant account linked
- account merge without authority
- duplicate account auto-merge
- identity correction overwrites history
- support sees raw CI / DI by default
- store staff sees verified identity data
- POS/KDS receives raw identity
- payment runtime uses CI / DI as general tracking key
- identity export allowed by default
- AI dataset includes raw identity
- logs or audit contain raw CI / DI
- vendor receives identity data without approval
- leakage response missing
- deployment without identity callback/masking tests

Critical failures in these categories block implementation.

---

## 7. Test Data Setup Requirement

Future tests should include at least:

- Tenant A
- Tenant B
- Store A1
- Store A2
- Customer A
- Customer B
- Customer Session A
- Customer Session B
- Public Service Account A
- Tenant Profile A
- Identity Provider Valid Callback A
- Identity Provider Invalid Callback
- Identity Provider Duplicate Callback
- Identity Provider Replayed Callback
- Callback With Wrong State
- Callback With Wrong Nonce where applicable
- Callback With Wrong Customer Session
- Callback With Wrong Tenant Mapping
- Verified Identity Reference A
- Duplicate Account Candidate A
- Account Merge Request A
- Identity Correction Request A
- Support Case A
- Support Agent Assigned
- Support Agent Unassigned
- Store Staff A1
- POS/KDS Payload Candidate
- Export Request Candidate
- AI Dataset Candidate
- Identity Leakage Incident Candidate
- Audit Event Candidate
- Evidence Packet Candidate

Test data must include valid, invalid, duplicate, replayed, and cross-context callback scenarios.

---

## 8. Test ID Naming Rule

Recommended test id format:

    TC-IDENTITY-[NUMBER]-[TYPE]

Examples:

    TC-IDENTITY-001-POSITIVE
    TC-IDENTITY-002-NEGATIVE
    TC-IDENTITY-003-CALLBACK
    TC-IDENTITY-004-IDEMPOTENCY
    TC-IDENTITY-005-REPLAY
    TC-IDENTITY-006-MASKING
    TC-IDENTITY-007-LEAKAGE
    TC-IDENTITY-008-AUDIT
    TC-IDENTITY-009-DEPLOY

Final test IDs may change later.

Traceability must remain stable.

---

## 9. Positive Tests

### TC-IDENTITY-001-POSITIVE: Valid Identity Callback Creates Verified Identity Linkage

Precondition:

- Customer Session A exists.
- Identity verification request was initiated.
- Provider callback is valid.
- State and nonce are valid where applicable.
- Provider transaction id is valid.

Action:

- Identity callback is processed.

Expected result:

- Verified identity linkage is created.
- Linkage belongs to correct customer/account context.
- Raw CI / DI storage follows approved storage direction.
- Derived identity status becomes verified or linked.
- Audit event is created.

Evidence:

- linkage record
- derived status record
- callback verification record
- audit event

---

### TC-IDENTITY-002-POSITIVE: Derived Identity Status Is Visible Without Raw CI / DI

Precondition:

- Customer A has verified identity linkage.
- Authorized runtime requests identity status.

Action:

- Runtime requests derived identity status.

Expected result:

- Derived status such as IDENTITY_VERIFIED is returned.
- Raw CI / DI is not returned.
- Access scope is respected.

Evidence:

- response sample
- masking verification

---

### TC-IDENTITY-003-POSITIVE: Duplicate Account Candidate Can Be Created Without Auto-Merge

Precondition:

- Two accounts have matching verified identity evidence under allowed rule.
- Duplicate detection is triggered.

Action:

- Duplicate candidate is created.

Expected result:

- Duplicate candidate record is created.
- Accounts are not merged automatically.
- Evidence is masked.
- Audit event is created.

Evidence:

- duplicate candidate record
- no merge confirmation
- audit event

---

### TC-IDENTITY-004-POSITIVE: Authorized Identity Correction Creates Append-Only Correction

Precondition:

- Identity linkage correction is required.
- Authorized identity specialist or approved workflow exists.

Action:

- Correction is applied.

Expected result:

- Original linkage remains traceable.
- Correction record is appended.
- Audit event links original and corrected state.
- Raw CI / DI is masked in audit.

Evidence:

- original linkage
- correction record
- audit lineage

---

## 10. Negative Tests

### TC-IDENTITY-005-NEGATIVE: Store Staff Cannot See Raw CI / DI

Precondition:

- Store staff has valid Store A1 operational access.
- Customer A has CI / DI identity linkage.

Action:

- Store staff requests customer or order view.

Expected result:

- Raw CI / DI is not visible.
- Staff receives only operationally necessary customer display data.
- No identity linkage key appears.

Failure severity:

- CRITICAL if raw CI / DI is exposed

Evidence:

- staff view sample
- masking verification

---

### TC-IDENTITY-006-NEGATIVE: POS/KDS Payload Does Not Include Raw Identity

Precondition:

- Customer A has verified identity.
- Order creates POS/KDS payload.

Action:

- POS/KDS payload is inspected.

Expected result:

- Payload excludes raw CI, DI, provider callback data, identity linkage key, and legal identity reference.
- Only operationally necessary masked identifier appears if needed.

Failure severity:

- CRITICAL

Evidence:

- POS/KDS payload sample
- field exclusion verification

---

### TC-IDENTITY-007-NEGATIVE: Support Cannot See Raw CI / DI By Default

Precondition:

- Support case exists.
- Support agent is assigned.
- Customer has verified identity.

Action:

- Support agent views case.

Expected result:

- Identity status may be visible.
- Raw CI / DI is not visible.
- Unmask approval is required for exceptional access.

Failure severity:

- CRITICAL if raw CI / DI visible by default

Evidence:

- support view sample
- masking verification

---

### TC-IDENTITY-008-NEGATIVE: Payment Runtime Cannot Use CI / DI As General Tracking Key

Precondition:

- Payment record exists for verified customer.

Action:

- Payment runtime requests identity linkage.

Expected result:

- Payment runtime receives only allowed payment customer reference or derived linkage status where approved.
- Raw CI / DI is not exposed.
- CI / DI is not used as ordinary payment tracking key.

Failure severity:

- HIGH to CRITICAL depending exposure

Evidence:

- payment runtime data sample
- field exclusion verification

---

### TC-IDENTITY-009-NEGATIVE: AI Cannot Receive Raw CI / DI

Precondition:

- AI support summary or dataset generation is requested.
- Source data includes verified identity.

Action:

- AI context or dataset is generated.

Expected result:

- Raw CI / DI is excluded.
- Identity provider callback payload is excluded.
- Account linkage key is excluded.
- Derived masked status only may appear where approved.

Failure severity:

- CRITICAL

Evidence:

- AI context inspection
- AI audit event

---

## 11. Callback Validation Tests

### TC-IDENTITY-010-CALLBACK: Valid State And Session Binding Are Required

Precondition:

- Identity verification request was initiated with state parameter.
- Callback includes matching state and session binding.

Action:

- Callback is processed.

Expected result:

- Validation passes.
- Linkage is applied to correct customer session.

Evidence:

- callback validation record
- linkage record

---

### TC-IDENTITY-011-CALLBACK: Invalid State Is Rejected

Precondition:

- Callback contains invalid or unknown state.

Action:

- Callback is processed.

Expected result:

- Callback is rejected or quarantined.
- No identity linkage occurs.
- Audit event is created.

Failure severity:

- CRITICAL

Evidence:

- rejection record
- no linkage proof
- audit event

---

### TC-IDENTITY-012-CALLBACK: Invalid Nonce Is Rejected Where Applicable

Precondition:

- Identity flow uses nonce.
- Callback contains invalid nonce.

Action:

- Callback is processed.

Expected result:

- Callback is rejected or quarantined.
- No linkage occurs.
- Audit event is created.

Failure severity:

- CRITICAL

Evidence:

- rejection record
- audit event

---

### TC-IDENTITY-013-CALLBACK: Callback Without Expected Session Is Rejected

Precondition:

- Callback cannot be bound to expected customer session.

Action:

- Callback is processed.

Expected result:

- Callback is rejected or marked review-required.
- No identity linkage occurs.

Failure severity:

- CRITICAL

Evidence:

- rejection record
- no linkage proof

---

### TC-IDENTITY-014-CALLBACK: Callback With Wrong Customer Session Is Rejected

Precondition:

- Customer A initiated verification.
- Callback attempts to bind to Customer B session.

Action:

- Callback is processed.

Expected result:

- Callback is rejected or quarantined.
- No Customer B linkage occurs.

Failure severity:

- CRITICAL

Evidence:

- rejection record
- Customer B unchanged proof

---

### TC-IDENTITY-015-CALLBACK: Callback With Wrong Tenant Mapping Is Rejected

Precondition:

- Callback belongs to Tenant A context.
- Payload or mapping attempts Tenant B account linkage.

Action:

- Callback is processed.

Expected result:

- Callback is rejected or quarantined.
- No cross-tenant identity linkage occurs.

Failure severity:

- CRITICAL

Evidence:

- rejection record
- audit event

---

## 12. Callback Idempotency Tests

### TC-IDENTITY-016-IDEMPOTENCY: Duplicate Callback Does Not Create Duplicate Linkage

Precondition:

- Valid callback was already processed.
- Identity linkage exists.

Action:

- Same callback is delivered again.

Expected result:

- No duplicate linkage is created.
- Prior result is returned or duplicate is safely ignored.
- Duplicate trace or audit exists where required.

Failure severity:

- HIGH

Evidence:

- linkage count comparison
- idempotency record

---

### TC-IDENTITY-017-IDEMPOTENCY: Duplicate Callback Does Not Create Duplicate Account

Precondition:

- Valid identity callback created or linked account.

Action:

- Duplicate callback is processed.

Expected result:

- No duplicate customer account is created.
- No duplicate membership identity is created.

Failure severity:

- HIGH

Evidence:

- account count comparison
- duplicate trace

---

### TC-IDENTITY-018-IDEMPOTENCY: Same Provider Transaction With Conflicting Payload Is Quarantined

Precondition:

- Provider transaction id was processed.
- New callback uses same provider transaction id with conflicting identity result.

Action:

- Callback is processed.

Expected result:

- Callback is quarantined.
- Existing linkage is not silently changed.
- Review or incident path is created.

Failure severity:

- CRITICAL

Evidence:

- quarantine record
- linkage unchanged proof
- audit event

---

## 13. Callback Replay Tests

### TC-IDENTITY-019-REPLAY: Replayed Callback Does Not Mutate Final Linkage

Precondition:

- Identity linkage is already final.
- Old callback is replayed.

Action:

- Replayed callback is processed.

Expected result:

- Final linkage is not silently mutated.
- Replay is detected, ignored safely, or quarantined.
- Audit event is created.

Failure severity:

- CRITICAL if final linkage changes incorrectly

Evidence:

- before/after linkage comparison
- replay audit

---

### TC-IDENTITY-020-REPLAY: Expired Callback Is Rejected

Precondition:

- Callback timestamp is outside allowed freshness window.

Action:

- Callback is processed.

Expected result:

- Callback is rejected or quarantined.
- No linkage mutation occurs.

Failure severity:

- HIGH

Evidence:

- rejection record
- audit event

---

### TC-IDENTITY-021-REPLAY: Replay Cannot Relink Account After Correction

Precondition:

- Original linkage was corrected.
- Old callback is replayed.

Action:

- Replayed callback is processed.

Expected result:

- Old callback does not reverse correction.
- Review or replay-detected status is recorded.

Failure severity:

- CRITICAL

Evidence:

- correction still active
- replay record

---

## 14. Account Linkage Tests

### TC-IDENTITY-022-LINKAGE: Public Service Identity Does Not Expose Cross-Tenant Tracking Key

Precondition:

- Customer A participates in multiple tenant/store contexts.
- Public service identity exists.

Action:

- Tenant/store runtime requests customer context.

Expected result:

- Tenant/store runtime does not receive raw CI / DI or universal tracking key.
- Store-specific benefit rules use scoped references.

Failure severity:

- HIGH to CRITICAL depending exposure

Evidence:

- tenant/store response sample
- linkage field inspection

---

### TC-IDENTITY-023-LINKAGE: Tenant Profile Linkage Is Scoped

Precondition:

- Customer A has public account and Tenant A profile.
- Tenant B exists.

Action:

- Tenant A runtime requests tenant profile.

Expected result:

- Only Tenant A profile is returned.
- Tenant B data is excluded.

Failure severity:

- CRITICAL if cross-tenant leakage occurs

Evidence:

- response sample
- tenant scope verification

---

### TC-IDENTITY-024-LINKAGE: Identity Linkage Is Not Visible As Staff Lookup Key

Precondition:

- Store staff searches customer operational data.

Action:

- Staff attempts lookup by identity linkage key or raw CI / DI.

Expected result:

- Lookup is denied or unsupported.
- Raw identity is not searchable by staff.

Failure severity:

- CRITICAL

Evidence:

- lookup denial
- search result sample

---

## 15. Duplicate Account And Merge Tests

### TC-IDENTITY-025-DUPLICATE: Duplicate Candidate Does Not Auto-Merge

Precondition:

- Duplicate candidate is detected.

Action:

- Candidate creation workflow completes.

Expected result:

- Candidate status is review-required.
- Accounts remain separate until approved merge.

Failure severity:

- HIGH

Evidence:

- candidate record
- separate account proof

---

### TC-IDENTITY-026-MERGE: Unauthorized Actor Cannot Merge Accounts

Precondition:

- Duplicate candidate exists.
- Actor lacks merge authority.

Action:

- Actor attempts account merge.

Expected result:

- Merge is denied.
- Accounts remain separate.
- Audit event is created.

Failure severity:

- CRITICAL

Evidence:

- denial result
- account state unchanged
- audit event

---

### TC-IDENTITY-027-MERGE: AI Recommendation Cannot Merge Accounts

Precondition:

- AI recommends likely duplicate account.

Action:

- AI output attempts merge action.

Expected result:

- Merge does not occur.
- AI output remains recommendation only.
- Human/system approval remains required.

Failure severity:

- CRITICAL if merge occurs

Evidence:

- AI output
- account state unchanged

---

### TC-IDENTITY-028-MERGE: Approved Merge Creates Audit And Evidence

Precondition:

- Duplicate candidate exists.
- Authorized merge approval exists.

Action:

- Merge is performed.

Expected result:

- Merge is completed within approved scope.
- Audit event is created.
- Evidence packet links candidate, approval, merge decision, and affected accounts.
- Raw CI / DI is masked.

Evidence:

- merge record
- audit event
- evidence packet

---

## 16. Identity Correction Tests

### TC-IDENTITY-029-CORRECTION: Correction Does Not Overwrite Original Linkage

Precondition:

- Identity linkage exists and is incorrect.

Action:

- Authorized correction is applied.

Expected result:

- Original linkage remains traceable.
- Correction record is appended.
- Audit lineage exists.

Failure severity:

- CRITICAL if history overwritten

Evidence:

- original linkage
- correction record
- audit lineage

---

### TC-IDENTITY-030-CORRECTION: Unauthorized Correction Is Denied

Precondition:

- Actor lacks identity correction authority.

Action:

- Actor attempts correction.

Expected result:

- Correction is denied.
- Identity linkage remains unchanged.
- Audit event is created where required.

Failure severity:

- CRITICAL

Evidence:

- denial result
- linkage unchanged proof

---

### TC-IDENTITY-031-CORRECTION: Customer Request Requires Verification Before Sensitive Change

Precondition:

- Customer requests identity-sensitive correction.
- Customer request is unverified.

Action:

- Correction is attempted.

Expected result:

- Correction is not finalized.
- Verification or review is required.

Failure severity:

- HIGH

Evidence:

- correction pending/rejected status
- verification requirement record

---

## 17. Support Visibility Tests

### TC-IDENTITY-032-SUPPORT: Assigned Support Sees Masked Identity Status Only

Precondition:

- Support agent is assigned to identity support case.
- Customer has verified identity.

Action:

- Support agent views case.

Expected result:

- Support sees masked identity status.
- Raw CI / DI is hidden.
- Access is audited.

Failure severity:

- CRITICAL if raw CI / DI visible

Evidence:

- support view sample
- support audit

---

### TC-IDENTITY-033-SUPPORT: Unassigned Support Cannot View Identity Case

Precondition:

- Support agent is not assigned to case.

Action:

- Support agent attempts to view identity case.

Expected result:

- Access is denied.
- Audit event is created where required.

Failure severity:

- HIGH

Evidence:

- denial result
- audit event

---

### TC-IDENTITY-034-SUPPORT: Identity Unmask Requires Approval

Precondition:

- Support agent requests raw or fuller identity access.

Action:

- Unmask request is submitted.

Expected result:

- Data remains masked until approved.
- Request is audited.
- Approval is time-bound and scoped if granted.

Failure severity:

- CRITICAL if unmask occurs without approval

Evidence:

- unmask request
- masked state before approval
- audit event

---

### TC-IDENTITY-035-SUPPORT: Unmask Approval Expires

Precondition:

- Identity unmask approval exists with expiration.

Action:

- Support attempts unmask after expiration.

Expected result:

- Access is denied.
- Approval does not remain permanent.

Failure severity:

- HIGH

Evidence:

- denial result
- approval expiration record

---

## 18. HQ And Store Visibility Tests

### TC-IDENTITY-036-HQ: HQ Identity Reviewer Sees Scoped Masked Review Queue

Precondition:

- HQ identity reviewer has valid role.
- Identity review queue exists.

Action:

- Reviewer opens queue.

Expected result:

- Scoped review items are visible.
- Raw CI / DI is masked unless exceptional approval exists.
- Access is audited.

Evidence:

- HQ view sample
- audit event

---

### TC-IDENTITY-037-STORE: Store Staff Operational View Excludes Legal Identity

Precondition:

- Store staff views waiting/order/customer operational screen.

Action:

- Staff opens customer/order record.

Expected result:

- Staff sees only operational label or masked contact where allowed.
- Legal identity, raw CI / DI, identity provider reference, and account linkage key are excluded.

Failure severity:

- CRITICAL if raw identity exposed

Evidence:

- staff operational view sample

---

## 19. Export Restriction Tests

### TC-IDENTITY-038-EXPORT: Raw CI / DI Export Is Denied By Default

Precondition:

- Actor requests export containing raw CI / DI.

Action:

- Export request is evaluated.

Expected result:

- Export is denied by default.
- Export denial audit is created.

Failure severity:

- CRITICAL

Evidence:

- export denial
- audit event

---

### TC-IDENTITY-039-EXPORT: Identity Export Requires Exceptional Approval

Precondition:

- Legal or customer data request requires identity export.
- Approval workflow exists.

Action:

- Identity export is requested.

Expected result:

- Export requires explicit purpose, scope, approval, masking where possible, secure delivery, and audit.
- Without approval, export is denied.

Failure severity:

- CRITICAL if exported without approval

Evidence:

- approval record or denial
- export audit

---

### TC-IDENTITY-040-EXPORT: Support Export Excludes Raw Identity

Precondition:

- Support case export is authorized.

Action:

- Support export is generated.

Expected result:

- Export excludes raw CI / DI, provider callback payload, account linkage key, and legal identity reference unless specifically approved.
- Export is masked.

Failure severity:

- CRITICAL

Evidence:

- export sample inspection

---

## 20. AI Dataset Exclusion Tests

### TC-IDENTITY-041-AI: AI Dataset Excludes Raw CI / DI

Precondition:

- AI dataset generation includes customer/account data.

Action:

- Dataset is generated.

Expected result:

- Raw CI / DI are excluded.
- Identity provider callback payload is excluded.
- Account linkage key is excluded.
- AI audit records exclusion.

Failure severity:

- CRITICAL

Evidence:

- dataset inspection
- AI audit

---

### TC-IDENTITY-042-AI: Prompt Does Not Include Identity Provider Callback Payload

Precondition:

- AI support summary is requested for identity case.

Action:

- Prompt/context is generated.

Expected result:

- Prompt excludes raw callback payload.
- Prompt uses masked summary or derived status only.

Failure severity:

- CRITICAL

Evidence:

- prompt/context inspection

---

### TC-IDENTITY-043-AI: AI Output Must Not Reconstruct Masked Identity

Precondition:

- AI receives masked identity summary.

Action:

- AI output is generated.

Expected result:

- AI does not infer, reconstruct, or invent raw CI / DI, full legal identity, or account linkage key.
- Unsafe output is blocked or reviewed.

Failure severity:

- HIGH to CRITICAL depending exposure

Evidence:

- AI output sample
- output safety review

---

## 21. Log And Audit Masking Tests

### TC-IDENTITY-044-MASKING: Logs Do Not Store Raw CI / DI

Precondition:

- Identity verification, callback, linkage, or correction occurs.

Action:

- Logs are inspected.

Expected result:

- Logs exclude raw CI / DI, provider callback payload, identity provider secret, full phone/email where restricted, and authorization headers.

Failure severity:

- CRITICAL

Evidence:

- log sample inspection

---

### TC-IDENTITY-045-MASKING: Audit Does Not Store Raw CI / DI

Precondition:

- Identity audit event is created.

Action:

- Audit payload is inspected.

Expected result:

- Audit excludes raw CI / DI.
- Audit uses masked reference or derived identity status.

Failure severity:

- CRITICAL

Evidence:

- audit sample inspection

---

### TC-IDENTITY-046-MASKING: Error Responses Do Not Reveal Identity Internals

Precondition:

- Identity callback or linkage fails.

Action:

- Error response is returned.

Expected result:

- Error does not reveal raw identity, callback payload, provider transaction secret, or account linkage internals.

Failure severity:

- HIGH

Evidence:

- error response sample

---

## 22. Leakage Detection Tests

### TC-IDENTITY-047-LEAKAGE: Raw CI / DI In Log Triggers Leakage Review

Precondition:

- Test or scanner detects raw CI / DI pattern in log.

Action:

- Leakage detection runs.

Expected result:

- Leakage review is triggered.
- Incident candidate or security review record is created.
- Containment path is identified.

Failure severity:

- CRITICAL if not detected

Evidence:

- leakage detection record
- review/incident candidate

---

### TC-IDENTITY-048-LEAKAGE: Raw Identity In Export Triggers Incident Path

Precondition:

- Export contains raw identity unexpectedly.

Action:

- Export leakage detection or review runs.

Expected result:

- Export is revoked where possible.
- Incident or leakage response path is triggered.
- Audit and evidence are preserved.

Failure severity:

- CRITICAL

Evidence:

- revocation record
- incident record
- evidence packet

---

### TC-IDENTITY-049-LEAKAGE: Raw Identity In AI Dataset Triggers Dataset Purge Path

Precondition:

- AI dataset contains raw identity unexpectedly.

Action:

- Leakage response runs.

Expected result:

- Dataset is quarantined or purged.
- AI usage is blocked.
- Incident review is triggered.
- Evidence is preserved.

Failure severity:

- CRITICAL

Evidence:

- dataset purge/quarantine record
- incident evidence

---

### TC-IDENTITY-050-LEAKAGE: Support Unmask Without Approval Triggers Misuse Review

Precondition:

- Support actor accesses raw identity without valid approval.

Action:

- Misuse detection runs.

Expected result:

- Support misuse review or incident path is triggered.
- Session may be revoked.
- Audit evidence is preserved.

Failure severity:

- CRITICAL

Evidence:

- misuse review record
- session revocation where applicable

---

## 23. Vendor Identity Tests

### TC-IDENTITY-051-VENDOR: Identity Provider Callback Credential Is Environment-Scoped

Precondition:

- Staging and production identity provider credentials exist separately.

Action:

- Callback is processed in wrong environment.

Expected result:

- Callback is rejected.
- No production identity linkage occurs in non-production context.

Failure severity:

- CRITICAL

Evidence:

- environment validation result
- rejection record

---

### TC-IDENTITY-052-VENDOR: Vendor Sharing Of Identity Data Requires Approval

Precondition:

- Vendor data sharing request includes identity data.

Action:

- Request is evaluated.

Expected result:

- Sharing is denied unless explicit approval, purpose, scope, masking, and audit exist.
- Raw CI / DI is prohibited by default.

Failure severity:

- CRITICAL if shared without approval

Evidence:

- vendor sharing denial or approval record
- audit event

---

## 24. Audit Tests

### TC-IDENTITY-053-AUDIT: Identity Callback Creates Audit

Precondition:

- Identity callback is received.

Action:

- Callback validation completes.

Expected result:

- Audit event records callback received and validation result.
- Raw CI / DI is excluded.

Failure severity:

- HIGH

Evidence:

- audit event

---

### TC-IDENTITY-054-AUDIT: Identity Linkage Creates Audit

Precondition:

- Valid callback creates identity linkage.

Action:

- Linkage is created.

Expected result:

- Audit event records linkage created, actor/service, tenant/account context, and result.
- Raw CI / DI is excluded.

Failure severity:

- HIGH

Evidence:

- audit event

---

### TC-IDENTITY-055-AUDIT: Account Merge Creates Audit

Precondition:

- Approved account merge occurs.

Action:

- Merge completes.

Expected result:

- Audit event records candidate, approval, actor, and merge result.
- Sensitive evidence is masked.

Failure severity:

- HIGH

Evidence:

- audit event

---

### TC-IDENTITY-056-AUDIT: Identity Leakage Response Creates Audit

Precondition:

- Identity leakage is suspected or confirmed.

Action:

- Response workflow starts.

Expected result:

- Audit records detection, containment, affected scope, and review status.
- Raw leaked values are not copied unnecessarily into audit.

Failure severity:

- HIGH

Evidence:

- leakage audit event

---

## 25. Evidence Packet Tests

### TC-IDENTITY-057-EVIDENCE: Identity Evidence Packet Contains Required References

Precondition:

- Identity linkage or correction requires evidence packet.

Action:

- Evidence packet is created.

Expected result:

- Packet includes callback verification result, masked customer reference, linkage state, audit references, and review status.
- Raw CI / DI is excluded unless specially protected and explicitly required.

Evidence:

- evidence packet sample

---

### TC-IDENTITY-058-EVIDENCE: Duplicate Account Evidence Packet Does Not Expose Raw Identity

Precondition:

- Duplicate account candidate exists.

Action:

- Evidence packet is generated.

Expected result:

- Packet includes masked evidence and candidate references.
- Raw CI / DI is not exposed to ordinary reviewer.

Failure severity:

- CRITICAL if raw CI / DI exposed

Evidence:

- evidence packet inspection

---

### TC-IDENTITY-059-EVIDENCE: Leakage Evidence Packet Preserves Containment Record

Precondition:

- Identity leakage incident candidate exists.

Action:

- Evidence packet is generated.

Expected result:

- Packet includes detection, affected category, containment action, audit references, and review status.
- Raw leaked data is minimized.

Evidence:

- leakage evidence packet

---

## 26. Deployment Gate Tests For Identity

### TC-IDENTITY-060-DEPLOY: Identity Release Requires Callback Validation Tests

Precondition:

- Release changes identity callback or verification flow.

Action:

- Release gate evaluates deployment.

Expected result:

- Release is blocked unless callback validation tests exist.
- Gate result is audited.

Failure severity:

- CRITICAL

Evidence:

- release gate result
- test evidence reference

---

### TC-IDENTITY-061-DEPLOY: Identity Release Requires Masking Tests

Precondition:

- Release changes identity display, support view, export, audit, or AI dataset.

Action:

- Release gate evaluates masking test evidence.

Expected result:

- Release is blocked unless masking tests exist.

Failure severity:

- CRITICAL

Evidence:

- release gate result
- masking test reference

---

### TC-IDENTITY-062-DEPLOY: Identity Release Requires Leakage Response Test

Precondition:

- Release introduces or changes CI / DI storage, export, or AI handling.

Action:

- Release gate evaluates leakage response readiness.

Expected result:

- Release is blocked unless leakage detection/response path is mapped and tested.

Failure severity:

- CRITICAL

Evidence:

- release gate result
- leakage response test reference

---

### TC-IDENTITY-063-DEPLOY: Identity Provider Credential Must Be Environment-Separated

Precondition:

- Release configures identity provider credentials.

Action:

- Release gate checks credential environment.

Expected result:

- Release is blocked if production credential is used in local/dev/staging incorrectly.
- Secret review and audit required.

Failure severity:

- CRITICAL

Evidence:

- secret gate result
- deployment audit

---

## 27. Regression Tests

Regression tests should be created for every identity failure.

Regression candidates:

- invalid callback accepted
- replayed callback changed linkage
- duplicate callback created duplicate account
- wrong customer session linked
- cross-tenant identity linkage
- duplicate candidate auto-merged
- unauthorized account merge
- identity correction overwrote history
- support saw raw CI / DI
- store staff saw legal identity
- POS/KDS payload included raw identity
- export included raw identity
- AI dataset included raw identity
- logs or audit stored raw CI / DI
- vendor received identity data without approval
- leakage response failed
- identity release skipped callback/masking tests

Every identity incident should generate a regression test.

---

## 28. Coverage Matrix

Recommended coverage matrix:

| Area | Positive | Negative | Callback | Idempotency | Replay | Masking | Leakage | Deploy |
| ---- | -------- | -------- | -------- | ----------- | ------ | ------- | ------- | ------ |
| Identity Callback | Required | Required | Required | Required | Required | Required | Conditional | Required |
| Identity Linkage | Required | Required | Conditional | Required | Required | Required | Conditional | Required |
| Account Duplicate | Required | Required | N/A | Conditional | Conditional | Required | Conditional | Conditional |
| Account Merge | Required | Required | N/A | Conditional | Conditional | Required | Conditional | Conditional |
| Identity Correction | Required | Required | N/A | Conditional | Required | Required | Conditional | Conditional |
| Support View | Required | Required | N/A | N/A | N/A | Required | Required | Required |
| Store/POS/KDS View | Required | Required | N/A | N/A | N/A | Required | Required | Required |
| Export | Required | Required | N/A | N/A | N/A | Required | Required | Required |
| AI Dataset | Required | Required | N/A | N/A | N/A | Required | Required | Required |
| Vendor Sharing | Conditional | Required | Conditional | Conditional | Conditional | Required | Required | Conditional |
| Leakage Response | Required | Required | N/A | N/A | N/A | Required | Required | Required |

Coverage gaps become blockers.

---

## 29. Evidence Requirements

Evidence must prove:

- valid identity callback creates correct linkage
- invalid state is rejected
- invalid nonce is rejected where applicable
- missing or wrong session is rejected
- wrong tenant mapping is rejected
- duplicate callback does not duplicate linkage or account
- conflicting provider transaction is quarantined
- replay does not mutate final linkage
- public service identity does not expose cross-tenant tracking key
- duplicate account candidate does not auto-merge
- unauthorized account merge is denied
- AI cannot merge accounts
- correction is append-only
- support sees masked identity by default
- unmask requires approval and expires
- store staff cannot see raw CI / DI
- POS/KDS excludes raw identity
- export of raw identity is denied by default
- AI dataset excludes raw CI / DI
- logs and audit exclude raw CI / DI
- leakage detection and response paths exist
- vendor identity sharing requires approval
- identity audit events exist
- evidence packets minimize raw identity
- release gates block unsafe identity changes

Evidence must not expose the raw CI / DI that it proves are protected.

---

## 30. Failure Severity

Critical failures include:

- invalid callback creates linkage
- replayed callback mutates final linkage
- duplicate callback creates duplicate account
- wrong customer linked
- cross-tenant identity linkage
- raw CI / DI visible to staff, support by default, POS/KDS, export, AI, logs, or audit
- unauthorized account merge
- AI merges account
- correction overwrites identity history
- identity export without approval
- leakage response missing for raw identity exposure
- production identity release without callback/masking tests

High failures include:

- duplicate account candidate auto-merge risk
- unmask approval does not expire
- support identity access not case-scoped
- derived identity status over-discloses
- vendor identity sharing lacks review
- identity audit missing for major event
- evidence packet exposes too much identity detail

Medium failures include:

- customer-safe identity message unclear but not leaking sensitive data
- non-sensitive masking inconsistency
- low-risk audit category mismatch

Critical and high failures block implementation.

---

## 31. Implementation Blockers

Implementation must be blocked if:

- callback validation tests are missing
- state/nonce tests are missing where applicable
- session binding tests are missing
- tenant context tests are missing
- callback idempotency tests are missing
- callback replay tests are missing
- duplicate account tests are missing
- account merge authority tests are missing
- identity correction append-only tests are missing
- support masking tests are missing
- staff/POS/KDS identity exclusion tests are missing
- export restriction tests are missing
- AI dataset exclusion tests are missing
- log/audit masking tests are missing
- leakage detection tests are missing
- leakage response tests are missing
- vendor identity sharing tests are missing
- identity audit tests are missing
- evidence packet tests are missing
- deployment gate tests are missing

These blockers must be added to the implementation blocker register.

---

## 32. Test Status Values

Recommended status values:

- `NOT_DEFINED`
- `DRAFT`
- `MAPPED`
- `READY_FOR_REVIEW`
- `READY_FOR_IMPLEMENTATION`
- `IMPLEMENTED`
- `PASS`
- `FAIL`
- `BLOCKED`
- `WAIVED_WITH_APPROVAL`
- `DEFERRED`
- `OBSOLETE`

Critical identity tests should not be waived unless the identity-related feature is removed from implementation scope.

---

## 33. Non-Goals

This document does not define:

- final identity provider
- final CI / DI storage design
- final callback handler
- final encryption implementation
- final RLS policy
- final masking function
- final support identity UI
- final account merge implementation
- final leakage scanner
- final AI dataset pipeline
- final export service
- final automated test code
- final production deployment

Those belong to later controlled implementation phase.

---

## 34. Readiness Check

This test catalog is ready when the project can answer:

1. How is valid identity callback tested?
2. How is invalid state rejected?
3. How is invalid nonce rejected where applicable?
4. How is callback session binding tested?
5. How is wrong customer session rejected?
6. How is wrong tenant mapping rejected?
7. How is duplicate callback idempotency tested?
8. How is conflicting provider transaction quarantined?
9. How is replayed callback tested?
10. How is account linkage scoped?
11. How is public service identity separated from tenant identity?
12. How is duplicate account candidate tested?
13. How is auto-merge prevented?
14. How is account merge authority tested?
15. How is AI merge authority denied?
16. How is identity correction append-only?
17. How is support identity visibility masked?
18. How does unmask approval work and expire?
19. How is store staff identity restriction tested?
20. How is POS/KDS identity exclusion tested?
21. How is identity export denied by default?
22. How is AI dataset exclusion tested?
23. How are logs and audit checked for raw CI / DI?
24. How is identity leakage detected?
25. How is identity leakage response tested?
26. How is vendor identity sharing controlled?
27. How are identity audit events tested?
28. How are evidence packets tested?
29. How do release gates protect identity changes?
30. What regression tests are required?
31. What evidence is required?
32. What failures are critical?
33. What blocks implementation?

If these questions cannot be answered, CI / DI identity callback masking leakage test catalog is incomplete.

---

## 35. Conclusion

CI / DI and verified identity linkage are highly sensitive boundaries in the Yoonsul Wait/Order Handoff project.

The system must preserve the following rules:

- identity callback must be verified
- state and session binding must be tested
- nonce must be tested where applicable
- invalid callback must not create linkage
- duplicate callback must not duplicate linkage or account
- replayed callback must not mutate final linkage
- wrong customer or tenant linkage must be denied
- public service identity must not expose cross-tenant tracking key
- duplicate candidate must not auto-merge
- account merge requires authority
- AI must not merge accounts
- identity correction must be append-only
- support sees masked identity by default
- unmasking requires scoped approval
- store staff must not see raw CI / DI
- POS/KDS must not receive raw identity
- payment runtime must not use CI / DI as ordinary tracking key
- identity export is denied by default
- AI datasets must exclude raw CI / DI
- logs and audit must exclude raw CI / DI
- leakage detection and response must exist
- vendor identity sharing requires approval
- identity actions must be audited
- evidence packets must minimize raw identity
- deployment gates must block unsafe identity changes
- critical failures block implementation

This document does not implement identity tests.

It defines the CI / DI identity callback masking leakage test catalog that future implementation must satisfy.