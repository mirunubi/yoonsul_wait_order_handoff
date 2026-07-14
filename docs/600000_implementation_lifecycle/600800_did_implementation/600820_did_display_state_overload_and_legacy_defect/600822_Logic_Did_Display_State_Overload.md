# 600822_Logic_Did_Display_State_Overload.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`did_display_state_overload_and_legacy_defect`

## §1 `0043` nested aggregate 결함 — 정확한 원인 (재확인, `600821_Overview.md` §3과 동일 근거)

`0043`의 "cooking summary by kitchen zone" 블록(L126-150)에서 집계 함수 `jsonb_object_agg(...)`의 인자 안에 또 다른 집계 함수 `count(*) filter (...)`를 직접 중첩했다 — PostgreSQL이 파싱 단계에서 거부하는 패턴(`ERROR: aggregate function calls cannot be nested`). 이번 턴 named-argument로 `0043` 오버로드만 강제 지정해 직접 재현 완료(`600821_Overview.md` §3). 표준적인 수정 방향은 `count(*) filter(...)`들을 서브쿼리로 먼저 집계한 뒤 바깥에서 `jsonb_object_agg`로 감싸는 것이지만, **§2의 확정에 따라 이 버그는 수정하지 않는다** — `0043` 자체를 DROP하므로 이 결함을 고칠 실익이 없다.

## §2 확정 — Option A: `0043` DROP, `0117`을 단일 canonical 함수로 확정 (Human 결정 2026-07-14, 재논의 금지)

**확정된 방향**은 `confirm_payment_from_provider()` overload 정리 결정과 동일한 논리다. 근거(3중 증거, `600821_Overview.md` §3-§5에서 확인된 사실 그대로):

1. 차별화 파라미터(`p_device_id`) 자체가 함수 본문에서 미사용 — 디바이스 스코핑이 애초에 구현된 적이 없다.
2. nested aggregate 문법 오류로 **독립적으로도** 100% 크래시(§1, 실증 완료) — 모호성 문제와 별개로 그 자체로 이미 죽은 코드다.
3. 라이브 호출자 0건.

세 증거가 동시에 성립하므로, `0043`을 유지해서 얻는 실질적 이득이 없다 — `confirm_payment_from_provider()` 사례와 마찬가지로 "잃을 기능이 없다."

### §2.1 실행 계획 (Stage 4 대상, 이번 턴 미실행)

```sql
drop function if exists catchmenu_store.get_did_display_state(
  uuid, uuid, uuid
);
```

**장점**: 모호성 즉시 해소, 크래시하는 죽은 코드 제거, 변경 범위 최소(`DROP FUNCTION` 한 문장).
**참고 사실**(단점이 아님, 확정에 영향 없음): `0043`이 반환하던 "매장 전체 대기/조리 현황 집계" 조합(대기 세션+호출된 세션+픽업 준비 주문+주방 구역별 조리 현황)은 현재 다른 어떤 함수에서도 정확히 같은 조합으로 제공되지 않는다. 그러나 이는 DROP을 보류할 이유가 아니다 — §2.2 참고.

### §2.2 기각됨 — Option B: `0043`을 별도 이름으로 재설계해 유지

**제안 내용**: `0043`이 담으려던 매장 전체 운영 현황 집계 개념이 미래에 필요해질 경우를 대비해, 지금 `0043`을 고쳐서 살리거나 별도 함수(`get_store_operational_summary()` 등)로 재설계.

**기각 근거(Human 결정)**: 지금 깨진 `0043`을 고쳐 살리는 방식이 아니라, **실제 요구가 확정되면 그때 새 이름으로 제대로 재설계한다**(YAGNI) — `600511_Overview.md`/`600512_Logic.md`에서 `confirm_payment_from_provider()`에 `p_locale`/`p_options jsonb`를 미리 만들어두지 않기로 한 결정과 정확히 같은 원칙이다. 지금 미리 만들어두는 것은 (a) 요구가 실재하는지 확인되지 않았고(§2.1 "참고 사실" — 다른 함수와의 중복 여부조차 전수 대조되지 않음), (b) 지금 살리려면 버그 수정+파라미터 재설계+함수명 분리까지 필요해 이번 workpacket의 원래 범위(오버로드 정리)를 크게 초과하며, (c) 나중에 진짜 요구가 생겼을 때 지금 만든 설계가 그 요구와 맞지 않을 위험이 있다. Option B는 최종적으로 기각한다.

### §2.3 판단 근거 요약 (확정 기록용)

| 질문 | 확인된 사실 |
|---|---|
| 크래시하는 코드를 고칠 가치가 있는가 | 호출자 0건 — 고쳐도 아무도 안 씀. 고치지 않는다. |
| "매장 전체 운영 현황 집계"가 다른 곳에 이미 있는가 | 미확인 — 확정에 영향 없음(§3 Open Item으로 이월, DROP 여부와 무관하게 별도로 조사 가능) |
| `get_did_display_state`라는 이름을 두 개념이 공유해도 되는가 | 공유해서는 안 된다는 것이 이번 모호성의 근본 원인 — `0043` DROP으로 이름 충돌 자체를 제거 |

## §3 Open Items

(a) (참고용, DROP 결정과 무관 — Option B가 기각되어 선행 조건이 아니게 됨) `get_kds_realtime_state()`(`0099`)/`get_waiting_realtime_state()`(`0099`)가 `0043`이 반환하려던 것과 얼마나 겹치는지 전수 대조되지 않았다. 매장 전체 운영 현황 집계에 대한 실제 요구가 미래에 확정되면, 그 시점에 이 대조부터 시작해 새 이름으로 재설계한다(§2.2).

(b) (역사적 참고, 확정에 영향 없음) `0043`의 `p_device_id` 미사용이 설계 누락인지 의도적이었는지는 이번 조사로 확인 불가 — 원 설계자 의도 불명. `0043`이 DROP되므로 더 이상 조사할 실익이 없다.

(c) `mark_no_show()`/`get_did_display_state()` 오버로드 확산이라는 더 큰 패턴(confirm_payment provider / customer handoff 계열에서 이미 발견)의 일부다 — 이 workpacket은 `get_did_display_state()`만 처리하며, `mark_no_show()`는 별도 workpacket 대상으로 남는다.

## §4 검증 계획 (Stage 5 대상)

- `DROP FUNCTION` 이후 라이브 오버로드 수 재확인: `select count(*) from pg_proc where proname='get_did_display_state' and pronamespace='catchmenu_store'::regnamespace;` → `1` 기대.
- `bootstrap_did_app()` 재호출로 `p_did_id`/`p_locale` named-argument 경로가 정상 작동하는지 재확인(§2.1의 DROP이 이 경로에 영향 없음을 이미 확인했으나, 실제 DROP 이후 재확인).
- positional 3-arg 호출(`600821_Overview.md` §2)이 더 이상 모호하지 않고 단일 오버로드(4-param)로 자연스럽게 매치되거나, 인자 수 불일치로 명확한 에러를 내는지 확인.
- 상세 시나리오는 `600823_TestPlan_...md`(Stage 2)에서 작성.

## Snapshot Decision

**확정.** §2의 Human 결정에 따라 Option 논의는 종료되었다 — `0043`(3-param) DROP, `0117`(4-param)을 canonical로 유지. 이 스냅샷으로 Stage 2(TestPlan/ChangeContract) 진행 가능. `.sql` 파일은 이번 턴에서도 생성·수정하지 않았음.
