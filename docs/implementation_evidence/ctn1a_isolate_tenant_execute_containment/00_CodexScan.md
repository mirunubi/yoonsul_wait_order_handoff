Stage 1 raw scan — Codex, 2026-09-22. 원문 보존본. 구속력 없음
# raw scope/inventory report — Codex, Stage 1 공식 Scan, CTN-1a

**중단 2회 · 각 원인 · 조치(A 유형)**

| 중단 | 원인 | 원 오류 | 수정 | 결과 |
|---|---|---|---|---|
| 1 | RLS 조회에서 `pol.polcmd`의 내부 타입 `"char"`를 `text`와 `||` 연결 | `42725: operator is not unique: text \|\| "char"` | `pol.polcmd::text`로 명시 변환 | 대상 6테이블의 RLS·policy 조회 성공 |
| 2 | 호출 그래프 조회에서 별칭 정렬 참조와 정규식 이스케이프를 잘못 작성 | 1차 `42703: column "caller" does not exist`; 별칭 수정 후 `0 rows` | 결과를 CTE로 감싸고, 함수명 비교를 `proname` 기준으로 바꾸며 정규식을 `E'\\m'`, `E'\\s*\\('`로 수정 | 호출 관계 10행 확인 |

추가로 중단 없이 수정한 A 유형 명령 오류:

- `rg -E`를 정규식 옵션으로 잘못 사용했다. `-E`는 encoding 옵션이므로 `rg -n -i -e "antigravity" -e "안티" ...` 형태로 수정했다.
- 앱 파일 경로를 `core/config`, `features/waiting/presentation`으로 잘못 지정했다. `rg --files`로 실제 경로 `core/constants`, `features/waiting/screens`를 확인한 뒤 재실행했다.

읽은 체제 문서:

- [000001_Md_Rules.md](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/000001_Md_Rules.md:7) §1·§5·§5.4
- [000002_Naming_Rules.md](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/000002_Naming_Rules.md:20) §1.1·§1.2
- [000015_Korean_Document_And_Encoding_Safety_Rules.md](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/000015_Korean_Document_And_Encoding_Safety_Rules.md:38)
- [000701_Guide_Controlled_AI_Development_Pipeline.md](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md:690) §3·§6.5·§8.1~§8.4·§14.5·§37·§42·§43·§44·§46

현재 작업은 파일 생성·수정 없이 Eyes Only로 수행했다. `catchmenu_*` 함수 호출, `SET ROLE`, DB 쓰기, git write는 모두 0건이다.

## Change ID

**미부여 — `CTN-1a` 임시 식별자만 사용.**

`000701` §8.4에 따른 Stage 1 raw inventory이며, CHANGE_ID·워크패킷 번호·migration 번호는 Stage 2 이후 소관이다.

## Change Summary

확인 대상은 다음 두 `SECURITY DEFINER` 함수의 EXECUTE ACL이다.

- `catchmenu_common.isolate_tenant(uuid,text,boolean,uuid,text)`
- `catchmenu_common.detect_threat(text,integer,text,text,jsonb,uuid,uuid,uuid,text,text)`

[601505 §4.1.1](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601505_ChangeContract_Operational_Authority_Foundation_Ddl.md:306)은 `isolate_tenant()`를 0-A-2 완료 전까지 직접·간접·관리자·배치·수동 SQL·테스트를 포함한 모든 경로에서 호출 금지한다.

```text
311: 이 함수는 0-A-2 완료 전까지 어떤 경로로도 호출되어서는 안 된다.
313~314: RPC 직접 호출, 다른 함수를 통한 간접 호출, 관리자 화면,
         배치, 수동 SQL, 테스트 스크립트 전부를 포함한다.
```

같은 문서 §4.1.2는 알려진 세 간접 호출이 잘못된 `p_reason` 인자 때문에 `42883`로 멈추지만, 이를 “우연한 방벽”으로 기록한다([L351~367](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601505_ChangeContract_Operational_Authority_Foundation_Ddl.md:351)).

Human이 이번 CTN-1a에 허용한 범위는 두 함수에서 `PUBLIC`·`anon`·`authenticated` EXECUTE를 회수하는 좁은 containment다. 함수 본문·signature·`p_reason`·wrapper·새 authority model·service-role grant·간접 경로 복구·0-A-2/0-C 재개방은 범위 밖이다.

## Candidate Affected Files

| 구분 | 경로 | 관측 |
|---|---|---|
| 최초 정의 | [0090_create_multitenant_isolation_rpc.sql](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0090_create_multitenant_isolation_rpc.sql:1256) | `isolate_tenant` 정의와 초기 ACL |
| 최초 정의 | [0121_create_security_pipeline.sql](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0121_create_security_pipeline.sql:762) | `detect_threat` 정의와 초기 ACL |
| 직접 호출자 | [0112_create_hq_admin_rpc.sql](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0112_create_hq_admin_rpc.sql:600) | `manage_subscription`의 두 호출 |
| 직접·간접 호출자 | [0121_create_security_pipeline.sql](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0121_create_security_pipeline.sql:628) | `verify_security_token`, `gateway_audit_entry`, `detect_threat` |
| 직접 호출자 | [0130_create_van_handler_extension.sql](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0130_create_van_handler_extension.sql:335) | `record_van_transaction → detect_threat` |
| 직접 호출자 | [0131_create_advanced_staff_permission.sql](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/0131_create_advanced_staff_permission.sql:462) | `check_staff_permission → detect_threat` |
| prototype | `sql/migrations/0179_ctn1a_revoke_isolate_tenant_execute.sql` | untracked·현재 DB 적용됨·정규 Stage 8/9 증거 제외 |
| prototype evidence | `.../601513_Evidence_Containment_Isolate_Tenant_Execute_Revocation.md` | untracked·비권위 자료 |
| prototype index edits | `docs/000005_Index_Document_Number.md`, `601500_Readme...md` | tracked 파일의 기존 미커밋 수정 |
| 정규 산출물 후보 | `docs/implementation_evidence/<change_id>/...` 및 새 migration | 실제 이름·번호는 미정 |

기존 `0090`·`0121`·호출자 migration을 수정하는 것은 Human 범위와 기존 migration 불변 규칙에 포함되지 않는다. formal migration 파일명과 번호는 **Open Question**이다.

## Direct Dependencies

### 두 함수 정의와 0179 이전 ACL

`isolate_tenant`:

```text
0090 L1256~1272  CREATE OR REPLACE FUNCTION
                 SECURITY DEFINER
                 search_path = common,hq,ledger,audit
0090 L1292~1297  catchmenu_hq.tenants UPDATE
0090 L1448~1455  REVOKE ALL FROM PUBLIC
                 GRANT EXECUTE TO authenticated
```

따라서 migration 원문으로 도출되는 prototype 이전 ACL은:

- `postgres`: 소유자 권한
- `authenticated`: 명시적 EXECUTE
- `PUBLIC`·`anon`·`service_role`: `0090`의 `REVOKE ALL FROM PUBLIC` 이후 별도 grant 없음

`detect_threat`:

```text
0121 L762~780    CREATE OR REPLACE FUNCTION
                 SECURITY DEFINER
                 search_path = catchmenu_common
0121 L806~842    security_threats INSERT
0121 L872~882    isolate_tenant 호출 — p_reason 사용
0121 L1545~1549  GRANT EXECUTE TO authenticated
```

`0121`에는 prototype 전 `detect_threat`의 `PUBLIC` revoke가 없다. PostgreSQL 함수 기본 ACL과 명시적 grant를 합치면:

- `postgres`: 소유자 권한
- `PUBLIC`: 기본 EXECUTE
- `anon`·`service_role`: PUBLIC을 통한 EXECUTE
- `authenticated`: PUBLIC 및 명시적 EXECUTE

다만 실제 도달에는 schema `USAGE`가 별도로 필요하다. 현재 실측에서는 `authenticated`만 `catchmenu_common` USAGE를 갖고, `anon`·`service_role`은 갖지 않는다.

### 현재 라이브 카탈로그 — prototype 효과 포함

실행:

```sql
SELECT p.oid::regprocedure AS function,
       r.rolname AS owner,
       p.prosecdef,
       p.proconfig,
       md5(p.prosrc) AS prosrc_md5,
       p.proacl
...
```

원출력:

```text
detect_threat(...) | postgres | t | {search_path=catchmenu_common}
                   | 992c78c881be2f23bcac8050b60ad2b7 | {postgres=X/postgres}

isolate_tenant(...)| postgres | t
                   | {"search_path=catchmenu_common, catchmenu_hq,
                      catchmenu_ledger, catchmenu_audit"}
                   | f53ea7f556e89cec883b9ca6b482ca3e | {postgres=X/postgres}
```

`aclexplode`:

```text
isolate_tenant(...) | postgres | EXECUTE | f
detect_threat(...)  | postgres | EXECUTE | f
(2 rows)
```

`has_function_privilege`:

```text
                         anon  authenticated  service_role  postgres
detect_threat              f          f             f          t
isolate_tenant             f          f             f          t
```

schema `USAGE`:

```text
anon          f
authenticated t
postgres      t
service_role  f
```

현재 ACL은 이미 적용된 untracked prototype 0179의 결과이며 formal Stage 8 기대 상태로 사용할 수 없다.

### 라이브 함수 본문

`pg_get_functiondef`를 두 함수에 각각 실행했다.

- `isolate_tenant`: migration의 본문과 같은 `catchmenu_hq.tenants UPDATE`, audit·ledger 기록을 포함한다. caller tenant 또는 caller authority 검사문은 본문에 없다.
- `detect_threat`: `security_threats INSERT`, alert 생성, FATAL일 때 `isolate_tenant(... p_reason := ...)`, sandbox violation 기록을 포함한다. caller tenant 검사문은 본문에 없다.
- 라이브 `md5(prosrc)`는 위 카탈로그 값과 일치한다.

## Indirect Dependencies

수정 재실행한 라이브 `prosrc` 호출 그래프 원출력은 10행이다.

| root | depth | callee | caller |
|---|---:|---|---|
| `detect_threat` | 1 | `detect_threat` | `gateway_audit_entry` |
| `detect_threat` | 1 | `detect_threat` | `verify_security_token` |
| `detect_threat` | 1 | `detect_threat` | `record_van_transaction` |
| `detect_threat` | 1 | `detect_threat` | `check_staff_permission` |
| `isolate_tenant` | 1 | `isolate_tenant` | `detect_threat` |
| `isolate_tenant` | 1 | `isolate_tenant` | `manage_subscription` |
| `isolate_tenant` | 2 | `detect_threat` | `gateway_audit_entry` |
| `isolate_tenant` | 2 | `detect_threat` | `verify_security_token` |
| `isolate_tenant` | 2 | `detect_threat` | `record_van_transaction` |
| `isolate_tenant` | 2 | `detect_threat` | `check_staff_permission` |

migration 원문 검색과 같은 집합이다.

- `manage_subscription → isolate_tenant`: `0112` L600, L616
- `verify_security_token → detect_threat`: `0121` L628, L662, L700
- `gateway_audit_entry → detect_threat`: `0121` L971, L989
- `record_van_transaction → detect_threat`: `0130` L335
- `check_staff_permission → detect_threat`: `0131` L462
- `detect_threat → isolate_tenant`: `0121` L876

`0095`의 대상 이름은 설명·메타데이터 언급이며 호출문이 아니다.

트리거 조회:

```text
 table_schema | table_name | tgname | trigger_def
--------------+------------+--------+-------------
(0 rows)
```

`cron.job` 조회:

```text
 jobid | schedule | command
-------+----------+---------
(0 rows)
```

public wrapper 조회:

```text
 wrapper
---------
(0 rows)
```

## 호출자·노출

앱 전체에서 두 함수 이름의 직접 참조는 없다.

```text
TARGET_REFERENCES: NONE
```

앱은 일반화된 schema RPC 호출기를 갖는다.

- [rpc_caller.dart L171~180](D:/Workspace/Yoonsul_Wait_Order_Handoff/catchmenu_app/lib/core/supabase/rpc_caller.dart:171): public이면 `_client.rpc`, 그 외에는 `_client.schema(schema).rpc`
- [app_constants.dart L37~47](D:/Workspace/Yoonsul_Wait_Order_Handoff/catchmenu_app/lib/core/constants/app_constants.dart:37): `catchmenu_common`을 포함한 public·pos·store·payment·common·kds·dev schema 상수
- [waiting_register_screen.dart L62~75](D:/Workspace/Yoonsul_Wait_Order_Handoff/catchmenu_app/lib/features/waiting/screens/waiting_register_screen.dart:62): store schema 호출
- 같은 파일 [L100~110](D:/Workspace/Yoonsul_Wait_Order_Handoff/catchmenu_app/lib/features/waiting/screens/waiting_register_screen.dart:100): pos schema 호출

로컬 [supabase/config.toml L7~15](D:/Workspace/Yoonsul_Wait_Order_Handoff/supabase/config.toml:7):

```toml
[api]
enabled = true
port = 54321
schemas = ["public", "graphql_public"]
extra_search_path = ["public", "extensions"]
```

따라서 로컬 config에는 `catchmenu_common` API 노출이 없다. cloud exposed-schema 설정은 저장소에서 확인되지 않았다.

## Database Tables

| 경로 | 직접 또는 간접 대상 |
|---|---|
| `isolate_tenant` | `catchmenu_hq.tenants` UPDATE |
| `isolate_tenant` | `catchmenu_common.security_audit_log` INSERT |
| `isolate_tenant` | `catchmenu_audit.append_audit_record` 호출 → audit record |
| `isolate_tenant` | `catchmenu_ledger.events` INSERT |
| `detect_threat` | `catchmenu_common.security_threats` INSERT |
| `detect_threat` | `catchmenu_common.create_operation_alert` 호출 → operation alert |
| `detect_threat` | `catchmenu_common.sandbox_violations` INSERT |
| `detect_threat` | FATAL 경로에서 위 `isolate_tenant` 대상 전부 |

## Migrations

- 최초 정의: `0090`, `0121`
- 호출자: `0112`, `0121`, `0130`, `0131`
- 이후 정규 migration에서 대상 함수의 재정의·ACL 변경: **없음**
- 현재 working tree prototype: `0179_ctn1a_revoke_isolate_tenant_execute.sql`
- prototype DB history:

```text
filename   0179_ctn1a_revoke_isolate_tenant_execute.sql
checksum   73c2e6b1ea5a2bfaa79b5a6929bff3ae345706c2a579b076102edee44a99a39c
success    t
applied_at 2026-09-21 11:15:56.588353+00
error      NULL
```

파일 SHA-256도 같은 값이다.

DB 환경:

```text
db_name=postgres
server_version=17.6
transaction_read_only=on
container=supabase_db_yoonsul_wait_order_handoff
```

## RLS Policies

수정된 RLS 조회 원출력:

| 테이블 | RLS | FORCE | policy |
|---|---:|---:|---|
| `catchmenu_common.operation_alerts` | t | t | `operation_alerts_isolation`, ALL, tenant=current tenant |
| `catchmenu_common.sandbox_violations` | t | t | `sandbox_violations_hq`, SELECT, `true` |
| `catchmenu_common.security_audit_log` | t | t | `security_audit_isolation`, ALL, tenant=current tenant |
| `catchmenu_common.security_threats` | t | t | `threats_hq_read`, SELECT, tenant NULL 또는 current tenant |
| `catchmenu_hq.tenants` | t | t | `tenants_select_own`, SELECT, id=current tenant |
| `catchmenu_ledger.events` | t | t | store SELECT/INSERT, tenant+store current context |

이 목록은 live policy inventory다. 두 함수는 `SECURITY DEFINER`이며, 함수 본문 자체에는 caller tenant 판정이 없다.

## Tests Found

- `tests`
- `catchmenu_app/test`

두 디렉터리에서 대상 함수명 검색 결과:

```text
TARGET_TEST_REFERENCES: NONE
```

별도 대상 테스트: **없음**.

비권위 prototype 자료의 테스트·판정은 formal Stage 9 증거로 승계하지 않는다.

## Tests Missing

다음은 파일 존재 여부 관점의 공백이다.

- 두 함수의 역할별 EXECUTE ACL을 검사하는 정규 테스트 파일: 없음
- prototype 전 clean 0178 baseline에서 ACL 회수를 재현하는 정규 검증: 없음
- cloud exposed-schema와 결합한 API 도달성 검증: 없음
- 상위 `SECURITY DEFINER` 호출자의 간접 실행 영향 검증: 없음

구체 테스트 설계와 기대값은 Stage 5/6 소관이다.

## Provider / POS / PG / VAN / Bank / Payout Impact

직접 결제·정산·은행·payout 객체 변경은 검색되지 않았다.

간접 호출자 중 `catchmenu_payment.record_van_transaction`이 `detect_threat`를 호출한다. 함수 호출 금지 대상이므로 이번 Stage 1에서는 실행하지 않았다.

## Audit Ledger / Evidence Impact

`isolate_tenant` 본문은 성공 시 다음을 기록한다.

- `security_audit_log`
- `catchmenu_audit.append_audit_record`
- `catchmenu_ledger.events`

ACL 회수는 이 함수의 직접 진입 가능 주체를 바꾸므로 위 감사·ledger 생산 경로의 도달성에 영향 후보가 있다. 본문과 기록 schema 자체는 Human 범위 밖이다.

## Monitoring / Alert Impact

`detect_threat`는:

- `security_threats` 기록
- CRITICAL/FATAL이면 `create_operation_alert`
- 지정된 위협이면 `sandbox_violations`
- FATAL이면 `isolate_tenant`

을 수행한다. ACL 회수는 이 monitoring/containment entry point의 직접 도달성에 영향을 준다. cron·trigger 기반 참조는 각각 0건이다.

## Related Documentation References

| 문서 | 원문 관측 |
|---|---|
| [601505 §4.1.1](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601505_ChangeContract_Operational_Authority_Foundation_Ddl.md:306) | 모든 경로의 `isolate_tenant` 호출 금지 |
| [601505 §4.3](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601505_ChangeContract_Operational_Authority_Foundation_Ddl.md:379) | 0-A-2 전 ACTIVE 승격 금지 |
| [601505 §4.4](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601505_ChangeContract_Operational_Authority_Foundation_Ddl.md:394) | 함수·ACL 변경을 0-C로 이월한 기존 금지 |
| [601505 §8A.2](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601505_ChangeContract_Operational_Authority_Foundation_Ddl.md:830) | 금지 해제는 0-A-2 검증+별도 Human 판단 |
| [601902 §0.3](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md:54) | `CONTRACT FROZEN`, implementation은 0-C로 이월 |
| [601902 §5](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601902_Register_Stage1_Business_Rules.md:1075) | role ID·EXECUTE ACL·판정 위치를 정하지 않음 |
| [600020 §1.1~§1.3](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/600020_Governance_Implementation_Lifecycle_Authority_Reset.md:19) | 601500 권위 보류, 600000 대역 non-authoritative by default |
| [600020 §4](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/600020_Governance_Implementation_Lifecycle_Authority_Reset.md:190) | provenance·order·validation·gate 4요건 |
| [600023 §2](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/600023_Governance_Runtime_Gate_Spiral.md:61) | runtime 결함과 정책 절차 분리 |
| [600023 §4](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/600023_Governance_Runtime_Gate_Spiral.md:205) | `601505` 호출 금지 유지, G15 충돌 미해소 |
| [010004 §7](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md:221) | `DENY_UNLESS_CONTEXT_MATCHES`, containment/suspension block, fail closed |
| [000221 §4.1](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/000100_project_foundation/000221_Guide_Post_0A_Spiral_Sequence.md:202) | `601505` 호출 금지가 0-A-2 완료까지 계속 유효 |
| [602000 §5](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/602000_runtime_gate/602000_Readme_Runtime_Gate.md:176) | RG-F2 G15 충돌, RG-F15 latent ownership gate |
| [601920 L67·L105](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601920_Evidence_Security_Definer_Inventory.md:67) | 두 함수의 별도 SECURITY DEFINER inventory, `NOT VERIFIED` 표시 |
| [601801 L653~712](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/601800_tenant_lifecycle_rpc_alignment/601801_Register_Stage1_Business_Rules.md:653) | 자동·Human 발동 class를 적지만 ACL은 0-C, `detect_threat` 자체를 승인하지 않음. 단 601800 대역은 권위 보류 |

`601500_Readme`의 지시서상 “142행”은 현재 working tree에서 prototype 행 삽입으로 한 행 밀려 [143행](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601500_Readme_Operational_Authority_Foundation.md:143)이다.

```text
0090/0112/0121/0130/0131 | isolate_tenant() 도달 경로 7개 함수
```

## Related SOP / Policy / Matrix / Checklist References

- Policy: `010004` §7
- Governance: `600020`, `600023`, `000701`
- Guide: `000221`
- ChangeContract: `601505`
- target 함수명을 직접 다루는 별도 SOP: **없음**
- target 함수명을 직접 다루는 별도 Matrix·Checklist: **없음**

## Master / Domain Index References

후보 위치:

- [000000_Readme_Root.md](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/000000_Readme_Root.md)
- [000005_Index_Document_Number.md](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/000005_Index_Document_Number.md)
- [000007_Map_Full_Directory.md](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/000007_Map_Full_Directory.md)
- [601500_Readme_Operational_Authority_Foundation.md](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601500_Readme_Operational_Authority_Foundation.md)
- [601900_Readme_Tenant_Isolation_Axis_V2.md](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601900_Readme_Tenant_Isolation_Axis_V2.md)
- [602000_Readme_Runtime_Gate.md](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/602000_runtime_gate/602000_Readme_Runtime_Gate.md)
- [sql/migrations/CHANGELOG.md](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/CHANGELOG.md:167)

## Risk Notes

- prototype 적용 전에는 `authenticated`가 두 함수의 EXECUTE를 가졌다.
- `detect_threat`는 PUBLIC 기본 EXECUTE도 유지했다.
- 두 함수는 `SECURITY DEFINER`이고 본문에 caller tenant/authority gate가 없다.
- 간접 경로가 현재 `p_reason` 오류로 막힌 것은 정책적 ACL gate가 아니다.
- 현재 DB는 prototype 0179가 적용되어 formal clean baseline이 아니다.
- local config는 `catchmenu_common`을 노출하지 않지만 cloud 노출 설정은 미확인이다.
- `apply_migrations.py`는 같은 working tree의 untracked 0179도 대상으로 선택한다.
- 현재 tracked 문서 두 개와 untracked prototype 파일들이 함께 존재한다.
- `000701`의 Antigravity 규칙이 최신 Human 운영 결정과 동기화되지 않았다.

## Uncertainties

- cloud PostgREST exposed schemas
- formal CHANGE_ID·workpacket 번호
- formal migration 번호·파일명
- clean 0178 baseline 구축 방법
- prototype 0179의 보존·격리·삭제 방법
- 정규 Stage 9에서 사용할 clean environment
- G15가 요구하는 ChangeContract와 이번 Full-tier 산출물의 연결 방식
- 상위 `SECURITY DEFINER` 간접 경로가 ACL 회수 후 어떤 정규 기대값을 가져야 하는지
- 현재 Human의 좁은 exception을 어떤 영구 권위 문서에 기록할지

# [3] Antigravity 제외 기록 위치

## 전역 제외·종료·중단 기록

`docs` 전체를 tracked 여부와 무관하게 `rg`로 검색했다.

```powershell
rg -n -i `
  -e "(antigravity|안티).*(제외|종료|중단)" `
  -e "(제외|종료|중단).*(antigravity|안티)" docs
```

**2026-09-22 전역 제외 결정 기록: `NOT_FOUND`.**

검색된 “안티 배제” 문장은 특정 워크패킷의 검증자 구성이다.

- `601034_ChangeContract...md:289`
- `601422_Slice_Input_Package...md:9782`
- `601430_Core_Payload_MD_Bundle...md:9431`

세 위치는 같은 “Cursor+Claude Code(안티 배제...)” 문맥이며 모든 Stage에서 제외한다는 전역 결정 기록이 아니다.

## `000701`에 남은 병행 기본값

[000701](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md)에서 확인된 병행·observer 규정:

- L43: Antigravity non-binding parallel role
- L66: non-authoritative observer-tier participant
- L95: Stage 1·4·6·9 parallel participant
- L118: Stage 1 병행
- L141~142: Stage 4 Normal/Critical 병행
- L155~156: Stage 6 Normal/Critical 병행
- L176~177: Stage 9 Normal/Critical 병행
- L206~208: “1/4/6/9단계 모두 병행 지시가 기본값”
- L249: Stage 1 `Cursor (+ Antigravity)`
- L252: Stage 4 구성
- L254: Stage 6 구성
- L257: Stage 9 구성
- L1096: Stage 4 설명에 non-binding reference
- L1213~1214: Stage 4 Normal/Critical 구성
- L1232: Antigravity 원문 인용 규칙
- L1456~1457: Stage 6 Normal/Critical 구성
- L1471: Stage 6 Antigravity 인용 규칙
- L2153: 검증자 raw 보고서에 Antigravity 포함
- L2668: Stage 1 scan 구성
- L2680: Stage 4 구성
- L2688: Stage 6 구성
- L2699: Stage 9 구성
- L3047~3051: observer period와 최소 1개월 병행
- L3055: “동일한 지시문을 병행 전달하는 것을 표준 절차”
- L3059~3061: 정식 검증자+Antigravity 3결과 비교
- L3063~3070: 관찰 후 Human 분기 전까지 기존 역할 유지
- L3072~3082: Antigravity 표준 지시문과 병행 기본 적용
- L3084~3088: 관찰 사례
- L3147: 참여 불가 시 처리 규정

특히 원문은 여전히 다음과 같다.

```text
3055: Antigravity에게도 동일한 지시문을 병행 전달하는 것을 표준 절차로 한다
3060: Antigravity: 동일 지시문을 병행 전달한다(기본값...)
3082: §40.1의 “3중 검토” 표준 절차에서 ... 기본으로 포함한다
```

따라서 저장소 문면과 이번 Human 운영 결정 사이의 차이는 **Open Question**으로 남는다.

# [4] 산출물 위치·명명 관행

## 최근 워크패킷 3개

| 패킷 | 실제 산출물 형식 | Change ID | Human approval 기록 |
|---|---|---|---|
| `601500_operational_authority_foundation` | `601502_Overview_*`, `601503_Logic_*`, `601504_TestPlan_*`, `601505_ChangeContract_*`, `601506/7_Verification_*`, `601508~511_Audit*`; Module 없음 | `operational_authority_foundation_ddl` — 각 문서 `## Change ID` | `601505` L956 checkbox 공란, L968 Stage 7 대기 |
| `601700_operational_authority_foundation_v2` | `601710_Overview_*`, `601713_Logic_*`, `601716_TestPlan_*`, `601717_ChangeContract_*`, `601722_Module_*`, `601740/3_Verification*`, 다수 Audit | ChangeContract L41~47의 `Workpacket 601700` 블록 | `601717` L1640 `APPROVED_FOR_IMPLEMENTATION — 정영석, 2026-08-23` |
| `601800_tenant_lifecycle_rpc_alignment` | `601809_Overview_*`, `601810_Logic_*`, `601811_TestPlan_*`, `601812_ChangeContract_*`, `601813~815_Audit_*`; Module·Verification 없음 | 별도 `## Change ID` 표기는 검색되지 않음 | `601812` L462 `NOT EFFECTIVE — 승인 기록 없음` |

현재 [000001 §5.4.2](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/000001_Md_Rules.md:162)는 Stage 1~6 진행 중 위치를 다음처럼 규정한다.

```text
docs/implementation_evidence/<change_id>/<DocumentType>.md
```

`docs/implementation_evidence/`는 존재한다.

- `601700/raw_logs/01~15`
- `order_sessions_customer_id_fk_and_guest_promotion/DesignPack.md`
- 같은 폴더 `TestAndContract.md`

`DesignPack.md` L3은 `CHANGE_ID`를 기록한다. `TestAndContract.md` L97은 `Human Boundary Approval (pending)`을 기록한다.

## G15 ChangeContract 탐색 규칙

[Check-Governance.ps1 L951~967](D:/Workspace/Yoonsul_Wait_Order_Handoff/tools/Check-Governance.ps1:951):

1. workpacket 6자리로 시작하는 폴더를 찾는다.
2. 그 아래 첫 `*ChangeContract*.md`를 사용한다.
3. 없으면 파일명에 workpacket 번호가 든 `*ChangeContract*.md`를 fallback으로 찾는다.

migration 연결은 [L970~991](D:/Workspace/Yoonsul_Wait_Order_Handoff/tools/Check-Governance.ps1:970):

- migration 첫 5줄에서 `Workpacket: NNNNNN` 또는 한글 동등 표기를 읽는다.
- ChangeContract가 없으면 `CONTRACT_NOT_FOUND`.

승인 판독은 [L913~948](D:/Workspace/Yoonsul_Wait_Order_Handoff/tools/Check-Governance.ps1:913):

- `| Stage 7 ... | APPROVED ... |`
- `Decision: [x] APPROVE`
- `APPROVED (YYYY-MM-DD)`

중 하나를 인식한다.

관측상 G15 연결에는 migration 첫 5줄의 6자리 Workpacket 값과, 해당 번호로 찾을 수 있는 ChangeContract가 필요하다. 실제 번호·경로 선정은 Stage 2 이후 소관이다.

# [5] clean 0178 baseline 구축 수단

## `tools/apply_migrations.py`

[코드 L1~8](D:/Workspace/Yoonsul_Wait_Order_Handoff/tools/apply_migrations.py:1):

- sequence 순서 적용
- 성공 history checksum 검증 후 skip
- 최초 SQL 실패 또는 checksum mismatch에서 중단

고정 대상([L18~22](D:/Workspace/Yoonsul_Wait_Order_Handoff/tools/apply_migrations.py:18)):

```text
sql/migrations
container supabase_db_yoonsul_wait_order_handoff
user postgres
database postgres
```

선정 규칙([L87~102](D:/Workspace/Yoonsul_Wait_Order_Handoff/tools/apply_migrations.py:87)):

```text
sql/migrations/*.sql
^(\d{4})_.+\.sql$
sequence number 정렬
checksum = raw bytes의 CRLF를 LF로 바꾼 뒤 SHA-256
```

적용 규칙([L175~236](D:/Workspace/Yoonsul_Wait_Order_Handoff/tools/apply_migrations.py:175)):

- 성공 history의 checksum이 같으면 skip
- 다르면 즉시 중단
- 미등록 파일은 `psql`로 실행
- 성공·실패를 `migration_history`에 기록
- 첫 실패 뒤 나머지 미실행

`argparse`, `sys.argv`, `click`, `typer` 사용은 **없음**. 별도 container·DB·upper migration 번호를 지정하는 옵션도 없다.

따라서 같은 working tree의 untracked `0179_*.sql`도:

- `sql/migrations` 바로 아래에 있고
- `NNNN_name.sql` 패턴을 만족하므로
- git tracked 여부와 관계없이 대상이 된다.

현재 tree에서 `apply_migrations.py`를 그대로 사용하면 clean 0178 baseline이 되지 않는다.

## replay 선례

legacy [604278 §4](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/990000_legacy_quarantine/604000_workpackets/604270_cross_scope_local_migration_replay_baseline_blockers/604278_Verification_Cross_Scope_Local_Migration_Replay_Baseline_Blockers.md:57):

```text
1. docker cp sql/migrations/. → container:/tmp/catchmenu_migrations
2. dropdb --if-exists catchmenu_local_verify_604278
3. createdb catchmenu_local_verify_604278
4. 파일명 순서로 0142까지 적용
```

같은 컨테이너 안의 별도 DB를 쓴 선례다. 별도 DB container 선례는 검색되지 않았다.

그 replay는 [L71~85](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/990000_legacy_quarantine/604000_workpackets/604270_cross_scope_local_migration_replay_baseline_blockers/604278_Verification_Cross_Scope_Local_Migration_Replay_Baseline_Blockers.md:71)에서 `0042` 문법 오류로 중단됐다.

[600311 L110~150](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/600000_implementation_lifecycle/600300_cloud_local_migration_sync/600310_initial_cloud_state_audit/600311_Overview.md:110)은 부분 seed·constraint가 이미 있는 cloud replay에서 19개 first-pass 실패가 있었다고 기록한다. 이는 clean local replay 증거가 아니다.

## `0073` 제외

현재 `sql/_excluded_from_local_replay/`에는 `0073_final_verification.sql` 1개만 있다.

[CHANGELOG L167~175](D:/Workspace/Yoonsul_Wait_Order_Handoff/sql/migrations/CHANGELOG.md:167):

```text
0073은 로컬 마이그레이션 재생에서 영구 제외
실제 보관 위치는 sql/_excluded_from_local_replay/
migration_history에는 success=false 1행이 남음
```

이동 commit:

```text
525c3aca6d60935a1adede298c11fcc534caafb4
2026-08-07 14:04:46 +0900
chore: exclude 0073_final_verification.sql from repo-tracked migrations directory
```

## worktree·container 선례 및 충돌 후보

- `git worktree`, `worktree add`, 별도 worktree 절차: **NOT_FOUND**
- 별도 DB container replay 선례: **NOT_FOUND**
- 같은 container의 별도 DB replay: 있음
- compose YAML: **NOT_FOUND**
- `supabase/config.toml` 고정값:
  - `project_id = "yoonsul_wait_order_handoff"`
  - API `54321`
  - DB `54322`
  - shadow DB `54320`
  - pooler `54329`

같은 설정으로 별도 Supabase stack을 시작할 경우 project/container identity와 포트가 겹칠 후보가 있다. 실제 clean-baseline 방식을 정하는 것은 Open Question이다.

# [6] prototype 현황

HEAD:

```text
78f16c5134d1c0dfabb51216311072dacd43db68
```

최종 `git status --short`:

```text
 M docs/000005_Index_Document_Number.md
 M docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601500_Readme_Operational_Authority_Foundation.md
?? business_day_probe_out.txt
?? docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601513_Evidence_Containment_Isolate_Tenant_Execute_Revocation.md
?? docs/600000_implementation_lifecycle/602000_runtime_gate/602060_Evidence_RuntimeGate_Ownership_Chain_Tenant_Consistency.md
?? sql/migrations/0179_ctn1a_revoke_isolate_tenant_execute.sql
```

| 항목 | 상태 |
|---|---|
| `0179_ctn1a_revoke_isolate_tenant_execute.sql` | untracked, DB에는 success 적용 행 존재 |
| `601513_Evidence_Containment_Isolate_Tenant_Execute_Revocation.md` | untracked |
| `000005_Index_Document_Number.md` | tracked·modified; 601513 색인행 추가 |
| `601500_Readme_Operational_Authority_Foundation.md` | tracked·modified; 601513 행 추가 |
| `602060_Evidence...md` | untracked·이번 CTN-1a 비권위 참조군 |
| `602061_Report...md` | tracked·비권위 참조군 |
| `business_day_probe_out.txt` | untracked·CTN-1a와의 연관 확인 안 됨 |

지시서에 적힌 `601513_Evidence_Ctn1a_Containment_Prototype.md`라는 경로는 실제로 존재하지 않는다. 실제 untracked 파일명은 위 `601513_Evidence_Containment_Isolate_Tenant_Execute_Revocation.md`다.

이 Stage 1 수행으로 추가된 working-tree 변화는 없다.

# [7] Required Context Snapshot Candidates

[000701 §6.5](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md:360)는 Stage 1이 후보만 제시하고 Stage 2가 최소 규칙 집합을 판정하도록 한다. [§42](D:/Workspace/Yoonsul_Wait_Order_Handoff/docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md:3110)는 Overview에 4단 구조를 요구한다.

## Master Anchor 후보

- 이번 지시문의 `HD-CTN-01`~`HD-CTN-04`
- `000701` controlled pipeline
- `600020` authority reset
- `000221` post-0A sequence

## Rule Summaries 후보

- `601500_Readme_Operational_Authority_Foundation.md`
- `601512_Baseline_Summary.md`
- `601900_Readme_Tenant_Isolation_Axis_V2.md`
- `602000_Readme_Runtime_Gate.md`

## Full Rules Required 후보

- `601505` §4.1.1·§4.3·§4.4·§8A.2
- `601902` §0.3·§5
- `010004` §7
- `600023` §2·§4
- `000001` §1·§5·§5.4
- `000002` §1.1·§1.2
- `000015`
- `000701` 관련 Stage·approval·migration 규칙
- `0090`, `0112`, `0121`, `0130`, `0131` 원문
- `tools/apply_migrations.py`
- `tools/Check-Governance.ps1` G15

## Domain Indexes 후보

- `601500_Readme_Operational_Authority_Foundation.md`
- `601900_Readme_Tenant_Isolation_Axis_V2.md`
- `602000_Readme_Runtime_Gate.md`
- `000005_Index_Document_Number.md`
- `000007_Map_Full_Directory.md`
- `sql/migrations/CHANGELOG.md`

## Excluded Rule Families 후보

- `602060`·`602061`·`601513`·prototype `0179` — discovery/prototype 위치 확인용, 최종 설계 권위에서 제외
- `601800` 판정 — authority suspended; historical evidence로만 분류
- payment/KDS/order runtime gates — 이번 두 함수 ACL 범위와 직접 연결되지 않는 부분
- 함수 본문 재설계·`p_reason` 수정·wrapper·새 role/authority model — Human 범위 밖
- 0-A-2·0-C 전체 재개방 — Human 범위 밖

# Open Questions

1. CHANGE_ID와 6자리 workpacket 번호는 무엇인가.
2. 정규 migration 번호와 파일명은 무엇인가.
3. Human의 narrow containment exception을 어느 영구 권위 문서에 기록하는가.
4. Stage 1~6 임시 산출물은 `docs/implementation_evidence/<change_id>/`에 둘 것인지, 최근 601xxx 영구 패킷 선례와 어떻게 연결할 것인가.
5. G15가 찾을 ChangeContract의 workpacket 번호·경로·승인 문면은 무엇인가.
6. clean 0178 baseline은 같은 container의 별도 DB, 별도 container, 별도 checkout 중 어느 방식으로 구축하는가.
7. `apply_migrations.py`가 DB·상한 번호 옵션을 제공하지 않는 상태에서 0178까지만 재현하는 절차는 무엇인가.
8. untracked prototype 0179와 601513을 보존·격리·삭제하는 시점과 방식은 무엇인가.
9. cloud의 exposed schemas에 `catchmenu_common`이 포함되는가.
10. ACL 회수 이후 상위 `SECURITY DEFINER` 호출자의 정규 회귀 기대값은 무엇인가.
11. `detect_threat`의 PUBLIC 기본 EXECUTE가 언제부터 존재했다고 간주할지 별도 ACL-history 검증 문서가 필요한가.
12. `000701`에 남은 Antigravity 병행 기본값을 최신 Human 결정과 언제 동기화하는가.
13. `business_day_probe_out.txt`와 `602060` untracked 상태가 clean checkout 구축 범위에 어떤 영향을 주는가.
14. formal Stage 9 환경은 prototype history가 없는 DB라는 사실을 어떤 증거로 고정하는가.
