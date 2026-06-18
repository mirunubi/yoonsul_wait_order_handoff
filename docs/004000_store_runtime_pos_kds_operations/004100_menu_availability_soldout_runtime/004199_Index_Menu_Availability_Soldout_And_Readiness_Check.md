# 004199_Index_Menu_Availability_Soldout_And_Readiness_Check

1\. Purpose

This document provides the index and readiness check for menu availability, sold-out handling, temporary unavailability, limited quantity, orderability, and kitchen continuity alignment.

The purpose is to confirm that menu availability and sold-out policy are ready to connect with POS acceptance, KDS ticket projection, degraded operation, and customer-safe messaging.

This document is an index and readiness gate.

It does not implement menu availability logic.

2\. Scope

This readiness check applies to:

\- Menu availability policy
\- Sold-out policy
\- Temporary unavailable state
\- Limited quantity state
\- Orderability boundary
\- POS acceptance dependency
\- KDS ticket dependency
\- Manual fallback dependency
\- Customer-facing availability message
\- Staff override boundary
\- Recovery and audit requirements

This readiness check does not define:

\- Inventory engine implementation
\- Automatic stock deduction
\- Menu master schema
\- POS vendor protocol
\- KDS vendor protocol
\- Customer refund automation
\- AI-controlled menu disabling
\- Dynamic pricing
\- Recipe mutation
\- Procurement workflow

3\. Document Position

This document depends on the main menu availability and sold-out policy document.

04190 \= Main menu availability and sold-out policy
04199 \= Index and readiness check for 04190 and its integration dependencies

This document also connects to the KDS integration document group.

04010 KDS Handoff Candidate And Kitchen Ticket Policy
04020 POS Accepted Order To KDS Ticket Boundary Policy
04030 KDS Retry Remake Delay And Fulfillment Status Policy
04040 KDS Degraded Operation Manual Kitchen Note Policy
04090 KDS Integration Kitchen Continuity MVP Cutline
04099 KDS Integration Kitchen Continuity Index And Readiness Check
04190 Menu Availability Soldout Policy
04199 Menu Availability Soldout Index And Readiness Check

4\. Core Principle

Menu availability determines whether an item should be orderable.

POS accepted order truth determines what has already been accepted.

KDS ticket projection determines what the kitchen must prepare or resolve.

These layers must not be collapsed.

Menu availability \= orderability signal
POS accepted order \= transaction truth
KDS ticket \= kitchen execution projection
Manual note \= fallback evidence

Sold-out may block future orderability.

Sold-out must not silently erase already accepted orders.

5\. Core Definitions

5.1 Menu Availability

Menu availability means whether an item is currently available for customer ordering or staff-assisted ordering.

Availability may vary by:

\- Store
\- Channel
\- Daypart
\- Prep status
\- Ingredient status
\- Kitchen capacity
\- Manual staff decision
\- Temporary operation condition

5.2 Sold-out

Sold-out means the store cannot reasonably accept new orders for the item because the item or a required ingredient is unavailable.

Sold-out usually blocks new orderability.

Sold-out does not retroactively mutate already accepted orders.

5.3 Temporary Unavailable

Temporary Unavailable means the item is paused for a limited operational reason.

Examples:

\- Prep not ready
\- Station overloaded
\- Equipment issue
\- Staff shortage
\- Packaging unavailable
\- Quality hold
\- Ingredient check pending

Temporary unavailable may be reversible during the same business day.

5.4 Limited Quantity

Limited Quantity means the item can still be ordered, but only within a remaining quantity or staff-confirmed capacity.

Limited quantity may require:

\- Staff confirmation
\- POS quantity guard
\- Kitchen visibility
\- Customer-safe message
\- Manual fallback note if system count is unreliable

5.5 Orderability

Orderability means whether the system or staff should allow a new order to be accepted.

Orderability is upstream of POS acceptance.

Once POS accepts the order, the order must be handled through accepted order, exception, cancellation, substitution, delay, or recovery policy.

5.6 Kitchen Availability Signal

Kitchen availability signal means a kitchen-facing indication that an item may be unavailable, delayed, limited, or risky to prepare.

This signal may inform KDS or staff.

It does not automatically mutate POS accepted order truth.

5.7 Availability Conflict

Availability conflict occurs when item availability state and accepted order state disagree.

Examples:

\- Item is sold out after POS accepted the order
\- KDS receives accepted item that kitchen says cannot be prepared
\- POS allows item that staff already marked unavailable manually
\- Manual fallback note says sold-out but system says available
\- Customer platform displays item as available while store pauses it

Availability conflict requires explicit resolution.

6\. Authority Boundary

6.1 Menu Master Authority

Menu master authority owns the existence and standard definition of the menu item.

Examples:

\- Item name
\- Category
\- Standard recipe reference
\- Base price
\- Standard modifier group
\- Allergen master reference
\- Nutrition reference, if applicable

Sold-out does not delete menu master.

Temporary unavailable does not delete menu master.

6.2 Store Availability Authority

Store availability authority controls whether a specific store can currently sell or pause an item.

This may be operated by:

\- Store manager
\- Authorized staff
\- HQ policy
\- Scheduled daypart rule
\- Inventory signal, if approved later
\- Quality or safety hold rule

The exact role permission may be defined later.

6.3 POS Acceptance Authority

POS or transaction-authoritative order service owns order acceptance.

The POS should respect orderability where integration exists.

However, once the POS accepts an order, the accepted order must not be silently erased by availability changes.

6.4 KDS Visibility Authority

KDS may display:

\- Accepted item
\- Sold-out conflict
\- Temporary unavailable note
\- Prep delay
\- Limited quantity warning
\- Kitchen exception
\- Manual recovery needed

KDS must not own:

\- Menu master
\- Inventory master
\- Payment
\- Refund
\- Loyalty
\- Customer identity
\- Accepted order mutation

6.5 Manual Staff Override Boundary

Manual override may be required during service.

Manual override may:

\- Mark item sold out
\- Mark item temporary unavailable
\- Mark limited quantity
\- Add kitchen note
\- Request manager review
\- Trigger customer confirmation

Manual override must not:

\- Silently delete accepted order
\- Approve refund alone
\- Mutate payment
\- Hide availability conflict
\- Remove audit evidence
\- Disable menu across stores without authority

7\. Sold-out State Families

7.1 Hard Sold-out

Hard Sold-out means the item cannot be sold for the remainder of the relevant period.

Examples:

\- Required ingredient exhausted
\- Item prep batch fully sold
\- Packaging completely unavailable
\- Safety hold
\- Equipment failure prevents item preparation

Hard sold-out normally blocks new orderability.

7.2 Soft Sold-out

Soft Sold-out means the item is likely unavailable but may require staff confirmation.

Examples:

\- Count is uncertain
\- Ingredient remains but not enough for normal flow
\- Kitchen lead must confirm last portions
\- Manual notes conflict with system state

Soft sold-out should not allow blind ordering without confirmation.

7.3 Prep Delayed

Prep Delayed means the item may become available later.

Examples:

\- Rice not ready
\- Protein batch cooling
\- Sauce refill pending
\- Vegetables being prepped
\- Soup batch not ready

Prep delayed may show as temporary unavailable or delayed orderability.

7.4 Ingredient Risk

Ingredient Risk means a required ingredient is suspected to be insufficient, compromised, or under review.

Examples:

\- Quality check pending
\- Temperature concern
\- Supplier issue
\- Allergen cross-contact concern
\- Shortage suspected

Ingredient risk may require manager or QC review before orderability resumes.

7.5 Kitchen Capacity Pause

Kitchen Capacity Pause means the item is temporarily paused because kitchen capacity cannot support additional orders safely.

Examples:

\- Station overloaded
\- Batch queue too long
\- Staff shortage
\- Delivery surge
\- Equipment bottleneck

Capacity pause should be customer-safe and reversible.

7.6 Manual Suspicion State

Manual Suspicion State means staff suspects the item should not be orderable, but final confirmation is pending.

Examples:

\- Staff thinks ingredient is gone
\- Manual count and system count disagree
\- KDS received conflict from kitchen
\- POS still shows item available
\- A note exists but manager has not reviewed

Manual suspicion state should trigger confirmation and prevent silent assumptions.

8\. Availability Readiness Domains

This readiness check uses the following domains.

1\. Menu master readiness
2\. Store availability readiness
3\. POS orderability readiness
4\. KDS visibility readiness
5\. Manual fallback readiness
6\. Customer message readiness
7\. Recovery and audit readiness

9\. Readiness Levels

Use the following readiness scale.

Level| Name| Meaning
R0| Undefined| No policy or owner is defined
R1| Policy Drafted| Policy exists but lacks fallback or boundary clarity
R2| Manual Operation Ready| Staff can operate manually with evidence
R3| POS/KDS Boundary Ready| Availability can align with accepted order and KDS projection
R4| MVP Integration Ready| Ready for MVP implementation planning
R5| Operationally Auditable| Production operation can be reconstructed and audited

MVP technical planning should not proceed below R3 for mandatory domains.

Pilot operation should target R4 or higher.

10\. Menu Master Readiness

Menu master readiness confirms that item identity is stable enough for availability control.

10.1 Required Conditions

\[ \] Menu item has stable identity.
\[ \] Store-level item mapping exists or is planned.
\[ \] Item display name is defined.
\[ \] Kitchen display name is defined or can be derived.
\[ \] Required modifier groups are known.
\[ \] Allergy/caution information is linked or explicitly deferred.
\[ \] Menu item can be active without being currently orderable.
\[ \] Sold-out does not delete menu master.

10.2 Not-ready Signals

The domain is not ready if:

\- Sold-out deletes or hides menu master identity
\- Store cannot distinguish inactive item from sold-out item
\- KDS item name differs from POS without mapping
\- Modifier groups are undefined
\- Allergy/caution information is lost when item is paused

10.3 Target Level

Minimum before implementation planning:

R3: POS/KDS Boundary Ready

11\. Store Availability Readiness

Store availability readiness confirms that a store can safely control current item availability.

11.1 Required Conditions

\[ \] Store can mark item available.
\[ \] Store can mark item sold out.
\[ \] Store can mark item temporary unavailable.
\[ \] Store can mark item limited quantity or defer it explicitly.
\[ \] Store can record reason.
\[ \] Store can record staff/source.
\[ \] Store can record time.
\[ \] Store can reverse temporary pause.
\[ \] Store can escalate uncertain cases.
\[ \] HQ/store authority boundary is defined.

11.2 Not-ready Signals

The domain is not ready if:

\- Anyone can disable items without role boundary
\- Sold-out reason is not recorded
\- Temporary pause cannot be distinguished from permanent removal
\- Staff cannot reverse mistaken pause
\- Limited quantity is shown without reliable count or confirmation
\- Store and HQ authority conflict is unresolved

11.3 Target Level

Minimum before implementation planning:

R2: Manual Operation Ready

Recommended before pilot:

R4: MVP Integration Ready

12\. POS Orderability Readiness

POS orderability readiness confirms that availability state can affect future order acceptance without mutating accepted orders.

12.1 Required Conditions

\[ \] POS can distinguish orderable from not orderable.
\[ \] POS can respect sold-out state where integrated.
\[ \] POS can respect temporary unavailable state where integrated.
\[ \] POS can handle limited quantity or defer it.
\[ \] POS does not accept new orders for hard sold-out items where integrated.
\[ \] POS accepted order remains traceable after availability change.
\[ \] Sold-out after acceptance triggers exception/recovery, not silent mutation.
\[ \] Cancellation/refund remains outside availability state alone.

12.2 Not-ready Signals

The domain is not ready if:

\- Sold-out can remove accepted order lines
\- POS accepts items after confirmed hard sold-out without warning
\- POS cancellation is automatically triggered by KDS sold-out note
\- Availability state changes payment state
\- Availability conflict has no exception path
\- POS and menu display can disagree without staff warning

12.3 Target Level

Minimum before implementation planning:

R3: POS/KDS Boundary Ready

Recommended before pilot:

R4: MVP Integration Ready

13\. KDS Visibility Readiness

KDS visibility readiness confirms that kitchen staff can see accepted work and availability conflicts without KDS becoming authority.

13.1 Required Conditions

\[ \] KDS receives accepted items only.
\[ \] KDS can display availability conflict.
\[ \] KDS can display sold-out after acceptance as exception or recovery.
\[ \] KDS can display prep delay.
\[ \] KDS can display temporary unavailable note where relevant.
\[ \] KDS can display limited quantity warning where relevant.
\[ \] KDS cannot mutate POS accepted order truth.
\[ \] KDS cannot disable menu master.
\[ \] KDS cannot approve refund from sold-out state alone.

13.2 Not-ready Signals

The domain is not ready if:

\- KDS can remove accepted order lines silently
\- KDS sold-out button directly mutates payment/refund state
\- Kitchen staff cannot distinguish sold-out from delayed prep
\- Accepted items disappear from KDS after availability change
\- KDS conflict has no manager or recovery path
\- KDS hides allergy/caution data during availability conflict

13.3 Target Level

Minimum before implementation planning:

R3: POS/KDS Boundary Ready

Recommended before pilot:

R4: MVP Integration Ready

14\. Manual Fallback Readiness

Manual fallback readiness confirms that staff can handle availability and sold-out issues when systems disagree or are unavailable.

14.1 Required Conditions

\[ \] Staff can record manual sold-out note.
\[ \] Staff can record temporary unavailable note.
\[ \] Staff can record limited quantity uncertainty.
\[ \] Staff can record item, time, reason, and staff source.
\[ \] Staff can mark accepted order affected by sold-out.
\[ \] Staff can preserve customer/order reference where available.
\[ \] Staff can preserve KDS/manual note mismatch.
\[ \] Staff can escalate uncertain case.
\[ \] Manual note is evidence, not POS truth.

14.2 Not-ready Signals

The domain is not ready if:

\- Manual note can silently remove order
\- Manual note can approve refund alone
\- Staff throws away availability notes before reconciliation
\- Sold-out during KDS failure has no recording path
\- Manual note does not preserve affected accepted order reference
\- Staff cannot distinguish suspected sold-out from confirmed sold-out

14.3 Target Level

Minimum before implementation planning:

R2: Manual Operation Ready

Recommended before pilot:

R4: MVP Integration Ready

15\. Customer Message Readiness

Customer message readiness confirms that availability and sold-out states can be communicated safely.

15.1 Required Conditions

\[ \] Customer-facing sold-out message is defined.
\[ \] Customer-facing temporary unavailable message is defined.
\[ \] Customer-facing prep delay message is defined or deferred.
\[ \] Customer-facing limited quantity message is defined or deferred.
\[ \] Sold-out after acceptance message avoids blame.
\[ \] Message does not promise refund without approval.
\[ \] Message does not expose internal system failure.
\[ \] Staff-assisted wording exists for uncertain cases.

15.2 Safe Message Examples

Allowed examples:

This item is currently unavailable.
This item is temporarily paused.
This item may take longer than usual.
A staff member will confirm this item.
This item became unavailable after order acceptance, and staff will assist.

Avoid:

The kitchen forgot to update the system.
The POS made a mistake.
The KDS failed.
You will automatically get a refund.
The staff marked it wrong.
Inventory is broken.

15.3 Target Level

Minimum before implementation planning:

R2: Manual Operation Ready

Recommended before pilot:

R4: MVP Integration Ready

16\. Recovery and Audit Readiness

Recovery and audit readiness confirms that availability conflicts can be reconstructed.

16.1 Required Conditions

\[ \] Availability state change can be traced.
\[ \] Sold-out reason can be traced.
\[ \] Staff/source can be traced.
\[ \] Time can be traced.
\[ \] Affected accepted orders can be identified where applicable.
\[ \] KDS conflict can be traced.
\[ \] Manual fallback note can be traced.
\[ \] Recovery action can be traced.
\[ \] Reversal or reopening can be traced.
\[ \] Silent overwrite is prohibited.

16.2 Not-ready Signals

The domain is not ready if:

\- No one knows who marked item sold out
\- Sold-out time is unknown
\- Accepted order conflict disappears after recovery
\- Manual note is not retained
\- Reversal overwrites original sold-out event
\- KDS conflict is dismissed without resolution
\- Availability state is used as automatic blame

16.3 Target Level

Minimum before implementation planning:

R3: POS/KDS Boundary Ready

Recommended before pilot:

R5: Operationally Auditable

17\. Integration Dependency Check

Dependency| Required From| Impact
Stable menu item identity| Menu master policy| Needed for availability state
Store-level menu mapping| Store/menu mapping policy| Needed for store-specific sold-out
POS accepted order boundary| 04020| Prevents sold-out from mutating accepted order truth
KDS ticket projection| 04010| KDS receives accepted work only
KDS status exception| 04030| Sold-out conflict can become exception/recovery
Manual kitchen note| 04040| Availability conflict survives degraded operation
MVP cutline| 04090| Defines whether availability is must-have or later
KDS readiness index| 04099| Confirms cross-document readiness

18\. Readiness Matrix

Domain| Minimum for Planning| Recommended for Pilot| Current Review Note
Menu master readiness| R3| R4| Must preserve stable item identity
Store availability readiness| R2| R4| Manual operation may be enough for MVP
POS orderability readiness| R3| R4| Must not mutate accepted orders
KDS visibility readiness| R3| R4| KDS displays conflict only
Manual fallback readiness| R2| R4| Required before pilot
Customer message readiness| R2| R4| Safe wording required
Recovery and audit readiness| R3| R5| Production requires stronger evidence

19\. Required Before Implementation

Before implementation planning begins, confirm:

\[ \] 04190 is complete.
\[ \] 04199 is complete.
\[ \] Sold-out definition is accepted.
\[ \] Temporary unavailable definition is accepted.
\[ \] Orderability boundary is accepted.
\[ \] Sold-out after acceptance does not mutate accepted order.
\[ \] POS/KDS boundary dependency is accepted.
\[ \] KDS conflict display is not authority.
\[ \] Manual fallback can record availability conflict.
\[ \] Customer-safe messages are defined or explicitly deferred.
\[ \] Recovery/audit requirement is accepted.

20\. Not Ready Signals

The availability/sold-out policy group is not ready if any of the following are true.

Sold-out deletes menu master.
Sold-out silently removes accepted orders.
Temporary unavailable is indistinguishable from permanent deletion.
KDS can disable menu without authority.
KDS sold-out note can approve refund.
Manual note can replace POS truth.
Limited quantity can oversell without review path.
Availability conflict has no recovery path.
Customer message blames staff, POS, KDS, or vendor.
Availability state changes are not auditable.
Reversal overwrites original sold-out history.

If any of these remain, implementation should be delayed or explicitly scoped out.

21\. MVP Readiness Summary

The menu availability and sold-out group is MVP-ready when:

\- Menu identity is stable
\- Store availability state can be controlled
\- Sold-out blocks future orderability where integrated
\- Sold-out does not mutate accepted orders retroactively
\- Temporary unavailable is distinct from sold-out
\- Limited quantity is defined or explicitly deferred
\- POS orderability boundary is clear
\- KDS displays conflicts without authority mutation
\- Manual fallback preserves availability conflicts
\- Customer-safe messages are available
\- Recovery and audit evidence is preserved

22\. Recommended Next Documents

After this readiness check, recommended follow-up documents include:

04210 KDS Station Routing Policy
04220 Kitchen Display Staff Role And Training SOP
04230 KDS Bridge Vendor Integration Boundary
04240 Kitchen Delay Customer Message Policy
04250 Manual Kitchen Recovery Evidence Packet Policy
04260 KDS Duplicate Ticket And Replay SOP
04270 KDS Allergy Caution Visibility Policy
04280 KDS Printer Fallback And Paper Queue Policy
04290 KDS Pilot Store Readiness Checklist

For menu availability specifically:

04310 Store Menu Availability Role Permission Policy
04320 Sold-out Customer Message And Recovery SOP
04330 Limited Quantity And Last Portion Handling Policy
04340 Menu Availability Audit Event Policy
04350 Inventory Signal To Menu Availability Boundary Policy

23\. Non-goals

This document does not define:

\- Menu database schema
\- Inventory deduction logic
\- Real-time stock count
\- POS vendor integration
\- KDS vendor integration
\- Customer refund workflow
\- Dynamic pricing
\- AI recommendation model
\- Automatic sold-out engine
\- Procurement or supplier workflow
\- Recipe formulation
\- Staff disciplinary logic

24\. Acceptance Criteria

This readiness check is ready when:

\- 04190 is clearly positioned as the main policy
\- 04199 is clearly positioned as index/readiness check
\- Core definitions are documented
\- Authority boundary is documented
\- Sold-out state families are documented
\- Readiness domains are documented
\- Readiness levels are documented
\- Menu master readiness is checkable
\- Store availability readiness is checkable
\- POS orderability readiness is checkable
\- KDS visibility readiness is checkable
\- Manual fallback readiness is checkable
\- Customer message readiness is checkable
\- Recovery and audit readiness is checkable
\- Integration dependencies are documented
\- Not-ready signals are documented
\- MVP readiness summary is documented
\- No implementation-specific design is forced

25\. Open Questions

\- Should limited quantity be included in MVP or deferred?
\- Who can mark hard sold-out during peak service?
\- Who can reverse sold-out state?
\- Should sold-out after acceptance always require manager review?
\- Should prep delayed be visible to customers or staff only?
\- Should kitchen capacity pause be treated as menu availability or order throttling?
\- Should inventory signal be advisory only in MVP?
\- Should sold-out state be channel-specific?
\- Should customer-facing message vary by dine-in, pickup, and delivery?
\- Should repeated sold-out conflicts trigger HQ review?
