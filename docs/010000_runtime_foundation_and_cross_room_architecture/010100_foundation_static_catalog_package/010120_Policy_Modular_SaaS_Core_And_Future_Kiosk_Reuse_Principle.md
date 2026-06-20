# 010120_Policy_Modular_SaaS_Core_And_Future_Kiosk_Reuse_Principle.md

## Purpose

This document defines the Modular SaaS Core and Future Kiosk Reuse Principle.

The previous static catalog and security foundation documents established security, audit, provider evidence, i18n, customer-safe status, recovery, compensation, AI, pgvector, and runtime-entry boundaries.

This document records the architectural principle that all future modules must be designed as reusable SaaS blocks, and that the financial-grade core foundation must be reusable for future Kiosk, POS, Catch Menu, Catch & Order, Support/Admin, Franchise OS, and external provider integration development.

The goal is not to build isolated applications.

The goal is to build composable blocks.

---

## 2. Core Principle

Every major function must be modular.

Every module must be SaaS-ready.

Every SaaS block must declare:

* authority boundary
* tenant boundary
* store boundary
* provider boundary
* customer-visible boundary
* audit boundary
* i18n boundary
* fallback boundary
* recovery boundary
* security boundary
* runtime permission boundary

A future Kiosk must not be developed as a separate isolated product.

A future Kiosk must reuse the same financial-grade core.

---

## 3. Modular SaaS Rule

All future components should be treated as blocks that can be assembled differently depending on tenant, store, brand, region, provider, device, and operational maturity.

The system must support:

* small store configuration
* franchise configuration
* multi-store tenant configuration
* HQ-controlled configuration
* provider-specific configuration
* kiosk-light configuration
* kiosk-full configuration
* POS-linked configuration
* POS-unlinked fallback configuration
* Catch Menu-only configuration
* Catch & Order configuration
* future Franchise OS configuration

The same core must support different assemblies.

---

## 4. Financial Core Reuse Rule

The financial-grade foundation is not only for payment.

It must be reusable across:

* Kiosk
* POS handoff
* Catch & Order
* Catch Menu
* customer recovery
* refund/coupon/point/wallet review
* order state confirmation
* provider evidence review
* support/admin review
* franchise policy enforcement
* audit/reconciliation
* AI/pgvector advisory review

The future Kiosk must inherit the same security and authority rules.

A Kiosk must not directly become payment truth, order truth, provider truth, customer recovery authority, or compensation authority without evidence and approved boundaries.

---

## 5. Kiosk Reuse Principle

Future Kiosk development should reference the existing foundation documents instead of creating a separate logic stack.

The Kiosk should reuse:

* customer-safe status catalog
* i18n message key registry
* provider evidence registry
* payment boundary rules
* POS/KDS separation rules
* value recovery authority matrix
* support/admin escalation boundaries
* audit and evidence packet rules
* AI non-authority rule
* pgvector non-proof rule
* bulkhead and containment rules
* fallback/degraded operation rules

The Kiosk is a surface.

The core remains shared.

---

## 6. Block Assembly Principle

SaaS must be built as controlled block assembly.

Example block families:

| Block Family           | Reusable Purpose                                      |
| ---------------------- | ----------------------------------------------------- |
| Identity Block         | Customer, staff, tenant, store context                |
| Menu Block             | Menu projection, availability, allergen, price status |
| Order Block            | Order draft, handoff, review, status                  |
| POS Block              | POS acceptance and transaction boundary               |
| Payment Block          | Payment checking, verification, reconciliation        |
| KDS Block              | Kitchen execution visibility                          |
| Recovery Block         | Customer recovery and support routing                 |
| Compensation Block     | Refund/coupon/point/wallet authority                  |
| Provider Block         | External provider evidence and capability             |
| i18n Block             | Locale-aware customer and staff messages              |
| Audit Block            | Evidence, traceability, immutable record              |
| AI Advisory Block      | Draft, summary, missing evidence suggestion           |
| pgvector Context Block | Similar policy/case retrieval, not proof              |
| Franchise Policy Block | HQ/tenant/store policy inheritance                    |

Each block must be independently reviewable.

Each block must be composable.

Each block must avoid hidden authority expansion.

---

## 7. SaaS Tenant Assembly Rule

A tenant must be able to use only the blocks it needs.

Examples:

* Catch Menu only
* Catch Menu + Order handoff
* Catch & Order + POS provider
* Catch & Order + POS + KDS
* Kiosk + POS + payment
* Kiosk + menu only
* Kiosk + staff-assisted payment
* Franchise OS + HQ policy
* Franchise OS + workforce interface
* Franchise OS + provider evidence registry

SaaS value comes from assembling blocks safely, not from copying a separate system per customer.

---

## 8. Device Surface Rule

Different devices may use different surfaces, but the core must remain consistent.

| Surface         | Role                                               |
| --------------- | -------------------------------------------------- |
| Customer mobile | Catch Menu / Catch & Order entry                   |
| QR/NFC table    | Lightweight customer entry                         |
| Kiosk           | Store-facing customer order/payment surface        |
| Staff tablet    | In-store operational review and assistance         |
| Owner admin     | Store-level review and configuration               |
| HQ admin        | Global policy and escalation                       |
| Support/admin   | Review, routing, evidence, customer response draft |
| Franchise OS    | Multi-store policy and operational assembly        |

Device surface does not define authority.

Authority comes from the core.

---

## 9. Kiosk Must Not Become Isolated Hardware Logic

The future Kiosk must not become:

* a separate payment truth system
* a separate order truth system
* a separate customer message system
* a separate compensation system
* a separate provider integration stack
* a separate menu/allergen source
* a separate support workflow
* a separate audit system
* a separate AI decision engine

The Kiosk must be a reusable surface assembled from approved core modules.

---

## 10. Core Invariants To Carry Into Kiosk

The following invariants must carry into Kiosk development:

* Order submitted is not POS accepted.
* POS accepted is not payment confirmed.
* Provider callback is not verified internal state.
* KDS completed is not settlement truth.
* Recovery message is not compensation approval.
* Evidence is not approval.
* AI is not authority.
* pgvector similarity is not proof.
* Customer-visible status is not internal truth.
* Support note is not mutation authority.
* Containment is not resolution.
* Quarantine is not deletion.
* Restore is not mutation.
* Static catalog is not runtime authorization.

These rules must remain unchanged across surfaces.

---

## 11. Long-Term Strategic Meaning

This structure allows the project to evolve from a single operational system into a SaaS platform.

The same foundation can support:

* current Catch Menu
* Catch & Order
* POS bridge
* KDS bridge
* future Kiosk
* future Mini Kiosk
* future Franchise OS
* provider marketplace
* workforce interface
* customer recovery center
* AI support gateway
* pgvector operational memory
* multi-store SaaS configuration

The strength of the system is not one feature.

The strength is the shared core.

---

## 12. Final Rule

All future development must assume modular SaaS assembly.

No future Kiosk, POS, KDS, customer menu, order handoff, support/admin, recovery, compensation, AI, pgvector, or Franchise OS feature should be built as an isolated silo.

The financial-grade core foundation created in the previous documents must be reused as the common control layer.

Kiosk development must reference and inherit the same authority, evidence, audit, i18n, provider, recovery, compensation, AI, pgvector, and runtime-entry boundaries.

The system must be built as blocks.
