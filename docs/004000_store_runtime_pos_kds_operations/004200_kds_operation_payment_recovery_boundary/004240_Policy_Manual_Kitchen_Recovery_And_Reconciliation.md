# 004240_Policy_Manual_Kitchen_Recovery_And_Reconciliation.md

## **1\. Purpose**

This document defines the policy for manual kitchen recovery and reconciliation when normal KDS, POS-to-KDS handoff, KDS Bridge, Agent visibility, or kitchen ticket flow cannot be trusted.

The purpose of this policy is to allow kitchen continuity during degraded operation while preserving operational truth.

Manual kitchen recovery must help the store continue service, but it must not create silent correction, hidden overwrite, duplicate preparation, payment confusion, or unverifiable kitchen history.

---

## **2\. Scope**

This policy applies to:

* KDS ticket missing
* KDS ticket delayed
* KDS ticket duplicated
* KDS state stale
* POS accepted order not visible in KDS
* POS-to-KDS handoff failure
* Bridge unavailable or delayed
* Agent visibility mismatch
* KDS tablet failure
* KDS printer failure
* Network partition
* Local device failure
* Staff-written manual kitchen ticket
* Manual remake during system uncertainty
* Kitchen action performed before system recovery
* Reconciliation after degraded kitchen operation

This policy does not define payment approval, refund authority, customer compensation, legal dispute handling, or final settlement authority.

---

## **3\. Core Principle**

Manual kitchen recovery is allowed only as a continuity action.

Manual kitchen recovery is not system truth.

Manual kitchen recovery must be marked, evidenced, reconciled, and auditable.

The system must preserve the difference between:

normal system-generated kitchen execution
degraded manual kitchen execution
unverified staff observation
reconciled recovery
reconciled recovery with exception

Manual recovery must never erase the fact that a degraded operation occurred.

---

## **4\. Authority Boundary**

Kitchen staff may continue preparation during degraded operation when store continuity requires it.

However, manual kitchen recovery must not allow staff to:

* Rewrite POS order history
* Change payment status
* Mark payment as complete
* Delete failed KDS tickets
* Overwrite KDS event history
* Convert uncertain state into verified state
* Close customer disputes
* Approve refunds
* Finalize settlement
* Hide duplicate preparation
* Treat Agent recommendation as execution authority

Manual kitchen recovery may produce only provisional kitchen execution state until reconciliation is completed.

---

## **5\. Recovery Trigger Conditions**

Manual kitchen recovery may be triggered when one or more of the following occur:

KDS\_TICKET\_MISSING
KDS\_TICKET\_DELAYED
KDS\_TICKET\_DUPLICATED
KDS\_STATE\_STALE
POS\_KDS\_HANDOFF\_FAILED
KDS\_BRIDGE\_UNAVAILABLE
AGENT\_VISIBILITY\_MISMATCH
NETWORK\_PARTITION
DEVICE\_FAILURE
KDS\_SCREEN\_UNAVAILABLE
KDS\_PRINTER\_UNAVAILABLE
POWER\_INTERRUPTION
CUSTOMER\_WAIT\_RISK
KITCHEN\_CONTINUITY\_REQUIRED

A trigger does not automatically authorize irreversible action.

The recovery actor must identify the trusted source and manual action taken.

---

## **6\. Manual Recovery States**

Manual kitchen recovery may use the following states:

RECOVERY\_NOT\_REQUIRED
RECOVERY\_TRIGGERED
MANUAL\_TICKET\_CREATED
MANUAL\_TICKET\_IN\_PROGRESS
MANUAL\_REMAKE\_REQUIRED
MANUAL\_REMAKE\_IN\_PROGRESS
WAITING\_RECONCILIATION
SOURCE\_CONFLICT\_REVIEW\_REQUIRED
RECONCILED
RECONCILED\_WITH\_EXCEPTION
HQ\_REVIEW\_REQUIRED
CLOSED

A recovery case must not move directly from `RECOVERY_TRIGGERED` to `CLOSED`.

It must pass through reconciliation or exception review.

---

## **7\. Trusted Source Rule**

During manual recovery, the staff must identify which source is being trusted.

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

If the trusted source is not system-originated, the recovery case must be marked:

HUMAN\_SOURCE\_DEPENDENT

If two or more sources conflict, the recovery case must be marked:

SOURCE\_CONFLICT\_REVIEW\_REQUIRED

---

## **8\. Manual Ticket Rule**

A manual kitchen ticket may be created only when kitchen execution cannot wait for system recovery.

The manual ticket must include at minimum:

store\_id
order\_reference
table\_or\_counter\_reference
created\_time
created\_by
trusted\_source
affected\_menu\_items
quantity
manual\_reason
kitchen\_station

If the original order reference is missing, the ticket must be marked:

ORDER\_REFERENCE\_MISSING

A manual ticket must not be treated as a normal KDS ticket.

It must carry:

MANUAL\_RECOVERY\_ORIGINATED

or:

FALLBACK\_ORIGINATED

---

## **9\. Remake Protection Rule**

Manual recovery must prevent unnecessary duplicate preparation.

Before a remake starts, staff should check:

* Whether the item was already prepared
* Whether another KDS screen received the ticket
* Whether a printed ticket already exists
* Whether the order was cancelled
* Whether payment is uncertain
* Whether the customer already received the item
* Whether another staff member already started recovery

If uncertainty remains, the recovery case must be marked:

DUPLICATE\_PREPARATION\_RISK

A remake performed under uncertainty must remain reviewable.

---

## **10\. Kitchen Hold Rule**

When payment, order identity, or ticket identity is uncertain, the system may place the kitchen ticket into:

PAYMENT\_HOLD
ORDER\_IDENTITY\_HOLD
SOURCE\_CONFLICT\_HOLD
MANAGER\_CONFIRMATION\_HOLD

Kitchen hold must be visible to staff.

A hold must not be hidden as a normal delay.

---

## **11\. Reconciliation Rule**

Manual kitchen recovery must be reconciled after the incident.

Reconciliation compares manual action against:

POS accepted order
payment status
KDS ticket events
KDS station events
KDS Bridge events
Agent anomaly events
customer order history
manual kitchen note
paper ticket
staff confirmation
customer recovery case
waste or remake record

Reconciliation appends a conclusion.

Reconciliation must not overwrite original degraded events.

---

## **12\. Reconciliation Outcomes**

Allowed reconciliation outcomes are:

MATCHED\_SYSTEM\_ORDER
MATCHED\_WITH\_DELAY
MATCHED\_WITH\_MANUAL\_ACTION
MATCHED\_WITH\_REMAKE
DUPLICATE\_PREPARATION\_CONFIRMED
MISSING\_ITEM\_CONFIRMED
PAYMENT\_UNCERTAIN
ORDER\_REFERENCE\_UNCERTAIN
SOURCE\_CONFLICT\_REMAINS
CUSTOMER\_RECOVERY\_REQUIRED
HQ\_REVIEW\_REQUIRED

If uncertainty remains after reconciliation, the case must not be closed as normal.

It must be marked:

RECONCILED\_WITH\_EXCEPTION

or:

HQ\_REVIEW\_REQUIRED

---

## **13\. Customer Impact Rule**

Manual kitchen recovery must classify customer impact.

Allowed classifications include:

NO\_VISIBLE\_IMPACT
MINOR\_DELAY
MAJOR\_DELAY
WRONG\_ITEM\_RISK
MISSING\_ITEM\_RISK
DUPLICATE\_ITEM\_RISK
CUSTOMER\_CONFIRMATION\_REQUIRED
CUSTOMER\_RECOVERY\_REQUIRED

Customer impact classification does not automatically approve compensation.

Compensation must follow a separate customer recovery policy.

---

## **14\. Payment Boundary**

Manual kitchen recovery must not determine payment truth.

If payment state is uncertain, the recovery case must be marked:

PAYMENT\_STATUS\_UNKNOWN

or:

PAYMENT\_CONFIRMATION\_REQUIRED

Kitchen may continue only if store policy allows manual continuation under manager confirmation.

Payment confirmation must be handled by POS Runtime, Payment Runtime, or authorized payment reconciliation process.

---

## **15\. Agent Boundary**

Agent may detect, alert, recommend, or summarize recovery risk.

Agent must not:

* Release kitchen tickets
* Approve payment
* Confirm refund
* Rewrite order status
* Close recovery case
* Convert uncertain state into verified state
* Discipline staff
* Hide manual fallback origin

Agent recommendation is not execution authority.

---

## **16\. Bridge Boundary**

KDS Bridge may relay events between POS, KDS, Agent, and customer display.

Bridge must not become the owner of kitchen truth or payment truth.

If Bridge is delayed, unavailable, or stale, recovery must be marked:

BRIDGE\_UNAVAILABLE

or:

BRIDGE\_STATE\_STALE

Bridge recovery must not silently merge manual actions into normal KDS history.

---

## **17\. Evidence Requirement**

Every manual kitchen recovery must create or link to an evidence packet.

The evidence packet should include:

recovery\_id
store\_id
order\_reference
ticket\_reference\_or\_reason\_missing
incident\_time
recovery\_time
recovery\_actor
trusted\_source
manual\_action\_taken
affected\_items
customer\_impact
reconciliation\_status
attachments\_or\_notes
audit\_event\_references

If evidence is incomplete, the recovery case must be marked:

EVIDENCE\_INCOMPLETE

Incomplete evidence does not block emergency kitchen continuity, but it prevents silent closure.

---

## **18\. Audit Requirements**

The system must create append-only audit events for:

recovery triggered
manual ticket created
manual remake started
manual remake completed
manual hold applied
manager confirmation requested
manager confirmation completed
evidence attached
reconciliation started
reconciliation completed
exception escalated
case closed

Audit events must be immutable.

Manual recovery records must not be deleted to hide operational failure.

---

## **19\. Prohibited Handling**

The following are prohibited:

* Treating manual ticket as normal KDS ticket
* Deleting failed KDS event after manual action
* Closing recovery case without reconciliation
* Hiding fallback-originated status
* Using staff memory alone as verified truth
* Combining multiple recovery cases into one vague record
* Marking payment as complete from kitchen recovery
* Allowing Agent to approve recovery
* Allowing Bridge to overwrite original ticket history
* Treating reconciliation as mutation
* Treating customer complaint dismissal as recovery resolution

---

## **20\. Store Staff Experience**

The staff-facing recovery flow should be simple.

Recommended store flow:

1\. Problem detected.
2\. Staff selects recovery reason.
3\. Staff selects trusted source.
4\. Staff enters or confirms affected items.
5\. Kitchen continues or holds.
6\. Evidence is attached.
7\. Manager confirms if needed.
8\. Reconciliation happens after incident.

The system should not require staff to understand internal event architecture during peak time.

The recovery interface must be fast, clear, and operationally usable.

---

## **21\. MVP Cutline**

For MVP, the system only needs to support:

manual recovery trigger
recovery reason selection
trusted source selection
manual action type selection
affected item record
fallback-originated flag
basic evidence note
reconciliation status
append-only audit event

Excluded from MVP:

AI recovery scoring
automatic duplicate detection across all devices
cross-store recovery benchmarking
full payment reconciliation automation
automatic customer compensation
advanced station-level replay

---

## **22\. Relationship To 04250**

This document defines when and how manual kitchen recovery is allowed.

Document 04250 defines the evidence packet structure required to support and review manual recovery.

The relationship is:

04240 \= recovery operation policy
04250 \= recovery evidence packet policy

Manual recovery without evidence packet linkage is not complete.

Evidence packet without recovery state linkage is not operationally useful.

---

## **23\. Readiness Check**

This policy is ready when:

manual kitchen recovery can be triggered quickly
manual tickets are distinguishable from normal KDS tickets
trusted source is captured
manual action is captured
duplicate preparation risk is visible
payment uncertainty does not become kitchen truth
reconciliation is required before closure
fallback-originated status is preserved
audit events are append-only
Agent recommendation does not become authority
Bridge relay does not become authority

---

## **24\. Summary**

Manual kitchen recovery exists because real stores cannot stop every time systems degrade.

However, recovery must not damage truth history.

The goal is to allow the kitchen to survive interruption while preserving the boundary between normal execution, degraded manual action, unresolved uncertainty, and verified reconciliation.

Manual recovery is continuity.

Reconciliation is truth restoration.

Audit is memory.
