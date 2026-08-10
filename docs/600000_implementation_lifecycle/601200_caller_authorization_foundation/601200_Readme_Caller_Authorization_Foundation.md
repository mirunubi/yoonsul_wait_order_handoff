# 601200_Readme_Caller_Authorization_Foundation.md

Status: Active
Lifecycle: Readme (폴더 진입점, `000001_Md_Rules.md` §5.4)
Domain: Caller Authorization Foundation
Last Updated: 2026-08-11

## §1 폴더 목적

**RPC 호출자 인가(caller authorization)** 기반 구조를 다루는 워크패킷 모듈이다.

핵심 문제: *"서버가 신뢰 가능한 세션에서 권한을 도출해야지, 클라이언트가 보낸 파라미터를 그대로 믿으면 안 된다"* —
`000701` §47.3의 **0-C 나선**이 해결 대상으로 명시한 공백이며, 본 폴더는 그 선행 파일럿을 담는다.

## §2 폴더 경계 (Semantic Boundary)

### 속하는 것
- 호출자 신원·권한 해석(resolver) 설계와 파일럿
- RPC 경계에서 "누가 호출했는가"를 서버가 판정하는 구조

### 속하지 **않는** 것

| 대상 | 소속 |
|---|---|
| 직원 로그인·세션 발급 자체 | 0-B(Staff identity/session) |
| 테이블 단위 RLS 정책 설계 | 0-C 본 나선 |
| tenant/store 권위 구조(법적 주체·매장 소속) | **0-A** — `601500_operational_authority_foundation/` |

## §3 문서 목록

| 번호 | 문서 | 역할 |
|---|---|---|
| 601200 | **본 Readme** | 폴더 진입점 |
| 601210 | `caller_authorization_resolver_pilot/` | 하위 워크패킷 |
| 601211 | `Overview_Caller_Authorization_Resolver_Pilot.md` | 파일럿 맥락 |
| 601212 | `Logic_Caller_Authorization_Resolver_Pilot.md` | 파일럿 설계 |

> `601211`/`601212`는 `601300_fable_blind_reverse_engineering_audit`의 **Known Prior Finding**으로
> 지정되어 Pass A 블라인드 감사 입력에서 의도적으로 제외된 이력이 있다(`601301` 참조).

## §4 Boundary Reference Documents (`000001_Md_Rules.md` §5.2.1 필수 섹션)

| 문서 경로 | 필요한 이유 |
|---|---|
| `docs/000700_.../000701_Guide_Controlled_AI_Development_Pipeline.md` | §3(13단계 파이프라인), §47.3(0-C 나선 정의 — 이 폴더의 존재 이유), §46/§48 |
| `docs/000001_Md_Rules.md` | 문서 규격 |
| `sql/migrations/0022_create_rls_policies.sql` | `current_tenant_id()`/`current_actor_id()`/`is_service_role()` — 호출자 식별의 현행 메커니즘 |
| `sql/migrations/0021_enable_rls.sql` | RLS 활성화 baseline |
| `supabase/config.toml` | PostgREST 노출 스키마 — 클라이언트 도달 경계 |
| `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601503_Logic_Operational_Authority_Foundation_Ddl.md` **§9** | ⚠️ **0-C 착수 필수 게이트** — `owners`/`legal_entities`/`legal_entity_person_roles`/`legal_entity_representatives`에 접근하는 `SECURITY DEFINER` 함수의 필수 6규칙(소유자/`search_path`/PUBLIC EXECUTE 회수/schema-qualified/tenant 경계 검증) |
| `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601500_Readme_Operational_Authority_Foundation.md` | 0-A가 확정한 권위 구조 — 인가 판정의 대상이 되는 경계 |
| `docs/600000_implementation_lifecycle/600010_Tracker_Spiral_Workpacket_Progress.md` | 나선 진행 순서·0-C 착수 게이트 |

> 새 변경건의 Stage 2가 이 표에 없는 경계 문서를 발견하면 그 Overview 작성과 동시에 여기에도 추가한다.
