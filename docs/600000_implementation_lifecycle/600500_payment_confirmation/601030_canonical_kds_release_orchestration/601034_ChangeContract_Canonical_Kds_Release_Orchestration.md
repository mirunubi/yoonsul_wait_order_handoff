# 601034_ChangeContract_Canonical_Kds_Release_Orchestration.md

Status: Draft
Lifecycle: ChangeContract
Stage: 5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`canonical_kds_release_orchestration`

## Authority

- `601031_Overview_Canonical_Kds_Release_Orchestration.md`
- `601032_Logic_Canonical_Kds_Release_Orchestration.md`
- `601033_TestPlan_Canonical_Kds_Release_Orchestration.md`

## §0 Contract summary

This ChangeContract authorizes creating one new shared function, `catchmenu_payment.request_kds_release_after_payment()` (full design: `601032_Logic.md` §1), and redefining exactly one existing live function, `catchmenu_payment.confirm_payment_from_provider()` (full design: `601032_Logic.md` §2), in a new forward migration file. The already-applied source file `sql/migrations/0027_create_payment_intent_rpc.sql` remains immutable/original and is not edited. No other file, function, or schema object may change.

The new function authorizes `payment_ledger.kds_release_authorized` inline (mirroring `release_kds_after_payment()`'s pattern, since `authorize_kds_release()` was dropped by `0157`), then delegates the actual per-ticket 7-condition gate entirely to the existing, unmodified `catchmenu_kds.bulk_commit_kds_tickets()`/`commit_kds_ticket()`. It never raises — every internal failure is caught and returned as `{success:true, result_code:'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED', ...}` — so a KDS-side failure can never roll back the caller's already-committed `payment_ledger` row (`601032_Logic.md` §0/§2, `600652_Logic.md` §9.2's atomicity principle re-applied).

**Numbering note**: `sql/migrations/` currently tops out at `0165`; no `0166`/`0167` file exists on disk or in `catchmenu_meta.migration_history` (live-reconfirmed at Stage 5, `601033_TestPlan.md` §0). `0166` is available for this workpacket's use — Stage 8 must re-confirm this immediately before creating the file, per the project's standing numbering discipline.

**Source-of-truth note (2026-07-18 Stage 8 correction)**: `sql/migrations/0027_create_payment_intent_rpc.sql` is an already-applied migration and remains immutable/original. The latest live definition of `catchmenu_payment.confirm_payment_from_provider()` for this workpacket is provided only by the new forward migration `0166_canonical_kds_release_orchestration.sql`; future readers must consult `0166`, not `0027`, for the post-Option-C body.

**`p_decision='PENDING'` design defect, found and fixed 2026-07-18 (Cursor+Codex Critical tier cross-verification)**: the original `601032_Logic.md` §1.2 mapped both `PARTIAL_CAPACITY_HOLD` and `CAPACITY_HOLD` to `p_decision := 'PENDING'`. `'PENDING'` is not one of the 11 values `catchmenu_ledger.audit_records.chk_audit_decision` (`0008:105-119`) actually accepts (`APPROVED`/`REJECTED`/`OVERRIDDEN`/`DELEGATED`/`ESCALATED`/`CANCELLED`/`COMPLETED`/`FAILED`/`NOTED`/`SUSPENDED`/`REVOKED`). Had this shipped, every `PARTIAL_CAPACITY_HOLD`/`CAPACITY_HOLD` call would have crashed its own `append_audit_record()` INSERT, been caught by `request_kds_release_after_payment()`'s own `EXCEPTION WHEN OTHERS` handler, and been misreported to the caller as `PAYMENT_CONFIRMED_KDS_RELEASE_FAILED` — a normal, healthy "still waiting for kitchen capacity" outcome silently relabeled as a failure. Corrected to `'SUSPENDED'` (§2.1) — chosen over `'DELEGATED'` (implies a retry/reconciliation receiver that `601031_Overview.md` §3 already confirmed doesn't exist) and over reusing `'NOTED'` (already used for `NO_TICKETS_TO_PROCESS`; reusing it here would conflate "nothing to do" with "actively on hold," collapsing two operationally distinct audit-trail meanings), based on the existing precedent at `0041_create_agent_heartbeat_rpc.sql:394` (`'agent_module_isolated'` uses `SUSPENDED` for the same "temporarily halted, may resume" concept).

**Verification-gap root cause, worth recording as a session lesson**: this defect survived this session's own Stage 5 authoring because `601033_TestPlan.md` §1.2 originally (incorrectly) asserted "`decision` has no CHECK constraint (free text)" — a false claim never actually checked against `0008_create_ledger_audit.sql`'s full `CREATE TABLE` body (the constraint sits at lines 105-119, past where this session's earlier read of that file stopped). And separately, none of `601032_Logic.md` §3's three `pg_temp` reproductions (§3.1 `COMMITTED`, §3.2 the exception path, §3.3 `NO_TICKETS_TO_PROCESS`) ever exercised the `PARTIAL_CAPACITY_HOLD`/`CAPACITY_HOLD` branches — exactly the two branches carrying the bug. Two independent gaps (an unverified schema claim, and incomplete branch coverage in live testing) compounded to let an invalid literal reach a Stage 5 "final design" document. `601033_TestPlan.md` §1.2 now states the actual constraint, and §2.2/§2.3 now include their own executable fixtures exercising exactly these two branches (Stage 4 Critical-tier correction round, `601033_TestPlan.md`).

## §1 Allowed files and objects

### §1.1 Allowed new SQL file

- One new migration, tentatively `sql/migrations/0166_canonical_kds_release_orchestration.sql` (Stage 8 must re-run the next-available-number check per §0 before creating it; if `0166` is claimed by another workpacket in the interim, use the actual next-available number instead).

### §1.2 Allowed existing-file edit

- None. `sql/migrations/0027_create_payment_intent_rpc.sql` is an already-applied migration and must stay byte-for-byte original. The live `catchmenu_payment.confirm_payment_from_provider()` replacement is carried only by the new forward migration in §1.1/§3.

### §1.3 Allowed new objects

- Function `catchmenu_payment.request_kds_release_after_payment(p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_ledger_id uuid, p_actor_type text default 'SYSTEM', p_correlation_id text default null) returns jsonb` — full body per `601032_Logic.md` §1.2.

If the project convention requires the existing `0027` source file and the new forward migration to stay semantically identical for `confirm_payment_from_provider()`'s body (the pattern established by `601020`/`601024` §1.2), both must be updated together.

### §1.4 Changelog

`sql/migrations/CHANGELOG.md` may be appended only if the project migration convention requires recording the new migration. No existing entry may be rewritten.

## §2 Required implementation contract

### §2.1 New function — `catchmenu_payment.request_kds_release_after_payment()`

Exactly as specified in `601032_Logic.md` §1.1-§1.4:

- Signature: `(p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_ledger_id uuid, p_actor_type text default 'SYSTEM', p_correlation_id text default null) returns jsonb`, `language plpgsql volatile security definer set search_path = catchmenu_payment, catchmenu_kds, catchmenu_ledger, catchmenu_audit, catchmenu_common`.
- Step 1: inline `update catchmenu_payment.payment_ledger set kds_release_authorized = true, kds_release_authorized_at = now(), kds_release_authorized_by = p_actor_type where id = p_ledger_id and tenant_id = p_tenant_id and store_id = p_store_id`.
- Step 2: delegate to `catchmenu_kds.bulk_commit_kds_tickets(p_tenant_id, p_store_id, p_order_id, p_force_conditions := null, p_correlation_id)` — unmodified, called as-is.
- Step 3: translate the bulk-commit result into exactly 5 `result_code` values, in this exact branch order (the order matters — the zero-ticket check must precede the committed check):
  1. `not success` → `PAYMENT_CONFIRMED_KDS_RELEASE_BLOCKED`
  2. `committed_count=0 and pending_count=0 and skipped_count=0` → `PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS`
  3. `pending_count=0 and skipped_count=0` → `PAYMENT_CONFIRMED_KDS_COMMITTED`
  4. `committed_count>0` → `PAYMENT_CONFIRMED_KDS_PARTIAL_CAPACITY_HOLD`
  5. else → `PAYMENT_CONFIRMED_KDS_CAPACITY_HOLD`
- Audit: one `catchmenu_audit.append_audit_record()` call per invocation, `p_audit_domain := 'payment'`, `p_audit_type := 'kds_release_requested'`, `p_decision` mapped per `601032_Logic.md` §1.2 (`COMMITTED`→`APPROVED`, `RELEASE_BLOCKED`→`FAILED`, `NO_TICKETS_TO_PROCESS`→`NOTED`, else→`SUSPENDED`). **`SUSPENDED` is required, not `PENDING`** — `catchmenu_ledger.audit_records.chk_audit_decision` (`0008:105-119`) does not accept `'PENDING'` at all; see §0's correction note and Open Item (h) below.
- `EXCEPTION WHEN OTHERS`: never re-raises. Writes a second audit record (`p_audit_type := 'kds_release_requested_failed'`, `p_decision := 'FAILED'`) and returns `{success:true, result_code:'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED', ledger_id, order_id, error_detail:{sqlstate}}`.
- Always returns `success:true` in every branch, including the exception branch (`601032_Logic.md` §1.2's closing rationale — this function's own "success" means "request processed," not "ticket committed"; `result_code` carries the real state).
- GRANT/REVOKE exactly per `601032_Logic.md` §1.3: `revoke all ... from public; grant execute ... to authenticated;`.

### §2.2 `confirm_payment_from_provider()` modification — exact insertion point

Per `601032_Logic.md` §2.1: the existing `payment_ledger` INSERT (source lines 263-289, `kds_release_authorized := false`) is **not** changed. `v_kds_release_result jsonb` is added to the `declare` block. Immediately after the existing `audit_id` calculation and immediately before the existing `return`, insert a call to the new function and replace the `return` block. **(2026-07-18, Option C — supersedes the earlier Option A/B choice, see §2.3)** the call is wrapped in a narrow nested `begin...exception when others...end;` block that covers only this call — nothing before it (intent validation, the `payment_ledger` INSERT, `kds_tickets`/`kds_events` updates, this function's own `append_audit_record()` call) is wrapped:

```sql
begin
  v_kds_release_result := catchmenu_payment.request_kds_release_after_payment(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := v_intent.order_id,
    p_ledger_id := v_ledger_id,
    p_actor_type := 'PROVIDER',
    p_correlation_id := p_correlation_id
  );
exception
  when others then
    perform catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'payment',
      p_audit_type := 'kds_release_call_unexpected_exception',
      p_audit_category := 'FINANCIAL',
      p_actor_type := 'PROVIDER',
      p_actor_id := null,
      p_subject_type := 'payment_ledger',
      p_subject_id := v_ledger_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object('error', sqlerrm, 'sqlstate', sqlstate),
      p_order_id := v_intent.order_id,
      p_correlation_id := p_correlation_id
    );
    v_kds_release_result := jsonb_build_object(
      'success', true,
      'result_code', 'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED',
      'ledger_id', v_ledger_id,
      'order_id', v_intent.order_id,
      'error_detail', jsonb_build_object('sqlstate', sqlstate)
    );
end;

return jsonb_build_object(
  'success', true,
  'ledger_id', v_ledger_id,
  'intent_id', p_intent_id,
  'ledger_status', 'APPROVED',
  'approved_amount', p_approved_amount,
  'kds_release_authorized',
    (v_kds_release_result->>'result_code' = 'PAYMENT_CONFIRMED_KDS_COMMITTED'),
  'kds_tickets_payment_confirmed', v_kds_updated,
  'kds_release_result', v_kds_release_result,
  'result_code', v_kds_release_result->>'result_code',
  'reconciliation_status', 'PENDING',
  'message_code', case
    when v_kds_release_result->>'result_code' = 'PAYMENT_CONFIRMED_KDS_COMMITTED'
      then 'payment_approved_kds_released'
    else 'payment_approved_kds_pending'
  end,
  'audit_id', v_audit_id
);
```

Required invariant (Stage 4 correction — must not regress): `kds_release_authorized` in this response is **derived from `result_code`**, `true` only when it equals `PAYMENT_CONFIRMED_KDS_COMMITTED`. It must not be hardcoded to `true` or `false`. This response field's meaning is deliberately distinct from the `payment_ledger.kds_release_authorized` **DB column**, which is unconditionally `true` after Step 1 of §2.1 regardless of outcome — the two are allowed to diverge, per `601032_Logic.md` §2.1's explicit note.

The prior response fields `'kds_release_authorized', false` and `'next_step', 'KDS_CAPACITY_CHECK_REQUIRED'` are removed (no longer accurate at this point in execution).

### §2.3 좁은 중첩 EXCEPTION 블록 — 옵션 C (ChatGPT 교차검증, Human 최종 결정, 재논의 금지 — Option A/B 양자택일 대체)

**이전 결정(Option A/B 양자택일)은 폐기됐다.** 원래 §2.3은 "`confirm_payment_from_provider()` 자신에게 방어적 `EXCEPTION` 핸들러를 추가할지(A)/제외할지(B)"를 물었는데, 이 질문 자체에 애매함이 있었다 — "함수 자신에게 추가"가 함수 **전체**를 감싸는 것을 의미한다면, `request_kds_release_after_payment()` 호출(함수 끝부분)에서 발생한 예외를 잡는 순간 PL/pgSQL 중첩 예외 블록의 동작 원리상(예외 블록은 **자신이 시작된 지점까지만** 롤백한다 — `pg_temp`로 라이브 실증, `601032_Logic.md` §2.1/§2.2) 함수 **시작부터**의 모든 작업 — 이미 완료된 `payment_ledger` INSERT를 포함해서 — 이 함께 롤백돼버린다. 이것이 ChatGPT가 지적한 위험이다: KDS 알림이라는 부수적 단계의 버그가 이미 정상 완료된 결제 승인 자체를 무효화시켜, "결제는 실패했는데 웹훅 응답은 성공"보다 더 위험한 "결제는 사실 성공했는데 그 사실 자체가 사라져버리는" 상황을 만들 수 있었다.

**옵션 C(대체 설계, 더 이상 대안이 아니라 유일한 확정 설계)**: `EXCEPTION` 핸들러를 함수 전체가 아니라 `request_kds_release_after_payment()` 호출 **그 자체만**을 감싸는 신규 중첩 `begin...exception...end` 블록에 붙인다(§2.2의 최종 SQL). 이 중첩 블록의 시작점이 이미 `payment_ledger` INSERT 등 payment-core 작업이 전부 끝난 **이후**이므로, 이 블록 안에서 발생하는 예외는 그 이전 작업을 전혀 건드리지 않는다 — 2026-07-18 `pg_temp`로 직접 실증(`601032_Logic.md` §2.1/§2.2, `601033_TestPlan.md` §6.4가 라이브 함수 체인 전체로 재현).

- **payment-core 구간(intent 검증 ~ `payment_ledger` INSERT ~ 이 함수 자신의 감사기록)은 감싸지 않는다** — 이 구간의 실패는 여전히 예외로 자연 전파되어 진짜 결제 실패로 처리된다(Option B와 동일한 부분).
- **`request_kds_release_after_payment()` 호출만 좁게 감싼다** — 이 호출이 (정상적으로는 도달 불가능해야 하지만) 예외를 던지면, 감사기록(`p_audit_domain := 'payment'`, `p_audit_type := 'kds_release_call_unexpected_exception'`, `p_audit_category := 'FINANCIAL'`, `p_decision := 'FAILED'`) 후 `v_kds_release_result`를 신규 함수 자신이 `RELEASE_FAILED`를 반환했을 때와 동일한 형태(`{success:true, result_code:'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED', ...}`)로 합성해 이어서 진행한다 — 결제 자체는 이미 성공했으므로 `success:true`를 유지한다(§2.1 신규 함수 핸들러와 동일한 극성 — 더 이상 "반대 극성의 두 번째 핸들러"가 아니라, 같은 원칙의 연장).

Human 승인(§9)은 이제 "A냐 B냐" 양자택일이 아니라, **이 하나의 개선된 설계(옵션 C)를 적용할지 여부**를 확인하는 단일 항목이다.

## §3 Allowed Operations (narrow verbs)

Per `000701_Guide_Controlled_AI_Development_Pipeline.md` §9.14's Operation Granularity Rule.

**New file `sql/migrations/0166_canonical_kds_release_orchestration.sql`** (number to be reconfirmed, §0/§1.1):

1. Create the file with a header identifying its purpose, `Depends on: 0165_menu_price_list_architecture_phase0.sql` (sequential-numbering convention only, no functional dependency).
2. `CREATE OR REPLACE FUNCTION catchmenu_payment.request_kds_release_after_payment(...)` exactly as specified in §2.1.
3. `REVOKE ALL ON FUNCTION catchmenu_payment.request_kds_release_after_payment(...) FROM PUBLIC` + `GRANT EXECUTE ... TO authenticated` — per §2.1's final bullet. No other GRANT.
4. `CREATE OR REPLACE FUNCTION catchmenu_payment.confirm_payment_from_provider(...)` — full function body, re-declared with exactly the §2.2 insertion (the narrow nested `begin...exception...end;` block wrapping only the `request_kds_release_after_payment()` call, per §2.3's Option C design) and otherwise byte-identical to the current live definition. This narrow wrapper is now a required part of the design, not conditional on a Human choice — §9 confirms Human's approval of applying it, not a choice between alternatives.

**Existing file `sql/migrations/0027_create_payment_intent_rpc.sql`** (§1.2):

5. Do not edit. Confirm its original checksum before applying `0166`; the forward migration's `CREATE OR REPLACE FUNCTION catchmenu_payment.confirm_payment_from_provider(...)` is the only authorized source for the post-Option-C live definition.

No operation is authorized on any other file.

## §4 Forbidden Operations

- Editing `catchmenu_payment.confirm_payment(...)` (`0098`, POS path) in any way — explicitly deferred to a future workpacket (`601031_Overview.md` §0.2 (3), Open Item (b)).
- Editing `catchmenu_payment.resolve_payment_uncertain(...)`, `catchmenu_payment.create_payment_intent(...)`, or `catchmenu_payment.mark_payment_uncertain(...)` — all 3 in the same `0027` file as the one function this contract may touch, but out of scope (`601031_Overview.md` §0.2 (4)/§5).
- Editing `catchmenu_kds.bulk_commit_kds_tickets(...)`, `catchmenu_kds.commit_kds_ticket(...)`, or `catchmenu_kds.evaluate_kds_capacity(...)` (`0028`/`0039`) in any way. These are reused exactly as they exist live today.
- Editing `sql/migrations/0038_create_toss_webhook_processor_rpc.sql`, `sql/migrations/0056_create_van_integration_rpc.sql`, or `sql/migrations/0143_add_no_payment_kds_release_policy.sql`.
- Any `GRANT` to `public` or any `GRANT` beyond §2.1's `authenticated`-execute on the new function.
- Any schema change (new column, new table, new CHECK constraint) — this workpacket is function-body-only.
- Designing or implementing a `CAPACITY_CHECKING` retry/reconciliation mechanism (`601031_Overview.md` §3/§6 (a)).
- Designing or implementing a fix for `price_list_assignments` or any object from the unrelated `601130` workpacket.
- Any Flutter/`catchmenu_app` change.

## §5 Forbidden scope

- `confirm_payment()`(POS, `0098`) integration — Open Item (b), separate future workpacket.
- `resolve_payment_uncertain()`'s missing `payment_ledger` INSERT — Open Item (c), separate future workpacket, different remediation class.
- Webhook idempotency/resend handling at the `confirm_payment_from_provider()` level — Open Item (e), **High priority**, but explicitly not designed or implemented by this contract.
- `bulk_commit_kds_tickets()` UI/Flutter caller investigation — Open Item (d), SQL-layer-only workpacket, out of scope.
- Domain number-space reorganization for `600500_payment_confirmation/` — Open Item (f), Human decision needed, out of scope.

## §6 Stop Conditions

Stop immediately and report if any of the following are true:

1. `catchmenu_payment.request_kds_release_after_payment` already exists live immediately before Stage 8 begins (`601033_TestPlan.md` §1.1).
2. Immediately before applying `0166`, the live `confirm_payment_from_provider()` definition no longer matches the original `sql/migrations/0027_create_payment_intent_rpc.sql` body — would mean §2.2's exact insertion point is no longer valid. After `0166` is applied, live mismatch with `0027` is expected because `0166` becomes the sole source for the post-Option-C definition.
3. `catchmenu_kds.bulk_commit_kds_tickets()`'s identity arguments, or its `success:false` / `committed_count`/`pending_count`/`skipped_count` response contract, differ from what `601033_TestPlan.md` §0 live-reconfirmed.
4. `catchmenu_kds.commit_kds_ticket()`'s 7-condition list or its `kds_status` response values (`COMMITTED`/`CAPACITY_CHECKING`) differ from `0028`'s current live behavior.
5. `catchmenu_ledger.audit_records.chk_audit_domain` no longer includes `'payment'`, or `chk_audit_category` no longer includes `'OPERATIONAL'`/`'FINANCIAL'`.
6. `payment_ledger` no longer has `kds_release_authorized`/`kds_release_authorized_at`/`kds_release_authorized_by` columns as §2.1 Step 1 assumes.
7. `0166` (or whatever number is actually used, §0/§1.1) is found to already exist with different content when Stage 8 begins.
8. Any residue of the prior unauthorized implementation attempt (an already-existing `catchmenu_payment.request_kds_release_after_payment` with a body differing from §2.1, or a migration file numbered `0166`/`0167` with content not matching this contract) is found live — do not silently overwrite; stop and report the discrepancy before proceeding.
9. §9's Option C approval checkbox (§2.3) is unchecked or its intent is otherwise ambiguous — Stage 8 must not guess whether Human approved applying the narrow nested `EXCEPTION` wrapper.

## §7 Required verification

Stage 8 must run `601033_TestPlan_Canonical_Kds_Release_Orchestration.md` completely.

Minimum required evidence:

1. All 5 `result_code` branches reproduced with correct `committed_count`/`pending_count`/`skipped_count` semantics (`601033_TestPlan.md` §2): `COMMITTED`/`PARTIAL_CAPACITY_HOLD`/`CAPACITY_HOLD`/`NO_TICKETS_TO_PROCESS` must expose matching integer count fields, while `RELEASE_BLOCKED` must expose `committed_count`/`pending_count`/`skipped_count` as `null` (not `0`) because `bulk_commit_kds_tickets()` returns before the per-ticket aggregation loop.
2. Zero-ticket regression guard confirmed (§2.4) — must not report `PAYMENT_CONFIRMED_KDS_COMMITTED`.
3. Audit record decision mapping confirmed for all 5 branches (§3).
4. Forced-exception path confirmed non-raising, with the pre-existing `payment_ledger` row surviving untouched and the ticket's own transition rolled back (§4).
5. `kds_release_authorized_by` reflects the caller's `p_actor_type`, not a hardcoded value (§5).
6. `confirm_payment_from_provider()`'s `payment_ledger` INSERT block unchanged; end-to-end response's `kds_release_authorized` field correctly derived from `result_code` in both the committed and non-committed cases (§6).
7. **(2026-07-18, Option C)** A simulated call-site exception at `request_kds_release_after_payment()` is caught by the narrow inner block only, does not propagate out of `confirm_payment_from_provider()`, and the earlier `payment_ledger` INSERT in the same invocation survives untouched (`601033_TestPlan.md` §6.4).
8. All boundary files (§7.1-§7.4 of the TestPlan) show 0 diff.

## §8 Open Items (carried from `601031_Overview.md` §6 and `601032_Logic.md` §6, in full — identical (a)-(g) list in all three documents)

(a) `CAPACITY_CHECKING` 재시도 메커니즘 부재 — 별도 워크패킷 필요(가칭 `kds_capacity_retry_scheduler`).

(b) `confirm_payment()`(POS, `0098`)를 동일한 신규 공용 함수로 연결 — 최우선 후속 워크패킷 후보.

(c) `resolve_payment_uncertain()`의 `payment_ledger` INSERT 누락 — 별도 워크패킷 권고, 다른 종류의 수정(신규 원장 행 설계 vs. 기존 함수 배선)이므로 이번 워크패킷과 합치지 않음.

(d) `bulk_commit_kds_tickets()`의 UI/Flutter 호출자 존재 여부 — SQL 레이어 밖, 미확정.

(e) **[High priority — Stage 4에서 격상]** 웹훅 멱등성(재전송) 시나리오 — Cursor+Codex 둘 다 "스코프 제외는 타당하나 실제 운영 위험이 크다"고 지적. `request_kds_release_after_payment()`는 이미 `COMMITTED`된 티켓에 대해 재호출돼도 `bulk_commit_kds_tickets()`가 `HOLD`/`CAPACITY_CHECKING` 상태의 티켓만 대상으로 순회하므로 안전할 것으로 **추정**되나(§2.4의 0-티켓 결과 코드가 정확히 이 경우를 다루도록 이미 설계됨), `confirm_payment_from_provider()` 자체의 상위 레벨 멱등성(동일 웹훅이 `payment_ledger` INSERT 자체를 중복 생성하지 않는지)은 이 워크패킷의 책임 범위가 아니며 별도로 설계돼야 한다.

(f) **[번호 관련]** `600500_payment_confirmation/` 도메인의 백단위 번호 공간 소진 — Human 결정 필요, 이 워크패킷 범위 밖.

(g) `601032_Logic.md` §3의 `pg_temp` 재현 3건은 이 세션(Stage 1.5/설계 단계)이 직접 수행한 것이며, Stage 8/9는 각자 자기 자신의 새 fixture로 독립 재현해 재확인해야 한다 — `601033_TestPlan.md`가 이 재확인을 실행 가능한 SQL로 명시했다(§2/§4).

(h) **[신규, 이 정정 라운드에서 부수적으로 발견 — 이 워크패킷 범위 밖. 2026-07-18 재정정: 파일 수/리터럴 수 혼동 정리]** `p_decision='PENDING'` 결함을 조사하던 중, `catchmenu_audit.append_audit_record()`를 호출하는 다른 여러 기존 라이브 함수들도 `chk_audit_decision`의 11개 허용값에 없는 리터럴을 `p_decision`에 전달하고 있음을 발견했다 — **7개 파일**에서 **8개(타겟 grep 기준 — 이 검색이 전수조사가 아니므로 그 이상일 수 있음)의 잘못된 리터럴**: `sql/migrations/0084_create_reconciliation_advanced_rpc.sql`(`'RESOLVED'`), `0085_create_franchise_os_foundation_rpc.sql`(`'PUBLISHED'`), `0086_create_hq_menu_distribution_rpc.sql`(`'PUBLISHED'`), `0087_create_multistore_policy_rpc.sql`(`'ROLLED_BACK'`), `0091_create_saas_readiness_final_rpc.sql`(`'GO_LIVE_AUTHORIZED'`), `0098_create_payment_confirm_pipeline_rpc.sql`(`'REFUND_PENDING'`), `0100_create_staff_app_bootstrap_rpc.sql`(**같은 파일 안에 `'OPENED'`/`'CLOSED'` 2개** — 이 파일 하나가 리터럴 수를 파일 수보다 1개 더 많게 만든다). 이 호출들이 실제로 실행되면 이번 워크패킷에서 발견한 것과 동일한 방식(`chk_audit_decision` 위반 → INSERT 크래시)으로 실패할 가능성이 높다 — 다만 이 워크패킷은 이 7개 파일 중 어느 것도 건드리지 않으며(§4 Forbidden Operations), 이 발견은 별도의 독립적인 감사(가칭 `audit_decision_literal_repair`) 워크패킷 후보로만 기록한다. 실제로 이 경로들이 라이브에서 호출되는지, 호출된다면 언제부터 깨져 있었는지는 확인되지 않았다 — Human 판단 필요.

## §9 Human Approval

Human must check all boxes before Stage 8 implementation. **자기승인 절대 불가 — 이 문서를 작성한 세션/에이전트는 이 섹션을 체크할 수 없다. 실제 정영석님이 직접 체크해야 한다.**

☑ I approve creating `catchmenu_payment.request_kds_release_after_payment()` exactly as
  specified in §2.1 — including that it never raises, always returns `success:true`, and
  reuses `bulk_commit_kds_tickets()`/`commit_kds_ticket()` unmodified.

☑ I approve modifying `catchmenu_payment.confirm_payment_from_provider()`(`0027`) exactly as
  specified in §2.2 — the `payment_ledger` INSERT itself is unchanged, and the response's
  `kds_release_authorized` field is derived from `result_code` (true only when
  `PAYMENT_CONFIRMED_KDS_COMMITTED`), diverging by design from the underlying DB column
  (which is always `true` after this call).

§2.3's narrow nested `EXCEPTION` block (Option C) — **더 이상 양자택일이 아니라 단일 설계에 대한 예/아니오 승인이다**:

☑ **옵션 C 적용 승인**: `request_kds_release_after_payment()` 호출 지점만 좁게 감싸는 중첩
  `begin...exception when others...end;` 블록을 §2.2/§2.3대로 적용한다 — payment-core 구간
  (intent 검증 ~ `payment_ledger` INSERT ~ 이 함수 자신의 감사기록)은 감싸지 않고 그대로
  두어, 그 구간의 실패는 여전히 진짜 결제 실패로 자연 전파됨을 이해했다. 이 좁은 블록이
  예외를 잡는 경우(정상적으로는 도달 불가능해야 함) `success:true`를 유지하며 `result_code
  := 'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED'`로 통일해서 반환함을 이해했다.

☑ I approve that `confirm_payment()`(POS, `0098`), `resolve_payment_uncertain()`, and the
  webhook idempotency question (Open Item (e), High priority) remain explicitly out of scope
  for this contract, to be addressed in separate future workpackets.

☑ I approve the migration number `0166` (or Stage 8's re-confirmed next-available number) and
  confirm no residue of any prior unauthorized implementation attempt is being reused.

(승인날짜: 2026-07-18)

## §10 Approval state

**APPROVED (2026-07-18).** Stage 8 may begin because every box in §9 is checked by the Human owner (정영석) with a recorded date.

## §11 Final Audit (Stage 11, Claude)

**Verdict: ACCEPT (2026-07-18)**

핵심 주장 재도출 확인 (Stage 9 산출물을 액면 그대로 신뢰하지 않고, raw 검증 결과에서 직접 재도출 - §13.6 앵커링 방지 원칙 적용):

- 신규 함수 request_kds_release_after_payment()의 5단계 result_code(COMMITTED/PARTIAL_CAPACITY_HOLD/CAPACITY_HOLD/NO_TICKETS_TO_PROCESS/RELEASE_BLOCKED) - Cursor+Claude Code 독립 재현 완전 일치, 서로 다른 fixture(Cursor: 경계/극단 케이스, Claude Code: Pass 1 순차 + Pass 2 실제 용량초과/중복웹훅/대량처리)로 검증방법 독립성(§38.4) 원칙 실전 적용.
- audit_decision='SUSPENDED' 정정 - 크래시 없이 정상 작동 3자 확인.
- 오늘 발견된 결정적 설계 결함(kds_release_authorized 하드코딩)의 회귀테스트(§6.2/§6.3) - COMMITTED일 때만 true임을 3자 모두 확인.
- 옵션C(KDS 호출만 좁게 감싼 중첩 예외블록) - PL/pgSQL 세이브포인트 메커니즘으로 규명된 원리가 실제 함수 체인에서도 정확히 작동함을 3자 확인.
- 0027/0166 관계 - 순수추가 방식(0027 미변경, 0166이 최신정의 유일 출처)으로 최종 확정. Cursor의 초기 드리프트 우려는 Claude Code의 설계 의도 설명으로 해소됨.
- boundary - 12개 파일(9+3, Claude Code가 "7개"라는 이전 서술의 오류를 정확히 잡아 정정) 전부 0 diff.

Boundary 확인: 3자 일치.

**Open Items (다음 워크패킷 후보로 이월):**

1. **[신규 실증, High priority 유지]** 웹훅 멱등성(Open Item e) - Claude Code Pass 2가 실제 중복호출로 payment_ledger 중복행 생성을 실증. 이미 High priority였으나 구체적 증거로 보강됨.
2. CAPACITY_CHECKING 재시도 메커니즘 부재(a) - 여전히 미해결.
3. confirm_payment()(POS, 0098) 동일 함수 연결(b) - 최우선 후속 워크패킷 후보.
4. resolve_payment_uncertain()의 payment_ledger INSERT 누락(c) - 별도 워크패킷.
5. bulk_commit_kds_tickets() UI/Flutter 호출자 미확정(d).
6. 600500 도메인 번호공간 소진(f) - Human 결정 필요.
7. audit_decision 리터럴 오류 7개 파일(h) - 별도 감사 워크패킷 후보(audit_decision_literal_repair).
8. 601033 TestPlan §4의 CHECK 제약 기법 - live에 기존 all_conditions_met 행이 있으면 일반 ADD CONSTRAINT가 실패할 수 있음(Cursor 발견) - NOT VALID 옵션 사용 권장, TestPlan 문서 보완 필요.

## §12 Human Merge/Release

담당: Human (정영석님) — 승인 대기 중, Stage 8 착수 전 §9 전체 체크 필요.
