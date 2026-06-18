# 011170_Assessment_Store_POS_Adoption_Strategy_OKPOS_Ledger_And_Toss_Kiosk_Combination

Legacy path: $old.

\#\# 1\. Purpose

This note records the strategic assessment of using a combined store setup such as Toss kiosk / Toss payment surface with OKPOS as the underlying POS ledger.

This is relevant because market examples show stores using modern kiosk or payment surfaces while still relying on OKPOS as the main POS infrastructure.

This document does not decide final vendor adoption.

It defines the decision logic for Yoonsul first store, Mini Kiosk, Kiosk, and future provider gateway design.

\---

\#\# 2\. Key Interpretation

A store may appear to use a Toss kiosk while still using OKPOS because the visible customer-facing device and the underlying POS ledger are different layers.

Possible structure:

\- Toss device or kiosk handles customer-facing payment/order UI.
\- OKPOS remains the main store POS ledger.
\- OKDC or partner integration connects external order/kiosk flow to OKPOS.
\- Payment terminal, VAN, kitchen print, sales ledger, and store operation may still depend on OKPOS.
\- Yoonsul backend may later sit above both as an integration/control layer.

Therefore, the question is not simply:

    Toss or OKPOS?

The real question is:

    Which system owns customer UI, payment approval, POS ledger, KDS handoff, settlement, and recovery?

\---

\#\# 3\. Why Stores Use Toss \+ OKPOS Together

Stores may combine Toss and OKPOS for several reasons:

1\. Existing OKPOS installation is already stable.
2\. Store owner or staff are already trained on OKPOS.
3\. OKPOS may already be connected to VAN, receipt printer, kitchen printer, table order, or sales management.
4\. Toss provides modern payment terminal, kiosk, app, or customer-facing UX.
5\. Replacing the entire POS ledger is riskier than adding a customer-facing device.
6\. POS dealers often prefer keeping the existing POS while adding new devices.
7\. Franchise or accounting flow may already depend on OKPOS.
8\. Modern kiosk/payment device can be added without full POS migration.
9\. OKDC may support table order, kiosk, mobile POS, or DID partner use cases.
10\. Toss provides cloud/API/payment ecosystem benefits.

This creates a layered deployment.

\---

\#\# 4\. Layered Store Runtime Model

Recommended conceptual model:

| Layer | Possible Owner |
| \----- | \-------------- |
| Customer-facing kiosk UI | Toss kiosk, Yoonsul Mini Kiosk, or other kiosk |
| Payment device / payment UX | Toss Front, Toss Payments, PAYCO, VAN terminal |
| Store POS ledger | OKPOS or Toss POS |
| External integration bridge | OKDC, Toss Open API, provider gateway |
| Yoonsul business logic | Yoonsul Backend |
| KDS/kitchen execution | Yoonsul KDS or POS-connected kitchen output |
| Audit/evidence | Yoonsul Audit Runtime |
| Recovery/support | Yoonsul Support Runtime |

The final design must decide which layer owns which truth.

\---

\#\# 5\. Store Adoption Options

\#\#\# 5.1 Option A: Toss-First Store

Use Toss POS / Toss device / Toss Open API as the main first store stack.

Advantages:

\- clean cloud Open API direction
\- webhook/event-driven integration
\- simpler backend-first model
\- modern developer experience
\- strong fit with SaaS handoff architecture

Risks:

\- domestic POS market coverage may be narrower than OKPOS
\- existing local POS/KDS/printing ecosystem may require replacement
\- franchise expansion may meet stores already using OKPOS or other POS

\#\#\# 5.2 Option B: OKPOS-First Store

Use OKPOS as the main POS ledger and integrate later through OKDC.

Advantages:

\- strong domestic market coverage
\- familiar to many POS dealers and stores
\- table order/kiosk/mobile POS/DID integration path
\- practical franchise compatibility

Risks:

\- OKDC partner access required
\- local daemon dependency
\- local PC/POS/network failure modes
\- more complex test/pilot process
\- less clean than cloud Open API

\#\#\# 5.3 Option C: OKPOS Ledger \+ Toss Kiosk/Payment Surface

Use OKPOS as store ledger and add Toss customer-facing payment/kiosk surface where compatible.

Advantages:

\- preserves OKPOS operational base
\- gains modern Toss payment/customer UX
\- reduces full POS migration risk
\- may match real-world store setup patterns

Risks:

\- responsibility boundaries become complex
\- payment truth, POS order truth, and KDS truth may split
\- support ownership may be unclear
\- duplicate order/payment risk increases
\- contract/partner compatibility must be verified

\#\#\# 5.4 Option D: Yoonsul Mini Kiosk \+ Provider Gateway

Use Yoonsul Mini Kiosk as the customer-facing layer and connect to provider gateway.

Advantages:

\- strongest long-term control
\- provider-agnostic architecture
\- reusable for Toss, OKPOS, PAYCO, future POS
\- aligns with SaaS/IP strategy

Risks:

\- more development responsibility
\- provider certification still required
\- needs strong recovery and evidence design
\- cannot shortcut payment/POS/KDS boundaries

\---

\#\# 6\. Recommended First Store Strategy

For Yoonsul first store, do not make the final decision only by brand name.

Use the following order:

1\. Confirm OKPOS quote, dealer support, OKDC availability, kiosk/table order support, and pilot feasibility.
2\. Confirm Toss POS / Toss Front / Toss kiosk compatibility and Open API availability.
3\. Check whether Toss device can coexist with OKPOS ledger in the desired store setup.
4\. Check whether the selected combination supports:
   \- menu sync
   \- order sync
   \- payment verification
   \- cancellation/refund separation
   \- kitchen output
   \- KDS handoff
   \- sales settlement
   \- support recovery
5\. Choose the lowest-risk stack for the first store.
6\. Keep Yoonsul Mini Kiosk architecture provider-neutral.

\---

\#\# 7\. Should Yoonsul Adopt Toss Kiosk \+ OKPOS?

Recommended answer:

    Possibly yes, but only after boundary and vendor support verification.

Use this combination if:

\- OKPOS is selected as main POS ledger.
\- Toss device/kiosk improves payment/customer experience.
\- Vendor/dealer confirms compatibility.
\- Order/payment duplication can be prevented.
\- KDS/kitchen output path is clear.
\- Settlement and refund responsibility is clear.
\- Yoonsul backend can still capture required evidence.
\- Future Mini Kiosk is not locked into vendor-specific flow.

Do not use this combination if:

\- payment truth becomes unclear.
\- order truth becomes unclear.
\- kiosk creates orders outside auditable path.
\- refund/cancel responsibility is unclear.
\- OKPOS and Toss support boundaries conflict.
\- Yoonsul cannot receive enough data for handoff/runtime evidence.
\- vendor setup blocks future SaaS modularity.

\---

\#\# 8\. Yoonsul Architecture Rule

Even if the physical store uses OKPOS \+ Toss device, Yoonsul architecture should remain:

    Customer Surface
        \-\> Yoonsul Backend / Gateway
            \-\> Provider Adapter
                \-\> Toss or OKPOS
                    \-\> POS / Payment / KDS boundary

Avoid:

    Customer Surface
        \-\> Toss or OKPOS directly
            \-\> hidden vendor state
                \-\> manual reconciliation later

Yoonsul must keep:

\- order intent
\- payment verification
\- handoff candidate
\- KDS ticket boundary
\- audit evidence
\- recovery state

under its own runtime model.

\---

\#\# 9\. Practical First Store Recommendation

For the physical first store:

\- OKPOS should be strongly considered as the main POS ledger because of domestic market coverage.
\- Toss should be strongly considered for payment/kiosk/cloud integration if compatible.
\- PAYCO should remain payment/smart-order option, not main POS ledger.
\- Yoonsul Mini Kiosk should be designed independently of the selected first store hardware.
\- Do not commit to direct OKDC implementation before official contract and pilot path are known.
\- Do not commit to Toss-only store stack before verifying local kitchen/receipt/store operation needs.

Best practical option to investigate:

    OKPOS as POS ledger
    Toss as payment/kiosk or cloud integration layer
    Yoonsul as backend handoff/audit/recovery layer

But this is an investigation target, not final adoption decision.

\---

\#\# 10\. Required Questions Before Adoption

Before choosing OKPOS \+ Toss combination, verify:

1\. Can Toss device/kiosk work with OKPOS in the intended setup?
2\. Which system owns order creation?
3\. Which system owns payment approval?
4\. Which system owns receipt printing?
5\. Which system owns KDS/kitchen output?
6\. Which system owns cancellation?
7\. Which system owns refund?
8\. Which system owns settlement report?
9\. Can Yoonsul receive order/payment event data?
10\. Can Yoonsul prevent duplicate KDS tickets?
11\. Can Yoonsul identify payment uncertain state?
12\. Can Yoonsul recover from network/device failure?
13\. Can OKPOS dealer support this setup?
14\. Can Toss support this setup?
15\. Is OKDC required?
16\. Is there extra monthly fee?
17\. Is pilot store approval required?
18\. Can the setup support future Mini Kiosk?
19\. Can the setup support future franchise deployment?
20\. Can the setup be rolled back?

\---

\#\# 11\. Decision

Current decision:

    Investigate OKPOS \+ Toss combination as a strong first-store candidate.

Current non-decision:

    Do not yet mandate OKPOS \+ Toss as final store stack.

Reason:

\- It appears realistic in the market.
\- It preserves OKPOS domestic compatibility.
\- It may provide better customer-facing payment/kiosk UX through Toss.
\- It aligns with future Mini Kiosk modularity if boundaries are kept clean.

But official vendor/dealer verification is required.

\---

\#\# 12\. Conclusion

Seeing Toss kiosk or Toss payment surfaces together with OKPOS is not contradictory.

It reflects a layered POS environment:

\- customer-facing device can be Toss
\- underlying POS ledger can be OKPOS
\- integration can happen through provider/dealer/OKDC paths
\- Yoonsul must preserve its own backend truth, audit, and recovery boundaries

For Yoonsul, the recommended direction is:

\- investigate OKPOS as main first-store POS ledger
\- investigate Toss as payment/kiosk/cloud integration layer
\- keep PAYCO as payment/smart-order option
\- keep Yoonsul Mini Kiosk provider-neutral
\- do not allow any vendor combination to collapse payment truth, order truth, and KDS truth

This combination is worth serious investigation, but not automatic adoption until vendor support, data access, recovery, KDS, and settlement boundaries are verified.
