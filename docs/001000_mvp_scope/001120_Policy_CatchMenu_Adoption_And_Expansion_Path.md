# 001120_Policy_CatchMenu_Adoption_And_Expansion_Path.md

Legacy path: $old.

1\. Purpose

This document defines how merchants adopt CatchMenu by stage and how they may migrate from one stage to another.

CatchMenu must not require every merchant to start with full POS/KDS integration.

The adoption model must allow small stores, POS-less stores, low-IT stores, foreign-guest-heavy stores, and future franchise/SaaS stores to enter at different levels.

Core purpose:

Let merchants start light.
Let the system expand safely.
Do not force integration before the store is ready.

Korean purpose:

업주는 가볍게 시작할 수 있어야 한다.
시스템은 단계적으로 확장되어야 한다.
매장이 준비되기 전에 POS/KDS 연동을 강제하지 않는다.

2\. Core Principle

CatchMenu adoption should be stage-based, not all-or-nothing.

Core rule:

Adoption stage defines what the merchant uses now.
Module set defines what the system enables.
Migration path defines what the merchant may add later.

A merchant may begin with:

QR menu only
show-to-staff view
owner web console
POS-less confirmation board
manual POS handoff
kitchen assist
POS adapter
KDS adapter
SaaS/franchise integration

The system must preserve a migration path without forcing premature complexity.

3\. Adoption Stage Overview

Suggested adoption stages:

Stage 0A \= Multilingual QR Menu \+ Show-to-Staff View
Stage 0B \= Menu Request Sent to Store Owner Web Console
Stage 0C \= POS-less Simple Request Confirmation Board
Stage 1  \= Waiting \+ Manual POS Handoff
Stage 2  \= Mini KDS / Kitchen Assist
Stage 3  \= POS Adapter
Stage 4  \= POS \+ KDS Adapter
Stage 5  \= SaaS / Franchise / Benefit Routing Integration

Each stage must have:

merchant value
required modules
optional modules
disabled modules
operational risk
migration requirement
rollback path

4\. Stage 0A Adoption

4.1 Definition

Stage 0A is the lightest CatchMenu adoption stage.

The guest scans a QR code, views a multilingual menu, selects items, and shows the selected menu to staff.

No request is sent to the store system.

4.2 Merchant Fit

Stage 0A is suitable for:

small restaurants
foreign-guest-heavy stores
stores without POS integration
stores testing digital menu demand
stores with limited staff IT capability
temporary popup stores
market validation

4.3 Required Modules

QR Menu Module
I18n Translation Module
Show-to-Staff Module
Menu Content Module

4.4 Disabled Modules

Send-to-Store Module
Owner Web Console Module
POS-less Request Confirmation Module
Waiting Module
POS Adapter
KDS Adapter
Payment Integration
Benefit Routing

4.5 Migration Path

Stage 0A may migrate to Stage 0B when the merchant wants to receive requests digitally.

Migration requirement:

store owner web console setup
basic request receiving flow
store language summary
request disclaimer

5\. Stage 0B Adoption

5.1 Definition

Stage 0B allows the guest to send a menu request to the store owner web console.

This is not POS integration.

This is not a confirmed paid order.

5.2 Merchant Fit

Stage 0B is suitable for:

stores that want digital request receiving
stores that still use manual POS
stores with many foreign guests
stores that want staff Korean summary
stores that want low-cost operational improvement

5.3 Required Modules

QR Menu Module
I18n Translation Module
Send-to-Store Module
Owner Web Console Module
Support Signal Module

5.4 Optional Modules

Notification Option
SMS/Kakao Option
Owner Mobile Notification Option
Basic Request Analytics

5.5 Migration Path

Stage 0B may migrate to Stage 0C when the merchant wants a simple order confirmation board without POS integration.

Migration requirement:

request status model
store confirmation action
guest edit lock after confirmation
unconfirmed request warning
forced cleanup threshold
auto-completion policy

6\. Stage 0C Adoption

6.1 Definition

Stage 0C provides a POS-less simple request confirmation board.

The merchant can confirm that a guest request was seen.

The merchant may optionally mark the request as completed.

Stage 0C is not POS.

Stage 0C is not payment ledger.

Stage 0C is not sales settlement authority.

6.2 Merchant Fit

Stage 0C is suitable for:

stores without POS integration
stores that want lightweight request tracking
stores that need foreign guest support
stores that want fewer missed requests
stores that cannot install full KDS/POS integration yet

6.3 Required Modules

QR Menu Module
I18n Translation Module
Send-to-Store Module
Owner Web Console Module
POS-less Request Confirmation Module
Support Signal Module
Evidence Packet Module

6.4 Critical Rule

Confirmed requests may be auto-completed.
Unconfirmed requests must not be auto-completed as completed orders.

Korean rule:

매장이 확인한 요청만 자동 완료 후보가 될 수 있다.
미확인 요청은 완료 주문으로 자동 처리하면 안 된다.

6.5 Migration Path

Stage 0C may migrate to Stage 1 when the store wants waiting and manual POS handoff.

Migration requirement:

waiting identity
arrival status
manual POS handoff marker
staff handoff view
request-to-POS manual transfer policy
handoff failure support signal

7\. Stage 1 Adoption

7.1 Definition

Stage 1 adds waiting and manual POS handoff.

CatchMenu helps bridge guest intent to staff/POS operation, but the POS is still manually operated by staff.

7.2 Merchant Fit

Stage 1 is suitable for:

busy stores with waiting guests
stores where guests choose menu before seating
stores that want to reduce order delay
stores that still cannot connect POS directly
stores that want staff handoff support

7.3 Required Modules

Waiting Module
Manual POS Handoff Module
Owner Web Console Module
Staff Handoff View
Evidence Packet Module
Support Signal Module

7.4 Optional Modules

Arrival Confirmation
Table Assignment Assist
Manual Payment Status Marker
Basic Kitchen Memo
Benefit Candidate Marker

7.5 Migration Path

Stage 1 may migrate to Stage 2 when the merchant wants kitchen-facing request visibility.

Migration requirement:

kitchen assist display
preparation status
manual completion flow
kitchen memo policy
no POS authority rule

8\. Stage 2 Adoption

8.1 Definition

Stage 2 adds Mini KDS or Kitchen Assist.

This helps kitchen staff see requested items or preparation context.

Stage 2 must not become full POS/KDS authority unless Stage 3 or Stage 4 is adopted.

8.2 Merchant Fit

Stage 2 is suitable for:

stores with kitchen bottlenecks
stores with manual POS but kitchen display need
stores wanting lightweight preparation visibility
stores testing KDS-style flow before full integration

8.3 Required Modules

Kitchen Assist Module
Manual Completion Module
Kitchen Memo Module
Support Signal Module
Evidence Packet Module

8.4 Boundary

Stage 2 kitchen assist is not final KDS authority.

Core rule:

Kitchen Assist shows preparation context.
It does not own POS transaction state.
It does not own final order ledger.

8.5 Migration Path

Stage 2 may migrate to Stage 3 when POS adapter integration is needed.

Migration requirement:

POS vendor identification
POS adapter contract
handoff state mapping
retry policy
adapter failure policy
support-safe POS reference

9\. Stage 3 Adoption

9.1 Definition

Stage 3 adds POS Adapter integration.

CatchMenu may send or synchronize selected request/order information to the POS through an approved adapter.

9.2 Merchant Fit

Stage 3 is suitable for:

stores with supported POS vendor
stores needing reduced manual POS input
stores with higher order volume
stores with staff bottleneck at order entry
stores preparing for chain or franchise operation

9.3 Required Modules

POS Adapter Module
POS Handoff State Module
Retry Policy Module
Adapter Failure Signal Module
Evidence Packet Module
Gateway Access Log Module

9.4 Boundary

POS remains transaction authority.

CatchMenu must not silently rewrite POS transaction state.

Core rule:

POS owns transaction authority.
CatchMenu owns handoff context and support evidence.

9.5 Migration Path

Stage 3 may migrate to Stage 4 when KDS adapter integration is also needed.

Migration requirement:

KDS vendor identification
POS-KDS state alignment
handoff reconciliation
kitchen execution state mapping
failure containment policy

10\. Stage 4 Adoption

10.1 Definition

Stage 4 adds POS \+ KDS Adapter integration.

This allows CatchMenu to support a more complete waiting-to-order-to-kitchen handoff path.

10.2 Merchant Fit

Stage 4 is suitable for:

high-volume stores
chain stores
stores with POS/KDS infrastructure
stores needing kitchen visibility
stores needing handoff failure monitoring
franchise pilot stores

10.3 Required Modules

POS Adapter Module
KDS Adapter Module
Handoff Reconciliation Module
Kitchen Status Mapping Module
Adapter Failure Signal Module
Evidence Packet Module
Support Gateway Module

10.4 Boundary

POS and KDS authority must remain clear.

Core rules:

POS owns transaction state.
KDS owns kitchen execution state.
CatchMenu owns guest intent, handoff context, support evidence, and integration trace.

CatchMenu must not pretend to be POS or KDS.

10.5 Migration Path

Stage 4 may migrate to Stage 5 when the merchant is part of SaaS, franchise, benefit routing, or white-label integration.

Migration requirement:

tenant boundary
store boundary
benefit routing
external membership connector
white-label link policy
HQ support visibility
audit and evidence standardization

11\. Stage 5 Adoption

11.1 Definition

Stage 5 connects CatchMenu to SaaS, franchise, benefit routing, white-label, or external membership systems.

Stage 5 is not merely a technical integration stage.

It is a multi-tenant operating model.

11.2 Merchant Fit

Stage 5 is suitable for:

franchise brands
multi-store operators
SaaS tenants
white-label partners
brands with membership systems
brands needing benefit routing
brands needing HQ support visibility

11.3 Required Modules

Tenant Boundary Module
Store Boundary Module
Benefit Routing Module
External Membership Connector Module
White Label Link Module
HQ Support View Module
Audit Module
Evidence Packet Module
Support Gateway Module

11.4 Boundary

Stage 5 must preserve identity separation.

Core rule:

CatchMenu guest identity, tenant membership identity, and external membership identity must not be silently merged.

Benefit routing must be explicit, traceable, and reversible.

12\. Upgrade Rule

A merchant may upgrade stage when the required module readiness is satisfied.

Upgrade must not be treated as a simple feature toggle.

Each upgrade should check:

merchant readiness
staff readiness
device readiness
menu data readiness
support readiness
fallback readiness
evidence readiness
integration readiness
rollback path

Core rule:

Upgrade requires operational readiness, not only technical availability.

13\. Downgrade And Rollback Rule

A merchant may need to downgrade or rollback a stage.

Examples:

POS adapter unstable
KDS adapter unavailable
owner console device failure
staff not ready
foreign guest workflow confusion
support burden too high
merchant requests simpler flow

Rollback must be supported.

Example rollback paths:

Stage 4 → Stage 3: disable KDS adapter, keep POS handoff
Stage 3 → Stage 1: disable POS adapter, return to manual POS handoff
Stage 1 → Stage 0C: disable waiting, keep request confirmation
Stage 0C → Stage 0B: disable confirmation board, keep request receive
Stage 0B → Stage 0A: disable send-to-store, keep QR menu

Rollback must preserve historical evidence.

Rollback must not delete prior events.

14\. Stage-Specific Failure Containment

Each stage must fail within its own boundary.

Examples:

Stage 0A QR failure must not affect POS.
Stage 0B send-to-store failure must not corrupt menu data.
Stage 0C confirmation board failure must not create completed orders.
Stage 1 manual POS handoff failure must not mutate POS state.
Stage 2 kitchen assist failure must not become KDS authority.
Stage 3 POS adapter failure must not silently retry without trace.
Stage 4 KDS adapter failure must not overwrite kitchen execution history.
Stage 5 benefit routing failure must not silently grant or remove benefits.

Failure/error naming and diagnostic hierarchy are governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

15\. Stage Adoption Record

The system should record the merchant's current adoption stage.

Suggested fields:

tenant\_id
store\_id
current\_stage
enabled\_modules
disabled\_modules
optional\_modules
stage\_started\_at
stage\_changed\_by
stage\_change\_reason
previous\_stage
rollback\_allowed
support\_notes
created\_at
updated\_at

Stage history should be append-only.

16\. Stage Migration Event

Each migration should create an event.

Suggested event types:

STAGE\_UPGRADE\_REQUESTED
STAGE\_UPGRADE\_APPROVED
STAGE\_UPGRADE\_APPLIED
STAGE\_UPGRADE\_FAILED
STAGE\_ROLLBACK\_REQUESTED
STAGE\_ROLLBACK\_APPLIED
STAGE\_ROLLBACK\_FAILED
MODULE\_ENABLED
MODULE\_DISABLED
INTEGRATION\_READY
INTEGRATION\_FAILED

Each event should preserve:

previous\_stage
target\_stage
reason
operator
module\_changes
readiness\_check\_result
fallback\_plan
evidence\_ref
created\_at

17\. Merchant Communication Policy

Merchant-facing explanation should use package language, not internal module language.

Example:

Internal:
Stage 0C POS-less Request Confirmation Board

Merchant-facing:
간단 주문 확인판

Example:

Internal:
Stage 3 POS Adapter

Merchant-facing:
POS 입력 보조 / POS 연동 패키지

The merchant should understand:

what changes
what does not change
what staff must do
what happens when it fails
how to rollback

18\. Guest Communication Policy

Guest-facing communication must remain simple.

Guests should not see:

stage number
adapter
runtime
gateway
tenant
evidence packet
POS/KDS integration state

Guests may see:

menu view
request sent
store confirmed
please ask staff
pay at store
request locked after store confirmation

19\. Support Readiness

Before a merchant moves to a higher stage, support readiness should be checked.

Support readiness includes:

known issue coverage
FAQ coverage
owner guide
staff guide
fallback guide
support signal coverage
evidence packet coverage
Gateway query coverage
failure code coverage

No stage should be enabled without support observability.

20\. Final Statement

CatchMenu adoption must be gradual, modular, reversible, and support-observable.

A merchant should be able to start with QR menu only and later move toward POS/KDS/SaaS integration.

However, every stage must preserve authority boundaries, rollback paths, evidence history, failure containment, and support readiness.

Final rule:

Start light.
Expand safely.
Fail within the module.
Preserve evidence.
Do not force integration before readiness.
