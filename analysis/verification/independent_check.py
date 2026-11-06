import csv, struct, sys, os
from decimal import Decimal
from collections import Counter, defaultdict
from datetime import datetime

D = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'data')
def load(n):
    with open(os.path.join(D, n), newline='', encoding='utf-8') as f:
        return list(csv.DictReader(f))
P = load('payments.csv'); R = load('receipts.csv'); S = load('disbursements.csv')

DELIV = {'paid', 'success', 'completed', 'delivered'}
FAIL = {'failed', 'rejected', 'cancelled', 'error_sending_payout_request', 'payout_not_processed'}
out = []  # (check, value)
def rec(name, v): out.append((name, str(v)))
def dist(c): return '; '.join(f'{k}:{c[k]}' for k in sorted(c, key=lambda x: (str(type(x)), x)))

# 1
for nm, rows in (('payments', P), ('receipts', R), ('disbursements', S)):
    rec(f'{nm} rows', len(rows)); rec(f'{nm} distinct id', len({r['id'] for r in rows}))
dis = {r['id']: r for r in S}
pay = {r['id']: r for r in P}
rpp = defaultdict(list)
for r in R: rpp[r['payment_id']].append(r)
rec('receipts per payment dist (payments with >=1 receipt)', dist(Counter(len(v) for v in rpp.values())))
rec('receipts with null disbursement_id', sum(1 for r in R if r['disbursement_id'] == ''))
rec('receipts with disbursement_id not in disbursements', sum(1 for r in R if r['disbursement_id'] != '' and r['disbursement_id'] not in dis))
rec('receipts with no disbursement record (null or missing)', sum(1 for r in R if r['disbursement_id'] not in dis))
rec('receipts with payment_id not in payments', sum(1 for r in R if r['payment_id'] not in pay))
rec('payments without a receipt', sum(1 for p in P if p['id'] not in rpp))
# 2
for nm, rows in (('payments', P), ('receipts', R), ('disbursements', S)):
    for c in rows[0].keys():
        rec(f'nulls {nm}.{c}', sum(1 for r in rows if r[c] == ''))
# 3
def dp(s):
    return len(s.split('.')[1]) if '.' in s else 0
rec('payments.amount decimals dist', dist(Counter(dp(p['amount']) for p in P)))
m = 0
for p in P:
    s = p['amount']
    if dp(s) in (8, 9):
        a = Decimal(s)
        f32 = struct.unpack('f', struct.pack('f', float(a.quantize(Decimal('0.01')))))[0]
        # float32 of amount rounded to 2dp, rendered at 9 decimals (exact decimal expansion rounded half-even)
        r9 = Decimal(f32).quantize(Decimal('0.000000001'))
        if a.quantize(Decimal('0.000000001')) == r9: m += 1
rec('payments.amount 8/9dp rows matching float32(round2) at 9dp', m)
rec('payments.amount rows with 8 or 9 dp', sum(1 for p in P if dp(p['amount']) in (8, 9)))
# 4
def isnum(s):
    try: Decimal(s); return True
    except Exception: return False
for nm, rows in (('payments', P), ('receipts', R), ('disbursements', S)):
    for c in rows[0].keys():
        vals = [r[c] for r in rows if r[c] != '']
        if vals and all(isnum(v) and 'e' not in v.lower() and v.lower() not in ('nan', 'inf') for v in vals[:200]):
            nn = [v for v in vals if isnum(v)]
            if len(nn) != len(vals): continue
            md = max(dp(v) for v in vals)
            mi = max(len(v.lstrip('-').split('.')[0]) for v in vals)
            rec(f'numeric {nm}.{c} max decimals / max int digits', f'{md} / {mi}')
# 5
def delivered_rcpts(pid):
    n = 0
    for r in rpp.get(pid, []):
        d = dis.get(r['disbursement_id'])
        if d and d['status'].lower() in DELIV: n += 1
    return n
def failed_rcpts(pid):
    n = 0
    for r in rpp.get(pid, []):
        d = dis.get(r['disbursement_id'])
        if d and d['status'].lower() in FAIL: n += 1
    return n
rec('sum payments.amount all', sum(Decimal(p['amount']) for p in P))
rec('sum payments.amount SUCCESSFUL', sum(Decimal(p['amount']) for p in P if p['status'] == 'SUCCESSFUL'))
dr = [p for p in P if p['status'] == 'SUCCESSFUL' and delivered_rcpts(p['id']) >= 1]
rec('delivered remittance count', len(dr))
rec('sum delivered remittance amount', sum(Decimal(p['amount']) for p in dr))
# 6
mv = defaultdict(lambda: [Decimal(0), 0])
for p in dr:
    k = p['created_at'][:7]; mv[k][0] += Decimal(p['amount']); mv[k][1] += 1
for k in sorted(mv): rec(f'delivered month {k} volume / count', f'{mv[k][0]} / {mv[k][1]}')
rec('delivered months present', len(mv))
# 7
oc = defaultdict(lambda: [0, Decimal(0)])
for p in P:
    rs = rpp.get(p['id'], [])
    nd = delivered_rcpts(p['id'])
    if not rs: o = 'no_receipt'
    elif nd >= 2: o = 'multiple_delivered'
    elif nd == 1: o = 'delivered'
    elif all((dis.get(r['disbursement_id']) is not None and dis[r['disbursement_id']]['status'].lower() in FAIL) for r in rs): o = 'all_attempts_failed'
    else: o = 'in_flight_or_unknown'
    oc[(p['status'], o)][0] += 1; oc[(p['status'], o)][1] += Decimal(p['amount'])
for k in sorted(oc): rec(f'outcome {k[0]} x {k[1]} count / USD', f'{oc[k][0]} / {oc[k][1]}')
rec('outcome table total count / USD', f'{sum(v[0] for v in oc.values())} / {sum(v[1] for v in oc.values())}')
# 8
bu = defaultdict(set); ub = defaultdict(set)
for r in R:
    if r['beneficiary_id'] != '': bu[r['beneficiary_id']].add(r['user_id']); ub[r['user_id']].add(r['beneficiary_id'])
rec('beneficiaries shared by >1 user', sum(1 for v in bu.values() if len(v) > 1))
rec('distinct beneficiaries', len(bu))
bk = Counter()
for u, s in ub.items():
    n = len(s); bk['1' if n == 1 else '2-3' if n <= 3 else '4-9' if n <= 9 else '10+'] += 1
rec('users by beneficiary count bucket', '; '.join(f'{k}:{bk[k]}' for k in ('1', '2-3', '4-9', '10+')))
# 9
pv = defaultdict(lambda: [0, 0, 0, 0])
for s in S:
    a = pv[s['disbursement_provider']]; a[0] += 1
    if s['status'].lower() in ('failed', 'rejected', 'cancelled'): a[1] += 1
    if s['raw_status'].lower() in ('failed', 'rejected'): a[2] += 1
    if s['raw_status'].lower() == 'cancelled': a[3] += 1
for k in sorted(pv, key=lambda x: (-pv[x][0], x)):
    a = pv[k]
    rec(f'provider {k!r} attempts / %status fail / %raw fail / %raw cancelled', f'{a[0]} / {100*a[1]/a[0]:.2f} / {100*a[2]/a[0]:.2f} / {100*a[3]/a[0]:.2f}')
# 10
sp = [p for p in P if p['status'] in ('SUCCESSFUL', 'REFUNDED')]
cb = [p for p in sp if p['has_dispute_chargeback'] == 'True']
rec('chargeback values seen', dist(Counter(p['has_dispute_chargeback'] for p in P)))
rec('chargebacks among SUCCESSFUL/REFUNDED', len(cb))
rec('settled (SUCCESSFUL/REFUNDED) count', len(sp))
rec('chargeback count rate %', f'{100*len(cb)/len(sp):.4f}')
rec('chargeback USD rate %', f'{100*sum(Decimal(p["amount"]) for p in cb)/sum(Decimal(p["amount"]) for p in sp):.4f}')
mm = defaultdict(lambda: [0, 0])
for p in sp:
    k = p['created_at'][:7]; mm[k][1] += 1
    if p['has_dispute_chargeback'] == 'True': mm[k][0] += 1
for k in sorted(mm): rec(f'chargeback month {k} cb / settled / rate %', f'{mm[k][0]} / {mm[k][1]} / {100*mm[k][0]/mm[k][1]:.4f}')
# 11
ua = defaultdict(Decimal)
for p in dr: ua[p['user_id']] += Decimal(p['amount'])
tot = sum(ua.values()); cum = Decimal(0); rk = None
for i, (u, a) in enumerate(sorted(ua.items(), key=lambda x: (-x[1], x[0])), 1):
    cum += a
    if cum * 2 >= tot: rk = i; break
rec('users with delivered payments (total users)', len(ua))
rec('rank where cumulative >= 50% of delivered USD', rk)
rec('rank as % of users', f'{100*rk/len(ua):.4f}')
# 12
uc = defaultdict(list)
for p in dr: uc[p['user_id']].append(p['created_at'][:7])
rec('delivered users with 2+ remittances', sum(1 for v in uc.values() if len(v) >= 2))
rec('delivered users with 2+ distinct months', sum(1 for v in uc.values() if len(set(v)) >= 2))
rec('delivered users with 3+ distinct months', sum(1 for v in uc.values() if len(set(v)) >= 3))
ut = defaultdict(list)
for p in dr: ut[p['user_id']].append(datetime.fromisoformat(p['created_at']))
def gap_within(v, days):
    s = sorted(v)
    return any(1 < (b - a).total_seconds() / 86400 <= days for a, b in zip(s, s[1:]))
rec('delivered users with a gap over 1 day and at most 90 days', sum(1 for v in ut.values() if gap_within(v, 90)))
# 13
pr = [Decimal(r['promotion_amount']) for r in R if r['promotion_amount'] != '']
rec('receipts promotion_amount > 0', sum(1 for x in pr if x > 0))
rec('sum promotion_amount', sum(pr)); rec('max promotion_amount', max(pr))
rec('receipts amount_charged = 0 and promotion > 0', sum(1 for r in R if r['amount_charged'] != '' and r['promotion_amount'] != '' and Decimal(r['amount_charged']) == 0 and Decimal(r['promotion_amount']) > 0))
# 14
nm_ = Counter(p['created_at'][:7] for p in P if p['status'] == 'SUCCESSFUL' and p['id'] not in rpp)
for k in sorted(nm_): rec(f'SUCCESSFUL no-receipt month {k}', nm_[k])
rec('SUCCESSFUL no-receipt total', sum(nm_.values()))
# 15
wf = [p for p in P if failed_rcpts(p['id']) >= 1]
rec('payments with failed-family attempt', len(wf))
rec('... also with delivered attempt', sum(1 for p in wf if delivered_rcpts(p['id']) >= 1))
rec('... without delivered attempt', sum(1 for p in wf if delivered_rcpts(p['id']) == 0))


# ---------------- comparison against DuckDB results (values transcribed from analysis/results/*.md) ----------------
from decimal import ROUND_HALF_UP
DUCK = {
 'payments rows': '788976', 'payments distinct id': '788976', 'receipts rows': '743948', 'receipts distinct id': '743948',
 'disbursements rows': '743763', 'disbursements distinct id': '743763',
 'receipts per payment dist (payments with >=1 receipt)': '1:715012; 2:11259; 3:1540; 4:312; 5:79; 6:21; 7:3; 8:1',
 'receipts with no disbursement record (null or missing)': '185',
 'receipts with payment_id not in payments': '0', 'payments without a receipt': '60749',
 'payments.amount decimals dist': '0:50321; 1:12022; 2:725806; 3:94; 4:39; 5:5; 8:4; 9:685',
 'payments.amount 8/9dp rows matching float32(round2) at 9dp': '687',
 'payments.amount rows with 8 or 9 dp': '689',
 'numeric payments.amount max decimals / max int digits': '9 / 4',
 'numeric payments.total_intents max decimals / max int digits': '0 / 1',
 'numeric receipts.amount_charged max decimals / max int digits': '2 / 4',
 'numeric receipts.fee max decimals / max int digits': '2 / 2',
 'numeric receipts.exchange_rate max decimals / max int digits': '4 / 4',
 'numeric receipts.promotion_amount max decimals / max int digits': '2 / 3',
 'numeric receipts.destination_amount max decimals / max int digits': '2 / 8',
 'numeric disbursements.amount max decimals / max int digits': '2 / 8',
 'sum payments.amount all': '268009275.296380599',
 'sum payments.amount SUCCESSFUL': '237730447.406696304',
 'delivered remittance count': '720630',
 'sum delivered remittance amount': '237075836.916685776',
 'delivered months present': '9',
 'beneficiaries shared by >1 user': '0', 'distinct beneficiaries': '554117',
 'users by beneficiary count bucket': '1:289700; 2-3:92942; 4-9:12044; 10+:94',
 'chargebacks among SUCCESSFUL/REFUNDED': '526', 'settled (SUCCESSFUL/REFUNDED) count': '730271',
 'chargeback count rate %': '0.072', 'chargeback USD rate %': '0.095',
 'users with delivered payments (total users)': '391244',
 'rank where cumulative >= 50% of delivered USD': '59511', 'rank as % of users': '15.21',
 'delivered users with 2+ remittances': '160590', 'delivered users with 2+ distinct months': '144758',
 'delivered users with 3+ distinct months': '58727',
 'delivered users with a gap over 1 day and at most 90 days': '133760',
 'receipts promotion_amount > 0': '13983', 'sum promotion_amount': '746479.11', 'max promotion_amount': '620',
 'receipts amount_charged = 0 and promotion > 0': '2953',
 'SUCCESSFUL no-receipt month 2026-06': '29', 'SUCCESSFUL no-receipt month 2026-07': '148',
 'SUCCESSFUL no-receipt month 2026-08': '733', 'SUCCESSFUL no-receipt month 2026-09': '1051',
 'SUCCESSFUL no-receipt total': '1961',
 'payments with failed-family attempt': '18313', '... also with delivered attempt': '11975', '... without delivered attempt': '6338',
 'outcome table total count / USD': '788976 / 268009275.296380599',
}
MV = {'2026-01': '16679287.738697410 / 54755', '2026-02': '19265512.559947657 / 60726', '2026-03': '24753796.199430188 / 75052',
      '2026-04': '25408575.707895777 / 77645', '2026-05': '30303037.939352239 / 92746', '2026-06': '30038057.871036566 / 89289',
      '2026-07': '32372631.160644604 / 96149', '2026-08': '33614832.568005530 / 101232', '2026-09': '24640105.171675805 / 73036'}
for k, v in MV.items(): DUCK[f'delivered month {k} volume / count'] = v
OC = """FAILED all_attempts_failed 1 500.000000
FAILED delivered 2 512.990000
FAILED no_receipt 58684 27567825.155192383
PENDING_USER_ACTION no_receipt 17 7039.400000
REFUNDED all_attempts_failed 6106 2653985.044492
REFUNDED no_receipt 86 33583.670000
REFUNDED in_flight_or_unknown 20 13485.040000
REFUNDED delivered 7 1897.490000
STARTED no_receipt 1 -0.900000
SUCCESSFUL delivered 720611 237070321.026685776
SUCCESSFUL no_receipt 1961 40690.150000
SUCCESSFUL in_flight_or_unknown 1279 563019.750000
SUCCESSFUL all_attempts_failed 182 50900.590011
SUCCESSFUL multiple_delivered 19 5515.890000"""
for ln in OC.splitlines():
    a, b, c, d = ln.split(); DUCK[f'outcome {a} x {b} count / USD'] = f'{c} / {d}'
PV = """PROVIDER 3|243048|1.44|0.18|1.26
PROVIDER 12|206334|3.78|1.33|2.42
PROVIDER 8|131807|4.75|0.42|4.33
PROVIDER 11|65966|1.94|1.94|0.0
PROVIDER 7|39819|3.32|2.95|0.37
PROVIDER 5|24524|2.84|2.8|0.04
PROVIDER 4|23426|2.0|1.93|0.0
PROVIDER 9|5166|3.74|3.74|0.0
PROVIDER 2|3396|7.48|7.48|0.0
PROVIDER 6|268|10.07|10.07|0.0
PROVIDER 10|6|66.67|0.0|66.67
PROVIDER 1|3|66.67|66.67|0.0"""
for ln in PV.splitlines():
    n, a, b, c, d = ln.split('|')
    DUCK[f"provider {n!r} attempts / %status fail / %raw fail / %raw cancelled"] = f'{a} / {b} / {c} / {d}'
CB = """2026-01|55473|43|0.078
2026-02|61379|33|0.054
2026-03|75911|65|0.086
2026-04|78419|74|0.094
2026-05|93582|96|0.103
2026-06|90058|76|0.084
2026-07|97043|60|0.062
2026-08|102736|55|0.054
2026-09|75670|24|0.032"""
for ln in CB.splitlines():
    m_, st, c_, r_ = ln.split('|')
    DUCK[f'chargeback month {m_} cb / settled / rate %'] = f'{c_} / {st} / {r_}'
# null counts: parse 01_completeness.md (only the column table; columns not listed there with nulls => 0)
nulls_duck = {}
rp = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'results', '01_completeness.md')
with open(rp) as f:
    sec = False
    for ln in f:
        if ln.startswith('## Column completeness'): sec = True; continue
        if sec and ln.startswith('## '): break
        if sec and ln.startswith('|') and not ln.startswith('|--') and 'source_file' not in ln:
            c = [x.strip() for x in ln.strip().strip('|').split('|')]
            nulls_duck[(c[0], c[1])] = c[4]
for k, _ in out:
    if k.startswith('nulls '):
        t, col = k[6:].split('.', 1)
        DUCK[k] = '788976' if (t, col) in (('payments', 'error_code'), ('payments', 'reason')) else nulls_duck.get((t, col), 'absent')  # all-null cols listed in 'Columns with no values at all'

def tok_match(i, d):
    if '.' in d:
        try:
            q = Decimal(1).scaleb(-len(d.split('.')[1]))
            return Decimal(i).quantize(q, rounding=ROUND_HALF_UP) == Decimal(d)
        except Exception: return i == d
    return i == d
def match(i, d):
    if ' / ' in d:
        a, b = i.split(' / '), d.split(' / ')
        return len(a) == len(b) and all(tok_match(x, y) for x, y in zip(a, b))
    return tok_match(i, d)

yes = no = 0; rows = []; mism = []
for k, v in out:
    d = DUCK.get(k)
    if d is None:
        rows.append((k, v, 'n/a (not reported)', 'n/a')); continue
    if d == 'absent': d = '0 (not listed: no nulls)'; ok = (v == '0')
    else: ok = match(v, d)
    if ok: yes += 1
    else: no += 1; mism.append(k)
    rows.append((k, v, d, 'yes' if ok else 'no'))
print('# Independent verification (pure Python stdlib, Decimal)\n')
print(f'Checks compared: {yes+no}; matched: {yes}; mismatched: {no}; not reported by DuckDB: {sum(1 for r in rows if r[3]=="n/a")}\n')
print('Match = independent value rounded to the precision DuckDB printed. DuckDB business tables (06) print USD at 6dp after a cast, so USD sums that include the 689 high-precision payments differ in the 5th-6th decimal.\n')
print('| check | independent value | DuckDB value | match |\n|---|---|---|---|')
for r in rows: print('| ' + ' | '.join(x.replace('|', '/') for x in r) + ' |')
if mism:
    print('\n## Mismatches\n')
    for k in mism: print('- ' + k)
