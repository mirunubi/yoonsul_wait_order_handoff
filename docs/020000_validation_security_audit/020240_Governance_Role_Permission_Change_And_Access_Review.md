# 020240_Governance_Role_Permission_Change_And_Access_Review

## 1 Purpose

Define governance for role changes, permission changes, and periodic access review.

Access governance must enforce least privilege and auditable lifecycle for all roles.

This document defines governance only.
It does not create RBAC schema, auth middleware, or access review tooling.

## 2 Scope

In scope:

- Role and permission change categories.
- Approval and periodic access review principles.
- Dormant account and stale access handling.
- Privilege escalation prevention and required audit events.

Out of scope:

- HR onboarding/offboarding systems.
- SSO provider implementation.
- Physical access control.
- Automated account provisioning runtime.

## 3 Role/Permission Change Categories

| role category | governance scope |
| --- | --- |
| tenant admin | Tenant-scoped configuration and governance visibility. |
| HQ admin | Multi-store or operating-group governance within tenant. |
| store owner | Store-level ownership and policy within tenant. |
| store manager | Store operational management within assigned stores. |
| staff | Store console operational actions within staff scope. |
| support operator | Scoped support session actions; not approval authority. |
| platform operator | Platform policy and cross-tenant governance within boundary. |
| emergency/break-glass role | Future-only high-risk path; rare, scoped, time-limited. |

## 4 Access Change Authority

- role visibility is not mutation authority.
- role assignment requires matching authority for target scope.
- elevation to tenant admin or platform operator requires higher approval.
- support operator role must not include export or policy activation by default.
- break-glass role must be rare, scoped, time-limited, and reviewed.

## 5 Approval Requirements

- privilege elevation requires explicit approval where policy defines high-risk roles.
- self-approval of role elevation is prohibited.
- support cannot approve its own role change.
- emergency/break-glass role grant requires separate review and expiry.
- role removal must be auditable.

## 6 Periodic Access Review Principles

- access reviews must occur on defined cadence per role risk level.
- reviewers must confirm least-privilege fit for current responsibilities.
- stale access is a security risk and must be flagged for removal or renewal.
- dormant accounts must be identified and reviewed.
- review outcome must append audit record without erasing prior grants.

## 7 Dormant Account and Stale Access Handling

- dormant account threshold is policy-defined.
- stale access includes unused elevated roles and expired support grants.
- removal or downgrade must record reason and reviewer.
- reactivation requires fresh approval for elevated roles.
- offboarding must trigger access removal review checklist.

## 8 Privilege Escalation Prevention

- access must be least-privilege by default.
- cumulative roles must not silently expand mutation authority.
- temporary elevation must have expiry and review.
- cross-tenant role assignment is prohibited by default.
- masking override permission requires separate approval track.

## 9 Required Audit Events

- role granted, modified, or removed.
- permission bundle changed.
- access review completed with outcome.
- dormant account flagged, disabled, or reactivated.
- break-glass or emergency role granted, used, and revoked.
- failed unauthorized access attempt where detectable.

## 10 Non-Implementation Boundary

- no role table or permission matrix schema.
- no auth middleware or RLS.
- no IAM product integration.
- no SQL, migrations, or RPC.
- no automated access review jobs.
- no SSO implementation.

## 11 Cross-References

- `docs/20000_validation_security_audit/020080_Governance_Access_Context_And_Data_Visibility.md`
- `docs/20000_validation_security_audit/020090_Governance_Support_Access_Masking_And_Scoped_Session.md`
- `docs/20000_validation_security_audit/020220_Governance_Admin_Console_Action_Safety.md`

## 12 Open Decisions

- access review cadence by role.
- dormant account threshold.
- break-glass role approval owner.
- store staff permission tiers at MVP.
- tenant admin vs platform admin split.

## 13 Current Status

Status: active role permission change and access review governance. Not implementation approval.
