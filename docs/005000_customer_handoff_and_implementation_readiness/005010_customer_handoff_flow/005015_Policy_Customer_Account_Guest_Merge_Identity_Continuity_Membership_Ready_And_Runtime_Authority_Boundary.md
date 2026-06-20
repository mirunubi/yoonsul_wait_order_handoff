# 005005_Policy_Customer_Account_Guest_Merge_Identity_Continuity_Membership_Ready_And_Runtime_Authority_Boundary

## 1. Purpose

This policy defines the customer account, guest merge, identity continuity, membership-ready, and runtime authority boundary.

The purpose is to ensure that customer identity does not become confused with waiting sessions, table sessions, order sessions, payment references, kiosk sessions, support cases, loyalty state, or staff-created guest records.

A customer account may provide long-term continuity, but live store operation often begins with guest sessions, QR/NFC links, kiosk sessions, table contexts, preorder flows, or staff-assisted records.

This policy defines how customer account identity must attach to those runtime sessions without overwriting operational truth.

## 2. Scope

This policy covers:

- Customer account boundary
- Guest session identity boundary
- Guest-to-account merge
- Customer identity continuity
- Duplicate customer identity detection
- Party and household distinction
- Membership-ready identity structure
- Loyalty-ready account linkage
- Support and dispute identity linkage
- Privacy and consent boundary
- Evidence requirements

This policy does not define full authentication implementation, final membership tier rules, loyalty point calculation, marketing segmentation, CRM implementation, or legal identity verification.

## 3. Baseline Dependency

This policy depends on:

`006511_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md`

`005002_Policy_Customer_Link_Token_QR_NFC_Session_Expiration_Abuse_Prevention_And_Security_Boundary.md`

`005003_Policy_Customer_Web_App_Guest_Session_App_Native_Continuity_Order_Surface_And_Runtime_Control.md`

`005004_Policy_Customer_Native_App_Deep_Link_Push_Account_Continuity_Web_App_Coexistence_And_Runtime_Control.md`

06560 defines the customer web app and guest session runtime boundary.  
06570 defines future native app and account continuity.  
This document defines the account and identity continuity model that must not break Store Runtime truth.

## 4. Core Principle

A customer account is a continuity anchor, not the live operational state itself.

The system must distinguish:

1. Customer account
2. Guest session
3. Device session
4. Waiting session
5. Party identity
6. Table session
7. Cart or preorder
8. Accepted order
9. Payment attempt
10. Support or dispute case
11. Membership or loyalty profile

A customer account may link to these records, but it must not replace them.

## 5. Identity Families

Customer identity must be separated into families.

| Identity Family | Meaning |
|---|---|
| Customer Account | Persistent known customer profile |
| Guest Identity | Temporary customer reference without login |
| Device Identity | Browser, app, kiosk, or customer link session |
| Party Identity | Group-level waiting or table unit |
| Store Runtime Session | Live store interaction context |
| Order Identity | Cart, preorder, accepted order, or order history reference |
| Payment Identity | Payment attempt, approval, refund, cancel, or dispute reference |
| Support Identity | Customer support or dispute case reference |
| Membership Identity | Membership tier, benefit, or loyalty-ready profile |
| Consent Identity | Customer permissions for communication, marketing, or data use |

The system must not collapse these identities into one universal customer row without preserving context.

## 6. Customer Account Role

A customer account may support:

- Login
- Profile continuity
- Preferred language
- Contact method
- Order history
- Waiting history
- Support history
- Membership state
- Loyalty-ready linkage
- Notification preference
- Future repeat-order convenience
- Future native app continuity

The account may improve convenience but must not grant authority over unrelated runtime sessions.

## 7. Guest Identity Role

Guest identity may support:

- Waiting
- Menu browsing
- Cart draft
- Preorder intent
- Kiosk continuation
- Table context
- Limited order status
- Limited payment status
- Staff help request
- Support intake

Guest identity must be scoped, expiring, and privacy-limited.

A guest identity may later be linked to a customer account, but the original guest session must remain preserved as evidence.

## 8. Guest-To-Account Merge

Guest-to-account merge may occur when:

- Guest logs in after waiting creation
- Guest logs in after cart creation
- Guest logs in after preorder submission
- Guest logs in after table assignment
- Guest logs in after order acceptance
- Guest logs in during support/dispute flow
- Staff identifies customer account during service
- Native app opens a web-created guest session
- Customer requests account attachment for receipt, loyalty, or support

Merge must preserve:

- Original guest identity
- Original session source
- Link/token reference
- Waiting session
- Table session
- Cart/preorder/order reference
- Payment reference, if any
- Support/dispute reference, if any
- Merge actor or customer action
- Merge timestamp
- Before/after identity linkage

Merge must not duplicate the order, payment, table session, or support case.

## 9. Merge Authority

Guest-to-account merge may be initiated by:

- Customer login
- Customer account verification
- Native app deep link validation
- Staff-assisted account lookup, where allowed
- Support case verification
- Manager-approved correction, where required

High-risk merge requires additional validation when:

- Payment dispute exists
- Refund/cancel case exists
- Support case contains sensitive information
- Multiple customer accounts match
- Guest session has financial state
- Table session involves multiple parties
- Customer claims account ownership but evidence is weak

Staff must not casually attach financial or support-sensitive guest records to an account without policy.

## 10. Duplicate Customer Detection

Duplicate customer identity may occur when:

- Customer creates multiple accounts
- Customer uses guest flow repeatedly
- Customer uses web and native app separately
- Staff creates a customer manually
- Phone/contact data differs
- Family members share device
- Party members use one waiting link
- Customer changes phone or login method

Duplicate detection may suggest merge, but merge must be controlled.

The system must not automatically merge accounts solely by name, table, device, or partial phone match.

## 11. Account Split And Correction

Account split or correction may be required when:

- Guest session was attached to wrong account
- Staff selected wrong customer
- Shared device caused wrong identity linkage
- Party member used another customer account
- Support case linked to wrong customer
- Payment dispute was attached to wrong account
- Native app deep link opened under wrong login

Correction must preserve:

- Previous account link
- New account link
- Actor
- Reason
- Timestamp
- Affected sessions/orders/payments/support cases
- Customer-facing impact
- Manager/support approval, where required

Identity correction must not erase original evidence.

## 12. Party And Customer Distinction

A party is not the same as a customer account.

A party may include:

- One customer account
- Multiple customer accounts
- One guest
- Multiple guests
- Mixed account and guest participants
- Staff-created party label

Waiting, seating, table session, and group order flows must preserve party context separately from individual account identity.

Membership or loyalty benefits must not be applied ambiguously to an entire party unless policy defines how.

## 13. Membership-Ready Boundary

The account model must be membership-ready but not membership-dependent.

Membership-ready identity may later support:

- Tier
- Points
- Coupons
- Visit count
- Store-specific benefit history
- App-specific benefit wallet
- Receipt/order linkage
- Consent-based marketing
- Customer support goodwill record

However, Store Runtime must work even without membership.

Waiting, order, payment, table, and support flows must not require membership unless future business policy explicitly changes.

## 14. Loyalty-Ready Linkage

Loyalty-ready linkage must distinguish:

- Account owner
- Guest order later claimed by account
- Party order with multiple participants
- Store-specific visit
- Payment reference
- Refund/cancel adjustment
- Compensation or goodwill benefit
- Dispute-linked benefit
- Manual staff adjustment
- Fraud or abuse review marker

Loyalty credit must not be blindly granted from ambiguous guest, table, or party records.

This policy does not define loyalty calculation; it defines identity safety for future loyalty.

## 15. Support And Dispute Identity Linkage

Support and dispute cases must link carefully to customer identity.

A support case may be linked to:

- Guest identity
- Customer account
- Waiting session
- Table session
- Order
- Payment
- Kiosk/device session
- Staff actor
- Incident
- Finance exception

Support must be able to resolve guest-origin cases without forcing account creation.

If a guest-origin dispute is later linked to a customer account, the system must preserve both guest-origin evidence and account linkage evidence.

## 16. Payment Identity Boundary

Payment identity must remain separate from customer identity.

A customer account may own or view payment-related status only when authorized by scoped session, account verification, or support workflow.

The system must not assume:

- Same account means same payment owner
- Same device means same customer
- Same table means same payer
- Same party means same payer
- Same phone means same account without verification

Payment disputes require stronger identity verification than simple order status display.

## 17. Account Authority Boundary

A customer account may allow:

- Viewing own account profile
- Viewing linked order history
- Continuing linked session
- Managing notification preference
- Opening support case
- Viewing support status
- Claiming guest session, where validated
- Receiving membership benefit, where policy allows

A customer account must not allow:

- Viewing other party members’ private data
- Taking over another guest session
- Resolving payment uncertainty
- Approving refund/cancel
- Changing staff/manager state
- Closing support case without policy
- Accessing audit-only evidence
- Viewing internal incident details

Account authority must remain scoped.

## 18. Privacy And Consent Boundary

Customer identity data must be minimized and consent-aware.

The system must define:

- Required data for guest flow
- Required data for account flow
- Optional profile data
- Notification consent
- Marketing consent
- Support follow-up consent
- Membership data usage
- Retention boundary
- Account deletion or anonymization impact
- Guest data expiration/anonymization boundary

Operational evidence may need retention even when customer-facing profile data is minimized or anonymized, subject to legal and policy review.

## 19. Identity Conflict Handling

Identity conflict occurs when:

- Guest session matches multiple accounts
- Account login conflicts with existing session owner
- Staff attaches wrong account
- Customer claims order under another account
- Payment reference conflicts with claimed customer
- Support case belongs to ambiguous identity
- Native app and web app disagree
- Duplicate account merge is uncertain

Identity conflict must enter manual review or support review.

High-risk conflict involving payment, refund, or support privacy must not be resolved automatically.

## 20. Daily Closeout Impact

Daily closeout must review material identity exceptions when they affect operation.

Closeout may include:

- Guest-to-account merge exceptions
- Wrong account linkage
- Duplicate customer conflict
- Support identity conflict
- Payment dispute identity conflict
- Staff-assisted account correction
- Native app/web account mismatch
- Identity-related customer dispute

A store day may close with identity carry-forward only when owner and evidence are assigned.

## 21. Evidence Requirements

The system must preserve evidence for:

- Guest identity creation
- Customer account login or attachment
- Guest-to-account merge
- Account split or correction
- Duplicate identity detection
- Staff-assisted account lookup or attachment
- Support identity linkage
- Payment identity verification event, where applicable
- Membership-ready linkage
- Consent capture or change
- Identity conflict
- Manual review
- Customer-facing account/session display
- Daily closeout identity exception

Evidence must include:

- Store ID, where applicable
- Business date, where applicable
- Guest identity reference
- Customer account reference
- Session reference
- Waiting/table/order/payment/support reference where applicable
- Actor ID, where applicable
- Action
- Timestamp
- Before state
- After state
- Reason
- Verification method, where applicable
- Related incident/dispute/support reference

Sensitive identity and verification data must not be stored or displayed unsafely.

## 22. Acceptance Criteria

This policy is accepted when:

- Customer account is not treated as the only operational identity
- Guest session identity is supported and scoped
- Guest-to-account merge preserves evidence
- Merge authority and high-risk verification rules are defined
- Duplicate customer detection does not automatically merge unsafe matches
- Party and customer account are separated
- Membership-ready identity does not force membership dependency
- Loyalty-ready linkage avoids ambiguous crediting
- Support and dispute identity linkage is controlled
- Payment identity remains separate from customer identity
- Privacy and consent boundaries are documented
- Identity conflicts enter review
- Daily closeout can see material identity exceptions
- Evidence requirements are traceable

## 23. Out of Scope

This policy does not include:

- Full authentication implementation
- Passwordless login design
- OAuth/social login implementation
- Final membership tier policy
- Final loyalty point calculation
- Marketing segmentation
- Full CRM design
- Legal privacy notice drafting
- Enterprise IAM

Those must be handled in authentication, membership, loyalty, marketing, CRM, legal, or IAM lanes.

## 24. Related Documents

Related document families include:

- Customer web app runtime policy
- Customer native app runtime policy
- Customer link token and QR/NFC security policy
- Customer notification and multilingual guidance policy
- Waiting queue policy
- Table matching policy
- Customer dispute and support handoff WorkPackage
- Payment uncertainty policy
- Runtime evidence policy
- Privacy and data retention policy
- Membership and loyalty policy

## 25. Final Rule

Customer identity must create continuity without destroying context.

A guest, account, party, table, order, payment, support case, and membership profile may be linked, but they must remain distinguishable, recoverable, and evidence-backed.

This policy defines the customer account and guest merge boundary before membership, loyalty, CRM, authentication, and marketing systems expand customer identity use.