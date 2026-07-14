# 600532_Logic_Mark_Payment_Uncertain_Overload.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`mark_payment_uncertain_overload_ambiguity`

## §0 전제 — `600482_Logic.md`의 예측과 실제 재검증 결과의 차이

`600482_Logic.md` §5는 "`mark_payment_uncertain()`은 confirm_payment_from_provider와 같은 패턴이므로 동일한 '9-param(6-param) 오버로드 DROP' 해법을 그대로 적용할 수 있을 것"이라고 예상했다. `600531_Overview.md`의 재검증 결과, **파라미터 시그니처 패턴은 예상대로 동일**했지만 **함수 본문의 실질적 동작은 예상과 달리 갈라져 있다** — `0027`/`0063` 어느 쪽도 confirm_payment_from_provider의 `0027`(완전히 정확함)/`0063`(4곳에서 크래시, 버릴 게 명백함)만큼 깔끔한 비대칭이 아니다. 아래 §1-§6은 이 재검증 결과를 반영한 옵션 비교이며, §0.5에서 Human이 최종 결정한다.

## §0.5 Human 최종 결정 (2026-07-14, confirm_payment_from_provider와 동일 논리, 재논의 금지)

**확정된 방향**: `0063`(6-param) DROP, `0027`(5-param)을 단일 canonical 함수로 확정 — 이 문서의 원 **Option A**(§2)와 내용상 동일.

**Human이 제시한 근거(안티+Codex 삼중 검증) — 이번 턴 직접 재검증**:

| # | 근거 | 재검증 방법 | 결과 |
|---|---|---|---|
| 1 | `0063`이 독립적으로도 `chk_intent_status` 위반으로 100% 크래시 | `pg_get_constraintdef`로 라이브 제약 재조회 | **재확인**(이미 `600531_Overview.md` §1.1에서 확인된 사실과 동일 — 신규 재확인 아님, 기존 확인의 반복) |
| 2 | Codex가 추가 발견한 `exceptions.exception_code` NOT NULL 누락(2중 결함) | `\d catchmenu_ledger.exceptions`로 라이브 스키마 재조회(`exception_code text not null`, 기본값 없음) + `0063` L649-661 INSERT 컬럼 목록 재확인 | **신규 독립 검증, 확인됨** — `0063`의 `insert into catchmenu_ledger.exceptions (...)` 컬럼 목록에 `exception_code`가 **없다**. `chk_intent_status` 크래시(첫 번째 쓰기 문장)를 우회해도, 그 다음 쓰기 문장인 이 INSERT에서 `NOT NULL` 위반으로 다시 크래시한다 — Codex 주장 그대로, 이번 턴 처음으로 직접 검증됨(이전 `600531`/`600532` 초안 작성 시점엔 발견하지 못했던 사실). |
| 3 | `p_locale` 다국어 요구 없음 | `600531_Overview.md` §2가 Open Question으로 남겼던 항목 — 실제 호출자 0건(§4 근거와 동일 사실)이라는 점에서, "노출될 화면이 아예 없다"는 근거로 이 Open Question을 닫는 것으로 해석 | Human 결정으로 해소(경험적으로 재검증 가능한 사실이 아니라 제품 판단 — §2/§3 근거와 사실상 같은 근거의 다른 표현으로 수용) |
| 4 | 실제 호출부 0건 | 저장소 전체(`sql/migrations` + `*.dart`/`*.ts`/`*.js`/`*.py`) 재검색 | **재확인**(`600531_Overview.md` §0.1에서 이미 확인된 사실과 동일) |
| 5 | 화면 노출 경로 없음 | 4와 동일 근거(호출자 0건 → 소비하는 화면도 0건) | 4에 종속된 결론, 별도 재검증 불필요 |

**결론**: 5개 근거 중 1/4/5는 이번 워크패킷의 기존 조사(§1.1, §0.1)에서 이미 확인된 사실의 재확인이고, 2는 이번 턴 신규로 독립 검증되어 확인된 새 사실이며, 3은 경험적 재검증 대상이 아닌 Human의 제품 판단으로 수용한다. §6(권고, 하단)이 제기했던 우려("`0027`을 그대로 두면 `0027` 자체의 기존 결함이 남는다")는 해소되지 않았고 **Open Item으로 명시적으로 carry-forward**한다(§7) — 근거 5개가 "`0063`을 버려도 안전하다"는 판단을 강하게 뒷받침하는 것과, "`0027`이 완전무결하다"는 것은 별개이기 때문이다.

## §1 비교표 — 두 오버로드 모두 각자 다른 결함을 가짐

| | `0027`(5-param) | `0063`(6-param) |
|---|---|---|
| 모호성 해소 후 생존 가능성(정적) | 가능(제약 위반 없음) | **`intent_status='UNCERTAIN'` 문장에서 크래시**(`chk_intent_status`에 `'UNCERTAIN'` 없음, `600531` §1.1) |
| `order_sessions.session_status` 갱신 | 함 | 안 함(누락) |
| `payment_intents.intent_status` 값의 의미론적 정확성 | **틀림**(`'PROCESSING'` — `0070` 대시보드가 찾는 `'UNCERTAIN'`이 아님) | 맞음(단, 크래시 때문에 도달 불가) |
| i18n 응답(`build_error_response`/`build_success_response`) | 없음(raw jsonb) | 있음 |
| `log_diagnostic()` CRITICAL 로그 | 없음 | 있음 |
| KDS 릴리즈 차단(특허1 핵심 안전장치, `exceptions` 테이블 기반) | 안전(양쪽 다 exceptions row 생성) | 안전(크래시 이전엔 도달 못하지만, 크래시 자체가 안전 방향 실패) |

## §2 확정 — Option A: `0063` DROP, `0027` 그대로 유지 (Human 결정 2026-07-14, §0.5)

```sql
drop function if exists catchmenu_payment.mark_payment_uncertain(
  uuid, uuid, uuid, text, text, text
);
```

### §2.1 실행 계획 (Stage 4 대상, 이번 턴 미실행)

동일한 `DROP FUNCTION` 문 1개. `600482_Logic.md` §1.1과 동일 패턴 — `.sql` 파일은 이번 턴에도 수정하지 않았다.

### §2.2 검증 계획 (Stage 5 대상)

- `DROP FUNCTION` 이후 라이브 오버로드 수 재확인: `select count(*) from pg_proc where proname='mark_payment_uncertain' and pronamespace='catchmenu_payment'::regnamespace;` → `1` 기대.
- 정상 호출(5-param, named 또는 positional) 시 더 이상 `"is not unique"` 에러가 발생하지 않음을 확인.
- 상세 시나리오는 `600533_TestPlan.md`에서 작성.

**채택 근거**(§0.5 표 참고):
- `600480`과 동일한 최소 변경 패턴 — `DROP FUNCTION` 한 문장.
- 크래시 위험이 있는 `0063`을 제거하므로 안전 방향 — 게다가 `0063`은 §0.5에서 확인된 대로 **2중 결함**(첫 크래시를 우회해도 `exceptions.exception_code` NOT NULL 위반으로 재크래시)이라, confirm_payment_from_provider의 9-param 오버로드(4개 결함)만큼은 아니어도 "버려도 실질적 손실 없음" 근거가 이전 초안(§6)에서 판단했던 것보다 더 강해졌다.
- KDS 릴리즈 차단(특허1)은 `exceptions` 테이블 기반이라 이 옵션으로도 계속 안전(`600531` §1.2).
- `p_locale`/화면 노출 경로 없음(§0.5 근거 3/5) — `0027`의 i18n/진단로그 결손을 지금 메울 필요가 없다는 뜻이기도 하다(화면이 없으므로).

**남는 결손(단점이 아니라 Open Item, §7에서 carry-forward)**:
- `0027`의 기존 결함(`intent_status='PROCESSING'`, `0070` 대시보드가 영구히 감지 못함)이 그대로 남는다.
- `0027`은 i18n 응답도, CRITICAL 진단 로그도 만들지 않는다 — 향후 이 함수가 실제로 연결될 때(§3 Open Question, 원 문서 기준 — 현 `600531_Overview.md` §3) 그 결손을 다시 별도 작업으로 메워야 한다.

## §3 기각됨 — Option B: `0063` DROP + `0027`에 `intent_status` 값만 최소 수정

Option A와 동일하게 `0063`을 DROP하되, `0027`의 `update payment_intents set intent_status = 'PROCESSING'`을 `intent_status = 'UNCERTAIN'`으로 바꾸기 위해 **먼저 `chk_intent_status`에 `'UNCERTAIN'`을 추가하는 스키마 마이그레이션이 선행되어야 한다**(현재 제약이 이 값을 막고 있으므로).

**장점**:
- `0070` 대시보드의 조용한 감지 실패를 근본적으로 닫는다.
- 여전히 단일 canonical 함수 유지 원칙(`§0.5`/`600482_Logic.md`)에 부합.

**단점**:
- `600480`의 "DROP 한 문장"보다 범위가 커진다 — CHECK 제약 변경(`ALTER TABLE ... DROP CONSTRAINT ... ADD CONSTRAINT ...`)은 순수 함수 DROP보다 훨씬 신중한 검토가 필요한 스키마 변경이다(기존 행에 영향 없음은 확인 가능하나, 제약 자체를 건드리는 것은 이 프로젝트 전반에서 드문 종류의 변경).
- "유지하는 쪽(`0027`)의 본문을 수정한다"는 점에서, `600480`이 지켰던 "버리는 쪽만 DROP, 남기는 쪽은 손대지 않는다"는 원칙에서 벗어난다.

**기각 근거(Human 결정, §0.5)**: `0027`을 그대로 두는 Option A로 확정됨에 따라 자동 기각. 스키마 제약 변경(`chk_intent_status`)까지 동반하는 이 옵션은 Human이 채택한 "동일 논리(5중 근거로 `0063`은 버려도 안전)"의 범위를 넘어선다.

## §4 기각됨 — Option C: `0027` DROP, `0063` 유지 + 크래시 수정 + `order_sessions` 갱신 보강

`0063`을 canonical로 삼고, ①`chk_intent_status`에 `'UNCERTAIN'` 추가(Option B와 동일 선행 작업), ②`0063` 본문에 `order_sessions.session_status = 'PAYMENT_UNCERTAIN'` UPDATE를 다시 추가.

**장점**:
- i18n 응답 + CRITICAL 진단 로그 + 의미론적으로 정확한 `intent_status` + `order_sessions` 갱신 — 두 오버로드의 장점을 모두 가진 유일한 함수가 남는다.
- `authorize_kds_release()`/`confirm_payment_from_provider()`와 마찬가지로 `0063` 계열(i18n 표준 패턴)로 수렴한다는 점에서 프로젝트 전체의 응답 포맷 일관성에 유리(다만 `confirm_payment_from_provider()`는 반대로 `0027` 계열로 수렴하기로 확정됐다는 점과는 방향이 반대 — §5에서 이 비일관성을 별도로 짚는다).

**단점**:
- 세 옵션 중 범위가 가장 크다 — 제약 변경 + 함수 본문 수정(재작성 수준) + `0027` DROP, 총 3가지 변경이 얽힌다.
- `600480`이 "`p_locale` 자체를 도입하지 않는다"고 확정한 원칙(YAGNI, §2 Open Question — 스태프 노출 여부 미확정)과 정면으로 배치될 수 있다 — `p_locale`을 오히려 canonical 계약에 편입시키는 방향이기 때문.

**기각 근거(Human 결정, §0.5)**: Option A 채택으로 자동 기각. 세 옵션 중 범위가 가장 컸던 만큼, "동일 논리(5중 근거)"로 더 작은 변경(Option A)이 충분하다고 판단된 이상 채택 근거가 없다.

## §5 해결됨 — Option A/B/C와 confirm_payment_from_provider 확정 방향의 일관성 문제

Option C가 기각(§4)됨에 따라, 애초 우려했던 "같은 도메인 폴더 안에서 정반대 방향의 canonical 선택이 공존"하는 상황 자체가 발생하지 않는다 — `confirm_payment_from_provider()`(`600480`)와 `mark_payment_uncertain()`(이 문서) 모두 `0027` 계열(비-`p_locale`)이 canonical로 확정되어, `600500_payment_confirmation` 도메인 안에서 방향이 일관된다.

## §6 원 초안 권고 (참고용, 최종 결정에는 §0.5가 우선함)

*(이번 턴 이전 초안 내용 — 역사적 기록으로 보존, Human 결정(§0.5)이 최종 결정임)*

세 옵션 모두 근거가 있어 단일 권고로 좁히지 않는다. 다만 재검증으로 드러난 사실 관계상:

- **Option A**는 `600480`과 가장 유사한 형태를 유지하지만, `0027` 자체의 기존 결함(대시보드 미감지)을 이번에 알고도 방치하는 선택이 된다 — 이 방치가 §44.2(의심 즉시 해결 원칙, 오늘 신설)의 정신과 어떻게 조화되는지는 Human 판단이 필요하다.
- **Option B**는 결함을 고치되 범위를 최소화하지만, 제약 변경이 필요해 `600480`보다 스테이지 4 실행 리스크가 높다.
- **Option C**는 가장 완전하지만 가장 크고, `p_locale` 필요성이라는 아직 열린 질문(§2)에 대한 답을 전제로 한다.

**"`0027`을 그대로 두고 `0063`만 기계적으로 DROP"(Option A를 배경이 암시한 원안 그대로)은 §1.1에서 확인된 `0027`의 실제 결함을 감안할 때, 예상보다 근거가 약하다** — 이 점이 이번 재검증에서 가장 중요한 정정이었다.

## §7 Open Items Carried Forward (Human 결정 이후에도 남는 항목)

(a) **`0027`의 `intent_status='PROCESSING'` — `0070` 대시보드가 영구히 감지 못함(§1, §2 "남는 결손").** Human 결정은 이 결함을 알고도 지금 고치지 않는 것으로 확정했다(화면 노출 경로 없음, §0.5 근거 5) — 향후 이 함수에 실제 호출부가 생기는 시점에 재검토가 필요하다.

(b) **`0027`의 i18n 응답/CRITICAL 진단 로그 결손.** 마찬가지로 화면 노출 경로가 없어 지금은 문제 없음으로 판단됐으나, 실제 호출부가 생기면 함께 재검토 대상.

(c) **`mark_payment_uncertain()`의 실제 호출 체인이 전혀 구현되어 있지 않음(`600531_Overview.md` §3, 원래 §3 Open Question).** 이 워크패킷의 범위 밖 — 별도 워크패킷 후보.

(d) **`authorize_kds_release()` 오버로드 정리.** `600481_Overview.md` §2에서 이미 "구조적으로 다름"으로 확인, 이 워크패킷/`600480` 어느 쪽에도 포함되지 않음 — 별도 조사 필요.

## Snapshot Decision

**확정.** Option A(`0063` DROP, `0027`을 단일 canonical 함수로 유지) 채택. `600533_TestPlan.md`/`600534_ChangeContract.md`(Stage 2)로 진행 가능. `.sql` 파일은 이번 턴에도 수정하지 않았다.
