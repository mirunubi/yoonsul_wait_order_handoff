# 601717_ChangeContract_Operational_Authority_Foundation_V2.md

Status: Draft
Lifecycle: ChangeContract
Gate Classification: 0-A v2 Operational Authority Foundation Change Contract Draft
Runtime Implementation Authorization: Not Granted
Owner: Stage 5 (Claude Code) — 2026-08-23 재도출. 종전 판(Claude 작성)은 candidate reference
Last Updated: 2026-08-23

**개정 이력**

| 일자 | 내용 |
|---|---|
| 2026-08-22 | 초안 — 판정 4건 + Blocker 10건 |
| 2026-08-22 | 2판 — B-1 등 해소. 대상 2·3·4 편입. 판정 6건 |
| 2026-08-22 | 3판 — §1.37 보강·§1.45 반영. backfill 편입. §1.5 조건부 1건(C-1) |
| 2026-08-22 | **4판** — `601718`/`601719` write-path 실측으로 C-1 근거 확보. **C-1 을 `DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT` 로 확정**. 두 INSERT RPC 수정 명시적 금지. Deferred handoff 명시. N-5 해소, 신규 blocker 2건 |
| 2026-08-23 | **8판** — **Stage 7 Human Approval 기록**(정영석, 2026-08-23). Stage 7 → `APPROVED_FOR_IMPLEMENTATION`. A-3 을 `601722` 확정 이름으로 교체. **B-7·B-8 CLOSED**, **B-9 DEFERRED**. 검증 환경을 `postgres:17.6.1.140` 으로 고정 |
| 2026-08-23 | **7판** — **Stage 7 승인 항목 4번(§4.1 컬럼명·타입) Human 확정.** `account_name` → **`merchant_account_name`**. §4.1 을 파생 표현에서 **확정 정의**로 전환. **N-3′ CLOSED**(backfill 값 출처 = `tenants.tenant_name`). name synchronization 을 **H-5** 로 신규 이월 |
| 2026-08-23 | **6판** — Stage 7 사전 측정(`601720`/`601721`) 반영. **N-2″ 확정** — `601701` 기록이 정확했고 RPC 가 phantom 을 참조한다. C-1 사유 정밀화(두 경로 중 `provision_tenant` 만 현재 호출 가능. **판정 불변**). `create_franchise_store` 현재 실패를 blocker 로 기록. 신규 blocker 2건 |
| 2026-08-22 | **5판** — **N-5′ 해소**(`601713` I-43~I-51·§1.5·Q-10 / `601710` §2.3·§2.4 / `601705` §4.1·§4.4·§8·O20). 근거를 선언 단독에서 **선언+Logic 불변조건**으로 전환. §8.3 검증자 경고 철회. §10 Stage 4 병기 제거. 신규 blocker 1건 |
| 2026-08-23 | **9판 — Stage 5 재도출 (Claude Code).** verified design(`601702`/`601705`/`601710`/`601713`) 및 증거 문서에서 계약을 다시 도출. **substantive change 없음**, governance correction 4건 — §0.3 |
| 2026-08-23 | **10판 — Stage 6 findings 반영.** Codex F-1~F-7 처분(`601724`), Cursor informational 3건 처분(`601723`), **C-1 부적격 사유 교체**(`601725`/`601726` — 종전 사유 철회 병기), TP-RT-03 폐기, 신규 blocker N-6″~N-8″. **Stage 6 재검증 필요** |
| 2026-08-23 | **11판 — Stage 6 Round 2 findings 반영.** R2-F1~F5 blocking 해소, R2-F6·F7 처분. 검증자 편차 기록(§7.4 Round 2). **Round 3 재검증 필요** |
| 2026-08-23 | **12판 — Cowork Round 2 검증 반영.** CW-B1~B5 blocking 해소(UNIQUE 형태 3종 통일 · `provision_tenant` 「정상」 서술 철회 병기 · R2-F4 전파 · TP-N-63 ③ 제거 · rollback 기준선 모순 정정), CW-I1~I10 처분. **수정 완결성 grep 절차 적용** — §7.7. **Round 3 재검증 필요** |
| 2026-08-23 | **13판 — Round 3 findings 반영.** R3-F1(FUNCTION 「유효」 표현 폐기 — catalog 존재/본문 불변 과 runtime executability 분리) · R3-F2(**물리 객체명 5건 exact expectation 확정** — §4.2.2). R3-I1·I2 는 CW 라운드에서 이미 해소. **Round 4 재검증 필요** |
| 2026-08-23 | **14판 — Round 4 findings 반영** — C4-B1(FK 를 D-14 에 연결) · C4-I1 승격(트리거명 확정, 물리 객체명 6건) · C4-B2(처분 전제 정정). C4-B3 는 Correction A 로 `601700` Readme 에서 처리. **Round 5 재검증 필요** |
| 2026-08-23 | **Stage 6 COMPLETE** — Round 5 에서 3검증자 blocking 0, §9.20 원문 직접 검토 blocking 0. 무효 사유 5건 전건 해소 병기. §10.7 종료 기록 · §10.8 판본 고정 신설. Stage 7 재승인 대기 |
| 2026-08-23 | §10.8 판본 고정값 기록 — `601716` SHA-256 직접, `601717` git commit. §10.9 신설(Stage 7 승인 시 기록할 것) |
| 2026-08-23 | §10.9 대조 절차에 EOL 확인 0단계 추가. `autocrlf` 환경에서 작업트리 CRLF 로 인한 해시 불일치를 문서 변경과 구분한다 |

**Stage 5 Provenance**

| 구분 | 일자 | 내용 |
|---|---|---|
| Stage 5 재도출 | 2026-08-23 | Claude Code. 종전 판(Claude 작성)은 candidate reference |
| 2026-08-23 | **Stage 6 미수행 확인으로 Stage 7 승인 무효화.** §10.1 Human 판단은 pre-decision 으로 보존. Stage 5 재도출 → Stage 6 → 재승인 경로로 복구 |

## Change ID

```text
Workpacket    601700  Operational Authority Foundation V2 (0-A 재수행)
Change Scope  ① Person 어휘·물리 식별자 정합화
              ② MerchantAccount foundation 신설 + canonical backfill + Store 구조 부모 연결
Migration     0170 · 0171  (신규 · 번호 미사용 확인: sql/migrations 최신 = 0169)
```

## §0 계약 요약

`000001` §5.4.5 ChangeContract 다. **구현을 승인하지 않는다.**

**저자 분리**(`000001` §5.4.2)

| 산출물 | 저자 |
|---|---|
| ERD `601705` / Overview `601710` / Logic `601713` | Claude Code |
| 선언 `601702` | Human |
| **TestPlan `601716` / ChangeContract `601717`** | **Claude Code (2026-08-23 재도출).** 종전 판은 Claude 작성 — candidate reference |

### §0.1 3판 → 4판 — 측정이 C-1 을 판정 가능하게 만들었다

**측정이 하나 들어왔고, 그 결과가 C-1 을 판정 가능하게 만들었다.**

`601718`(Cursor) / `601719`(Codex)가 **상대 결과를 참조하지 않고 동일 수치에 도달**했다(`000701` §35).

```text
stores 참조 함수         158        (601701 D-3 은 151 — §7.2 에 기록)
INSERT 경로               2         provision_tenant / create_franchise_store
  둘 다 COLUMN_LIST
  둘 다 merchant_account_id 를 공급하지 않는다
NO_COLUMN_LIST            0
ROW_TYPE                  0
SELECT * · 행 타입 의존    0
앱 코드 직접 INSERT        0
UPDATE 경로               2         onboard_tenant(brand_id) / update_business_hours
stores 트리거            241        internal 240 + user 1 (trg_stores_updated_at)
stores 참조 view/matview   0 / 0
```

| 3판 blocker | 판정 |
|---|---|
| **N-5** `stores` 참조 함수 형태 미측정 | **해소.** `SELECT *`·행 타입 의존 0건, `NO_COLUMN_LIST` 0건이 실측됐다 |
| **N-1′** C-1 승격 가부 미판정 | **판정 가능해졌고, 판정 결과는 부적격이다.** §4.4 |

### §0.1.1 4판 → 5판 — 설계 문서가 선언을 따라잡았다

**4판이 기록한 N-5′ 가 해소됐다.**

| 문서 | 반영 내용 |
|---|---|
| `601713` Logic | **I-43~I-46**(§1.37 보강 — 트리거명·`person_name`·유지 대상 2건) · **I-47~I-51**(§1.45 — 존재 조건·backfill·1:1 강제 방향·배치·fail-closed) · §1.1 에 `owner_` 검증 범위 주석 · **§1.5 에 write-path 실측 승계** · §6 **Q-10** 추가(합계 10건) |
| `601710` Overview | §2.3 에 **§1.37 보강 · §1.45 행** 추가 · **§2.4 신설**(write-path 실측, 「구현 대상을 바꾸지 않는다」 명시) |
| `601705` ERD | §4.1 PERSON(트리거명·`person_name`) · §4.4 MERCHANT_ACCOUNT(배치·존재 조건·강제 방향·posture) · §8 Physical Drift 에 write-path 행 · **O20** 신설 |

**이 계약의 근거가 바뀌었다.**

```text
4판까지   §4.1~§4.3 · §4.5 의 근거 = 선언(§1.45) + 인접 테이블 실측 관행
5판       근거 = 선언 + Logic 불변조건(I-47 ~ I-51)
```

**결론은 하나도 바뀌지 않았다.** 같은 판정이 이제 Logic 을 경유해 지지된다.
Stage 6 검증자가 Logic 만 읽어도 backfill·트리거명 변경을 범위 초과로 판단하지 않는다 — §8.3.

> ⚠️ **다만 I-47 은 이번 구현이 미래에 대해 만족시킬 수 없는 불변조건이다.**
> 「Tenant 만 존재하고 MerchantAccount 가 없는 상태를 정상 운영 상태로 허용하지 않는다」는
> **검증 시점에는 참**이지만(backfill 이 기존 Tenant 전부를 덮으므로),
> `provision_tenant` 가 정렬되기 전까지 **강제되지 않는다.** §7.3 N-1″.

### §0.1.2 5판 → 6판 — 사전 측정이 N-2″ 를 닫았다

`601720`(Cursor) / `601721`(Codex)가 **동일 수치에 도달**했다(`000701` §35).

| 항목 | 실측 |
|---|---|
| PRE-5 `catchmenu_hq.tenants` 행 수 | **1** (`tenant_status=TRIAL`, `isolation_state=NONE`) |
| PRE-6 `catchmenu_hq.stores` 컬럼 수 | **16** — `601701` §4.5 B-1 기록과 **차이 0** |
| PRE-6 `stores.brand_id` | **부재** |
| PRE-6 `stores.extra_metadata` | **부재** |
| PRE-7 `provision_tenant` `prosrc` md5 | `f84ac1a81da4ccba87930bf020a3e974` (len 4758, 오버로드 1) |
| PRE-7 `create_franchise_store` `prosrc` md5 | `87511a95676a41d2c95866e0c2da8b7f` (len 3460, 오버로드 1) |

**N-2″ 확정 — 두 가능성 중 두 번째다.**

```text
5판에 기록한 두 가능성
  컬럼이 실재한다   →  601701 기록이 불완전하다        ❌ 아니다
  컬럼이 없다       →  RPC 가 phantom 을 참조한다      ⭕ 이것이다
```

**`601701` 의 16컬럼 기록은 정확했다.** 기준선 문서의 결함이 아니라 **RPC 의 결함**이다.

| 함수 | `brand_id` in `prosrc` | `extra_metadata` in `prosrc` | 현재 호출 가능성 |
|---|---|---|---|
| `catchmenu_common.provision_tenant` | 없음 | 없음 | ~~**정상**~~ → **철회 (2026-08-23, CW-B2)** — `601725`/`601726` 이 `tenants` INSERT 의 phantom 3건(`owner_name`·`owner_email`·`owner_phone`)을 확정해 **이 함수도 실행 불가능**하다. 위 「정상」은 `stores` 측만 본 6판 판정이며 §4.4.1.2 가 사실모델을 교체했다 |
| `catchmenu_hq.create_franchise_store` | 없음 | **있음** | **실패** — INSERT 주 경로가 부재 컬럼을 참조 |

> ⚠️ **`brand_id` 에 대해서는 이 측정이 답하지 않은 것이 있다.**
> `601720`/`601721` 의 `prosrc` 토큰 검사는 **위 두 INSERT RPC 만** 대상으로 했다.
> `601718` S-4 / `601719` S-4 는 **`catchmenu_common.onboard_tenant`** 가
> `update catchmenu_hq.stores set brand_id = v_brand_id …` 를 수행한다고
> 문장 전문과 함께 기록했으며, **그 함수는 이번 측정 범위에 없었다.**
>
> `stores.brand_id` 컬럼이 부재로 확정된 이상 **`onboard_tenant` 도 phantom 참조를 갖는다**는
> 것이 논리적 귀결이나, **그 함수 자체를 재측정한 문서는 없다.** §7.3 N-5″.

**이 측정이 바꾸지 않은 것**

`create_franchise_store` 가 이미 실패 상태라는 사실은 **C-1 판정을 바꾸지 않는다.** §4.4.1.

### §0.2 이 계약이 판정한 6건

| # | 판정 대상 | 결론 | 절 |
|---|---|---|---|
| 1 | `owners → persons` 물리 변경 방법 | **`ALTER … RENAME` 계열만 허용** | §2 |
| 2 | Store–LegalEntity `NOT NULL` enforcement | **DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT** | §3 |
| 3 | 허용 파일 / 금지 파일 | migration 2건 + 색인 동기화 / X-1~X-21 | §1 · §5 |
| 4 | Stage 7 승인란 | **대기** | §10 |
| 5 | `merchant_accounts` 물리 표현 | §4 에서 확정 | §4 |
| 6 | **MerchantAccount → Store `NOT NULL` enforcement** | **DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT** | §4.4 |

### §0.3 8판 → 9판 — Stage 5 재도출 대조 (2026-08-23, Claude Code)

**이 판은 후보본을 승인한 것이 아니라 다시 도출한 것이다.**

`000701` Stage 5 는 Contract Drafting 을 **Claude Code** 에 지정한다.
종전 판은 Claude 가 작성했고 근거로 삼은 `000001` §5.4.2 는
**2026-07-16 이전 번호 체계**다(`000701` 1096행). 그 결과 Claude 가 원작자가 되어
`000701` §37 상 **Stage 6 통합자 역할을 수행할 수 없는 상태**였다 — §10 무효화 배너 사유 4.

**재도출 근거 (authority)**

```text
선언      601702 §1.22~§1.27 · §1.31 · §1.34 · §1.37(보강) · §1.38 · §1.39
                 §1.43 · §1.44 · §1.45 · §2.1 · §2.2 · §5
설계      601705 §4.1 · §4.4 · §4.6 · §5.2 · §8 · §10(O18~O20)
          601710 §2 · §2.1~§2.4 · §3 · §3.1 · §4 · §5 · §7
          601713 I-1~I-51 · E-1~E-4 · X-1~X-11 · §6(Q-1~Q-10)
증거      601711 · 601712    Person 물리 기준선 (이중)
          601714 · 601715    갭 해소 실측 (이중)
          601718 · 601719    stores write-path (이중)
          601720 · 601721    Stage 7 사전 측정 (이중)
Human     601717 §10.1 pre-decision 9건
```

**대조 결과 — substantive change 없음**

| 대상 | 재도출 결과 |
|---|---|
| §1 허용 파일 A-1~A-6 | 동일 |
| §1.3 허용 DDL D-1~D-13 | 동일 — `601702` §1.37·§1.37 보강·§1.38·§1.39 / `601713` I-34~I-37 · I-43~I-46 에서 그대로 도출 |
| §1.4 허용 DDL D-14~D-21 | 동일 — §1.44·§1.45 / I-47~I-51 |
| §1.5 C-1 · C-2 | 동일 — **`DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT`.** `RESOLVED` 로 바꾸지 않았다 |
| §1.6 허용 동사 | 동일 |
| §2 판정 1 (rename-only) | 동일 — F-1~F-7 을 `601711`/`601712`/`601714`/`601715` 에서 재확인 |
| §3 판정 2 (C-2) | 동일 — E-1~E-4 가 `601713` §1.5 와 일치 |
| §4.1 확정 5컬럼 | 동일 — §10.1 항목 4 pre-decision 을 그대로 승계 |
| §4.4 판정 6 (C-1) | 동일 — `601718`/`601719`/`601720`/`601721` 실측 재대조 |
| §4.5 M-1 · M-2 | 동일 — M-2 가 파생이라는 N-2′ 표기 유지 |
| §4.6 External Provider 금지 | 동일 |
| §5 금지 파일 X-1~X-21 | 동일 |
| §6 금지 조작 FO-A~FO-40 | 동일 |
| §7 blocker | 동일 |
| §8 · §9 | 동일 (§9.3 1행 제외 — 아래 G-2) |

**재대조한 실측값** — 두 조사가 독립적으로 같은 값을 기록함을 확인했다(`000701` §35).

```text
stores 참조 함수        158     601718 L55 / 601719 L51
INSERT 경로              2      둘 다 COLUMN_LIST, merchant_account_id 미공급
NO_COLUMN_LIST / ROW_TYPE 0/0   601718 S-2 / 601719 S-2
stores 트리거          241      601718 S-6
tenants 행 수            1      601720 PRE-5 / 601721
stores 컬럼 수          16      601720 PRE-6 (brand_id · extra_metadata 부재)
provision_tenant md5    f84ac1a81da4ccba87930bf020a3e974 (4758)
create_franchise_store  87511a95676a41d2c95866e0c2da8b7f (3460)
```

**governance correction 4건** — 정책 결정이 아니라 문서 상태 정합화다.

| # | 지점 | 종전 | 재도출 | 근거 |
|---|---|---|---|---|
| G-1 | 헤더 `Owner` · §0 저자 분리 표 | Claude (본 문서 저자) | Claude Code 재도출 | `000701` Stage 5 |
| G-2 | §9.3 Codex Instruction Boundary 1행 | 「Stage 7 Human Approval 완료 … 승인 경계 안에서만 구현한다」 | 「Stage 7 미승인. 착수하지 않는다」 | §10 무효화 배너 — Stage 8 `MUST NOT START` |
| G-3 | `601716` §2 PRE-1 | Stage 7 = `APPROVED_FOR_IMPLEMENTATION` 을 전제값으로 서술 | 현재 Stage 7 = **대기** 를 반영 | 동일 |
| G-4 | §10 Stage 5 행 | `PROCEDURAL REPAIR REQUIRED` | **완료** — Claude Code 재도출 | 본 재도출 |

> ⚠️ **G-2 가 이 재도출에서 가장 중요한 정정이다.**
> §9.3 은 구현자에게 직접 주는 지시문이다. 「승인 완료」가 남아 있으면
> **Stage 8 을 시작하지 말라는 §10 배너와 정면으로 어긋난다.**

> **§4.1 · §4.5.1 · §7.1 · §10.2~§10.6 의 「Stage 7 확정 / CLOSED by Stage 7 Decision」 표기는 그대로 둔다.**
> 그 내용은 §10.1 Human pre-decision 이며 §10 배너가 **재승인 시 그대로 승계**한다고 명시했다.
> 표기를 지우면 다시 논쟁 대상이 된다 — 배너가 금지한 것이다.

**이 재도출이 하지 않은 것**

```text
새 정책 결정          없음
C-1 · C-2 의 RESOLVED 전환   없음
§10.1 9건 변경        없음
§10 무효화 배너 변경   없음
Stage 6 상태 변경     없음 — 대기 유지
```

## §1 Allowed — 허용 대상

### §1.1 허용 파일 — 구현(Stage 8)

| # | 경로 | 성격 | 제약 |
|---|---|---|---|
| A-1 | `sql/migrations/0170_person_vocabulary_normalization.sql` | 신규 | Person 계열 전용. **Stage 7 이 파일명 유지로 확정(2026-08-23)** |
| A-2 | `sql/migrations/0171_merchant_account_foundation.sql` | 신규 | MerchantAccount 계열 + backfill 전용. **동상** |

**A-1·A-2 가 허용 SQL 파일의 전부다.**

### §1.2 허용 파일 — 문서 동기화 (Stage 10, 기계적)

| # | 경로 | 허용 조작 |
|---|---|---|
| A-3 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601722_Module_Operational_Authority_Foundation_V2.md` | 신규 생성 (Stage 8 자기보고서). **파일명 확정 — 와일드카드 아님** |
| A-4 | `601700_Readme_…V2.md` §8 File List | 행 추가 |
| A-5 | `docs/000005_Index_Document_Number.md` | 행 추가 |
| A-6 | `docs/000007_Map_Full_Directory.md` | 행 추가 |

> ⚠️ **A-3 의 번호는 Stage 7 이 확정했다. 구현자가 바꾸지 않는다.**
>
> 7판까지 `601720_Module_*` 이었으나 **`601720`/`601721` 은 Stage 7 사전 측정에 이미 사용됐다.**
> Stage 7 이 승인 시점에 `000005` 기준 **미사용 번호임을 확인해 `601722` 로 확정**했다.
> 「`000005` 기준 다음 빈 번호를 쓰라」는 지시는 **더 이상 유효하지 않다** — `601722` 를 그대로 쓴다.

`000001` §5.11 트리플 업데이트는 A-4·A-5·A-6 을 **같은 배치**에서 처리할 것을 요구한다.

### §1.3 허용 DDL — `0170` Person 계열

| # | 조작 | 대상 | 근거 |
|---|---|---|---|
| D-1 | `ALTER TABLE … RENAME TO` | `owners` → `persons` | `601702` §1.37 |
| D-2 | `ALTER TABLE … RENAME COLUMN` | `legal_entity_person_roles.owner_id` → `person_id` | 동일 |
| D-3 | `ALTER TABLE … RENAME COLUMN` | `legal_entity_representatives.owner_id` → `person_id` | 동일 |
| D-4 | `ALTER TABLE … RENAME COLUMN` | `persons.owner_name` → `person_name` | §1.37 보강 / **`601713` I-44** |
| D-5 | `ALTER TRIGGER … RENAME TO` | `trg_owners_updated_at` → `trg_persons_updated_at` | §1.37 보강 / **`601713` I-43** |
| D-6 | `ALTER TABLE … RENAME CONSTRAINT` | `legal_entity_person_roles_owner_id_fkey` → `…_person_id_fkey` | §1.37 |
| D-7 | `ALTER TABLE … RENAME CONSTRAINT` | `legal_entity_representatives_owner_id_fkey` → `…_person_id_fkey` | 동일 |
| D-8 | `ALTER INDEX … RENAME TO` | `owners_pkey` → `persons_pkey` | 동일 |
| D-9 | `ALTER INDEX … RENAME TO` | `idx_lepr_owner` → `idx_lepr_person` | 동일 |
| D-10 | `ALTER TABLE … DROP COLUMN` | `persons.is_active` | `601713` I-36 / §1.38 |
| D-11 | `ALTER TABLE … DROP CONSTRAINT` | `chk_lepr_ownership_percent` | `601713` I-37 / §1.39 |
| D-12 | `ALTER TABLE … DROP COLUMN` | `legal_entity_person_roles.ownership_percent` | 동일 |
| D-13 | `COMMENT ON TABLE` | `persons` — literal: `Canonical natural persons who hold operational or legal authority for legal entities.` | `601713` I-15 / **F-2 처분** |

> **D-11 을 D-12 보다 먼저 수행한다.** 제약을 남긴 채 컬럼을 지우면 `CASCADE` 가 필요해지고,
> `601702` §1.39 와 I-37 이 `CASCADE` 를 금지했다.

> ⚠️ **`uq_lepr_active` / `uq_ler_active` / `uq_ler_sole_active` 는 이름을 바꾸지 않는다.**
> 세 이름에 `owner` 문자열이 없고, 정의 안의 컬럼 참조는 D-2·D-3 으로 자동 갱신된다.

> ⚠️ **§1.37 이 정합화 범위와 경계를 함께 그었고, `601713` I-45·I-46 이 이를 불변조건으로 승계했다.**
> `catchmenu_common.set_updated_at()` 함수명(I-45)과 `catchmenu_authority_owner` role 명(I-46)은
> **변경 대상이 아니다**(FO-9·FO-16).

### §1.4 허용 DDL — `0171` MerchantAccount 계열

| # | 조작 | 대상 | 근거 |
|---|---|---|---|
| D-14 | `CREATE TABLE` | **`catchmenu_hq.merchant_accounts` — §4.1 의 확정 5컬럼 + 명명된 `CONSTRAINT` 2건.** `merchant_accounts_pkey` PK · **`fk_merchant_accounts_tenant_id` FK** 를 `CREATE TABLE` 정의 안에 포함한다 — §1.4.1 | §1.44 · §1.45 「배치」 / `601713` I-50 / Stage 7 확정(2026-08-23) / **C4-B1 처분** |
| D-15 | `ALTER TABLE … ADD CONSTRAINT … UNIQUE` — **제약 형태로 한정** | `merchant_accounts.tenant_id` 단독. 제약명 `uq_merchant_accounts_tenant` | §1.45 「관계의 물리 표현」 / **`601713` I-49** / **F-1 처분** — `601716` TP-P-29 의 기대(UNIQUE 제약)와 일치시켰다. `CREATE UNIQUE INDEX` 형태는 허용에서 제외한다 |
| D-16 | `CREATE TRIGGER` | **트리거명 `trg_merchant_accounts_updated_at`.** `merchant_accounts` BEFORE UPDATE → `catchmenu_common.set_updated_at()` — 확정 구문은 §4.2.3 | §1.44 「수정 시각」 / **§4.2.2 확정명 · C4-I1(blocking 승격)** |
| D-17 | `ALTER TABLE … ENABLE / FORCE ROW LEVEL SECURITY` | `merchant_accounts` | §1.45 fail-closed baseline / **`601713` I-51** |
| D-18 | `ALTER TABLE … ADD COLUMN` | `stores.merchant_account_id` — **NULL 허용** | §1.26·§1.43 / Overview 대상 4 |
| D-19 | `ALTER TABLE … ADD CONSTRAINT … FOREIGN KEY` | **제약명 `fk_stores_merchant_account_id`**. `stores.merchant_account_id` → `merchant_accounts(id)`, `ON DELETE/UPDATE NO ACTION` | `fk_stores_legal_entity_id` 와 동일 관행 / **§4.2.2 확정명 (R3-F2)** |
| D-20 | `CREATE INDEX` | **인덱스명 `idx_stores_merchant_account_id`**. `stores.merchant_account_id` 조회 인덱스 | `idx_stores_legal_entity_id` 와 동일 관행 / **§4.2.2 확정명 (R3-F2)** |
| D-21 | `COMMENT ON TABLE / COLUMN` | **exact literal 3건 확정 — §4.2.1 참조.** `merchant_accounts` / `merchant_accounts.tenant_id` / `stores.merchant_account_id` | 어휘 정합 / **F-2 · R2-F2 처분** — `601716` TP-P-38 이 문자열 동일을 검사 |

#### §1.4.1 D-14 확정 형태 — PK · FK 는 `CREATE TABLE` 안에서 만든다 (C4-B1, 2026-08-23)

**`CREATE TABLE` 정의 안에서 반드시 아래를 포함한다.**

```text
  CONSTRAINT merchant_accounts_pkey PRIMARY KEY (id)
  CONSTRAINT fk_merchant_accounts_tenant_id
    FOREIGN KEY (tenant_id)
    REFERENCES catchmenu_hq.tenants(id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
```

**책임 배분**

```text
D-14   PK + Tenant FK 생성      CREATE TABLE 안의 명명된 CONSTRAINT
D-15   Tenant UNIQUE 생성       ALTER TABLE … ADD CONSTRAINT
D-16   trigger 생성             CREATE TRIGGER
D-19   stores 측 FK 생성        ALTER TABLE … ADD CONSTRAINT
D-20   stores 측 index 생성     CREATE INDEX
```

> ⚠️ **CW-B1 처분과 충돌하지 않는다.**
>
> CW-B1 이 배제한 것은 **제약명이 자동 생성되는 인라인 형태**다.
> `CONSTRAINT <name> …` 은 `CREATE TABLE` 안에 있어도 **명명된 제약**이므로
> §4.2.2 exact expectation 을 만족한다.
> **`tenant_id` 의 UNIQUE 는 D-15 에 그대로 남는다** — 형태 통일(R2-F1)은 유지된다.

> ⚠️ **왜 D 번호를 늘리지 않는가**
>
> FK 를 별도 D 항목으로 만들면 §1.6 `ADD CONSTRAINT` 한정 목록과
> §4.2.2 귀속 표를 다시 갈라야 한다. **한 객체를 만드는 조작은 한 D 항목에 둔다.**

### §1.5 Deferred Enforcement — 이번 계약이 수행하지 않는 강제

**3판의 「조건부 허용 C-1」을 여기로 옮긴다. 조건부가 아니라 이월이다.**

| # | 대상 | 상태 |
|---|---|---|
| **C-1** | `stores.merchant_account_id` `NOT NULL` 승격 | **`DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT`** |
| **C-2** | `stores.legal_entity_id` `NOT NULL` 승격 | **`DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT`** |

> ⚠️ **`RESOLVED` 가 아니다.**
>
> ```text
> 장기 canonical invariant       살아 있음
> 현재 0-A 에서 NOT NULL 적용    부적격
> ```
>
> **`RESOLVED` 로만 적으면 나중에 NOT NULL 요구 자체가 폐기된 것으로 읽힌다.**
> 두 항목 모두 요구는 유효하고 **이번 계약에서 적용할 수 없을 뿐**이다.

**각 항목의 장기 invariant 근거**

| # | 살아 있는 invariant | 근거 |
|---|---|---|
| C-1 | Store 의 구조 부모는 MerchantAccount 이며, MerchantAccount 없이 Tenant 에 직접 매달지 않는다. Tenant 만 존재하고 MerchantAccount 가 없는 상태를 정상 운영 상태로 허용하지 않는다 | **`601702` §1.26 · §1.45** / `601713` I-27 |
| C-2 | 각 Store 는 현재 시점의 법적 운영주체를 명시하며, 그 배정은 유효기간을 갖는 시점 관계다 | **`601702` §1.24 · §1.34** / `601713` I-40~I-42 |

부적격 사유는 §4.4(C-1)와 §3(C-2)에 각각 적었다. **사유가 서로 다르다.**

### §1.6 허용 동사 (narrow verbs)

```text
DDL 허용   ALTER TABLE … RENAME TO / RENAME COLUMN / RENAME CONSTRAINT
           ALTER TABLE … DROP COLUMN / DROP CONSTRAINT      (D-10 · D-11 · D-12 한정)
           ALTER TABLE … ADD COLUMN                         (D-18 한정)
           ALTER TABLE … ADD CONSTRAINT                     (D-15 · D-19 한정)
           CREATE TABLE … CONSTRAINT <name> PRIMARY KEY / FOREIGN KEY
                                                            (D-14 한정 — §1.4.1)
           ALTER TABLE … ENABLE / FORCE ROW LEVEL SECURITY  (D-17 한정)
           ALTER TRIGGER … RENAME TO                        (D-5 한정)
           ALTER INDEX … RENAME TO
           CREATE TABLE / CREATE INDEX / CREATE TRIGGER
           (CREATE INDEX 는 비-unique 인덱스만. CREATE UNIQUE INDEX 는 배제 — R2-F1 · CW-I10)
           COMMENT ON TABLE / COLUMN
DML 허용   INSERT … SELECT   (§4.5 M-1 한정)
           UPDATE … FROM     (§4.5 M-2 한정)

금지       ALTER TABLE … ALTER COLUMN … SET NOT NULL        (§1.5 — 이월)
```

**3판까지 있던 조건부 동사는 없다.** `SET NOT NULL` 은 이제 조건부가 아니라 **금지**다(FO-13).

## §2 판정 1 — `owners → persons` 물리 변경 방법

### §2.1 판정

**`ALTER … RENAME` 계열 조작만 허용한다.**
**신규 테이블 생성 후 교체 방식을 금지한다.**
**`owners` 라는 이름의 호환 view / matview 생성을 금지한다.**

### §2.2 판정 근거 — 실측 사실

| # | 사실 | 출처 |
|---|---|---|
| F-1 | Person 계열 4테이블 전부 0행 | `601711` P-3 / `601712` P-3 |
| F-2 | `owners` 참조 FUNCTION 0건, `pg_depend`→`pg_proc` 의존 0건 | `601714`/`601715` Q-4 |
| F-3 | `owners` 참조 VIEW / MATVIEW 0건 | `601711` P-1 |
| F-4 | 타 스키마에서 4테이블을 참조하는 FK 0건 | `601714`/`601715` Q-4 |
| F-5 | 앱·패키지·테스트·seed 코드 참조 0건 | `601711` P-5 / `601712` P-5 |
| F-6 | 관련 migration 은 `0168`/`0169` 2건뿐 | `601711` P-2 |
| F-7 | RLS `ENABLE`+`FORCE`, POLICY 0건, GRANT 4건, role 은 `nologin`+`bypassrls` | `601711` P-1 / `601714` Q-4 |

### §2.3 왜 rename 인가

```text
ALTER … RENAME          객체 OID 가 유지된다 → I-1~I-4, I-9~I-14 자동 보존
CREATE 신규 + 교체       FK 2 · TRIGGER 1 · RLS · GRANT 4 · PK · 부분 unique 3 을
                        전부 재선언 → Logic X-1·X-2·X-3·X-4·X-6·X-7·X-8 이 실현 가능해진다
```

**Logic §3 의 11개 실패 지점 중 7개는 "신규 생성 후 교체"에서만 발생한다.**

### §2.4 rename 이 자동으로 해주지 않는 것

| 항목 | PostgreSQL 동작 | 계약 요구 |
|---|---|---|
| FK **정의** 안의 컬럼 참조 | 자동 갱신 | 조치 불필요 |
| FK **제약 이름** | 자동 갱신 안 됨 | D-6 · D-7 |
| **인덱스 이름** | 자동 갱신 안 됨 | D-8 · D-9 |
| **트리거 이름** | 자동 갱신 안 됨 | D-5 |
| 부분 unique 인덱스 **정의** | 자동 갱신 | 이름 변경 금지 |
| 테이블 **코멘트** | 유지 | D-13 |

### §2.5 호환 계층을 금지하는 이유

`owners` view 를 남기면 legacy 어휘가 **다시 조회 가능한 canonical 표면**이 된다.
데이터 0행·코드 참조 0건 상태에서 호환 계층이 보호할 호출자가 없다(`601710` §2.1).

### §2.6 이 판정이 결정하지 않은 것

`legal_entities` / `legal_entity_person_roles` / `legal_entity_representatives` 테이블명은 유지한다(I-35).
`catchmenu_authority_owner` role 명과 `catchmenu_common.set_updated_at()` 함수명은 유지한다(§1.37 명시적 제외).

## §3 판정 2 — Store–LegalEntity NOT NULL enforcement

### §3.1 판정

**`DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT`** (§1.5 C-2).
`stores.legal_entity_id` 에 `NOT NULL` 을 걸지 않는다.

**장기 invariant 는 살아 있다** — `601702` §1.24·§1.34, `601713` I-40~I-42.

### §3.2 부적격 사유 — Logic E-1~E-4 대조

| 조건 | 판정 | 근거 |
|---|---|---|
| E-1 모든 Store 가 검증된 business identity 확보 | **거짓** | `010901` §11 의 9개 intake 필드 중 실재 정확명 1건, 나머지 8건 0건 (`601714`/`601715` Q-8) |
| E-2 그 identity 로 canonical LegalEntity 생성·연결 | **거짓** | `legal_entities` 0행 (`601701` §4.5 D-3) |
| E-3 mapping completeness — 미매핑 Store 0 | **거짓** | `stores` 1행 / 백필 0행 → 미매핑 1 |
| E-4 신규 onboarding 경로 강제 | **미확인** | `sales_lead`/`tenant_candidate` 0건. `tenant_onboarding_log` 는 intake 9필드를 담지 않는다 |

**`601710` §4 가 같은 결론을 독립적으로 재확인했다** — 「enforcement 는 여전히 부적격이다」.

> **C-1 과 사유가 다르다.**
>
> ```text
> C-2 (LegalEntity)      채울 값 자체가 없다.  외부 검증(사업자등록 intake)이 선행되어야 한다
> C-1 (MerchantAccount)  값은 채워진다.        신규 생성 경로가 값을 공급하지 않을 뿐이다
> ```

### §3.3 §1.45 의 backfill 이 여기로 확장되지 않는다

`601702` §1.45 자신이 경계를 그었다.

```text
LegalEntity        외부 검증(사업자등록 intake)이 필요하다   →  §1.31 synthetic 금지 적용
MerchantAccount    Tenant 로부터 파생, 외부 검증 불요        →  backfill 허용
```

| 금지 | 근거 |
|---|---|
| 검증되지 않은 synthetic LegalEntity 생성 | I-28 / §1.31·§1.45 |
| placeholder 로 `stores.legal_entity_id` 백필 | 동일 |
| `store_operator_type` 값으로 LegalEntity 추론·배정 | I-30 / §1.32 |

### §3.4 시점 관계 물리 구조를 만들지 않는 이유

| # | 이유 |
|---|---|
| 1 | `601710` §4 의 적용 분기가 **「미확보 → 관계만 유지」** 다 |
| 2 | I-41(유효기간 중첩 금지) 검증 방식을 §1.34 가 「물리 설계에서 정한다」로 남겼는데, **필요한 확장(`btree_gist` 등) 설치 여부 실측이 없다** |
| 3 | I-42 는 Store 의 현재값을 「현재 포인터」로 규정한다. 시점 테이블 없이 포인터만 남기면 **권위 원본 없는 포인터**가 된다 |
| 4 | 검증할 데이터가 0행이다 |

**§7.2 B-5 로 남긴다.**

## §4 판정 5 — `merchant_accounts` 물리 표현

### §4.1 확정 — 필드 구성 (Stage 7 Human 확정, 2026-08-23)

> **6판까지 이 절은 이 계약의 파생 표현이었다. 7판부터 Human 확정값이다.**
> Stage 7 승인 항목 4번이 처리됐다 — §10.

```text
catchmenu_hq.merchant_accounts        ← 목표 상태 (DDL 형태는 D-14·D-15. stores 측은 D-18~D-20)

  id                     uuid NOT NULL DEFAULT gen_random_uuid()  PRIMARY KEY
  tenant_id              uuid NOT NULL
  merchant_account_name  text NOT NULL
  created_at             timestamptz NOT NULL DEFAULT now()
  updated_at             timestamptz NOT NULL DEFAULT now()

  merchant_accounts_pkey          PRIMARY KEY (id)             ← D-14
  uq_merchant_accounts_tenant     UNIQUE (tenant_id)           ← D-15  ADD CONSTRAINT
  fk_merchant_accounts_tenant_id  FOREIGN KEY (tenant_id)      ← D-14  §1.4.1
                                  → catchmenu_hq.tenants(id)
                                  ON DELETE NO ACTION / ON UPDATE NO ACTION
```

> ⚠️ **객체명은 §4.2.2 가 확정한 exact expectation 이다**(R3-F2). 자동 생성명을 쓰지 않는다.

> ⚠️ **UNIQUE 와 FK 는 인라인 컬럼 정의가 아니라 명명된 제약이다**(CW-B1 처분).
>
> ```text
> 금지   CREATE TABLE … tenant_id uuid NOT NULL UNIQUE …    인라인 — 제약명이 자동 생성된다
> 금지   CREATE UNIQUE INDEX …                              R2-F1 에서 배제
> 채택   ALTER TABLE … ADD CONSTRAINT uq_merchant_accounts_tenant UNIQUE (tenant_id)
> ```
>
> **D-14 는 5컬럼 + 명명된 PK·FK 제약을 만든다**(§1.4.1 — C4-B1 정정).
> **UNIQUE 는 D-15 가** 별도 `ALTER TABLE … ADD CONSTRAINT` 로 만든다.
>
> **12판까지 이 자리는 `merchant_accounts` FK 의 근거를 D-19 로 적었다.**
> **D-19 는 `stores` 측 FK(`fk_stores_merchant_account_id`)이며 이 FK 를 만들지 않는다** — C4-B1.

**총 5컬럼.** `601716` TP-N-21 이 컬럼 수 일치를 검사한다.

| 선언 항목(`601702` §1.44) | 확정 컬럼 | 근거 |
|---|---|---|
| 식별자 (PK) | `id` | `tenants.id`/`stores.id`/`legal_entities.id` 동일 형태(`601701` E단계) |
| Tenant 참조 | `tenant_id` — `NOT NULL` 컬럼 + **명명 제약** `uq_merchant_accounts_tenant UNIQUE (tenant_id)`(D-15) + **명명 FK** `fk_merchant_accounts_tenant_id`(**D-14 · §1.4.1**) | **§1.45 가 이름·NOT NULL·UNIQUE 를 직접 명시** / `601713` I-49 / **CW-B1 처분 — 인라인 UNIQUE 형태는 배제** / **C4-B1 — FK 귀속을 D-19 에서 D-14 로 정정** |
| 계정 명칭 | **`merchant_account_name`** | `tenants.tenant_name` / `stores.store_name` / `persons.person_name` 관례 |
| 생성·수정 시각 | `created_at` / `updated_at` | 네 테이블 전부 동일 형태 |

**명명 근거 — 왜 `account_name` 이 아닌가**

```text
관례      tenants.tenant_name · stores.store_name · persons.person_name
                → <entity>_name

위험      account_name 은 일반어이며
          향후 PG account · settlement account 와 혼동될 수 있다
```

> `persons.person_name` 은 이 계약이 D-4 로 만드는 이름이다(`601702` §1.37 보강 / `601713` I-44).
> 세 이름이 같은 규칙을 따르는 것이 이 확정의 근거다.

**포함하지 않는 것 — 확정**

```text
is_active / status
provider 식별자
legal_entity_id
store_id
임의 business metadata
```

| 제외 | 근거 |
|---|---|
| `is_active` / `status` | `601702` §1.44 미채택(상태 축 · 과금 경계) / `601713` I-39 |
| provider 식별자 | §4.6 External Provider Mapping 금지 / `601702` §1.43 |
| `legal_entity_id` | **`601713` I-38** — §1.23 과 충돌 |
| `store_id` | 관계 방향이 반대다. Store 쪽이 `merchant_account_id` 를 보유한다(D-18) |
| 임의 business metadata | `601713` I-39 — 미채택 필드를 임의로 추가하지 않는다 |

**`601716` TP-N-16~TP-N-21 · TP-N-60 이 이 제외 목록을 negative 로 검사한다.**

### §4.2 확정 — 제약과 부속 객체

| # | 객체 | 정의 | 근거 |
|---|---|---|---|
| 1 | `uq_merchant_accounts_tenant` | `ALTER TABLE … ADD CONSTRAINT uq_merchant_accounts_tenant UNIQUE (tenant_id)` — **제약 형태만 허용**(R2-F1) | §1.45 「이것만으로 1:1 이 강제된다」 / **`601713` I-49** / D-15 |
| 1a | `merchant_accounts.tenant_id` FK — **제약명 `fk_merchant_accounts_tenant_id`** | → `catchmenu_hq.tenants(id)`, **`ON DELETE NO ACTION` / `ON UPDATE NO ACTION`**. **생성 조작은 D-14**(§1.4.1) | §4.1 Stage 7 확정 / `601713` I-3 관행 / §4.2.2 확정명 (R3-F2) / **C4-B1** |
| 2 | `trg_merchant_accounts_updated_at` | **§4.2.3 확정 구문.** `BEFORE UPDATE … EXECUTE FUNCTION catchmenu_common.set_updated_at()`. 생성 조작은 D-16 | §1.44 / **§4.2.2 확정명 · C4-I1** |
| 3 | RLS | `ENABLE` + `FORCE`, POLICY 0건 | §1.45 fail-closed baseline / **`601713` I-51** |
| 4 | GRANT | `catchmenu_authority_owner` 외 확대 금지 | 동일 |

#### §4.2.1 확정 COMMENT literal (R2-F2, 2026-08-23)

**아래 3건이 D-21 의 허용 literal 전부다.** 문자열을 바꾸지 않는다.

```text
COMMENT ON TABLE catchmenu_hq.merchant_accounts IS
  'CatchMenu SaaS contract and management account. One-to-one with tenant.';

COMMENT ON COLUMN catchmenu_hq.merchant_accounts.tenant_id IS
  'Owning tenant. NOT NULL and UNIQUE; this column alone enforces the 1:1 relationship.';

COMMENT ON COLUMN catchmenu_hq.stores.merchant_account_id IS
  'Structural parent merchant account. Nullable in this contract; NOT NULL is deferred (C-1).';
```

**D-13 의 literal 도 같은 방식으로 고정되어 있다.**

```text
COMMENT ON TABLE catchmenu_hq.persons IS
  'Canonical natural persons who hold operational or legal authority for legal entities.';
```

> ⚠️ **literal 이 확정되지 않으면 문자열 동일 검사가 성립하지 않는다**(R2-F2).
> `601716` TP-P-23 · TP-P-38 이 위 4건을 **문자열 동일**로 검사한다.
> 구현자가 문구를 다듬으면 FAIL 이다 — §9.3 S-13.

#### §4.2.2 확정 물리 객체명 (R3-F2, 2026-08-23 Human 결정)

**아래 6개가 이 계약이 만드는 물리 객체명 전부다.** exact expectation 이며 구현자가 선택하지 않는다.

```text
merchant_accounts_pkey            PK            (D-14  §1.4.1)
uq_merchant_accounts_tenant       UNIQUE        (D-15)
fk_merchant_accounts_tenant_id    FK            (D-14  §1.4.1)
trg_merchant_accounts_updated_at  TRIGGER       (D-16)
fk_stores_merchant_account_id     FK            (D-19)
idx_stores_merchant_account_id    INDEX         (D-20)
```

> **13판까지 5개였다.** C4-B1 이 FK 귀속을 `§4.2 1a` → `D-14` 로 정정했고,
> **C4-I1(blocking 승격)이 `trg_merchant_accounts_updated_at` 을 추가**했다 — 6개다.

**명명 근거**

| 객체 | 형태 | 근거 |
|---|---|---|
| PK | `<table>_pkey` | PostgreSQL deterministic 기본형. `owners_pkey` → `persons_pkey` 계보 유지 |
| UNIQUE | `uq_<table>_<의미>` | `uq_lepr_active` / `uq_ler_sole_active` 관례 — constraint 의 업무 의미를 담는다 |
| FK · index | `<접두>_<table>_<column>` | 기존 `fk_stores_legal_entity_id` / `idx_stores_legal_entity_id` 관례 |
| TRIGGER | `trg_<table>_updated_at` | `trg_owners_updated_at` → `trg_persons_updated_at`(D-5) · `trg_stores_updated_at` 관례 |

> ⚠️ **FK 와 index 에 `_id` 를 붙이는 이유**
>
> 무엇을 참조하는지가 아니라 **어느 컬럼에 걸린 제약인지**를 이름만으로 식별한다.
> 향후 `merchant_account_code` · `merchant_account_status` 가 함께 존재하면
> `idx_stores_merchant_account` 는 모호해진다.
>
> UNIQUE 는 예외다. `uq_merchant_accounts_tenant` 가
> **「한 Tenant 당 MerchantAccount 하나」** 라는 invariant 를 더 잘 표현한다.

> ⚠️ **R3-F2 가 지적한 것은 자동 생성명과 명시명이 모두 계약을 만족한다는 점이다.**
> `ALTER TABLE … ADD CONSTRAINT` 에 이름을 주지 않으면 PostgreSQL 이
> `merchant_accounts_tenant_id_key` 류를 자동 생성하고, 그것도 「UNIQUE 제약 존재」를 만족한다.
> **구현자가 선택하게 두지 않는다** — `601716` TP-P-26·27·29·32·34~36 이 위 이름을 정확히 기대한다.
>
> ⚠️ **`merchant_accounts_pkey` 는 이 문장의 예외다**(C4-I4 처분, 2026-08-23).
> PK 는 PostgreSQL 이 `<table>_pkey` 로 **결정적으로** 만들며, 위 명명 근거 표도 그렇게 적는다.
> **이 한 건은 「자동 생성명이면 FAIL」이 아니라 「이 문자열과 일치하면 PASS」다.**
> 나머지 5건은 이름을 명시하지 않으면 다른 문자열이 나오므로 FAIL 이다.


#### §4.2.3 확정 TRIGGER 구문 (C4-I1, 2026-08-23)

**D-16 의 허용 구문은 아래 하나다.**

```text
CREATE TRIGGER trg_merchant_accounts_updated_at
BEFORE UPDATE ON catchmenu_hq.merchant_accounts
FOR EACH ROW EXECUTE FUNCTION catchmenu_common.set_updated_at()
```

> ⚠️ **트리거는 자동 생성명이 없다.**
>
> PK 는 `<table>_pkey` 로 결정적이지만, **`CREATE TRIGGER` 는 이름이 필수 인자**다.
> 즉 **구현자가 반드시 이름을 고르게 되는 유일한 객체**이며,
> 13판 §4.2.2 가 「물리 객체명 **전부**」라고 적고도 이것을 빠뜨렸다 — C4-I1.
>
> `601716` **TP-P-32** 가 이름과 호출 함수를 함께 exact 로 검사한다.

> **`catchmenu_common.set_updated_at()` 함수명은 바뀌지 않는다** —
> `601702` §1.37 보강이 generic technical identifier 로 명시 제외했고 FO-16 이 금지한다.

### §4.3 확정 — 스키마 배치

**`catchmenu_hq`.** `601702` §1.45 「배치」가 직접 확정했고 **`601713` I-50** 이 불변조건으로 승계했다.
`601705` §4.4 도 같은 값을 기록한다.

### §4.4 판정 6 — MerchantAccount → Store NOT NULL enforcement

**`DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT`** (§1.5 C-1).

**장기 invariant 는 살아 있다** — `601702` §1.26·§1.45, `601713` I-27.

#### §4.4.1 판정 근거 — `601718`/`601719` 실측

| 조건 | 판정 | 근거 |
|---|---|---|
| 기존 데이터에 값을 채울 수 있는가 | **참** | §1.45 backfill + `stores.tenant_id` NOT NULL → 전 행 결정적 파생 |
| mapping completeness 를 만들 수 있는가 | **참** | 미매핑 Store 0 달성 가능 (M-2) |
| `SELECT *` · 행 타입 의존 함수가 깨지는가 | **아니오** | **`SELECT *`/`ROW_TYPE` 0건**(`601718` S-3 / `601719` S-3) |
| 컬럼 목록 없는 INSERT 가 깨지는가 | **아니오** | **`NO_COLUMN_LIST` 0건**(`601718` S-2 / `601719` S-2) |
| 앱 코드가 깨지는가 | **아니오** | **앱 코드 직접 INSERT 0건**(`601718` S-5 / `601719` S-5) |
| **신규 Store 생성 경로가 값을 공급하는가** | **아니오 — 2건 전부 미공급** | **`provision_tenant` / `create_franchise_store`. 둘 다 `COLUMN_LIST` 이며 `merchant_account_id` 가 컬럼 목록에 없다** |
| 두 경로가 현재 호출 가능한가 | ~~**1건만 가능**~~ → **0건** | **철회 (2026-08-23, CW-B2)** — 6판은 `provision_tenant` 를 「정상」으로 보았으나 `601725`/`601726` 이 `tenants` INSERT 의 phantom 3건을 확정했다. **두 경로 모두 실행 불가능**하다 — §7.3 N-6″ · §4.4.1.2 |

**마지막 조건 하나가 부적격을 만든다.**

```text
provision_tenant       insert into catchmenu_hq.stores
                         (tenant_id, store_code, store_name,
                          store_type, store_status, timezone)

create_franchise_store insert into catchmenu_hq.stores
                         (tenant_id, store_code, store_name, store_type,
                          store_status, address, phone, timezone,
                          business_hours, opened_on, is_active, extra_metadata)
```

**어느 쪽도 `merchant_account_id` 를 공급하지 않는다.**

#### §4.4.1.1 6판 정밀화 — 부적격은 `provision_tenant` 하나로 성립한다

`601720`/`601721` PRE-6 이 두 경로의 현재 상태를 갈랐다.

```text
provision_tenant         호출 가능하다.  merchant_account_id 를 공급하지 않는다
                         → NOT NULL 을 걸면 이 경로가 새로 깨진다

create_franchise_store   이미 실패한다.  부재 컬럼 extra_metadata 를 참조한다
                         → NOT NULL 이 이 경로를 더 나쁘게 만들지는 않는다
```

**따라서 부적격 판정은 `provision_tenant` 하나에 걸려 있다. 그것으로 충분하다.**

> ⚠️ **「어차피 하나는 이미 깨져 있으니 나머지 하나만 고치면 된다」는 논증을 이 계약이 받지 않는다.**
>
> 그 「나머지 하나」를 고치는 것이 `provision_tenant` 수정이며,
> **RPC 재작성은 `601710` §3 이 이 나선 밖에 두었다**(FO-A).
> 경로가 2건이든 1건이든, **살아 있는 생성 경로가 값을 공급하지 않는 한 부적격이다.**

> 🛑 **위 블록의 「`provision_tenant` 호출 가능하다」는 철회됐다 (2026-08-23, CW-B2).**
> `601725`/`601726` 이 `tenants` INSERT 의 phantom 3건을 확정했다 — 이 함수도 실행 불가능하다.
> **§4.4.1.2 가 사실모델을 교체했다.** 이 절은 6판 시점의 기록으로 보존한다.

**판정은 5판과 같다. 바뀐 것은 사유의 정밀도뿐이다.**

#### §4.4.1.2 10판 — 부적격 사유 교체 (2026-08-23 Human 재판정)

> **종전 사유를 삭제하지 않는다. 철회로 병기한다.**

```text
철회 (2026-08-23)
  「정상 동작하는 provision_tenant 가 merchant_account_id 를 공급하지 않아
    NOT NULL 적용 시 신규 Store 생성 경로를 새로 깨뜨린다」
  → 사실모델이 틀렸다. 601725 / 601726 참조

새 사유 (2026-08-23 Human 재판정)
  현재 확인된 Store provisioning RPC 계층 자체가 이미 실행 불가능하며,
  그 복구·재정렬은 현재 0-A 계약 범위 밖이다.
```

**판정은 유지한다** — `DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT`.

**사실모델이 바뀐 근거** (`601725` Cursor / `601726` Codex — 이중 검증)

```text
provision_tenant 의 tenants INSERT 가
  owner_name · owner_email · owner_phone 세 phantom 컬럼을 참조한다

0002 가 세 컬럼 없이 catchmenu_hq.tenants 를 만들었고
0082 가 provision_tenant 최초 정의에서 그대로 참조했다 — 처음부터 phantom
tenants INSERT 가 첫 단계이므로 stores INSERT 에 도달하지 못한다
```

> **현재 모든 확인된 Store provisioning 경로가 이미 실행 불가능하므로
> NOT NULL 이 새 regression 을 발생시키는 것은 아니다.**
>
> 그러나 정상적인 runtime producer 자체의 복구 및 MerchantAccount binding 이
> 이번 0-A 의 허용 범위 밖이며,
> **producer 가 invariant 를 만족함을 검증하기 전에 DB enforcement 만 선행시키지 않는다.**
>
> `stores.merchant_account_id NOT NULL` 은 후속 RPC alignment 에서
> provisioning 경로를 정상화하고 `merchant_account_id` 공급을
> 실제 실행 검증한 뒤 같은 나선에서 재판정한다.

> ⚠️ **ELIGIBLE 로 올리지 않는 이유**
>
> ```text
> 현재 Store 1행                    M-2 backfill 가능
> 현재 정상 Store 생성 RPC          0개
> 지금 NOT NULL 적용                작동 중인 경로를 새로 깨뜨리지는 않음
> ```
>
> 기술적으로는 성립한다. 그러나 C-1 은 단순 데이터 청결 제약이 아니라
> `Tenant → MerchantAccount → Store` **구조적 생성 계약의 enforcement** 다.
>
> **DB 제약만 완성하고 그것을 만족시키는 정상 write path 가 하나도 없는 상태**를 만들면,
> 이번 0-A 가 producer contract 까지 검증했다는 인상을 준다.
>
> DB enforcement 와 그것을 만족시키는 producer 는 **같은 후속 나선에서 검증하고 잠근다.**

> **§4.4.1.1 의 「부적격은 `provision_tenant` 하나로 성립한다」는 철회 대상이다.**
> `provision_tenant` 도 실행 불가능하므로 「살아 있는 생성 경로」는 0개다.
> **판정 결과는 같고 사유가 바뀌었다.**

#### §4.4.2 왜 두 RPC 를 고쳐서 해결하지 않는가

**두 RPC 수정은 이 계약의 범위 밖이다.**

| # | 근거 |
|---|---|
| 1 | `601700` Readme §5 · `601710` §3 — **RPC 재작성 Out of Scope** |
| 2 | `601702` §1.45 자신이 「Tenant provisioning 경로의 구현은 0-A 범위 밖」이라고 명시했다 |
| 3 | 두 RPC 는 `stores` 를 넘어 tenant·brand·plan·quota 를 함께 다룬다. 여기서 손대면 0-A 가 provisioning 설계를 선점한다 |

**따라서 이 계약은 값을 채우되 제약을 걸지 않는다.**

```text
이번 계약    구조 생성 + backfill        기존 행 전부 값 보유
             NOT NULL 미적용             신규 행은 NULL 로 생성될 수 있다

후속 나선    두 RPC 가 값을 공급하도록 정렬 → NOT NULL 승격 재판정
```

#### §4.4.3 Deferred Handoff — 후속 RPC alignment 나선

**이 계약이 넘기는 것을 명시한다.**

| # | 이월 항목 | 근거 |
|---|---|---|
| H-1 | `catchmenu_common.provision_tenant` 가 `merchant_accounts` 행을 **같은 transaction 에서** 생성하도록 정렬 | **`601702` §1.45 「신규 Tenant 생성 경로가 MerchantAccount 동시 생성을 책임진다」** |
| H-2 | `catchmenu_common.provision_tenant` 의 `stores` INSERT 가 `merchant_account_id` 를 공급하도록 정렬 | §1.26 / I-27 |
| H-3 | `catchmenu_hq.create_franchise_store` 의 `stores` INSERT 가 `merchant_account_id` 를 공급하도록 정렬 | 동일 |
| **H-3a** | **H-3 에 선행 — `create_franchise_store` 의 phantom `extra_metadata` 참조 교정.** 현재 이 함수는 호출 시 실패한다(`601720`/`601721` PRE-6) | **§7.3 N-4″.** 0-A 범위 밖 |
| **H-5** | **`tenants.tenant_name` ↔ `merchant_accounts.merchant_account_name` 동기화 정책** — backfill 은 **초기값 복사**이며 영구 미러가 아니다. 이후 tenant 명칭이 바뀔 때 계정 명칭이 따라가는지 정하지 않았다 | **`601702` §2.2 — 0-A 에서 정하지 않는다.** §4.5.1 |
| H-4 | H-1~H-3 완료 후 `stores.merchant_account_id` `NOT NULL` 승격 재판정 | §1.5 C-1 |

**소관**: 후속 **RPC alignment 나선**. `601700` Readme §5 가 RPC 재작성을 파생 나선 소관으로 두었다.
**워크패킷 번호는 이 계약이 확정하지 않는다.**

> **Prerequisite**: `provision_tenant` 자체의 기존 phantom 참조와 제약 위반이
> **먼저 별도 RPC alignment 범위에서 정합화되어야 한다.**
>
> ```text
> N-6″   tenants INSERT 의 phantom 3건
>        owner_name · owner_email · owner_phone
>
> N-8″   stores INSERT 의 store_type='RESTAURANT' 가 chk_stores_type 허용값 밖
>        DINE_IN / TAKEOUT / HYBRID / DELIVERY_ONLY
> ```
>
> ⚠️ **위는 필요조건이며 충분조건이 아니다** (C4-I6 처분, 2026-08-23).
>
> N-6″·N-8″ 를 정합화해도 **호출 경로를 통한 검증은 여전히 불가능하다.**
>
> ```text
> provision_tenant 의 in-DB 직접 호출자   1개 = onboard_tenant   (601725 §7.1 / 601726 §7.3)
> 앱·테스트 코드 직접 호출자              0개                     (601725 §7.4 / 601726 §7.2)
> onboard_tenant 의 상태                  N-7″ — business_number phantom + 인자명 불일치
> ```
>
> **유일한 in-DB 호출 경로가 N-7″ 로 막혀 있다.**
> 후속 RPC alignment 나선이 **「경로 검증」과 「직접 호출 검증」을 구분하지 않으면
> H-1 완료 판정이 흔들린다** — `authenticated` EXECUTE 를 통한 직접 호출 검증만 가능하다.
>
> **이 계약은 N-7″ 를 H-1 의 Prerequisite 으로 승격하지 않는다.**
> N-7″ 는 §7.3 에 기록되어 있고 H-1 은 후속 나선 소관이며,
> 승격은 후속 나선의 범위 결정이다.
>
> **phantom 3건만 고치면 다음 단계에서 다시 막힌다**(R2-F4).
> 두 지점이 모두 정합화되기 전에는 H-1 의 MerchantAccount 동시 생성을 검증할 방법이 없다.
>
> `601725` / `601726` 실측. §7.3 **N-6″ · N-8″**.


> ⚠️ **H-1 은 H-2·H-3 과 성격이 다르다.**
> H-2·H-3 은 컬럼 하나를 공급하는 문제지만,
> **H-1 은 `provision_tenant` 가 현재 MerchantAccount 를 아예 만들지 않는다는 문제**다.
>
> **5판에서 근거가 승격됐다** — `601713` **I-47** 이 「Tenant 만 존재하고 MerchantAccount 가 없는
> 상태를 정상 운영 상태로 허용하지 않는다」를 **Logic 불변조건**으로 두었다.
> 이번 구현은 backfill 로 **기존** Tenant 에 대해서만 I-47 을 만족시킨다.
> 이 계약이 backfill 로 기존 Tenant 를 덮고 나면,
> **다음에 provisioning 되는 Tenant 부터 §1.45 의 1:1 invariant 가 다시 깨진다.**
> §7.3 N-1″ 로 기록한다.

### §4.5 확정 — 허용 DML (backfill)

| # | 조작 | 정의 | 근거 |
|---|---|---|---|
| **M-1** | 아래 §4.5.1 의 확정 구문 | **`tenants` 전 행에서 1:1 파생.** 리터럴 business data 금지 | `601702` §1.45 / **`601713` I-48** / Stage 7 확정 |
| **M-2** | `UPDATE catchmenu_hq.stores SET merchant_account_id = … FROM catchmenu_hq.merchant_accounts WHERE stores.tenant_id = merchant_accounts.tenant_id` | `stores.tenant_id` 경유 결정적 파생 | §1.26 — **§7.3 N-2′ (파생이며 직접 선언이 아니다)** |

**M-1 · M-2 가 허용 DML 의 전부다.**

#### §4.5.1 M-1 확정 구문 (Stage 7 Human 확정, 2026-08-23)

```sql
INSERT INTO catchmenu_hq.merchant_accounts (tenant_id, merchant_account_name)
SELECT id, tenant_name FROM catchmenu_hq.tenants;
```

**`tenant_name` 이 `NOT NULL` 이므로 deterministic 하다**(`601701` E단계 — `tenants.tenant_name text NOT NULL`).
**6판까지의 blocker N-3′(값 출처 미선언)는 이것으로 CLOSED 다** — §7.1.

> ⚠️ **초기값이며 영구 미러가 아니다.**
>
> ```text
> 이번 계약      backfill 시점의 tenant_name 을 초기값으로 복사한다
> 정하지 않음    이후 tenant_name 이 바뀌면 merchant_account_name 이 따라가는가
> ```
>
> **이후 동기화 정책은 0-A 에서 정하지 않는다**(`601702` §2.2).
> 이 계약은 두 컬럼 사이에 트리거·제약·view 를 만들지 않는다 — §4.4.3 **H-5** 로 이월.

> ⚠️ **M-1 · M-2 는 조건이 아니라 형태로 제한된다.**
>
> ```text
> 허용   INSERT … SELECT FROM tenants        원천 행에서 파생
> 금지   INSERT … VALUES (…)                 리터럴 주입
> ```
>
> `tenants` 가 0행이면 M-1 은 0행을 만든다 — §1.45 가 요구한 동작이다.

> ⚠️ **M-2 는 `trg_stores_updated_at` 을 발동시켜 `stores.updated_at` 을 갱신한다.**
> `601718` S-6 이 그 트리거가 실재함을 재확인했다(user-visible 1건).
> **rollback 으로 복원되지 않는다** — §7.3 N-4′.

## §4.6 판정 3 관련 — External Provider Mapping 명시적 금지 (`601710` §7 요구)

```text
금지   provider mapping table 생성
금지   외부 provider 전용 컬럼 추가 (기존 테이블 포함)
금지   provider contract 를 추정한 schema · 타입 · 제약 생성
금지   특정 벤더명을 담은 객체 생성 (TOSS / OKPOS / KICC / Smartcast 등)
금지   stores.id 를 외부 provider merchant id 와 동일시하는 제약 · 주석
금지   catchmenu_integrations / catchmenu_payment 의 기존 merchant 컬럼 5건을
       canonical identity 로 승격하는 FK · unique 제약 추가
금지   merchant_accounts 를 외부 provider 식별자와 연결하는 컬럼 · FK
금지   backfill 이 외부 provider 테이블의 값을 원천으로 삼는 것
```

**어휘가 겹친다.** `merchant_accounts`(CM-PLAT SaaS 계약 단위)와
`van_merchant_id` 등 5건(외부 결제 가맹점 식별자)은 같은 단어를 쓴다.
둘을 연결하는 것이 정확히 `601702` §1.43 이 금지한 provider identity 의 canonical 승격이다.

**M-1 의 원천은 `catchmenu_hq.tenants` 하나뿐이다.** `601716` TP-X-10 이 검사한다.

## §5 Forbidden Files

**§1 에 없는 모든 파일이 금지다.** 아래는 실수 가능성이 높은 것을 명시한 것이며 한정 목록이 아니다.

### §5.1 절대 금지

| # | 경로 | 사유 |
|---|---|---|
| X-1 | `sql/migrations/0168_create_operational_authority_foundation.sql` | `000701` §14.5 · `601710` §5 동결 |
| X-2 | `sql/migrations/0169_authority_owner_role_and_sole_representative_uniqueness.sql` | 동일 |
| X-3 | `sql/migrations/0000_*.sql` ~ `0167_*.sql` (기존 167개) | 동일. **`0034`/`0060`/`0082` 가 `stores` INSERT 를 포함하나 수정 대상이 아니다**(`601718` S-5 note) |
| X-4 | `sql/_excluded_from_local_replay/**` | 재생 제외 결정 파일 |
| X-5 | `sql/seed_yoonsul_menu.sql` · 기타 seed | §4.5 는 migration 내 backfill 만 허용 |
| X-6 | `sql/migrations/CHANGELOG.md` | 규약 상태 미결 — §7.2 B-6 |

### §5.2 상위 근거 문서

| # | 경로 | 사유 |
|---|---|---|
| X-7 | `601702_Register_Stage1_Business_Rules.md` | Human 전담. AI 수정 불가 |
| X-8 | `601705_…ERD.md` · `601710_Overview_…V2.md` · `601713_Logic_…V2.md` | 개정은 Stage 3/4 경로로만 |
| X-9 | `601716_…TestPlan.md` · `601717_…ChangeContract.md` | 개정은 Stage 6/7 경로로만 |
| X-10 | `601701` · `601703`~`601709` · `601711`·`601712` · `601714`·`601715` · `601718`·`601719` · **`601720`·`601721`** · **`601723`~`601735`** | Evidence / Register / Audit — 사후 수정 시 기준선 소멸. **C4-I5 처분 — `601720`/`601721`(환경 drift 게이트 근거) · `601725`/`601726`(C-1 사유 교체 근거) · Stage 6 검증 보고서 전건을 편입** |
| X-11 | `docs/000001_Md_Rules.md` · `docs/000701_…Pipeline.md` | 거버넌스 문서 |
| X-12 | `docs/…/600020_…Authority_Reset.md` | 권위 판정 전문 |
| X-13 | `docs/…/601500_operational_authority_foundation/**` | 권위보류 대역 |

### §5.3 범위 밖

| # | 경로 | 사유 |
|---|---|---|
| X-14 ~ X-17 | `apps/**` · `packages/**` · `catchmenu_app/**` · `tests/**` | 코드 참조 0건(`601711` P-5, `601718` S-5) |
| X-18 | `tools/**` | 검증 도구를 변경해 검사를 통과시키지 않는다 |
| X-19 | `supabase/**` | 런타임 설정 |
| X-20 | `.git/hooks/**` | 커밋 게이트 우회 금지 |
| X-21 | `data/**` · `scratch/**` · `sop/**` | 무관 |

## §6 Forbidden Operations

### §6.1 RPC — 명시적 금지 (4판 신설)

> **`601718`/`601719` 가 두 함수를 이름으로 특정했으므로, 금지도 이름으로 특정한다.**
> 이름 없는 「RPC 수정 금지」는 구현자가 「이건 수정이 아니라 정렬」이라고 읽을 여지를 남긴다.

| # | 금지 | 근거 |
|---|---|---|
| **FO-A** | **`catchmenu_common.provision_tenant` 의 생성·수정·삭제·재정의** | **`601710` §3 RPC 재작성 Out of Scope · `601702` §1.45 「provisioning 경로 구현은 0-A 범위 밖」.** 이월 항목 §4.4.3 H-1·H-2 |
| **FO-B** | **`catchmenu_hq.create_franchise_store` 의 생성·수정·삭제·재정의** | 동일. 이월 항목 §4.4.3 H-3 |
| **FO-B1** | **`create_franchise_store` 의 phantom `extra_metadata` 참조 교정** — 이 함수가 현재 실패한다는 사실이 수정 근거가 되지 않는다 | **`601710` §3 RPC 재작성 Out of Scope.** 이월 항목 §4.4.3 H-3a · §7.3 N-4″ |
| **FO-C** | 두 함수의 `stores` INSERT 컬럼 목록에 `merchant_account_id` 를 추가하는 행위 | FO-A · FO-B |
| **FO-D** | `catchmenu_common.onboard_tenant` · `catchmenu_store.update_business_hours` 수정 | `601718` S-4 가 특정한 `stores` UPDATE 경로 2건. 동일 사유 |
| **FO-E** | 두 INSERT 경로를 우회하는 신규 store 생성 함수·트리거 생성 | 우회는 수정과 같다 |

### §6.2 물리 조작

| # | 금지 | 근거 |
|---|---|---|
| FO-1 | Person 계열에서 신규 테이블 생성 (어떤 이름으로도) | §2 판정 |
| FO-2 | `DROP TABLE` | 동일 |
| FO-3 | `owners` 이름의 VIEW / MATVIEW 생성 | §2.5 |
| FO-4 | `CASCADE` 사용 | §1.39 / I-37 |
| FO-5 | RLS POLICY 생성·삭제 — `merchant_accounts` 포함 | §1.45 「Policy 0개」 · I-11 |
| FO-6 | `DISABLE` / `NO FORCE ROW LEVEL SECURITY` | I-10 / §1.45 |
| FO-7 | GRANT / REVOKE — 4 privilege 확대·축소, `merchant_accounts` 신규 부여 포함 | §1.45 |
| FO-8 | 클라이언트 도달 가능 role(`anon`/`authenticated`/`service_role`)에 권한 부여 | §1.45 |
| FO-9 | role 생성·삭제·속성 변경 (`catchmenu_authority_owner` 개명 포함) | §1.37 명시적 제외 |
| FO-10 | FK 참조 동작을 `NO ACTION` 이외로 변경 | I-3 |
| FO-11 | §4.5 M-1 · M-2 외의 모든 `INSERT` / `UPDATE` / `DELETE` | §4.5 |
| FO-12 | `stores.legal_entity_id` 에 대한 모든 DDL·DML | §3.1 |
| FO-13 | **`SET NOT NULL` — `stores.legal_entity_id` · `stores.merchant_account_id` 둘 다** | **§1.5 — 조건부가 아니라 이월** |
| FO-14 | `chk_lepr_role_type` · **`chk_stores_type`** 허용값 재정의 | 선언 없음. **`chk_stores_type` 완화는 N-8″ 의 두 번째 교정 경로이며 이 계약이 명시적으로 금지한다**(CW-I1 처분) |
| FO-15 | 함수 생성·수정·삭제 (SECURITY DEFINER 포함) | `601700` Readme §5. §6.1 이 그중 4건을 이름으로 특정 |
| FO-16 | `catchmenu_common.set_updated_at()` 수정·개명 | §1.37 명시적 제외. 114개 트리거 공유 |
| FO-17 | `catchmenu_meta.migration_history` 직접 조작 | 이력 보존 |
| FO-18 | `tenants` 에 대한 모든 DDL 및 UPDATE | §1.45 「순환 참조를 만들지 않는다」 |
| FO-19 | `stores` 에 `merchant_account_id` 외의 컬럼 추가·변경·삭제 | D-18 한정 |
| FO-20 | `stores` 의 기존 트리거 241건(internal 240 + user 1) 변경·비활성화 | `601718` S-6. backfill 중 트리거 우회 금지 |

### §6.3 범위 조작

| # | 금지 | 근거 |
|---|---|---|
| FO-21 | External Provider Mapping 물리 구현 | §4.6 |
| FO-22 | `merchant_accounts` 에 LegalEntity 참조 추가 | I-38 / §1.44·§1.23 |
| FO-23 | `merchant_accounts` 에 미채택·deferred 필드 추가 | I-39 |
| FO-24 | `merchant_companies` / `merchant_stores` 등 3층 구조 테이블 생성 | §1.25 / `601705` §4.6 |
| FO-25 | `merchant_accounts` 와 `tenants` 를 한 테이블로 합치기 | I-23 |
| FO-26 | economic ownership 모델 생성 | §1.39 |
| FO-27 | Store 상태 3축 enum · 상태 컬럼 생성 | `601710` §3 |
| FO-28 | `OperatingGroup` / `company` / `business_unit` / `cross_business_link` 물리화 | `601710` §3 |
| FO-29 | Store–LegalEntity 시점 이력 테이블 생성 | §3.4 |
| FO-30 | 금전 객체 LegalEntity snapshot 컬럼 생성 | `601710` §2.3 — §1.35 원칙 전용 |
| FO-31 | Tenant 이전 절차·데이터 처리 객체 생성 | `601710` §2.3 — §1.36 원칙 전용 |
| FO-32 | 감사 이력 테이블 · 감사 트리거 생성 | `601713` §5 |
| FO-33 | Staff / User / Session / Role / Permission 객체 변경, `tenant_status`/`isolation_state` 조작, tenant `ACTIVE` 승격 | §1.18·§1.19 / `601505` §4 |

### §6.4 절차 조작

| # | 금지 | 근거 |
|---|---|---|
| FO-34 | Stage 7 승인 전 migration 적용 또는 커밋 | `000701` §10 · §6.11.1 |
| FO-35 | `-- Workpacket: 601700` 헤더 누락 — 두 파일 모두 | `000701` §6.11.1 |
| FO-36 | 검증 도구를 수정해 검사를 통과시키는 행위 | X-18 |
| FO-37 | 구현자가 자기 구현을 감사·승인하는 행위 | `000701` §37 |
| FO-38 | `0170`/`0171` 각각을 2개 이상으로 분할 | 중간 상태 커밋 금지 |
| FO-39 | `0171` 을 `0170` 보다 먼저 적용 | 적용 순서 고정 |
| FO-40 | 과거 migration 파일에서 `owner_` 를 제거하려는 시도 | §1.37 「검증 범위」 명시적 제외 · §14.5 |

## §7 Blocker

### §7.1 해소된 것 (기록 보존)

| # | blocker | 해소 근거 |
|---|---|---|
| B-1 | `MerchantAccount` 목표 물리 형태 | `601702` §1.44 |
| B-2a / B-2b | 트리거명 / `owner_name` | `601702` §1.37 보강 → D-5 · D-4 |
| B-3 / B-4 | `is_active` / `ownership_percent` 충돌 | `601713` I-36 · I-37 |
| B-6(1판) / B-7(1판) | §1.43 vs §3.1 / §1.34~§1.44 미반영 | `601710` §2.3 / `601713` I-34~I-42 |
| N-1(2판) | MA→Store enforcement 원인 | `601702` §1.45 backfill |
| N-2 / N-3 / N-4 / N-6 | posture / 소관 순환 / 옛 서술 / 일자 | `601702` §1.45·§2.2·§5, `601713` 병기 |
| **N-5** | **`stores` 참조 함수 형태 미측정** | **`601718`/`601719` — `SELECT *`·`ROW_TYPE`·`NO_COLUMN_LIST` 전부 0건** |
| **N-1′** | **C-1 승격 가부 미판정** | **판정 가능해졌다. 결과는 §4.4 — 부적격이며 §1.5 로 이월** |
| **B-7** | **재적용 동작 요구사항 미선언** | **CLOSED by Stage 7 Decision (2026-08-23)** — clean baseline replay 만 요구(§10.2) |
| **B-8** | **검증 환경 미지정** | **CLOSED by Stage 7 Decision (2026-08-23)** — `postgres:17.6.1.140` / `0169` / `tenants`=1 · `stores`=1 (§10.3) |
| **N-3′** | **backfill `merchant_account_name` 값 출처 미선언** | **CLOSED (2026-08-23)** — Stage 7 이 §4.5.1 구문을 확정. 출처는 `tenants.tenant_name`(`NOT NULL`). **동기화 정책은 H-5 로 이월** |
| **N-2″** | **`stores` 실제 컬럼 수 미확정** | **`601720`/`601721` PRE-6 — 라이브 16컬럼, `601701` 기록과 차이 0. `brand_id`·`extra_metadata` 둘 다 부재. 기준선 기록이 정확했고 RPC 가 phantom 을 참조한다** |
| **N-5′** | **§1.45·§1.37 보강이 ERD/Overview/Logic 에 미반영** | **`601713` I-43~I-51 · §1.1 주석 · §1.5 write-path 승계 · §6 Q-10 / `601710` §2.3·§2.4 / `601705` §4.1·§4.4·§8·O20** |

> **N-1′ 이 "해소"인 것은 판정 불능 상태가 끝났다는 뜻이다.**
> **C-1 자체는 해소되지 않았다** — §1.5 를 보라.

### §7.2 남아 있는 것 — 처분 유효성 재확인

| # | Blocker | 처분이 여전히 유효한가 | 이 계약의 처리 |
|---|---|---|---|
| **B-5** | Store–LegalEntity 시점 관계 물리 구조 미정 | **유효.** `601710` §4 분기·확장 실측 부재 모두 변동 없음 | FO-29. §3.4 |
| **B-6** | `CHANGELOG.md` 규약 상태 미결 | **유효.** 변동 없음 | X-6 |
| **B-9** | 문서 정합화 시점 미정 | **DEFERRED by Stage 7 Decision (2026-08-23).** 현 0-A Stage 8 에서 27~30건 문서를 수정하지 않는다. 물리 구현 + Verification/Audit 완료 후 **별도 Documentation Vocabulary Reconciliation** 으로 처리한다 | §1.2 는 색인 3종만 허용. **정합화 전까지 해당 문서군의 legacy `owners`/`owner_id` 표현을 새 나선의 canonical 근거로 사용하지 않는다** |
| **N-2′** | `stores` backfill 이 §1.45 의 직접 선언이 아니다 | **유효.** §1.45 문언은 MerchantAccount 생성만 다루고, **신설된 I-47~I-51 도 `stores` backfill 을 다루지 않는다**(I-48 은 `merchant_accounts` 행 생성만) | M-2 로 허용하되 파생임을 명시. Stage 7 확인 |
| **N-4′** | backfill UPDATE 의 `stores.updated_at` 부작용 | **유효.** `601713`/`601710`/`601705` 갱신분 어디에도 이 부작용에 대한 서술이 없다 | §9.1 R-6 비가역 지점 |

### §7.3 새로 생긴 것

| # | Blocker | 사실 관계 | 이 계약의 처리 |
|---|---|---|---|
| **N-1″** | **backfill 이후 신규 provisioning 부터 1:1 invariant 가 다시 깨진다.** 5판에서 **선언에서 Logic 불변조건으로 승격**됐다 | `provision_tenant` 는 `merchant_accounts` 를 만들지 않는다(`601718` S-2 — INSERT 대상은 `stores` 뿐). backfill 은 **기존** Tenant 만 덮는다. **`601713` I-47** 이 「Tenant 만 존재하고 MerchantAccount 가 없는 상태를 정상 운영 상태로 허용하지 않는다」를 불변조건으로 두었으나, **이번 구현에는 그것을 강제할 장치가 없다** | §4.4.3 H-1 로 이월. FO-A 로 이번 계약에서의 수정을 금지. §8.3 이 검증자에게 해석을 전달 |
| **N-3″** | **`601710` §2.4 의 「§2.2 미결」 상호참조가 모호하다** | 151 vs 158 차이를 미결로 기록한 것은 **`601702` §2.2** 인데, `601710` §2.4 는 문서명 없이 「§2.2」로 적었다. `601710` 자신의 §2.2 는 `MerchantAccount` 절이다 | 이 계약은 `601702` §2.2 로 읽는다. **문면 정정은 Stage 4 소관**(X-8) |
| **N-4″** | **`catchmenu_hq.create_franchise_store` 가 현재 호출 시 실패한다** | INSERT 주 경로가 부재 컬럼 `extra_metadata` 를 참조한다(`601718` S-2 INSERT 전문 / `601720`·`601721` PRE-6 컬럼 부재). **이 나선이 만든 결함이 아니며 이 나선이 고칠 수도 없다** — `601710` §3 RPC 재작성 Out of Scope | FO-B1 로 교정 금지. §4.4.3 **H-3a** 로 후속 RPC alignment 나선에 이월. `601716` **TP-RT-08** 이 **실패 양상 불변**을 검사 (**F-6 처분** — 종전 TP-RT-03 인용은 오인용) |
| **N-5″** | **`catchmenu_common.onboard_tenant` 의 `stores.brand_id` phantom 참조가 재측정되지 않았다** | `601718` S-4 / `601719` S-4 가 `update catchmenu_hq.stores set brand_id = v_brand_id` 를 전문과 함께 기록했고, `601720`/`601721` PRE-6 이 `stores.brand_id` **부재**를 확정했다. 그러나 두 사전 측정의 `prosrc` 토큰 검사는 **두 INSERT RPC 만** 대상으로 했고 `onboard_tenant` 는 범위 밖이었다 | 이 계약은 **판정하지 않는다.** `onboard_tenant` 는 FO-D 로 이미 수정 금지이며, `601716` TP-N-53 이 `prosrc` 불변을 검사한다 |
| **N-6″** | **`catchmenu_common.provision_tenant` 가 `tenants` 의 phantom 컬럼 3건을 참조해 첫 단계에서 실패한다** | `owner_name` · `owner_email` · `owner_phone`. `0002` 가 세 컬럼 없이 `catchmenu_hq.tenants` 를 만들었고 `0082` 가 `provision_tenant` 최초 정의에서 그대로 참조했다 — **처음부터 phantom**. `tenants` INSERT 가 첫 단계이므로 `stores` INSERT 에 도달하지 못한다 (`601725` / `601726` 이중 실측) | **후속 RPC alignment. §4.4.3 H-1 의 prerequisite — N-8″ 와 함께 둘 다다**(R2-F4 · CW-B3). 이번 계약은 FO-A 로 수정을 금지하며 판정하지 않는다. **C-1 사유 교체의 근거** — §4.4.1.2 |
| **N-7″** | **`catchmenu_common.onboard_tenant` 가 `tenants.business_number` phantom 참조와 인자명 불일치를 갖는다** | pre-check 가 `tenants.business_number` 를 참조하나 라이브 스키마에 부재. `provision_tenant` 호출 시 `p_company_name`/`p_business_number`/`p_ceo_name` 등 **라이브 시그니처에 없는 named argument** 를 전달한다(`0112` 유래). `601725` E-5 / `601726` | 동상. FO-D 로 이미 수정 금지. **N-5″(`brand_id`)와 같은 함수의 별개 결함** |
| **N-8″** | **`provision_tenant` 의 `store_type='RESTAURANT'` 가 `chk_stores_type` 허용값 밖이다** | `0002` `chk_stores_type` 허용값은 `DINE_IN` / `TAKEOUT` / `HYBRID` / `DELIVERY_ONLY`. **`601725` §H unresolved facts #4**(R2-F7 처분). ⚠️ **단일 출처이며 그 출처가 「not verified whether constraint unchanged at runtime」로 자기 표시했다** — `601726` 은 이 항목을 다루지 않았다. **`000701` §35 이중 검증 미충족**(CW-I2 처분) | 동상. **N-6″ 때문에 이 지점에 도달하지 않으므로 현재 표면화되지 않는다.** 재측정은 후속 RPC alignment 나선 착수 시점에 수행한다 — 이 계약은 재측정을 요구하지 않는다. §4.4.3 H-1 prerequisite 에 N-6″ 와 함께 연결됨(R2-F4) |

> **N-2″ 를 이 계약이 판정하지 않는 이유**
>
> 두 가능성의 결과가 완전히 다르다.
>
> ```text
> 컬럼이 실재한다        601701 E단계 기록이 불완전하다 — 기준선 문서의 정확성 문제
> 컬럼이 없다            두 RPC 가 phantom 컬럼을 참조한다 — 런타임 결함
> ```
>
> 이 프로젝트에는 **phantom 컬럼 참조로 RPC 가 실패한 실제 이력**이 있다
> (`sql/migrations/CHANGELOG.md` 2026-07-18 — `0160`~`0164` 가 `order_sessions` phantom 컬럼을 교정).
> **가능성을 배제할 근거가 없으므로 판정하지 않고 기록한다.**
>
> 어느 쪽이든 이번 계약의 허용 범위는 바뀌지 않는다 —
> `stores` 에 컬럼 하나를 추가할 뿐이고 FO-A·FO-B 가 두 RPC 수정을 금지한다.
> **바뀌는 것은 검증 기대값뿐이다.**
> **철회 (2026-08-23, F-3 처분)** — 위 「판정하지 않는다」는 **더 이상 유효하지 않다.**
> `601720`/`601721` PRE-6 이 **라이브 16컬럼 · `brand_id`·`extra_metadata` 부재**를 확정했으므로
> 두 가능성 중 **두 번째(RPC 가 phantom 을 참조한다)로 결정**됐다 — §0.1.2 · §7.1 N-2″.
> BL-21 before=16 / after=17 은 이미 그 확정값을 상수로 쓰고 있다.
> 위 문단은 **6판 이전의 사실 기록으로 보존**한다.

> **C-1·C-2 는 blocker 표에 없다. §1.5 에 있다.**
> 이월은 미해결이 아니라 **판정된 상태**이며, 그 판정이 `DEFERRED — INELIGIBLE` 이다.

### §7.4 Stage 6 검증자 결론 불일치 (2026-08-23)

```text
601723 Cursor   blocking 0건 — NO CONCERNS FOUND
601724 Codex    blocking 5건 / 고유 findings 7건
```

**같은 계약·같은 authority 를 읽고 결론이 갈렸다.**

Claude 통합 결과 **Codex 의 F-1·F-3·F-4·F-5·F-6·F-7 을 실재 findings 로 채택**했다.
따라서 Cursor 의 `NO CONCERNS FOUND` 는 **검증 누락**이다.

> ⚠️ **이 불일치를 기록으로 남긴다.**
> 단일 검증자였다면 어느 쪽을 골랐느냐에 따라 계약이 그대로 Stage 7 로 갔거나
> 5건이 잡혔다. `000701` §35 이중 검증의 근거다.

**Round 2 (2026-08-23)**

```text
Cursor        발견 5 / blocking 0
Codex         발견 7 / blocking 5
Antigravity   V11~V14 만 수행. 발견 0
```

**두 라운드 연속 같은 패턴이다.**

| 검증자 | 관찰된 특성 |
|---|---|
| Cursor | 경계·범위 정합성에 강함. 국소 교차참조·실행가능성 모순 탐지율 낮음 |
| Codex | TestPlan ↔ ChangeContract 세부 교차대조, 허용/금지 동사 잔존, 실행 불가능한 기대값에 민감 |
| Antigravity | 지정 범위(V1~V10)를 수행하지 않음. 결과가 비교 대상이 아님 |

> ⚠️ **이 관찰을 검증자 제거 근거로 사용하지 않는다.**
> 향후 Stage 6 verifier prompt specialization 의 근거로 사용한다(`000701` §38.4).

**Round 2 — Cowork (2026-08-23)**

```text
범위       V11~V14 + 전면
발견       blocking 5 / non-blocking 10 / 명시적 PASS 8
특성       지시서와 현물의 판본 불일치를 수행 전 확인 (§0.1)
           수정 완결성 추적 — 한쪽 문서만 고친 것을 3건 탐지
```

> ⚠️ **Cowork 은 11판(R2 수정 반영본)을 읽었다.**
> Cursor·Codex 는 10판을 읽었다.
> **따라서 Cowork 결과는 사실상 Round 3 findings 다.**

**Round 3 (2026-08-23) — 검증 방법 분화 적용**

```text
Cursor (A1~A7)   발견 4 / blocking 0
Codex  (B1~B7)   발견 5 / blocking 2
```

> ⚠️ **acceptance rule 이 작동했다.**
> Codex blocking 이 Round 2 의 5건에서 2건으로 줄었고,
> 남은 둘은 Rule 1 · Rule 3 에 정확히 해당한다.
>
> ⚠️ **두 검증자 모두 11판을 읽었다.**
> CW 수정이 12판을 만들었으므로 R3-I1 · R3-I2 는 이미 해소된 상태였다.
> **Round 4 는 판본을 명시해 지시한다.**

### §7.5 Stage 6 findings 처분

**`601724` Codex — 고유 findings 7건**

| # | 유형 | 지점 | 처분 | 반영 위치 |
|---|---|---|---|---|
| **F-1** | document conflict | D-15 ↔ `601716` TP-P-29 | **채택.** 계약 허용 형태를 `ADD CONSTRAINT … UNIQUE` **하나로 좁혔다.** `CREATE UNIQUE INDEX` 는 허용에서 제외 | §1.4 D-15 / `601716` TP-P-29 |
| **F-2** | too broad / missing test | D-13 · D-21 COMMENT literal 부재 | **채택.** 허용 comment literal 을 D-13·D-21 에 명시하고 대응 검사를 신설 | §1.3 D-13 · §1.4 D-21 / `601716` TP-P-23 · **TP-P-38** |
| **F-3** | document conflict | N-2″ 「확정」 ↔ 「판정하지 않는다」 병존 | **채택.** `601720`/`601721` 이 확정했으므로 **미판정 서술을 철회 병기**. 종전 문단은 사실 기록으로 보존 | §7.3 N-2″ 주석 / `601716` §12.3 |
| **F-4** | document conflict | B-8 「CLOSED」 ↔ 「여전히 미해소」 병존 | **채택.** Stage 7 승인 항목 8 이 CLOSED 로 확정했으므로 **미해소 서술을 정정** | `601716` §2.2 |
| **F-5** | forbidden leakage | TP-RT-03 ↔ FO-33 · TP-N-58 | **채택.** TP-RT-03 을 **폐기하고 negative 검사로 대체** | `601716` §10 · §12.1 |
| **F-6** | document conflict | N-4″ 가 TP-RT-03 인용 | **채택.** **TP-RT-08** 로 정정 | §7.3 N-4″ |
| **F-7** | too narrow | §9.2 요약에 H-5 누락 | **채택.** §9.2 후속 RPC alignment 행에 **H-5 추가** | §9.2 |

**`601723` Cursor — informational 3건**

| # | 지점 | 처분 |
|---|---|---|
| 1 | I-18·I-19·I-21·I-22·I-25·I-26·I-31·I-32 에 명시 Test ID 없음 | **범위 한정으로 유지.** `601716` §14·§0.2 가 schema/backfill 로 범위를 한정했고 FO/negative 가 우회 구현을 막는다. 운영·정책 축의 positive 검증은 이 나선의 대상이 아니다. **신규 조치 없음** |
| 2 | TP-P-08 이 `updated_at` 트리거 **존재**만 검사 | **유지.** 갱신 **동작** 검증은 DML 실행을 요구하며, 이번 계약의 허용 DML 은 M-1·M-2 뿐이다(FO-11). 동작 검증은 후속 나선 소관. **신규 조치 없음** |
| 3 | §12.4 「Stage 7 APPROVED」 ↔ PRE-1 「대기」 | **의도적 병기로 유지.** §10 배너가 pre-decision 보존과 효력 부재를 구분한다. 9판 §0.3 이 같은 취지를 기록했다. **신규 조치 없음** |

> **Cursor informational 3건은 전부 「신규 조치 없음」이다.**
> 처분하지 않은 것이 아니라 **검토하고 유지 판정한 것**이다.

### §7.6 Stage 6 Round 2 findings 처분 (2026-08-23)

> **finding 위치만 고치지 않는다.**
> R2-F1 이 그 증거다 — 1차 F-1 이 D-15 에서 `CREATE UNIQUE INDEX` 를 제외했으나
> **§1.6 허용 동사 목록에 그대로 잔존**했다.
> **같은 권한·같은 literal·같은 Test ID 가 등장하는 모든 지점을 함께 정합화한다.**

| # | 지점 | 처분 | 정합화한 전 지점 |
|---|---|---|---|
| **R2-F1** | `CREATE UNIQUE INDEX` 잔존 | **채택.** 허용 형태를 `ALTER TABLE … ADD CONSTRAINT … UNIQUE` **하나로 통일** | §1.4 D-15 · **§1.6 허용 동사 목록** · §4.2 부속 객체 #1 / `601716` TP-P-29 |
| **R2-F2** | COMMENT exact literal 미확정 | **채택.** **§4.2.1 신설** — 4건의 exact literal 을 SQL 구문으로 고정 | §1.3 D-13 · §1.4 D-21 · **§4.2.1** · §9.3 S-13 / `601716` TP-P-23 · TP-P-38 |
| **R2-F3** | TP-N-63 이 관측 장치를 요구 | **채택.** `601716` 에서 **정적 증거로 재정의**. 종전 정의는 폐기 기록으로 보존 | `601716` §5.9 TP-N-63 · §10 주석 |
| **R2-F4** | H-1 Prerequisite 이 N-6″ 만 연결 | **채택.** **N-8″ 도 연결.** phantom 3건만 고치면 다음 단계에서 다시 막힌다 | §4.4.3 Prerequisite · §7.3 N-8″ |
| **R2-F5** | AC 에 TP-D-09 · H-3a 누락 | **채택.** AC-10 에 **H-3a** 명시 | §9.4 AC-10 / `601716` AC-4 · AC-12 |
| **R2-F6** | 재도출 요약의 Test ID 범위가 구판 | **채택(non-blocking).** 현 판 범위로 갱신 | `601716` §0.3 |
| **R2-F7** | `601725 §-4` 가 검증 불가능한 인용 | **채택(non-blocking).** **`601725` §H unresolved facts #4** 로 정정 | §7.3 N-8″ |

> ⚠️ **R2-F1 이 이 라운드의 교훈이다.**
> 1차에서 D-15 만 고치고 §1.6 을 놓쳤다.
> **허용 동사는 §1.4 표와 §1.6 목록 두 곳에 산다.** 한 곳만 고치면 계약이 스스로 모순된다.

### §7.7 Cowork Round 2 findings 처분 (2026-08-23)

> **수정 완결성 절차를 이 라운드부터 강제한다.**
>
> ```text
> 1차   F-1 고침    → §1.6 허용 동사에 잔존
> 2차   R2-F1 고침  → §1.6 ADD CONSTRAINT 범위가 D-15 를 배제
> 3차   R2-F1 고침  → 세 번째 형태 잔존 (CW-B1)
>       R2-F4 고침  → 601716 에 미전파 (CW-B3)
> ```
>
> **전부 「고친 자리 옆」과 「다른 문서」를 안 본 결과다.**
> 이후 각 finding 은 **개념·literal·Test ID·blocker ID 를 두 문서 전수 grep** 한 뒤
> 지점별 처리(수정/유지/유지 사유)를 기록한다.

**Blocking 5건**

| # | 지점 | 처분 | 정합화한 전 지점 |
|---|---|---|---|
| **CW-B1** | `tenant_id` UNIQUE 의 세 번째 형태(인라인) 잔존 — D-14 ↔ D-15 충돌 | **채택.** 채택 형태를 `ALTER TABLE … ADD CONSTRAINT uq_merchant_accounts_tenant UNIQUE (tenant_id)` **하나로 확정** | §4.1 정의 블록 · §4.1 매핑표 · §1.4 D-15 · §1.6 · §4.2 #1 / `601716` §4.3 표 · TP-P-29 |
| **CW-B2** | `provision_tenant` 「정상 / 호출 가능」 서술 잔존 | **채택.** 3개 지점에 **철회 병기**. 삭제하지 않았다 | §0.1.2 표 · §4.4.1 판정 근거 표 · §4.4.1.1 블록 / `601716` §0.1.2 표 |
| **CW-B3** | R2-F4 가 `601716` 에 미승계 | **채택.** N-6″ 단독 연결 지점을 **N-6″ · N-8″ 로 전수 정합화** | §9.2 / `601716` §5.9 · §10 주석 · §12.3 N-6″ 행 |
| **CW-B4** | TP-N-63 ③ 이 없는 산출물을 인용 | **채택.** ③ **제거**. ①② 만 남긴다 — 없는 산출물을 만들지 않는다 | `601716` §5.9 TP-N-63 · §10 주석 · §12.6 |
| **CW-B5** | TP-RB-03/R-5 ↔ TP-RB-06/R-6 — 항상 FAIL | **채택. R-6 · TP-RB-06 이 옳다**(N-4′ — `updated_at` 은 비가역). **R-5 · TP-RB-03 에서 BL-26 을 명시적으로 제외** | §9.1 R-5 / `601716` TP-RB-03 |

**Non-blocking 10건 — 전건 처분**

| # | 항목 | 처분 |
|---|---|---|
| **CW-I1** | N-8″ 의 두 번째 교정 경로(`chk_stores_type` 완화)가 명명 금지되지 않음 | **채택.** **FO-14 에 `chk_stores_type` 추가** — 완화로 N-8″ 를 「해소」하는 경로를 막는다 |
| **CW-I2** | N-8″ 근거가 단일 출처이며 출처가 스스로 미검증 표시 | **채택(기록).** N-8″ 행에 **「단일 출처 · `000701` §35 이중 검증 미충족」을 명기.** **재측정은 이 계약이 요구하지 않는다** — N-6″ 때문에 도달 불가라 현재 표면화되지 않으며, 후속 RPC alignment 나선 착수 시점에 수행한다 |
| **CW-I3** | TP-RT-08 의 판별력 주장이 실현 불가능 | **채택(기록).** `601716` TP-RT-08 에 **판별력 한계를 병기.** 두 경로가 모두 실행 불가이므로 「원인이 옮겨갔는지」를 실행으로 가릴 수 없다. 기대값 자체는 유지 |
| **CW-I4** | TP-RT-03 대체 매핑 서술이 부정확 | **채택.** `601716` §10 주석의 매핑 서술을 정정. **검증 공백은 없다**는 사실도 함께 기록 |
| **CW-I5** | Round 2 Cursor 5건 처분 행 없음 / R2-F1~F7 귀속 미기재 | **부분 채택.** R2-F1~F5(blocking)는 **Codex 귀속**으로 명기 — Round 2 blocking 보고자는 Codex 뿐이다. **R2-F6·F7 귀속과 Cursor 5건 내용은 보고서가 repo 에 보존되지 않아 기록할 수 없다.** Round 3 부터 **검증자 보고서를 `docs/` 대역에 보존**할 것을 요구한다 |
| **CW-I6** | R2-F7 정정이 `601716` 에 미전파 | **채택.** `601716` §12.3 N-8″ 행의 인용을 **`601725` §H unresolved facts #4** 로 정정 |
| **CW-I7** | `601716` 헤더 `Last Updated` 가 개정 이력보다 뒤처짐 | **채택.** `2026-08-23` 으로 갱신 |
| **CW-I8** | 개정 이력 행 순서 미정렬 | **유지.** 재배열은 과거 기록의 배치를 바꾸는 것이며 정보 이득이 없다. 각 행이 판번호·일자를 자체 표기하므로 판독 가능하다. **신규 조치 없음** |
| **CW-I9** | 폐기 행이 활성 시험 표 안에 잔존 | **유지.** 삭제 금지(기록 보존)와 충돌한다. 폐기 행은 `~~취소선~~` + **폐기** 표기로 구분되며 §13 Acceptance Criteria 가 폐기 행을 요구하지 않는다. **신규 조치 없음** |
| **CW-I10** | `CREATE INDEX` 가 `CREATE UNIQUE INDEX` 를 배제하는지 불명 / 추가 인덱스 negative 부재 | **채택.** §1.6 에 **배제를 명시**하고 `601716` 에 **TP-N-65**(선언되지 않은 추가 인덱스 미생성) 신설 |

> ⚠️ ~~**CW-I5 의 잔여분은 절차 문제이지 계약 문제가 아니다.**
> Round 2 Cursor·Codex 보고서가 `tools/` 아래 임시 파일로만 존재하고
> `601723`/`601724` 처럼 워크패킷 문서로 보존되지 않았다.
> **이 계약은 `tools/**` 를 X-18 로 금지 대역에 두었으므로 그것을 근거 문서로 인용할 수 없다.**
> Round 3 검증 보고서는 `docs/` 대역 워크패킷 번호로 보존해야 한다.~~

> 🛑 **정정 (2026-08-23, C4-B2)**
>
> ```text
> Round 2 verification artifacts 는 이 처분이 기록되기 전에
> docs/ 대역에 보존되고 3종 색인에 등록되어 있었다 — 601727~601730.
> "보존되지 않아 기록 불가" 라는 종전 서술은 사실과 다르다.
>
> 원인
>   현재 색인 상태를 다시 확인하지 않고 stale context 로 처분을 기록했다.
> ```
>
> **종전 서술은 삭제하지 않고 취소선으로 보존한다.**
>
> | 시각 | 사건 |
> |---|---|
> | 08:55 | `601727`(Cursor) · `601728`(Codex) · `601729`(Antigravity) 생성 |
> | 09:15~09:16 | `601730`(Cowork) · `601731`·`601732`(Round 3) 생성. **Readme §8 · `000005` · `000007` 3종 색인 등록 완료** |
> | 09:39 / 09:41 | `601717` / `601716` **13판 기록** — 위 사실을 확인하지 않았다 |
>
> 근거: `601700` Readme §8 File List L156-159 · `601735` §4.2.

> ⚠️ **이 유형을 기록으로 남긴다.**
>
> **문서가 없어서 판단하지 못한 것이 아니라,
> 문서는 있었는데 최신 상태를 다시 보지 않고 「없다」고 판단했다.**
>
> ```text
> N-2″ · N-4″ · N-6″ · CW-B2   catalog 존재 ≠ 호출 가능      을 섞은 결과
> CW-I5 잔여분                  기록 부재 ≠ 확인 부재         를 섞은 결과
> ```
>
> **수정 완결성 절차(전수 grep)가 문서 내부를 대상으로 하듯,
> 처분의 사실 전제도 기록 시점에 다시 확인해야 한다.**

#### §7.7.1 Round 2 Cursor 발견 5건 처분 (C4-B2, 2026-08-23)

**`601727` Findings 표를 근거로 이제 기록한다.** 전건 non-blocking 이었다.

| # | 유형 | 지점 | 내용 | 처분 |
|---|---|---|---|---|
| **R2C-1** | document conflict | `601717` §4.4.1 · §0.1.2 | §4.4.1.2·N-6″ 가 `provision_tenant` 실행 불가로 갱신했으나 **구 표는 「정상/호출 가능」 유지** | **해소됨 (12판, CW-B2).** 같은 잔존을 4지점에서 취소선 처리 |
| **R2C-2** | document conflict | `601716` §0.1 | `provision_tenant` 「phantom 없음 · 정상」이 `601725`·N-6″·§5.9 와 불일치 | **해소됨 (12판, CW-B2).** §0.1 요약 갱신 |
| **R2C-3** | missing test | `601716` AC-6 / `601717` §8.2 V-13 | TP-RT-03 폐기 후 대체 TP-N-62~64 가 AC-6·V-13 에 **명시되지 않음** | **채택.** `601716` AC-6 · 본 계약 §8.2 V-13 에 **TP-N-62~64 를 명시**한다 — 아래 병행 조치 |
| **R2C-4** | missing test | `601716` §4 | I-18~I-32 등 운영·정책 불변조건에 **명시 Test ID 없음** | **유지.** 이 계약의 검증 범위는 schema·backfill 이며, I-18~I-32 는 관계·격리 원칙으로 물리 검사 대상이 아니다. `601716` §12.5 가 이미 커버 범위를 한정한다. **신규 조치 없음** |
| **R2C-5** | document conflict | `601716` §10 | TP-RT-03 폐기 후에도 「성공해야 한다」 종전 서술 보존 | **유지.** 폐기 행에 `~~취소선~~` + 폐기 사유가 있고 기록 보존 원칙과 충돌한다. **CW-I9 와 동일 처분** |

> **R2-F1~F5(blocking)의 보고자는 Codex(`601728`)다.** CW-I5 처분의 그 부분은 유효하다.
> **R2-F6·F7 귀속도 `601728` 로 확인된다** — 「기록할 수 없다」는 전제가 거짓이었으므로 함께 정정한다.

### §7.8 Round 3 findings 처분 (2026-08-23)

**Blocking 2건**

| # | Rule | 지점 | 처분 | 정합화한 전 지점 |
|---|---|---|---|---|
| **R3-F1** | Rule 1 — 계약대로 한 구현이 FAIL 할 수 있다 | TP-R-14 · TP-R-15 가 「FUNCTION 전부 유효」를 기대. **모집단에 known phantom 함수가 포함된다**(`provision_tenant` · `create_franchise_store` · `onboard_tenant`) | **채택.** 「유효」라는 단어를 버리고 **catalog 존재/본문 불변** 과 **runtime executability** 를 분리 | `601716` TP-R-14 · TP-R-15 · §6 주석 · AC-7 / **§8.2 V-19** |
| **R3-F2** | Rule 3 — 자동 생성명과 명시명이 모두 계약을 만족 | FK · UNIQUE · index · PK 이름이 계약에 없어 구현자가 선택하게 된다 | **채택.** **§4.2.2 신설** — 5개 이름을 exact expectation 으로 확정 | §4.1 정의 블록 · §4.2 1a · §1.4 D-19 · D-20 · **§4.2.2** / `601716` TP-P-26 · 27 · 34 · 35 · 36 · TP-N-65 · §4.3 |

> ⚠️ **R3-F1 의 원칙을 계약 전반에 적용한다.**
>
> ```text
> catalog 에 존재한다   ≠   호출 가능하다
> ```
>
> **이번 워크패킷에서 발견된 문제 상당수가 이 둘을 섞은 결과다**
> — N-2″ · N-4″ · N-6″ · CW-B2 가 전부 같은 혼동에서 나왔다.
> 두 개념을 쓰는 다른 Test 에도 같은 분리를 적용한다.

**Informational — 이미 해소된 것 2건**

| # | 내용 | 상태 |
|---|---|---|
| **R3-I1** | TP-N-63 ③ 이 존재하지 않는 산출물을 인용 | **CW-B4 로 해소 (2026-08-23).** ③ 이 이미 제거됐다 — §7.7 |
| **R3-I2** | §9.2 가 H-1 prerequisite 을 N-6″ 만으로 적음 | **CW-B3 로 해소 (2026-08-23).** N-8″ 가 이미 추가됐다 — §7.7 |

> ⚠️ **해소된 것을 다시 고치지 않았다.**
> `601731`/`601732` 는 **11판**을 읽었고 CW 수정이 12판을 만들었다.
> 두 항목 모두 12판에서 이미 처리된 상태였으므로 **해소 사실만 기록한다.**

**Informational — 처분 1건 + Cursor 4건**

| # | 항목 | 처분 |
|---|---|---|
| **R3-I3** | 운영·정책 축 불변조건에 명시 Test ID 없음 | **유지.** `601716` §12.5 가 이미 범위 한정 사유를 기록한다 — §14·§0.2 가 schema/backfill 로 범위를 한정했고 FO/negative 가 우회 구현을 막는다. **신규 조치 없음** |
| **Cursor A3 · A7 (4건)** | informational | **전건 유지 판정.** A3·A7 은 허용 범위·Stage 게이트 정합성을 확인한 항목이며 blocking 이 아니다. 지적된 내용은 §7.5~§7.7 의 기존 처분과 중복되거나 범위 한정으로 이미 설명된다. **신규 조치 없음** |

### §7.9 Round 4 findings 처분 (2026-08-23)

**대상 판본**: `601716` / `601717` **13판**. 세 검증자 전원이 같은 판본을 읽었다 — Round 3 의 판본 시차가 재발하지 않았다.

**Blocking 3건**

| # | Rule | 지점 | 처분 | 정합화한 전 지점 |
|---|---|---|---|---|
| **C4-B1** | Rule 1 — 계약대로 한 구현이 FAIL 할 수 있다 | `fk_merchant_accounts_tenant_id` 는 이름만 확정되고 **어떤 허용 DDL 도 이 객체를 만들지 않는다.** §1.6 `ADD CONSTRAINT` 는 D-15·D-19 한정, §4.2 1a 는 D 항목이 아니다 | **채택.** **D 번호를 늘리지 않고 D-14 안에 명시** — `CREATE TABLE` 정의에 명명된 `merchant_accounts_pkey` PK 와 `fk_merchant_accounts_tenant_id` FK 를 포함(**§1.4.1 신설**) | §1.4 D-14 · **§1.4.1** · §1.6 · §4.1 정의 블록 · §4.1 CW-B1 주석 · §4.1 매핑표 · §4.2 1a · §4.2.2 / `601716` TP-P-27 · §4.3 |
| **C4-B2** | 전제 확인 | CW-I5 잔여분 처분의 전제(「보고서가 보존되지 않아 기록 불가」)가 **13판 기록 시점에 이미 거짓**이었다 | **채택.** 종전 서술을 **삭제하지 않고 취소선 + 정정 병기.** **§7.7.1 신설** — Round 2 Cursor 5건(R2C-1~R2C-5)을 `601727` 근거로 처분 | §7.7 CW-I5 주석 · **§7.7.1** · §8.2 V-13 / `601716` AC-6 |
| **C4-I1** | Rule 3 — **blocking 승격** | `CREATE TRIGGER` 는 이름이 필수 인자다. §4.2.2 「물리 객체명 **전부**」가 트리거명을 빠뜨렸고 TP-P-32 가 이름을 검사하지 않았다 | **채택.** D-16 을 확정 구문으로 좁히고(**§4.2.3 신설**) **§4.2.2 를 6개로 확장** | §1.4 D-16 · §4.2 #2 · §4.2.2 · **§4.2.3** / `601716` TP-P-32 · §4.3 |

**C4-B3 는 이 계약의 대상이 아니다.** `601700` Readme 의 authority state 충돌이며 **Correction A 로 처리됐다.**

**Informational — 전건 처분**

| # | 내용 | 처분 |
|---|---|---|
| **C4-I2** | R3-F1 이 스스로 지시한 「두 개념을 쓰는 다른 Test 에도 같은 분리를 적용한다」가 §10 Runtime Behavior Tests 에 미이행 | **채택.** `601716` TP-RT-01·02·04·05 에 **「전후 비교」임을 문면에 명기**하고 절 하단에 분리 원칙 주석 추가. 검증 방법도 「실행이 아니라 catalog·정의 대조」로 명시 |
| **C4-I3** | CW-I3 정정이 TP-RT-08 행에만 반영되고 같은 절 하단 주석에 무표기 잔존 | **채택.** `601716` 해당 문장에 **취소선 + 철회 표기.** 판별은 TP-N-40·TP-N-42(정적 검사) 소관임을 병기. **삭제하지 않는다** |
| **C4-I4** | 「자동 생성명은 FAIL」이 `merchant_accounts_pkey` 에는 성립하지 않는다 | **채택.** §4.2.2 주석과 `601716` §4.3 주석에 **PK 예외를 병기** — 「자동 생성명이면 FAIL」이 아니라 「이 문자열과 일치하면 PASS」 |
| **C4-I5** | §5.2 X-10 · §11 근거 목록이 `601720`·`601721`·`601723`~`601732` 를 담지 않는다 | **채택.** X-10 에 `601720`·`601721`·**`601723`~`601735`** 편입. §11 에 Round 1~4 검증 보고서와 `601725`/`601726` 추가. `601716` TP-B-07 동일 확장 |
| **C4-I6** | §4.4.3 Prerequisite 은 필요조건만 진술 — N-7″ 가 열린 채로는 유일한 in-DB 호출 경로가 막혀 있다 | **채택(기록).** Prerequisite 아래에 **필요조건임을 명시**하고 호출 경로 사실을 병기. **N-7″ 를 Prerequisite 으로 승격하지 않는다** — 범위 결정은 후속 나선 소관 |
| **C4-I7** | `601733`·`601734` 미존재(보고 시점) / `601735` 3종 색인 미등록 | **해소됨 (2026-08-23).** 세 보고서 모두 `docs/` 대역에 존재하며 3종 색인 등록 완료 — 이 계약은 §11 · X-10 으로 근거·금지 목록에 편입했다 |

> ⚠️ **C4-I6 은 Cowork 자신의 정정이다.**
> `601730` §3 V13 에서 같은 Prerequisite 을 **충분조건 미달**로 읽었던 것을
> **과했다고 스스로 낮춰 informational 로 재분류**했다(`601735` §5.6).
> **검증자가 자기 이전 판정을 낮춘 기록**이며, 이 계약은 그 사실을 그대로 보존한다.

### §7.4.1 Stage 6 Verifier Divergence Observation (Round 4 시점)

```text
Round 2   Cursor blocking 0 / Codex blocking 5 / Cowork blocking 5
Round 3   Cursor blocking 0 / Codex blocking 2
Round 4   Cursor blocking 0 / Codex blocking 0 / Cowork blocking 3
```

**관찰된 패턴**

```text
Cursor   broad boundary / scope 검토에서 finding 을 냈으나
         blocking 으로 승격한 사례가 없었다

Codex    TestPlan ↔ ChangeContract 내부 실행 정합성,
         허용/금지 조작의 교차모순을 반복적으로 발견했다

Cowork   계약 두 문서 내부뿐 아니라 Readme 같은 인접 authority surface 와
         이전 finding disposition 의 사실 전제까지 확장해 재검증하면서
         별도 blocking findings 를 발견했다
```

> ⚠️ **이것은 관찰이며 항구적 능력 순위가 아니다.**
>
> **어떤 검증자도 이 워크패킷만으로 제거되지 않는다.**
> 결과는 향후 verifier prompt 와 method 를 분화하는 데 사용한다(`000701` §38.4).
>
> **C4-B3 는 다른 두 검증자가 `601716`/`601717` 만 읽어
> 볼 수 없었던 결함이다.** 능력 차이가 아니라 **입력 범위의 차이**다.

## §8 Required Verification

### §8.1 착수 직전 게이트

| # | 항목 | 미충족 시 |
|---|---|---|
| V-1 | §10 Stage 7 이 승인 상태 | 착수 금지 |
| V-2 | §7 blocker 중 착수 범위에 걸린 것이 해소 또는 명시적 제외됨 | 해당 범위 제외 |
| V-3 | `601716` §2.1 기준선 재측정 완료. **기준 환경은 `postgres:17.6.1.140` / migration `0169`**(Stage 7 항목 8) | 착수 금지 |
| V-4 | `tenants` 행 수 = **1** 확인 | 불일치 시 **environment drift 로 중단** |
| V-5 | **`stores` 컬럼 수 = 16 · 두 RPC `prosrc` md5 일치 확인** (`601720`/`601721` PRE-6·PRE-7) | 불일치 시 **environment drift 로 중단** |
| V-6 | 검증 환경이 `postgres:17.6.1.140` 임을 확인 — **B-8 은 Stage 7 이 CLOSED** | 다른 환경이면 착수 금지 |
| V-7 | §4.1 컬럼명·타입 — **2026-08-23 Stage 7 확정 완료.** 구현 직전 이 계약의 §4.1 과 Approval 문면이 일치하는지 대조 | 불일치 시 착수 금지 |
| V-8 | N-2′(`stores` backfill 이 파생임)이 Stage 7 에서 확인됨. **N-3′ 는 CLOSED** | 해당 범위 제외 |
| V-9 | 구현자가 상위 문서·본 문서의 원작자가 아님 | 배정 재조정(`000701` §37) |
| V-24 | **`601716`·`601717` 의 SHA-256 이 §10.8 기록값과 일치** — **측정 전 `git ls-files --eol` 로 `w/lf` 확인 — §10.9 대조 절차 0단계** | 불일치 시 **착수 금지** — 승인한 계약과 읽는 계약이 다르다 |

### §8.2 구현 후 검증

| # | 항목 | 대응 Test ID |
|---|---|---|
| V-10 | negative 검증 전건 | `601716` §5 |
| V-11 | backfill 이 선언된 파생인가 — 행 수 일치·고아 0·리터럴 0 | TP-D-01~TP-D-07 |
| V-12 | **`NOT NULL` 을 선행 강제하지 않았는가** | **TP-N-40 · TP-N-25** |
| V-13 | **두 INSERT RPC 가 수정되지 않았는가** | **TP-N-50 ~ TP-N-53** · **TP-N-62 ~ TP-N-64**(TP-RT-03 폐기 대체 — R2C-3 처분) |
| V-14 | External Provider Mapping negative — 특히 TP-X-10 | `601716` §7 |
| V-15 | `merchant_accounts` 컬럼 수 일치 · LegalEntity 참조 0건 · 순환 참조 없음 | TP-N-21 · TP-N-16 · TP-N-22 |
| V-16 | fail-closed posture | TP-P-33 · TP-N-11 · TP-N-13 |
| V-17 | §1.37 경계 준수 — `set_updated_at()`·role 명 불변 | TP-N-07 · TP-N-08 |
| V-18 | `catchmenu_hq` BASE TABLE 수 / `set_updated_at()` 트리거 수 | TP-R-01 · TP-R-02 |
| V-19 | **`stores` 참조 158개 함수의 존재·본문 기준선 불변** — **runtime executability 를 주장하지 않는다**(R3-F1) | TP-R-14 |
| V-20 | `stores` 의 `merchant_account_id`·`updated_at` 외 컬럼 불변 | TP-N-49 |
| V-21 | `0168`/`0169` checksum 동일 | TP-R-16 |
| V-22 | 허용 파일 목록 준수 | TP-B-01 · TP-B-02 |
| V-23 | G15 — `-StrictStage7` 포함, 두 파일 모두 | TP-M-02 · TP-M-03 |

### §8.3 이중 검증 (`000701` §35)

구현자(Codex)를 제외한 **2개 이상의 독립 행위자**가 §8.2 를 각각 수행한다.

> **4판의 N-5′ 경고는 철회한다.**
> `601713` I-43~I-51 과 §1.5 write-path 승계, `601710` §2.3·§2.4, `601705` §4.1·§4.4·§8·O20 이
> 반영되어 **Logic 만 읽은 검증자도 backfill·트리거명 변경을 범위 안으로 읽는다.**
>
> ⚠️ **대신 I-47 의 해석을 전달한다.**
> 「Tenant 만 존재하고 MerchantAccount 가 없는 상태를 허용하지 않는다」는
> **검증 시점 상태 검사(TP-D-02)로 확인되며, 강제 장치가 없다는 사실은 §7.3 N-1″ 다.**
> I-47 을 「강제되어야 한다」로 읽고 FAIL 판정하면 이월 결정을 뒤집는 것이 된다.

## §9 Rollback Policy · 경계 · 구현자 지시 경계

### §9.1 Rollback Policy

| # | 규칙 |
|---|---|
| R-1 | rollback 은 **역방향 신규 migration** 으로만 수행한다 |
| R-2 | rollback 순서는 **`0171` 역 → `0170` 역** |
| R-3 | `0171` 역 순서는 **stores FK/컬럼 제거 → `merchant_accounts` 행 제거 → 테이블 제거** |
| R-4 | Person 계열 rollback 대상 데이터는 없다(4테이블 0행). 위험은 **RLS·GRANT 조합의 비대칭 복원** |
| R-5 | rollback 후 `601716` §2.1 기준선 before 값이 복원되어야 한다 — **단 BL-26(`stores.updated_at`)은 제외한다**(R-6 · CW-B5 처분). 그 한 항목을 제외하지 않으면 R-5 는 예외 없이 실패한다 |
| R-6 | **`stores.updated_at` 은 복원되지 않는다.** M-2 가 갱신한 이전 값은 보존되지 않는다 — N-4′ |
| R-7 | rollback 판단은 Human 이 한다 |

### §9.2 Boundary With Related Workpackets

| 워크패킷 | 경계 |
|---|---|
| `601500` (1차 0-A) | 권위보류. `601505` §4 금지는 0-A-2 완료까지 유효(FO-33) |
| `601600` (역전파) | 권위보류. 판정은 `600020` §5 로 대체 |
| 0-A-2 | `tenant_status` / `isolation_state` — FO-33 |
| 0-B (Identity/Login/Session) | Staff / User / Session. `primary_owner_user_id` 새 어휘 |
| 0-C (Role/Permission/Authorization) | `merchant_accounts` 의 application access policy — §1.45 가 명시적 이관 |
| **후속 RPC alignment 나선 (번호 미정)** | **§4.4.3 H-1~H-5.** `provision_tenant` / `create_franchise_store` 정렬 후 `stores.merchant_account_id` NOT NULL 재판정. **H-5(name synchronization) 포함**(F-7 처분). **H-1 의 prerequisite 은 N-6″ phantom 컬럼 정합화 + N-8″ `chk_stores_type` 위반 해소 둘 다다**(R2-F4 · CW-B3 처분). `601700` Readme §5 가 RPC 재작성을 파생 나선 소관으로 둔다 |
| Business Registration Intake 나선 (번호 미정) | §3 C-2. `010901` §11 intake 확보 후 `stores.legal_entity_id` NOT NULL 재판정 |
| Provider Integration (번호 미정) | External Provider Mapping — §4.6 |
| Franchise OS | `FranchiseAgreement` — §1.10 |

### §9.3 Codex Instruction Boundary

```text
Stage 7 미승인 — §10 배너(2026-08-23)가 Stage 7 을 무효화했다. Stage 8 을 착수하지 않는다.
Module 자기보고서 파일명은 601722_Module_Operational_Authority_Foundation_V2.md 다. 번호를 바꾸지 않는다.
허용 파일 §1.1·§1.2 / 허용 DDL §1.3·§1.4 / 허용 DML §4.5 / 허용 동사 §1.6.
merchant_accounts 의 컬럼명·타입은 §4.1 의 Stage 7 확정 정의를 그대로 쓴다.
계정 명칭 컬럼은 merchant_account_name 이다. account_name 을 쓰지 않는다.
backfill 구문은 §4.5.1 의 확정 SQL 을 그대로 쓴다.
NOT NULL 을 걸지 않는다 (§1.5 · FO-13).
provision_tenant / create_franchise_store / onboard_tenant / update_business_hours 를
어떤 형태로도 수정하지 않는다 (§6.1).
불확실하면 중단하고 묻는다. 추론으로 범위를 넓히지 않는다.
Codex 는 자기 구현을 스스로 감사하거나 승인하지 않는다.
```

**중단 조건**

| # | 중단 조건 |
|---|---|
| S-1 | `601716` §2.1 기준선 재측정값이 before 값과 다르다 |
| S-2 | 허용 목록 밖 파일을 건드려야 한다는 판단이 든다 |
| S-3 | rename 만으로 Person 목표 상태에 도달할 수 없다 |
| S-4 | `merchant_accounts` 에 §4.1 의 확정 5컬럼 외 필드가 필요하다 — §4.1 제외 목록 포함 |
| S-5 | `stores` 에 `merchant_account_id` 외의 변경이 필요하다 |
| S-6 | backfill 값을 `tenants` 외의 원천에서 가져와야 한다. **또는 §4.5.1 구문을 바꿔야 한다** |
| S-7 | backfill 결과 행 수가 `tenants` 행 수와 다르다 |
| S-8 | **두 INSERT RPC 중 하나라도 고쳐야 한다는 판단이 든다** — **`create_franchise_store` 의 phantom 교정 포함**(FO-B1) |
| S-9 | **`NOT NULL` 을 걸어야 검증이 통과한다는 판단이 든다** |
| S-10 | **`stores` 재측정 컬럼 수가 16이 아니다** (`601720`/`601721` PRE-6) |
| S-11 | §7 의 blocker 중 하나가 구현 도중 범위에 걸린다 |
| S-12 | provider / external / mapping 관련 객체를 만들어야 한다는 판단이 든다 |
| S-13 | **§4.2.1 의 COMMENT literal 을 문구 수정해야 한다는 판단이 든다** — 다듬는 것도 수정이다(R2-F2) |

### §9.4 Acceptance Criteria

| # | 조건 |
|---|---|
| AC-1 | §8.1 V-1~V-9 충족 |
| AC-2 | 변경 파일이 §1 허용 목록의 부분집합 |
| AC-3 | §5 금지 파일 변경 0건 |
| AC-4 | §6 금지 조작 0건 — **§6.1 RPC 4건 무변경 포함** |
| AC-5 | §4.5 외의 DML 0건 |
| AC-6 | **`SET NOT NULL` 0건** |
| AC-7 | `601716` §13 Acceptance Criteria 충족 |
| AC-8 | §8.3 이중 검증 수행. **N-5′ 경고는 철회됐고, 대신 I-47 해석이 검증자에게 전달됨** |
| AC-9 | §7 blocker 중 미해소분이 Stage 7 Approval 에 **제외 사실로 명시**되어 있다 |
| AC-11 | **`merchant_accounts` 가 §4.1 확정 정의와 정확히 일치한다** — 5컬럼, 컬럼명 `merchant_account_name`, FK `NO ACTION`, 제외 목록 0건 |
| AC-12 | **H-5(name synchronization)가 Approval 에 이월로 명시되어 있다** |
| AC-10 | **§1.5 의 C-1·C-2 가 `DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT` 로, §4.4.3 의 H-1~H-5(**H-3a 포함**)가 이월 항목으로 Approval 에 명시되어 있다** — **H-3a 는 H-3 의 선행 조건이므로 누락 시 후속 나선이 순서를 잃는다**(R2-F5 처분) |

> **AC-10 이 이번 판에서 가장 중요한 수용 조건이다.**
> C-1 이 `RESOLVED` 로 기록되면 **NOT NULL 요구가 폐기된 것으로 읽힌다.**
> 실제로는 요구가 살아 있고 이번 계약에서 적용할 수 없을 뿐이며,
> **H-1~H-4 를 수행할 후속 나선이 그 요구를 이어받는다.**

## §10 Approval State

> 🛑 **2026-08-23 무효화 — Stage 6 미수행**
>
> **이 절의 Stage 6 완료 표기와 Stage 7 승인은 효력이 없다.**
>
> | 항목 | 상태 |
> |---|---|
> | Stage 5 | **PROCEDURAL REPAIR REQUIRED** — actor provenance 이상 |
> | Stage 6 | **NOT COMPLETED** — 독립 Contract Verification 미수행 |
> | Stage 7 | **NOT EFFECTIVE** — Stage 6 이 전제(`000701` 1258행) |
> | Stage 8 | **MUST NOT START** |
>
> **무효 사유**
>
> 1. `000701` §9.16 이 요구하는 독립 Contract Verification 이 수행되지 않았다.
>    `601718`~`601721` 은 write-path·baseline evidence 이며 계약 검증이 아니다.
> 2. `000701` 1258행 — 계약은 Stage 6 검증과 Human 승인을 모두 거쳐야 binding 이다.
> 3. 8판이 지시 없이 Stage 6 을 「대기」에서 「완료」로 변경했다.
>    검증자·산출물·판정이 없다.
> 4. Stage 5 작성자가 Claude 였다. `000701` Stage 5 는 Claude Code 를 지정한다.
>    `000001` §5.4.2 는 2026-07-16 이전 번호 체계다(`000701` 1096행).
>    그 결과 Claude 가 원작자가 되어 Stage 6 통합자 역할을 수행할 수 없다.
> 5. `000701` §9.20 이 요구하는 Claude 의 원문 직접 검토가 수행되지 않았다.
>
> **§10.1 의 Human 승인 결과 9건은 유효하다.**
> Human pre-decision 으로 보존하며, 절차 정상화 후 재승인 시 그대로 승계한다.
> **다시 논쟁하지 않는다.**
>
> **복구 순서**
>
> ```text
> Stage 5 재도출        Claude Code — verified design 에서 독립 재도출
>                       현 601716/601717 은 candidate reference
>          ↓
> Stage 6               Cursor + Codex 독립 검증 (Critical tier)
>                       Eyes-Only. 수정 권한 없음
>          ↓
> Claude 통합           두 보고서 disposition 기록
>                       + §9.20 원문 직접 재검토
>          ↓
> Stage 6 COMPLETE      검증자·산출물·판정 명시
>          ↓
> Stage 7 재승인        §10.1 9건 승계
>          ↓
> Stage 8               Codex 구현
> ```
>
> **1차 0-A(`601500`)는 Stage 6·7 미수행 상태로 Stage 8~12 를 통과했다**
> (`600020` §1.1 사유 1). **이번에는 구현 파일 생성 전에 멈췄다.**
> `0170`/`0171` 은 존재하지 않으며 물리적 변경은 발생하지 않았다.
>
> ✅ **2026-08-23 — 무효 사유 5건 전건 해소**
>
> | # | 무효 사유 | 해소 |
> |---|---|---|
> | 1 | 독립 Contract Verification 미수행 | Round 1~5 수행. `601723`·`601724`·`601727`~`601738` |
> | 2 | 계약이 binding 이 아님 | Stage 6 COMPLETE 로 binding 성립 — §10.7 |
> | 3 | Stage 6 을 검증자 없이 「완료」로 변경 | 검증자·산출물·판정을 §10.7 에 명시 |
> | 4 | Stage 5 작성자 provenance 이상 | Claude Code 재도출 완료(9판). Claude 는 통합자로 복귀 |
> | 5 | §9.20 원문 직접 검토 미수행 | 수행 완료 — blocking 0. §10.7 기록 |
>
> **이 배너는 무효화 이력으로 보존한다. 삭제하지 않는다.**
>
> ⚠️ **위 표의 Stage 상태는 2026-08-23 무효화 시점의 것이다.**
> **현재 상태는 아래 Stage 표와 §10.7 을 따른다.**

| 단계 | 상태 |
|---|---|
| Stage 4 (ERD / Overview / Logic, Claude Code) | 완료 — `601705` / `601710` / `601713`. §1.37 보강 · §1.45 · write-path 실측 전부 반영됨 (N-5′ 해소) |
| Stage 5 (Contract Drafting) | **완료** — Claude Code 재도출 (2026-08-23). 종전 Claude 작성분은 candidate reference |
| Stage 6 (Contract Verification) | COMPLETE (2026-08-23) — Round 5 에서 3검증자 blocking 0. §9.20 원문 직접 검토 blocking 0. 상세는 §10.7 |
| Stage 7 (Human Approval) | 대기 — Stage 6 종료로 재효력화 가능. §10.1 판단은 pre-decision 으로 승계한다 |
| Stage 8 (Implementation, Codex) | MUST NOT START — Stage 7 미효력 |

### §10.1 승인 범위 — 항목별 결과 (2026-08-23, 정영석)

> ⚠️ **아래는 2026-08-23 Human pre-decision 이다.**
> Stage 6 정상화 후 재승인 시 **그대로 승계**하며 다시 논쟁하지 않는다.
> 다만 **현 시점에서 Stage 7 승인 효력은 없다** — 위 무효화 배너 참조.

| # | 항목 | 결과 |
|---|---|---|
| 1 | 허용 파일 목록 | **APPROVED** — A-1·A-2 파일명 유지. **A-3 은 `601722_Module_Operational_Authority_Foundation_V2.md` 로 확정**(§1.2). A-4~A-6 as written |
| 2 | C-1 · C-2 | **APPROVED** — `DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT`. **`RESOLVED` 아님** |
| 3 | H-1 ~ H-5 | **APPROVED** — 후속 RPC alignment 나선 이월. **워크패킷 번호 미확정** |
| 4 | `merchant_accounts` 컬럼 정의 | **확정 완료 (2026-08-23)** — §4.1 (7판 반영분) |
| 5 | N-2′ / N-3′ / H-5 | **APPROVED** — N-2′ 확인 · **N-3′ CLOSED** · H-5 이월 |
| 6 | N-2″ / N-4″ / N-5″ | **APPROVED** — N-2″ 확정 · N-4″·N-5″ 이월 |
| 7 | blocker 처분 | **APPROVED** — **B-7 CLOSED** · **B-9 DEFERRED** · 나머지 as documented (§10.2) |
| 8 | 검증 환경 | **APPROVED** — **B-8 CLOSED** (§10.3) |
| 9 | I-47 해석 | **APPROVED** (§10.4) |

### §10.2 항목 7 — B-7 CLOSED / B-9 DEFERRED

**B-7 — replay 요구사항 확정**

```text
0170 / 0171 은 동일 DB 에 반복 실행 가능한 idempotent migration 일 필요가 없다.

요구되는 replay:
  깨끗한 baseline DB 에서 0000…0169 → 0170 → 0171 전체 순차 재생 성공

지원 대상 아님:
  이미 0170/0171 이 적용된 동일 DB 에서 migration 본문을 다시 직접 실행
```

`0170` 의 rename 은 동일 DB 재실행에 적합하지 않다.
**`601716` TP-M-08 의 「재적용(replay)」 표현을 「clean baseline replay」로 좁혔다** —
현 문구가 「같은 DB 에서 두 번 실행」으로 읽힐 여지가 있었기 때문이다.

**B-9 — 문서 정합화 이월**

```text
현 0-A Stage 8 구현에서 27~30건 문서를 수정하지 않는다.
물리 구현 + Verification/Audit 완료 후
별도 Documentation Vocabulary Reconciliation 으로 처리한다.

그 정합화가 끝나기 전에는 해당 문서군의
legacy owners / owner_id 표현을 새 나선의 canonical 근거로 사용하지 않는다.
```

### §10.3 항목 8 — 검증 환경 고정

```text
Implementation / Verification reference environment

PostgreSQL image   postgres:17.6.1.140
latest migration   0169
baseline           tenants = 1 / stores = 1

PRE-5 / PRE-6 / PRE-7 이 601720 / 601721 과 일치해야 한다.
불일치하면 구현하지 않고 environment drift 로 중단한다.
```

> ⚠️ **`601714`/`601715`(`.156`)의 증거를 폐기하는 것이 아니다.**
> 그 조사가 답한 Q-2~Q-5·Q-8 은 유효하다.
> **`0170`/`0171` 구현 및 사후 PASS/FAIL 기준이 `.140` 이라는 뜻이다.**

### §10.4 항목 9 — I-47 해석

```text
PASS 조건        검증 시점에 MerchantAccount 없는 Tenant = 0
요구하지 않음     향후 신규 Tenant 에 대한 runtime enforcement
강제 부재        N-1″ / H-1 후속 소관. 현재 Verification FAIL 사유 아님
```

### §10.5 승인이 뜻하지 않는 것

| # | 승인되지 않은 것 |
|---|---|
| 1 | **C-1 · C-2 의 `NOT NULL` 적용** — 이월이며 FO-13 이 계속 금지한다 |
| 2 | **두 INSERT RPC 및 `onboard_tenant` · `update_business_hours` 수정** — §6.1 FO-A~FO-E 가 계속 금지한다 |
| 3 | **`create_franchise_store` 의 phantom 교정** — FO-B1. H-3a 로 이월 |
| 4 | **§1 허용 목록 밖의 어떤 파일·조작** — §5·§6 이 계속 금지한다 |
| 5 | **후속 RPC alignment 나선의 착수** — 워크패킷 번호도 확정되지 않았다 |
| 6 | **B-5 · N-1″ · N-2′ · N-4″ · N-5″ 의 해결** — 이월이거나 미판정이다 |

> **승인은 §1 이 열거한 파일과 경계 안에서만 유효하다**(`000001` §5.4.6).
> Approval 과 이 계약이 충돌하면 **더 엄격한 경계가 이긴다.**

### §10.6 문서 형식에 관한 기록

이 워크패킷은 별도 `Approval` 문서(`000001` §5.4.6)를 만들지 않고
**`601700` Readme §10 이 정한 대로 ChangeContract §10 에 승인 상태를 기록**한다.
`tools/Check-Governance.ps1` G15 도 이 위치를 읽는다(`000701` §6.11.1).

> 본 문서 상단 메타데이터의 `Runtime Implementation Authorization: Not Granted` 는
> **`000001` §5.4.5 가 정한 ChangeContract 문서 규격**이며,
> ChangeContract 자체는 구현을 승인하지 않는다는 뜻이다.
> **실제 착수 권한은 위 §10 Stage 7 행과 §10.1 이 정한다.**

> ⚠️ **Stage 8 착수 전 최종 확인**
>
> ```text
> 1. §8.1 V-1 ~ V-9 전건 충족
> 2. 환경이 postgres:17.6.1.140 · migration 0169 · tenants 1 · stores 1
> 3. 두 RPC prosrc md5 가 601720/601721 기록값과 일치
> 4. 구현자가 상위 문서·본 문서의 원작자가 아님 (000701 §37)
> ```
>
> **하나라도 어긋나면 구현하지 않고 중단한다.**

### §10.7 Stage 6 종료 기록 (2026-08-23)

```text
Stage 6 — Contract Verification
COMPLETE

Contract author
  Claude Code — excluded from verifier pool (000701 §37)

Canonical verifiers (Critical tier, 000701 §9.16)
  Cursor
  Codex

Supplemental independent verifier
  Cowork
  — 000701 §9.16 이 정의한 actor 가 아니다.
    이번 워크패킷의 기록으로만 남기며 SOP actor 정의를 바꾸지 않는다.

Verification method
  Differentiated per 000701 §38.4

Round 5 result
  Cursor    blocking 0 / informational 5
  Codex     blocking 0 / informational 0
  Cowork    blocking 0 / informational 10

Claude integration
  COMPLETE

§9.20 direct source review
  COMPLETE — blocking 0
  범위: 601717 §1 · §6 · §8 · §9 · §10 전문
        601716 §0.2 · §5.9 · §6
  교차 검증: TP-R-01/02/06 기준선, §1.6 허용 동사 ↔ D 항목,
             물리 객체명 6건 귀속, §9.3 ↔ §10 배너 정합

Disposition
  READY_FOR_STAGE_7_HUMAN_APPROVAL
```

**라운드별 경과**

| Round | Cursor | Codex | Cowork | 주요 발견 |
|---|---|---|---|---|
| 1 | 0 | 5 | — | 허용 동사 잔존 · MerchantAccount 물리 정의 부재 |
| 2 | 0 | 5 | 5 | TP-RT-03 이 금지 조작을 수행 · 수정 완결성 결함 3건 |
| 3 | 0 | 2 | — | 물리 객체명 미확정 · 「FUNCTION 전부 유효」 기대 |
| 4 | 0 | 0 | 3 | FK 생성 조작 부재 · Readme 권한 표기 · 처분 전제 오류 |
| 5 | 0 | 0 | 0 | — |

> **빈 라운드가 없었다.** Round 5 에서 처음 0 이 됐다.

**이번 Stage 6 에서 도입된 절차 3건**

```text
finding acceptance rule    blocking 을 「Stage 8 에서 다른 코드를 만들 수 있는가」로 한정
수정 완결성 전수 grep       finding 반영 시 「n곳 찾아 m곳 고쳤다」를 강제
검증자 입력·방법 분화       §38.4 적용. Round 5 에서 Cursor 입력에 Readme 추가
```

> ⚠️ **이 세 절차를 `000701` 에 반영하는 것은 후속 governance 과제다.**
> **승인 직전에 controlling rule 을 바꾸지 않는다** —
> 「이번 Stage 6 은 어느 판의 `000701` 을 따랐는가」가 새 문제가 된다.
>
> **효과는 아직 미증명이다.** 「다음 나선이 2라운드로 끝난다」고 단정하지 않는다.
> 정확히는 **같은 유형의 미완 수정·검증 범위 중복 때문에
> 5라운드까지 갈 가능성을 낮춘다**까지다.
> 0-B·0-C 에서는 다른 종류의 결함이 나올 수 있다.

### §10.8 Stage 7 승인 대상 판본 고정

**Stage 7 승인은 아래 판본에 대해 효력을 갖는다.**

| 문서 | 판본 | 고정 방식 | 값 |
|---|---|---|---|
| `601716_TestPlan_…V2.md` | 14판 + §12.9 | SHA-256 | `00C1376EB1230A4B68F27C1479681C5BC95B23A8801EE70364EAACF22719F102` |
| `601717_ChangeContract_…V2.md` | 15판 | git commit | `50f96e591e4c9bbb71e1d8bb3912f09fa843e015` 이후 최초 커밋 |

> ⚠️ **두 문서의 고정 방식이 다른 이유**
>
> ```text
> 601716   SHA-256 직접 기록
>          다른 파일이므로 자기 참조가 없다
>
> 601717   git commit hash
>          자기 SHA-256 을 적으면 적는 순간 값이 바뀐다
>          커밋은 자신의 변경까지 포함해 확정된다
> ```
>
> **`601717` 의 기준 커밋은 이 §10.8 을 채운 커밋이다.**
> `50f96e59…` 는 그 직전 커밋(Stage 6 COMPLETE)이며,
> **Stage 7 승인 시 Human 이 실제 커밋 해시를 §10.9 에 기록한다.**

> ⚠️ **승인 후 문서가 바뀌면 승인 효력이 그 변경분에 미치지 않는다.**
>
> Stage 6 중 판본이 11 → 12 → 13 → 14 로 계속 움직였고,
> Round 3 검증자 둘이 11판을 읽어 findings 2건이 헛돌았다.
>
> **구현자는 착수 직전에 두 문서의 SHA-256 을 대조한다.**
> 불일치 시 착수하지 않고 보고한다.

**해시 기록 절차**

```text
Stage 7 승인 직전   두 문서의 SHA-256 을 측정해 이 표에 기록한다
Stage 8 착수 직전   구현자가 재측정해 대조한다 (§8.1 게이트에 추가)
```

### §10.9 Stage 7 승인 시 기록할 것

**Stage 7 승인자는 아래를 이 절에 기록한다.**

```text
승인자
승인 일자
601717 기준 커밋 해시     git log -1 --format="%H" -- <601717 경로>
601716 SHA-256 재측정값   §10.8 기록값과 일치 확인
```

> ⚠️ **승인 기록 없이 Stage 8 을 착수하지 않는다.**
>
> `601717` §8.1 V-24 가 착수 직전에 이 값들과의 대조를 요구한다.
> 값이 비어 있으면 대조할 대상이 없고, 그것은 **승인이 어느 판본에 대한 것인지
> 확인할 수 없다는 뜻**이다.

**대조 절차 — 구현자**

```text
0  git ls-files --eol <601716 경로> 로 작업트리 EOL 을 확인한다
   w/lf 가 아니면 git checkout -- <경로> 로 정규화한 뒤 측정한다

1  601716 SHA-256 을 측정해 §10.8 값과 대조

2  git log -1 --format="%H" -- <601717 경로> 로 최종 변경 커밋을 확인

3  §10.9 에 기록된 승인 시점 커밋과 대조

4  불일치 시 착수하지 않고 보고한다 — 승인한 계약과 읽는 계약이 다르다
```

> ⚠️ **0단계를 건너뛰지 않는다.**
>
> `core.autocrlf=true` 환경에서는 체크아웃 시점에 작업트리가 CRLF 로 바뀐다.
> **§10.8 의 `601716` SHA-256 은 LF 상태에서 측정한 값이다.**
>
> ```text
> 저장소     항상 LF
> 작업트리   autocrlf 설정에 따라 LF 또는 CRLF
> ```
>
> **CRLF 상태에서 측정한 불일치는 문서 변경이 아니라 EOL 차이다.**
> 이 둘을 구분하지 못하면 정상 착수를 막거나,
> 반대로 실제 변경을 EOL 탓으로 넘길 수 있다.
>
> `601717` 은 커밋 해시로 고정하므로 이 문제를 겪지 않는다.

## §11 근거 문서 목록 (`000701` §46)

| 문서 | 인용 절 | 권위 | 역할 |
|---|---|---|---|
| `docs/000001_Md_Rules.md` | §5.4.1~§5.4.6, §5.4.10, §5.7, §5.11 | ACTIVE | ChangeContract 규격·저자 분리·충돌 처리 |
| `docs/000700_…/000701_…Pipeline.md` | §3, §6.11.1, §10, §14.5, §35, §37, §46, §47.1 | ACTIVE | Stage 게이트·불변 경계·이중 검증 |
| `docs/…/600020_Governance_…Authority_Reset.md` | §2, §5 | ACTIVE | `601500` 권위보류 |
| `docs/…/601700_Readme_…V2.md` | §4, **§5**, §10, §10.1 | 본 워크패킷 | RPC 재작성 파생 나선 소관 — §4.4.3 |
| `docs/…/601701_Register_Stage0_Evidence_Collection.md` | §4.5 D-3, E단계 | 본 워크패킷 | §4.1 파생 근거 · N-2″ |
| `docs/…/601702_Register_Stage1_Business_Rules.md` | §0, §1.2, §1.10, §1.18, §1.19, §1.22~§1.27, §1.31, §1.32, §1.34, §1.37(보강), §1.38, §1.39, §1.43, §1.44, §1.45, §2.2, §5 | 본 워크패킷 | **최우선 근거** — Human 선언 |
| `docs/…/601705_Diagram_…ERD.md` | **§4.1**, §4.4, §4.6, §5.2, **§8**, §10 (O5·O18·O19·**O20**) | 본 워크패킷 | 물리 정의 · Physical Drift · Open Decisions |
| `docs/…/601710_Overview_…V2.md` | §2, §2.1~§2.3, **§2.4**, **§3**, §3.1, §4, §5, §7 | 본 워크패킷 | 구현 대상 · write-path 실측 · RPC Out of Scope · 금지 조항 요구 |
| `docs/…/601711_…Cursor.md` / `601712_…Codex.md` | P-1 ~ P-5 | 본 워크패킷 | 물리 기준선(이중) |
| `docs/…/601713_Logic_…V2.md` | §1.1~§1.5 (**I-1~I-51**), §2~§6 (**Q-10 포함**) | 본 워크패킷 | 불변조건 · 예외 · 미해결. **I-43~I-51 이 5판의 직접 근거** |
| `docs/…/601714_…Cursor.md` / `601715_…Codex.md` | Environment, Q-2 ~ Q-8 | 본 워크패킷 | 갭 해소 실측(이중) |
| **`docs/…/601718_Evidence_Stores_Write_Path_Scan_Cursor.md`** | **Environment, S-1 ~ S-6** | **본 워크패킷** | **§4.4 판정의 직접 근거** |
| **`docs/…/601719_Evidence_Stores_Write_Path_Scan_Codex.md`** | **Environment, S-1 ~ S-6** | **본 워크패킷** | **동일(이중, `000701` §35)** |
| **`docs/…/601720_Evidence_Stage7_Pre_Measurement_Cursor.md`** | **Environment, PRE-5 · PRE-6 · PRE-7** | **본 워크패킷** | **N-2″ 확정 · §4.4.1.1 정밀화 근거** |
| **`docs/…/601721_Evidence_Stage7_Pre_Measurement_Codex.md`** | **환경, PRE-5 · PRE-6 · PRE-7** | **본 워크패킷** | **동일(이중, `000701` §35)** |
| **`docs/…/601723_Audit_Stage6_Contract_Verification_Cursor.md`** · **`601724_…_Codex.md`** | Findings 전건 | 본 워크패킷 | Stage 6 Round 1 — §7.6 처분 근거 |
| **`docs/…/601725_Evidence_Provision_Tenant_Schema_Consistency_Cursor.md`** · **`601726_…_Codex.md`** | §7 · §H | 본 워크패킷 | **C-1 부적격 사유 교체의 직접 근거** |
| **`docs/…/601727`~`601730` (Round 2: Cursor · Codex · Antigravity · Cowork)** | Findings 전건 | 본 워크패킷 | §7.7 처분 근거. **`601727` 은 §7.7.1 Round 2 Cursor 5건 처분의 근거** |
| **`docs/…/601731`·`601732` (Round 3: Cursor · Codex)** | Findings 전건 | 본 워크패킷 | §7.8 처분 근거 |
| **`docs/…/601733`·`601734`·`601735` (Round 4: Cursor · Codex · Cowork)** | Findings 전건 | 본 워크패킷 | **§7.9 처분 근거 (C4-B1 · C4-B2 · C4-I1~I7)** |
| `docs/…/601716_TestPlan_…V2.md` | 전체 | 본 워크패킷 | 검증 요건의 실체 |
| `sql/migrations/CHANGELOG.md` | 2026-07-18 항목(phantom 컬럼 사례) · 2026-08-07 항목 · Convention status | 프로젝트 파일 | B-6 · N-2″ |
| `tools/Check-Governance.ps1` | G15 | 프로젝트 파일 | §10 게이트 실행 주체 |

**권위보류 문서 인용 — 명시**

| 문서 | 인용 위치 | 어떻게 썼는가 |
|---|---|---|
| `601505` §4 | FO-33 · §9.2 | 금지 조항이 0-A-2 완료까지 유효하다는 **사실**만 인용 |

`601501`~`601512` 의 설계 결론을 정답으로 전제한 곳은 없다(`600020` §2).

---

## Final Rule

```text
This ChangeContract does not authorize implementation.
It defines candidate future boundaries only.
Codex may implement only after Human Approval explicitly lists allowed files.
```

> **7판은 §4.1 의 성격을 바꿨다.**
> 6판까지 §4.1 은 **이 계약의 파생 표현**이었고 Stage 7 확인 대상이었다.
> 이제 **Human 확정값**이며, 이 계약은 그것을 승계한다.
> `account_name` → `merchant_account_name` 은 이름 하나의 문제가 아니라
> **`<entity>_name` 관례를 지키고 PG·settlement account 와의 혼동을 막는 결정**이다.
>
> backfill 은 **초기값 복사**다. 영구 미러가 아니며, 그 구분이 H-5 로 남는다.
>
> **6판이 바꾼 것도 결론이 아니라 사유의 정밀도다.**
> `create_franchise_store` 가 이미 실패 상태라는 사실이 드러났지만,
> **살아 있는 생성 경로(`provision_tenant`)가 값을 공급하지 않는 한 부적격은 그대로다.**
> 경로가 둘에서 하나로 줄어든 것이 판정을 뒤집지 않는다.
>
> **5판이 바꾼 것은 결론이 아니라 근거다.**
> N-5′ 가 해소되어 §4 의 판정이 선언 단독이 아니라 **선언 + Logic 불변조건(I-43~I-51)** 위에 선다.
> 허용 범위·금지 목록·이월 항목은 하나도 바뀌지 않았다.
>
> **4판이 확정한 것은 그대로다 — C-1 은 `DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT` 다.**
>
> 측정이 질문을 닫았고, 닫힌 답이 「지금은 못 건다」였다.
> 사유는 데이터가 아니라 **신규 Store 생성 경로 2건이 값을 공급하지 않는다**는 것이며,
> 그 2건을 고치는 일은 `601710` §3 이 이 나선 밖에 두었다.
>
> ```text
> 이번 계약   기존 행에 값을 채운다        제약은 걸지 않는다
> 후속 나선   생성 경로가 값을 공급하게 한다  그때 제약을 건다
> ```
>
> **`RESOLVED` 로 적으면 두 번째 줄이 사라진다.**
> §1.5 와 §4.4.3 이 그 줄을 문서에 남기기 위해 존재한다.
>
> 승인 시 Approval 과 이 계약이 충돌하면 **더 엄격한 경계가 이긴다**(`000001` §5.4.6).
