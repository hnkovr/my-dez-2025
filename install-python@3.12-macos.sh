#!/bin/bash
# ~/gibus/dwh17/dbt-CH/utils/install-python@3.12-macos.sh

# Set script to exit immediately if a command fails
set -e

echo "🔍 Checking if Homebrew is installed..."
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed. Installing now..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✅ Homebrew is already installed."
fi

echo "🔄 Updating Homebrew..."
brew update

echo "🚀 Handling Python 3.13 dependencies and removal..."
# Get dependent packages
DEPS=$(brew deps --installed python@3.13 2>/dev/null || echo "")
if [ ! -z "$DEPS" ]; then
    echo "💡 Python 3.13 has dependencies. Will attempt to reconfigure them to use Python 3.12 first."

    # Install Python 3.12 first
    echo "📥 Installing Python 3.12..."
    brew install python@3.12 || brew upgrade python@3.12

    # Force reinstall dependencies to point to Python 3.12
    echo "🔄 Reinstalling dependencies to use Python 3.12 instead..."
    for pkg in $DEPS; do
        echo "  - Reinstalling $pkg..."
        brew reinstall $pkg || echo "  ⚠️ Failed to reinstall $pkg, continuing anyway..."
    done

    # Now try to uninstall Python 3.13
    echo "🗑️ Attempting to uninstall Python 3.13..."
    brew uninstall python@3.13 || {
        echo "⚠️ Could not automatically uninstall Python 3.13 due to dependencies."
        echo "💡 You may need to manually uninstall it later with:"
        echo "    brew uninstall --ignore-dependencies python@3.13"
    }
else
    echo "📥 Installing Python 3.12..."
    brew install python@3.12 || brew upgrade python@3.12

    echo "🗑️ Uninstalling Python 3.13 if it exists..."
    brew uninstall python@3.13 || echo "Python 3.13 was not installed through Homebrew."
fi

echo "⚙️ Unlinking other Python versions and linking Python 3.12..."
brew unlink python@3.10 python@3.11 python@3.13 2>/dev/null || true
brew link --force --overwrite python@3.12

# Get the path to the Python 3.12 binary
PYTHON312_BIN=$(brew --prefix python@3.12)/bin

echo "🔧 Creating proper system symlinks for Python 3.12..."
# Create a more comprehensive set of symlinks
sudo rm -f /usr/local/bin/python
sudo rm -f /usr/local/bin/python3
sudo rm -f /usr/local/bin/pip
sudo rm -f /usr/local/bin/pip3

sudo ln -sf $PYTHON312_BIN/python3.12 /usr/local/bin/python
sudo ln -sf $PYTHON312_BIN/python3.12 /usr/local/bin/python3
sudo ln -sf $PYTHON312_BIN/pip3.12 /usr/local/bin/pip
sudo ln -sf $PYTHON312_BIN/pip3.12 /usr/local/bin/pip3

# Update PATH in shell profiles
echo "🔧 Updating PATH in shell profiles..."
# Remove existing Python PATH entries to avoid duplication
sed -i '' '/export PATH="\/usr\/local\/opt\/python@/d' ~/.zshrc 2>/dev/null || true
sed -i '' '/export PATH="\/usr\/local\/opt\/python@/d' ~/.bash_profile 2>/dev/null || true

# Add new PATH at the beginning to ensure it takes precedence
echo 'export PATH="'$PYTHON312_BIN':$PATH"' | cat - ~/.zshrc > /tmp/zshrc && mv /tmp/zshrc ~/.zshrc
echo 'export PATH="'$PYTHON312_BIN':$PATH"' | cat - ~/.bash_profile > /tmp/bash_profile && mv /tmp/bash_profile ~/.bash_profile

echo "✅ Verifying Python version (after restart/source it should be 3.12)..."
$PYTHON312_BIN/python3 --version
echo "System python symlink will now point to:"
#d? ls -la /usr/local/bin/python3

echo "🎉 Python 3.12 is now properly installed and configured as default!"
echo "⚠️ Important: Run the following command to apply changes to your current shell:"
echo "    source ~/.zshrc  # or source ~/.bash_profile for bash"
echo ""
echo "💡 After sourcing, verify with:"
echo "    which python"
echo "    which python3"
echo "    python --version"
echo "    python3 --version"

python3 -m pip install uv