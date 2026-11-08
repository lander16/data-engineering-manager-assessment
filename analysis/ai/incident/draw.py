"""Draw the incident targets for a round with its fixed seed, and write the answer key.

usage: python analysis/ai/incident/draw.py --round 1

Reads felix.duckdb read-only. Writes work/round<N>/draw.json and work/round<N>/key.json,
which the agents never see. Symptoms were written by hand for each round's draw, before
any run, and live in symptoms.json.
"""
import argparse
import datetime as dt
import json
import random
import sys
from pathlib import Path

import duckdb

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from common import PROJECT_DB  # noqa: E402

ROUNDS = {
    1: dict(seed=20261107, used=set(), label=["PROVIDER 3", "PROVIDER 7"], months=["2026-02", "2026-03", "2026-04"],
            ids=["k3", "m7", "q2", "t9", "v4", "w6", "x8", "y5"]),
    2: dict(seed=20261108, used={("PROVIDER 8", "HN", "CASH"), ("PROVIDER 4", "CO", "WALLET")},
            label=["PROVIDER 7", "PROVIDER 11"], months=["2026-03", "2026-04"],
            ids=["b2", "c5", "d7", "f3", "h6", "j4", "n8", "p9"]),
}
# Real anomalies from a weekly scan: provider, country, type, first week, last week. A draw within 7 days is redrawn.
REAL = [("PROVIDER 2", "MX", "BANK", "2026-06-08", "2026-06-28"), ("PROVIDER 4", "CO", "WALLET", "2026-04-20", "2026-05-10"),
        ("PROVIDER 7", "GT", "BANK", "2026-06-08", "2026-06-14"), ("PROVIDER 4", "MX", "BANK", "2026-03-30", "2026-04-12"),
        ("PROVIDER 7", "MX", "CASH", "2026-06-29", "2026-07-05")]
D = dt.date.fromisoformat


def draw(con, cfg):
    rng = random.Random(cfg["seed"])

    def day(a, b):
        return D(a) + dt.timedelta(days=rng.randrange((D(b) - D(a)).days + 1))

    routes = con.execute("""
        with r as (
            select provider, country_code, payout_type, count(*) filter (attempt_status = 'delivered') d,
                   min(attempt_at)::date::varchar first_day
            from int_payout_attempts where attempt_status <> 'missing' and payout_type <> 'CASH DELIVERY' group by all),
        multi as (select provider from r where d >= 500 group by 1 having count(*) >= 2)
        select * from r where d >= 8000 and provider <> 'PROVIDER 12' and provider in (select provider from multi)
        order by 1, 2, 3""").fetchall()

    def pick_route(a, b, days, exclude=()):
        while True:
            p, co, ty, _, first = rng.choice(routes)
            s = day(a, b)
            e = s + dt.timedelta(days=days - 1)
            if p in exclude or (p, co, ty) in cfg["used"] or D(first) > s - dt.timedelta(days=30):
                continue
            if any(p == x[0] and co == x[1] and ty == x[2] and s <= D(x[4]) + dt.timedelta(days=7)
                   and e >= D(x[3]) - dt.timedelta(days=7) for x in REAL):
                continue
            return dict(provider=p, country=co, payout_type=ty, start=str(s), end=str(e))

    out = {"a": dict(kind="failures", rate=0.30, **pick_route("2026-03-09", "2026-07-20", 14))}
    out["b"] = dict(kind="failures", rate=0.30, **pick_route("2026-08-24", "2026-09-08", 10, exclude=(out["a"]["provider"],)))
    label = [p for p in cfg["label"] if p not in (out["a"]["provider"], out["b"]["provider"])] or ["PROVIDER 3"]
    out["c"] = dict(kind="label", provider=rng.choice(label), start=str(day("2026-05-25", "2026-07-31")))
    while True:
        s = day("2026-04-01", "2026-08-31")
        if abs((s - D("2026-06-12")).days) > 3:
            break
    out["d"] = dict(kind="loss", start=str(s), end=str(s + dt.timedelta(days=1)))
    promo = con.execute("""
        select country_code, payout_type, count(*) filter (promotion_usd > 0) p from int_payout_attempts
        where payout_type in ('BANK', 'CASH', 'WALLET') group by all having p >= 400 order by 1, 2""").fetchall()
    while True:
        co, ty, _ = rng.choice(promo)
        s = day("2026-03-01", "2026-08-31")
        e = s + dt.timedelta(days=3)
        n = con.execute(f"""select count(*) from int_payout_attempts where promotion_usd > 0 and country_code = '{co}'
                            and payout_type = '{ty}' and attempt_at::date between '{s}' and '{e}'""").fetchone()[0]
        if n >= 5:
            break
    out["e"] = dict(kind="amount", country=co, payout_type=ty, start=str(s), end=str(e), factor=100, promo_rows=n)
    out["f"] = dict(kind="chargeback", month=rng.choice(cfg["months"]))
    for k, i in zip(["a", "b", "c", "d", "e", "f", "g1", "g2"], rng.sample(cfg["ids"], 8)):
        out.setdefault(k, dict(kind="control"))["id"] = i
    return out


def key(scenarios, symptoms):
    category = dict(failures="provider_failures", label="label_change", loss="data_loss", amount="amount_error",
                    chargeback="chargeback_data", control="none")
    fields = dict(failures=["provider", "country", "payout_type"], label=["provider"], amount=["country", "payout_type"])
    out = {}
    for name, sc in scenarios.items():
        start = sc.get("start") or (sc["month"] + "-01" if "month" in sc else None)
        out[sc["id"]] = dict(id=sc["id"], scenario=name, kind=sc["kind"], symptom=symptoms[name],
                             category=category[sc["kind"]], start_date=start,
                             required={f: sc[f] for f in fields.get(sc["kind"], [])})
    return out


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--round", type=int, choices=ROUNDS, required=True)
    args = parser.parse_args()
    cfg = ROUNDS[args.round]
    with duckdb.connect(str(PROJECT_DB), read_only=True, config={"TimeZone": "UTC"}) as con:
        scenarios = draw(con, cfg)
    symptoms = json.loads((HERE / "symptoms.json").read_text())[str(args.round)]
    out = HERE / "work" / f"round{args.round}"
    out.mkdir(parents=True, exist_ok=True)
    (out / "draw.json").write_text(json.dumps(dict(seed=cfg["seed"], scen=scenarios), indent=1) + "\n")
    (out / "key.json").write_text(json.dumps(key(scenarios, symptoms), indent=1) + "\n")
    print(f"Drew {len(scenarios)} scenarios for round {args.round} with seed {cfg['seed']} into {out}")


if __name__ == "__main__":
    main()
