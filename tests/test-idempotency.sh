#!/bin/bash
#
# Idempotency Test Script
# Tests that the playbook can be run multiple times without changes
#
# Usage:
#   ./tests/test-idempotency.sh [target] [tags]
#
# Examples:
#   ./tests/test-idempotency.sh testbuild
#   ./tests/test-idempotency.sh testbuild base
#   ./tests/test-idempotency.sh localhost --skip-tags aur

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
TARGET="${1:-testbuild}"
TAGS="${2:-}"
USER_NAME="${USER_NAME:-vagrant}"
USER_GIT_NAME="${USER_GIT_NAME:-Test User}"
USER_EMAIL="${USER_EMAIL:-test@test.com}"

echo "========================================"
echo "Idempotency Test"
echo "========================================"
echo "Target: $TARGET"
echo "Tags: ${TAGS:-all}"
echo "User: $USER_NAME"
echo ""

# Build ansible-playbook command
PLAYBOOK_CMD="ansible-playbook playbook.yml -l $TARGET"
PLAYBOOK_CMD="$PLAYBOOK_CMD --extra-vars=\"user_name=$USER_NAME user_git_name='$USER_GIT_NAME' user_email=$USER_EMAIL\""

if [ -n "$TAGS" ]; then
  PLAYBOOK_CMD="$PLAYBOOK_CMD --tags $TAGS"
fi

# First run
echo -e "${YELLOW}=== First Run (expect changes) ===${NC}"
echo "Running: $PLAYBOOK_CMD"
echo ""

eval "$PLAYBOOK_CMD --ask-become-pass" > /tmp/ansible-run1.log 2>&1 || {
  echo -e "${RED}❌ First run failed!${NC}"
  cat /tmp/ansible-run1.log
  exit 1
}

echo -e "${GREEN}✓ First run completed${NC}"
echo ""

# Extract stats from first run
CHANGED_1=$(grep -oP 'changed=\K\d+' /tmp/ansible-run1.log | tail -1 || echo "0")
FAILED_1=$(grep -oP 'failed=\K\d+' /tmp/ansible-run1.log | tail -1 || echo "0")

echo "First run stats:"
echo "  Changed: $CHANGED_1"
echo "  Failed: $FAILED_1"
echo ""

if [ "$FAILED_1" != "0" ]; then
  echo -e "${RED}❌ First run had failures${NC}"
  cat /tmp/ansible-run1.log
  exit 1
fi

# Second run
echo -e "${YELLOW}=== Second Run (expect no changes) ===${NC}"
echo "Running: $PLAYBOOK_CMD"
echo ""

eval "$PLAYBOOK_CMD --ask-become-pass" > /tmp/ansible-run2.log 2>&1 || {
  echo -e "${RED}❌ Second run failed!${NC}"
  cat /tmp/ansible-run2.log
  exit 1
}

echo -e "${GREEN}✓ Second run completed${NC}"
echo ""

# Extract stats from second run
CHANGED_2=$(grep -oP 'changed=\K\d+' /tmp/ansible-run2.log | tail -1 || echo "0")
FAILED_2=$(grep -oP 'failed=\K\d+' /tmp/ansible-run2.log | tail -1 || echo "0")

echo "Second run stats:"
echo "  Changed: $CHANGED_2"
echo "  Failed: $FAILED_2"
echo ""

# Check idempotency
if [ "$CHANGED_2" = "0" ] && [ "$FAILED_2" = "0" ]; then
  echo -e "${GREEN}========================================"
  echo "✅ IDEMPOTENCY TEST PASSED"
  echo "========================================${NC}"
  echo ""
  echo "The playbook is idempotent!"
  echo "First run: $CHANGED_1 changes"
  echo "Second run: $CHANGED_2 changes (expected: 0)"
  exit 0
else
  echo -e "${RED}========================================"
  echo "❌ IDEMPOTENCY TEST FAILED"
  echo "========================================${NC}"
  echo ""
  echo "The playbook made changes on the second run!"
  echo "First run: $CHANGED_1 changes"
  echo "Second run: $CHANGED_2 changes (expected: 0)"
  echo ""
  echo "Diff output:"
  diff /tmp/ansible-run1.log /tmp/ansible-run2.log || true
  echo ""
  echo "Full second run log:"
  cat /tmp/ansible-run2.log
  exit 1
fi
