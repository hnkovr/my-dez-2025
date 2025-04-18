{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='pickup_datetime',
    partition_by="toYYYYMM(pickup_datetime)"
) }}

SELECT
    VendorID,
    toDate(pickup_datetime) AS trip_date,
    pickup_datetime,
    dropoff_datetime,
    passenger_count,
    trip_distance,
    PULocationID,
    DOLocationID,
    payment_type,
    total_amount
FROM trips_raw
