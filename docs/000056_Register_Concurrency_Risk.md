# 000056_Register_Concurrency_Risk

Status: Draft
Lifecycle: Register
Owner: TBD
Last Updated: 2026-07-15

## §0 번호 확인

`docs/` 루트 직접 조회 결과: `000053`(Matrix_Domain_To_Artifact_Traceability)/`000054`(Assessment_Workpacket_Overview_Logic_Filename_Convention_Governance_Gap) 다음, `000055`~`000099`가 이미 전부 사용 중이며(재확인, `ls docs/*.md` 전수 조회) 그 구간의 유일한 빈 번호는 `000056`이다(`000055`와 `000057` 사이). `000057`부터 `000099`까지는 전부 파일이 존재하고, `000100`부터는 폴더 기반 도메인(`000100_project_foundation` 등)으로 전환되어 단일 파일 번호 공간이 아니다. `docs/000005_Index_Document_Number.md`/`docs/000007_Map_Full_Directory.md`에서 `000056` 검색 결과 0건, 저장소 전체(`grep -rl`)에서도 0건 — 예약되거나 이미 참조된 번호가 아님을 확인했다. `000060_Report_Batch_7A_Docs_Number_Band_Density_Gap_Scan.md`(과거 갭 스캔)도 `000000-000999` 대역을 "정상" 등급(갭 5건)으로만 기록했을 뿐, `000056`을 특정해 예약한 근거는 없다. **`000056`을 이 문서의 번호로 확정한다.**

## §1 문서 목적

이 문서는 결제/주문/KDS/대기열/재고/멤버십/DID 전 도메인에 걸쳐, 오늘 세션(2026-07-15)의 ChatGPT+제미나이 교차검증을 거쳐 확정된 동시성(레이스 컨디션) 위험 25개 이상을 하나의 레지스터로 등록한다. `000053`(도메인→산출물 추적 매트릭스)과 같은 급의 살아있는(living) 참조 문서이며, 특정 워크패킷 하나에 속하지 않고 이후 여러 워크패킷(§8 로드맵)이 공통으로 참조·갱신한다.

**이 문서가 하지 않는 것**: 각 위험의 실제 보호 장치 유무를 전수 조사하지 않는다. 오늘 세션 중 이미 코드/라이브 DB로 직접 확인된 사실만 "Existing protection" 컬럼에 반영하고, 나머지는 전부 `Unknown`으로 표시한다 — **Workpacket 1부터 순서대로 각 Risk ID를 실제 조사해 이 컬럼을 채워나가는 것이 후속 작업의 목적**이다. `Unknown`은 "보호 장치가 없다"는 뜻이 아니라 "아직 확인하지 않았다"는 뜻이며, 반대로 §6(P3)이 명시하듯 "호출자 0건"이 곧 안전을 뜻하지도 않는다.

## §2 Risk ID 명명 규칙

`[도메인]-CON-[번호]` — `PAY`(결제), `ORD`(주문), `KDS`(주방), `WAIT`(대기열), `MBR`(멤버십), `INV`(재고), `DID`(디스플레이 단말).

## §3 🔴 P0 (10개)

| Risk ID | 함수/테이블 | Race type | Trigger | Damage |
|---|---|---|---|---|
| PAY-CON-001 | `confirm_payment()`(`0098`) | 이중 실행(Double Submission) | 동일 결제 확인 요청이 네트워크 재시도/이중 클릭 등으로 2회 이상 도달 | 결제 원장 중복 생성, 금액 이중 청구 위험 |
| PAY-CON-002 | `resolve_or_create_payment_intent()`(`0158`) | SELECT-then-INSERT 레이스 | 동일 주문에 대해 두 요청이 거의 동시에 intent 조회→생성 흐름을 탐 | 하나의 실결제에 intent 중복 생성, `intent_id` 바인딩 불일치 |
| PAY-CON-003 | `payment_ledger`/`confirm_payment()` vs 취소·환불 RPC | 상태 전이 충돌 | 결제 확인 처리 중 동시에 취소/환불 요청 도달 | `ledger_status`가 두 흐름에서 서로 다른 최종값으로 경쟁, 정합성 붕괴 |
| PAY-CON-004 | `payment_ledger.provider_payment_key` | 동일 provider 거래의 다중 주문 바인딩 | 동일 `provider_payment_key`(PG/VAN 거래 식별자)가 서로 다른 두 주문 확인 요청에 동시에 쓰임 | 한 결제가 두 주문에 이중 반영되거나 반대로 유실 |
| PAY-CON-005 | `confirm_payment_from_provider()`(`0027`) / `confirm_payment()`(`0098`) / (미래) `reconcile_payment` | 3개 경로 동시 확정, canonical 미수렴 | 웹훅 경로와 POS/PG 직접 경로가 같은 결제 건을 동시에 확정 시도 | 두 파이프라인이 병렬 존재(`601021_Overview.md` §10 기존 발견)한 채 서로의 존재를 모르고 동시 기록 |
| ORD-CON-001 | `catchmenu_pos.orders` 수정 RPC vs `confirm_payment()` | 주문 수정과 결제 확정 경쟁 | 직원이 주문 금액/항목을 수정하는 동안 결제 승인이 동시에 들어옴 | 승인된 금액과 확정된 주문 금액이 불일치 |
| KDS-CON-001 | KDS 티켓 생성 RPC(`catchmenu_kds.kds_tickets` INSERT 경로) | 동일 `order_item_id`에 대한 티켓 중복 생성 | 주문 생성/재시도 흐름이 같은 항목에 대해 티켓 생성을 두 번 트리거 | 주방에 동일 메뉴가 중복 노출, 이중 조리 |
| PAY-CON-006 | `payment_ledger` 기록 vs `release_kds_after_payment()`/향후 outbox | 이중 생성 | 결제 확정과 KDS 릴리즈/이벤트 발행이 원자적으로 묶이지 않은 상태에서 재시도 발생 | 원장은 1건인데 KDS 릴리즈/알림 이벤트가 중복 발행 |
| KDS-CON-002 | `start_cooking()`(`0029`/`0157`) vs 취소 RPC | 조리 시작과 취소 경쟁 | 조리 시작 승인과 주문 취소가 거의 동시에 같은 티켓에 도달 | 취소된 주문이 조리 시작되거나, 조리 시작된 주문이 취소 처리됨. 관련: `600570` 워크패킷에서 COOKING 상태 취소 시나리오는 의도적으로 1단계 범위에서 제외됨(운영 정책 선결 필요) |
| MBR-CON-001 | `earn_points_after_order` 중복 호출 + `point_balance` 갱신 경쟁(A5+E1 통합) | 중복 적립 + Lost Update | 포인트 적립 RPC 중복 호출과, 잔액 컬럼에 대한 비원자적 읽기-갱신-쓰기가 동시에 발생 | 포인트 중복 적립 또는 동시 갱신 중 한쪽 적립분 유실 |

## §4 🟠 P1 (8개)

| Risk ID | 함수/테이블 | Race type | Trigger | Damage |
|---|---|---|---|---|
| PAY-CON-007 | 쿠폰 사용 RPC | 동시 사용(Double Redemption) | 같은 쿠폰이 두 주문에서 거의 동시에 사용 시도 | 1회용 쿠폰이 2회 이상 적용 |
| WAIT-CON-001 | 대기 순번 발급 RPC | 순번 중복 발급 | 동시 접수 시 순번 채번 로직이 원자적이지 않음 | 두 고객이 동일 대기 순번을 받음 |
| WAIT-CON-002 | 대기 세션 생성 RPC | 같은 고객의 활성 대기 세션 중복 | 같은 고객이 짧은 간격으로 대기 등록을 2회 요청 | 한 고객에 대해 활성 대기 세션이 2개 이상 공존 |
| WAIT-CON-003 | 테이블 배정 RPC | 동시 배정(Double Assignment) | 두 대기 그룹에 같은 테이블이 거의 동시에 배정됨 | 한 테이블에 두 그룹이 겹쳐 배정 |
| KDS-CON-003 | `bulk_commit_kds_tickets()`(`0039`) | 이중 실행 | 동일 주문에 대해 일괄 커밋 RPC가 재시도로 2회 실행 | 이미 COMMITTED된 티켓에 대해 중복 이벤트/감사 기록 생성 |
| KDS-CON-004 | KDS 완료/취소 전이 RPC | 동시 전이 | 완료 처리와 취소 처리가 같은 티켓에 거의 동시에 도달 | 티켓 최종 상태가 처리 순서에 따라 비결정적으로 결정됨 |
| INV-CON-001 | 재고 차감 RPC | 마지막 수량 경쟁(Last-Item Race) | 재고 1개 남은 상품에 대해 두 주문이 동시에 차감 시도 | 재고가 음수가 되거나 두 주문 모두 성공 처리(오버셀) |
| MBR-CON-002 | 스탬프 적립 RPC(`stamp_visit` 등) | 중복 적립 | 같은 방문에 대해 스탬프 적립이 중복 호출됨 | 방문 1회에 스탬프 2개 이상 적립 |

## §5 🟡 P2 (7개)

| Risk ID | 함수/테이블 | Race type | Trigger | Damage |
|---|---|---|---|---|
| WAIT-CON-004 | 고객 호출(call) RPC vs 대기 취소 RPC | 호출과 취소 경쟁 | 직원의 고객 호출과 고객의 대기 취소가 거의 동시에 발생 | 이미 취소된 대기를 호출하거나, 호출 중인 대기가 취소로 사라짐 |
| WAIT-CON-005 | `call_count` 컬럼 갱신 | Lost Update | 여러 직원 단말이 동시에 같은 대기 건의 호출 횟수를 증가시킴 | 호출 횟수 카운트 유실(증가분 일부가 반영 안 됨) |
| KDS-CON-005 | `check_kds_capacity()` | TOCTOU(확인 후 사용 사이 변경) | 용량 확인과 실제 커밋 사이 다른 요청이 용량을 먼저 소진 | 확인 시점엔 여유가 있었으나 실제 커밋 시점엔 초과 |
| DID-CON-001 | DID 디바이스 heartbeat RPC | 동일 단말 동시 heartbeat | 같은 DID 디바이스에서 두 heartbeat 요청이 동시에 도달(네트워크 재시도 등) | 디바이스 상태 갱신이 순서 없이 덮어써짐 |
| DID-CON-002 | DID 상태 이벤트 기록 | 이벤트 순서 역전 | 네트워크 지연으로 나중에 발생한 이벤트가 먼저 도착 | 디스플레이가 과거 상태로 되돌아가 보임 |
| KDS-CON-006 | 관리자 메모/상태 변경 RPC | 동시 편집 충돌 | 두 관리자가 같은 티켓의 메모/상태를 거의 동시에 수정 | 한쪽의 수정이 다른 쪽에 덮어써짐(마지막 쓰기 승리) |
| KDS-CON-007 | 티켓 완료 처리 RPC | 다중 직원 동시 완료 입력 | 여러 직원 단말이 같은 티켓을 거의 동시에 "완료"로 입력 | 완료 이벤트/감사 기록이 중복 생성 |

## §6 ⚪ P3 (비활성, 조건부)

현재 라이브 호출자가 0건이거나 이미 DROP된 함수(`authorize_kds_release()` 등, `601020_authorize_kds_release_overload_and_redesign` 워크패킷에서 DROP 완료)는 이 레지스터의 능동 추적 대상에서 제외한다.

**원칙(재논의 금지 수준으로 명시)**: **"호출자 0건이 안전을 뜻하지 않는다."** 이번 세션 전체에서 반복 확인된 패턴(`start_cooking()`/`bulk_commit_kds_tickets()`/`flush_offline_queue()`의 `RECORD_MANUAL_PAYMENT`/`record_van_transaction()` 모두 한때 또는 현재 호출자 0건이었음에도 실행 시 크래시하거나 동시성 결함을 내포하고 있었음, `601021_Overview.md`/`601026_Verification.md` 참고)과 동일하게, 현재 비활성인 함수도 향후 배선되는 순간 이 레지스터에 등록된 것과 동일한 계열의 동시성 위험에 노출될 수 있다. **어떤 함수든 새로 활성화(배선)하기 전에는 반드시 동시성 테스트를 거쳐야 하며, 이 게이트를 생략할 수 없다.**

## §7 공통 해법 카탈로그

향후 각 워크패킷은 아래 7가지 표준 도구 중에서 위험 유형에 맞는 것을 선택해 참조한다 — 이 카탈로그 자체가 어떤 위험에 어떤 도구를 쓸지 미리 결정하지 않는다.

1. **UNIQUE 제약(UNIQUE Constraint)**: 중복 생성 자체를 DB 레벨에서 원천 차단. 애플리케이션 로직의 실수와 무관하게 강제됨 — 이중 실행/중복 적립류 위험(예: `PAY-CON-001`, `MBR-CON-002`)에 적합.
2. **조건부 원자적 UPDATE(Conditional Atomic UPDATE)**: `UPDATE ... SET ... WHERE 현재상태 = 기대값` 형태로 읽기-확인-쓰기를 한 문장에 압축. 상태 전이 충돌류(`PAY-CON-003`, `KDS-CON-002`, `KDS-CON-004`)에 적합.
3. **원자적 증감(Atomic Increment/Decrement)**: `SET count = count + 1` 형태로 DB 자체가 증감을 원자적으로 처리하게 함. Lost Update류(`MBR-CON-001`의 잔액 갱신, `WAIT-CON-005`)에 적합.
4. **Row Lock(`FOR UPDATE`/`FOR SHARE`)**: 트랜잭션 내에서 대상 행을 명시적으로 잠가 동시 접근을 직렬화. SELECT-then-INSERT/UPDATE류(`PAY-CON-002`)에 적합 — `0142_patch_toss_mvp_payment_intent_binding.sql`의 `bind_toss_payment_intent()` 트리거가 이미 이 패턴을 실사용 중(아래 §9 참고).
5. **Advisory Lock**: 특정 행에 매이지 않는 논리적 잠금(예: `tenant_id+store_id+order_id` 조합 해시). 여러 테이블/함수에 걸친 넓은 범위의 직렬화가 필요할 때(예: `ORD-CON-001`처럼 주문 수정과 결제 확정처럼 서로 다른 RPC 간 경쟁) 적합.
6. **Idempotency Key + DB 제약**: 요청 자체에 멱등키를 부여하고 그 키에 UNIQUE 제약을 걸어 재시도가 안전하게 no-op이 되도록 함. 네트워크 재시도발 이중 실행류(`PAY-CON-001`, `KDS-CON-003`)에 적합.
7. **Version Column(낙관적 잠금, Optimistic Concurrency)**: 행에 버전 번호를 두고 갱신 시 버전 일치를 조건으로 검사, 불일치 시 재시도/거부. 동시 편집 충돌류(`KDS-CON-006`)에 적합.

## §8 하위 워크패킷 로드맵

| Workpacket | 커버 범위 | Risk ID |
|---|---|---|
| Workpacket 1 | 결제 확정 이중 실행/원자성 | `PAY-CON-001`, `PAY-CON-002`, `PAY-CON-004`, `PAY-CON-005` |
| Workpacket 2 | 결제-주문-KDS 상태 전이 경쟁 | `PAY-CON-003`, `PAY-CON-006`, `ORD-CON-001`, `KDS-CON-001`, `KDS-CON-002` |
| Workpacket 3 | 대기열/테이블 배정 동시성 | `WAIT-CON-001`, `WAIT-CON-002`, `WAIT-CON-003`, `WAIT-CON-004`, `WAIT-CON-005` |
| Workpacket 4 | KDS 벌크/완료/용량 동시성 | `KDS-CON-003`, `KDS-CON-004`, `KDS-CON-005`, `KDS-CON-006`, `KDS-CON-007` |
| Workpacket 5 | 재고/멤버십(포인트·쿠폰·스탬프) 동시성 | `INV-CON-001`, `MBR-CON-001`, `MBR-CON-002`, `PAY-CON-007` |
| Workpacket 6 | DID 단말 동시성 | `DID-CON-001`, `DID-CON-002` |

각 Workpacket은 착수 시 이 문서(`000056`)의 해당 Risk ID 행을 실제 코드/라이브 DB 조사로 갱신하고(`Existing protection`/`Required invariant`/`Recommended control`/`Test status`), 조사 결과를 이 레지스터에 반영해야 한다 — Overview/Logic 별도 워크패킷 문서를 만들되 이 레지스터를 살아있는 마스터로 유지한다.

## §9 오늘 세션 중 확인된 사실 (Existing protection 반영분)

이번 문서 작성 턴에서 직접 재확인한 것만 반영하고, 나머지 전 항목은 `Unknown`이다(§1 원칙).

- **`PAY-CON-002`(`resolve_or_create_payment_intent()`)**: `sql/migrations/0158_confirm_payment_intent_linkage_fix.sql` 전체를 `for update`/`for share`/`advisory` 키워드로 재검색한 결과 **0건** — 신규 헬퍼 함수 자체에는 행 잠금이 전혀 없다. 반면 `0142_patch_toss_mvp_payment_intent_binding.sql`의 `bind_toss_payment_intent()` 트리거는 `for share`(주문 조회)/`for update`(intent 후보 조회)를 이미 사용 중이나, 이 트리거는 `toss_payment_requests` INSERT에만 걸리는 별개 경로이며 `resolve_or_create_payment_intent()`가 이 락 패턴을 상속하지 않는다. **Existing protection: 없음(신규 헬퍼 기준), 참고 가능한 락 패턴은 `0142`에 별도 존재.**
- **`PAY-CON-001`(`confirm_payment()` 이중 실행)**: `0098`(재작성판, `0158`/§3 재검토 대상)의 `p_correlation_id is not null` 분기가 `provider_payment_key`+`provider_type`+`ledger_status='APPROVED'` 조건으로 사전 `SELECT EXISTS` 검사를 수행한다(`600552_Logic.md`가 이미 이 위치를 `provider_tx_id`→`provider_payment_key` 컬럼명 정정 대상으로 다룸). 이는 **완전한 원자적 보호가 아니다** — SELECT와 이후 INSERT 사이에 원자적으로 묶여있지 않다(UNIQUE 제약이 이 조합에 걸려있는지는 이번 문서에서 확인하지 않음, Workpacket 1 대상). **Existing protection: 부분적(사전 SELECT 검사만 존재, TOCTOU 갭 있음, UNIQUE 제약 여부 미확인).**
- **`KDS-CON-002`(`start_cooking()`과 취소 경쟁)**: `start_cooking()`(`0029`/`0157`)은 대상 티켓을 `select ... from kds_tickets where id = p_ticket_id ... for update`로 조회한다(이번 세션 `601020` 워크패킷에서 이미 확인). 조리 시작 자체는 행 잠금 하에 진행되나, **취소 RPC가 동일한 락 순서/대상을 획득하는지는 이번 문서에서 확인하지 않았다.** **Existing protection: 부분적(`start_cooking()` 측 `for update`만 확인, 취소 경로는 `Unknown`).**
- 그 외 22개 Risk ID: 전부 `Unknown` — Workpacket 1-6(§8) 착수 시 순서대로 조사한다.

## Module Domain Tags

- DOCUMENTATION_ONLY
- CROSS_DOMAIN(결제/주문/KDS/대기열/재고/멤버십/DID)

## Snapshot Decision

**확정.** §0에서 번호(`000056`, `000055`~`000099` 구간의 유일한 빈 슬롯)를 3가지 방법(디렉토리 조회/`000005`/`000007` 검색)으로 재확인했다. §3-§6에서 지시된 25개 위험 항목(P0 10 + P1 8 + P2 7)을 지시받은 순서·문구 그대로 등록했고, P3 원칙("호출자 0건이 안전을 뜻하지 않는다")을 명시했다. §7 공통 해법 카탈로그와 §8 하위 워크패킷 로드맵을 등록했다. §9에서 오늘 세션 중 실제로 확인된 3개 항목(`PAY-CON-002`/`PAY-CON-001`/`KDS-CON-002`)의 `Existing protection`만 사실대로 채우고 나머지는 `Unknown`으로 남겼다 — 임의로 채우지 않았다. `.sql` 파일은 이번 턴에 생성·수정하지 않았다.
