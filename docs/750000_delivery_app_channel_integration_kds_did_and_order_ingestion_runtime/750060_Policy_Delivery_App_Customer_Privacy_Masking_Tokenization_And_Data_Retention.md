# 750060_Policy_Delivery_App_Customer_Privacy_Masking_Tokenization_And_Data_Retention.md

## 1. Purpose

This policy defines the privacy, masking, tokenization, and data-retention boundary for delivery app channel integration in `yoonsul_wait_order_handoff`.

The delivery app channel receives customer-facing order data from external platforms and routes it through POS projection, KDS, station KDS, assembly/packing, DID callout, audit ledger, and evidence packets.

Because this flow may contain customer phone numbers, addresses, delivery notes, rider pickup metadata, order memo text, and channel identifiers, this policy exists to prevent:

- unnecessary storage of personal data;
- customer data exposure on KDS or DID screens;
- raw delivery address leakage into kitchen operations;
- long-term local retention of delivery app personal data;
- uncontrolled logs containing phone numbers or addresses;
- screenshot, export, or evidence packets containing unredacted customer data;
- accidental reuse of delivery app customer identifiers as internal customer identity.

## 2. Scope

This policy applies to all delivery app channel data handled by:

- delivery app channel adapters;
- partner API gateway integrations;
- webhook handlers;
- polling jobs;
- POS projection logic;
- order normalization logic;
- KDS order cards;
- station KDS views;
- assembly and packing screens;
- DID customer or rider callout screens;
- audit ledger events;
- evidence packet generation;
- raw logs captured during verification;
- support tools and admin console views;
- downstream analytics derived from delivery app orders.

## 3. Core Privacy Rule

The core rule is:

```text
Delivery app personal data must be minimized at ingestion,
masked before operational display,
tokenized before internal routing,
redacted before evidence export,
and expired as soon as operationally unnecessary.
```

KDS and DID are operational routing surfaces.

They are not customer profile systems.

They must not become long-term storage for delivery app personal data.

## 4. Data Classification

| Data Type | Example | Classification | Default Handling |
|---|---|---|---|
| External order ID | platform order number | operational identifier | store as channel reference |
| Internal order token | generated UUID/token | internal routing identifier | allowed |
| Customer phone number | full mobile number | personal data | mask/tokenize, avoid display |
| Customer address | delivery destination | sensitive personal data | minimize, restrict, expire |
| Customer name/nickname | app display name | personal data | avoid KDS/DID display unless required |
| Customer request memo | “leave at door”, allergies, notes | mixed sensitive data | parse cautiously, display only operationally necessary text |
| Rider name/phone | rider metadata | third-party personal data | mask and restrict |
| Pickup number | order call number | operational display identifier | allowed on DID |
| Menu/options | food items and modifiers | operational data | allowed |
| Payment amount | order total | financial data | restrict to POS/payment context |
| Platform status | accepted, cooking, ready, picked up | operational status | allowed |
| Raw API payload | full platform response | high-risk evidence data | never log unredacted by default |

## 5. Personal Data Minimization At Ingestion

Delivery app channel adapters must normalize only the fields needed for order execution.

Allowed normalized fields:

- external channel name;
- external order reference;
- internal order token;
- store identifier;
- order received timestamp;
- order type: delivery, pickup, takeout, dine-in handoff if applicable;
- menu items;
- item options;
- operational kitchen memo after filtering;
- pickup number or safe customer-facing call number;
- expected pickup/delivery time;
- rider pickup status where applicable;
- masked contact reference if required for support.

Forbidden by default:

- storing full raw API payload in application logs;
- storing full customer address in KDS state;
- exposing full phone number to station KDS;
- using delivery app customer identity as internal loyalty/customer identity;
- copying delivery app personal data into unrelated analytics tables;
- persisting unmasked rider contact data beyond operational need.

## 6. Masking Rule

Personal data must be masked before it appears in any operational UI unless a specific approved use case requires temporary unmasking.

### 6.1 Phone Number Masking

```text
010-1234-5678 -> 010-****-5678
```

If only contact verification is required, show the last four digits only.

### 6.2 Address Masking

KDS should not display full delivery address.

Allowed:

```text
강남구 역삼동 ***
```

Forbidden:

```text
서울 강남구 역삼동 123-45 3층 302호
```

### 6.3 Name / Nickname Masking

Customer name or nickname must not be displayed on DID.

KDS may display only a safe call number or internal order token.

### 6.4 Rider Metadata Masking

Rider phone number must be masked.

Rider identity must be visible only where it is operationally necessary for pickup coordination.

## 7. Tokenization Rule

Internal runtime must route delivery app orders using internal tokens, not raw platform personal data.

Required internal identifiers:

- `change_id` for implementation traceability;
- `order_id` for internal order lifecycle;
- `channel_order_ref` for external platform reference;
- `kds_ticket_id` for KDS card lifecycle;
- `station_task_id` for station-level work;
- `did_callout_token` for customer/rider display;
- `evidence_packet_id` for audit and verification.

The DID callout token must be safe for public display.

It must not encode phone number, address, or customer name.

## 8. KDS Display Boundary

KDS is allowed to display:

- order type;
- safe order number;
- platform badge;
- menu items;
- item options;
- allergy/food safety notes if explicitly required;
- cooking priority;
- target completion time;
- station routing state;
- rider pickup pending/arrived/collected status if safe.

KDS must not display:

- full phone number;
- full address;
- unnecessary customer identity;
- raw payment details;
- unfiltered personal request memo;
- platform access tokens;
- API credentials;
- HMAC secrets;
- OAuth tokens.

## 9. DID Display Boundary

DID is a public or semi-public display surface.

DID may display only:

- safe pickup number;
- order ready status;
- pickup counter or zone;
- rider/customer pickup instruction;
- generic delay notice.

DID must not display:

- customer name;
- phone number;
- address;
- delivery memo;
- payment amount;
- rider phone;
- internal error message;
- platform access token;
- store back-office identifiers.

## 10. Customer Memo Filtering

Customer memo fields may contain sensitive personal information even when the platform field is operationally labeled.

Examples:

- “아기 자고 있어요, 벨 누르지 마세요.”
- “현관 비밀번호 1234.”
- “병원 병실 앞에 놓아주세요.”
- “알레르기 있어요.”

The system must separate:

| Memo Type | Handling |
|---|---|
| Cooking instruction | may be shown to KDS |
| Allergy/food safety note | may be shown prominently to KDS |
| Delivery access information | must not be shown to station KDS |
| Door code / private location | must be restricted and expired |
| Customer health or family note | redact from evidence and analytics |

## 11. Data Retention Rule

Delivery app personal data retention must be short and purpose-bound.

Default policy:

| Data Category | Retention Handling |
|---|---|
| Internal order token | retain according to order/audit policy |
| External order reference | retain for reconciliation and dispute handling |
| Menu/order operational data | retain for business analytics where allowed |
| Full phone number | avoid storing; expire/mask after operational window |
| Full address | avoid storing in core runtime; expire/mask after delivery completion |
| Customer request memo | split operational vs sensitive portions; redact as soon as possible |
| Raw API payload | do not retain by default; if retained for incident evidence, redact and seal |
| Rider personal data | expire after pickup/dispute window |
| DID display token | expire after pickup completion and short grace period |

If a legal, tax, settlement, dispute, chargeback, or platform requirement requires retention, the retained record must use the minimum necessary data and must be protected by evidence redaction rules.

## 12. Masking Deadline Rule

After delivery or pickup completion, customer personal data must be masked or removed from operational systems within the approved privacy window.

For this project, the delivery app channel must be designed so that masking can occur within the strictest applicable partner, legal, and platform requirement.

If the applicable platform or regulation requires masking within a specific time window, the stricter rule wins.

## 13. Raw Log Rule

Raw logs must not contain unmasked personal data unless explicitly captured as a sealed incident evidence artifact.

Forbidden in normal logs:

- full request/response payload dump;
- full address;
- full phone number;
- OAuth token;
- HMAC secret;
- platform API key;
- customer memo before filtering;
- rider phone number;
- unredacted webhook body.

Allowed in normal logs:

- internal order token;
- external order reference if not personal data;
- platform code;
- status transition;
- timestamp;
- masked phone suffix where needed;
- redacted memo indicator;
- evidence packet ID.

## 14. Evidence Packet Redaction Rule

Evidence packets may need to preserve facts for audit, incident response, provider dispute, or regression testing.

However, evidence must be privacy-safe by default.

Required evidence redaction fields:

- redaction profile name;
- redaction timestamp;
- redaction actor/system;
- fields removed;
- fields masked;
- reason for any sealed unredacted artifact;
- access approval for sealed artifact;
- expiry or legal hold status.

## 15. Audit Ledger Rule

Audit ledger events must record material privacy actions without exposing the sensitive data itself.

Required audit events:

- delivery order ingested;
- personal data minimized;
- customer memo filtered;
- DID callout token generated;
- KDS operational card created;
- address/contact masked;
- raw payload redacted or discarded;
- evidence packet generated;
- sealed evidence accessed if applicable;
- retention expiry executed.

Audit ledger must reference:

- `CHANGE_ID` for implementation traceability;
- internal order ID;
- channel order reference;
- evidence packet ID where applicable;
- redaction policy version;
- actor/system.

The audit ledger must not store full personal data values.

## 16. Access Control Rule

Access to delivery app personal data must follow least privilege.

| Actor / Surface | Allowed Visibility |
|---|---|
| Station KDS worker | menu, options, safe operational memo |
| Assembly/Packing | safe order token, items, packaging notes |
| Front counter | safe pickup number, ready status |
| DID | safe callout token only |
| Store manager | limited masked customer/order view |
| Support operator | masked by default, temporary reveal only with approval |
| Developer | no real personal data in local/dev logs |
| Auditor | redacted evidence by default |
| Break-glass role | time-limited, logged, post-reviewed |

## 17. External Platform Credential Boundary

Delivery app credentials are secrets.

The following must never appear in KDS, DID, logs, or evidence without secret redaction:

- API key;
- access key;
- secret key;
- OAuth token;
- refresh token;
- webhook signing secret;
- HMAC secret;
- store authorization token;
- partner gateway token;
- IP whitelist configuration secrets where sensitive.

Credential handling belongs to the secure integration layer, not the kitchen display layer.

## 18. Database And Migration Requirements

If delivery app personal data is stored in the database, schema design must separate:

- operational order data;
- personal delivery data;
- redaction state;
- evidence metadata;
- audit ledger event metadata.

Required constraints where applicable:

- unique internal order token;
- unique channel order reference per platform/store;
- redaction status enum;
- retention expiry timestamp;
- evidence packet reference;
- no plaintext personal data in analytics tables;
- RLS policy preventing unauthorized personal data reads.

Any migration that touches delivery app personal data is high-risk and must not use the MVV pipeline.

## 19. Test Requirements

Required tests:

- phone masking test;
- address masking test;
- customer memo filtering test;
- DID safe token display test;
- KDS no-full-address display test;
- raw log redaction test;
- evidence packet redaction manifest test;
- audit ledger no-sensitive-value test;
- retention expiry job test;
- role-based visibility test;
- webhook payload redaction test;
- sealed evidence access audit test;
- CHANGE_ID audit mapping test.

## 20. Failure And Block Conditions

Implementation must be blocked if:

- KDS displays full customer address without explicit approved exception;
- DID displays customer name, phone number, or address;
- raw webhook payload is logged unredacted;
- customer memo is copied into analytics without filtering;
- full address or phone number is retained without retention policy;
- audit ledger stores sensitive values directly;
- evidence packet lacks redaction profile;
- platform credentials appear in logs;
- RLS allows unauthorized personal data reads;
- CHANGE_ID is missing from privacy-related evidence or audit actions;
- retention expiry cannot be verified.

## 21. Context Snapshot Rule For 51355 Pipeline

When this policy is used inside the 51355 AI-assisted development pipeline, it must be injected as a sliced context rule for delivery app, KDS, DID, privacy, evidence, and external channel modules.

Do not inject the full delivery app research report into Claude unless the module specifically requires broad architectural review.

Use this policy as the compact privacy rule packet.

Recommended context slot:

```text
Context Slot: delivery_app_privacy_masking_retention
Required For:
- delivery app order ingestion
- KDS display logic
- DID callout logic
- evidence packet generation
- audit ledger for delivery app orders
- support/admin delivery order views
- platform webhook/polling handlers
```

## 22. Related 750000 Documents

- `750000_Index_Delivery_App_Channel_Integration_KDS_DID_And_Order_Ingestion_Runtime.md`
- `750010_Assessment_Delivery_App_Channel_API_KDS_DID_And_Omnichannel_Order_Ingestion_Architecture.md`
- `750020_Guide_Delivery_App_API_KDS_DID_Integration_Context_Summary.md`
- `750030_Policy_Delivery_App_Official_API_Integration_And_No_Scraping_Boundary.md`
- `750040_Boundary_POS_API_Gateway_KDS_DID_And_Kitchen_Runtime_Responsibility.md`
- `750050_Matrix_Delivery_App_POS_KDS_DID_Channel_Integration_Map.md`

## 23. Final Rule

```text
No delivery app personal data may survive longer, travel farther,
or appear more visibly than the kitchen operation strictly requires.
```
