clear
# echo "# user: $(whoami)"
echo "# python: $(which python)  # $(python --version)"

cd /Users/nk.myg/github/@dataengy/my-dez-2025/

(set -x
rm -rf .venv
)
set -e
echo "# requirements.txt" && cat requirements.txt
echo "# $0" && cat $0

#sh install-rush.sh

uv venv .venv
source .venv/bin/activate

(set -x
uv pip install 'pendulum>=2.1.3'
uv pip install -r requirements.txt

python -c "from dagster_dbt import load_assets_from_dbt_project; print('✅ dagster_dbt: OK')"
)
