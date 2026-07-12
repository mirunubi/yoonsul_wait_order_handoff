# 000020_Policy_Store_Capability_Stage_0_To_5_Module

1\. Purpose

This document defines the six-stage store capability model for the yoonsul\_wait\_order\_handoff project.

The purpose of this model is to separate store adoption types by real operational capability, not by project development maturity.

The six stages define how much of CatchMenu / wait\_order\_handoff should be activated for each store depending on the store’s POS, KDS, waiting operation, multilingual need, membership integration, and SaaS readiness.

This is a store-by-store module policy.

2\. Core Principle

The same wait\_order core may serve different store types.

However, the activated modules must differ by store capability.

A store that only needs a multilingual QR menu must not be forced into waiting, POS, KDS, or benefit routing.

A store that has POS but no integration must use manual handoff.

A store with POS/KDS integration may use adapter-based handoff.

A franchise or SaaS tenant may use identity link, benefit routing, external membership connector, and white label integration.

The core rule is:

«Store capability determines which modules are activated.
wait\_order core remains one runtime, but Store Console, Mini Kiosk, Mini KDS, POS/KDS Handoff, and Benefit Routing are enabled differently by stage.»

3\. Stage Summary

Stage 0 \= Multilingual Menu Board / No CatchMenu Waiting
Stage 1 \= Manual POS Handoff / POS Exists But No Integration
Stage 2 \= Manual POS \+ Mini KDS / Kitchen Assist
Stage 3 \= POS Adapter Handoff
Stage 4 \= POS \+ KDS Integrated Handoff
Stage 5 \= SaaS / White Label / External Membership / Benefit Routing

These stages are not always chronological.

They are store capability types.

A small independent restaurant may stay at Stage 0 or Stage 1\.

A high-volume waiting restaurant may adopt Stage 1 or Stage 2\.

A store with POS API may adopt Stage 3\.

A QSR or franchise store with KDS may adopt Stage 4\.

A multi-store tenant or franchise brand may adopt Stage 5\.

4\. Stage 0 — Multilingual Menu Board / No CatchMenu Waiting

4.1 Store Situation

Stage 0 is for stores that do not need CatchMenu waiting or order handoff.

The store may only need a QR menu, multilingual menu explanation, allergy information, and a screen that customers can show to staff.

Typical stores:

\- stores without waiting queue
\- stores that do not want digital order preparation
\- tourist-heavy stores
\- stores needing foreign-language menu support
\- stores that do not want POS/KDS/membership integration
\- small restaurants that only want QR menu assistance

4.2 Activated Modules

Required modules:

\- QR menu board
\- multilingual menu explanation
\- menu image / description
\- allergy and ingredient display
\- recommended menu display
\- customer “show to staff” screen

Optional modules:

\- simple menu favorites
\- basic store notice
\- language selector
\- staff-readable Korean summary

4.3 Disabled Modules

The following modules are disabled:

\- CatchMenu waiting registration
\- wait\_order\_session
\- order preparation flow
\- Store Wait Board
\- Staff Handoff
\- POS Handoff
\- KDS Handoff
\- Mini KDS
\- Benefit Routing
\- external membership integration
\- white label integration

4.4 Core Policy

Stage 0 is not a waiting service.

It is a multilingual menu board and customer communication support mode.

Stage 0 must not create unnecessary wait\_order state.

4.5 Definition

«Stage 0 is a multilingual QR menu board mode for stores that do not need CatchMenu waiting, order preparation, or POS/KDS handoff.»

\---

5\. Stage 1 — Manual POS Handoff / POS Exists But No Integration

5.1 Store Situation

Stage 1 is for stores that have POS but cannot or do not want to integrate it.

The customer may register waiting and prepare menu context, but staff must manually input the order into the store POS.

Typical stores:

\- POS exists but has no API
\- POS vendor does not support external integration
\- store wants to avoid POS integration risk
\- KDS does not exist or is separate
\- staff can manually enter the prepared order into POS
\- store wants CatchMenu waiting and order preparation with minimal system change

5.2 Activated Modules

Required modules:

\- CatchMenu waiting registration
\- customer webapp or app entry
\- menu pre-selection
\- request and allergy input
\- Store Wait Board
\- Staff Handoff screen
\- arrival confirmation
\- seating confirmation
\- prepared order review
\- manual POS input summary
\- staff confirmation log

Optional modules:

\- benefit candidate display
\- foreign-language order summary
\- staff memo
\- no-show handling
\- prepared order expiration
\- simple call notification

5.3 Disabled Modules

The following modules are disabled:

\- automatic POS order creation
\- automatic payment processing
\- automatic KDS ticket creation
\- POS API sync
\- KDS API sync
\- external membership mutation
\- automatic benefit claim

5.4 POS/KDS Policy

POS remains the transaction authority.

wait\_order only provides prepared customer/order context.

Staff reads the prepared order and manually enters it into POS.

If kitchen communication is needed, staff handles it manually.

5.5 Required Status Families

Stage 1 may use:

\- waiting\_status
\- arrival\_status
\- seating\_status
\- order\_prep\_status
\- staff\_confirmation\_status
\- manual\_pos\_handoff\_status
\- handoff\_status
\- benefit\_candidate\_status

5.6 Definition

«Stage 1 is a manual handoff mode where CatchMenu carries the customer’s waiting and prepared-order context to staff, and staff manually enters the order into the existing POS.»

\---

6\. Stage 2 — Manual POS \+ Mini KDS / Kitchen Assist

6.1 Store Situation

Stage 2 is for stores where POS integration is still unavailable, but kitchen preparation support is needed.

The store may want the prepared order to appear on a simple kitchen/staff screen even though POS remains manual.

Typical stores:

\- POS cannot integrate
\- KDS does not exist
\- kitchen needs a preparation support screen
\- waiting is heavy
\- menu preparation needs early visibility
\- staff wants to reduce verbal handoff
\- store wants Mini KDS before full KDS investment

6.2 Activated Modules

Stage 2 includes Stage 1 modules plus:

\- Mini KDS
\- kitchen preparation queue
\- simple production grouping
\- allergy/request kitchen highlight
\- handoff channel display
\- kitchen confirmation check
\- manual kitchen ready status
\- manual KDS handoff log

Optional modules:

\- category-based grouping
\- drink/food separation
\- packaging checklist
\- pickup readiness display
\- kitchen memo
\- delayed preparation warning

6.3 Disabled Modules

The following modules are disabled unless separately integrated:

\- automatic POS order creation
\- automatic POS payment sync
\- full KDS engine
\- kitchen production optimization
\- inventory deduction
\- automatic production merge
\- external membership mutation

6.4 POS/KDS Policy

POS input remains manual.

Mini KDS is a lightweight kitchen support screen.

Mini KDS does not replace the official POS or full KDS unless the store explicitly adopts it as a local operational tool.

Mini KDS should support staff awareness, not automatic production authority.

6.5 Required Status Families

Stage 2 may use:

\- waiting\_status
\- arrival\_status
\- seating\_status
\- order\_prep\_status
\- staff\_confirmation\_status
\- manual\_pos\_handoff\_status
\- mini\_kds\_status
\- kitchen\_ack\_status
\- handoff\_status
\- benefit\_candidate\_status

6.6 Definition

«Stage 2 is a manual POS plus Mini KDS mode where CatchMenu supports both staff handoff and lightweight kitchen visibility without POS/KDS API integration.»

\---

7\. Stage 3 — POS Adapter Handoff

7.1 Store Situation

Stage 3 is for stores where POS integration is possible.

The store POS can receive external order context, create an order, or return a POS reference.

Typical stores:

\- POS API exists
\- POS vendor supports external order input
\- store wants to reduce manual POS entry
\- store wants POS order reference tracking
\- KDS may or may not be integrated
\- staff still needs fallback to manual handoff

7.2 Activated Modules

Stage 3 includes Stage 1 modules plus:

\- POS adapter
\- POS handoff payload
\- POS order request
\- POS reference storage
\- POS handoff success/failure status
\- duplicate transmission guard
\- retry policy
\- manual fallback
\- adapter capability configuration

Optional modules:

\- limited payment status reference
\- POS item mapping
\- POS option mapping
\- menu sync capability
\- POS error queue
\- staff recovery screen

7.3 Disabled Modules

The following modules remain outside wait\_order ownership:

\- POS transaction authority
\- final payment ownership
\- refund execution
\- POS settlement
\- official sales ledger
\- full kitchen production logic

7.4 POS/KDS Policy

POS is the transaction authority.

wait\_order may request POS order creation or transmit order context.

wait\_order records the POS response reference.

If POS handoff fails, the system falls back to Stage 1 manual handoff.

7.5 Required Status Families

Stage 3 may use:

\- waiting\_status
\- arrival\_status
\- seating\_status
\- order\_prep\_status
\- pos\_handoff\_status
\- external\_pos\_reference\_status
\- adapter\_status
\- handoff\_retry\_status
\- recovery\_status
\- handoff\_status
\- benefit\_candidate\_status

7.6 Definition

«Stage 3 is a POS adapter mode where wait\_order sends prepared order context to POS and records the returned POS reference, while POS remains the transaction authority.»

\---

8\. Stage 4 — POS \+ KDS Integrated Handoff

8.1 Store Situation

Stage 4 is for stores where both POS and KDS can participate in the handoff flow.

This is the integrated store operation stage.

Typical stores:

\- QSR or fast casual store
\- high-volume store
\- POS and KDS are integrated
\- kitchen needs structured order visibility
\- seating, pickup, and kitchen readiness must be connected
\- store wants end-to-end handoff status

8.2 Activated Modules

Stage 4 includes Stage 3 modules plus:

\- KDS adapter
\- KDS handoff payload
\- KDS reference storage
\- KDS visible status
\- kitchen accepted status
\- ready status
\- failed/recovered status
\- handoff completion status
\- POS/KDS consistency check
\- manual recovery screen

Optional modules:

\- Mini KDS fallback
\- kitchen channel display
\- pickup readiness display
\- external KDS status subscription
\- KDS retry policy
\- staff override with audit log

8.3 Disabled Modules

The following remain outside wait\_order ownership:

\- KDS internal production logic
\- kitchen line assignment
\- production task split
\- production merge
\- kitchen priority algorithm
\- inventory deduction
\- automatic cooking start without POS/KDS authority

8.4 POS/KDS Policy

POS remains the transaction authority.

KDS remains the kitchen execution authority.

wait\_order is the handoff runtime.

wait\_order sends prepared customer/order context and records external POS/KDS references and returned statuses.

8.5 Required Status Families

Stage 4 may use:

\- waiting\_status
\- arrival\_status
\- seating\_status
\- order\_prep\_status
\- pos\_handoff\_status
\- kds\_handoff\_status
\- external\_pos\_reference\_status
\- external\_kds\_reference\_status
\- kds\_visible\_status
\- ready\_status
\- recovery\_status
\- handoff\_status
\- benefit\_candidate\_status

8.6 Definition

«Stage 4 is a POS \+ KDS integrated handoff mode where wait\_order connects waiting, arrival, seating, prepared order, POS reference, and KDS reference without owning transaction or kitchen execution authority.»

\---

9\. Stage 5 — SaaS / White Label / External Membership / Benefit Routing

9.1 Store Situation

Stage 5 is for multi-store tenants, franchise brands, white label apps, and stores with external membership systems.

This stage is not only about POS/KDS integration.

It is about identity separation, benefit routing, tenant capability, store policy, and external system connection.

Typical stores or tenants:

\- franchise brand
\- multi-store operator
\- tenant with own customer membership
\- white label app operator
\- store using CatchMenu plus tenant membership
\- brand with external coupon/point system
\- stores requiring SaaS-level reporting and policy configuration

9.2 Activated Modules

Stage 5 may include all previous modules plus:

\- tenant management
\- store capability profile
\- feature activation by plan/package
\- CatchMenu customer identity
\- tenant customer identity
\- identity link
\- claim token
\- benefit routing
\- duplicate guard
\- external membership connector
\- white label app link
\- webhook/API
\- store-level benefit policy
\- tenant-level benefit policy
\- audit log
\- SaaS reporting

Optional modules:

\- external CRM connector
\- franchise HQ console
\- multi-store analytics
\- tenant-specific branding
\- cross-store benefit rules
\- campaign routing
\- settlement reference
\- customer consent separation

9.3 Disabled By Default

The following must not be enabled automatically:

\- external membership mutation without consent/policy
\- automatic benefit claim without duplicate guard
\- cross-tenant identity merge
\- tenant customer data sharing without boundary
\- POS/KDS integration without store capability declaration
\- white label account merge with CatchMenu account

9.4 Membership and Benefit Policy

CatchMenu has its own customer identity.

A tenant or white label app may have its own customer identity.

These identities must not be forcibly merged.

They may be connected through identity link.

Benefits are routed through claim token, policy evaluation, and duplicate guard.

wait\_order is not the membership ledger.

External membership remains owned by the tenant or external system.

9.5 Required Status Families

Stage 5 may use:

\- tenant\_status
\- store\_capability\_status
\- feature\_activation\_status
\- identity\_link\_status
\- benefit\_routing\_status
\- claim\_token\_status
\- duplicate\_guard\_status
\- external\_membership\_status
\- webhook\_delivery\_status
\- consent\_status
\- audit\_status

9.6 Definition

«Stage 5 is the SaaS and white label stage where CatchMenu/wait\_order\_handoff supports tenant-specific capability, external membership linkage, benefit routing, duplicate guard, and API/webhook integration while preserving identity and ledger boundaries.»

\---

10\. Module Activation Matrix

Module| Stage 0| Stage 1| Stage 2| Stage 3| Stage 4| Stage 5
QR Menu Board| Required| Optional| Optional| Optional| Optional| Optional
Multilingual Menu| Required| Optional| Optional| Optional| Optional| Optional
CatchMenu Waiting| Disabled| Required| Required| Required| Required| Required
Menu Pre-selection| Show-only| Required| Required| Required| Required| Required
Store Wait Board| Disabled| Required| Required| Required| Required| Required
Staff Handoff| Disabled| Required| Required| Required| Required| Required
Manual POS Handoff| Disabled| Required| Required| Fallback| Fallback| Store-dependent
Mini KDS| Disabled| Optional| Required| Optional| Fallback| Store-dependent
POS Adapter| Disabled| Disabled| Disabled| Required| Required| Store-dependent
KDS Adapter| Disabled| Disabled| Disabled| Optional| Required| Store-dependent
Benefit Candidate Display| Disabled| Optional| Optional| Optional| Optional| Required
Benefit Routing| Disabled| Disabled| Optional concept| Optional| Optional| Required
External Membership| Disabled| Disabled| Disabled| Disabled| Optional| Required
White Label Link| Disabled| Disabled| Disabled| Disabled| Optional| Required
Webhook/API| Disabled| Disabled| Optional internal| POS-specific| POS/KDS-specific| Required
Tenant Policy| Disabled| Disabled| Disabled| Optional| Optional| Required

11\. Store Capability Profile

Each store should eventually have a capability profile.

Suggested fields:

store\_id
tenant\_id
capability\_stage
qr\_menu\_enabled
jarijjim\_waiting\_enabled
customer\_webapp\_enabled
customer\_app\_enabled
store\_wait\_board\_enabled
staff\_handoff\_enabled
manual\_pos\_handoff\_enabled
mini\_kds\_enabled
pos\_adapter\_enabled
kds\_adapter\_enabled
benefit\_routing\_enabled
external\_membership\_enabled
white\_label\_enabled
webhook\_enabled
deployment\_mode
fallback\_mode

The capability profile controls which modules are active for that store.

12\. Fallback Policy

Every higher stage must be able to fall back to a lower stage.

Examples:

Stage 4 KDS adapter failure
→ fall back to Stage 2 Mini KDS or Stage 1 manual kitchen handoff

Stage 3 POS adapter failure
→ fall back to Stage 1 manual POS handoff

Stage 5 external membership failure
→ defer benefit claim and preserve claim token

Stage 2 Mini KDS unavailable
→ fall back to Staff Handoff screen and manual kitchen note

Fallback must create an event log.

Silent downgrade is prohibited.

13\. Boundary Policy

wait\_order must not become POS.

wait\_order must not become full KDS.

wait\_order must not become inventory.

wait\_order must not become payment ledger.

wait\_order must not become external membership ledger.

The project may provide Mini Kiosk and Mini KDS, but these are lightweight operational support modules for low-integration stores.

Full transaction, kitchen execution, inventory, payment, and external membership ownership remain with the responsible systems.

14\. Relationship With Operation Patterns

The 0\~5 stage model defines what the store can technically connect.

Operation patterns define how the store physically produces, confirms, and hands off orders.

Examples of operation patterns:

\- split production
\- multi-channel handoff
\- pre-order pending confirmation
\- standalone kiosk loop

These operation patterns must be reflected in Mini Kiosk, Mini KDS, Yoonsul KDS, or external KDS depending on the store capability stage.

They are not Stage 6\~9.

15\. Design Rule

The store capability stage controls module activation.

The operation pattern controls runtime behavior.

The deployment mode controls where the runtime runs.

These three axes must remain separate:

Capability Stage \= what the store can connect
Operation Pattern \= how the store operates physically
Deployment Mode \= where and how the runtime is hosted

Do not collapse these axes into one hierarchy.
