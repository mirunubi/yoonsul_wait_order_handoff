# 010465_Policy_Kitchen_IoT_Automation.md

## Purpose

This document defines the Kitchen IoT, UWB Spatial Matching, Auto-SCM, and Physical Automation Expansion Policy.

The previous artifact `10609M` defined realtime sync, AI turnover prediction, local mesh, dynamic pricing, SoftPOS, OCR, NFC payment, and field-control expansion boundaries.

This document adds the physical automation and supply-chain intelligence layer for:

1. Kitchen device orchestration through KDS-to-IoT control.
2. UWB / precise indoor positioning for customer, table, chair, and order matching.
3. Demand-forecast-based inventory and supplier auto-replenishment.
4. Physical AI and device-control boundaries.
5. Chain-of-custody from order/payment to cooking device to inventory depletion to supplier ordering.

The purpose is to ensure that Catch Menu can eventually evolve beyond software order management into a field-operating platform that coordinates kitchen hardware, indoor spatial identity, inventory movement, and supplier replenishment without weakening safety, financial truth, human authority, or tenant isolation.

This document is planning-only.

It does not authorize coding.

This document does not assert that any named external competitor uses the exact architecture described here.

All IoT control, UWB positioning, kitchen robotics, automated heating/cooking equipment, food safety, labor safety, supplier integration, automated purchasing, and physical AI decisions must be reviewed by qualified hardware, safety, legal, insurance, food-safety, supplier, operations, and security experts before implementation.

---

## 2. Core Position

Physical automation is not ordinary software execution.

The correct rule is:

KDS ticket is not device command.  
Device command is not safe execution by itself.  
AI recommendation is not cooking authority.  
Robot-ready recipe is not approved production SOP.  
UWB position is not legal identity.  
Spatial match is not payment truth.  
Inventory prediction is not purchase approval.  
Auto-order candidate is not supplier purchase order.  
Supplier API acceptance is not delivery completion.  
Physical device state must be observable, interruptible, and auditable.  
Human override must always exist for safety-critical kitchen actions.  

The platform may coordinate physical devices and supply chains only through bounded, evidence-linked, reversible, and safety-reviewed controls.

---

## 3. Physical Automation Expansion Catalog

The following capability families are added:

| Capability Family | Purpose |
|---|---|
| `KDS_TO_IOT_ORCHESTRATION` | Convert approved kitchen tickets into device-ready commands |
| `LOCAL_IOT_HUB` | Mediate local kitchen device control inside store network |
| `DEVICE_COMMAND_GUARD` | Validate safety, recipe, timing, and device readiness before command |
| `KITCHEN_ROBOT_TASK_ROUTING` | Route approved tasks to robot/automation device candidates |
| `UWB_SPATIAL_MATCHING` | Match customer/device/table/chair position with high precision |
| `PHYSICAL_PRESENCE_EVIDENCE` | Use spatial evidence without treating it as final authority |
| `DEMAND_FORECAST_ENGINE` | Predict demand and ingredient depletion |
| `INVENTORY_DEPLETION_LEDGER` | Link sales/orders to ingredient consumption |
| `AUTO_REPLENISHMENT_CANDIDATE` | Generate supplier order recommendations |
| `SUPPLIER_ORDER_GOVERNANCE` | Control automatic purchase order submission |
| `PHYSICAL_AI_TRANSLATION_LAYER` | Translate operational knowledge into physical-device instructions under review |

These capabilities are future expansion boundaries.

They are not runtime permission.

---

## 4. Kitchen IoT Orchestration Boundary

Kitchen IoT orchestration converts approved operational state into device-control candidates.

Candidate devices may include:

- smart induction
- automated cooker
- robotic stirrer
- automated water dispenser
- smart oven
- rice cooker
- noodle boiler
- fryer if ever used
- warming cabinet
- holding cabinet
- temperature sensor
- smart scale
- kitchen timer
- robot arm
- conveyor or pickup station
- dish status sensor

Device orchestration must not bypass kitchen SOP.

Device orchestration must not bypass human safety controls.

---

## 5. KDS-To-IoT Command Boundary

KDS ticket may generate IoT command candidate only after required gates pass.

Required gates may include:

- order accepted
- payment/auth state valid under policy
- KDS ticket created
- recipe version approved
- device capability verified
- device state ready
- ingredient availability verified
- food safety condition satisfied
- staff override state clear
- local hub online
- emergency stop clear
- idempotency key valid
- duplicate command check passed
- tenant/store scope valid

KDS ticket alone is not command authority.

---

## 6. Kitchen Device Command State Skeleton

Recommended command states:

| State | Meaning |
|---|---|
| `DEVICE_COMMAND_NOT_ALLOWED` | Command gate not satisfied |
| `DEVICE_COMMAND_CANDIDATE` | Candidate generated |
| `DEVICE_COMMAND_VALIDATING` | Safety and readiness validation |
| `DEVICE_COMMAND_READY` | Ready to send |
| `DEVICE_COMMAND_SENT` | Sent to device/hub |
| `DEVICE_COMMAND_ACKNOWLEDGED` | Device acknowledged |
| `DEVICE_COMMAND_RUNNING` | Device executing |
| `DEVICE_COMMAND_COMPLETED` | Device completed |
| `DEVICE_COMMAND_FAILED` | Device failed |
| `DEVICE_COMMAND_ABORTED` | Aborted by human/system |
| `DEVICE_COMMAND_RETRY_REVIEW_REQUIRED` | Retry requires review |
| `DEVICE_COMMAND_MANUAL_FALLBACK_REQUIRED` | Manual fallback required |
| `DEVICE_COMMAND_DLQ_REQUIRED` | DLQ isolation required |

Device command must be explicit and auditable.

---

## 7. Local IoT Hub Boundary

Local IoT hub mediates device control inside store.

Local hub may handle:

- device discovery
- device health check
- command routing
- local command queue
- emergency stop propagation
- local logs
- offline buffer
- device capability registry
- firmware version report
- sensor collection
- sync to central
- safety interlock status
- manual override relay

Hub is a mediator.

Hub is not central financial authority.

---

## 8. IoT Protocol Boundary

Potential protocols may include MQTT, CoAP, HTTP local API, vendor SDK, BLE, serial gateway, or proprietary kitchen-device integration.

Protocol use must preserve:

- authentication
- encryption where possible
- device identity
- command idempotency
- replay protection
- command sequence
- acknowledgment
- timeout handling
- failure event
- audit log
- local fallback
- firmware/version compatibility

Protocol convenience must not weaken safety.

---

## 9. Device Safety Interlock Boundary

Safety interlocks must block unsafe physical execution.

Interlock checks may include:

- emergency stop active
- lid/door open
- overheating
- empty water tank
- missing ingredient container
- blocked motor
- human proximity if relevant
- device cleaning required
- fire/smoke alarm
- invalid recipe parameters
- expired firmware
- network uncertainty
- repeated device failure
- staff lockout

Safety interlock failure must block or abort command.

---

## 10. Recipe-To-Device Translation Boundary

Recipe-to-device translation converts recipe SOP into device-specific instructions.

Translation must define:

- recipe version
- device type
- device capability
- ingredient amount
- water amount
- temperature
- time
- stir speed
- heating stage
- hold stage
- sensor threshold
- manual step
- abort condition
- quality check
- staff confirmation point

AI may draft translation.

Approved SOP owner must review before production use.

---

## 11. Physical AI Boundary

Physical AI may recommend device timing or control improvements.

Physical AI must not:

- create unapproved cooking SOP
- bypass food-safety rules
- bypass human emergency stop
- alter temperature/time safety limits without approval
- command device outside approved recipe range
- auto-deploy new recipe to production
- hide failed device execution
- replace staff safety review

Physical AI is advisory until explicitly governed.

---

## 12. Kitchen Automation Evidence Packet

Kitchen automation evidence packet may include:

- order id
- KDS ticket id
- recipe version
- device id
- hub id
- command id
- command payload hash
- safety interlock result
- device acknowledgment
- execution timeline
- sensor readings
- staff override events
- manual fallback event
- completion state
- quality check reference
- audit reference

Evidence packet supports incident review, QA, food safety, and patent evidence.

---

## 13. UWB Spatial Matching Boundary

UWB spatial matching may provide high-precision indoor position evidence.

UWB may support:

- customer device proximity
- table/chair position
- staff device position
- pickup station proximity
- serving route signal
- wrong-table prevention
- preorder arrival confidence
- seating confirmation
- table turnover estimation
- local navigation

UWB position is physical context.

It is not legal identity, payment truth, or final order authority by itself.

---

## 14. UWB Anchor And Device Boundary

UWB deployment requires governed hardware identity.

Required records may include:

- anchor id
- anchor location
- store id
- floor/zone
- calibration version
- device id
- customer session pseudonym
- signal confidence
- distance estimate
- coordinate estimate
- timestamp
- drift marker
- interference marker
- firmware version
- audit reference

Calibration and interference must be monitored.

---

## 15. Spatial Match State Skeleton

Recommended states:

| State | Meaning |
|---|---|
| `SPATIAL_MATCH_NOT_AVAILABLE` | No spatial data |
| `SPATIAL_SIGNAL_DETECTED` | Signal detected |
| `SPATIAL_MATCH_CANDIDATE` | Candidate match generated |
| `SPATIAL_MATCH_LOW_CONFIDENCE` | Confidence too low |
| `SPATIAL_MATCH_CONFIRMED_BY_SECOND_SIGNAL` | Confirmed with NFC/QR/staff/device evidence |
| `SPATIAL_MATCH_CONFLICT` | Conflicting position evidence |
| `SPATIAL_MATCH_EXPIRED` | Match expired |
| `SPATIAL_MATCH_REVIEW_REQUIRED` | Human review required |
| `SPATIAL_MATCH_REJECTED` | Rejected |
| `SPATIAL_MATCH_EVIDENCE_STORED` | Evidence stored |

Spatial match must be confidence-scored and time-bounded.

---

## 16. UWB And NFC/QR Relationship

UWB may complement NFC/QR but should not silently replace it in high-risk flows.

Possible combinations:

| Signal | Strength |
|---|---|
| UWB only | Good proximity evidence, not final proof for high-risk actions |
| QR only | User action evidence, replay risk must be controlled |
| NFC only | Strong physical tap evidence if token-secured |
| UWB + NFC | Stronger physical presence evidence |
| UWB + QR + app session | Strong multi-signal arrival evidence |
| UWB + staff confirmation | Strong operational verification |
| UWB conflict with NFC/QR | Review or fail closed |

High-risk order/table/payment handoff should use multi-signal confirmation where appropriate.

---

## 17. Wrong-Table Prevention Boundary

Wrong-table prevention must reconcile:

- customer session
- order/preorder id
- UWB position
- NFC/QR table token
- table state
- staff seating state
- payment/auth state
- party size
- current table occupancy
- time window
- replay/conflict marker

If signals conflict, do not serve automatically.

Route to staff review or manual fallback.

---

## 18. Spatial Privacy Boundary

Indoor position data is sensitive.

Controls must include:

- data minimization
- short retention where possible
- pseudonymization
- purpose limitation
- no raw tracking beyond operational need
- customer notice where required
- staff notice where required
- access audit
- masking in projections
- privacy review
- deletion/anonymization policy

Spatial intelligence must not become uncontrolled surveillance.

---

## 19. Auto-SCM Demand Forecast Boundary

Auto-SCM predicts ingredient demand and replenishment needs.

Inputs may include:

- daily sales
- weekly sales
- menu mix
- reservations
- remote wait/preorder demand
- weather forecast
- local events
- seasonality
- day of week
- promotion plan
- dynamic pricing events
- historical waste
- current inventory
- supplier lead time
- expiry dates
- recipe ingredient mapping
- store capacity
- kitchen automation data

Forecast is recommendation.

It is not purchase order authority by itself.

---

## 20. Demand Forecast State Skeleton

Recommended forecast states:

| State | Meaning |
|---|---|
| `FORECAST_NOT_AVAILABLE` | No forecast |
| `FORECAST_COMPUTING` | Forecast running |
| `FORECAST_READY` | Forecast ready |
| `FORECAST_LOW_CONFIDENCE` | Low confidence |
| `FORECAST_CONFLICT` | Conflicting inputs |
| `FORECAST_REVIEW_REQUIRED` | Human review required |
| `FORECAST_APPROVED_FOR_REPLENISHMENT` | Approved for replenishment candidate |
| `FORECAST_EXPIRED` | Forecast expired |
| `FORECAST_SUPERSEDED` | Replaced by newer forecast |

Forecast must carry model version, feature snapshot, and confidence.

---

## 21. Ingredient Depletion Ledger Boundary

Ingredient consumption should be linked to orders.

Ingredient depletion may be derived from:

- recipe BOM
- order quantity
- kitchen execution
- manual adjustment
- waste log
- spoilage log
- staff correction
- supplier delivery
- inventory count
- batch prep
- yield loss
- portion variance

Ingredient depletion ledger must be append-only or amendment-based.

It must not be hidden inside menu sales.

---

## 22. Recipe BOM Boundary

Recipe BOM links menu item to ingredient consumption.

BOM must include:

- menu item id
- recipe version
- ingredient id
- unit
- standard quantity
- yield factor
- prep loss factor
- substitute ingredient rule
- allergen class
- expiration sensitivity
- cost basis
- effective date
- approval state

Forecast and inventory cannot be trusted without approved BOM.

---

## 23. Auto-Replenishment Candidate Boundary

Auto-replenishment candidate is not purchase order.

Candidate must include:

- store id
- supplier id
- ingredient id
- forecast demand
- current stock
- safety stock
- lead time
- expiry risk
- order quantity
- unit price estimate
- minimum order quantity
- delivery window
- confidence score
- approval requirement
- budget impact
- substitution option
- evidence packet id

Candidate requires policy/human/supplier approval before order if not pre-authorized.

---

## 24. Supplier Order Governance Boundary

Supplier order submission is high-risk.

Before supplier order is submitted:

- supplier contract valid
- item mapping valid
- price policy valid
- budget/limit check passed
- delivery window valid
- store receiving capacity valid
- duplicate order check passed
- forecast confidence sufficient
- approval rule satisfied
- substitution rule clear
- cancellation/return policy known
- audit record created

Auto-order sent is purchase commitment candidate.

It must be reconciled with delivery and invoice.

---

## 25. Supplier Order State Skeleton

Recommended states:

| State | Meaning |
|---|---|
| `REPLENISHMENT_CANDIDATE` | Candidate generated |
| `REPLENISHMENT_REVIEW_REQUIRED` | Review required |
| `REPLENISHMENT_APPROVED` | Approved |
| `SUPPLIER_ORDER_REQUESTED` | Supplier order requested |
| `SUPPLIER_ORDER_ACCEPTED` | Supplier accepted |
| `SUPPLIER_ORDER_REJECTED` | Supplier rejected |
| `SUPPLIER_ORDER_MODIFIED` | Supplier modified |
| `DELIVERY_SCHEDULED` | Delivery scheduled |
| `DELIVERY_RECEIVED` | Delivery received |
| `DELIVERY_SHORTAGE` | Shortage detected |
| `QUALITY_REVIEW_REQUIRED` | Quality review required |
| `INVOICE_RECONCILIATION_REQUIRED` | Invoice reconciliation required |
| `SUPPLIER_ORDER_CLOSED` | Closed |
| `SUPPLIER_ORDER_DLQ_REQUIRED` | DLQ isolation required |

SCM order lifecycle must be explicit.

---

## 26. Inventory Waste And Loss Boundary

Auto-SCM must reduce waste but also track loss.

Waste/loss records may include:

- expired ingredient
- spoilage
- prep waste
- overproduction
- no-show prepared food
- supplier defect
- storage temperature issue
- manual disposal
- staff error
- kitchen automation error
- recipe yield variance

Waste record must be evidence-linked.

Waste reduction claims must be measured.

---

## 27. Auto-SCM Evidence Packet

Auto-SCM evidence packet may include:

- forecast id
- model version
- feature snapshot
- recipe BOM reference
- current inventory snapshot
- waste history
- sales history
- weather/event input
- supplier lead time
- recommended order quantity
- approval reference
- supplier order id
- delivery result
- invoice reconciliation result
- waste/loss result
- audit reference

Evidence packet supports supplier, finance, inventory, and patent review.

---

## 28. Relationship To Physical AI And Franchise OS

Kitchen IoT, UWB, and Auto-SCM are future Franchise OS accelerators.

They may support:

- standardized kitchen execution
- reduced training burden
- lower labor dependency
- consistent quality
- table matching without fixed hardware
- dynamic seating and queue control
- automated procurement
- waste reduction
- HQ-level supply-chain visibility
- supplier negotiation power
- data-driven menu engineering

These capabilities must remain modular.

They must not be inserted into MVP runtime without explicit authorization.

---

## 29. Relationship To Financial Trust

Financial Trust must enforce:

- kitchen IoT is not payment authority
- device command evidence does not equal settlement evidence
- UWB spatial evidence does not equal payment truth
- inventory forecast does not equal purchase liability
- supplier order acceptance and invoice reconciliation are separate states
- ingredient cost must be fixed-point/accounting-reviewed
- waste/no-show/supplier loss must be ledger-linked

Financial truth remains separate from physical automation.

---

## 30. Relationship To Store Runtime

Store Runtime must govern:

- KDS ticket state
- kitchen device readiness
- local IoT hub health
- safety interlock state
- manual fallback
- UWB/table match state
- staff override
- ingredient availability
- inventory movement
- supplier delivery receiving

Store Runtime owns operational execution.

It does not own final financial settlement.

---

## 31. Relationship To Data Governance

Data Governance must control:

- indoor location privacy
- device telemetry visibility
- kitchen automation evidence retention
- forecast explanation
- supplier order projection
- inventory and waste reporting
- AI recommendation boundaries
- i18n messages
- export restrictions
- HQ/franchise visibility
- staff/customer privacy

Spatial, device, and SCM data are sensitive operational assets.

---

## 32. Relationship To Security Agent

Security Agent may detect:

- IoT command spoofing
- device replay attack
- local hub compromise
- unsafe command pattern
- UWB spoofing
- anchor tampering
- wrong-table attack
- inventory manipulation
- supplier API abuse
- abnormal auto-order spike
- forecast manipulation
- unauthorized recipe-to-device change
- physical AI overreach

Security Agent may alert or contain.

It must not execute physical commands or supplier orders by itself.

---

## 33. Relationship To Cross-Room Plumbing

Future event routing must carry:

- KDS ticket id
- IoT command id
- device id
- local hub id
- safety interlock id
- recipe version id
- device execution id
- UWB anchor id
- spatial match id
- table/chair coordinate id
- inventory ledger id
- recipe BOM id
- demand forecast id
- replenishment candidate id
- supplier order id
- delivery receipt id
- waste/loss id
- physical automation evidence packet id
- auto-SCM evidence packet id

These become context envelope and evidence packet candidates.

---

## 34. Anti-Patterns

Avoid:

- KDS ticket directly commanding heating device without safety gate
- AI-generated recipe deployed to production without approval
- IoT command without emergency stop
- device command without idempotency
- local hub treated as central authority
- UWB position treated as legal identity
- UWB used as sole proof for high-risk payment/table action
- indoor tracking without privacy boundary
- forecast directly creating supplier PO without governance
- auto-order without budget/supplier/price checks
- ingredient depletion hidden inside sales summary
- BOM changes without versioning
- supplier delivery accepted without quality and invoice reconciliation
- physical automation added to MVP before store SOP is stable

These anti-patterns must be blocked in future runtime design.

---

## 35. Runtime Deferral

This document defines kitchen IoT, UWB spatial matching, Auto-SCM, and physical automation expansion boundaries only.

It does not authorize:

- IoT hub implementation
- MQTT/CoAP integration
- kitchen robot integration
- device command runtime
- UWB deployment
- indoor location tracking
- Auto-SCM forecast model
- inventory depletion ledger
- supplier API integration
- auto-order runtime
- physical AI control
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 36. Validation Checklist

Validation must confirm:

1. Physical automation expansion catalog is defined.
2. Kitchen IoT orchestration boundary is defined.
3. KDS-to-IoT command boundary is defined.
4. Kitchen device command state skeleton is defined.
5. Local IoT hub boundary is defined.
6. IoT protocol boundary is defined.
7. Device safety interlock boundary is defined.
8. Recipe-to-device translation boundary is defined.
9. Physical AI boundary is defined.
10. Kitchen automation evidence packet is defined.
11. UWB spatial matching boundary is defined.
12. UWB anchor/device boundary is defined.
13. Spatial match state skeleton is defined.
14. UWB and NFC/QR relationship is defined.
15. Wrong-table prevention boundary is defined.
16. Spatial privacy boundary is defined.
17. Auto-SCM demand forecast boundary is defined.
18. Demand forecast state skeleton is defined.
19. Ingredient depletion ledger boundary is defined.
20. Recipe BOM boundary is defined.
21. Auto-replenishment candidate boundary is defined.
22. Supplier order governance boundary is defined.
23. Supplier order state skeleton is defined.
24. Inventory waste/loss boundary is defined.
25. Auto-SCM evidence packet is defined.
26. Relationships to Physical AI, Franchise OS, Financial Trust, Store Runtime, Data Governance, Security Agent, and Cross-Room Plumbing are defined.
27. Anti-patterns are listed.
28. Coding remains unauthorized.
29. Runtime remains deferred.

---

## 37. Relationship To Previous Documents

This document supplements:

- `10609M Realtime Sync AI Turnover Prediction Local Mesh Dynamic Pricing SoftPOS And Field Control Expansion Policy`

It references:

- `10240 KDS Ticket Room Boundary Policy`
- `10250 Kitchen Execution Room Boundary Policy`
- `10270 Device Runtime Room Boundary Policy`
- `10290 Degraded Operation Room Boundary Policy`
- `10320 Operational Evidence Room Boundary Policy`
- `10330 Fulfillment Visibility Room Boundary Policy`
- `10400~10480 Financial Trust Room Framing Sequence`
- `10530 Safe Projection Masking And Audience Visibility Boundary Policy`
- `10540 AI Advisory Runtime And Non-Authority Boundary Policy`
- `10550 pgvector Context Retrieval And Similarity Boundary Policy`
- `10580 Data Governance Closure And Cross-Room Handoff Policy`
- `10600 Cross-Room Plumbing Wiring Insulation Planning Index`
- `10609M Realtime Sync AI Turnover Prediction Local Mesh Dynamic Pricing SoftPOS And Field Control Expansion Policy`

It prepares:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- future kitchen IoT feasibility review packet
- future UWB spatial matching privacy and hardware packet
- future recipe-to-device translation specification
- future Auto-SCM demand forecast and supplier order governance packet
- future physical AI boundary authorization packet
- future Franchise OS kitchen automation roadmap

This document is architecture boundary planning only.

It does not authorize coding.

---

## 38. Final Rule

Kitchen IoT, UWB spatial matching, and Auto-SCM are Franchise OS-level accelerators, not MVP shortcuts.

KDS-to-IoT orchestration may reduce kitchen labor, but only through approved recipe versions, safety interlocks, local hub controls, device identity, command idempotency, emergency stop, and human override.

UWB may improve table and customer matching, but spatial data is sensitive and cannot replace payment truth, legal identity, or high-risk physical verification without multi-signal evidence.

Auto-SCM may reduce waste and stockout risk, but demand forecast is recommendation, not supplier purchase authority.

Supplier order must be contract-checked, budget-checked, price-checked, duplicate-checked, approved where required, reconciled against delivery, and linked to inventory and invoice evidence.

Physical automation must remain modular, safety-reviewed, tenant-scoped, auditable, and explicitly authorized before any runtime implementation.
