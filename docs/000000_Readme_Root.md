# 000000_Readme_Root

Status: Active
Last Updated: 2026-07-10

## 1 이 폴더의 역할

`docs/` 는 `yoonsul_wait_order_handoff` 프로젝트의 개발 문서 루트입니다.

아키텍처, 스펙, 경계 정의, 구현 라이프사이클, 런타임 플로우, 보안/감사, 배포 운영, 향후 확장 문서를 포함합니다.

운영 SOP, 레시피 SOP, 훈련 문서는 `sop/` 폴더에 분리 보관합니다.

- Project name: `yoonsul_wait_order_handoff`
- GitHub repository: `mirunubi/yoonsul_wait_order_handoff`
- Supabase project URL: `https://upzthfwhtvazfftxnyfu.supabase.co`
- 외부 프로젝트(`yoonsul_os`, `yoonsul_franchise_os`)는 참조 전용이며 이 문서 체계에 포함하지 않습니다.

## 2 루트 밴드 (000000~000099)

docs 루트에 직접 위치하는 파일들입니다. 프로젝트 전체 거버넌스, 마이그레이션 배치 기록, 구현 WorkPackage 게이트 문서를 담습니다.

### 2.1 핵심 거버넌스 파일

| 번호 | 파일 | 역할 |
|------|------|------|
| 000000 | Readme_Root | 이 파일. docs 루트 및 하위 폴더 안내 |
| 000001 | Md_Rules | Markdown 작성 규칙, 인코딩, 이동/인덱스 규칙 |
| 000002 | Naming_Rules | 파일명 규칙, DocumentType 기준, 6자리 네임스페이스 |
| ~~000003~~ | ~~Guide_Project_Context~~ | ~~프로젝트 배경, 외부 프로젝트 분리 원칙~~ → **deprecated**, `_migration_history/`로 이동. 내용은 `000010_Guide_Wait_Order_Project.md`에 통합. |
| 000005 | Index_Document_Number | 전체 문서 번호 중앙 등록부 |
| 000007 | Map_Full_Directory | 전체 디렉토리 구조 맵 |
| 000015 | Korean_Document_And_Encoding_Safety_Rules | 한국어 문서 및 인코딩 안전 규칙 |
| 000080 | Governance_CatchMenu_Failure_Error_Code_Naming_And_Diagnostic_Hierarchy | 에러 코드 명명 계층·진단 체계 거버넌스 표준 |
| 000099 | Docs_Governance_Checklist | 문서 거버넌스 점검 체크리스트 |

### 2.2 도메인 문서

루트 배치 허용 도메인 정의 파일.

| 번호 | 파일 | 역할 |
|------|------|------|
| 000010 | Guide_Wait_Order_Project | 프로젝트 전체 소개 및 온보딩 가이드 (000003 대체) |
| 000020 | Policy_Store_Capability_Stage_0_To_5_Module | 매장 역량 Stage 0~5 모듈 정책 |
| 000030 | Boundary_Runtime | 런타임 시스템 경계 정의 |
| 000040 | Runtime_Operation_Patterns_For_KDS_And_Mini | KDS·Mini 런타임 운영 패턴 ⚠️ DocumentType 검토 필요 |
| 000050 | Policy_Deployment_Mode_Model | 배포 모드 모델 정책 |

### 2.3 마이그레이션 배치 기록 (000004~000065)

초기 구조 정비·폴더 통합·6자리 rename·경로 단축·링크 무결성·확장 웨이브 전반의 배치별 계획·매니페스트·보고서.

| 번호 | 파일 | 역할 |
|------|------|------|
| 000004 | Report_Final_Documentation_Structure_Integrity_Audit | 최종 문서 구조 무결성 감사 보고 |
| 000006 | Plan_Top_Level_Folder_Consolidation | 최상위 폴더 통합 계획 |
| 000008 | Report_Docs_Directory_Redesign_v0_2_Audit_And_Move_Plan | docs 디렉토리 재설계 v0.2 감사·이동 계획 보고 |
| 000009 | Report_Root_Governance_Rules_Correction_Readme_Index_And_Overview_Logic_Module_Model | 루트 거버넌스 룰 수정·Readme/Index/모델 구성 보고 |
| 000011 | Report_Six_Digit_Documentation_Numbering_Dry_Run_Manifest | 6자리 문서 번호 체계 드라이런 보고 |
| 000012 | Register_Six_Digit_Rename_Dry_Run_Manifest | 6자리 rename 드라이런 등록 매니페스트 |
| 000013 | Register_Six_Digit_Rename_Anomaly_And_Manual_Review | 6자리 rename 이상·수동 검토 등록 |
| 000014 | Report_Six_Digit_Migration_Batch_1_Root_Governance_Rename | Batch 1 루트 거버넌스 rename 결과 보고 |
| 000016 | Report_Docs_Folder_File_Count_And_Number_Density_Audit | docs 폴더 파일 수·번호 밀도 감사 보고 |
| 000017 | Report_Docs_Six_Digit_Domain_Band_Redesign_v0_4_Plan | docs 6자리 도메인 밴드 재설계 v0.4 계획 보고 |
| 000018 | Matrix_Current_To_Proposed_Domain_Folder_Mapping_v0_4 | 현행→제안 도메인 폴더 매핑 v0.4 |
| 000019 | Report_Batch_3A_High_Range_Implementation_Lifecycle_Planning_Manifest | Batch 3A 고번호대 구현 라이프사이클 계획 보고 |
| 000021 | Report_Batch_3B_High_Range_Implementation_Lifecycle_POS_Gateway_Package_Move | Batch 3B POS Gateway 패키지 이동 보고 |
| 000022 | Report_Batch_3B_1_Implementation_Lifecycle_Long_Path_Mitigation_Manifest | Batch 3B-1 긴 경로 완화 보고 |
| 000023 | Matrix_Batch_3B_1_Long_Path_Mitigation_Rename_Manifest | Batch 3B-1 rename 매니페스트 |
| 000024 | Report_Batch_3B_2_Implementation_Lifecycle_Folder_Shortening | Batch 3B-2 폴더 경로 단축 보고 |
| 000025 | Report_Batch_3C_Runtime_Flow_700000_Planning_Manifest | Batch 3C 런타임 플로우 700000 밴드 계획 보고 |
| 000026 | Matrix_Batch_3C_Runtime_Flow_700000_Move_Manifest | Batch 3C 이동 매니페스트 |
| 000027 | Report_Batch_3D_Runtime_Flow_700000_Move | Batch 3D 런타임 플로우 700000 이동 보고 |
| 000028 | Report_Batch_3D_1_Remaining_Runtime_Flow_Review_Packet_Move | Batch 3D-1 남은 런타임 플로우 검토 패킷 이동 보고 |
| 000029 | Report_Batch_3E_Runtime_Flow_Internal_Folder_Alignment | Batch 3E 런타임 플로우 폴더 내부 정렬 보고 |
| 000031 | Report_Batch_4A_High_Range_File_Basename_Migration_Planning | Batch 4A 고번호대 basename 이동 계획 보고 |
| 000032 | Matrix_Batch_4A_High_Range_File_Basename_Rename_Manifest | Batch 4A rename 매니페스트 |
| 000033 | Report_Batch_4B_High_Range_File_Basename_Rename | Batch 4B basename rename 실행 보고 |
| 000034 | Report_Batch_4C_High_Range_Internal_Link_Integrity_Scan | Batch 4C 내부 링크 무결성 스캔 보고 |
| 000035 | Matrix_Batch_4C_High_Range_Internal_Link_Update_Manifest | Batch 4C 내부 링크 업데이트 매니페스트 |
| 000036 | Report_Batch_4D_High_Range_H1_And_Manual_Review_Closure | Batch 4D H1·수동 검토 종료 보고 |
| 000037 | Matrix_Batch_4D_High_Range_Manual_Review_Closure | Batch 4D 수동 검토 종료 매니페스트 |
| 000038 | Report_Batch_5A_Global_Docs_File_Basename_Migration_Planning | Batch 5A 전역 basename 이동 계획 보고 |
| 000039 | Matrix_Batch_5A_Global_Docs_File_Basename_Rename_Manifest | Batch 5A rename 매니페스트 |
| 000041 | Report_Batch_5C_Low_Density_Domain_File_Basename_Rename | Batch 5C 저밀도 도메인 basename rename 보고 |
| 000042 | Report_Batch_5D_Medium_Density_Domain_File_Basename_Rename | Batch 5D 중밀도 도메인 basename rename 보고 |
| 000043 | Report_Batch_5E_Dense_Domain_File_Basename_Rename | Batch 5E 고밀도 도메인 basename rename 보고 |
| 000044 | Report_Batch_5F_Manual_Review_Exclusion_Closeout_Plan | Batch 5F 수동 검토 제외 종료 계획 |
| 000045 | Matrix_Batch_5F_Manual_Review_Exclusion_Action_Manifest | Batch 5F 액션 매니페스트 |
| 000046 | Report_Batch_5G_Global_Internal_Link_Integrity_Scan | Batch 5G 전역 내부 링크 무결성 스캔 보고 |
| 000047 | Matrix_Batch_5G_Global_Internal_Link_Update_Manifest | Batch 5G 링크 업데이트 매니페스트 |
| 000048 | Report_Batch_5H_Global_H1_And_Six_Digit_Basename_Migration_Closeout | Batch 5H 전역 H1·6자리 basename 종료 보고 |
| 000049 | Matrix_Batch_5H_Global_H1_Mismatch_Closeout | Batch 5H H1 불일치 종료 매니페스트 |
| 000051 | Plan_Batch_6B_Staged_Commit_Execution_And_Post_Commit_Verification | Batch 6B 단계적 커밋 실행·사후 검증 계획 |
| 000052 | Matrix_Batch_6C_Untracked_Legacy_Five_Digit_Cleanup_Approval_Manifest | Batch 6C 미추적 레거시 5자리 정리 승인 매니페스트 |
| 000055 | Matrix_Batch_5F_1_ManualReview_Hold_Files_Resolution_Manifest | Batch 5F-1 수동 검토 홀드 파일 해결 매니페스트 |
| 000057 | Plan_Batch_6F_Root_Migration_Evidence_Disposition_And_Worktree_Noise_Gate | Batch 6F 루트 이동 증거 처리·노이즈 게이트 계획 |
| 000058 | Matrix_Batch_6F_Root_Migration_Evidence_Disposition_Manifest | Batch 6F 루트 이동 증거 처리 매니페스트 |
| 000059 | Plan_Batch_6G_Commit_6F_Manifest_And_Untracked_Migration_Evidence_Disposition | Batch 6G 커밋·미추적 이동 증거 처리 계획 |
| 000060 | Report_Batch_7A_Docs_Number_Band_Density_Gap_Scan | Batch 7A docs 번호 밴드 밀도·갭 스캔 보고 |
| 000061 | Report_Batch_7B_Missing_Number_Band_Expansion_Roadmap | Batch 7B 결측 번호 밴드 확장 로드맵 보고 |
| 000062 | Report_Batch_7M_Post_Expansion_Docs_Count_Reconciliation_And_Final_Gap_Scan | Batch 7M 확장 후 문서 수량 조정·최종 갭 스캔 보고 |
| 000063 | Report_Batch_7O_Expansion_Waves_Staging_Validation_And_Commit_Readiness_Gate | Batch 7O 확장 웨이브 스테이징 검증·커밋 준비 게이트 보고 |
| 000064 | Report_Batch_7Q_Post_Commit_Recount_And_2300_Plus_Docs_Milestone_Closeout | Batch 7Q 커밋 후 재집계·2300+ docs 마일스톤 종료 보고 |
| 000065 | Report_Batch_7R_Untracked_Migration_And_Leftover_Docs_Disposition_Review | Batch 7R 미추적 이동·남은 문서 처리 검토 보고 |

### 2.4 WorkPackage 게이트 파일 (000066~000098)

WP 8A-001(코드베이스 수화 기반), WP 9A-001(수화 레지스트리 스키마 검증), WP 9B-001(소스-모듈 맵 정적 검증) 3개 WorkPackage 게이트 아티팩트.

| 번호 | 파일 | 역할 |
|------|------|------|
| 000066 | Report_Batch_8A_Development_Entry_Candidate_WorkPackage_Selection | Batch 8A 개발 진입 WP 후보 선정 보고 |
| 000067 | Overview_WP_8A_001_Read_Only_Codebase_Hydration_Foundation_And_Source_To_Module_Mapping | WP 8A-001 읽기 전용 코드베이스 수화·소스-모듈 매핑 Overview |
| 000068 | Matrix_WP_8A_001_Dependency_Graph_And_Source_To_Module_Map | WP 8A-001 의존성 그래프·소스-모듈 맵 |
| 000069 | Diagram_WP_8A_001_Runtime_Flow_Read_Only_Hydration_Diagram | WP 8A-001 런타임 플로우 읽기 전용 수화 다이어그램 |
| 000070 | Matrix_WP_8A_001_Module_Impact_Map | WP 8A-001 모듈 영향 맵 |
| 000071 | Matrix_WP_8A_001_Test_Coverage_Map | WP 8A-001 테스트 커버리지 맵 |
| 000072 | Plan_WP_8A_001_Pre_Implementation_Test_Plan | WP 8A-001 구현 전 테스트 계획 |
| 000073 | Checklist_WP_8A_001_Code_Handoff_Readiness_Checklist | WP 8A-001 코드 핸드오프 준비 체크리스트 |
| 000074 | Report_Batch_8B_Read_Only_Hydration_Foundation_WorkPackage_Artifact_Pack_Closeout | Batch 8B WP 8A-001 아티팩트 팩 종료 보고 |
| 000075 | Report_WP_8A_001_Read_Only_Repository_Hydration_Evidence_Capture | WP 8A-001 읽기 전용 저장소 수화 증거 포획 보고 |
| 000076 | Matrix_WP_8A_001_Source_File_Inventory_By_Module_And_Extension | WP 8A-001 소스 파일 인벤토리 (모듈·확장자별) |
| 000077 | Matrix_WP_8A_001_Allowed_And_Forbidden_File_Boundary_Map | WP 8A-001 허용·금지 파일 경계 맵 |
| 000078 | Report_Batch_8C_Read_Only_Repository_Hydration_Execution_Closeout | Batch 8C 읽기 전용 저장소 수화 실행 종료 보고 |
| 000079 | Report_Batch_8D_Read_Only_Hydration_Review_And_First_Implementation_Gate_Decision | Batch 8D 읽기 전용 수화 검토·첫 번째 구현 게이트 결정 보고 |
| 000081 | Report_Batch_8F_First_Skeleton_Creation_Authorization_Packet | Batch 8F 첫 스켈레톤 생성 인가 패킷 보고 |
| 000082 | Report_Batch_8H_Neutral_Skeleton_Validation_And_Commit_Readiness_Gate | Batch 8H 중립 스켈레톤 검증·커밋 준비 게이트 보고 |
| 000083 | Report_Batch_8J_Post_Commit_Verification_And_WP_8A_001_Closeout | Batch 8J 커밋 후 검증·WP 8A-001 종료 보고 |
| 000084 | Report_Batch_8K_Directory_Only_Tree_Disposition_Review | Batch 8K 디렉토리 전용 트리 처리 검토 보고 |
| 000085 | Report_Batch_9A_Next_WorkPackage_Candidate_Selection | Batch 9A 다음 WP 후보 선정 보고 |
| 000086 | Overview_WP_9A_001_Hydration_Registry_Schema_Validation_And_Static_Evidence_Gate | WP 9A-001 수화 레지스트리 스키마 검증·정적 증거 게이트 Overview |
| 000087 | Logic_WP_9A_001_Hydration_Registry_Schema_Validation_Rules_And_Evidence_Gate | WP 9A-001 스키마 검증 규칙·증거 게이트 Logic |
| 000088 | Plan_WP_9A_001_Hydration_Registry_Schema_Validation_Test_Plan | WP 9A-001 스키마 검증 테스트 계획 |
| 000089 | Matrix_WP_9A_001_HR_001_To_HR_009_Validation_Case_Coverage_Map | WP 9A-001 HR-001~HR-009 검증 케이스 커버리지 맵 |
| 000090 | Checklist_WP_9A_001_Hydration_Registry_Static_Evidence_Gate_Readiness_Checklist | WP 9A-001 정적 증거 게이트 준비 체크리스트 |
| 000091 | Report_Batch_9B_WP_9A_001_Artifact_Pack_Closeout | Batch 9B WP 9A-001 아티팩트 팩 종료 보고 |
| 000092 | Evidence_WP_9A_001_HR_001_To_HR_009_Static_Validation_Result_Packet | WP 9A-001 HR-001~HR-009 정적 검증 결과 증거 패킷 |
| 000093 | Matrix_WP_9A_001_Hydration_Registry_Static_Validation_Findings_Map | WP 9A-001 수화 레지스트리 정적 검증 소견 맵 |
| 000094 | Report_Batch_9D_WP_9A_001_Static_Validation_Execution_Closeout | Batch 9D WP 9A-001 정적 검증 실행 종료 보고 |
| 000095 | Overview_WP_9B_001_Source_Module_Map_Static_Validation_And_Evidence_Gate | WP 9B-001 소스-모듈 맵 정적 검증·증거 게이트 Overview |
| 000096 | Logic_WP_9B_001_Source_Module_Map_Static_Validation_Rules_And_Boundary_Checks | WP 9B-001 소스-모듈 맵 정적 검증 규칙·경계 체크 Logic |
| 000097 | Plan_WP_9B_001_Source_Module_Map_Static_Validation_Test_Plan | WP 9B-001 소스-모듈 맵 정적 검증 테스트 계획 |
| 000098 | Matrix_WP_9B_001_SMM_001_To_SMM_009_Validation_Case_Coverage_Map | WP 9B-001 SMM-001~SMM-009 검증 케이스 커버리지 맵 |

## 3 하위 폴더

### 000100_project_foundation
프로젝트 기반 정의. 프로젝트 정체성, BM 특허 경계, 핵심 개념, 외부 시스템 분리 원칙.

### 000700_ai_agent_prelearning_and_project_context
AI 에이전트 선행학습 및 프로젝트 컨텍스트. 에이전트가 작업 전 숙지해야 할 프로젝트 구조, 규칙, 맥락 문서.

### 000800_pos_gateway_and_provider_integration_foundation
POS 게이트웨이 및 프로바이더 통합 내부 기반. 아웃소싱/구현 이전 단계의 권한 경계, 어댑터 계약, 주문/결제/취소/환불 상태 머신, 재시도/조정/증거 정의.

### 000900_outsourcing_vendor_handoff_and_acceptance
아웃소싱 벤더 핸드오프 및 인수. RFP/SOW, 벤더 보안·접근·IP 규칙, 인수 증거·검증, 000800 기반 위에서의 벤더 납품 통제.

### 001000_mvp_scope
MVP 범위 정의. 1차 출시 포함/제외 기능 경계, MVP 단계별 기능 목록, 우선순위.

### 003000_saas_runtime
SaaS 런타임 아키텍처. 멀티테넌트 구조, 테넌트 격리, SaaS 운영 모델, 런타임 경계.

### 004000_store_runtime_pos_kds_operations
매장 런타임 운영. POS 연동, KDS 흐름, 주문 접수/처리, 매장 운영 스펙.

### 004900_security_runtime_test_catalog
보안 런타임 테스트 카탈로그. 보안 테스트 케이스, 런타임 보안 검증 목록.

### 005000_customer_handoff_and_implementation_readiness
고객 핸드오프 및 구현 준비. 고객 인도 흐름, 구현 준비 체크리스트, 핸드오프 패킷.

### 007000_admin_console
어드민 콘솔 스펙. 운영자/오너 관리 화면, 테넌트 관리, 대시보드 기능 정의.

### 008000_ai_customer_center
AI 고객센터. AI 상담 자동화, 고객 문의 처리, 지식베이스 연동.

### 009000_data_model_state_machine
데이터 모델 및 상태 머신. 핵심 엔티티 스키마, 상태 전이 정의, 이벤트 계약.

### 010000_runtime_foundation_and_cross_room_architecture
런타임 기반 및 크로스룸 아키텍처. 런타임 공통 기반, 룸 간 연동 구조, 이벤트 버스 설계.

### 011000_integration_boundary
통합 경계 정의. 외부 시스템 연동 경계, API 계약, 채널 경계, 책임 분리.

### 011500_pos_gateway_runtime_flow_implementation_package
POS 게이트웨이 런타임 플로우 구현 패키지. POS 연동 흐름 구현 묶음.

### 012000_implementation_mapping
구현 매핑. 문서-코드 대응 맵, 기능-모듈 매핑.

### 013000_app_api_projection
앱 API 프로젝션. 앱 클라이언트 API 인터페이스, RPC/REST 스펙.

### 014000_pos_provider_integration_strategy
POS 공급업체 통합 전략. 공급업체 평가, 연동 전략, 어댑터 설계.

### 015000_membership_loyalty
멤버십 및 로열티. 회원 등급, 포인트, 쿠폰, 리텐션 정책.

### 016000_admin_console_saas_operations_control
어드민 콘솔 SaaS 운영 통제. SaaS 운영자 제어 기능, 테넌트 라이프사이클 관리.

### 017000_ui_screen_composition
UI 화면 구성. 화면 구조, 와이어프레임, 컴포넌트 구성, 워딩 정책.

### 018000_ai_customer_center_sop_knowledge_automation
AI 고객센터 SOP 및 지식 자동화. SOP 연동, 지식 자동화 파이프라인.

### 019000_data_model_state_machine_runtime_event_contract
데이터 모델 런타임 이벤트 계약. 런타임 이벤트 페이로드, 상태 계약, 프로토콜 스펙.

### 020000_validation_security_audit
검증, 보안, 감사. 검증 정책, 보안 감사 규칙, 감사 이벤트 정의.

### 021000_financial_security_monitoring_catalog
재무 보안 모니터링 카탈로그. 재무 이상 탐지, 보안 모니터링 항목, 감사 카탈로그.

### 022000_implementation_planning
구현 계획. 구현 작업 계획, 빌드 순서, QA 계획.

### 023000_implementation_planning
구현 계획 (확장 밴드). 022000 이후 추가 구현 계획 문서.

### 024000_deployment_operations
배포 운영. 배포 절차, 운영 지원, 롤백 계획.

### 025000_security_audit_evidence_financial_grade_control
보안 감사 증거 및 재무 등급 통제. 재무급 감사 증거 패킷, 통제 문서.

### 026000_analytics_reporting_bi
분석, 리포팅, BI. 데이터 분석 스펙, 리포트 정의, BI 연동.

### 027000_deployment_operations_release_runtime_control
배포 운영 릴리즈 런타임 통제. 릴리즈 관리, 런타임 통제 정책.

### 028000_future_expansion
향후 확장. 중기 기능 확장 계획, 외부 채널 연동 로드맵.

### 029000_operations_sop_store_runbook_support_closure
운영 SOP, 매장 런북, 지원 종료. 매장 운영 절차, 지원 런북, 종료 기록.

### 030000_future_saas_modules
미래 SaaS 모듈. 장기 SaaS 기능 후보, 모듈 확장 예약 밴드.

### 040000_menu_taxonomy_and_ai_classification
메뉴 분류 체계 및 AI 분류. 메뉴 카테고리 설계, AI 기반 메뉴 분류 로직.

### 070000_external_integration_control_plane_validation_correction_log_and_process_governance
외부 통합 통제 플레인 검증 및 프로세스 거버넌스. 외부 연동 통제, 검증 로그, 프로세스 관리.

### 700000_runtime_flow_bundle
런타임 플로우 번들. 문서 전용(코드 아님) 외부 통합 증거 및 릴리즈 준비성 번들.

### 700900_runtime_flow
POS 게이트웨이 금융 트랜잭션 Flow Bundle(승인/환불/타임아웃/웹훅/정산) 및 AI 구현 거버넌스 통제 인프라(레지스트리, 의존성 그래프, 모듈 맵, Claude Code/Cursor용 코드 핸드오프 템플릿, 예외 거버넌스, 인간 승인, 릴리즈 게이트). 고객향 주문/KDS 흐름이 아니며, 해당 내용은 `004000_store_runtime_pos_kds_operations`에 있음.

### 750000_delivery_app_channel_integration_kds_did_and_order_ingestion_runtime
배달앱 채널 통합, KDS DID, 주문 수신 런타임. 배달앱 연동 흐름, KDS 표시 연동, 주문 수신 처리.

### 900000_patent_and_handoff_package
특허 및 핸드오프 패키지. 고객 대기/핸드오프/late-binding 파이프라인, 채널별(웹/네이티브앱/화이트라벨/임베디드) 핸드오프, 키오스크·DID 자동 제어, 특허 회피 전략, 멀티브랜드 SaaS 비전 정책 문서.

### Temp
임시 파일 보관. 정식 번호 미부여 작업 중 임시 문서. 정리 후 이동 또는 삭제 대상.

### _migration_history
마이그레이션 이력. 과거 파일명 변경, 이동, 배치 작업의 히스토리 보관. 참조 전용.

## 4 Add / Move 규칙

- 신규 문서는 해당 도메인 폴더에 배치. docs 루트는 거버넌스/게이트/배치 기록 문서만 허용.
- 신규 문서 생성 후 `000005_Index_Document_Number.md`, `000007_Map_Full_Directory.md` 반영 필수.
- 번호 없는 임시 md 파일을 docs 루트에 생성 금지.
- 각 하위 폴더의 첫 번째 파일은 `{폴더번호}_Readme_{폴더명}.md` 이어야 합니다.
