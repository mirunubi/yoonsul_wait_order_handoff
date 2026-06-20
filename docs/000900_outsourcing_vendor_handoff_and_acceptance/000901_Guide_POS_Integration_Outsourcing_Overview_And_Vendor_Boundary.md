# 000901_Guide_POS_Integration_Outsourcing_Overview_And_Vendor_Boundary.md

## 1. Purpose

This guide explains the overall POS integration outsourcing strategy for OKPOS, Toss POS, and future major POS providers.

## 2. Why POS Outsourcing Is Risky

| Risk | Why it matters |
| --- | --- |
| Financial exposure | Duplicate payment, lost refund, unknown payment state |
| Operational exposure | Duplicate order, missing kitchen ticket, false customer finality |
| Provider divergence | Each POS behaves differently; hidden limitations cause production incidents |
| Authority confusion | Vendor may assume they own business rules if boundaries are vague |
| Recovery gaps | Without reconciliation and evidence, stores cannot recover after timeout |

## 3. Why POS Is Not Just API Integration

POS integration includes:

- order lifecycle across Kiosk, POS, KDS, DID, and CMS surfaces
- payment authorization, cancel, refund, and settlement evidence
- menu, price, option, and sold-out synchronization
- timeout, retry, idempotency, and unknown-state handling
- manual recovery when provider state is uncertain
- audit and evidence for financial and operational review

A vendor connecting one API endpoint does **not** complete POS integration.

## 4. Order Success vs Payment Success

Payment success and order success are **different events**.

| Event | Meaning |
| --- | --- |
| Payment authorized | Funds or payment intent accepted by payment layer |
| POS order confirmed | POS accepted and recorded the order |
| KDS displayed | Kitchen received the ticket |
| Customer finality | Customer was told order/payment is complete with evidence |

Vendor adapters must map provider events without collapsing these into one “success” flag.

## 5. Provider Adapter Boundaries

This outsourcing package does not ask a vendor to design our business system.
It asks the vendor to implement provider-specific POS adapters under our POS Gateway boundary.

Vendor implements **how** to talk to OKPOS, Toss POS, or other providers.
We define **what** order/payment states mean and **who** is source of truth.

## 6. Mandatory Design Topics

Vendor deliverables must address:

- retry rules per operation type
- idempotency keys and duplicate prevention
- recovery and reconciliation after timeout or unknown state
- evidence packets per transaction
- error mapping to normalized adapter errors
- manual recovery hooks when automation cannot proceed

## 7. Vendor Must Not Own Business Policy

Vendor must **not** decide:

- refund approval policy
- cancel policy
- customer-facing finality wording
- tenant permission model
- production deployment approval
- which provider is “officially supported” without our evidence review

## 8. Official API and Provider Boundary

| Required | Prohibited |
| --- | --- |
| Official provider API or officially approved integration path | Scraping, reverse engineering, undocumented bypass |
| Sandbox-first development | Production credential in vendor environment without vault policy |
| Documented capability limits | Hidden workarounds presented as production-ready |

## 9. Documents Vendor Must Read Before Starting

| Document | Why |
| --- | --- |
| `000552_Boundary_...` | Responsibility split |
| `000554_Spec_...` | Adapter interface contract |
| `000555_Logic_...` | State machine and recovery |
| `000556_Policy_...` | Security and access |
| `000508` Phase 3 prelearning | Integration phase boundaries |
| `000506` Phase 1 prelearning | OKPOS/Toss foundation |

## 10. Final Rule

Outsource **adapters**, not **authority**.
All vendor work stays inside POS Gateway adapter boundaries with evidence, reconciliation, and human acceptance.
