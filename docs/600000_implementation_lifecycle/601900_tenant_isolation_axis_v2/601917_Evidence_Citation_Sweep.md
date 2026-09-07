# 601917_Evidence_Citation_Sweep.md

Status: Active
Lifecycle: Evidence
DocumentType: Evidence
Last Updated: 2026-09-06

## §0 성격

전수 대조. 판단 · 결론 · 보강 제안 없음. 원천의 내용을 추가 채록하지 않고 문서번호·절번호·출현 위치·기존 채록 위치만 기록한다.

작업 근거는 사용자 지시의 000701 §48 / 601901 Q-P14 / 601916 F-4 · 601915 BR3-I8이다. 601916·601915의 판정을 입력으로 사용하지 않았으며 이번 작업에서 두 문서의 본문을 열람하지 않았다.

대조 입력은 현재 작업 파일 601901·601902 전문이다. §2 S1·§4 S3의 계수 단위는 **원천 문서번호 + 절번호의 고유 쌍**이다. 동일 절의 반복 출현은 위치를 모두 남기고 별도 계수한다. 절번호 없는 문서·주제 언급은 §2.2에 분리한다.

생성 허용 파일은 이 문서 1개다. 601901·601902 및 다른 파일의 생성·수정·삭제, DB 접속, git write, 포매터, 인코딩 정규화는 수행하지 않았다. 기존 index·map은 수정하지 않았다.

```text
KOREAN / ENCODING SAFETY:
- Preserve UTF-8.
- Do not normalize encoding.
- Do not run formatters.
- Do not use PowerShell Set-Content.
- Do not rewrite full markdown files.
- Do not perform broad search-and-replace over Korean text.
- Do not modify Korean prose, Korean brand wording, menu names, membership names, customer-facing wording, or philosophy text unless explicitly instructed.
- If you are Cursor, do not edit Korean body text. Only report the required change.
- If a file contains Korean body text and the requested change requires semantic editing, STOP and report: "Requires Codex or manual Korean document editing."
- Path/reference/index/map updates are allowed only when they do not rewrite Korean prose.
```

## §1 측정 방법

### §1.1 입력 판본과 행 번호

모든 L번호는 해당 입력 파일의 1-based 실제 행 번호다. §2는 601902, §3의 목록·채록 위치는 601901이다. §4는 열 제목에 따라 나뉜다.

| 입력 | 읽기 시작 시 SHA-256 |
|---|---|
| 601901_Register_Stage0_Evidence_Collection.md | 2B15934E53EC3C2CE9CE333CAE9DC1403312F0B437493EDA63D3A3AA1E50FCAD |
| 601902_Register_Stage1_Business_Rules.md | 07962313E8F92D87D3F5C573989750264D53F52415771D5B57C605529F1B6EE3 |

git HEAD: 85a328b55ae3e7dafc42c1c690270df7813fbe29. 두 입력 모두 git ls-files --eol 결과 i/lf · w/lf다. 이전 작업의 커밋 번호를 이번 측정값으로 사용하지 않았다.

### §1.2 S1 추출 규칙

1. 대상 문서는 010004·010640·010630·010650·010660·000150·000170·000190 및 601702다. 601702는 §1.N 형태를 대상으로 한다.
2. 전문의 제목·개정 이력·TI-N 본문·근거 줄·표·코드 블록·§3·§4·§5·§6·§7을 포함한다. 개정 이력의 과거 언급과 “근거가 아니다”라는 서술도 문자열 출현으로 포함한다.
3. 문서번호 뒤의 §N을 추출한다. 같은 행에서 문서번호를 반복하지 않은 §N 연쇄는 앞 문서번호에 연결한다. 파일명 접두어 형태도 포함한다.
4. 현재 문서의 절번호는 제외한다. 같은 행의 601902 §6을 뜻하는 L116의 마지막 §6과 L857의 마지막 §6은 명시적으로 제외했다.
5. 문서명이 생략된 010004 §19(L414), §24(L432·L434·L441·L444)는 TI-10·TI-11의 앞선 문서명과 연결해 따로 기록했다. §4 HD-0-A-2R-9의 영어 “Section 24”(L929)도 같은 항목의 출현으로 기록했다.
6. “601702 선언 45건”처럼 절번호 목록 없이 문서 전체를 지칭하는 표현을 §1.1~§1.45의 45개 인용으로 자동 전개하지 않았다.
7. 문서명만 있는 주제 인용, 예컨대 SCOPE_GATE·multi-party approval·release stronger authority는 절번호를 새로 배정하지 않고 §2.2에 기록했다.
8. 하나의 절을 여러 번 인용한 횟수와 고유 절 수를 구분했다. 이 규칙으로 고유 33건, 절 토큰 출현 113건, 해당 출현 행 74개다.

후보 검색 정규식:

```text
§|Section\s+\d+|^\d+\\\.\s|^## \d+\.
```

문서번호·절번호 토큰 정규식(JavaScript):

```text
(?<!\d)(\d{6})(?=[_\W]|$)|§\s*(\d+(?:\.\d+)*)(?!\d|\.\d|\.N)
```

문장 끝 마침표와 절번호 소수점을 구분한다. 숫자 절 뒤에 마침표가 붙은 L227의 §35., L363의 §42., L514의 §1.28.도 포함했다.

### §1.3 S2 채록 구분 규칙

- “절 구조 목록”은 source별 전체 절 구조 표·목록과 601702의 45개 heading 목록이다. provenance 표의 관련 절 나열도 검색했으나 원문 채록으로 합산하지 않았다.
- “원문 채록”은 출처 절이 붙은 본문 발췌·표·코드 블록·인용문이 존재하는 경우다. **절 전체의 모든 문장이 채록됐다는 뜻은 아니다.**
- 제목만 있는 절, 애매점 표의 짧은 단어 인용, 실측 대응표·근거 목록·질문표의 절명 언급은 별도 원문 채록으로 세지 않았다.
- 601702 §1.33 채록 안에서 000190 §10·§11·§21을 다시 인용한 부분도 추출했다. 이 중 §10·§21은 앞의 독립 채록과 중복이므로 고유 절 수를 늘리지 않았고, §11은 중첩 채록 위치를 기록했다.
- 두 문서번호가 다른 §5를 합치지 않는다. **601901 L183의 MD-Level Isolation Rule은 010004 §5**다. 010640 §5의 목록 위치는 L334이며 별도 원문 블록은 없다.
- S2/S4의 본표는 S1과 같은 9문서 범위다. 그 밖에 601901에 채록된 600020 §1.2는 §3.3·§5.2에 별도 기록하고 9문서 집계에 더하지 않았다.

상태는 다음 네 값만 사용한다.

| 상태 | 기계적 대조 기준 |
|---|---|
| 채록됨 | 해당 문서·절의 목록 위치와 본문 채록 위치가 모두 존재 |
| 목록만 | 목록 위치 존재, 해당 절의 본문 채록 블록 없음 |
| 없음 | 목록 위치와 본문 채록 위치 모두 없음 |
| 확인 불가 | 문서·절 귀속 또는 본문 블록 유무를 특정할 수 없음. 해당 사유 병기 |

### §1.4 표기 경계 기록

| 사례 | 현재 파일에서 확인한 위치 |
|---|---|
| 절 일부 발췌 | 601702 §1.27은 601901 L1808부터 일부 채록됐다. 601902 L489의 “한 축의 값으로 다른 축의 상태를 추론하지 않는다”라는 문장은 이 발췌 블록에는 없다. 절 단위 존재 상태는 채록됨으로 기록했다. |
| 부분 표 | 010640 §4는 601901 L360에 “중 원문 관련 행”으로 표시돼 있다. 전체 dimension 표 채록으로 표기하지 않았다. |
| 목록 제목과 채록 제목 차이 | 010650 §38은 목록 L1068에 Example Containment Scenarios, 채록 L1358에 Anti-Patterns로 표시된다. 문서번호·절번호가 같고 본문 블록이 있으므로 채록됨으로 기록했다. |
| 짧은 언급과 본문 블록 | 010640 §5는 601901 L474의 “should carry” 및 L2052 Q-P5에 언급되지만 별도의 해당 절 원문 블록은 없다. |
| 중첩 인용 | 000190 §11 본문은 독립 A1 상세인 §9.2가 아니라 601702 §1.33 채록 내부 L1886~L1891에 존재한다. |
| 같은 주제와 실제 절번호 인용 | 사용자 지시가 든 601702 §1.12는 601901 L1741에 목록이 있고 본문 채록은 없다. 601902 전문에는 601702 §1.12라는 절 인용이 없다. TI-15.3은 L746~L749이며, 그 근거 줄 L796~L797에 000150 §12와 601702 §1.33이 있다. 이 항목을 S1/S3의 33건에 추가하지 않았다. |
| 보강 일자 문자열 | 사용자 지시는 010650 §38 보강을 2026-09-05로 적었다. 현재 601901 L2060은 2026-09-02 보강 채록이라고 적었다. 이 문서의 계수는 일자가 아닌 현재 채록 블록의 존재 기준이다. |

## §2 S1 — 601902 인용 절 전수

### §2.1 고유 절별 출현 위치

동일 행의 서로 다른 절은 각 절의 출현으로 기록한다. “본문”은 경고·설명·인용 블록을 포함한다.

| ID | 인용 절 | 601902 출현 위치 전부 | 출현 수 |
|---|---|---|---:|
| S1-01 | 010004 §7 | §0.2 개정 이력 L43<br>TI-2 본문 L116<br>TI-13 본문 L540<br>TI-13 본문 L571<br>TI-13 근거 줄 L597<br>TI-13 본문 L624<br>TI-13 근거 줄 L627<br>TI-14 본문 L685<br>TI-15 본문 L767<br>§6 OQ-4 L1042<br>§7 목록 L1050 | 11 |
| S1-02 | 010004 §19 | TI-10 본문 L400<br>TI-10 본문 L414 (문서명 생략)<br>TI-10 근거 줄 L427<br>§7 목록 L1050 | 4 |
| S1-03 | 010004 §20 | TI-9 본문 L367<br>TI-9 본문 L382<br>TI-9 근거 줄 L396<br>§6 OQ-2 L1040<br>§7 목록 L1050 | 5 |
| S1-04 | 010004 §24 | TI-11 제목 L429<br>TI-11 본문 L432 (문서명 생략)<br>TI-11 본문 L434 (문서명 생략)<br>TI-11 본문 L441 (문서명 생략)<br>TI-11 본문 L444 (문서명 생략)<br>TI-11 근거 줄 L450<br>§4 HD-0-A-2R-9 L929 (영어 Section)<br>§7 목록 L1050 | 8 |
| S1-05 | 010004 §26 | TI-11 본문 L431<br>TI-11 근거 줄 L450<br>§7 목록 L1050 | 3 |
| S1-06 | 010004 §29 | TI-11 본문 L431<br>TI-11 근거 줄 L450<br>§7 목록 L1050 | 3 |
| S1-07 | 010640 §2 | TI-8 근거 줄 L363<br>§7 목록 L1051 | 2 |
| S1-08 | 010640 §4 | TI-7 근거 줄 L335<br>§7 목록 L1051 | 2 |
| S1-09 | 010640 §5 | TI-8 본문 L342<br>TI-8 근거 줄 L363<br>§7 목록 L1051 | 3 |
| S1-10 | 010640 §6 | TI-2 본문 L105<br>TI-2 본문 L118<br>§6 OQ-6 L1044<br>§7 목록 L1051 | 4 |
| S1-11 | 010640 §41 | §7 목록 L1051 | 1 |
| S1-12 | 010640 §42 | TI-8 근거 줄 L363<br>§7 목록 L1051 | 2 |
| S1-13 | 010630 §6 | TI-3 본문 L150<br>TI-3 근거 줄 L178 | 2 |
| S1-14 | 010630 §28 | §0.2 개정 이력 L47<br>TI-3 본문 L160<br>TI-3 본문 L163<br>TI-3 본문 L172<br>TI-3 근거 줄 L178 | 5 |
| S1-15 | 010650 §35 | TI-5 근거 줄 L227<br>§7 목록 L1056 | 2 |
| S1-16 | 010650 §38 | §3 Q-P13 L857<br>§6 OQ-3 L1041 | 2 |
| S1-17 | 010660 §4 | TI-6 본문 L290<br>TI-6 본문 L303<br>TI-6 근거 줄 L314<br>§7 목록 L1057 | 4 |
| S1-18 | 010660 §5 | TI-6 근거 줄 L314<br>§7 목록 L1057 | 2 |
| S1-19 | 010660 §6 | §0.2 개정 이력 L47<br>TI-6 본문 L265 | 2 |
| S1-20 | 000150 §12 | TI-15 근거 줄 L796<br>§7 목록 L1052 | 2 |
| S1-21 | 000150 §22 | TI-15 본문 L717<br>TI-15 근거 줄 L796<br>§7 목록 L1052 | 3 |
| S1-22 | 000150 §23 | TI-15 본문 L720<br>TI-15 근거 줄 L796<br>§7 목록 L1052 | 3 |
| S1-23 | 000170 §3 | §7 목록 L1053 | 1 |
| S1-24 | 000170 §4 | §7 목록 L1053 | 1 |
| S1-25 | 000190 §3 | TI-15 본문 L724<br>TI-15 본문 L797<br>§7 목록 L1054 | 3 |
| S1-26 | 000190 §8 | TI-15 본문 L732<br>TI-15 본문 L797<br>§7 목록 L1054 | 3 |
| S1-27 | 000190 §10 | TI-15 본문 L727<br>TI-15 본문 L797<br>§7 목록 L1054 | 3 |
| S1-28 | 000190 §17 | TI-15 본문 L730<br>TI-15 본문 L797<br>§7 목록 L1054 | 3 |
| S1-29 | 000190 §20 | TI-15 본문 L784<br>TI-15 본문 L789<br>§5 L1023<br>§7 목록 L1054 | 4 |
| S1-30 | 000190 §27 | TI-15 본문 L763<br>TI-15 본문 L797<br>§7 목록 L1054 | 3 |
| S1-31 | 601702 §1.27 | TI-12 본문 L489<br>TI-12 근거 줄 L514<br>TI-12 본문 L521<br>§7 목록 L1058<br>§7 목록 L1060 | 5 |
| S1-32 | 601702 §1.28 | §0.2 개정 이력 L42<br>TI-12 본문 L455<br>TI-12 본문 L500<br>TI-12 근거 줄 L514<br>TI-12 본문 L521<br>§7 목록 L1058<br>§7 목록 L1060 | 7 |
| S1-33 | 601702 §1.33 | §0.2 개정 이력 L49<br>TI-15 본문 L797<br>TI-15 본문 L799<br>§6 OQ-5 L1043<br>§7 목록 L1058 | 5 |
| 합계 | 고유 33건 | 74개 행 | 113 |

010640 §41은 L1051에서 “A3 발견 경로이며 TI-N 근거가 아니다”라고 서술된다. 원천 절의 출현을 전수 추출하는 규칙에 따라 포함했으며, 이 문서가 해당 절에 근거 지위를 부여한 것은 아니다.

### §2.2 절번호 없는 표현과 문서 단위 언급

아래는 절번호를 배정하지 않은 문자열 기록이다. S1의 고유 33건과 별도이며 “인용하지 않았다”라는 의미로 지우지 않았다.

| 위치 | 문서 또는 문구 |
|---|---|
| L41 | 010004를 어느 규칙의 근거로도 쓰지 않았다는 개정 이력 |
| L46 | 000150·000190의 원천 강제·cross-business 주제 언급 |
| L55·L58~L60 | 010630·010650·010660 채택 및 문서 제목 |
| TI-2 L95~L97 | 010650, TENANT_CIRCUIT_BREAKER·STORE_CIRCUIT_BREAKER·DEVICE_CIRCUIT_BREAKER, 가장 작은 안전한 경계 |
| TI-2 근거 L124 | 010650 문서 단위, 010630 SCOPE_GATE |
| TI-3 근거 L178~L179 | 010630 high-impact action gate, 010650 자동 containment |
| TI-4 L209~L210 | 010650의 자신이 발동한 quarantine release anti-pattern |
| TI-4 근거 L214 | 010650 release stronger authority, 010630 multi-party approval |
| TI-6 근거 L314 | 010630 문서 단위 |
| TI-7 L319~L320·L335 | 010640 merchant_id, 000170 Merchant Account 및 문서 단위 근거 |
| TI-9 L378~L380 | 010004의 파일명·주제 |
| TI-11 L438 | 010004의 runtime 유보 영역 |
| TI-12 L526 | 601702가 선언 근거라는 문서 단위 설명 |
| TI-15 L710~L711 | 000150·000190 강제 문서 언급 |
| §4 L873~L876 | 010630·010650·010660 문서 채택 |
| §7 L1055 | 010630 authority gate family·SCOPE_GATE·multi-party |
| §7 L1056 | 010650 circuit breaker scope·anti-pattern — 같은 행의 §35는 §2.1에 별도 집계 |
| §7 L1058 | 601702 선언 45건 — 같은 행의 §1.27·§1.28·§1.33은 §2.1에 별도 집계 |

§4의 HD-0-A-2R-2~13은 문서번호·절번호 없이 앞선 TI 규칙을 영어로 서술하는 부분을 포함한다(L878~L993). 숫자 절이 있는 L929의 Section 24만 §2.1에 위치를 추가했고, 나머지 문장에 새 원천 절번호를 부여하지 않았다.

## §3 S2 — 601901 채록 절 전수

### §3.1 절 구조 목록 위치

| 문서 | 601901 절 구조 목록 | 본문 채록 탐색 구간 |
|---|---|---|
| 010004 | §5.1 L134~L137 | §5.2 L139~L318 |
| 010640 | §6.1 L334~L336 | §6.2 L338~L466 및 §11.2 L1929~L1950 |
| 010630 | §9.1.1 L775 | §9.1.2 L777~L1048 |
| 010650 | §9.2.1 L1068 | §9.2.2 L1070~L1382 |
| 010660 | §9.3.1 L1402 | §9.3.2 L1404~L1702 |
| 000150 | §7.1 L481 | §7.2 L483~L564 |
| 000170 | §8.1 L579 | §8.2 L581~L653 |
| 000190 | §9.1 L668 | §9.2 L670~L756 및 §10.2의 중첩 인용 L1868~L1901 |
| 601702 | §10.1 L1730~L1774 — §1.1~§1.45 heading | §10.2 L1776~L1903 |

### §3.2 본문 채록 절 목록

채록 위치는 표제 또는 인용 출처 표기가 시작하는 행이다. 아래 82행은 고유 절 82건이며, 중복 채록 위치는 같은 행에 병기했다.

| ID | 원천 절 | 절 구조 목록 행 | 채록 시작 행 | 채록 표제·형태 |
|---|---|---|---|---|
| S2-01 | 010004 §2 | L135 | L141 | `§2 Core Principle`: |
| S2-02 | 010004 §4 | L135 | L167 | `§4 Mandatory Context Fields` 원문 표: |
| S2-03 | 010004 §5 | L135 | L183 | `§5 MD-Level Isolation Rule` 원문 14항: |
| S2-04 | 010004 §7 | L135 | L202 | `§7 Deny-By-Default Rule`: |
| S2-05 | 010004 §19 | L136 | L228 | `§19 Audit Isolation Rule`: |
| S2-06 | 010004 §20 | L137 | L253 | `§20 Cross-Tenant Containment Rule`: |
| S2-07 | 010004 §24 | L137 | L286 | `§24 Relationship To Runtime Authorization` 원문 11항: |
| S2-08 | 010004 §29 | L137 | L306 | `§29 Final Rule`: |
| S2-09 | 010640 §2 | L334 | L340 | `§2 Core Position`: |
| S2-10 | 010640 §4 | L334 | L360 | `§4 Scope Dimension Catalog` 중 원문 관련 행: |
| S2-11 | 010640 §6 | L334 | L377 | `§6 Scope Validation State Skeleton`: |
| S2-12 | 010640 §7 | L335 | L398 | `§7 Tenant Isolation Boundary`: |
| S2-13 | 010640 §31 | L336 | L414 | `§31 Scope Propagation Boundary`: |
| S2-14 | 010640 §35 | L336 | L438 | `§35 Scope Conflict Boundary`: |
| S2-15 | 010640 §41 | L336 | L1929 | ### §11.2 발견 근거 원문 (`010640` §41) |
| S2-16 | 010640 §42 | L336 | L458 | `§42 Final Rule`: |
| S2-17 | 010630 §2 | L775 | L780 | ## 2. Core Position |
| S2-18 | 010630 §5 | L775 | L805 | ## 5. Authority Context Boundary |
| S2-19 | 010630 §6 | L775 | L839 | ## 6. Authority Decision State Skeleton |
| S2-20 | 010630 §9 | L775 | L867 | ## 9. Scope Gate Boundary |
| S2-21 | 010630 §18 | L775 | L897 | ## 18. Multi-Party Approval Gate Boundary |
| S2-22 | 010630 §21 | L775 | L924 | ## 21. Idempotency Gate Boundary |
| S2-23 | 010630 §22 | L775 | L952 | ## 22. Audit Gate Boundary |
| S2-24 | 010630 §28 | L775 | L979 | ## 28. Deny-By-Default Rule |
| S2-25 | 010630 §35 | L775 | L1015 | ## 35. Authority Gate And Break-Glass Boundary |
| S2-26 | 010630 §44 | L775 | L1037 | ## 44. Final Rule |
| S2-27 | 010650 §2 | L1068 | L1073 | ## 2. Core Position |
| S2-28 | 010650 §4 | L1068 | L1099 | ## 4. Failure Containment Catalog |
| S2-29 | 010650 §5 | L1068 | L1127 | ## 5. Circuit Breaker State Skeleton |
| S2-30 | 010650 §16 | L1068 | L1151 | ## 16. Security Quarantine Boundary |
| S2-31 | 010650 §17 | L1068 | L1191 | ## 17. Tenant Noisy Neighbor Containment Boundary |
| S2-32 | 010650 §18 | L1068 | L1224 | ## 18. Store-Level Containment Boundary |
| S2-33 | 010650 §29 | L1068 | L1256 | ## 29. Recovery Boundary |
| S2-34 | 010650 §35 | L1068 | L1280 | ## 35. Relationship To Authority Gate |
| S2-35 | 010650 §36 | L1068 | L1305 | ## 36. Relationship To Tenant Scope Envelope |
| S2-36 | 010650 §38 | L1068 | L1358 | ## 38. Anti-Patterns |
| S2-37 | 010650 §42 | L1068 | L1332 | ## 42. Final Rule |
| S2-38 | 010660 §2 | L1402 | L1407 | ## 2. Core Position |
| S2-39 | 010660 §4 | L1402 | L1434 | ## 4. Idempotency Key Boundary |
| S2-40 | 010660 §5 | L1402 | L1464 | ## 5. Idempotency Record Fields |
| S2-41 | 010660 §6 | L1402 | L1497 | ## 6. Idempotency State Skeleton |
| S2-42 | 010660 §7 | L1402 | L1522 | ## 7. Retry Boundary |
| S2-43 | 010660 §10 | L1402 | L1549 | ## 10. Timeout Boundary |
| S2-44 | 010660 §12 | L1402 | L1582 | ## 12. Replay Boundary |
| S2-45 | 010660 §14 | L1402 | L1611 | ## 14. Reconciliation Boundary |
| S2-46 | 010660 §32 | L1402 | L1643 | ## 32. Reconciliation Closing Boundary |
| S2-47 | 010660 §37 | L1402 | L1663 | ## 37. Idempotency And Tenant Scope Boundary |
| S2-48 | 010660 §44 | L1402 | L1679 | ## 44. Final Rule |
| S2-49 | 000150 §3 | L481 | L486 | 3\. Core Principle |
| S2-50 | 000150 §5 | L481 | L498 | 5\. Parent Group Context |
| S2-51 | 000150 §7 | L481 | L509 | 7\. Legal Entity Boundary |
| S2-52 | 000150 §12 | L481 | L523 | 12\. Shared Yoonsul-Affiliated Store Case |
| S2-53 | 000150 §13 | L481 | L529 | 13\. External Merchant Case |
| S2-54 | 000150 §22 | L481 | L535 | 22\. Cross-Business Link |
| S2-55 | 000150 §23 | L481 | L542 | 23\. Cross-Business Access Denial By Default |
| S2-56 | 000150 §33 | L481 | L554 | 33\. Final Rule |
| S2-57 | 000170 §3 | L579 | L584 | 3\. Core Principle |
| S2-58 | 000170 §4 | L579 | L596 | 4\. Merchant Account Definition |
| S2-59 | 000170 §7 | L579 | L604 | 7\. Merchant Store Definition |
| S2-60 | 000170 §12 | L579 | L615 | 12\. External Merchant Boundary |
| S2-61 | 000170 §13 | L579 | L621 | 13\. Yoonsul-Affiliated Store |
| S2-62 | 000170 §25 | L579 | L628 | 25\. Service Plan Relationship |
| S2-63 | 000170 §31 | L579 | L635 | 31\. Cross-Business Link To Franchise OS |
| S2-64 | 000170 §39 | L579 | L642 | 39\. Final Rule |
| S2-65 | 000190 §3 | L668 | L673 | 3\. Core Principle |
| S2-66 | 000190 §4 | L668 | L682 | 4\. Business Boundary Summary |
| S2-67 | 000190 §8 | L668 | L689 | 8\. External Merchant Boundary |
| S2-68 | 000190 §10 | L668 | L696 · L1868 | 10\. Cross-Business Link — 중첩 인용 위치 포함 |
| S2-69 | 000190 §11 | L668 | L1886 | `000190` §11 Cross-Business User Link: — 중첩 인용 위치 포함 |
| S2-70 | 000190 §13 | L668 | L703 | 13\. Permission Separation |
| S2-71 | 000190 §17 | L668 | L709 | 17\. Authority Leakage Prohibition |
| S2-72 | 000190 §20 | L668 | L715 | 20\. Federation Definition |
| S2-73 | 000190 §21 | L668 | L732 · L1893 | 21\. Source Of Truth Rule — 중첩 인용 위치 포함 |
| S2-74 | 000190 §27 | L668 | L738 | 27\. Cross-Business Link Status |
| S2-75 | 000190 §37 | L668 | L746 | 37\. Final Rule |
| S2-76 | 601702 §1.22 | L1751 | L1778 | `§1.22`: |
| S2-77 | 601702 §1.26 | L1755 | L1790 | `§1.26`: |
| S2-78 | 601702 §1.27 | L1756 | L1808 | `§1.27`: |
| S2-79 | 601702 §1.28 | L1757 | L1821 | `§1.28`: |
| S2-80 | 601702 §1.33 | L1762 | L1862 | ### §1.33 cross-business link 는 참조이며 권한이 아니다 |
| S2-81 | 601702 §1.40 | L1769 | L1834 | `§1.40`: |
| S2-82 | 601702 §1.43 | L1772 | L1853 | `§1.43`: |

목록 82건. 채록 위치 84곳(000190 §10·§21 각 2곳). 일부 발췌·원문 표·중첩 인용의 존재를 계수한 것이며 각 절의 전문 채록 여부는 이 계수가 나타내지 않는다.

### §3.3 9문서 밖의 원문 채록

| 원천 절 | 601901 원문 위치 | 본표 계수 |
|---|---|---|
| 600020 §1.2 | L2030~L2040 “원문” 표기 및 코드 블록 | 9문서 S2 82건 밖에 별도 1건 |

601901 §12.4 L2001~L2019의 601816 finding 목록은 source 절번호가 붙은 원문 채록 절 목록이 아니므로 위 절 계수에 넣지 않았다. SQL 쿼리·catalog 실측표도 문서 원천 절 채록과 분리했다.

## §4 S3 — 대조표

| 인용 절 | 601902 인용 위치 | 601901 절 구조 목록 | 601901 원문 채록 | 상태 |
|---|---|---|---|---|
| 010004 §7 | §0.2 개정 이력 L43<br>TI-2 본문 L116<br>TI-13 본문 L540<br>TI-13 본문 L571<br>TI-13 근거 줄 L597<br>TI-13 본문 L624<br>TI-13 근거 줄 L627<br>TI-14 본문 L685<br>TI-15 본문 L767<br>§6 OQ-4 L1042<br>§7 목록 L1050 | 있음 — L135 | 있음 — L202 | 채록됨 |
| 010004 §19 | TI-10 본문 L400<br>TI-10 본문 L414 (문서명 생략)<br>TI-10 근거 줄 L427<br>§7 목록 L1050 | 있음 — L136 | 있음 — L228 | 채록됨 |
| 010004 §20 | TI-9 본문 L367<br>TI-9 본문 L382<br>TI-9 근거 줄 L396<br>§6 OQ-2 L1040<br>§7 목록 L1050 | 있음 — L137 | 있음 — L253 | 채록됨 |
| 010004 §24 | TI-11 제목 L429<br>TI-11 본문 L432 (문서명 생략)<br>TI-11 본문 L434 (문서명 생략)<br>TI-11 본문 L441 (문서명 생략)<br>TI-11 본문 L444 (문서명 생략)<br>TI-11 근거 줄 L450<br>§4 HD-0-A-2R-9 L929 (영어 Section)<br>§7 목록 L1050 | 있음 — L137 | 있음 — L286 | 채록됨 |
| 010004 §26 | TI-11 본문 L431<br>TI-11 근거 줄 L450<br>§7 목록 L1050 | 있음 — L137 | 해당 절의 본문 채록 블록 없음 | 목록만 |
| 010004 §29 | TI-11 본문 L431<br>TI-11 근거 줄 L450<br>§7 목록 L1050 | 있음 — L137 | 있음 — L306 | 채록됨 |
| 010640 §2 | TI-8 근거 줄 L363<br>§7 목록 L1051 | 있음 — L334 | 있음 — L340 | 채록됨 |
| 010640 §4 | TI-7 근거 줄 L335<br>§7 목록 L1051 | 있음 — L334 | 있음 — L360 | 채록됨 |
| 010640 §5 | TI-8 본문 L342<br>TI-8 근거 줄 L363<br>§7 목록 L1051 | 있음 — L334 | 해당 절의 본문 채록 블록 없음 | 목록만 |
| 010640 §6 | TI-2 본문 L105<br>TI-2 본문 L118<br>§6 OQ-6 L1044<br>§7 목록 L1051 | 있음 — L334 | 있음 — L377 | 채록됨 |
| 010640 §41 | §7 목록 L1051 | 있음 — L336 | 있음 — L1929 | 채록됨 |
| 010640 §42 | TI-8 근거 줄 L363<br>§7 목록 L1051 | 있음 — L336 | 있음 — L458 | 채록됨 |
| 010630 §6 | TI-3 본문 L150<br>TI-3 근거 줄 L178 | 있음 — L775 | 있음 — L839 | 채록됨 |
| 010630 §28 | §0.2 개정 이력 L47<br>TI-3 본문 L160<br>TI-3 본문 L163<br>TI-3 본문 L172<br>TI-3 근거 줄 L178 | 있음 — L775 | 있음 — L979 | 채록됨 |
| 010650 §35 | TI-5 근거 줄 L227<br>§7 목록 L1056 | 있음 — L1068 | 있음 — L1280 | 채록됨 |
| 010650 §38 | §3 Q-P13 L857<br>§6 OQ-3 L1041 | 있음 — L1068 | 있음 — L1358 | 채록됨 |
| 010660 §4 | TI-6 본문 L290<br>TI-6 본문 L303<br>TI-6 근거 줄 L314<br>§7 목록 L1057 | 있음 — L1402 | 있음 — L1434 | 채록됨 |
| 010660 §5 | TI-6 근거 줄 L314<br>§7 목록 L1057 | 있음 — L1402 | 있음 — L1464 | 채록됨 |
| 010660 §6 | §0.2 개정 이력 L47<br>TI-6 본문 L265 | 있음 — L1402 | 있음 — L1497 | 채록됨 |
| 000150 §12 | TI-15 근거 줄 L796<br>§7 목록 L1052 | 있음 — L481 | 있음 — L523 | 채록됨 |
| 000150 §22 | TI-15 본문 L717<br>TI-15 근거 줄 L796<br>§7 목록 L1052 | 있음 — L481 | 있음 — L535 | 채록됨 |
| 000150 §23 | TI-15 본문 L720<br>TI-15 근거 줄 L796<br>§7 목록 L1052 | 있음 — L481 | 있음 — L542 | 채록됨 |
| 000170 §3 | §7 목록 L1053 | 있음 — L579 | 있음 — L584 | 채록됨 |
| 000170 §4 | §7 목록 L1053 | 있음 — L579 | 있음 — L596 | 채록됨 |
| 000190 §3 | TI-15 본문 L724<br>TI-15 본문 L797<br>§7 목록 L1054 | 있음 — L668 | 있음 — L673 | 채록됨 |
| 000190 §8 | TI-15 본문 L732<br>TI-15 본문 L797<br>§7 목록 L1054 | 있음 — L668 | 있음 — L689 | 채록됨 |
| 000190 §10 | TI-15 본문 L727<br>TI-15 본문 L797<br>§7 목록 L1054 | 있음 — L668 | 있음 — L696 · 있음 — L1868 | 채록됨 |
| 000190 §17 | TI-15 본문 L730<br>TI-15 본문 L797<br>§7 목록 L1054 | 있음 — L668 | 있음 — L709 | 채록됨 |
| 000190 §20 | TI-15 본문 L784<br>TI-15 본문 L789<br>§5 L1023<br>§7 목록 L1054 | 있음 — L668 | 있음 — L715 | 채록됨 |
| 000190 §27 | TI-15 본문 L763<br>TI-15 본문 L797<br>§7 목록 L1054 | 있음 — L668 | 있음 — L738 | 채록됨 |
| 601702 §1.27 | TI-12 본문 L489<br>TI-12 근거 줄 L514<br>TI-12 본문 L521<br>§7 목록 L1058<br>§7 목록 L1060 | 있음 — L1756 | 있음 — L1808 | 채록됨 |
| 601702 §1.28 | §0.2 개정 이력 L42<br>TI-12 본문 L455<br>TI-12 본문 L500<br>TI-12 근거 줄 L514<br>TI-12 본문 L521<br>§7 목록 L1058<br>§7 목록 L1060 | 있음 — L1757 | 있음 — L1821 | 채록됨 |
| 601702 §1.33 | §0.2 개정 이력 L49<br>TI-15 본문 L797<br>TI-15 본문 L799<br>§6 OQ-5 L1043<br>§7 목록 L1058 | 있음 — L1762 | 있음 — L1862 | 채록됨 |

S3의 없음 0건, 확인 불가 0건이다. 지시서의 별도 주제 항목 601702 §1.12는 §1.4에 위치를 기록했으며 S1에서 추출된 인용 절이 아니므로 S3 계수에 포함하지 않았다.

## §5 S4 — 역방향

### §5.1 9문서 범위

아래 51건은 601901에 본문 채록이 있고, §1.2의 문서번호·절번호 추출 규칙으로 601902에서 나오지 않은 절이다. 절번호 없는 관련 문자열은 별도 열에 남겼다. 해당 열의 “별도 대응 절번호 배정 없음”은 주제 인용까지 없다는 뜻이 아니다.

| 601901 채록 절 | 601901 채록 위치 | 601902의 절번호 없는 문자열 기록 |
|---|---|---|
| 010004 §2 | L141 | 별도 대응 절번호 배정 없음 |
| 010004 §4 | L167 | 별도 대응 절번호 배정 없음 |
| 010004 §5 | L183 | 별도 대응 절번호 배정 없음 |
| 010640 §7 | L398 | 별도 대응 절번호 배정 없음 |
| 010640 §31 | L414 | 별도 대응 절번호 배정 없음 |
| 010640 §35 | L438 | 별도 대응 절번호 배정 없음 |
| 010630 §2 | L780 | L178: high-impact action gate |
| 010630 §5 | L805 | 별도 대응 절번호 배정 없음 |
| 010630 §9 | L867 | L124·L1055: SCOPE_GATE |
| 010630 §18 | L897 | L214: multi-party approval / L1055: multi-party |
| 010630 §21 | L924 | 별도 대응 절번호 배정 없음 |
| 010630 §22 | L952 | 별도 대응 절번호 배정 없음 |
| 010630 §35 | L1015 | 별도 대응 절번호 배정 없음 |
| 010630 §44 | L1037 | 별도 대응 절번호 배정 없음 |
| 010650 §2 | L1073 | L95~L97: 010650 및 가장 작은 안전한 경계 문구 |
| 010650 §4 | L1099 | L95~L97: 010650 및 circuit breaker family 명칭 |
| 010650 §5 | L1127 | 별도 대응 절번호 배정 없음 |
| 010650 §16 | L1151 | 별도 대응 절번호 배정 없음 |
| 010650 §17 | L1191 | 별도 대응 절번호 배정 없음 |
| 010650 §18 | L1224 | 별도 대응 절번호 배정 없음 |
| 010650 §29 | L1256 | 별도 대응 절번호 배정 없음 |
| 010650 §36 | L1305 | 별도 대응 절번호 배정 없음 |
| 010650 §42 | L1332 | 별도 대응 절번호 배정 없음 |
| 010660 §2 | L1407 | 별도 대응 절번호 배정 없음 |
| 010660 §7 | L1522 | 별도 대응 절번호 배정 없음 |
| 010660 §10 | L1549 | 별도 대응 절번호 배정 없음 |
| 010660 §12 | L1582 | 별도 대응 절번호 배정 없음 |
| 010660 §14 | L1611 | 별도 대응 절번호 배정 없음 |
| 010660 §32 | L1643 | 별도 대응 절번호 배정 없음 |
| 010660 §37 | L1663 | 별도 대응 절번호 배정 없음 |
| 010660 §44 | L1679 | 별도 대응 절번호 배정 없음 |
| 000150 §3 | L486 | 별도 대응 절번호 배정 없음 |
| 000150 §5 | L498 | 별도 대응 절번호 배정 없음 |
| 000150 §7 | L509 | 별도 대응 절번호 배정 없음 |
| 000150 §13 | L529 | 별도 대응 절번호 배정 없음 |
| 000150 §33 | L554 | 별도 대응 절번호 배정 없음 |
| 000170 §7 | L604 | 별도 대응 절번호 배정 없음 |
| 000170 §12 | L615 | 별도 대응 절번호 배정 없음 |
| 000170 §13 | L621 | 별도 대응 절번호 배정 없음 |
| 000170 §25 | L628 | 별도 대응 절번호 배정 없음 |
| 000170 §31 | L635 | 별도 대응 절번호 배정 없음 |
| 000170 §39 | L642 | 별도 대응 절번호 배정 없음 |
| 000190 §4 | L682 | 별도 대응 절번호 배정 없음 |
| 000190 §11 | L1886 | 별도 대응 절번호 배정 없음 |
| 000190 §13 | L703 | 별도 대응 절번호 배정 없음 |
| 000190 §21 | L732 · L1893 | 별도 대응 절번호 배정 없음 |
| 000190 §37 | L746 | 별도 대응 절번호 배정 없음 |
| 601702 §1.22 | L1778 | 별도 대응 절번호 배정 없음 |
| 601702 §1.26 | L1790 | 별도 대응 절번호 배정 없음 |
| 601702 §1.40 | L1834 | 별도 대응 절번호 배정 없음 |
| 601702 §1.43 | L1853 | 별도 대응 절번호 배정 없음 |

### §5.2 범위 밖 별도 기록

| 601901 채록 절 | 채록 위치 | 601902 전문의 동일 문서번호·절번호 |
|---|---|---|
| 600020 §1.2 | L2030~L2040 | 출현 없음 — 9문서 역방향 51건 밖 별도 1건 |

## §6 집계

| 원천 문서 | 인용 고유 절 | 인용 출현 | 채록됨 | 목록만 | 없음 | 확인 불가 | S2 채록 고유 절 | S4 역방향 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 010004 | 6 | 34 | 5 | 1 | 0 | 0 | 8 | 3 |
| 010640 | 6 | 14 | 5 | 1 | 0 | 0 | 8 | 3 |
| 010630 | 2 | 7 | 2 | 0 | 0 | 0 | 10 | 8 |
| 010650 | 2 | 4 | 2 | 0 | 0 | 0 | 11 | 9 |
| 010660 | 3 | 8 | 3 | 0 | 0 | 0 | 11 | 8 |
| 000150 | 3 | 8 | 3 | 0 | 0 | 0 | 8 | 5 |
| 000170 | 2 | 2 | 2 | 0 | 0 | 0 | 8 | 6 |
| 000190 | 6 | 19 | 6 | 0 | 0 | 0 | 11 | 5 |
| 601702 | 3 | 17 | 3 | 0 | 0 | 0 | 7 | 4 |
| 합계 — 9문서 | 33 | 113 | 31 | 2 | 0 | 0 | 82 | 51 |

계수 관계: 인용 33 = 채록됨 31 + 목록만 2 + 없음 0 + 확인 불가 0. S2 82 = S3 채록됨 31 + S4 51.

| S3 목록만 | 601902 인용 위치 | 601901 목록 위치 |
|---|---|---|
| 010004 §26 | TI-11 본문 L431 / 근거 L450 / §7 목록 L1050 | L137 |
| 010640 §5 | TI-8 본문 L342 / 근거 L363 / §7 목록 L1051 | L334 |

S3 없음 목록: 0건. S3 확인 불가 목록: 0건. 지시서 별도 언급 601702 §1.12: 601902 해당 절 인용 0건 / 601901 목록 L1741 / 본문 채록 블록 없음. 위 33건 밖의 기록이다.

9문서 밖 600020 §1.2를 포함해 별도로 센 본문 채록 절은 83건, 역방향 항목은 52건이다. S1/S3 집계에 그 1건을 합산하지 않았다.

판단·결론·보강 제안 0건. DB 접속 0건. 원천 채록 추가 0건. 입력 파일 수정 0건.

## §7 실행 명령 전문

### §7.1 파일 읽기·후보 추출·판본 확인

PowerShell에서 다음 측정 명령을 실행했다. 출력의 원문을 메모리에서 대조했으며 임시 스크립트·CSV·JSON 파일은 만들지 않았다.

```powershell
$sweepRoot = 'D:\Workspace\Yoonsul_Wait_Order_Handoff'
$sweepPaths = @(
 'docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601901_Register_Stage0_Evidence_Collection.md',
 'docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md'
)
foreach ($p in $sweepPaths) {
  $sweepFull = Join-Path $sweepRoot $p
  Get-FileHash -Algorithm SHA256 -LiteralPath $sweepFull | Select-Object Path,Hash
  $sweepLines = [IO.File]::ReadAllLines($sweepFull, [Text.UTF8Encoding]::new($false,$true))
  for ($i=0; $i -lt $sweepLines.Length; $i++) {
    if ($sweepLines[$i] -match '§|Section\s+\d+|^\d+\\\.\s|^## \d+\.') {
      '{0}:{1}: {2}' -f [IO.Path]::GetFileName($p),($i+1),$sweepLines[$i]
    }
  }
}
git ls-files --eol -- '*601901*' '*601902*'
git rev-parse HEAD
git status --short --untracked-files=all
```

입력 전문을 메모리로 전달한 명령:

```powershell
$sweepPaths=@(
 'docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601901_Register_Stage0_Evidence_Collection.md',
 'docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md'
)
$sweepData=@{}
foreach($p in $sweepPaths) {
 $sweepData[[IO.Path]::GetFileName($p).Substring(0,6)] =
   [IO.File]::ReadAllText((Join-Path (Get-Location) $p))
}
ConvertTo-Json -InputObject $sweepData -Compress
```

규칙 문서·파일 존재·해시 확인 명령:

```powershell
rg --files -g '*000001_Md_Rules.md' -g AGENTS.md
Get-Content -Encoding UTF8 'docs/000001_Md_Rules.md' | Select-Object -First 145
Get-Content -Raw -Encoding UTF8 'docs/000015_Korean_Document_And_Encoding_Safety_Rules.md'
Get-Content -Raw -Encoding UTF8 'docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md'
Get-FileHash -Algorithm SHA256 -LiteralPath 'docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601901_Register_Stage0_Evidence_Collection.md','docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md' | Format-List Path,Hash
Test-Path -LiteralPath 'docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601917_Evidence_Citation_Sweep.md'
git status --short --untracked-files=all
git rev-parse HEAD
git ls-files --eol -- '*601901*' '*601902*'
```

### §7.2 메모리 내 S1 추출 코드

JavaScript 실행 환경에서 lines는 601902 전문을 LF로 나눈 배열이다. §1.2의 생략형 6건을 명시한 최종 추출 코드 전문이다. 최초 후보 검색 뒤 문장 끝 마침표가 있는 절도 포함하도록 재검색한 결과를 사용했다.

```javascript
const allowed = new Set(["010004","010640","010630","010650","010660","000150","000170","000190","601702"]);
const exclusions = new Set(["116:6","857:6"]);
const records = [];
let zone = "";
for (let i=0; i<lines.length; i++) {
  const s = lines[i];
  if (/^## §/.test(s) || /^### §1\.\d+ TI-/.test(s)) zone=s.replace(/^#{2,3} /,"");
  let doc = null;
  const tokens = [...s.matchAll(/(?<!\d)(\d{6})(?=[_\W]|$)|§\s*(\d+(?:\.\d+)*)(?!\d|\.\d|\.N)/g)];
  for (const t of tokens) {
    if (t[1]) doc=t[1];
    else if (doc && allowed.has(doc) && !exclusions.has(`${i+1}:${t[2]}`)) {
      if (doc==="601702" && !/^1\.\d+$/.test(t[2])) continue;
      records.push({doc,sec:t[2],line:i+1,zone,form:"명시",raw:s});
    }
  }
}
for (const [line,sec] of [[414,"19"],[432,"24"],[434,"24"],[441,"24"],[444,"24"],[929,"24"]]) {
  let z="";
  for (let i=0;i<line;i++) if (/^## §/.test(lines[i]) || /^### §1\.\d+ TI-/.test(lines[i])) z=lines[i].replace(/^#{2,3} /,"");
  records.push({doc:"010004",sec,line,zone:z,form:line===929?"영어 Section":"문서명 생략",raw:lines[line-1]});
}
records.sort((a,b)=>a.line-b.line || Number(a.sec)-Number(b.sec));
```

### §7.3 메모리 내 S2·S3·S4 집계 코드

아래 앵커는 정규식으로 얻은 표제 후보와 실제 본문 블록을 대조한 목록이다. 원천 문서의 본문을 새로 채록하는 코드가 아니다. 입력 SHA가 다른 파일의 임의 위치에 재사용하지 않았다.

```javascript
const spec = [
 ["010004",[2,4,5,7,19,20,24,29],[141,167,183,202,228,253,286,306]],
 ["010640",[2,4,6,7,31,35,42,41],[340,360,377,398,414,438,458,1929]],
 ["000150",[3,5,7,12,13,22,23,33],[486,498,509,523,529,535,542,554]],
 ["000170",[3,4,7,12,13,25,31,39],[584,596,604,615,621,628,635,642]],
 ["000190",[3,4,8,10,13,17,20,21,27,37],[673,682,689,696,703,709,715,732,738,746]],
 ["010630",[2,5,6,9,18,21,22,28,35,44],[780,805,839,867,897,924,952,979,1015,1037]],
 ["010650",[2,4,5,16,17,18,29,35,36,42,38],[1073,1099,1127,1151,1191,1224,1256,1280,1305,1332,1358]],
 ["010660",[2,4,5,6,7,10,12,14,32,37,44],[1407,1434,1464,1497,1522,1549,1582,1611,1643,1663,1679]],
 ["601702",["1.22","1.26","1.27","1.28","1.40","1.43","1.33"],[1778,1790,1808,1821,1834,1853,1862]]
];
const excerpts = [];
for (const [doc,secs,anchors] of spec) {
  for (let i=0;i<secs.length;i++) excerpts.push({doc,sec:String(secs[i]),anchors:[anchors[i]]});
}
excerpts.find(r=>r.doc==="000190"&&r.sec==="10").anchors.push(1868);
excerpts.find(r=>r.doc==="000190"&&r.sec==="21").anchors.push(1893);
excerpts.push({doc:"000190",sec:"11",anchors:[1886]});
const key = r => r.doc+" §"+r.sec;
const cited = new Set(records.map(key));
const raw = new Set(excerpts.map(key));
const listed = new Set();
const catalogRanges = {
 "010004":[2,29], "010640":[2,42], "010630":[2,44],
 "010650":[2,42], "010660":[2,44], "000150":[1,33],
 "000170":[1,39], "000190":[1,37]
};
for (const [doc,[first,last]] of Object.entries(catalogRanges))
  for (let n=first;n<=last;n++) listed.add(doc+" §"+n);
listed.add("010004 §4.1");
for (let n=1;n<=45;n++) listed.add("601702 §1."+n);
// 숫자 범위는 §3.1의 source별 전체 절 구조 목록에서 확인했다.
const compared = [...cited].map(k=>({
 section:k,
 status:listed.has(k)
   ? (raw.has(k)?"채록됨":"목록만")
   : (raw.has(k)?"확인 불가":"없음")
}));
const reverse = excerpts.filter(r=>!cited.has(key(r)));
const counts = {
  citationSections:cited.size,
  citationOccurrences:records.length,
  sourceExcerptSections:raw.size,
  recorded:compared.filter(r=>r.status==="채록됨").length,
  listOnly:compared.filter(r=>r.status==="목록만").length,
  absent:compared.filter(r=>r.status==="없음").length,
  unverifiable:compared.filter(r=>r.status==="확인 불가").length,
  reverse:reverse.length
};
```

### §7.4 생성·검사 경계

결과 본문만 UTF-8/BOM 없는 바이트 배열로 만들어 FileMode.CreateNew로 지정 파일에 기록한다. 기존 파일이 있으면 덮어쓰지 않는 방식이다. 입력 파일의 인코딩·줄바꿈은 변환하지 않았다.

생성 후 검사 대상은 이 결과 파일의 UTF-8 유효성·BOM·CR·H1·총 행 수, 입력 두 파일의 SHA-256, git diff --check, git status다. 검사 결과는 완료 보고에 별도로 제시한다.

검사 명령 전문(동일 PowerShell 문장을 줄 단위로 표시):

```powershell
$sweepOutput='D:\Workspace\Yoonsul_Wait_Order_Handoff\docs\600000_implementation_lifecycle\601900_tenant_isolation_axis_v2\601917_Evidence_Citation_Sweep.md'
$sweepBytes=[IO.File]::ReadAllBytes($sweepOutput)
$sweepDecoded=[Text.UTF8Encoding]::new($false,$true).GetString($sweepBytes)
$sweepLines=[IO.File]::ReadAllLines($sweepOutput,[Text.UTF8Encoding]::new($false,$true))
[PSCustomObject]@{
 Lines=$sweepLines.Length
 UTF8Valid=$true
 BOM=($sweepBytes[0]-eq 239 -and $sweepBytes[1]-eq 187 -and $sweepBytes[2]-eq 191)
 CRCount=(@($sweepBytes | Where-Object {$_ -eq 13}).Count)
 EndsLF=($sweepBytes[-1]-eq 10)
 H1Exact=($sweepLines[0] -ceq '# 601917_Evidence_Citation_Sweep.md')
 DocumentType=($sweepDecoded -match '(?m)^DocumentType: Evidence$')
 S1Rows=([regex]::Matches($sweepDecoded,'(?m)^\| S1-\d+ \|').Count)
 S2Rows=([regex]::Matches($sweepDecoded,'(?m)^\| S2-\d+ \|').Count)
} | Format-List
Get-FileHash -Algorithm SHA256 -LiteralPath 'docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601901_Register_Stage0_Evidence_Collection.md','docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md' | Format-List Path,Hash
git diff --check
git status --short --untracked-files=all
```


작업 시작 시 git status의 유일한 항목:

```text
?? docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601916_Audit_Stage3_Round3_Claude.md
```

위 파일의 내용을 읽거나 변경하지 않았다.

## §8 근거 문서 목록 (000701 §46)

| 문서 | 사용 범위 |
|---|---|
| 601901_Register_Stage0_Evidence_Collection.md | 전문 — S2, S3, S4. §14 Q-P14 |
| 601902_Register_Stage1_Business_Rules.md | 전문 — S1, S3, S4 |
| docs/000001_Md_Rules.md §1 | 인코딩·Set-Content 금지 |
| docs/000015_Korean_Document_And_Encoding_Safety_Rules.md | 안전 블록 및 UTF-8·검사 규칙 |
| 000701 §48·§46 | 사용자 지시의 전수 대조·근거 목록 형식 |
| 601916 F-4 · 601915 BR3-I8 | 사용자 지시가 제시한 작업 근거 식별자. 이번 작업에서 원본 열람 없음 |

원천 9문서의 절명·내용은 601901·601902 안에 있는 표기만 대상으로 삼았다. 원천 파일을 수정하거나 원천 본문을 이 결과 파일에 보강 채록하지 않았다.
