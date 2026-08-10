import re, pathlib, subprocess, hashlib

def extract_fn(text, schema, func):
    pat = rf'create or replace function\s+{schema}\.{func}\([\s\S]*?\bas \$\$(.*?)\$\$'
    m = re.search(pat, text, re.I | re.S)
    return m.group(1) if m else None

def canon(s):
    if not s: return ''
    s = re.sub(r'--[^\n]*', '', s)
    return re.sub(r'\s+', ' ', s.strip().lower())

def live_inner(schema, func):
    q = f"SELECT pg_get_functiondef(p.oid) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='{schema}' AND p.proname='{func}'"
    live = subprocess.check_output(['docker','exec','-i','supabase_db_yoonsul_wait_order_handoff','psql','-U','postgres','-d','postgres','-t','-A','-c',q], text=True, encoding='utf-8', errors='replace')
    m = re.search(r'AS \$function\$(.*?)\$function\$', live, re.S)
    return m.group(1) if m else ''

src = pathlib.Path('sql/migrations/0099_create_realtime_pipeline_rpc.sql').read_text(encoding='utf-8')
head = subprocess.check_output(['git','show','HEAD:sql/migrations/0099_create_realtime_pipeline_rpc.sql'], text=True, encoding='utf-8')

pairs = [
    ('catchmenu_kds', 'get_kds_realtime_state'),
    ('catchmenu_common', 'get_staff_alert_feed'),
    ('catchmenu_common', 'broadcast_store_event'),
]
for schema, fn in pairs:
    wt = extract_fn(src, schema, fn)
    hd = extract_fn(head, schema, fn)
    lv = live_inner(schema, fn)
    print(f'{schema}.{fn}: WT==HEAD {canon(wt)==canon(hd)}, LIVE==WT {canon(lv)==canon(wt)}')
