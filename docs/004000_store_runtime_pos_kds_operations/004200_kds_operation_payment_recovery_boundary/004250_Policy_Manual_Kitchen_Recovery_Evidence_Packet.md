# 004250_Policy_Manual_Kitchen_Recovery_Evidence_Packet.md

## **1\. Purpose**

This document defines the evidence packet policy for manual kitchen recovery situations.

Manual kitchen recovery occurs when normal POS-to-KDS, KDS Bridge, Agent, or kitchen ticket flow cannot be trusted, delayed tickets must be reconstructed, or kitchen execution must continue through manual staff action.

The purpose of this policy is to ensure that manual recovery does not become silent correction, hidden overwrite, untraceable remake, or unverifiable kitchen execution.

Manual recovery is allowed only when it is captured as evidence, linked to the affected order or kitchen ticket, and reviewed through the proper operational lane.

---

## **2\. Scope**

This policy applies to:

* POS accepted order to KDS ticket handoff failure
* KDS ticket missing, delayed, duplicated, stale, or unreadable state
* Kitchen ticket remake due to system interruption
* Manual kitchen note used during degraded operation
* Staff-written ticket used as temporary kitchen execution source
* Agent or bridge visibility mismatch requiring human confirmation
* Recovery after offline, LAN partition, tablet failure, printer failure, or KDS screen failure
* Post-incident reconstruction of kitchen fulfillment history

This policy does not define normal KDS ticket operation, menu availability logic, payment authority, refund authority, or customer compensation rules.

---

## **3\. Core Principle**

Manual kitchen recovery is not a replacement for system authority.

Manual recovery is a temporary operational survival action.

The recovered action must be supported by an evidence packet.

The evidence packet must preserve what happened, who acted, why manual recovery was needed, what source was trusted, what was prepared, and what remains uncertain.

---

## **4\. Authority Boundary**

Manual kitchen recovery may allow staff to continue kitchen execution.

Manual kitchen recovery must not allow staff to:

* Rewrite the original POS order
* Alter payment status
* Change settlement authority
* Silently mark a disputed ticket as resolved
* Delete or overwrite failed KDS events
* Backfill system history without evidence
* Convert uncertain state into verified state without review

Manual recovery can produce provisional kitchen execution status only.

Verified recovery status must come from reconciliation against POS, KDS, bridge logs, audit events, and staff evidence.

---

## **5\. Evidence Packet Definition**

A Manual Kitchen Recovery Evidence Packet is a structured collection of records that explains and supports a manual recovery action.

The packet may include:

* Affected order ID
* Affected kitchen ticket ID
* Store ID
* POS source reference
* KDS source reference
* Bridge event reference
* Agent alert reference
* Recovery start time
* Recovery end time
* Staff member who initiated recovery
* Staff member who approved recovery
* Kitchen station involved
* Menu items affected
* Quantity affected
* Original ticket state
* Observed failure state
* Manual action taken
* Customer-facing impact
* Kitchen-facing impact
* Photo, note, screenshot, paper ticket, or staff memo
* Final reconciliation result
* Remaining uncertainty flag

---

## **6\. Required Minimum Packet Fields**

Every evidence packet must contain at least:

packet\_id
store\_id
order\_reference
ticket\_reference\_or\_reason\_missing
incident\_time
recovery\_time
recovery\_actor
recovery\_reason
trusted\_source\_used
manual\_action\_taken
affected\_items
reconciliation\_status
created\_at

If any required field cannot be captured, the packet must be marked:

EVIDENCE\_INCOMPLETE

Incomplete evidence does not block emergency kitchen action, but it must prevent silent closure.

---

## **7\. Recovery Reasons**

Allowed recovery reason categories include:

KDS\_TICKET\_MISSING
KDS\_TICKET\_DELAYED
KDS\_TICKET\_DUPLICATED
KDS\_STATE\_STALE
KDS\_SCREEN\_UNAVAILABLE
KDS\_PRINTER\_UNAVAILABLE
POS\_KDS\_HANDOFF\_FAILED
BRIDGE\_UNAVAILABLE
AGENT\_VISIBILITY\_MISMATCH
NETWORK\_PARTITION
DEVICE\_FAILURE
POWER\_INTERRUPTION
STAFF\_MANUAL\_CONFIRMATION\_REQUIRED
CUSTOMER\_WAIT\_RISK
KITCHEN\_CONTINUITY\_REQUIRED

Free-text explanation may be added, but the structured category must remain.

---

## **8\. Trusted Source Rule**

During recovery, staff must identify which source is being trusted.

Allowed trusted source types include:

POS\_ACCEPTED\_ORDER
POS\_RECEIPT
CUSTOMER\_ORDER\_SCREEN
KDS\_LAST\_VISIBLE\_STATE
KDS\_PRINTED\_TICKET
BRIDGE\_EVENT\_LOG
AGENT\_ALERT
STAFF\_OBSERVED\_ORDER
MANUAL\_COUNTER\_NOTE
CUSTOMER\_CONFIRMATION

If the trusted source is not system-originated, the packet must be marked:

HUMAN\_SOURCE\_DEPENDENT

If multiple sources conflict, the packet must be marked:

SOURCE\_CONFLICT\_REVIEW\_REQUIRED

---

## **9\. Manual Action Types**

Manual action must be classified.

Allowed manual action types include:

MANUAL\_TICKET\_CREATED
MANUAL\_TICKET\_REWRITTEN
MANUAL\_REMAKE\_STARTED
MANUAL\_REMAKE\_CANCELLED
MANUAL\_ITEM\_CONFIRMED
MANUAL\_ITEM\_HELD
MANUAL\_ITEM\_RELEASED
MANUAL\_STATION\_NOTE\_CREATED
MANUAL\_CUSTOMER\_CHECK\_REQUIRED
MANUAL\_MANAGER\_CONFIRMATION\_REQUESTED

Manual action must describe the kitchen action, not the final truth of the order.

---

## **10\. Status Model**

Manual kitchen recovery evidence packet status may be:

OPEN
EVIDENCE\_INCOMPLETE
KITCHEN\_ACTION\_IN\_PROGRESS
WAITING\_RECONCILIATION
SOURCE\_CONFLICT\_REVIEW\_REQUIRED
RECONCILED
RECONCILED\_WITH\_EXCEPTION
HQ\_REVIEW\_REQUIRED
CLOSED

A packet may not move directly from `OPEN` to `CLOSED`.

A packet must pass through reconciliation or exception review.

---

## **11\. Reconciliation Rule**

Reconciliation must compare manual action against available system records.

The reconciliation process should check:

* POS accepted order
* POS payment status
* KDS ticket creation event
* KDS station state
* Bridge handoff log
* Agent anomaly log
* Staff manual note
* Customer-facing order history
* Remake or delay record
* Refund or compensation case, if any

Reconciliation does not rewrite the original event.

Reconciliation appends a recovery conclusion.

---

## **12\. No Silent Merge Rule**

Manual recovery records must not be silently merged into normal KDS history.

Recovered records must remain distinguishable from normal system-generated tickets.

A recovered kitchen action must carry one of the following flags:

FALLBACK\_ORIGINATED
MANUAL\_RECOVERY\_ORIGINATED
RECONCILED\_AFTER\_FAILURE
RECONCILED\_WITH\_EXCEPTION

This prevents degraded-operation actions from being mistaken as normal uninterrupted execution.

---

## **13\. Duplicate And Remake Protection**

Manual recovery must protect against duplicate preparation.

Before starting a manual remake, staff should check:

* Whether the item was already prepared
* Whether the ticket exists on another KDS screen
* Whether another station received the same order
* Whether the customer already received the item
* Whether the POS order was cancelled or modified
* Whether the kitchen note is stale

If uncertainty remains, the packet must be marked:

DUPLICATE\_PREPARATION\_RISK

---

## **14\. Customer Impact Classification**

Customer impact should be classified as:

NO\_VISIBLE\_IMPACT
MINOR\_DELAY
MAJOR\_DELAY
WRONG\_ITEM\_RISK
DUPLICATE\_ITEM\_RISK
MISSING\_ITEM\_RISK
CUSTOMER\_CONFIRMATION\_REQUIRED
CUSTOMER\_RECOVERY\_REQUIRED

This classification does not automatically create compensation.

Customer compensation must follow the separate customer recovery policy.

---

## **15\. Staff Responsibility**

The staff member initiating recovery is responsible for capturing the first evidence.

The kitchen lead or manager is responsible for confirming whether manual kitchen execution should proceed.

HQ or owner review may be required when:

* Payment status is uncertain
* Customer dispute occurs
* Duplicate preparation causes material loss
* Multiple orders are affected
* Recovery packet is incomplete
* System failure lasts beyond store-level handling
* Repeated recovery occurs for the same integration path

---

## **16\. Evidence Attachment Rule**

Acceptable evidence attachments include:

* Photo of paper ticket
* Photo of KDS screen
* POS receipt image
* Customer order screen image
* Staff memo
* Manager note
* Bridge error screenshot
* Agent alert screenshot
* Kitchen station note
* Time-stamped manual checklist

Attachments must not contain unnecessary personal information.

If customer information is visible, masking should be applied where practical.

---

## **17\. Audit Requirements**

Every packet must create audit events for:

* Packet creation
* Evidence attachment
* Manual action start
* Manual action completion
* Manager confirmation
* Reconciliation start
* Reconciliation result
* Exception escalation
* Packet closure

Audit records must be append-only.

No packet may be deleted to hide operational failure.

---

## **18\. Prohibited Handling**

The following are prohibited:

* Deleting failed KDS events after manual recovery
* Marking a ticket as normal when it was manually recovered
* Rewriting order state without source evidence
* Treating staff memory alone as verified truth
* Closing incomplete packet without exception flag
* Combining multiple incidents into one vague packet
* Using recovery packet as refund authority
* Using recovery packet as disciplinary conclusion
* Allowing Agent recommendation to become execution authority

---

## **19\. Runtime Integration Boundary**

The evidence packet may be linked to:

* POS order
* KDS ticket
* KDS Bridge event
* Agent anomaly
* Store incident
* Customer recovery case
* Waste or remake record
* Audit event
* Manual kitchen note

However, the packet itself is not the owner of payment, refund, settlement, inventory, or legal decision.

It is an operational evidence container.

---

## **20\. MVP Cutline**

For MVP, the system only needs to support:

* Manual recovery packet creation
* Required minimum fields
* Recovery reason category
* Trusted source category
* Manual action category
* Evidence note or attachment reference
* Reconciliation status
* Append-only audit event
* Fallback-originated flag

Advanced automation, AI analysis, cross-store benchmarking, and predictive recovery scoring are excluded from MVP.

---

## **21\. Readiness Check**

This policy is ready when the following are true:

* Manual recovery can be recorded without blocking kitchen survival
* Staff can identify why recovery was needed
* Staff can identify which source was trusted
* Recovered tickets remain visibly different from normal tickets
* Reconciliation can occur after the incident
* Incomplete packets cannot be silently closed
* Audit trail exists for every recovery step
* Customer compensation remains separate from kitchen recovery evidence
* Agent recommendation does not become execution authority
* Manual recovery improves continuity without damaging truth history

---

## **22\. Summary**

Manual kitchen recovery is allowed because stores must survive real operational interruptions.

But survival action must not erase truth.

A manual recovery evidence packet preserves the difference between normal system execution, degraded manual execution, unresolved uncertainty, and verified reconciliation.

The goal is kitchen continuity with evidence, not silent correction.
