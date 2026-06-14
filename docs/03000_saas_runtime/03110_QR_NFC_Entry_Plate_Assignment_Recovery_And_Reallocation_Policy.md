00310 QR NFC Entry Plate Assignment Recovery And Reallocation Policy

Legacy path: $old.

1\. Purpose

This document defines the assignment, recovery, and reallocation policy for CatchMenu QR/NFC Entry Plates.

An Entry Plate is a reusable physical asset that may contain NFC and QR access points.

The same Entry Plate may be assigned to a trial store, test store, production store, or future merchant location over time.

Assignment, recovery, and reallocation must be traceable.

Core purpose:

Assign reusable QR/NFC Entry Plates safely.
Recover unused or terminated assets.
Reallocate assets without erasing history.
Protect store mapping integrity.

Korean purpose:

재사용 가능한 QR/NFC 엔트리 플레이트를 안전하게 배정한다.
사용하지 않거나 종료된 자산을 회수한다.
이력을 지우지 않고 자산을 재배정한다.
매장 매핑 무결성을 보호한다.

2\. Scope

This document covers:

Entry Plate assignment
QR/NFC mapping activation
trial store assignment
test store assignment
production store assignment
admin access relationship
assignment closure
logical deactivation
physical recovery
reallocation readiness
reallocation to another store
lost/damaged handling reference
audit requirement

This document does not define:

field installation SOP
merchant sales talk
physical visit schedule
menu data creation
AI menu intake
guest request state transition
owner console screen design
POS/KDS/payment integration

Field operation is governed separately under the root "sop/" folder.

3\. Core Principle

Entry Plate assignment is not a simple overwrite.

Assignment creates a time-bounded relationship between an Entry Plate and a store or test context.

Core rule:

Assignment creates history.
Recovery closes physical use.
Reallocation creates new history.
No prior history may be erased.

Korean rule:

배정은 이력을 만든다.
회수는 물리 사용을 종료한다.
재배정은 새 이력을 만든다.
과거 이력은 삭제하면 안 된다.

4\. Entry Plate Identity

Each Entry Plate must have a stable identity.

Recommended fields:

entry\_plate\_id
entry\_plate\_code
physical\_asset\_type
nfc\_id
qr\_id
asset\_status
created\_at
registered\_by
current\_assignment\_id
last\_assignment\_id
notes

Entry Plate identity must not change when the plate is reassigned.

Core rule:

The plate identity remains stable.
The assignment changes over time.

5\. Entry Media Identity

An Entry Plate may contain one or more Entry Media identities.

Examples:

NFC\_TAG
QR\_CODE
SHORT\_LINK
ENTRY\_URL

Recommended fields:

entry\_media\_id
entry\_plate\_id
media\_type
media\_value\_ref
media\_status
registered\_at
activated\_at
deactivated\_at

The NFC and QR may resolve to the same store context, but they should still be identifiable separately for diagnostics.

6\. Assignment Definition

Assignment connects an Entry Plate or Entry Media to a store or test context.

Recommended assignment fields:

assignment\_id
entry\_plate\_id
entry\_media\_id
store\_id
test\_context\_id
menu\_context\_id
enabled\_stage
placement
assignment\_status
assignment\_start\_at
assignment\_end\_at
assigned\_by
assignment\_reason
deactivation\_reason
trace\_id

A single Entry Plate must not have two active production store assignments at the same time.

7\. Assignment Targets

Entry Plate may be assigned to:

trial store
test store
production store
merchant pilot
internal demo context
recovered inventory pool

Assignment target must be explicit.

Suggested target types:

TRIAL\_STORE
TEST\_STORE
PRODUCTION\_STORE
INTERNAL\_DEMO
FIELD\_SAMPLE
INVENTORY\_POOL

8\. Store-Level Default Assignment

For Stage 0 POS-less use, Entry Plate assignment is store-level by default.

That means:

store\_id \= required
menu\_context\_id \= required
table\_id \= optional
table\_id \= usually null

Stage 0 trial merchants should not require table-level mapping.

Core rule:

Stage 0 Entry Plate assignment defaults to store-level context.

9\. Placement

Placement should be tracked for physical and support clarity.

Suggested placement values:

OUTSIDE\_AD\_BOARD
INSIDE\_STORE\_GUIDE
COUNTER\_GUIDE
ENTRANCE\_GUIDE
WINDOW\_GUIDE
TABLE\_GUIDE
TEST\_LOCATION
FIELD\_SAMPLE
UNKNOWN

For lightweight trial:

INSIDE\_STORE\_GUIDE

may be sufficient.

Optional later expansion:

OUTSIDE\_AD\_BOARD

10\. Assignment Preconditions

Before assigning an Entry Plate, the system or admin must verify:

Entry Plate exists
Entry Plate is not retired
Entry Plate is not lost
Entry Plate is not actively assigned to another store
NFC/QR media exists or can be generated
target store or test context exists
menu context exists or setup is pending
assignment actor has authority

If any precondition fails, assignment must be denied and logged.

11\. Assignment Status

Suggested assignment statuses:

PENDING
ASSIGNED
ACTIVE
TRIAL\_ACTIVE
SUSPENDED
DEACTIVATION\_REQUESTED
DEACTIVATED
RECOVERY\_REQUESTED
RECOVERED
REALLOCATION\_READY
REALLOCATED
CLOSED

Status must be event-backed.

Status must not be silently changed.

12\. Active Assignment Rule

Only one active assignment should exist for a given Entry Media.

Allowed:

one Entry Plate
→ one active store assignment

Not allowed:

one Entry Plate
→ two active stores

Exception may exist for controlled internal test environments, but it must be explicitly marked as test-only.

Core rule:

No ambiguous active mapping.

13\. Assignment Activation

Assignment activation means the Entry Media can resolve to the target store/menu context.

Activation may create:

ENTRY\_MEDIA\_ASSIGNED
ENTRY\_MEDIA\_ACTIVATED
MAPPING\_ACTIVATED

Activation requires:

valid assignment
active or trial active status
valid store context
valid menu context
enabled guest flow

Guest scans should only resolve through active mapping.

14\. Trial Assignment

Trial assignment supports time-limited merchant testing.

Recommended trial fields:

trial\_start\_at
trial\_end\_at
trial\_status
trial\_package
admin\_access\_enabled
conversion\_status

Trial statuses may include:

TRIAL\_PENDING
TRIAL\_ACTIVE
TRIAL\_EXTENDED
TRIAL\_EXPIRED
CONVERTED
DECLINED
NOT\_USING
RECOVERY\_REQUIRED

Trial expiration must not automatically erase mapping history.

15\. Trial Expiration

When trial expires without conversion, system state may move to:

TRIAL\_EXPIRED

Then follow-up actions may include:

admin access suspension
request receiving disabled
mapping deactivation
physical recovery requested
reallocation preparation after recovery

Trial expiration is not the same as physical recovery.

Core rule:

Trial expired does not mean plate recovered.

16\. Admin Access Relationship

Entry Plate assignment may be associated with merchant admin access.

When assignment is active, the merchant may have access to:

owner web console
menu draft/edit function
request view
basic dashboard

When trial or service ends, access may be suspended.

However:

admin access lifecycle

and

Entry Plate lifecycle

must be tracked separately.

Core rule:

Disable admin access when needed.
Do not delete asset history.

17\. Deactivation Definition

Deactivation means the Entry Media mapping is no longer active for the current store/context.

Deactivation is logical.

It is not the same as physical recovery.

Deactivation may happen before or after physical recovery depending on operational need.

Core rule:

Deactivate mapping logically.
Recover plate physically.
Track both.

18\. Deactivation Reasons

Suggested deactivation reasons:

TRIAL\_ENDED\_NOT\_CONVERTED
MERCHANT\_DECLINED
STORE\_CLOSED
PLATE\_RECOVERED
PLATE\_LOST
PLATE\_DAMAGED
WRONG\_MAPPING\_DETECTED
SECURITY\_CONCERN
REALLOCATION\_REQUIRED
TEST\_ENDED
ADMIN\_TERMINATED

Deactivation reason must be recorded.

19\. Deactivation Requirements

Before deactivation, record:

current assignment
current store
current menu context
current placement
deactivation reason
requested\_by
approved\_by if needed
effective\_at
trace\_id

Deactivation must create an event.

Recommended event:

ENTRY\_MEDIA\_DEACTIVATED

20\. Recovery Definition

Recovery means the physical Entry Plate has been collected, returned, or otherwise confirmed as no longer in use at the merchant location.

Recovery is physical.

Recovery fields may include:

recovery\_requested\_at
recovery\_scheduled\_at
recovered\_at
recovered\_by
recovery\_method
recovery\_condition
recovery\_note

Recovery condition values:

GOOD
MINOR\_WEAR
DAMAGED
NFC\_FAILED
QR\_UNREADABLE
LOST
UNKNOWN

21\. Recovery Requested

When a plate should be recovered, set:

RECOVERY\_REQUESTED

Recovery requested may be triggered by:

trial ended
merchant declined
store closed
admin terminated
asset needs replacement
wrong placement
security concern

Recovery requested does not mean recovered.

Core rule:

Requested is not completed.

22\. Recovered

Set "RECOVERED" only when the physical plate is confirmed returned or collected.

Required evidence may include:

operator confirmation
field note
asset scan
photo if applicable
condition check

Recovered asset may still need inspection before reallocation.

23\. Reallocation Readiness

An Entry Plate may become "REALLOCATION\_READY" only when:

previous active mapping is deactivated
previous assignment is closed or ended
physical plate is recovered
asset condition is acceptable
NFC works or is replaceable
QR works or is replaceable
no unresolved merchant dispute exists
asset is not lost
asset is not retired

Core rule:

Do not reallocate before deactivation and recovery readiness.

24\. Reallocation

Reallocation assigns a recovered or reusable Entry Plate to a new store or test context.

Reallocation must create a new assignment.

It must not overwrite the previous assignment.

Required actions:

close previous assignment period
create new assignment
activate new mapping
record reallocation reason
record actor and timestamp
preserve old mapping history

Core rule:

Reallocation is new assignment.
It is not edit-in-place overwrite.

25\. Reallocation Reason

Suggested reallocation reasons:

RECOVERED\_FROM\_NON\_CONVERTED\_TRIAL
MERCHANT\_DECLINED
FIELD\_SAMPLE\_REUSE
TEST\_CONTEXT\_REUSE
PLATE\_REFURBISHED
INVENTORY\_REBALANCE
REPLACEMENT\_ASSET\_REUSE

Reallocation reason must be recorded.

26\. Mapping History Requirement

Every assignment, deactivation, recovery, and reallocation must preserve mapping history.

Mapping history should answer:

Which store was this plate assigned to?
When did assignment start?
When did assignment end?
Why was it deactivated?
Was it physically recovered?
When was it reallocated?
Who performed the action?

Core rule:

Mapping history is permanent operational memory.

27\. No Hard Delete

Hard deletion is prohibited by default.

Do not hard-delete:

entry\_plate
entry\_media
assignment
deactivation event
recovery event
reallocation event
mapping history

Use:

DEACTIVATED
CLOSED
ARCHIVED
RETIRED

instead.

Core rule:

Deactivate or retire.
Do not erase.

28\. Wrong Mapping Handling

If NFC/QR resolves to the wrong store, it is a high-priority issue.

Immediate actions:

suspend mapping if risk is high
create failure event
create support signal if needed
verify current assignment
verify previous assignment
check reallocation history
correct mapping through authorized process

Do not silently rewrite mapping without event.

Possible failure code:

WOH.ENTRY\_MEDIA.MAPPING.RESOLVE.WRONG\_STORE

29\. Active Reassignment Denial

The system must deny reallocation if the plate is still actively assigned to another store.

Denied case:

ACTIVE assignment exists
→ new assignment attempted
→ deny unless previous assignment is closed or explicitly transferred

Possible failure code:

WOH.ENTRY\_MEDIA.ASSIGNMENT.REALLOCATE.ACTIVE\_ASSIGNMENT\_EXISTS

30\. Lost Asset Handling

If an Entry Plate is lost:

mark LOST
deactivate mapping
block reallocation
preserve last known assignment
create audit event

Lost asset must not be reassigned.

If later found, it must go through verification before any reactivation.

31\. Damaged Asset Handling

If an Entry Plate is damaged:

mark DAMAGED
inspect NFC
inspect QR
check physical text
decide repair, replace, retire, or reuse

A physically misleading plate must not remain active even if NFC/QR still works.

32\. Retired Asset Handling

Retire asset when:

NFC permanently fails
QR cannot be safely reused
physical branding is obsolete
asset is too damaged
security concern exists

Retired asset status:

RETIRED

Retired asset must not be assigned again.

33\. Test Assignment

Entry Plate may be assigned to test context.

Test assignment must be clearly marked.

Suggested flags:

TEST\_ONLY
INTERNAL\_ONLY
NOT\_FOR\_GUEST\_USE

Test media must not accidentally create production requests.

Core rule:

Test assignment must be visibly and logically separated from production assignment.

34\. Production Assignment

Production assignment is active use by a merchant store.

Production assignment requires:

valid store
valid menu context
active admin or merchant agreement if required
approved entry media
non-test status
audit record

Production assignment should not use unverified recovered assets.

35\. Field Sample Assignment

Entry Plate may be used as field sample for sales or demo.

Field sample assignment should be tracked.

Fields may include:

field\_operator
demo\_area
sample\_status
temporary\_store\_context if any
return\_expected\_at

Field sample must not be confused with live production store mapping.

36\. Guest Scan During Suspended State

If guest scans a suspended or deactivated Entry Media, show safe message.

Suggested guest message:

This guide is currently not available.
Please ask staff.

Korean:

이 안내판은 현재 사용할 수 없습니다.
직원에게 문의해주세요.

Do not expose internal asset status to guest.

37\. Guest Scan After Reallocation

After reallocation, guest scan should resolve to the new active store.

Support records must preserve previous mapping.

If guest reports confusion, support should check:

entry\_media\_id
scan time
current assignment
previous assignment
deactivation time
reallocation time
store context at scan time

38\. Audit Events

Recommended audit events:

ENTRY\_PLATE\_REGISTERED
ENTRY\_MEDIA\_REGISTERED
ENTRY\_MEDIA\_ASSIGNED
ENTRY\_MEDIA\_ACTIVATED
ENTRY\_MEDIA\_DEACTIVATION\_REQUESTED
ENTRY\_MEDIA\_DEACTIVATED
ENTRY\_MEDIA\_RECOVERY\_REQUESTED
ENTRY\_MEDIA\_RECOVERED
ENTRY\_MEDIA\_REALLOCATION\_READY
ENTRY\_MEDIA\_REALLOCATED
ENTRY\_MEDIA\_LOST
ENTRY\_MEDIA\_DAMAGED
ENTRY\_MEDIA\_RETIRED

Each event should include:

event\_id
entry\_plate\_id
entry\_media\_id
assignment\_id
previous\_status
new\_status
store\_id if applicable
actor\_type
actor\_id
reason
created\_at
trace\_id

39\. Failure Events

Invalid lifecycle actions must create typed failure events.

Examples:

assign retired plate
assign lost plate
reallocate active plate
activate without store context
activate without menu context
deactivate without reason
recover unknown asset
mark recovered without evidence

Example failure codes:

WOH.ENTRY\_MEDIA.ASSIGNMENT.RETIRED\_ASSET\_DENIED
WOH.ENTRY\_MEDIA.ASSIGNMENT.LOST\_ASSET\_DENIED
WOH.ENTRY\_MEDIA.REALLOCATION.ACTIVE\_ASSIGNMENT\_EXISTS
WOH.ENTRY\_MEDIA.ACTIVATION.STORE\_CONTEXT\_MISSING
WOH.ENTRY\_MEDIA.ACTIVATION.MENU\_CONTEXT\_MISSING
WOH.ENTRY\_MEDIA.DEACTIVATION.REASON\_REQUIRED
WOH.ENTRY\_MEDIA.RECOVERY.UNKNOWN\_ASSET
WOH.ENTRY\_MEDIA.RECOVERY.EVIDENCE\_REQUIRED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

40\. Support Signals

Support signals may be generated for:

WRONG\_STORE\_MAPPING
ACTIVE\_ASSIGNMENT\_CONFLICT
DEACTIVATION\_REQUIRED
RECOVERY\_OVERDUE
LOST\_PLATE\_STILL\_ACTIVE
DAMAGED\_PLATE\_STILL\_ACTIVE
REALLOCATION\_BLOCKED
TEST\_MEDIA\_USED\_IN\_PRODUCTION
GUEST\_SCAN\_ON\_DEACTIVATED\_MEDIA

Support Signal is not mutation authority.

Support should review and escalate through authorized process.

41\. Relationship To Stage 0 Runtime

Stage 0 runtime may use active Entry Media mapping to resolve guest entry.

Stage 0 runtime may ask:

Given entry\_media\_id, what store/menu/stage context should be used?

But Stage 0 runtime must not own:

physical asset status
recovery status
reallocation history
inventory lifecycle

Core separation:

Entry Media Inventory owns asset lifecycle.
Stage 0 resolves active assigned context.

42\. Relationship To Owner Console

Owner Console may show merchant-facing assignment status if needed.

Allowed merchant-facing concepts:

active guide
inactive guide
needs replacement
trial ended

Avoid exposing internal inventory status unnecessarily:

REALLOCATION\_READY
assignment\_id
mapping trace
audit event id

unless support/admin mode is enabled.

43\. Relationship To SOP

The field SOP defines how operations team physically installs, recovers, and prepares plates for reuse.

This policy defines system truth.

Core separation:

SOP tells field team what to do.
This policy tells system what must be recorded.

44\. Minimum MVP Requirement

MVP should support at least:

entry\_plate registration
QR/NFC identity registration
store-level assignment
active/inactive status
trial assignment
deactivation
recovery requested
recovered
reallocation ready
reallocated
mapping history
basic audit event

MVP may defer:

advanced warehouse inventory
batch asset scanning
automated field route planning
complex device health checks
multi-region logistics

45\. Final Rule

Entry Plate assignment, recovery, and reallocation must be safe, traceable, and reversible from an operational evidence standpoint.

Final rule:

Assign with scope.
Activate with context.
Deactivate before reuse.
Recover physically.
Reallocate as new history.
Never overwrite prior assignment.
Never delete mapping history.
