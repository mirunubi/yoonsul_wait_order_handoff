# 14001_Policy_Provider_Register_Phase_Gate_Vendor_Evidence_Tracking

## 1. Purpose

This document defines the provider register, phase gate, vendor evidence tracking, official verification status, and implementation readiness policy for POS, payment, kiosk, table order, API hub, and hardware providers in the Yoonsul Wait/Order Handoff project.

The previous documents established:

- Toss as the primary base direction
- OKPOS as required compatibility interface
- PAYCO as secondary payment / smart-order channel
- Smartro, KICC, NICE, I'M U, Hyphen, and other providers as Phase 2 candidates
- minor POS, dealer networks, hardware terminals, and table order ecosystem expansion as Phase 3 candidates
- provider adapter boundary and canonical event mapping policy

This document defines how these providers must be tracked before implementation.

This document does not implement any provider integration.

It defines register and evidence governance only.

---

## 2. Scope

This document covers:

- provider register structure
- phase classification
- provider status values
- official evidence tracking
- source confidence tracking
- provider priority tracking
- provider blocker tracking
- provider phase gate
- vendor evidence packet linkage
- Mini Kiosk and Kiosk reuse tagging
- first-store adoption relevance
- no-implementation boundary

This document does not cover:

- final provider contracts
- final provider implementation
- final POS adapter code
- final payment gateway code
- final kiosk code
- final table order implementation
- final hardware certification
- final production rollout

---

## 3. Core Principle

No provider may move from research to implementation without register entry, official evidence, phase approval, blocker review, and controlled implementation authorization.

The project must follow this rule:

> Provider interest is not provider readiness. Market relevance is not implementation permission. Official evidence and phase gate approval are required before any provider becomes active implementation scope.

This prevents the project from becoming a chaotic multi-provider integration project.

---

## 4. Provider Register Purpose

The provider register exists to track:

- who the provider is
- what architecture family it belongs to
- which phase it belongs to
- whether it is active, deferred, or investigation-only
- what official documents exist
- what API or SDK path exists
- what risks are unresolved
- what evidence has been collected
- what blockers exist
- whether it affects Mini Kiosk / Kiosk
- whether it affects first-store equipment decision
- whether it can move to implementation later

The register is a planning artifact.

It is not implementation code.

---

## 5. Provider Register ID Format

Recommended provider register ID format:

    PROV-[PHASE]-[CATEGORY]-[NUMBER]

Examples:

    PROV-P1-POS-001
    PROV-P1-POS-002
    PROV-P1-PAY-001
    PROV-P2-POS-001
    PROV-P2-HUB-001
    PROV-P3-HW-001

Alternative short format:

    PROVIDER-001

Final format may be normalized later during PC import.

---

## 6. Provider Register Fields

Each provider register entry should include:

| Field | Description |
| ----- | ----------- |
| Provider ID | Internal provider register id |
| Provider Name | Toss, OKPOS, PAYCO, Smartro, etc. |
| Provider Category | POS, Payment, Table Order, API Hub, Hardware, Dealer Network |
| Architecture Family | Cloud API, Local Daemon, Payment Gateway, API Hub, Hardware |
| Phase | Phase 1, Phase 2, Phase 3 |
| Current Status | Research, Verified, Blocked, Deferred, etc. |
| Strategic Role | Base, compatibility, payment channel, hub, hardware, etc. |
| Market Relevance | High, Medium, Low, Unknown |
| Official Source Status | Official found, missing, outdated, provisional |
| API Access Status | Public, partner-only, unknown, unavailable |
| SDK / Daemon Status | Available, partner-only, unknown, not applicable |
| Webhook / Callback Status | Supported, unsupported, unknown |
| Sandbox Status | Available, partner-only, unknown |
| Merchant Mapping Status | Known, partial, unknown |
| Payment Scope | Supported, partial, unknown, not applicable |
| Order Scope | Supported, partial, unknown, not applicable |
| KDS / Kitchen Scope | Supported, partial, unknown, not applicable |
| Cancel / Refund Scope | Known, partial, unknown |
| Timeout Model | Known, partial, unknown |
| Hardware Dependency | None, optional, required, unknown |
| Dealer Dependency | None, optional, required, unknown |
| Mini Kiosk Relevance | High, Medium, Low |
| Kiosk Relevance | High, Medium, Low |
| First Store Relevance | High, Medium, Low |
| Evidence Packet IDs | Linked evidence references |
| Blocker IDs | Linked blocker references |
| Next Action | Verify, contact, defer, compare, reject |
| Owner | Responsible review role |
| Last Reviewed At | Review date |
| Notes | Controlled notes |

---

## 7. Provider Status Values

Recommended provider status values:

- `NOT_STARTED`
- `RESEARCH_ONLY`
- `OFFICIAL_SOURCE_FOUND`
- `OFFICIAL_VERIFICATION_PENDING`
- `PARTNER_CONTACT_REQUIRED`
- `PARTNER_ACCESS_CONFIRMED`
- `SANDBOX_AVAILABLE`
- `SANDBOX_UNKNOWN`
- `API_CONFIRMED`
- `API_UNCLEAR`
- `IMPLEMENTATION_BLOCKED`
- `DESIGN_READY`
- `CONTROLLED_IMPLEMENTATION_AUTHORIZED`
- `PILOT_REQUIRED`
- `PILOT_READY`
- `PILOT_COMPLETED`
- `PRODUCTION_BLOCKED`
- `DEFERRED`
- `REJECTED_FOR_NOW`
- `OBSOLETE`

Status must be evidence-based.

---

## 8. Phase Classification

### 8.1 Phase 1

Phase 1 providers:

| Provider | Register Role |
| -------- | ------------- |
| Toss Place | Primary base provider |
| OKPOS | Required compatibility interface |
| PAYCO | Secondary payment / smart-order channel |

Phase 1 providers may receive deeper documents and implementation planning, but only after controlled implementation authorization.

### 8.2 Phase 2

Phase 2 providers:

| Provider | Register Role |
| -------- | ------------- |
| Smartro | Local Agent / table order candidate |
| KICC | VAN / payment / EasyPOS candidate |
| NICE | Payment / VAN / POS candidate |
| I'M U | Cloud SaaS POS candidate |
| Hyphen | API hub / marketplace candidate |
| PAYCO deeper channel | Payment / kiosk UI candidate |

Phase 2 providers remain investigation or design candidates until Phase 2 is authorized.

### 8.3 Phase 3

Phase 3 candidates:

- minor POS vendors
- VAN dealer networks
- kiosk vendors
- table order vendors
- DID vendors
- certified hardware terminals
- printers
- scanners
- CAT terminals
- multi-provider abstraction
- API hub production adoption
- franchise rollout provider onboarding

Phase 3 is ecosystem expansion, not MVP.

---

## 9. Initial Provider Register

Initial register entries:

| Provider ID | Provider | Phase | Role | Status |
| ----------- | -------- | ----- | ---- | ------ |
| PROV-P1-POS-001 | Toss Place | Phase 1 | Primary base | OFFICIAL_VERIFICATION_PENDING |
| PROV-P1-POS-002 | OKPOS | Phase 1 | Required compatibility | PARTNER_CONTACT_REQUIRED |
| PROV-P1-PAY-001 | PAYCO | Phase 1 | Secondary payment channel | OFFICIAL_VERIFICATION_PENDING |
| PROV-P2-POS-001 | Smartro / Smile POS | Phase 2 | Local Agent candidate | RESEARCH_ONLY |
| PROV-P2-POS-002 | KICC / EasyPOS | Phase 2 | VAN / POS candidate | RESEARCH_ONLY |
| PROV-P2-PAY-001 | NICE POS / NICE Payments | Phase 2 | Payment / VAN candidate | RESEARCH_ONLY |
| PROV-P2-POS-003 | I'M U / UP POS | Phase 2 | Cloud SaaS POS candidate | RESEARCH_ONLY |
| PROV-P2-HUB-001 | Hyphen | Phase 2 | API hub candidate | RESEARCH_ONLY |
| PROV-P3-ECO-001 | Minor POS Ecosystem | Phase 3 | Broad compatibility | DEFERRED |
| PROV-P3-HW-001 | Certified Hardware Terminals | Phase 3 | Hardware lane | DEFERRED |
| PROV-P3-DEALER-001 | VAN Dealer Network | Phase 3 | Installation/support ecosystem | DEFERRED |

---

## 10. Architecture Family Classification

Provider entries must be classified into architecture family.

| Architecture Family | Providers |
| ------------------- | --------- |
| Cloud Open API | Toss, I'M U |
| Local Daemon / Agent | OKPOS, Smartro |
| Payment Gateway / VAN API | PAYCO, KICC, NICE |
| API Hub / Marketplace | Hyphen |
| Minor POS / Dealer POS | minor POS vendors |
| Hardware Certified Lane | terminals, scanners, printers |
| External Operational Channel | smart order programs, kiosk vendor bridges |

Architecture family affects:

- tests
- evidence
- failure mode
- support runbook
- rollout path
- Mini Kiosk integration
- KDS handoff boundary

---

## 11. Evidence Classes

Provider evidence should be classified.

Recommended evidence classes:

- `OFFICIAL_DOC`
- `DEVELOPER_PORTAL`
- `PARTNER_EMAIL`
- `CONTRACT_TERM`
- `API_SPEC`
- `SDK_SPEC`
- `DAEMON_SPEC`
- `WEBHOOK_SPEC`
- `PAYMENT_SPEC`
- `SANDBOX_ACCESS`
- `TEST_RESULT`
- `PILOT_RESULT`
- `SUPPORT_CONFIRMATION`
- `PRICE_QUOTE`
- `DEALER_CONFIRMATION`
- `HARDWARE_CERTIFICATION`
- `SECURITY_REVIEW`
- `ROLLBACK_REVIEW`

Evidence class must be stored with provider entry.

---

## 12. Evidence Confidence

Each evidence item should have confidence level.

Recommended values:

- `OFFICIAL_CONFIRMED`
- `PARTNER_CONFIRMED`
- `SANDBOX_CONFIRMED`
- `PILOT_CONFIRMED`
- `PUBLIC_BUT_UNVERIFIED`
- `THIRD_PARTY_REPORT`
- `MARKET_OBSERVATION`
- `USER_OBSERVATION`
- `OUTDATED`
- `CONFLICTING`
- `UNKNOWN`

Rules:

- Official confirmed evidence outranks third-party report.
- Partner confirmed evidence outranks market observation.
- User observation is useful but not implementation evidence.
- Outdated evidence requires re-verification.
- Conflicting evidence creates blocker.

---

## 13. Phase Gate Rule

A provider may move to next phase only when required evidence exists.

### 13.1 Move From Research To Design

Requires:

- official source or partner confirmation
- architecture family classification
- scope classification
- basic risk analysis
- blocker list
- owner assigned

### 13.2 Move From Design To Controlled Implementation

Requires:

- official API/SDK/daemon evidence
- tenant/store mapping defined
- credential handling defined
- idempotency source known
- timeout/recovery model known
- payment/order/KDS boundary defined
- test mapping defined
- evidence packet created
- blocker review completed
- authorization record created

### 13.3 Move From Controlled Implementation To Pilot

Requires:

- sandbox/test result
- support runbook
- rollback path
- production blocker review
- provider/dealer confirmation where applicable
- pilot store scope

### 13.4 Move From Pilot To Production

Requires:

- pilot evidence
- incident review
- reconciliation review
- support readiness
- security review
- production release gate approval

---

## 14. Provider Blocker Categories

Provider blockers should be categorized.

Recommended categories:

- `OFFICIAL_SOURCE_BLOCKER`
- `PARTNER_ACCESS_BLOCKER`
- `API_SCOPE_BLOCKER`
- `SDK_ACCESS_BLOCKER`
- `DAEMON_DEPENDENCY_BLOCKER`
- `CREDENTIAL_BLOCKER`
- `MERCHANT_MAPPING_BLOCKER`
- `IDEMPOTENCY_BLOCKER`
- `PAYMENT_FINALITY_BLOCKER`
- `REFUND_CANCEL_BLOCKER`
- `KDS_HANDOFF_BLOCKER`
- `TIMEOUT_RECOVERY_BLOCKER`
- `SANDBOX_BLOCKER`
- `PILOT_BLOCKER`
- `SUPPORT_OWNERSHIP_BLOCKER`
- `COST_CONTRACT_BLOCKER`
- `HARDWARE_CERTIFICATION_BLOCKER`
- `SECURITY_BLOCKER`
- `RELEASE_GATE_BLOCKER`

Provider blockers must be linked to register entries.

---

## 15. Provider Priority Values

Recommended priority values:

- `PRIMARY_BASE`
- `REQUIRED_COMPATIBILITY`
- `SECONDARY_CHANNEL`
- `PHASE2_CANDIDATE`
- `PHASE3_ECOSYSTEM`
- `STORE_SPECIFIC`
- `WATCH_ONLY`
- `REJECT_FOR_NOW`

Current priority:

| Provider | Priority |
| -------- | -------- |
| Toss | PRIMARY_BASE |
| OKPOS | REQUIRED_COMPATIBILITY |
| PAYCO | SECONDARY_CHANNEL |
| Smartro | PHASE2_CANDIDATE |
| KICC | PHASE2_CANDIDATE |
| NICE | PHASE2_CANDIDATE |
| I'M U | PHASE2_CANDIDATE |
| Hyphen | PHASE2_CANDIDATE |
| Minor POS | PHASE3_ECOSYSTEM |
| Hardware | PHASE3_ECOSYSTEM |
| Dealer Network | PHASE3_ECOSYSTEM |

---

## 16. Mini Kiosk Relevance Tagging

Each provider must be tagged for Mini Kiosk relevance.

Recommended values:

- `MINI_KIOSK_CORE`
- `MINI_KIOSK_PAYMENT`
- `MINI_KIOSK_COMPATIBILITY`
- `MINI_KIOSK_DEFERRED`
- `MINI_KIOSK_NOT_RELEVANT`
- `MINI_KIOSK_UNKNOWN`

Current recommendation:

| Provider | Mini Kiosk Tag |
| -------- | -------------- |
| Toss | MINI_KIOSK_CORE |
| OKPOS | MINI_KIOSK_COMPATIBILITY |
| PAYCO | MINI_KIOSK_PAYMENT |
| Smartro | MINI_KIOSK_DEFERRED |
| KICC | MINI_KIOSK_PAYMENT |
| NICE | MINI_KIOSK_PAYMENT |
| I'M U | MINI_KIOSK_DEFERRED |
| Hyphen | MINI_KIOSK_DEFERRED |
| Minor POS | MINI_KIOSK_DEFERRED |
| Hardware | MINI_KIOSK_DEFERRED |

---

## 17. Kiosk Relevance Tagging

Each provider must be tagged for full Kiosk relevance.

Recommended values:

- `KIOSK_CORE`
- `KIOSK_PAYMENT`
- `KIOSK_POS_LEDGER`
- `KIOSK_COMPATIBILITY`
- `KIOSK_HARDWARE`
- `KIOSK_DEFERRED`
- `KIOSK_UNKNOWN`

Current recommendation:

| Provider | Kiosk Tag |
| -------- | --------- |
| Toss | KIOSK_CORE |
| OKPOS | KIOSK_COMPATIBILITY |
| PAYCO | KIOSK_PAYMENT |
| Smartro | KIOSK_COMPATIBILITY |
| KICC | KIOSK_PAYMENT |
| NICE | KIOSK_PAYMENT |
| I'M U | KIOSK_CORE_CANDIDATE |
| Hyphen | KIOSK_PROVIDER_HUB_CANDIDATE |
| Minor POS | KIOSK_DEFERRED |
| Hardware | KIOSK_HARDWARE |

---

## 18. First Store Relevance

Each provider must be tagged for first-store relevance.

Recommended values:

- `FIRST_STORE_PRIMARY`
- `FIRST_STORE_REQUIRED_CHECK`
- `FIRST_STORE_OPTIONAL`
- `FIRST_STORE_DEFERRED`
- `FIRST_STORE_NOT_RELEVANT`

Current recommendation:

| Provider | First Store Tag |
| -------- | --------------- |
| Toss | FIRST_STORE_PRIMARY |
| OKPOS | FIRST_STORE_REQUIRED_CHECK |
| PAYCO | FIRST_STORE_OPTIONAL |
| Smartro | FIRST_STORE_DEFERRED |
| KICC | FIRST_STORE_DEFERRED |
| NICE | FIRST_STORE_DEFERRED |
| I'M U | FIRST_STORE_DEFERRED |
| Hyphen | FIRST_STORE_DEFERRED |
| Minor POS | FIRST_STORE_DEFERRED |
| Hardware | FIRST_STORE_DEFERRED |

---

## 19. Provider Register Update Rule

Provider register must be updated when:

- new official document is found
- provider contract is discussed
- sandbox access is obtained
- API/SDK scope changes
- pricing changes
- dealer confirms capability
- provider compatibility is observed in real store
- blocker is created or resolved
- provider phase changes
- implementation authorization changes
- pilot result is produced
- production release decision occurs

Provider register must not be silently edited without version note.

---

## 20. User Observation Handling

User observations are useful but must be classified correctly.

Examples:

- "A nearby store uses Toss kiosk with OKPOS."
- "A sock store seems to use OKPOS."
- "Small kiosk company appears not integrated."
- "Dealer says this works."
- "Market commonly uses OKPOS."

These should be recorded as:

    USER_OBSERVATION or MARKET_OBSERVATION

They may trigger investigation.

They do not authorize implementation.

---

## 21. Third-Party Report Handling

Third-party reports may inform strategy.

However:

- third-party report is not official provider evidence
- report claims must be verified before implementation
- URLs should be recorded
- conflicts should create blocker
- outdated reports should be marked outdated
- market-share claims should not replace official API evidence

Third-party reports may support phase classification and priority, not production readiness.

---

## 22. Official Source Handling

Official sources include:

- provider developer portal
- provider API documentation
- provider partner guide
- provider contract document
- provider email confirmation
- provider sandbox console
- provider SDK package
- provider support confirmation
- provider certification result

Official source must be linked to provider evidence packet.

---

## 23. Register Storage Recommendation

Recommended future folder:

    docs/
      05000_provider_integration_and_kiosk_reuse/
        provider_register/
          05300_Provider_Register_Phase_Gate_And_Vendor_Evidence_Tracking_Policy.md
          Provider_Register_Index.md
          Provider_Evidence_Log.md
          Provider_Blocker_Register.md

This is a future PC-side organization recommendation only.

Do not create folders during document drafting phase.

---

## 24. Provider Register Example

Example entry:

    Provider ID: PROV-P1-POS-001
    Provider Name: Toss Place
    Category: POS / Payment / Cloud API
    Architecture Family: Cloud Open API
    Phase: Phase 1
    Status: OFFICIAL_VERIFICATION_PENDING
    Priority: PRIMARY_BASE
    Mini Kiosk Relevance: MINI_KIOSK_CORE
    Kiosk Relevance: KIOSK_CORE
    First Store Relevance: FIRST_STORE_PRIMARY
    Evidence: official docs, webhook guide, API key guide
    Blockers: official recheck, sandbox, merchant mapping, production approval
    Next Action: complete official verification checklist

Example entry:

    Provider ID: PROV-P1-POS-002
    Provider Name: OKPOS
    Category: POS / Local Daemon
    Architecture Family: Local Daemon / Agent
    Phase: Phase 1
    Status: PARTNER_CONTACT_REQUIRED
    Priority: REQUIRED_COMPATIBILITY
    Mini Kiosk Relevance: MINI_KIOSK_COMPATIBILITY
    Kiosk Relevance: KIOSK_COMPATIBILITY
    First Store Relevance: FIRST_STORE_REQUIRED_CHECK
    Evidence: OKDC partner guide, user market observation, future partner confirmation
    Blockers: OKDC access, daemon spec, store mapping, pilot, cost
    Next Action: verify OKDC partner process and integration scope

---

## 25. Anti-Patterns

The following are prohibited:

- treating market share as implementation readiness
- treating user observation as official evidence
- treating third-party report as production proof
- moving provider to implementation without register entry
- adding provider because it appears in t-order ecosystem without phase gate
- building adapter before idempotency source is known
- building integration before merchant/store mapping is known
- treating API hub as universal solution without evidence
- treating small kiosk vendor behavior as architecture reference
- allowing provider-specific assumptions into Yoonsul core runtime
- skipping blocker review because provider is strategically important

---

## 26. Non-Goals

This document does not define:

- final spreadsheet
- final database table
- final provider management UI
- final provider adapter
- final vendor contract
- final provider implementation
- final procurement decision
- final hardware purchase
- final production certification

Those belong to later PC-side organization and controlled implementation.

---

## 27. Readiness Check

This document is ready when the project can answer:

1. What is the provider register?
2. Why is provider register required?
3. What fields must a provider entry contain?
4. What provider status values exist?
5. Which providers are Phase 1?
6. Which providers are Phase 2?
7. Which providers are Phase 3?
8. What is the initial provider register?
9. How are architecture families classified?
10. What evidence classes exist?
11. What confidence levels exist?
12. What phase gates apply?
13. What blocker categories exist?
14. What priority values exist?
15. How is Mini Kiosk relevance tagged?
16. How is Kiosk relevance tagged?
17. How is first-store relevance tagged?
18. How are user observations handled?
19. How are third-party reports handled?
20. How are official sources handled?
21. What anti-patterns are prohibited?

If these questions cannot be answered, provider register and evidence tracking is incomplete.

---

## 28. Conclusion

Provider expansion must be controlled through a register.

Yoonsul must not treat every POS, payment, kiosk, table order, API hub, or hardware provider as immediate implementation scope.

The correct structure is:

- Phase 1: Toss base, OKPOS compatibility, PAYCO secondary payment channel
- Phase 2: Smartro, KICC, NICE, I'M U, Hyphen, deeper payment/channel verification
- Phase 3: minor POS, dealer networks, hardware, table order ecosystem, multi-provider abstraction

Each provider must have:

- register entry
- phase classification
- architecture family
- official evidence status
- blocker status
- Mini Kiosk relevance
- Kiosk relevance
- first-store relevance
- evidence confidence

This document prepares the provider ecosystem for disciplined expansion without losing MVP focus.