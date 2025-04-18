{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='trip_date, PULocationID',
    partition_by="toYYYYMM(trip_date)"
) }}

SELECT
    trip_date,
    PULocationID,
    DOLocationID,
    COUNT(*) AS trip_count,
    ROUND(AVG(total_amount), 2) AS avg_fare
FROM {{ ref('stg_trips') }}
GROUP BY trip_date, PULocationID, DOLocationID
