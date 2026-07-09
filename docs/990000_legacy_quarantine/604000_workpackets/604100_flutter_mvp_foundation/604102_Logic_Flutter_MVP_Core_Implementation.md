# 604102_Logic_Flutter_MVP_Core_Implementation.md

Status: Reinforced Draft  
Lifecycle: Logic  
Owner: TBD  
Last Updated: 2026-07-01

---

## 0. Purpose

This document defines the **core Flutter implementation logic** for the Catch Menu MVP:

* `rpc_caller.dart` detailed design
* Supabase initialization
* Session recovery flows (DROP-A~E)
* Standard error handling
* Application of invariants INV-001~006 on the client

This is logic documentation only. It does not authorize code changes.

Upstream references:

| Document | Role |
| --- | --- |
| `900102_ChangeContract_…` | Invariants, scopes, forbidden client actions |
| `900121_Logic_Channel_2_…` | DROP-A~E session defense |
| `900103_TestPlan_…` | Expected states and test cases |

Structure reference: `604101_Overview_Flutter_MVP_Project_Structure.md`

Existing implementation baseline: `catchmenu_app/lib/core/` (foundation scaffold)


Related implementation record: `604103_Module_Flutter_MVP_Foundation_Scaffold_Implementation.md`

Gate classification:

```text
This document is a Logic Contract baseline.
It is not implementation approval.
It defines required behavior, forbidden behavior, tests, and failure handling for future implementation.
Codex may use it only together with an approved change_contract and implementation_approval.md.
```

### 0.1 Retrospective Foundation Note

`600003` reports that a Foundation scaffold already created `RpcCaller`, `AppError`, `SupabaseInit`, constants, and placeholder feature folders. This logic document accepts that scaffold only as a pre-gate Foundation baseline. It does not certify that all tests in this document already exist. In particular, `rpc_caller_test.dart`, mock PostgREST failure handling, and dev audit failure handling must still be verified or added under a later approved Foundation-hardening or Scope-specific gate.

### 0.2 Codex Reading Rule

Codex must not implement this entire document at once. Codex must implement only the subsection explicitly referenced by the approved change contract. If a subsection requires files not listed in `implementation_approval.md`, Codex must stop and report a scope conflict instead of adding those files.

---

## 1. Core Rule

```text
The client interprets and displays server state.
The client does not own payment approval, KDS release, or final handoff truth.
Every mutation path goes through RpcCaller with correlation_id and AppError normalization.
```


### 1.1 Authority Boundary

| Layer | Owns | Must not own |
| --- | --- | --- |
| Flutter UI | Rendering server-confirmed state, user input, retry prompts | Payment truth, KDS release truth, final session truth |
| Notifier | Screen state, loading/error transitions | Raw SQL/RPC exception interpretation |
| Repository | Feature-specific RPC intent via `RpcCaller` | Direct Supabase RPC calls |
| `RpcCaller` | correlation_id, schema-aware RPC, error normalization, forbidden client guard | Business approval decisions |
| Server RPC/Edge | payment approval, KDS release, ledger, RLS, idempotency | Flutter-only optimistic state |

The client may cache hints, but every terminal state must be explainable by the last server read or mutation and its `correlation_id`.

---

## 2. rpc_caller.dart Detailed Design

### 2.1 Responsibilities

| # | Responsibility | Rationale |
| --- | --- | --- |
| 1 | Sole RPC entry | Prevents bypass of guards and audit |
| 2 | Correlation ID | INV-006 traceability from Flutter to ledger |
| 3 | Forbidden RPC block | INV-004 client enforcement |
| 4 | Dev audit log | INV-006 evidence in `catchmenu_dev` |
| 5 | Error normalization | UI never parses raw Postgrest errors |
| 6 | Schema-aware RPC | Multi-schema Postgres layout |



### 2.1.1 Non-Negotiable Implementation Rules

Codex must preserve these rules when touching `rpc_caller.dart` or any repository:

```text
1. No repository may call Supabase.instance.client.rpc() directly.
2. No widget may import PostgrestException.
3. No feature may catch raw RPC errors and parse message strings for business truth.
4. No client code may call release_kds_after_payment.
5. No local state may mark payment APPROVED or KDS COMMITTED without server confirmation.
6. Every RPC result must expose correlationId for support/evidence.
7. Dev audit failure must never break the user flow.
8. Prod client audit must not write to catchmenu_dev.
```

If an approved implementation appears to require breaking one of these rules, the correct action is to stop and amend the change contract, not to implement around the guard.

### 2.2 Public API

```dart
Future<RpcResult<T>> call<T>(
  String fnName, {
  Map<String, dynamic>? params,
  String schema = AppConstants.schemaPublic,
  String pipeline = AppConstants.pipelineSession,
  String module = 'unknown',
  String? flutterScreen,
  String? correlationId,
  String? injectCorrelationIdAs,
});
```

| Parameter | Required | Description |
| --- | --- | --- |
| `fnName` | Yes | Postgres function name without schema prefix |
| `schema` | Yes | e.g. `catchmenu_pos`, `catchmenu_payment` |
| `params` | No | RPC args with `p_` prefix convention |
| `pipeline` | Yes | Audit classification (`WAITING_HANDOFF`, `PAYMENT`, …) |
| `module` | Yes | Repository or notifier name |
| `flutterScreen` | No | Screen name for audit |
| `correlationId` | No | Auto UUID v4 if omitted |
| `injectCorrelationIdAs` | No | e.g. `p_correlation_id` when RPC accepts it |

### 2.3 Execution Flow

```text
call(fnName, ...)
  │
  ├─► Generate correlationId (if missing)
  │
  ├─► INV-004: fnName in forbiddenClientRpcs?
  │     yes → AppError.forbiddenClientCall → audit ERROR → RpcResult.failure
  │
  ├─► Merge params (+ optional correlation inject)
  │
  ├─► _rpc(schema, fnName, params)
  │     public  → client.rpc(fnName)
  │     other   → client.schema(schema).rpc(fnName)
  │
  ├─► success → audit SUCCESS (dev) → RpcResult.success
  │
  ├─► PostgrestException → AppError.rpc → audit ERROR → RpcResult.failure
  │
  └─► other Exception → AppError.network → audit ERROR → RpcResult.failure
```

### 2.4 RpcResult Contract

Repositories **must** branch on `RpcResult`, not throw:

```dart
final res = await caller.call<Map<String, dynamic>>(
  'register_waiting',
  schema: AppConstants.schemaPos,
  params: {'p_store_id': storeId, 'p_party_size': partySize},
  pipeline: AppConstants.pipelineWaiting,
  module: 'waiting_repository',
  flutterScreen: 'waiting_register_screen',
);

if (res.isFailure) {
  // res.error: AppError, res.correlationId for support
  return;
}
final sessionId = res.data!['session_id'];
```

`requireData` may be used only when failure should crash in dev tests.

### 2.5 Dev Audit (`write_audit_log`)

When `AppConstants.isDev`:

```text
catchmenu_dev.write_audit_log(
  p_pipeline, p_module, p_event_type, p_event_status,
  p_log_session_id, p_rpc_name, p_flutter_screen,
  p_input_payload, p_error_detail, p_duration_ms,
  p_app_version, p_flutter_platform
)
```

Audit failure is swallowed — dev convenience must not break user flows.

Prod: audit RPC is not called from client (server ledger remains authoritative for INV-006).

### 2.6 Forbidden RPC List

Maintain in `AppConstants.forbiddenClientRpcs`:

| RPC | Reason |
| --- | --- |
| `release_kds_after_payment` | SYSTEM-only; invoked inside `confirm_payment()` |

Extend list only via change contract amendment. Each addition requires:

* 900102 scope approval
* test that `grep` shows no direct call sites
* `rpc_caller_test` asserting FORBIDDEN_CLIENT_CALL

### 2.7 Repository Usage Rules

```text
ALLOWED:
  waiting_repository → register_waiting, get_waiting_status, …
  payment_repository → client-side payment init helpers only;
                       confirm path via Edge Function / approved RPC
  kds_repository     → read tickets, transition_kds_ticket (staff actions)
                       NOT release_kds_after_payment

FORBIDDEN:
  Any file calling SupabaseClient.rpc directly
  Any feature importing PostgrestException for UI logic
  Catching raw dynamic from supabase without RpcCaller
```

### 2.8 Planned Tests (`test/core/rpc_caller_test.dart`)

| Case | Expect |
| --- | --- |
| Success path | `isSuccess`, correlationId non-empty |
| Forbidden RPC | `FORBIDDEN_CLIENT_CALL`, no network call |
| Postgrest error | `RPC_ERROR`, details populated |
| Network error | `NETWORK_ERROR` |
| Dev audit | mock client verifies write_audit_log on success/failure |



### 2.9 Mandatory Verification Gates for RpcCaller

The following checks are mandatory before any feature repository is allowed to depend on `RpcCaller` in production-like flows:

```bash
grep -rn "\.rpc(" lib/
# Expected: lib/core/supabase/rpc_caller.dart only

grep -rn "release_kds_after_payment" lib/
# Expected: app_constants.dart, rpc_caller guard/comment, README/docs only; no executable call site

flutter test test/core/rpc_caller_test.dart
```

Required `rpc_caller_test.dart` assertions:

| Test | Required assertion |
| --- | --- |
| direct success | returns `RpcResult.success`, non-empty `correlationId` |
| forbidden RPC | returns `FORBIDDEN_CLIENT_CALL`, does not invoke network client |
| PostgREST error | returns `AppError.rpc` with safe details |
| unknown exception | returns `AppError.network` or `UNKNOWN_ERROR` per implementation contract |
| audit success | writes dev audit when `isDev` and swallows audit failures |
| correlation injection | adds `p_correlation_id` only when requested |
| schema routing | `public` uses base RPC; non-public uses `.schema(schema).rpc()` |

A feature Scope may not claim verification complete if only `widget_test.dart` passes.

### 2.10 Direct RPC Exception Rule

A direct `.rpc(` call outside `rpc_caller.dart` is allowed only in a test mock/fake file explicitly named in `implementation_approval.md`. Production `lib/` code must have exactly one direct RPC gateway.

---

## 3. Supabase Initialization Logic

### 3.1 Boot Sequence

```text
main()
  WidgetsFlutterBinding.ensureInitialized()
  SupabaseInit.ensureInitialized()
    if already initialized → return
    if missing URL/key → throw AppError.notInitialized
    Supabase.initialize(url, anonKey, debug: isDev)
  runApp(ProviderScope → CatchMenuApp)
```

Current file: `lib/core/supabase/supabase_client.dart`

### 3.2 Planned Auth Extension (Scope A / Ch2)

When OTP login is implemented, replace plain initialize with:

```dart
await Supabase.initialize(
  url: AppConstants.supabaseUrl,
  anonKey: AppConstants.supabaseAnonKey,
  debug: AppConstants.isDev,
  authOptions: const FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,
    autoRefreshToken: true,
    persistSession: true,
  ),
);
```

### 3.3 Post-Init Hooks

After successful init, register (in `auth_session.dart`):

```text
supabase.auth.onAuthStateChange.listen(...)
  AuthChangeEvent.tokenRefreshed  → verify Realtime subscriptions (DROP-A)
  AuthChangeEvent.signedOut       → unexpected sign-out handler (DROP-A)
```

### 3.4 Global Access

```dart
SupabaseInit.client   // SupabaseClient — Realtime, Auth only
ref.read(rpcCallerProvider)  // all RPC
```

Document in code reviews: **RPC only through RpcCaller**.

### 3.5 Configuration Guard

If `!AppConstants.hasSupabaseConfig`:

* Boot screen shows `AppError.notInitialized` message (current behavior)
* No silent offline mode for MVP
* Tests may inject mock Supabase via Riverpod override (future)



### 3.6 Supabase Version Drift Rule

If the Supabase Flutter SDK deprecates an initialization parameter, Codex must not silently change authentication behavior. For example, replacing `anonKey` with `publishableKey` or changing auth options requires a change-contract note covering:

| Item | Required explanation |
| --- | --- |
| SDK version | installed and target version |
| key type | anon/publishable key compatibility |
| auth behavior | PKCE, auto refresh, session persistence |
| migration risk | boot failure, token refresh failure, RLS effect |
| rollback | exact code and dependency rollback |

Foundation may tolerate non-blocking analyzer info, but a future hardening gate must either fix the issue or mark it as an accepted warning with owner/date.

---

## 4. Session Recovery Flows (DROP-A~E)

### 4.1 Overview

```text
                    ┌─────────────────┐
                    │   App Launch    │
                    └────────┬────────┘
                             │
              ┌──────────────▼──────────────┐
              │ SupabaseInit + Auth restore │
              └──────────────┬──────────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
    DROP-A/C            DROP-E check         DROP-D FCM
    token refresh       pending payment     token sync
         │                   │                   │
         └───────────────────┼───────────────────┘
                             │
              ┌──────────────▼──────────────┐
              │ recoverActiveSession()      │  DROP-C
              │ (server order_sessions)     │
              └──────────────┬──────────────┘
                             │
                    route to correct screen
```

### 4.2 DROP-A — JWT Expiry

**Trigger:** Access token expired during WAITING or ARRIVAL_PENDING.

**Logic:**

```text
1. autoRefreshToken: true (Supabase SDK)
2. onAuthStateChange.tokenRefreshed:
     RealtimeManager.verifySubscriptions()
3. onAuthStateChange.signedOut (unexpected):
     attempt refresh once
     else → /login with banner "session expired"
4. RPC 401 from Postgrest:
     map to AppError.rpc with code hint
     UI: retry after refresh, not "payment complete"
```

**Must not:** Treat 401 as order cancellation or payment failure without server read.

### 4.3 DROP-B — Background / Foreground

**Trigger:** `AppLifecycleState.resumed`

**Logic:**

```text
1. lifecycle_observer notifies WaitingStatusNotifier
2. refreshWaitingStatus():
     RpcCaller.call('get_waiting_status', p_session_id)
     apply server state to UI (server wins)
3. RealtimeManager.resubscribeWaitingChannel(storeId)
4. Backup: Timer 30s while status in {WAITING, ARRIVAL_PENDING}
     if Realtime payload conflicts with poll → server wins
```

**900103 alignment:** Customer must not miss call → no erroneous NO_SHOW from client silence.

### 4.4 DROP-C — Device Change / Reinstall

**Trigger:** Successful OTP login, empty local session hints

**Logic:**

```text
1. Auth completes → customer_id available
2. recoverActiveSession():
     RPC query active order_sessions for customer_id
     status IN (WAITING, ARRIVAL_PENDING, SEATED)
     business_day = today
     LIMIT 1
3. If found:
     persist session_id, store_id to SharedPreferences
     navigate → waiting_status / payment / seated flow by server status
4. If not found:
     navigate → home / register waiting
```

**Must not:** Create duplicate waiting session without user intent.

### 4.5 DROP-D — FCM Token

**Trigger:** App start, `onTokenRefresh`

**Logic:**

```text
1. getToken() → compare savedFcmToken
2. if changed:
     RpcCaller.call('update_customer_fcm_token',
       p_customer_id, p_fcm_token)
3. Waiting call delivery:
     foreground → Realtime primary
     background → FCM primary
     both should converge on same server event id when possible
```

### 4.6 DROP-E — Payment App Switch

**Trigger:** Resume during Toss / card app redirect

**Logic:**

```text
Before external payment:
  prefs.setString('pending_payment_order_id', orderId)
  prefs.setString('pending_payment_session_id', sessionId)

On resume (lifecycle or deep link):
  pending = prefs.getString('pending_payment_order_id')
  if pending != null:
    res = RpcCaller.call('check_payment_status', p_order_id: pending)
    if res.data['paid'] == true OR ledger equivalent APPROVED:
       navigate → complete (server confirmed only)
    else:
       navigate → payment retry screen
    clear pending keys after handled
```

**INV-001 context:** Even if Toss UI showed success, Flutter complete screen requires server APPROVED.



### 4.7 Unknown-State Recovery Rule

When app-local hints conflict with server state, server state wins. If the server returns an unknown or incomplete state, Flutter must prefer a safe pending/retry UI rather than a terminal success UI.

| Conflict | Required client behavior | Forbidden behavior |
| --- | --- | --- |
| local pending payment, server says not found | show recovery/support path; do not create paid state | mark complete locally |
| Realtime says called, RPC says waiting | refresh and display RPC snapshot | trust Realtime as final |
| Toss callback success, server ledger pending | show confirming/retry path | release KDS or show final receipt |
| SharedPreferences has session, server expired it | clear local hint after user-safe message | recreate waiting silently |
| duplicate resume callback | idempotent check; single visible terminal state | submit duplicate confirm blindly |

### 4.8 Session Storage Evidence Rule

Every persisted session hint must have a matching clearing rule. `pending_payment_*` keys must be transient and cleared only after server-verified handling or explicit recovery reset. Long-lived raw PII, card data, OTP values, and service keys are forbidden in local storage.

---

## 5. Standard Error Handling

### 5.1 AppError Codes

| Code | Source | UI guidance |
| --- | --- | --- |
| `NETWORK_ERROR` | Socket, timeout, non-Postgrest | Retry button; no state mutation |
| `RPC_ERROR` | PostgrestException | Map message; show correlationId in dev/support |
| `FORBIDDEN_CLIENT_CALL` | rpc_caller guard | Dev-only surface; log critical in prod |
| `NOT_INITIALIZED` | Missing Supabase config | Config instruction screen |
| `UNKNOWN_ERROR` | Unclassified | Generic retry + support |

### 5.2 Layer Rules

```text
rpc_caller     → produces AppError inside RpcResult
repository     → returns RpcResult or domain Result; no BuildContext
notifier       → sets AsyncValue/error state
widget         → maps AppError.code → localized user string
                 never show raw postgres hint in prod UI
```

### 5.3 Payment-Specific Errors

| Situation | Client behavior |
| --- | --- |
| Toss success, server pending | Show "confirming payment…"; poll/check RPC |
| Toss fail | Show retry; do not release KDS locally |
| Duplicate confirm | Server idempotent → show existing approved state |
| Timeout | DROP-E recovery; do not assume failure |

### 5.4 Logging

```text
dev:  write_audit_log + debugPrint(correlationId)
prod: correlationId on support sheet only; no card/phone in logs
```



### 5.5 User-Facing Error Safety

Production UI must not display raw Postgres hints, SQLSTATE values, RLS policy names, card/payment provider internals, or stack traces. The UI may display a short support code derived from `correlationId`. Developer builds may show richer diagnostics only when they do not include PII or payment credentials.

### 5.6 Error-to-State Rule

An error is not a state transition. Network timeout, RPC error, or external payment callback ambiguity must not mutate business state locally. The next business state must be obtained from an approved server RPC or Edge verification path.

---

## 6. INV-001~006 Client Application

Invariants are **primarily enforced on the server** (900102 Scope D). The Flutter app must not undermine them.

### INV-001 — KDS Release Requires Approved Payment

| Layer | Client obligation |
| --- | --- |
| UI | Never show "kitchen started" because KDS card is visible in HOLD |
| Payment flow | Complete screen only after server reports APPROVED |
| KDS UI | HOLD = disabled cook actions (Scope C) |
| RPC | Never call `release_kds_after_payment` |

### INV-002 — Seating Is Not Payment

| Layer | Client obligation |
| --- | --- |
| Waiting app | SEATED status does not trigger payment complete or KDS release UI |
| Staff app | Seat action does not call payment or release RPC |

### INV-003 — Calling Is Not Payment

| Layer | Client obligation |
| --- | --- |
| Customer | ARRIVAL_PENDING shows "please come" not "order confirmed" |
| DID | Call display only |

### INV-004 — Client Is Not Release Authority

| Layer | Client obligation |
| --- | --- |
| rpc_caller | Block forbidden RPC set |
| KDS feature | No "force release" button |
| Tests | grep + unit test for forbidden calls |

### INV-005 — Release Is Idempotent

| Layer | Client obligation |
| --- | --- |
| Payment | Safe to retry confirm/check status; UI shows single terminal state |
| Client state | Idempotent handling of duplicate success callbacks (Toss + webhook race) |
| Note | Idempotent UPDATE is server-side; client avoids duplicate order submit keys where RPC supports `p_idempotency_key` |

### INV-006 — Ledger Evidence Is Required

| Layer | Client obligation |
| --- | --- |
| rpc_caller | correlation_id on every RPC; dev audit payload |
| RPC params | Pass correlation / idempotency when function signature requires |
| Client | Do not perform silent local state transitions without server event |
| Note | Full ledger events are written server-side; client contributes trace keys |

### 6.1 Invariant Quick Matrix

| INV | Client can | Client must not |
| --- | --- | --- |
| 001 | Poll payment; show HOLD vs COMMITTED from server | Infer COMMITTED from client payment widget |
| 002 | Show seated banner | Trigger release on seat |
| 003 | Show called banner | Trigger release on call |
| 004 | Use RpcCaller | Call release RPC |
| 005 | Retry status check | Assume duplicate confirm failed |
| 006 | Send correlation_id, audit metadata | Skip logging on "minor" RPCs |



### 6.2 Invariant Breach Handling

If a client path appears to violate an invariant, the app must fail closed:

| Detected issue | Required action |
| --- | --- |
| forbidden RPC attempted | block, return `FORBIDDEN_CLIENT_CALL`, write dev audit |
| KDS COMMITTED visible without approved payment evidence | refresh from server; do not enable cook actions |
| payment complete screen requested without server APPROVED | route to confirming/retry state |
| duplicate callback | check server idempotent status, show one terminal state |
| missing correlation ID | generate one before call; never send anonymous mutation |

The audit review must treat any invariant breach as release-blocking unless the server demonstrably rejects the path and the client surfaces a safe state.

---

## 7. Realtime Logic (Companion to RpcCaller)

Realtime is not wrapped in RpcCaller but must follow the same authority rules.

```text
Subscribe:
  waiting:{store_id}     → call events
  kds:{store_id}:{station} → ticket status
  did:{store_id}         → display projection

On resume (DROP-B):
  removeChannel(old)
  subscribe fresh
  immediately RPC refresh status

On payload received:
  update local UI state as "hint"
  if payload conflicts with last RPC snapshot → RPC refresh wins
```

---

## 8. State Application Rules

When applying server data to UI:

```text
1. Fetch or receive server payload
2. Map to view model (explicit fields, no guessed defaults)
3. If field missing → show unknown / loading, not success
4. Payment and KDS fields from separate sources → do not merge optimistically
5. Record last correlation_id on screen for support
```

Align session states with 900103 §2.1 and KDS states with §2.2.

---

## 9. Scope D Gate Before Feature Logic

Flutter feature logic in §4~§8 is **blocked** until Scope D server guards pass:

```text
confirm_payment() idempotent
release_kds_after_payment() HOLD-only update idempotent
Edge functions verify Toss before confirm
```

Verify with 900103 invariant tests and server integration tests before Scope C/A UI work.



### 9.1 Scope D Dependency Evidence

Before Scope C/A/B/E Flutter code can claim correctness, Scope D evidence must exist and be linked from the relevant implementation approval:

| Evidence | Required proof |
| --- | --- |
| server migration dry-run | no destructive SQL, idempotent rerun behavior |
| `confirm_payment()` | verifies provider status, writes ledger, idempotent duplicate handling |
| `release_kds_after_payment()` | server-only authority, HOLD-only idempotent update |
| RLS/security check | anon/user role cannot bypass release/payment authority |
| Edge Function verification | payment provider callback verified before server confirm |
| audit/ledger evidence | correlation/idempotency keys traceable |

If any Scope D evidence is missing, Flutter must display only non-terminal or read-only states for the dependent feature.

---

## 10. Anti-Patterns

Prohibited:

* `supabase.rpc()` outside `rpc_caller.dart`
* Showing payment complete on Toss `onSuccess` alone
* Local `kds_status = COMMITTED` without server event
* Skipping correlation_id on "read" RPCs that mutate audit trail
* Ignoring DROP-B resume refresh
* Storing phone or card data in SharedPreferences
* Catching exceptions in widgets without AppError mapping
* Adding forbidden RPC without 900102 amendment
* Treating `600003` Foundation scaffold as approval for runtime Scope implementation
* Expanding from README placeholders into feature screens without `implementation_approval.md`

---


## 11. Codex Implementation Boundary

When Codex receives this logic document, the implementation prompt must include the exact approved subsection and file whitelist. The safe instruction is:

```text
You are not allowed to redesign, refactor, rename, move files, or expand the scope.
You may only implement the approved change_contract within the files listed in implementation_approval.md.
If 600001/600002 conflict with current code, stop and report the conflict.
Do not silently normalize architecture.
```

Codex output must update or create `implementation_module.md` with:

| Field | Required content |
| --- | --- |
| implemented files | exact paths |
| changed symbols | functions/classes/constants touched |
| contract mapping | which overview/logic/change_contract clauses were implemented |
| tests run | command, result, exit code, accepted warnings |
| invariant impact | INV-001~006 status |
| rollback | exact file or commit rollback path |
| unresolved risks | schema exposure, SDK drift, RLS, test gaps |

## 12. Acceptance Criteria

This logic document is acceptable when it:

* fully specifies RpcCaller behavior and extension points
* documents Supabase init and planned auth options
* defines DROP-A~E recovery flows with server-first reconciliation
* defines AppError handling across layers
* maps INV-001~006 to concrete client rules
* references 900102 / 900121 / 900103 without redefining server authority
* does not authorize implementation by itself
* records that the existing Foundation scaffold is a pre-gate baseline, not future authorization
* defines mandatory RpcCaller verification beyond the boot widget test
* gives Codex explicit boundaries for future implementation

---

## 13. Final Rule

```text
Flutter MVP core logic is correct when every handoff screen can explain
which server RPC last confirmed its state,
which correlation_id proves the call,
and why the client did not pretend to approve payment or release KDS.
```
