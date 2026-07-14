# 600531_Overview_Mark_Payment_Uncertain_Overload.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`mark_payment_uncertain_overload_ambiguity`

## §0 위치/번호 확인

오늘(`600520`) 재편된 도메인 구조 기준, `mark_payment_uncertain()`은 결제 확인 경계(Payment Confirmation)이므로 `600500_payment_confirmation/` 산하에 생성한다. `000005`/`000007` 재확인 결과 `600500` 산하에서 `600480`(6단위 워크패킷 자체 번호 `600481`–`600487` 사용 중) 다음 빈 번호는 `600500`대 자체(Readme/NavigationMap, `600500`/`600502`)를 제외하면 `600503`–`600529`가 비어 있음 — 이번 워크패킷은 그 다음 워크패킷 슬롯인 `600530`을 사용한다(`600481`–`600487` 패턴과 동일하게 자체 7-슬롯 확보: `600531`–`600537`). 파일명은 `000701` §42 규칙대로 번호+타입+제목 전부 포함.

## §0.1 배경 재확인 — "삼중 검증 완료, 재확인 불필요" 전제를 그대로 받아들이지 않음

이번 턴 지시문은 "Cursor+Codex+안티 삼중 검증 완료, 재확인 불필요"라고 명시했으나, `000701` §37/§39/§44.2(Zero Deferred Doubt, 오늘 신설)의 원칙에 따라 이 전제를 그대로 문서에 반영하지 않고 라이브 DB에서 직접 재확인했다. 결과: 배경의 핵심 주장(오버로드 2개 공존, 호출자 0건, named-argument 모호성)은 **정확했다**. 다만 §1 이하에서, 배경이 암시한 "confirm_payment_from_provider(`600480`)와 완전히 동일한 패턴"이라는 전제는 **재검증 결과 부분적으로만 맞고, 중요한 차이점이 새로 발견됐다** — 이 차이점이 이번 문서의 핵심이다.

### 라이브 재확인 (`pg_get_function_identity_arguments`)

```
(5-param, 0027) p_tenant_id, p_store_id, p_intent_id, p_uncertain_reason, p_correlation_id default null
(6-param, 0063) p_tenant_id, p_store_id, p_intent_id, p_uncertain_reason, p_locale default 'ko', p_correlation_id default null
```

### 호출자 재확인

저장소 전체(`sql/migrations/*.sql` + `*.dart`/`*.ts`/`*.js`/`*.py` 전수 검색) 재검색 결과 실제 함수 호출(`perform`/`select`)은 **0건**. `0063` 내 3곳의 매치는 전부 `revoke`/`grant`/`comment on function` — 실행 코드 아님. 배경의 "호출자 0건" 주장과 일치.

### 모호성 재확인 (라이브 재현, BEGIN...ROLLBACK 아님 — 순수 SELECT 호출이라 부작용 없음)

```sql
select catchmenu_payment.mark_payment_uncertain(
  p_tenant_id := gen_random_uuid(), p_store_id := gen_random_uuid(),
  p_intent_id := gen_random_uuid(), p_uncertain_reason := 'test ambiguity'
);
-- ERROR: function catchmenu_payment.mark_payment_uncertain(...) is not unique
```

추가로 확인: **순수 positional 5-인자 호출도 모호하다**(`p_locale`이 default를 가지므로 PostgreSQL이 6-param 오버로드도 후보로 계속 고려함) — 즉 `0027`(5-param)은 named든 positional이든 **어떤 정상적 호출 방식으로도 단독 선택이 불가능**하다. `p_locale`을 명시적으로 넘기는 호출만 유일하게 `0063`(6-param)으로 확정된다.

## §1 핵심 신규 발견 — "단순 p_locale 추가"가 아니라 실질적 동작 분기(behavioral divergence)

배경/`600481_Overview.md` §2는 이 함수를 confirm_payment_from_provider와 "정확히 같은 패턴"(필수 파라미터 순서·이름 동일, `p_locale`만 삽입)으로 평가했다. 이번 턴 두 함수 본문을 라이브 스키마와 직접 대조한 결과, 이는 **부분적으로만 맞다** — 파라미터 시그니처는 동일 패턴이지만, **함수가 실제로 하는 일이 다르다**:

| 항목 | `0027`(5-param) | `0063`(6-param) |
|---|---|---|
| `payment_intents.intent_status` 갱신값 | `'PROCESSING'` | `'UNCERTAIN'` |
| `order_sessions.session_status` 갱신 | **함(`'PAYMENT_UNCERTAIN'`으로 갱신, 특허1 주석 포함)** | **안 함 — 함수 본문에 `order_sessions` 참조 자체가 없음** |
| 응답 생성 방식 | `jsonb_build_object()` 직접 조립 (raw error_key 스타일) | `catchmenu_common.build_error_response()`/`build_success_response()` 사용 (서버사이드 i18n, `0062_create_i18n_error_diagnostics.sql`의 표준 패턴) |
| `catchmenu_common.log_diagnostic()` 호출 | 없음 | 있음(CRITICAL 레벨, recovery_hint 포함) |
| `catchmenu_audit.append_audit_record()` 호출 | 있음 | 있음 (양쪽 다 있음) |

### §1.1 `payment_intents.intent_status = 'UNCERTAIN'`(0063)은 라이브 CHECK 제약 위반 — 독립적으로 깨져 있음

라이브 제약 직접 조회(`pg_get_constraintdef`):

```
chk_intent_status: CHECK (intent_status = ANY (ARRAY['CREATED','PENDING','PROCESSING','CONFIRMED','FAILED','CANCELLED','EXPIRED']))
```

**`'UNCERTAIN'`은 이 목록에 없다.** 즉 `0063`의 6-param 오버로드는, 모호성 문제와 별개로, 실제 `payment_intents` 행이 존재해서 자기 본문의 **첫 번째 쓰기 문장**(`update payment_intents set intent_status = 'UNCERTAIN'`)에 도달하면 하드 제약 위반으로 크래시한다 — `confirm_payment_from_provider()`의 9-param 오버로드가 자기 본문 첫 쓰기 문장에서 크래시했던 것과 **동일한 패턴**이다.

**검증 방법 투명 공개**: 이 크래시 지점은 라이브 CHECK 제약 정의 조회로 확정했다(결정론적 사실 — `'UNCERTAIN'` 값을 가진 어떤 행도 이 제약을 통과할 수 없음). 실제 `payment_intents` 행을 만들어 함수 전체를 끝까지 실행시키는 재현은 하지 않았다 — `orders`/`order_sessions`부터 시작하는 FK 체인 전체를 구성해야 하는 비용 대비, 제약 정의 자체가 이미 결정적 증거이기 때문이다(`600482_Logic.md` §4가 `0027`의 `payment_ledger` INSERT를 정적 검증만으로 결론 낸 것과 동일한 방법론). 대신 nonexistent intent_id로 `0063`을 직접 호출해 early-return 경로(`intent_not_found`)까지는 실제로 실행되어 `p_locale`/`build_error_response` 배선이 정상 작동함을 확인했다.

### §1.2 `0027`(유지 후보) 자체에도 별도의, 크래시는 아닌 결함이 있음

`0070_create_flutter_bootstrap_rpc.sql`(부트스트랩 대시보드)의 "PAYMENT_UNCERTAIN active?" 체크는 다음과 같다:

```sql
select exists (
  select 1 from catchmenu_payment.payment_intents
  where store_id = p_store_id and tenant_id = p_tenant_id
    and intent_status = 'UNCERTAIN'
) into v_payment_uncertain_active;
```

`0027`이 실제로 설정하는 값은 `'UNCERTAIN'`이 아니라 `'PROCESSING'`이다 — 즉 **`0027` 경로로 결제가 불확실 처리돼도, `0070`의 부트스트랩 대시보드는 이를 영영 감지하지 못한다.** 이는 크래시가 아니라 조용한 기능 누락(silent gap)이다.

**단, 이 누락이 KDS 릴리즈 차단(특허1의 핵심 안전장치)까지 무력화하지는 않는다** — `authorize_kds_release()`(`0028`)의 실제 게이트 조건은 `payment_intents.intent_status`가 아니라 `catchmenu_ledger.exceptions`(`exception_type = 'payment_uncertain'`, status `OPEN`/`ACKNOWLEDGED`/`IN_RECOVERY`)를 직접 조회한다 — 이 exceptions row는 `0027`/`0063` **양쪽 모두** 생성한다. 따라서 KDS 릴리즈 차단 자체는 두 오버로드 어느 쪽을 쓰든 안전하게 유지되며, 위험에 노출되는 것은 `0070`의 대시보드 표시(운영 가시성)뿐이다 — 심각도를 과장하지 않기 위해 이 구분을 명시한다.

## §2 `p_locale`(다국어) 필요성 재확인 — confirm_payment_from_provider와 다른 맥락일 가능성

`600480`(`confirm_payment_from_provider`)의 확정 근거(`600481_Overview.md` §0.5)는 "실제 요구사항 없음이 삼중검증으로 확인됨"이었다 — 그 함수는 결제 게이트웨이 웹훅(`0038`/`0056`)이 시스템 대 시스템으로 호출하는 순수 백엔드 오케스트레이션이며, 응답을 직접 소비하는 사람이 없다.

`mark_payment_uncertain()`은 함수명·본문 내용상 성격이 다를 가능성이 있다:

- `0063` 버전의 `p_recovery_hint` 값: `"1. 카드사/PG사에 승인 여부 직접 확인 2. resolve_payment_uncertain() 호출 3. KDS 릴리즈 권한은 해소 후 자동 복구"` — **사람(스태프)이 읽고 따라야 할 행동 지침** 형태다.
- `comment on function`에 `"Recovery hint (ko/en/zh/ja)"`라는 문서화가 있으나, 실제 `p_recovery_hint` 값은 locale 분기 없이 한국어로 고정 하드코딩되어 있다 — 주석이 예고하는 다국어 지원과 실제 코드가 불일치한다(자체로 하나의 작은 drift).
- 반대로, 이 함수를 실제로 호출할 주체가 시스템(예: 결제 타임아웃 감지 배치)인지 스태프 앱의 수동 액션인지는 **저장소 어디에도 실제 호출자가 없어 확정할 수 없다** — 함수 설계 의도(주석/naming)만으로 추정한 것이며, 확정적 결론이 아니다.

**이번 턴 결론(판단 아님, 사실 나열)**: `confirm_payment_from_provider`의 "다국어 불필요" 근거를 이 함수에 기계적으로 적용하기에는, 이 함수의 응답이 스태프에게 직접 노출될 개연성을 시사하는 코드상 증거(recovery_hint 내용)가 있다는 점에서 최소 하나의 반례가 존재한다. 결정은 `600532_Logic.md`에서 옵션으로만 제시하고 Human 결정을 기다린다.

## §3 실제 호출 체인 — Open Question (해결 안 됨)

`mark_payment_uncertain()`을 실제로 트리거해야 할 지점(결제 타임아웃 감지, PG사 웹훅 실패 콜백, 스태프 수동 조작 등)이 현재 코드베이스 어디에도 구현되어 있지 않다 — `authorize_kds_release()`가 `600481_Overview.md` §1.3에서 이미 "호출자 0건"으로 확인된 것과 같은 성격의 공백이다. 이 워크패킷의 범위(오버로드 정리)를 넘어서므로 Open Question으로만 기록한다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `000701_Guide_Controlled_AI_Development_Pipeline.md`(특히 §37/§39/§43/§44, 오늘 신설된 검증 원칙)
- `600481_Overview.md`/`600482_Logic.md`(`confirm_payment_from_provider` 선례 — 이번 판단의 출발점이자, 재검증으로 정정된 대상)

### Full Rules Required

- `sql/migrations/0027_create_payment_intent_rpc.sql` — `mark_payment_uncertain()` 5-param 원본.
- `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql` — 6-param 패치본, `authorize_kds_release()`/`confirm_payment_from_provider()` 9-param과 동일 배치 작업.
- `sql/migrations/0028_create_kds_capacity_commit_rpc.sql` — `authorize_kds_release()`의 실제 게이트 조건(`exceptions` 테이블 조회) 확인용.
- `sql/migrations/0070_create_flutter_bootstrap_rpc.sql` — `PAYMENT_UNCERTAIN active?` 대시보드 체크 로직.
- `sql/migrations/0062_create_i18n_error_diagnostics.sql` — `build_error_response`/`build_success_response`의 i18n 처리 방식 확인용.

### Domain Indexes

- `600500_Readme_Payment_Confirmation.md`/`600502_NavigationMap_Payment_Confirmation.md` — 이 워크패킷이 속할 도메인의 현재 상태(아직 `600480`만 등재).

### Excluded Rule Families

- `authorize_kds_release()` 자체의 오버로드 정리 — `600481_Overview.md` §2가 이미 "구조적으로 다름(3번째 필수 파라미터 이름부터 상이)"으로 확인, 별도 워크패킷 대상. 이번 문서는 그 함수를 게이트 조건 확인 목적으로만 읽었고 오버로드 자체는 다루지 않는다.
- `900xxx` 특허 문서 — 특허1(PAYMENT_UNCERTAIN = KDS 릴리즈 금지) 설계 원칙 자체는 이번 워크패킷에서 재론하지 않는다. 다만 §1.2에서 확인했듯 그 안전장치는 `exceptions` 테이블 기반이라 이번 오버로드 정리와 무관하게 유지된다.

## Module Domain Tags

- SQL
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정 아님 — Human 결정 대기.** §1/§1.1/§1.2/§2에서 확인된 신규 발견(behavioral divergence, `0063`의 독립 크래시, `0027`의 조용한 대시보드 누락, `p_locale` 필요성 재고 여지)은 `600482_Logic.md`가 예측했던 "단순 DROP" 해법을 그대로 기계적으로 적용하기 어렵게 만든다. `600532_Logic.md`에서 옵션을 근거와 함께 제시한다.
