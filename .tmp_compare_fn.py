import re, pathlib, subprocess, hashlib

src = pathlib.Path('sql/migrations/0027_create_payment_intent_rpc.sql').read_text(encoding='utf-8')
m = re.search(r'create or replace function catchmenu_payment\.confirm_payment_from_provider\([\s\S]*?\nas \$\$(.*?)\$\$', src, re.I | re.S)
src_inner = m.group(1)

live = subprocess.check_output([
    'docker', 'exec', '-i', 'supabase_db_yoonsul_wait_order_handoff',
    'psql', '-U', 'postgres', '-d', 'postgres', '-t', '-A', '-c',
    "SELECT pg_get_functiondef(p.oid) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='catchmenu_payment' AND p.proname='confirm_payment_from_provider'"
], text=True, encoding='utf-8', errors='replace')

live_m = re.search(r'AS \$function\$(.*?)\$function\$', live, re.S)
live_inner = live_m.group(1)

def canon(s):
    s = re.sub(r'--[^\n]*', '', s)
    s = re.sub(r'\s+', ' ', s.strip().lower())
    return s

print('INNER_MATCH', canon(src_inner) == canon(live_inner))
print('SRC_MD5', hashlib.md5(canon(src_inner).encode()).hexdigest())
print('LIVE_MD5', hashlib.md5(canon(live_inner).encode()).hexdigest())
print('LIVE_build_error', live.count('build_error_response'))
print('LIVE_p_locale', 'p_locale' in live)
