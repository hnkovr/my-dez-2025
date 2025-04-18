import duckdb
from pathlib import Path
from logger import get_logger

log = get_logger("ingest")

##!? fixme DATA_PATH = Path("../data")
DATA_PATH = Path("data")
DB_PATH = DATA_PATH / "nyc_trips.duckdb"

def main():
    con = duckdb.connect(DB_PATH)
    log.info("Connected to DuckDB")

    # Parquet: Yellow Trips
    trip_file = DATA_PATH / "yellow_tripdata_2025-01.parquet"
    log.info(f"Reading: {trip_file}")
    con.execute(f"CREATE OR REPLACE TABLE trips_raw AS SELECT * FROM parquet_scan('{trip_file}')")
    log.info("✅ trips_raw table created")

    # CSV: Zones
    zone_file = DATA_PATH / "taxi_zone_lookup.csv"
    con.execute(f"""
        CREATE OR REPLACE TABLE zones AS
        SELECT * FROM read_csv_auto('{zone_file}', header=True)
    """)
    log.info("✅ zones table created")

    # Preview
    for table in ("trips_raw", "zones"):
        count = con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        log.info(f"📊 {table}: {count} rows")

if __name__ == "__main__":
    main()
