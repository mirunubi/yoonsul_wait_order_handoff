# 20190 Customer Privacy And Consent Governance

## 1 Purpose

Define customer privacy, consent, and personal data handling boundaries for the waiting-order handoff SaaS.

Customer privacy governance protects identifiable customer data while enabling legitimate store operations.

This document defines governance only.
It does not create consent UI, privacy policy text, or data processing runtime.

## 2 Scope

In scope:

- Customer data categories and collection boundaries.
- Consent and minimization principles.
- Customer visibility and correction request principles.
- Store, HQ, and platform visibility boundaries.
- Relationship to retention, deletion, and support access governance.

Out of scope:

- Legal counsel finalization of privacy notices.
- PG or payment processor privacy agreements.
- Marketing consent product implementation.
- Cross-border data transfer legal framework.

## 3 Customer Data Categories

| category | governance meaning |
| --- | --- |
| identity/contact data | Phone, name, or session-linked identifiers when collected. |
| waiting session data | Queue registration, call, arrival, no-show context. |
| pre-order content | Order candidate, preorder intent, menu selections. |
| table/seating participation data | Table, pickup, or seating handoff participation markers. |
| payment-adjacent data | Payment-pending or payment-status visibility markers; not financial truth. |
| consent records | Record of consent scope, time, and channel where required. |
| support interaction data | Support session content involving customer context. |

## 4 Consent Principles

- consent must be explicit where required.
- consent scope must match stated purpose.
- consent withdrawal must be recordable where policy requires.
- implied consent from store convenience is insufficient for unrelated reuse.
- Mini Kiosk and customer webapp consent posture must align per surface policy.
- future membership or marketing use requires separate consent basis.

## 5 Collection Minimization Rules

- collect only data needed for waiting, handoff, and authorized store operations.
- avoid collecting identity/contact data when anonymous session suffices.
- do not collect payment card or bank data in handoff runtime by default.
- do not expand collection because HQ or platform has broader visibility tools.
- support-assisted collection must remain within scoped session purpose.

## 6 Customer Visibility and Correction Request Principles

- customers may see their own session and handoff status within authorized surfaces.
- correction requests must be reviewable without silent mutation of audit history.
- correction does not erase original event; append correction lineage.
- store convenience does not override customer privacy.
- export of customer-identifiable data requires export approval governance.

## 7 Store/HQ/Platform Visibility Boundaries

| visibility level | may see | may not imply |
| --- | --- | --- |
| store-visible | Store-scoped customer session and handoff data for operations. | Cross-store customer identity without authority. |
| HQ-visible | Tenant-scoped summaries and policy review context. | Raw cross-tenant customer identity. |
| platform-visible | Policy, isolation, and support review context within audit scope. | Unrestricted customer browsing across tenants. |

Support access must be scoped, masked, and audited per `20090`.

## 8 Retention/Deletion Relationship

- customer data retention follows `20110` and `20030` lifecycle classes.
- deletion must not erase required audit evidence where retention policy requires preservation.
- anonymization and pseudonymization follow `20060` and `20110`.
- tenant offboarding must include customer data handling review.
- consent records must outlive operational session where policy requires proof of basis.

## 9 Required Audit Events

- consent granted, withdrawn, or scope-changed.
- customer data access by admin or support outside normal customer surface.
- correction request submitted and resolved.
- export request involving customer-identifiable data.
- retention/deletion action affecting customer-identifiable data.
- masking failure or over-exposure incident review.

## 10 Non-Implementation Boundary

- no consent banner implementation.
- no privacy preference API.
- no SQL, migrations, or schema.
- no RLS or auth middleware.
- no marketing automation.
- no data subject request portal.

## 11 Cross-References

- `docs/20000_validation_security_audit/20020_Cross_Entity_Data_Sharing_And_Privacy_Boundary.md`
- `docs/20000_validation_security_audit/20090_Support_Access_Masking_And_Scoped_Session_Governance.md`
- `docs/20000_validation_security_audit/20110_Retention_Deletion_Anonymization_Consolidation.md`
- `docs/20000_validation_security_audit/20170_Cross_Tenant_Isolation_And_Data_Leakage_Prevention_Governance.md`

## 12 Open Decisions

- required consent surfaces at MVP.
- phone vs anonymous session default.
- correction request channel.
- customer data retention default periods.
- legal review of privacy notice placeholders.

## 13 Current Status

Status: active customer privacy and consent governance. Not implementation approval.
