# 05201_Policy_POS_Payment_Provider_Document_Folder_Grouping_And_Kiosk_Reuse

## 1. Purpose

This document defines the folder grouping, document bundling, reuse boundary, and future mini kiosk / kiosk development linkage policy for POS/payment provider integration documents in the Yoonsul Wait/Order Handoff project.

Recent documents covering Toss, PAYCO, provider priority, MVP cutline, and Phase 2 POS expansion are not only payment integration documents.

They are also future reusable materials for:

- Mini Kiosk
- full kiosk
- customer self-order
- table-side ordering
- payment provider selection
- POS handoff
- KDS ticket creation
- local device runtime
- Android/WebView payment UI
- provider-specific SDK boundaries
- franchise deployment modularization

Therefore, these documents must be grouped carefully on PC import so that future kiosk development can reuse them without searching through unrelated security/test catalog documents.

This document does not move files, create folders, implement kiosk code, or define final directory structure.

It defines the grouping policy for later PC-side organization.

---

## 2. Scope

This document covers:

- provider document grouping
- Toss/PAYCO/OKPOS future grouping
- Mini Kiosk reuse
- Kiosk reuse
- POS/payment module reuse
- Android/WebView reuse
- Windows POS channel reuse
- hardware terminal deferral
- provider investigation folder rule
- MVP versus Phase 2 folder separation
- PC import folder recommendation
- cross-reference policy

This document does not cover:

- actual folder creation
- actual file moving
- actual Git commit
- actual kiosk implementation
- actual payment implementation
- actual POS adapter code
- actual Android project
- actual WebView code
- actual hardware integration

---

## 3. Core Principle

Provider integration documents should be grouped by reusable development module, not only by document number.

The project must follow this rule:

> Documents about Toss, PAYCO, OKPOS, POS providers, payment provider openness, and MVP provider cutline must be preserved as a reusable provider-integration knowledge bundle for future Mini Kiosk and Kiosk modules.

This prevents provider research from being trapped inside one handoff lane.

---

## 4. Documents To Bundle

The following documents should be grouped together on PC import:

| No | Document | Bundle Role |
| --- | -------- | ----------- |
| 05095 | Toss POS Integration Implementation Approach And Test Mapping Policy | Toss provider integration base |
| 05150 | Toss POS Official Verification Checklist And Integration Evidence Policy | Toss official verification checklist |
| 05170 | PAYCO POS Integration Implementation Approach And Official Verification Policy | PAYCO provider integration base |
| 05180 | POS Payment Provider Integration Priority Matrix And Openness Assessment Policy | Provider comparison and priority |
| 05190 | MVP Provider Cutline And Phase 2 POS Expansion Deferral Policy | MVP/Phase 2 provider scope control |
| 05200 | POS Payment Provider Document Folder Grouping And Kiosk Reuse Policy | Folder grouping and kiosk reuse rule |

Optional related documents:

| No | Document | Relationship |
| --- | -------- | ------------ |
| 05010 | Payment Webhook Refund Settlement Reconciliation Test Catalog Policy | Payment verification tests |
| 05000 | POS KDS RPC Bridge Idempotency Replay Test Catalog Policy | POS/KDS bridge tests |
| 05080 | Vendor Partner Access External Integration Test Catalog Policy | Vendor integration tests |
| 05090 | Secure Deployment Release Gate Rollback Test Catalog Policy | Release gate tests |
| 05160 | Controlled Implementation Entry Gate And Build Authorization Policy | Build entry rule |

Optional related documents should be cross-referenced, not necessarily moved into the provider bundle.

---

## 5. Recommended PC Folder Grouping

Recommended folder grouping:

    docs/
      05000_provider_integration_and_kiosk_reuse/
        README.md
        05095_Policy_Toss_POS_Integration_Implementation_Approach_And_Test_Mapping.md
        05151_Policy_Toss_POS_Official_Verification_Checklist_And_Integration_Evidence.md
        05170_Policy_PAYCO_POS_Verification.md
        05180_Policy_Provider_Priority_Openness.md
        05191_Policy_MVP_Provider_Cutline_And_Phase_2_POS_Expansion_Deferral.md
        05201_Policy_POS_Payment_Provider_Document_Folder_Grouping_And_Kiosk_Reuse.md

Alternative folder name:

    docs/provider_integration_kiosk_reuse/

The final folder name may be normalized later.

---

## 6. Why This Bundle Matters For Mini Kiosk

Mini Kiosk development will need:

- payment provider choice
- QR/barcode payment possibility
- Android/WebView payment UI decision
- whether to use external app bridge
- whether backend approval is required
- whether order can be sent to KDS before payment
- whether payment reservation is enough
- how to handle callback/retry
- how to handle customer cancellation
- how to prevent duplicate KDS tickets
- how to separate provider login from payment
- how to handle local device identity
- how to handle provider-specific UI limitations

The Toss/PAYCO provider documents already contain these boundaries.

Therefore, they should be reused rather than rewritten.

---

## 7. Why This Bundle Matters For Full Kiosk

Full kiosk development will need:

- hardware terminal integration decision
- VAN/CAT device deferral or certification
- payment device versus backend payment separation
- Android tablet versus Windows kiosk choice
- WebView security policy
- local storage restriction
- receipt printing boundary
- order display and KDS handoff
- payment failure recovery
- refund/cancel boundary
- support recovery
- deployment and rollback gate

PAYCO Windows Smart Order and Android WebView analysis are especially relevant for kiosk hardware/platform decisions.

Toss Open API/Webhook analysis is especially relevant for backend event-driven kiosk integration.

---

## 8. Reuse Boundary

These provider documents may be reused for:

- Mini Kiosk payment provider selection
- Kiosk payment flow planning
- POS provider onboarding
- smart order channel design
- Android WebView payment safety
- backend payment reservation/approval design
- webhook/callback idempotency
- provider credential storage
- merchant/store mapping
- KDS ticket duplication prevention
- support evidence design
- provider MVP/Phase 2 cutline

These documents must not be used as:

- final implementation code
- final SDK guide
- final API contract
- final certification proof
- final production approval
- final legal compliance evidence
- final security review

Official provider verification is still required.

---

## 9. Module Mapping

Provider bundle maps to future modules as follows:

| Future Module | Reused Documents |
| ------------- | ---------------- |
| Mini Kiosk Payment Module | 05095, 05170, 05180, 05190 |
| Mini Kiosk Order Handoff Module | 05000, 05095, 05190 |
| Kiosk Android/WebView Module | 05170, 05200 |
| Kiosk Windows/Receipt Module | 05170, 05200 |
| Kiosk Payment Recovery Module | 05010, 05170, 05095 |
| Provider Credential Module | 05080, 05095, 05170 |
| Provider Verification Module | 05150, 05170 |
| Provider Selection Module | 05180, 05190 |
| Phase 2 POS Expansion Module | 05190 |
| Deployment Gate Module | 05090, 05160 |

---

## 10. Index README Recommendation

The provider bundle folder should later include a README.

Recommended README sections:

- Purpose
- Included Documents
- MVP Provider Scope
- Toss Role
- PAYCO Role
- OKPOS / Other POS Role
- Mini Kiosk Reuse
- Kiosk Reuse
- Deferred Scope
- Official Verification Required
- Related Test Catalogs
- Next Phase Triggers

This README should prevent future confusion when PC-side sorting occurs.

---

## 11. MVP Provider Bundle Rule

For MVP, the provider bundle must clearly mark:

- Toss as active MVP candidate
- PAYCO as active MVP candidate
- OKPOS as investigation-only
- other POS providers as Phase 2 candidates
- direct hardware terminal control as deferred
- universal POS adapter as deferred
- Apps in Toss miniapp as deferred unless separately authorized
- PAYCO Android WebView as deferred unless selected
- PAYCO Windows Smart Order direct ingestion as deferred

This prevents kiosk development from accidentally broadening MVP scope.

---

## 12. Mini Kiosk Reuse Notes

Mini Kiosk should reuse these principles:

- provider UI is not payment truth
- backend approval is payment truth
- order reservation is not payment approval
- auth callback is not payment approval
- login is not payment
- duplicate callback must not duplicate order
- KDS ticket must be idempotent
- cancellation is not refund unless verified
- local storage must not contain provider secrets
- device context is not user authority
- payment failure must create recoverable state
- provider-specific UI should be isolated behind module boundary

---

## 13. Kiosk Reuse Notes

Full kiosk should reuse these principles:

- payment terminal control is a certified hardware lane
- Android WebView payment must be security-reviewed
- Windows program integration must not rely on scraping
- printer output is not backend truth
- provider callback must be verified
- KDS handoff must pass internal bridge
- refund/cancel must be separated
- support recovery must exist
- local device loss or failure must not corrupt payment/order truth
- release gate must include rollback/disable path

---

## 14. Future Folder Expansion

When OKPOS or other POS providers are officially verified, create subfolders later:

    docs/
      05000_provider_integration_and_kiosk_reuse/
        providers/
          toss/
          payco/
          okpos/
          other_pos/
        kiosk_reuse/
        mini_kiosk_reuse/
        phase2_candidates/
        evidence/

This is a future suggestion only.

Do not create the expanded structure prematurely.

---

## 15. Cross-Reference Rule

Provider bundle documents should cross-reference:

- POS/KDS bridge test catalog
- payment webhook/refund/settlement test catalog
- vendor integration test catalog
- deployment release gate test catalog
- evidence packet policy
- blocker/waiver/deferred scope policy
- controlled implementation entry policy

Cross-reference is better than duplicating all content.

---

## 16. PC Import Handling

During PC-side import:

1. Keep document numbers unchanged.
2. Normalize filenames to ASCII-safe long names.
3. Place provider bundle documents together.
4. Add README later.
5. Do not merge Toss and PAYCO into one document.
6. Do not delete provisional warnings.
7. Preserve deferred scope notes.
8. Preserve official verification requirement.
9. Preserve MVP/Phase 2 cutline.
10. Cross-reference related test catalog documents.

If uncertain, keep files rather than merging them.

---

## 17. Development Modularity Impact

This bundle supports modular development because it separates:

- provider verification
- provider credential handling
- payment backend
- Android/WebView
- Windows receiving program
- hardware terminal
- POS/KDS handoff
- KDS ticket creation
- support recovery
- deployment gate

This makes it easier to build:

- Toss module
- PAYCO module
- provider abstraction later
- mini kiosk payment module
- kiosk payment module
- provider onboarding module
- Phase 2 POS expansion module

without mixing all provider behavior into the core system.

---

## 18. Non-Goals

This document does not define:

- final folder creation
- final Git commit
- final directory map
- final kiosk architecture
- final mini kiosk architecture
- final provider abstraction
- final Toss implementation
- final PAYCO implementation
- final OKPOS implementation

Those belong to later PC-side organization and controlled implementation design.

---

## 19. Readiness Check

This document is ready when the project can answer:

1. Which provider documents should be bundled together?
2. Why should these documents be reused for Mini Kiosk?
3. Why should these documents be reused for Kiosk?
4. What folder grouping is recommended?
5. What documents are optional cross-references?
6. What should the README contain?
7. What provider scope applies to MVP?
8. What provider scope is deferred?
9. What principles should Mini Kiosk reuse?
10. What principles should full Kiosk reuse?
11. How should OKPOS and future providers be added later?
12. How should PC import handle these files?
13. Why does this support development modularity?

If these questions cannot be answered, provider folder grouping and kiosk reuse planning is incomplete.

---

## 20. Conclusion

The Toss, PAYCO, provider priority, and MVP cutline documents must be grouped as a reusable provider integration bundle.

This bundle is important not only for POS/payment integration but also for future Mini Kiosk and full Kiosk development.

The project should preserve the following rules:

- group provider documents together on PC import
- keep Toss and PAYCO separate
- keep MVP/Phase 2 cutline visible
- keep official verification warnings visible
- keep OKPOS and other providers as Phase 2 candidates
- reuse these documents for Mini Kiosk and Kiosk payment modules
- do not treat provider UI or installed program output as final payment truth
- do not implement universal provider adapter prematurely
- keep Yoonsul internal runtime boundaries first
- use cross-references instead of duplicating test catalog content

This document prepares the provider integration document bundle for later PC organization and kiosk module reuse.