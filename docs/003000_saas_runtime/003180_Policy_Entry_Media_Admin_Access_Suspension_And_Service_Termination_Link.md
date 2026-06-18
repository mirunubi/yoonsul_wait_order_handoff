# 003180_Policy_Entry_Media_Admin_Access_Suspension_And_Service_Termination_Link

Legacy path: $old.

1\. Purpose

This document defines how Entry Media lifecycle connects to merchant admin access suspension and service termination.

Entry Media is a reusable physical and logical asset.

Merchant admin access is an authorization layer.

Service termination is a merchant lifecycle event.

These are related, but they are not the same thing.

Core purpose:

Separate Entry Media state from admin access state.
Link trial expiration to admin suspension when needed.
Deactivate guest-facing media when service ends.
Preserve all mapping, access, and asset history.
Prevent terminated merchants from continuing active request flows.

Korean purpose:

Entry Media 상태와 관리자 접근 상태를 분리한다.
필요 시 체험 종료를 관리자 차단과 연결한다.
서비스 종료 시 손님-facing 미디어를 비활성화한다.
매핑, 접근, 자산 이력을 모두 보존한다.
종료된 매장이 계속 요청 흐름을 사용하는 것을 막는다.

2\. Scope

This document covers:

merchant admin access relationship
trial expiration
admin suspension request
admin suspension
service termination
Entry Media mapping deactivation
guest-facing inactive behavior
physical recovery relationship
reactivation after conversion or renewal
audit event
support signal
failure event

This document does not define:

full merchant contract lifecycle
billing engine
payment collection
legal collection process
field recovery SOP
menu creation workflow
AI menu intake
POS/KDS/payment integration

Related documents:

00300\_Entry\_Media\_Inventory\_Readme.md
00310\_QR\_NFC\_Entry\_Plate\_Assignment\_Recovery\_And\_Reallocation\_Policy.md
00320\_Entry\_Media\_Mapping\_History\_And\_Deactivation\_Policy.md
00330\_Entry\_Media\_Status\_Lifecycle\_And\_Audit\_Policy.md
00370\_Entry\_Media\_Scan\_Usage\_And\_Trial\_Observation\_Policy.md

3\. Core Principle

Admin access, service status, mapping status, and physical asset status are separate axes.

Core rule:

Suspend access when needed.
Deactivate mapping when needed.
Recover plate when needed.
Do not collapse these states into one.

Korean rule:

필요하면 접근을 차단한다.
필요하면 매핑을 비활성화한다.
필요하면 플레이트를 회수한다.
이 상태들을 하나로 뭉개지 않는다.

Example:

trial\_status \= TRIAL\_EXPIRED
admin\_access\_status \= ADMIN\_SUSPENDED
mapping\_status \= DEACTIVATED
physical\_asset\_status \= RECOVERY\_REQUESTED

Each axis has its own meaning.

4\. State Axes

This policy uses these status axes:

trial\_status
merchant\_service\_status
admin\_access\_status
entry\_media\_mapping\_status
physical\_asset\_status
recovery\_status

They must be tracked separately.

Reason:

Trial may expire before admin access is suspended.
Admin may be suspended before physical plate is recovered.
Mapping may be deactivated while the plate remains installed.
Plate may be recovered while admin data remains preserved.

5\. Merchant Service Status

Suggested merchant service statuses:

PROSPECT
TRIAL\_ACTIVE
TRIAL\_EXPIRED
CONVERTED
ACTIVE\_PAID
SUSPENDED
TERMINATION\_PENDING
TERMINATED
REACTIVATION\_PENDING

Meaning:

PROSPECT
\= merchant is being prepared or approached

TRIAL\_ACTIVE
\= trial service is active

TRIAL\_EXPIRED
\= trial period ended

CONVERTED
\= merchant agreed to continue

ACTIVE\_PAID
\= active production/paid use

SUSPENDED
\= service temporarily blocked

TERMINATION\_PENDING
\= service termination is being processed

TERMINATED
\= service ended

REACTIVATION\_PENDING
\= merchant may be reactivated after review

6\. Admin Access Status

Suggested admin access statuses:

ADMIN\_NOT\_CREATED
ADMIN\_PENDING
ADMIN\_ACTIVE
ADMIN\_SUSPENSION\_REQUESTED
ADMIN\_SUSPENDED
ADMIN\_REVOKED
ADMIN\_REACTIVATION\_REQUESTED
ADMIN\_REACTIVATED

Admin access status governs owner console access, menu management, request board access, and trial admin features.

Core rule:

Admin access must be scoped to current merchant status.

7\. Entry Media Mapping Status Relationship

Entry Media mapping status is governed by:

00320\_Entry\_Media\_Mapping\_History\_And\_Deactivation\_Policy.md

Relevant mapping statuses:

ACTIVE
SUSPENDED
DEACTIVATION\_REQUESTED
DEACTIVATED
REPLACED
EXPIRED

Mapping status determines whether QR/NFC can resolve to live guest flow.

Admin access status determines whether merchant users can manage or view owner/admin functions.

8\. Physical Asset Status Relationship

Physical asset status is governed by:

00330\_Entry\_Media\_Status\_Lifecycle\_And\_Audit\_Policy.md

Relevant physical statuses:

INSTALLED
RECOVERY\_REQUESTED
RECOVERY\_SCHEDULED
RECOVERED
REALLOCATION\_READY
LOST
DAMAGED
RETIRED

Physical status determines whether the plate is still at the store, recovered, reusable, lost, damaged, or retired.

9\. Trial Expiration Default Flow

When a trial expires without conversion, the expected flow is:

TRIAL\_ACTIVE
→ TRIAL\_EXPIRED
→ ADMIN\_SUSPENSION\_REQUESTED
→ DEACTIVATION\_REQUESTED
→ RECOVERY\_REQUESTED

After processing:

ADMIN\_SUSPENDED
MAPPING\_DEACTIVATED
PHYSICAL\_RECOVERY\_PENDING

After field recovery:

RECOVERED
→ INSPECTION\_REQUIRED
→ REALLOCATION\_READY

Core rule:

Trial expiration starts controlled shutdown.
It does not erase history.

10\. Conversion Flow

If merchant converts before or at trial end:

TRIAL\_ACTIVE
→ CONVERTED
→ ACTIVE\_PAID

Expected linked state:

admin\_access\_status \= ADMIN\_ACTIVE
entry\_media\_mapping\_status \= ACTIVE
physical\_asset\_status \= INSTALLED

The Entry Plate remains installed.

Mapping remains active.

Trial history remains preserved.

Core rule:

Conversion continues service.
It does not delete trial history.

11\. Merchant Decline Flow

If merchant declines:

TRIAL\_ACTIVE or TRIAL\_EXPIRED
→ TERMINATION\_PENDING
→ TERMINATED

Linked actions:

ADMIN\_SUSPENSION\_REQUESTED
ENTRY\_MEDIA\_DEACTIVATION\_REQUESTED
RECOVERY\_REQUESTED

After completion:

admin\_access\_status \= ADMIN\_SUSPENDED or ADMIN\_REVOKED
mapping\_status \= DEACTIVATED
physical\_asset\_status \= RECOVERY\_REQUESTED or RECOVERED

12\. No-Use Flow

If usage observation shows no meaningful use, operations may classify merchant as non-use.

Possible flow:

TRIAL\_ACTIVE
→ NOT\_USING
→ FOLLOW\_UP\_REQUIRED

If merchant still does not continue:

NOT\_USING
→ TERMINATION\_PENDING
→ ADMIN\_SUSPENSION\_REQUESTED
→ DEACTIVATION\_REQUESTED
→ RECOVERY\_REQUESTED

No-use signal should not automatically terminate service without policy or human review unless explicit automation is approved.

Core rule:

No-use is a signal.
Termination is a decision.

13\. Admin Suspension Request

Admin suspension request should be created when:

trial expired without conversion
merchant declined
service terminated
merchant account risk exists
store closed
payment or contract issue exists
admin access was granted by mistake

Recommended fields:

admin\_suspension\_request\_id
merchant\_id
store\_id
reason
requested\_by
requested\_at
target\_effective\_at
related\_entry\_plate\_id
related\_entry\_media\_id
related\_trial\_id
trace\_id

14\. Admin Suspension Effect

Admin suspension may disable:

owner web console login
menu editing
request board access
request receiving configuration
usage dashboard
admin settings

Admin suspension should not delete:

merchant record
store record
menu history
request history
mapping history
audit events
support evidence

Core rule:

Suspend access.
Do not erase operational memory.

15\. Mapping Deactivation Link

When service terminates, active Entry Media mapping should usually be deactivated.

Expected action:

merchant\_service\_status \= TERMINATED
→ mapping\_status \= DEACTIVATION\_REQUESTED
→ mapping\_status \= DEACTIVATED

Deactivation reason may be:

TRIAL\_ENDED\_NOT\_CONVERTED
MERCHANT\_DECLINED
SERVICE\_TERMINATED
ADMIN\_ACCESS\_TERMINATED
STORE\_CLOSED

Mapping deactivation must be event-backed.

16\. Physical Recovery Link

After mapping deactivation, physical plate recovery may be required.

Expected action:

mapping\_status \= DEACTIVATED
→ physical\_asset\_status \= RECOVERY\_REQUESTED

However, mapping deactivation and physical recovery are separate.

Core rule:

Deactivate immediately when needed.
Recover physically when operationally possible.

17\. Guest Scan After Admin Suspension

If admin access is suspended but mapping is still active, guest scan may still enter guest flow.

This may be allowed or unsafe depending on policy.

Possible safe policies:

admin\_suspended but merchant still active
→ guest flow may remain active

admin\_suspended because service terminated
→ guest flow must be deactivated

admin\_suspended pending review
→ guest flow may be suspended

Core rule:

Admin suspension reason determines guest flow impact.

18\. Guest Scan After Service Termination

If service is terminated, guest scan should not enter normal request flow.

Guest-facing message:

This guide is currently not available.
Please ask staff.

Korean:

이 안내판은 현재 사용할 수 없습니다.
직원에게 문의해주세요.

Do not expose:

trial ended
merchant declined
admin suspended
payment issue
contract issue

to guests.

19\. Owner Console After Suspension

When admin access is suspended, the merchant user may see limited message if login is attempted.

Possible message:

This store's CatchMenu access is currently unavailable.
Please contact support.

Korean:

현재 이 매장의 CatchMenu 관리자 이용이 제한되어 있습니다.
지원팀에 문의해주세요.

Avoid exposing internal reason if not appropriate.

20\. Reactivation

Merchant may be reactivated after renewal, conversion, or mistake correction.

Possible flow:

ADMIN\_SUSPENDED
→ ADMIN\_REACTIVATION\_REQUESTED
→ ADMIN\_REACTIVATED

Mapping may also be reactivated or recreated.

Allowed only when:

merchant status allows service
store context exists
menu context exists
Entry Media asset is safe
mapping is valid or new mapping is created
actor has authority
reason is recorded

Core rule:

Reactivation requires review.
Do not silently reopen terminated access.

21\. Reactivation With Same Plate

If the same plate remains installed and safe, reactivation may use the same Entry Media.

Required checks:

asset not lost
asset not retired
asset not damaged beyond use
mapping can be safely reactivated or recreated
physical plate text still accurate
admin access approved

Reactivation must create events.

22\. Reactivation With New Plate

If previous plate was recovered, lost, damaged, or reallocated, a new plate may be assigned.

Flow:

old mapping remains historical
new Entry Plate assigned
new mapping created
admin access reactivated

Core rule:

New plate creates new asset relationship.
It does not erase old relationship.

23\. Termination And Reallocation

After service termination:

admin access suspended
mapping deactivated
plate recovered
asset inspected
asset marked REALLOCATION\_READY
new assignment may be created

Reallocation requires compliance with:

00310\_QR\_NFC\_Entry\_Plate\_Assignment\_Recovery\_And\_Reallocation\_Policy.md

24\. Inconsistent State Detection

The system should detect inconsistent combinations.

Examples:

merchant\_service\_status \= TERMINATED
admin\_access\_status \= ADMIN\_ACTIVE

merchant\_service\_status \= TERMINATED
mapping\_status \= ACTIVE

admin\_access\_status \= ADMIN\_SUSPENDED
mapping\_status \= ACTIVE
reason \= SERVICE\_TERMINATED

physical\_asset\_status \= RECOVERED
mapping\_status \= ACTIVE

trial\_status \= TRIAL\_EXPIRED
admin\_access\_status \= ADMIN\_ACTIVE
mapping\_status \= ACTIVE

Detected inconsistency should create support signal or audit review.

25\. Support Signals

Support signals may include:

TRIAL\_EXPIRED\_ADMIN\_STILL\_ACTIVE
TRIAL\_EXPIRED\_MAPPING\_STILL\_ACTIVE
SERVICE\_TERMINATED\_MAPPING\_ACTIVE
SERVICE\_TERMINATED\_ADMIN\_ACTIVE
ADMIN\_SUSPENDED\_GUEST\_FLOW\_ACTIVE
RECOVERED\_PLATE\_MAPPING\_ACTIVE
REACTIVATION\_REVIEW\_REQUIRED
TERMINATION\_INCOMPLETE

Support Signal does not mutate state.

It alerts authorized operators.

26\. Failure Events

Invalid actions must create typed failure events.

Examples:

reactivate admin for terminated merchant without review
activate mapping for suspended merchant
terminate service without deactivation plan
recover plate without closing mapping
delete admin history during suspension

Example failure codes:

WOH.ENTRY\_MEDIA.ADMIN.REACTIVATE.REVIEW\_REQUIRED
WOH.ENTRY\_MEDIA.ADMIN.REACTIVATE.TERMINATED\_MERCHANT\_DENIED
WOH.ENTRY\_MEDIA.MAPPING.ACTIVATE.SERVICE\_TERMINATED\_DENIED
WOH.ENTRY\_MEDIA.SERVICE.TERMINATE.DEACTIVATION\_PLAN\_REQUIRED
WOH.ENTRY\_MEDIA.RECOVERY.MAPPING\_ACTIVE\_CONFLICT
WOH.ENTRY\_MEDIA.ADMIN.SUSPEND.DELETE\_HISTORY\_DENIED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

27\. Audit Events

Recommended audit events:

MERCHANT\_TRIAL\_EXPIRED
MERCHANT\_CONVERTED
MERCHANT\_DECLINED
MERCHANT\_SERVICE\_TERMINATION\_REQUESTED
MERCHANT\_SERVICE\_TERMINATED
ADMIN\_ACCESS\_SUSPENSION\_REQUESTED
ADMIN\_ACCESS\_SUSPENDED
ADMIN\_ACCESS\_REACTIVATION\_REQUESTED
ADMIN\_ACCESS\_REACTIVATED
ENTRY\_MEDIA\_MAPPING\_DEACTIVATION\_REQUESTED\_BY\_TERMINATION
ENTRY\_MEDIA\_MAPPING\_DEACTIVATED\_BY\_TERMINATION
ENTRY\_PLATE\_RECOVERY\_REQUESTED\_BY\_TERMINATION

Audit event fields:

event\_id
merchant\_id
store\_id
entry\_plate\_id
entry\_media\_id
assignment\_id
mapping\_id
previous\_status
new\_status
actor\_type
actor\_id
reason
created\_at
trace\_id

28\. Evidence Packet Relationship

Evidence Packet may include termination/access relationship when relevant.

Possible fields:

trial\_status
merchant\_service\_status
admin\_access\_status
mapping\_status
physical\_asset\_status
termination\_reason
admin\_suspension\_event
mapping\_deactivation\_event
recovery\_request\_event
reactivation\_event
support\_signal\_ref
failure\_event\_ref

Evidence must distinguish:

service ended
admin access suspended
mapping deactivated
plate recovered

Core rule:

Termination evidence must show which axes changed and when.

29\. Minimum MVP Requirement

MVP should support at least:

admin access active/suspended status
trial expired status
service terminated status
mapping deactivation request
mapping deactivated status
recovery requested status
basic inconsistency detection
basic audit event
basic support signal
reactivation requires manual review

MVP may defer:

billing-linked automatic suspension
contract lifecycle automation
advanced renewal workflow
multi-role admin recovery
bulk termination workflow

30\. Relationship To Field SOP

Field SOP may define how the operations team contacts the merchant, schedules recovery, and physically collects Entry Plate.

This policy defines what system states must be linked and recorded.

Core separation:

SOP handles people and field movement.
This policy handles system truth and access safety.

31\. Relationship To Stage 0 Runtime

Stage 0 runtime may use Entry Media only if mapping is active and service state allows guest flow.

Stage 0 should not decide merchant termination.

Correct flow:

merchant service/access state
→ Entry Media mapping availability
→ Stage 0 guest flow enabled or unavailable

Core separation:

Merchant service state controls eligibility.
Entry Media mapping controls resolution.
Stage 0 runs guest experience only when eligible.

32\. Final Rule

Admin access, service termination, Entry Media mapping, and physical recovery must be linked but not collapsed.

Final rule:

Suspend admin access with reason.
Deactivate guest mapping when service ends.
Recover the plate through operations.
Preserve all history.
Detect inconsistent active states.
Reactivate only with review.
Never delete past access, mapping, or asset history.
