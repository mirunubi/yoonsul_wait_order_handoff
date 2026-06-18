# 000040_Operation_Patterns_For_KDS_And_Mini_Runtime

1\. Purpose

This document defines how special store operation patterns are reflected in the yoonsul\_wait\_order\_handoff project.

The patterns described here are not direct ownership responsibilities of the wait\_order core ledger.
They are operation patterns that may affect KDS, Mini Kiosk, Mini KDS, POS/KDS adapters, and store handoff behavior.

The purpose of this document is to prevent over-expanding the wait\_order core while still preserving future compatibility with real store operation variants.

2\. Core Principle

wait\_order core does not own kitchen production logic.

wait\_order core owns:

\- waiting context
\- prepared order context
\- arrival context
\- seating context
\- handoff context
\- external POS/KDS handoff reference
\- returned handoff status
\- benefit routing candidate context

wait\_order core does not own:

\- kitchen line assignment
\- production task splitting
\- KDS internal routing
\- KDS merge logic
\- kitchen priority queue
\- stock deduction
\- POS transaction authority
\- payment finalization
\- refund execution
\- automatic kitchen production start

3\. Three Reflection Layers

Special operation patterns are reflected in three different layers.

3.1 Interface Layer

The wait\_order handoff payload may include fields that help external POS/KDS or internal Mini KDS understand the customer/order context.

Examples:

\- handoff\_channel
\- handoff\_location
\- recipient\_type
\- prepared\_order\_items
\- item options
\- allergy flags
\- special requests
\- language summary
\- store confirmation required
\- external POS/KDS reference
\- external handoff status

3.2 Mini Runtime Layer

Jarijjim Mini Kiosk and Mini KDS may support simplified versions of store operation patterns.

Mini Kiosk is a lightweight customer-facing ordering-preparation interface.

Mini KDS is a lightweight kitchen/staff-facing preparation support screen for stores without strong POS/KDS integration.

Mini Runtime may support:

\- menu browsing
\- multilingual menu explanation
\- prepared order draft
\- staff confirmation request
\- manual kitchen preparation list
\- simple line/category grouping
\- handoff channel display
\- local temporary queue
\- manual POS/KDS handoff support

3.3 Full KDS Layer

Yoonsul KDS or an external store KDS owns full kitchen execution behavior.

Full KDS may support:

\- production units
\- production tasks
\- kitchen line assignment
\- split production
\- partial ready status
\- merge ready status
\- final handoff readiness
\- channel-based priority
\- stock-aware order acceptance
\- recovery and retry logic

4\. Pattern A — Split Production / Multi-KDS Merge

4.1 Definition

Split Production is a store operation pattern where one customer order is produced by multiple production lines or kitchen units.

Examples:

\- kimbap line
\- bowl/salad line
\- drink line
\- soup/side line
\- pickup counter
\- delivery pickup station

4.2 Core Boundary

wait\_order core does not split the order into kitchen production tasks.

wait\_order core may provide:

\- prepared order item list
\- item category
\- allergy/request notes
\- handoff channel
\- external KDS reference
\- external KDS status

wait\_order core must not own:

\- production unit assignment
\- kitchen task sequencing
\- production completion merge
\- line-level priority
\- final kitchen readiness judgment

4.3 Mini KDS Reflection

Mini KDS may provide simplified line grouping.

Example groups:

\- Kimbap
\- Bowl / Salad
\- Drink
\- Soup / Side
\- Packing / Pickup

Mini KDS may allow staff to mark each group as checked or ready.

However, this is a lightweight support function and not a full KDS production engine.

4.4 Full KDS Reflection

Yoonsul KDS or external KDS may fully implement:

\- production\_unit
\- production\_task
\- task\_group
\- partial\_ready
\- merge\_ready
\- final\_ready\_for\_handoff

The final ready status should be determined by the KDS or store production system, not by wait\_order core.

5\. Pattern B — Multi-Channel Handoff

5.1 Definition

Multi-Channel Handoff is a store operation pattern where the prepared order may be handed off through different channels.

Examples:

\- dine-in table
\- takeout counter
\- pickup shelf
\- delivery rider
\- walk-through window
\- curbside pickup
\- drive-through
\- table service

5.2 Core Boundary

wait\_order core may hold interface-level fields.

Examples:

\- handoff\_channel
\- handoff\_location
\- recipient\_type
\- requested\_pickup\_time
\- arrival\_status

wait\_order core must not decide:

\- kitchen priority queue
\- production order
\- staff assignment
\- pickup shelf operation
\- delivery dispatch priority

5.3 Mini Kiosk Reflection

Mini Kiosk may allow the customer to select a handoff channel.

Examples:

\- Eat in store
\- Take out
\- Pick up at counter
\- Show this screen to staff

5.4 Mini KDS Reflection

Mini KDS may group prepared orders by handoff channel.

Examples:

\- Hall
\- Takeout
\- Pickup
\- Delivery rider

This grouping is operational support only.
It does not replace POS/KDS execution authority.

5.5 Full KDS Reflection

Yoonsul KDS or external KDS may apply channel-based priority, routing, and ready notification logic.

6\. Pattern C — Pre-order Pending Confirmation

6.1 Definition

Pre-order Pending Confirmation is a pattern where the customer prepares or requests an order, but the store must confirm availability before the order becomes final.

This is important for stores with:

\- limited daily ingredients
\- premium small-batch menus
\- freshness-sensitive production
\- sold-out items
\- substitution options
\- delayed acceptance flow

6.2 Core Boundary

wait\_order core must distinguish prepared order context from confirmed POS order.

Prepared order context does not equal confirmed POS order.

Suggested statuses:

\- DRAFTED
\- REQUESTED
\- STORE\_CONFIRM\_REQUIRED
\- STORE\_ACCEPTED
\- STORE\_REJECTED
\- SUBSTITUTION\_REQUIRED
\- EXPIRED

wait\_order core may show these states to customers and staff.

wait\_order core must not own:

\- real-time stock deduction
\- POS sales confirmation
\- payment finalization
\- refund execution
\- kitchen production confirmation

6.3 Mini Kiosk Reflection

Mini Kiosk should display customer-facing caution text when store confirmation is required.

Example:

«This menu is confirmed after store review.
If ingredients are sold out, the store may suggest a substitute or cancel the request.»

Korean example:

«이 메뉴는 매장 확인 후 확정됩니다.
재료 소진 시 대체 메뉴 안내 또는 취소가 발생할 수 있습니다.»

6.4 Mini KDS / Store Console Reflection

Mini KDS or Store Console may show a confirmation queue.

Possible staff actions:

\- Accept
\- Reject
\- Suggest substitution
\- Mark sold out
\- Ask customer to reconfirm
\- Expire request

6.5 Full KDS / Inventory Reflection

Yoonsul KDS or a connected inventory system may support:

\- available stock check
\- reserve candidate
\- accept order
\- reject order
\- substitution offer
\- sold-out propagation

7\. Pattern D — Standalone Kiosk Loop

7.1 Definition

Standalone Kiosk Loop is a pattern where a store operates locally with minimal or no cloud/POS/KDS integration.

Examples:

\- independent small store
\- semi-unmanned store
\- local kiosk-only operation
\- store with unstable internet
\- store using local POS/KDS only

7.2 Core Boundary

Standalone local operation is not the default direction of wait\_order core.

wait\_order core is designed for SaaS-compatible handoff, but it may support limited local or manual modes through Mini Kiosk and Mini KDS.

7.3 Mini Kiosk / Mini KDS Reflection

Mini Kiosk and Mini KDS may support:

\- local screen operation
\- temporary local queue
\- manual staff confirmation
\- manual POS input support
\- sync pending status
\- offline caution display

7.4 Deployment Boundary

Standalone Kiosk Loop should be treated as a deployment or integration mode, not as a higher capability stage.

Suggested deployment modes:

\- CLOUD\_SAAS
\- HYBRID\_SYNC
\- STORE\_LOCAL\_FIRST
\- STANDALONE\_LOCAL

Standalone local mode may be useful for low-integration stores, but it limits CRM, benefit routing, central reporting, and SaaS analytics.

8\. Relationship With Store Capability Stage 0\~5

The store capability stage defines what the store can technically connect.

Operation pattern defines how the store physically produces, queues, confirms, and hands off orders.

The same capability stage may require different operation pattern handling.

Examples:

\- A Stage 1 store may still use Mini KDS for simple kitchen grouping.
\- A Stage 3 store may use POS adapter but still have no full KDS.
\- A Stage 4 store may require split production handling inside KDS.
\- A Stage 5 tenant may combine white label membership, benefit routing, and external KDS.

9\. Reflection Matrix

Pattern| wait\_order Core| Mini Kiosk| Mini KDS| Yoonsul / External KDS
Split Production| Interface only| Menu/category display| Simple line grouping| Full production split and merge
Multi-Channel Handoff| Handoff channel fields| Customer channel choice| Channel grouped queue| Priority and routing logic
Pre-order Pending Confirmation| Confirmation status| Store-confirm-required notice| Confirmation queue| Stock-aware accept/reject
Standalone Kiosk Loop| Not default core| Local/manual support| Local/manual support| Local deployment or external responsibility

10\. Required Boundary Statement

The following statement must be preserved in related documents.

«Operation patterns such as split production, multi-channel handoff, pre-order confirmation, and standalone kiosk loops are not owned by the wait\_order core ledger.
They are reflected as interface fields in the handoff payload, simplified support behavior in Jarijjim Mini Kiosk and Mini KDS, and full production/runtime behavior in Yoonsul KDS or the store’s external KDS.»

Korean version:

«분리 주방, 다중 수령 채널, 선주문 후확정, 독립형 키오스크 루프는 wait\_order core 원장이 직접 소유하지 않는다.
이 패턴들은 wait\_order handoff payload의 인터페이스 필드, 자리찜 Mini Kiosk / Mini KDS의 경량 보조 기능, 윤슬 KDS 또는 업소 외부 KDS의 실제 주방 실행 로직에 나누어 반영한다.»

11\. Design Rule

Do not expand wait\_order core into a kitchen production system.

Do not make wait\_order core a POS.

Do not make wait\_order core a KDS.

Do not make wait\_order core an inventory or payment ledger.

wait\_order core must remain the handoff runtime that carries prepared customer/order context from waiting to store execution.
