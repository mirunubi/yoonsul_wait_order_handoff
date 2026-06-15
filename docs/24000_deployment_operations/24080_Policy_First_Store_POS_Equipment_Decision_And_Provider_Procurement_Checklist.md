# 24080_Policy_First_Store_POS_Equipment_Decision_And_Provider_Procurement_Checklist

Legacy path: $old.

\#\# 1\. Purpose

This document defines the first-store POS equipment decision policy, provider procurement checklist, vendor comparison rule, and operational verification process for the Yoonsul Wait/Order Handoff project.

The project has selected the following strategic provider direction:

\- Toss as the primary base direction
\- OKPOS as required compatibility interface
\- PAYCO as secondary payment / smart-order channel
\- other POS providers as Phase 2 or Phase 3 candidates

This document turns that strategy into a first-store equipment and procurement checklist.

This document does not purchase equipment, sign contracts, implement integrations, or select a final vendor.

It defines what must be verified before choosing the first-store POS, payment device, kiosk, Mini Kiosk, and related provider setup.

\---

\#\# 2\. Scope

This document covers:

\- first-store POS decision checklist
\- Toss procurement verification
\- OKPOS procurement verification
\- PAYCO optional channel verification
\- kiosk / Mini Kiosk implication
\- hardware and device checklist
\- monthly fee and contract checklist
\- support and dealer checklist
\- integration data access checklist
\- payment / refund / settlement checklist
\- KDS / kitchen output checklist
\- rollback and replacement checklist
\- first-store decision record

This document does not cover:

\- final vendor contract
\- final price negotiation
\- final hardware purchase
\- actual installation
\- actual API implementation
\- actual OKDC implementation
\- actual Toss integration
\- actual PAYCO integration
\- final KDS implementation
\- final Mini Kiosk implementation

\---

\#\# 3\. Core Principle

First-store equipment must be chosen by runtime fit, not by vendor brand alone.

The project must follow this rule:

\> The first-store POS and payment stack must support Yoonsul’s future backend handoff, Mini Kiosk, KDS, audit, recovery, and provider-neutral architecture. A cheap or popular vendor setup is not acceptable if it blocks data access, recovery, or future modularity.

The first store is not only a shop.

It is the first runtime test site.

\---

\#\# 4\. First-Store Strategic Position

The current recommended first-store direction is:

    Toss-first where feasible.
    OKPOS-compatible where required.
    PAYCO optional for payment/smart-order channel.
    Yoonsul Mini Kiosk provider-neutral.

Meaning:

\- Toss should be investigated as the default modern base.
\- OKPOS must be checked because many stores and dealers use it.
\- PAYCO should not drive POS selection but may be payment option later.
\- Mini Kiosk should not be locked into any single vendor.
\- KDS handoff must remain under Yoonsul runtime control.

\---

\#\# 5\. First-Store Decision Candidates

\#\#\# 5.1 Candidate A: Toss-First Stack

Possible structure:

    Toss POS / Toss device / Toss payment
        \+ Yoonsul Backend
        \+ Yoonsul Mini Kiosk later
        \+ Yoonsul KDS / Handoff bridge later

Use if:

\- Toss can cover store operation needs.
\- API / webhook access is available.
\- payment and order data can be verified.
\- kitchen output needs can be met.
\- support terms are acceptable.
\- future Mini Kiosk can integrate through backend.

Risk:

\- may have less incumbent POS ecosystem coverage than OKPOS.
\- some local dealer workflows may be weaker.
\- store operation must fit Toss workflow.

\#\#\# 5.2 Candidate B: OKPOS-First Stack

Possible structure:

    OKPOS POS ledger
        \+ OKDC compatibility later
        \+ Yoonsul Backend
        \+ Toss or PAYCO payment channel optional

Use if:

\- store operation needs incumbent POS stability.
\- dealer support is strong.
\- kitchen/receipt/VAN setup depends on OKPOS.
\- OKDC access is feasible.
\- Toss-only setup cannot cover operational needs.

Risk:

\- OKDC partner access may be required.
\- local daemon dependency may increase support burden.
\- future SaaS integration may be more complex.

\#\#\# 5.3 Candidate C: OKPOS Ledger \+ Toss Payment/Kiosk Surface

Possible structure:

    OKPOS as POS ledger
        \+ Toss customer-facing payment/kiosk layer
        \+ Yoonsul Backend / Gateway

Use if:

\- dealer confirms compatibility.
\- Toss confirms compatible use case.
\- order/payment/KDS truth boundaries are clear.
\- duplicate order and duplicate payment risks are controlled.
\- Yoonsul can still capture evidence.

Risk:

\- ownership boundaries may be complex.
\- support may be split between Toss, OKPOS, dealer, and Yoonsul.
\- data access may be incomplete.

\#\#\# 5.4 Candidate D: Yoonsul Mini Kiosk \+ Provider Gateway

Possible structure:

    Yoonsul Mini Kiosk
        \-\> Yoonsul Backend
            \-\> Toss / OKPOS / PAYCO adapter

Use later when:

\- core backend runtime is stable.
\- provider adapter is verified.
\- payment state model is implemented.
\- KDS handoff is controlled.
\- recovery path exists.

Risk:

\- more implementation burden.
\- not suitable as immediate first-store shortcut unless ready.

\---

\#\# 6\. Toss Procurement Checklist

Before selecting Toss as first-store base, verify:

1\. Available POS product type.
2\. Available payment terminal/device type.
3\. Whether Toss POS can handle the intended menu/order workflow.
4\. Whether Toss supports order lookup needed by Yoonsul.
5\. Whether Toss supports payment lookup needed by Yoonsul.
6\. Whether Toss supports webhook/event integration for required events.
7\. Whether merchant/store mapping is available.
8\. Whether test/sandbox access is available.
9\. Whether API key and secret management is clear.
10\. Whether webhook signing is supported for required events.
11\. Whether refund/cancel flow is clear.
12\. Whether settlement report access is sufficient.
13\. Whether kitchen printing or KDS output is supported.
14\. Whether receipt printing is supported.
15\. Whether offline/degraded operation is possible.
16\. Whether device replacement flow is clear.
17\. Whether monthly fee and transaction fee are acceptable.
18\. Whether support channel is acceptable.
19\. Whether future Mini Kiosk integration is allowed.
20\. Whether vendor lock-in risk is acceptable.

\---

\#\# 7\. OKPOS Procurement Checklist

Before selecting or supporting OKPOS, verify:

1\. Which OKPOS product/package is used.
2\. Which dealer or agency supports the store.
3\. Whether OKDC is available for this store.
4\. Whether OKDC requires separate contract.
5\. Whether OKDC requires separate monthly fee.
6\. Whether OKDC supports table order.
7\. Whether OKDC supports kiosk.
8\. Whether OKDC supports mobile POS.
9\. Whether OKDC supports DID.
10\. Whether OKDC supports order registration.
11\. Whether OKDC supports payment processing.
12\. Whether OKDC supports payment cancel/refund.
13\. Whether OKDC supports table state lookup.
14\. Whether OKDC supports menu/master data lookup.
15\. Whether OKDC daemon installation is required.
16\. Whether DLL/interface access is required.
17\. Whether pilot verification is required.
18\. Whether technical documents can be obtained.
19\. Whether duplicate order prevention exists.
20\. Whether local timeout behavior is defined.
21\. Whether POS business open/close state affects integration.
22\. Whether KDS/kitchen printer output path is clear.
23\. Whether support responsibility is clear.
24\. Whether future Yoonsul Mini Kiosk can connect through backend.
25\. Whether OKPOS lock-in risk is acceptable.

\---

\#\# 8\. PAYCO Procurement Checklist

PAYCO should be evaluated as payment or smart-order channel, not first-store POS base.

Before activating PAYCO channel, verify:

1\. Payment API availability.
2\. Payment reservation flow.
3\. Auth callback flow.
4\. Final approval API.
5\. Cancel/refund API.
6\. WebView or app bridge requirements.
7\. Android/iOS scheme requirements where relevant.
8\. Login versus payment separation.
9\. Smart Order channel scope.
10\. Merchant credential handling.
11\. Test credential or sandbox availability.
12\. Payment result evidence.
13\. Settlement report availability.
14\. Support channel.
15\. Fit with Yoonsul Mini Kiosk payment UI.

PAYCO is optional unless payment strategy requires it.

\---

\#\# 9\. Kiosk / Mini Kiosk Checklist

Before choosing first-store provider stack, verify kiosk impact:

1\. Can customer order be captured outside POS UI?
2\. Can menu data be synchronized or manually aligned?
3\. Can sold-out status be reflected?
4\. Can payment verification happen in backend?
5\. Can KDS handoff be controlled?
6\. Can duplicate order be blocked?
7\. Can duplicate payment be blocked?
8\. Can timeout be recovered?
9\. Can customer cancellation be handled?
10\. Can refund review be handled?
11\. Can table context be linked?
12\. Can pickup context be linked?
13\. Can waiting context be linked?
14\. Can device trust be managed?
15\. Can provider adapter be disabled?
16\. Can support inspect masked state?
17\. Can evidence be captured?
18\. Can future Mini Kiosk remain provider-neutral?

If these cannot be answered, do not lock into a vendor stack.

\---

\#\# 10\. KDS / Kitchen Output Checklist

Before choosing first-store stack, verify:

1\. Is kitchen output printed by POS?
2\. Is KDS supported directly?
3\. Is kitchen printer controlled by POS?
4\. Is kitchen ticket status visible?
5\. Can duplicate kitchen output occur?
6\. Can Yoonsul KDS be added later?
7\. Can POS kitchen output and Yoonsul KDS coexist safely?
8\. Can order cancellation after kitchen start be detected?
9\. Can kitchen retry/remake be represented?
10\. Can external kitchen output be marked as provider-originated?

Kitchen output path is critical.

A POS that looks convenient but hides kitchen state may block later KDS architecture.

\---

\#\# 11\. Payment / Refund / Settlement Checklist

Before choosing first-store stack, verify:

1\. Which system owns payment approval?
2\. Which system owns refund?
3\. Which system owns order cancellation?
4\. Which system owns settlement report?
5\. Which system owns VAN terminal state?
6\. Can payment be looked up by order?
7\. Can order be looked up by payment?
8\. Can split payment be handled?
9\. Can partial refund be handled?
10\. Can failed payment be identified?
11\. Can uncertain payment be reviewed?
12\. Can duplicate charge be detected?
13\. Can payment evidence be exported safely?
14\. Can sensitive data be masked?

If payment and refund responsibility is unclear, provider selection is not ready.

\---

\#\# 12\. Dealer / Support Checklist

For any store POS setup, verify:

1\. Who installs equipment?
2\. Who supports POS failure?
3\. Who supports payment terminal failure?
4\. Who supports kiosk failure?
5\. Who supports OKDC/daemon failure?
6\. Who supports printer failure?
7\. Who supports network failure?
8\. Who handles after-hours incident?
9\. Who handles version update?
10\. Who handles replacement device?
11\. Who handles contract cancellation?
12\. Who handles data export?
13\. Who handles API issue?
14\. Who handles refund dispute?
15\. Who handles training?

Support ownership must be written down.

\---

\#\# 13\. Contract / Cost Checklist

Before first-store provider selection, record:

\- installation cost
\- hardware cost
\- monthly POS fee
\- monthly kiosk fee
\- payment terminal fee
\- OKDC fee if applicable
\- API access fee if applicable
\- maintenance fee
\- dealer support fee
\- cancellation fee
\- contract term
\- minimum commitment
\- transaction fee
\- refund fee
\- device replacement cost
\- additional store cost
\- franchise expansion cost

Provider cost must be compared across first store and future franchise rollout.

\---

\#\# 14\. Data Access Checklist

The first-store provider stack must be judged by data access.

Required data categories:

\- menu
\- item option
\- price
\- sold-out status
\- order
\- payment
\- cancel
\- refund
\- table
\- kitchen output
\- receipt
\- settlement
\- store id
\- terminal id
\- merchant id
\- event timestamp
\- status transition
\- error state

If a provider cannot expose enough data, it may still be usable operationally but not ideal for Yoonsul runtime integration.

\---

\#\# 15\. Rollback / Replacement Checklist

Before selecting provider, verify:

1\. Can provider integration be disabled?
2\. Can payment still operate manually?
3\. Can orders be taken manually?
4\. Can kitchen receive manual tickets?
5\. Can device be replaced quickly?
6\. Can provider contract be cancelled?
7\. Can data be exported?
8\. Can POS be changed later?
9\. Can Mini Kiosk be disconnected?
10\. Can store operate without Yoonsul backend temporarily?
11\. Can Toss be replaced by OKPOS or vice versa?
12\. Can PAYCO be disabled without breaking POS?

No first-store provider should become irreversible.

\---

\#\# 16\. First-Store Decision Record

When the first-store provider stack is selected, create a decision record.

Recommended fields:

\- decision id
\- decision date
\- selected POS provider
\- selected payment provider
\- selected kiosk provider
\- selected KDS path
\- selected dealer/support partner
\- reasons selected
\- rejected alternatives
\- data access summary
\- payment/refund boundary
\- KDS/kitchen boundary
\- Mini Kiosk impact
\- integration readiness
\- unresolved blockers
\- costs
\- support contacts
\- rollback plan
\- reviewer
\- approval status

This decision record should be stored with provider documents.

\---

\#\# 17\. First-Store Recommended Evaluation Order

Recommended evaluation order:

1\. Toss-first stack feasibility.
2\. Toss data/API/payment/KDS fit.
3\. OKPOS compatibility need.
4\. OKPOS OKDC/dealer/support feasibility.
5\. Toss \+ OKPOS coexistence possibility.
6\. PAYCO optional payment value.
7\. kitchen output path.
8\. support ownership.
9\. monthly/installation cost.
10\. future Mini Kiosk compatibility.
11\. rollback path.
12\. final decision record.

\---

\#\# 18\. Current Recommendation

Current recommendation:

    Default investigation path:
      Toss as primary first-store base.

    Required parallel check:
      OKPOS compatibility and OKDC feasibility.

    Optional payment/channel check:
      PAYCO.

    Deferred:
      Smartro, KICC, NICE, I'M U, Hyphen, minor POS, hardware terminal direct integration.

This recommendation may change after official quotes, dealer confirmation, and technical verification.

\---

\#\# 19\. Anti-Patterns

The following are prohibited:

\- choosing POS only because it is popular
\- choosing POS only because it is cheap
\- choosing POS only because dealer recommends it
\- choosing POS without data access check
\- choosing kiosk without KDS boundary check
\- choosing payment provider without refund boundary
\- choosing OKPOS without OKDC feasibility check
\- choosing Toss without kitchen/store operation check
\- choosing PAYCO as POS base without evidence
\- allowing vendor to define Yoonsul architecture
\- ignoring rollback path
\- ignoring support ownership
\- ignoring future Mini Kiosk compatibility

\---

\#\# 20\. Non-Goals

This document does not decide:

\- final POS provider
\- final payment provider
\- final kiosk provider
\- final dealer
\- final contract
\- final equipment
\- final cost
\- final implementation
\- final store opening setup

Those belong to later procurement and controlled implementation stages.

\---

\#\# 21\. Readiness Check

This document is ready when the project can answer:

1\. What first-store provider candidates exist?
2\. Why is Toss checked first?
3\. Why is OKPOS checked in parallel?
4\. Why is PAYCO optional?
5\. What Toss checklist must be completed?
6\. What OKPOS checklist must be completed?
7\. What PAYCO checklist must be completed?
8\. What kiosk checklist must be completed?
9\. What KDS/kitchen checklist must be completed?
10\. What payment/refund/settlement checklist must be completed?
11\. What dealer/support checklist must be completed?
12\. What contract/cost checklist must be completed?
13\. What data access is required?
14\. What rollback questions must be answered?
15\. What decision record must be created?
16\. What anti-patterns are prohibited?

If these questions cannot be answered, first-store POS equipment decision planning is incomplete.

\---

\#\# 22\. Conclusion

The first-store POS and provider decision must support both immediate operation and future Yoonsul architecture.

The current strategic direction is:

\- Toss-first
\- OKPOS-compatible
\- PAYCO-optional
\- provider-neutral Mini Kiosk
\- Yoonsul-owned backend runtime
\- no vendor lock-in
\- no hidden payment/order/KDS truth

The first store must not be treated as only a shop setup.

It is the first operational proving ground for:

\- provider adapter
\- POS/KDS handoff
\- payment recovery
\- Mini Kiosk readiness
\- support ownership
\- evidence capture
\- franchise expansion

Final provider selection must be made only after procurement, data access, support, cost, KDS, payment, and rollback checks are completed.
