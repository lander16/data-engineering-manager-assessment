import os
import sys

import duckdb

here = os.path.dirname(os.path.abspath(__file__))
name = "felix.duckdb" if os.path.exists(os.path.join(here, "felix.duckdb")) else "data.duckdb"
con = duckdb.connect(os.path.join(here, name), read_only=True, config={"TimeZone": "UTC"})
con.execute("set enable_external_access=false")
sql = sys.argv[1]
if any(w in sql.lower() for w in ("read_csv", "read_parquet", "glob(", "attach", "copy ", "install", "load ")):
    sys.exit("blocked")
result = con.execute(sql)
print(" | ".join(d[0] for d in result.description))
for i, row in enumerate(result.fetchall()):
    if i >= 60:
        print("...truncated")
        break
    print(" | ".join(str(v) for v in row))
