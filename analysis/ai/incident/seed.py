"""Apply one drawn scenario to the raw tables of a database copy."""
import duckdb

FAILED = "('failed', 'rejected', 'error_sending_payout_request', 'payout_not_processed')"
DELIVERED = "('paid', 'success', 'completed', 'delivered')"


def seed(db, name, sc):
    """Seed scenario `name` with draw `sc` into db. Returns the affected row counts."""
    con = duckdb.connect(str(db), config={"TimeZone": "UTC"})
    n = lambda sql: con.execute(sql).fetchone()[0]  # noqa: E731
    kind, res = sc["kind"], {}
    if kind == "failures":
        p, co, ty, s, e = sc["provider"], sc["country"], sc["payout_type"], sc["start"], sc["end"]
        pct = int(sc["rate"] * 1000)
        # Real failed rows on this route are the template, so seeded rows look like real ones.
        con.execute(f"""create temp table tmpl as
            select status, raw_status, provider_status, row_number() over (order by id) - 1 i
            from raw.disbursements where disbursement_provider = '{p}' and destination_country = '{co}'
              and type = '{ty}' and lower(status) in {FAILED}""")
        m = n("select count(*) from tmpl")
        assert m > 0
        con.execute(f"""create temp table pick as
            select d.id did, r.payment_id pid, hash(d.id || '{name}') h
            from raw.disbursements d join raw.receipts r on r.disbursement_id = d.id join raw.payments y on y.id = r.payment_id
            where d.disbursement_provider = '{p}' and d.destination_country = '{co}' and d.type = '{ty}'
              and lower(d.status) in {DELIVERED} and y.status = 'SUCCESSFUL'
              and substr(r.created_at, 1, 10) between '{s}' and '{e}'
              and (select count(*) from raw.receipts x where x.payment_id = r.payment_id) = 1""")
        res["eligible"] = n("select count(*) from pick")
        con.execute(f"delete from pick where h % 1000 >= {pct}")
        res["flipped"] = n("select count(*) from pick")
        con.execute(f"""update raw.disbursements d set status = t.status, raw_status = t.raw_status,
                            provider_status = t.provider_status
                        from pick x join tmpl t on t.i = x.h % {m} where d.id = x.did""")
        # 96% of real unrescued failures sit on a REFUNDED payment, with null or SUCCESSFUL detail at about 60/40.
        con.execute("""update raw.payments y set status = 'REFUNDED',
                           detailed_status = case when x.h % 10 < 6 then null else 'SUCCESSFUL' end
                       from pick x where y.id = x.pid""")
    elif kind == "label":
        where = (f"where disbursement_provider = '{sc['provider']}' and lower(status) = 'failed'"
                 f" and substr(created_at, 1, 10) >= '{sc['start']}'")
        res["flipped"] = n(f"select count(*) from raw.disbursements {where}")
        con.execute(f"""update raw.disbursements set
                status = case when status = 'Failed' then 'Cancelled' else 'CANCELLED' end,
                raw_status = case when raw_status = upper(raw_status) then 'CANCELLED' else 'cancelled' end
            {where}""")
    elif kind == "loss":
        where = f"where substr(created_at, 1, 10) between '{sc['start']}' and '{sc['end']}'"
        res["deleted"] = n(f"select count(*) from raw.receipts {where}")
        con.execute(f"delete from raw.receipts {where}")
    elif kind == "amount":
        where = f"""d.id = r.disbursement_id and d.type = '{sc['payout_type']}'
            and r.destination_country_code = '{sc['country']}'
            and substr(r.created_at, 1, 10) between '{sc['start']}' and '{sc['end']}'
            and cast(r.promotion_amount as decimal(18, 2)) > 0"""
        res["rows"] = n(f"select count(*) from raw.receipts r, raw.disbursements d where {where}")
        con.execute(f"""update raw.receipts r
            set promotion_amount = rtrim(rtrim(printf('%.2f', cast(r.promotion_amount as double) * {sc['factor']}), '0'), '.')
            from raw.disbursements d where {where}""")
    elif kind == "chargeback":
        where = f"where has_dispute_chargeback = 'True' and substr(created_at, 1, 7) = '{sc['month']}'"
        res["cleared"] = n(f"select count(*) from raw.payments {where}")
        con.execute(f"update raw.payments set has_dispute_chargeback = 'False' {where}")
    elif kind != "control":
        raise ValueError(f"unknown scenario kind {kind}")
    con.close()
    return res
