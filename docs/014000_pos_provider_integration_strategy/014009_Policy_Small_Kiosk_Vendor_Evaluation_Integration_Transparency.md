# 014009_Policy_Small_Kiosk_Vendor_Evaluation_Integration_Transparency

## 1. Purpose

This document defines the evaluation policy for small kiosk vendors, third-party kiosk providers, table-order device vendors, and store-specific kiosk installers in the Yoonsul Wait/Order Handoff project.

The project has observed that many stores use small kiosk vendors together with existing POS systems such as OKPOS, but the actual integration depth may be limited, unclear, or dealer-dependent.

This document defines how Yoonsul should evaluate such vendors before adoption or integration.

This document does not select a kiosk vendor.

It defines evaluation, risk, transparency, and integration boundary policy only.

---

## 2. Scope

This document covers:

- small kiosk vendor evaluation
- third-party kiosk integration transparency
- POS linkage verification
- payment linkage verification
- KDS/kitchen output verification
- dealer dependency review
- support ownership review
- data access review
- future Yoonsul Mini Kiosk impact
- vendor lock-in review
- no-implementation boundary

This document does not cover:

- final kiosk hardware purchase
- final kiosk software implementation
- final kiosk vendor contract
- final kiosk installation
- final POS integration code
- final payment integration code
- final KDS implementation
- final Mini Kiosk implementation

---

## 3. Core Principle

A kiosk vendor must be judged by integration transparency, not by screen appearance.

The project must follow this rule:

> A kiosk that looks good but cannot clearly expose order, payment, cancellation, refund, KDS, support, and recovery boundaries is not a safe integration partner for Yoonsul.

A kiosk UI is not enough.

Yoonsul needs runtime visibility.

---

## 4. Why Small Kiosk Vendors Are Risky

Small kiosk vendors may be useful for fast store installation, but they often create hidden risks.

Common risks:

- POS integration is shallow
- integration depends on dealer-specific setup
- payment ownership is unclear
- refund and cancellation are manual
- KDS output is hidden behind POS/printer
- data export is weak
- no API is available
- no webhook is available
- no event evidence exists
- failure recovery is undocumented
- support responsibility is split
- future Mini Kiosk integration becomes blocked
- vendor lock-in occurs through hardware/software bundle

Therefore, small kiosk vendor adoption must be controlled.

---

## 5. Vendor Categories

Small kiosk vendors should be classified into categories.

| Category | Meaning |
| -------- | ------- |
| UI-Only Kiosk Vendor | Provides screen/device only, relies on POS/dealer |
| POS-Integrated Kiosk Vendor | Has formal POS integration |
| Payment-Integrated Kiosk Vendor | Handles payment device or PG connection |
| Table-Order Device Vendor | Provides table tablets and order flow |
| Dealer-Installed Kiosk Vendor | Installed and maintained by POS/VAN dealer |
| White-Label Kiosk Vendor | Provides branded kiosk software |
| Hardware-Only Vendor | Provides kiosk body/device only |
| Full-Stack Kiosk Vendor | Claims POS/payment/KDS integration ownership |
| Unknown Vendor | Integration depth unclear |

Each category requires different verification.

---

## 6. Minimum Evaluation Questions

Before considering a small kiosk vendor, ask:

1. Which POS systems are officially supported?
2. Is OKPOS supported directly or through dealer setup?
3. Is Toss supported directly or only as payment terminal?
4. Is payment handled by kiosk, POS, VAN, or PG?
5. Who owns order creation?
6. Who owns payment approval?
7. Who owns cancellation?
8. Who owns refund?
9. Who owns kitchen output?
10. Is KDS supported?
11. Is there an API?
12. Is there a webhook?
13. Is there an admin console?
14. Can data be exported?
15. Can Yoonsul backend receive order/payment events?
16. Can duplicate order be prevented?
17. Can duplicate payment be prevented?
18. What happens when POS is offline?
19. What happens when payment succeeds but POS order fails?
20. What happens when kiosk freezes?
21. Who supports incidents?
22. Can the system be disabled or replaced?

If these cannot be answered, vendor is not integration-transparent.

---

## 7. Integration Transparency Levels

Recommended transparency levels:

| Level | Meaning |
| ----- | ------- |
| Level 0 | UI/demo only, no technical integration details |
| Level 1 | POS/dealer says it works, but no documents |
| Level 2 | Basic operational setup known, but no API evidence |
| Level 3 | POS/payment/KDS ownership documented |
| Level 4 | Official API/webhook/export or integration documents available |
| Level 5 | Sandbox/pilot evidence and failure recovery documented |

Minimum for first-store operational use:

    Level 2 or higher

Minimum for Yoonsul backend integration:

    Level 4 or higher

Minimum for controlled implementation:

    Level 5 preferred

---

## 8. POS Integration Verification

Kiosk vendor must explain POS integration method.

Possible methods:

- direct POS API
- OKDC / OKPOS interface
- Toss API / Toss provider integration
- local daemon
- local socket
- printer interception
- manual sync
- file export/import
- dealer configuration
- no integration

Rules:

- printer interception is not proper POS integration
- manual sync is not runtime integration
- dealer setup without documentation is weak evidence
- local daemon requires timeout/recovery policy
- direct API requires official evidence
- POS integration must preserve order id and status mapping

---

## 9. Payment Integration Verification

Kiosk vendor must explain payment path.

Possible payment paths:

- POS-owned payment
- kiosk-owned payment
- Toss payment
- PAYCO payment
- VAN terminal
- PG payment
- card reader attached to kiosk
- QR/barcode payment
- manual cashier payment

Rules:

- payment UI is not payment approval
- payment approval must be verifiable
- refund owner must be known
- cancellation owner must be known
- duplicate payment prevention must be documented
- settlement report owner must be known
- payment secrets must not be stored insecurely on kiosk

---

## 10. KDS / Kitchen Output Verification

Kiosk vendor must explain kitchen output path.

Possible kitchen output paths:

- POS kitchen printer
- POS KDS
- Yoonsul KDS
- kiosk sends kitchen print
- dealer-configured printer route
- manual kitchen note
- no kitchen integration

Rules:

- printer output is not full KDS state
- kitchen ticket duplication must be prevented
- cancellation after kitchen start must be handled
- remake/retry must be visible
- Yoonsul KDS addition later must not be blocked
- local kitchen output must be marked as provider-originated if needed

---

## 11. Data Access Verification

Minimum data access questions:

| Data | Required Question |
| ---- | ----------------- |
| Menu | Can menu be synced or exported? |
| Price | Can price changes be synchronized? |
| Sold-out | Can sold-out state be reflected? |
| Order | Can order id and item list be accessed? |
| Payment | Can payment status be verified? |
| Cancel | Can cancellation state be accessed? |
| Refund | Can refund state be accessed? |
| Kitchen | Can kitchen output state be accessed? |
| Error | Can failure reason be accessed? |
| Settlement | Can settlement report be accessed? |
| Device | Can kiosk device status be accessed? |

If vendor cannot provide data access, it may remain a standalone store device but should not become Yoonsul integration dependency.

---

## 12. Dealer Dependency Review

Small kiosk vendors may depend on POS/VAN dealers.

Dealer dependency must be documented:

- who installs the kiosk
- who configures POS
- who configures printer
- who configures payment terminal
- who maps menu
- who maps table numbers
- who fixes integration failure
- who owns after-hours support
- who updates software
- who replaces hardware
- who handles contract cancellation

If vendor and dealer blame each other, adoption risk is high.

---

## 13. Support Ownership Review

Support ownership must be explicit.

Support areas:

- kiosk hardware
- kiosk software
- POS integration
- payment terminal
- printer
- network
- menu sync
- order failure
- refund/cancel issue
- settlement mismatch
- KDS output issue
- data export
- API issue
- customer complaint

No vendor should be selected if support ownership is unclear.

---

## 14. Failure Scenario Review

Kiosk vendor must answer failure scenarios.

Required scenarios:

1. Customer pays but POS order fails.
2. POS order succeeds but payment fails.
3. POS accepts order but kitchen output fails.
4. Kiosk sends duplicate order.
5. Customer taps payment twice.
6. POS is offline.
7. Network is unstable.
8. Printer is disconnected.
9. Kiosk app crashes.
10. Kiosk device reboots mid-payment.
11. Customer cancels after payment.
12. Customer cancels after kitchen start.
13. Refund is requested.
14. Settlement mismatch occurs.
15. Menu price differs between POS and kiosk.

Failure response must be documented.

---

## 15. Future Mini Kiosk Impact

Small kiosk vendor adoption must not block Yoonsul Mini Kiosk.

Before adoption, verify:

- can Yoonsul later replace kiosk UI?
- can Yoonsul backend receive same data?
- can provider adapter be reused?
- can POS integration be transferred?
- can device be disabled?
- can menu data be exported?
- can customer data be exported or deleted?
- can contract be ended?
- can hardware be repurposed?
- can Yoonsul Mini Kiosk coexist during transition?

If the answer is no, vendor lock-in risk is high.

---

## 16. Vendor Lock-In Signals

Warning signs:

- vendor refuses to explain integration path
- vendor says "it just works" without documents
- vendor says dealer handles everything but no dealer confirmation
- no API
- no export
- no webhook
- no failure logs
- no refund/cancel explanation
- no support boundary
- kiosk hardware only runs vendor software
- menu data cannot be migrated
- order data cannot be exported
- contract cancellation is expensive
- POS change is impossible
- Yoonsul backend cannot integrate later

These vendors should be avoided or used only as temporary operational devices.

---

## 17. Temporary Use Classification

A small kiosk vendor may be classified as temporary use.

Temporary use allowed when:

- first store needs fast opening
- vendor is operationally stable
- cost is acceptable
- no critical data integration is required immediately
- rollback is possible
- Yoonsul Mini Kiosk remains planned separately
- vendor does not block Toss/OKPOS strategy

Temporary use must be marked:

    TEMPORARY_OPERATIONAL_VENDOR

Temporary use is not architecture dependency.

---

## 18. Integration Candidate Classification

A small kiosk vendor may be classified as integration candidate only when:

- supported POS systems are documented
- payment boundary is clear
- KDS/kitchen output path is clear
- API/export/webhook exists
- failure scenarios are documented
- support ownership is written
- data access is adequate
- vendor allows backend integration
- rollback path exists

Integration candidate status:

    INTEGRATION_CANDIDATE

Implementation still requires controlled authorization.

---

## 19. Vendor Evaluation Status Values

Recommended status values:

- `NOT_REVIEWED`
- `MARKET_OBSERVED`
- `QUOTE_REQUESTED`
- `QUOTE_RECEIVED`
- `DEMO_ONLY`
- `OPERATIONAL_USE_CANDIDATE`
- `TEMPORARY_OPERATIONAL_VENDOR`
- `INTEGRATION_CANDIDATE`
- `NEEDS_TECH_CONFIRMATION`
- `NEEDS_DEALER_CONFIRMATION`
- `NEEDS_SUPPORT_CONFIRMATION`
- `BLOCKED`
- `REJECTED`
- `DEFERRED`
- `SELECTED_WITH_CONDITIONS`

---

## 20. Evidence Requirements

Small kiosk vendor evidence should include:

- quote
- vendor brochure
- supported POS list
- supported payment list
- integration document if available
- dealer confirmation
- support terms
- failure handling explanation
- data export explanation
- API/webhook documentation if available
- hardware specification
- contract terms
- cancellation terms
- demo screenshots where allowed
- installation plan
- rollback plan

Evidence must be attached to vendor quote/adoption records.

---

## 21. Scoring Model

Recommended scoring dimensions:

| Dimension | Score 0-5 |
| --------- | --------- |
| POS Integration Transparency | 0-5 |
| Payment Boundary Clarity | 0-5 |
| KDS/Kitchen Clarity | 0-5 |
| Data Access | 0-5 |
| Failure Recovery | 0-5 |
| Support Ownership | 0-5 |
| Mini Kiosk Future Compatibility | 0-5 |
| Vendor Lock-In Risk | 0-5 |
| Cost Fit | 0-5 |
| Operational Simplicity | 0-5 |

For lock-in risk, higher score means lower lock-in risk.

Blocking if:

- POS integration transparency below 2
- payment boundary below 2
- support ownership below 2
- rollback below 2
- Mini Kiosk future compatibility unknown for long-term adoption

---

## 22. Adoption Rules

### 22.1 Operational Adoption

A small kiosk vendor may be adopted operationally if:

- store can operate safely
- payment/refund is clear enough
- support owner exists
- cost is acceptable
- rollback exists
- Yoonsul architecture is not blocked

### 22.2 Integration Adoption

A small kiosk vendor may become Yoonsul integration scope only if:

- API/export/webhook or official integration path exists
- POS/payment/KDS data access is sufficient
- failure recovery is documented
- evidence packet exists
- controlled implementation authorization exists

Operational adoption does not equal integration adoption.

---

## 23. Recommended Yoonsul Position

Yoonsul should prefer:

    Toss base + OKPOS compatibility + Yoonsul Mini Kiosk

over:

    opaque small kiosk vendor dependency

Small kiosk vendors may be used when they solve short-term operational needs, but they should not become the architecture base unless they are integration-transparent.

The long-term goal remains:

    Yoonsul-owned Mini Kiosk and provider gateway.

---

## 24. Anti-Patterns

The following are prohibited:

- adopting kiosk vendor because demo screen looks good
- adopting kiosk vendor without refund/cancel clarity
- adopting kiosk vendor without POS integration explanation
- adopting kiosk vendor without KDS path
- adopting kiosk vendor without support ownership
- treating dealer claim as technical proof
- treating printer output as KDS integration
- treating payment terminal approval as full order truth
- letting kiosk vendor own Yoonsul customer data without export/delete policy
- locking first store into non-exportable menu/order data
- delaying Yoonsul Mini Kiosk because temporary vendor exists
- treating temporary operational vendor as architecture platform

---

## 25. Non-Goals

This document does not define:

- final kiosk vendor
- final kiosk hardware
- final kiosk software
- final small vendor contract
- final POS integration
- final payment integration
- final KDS integration
- final Mini Kiosk implementation

Those belong to later procurement and controlled implementation.

---

## 26. Readiness Check

This document is ready when the project can answer:

1. Why are small kiosk vendors risky?
2. What vendor categories exist?
3. What minimum questions must be asked?
4. What integration transparency levels exist?
5. How is POS integration verified?
6. How is payment integration verified?
7. How is KDS/kitchen output verified?
8. What data access must be checked?
9. How is dealer dependency reviewed?
10. How is support ownership reviewed?
11. What failure scenarios must be answered?
12. How does vendor adoption affect future Mini Kiosk?
13. What are lock-in warning signs?
14. When is temporary use allowed?
15. When is vendor an integration candidate?
16. What evidence is required?
17. How is vendor scored?
18. What adoption rules apply?
19. What anti-patterns are prohibited?

If these questions cannot be answered, small kiosk vendor evaluation is incomplete.

---

## 27. Conclusion

Small kiosk vendors may be useful in the market, but Yoonsul must evaluate them carefully.

The project must preserve the following rules:

- kiosk UI is not integration proof
- dealer claim is not official evidence
- printer output is not KDS truth
- payment device success is not full runtime truth
- support ownership must be explicit
- POS/payment/KDS boundaries must be visible
- future Mini Kiosk must not be blocked
- temporary operational use is not architecture adoption
- integration candidate status requires evidence
- Yoonsul backend and provider gateway remain the long-term direction

This document protects the first store and future Mini Kiosk development from opaque kiosk vendor lock-in.