# 604101_Overview_Flutter_MVP_Project_Structure.md

Status: Reinforced Draft  
Lifecycle: Overview  
Owner: TBD  
Last Updated: 2026-07-01

---

## 0. Purpose

This document defines the Flutter MVP project structure for **Catch Menu (캐치메뉴)** before feature implementation begins.

It is a planning document only. It does not authorize runtime code changes beyond what is already scaffolded in `catchmenu_app/`.

Upstream references:

| Document | Role |
| --- | --- |
| `docs/900000_patent_and_handoff_package/900102_ChangeContract_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` | Allowed scopes, invariants, implementation order |
| `docs/900000_patent_and_handoff_package/900121_Logic_Channel_2_Catch_Menu_Native_App_Customer_Handoff_And_Session.md` | Session lifecycle, DROP-A~E defense |
| `docs/900000_patent_and_handoff_package/900103_TestPlan_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` | Verification cases and expected states |

Related logic document: `604102_Logic_Flutter_MVP_Core_Implementation.md`

Related implementation record: `604103_Module_Flutter_MVP_Foundation_Scaffold_Implementation.md`

Gate classification:

```text
This document is an Architecture Overview baseline.
It is not an implementation approval.
It may be shown to Codex only as context, constraints, and boundary rules.
Any runtime Scope implementation still requires Controlled Implementation Gate approval.
```

### 0.1 Retrospective Foundation Note

`604103_Module_Flutter_MVP_Foundation_Scaffold_Implementation.md` records a Foundation scaffold that was implemented before this reinforced overview/logic pair was normalized. That implementation is accepted only as a **pre-gate Foundation bootstrap baseline** because it introduced client skeleton files and did not implement Scope A~E runtime behavior, DB migrations, Edge Functions, payment approval, KDS release, waiting state transitions, or staff/DID workflows.

This history must not become a precedent. From this point forward, no Scope D/C/A/B/E implementation may start from this overview alone. The required sequence is:

```text
Cursor Impact Scope
  → Claude Architecture / Logic / Test Plan / Change Contract
  → Claude + Human Approval
  → Codex Implementation
  → Local Automated Verification Gate
  → Claude Audit
  → Human Merge / Release
```

### 0.2 Codex Reading Rule

When this document is given to Codex, Codex must treat it as a **read-only architecture contract**. Codex must not infer permission to rename folders, move files, widen scope, add features, refactor unrelated code, or touch SQL/Edge/server files unless a separate `implementation_approval.md` explicitly authorizes those files.


---

## 1. Project Location

```text
D:\workspace\yoonsul_wait_order_handoff\catchmenu_app\
```

Flutter package name: `catchmenu_app`  
Organization: `com.yoonsul`

The app is the **Channel 2 native customer handoff client** (authenticated OTP session). It shares server contracts with Channel 1 web but adds SecureStorage, FCM, and native lifecycle recovery per `900121`.

---

## 2. Design Principles

```text
1. Server owns business authority (order_sessions, payment_ledger, kds_tickets).
2. Client never calls supabase.rpc() directly — only RpcCaller.
3. Client success UI ≠ payment complete; server APPROVED only (INV-001 context).
4. Seating and calling are not payment (INV-002, INV-003).
5. Client is not KDS release authority (INV-004).
6. All handoff transitions must be auditable (INV-006 client-side contribution).
7. Implement scopes in order: D → C → A → B → E (900102 §12).
```

Documentation-only work in `docs/600000_implementation/` does not replace Scope approval in `catchmenu_app/impact_scope.md`.


### 2.1 Controlled Implementation Gate Alignment

This overview participates in the project-wide **Controlled Implementation Gate** as architecture context only. The responsibility split is fixed:

| Step | Actor | Output | May modify code? |
| --- | --- | --- | --- |
| 1 | Cursor Impact Scope | `impact_scope.md` | No |
| 2 | Claude Architecture | `overview.md`, `logic.md`, `test_plan.md`, `change_contract.md` | No |
| 3 | Claude + Human Approval | `implementation_approval.md` | No |
| 4 | Codex Implementation | code diff + `implementation_module.md` | Yes, approved files only |
| 5 | Local Gate | `verification_result.md` | No runtime expansion |
| 6 | Claude Audit | `audit_review.md` | No |
| 7 | Human Merge / Release | commit + release evidence | Human only |

The Flutter MVP must never enter implementation from a broad instruction such as "build the feature". Every Scope must be decomposed into approved files, forbidden files, expected RPCs, expected tests, rollback criteria, and evidence requirements.

### 2.2 Foundation Baseline Freeze

The current Foundation scaffold may be used as the starting baseline only under the following freeze rules:

```text
ALLOWED AS BASELINE:
  catchmenu_app/lib/core/constants/app_constants.dart
  catchmenu_app/lib/core/errors/app_error.dart
  catchmenu_app/lib/core/supabase/supabase_client.dart
  catchmenu_app/lib/core/supabase/rpc_caller.dart
  catchmenu_app/lib/main.dart
  feature README placeholders

NOT IMPLIED:
  approval to implement waiting/payment/KDS/staff/DID runtime
  approval to create SQL migrations
  approval to create Edge Functions
  approval to rename the app structure
  approval to bypass Scope D server guard
```

If Codex finds that the Foundation baseline conflicts with this overview, Codex must report the conflict in `implementation_module.md` or a proposed change note. Codex must not silently normalize the tree.

### 2.3 Scope Authorization Matrix

| Scope | Primary area | Requires prior approval? | May use this overview as approval? | Notes |
| --- | --- | --- | --- | --- |
| Foundation | client skeleton only | Retrospective accepted | No future precedent | Already recorded in `600003` |
| D | server runtime guard | Yes | No | SQL/Edge/server authority before UI truth |
| C | KDS HOLD/COMMITTED UI | Yes | No | Depends on Scope D guard |
| A | customer waiting/preorder/payment | Yes | No | Depends on Scope D and relevant server RPCs |
| B | staff call/seat/table | Yes | No | Must not release KDS or approve payment |
| E | DID projection | Yes | No | Projection only; no payment detail |

---

## 3. Target Folder Structure

Planned structure after MVP scopes are implemented. **Bold** = exists today (foundation scaffold).

```text
catchmenu_app/
├── pubspec.yaml
├── impact_scope.md                    # per-scope allow/deny before coding
├── lib/
│   ├── main.dart                      # ProviderScope, Supabase boot, router hook
│   ├── app/
│   │   ├── app.dart                   # MaterialApp / theme (split from main later)
│   │   ├── router.dart                # go_router: channel entry + deep links
│   │   └── lifecycle_observer.dart    # global WidgetsBindingObserver (DROP-B/E)
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart     # env, schemas, pipelines, forbidden RPCs
│   │   ├── errors/
│   │   │   └── app_error.dart         # normalized failure type
│   │   ├── session/
│   │   │   ├── session_storage.dart   # SecureStorage + SharedPreferences policy
│   │   │   ├── session_recovery.dart  # DROP-C active session restore
│   │   │   └── auth_session.dart      # onAuthStateChange, token refresh (DROP-A)
│   │   ├── supabase/
│   │   │   ├── supabase_client.dart   # SupabaseInit.ensureInitialized()
│   │   │   └── rpc_caller.dart        # ★ sole RPC entry (see §5)
│   │   └── realtime/
│   │       ├── realtime_manager.dart  # subscribe / resubscribe (DROP-B)
│   │       └── channel_registry.dart  # waiting, kds, did channel names
│   ├── features/
│   │   ├── bootstrap/                 # QR / store context / language
│   │   │   ├── bootstrap_screen.dart
│   │   │   └── bootstrap_repository.dart
│   │   ├── auth/                      # OTP login (Ch2)
│   │   │   ├── login_screen.dart
│   │   │   └── auth_repository.dart
│   │   ├── waiting/                   # Scope A (customer)
│   │   │   ├── waiting_register_screen.dart
│   │   │   ├── waiting_status_screen.dart
│   │   │   ├── pre_order_screen.dart
│   │   │   ├── waiting_state_notifier.dart
│   │   │   └── waiting_repository.dart
│   │   ├── payment/                   # Scope A
│   │   │   ├── payment_screen.dart
│   │   │   ├── payment_result_handler.dart  # DROP-E resume
│   │   │   └── payment_repository.dart
│   │   ├── kds/                       # Scope C
│   │   │   ├── kds_screen.dart
│   │   │   ├── kds_ticket_card.dart
│   │   │   ├── kds_state_notifier.dart
│   │   │   └── kds_repository.dart
│   │   ├── staff/                     # Scope B (900102: waiting_admin)
│   │   │   ├── staff_waiting_screen.dart
│   │   │   ├── waiting_list_tile.dart
│   │   │   └── staff_waiting_repository.dart
│   │   └── did/                       # Scope E (create at scope start)
│   │       ├── did_screen.dart
│   │       └── did_repository.dart
│   └── shared/
│       ├── models/                    # DTOs aligned to RPC responses
│       └── widgets/                   # loading, error, status badges
└── test/
    ├── widget_test.dart
    ├── core/rpc_caller_test.dart
    └── features/…                     # per-scope tests per 900103
```

### 3.1 Naming Notes (Open Items)

| 900102 name | Current scaffold | Decision |
| --- | --- | --- |
| `lib/services/supabase/*_service.dart` | `lib/core/supabase/` + feature `*_repository.dart` | Keep **core + repository** pattern; do not duplicate service layer |
| `lib/features/waiting_admin/` | `lib/features/staff/` | Rename to `staff/` in docs unless product prefers `waiting_admin/` at Scope B start |

Resolve in `impact_scope.md` before Scope B coding.


### 3.2 Folder Boundary Rules for Codex

Codex must preserve the architecture boundary unless a separate approval says otherwise:

| Boundary | Rule |
| --- | --- |
| `lib/core/` | Cross-feature primitives only: config, errors, Supabase, session, realtime |
| `lib/features/*/` | Feature UI/state/repository only; no shared RPC bypass |
| `lib/shared/` | Pure reusable UI/model utilities; no business authority |
| `test/core/` | Core contract tests such as `rpc_caller_test.dart` |
| `test/features/` | Scope-specific behavior tests |
| `supabase/`, `sql/`, `functions/` | Forbidden from Flutter Scope work unless Scope D approval explicitly allows |

Any direct dependency from a widget to `SupabaseClient.rpc()` is a contract violation. Widgets may read state and dispatch notifier actions, but business mutation must flow through Repository → `RpcCaller.call()`.

---

## 4. Key Files (Current and Planned)

### 4.1 Foundation (present)

| File | Role |
| --- | --- |
| `lib/main.dart` | Boot: `SupabaseInit`, `ProviderScope`, placeholder home |
| `lib/core/constants/app_constants.dart` | `--dart-define` env, schema names, audit pipelines, `forbiddenClientRpcs` |
| `lib/core/errors/app_error.dart` | Standard error codes for UI and logging |
| `lib/core/supabase/supabase_client.dart` | One-time Supabase initialize |
| `lib/core/supabase/rpc_caller.dart` | Mandatory RPC wrapper; INV-004 block; dev audit |
| `catchmenu_app/impact_scope.md` | Scope allow/deny manifest per 900102 §5 |

### 4.2 Planned core additions

| File | Role |
| --- | --- |
| `lib/app/router.dart` | Channel entry routes (§8) |
| `lib/core/session/session_storage.dart` | Secure vs prefs split per 900121 §6 |
| `lib/core/session/auth_session.dart` | DROP-A token refresh handlers |
| `lib/core/realtime/realtime_manager.dart` | DROP-B resubscribe on resume |
| `lib/features/payment/payment_result_handler.dart` | DROP-E pending payment recovery |

### 4.3 Feature README placeholders (present)

| Path | Scope |
| --- | --- |
| `lib/features/waiting/README.md` | Scope A |
| `lib/features/payment/README.md` | Scope A |
| `lib/features/kds/README.md` | Scope C |
| `lib/features/staff/README.md` | Scope B |

---


### 4.4 Relationship to `600003` Module Record

`600003` is not a replacement for this overview. It is a module record for the already-created Foundation scaffold. The relationship is:

```text
600001 = intended architecture and folder boundary
600002 = core runtime logic contract
600003 = existing Foundation scaffold implementation record
```

Before any new implementation, Codex must compare the current tree against this overview and report one of the following:

| Result | Meaning | Required action |
| --- | --- | --- |
| `MATCHES_BASELINE` | Existing scaffold matches the overview enough to continue | Proceed only within approved files |
| `DOC_ONLY_DRIFT` | Docs name a future file not yet implemented | Do not implement unless approved |
| `CODE_DRIFT` | Existing code/folders differ from overview | Stop and report, or modify only if approved |
| `SCOPE_DRIFT` | Code contains runtime behavior not authorized by Scope | Stop and escalate to audit |

## 5. Supabase Integration Model

### 5.1 Configuration

Secrets are **never** hard-coded. Inject at build/run time:

```bash
flutter run \
  --dart-define=APP_ENV=dev \
  --dart-define=SUPABASE_URL=https://<project>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon_key>
```

| Constant | Source | Usage |
| --- | --- | --- |
| `APP_ENV` | dart-define | `dev` enables audit logging; `prod` disables dev RPC audit |
| `SUPABASE_URL` | dart-define | Supabase project URL |
| `SUPABASE_ANON_KEY` | dart-define | Anon key only; no service role in client |

### 5.2 Schema Exposure

PostgREST must expose non-public schemas used by the app:

```text
public
catchmenu_pos      # waiting, seating, sessions
catchmenu_payment  # payment confirm paths (client triggers, server approves)
catchmenu_kds      # read + staff transitions (not release)
catchmenu_common   # bootstrap, integration helpers
catchmenu_dev      # write_audit_log (dev only)
```

Verify **Supabase Dashboard → API → Exposed schemas** before Scope A.

### 5.3 Access Layers

```text
UI / Notifier
    ↓
Repository (feature)
    ↓
RpcCaller.call()          ← only RPC path
    ↓
SupabaseClient (schema-aware rpc)
    ↓
Postgres RPC / RLS
```

**Prohibited:** `Supabase.instance.client.rpc(...)` outside `rpc_caller.dart`.

Realtime subscriptions may use `SupabaseInit.client` directly for channels, but state changes that mutate business data must go through RPC defined in 900102.

### 5.4 rpc_caller.dart Role (Summary)

`RpcCaller` is the **single RPC gateway** for the Flutter app.

| Responsibility | Detail |
| --- | --- |
| Correlation ID | Auto-generated per call; optional inject into RPC params |
| INV-004 enforcement | Blocks `AppConstants.forbiddenClientRpcs` (e.g. `release_kds_after_payment`) |
| INV-006 dev audit | Calls `catchmenu_dev.write_audit_log` when `APP_ENV != prod` |
| Error normalization | Maps `PostgrestException` / network errors to `AppError` |
| Result envelope | `RpcResult<T>` with `isSuccess`, `error`, `correlationId` |
| Schema routing | `public` vs `client.schema('catchmenu_pos').rpc(...)` |

Detailed design: `604102_Logic_Flutter_MVP_Core_Implementation.md` §2.

### 5.5 Auth Options (Channel 2 — to add in Scope A)

Per `900121` DROP-A, initialization must eventually include:

```dart
authOptions: FlutterAuthClientOptions(
  authFlowType: AuthFlowType.pkce,
  autoRefreshToken: true,
  persistSession: true,
)
```

Current `SupabaseInit` uses default initialize; extend when OTP auth lands (documented in 600002, not implemented here).

---

## 6. Session Management Strategy (DROP-A~E)

Session defense patterns from `900121` map to Flutter modules as follows.

| Pattern | Risk | Primary module | Backup |
| --- | --- | --- | --- |
| **DROP-A** | JWT expiry during long wait | `auth_session.dart` + Supabase `autoRefreshToken` | `onAuthStateChange` → refresh Realtime |
| **DROP-B** | Background → foreground; Realtime drop | `lifecycle_observer.dart` + `realtime_manager.dart` | 30s polling `get_waiting_status` |
| **DROP-C** | Reinstall / new device | `session_recovery.dart` after OTP login | Query active `order_sessions` for `customer_id` |
| **DROP-D** | FCM token stale | `auth` or `bootstrap` startup | FCM + Realtime dual notify on call |
| **DROP-E** | Payment external app switch | `payment_result_handler.dart` | Persist `pending_payment_order_id`; resume checks `check_payment_status` |

### 6.1 Storage Policy

| Store | Allowed keys | Forbidden |
| --- | --- | --- |
| **SecureStorage** | Supabase access/refresh tokens | phone, card, OTP |
| **SharedPreferences** | `session_id`, `store_id`, locale, pending payment ids (transient) | raw PII, secrets |

Server remains source of truth for `order_sessions`, `orders`, `payment_ledger`, `kds_tickets` (900102 §2).

---

## 7. Scope Implementation Order

From `900102` and `impact_scope.md`:

```text
1. Scope D — Server runtime guard (Supabase migrations/functions) — NOT Flutter
2. Scope C — KDS HOLD/COMMITTED UI
3. Scope A — Customer waiting / preorder / payment handoff
4. Scope B — Staff call / seat / table
5. Scope E — DID projection
```

Flutter MVP documentation assumes **Scope D passes** before customer or KDS UI claims payment/KDS correctness.

---

## 8. Channel Entry Points

### 8.1 Customer App (Channel 2 — this MVP)

| Entry | Route / trigger | First RPC / action | Next screen |
| --- | --- | --- | --- |
| Cold start | `/` boot | `SupabaseInit` | Login or session recovery |
| OTP login | `/login` | Supabase Auth OTP | `_recoverActiveSession()` |
| QR / deep link | `/store/:storeId` | `bootstrap_customer_app_v2` | Language → waiting or menu |
| NFC / link (future) | `/handoff?token=` | validate link token | Same as QR |
| Waiting register | `/waiting/register` | `register_waiting` | Waiting status |
| Preorder | `/waiting/preorder` | create preorder RPC | Cart / submit |
| Payment | `/payment/:orderId` | Toss widget → Edge confirm | Pending until server APPROVED |
| Post-pay | `/order/complete` | read server status only | Complete UI |

Router implementation file: `lib/app/router.dart` (planned).

### 8.2 Staff App Surface (Scope B)

Same binary or flavor TBD. Planned entry:

```text
/staff/:storeId/waiting   → waiting list, call, seat, read-only payment/KDS
```

Staff must not trigger KDS release or payment approval from client (900102 Scope B prohibitions).

### 8.3 KDS Surface (Scope C)

```text
/kds/:storeId/:stationId   → HOLD grey / COMMITTED active; no release button
```

### 8.4 DID Surface (Scope E)

```text
/did/:storeId              → waiting numbers, call overlay; no payment detail
```

---

## 9. Dependencies (pubspec)

Current foundation dependencies:

| Package | Purpose |
| --- | --- |
| `supabase_flutter` | Auth, RPC, Realtime |
| `flutter_riverpod` / `riverpod` | DI, notifiers |
| `go_router` | Declarative routes (wired at Scope A) |
| `flutter_secure_storage` | JWT storage (Ch2) |
| `shared_preferences` | Non-sensitive session hints |
| `uuid` | correlation_id generation |

Add when scope starts: `firebase_messaging` (DROP-D), Toss payments SDK (Scope A payment).

---



## 10. Pre-Implementation Checklist for Each Scope

Before Codex modifies code for any Scope, the following artifacts must exist and agree with this overview:

| Artifact | Required contents |
| --- | --- |
| `impact_scope.md` | affected files, imports, routes, SQL/RLS/test locations, no-modification statement from Cursor |
| `overview.md` | scope-specific user flow and architecture boundary |
| `logic.md` | RPCs, state transitions, error handling, idempotency, unknown-state behavior |
| `test_plan.md` | lint/typecheck/unit/integration/security/idempotency/duplicate/unknown-state tests |
| `change_contract.md` | allowed changes, forbidden changes, rollback criteria, expected diff shape |
| `implementation_approval.md` | Human-approved file whitelist and "only these files" instruction |

Minimum approval fields:

```text
Approved scope:
Approved files:
Forbidden files:
Expected RPCs:
Expected state transitions:
Expected tests:
Rollback method:
Evidence required:
Human approval statement:
```

## 11. Verification Commands (Foundation)


```bash
cd catchmenu_app
flutter analyze
flutter test
grep -rn "release_kds_after_payment" lib/   # expect: app_constants + rpc guard only
grep -rn "\.rpc(" lib/                       # expect: rpc_caller.dart only
```

Align feature tests with `900103` as scopes land.

---

## 12. Non-Scope

This overview does not define:

* SQL migrations or Edge Functions (Scope D)
* Production release approval
* POS Gateway integration (`docs/000800_*`)
* Admin console or franchise OS

---

## 13. Acceptance Criteria

This overview is acceptable when it:

* defines a complete target tree under `catchmenu_app/lib/`
* lists existing foundation files and planned scope files
* documents Supabase config, schema exposure, and RpcCaller-only RPC rule
* maps DROP-A~E to modules
* lists channel entry points for customer, staff, KDS, DID
* preserves 900102 scope order and invariant boundaries
* does not authorize implementation by itself
* records that `600003` is a pre-gate Foundation bootstrap baseline, not a precedent
* defines the required Controlled Implementation Gate before future Scope code changes
* gives Codex explicit read-only interpretation rules

---

## 14. Final Rule

```text
The Flutter MVP structure exists to enforce server authority and auditable handoff.
Folder layout is acceptable only when every feature path can reach Supabase through RpcCaller,
recover sessions under DROP-A~E,
and never treat client UI success as payment or KDS release truth.
```
