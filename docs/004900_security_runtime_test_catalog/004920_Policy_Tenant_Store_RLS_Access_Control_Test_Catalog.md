# 004981_Policy_Tenant_Store_RLS_Access_Control_Test_Catalog

## 1. Purpose

This document defines the test catalog policy for tenant isolation, store isolation, RLS behavior, role scope, actor context, service identity scope, support scope, owner scope, staff scope, customer self-scope, and cross-context denial in the Yoonsul Wait/Order Handoff project.

Tenant and store isolation are the foundation of SaaS safety.

If tenant/store boundary fails, every other policy becomes unreliable.

Therefore, tenant/store/RLS access control must have explicit positive tests, negative tests, abuse-case tests, audit tests, masking tests, and evidence requirements before implementation is allowed.

This document does not implement SQL tests, RLS policies, RPC functions, API tests, or UI tests.

It defines the test catalog that future implementation must satisfy.

---

## 2. Scope

This test catalog applies to:

- tenant isolation
- store isolation
- RLS deny-by-default behavior
- actor role scope
- affiliation scope
- owner store access
- staff store assignment access
- customer self-scope
- support case-scope access
- HQ role access
- service identity access
- POS/KDS tenant/store context
- payment tenant/store context
- identity tenant/store context
- export tenant/store scope
- AI dataset tenant/store scope
- local agent tenant/store scope
- vendor tenant/store scope
- audit access scope
- safe error behavior
- test evidence requirements
- implementation blockers

This document focuses on access control test design.

---

## 3. Core Principle

Tenant/store access control must be proven by denial tests, not only allowed access tests.

The project must follow this rule:

> A user seeing their own allowed data is not enough. The system must prove they cannot see, mutate, export, infer, or route data across unauthorized tenant or store boundaries.

Access control must be tested against misuse.

---

## 4. Source Mapping Documents

This test catalog verifies constraints from:

- 04831_Implementation_Mapping_Lane_Start_And_Policy_To_Code_Constraint_Handoff_Policy
- 04841_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping
- 04851_Audit_Event_Taxonomy_Append_Only_And_Evidence_Implementation_Mapping_Policy
- 04861_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Implementation_Mapping
- 04871_Policy_Payment_Webhook_Refund_Settlement_And_Reconciliation_Implementation_Mapping
- 04881_Policy_CI_DI_Identity_Linkage_Callback_Masking_And_Leakage_Response_Implementation_Mapping
- 04891_Policy_Support_Access_Masking_Break_Glass_And_Scoped_Session_Implementation_Mapping
- 04901_Policy_Device_Trust_Session_Revocation_Store_Runtime_And_Lost_Device_Implementation_Mapping
- 04911_Policy_Local_Agent_Degraded_Recovery_Sync_Conflict_And_Manual_Evidence_Implementation_Mapping
- 04921_Policy_Export_Report_Benchmark_External_Sharing_And_Data_Extraction_Implementation_Mapping
- 04931_Policy_AI_Analytics_Dataset_Minimization_Model_Output_And_Recommendation_Boundary_Implementation_Mapping
- 04941_Policy_Vendor_Partner_Access_Third_Party_Risk_And_External_Integration_Implementation_Mapping
- 04951_Policy_Secure_Deployment_Environment_Separation_Release_Gate_And_Rollback_Implementation_Mapping
- 04971_Policy_Security_And_Runtime_Test_Catalog_Lane_Start_And_Verification_Governance

---

## 5. Affected Runtime

This test catalog affects:

- Customer Runtime
- Staff Runtime
- Store Tablet Runtime
- Owner Runtime
- HQ Admin Runtime
- Support Runtime
- POS Runtime
- KDS Runtime
- POS/KDS Bridge Runtime
- Payment Runtime
- Identity Runtime
- Export Runtime
- AI Analytics Runtime
- Local Agent Runtime
- Vendor Integration Runtime
- Audit Runtime
- Deployment Runtime

Tenant/store scope must be validated across all runtimes, not only database reads.

---

## 6. Risk Categories

This catalog covers the following risk categories:

- cross-tenant read
- cross-tenant mutation
- cross-tenant export
- cross-store read
- cross-store mutation
- cross-store export
- role escalation
- affiliation bypass
- support overreach
- owner overreach
- staff overreach
- customer data leakage
- service identity overreach
- RLS bypass
- UI-only filtering dependency
- unsafe error disclosure
- AI dataset contamination
- vendor scope leakage
- local agent cross-store sync
- audit scope leakage

Any critical failure in these categories blocks implementation.

---

## 7. Test Data Setup Requirement

Future tests should include at least:

- Tenant A
- Tenant B
- Store A1 under Tenant A
- Store A2 under Tenant A
- Store B1 under Tenant B
- Customer A
- Customer B
- Staff A1 assigned to Store A1
- Staff A2 assigned to Store A2
- Owner A authorized for Store A1 only
- Owner A-wide authorized for Store A1 and A2 where needed
- Owner B authorized for Tenant B
- HQ operator with limited scope
- HQ lead with broader scope
- Support agent assigned to Case A1
- Support agent not assigned to Case A1
- POS Terminal A1
- KDS Device A1
- Local Agent A1
- Vendor A scoped to Tenant A or Store A1
- Service identity scoped to a defined runtime

Test data must intentionally create near-neighbor contexts to catch leakage.

---

## 8. Test ID Naming Rule

Recommended test id format:

    TC-TENANT-[NUMBER]-[TYPE]

Examples:

    TC-TENANT-001-POSITIVE
    TC-TENANT-002-NEGATIVE
    TC-TENANT-003-ABUSE
    TC-TENANT-004-RLS
    TC-TENANT-005-STORE
    TC-TENANT-006-SERVICE
    TC-TENANT-007-EXPORT
    TC-TENANT-008-AI

Final test IDs may change later.

Traceability must remain stable.

---

## 9. Positive Tests

### TC-TENANT-001-POSITIVE: Customer Can Access Own Customer Data

Precondition:

- Customer A is authenticated.
- Customer A has own order, waiting session, and membership data.

Action:

- Customer A requests own scoped data.

Expected result:

- Request succeeds.
- Only Customer A data is returned.
- Tenant/store context is correct.
- No unrelated customer data appears.

Evidence:

- response scope sample
- access audit where required
- no leakage confirmation

---

### TC-TENANT-002-POSITIVE: Staff Can Access Assigned Store Operational Data

Precondition:

- Staff A1 is assigned to Store A1.
- Store A1 has operational records.

Action:

- Staff A1 requests allowed operational view for Store A1.

Expected result:

- Request succeeds.
- Only allowed Store A1 operational data is returned.
- Sensitive restricted fields remain masked or unavailable.

Evidence:

- staff access result
- masking result
- audit event where required

---

### TC-TENANT-003-POSITIVE: Owner Can Access Authorized Store Summary

Precondition:

- Owner A is authorized for Store A1.
- Store A1 has sales/order summary.

Action:

- Owner A requests Store A1 summary.

Expected result:

- Request succeeds.
- Store A1 summary is returned.
- Unrelated store data is excluded.

Evidence:

- owner scope result
- store filter verification
- audit event where required

---

### TC-TENANT-004-POSITIVE: Support Can Access Assigned Case Summary

Precondition:

- Support Agent S is assigned to Support Case A1.
- Case A1 is scoped to Tenant A and Store A1.

Action:

- Support Agent S opens Case A1 summary.

Expected result:

- Request succeeds.
- Only case-scoped data is visible.
- Default masking applies.
- No unrelated tenant/store/customer data appears.

Evidence:

- support session record
- masked case view
- support audit event

---

### TC-TENANT-005-POSITIVE: Service Identity Can Access Its Allowed Runtime Scope

Precondition:

- POS/KDS Bridge Service A1 is registered for Tenant A and Store A1.
- Bridge action is allowed.

Action:

- Bridge Service A1 processes allowed Store A1 event.

Expected result:

- Request succeeds.
- Scope is limited to Tenant A and Store A1.
- Action is audited where required.

Evidence:

- service identity validation result
- event processing result
- audit event

---

## 10. Negative Tests

### TC-TENANT-006-NEGATIVE: Customer Cannot Access Another Customer Data

Precondition:

- Customer A and Customer B exist.
- Customer B has order or membership data.

Action:

- Customer A attempts to request Customer B data.

Expected result:

- Request is denied.
- No Customer B data is returned.
- Error is safe.
- Audit is created where required.

Failure severity:

- CRITICAL

Evidence:

- denied response
- no data leakage confirmation
- audit event where required

---

### TC-TENANT-007-NEGATIVE: Owner Cannot Access Unrelated Store

Precondition:

- Owner A is authorized for Store A1 only.
- Store A2 exists under same tenant.
- Store B1 exists under different tenant.

Action:

- Owner A attempts to access Store A2 or Store B1.

Expected result:

- Unauthorized access is denied.
- No store data is returned.
- Error does not reveal sensitive details.

Failure severity:

- HIGH for same-tenant wrong store
- CRITICAL for cross-tenant store

Evidence:

- denial result
- audit event where required

---

### TC-TENANT-008-NEGATIVE: Staff Cannot Access Unassigned Store

Precondition:

- Staff A1 is assigned to Store A1.
- Store A2 exists.

Action:

- Staff A1 attempts to access Store A2 operational data.

Expected result:

- Access is denied.
- No Store A2 data is returned.
- Safe error is returned.

Failure severity:

- HIGH

Evidence:

- denied response
- staff scope verification
- audit event where required

---

### TC-TENANT-009-NEGATIVE: Support Cannot Access Case Without Assignment

Precondition:

- Support Case A1 exists.
- Support Agent S is not assigned to Case A1.

Action:

- Support Agent S attempts to open Case A1.

Expected result:

- Access is denied.
- No case data is returned.
- Support audit or denied access event is created.

Failure severity:

- HIGH

Evidence:

- denial result
- support audit event

---

### TC-TENANT-010-NEGATIVE: HQ Limited Role Cannot Access Restricted Tenant Data

Precondition:

- HQ operator has limited role.
- Restricted tenant data exists.

Action:

- HQ operator attempts to access restricted tenant-level data beyond role.

Expected result:

- Access is denied.
- Safe error is returned.
- Audit event is created where required.

Failure severity:

- HIGH

Evidence:

- denied response
- role scope evaluation
- audit event

---

## 11. Cross-Tenant Abuse Tests

### TC-TENANT-011-ABUSE: Tenant ID Payload Tampering Is Denied

Precondition:

- Actor belongs to Tenant A.
- Request payload includes tenant_id for Tenant B.

Action:

- Actor sends request with modified tenant_id.

Expected result:

- Server-side context validation rejects request.
- Payload tenant_id is not trusted.
- No Tenant B data is returned or mutated.

Failure severity:

- CRITICAL

Evidence:

- rejected request
- server-side context validation evidence
- audit event

---

### TC-TENANT-012-ABUSE: Cross-Tenant Export Attempt Is Denied

Precondition:

- Actor has export authority for Tenant A only.
- Tenant B data exists.

Action:

- Actor attempts to generate export including Tenant B data.

Expected result:

- Export is denied.
- No file is generated.
- Export audit records denial.

Failure severity:

- CRITICAL

Evidence:

- export denial
- export audit event
- no generated file confirmation

---

### TC-TENANT-013-ABUSE: Cross-Tenant AI Dataset Contamination Is Blocked

Precondition:

- AI dataset request is scoped to Tenant A.
- Tenant B operational data exists.

Action:

- AI dataset generation attempts to include Tenant B data.

Expected result:

- Dataset generation is denied or Tenant B data is excluded.
- Audit records dataset scope.
- No cross-tenant data enters AI context.

Failure severity:

- CRITICAL

Evidence:

- dataset scope record
- exclusion result
- AI audit event

---

### TC-TENANT-014-ABUSE: Vendor Cannot Access Unapproved Tenant

Precondition:

- Vendor V is approved for Tenant A only.
- Tenant B exists.

Action:

- Vendor V calls API for Tenant B resource.

Expected result:

- Access is denied.
- Vendor audit event is created.
- No Tenant B data is returned.

Failure severity:

- CRITICAL

Evidence:

- vendor denial
- vendor audit event

---

## 12. Cross-Store Abuse Tests

### TC-TENANT-015-ABUSE: POS Terminal Cannot Submit Event For Another Store

Precondition:

- POS Terminal A1 is registered to Store A1.
- Store A2 exists.

Action:

- POS Terminal A1 sends event with Store A2 context.

Expected result:

- Event is rejected or quarantined.
- No Store A2 order/ticket is created.
- Audit event is created.

Failure severity:

- CRITICAL

Evidence:

- rejected event
- quarantine or audit record
- no mutation confirmation

---

### TC-TENANT-016-ABUSE: KDS Device Cannot View Another Store Tickets

Precondition:

- KDS Device A1 is registered to Store A1.
- Store A2 has tickets.

Action:

- KDS Device A1 requests Store A2 tickets.

Expected result:

- Access is denied.
- No Store A2 ticket data is returned.

Failure severity:

- HIGH

Evidence:

- denied response
- KDS device scope verification

---

### TC-TENANT-017-ABUSE: Local Agent Cannot Sync Another Store Data

Precondition:

- Local Agent A1 is bound to Store A1.
- Store A2 exists.

Action:

- Local Agent A1 attempts to sync Store A2 fallback records.

Expected result:

- Sync is denied or quarantined.
- No Store A2 state is accepted.
- Audit event is created.

Failure severity:

- CRITICAL

Evidence:

- sync rejection
- local agent audit
- central verification denial

---

### TC-TENANT-018-ABUSE: Support Case Scope Does Not Expand To Same Tenant Store

Precondition:

- Support Agent S is assigned to Case A1 for Store A1.
- Store A2 exists under Tenant A.

Action:

- Support Agent S attempts to browse Store A2 data through same tenant context.

Expected result:

- Access is denied unless case explicitly includes Store A2.
- Support session scope remains narrow.

Failure severity:

- HIGH

Evidence:

- denial result
- support scoped session record

---

## 13. RLS Deny-By-Default Tests

### TC-TENANT-019-RLS: Unauthenticated Access Is Denied

Precondition:

- Protected table or view exists.
- Request has no valid authenticated context.

Action:

- Unauthenticated request attempts to read protected data.

Expected result:

- Access is denied.
- No protected data is returned.

Failure severity:

- CRITICAL

Evidence:

- denied response
- RLS evaluation evidence where available

---

### TC-TENANT-020-RLS: Unknown Role Gets No Data

Precondition:

- Actor exists with no valid role/affiliation for target resource.

Action:

- Actor requests protected resource.

Expected result:

- Access is denied.
- Default behavior is no access.

Failure severity:

- HIGH

Evidence:

- denied response
- role evaluation result

---

### TC-TENANT-021-RLS: Missing Tenant Context Is Denied

Precondition:

- Request lacks tenant context or tenant context cannot be derived.

Action:

- Request attempts protected read or mutation.

Expected result:

- Request is denied.
- No fallback to broad access occurs.

Failure severity:

- CRITICAL

Evidence:

- denial result
- audit event where required

---

### TC-TENANT-022-RLS: Missing Store Context Is Denied For Store-Scoped Resource

Precondition:

- Resource requires store context.
- Request lacks store context.

Action:

- Request attempts read or mutation.

Expected result:

- Request is denied.
- No all-store access is granted.

Failure severity:

- HIGH

Evidence:

- denial result
- store context validation evidence

---

## 14. Role And Affiliation Tests

### TC-TENANT-023-ROLE: Role Without Affiliation Is Insufficient

Precondition:

- Actor has generic role label but no valid tenant/store affiliation.

Action:

- Actor attempts store-scoped access.

Expected result:

- Access is denied.
- Role label alone is insufficient.

Failure severity:

- HIGH

Evidence:

- denied response
- affiliation check record

---

### TC-TENANT-024-ROLE: Expired Affiliation Is Denied

Precondition:

- Actor previously had Store A1 affiliation.
- Affiliation is expired or revoked.

Action:

- Actor attempts Store A1 access.

Expected result:

- Access is denied.
- Former affiliation does not grant access.

Failure severity:

- HIGH

Evidence:

- denial result
- affiliation status evidence

---

### TC-TENANT-025-ROLE: Backup Authority Is Time-Scoped

Precondition:

- HQ lead has backup authority under scoped condition.
- Backup scope expires.

Action:

- HQ lead attempts backup action after expiration.

Expected result:

- Access is denied.
- Backup authority does not become permanent.

Failure severity:

- HIGH

Evidence:

- denial result
- backup scope record
- audit event

---

## 15. Device-Aware Access Tests

### TC-TENANT-026-DEVICE: Trusted Device Allows Scoped Action

Precondition:

- Actor has allowed role.
- Device is trusted and scoped to Store A1.

Action:

- Actor performs allowed Store A1 action.

Expected result:

- Action succeeds.
- Device identity is recorded where required.

Evidence:

- success result
- device/session context evidence

---

### TC-TENANT-027-DEVICE: Revoked Device Is Denied Even With Valid User

Precondition:

- Actor has valid role.
- Device is revoked.

Action:

- Actor attempts protected action from revoked device.

Expected result:

- Access is denied.
- Session is invalidated where applicable.
- Audit event is created.

Failure severity:

- CRITICAL

Evidence:

- denial result
- revocation record
- audit event

---

### TC-TENANT-028-DEVICE: Staff Mobile Cannot Perform Store Tablet Only Action

Precondition:

- Staff user has valid store role.
- Device role is Staff Mobile.
- Action requires Store Tablet.

Action:

- Staff Mobile attempts Store Tablet-only action.

Expected result:

- Action is denied.
- Device role boundary is enforced.

Failure severity:

- HIGH

Evidence:

- denial result
- device role evaluation

---

## 16. Service Identity Scope Tests

### TC-TENANT-029-SERVICE: Bridge Service Cannot Use Broad Tenant Scope

Precondition:

- Bridge service is scoped to Store A1.

Action:

- Bridge service attempts broad tenant-level operation.

Expected result:

- Operation is denied unless explicitly authorized.
- Store-scoped bridge identity remains limited.

Failure severity:

- HIGH

Evidence:

- denial result
- service identity audit

---

### TC-TENANT-030-SERVICE: Payment Webhook Service Validates Tenant Store Mapping

Precondition:

- Payment webhook event references payment for Store A1.
- Payload attempts mismatch with Store A2.

Action:

- Webhook handler processes event.

Expected result:

- Event is rejected or quarantined.
- No Store A2 payment state is changed.

Failure severity:

- CRITICAL

Evidence:

- webhook quarantine record
- audit event

---

### TC-TENANT-031-SERVICE: Identity Callback Cannot Link Wrong Tenant Account

Precondition:

- Identity callback belongs to Customer A under Tenant A context.
- Callback attempts to link to Tenant B account.

Action:

- Identity callback is processed.

Expected result:

- Callback is rejected or quarantined.
- No cross-tenant identity linkage occurs.

Failure severity:

- CRITICAL

Evidence:

- callback rejection
- identity audit event

---

## 17. Mutation Tests

### TC-TENANT-032-MUTATION: Cross-Tenant Mutation Is Denied

Precondition:

- Actor belongs to Tenant A.
- Tenant B resource exists.

Action:

- Actor attempts mutation on Tenant B resource.

Expected result:

- Mutation is denied.
- Tenant B resource remains unchanged.
- Audit event is created where required.

Failure severity:

- CRITICAL

Evidence:

- denial result
- before/after resource comparison
- audit event

---

### TC-TENANT-033-MUTATION: Cross-Store Mutation Is Denied

Precondition:

- Actor is authorized for Store A1.
- Store A2 resource exists.

Action:

- Actor attempts mutation on Store A2 resource.

Expected result:

- Mutation is denied.
- Store A2 resource remains unchanged.

Failure severity:

- HIGH

Evidence:

- denial result
- before/after resource comparison

---

### TC-TENANT-034-MUTATION: UI Filter Removal Does Not Expose Mutation

Precondition:

- Frontend UI normally filters store list.
- Actor manipulates request manually.

Action:

- Actor sends direct mutation request for unauthorized store.

Expected result:

- Server denies mutation.
- UI-only filtering is not relied upon.

Failure severity:

- CRITICAL

Evidence:

- direct request denial
- server-side access evidence

---

## 18. Safe Error Tests

### TC-TENANT-035-ERROR: Unauthorized Tenant Error Does Not Reveal Data

Precondition:

- Actor attempts unauthorized tenant access.

Action:

- Request is denied.

Expected result:

- Error does not expose tenant details, customer identity, payment state, or internal schema.
- Error is safe and generic.

Failure severity:

- MEDIUM to HIGH depending data leaked

Evidence:

- error response sample
- leakage review

---

### TC-TENANT-036-ERROR: Unauthorized Store Error Does Not Reveal Sensitive Store Data

Precondition:

- Actor attempts unauthorized store access.

Action:

- Request is denied.

Expected result:

- Error does not reveal sensitive store operational details.
- Error does not reveal unrelated customer/order data.

Evidence:

- error response sample
- leakage review

---

## 19. Audit And Evidence Tests

### TC-TENANT-037-AUDIT: High-Risk Denied Access Creates Audit

Precondition:

- Cross-tenant access attempt occurs.

Action:

- System denies access.

Expected result:

- Audit event is created with actor, tenant/store attempted scope, action, result, and reason class.
- Audit does not include secrets.

Failure severity:

- HIGH if audit missing for critical denial

Evidence:

- audit event sample
- masking verification

---

### TC-TENANT-038-AUDIT: Support Cross-Scope Attempt Creates Support Audit

Precondition:

- Support actor attempts case access outside assignment.

Action:

- Access is denied.

Expected result:

- Support audit event is created.
- Possible misuse indicator is recorded if repeated.

Evidence:

- support audit event
- misuse indicator where applicable

---

### TC-TENANT-039-EVIDENCE: Access Control Evidence Packet Can Be Created

Precondition:

- Critical cross-tenant abuse attempt occurs.

Action:

- Security review creates or links evidence packet.

Expected result:

- Evidence packet includes denial, audit, actor, scope, and impact summary.
- Evidence packet does not expose unnecessary sensitive data.

Evidence:

- evidence packet sample

---

## 20. Masking Tests

### TC-TENANT-040-MASKING: Authorized Scope Still Masks Restricted Fields

Precondition:

- Actor is authorized to view operational summary.
- Data includes restricted fields.

Action:

- Actor requests allowed summary.

Expected result:

- Allowed data is returned.
- Restricted fields are masked or excluded.

Failure severity:

- HIGH if sensitive fields exposed

Evidence:

- response sample
- masking verification

---

### TC-TENANT-041-MASKING: Support Case View Masks Identity And Payment Fields

Precondition:

- Support agent is assigned to case.
- Case includes identity and payment references.

Action:

- Support agent views case.

Expected result:

- Raw CI / DI is not visible.
- Payment tokens/secrets are not visible.
- Masked references are shown where allowed.

Failure severity:

- CRITICAL if raw CI / DI or payment secret exposed

Evidence:

- support view sample
- masking verification

---

## 21. Export Scope Tests

### TC-TENANT-042-EXPORT: Owner Export Is Store-Scoped

Precondition:

- Owner A is authorized for Store A1.
- Store A2 and Tenant B data exist.

Action:

- Owner A requests export.

Expected result:

- Export includes only Store A1 data.
- Store A2 and Tenant B data are excluded.
- Export audit is created.

Failure severity:

- CRITICAL for cross-tenant leakage
- HIGH for same-tenant unauthorized store leakage

Evidence:

- export scope sample
- export audit event

---

### TC-TENANT-043-EXPORT: Support Export Requires Case Scope

Precondition:

- Support agent has no assigned case.

Action:

- Support agent requests export of customer/order data.

Expected result:

- Export is denied.
- Export audit records denial.

Failure severity:

- HIGH

Evidence:

- export denial
- export audit event

---

## 22. AI Dataset Scope Tests

### TC-TENANT-044-AI: AI Dataset Is Tenant Scoped

Precondition:

- AI dataset request is for Tenant A.
- Tenant B data exists.

Action:

- Dataset generation runs.

Expected result:

- Tenant B data is excluded.
- Dataset scope is recorded.
- AI audit event is created.

Failure severity:

- CRITICAL

Evidence:

- dataset scope record
- AI audit event

---

### TC-TENANT-045-AI: AI Dataset Is Store Scoped Where Required

Precondition:

- AI dataset request is for Store A1.
- Store A2 data exists.

Action:

- Dataset generation runs.

Expected result:

- Store A2 data is excluded unless explicitly authorized and aggregated.
- Scope is recorded.

Failure severity:

- HIGH

Evidence:

- dataset sample summary
- scope record

---

## 23. POS/KDS Context Tests

### TC-TENANT-046-POSKDS: POS Accepted Order Requires Matching Tenant Store

Precondition:

- POS Terminal A1 is bound to Tenant A and Store A1.

Action:

- POS accepted order event is submitted with mismatched tenant/store.

Expected result:

- Event is rejected or quarantined.
- No KDS ticket is created for wrong store.

Failure severity:

- CRITICAL

Evidence:

- event rejection
- quarantine record
- audit event

---

### TC-TENANT-047-POSKDS: KDS Status Update Requires Matching Ticket Store

Precondition:

- KDS Device A1 is bound to Store A1.
- Ticket A2 belongs to Store A2.

Action:

- KDS Device A1 attempts to update Ticket A2.

Expected result:

- Update is denied.
- Ticket A2 remains unchanged.

Failure severity:

- HIGH

Evidence:

- denied response
- before/after ticket state

---

## 24. Payment Context Tests

### TC-TENANT-048-PAYMENT: Payment Confirmation Requires Matching Store Context

Precondition:

- Payment belongs to Store A1.
- Webhook or internal event attempts Store A2 mapping.

Action:

- Payment confirmation is processed.

Expected result:

- Event is rejected or quarantined.
- Payment state is not changed under wrong store.

Failure severity:

- CRITICAL

Evidence:

- payment event audit
- quarantine record

---

### TC-TENANT-049-PAYMENT: Refund Request Cannot Target Another Store Payment

Precondition:

- Actor is authorized for Store A1.
- Payment belongs to Store A2.

Action:

- Actor requests refund for Store A2 payment.

Expected result:

- Refund request is denied.
- Audit event created where required.

Failure severity:

- CRITICAL

Evidence:

- refund denial
- audit event

---

## 25. Local Agent Scope Tests

### TC-TENANT-050-LOCALAGENT: Local Agent Cannot Cross Tenant Boundary

Precondition:

- Local Agent A1 belongs to Tenant A.
- Tenant B exists.

Action:

- Local Agent A1 syncs event with Tenant B context.

Expected result:

- Sync is denied or quarantined.
- No Tenant B state is changed.

Failure severity:

- CRITICAL

Evidence:

- sync denial
- local agent audit

---

### TC-TENANT-051-LOCALAGENT: Fallback Record Preserves Store Scope

Precondition:

- Local Agent A1 creates fallback-originated record for Store A1.

Action:

- Record syncs to central.

Expected result:

- Record remains Store A1-scoped.
- Central verification validates store scope.
- Record cannot be reassigned to Store A2 silently.

Failure severity:

- HIGH

Evidence:

- synced record scope
- central verification result

---

## 26. Vendor Scope Tests

### TC-TENANT-052-VENDOR: Vendor API Is Tenant Scoped

Precondition:

- Vendor V is approved for Tenant A.
- Tenant B exists.

Action:

- Vendor V requests Tenant B data.

Expected result:

- Request is denied.
- Vendor audit event is created.

Failure severity:

- CRITICAL

Evidence:

- vendor denial
- audit event

---

### TC-TENANT-053-VENDOR: Vendor Data Feed Excludes Unapproved Store

Precondition:

- Vendor V is approved for Store A1.
- Store A2 exists.

Action:

- Vendor data feed is generated.

Expected result:

- Feed includes only Store A1 data.
- Store A2 data excluded.

Failure severity:

- HIGH

Evidence:

- feed scope summary
- vendor export audit

---

## 27. Deployment Gate Tests For RLS

### TC-TENANT-054-DEPLOY: RLS Change Requires Isolation Test Evidence

Precondition:

- Release includes RLS or access control change.

Action:

- Release gate evaluates deployment.

Expected result:

- Release is blocked unless tenant/store isolation test evidence exists.
- Gate result is audited.

Failure severity:

- CRITICAL

Evidence:

- release gate denial or approval
- test evidence reference
- deployment audit event

---

### TC-TENANT-055-DEPLOY: Public Read Policy Cannot Be Introduced Without Review

Precondition:

- Release attempts to add broad public read.

Action:

- Release gate evaluates policy change.

Expected result:

- Release is blocked or requires explicit high-risk approval.
- Evidence and audit are required.

Failure severity:

- CRITICAL

Evidence:

- release gate result
- approval record if allowed

---

## 28. Regression Tests

Regression tests should be created for every fixed access control defect.

Regression candidates:

- cross-tenant read defect
- cross-store read defect
- owner overreach defect
- staff overreach defect
- support overreach defect
- service identity overreach defect
- export leakage defect
- AI dataset contamination defect
- local agent cross-store sync defect
- vendor scope defect
- RLS policy regression

Every access control incident should generate a regression test.

---

## 29. Coverage Matrix

Recommended coverage matrix:

| Area | Positive | Negative | Abuse | Audit | Masking | Export | AI | Deployment |
| ---- | -------- | -------- | ----- | ----- | ------- | ------ | -- | ---------- |
| Customer Self-Scope | Required | Required | Required | Conditional | Required | Conditional | Conditional | N/A |
| Staff Store Scope | Required | Required | Required | Conditional | Required | N/A | N/A | N/A |
| Owner Store Scope | Required | Required | Required | Conditional | Required | Required | Conditional | N/A |
| Support Case Scope | Required | Required | Required | Required | Required | Required | Conditional | N/A |
| Service Identity Scope | Required | Required | Required | Required | Required | Conditional | Conditional | N/A |
| POS/KDS Scope | Required | Required | Required | Required | Required | N/A | N/A | Conditional |
| Payment Scope | Required | Required | Required | Required | Required | Required | Conditional | Conditional |
| Local Agent Scope | Required | Required | Required | Required | Required | N/A | N/A | Conditional |
| Vendor Scope | Required | Required | Required | Required | Required | Required | Conditional | Conditional |
| RLS Release Gate | N/A | Required | Required | Required | N/A | N/A | N/A | Required |

Coverage gaps become blockers.

---

## 30. Evidence Requirements

Evidence must prove:

- tenant isolation works
- store isolation works
- RLS deny-by-default works
- role alone is insufficient
- affiliation is checked
- expired affiliation is denied
- support case scope is enforced
- owner scope is enforced
- staff assignment scope is enforced
- customer self-scope is enforced
- device trust affects access
- service identity is scoped
- POS/KDS context is validated
- payment context is validated
- identity callback context is validated
- local agent scope is enforced
- export scope is enforced
- AI dataset scope is enforced
- vendor scope is enforced
- deployment gate blocks untested RLS changes
- safe errors do not leak data
- audit events exist for high-risk denials

Evidence must not expose secrets, raw CI / DI, payment tokens, or unrelated tenant data.

---

## 31. Failure Severity

Critical failures include:

- cross-tenant read
- cross-tenant mutation
- cross-tenant export
- cross-tenant AI dataset contamination
- cross-tenant vendor access
- payment state mutation under wrong tenant/store
- identity linkage under wrong tenant
- RLS bypass exposing protected data
- service role leak to client
- public read/write accidentally introduced

High failures include:

- cross-store read without authority
- cross-store mutation
- support case overreach
- owner unrelated store access
- staff unassigned store access
- local agent wrong store sync
- KDS wrong store ticket access
- export wrong store data leakage

Medium failures include:

- overly detailed safe error
- missing audit for lower-risk denial
- minor masking inconsistency without sensitive leakage

Critical and high failures block implementation.

---

## 32. Implementation Blockers

Implementation must be blocked if:

- tenant isolation tests are missing
- store isolation tests are missing
- RLS deny-by-default tests are missing
- role/affiliation tests are missing
- support scope tests are missing
- owner scope tests are missing
- staff scope tests are missing
- customer self-scope tests are missing
- service identity tests are missing
- POS/KDS context tests are missing
- payment context tests are missing
- identity context tests are missing
- local agent scope tests are missing
- export scope tests are missing
- AI dataset scope tests are missing
- vendor scope tests are missing
- RLS deployment gate tests are missing
- critical denial audit tests are missing
- safe error tests are missing

These blockers must be added to the implementation blocker register.

---

## 33. Test Status Values

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

High-risk access control tests should not be waived casually.

---

## 34. Non-Goals

This document does not define:

- final SQL test code
- final RLS policy
- final database schema
- final API implementation
- final Flutter UI
- final automated test runner
- final CI/CD test job
- final seed data script
- final production monitoring
- final deployment

Those belong to later controlled implementation phase.

---

## 35. Readiness Check

This test catalog is ready when the project can answer:

1. What tenant/store access risks are covered?
2. What test data setup is required?
3. What positive access tests exist?
4. What negative access tests exist?
5. What abuse cases exist?
6. How is cross-tenant access denied?
7. How is cross-store access denied?
8. How is RLS deny-by-default tested?
9. How is role plus affiliation tested?
10. How is expired affiliation tested?
11. How is device-aware access tested?
12. How is service identity scope tested?
13. How are cross-tenant mutations tested?
14. How are UI-filter bypass attempts tested?
15. How are safe errors tested?
16. How is audit tested?
17. How is masking tested?
18. How is export scope tested?
19. How is AI dataset scope tested?
20. How is POS/KDS context tested?
21. How is payment context tested?
22. How is local agent scope tested?
23. How is vendor scope tested?
24. How does deployment gate prevent untested RLS change?
25. What regression tests are required?
26. What coverage matrix exists?
27. What evidence is required?
28. What failures are critical?
29. What blocks implementation?

If these questions cannot be answered, tenant/store/RLS test catalog is incomplete.

---

## 36. Conclusion

Tenant/store/RLS access control is the foundation of the Yoonsul Wait/Order Handoff SaaS architecture.

The system must preserve the following rules:

- tenant isolation must be tested
- store isolation must be tested
- RLS must deny by default
- role alone is not enough
- affiliation must be valid
- expired affiliation must fail
- UI filtering is not security
- support access must be case-scoped
- owner access must be store-scoped
- staff access must be assignment-scoped
- customer access must be self-scoped
- device trust must affect access
- service identity must be scoped
- POS/KDS events must validate tenant/store
- payment events must validate tenant/store
- identity callbacks must validate context
- local agent must not cross store boundary
- export must not cross unauthorized scope
- AI datasets must not mix tenants or stores
- vendors must not exceed approved scope
- RLS changes must be release-gated
- safe errors must not leak data
- audit must exist for high-risk denials
- critical failures block implementation

This document does not implement tests.

It defines the tenant/store/RLS test catalog that future implementation must satisfy.