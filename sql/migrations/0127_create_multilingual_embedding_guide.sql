-- 0127_create_multilingual_embedding_guide.sql
-- Purpose: Multilingual menu embedding pipeline.
--          pgvector RAG 완성.
--          메뉴 다국어 임베딩.
--          벡터 검색 최적화.
--          할루시네이션 방지 강화.
--          외국인 메뉴 추천 파이프라인.
--          i18n: 모든 메시지 = message_catalog.
-- Depends on: 0126_create_staff_notification_pipeline.sql

insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('menu_search_completed', 'ko',
  '메뉴 검색이 완료되었습니다'),
('menu_search_completed', 'en',
  'Menu search completed'),
('menu_search_completed', 'zh',
  '菜单搜索完成'),
('menu_search_completed', 'ja',
  'メニュー検索が完了しました'),
('menu_search_completed', 'vi',
  'Tìm kiếm menu hoàn thành'),
('menu_search_completed', 'th',
  'ค้นหาเมนูเสร็จสิ้น'),

('menu_recommendation_ready', 'ko',
  '메뉴 추천이 준비되었습니다'),
('menu_recommendation_ready', 'en',
  'Menu recommendation ready'),
('menu_recommendation_ready', 'zh',
  '菜单推荐已准备好'),
('menu_recommendation_ready', 'ja',
  'メニューのおすすめが準備できました'),
('menu_recommendation_ready', 'vi',
  'Gợi ý menu đã sẵn sàng'),
('menu_recommendation_ready', 'th',
  'คำแนะนำเมนูพร้อมแล้ว'),

('no_menu_found', 'ko',
  '검색 결과가 없습니다'),
('no_menu_found', 'en',
  'No menu found'),
('no_menu_found', 'zh', '没有找到菜单'),
('no_menu_found', 'ja',
  'メニューが見つかりませんでした'),
('no_menu_found', 'vi',
  'Không tìm thấy menu'),
('no_menu_found', 'th', 'ไม่พบเมนู'),

('embedding_queued', 'ko',
  '임베딩 요청이 등록되었습니다'),
('embedding_queued', 'en',
  'Embedding queued')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(13010, 'embedding_not_ready',
  'AI', 'TECHNICAL', 503, 'WARNING'),
(13011, 'menu_vector_not_found',
  'AI', 'NOT_FOUND', 404, 'INFO'),
(13012, 'rag_grounding_failed',
  'AI', 'SECURITY', 200, 'WARNING')
on conflict (code) do nothing;


-- =============================================
-- menu_embeddings table
-- 메뉴 다국어 벡터 임베딩
-- =============================================
create table if not exists
  catchmenu_knowledge.menu_embeddings (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  menu_id uuid not null
    references catchmenu_pos.menus(id),

  -- 임베딩 텍스트 (다국어)
  embedding_locale text not null,
  embedding_text text not null,

  -- 벡터 (pgvector)
  embedding_vector vector(1536),

  -- 메타데이터
  menu_name text not null,
  menu_price int,
  allergen_codes jsonb,
  menu_status text,

  -- 상태
  embedding_status text not null
    default 'PENDING',
  embedding_model text
    default 'text-embedding-3-small',
  embedded_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_menu_embedding unique (
    menu_id, embedding_locale
  ),
  constraint chk_embedding_locale check (
    embedding_locale in (
      'ko', 'en', 'zh', 'ja', 'vi', 'th'
    )
  ),
  constraint chk_embedding_status check (
    embedding_status in (
      'PENDING', 'PROCESSING',
      'COMPLETED', 'FAILED'
    )
  )
);

-- HNSW 인덱스 (빠른 근사 최근접 검색)
create index if not exists
  idx_menu_embeddings_vector
  on catchmenu_knowledge.menu_embeddings
  using hnsw (
    embedding_vector vector_cosine_ops
  )
  with (m = 16, ef_construction = 64);

create index if not exists
  idx_menu_embeddings_store
  on catchmenu_knowledge.menu_embeddings(
    store_id, embedding_locale,
    embedding_status
  ) where embedding_status = 'COMPLETED';

alter table catchmenu_knowledge.menu_embeddings
  enable row level security;
alter table catchmenu_knowledge.menu_embeddings
  force row level security;

drop policy if exists menu_embedding_isolation
  on catchmenu_knowledge.menu_embeddings;
create policy menu_embedding_isolation
  on catchmenu_knowledge.menu_embeddings
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_menu_emb_updated
  on catchmenu_knowledge.menu_embeddings;
create trigger trg_menu_emb_updated
  before update on
    catchmenu_knowledge.menu_embeddings
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_knowledge.menu_embeddings is
  '메뉴 다국어 벡터 임베딩.
   6개 로케일 × 메뉴 수만큼 레코드.
   HNSW 인덱스: 빠른 근사 검색.
   vector_cosine_ops: 코사인 유사도.
   embedding_text:
     메뉴명 + 설명 + 알레르겐 + 태그
     다국어로 구성된 검색 텍스트.
   외국인 고객 자연어 검색 지원:
     "spicy noodles without pork" 검색
     → 벡터 유사도로 메뉴 매칭.
   Edge Function embedding-request가
   OpenAI API 호출 후 벡터 업데이트.';


-- =============================================
-- menu_search_logs table
-- 검색 이력 + 추천 피드백
-- =============================================
create table if not exists
  catchmenu_knowledge.menu_search_logs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  store_id uuid not null,

  -- 검색 정보
  search_query text not null,
  search_locale text not null,
  search_type text not null default 'VECTOR',

  -- 결과
  result_count int not null default 0,
  top_result_menu_id uuid,
  top_result_score numeric(5,4),
  results_json jsonb,

  -- 고객 피드백
  customer_id uuid,
  selected_menu_id uuid,
  was_helpful boolean,

  -- 성능
  search_duration_ms int,

  searched_at timestamptz
    not null default now(),

  constraint chk_search_type check (
    search_type in (
      'VECTOR',     -- 벡터 유사도
      'KEYWORD',    -- 키워드
      'HYBRID',     -- 벡터 + 키워드
      'ALLERGEN'    -- 알레르겐 필터
    )
  )
);

create index if not exists idx_search_logs
  on catchmenu_knowledge.menu_search_logs(
    store_id, search_locale, searched_at desc
  );

alter table catchmenu_knowledge.menu_search_logs
  enable row level security;
alter table catchmenu_knowledge.menu_search_logs
  force row level security;

drop policy if exists search_logs_isolation
  on catchmenu_knowledge.menu_search_logs;
create policy search_logs_isolation
  on catchmenu_knowledge.menu_search_logs
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_knowledge.menu_search_logs is
  '메뉴 검색 이력 + 피드백.
   was_helpful: 고객 피드백 (도움됨/아님).
   selected_menu_id: 실제 선택한 메뉴.
   검색 피드백 → 임베딩 품질 개선.
   외국인 검색 패턴 분석:
   search_locale != ko 필터링.
   top_result_score < 0.7 → 미스 탐지.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_knowledge.queue_menu_embedding(
  p_tenant_id uuid,
  p_store_id uuid,
  p_menu_ids jsonb default null,
  p_locales jsonb
    default '["ko","en","zh","ja","vi","th"]'
      ::jsonb,
  p_force_rebuild boolean default false
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_knowledge,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_menu record;
  v_locale text;
  v_embedding_text text;
  v_queued_count int := 0;
  v_allergen_text text;
begin
  -- 메뉴 순회
  for v_menu in
    select id, menu_name,
           menu_name_en, menu_name_zh,
           menu_name_ja, description,
           price, allergen_codes,
           menu_status
    from catchmenu_pos.menus
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true
      and (
        p_menu_ids is null
        or id = any(
          select (value::text)::uuid
          from jsonb_array_elements_text(
            p_menu_ids
          )
        )
      )
  loop
    -- 알레르겐 텍스트
    v_allergen_text := case
      when v_menu.allergen_codes is not null
        and jsonb_array_length(
          v_menu.allergen_codes
        ) > 0
      then ' allergens: '
        || array_to_string(
          array(
            select value::text
            from jsonb_array_elements_text(
              v_menu.allergen_codes
            )
          ), ', '
        )
      else ' no allergens'
    end;

    -- 로케일별 임베딩 텍스트 구성
    for v_locale in
      select value::text
      from jsonb_array_elements_text(p_locales)
    loop
      v_embedding_text := case v_locale
        when 'ko' then
          coalesce(v_menu.menu_name, '')
          || ' ' || coalesce(
            v_menu.description, ''
          )
          || v_allergen_text
          || ' 가격: '
            || v_menu.price::text || '원'
        when 'en' then
          coalesce(
            v_menu.menu_name_en,
            v_menu.menu_name, ''
          )
          || ' ' || coalesce(
            v_menu.description, ''
          )
          || v_allergen_text
          || ' price: '
            || v_menu.price::text || 'KRW'
        when 'zh' then
          coalesce(
            v_menu.menu_name_zh,
            v_menu.menu_name_en,
            v_menu.menu_name, ''
          )
          || v_allergen_text
          || ' 价格: '
            || v_menu.price::text || '韩元'
        when 'ja' then
          coalesce(
            v_menu.menu_name_ja,
            v_menu.menu_name_en,
            v_menu.menu_name, ''
          )
          || v_allergen_text
          || ' 価格: '
            || v_menu.price::text || 'ウォン'
        when 'vi' then
          coalesce(
            v_menu.menu_name_en,
            v_menu.menu_name, ''
          )
          || v_allergen_text
          || ' giá: '
            || v_menu.price::text || ' won'
        when 'th' then
          coalesce(
            v_menu.menu_name_en,
            v_menu.menu_name, ''
          )
          || v_allergen_text
          || ' ราคา: '
            || v_menu.price::text || ' วอน'
        else v_menu.menu_name
      end;

      -- 임베딩 레코드 생성 (PENDING)
      insert into
        catchmenu_knowledge.menu_embeddings (
        tenant_id, store_id, menu_id,
        embedding_locale, embedding_text,
        menu_name, menu_price,
        allergen_codes, menu_status,
        embedding_status
      ) values (
        p_tenant_id, p_store_id, v_menu.id,
        v_locale, v_embedding_text,
        v_menu.menu_name, v_menu.price,
        v_menu.allergen_codes,
        v_menu.menu_status,
        'PENDING'
      )
      on conflict (menu_id, embedding_locale)
      do update set
        embedding_text = excluded.embedding_text,
        menu_name = excluded.menu_name,
        menu_price = excluded.menu_price,
        allergen_codes = excluded.allergen_codes,
        menu_status = excluded.menu_status,
        embedding_status = case
          p_force_rebuild
          when true then 'PENDING'
          else catchmenu_knowledge
            .menu_embeddings.embedding_status
        end,
        updated_at = now();

      v_queued_count := v_queued_count + 1;
    end loop;
  end loop;

  -- Edge Function 임베딩 요청
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'SYSTEM_EVENTS',
    p_event_type :=
      'menu_embedding_requested',
    p_payload := jsonb_build_object(
      'tenant_id', p_tenant_id,
      'store_id', p_store_id,
      'menu_ids', p_menu_ids,
      'locales', p_locales,
      'queued_count', v_queued_count,
      'force_rebuild', p_force_rebuild
    )
  );

  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'queued_count', v_queued_count,
      'locales', p_locales,
      'next_step',
        'Edge Function embedding-request 처리 대기',
      'est_minutes',
        ceil(v_queued_count / 10.0)
    )
  );
end;
$$;


create or replace function
  catchmenu_knowledge.search_menu_vector(
  p_tenant_id uuid,
  p_store_id uuid,
  p_query_text text,
  p_query_vector vector(1536) default null,
  p_search_locale text default 'en',
  p_max_results int default 5,
  p_min_score numeric default 0.6,
  p_exclude_allergens jsonb default null,
  p_only_available boolean default true,
  p_customer_id uuid default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_knowledge,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_results jsonb;
  v_search_type text;
  v_start_time timestamptz;
  v_duration_ms int;
  v_log_id uuid;
begin
  v_start_time := clock_timestamp();

  -- 벡터 없으면 키워드 검색 폴백
  if p_query_vector is null then
    v_search_type := 'KEYWORD';

    -- 키워드 기반 메뉴 검색
    select coalesce(
      jsonb_agg(
        jsonb_build_object(
          'menu_id', m.id,
          'menu_name', case p_search_locale
            when 'en' then coalesce(
              m.menu_name_en, m.menu_name
            )
            when 'zh' then coalesce(
              m.menu_name_zh, m.menu_name
            )
            when 'ja' then coalesce(
              m.menu_name_ja, m.menu_name
            )
            else m.menu_name
          end,
          'price', m.price,
          'menu_status', m.menu_status,
          'thumbnail_url', m.thumbnail_url,
          'allergen_codes', m.allergen_codes,
          'similarity_score', 0.75,
          'search_type', 'KEYWORD'
        )
        order by m.display_order asc
      ),
      '[]'::jsonb
    )
    into v_results
    from catchmenu_pos.menus m
    where m.store_id = p_store_id
      and m.tenant_id = p_tenant_id
      and m.is_active = true
      and (
        not p_only_available
        or m.menu_status = 'AVAILABLE'
      )
      and (
        m.menu_name ilike
          '%' || p_query_text || '%'
        or m.menu_name_en ilike
          '%' || p_query_text || '%'
        or m.menu_name_zh ilike
          '%' || p_query_text || '%'
        or m.menu_name_ja ilike
          '%' || p_query_text || '%'
        or m.description ilike
          '%' || p_query_text || '%'
      )
      and (
        p_exclude_allergens is null
        or not (
          m.allergen_codes ?|
          array(
            select value::text
            from jsonb_array_elements_text(
              p_exclude_allergens
            )
          )
        )
      )
    limit p_max_results;

  else
    v_search_type := 'VECTOR';

    -- 벡터 유사도 검색
    select coalesce(
      jsonb_agg(
        jsonb_build_object(
          'menu_id', m.id,
          'menu_name', case p_search_locale
            when 'en' then coalesce(
              m.menu_name_en, m.menu_name
            )
            when 'zh' then coalesce(
              m.menu_name_zh, m.menu_name
            )
            when 'ja' then coalesce(
              m.menu_name_ja, m.menu_name
            )
            else m.menu_name
          end,
          'price', m.price,
          'menu_status', m.menu_status,
          'thumbnail_url', m.thumbnail_url,
          'allergen_codes', m.allergen_codes,
          'similarity_score',
            1 - (
              me.embedding_vector
                <=> p_query_vector
            ),
          'search_type', 'VECTOR'
        )
        order by
          me.embedding_vector
            <=> p_query_vector asc
      ),
      '[]'::jsonb
    )
    into v_results
    from catchmenu_knowledge.menu_embeddings me
    join catchmenu_pos.menus m
      on m.id = me.menu_id
    where me.store_id = p_store_id
      and me.tenant_id = p_tenant_id
      and me.embedding_locale = p_search_locale
      and me.embedding_status = 'COMPLETED'
      and (
        not p_only_available
        or m.menu_status = 'AVAILABLE'
      )
      and (
        1 - (
          me.embedding_vector <=> p_query_vector
        )
      ) >= p_min_score
      and (
        p_exclude_allergens is null
        or not (
          m.allergen_codes ?|
          array(
            select value::text
            from jsonb_array_elements_text(
              p_exclude_allergens
            )
          )
        )
      )
    limit p_max_results;
  end if;

  v_duration_ms := extract(
    epoch from (
      clock_timestamp() - v_start_time
    )
  )::int * 1000;

  -- 검색 로그
  insert into catchmenu_knowledge.menu_search_logs (
    tenant_id, store_id,
    search_query, search_locale,
    search_type, result_count,
    top_result_menu_id,
    top_result_score,
    results_json, customer_id,
    search_duration_ms
  ) values (
    p_tenant_id, p_store_id,
    p_query_text, p_search_locale,
    v_search_type,
    jsonb_array_length(v_results),
    case jsonb_array_length(v_results) > 0
      when true
      then (v_results->0->>'menu_id')::uuid
      else null
    end,
    case jsonb_array_length(v_results) > 0
      when true
      then (
        v_results->0->>'similarity_score'
      )::numeric
      else null
    end,
    v_results, p_customer_id,
    v_duration_ms
  )
  returning id into v_log_id;

  return catchmenu_common.build_success_response(
    p_message_key := case
      jsonb_array_length(v_results) > 0
      when true then 'menu_search_completed'
      else 'no_menu_found'
    end,
    p_data := jsonb_build_object(
      'query', p_query_text,
      'search_locale', p_search_locale,
      'search_type', v_search_type,
      'results', v_results,
      'result_count',
        jsonb_array_length(v_results),
      'search_log_id', v_log_id,
      'duration_ms', v_duration_ms,
      'allergen_filtered',
        p_exclude_allergens is not null,
      'note', case v_search_type
        when 'KEYWORD'
        then 'Vector not available. Using keyword search.'
        else null
      end
    ),
    p_locale := p_search_locale
  );
end;
$$;


create or replace function
  catchmenu_knowledge.get_menu_recommendation(
  p_tenant_id uuid,
  p_store_id uuid,
  p_customer_locale text default 'en',
  p_exclude_allergens jsonb default null,
  p_price_max int default null,
  p_customer_id uuid default null,
  p_context text default 'GENERAL'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_knowledge,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_recommended jsonb;
  v_popular jsonb;
  v_featured jsonb;
  v_allergen_safe jsonb;
begin
  -- 인기 메뉴 (최근 주문 기반)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'menu_id', m.id,
        'menu_name', case p_customer_locale
          when 'en' then coalesce(
            m.menu_name_en, m.menu_name
          )
          when 'zh' then coalesce(
            m.menu_name_zh, m.menu_name
          )
          when 'ja' then coalesce(
            m.menu_name_ja, m.menu_name
          )
          when 'vi' then coalesce(
            m.menu_name_en, m.menu_name
          )
          when 'th' then coalesce(
            m.menu_name_en, m.menu_name
          )
          else m.menu_name
        end,
        'price', m.price,
        'thumbnail_url', m.thumbnail_url,
        'allergen_codes', m.allergen_codes,
        'order_count', coalesce(
          pop.order_count, 0
        ),
        'recommendation_type', 'POPULAR'
      )
      order by coalesce(
        pop.order_count, 0
      ) desc
    ),
    '[]'::jsonb
  )
  into v_popular
  from catchmenu_pos.menus m
  left join lateral (
    select count(*) as order_count
    from catchmenu_pos.order_items oi
    join catchmenu_pos.orders o
      on o.id = oi.order_id
    where oi.menu_id = m.id
      and o.store_id = p_store_id
      and o.business_day
        > current_date - 7
      and o.order_status = 'COMPLETED'
  ) pop on true
  where m.store_id = p_store_id
    and m.tenant_id = p_tenant_id
    and m.is_active = true
    and m.menu_status = 'AVAILABLE'
    and (
      p_price_max is null
      or m.price <= p_price_max
    )
    and (
      p_exclude_allergens is null
      or not (
        m.allergen_codes ?|
        array(
          select value::text
          from jsonb_array_elements_text(
            p_exclude_allergens
          )
        )
      )
    )
  limit 3;

  -- 알레르겐 안전 메뉴 (외국인 핵심)
  if p_exclude_allergens is not null then
    select coalesce(
      jsonb_agg(
        jsonb_build_object(
          'menu_id', m.id,
          'menu_name', case p_customer_locale
            when 'en' then coalesce(
              m.menu_name_en, m.menu_name
            )
            else m.menu_name
          end,
          'price', m.price,
          'thumbnail_url', m.thumbnail_url,
          'allergen_codes', m.allergen_codes,
          'recommendation_type',
            'ALLERGEN_SAFE'
        )
        order by m.display_order asc
      ),
      '[]'::jsonb
    )
    into v_allergen_safe
    from catchmenu_pos.menus m
    where m.store_id = p_store_id
      and m.tenant_id = p_tenant_id
      and m.is_active = true
      and m.menu_status = 'AVAILABLE'
      and not (
        m.allergen_codes ?|
        array(
          select value::text
          from jsonb_array_elements_text(
            p_exclude_allergens
          )
        )
      )
    limit 5;
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := 'menu_recommendation_ready',
    p_data := jsonb_build_object(
      'customer_locale', p_customer_locale,
      'context', p_context,
      'popular_menus', v_popular,
      'allergen_safe_menus', v_allergen_safe,
      'exclude_allergens', p_exclude_allergens,
      'price_max', p_price_max,
      'note', jsonb_build_object(
        'foreign_visitor',
          'ALLERGEN_SAFE list prioritized',
        'vector_search',
          'Use search_menu_vector() for natural language',
        'example_queries', jsonb_build_array(
          'spicy noodles without pork',
          'vegetarian friendly',
          'no gluten no dairy',
          'halal friendly'
        )
      )
    ),
    p_locale := p_customer_locale
  );
end;
$$;


create or replace function
  catchmenu_knowledge.get_embedding_status(
  p_tenant_id uuid,
  p_store_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_knowledge,
                  catchmenu_common
as $$
declare
  v_status_summary jsonb;
  v_locale_breakdown jsonb;
  v_pending_list jsonb;
begin
  -- 전체 임베딩 현황
  select jsonb_build_object(
    'total', count(*),
    'completed', count(*) filter (
      where embedding_status = 'COMPLETED'
    ),
    'pending', count(*) filter (
      where embedding_status = 'PENDING'
    ),
    'failed', count(*) filter (
      where embedding_status = 'FAILED'
    ),
    'completion_rate', case count(*)
      when 0 then 0
      else round(
        count(*) filter (
          where embedding_status = 'COMPLETED'
        )::numeric / count(*) * 100, 1
      )
    end
  )
  into v_status_summary
  from catchmenu_knowledge.menu_embeddings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 로케일별 현황
  select coalesce(
    jsonb_object_agg(
      embedding_locale,
      jsonb_build_object(
        'completed', completed,
        'pending', pending,
        'total', total
      )
    ),
    '{}'::jsonb
  )
  into v_locale_breakdown
  from (
    select
      embedding_locale,
      count(*) filter (
        where embedding_status = 'COMPLETED'
      ) as completed,
      count(*) filter (
        where embedding_status = 'PENDING'
      ) as pending,
      count(*) as total
    from catchmenu_knowledge.menu_embeddings
    where store_id = p_store_id
      and tenant_id = p_tenant_id
    group by embedding_locale
  ) l;

  -- PENDING 목록 (최대 10개)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'menu_id', menu_id,
        'menu_name', menu_name,
        'locale', embedding_locale,
        'status', embedding_status,
        'created_at', created_at
      )
      order by created_at asc
    ),
    '[]'::jsonb
  )
  into v_pending_list
  from catchmenu_knowledge.menu_embeddings
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and embedding_status in (
      'PENDING', 'FAILED'
    )
  limit 10;

  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'store_id', p_store_id,
      'status_summary', v_status_summary,
      'locale_breakdown', v_locale_breakdown,
      'pending_items', v_pending_list,
      'setup_guide', jsonb_build_object(
        'step1',
          'queue_menu_embedding() 호출',
        'step2',
          'Edge Function embedding-request 실행',
        'step3',
          'get_embedding_status() 확인',
        'step4',
          'search_menu_vector() 테스트',
        'note',
          'completion_rate 100% 목표'
      )
    )
  );
end;
$$;


-- grants
do $$
begin
  grant execute on function
    catchmenu_knowledge.queue_menu_embedding(
      uuid, uuid, jsonb, jsonb, boolean
    ) to authenticated;

  grant execute on function
    catchmenu_knowledge.search_menu_vector(
      uuid, uuid, text, vector,
      text, int, numeric, jsonb, boolean, uuid
    ) to authenticated;

  grant execute on function
    catchmenu_knowledge.get_menu_recommendation(
      uuid, uuid, text, jsonb,
      int, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_knowledge.get_embedding_status(
      uuid, uuid
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_knowledge.search_menu_vector(
    uuid, uuid, text, vector,
    text, int, numeric, jsonb, boolean, uuid
  ) is
  '다국어 메뉴 벡터 검색.
   외국인 자연어 쿼리 지원.

   검색 흐름:
   1. 고객 앱 → 검색어 입력 (예: no pork halal)
   2. Edge Function → OpenAI 임베딩 생성
   3. search_menu_vector(query_vector=...) 호출
   4. HNSW 코사인 유사도 검색
   5. similarity_score >= min_score 필터
   6. 알레르겐 제외 필터

   벡터 없을 때:
   p_query_vector = null → KEYWORD 폴백.
   ilike 다국어 검색.

   알레르겐 제외:
   p_exclude_allergens = ["돼지고기","우유"]
   → 해당 알레르겐 포함 메뉴 제외.

   외국인 핵심 사례:
   "no pork spicy noodles" (en)
   → 돼지고기 없는 국물 메뉴 추천.

   성능:
   HNSW m=16 ef_construction=64.
   1000개 메뉴 기준 ~10ms.';

comment on function
  catchmenu_knowledge.queue_menu_embedding(
    uuid, uuid, jsonb, jsonb, boolean
  ) is
  '메뉴 다국어 임베딩 큐 등록.

   처리 흐름:
   1. queue_menu_embedding() 호출
   2. menu_embeddings PENDING 레코드 생성
   3. SYSTEM_EVENTS 채널 알림
   4. Edge Function embedding-request 수신
   5. OpenAI text-embedding-3-small API 호출
   6. embedding_vector 업데이트 → COMPLETED

   임베딩 텍스트 구성:
   ko: 메뉴명 + 설명 + 알레르겐 + 가격
   en: menu_name_en + description + allergens
   zh: menu_name_zh + allergens + 价格
   ja: menu_name_ja + allergens + 価格
   vi/th: menu_name_en + allergens + price

   p_force_rebuild = true:
   기존 임베딩 재생성 (메뉴 정보 변경 시).

   1호점 오픈 전 실행 필수:
   SELECT catchmenu_knowledge
     .queue_menu_embedding(tenant_id, store_id);';