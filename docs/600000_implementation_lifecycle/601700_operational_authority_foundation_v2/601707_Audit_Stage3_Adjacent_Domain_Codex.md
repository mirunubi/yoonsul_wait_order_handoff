# 601707_Audit_Stage3_Adjacent_Domain_Codex.md

> ⚠️ **3단계 인접 도메인 대조 · 검증 결과이며 판정이 아니다**
>
> `000701` §47.1의 **3단계(인접 도메인 대조)** 산출물이다.
> `601705` ERD 를 인접 ACTIVE 문서와 대조해 충돌을 기록한 것이며,
> 어느 쪽이 옳은지 판정하지 않았다. 판정은 `601702` §1.25~§1.26 이 했다.
>
> **원작자 배제**(`000701` §37): `601705` 는 Claude Code 가 작성했으므로
> 검증자에서 제외했다. 이 검증은 Codex 가 수행했다.
>
> **같은 작업을 Cursor 도 독립 수행했다 — `601706`.**
> 두 결과의 발견이 갈렸다(`000701` §35).
> Cursor 는 외부 어휘 충돌과 누락(`Merchant Company` 부재, store 상태축)을,
> Codex 는 ERD 내부 정합성(미정 관계를 확정 기호로 표기)을 잡았다.
>
> 수행: Codex, 2026-08-13. 필수 인접 문서 11개 전수 대조.

검증 역할: Cursor 독립 검증자(원작자 Claude Code 제외)  
대상: `601705_Diagram_Operational_Authority_Core_ERD.md`  
방식: 지정된 필수 인접 도메인 문서 11개 전수 대조 + 그 문서들이 참조하는 Core 5축 정의 문서 추가 탐색  
제약: 어느 문서가 옳은지 판정하지 않으며 수정안을 제안하지 않는다.

## V1 — Core 엔티티 경계 대조

| ID | 대조 사실 | 601705 근거 | 인접 문서 근거 | 상태 |
|---|---|---|---|---|
| V1-01 | Core를 `Person/Tenant/MerchantAccount/Store/LegalEntity` 5개로 구성 | §2 L89-106, §3 L133-151 | `003020` §2 L20-24와 `009030` §2 L17-21의 5축은 `tenant/company/legal_entity/operating_group/store` | 어휘 집합 불일치 |
| V1-02 | Company/BusinessUnit/OperatingGroup은 Candidate이며 persistent entity 미결 | §6 L242-266 | `000150` §4 L149-173은 Company record와 필드를 서술. `007010` §2 L20-40과 `007040` L38-43은 company/operating_group 화면·역할 축을 전제. `009070` §2 L18-21은 persistence depth를 미결로 둠 | 문서별 확정 깊이 차이 |
| V1-03 | Person은 Store/Tenant와 직접 관계 없음 | §4.1 L158-168, §9 L369 | `020310` §11 부근 L292-298은 User Account를 person 또는 non-human actor로 정의하고, L454-468은 merchant account/store scope 귀속을 서술 | Person↔User↔scope 연결은 경계 밖/추가 정의 필요 상태 |
| V1-04 | LegalEntity는 tenant에 직접 종속되지 않는 전역 개념 | §4.3 L181-190 | `003020` 개정 블록 L59-60은 tenant 직접 관계 없음과 cross-tenant 가능을 서술하지만 AUTHORITY SUSPENDED 배너 L26-28 아래 내용. `009030` §2 L19는 tenant와 관계 가능성을 열어 둠 | 근거 권위·관계 깊이 불일치 |
| V1-05 | Store는 tenant 소속이며 runtime 단위 | §4.5 L203-212 | `003020` §2 L20, L24; `007010` §2 L28-40; `010004` §7-8 L178-218 | 일치 |
| V1-06 | `MerchantAccount` / `merchant_account` / `tenant` 어휘쌍 | §4.2 L170-179는 Tenant를 SaaS customer/contract boundary, §4.4 L192-201은 MerchantAccount를 SaaS 계약·관리 단위로 별도 정의 | `000170` §4-5 L82-107은 merchant account를 고객 계정 context로 정의. `003020` §2 L20과 `009030` §2 L17은 tenant를 SaaS customer/contract boundary로 정의 | 두 개념의 설명 범위가 중첩되지만 동일어 선언은 없음 |
| V1-07 | `LegalEntity` / `legal_entity` / `company` 어휘쌍 | §4.3 L181-190은 LegalEntity를 계약·세무·정산 법적 주체로 정의하고 §6 L252-256은 Company를 별도 Candidate로 둠 | `000150` §7 L237-267과 `009070` L19-21은 company와 legal_entity를 별도 병렬축으로 정의 | 분리 원칙 일치 |
| V1-08 | `Person` / `owners` / 자연인 어휘쌍 | §4.1 L158-168은 자연인을 Person으로 명명하고 무수식 Owner를 금지 | `010004` L138은 Owner(자연인)를 전역 개념으로 서술. `020310` L292-298은 User Account가 사람 또는 통제된 비인간 actor를 나타낸다고 별도 정의 | `owners` 물리명은 필수 ACTIVE 11개에서 정의되지 않으며 Person/Owner/User 경계만 확인됨 |
| V1-09 | `Store` / `merchant_store` / `stores` 어휘쌍 | §4.5 L203-212는 Store를 runtime 운영 단위로 정의하고 §8 L337은 SQL `stores`와 개념 일치라고 기록 | `000170` §7 L199-235는 merchant_store를 actual operating location/runtime context로 정의. `003020` §2 L24는 store를 runtime 단위로 정의 | 핵심 의미 유사, 접두어·물리명 깊이 차이 |

## V2 — Relationship/Cardinality 대조

| ID | 대조 사실 | 601705 근거 | 인접 문서 근거 | 상태 |
|---|---|---|---|---|
| V2-01 | Tenant↔MerchantAccount 1:1 확정 | §3 L135, §5.1 L220 | `000170` §5-9 L82-107, L201-203, L238-275는 account가 하나 이상 store를 포함한다고 서술하지만 Tenant↔Account cardinality는 명시하지 않음. `020320` §40 L989-1000도 account scope가 복수 store를 포함한다고만 서술 | 지정 11개에서 1:1 독립 근거 부재 |
| V2-02 | MerchantAccount→Store 1:N | §3 L137, §5.1 L221 | `000170` L201-203, L258-275; `020320` §40 L989-1000 | 일치 |
| V2-03 | LegalEntity→MerchantAccount 1:N 허용 | §3 L136, §5.1 L222 | `000150` §7 L237-267은 legal entity와 company 분리를 서술. `000170`은 Merchant Company를 business/owner entity로 서술(L169-195). 지정 문서에는 LegalEntity→MerchantAccount 1:N의 직접 cardinality 문장이 없음 | 독립 근거 부재 |
| V2-04 | LegalEntity→Store 관계를 Formal ERD에서 `||--o{`로 표현하면서 Store당 개수는 미정이라고 선언 | §3 L139, §5.2 L232-240 | `003020` §2 L24는 store가 legal context에 may link, §6 L110-114는 versioning/cardinality를 open으로 둠 | 내부 표기 충돌: Mermaid는 Store당 정확히 1 LegalEntity로 읽힘 |
| V2-05 | Representative/PersonRole cardinality 미정인데 `}o--o{` 사용 | §3 L140-148, §5.2 L234-235 | 필수 11개에는 두 관계 cardinality 정의 없음. `000150` 개정 블록 L35-36, L61-67은 601500 결과를 인용하나 권위보류 배너 L10-12 아래 | 표기와 선언의 의미 차이 명시됨, 기계 소비 위험 존재 |
| V2-06 | Tenant→Store 1:N | §3 L138, §5.1 L223 | `003020` §2 L20, L24; `009030` §2 L17, L21 | 일치 |

## V3 — 권한·인증·경계 대조

| ID | 대조 사실 | 601705 근거 | 인접 문서 근거 | 상태 |
|---|---|---|---|---|
| V3-01 | User/Auth/Staff/Session/Role/Permission을 0-B/0-C 외부 경계로 분리 | §7.2 L293-316 | `020310` L139, L292-298, L454-468, L642; `020320` §40-41 L989-1023; `007010` §3 L68-238 | 경계 분리는 일치, 인접 문서는 내부 계약을 이미 상세 정의 |
| V3-02 | JWT subject를 특정 Store staff에 종속시키지 않음 | §7.2 L311-316 | `020310`은 User Account와 store-scoped session/role을 분리(L292-298, L906-932). `020320`은 account scope와 store scope 비확장 규칙(L989-1023) | 일치 |
| V3-03 | Franchise OS link는 권한을 자동 생성하지 않음 | §7.1 L284-291 | `000150` §11-12 L350-399, §33 L610-643; `020310` L139; `020320` L21-33, L172-176 | 일치 |
| V3-04 | `cross_business_link`를 관계로 미구현 처리 | §10 O6 L393 | `000150` §26 부근 L610-653은 explicit link 개념. `020320` L1125 부근은 cross-business scope로 취급 | 동일 어휘가 관계와 scope 두 형태로 나타남 |
| V3-05 | Company/OperatingGroup은 권한이 아니라 조직 context | §6 L252-256 | `007010`은 `company_admin`/`operating_group_manager` 역할과 scope를 정의(L93-153). `007040` L40-43, L66-71은 화면 가시성과 역할을 연결 | 개념축 자체와 그 축에 부여되는 권한을 구별해야 하는 문서 간 경계 존재 |

## V4 — 상태·런타임·금전 경계 대조

| ID | 대조 사실 | 601705 근거 | 인접 문서 근거 | 상태 |
|---|---|---|---|---|
| V4-01 | Tenant 상태축 구성을 미정으로 둠 | §4.2 L170-179 | `000170` AUTHORITY SUSPENDED 블록 L385-447은 tenant_status/isolation_state 구현을 상세 확정하지만 권위보류. 본문 §14-16 L451-524는 account/store 서비스·운영·trial 상태를 별도 축으로 정의 | 권위 상태 및 상태 소유축 불일치 |
| V4-02 | Store runtime과 MerchantAccount customer context 분리 | §4.5 L207-210 | `000170` L199-235, `003020` §2 L24, `007010` §2 L40 | 일치 |
| V4-03 | 금전 최종성은 LegalEntity context로 검증 | §4.3 L185-189, §5.2 U6 L237 | `010640` §9(문서 내 LegalEntity scope/finality), `010004` L310 및 L1012-1018은 tenant/store/legal scope 일치 요구 | 일치하나 물리 제약은 미정 |
| V4-04 | MerchantAccount는 복수 Store·다브랜드 포함 가능 | §4.4 L192-201 | `000170` L256-275; `020320` §40 L989-1000 | 일치 |
| V4-05 | Store별 서비스 상태는 ERD Core 속성에 없음 | §4.5 L203-212 | `000170` §14-16 L451-524는 merchant account 상태와 별도의 store service/operating/trial 상태를 요구 | Core 속성 범위에서 누락/후속 단계 여부 미표시 |
| V4-06 | `010004` §4의 `tenant_id` 필수 요건 반영 여부 | §4.2 L174-179는 tenant-owned 객체가 tenant 식별자를 갖는다고 기록하지만 Formal ERD는 개념 관계만 있고 속성 블록을 의도적으로 생략(§3 L130-131) | `010004` §4 L78은 `tenant_id`를 모든 tenant-owned 객체에 필수로 규정. L94-115는 전역 객체에는 적용하지 않는다고 범위를 명시 | 개념 경계로 반영, 엔티티별 적용 대상 표시는 없음 |
| V4-07 | `010640` §9 LegalEntity 금전 최종성 | §4.3 L185-189와 §5.2 U6 L237이 금전 최종성/정산 분리 제약을 기록 | `010640` L224-241은 financial action에 LegalEntity scope를 요구하고 없는 금융 객체의 finality를 금지 | 반영 |
| V4-08 | `000170` §14~§16 상태축 | §4.2 L179는 Tenant 상태축을 미정, §4.5에는 Store service/operating/trial 상태 속성이 없음 | `000170` §14 L451-474는 Store service status, §15 L476-489는 Store operating status, §16 L500-524는 trial status를 각각 정의 | 세 상태축 중 runtime 의미 일부만 서술되고 상태 속성은 미반영 |
| V4-09 | `009070` company ≠ operating_group | §6 L252-256은 Company/BusinessUnit/OperatingGroup을 별도 Candidate 항목으로 나열 | `009070` L19-21, L30-33은 company와 operating_group을 별도 병렬 context axes로 정의 | 분리 반영 |

## V5 — `601705`와 권위보류 `601501` 유사성 사실 비교

> `601501`은 AUTHORITY SUSPENDED 문서다. 아래 표는 정합성 근거 또는 채택 판단이 아니라 두 산출물의 같은 지점을 사실로 비교한 것이다.

| # | 항목 | 601705 | 601501 | 같은가 | 비고 |
|---|---|---|---|---|---|
| 1 | 자연인 축 | `Person` 개념명, 무수식 Owner 금지(§4.1 L158-168) | `owners` 테이블을 자연인으로 정의(§2.4 L389-419) | 부분 같음 | 존재 대상은 유사하나 개념명과 물리명 깊이가 다름 |
| 2 | LegalEntity 전역성 | tenant 직접 종속 없는 전역 개념(§4.3 L181-190) | 전역 테이블이며 tenant_id 없음(§0.1 L60-65, §2.7.6 L652-667) | 같음 | 601501은 물리 접근경로까지 정의 |
| 3 | LegalEntity→Store | 1:N 관계를 그리고 Store당 개수·이력은 미정(§3 L139, §5.2 L232-240) | Store당 정확히 1 LegalEntity, `stores.legal_entity_id`(L49, §1.1 L271-277) | 부분 같음 | 관계 존재/1:N은 유사, 역방향 cardinality 확정 여부가 다름 |
| 4 | Tenant→Store | 1:N(§3 L138, §5.1 L223) | 1:N, `stores.tenant_id`(§1.1 L274) | 같음 | — |
| 5 | Tenant↔MerchantAccount | 별도 Core 두 축, 1:1(§3 L135, §5.1 L220) | MerchantAccount 엔티티 없음; tenants 유지(§0.1 L60-65, 전체 ERD) | 다름 | 601501에는 대응 물리/개념 엔티티가 없음 |
| 6 | Company 축 | Candidate이며 persistent entity 미결(§6 L252-266) | company=기존 `franchise_brands`, operating_group=`store_groups`로 매핑(§0.3 L70-86) | 다름 | 601501은 물리 대응을 확정 |
| 7 | Representative | Person↔LegalEntity 축 존재, cardinality 미정(§3 L140, §5.2 L234) | `legal_entity_representatives`, Owner↔LegalEntity N:M(§1.1 L272, §2.5 L423-451) | 부분 같음 | 축/별도 관계는 유사, cardinality·물리화 차이 |
| 8 | PersonRole | Person↔LegalEntity 축 존재, cardinality 미정(§3 L141, §5.2 L235) | `legal_entity_person_roles`, Owner↔LegalEntity N:M(§1.1 L271, §2.3 L352-365) | 부분 같음 | 동상 |
| 9 | 지분소유 | 역할과 별개라고 선언하고 미모델링(§5.2 U5 L236, §9 L355) | 소유권은 미모델링, `ownership_percent` 사용 금지(§0.6 L113-134, §2.3.1 L372-382) | 같음 | 601501에 잔존 컬럼은 있으나 모델로 사용 금지 |
| 10 | Store 법적주체 시간성 | 개수·이력 모두 미정(§5.2 U1-U2 L232-233) | 현재 FK와 과거 재해석 위험을 Open Item으로 기록(§7(u) L838) | 부분 같음 | 둘 다 시간성 문제를 완료하지 않음 |
| 11 | Tenant 상태 | 구성 미정(§4.2 L179) | tenant_status/isolation_state 2축 확정(§3 L686-737) | 다름 | — |
| 12 | 권한 경계 | User/Auth/Staff/Session/RBAC을 0-B/0-C로 인계(§7.2 L293-316) | owners는 인증주체가 아니며 0-B/0-C 소관(§2.4 L408-417) | 같음 | — |

## 부가 검증 — 문서 권위·완전성·추적성

| ID | 대조 사실 | 근거 | 상태 |
|---|---|---|---|
| A-01 | 601705는 ACTIVE source documents를 2순위로 채택한다고 선언 | 601705 §0.2 L37-45 | 기준 명시 |
| A-02 | 필수 문서 `000150`, `000170`, `003020`, `009030`에는 AUTHORITY SUSPENDED 역전파 블록이 포함됨 | `000150` L10-12, `000170` L385-387, `003020` L26-28, `009030` L23-25 | 동일 파일 안 ACTIVE 본문과 권위보류 삽입분 혼재 |
| A-03 | 601705가 `003020`을 관계 근거로 사용하면서 개정 삽입분 일부를 Physical Drift 사실로 소비 | 601705 §4.2-§4.5, §8 L325-345; `003020` L43-75 | 어떤 절이 ACTIVE 원문이고 어떤 절이 권위보류 삽입분인지 인용마다 구분되지 않음 |
| A-04 | 1단계 대응 집계가 `§1.1~§1.24`를 24개로 세나 §1.18.1도 별도 행으로 포함 | 601705 §9 L347-380 | 표 행 기준으로는 25개 항목이며 집계 12+7+5=24와 대응 방식 불명확 |
| A-05 | Formal ERD는 “확정 관계만” 그린다고 선언하면서 cardinality 미정 관계 2개를 그림 | 601705 §3 L125-148 | 선언과 산출물 형식 충돌 |
| A-06 | 필수 11개 중 `007010`, `007040`, `020310`은 601705 §11 근거 목록에 없음 | 601705 §11 L399-415 | 인접 도메인 추적 목록 불완전 |

## 필수 11개 문서 전수 대조 종합

| # | 문서 | 대조 절/줄 | 핵심 관찰 |
|---|---|---|---|
| 1 | `000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | 배너 L10-12; §4 L149-173; §7 L237-267; §11-12 L350-399; §33 L610-643 | Company/BusinessUnit/LegalEntity 분리와 cross-business 명시 링크. 권위보류 역전파 블록 혼재 |
| 2 | `000170_Policy_Merchant_Account_Company_And_Store_Context.md` | §4-9 L82-275; 배너 L385-387; §14-16 L451-524 | MerchantAccount/Company/Store 분리, account→store 1:N, store별 상태축. 권위보류 구현 어휘 혼재 |
| 3 | `003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md` | §2 L16-24; 배너 L26-28; §3 L77-90; §6 L108-114 | 기존 5축과 관계/open decision. 권위보류 구현 결론 혼재 |
| 4 | `009030_Register_Conceptual_Entity_Master.md` | §2 L17-21; 배너 L23-25; 구현 대응 L37-51 | 기존 5축 registry와 open questions. 권위보류 구현 대응 혼재 |
| 5 | `009070_Matrix_Context_Entity_Alignment_Model.md` | §2 L14-21; §3 L27-33; §6 L53-59 | company/legal_entity/operating_group 병렬축과 persistence open |
| 6 | `010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | §7-8 L178-218; provider scope L310; 결론 L1012-1018 | 모든 객체의 tenant/store/legal scope envelope 및 격리 |
| 7 | `010640_Policy_Tenant_Scope_Envelope.md` | §4, §9, §11 | LegalEntity 금전 최종성 및 franchise_hq scope 차원 |
| 8 | `007010_Policy_Admin_Console_Context_And_Role_Model.md` | §2 L20-40; §3 L68-238; open L293-296 | 기존 5축을 관리화면·역할 scope로 사용 |
| 9 | `007040_Policy_Admin_Screen_Inventory_And_Navigation_Model.md` | L38-60; role visibility L66-72 | Tenant/Company/LegalEntity/OperatingGroup/Store별 화면이 존재하는 것으로 정의 |
| 10 | `020310_Policy_User_Account_And_Login.md` | L139; L292-298; L454-468; L642; L906-932 | Person/non-human User Account, merchant/store scope, session 비영구 권한 |
| 11 | `020320_Policy_Role_Permission_And_Scope.md` | L21-33; §40-41 L989-1023; cross-business L1125 | MerchantAccount/Store scope 분리와 비확장, Franchise OS 권한 비자동화 |

## Blocker

| B# | 사실 | 정확한 근거 |
|---|---|---|
| B1 | Formal ERD가 Store당 LegalEntity cardinality를 `||--o{`로 확정 표기하지만 본문은 미정으로 선언 | 601705 L139 vs L232-240 |
| B2 | Formal ERD가 cardinality 미정인 Representative/PersonRole을 N:M 기호로 포함하여 “확정 관계만 그린다” 선언과 충돌 | 601705 L127-148, L234-235 |
| B3 | Tenant↔MerchantAccount 1:1과 LegalEntity→MerchantAccount 1:N은 필수 11개에서 독립 cardinality 근거가 확인되지 않고 601702 Human Decision에만 의존 | 601705 L135-136, L220-222 |
| B4 | Core 5축 정의가 문서군마다 다름: 601705는 Person/Tenant/MerchantAccount/Store/LegalEntity, 기존 registry는 tenant/company/legal_entity/operating_group/store | 601705 L89-106 vs 003020 L20-24, 009030 L17-21, 009070 L18-21 |
| B5 | 필수 근거 문서 4개에 ACTIVE 본문과 AUTHORITY SUSPENDED 역전파 블록이 같은 파일에 혼재하며 601705 인용은 절별 권위 구분을 표시하지 않음 | 000150 L10-12; 000170 L385-387; 003020 L26-28; 009030 L23-25; 601705 L401-413 |
| B6 | 필수 인접 문서 3개가 601705 근거 목록에서 누락 | 601705 L399-415; 누락: 007010, 007040, 020310 |

## 추가 탐색 문서

지정 제외 경로(`601500`, `601600`, `_migration_history`)와 KO 문서를 제외하고, 필수 11개가 직접 참조하거나 Core 축 계약을 확장하는 문서를 추적했다.

| 문서 | 발견 경로 | 관련 정의 |
|---|---|---|
| `docs/003000_saas_runtime/003030_Guide_Store_Runtime_Profile_Model.md` | `003020` §5 교차참조 | Store runtime/profile을 Store에 종속된 별도 컨테이너로 정의(L5-29) |
| `docs/020000_validation_security_audit/020330_Policy_Merchant_User_And_Store_Access.md` | `020310`/`020320`의 Merchant User and Store Access 참조 | MerchantAccount scope와 Store scope 분리(L7-19, L83-116), account의 복수 store(L688-708) |
| `docs/013000_app_api_projection/013080_Matrix_Store_Admin_Support_Action_Authority.md` | `007040` L113 직접 참조 | store/company/tenant/operating_group 역할별 action authority(L15-20, L54-72) |

## 종합

- 필수 문서 11개 전부 대조 완료.
- V1~V5 발견: **41건**(V1 9 + V2 6 + V3 5 + V4 9 + V5 12).
- 부가 검증: **6건**.
- Blocker: **6건**.
- 추가 탐색 문서: **3건**.
- 본 보고서는 일치, 불일치, 근거 부재, 권위 혼재를 사실로 기록했으며 어느 쪽의 우선성도 판정하지 않았다.
