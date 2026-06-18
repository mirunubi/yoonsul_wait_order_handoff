# 004320_Policy_POS_Adapter_Capability_Level_And_Integration_Contract

## **1\. Purpose**

This document defines the POS adapter capability level and integration contract policy.

The purpose of this policy is to classify each POS provider integration by what the adapter can safely observe, synchronize, control, or reconcile.

The system must not assume that every POS provider supports the same level of integration.

Some POS providers may support only manual entry or read-only intake.

Some may support webhook-based order and payment events.

Some may support deeper bidirectional authority integration.

Each integration must be explicitly classified before it is used by Payment Runtime, KDS Runtime, Customer Display Runtime, Agent Runtime, Audit Runtime, or Reconciliation Runtime.

---

## **2\. Scope**

This policy applies to:

* POS provider adapter capability classification
* POS read-only order intake
* POS webhook or polling-based event synchronization
* POS payment status synchronization
* POS order update synchronization
* POS cancellation and void synchronization
* POS-to-KDS handoff capability
* POS authority-level integration
* Legacy POS limited integration
* Manual fallback POS operation
* Provider onboarding contract
* Adapter reliability classification
* Integration readiness review

This policy does not define commercial pricing, vendor negotiation, payment fee rates, settlement allocation, refund approval, tax filing, or legal dispute handling.

---

## **3\. Core Principle**

Integration capability must be explicit.

The system must not treat a weak integration as a strong integration.

The core rule is:

visibility level must match capability level
authority level must match contract level
automation level must match verification level

A POS adapter that can only read orders must not be allowed to modify orders.

A POS adapter that receives delayed polling data must not be treated as real-time authority.

A POS adapter that relies on staff confirmation must not be treated as provider-verified.

---

## **4\. Capability Level Overview**

POS integrations must be classified into one of the following levels:

LEVEL\_0\_MANUAL\_OR\_NO\_API
LEVEL\_1\_READ\_ONLY\_INTAKE
LEVEL\_2\_EVENT\_SYNC
LEVEL\_3\_OPERATIONAL\_AUTHORITY\_INTEGRATION
LEVEL\_4\_CERTIFIED\_DEEP\_INTEGRATION

Each level defines what the system may safely do.

MVP should target Level 1 and Level 2 first.

Level 3 and Level 4 require stronger contracts, testing, audit, rollback, and vendor cooperation.

---

## **5\. Level 0: Manual Or No API**

Level 0 means the POS has no usable API or no integration agreement.

Allowed actions:

manual order entry
manual receipt reference entry
staff-confirmed payment note
paper ticket reference
manual kitchen note
basic evidence packet

Required flags:

LEVEL\_0\_MANUAL\_OR\_NO\_API
HUMAN\_SOURCE\_DEPENDENT
SOURCE\_CONFIDENCE\_LOW
RECONCILIATION\_REQUIRED

Level 0 must not be represented as automated POS integration.

---

## **6\. Level 1: Read-Only Intake**

Level 1 means the adapter can read or receive order data but cannot safely write back to the POS.

Allowed actions:

read POS order
read item list
read order amount
read table reference
read receipt reference
create internal projection
send normalized order to internal KDS projection
show customer or staff visibility
create audit record

Prohibited actions:

update POS order
cancel POS order
change POS payment state
approve refund
change table assignment in POS
mark POS order complete

Required flags:

LEVEL\_1\_READ\_ONLY\_INTAKE
POS\_WRITE\_NOT\_ALLOWED

Level 1 is useful for visibility and KDS projection, but it is not POS authority integration.

---

## **7\. Level 2: Event Synchronization**

Level 2 means the adapter can receive or poll provider events and synchronize status into the internal system.

Allowed actions:

receive order created event
receive order updated event
receive payment status event
receive cancellation event
receive table movement event
receive item void event
sync customer display projection
sync KDS projection
create conflict flags
create reconciliation records

Conditional actions:

limited acknowledgement to provider
limited status sync if provider contract allows

Prohibited actions unless explicitly contracted:

create POS order from internal system
force payment completion
force refund
force cancellation
override provider order state

Required flags:

LEVEL\_2\_EVENT\_SYNC
EVENT\_SYNC\_ENABLED
AUTHORITY\_WRITE\_LIMITED

Level 2 is the recommended early SaaS integration target.

---

## **8\. Level 3: Operational Authority Integration**

Level 3 means the adapter can perform authority-level operations under a formal integration contract.

Allowed actions may include:

create POS order
update POS order
cancel POS order
sync payment status
trigger kitchen release
confirm order acceptance
apply approved void
write operational status back to POS

Requirements:

provider contract
idempotency guarantee
webhook verification
retry policy
rollback or compensation policy
audit event mapping
test environment
certification scenario
permission scope review

Level 3 must not be enabled by default.

Each provider and store must be explicitly approved.

---

## **9\. Level 4: Certified Deep Integration**

Level 4 means the integration is certified, tested, versioned, monitored, and approved for high-confidence automation.

Allowed features may include:

bidirectional order lifecycle sync
payment state authority synchronization
KDS lifecycle synchronization
menu sync
inventory sold-out sync
refund event sync
settlement event handoff
device health monitoring
provider outage detection
certified replay and recovery

Requirements:

vendor certification
production monitoring
versioned integration contract
SLA or operational expectation
security review
data protection review
failure-mode testing
certified reconciliation workflow

Level 4 is not MVP.

Level 4 is a long-term SaaS scaling target.

---

## **10\. Capability Matrix**

Each POS provider must be assessed against a capability matrix.

Required capability categories include:

order intake
order update
payment status
cancellation
void
refund visibility
table reference
menu item mapping
modifier mapping
discount mapping
tax mapping
KDS handoff
webhook support
polling support
raw payload access
test environment
credential scope
rate limit
outage signal
replay support

Each category should be marked as:

SUPPORTED
PARTIALLY\_SUPPORTED
NOT\_SUPPORTED
UNKNOWN
REQUIRES\_VENDOR\_CONFIRMATION

---

## **11\. Integration Contract Definition**

An integration contract defines what is allowed between the external POS provider and the internal system.

The contract should specify:

provider\_name
provider\_version
integration\_level
allowed\_read\_operations
allowed\_write\_operations
webhook\_events
polling\_events
idempotency\_key\_rule
retry\_policy
rate\_limit
credential\_scope
data\_retention\_rule
raw\_payload\_policy
reconciliation\_policy
fallback\_policy
support\_contact
adapter\_version
certification\_status

No adapter should run in production without an explicit integration contract record.

---

## **12\. Read Operations**

Read operations may include:

read order
read order list
read order detail
read payment status
read receipt status
read table status
read menu data
read item options
read cancellation status
read provider event log

Read access does not imply write authority.

Read access does not imply payment authority.

Read access does not imply KDS release authority.

---

## **13\. Write Operations**

Write operations may include:

create order
update order
cancel order
void item
confirm payment
mark order complete
send kitchen status
send table status
send pickup status

Every write operation must be explicitly allowed by integration contract.

If a write operation is not listed, it is prohibited.

---

## **14\. Payment Authority Contract**

Payment authority must be separately classified.

Payment capability levels may include:

PAYMENT\_VISIBILITY\_ONLY
PAYMENT\_STATUS\_SYNC
PAYMENT\_PROVIDER\_VERIFIED
PAYMENT\_AUTHORITY\_WRITE\_ALLOWED
PAYMENT\_RECONCILIATION\_REQUIRED

POS payment status and Payment Runtime status may differ.

If they conflict, the system must mark:

PAYMENT\_STATUS\_CONFLICT

and require reconciliation.

---

## **15\. KDS Authority Contract**

KDS authority must be separately classified.

KDS capability levels may include:

KDS\_VISIBILITY\_ONLY
KDS\_PROJECTION\_ALLOWED
KDS\_RELEASE\_EVENT\_ALLOWED
KDS\_STATUS\_SYNC\_ALLOWED
KDS\_AUTHORITY\_WRITE\_ALLOWED

A POS provider may allow order read but not KDS status sync.

The system must not assume KDS write authority from order read authority.

---

## **16\. Menu Mapping Capability**

Menu mapping capability must be assessed separately.

Levels may include:

MENU\_NOT\_AVAILABLE
MENU\_READ\_ONLY
MENU\_ITEM\_MAPPING\_ONLY
MENU\_OPTION\_MAPPING\_SUPPORTED
MENU\_BUNDLE\_MAPPING\_SUPPORTED
MENU\_SYNC\_SUPPORTED
MENU\_SOLDOUT\_SYNC\_SUPPORTED

If menu mapping is weak, the system may still show orders, but KDS execution quality may require manual review.

Unknown items must be flagged.

---

## **17\. Table And Session Capability**

Table capability must be assessed separately.

Levels may include:

TABLE\_NOT\_SUPPORTED
TABLE\_NAME\_ONLY
TABLE\_ID\_SUPPORTED
TABLE\_MOVE\_EVENT\_SUPPORTED
TABLE\_MERGE\_SPLIT\_SUPPORTED
SEATING\_SESSION\_SUPPORTED

Table identity must not be assumed from table name alone when split or merged tables exist.

---

## **18\. Webhook Capability**

Webhook capability must be documented.

Required webhook details include:

event\_types\_supported
signature\_verification\_method
retry\_policy
duplicate\_delivery\_behavior
delivery\_timeout
event\_ordering\_guarantee
test\_webhook\_support
webhook\_secret\_rotation

If webhook ordering is not guaranteed, the adapter must support chronology uncertainty.

---

## **19\. Polling Capability**

If webhook is unavailable, polling may be used.

Polling capability must document:

polling\_interval
rate\_limit
query\_window
event\_loss\_risk
latency\_expectation
provider\_status\_endpoint
backfill\_support

Polling-based integration must not be marketed as real-time unless the latency is operationally acceptable and disclosed.

---

## **20\. Source Confidence By Capability Level**

Default source confidence may be assigned by integration level.

Suggested default mapping:

Level 0 \-\> MANUAL\_ENTRY or STAFF\_CONFIRMED
Level 1 \-\> PROVIDER\_EXPORT or PROVIDER\_API\_POLL
Level 2 \-\> PROVIDER\_WEBHOOK or PROVIDER\_API\_POLL
Level 3 \-\> PROVIDER\_VERIFIED
Level 4 \-\> PROVIDER\_VERIFIED\_CERTIFIED

Source confidence may be lowered if provider outage, mapping failure, or chronology uncertainty occurs.

---

## **21\. Capability Downgrade Rule**

A provider integration may be downgraded temporarily.

Downgrade triggers include:

webhook failure
polling failure
credential failure
provider outage
mapping version conflict
signature verification failure
high duplicate event rate
chronology uncertainty
contract expiration
security incident

Downgraded integration must be marked:

INTEGRATION\_CAPABILITY\_DOWNGRADED

and may require fallback policy.

---

## **22\. Capability Upgrade Rule**

A provider integration may be upgraded only after review.

Upgrade requirements may include:

successful test cases
vendor confirmation
credential scope review
idempotency verification
webhook retry verification
payment status verification
cancellation scenario test
conflict scenario test
security review
audit review
store pilot result

An adapter must not self-upgrade based only on successful runtime behavior.

---

## **23\. Store-Level Capability Override**

A provider may support high-level integration, but a specific store may not.

Store-level constraints may include:

old terminal
different POS version
disabled API feature
limited merchant contract
network limitation
franchise policy limitation
missing credential
unsupported menu structure

Therefore integration capability must be tracked by:

provider
tenant
store
terminal
adapter version
contract version

not only by provider name.

---

## **24\. Fallback Requirement**

Every integration level must define fallback behavior.

Fallback may include:

manual order entry
read-only projection
customer mobile payment link
manual kitchen ticket
manual payment confirmation
evidence packet
post-incident reconciliation

Fallback-originated events must be marked:

FALLBACK\_ORIGINATED

Fallback must not pretend to be normal provider integration.

---

## **25\. Security Requirement**

Integration contracts must define credential scope.

Required security controls include:

least privilege credential
store-scoped access where possible
tenant-scoped isolation
webhook secret verification
credential rotation policy
access logging
provider permission review
production/test credential separation

A provider credential must not grant broader authority than the integration level requires.

---

## **26\. Audit Requirements**

The system must create append-only audit events for:

integration contract created
integration contract updated
adapter enabled
adapter disabled
capability level assigned
capability level downgraded
capability level upgraded
provider credential added
provider credential rotated
read operation performed
write operation performed
write operation blocked
webhook verified
webhook verification failed
polling failed
fallback activated
reconciliation required

Audit must link:

provider
tenant
store
adapter version
integration level
contract version
operation type
authority scope

---

## **27\. MVP Cutline**

For MVP, the system should support:

integration level classification
Level 0 manual mode
Level 1 read-only intake
Level 2 event sync target model
integration contract record
read/write permission boundary
payment authority flag
KDS authority flag
webhook capability flag
polling capability flag
source confidence mapping
capability downgrade flag
audit event creation

Excluded from MVP:

full Level 3 authority integration
Level 4 certification program
automatic vendor certification
multi-provider commercial contract automation
advanced SLA monitoring
automatic capability upgrade
deep POS terminal inventory
full security certification workflow

---

## **28\. Relationship To 04300 And 04310**

Document 04300 defines the POS Provider Abstraction and Multi-POS Adapter boundary.

Document 04310 defines the Canonical Order Model and POS Event Normalization policy.

This document defines how each POS adapter is classified by capability and what the integration contract allows.

The relationship is:

04300 \= adapter layer exists
04310 \= adapter output becomes canonical order model
04320 \= adapter capability and contract define what is allowed

Without 04320, the system may accidentally give too much authority to a weak adapter.

---

## **29\. Readiness Check**

This policy is ready when:

each POS provider has a capability level
each store integration has a contract record
read and write operations are separated
payment authority is classified separately
KDS authority is classified separately
webhook capability is documented
polling capability is documented
source confidence follows capability level
downgrade conditions are defined
fallback behavior is defined
credentials match authority scope
audit records integration authority changes

---

## **30\. Summary**

Not all POS integrations are equal.

A multi-POS SaaS system must know exactly what each adapter can and cannot do.

The system must distinguish:

manual visibility
read-only intake
event synchronization
operational authority
certified deep integration

Only then can Payment Runtime, KDS Runtime, Customer Display Runtime, Agent Runtime, Audit Runtime, and Reconciliation Runtime safely operate across many POS environments.

The goal is not to connect to every POS recklessly.

The goal is to connect to many POS systems with explicit capability, authority, fallback, and audit boundaries.
