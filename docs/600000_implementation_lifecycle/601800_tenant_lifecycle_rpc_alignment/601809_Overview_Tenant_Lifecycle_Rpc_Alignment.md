# 601809_Overview_Tenant_Lifecycle_Rpc_Alignment.md

Status: Active
Lifecycle: Overview
Last Updated: 2026-08-29

## §0 성격

`000701` §47.1 의 **4단계 설계문서 정합화** 산출물이다.

**1단계 선언과 2단계 모델을 구현 범위로 옮긴 것이며 구현 설계가 아니다.**

```text
601801   HG-A-1 ~ HG-A-15 · HD-0-A-2-1 ~ HD-0-A-2-9
601803   상태 전이 모델 (Active)
601802   Stage 0 증거수집
601808   3단계 대조 — 이 문서의 착수 범위를 정했다
```

> ⚠️ **테이블 · 컬럼 · 제약명을 확정하지 않는다.**
> **허용 파일과 금지 조작은 ChangeContract(`601812`) 소관이다.**

> ⚠️ **`601801` 에 없는 선언을 만들지 않는다.**
> **3단계에서 세 검증자가 독립적으로 같은 결함을 지적한 지점이다**(`601807` `S-1`).

**검증 등급 — A**(`HD-0-A-2-1`). 등급 판정 기록은 `601801` §3 에 있다.

## §1 Purpose

**`0-A-2` 가 무엇을 확정하는가.**

```text
tenant_status 와 isolation_state 의 독립성을 물리적으로 성립시킨다
isolate_tenant 를 그 축에 맞게 정합화한다
격리 · 해제 · 감사 경로를 확정한다
```

> ⚠️ **`601802` 가 확정한 것** — `isolation_state` 를 참조하는 함수 · VIEW · MATVIEW · TRIGGER 가 **전 스키마 0개**다(§6.2).
> **`isolate_tenant` 는 `tenant_status` 에 `ISOLATED` 를 쓰며
> 그 값은 허용값 밖이라 해당 UPDATE 는 실패한다**(§5.2 · §6.1 · §9.1).
>
> **두 축 분리는 CHECK 에만 있고 로직에 없다.**
> **이 나선은 정렬이 아니라 축 신설에 가깝다**(`601803` §0.1).

**이 나선이 소유하는 상태축은 둘이다**(`HG-A-11` · `HD-0-A-2-3`).

```text
tenant_status      읽기만 한다. 변경하지 않는다
isolation_state    이 나선이 실제로 쓰기 시작한다
```

## §2 Implementation Target

| # | 구현 대상 | `601801` 근거 | `601803` 근거 |
|---|---|---|---|
| A-1 | `isolation_state` 를 실제로 쓰는 격리 경로 | `HG-A-1` 축 독립 · `HG-A-3` 격리와 상업 상태 분리 | §2 `I-2` |
| A-2 | `isolate_tenant` 정합화 — §4 가 수리인지 재작성인지 판정한다 | `HG-A-3` | §4 책임 경계 표 |
| A-3 | 격리 해제 경로 — 원인 해소 확인 · Human 승인 · 감사 기록 3요건 | `HG-A-8` | §2 `I-3` · 3요건 다이어그램 |
| A-4 | `TERMINATED` 분기 — 일반 복구 대상에서 제외 | `HG-A-9.7` | §2 `I-4` |
| A-5 | `tenant_status` 조회 · 접근 판단 — **읽기만 한다** | `HG-A-9.2` 더 제한적인 조건 · `HG-A-11` | §3.3 합성 규칙표 |
| A-6 | 멱등성 · 동시성 — 동일 요청 재실행 · 오래된 요청 · 실패 시 원자성 | `HG-A-10` | §7 `U-15` |
| A-7 | 감사 기록 — 상태 변경과 함께 commit / rollback | `HG-A-8` · `HG-A-10` | §2 `I-3` |
| A-8 | 격리 범위 한정 — CatchMenu 통제 대상에만 적용 | `HG-A-13` | §3.4 |
| A-9 | isolation queue — 외부 이벤트 보존 · quarantine · 재처리 | `HG-A-7` | §5 `Q-1`~`Q-10` |
| A-10 | billing review task — 생성 · 알림 · 청구 전 경고 | `HG-A-5` · `HG-A-9.4` | §6 `B-1`~`B-8` |

> ⚠️ **`A-9` · `A-10` 의 물리 표현은 ChangeContract 소관이다.**
> **`601803` §7 `U-8` · `U-9` · `U-10` 이 이월했다.**

> ⚠️ **`A-5` 는 쓰기를 포함하지 않는다.**
> **`tenant_status` 를 바꾸는 전이는 `HD-0-A-2-7` 로 절단됐다** — §3.

### §2.1 착수 전 확인 — `601808` §5

| # | 확인 대상 | 상태 |
|---|---|---|
| C-1 | `U-7` 「더 제한적인 조건」의 판정 위치를 `0-A-2` 안에서 확정하지 않는다 | `601803` `U-7` · `U-18` 이 `0-C` 소관으로 기록했다 |
| C-2 | `601748` §8 게이트 1 — C-3 는 RLS policy 보다 선행 | 이 나선은 RLS policy 를 만들지 않으므로 침범하지 않는다. `601803` `U-19` |
| C-3 | 검증 등급 판정 기록 | `HD-0-A-2-1` — A급. `601801` §3 |

## §3 Out of Scope

| 제외 대상 | 소관 | 근거 |
|---|---|---|
| `manage_subscription` · `T-2`~`T-7` 구독 전이 | 별도 Subscription Lifecycle 워크패킷 | `HD-0-A-2-7` |
| provisioning RPC 재설계 · `C-3` tenant 일치 강제 · `NOT NULL` 승격 | `0-A-3` | `000221` §4.2 · `601748` §8 |
| `tenant_status` bootstrap 초기값 경로 | `0-A-3` | `HG-A-10` · `601803` `U-4` |
| User / Auth / Session | `0-B` | `000221` §4.3 |
| Role / Permission / RLS policy · 전이별 권한 주체 | `0-C` | `000221` §4.4 · `HG-A-10` |
| 과금 금액 계산 · 정산 로직 | 별도 | `601801` §4 · `601803` `U-13` |
| `MerchantAccount` 생성 · 삭제 · 교체 · 연결 변경 | `0-A-3` | `HG-A-12` · `HD-0-A-2-4` |
| `MerchantAccountStatus` 축 | 후속 | `HG-A-12` · `601746` §2.11 d |
| `601702` §1.28 의 나머지 4축 — `StoreServiceStatus` · `StoreOperatingStatus` · `TrialStatus` · `MerchantAccountStatus` | 각 축 소관 나선 | `HG-A-11` · `HD-0-A-2-3` |
| 포인트 provider 전환 절차 · 잔액 이전 | 후속 포인트 연동 워크패킷 | `HG-A-14` · `601801` §4 |
| 「장기 격리」 시간 기준 | 구독 · SLA 정책 | `HG-A-5` · `601803` `U-11` |
| `TERMINATED` 보존 · 삭제 · 익명화 절차 | 후속 | `601801` §4 · `601803` `U-12` |
| UI | Phase 0 Exit Demo | `000221` §4.6 |

> ⚠️ **`HG-A-6` 은 무효가 아니다.**
> **`manage_subscription` 이 `isolation_state` 를 변경하지 않는다는 경계는 유지되며
> 후속 워크패킷이 그 경계를 지킨다**(`601801` §1.6 병기).

## §4 기존 함수 취급

**이 절이 이 Overview 의 핵심이다.**

### §4.1 실측

**`601802` · `601804` 가 실측한 것.**

| 함수 | 관측 |
|---|---|
| `isolate_tenant` | `tenant_status` 에 허용값 밖 값을 쓴다 — 그 경로는 실행 불가. `isolation_state` 참조 0건. SECURITY DEFINER. DB 직접 호출자 2건 — `detect_threat` · `manage_subscription` |
| `manage_subscription` | phantom `tenants.company_name` 참조 1건. `isolate_tenant` 호출 named argument 불일치 2곳. source-state guard 없음 |
| `detect_threat` | FATAL 경로에서 `isolate_tenant` 를 호출하며 같은 named argument 불일치 |

> ⚠️ **호출부 3곳이 모두 실제 파라미터명과 다른 이름으로 호출한다**(`601802` §5.2 · §9.1).
> **`isolate_tenant` 는 현재 어느 호출자에서도 성립하지 않는다.**

### §4.2 판정 — **수리한다**

```text
결론   isolate_tenant 를 같은 이름 · 같은 자리에서 정합화한다
       신규 함수를 만들고 기존을 폐기하는 재작성을 택하지 않는다
```

**근거 1 — 호출자를 고칠 수 없다**

```text
manage_subscription   HD-0-A-2-7 로 0-A-2 범위 밖
detect_threat         601505 §4 호출 금지 대상이며 0-A-2 in scope 가 아니다
```

**신규 이름을 도입하면 두 호출자가 계속 옛 함수를 가리킨다.**
**이 나선이 그 호출부를 고칠 수 없으므로 재작성은 깨진 참조를 남긴다.**

**근거 2 — 식별자가 금지 조항의 주소다**

```text
601505 §4 호출 금지 7건이 함수명으로 지정돼 있다
600010 §1.1 이 그 금지를 0-A-2 완료까지 유효로 유지한다
```

**이름이 바뀌면 금지 조항과 감사 기록의 연결이 끊어진다.**

**근거 3 — 권한 표면이 유지된다**

```text
601802 §9.2   isolate_tenant EXECUTE ACL = postgres, authenticated
```

**신규 함수는 ACL 을 새로 정해야 하고 그 결정은 `0-C` 소관이다**(`HG-A-10`).
**수리는 권한 표면을 건드리지 않는다.**

> ⚠️ **수리의 뜻**
>
> ```text
> 같은 것    함수명 · 스키마 · 호출 지점
> 바뀌는 것  본문이 isolation_state 를 쓰도록 정합화된다
>            tenant_status 를 쓰지 않는다 — HG-A-3
> ```
>
> **본문 변경 방법(교체 · 부분 수정)과 물리 조작은 ChangeContract 가 정한다.**

### §4.3 ChangeContract 로 이월하는 미결 2건

| # | 미결 | 왜 여기서 정하지 않는가 |
|---|---|---|
| M-1 | 파라미터명 불일치를 어느 쪽으로 맞출 것인가 | 호출부를 고치면 `manage_subscription`(범위 밖)을 건드린다. 시그니처를 고치면 함수 식별이 바뀐다. **양쪽 다 이 Overview 가 결정할 수 없고 물리 조작 판단이 필요하다** |
| M-2 | `detect_threat` 가 격리를 발동하는 경로의 처분 | 격리 발동 권한 주체가 미선언이다 — `601803` `U-6`. `detect_threat` 자체는 `0-A-2` in scope 가 아니다 |

> ⚠️ **`M-1` 이 열려 있는 동안 `isolate_tenant` 는 어느 호출자에서도 성립하지 않는다.**
> **ChangeContract 가 이를 닫지 않으면 `0-A-2` 완료 후에도 함수가 살아나지 않는다.**

### §4.4 `601505` §4 호출 금지의 해제 조건

**이 Overview 가 판정한다.**

```text
0-A-2 완료 시 해제 대상        isolate_tenant 1건
                               조건 — M-1 이 닫히고 A-3 해제 경로가 성립할 것

해제되지 않는 것               manage_subscription      HD-0-A-2-7 이월 워크패킷
                               detect_threat            0-A-2 in scope 아님
                               verify_security_token
                               gateway_audit_entry      각 소관 나선
                               record_van_transaction
                               check_staff_permission
```

> ⚠️ **`0-A` 가 `provision_tenant` 를 두고 같은 판정을 미뤘고 `0-A-3` 이 그것을 다룬다.**
> **이 절은 `isolate_tenant` 만 판정한다.**

> ⚠️ **`601505` 는 권위보류 대역이다**(`000221` §3.2).
> **금지 조항의 존재는 `600010` §1.1 이 현재 유효로 유지한 사실을 근거로 인용했으며
> `601505` 의 설계 결론을 승계하지 않았다.**

## §5 근거 문서 목록 (`000701` §46)

### §5.1 인용한 문서

| 문서 | 인용 | 지위 |
|---|---|---|
| `601801_Register_Stage1_Business_Rules.md` | `HG-A-1` · `HG-A-3` · `HG-A-5` · `HG-A-6` · `HG-A-7` · `HG-A-8` · `HG-A-9.2` · `HG-A-9.4` · `HG-A-9.7` · `HG-A-10` · `HG-A-11` · `HG-A-12` · `HG-A-13` · `HG-A-14` · `HD-0-A-2-1` · `HD-0-A-2-3` · `HD-0-A-2-4` · `HD-0-A-2-7` · §1.6 병기 · §3 · §4 | ACTIVE |
| `601802_Register_Stage0_Evidence_Collection.md` | §5.2 · §5.3 · §6.1 · §6.2 · §9.1 · §9.2 | ACTIVE |
| `601803_Diagram_Tenant_Lifecycle_State_Machine.md` | §0.1 · §2 · §3.3 · §3.4 · §4 · §5 · §6 · §7 `U-4`~`U-19` | ACTIVE |
| `601808_Report_Stage3_Impact_Reconciliation.md` | §2 대조표 · §5 착수 전 확인 | ACTIVE |
| `601702_Register_Stage1_Business_Rules.md` | §1.28 6축 | ACTIVE |
| `601746_Report_Stage11C_Conflict_Analysis.md` | §2.11 d — `MerchantAccountStatus` 이관 | ACTIVE |
| `601748_Evidence_Stage12_Human_Merge_Decision.md` | §8 Mandatory Gates 게이트 1 | ACTIVE |
| `601800_Readme_Tenant_Lifecycle_Rpc_Alignment.md` | §5 · §6 · §10 | ACTIVE |
| `000220_Guide_Shared_Commerce_Kernel_And_Foundation_Axis.md` | Foundation 축 ⑥ · ⑦ — `A-9` 정보 요소와 겹친다. **축 귀속은 `000220` §4 소관이며 이 문서가 판정하지 않는다** | ACTIVE |
| `000221_Guide_Post_0A_Spiral_Sequence.md` | §3.2 권위보류 경계 · §4.2 · §4.3 · §4.4 · §4.6 · §6.1 | ACTIVE |
| `600010_Tracker_Spiral_Workpacket_Progress.md` | §1.1 — `601505` §4 금지 조항이 `0-A-2` 완료까지 유효 | ACTIVE |
| `000701_Guide_Controlled_AI_Development_Pipeline.md` | §46 · §47.1 | ACTIVE |

### §5.2 확인했으나 배제한 문서

**`000701` §46 요건 1 — 배제 사유를 기록한다.**

| 문서 | 배제 사유 |
|---|---|
| `601804_Audit_Stage3_Adjacent_Domain_Codex.md` | 3단계 검증자 원본. `601808` 이 `F-1`~`F-9` 를 전건 승계했으므로 통합본을 인용한다 |
| `601805_Audit_Stage3_Adjacent_Domain_Cowork.md` | 동상 — `F-1`·`F-2`·`I-1`~`I-11` |
| `601806_Audit_Stage3_Adjacent_Domain_Claude.md` | 동상 — `C-B1`~`C-B7`·`C-I1`~`C-I10` |
| `601807_Report_Stage3_Integration.md` | 3단계 통합본. `601808` 이 그 33건을 분류해 4단계 지시서로 재구성했다 |
| `601502` · `601503` | 권위보류 대역. 설계 결론을 승계하지 않는다 — `000221` §3.2 |
| `601505` | 권위보류 대역. **§4 금지 조항의 존재만 `600010` §1.1 을 통해 간접 인용했다** — §4.4 |
| `601510` · `601511` | 권위보류 대역. `0-A-2` 파생 경위와 Gate A 발생 경위는 `600010` 이 승계했다 |
| `sql/migrations/0168_…sql` | 제약 실재 위치. 이 Overview 는 물리 제약을 다루지 않으므로 `601803` §0.1 의 기록으로 갈음한다 |

> ⚠️ **`601805` `I-7` 이 `601803` 의 §46 요건 1·2 미충족을 지적했다.**
> **이 문서는 인용 12건과 배제 8건을 모두 적었다.**

## §6 다음 단계

```text
601810   Logic          불변조건 I-N 을 HG-A-N 에서 도출한다
601811   TestPlan       A급 — blind design review · fault injection 포함
601812   ChangeContract 허용 파일 · 금지 조작 · M-1 · M-2 처분
Stage 5 ~ 12            A급 절차 전체 — HD-0-A-2-1
```

**이 Overview 는 구현을 승인하지 않는다.**

```text
허용 파일과 금지 조작   ChangeContract 가 정한다
착수 권한               Stage 7 이 정한다
```

**`601505` §4 의 금지 조항은 이 나선 완료까지 계속 유효하다**(`600010` §1.1).
