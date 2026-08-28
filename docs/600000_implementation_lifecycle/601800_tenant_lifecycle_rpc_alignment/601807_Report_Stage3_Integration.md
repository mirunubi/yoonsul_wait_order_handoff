# 601807_Report_Stage3_Integration.md

Status: Active
Lifecycle: Report
Last Updated: 2026-08-28

## §0 이 문서의 지위

`000701` §47.1 **3단계 인접 도메인 대조**의 통합이다.

```text
Verifier A   Codex    601804   실측 축      Blocker 3 / informational 6
Verifier B   Cowork   601805   문서 축      Blocker 2 / informational 11
Verifier C   Claude   601806   인접 도메인   Blocker 7 / informational 10
```

**세 검증자가 동시에 수행했고 서로의 결과를 참조하지 않았다.**

**통합자는 세 보고서를 액면 그대로 신뢰하지 않고
원문에서 핵심 주장을 재도출했다**(`000701` §13.6).

## §1 수행 조건

**판본 — 3/3 일치**

```text
601801  562E7DF0…D048
601802  7F4986CF…859D
601803  DEF851BE…7561
커밋     5b05feb43f1b1e3415ed84fe1817675178f595d0
```

**세션 분리 요건 — `000701` §47.1**

| 검증자 | 2단계 작성자 배제 | 사전 맥락 0 |
|---|---|---|
| Codex | 충족 | 충족 — 새 세션에서 재수행 |
| Cowork | 충족 | **미충족** — `601739` 맥락 보유. `601805` §0.2 가 자기 보고 |
| Claude | 충족 | 충족 — 새 대화창. 첨부 7건만 |

> ⚠️ **Cowork 의 「사전 맥락 0」 미충족을 무효로 보지 않는다.**
>
> ```text
> §47.1 핵심 요건   2단계 ERD 를 작성한 세션과 분리
>                   601803 작성자는 Claude Code. Cowork 은 아니다
>
> 보유 맥락          601739 — 0-A 나선 Stage 8 supplemental
>                   601803 과 무관한 워크패킷
> ```
>
> **그 맥락이 판정을 오염시켰다면 `isolate_tenant` 문제를 먼저 짚었을 텐데
> `F-1`·`F-2` 어느 것도 그것이 아니다.**
>
> **Codex 는 첫 시도에서 스스로 조건 미충족을 감지해 중단했고
> Cowork 은 진행하되 결과 서두에 명시했다.**
> **둘 다 조건을 숨기지 않았다.**

**`000701` §47.1 actor 지정**

```text
§47.1   3단계 actor = Opus / Fable
```

**Verifier C 가 그 요건을 충족한다.**
**A · B 는 실무 보강이며 §47.1 이 지정한 actor 가 아니다.**

> ⚠️ **`601700` 3단계는 Cursor(`601706`) · Codex(`601707`)로 수행됐고
> §47.1 actor 요건을 충족하지 않았다. 그 사실이 당시 검증되지 않았다.**
> **`AC-13` · DocumentType 과 같은 계열의 spec conflict 이며 §7 로 이관한다.**

## §2 3/3 수렴 — 전이·초기값 판정

**세 검증자가 독립적으로 같은 결함에 도달했다.**

| 검증자 | finding | 근거 축 |
|---|---|---|
| Codex | `F-1` | `601801` §1.6 · §1.9 원문 — 전이 그래프 선언 없음 |
| Cowork | `F-1` | `601803` 내부 자기모순 — L99-101 |
| Claude | `C-B2` | `601702` §1.27 — 과거 구현을 설계 근거로 승격 금지 |

**공통 결론**

```text
601803 §1 T-2~T-8 이 전이 「허용」과 수행 주체를 확정했다
601801 은 전이 허용 여부도 수행 주체도 선언하지 않았다
```

**Cowork 이 짚은 자기모순이 결정적이다.**

```text
601803 §1 L99-101
  「HG-A-1 표와 HG-A-9 표는 조합의 유효성을 선언했을 뿐
   전이의 허용 여부를 전건 선언하지 않았다」

그 원칙을 T-8~T-11 에만 적용하고 T-2~T-7 에는 적용하지 않았다
```

**Codex 가 실측으로 보강했다.**

```text
라이브 manage_subscription 에 source-state guard 가 없다
SUSPEND → SUSPENDED / ACTIVATE → ACTIVE / CANCEL → CANCELLED 를 그냥 쓴다
601803 이 그린 제한된 전이를 보장하는 것이 라이브에 없다
```

**`601700` Stage 6 에서 다섯 라운드가 문서 대 문서로만 봤다가
`D-1` 을 놓친 것과 대비된다. 이번엔 세 축이 같은 지점에서 만났다.**

## §3 Blocker 통합 — 10건

**12건의 보고를 중복 제거해 10건으로 정리한다.**

| # | 내용 | 출처 | 성격 |
|---|---|---|---|
| **S-1** | `601803` §1 T-2~T-8 · §2 I-1 이 `601801` 에 없는 전이 허용 · 수행 주체 · 초기값을 확정했다 | Codex `F-1` · Cowork `F-1` · Claude `C-B2` | **3/3 수렴** |
| **S-2** | 라이브 `manage_subscription` 에 source-state guard 가 없어 모델이 그린 전이 제한을 스키마가 보장하지 않는다 | Codex `F-2` | 실측 |
| **S-3** | `601803` §6 이 「그 외 → review 생성하지 않음」이라는 음의 정책을 추가했다. `HG-A-5` 에 없다 | Codex `F-3` | 선언 생성 |
| **S-4** | `601803` §5 흐름도가 「tenant 가 `ISOLATED` 인가」 단일 축으로 분기한다. 같은 문서 §3 이 「두 축 중 더 제한적인 조건」으로 정의했고 `Q-4` 가 근거로 `HG-A-9-2` 를 적어놓고도 다이어그램이 그것을 따르지 않는다 | Claude `C-B1` | **문서 내부 모순** |
| **S-5** | `601803` §3 이 서비스 접근을 2축으로 합성한다. `601702` §1.28 은 **6축**을 열거하고 「상위 상태를 하위 상태의 대체물로 사용하지 않는다」고 못박았다 | Claude `C-B4` | **상위 선언 위반** |
| **S-6** | 「격리」 어휘가 두 의미를 구분하지 않는다. `601702` §1.26 의 격리 scope(멀티테넌트 데이터 경계 · RLS)와 `HG-A-1` 의 `isolation_state`(보안 · 장애 대응)가 다르다 | Claude `C-B3` | 어휘 충돌 |
| **S-7** | 상태 축 모델인데 `merchant_account` 를 한 번도 다루지 않는다. `601702` §1.28 이 `MerchantAccountStatus` 를 별도 축으로 열거했고 `601746` §2.11 d 가 「tenant 상태 ↔ merchant account 계약 상태 미연결」을 이관했다 | Claude `C-B5` | **상위 선언 위반** |
| **S-8** | `U-14` 가 두 값집합만 기록했으나 `601802` §7.2 는 세 개를 실측했다. `white_label_configs.contract_status` 가 빠졌다 | Claude `C-B6` | 실측 누락 |
| **S-9** | `601803` §3 이 사용량 산정에 `tenant_status` **미관여**를 판정했다. `601801` §2 는 `CANCELLED` 이후 반복과금 없음 · `TERMINATED` 이후 과금 없음을 규정한다 | Claude `C-B7` · Cowork `I-2` | **등급 갈림 — §4** |
| **S-10** | `HG-A-2` 가 차단하는 「멤버십 · 재고 쓰기」가 같은 커밋 `5b05feb` 에서 `000221` 이 별도 제품 · 별도 DB 로 이관한 `YS-OS` 소관과 겹친다. 제품 경계를 넘는 격리 전파 수단이 모델에 없다 | Cowork `F-2` | **제품 경계** |

### §3.1 S-5 — 통합자 직접 재도출

**`601702` §1.27 · §1.28 원문을 확인했다.**

```text
§1.27  Store Service Status    CatchMenu 서비스 제공 상태
       Store Operating Status  실제 음식점이 영업 중인가
       Trial Status            체험 · 전환 lifecycle

       한 축의 값으로 다른 축의 상태를 추론하지 않는다

§1.28  TenantStatus
         ≠ MerchantAccountStatus
         ≠ StoreServiceStatus
         ≠ StoreOperatingStatus
         ≠ TrialStatus
         ≠ IsolationState

       각 계층은 자신의 상태를 갖는다
       상위 상태를 하위 상태의 대체물로 사용하지 않는다
```

**여섯 축이다. `601803` 은 그중 둘만 그렸다.**

**`601803` §3 격자의 `TRIAL` 행 「체험 서비스」는
`Trial Status` 를 `tenant_status` 로 추론한 것이며 §1.27 이 금지한다.**

**`S-7` 도 §1.28 이 `MerchantAccountStatus` 를 별도 축으로 열거한 것으로 강화된다.**

### §3.2 S-4 와 S-5 는 별개다

```text
S-4   문서 자신의 §3 규칙(2축)조차 §5 에서 지키지 않았다   내부 모순
S-5   §3 규칙 자체가 601702 §1.28 의 6축과 어긋난다       상위 선언 위반
```

**층위가 다르므로 병합하지 않는다.**

## §4 판정이 갈린 지점

### §4.1 S-9 — 사용량 `tenant_status` 미관여

```text
Claude C-B7   Blocker — 선언에 없는 부정 판정
Cowork I-2    informational — U-13 이 산정 로직을 이월했으므로 즉시 위반 아님
```

**통합 판정 — Blocker 로 승격한다.**

```text
601801 §2 가 CANCELLED 이후 「반복과금 없음」 ·
TERMINATED 이후 「과금 없음」을 명시했다
tenant_status 가 과금에 관여한다는 뜻이다

U-13 이 이월한 것은 「산정 로직」이며 「관여 여부」가 아니다
601803 이 관여 여부를 미관여로 확정했다
```

**금전에 직결되므로 `000221` §6.1 A급 판별 7질문 중
「돈 · 포인트 · 재고 수량을 바꿀 수 있는가」에 해당한다.**

### §4.2 `TERMINATED` 해제 불가

```text
Claude C-I1   다이어그램과 표가 다르게 그림
Cowork I-1    「일반 복구 대상 아님」 ≠ 「어떤 경로로도 불가」
```

**둘 다 informational 이며 Cowork 해석이 더 정확하다.**

```text
HG-A-9-7   해당 tenant 는 일반 격리 복구 대상이 아니다
U-12       TERMINATED 보존 · 삭제 · 익명화 절차를 미정으로 남겼다
```

**비일반 경로를 배제하지 않았다. `601803` 이 「해제 불가」로 강화했다.**

## §5 informational 통합 — 중복 제거 후

| # | 내용 | 출처 |
|---|---|---|
| N-1 | §8.1 추적표가 「§7 `U-1` ~ `U-15`」로 남았다. 본문은 `U-17` 까지이고 「미정 17건」으로 닫는다. **같은 판본 안의 불일치다** | Claude `C-I2` · Cowork `I-6` |
| N-2 | `TERMINATED` 해제 표현 — §4.2 | Claude `C-I1` · Cowork `I-1` |
| N-3 | §4 대조표가 `isolate_tenant` 호출자 중 `detect_threat` 를 다루지 않는다. 자동 위협 탐지가 격리를 발동하는 경로이며 `U-6` · `B-2` 에 직결된다 | Claude `C-I3` |
| N-4 | §6 mermaid 가 billing review 와 trial extension review 의 중첩 여부를 배타로 암묵 판정했다. `601801` 이 명시하지 않았다 | Claude `C-I4` |
| N-5 | `HG-A-7` 「KDS release 금지」가 §5 에 개별 표현되지 않았다 | Claude `C-I5` |
| N-6 | §5 노드 `E` 가 provider 를 단일 노드로 둔다. `601702` §1.43 은 거래 provider(`TOSS-TX`)와 실행 provider(`SC-EXEC`)를 성격이 다르다고 선언했다 | Claude `C-I6` |
| N-7 | `U-7` 이 소관 나선을 적지 않았다. **4단계가 `U-7` 을 `0-A-2` 안에서 닫으면 `0-C` 침범이 된다** | Claude `C-I7` |
| N-8 | §5 가 `catchmenu_common.idempotency_keys` 를 언급하지 않는다. `601802` §8.1 이 21컬럼으로 실측했다. `offline_queue` 는 승계했으므로 증거 승계가 비대칭이다 | Claude `C-I8` |
| N-9 | `601801` §2 「고객의 자발적 사용 중지 → `ISOLATED` 사용 금지」가 전이 모델에 표현되지 않았다 | Claude `C-I9` |
| N-10 | §3 격자에 `601801` §2 의 `CANCELLED`·`TERMINATED` 과금 처분이 없다 — `S-9` 와 같은 대상 | Claude `C-I10` |
| N-11 | `T-4` 근거란이 `HG-A-1` 표를 전이 근거로 인용했다. 그 표는 조합 의미표이며 전이를 다루지 않는다 | Cowork `I-3` |
| N-12 | §0.1 이 제약명 출처를 `601802` §6.1 로 적었으나 그 절에 제약명이 없다. 제약은 `0168` 에 실재한다 | Cowork `I-4` |
| N-13 | `HG-A-9-N` 하위 식별자를 `601803` 이 도입했다. `601801` §0.1 은 canonical 을 `HG-A-N` 으로 못박았고 하위 8항은 번호 없는 코드블록이다. **매핑은 8/8 정확하다** | Cowork `I-5` |
| N-14 | §8 근거 목록에 `000220` · `601746` · `601748` · `601702` · `600010` 이 인용도 배제 근거도 없이 빠졌다. `000701` §46 요건 1·2 미충족 | Cowork `I-7` |
| N-15 | `601748` §8 게이트 1 「C-3 는 RLS policy 보다 선행」과 `U-7`·`U-16` 의 RLS 예고가 순서상 충돌할 수 있다. 인용되지 않았다 | Cowork `I-8` |
| N-16 | §5 정보 요소가 `000220` Foundation 축 ⑥ External Provider Boundary · ⑦ Reliability 와 겹친다. `000220` 을 인용하지 않았다 | Cowork `I-9` |
| N-17 | `0-A-2` 의 검증 등급 판정 기록이 `601800`~`601803` 어디에도 없다. `000221` §6.1 7질문 중 셋에 해당하는 것으로 보인다 | Cowork `I-10` |
| N-18 | `plan_status` 참조 함수 13개 · `tenant_status` 7개. FK 157개는 식별자 참조이며 상태 참조가 아니다. 실측 행 1건으로는 어휘 간 불변식을 확정할 수 없다 | Codex `F-5` · `F-6` |
| N-19 | `601803` §0.1 · §4 · §5 의 `601802` 인용은 원문과 일치한다. 다만 §7 `plan_status` 5값과 구독 도메인 상세가 `U-14` 한 행으로 압축됐다 | Codex `F-7` |
| N-20 | `U-3` 이 `TERMINATED` 를 벗어나는 lifecycle 전이를 미정으로 둔 것은 타당하다. `HG-A-9-7` 은 격리 복구에 집중하며 lifecycle 전이 전건을 금지한다고 단정할 수 없다 | Codex `F-8` |
| N-21 | 컬럼 타입 · nullable · DEFAULT · CHECK 허용값이 라이브와 일치한다. 두 축 조합을 제한하는 제약은 없다 | Codex `F-4` |
| N-22 | 신규 물리명 확정 0건. `offline_queue` 재사용 판정 0건. 물리 확정 선점 없음 | Codex `F-9` · Cowork `B4`·`B5` `NO CONCERNS FOUND` |
| N-23 | `000221` §4.2 가 「`601746` §8 게이트 1」을 인용하나 `601746` 에 §8 이 없다. 실제는 `601748` §8 Mandatory Gates 다. **`601803` 의 오류가 아니라 상위 문서 `000221` 의 오류이며 `5b05feb` 판본에 남아 있었다.** **2026-08-28 정정 완료** — 같은 문서 481행이 `601748` §8 을 정확히 기록하고 있었다 | Cowork `I-11` |

## §6 종합

```text
Blocker    10건   S-1 ~ S-10
informational  23건   N-1 ~ N-23

3/3 수렴        1건   S-1
2/3 수렴        2건   S-9(등급 갈림) · N-1
단독 발견        Codex 2 · Cowork 1 · Claude 6
```

**세 축이 각자의 강점대로 작동했다.**

```text
Codex   라이브 함수 본문 · guard 부재 · 함수 수 실측
Cowork  문서 내부 자기모순 · 제품 경계 · §46 요건
Claude  601702 상위 선언 위반 4건 — 원문을 읽어야 나온다
```

**`601702` §1.27 · §1.28 은 첨부로 받은 Claude 만 확인했다.**
**Codex · Cowork 은 저장소 접근이 있었으나 그 절을 열지 않았다.**

## §7 4단계 이관

**처분은 4단계 설계문서 정합화가 정한다. 이 문서는 판정하지 않는다.**

| # | 이관 대상 | 소관 |
|---|---|---|
| S-1 ~ S-9 | `601803` 수정 또는 `601801` 보강 | 4단계. `S-1`·`S-5`·`S-7` 은 1단계 재개방 가능성 있음 |
| S-10 | 제품 경계를 넘는 격리 전파 수단 | **1단계 소관** — `HG-A-2` 를 CatchMenu 범위로 축소할지, 전파 수단을 선언할지 |
| N-7 · N-15 | `U-7` 을 `0-A-2` 안에서 닫으면 `0-C` 침범 · `601748` §8 게이트 1 순서 | 4단계 착수 전 확인 |
| N-17 | `0-A-2` 검증 등급 판정 기록 부재 | 4단계 착수 전 |
| — | `000701` §47.1 3단계 actor 지정과 `601700` 실제 수행의 불일치 | governance |

> ⚠️ **`S-1` · `S-5` · `S-7` 은 `601801` 재개방을 요구할 수 있다.**
> **1단계는 Human 전담이며 2~4단계가 선언을 만들 수 없다**(`000701` §47.1).

## §8 근거 문서 목록 (`000701` §46)

| 문서 | 인용 | 지위 |
|---|---|---|
| `601804_Audit_Stage3_Adjacent_Domain_Codex.md` | 전문 | ACTIVE |
| `601805_Audit_Stage3_Adjacent_Domain_Cowork.md` | 전문 | ACTIVE |
| `601806_Audit_Stage3_Adjacent_Domain_Claude.md` | 전문 | ACTIVE |
| `601801_Register_Stage1_Business_Rules.md` | `HG-A-1`~`HG-A-9` · §2 | ACTIVE |
| `601802_Register_Stage0_Evidence_Collection.md` | §5 · §6 · §7 · §8 | ACTIVE |
| `601803_Diagram_Tenant_Lifecycle_State_Machine.md` | 검증 대상 전문 | ACTIVE |
| `601702_Register_Stage1_Business_Rules.md` | §1.26 · §1.27 · §1.28 · §1.42 · §1.43 · §1.45 | ACTIVE |
| `601746_Report_Stage11C_Conflict_Analysis.md` | §2.11 d · §4 | ACTIVE |
| `601748_Evidence_Stage12_Human_Merge_Decision.md` | §8 Mandatory Gates | ACTIVE |
| `000220_Guide_Shared_Commerce_Kernel_And_Foundation_Axis.md` | 축 ⑥ · ⑦ | ACTIVE |
| `000221_Guide_Post_0A_Spiral_Sequence.md` | §3 · §4.4 · §6.1 | ACTIVE |
| `000701_Guide_Controlled_AI_Development_Pipeline.md` | §13.6 · §46 · §47.1 | ACTIVE |
