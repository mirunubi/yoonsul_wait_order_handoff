# 000805_Policy_POS_Official_API_No_Scraping_And_Provider_Boundary.md

## 1. Purpose

This document defines the official API, no-scraping, no-unofficial-workaround, and provider boundary policy for POS integration.

The purpose is to prevent unsafe, legally risky, operationally fragile, or commercially misleading POS integrations.

A POS integration must not be considered acceptable merely because it appears to work in a local test.

A POS integration is acceptable only when its provider boundary, evidence, security, recovery, reconciliation, and support status are approved.

This document is a policy foundation document.

It is not implementation code.

## 2. Upstream Dependencies

This document depends on:

```text
000801_Boundary_POS_Gateway_Order_Payment_Provider_And_Runtime_Authority.md
000802_Spec_POS_Gateway_Core_Interface_And_Provider_Adapter_Contract.md
000803_Logic_POS_Order_Payment_Cancel_Refund_And_Status_State_Machine.md
000804_Matrix_POS_Provider_Capability_Readiness_And_Support_Status.md
```

The authority boundary, adapter contract, state machine, and provider capability matrix remain upstream standards.

This policy must not redefine those documents differently.

## 3. Core Rule

```text
Official API or provider-approved integration boundary comes first.
Scraping, reverse engineering, undocumented bypass, hidden local automation, and credential misuse are prohibited.
```

Technical possibility does not equal acceptable integration.

A provider must not be represented as officially supported unless the official boundary, capability, test evidence, recovery readiness, reconciliation readiness, security boundary, and release approval are all satisfied.

## 4. Scope

This policy covers:

* official API requirement
* provider-approved integration boundary
* no-scraping rule
* no reverse engineering rule
* no undocumented bypass rule
* local connector boundary
* cloud integration boundary
* manual and semi-manual integration labeling
* credential and authentication boundary
* provider capability limitation disclosure
* unsupported provider handling
* commercial support claim control
* vendor and outsourcing boundary
* evidence requirement
* exception handling

## 5. Non-Scope

This policy does not define:

* actual adapter source code
* provider-specific API payloads
* commercial pricing with providers
* final legal contract language
* production credential storage implementation
* deployment automation
* UI implementation
* SQL schema implementation
* Supabase RLS implementation

Those belong to implementation, legal, security, release, or operations documents.

## 6. Official API First Policy

The preferred integration route is an official, documented, provider-approved API or integration channel.

Official integration may include:

* documented cloud API
* documented local API
* officially provided SDK
* officially provided webhook channel
* officially provided polling endpoint
* officially approved partner integration
* provider-approved local connector
* provider-approved file exchange
* provider-approved terminal or POS connector

The provider boundary must be documented.

The system must record:

* provider name
* official document reference
* API or connector version
* supported capabilities
* unsupported capabilities
* authentication method
* credential scope
* sandbox availability
* production approval requirement
* known limitations
* provider contact or approval reference where applicable

## 7. Provider-Approved Boundary Requirement

A provider integration must operate inside a provider-approved boundary.

A provider-approved boundary means the provider has explicitly documented, exposed, licensed, or approved the integration path.

Examples:

```text
Allowed:
- official REST API
- official webhook
- official SDK
- official local connector
- official partner gateway
- provider-approved test sandbox
- provider-approved file export/import
```

Examples:

```text
Not allowed:
- screen scraping
- DOM scraping
- OCR-based operational scraping
- reverse-engineered local database access
- reverse-engineered network traffic
- hidden automation of provider UI
- private endpoint use without approval
- shared credential abuse
- bypassing provider rate limits
- simulating human operation as API integration
```

## 8. No-Scraping Policy

Scraping must not be used as a production POS integration method.

Prohibited scraping includes:

* scraping POS admin screens
* scraping provider web dashboards
* scraping mobile app screens
* scraping local POS UI
* scraping receipt screens
* scraping network responses not documented for integration
* OCR-based extraction from provider UI
* browser automation pretending to be official API
* headless browser integration
* robotic UI automation against provider systems

Scraping is prohibited because it may:

* violate provider terms
* break without notice
* bypass security assumptions
* produce incomplete evidence
* create duplicate orders or payments
* fail under UI changes
* hide provider limitations
* make recovery and reconciliation unreliable
* create legal and operational risk

## 9. No Reverse Engineering Policy

Reverse engineering must not be used to create production provider integration.

Prohibited reverse engineering includes:

* inspecting undocumented network calls
* using private endpoints
* decoding undocumented local files
* extracting undocumented local database structure
* bypassing authentication flow
* modifying POS client behavior
* exploiting undocumented provider behavior
* using leaked or shared provider credentials
* patching provider binaries or clients

If provider capability cannot be accessed through approved channels, the capability must be marked as unsupported, limited, research, or human review.

## 10. No Undocumented Bypass Policy

Undocumented bypass is prohibited.

Examples of undocumented bypass include:

* using internal provider endpoints without approval
* using employee-only endpoints
* using test endpoints in production
* using partner credentials for unrelated tenants
* bypassing store-level authorization
* bypassing provider approval flow
* bypassing rate limits
* bypassing receipt generation
* bypassing provider cancellation/refund restrictions
* bypassing provider audit trail

The adapter must not depend on undocumented bypass behavior.

## 11. Local Connector Boundary

Some POS providers may require local integration.

Local integration may be acceptable only if:

* the local connector is provider-approved
* installation procedure is documented
* security boundary is documented
* store network requirement is documented
* credential handling is approved
* data flow is documented
* failure mode is documented
* update policy is documented
* monitoring method is documented
* recovery path is documented
* evidence capture is possible
* human approval accepts local operational risk

Local-only integration must be labeled clearly.

Local-only integration must not be presented as cloud-native support.

## 12. Cloud Integration Boundary

Cloud integration may be acceptable only if:

* provider exposes official cloud API or gateway
* authentication and authorization are documented
* rate limits are documented or tested
* webhook or polling behavior is documented
* sandbox or test environment exists or controlled test path is approved
* evidence capture is possible
* recovery and reconciliation are possible
* provider status and outage handling are documented

Cloud integration must not assume provider uptime, response timing, or idempotency without evidence.

## 13. Manual And Semi-Manual Integration Labeling

Manual or semi-manual integration may exist as an operational fallback.

It must be labeled clearly as manual or semi-manual.

Examples:

* staff manually enters mobile order into POS
* staff manually cancels POS order
* staff manually confirms receipt
* staff manually prints kitchen ticket
* staff manually performs refund through provider portal
* staff manually reconciles daily settlement

Manual operation must not be described as API integration.

Semi-manual operation must not be described as official POS automation.

Manual or semi-manual paths require:

* runbook
* role responsibility
* evidence capture
* reconciliation step
* escalation condition
* customer-facing caution where needed

## 14. Credential Boundary

Provider credentials must be handled only through approved security boundaries.

Prohibited:

* embedding production credentials in source code
* sharing credentials with vendors outside approved scope
* storing credentials in local plaintext files
* storing credentials in test screenshots
* using personal provider accounts for production integration
* reusing sandbox credentials in production
* using one tenant credential for another tenant
* sending credentials through chat, email, or unmanaged documents
* allowing adapter code to log secrets

Required:

* approved credential storage
* environment separation
* tenant separation
* least privilege
* rotation capability
* access removal process
* evidence of credential handling
* incident notification rule

## 15. Authentication Boundary

Each provider authentication method must be documented.

Possible authentication methods include:

* API key
* OAuth
* certificate
* signed request
* HMAC
* IP whitelist
* local credential
* partner account
* device registration
* provider-managed token
* unknown

Unknown authentication must remain `Unknown` in the provider capability matrix until verified.

Provider authentication must not be guessed.

## 16. Capability Limitation Disclosure

Provider limitations must be documented.

Examples:

* no refund API
* no cancellation API
* no webhook
* polling only
* no idempotency
* no receipt ID
* no menu sync
* no option sync
* no sold-out sync
* local-only connector required
* cloud API unavailable
* sandbox unavailable
* provider status delayed
* rate limit unknown
* evidence fields incomplete

Known limitations must be reflected in:

```text
000804_Matrix_POS_Provider_Capability_Readiness_And_Support_Status.md
```

Known limitations must also inform:

* adapter contract behavior
* state machine transitions
* retry policy
* recovery policy
* reconciliation policy
* customer-facing promise
* vendor RFP/SOW requirements

## 17. Support Claim Policy

A provider must not be described as officially supported unless approved.

Prohibited claims:

* supported
* fully supported
* integrated
* official integration
* production-ready
* certified
* compatible
* safe for launch

unless evidence and approval exist.

Allowed conservative wording:

* under research
* candidate provider
* limited support candidate
* official verification required
* sandbox verification pending
* field test pending
* unsupported at this time
* manual operation only
* human review required

Marketing, sales, vendor documents, and internal roadmap documents must not overstate support.

## 18. Unsupported Provider Policy

If a provider lacks approved integration boundary, the provider must remain:

```text
Research
Human Review
Limited
Unsupported
```

depending on evidence.

Unsupported provider must not be connected through scraping or undocumented bypass.

Unsupported provider may be handled through manual operation only if approved by policy and clearly documented.

## 19. Vendor And Outsourcing Boundary

Outsourcing vendors may investigate provider capabilities.

Vendors may implement adapters only under approved boundaries.

Vendors must not:

* decide official provider support status
* approve scraping
* approve reverse engineering
* define our state machine
* define our recovery policy
* define our reconciliation policy
* access production DB directly
* use production credentials without approved process
* create hidden bypass implementation
* present unsupported provider as supported
* skip evidence requirements
* modify runtime code outside approved scope

Vendor deliverables must follow both:

```text
docs/000800_pos_gateway_and_provider_integration_foundation/
docs/000900_outsourcing_vendor_handoff_and_acceptance/
```

## 20. Evidence Requirement

Every provider integration path must have evidence.

Required evidence may include:

* official provider document reference
* provider contact or approval reference
* API version reference
* sandbox evidence
* request/response evidence
* adapter behavior evidence
* error behavior evidence
* timeout behavior evidence
* retry evidence
* idempotency evidence
* reconciliation evidence
* recovery evidence
* manual operation evidence
* limitation evidence
* security review evidence
* human approval evidence

Evidence must be retained according to the evidence and audit policy.

## 21. Exception Policy

Exceptions are allowed only through explicit human approval.

An exception must record:

* exception request
* provider name
* requested deviation
* reason
* risk assessment
* affected tenants or stores
* affected customer-facing promise
* affected payment or refund flow
* affected recovery and reconciliation flow
* security review
* legal or contract review if needed
* expiration date
* rollback condition
* reviewer
* approval status

An exception must not silently become permanent support.

## 22. Emergency Fallback Policy

Emergency fallback may be allowed for store continuity.

Examples:

* manual POS entry
* payment-at-counter only
* pause kiosk ordering
* pause mobile ordering
* limited menu
* manual receipt check
* manual refund review
* printed kitchen ticket
* handwritten kitchen ticket

Emergency fallback must not be described as normal integration.

Emergency fallback requires:

* human decision
* evidence
* recovery step
* reconciliation step
* post-incident review

## 23. Release Gate Policy

A provider integration cannot be released unless:

* official or approved boundary is documented
* provider capability matrix is updated
* adapter contract fit is reviewed
* state machine impact is reviewed
* timeout and retry policy is reviewed
* idempotency or duplicate prevention is reviewed
* recovery path is reviewed
* reconciliation path is reviewed
* evidence template is satisfied
* security boundary is approved
* known limitations are documented
* support status is approved
* release owner approves

If any item is missing, the release must remain blocked or limited.

## 24. Relationship To 000900 Outsourcing Package

The outsourcing package under:

```text
docs/000900_outsourcing_vendor_handoff_and_acceptance/
```

must use this policy as an upstream standard.

The vendor-facing RFP/SOW must explicitly state:

```text
No scraping.
No reverse engineering.
No undocumented bypass.
No unauthorized credential use.
No unsupported provider presented as supported.
No production deployment without approval.
```

Vendor acceptance and final handoff must include confirmation that this policy was followed.

## 25. Boundary Violation Examples

The following are boundary violations:

* using screen scraping for POS order creation
* using provider dashboard automation as integration
* reverse engineering private endpoints
* storing provider passwords in source code
* using production credential in sandbox
* using one store credential for another store
* marking unsupported refund as supported
* using manual entry while claiming API integration
* hiding local connector dependency
* ignoring provider rate limits
* bypassing provider approval
* skipping evidence capture
* ignoring unknown provider result
* releasing provider support without capability matrix update
* letting vendor decide official support status

## 26. Required Actions When Violation Is Found

When a violation is found:

1. stop the affected integration path if risk is active
2. preserve evidence
3. classify affected provider and capability
4. identify affected tenants, stores, and transactions
5. determine whether customer, payment, refund, or order state was affected
6. trigger reconciliation if needed
7. trigger manual review if needed
8. rotate credentials if exposed
9. document incident
10. decide rollback, limitation, or rejection
11. update provider capability matrix
12. update vendor acceptance status if vendor was involved

## 27. Acceptance Criteria

This policy is acceptable only if it confirms that:

* official API or provider-approved boundary comes first
* scraping is prohibited
* reverse engineering is prohibited
* undocumented bypass is prohibited
* local-only integration must be labeled
* manual integration must not be described as API support
* credentials must remain controlled
* provider limitations must be documented
* support claims must be evidence-based
* unsupported providers must not be marketed as supported
* vendors cannot approve provider support status
* exception handling requires human approval
* no implementation is authorized by this policy

## 28. Final Rule

```text
A POS integration that works by accident, scraping, reverse engineering, undocumented bypass, credential misuse, or hidden manual operation is not an acceptable integration.
Acceptable POS integration requires an approved provider boundary, verified capability, controlled credentials, recoverable operation, reconcilable evidence, and human-approved support status.
```
