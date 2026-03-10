#!/bin/bash
set -euo pipefail

# Only run in remote Claude Code on the web environment
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

echo "=== Hummingbot Session Start Hook ==="
cd "${CLAUDE_PROJECT_DIR:-/home/user/hummingbot}"

# Install build dependencies (Cython, numpy, setuptools, wheel)
echo "Installing build dependencies..."
pip install --quiet "numpy>=2.2.6" "cython>=3.0.12" "setuptools>=80.8.0" wheel

# Install Python dependencies from setup.py
echo "Installing Python dependencies..."
pip install --quiet \
  "aiohttp>=3.8.5" \
  "asyncssh>=2.13.2" \
  "aioprocessing>=2.0.1" \
  "aioresponses>=0.7.4" \
  "aiounittest>=1.4.2" \
  "async-timeout>=4.0.2,<5" \
  "bidict>=0.22.1" \
  "bip-utils" \
  "cachetools>=5.3.1" \
  "commlib-py>=0.11" \
  "cryptography>=41.0.2" \
  "eth-account>=0.13.0" \
  "msgpack-python" \
  "numba>=0.61.2" \
  "objgraph" \
  "pandas>=2.3.2" \
  "prompt_toolkit>=3.0.39" \
  "protobuf>=4.23.3" \
  "psutil>=5.9.5" \
  "pydantic>=2" \
  "pyjwt>=2.3.0" \
  "pyperclip>=1.8.2" \
  "requests>=2.31.0" \
  "ruamel.yaml>=0.2.5" \
  "scalecodec" \
  "scipy>=1.11.1" \
  "six>=1.16.0" \
  "sqlalchemy>=1.4.49" \
  "tabulate>=0.9.0" \
  "TA-Lib>=0.6.4" \
  "tqdm>=4.67.1" \
  "ujson>=5.7.0" \
  "urllib3>=1.26.15,<2.0" \
  "web3" \
  "xrpl-py>=4.1.0" \
  "PyYAML>=0.2.5"

# Install safe-pysha3 using prebuilt wheel (replaces pysha3 which requires old Python headers)
# eip712-structs depends on pysha3 but safe-pysha3 is a compatible drop-in replacement
echo "Installing sha3 packages..."
pip install --quiet --no-build-isolation "safe-pysha3"
pip install --quiet --no-deps "eip712-structs"

# Install testing and linting tools
echo "Installing testing and linting tools..."
pip install --quiet \
  "pytest>=7.4.0" \
  "pytest-asyncio>=0.16.0" \
  "coverage>=7.2.7" \
  "flake8>=6.0.0" \
  "black" \
  "isort" \
  "autopep8"

# Compile Cython extensions in-place
echo "Compiling Cython extensions..."
WITHOUT_CYTHON_OPTIMIZATIONS=1 python setup.py build_ext --inplace --quiet 2>/dev/null || \
  python setup.py build_ext --inplace --quiet

# Add project to Python path
echo "export PYTHONPATH=\"${CLAUDE_PROJECT_DIR:-/home/user/hummingbot}:\${PYTHONPATH:-}\"" >> "${CLAUDE_ENV_FILE:-/dev/null}"

echo "=== Session start hook complete ==="
