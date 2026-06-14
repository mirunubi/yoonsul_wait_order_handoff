# 00030_Runtime_Boundary

1\. Purpose

This document defines the runtime ownership boundary of the yoonsul\_wait\_order\_handoff project.

The purpose is to prevent wait\_order\_handoff from expanding into POS, KDS, payment, inventory, external membership, or full store operation systems.

wait\_order\_handoff must remain a handoff runtime.

It carries prepared customer/order context from waiting to store execution.

2\. Core Definition

wait\_order\_handoff is not a POS.

wait\_order\_handoff is not a full KDS.

wait\_order\_handoff is not a payment system.

wait\_order\_handoff is not an inventory system.

wait\_order\_handoff is not an external membership ledger.

wait\_order\_handoff is a runtime ledger that connects:

waiting
customer arrival
prepared order context
staff confirmation
seating
POS handoff
KDS handoff
benefit routing candidate
external handoff status

Core statement:

«wait\_order\_handoff does not replace store execution systems.
It carries customer/order context created during waiting and hands it off to staff, POS, KDS, or external systems according to store capability.»

3\. Jarijjim And wait\_order\_handoff

Jarijjim is the customer-facing service name.

wait\_order\_handoff is the runtime/project name.

Jarijjim may include:

customer app
customer webapp
QR entry
menu board
waiting registration
menu pre-selection
show-to-staff screen
benefit candidate display

wait\_order\_handoff includes:

wait\_order core
store capability stage policy
store console
staff handoff
handoff payload
POS/KDS adapter boundary
benefit routing boundary
external integration boundary

Jarijjim is the service experience.

wait\_order\_handoff is the operational runtime.

4\. What wait\_order Core Owns

wait\_order Core owns the following runtime contexts.

4.1 Waiting Context

Examples:

wait\_order\_session\_id
store\_id
customer\_display\_token
party\_size
waiting\_status
registered\_at
called\_at
cancelled\_at
no\_show\_marked\_at

4.2 Arrival Context

Examples:

arrival\_status
arrival\_confirmed\_at
arrival\_source
staff\_confirmed\_arrival

4.3 Seating Context

Examples:

seating\_status
seating\_requested
table\_context
seated\_at
staff\_confirmed\_seating

4.4 Prepared Order Context

Examples:

prepared\_order\_id
prepared\_order\_items
item\_options
allergy\_flags
special\_requests
language\_summary
order\_prep\_status
store\_confirm\_required

Prepared order context does not equal confirmed POS order.

4.5 Staff Confirmation Context

Examples:

staff\_confirmed
staff\_confirmed\_at
staff\_user\_id
confirmation\_type
staff\_note

4.6 Handoff Context

Examples:

handoff\_status
handoff\_channel
handoff\_location
recipient\_type
manual\_pos\_handoff\_status
pos\_handoff\_status
kds\_handoff\_status
external\_handoff\_status

4.7 External Reference Context

Examples:

external\_pos\_reference
external\_kds\_reference
external\_system\_type
external\_received\_status
external\_failed\_reason
last\_synced\_at

4.8 Benefit Candidate Context

Examples:

benefit\_candidate\_status
benefit\_routing\_status
claim\_token\_status
duplicate\_guard\_status
identity\_link\_status

wait\_order may carry benefit routing context, but it does not become the membership ledger.

5\. What wait\_order Core Does Not Own

5.1 POS Transaction Authority

wait\_order Core does not own:

official POS order
payment confirmation
sales ledger
cash/card approval
refund execution
settlement
tax receipt
POS cancellation

POS remains the transaction authority.

5.2 Full KDS Execution Authority

wait\_order Core does not own:

kitchen ticket authority
kitchen line assignment
production task splitting
production priority
cooking start authority
ready judgment
production merge
kitchen completion truth

KDS remains the kitchen execution authority.

5.3 Inventory Authority

wait\_order Core does not own:

stock deduction
real-time inventory truth
ingredient reservation
sold-out propagation authority
purchase order
supplier stock
waste adjustment

Inventory or store production systems own inventory truth.

5.4 Payment Authority

wait\_order Core does not own:

payment approval
payment capture
payment cancellation
refund
chargeback
settlement
cash reconciliation

Payment provider or POS owns payment authority.

5.5 External Membership Ledger

wait\_order Core does not own:

tenant membership point ledger
external coupon ledger
external membership rank
external customer account
white label customer master
tenant wallet

External membership systems remain owned by the tenant or external system.

6\. Boundary By Store Capability Stage

6.1 Stage 0 Boundary

Stage 0 is menu-board only.

wait\_order\_session is not created.

No waiting, POS, KDS, or benefit routing runtime is activated.

6.2 Stage 1 Boundary

Stage 1 supports manual POS handoff.

wait\_order carries waiting and prepared order context to staff.

Staff manually enters the order into POS.

wait\_order does not create POS order.

6.3 Stage 2 Boundary

Stage 2 adds Mini KDS or kitchen assistance.

POS remains manual.

Mini KDS is a lightweight support screen.

Mini KDS does not become full KDS authority.

6.4 Stage 3 Boundary

Stage 3 adds POS Adapter.

wait\_order may send prepared order context to POS and store POS reference.

POS remains transaction authority.

KDS is absent, POS-owned, external, or indirectly observed.

6.5 Stage 4 Boundary

Stage 4 adds POS \+ KDS integrated handoff.

wait\_order may send context to POS and KDS and receive returned statuses.

POS remains transaction authority.

KDS remains kitchen execution authority.

wait\_order does not own internal KDS production logic.

6.6 Stage 5 Boundary

Stage 5 adds SaaS, white label, external membership, and benefit routing.

wait\_order may evaluate benefit routing candidates, issue claim tokens, and call external connectors.

wait\_order does not forcibly merge identities.

wait\_order does not become the tenant membership ledger.

7\. Mini Kiosk Boundary

Mini Kiosk is a customer-facing lightweight ordering-preparation UI.

Mini Kiosk may support:

QR menu
multilingual menu
menu pre-selection
allergy/request input
show-to-staff screen
handoff channel selection
store-confirm-required notice

Mini Kiosk must not imply:

payment completed
POS order confirmed
kitchen started
benefit claimed
membership updated

unless such status is returned by the responsible external system.

8\. Mini KDS Boundary

Mini KDS is a lightweight kitchen/staff support screen.

Mini KDS may support:

prepared order queue
simple kitchen grouping
allergy/request highlight
manual kitchen acknowledgment
manual ready check
handoff channel grouping
fallback operation

Mini KDS must not be treated as full KDS unless separately promoted and governed as a full KDS product.

Mini KDS does not own:

official kitchen ticket truth
production task authority
production priority algorithm
inventory deduction
POS transaction state

9\. Adapter Boundary

Adapters are handoff connectors.

They do not transfer ownership to wait\_order.

9.1 POS Adapter

POS Adapter may:

send order context to POS
receive POS reference
receive success/failure status
support retry
support manual fallback

POS Adapter must not:

treat wait\_order as POS
finalize payment independently
override POS state
silently duplicate orders

9.2 KDS Adapter

KDS Adapter may:

send kitchen handoff context
receive KDS reference
receive visible/accepted/ready/completed status
support retry
support manual fallback

KDS Adapter must not:

own kitchen production logic
override KDS priority
force cooking start
mark final readiness without KDS/store authority

9.3 Membership Adapter

Membership Adapter may:

send claim token
request benefit claim
receive external claim result
record duplicate guard result
defer failed claims

Membership Adapter must not:

merge identities without consent
mutate external membership without policy
own external point ledger
bypass duplicate guard

10\. Event And Audit Boundary

wait\_order must record important runtime events.

Examples:

waiting\_registered
customer\_called
arrival\_confirmed
seating\_confirmed
prepared\_order\_created
prepared\_order\_updated
store\_confirm\_required
staff\_confirmed\_order
manual\_pos\_handoff\_started
manual\_pos\_handoff\_completed
pos\_adapter\_sent
pos\_adapter\_failed
kds\_adapter\_sent
kds\_adapter\_failed
mini\_kds\_acknowledged
handoff\_completed
benefit\_candidate\_detected
claim\_token\_issued
external\_claim\_deferred
duplicate\_guard\_triggered

Events describe what happened.

Events do not automatically imply legal, payment, inventory, or membership truth unless confirmed by the responsible system.

11\. Fallback Boundary

Fallback is allowed.

Silent downgrade is prohibited.

Examples:

POS Adapter failure
→ Stage 1 manual POS handoff

KDS Adapter failure
→ Stage 2 Mini KDS or manual kitchen handoff

External membership failure
→ claim deferred

Mini KDS unavailable
→ Staff Handoff screen and staff memo

Every fallback must create an event log.

12\. Design Rules

Do not make wait\_order Core a POS.

Do not make wait\_order Core a full KDS.

Do not make wait\_order Core an inventory ledger.

Do not make wait\_order Core a payment ledger.

Do not make wait\_order Core an external membership ledger.

Do not collapse prepared order context into confirmed POS order.

Do not collapse customer request into store acceptance.

Do not collapse KDS visible status into kitchen completed status.

Do not collapse benefit candidate into benefit claimed.

13\. Final Boundary Statement

wait\_order\_handoff is the handoff runtime between customer waiting and store execution.

It carries context.

It records handoff status.

It supports manual, adapter, Mini Kiosk, Mini KDS, POS/KDS, and SaaS benefit routing paths according to store capability.

It does not replace the systems that own transaction, kitchen execution, payment, inventory, or external membership truth.
