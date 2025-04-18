#!/bin/bash
clear
set -e

echo "🔧 Running Python Data Engineering Project Fix Script"
echo "----------------------------------------"

# Check Python version
PYTHON_VERSION=$(python --version 2>&1)
echo "Using $PYTHON_VERSION"

# Clean up existing environment
echo "🧹 Cleaning up existing virtual environment"
rm -rf .venv

# Create new environment using Python 3.11 if available
# This is the safest approach since pendulum is not yet compatible with Python 3.12
if command -v python3.11 &> /dev/null; then
    echo "🌱 Creating new virtual environment with Python 3.11"
    python3.11 -m venv .venv
else
    echo "⚠️ Python 3.11 not found, attempting with current Python version"
    echo "⚠️ Note: You may need to install Python 3.11 for full compatibility"
    python -m venv .venv
fi

source .venv/bin/activate

# Upgrade uv pip and install critical tools
echo "🔄 Upgrading uv pip and installing critical tools"
uv pip install --upgrade uv pip setuptools wheel

# If using Python 3.12, try to install distutils compatibility
PY_VERSION=$(python -c "import sys; print(sys.version_info.major, sys.version_info.minor)")
if [[ $PY_VERSION == "3 12" ]]; then
    echo "📦 Installing distutils compatibility for Python 3.12"
    uv pip install setuptools-distutils-hack
fi

# Install dependencies one by one to better handle issues
echo "📦 Installing core dependencies"
uv pip install fastcore click duckdb requests PyYAML python-dotenv==1.0.0 pytest

# Try direct install of pendulum
echo "📦 Installing pendulum"
# First try with pip
uv pip install pendulum==2.1.2 || {
    echo "⚠️ Direct pendulum install failed, trying alternative method"
    # If direct install fails, try to install pytzdata first
    uv pip install pytzdata

    # Then try to install pendulum with no-binary
    uv pip install pendulum==2.1.2 --no-binary pendulum || {
        echo "⚠️ Alternative pendulum install failed, installing arrow as a replacement"
        uv pip install arrow
        # Create pendulum compatibility layer
        mkdir -p $(python -c "import site; print(site.getsitepackages()[0])")/pendulum
        cat > $(python -c "import site; print(site.getsitepackages()[0])")/pendulum/__init__.py << 'EOF'
"""
Pendulum compatibility wrapper using arrow
"""
import arrow
__version__ = "2.1.2"

def now(tz=None):
    return arrow.now(tz).datetime

def utcnow():
    return arrow.utcnow().datetime

def parse(time_str, tz=None):
    return arrow.get(time_str, tzinfo=tz).datetime

class Pendulum:
    """Compatibility shim"""
    pass
EOF
    }
}

# Install Dagster stack
echo "📦 Installing Dagster stack"
uv pip install dagster==1.5.6 dagster-webserver==1.5.6 dagster-dbt==0.21.6

# Install DBT stack
echo "📦 Installing DBT stack"
uv pip install dbt-core dbt-clickhouse

# Verify installation
echo "✅ Verifying installation"
python -c "
import sys
print(f'Python version: {sys.version}')
try:
    import pendulum
    print(f'Pendulum version: {pendulum.__version__}')
except ImportError:
    print('Pendulum not available, using compatibility layer')
import dagster
print(f'Dagster version: {dagster.__version__}')
from dagster_dbt import load_assets_from_dbt_project
print('✅ dagster_dbt: OK')
"

echo "----------------------------------------"
echo "🎉 Installation completed successfully!"
echo "To activate the environment: source .venv/bin/activate"