# 06750_Register_Customer_Runtime_Message_Template_Translation_Status_Wording_And_Customer_Display_Control

## 1. Purpose

This register defines the Customer Runtime message template, translation, status wording, and customer display control record.

The purpose is to ensure that all customer-facing messages shown through QR/NFC entry, waiting page, web app, native app, kiosk, mini kiosk, table page, notification, support page, membership/benefit surface, and recovery flow remain conservative, accurate, multilingual-safe, and evidence-backed.

Customer-facing wording is operationally sensitive.  
A message can create an implied promise about waiting priority, table assignment, order confirmation, payment success, refund completion, coupon restoration, compensation, or privacy review.

This register prevents customer-visible wording from drifting beyond runtime truth.

## 2. Scope

This register covers:

- Customer-facing message templates
- Runtime status wording
- Waiting and no-show messages
- Table and seating messages
- Order and preorder messages
- Payment uncertainty messages
- Refund and cancel messages
- Link expiration and recovery messages
- Web app and native app status messages
- Kiosk and mini kiosk continuation messages
- Support case messages
- Membership, coupon, and benefit messages
- Privacy-sensitive messages
- Multilingual translation review
- Template versioning
- Message retirement and replacement
- Customer display evidence linkage

This register does not define final marketing copy, brand campaign language, full localization process, or legal notice wording.

## 3. Baseline Dependency

This register depends on:

`06540_Policy_Entrance_Customer_Notification_Call_Message_Status_Display_Multilingual_Guidance_And_Evidence_Control.md`

`06610_Policy_Customer_Privacy_Consent_Data_Retention_Evidence_Access_Support_Visibility_And_Runtime_Governance.md`

`06620_Policy_Customer_Runtime_Evidence_Packet_Audit_Trail_Cross_Flow_Traceability_Closeout_Handoff_And_Governance.md`

`06700_Template_Customer_Runtime_Event_Audit_Evidence_Field_Specification_Template.md`

`06740_Checklist_Customer_Runtime_Privacy_Consent_And_Link_Security_Preflight_Check.md`

This register routes message-related risks to:

`06670_Register_Customer_Runtime_Risk_Waiver_Blocker_Backlog_Carry_Forward_And_Rollout_Control.md`

## 4. Core Principle

Customer-facing wording must never outrun authoritative runtime state.

Every message must answer:

1. Which runtime state allows this message?
2. Which event creates or updates this message?
3. Which customer surface displays it?
4. Which language versions exist?
5. What action does the customer think they can take?
6. Does the message imply confirmation, payment success, refund, benefit, or compensation?
7. Is the message safe under uncertainty?
8. Is the message versioned and reviewable?
9. Can support prove what the customer saw?
10. Does this message create rollout risk if wrong?

## 5. Message Families

Customer Runtime messages must be grouped into families.

| Message Family | Meaning |
|---|---|
| Entrance | QR/NFC entry, store context, unavailable entry, recovery |
| Waiting | Waiting created, queue active, called, arrival, no-show, recovery |
| Table | Table preparing, table assigned, reassigned, merged, split, closed |
| Order | Cart, preorder submitted, checking, confirmed, rejected, cancelled |
| Payment | Payment pending, approved, failed, uncertain, refund/cancel status |
| Kitchen | Preparing, delayed, ready, served, remake, unavailable item |
| Link/Token | Expired link, invalid link, recovery, replay blocked, safe error |
| Web App | Session, cart, recovery, duplicate prevention, error |
| Native App | Deep link, push, stale state, app/web conflict, recovery |
| Membership | Coupon, benefit, visit count, loyalty, compensation benefit |
| Support | Case received, checking, owner review, resolved, rejected, reopened |
| Privacy | Privacy review, wrong-session concern, data access/restriction |
| Incident | Temporary unavailable, restricted flow, staff assist required |
| Multilingual | Translation-specific wording and fallback control |

Each message must have one primary family.

## 6. Message Risk Classes

Message risk must be classified.

| Risk Class | Meaning | Example |
|---|---|---|
| MSG-R1 | High-risk financial, privacy, legal, or irreversible trust implication | “Payment completed” |
| MSG-R2 | Material operational promise or customer priority implication | “Your table is ready” |
| MSG-R3 | Normal customer guidance with limited risk | “Please wait a moment” |
| MSG-R4 | Low-risk informational or help text | “Open this page again if needed” |

Payment, refund, compensation, privacy, no-show, and order confirmation wording must be treated as MSG-R1 or MSG-R2 unless proven otherwise.

## 7. Template Status Model

Each template must have a controlled status.

| Status | Meaning |
|---|---|
| Draft | Template is being prepared |
| Review Required | Needs operation, support, privacy, finance, or translation review |
| Approved | Approved for configured scope |
| Active | Currently usable in runtime |
| Restricted | Usable only under condition, store, language, or pilot scope |
| Deprecated | Should not be used for new flows |
| Replaced | Replaced by another template |
| Retired | No longer usable |
| Blocked | Must not be used due to risk |
| Emergency Disabled | Disabled due to incident or rollout risk |

Status change must be timestamped and owner-linked.

## 8. Template Record Model

Each message template record must include:

| Field | Description |
|---|---|
| Template ID | Unique message template ID |
| Message Family | Entrance, Waiting, Table, Payment, Support, etc. |
| Risk Class | MSG-R1 to MSG-R4 |
| Template Status | Draft, Active, Restricted, Blocked, etc. |
| Runtime State | State that allows message |
| Event Trigger | Event that creates or updates message |
| Customer Surface | Web app, native app, kiosk, QR/NFC page, table page, notification, support page |
| Language | Language code |
| Source Language | Original source language |
| Message Text | Customer-facing text |
| Customer Action | Action the customer may take |
| Forbidden Implication | What this message must not imply |
| Review Owner | Owner responsible for approval |
| Version | Template version |
| Effective Scope | Store, pilot, feature, channel, or language scope |
| Evidence Required | Whether display/send evidence is required |
| Replacement Template | Replacement template ID if deprecated/replaced |
| Related Incident / Register | Link to incident or risk register where applicable |

## 9. Message Template Register Table

| Template ID | Family | Risk | Status | Runtime State | Event Trigger | Surface | Language | Version | Owner | Evidence Required |
|---|---|---|---|---|---|---|---|---|---|---|
| MSG-0001 |  |  |  |  |  |  |  |  |  |  |
| MSG-0002 |  |  |  |  |  |  |  |  |  |  |
| MSG-0003 |  |  |  |  |  |  |  |  |  |  |

## 10. Entrance Message Control

Entrance messages may include:

- Store entry available
- Store context cannot be confirmed
- QR/NFC link unavailable
- Entry flow temporarily paused
- Staff assist required
- Wrong store context
- Unsupported device/browser
- Recovery required

Entrance wording must not expose:

- Internal store IDs
- Token validation details
- Other customer/session existence
- Staff-only incident reason
- Internal rollout state

Example safe wording:

- “매장 연결을 확인하고 있습니다.”
- “현재 이 링크로는 이용할 수 없습니다. 직원에게 문의해 주세요.”
- “입장 흐름을 다시 확인해 주세요.”

## 11. Waiting Message Control

Waiting messages may include:

- Waiting registered
- Waiting active
- Customer called
- Arrival confirmation needed
- Arrival confirmed
- No-show pending
- No-show confirmed
- Waiting expired
- Waiting recovered
- Staff checking waiting status

Waiting wording must not imply:

- Guaranteed seating time
- Guaranteed queue priority beyond current state
- Staff fault before review
- No-show finality without recovery path where allowed
- Another customer’s queue position or details

Example safe wording:

- “대기 등록이 완료되었습니다.”
- “호출 상태를 확인해 주세요.”
- “도착 확인이 필요합니다.”
- “대기 상태를 직원이 확인하고 있습니다.”

## 12. Table Message Control

Table messages may include:

- Table preparing
- Table assigned
- Please move to assigned table
- Table reassignment in progress
- Table session closed
- Staff checking table context
- Table QR expired or invalid

Table wording must not imply:

- Order has been accepted unless confirmed separately
- Payment has succeeded unless confirmed separately
- KDS/kitchen preparation has started unless confirmed separately
- Another table’s status
- Internal table conflict

Example safe wording:

- “좌석 배정을 확인하고 있습니다.”
- “안내된 좌석으로 이동해 주세요.”
- “테이블 연결 상태를 확인 중입니다.”

## 13. Order And Preorder Message Control

Order messages may include:

- Cart saved
- Preorder submitted
- Store checking order
- Order accepted
- Order rejected
- Order unavailable
- Order cancelled
- Duplicate submission blocked

Order wording must distinguish:

- Cart draft
- Preorder submitted
- Store review
- POS accepted order
- Kitchen accepted ticket
- Cancel requested
- Cancel completed

Forbidden overstatement:

- “주문 완료” before authoritative order acceptance
- “조리 시작” before KDS/kitchen confirmation
- “취소 완료” when only cancel request exists

Example safe wording:

- “주문 내용을 확인하고 있습니다.”
- “주문 접수가 완료되었습니다.”
- “이미 제출된 주문을 확인 중입니다.”

## 14. Payment Message Control

Payment messages are high risk.

Payment messages may include:

- Payment not started
- Payment pending
- Payment approved
- Payment failed
- Payment uncertain
- Payment review required
- Duplicate charge review
- Refund requested
- Refund approved
- Refund completed
- Refund failed
- Cancel requested
- Cancel completed

Payment wording must distinguish:

- Attempt started
- Provider approved
- Provider failed
- Provider timeout
- POS Gateway uncertainty
- Refund requested
- Refund completed
- Customer bank/card posting delay

Forbidden overstatement:

- “결제 완료” without authoritative confirmation
- “환불 완료” when refund is only requested
- “결제 실패” when provider state is uncertain
- “중복 결제 아님” before finance/reconciliation review

Example safe wording:

- “결제 상태를 확인하고 있습니다.”
- “결제 결과 확인이 필요합니다.”
- “환불 요청이 접수되었습니다.”
- “환불 완료 여부는 확인 후 안내됩니다.”

## 15. Kitchen And Service Message Control

Kitchen/service messages may include:

- Preparing
- Delayed
- Ready
- Served
- Remake requested
- Remake in progress
- Item unavailable
- Substitution requested

Kitchen wording must not imply payment, refund, or final order acceptance unless those are separately confirmed.

Example safe wording:

- “조리 상태를 확인하고 있습니다.”
- “준비가 지연되고 있습니다.”
- “직원이 상태를 확인 중입니다.”

## 16. Link And Token Message Control

Link/token messages may include:

- Link expired
- Link invalid
- Action already submitted
- Recovery available
- Staff assist required
- Token replay blocked
- Scope mismatch safe error

Link/token wording must not expose:

- Raw token state
- Whether another customer/session exists
- Internal security reason
- Account/session matching logic
- Payment-sensitive context

Example safe wording:

- “이 링크는 더 이상 사용할 수 없습니다.”
- “다시 연결이 필요합니다.”
- “직원에게 확인을 요청해 주세요.”

## 17. Web App And Native App Message Control

App messages may include:

- Session restored
- Session expired
- Browser refresh recovery
- Duplicate action blocked
- App state stale
- Deep link unavailable
- Push opened but state changed
- Web/native conflict recovery

App wording must not expose:

- Internal exception names
- Stack traces
- Provider details
- Token or raw IDs
- Other customer context

Example safe wording:

- “최신 상태를 다시 확인하고 있습니다.”
- “이미 처리 중인 요청입니다.”
- “화면을 새로고침해 주세요.”

## 18. Membership And Benefit Message Control

Membership messages may include:

- Coupon available
- Coupon reserved
- Coupon applied
- Coupon used
- Coupon released
- Coupon restored
- Coupon expired
- Visit counted
- Benefit review
- Compensation coupon issued

Benefit wording must distinguish:

- Available
- Reserved
- Applied
- Consumed
- Restored
- Expired
- Under review

Forbidden overstatement:

- “쿠폰 복구 완료” before restoration event
- “방문 횟수 적립 완료” before qualifying event
- “보상 지급 완료” before compensation approval

Example safe wording:

- “쿠폰 적용 상태를 확인하고 있습니다.”
- “혜택 검토가 진행 중입니다.”
- “쿠폰이 적용되었습니다.”

## 19. Support Message Control

Support messages may include:

- Case received
- Checking
- Store review
- Payment review
- Finance review
- Benefit review
- Privacy review
- Waiting for customer
- Resolution proposed
- Resolved
- Rejected
- Reopened
- Carried forward

Support wording must not promise outcome before owner approval.

Example safe wording:

- “문의가 접수되었습니다.”
- “담당자가 기록을 확인하고 있습니다.”
- “결제 관련 확인이 필요합니다.”
- “처리 결과를 안내드리겠습니다.”

## 20. Privacy Message Control

Privacy-sensitive messages may include:

- Privacy review started
- Data access issue under review
- Wrong-session concern received
- Support/privacy owner checking
- Data restriction applied
- Resolution completed

Privacy wording must not prematurely deny exposure.

Forbidden overstatement:

- “개인정보 문제는 아닙니다” before privacy review
- “노출된 정보가 없습니다” without evidence
- “삭제했습니다” when evidence retention remains required

Example safe wording:

- “개인정보 관련 가능성을 확인하고 있습니다.”
- “담당자가 접근 기록을 확인 중입니다.”
- “확인 후 필요한 조치를 안내드리겠습니다.”

## 21. Translation Control

Every translated message must preserve source meaning.

Translation review must check:

- Confirmation strength
- Payment/refund meaning
- No-show finality
- Support outcome promise
- Privacy sensitivity
- Politeness level
- Local customer expectation
- Button/action label clarity
- Legal or compliance-sensitive wording
- Cultural misunderstanding risk

A translated message must not be approved only because it is linguistically fluent.

## 22. Translation Register Table

| Translation ID | Template ID | Source Language | Target Language | Source Version | Target Version | Reviewer | Status | Notes |
|---|---|---|---|---|---|---|---|---|
| TR-0001 |  |  |  |  |  |  |  |  |
| TR-0002 |  |  |  |  |  |  |  |  |

## 23. Customer Surface Control

Each template must declare allowed surfaces.

| Surface | Message Risk Notes |
|---|---|
| QR/NFC Page | Must be safe for public/open access |
| Waiting Page | Must avoid exposing other customers |
| Table Page | Must avoid wrong-session/table exposure |
| Web App | Must avoid stale runtime truth |
| Native App | Must handle push/deep link/stale state safely |
| Kiosk | Must support quick recovery and staff assist |
| Mini Kiosk | Must support multilingual and low-context customers |
| Staff Tablet Script | Staff-facing guidance must not leak to customer surface |
| Support Page | Must distinguish review, decision, and closure |
| Notification | Must be brief, privacy-minimized, and conservative |

A template approved for one surface is not automatically approved for another.

## 24. Versioning Rules

Message templates must be versioned.

| Change Type | Version Rule |
|---|---|
| Minor wording improvement with same meaning | Increment minor version |
| Customer-facing meaning change | New version required |
| Confirmation strength change | New version and owner review required |
| Payment/refund wording change | Finance/reconciliation review required |
| Privacy wording change | Privacy/compliance review required |
| Support outcome wording change | Support owner review required |
| Translation meaning change | Translation version required |
| Surface change | Surface-specific review required |
| Emergency disable | Status change with incident/register link required |

A message must not change meaning silently.

## 25. Approval Rules

Approval may be required from:

| Message Type | Required Reviewer |
|---|---|
| Waiting/no-show | Store Operations / Support |
| Table/seating | Store Operations |
| Order confirmation | Store Runtime / POS Gateway Owner |
| Payment/refund/cancel | Finance/Reconciliation / POS Gateway Owner |
| Coupon/benefit | Membership/Loyalty Owner / Finance where amount affected |
| Compensation | Support Owner / Manager Governance |
| Privacy | Privacy/Compliance Owner |
| Link/token security | Security/Runtime Owner |
| Multilingual | Translation Reviewer / Operation Owner |
| Pilot/rollout restriction | Release Owner |

High-risk messages require owner approval before activation.

## 26. Message Display Evidence

For risk-sensitive messages, evidence must capture:

- Template ID
- Template version
- Language
- Surface
- Recipient/session reference
- Runtime state at display/send
- Event trigger
- Timestamp
- Customer action, where applicable
- Expiration/supersession
- Delivery/open/display status, where available
- Related support/incident/closeout reference, where applicable

Message evidence must be available for support dispute and closeout review.

## 27. Message Defect Routing

A message defect must be routed when:

- Message overstates runtime state
- Translation changes meaning
- Payment wording is unsafe
- Refund/cancel wording is ambiguous
- Privacy wording denies issue prematurely
- Support wording promises unapproved outcome
- No-show message appears without call evidence
- Link error exposes internal logic
- Customer sees stale message
- Message shown to wrong recipient/session
- Template version cannot be proven

Defect routing targets:

- Message register correction
- Support case
- Privacy incident
- Finance review
- Runtime incident
- Rollout risk register
- Training backlog

## 28. Blocked Wording Register

| Blocked ID | Phrase / Pattern | Reason | Affected Family | Replacement Guidance | Owner |
|---|---|---|---|---|---|
| BW-0001 | “결제 완료” without approved payment confirmation | Overstates payment truth | Payment | Use payment confirmed only after authoritative event |  |
| BW-0002 | “환불 완료” before refund completion | Overstates refund state | Payment / Support | Use refund requested or refund review wording |  |
| BW-0003 | “주문 완료” before order acceptance | Overstates order truth | Order | Use order checking or order submitted wording |  |
| BW-0004 | “개인정보 문제는 아닙니다” before privacy review | Premature privacy denial | Privacy | Use privacy review wording |  |
| BW-0005 | “쿠폰 복구 완료” before restoration event | Overstates benefit state | Membership | Use benefit review wording |  |

## 29. Review Cadence

This register must be reviewed:

- Before pilot entry
- Before rollout expansion
- After payment wording change
- After refund/cancel process change
- After privacy incident
- After support escalation pattern
- After adding a language
- After changing QR/NFC or link flow
- After adding native app push/deep link
- After adding coupon/benefit flow
- After customer complaint about wording

Review result must be recorded.

## 30. Review Record

| Review Date | Scope | Reviewer | Findings | Required Changes | Status |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

## 31. Acceptance Criteria

This register is accepted when:

- Message families are defined
- Message risk classes are defined
- Template status model is defined
- Template record model is defined
- Template register table is available
- Entrance, waiting, table, order, payment, kitchen, link, app, membership, support, and privacy wording rules are defined
- Translation control is defined
- Customer surface control is defined
- Versioning rules are defined
- Approval rules are defined
- Message display evidence requirements are defined
- Defect routing is defined
- Blocked wording register is included
- Review cadence is defined

## 32. Related Documents

Related document families include:

- Customer notification multilingual guidance policy
- Customer privacy consent data retention policy
- Customer runtime evidence packet policy
- Customer event audit evidence field specification template
- Privacy consent and link security preflight checklist
- Customer support dispute compensation privacy escalation SOP
- Customer Runtime pilot readiness checklist
- Customer Runtime risk waiver blocker register
- Customer web app runtime policy
- Customer native app runtime policy
- Customer link token QR/NFC security policy
- Payment uncertainty policy
- Refund and cancel policy
- Membership loyalty coupon benefit policy

## 33. Final Rule

A customer message is a promise.

Every customer-facing word must be tied to runtime state, authority, evidence, language version, surface, and review owner.

This register controls customer display wording so that the system never promises more than it can prove.