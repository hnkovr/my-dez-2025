from dagster import Definitions, define_asset_job
from dagster_dez.assets import trips_raw, zones

ingest_job = define_asset_job("ingest_job", selection=["*"])

defs = Definitions(
    assets=[trips_raw, zones],
    jobs=[ingest_job],
)
