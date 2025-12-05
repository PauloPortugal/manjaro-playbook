#!/bin/bash
#
# Setup Development Environment for Manjaro Playbook
# This script installs all necessary dependencies for development and testing
#

set -e  # Exit on error

echo "=========================================="
echo "Manjaro Playbook - Development Setup"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running on Manjaro/Arch
if ! command -v pacman &> /dev/null; then
    echo -e "${RED}Error: This script is designed for Manjaro/Arch Linux${NC}"
    echo "Please install dependencies manually on your system."
    exit 1
fi

echo -e "${YELLOW}Step 1: Installing system packages via pacman${NC}"
echo "This will install: ansible, ansible-lint, git, xclip, python-pip, yamllint, python-pytokens, shellcheck, pre-commit"
echo ""

sudo pacman -S --needed --noconfirm \
    ansible \
    ansible-lint \
    git \
    xclip \
    python-pip \
    python-pytokens \
    yamllint \
    shellcheck \
    pre-commit

echo -e "${GREEN}✓ System packages installed${NC}"
echo ""

echo -e "${YELLOW}Step 2: Verifying Python dependencies${NC}"
echo "All Python dependencies are now installed via pacman (system packages)"
echo "This avoids conflicts with externally-managed Python environments"
echo -e "${GREEN}✓ Python dependencies ready${NC}"
echo ""

echo -e "${YELLOW}Step 3: Installing Ansible Galaxy collections${NC}"
echo "Installing from requirements.yml..."
echo ""

ansible-galaxy collection install -r requirements.yml

echo -e "${GREEN}✓ Ansible collections installed${NC}"
echo ""

echo -e "${YELLOW}Step 4: Installing pre-commit hooks${NC}"
echo "Setting up automated quality checks..."
echo ""

pre-commit install

echo -e "${GREEN}✓ Pre-commit hooks installed${NC}"
echo ""

echo -e "${YELLOW}Step 5: Verifying installation${NC}"
echo ""

# Verify installations
echo "Checking versions..."
echo -n "Ansible: "
ansible --version | head -n1

echo -n "ansible-lint: "
ansible-lint --version | head -n1

echo -n "yamllint: "
yamllint --version

echo -n "pre-commit: "
pre-commit --version

echo -n "Python: "
python --version

echo ""
echo -e "${GREEN}=========================================="
echo "✓ Development environment setup complete!"
echo "==========================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Run: yamllint . && ansible-lint"
echo "  2. Test playbook syntax: ansible-playbook --syntax-check playbook.yml"
echo "  3. Make a commit - pre-commit hooks will run automatically!"
echo "  4. See README.md for usage instructions"
echo ""
