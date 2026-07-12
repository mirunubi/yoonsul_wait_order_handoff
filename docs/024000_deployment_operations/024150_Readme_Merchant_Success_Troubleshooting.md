# 024150_Readme_Merchant_Success_Troubleshooting

Legacy path: $old.

1\. Purpose

This folder defines Merchant Success, First 7 Days Activation, First 30 Days Troubleshooting, AI Menu Stabilization, Request Board Adoption, Manual POS Fallback Training, Trial Usage Review, Conversion Readiness, and Early Support Governance for CatchMenu / Wait Order Handoff.

CatchMenu can enter stores lightly through QR/NFC Entry Plate, AI Menu Intake, Owner Console, and POS-less or POS-light operation.

However, lightweight adoption succeeds only if the first operational period is stabilized.

A merchant may agree to a trial, but trial value is proven only when:

the Entry Plate scans correctly
the menu is accurate
staff understands the request board
manual POS fallback is workable
guest requests are visible
translation and critical warnings are trusted
owner sees usage value
support issues are resolved quickly
conversion conversation is backed by evidence

Core purpose:

Define merchant success governance.
Define first 7 days activation check.
Define first 30 days troubleshooting flow.
Define AI menu correction and live menu stabilization.
Define request board staff adoption policy.
Define manual POS fallback training.
Define trial usage review.
Define conversion readiness.
Define support signal and evidence.
Prevent trial failure caused by poor onboarding or unresolved early friction.

Korean purpose:

Merchant Success 거버넌스를 정의한다.
초기 7일 활성화 점검을 정의한다.
초기 30일 트러블슈팅 흐름을 정의한다.
AI 메뉴 보정과 라이브 메뉴 안정화를 정의한다.
요청판 직원 사용 정착 정책을 정의한다.
수동 POS fallback 교육을 정의한다.
체험 사용량 리뷰를 정의한다.
유료 전환 준비 상태를 정의한다.
부실한 온보딩이나 초기 마찰 미해결로 체험이 실패하는 것을 방지한다.

2\. Scope

This folder covers:

merchant success
first 7 days activation
first 30 days troubleshooting
trial stabilization
AI menu correction
live menu stabilization
request board adoption
staff usage training
manual POS fallback training
Owner Console guidance
usage review
conversion readiness
early support case
support signal
evidence packet
merchant feedback
sales handoff
Merchant Ops handoff

This folder does not define:

sales commission payout
full billing engine
payment provider execution
POS adapter implementation
KDS implementation
final legal support contract
HR training system
full CRM automation

Related folders:

docs/000100_project_foundation/000300_documentation_governance/000300_Readme_Documentation_Governance.md/
docs/001000_mvp_scope/001100_Policy_CatchMenu_I18n_Order_Request_Translation.md/
docs/02400\_owner\_console/ (not yet implemented)
docs/02600\_merchant\_ops/ (not yet implemented)
docs/003000_saas_runtime/003100_Readme_Entry_Media_Inventory.md/
docs/03500\_external\_pos\_integration\_runtime/
docs/03600\_billing\_plan\_settlement/
docs/03700\_sales\_partner\_field\_growth/
docs/03800\_native\_all\_in\_one\_service\_runtime/
sop/competitive\_response/

3\. Core Principle

Trial success depends on early stabilization.

Core rule:

Trial installation is not success.
Stable merchant usage is success.

Korean rule:

체험 설치가 성공이 아니다.
매장이 안정적으로 사용하는 것이 성공이다.

4\. Merchant Success Boundary

Merchant Success owns:

activation check
merchant onboarding follow-up
first usage troubleshooting
AI menu correction coordination
request board adoption check
manual POS fallback guidance
trial usage review
merchant feedback collection
conversion readiness signal
support escalation

Merchant Success does not own:

sales commission eligibility
billing plan authority
POS credential binding
Entry Media inventory truth
AI extraction engine
payment execution
legal dispute final decision

Core rule:

Merchant Success improves adoption.
It does not override system authority.

5\. Merchant Success Lifecycle

Suggested lifecycle:

PRE\_ACTIVATION
ACTIVATION\_DAY
FIRST\_7\_DAYS
FIRST\_30\_DAYS
TRIAL\_MIDPOINT
CONVERSION\_READINESS
CONVERTED\_SUCCESS
NON\_CONVERSION\_RECOVERY

Meaning:

PRE\_ACTIVATION
\= store setup is being prepared

ACTIVATION\_DAY
\= Entry Plate and menu flow go live

FIRST\_7\_DAYS
\= scan, menu, request board, staff adoption are checked

FIRST\_30\_DAYS
\= real operational friction is identified and resolved

TRIAL\_MIDPOINT
\= usage and merchant value are reviewed

CONVERSION\_READINESS
\= merchant has enough evidence to decide paid conversion

CONVERTED\_SUCCESS
\= merchant converts and continues operation

NON\_CONVERSION\_RECOVERY
\= merchant does not convert and recovery workflow starts

6\. First 7 Days Activation Check

The first 7 days should confirm that the service is technically and operationally usable.

Checklist:

Entry Plate scans correctly
QR fallback works
NFC works if available
store context resolves correctly
menu opens correctly
menu prices are correct
menu categories are usable
language display is acceptable
request flow works
request board is visible to staff
store can confirm request if enabled
manual POS fallback is understood
support contact is known

Core rule:

First 7 days prove activation, not business value yet.

7\. First 30 Days Troubleshooting

The first 30 days should identify adoption friction.

Check areas:

guest scan rate
menu view rate
request send rate
staff response behavior
wrong menu reports
translation concerns
critical warning concerns
manual POS burden
Owner Console usage
support cases
merchant satisfaction
sales partner follow-up quality

Core rule:

First 30 days determine whether the trial becomes a habit.

8\. AI Menu Stabilization

AI Menu Intake may create initial draft quickly, but live operation requires stabilization.

Stabilization checks:

item names correct
prices correct
options correct
sold-out or unavailable items handled
categories understandable
translations reviewed
allergy/critical warning candidates reviewed
merchant approval recorded
correction history preserved

Core rule:

AI draft must become trusted live menu through review and correction.

9\. Live Menu Correction

Menu correction may be needed after launch.

Correction sources:

merchant reports wrong price
staff reports wrong option
guest confusion occurs
sales partner field note
support case
AI confidence low
translation mismatch
menu changed in store

Correction workflow:

detect issue
mark review required
edit draft or live menu
review correction
publish updated menu
record audit
notify merchant if needed

Core rule:

Menu correction must be fast but auditable.

10\. Request Board Adoption

Request board adoption is critical.

Adoption checks:

staff knows where request board is
staff knows how to read request
staff knows confirm/done meaning
staff knows manual POS entry flow
staff checks board during service
unconfirmed requests do not pile up
owner understands warning signals

Core rule:

A request board that staff does not watch has no operational value.

11\. Manual POS Fallback Training

Before full POS integration, manual POS fallback may be required.

Training should cover:

how to read selected items
how to read options
how to read critical warning
how to enter order manually into POS
how to mark request handled
how to avoid duplicate entry
how to handle request change
how to call support

Core rule:

Manual POS fallback is official interim operation, not failure.

12\. POS Integration Readiness Signal

Some merchants may need POS integration earlier.

POS readiness signals:

request volume high
manual POS fallback burden high
merchant asks for POS connection
staff duplicate entry complaints
medium or large store
table-specific operation needed
preorder volume grows

Core rule:

Merchant Success should identify when POS integration becomes necessary.

13\. KDS Readiness Signal

Some merchants may need KDS path later.

KDS readiness signals:

kitchen misses request
prep timing matters
waiting-to-order handoff becomes active
preorder volume grows
group orders increase
kitchen station coordination needed
delay tracking needed

Core rule:

KDS readiness should emerge from operational friction, not feature ambition alone.

14\. Owner Console Guidance

Merchant Success should ensure Owner Console usage.

Owner Console guidance includes:

login guidance
trial status view
menu management location
request board location
usage summary location
support entry point
billing/plan view if enabled
POS integration status if enabled
promotion CMS if enabled

Core rule:

Owner Console must become merchant's control surface.

15\. Usage Review

Usage review helps conversion.

Usage metrics may include:

Entry Plate scans
menu views
request sends
request confirmations
language use
repeat usage
peak time usage
support issues
manual POS burden
merchant comments
staff comments

Core rule:

Usage review turns trial into conversion evidence.

16\. Conversion Readiness

Conversion readiness means merchant has enough evidence and stability to consider paid plan.

Signals:

menu stable
request board used
merchant understands value
usage exists
support issues resolved or acceptable
manual POS fallback acceptable or POS integration needed
owner has seen usage summary
pricing/plan explained
trial expiry understood

Core rule:

Do not push paid conversion before basic operating friction is understood.

17\. Non-Conversion Recovery

If merchant does not convert, recovery may begin.

Recovery triggers:

trial expired
merchant declined
not using
unreachable
low usage
support unresolved
merchant closed
wrong fit

Recovery actions:

limit owner access
deactivate guest flow if policy requires
request Entry Plate recovery
record reason
preserve history
release asset for reuse after proper process

Core rule:

Non-conversion must become learnable data and recoverable asset flow.

18\. Merchant Feedback

Merchant feedback should be structured.

Feedback categories:

menu setup
price accuracy
translation quality
request board usability
staff burden
guest reaction
POS fallback burden
reservation/preorder interest
promotion interest
support quality
pricing concern
competitor comparison

Core rule:

Merchant feedback should improve product, support, and sales positioning.

19\. Sales Handoff

Sales partner should not disappear after installation.

Sales handoff should include:

lead source
merchant expectation
promised features
trial offer terms
menu material status
Entry Plate installation note
merchant concern
competitor context
first follow-up schedule

Core rule:

Sales promise must be visible to Merchant Success.

20\. Merchant Ops Handoff

Merchant Ops may take over after sales.

Merchant Ops handoff should include:

merchant account
merchant store
Entry Media reference
trial status
menu setup status
Owner Console access
request board status
support issues
conversion target date
recovery risk

Core rule:

Merchant Ops must receive enough context to stabilize the trial.

21\. Early Support Case

Early support cases should be tagged.

Tags:

ACTIVATION\_BLOCKER
MENU\_CORRECTION
SCAN\_ISSUE
REQUEST\_BOARD\_ISSUE
STAFF\_TRAINING
POS\_FALLBACK
TRANSLATION\_ISSUE
CRITICAL\_WARNING
OWNER\_CONSOLE\_LOGIN
TRIAL\_STATUS
CONVERSION\_QUESTION

Core rule:

Early support cases are product signals, not only support burden.

22\. Merchant Success Status

Suggested statuses:

NOT\_STARTED
ACTIVATION\_PENDING
ACTIVATED
FIRST\_7\_DAYS\_CHECK\_REQUIRED
FIRST\_7\_DAYS\_PASSED
FIRST\_30\_DAYS\_SUPPORT\_REQUIRED
STABILIZED
CONVERSION\_READY
CONVERSION\_BLOCKED
CONVERTED
NON\_CONVERSION\_RECOVERY\_REQUIRED

Core rule:

Merchant Success status should be separate from billing status and service status.

23\. Risk Levels

Merchant success risk may be categorized.

Risk levels:

LOW
MEDIUM
HIGH
CRITICAL

Risk factors:

no scan activity
menu not stable
staff not checking request board
support issue unresolved
merchant unreachable
manual POS burden high
negative owner feedback
trial expiry approaching

Core rule:

Risk should trigger follow-up before trial fails.

24\. Support Signals

Support signals may include:

TRIAL\_INSTALLED\_NOT\_ACTIVATED
ENTRY\_PLATE\_SCAN\_FAILURE
AI\_MENU\_REVIEW\_BLOCKED
LIVE\_MENU\_CORRECTION\_REQUIRED
REQUEST\_BOARD\_NOT\_USED
UNCONFIRMED\_REQUESTS\_ACCUMULATING
STAFF\_TRAINING\_REQUIRED
MANUAL\_POS\_BURDEN\_HIGH
FIRST\_7\_DAYS\_CHECK\_OVERDUE
FIRST\_30\_DAYS\_SUPPORT\_REQUIRED
CONVERSION\_READINESS\_LOW
TRIAL\_EXPIRY\_WITH\_LOW\_USAGE
ENTRY\_PLATE\_RECOVERY\_REQUIRED

Support Signal alerts.

It does not mutate merchant service state by itself.

25\. Audit Events

Recommended audit events:

MERCHANT\_SUCCESS\_STARTED
FIRST\_7\_DAYS\_CHECK\_CREATED
FIRST\_7\_DAYS\_CHECK\_COMPLETED
FIRST\_30\_DAYS\_REVIEW\_CREATED
FIRST\_30\_DAYS\_REVIEW\_COMPLETED
AI\_MENU\_CORRECTION\_REQUESTED
AI\_MENU\_CORRECTION\_COMPLETED
REQUEST\_BOARD\_TRAINING\_COMPLETED
MANUAL\_POS\_FALLBACK\_TRAINING\_COMPLETED
USAGE\_REVIEW\_CREATED
CONVERSION\_READINESS\_MARKED
CONVERSION\_BLOCKER\_RECORDED
NON\_CONVERSION\_RECOVERY\_MARKED
MERCHANT\_FEEDBACK\_RECORDED

Minimum audit fields:

event\_id
merchant\_account\_id
merchant\_store\_id
actor\_type
actor\_id
action
previous\_value
new\_value
reason
created\_at
trace\_id

26\. Failure Events

Example failure codes:

WOH.MERCHANT\_SUCCESS.ACTIVATION.ENTRY\_MEDIA\_REQUIRED
WOH.MERCHANT\_SUCCESS.MENU.REVIEW\_REQUIRED
WOH.MERCHANT\_SUCCESS.REQUEST\_BOARD.NOT\_CONFIGURED
WOH.MERCHANT\_SUCCESS.POS\_FALLBACK.TRAINING\_REQUIRED
WOH.MERCHANT\_SUCCESS.FIRST\_7\_DAYS.CHECK\_OVERDUE
WOH.MERCHANT\_SUCCESS.FIRST\_30\_DAYS.REVIEW\_OVERDUE
WOH.MERCHANT\_SUCCESS.CONVERSION.EVIDENCE\_REQUIRED
WOH.MERCHANT\_SUCCESS.RECOVERY.ENTRY\_MEDIA\_REQUIRED

Failure/error naming is governed by:

docs/000080_Governance_CatchMenu_Failure_Error_Code_Naming_And_Diagnostic_Hierarchy.md

27\. Relationship To Entry Media Inventory

Entry Media Inventory owns the physical/digital asset lifecycle.

Merchant Success uses Entry Media status to check activation.

Examples:

Entry Media assigned
Entry Media active
Entry Media scan failing
Entry Media recovery required

Core rule:

Merchant Success can flag Entry Media issue.
Entry Media Inventory owns asset truth.

28\. Relationship To AI Menu Intake

AI Menu Intake owns menu draft generation and review process.

Merchant Success ensures menu becomes usable in real operation.

Core rule:

AI Menu Intake creates draft.
Merchant Success verifies operational stability.

29\. Relationship To Stage 0 Runtime

Stage 0 Runtime owns guest menu/request flow.

Merchant Success verifies whether store can actually use the flow.

Core rule:

Runtime can function technically while merchant adoption still fails.
Merchant Success closes that gap.

30\. Relationship To External POS Integration

External POS Integration may not be ready for every merchant.

Merchant Success supports manual POS fallback and identifies POS integration need.

Core rule:

Manual POS fallback is acceptable temporarily.
Repeated fallback burden becomes POS integration signal.

31\. Relationship To Billing Plan Settlement

Billing Plan Settlement owns trial, paid conversion, entitlement, billing status, and suspension.

Merchant Success provides conversion readiness and usage evidence.

Core rule:

Merchant Success supports conversion evidence.
Billing governs paid conversion and entitlement.

32\. Relationship To Sales Partner Field Growth

Sales Partner Field Growth creates leads and trial adoption.

Merchant Success stabilizes the merchant after installation.

Core rule:

Sales creates entry.
Merchant Success creates retention.

33\. Relationship To Native All-In-One Service Runtime

Native All-In-One Service Runtime defines the unified product path.

Merchant Success makes that path real in store operation.

Core rule:

Native all-in-one design becomes valuable only when merchants adopt the flow.

34\. MVP Requirements

Merchant Success Troubleshooting MVP should support at least:

merchant success record
activation status
first 7 days checklist
first 30 days checklist
AI menu correction flag
request board adoption flag
manual POS fallback training flag
usage review record
conversion readiness status
non-conversion recovery signal
support signal
audit event
failure event
merchant feedback note

MVP may defer:

advanced customer success automation
full CRM pipeline
automatic health scoring
AI-generated conversion recommendation
advanced support SLA automation
complex staff training module

35\. Suggested Conceptual Entities

Suggested entities:

merchant\_success\_records
merchant\_success\_status\_events
activation\_checklists
first\_7\_days\_checks
first\_30\_days\_reviews
menu\_stabilization\_reviews
request\_board\_adoption\_checks
pos\_fallback\_training\_events
usage\_review\_events
conversion\_readiness\_reviews
merchant\_feedback\_events
merchant\_success\_audit\_events
merchant\_success\_failure\_events
merchant\_success\_support\_signals

This document defines policy.

Actual schema may be designed later.

36\. Risk If Skipped

If Merchant Success Troubleshooting governance is skipped, risks include:

trial plate installed but never used
AI menu errors remain live
staff ignores request board
manual POS fallback feels burdensome
merchant forgets trial value
support issues remain unresolved
trial expires without conversion conversation
Entry Plate is not recovered
sales partner overpromises but no one stabilizes operation
low-cost adoption becomes low-value adoption

Therefore, Merchant Success Troubleshooting must be defined before aggressive field growth.

37\. Final Rule

Merchant success is the bridge between trial installation and paid conversion.

Final rule:

Install is not success.
Activation is not enough.
Check first 7 days.
Stabilize first 30 days.
Correct AI menu errors quickly.
Train request board usage.
Treat manual POS fallback as official interim flow.
Collect usage proof.
Resolve support issues.
Prepare conversion with evidence.
Recover Entry Plate if not converted.
Turn early friction into product improvement.
