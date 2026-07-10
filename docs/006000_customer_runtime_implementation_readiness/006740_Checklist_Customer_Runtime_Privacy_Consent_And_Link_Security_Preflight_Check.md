# 006740_Checklist_Customer_Runtime_Privacy_Consent_And_Link_Security_Preflight_Check.md

## 1. Purpose

This checklist defines the Customer Runtime privacy, consent, and link security preflight check.

The purpose is to verify that customer-facing links, QR/NFC flows, web app sessions, waiting sessions, table sessions, support cases, notification messages, account linkage, and evidence access do not expose customer data, create wrong-session access, bypass consent rules, or weaken runtime security before pilot or rollout.

Privacy and link security must be checked before live customer use, not only after incidents occur.

## 2. Scope

This checklist covers:

- Customer link security
- QR/NFC preflight
- Dynamic token scope and expiration
- Guest session privacy
- Customer account linkage safety
- Waiting and table visibility
- Web app and native app display safety
- Notification recipient and wording safety
- Consent capture and separation
- Support and finance visibility
- Staff and manager access control
- Evidence access and retention
- Privacy incident readiness
- Rollout blocking conditions

This checklist does not replace full security penetration testing, legal privacy review, IAM implementation, or final compliance certification.

## 3. Baseline Dependency

This checklist depends on:

`06550_Policy_Customer_Link_Token_QR_NFC_Session_Expiration_Abuse_Prevention_And_Security_Boundary.md`

`06610_Policy_Customer_Privacy_Consent_Data_Retention_Evidence_Access_Support_Visibility_And_Runtime_Governance.md`

`006620_Policy_Customer_Runtime_Evidence_Audit_Trail_Traceability_Closeout_Handoff.md`

`006730_SOP_Customer_Runtime_Support_Dispute_Compensation_And_Privacy_Escalation_Operation.md`

It supports pilot readiness verification in:

`06640_Checklist_Customer_Runtime_Pilot_Readiness_Entry_Closeout_Rollout_And_Evidence_Acceptance.md`

## 4. Checklist Result Model

Each item must be marked with one of the following results.

| Result | Meaning |
|---|---|
| Pass | Requirement is verified and evidenced |
| Conditional Pass | Requirement is usable only with restriction or waiver |
| Hold | Requirement requires review before activation |
| Fail | Requirement blocks pilot or rollout |
| Not In Scope | Requirement is intentionally excluded from current scope |

A `Conditional Pass` must include owner, restriction, review trigger, and evidence link.

## 5. Preflight Scope Confirmation

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Store scope confirmed | Store and business date context are correct |  |  |  |
| Customer channel scope confirmed | QR/NFC, web app, kiosk, native app, support link scope is defined |  |  |  |
| Privacy owner assigned | Privacy/compliance review owner is assigned |  |  |  |
| Link security owner assigned | Link/token security owner is assigned |  |  |  |
| Support owner assigned | Privacy-sensitive customer support escalation owner is assigned |  |  |  |
| Evidence owner assigned | Evidence access and packet owner is assigned |  |  |  |
| Pilot restriction scope confirmed | Features excluded from pilot are disabled or hidden |  |  |  |
| Emergency pause path confirmed | Affected customer flow can be paused or disabled |  |  |  |

## 6. Static QR/NFC Link Preflight

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Static link contains no customer data | Static QR/NFC URL does not embed customer/session/order/payment data |  |  |  |
| Static link resolves correct store | QR/NFC resolves only to intended store/context |  |  |  |
| Static link cannot perform sensitive action | Static scan cannot confirm arrival, place order, pay, refund, or claim benefit by itself |  |  |  |
| Static link safe on repeated scan | Repeated scan does not duplicate waiting/order/payment action |  |  |  |
| Static link safe across devices | Opening on another device does not expose previous customer session |  |  |  |
| Static link error wording safe | Invalid store or disabled flow shows safe message |  |  |  |
| QR/NFC physical placement reviewed | Link placement does not confuse table, entrance, or store context |  |  |  |
| QR/NFC replacement process defined | Lost, wrong, or outdated QR/NFC can be removed or replaced |  |  |  |

## 7. Dynamic Link And Token Preflight

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Token scope defined | Dynamic token has explicit allowed action |  |  |  |
| Token expiration defined | Token expiration is configured and tested |  |  |  |
| Token revocation tested | Token can be revoked after cancel, merge, split, incident, or risk |  |  |  |
| Token replay blocked | Repeated token use cannot duplicate sensitive action |  |  |  |
| Token raw value not logged | Raw token is not exposed in audit/evidence/log views |  |  |  |
| Token hash/reference used | Evidence uses safe token reference or hash |  |  |  |
| Scope mismatch blocked | Token for one session/action cannot be used for another |  |  |  |
| Expired token recovery safe | Expired link routes to recovery without exposing data |  |  |  |
| Staff assist link scoped | Staff-generated link records actor, reason, scope, and expiration |  |  |  |
| Support recovery link scoped | Support-generated link is case-scoped and time-limited |  |  |  |
| Abuse signals captured | Repeated invalid attempts, replay, or suspicious opens are recorded |  |  |  |

## 8. Guest Session Privacy Preflight

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Guest ID separated | Guest identity is separate from customer account, table, order, and payment |  |  |  |
| Guest session scoped | Guest session can access only its own allowed flow |  |  |  |
| Guest session expiration defined | Guest-facing access expires according to policy |  |  |  |
| Guest session recovery safe | Recovery does not expose another guest/session |  |  |  |
| Guest contact minimized | Contact data is collected only when needed |  |  |  |
| Guest not auto-marketed | Guest contact is not used for marketing without consent |  |  |  |
| Guest claim controlled | Guest-to-account claim requires valid proof/session/link/support validation |  |  |  |
| Guest evidence preserved | Guest evidence remains traceable after expiration or merge |  |  |  |

## 9. Customer Account Linkage Preflight

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Account linkage explicit | Account is linked only by customer action or approved support flow |  |  |  |
| Guest-to-account merge tested | Merge preserves original guest/session/order/payment evidence |  |  |  |
| Wrong account detection path defined | Wrong account link can be reported and reviewed |  |  |  |
| Duplicate identity review defined | Duplicate account/guest cannot auto-merge unsafely |  |  |  |
| Party/account separation confirmed | Party identity does not expose all customer account data |  |  |  |
| Payment/account separation confirmed | Account ownership is not treated as payment truth |  |  |  |
| Account support access scoped | Support sees only case-relevant account/session evidence |  |  |  |
| Account correction evidenced | Account correction creates before/after and reason evidence |  |  |  |

## 10. Waiting Visibility Preflight

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Waiting page scoped | Customer sees only own waiting status |  |  |  |
| Queue display minimized | Queue position display does not expose other customers |  |  |  |
| Call message recipient verified | Call notification is sent/displayed to correct recipient/session |  |  |  |
| No-show display safe | No-show status does not expose internal staff notes |  |  |  |
| Recovery flow safe | Waiting recovery does not reveal whether another session exists |  |  |  |
| Duplicate waiting review private | Duplicate detection is not exposed unsafely to customer |  |  |  |
| Staff waiting view scoped | Staff sees only operationally necessary customer data |  |  |  |
| Waiting dispute path defined | Customer can be routed to support without exposing internal evidence |  |  |  |

## 11. Table Visibility Preflight

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Table QR scoped | Table QR opens only correct table/session context |  |  |  |
| Physical table not enough for identity | Table number alone cannot expose customer/order/payment data |  |  |  |
| Table session access scoped | Customer sees only own party/table session data |  |  |  |
| Reassignment safe | Table move does not expose previous or next party data |  |  |  |
| Merge/split visibility safe | Merge/split does not expose unrelated customer information |  |  |  |
| Order display scoped | Table page shows only authorized order context |  |  |  |
| Payment display scoped | Payment status is minimized and customer-scoped |  |  |  |
| Staff table view scoped | Staff sees operational context without unnecessary profile data |  |  |  |
| Table privacy incident path defined | Wrong table/session display routes to privacy incident |  |  |  |

## 12. Web App Privacy Preflight

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Session isolation tested | Browser refresh/new device does not expose another session |  |  |  |
| Menu display safe | Menu availability display does not expose internal stock or staff notes |  |  |  |
| Cart display scoped | Cart contents are visible only to correct session/account |  |  |  |
| Preorder display scoped | Preorder status is visible only to correct session/account |  |  |  |
| Payment status conservative | Payment status display avoids provider internals and unsafe conclusions |  |  |  |
| Error screen safe | Error screens do not expose stack traces, tokens, internal IDs, or provider details |  |  |  |
| Duplicate prevention private | Duplicate-blocking message does not reveal sensitive internal logic |  |  |  |
| Support handoff scoped | Web app support handoff includes context without exposing unrelated records |  |  |  |
| Web evidence redaction reviewed | Web app evidence is reviewable with sensitive fields protected |  |  |  |

## 13. Native App Continuity Privacy Preflight

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Native scope declared | Native app is included, excluded, or future-compatible only |  |  |  |
| Deep link scoped | Native deep link follows token scope and expiration rules |  |  |  |
| Push recipient safe | Push notification is sent to correct account/device/session |  |  |  |
| Push wording minimized | Push does not expose sensitive order/payment/support details on lock screen |  |  |  |
| Stale state blocked | Cached native state cannot act as current runtime truth |  |  |  |
| Web/native conflict safe | Conflict routes to recovery without exposing unrelated context |  |  |  |
| Account continuity private | Native account continuity does not expose guest/session records incorrectly |  |  |  |
| Native support handoff scoped | Native support handoff sends only case-relevant context |  |  |  |

## 14. Notification And Multilingual Privacy Preflight

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Operational vs marketing separated | Service notification is separated from marketing communication |  |  |  |
| Recipient selection verified | Notification recipient/session selection is correct |  |  |  |
| Message content minimized | Message does not include unnecessary personal/payment/support data |  |  |  |
| Payment wording safe | Payment wording avoids unsafe success/failure claims under uncertainty |  |  |  |
| Refund wording safe | Refund/cancel wording distinguishes request, approval, and completion |  |  |  |
| Support wording safe | Support message does not promise unapproved outcome |  |  |  |
| Multilingual meaning reviewed | Translated message does not overstate source state |  |  |  |
| Message expiration handled | Expired/superseded messages are not treated as current truth |  |  |  |
| Misdelivery incident path defined | Wrong recipient notification creates privacy/support review |  |  |  |

## 15. Consent Preflight

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Service consent captured where required | Service-related consent is recorded where policy requires it |  |  |  |
| Membership consent separated | Membership enrollment is separate from basic guest service |  |  |  |
| Marketing consent separated | Marketing opt-in is not bundled with operational service flow |  |  |  |
| Consent version recorded | Consent text/version/source/timestamp can be traced |  |  |  |
| Consent withdrawal supported | Withdrawal path exists for applicable consent type |  |  |  |
| Withdrawal does not erase evidence | Consent withdrawal does not delete required operational/payment/support evidence |  |  |  |
| Optional data use separated | Optional profile or recommendation use is separately governed |  |  |  |
| Support follow-up consent/necessity reviewed | Support contact is based on valid purpose and record |  |  |  |

## 16. Staff And Manager Access Preflight

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Staff role scoped | Staff can view only live-operation customer data |  |  |  |
| Staff sensitive action evidenced | Staff customer-impacting actions create evidence |  |  |  |
| Manager sensitive access scoped | Manager sensitive views are purpose-scoped |  |  |  |
| Manager approval evidenced | Manager overrides/compensation/privacy-related actions are evidenced |  |  |  |
| Reauthentication rule defined | Sensitive actions require reauthentication where policy requires |  |  |  |
| Staff note visibility controlled | Staff notes are not exposed to customer-facing surfaces |  |  |  |
| Internal severity hidden | Incident/support severity is not customer-facing by default |  |  |  |
| Access audit reviewed | Sensitive customer data access is logged where required |  |  |  |

## 17. Support And Finance Visibility Preflight

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Support case visibility scoped | Support sees only case-relevant customer/runtime evidence |  |  |  |
| Support customer communication safe | Support messages do not overpromise outcome |  |  |  |
| Finance visibility minimized | Finance sees payment/refund/cancel context without broad profile data |  |  |  |
| Payment reference protected | Provider/payment references are hidden from unauthorized roles |  |  |  |
| Refund/cancel evidence scoped | Refund/cancel review exposes only required data |  |  |  |
| Benefit financial impact scoped | Coupon/benefit finance impact is visible only to required roles |  |  |  |
| Support-to-finance handoff safe | Handoff includes case context without unnecessary personal data |  |  |  |
| Case export restricted | Support/finance evidence export is controlled |  |  |  |

## 18. Evidence Access And Retention Preflight

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Evidence families classified | Waiting, table, link, web, support, benefit, privacy evidence are classified |  |  |  |
| Evidence visibility class defined | Each evidence family has role visibility |  |  |  |
| Sensitive evidence redacted | Sensitive fields are redacted from lower-privilege views |  |  |  |
| Evidence access logged | Sensitive evidence access creates audit record where required |  |  |  |
| Evidence retention class defined | Active, support, finance, audit, privacy, legal hold classes are defined |  |  |  |
| Expiration not equal deletion | Session expiration does not delete required evidence |  |  |  |
| Anonymization boundary defined | Personal data can be minimized without breaking required evidence |  |  |  |
| Legal/audit hold path defined | Evidence can be retained under hold when required |  |  |  |
| Evidence packet safe to share internally | Pilot packet does not overexpose customer data |  |  |  |

## 19. Privacy Incident Readiness

| Item | Check | Result | Owner | Evidence |
|---|---|---|---|---|
| Privacy incident triggers defined | Wrong-session, misdelivery, overexposure, wrong account triggers are defined |  |  |  |
| Containment path defined | Active exposure can be stopped quickly |  |  |  |
| Escalation owner assigned | Privacy/compliance owner is assigned |  |  |  |
| Support linkage defined | Customer complaint can link to privacy incident |  |  |  |
| Evidence preservation defined | Link/display/access evidence is preserved |  |  |  |
| Customer-facing wording prepared | Staff/support have safe privacy-sensitive wording |  |  |  |
| Rollout blocker path defined | Privacy issue can block pilot/rollout expansion |  |  |  |
| Closeout review included | Privacy incidents appear in daily closeout |  |  |  |

## 20. Blocking Conditions

Pilot entry or rollout expansion must be blocked when:

- Static QR/NFC exposes customer/session/order/payment data
- Dynamic token can be replayed for sensitive action
- Expired token can still access sensitive session
- Link opens wrong customer, waiting, table, order, or payment context
- Customer-facing page can show another customer’s data
- Payment status exposes unsafe or incorrect conclusion
- Notification can be sent to wrong recipient without detection
- Guest-to-account merge can attach wrong identity without review
- Staff can view or change sensitive customer data without evidence
- Support or finance can access unrelated customer data
- Privacy incident path is not defined
- Evidence access is uncontrolled for sensitive records
- Consent separation is missing for marketing or membership use

Blocking conditions must route to:

`06670_Register_Customer_Runtime_Risk_Waiver_Blocker_Backlog_Carry_Forward_And_Rollout_Control.md`

## 21. Preflight Acceptance Record

| Field | Value |
|---|---|
| Preflight Date |  |
| Store |  |
| Business Date / Pilot Scope |  |
| Reviewed By |  |
| Privacy Owner |  |
| Link Security Owner |  |
| Evidence Owner |  |
| Overall Result | Pass / Conditional Pass / Hold / Fail |
| Restrictions |  |
| Waivers |  |
| Blockers |  |
| Evidence Packet Link |  |
| Next Review Trigger |  |

## 22. Acceptance Criteria

This checklist is accepted when:

- Static QR/NFC link safety is checked
- Dynamic token scope, expiration, revocation, and replay prevention are checked
- Guest session privacy is checked
- Customer account linkage safety is checked
- Waiting and table visibility are checked
- Web app and native app privacy are checked
- Notification and multilingual privacy are checked
- Consent separation is checked
- Staff and manager access are checked
- Support and finance visibility are checked
- Evidence access and retention are checked
- Privacy incident readiness is checked
- Blocking conditions are documented
- Final preflight acceptance record is completed

## 23. Related Documents

Related document families include:

- Customer link token QR/NFC security policy
- Customer privacy consent data retention policy
- Customer runtime evidence packet policy
- Customer support dispute compensation privacy escalation SOP
- Customer Runtime pilot readiness checklist
- Customer Runtime pilot execution runbook
- Customer Runtime risk waiver blocker register
- Customer web app runtime policy
- Customer native app runtime policy
- Customer account guest merge policy
- Waiting queue policy
- Table matching policy
- Runtime evidence policy
- Security audit governance
- Privacy incident response policy

## 24. Final Rule

A customer link is a door.

Before customers use it, the system must prove that the door opens only to the right store, the right session, the right customer context, the right action, and the right evidence.

This checklist verifies privacy, consent, and link security before customer runtime pilot or rollout exposure.