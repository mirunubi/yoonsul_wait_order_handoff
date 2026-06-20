# 008050_Policy_Night_Operation_Delivery_Platform_Concurrent_Order_Synchronization.md

## Purpose

This document defines the night operation delivery platform concurrency, Baemin/Coupang Eats order synchronization, hall order coexistence, table order coexistence, Mini Kiosk coexistence, POS order boundary, KDS priority, sold-out synchronization, cancellation propagation, provider event validation, staff intervention, and implementation deferral policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined drunk customer mistouch, misoperation, confirmation, staff intervention, payment hold, KDS hold, and safety escalation policy.

This document focuses on the high-risk edge case where night store operation receives concurrent orders from delivery platforms and in-store channels while alcohol mode, partial settlement, KDS load, and staff safety risks may also exist.

This document does not implement delivery platform integration, POS integration, KDS synchronization, provider API, webhook handling, stock deduction, order routing, or UI.

It defines night delivery concurrency and synchronization boundary policy only.

---

## 2. Scope

This document covers:

- night operation concurrency
- delivery platform order boundary
- Baemin/Coupang Eats order coexistence
- hall order coexistence
- table order coexistence
- Mini Kiosk order coexistence
- POS manual order coexistence
- KDS synchronization
- sold-out synchronization
- cancellation synchronization
- refund/recovery coordination
- provider event validation
- staff priority decision
- no-implementation boundary

This document does not cover:

- final Baemin API integration
- final Coupang Eats API integration
- final delivery marketplace contract
- final POS implementation
- final KDS implementation
- final inventory implementation
- final rider handoff workflow
- final delivery alcohol rule
- final customer notification automation
- final kitchen capacity algorithm

---

## 3. Core Principle

Night delivery concurrency must not silently merge incompatible order truth.

The project must follow this rule:

> Delivery platform orders, hall orders, table orders, Mini Kiosk orders, POS manual orders, KDS tickets, sold-out states, payment states, and cancellation states must be synchronized through validated canonical events and staff-visible uncertainty, not silent merge, hidden priority, or provider assumption.

Delivery platform order is not automatically Yoonsul order truth.

KDS ticket is not automatically payment truth.

Sold-out state must not lag behind active kitchen reality.

---

## 4. Night Operation Meaning

Night operation means a store operating during a period with higher risk of:

- alcohol-related customer behavior
- delivery platform order spikes
- reduced staff count
- kitchen fatigue
- rider pickup pressure
- cancellation conflicts
- provider delays
- POS/KDS overload
- stock-out acceleration
- payment disputes
- staff safety incidents
- support availability limits

Night operation should not reuse daytime assumptions blindly.

---

## 5. Delivery Platform Concurrency Meaning

Delivery platform concurrency means multiple external and internal order channels compete for store capacity at the same time.

Channels may include:

- Baemin
- Coupang Eats
- other delivery platform
- POS manual order
- hall order
- table order
- Mini Kiosk order
- staff-entered order
- phone order if later supported
- reservation/preorder if later supported

Each channel may have its own payment, cancellation, customer communication, and provider state.

---

## 6. Delivery Platform Order Boundary

A delivery platform order should be treated as provider-originated order candidate until:

- provider event is validated
- order id is mapped
- store context is confirmed
- item mapping is confirmed
- sold-out availability is checked
- payment/cancellation state is understood
- KDS routing is allowed
- duplicate event is ruled out
- evidence is recorded

Provider order must not bypass canonical event mapping.

---

## 7. Delivery Platform Provider Status Values

Recommended delivery provider status values:

- `DELIVERY_PROVIDER_UNKNOWN`
- `DELIVERY_PROVIDER_AVAILABLE`
- `DELIVERY_PROVIDER_DELAYED`
- `DELIVERY_PROVIDER_DEGRADED`
- `DELIVERY_PROVIDER_UNAVAILABLE`
- `DELIVERY_PROVIDER_EVENT_DUPLICATE`
- `DELIVERY_PROVIDER_EVENT_STALE`
- `DELIVERY_PROVIDER_MAPPING_REQUIRED`
- `DELIVERY_PROVIDER_CANCEL_PENDING`
- `DELIVERY_PROVIDER_REVIEW_REQUIRED`

Provider status must be visible when it affects store operation.

---

## 8. Night Concurrency Status Values

Recommended night concurrency status values:

- `NIGHT_CONCURRENCY_NORMAL`
- `NIGHT_CONCURRENCY_WATCH`
- `NIGHT_CONCURRENCY_HIGH`
- `NIGHT_CONCURRENCY_KDS_PRESSURE`
- `NIGHT_CONCURRENCY_SOLDOUT_RISK`
- `NIGHT_CONCURRENCY_PROVIDER_DELAY`
- `NIGHT_CONCURRENCY_STAFF_REVIEW_REQUIRED`
- `NIGHT_CONCURRENCY_ORDER_HOLD`
- `NIGHT_CONCURRENCY_PAUSE_DELIVERY`
- `NIGHT_CONCURRENCY_INCIDENT_OPEN`

Concurrency status should guide staff action.

---

## 9. Order Channel Classification

Recommended order channel classifications:

- `CHANNEL_HALL_ORDER`
- `CHANNEL_TABLE_ORDER`
- `CHANNEL_MINI_KIOSK`
- `CHANNEL_POS_MANUAL`
- `CHANNEL_BAEMIN`
- `CHANNEL_COUPANG_EATS`
- `CHANNEL_OTHER_DELIVERY`
- `CHANNEL_PHONE_ORDER`
- `CHANNEL_PREORDER`
- `CHANNEL_STAFF_RECOVERY`
- `CHANNEL_UNKNOWN`

Channel classification affects priority, communication, payment, and cancellation rules.

---

## 10. Canonical Order Mapping Rule

Every external order must be mapped to canonical order context.

Mapping should verify:

- external provider order id
- provider name
- store id
- tenant id
- order channel
- item mapping
- quantity
- modifier mapping
- price if relevant
- payment state
- cancellation state
- KDS routing state
- duplicate/replay status
- timestamp

Unmapped provider order must not silently enter KDS.

---

## 11. Duplicate Provider Event Rule

Duplicate provider event may occur when:

- provider retries webhook
- network delay triggers resend
- local daemon replays old event
- staff manually enters same order
- provider sends update as new order
- cancellation event follows delayed accept event
- KDS ticket already exists

Duplicate event must be idempotent or quarantined.

Duplicate provider event must not create duplicate kitchen ticket.

---

## 12. Stale Provider Event Rule

Stale provider event may occur when:

- event arrives late
- provider clock differs
- local daemon reconnects
- platform sends delayed cancellation
- order was already prepared
- store already handled manually
- table/hall state changed
- sold-out state changed

Stale event must be reviewed before affecting order/KDS/payment truth.

---

## 13. Hall And Delivery Coexistence Rule

Hall/table orders and delivery orders may compete for:

- kitchen capacity
- staff attention
- ingredients
- KDS screen space
- packaging station
- payment recovery
- cancellation handling
- customer communication

Coexistence requires visible priority and capacity state.

Do not let delivery platform silently starve hall customers.

Do not let hall orders silently invalidate accepted delivery orders.

---

## 14. Alcohol And Delivery Concurrency Warning

Alcohol mode increases concurrency risk because:

- staff may be busy with verification
- service refusal may require manager attention
- drunk customer dispute may delay kitchen
- partial settlement may require payment review
- KDS may hold alcohol-related tickets
- delivery riders may pressure pickup timing
- staff safety may reduce available capacity

Alcohol mode and delivery rush should create high-risk operational watch.

---

## 15. KDS Synchronization Boundary

KDS synchronization must preserve:

- order channel
- order source
- priority rule
- payment/acceptance status
- hold reason
- cancellation status
- sold-out status
- preparation status
- rider pickup status if applicable
- table/session linkage if applicable
- evidence linkage

KDS must not receive ambiguous provider events as executable tickets.

---

## 16. KDS Priority Rule

KDS priority may consider:

- order channel
- accepted time
- promised pickup time
- table waiting time
- customer recovery urgency
- food preparation time
- alcohol hold state
- staff manual priority
- provider SLA risk
- kitchen load
- packaging capacity

Priority must be visible and explainable.

Priority is not silent favoritism.

---

## 17. KDS Hold Conditions

KDS hold is required when:

- provider order is unmapped
- payment state is uncertain
- cancellation state is pending
- item is sold out or near sold out
- duplicate event suspected
- stale event suspected
- alcohol verification required
- staff confirmation required
- kitchen capacity is unsafe
- service refusal review affects table order
- provider incident active

Hold reason must be visible.

---

## 18. Sold-Out Synchronization Rule

Sold-out state must synchronize across:

- POS
- table order
- Mini Kiosk
- hall order
- delivery platform
- KDS
- staff view
- Admin Console if later built

Sold-out delay can create accepted-but-unfulfillable orders.

Sold-out synchronization must be conservative in night operation.

---

## 19. Near Sold-Out Risk Rule

Near sold-out risk should be visible when:

- remaining quantity is low
- delivery platform order volume spikes
- hall order demand increases
- KDS preparation already allocated ingredient
- manual staff hold exists
- provider update delay exists
- item is alcohol-paired or high-risk combo
- replacement item is not available

Near sold-out state may require staff confirmation before accepting more orders.

---

## 20. Sold-Out Conflict Status Values

Recommended values:

- `SOLDOUT_CONFLICT_NONE`
- `SOLDOUT_CONFLICT_WATCH`
- `SOLDOUT_CONFLICT_PROVIDER_DELAY`
- `SOLDOUT_CONFLICT_CHANNEL_MISMATCH`
- `SOLDOUT_CONFLICT_ACCEPTED_UNFULFILLABLE`
- `SOLDOUT_CONFLICT_KDS_ALREADY_STARTED`
- `SOLDOUT_CONFLICT_CUSTOMER_RECOVERY_REQUIRED`
- `SOLDOUT_CONFLICT_RESOLVED`

Sold-out conflict must not be hidden.

---

## 21. Cancellation Synchronization Rule

Cancellation may originate from:

- delivery platform
- customer
- staff
- POS
- payment failure
- sold-out
- service refusal
- KDS issue
- provider timeout
- support recovery

Cancellation must be synchronized with payment, KDS, provider, and customer communication.

Cancellation must not silently delete evidence.

---

## 22. Cancellation Conflict Examples

Cancellation conflict may occur when:

- delivery platform cancels after KDS started
- customer cancels table order after payment
- staff cancels due to sold-out
- provider sends delayed cancellation
- rider arrives after cancellation
- payment remains captured after cancellation
- KDS ticket already prepared
- alcohol service refusal occurs after payment
- partial settlement complicates refund

Cancellation conflict requires evidence review.

---

## 23. Delivery Cancellation Status Values

Recommended values:

- `DELIVERY_CANCEL_NONE`
- `DELIVERY_CANCEL_REQUESTED`
- `DELIVERY_CANCEL_PROVIDER_PENDING`
- `DELIVERY_CANCEL_PAYMENT_REVIEW`
- `DELIVERY_CANCEL_KDS_REVIEW`
- `DELIVERY_CANCEL_ACCEPTED`
- `DELIVERY_CANCEL_REJECTED`
- `DELIVERY_CANCEL_CUSTOMER_RECOVERY`
- `DELIVERY_CANCEL_DISPUTED`
- `DELIVERY_CANCEL_CLOSED`

Cancellation status must be visible to staff.

---

## 24. Rider Pickup Boundary

Rider pickup creates additional timing risk.

Rider pickup boundary must consider:

- order accepted
- KDS started
- KDS completed
- packaging complete
- cancellation pending
- sold-out conflict
- payment uncertainty
- wrong order risk
- platform delay
- rider pressure
- staff capacity

Rider arrival must not override unresolved cancellation or sold-out risk.

---

## 25. Delivery Alcohol Boundary Placeholder

Delivery alcohol ordering requires separate legal and provider review.

Until defined:

- delivery alcohol mode should remain disabled or restricted
- alcohol item should not be accepted from delivery platform without legal review
- recipient verification must be defined
- platform policy must be reviewed
- rider handoff responsibility must be defined
- refund/cancel boundary must be defined
- evidence requirement must be defined

This document does not approve delivery alcohol sales.

---

## 26. Staff Priority Decision Rule

Staff may need to decide priority when:

- hall and delivery rush collide
- KDS queue is overloaded
- rider pickup time conflicts with table wait
- sold-out risk affects multiple channels
- alcohol verification delays table order
- customer recovery is active
- provider incident disrupts order sync
- cancellation conflict occurs

Staff priority decision must be recorded for high-risk cases.

---

## 27. Staff Priority Decision Values

Recommended values:

- `PRIORITY_NORMAL_SEQUENCE`
- `PRIORITY_DELIVERY_PICKUP_TIME`
- `PRIORITY_HALL_WAITING_CUSTOMER`
- `PRIORITY_CUSTOMER_RECOVERY`
- `PRIORITY_SOLDOUT_RISK_CONTROL`
- `PRIORITY_KDS_OVERLOAD_CONTROL`
- `PRIORITY_STAFF_SAFETY`
- `PRIORITY_PROVIDER_INCIDENT_CONTAINMENT`
- `PRIORITY_MANAGER_DECISION_REQUIRED`

Priority decision should be explainable.

---

## 28. Delivery Platform Pause Rule

Delivery platform intake may need pause when:

- kitchen capacity exceeded
- sold-out state cannot synchronize
- provider incident active
- KDS overload active
- staff safety incident active
- alcohol/service refusal incident active
- payment/cancellation conflict repeated
- support capacity unavailable
- rider pressure creates unsafe operation

Pause should be controlled and recorded.

---

## 29. Delivery Platform Pause Status Values

Recommended values:

- `DELIVERY_PAUSE_NOT_REQUIRED`
- `DELIVERY_PAUSE_REVIEW_REQUIRED`
- `DELIVERY_PAUSE_REQUESTED`
- `DELIVERY_PAUSE_ACTIVE`
- `DELIVERY_PAUSE_PARTIAL`
- `DELIVERY_PAUSE_PROVIDER_PENDING`
- `DELIVERY_PAUSE_RELEASE_REVIEW`
- `DELIVERY_PAUSE_RELEASED`
- `DELIVERY_PAUSE_FAILED`

Pause status must be visible to store staff.

---

## 30. Provider Event Evidence Requirement

Provider event evidence should include:

- provider name
- provider event id
- external order id
- canonical order reference
- store id
- event type
- event timestamp
- received timestamp
- mapping status
- duplicate status
- stale status
- validation status
- affected KDS ticket
- affected payment state
- affected cancellation state
- evidence packet reference

Evidence must avoid storing unnecessary provider payload.

---

## 31. Night Concurrency Evidence Requirement

Night concurrency evidence should include:

- store id
- operation window
- active channels
- KDS load status
- delivery provider status
- sold-out conflict status
- cancellation conflict status
- staff priority decision
- delivery pause status
- alcohol mode status if relevant
- incident reference if any
- customer recovery reference if any
- support case if any
- timestamps
- notes

Evidence should support review without overloading staff.

---

## 32. Evidence ID Format

Recommended format:

    NIGHT-DELIVERY-CONCURRENCY-[YYYYMMDD]-[NUMBER]

Example:

    NIGHT-DELIVERY-CONCURRENCY-20260612-001

Final format may be normalized later.

---

## 33. Customer Communication Rule

Customer communication should be channel-appropriate.

For hall/table customers:

- explain delay calmly
- separate alcohol hold from food delay
- offer staff assistance
- avoid blaming delivery platform

For delivery customers:

- update sold-out/cancel status where platform allows
- avoid false preparation status
- avoid accepting unfulfillable order
- support customer recovery if needed

Customer communication should not expose internal provider failure details unnecessarily.

---

## 34. Staff Communication Rule

Staff view should show:

- active channel load
- delivery platform status
- KDS pressure
- sold-out conflict
- cancellation conflict
- rider pickup risk
- alcohol/verification hold if relevant
- recommended next action
- manager escalation need
- delivery pause option if authorized

Staff should not infer concurrency from scattered tablets.

---

## 35. Admin Console Boundary

Future Admin Console may show:

- night concurrency status
- active delivery providers
- provider delay count
- KDS pressure status
- sold-out conflict count
- cancellation conflict count
- delivery pause status
- provider incident linkage
- staff priority decisions
- evidence completeness

Admin Console must not directly accept/cancel delivery platform orders without runtime/provider workflow authority.

---

## 36. Support Boundary

Support may assist when:

- provider order mapping fails
- cancellation conflict occurs
- payment/refund conflict occurs
- sold-out accepted order occurs
- KDS duplicate risk appears
- delivery platform incident affects multiple stores
- staff cannot resolve platform state
- customer recovery escalates

Support must be case-scoped and evidence-based.

Support must not silently rewrite provider truth.

---

## 37. Provider Incident Boundary

Provider incident should be created when:

- Baemin/Coupang event delay repeats
- webhook/callback duplicates
- local tablet/provider app state conflicts with POS
- cancellation state mismatches
- sold-out update fails
- platform order appears after pause
- provider mapping sends wrong item/store
- provider status affects multiple stores

Provider incident may require cross-store broadcast.

---

## 38. Inventory And Sold-Out Boundary

Inventory/sold-out integration must later define:

- stock source of truth
- channel update timing
- KDS allocation rule
- delivery platform update mechanism
- manual sold-out override
- near-sold-out threshold
- conflict resolution
- evidence
- customer recovery

This document does not implement inventory.

It establishes sold-out as a high-risk concurrency dependency.

---

## 39. Payment And Refund Boundary

Delivery concurrency may affect payment/refund when:

- platform payment already captured
- store cannot fulfill
- cancellation delayed
- KDS already prepared
- rider pickup failed
- customer disputes delay
- partial hall settlement overlaps
- alcohol service refusal affects table order

Payment/refund must follow provider and canonical evidence.

---

## 40. Training Boundary

Staff training must later cover:

- reading channel load
- pausing delivery platform when authorized
- handling sold-out conflict
- handling rider pressure
- handling cancellation conflict
- separating hall and delivery priority
- using KDS hold
- escalating provider incident
- customer communication
- evidence capture

Night delivery concurrency cannot be handled by intuition alone.

---

## 41. Commercial Boundary

Night delivery concurrency may affect:

- provider gateway fee
- delivery platform integration fee
- KDS complexity fee
- support tier
- night operation support fee
- staff training fee
- incident support cost
- sold-out/inventory module value
- high-risk operation package

Delivery concurrency should not be bundled casually into basic SaaS scope.

---

## 42. Legal/Compliance Handoff

Legal/compliance review may be needed for:

- delivery alcohol restrictions
- platform contract obligations
- cancellation/refund rules
- customer notification
- service refusal
- sold-out after acceptance
- rider handoff responsibility
- late-night safety policies
- consumer dispute handling

This document does not provide legal conclusion.

---

## 43. Implementation Deferral Boundary

This document does not authorize:

- Baemin integration
- Coupang Eats integration
- delivery platform API use
- delivery platform auto-accept
- delivery platform auto-cancel
- KDS synchronization build
- inventory sold-out sync build
- provider webhook build
- delivery pause automation
- Admin Console delivery control
- delivery alcohol sale

Implementation requires separate provider, legal, runtime, and build authorization.

---

## 44. Registers Recommendation

Recommended future files:

    docs/_index/
      Night_Concurrency_Status_Register.md
      Delivery_Provider_Status_Register.md
      Order_Channel_Register.md
      Delivery_Order_Mapping_Register.md
      Delivery_Cancellation_Register.md
      Soldout_Conflict_Register.md
      Staff_Priority_Decision_Register.md
      Delivery_Platform_Pause_Register.md
      Night_Delivery_Concurrency_Evidence_Register.md

This document only recommends these files.

It does not create them.

---

## 45. Anti-Patterns

The following are prohibited:

- treating delivery platform order as canonical truth without validation
- sending unmapped provider order directly to KDS
- allowing duplicate provider event to create duplicate ticket
- hiding stale provider event
- letting delivery orders silently starve hall orders
- ignoring alcohol mode during night delivery rush
- accepting unfulfillable order after sold-out
- cancelling order without KDS/payment review
- letting rider pressure override cancellation conflict
- enabling delivery alcohol without separate legal review
- pausing delivery without evidence or status
- showing provider payload to staff unnecessarily
- treating sold-out sync as simple UI toggle
- merging hall/table/delivery states without canonical mapping

---

## 46. Non-Goals

This document does not define:

- final delivery platform integration
- final provider API
- final webhook validation
- final POS implementation
- final KDS implementation
- final inventory implementation
- final delivery platform contract
- final rider handoff workflow
- final delivery alcohol policy
- final customer notification automation

Those belong to later provider, legal, runtime, UI, and implementation planning.

---

## 47. Readiness Check

This document is ready when the project can answer:

1. What does night operation mean?
2. What does delivery platform concurrency mean?
3. What delivery platform order boundary applies?
4. What delivery provider status values exist?
5. What night concurrency status values exist?
6. What order channel classifications exist?
7. What canonical order mapping rule applies?
8. What duplicate provider event rule applies?
9. What stale provider event rule applies?
10. What hall and delivery coexistence rule applies?
11. What alcohol and delivery concurrency warning applies?
12. What KDS synchronization boundary applies?
13. What KDS priority rule applies?
14. What KDS hold conditions exist?
15. What sold-out synchronization rule applies?
16. What near sold-out risk rule applies?
17. What sold-out conflict statuses exist?
18. What cancellation synchronization rule applies?
19. What cancellation conflict examples exist?
20. What delivery cancellation statuses exist?
21. What rider pickup boundary applies?
22. What delivery alcohol placeholder applies?
23. What staff priority decision rule applies?
24. What priority decision values exist?
25. When may delivery platform pause be needed?
26. What delivery pause statuses exist?
27. What provider event evidence is required?
28. What night concurrency evidence is required?
29. What customer communication rule applies?
30. What staff communication rule applies?
31. What Admin Console boundary applies?
32. What support boundary applies?
33. What provider incident boundary applies?
34. What inventory/sold-out boundary applies?
35. What payment/refund boundary applies?
36. What training boundary applies?
37. What commercial boundary applies?
38. What legal/compliance handoff is needed?
39. What implementation deferral boundary applies?
40. What anti-patterns are prohibited?

If these questions cannot be answered, night operation delivery platform concurrency and synchronization planning is incomplete.

---

## 48. Conclusion

Night delivery concurrency is one of the harshest edge cases because it combines provider delay, KDS pressure, sold-out risk, cancellation conflict, rider pickup pressure, alcohol-mode staff burden, and customer recovery.

The safe concurrency flow is:

    external or internal order event
        -> provider/channel validation
        -> canonical order mapping
        -> duplicate/stale check
        -> sold-out and payment review
        -> KDS hold or release
        -> staff priority decision if overloaded
        -> cancellation/recovery if needed
        -> evidence capture
        -> provider/support/legal handoff if needed

This document ensures that Baemin, Coupang Eats, hall orders, table orders, Mini Kiosk orders, POS manual orders, KDS tickets, sold-out state, cancellations, and night alcohol risks are synchronized through governed events rather than silent merge or unsafe provider assumptions.
