# 014007_Policy_Store_Vendor_Quote_Comparison_Adoption_Decision_Record

## 1. Purpose

This document defines the vendor quote comparison, adoption decision record, scoring model, risk review, and final selection evidence policy for the first-store POS, payment, kiosk, Mini Kiosk, and provider integration stack in the Yoonsul Wait/Order Handoff project.

The previous document defined the first-store POS equipment decision and procurement checklist.

This document defines how vendor quotes and proposals must be compared before selecting the first-store stack.

This document does not select a final vendor.

It defines the comparison and decision record policy only.

---

## 2. Scope

This document covers:

- vendor quote comparison
- Toss quote review
- OKPOS quote review
- Toss plus OKPOS coexistence quote review
- PAYCO optional channel quote review
- kiosk vendor quote review
- dealer/support comparison
- data access comparison
- KDS/kitchen output comparison
- payment/refund comparison
- contract/cost comparison
- future Mini Kiosk compatibility comparison
- adoption decision record template
- no-implementation boundary

This document does not cover:

- final vendor selection
- actual contract negotiation
- actual payment provider registration
- actual equipment purchase
- actual POS installation
- actual kiosk installation
- actual API implementation
- actual OKDC implementation
- actual Toss integration
- actual PAYCO integration

---

## 3. Core Principle

Vendor quote comparison must include operational and architectural fit, not only cost.

The project must follow this rule:

> A vendor quote is acceptable only if it can be compared across cost, data access, support ownership, runtime boundary, future Mini Kiosk compatibility, KDS path, payment recovery, and rollback feasibility.

Cheap equipment that blocks runtime integration is expensive.

Popular POS that hides data access is risky.

Modern provider UI that cannot reconcile payment and order state is incomplete.

---

## 4. Vendor Quote Types

Expected quote types:

| Quote Type | Example |
| ---------- | ------- |
| POS Base Quote | Toss POS, OKPOS |
| Payment Device Quote | Toss Front, VAN terminal, PAYCO-linked device |
| Kiosk Quote | Toss kiosk, third-party kiosk, small vendor kiosk |
| Table Order Quote | t-order-like vendor, POS dealer table order |
| Integration Quote | OKDC, Toss API, provider gateway |
| Support Quote | dealer support, installation, A/S |
| Optional Channel Quote | PAYCO payment, smart-order channel |
| Hardware Quote | printer, scanner, terminal, tablet, kiosk body |
| Maintenance Quote | monthly fee, support, updates |

Each quote must be recorded with the same structure.

---

## 5. Quote Record Fields

Each quote record should include:

- quote id
- quote date
- vendor name
- vendor category
- contact person
- contact channel
- quoted products
- hardware list
- software list
- installation cost
- monthly cost
- transaction fee
- maintenance fee
- support terms
- contract term
- cancellation term
- API access availability
- data access availability
- KDS/kitchen output path
- payment/refund ownership
- dealer/support ownership
- integration limitations
- rollback possibility
- future Mini Kiosk compatibility
- evidence attachments
- reviewer
- decision status

---

## 6. Quote ID Format

Recommended quote id format:

    QUOTE-[VENDOR]-[YYYYMMDD]-[NUMBER]

Examples:

    QUOTE-TOSS-20260612-001
    QUOTE-OKPOS-20260612-001
    QUOTE-KIOSK-20260612-001
    QUOTE-PAYCO-20260612-001

Final naming may be normalized later during PC import.

---

## 7. Vendor Categories

Vendor category values:

- `POS_PROVIDER`
- `PAYMENT_PROVIDER`
- `KIOSK_PROVIDER`
- `TABLE_ORDER_PROVIDER`
- `POS_DEALER`
- `VAN_DEALER`
- `HARDWARE_VENDOR`
- `API_PROVIDER`
- `SUPPORT_VENDOR`
- `HYBRID_VENDOR`
- `UNKNOWN`

A vendor may have multiple categories.

Example:

    OKPOS dealer = POS_DEALER + SUPPORT_VENDOR
    Toss = POS_PROVIDER + PAYMENT_PROVIDER + KIOSK_PROVIDER
    PAYCO = PAYMENT_PROVIDER + SMART_ORDER_CHANNEL
    Small kiosk vendor = KIOSK_PROVIDER + possibly POS_DEALER_DEPENDENT

---

## 8. Decision Candidates

All vendor quotes should be grouped into decision candidates.

### 8.1 Candidate A: Toss Base

Structure:

    Toss POS / Toss payment / Toss device
        + Yoonsul backend later
        + Yoonsul Mini Kiosk later

### 8.2 Candidate B: OKPOS Base

Structure:

    OKPOS POS ledger
        + OKDC later
        + Yoonsul backend later

### 8.3 Candidate C: OKPOS Ledger Plus Toss Surface

Structure:

    OKPOS as POS ledger
        + Toss payment or kiosk surface
        + Yoonsul provider gateway later

### 8.4 Candidate D: Third-Party Kiosk Plus Existing POS

Structure:

    Small kiosk vendor
        + OKPOS or other POS
        + limited integration

### 8.5 Candidate E: Yoonsul Mini Kiosk Later

Structure:

    Yoonsul Mini Kiosk
        + Toss / OKPOS / PAYCO adapter
        + Yoonsul backend

Candidate E is usually not immediate first-store setup unless implementation is ready.

---

## 9. Comparison Dimensions

Each candidate must be scored across these dimensions:

| Dimension | Meaning |
| --------- | ------- |
| Operational Fit | Can the store run daily operations smoothly? |
| Data Access | Can Yoonsul access required order/payment/menu/state data? |
| Payment Boundary | Are approval, cancel, refund, settlement clear? |
| KDS/Kitchen Fit | Is kitchen output clear and future KDS possible? |
| Mini Kiosk Compatibility | Can future Mini Kiosk integrate safely? |
| Provider Neutrality | Does it avoid hard vendor lock-in? |
| Support Ownership | Is installation/A/S responsibility clear? |
| Cost | Are setup and recurring costs acceptable? |
| Integration Complexity | How hard is API/daemon/provider integration? |
| Recovery Readiness | Can timeout/failure/duplicate states be recovered? |
| Rollback Feasibility | Can the setup be disabled or replaced? |
| Franchise Scalability | Can this scale beyond one store? |
| Evidence Availability | Are official docs/quotes/support confirmations available? |

---

## 10. Scoring Scale

Recommended score:

| Score | Meaning |
| ----- | ------- |
| 5 | Strong fit / verified |
| 4 | Good fit / minor uncertainty |
| 3 | Usable / needs confirmation |
| 2 | Risky / significant uncertainty |
| 1 | Poor fit |
| 0 | Unknown or not provided |

Do not use weighted total alone.

A low score in payment boundary, KDS boundary, rollback, or support ownership may block adoption even if total score is high.

---

## 11. Blocking Dimensions

The following dimensions are blocking if unresolved:

- payment approval ownership
- refund/cancel ownership
- KDS/kitchen output path
- data access for order/payment
- support ownership
- rollback possibility
- vendor contract risk
- integration permission
- security/credential handling
- duplicate order/payment prevention

If any blocking dimension is unknown, the candidate cannot be final-selected.

It may remain under review.

---

## 12. Toss Quote Review

Toss quote must be reviewed for:

- POS product scope
- payment device scope
- kiosk availability
- API availability
- webhook availability
- merchant/store mapping
- order/payment lookup
- kitchen output
- settlement reports
- refund/cancel process
- support channel
- device replacement
- installation cost
- monthly fee
- transaction fee
- integration limitations
- Mini Kiosk compatibility

Toss quote is strong only if it supports store operation and future Yoonsul backend integration.

---

## 13. OKPOS Quote Review

OKPOS quote must be reviewed for:

- POS package
- dealer support
- kitchen printer setup
- receipt printer setup
- VAN terminal
- table order compatibility
- kiosk compatibility
- OKDC availability
- OKDC cost
- OKDC contract requirement
- OKDC pilot requirement
- menu/order/payment data access
- cancellation/refund path
- local daemon dependency
- support ownership
- installation cost
- monthly fee
- future Yoonsul compatibility

OKPOS quote is strong only if it provides operational stability and does not block future integration.

---

## 14. Toss Plus OKPOS Coexistence Review

If considering Toss plus OKPOS, verify:

- which system owns POS ledger
- which system owns payment approval
- which system owns order creation
- which system owns refund
- which system owns cancellation
- which system owns settlement
- which system owns kitchen output
- whether duplicate orders can occur
- whether duplicate payments can occur
- whether Toss and OKPOS support the setup
- whether the dealer supports the setup
- whether Yoonsul can receive required data
- whether rollback is possible

This candidate must not be selected if ownership boundaries are unclear.

---

## 15. PAYCO Quote Review

PAYCO quote or channel proposal must be reviewed for:

- payment API availability
- merchant setup
- reservation/approval flow
- callback flow
- refund/cancel flow
- WebView/app bridge need
- smart-order scope
- login identity boundary
- settlement report
- support channel
- transaction cost
- integration cost
- Mini Kiosk payment UI fit

PAYCO should not be scored as primary POS base unless new evidence proves POS ledger capability.

---

## 16. Small Kiosk Vendor Review

Small kiosk vendor proposals must be reviewed carefully.

Check:

- which POS systems are supported
- whether support is direct or dealer-mediated
- whether order data is accessible
- whether payment state is accessible
- whether refund/cancel state is accessible
- whether KDS/kitchen output is visible
- whether the kiosk vendor owns backend or only device UI
- whether APIs are available
- whether vendor lock-in exists
- whether failure recovery is documented
- whether duplicate payment/order prevention exists
- whether data can be exported
- whether Yoonsul backend can integrate later

Small kiosk vendor is risky if it only provides visible UI but hides integration details.

---

## 17. Cost Comparison Structure

Cost comparison should include:

| Cost Type | Notes |
| --------- | ----- |
| Initial hardware | POS, terminal, printer, kiosk, tablet |
| Installation | dealer setup, network, wiring |
| Software monthly | POS software, kiosk software |
| API / integration fee | OKDC, provider API, custom work |
| Transaction fee | payment fee, VAN fee |
| Maintenance | support, updates, warranty |
| Replacement | device failure cost |
| Cancellation | contract cancellation fee |
| Expansion | second store / franchise cost |
| Hidden support | dealer visit, after-hours support |

Do not compare only initial installation cost.

---

## 18. Data Access Comparison Structure

For each candidate, record:

| Data | Available | Method | Limitation |
| ---- | --------- | ------ | ---------- |
| Menu | Yes/No/Unknown | API/manual/export | Notes |
| Sold-out | Yes/No/Unknown | API/manual | Notes |
| Order | Yes/No/Unknown | API/webhook/daemon | Notes |
| Payment | Yes/No/Unknown | API/webhook/VAN | Notes |
| Cancel | Yes/No/Unknown | API/manual | Notes |
| Refund | Yes/No/Unknown | API/manual | Notes |
| Table | Yes/No/Unknown | POS/daemon/manual | Notes |
| Kitchen | Yes/No/Unknown | KDS/printer/POS | Notes |
| Settlement | Yes/No/Unknown | report/API | Notes |
| Error State | Yes/No/Unknown | API/support/log | Notes |

Unknown data access should be treated as risk.

---

## 19. Support Comparison Structure

For each candidate, record:

- POS issue owner
- payment issue owner
- kiosk issue owner
- network issue owner
- printer issue owner
- KDS issue owner
- API issue owner
- refund dispute owner
- after-hours owner
- training owner
- replacement owner
- escalation contact
- expected response time
- support cost

If support ownership is split, the split must be explicit.

---

## 20. Adoption Decision Record

When selecting a candidate, create an Adoption Decision Record.

Recommended title:

    ADR-STORE-POS-[YYYYMMDD]-[NUMBER]

Required fields:

- decision id
- decision date
- decision scope
- selected candidate
- selected vendors
- selected hardware
- selected software
- selected support partner
- alternatives reviewed
- reasons selected
- reasons rejected
- cost summary
- data access summary
- payment/refund boundary
- KDS/kitchen boundary
- Mini Kiosk impact
- provider-neutrality impact
- unresolved risks
- blockers accepted
- rollback plan
- review owner
- approval status
- next review date

---

## 21. Adoption Decision Status

Recommended decision statuses:

- `DRAFT`
- `UNDER_REVIEW`
- `NEEDS_VENDOR_CONFIRMATION`
- `NEEDS_COST_CONFIRMATION`
- `NEEDS_TECH_CONFIRMATION`
- `BLOCKED`
- `SELECTED_FOR_FIRST_STORE`
- `SELECTED_WITH_CONDITIONS`
- `REJECTED`
- `DEFERRED`
- `SUPERSEDED`

Do not mark selected until blocking dimensions are resolved or explicitly accepted.

---

## 22. Conditional Selection Rule

A candidate may be selected with conditions only if:

- conditions are written
- owner is assigned
- due date is set
- fallback exists
- risk is accepted
- implementation is not blocked by unresolved critical unknowns

Example conditions:

- OKDC availability must be confirmed before Yoonsul backend integration.
- Toss webhook access must be confirmed before API implementation.
- Dealer support scope must be documented before store opening.
- KDS path must be verified before adding Mini Kiosk.

Conditional selection is not final integration approval.

---

## 23. Vendor Evidence Attachments

Quote comparison should preserve:

- written quote
- product brochure
- hardware list
- support terms
- API documentation reference
- contract draft
- dealer message
- vendor email
- screenshots where allowed
- installation plan
- cost table
- warranty terms
- cancellation terms

Sensitive information should be masked before broader sharing.

---

## 24. Review Cadence

During first-store preparation:

- update quote comparison when new quote arrives
- review major candidates weekly if active
- review blockers before signing contract
- review rollback before installation
- review support contacts before opening
- review integration impact before implementation

A vendor quote older than 30 days should be rechecked before signing.

---

## 25. Anti-Patterns

The following are prohibited:

- selecting vendor based only on monthly fee
- selecting vendor based only on market share
- selecting vendor based only on UI appearance
- selecting vendor based only on dealer confidence
- ignoring data access
- ignoring refund/cancel ownership
- ignoring KDS path
- ignoring support ownership
- ignoring rollback
- hiding unresolved blockers
- treating verbal sales claims as official evidence
- treating small kiosk demo as integration proof
- selecting Toss-only while future OKPOS compatibility is ignored
- selecting OKPOS-only while future Toss base is abandoned
- selecting hybrid stack without ownership boundary

---

## 26. Non-Goals

This document does not decide:

- final store vendor
- final POS stack
- final payment stack
- final kiosk stack
- final support partner
- final contract
- final installation schedule
- final implementation authorization

Those belong to later procurement decision and controlled implementation entry.

---

## 27. Readiness Check

This document is ready when the project can answer:

1. What quote types must be recorded?
2. What fields must quote records include?
3. What candidates are compared?
4. What comparison dimensions are used?
5. What scoring scale applies?
6. Which dimensions are blocking?
7. How is Toss quote reviewed?
8. How is OKPOS quote reviewed?
9. How is Toss plus OKPOS reviewed?
10. How is PAYCO reviewed?
11. How is small kiosk vendor reviewed?
12. How is cost compared?
13. How is data access compared?
14. How is support compared?
15. What is an adoption decision record?
16. What decision statuses exist?
17. When is conditional selection allowed?
18. What evidence attachments are preserved?
19. What anti-patterns are prohibited?

If these questions cannot be answered, vendor quote comparison and adoption decision planning is incomplete.

---

## 28. Conclusion

The first-store vendor decision must be evidence-based.

The project must compare Toss, OKPOS, Toss plus OKPOS, PAYCO, kiosk vendors, dealers, and support partners by:

- operational fit
- data access
- payment/refund boundary
- KDS/kitchen path
- Mini Kiosk compatibility
- provider neutrality
- support ownership
- cost
- recovery readiness
- rollback
- franchise scalability
- evidence availability

The current strategic posture remains:

- Toss as primary base direction
- OKPOS as required compatibility path
- PAYCO as optional payment channel
- small kiosk vendors only if integration transparency is proven
- Yoonsul backend runtime as the long-term owner of handoff, audit, recovery, and modularity

No vendor should be adopted without a written decision record.