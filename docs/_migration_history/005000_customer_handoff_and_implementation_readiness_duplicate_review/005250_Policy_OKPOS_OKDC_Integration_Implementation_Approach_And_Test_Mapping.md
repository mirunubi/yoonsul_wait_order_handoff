# 005250_Policy_OKPOS_OKDC_Integration_Implementation_Approach_And_Test_Mapping

\#\# 1\. Purpose

This document defines the implementation approach, runtime boundary, test mapping, evidence requirement, blocker structure, and MVP cutline for OKPOS OKDC integration in the Yoonsul Wait/Order Handoff project.

The previous document revised the first-phase provider cutline:

\- Toss Place represents cloud Open API / webhook POS integration.  
\- OKPOS represents domestic POS market coverage and local daemon / OKDC integration.  
\- PAYCO remains a payment / smart-order / login channel candidate.

This document focuses on OKPOS OKDC.

It does not implement OKDC integration.

It defines how OKPOS should be approached before future controlled implementation.

\---

\#\# 2\. Scope

This document covers:

\- OKPOS OKDC integration approach  
\- OKDC local daemon boundary  
\- OKDC partner process boundary  
\- OKDC public versus dedicated integration distinction  
\- table order / kiosk / mobile POS / DID relevance  
\- POS/KDS handoff mapping  
\- local failure and timeout handling  
\- payment/order/cancel boundary  
\- merchant/store mapping  
\- test catalog mapping  
\- evidence requirements  
\- blocker register  
\- MVP cutline  
\- no-implementation boundary

This document does not cover:

\- actual OKDC source code  
\- actual OKDC DLL loading  
\- actual OKDC daemon communication  
\- actual OKPOS contract  
\- actual production store setup  
\- actual KDS ticket creation  
\- actual payment processing  
\- actual database schema  
\- actual Android kiosk implementation  
\- actual Windows POS installation

\---

\#\# 3\. Core Principle

OKPOS integration must be treated as a local POS-connected provider integration, not a simple cloud API integration.

The project must follow this rule:

\> OKDC daemon, POS local state, partner certification, and store network reliability are part of the OKPOS integration boundary. Yoonsul must not treat OKDC events as trusted backend truth until mapping, idempotency, audit, and recovery controls are defined.

OKPOS may be strategically important because of market coverage.

That does not remove the need for strict boundary control.

\---

\#\# 4\. Source Context

OKPOS OKDC is understood as a provider integration path connecting OKPOS software with external partner systems.

The reported integration targets include:

\- table order  
\- kiosk  
\- mobile POS  
\- DID  
\- external partner systems

The reported architecture includes:

\- OKDC daemon  
\- OKDC DLL or interface component  
\- local POS-connected communication  
\- partner process  
\- specification review  
\- development  
\- test scenario submission  
\- OKPOS internal verification  
\- pilot store application  
\- production rollout

These must be officially verified before implementation.

\---

\#\# 5\. OKPOS Runtime Positioning

OKPOS should be classified as:

    FIRST\_PHASE\_LOCAL\_POS\_DAEMON\_PROVIDER

Runtime category:

    LOCAL\_DAEMON\_POS\_BRIDGE

Primary value:

\- domestic POS market coverage  
\- table order / kiosk relevance  
\- incumbent POS ecosystem access  
\- practical franchise compatibility  
\- local POS/KDS bridge learning

Primary risk:

\- partner access required  
\- local daemon dependency  
\- local POS PC dependency  
\- store network dependency  
\- DLL/runtime compatibility  
\- pilot certification requirement  
\- order/payment mutation ambiguity  
\- failure ownership ambiguity

\---

\#\# 6\. OKDC Conceptual Architecture

Recommended conceptual architecture:

\- OKPOS POS Software  
  \- owns local POS transaction context where OKPOS is deployed  
  \- interacts with store POS database / local POS runtime  
  \- may manage table/order/payment state depending on configuration

\- OKDC Daemon  
  \- runs locally near POS environment  
  \- mediates communication between OKPOS and partner system  
  \- must be treated as local integration component  
  \- is not Yoonsul backend truth by itself

\- OKDC Interface / DLL  
  \- may expose supported integration functions  
  \- must be officially verified  
  \- must not be reverse engineered  
  \- must not be loaded without certified contract

\- Yoonsul OKPOS Integration Gateway  
  \- future controlled backend/local bridge boundary  
  \- maps OKPOS identifiers to Yoonsul tenant/store  
  \- validates order/payment events  
  \- enforces idempotency  
  \- records evidence  
  \- quarantines ambiguous state

\- Yoonsul POS/KDS Bridge  
  \- creates Yoonsul handoff candidate after validation  
  \- does not let OKDC directly create KDS truth  
  \- prevents duplicate kitchen tickets

\---

\#\# 7\. OKPOS Integration Lanes

OKPOS should be split into lanes:

\#\#\# 7.1 Partner Verification Lane

Covers:

\- OKPOS contact  
\- OKDC eligibility  
\- contract/fee model  
\- public versus dedicated integration  
\- official documents  
\- certification process  
\- pilot store requirement

\#\#\# 7.2 Local Daemon Lane

Covers:

\- OKDC daemon installation  
\- daemon lifecycle  
\- local network dependency  
\- POS PC dependency  
\- version compatibility  
\- failure monitoring

\#\#\# 7.3 Interface Lane

Covers:

\- DLL or API contract  
\- supported commands  
\- supported events  
\- data schema  
\- timeout rule  
\- idempotency rule  
\- error codes

\#\#\# 7.4 Order Lane

Covers:

\- menu/master data  
\- order registration  
\- order update  
\- order cancellation  
\- table assignment  
\- kitchen output

\#\#\# 7.5 Payment Lane

Covers:

\- payment processing if supported  
\- payment reference  
\- payment cancel/refund  
\- settlement implication  
\- VAN dependency  
\- local terminal dependency

\#\#\# 7.6 Kiosk/Table Order Lane

Covers:

\- table order integration  
\- kiosk order integration  
\- mobile POS integration  
\- DID integration  
\- mini kiosk reuse

\---

\#\# 8\. OKPOS Authority Boundary

OKPOS authority must be separated from Yoonsul authority.

| Area | OKPOS May Own | Yoonsul Must Own |  
| \---- | \------------- | \---------------- |  
| Local POS transaction | OKPOS local POS runtime | Yoonsul mapping and audit |  
| OKDC communication | OKDC daemon/interface | Integration gateway evidence |  
| Table order support | OKPOS-supported interface | Customer/session boundary |  
| Payment local handling | OKPOS/VAN where applicable | Payment state mapping and reconciliation |  
| Kitchen print/output | OKPOS local output where configured | Yoonsul KDS handoff truth |  
| Store operation | OKPOS local operational state | Yoonsul runtime policy and recovery |

OKPOS local state may be important.

But Yoonsul must not silently accept it without controlled mapping.

\---

\#\# 9\. Merchant / Store Mapping

OKPOS integration requires explicit mapping.

Candidate mapping fields:

\- okpos\_partner\_id  
\- okpos\_store\_id  
\- okdc\_service\_id  
\- okdc\_installation\_id  
\- pos\_terminal\_id  
\- tenant\_id  
\- store\_id  
\- legal\_entity\_id  
\- operating\_group\_id  
\- environment  
\- integration\_type  
\- contract\_status  
\- pilot\_status  
\- daemon\_status  
\- active\_from  
\- active\_until  
\- last\_verified\_at

Rules:

\- Unknown OKPOS store id must be quarantined.  
\- Sandbox/test store must be separated from production.  
\- One OKPOS contract must not automatically grant tenant-wide access.  
\- Store mapping changes must be audited.  
\- OKDC daemon identity must not replace Yoonsul device trust.  
\- POS terminal id must not replace Yoonsul store context.

\---

\#\# 10\. Order Mapping

OKPOS order integration must define:

\- external order id  
\- OKPOS order id  
\- table id  
\- order sequence  
\- item list  
\- option list  
\- quantity  
\- price  
\- tax  
\- discount  
\- order status  
\- cancellation status  
\- kitchen output status  
\- received timestamp  
\- POS accepted timestamp  
\- Yoonsul handoff id

Rules:

\- OKPOS order registered does not automatically mean Yoonsul KDS ticket created.  
\- OKPOS kitchen print does not automatically mean Yoonsul KDS accepted.  
\- Yoonsul must prevent duplicate ticket creation.  
\- Order update must not overwrite payment/refund truth.  
\- Late OKDC order result must create review if customer flow expired.  
\- Failed OKDC order registration must create recovery state.

\---

\#\# 11\. Payment Mapping

OKPOS payment integration must be verified before inclusion.

Possible payment states:

\- OKPOS\_PAYMENT\_NOT\_USED  
\- OKPOS\_PAYMENT\_PENDING  
\- OKPOS\_PAYMENT\_APPROVED  
\- OKPOS\_PAYMENT\_FAILED  
\- OKPOS\_PAYMENT\_CANCELLED  
\- OKPOS\_PAYMENT\_REFUND\_REVIEW\_REQUIRED  
\- OKPOS\_PAYMENT\_RECONCILIATION\_REQUIRED

Rules:

\- OKPOS order success is not payment success unless officially verified.  
\- OKPOS payment success must map to Yoonsul payment runtime.  
\- Refund and cancellation must be separated.  
\- VAN terminal approval must be reconciled.  
\- Payment failure must not create KDS ticket unless unpaid kitchen policy exists.  
\- Payment approval evidence must be stored without exposing sensitive data.

\---

\#\# 12\. KDS / Kitchen Boundary

OKPOS may interact with kitchen output through local POS mechanisms.

Yoonsul must still preserve KDS boundary.

Rules:

\- Local kitchen print is not Yoonsul KDS truth.  
\- OKPOS order registration is not Yoonsul KDS ticket unless mapped.  
\- Duplicate OKDC order registration must not duplicate kitchen output.  
\- If OKPOS creates kitchen output directly, Yoonsul must mark the source as external/local POS originated.  
\- If Yoonsul creates KDS ticket independently, conflict with OKPOS kitchen output must be prevented.  
\- One order must not create two kitchen execution tracks.

Recommended state:

    EXTERNAL\_POS\_KITCHEN\_OUTPUT\_DETECTED

if OKPOS kitchen output exists outside Yoonsul KDS.

\---

\#\# 13\. Local Daemon Failure Handling

OKDC local daemon introduces failure modes.

Potential failures:

\- daemon not running  
\- daemon version mismatch  
\- POS PC turned off  
\- store network unavailable  
\- POS business state closed  
\- DLL load failure  
\- local socket failure  
\- timeout  
\- duplicate send  
\- partial order registration  
\- response lost  
\- local POS accepted but Yoonsul response lost  
\- Yoonsul sent but OKPOS rejected  
\- OKPOS accepted but KDS not synchronized

Required handling:

\- detect failure  
\- mark uncertainty  
\- prevent duplicate send  
\- provide retry policy  
\- provide staff review  
\- record evidence  
\- do not silently mutate payment or KDS state

\---

\#\# 14\. Timeout Handling

Timeout handling must be explicitly defined.

Recommended states:

\- OKDC\_REQUEST\_SENT  
\- OKDC\_RESPONSE\_RECEIVED  
\- OKDC\_TIMEOUT  
\- OKDC\_RESPONSE\_LOST  
\- OKDC\_ACCEPTANCE\_UNCERTAIN  
\- OKDC\_RETRY\_PENDING  
\- OKDC\_RETRY\_BLOCKED  
\- OKDC\_REVIEW\_REQUIRED

Rules:

\- Timeout does not prove failure.  
\- Timeout does not prove success.  
\- Timeout requires lookup or review if available.  
\- Retrying without idempotency is prohibited.  
\- Customer UI must not create a second payment/order blindly.  
\- KDS duplicate prevention must run before retry.

\---

\#\# 15\. Mini Kiosk / Kiosk Reuse

OKPOS is highly relevant to Mini Kiosk and Kiosk because OKDC reportedly supports table order, kiosk, mobile POS, and DID use cases.

Kiosk reuse areas:

\- table order registration  
\- kiosk order submission  
\- local POS acceptance  
\- local daemon health  
\- table occupancy / lock behavior  
\- kitchen output conflict  
\- timeout recovery  
\- customer payment timing  
\- local network recovery  
\- staff intervention

Mini Kiosk must not directly talk to OKDC daemon unless architecture explicitly approves it.

Preferred approach:

    Mini Kiosk \-\> Yoonsul Backend / Gateway \-\> OKPOS Integration Boundary \-\> OKDC

not:

    Mini Kiosk \-\> OKDC directly

\---

\#\# 16\. OKPOS Test Mapping

OKPOS must map into existing test catalog areas:

| Test Catalog | OKPOS Mapping |  
| \------------ | \------------- |  
| Tenant/Store RLS | OKPOS store id to tenant/store validation |  
| Audit Append Only | OKDC event evidence and mutation history |  
| POS/KDS Idempotency | duplicate order registration, duplicate KDS output |  
| Payment/Reconciliation | OKPOS payment/refund/cancel mapping |  
| Device Trust | OKDC daemon and POS device trust separation |  
| Local Agent Recovery | local daemon failure and degraded recovery |  
| Vendor Integration | OKPOS contract, credential, partner scope |  
| Export/AI | OKPOS data minimization |  
| Deployment Gate | daemon/version rollout and rollback |  
| Evidence Packet | partner verification, pilot test, timeout proof |

\---

\#\# 17\. Required Future Tests

Required future OKPOS tests:

1\. Unknown OKPOS store id is quarantined.  
2\. Wrong tenant/store mapping is denied.  
3\. OKDC daemon unavailable creates recovery state.  
4\. POS business closed state blocks or reviews order.  
5\. Duplicate order send does not duplicate POS order.  
6\. Duplicate OKDC response does not duplicate KDS ticket.  
7\. Timeout creates uncertain state, not success/failure.  
8\. Retry requires idempotency.  
9\. Local POS accepted but Yoonsul response lost creates review.  
10\. Yoonsul sent but OKPOS rejected creates recovery.  
11\. OKPOS accepted but KDS conflict creates review.  
12\. Payment success does not bypass Yoonsul payment mapping.  
13\. Order cancellation does not automatically refund.  
14\. Refund does not silently cancel kitchen output.  
15\. Kitchen print and Yoonsul KDS ticket cannot both duplicate execution.  
16\. OKDC daemon identity does not replace Yoonsul device trust.  
17\. OKPOS data is masked in logs/evidence.  
18\. Pilot evidence is required before production rollout.  
19\. Version mismatch blocks or reviews integration.  
20\. Rollback disables OKPOS integration safely.

\---

\#\# 18\. Evidence Requirements

OKPOS evidence packets must include:

\- official OKPOS document reference  
\- partner confirmation where applicable  
\- OKDC version  
\- daemon installation requirement  
\- interface/DLL specification reference  
\- store mapping decision  
\- test store or pilot store reference  
\- order registration result  
\- payment mapping result where applicable  
\- timeout result  
\- duplicate prevention result  
\- kitchen output result  
\- local failure result  
\- rollback/disable result  
\- reviewer  
\- sensitive data review

Evidence must not include:

\- partner secret  
\- API key  
\- DLL binary  
\- proprietary specification copied beyond allowed scope  
\- raw customer personal data  
\- raw payment data  
\- raw VAN terminal secret  
\- POS database credential  
\- unrestricted local POS logs

\---

\#\# 19\. Initial OKPOS Blockers

Initial blockers:

| Blocker ID | Severity | Description |  
| \---------- | \-------- | \----------- |  
| BLOCK-OKPOS-001 | Critical | Official OKDC document and partner access must be obtained |  
| BLOCK-OKPOS-002 | Critical | OKDC daemon/interface communication contract must be verified |  
| BLOCK-OKPOS-003 | Critical | OKPOS store id to Yoonsul tenant/store mapping must be defined |  
| BLOCK-OKPOS-004 | High | OKDC timeout and retry behavior must be verified |  
| BLOCK-OKPOS-005 | Critical | Duplicate order and duplicate KDS prevention must be defined |  
| BLOCK-OKPOS-006 | High | Local POS business open/closed state handling must be verified |  
| BLOCK-OKPOS-007 | High | OKPOS payment/cancel/refund semantics must be verified if payment is in scope |  
| BLOCK-OKPOS-008 | High | Kitchen output/KDS conflict boundary must be defined |  
| BLOCK-OKPOS-009 | Medium | OKDC cost/contract/pilot process must be verified |  
| BLOCK-OKPOS-010 | Critical | Production rollout cannot proceed without OKPOS pilot evidence |

\---

\#\# 20\. Deferred Scope

Recommended deferred scope:

| Deferred ID | Scope |  
| \----------- | \----- |  
| DEFER-OKPOS-001 | Direct Mini Kiosk to OKDC daemon communication |  
| DEFER-OKPOS-002 | Direct DLL implementation before official partner contract |  
| DEFER-OKPOS-003 | Direct hardware terminal control through OKPOS |  
| DEFER-OKPOS-004 | Automated refund via OKPOS before semantics verified |  
| DEFER-OKPOS-005 | Franchise-wide rollout before pilot evidence |  
| DEFER-OKPOS-006 | Universal POS adapter abstraction before Toss \+ OKPOS evidence |

\---

\#\# 21\. MVP / First-Phase Cutline

First-phase OKPOS scope should include:

\- official verification  
\- partner process documentation  
\- OKDC daemon boundary  
\- store mapping model  
\- order registration boundary  
\- timeout/retry model  
\- KDS conflict model  
\- kiosk/table order reuse boundary  
\- evidence packet planning  
\- pilot readiness checklist

First-phase OKPOS scope should not include:

\- production integration  
\- direct DLL implementation  
\- direct Mini Kiosk to OKDC communication  
\- automated refund  
\- direct hardware terminal control  
\- franchise rollout  
\- universal POS adapter

\---

\#\# 22\. Controlled Implementation Entry Rule

OKPOS controlled implementation may begin only when:

1\. Official OKDC documentation is available.  
2\. Partner access requirements are known.  
3\. OKDC daemon/interface contract is verified.  
4\. Store mapping is defined.  
5\. Order registration behavior is verified.  
6\. Timeout behavior is verified.  
7\. Duplicate prevention strategy is defined.  
8\. KDS/kitchen output boundary is defined.  
9\. Payment/cancel/refund behavior is verified if in scope.  
10\. Pilot store requirement is known.  
11\. Evidence packet exists.  
12\. Blockers are reviewed.  
13\. Runtime owners are assigned.  
14\. Rollback/disable path is defined.

If any critical item is missing, implementation remains blocked.

\---

\#\# 23\. Comparison With Toss

OKPOS and Toss represent different integration families.

| Area | Toss | OKPOS |  
| \---- | \---- | \----- |  
| Architecture | Cloud Open API / webhook | Local daemon / OKDC bridge |  
| Access Model | Developer/merchant API | Partner process / OKDC access |  
| Failure Mode | rate limit, webhook replay, cloud sync | daemon down, POS PC down, local network, timeout |  
| Identity Mapping | merchantId | OKPOS store/partner/service identifiers |  
| KDS Risk | duplicate webhook/ticket | duplicate local order/kitchen output |  
| Kiosk Fit | backend-first | local POS/table order/kiosk fit |  
| Implementation Risk | API/security/webhook | partner/local runtime/certification |

Both are needed for first-phase learning.

\---

\#\# 24\. Anti-Patterns

The following are prohibited:

\- treating OKDC as a simple public REST API without verification  
\- reverse engineering OKDC DLL or daemon  
\- scraping OKPOS UI  
\- reading local POS database without contract  
\- letting Mini Kiosk connect directly to OKDC in MVP  
\- treating timeout as failure without lookup/review  
\- retrying order registration without idempotency  
\- creating duplicate kitchen output  
\- assuming OKPOS order cancel equals refund  
\- storing OKPOS credentials in kiosk  
\- treating local POS PC as central truth  
\- bypassing Yoonsul audit because OKPOS has local logs  
\- rolling out to stores before pilot evidence

\---

\#\# 25\. Non-Goals

This document does not define:

\- OKDC source code  
\- DLL integration code  
\- daemon installation procedure  
\- final OKPOS contract  
\- final pilot store plan  
\- final table order implementation  
\- final kiosk implementation  
\- final payment implementation  
\- final production rollout

Those belong to later controlled implementation and partner onboarding.

\---

\#\# 26\. Readiness Check

This document is ready when the project can answer:

1\. What is OKPOS runtime category?  
2\. Why is OKPOS first-phase now?  
3\. What is OKDC conceptual architecture?  
4\. What integration lanes exist?  
5\. What authority boundary applies?  
6\. How is OKPOS store mapped to Yoonsul store?  
7\. How is OKPOS order mapped?  
8\. How is OKPOS payment handled?  
9\. How is KDS/kitchen boundary protected?  
10\. What local daemon failures are expected?  
11\. How is timeout handled?  
12\. How is OKPOS reused for kiosk?  
13\. What test catalogs apply?  
14\. What OKPOS tests are required?  
15\. What evidence is required?  
16\. What blockers exist?  
17\. What scope is deferred?  
18\. What is first-phase cutline?  
19\. When may OKPOS implementation begin?  
20\. How does OKPOS differ from Toss?

If these questions cannot be answered, OKPOS OKDC integration approach is incomplete.

\---

\#\# 27\. Conclusion

OKPOS must be treated as a first-phase provider because it represents the dominant domestic local POS-connected integration family.

However, OKPOS is not the same as Toss.

Toss teaches cloud Open API and webhook integration.

OKPOS teaches local daemon, POS-installed bridge, partner certification, table order/kiosk integration, timeout recovery, and local POS/KDS conflict handling.

The Yoonsul Wait/Order Handoff project must preserve the following rules:

\- OKPOS integration requires official OKDC verification  
\- OKDC daemon is not automatically backend truth  
\- Mini Kiosk must not directly connect to OKDC in MVP  
\- store mapping must be explicit  
\- timeout creates uncertainty  
\- duplicate order and duplicate KDS output must be blocked  
\- payment/cancel/refund semantics must be verified  
\- local kitchen output must not conflict with Yoonsul KDS  
\- pilot evidence is required before rollout  
\- OKPOS must remain behind controlled integration boundary

This document prepares OKPOS OKDC for future controlled implementation planning without implementing it.