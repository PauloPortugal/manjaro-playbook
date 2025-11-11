#!/bin/bash
#
# Vagrant VM Test Helper
# Automates testing the playbook against a clean Vagrant VM
#
# Usage:
#   ./tests/vagrant-test.sh [command] [tags]
#
# Commands:
#   setup    - Start VM and run full playbook
#   test     - Run idempotency test
#   verify   - Run verification checks
#   clean    - Destroy VM
#   all      - Full test cycle (setup + test + verify + clean)
#
# Examples:
#   ./tests/vagrant-test.sh setup
#   ./tests/vagrant-test.sh test base
#   ./tests/vagrant-test.sh all

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

COMMAND="${1:-all}"
TAGS="${2:-}"

echo -e "${BLUE}========================================"
echo "Vagrant Test Helper"
echo "========================================${NC}"
echo "Command: $COMMAND"
echo "Tags: ${TAGS:-all}"
echo ""

# Check if Vagrantfile exists
if [ ! -f Vagrantfile ]; then
  echo -e "${RED}❌ Vagrantfile not found!${NC}"
  echo "Please run this script from the project root."
  exit 1
fi

# Function: Setup VM
setup_vm() {
  echo -e "${YELLOW}=== Setting up Vagrant VM ===${NC}"

  # Start VM
  echo "Starting Vagrant VM..."
  vagrant up --provision

  echo -e "${GREEN}✓ VM is ready${NC}"
  echo ""
}

# Function: Run playbook
run_playbook() {
  local tags_arg=""
  if [ -n "$TAGS" ]; then
    tags_arg="--tags $TAGS"
  fi

  echo -e "${YELLOW}=== Running playbook ===${NC}"
  ansible-playbook playbook.yml -l testbuild \
    --extra-vars="user_name=vagrant user_git_name='Test User' user_email=test@test.com" \
    $tags_arg \
    --ask-become-pass

  echo -e "${GREEN}✓ Playbook completed${NC}"
  echo ""
}

# Function: Test idempotency
test_idempotency() {
  echo -e "${YELLOW}=== Testing idempotency ===${NC}"
  ./tests/test-idempotency.sh testbuild "$TAGS"
  echo -e "${GREEN}✓ Idempotency test passed${NC}"
  echo ""
}

# Function: Verify installation
verify_installation() {
  echo -e "${YELLOW}=== Verifying installation ===${NC}"

  # Run verification playbook
  ansible-playbook tests/verify.yml -l testbuild

  echo -e "${GREEN}✓ Verification passed${NC}"
  echo ""
}

# Function: Clean up
clean_vm() {
  echo -e "${YELLOW}=== Cleaning up VM ===${NC}"
  vagrant destroy -f
  echo -e "${GREEN}✓ VM destroyed${NC}"
  echo ""
}

# Main logic
case "$COMMAND" in
  setup)
    setup_vm
    ;;

  run)
    run_playbook
    ;;

  test)
    test_idempotency
    ;;

  verify)
    verify_installation
    ;;

  clean)
    clean_vm
    ;;

  all)
    echo -e "${BLUE}=== Full test cycle ===${NC}"
    setup_vm
    run_playbook
    test_idempotency
    verify_installation

    echo -e "${GREEN}========================================"
    echo "✅ ALL TESTS PASSED"
    echo "========================================${NC}"
    echo ""

    read -p "Destroy VM? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      clean_vm
    fi
    ;;

  *)
    echo -e "${RED}❌ Unknown command: $COMMAND${NC}"
    echo ""
    echo "Available commands:"
    echo "  setup    - Start VM and prepare"
    echo "  run      - Run playbook"
    echo "  test     - Test idempotency"
    echo "  verify   - Verify installation"
    echo "  clean    - Destroy VM"
    echo "  all      - Full test cycle"
    exit 1
    ;;
esac

echo -e "${GREEN}Done!${NC}"
