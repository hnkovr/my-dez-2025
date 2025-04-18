#!/bin/bash
TEST_DAGSTER=false

clear
echo "# python: $(which python)  # $(python --version)"
#f=install-python@3.12-macos.sh
#echo "# $f" && cat $f
#sh $f

echo "# requirements.txt" && cat requirements.txt
echo "# $0" && cat $0

cd /Users/nk.myg/github/@dataengy/my-dez-2025/

(set -x
rm -rf .venv
)

uv venv .venv
source .venv/bin/activate

(set -x
# The key fix: Install pendulum 2.x which is compatible with dagster 1.5.6
# Note: It's pendulum 2.x (not 3.x) that properly works with dagster 1.5.6
#uv pip install 'pendulum>=2.0.0,<3.0.0'

# Install other requirements

uv pip install -r requirements.txt

# Test if dagster_dbt works
#if [[ $TEST_DAGSTER ]]; then
#  python -c "
#import pendulum; pendulum.Pendulum = -1
#from dagster_dbt import load_assets_from_dbt_project; print('✅ dagster_dbt: OK')
#  "
#fi

)
