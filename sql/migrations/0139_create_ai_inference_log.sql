-- 0139_create_ai_inference_log.sql
-- Purpose: AI multi-engine gateway inference audit log
-- Schema:  catchmenu_ai
-- Tables:  ai_inference_logs, ai_prompt_templates
-- Supports: LangGraph/CrewAI + HyperCLOVA X + Claude + GPT + Gemini + pgvector
-- Depends on: 0138_patch_integration_functions.sql

-- =============================================
-- catchmenu_ai schema
-- =============================================
CREATE SCHEMA IF NOT EXISTS catchmenu_ai;

COMMENT ON SCHEMA catchmenu_ai IS
  'AI multi-engine gateway schema.
   Inference audit logs for all AI calls.
   Supports LangGraph/CrewAI orchestration
   + HyperCLOVA X + Claude + GPT + Gemini + pgvector.';

-- =============================================
-- ai_prompt_templates
-- prompt version management
-- =============================================
CREATE TABLE IF NOT EXISTS
  catchmenu_ai.ai_prompt_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid,

  template_code text NOT NULL,
  template_name text NOT NULL,
  model_provider text NOT NULL,
  model_name text NOT NULL,
  prompt_version text NOT NULL,

  system_prompt text,
  user_prompt_template text,
  temperature numeric(3,2) DEFAULT 0.7,
  max_tokens int DEFAULT 1000,

  is_active boolean DEFAULT true,
  ab_test_weight int DEFAULT 100,

  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),

  CONSTRAINT uq_prompt_version
    UNIQUE (template_code, prompt_version,
            model_provider)
);

COMMENT ON TABLE catchmenu_ai.ai_prompt_templates IS
  'AI prompt template registry.
   Supports A/B testing via ab_test_weight.
   Rollback = change is_active flag.';

-- =============================================
-- ai_inference_logs
-- all AI engine call audit log
-- =============================================
CREATE TABLE IF NOT EXISTS
  catchmenu_ai.ai_inference_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  store_id uuid,

  -- chain tracking
  -- one customer request = one chain_id
  chain_id uuid NOT NULL,
  chain_step int NOT NULL DEFAULT 1,
  chain_total int NOT NULL DEFAULT 1,
  chain_total_latency_ms int,

  -- AI engine identification
  model_provider text NOT NULL,
  model_name text NOT NULL,
  prompt_version text NOT NULL DEFAULT 'v1.0',
  prompt_template_id uuid
    REFERENCES catchmenu_ai.ai_prompt_templates(id),
  system_prompt_hash text,

  -- routing decision
  -- why this engine was selected
  routing_reason text,
  -- KOREAN_CUSTOMER
  -- COMPLEX_REASONING
  -- TRANSLATION_NEEDED
  -- SOP_GENERATION
  -- MENU_SEARCH
  -- MULTIMODAL
  -- FALLBACK

  -- language
  input_language text DEFAULT 'ko',
  output_language text DEFAULT 'ko',
  translation_required boolean DEFAULT false,

  -- RAG tracking
  rag_source jsonb,
  -- {"sop_ids": [...], "menu_ids": [...],
  --  "faq_ids": [...]}
  rag_chunk_count int DEFAULT 0,
  rag_similarity_threshold numeric(4,3),
  rag_top_k int,

  -- token usage
  input_tokens int,
  output_tokens int,
  total_tokens int
    GENERATED ALWAYS AS
      (COALESCE(input_tokens,0) +
       COALESCE(output_tokens,0)) STORED,

  -- content summary (not full content)
  input_summary text,
  output_summary text,
  latency_ms int,

  -- tool calls by LangGraph/CrewAI
  tool_call_log jsonb DEFAULT '[]',
  -- [{"tool": "search_menu_vector",
  --   "input": "gluten free",
  --   "result_count": 5,
  --   "latency_ms": 23},
  --  {"tool": "get_order_status",
  --   "input": "session_id",
  --   "result": "WAITING",
  --   "latency_ms": 8}]

  -- human review
  human_approved boolean DEFAULT false,
  human_approved_by uuid,
  human_approved_at timestamptz,
  human_override text,
  escalated_to_staff boolean DEFAULT false,
  escalated_at timestamptz,

  -- fallback
  fallback_engine text,
  fallback_reason text,

  -- cost tracking
  cost_usd numeric(10,6) DEFAULT 0,
  cost_krw numeric(10,2) DEFAULT 0,

  -- session linking
  session_id uuid,
  order_id uuid,
  inquiry_id uuid,
  staff_id uuid,
  correlation_id uuid,

  -- result
  response_status text NOT NULL
    DEFAULT 'SUCCESS',
  confidence_score numeric(4,3),
  customer_satisfied boolean,

  created_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT chk_provider CHECK (
    model_provider IN (
      'LANGGRAPH',
      'CREWAI',
      'CLOVA_X',
      'ANTHROPIC',
      'OPENAI',
      'GEMINI',
      'PGVECTOR',
      'CUSTOM'
    )
  ),
  CONSTRAINT chk_status CHECK (
    response_status IN (
      'SUCCESS',
      'FALLBACK',
      'ERROR',
      'TIMEOUT',
      'HUMAN_ESCALATED',
      'SKIPPED'
    )
  ),
  CONSTRAINT chk_routing_reason CHECK (
    routing_reason IS NULL OR
    routing_reason IN (
      'KOREAN_CUSTOMER',
      'FOREIGN_CUSTOMER',
      'COMPLEX_REASONING',
      'TRANSLATION_NEEDED',
      'SOP_GENERATION',
      'MENU_SEARCH',
      'MULTIMODAL',
      'FALLBACK',
      'COST_OPTIMIZATION',
      'SPEED_PRIORITY'
    )
  )
);

-- indexes
CREATE INDEX IF NOT EXISTS idx_ai_chain
  ON catchmenu_ai.ai_inference_logs(
    chain_id, chain_step ASC
  );

CREATE INDEX IF NOT EXISTS idx_ai_tenant_date
  ON catchmenu_ai.ai_inference_logs(
    tenant_id, created_at DESC
  );

CREATE INDEX IF NOT EXISTS idx_ai_provider
  ON catchmenu_ai.ai_inference_logs(
    model_provider, model_name,
    prompt_version, created_at DESC
  );

CREATE INDEX IF NOT EXISTS idx_ai_escalated
  ON catchmenu_ai.ai_inference_logs(
    escalated_to_staff, created_at DESC
  ) WHERE escalated_to_staff = true;

CREATE INDEX IF NOT EXISTS idx_ai_cost
  ON catchmenu_ai.ai_inference_logs(
    tenant_id, created_at DESC,
    cost_usd
  );

COMMENT ON TABLE catchmenu_ai.ai_inference_logs IS
  'AI multi-engine inference audit log.
   Every AI call is recorded here.
   chain_id groups one customer request.
   chain_step tracks engine order.
   routing_reason explains engine selection.
   human_approved tracks staff review.';

-- =============================================
-- helper functions
-- =============================================

-- write inference log
CREATE OR REPLACE FUNCTION
  catchmenu_ai.write_inference_log(
  p_tenant_id uuid,
  p_chain_id uuid,
  p_chain_step int,
  p_chain_total int,
  p_model_provider text,
  p_model_name text,
  p_prompt_version text DEFAULT 'v1.0',
  p_routing_reason text DEFAULT NULL,
  p_input_language text DEFAULT 'ko',
  p_output_language text DEFAULT 'ko',
  p_translation_required boolean DEFAULT false,
  p_rag_source jsonb DEFAULT NULL,
  p_rag_chunk_count int DEFAULT 0,
  p_input_tokens int DEFAULT NULL,
  p_output_tokens int DEFAULT NULL,
  p_input_summary text DEFAULT NULL,
  p_output_summary text DEFAULT NULL,
  p_latency_ms int DEFAULT NULL,
  p_chain_total_latency_ms int DEFAULT NULL,
  p_tool_call_log jsonb DEFAULT '[]',
  p_response_status text DEFAULT 'SUCCESS',
  p_confidence_score numeric DEFAULT NULL,
  p_cost_usd numeric DEFAULT 0,
  p_cost_krw numeric DEFAULT 0,
  p_session_id uuid DEFAULT NULL,
  p_order_id uuid DEFAULT NULL,
  p_inquiry_id uuid DEFAULT NULL,
  p_correlation_id uuid DEFAULT NULL,
  p_store_id uuid DEFAULT NULL,
  p_fallback_engine text DEFAULT NULL,
  p_fallback_reason text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = catchmenu_ai
AS $$
DECLARE
  v_log_id uuid;
BEGIN
  INSERT INTO catchmenu_ai.ai_inference_logs (
    tenant_id, store_id,
    chain_id, chain_step, chain_total,
    chain_total_latency_ms,
    model_provider, model_name,
    prompt_version,
    routing_reason,
    input_language, output_language,
    translation_required,
    rag_source, rag_chunk_count,
    input_tokens, output_tokens,
    input_summary, output_summary,
    latency_ms,
    tool_call_log,
    response_status,
    confidence_score,
    cost_usd, cost_krw,
    session_id, order_id,
    inquiry_id, correlation_id,
    fallback_engine, fallback_reason
  ) VALUES (
    p_tenant_id, p_store_id,
    p_chain_id, p_chain_step, p_chain_total,
    p_chain_total_latency_ms,
    p_model_provider, p_model_name,
    p_prompt_version,
    p_routing_reason,
    p_input_language, p_output_language,
    p_translation_required,
    p_rag_source, p_rag_chunk_count,
    p_input_tokens, p_output_tokens,
    p_input_summary, p_output_summary,
    p_latency_ms,
    p_tool_call_log,
    p_response_status,
    p_confidence_score,
    p_cost_usd, p_cost_krw,
    p_session_id, p_order_id,
    p_inquiry_id, p_correlation_id,
    p_fallback_engine, p_fallback_reason
  )
  RETURNING id INTO v_log_id;

  RETURN v_log_id;
END;
$$;

-- get chain summary
CREATE OR REPLACE FUNCTION
  catchmenu_ai.get_chain_summary(
  p_chain_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = catchmenu_ai
AS $$
DECLARE
  v_steps jsonb;
  v_summary jsonb;
BEGIN
  SELECT jsonb_agg(
    jsonb_build_object(
      'step', chain_step,
      'provider', model_provider,
      'model', model_name,
      'routing_reason', routing_reason,
      'input_lang', input_language,
      'output_lang', output_language,
      'latency_ms', latency_ms,
      'tokens', total_tokens,
      'cost_usd', cost_usd,
      'status', response_status,
      'tools', tool_call_log,
      'rag_chunks', rag_chunk_count
    )
    ORDER BY chain_step ASC
  )
  INTO v_steps
  FROM catchmenu_ai.ai_inference_logs
  WHERE chain_id = p_chain_id;

  SELECT jsonb_build_object(
    'chain_id', p_chain_id,
    'total_steps', COUNT(*),
    'total_latency_ms',
      MAX(chain_total_latency_ms),
    'total_tokens', SUM(total_tokens),
    'total_cost_usd', SUM(cost_usd),
    'total_cost_krw', SUM(cost_krw),
    'engines_used',
      jsonb_agg(DISTINCT model_provider),
    'human_escalated',
      BOOL_OR(escalated_to_staff),
    'overall_status', CASE
      WHEN BOOL_OR(response_status = 'ERROR')
        THEN 'HAS_ERROR'
      WHEN BOOL_OR(response_status = 'FALLBACK')
        THEN 'HAS_FALLBACK'
      ELSE 'SUCCESS'
    END,
    'steps', v_steps
  )
  INTO v_summary
  FROM catchmenu_ai.ai_inference_logs
  WHERE chain_id = p_chain_id;

  RETURN v_summary;
END;
$$;

-- prompt version performance analysis
CREATE OR REPLACE FUNCTION
  catchmenu_ai.get_prompt_performance(
  p_tenant_id uuid DEFAULT NULL,
  p_model_provider text DEFAULT NULL,
  p_days_ago int DEFAULT 30
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = catchmenu_ai
AS $$
DECLARE
  v_result jsonb;
BEGIN
  SELECT jsonb_agg(
    jsonb_build_object(
      'provider', model_provider,
      'model', model_name,
      'version', prompt_version,
      'total_calls', total,
      'success_rate',
        ROUND(success::numeric/total*100, 1),
      'approval_rate',
        ROUND(approved::numeric/total*100, 1),
      'avg_latency_ms', avg_latency,
      'avg_cost_usd', avg_cost,
      'total_cost_usd', total_cost
    )
    ORDER BY approval_rate DESC
  )
  INTO v_result
  FROM (
    SELECT
      model_provider,
      model_name,
      prompt_version,
      COUNT(*) as total,
      COUNT(*) FILTER (
        WHERE response_status = 'SUCCESS'
      ) as success,
      COUNT(*) FILTER (
        WHERE human_approved = true
      ) as approved,
      ROUND(AVG(latency_ms)) as avg_latency,
      ROUND(AVG(cost_usd)::numeric, 6) as avg_cost,
      ROUND(SUM(cost_usd)::numeric, 4) as total_cost
    FROM catchmenu_ai.ai_inference_logs
    WHERE created_at > now()
        - (p_days_ago || ' days')::interval
      AND (p_tenant_id IS NULL
           OR tenant_id = p_tenant_id)
      AND (p_model_provider IS NULL
           OR model_provider = p_model_provider)
    GROUP BY
      model_provider, model_name, prompt_version
  ) t;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;

-- daily cost report
CREATE OR REPLACE FUNCTION
  catchmenu_ai.get_daily_ai_cost(
  p_tenant_id uuid,
  p_date date DEFAULT CURRENT_DATE
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = catchmenu_ai
AS $$
DECLARE
  v_result jsonb;
BEGIN
  SELECT jsonb_build_object(
    'date', p_date,
    'total_calls', COUNT(*),
    'total_cost_usd',
      ROUND(SUM(cost_usd)::numeric, 4),
    'total_cost_krw',
      ROUND(SUM(cost_krw)::numeric, 0),
    'by_provider', jsonb_object_agg(
      model_provider,
      jsonb_build_object(
        'calls', cnt,
        'cost_usd', provider_cost_usd,
        'cost_krw', provider_cost_krw
      )
    )
  )
  INTO v_result
  FROM (
    SELECT
      model_provider,
      COUNT(*) as cnt,
      ROUND(SUM(cost_usd)::numeric, 4)
        as provider_cost_usd,
      ROUND(SUM(cost_krw)::numeric, 0)
        as provider_cost_krw
    FROM catchmenu_ai.ai_inference_logs
    WHERE tenant_id = p_tenant_id
      AND created_at::date = p_date
    GROUP BY model_provider
  ) t
  CROSS JOIN LATERAL (
    SELECT COUNT(*) as total_cnt,
           SUM(cost_usd) as total_usd,
           SUM(cost_krw) as total_krw
    FROM catchmenu_ai.ai_inference_logs
    WHERE tenant_id = p_tenant_id
      AND created_at::date = p_date
  ) totals;

  RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$;

-- =============================================
-- grants
-- =============================================
GRANT USAGE ON SCHEMA catchmenu_ai
  TO authenticated, service_role;

GRANT SELECT, INSERT ON
  catchmenu_ai.ai_inference_logs
  TO authenticated, service_role;

GRANT SELECT, INSERT, UPDATE ON
  catchmenu_ai.ai_prompt_templates
  TO service_role;

GRANT SELECT ON
  catchmenu_ai.ai_prompt_templates
  TO authenticated;

GRANT EXECUTE ON FUNCTION
  catchmenu_ai.write_inference_log(
    uuid, uuid, int, int,
    text, text, text, text,
    text, text, boolean,
    jsonb, int, int, int,
    text, text, int, int,
    jsonb, text, numeric,
    numeric, numeric,
    uuid, uuid, uuid, uuid,
    uuid, text, text
  ) TO authenticated, service_role;

GRANT EXECUTE ON FUNCTION
  catchmenu_ai.get_chain_summary(uuid)
  TO authenticated, service_role;

GRANT EXECUTE ON FUNCTION
  catchmenu_ai.get_prompt_performance(
    uuid, text, int
  ) TO authenticated, service_role;

GRANT EXECUTE ON FUNCTION
  catchmenu_ai.get_daily_ai_cost(uuid, date)
  TO authenticated, service_role;

-- =============================================
-- seed: default prompt templates
-- =============================================
INSERT INTO catchmenu_ai.ai_prompt_templates (
  template_code, template_name,
  model_provider, model_name,
  prompt_version, is_active,
  ab_test_weight
) VALUES
  ('MENU_SEARCH_KO', 'Korean menu search',
   'PGVECTOR', 'text-embedding-ada-002',
   'v1.0', true, 100),
  ('SOP_SEARCH', 'SOP document search',
   'PGVECTOR', 'text-embedding-ada-002',
   'v1.0', true, 100),
  ('CUSTOMER_QA_KO', 'Korean customer QA',
   'CLOVA_X', 'clova-x-v2',
   'v1.0', true, 100),
  ('CUSTOMER_QA_EN', 'English customer QA',
   'ANTHROPIC', 'claude-sonnet-4-6',
   'v1.0', true, 100),
  ('SOP_GENERATION', 'SOP auto generation',
   'ANTHROPIC', 'claude-sonnet-4-6',
   'v1.0', true, 100),
  ('TRANSLATION_KO', 'Foreign to Korean',
   'CLOVA_X', 'clova-x-v2',
   'v1.0', true, 100),
  ('ORCHESTRATOR', 'LangGraph orchestrator',
   'LANGGRAPH', 'langgraph-v0.1',
   'v1.0', true, 100)
ON CONFLICT (template_code, prompt_version,
             model_provider)
DO NOTHING;

-- =============================================
-- verification
-- =============================================
SELECT
  schemaname,
  tablename
FROM pg_tables
WHERE schemaname = 'catchmenu_ai'
ORDER BY tablename;