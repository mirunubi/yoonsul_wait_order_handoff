# 003130_Policy_Entry_Media_Status_Lifecycle_And_Audit.md

## Purpose

This document defines the SaaS runtime or entry media inventory topic indicated by its filename and preserves its governed documentation role within `docs/003000_saas_runtime/`.

Legacy path: $old.

1\. Purpose

This document defines the status lifecycle and audit policy for CatchMenu Entry Media and Entry Plates.

Entry Media and Entry Plates are reusable assets.

They may move through inventory, assignment, activation, trial, suspension, recovery, reallocation, damage, loss, and retirement states.

Every important status change must be traceable.

Core purpose:

Define Entry Media lifecycle states.
Prevent unsafe status changes.
Separate physical asset state from logical mapping state.
Create audit events for every important lifecycle change.

Korean purpose:

Entry Media 생명주기 상태를 정의한다.
위험한 상태 변경을 막는다.
물리 자산 상태와 논리 매핑 상태를 분리한다.
중요한 생명주기 변경마다 감사 이벤트를 남긴다.

2\. Scope

This document covers:

Entry Plate status
Entry Media status
assignment status
mapping status reference
physical recovery status
trial status
damage/loss/retirement status
status transition guard
audit events
failure events
support signals
minimum MVP lifecycle

This document does not define:

field recovery SOP
merchant sales procedure
menu intake
AI menu generation
Stage 0 request lifecycle
POS/KDS/payment lifecycle
physical manufacturing process

Related documents:

00300\_Entry\_Media\_Inventory\_Readme.md
00310\_QR\_NFC\_Entry\_Plate\_Assignment\_Recovery\_And\_Reallocation\_Policy.md
00320\_Entry\_Media\_Mapping\_History\_And\_Deactivation\_Policy.md

3\. Core Principle

Entry Media lifecycle must be stateful, event-backed, and auditable.

Core rule:

Status is operational truth.
Status changes require event history.

Korean rule:

상태는 운영상 진실이다.
상태 변경에는 이벤트 이력이 필요하다.

A status must not be changed silently.

4\. Status Axes

Entry Media Inventory has multiple status axes.

They must not be collapsed into one field.

Recommended axes:

physical\_asset\_status
entry\_media\_status
assignment\_status
mapping\_status
trial\_status
admin\_access\_status
recovery\_status
audit\_status

Reason:

A plate can be physically unrecovered but logically deactivated.
A mapping can be inactive while the admin account is still pending suspension.
A trial can expire before the plate is recovered.
A recovered plate can be unusable because it is damaged.

Core rule:

Separate physical state, logical mapping state, assignment state, and access state.

5\. Physical Asset Status

Physical asset status describes the actual Entry Plate condition and inventory location.

Suggested statuses:

IN\_STOCK
FIELD\_SAMPLE
ASSIGNED\_TO\_STORE
INSTALLED
RECOVERY\_REQUESTED
RECOVERY\_SCHEDULED
RECOVERED
INSPECTION\_REQUIRED
REALLOCATION\_READY
DAMAGED
LOST
RETIRED

Meaning:

IN\_STOCK
\= plate exists in inventory and is not assigned

FIELD\_SAMPLE
\= plate is used for sales/demo

ASSIGNED\_TO\_STORE
\= plate is assigned to a store but may not yet be installed

INSTALLED
\= plate is physically placed at store

RECOVERY\_REQUESTED
\= recovery is required but not complete

RECOVERY\_SCHEDULED
\= recovery visit or pickup is scheduled

RECOVERED
\= plate has been physically collected

INSPECTION\_REQUIRED
\= recovered plate needs condition check

REALLOCATION\_READY
\= plate can be assigned again

DAMAGED
\= physical plate or media is damaged

LOST
\= plate cannot be located

RETIRED
\= plate must not be used again

6\. Entry Media Status

Entry Media status describes QR/NFC logical usability.

Suggested statuses:

REGISTERED
PENDING\_ACTIVATION
ACTIVE
SUSPENDED
DEACTIVATION\_REQUESTED
DEACTIVATED
REPLACED
EXPIRED
INVALIDATED
RETIRED

Meaning:

REGISTERED
\= QR/NFC identity exists

PENDING\_ACTIVATION
\= prepared but not active

ACTIVE
\= can resolve to an active mapping

SUSPENDED
\= temporarily blocked

DEACTIVATION\_REQUESTED
\= deactivation requested

DEACTIVATED
\= no longer active

REPLACED
\= replaced by another media or mapping

EXPIRED
\= time-limited use ended

INVALIDATED
\= unsafe or incorrect media state preserved for audit

RETIRED
\= media must not be used again

7\. Assignment Status

Assignment status describes the relationship between asset and store/test context.

Suggested statuses:

ASSIGNMENT\_DRAFT
ASSIGNED
ASSIGNMENT\_ACTIVE
TRIAL\_ACTIVE
SUSPENDED
ASSIGNMENT\_END\_REQUESTED
ASSIGNMENT\_ENDED
REALLOCATION\_READY
REALLOCATED
CLOSED

Assignment status must preserve assignment periods.

Core rule:

Assignment ending closes a relationship.
It does not delete the relationship.

8\. Mapping Status Reference

Mapping status is defined in:

00320\_Entry\_Media\_Mapping\_History\_And\_Deactivation\_Policy.md

Common mapping statuses:

DRAFT
PENDING\_ACTIVATION
ACTIVE
SUSPENDED
DEACTIVATION\_REQUESTED
DEACTIVATED
REPLACED
EXPIRED
ARCHIVED
INVALIDATED

Mapping status should not be confused with physical asset status.

Example:

physical\_asset\_status \= RECOVERY\_REQUESTED
mapping\_status \= DEACTIVATED

means:

The plate is still in the field, but the QR/NFC no longer resolves to the old store.

9\. Trial Status

Trial status describes merchant trial lifecycle.

Suggested statuses:

TRIAL\_PENDING
TRIAL\_ACTIVE
TRIAL\_EXTENDED
TRIAL\_EXPIRED
CONVERTED
DECLINED
NOT\_USING
UNREACHABLE
RECOVERY\_REQUIRED

Trial status must not automatically overwrite asset status.

Example:

trial\_status \= TRIAL\_EXPIRED
physical\_asset\_status \= INSTALLED
mapping\_status \= ACTIVE

is possible temporarily, but it should trigger follow-up action.

10\. Admin Access Status

Admin access status is separate from asset status.

Suggested statuses:

ADMIN\_PENDING
ADMIN\_ACTIVE
ADMIN\_SUSPENSION\_REQUESTED
ADMIN\_SUSPENDED
ADMIN\_REVOKED

Core rule:

Admin access may be disabled.
Asset history must remain.

When merchant trial ends without conversion, expected relationship may be:

trial\_status \= TRIAL\_EXPIRED
admin\_access\_status \= ADMIN\_SUSPENSION\_REQUESTED
mapping\_status \= DEACTIVATION\_REQUESTED
physical\_asset\_status \= RECOVERY\_REQUESTED

11\. Recovery Status

Recovery status describes field recovery progress.

Suggested statuses:

RECOVERY\_NOT\_REQUIRED
RECOVERY\_REQUIRED
RECOVERY\_REQUESTED
RECOVERY\_SCHEDULED
RECOVERY\_ATTEMPTED
RECOVERED
RECOVERY\_FAILED
UNRECOVERABLE

Recovery status must be distinct from deactivation.

Core rule:

Deactivated does not mean recovered.
Recovered does not automatically mean reallocation-ready.

12\. Audit Status

Audit status may be used when lifecycle consistency must be checked.

Suggested statuses:

AUDIT\_NOT\_REQUIRED
AUDIT\_PENDING
AUDIT\_PASSED
AUDIT\_FAILED
AUDIT\_REVIEW\_REQUIRED

Audit may be required when:

wrong mapping is suspected
multiple active mappings were detected
lost plate scanned after deactivation
reallocation occurred
mapping history conflict exists
support dispute exists

13\. Lifecycle Transition Principle

Lifecycle transitions must be guarded.

A status transition should verify:

current status
target status
actor authority
asset condition
mapping state
assignment state
trial state
recovery state
reason
timestamp
trace id

If transition is invalid, reject and create failure event.

Core rule:

No lifecycle transition without reason and trace.

14\. Normal Trial Lifecycle

A normal trial lifecycle may look like:

IN\_STOCK
→ ASSIGNED\_TO\_STORE
→ INSTALLED
→ TRIAL\_ACTIVE
→ CONVERTED

If merchant converts:

mapping\_status \= ACTIVE
admin\_access\_status \= ADMIN\_ACTIVE
physical\_asset\_status \= INSTALLED

The plate remains at the store.

15\. Non-Conversion Lifecycle

If merchant does not convert:

TRIAL\_ACTIVE
→ TRIAL\_EXPIRED
→ ADMIN\_SUSPENSION\_REQUESTED
→ DEACTIVATION\_REQUESTED
→ RECOVERY\_REQUESTED
→ RECOVERED
→ INSPECTION\_REQUIRED
→ REALLOCATION\_READY

Core rule:

Trial end should lead to controlled suspension, deactivation, and recovery.

16\. Reallocation Lifecycle

A recovered plate may be reallocated.

Expected lifecycle:

RECOVERED
→ INSPECTION\_REQUIRED
→ REALLOCATION\_READY
→ ASSIGNED\_TO\_STORE
→ INSTALLED

Reallocation must create new assignment and mapping history.

Core rule:

Reallocation starts a new assignment period.
It must not reopen or overwrite the old assignment.

17\. Lost Asset Lifecycle

If asset is lost:

INSTALLED
or
RECOVERY\_REQUESTED
→ LOST

Required actions:

deactivate active mapping
block reallocation
create audit event
create support signal if still scanned
preserve last known assignment

Lost asset cannot become "REALLOCATION\_READY" without verification.

If found later:

LOST
→ INSPECTION\_REQUIRED

Only after verification may it return to usable inventory.

18\. Damaged Asset Lifecycle

If asset is damaged:

INSTALLED
or
RECOVERED
→ DAMAGED

Then:

DAMAGED
→ INSPECTION\_REQUIRED
→ REALLOCATION\_READY

or:

DAMAGED
→ RETIRED

depending on condition.

Damage check should include:

NFC scan test
QR scan test
physical readability
brand/message accuracy
adhesive or stand condition
safety for public placement

19\. Retired Asset Lifecycle

Retired is terminal by default.

Allowed transition:

DAMAGED
→ RETIRED

or:

LOST
→ RETIRED

or:

INVALIDATED
→ RETIRED

Retired asset must not be reassigned.

Core rule:

RETIRED means no future field use.

20\. Suspended State

Suspension is temporary.

Use "SUSPENDED" when:

trial payment issue exists
wrong mapping is suspected
merchant admin access is paused
security review is pending
store is temporarily not using service

Suspension should not erase assignment.

Suspension may later become:

ACTIVE

or:

DEACTIVATED

depending on review result.

21\. Invalid Status Transitions

Examples of invalid transitions:

LOST → ACTIVE
without verification

RETIRED → ACTIVE

DAMAGED → REALLOCATION\_READY
without inspection

ACTIVE → REALLOCATED
without deactivation

TRIAL\_EXPIRED → CONVERTED
without merchant decision record

RECOVERY\_REQUESTED → REALLOCATION\_READY
without RECOVERED

DEACTIVATED → ACTIVE
without reactivation event

Invalid transitions must be denied and logged.

22\. Status Change Event Requirement

Every important status change must create an event.

Recommended event fields:

event\_id
entity\_type
entity\_id
previous\_status
new\_status
status\_axis
actor\_type
actor\_id
reason
created\_at
trace\_id
related\_store\_id
related\_assignment\_id
related\_mapping\_id

Status axes:

PHYSICAL\_ASSET
ENTRY\_MEDIA
ASSIGNMENT
MAPPING
TRIAL
ADMIN\_ACCESS
RECOVERY
AUDIT

23\. Audit Event Types

Recommended audit events:

ENTRY\_PLATE\_REGISTERED
ENTRY\_MEDIA\_REGISTERED
ENTRY\_PLATE\_ASSIGNED
ENTRY\_MEDIA\_ASSIGNED
ENTRY\_MEDIA\_ACTIVATED
ENTRY\_MEDIA\_SUSPENDED
ENTRY\_MEDIA\_REACTIVATED
ENTRY\_MEDIA\_DEACTIVATION\_REQUESTED
ENTRY\_MEDIA\_DEACTIVATED
ENTRY\_PLATE\_INSTALLED
ENTRY\_PLATE\_RECOVERY\_REQUESTED
ENTRY\_PLATE\_RECOVERY\_SCHEDULED
ENTRY\_PLATE\_RECOVERED
ENTRY\_PLATE\_INSPECTION\_REQUIRED
ENTRY\_PLATE\_REALLOCATION\_READY
ENTRY\_PLATE\_REALLOCATED
ENTRY\_PLATE\_LOST
ENTRY\_PLATE\_DAMAGED
ENTRY\_PLATE\_RETIRED
ADMIN\_ACCESS\_SUSPENSION\_REQUESTED
ADMIN\_ACCESS\_SUSPENDED

24\. Reason Requirement

Every sensitive status change must include reason.

Reason examples:

TRIAL\_STARTED
TRIAL\_ENDED\_NOT\_CONVERTED
MERCHANT\_CONVERTED
MERCHANT\_DECLINED
NOT\_USING
STORE\_CLOSED
PLATE\_RECOVERED
PLATE\_LOST
PLATE\_DAMAGED
WRONG\_MAPPING\_DETECTED
SECURITY\_CONCERN
REALLOCATION\_REQUIRED
TEST\_ENDED
ADMIN\_TERMINATED

Core rule:

No reason, no sensitive transition.

25\. Actor Authority

Only authorized actors may change lifecycle status.

Suggested actor types:

system\_admin
inventory\_admin
operations\_manager
field\_operator
support\_operator
automated\_policy\_job
audit\_reviewer

Authority examples:

field\_operator
\= may request recovery or record recovered if permitted

inventory\_admin
\= may mark reallocation ready

system\_admin
\= may deactivate mapping

support\_operator
\= may flag review, not reassign directly

automated\_policy\_job
\= may mark trial expired or create recovery request if policy allows

Core rule:

No actor may change a lifecycle state outside its authority.

26\. Automated Policy Jobs

Automated jobs may create lifecycle changes when policy allows.

Examples:

TRIAL\_ACTIVE \+ trial\_end\_date passed
→ TRIAL\_EXPIRED

TRIAL\_EXPIRED \+ no conversion
→ RECOVERY\_REQUIRED

RECOVERY\_REQUIRED \+ overdue
→ RECOVERY\_OVERDUE signal

DEACTIVATION\_REQUESTED \+ approved
→ DEACTIVATED

Automated jobs must create events.

Automated jobs must not delete history.

27\. Support Signals

Support signals may be generated for lifecycle anomalies.

Examples:

TRIAL\_EXPIRED\_BUT\_MAPPING\_ACTIVE
ADMIN\_SUSPENDED\_BUT\_MAPPING\_ACTIVE
RECOVERY\_REQUESTED\_BUT\_NOT\_RECOVERED
LOST\_PLATE\_STILL\_ACTIVE
DAMAGED\_PLATE\_STILL\_ACTIVE
RETIRED\_PLATE\_ASSIGNMENT\_ATTEMPTED
MULTIPLE\_ACTIVE\_STATUS\_CONFLICT
REALLOCATION\_READY\_WITHOUT\_RECOVERY

Support Signal is not mutation authority.

It alerts for review.

28\. Failure Events

Invalid lifecycle actions must create typed failure events.

Example failure codes:

WOH.ENTRY\_MEDIA.STATUS.TRANSITION.INVALID
WOH.ENTRY\_MEDIA.STATUS.TRANSITION.UNAUTHORIZED\_ACTOR
WOH.ENTRY\_MEDIA.STATUS.TRANSITION.REASON\_REQUIRED
WOH.ENTRY\_MEDIA.STATUS.TRANSITION.RETIRED\_ASSET\_DENIED
WOH.ENTRY\_MEDIA.STATUS.TRANSITION.LOST\_ASSET\_REACTIVATION\_DENIED
WOH.ENTRY\_MEDIA.STATUS.TRANSITION.REALLOCATION\_WITHOUT\_RECOVERY\_DENIED
WOH.ENTRY\_MEDIA.STATUS.TRANSITION.ACTIVE\_REASSIGNMENT\_DENIED
WOH.ENTRY\_MEDIA.STATUS.TRANSITION.INSPECTION\_REQUIRED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

29\. Lifecycle Consistency Checks

The system should detect inconsistent lifecycle combinations.

Examples:

physical\_asset\_status \= LOST
mapping\_status \= ACTIVE

physical\_asset\_status \= RETIRED
assignment\_status \= ACTIVE

trial\_status \= TRIAL\_EXPIRED
admin\_access\_status \= ADMIN\_ACTIVE
mapping\_status \= ACTIVE

recovery\_status \= RECOVERED
physical\_asset\_status \= INSTALLED

assignment\_status \= REALLOCATED
previous\_mapping\_status \= ACTIVE

Detected inconsistencies should create audit review or support signal.

30\. Scan-Time Audit Relationship

If an Entry Media is scanned, scan resolution should be consistent with lifecycle state.

If scan occurs while media is:

DEACTIVATED
SUSPENDED
LOST
RETIRED

the system should not silently resolve to an unsafe guest flow.

Possible handling:

show inactive message
create scan failure event
create support signal if repeated
route to safe fallback

31\. Audit Trail Retention

Audit trail must be preserved.

Do not hard-delete:

status change event
assignment event
mapping event
deactivation event
recovery event
reallocation event
lost/damaged/retired event
failure event
support signal

Core rule:

Lifecycle memory must remain available for support and audit.

32\. Correction Policy

If a lifecycle status was set incorrectly, correct it with a correction event.

Do not silently edit history.

Correction event should include:

incorrect\_event\_id
corrected\_status
correction\_reason
corrected\_by
corrected\_at
trace\_id

Core rule:

Correct the record.
Do not pretend the mistake never happened.

33\. Evidence Packet Relationship

Entry Media lifecycle evidence may be included in an Evidence Packet when relevant.

Evidence may include:

entry\_plate\_id
entry\_media\_id
current physical status
current mapping status
assignment history
status transition timeline
deactivation event
recovery event
reallocation event
lost/damaged event
audit review event
failure event
support signal

Evidence must distinguish:

current status
status at scan time
status at request time
status after later correction

34\. Minimum MVP Requirement

MVP should support at least:

Entry Plate registration
Entry Media registration
IN\_STOCK
ASSIGNED\_TO\_STORE
INSTALLED
ACTIVE
TRIAL\_ACTIVE
TRIAL\_EXPIRED
DEACTIVATION\_REQUESTED
DEACTIVATED
RECOVERY\_REQUESTED
RECOVERED
REALLOCATION\_READY
REALLOCATED
LOST
DAMAGED
RETIRED
basic status change event
basic audit log
invalid transition failure event

MVP may defer:

advanced warehouse location tracking
bulk scan inventory audit
automated recovery route planning
multi-region inventory transfer
asset depreciation accounting

35\. Relationship To Field SOP

Field SOP may define how operations staff physically installs, recovers, inspects, and prepares plates.

This policy defines what the system must record.

Core separation:

SOP describes field action.
Lifecycle policy records system truth.

36\. Relationship To Mapping History

Mapping history is defined in:

00320\_Entry\_Media\_Mapping\_History\_And\_Deactivation\_Policy.md

Lifecycle status and mapping status must remain consistent but separate.

Core separation:

Asset lifecycle says what the plate is.
Mapping history says where the QR/NFC resolves.

37\. Final Rule

Entry Media status lifecycle must protect reusable assets from operational confusion.

Final rule:

Separate status axes.
Guard every transition.
Require reason.
Record event.
Detect inconsistent states.
Preserve audit history.
Do not reactivate lost or retired assets without review.
Do not reallocate without recovery readiness.
