# Inzhenerka Dagster Project with dbt Integration

## Setup

1. Create a virtual environment:
   ```
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```

2. Install dependencies:
   ```
   pip install -r requirements.txt
   pip install -e .
   ```

3. Configure environment variables:
   - Copy `.env.template` to `.env`
   - Fill in your credentials

4. Initialize dbt:
   ```
   cd dbt-scooters
   dbt deps
   dbt parse
   ```

5. Run Dagster:
   ```
   dagster dev -m inzhenerka_dagster
   ```

## Project Structure

- `inzhenerka_dagster/`: Main package
  - `__init__.py`: Definitions setup
  - `assets.py`: Data assets (source and dbt)
  - `resources.py`: External resources (API, etc)
  - `iomanagers.py`: I/O manager for PostgreSQL
  - `jobs.py`: Pipeline job definitions
  - `hooks.py`: Success/failure hooks
  - `ops.py`: Individual operations
  - `graphs.py`: Operation graphs
  - `schedules.py`: Run schedules
- `dbt-scooters/`: dbt project
  - Transformation models for data warehouse
