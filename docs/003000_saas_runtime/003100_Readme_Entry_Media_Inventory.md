# 003100_Readme_Entry_Media_Inventory.md

## Purpose

This document defines the SaaS runtime or entry media inventory topic indicated by its filename and preserves its governed documentation role within `docs/003000_saas_runtime/`.

## Local File Roles

| document | role |
| --- | --- |
| `003100_Readme_Entry_Media_Inventory.md` | Local Readme for Entry Media Inventory ownership, QR/NFC asset lifecycle, and non-ownership boundaries. |
| `003110_Policy_QR_NFC_Entry_Plate_Assignment_Recovery_And_Reallocation.md` | Policy for QR/NFC entry plate assignment, recovery, and reallocation. |
| `003130_Policy_Entry_Media_Status_Lifecycle_And_Audit.md` | Policy for entry media status lifecycle and audit trail. |
| `003140_Policy_Entry_Media_Test_Field_Sample_And_Production_Separation.md` | Policy separating test, field sample, and production entry media assets. |
| `003150_Policy_Entry_Media_Lost_Damaged_And_Retired_Asset.md` | Policy for lost, damaged, retired, and replaced entry media assets. |
| `003160_Policy_Entry_Media_Identifier_Encoding_And_Resolution.md` | Policy for entry media identifier encoding, lookup, and resolution. |
| `003170_Policy_Entry_Media_Scan_Usage_And_Trial_Observation.md` | Policy for scan usage observation, trial monitoring, and usage evidence. |
| `003180_Policy_Entry_Media_Admin_Access_Suspension_And_Service_Termination_Link.md` | Policy linking entry media admin access, suspension, and service termination. |
| `003190_Policy_Entry_Media_Production_Batch_Stock_And_Inventory_Control.md` | Policy for production batch, stock, and inventory control of entry media assets. |
| `003199_Index_Entry_Media_Inventory_And_MVP_Cutline.md` | Index for Entry Media Inventory documents and MVP cutline alignment. |

Legacy path: $old.

1\. Purpose

This folder defines the root-level Entry Media Inventory governance for CatchMenu.

Entry Media Inventory manages reusable physical and logical access assets such as QR/NFC entry plates.

These assets may be assigned to trial stores, test stores, production stores, merchant pilots, or future operating stages.

Runtime modules such as Stage 0 may use assigned Entry Media, but they do not own the inventory lifecycle.

Core purpose:

Manage reusable QR/NFC entry assets.
Assign them to stores safely.
Deactivate them safely.
Recover and reallocate them without losing history.
Preserve mapping and audit trail.

Korean purpose:

재사용 가능한 QR/NFC 진입 자산을 관리한다.
매장에 안전하게 배정한다.
안전하게 비활성화한다.
회수 및 재배정 시 이력을 잃지 않는다.
매핑 및 감사 이력을 보존한다.

2\. Scope

This folder covers:

Entry Plate inventory
QR code identity
NFC tag identity
Entry Media assignment
Entry Media activation
Entry Media deactivation
Entry Media recovery
Entry Media reallocation
mapping history
asset status lifecycle
audit trail
lost / damaged / retired asset handling
trial and production assignment support

This folder does not define:

field installation SOP
merchant sales script
physical visit procedure
menu creation workflow
AI menu intake
Stage 0 request handling
guest web screen
owner console screen
POS integration
KDS integration
payment settlement

Field operations SOP is maintained under the root "sop/" folder, not under "docs/".

3\. Entry Media Definition

Entry Media is a logical access medium that allows a guest or merchant to enter a CatchMenu flow.

Examples:

QR\_CODE
NFC\_TAG
SHORT\_LINK
ENTRY\_URL
POSTER\_LINK

Entry Media may be embedded into a physical Entry Plate.

4\. Entry Plate Definition

Entry Plate is a physical mini board, plate, sticker, stand, or guide object that contains one or more Entry Media.

A typical Entry Plate may include:

NFC tag
printed QR code
CatchMenu guide text
mini advertisement message
store-level entry guide

Entry Plate is a reusable physical asset.

Core rule:

Entry Plate is inventory.
QR/NFC is access identity.
Mapping connects the asset to a store context.

5\. Root-Level Ownership

Entry Media Inventory is a root-level governance area.

It is not owned by Stage 0\.

It is not owned by Merchant Ops.

It is not owned by Owner Console.

It is not owned by Guest Web.

Reason:

The same QR/NFC plate may be used for:
\- test store
\- trial merchant
\- Stage 0 store
\- future Stage 1 store
\- production merchant
\- recovered and reallocated merchant

Core rule:

Runtime modules use Entry Media.
Entry Media Inventory owns the asset lifecycle.

Korean rule:

런타임 모듈은 Entry Media를 사용한다.
Entry Media Inventory는 자산 생명주기를 소유한다.

6\. Relationship To Stage 0

Stage 0 uses assigned Entry Media to resolve guest entry into store/menu/stage context.

Stage 0 may resolve:

entry\_media\_id
→ store\_id
→ menu\_context\_id
→ enabled\_stage
→ guest flow

However, Stage 0 must not own:

asset registration
asset recovery
asset reallocation
mapping history deletion
physical inventory state

Stage 0 should reference this folder for asset lifecycle governance.

7\. Relationship To SOP

Operational SOP may define how the operations team installs, recovers, and reuses Entry Plates in the field.

However, SOP does not own the system of record.

Separation:

docs/00300\_entry\_media\_inventory/
\= system policy, asset lifecycle, mapping history, audit

sop/entry\_media\_operations/
\= field procedure, merchant visit, installation, recovery, re-use checklist

Core rule:

SOP performs field operation.
Entry Media Inventory preserves system truth.

8\. Entry Media Kit

A basic CatchMenu field kit may include:

inside-store Entry Plate
outside mini ad board
NFC tag
printed QR code
store guide copy

For low-cost Stage 0 trial, the initial package may include only:

one inside-store Entry Plate
NFC \+ QR
admin trial access

Cost-aware operation may require recovery and reuse when a merchant does not convert.

9\. Store-Level Default

For POS-less Stage 0 adoption, Entry Media is store-level by default.

That means:

store\_id \= required
menu\_context\_id \= required
table\_id \= optional
table\_id \= usually null

Stage 0 trial stores do not need table-level mapping.

Core rule:

Do not require table identity for POS-less Stage 0 entry.

10\. Entry Media Types

Suggested entry media types:

QR\_CODE
NFC\_TAG
SHORT\_LINK
ENTRY\_URL
POSTER\_LINK

Suggested physical asset types:

ENTRY\_PLATE
MINI\_AD\_BOARD
COUNTER\_GUIDE
WINDOW\_STICKER
DOOR\_SIGN
TABLE\_STICKER
TEST\_PLATE

Stage 0 trial usually uses:

ENTRY\_PLATE
MINI\_AD\_BOARD

11\. Placement Types

Entry Plate placement should be tracked.

Suggested placement types:

OUTSIDE\_AD\_BOARD
INSIDE\_STORE\_GUIDE
COUNTER\_GUIDE
ENTRANCE\_GUIDE
WINDOW\_GUIDE
TABLE\_GUIDE
TEST\_LOCATION
UNKNOWN

For Stage 0 POS-less basic trial:

INSIDE\_STORE\_GUIDE

is sufficient.

Optional expansion:

OUTSIDE\_AD\_BOARD

12\. Entry Media Status

Entry Media and Entry Plate should have explicit status.

Suggested statuses:

IN\_STOCK
ASSIGNED
ACTIVE
TRIAL\_ACTIVE
TRIAL\_EXPIRED
SUSPENDED
DEACTIVATED
RECOVERY\_REQUESTED
RECOVERED
REALLOCATION\_READY
REALLOCATED
LOST
DAMAGED
RETIRED

Status must be event-backed.

Status must not be changed silently.

13\. Mapping Principle

Entry Media does not contain full store/menu data.

Entry Media contains or references an identity.

The system resolves that identity into current assigned context.

Example:

entry\_media\_id
→ current assignment
→ store\_id
→ menu\_context\_id
→ enabled\_stage
→ guest flow

Core rule:

Entry Media identifies.
Mapping resolves.
Runtime uses resolved context.

14\. Assignment Principle

Assignment connects Entry Media to a store or test context.

Assignment must record:

entry\_media\_id
entry\_plate\_id
store\_id or test\_context\_id
menu\_context\_id
placement
assignment\_start\_at
assigned\_by
assignment\_reason
status

Assignment must be auditable.

Assignment must not overwrite previous assignment history.

15\. Deactivation Principle

Deactivation stops an Entry Media from being active for its current mapping.

Deactivation may happen because:

trial ended without conversion
merchant declined
store closed
plate recovered
plate lost
plate damaged
wrong mapping detected
reallocation required
security concern exists

Deactivation must preserve history.

Core rule:

Deactivate mapping.
Do not delete history.

16\. Recovery Principle

Recovery means the physical Entry Plate is collected back from the merchant or field location.

Recovery is physical.

Deactivation is logical.

They are related but not the same.

deactivation
\= system mapping no longer active

recovery
\= physical plate returned or collected

Core rule:

Logical deactivation and physical recovery must both be tracked.

17\. Reallocation Principle

Reallocation assigns a recovered or reusable Entry Media asset to a new store or test context.

Reallocation creates a new assignment period.

Reallocation must not overwrite previous assignment.

Core rule:

Reallocation creates new history.
Reallocation does not erase old history.

Korean rule:

재배정은 새 이력을 만든다.
재배정은 과거 이력을 지우지 않는다.

18\. Mapping History

Mapping history is mandatory.

Mapping history should preserve:

previous store
new store
previous menu context
new menu context
previous placement
new placement
assignment period
deactivation reason
reallocation reason
actor
timestamp
trace id

This allows support to answer questions such as:

Which store did this NFC point to on that date?
When was this QR reassigned?
Was this plate still active at the old store?
Did a guest scan before or after reallocation?

19\. Deletion Policy

Hard deletion should be prohibited by default.

Do not hard-delete:

entry media record
entry plate record
assignment record
mapping history
deactivation event
reallocation event
recovery event

Use status changes and event history instead.

Core rule:

Retire, deactivate, or archive.
Do not erase operational history.

20\. Admin Access Relationship

Entry Media assignment may be related to merchant admin access.

When trial or service ends:

admin access may be suspended
request receiving may be disabled
menu editing may be disabled
entry media mapping may be deactivated
physical plate may be recovered

However, admin access lifecycle is separate from physical asset lifecycle.

Core rule:

Disable access when needed.
Preserve asset and mapping history.

21\. Trial Store Support

Trial store assignment should be supported.

Trial assignment may include:

trial\_start\_at
trial\_end\_at
trial\_status
trial\_store\_ref
admin\_access\_enabled
entry\_plate\_assigned
mapping\_active

Trial expiration does not automatically mean physical recovery is complete.

Suggested separation:

TRIAL\_EXPIRED
RECOVERY\_REQUESTED
RECOVERED
REALLOCATION\_READY

22\. Test Store Support

Entry Media may be assigned to test stores or internal test contexts.

Test assets must be clearly marked.

Suggested status or flag:

TEST\_ONLY

Test Entry Media must not accidentally create production guest requests.

Core rule:

Test media must be visibly and logically separated from production media.

23\. Lost Asset Handling

If an Entry Plate is lost:

mark asset LOST
deactivate mapping
block reallocation
preserve last known assignment
create audit event

If a lost asset is later found, it must be verified before reactivation.

24\. Damaged Asset Handling

If an Entry Plate is damaged:

mark DAMAGED
inspect NFC
inspect QR
decide repair, retire, or reuse
deactivate mapping if unsafe

A damaged but still scannable asset may be operationally dangerous if it shows misleading text.

Do not reuse damaged assets without verification.

25\. Retired Asset Handling

Retire assets when:

NFC permanently failed
QR cannot be safely reused
physical branding is obsolete
plate is too damaged
security issue exists

Retired asset must not be assigned again.

26\. Evidence And Audit

Every important lifecycle change should create an audit event.

Events may include:

ENTRY\_MEDIA\_REGISTERED
ENTRY\_MEDIA\_ASSIGNED
ENTRY\_MEDIA\_ACTIVATED
ENTRY\_MEDIA\_DEACTIVATED
ENTRY\_MEDIA\_RECOVERY\_REQUESTED
ENTRY\_MEDIA\_RECOVERED
ENTRY\_MEDIA\_REALLOCATION\_READY
ENTRY\_MEDIA\_REALLOCATED
ENTRY\_MEDIA\_LOST
ENTRY\_MEDIA\_DAMAGED
ENTRY\_MEDIA\_RETIRED

Audit event should include:

actor
timestamp
previous\_state
new\_state
reason
store\_id if applicable
entry\_media\_id
entry\_plate\_id
trace\_id

27\. Support Questions This Folder Must Answer

The Entry Media Inventory system should help answer:

Where is this plate now?
Which store is this NFC assigned to?
Which store was this QR assigned to last month?
Is this plate active?
Is this plate recovered?
Can this plate be reallocated?
Was this QR used in a trial store?
Was this asset lost or damaged?
Did admin access end before or after deactivation?

28\. Safety Rules

Entry Media Inventory must prevent unsafe shortcuts.

Prohibited:

reuse without deactivation
reallocate without history
delete old mapping
assign active plate to another store without closing previous assignment
use test plate in production without conversion
reactivate lost plate without verification
leave trial plate active after merchant termination

Core rule:

No reuse without trace.
No reallocation without prior assignment closure.
No deletion of mapping history.

29\. Suggested Documents

This folder may include:

00300\_Entry\_Media\_Inventory\_Readme.md
00310\_QR\_NFC\_Entry\_Plate\_Assignment\_Recovery\_And\_Reallocation\_Policy.md
00320\_Entry\_Media\_Mapping\_History\_And\_Deactivation\_Policy.md
00330\_Entry\_Media\_Status\_Lifecycle\_And\_Audit\_Policy.md

Future documents may include:

00340\_Entry\_Media\_Test\_And\_Production\_Separation\_Policy.md
00350\_Entry\_Media\_Lost\_Damaged\_And\_Retired\_Asset\_Policy.md

30\. Relationship To Future AI Menu Intake

AI menu intake is a separate owner/admin function.

It may help merchants create menu data from photos or scanned menu boards.

It does not belong to Entry Media Inventory.

Entry Media Inventory may link to menu context, but it does not generate menus.

Core separation:

Entry Media Inventory
\= access asset and mapping lifecycle

AI Menu Intake
\= menu data creation and draft generation

31\. Final Rule

Entry Media Inventory is the system of record for reusable QR/NFC entry assets.

Final rule:

Register the asset.
Assign it with scope.
Activate it with trace.
Deactivate it before reuse.
Recover it physically.
Reallocate it with history.
Never erase prior mapping.
