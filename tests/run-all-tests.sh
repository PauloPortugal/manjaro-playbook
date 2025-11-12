#!/bin/bash
#
# Comprehensive Test Runner
# Runs all test suites for the Manjaro playbook
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

echo "========================================"
echo "Manjaro Playbook - Test Suite"
echo "========================================"
echo ""

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"

    echo -n "Running $test_name... "

    if eval "$test_command" > /tmp/test_output_$$.log 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "Error output:"
        cat /tmp/test_output_$$.log | tail -20
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# 1. Syntax and Linting Tests
echo "=== Phase 1: Code Quality Tests ==="
echo ""

run_test "YAML Lint" "yamllint ."
run_test "Ansible Lint" "ansible-lint"
run_test "Syntax Check" "ansible-playbook --syntax-check playbook.yml"
run_test "ShellCheck" "shellcheck tests/*.sh aur/*.sh setup-dev-environment.sh"

echo ""

# 2. Unit Tests (if on a test system)
if [ -f "/etc/hostname" ] && [ "$(hostname)" = "testbuild" ]; then
    echo "=== Phase 2: Unit Tests ==="
    echo ""

    run_test "Verification Tests" \
        "ansible-playbook tests/verify.yml -l localhost --extra-vars='user_name=vagrant'"

    echo ""
fi

# 3. Integration Tests (if Vagrant available)
if command -v vagrant &> /dev/null; then
    echo "=== Phase 3: Integration Tests ==="
    echo ""

    # Check if VM is running
    if vagrant status | grep -q "running"; then
        run_test "Vagrant Verification" \
            "ansible-playbook tests/verify.yml -l testbuild"

        # Optional: Run idempotency test
        if [ "${RUN_IDEMPOTENCY:-false}" = "true" ]; then
            run_test "Idempotency Test" \
                "./tests/test-idempotency.sh testbuild"
        fi
    else
        echo -e "${YELLOW}⊘ Skipped (Vagrant VM not running)${NC}"
    fi

    echo ""
fi

# Summary
echo "========================================"
echo "Test Summary"
echo "========================================"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
echo "========================================"

# Cleanup
rm -f /tmp/test_output_$$.log

# Exit with appropriate code
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}✗ TESTS FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
    exit 0
fi
