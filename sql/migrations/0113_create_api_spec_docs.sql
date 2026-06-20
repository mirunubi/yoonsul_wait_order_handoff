-- 0113_create_api_spec_docs.sql
-- Purpose: API specification and Flutter dev guide
--          registration in knowledge base.
--          외주용 API 명세 문서.
--          Flutter 개발 가이드.
--          기술신보 심사 자료 기반.
--          RPC 입출력 매핑표.
-- Depends on: 0112_create_hq_admin_rpc.sql

-- =============================================
-- API 명세 문서 등록
-- =============================================
insert into catchmenu_knowledge.documents (
  tenant_id, store_id,
  document_code, document_title,
  document_type, domain,
  content_ko, content_en,
  version_number, document_status,
  is_tenant_approved,
  approved_at, effective_from, created_by
) values

-- -----------------------------------------------
-- 1. 전체 RPC 매핑표
-- -----------------------------------------------
(
  '00000000-0000-0000-0000-000000000001',
  null,
  'API_SPEC_RPC_MAP_001',
  'Catch Menu RPC 전체 매핑표',
  'SPEC', 'ARCHITECTURE',
  $ko$
# Catch Menu RPC 전체 매핑표

## 0. 기본 원칙

모든 RPC는 다음 표준 응답 구조를 반환한다.

```json
{
  "success": true,
  "message": "메시지 (i18n)",
  "data": { ... },
  "error_code": null,
  "error_key": null,
  "correlation_id": "..."
}
```

오류 시:
```json
{
  "success": false,
  "message": "오류 메시지",
  "data": null,
  "error_code": 1001,
  "error_key": "auth_required"
}
```

## 1. 인증 파이프라인

| RPC | 설명 | 권한 |
|-----|------|------|
| catchmenu_common.register_device | 디바이스 등록 | authenticated |
| catchmenu_common.verify_device_trust | 디바이스 신뢰 검증 | authenticated |
| catchmenu_common.staff_login | 직원 PIN 로그인 | authenticated |
| catchmenu_common.staff_logout | 직원 로그아웃 | authenticated |
| catchmenu_common.refresh_auth_session | 세션 갱신 | authenticated |
| catchmenu_common.customer_phone_verify_send | 고객 전화 인증 발송 | authenticated |
| catchmenu_common.customer_login | 고객 로그인 | authenticated |
| catchmenu_common.get_auth_context | 인증 컨텍스트 조회 | authenticated |

## 2. 직원 앱 부트스트랩

| RPC | 설명 | 권한 |
|-----|------|------|
| catchmenu_common.bootstrap_staff_app | 직원 앱 전체 초기화 | authenticated |
| catchmenu_store.open_store | 매장 오픈 | authenticated |
| catchmenu_store.close_store | 매장 마감 | authenticated |
| catchmenu_store.change_store_mode | 매장 모드 변경 | authenticated |
| catchmenu_store.get_store_dashboard | 매장 대시보드 | authenticated |

## 3. 메뉴 / 주문

| RPC | 설명 | 권한 |
|-----|------|------|
| catchmenu_pos.get_menu_catalog_i18n | 메뉴 카탈로그 조회 | authenticated |
| catchmenu_pos.place_takeout_order | 포장 주문 | authenticated |
| catchmenu_store.bootstrap_customer_app | 고객 앱 초기화 | authenticated |
| catchmenu_store.place_takeout_order | 고객 포장 주문 | authenticated |

## 4. KDS 파이프라인

| RPC | 설명 | 권한 |
|-----|------|------|
| catchmenu_kds.get_kds_realtime_state | KDS 실시간 상태 | authenticated |
| catchmenu_kds.transition_kds_ticket | KDS 상태 전환 | authenticated |
| catchmenu_kds.check_kds_capacity | KDS 용량 확인 | authenticated |

## 5. 결제 파이프라인

| RPC | 설명 | 권한 |
|-----|------|------|
| catchmenu_payment.confirm_payment | 결제 확인 (핵심) | authenticated |
| catchmenu_payment.release_kds_after_payment | KDS Late Binding 해제 | authenticated |
| catchmenu_payment.request_refund | 환불 요청 | authenticated |
| catchmenu_payment.confirm_refund | 환불 확인 | authenticated |
| catchmenu_payment.get_payment_status | 결제 상태 조회 | authenticated |
| catchmenu_integrations.initiate_toss_payment | 토스페이먼츠 결제 시작 | authenticated |
| catchmenu_integrations.confirm_toss_payment | 토스페이먼츠 결제 확인 | authenticated |
| catchmenu_integrations.cancel_toss_payment | 토스페이먼츠 취소 | authenticated |
| catchmenu_integrations.process_toss_webhook | 토스 웹훅 처리 | authenticated |

## 6. 대기 파이프라인

| RPC | 설명 | 권한 |
|-----|------|------|
| catchmenu_pos.get_waiting_realtime_state | 대기 실시간 상태 | authenticated |
| catchmenu_pos.estimate_wait_time | 대기 시간 예측 | authenticated |
| catchmenu_store.call_customer_pickup | 고객 호출 | authenticated |

## 7. Realtime 파이프라인

| RPC | 설명 | 권한 |
|-----|------|------|
| catchmenu_common.get_realtime_config | Realtime 설정 조회 | authenticated |
| catchmenu_common.broadcast_store_event | 이벤트 브로드캐스트 | authenticated |
| catchmenu_common.get_staff_alert_feed | 직원 알림 피드 | authenticated |

## 8. POS 연동

| RPC | 설명 | 권한 |
|-----|------|------|
| catchmenu_integrations.sync_okpos_menu | OKpos 메뉴 동기화 | authenticated |
| catchmenu_integrations.send_order_to_okpos | OKpos 주문 전송 | authenticated |
| catchmenu_integrations.confirm_okpos_payment | OKpos 결제 확인 | authenticated |
| catchmenu_integrations.sync_toss_pos_menu | 토스POS 메뉴 동기화 | authenticated |
| catchmenu_integrations.send_order_to_toss_pos | 토스POS 주문 전송 | authenticated |
| catchmenu_integrations.confirm_toss_pos_payment | 토스POS 결제 확인 | authenticated |

## 9. 배달 플랫폼

| RPC | 설명 | 권한 |
|-----|------|------|
| catchmenu_integrations.receive_delivery_order | 배달 주문 수신 | authenticated |
| catchmenu_integrations.accept_delivery_order | 배달 주문 수락 | authenticated |
| catchmenu_integrations.reject_delivery_order | 배달 주문 거절 | authenticated |
| catchmenu_integrations.update_delivery_status | 배달 상태 업데이트 | authenticated |
| catchmenu_integrations.get_delivery_dashboard | 배달 대시보드 | authenticated |

## 10. 현금영수증

| RPC | 설명 | 권한 |
|-----|------|------|
| catchmenu_integrations.issue_cash_receipt | 현금영수증 발급 | authenticated |
| catchmenu_integrations.auto_issue_cash_receipt | 자동 발급 판단 | authenticated |
| catchmenu_integrations.confirm_cash_receipt | 발급 확인 | authenticated |
| catchmenu_integrations.cancel_cash_receipt | 취소 | authenticated |

## 11. CMS / 이벤트

| RPC | 설명 | 권한 |
|-----|------|------|
| catchmenu_store.create_cms_event | 이벤트 생성 | authenticated |
| catchmenu_store.publish_cms_event | 이벤트 발행 | authenticated |
| catchmenu_store.create_cms_banner | 배너 생성 | authenticated |
| catchmenu_store.create_cms_popup | 팝업 생성 | authenticated |
| catchmenu_store.get_cms_display_bundle | CMS 표시 번들 | authenticated |
| catchmenu_store.get_cms_dashboard | CMS 대시보드 | authenticated |

## 12. 멤버십

| RPC | 설명 | 권한 |
|-----|------|------|
| catchmenu_store.earn_points_after_order | 주문 후 포인트 적립 | authenticated |
| catchmenu_store.stamp_visit | 스탬프 적립 | authenticated |
| catchmenu_store.get_customer_membership | 고객 멤버십 조회 | authenticated |
| catchmenu_store.get_membership_dashboard | 멤버십 대시보드 | authenticated |

## 13. 네트워크 / 오프라인

| RPC | 설명 | 권한 |
|-----|------|------|
| catchmenu_common.report_network_status | 네트워크 상태 보고 | authenticated |
| catchmenu_common.enqueue_offline_action | 오프라인 큐 등록 | authenticated |
| catchmenu_common.flush_offline_queue | 오프라인 큐 동기화 | authenticated |
| catchmenu_common.get_fallback_config | Fallback 설정 조회 | authenticated |

## 14. 매장 관리자

| RPC | 설명 | 권한 |
|-----|------|------|
| catchmenu_store.upsert_menu | 메뉴 등록/수정 | authenticated |
| catchmenu_store.set_menu_status | 메뉴 상태 변경 | authenticated |
| catchmenu_store.get_menu_admin_list | 메뉴 목록 | authenticated |
| catchmenu_store.upsert_staff | 직원 등록/수정 | authenticated |
| catchmenu_store.get_staff_admin_list | 직원 목록 | authenticated |
| catchmenu_store.set_store_hours | 영업시간 설정 | authenticated |
| catchmenu_store.set_holiday | 휴무일 설정 | authenticated |
| catchmenu_store.update_store_settings | 매장 설정 | authenticated |
| catchmenu_store.setup_pos_integration | POS 연동 설정 | authenticated |
| catchmenu_store.get_store_admin_dashboard | 매장 관리 대시보드 | authenticated |

## 15. 가맹점 관리자

| RPC | 설명 | 권한 |
|-----|------|------|
| catchmenu_hq.get_franchise_admin_dashboard | 가맹 대시보드 | authenticated |
| catchmenu_hq.get_brand_store_overview | 브랜드 매장 현황 | authenticated |
| catchmenu_hq.compare_store_revenue | 매장별 매출 비교 | authenticated |
| catchmenu_hq.broadcast_brand_cms | 브랜드 CMS 배포 | authenticated |
| catchmenu_hq.get_franchise_compliance_report | 컴플라이언스 리포트 | authenticated |
| catchmenu_hq.get_franchise_settlement_report | 정산 리포트 | authenticated |
| catchmenu_hq.distribute_menu_to_stores | 메뉴 템플릿 배포 | authenticated |
| catchmenu_hq.run_compliance_check | 정책 준수 검사 | authenticated |

## 16. HQ 관리자 (service_role 전용)

| RPC | 설명 | 권한 |
|-----|------|------|
| catchmenu_common.get_hq_dashboard | HQ 대시보드 | service_role |
| catchmenu_common.get_tenant_list | 테넌트 목록 | service_role |
| catchmenu_common.onboard_tenant | 테넌트 온보딩 | service_role |
| catchmenu_common.manage_subscription | 구독 관리 | service_role |
| catchmenu_common.get_saas_revenue_report | SaaS 매출 리포트 | service_role |
| catchmenu_common.get_system_health_all | 전체 시스템 헬스 | service_role |

## 17. AI / SOP

| RPC | 설명 | 권한 |
|-----|------|------|
| catchmenu_knowledge.search_knowledge | RAG 지식 검색 | authenticated |
| catchmenu_knowledge.verify_answer_grounding | 답변 근거 검증 | authenticated |
| catchmenu_knowledge.publish_sop_document | SOP 발행 | authenticated |
| catchmenu_knowledge.submit_customer_inquiry | 고객 문의 등록 | authenticated |
| catchmenu_knowledge.get_ai_center_dashboard | AI 고객센터 대시보드 | authenticated |
$ko$,
  $en$
# Catch Menu RPC Complete Mapping Table

## Standard Response Structure

```json
{
  "success": true,
  "message": "Message (i18n)",
  "data": { ... },
  "error_code": null,
  "error_key": null,
  "correlation_id": "..."
}
```

All RPCs follow this structure.
See Korean version for full table.
$en$,
  1, 'PUBLISHED', true, now(), current_date, null
),

-- -----------------------------------------------
-- 2. Flutter 개발 가이드
-- -----------------------------------------------
(
  '00000000-0000-0000-0000-000000000001',
  null,
  'API_SPEC_FLUTTER_GUIDE_001',
  'Flutter 개발 가이드 — Catch Menu',
  'GUIDE', 'FLUTTER',
  $ko$
# Flutter 개발 가이드 — Catch Menu

## 1. 프로젝트 구조