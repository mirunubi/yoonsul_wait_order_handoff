# 14143_Policy_POS_Gateway_Training_Runbook_Field_Operation_Checklist_Store_Readiness_And_Knowledge_Transfer

## 1. Purpose

This document defines the training, runbook, field operation checklist, store readiness, and knowledge transfer policy for the POS Gateway.

The POS Gateway cannot be considered production-ready only because the technical integration works.

Store staff, managers, support operators, reconciliation owners, incident responders, and rollout operators must understand how to operate the gateway safely during:

- normal ordering;
- payment uncertainty;
- POS write failure;
- KDS routing issue;
- refund/cancellation exception;
- sold-out conflict;
- QR/table ordering issue;
- kiosk issue;
- provider outage;
- manual fallback;
- reconciliation variance;
- customer dispute.

This policy exists to ensure that:

- store operation teams know what the POS Gateway does and does not do;
- field staff have short and practical runbooks;
- managers know approval and override boundaries;
- support teams know how to communicate uncertainty;
- rollout teams verify store readiness before activation;
- knowledge transfer is documented and repeatable;
- training completion becomes part of production enablement evidence.

---

## 2. Scope

This policy applies to all POS Gateway training and operational knowledge transfer activities, including:

- store staff training;
- store manager training;
- cashier/front staff training;
- kitchen/KDS staff training;
- support operator training;
- reconciliation owner training;
- incident responder training;
- technical operator training;
- provider onboarding training;
- tenant/store onboarding training;
- kiosk/QR/table ordering operation training;
- manual fallback training;
- refund/cancellation training;
- customer dispute handling training;
- rollout wave field checklist;
- production cutover readiness checklist;
- post-rollout stabilization feedback.

This document governs human readiness and knowledge transfer for POS Gateway operation.

---

## 3. Core Principle

A POS Gateway is only safe when the people operating it know how to respond when automation is uncertain.

Training must focus on real operational decisions:

```text
when to trust automation
when to pause automation
when to call a manager
when not to ask the customer to pay again
when to use manual POS entry
when to verify payment
when to block refund automation
when to preserve evidence
when to escalate incident
when to reconcile before closing
```

Training is not an HR checkbox.  
It is part of transaction safety.

---

## 4. Training Audience Model

Training must be role-specific.

Recommended training audiences:

| Audience | Training Focus |
|---|---|
| `front_staff` | Customer status, manual confirmation, payment uncertainty |
| `cashier` | POS/payment/receipt, duplicate payment prevention |
| `kitchen_staff` | KDS ticket state, manual kitchen fallback, wrong ticket handling |
| `store_manager` | approvals, overrides, refund/cancel, incident coordination |
| `shift_lead` | delegated manager actions during shift |
| `support_operator` | customer dispute and safe communication |
| `reconciliation_owner` | variance review, manual adjustment, audit closure |
| `technical_operator` | provider health, routing, queue, deployment support |
| `incident_commander` | incident command, outage, rollback, continuity mode |
| `tenant_admin` | tenant/store configuration, rollout oversight |
| `field_rollout_operator` | store readiness, cutover, training verification |

Each role must receive only the operational knowledge required for its authority.

---

## 5. Training Level Model

Training must be structured by level.

Recommended levels:

| Level | Meaning |
|---|---|
| `awareness` | Understand basic concept and risk |
| `operator_basic` | Can perform normal workflow |
| `operator_exception` | Can handle common exceptions |
| `manager_control` | Can approve sensitive actions |
| `reconciliation_control` | Can close variance with evidence |
| `incident_control` | Can operate during outage/incident |
| `technical_control` | Can diagnose and control runtime/provider behavior |
| `trainer` | Can train others and verify readiness |

Production activation must define which levels are required for each role.

---

## 6. Training Content Areas

Training content must cover at least:

- order lifecycle;
- POS write lifecycle;
- payment lifecycle;
- cancellation/refund lifecycle;
- KDS routing;
- customer status messages;
- receipt/proof distinction;
- table/session/QR/NFC identity;
- kiosk/device identity;
- sold-out/availability blocking;
- manual fallback;
- manager approval;
- provider outage;
- disaster/continuity mode;
- reconciliation variance;
- evidence preservation;
- incident escalation;
- prohibited actions.

Training must use real store examples, not only system diagrams.

---

## 7. Normal Operation Runbook

Normal operation runbook must explain:

- how an order is accepted;
- how POS confirmation appears;
- how payment confirmation appears;
- how KDS ticket appears;
- how receipt/proof appears;
- how customer status is updated;
- how staff identifies completed vs pending order;
- how staff identifies a blocked order;
- how staff identifies an order needing manual confirmation.

Normal runbook must fit store workflow and be usable during peak operation.

---

## 8. Payment Uncertainty Runbook

Payment uncertainty runbook is mandatory.

It must instruct staff:

```text
do not ask customer to pay again immediately
check payment status first
look for approval/reference evidence
check POS/payment provider where allowed
escalate to cashier/manager/payment owner if uncertain
use safe customer message
create or update manual fallback case
```

The runbook must clearly distinguish:

- payment failed confirmed;
- payment pending;
- payment success confirmed;
- payment unknown;
- duplicate payment risk.

This is one of the most important store safety runbooks.

---

## 9. POS Write Failure Runbook

POS write failure runbook must explain:

- how to identify POS write pending;
- how to identify confirmed failure;
- how to identify unknown result;
- when to retry;
- when not to retry;
- when to perform provider/POS lookup;
- when to use manual POS entry;
- how to link manual POS entry to gateway order;
- how to avoid duplicate POS order;
- how to notify customer safely.

Manual POS entry must preserve original gateway order reference.

---

## 10. KDS Issue Runbook

KDS issue runbook must explain:

- how to confirm KDS ticket received;
- how to detect missing ticket;
- how to detect duplicate ticket;
- how to handle wrong table/channel on ticket;
- how to create manual kitchen instruction;
- how to mark remake or correction;
- how to avoid duplicate cooking;
- how to notify staff/customer.

Kitchen staff must not be forced to infer transaction truth from incomplete screens.

---

## 11. Refund and Cancellation Runbook

Refund/cancellation runbook must explain:

- cancellation before payment;
- cancellation after payment;
- refund requested;
- refund pending;
- refund confirmed;
- refund unknown;
- duplicate refund risk;
- partial refund;
- coupon/point restoration;
- provider-owned refund;
- manual review;
- manager approval threshold.

Staff must not promise refund completion without evidence.

---

## 12. Sold-Out and Availability Runbook

Sold-out and availability runbook must explain:

- how to mark item sold out;
- how to restore availability;
- who can approve restoration;
- how sold-out propagates to channels;
- what to do if customer paid for unavailable item;
- how to communicate sold-out after payment;
- how to create manual fallback or refund review;
- how to record reason.

Availability action must be fast enough for real store operation.

---

## 13. QR / NFC / Table Session Runbook

QR/NFC/table session runbook must explain:

- how table QR/NFC identity works;
- how to identify wrong table issue;
- how to suspend object;
- how to open/close table session;
- how to transfer table;
- how to merge/split session;
- how waiting/preorder handoff works;
- when staff confirmation is required;
- how to avoid wrong table order.

Staff must understand that QR/NFC object identity is not just a visible table number.

---

## 14. Kiosk / Device Runbook

Kiosk/device runbook must explain:

- kiosk device identity;
- device online/offline state;
- payment terminal association;
- order channel behavior;
- receipt behavior;
- how to pause kiosk;
- how to handle kiosk order uncertainty;
- how to route customer to staff;
- how to report device issue.

A kiosk must not continue accepting orders when its store/device identity is uncertain.

---

## 15. Manual Fallback Runbook

Manual fallback runbook must explain:

- what manual fallback means;
- when manual fallback is required;
- what evidence to capture;
- how to perform manual POS entry;
- how to verify payment;
- how to handle KDS manually;
- how to communicate to customer;
- when manager approval is required;
- how to close or escalate fallback case.

Manual fallback must preserve evidence and reconciliation linkage.

---

## 16. Manager Approval Runbook

Manager approval runbook must explain:

- which actions require approval;
- refund/cancel approval thresholds;
- manual price adjustment approval;
- emergency override approval;
- restriction removal approval;
- table/session correction approval;
- evidence export approval;
- how approval is recorded;
- when second approval is required.

Managers must understand that approval is a financial and audit control, not just permission convenience.

---

## 17. Customer Communication Script

Training must include approved customer scripts.

Script areas:

- order pending;
- payment unknown;
- duplicate payment risk;
- POS confirmation pending;
- KDS/preparation delay;
- refund pending;
- cancellation pending;
- sold-out after payment;
- table/session issue;
- provider outage;
- manual staff confirmation.

Scripts must use approved wording and avoid unsupported certainty.

---

## 18. Reconciliation Training

Reconciliation training must cover:

- how variances are detected;
- how to classify variance;
- how to collect evidence;
- how to match transactions;
- how manual fallback affects reconciliation;
- how to handle payment variance;
- how to handle refund/cancel variance;
- how to apply manual adjustment;
- how to close case with evidence;
- when to reopen.

Reconciliation owners must not close cases by making numbers look clean.

---

## 19. Incident Training

Incident training must cover:

- incident severity;
- who becomes incident commander;
- how to preserve evidence;
- how to activate continuity mode;
- how to freeze transaction paths;
- how to communicate to store/customer/support;
- how to escalate provider issue;
- how to resume service;
- how to run post-outage reconciliation;
- how to write postmortem.

Incident training must include drills, not only documentation.

---

## 20. Technical Operator Training

Technical operator training must cover:

- provider health;
- adapter version;
- routing configuration;
- queue state;
- retry/backpressure controls;
- degraded mode;
- feature flags;
- credential reference state;
- monitoring and alerting;
- deployment and rollback;
- configuration drift;
- evidence access boundary.

Technical operators must not perform financial or customer-impact actions outside their authority.

---

## 21. Field Operation Checklist

Before store activation, field operators must verify:

```text
store staff trained
manager trained
cashier trained
kitchen/KDS staff trained
support contact known
manual fallback runbook available
payment uncertainty script understood
refund/cancel approval path known
QR/NFC/table objects verified
kiosk devices verified
POS terminal mapping verified
KDS routing tested
receipt proof checked
sold-out action tested
manual POS entry process tested
incident escalation path tested
```

Checklist completion must become part of onboarding evidence.

---

## 22. Store Readiness Checklist

Store readiness must include both technical and human readiness.

Required readiness areas:

- provider connection ready;
- menu mapping ready;
- price calculation ready;
- availability ready;
- POS write smoke passed;
- payment smoke passed where applicable;
- cancel/refund smoke passed where applicable;
- KDS smoke passed;
- receipt smoke passed;
- staff training completed;
- manager approval path completed;
- manual fallback ready;
- customer communication scripts ready;
- support escalation ready;
- reconciliation owner assigned.

Store must not go live only on technical smoke success.

---

## 23. Training Evidence Record

Training completion must be recorded.

Required fields:

```text
training_record_id
tenant_id
store_id
actor_id
role
training_module
training_level
completed_at
trainer_id
verification_method
score_or_result
expires_at
status
```

Training evidence must be available during readiness review.

Sensitive personal details must be minimized.

---

## 24. Knowledge Transfer Package

Each rollout must produce a knowledge transfer package.

Package should include:

- one-page store operation guide;
- payment uncertainty runbook;
- refund/cancellation runbook;
- manual fallback guide;
- manager approval guide;
- KDS issue guide;
- QR/NFC/table session guide;
- kiosk/device guide;
- incident escalation contacts;
- reconciliation handoff guide;
- FAQ;
- prohibited actions list.

Package must be versioned and store-specific where needed.

---

## 25. Runbook Versioning

Runbooks must be versioned.

Required fields:

```text
runbook_id
runbook_type
version
tenant_id
store_id
provider_scope
approved_by
effective_from
effective_until
status
```

Store staff must not rely on outdated runbooks after major provider, payment, refund, kiosk, or routing changes.

---

## 26. Training Refresh Triggers

Training must be refreshed when:

- new store is onboarded;
- new provider is added;
- payment/refund behavior changes;
- kiosk/QR/table ordering is activated;
- manual fallback policy changes;
- manager approval thresholds change;
- customer message templates change;
- incident reveals training gap;
- recurring manual fallback pattern appears;
- staff role changes;
- rollout wave expands.

Training refresh must be tracked.

---

## 27. Field Feedback Loop

Field feedback must be collected during pilot and rollout.

Feedback sources:

- staff confusion;
- customer questions;
- manual fallback frequency;
- manager approval delays;
- KDS ticket handling issues;
- refund/cancel mistakes;
- payment uncertainty cases;
- QR/table object issues;
- kiosk usability issues;
- support tickets;
- reconciliation variance.

Feedback must be reviewed and converted into:

- runbook update;
- training update;
- UI improvement;
- policy update;
- monitoring alert;
- incident corrective action.

---

## 28. Proficiency Verification

Training must verify practical proficiency where risk is high.

Verification methods:

- checklist confirmation;
- short quiz;
- scenario drill;
- supervised manual fallback;
- simulated payment uncertainty;
- refund/cancel scenario review;
- KDS duplicate ticket drill;
- QR wrong table drill;
- incident escalation drill.

High-risk roles should not rely only on self-attestation.

---

## 29. Store Launch Briefing

Before production launch, a launch briefing must occur.

Briefing must cover:

- launch window;
- enabled channels;
- enabled providers;
- payment behavior;
- refund/cancel restrictions;
- manual fallback mode;
- known limitations;
- escalation path;
- monitoring owner;
- expected stabilization window;
- stop/go criteria.

Store launch briefing must be short but explicit.

---

## 30. Stabilization Knowledge Transfer

After launch, stabilization learning must be shared.

Stabilization review should include:

- first-day issues;
- staff questions;
- customer-impact cases;
- manual fallback cases;
- provider variance;
- refund/cancel cases;
- KDS routing issues;
- QR/kiosk issues;
- reconciliation findings;
- runbook gaps.

Knowledge transfer is not complete until field reality is reflected back into documentation and operation.

---

## 31. Training Metrics

Training and readiness must be measured.

Required metrics:

- training completion rate by role;
- manager approval training completion;
- payment uncertainty drill completion;
- manual fallback drill completion;
- refund/cancel training completion;
- KDS issue training completion;
- QR/kiosk training completion;
- first-week staff error count;
- manual fallback caused by training gap;
- customer communication error count;
- runbook update count;
- field feedback closure rate.

Metrics must be reviewed during rollout stabilization.

---

## 32. Dashboard Requirements

Training/readiness dashboard must show:

- required training modules;
- completion status by store;
- completion status by role;
- expired training;
- missing manager approval training;
- missing payment uncertainty training;
- runbook version in use;
- field checklist status;
- store readiness status;
- launch briefing status;
- stabilization feedback status;
- open training gap actions.

Dashboard must not show store ready when critical role training is missing.

---

## 33. Incident Requirements

Training-related incidents may include:

- staff asked customer to pay again during payment uncertainty;
- refund promised without evidence;
- manual POS entry caused duplicate order;
- KDS duplicate ticket cooked;
- wrong table correction done without evidence;
- manager approval bypassed;
- sold-out not propagated;
- customer message contradicted system state;
- runbook missing during outage;
- support gave unsupported status.

Training incidents must trigger runbook review and refresher training.

---

## 34. Prohibited Practices

The following practices are prohibited:

- going live with no store staff training;
- treating technical smoke test as full store readiness;
- hiding payment uncertainty runbook from cashier/front staff;
- allowing managers to approve refunds without training;
- relying on informal verbal training only;
- using outdated runbook after major release;
- failing to train staff on “do not ask customer to pay again” rule;
- training staff to delete or overwrite evidence;
- closing training gap without field verification;
- ignoring repeated staff confusion as “user error.”

---

## 35. Minimum Acceptance Criteria

Training and knowledge transfer is acceptable only when:

- training audience model exists;
- training level model exists;
- normal operation, payment uncertainty, POS write failure, KDS issue, refund/cancel, sold-out, QR/NFC/table, kiosk/device, manual fallback, and manager approval runbooks exist;
- customer communication scripts exist;
- reconciliation, incident, and technical operator training exist;
- field operation checklist exists;
- store readiness checklist exists;
- training evidence records exist;
- knowledge transfer package exists;
- runbooks are versioned;
- training refresh triggers exist;
- field feedback loop exists;
- proficiency verification exists for high-risk roles;
- launch briefing and stabilization knowledge transfer exist;
- dashboard, metrics, and incident handling exist.

---

## 36. Implementation Notes

Recommended implementation artifacts:

```text
pos_gateway_training_modules
pos_gateway_training_records
pos_gateway_training_levels
pos_gateway_role_training_requirements
pos_gateway_runbooks
pos_gateway_runbook_versions
pos_gateway_store_readiness_checklists
pos_gateway_field_operation_checklists
pos_gateway_knowledge_transfer_packages
pos_gateway_training_refresh_triggers
pos_gateway_field_feedback_records
pos_gateway_proficiency_verifications
pos_gateway_launch_briefings
pos_gateway_stabilization_reviews
pos_gateway_training_gap_actions
pos_gateway_training_incidents
```

Recommended services:

```text
TrainingModuleService
RoleTrainingRequirementService
TrainingRecordService
RunbookVersionService
StoreReadinessChecklistService
FieldOperationChecklistService
KnowledgeTransferPackageService
TrainingRefreshService
FieldFeedbackService
ProficiencyVerificationService
LaunchBriefingService
StabilizationKnowledgeTransferService
TrainingDashboardService
TrainingIncidentService
```

Recommended event types:

```text
pos_gateway.training.module_assigned
pos_gateway.training.completed
pos_gateway.training.expired
pos_gateway.training.refresh_required
pos_gateway.training.runbook_version_updated
pos_gateway.training.store_readiness_check_started
pos_gateway.training.store_readiness_check_completed
pos_gateway.training.field_feedback_submitted
pos_gateway.training.proficiency_verified
pos_gateway.training.launch_briefing_completed
pos_gateway.training.stabilization_review_completed
pos_gateway.training.gap_detected
pos_gateway.training.incident_detected
```

---

## 37. Relationship To Adjacent Documents

This document is related to:

- 06170 POS Gateway change management, release governance, configuration drift control, and production deployment policy;
- 06160 POS Gateway disaster recovery, business continuity, provider outage, store offline mode, and service resumption policy;
- 06150 POS Gateway performance, load, peak traffic, queue backpressure, and capacity planning policy;
- 06140 POS Gateway access control, role segregation, tenant isolation, privileged action, and approval audit policy;
- 06120 POS Gateway reconciliation case workflow, variance resolution, manual adjustment, and audit closure policy;
- 06110 POS Gateway customer status message, receipt proof, notification, and dispute communication policy;
- 06100 POS Gateway staff operation, manual fallback, override authority, and manager approval policy;
- POS Gateway production readiness checklist, smoke test, and operational acceptance policy;
- POS Gateway store rollout, wave control, pilot expansion, field feedback, and stabilization policy.

Where conflict exists, this document governs POS Gateway training, runbook, field operation checklist, store readiness, and knowledge transfer behavior.

---

## 38. Summary

POS Gateway readiness is not complete when code is deployed.

It is complete only when the store can safely operate the gateway during both normal and abnormal conditions.

The correct standard is:

- train by role;
- provide short runbooks;
- verify manager approval knowledge;
- drill payment uncertainty;
- teach manual fallback with evidence;
- capture readiness evidence;
- update runbooks from field feedback;
- retrain after changes and incidents.

A well-trained store can survive gateway uncertainty.  
An untrained store can turn a small uncertainty into a financial, operational, and customer trust incident.