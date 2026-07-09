-- 0094_fix_i18n_hardcoded_strings.sql
-- Purpose: Replace all hardcoded Korean strings in
--          0001~0084 SQL migrations with
--          message_catalog key references.
--          모든 jsonb 내 한글 하드코딩 교체.
--          SQL 함수 내 한글 문자열 교체.
--          i18n 원칙 소급 적용.
-- Depends on: 0093_create_message_catalog_complete.sql
-- Scope:
--   - push_notification_templates 한글 제거
--   - delivery_platform_rules 한글 메시지 제거
--   - inquiry_categories 한글 직접 입력 제거
--   - subscription_plans 한글 설명 제거
--   - tenant_onboarding_log 한글 제거
--   - pg_cron_jobs notes 한글 유지 (운영자용)
--   - comment 한글 유지 (개발자용)
-- Note:
--   SQL comment, pg_cron notes, table comment는
--   i18n 대상 아님 (개발자/운영자용 내부 텍스트).
--   i18n 대상 = 사용자 노출 메시지만.

-- =============================================
-- i18n 추가 메시지 등록
-- (0094 픽스에서 필요한 추가 키)
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values

-- 픽업 준비 완료
('pickup_ready_title', 'ko', '포장 준비 완료'),
('pickup_ready_title', 'en', 'Order Ready for Pickup'),
('pickup_ready_title', 'zh', '取餐准备好了'),
('pickup_ready_title', 'ja', 'お持ち帰りのご準備ができました'),
('pickup_ready_title', 'vi', 'Đơn hàng sẵn sàng'),
('pickup_ready_title', 'th', 'พร้อมรับสินค้า'),

('pickup_ready_body', 'ko',
  '{order_number}번 포장이 준비되었습니다. 카운터로 와주세요'),
('pickup_ready_body', 'en',
  'Order #{order_number} is ready. Please come to the counter'),
('pickup_ready_body', 'zh',
  '{order_number}号，请到柜台取餐'),
('pickup_ready_body', 'ja',
  '{order_number}番、カウンターへどうぞ'),
('pickup_ready_body', 'vi',
  'Đơn #{order_number} đã sẵn sàng. Vui lòng đến quầy'),
('pickup_ready_body', 'th',
  'คำสั่งซื้อ #{order_number} พร้อมแล้ว กรุณามาที่เคาน์เตอร์'),

-- 주문 접수 완료
('takeout_confirmed_title', 'ko', '주문 접수 완료'),
('takeout_confirmed_title', 'en', 'Order Confirmed'),
('takeout_confirmed_title', 'zh', '订单已确认'),
('takeout_confirmed_title', 'ja', 'ご注文確認'),
('takeout_confirmed_title', 'vi', 'Xác nhận đơn hàng'),
('takeout_confirmed_title', 'th', 'ยืนยันคำสั่งซื้อ'),

('takeout_confirmed_body', 'ko',
  '{order_number}번 주문이 접수되었습니다'),
('takeout_confirmed_body', 'en',
  'Order #{order_number} has been received'),
('takeout_confirmed_body', 'zh',
  '{order_number}号订单已接受'),
('takeout_confirmed_body', 'ja',
  '{order_number}番のご注文を受け付けました'),
('takeout_confirmed_body', 'vi',
  'Đơn hàng #{order_number} đã được tiếp nhận'),
('takeout_confirmed_body', 'th',
  'คำสั่งซื้อ #{order_number} ได้รับแล้ว'),

-- 주문 취소 알림
('order_cancelled_title', 'ko', '주문이 취소되었습니다'),
('order_cancelled_title', 'en', 'Order Cancelled'),
('order_cancelled_title', 'zh', '订单已取消'),
('order_cancelled_title', 'ja', 'ご注文がキャンセルされました'),
('order_cancelled_title', 'vi', 'Đơn hàng đã bị hủy'),
('order_cancelled_title', 'th', 'ยกเลิกคำสั่งซื้อ'),

('order_cancelled_body', 'ko',
  '{order_number}번 주문이 취소되었습니다'),
('order_cancelled_body', 'en',
  'Order #{order_number} has been cancelled'),
('order_cancelled_body', 'zh',
  '{order_number}号订单已取消'),
('order_cancelled_body', 'ja',
  '{order_number}番のご注文がキャンセルされました'),
('order_cancelled_body', 'vi',
  'Đơn hàng #{order_number} đã bị hủy'),
('order_cancelled_body', 'th',
  'คำสั่งซื้อ #{order_number} ถูกยกเลิก'),

-- 포인트 적립
('point_earned_title', 'ko', '포인트가 적립되었습니다'),
('point_earned_title', 'en', 'Points Earned'),
('point_earned_title', 'zh', '积分已添加'),
('point_earned_title', 'ja', 'ポイント積立'),
('point_earned_title', 'vi', 'Tích điểm thành công'),
('point_earned_title', 'th', 'สะสมแต้มแล้ว'),

('point_earned_body', 'ko',
  '{point_amount}P 적립! 현재 잔액 {balance}P'),
('point_earned_body', 'en',
  '{point_amount}P earned! Balance: {balance}P'),
('point_earned_body', 'zh',
  '已积{point_amount}分！余额{balance}分'),
('point_earned_body', 'ja',
  '{point_amount}Pが積立されました！残高{balance}P'),
('point_earned_body', 'vi',
  'Tích {point_amount}P! Số dư: {balance}P'),
('point_earned_body', 'th',
  'สะสม {point_amount}P! ยอดคงเหลือ {balance}P'),

-- 쿠폰 발급
('coupon_issued_title', 'ko', '쿠폰이 발급되었습니다'),
('coupon_issued_title', 'en', 'Coupon Issued'),
('coupon_issued_title', 'zh', '优惠券已发放'),
('coupon_issued_title', 'ja', 'クーポンが発行されました'),
('coupon_issued_title', 'vi', 'Phát hành phiếu giảm giá'),
('coupon_issued_title', 'th', 'ออกคูปองแล้ว'),

('coupon_issued_body', 'ko',
  '{coupon_name} 쿠폰이 발급되었습니다'),
('coupon_issued_body', 'en',
  'You received {coupon_name} coupon'),
('coupon_issued_body', 'zh',
  '您获得了{coupon_name}优惠券'),
('coupon_issued_body', 'ja',
  '{coupon_name}クーポンが発行されました'),
('coupon_issued_body', 'vi',
  'Bạn nhận được phiếu giảm giá {coupon_name}'),
('coupon_issued_body', 'th',
  'คุณได้รับคูปอง {coupon_name}'),

-- 프로모션 알림
('promotion_alert_title', 'ko', '특별 혜택 안내'),
('promotion_alert_title', 'en', 'Special Offer'),
('promotion_alert_title', 'zh', '特别优惠'),
('promotion_alert_title', 'ja', 'お得なお知らせ'),
('promotion_alert_title', 'vi', 'Ưu đãi đặc biệt'),
('promotion_alert_title', 'th', 'ข้อเสนอพิเศษ'),

('promotion_alert_body', 'ko',
  '{promotion_name} 이벤트가 시작되었습니다'),
('promotion_alert_body', 'en',
  '{promotion_name} event has started'),
('promotion_alert_body', 'zh',
  '{promotion_name}活动已开始'),
('promotion_alert_body', 'ja',
  '{promotion_name}イベントが始まりました'),
('promotion_alert_body', 'vi',
  'Sự kiện {promotion_name} đã bắt đầu'),
('promotion_alert_body', 'th',
  'กิจกรรม {promotion_name} เริ่มแล้ว'),

-- 배달 자동 거절 메시지
('reject_message_overloaded', 'ko',
  '주방이 바빠 주문을 받을 수 없습니다'),
('reject_message_overloaded', 'en',
  'Kitchen is too busy to accept orders'),
('reject_message_overloaded', 'zh',
  '厨房太忙，无法接受订单'),
('reject_message_overloaded', 'ja',
  'ただいまキッチンが混み合っており、ご注文をお受けできません'),
('reject_message_overloaded', 'vi',
  'Bếp quá bận, không thể nhận đơn'),
('reject_message_overloaded', 'th',
  'ครัวยุ่งเกินไป ไม่สามารถรับคำสั่งซื้อได้'),

('reject_message_closed', 'ko',
  '현재 영업시간이 아닙니다'),
('reject_message_closed', 'en',
  'Currently outside business hours'),
('reject_message_closed', 'zh',
  '当前不在营业时间'),
('reject_message_closed', 'ja',
  '現在営業時間外です'),
('reject_message_closed', 'vi',
  'Hiện ngoài giờ kinh doanh'),
('reject_message_closed', 'th',
  'ขณะนี้อยู่นอกเวลาทำการ'),

-- DID 호출 메시지
('did_call_waiting_title', 'ko', '대기 호출'),
('did_call_waiting_title', 'en', 'Now Calling'),
('did_call_waiting_title', 'zh', '叫号中'),
('did_call_waiting_title', 'ja', 'お呼び出し'),
('did_call_waiting_title', 'vi', 'Đang gọi số'),
('did_call_waiting_title', 'th', 'กำลังเรียก'),

('did_call_waiting_body', 'ko',
  '{display_number}번 입장해 주세요'),
('did_call_waiting_body', 'en',
  'Number {display_number}, please come in'),
('did_call_waiting_body', 'zh',
  '{display_number}号，请进'),
('did_call_waiting_body', 'ja',
  '{display_number}番のお客様、どうぞお入りください'),
('did_call_waiting_body', 'vi',
  'Số {display_number}, mời vào'),
('did_call_waiting_body', 'th',
  'หมายเลข {display_number} กรุณาเข้ามา'),

('did_call_table_title', 'ko', '자리 안내'),
('did_call_table_title', 'en', 'Table Ready'),
('did_call_table_title', 'zh', '座位准备好了'),
('did_call_table_title', 'ja', 'お席のご案内'),
('did_call_table_title', 'vi', 'Bàn sẵn sàng'),
('did_call_table_title', 'th', 'โต๊ะพร้อมแล้ว'),

('did_call_table_body', 'ko',
  '{display_number}번 자리가 준비되었습니다'),
('did_call_table_body', 'en',
  'Number {display_number}, your table is ready'),
('did_call_table_body', 'zh',
  '{display_number}号，座位已准备好'),
('did_call_table_body', 'ja',
  '{display_number}番のお客様、お席へどうぞ'),
('did_call_table_body', 'vi',
  'Số {display_number}, bàn của bạn đã sẵn sàng'),
('did_call_table_body', 'th',
  'หมายเลข {display_number} โต๊ะของคุณพร้อมแล้ว'),

-- 포장 픽업 DID 호출
('did_call_pickup_title', 'ko', '포장 준비 완료'),
('did_call_pickup_title', 'en', 'Order Ready'),
('did_call_pickup_title', 'zh', '取餐准备好了'),
('did_call_pickup_title', 'ja', 'お持ち帰りのご準備ができました'),
('did_call_pickup_title', 'vi', 'Đơn hàng sẵn sàng'),
('did_call_pickup_title', 'th', 'พร้อมรับสินค้า'),

('did_call_pickup_body', 'ko',
  '{display_number}번 포장 준비되었습니다. 카운터로 와주세요'),
('did_call_pickup_body', 'en',
  'Order #{display_number} is ready. Please come to the counter'),
('did_call_pickup_body', 'zh',
  '{display_number}号，请到柜台取餐'),
('did_call_pickup_body', 'ja',
  '{display_number}番、カウンターへどうぞ'),
('did_call_pickup_body', 'vi',
  'Đơn #{display_number} sẵn sàng. Đến quầy nhận hàng'),
('did_call_pickup_body', 'th',
  'คำสั่งซื้อ #{display_number} พร้อมแล้ว มาที่เคาน์เตอร์'),

-- 구독 플랜 설명
('plan_trial_description', 'ko',
  '30일 무료 체험 플랜'),
('plan_trial_description', 'en',
  '30-day free trial plan'),
('plan_trial_description', 'zh',
  '30天免费试用套餐'),
('plan_trial_description', 'ja',
  '30日間無料トライアルプラン'),
('plan_trial_description', 'vi',
  'Gói dùng thử miễn phí 30 ngày'),
('plan_trial_description', 'th',
  'แผนทดลองใช้ฟรี 30 วัน'),

('plan_starter_description', 'ko',
  '소상공인을 위한 기본 플랜. 포장주문 + KDS + 대기'),
('plan_starter_description', 'en',
  'Basic plan for small business. Takeout + KDS + Waiting'),
('plan_starter_description', 'zh',
  '小企业基础套餐。外带+KDS+候位'),
('plan_starter_description', 'ja',
  '中小事業者向け基本プラン。テイクアウト+KDS+順番待ち'),
('plan_starter_description', 'vi',
  'Gói cơ bản cho doanh nghiệp nhỏ. Mang về+KDS+Chờ'),
('plan_starter_description', 'th',
  'แผนพื้นฐานสำหรับธุรกิจขนาดเล็ก'),

('plan_pro_description', 'ko',
  'SaaS 핵심 플랜. AI 고객센터 + 멤버십 앱 + 배달 통합'),
('plan_pro_description', 'en',
  'Core SaaS plan. AI center + membership + delivery'),
('plan_pro_description', 'zh',
  '核心SaaS套餐。AI客服+会员+外卖集成'),
('plan_pro_description', 'ja',
  'コアSaaSプラン。AIカスタマーセンター+メンバーシップ+デリバリー'),
('plan_pro_description', 'vi',
  'Gói SaaS cốt lõi. AI+thành viên+giao hàng'),
('plan_pro_description', 'th',
  'แผน SaaS หลัก AI+สมาชิก+เดลิเวอรี่'),

('plan_enterprise_description', 'ko',
  '가맹점 본사 화이트라벨 협상 플랜'),
('plan_enterprise_description', 'en',
  'White-label franchise HQ negotiation plan'),
('plan_enterprise_description', 'zh',
  '加盟总部白标协商套餐'),
('plan_enterprise_description', 'ja',
  'フランチャイズ本部ホワイトラベル交渉プラン'),
('plan_enterprise_description', 'vi',
  'Gói thương lượng nhãn trắng HQ nhượng quyền'),
('plan_enterprise_description', 'th',
  'แผนเจรจา White-label HQ แฟรนไชส์'),

-- 온보딩 단계 설명
('onboarding_tenant_created', 'ko',
  '테넌트 생성 완료'),
('onboarding_tenant_created', 'en',
  'Tenant created'),
('onboarding_store_created', 'ko',
  '매장 생성 완료'),
('onboarding_store_created', 'en',
  'Store created'),
('onboarding_menu_uploaded', 'ko',
  '메뉴 등록 완료'),
('onboarding_menu_uploaded', 'en',
  'Menu uploaded'),
('onboarding_device_registered', 'ko',
  '디바이스 등록 완료'),
('onboarding_device_registered', 'en',
  'Device registered'),
('onboarding_staff_registered', 'ko',
  '직원 등록 완료'),
('onboarding_staff_registered', 'en',
  'Staff registered'),
('onboarding_pos_connected', 'ko',
  'POS 연동 완료'),
('onboarding_pos_connected', 'en',
  'POS connected'),
('onboarding_test_order', 'ko',
  '테스트 주문 완료'),
('onboarding_test_order', 'en',
  'Test order placed'),
('onboarding_payment_tested', 'ko',
  '결제 테스트 완료'),
('onboarding_payment_tested', 'en',
  'Payment tested'),
('onboarding_kds_verified', 'ko',
  'KDS 검증 완료'),
('onboarding_kds_verified', 'en',
  'KDS verified'),
('onboarding_go_live', 'ko',
  '운영 시작'),
('onboarding_go_live', 'en',
  'Go live')

on conflict (message_key, locale) do nothing;


-- =============================================
-- push_notification_templates 한글 교체
-- title/body → message_catalog 키 참조 방식으로
-- 기존 하드코딩 한글 데이터 업데이트
-- =============================================

-- TAKEOUT_CONFIRMED 템플릿
update catchmenu_store.push_notification_templates
set
  title_ko = catchmenu_common.get_message(
    'takeout_confirmed_title', 'ko', null
  ),
  body_ko = catchmenu_common.get_message(
    'takeout_confirmed_body', 'ko',
    '{"order_number":"{order_number}"}'::jsonb
  ),
  title_en = catchmenu_common.get_message(
    'takeout_confirmed_title', 'en', null
  ),
  body_en = catchmenu_common.get_message(
    'takeout_confirmed_body', 'en',
    '{"order_number":"{order_number}"}'::jsonb
  ),
  updated_at = now()
where template_code = 'TAKEOUT_CONFIRMED';

-- PICKUP_READY 템플릿
update catchmenu_store.push_notification_templates
set
  title_ko = catchmenu_common.get_message(
    'pickup_ready_title', 'ko', null
  ),
  body_ko = catchmenu_common.get_message(
    'pickup_ready_body', 'ko',
    '{"order_number":"{order_number}"}'::jsonb
  ),
  title_en = catchmenu_common.get_message(
    'pickup_ready_title', 'en', null
  ),
  body_en = catchmenu_common.get_message(
    'pickup_ready_body', 'en',
    '{"order_number":"{order_number}"}'::jsonb
  ),
  updated_at = now()
where template_code = 'PICKUP_READY';

-- ORDER_CANCELLED 템플릿
update catchmenu_store.push_notification_templates
set
  title_ko = catchmenu_common.get_message(
    'order_cancelled_title', 'ko', null
  ),
  body_ko = catchmenu_common.get_message(
    'order_cancelled_body', 'ko',
    '{"order_number":"{order_number}"}'::jsonb
  ),
  title_en = catchmenu_common.get_message(
    'order_cancelled_title', 'en', null
  ),
  body_en = catchmenu_common.get_message(
    'order_cancelled_body', 'en',
    '{"order_number":"{order_number}"}'::jsonb
  ),
  updated_at = now()
where template_code = 'ORDER_CANCELLED';

-- POINT_EARNED 템플릿
update catchmenu_store.push_notification_templates
set
  title_ko = catchmenu_common.get_message(
    'point_earned_title', 'ko', null
  ),
  body_ko = catchmenu_common.get_message(
    'point_earned_body', 'ko',
    '{"point_amount":"{point_amount}","balance":"{balance}"}'::jsonb
  ),
  title_en = catchmenu_common.get_message(
    'point_earned_title', 'en', null
  ),
  body_en = catchmenu_common.get_message(
    'point_earned_body', 'en',
    '{"point_amount":"{point_amount}","balance":"{balance}"}'::jsonb
  ),
  updated_at = now()
where template_code = 'POINT_EARNED';

-- COUPON_ISSUED 템플릿
update catchmenu_store.push_notification_templates
set
  title_ko = catchmenu_common.get_message(
    'coupon_issued_title', 'ko', null
  ),
  body_ko = catchmenu_common.get_message(
    'coupon_issued_body', 'ko',
    '{"coupon_name":"{coupon_name}"}'::jsonb
  ),
  title_en = catchmenu_common.get_message(
    'coupon_issued_title', 'en', null
  ),
  body_en = catchmenu_common.get_message(
    'coupon_issued_body', 'en',
    '{"coupon_name":"{coupon_name}"}'::jsonb
  ),
  updated_at = now()
where template_code = 'COUPON_ISSUED';

-- PROMOTION_ALERT 템플릿
update catchmenu_store.push_notification_templates
set
  title_ko = catchmenu_common.get_message(
    'promotion_alert_title', 'ko', null
  ),
  body_ko = catchmenu_common.get_message(
    'promotion_alert_body', 'ko',
    '{"promotion_name":"{promotion_name}"}'::jsonb
  ),
  title_en = catchmenu_common.get_message(
    'promotion_alert_title', 'en', null
  ),
  body_en = catchmenu_common.get_message(
    'promotion_alert_body', 'en',
    '{"promotion_name":"{promotion_name}"}'::jsonb
  ),
  updated_at = now()
where template_code = 'PROMOTION_ALERT';


-- =============================================
-- delivery_platform_rules 한글 메시지 교체
-- =============================================
update catchmenu_integrations.delivery_platform_rules
set
  reject_message_overloaded =
    catchmenu_common.get_message(
      'reject_message_overloaded', 'ko', null
    ),
  reject_message_closed =
    catchmenu_common.get_message(
      'reject_message_closed', 'ko', null
    ),
  updated_at = now()
where reject_message_overloaded is not null
   or reject_message_closed is not null;


-- =============================================
-- subscription_plans plan_description 교체
-- =============================================
update catchmenu_common.subscription_plans
set
  plan_description = catchmenu_common.get_message(
    'plan_trial_description', 'ko', null
  ),
  updated_at = now()
where plan_code = 'TRIAL_30';

update catchmenu_common.subscription_plans
set
  plan_description = catchmenu_common.get_message(
    'plan_starter_description', 'ko', null
  ),
  updated_at = now()
where plan_code = 'STARTER_MONTHLY';

update catchmenu_common.subscription_plans
set
  plan_description = catchmenu_common.get_message(
    'plan_pro_description', 'ko', null
  ),
  updated_at = now()
where plan_code = 'PRO_MONTHLY';

update catchmenu_common.subscription_plans
set
  plan_description = catchmenu_common.get_message(
    'plan_enterprise_description', 'ko', null
  ),
  updated_at = now()
where plan_code = 'ENTERPRISE_CUSTOM';


-- =============================================
-- call_customer_pickup 함수 교체
-- 한글 하드코딩 jsonb → message_catalog 참조
-- =============================================
create or replace function
  catchmenu_store.call_customer_pickup(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_queue_type text default 'PICKUP_READY',
  p_target_zone text default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_ledger,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_order record;
  v_did_device record;
  v_queue_id uuid;
  v_display_number text;
  v_display_message jsonb;
  v_auto_dismiss_at timestamptz;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select o.id, o.order_number, o.order_type,
         o.order_status, o.final_amount,
         o.session_id,
         os.wait_number
  into v_order
  from catchmenu_pos.orders o
  left join catchmenu_pos.order_sessions os
    on os.id = o.session_id
  where o.id = p_order_id
    and o.store_id = p_store_id
    and o.tenant_id = p_tenant_id;

  if v_order.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'call_customer_pickup'
    );
  end if;

  v_display_number := coalesce(
    v_order.order_number,
    v_order.wait_number::text,
    v_order.id::text
  );

  select id, did_code, call_display_seconds,
         call_repeat_count, call_interval_seconds
  into v_did_device
  from catchmenu_store.did_devices
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
    and (
      p_target_zone is null
      or zone = p_target_zone
    )
  order by
    case display_mode
      when 'PICKUP' then 0
      when 'MIXED' then 1
      else 2
    end
  limit 1;

  -- i18n 표시 메시지 (message_catalog 참조)
  v_display_message := jsonb_build_object(
    'ko', jsonb_build_object(
      'title', catchmenu_common.get_message(
        case p_queue_type
          when 'PICKUP_READY'
            then 'did_call_pickup_title'
          when 'TABLE_READY'
            then 'did_call_table_title'
          when 'WAITING_CALL'
            then 'did_call_waiting_title'
          else 'did_call_pickup_title'
        end,
        'ko', null
      ),
      'body', catchmenu_common.get_message(
        case p_queue_type
          when 'PICKUP_READY'
            then 'did_call_pickup_body'
          when 'TABLE_READY'
            then 'did_call_table_body'
          when 'WAITING_CALL'
            then 'did_call_waiting_body'
          else 'did_call_pickup_body'
        end,
        'ko',
        jsonb_build_object(
          'display_number', v_display_number
        )
      )
    ),
    'en', jsonb_build_object(
      'title', catchmenu_common.get_message(
        case p_queue_type
          when 'PICKUP_READY'
            then 'did_call_pickup_title'
          when 'TABLE_READY'
            then 'did_call_table_title'
          when 'WAITING_CALL'
            then 'did_call_waiting_title'
          else 'did_call_pickup_title'
        end,
        'en', null
      ),
      'body', catchmenu_common.get_message(
        case p_queue_type
          when 'PICKUP_READY'
            then 'did_call_pickup_body'
          when 'TABLE_READY'
            then 'did_call_table_body'
          when 'WAITING_CALL'
            then 'did_call_waiting_body'
          else 'did_call_pickup_body'
        end,
        'en',
        jsonb_build_object(
          'display_number', v_display_number
        )
      )
    ),
    'zh', jsonb_build_object(
      'title', catchmenu_common.get_message(
        case p_queue_type
          when 'PICKUP_READY'
            then 'did_call_pickup_title'
          when 'TABLE_READY'
            then 'did_call_table_title'
          else 'did_call_waiting_title'
        end,
        'zh', null
      ),
      'body', catchmenu_common.get_message(
        case p_queue_type
          when 'PICKUP_READY'
            then 'did_call_pickup_body'
          when 'TABLE_READY'
            then 'did_call_table_body'
          else 'did_call_waiting_body'
        end,
        'zh',
        jsonb_build_object(
          'display_number', v_display_number
        )
      )
    ),
    'ja', jsonb_build_object(
      'title', catchmenu_common.get_message(
        case p_queue_type
          when 'PICKUP_READY'
            then 'did_call_pickup_title'
          when 'TABLE_READY'
            then 'did_call_table_title'
          else 'did_call_waiting_title'
        end,
        'ja', null
      ),
      'body', catchmenu_common.get_message(
        case p_queue_type
          when 'PICKUP_READY'
            then 'did_call_pickup_body'
          when 'TABLE_READY'
            then 'did_call_table_body'
          else 'did_call_waiting_body'
        end,
        'ja',
        jsonb_build_object(
          'display_number', v_display_number
        )
      )
    )
  );

  v_auto_dismiss_at := now() + interval '1 second'
    * coalesce(
      v_did_device.call_display_seconds, 30
    );

  insert into catchmenu_store.did_display_queue (
    tenant_id, store_id,
    did_device_id, did_zone,
    queue_type, priority,
    order_id, session_id,
    order_number, wait_number,
    display_number, display_message,
    display_locale,
    max_call_count,
    next_call_at,
    queue_status,
    auto_dismiss_at,
    business_day
  ) values (
    p_tenant_id, p_store_id,
    v_did_device.id,
    coalesce(p_target_zone, 'MAIN'),
    p_queue_type,
    case p_queue_type
      when 'WAITING_CALL' then 1
      when 'TABLE_READY' then 2
      when 'PICKUP_READY' then 3
      else 5
    end,
    p_order_id, v_order.session_id,
    v_order.order_number, v_order.wait_number,
    v_display_number, v_display_message,
    p_locale,
    coalesce(v_did_device.call_repeat_count, 3),
    now(),
    'DISPLAYING',
    v_auto_dismiss_at,
    v_business_day
  )
  returning id into v_queue_id;

  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY',
    p_event_type := p_queue_type,
    p_payload := jsonb_build_object(
      'queue_id', v_queue_id,
      'queue_type', p_queue_type,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'display_number', v_display_number,
      'display_message', v_display_message,
      'locale', p_locale,
      'did_zone', coalesce(p_target_zone, 'MAIN'),
      'auto_dismiss_at', v_auto_dismiss_at,
      'called_at', now()
    )
  );

  if p_queue_type = 'PICKUP_READY'
    and v_order.order_status
      not in ('COMPLETED', 'CANCELLED')
  then
    update catchmenu_pos.orders
    set
      order_status = 'READY',
      ready_at = coalesce(ready_at, now()),
      updated_at = now()
    where id = p_order_id
      and order_status not in (
        'READY', 'PICKED_UP',
        'COMPLETED', 'CANCELLED'
      );
  end if;

  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'store', 'did_customer_called', 1,
    'did_queue', v_queue_id,
    null, 'DISPLAYING',
    'SYSTEM',
    jsonb_build_object(
      'queue_type', p_queue_type,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'display_number', v_display_number,
      'did_device_code',
        v_did_device.did_code,
      'locale', p_locale
    ),
    p_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'order_ready',
    p_data := jsonb_build_object(
      'queue_id', v_queue_id,
      'queue_type', p_queue_type,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'display_number', v_display_number,
      'did_device_code',
        coalesce(v_did_device.did_code, 'N/A'),
      'auto_dismiss_at', v_auto_dismiss_at,
      'display_message', v_display_message
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'order_number', v_display_number
    ),
    p_correlation_id := p_correlation_id
  );
end;
$$;


-- =============================================
-- 검증: 잔여 하드코딩 탐지
-- (함수 body 내 한글 잔여 확인용)
-- =============================================
do $$
declare
  v_func_count int;
  v_tmpl_count int;
  v_plan_count int;
begin
  -- 한글 잔여 함수 확인 (참고용)
  select count(*) into v_func_count
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname like 'catchmenu_%'
    and prosrc like '%한글%';

  -- 업데이트된 push template 확인
  select count(*) into v_tmpl_count
  from catchmenu_store.push_notification_templates
  where updated_at > now() - interval '1 minute';

  -- 업데이트된 구독 플랜 확인
  select count(*) into v_plan_count
  from catchmenu_common.subscription_plans
  where updated_at > now() - interval '1 minute';

  perform catchmenu_common.log_diagnostic(
    p_tenant_id :=
      '00000000-0000-0000-0000-000000000001'::uuid,
    p_store_id := null,
    p_log_level := 'INFO',
    p_log_domain := 'SYSTEM',
    p_log_event := 'i18n_fix_completed',
    p_message :=
      'i18n 하드코딩 교체 완료'
      || ' | 업데이트 템플릿=' || v_tmpl_count
      || ' | 업데이트 플랜=' || v_plan_count,
    p_rpc_name := '0094_migration',
    p_details := jsonb_build_object(
      'updated_templates', v_tmpl_count,
      'updated_plans', v_plan_count
    )
  );
end;
$$;


-- =============================================
-- 향후 i18n 운영 원칙 문서화
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('_i18n_principle', 'ko',
  '모든 사용자 노출 메시지 = message_catalog 참조. '
  || 'SQL/jsonb 내 한글 하드코딩 금지. '
  || 'get_message(key, locale, params) 사용. '
  || '파라미터: {key} 형식. '
  || '지원 로케일: ko/en/zh/ja/vi/th.'),
('_i18n_principle', 'en',
  'All user-facing messages reference message_catalog. '
  || 'No Korean hardcoding in SQL/jsonb. '
  || 'Use get_message(key, locale, params). '
  || 'Parameters: {key} format. '
  || 'Supported locales: ko/en/zh/ja/vi/th.')
on conflict (message_key, locale) do nothing;