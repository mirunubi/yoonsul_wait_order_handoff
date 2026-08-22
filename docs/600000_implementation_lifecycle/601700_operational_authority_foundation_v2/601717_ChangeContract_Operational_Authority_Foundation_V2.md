# 601717_ChangeContract_Operational_Authority_Foundation_V2.md

Status: Draft
Lifecycle: ChangeContract
Gate Classification: 0-A v2 Operational Authority Foundation Change Contract Draft
Runtime Implementation Authorization: Not Granted
Owner: Stage 2 (Claude) — 저자 분리(`000001` §5.4.2)
Last Updated: 2026-08-22

**개정 이력**

| 일자 | 내용 |
|---|---|
| 2026-08-22 | 초안 — 4단계 ChangeContract. 판정 4건 + Blocker 8건 |

## Change ID

```text
Workpacket    601700  Operational Authority Foundation V2 (0-A 재수행)
Change Scope  Person 어휘 정규화 물리 교정 (forward migration 1건)
Migration     0170  (신규 · 번호 미사용 확인: sql/migrations 최신 = 0169)
```

## §0 계약 요약

`000001` §5.4.5 ChangeContract 다. **구현을 승인하지 않는다.**
허용 후보 경계·금지 대상·필요한 Human 결정·검증 요건·rollback 을 정한다.

**저자 분리**(`000001` §5.4.2)

| 산출물 | 저자 |
|---|---|
| Overview `601710` / Logic `601713` | Claude Code |
| **TestPlan `601716` / ChangeContract `601717`** | **Claude (본 문서 저자)** |

이 계약은 Overview / Logic 을 **옹호하지 않는다.** 불충분한 지점은 §7 에 blocker 로 기록했다.
`601702` §1.37 이 물리 변경 방법 판정을, `601710` §4 가 enforcement 조건 판정을,
`601710` §7 이 provider mapping 금지 조항을 이 문서에 위임했다.

### §0.1 이 계약이 판정한 4건

| # | 판정 대상 | 결론 | 절 |
|---|---|---|---|
| 1 | `owners → persons` 물리 변경 방법 | **`ALTER … RENAME` 계열만 허용. 신규 생성 후 교체 금지. 호환 view 금지** | §2 |
| 2 | Store–LegalEntity `NOT NULL` enforcement eligibility | **부적격(NOT ELIGIBLE). 명시적 blocker 와 함께 이월** | §3 |
| 3 | 허용 파일 / 금지 파일 | §1 / §5 | §1·§5 |
| 4 | Stage 7 승인란 | §10 | §10 |

### §0.2 이 계약이 판정하지 않은 것

**Overview §2 의 구현 대상 5건 중 3건(2·3·4 — `MerchantAccount` 축)은 이 계약이 허용하지 않는다.**
금지해서가 아니라 **목표 물리 형태를 정한 문서가 없기 때문**이다(§7 B-1).
테이블명·컬럼·제약이 선언되지 않은 대상에 허용 DDL 을 쓰면,
그것은 계약이 아니라 이 문서가 만들어낸 새 설계다.

## §1 Allowed — 허용 대상

### §1.1 허용 파일 — 구현(Stage 8)

| # | 경로 | 성격 | 제약 |
|---|---|---|---|
| A-1 | `sql/migrations/0170_person_vocabulary_normalization.sql` | **신규 1개 파일** | 파일명은 제안이며 Stage 7 이 확정한다. 번호 `0170` 은 고정 |

**A-1 이 허용 파일의 전부다.** 다른 SQL 파일은 생성·수정·삭제 대상이 아니다.

### §1.2 허용 파일 — 문서 동기화 (Stage 10, 기계적)

`000001` §5.4.10 이 Codex 의 mechanical index synchronization 을 허용한다.
**행 추가만 허용하며 기존 행의 의미를 바꾸지 않는다.**

| # | 경로 | 허용 조작 |
|---|---|---|
| A-2 | `docs/.../601700_operational_authority_foundation_v2/601718_Module_*.md` | 신규 생성 (Stage 8 자기보고서) |
| A-3 | `601700_Readme_…V2.md` §8 File List | 행 추가 |
| A-4 | `docs/000005_Index_Document_Number.md` | 행 추가 |
| A-5 | `docs/000007_Map_Full_Directory.md` | 행 추가 |

> `000001` §5.11 트리플 업데이트는 A-3·A-4·A-5 를 **같은 배치**에서 처리할 것을 요구한다.
> `601716`/`601717` 자신의 등록도 같은 규칙을 따른다.

### §1.3 허용 DDL — 판정 1의 범위 안에서만

**대상 스키마는 `catchmenu_hq` 뿐이다.**

| # | 조작 | 대상 | 근거 |
|---|---|---|---|
| D-1 | `ALTER TABLE … RENAME TO` | `owners` → `persons` | `601702` §1.37 |
| D-2 | `ALTER TABLE … RENAME COLUMN` | `legal_entity_person_roles.owner_id` → `person_id` | `601702` §1.37 |
| D-3 | `ALTER TABLE … RENAME COLUMN` | `legal_entity_representatives.owner_id` → `person_id` | `601702` §1.37 |
| D-4 | `ALTER TABLE … RENAME CONSTRAINT` | `legal_entity_person_roles_owner_id_fkey` → `legal_entity_person_roles_person_id_fkey` | `601702` §1.37 「FK 제약명…도 person 기준으로 정렬」 |
| D-5 | `ALTER TABLE … RENAME CONSTRAINT` | `legal_entity_representatives_owner_id_fkey` → `legal_entity_representatives_person_id_fkey` | 동일 |
| D-6 | `ALTER INDEX … RENAME TO` | `owners_pkey` → `persons_pkey` | `601702` §1.37 「인덱스명도 person 기준으로 정렬」 |
| D-7 | `ALTER INDEX … RENAME TO` | `idx_lepr_owner` → `idx_lepr_person` | 동일 |
| D-8 | `COMMENT ON TABLE` | `persons` — canonical 개념과 어긋나지 않는 문구 | Logic I-15 |

**D-1~D-8 이 허용 DDL 의 전부다.**

> ⚠️ **`uq_lepr_active` / `uq_ler_active` / `uq_ler_sole_active` 는 이름을 바꾸지 않는다.**
> 세 이름에 `owner` 문자열이 없고, 정의 안의 컬럼 참조는 D-2·D-3 으로 자동 갱신된다.
> 이름을 바꿀 이유가 없는데 바꾸면 Logic I-5~I-7 의 유일성 의미가 끊긴 구간이 생길 위험만 늘어난다.

### §1.4 조건부 허용 — Human 판정 후에만

아래는 `601702` §1.37 의 **명시 목록에 없다.** §7 의 해당 blocker 가 해소되어야 허용된다.

| # | 조작 | 대상 | 걸린 blocker |
|---|---|---|---|
| C-1 | `ALTER TRIGGER … RENAME TO` | `trg_owners_updated_at` → `trg_persons_updated_at` | B-2a |
| C-2 | `ALTER TABLE … RENAME COLUMN` | `persons.owner_name` → 다른 이름 | B-2b |
| C-3 | `ALTER TABLE … DROP COLUMN` | `persons.is_active` | B-3 |
| C-4 | `ALTER TABLE … DROP COLUMN` + `DROP CONSTRAINT` | `legal_entity_person_roles.ownership_percent` / `chk_lepr_ownership_percent` | B-4 |

> **C-1~C-4 는 기본 상태가 "금지"다.** Stage 7 Approval 이 개별적으로 명시하지 않으면 수행하지 않는다.

### §1.5 허용 동사 (narrow verbs)

```text
허용   ALTER TABLE … RENAME TO
       ALTER TABLE … RENAME COLUMN
       ALTER TABLE … RENAME CONSTRAINT
       ALTER INDEX … RENAME TO
       COMMENT ON TABLE
       (조건부) ALTER TRIGGER … RENAME TO
       (조건부) ALTER TABLE … DROP COLUMN / DROP CONSTRAINT
```

이 목록에 없는 동사는 전부 §6 금지다.

## §2 판정 1 — `owners → persons` 물리 변경 방법

### §2.1 판정

**`ALTER … RENAME` 계열 조작만 허용한다.**
**신규 테이블 생성 후 교체 방식을 금지한다.**
**`owners` 라는 이름의 호환 view / matview 생성을 금지한다.**

### §2.2 판정 근거 — 실측 사실

| # | 사실 | 출처 |
|---|---|---|
| F-1 | 4테이블 전부 0행 — 데이터 이관 위험 없음 | `601711` P-3 / `601712` P-3 |
| F-2 | `owners` 참조 FUNCTION 0건, `pg_depend`→`pg_proc` 의존 0건 | `601714` Q-4 / `601715` Q-4 |
| F-3 | `owners` 참조 VIEW / MATVIEW 0건 | `601711` P-1 |
| F-4 | 타 스키마에서 4테이블을 참조하는 FK 0건 | `601714` Q-4 / `601715` Q-4 |
| F-5 | 앱·패키지·테스트·seed 코드 참조 0건 | `601711` P-5 / `601712` P-5 |
| F-6 | 관련 migration 은 `0168`/`0169` 2건뿐 | `601711` P-2 |
| F-7 | RLS `ENABLE`+`FORCE`, POLICY 0건, GRANT 4건, role 은 `nologin`+`bypassrls` | `601711` P-1 / `601714` Q-4 |

### §2.3 왜 rename 인가 — 두 방식이 불변조건에 미치는 영향

Logic `601713` §1.1 의 I-1~I-14 는 **어느 방식을 택하든** 지켜져야 한다.
차이는 "지켜지는 방식"이다.

```text
ALTER … RENAME          객체 OID 가 유지된다
                        FK · TRIGGER · RLS 플래그 · GRANT · PK 가
                        재선언 없이 그대로 따라간다
                        → I-1~I-4, I-9~I-14 가 자동 보존된다

CREATE 신규 + 교체       FK 2건 · TRIGGER 1건 · RLS ENABLE+FORCE ·
                        GRANT 4건 · PK · 부분 unique 3건을
                        전부 사람 손으로 재선언해야 한다
                        → Logic X-1 · X-2 · X-3 · X-4 · X-6 · X-7 · X-8 이
                          전부 실현 가능한 실패 지점이 된다
```

**Logic §3 이 열거한 11개 실패 지점 중 7개는 "신규 생성 후 교체" 방식에서만 발생한다.**
데이터 0행·참조 0건이라는 상태에서 그 7개 위험을 자발적으로 도입할 근거가 없다.

### §2.4 rename 이 자동으로 해주지 않는 것 — 명시적으로 써야 한다

| 항목 | PostgreSQL 동작 | 계약 요구 |
|---|---|---|
| FK **정의** 안의 컬럼 참조 | 컬럼 rename 시 자동 갱신 | 별도 조치 불필요 |
| FK **제약 이름** | 자동 갱신되지 않음 | D-4 · D-5 로 명시 |
| **인덱스 이름** | 자동 갱신되지 않음 | D-6 · D-7 로 명시 |
| **트리거 이름** | 자동 갱신되지 않음 | C-1 — 조건부(B-2a) |
| 부분 unique 인덱스의 **정의** | 컬럼 rename 시 자동 갱신 | 이름 변경 금지(§1.3 주의) |
| 테이블 **코멘트** | 유지 | D-8 로 문구 정합 |

### §2.5 호환 계층을 금지하는 이유

`owners` 라는 view 를 남기면 legacy 어휘가 **다시 조회 가능한 canonical 표면**이 된다.
`601710` §2.1 은 「legacy `owners` terminology 를 authoritative 로 남기지 않는다」고 정했다.
데이터 0행·코드 참조 0건 상태에서 호환 계층이 보호할 호출자가 존재하지 않는다.

**TestPlan `601716` TP-N-01 · TP-N-02 가 이 판정을 검사한다.**

### §2.6 이 판정이 결정하지 않은 것

**`legal_entities` / `legal_entity_person_roles` / `legal_entity_representatives` 의 테이블명은 유지한다.**
`601702` §1.37 이 `legal_entity_representatives` 유지를 명시했고,
나머지 둘의 개명을 지시하지 않았다. **선언에 없는 개명을 이 계약이 만들지 않는다.**

**`catchmenu_authority_owner` role 명은 이번 범위 밖이다.**
role 은 클러스터 전역 객체이며 `0169` 가 생성했다. `601702` §1.37 의 대상 목록에 없다.
이름에 `owner` 가 포함된다는 사실만 기록하고 **변경하지 않는다**(§6 금지).

## §3 판정 2 — Store–LegalEntity NOT NULL enforcement eligibility

### §3.1 판정

**부적격(NOT ELIGIBLE).**
`stores.legal_entity_id` 에 `NOT NULL` 을 걸지 않는다.
**이번 나선에서 `stores` 테이블에 어떤 DDL 도 적용하지 않는다.**
enforcement 는 **명시적 blocker 와 함께 이월**한다(`601710` §4 「미확보」 분기).

### §3.2 판정 근거 — Logic E-1~E-4 대조

Logic `601713` §1.5 가 enforcement 가능 조건 4건을 제시했다.

| 조건 | 판정 | 근거 |
|---|---|---|
| E-1 모든 Store 가 검증된 business identity 확보 | **거짓** | `010901` §11 의 9개 intake 필드 중 실재하는 정확명은 `business_registration_number` 1건뿐. 나머지 8건(`legal_entity_name` / `representative_name` / `business_address` / `business_category` / `tax_invoice_email` / `settlement_owner` / `contract_signer` / `verification_state`)은 전 스키마에서 0건 (`601714` Q-8 / `601715` Q-8) |
| E-2 그 identity 로 canonical LegalEntity 생성·연결 | **거짓** | `legal_entities` 0행 (`601701` §4.5 D-3) |
| E-3 mapping completeness — 미매핑 Store 0 | **거짓** | `stores` 1행 / `legal_entity_id` 백필 0행 → 미매핑 Store = 1 |
| E-4 신규 onboarding 경로가 LegalEntity 없이 Store 를 만들 수 없다 | **미확인** | `sales_lead` / `tenant_candidate` 테이블 0건. onboarding 명칭 테이블은 `catchmenu_common.tenant_onboarding_log` 1건이며 intake 9필드를 담지 않는다. `catchmenu_integrations.delivery_intake_log` 는 배달 도메인이며 무관 (`601714` Q-8 / `601715` Q-8) |

**E-1·E-2·E-3 이 거짓이므로 기존 데이터에 enforcement 를 걸 수 없다.**
E-4 는 향후 유입 조건이며, 충족되더라도 E-1~E-3 을 대신하지 못한다(Logic §1.5 주석).

### §3.3 적격으로 만들려는 시도를 금지한다

| 금지 | 근거 |
|---|---|
| 검증되지 않은 synthetic LegalEntity 생성 | Logic I-28 / `601702` §1.31 |
| placeholder 로 `stores.legal_entity_id` 백필 | 동일 |
| `store_operator_type` 값으로 LegalEntity 추론·배정 | Logic I-30 / `601702` §1.32 |

> `legal_entities` 0행이라는 물리 사실만으로 **모델 결함이라고 판정하지 않는다**(`601702` §1.31).
> `601714`/`601715` Q-8 이 확인한 것은 **intake 필드가 시스템에 존재하지 않는다**는 사실이다.
> 이는 "intake 가 수행되지 않았다"와 "intake 를 담을 곳이 아직 없다"를 **구분하지 못한다.**
> 그 구분은 onboarding 운영 증거로 확인할 사항이며 이 계약의 범위 밖이다.

### §3.4 이 판정과 `601702` §1.34 의 관계 — 미해결

`601702` §1.34(2026-08-22)는 Store–LegalEntity 를 **유효기간을 갖는 시점 관계**로 확정하고,
Store 가 보유하는 값은 「권위 원본이 아니라 현재 포인터」라고 선언했다.
그리고 **물리 구조를 2단계 ERD 및 ChangeContract 로 넘겼다.**

**이 계약은 그 물리 구조를 정하지 않는다.**

| 이유 |
|---|
| Overview `601710` §2·§4 와 Logic `601713` §1.5 는 §1.34 이전 문서이며, 시점 이력 구조를 구현 대상으로 두지 않았다 |
| Logic I-31 은 「Store 당 LegalEntity 개수는 미정 상태를 유지」를 요구하고, I-33 은 「이력 테이블을 지시하지 않는다」고 명시했다 |
| `601705` §5.2 U2 가 시점 이력 표현을 미정으로 남겼고 §10 O1 이 4단계로 넘겼으나, 4단계 산출물(Overview/Logic)이 이를 다루지 않았다 |

**Overview / Logic 에 없는 구현 범위를 이 계약이 추가하지 않는다.** §7 B-5 로 기록한다.

## §4 판정 3 관련 — External Provider Mapping 명시적 금지 (`601710` §7 요구)

> `601710` §7: 「ChangeContract 는 provider mapping 물리 구현을 **명시적으로 금지**해야 한다.
> 선언만 있고 금지가 없으면, 구현 주체가 "mapping 이 필요하다고 했으니 테이블을 만들어야겠다"고
> 판단할 여지가 남는다.」

### §4.1 금지 조항

**이번 나선에서 External Provider Mapping 의 물리 구현을 전면 금지한다.**

```text
금지   provider mapping table 생성
금지   외부 provider 전용 컬럼 추가 (기존 테이블 포함)
금지   provider contract 를 추정한 schema · 타입 · 제약 생성
금지   특정 벤더명을 담은 객체 생성 (TOSS / OKPOS / KICC / Smartcast 등)
금지   stores.id 를 외부 provider merchant id 와 동일시하는 제약 · 주석
금지   catchmenu_integrations / catchmenu_payment 의 기존 merchant 컬럼 5건을
       canonical identity 로 승격하는 FK · unique 제약 추가
```

### §4.2 `601702` §1.43 과 `601710` §3.1 의 긴장 — 기록

`601702` §1.43 은 「물리 구조·테이블명·필드는 2단계 ERD 및 ChangeContract 에서 정한다」고 썼다.
`601710` §3.1 은 「이번 나선에서 물리 구현을 하지 않는다」고 정하고 §7 에서 금지 조항을 요구했다.

**이 계약은 `601710` 을 따른다.** 이유는 외부 provider 의 실제 identifier 구조가 확보되지 않았다는
사실(`601710` §3.1)이 `601702` §1.43 의 T-1~T-5 / E-1~E-6 / C-1~C-2 확인 항목으로도
아직 열려 있기 때문이다. **다만 두 문서의 지시가 문면상 다르다는 사실은 §7 B-6 로 기록한다.**

**빈 테이블도 설계 결정이다**(`601710` §3.1). 만들지 않은 상태가 이번 나선의 결과다.

**TestPlan `601716` §7 TP-X-01~TP-X-10 이 이 조항을 negative 로 검사한다.**

## §5 Forbidden Files — 금지 파일 목록

**§1 에 없는 모든 파일이 금지다.** 아래는 실수 가능성이 높은 것을 명시한 것이며 한정 목록이 아니다.

### §5.1 절대 금지 — 수정 시 즉시 반려

| # | 경로 | 사유 |
|---|---|---|
| X-1 | `sql/migrations/0168_create_operational_authority_foundation.sql` | `000701` §14.5 불변 경계 · `601710` §5 동결 |
| X-2 | `sql/migrations/0169_authority_owner_role_and_sole_representative_uniqueness.sql` | 동일 |
| X-3 | `sql/migrations/0000_*.sql` ~ `0167_*.sql` (기존 167개) | 동일 |
| X-4 | `sql/_excluded_from_local_replay/**` | 재생 제외 결정 파일(`CHANGELOG` 2026-08-07) |
| X-5 | `sql/seed_yoonsul_menu.sql` · 기타 seed | 데이터 생성 금지(§6) |
| X-6 | `sql/migrations/CHANGELOG.md` | 규약 상태 미결(자체 「de facto superseded」 기록). Human 판정 전 수정 금지 — §7 B-8 |

### §5.2 상위 근거 문서 — 구현자가 수정하지 않는다

| # | 경로 | 사유 |
|---|---|---|
| X-7 | `601702_Register_Stage1_Business_Rules.md` | Human 전담 산출물. AI 수정 불가(`601702` §0) |
| X-8 | `601710_Overview_…V2.md` · `601713_Logic_…V2.md` | 4단계 상위 근거. 개정은 Stage 3/4 경로로만 |
| X-9 | `601716_TestPlan_…V2.md` · `601717_ChangeContract_…V2.md` | 본 계약 자신 포함. 개정은 Stage 6/7 경로로만 |
| X-10 | `601701` · `601703`~`601709` · `601711`·`601712` · `601714`·`601715` | Evidence / Register / Audit — 사후 수정 시 기준선이 소멸한다 |
| X-11 | `docs/000001_Md_Rules.md` · `docs/000701_…Pipeline.md` | 거버넌스 문서. 이 워크패킷의 대상이 아니다 |
| X-12 | `docs/600000_implementation_lifecycle/600020_…Authority_Reset.md` | 권위 판정 전문 |
| X-13 | `docs/…/601500_operational_authority_foundation/**` | 권위보류 대역. 처분은 나선 완료 후 재판정(`601710` §5.1) |

### §5.3 범위 밖 — 이번 변경이 닿지 않는다

| # | 경로 | 사유 |
|---|---|---|
| X-14 | `apps/**` | 앱 코드 참조 0건(`601711` P-5) |
| X-15 | `packages/**` | 동일 |
| X-16 | `catchmenu_app/**` | 동일 |
| X-17 | `tests/**` | 동일 |
| X-18 | `tools/**` (`Check-Governance.ps1` · `apply_migrations*.py` 포함) | 검증 도구를 변경해 검사를 통과시키지 않는다 |
| X-19 | `supabase/**` | 런타임 설정 |
| X-20 | `.git/hooks/**` | 커밋 게이트 우회 금지 |
| X-21 | `data/**` · `scratch/**` · `sop/**` | 무관 |

## §6 Forbidden Operations — 금지 조작

### §6.1 물리 조작

| # | 금지 | 근거 |
|---|---|---|
| FO-1 | 신규 테이블 생성 (`persons` 를 포함해 **어떤 이름으로도**) | §2 판정 — rename 방식 |
| FO-2 | `DROP TABLE` | 동일 |
| FO-3 | `owners` 이름의 VIEW / MATVIEW 생성 | §2.5 |
| FO-4 | `CASCADE` 사용 | `601702` §1.39 「`CASCADE` 로 일괄 제거하지 않는다」 |
| FO-5 | RLS POLICY 생성·삭제 | Logic I-11 — 정책 0개는 의도된 상태 |
| FO-6 | `ALTER TABLE … DISABLE/NO FORCE ROW LEVEL SECURITY` | Logic I-10 |
| FO-7 | GRANT / REVOKE (`catchmenu_authority_owner` 4 privilege 의 확대·축소 포함) | Logic I-12·I-13 |
| FO-8 | 클라이언트 도달 가능 role(`anon`/`authenticated`/`service_role`)에 권한 부여 | Logic I-12 |
| FO-9 | role 생성·삭제·속성 변경 (`catchmenu_authority_owner` 개명 포함) | §2.6 — 선언 목록 밖 |
| FO-10 | FK 참조 동작을 `NO ACTION` 이외로 변경 | Logic I-3 |
| FO-11 | `INSERT` / `UPDATE` / `DELETE` — 어떤 테이블에도 | `601710` §2 에 데이터 대상 없음 |
| FO-12 | `stores` 에 대한 모든 DDL | §3.1 |
| FO-13 | `NOT NULL` 승격 | §3.1 |
| FO-14 | `chk_lepr_role_type` 허용값 재정의 | `601702` 선언 없음(`601713` §1.1) |
| FO-15 | 함수 생성·수정·삭제 (SECURITY DEFINER 포함) | `601700` Readme §5 — RPC 재작성 범위 밖 |
| FO-16 | `catchmenu_common.set_updated_at()` 수정 | 114개 트리거가 공유(`601714` Q-3) |
| FO-17 | `catchmenu_meta.migration_history` 직접 조작 | 이력 보존 |

### §6.2 범위 조작

| # | 금지 | 근거 |
|---|---|---|
| FO-18 | External Provider Mapping 물리 구현 | §4.1 |
| FO-19 | `merchant_accounts` 및 유사 테이블 생성 | §0.2 / §7 B-1 |
| FO-20 | economic ownership 모델 생성 | `601702` §1.39 「0-A 에서 새 ownership 모델을 구현하지 않는다」 |
| FO-21 | Store 상태 3축 enum · 상태 컬럼 생성 | `601710` §3 |
| FO-22 | `OperatingGroup` / `company` / `business_unit` / `cross_business_link` 물리화 | `601710` §3 |
| FO-23 | Staff / User / Session / Role / Permission 객체 변경 | `601702` §1.18·§1.19 |
| FO-24 | Store–LegalEntity 시점 이력 테이블 생성 | §3.4 |
| FO-25 | 감사 이력 테이블 · 감사 트리거 생성 | `601713` §5 |
| FO-26 | `tenant_status` / `isolation_state` 관련 조작, tenant 를 `ACTIVE` 로 승격 | `601505` §4 금지 조항이 0-A-2 완료까지 유효(`601710` §5) |

### §6.3 절차 조작

| # | 금지 | 근거 |
|---|---|---|
| FO-27 | Stage 7 승인 전 migration 적용 또는 커밋 | `000701` §10 · §6.11.1 |
| FO-28 | `-- Workpacket: 601700` 헤더 누락 | `000701` §6.11.1 |
| FO-29 | 검증 도구를 수정해 검사를 통과시키는 행위 | X-18 |
| FO-30 | 구현자가 자기 구현을 감사·승인하는 행위 | `000701` §37 / `000001` §5.4.10 |
| FO-31 | migration 을 2개 이상으로 분할 | §1.1 A-1 — 단일 파일. 중간 상태 커밋 금지(Logic X-1) |

## §7 Blocker — 착수 전 Human 판정이 필요한 것

> 이 계약은 아래를 **해소하지 않는다.** 판정 주체는 Human 이다(`000001` §5.7).
> 해소되지 않은 blocker 에 걸린 범위는 **구현에서 제외**되어야 하며,
> 제외 사실이 Stage 7 Approval 에 명시되어야 한다.

| # | Blocker | 사실 관계 | 이 계약의 처리 |
|---|---|---|---|
| **B-1** | **`MerchantAccount` 목표 물리 형태 미선언** | Overview §2 가 구현 대상 2·3·4 로 지정. 그러나 `601705` §10 O5(물리 구현 방식) · O9(권장 필드 새 어휘) · O10(식별 속성 목록)이 미결이고, Logic §1.2 가 「`601702` 가 필드 집합을 선언하지 않았으므로 필드를 확정하지 않는다」고 기록. `601714`/`601715` Q-5 실측: `merchant%` 테이블 0건 | 대상 2·3·4 를 §1 허용 목록에서 **제외**. FO-19 로 금지 |
| **B-2a** | **트리거명 `trg_owners_updated_at` 처리 미선언** | `601702` §1.37 의 명시 목록은 FK 제약명·인덱스명뿐. 트리거명은 없다. 이름에 `owners` 가 남는다 | C-1 조건부. 기본 금지 |
| **B-2b** | **컬럼 `owner_name` 처리 미선언** | `601702` §1.2 는 무수식 `Owner` 금지, §1.37 의 명시 목록에는 없다. `601714`/`601715` Q-8 이 `owners.owner_name` 실재 확인 | C-2 조건부. 기본 금지 |
| **B-3** | **`is_active` 처리 충돌** | Logic I-14(2026-08-13)는 7컬럼의 「활성」 역할 유실 금지. `601702` §1.38(2026-08-22)은 사람 레코드에서 `is_active` 제거 선언. **Logic 은 개정되지 않았다** | C-3 조건부. 기본 금지 |
| **B-4** | **`ownership_percent` 처리 충돌** | `601702` §1.39(2026-08-22)는 제거 선언. Logic §1.1(2026-08-13)은 「제거도 사용도 지시하지 않는다」. **Logic 은 개정되지 않았다** | C-4 조건부. 기본 금지 |
| **B-5** | **Store–LegalEntity 시점 관계 물리 구조 미정** | `601702` §1.34 가 시점 관계를 확정하고 물리 구조를 ChangeContract 로 위임. 그러나 Overview §2·§4 와 Logic I-31·I-33 이 이를 구현 대상으로 두지 않았고, `601705` §5.2 U2 는 미정 | FO-24 로 금지. §3.4 에 기록 |
| **B-6** | **`601702` §1.43 과 `601710` §3.1 의 문면 차이** | §1.43 「물리 구조는 ChangeContract 에서 정한다」 vs §3.1 「이번 나선에서 물리 구현을 하지 않는다」 | `601710` §7 의 명시 지시에 따라 **금지**로 처리(§4). 차이 자체는 미해소 |
| **B-7** | **상위 선언 개정에 따른 재검토 범위 미판정** | `601702` §0 은 「선언을 변경하려면 그 사유를 개정 이력에 남기고, 이미 그 선언을 근거로 만들어진 산출물(`601705` 이하)의 재검토 범위를 함께 판정한다」고 요구. §1.34~§1.43 이 2026-08-22 에 추가됐으나 `601705`/`601710`/`601713` 의 재검토 범위 판정이 문서로 없다 | 이 계약은 판정하지 않는다. **B-3·B-4·B-5 의 상위 원인** |
| **B-8** | **`CHANGELOG.md` 규약 상태 미결** | 파일 자체가 「de facto superseded」로 기록하고 Human 의 명시적 판정(폐기 / 재개)을 권고. 판정이 없다 | X-6 으로 수정 금지. 갱신 여부는 Stage 7 이 정한다 |
| **B-9** | **검증 환경 미지정** | `601701`/`601711`/`601712` 는 `postgres:17.6.1.140`, `601714`/`601715` 는 `17.6.1.156`. 두 컨테이너가 다르다는 사실이 기록되어 있다 | 이 계약은 지정하지 않는다. Stage 7 이 정한다 |
| **B-10** | **문서 정합화 시점 미정** | `owners` 참조 문서 27건(`601711` P-4) / 30건(`601712` P-4.1). Logic X-9 가 최대 실패 지점으로 지목했으나 시점이 정해지지 않았다 | §1.2 문서 동기화는 색인 3종만 허용. 27~30건 정합화는 **별도 판정 대상** |

> **B-7 이 B-3·B-4·B-5 를 만든다.**
> Human 선언이 나중에 추가됐고, 그 선언을 반영하는 Overview/Logic 개정이 없다.
> 이 계약이 선언 쪽을 택하면 Overview/Logic 에 없는 범위를 구현하는 것이고,
> Overview/Logic 쪽을 택하면 상위 근거인 Human 선언을 무시하는 것이다.
> **어느 쪽도 이 계약의 권한이 아니다.**

### §7.1 거버넌스 문서 간 표기 차이 — 기록

| 항목 | `000001` §5.4.2 | `000701` §3 (13단계) |
|---|---|---|
| Overview / Logic 저자 | Stage 1.5 (Claude Code) | [2] Design Draft — Claude Code |
| TestPlan / ChangeContract 저자 | **Stage 2 (Claude)** | **[5] Contract Drafting — Claude Code** |
| Human 승인 | — | [7] Human Approval Gate |

두 문서가 계약 작성 주체를 다르게 표기한다.
**공통점은 "Overview/Logic 저자와 TestPlan/ChangeContract 저자가 달라야 한다"는 원칙이며**,
이 계약은 `000001` §5.4.2 표기를 따라 Claude 가 작성했다.
**표기 차이 자체는 이 계약이 판정하지 않는다.**

## §8 Required Verification

### §8.1 착수 직전 게이트

| # | 항목 | 미충족 시 |
|---|---|---|
| V-1 | §10 Stage 7 이 승인 상태 | 착수 금지 |
| V-2 | §7 의 blocker 중 착수 범위에 걸린 것이 해소 또는 명시적 제외됨 | 해당 범위 제외 |
| V-3 | TestPlan `601716` §2.1 기준선 BL-1~BL-18 재측정 완료 | 사후 비교 불가 — 착수 금지 |
| V-4 | 검증 환경 확정(B-9) | 착수 금지 |
| V-5 | 구현자가 Overview/Logic/TestPlan/ChangeContract 원작자가 아님 | 배정 재조정(`000701` §37) |

### §8.2 구현 후 검증

**TestPlan `601716` 의 전 항목을 수행한다.** 특히 아래는 생략 불가다.

| # | 항목 | 대응 Test ID |
|---|---|---|
| V-6 | negative 검증 전건 | `601716` §5 전체 |
| V-7 | **External Provider Mapping negative 검증** | `601716` §7 TP-X-01~TP-X-10 |
| V-8 | RLS `ENABLE`+`FORCE` + POLICY 0건 + GRANT 4건 조합 | TP-P-14 · TP-P-15 · TP-N-05 · TP-N-09 |
| V-9 | `catchmenu_hq` BASE TABLE 수 = 20 | TP-R-01 — rename 인지 신규 생성인지를 가르는 검사 |
| V-10 | `set_updated_at()` 호출 트리거 총계 = 114 | TP-R-02 |
| V-11 | `0168`/`0169` checksum 이 `migration_history` 기록값과 동일 | TP-R-11 |
| V-12 | 허용 파일 목록 준수 (`git diff --name-only`) | TP-B-01 · TP-B-02 |
| V-13 | `tools/Check-Governance.ps1` G15 — `-StrictStage7` 포함 | TP-M-02 · TP-M-03 |

### §8.3 이중 검증 (`000701` §35)

**검증자가 1명이면 그 1명의 사각지대가 남는다**(`601700` Readme §10.1).
구현자(Codex)를 제외한 **2개 이상의 독립 행위자**가 §8.2 를 각각 수행한다.

## §9 Rollback Policy · 경계 · 구현자 지시 경계

### §9.1 Rollback Policy

| # | 규칙 |
|---|---|
| R-1 | rollback 은 **역방향 신규 migration**(`0171`)으로만 수행한다. `0170` 을 수정·삭제하지 않는다(`000701` §14.5) |
| R-2 | rollback 대상 데이터는 없다(4테이블 0행). 위험은 데이터가 아니라 **RLS·GRANT 조합의 비대칭 복원**이다(Logic X-6·X-7·X-8) |
| R-3 | rollback 후 `601716` §2.1 기준선 BL-1~BL-18 이 전부 복원되어야 한다 |
| R-4 | rollback 판단은 Human 이 한다. 구현자가 스스로 되돌리고 그 사실을 기록하지 않는 것을 금지한다 |

### §9.2 Boundary With Related Workpackets

| 워크패킷 | 경계 |
|---|---|
| `601500` (1차 0-A) | 권위보류. 설계 결론을 근거로 쓰지 않았다. `601505` §4 금지 조항은 0-A-2 완료까지 유효(FO-26) |
| `601600` (역전파) | 권위보류. 판정 내용은 `600020` §5 로 대체 |
| 0-A-2 | `tenant_status` / `isolation_state` 소관. FO-26 |
| 0-B (Identity/Login/Session) | Staff / User / Session — FO-23 |
| 0-C (Role/Permission/Authorization) | 권한 모델 — FO-23 |
| Provider Integration (번호 미정) | External Provider Mapping — §4. `601710` §3.1 이 착수 전 확인 항목 T-1~T-5 / E-1~E-6 / C-1~C-2 를 제시 |
| Franchise OS | `FranchiseAgreement` — `601702` §1.10 |

### §9.3 Codex Instruction Boundary

```text
Codex 는 Stage 7 Human Approval 이 명시적으로 허용 파일을 열거한 뒤에만 구현한다.
허용 파일은 §1, 허용 DDL 은 §1.3(및 승인된 경우 §1.4), 허용 동사는 §1.5 다.
불확실하면 중단하고 묻는다. 추론으로 범위를 넓히지 않는다.
Codex 는 자기 구현을 스스로 감사하거나 승인하지 않는다.
```

**중단 조건** — 아래를 만나면 즉시 멈추고 재승인을 받는다.

| # | 중단 조건 |
|---|---|
| S-1 | `601716` §2.1 기준선 재측정값이 BL-1~BL-18 과 다르다 |
| S-2 | 허용 목록 밖 파일을 건드려야 한다는 판단이 든다 |
| S-3 | rename 만으로 목표 상태에 도달할 수 없다는 사실이 발견된다 |
| S-4 | §7 의 blocker 중 하나가 구현 도중 범위에 걸린다 |
| S-5 | provider / merchant / mapping 관련 객체를 만들어야 한다는 판단이 든다 |

### §9.4 Acceptance Criteria

| # | 조건 |
|---|---|
| AC-1 | §8.1 V-1~V-5 충족 |
| AC-2 | 변경 파일이 §1 허용 목록의 부분집합 |
| AC-3 | §5 금지 파일 변경 0건 |
| AC-4 | §6 금지 조작 0건 |
| AC-5 | `601716` §13 Acceptance Criteria AC-1~AC-10 충족 |
| AC-6 | §8.3 이중 검증 수행 |
| AC-7 | §7 blocker 중 미해소분이 Stage 7 Approval 에 **제외 사실로 명시**되어 있다 |

> **AC-7 이 없으면 "blocker 를 잊은 것"과 "blocker 를 알고 제외한 것"이 구분되지 않는다.**
> 1차 0-A 실패의 형태가 정확히 이것이다 — `601505` §10 이 스스로 `Stage 7 대기` 라고
> 기록하고 있었는데도 아무도 발견하지 못했다(`000701` §6.11.1 근거 사례).

## §10 Approval State

| 단계 | 상태 |
|---|---|
| Stage 4 (Overview / Logic, Claude Code) | 완료 — `601710` / `601713` |
| Stage 5 (Contract Drafting) | 완료 — 본 문서 및 `601716` |
| Stage 6 (Contract Verification) | 대기 — §37 에 따라 **Claude 제외**(계약 작성자) |
| Stage 7 (Human Approval) | 대기 |
| Stage 8 (Implementation, Codex) | 미착수 |

> **Stage 6 주의**(`000701` §37): `601716` TestPlan 과 본 계약은 Claude 가 작성했으므로,
> Claude 는 계약 검증에 참여하지 않는다. Overview/Logic 은 Claude Code 가 작성했으므로
> Claude Code 도 그 범위의 원작자다. 검증자는 그 둘을 제외해 구성한다(`601700` Readme §10.1).

> ⚠️ **Stage 7 이 승인 상태가 되기 전에는 `sql/migrations/0170_*.sql` 이 존재해서는 안 된다.**
> `tools/Check-Governance.ps1` 의 G15 가 커밋 시점에 이 표의 Stage 7 행을 읽는다
> (`000701` §6.11.1). `-StrictStage7` 또는 `GOVERNANCE_STRICT=1` 에서 ERROR 로 승격된다.

> ⚠️ **Stage 7 승인 시 함께 명시해야 하는 것**
>
> ```text
> 1. 허용 파일 목록 (§1 을 확정하거나 축소)
> 2. §1.4 조건부 항목 C-1 ~ C-4 각각의 허용 여부
> 3. §7 blocker 중 미해소분과 그로 인해 제외되는 범위 (AC-7)
> 4. 검증 환경 (B-9)
> ```

## §11 근거 문서 목록 (`000701` §46)

Overview `601710` §6.1/§6.2 가 79건을 전수 분류했다. 여기에는 **이 계약이 직접 인용한 것만** 기록한다.

| 문서 | 인용 절 | 권위 | 역할 |
|---|---|---|---|
| `docs/000001_Md_Rules.md` | §5.4.1, §5.4.2, §5.4.3, §5.4.5, §5.4.6, §5.4.10, §5.7, §5.11 | ACTIVE | ChangeContract 규격 · 저자 분리 · 충돌 처리 |
| `docs/000700_…/000701_Guide_Controlled_AI_Development_Pipeline.md` | §3, §6.11.1, §10, §14.5, §35, §37, §46, §47.1 | ACTIVE | Stage 게이트 · 불변 경계 · 이중 검증 |
| `docs/600000_implementation_lifecycle/600020_Governance_…Authority_Reset.md` | §2, §5 | ACTIVE | `601500` 권위보류 |
| `docs/…/601700_Readme_…V2.md` | §4, §5, §10, §10.1 | 본 워크패킷 | In/Out of Scope · 비구현 경계 · Actor 배정 |
| `docs/…/601701_Register_Stage0_Evidence_Collection.md` | §4.5 D-3 | 본 워크패킷 | LegalEntity 0행 / Store 1행 |
| `docs/…/601702_Register_Stage1_Business_Rules.md` | §0, §1.2, §1.10, §1.18, §1.19, §1.31, §1.32, §1.34, §1.37, §1.38, §1.39, §1.43, §5 | 본 워크패킷 | **최우선 근거** — Human 선언 |
| `docs/…/601705_Diagram_Operational_Authority_Core_ERD.md` | §5.2 U1·U2, §8, §10 O1·O5·O9·O10 | 본 워크패킷 | 미정 관계 · Open Decisions |
| `docs/…/601710_Overview_…V2.md` | §2, §2.1, §3, §3.1, §4, §5, §7 | 본 워크패킷 | 구현 대상 · 제외 · 금지 조항 요구 |
| `docs/…/601711_Evidence_Person_Physical_Impact_Scan_Cursor.md` | P-1 ~ P-5 | 본 워크패킷 | 물리 기준선 |
| `docs/…/601712_Evidence_Person_Physical_Impact_Scan_Codex.md` | P-1 ~ P-5 | 본 워크패킷 | 물리 기준선(이중) |
| `docs/…/601713_Logic_…V2.md` | §1.1~§1.5, §2, §3, §4, §5, §6 | 본 워크패킷 | I-1~I-33 / X-1~X-11 / E-1~E-4 |
| `docs/…/601714_Evidence_Stage4_Logic_Gap_Survey_Cursor.md` | Environment, Q-2 ~ Q-8 | 본 워크패킷 | 판정 1·2 의 실측 근거 |
| `docs/…/601715_Evidence_Stage4_Logic_Gap_Survey_Codex.md` | 환경, Q-2 ~ Q-8 | 본 워크패킷 | 동일(이중) |
| `docs/…/601716_TestPlan_…V2.md` | 전체 | 본 워크패킷 | 검증 요건의 실체 |
| `sql/migrations/CHANGELOG.md` | 2026-08-07 항목 · Convention status | 프로젝트 파일 | B-8 |
| `tools/Check-Governance.ps1` | G15 | 프로젝트 파일 | §10 게이트 실행 주체 |

**권위보류 문서 인용 — 명시**

| 문서 | 인용 위치 | 어떻게 썼는가 |
|---|---|---|
| `601505` §4 | FO-26 · §9.2 | 금지 조항이 0-A-2 완료까지 유효하다는 **사실**만 인용. `601710` §5 를 경유했다 |
| `601505` §10 | AC-7 주석 | 1차 0-A 실패의 **형태**로만 인용. `000701` §6.11.1 이 기록한 사례다 |

`601501`~`601512` 의 설계 결론을 정답으로 전제한 곳은 없다(`600020` §2).
`601504` TestPlan · `601505` ChangeContract 의 허용 목록·DDL 을 참조하지 않았다.

---

## Final Rule

```text
This ChangeContract does not authorize implementation.
It defines candidate future boundaries only.
Codex may implement only after Human Approval explicitly lists allowed files.
```

> **이 계약이 판정한 것**은 물리 변경 방법(§2 — rename), enforcement 부적격(§3),
> 허용·금지 파일(§1·§5), Stage 7 승인란(§10) 넷이다.
>
> **이 계약이 판정하지 않은 것**은 §7 의 blocker 10건이다.
> 그중 B-1 은 Overview §2 의 구현 대상 5건 중 3건을 통째로 착수 불가로 만든다.
> **이 상태에서 대상 2·3·4 를 구현하면 그것은 구현이 아니라 설계다.**
>
> 승인 시 Approval 과 이 계약이 충돌하면 **더 엄격한 경계가 이긴다**(`000001` §5.4.6).
