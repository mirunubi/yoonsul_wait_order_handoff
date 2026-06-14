# 09540 Universal Integration Reconciliation And Idempotency Catalog Policy

## 1. Purpose

This document defines the universal reconciliation and idempotency catalog policy for all system integrations.

The purpose is to ensure that when two or more systems disagree, duplicate, delay, replay, partially apply, or lose integration events, the project has a controlled reconciliation and duplicate-prevention model before runtime implementation begins.

This applies not only to financial settlement, but also to membership, coupon, wallet, identity, POS, KDS, inventory, content, i18n, AI, external projection, support/admin, provider, supplier, SCM, WMS, workforce, and Franchise OS integrations.

This document does not authorize coding.

Coding remains deferred unless a specific package has `CODING_ALLOWED`, a completed handoff record, a narrow work order, required tests, and review approval.

---

## 2. Scope

This policy applies to reconciliation and idempotency planning for:

1. Membership points, grades, visits, and benefits
2. Coupon issuance, reservation, usage, cancellation, and expiration
3. Wallet/prepaid balance charge, use, refund, hold, and adjustment
4. Customer identity linking and unlinking
5. POS order events
6. Payment and provider callbacks
7. Settlement ledger entries
8. KDS ticket creation and status changes
9. Inventory and sold-out updates
10. External menu projection publication and rollback
11. Content registry and i18n key propagation
12. AI output attachment and support draft handling
13. Support/admin case actions
14. Supplier/SCM/WMS sync
15. Workforce/HR sync
16. Franchise OS policy, royalty, and store sync
17. Provider capability and evidence state changes

This document defines catalog rules only.

It does not implement reconciliation jobs, queues, database constraints, RPCs, event processors, or UI tools.

---

## 3. Core Principle

Reconciliation and idempotency are universal integration safeguards.

Idempotency prevents duplicate events from creating duplicate effects.

Reconciliation detects and resolves disagreement between systems.

A retry must not create duplicate value.

A callback must not become final truth without verification.

A later event must not silently overwrite an earlier event.

A support action must not resolve a mismatch without evidence.

A UI refresh must not create authority.

A partner sync must not override internal source of truth without a contract.

---

## 4. Reconciliation Definition

Reconciliation is required when two or more systems disagree on an authority-sensitive fact.

Authority-sensitive facts include:

- customer identity
- membership point balance
- membership grade
- coupon state
- wallet/prepaid balance
- order state
- payment state
- refund state
- settlement ledger state
- KDS ticket state
- inventory availability
- sold-out state
- menu projection state
- allergen/price/translation state
- support case state
- provider capability state
- workforce attendance/role state
- franchise policy/royalty state

Reconciliation must produce a traceable result.

Silent overwrite is prohibited.

---

## 5. Idempotency Definition

Idempotency means that repeated processing of the same logical event does not create duplicate effects.

Idempotency is required when an event can create or change:

- money
- value
- points
- coupons
- wallet balance
- customer identity
- order status
- payment/refund status
- settlement ledger entries
- KDS tickets
- inventory state
- menu projection
- support case action
- provider capability state
- AI draft attachment
- workforce attendance record
- franchise policy state

Every state-changing integration event must define an idempotency key or equivalent duplicate-prevention rule.

---

## 6. Universal Reconciliation Record

Every reconciliation process must produce a reconciliation record.

Minimum fields:

| Field | Required Meaning |
|---|---|
| Reconciliation id | Stable reconciliation identifier |
| Domain | Membership, payment, KDS, inventory, etc. |
| Source system | First system involved |
| Target system | Second system involved |
| Conflict family | Controlled mismatch type |
| Correlation id | Cross-system link |
| Affected entity | Customer, order, payment, ticket, content, etc. |
| Source state | State from source |
| Target state | State from target |
| Internal authority | Which system is source of truth |
| Evidence packet id | Evidence reference |
| Audit event id | Audit reference |
| Resolution status | Open, pending, resolved, deferred, rejected |
| Resolution method | Manual review, replay, correction, rollback, reject |
| Actor/system actor | Who or what resolved |
| Customer impact | None, possible, confirmed |
| Created timestamp | Record creation time |
| Resolved timestamp | Resolution time if any |

A reconciliation record must not be replaced by a simple status flag.

---

## 7. Universal Idempotency Record

Every idempotent event family must define an idempotency record or logical equivalent.

Minimum fields:

| Field | Required Meaning |
|---|---|
| Idempotency key | Stable duplicate-prevention key |
| Event family | Event type |
| Domain | Membership, payment, KDS, etc. |
| Source system | Event origin |
| Target system | Event consumer |
| Scope | Tenant/store/customer/order/payment/etc. |
| First seen timestamp | First processing time |
| Last seen timestamp | Latest duplicate/retry time |
| Processing status | Accepted, duplicate, replay, rejected, conflict |
| Result reference | Created object or result |
| Replay policy | Whether replay is allowed |
| Conflict policy | What happens if duplicate payload differs |
| Audit link | Audit event if high-risk |
| Evidence link | Evidence packet if needed |

Idempotency must be scoped narrowly enough to prevent false merging.

---

## 8. Idempotency Key Scope Rule

An idempotency key must include or derive from the correct scope.

Recommended scope components:

- tenant id
- store id
- source system
- event family
- provider event id if applicable
- customer/session id if applicable
- order id if applicable
- payment id if applicable
- coupon id if applicable
- wallet transaction id if applicable
- KDS ticket id if applicable
- projection version if applicable
- timestamp window if applicable

A global idempotency key without domain and context is unsafe.

A local key without tenant/store context is unsafe.

---

## 9. Duplicate Event Classification

Duplicate events must be classified.

| Duplicate Class | Meaning |
|---|---|
| `DUPLICATE_EXACT_REPLAY` | Same event, same payload |
| `DUPLICATE_SAFE_RETRY` | Retry allowed and result reused |
| `DUPLICATE_PAYLOAD_MISMATCH` | Same key but payload differs |
| `DUPLICATE_OUT_OF_ORDER` | Older event arrives after newer event |
| `DUPLICATE_CROSS_STORE_RISK` | Duplicate appears across store boundary |
| `DUPLICATE_CROSS_CUSTOMER_RISK` | Duplicate appears across customer boundary |
| `DUPLICATE_VALUE_RISK` | Duplicate may create extra value |
| `DUPLICATE_TICKET_RISK` | Duplicate may create extra KDS/order ticket |
| `DUPLICATE_PUBLICATION_RISK` | Duplicate may publish wrong content |
| `DUPLICATE_REQUIRES_REVIEW` | Duplicate cannot be auto-resolved |

Duplicate classification must drive alert and reconciliation behavior.

---

## 10. Reconciliation Status Catalog

Reconciliation status values must be controlled.

| Status | Meaning |
|---|---|
| `RECON_NOT_REQUIRED` | Reconciliation not needed |
| `RECON_CANDIDATE` | Mismatch candidate detected |
| `RECON_OPEN` | Reconciliation case open |
| `RECON_EVIDENCE_REQUIRED` | Evidence required |
| `RECON_PROVIDER_EVIDENCE_REQUIRED` | Provider evidence required |
| `RECON_MANUAL_REVIEW_REQUIRED` | Human review required |
| `RECON_REPLAY_REQUIRED` | Replay needed |
| `RECON_CORRECTION_REQUIRED` | Correction entry/action needed |
| `RECON_ROLLBACK_REQUIRED` | Rollback required |
| `RECON_CUSTOMER_RECOVERY_REQUIRED` | Customer recovery likely |
| `RECON_RESOLVED` | Resolved |
| `RECON_REJECTED_FALSE_POSITIVE` | Rejected after review |
| `RECON_DEFERRED` | Deferred with reason |
| `RECON_REOPENED` | Reopened due to new evidence |

These statuses must not be collapsed into `done`.

---

## 11. Idempotency Status Catalog

Idempotency status values must be controlled.

| Status | Meaning |
|---|---|
| `IDEMPOTENCY_NOT_REQUIRED` | Idempotency not needed |
| `IDEMPOTENCY_REQUIRED` | Idempotency required |
| `IDEMPOTENCY_KEY_ASSIGNED` | Key assigned |
| `IDEMPOTENCY_FIRST_ACCEPTED` | First event accepted |
| `IDEMPOTENCY_DUPLICATE_REUSED_RESULT` | Duplicate reused prior result |
| `IDEMPOTENCY_DUPLICATE_SUPPRESSED` | Duplicate suppressed |
| `IDEMPOTENCY_PAYLOAD_MISMATCH` | Same key, different payload |
| `IDEMPOTENCY_REPLAY_ALLOWED` | Replay allowed |
| `IDEMPOTENCY_REPLAY_BLOCKED` | Replay blocked |
| `IDEMPOTENCY_CONFLICT_REVIEW_REQUIRED` | Conflict needs review |
| `IDEMPOTENCY_SCOPE_INVALID` | Scope invalid |
| `IDEMPOTENCY_KEY_MISSING` | Required key missing |

Any value-bearing or authority-bearing event with missing idempotency must be blocked from runtime implementation.

---

## 12. Membership Reconciliation Rules

Membership reconciliation must handle mismatches in:

- customer identity
- duplicate account detection
- visit count
- order count
- membership grade
- point balance
- benefit eligibility
- store-specific benefit rules
- partner membership sync
- consent state

Membership reconciliation must not silently change customer identity, points, grade, or benefits.

Required controls:

- evidence packet
- customer recovery path if affected
- audit event for value/identity changes
- idempotency for point earn/use
- reconciliation record for mismatch
- support/admin review for identity conflict

---

## 13. Coupon Reconciliation Rules

Coupon reconciliation must handle mismatches in:

- issued state
- reserved state
- used state
- cancelled state
- expired state
- campaign rule
- partner coupon state
- duplicate use risk
- customer eligibility

Coupon duplicate use must not be silently accepted.

Required controls:

- coupon event idempotency
- evidence for duplicate use
- audit for manual adjustment
- customer support path
- reconciliation record for mismatch
- campaign rule version reference

---

## 14. Wallet And Prepaid Reconciliation Rules

Wallet and prepaid value reconciliation must be ledger-compatible.

Reconciliation must handle:

- balance charge mismatch
- balance use mismatch
- refund mismatch
- hold mismatch
- adjustment without authority
- duplicate charge
- duplicate use
- expired balance dispute
- provider/payment link mismatch if applicable

Wallet/prepaid balances must not be corrected through silent UPDATE.

Correction must be append-only or ledger-compatible.

Required controls:

- value-bearing idempotency
- audit event
- evidence packet
- reconciliation record
- customer recovery route
- finance/support review

---

## 15. Identity Reconciliation Rules

Identity reconciliation must handle:

- duplicate customer identity
- wrong account risk
- missing consent
- conflicting phone/email/social identity
- partner identity mismatch
- 자리찜 vs tenant membership identity conflict
- temporary session to permanent identity conflict
- unlink request mismatch

Identity reconciliation must preserve privacy and consent.

Wrong identity linkage must be treated as high-risk.

Required controls:

- consent evidence
- identity link audit
- support/privacy review
- unlink/relink path
- customer recovery path
- no automatic merge without authority

---

## 16. POS Reconciliation Rules

POS reconciliation must handle:

- POS order accepted but internal order missing
- internal order exists but POS event missing
- POS cancellation after payment capture
- duplicate POS event
- stale POS event
- cross-store mapping risk
- POS local cache treated as truth
- POS order id mapped to wrong payment/order

External POS is limited-trust.

POS events are evidence/context, not financial truth.

Required controls:

- tokenized correlation
- event verification
- idempotency
- audit if authority affected
- reconciliation record
- alert for cross-store or stale high-risk events

---

## 17. Payment Reconciliation Rules

Payment reconciliation must handle:

- provider captured but internal payment missing
- internal payment exists but provider callback missing
- amount mismatch
- duplicate capture risk
- refund executed without internal adjustment
- cancellation mismatch
- provider callback signature failure
- provider callback duplicate
- payment state uncertain

Payment success is not final settlement.

Required controls:

- callback verification
- idempotency
- evidence packet
- audit event
- reconciliation record
- provider evidence
- customer support route if affected

---

## 18. Settlement Ledger Reconciliation Rules

Settlement ledger reconciliation must handle:

- ledger entry missing
- provider settlement report missing
- fee mismatch
- platform/franchise/partner allocation mismatch
- exchange-rate mismatch
- refund adjustment missing
- payout mismatch
- correction required
- double-entry imbalance

Ledger corrections must be append-only.

Required controls:

- double-entry compatibility
- evidence source
- audit event
- correction/reversal record
- finance review
- provider/commercial evidence if external

---

## 19. KDS Reconciliation Rules

KDS reconciliation must handle:

- POS accepted order but KDS ticket missing
- KDS ticket duplicate
- KDS completed but payment unresolved
- order cancelled but ticket active
- remake requested but support/evidence missing
- manual fallback used without evidence
- station routing mismatch
- stale ticket

KDS evidence does not automatically approve refunds or settlement corrections.

Required controls:

- ticket idempotency
- order/ticket correlation
- evidence packet for manual/remake exceptions
- support/store review path
- reconciliation record for mismatch

---

## 20. Inventory Reconciliation Rules

Inventory reconciliation must handle:

- stock mismatch
- sold-out mismatch
- menu availability mismatch
- external projection availability mismatch
- KDS accepted unavailable item
- supplier delivery mismatch
- WMS stock mismatch
- waste/disposal mismatch

Inventory reconciliation must preserve source and timestamp.

Required controls:

- inventory event correlation
- evidence for supplier/quality issues
- support/customer recovery if customer affected
- content/projection correction if external display affected
- audit for manual adjustment

---

## 21. Content And i18n Reconciliation Rules

Content and i18n reconciliation must handle:

- missing message key
- missing content key
- wrong locale
- stale content
- unapproved translation
- customer-visible untranslated text
- external projection mismatch
- AI using unapproved content
- hardcoded operational string detected

Content/i18n reconciliation must not patch runtime text manually.

Required controls:

- key registry reference
- source traceability
- translation approval status
- rollback rule if published
- content/localization review
- support route if customer impact occurred

---

## 22. External Projection Reconciliation Rules

External projection reconciliation must handle:

- stale projection
- price mismatch
- availability mismatch
- allergen mismatch
- translation mismatch
- provider sync failure
- projection rollback required
- unverified payment capability displayed
- customer identity sharing risk

External projection is not source of truth.

Required controls:

- internal source authority
- publication version
- rollback version
- provider capability status
- evidence packet
- audit event for publication/rollback
- support route if customer affected

---

## 23. AI Reconciliation Rules

AI reconciliation applies when AI output conflicts with approved sources, boundaries, or authority.

AI reconciliation must handle:

- untraceable output
- wrong source used
- wrong locale
- restricted source access
- unapproved customer response
- provider capability invention
- evidence summary treated as original
- AI output used outside permitted audience
- AI recommendation treated as decision

AI remains assistance only.

Required controls:

- source traceability
- output state classification
- human review
- audit if used in support/admin context
- alert for authority overreach
- blocking customer-facing use until approved

---

## 24. Support/Admin Reconciliation Rules

Support/admin reconciliation must handle:

- case closed without evidence
- refund requested without evidence
- support action attempted without authority
- unmasking without approval
- evidence packet mismatch
- AI draft sent without approval
- export requested without authority
- override used without required review

Support/admin tools must not become backdoor mutation paths.

Required controls:

- evidence packet
- audit event
- authority marker
- support lead/HQ review
- restricted visibility
- reopen path

---

## 25. Supplier SCM WMS Reconciliation Rules

Supplier, SCM, and WMS reconciliation must handle:

- order sent but supplier not acknowledged
- supplier rejected but internal expected delivery active
- delivery delayed
- delivery quantity mismatch
- item mismatch
- quality issue
- WMS stock mismatch
- supplier invoice mismatch
- waste/disposal mismatch

Required controls:

- supplier evidence
- receiving evidence
- inventory adjustment audit
- QC review where safety/quality affected
- SCM reconciliation record

---

## 26. Workforce HR Reconciliation Rules

Workforce/HR reconciliation must handle:

- shift sync failed
- attendance duplicate
- attendance unmapped
- role/permission mismatch
- work eligibility review required
- payroll-adjacent mismatch
- staff assignment mismatch
- training completion mismatch

Required controls:

- employee/store context
- evidence packet for manual correction
- audit for role/permission changes
- HR review
- payroll boundary protection where value is affected

---

## 27. Franchise OS Reconciliation Rules

Franchise OS reconciliation must handle:

- store metadata mismatch
- policy version mismatch
- royalty rule conflict
- menu policy mismatch
- support escalation mismatch
- operating group/company/legal entity context conflict
- partner/franchise settlement conflict

Required controls:

- policy version reference
- tenant/store/legal entity context
- audit event
- finance/franchise review
- support escalation if store affected
- no silent policy overwrite

---

## 28. Universal Replay Rule

Replay must be controlled.

Replay planning must define:

- who or what may trigger replay
- event family eligible for replay
- replay idempotency key
- replay source
- replay target
- replay time window
- whether original payload is reused
- whether transformed payload is allowed
- audit event
- evidence link
- conflict behavior
- customer impact handling

Replay must not create duplicate money, points, coupons, tickets, projections, support actions, or identity links.

---

## 29. Universal Conflict Resolution Methods

Controlled resolution methods include:

| Resolution Method | Meaning |
|---|---|
| `RESOLVE_NO_ACTION_FALSE_POSITIVE` | No action after review |
| `RESOLVE_REPLAY_EVENT` | Replay original event |
| `RESOLVE_REJECT_EVENT` | Reject event |
| `RESOLVE_APPEND_CORRECTION` | Append correction entry |
| `RESOLVE_ROLLBACK_PROJECTION` | Roll back projection |
| `RESOLVE_REISSUE_COUPON` | Reissue controlled coupon |
| `RESOLVE_ADJUST_POINTS` | Adjust points with audit |
| `RESOLVE_ADJUST_WALLET_LEDGER` | Wallet ledger adjustment |
| `RESOLVE_RELINK_IDENTITY` | Relink identity with consent/audit |
| `RESOLVE_MANUAL_SUPPORT_RECOVERY` | Customer recovery through support |
| `RESOLVE_PROVIDER_ESCALATION` | Escalate to provider |
| `RESOLVE_LEGAL_REVIEW` | Legal/compliance review |
| `RESOLVE_DEFER_WITH_REASON` | Deferred with reason |

Resolution methods must be domain-authorized.

They must not be free-form mutations.

---

## 30. Universal Idempotency Failure Alerts

Idempotency failure alerts should include:

| Alert Family | Meaning |
|---|---|
| `ALERT_IDEMPOTENCY_KEY_MISSING` | Required idempotency key missing |
| `ALERT_IDEMPOTENCY_SCOPE_INVALID` | Idempotency scope invalid |
| `ALERT_IDEMPOTENCY_PAYLOAD_MISMATCH` | Same key but different payload |
| `ALERT_IDEMPOTENCY_DUPLICATE_VALUE_RISK` | Duplicate may create value |
| `ALERT_IDEMPOTENCY_DUPLICATE_TICKET_RISK` | Duplicate may create ticket/order |
| `ALERT_IDEMPOTENCY_DUPLICATE_PUBLICATION_RISK` | Duplicate may publish content |
| `ALERT_IDEMPOTENCY_REPLAY_BLOCKED` | Replay blocked |
| `ALERT_IDEMPOTENCY_CONFLICT_REVIEW_REQUIRED` | Conflict requires review |

These alerts must link to evidence and audit when authority/value is involved.

---

## 31. Universal Reconciliation Alerts

Reconciliation alerts should include:

| Alert Family | Meaning |
|---|---|
| `ALERT_RECON_OPEN` | Reconciliation opened |
| `ALERT_RECON_EVIDENCE_REQUIRED` | Evidence required |
| `ALERT_RECON_PROVIDER_EVIDENCE_REQUIRED` | Provider evidence required |
| `ALERT_RECON_MANUAL_REVIEW_REQUIRED` | Manual review required |
| `ALERT_RECON_REPLAY_REQUIRED` | Replay required |
| `ALERT_RECON_CORRECTION_REQUIRED` | Correction required |
| `ALERT_RECON_ROLLBACK_REQUIRED` | Rollback required |
| `ALERT_RECON_CUSTOMER_RECOVERY_REQUIRED` | Customer recovery likely |
| `ALERT_RECON_DEFERRED_TOO_LONG` | Deferred too long |
| `ALERT_RECON_REOPENED` | Reopened due to new evidence |

These alerts should route by domain.

---

## 32. Audit And Evidence Mapping

Every reconciliation and idempotency conflict must define audit/evidence behavior.

Audit is required when:

- value changes
- identity changes
- authority is exercised
- restricted data is viewed
- support decision is made
- provider capability state changes
- external projection is corrected
- AI output is used in review
- manual correction is applied
- replay is triggered by human/operator

Evidence is required when:

- customer may be affected
- value may be affected
- provider/system mismatch exists
- legal/compliance risk exists
- manual correction is needed
- support recovery is possible
- dispute may occur

---

## 33. i18n Mapping

All visible reconciliation and idempotency messages must use message keys.

Message key families must include:

- reconciliation opened
- evidence required
- manual review required
- replay required
- correction required
- rollback required
- customer recovery required
- duplicate suppressed
- duplicate conflict
- idempotency missing
- idempotency conflict
- resolution completed
- resolution deferred
- provider evidence required

Hardcoded operational strings remain prohibited.

---

## 34. Readiness Blocker Additions

The blocker inventory must include reconciliation and idempotency blockers.

| Blocker ID Pattern | Family | Meaning |
|---|---|---|
| `BLOCKER-RECON-0001` | Reconciliation | Reconciliation record fields missing |
| `BLOCKER-RECON-0002` | Reconciliation | Resolution method catalog missing |
| `BLOCKER-RECON-0003` | Reconciliation | Domain reconciliation rule missing |
| `BLOCKER-RECON-0004` | Reconciliation | Reconciliation alert mapping missing |
| `BLOCKER-IDEMPOTENCY-0001` | Idempotency | Idempotency key rule missing |
| `BLOCKER-IDEMPOTENCY-0002` | Idempotency | Idempotency scope missing |
| `BLOCKER-IDEMPOTENCY-0003` | Idempotency | Duplicate classification missing |
| `BLOCKER-IDEMPOTENCY-0004` | Idempotency | Replay behavior missing |
| `BLOCKER-IDEMPOTENCY-0005` | Idempotency | Idempotency conflict alert missing |
| `BLOCKER-REPLAY-0001` | Replay | Replay authority rule missing |

Open reconciliation or idempotency blockers must prevent runtime integration coding.

---

## 35. Boundary Test Additions

Future tests/checks should verify:

- every state-changing event has idempotency requirement
- every idempotency requirement has scope
- duplicate payload mismatch creates review path
- duplicate value risk creates alert
- reconciliation-required events create reconciliation record
- reconciliation record has evidence/audit mapping
- acknowledgement does not equal resolution
- replay cannot create duplicate value
- replay cannot create duplicate ticket
- replay cannot publish duplicate external content
- wallet/point/coupon corrections are not silent overwrites
- ledger correction is append-only
- identity reconciliation requires consent/audit
- AI cannot resolve reconciliation
- provider callback cannot finalize state without verification
- no package marked coding-ready with reconciliation/idempotency blocker open

These tests are planning expectations until implementation is approved.

---

## 36. Relationship To Previous Documents

This document follows:

- `09530 Universal Integration Event Catalog And Alert Family Index Policy`

It also reinforces:

- `09520 Universal Integration Event Alert Logging And Evidence Policy`
- `09510 Financial Event Alert Logging And Automated Warning System Policy`
- `09500 Financial Security Ledger Foundation Catalog And Status Value Addendum Policy`
- `09490 External POS Third-Party Financial Security Ledger And Settlement Isolation Reinforcement Policy`
- `09480 Foundation Catalog Validation Checklist And Review Gate Policy`
- `09330 API RPC Event Contract Planning Boundary Policy`
- `09360 Support Admin Evidence Audit Package Planning Policy`

This document prepares reconciliation and idempotency catalog discipline for all integration domains.

It does not authorize coding.

---

## 37. Final Rule

Every integration that can affect value, identity, order state, payment state, KDS state, inventory state, content/projection state, support outcome, provider status, workforce record, or franchise policy must define reconciliation and idempotency before runtime implementation.

Duplicate events must not create duplicate value.

Cross-system mismatches must not be silently overwritten.

Reconciliation must be explicit, evidenced, auditable, and domain-authorized.

Coding remains deferred until reconciliation records, idempotency keys, duplicate classifications, replay rules, resolution methods, audit/evidence mappings, i18n keys, alert families, blockers, and boundary tests are reviewed and approved.
