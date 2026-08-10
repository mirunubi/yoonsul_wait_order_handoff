import re, pathlib, subprocess, hashlib

def extract_fn(text, schema, func):
    pat = rf'create or replace function\s+{schema}\.{func}\([\s\S]*?\bas \$\$(.*?)\$\$'
    m = re.search(pat, text, re.I | re.S)
    return m.group(1) if m else None

def canon(s):
    if not s: return ''
    s = re.sub(r'--[^\n]*', '', s)
    return re.sub(r'\s+', ' ', s.strip().lower())

def live_def(schema, func):
    q = f"SELECT pg_get_functiondef(p.oid) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='{schema}' AND p.proname='{func}'"
    return subprocess.check_output(['docker','exec','-i','supabase_db_yoonsul_wait_order_handoff','psql','-U','postgres','-d','postgres','-t','-A','-c',q], text=True, encoding='utf-8', errors='replace')

path = 'sql/migrations/0099_create_realtime_pipeline_rpc.sql'
src = pathlib.Path(path).read_text(encoding='utf-8')
head = subprocess.check_output(['git','show',f'HEAD:{path}'], text=True, encoding='utf-8')

for fn in ['get_kds_realtime_state', 'get_staff_alert_feed', 'broadcast_store_event']:
    src_wt = extract_fn(src, 'catchmenu_pos', fn)
    src_hd = extract_fn(head, 'catchmenu_pos', fn)
    live = live_def('catchmenu_pos', fn)
    live_inner = re.search(r'AS \$function\$(.*?)\$function\$', live, re.S)
    live_inner = live_inner.group(1) if live_inner else ''
    print(f'=== {fn} ===')
    print('WT_vs_HEAD_MATCH', canon(src_wt)==canon(src_hd))
    print('LIVE_vs_WT_MATCH', canon(live_inner)==canon(src_wt))
    if fn == 'get_kds_realtime_state':
        body = canon(live_inner)
        print('600420 per_zone', 'kds_capacity_threshold_per_zone' in body)
        print('600420 priority', 'kt.priority' in body and 'priority_score' not in body)
        print('600420 is_late_expr_count', body.count('estimated_minutes_snapshot'))
