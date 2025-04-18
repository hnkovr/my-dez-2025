from dagster import Definitions
from dagster_dez.assets_dbt import dbt_assets
# from assets_dbt import dbt_assets

from dagster_dbt import build_schedule_from_dbt_selection, build_job

dbt_job = build_job(name="dbt_run_job", selection="*")

defs = Definitions(
    assets=[dbt_assets],
    jobs=[dbt_job],
)
