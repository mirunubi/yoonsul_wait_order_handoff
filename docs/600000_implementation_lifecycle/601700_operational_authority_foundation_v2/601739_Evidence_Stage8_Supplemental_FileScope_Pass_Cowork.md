# 601739_Evidence_Stage8_Supplemental_FileScope_Pass_Cowork.md

> 수행: **Cowork**, 2026-08-24
> 성격: **Post-Implementation Supplemental TestPlan Evidence Pass — file-scope 한정**
> 권한: 비구속 독립 증거 수집자

---

## §0 이 문서의 지위

```text
601739 is verification evidence created after
the implementation delta was measured.
It is not part of the Stage 8 implementation delta.
```

**이 결과는 Stage 9 VerificationResult 를 대체하지 않는다.**
`000701` 은 Stage 9 공식 구현 검증자를 **Claude Code** 로 두고 Critical tier 에서 **Cursor** 를 추가한다.
**Cowork 은 정규 actor 가 아니다.** 이 문서는 Stage 9 의 입력 자료일 뿐이다.

### §0.1 원작자 배제 확인 (PRE-8)

| 문서 · 산출물 | 작성·구현 | Cowork 관여 |
|---|---|---|
| `601710` / `601713` / `601716` / `601717` | Claude Code | 없음 |
| `0170` / `0171` | Codex | 없음 |

**Claude Code · Codex 는 검증자 풀에서 제외된다.** Cowork 은 위 문서를 작성하지 않았고 구현하지도 않았다 — `000701` §37 충족. → `AC-13` PASS.

### §0.2 실행 시점 — post-implementation

| 문서 기재값 | 이번 실행 시점 실제값 |
|---|---|
| PRE-1 Stage 7 「대기」 | **APPROVED_FOR_IMPLEMENTATION** (2026-08-23) |
| PRE-3 최신 migration `0169` | **`0171`** |
| PRE-6 `stores` 컬럼 16 | **17** (문서 기재 · 이번 pass 미실측) |

**pre-implementation 기대값으로 drift 판정하지 않았다.**

```text
적용 커밋      0170  b657ec23ce5493c7561cd1139c93c6ee2bc21090
               0171  bc4cd14deaea6d696d573d437163ab42d4f93619
승인 기준 커밋  601717  01cfd45bab7710b0db2a4957b7e540bebfad7377
저장소 HEAD    bc4cd14  ·  git status --short 출력 0행 (clean)
```

### §0.3 범위 — file-scope only

**이 환경은 DB 에 도달할 수 없음이 이번 pass 에서 재측정으로 재확인됐다** — §6 참조.

```text
수행     판본·EOL 검증 / implementation delta / TP-B / TP-M 문서 검사분
         문서·파일 정합성으로 판정 가능한 항목
미수행   DB 실측이 필요한 전건  → SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)
         PowerShell 필요분      → SKIP(NO_POWERSHELL_IN_SUPPLEMENTAL_ENV)
         → 공식 Stage 9(Claude Code · Cursor)로 이관
```

**SKIP 을 PASS 로 적지 않았다.** 저장소는 읽기 전용으로만 사용했고 git write 명령을 0회 실행했다.

---

## §1 승인판 hash · EOL 검증

| 항목 | 기대값 | 실측값 | 판정 |
|---|---|---|---|
| `601716` SHA-256 (§10.8 기록값) | `00C1376E…19F102` | `00c1376eb1230a4b68f27c1479681c5bc95b23a8801ee70364eaacf22719f102` | **일치** |
| 측정 기준 — repository LF content | `git show HEAD:<경로>` | 동일 해시 | **일치** |
| 측정 기준 — 승인 커밋 blob | `git show 01cfd45b:<경로>` | 동일 해시 | **일치** |
| 측정 기준 — 작업트리 파일 | `sha256sum <경로>` | 동일 해시 | **일치** |
| `601716` EOL (§10.9 대조 절차 0단계) | `w/lf` | `i/lf  w/lf  attr/` | **일치** |
| `601717` EOL | `w/lf` | `i/lf  w/lf  attr/` | **일치** |
| `0170` / `0171` EOL | LF | `i/lf  w/lf  attr/text eol=lf` | **일치** |
| `601717` 최종 변경 커밋 | §10.10 기록 `01cfd45b` | `accf0666` (§10.9 5단계 커밋) | **정합** |

> **`601717` 이 승인 커밋 이후 1회 변경됐다.** `accf0666` 의 diff 는 §10.10 의
> `601717 기준 커밋 (승인 커밋 후 측정해 기록)` → `01cfd45bab77…` **1행 치환뿐**이며,
> §10.9 「기록 시점 — 순서를 지킨다」 5단계가 지시한 기록 행위다.
> 대조 절차 2~3단계의 「현재 최종 커밋이 5단계 커밋이면 그 차이는 이 기록 추가분뿐이다」와 일치한다.
>
> ```text
> 601717 blob sha256 @ 01cfd45b   e4571928c40199cda6eab54bc37efc298dc1fb3d0aa2a2ce7c8b9636250ae5fb
> 601717 blob sha256 @ HEAD       ab30aaee0be808cfa8f1df80488ca1d448697f78e02188b2562e9d1cdbd29bcf
> 차이                            1행 (+1 / -1)
> ```

---

## §2 implementation commit 범위 고정 및 커밋 단위 분리

**범위: `01cfd45b` → `bc4cd14` — 커밋 4건.**

| 순서 | 커밋 | 일시 (KST) | 제목 | 변경 파일 | 성격 |
|---|---|---|---|---|---|
| 1 | `accf0666` | 2026-08-23 23:25 | docs: approval commit recorded in the contract | `601717` (M) | **Stage 7 기록** (§10.9 5단계) |
| 2 | `df49eb56` | 2026-08-24 10:50 | docs: 601736-601738 round-5 verification reports registered | `000005`(M) `000007`(M) `601736`·`601737`·`601738`(A) | **Stage 6 산출물 등록** |
| 3 | `b657ec23` | 2026-08-24 11:15 | feat: 0170 person vocabulary normalization | `sql/migrations/0170_…sql` (A) | **Stage 8 구현** |
| 4 | `bc4cd14` | 2026-08-24 11:31 | feat: 0171 merchant account foundation | `sql/migrations/0171_…sql` (A) | **Stage 8 구현** |

```text
Stage 8 implementation delta  =  b657ec23 ∪ bc4cd14
                              =  { sql/migrations/0170_person_vocabulary_normalization.sql,
                                   sql/migrations/0171_merchant_account_foundation.sql }
```

**`601717` §1 이 색인 3종 동기화를 허용 목록에 두는가 — 확인 결과 「둔다」.**

| # | 경로 | §1 근거 | 범위 내 변경 |
|---|---|---|---|
| A-4 | `601700_Readme_…V2.md` §8 File List | §1.2 (Stage 10, 기계적) | 0건 |
| A-5 | `docs/000005_Index_Document_Number.md` | 동일 | 1건 (`df49eb56`) |
| A-6 | `docs/000007_Map_Full_Directory.md` | 동일 | 1건 (`df49eb56`) |

> **A-5·A-6 은 허용 목록 안에 있으나, 이번 변경의 내용은 `601722_Module` 등록이 아니라
> `601736`~`601738` Round-5 검증 보고서 등록이다** (diff 실측 — 각 3행 추가).

### §2.1 누적 범위 관측 (OBS) — Stage 8 델타 밖

**아래는 Test 판정이 아니라 관측 기록이다. 커밋 단위 분리로 Stage 8 델타에서 배제됐다.**

| # | 관측 | Stage 9 확인 필요 |
|---|---|---|
| **OBS-1** | `601717` 이 승인 커밋 이후 `accf0666` 으로 1회 변경됐다. §5 X-9 는 「개정은 Stage 6/7 경로로만」이며 이 변경은 §10.9 5단계가 지시한 Stage 7 경로 행위다. 실행 의미 변경 0 | 확인 권고 |
| **OBS-2** | `601736`·`601737`·`601738` 3파일이 `df49eb56` 으로 신규 추가됐다. §1 허용 목록(A-1~A-6)에 없고, §5 X-10 열거는 `601723`~`601735` 에서 끝나 이 3건을 다루지 않는다. Stage 6 Round-5 산출물이며 승인(2026-08-23 23:20) 이후 · 구현(2026-08-24 11:15) 이전에 등록됐다 | **확인 필요** |
| **OBS-3** | A-3 `601722_Module_Operational_Authority_Foundation_V2.md` 가 아직 생성되지 않았다. Stage 10 소관이므로 Stage 8 위반이 아니다 | 정보 |
| **OBS-4** | `AC-11` 판정 시 확인 — `601717` §10 전체에 `N-6″`·`N-7″`·`N-8″` 가 이름으로 등장하지 않는다. 제외 사실은 `601716` §12.3 과 `601717` §7.3 에만 기재돼 있다. 계약 §9.4 AC-9 는 「§7 blocker 중 미해소분이 Stage 7 Approval 에 **제외 사실로 명시**」를 요구한다 | **확인 필요** |
| **OBS-5** | `FO-34`(Stage 7 승인 전 migration 적용·커밋) 위반 없음 — 승인 `08-23 23:20` < 구현 커밋 `08-24 11:15`/`11:31` | 정보 |

---

## §3 Test ID inventory 재확인

**`601716` 14판에서 기계적으로 재추출했다.**

| 접두 | 직전 pass | 이번 확인 | 일치 |
|---|---:|---:|---|
| `BL-` | 38 | 38 | ✅ |
| `TP-P-` | 38 | 38 | ✅ |
| `TP-N-` | 65 | 65 | ✅ |
| `TP-D-` | 9 | 9 | ✅ |
| `TP-R-` | 20 | 20 | ✅ |
| `TP-RB-` | 8 | 8 | ✅ |
| `TP-RT-` | 7 | 7 | ✅ |
| `TP-B-` | 8 | 8 | ✅ |
| `TP-M-` | 11 | 11 | ✅ |
| `TP-X-` | 13 | 13 | ✅ |
| `AC-` | 18 | 18 | ✅ |
| **합계** | **235** | **235** | ✅ |

**전건 일치. 중단 사유 없음.**

**추출 보정 2건 — 근거를 명시한다.**

```text
BL-3 · BL-4     §2.1 표가 「BL-2~4」 한 행으로 접어 두어 토큰이 나타나지 않는다.
                BL-1 … BL-38 연속 정의이므로 38건으로 센다.

TP-RT-03        10판 F-5 처분으로 폐기(취소선). 대체 = TP-N-62~64.
TP-N-63(종전)   R2-F3 처분으로 폐기(취소선). ID 는 재정의되어 살아 있으므로
                TP-N- 총계는 변하지 않는다.
                → 「폐기 취소선 2건 제외」의 실제 감소분은 TP-RT-03 1건이며,
                  raw unique 236 − 1 = 235 로 직전 pass 와 일치한다.
```

---

## §4 전건 결과표

**모든 Test 를 기록한다. 판정은 `PASS` / `FAIL` / `SKIP(사유)` 뿐이다.**

### BL — 기준선 (§2.1)

| Test ID | 기대값 | 실측값 | 판정 | 근거 |
|---|---|---|---|---|
| `BL-1` | before=0 / after=0 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-2` | before=0 / after=0 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-3` | before=0 / after=0 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-4` | before=0 / after=0 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-5` | before=1 / after=1 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-6` | before=0 / after=0 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-7` | before=20 / after=21 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-8` | before=0 / after=0 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-9` | before=0 / after=0 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-10` | before=ENABLE+FORCE / after=동일(대상 persons) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-11` | before=4, is_grantable=NO / after=4 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-12` | before=114 / after=115 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-13` | before=0 / after=0 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-14` | before=5 / after=5 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-15` | before=0 / after=1 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-16` | before=5 / after=선언된 증가분만 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-17` | before=0 / after=0 | 0건 (identifier 기준) | `PASS` | repo grep — `apps` `packages` `catchmenu_app` `tests` `sql/seed_yoonsul_menu.sql` 에서 `catchmenu_hq.owners`·`owner_id` 식별자 0건. 자연어 'owners' 10건(NOTICES 저작권문·README 산문)은 식별자 참조가 아니다 — `601711` P-5 와 동일 판정 기준 |
| `BL-18` | before=5개 / after=동일 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-19` | before=0 / after=0 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-20` | before=10컬럼, 1행, RLS ENABLE+FORCE / after=무변경 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-21` | before=16 (601701 기록과 차이 0) / after=17 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-22` | before=158 (601701 기록은 151 — 601702 §2.2) / after=158 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-23` | before=10 / after=10 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-24` | before=(테이블 없음) / after=1 (= tenants 행 수) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-25` | before=(컬럼 없음) / after=1 (= stores 행 수) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-26` | before=기존 값 / after=변경됨 (M-2 가 trg_stores_updated_at 발동) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-27` | before=TRIAL / NONE / after=무변경 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-28` | before=2 — catchmenu_common.provision_tenant / catchmenu_hq.create_franchise_store / after=2, 본문 불변 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-29` | before=0 / 0 / after=0 / 0 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-30` | before=0 / after=0 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-31` | before=2 — catchmenu_common.onboard_tenant(brand_id) / catchmenu_store.update_business_hours / after=2, 본문 불변 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-32` | before=0 / after=0 | 0건 | `PASS` | repo grep — 앱 코드 `INSERT INTO …stores` 0건. 범위 내 `apps`/`packages`/`catchmenu_app`/`tests` 변경 0파일 |
| `BL-33` | before=241 (internal 240 / user 1 trg_stores_updated_at) / after=241 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-34` | before=0 / 0 / after=0 / 0 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-35` | before=f84ac1a81da4ccba87930bf020a3e974 / 4758 / after=동일 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-36` | before=87511a95676a41d2c95866e0c2da8b7f / 3460 / after=동일 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-37` | before=둘 다 부재 / after=둘 다 부재 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `BL-38` | before=text NOT NULL, 1행 / after=무변경 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |

### TP-P — Positive (§4.1·§4.2)

| Test ID | 기대값 | 실측값 | 판정 | 근거 |
|---|---|---|---|---|
| `TP-P-01` | 1건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-02` | 1건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-03` | 1건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-04` | 1건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-05` | 2건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-06` | 2건 모두 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-07` | 2건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-08` | 1건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-09` | 1건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-10` | 1건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-11` | 1건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-12` | 1건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-13` | 1건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-14` | 둘 다 true | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-15` | 4건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-16` | BL-11 대비 동일 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-17` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-18` | 1건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-19` | 6컬럼 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-20` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-21` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-22` | 유지 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-23` | 완전 일치 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-24` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-25` | 1건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-26` | 일치 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-27` | exact 일치 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-28` | 참 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-29` | 1건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-30` | 일치 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-31` | 2건 일치 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-32` | exact 일치 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-33` | 둘 다 true | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-34` | 1건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-35` | 참 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-36` | 1건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-37` | 2건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-P-38` | 3건 모두 완전 일치 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |

### TP-N — Negative (§5)

| Test ID | 기대값 | 실측값 | 판정 | 근거 |
|---|---|---|---|---|
| `TP-N-01` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-02` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-03` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-04` | 0건 (BL-8) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-05` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-06` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-07` | 불변 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-08` | 불변 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-09` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-10` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-11` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-12` | 유지 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-13` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-14` | 정확히 4건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-15` | 불변 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-16` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-17` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-18` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-19` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-20` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-21` | 5 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-22` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-23` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-24` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-25` | is_nullable = YES | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-26` | 0행 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-27` | 0행 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-28` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-29` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-30` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-31` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-32` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-33` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-34` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-35` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-36` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-37` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-38` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-39` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-40` | is_nullable = YES | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-41` | is_nullable = NO | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-42` | 0건 | 0건 | `PASS` | `0170`+`0171` 본문 정규식 `SET\s+NOT\s+NULL` 0건 |
| `TP-N-43` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-44` | 정확히 1건 | 정확히 1건 (`merchant_accounts` 대상) | `PASS` | `INSERT INTO` 1건 = M-1, 대상 `catchmenu_hq.merchant_accounts` |
| `TP-N-45` | 정확히 1건 | 정확히 1건 (`stores.merchant_account_id` 대상) | `PASS` | `UPDATE` 1건 = M-2, `SET merchant_account_id = ma.id` |
| `TP-N-46` | 0건 | 0건 | `PASS` | `DELETE FROM` 0건 |
| `TP-N-47` | 리터럴 0건 | 리터럴 0건 | `PASS` | M-1 = `INSERT … SELECT FROM catchmenu_hq.tenants`, M-2 = `UPDATE … FROM catchmenu_hq.merchant_accounts`. `VALUES` 절 0건, business data 리터럴 0건 |
| `TP-N-48` | 0행 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-49` | 나머지 전부 불변 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-50` | 일치 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-51` | 일치 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-52` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-53` | 불변 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-54` | 2건 (BL-28) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-55` | 2건 (BL-31) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-56` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-57` | 0건 | 0건 | `PASS` | `git diff --name-only 01cfd45b bc4cd14 -- sql/seed_yoonsul_menu.sql` → 0 |
| `TP-N-58` | 불변 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-59` | 0건 (BL-37) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-60` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-61` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-62` | f84ac1a81da4ccba87930bf020a3e974 (len 4758) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-63` | 2건 모두 충족 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-64` | BL-20 유지 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-N-65` | 정확히 2건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |

### TP-D — Data / backfill (§4.4)

| Test ID | 기대값 | 실측값 | 판정 | 근거 |
|---|---|---|---|---|
| `TP-D-01` | 일치 (PRE-5 재측정값) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-D-02` | 누락 0 · 중복 0 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-D-03` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-D-04` | 전 행 일치 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-D-05` | 전 행 일치 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-D-06` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-D-07` | BL-5·BL-20 유지 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-D-08` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-D-09` | 일치 | §4.5.1 확정 SQL 과 바이트 동일 | `PASS` | `0171` M-1 절이 `601717` §4.5.1 코드블록과 exact substring 일치 (개행 포함) |

### TP-R — Regression (§6)

| Test ID | 기대값 | 실측값 | 판정 | 근거 |
|---|---|---|---|---|
| `TP-R-01` | 21 (BL-7) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-R-02` | 115 (BL-12) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-R-03` | 불변 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-R-04` | 불변 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-R-05` | 불변 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-R-06` | 17 (BL-21) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-R-07` | 불변 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-R-08` | 불변 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-R-09` | 불변 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-R-10` | BL-18 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-R-11` | 불변 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-R-12` | 0건 (BL-13) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-R-13` | 0건 (BL-17) | 0건 (identifier 기준) | `PASS` | BL-17 과 동일 측정. 범위 내 해당 경로 변경 0파일 |
| `TP-R-14` | before/after 모두 158건, 본문 불변 (BL-22) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-R-15` | 10건 존재, 본문 불변 (BL-23) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-R-16` | 동일 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-R-17` | 불변 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-R-18` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-R-19` | 241 (BL-33) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-R-20` | 0 / 0 (BL-34) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |

### TP-RB — Rollback (§11)

| Test ID | 기대값 | 실측값 | 판정 | 근거 |
|---|---|---|---|---|
| `TP-RB-01` | 가능 | 가능 — 명시됨 | `PASS` | `601717` §9.1 R-1 「rollback 은 역방향 신규 migration 으로만 수행한다」 |
| `TP-RB-02` | 전제 없음 | 전제 없음 | `PASS` | R-1 이 역방향 신규 migration 으로 한정. `0170`/`0171` 수정·삭제 전제 문면 0건. `000701` §14.5 불변과 정합 |
| `TP-RB-03` | 복원 (BL-26 제외) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-RB-04` | 복원 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-RB-05` | 0행 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-RB-06` | 명시 | 명시됨 | `PASS` | `601717` §9.1 R-6 「`stores.updated_at` 은 복원되지 않는다」 + R-5 가 BL-26 을 명시 제외 |
| `TP-RB-07` | 참 | 참 | `PASS` | `601717` §9.1 R-2 「rollback 순서는 `0171` 역 → `0170` 역」 |
| `TP-RB-08` | 불변 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |

### TP-RT — Runtime Behavior (§10)

| Test ID | 기대값 | 실측값 | 판정 | 근거 |
|---|---|---|---|---|
| `TP-RT-01` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-RT-02` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-RT-04` | 동일 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-RT-05` | 불변 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-RT-06` | 도달 0 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-RT-07` | 불변 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-RT-08` | 동일 오류 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |

### TP-B — Boundary / Forbidden File (§8)

| Test ID | 기대값 | 실측값 | 판정 | 근거 |
|---|---|---|---|---|
| `TP-B-01` | 부분집합 | 부분집합 (2/2) | `PASS` | Stage 8 구현 델타 = `b657ec23` ∪ `bc4cd14` = {`0170`,`0171`} ⊂ {A-1,A-2}. 범위 내 문서 커밋 2건은 커밋 단위 분리 — OBS-1·OBS-2 |
| `TP-B-02` | 0건 | 0건 | `PASS` | Stage 8 구현 델타에 §5 X-1~X-21 해당 파일 0건 |
| `TP-B-03` | 0건 | 0건 | `PASS` | `git diff --name-status … -- sql/` = `A` 2건뿐. 기존 169개 `.sql` 전건 `M`/`D` 0건 (총 171 − 신규 2 = 169) |
| `TP-B-04` | 0건 | 0건 | `PASS` | `git diff --name-only … -- apps packages catchmenu_app tests` → 0. `tools/` 변경 0건 |
| `TP-B-05` | 0건 | 0건 | `PASS` | `supabase/` 변경 0건 |
| `TP-B-06` | 범위 내 | 범위 내 (구현 델타 docs 변경 0건) | `PASS` | Stage 8 구현 델타의 `docs/` 변경 0건. B-9 대상 27~30건 정합화 문서 미변경. `601722_Module_…` 미생성 = Stage 10 소관, Stage 8 위반 아님 — OBS-3 |
| `TP-B-07` | 0건 | 0건 | `PASS` | 열거 문서 전건 미변경 (`601723`~`601735` 포함) |
| `TP-B-08` | 2개 | 2개 | `PASS` | `sql/migrations/` 신규 = `0170_…sql` · `0171_…sql` 정확히 2개 |

### TP-M — Migration / Schema (§9)

| Test ID | 기대값 | 실측값 | 판정 | 근거 |
|---|---|---|---|---|
| `TP-M-01` | 2건 모두 | 2건 모두 1행 | `PASS` | 두 파일 모두 1행이 `-- Workpacket: 601700` — 상단 5행 이내 |
| `TP-M-02` | 0건 | 미측정 | `SKIP(NO_POWERSHELL_IN_SUPPLEMENTAL_ENV)` | `tools/Check-Governance.ps1` 실행에 PowerShell 필요 — 두 환경 모두 `pwsh`/`powershell` 부재 |
| `TP-M-03` | 0건 | 미측정 | `SKIP(NO_POWERSHELL_IN_SUPPLEMENTAL_ENV)` | `tools/Check-Governance.ps1` 실행에 PowerShell 필요 — 두 환경 모두 `pwsh`/`powershell` 부재 |
| `TP-M-04` | 참 | 참 | `PASS` | `0170_`/`0171_` 각 1파일. 직전 최신 `0169`. 번호 중복 0건 |
| `TP-M-05` | 2행 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-M-06` | 참 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-M-07` | 참 | 테이블생성 → stores 컬럼·FK·인덱스 → M-1 → M-2 | `FAIL` | 실제 순서 D-14→D-15→D-16→D-17→D-18→D-19→D-20→D-21→M-1→M-2. 기대 문면은 M-1 이 stores 컬럼·FK·인덱스 **앞**에 오도록 적혀 있으나 실제는 **뒤**다. 참조 무결성은 두 순서 모두 성립하며, 실제 순서는 `601717` §1.4 D-14~D-21 → §4.5 M-1·M-2 번호 순서와 일치한다 |
| `TP-M-08` | 성공 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-M-09` | 0건 | 0건 | `PASS` | `CASCADE` 정규식 0건 (두 파일) |
| `TP-M-10` | 0건 | 0건 | `PASS` | `DROP TABLE` 0건 |
| `TP-M-11` | 0건 | 0건 | `PASS` | `CREATE OR REPLACE FUNCTION` 0건. `CREATE FUNCTION` 도 0건 |

### TP-X — External Provider (§7)

| Test ID | 기대값 | 실측값 | 판정 | 근거 |
|---|---|---|---|---|
| `TP-X-01` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-X-02` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-X-03` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-X-04` | 정확히 1개 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-X-05` | 정확히 1건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-X-06` | 대조 일치 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-X-07` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-X-08` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-X-09` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-X-10` | 원천 1개 | 원천 1개 | `PASS` | M-1 의 `FROM` 절 = `catchmenu_hq.tenants` 단일. M-2 의 `FROM` = `catchmenu_hq.merchant_accounts`(M-1 파생). provider 계열 원천 0건 |
| `TP-X-11` | 0건 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `TP-X-12` | 조항 존재 | 조항 존재 | `PASS` | `601717` §4.6 「External Provider Mapping 명시적 금지」 9행 + §6.3 FO-21 |
| `TP-X-13` | 0건 | 0건 | `PASS` | 두 파일 본문에 `provider`·`external`·`mapping`·`van_merchant`·`pos_store_config`·`toss`·`okpos`·`kicc`·`smartcast`·`payment`·`integration` 토큰 0건 |

### AC — Acceptance Criteria (§13)

| Test ID | 기대값 | 실측값 | 판정 | 근거 |
|---|---|---|---|---|
| `AC-1` | §2 Preconditions PRE-1~PRE-8 이 모두 충족됐다 — PRE-3·5·6·7 은 environment drift 게이트다 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `AC-2` | §4 Positive 중 BLOCKED 가 아닌 항목이 전부 PASS 다 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `AC-3` | §4.3 에 따라 컬럼명·타입 기대값이 601717 §4.1 로 확정된 뒤 실행됐다 | 충족 | `PASS` | `601717` §4.1 이 Stage 7 Human 확정값(2026-08-23)이고 `601716` §4.3 이 확정 완료를 기록. `0171` D-14 가 그 5컬럼 정의와 일치 |
| `AC-4` | §4.4 backfill 검증 TP-D-01~TP-D-09 가 전부 PASS 다 — TP-D-09(backfill 구문이 601717 §4.5.1 확정 SQL 과 동일) 포함(R2-F5 처분. 종전 범위는 TP-D-08 까지였다) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `AC-5` | §5 Negative 전 항목이 PASS 다. 하나라도 FAIL 이면 전체 FAIL | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `AC-6` | §5.6 · §5.7 · §5.9 가 전부 PASS 다 — NOT NULL 미적용, 두 INSERT RPC 무변경, TP-N-62~64(TP-RT-03 폐기 대체 — R2C-3 처분) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `AC-7` | §6 Regression 전 항목이 PASS 다 — TP-R-14·TP-R-15 는 모집단·본문 기준선 불변으로 판정한다(R3-F1). known pre-existing phantom defect 를 이 항목의 FAIL 사유로 삼지 않는다 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `AC-8` | §7 External Provider negative 전 항목이 PASS 다 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `AC-9` | §8 Boundary · §9 Migration 전 항목이 PASS 다 | 불충족 | `FAIL` | §9 Migration 중 TP-M-07 이 FAIL — 「§8 Boundary · §9 Migration 전 항목이 PASS」를 만족하지 않는다. §8 Boundary 는 8/8 PASS |
| `AC-10` | §11 Rollback 계획이 문서로 존재하고 TP-RB-01·TP-RB-02·TP-RB-06·TP-RB-07 을 만족한다 | 충족 | `PASS` | rollback 계획 = `601717` §9.1 R-1~R-7 문서 존재. TP-RB-01·02·06·07 전건 PASS |
| `AC-11` | §12.2·§12.3 의 blocker 중 해당 범위에 걸리는 것이 Human 판정으로 해소됐거나 구현에서 제외됐다 | 충족 | `PASS` | §12.2 B-5·B-6·B-9·N-2′·N-4′ 및 §12.3 N-1″~N-8″ 각 행이 「이 TestPlan 은 판정하지 않는다 / 0-A 범위 밖 / 후속 나선 이월」로 제외를 명시. `601717` §10.1 항목 6·7 이 blocker 처분 APPROVED. 다만 §10 문면에 N-6″·N-7″·N-8″ 가 이름으로 등장하지 않는다 — OBS-4 |
| `AC-12` | §12.4 의 C-1·C-2·H-1~H-5 가 Stage 7 Approval 에 이월로 명시되어 있다 — H-3a 포함(R2-F5 처분). H-3a 는 H-3 의 선행 조건이므로 누락 시 후속 나선이 순서를 잃는다 | 충족 | `PASS` | `601717` §10.1 항목 2(C-1·C-2 DEFERRED) · 항목 3(H-1~H-5 이월) · §10.2 표 3행이 H-3a 를 이름으로 명시(1721행) |
| `AC-13` | 검증자가 상위 문서 및 본 문서의 원작자가 아니다 (000701 §37) | 충족 | `PASS` | Cowork 은 `601710`·`601713`·`601716`·`601717` 원작자(Claude Code) 도 `0170`/`0171` 구현자(Codex) 도 아니다 — 지시문 서두 원작자 명시와 일치 |
| `AC-14` | I-47 을 강제 장치 유무가 아니라 검증 시점 상태(TP-D-08)로 판정했다 — 강제 부재는 §12.3 N-1″ 이며 FAIL 사유가 아니다 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `AC-15` | create_franchise_store 의 실패를 이 구현의 결함으로 판정하지 않았다 — TP-RT-08 은 실패 양상 불변만 검사한다(§12.3 N-4″) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `AC-16` | merchant_accounts 가 601717 §4.1 확정 정의와 정확히 일치한다 — TP-P-26~31 · TP-N-21 · TP-N-60 · TP-N-61 | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |
| `AC-17` | §12.4 H-5(name synchronization)가 Approval 에 이월로 명시되어 있다 — 601717 §10.1 항목 5 | 충족 | `PASS` | `601717` §10.1 항목 5 「N-2′ / N-3′ / H-5 — APPROVED … H-5 이월」. §4.4.3 H-5 행이 동기화 정책 미결을 명시 |
| `AC-18` | TP-M-08 을 clean baseline replay 로만 판정했다 — 동일 DB 재실행 실패는 FAIL 사유가 아니다(601717 §10.2) | 미측정 | `SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)` | DB 실측 필요 — 이 환경에서 도달 불가 |

---

## §5 `0170` · `0171` 파일 내용 — 계약 §1.3 / §1.4 / §4.5 대조

### §5.1 조작 누락 · 추가 · 순서

| 계약 항목 | 계약 조작 | 파일 실측 | 판정 |
|---|---|---|---|
| D-1 | `ALTER TABLE … RENAME TO` `owners`→`persons` | `0170` L6 동일 | 일치 |
| D-2 | `RENAME COLUMN` `lepr.owner_id`→`person_id` | `0170` L9-10 동일 | 일치 |
| D-3 | `RENAME COLUMN` `ler.owner_id`→`person_id` | `0170` L13-14 동일 | 일치 |
| D-4 | `RENAME COLUMN` `persons.owner_name`→`person_name` | `0170` L17-18 동일 | 일치 |
| D-5 | `ALTER TRIGGER … RENAME TO` `trg_persons_updated_at` | `0170` L21-22 동일 | 일치 |
| D-6 | `RENAME CONSTRAINT` `…lepr…_person_id_fkey` | `0170` L25-27 동일 | 일치 |
| D-7 | `RENAME CONSTRAINT` `…ler…_person_id_fkey` | `0170` L30-32 동일 | 일치 |
| D-8 | `ALTER INDEX` `owners_pkey`→`persons_pkey` | `0170` L35 동일 | 일치 |
| D-9 | `ALTER INDEX` `idx_lepr_owner`→`idx_lepr_person` | `0170` L38 동일 | 일치 |
| D-10 | `DROP COLUMN persons.is_active` | `0170` L41 동일 | 일치 |
| D-11 | `DROP CONSTRAINT chk_lepr_ownership_percent` | `0170` L44-45 동일 | 일치 |
| D-12 | `DROP COLUMN lepr.ownership_percent` | `0170` L48-49 동일 | 일치 |
| D-13 | `COMMENT ON TABLE persons` | `0170` L52-53 동일 | 일치 |
| D-14 | `CREATE TABLE merchant_accounts` — 5컬럼 + 명명 PK·FK (§1.4.1) | `0171` L6-18. 5컬럼, `CONSTRAINT merchant_accounts_pkey PRIMARY KEY (id)`, `CONSTRAINT fk_merchant_accounts_tenant_id … NO ACTION/NO ACTION` | 일치 |
| D-15 | `ADD CONSTRAINT uq_merchant_accounts_tenant UNIQUE (tenant_id)` | `0171` L21-22 동일. `CREATE UNIQUE INDEX` 형태 0건 | 일치 |
| D-16 | `CREATE TRIGGER` — §4.2.3 확정 구문 | `0171` L25-27 동일 | 일치 |
| D-17 | `ENABLE` + `FORCE ROW LEVEL SECURITY` | `0171` L30-31 (2문) | 일치 |
| D-18 | `stores ADD COLUMN merchant_account_id uuid` — NULL 허용 | `0171` L34. `NOT NULL` 미부착 | 일치 |
| D-19 | `ADD CONSTRAINT fk_stores_merchant_account_id … NO ACTION` | `0171` L37-42 동일 | 일치 |
| D-20 | `CREATE INDEX idx_stores_merchant_account_id` | `0171` L45-46 동일 (비-unique) | 일치 |
| D-21 | `COMMENT ON TABLE/COLUMN` 3건 | `0171` L49-56 (3문) | 일치 |
| M-1 | §4.5.1 확정 SQL | `0171` L59-60 **바이트 동일** | 일치 |
| M-2 | `UPDATE … FROM` 파생 | `0171` L63-66 동일 | 일치 |

```text
조작 누락   0건        조작 추가   0건
D-11 → D-12 순서   준수 (L44 → L48)
M-1  → M-2  순서   준수 (L59 → L63)
파일 내 D/M 마커 순서
  0170  D-1 D-2 D-3 D-4 D-5 D-6 D-7 D-8 D-9 D-10 D-11 D-12 D-13
  0171  D-14 D-15 D-16 D-17 D-18 D-19 D-20 D-21 M-1 M-2
```

### §5.2 금지 조작 — 전건 0

| 금지 토큰 | `0170` | `0171` |
|---|---:|---:|
| `CASCADE` | 0 | 0 |
| `CREATE UNIQUE INDEX` | 0 | 0 |
| `CREATE POLICY` | 0 | 0 |
| `GRANT` | 0 | 0 |
| `REVOKE` | 0 | 0 |
| `IF EXISTS` | 0 | 0 |
| `IF NOT EXISTS` | 0 | 0 |
| `DO $$` | 0 | 0 |
| dynamic `EXECUTE` | 0 | 0 |
| `EXCEPTION` | 0 | 0 |
| `DROP TABLE` | 0 | 0 |
| `CREATE (OR REPLACE) FUNCTION` | 0 | 0 |
| `SET NOT NULL` | 0 | 0 |
| `INSERT … VALUES` | 0 | 0 |
| `DISABLE` / `NO FORCE ROW LEVEL SECURITY` | 0 | 0 |
| `ALTER COLUMN` | 0 | 0 |
| `DELETE FROM` / `TRUNCATE` | 0 | 0 |
| `CREATE VIEW` / `MATERIALIZED VIEW` | 0 | 0 |
| `SECURITY DEFINER` / `CREATE ROLE` / `CREATE SCHEMA` | 0 | 0 |
| `ON DELETE`/`ON UPDATE` 가 `NO ACTION` 이외 | 0 | 0 |

> **`EXECUTE FUNCTION` 1건은 dynamic SQL 이 아니다.** `0171` L27 D-16 의 trigger 문법이며 정상이다.
> 전체 `EXECUTE` 출현은 이 1건뿐이다.

**`stores.merchant_account_id` NOT NULL enforcement — 0건.**

```text
ALTER TABLE catchmenu_hq.stores ADD COLUMN merchant_account_id uuid;    ← NOT NULL 미부착
ALTER TABLE … stores … SET NOT NULL                                     ← 0건
merchant_account_id 를 강제하는 CHECK · 트리거                            ← 0건 (파일 기준)
```

> **「NOT NULL」 문자열 총 7건은 검사 기준이 아니다.**
> D-14 컬럼 정의 5건(`id`·`tenant_id`·`merchant_account_name`·`created_at`·`updated_at`) +
> D-21 COMMENT literal 2건이며, **전부 계약이 요구한 정상 출현**이다.
> `0170` 은 0건.

### §5.3 exact literal

**COMMENT 4건 — `601717` §4.2.1 과 전건 바이트 동일 (개행 포함 substring 일치).**

| # | 대상 | 일치 |
|---|---|---|
| D-13 | `catchmenu_hq.persons` | ✅ |
| D-21 ① | `catchmenu_hq.merchant_accounts` | ✅ |
| D-21 ② | `catchmenu_hq.merchant_accounts.tenant_id` | ✅ |
| D-21 ③ | `catchmenu_hq.stores.merchant_account_id` | ✅ |

**물리 객체명 6건 — `601717` §4.2.2 와 전건 일치, 각 1회 출현.**

```text
merchant_accounts_pkey            1     uq_merchant_accounts_tenant       1
fk_merchant_accounts_tenant_id    1     trg_merchant_accounts_updated_at  1
fk_stores_merchant_account_id     1     idx_stores_merchant_account_id    1
```

**M-1 — `601717` §4.5.1 확정 SQL 과 바이트 동일.**

```sql
INSERT INTO catchmenu_hq.merchant_accounts (tenant_id, merchant_account_name)
SELECT id, tenant_name FROM catchmenu_hq.tenants;
```

**TRIGGER 구문 — `601717` §4.2.3 확정 구문과 일치 (들여쓰기·줄바꿈만 상이, 토큰 동일).**

### §5.4 파일 규격

| 항목 | `0170` | `0171` | 기준 | 판정 |
|---|---|---|---|---|
| 워크패킷 헤더 위치 | 1행 | 1행 | 상단 5행 이내 | PASS |
| executable statement count | 15 | 15 | `BEGIN`+D-1~13+`COMMIT` / `BEGIN`+D-14~21(11문)+M-1+M-2+`COMMIT` | 정합 |
| 주석 라인 수 (`--`) | 14 | 11 | 헤더 1 + D/M 마커 13 / 10 | 정합 |
| 트랜잭션 | `BEGIN;`×1 `COMMIT;`×1 | `BEGIN;`×1 `COMMIT;`×1 | 단일 트랜잭션 | PASS |
| 인코딩 | us-ascii (UTF-8 호환) | us-ascii (UTF-8 호환) | UTF-8 | PASS |
| BOM | 없음 (`2d 2d 20`) | 없음 (`2d 2d 20`) | 없음 | PASS |
| 개행 | LF (CR 0건) | LF (CR 0건) | LF | PASS |
| git EOL 속성 | `i/lf w/lf attr/text eol=lf` | 동일 | LF | PASS |
| 파일 끝 개행 | 있음 (`0a`) | 있음 (`0a`) | — | PASS |
| 행 끝 공백 | 0건 | 0건 | — | PASS |
| 바이트 / 행 | 1375 B / 55행 | 2161 B / 68행 | — | 기록 |

### §5.5 G15 거버넌스 — 기계적 재도출 (도구 미실행)

**`tools/Check-Governance.ps1` 은 실행하지 못했다** (§6). 아래는 스크립트 로직을 읽고 동일 규칙을 Python 으로 재현한 **참고 증거**이며, **TP-M-02·TP-M-03 의 판정은 `SKIP` 으로 남긴다.**

```text
wpRegex '(?i)(?:Workpacket|워크패킷)\s*:?\s*(\d{6})'  (상단 5행)
  0170  match → wp=601700
  0171  match → wp=601700

Find-ChangeContract('601700')
  → docs/…/601700_operational_authority_foundation_v2/601717_ChangeContract_…md

Get-Stage7State  규칙(a) 표 행 매칭 — 601717 1640행
  cell = 'APPROVED_FOR_IMPLEMENTATION — 정영석, 2026-08-23. …'
  → Kind = APPROVED  (ref s10)

Kind -eq 'APPROVED' → continue → G15 finding 미생성
StrictStage7 는 severity 만 승격하므로 결과 동일
```

**재도출 결과 G15 finding 0건이나, 이는 도구 출력이 아니다.**

---

## §6 환경 실측 — DB 도달 불가 재확인

**직전 pass 의 기록을 이번 pass 에서 재측정했다.**

| 항목 | `device_bash` (사용자 PC 내 Linux VM) | `Bash` (클라우드 컨테이너) |
|---|---|---|
| `docker` | `command not found` | 바이너리 존재 · **데몬 부재** (`/var/run/docker.sock` no such file) |
| `psql` | 없음 | 존재 |
| `pg_isready` | 없음 | — |
| `psycopg2` | `ModuleNotFoundError` | — |
| `127.0.0.1:5432` | **Connection refused** | **Connection refused** |
| `pwsh` / `powershell` | 없음 | 없음 (`apt` 패키지 미제공) |

**요청받은 명령 `docker exec -i supabase_db_yoonsul_wait_order_handoff psql …` 은 두 환경 모두에서 실행 불가다.**
대상 컨테이너는 Windows 호스트의 Docker Desktop 위에 있고, 두 실행 환경 모두 그 경계 밖이다.

```text
SKIP(NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV)      197건 중 195건
SKIP(NO_POWERSHELL_IN_SUPPLEMENTAL_ENV)       TP-M-02 · TP-M-03  2건
```

---

## §7 종합

| 접두 | 총 | PASS | FAIL | SKIP |
|---|---:|---:|---:|---:|
| `BL-` | 38 | 2 | 0 | 36 |
| `TP-P-` | 38 | 0 | 0 | 38 |
| `TP-N-` | 65 | 6 | 0 | 59 |
| `TP-D-` | 9 | 1 | 0 | 8 |
| `TP-R-` | 20 | 1 | 0 | 19 |
| `TP-RB-` | 8 | 4 | 0 | 4 |
| `TP-RT-` | 7 | 0 | 0 | 7 |
| `TP-B-` | 8 | 8 | 0 | 0 |
| `TP-M-` | 11 | 5 | 1 | 5 |
| `TP-X-` | 13 | 3 | 0 | 10 |
| `AC-` | 18 | 6 | 1 | 11 |
| **합계** | **235** | **36** | **2** | **197** |

### §7.1 최종 판정

```text
FAIL = 2   (> 0)

→ TESTPLAN FAILURES FOUND
```

> ⚠️ **지시문은 「DB 계열 전건 SKIP 이므로 정상적으로 두 번째 판정(NO FAIL OBSERVED — TESTPLAN NOT FULLY EXECUTED)이 나올 것」으로 예상했다.**
> **실제로는 file-scope 검사에서 FAIL 2건이 관측되어 세 번째 판정이 나왔다.**
> 규칙은 기계적으로 적용했다 — `FAIL > 0` 이므로 `TESTPLAN FAILURES FOUND` 다.
>
> **다만 이 pass 는 전체 235건 중 38건(16.2%)만 실행했다.**
> `TESTPLAN FAILURES FOUND` 와 `TESTPLAN NOT FULLY EXECUTED` 는 **동시에 참**이며,
> 두 사실을 함께 읽어야 한다.

```text
실행    38건  (PASS 36 · FAIL 2)
미실행 197건  (SKIP)
```

---

## §8 FAIL 목록

| Test ID | 기대 | 실측 | 계약 위반 여부 |
|---|---|---|---|
| `TP-M-07` | `0171` 내부 순서가 **테이블 생성 → M-1 → stores 컬럼·FK·인덱스 → M-2** | 테이블 생성 → **stores 컬럼·FK·인덱스** → **M-1** → M-2 | **아니오.** 실제 순서는 `601717` §1.4 (D-14~D-21) → §4.5 (M-1·M-2) 의 번호 순서와 일치한다. `601717` 어느 조항도 M-1 을 D-18~D-20 앞에 두라고 요구하지 않는다. 근거로 적힌 「참조 무결성」은 두 순서 모두에서 성립한다 (`merchant_accounts` 는 D-14 로 이미 존재하고, M-2 는 D-18 컬럼과 M-1 행을 모두 필요로 하므로 마지막이다) |
| `AC-9` | §8 Boundary · §9 Migration **전 항목 PASS** | §8 Boundary 8/8 PASS · §9 Migration 에 `TP-M-07` FAIL 1건 | **파생 FAIL.** `TP-M-07` 하나에서 파생한다. 독립 결함이 아니다 |

### §8.1 `TP-M-07` — Stage 9 에 넘기는 판단

**이 pass 는 원인을 고치지 않았다.** `601716`·`601717`·`0171` 어느 것도 수정하지 않았다.

```text
관측된 것    TestPlan 문면(TP-M-07)  ↔  ChangeContract D/M 번호 순서  가 서로 다른 순서를 지시한다
구현이 따른 것  ChangeContract 의 D/M 번호 순서
따라서        「구현이 계약을 위반했다」가 아니라
              「TestPlan 문면과 계약 문면이 불일치한다」로 관측된다
```

**Stage 9 가 판단해야 하는 것**

```text
1  TP-M-07 문면이 오기인가 — 그렇다면 정정은 Stage 6 경로 (X-9)
2  계약 D/M 순서가 오기인가 — 그렇다면 0171 재작성이 필요하며 §14.5 불변과 충돌한다
3  둘 다 유효하고 참조 무결성만 요구한 것인가 — 그렇다면 TP-M-07 은 PASS 로 재판정된다
```

**Cowork 은 위 셋 중 어느 것도 선택하지 않았다.** 판정 권한 밖이다.

---

## §9 SKIP 목록

**전건은 §4 결과표에 개별 기록돼 있다. 아래는 접두별 요약이다.**

| 접두 | SKIP 건수 | 사유 | Stage 9 에서 수행해야 하는가 |
|---|---:|---|---|
| `BL-` | 36 | `NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV` | **예** — 사후 비교 기준선 전건 |
| `TP-P-` | 38 | 동일 | **예** — Positive 전건. 물리 객체명 6건·COMMENT 4건은 파일 수준에서 일치가 확인됐으나(§5.3) **DB catalog 실측이 별도로 필요** |
| `TP-N-` | 59 | 동일 | **예** — 특히 TP-N-50~53·62~64 (`prosrc` md5), TP-N-40·41 (`is_nullable`), TP-N-21·60·61 (컬럼 구성) |
| `TP-D-` | 8 | 동일 | **예** — backfill 행 수·고아·NULL 전건 |
| `TP-R-` | 19 | 동일 | **예** — BASE TABLE 21 / 트리거 115 / `stores` 컬럼 17 / 함수 158 등 |
| `TP-RB-` | 4 | 동일 | **예** — 실제 rollback 실행 검증 |
| `TP-RT-` | 7 | 동일 | **예** — 전후 비교(catalog·정의 대조). `provision_tenant` 실행은 §5.9 가 금지 |
| `TP-B-` | 0 | — | 아니오 — 이번 pass 에서 전건 실행 |
| `TP-M-` | 5 | `NO_DB_ACCESS…` 3건 (TP-M-05·06·08) · `NO_POWERSHELL…` 2건 (TP-M-02·03) | **예** — 특히 TP-M-08 clean baseline replay |
| `TP-X-` | 10 | `NO_DB_ACCESS_FROM_SUPPLEMENTAL_ENV` | **예** — DB 전역 negative |
| `AC-` | 11 | 동일 | **예** — 하위 Test 가 SKIP 인 roll-up |
| **합계** | **197** | | |

### §9.1 Stage 9 로 이관되는 항목 — 접두별 건수

```text
BL-      36        TP-P-    38        TP-N-    59
TP-D-     8        TP-R-    19        TP-RB-    4
TP-RT-    7        TP-B-     0        TP-M-     5
TP-X-    10        AC-      11
합계    197
```

**추가로 이관되는 것**

```text
TP-M-07 FAIL 처분          §8.1 의 3지선다
AC-9    파생 FAIL          TP-M-07 처분에 종속
OBS-2   601736~601738 등록이 §1 허용 목록 밖이라는 관측
OBS-4   §10 Approval 에 N-6″·N-7″·N-8″ 제외 사실 미명시 관측
```

---

## §10 실행한 명령 — 전문 (재현 가능)

**전부 읽기 전용이다. git write 명령 0회.**

### §10.1 판본 · EOL

```bash
P=docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2
git show HEAD:$P/601716_TestPlan_Operational_Authority_Foundation_V2.md | sha256sum
git show 01cfd45bab7710b0db2a4957b7e540bebfad7377:$P/601716_TestPlan_Operational_Authority_Foundation_V2.md | sha256sum
sha256sum $P/601716_TestPlan_Operational_Authority_Foundation_V2.md
git ls-files --eol $P/601716_TestPlan_Operational_Authority_Foundation_V2.md \
                   $P/601717_ChangeContract_Operational_Authority_Foundation_V2.md \
                   sql/migrations/0170_person_vocabulary_normalization.sql \
                   sql/migrations/0171_merchant_account_foundation.sql
git show HEAD:$P/601717_ChangeContract_Operational_Authority_Foundation_V2.md | sha256sum
git show 01cfd45bab7710b0db2a4957b7e540bebfad7377:$P/601717_ChangeContract_Operational_Authority_Foundation_V2.md | sha256sum
git log -1 --format='%H%n%ad%n%s' 01cfd45bab7710b0db2a4957b7e540bebfad7377
git log -1 --format='%H' -- $P/601717_ChangeContract_Operational_Authority_Foundation_V2.md
git rev-parse HEAD
git status --short
```

### §10.2 커밋 범위 · TP-B

```bash
A=01cfd45bab7710b0db2a4957b7e540bebfad7377
B=bc4cd14deaea6d696d573d437163ab42d4f93619
git log --format='%H|%h|%ad|%an|%s' --date=iso $A..$B
git diff --name-status $A $B
git diff --stat        $A $B
for c in $(git rev-list --reverse $A..$B); do
  echo "--- $c $(git log -1 --format='%s' $c) ---"
  git show --name-status --format='' $c
done
git show accf0666ffedec69241cc93c4c992e0d229e5ecd -- $P/601717_ChangeContract_Operational_Authority_Foundation_V2.md
git show df49eb568174a0b7a1964b68ab7f66f58c06bbee -- docs/000005_Index_Document_Number.md docs/000007_Map_Full_Directory.md
git diff --check $A $B
git diff --name-status $A $B -- sql/
git diff --name-only  $A $B -- apps packages catchmenu_app tests
git diff --name-only  $A $B -- sql/seed_yoonsul_menu.sql
git diff --name-only  $A $B -- 'docs/**/601700_Readme*'
ls sql/migrations/*.sql | wc -l
ls sql/migrations/ | grep -E '^(0170|0171)'
```

### §10.3 파일 규격

```bash
for f in sql/migrations/0170_person_vocabulary_normalization.sql \
         sql/migrations/0171_merchant_account_foundation.sql; do
  wc -c -l < $f
  head -c 3 $f | xxd | head -1              # BOM
  grep -c $'\r' $f                          # CRLF
  file -i $f                                # encoding
  LC_ALL=C grep -c -P '[\x80-\xFF]' $f      # non-ascii
  grep -c ' $' $f                           # trailing ws
  tail -c 1 $f | xxd | head -1              # final newline
  head -5 $f | cat -n                       # header
  grep -c ';' $f                            # statements
  grep -c '^\s*--' $f                       # comment lines
done
```

### §10.4 계약 대조 · 금지 조작

```bash
M="sql/migrations/0170_person_vocabulary_normalization.sql sql/migrations/0171_merchant_account_foundation.sql"
grep -o -i -E 'provider|external|mapping|van_merchant|pos_store_config|toss|okpos|kicc|smartcast|payment|integration' $M
grep -c -i -E 'provision_tenant|create_franchise_store|onboard_tenant|update_business_hours' $M
grep -o -i -E 'FROM\s+[a-z_]+\.[a-z_]+|JOIN\s+[a-z_]+\.[a-z_]+|INTO\s+[a-z_]+\.[a-z_]+|REFERENCES\s+[a-z_]+\.[a-z_]+' $M
grep -rn -E '\bowners\b|\bowner_id\b' apps packages catchmenu_app tests sql/seed_yoonsul_menu.sql
grep -rn -i -E 'INSERT[[:space:]]+INTO[[:space:]]+[a-z_.]*stores' apps packages catchmenu_app tests
```

**금지 토큰 · exact literal · D/M 마커 순서 · 물리 객체명 6건은 Python 정규식 스캔으로 수행했다.**
스캔 대상 패턴은 §5.2 표의 좌측 열이 전부이며, literal 비교는 `601717` §4.2.1 / §4.2.3 / §4.5.1
코드블록을 그대로 substring 대조했다.

### §10.5 Test ID inventory

```bash
# 601716 에서 표 행 선두의 Test ID 를 기계 추출 (취소선·굵게 표기 허용)
#   ^\|\s*\*{0,2}~{0,2}\s*((?:TP-(?:P|N|D|R|RB|RT|B|M|X)|BL|AC)-\d+)
# raw unique 236 − TP-RT-03(폐기) = 235
```

### §10.6 환경 실측

```bash
which docker psql pg_isready pwsh powershell
docker ps
(timeout 3 bash -c 'cat < /dev/null > /dev/tcp/127.0.0.1/5432') && echo OPEN || echo CLOSED
python3 -c "import psycopg2"
psql "postgresql://postgres:postgres@127.0.0.1:5432/postgres" -c "SELECT 1;"
```

---

## §11 이 pass 가 하지 않은 것

```text
파일 생성·수정·삭제        이 파일 1개 외 0건
sql/migrations/** 수정      0건
git write 명령              0회
FAIL 원인 교정              0건
TestPlan · ChangeContract 수정  0건
판정 불가를 PASS 로 기록     0건
샘플링                      0건 — 수행 가능한 항목은 전건 검사
```

**`601739` 는 implementation delta 가 아니다.**

```text
601739 is verification evidence created after
the implementation delta was measured.
It is not part of the Stage 8 implementation delta.
```

**생성 후 implementation delta 를 재측정·재정의하지 않았다.**
