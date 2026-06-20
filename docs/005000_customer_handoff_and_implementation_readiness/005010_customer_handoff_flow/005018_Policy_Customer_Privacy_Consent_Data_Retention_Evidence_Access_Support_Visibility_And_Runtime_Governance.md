# 005008_Policy_Customer_Privacy_Consent_Data_Retention_Evidence_Access_Support_Visibility_And_Runtime_Governance

## 1. Purpose

This policy defines the customer privacy, consent, data retention, evidence access, support visibility, and runtime governance boundary.

The purpose is to ensure that customer-facing runtime data created through waiting, web app, native app, kiosk, table service, order, payment status, membership, support, dispute, and notification flows is collected, displayed, retained, shared, and accessed only under controlled rules.

Customer data is not just marketing data.  
It may include guest identity, customer account identity, waiting records, table context, order references, payment status, support claims, coupon usage, notification history, staff notes, manager decisions, incident records, and audit evidence.

This policy defines how customer data must remain useful for Store Runtime, finance, support, audit, and compliance without overexposing customer information or staff-only evidence.

## 2. Scope

This policy covers:

- Customer privacy boundary
- Guest and account data minimization
- Consent capture and usage boundary
- Operational notification consent boundary
- Marketing consent boundary
- Support and dispute data visibility
- Evidence access by role
- Data retention and expiration
- Customer-facing data display
- Staff and manager visibility control
- Finance, support, audit, and compliance access
- Privacy-sensitive incident linkage

This policy does not define final legal privacy notice wording, full data deletion automation, full enterprise IAM, legal discovery process, or country-specific regulatory compliance implementation.

## 3. Baseline Dependency

This policy depends on:

`005002_Policy_Customer_Link_Token_QR_NFC_Session_Expiration_Abuse_Prevention_And_Security_Boundary.md`

`005003_Policy_Customer_Web_App_Guest_Session_App_Native_Continuity_Order_Surface_And_Runtime_Control.md`

`005004_Policy_Customer_Native_App_Deep_Link_Push_Account_Continuity_Web_App_Coexistence_And_Runtime_Control.md`

`005005_Policy_Customer_Account_Guest_Merge_Identity_Continuity_Membership_Ready_And_Runtime_Authority_Boundary.md`

`005006_Policy_Customer_Membership_Loyalty_Coupon_Visit_Count_Store_Benefit_And_Runtime_Control.md`

`005007_Policy_Customer_Support_Case_Dispute_Resolution_Compensation_Refund_Cancel_Handoff_And_Evidence_Control.md`

06600 defines support case and dispute resolution control.  
This document defines privacy, consent, retention, and evidence access rules across the customer-facing runtime lane.

## 4. Core Principle

Customer data must be minimized for convenience but preserved for truth.

The system must balance two duties:

1. Do not collect, display, retain, or expose unnecessary customer data.
2. Preserve enough evidence to prove operational, payment, support, and compliance truth.

The system must distinguish between:

- Customer-facing data
- Staff-operational data
- Manager-sensitive data
- Support-case data
- Finance-relevant data
- Audit evidence
- Compliance-sensitive data
- Marketing data
- Consent data
- Deleted, expired, anonymized, or restricted data

No role should see more customer data than needed for its purpose.

## 5. Customer Data Families

Customer-related data must be grouped into families.

| Data Family | Description |
|---|---|
| Guest Data | Temporary customer/session information without persistent account |
| Account Data | Persistent customer account profile and login-related identity |
| Contact Data | Phone, email, app push token, or message channel reference |
| Waiting Data | Waiting session, call, arrival, no-show, seating records |
| Table Data | Table session and service context |
| Order Data | Cart, preorder, accepted order, order status |
| Payment Status Data | Payment state, approval/failure/uncertainty references |
| Membership Data | Coupon, visit count, benefit, loyalty-ready records |
| Notification Data | Message template, channel, delivery/display/open evidence |
| Support Data | Customer claims, dispute notes, resolution records |
| Staff Interaction Data | Staff assist, correction, response, and communication notes |
| Manager Decision Data | Override, compensation, closeout, or approval decisions |
| Audit Evidence | Trace records needed for operational or financial proof |
| Marketing Data | Promotional consent, segmentation, campaign interaction |

Each family must have separate purpose, visibility, and retention rules.

## 6. Data Minimization Rules

The system should collect only data needed for the active purpose.

Examples:

- Waiting may require party label, party size, and contact method, but not full account creation.
- Guest order may require scoped session reference, but not permanent profile.
- Payment status display may require safe status, but not full provider details.
- Support follow-up may require contact method and claim details, but not unrelated order history.
- Membership may require account linkage, but not staff-only incident notes.
- Marketing may require explicit consent and must not reuse operational data without policy.

Data minimization must not prevent required audit evidence from being preserved.

## 7. Guest Data Boundary

Guest data must be scoped and limited.

Guest data may include:

- Guest session ID
- Device/session reference
- Waiting session
- Cart or preorder reference
- Table session reference
- Limited contact method, where allowed
- Language preference
- Support case reference, where applicable
- Link/token reference or hash
- Runtime evidence

Guest data must not be used as permanent marketing identity unless consent and account linkage policy allow it.

Guest data may later be linked to customer account through controlled merge policy.

## 8. Account Data Boundary

Customer account data may include:

- Account ID
- Login method reference
- Profile nickname or name, where collected
- Contact method
- Preferred language
- Notification preference
- Membership profile
- Order/support history references
- Consent records
- Account status

Account data must remain distinct from:

- Party identity
- Table session
- Payment identity
- Support case identity
- Staff notes
- Audit-only evidence

An account must not automatically expose every party member, table context, or support-sensitive record.

## 9. Consent Boundary

Consent must be purpose-specific.

Consent categories may include:

- Service operation notification
- Support follow-up
- Membership enrollment
- Loyalty/benefit use
- Marketing notification
- Personalized recommendation, where later supported
- Data sharing with external providers, where applicable
- Optional profile data use

Operational service communication may be necessary for service delivery, but marketing use must be separately governed.

Consent state must be recorded with timestamp, source, version, and purpose.

## 10. Operational Notification Boundary

Operational notifications may include:

- Waiting call
- Arrival reminder
- Table assignment
- Order status
- Payment status
- Refund/cancel status
- Support follow-up
- Incident/recovery notice

Operational notifications must be limited to service-related purpose.

Operational notification history may be retained as evidence when it affects waiting, no-show, payment, support, or dispute resolution.

## 11. Marketing Consent Boundary

Marketing communication must be separated from operational communication.

Marketing may include:

- Promotions
- Coupons not tied to support compensation
- Campaign announcements
- Store events
- Loyalty campaigns
- Personalized offers

Marketing must not be sent based only on guest session creation unless policy, consent, and legal review allow it.

Marketing consent withdrawal must not disable required operational evidence retention.

## 12. Customer-Facing Data Display

Customer-facing surfaces may display only safe scoped data.

Customer-facing surfaces include:

- Web app
- Native app
- Entrance link
- Waiting status page
- Table QR/NFC page
- Kiosk
- Mini kiosk
- Support case page
- Notification message

Customer-facing display must not expose:

- Internal IDs
- Other customers’ data
- Staff-only notes
- Manager-only decisions
- Internal incident severity
- Audit-only evidence
- Full provider payment details
- Sensitive token values
- Internal financial reconciliation details

## 13. Staff Visibility Boundary

Staff may view customer data needed for live operation.

Staff-visible data may include:

- Waiting party label
- Party size
- Arrival status
- Table assignment
- Order status
- Limited customer contact or call status where needed
- Language preference
- Staff assist notes
- Customer request summary
- Support escalation marker
- Payment uncertainty marker without full sensitive detail

Staff should not see:

- Full customer account history unless required
- Marketing profile
- Sensitive support notes unrelated to store operation
- Full payment provider references
- Internal compliance notes
- Audit-only evidence beyond role need

## 14. Manager Visibility Boundary

Managers may view additional sensitive data for:

- Payment uncertainty review
- Refund/cancel exception
- Compensation approval
- Customer dispute resolution
- Staff correction review
- Incident confirmation
- Daily closeout
- Carry-forward owner assignment

Manager visibility must still be purpose-scoped.

Manager access must create audit events for sensitive views or actions where required.

## 15. Support Visibility Boundary

Support may view data needed to resolve customer cases.

Support-visible data may include:

- Customer claim
- Contact/reference information
- Store and business date
- Waiting/table/order/payment references
- Customer-facing message history
- Staff and manager response summary
- Refund/cancel status
- Membership/coupon/benefit history relevant to case
- Evidence links

Support must not see unrelated customer records or audit-only details without purpose and role.

## 16. Finance Visibility Boundary

Finance may view customer-related data only when needed for:

- Payment uncertainty
- Refund/cancel
- Settlement mismatch
- Duplicate charge
- Manual POS entry
- Compensation with financial value
- Coupon/benefit financial impact
- Customer dispute hold

Finance does not need broad customer profile or marketing data for normal reconciliation.

Finance evidence should use order/payment/support references and minimized customer identifiers where possible.

## 17. Audit And Compliance Visibility Boundary

Audit and compliance may require broader evidence access for:

- Payment dispute review
- Refund/cancel review
- Incident investigation
- Privacy-sensitive case
- Legal hold
- Provider dispute
- Financial audit
- Security investigation
- Policy violation review

Audit/compliance access must be logged, purpose-linked, and role-controlled.

Audit views should protect sensitive customer data from unnecessary exposure.

## 18. Retention State Families

Data retention must be state-aware.

Retention states may include:

| State | Meaning |
|---|---|
| Active | Needed for current runtime operation |
| Operationally Closed | Store operation completed but review may remain |
| Support Open | Support or dispute case remains active |
| Finance Open | Payment/reconciliation review remains active |
| Audit Hold | Evidence must be retained for audit/compliance |
| Legal Hold | Deletion/alteration restricted by legal process |
| Expired | No longer active but may be retained under policy |
| Anonymized | Personal identifiers minimized or removed |
| Deleted | Data removed where allowed |
| Restricted | Visible only to specific roles or purposes |

The system must not treat expiration as deletion.

## 19. Data Retention Boundary

Retention periods must be defined by data family and purpose.

Examples:

- Guest session data may expire quickly for customer-facing access.
- Waiting evidence may be retained longer for dispute review.
- Payment-related evidence may require finance/audit retention.
- Support cases may require retention until resolution and review period.
- Marketing consent records may require proof of opt-in/out.
- Audit logs may need longer retention than customer-facing profile fields.
- Token values should not be retained unsafely, but token hashes/references may be retained as evidence.

This policy defines the boundary; final retention durations require legal and compliance review.

## 20. Deletion And Anonymization Boundary

Deletion or anonymization must not break required evidence.

When customer profile deletion or anonymization is requested or required, the system must distinguish:

- Customer-facing account data
- Operational transaction evidence
- Payment/reconciliation evidence
- Support/dispute evidence
- Audit/legal hold evidence
- Marketing profile data
- Consent history

Some data may be anonymized while preserving order/payment/support evidence.

Deletion must not silently erase financial or legal evidence where retention is required.

## 21. Evidence Access Control

Evidence access must be controlled by role and purpose.

Evidence may include:

- Customer-facing message history
- Waiting state history
- Table session history
- Order/payment state history
- Staff correction history
- Manager override history
- Support case history
- Coupon/benefit history
- Incident history
- Finance exception history

Evidence access must record:

- Actor
- Role
- Purpose
- Timestamp
- Evidence category
- Case/order/payment reference where applicable

Sensitive evidence must not be broadly searchable by ordinary staff.

## 22. Privacy Incident Boundary

A privacy-sensitive incident may occur when:

- Customer link exposes wrong session
- Table QR shows another party’s information
- Staff links guest to wrong account
- Support case visible to wrong account
- Notification sent to wrong recipient
- Coupon/benefit data attached to wrong customer
- Payment status shown to wrong user
- Internal staff note exposed to customer
- Token or sensitive link is leaked
- Unauthorized role views customer evidence

Privacy-sensitive incidents must be escalated to compliance/security owner.

## 23. Daily Closeout Impact

Daily closeout must review material privacy and visibility exceptions.

Closeout may include:

- Wrong customer/session display
- Misdelivered notification
- Link/session access issue
- Staff account-link correction
- Support privacy conflict
- Payment status visibility issue
- Customer dispute involving privacy
- Evidence access failure
- Missing consent marker for required flow

Privacy-related carry-forward must have owner and severity.

## 24. Evidence Requirements

The system must preserve evidence for:

- Consent capture
- Consent withdrawal
- Guest session creation
- Account linkage
- Customer-facing data display
- Notification send/display/open, where available
- Staff sensitive view/action
- Manager sensitive view/action
- Support case data access
- Finance-related customer data access
- Audit/compliance evidence access
- Data expiration
- Data restriction
- Anonymization or deletion event
- Privacy incident creation
- Privacy incident resolution

Evidence must include:

- Actor ID, where applicable
- Customer or guest reference, where applicable
- Session/order/payment/support reference, where applicable
- Data family
- Purpose
- Action
- Timestamp
- Result
- Related incident/support/audit reference where applicable

Sensitive evidence must itself be protected.

## 25. Acceptance Criteria

This policy is accepted when:

- Customer data families are classified
- Guest and account data boundaries are separated
- Consent categories are purpose-specific
- Operational and marketing notifications are separated
- Customer-facing display excludes internal/sensitive data
- Staff, manager, support, finance, audit, and compliance visibility boundaries are defined
- Retention states are documented
- Expiration is not treated as deletion
- Deletion/anonymization does not break required evidence
- Evidence access is role- and purpose-controlled
- Privacy incident conditions are defined
- Daily closeout can see material privacy exceptions
- Evidence requirements are traceable

## 26. Out of Scope

This policy does not include:

- Final legal privacy notice wording
- Exact statutory retention durations
- Full deletion automation
- Full consent management UI
- Full enterprise IAM implementation
- Full data catalog tooling
- Full privacy incident response program
- Cross-border data transfer legal review
- Final compliance certification

Those must be handled in legal, privacy, compliance, IAM, data governance, or security lanes.

## 27. Related Documents

Related document families include:

- Customer link token and QR/NFC security policy
- Customer web app runtime policy
- Customer native app runtime policy
- Customer account and guest merge policy
- Membership loyalty coupon benefit policy
- Customer support case policy
- Customer notification and multilingual guidance policy
- Runtime evidence policy
- Security audit governance
- Data retention policy
- Privacy incident response policy

## 28. Final Rule

Customer data must be useful without becoming overexposed.

The system must preserve operational, financial, support, and audit truth while minimizing customer data collection, limiting visibility by role and purpose, respecting consent, controlling retention, and protecting evidence.

This policy defines the privacy, consent, retention, and evidence access boundary before detailed legal, IAM, data governance, and security policies expand customer data control.