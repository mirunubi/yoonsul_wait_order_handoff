-- 0093_create_message_catalog_complete.sql
-- Purpose: Complete message catalog and error codes.
--          All i18n messages for all domains.
--          All error codes for all domains.
--          0001~0092 전체 메시지 통합 정리.
--          6개 로케일: ko/en/zh/ja/vi/th
--          i18n 원칙: SQL 내 한글 하드코딩 금지.
-- Depends on: 0092_create_flutter_edge_function_guide_rpc.sql
-- Creates:
--   catchmenu_common.message_catalog 전체 시드
--   catchmenu_common.error_codes 전체 시드

-- =============================================
-- 에러 코드 완성 (도메인별 전체)
-- =============================================

-- 1xxx: AUTH / 세션 / 디바이스
insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity,
  sop_runbook_code
) values
(1001, 'auth_required',
  'AUTH', 'AUTHENTICATION', 401, 'ERROR', null),
(1002, 'auth_token_expired',
  'AUTH', 'AUTHENTICATION', 401, 'WARNING', null),
(1003, 'auth_token_invalid',
  'AUTH', 'AUTHENTICATION', 401, 'ERROR', null),
(1004, 'auth_permission_denied',
  'AUTH', 'AUTHORIZATION', 403, 'ERROR', null),
(1005, 'device_not_registered',
  'AUTH', 'AUTHORIZATION', 403, 'WARNING',
  'SOP-SEC-001'),
(1006, 'device_not_trusted',
  'AUTH', 'AUTHORIZATION', 403, 'WARNING',
  'SOP-SEC-001'),
(1007, 'device_blocked',
  'AUTH', 'AUTHORIZATION', 403, 'CRITICAL',
  'SOP-SEC-002'),
(1008, 'session_expired',
  'AUTH', 'AUTHENTICATION', 401, 'INFO', null),
(1009, 'tenant_not_found',
  'AUTH', 'NOT_FOUND', 404, 'ERROR', null),
(1010, 'tenant_suspended',
  'AUTH', 'AUTHORIZATION', 403, 'ERROR',
  'SOP-SEC-003'),
(1011, 'store_not_found',
  'AUTH', 'NOT_FOUND', 404, 'WARNING', null),
(1012, 'staff_not_found',
  'AUTH', 'NOT_FOUND', 404, 'WARNING', null),
(1013, 'customer_not_found',
  'AUTH', 'NOT_FOUND', 404, 'WARNING', null),
(1014, 'invalid_input',
  'AUTH', 'VALIDATION', 400, 'WARNING', null),
(1015, 'duplicate_request',
  'AUTH', 'CONFLICT', 409, 'INFO', null),

-- 2xxx: ORDER / KDS / 대기
(2001, 'order_not_found',
  'ORDER', 'NOT_FOUND', 404, 'WARNING', null),
(2002, 'order_not_confirmable',
  'ORDER', 'BUSINESS_RULE', 409, 'WARNING', null),
(2003, 'order_already_cancelled',
  'ORDER', 'CONFLICT', 409, 'INFO', null),
(2004, 'order_already_completed',
  'ORDER', 'CONFLICT', 409, 'INFO', null),
(2005, 'items_required',
  'ORDER', 'VALIDATION', 400, 'WARNING', null),
(2006, 'menu_not_found',
  'ORDER', 'NOT_FOUND', 404, 'WARNING', null),
(2007, 'menu_sold_out',
  'ORDER', 'BUSINESS_RULE', 409, 'WARNING', null),
(2008, 'menu_unavailable',
  'ORDER', 'BUSINESS_RULE', 409, 'WARNING', null),
(2009, 'kds_overloaded',
  'ORDER', 'CAPACITY', 429, 'WARNING',
  'SOP-KDS-001'),
(2010, 'kds_ticket_not_found',
  'ORDER', 'NOT_FOUND', 404, 'WARNING', null),
(2011, 'kds_invalid_transition',
  'ORDER', 'BUSINESS_RULE', 409, 'WARNING', null),
(2012, 'session_not_found',
  'ORDER', 'NOT_FOUND', 404, 'WARNING', null),
(2013, 'session_already_seated',
  'ORDER', 'CONFLICT', 409, 'INFO', null),
(2014, 'session_expired',
  'ORDER', 'BUSINESS_RULE', 410, 'INFO', null),
(2015, 'wait_queue_full',
  'ORDER', 'CAPACITY', 429, 'WARNING',
  'SOP-WAIT-001'),
(2016, 'pre_order_disabled',
  'ORDER', 'BUSINESS_RULE', 503, 'INFO', null),
(2017, 'order_amount_below_minimum',
  'ORDER', 'VALIDATION', 400, 'WARNING', null),
(2018, 'table_not_available',
  'ORDER', 'BUSINESS_RULE', 409, 'WARNING', null),

-- 3xxx: SYSTEM / SaaS / 인프라
(3001, 'internal_server_error',
  'SYSTEM', 'TECHNICAL', 500, 'ERROR',
  'SOP-SYS-001'),
(3002, 'database_error',
  'SYSTEM', 'TECHNICAL', 500, 'ERROR',
  'SOP-SYS-001'),
(3003, 'external_service_unavailable',
  'SYSTEM', 'TECHNICAL', 503, 'ERROR',
  'SOP-SYS-002'),
(3004, 'timeout',
  'SYSTEM', 'TECHNICAL', 504, 'WARNING',
  'SOP-SYS-002'),
(3005, 'feature_not_enabled',
  'SYSTEM', 'AUTHORIZATION', 403, 'INFO', null),
(3006, 'plan_upgrade_required',
  'SYSTEM', 'AUTHORIZATION', 403, 'INFO', null),
(3007, 'maintenance_mode',
  'SYSTEM', 'BUSINESS_RULE', 503, 'INFO',
  'SOP-SYS-003'),
(3008, 'store_closed',
  'SYSTEM', 'BUSINESS_RULE', 503, 'INFO', null),
(3009, 'holiday_mode',
  'SYSTEM', 'BUSINESS_RULE', 503, 'INFO', null),

-- 4xxx: PAYMENT / 결제 / 대사
(4001, 'payment_not_found',
  'PAYMENT', 'NOT_FOUND', 404, 'WARNING', null),
(4002, 'payment_already_approved',
  'PAYMENT', 'CONFLICT', 409, 'INFO', null),
(4003, 'payment_failed',
  'PAYMENT', 'TECHNICAL', 402, 'ERROR',
  'SOP-PAY-001'),
(4004, 'payment_cancelled',
  'PAYMENT', 'BUSINESS_RULE', 409, 'INFO', null),
(4005, 'refund_failed',
  'PAYMENT', 'TECHNICAL', 500, 'ERROR',
  'SOP-PAY-002'),
(4006, 'refund_amount_exceeded',
  'PAYMENT', 'VALIDATION', 400, 'ERROR', null),
(4007, 'reconciliation_gap',
  'PAYMENT', 'FINANCIAL', 409, 'CRITICAL',
  'SOP-PAY-003'),
(4008, 'settlement_not_found',
  'PAYMENT', 'NOT_FOUND', 404, 'WARNING', null),
(4009, 'insufficient_points',
  'PAYMENT', 'BUSINESS_RULE', 409, 'WARNING', null),
(4010, 'coupon_not_redeemable',
  'PAYMENT', 'BUSINESS_RULE', 409, 'WARNING', null),
(4011, 'coupon_expired',
  'PAYMENT', 'BUSINESS_RULE', 410, 'INFO', null),
(4012, 'pos_sync_failed',
  'PAYMENT', 'TECHNICAL', 500, 'ERROR',
  'SOP-POS-001'),
(4013, 'van_connection_failed',
  'PAYMENT', 'TECHNICAL', 503, 'ERROR',
  'SOP-PAY-004'),
(4014, 'case_already_resolved',
  'PAYMENT', 'CONFLICT', 409, 'INFO', null),

-- 5xxx: MENU / 재고 / 알레르겐
(5001, 'category_not_found',
  'MENU', 'NOT_FOUND', 404, 'WARNING', null),
(5002, 'menu_code_duplicate',
  'MENU', 'CONFLICT', 409, 'WARNING', null),
(5003, 'allergen_not_declared',
  'MENU', 'COMPLIANCE', 422, 'CRITICAL',
  'SOP-FOOD-001'),
(5004, 'stock_insufficient',
  'MENU', 'BUSINESS_RULE', 409, 'WARNING',
  'SOP-INV-001'),
(5005, 'stock_not_found',
  'MENU', 'NOT_FOUND', 404, 'WARNING', null),
(5006, 'menu_template_conflict',
  'MENU', 'CONFLICT', 409, 'WARNING', null),
(5007, 'price_override_exceeded',
  'MENU', 'BUSINESS_RULE', 409, 'WARNING', null),

-- 6xxx: STAFF / 직원 / 스케줄
(6001, 'shift_not_found',
  'STAFF', 'NOT_FOUND', 404, 'WARNING', null),
(6002, 'shift_already_clocked_in',
  'STAFF', 'CONFLICT', 409, 'INFO', null),
(6003, 'shift_not_clocked_in',
  'STAFF', 'BUSINESS_RULE', 409, 'WARNING', null),
(6004, 'schedule_conflict',
  'STAFF', 'CONFLICT', 409, 'WARNING', null),
(6005, 'staff_quota_exceeded',
  'STAFF', 'QUOTA', 429, 'WARNING', null),
(6006, 'pay_basis_not_found',
  'STAFF', 'NOT_FOUND', 404, 'WARNING', null),

-- 7xxx: STORE / 매장 설정
(7001, 'store_group_not_found',
  'STORE', 'NOT_FOUND', 404, 'WARNING', null),
(7002, 'store_already_in_group',
  'STORE', 'CONFLICT', 409, 'INFO', null),
(7003, 'transfer_not_found',
  'STORE', 'NOT_FOUND', 404, 'WARNING', null),
(7004, 'transfer_already_processed',
  'STORE', 'CONFLICT', 409, 'INFO', null),
(7005, 'did_device_not_found',
  'STORE', 'NOT_FOUND', 404, 'WARNING', null),
(7006, 'cms_content_not_found',
  'STORE', 'NOT_FOUND', 404, 'WARNING', null),
(7007, 'promotion_not_found',
  'STORE', 'NOT_FOUND', 404, 'WARNING', null),
(7008, 'notice_not_found',
  'STORE', 'NOT_FOUND', 404, 'WARNING', null),
(7009, 'call_already_dismissed',
  'STORE', 'CONFLICT', 409, 'INFO', null),
(7010, 'push_token_invalid',
  'STORE', 'VALIDATION', 400, 'WARNING', null),
(7011, 'template_not_found',
  'STORE', 'NOT_FOUND', 404, 'WARNING', null),

-- 9xxx: DELIVERY / 배달 / 외부
(9001, 'delivery_platform_error',
  'DELIVERY', 'TECHNICAL', 502, 'ERROR',
  'SOP-DEL-001'),
(9002, 'delivery_order_not_found',
  'DELIVERY', 'NOT_FOUND', 404, 'WARNING', null),
(9003, 'delivery_auto_rejected',
  'DELIVERY', 'BUSINESS_RULE', 409, 'INFO', null),
(9004, 'delivery_sync_failed',
  'DELIVERY', 'TECHNICAL', 500, 'ERROR',
  'SOP-DEL-001'),
(9005, 'webhook_signature_invalid',
  'DELIVERY', 'SECURITY', 401, 'CRITICAL',
  'SOP-SEC-004'),

-- 10xxx: AUDIT / 감사 / 증빙
(10001, 'audit_record_not_found',
  'AUDIT', 'NOT_FOUND', 404, 'WARNING', null),
(10002, 'evidence_packet_incomplete',
  'AUDIT', 'COMPLIANCE', 422, 'ERROR',
  'SOP-AUD-001'),
(10003, 'ledger_event_missing',
  'AUDIT', 'COMPLIANCE', 422, 'CRITICAL',
  'SOP-AUD-001')
on conflict (code) do nothing;


-- =============================================
-- 전체 메시지 카탈로그
-- 6개 로케일: ko/en/zh/ja/vi/th
-- =============================================

-- -----------------------------------------------
-- AUTH / 공통 에러
-- -----------------------------------------------
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values

-- auth_required
('auth_required', 'ko', '로그인이 필요합니다'),
('auth_required', 'en', 'Login required'),
('auth_required', 'zh', '需要登录'),
('auth_required', 'ja', 'ログインが必要です'),
('auth_required', 'vi', 'Cần đăng nhập'),
('auth_required', 'th', 'ต้องเข้าสู่ระบบ'),

-- auth_token_expired
('auth_token_expired', 'ko',
  '세션이 만료되었습니다. 다시 로그인해 주세요'),
('auth_token_expired', 'en',
  'Session expired. Please log in again'),
('auth_token_expired', 'zh',
  '会话已过期，请重新登录'),
('auth_token_expired', 'ja',
  'セッションが期限切れです。再度ログインしてください'),
('auth_token_expired', 'vi',
  'Phiên đã hết hạn. Vui lòng đăng nhập lại'),
('auth_token_expired', 'th',
  'เซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่'),

-- auth_permission_denied
('auth_permission_denied', 'ko',
  '접근 권한이 없습니다'),
('auth_permission_denied', 'en',
  'Access denied'),
('auth_permission_denied', 'zh', '访问被拒绝'),
('auth_permission_denied', 'ja',
  'アクセスが拒否されました'),
('auth_permission_denied', 'vi',
  'Truy cập bị từ chối'),
('auth_permission_denied', 'th',
  'การเข้าถึงถูกปฏิเสธ'),

-- device_not_trusted
('device_not_trusted', 'ko',
  '신뢰할 수 없는 디바이스입니다'),
('device_not_trusted', 'en',
  'Device not trusted'),
('device_not_trusted', 'zh', '设备不受信任'),
('device_not_trusted', 'ja',
  '信頼できないデバイスです'),
('device_not_trusted', 'vi',
  'Thiết bị không được tin cậy'),
('device_not_trusted', 'th',
  'อุปกรณ์ไม่น่าเชื่อถือ'),

-- invalid_input
('invalid_input', 'ko',
  '입력값이 올바르지 않습니다: {field}'),
('invalid_input', 'en',
  'Invalid input: {field}'),
('invalid_input', 'zh', '输入无效：{field}'),
('invalid_input', 'ja',
  '入力が正しくありません：{field}'),
('invalid_input', 'vi',
  'Đầu vào không hợp lệ: {field}'),
('invalid_input', 'th',
  'ข้อมูลไม่ถูกต้อง: {field}'),

-- store_not_found
('store_not_found', 'ko',
  '매장을 찾을 수 없습니다'),
('store_not_found', 'en', 'Store not found'),
('store_not_found', 'zh', '找不到门店'),
('store_not_found', 'ja', '店舗が見つかりません'),
('store_not_found', 'vi',
  'Không tìm thấy cửa hàng'),
('store_not_found', 'th',
  'ไม่พบร้านค้า'),

-- tenant_not_found
('tenant_not_found', 'ko',
  '테넌트를 찾을 수 없습니다'),
('tenant_not_found', 'en', 'Tenant not found'),
('tenant_not_found', 'zh', '找不到租户'),
('tenant_not_found', 'ja',
  'テナントが見つかりません'),
('tenant_not_found', 'vi',
  'Không tìm thấy tenant'),
('tenant_not_found', 'th',
  'ไม่พบผู้เช่า'),

-- -----------------------------------------------
-- ORDER / KDS / 대기
-- -----------------------------------------------

-- order_confirmed
('order_confirmed', 'ko',
  '주문이 확인되었습니다'),
('order_confirmed', 'en',
  'Order confirmed'),
('order_confirmed', 'zh', '订单已确认'),
('order_confirmed', 'ja',
  'ご注文を承りました'),
('order_confirmed', 'vi',
  'Đơn hàng đã được xác nhận'),
('order_confirmed', 'th',
  'ยืนยันคำสั่งซื้อแล้ว'),

-- order_ready
('order_ready', 'ko',
  '{order_number}번 준비가 완료되었습니다'),
('order_ready', 'en',
  'Order #{order_number} is ready'),
('order_ready', 'zh',
  '{order_number}号，已准备好'),
('order_ready', 'ja',
  '{order_number}番のご注文が準備できました'),
('order_ready', 'vi',
  'Đơn hàng #{order_number} đã sẵn sàng'),
('order_ready', 'th',
  'คำสั่งซื้อ #{order_number} พร้อมแล้ว'),

-- order_cancelled
('order_cancelled', 'ko',
  '주문이 취소되었습니다'),
('order_cancelled', 'en',
  'Order cancelled'),
('order_cancelled', 'zh', '订单已取消'),
('order_cancelled', 'ja',
  'ご注文がキャンセルされました'),
('order_cancelled', 'vi',
  'Đơn hàng đã bị hủy'),
('order_cancelled', 'th',
  'ยกเลิกคำสั่งซื้อแล้ว'),

-- order_not_found
('order_not_found', 'ko',
  '주문을 찾을 수 없습니다'),
('order_not_found', 'en', 'Order not found'),
('order_not_found', 'zh', '找不到订单'),
('order_not_found', 'ja',
  'ご注文が見つかりません'),
('order_not_found', 'vi',
  'Không tìm thấy đơn hàng'),
('order_not_found', 'th',
  'ไม่พบคำสั่งซื้อ'),

-- order_not_confirmable
('order_not_confirmable', 'ko',
  '현재 상태에서 주문을 확인할 수 없습니다'),
('order_not_confirmable', 'en',
  'Order cannot be confirmed in current state'),
('order_not_confirmable', 'zh',
  '当前状态下无法确认订单'),
('order_not_confirmable', 'ja',
  '現在の状態では注文を確認できません'),
('order_not_confirmable', 'vi',
  'Không thể xác nhận đơn hàng ở trạng thái hiện tại'),
('order_not_confirmable', 'th',
  'ไม่สามารถยืนยันคำสั่งซื้อในสถานะปัจจุบัน'),

-- menu_sold_out
('menu_sold_out', 'ko',
  '{menu_name}이(가) 품절되었습니다'),
('menu_sold_out', 'en',
  '{menu_name} is sold out'),
('menu_sold_out', 'zh',
  '{menu_name}已售罄'),
('menu_sold_out', 'ja',
  '{menu_name}は売り切れです'),
('menu_sold_out', 'vi',
  '{menu_name} đã hết hàng'),
('menu_sold_out', 'th',
  '{menu_name} หมดแล้ว'),

-- menu_not_found
('menu_not_found', 'ko',
  '메뉴를 찾을 수 없습니다'),
('menu_not_found', 'en', 'Menu not found'),
('menu_not_found', 'zh', '找不到菜单'),
('menu_not_found', 'ja',
  'メニューが見つかりません'),
('menu_not_found', 'vi',
  'Không tìm thấy menu'),
('menu_not_found', 'th',
  'ไม่พบเมนู'),

-- kds_overloaded
('kds_overloaded', 'ko',
  '주방이 바빠 잠시 후 주문해 주세요'),
('kds_overloaded', 'en',
  'Kitchen is busy. Please order later'),
('kds_overloaded', 'zh',
  '厨房繁忙，请稍后下单'),
('kds_overloaded', 'ja',
  'ただいまキッチンが混み合っています。しばらくしてからご注文ください'),
('kds_overloaded', 'vi',
  'Bếp đang bận. Vui lòng đặt hàng sau'),
('kds_overloaded', 'th',
  'ครัวกำลังยุ่ง กรุณาสั่งอาหารภายหลัง'),

-- kds_invalid_transition
('kds_invalid_transition', 'ko',
  '유효하지 않은 KDS 상태 전환입니다'),
('kds_invalid_transition', 'en',
  'Invalid KDS status transition'),
('kds_invalid_transition', 'zh',
  'KDS状态转换无效'),
('kds_invalid_transition', 'ja',
  '無効なKDS状態遷移です'),
('kds_invalid_transition', 'vi',
  'Chuyển đổi trạng thái KDS không hợp lệ'),
('kds_invalid_transition', 'th',
  'การเปลี่ยนสถานะ KDS ไม่ถูกต้อง'),

-- wait_queue_full
('wait_queue_full', 'ko',
  '대기 인원이 가득 찼습니다'),
('wait_queue_full', 'en',
  'Waiting queue is full'),
('wait_queue_full', 'zh', '等候队伍已满'),
('wait_queue_full', 'ja',
  '順番待ちが満員です'),
('wait_queue_full', 'vi',
  'Hàng chờ đã đầy'),
('wait_queue_full', 'th',
  'คิวรอเต็มแล้ว'),

-- pre_order_disabled
('pre_order_disabled', 'ko',
  '현재 주문을 받지 않습니다'),
('pre_order_disabled', 'en',
  'Orders are not being accepted'),
('pre_order_disabled', 'zh',
  '目前不接受订单'),
('pre_order_disabled', 'ja',
  '現在注文を受け付けておりません'),
('pre_order_disabled', 'vi',
  'Hiện không nhận đơn hàng'),
('pre_order_disabled', 'th',
  'ขณะนี้ไม่รับคำสั่งซื้อ'),

-- items_required
('items_required', 'ko',
  '주문 항목이 필요합니다'),
('items_required', 'en',
  'Order items are required'),
('items_required', 'zh', '需要订单项目'),
('items_required', 'ja',
  '注文項目が必要です'),
('items_required', 'vi',
  'Cần có mục đơn hàng'),
('items_required', 'th',
  'ต้องมีรายการสั่งซื้อ'),

-- order_amount_below_minimum
('order_amount_below_minimum', 'ko',
  '최소 주문금액 {min_order_amount}원 이상이어야 합니다'),
('order_amount_below_minimum', 'en',
  'Minimum order amount is {min_order_amount}'),
('order_amount_below_minimum', 'zh',
  '最低订单金额为{min_order_amount}'),
('order_amount_below_minimum', 'ja',
  '最低注文金額は{min_order_amount}円です'),
('order_amount_below_minimum', 'vi',
  'Số tiền đặt hàng tối thiểu là {min_order_amount}'),
('order_amount_below_minimum', 'th',
  'ยอดสั่งซื้อขั้นต่ำคือ {min_order_amount}'),

-- session_not_found
('session_not_found', 'ko',
  '세션을 찾을 수 없습니다'),
('session_not_found', 'en',
  'Session not found'),
('session_not_found', 'zh', '找不到会话'),
('session_not_found', 'ja',
  'セッションが見つかりません'),
('session_not_found', 'vi',
  'Không tìm thấy phiên'),
('session_not_found', 'th',
  'ไม่พบเซสชัน'),

-- -----------------------------------------------
-- PAYMENT / 결제
-- -----------------------------------------------

-- payment_failed
('payment_failed', 'ko',
  '결제에 실패했습니다. 다시 시도해 주세요'),
('payment_failed', 'en',
  'Payment failed. Please try again'),
('payment_failed', 'zh',
  '付款失败，请重试'),
('payment_failed', 'ja',
  'お支払いに失敗しました。再度お試しください'),
('payment_failed', 'vi',
  'Thanh toán thất bại. Vui lòng thử lại'),
('payment_failed', 'th',
  'การชำระเงินล้มเหลว กรุณาลองอีกครั้ง'),

-- payment_cancelled
('payment_cancelled', 'ko',
  '결제가 취소되었습니다'),
('payment_cancelled', 'en',
  'Payment cancelled'),
('payment_cancelled', 'zh', '付款已取消'),
('payment_cancelled', 'ja',
  'お支払いがキャンセルされました'),
('payment_cancelled', 'vi',
  'Thanh toán đã bị hủy'),
('payment_cancelled', 'th',
  'ยกเลิกการชำระเงินแล้ว'),

-- refund_failed
('refund_failed', 'ko',
  '환불 처리에 실패했습니다'),
('refund_failed', 'en',
  'Refund failed'),
('refund_failed', 'zh', '退款失败'),
('refund_failed', 'ja', '返金に失敗しました'),
('refund_failed', 'vi',
  'Hoàn tiền thất bại'),
('refund_failed', 'th',
  'การคืนเงินล้มเหลว'),

-- insufficient_points
('insufficient_points', 'ko',
  '포인트가 부족합니다. 현재 잔액: {point_balance}P'),
('insufficient_points', 'en',
  'Insufficient points. Balance: {point_balance}P'),
('insufficient_points', 'zh',
  '积分不足。余额：{point_balance}P'),
('insufficient_points', 'ja',
  'ポイントが不足しています。残高：{point_balance}P'),
('insufficient_points', 'vi',
  'Không đủ điểm. Số dư: {point_balance}P'),
('insufficient_points', 'th',
  'แต้มไม่เพียงพอ ยอดคงเหลือ: {point_balance}P'),

-- coupon_not_redeemable
('coupon_not_redeemable', 'ko',
  '사용할 수 없는 쿠폰입니다'),
('coupon_not_redeemable', 'en',
  'Coupon cannot be redeemed'),
('coupon_not_redeemable', 'zh',
  '优惠券无法使用'),
('coupon_not_redeemable', 'ja',
  'クーポンは使用できません'),
('coupon_not_redeemable', 'vi',
  'Không thể sử dụng phiếu giảm giá'),
('coupon_not_redeemable', 'th',
  'ไม่สามารถใช้คูปองได้'),

-- layer2_recon_balanced
('layer2_recon_balanced', 'ko',
  'Layer 2 대사가 일치합니다'),
('layer2_recon_balanced', 'en',
  'Layer 2 reconciliation balanced'),
('layer2_recon_balanced', 'zh',
  'Layer 2对账平衡'),
('layer2_recon_balanced', 'ja',
  'Layer 2照合が一致しています'),
('layer2_recon_balanced', 'vi',
  'Layer 2 đối soát cân bằng'),
('layer2_recon_balanced', 'th',
  'Layer 2 กระทบยอดสมดุล'),

-- layer2_recon_gap_detected
('layer2_recon_gap_detected', 'ko',
  'Layer 2 대사 불일치가 감지되었습니다'),
('layer2_recon_gap_detected', 'en',
  'Layer 2 reconciliation gap detected'),
('layer2_recon_gap_detected', 'zh',
  '检测到Layer 2对账差异'),
('layer2_recon_gap_detected', 'ja',
  'Layer 2照合の不一致が検出されました'),
('layer2_recon_gap_detected', 'vi',
  'Phát hiện chênh lệch đối soát Layer 2'),
('layer2_recon_gap_detected', 'th',
  'ตรวจพบความไม่สมดุลในการกระทบยอด Layer 2'),

-- layer3_recon_balanced
('layer3_recon_balanced', 'ko',
  'Layer 3 정산 대사가 일치합니다'),
('layer3_recon_balanced', 'en',
  'Layer 3 settlement reconciliation balanced'),
('layer3_recon_balanced', 'zh',
  'Layer 3结算对账平衡'),
('layer3_recon_balanced', 'ja',
  'Layer 3決済照合が一致しています'),
('layer3_recon_balanced', 'vi',
  'Layer 3 đối soát thanh toán cân bằng'),
('layer3_recon_balanced', 'th',
  'Layer 3 กระทบยอดการชำระเงินสมดุล'),

-- layer3_recon_gap_detected
('layer3_recon_gap_detected', 'ko',
  'Layer 3 정산 불일치가 감지되었습니다'),
('layer3_recon_gap_detected', 'en',
  'Layer 3 settlement gap detected'),
('layer3_recon_gap_detected', 'zh',
  '检测到Layer 3结算差异'),
('layer3_recon_gap_detected', 'ja',
  'Layer 3決済の不一致が検出されました'),
('layer3_recon_gap_detected', 'vi',
  'Phát hiện chênh lệch thanh toán Layer 3'),
('layer3_recon_gap_detected', 'th',
  'ตรวจพบความไม่สมดุลการชำระเงิน Layer 3'),

-- recon_gap_resolved
('recon_gap_resolved', 'ko',
  '대사 불일치가 해결되었습니다'),
('recon_gap_resolved', 'en',
  'Reconciliation gap resolved'),
('recon_gap_resolved', 'zh', '对账差异已解决'),
('recon_gap_resolved', 'ja',
  '照合の不一致が解決されました'),
('recon_gap_resolved', 'vi',
  'Chênh lệch đối soát đã được giải quyết'),
('recon_gap_resolved', 'th',
  'แก้ไขความไม่สมดุลการกระทบยอดแล้ว'),

-- pg_settlement_imported
('pg_settlement_imported', 'ko',
  'PG 정산 파일이 임포트되었습니다'),
('pg_settlement_imported', 'en',
  'PG settlement file imported'),
('pg_settlement_imported', 'zh',
  'PG结算文件已导入'),
('pg_settlement_imported', 'ja',
  'PG決済ファイルがインポートされました'),
('pg_settlement_imported', 'vi',
  'File thanh toán PG đã được nhập'),
('pg_settlement_imported', 'th',
  'นำเข้าไฟล์การชำระเงิน PG แล้ว'),

-- -----------------------------------------------
-- MENU / 식품 / 알레르겐
-- -----------------------------------------------

-- allergen_consult_staff
('allergen_consult_staff', 'ko',
  '알레르기 정보는 직원에게 문의해 주세요'),
('allergen_consult_staff', 'en',
  'Please consult staff for allergen information'),
('allergen_consult_staff', 'zh',
  '请咨询工作人员了解过敏原信息'),
('allergen_consult_staff', 'ja',
  'アレルゲン情報はスタッフにお問い合わせください'),
('allergen_consult_staff', 'vi',
  'Vui lòng hỏi nhân viên về thông tin dị ứng'),
('allergen_consult_staff', 'th',
  'กรุณาสอบถามพนักงานเกี่ยวกับข้อมูลสารก่อภูมิแพ้'),

-- allergen_not_declared
('allergen_not_declared', 'ko',
  '알레르겐 정보가 선언되지 않았습니다. 식품위생법 위반'),
('allergen_not_declared', 'en',
  'Allergen not declared. Food Safety Law violation'),
('allergen_not_declared', 'zh',
  '未申报过敏原。违反食品安全法'),
('allergen_not_declared', 'ja',
  'アレルゲンが未申告です。食品衛生法違反'),
('allergen_not_declared', 'vi',
  'Chất gây dị ứng chưa được khai báo. Vi phạm luật ATTP'),
('allergen_not_declared', 'th',
  'ไม่ได้แจ้งสารก่อภูมิแพ้ ละเมิดกฎหมายความปลอดภัยด้านอาหาร'),

-- stock_insufficient
('stock_insufficient', 'ko',
  '재고가 부족합니다'),
('stock_insufficient', 'en',
  'Insufficient stock'),
('stock_insufficient', 'zh', '库存不足'),
('stock_insufficient', 'ja', '在庫が不足しています'),
('stock_insufficient', 'vi',
  'Không đủ hàng tồn kho'),
('stock_insufficient', 'th',
  'สต็อกไม่เพียงพอ'),

-- -----------------------------------------------
-- STORE / CMS / DID / 고객
-- -----------------------------------------------

-- order_tracked
('order_tracked', 'ko',
  '주문 현황이 로드되었습니다'),
('order_tracked', 'en',
  'Order status loaded'),
('order_tracked', 'zh', '订单状态已加载'),
('order_tracked', 'ja',
  '注文状況が読み込まれました'),
('order_tracked', 'vi',
  'Trạng thái đơn hàng đã tải'),
('order_tracked', 'th',
  'โหลดสถานะคำสั่งซื้อแล้ว'),

-- customer_app_bootstrapped
('customer_app_bootstrapped', 'ko',
  '앱이 시작되었습니다'),
('customer_app_bootstrapped', 'en',
  'App initialized'),
('customer_app_bootstrapped', 'zh', '应用已初始化'),
('customer_app_bootstrapped', 'ja',
  'アプリが起動しました'),
('customer_app_bootstrapped', 'vi',
  'Ứng dụng đã khởi tạo'),
('customer_app_bootstrapped', 'th',
  'แอปเริ่มต้นแล้ว'),

-- customer_home_loaded
('customer_home_loaded', 'ko',
  '고객 홈이 로드되었습니다'),
('customer_home_loaded', 'en',
  'Customer home loaded'),
('customer_home_loaded', 'zh',
  '客户主页已加载'),
('customer_home_loaded', 'ja',
  'カスタマーホームが読み込まれました'),
('customer_home_loaded', 'vi',
  'Trang chủ khách hàng đã tải'),
('customer_home_loaded', 'th',
  'โหลดหน้าหลักลูกค้าแล้ว'),

-- customer_not_found
('customer_not_found', 'ko',
  '고객 정보를 찾을 수 없습니다'),
('customer_not_found', 'en',
  'Customer not found'),
('customer_not_found', 'zh', '找不到客户信息'),
('customer_not_found', 'ja',
  'お客様情報が見つかりません'),
('customer_not_found', 'vi',
  'Không tìm thấy thông tin khách hàng'),
('customer_not_found', 'th',
  'ไม่พบข้อมูลลูกค้า'),

-- push_token_registered
('push_token_registered', 'ko',
  '푸시 알림이 등록되었습니다'),
('push_token_registered', 'en',
  'Push notification registered'),
('push_token_registered', 'zh',
  '推送通知已注册'),
('push_token_registered', 'ja',
  'プッシュ通知が登録されました'),
('push_token_registered', 'vi',
  'Thông báo đẩy đã được đăng ký'),
('push_token_registered', 'th',
  'ลงทะเบียนการแจ้งเตือนพุชแล้ว'),

-- push_notification_queued
('push_notification_queued', 'ko',
  '푸시 알림이 발송 대기 중입니다'),
('push_notification_queued', 'en',
  'Push notification queued'),
('push_notification_queued', 'zh',
  '推送通知已加入队列'),
('push_notification_queued', 'ja',
  'プッシュ通知が送信待ちです'),
('push_notification_queued', 'vi',
  'Thông báo đẩy đang chờ gửi'),
('push_notification_queued', 'th',
  'การแจ้งเตือนพุชอยู่ในคิว'),

-- cms_content_published
('cms_content_published', 'ko',
  'CMS 콘텐츠가 발행되었습니다'),
('cms_content_published', 'en',
  'CMS content published'),
('cms_content_published', 'zh',
  'CMS内容已发布'),
('cms_content_published', 'ja',
  'CMSコンテンツが公開されました'),
('cms_content_published', 'vi',
  'Nội dung CMS đã được xuất bản'),
('cms_content_published', 'th',
  'เนื้อหา CMS ถูกเผยแพร่แล้ว'),

-- cms_content_loaded
('cms_content_loaded', 'ko',
  'CMS 콘텐츠가 로드되었습니다'),
('cms_content_loaded', 'en',
  'CMS content loaded'),
('cms_content_loaded', 'zh', 'CMS内容已加载'),
('cms_content_loaded', 'ja',
  'CMSコンテンツが読み込まれました'),
('cms_content_loaded', 'vi',
  'Nội dung CMS đã tải'),
('cms_content_loaded', 'th',
  'โหลดเนื้อหา CMS แล้ว'),

-- cms_bundle_loaded
('cms_bundle_loaded', 'ko',
  'CMS 번들이 로드되었습니다'),
('cms_bundle_loaded', 'en',
  'CMS bundle loaded'),
('cms_bundle_loaded', 'zh', 'CMS包已加载'),
('cms_bundle_loaded', 'ja',
  'CMSバンドルが読み込まれました'),
('cms_bundle_loaded', 'vi',
  'CMS bundle đã tải'),
('cms_bundle_loaded', 'th',
  'โหลด CMS bundle แล้ว'),

-- did_device_registered
('did_device_registered', 'ko',
  'DID 디바이스가 등록되었습니다'),
('did_device_registered', 'en',
  'DID device registered'),
('did_device_registered', 'zh',
  'DID设备已注册'),
('did_device_registered', 'ja',
  'DIDデバイスが登録されました'),
('did_device_registered', 'vi',
  'Thiết bị DID đã được đăng ký'),
('did_device_registered', 'th',
  'ลงทะเบียนอุปกรณ์ DID แล้ว'),

-- did_display_loaded
('did_display_loaded', 'ko',
  'DID 표시 데이터가 로드되었습니다'),
('did_display_loaded', 'en',
  'DID display data loaded'),
('did_display_loaded', 'zh',
  'DID显示数据已加载'),
('did_display_loaded', 'ja',
  'DID表示データが読み込まれました'),
('did_display_loaded', 'vi',
  'Dữ liệu hiển thị DID đã tải'),
('did_display_loaded', 'th',
  'โหลดข้อมูลแสดงผล DID แล้ว'),

-- did_content_pushed
('did_content_pushed', 'ko',
  'DID 콘텐츠가 업데이트되었습니다'),
('did_content_pushed', 'en',
  'DID content updated'),
('did_content_pushed', 'zh',
  'DID内容已更新'),
('did_content_pushed', 'ja',
  'DIDコンテンツが更新されました'),
('did_content_pushed', 'vi',
  'Nội dung DID đã được cập nhật'),
('did_content_pushed', 'th',
  'อัปเดตเนื้อหา DID แล้ว'),

-- did_zone_state_loaded
('did_zone_state_loaded', 'ko',
  'DID 존 상태가 로드되었습니다'),
('did_zone_state_loaded', 'en',
  'DID zone state loaded'),
('did_zone_state_loaded', 'zh',
  'DID区域状态已加载'),
('did_zone_state_loaded', 'ja',
  'DIDゾーン状態が読み込まれました'),
('did_zone_state_loaded', 'vi',
  'Trạng thái vùng DID đã tải'),
('did_zone_state_loaded', 'th',
  'โหลดสถานะโซน DID แล้ว'),

-- notices_loaded
('notices_loaded', 'ko',
  '공지사항이 로드되었습니다'),
('notices_loaded', 'en', 'Notices loaded'),
('notices_loaded', 'zh', '公告已加载'),
('notices_loaded', 'ja', 'お知らせが読み込まれました'),
('notices_loaded', 'vi', 'Thông báo đã tải'),
('notices_loaded', 'th', 'โหลดประกาศแล้ว'),

-- notice_created
('notice_created', 'ko',
  '공지사항이 등록되었습니다'),
('notice_created', 'en', 'Notice created'),
('notice_created', 'zh', '公告已创建'),
('notice_created', 'ja', 'お知らせが作成されました'),
('notice_created', 'vi', 'Thông báo đã được tạo'),
('notice_created', 'th', 'สร้างประกาศแล้ว'),

-- promotions_loaded
('promotions_loaded', 'ko',
  '프로모션이 로드되었습니다'),
('promotions_loaded', 'en',
  'Promotions loaded'),
('promotions_loaded', 'zh', '促销已加载'),
('promotions_loaded', 'ja',
  'プロモーションが読み込まれました'),
('promotions_loaded', 'vi',
  'Chương trình khuyến mãi đã tải'),
('promotions_loaded', 'th',
  'โหลดโปรโมชั่นแล้ว'),

-- promotion_created
('promotion_created', 'ko',
  '프로모션이 생성되었습니다'),
('promotion_created', 'en',
  'Promotion created'),
('promotion_created', 'zh', '促销已创建'),
('promotion_created', 'ja',
  'プロモーションが作成されました'),
('promotion_created', 'vi',
  'Khuyến mãi đã được tạo'),
('promotion_created', 'th',
  'สร้างโปรโมชั่นแล้ว'),

-- -----------------------------------------------
-- SYSTEM / SaaS / 인프라
-- -----------------------------------------------

-- internal_server_error
('internal_server_error', 'ko',
  '서버 오류가 발생했습니다. 잠시 후 다시 시도해 주세요'),
('internal_server_error', 'en',
  'Server error. Please try again later'),
('internal_server_error', 'zh',
  '服务器错误，请稍后重试'),
('internal_server_error', 'ja',
  'サーバーエラーが発生しました。しばらくしてから再度お試しください'),
('internal_server_error', 'vi',
  'Lỗi máy chủ. Vui lòng thử lại sau'),
('internal_server_error', 'th',
  'เกิดข้อผิดพลาดของเซิร์ฟเวอร์ กรุณาลองอีกครั้งภายหลัง'),

-- feature_not_enabled
('feature_not_enabled', 'ko',
  '이 기능은 현재 플랜에서 사용할 수 없습니다'),
('feature_not_enabled', 'en',
  'Feature not available on current plan'),
('feature_not_enabled', 'zh',
  '当前套餐不支持此功能'),
('feature_not_enabled', 'ja',
  'この機能は現在のプランでは利用できません'),
('feature_not_enabled', 'vi',
  'Tính năng không có trên gói hiện tại'),
('feature_not_enabled', 'th',
  'ฟีเจอร์นี้ไม่พร้อมใช้งานในแผนปัจจุบัน'),

-- plan_upgrade_required
('plan_upgrade_required', 'ko',
  '이 기능을 사용하려면 플랜 업그레이드가 필요합니다'),
('plan_upgrade_required', 'en',
  'Plan upgrade required for this feature'),
('plan_upgrade_required', 'zh',
  '使用此功能需要升级套餐'),
('plan_upgrade_required', 'ja',
  'この機能を使用するにはプランのアップグレードが必要です'),
('plan_upgrade_required', 'vi',
  'Cần nâng cấp gói để sử dụng tính năng này'),
('plan_upgrade_required', 'th',
  'ต้องอัปเกรดแผนเพื่อใช้ฟีเจอร์นี้'),

-- store_closed
('store_closed', 'ko',
  '현재 영업시간이 아닙니다'),
('store_closed', 'en',
  'Store is currently closed'),
('store_closed', 'zh', '当前不在营业时间'),
('store_closed', 'ja',
  '現在営業時間外です'),
('store_closed', 'vi',
  'Cửa hàng hiện đang đóng cửa'),
('store_closed', 'th',
  'ร้านค้าปิดอยู่ในขณะนี้'),

-- tenant_provisioned
('tenant_provisioned', 'ko',
  '테넌트가 생성되었습니다'),
('tenant_provisioned', 'en',
  'Tenant provisioned'),
('tenant_provisioned', 'zh', '租户已创建'),
('tenant_provisioned', 'ja',
  'テナントが作成されました'),
('tenant_provisioned', 'vi',
  'Tenant đã được tạo'),
('tenant_provisioned', 'th',
  'สร้าง tenant แล้ว'),

-- subscription_activated
('subscription_activated', 'ko',
  '구독이 활성화되었습니다'),
('subscription_activated', 'en',
  'Subscription activated'),
('subscription_activated', 'zh', '订阅已激活'),
('subscription_activated', 'ja',
  'サブスクリプションが有効化されました'),
('subscription_activated', 'vi',
  'Đăng ký đã được kích hoạt'),
('subscription_activated', 'th',
  'เปิดใช้งานการสมัครสมาชิกแล้ว'),

-- usage_recorded
('usage_recorded', 'ko',
  '사용량이 기록되었습니다'),
('usage_recorded', 'en', 'Usage recorded'),
('usage_recorded', 'zh', '使用量已记录'),
('usage_recorded', 'ja',
  '使用量が記録されました'),
('usage_recorded', 'vi',
  'Đã ghi lại mức sử dụng'),
('usage_recorded', 'th',
  'บันทึกการใช้งานแล้ว'),

-- saas_dashboard_loaded
('saas_dashboard_loaded', 'ko',
  'SaaS 대시보드가 로드되었습니다'),
('saas_dashboard_loaded', 'en',
  'SaaS dashboard loaded'),
('saas_dashboard_loaded', 'zh',
  'SaaS仪表板已加载'),
('saas_dashboard_loaded', 'ja',
  'SaaSダッシュボードが読み込まれました'),
('saas_dashboard_loaded', 'vi',
  'Dashboard SaaS đã tải'),
('saas_dashboard_loaded', 'th',
  'โหลดแดชบอร์ด SaaS แล้ว'),

-- saas_ready
('saas_ready', 'ko',
  'SaaS 출시 준비가 완료되었습니다'),
('saas_ready', 'en', 'SaaS launch ready'),
('saas_ready', 'zh', 'SaaS已准备好发布'),
('saas_ready', 'ja',
  'SaaSリリースの準備が完了しました'),
('saas_ready', 'vi',
  'Sẵn sàng ra mắt SaaS'),
('saas_ready', 'th',
  'พร้อมสำหรับการเปิดตัว SaaS'),

-- saas_not_ready
('saas_not_ready', 'ko',
  'SaaS 출시 준비가 아직 완료되지 않았습니다'),
('saas_not_ready', 'en',
  'SaaS not yet ready for launch'),
('saas_not_ready', 'zh', 'SaaS尚未准备好发布'),
('saas_not_ready', 'ja',
  'SaaSリリースの準備がまだ完了していません'),
('saas_not_ready', 'vi',
  'SaaS chưa sẵn sàng ra mắt'),
('saas_not_ready', 'th',
  'SaaS ยังไม่พร้อมสำหรับการเปิดตัว'),

-- delivery_status_synced
('delivery_status_synced', 'ko',
  '배달 주문 상태가 동기화되었습니다'),
('delivery_status_synced', 'en',
  'Delivery order status synced'),
('delivery_status_synced', 'zh',
  '外卖订单状态已同步'),
('delivery_status_synced', 'ja',
  'デリバリー注文状態が同期されました'),
('delivery_status_synced', 'vi',
  'Trạng thái đơn hàng giao đã đồng bộ'),
('delivery_status_synced', 'th',
  'ซิงค์สถานะคำสั่งซื้อเดลิเวอรี่แล้ว'),

-- delivery_sync_failed
('delivery_sync_failed', 'ko',
  '배달 주문 동기화에 실패했습니다'),
('delivery_sync_failed', 'en',
  'Delivery order sync failed'),
('delivery_sync_failed', 'zh',
  '外卖订单同步失败'),
('delivery_sync_failed', 'ja',
  'デリバリー注文の同期に失敗しました'),
('delivery_sync_failed', 'vi',
  'Đồng bộ đơn hàng giao thất bại'),
('delivery_sync_failed', 'th',
  'การซิงค์คำสั่งซื้อเดลิเวอรี่ล้มเหลว'),

-- delivery_poll_completed
('delivery_poll_completed', 'ko',
  '배달 주문 폴링이 완료되었습니다'),
('delivery_poll_completed', 'en',
  'Delivery order polling completed'),
('delivery_poll_completed', 'zh',
  '外卖订单轮询已完成'),
('delivery_poll_completed', 'ja',
  'デリバリー注文のポーリングが完了しました'),
('delivery_poll_completed', 'vi',
  'Hoàn thành polling đơn hàng giao'),
('delivery_poll_completed', 'th',
  'การ polling คำสั่งซื้อเดลิเวอรี่เสร็จสิ้น'),

-- delivery_performance_loaded
('delivery_performance_loaded', 'ko',
  '배달 성과가 로드되었습니다'),
('delivery_performance_loaded', 'en',
  'Delivery performance loaded'),
('delivery_performance_loaded', 'zh',
  '外卖绩效已加载'),
('delivery_performance_loaded', 'ja',
  'デリバリーパフォーマンスが読み込まれました'),
('delivery_performance_loaded', 'vi',
  'Hiệu suất giao hàng đã tải'),
('delivery_performance_loaded', 'th',
  'โหลดประสิทธิภาพการจัดส่งแล้ว'),

-- order_auto_rejected
('order_auto_rejected', 'ko',
  '주문이 자동으로 거절되었습니다'),
('order_auto_rejected', 'en',
  'Order automatically rejected'),
('order_auto_rejected', 'zh', '订单已自动拒绝'),
('order_auto_rejected', 'ja',
  'ご注文が自動的に断られました'),
('order_auto_rejected', 'vi',
  'Đơn hàng bị tự động từ chối'),
('order_auto_rejected', 'th',
  'คำสั่งซื้อถูกปฏิเสธโดยอัตโนมัติ'),

-- order_accepted
('order_accepted', 'ko',
  '주문이 수락되었습니다'),
('order_accepted', 'en', 'Order accepted'),
('order_accepted', 'zh', '订单已接受'),
('order_accepted', 'ja', 'ご注文を受け付けました'),
('order_accepted', 'vi', 'Đơn hàng đã được chấp nhận'),
('order_accepted', 'th', 'ยอมรับคำสั่งซื้อแล้ว'),

-- recon_report_loaded
('recon_report_loaded', 'ko',
  '정산 대사 리포트가 로드되었습니다'),
('recon_report_loaded', 'en',
  'Reconciliation report loaded'),
('recon_report_loaded', 'zh',
  '对账报告已加载'),
('recon_report_loaded', 'ja',
  '照合レポートが読み込まれました'),
('recon_report_loaded', 'vi',
  'Báo cáo đối soát đã tải'),
('recon_report_loaded', 'th',
  'โหลดรายงานการกระทบยอดแล้ว'),

-- staff_dashboard_loaded
('staff_dashboard_loaded', 'ko',
  '직원 대시보드가 로드되었습니다'),
('staff_dashboard_loaded', 'en',
  'Staff dashboard loaded'),
('staff_dashboard_loaded', 'zh',
  '员工仪表板已加载'),
('staff_dashboard_loaded', 'ja',
  'スタッフダッシュボードが読み込まれました'),
('staff_dashboard_loaded', 'vi',
  'Dashboard nhân viên đã tải'),
('staff_dashboard_loaded', 'th',
  'โหลดแดชบอร์ดพนักงานแล้ว'),

-- multistore_inventory_loaded
('multistore_inventory_loaded', 'ko',
  '다지점 재고가 로드되었습니다'),
('multistore_inventory_loaded', 'en',
  'Multi-store inventory loaded'),
('multistore_inventory_loaded', 'zh',
  '多门店库存已加载'),
('multistore_inventory_loaded', 'ja',
  '多店舗在庫が読み込まれました'),
('multistore_inventory_loaded', 'vi',
  'Tồn kho đa cửa hàng đã tải'),
('multistore_inventory_loaded', 'th',
  'โหลดสินค้าคงคลังหลายสาขาแล้ว'),

-- stock_transfer_requested
('stock_transfer_requested', 'ko',
  '재고 이동 요청이 접수되었습니다'),
('stock_transfer_requested', 'en',
  'Stock transfer requested'),
('stock_transfer_requested', 'zh',
  '库存调拨请求已提交'),
('stock_transfer_requested', 'ja',
  '在庫移動のリクエストが受け付けられました'),
('stock_transfer_requested', 'vi',
  'Yêu cầu chuyển hàng đã được gửi'),
('stock_transfer_requested', 'th',
  'ส่งคำขอโอนสต็อกแล้ว'),

-- stock_transfer_approved
('stock_transfer_approved', 'ko',
  '재고 이동이 승인되었습니다'),
('stock_transfer_approved', 'en',
  'Stock transfer approved'),
('stock_transfer_approved', 'zh',
  '库存调拨已批准'),
('stock_transfer_approved', 'ja',
  '在庫移動が承認されました'),
('stock_transfer_approved', 'vi',
  'Chuyển hàng đã được phê duyệt'),
('stock_transfer_approved', 'th',
  'อนุมัติการโอนสต็อกแล้ว'),

-- no_knowledge_found
('no_knowledge_found', 'ko',
  '관련 정보를 찾을 수 없습니다'),
('no_knowledge_found', 'en',
  'No relevant knowledge found'),
('no_knowledge_found', 'zh', '找不到相关信息'),
('no_knowledge_found', 'ja',
  '関連情報が見つかりません'),
('no_knowledge_found', 'vi',
  'Không tìm thấy thông tin liên quan'),
('no_knowledge_found', 'th',
  'ไม่พบข้อมูลที่เกี่ยวข้อง'),

-- delivery_order_cancelled (직원 알림)
('delivery_order_cancelled_alert', 'ko',
  '{order_number}번 배달 주문이 취소되었습니다'),
('delivery_order_cancelled_alert', 'en',
  'Delivery order #{order_number} cancelled'),
('delivery_order_cancelled_alert', 'zh',
  '{order_number}号外卖订单已取消'),
('delivery_order_cancelled_alert', 'ja',
  '{order_number}番のデリバリー注文がキャンセルされました'),
('delivery_order_cancelled_alert', 'vi',
  'Đơn giao #{order_number} đã bị hủy'),
('delivery_order_cancelled_alert', 'th',
  'คำสั่งซื้อเดลิเวอรี่ #{order_number} ถูกยกเลิก')

on conflict (message_key, locale) do nothing;

-- =============================================
-- 메시지 카탈로그 통계 확인
-- =============================================
do $$
declare
  v_total int;
  v_ko int;
  v_en int;
  v_by_locale jsonb;
begin
  select count(*) into v_total
  from catchmenu_common.message_catalog;

  select count(*) into v_ko
  from catchmenu_common.message_catalog
  where locale = 'ko';

  select count(*) into v_en
  from catchmenu_common.message_catalog
  where locale = 'en';

  perform catchmenu_common.log_diagnostic(
    p_tenant_id :=
      '00000000-0000-0000-0000-000000000001'::uuid,
    p_log_level := 'INFO',
    p_log_domain := 'SYSTEM',
    p_log_event := 'message_catalog_seeded',
    p_message :=
      '메시지 카탈로그 시드 완료'
      || ' | 전체=' || v_total
      || ' | ko=' || v_ko
      || ' | en=' || v_en,
    p_rpc_name := '0093_migration',
    p_details := jsonb_build_object(
      'total', v_total,
      'ko', v_ko,
      'en', v_en
    )
  );
end;
$$;

-- =============================================
-- 에러 코드 통계 확인
-- =============================================
do $$
declare
  v_total int;
  v_by_domain jsonb;
begin
  select count(*) into v_total
  from catchmenu_common.error_codes;

  perform catchmenu_common.log_diagnostic(
    p_tenant_id :=
      '00000000-0000-0000-0000-000000000001'::uuid,
    p_log_level := 'INFO',
    p_log_domain := 'SYSTEM',
    p_log_event := 'error_codes_seeded',
    p_message :=
      '에러 코드 시드 완료 | 전체=' || v_total,
    p_rpc_name := '0093_migration',
    p_details := jsonb_build_object(
      'total', v_total
    )
  );
end;
$$;

comment on table catchmenu_common.message_catalog is
  '다국어 메시지 카탈로그.
   지원 로케일: ko/en/zh/ja/vi/th.
   {param} 형식으로 파라미터 치환.
   참조: catchmenu_common.get_message(
     key, locale, params
   ).
   SQL 내 한글 하드코딩 금지.
   jsonb 내 한글 직접 삽입 금지.
   0085 이후 전면 적용.
   0095에서 0001~0084 레거시 하드코딩 일괄 교체.';

comment on table catchmenu_common.error_codes is
  '에러 코드 레지스트리.
   도메인별 번호 대역:
   1xxx: AUTH/세션/디바이스
   2xxx: ORDER/KDS/대기
   3xxx: SYSTEM/SaaS/인프라
   4xxx: PAYMENT/결제/대사
   5xxx: MENU/재고/알레르겐
   6xxx: STAFF/직원/스케줄
   7xxx: STORE/매장설정
   8xxx: KNOWLEDGE/AI/SOP
   9xxx: DELIVERY/배달/외부
   10xxx: AUDIT/감사/증빙
   11xxx: FRANCHISE/프랜차이즈
   안정적 Unix-like 코드.
   grep-friendly: error_key로 로그 검색.
   sop_runbook_code: 연결된 SOP 코드.';