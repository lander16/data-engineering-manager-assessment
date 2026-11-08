"""Score incident runs against work/round<N>/key.json.

usage: python analysis/ai/incident/score.py --round 1

Strict means is_incident true, the right category, the required provider, country, and payout
type, and a start date within 2 days. A control passes when the agent says there is no incident.
"""
import argparse
import collections
import datetime as dt
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from common import last_json, result_event  # noqa: E402

COUNTRIES = {"MEXICO": "MX", "GUATEMALA": "GT", "HONDURAS": "HN", "COLOMBIA": "CO", "EL SALVADOR": "SV",
             "NICARAGUA": "NI", "DOMINICAN REPUBLIC": "DO", "ECUADOR": "EC", "PERU": "PE", "BRAZIL": "BR",
             "COSTA RICA": "CR"}


def provider(x):
    m = re.search(r"(\d+)", str(x or ""))
    return f"PROVIDER {m.group(1)}" if m else None


def country(x):
    x = str(x or "").strip().upper()
    return COUNTRIES.get(x, x) or None


def payout_type(x):
    return str(x or "").strip().upper() or None


NORMALISE = dict(provider=provider, country=country, payout_type=payout_type)


def boolish(x):
    if isinstance(x, str) and x.strip().lower() in ("true", "false"):
        return x.strip().lower() == "true"
    return x if isinstance(x, bool) else None


def date(x):
    try:
        return dt.date.fromisoformat(str(x)[:10])
    except ValueError:
        return None


def score(k, a):
    r = dict(answered=a is not None, category_ok=False, entity_ok=False, date_ok=False, strict=False,
             localised=False, control_pass=None)
    if k["category"] == "none":
        r["control_pass"] = a is not None and boolish(a.get("is_incident")) is False
        r["strict"] = r["control_pass"]
        return r
    if a is None:
        return r
    r["category_ok"] = boolish(a.get("is_incident")) is True and a.get("category") == k["category"]
    r["entity_ok"] = all(NORMALISE[f](a.get(f)) == v for f, v in k["required"].items())
    d = date(a.get("start_date"))
    r["date_ok"] = d is not None and abs((d - date(k["start_date"])).days) <= 2
    r["localised"] = r["entity_ok"] and r["date_ok"]
    r["strict"] = r["category_ok"] and r["localised"]
    return r


def pct(n, d):
    return f"{n}/{d} ({100 * n / d:.0f}%)" if d else "-"


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--round", type=int, required=True)
    args = parser.parse_args()
    round_dir = HERE / "work" / f"round{args.round}"
    key = json.loads((round_dir / "key.json").read_text())
    rows = []
    for path in sorted((round_dir / "transcripts").glob("*.jsonl")):
        sid, arm, model, rep = path.stem.split("_")
        res = result_event(path)
        k, a = key[sid], last_json(res.get("result", ""), "is_incident")
        rows.append(dict(tag=path.stem, scenario=k["scenario"], arm=arm, model=model, cost=res.get("total_cost_usd", 0),
                         turns=res.get("num_turns", 0), error=res.get("subtype") if res.get("is_error") or not res else "",
                         answer=a, **score(k, a)))
    (round_dir / "scored.json").write_text(json.dumps(rows, indent=1, default=str) + "\n")

    cells = collections.defaultdict(list)
    for r in rows:
        cells[(r["arm"], r["model"])].append(r)
    print("| Arm | Model | Runs | Strict | Localised | Category | Entity | Date | Control pass | Avg cost | Avg turns |")
    print("|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|")
    summary = {}
    for (arm, model), v in sorted(cells.items()):
        inc = [r for r in v if r["control_pass"] is None]
        ctl = [r for r in v if r["control_pass"] is not None]
        s = lambda f: sum(r[f] for r in inc)  # noqa: E731
        summary[(arm, model)] = (s("strict"), len(inc), sum(r["control_pass"] for r in ctl), len(ctl))
        print(f"| {arm} | {model} | {len(v)} | {pct(s('strict'), len(inc))} | {pct(s('localised'), len(inc))} "
              f"| {pct(s('category_ok'), len(inc))} | {pct(s('entity_ok'), len(inc))} | {pct(s('date_ok'), len(inc))} "
              f"| {pct(sum(r['control_pass'] for r in ctl), len(ctl))} | ${sum(r['cost'] for r in v) / len(v):.3f} "
              f"| {sum(r['turns'] for r in v) / len(v):.0f} |")

    print("\n| Scenario | " + " | ".join(f"{a} {m}" for a, m in sorted(cells)) + " |\n|---|" + "---:|" * len(cells))
    for sc in sorted({k["scenario"] for k in key.values()}):
        line = [f"{sum(r['strict'] for r in v if r['scenario'] == sc)}/{sum(r['scenario'] == sc for r in v)}"
                for _, v in sorted(cells.items())]
        print(f"| {sc} | " + " | ".join(line) + " |")

    print("\nVerdict by model (bar: iface strict >= 80% of incident runs, and every control run says no incident)")
    for (arm, model), (s, n, cp, cn) in sorted(summary.items()):
        if arm != "iface" or not n:
            continue
        raw = summary.get(("raw", model))
        gap = f"; iface minus raw strict {100 * (s / n - raw[0] / raw[1]):.0f} points" if raw and raw[1] else ""
        verdict = "CLEARS" if s / n >= 0.8 and cp == cn else "MISSES"
        print(f"  {model}: strict {s}/{n}, control {cp}/{cn} -> {verdict}{gap}")
    print(f"\nRuns {len(rows)}, total cost ${sum(r['cost'] for r in rows):.2f}, "
          f"unanswered {sum(not r['answered'] for r in rows)}")
    print("\nMisses:")
    for r in rows:
        if not r["strict"]:
            a = r["answer"] or {}
            print(f"  {r['tag']} [{r['scenario']}] category={r['category_ok']} entity={r['entity_ok']} "
                  f"date={r['date_ok']} error={r['error']} -> {a.get('is_incident')} {a.get('category')} "
                  f"{a.get('provider')} {a.get('country')} {a.get('payout_type')} {a.get('start_date')}")


if __name__ == "__main__":
    main()
