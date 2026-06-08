# 20010 SaaS Data Capture And Governance Principle

## 1 Purpose

This document defines how SaaS runtime data may be captured and governed for future analytics, CRM, advertising, Agent, and Franchise OS use.

It is documentation-only.
It does not define SQL, migrations, app code, Supabase functions, ad serving, CRM automation, AI recommendation runtime, Franchise OS ingestion, or external data transfer.

Active MVP data capture exists first for operational handoff, staff confirmation, audit, and recovery.

## 2 Data Capture Categories

Conceptual data capture categories:

- tenant configuration data.
- company, legal_entity, operating_group, and store context data.
- `customer_session`.
- `waiting_session`.
- `handoff_session`.
- `mini_kiosk_session`.
- menu browsing and menu interest.
- `order_candidate`.
- `preorder_request`.
- staff confirmation, rejection, and correction.
- Store Agent status and event.
- printer output attempt and result.
- POS API attempt and result.
- manual recovery.
- audit event.
- package plan and feature flag configuration.
- integration profile and payment profile.

## 3 Critical Distinction Rules

- order candidate does not equal confirmed order.
- menu interest does not equal purchase.
- handoff event does not equal POS transaction.
- printer output does not equal POS sales creation.
- POS API attempt does not equal POS order success.
- Store Agent delivery does not equal staff confirmation.
- customer notification does not equal fulfilled order.
- operational signal does not equal financial truth.
- benefit preview does not equal redemption.
- future point placeholder does not equal active loyalty ledger.

## 4 Franchise Intelligence Material

Future franchise intelligence material may include:

- waiting-to-order conversion rate.
- waiting abandonment.
- order candidate completion ratio.
- staff confirmation delay.
- Mini Kiosk language usage.
- foreign visitor menu pattern.
- photo menu interaction.
- Store Agent, printer, and POS API failure rate.
- recovery reason patterns.
- package plan performance.
- feature flag performance.
- store type performance.

These materials are future candidates only.
They do not grant runtime authority or external transfer permission.

## 5 Governance Requirements

- capture purpose must be documented.
- data category must be classified.
- tenant and store scope must be preserved.
- customer-identifiable data must be minimized.
- sensitive fields must be access-controlled.
- export must be audited.
- retention policy must be defined before production.
- future analytics should prefer aggregate, anonymized, or pseudonymized data.
- raw data must not be reused without policy, contract, and legal review.

## 6 Non-MVP Boundary

The first MVP does not include:

- ad engine.
- CRM automation.
- AI recommendation runtime.
- Franchise OS direct ingestion.
- cross-tenant benchmark sharing.
- raw customer data transfer to external solutions.

## 7 Open Decisions

- final data classification labels.
- customer-identifiable field minimization depth.
- retention period by tenant, store, and event category.
- export approval role.
- whether store-level analytics can be enabled before tenant-level analytics.
- whether cross-tenant benchmarks are ever allowed.
- future contract model for Franchise OS intelligence material.

## 8 Current Status

Status: active SaaS data governance principle.

