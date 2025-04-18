#!/usr/bin/env python3
# ./src/ingest_oltp.py

import os
import duckdb
import psycopg2
from psycopg2.extras import execute_values
from pathlib import Path
from dotenv import load_dotenv
from logger import get_logger

# Initialize logger
log = get_logger("ingest")

# Load environment variables
load_dotenv()

# Paths
DATA_PATH = Path("data")
DB_PATH = DATA_PATH / "nyc_trips.duckdb"

# PostgreSQL connection parameters
PG_PARAMS = {
    "host": os.getenv("POSTGRES_HOST", "localhost"),
    "port": os.getenv("POSTGRES_PORT", "5432"),
    "user": os.getenv("POSTGRES_USER", "admin"),
    "password": os.getenv("POSTGRES_PASSWORD", "admin"),
    "dbname": os.getenv("POSTGRES_DBNAME", "db")
}

def create_pg_tables(pg_conn):
    """Create PostgreSQL tables if they don't exist"""
    cursor = pg_conn.cursor()

    # Create trips table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS trips (
        id SERIAL PRIMARY KEY,
        vendor_id INTEGER,
        pickup_datetime TIMESTAMP,
        dropoff_datetime TIMESTAMP,
        passenger_count FLOAT,
        trip_distance FLOAT,
        pickup_location_id INTEGER,
        dropoff_location_id INTEGER,
        payment_type INTEGER,
        fare_amount FLOAT,
        tip_amount FLOAT,
        total_amount FLOAT
    )
    """)

    # Create zones table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS zones (
        location_id INTEGER PRIMARY KEY,
        borough TEXT,
        zone TEXT,
        service_zone TEXT
    )
    """)

    pg_conn.commit()
    log.info("✅ PostgreSQL tables created")

def transform_trips(con):
    """Transform trips data before loading to PostgreSQL"""
    con.execute("""
    CREATE OR REPLACE TABLE trips_transformed AS
    SELECT
        CAST(ROW_NUMBER() OVER () AS INTEGER) as id,
        CAST(VendorID AS INTEGER) as vendor_id,
        tpep_pickup_datetime as pickup_datetime,
        tpep_dropoff_datetime as dropoff_datetime,
        CAST(passenger_count AS FLOAT) as passenger_count,
        CAST(trip_distance AS FLOAT) as trip_distance,
        CAST(PULocationID AS INTEGER) as pickup_location_id,
        CAST(DOLocationID AS INTEGER) as dropoff_location_id,
        CAST(payment_type AS INTEGER) as payment_type,
        CAST(fare_amount AS FLOAT) as fare_amount,
        CAST(tip_amount AS FLOAT) as tip_amount,
        CAST(total_amount AS FLOAT) as total_amount
    FROM trips_raw
    """)
    log.info("✅ trips_transformed table created")

    # Preview transformed data
    count = con.execute("SELECT COUNT(*) FROM trips_transformed").fetchone()[0]
    log.info(f"📊 trips_transformed: {count} rows")

def load_to_postgres(duck_con, pg_conn):
    """Load data from DuckDB to PostgreSQL"""
    pg_cursor = pg_conn.cursor()

    # Load zones data
    log.info("Loading zones data to PostgreSQL...")
    zones_data = duck_con.execute("SELECT * FROM zones").fetchall()
    execute_values(
        pg_cursor,
        "INSERT INTO zones (location_id, borough, zone, service_zone) VALUES %s ON CONFLICT DO NOTHING",
        [(row[0], row[1], row[2], row[3]) for row in zones_data],
        template="(%s, %s, %s, %s)"
    )
    log.info(f"✅ Loaded {len(zones_data)} zones to PostgreSQL")

    # Load trips data in batches
    log.info("Loading trips data to PostgreSQL...")
    batch_size = 10000
    total_rows = duck_con.execute("SELECT COUNT(*) FROM trips_transformed").fetchone()[0]

    for offset in range(0, total_rows, batch_size):
        trips_batch = duck_con.execute(f"""
            SELECT * FROM trips_transformed
            LIMIT {batch_size} OFFSET {offset}
        """).fetchall()

        if not trips_batch:
            break

        execute_values(
            pg_cursor,
            """
            INSERT INTO trips (
                id, vendor_id, pickup_datetime, dropoff_datetime, 
                passenger_count, trip_distance, pickup_location_id, 
                dropoff_location_id, payment_type, fare_amount, 
                tip_amount, total_amount
            ) VALUES %s
            ON CONFLICT (id) DO NOTHING
            """,
            trips_batch,
            template="(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
        )

        pg_conn.commit()
        log.info(f"✅ Loaded batch {offset//batch_size + 1}/{(total_rows//batch_size) + 1} to PostgreSQL")

    # Verify loaded data
    pg_cursor.execute("SELECT COUNT(*) FROM trips")
    trips_count = pg_cursor.fetchone()[0]
    pg_cursor.execute("SELECT COUNT(*) FROM zones")
    zones_count = pg_cursor.fetchone()[0]

    log.info(f"📊 PostgreSQL trips table: {trips_count} rows")
    log.info(f"📊 PostgreSQL zones table: {zones_count} rows")

def main():
    # Connect to DuckDB
    duck_con = duckdb.connect(DB_PATH)
    log.info("Connected to DuckDB")

    # Parquet: Yellow Trips
    trip_file = DATA_PATH / "yellow_tripdata_2025-01.parquet"
    log.info(f"Reading: {trip_file}")
    duck_con.execute(f"CREATE OR REPLACE TABLE trips_raw AS SELECT * FROM parquet_scan('{trip_file}')")
    log.info("✅ trips_raw table created")

    # CSV: Zones
    zone_file = DATA_PATH / "taxi_zone_lookup.csv"
    duck_con.execute(f"""
        CREATE OR REPLACE TABLE zones AS
        SELECT * FROM read_csv_auto('{zone_file}', header=True)
    """)
    log.info("✅ zones table created")

    # Preview
    for table in ("trips_raw", "zones"):
        count = duck_con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        log.info(f"📊 {table}: {count} rows")

    # Transform data
    transform_trips(duck_con)

    # Connect to PostgreSQL
    try:
        log.info(f"Connecting to PostgreSQL at {PG_PARAMS['host']}:{PG_PARAMS['port']}...")
        pg_conn = psycopg2.connect(**PG_PARAMS)
        log.info("Connected to PostgreSQL")

        # Create PostgreSQL tables
        create_pg_tables(pg_conn)

        # Load data from DuckDB to PostgreSQL
        load_to_postgres(duck_con, pg_conn)

        pg_conn.close()
        log.info("PostgreSQL connection closed")

    except Exception as e:
        log.error(f"PostgreSQL Error: {e}")

    # Close DuckDB connection
    duck_con.close()
    log.info("DuckDB connection closed")
    log.info("Ingestion complete!")

if __name__ == "__main__":
    main()