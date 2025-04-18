# my-dez-2025

🚕 Minimal Data Engineering pipeline for NYC Yellow Taxi 2025 trip data
Built with **DuckDB**, **ClickHouse**, **dbt**, and **Metabase**.
All runs **locally**, with optional support for Docker and Dagster-ODP.

## Setup

```bash
make install
make run
```

## Project structure

- OLTP: DuckDB
- DWH: ClickHouse
- Transforms: dbt
- Dashboard: Metabase
- Orchestration: Makefile + utils.sh (optional: Dagster)

## Authors

- @vndv, 2025
