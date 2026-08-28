# 601801_Register_Stage1_Business_Rules.md

Status: Active
Lifecycle: Register
Last Updated: 2026-08-29

## §0 성격

`000701` §47.1 의 **1단계 업무규칙 선언** 산출물이다.
Human 전담이며 AI 위임 불가다. 아래는 Human 이 확정한 내용을 그대로 기록한 것이다.

**이 문서는 「무엇을 사실로 삼을지」를 선언한다.** 설계도 구현도 아니다.
테이블 · 컬럼 · 값 이름의 구체적 결정은 2단계(ERD) 이후의 일이다.

> ✅ **Human Gate A — RESOLVED (2026-08-27)**
>
> `600010` §1.1 이 `0-A-2` 착수 전 결정을 요구한
> **tenant `ACTIVE` + `ISOLATED` 동시상태의 과금 · 서비스 정책**을 확정한다.
>
> **선언 15건 — `HG-A-1` ~ `HG-A-15`.**

### §0.1 식별자 규칙

```text
§1.N        문서 내 위치 · 구조
HG-A-N      업무규칙의 영구 식별자
```

**canonical identifier 는 `HG-A-N` 이다.**

```text
정식 최초 인용   601801 §1.N (HG-A-N)
이후 내부 추적    HG-A-N
```

> ⚠️ **`§1.N` 만으로 인용하지 않는다.**
> 앞 절이 추가되거나 문서를 재구성하면 위치 번호는 움직이지만
> **`HG-A-N` 은 계속 같은 규칙을 뜻해야 한다.**

**추적 구조**

```text
Business Rule     HG-A-3
Logic invariant   I-xx  → HG-A-3
TestPlan          TP-xx → HG-A-3
ChangeContract    D-xx  → HG-A-3
Audit             HG-A-3 충족 여부
```

**상위 근거**

```text
601702_Register_Stage1_Business_Rules.md   0-A 선언 45건
000221_Guide_Post_0A_Spiral_Sequence.md    나선 순서 · 권위보류 경계
```

> ⚠️ **`601502` · `601503` · `601505` · `601510` · `601511` 은 권위보류 대역이다.**
> **evidence 로만 인용하며 그 설계 결론을 승계하지 않는다**(`000221` §3.2).

**개정 이력**

| 일자 | 내용 |
|---|---|
| 2026-08-27 | 초안 — `HG-A-1`~`HG-A-8` (Human Gate A) |
| 2026-08-27 | `HG-A-9` 추가 — Stage 2 착수 전 `TRIAL` · `CANCELLED` · `TERMINATED` 조합 누락 발견. **`HG-A-1`~`HG-A-8` 의 의미를 수정하지 않고** 5×2 상태 조합과 우선순위를 닫았다 |
| 2026-08-28 | `HG-A-10`~`HG-A-12` 추가 — 3단계(`601807` `S-1`·`S-5`·`S-7`)가 확인한 업무규칙 공백. **제한적 재개방** — `HG-A-1`~`HG-A-9` 의 의미를 수정하지 않고 상태 초기값·전이·멱등성·동시성, 6축과 2축의 관계, MerchantAccount 경계를 추가했다 |
| 2026-08-28 | `HG-A-13`·`HG-A-14` 추가 — `601807` `S-10` 이 1단계 소관으로 분류됐으나 `HD-0-A-2-2` 재개방 범위에 빠져 있었다. 제품 경계와 격리 범위, tenant 별 포인트 권위 provider 선택을 선언한다 |
| 2026-08-28 | `HG-A-14` 폐기 — YS-OS 별도 DB 를 전제한 포인트 provider 선택 선언이었다. YS-OS 가 CatchMenu tenant 임이 확정돼 포인트 권위가 하나뿐이므로 선택지가 성립하지 않는다. `HG-A-13` 은 실제 외부 시스템 대상으로 유지 |
| 2026-08-29 | `HG-A-14` 폐기 철회 — 폐기 사유였던 「YS-OS 가 CatchMenu tenant」 판단이 틀렸다. Human 이 별도 제품 · 별도 DB · 별도 tenant registry 를 명시적으로 확정했다. `HG-A-13`·`HG-A-14` 를 복원한다 |
| 2026-08-29 | `HD-0-A-2-7` — `manage_subscription` 과 `T-2`~`T-7` 구독 전이를 `0-A-2` 범위에서 절단. `601807` `S-1` 이 확인한 선언 부재를 `HG-A-10` 에 따라 추론으로 채우지 않고 별도 워크패킷으로 이월한다. `tenant_status` 는 범위에 남는다. `HD-0-A-2-8` — `HG-A-9.1`~`HG-A-9.8` 식별자 부여 |
| 2026-08-29 | `HG-A-15` 추가 — `601810` `Q-4` 가 확인한 공백. `HG-A-5` 는 환불 · 크레딧 결정 주체를 정했으나 **격리 원인 귀책의 최종 확정 주체**를 정하지 않았다. 귀책 판정이 과금 조정으로 이어지므로 A급 항목이다 |

## §1 Human Gate A Business Rules

### §1.1 HG-A-1 — 상태축 독립성

**`tenant_status` 와 `isolation_state` 는 서로 독립된 축이다.**

```text
tenant_status     계약 · 고객 lifecycle
isolation_state   보안 · 장애 대응을 위한 기술적 격리
```

**`ACTIVE` + `ISOLATED` 는 유효한 동시상태다.**

| 조합 | 의미 |
|---|---|
| `ACTIVE` + `NONE` | 정상 영업 |
| `ACTIVE` + `ISOLATED` | 계약은 유효하나 시스템 사용이 격리됨 |
| `SUSPENDED` + `NONE` | 계약 · 운영상 서비스 정지 |
| `SUSPENDED` + `ISOLATED` | 서비스 정지 상태에서 추가 보안 격리 |

### §1.2 HG-A-2 — ACTIVE + ISOLATED 의 의미

**계약과 기본 구독이 유효하지만
tenant 의 일반 runtime 접근과 영업 데이터 처리가 fail-closed 로 차단된 상태다.**

| 기능 | 정책 |
|---|---|
| 고객 · 직원 로그인 | 차단 |
| 주문 · 대기 · 멤버십 · 재고 쓰기 | 차단 |
| 일반 tenant 조회 | 차단 |
| 신규 store · user 생성 | 차단 |
| 외부 POS · KDS 명령 전송 | 차단 |
| 외부 webhook | 직접 반영 금지. `HG-A-7` 을 따른다 |
| 시스템 감사 · 보안 조사 | 플랫폼 특권 경로만 허용 |
| 격리 해제 작업 | 승인된 복구 경로만 허용 |
| 계약 · 구독 정보 조회 | 플랫폼 관리 경로만 허용 |

**고객 관점에서는 서비스가 멈추지만 증거와 외부 이벤트를 버리지 않는다.**

### §1.3 HG-A-3 — 격리와 상업 상태의 분리

**`isolate_tenant` 는 아래를 자동 변경하지 않는다.**

```text
tenant_status
subscription 상태
청구조건
```

> ⚠️ **사고 처리 함수가 상업 계약을 임의로 바꾸면 안 된다.**

### §1.4 HG-A-4 — 기본료 · 사용량 과금

**격리만으로 기본 구독료를 자동 중단하지 않는다.**

```text
격리는 보안 · 운영 조치이며 계약 해지나 구독 취소가 아니다
```

**격리 중 차단된 신규 사용량은 사용량 과금에 포함하지 않는다.**

```text
격리 전 확정 사용량        정상 청구
격리 중 차단된 요청        사용량 미산정
격리 큐에 보존된 이벤트    복구 후 확정된 경우에만 산정
```

> ⚠️ **격리와 동시에 자동으로 과금을 멈추면
> 격리를 유발해 과금을 회피하는 경로가 생긴다.**

### §1.5 HG-A-5 — Human 과금 검토

**환불 · 크레딧 · 청구중단은 격리 원인과 책임을 검토한
별도 Human 승인으로만 처리한다.**

**다만 검토 누락을 방지한다.**

```text
격리가 발생하면 billing review 대상 여부를 자동 판정한다
플랫폼 귀책 격리 또는 장기 격리는 review task 와 감사 기록을 생성한다
미처리 review 가 존재하면 다음 청구 확정 전에 경고한다
```

**자동화 경계**

```text
자동화 가능   검토 작업 생성 · 알림 · 청구 전 경고
자동화 금지   환불 · 크레딧 · 청구중단 결정
```

**review task 생성은 금전 조작이 아니다.**

> ⚠️ **「장기 격리」의 시간 기준은 이 나선이 임의로 정하지 않는다.**
> 구독 · SLA 정책에서 확정하며, 그전까지는
> **모든 플랫폼 귀책 격리에 review 를 생성한다.**

### §1.6 HG-A-6 — 구독 변경과 격리 해제의 분리

**`manage_subscription` 은 `isolation_state` 를 변경하지 않는다.**
**구독 변경만으로 격리가 해제되지 않는다.**

```text
isolate_tenant        기술적 containment
manage_subscription   상업적 계약 lifecycle
```

> ⚠️ **`HD-0-A-2-7` 로 `manage_subscription` 이 `0-A-2` 범위에서 절단됐다.**
>
> **이 선언은 무효가 되지 않는다. 적용 시점이 이월된 것이다.**
>
> ```text
> 0-A-2         manage_subscription 을 설계 · 구현하지 않는다
>               isolation_state 를 변경하지 않는다는 경계는 유지된다
>
> 후속 워크패킷   Subscription Lifecycle 설계 시 이 경계를 지킨다
> ```

### §1.7 HG-A-7 — 외부 이벤트 수신과 side effect 격리

**격리 중에도 외부 provider 의 확정 사실과 raw event 는
검증 · 수신 · 불변 증거로 보존한다.**

| 동작 | 격리 중 정책 |
|---|---|
| 외부 승인 사실 수신 · 원문 보존 | **해야 한다** |
| 중복 검증 · 서명 검증 | **해야 한다** |
| 영업 주문 상태 진행 | 보류 |
| KDS release | 금지 |
| 멤버십 · 재고 변경 | 보류 |
| 이벤트 폐기 | **금지** |
| 응답 실패 반복 | **금지** |

**side effect 는 quarantine 또는 pending review 상태로 둔다.**

**격리 해제 후 재처리는 동일 이벤트의 중복 적용을 방지하는
idempotency 계약을 따른다.**

> ⚠️ **`catchmenu_common.offline_queue` 재사용은 여기서 승인하지 않는다.**
>
> ```text
> offline_queue     네트워크 단절 후 재전송 목적
> isolation queue   보안 · 운영 격리 중 side effect 보류 목적
> ```
>
> **실패 원인과 해제 권한이 다르다.**
> **구조 · 권한 · 보존기간을 조사한 뒤 2~4단계가 재사용 여부를 결정한다.**

### §1.8 HG-A-8 — 격리 해제 승인

**격리 해제는 별도 복구 동작으로 수행한다.**

```text
원인 해소 확인
Human 승인
감사 기록
```

**세 요건을 모두 거친다.**

### §1.9 HG-A-9 — Tenant lifecycle 과 isolation 조합의 합성 규칙

**`HG-A-1` 의 상태축 독립 원칙을 전체 정의역에 적용해 닫는다.**

> ⚠️ **`HG-A-1` ~ `HG-A-8` 의 의미를 바꾸지 않는다.**
> **`§1.1` 표가 다루지 않은 `TRIAL` · `CANCELLED` · `TERMINATED` 조합을 보완한다.**

> ⚠️ **하위 식별자 — `HD-0-A-2-8`**
>
> ```text
> canonical   HG-A-9.1 ~ HG-A-9.8
> 절 인용      601801 §1.9.N (HG-A-9.N)
> ```
>
> **`601803` 이 `HG-A-9-N` 형식을 임의로 도입했고**
> **`601805` `I-5` 가 「`601801` 이 정의하지 않은 인용 형식」으로 지적했다.**
> **매핑은 8/8 정확했으나 승인이 없었다. 이 결정이 그것을 부여한다.**

**합성 규칙**

```text
서비스 접근   tenant_status 와 isolation_state 중 더 제한적인 조건을 적용한다
과금 · 계약   tenant_status 와 subscription 조건만으로 결정한다
기술적 격리   서비스 제한을 추가하지만 상업 상태를 바꾸지 않는다
격리 해제     tenant_status 를 변경하거나 서비스를 자동 재개하지 않는다
```

**선언 8항**

```text
HG-A-9.1  tenant_status 의 5개 값
   ACTIVE · TRIAL · SUSPENDED · CANCELLED · TERMINATED 와
   isolation_state 의 NONE · ISOLATED 조합은 모두 표현 가능하다.

HG-A-9.2  서비스 접근에는 tenant_status 와 isolation_state 중
   더 제한적인 조건을 적용한다.
   ISOLATED 는 어떤 tenant_status 에서도 일반 runtime 접근과
   tenant 영업 side effect 를 허용하지 않는다.

HG-A-9.3  계약 · 기본 구독료 · 체험조건 · 취소 효력일 및 반복과금 여부는
   tenant_status 와 subscription 계약에서 결정한다.
   isolation_state 는 이를 자동 변경하지 않는다.

HG-A-9.4  TRIAL + ISOLATED 에서 격리는 유료 전환 · 신규 청구 ·
   체험 종료 또는 체험기간 연장을 자동 발생시키지 않는다.
   플랫폼 귀책 격리는 trial extension review 를 생성하되,
   실제 연장은 Human 승인으로만 수행한다.

HG-A-9.5  SUSPENDED + ISOLATED 에서 격리를 해제해도
   tenant_status 는 SUSPENDED 로 유지되고 서비스는 재개되지 않는다.

HG-A-9.6  CANCELLED + ISOLATED 에서 취소 및 종료 처리는 계속할 수 있으나
   일반 영업 서비스는 재개하지 않는다.
   격리 해제는 CANCELLED 를 ACTIVE 로 변경하지 않는다.

HG-A-9.7  TERMINATED + ISOLATED 는 유효한 terminal containment 상태다.
   TERMINATED 전이는 isolation 을 자동 해제하지 않으며,
   해당 tenant 는 일반 격리 복구 대상이 아니다.
   데이터 보존 · 삭제 · 익명화 · 법적 증거 처리만 수행할 수 있다.

HG-A-9.8  isolation 해제는 tenant_status 를 변경하지 않는다.
   tenant_status 변경 또한 isolation_state 를 자동 변경하지 않는다.
   두 축의 변경은 각각 별도 권한 · 사유 · 승인 및 감사 기록을 요구한다.
```

**상태 조합 판정 — 10건 전부 유효**

| `tenant_status` | `NONE` | `ISOLATED` |
|---|---|---|
| `TRIAL` | 체험 서비스 · 체험 과금조건 | 체험 서비스 차단. 체험조건은 자동 변경하지 않음 |
| `ACTIVE` | 정상 서비스 · 활성 구독 | 서비스 차단. 활성 계약 · 기본료 유지 |
| `SUSPENDED` | 서비스 정지 · 정지 계약조건 | 정지에 보안격리 추가 |
| `CANCELLED` | 신규 서비스 금지 · 종료 처리 | 종료 처리 중 기술적 격리 유지 |
| `TERMINATED` | 영구 종료 · 보존 / 삭제 절차 | terminal containment |

> ⚠️ **유효하다는 것이 정상 영업상태라는 뜻은 아니다.**
> **표현 가능한 조합과 서비스가 열리는 조합은 다르다.**

> ⚠️ **`TERMINATED` 는 일반 격리 복구 경로의 대상이 아니다.**
> **복구 함수가 `TERMINATED` tenant 를 되살리면 안 된다.**

### §1.10 HG-A-10 — 상태 초기값 · 전이 · 멱등성 · 동시성

**`601807` `S-1` 이 확인한 공백을 닫는다.**

> ⚠️ **`HG-A-1`~`HG-A-9` 는 조합의 유효성을 선언했을 뿐
> 전이의 허용 여부 · 수행 주체 · 초기값을 선언하지 않았다.**
> **2단계가 그것을 만들어냈고 3단계 세 검증자가 독립적으로 같은 결함에 도달했다.**

**초기값**

```text
isolation_state   초기값 NONE
tenant_status     초기값은 bootstrap 경로가 정한다 — 0-A-3 소관
```

> ⚠️ **현재 DB default 를 설계 근거로 승격하지 않는다**(`601702` §1.27).

**전이 선언**

```text
각 전이마다 아래를 명시한다

  허용 / 금지
  수행 주체
  전이 사유
  전제 조건
```

**미선언 전이는 미정으로 남긴다.** 2~4단계가 채우지 않는다.

**멱등성 · 동시성**

```text
동일 요청 재실행    같은 결과로 성공한다
오래된 요청         최신 상태를 되돌리지 못한다
실패                상태 변경과 감사 기록이 함께 commit 되거나 함께 rollback 된다
```

**권한 분리**

```text
격리 실행 권한과 격리 해제 권한이 반드시 같지 않다
해제 쪽이 더 강한 승인 조건을 요구할 수 있다
```

**구체적 권한 주체는 0-C 가 정한다.**

### §1.11 HG-A-11 — 이 나선이 소유하는 상태축

**`601807` `S-5` 가 확인한 충돌을 닫는다.**

```text
601702 §1.28 이 6축을 열거한다

  TenantStatus ≠ MerchantAccountStatus ≠ StoreServiceStatus
  ≠ StoreOperatingStatus ≠ TrialStatus ≠ IsolationState

  각 계층은 자신의 상태를 갖는다
  상위 상태를 하위 상태의 대체물로 사용하지 않는다
```

**0-A-2 가 직접 소유하는 상태축은 둘이다.**

```text
tenant_status
isolation_state
```

**나머지 4축**

```text
이번 나선의 직접 변경 대상이 아니다
두 직접 상태축으로부터 자동 파생되지 않는다
0-A-2 RPC 가 변경하지 않는다
접근 판단에서 참조가 필요하면 명시적 precondition 으로만 사용한다
```

> ⚠️ **6축의 존재를 부정하지 않는다.**
> **`0-A-2` 가 소유하는 상태머신을 2축으로 한정할 뿐이다.**
>
> **`601803` §3 격자의 `TRIAL` 행 「체험 서비스」는
> `Trial Status` 를 `tenant_status` 로 추론한 것이며 `601702` §1.27 이 금지한다.**
> **4단계가 그 표현을 정정한다.**

### §1.12 HG-A-12 — MerchantAccount 경계

**`601807` `S-7` 이 확인한 부재를 닫는다.**

**`MerchantAccount` 는 세 번째 lifecycle 상태축이 아니다.**

```text
tenant 가 운영하기 위한 권위 객체다
```

**`0-A-2` RPC 가 하지 않는 것**

```text
merchant_account 를 생성 · 삭제 · 교체하지 않는다
merchant_account_id 를 변경하지 않는다
tenant ↔ merchant_account 연결을 수정하지 않는다
```

**허용되는 것**

```text
정상 운영 자격 판단에서
tenant 와 연결된 유효한 merchant_account 존재 여부를
별도 prerequisite 로 검사할 수 있다
```

> ⚠️ **생성과 연결 복구는 `0-A-3` 소관이다.**
> **`0-A-2` 에서 merchant account 를 생성하려 하면
> `0-A-3` provisioning 범위를 침범한다.**

> ⚠️ **`601702` §1.28 이 `MerchantAccountStatus` 를 별도 축으로 열거했으나
> 그 축을 이 나선이 설계하지 않는다.**
> **`601746` §2.11 d 가 「tenant 상태 ↔ merchant account 계약 상태 미연결」을
> 이관한 그대로 둔다.**

### §1.13 HG-A-13 — 외부 제품 경계와 격리 범위

**`601807` `S-10` 이 확인한 공백을 닫는다.**

> ⚠️ **`HG-A-2` 가 격리 중 차단 대상으로 「멤버십 · 재고 쓰기」를 선언했다.**
> **YS-OS 는 별도 제품 · 별도 DB 이며 그 쓰기는 CatchMenu 통제 밖이다.**

**제품 경계**

```text
CatchMenu 와 YS-OS 는 각각 별도의 제품 · PostgreSQL DB ·
tenant registry · 포인트 ledger 를 가진다

현실의 동일 사업자 윤슬김밥은 양쪽에 각각 tenant/account 로 존재하며
서로 다른 식별자를 API mapping 으로 연결한다

  catchmenu_tenant_id ≠ ys_os_tenant_id
  catchmenu_store_id  ≠ ys_os_store_id

YS-OS 는 CatchMenu 의 윤슬김밥 tenant 자격으로 CatchMenu API 를 호출한다
```

**CatchMenu tenant 의 격리는 CatchMenu 가 소유하거나 통제하는
데이터 · API · 세션 · integration credential · 외부 전달 경로에만 적용한다.**

**CatchMenu 와 별도 권위를 가진 외부 제품의
업무 쓰기를 직접 또는 간접적으로 차단하지 않는다.**

**차단하는 것**

```text
CatchMenu 데이터 쓰기
CatchMenu 대기 · 주문 · native 포인트 쓰기
해당 tenant 의 로그인 · 세션
외부 제품이 해당 tenant 자격으로 호출하는 CatchMenu API
CatchMenu integration credential
CatchMenu provider outbox 전달
```

**차단하지 않는 것**

```text
외부 제품 DB 쓰기
외부 제품의 직원 업무 · 재고 처리 · 자체 멤버십
외부 제품 point ledger
외부 제품의 다른 외부 연동
```

> ⚠️ **CatchMenu 는 외부 제품을 격리하지 않는다.**
> **외부 제품이 CatchMenu 에 접근하는 통로만 차단한다.**
>
> **CatchMenu 의 보안 사고가 별도 권위를 가진 제품의
> 전체 운영을 정지시켜서는 안 된다.**

**외부 제품이 해당 CatchMenu tenant 의 자격으로 API 를 호출하면
격리 상태에서 그 호출을 fail-closed 로 거부한다.**

**CatchMenu 격리 상태는 외부 제품의 tenant 상태나 업무 상태로
자동 전파되지 않는다.**

> ⚠️ **이 조항은 실제 외부 시스템에도 같은 원리로 적용된다.**
>
> ```text
> Toss PG · Toss POS / Kiosk · Smartcast KDS 등
>
> 그 시스템들은 CatchMenu 와 별도 권위를 갖는다
> 격리가 그 시스템의 자체 운영을 멈추지 않는다
> ```

> ⚠️ **`HG-A-2` 의 「멤버십 · 재고 쓰기 차단」은
> CatchMenu 가 소유 · 통제하는 데이터만 뜻한다.**
> **`HG-A-2` 본문을 수정하지 않고 이 조항이 범위를 한정한다.**

> ⚠️ **`601807` `S-10` 을 기각하지 않는다.**
>
> ```text
> Cowork F-2 의 「YS-OS = 별도 제품 · 별도 DB」 전제는 이 선언과 일치한다
> 601807 이 그 전제를 독립 재도출하지 않은 것은 절차적 finding 이며
> 전제의 진위와 별개다
> ```

### §1.14 HG-A-14 — Tenant 별 포인트 권위 선택

**CatchMenu tenant 는 포인트 권위 provider 를 하나 선택한다.**

```text
CATCHMENU_NATIVE   CatchMenu point ledger 가 권위
EXTERNAL           연결된 외부 제품의 point ledger 가 권위
                   CatchMenu 는 API 호출 결과만 보존한다
```

**하나의 포인트 거래에 두 provider 가 동시에 권위를 갖거나
적립 · 차감하는 것을 허용하지 않는다.**

**거래 생성 시 provider 를 snapshot 으로 남긴다**

```text
point_provider
provider_tenant_ref
provider_transaction_ref
```

**설정이 나중에 바뀌어도 이미 발생한 거래의 provider 는 바뀌지 않는다.**

**자동 fallback 금지**

```text
외부 provider 의 timeout 또는 실패를 이유로
CatchMenu native 포인트로 자동 전환하지 않는다

동일 idempotency key 를 유지해 보류 · 재시도한다
장기 실패는 운영자 확인 대상이다
```

> ⚠️ **자동 fallback 은 이중 적립을 만든다.**
> **`000221` §6.1 「돈 · 포인트 · 재고 수량을 바꿀 수 있는가」에 해당하는 A급 항목이다.**

**`EXTERNAL` 모드에서 CatchMenu 가 가질 수 있는 것**

```text
외부 회원 연결 식별자
요청 금액과 포인트
외부 transaction ID
처리 상태
마지막 조회 잔액과 조회 시각 — cache 이며 권위 잔액이 아니다
감사 및 재처리 정보
```

**provider 변경은 기존 잔액과 진행 중 거래를 자동 변환하지 않는다.**
**별도의 전환 계약을 따른다.**

> ⚠️ **포인트 잔액 이전과 전환 절차는 `0-A-2` 구현 대상이 아니다.**
> **후속 포인트 연동 워크패킷 소관이다 — §4.**

### §1.15 HG-A-15 — 격리 원인 귀책의 확정 주체

**`601810` `Q-4` 가 확인한 공백을 닫는다.**

```text
HG-A-5 가 환불 · 크레딧 · 청구중단을 Human 승인으로 한정했다
601801 §2 가 격리 원인을 5분류로 열거했다
없는 것   그 분류를 누가 최종 확정하는가
```

**자동 시스템은 증거를 모으고 임시 분류만 한다.**

```text
PROVISIONAL_PLATFORM
PROVISIONAL_TENANT
PROVISIONAL_PROVIDER
UNKNOWN
```

**최종 귀책 확정은 승인된 Human 역할이 수행한다.**

```text
1차 분류   운영 담당자
최종 확정   과금 · 보상에 영향이 있으면 별도 승인권자
분리 원칙   자기가 관여한 사건을 자기 혼자 승인하지 못한다
```

> ⚠️ **자동 분류는 임시값이며 과금 조정의 근거가 되지 않는다.**
> **`HG-A-5` 가 정한 「환불 · 크레딧은 Human 승인」의 선행 단계다.**

**`0-A-2` 가 정하는 것**

```text
임시 분류값의 존재와 그것이 임시라는 사실
최종 확정이 Human 역할의 행위라는 것
확정 이력이 감사 기록에 남는다는 것
```

**`0-A-2` 가 정하지 않는 것**

```text
구체적 역할 이름과 권한 — 0-C
승인권자 배정 규칙 — 0-C
보상 정책과 금액 — 별도
provider 장애를 플랫폼 귀책으로 볼 것인가 — 계약 · 법무
```

> ⚠️ **`000221` §6.1 「돈 · 포인트 · 재고 수량을 바꿀 수 있는가」에 해당하는 A급 항목이다.**

## §2 격리 원인별 처분

| 격리 원인 | 기본 구독료 | 후속 조치 |
|---|---|---|
| 보안 침해 의심 | 유지 | 조사 후 Human 판단 |
| 고객의 약관 위반 | 유지 | 계약 상태 별도 전이 |
| 플랫폼 장애 | 유지 후 크레딧 검토 | Human 보상 결정 |
| 법적 · 행정 명령 | 유지 원칙 | 계약 · 법무 판단 |
| 고객의 자발적 사용 중지 | — | **`ISOLATED` 사용 금지** |
| `TRIAL` 중 플랫폼 장애 | 체험조건 유지 | trial extension review 자동 생성. 연장은 Human 승인 |
| `CANCELLED` 이후 격리 | 반복과금 없음 | 최종 청구 · 환불 · 데이터 반출 등 종료 절차만 |
| `TERMINATED` 이후 격리 | 과금 없음 | 보존 · 삭제 · 익명화 · 법적 증거 처리만 |

> ⚠️ **마지막 행이 중요하다.**
> **고객이 잠시 서비스를 쉬는 것을 `ISOLATED` 로 표현하지 않는다.**
> 그것은 `SUSPENDED` 또는 별도 구독 상태의 문제다.
>
> **격리를 편의상 재사용하면 축이 오염된다.**

## §3 Human Decision — Gate A

```text
Human Decision — Gate A

HG-A-1 through HG-A-8 are approved, subject to the following
clarifications:

1. Isolation never automatically changes tenant lifecycle,
   subscription state, billing terms, refunds, credits, or suspension.

2. Platform-caused or prolonged isolation must automatically create
   a billing review task and pre-invoice warning, but no monetary
   adjustment may execute without Human approval.

3. External provider facts must still be validated and preserved
   during isolation. Tenant business side effects are quarantined
   and later replayed only under an idempotent recovery contract.

4. Reuse of catchmenu_common.offline_queue is not approved here.
   Its suitability must be decided during 0-A-2 design.

5. All ten combinations of tenant_status and isolation_state are
   representable. Service access takes the more restrictive of the two;
   commercial terms are decided by tenant_status and subscription only.
   Lifting isolation never changes tenant_status, and changing
   tenant_status never lifts isolation. TERMINATED tenants are not
   subject to ordinary isolation recovery.

HD-0-A-2-1 — Verification Grade

0-A-2 affects tenant lifecycle, technical isolation, access rights and
the tenant data boundary. It is graded A. Blind design review,
ChangeContract, fault injection and independent audit are not omitted.

HD-0-A-2-2 — Stage 1 Reopening

S-1, S-5 and S-7 identified at Stage 3 are gaps in human business rules
that modelling alone cannot close. 601801 is reopened in a limited way.
The scope is: state initial values, permitted transitions, transition
actors, idempotency and concurrency; the relation between the six axes
and this spiral's two; and the non-axis boundary of MerchantAccount.

HD-0-A-2-3 — State Axes

The state axes this spiral owns are tenant_status and isolation_state.
Other axes are neither derived nor modified, and are referenced only as
explicit preconditions where required.

HD-0-A-2-4 — MerchantAccount Boundary

MerchantAccount is not a third lifecycle axis. 0-A-2 RPCs do not create,
delete, replace or re-link it. Checking for the existence of a valid
merchant account as an operating prerequisite is permitted; creation and
link repair remain 0-A-3 scope.

HD-0-A-2-5 — External Product Boundary

CatchMenu and YS-OS are separate products with separate PostgreSQL
databases, tenant registries and point ledgers. The same real business,
윤슬김밥, exists on both sides as its own tenant/account, and the two
identifiers are joined by API mapping rather than by a cross-database
foreign key or a shared tenant primary key.

Isolation of a CatchMenu tenant applies only to data, APIs, sessions,
integration credentials and outbound paths that CatchMenu owns or
controls. It does not block, directly or indirectly, the business writes
of a separate product holding its own authority. Where such a product
calls CatchMenu APIs under that tenant's credentials, those calls are
refused fail-closed. CatchMenu isolation does not propagate into the
other product's tenant or business state.

HD-0-A-2-6 — Point Authority Provider

A CatchMenu tenant selects exactly one point authority provider:
CATCHMENU_NATIVE, where the CatchMenu point ledger is authoritative, or
EXTERNAL, where the connected external product's ledger is authoritative
and CatchMenu preserves only the call and its result. No point
transaction may hold two authoritative providers, and none may be
accrued or deducted by both. The provider is recorded as a snapshot when
the transaction is created and does not change when the setting later
changes. Automatic fallback to native points on external timeout or
failure is forbidden; the request is held and retried under the same
idempotency key, and prolonged failure is for an operator to review.
Balance migration and provider switching are not implemented in 0-A-2.

HD-0-A-2-7 — manage_subscription Scope Cut

manage_subscription and the subscription state transitions T-2 through
T-7 are removed from the design and implementation scope of 0-A-2. The
permitted conditions, actors, billing and entitlement effects of those
transitions have not been declared by the human, and HG-A-10 forbids
stages two through four from inferring them. Subscription lifecycle is
declared, designed and verified in a separate workpacket. Until then the
existing function remains under the call prohibition, and 0-A-2 only
regression-checks that its body and privileges are unchanged.

tenant_status itself is not removed from scope. 0-A-2 reads it for
access decisions and does not change it.

HD-0-A-2-8 — HG-A-9 Sub-identifiers

The eight rules under HG-A-9 receive canonical identifiers HG-A-9.1
through HG-A-9.8. Document references use the form 601801 §1.9.N with
the gate identifier alongside.

HD-0-A-2-9 — Fault Attribution Authority

Automated classification of an isolation cause is provisional and never
by itself a basis for billing adjustment. Final attribution is an act of
an approved human role: an operator makes the first classification, and
where billing or compensation is affected a separate approver confirms
it. No one confirms an incident they were party to alone. The concrete
roles and their privileges are 0-C scope; compensation policy is
separate. What 0-A-2 fixes is that a provisional value exists, that it
is marked provisional, and that confirmation is recorded.
```

**판정자** — 정영석, 2026-08-27

**HG-A-9 판정자** — 정영석, 2026-08-27

**HD-0-A-2-1 ~ HD-0-A-2-4 판정자** — 정영석, 2026-08-28

**HD-0-A-2-5 판정자** — 정영석, 2026-08-28

**HD-0-A-2-6 판정자** — 정영석, 2026-08-29

**HD-0-A-2-7 · HD-0-A-2-8 판정자** — 정영석, 2026-08-29

**HD-0-A-2-9 판정자** — 정영석, 2026-08-29

## §4 후속 설계 의무

**2단계 ERD 이후가 정한다.**

```text
테이블 · 컬럼 · 값 이름
isolation queue 의 물리 구조
「장기 격리」의 시간 기준
격리 해제 복구 경로의 구현
billing review task 의 물리 표현
과금 금액 계산 · 정산 로직
trial extension review 의 물리 표현
TERMINATED 보존 · 삭제 · 익명화 절차
전이별 수행 주체의 구체적 권한 정의 — 0-C
tenant_status 초기값을 정하는 bootstrap 경로 — 0-A-3
MerchantAccountStatus 축 — 후속. 601746 §2.11 d
point_provider 설정의 물리 표현 — 후속 포인트 연동 워크패킷
provider snapshot 3필드의 물리 표현 — 동상
외부 provider 실패 시 보류 · 재시도 절차 — 동상
외부 회원 연결 식별자와 잔액 cache 구조 — 동상
provider 전환 계약 — 잔액 이전 · 진행 중 거래 처리. 동상
integration mapping — catchmenu_tenant_id ↔ 외부 제품 tenant ref. 동상
귀책 확정 역할과 승인권자 배정 — 0-C
provider 장애의 귀책 판정 기준 — 계약 · 법무
```

**각 산출물은 자신이 어느 `HG-A-N` 에서 나왔는지 명시한다**(§0.1).

## §5 근거 문서 목록 (`000701` §46)

| 문서 | 인용 | 지위 |
|---|---|---|
| `600010_Tracker_Spiral_Workpacket_Progress.md` | §1.1 — Gate A 요구 | ACTIVE |
| `000221_Guide_Post_0A_Spiral_Sequence.md` | §3 · §3.2 · §4.1 | ACTIVE |
| `601702_Register_Stage1_Business_Rules.md` | 선언 45건 — 상위 근거 | ACTIVE |
| `601800_Readme_Tenant_Lifecycle_Rpc_Alignment.md` | §3 · §5 | ACTIVE |
| `601511` | Gate A 발생 경위 | ⛔ **권위보류. evidence 로만** |
| `601505` §4 | 호출 금지 조항 | ⛔ **권위보류. evidence 로만** |
