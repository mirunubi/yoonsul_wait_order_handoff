# 04130_Policy_POS_KDS_Inventory_Availability_Sync

1\. Purpose

This document defines POS, KDS, and Inventory Availability Sync policy for CatchMenu / Wait Order Handoff.

Menu availability may be updated manually by store staff, referenced from POS sold-out status, signaled by kitchen/KDS conditions, or later derived from inventory or ingredient stock.

However, these sources may disagree, update at different speeds, or have different reliability.

CatchMenu must not blindly trust every external availability signal.

CatchMenu must define source priority, capability verification, timestamp handling, conflict detection, conservative blocking, review requirement, audit, and support signals before using POS/KDS/Inventory availability to control preorder, pickup, POS handoff, or KDS handoff.

Core purpose:

Define POS availability sync.
Define KDS/kitchen availability signal.
Define inventory availability reference.
Define availability source priority.
Define source reliability.
Define sync timestamp and staleness.
Define availability conflict handling.
Define conservative blocking rule.
Define review requirement.
Prevent stale or conflicting availability from creating false commitments.

Korean purpose:

POS availability sync를 정의한다.
KDS/주방 availability signal을 정의한다.
inventory availability reference를 정의한다.
availability source priority를 정의한다.
source reliability를 정의한다.
sync timestamp와 staleness를 정의한다.
availability conflict 처리를 정의한다.
보수적 차단 규칙을 정의한다.
review requirement를 정의한다.
오래되었거나 충돌하는 availability가 잘못된 약속을 만드는 것을 방지한다.

2\. Scope

This document covers:

POS sold-out reference
POS menu active/inactive reference
POS stock count reference if supported
KDS kitchen availability signal
KDS station pause
KDS prep capacity signal
inventory availability reference
ingredient stock reference later
source priority
source reliability
sync timestamp
stale data
conflict handling
availability sync audit
availability sync support signal
availability sync failure event

This document does not define:

full POS adapter implementation
full KDS implementation
full inventory ledger
warehouse management
supplier ordering
recipe BOM costing
automatic food safety certification
accounting inventory valuation

Related documents:

04100\_Menu\_Availability\_Soldout\_Runtime\_Readme.md
04110\_Menu\_Availability\_Soldout\_And\_Preorder\_Blocking\_Policy.md
04120\_Limited\_Quantity\_Menu\_And\_Waiting\_Preorder\_Control\_Policy.md
03500\_External\_POS\_Integration\_Runtime\_Readme.md
03520\_POS\_Provider\_Adapter\_Contract\_And\_Capability\_Declaration\_Policy.md
04000\_KDS\_Integration\_And\_Kitchen\_Continuity\_Readme.md
03930\_AI\_Menu\_Intake\_Correction\_And\_Live\_Menu\_Stabilization\_Policy.md

3\. Core Principle

External availability facts can inform CatchMenu, but must not be blindly trusted.

Core rule:

Availability source must be capability-verified, timestamped, and conflict-checked before it controls commitment.

Korean rule:

availability source는 capability 검증, timestamp, conflict check 이후에만 commitment 제어에 사용한다.

4\. Availability Source Types

Availability may come from multiple sources.

Suggested source types:

MANUAL\_STORE\_OVERRIDE
MANUAL\_HQ\_OR\_SUPPORT\_OVERRIDE
POS\_SOLD\_OUT\_REFERENCE
POS\_MENU\_ACTIVE\_REFERENCE
POS\_STOCK\_COUNT\_REFERENCE
KDS\_KITCHEN\_AVAILABILITY\_SIGNAL
KDS\_STATION\_STATUS
INVENTORY\_STOCK\_REFERENCE
INGREDIENT\_AVAILABILITY\_REFERENCE
SCHEDULED\_AVAILABILITY\_RULE
DEFAULT\_MENU\_STATE
UNKNOWN

Core rule:

Every availability value must have a source.

5\. Source Priority

When sources disagree, CatchMenu must apply source priority.

Suggested priority:

1\. Food safety or emergency block
2\. Authorized manual store/HQ block
3\. KDS/kitchen unavailable signal
4\. POS sold-out or inactive reference
5\. Inventory/ingredient unavailable reference
6\. Scheduled availability rule
7\. Manual available override with review
8\. Default menu availability
9\. Unknown

Core rule:

Higher-risk blocking source should override ordinary available source.

6\. Source Reliability

Every source should have reliability level.

Suggested levels:

HIGH
MEDIUM
LOW
UNKNOWN

Example interpretation:

manual store block during service
\= HIGH for blocking

KDS kitchen unavailable
\= HIGH for kitchen execution

POS sold-out reference
\= MEDIUM/HIGH if provider capability is verified

inventory estimate not real-time
\= LOW/MEDIUM

default menu state
\= LOW for committed preorder

UNKNOWN
\= UNKNOWN

Core rule:

Low reliability source must not create high-confidence commitment.

7\. Capability Verification

External availability sync requires capability verification.

POS capability examples:

SOLD\_OUT\_SYNC
ITEM\_ACTIVE\_SYNC
STOCK\_COUNT\_SYNC
MENU\_VERSION\_REFERENCE
CALLBACK\_SUPPORTED
TIMESTAMP\_SUPPORTED

KDS capability examples:

KITCHEN\_AVAILABILITY\_SIGNAL
STATION\_PAUSE\_SIGNAL
PREP\_CAPACITY\_SIGNAL
DELAY\_SIGNAL
READY\_STATUS

Inventory capability examples:

ITEM\_STOCK\_REFERENCE
INGREDIENT\_STOCK\_REFERENCE
BATCH\_AVAILABILITY
LIMITED\_QUANTITY\_REFERENCE
EXPIRY\_BASED\_BLOCK

Core rule:

No verified capability, no automatic availability sync.

8\. Timestamp Requirement

Availability source must include timestamp where possible.

Timestamp fields:

source\_updated\_at
received\_at
applied\_at
expires\_at optional
last\_verified\_at optional

Core rule:

Availability without timestamp becomes stale-risk data.

9\. Staleness

Availability data becomes stale after a defined threshold.

Staleness threshold may depend on:

source type
menu type
limited quantity risk
store peak time
provider sync frequency
merchant policy

Suggested examples:

manual sold-out
\= valid until restored or expiry

POS sold-out reference
\= valid until next sync or provider update

stock count reference
\= stale quickly during peak

default menu state
\= not enough for limited preorder commitment

Core rule:

Stale availability should not support high-commitment flows.

10\. POS Availability Sync

POS may provide availability reference if provider supports it.

POS availability data may include:

item active/inactive
sold-out flag
stock count
menu version
price/menu change
option availability
modifier availability

CatchMenu must record:

provider\_id
pos\_binding\_id
provider\_item\_id
source status
timestamp
capability version
mapping version

Core rule:

POS availability sync must be mapped to CatchMenu menu item before use.

11\. POS Sold-Out Reference

POS sold-out reference may block CatchMenu committed flows.

When POS says sold out:

mark POS\_SOLD\_OUT\_REFERENCE
block preorder by default
block POS handoff
block KDS handoff unless manual override
show review/sold-out label depending policy

Core rule:

POS sold-out reference is strong blocking evidence when capability and mapping are verified.

12\. POS Stock Count Reference

POS stock count may be available for some providers.

Stock count risks:

not real-time
delayed sync
includes POS-only sales but not manual holds
does not include kitchen waste
does not include reservations
provider-specific meaning unclear

Core rule:

POS stock count must not be treated as exact unless provider meaning is verified.

13\. KDS Kitchen Availability Signal

KDS/kitchen may signal availability or capacity.

KDS signals may include:

item unavailable
station paused
prep delayed
prep capacity full
ingredient not ready
kitchen overloaded
ready status

KDS signal affects:

preorder permission
KDS handoff eligibility
guest expectation
support signal
merchant success review

Core rule:

KDS kitchen unavailable signal should block kitchen execution commitment.

14\. KDS Station Status

Kitchen station status may affect specific items.

Examples:

noodle station paused
grill station overloaded
rice prep delayed
beverage station unavailable
packaging station delayed

Core rule:

Station-specific unavailability should block affected items, not necessarily whole menu.

15\. Inventory Availability Reference

Inventory reference may be added later.

Inventory may provide:

ingredient stock
recipe availability
batch count
expiry-based block
prep availability
limited quantity remaining

Inventory reference should include:

source
item or ingredient
quantity or availability
timestamp
reliability
scope

Core rule:

Inventory reference must be connected to menu item through recipe or mapping before blocking.

16\. Ingredient-Level Availability

Ingredient availability may affect many items.

Example:

egg unavailable
→ block items requiring egg or mark manual confirmation required

rice batch delayed
→ block rice-based preorder temporarily

chicken unavailable
→ block chicken menu group

Core rule:

Ingredient-level block must map to affected menu items.

17\. Scheduled Availability Rule

Some availability is schedule-based.

Examples:

breakfast only
lunch only
weekday only
seasonal
limited lunch batch
preorder disabled during peak
pickup disabled after 18:00

Core rule:

Scheduled rule is valid only within defined time window.

18\. Availability Sync Conflict

Conflict occurs when availability sources disagree.

Examples:

store says sold out, POS says available
POS says sold out, inventory says available
KDS says station paused, menu says available
stock count says 2 left, holds say 3 reserved
scheduled rule allows, kitchen blocks

Core rule:

Availability conflict must prefer safer operation until reviewed.

19\. Conflict Resolution

Conflict resolution should record:

conflicting sources
timestamps
reliability
affected item
affected flow
temporary decision
reviewer
final decision
audit event

Possible temporary decisions:

block committed flows
manual confirmation required
request-only mode
show sold-out
show store confirmation required

Core rule:

Conflict resolution must be evidence-backed.

20\. Conservative Blocking

Conservative blocking should apply when risk is high.

High-risk flows:

prepaid pickup
reservation/group order
waiting preorder
automatic POS handoff
automatic KDS handoff
limited quantity item
critical kitchen capacity item

Core rule:

When availability is uncertain, block high-commitment automation first.

21\. Manual Override With External Source

Manual override may conflict with external source.

Examples:

store overrides POS sold-out to available
store marks sold-out despite POS available
support blocks item despite POS available

Manual override should require:

authority
reason
expiry/review time
affected flow
audit event
support signal if conflict persists

Core rule:

Manual override can win, but must be scoped and auditable.

22\. Sync Frequency

Sync frequency should depend on source and risk.

Examples:

POS menu active state
\= periodic or callback-based

sold-out state
\= near real-time if supported

stock count
\= frequent during peak if reliable

KDS station pause
\= immediate if possible

inventory ingredient stock
\= batch or event-based

Core rule:

Sync frequency must match operational risk.

23\. Sync Failure

Sync failure means availability source could not be updated.

Sync failure handling:

mark source stale
emit support signal
fallback to manual store state if available
block high-risk committed flows if no reliable source
record failure event

Core rule:

Sync failure should not silently leave stale availability as trusted.

24\. Availability Snapshot

Committed flows should record availability snapshot.

Snapshot may include:

menu\_item\_id
availability\_state
source
timestamp
reliability
conflict\_status
quantity/hold reference if applicable
flow\_type
decision

Core rule:

Availability decision must be explainable at request time.

25\. Guest Impact

Guest-facing behavior should reflect availability sync safely.

If uncertain:

show store confirmation required
disable preorder
allow request-only
hide item if store policy
show limited/sold-out label

Core rule:

Guest should not see false certainty from uncertain sync.

26\. Store Impact

Store-facing UI should expose source and conflict.

Store may see:

current availability
source
last updated
conflict warning
manual override option
affected flow
support signal

Core rule:

Store needs source visibility to trust availability control.

27\. POS Handoff Impact

Before POS handoff:

check CatchMenu availability state
check POS sold-out reference if capability exists
check quantity/hold state if limited
check conflict status
block if unsafe

Core rule:

POS handoff must not bypass availability conflict.

28\. KDS Handoff Impact

Before KDS handoff:

check kitchen availability signal
check station status
check item availability
check quantity state
block if kitchen unavailable

Core rule:

KDS handoff must respect kitchen availability.

29\. Audit Events

Recommended audit events:

AVAILABILITY\_SOURCE\_SYNCED
POS\_AVAILABILITY\_SYNC\_RECEIVED
POS\_SOLD\_OUT\_REFERENCE\_APPLIED
POS\_STOCK\_REFERENCE\_RECEIVED
KDS\_AVAILABILITY\_SIGNAL\_RECEIVED
KDS\_STATION\_STATUS\_RECEIVED
INVENTORY\_AVAILABILITY\_REFERENCE\_RECEIVED
AVAILABILITY\_SOURCE\_MARKED\_STALE
AVAILABILITY\_SYNC\_FAILED
AVAILABILITY\_CONFLICT\_DETECTED
AVAILABILITY\_CONFLICT\_RESOLVED
AVAILABILITY\_CONSERVATIVE\_BLOCK\_APPLIED
AVAILABILITY\_MANUAL\_OVERRIDE\_APPLIED
AVAILABILITY\_SNAPSHOT\_CREATED

Minimum audit fields:

event\_id
merchant\_account\_id
merchant\_store\_id
menu\_item\_id optional
source\_type
source\_id
actor\_type
actor\_id optional
action
previous\_value
new\_value
source\_timestamp
received\_at
created\_at
trace\_id

30\. Failure Events

Example failure codes:

WOH.AVAILABILITY\_SYNC.SOURCE\_UNVERIFIED
WOH.AVAILABILITY\_SYNC.SOURCE\_STALE
WOH.AVAILABILITY\_SYNC.POS\_MAPPING\_REQUIRED
WOH.AVAILABILITY\_SYNC.POS\_SOLD\_OUT\_APPLIED
WOH.AVAILABILITY\_SYNC.KDS\_UNAVAILABLE\_APPLIED
WOH.AVAILABILITY\_SYNC.INVENTORY\_REFERENCE\_UNMAPPED
WOH.AVAILABILITY\_SYNC.CONFLICT\_REVIEW\_REQUIRED
WOH.AVAILABILITY\_SYNC.SYNC\_FAILED
WOH.AVAILABILITY\_SYNC.CONSERVATIVE\_BLOCK\_APPLIED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

31\. Support Signals

Support signals may include:

POS\_AVAILABILITY\_SYNC\_FAILED
POS\_AVAILABILITY\_SOURCE\_STALE
POS\_SOLD\_OUT\_CONFLICT
KDS\_AVAILABILITY\_CONFLICT
KDS\_STATION\_PAUSED
INVENTORY\_AVAILABILITY\_UNMAPPED
AVAILABILITY\_SOURCE\_UNVERIFIED
AVAILABILITY\_CONFLICT\_REVIEW\_REQUIRED
AVAILABILITY\_SYNC\_CONSERVATIVE\_BLOCK
HIGH\_RISK\_FLOW\_BLOCKED\_BY\_STALE\_AVAILABILITY

Support Signal alerts.

It does not change availability by itself.

32\. Relationship To POS Integration

POS availability sync depends on provider capability and mapping.

Core rule:

POS availability cannot be trusted without provider capability and item mapping.

33\. Relationship To KDS Integration

KDS availability sync depends on kitchen authority.

Core rule:

KDS availability signal must come from declared kitchen authority.

34\. Relationship To Limited Quantity

Limited quantity may use POS/KDS/inventory references.

Core rule:

Quantity reference must include source, timestamp, and reliability before commitment.

35\. Relationship To AI Menu Stabilization

AI menu creates item identity.

Availability sync requires stable menu item identity.

Core rule:

Unstable AI menu item cannot safely receive external availability sync.

36\. MVP Requirements

MVP should support at least:

manual source record
availability source type
source timestamp
source reliability
stale marker
conflict flag
conservative block flag
manual override
availability snapshot
audit event
failure event
support signal

MVP may defer:

real-time POS sold-out sync
KDS station sync
ingredient-level inventory sync
automatic source priority engine
automatic stock count reconciliation
advanced availability prediction

37\. Suggested Conceptual Entities

Suggested entities:

availability\_sources
availability\_source\_events
availability\_sync\_events
availability\_source\_reliability
availability\_conflicts
availability\_snapshots
availability\_sync\_audit\_events
availability\_sync\_failure\_events
availability\_sync\_support\_signals

This document defines policy.

Actual schema may be designed later.

38\. Risk If Skipped

If POS/KDS/Inventory Availability Sync policy is skipped, risks include:

stale POS sold-out data is trusted
KDS station pause is ignored
inventory says unavailable but preorder continues
sources conflict silently
limited items are over-promised
POS receives unavailable item
KDS receives impossible ticket
guest expectation fails
merchant trust decreases
support cannot explain availability decision

Therefore, availability sync must be governed before external source data controls preorder, POS handoff, or KDS handoff.

39\. Final Rule

Availability sync must be source-aware, timestamped, and conservative.

Final rule:

Record availability source.
Verify source capability.
Map external item identity.
Record timestamp.
Detect staleness.
Detect conflict.
Prioritize safety.
Block high-commitment flows when uncertain.
Do not trust unknown source.
Do not trust stale data.
Use manual override with audit.
Create availability snapshot at commitment.
Protect guest expectation and kitchen reality.
