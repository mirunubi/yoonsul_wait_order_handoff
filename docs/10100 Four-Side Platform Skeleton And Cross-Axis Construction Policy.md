# 10100 Four-Side Platform Skeleton And Cross-Axis Construction Policy

## 1. Purpose

This document defines the Four-Side Platform Skeleton and Cross-Axis Construction Policy.

The previous planning sequence `10020~10057` completed the first major skeleton for:

- Modular SaaS Core
- Catch Menu
- Mini Kiosk
- Full Kiosk
- Admin Surface
- Franchise OS future reuse
- Static authorization gate

That sequence defined one side of the building.

This document opens the next architectural phase: creating the remaining structural sides before detailed insulation, wiring, plumbing, runtime logic, provider execution, UI implementation, or operational automation is added.

The purpose is to build the platform skeleton first.

This document is planning-only.

It does not authorize coding.

---

## 2. Building Metaphor

The platform must not be built by decorating one wall while the other walls are missing.

The correct construction order is:

1. Build the four structural sides.
2. Connect the corners.
3. Define load-bearing beams.
4. Define safe openings.
5. Add insulation.
6. Add wiring.
7. Add plumbing.
8. Add interior systems.
9. Add runtime equipment.
10. Open to customers only after safety inspection.

In platform terms:

- skeleton first
- runtime later
- integration later
- automation later
- AI later
- production last

---

## 3. Four-Side Skeleton Model

The platform skeleton should be divided into four major sides:

| Side | Name | Role |
|---|---|---|
| Side A | Product Surface And SaaS Product Line Skeleton | Catch Menu, Mini Kiosk, Kiosk, Admin, Franchise OS |
| Side B | Operational Runtime And Store Execution Skeleton | POS, KDS, Kitchen, Staff, Device, Store Runtime |
| Side C | Financial Security And Trust Skeleton | Payment, settlement, refund, wallet, audit, evidence, containment |
| Side D | Data Intelligence And Governance Skeleton | i18n, CMS, AI, pgvector, analytics, support, policy, compliance |

The previous `10020~10057` sequence mainly completed Side A.

The next work should build Sides B, C, and D at skeleton level.

---

## 4. Side A Closure Summary

Side A is now defined at planning level.

Side A includes:

- Catch Menu
- Catch & Order
- Mini Kiosk
- Full Kiosk
- Product Surface Registry
- Capability Matrix
- SaaS Package Entitlement
- Admin Surface Reuse
- Franchise OS future handoff
- Static artifact authorization gate

Side A remains planning-only.

It does not authorize static file creation or runtime implementation.

---

## 5. Side B: Operational Runtime And Store Execution Skeleton

Side B should define how the store actually operates.

It should include:

- Store Runtime
- POS boundary
- KDS boundary
- kitchen ticket flow
- staff assist flow
- device runtime
- printer/peripheral boundary
- local degraded operation
- manual fallback
- incident lane
- order state visibility
- fulfillment state visibility
- store-level recovery route
- operations evidence packet

Side B is not implementation.

Side B defines operational beams.

---

## 6. Side C: Financial Security And Trust Skeleton

Side C should define financial-grade trust and containment.

It should include:

- payment truth boundary
- POS accepted versus payment confirmed boundary
- settlement boundary
- refund boundary
- coupon/point/wallet/prepaid boundary
- compensation review boundary
- idempotency
- reconciliation
- evidence packet
- fraud/abuse prevention
- secret handling
- provider trust boundary
- containment and quarantine
- financial audit
- legal/security review

Side C must follow financial-grade security assumptions.

Payment is never just a UI feature.

---

## 7. Side D: Data Intelligence And Governance Skeleton

Side D should define data, language, content, AI, and governance boundaries.

It should include:

- i18n registry
- customer-visible message governance
- CMS content governance
- AI advisory boundary
- pgvector context boundary
- analytics/read model boundary
- support/admin visibility
- policy registry
- compliance mapping
- data retention
- privacy/masking
- training and SOP publication
- incident learning
- provider evidence knowledge base

Side D must separate intelligence from authority.

AI is not authority.

pgvector is not proof.

---

## 8. Corner Connections

The four sides must connect through explicit corner rules.

| Corner | Connection |
|---|---|
| A-B | Product Surface to Store Runtime |
| B-C | Store Runtime to Financial Trust |
| C-D | Financial Trust to Data Governance |
| D-A | Governance to Product Surface |

Each corner must prevent uncontrolled crossing.

A surface must not directly execute store runtime.

Store runtime must not directly assert financial truth.

Financial evidence must not be replaced by AI or analytics.

Governance must shape product visibility without bypassing authority.

---

## 9. Side A To Side B Corner Rule

Product Surface to Store Runtime must pass through Use Case API and Safe Projection.

Examples:

- Catch Menu may show menu state but must not mutate kitchen state directly.
- Mini Kiosk may request order intent but must not create POS/KDS truth directly.
- Full Kiosk may submit request but server-side workflow decides.
- Admin Surface may request config change but policy decides.
- Franchise OS may assemble capabilities but does not execute store tasks directly.

Surface request is not execution.

---

## 10. Side B To Side C Corner Rule

Store Runtime to Financial Trust must pass through financial verification.

Examples:

- POS accepted does not mean payment confirmed.
- KDS completed does not mean settlement completed.
- Staff assisted does not mean refund approved.
- Store incident does not mean compensation approved.
- Device success does not mean transaction success.

Operational completion is not financial truth.

---

## 11. Side C To Side D Corner Rule

Financial Trust to Data Governance must pass through masking, evidence, audit, and policy.

Examples:

- payment payload must not be exposed as raw admin data
- refund decision must not be generated by analytics alone
- compensation pattern must not become automatic approval
- fraud signal must not become legal conclusion
- AI summary must not replace payment evidence
- vector similarity must not replace reconciliation

Data can assist.

Evidence decides.

Authority approves.

---

## 12. Side D To Side A Corner Rule

Data Governance to Product Surface must pass through Safe Projection and i18n.

Examples:

- CMS content must be approved before customer display.
- AI draft must be reviewed before publication.
- i18n keys must govern visible text.
- degraded operation messages must be safe and non-blaming.
- provider limitation must not be exposed as customer-facing blame.
- analytics insight must not become customer promise.

Governance shapes visibility.

It does not bypass product surface policy.

---

## 13. Cross-Axis Load-Bearing Beams

The platform requires common load-bearing beams across all sides:

1. Tenant Context
2. Store Context
3. Device Context
4. Surface Context
5. Provider Context
6. Policy Context
7. Authority Context
8. Evidence Context
9. Audit Context
10. i18n Context
11. Runtime State Context
12. Fallback Context
13. Reconciliation Context
14. Support Context
15. Franchise Context

Every future document should identify which beams it touches.

---

## 14. Runtime Deferral Rule

All four sides remain planning-only until separately authorized.

The skeleton documents may define:

- boundaries
- responsibilities
- state names
- context models
- dependency maps
- blocker lists
- validation rules
- approval gates
- fallback principles

They must not define:

- executable code
- production schema
- provider calls
- payment execution
- POS/KDS runtime
- AI runtime
- pgvector runtime
- deployment steps
- live credentials

Skeleton is not construction completion.

---

## 15. Recommended Next Skeleton Documents

The next structural documents should be:

| Document | Axis |
|---|---|
| `10110 Store Runtime POS KDS Kitchen Execution Skeleton Policy` | Side B |
| `10120 Payment Settlement Refund Wallet Financial Trust Skeleton Policy` | Side C |
| `10130 CMS i18n AI pgvector Data Governance Skeleton Policy` | Side D |
| `10140 Cross-Axis Authority Evidence Audit And Fallback Beam Policy` | Cross-beam |
| `10150 Four-Side Skeleton Closure And Runtime Deferral Policy` | Closure |

This creates the remaining building frame before detailed systems are inserted.

---

## 16. Anti-Patterns

Avoid:

- building Full Kiosk before Store Runtime skeleton
- building payment before Financial Trust skeleton
- building AI before Data Governance skeleton
- building Admin mutation before Authority skeleton
- building provider integration before Evidence skeleton
- building CMS publication before i18n/message governance
- building POS/KDS handoff before fallback/reconciliation
- building Franchise OS before cross-axis context is stable
- treating one product surface as the whole platform
- treating static catalog as runtime implementation

The platform must be framed before it is wired.

---

## 17. Validation Checklist

Validation must confirm:

1. Four-side skeleton model is defined.
2. Side A is acknowledged as planning-complete.
3. Side B is identified as operational runtime skeleton.
4. Side C is identified as financial trust skeleton.
5. Side D is identified as data governance skeleton.
6. Corner connection rules are defined.
7. Cross-axis load-bearing beams are listed.
8. Runtime deferral rule is preserved.
9. Recommended next skeleton documents are identified.
10. Coding remains unauthorized.
11. Runtime remains deferred.

---

## 18. Relationship To Previous Documents

This document follows the closure of:

- `10020~10057 Product Surface, SaaS, Mini Kiosk, Admin Reuse, and Static Authorization Planning Sequence`

It prepares the next skeleton sequence:

- `10110 Store Runtime POS KDS Kitchen Execution Skeleton Policy`
- `10120 Payment Settlement Refund Wallet Financial Trust Skeleton Policy`
- `10130 CMS i18n AI pgvector Data Governance Skeleton Policy`
- `10140 Cross-Axis Authority Evidence Audit And Fallback Beam Policy`
- `10150 Four-Side Skeleton Closure And Runtime Deferral Policy`

This document is structural planning only.

It does not authorize coding.

---

## 19. Final Rule

The platform must now be framed as a four-side structure.

Side A, the Product Surface and SaaS Product Line skeleton, has been planned.

The next phase must build Side B, Side C, and Side D skeletons, then connect them with authority, evidence, audit, policy, fallback, i18n, and runtime state beams.

No detailed wiring, runtime implementation, provider integration, payment execution, POS/KDS execution, CMS publication, AI runtime, pgvector runtime, or production deployment is authorized until the skeleton is closed and a separate explicit authorization packet is approved.
