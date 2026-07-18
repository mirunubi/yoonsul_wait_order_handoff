# 600674_ChangeContract_Record_Waiting_Call_Grant_Correction.md

Status: Draft
Lifecycle: ChangeContract
Stage: 5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`record_waiting_call_grant_correction`

## Authority

- `600671_Overview_Record_Waiting_Call_Grant_Correction.md`
- `600672_Logic_Record_Waiting_Call_Grant_Correction.md`
- `600673_TestPlan_Record_Waiting_Call_Grant_Correction.md`

## §0 Contract summary

This ChangeContract authorizes adding `REVOKE`/`GRANT` statements — and only those statements — for exactly two existing functions in `sql/migrations/0160_call_waiting_customer_contract_recovery.sql`: `catchmenu_pos._record_waiting_call(...)` and `catchmenu_pos.call_next_waiting_customer(...)`. Neither function's body is modified; neither is re-declared (`CREATE OR REPLACE`) at all — the new migration is pure ACL correction on already-existing live objects.

`_record_waiting_call()` gets `REVOKE ALL ... FROM PUBLIC` only (no `GRANT` to any role) — it is called exclusively from within the other two functions via `SECURITY DEFINER`, never directly by a client (`600671_Overview.md` §1.1/§5.1, the `0163`/`_resolve_dining_table_by_number()` precedent). `call_next_waiting_customer()` gets `REVOKE ALL ... FROM PUBLIC` followed by `GRANT EXECUTE ... TO authenticated` — it is a public entry point (Human decision Q1, `600642_Logic.md` §1.1/§2), and this combination follows `0050:714-719`'s precedent for its own predecessor function `call_next_waiting()`.

`call_waiting_customer()` is deliberately **not** touched by this contract — it has its own separate, already-documented gap (`authenticated` GRANT present, `PUBLIC` never revoked, `600671_Overview.md` §4/§7 (e)) that is out of scope here and carried forward as an Open Item for a future hardening workpacket.

**Numbering note**: `sql/migrations/` currently tops out at `0166`; `0167` is available for this workpacket — Stage 8 must re-confirm this immediately before creating the file, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §14.5 (Migration Draft Mutability Rule) and the project's standing numbering discipline.

## §1 Allowed files and objects

### §1.1 Allowed new SQL file

- One new migration, tentatively `sql/migrations/0167_record_waiting_call_grant_correction.sql` (Stage 8 must re-run the next-available-number check per §0 before creating it).

### §1.2 Allowed objects (ACL only — no `CREATE`/`CREATE OR REPLACE`)

- `REVOKE ALL ON FUNCTION catchmenu_pos._record_waiting_call(uuid, uuid, uuid, text, int, text, text, uuid, boolean, int, text, timestamptz, text, uuid, text, text) FROM PUBLIC` — exactly as specified in `600672_Logic.md` §1.2, live-reconfirmed at Stage 5 (`600673_TestPlan.md` §2).
- `REVOKE ALL ON FUNCTION catchmenu_pos.call_next_waiting_customer(uuid, uuid, uuid, text, text) FROM PUBLIC` followed by `GRANT EXECUTE ON FUNCTION catchmenu_pos.call_next_waiting_customer(uuid, uuid, uuid, text, text) TO authenticated` — exactly as specified in `600672_Logic.md` §2.1, live-reconfirmed at Stage 5 (`600673_TestPlan.md` §3).

No existing migration file may be modified. `0160_call_waiting_customer_contract_recovery.sql` is not edited — the target functions already exist live with the signatures above; this contract only changes their ACLs.

### §1.3 Changelog

`sql/migrations/CHANGELOG.md` may be appended only if the project migration convention requires recording the new migration. No existing entry may be rewritten.

## §2 Required implementation contract

### §2.1 `catchmenu_pos._record_waiting_call(...)` — REVOKE-only

```sql
revoke all on function catchmenu_pos._record_waiting_call(
  uuid, uuid, uuid, text, int, text, text, uuid,
  boolean, int, text, timestamptz, text, uuid, text, text
) from public;
```

No `GRANT` statement of any kind for this function is authorized. Required invariant: after this statement runs, `has_function_privilege('anon', ..., 'execute')` and `has_function_privilege('authenticated', ..., 'execute')` must both return `false` (`600673_TestPlan.md` §2).

### §2.2 `catchmenu_pos.call_next_waiting_customer(...)` — REVOKE + GRANT authenticated

```sql
revoke all on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) from public;

grant execute on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) to authenticated;
```

Required invariant: after these statements run, `has_function_privilege('anon', ..., 'execute')` must return `false` and `has_function_privilege('authenticated', ..., 'execute')` must return `true` (`600673_TestPlan.md` §3).

### §2.3 Functional continuity requirement

Both `catchmenu_pos.call_waiting_customer(...)` and `catchmenu_pos.call_next_waiting_customer(...)` must continue to complete successfully end-to-end after §2.1/§2.2 apply — the `SECURITY DEFINER` internal call to `_record_waiting_call()` is unaffected by the direct-caller REVOKE (`600673_TestPlan.md` §4, live-reconfirmed at Stage 5 with real fixture data).

## §3 Allowed Operations (narrow verbs)

Per `000701_Guide_Controlled_AI_Development_Pipeline.md` §9.14's Operation Granularity Rule.

**New file `sql/migrations/0167_record_waiting_call_grant_correction.sql`** (number to be reconfirmed, §0/§1.1):

1. Create the file with a header identifying its purpose, `Depends on: 0166_canonical_kds_release_orchestration.sql` (sequential-numbering convention only, no functional dependency).
2. `REVOKE ALL ON FUNCTION catchmenu_pos._record_waiting_call(...)` exactly as specified in §2.1. No other statement referencing this function.
3. `REVOKE ALL ON FUNCTION catchmenu_pos.call_next_waiting_customer(...)` exactly as specified in §2.2.
4. `GRANT EXECUTE ON FUNCTION catchmenu_pos.call_next_waiting_customer(...) TO authenticated` exactly as specified in §2.2. No other GRANT, and no GRANT of any kind for step 2's function.

No operation is authorized on any other file, including `0160` itself.

## §4 Forbidden Operations

- Modifying `catchmenu_pos.call_waiting_customer(...)` in any way — no ACL change, no body change, no re-declaration. This function's own gap is an explicit, separate Open Item (§8 (e)), not part of this contract.
- Modifying `catchmenu_pos._record_waiting_call(...)`'s or `catchmenu_pos.call_next_waiting_customer(...)`'s function **bodies** — this contract is ACL-only. Any `CREATE OR REPLACE FUNCTION` for either is forbidden.
- Editing `sql/migrations/0160_call_waiting_customer_contract_recovery.sql` in any way (including adding the new `REVOKE`/`GRANT` statements in-place — they belong in the new migration only, per `600672_Logic.md` §4's Operation Granularity reasoning).
- Editing `sql/migrations/0110_create_store_admin_rpc.sql` or any `upsert_menu_core()`/`sync_menu_option_*_core()`-family object — explicitly out of scope, `601140`'s prior decision not to add ACL correction there is not reversed here (`600671_Overview.md` §2/§7 (a)).
- Editing `sql/migrations/0050_create_waiting_queue_rpc.sql`, `sql/migrations/0115_create_waiting_pipeline_rpc.sql`, or `sql/migrations/0163_seat_waiting_customer_facade_correction.sql` — cited only as design precedents, never modified.
- Any `GRANT` to `public` for either target function.
- Any schema change (new column, new table, new CHECK constraint) — this workpacket is ACL-only.
- Any Flutter/`catchmenu_app` change.

## §5 Forbidden scope

- `call_waiting_customer()`'s own `PUBLIC` EXECUTE gap — Open Item (e), separate future hardening workpacket, not designed or implemented here.
- `upsert_menu_core()`/`sync_menu_option_*_core()` ACL correction — Open Item (a), separate future workpacket (`menu_core_grant_correction`), not designed or implemented here.
- `call_next_waiting_customer()`'s orphan-caller status (0 real callers) — Open Item (c), not addressed; granting `authenticated` execute does not itself wire any caller.
- `call_next_waiting_customer()`'s final name confirmation (still "(가칭)") — Open Item (d), not addressed.

## §6 Stop Conditions

Stop immediately and report if any of the following are true:

1. `catchmenu_pos._record_waiting_call(...)`'s live identity arguments no longer match the 16-parameter signature in §1.2/§2.1 (a drift since this contract was drafted).
2. `catchmenu_pos.call_next_waiting_customer(...)`'s live identity arguments no longer match the 5-parameter signature in §1.2/§2.2.
3. `catchmenu_pos.call_waiting_customer(...)`'s live `proacl` no longer shows both `authenticated` GRANT and `PUBLIC` EXECUTE present (i.e., someone already partially fixed it since this contract was drafted) — would mean Open Item (e)'s premise has changed and must be reported, not silently absorbed.
4. Either target function already shows an existing explicit `GRANT`/`REVOKE` in its live `proacl` (i.e., `proacl` is not actually `NULL` for both, contradicting `600671_Overview.md` §7 (b)'s live-reconfirmed finding).
5. `0167` (or whatever number is actually used, §0/§1.1) is found to already exist with different content when Stage 8 begins.
6. The functional continuity check (§2.3/`600673_TestPlan.md` §4) fails — either public function stops working end-to-end after the REVOKE/GRANT is applied.

## §7 Required verification

Stage 8 must run `600673_TestPlan_Record_Waiting_Call_Grant_Correction.md` completely.

Minimum required evidence:

1. `_record_waiting_call()` loses EXECUTE for both `anon` and `authenticated` (§2).
2. `call_next_waiting_customer()` loses EXECUTE for `anon`, retains it for `authenticated` (§3).
3. `call_waiting_customer()`'s privilege state is unchanged before/after (§5).
4. Both public functions complete successfully end-to-end after the change (§4).
5. `0160`, `0050`, `0110`, `0115`, `0163`, `0166`, and `catchmenu_app` all show 0 diff (§6.1/§6.2/§6.3).

## §8 Open Items (carried from `600671_Overview.md` §7 / `600672_Logic.md` §6, in full — identical (a)-(e) list in all three documents)

(a) `upsert_menu_core()`/`sync_menu_option_*_core()`(`0110`)의 `proacl` NULL 갭 — `upsert_menu_core()` 자체(파라미터 기본값)는 `601140`이 이미 수정했다. 범위 밖으로 남은 것은 오직 그 함수의 ACL(REVOKE/GRANT) 교정뿐이다. 별도 워크패킷 후보(가칭 `menu_core_grant_correction`), 이번 워크패킷 범위 밖.

(b) **[해소, 2026-07-18]** 라이브 `pg_proc.proacl` 직접 재확인 — Cursor+Codex가 라이브로 확인 완료: `_record_waiting_call()`/`call_next_waiting_customer()` 둘 다 `proacl` NULL, `call_waiting_customer()`는 `authenticated=X/postgres`(GRANT)와 `=X/postgres`(PUBLIC EXECUTE 잔존)가 동시에 존재. 이 세션도 Docker 재연결 후 동일 쿼리로 독립 재확인해 일치를 확인했다(`600671_Overview.md` §7 (b) 상세). Stage 5 TestPlan(§1.1)에서 다시 한번 재확인됨.

(c) `call_next_waiting_customer()`의 실호출자 0건(고아 함수) — GRANT 부여 후에도 배선 전까지는 도달 불가능한 상태로 남는다. 배선 여부는 별도 판단 필요.

(d) `call_next_waiting_customer()`의 "(가칭)" 명칭 미확정 — 이번 워크패킷은 다루지 않는다.

(e) `call_waiting_customer()`의 `PUBLIC` EXECUTE 권한이 한 번도 REVOKE된 적 없다 — `authenticated` GRANT와 별개의 보안 공백. `0115` 작성 당시의 레거시 관행(같은 grants 블록의 다른 8개 함수도 동일 패턴)에 가까운 문제로 판단해 이번 워크패킷 범위에서 명시적으로 분리했다 — 별도 hardening 워크패킷 후보로 기록.

## §9 Human Approval

Human must check all boxes before Stage 8 implementation. **자기승인 절대 불가 — 이 문서를 작성한 세션/에이전트는 이 섹션을 체크할 수 없다. 실제 정영석님이 직접 체크해야 한다.**

☑ I approve `catchmenu_pos._record_waiting_call(...)` receiving `REVOKE ALL FROM PUBLIC`
  only, with no `GRANT` to any role — matching the `0163`/`_resolve_dining_table_by_number()`
  precedent, since this function is called exclusively via internal `SECURITY DEFINER`
  invocation and never directly by a client.

☑ I approve `catchmenu_pos.call_next_waiting_customer(...)` receiving `REVOKE ALL FROM
  PUBLIC` followed by `GRANT EXECUTE TO authenticated` — matching the `0050:714-719`
  precedent for its own predecessor `call_next_waiting()`.

☑ I approve that `catchmenu_pos.call_waiting_customer(...)` is explicitly **not** touched
  by this contract — its own `PUBLIC` EXECUTE gap (Open Item (e)) remains unresolved and
  is deferred to a separate future hardening workpacket.

☑ I approve that `upsert_menu_core()`/`sync_menu_option_*_core()` (Open Item (a)),
  `call_next_waiting_customer()`'s orphan-caller status (Open Item (c)), and its
  unconfirmed final name (Open Item (d)) remain explicitly out of scope for this contract.

☑ I approve the migration number `0167` (or Stage 8's re-confirmed next-available number).

(승인날짜: 2026-07-18)

## §10 Approval state

**APPROVED (2026-07-18).** All five boxes in §9 were checked by the Human owner (정영석) with the approval date recorded. Stage 8 implementation is authorized within this ChangeContract's exact Allowed/Forbidden boundary.

## §11 Final Audit (Stage 11, Claude)

**Implementation Verdict: ACCEPT (2026-07-18)**
**System Security Verdict: ACCEPT_WITH_HIGH_PRIORITY_OPEN_ITEM**

이 ACCEPT는 승인된 함수 실행 권한(ACL) 교정만을 인증한다.
tenant/store 직원 인가(authorization) 문제를 해결하거나
안전하다고 인증하는 것이 아니다.

0167이 승인된 ACL 변경을 정확히 구현했음을 확인한다:
- _record_waiting_call()은 더 이상 PUBLIC이 실행할 수 없다.
- call_next_waiting_customer()는 authenticated는 실행 가능,
  anon은 불가능하다.
- call_waiting_customer()는 승인된 경계대로 무변경이다.

핵심 주장 재도출 확인 (raw 검증 결과에서 직접 재도출):
- ACL 교정이 설계(600671/600672) 그대로 정확히 구현됨 - Cursor+
  Claude Code 독립 재현 완전 일치.
- SECURITY DEFINER 내부호출 원리(0163 선례)가 실제 non-superuser
  authenticated 역할 전환 상태에서 재확인됨.
- call_waiting_customer() 완전 무변경 - proacl::text byte-
  identical 확인.
- boundary - 7개 파일 전부 0 diff.

**Stage 11B(ChatGPT Blind Audit) + 11C(충돌분석) 결론:**
블라인드 역설계와 Claude의 설계/감사는 핵심 사실관계(세 함수의
아키텍처, call_waiting_customer()의 PUBLIC EXECUTE 위험)에서
거의 완전히 일치했다. 유일한 충돌은 판정 범위였다 - Claude는
"승인된 0167 변경이 정확히 구현됐는가"를, ChatGPT는 "세 함수가
구성하는 전체 권한 구조가 안전한가"를 물었다. 두 질문 모두
정당하며, 이번 워크패킷은 전자에 대해서만 답한다.

Cursor의 후속 전수조사(waiting_call_caller_identity_
verification)는 이 문제가 3함수만이 아니라 0115의 6개 mutator
RPC 및 order/payment/admin 도메인 전반에 걸친 구조적 결여임을
확인했다. ChatGPT+제미나이 교차검증 결과, 이번 0167 워크패킷에
이 문제를 섞지 않고 별도 프로그램으로 승격하기로 결정했다.

**Open Items (기존 4개 + 신규 1개, 범위 확장):**

1. upsert_menu_core()/sync_menu_option_*_core() ACL 갭(a) -
   별도 워크패킷(menu_core_grant_correction).
2. call_next_waiting_customer()의 고아 함수 상태(c) - GRANT
   후에도 여전히 실호출자 0건.
3. call_next_waiting_customer()의 "(가칭)" 명칭 미확정(d).
4. call_waiting_customer()의 PUBLIC EXECUTE 잔존(e) - 아래 5번
   프로그램의 파일럿 대상으로 흡수.
5. **[신규, PROGRAM-LEVEL SECURITY FINDING으로 승격]** 호출자-
   tenant/store 소속 인가(authorization) 검증이 이 프로젝트
   전반(waiting 6개 mutator RPC 포함, order/payment/admin
   도메인도 동일 패턴)에 구조적으로 결여됨. 단순 Open Item이
   아니라 별도 프로그램(가칭 caller_authorization_foundation)
   으로 즉시 착수 결정 - waiting 도메인을 첫 파일럿으로 적용
   후 확장.

## §12 Human Merge/Release

담당: Human (정영석님)

상태: READY_FOR_HUMAN_MERGE