import re, pathlib, subprocess, hashlib

def get_live_def(schema, func):
    q = (
        "SELECT pg_get_functiondef(p.oid) FROM pg_proc p "
        "JOIN pg_namespace n ON n.oid=p.pronamespace "
        f"WHERE n.nspname='{schema}' AND p.proname='{func}'"
    )
    return subprocess.check_output([
        'docker', 'exec', '-i', 'supabase_db_yoonsul_wait_order_handoff',
        'psql', '-U', 'postgres', '-d', 'postgres', '-t', '-A', '-c', q
    ], text=True, encoding='utf-8', errors='replace')

def extract_fn(src_text, schema, func):
    pat = rf'create or replace function\s+{schema}\.{func}\([\s\S]*?\bas \$\$(.*?)\$\$'
    m = re.search(pat, src_text, re.I | re.S)
    return m.group(1) if m else None

def canon(s):
    s = re.sub(r'--[^\n]*', '', s)
    s = re.sub(r'\s+', ' ', s.strip().lower())
    return s

def compare(schema, func, path):
    src = pathlib.Path(path).read_text(encoding='utf-8')
    src_inner = extract_fn(src, schema, func)
    live = get_live_def(schema, func)
    live_m = re.search(r'AS \$function\$(.*?)\$function\$', live, re.S)
    live_inner = live_m.group(1) if live_m else ''
    sm = canon(src_inner) if src_inner else ''
    lm = canon(live_inner)
    print(f'=== {schema}.{func} ===')
    print('INNER_MATCH', sm == lm)
    print('SRC_MD5', hashlib.md5(sm.encode()).hexdigest()[:16] if sm else 'NA')
    print('LIVE_MD5', hashlib.md5(lm.encode()).hexdigest()[:16] if lm else 'NA')
    return sm == lm

compare('catchmenu_pos', 'get_waiting_realtime_state', 'sql/migrations/0099_create_realtime_pipeline_rpc.sql')
compare('catchmenu_pos', 'pre_order_while_waiting', 'sql/migrations/0115_create_waiting_pipeline_rpc.sql')

for fn in ['get_kds_realtime_state', 'get_staff_alert_feed', 'broadcast_store_event']:
    live = get_live_def('catchmenu_pos', fn)
    # compare live to committed HEAD version
    head = subprocess.check_output(['git', 'show', f'HEAD:sql/migrations/0099_create_realtime_pipeline_rpc.sql'], text=True, encoding='utf-8')
    src_inner = extract_fn(head, 'catchmenu_pos', fn)
    live_m = re.search(r'AS \$function\$(.*?)\$function\$', live, re.S)
    live_inner = live_m.group(1) if live_m else ''
    sm, lm = canon(src_inner), canon(live_inner)
    print(f'=== sibling {fn} (live vs HEAD source) ===')
    print('INNER_MATCH', sm == lm)
