from dagster import asset
import duckdb
from pathlib import Path

@asset
def trips_raw():
    duckdb.sql("""
        CREATE OR REPLACE TABLE trips_raw AS
        SELECT * FROM parquet_scan('data/yellow_tripdata_2025-01.parquet')
    """)
    return "trips_raw ✅"

@asset
def zones():
    duckdb.sql("""
        CREATE OR REPLACE TABLE zones AS
        SELECT * FROM read_csv_auto('data/taxi_zone_lookup.csv', header=True)
    """)
    return "zones ✅"
