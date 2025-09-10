#!/usr/bin/env bash

# test_sync.sh - Basic tests for the sync.sh script
# Run with: bash tests/test_sync.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Get the directory where this script is located
TEST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$( cd "$TEST_DIR/.." && pwd )"
SYNC_SCRIPT="$DOTFILES_DIR/scripts/sync.sh"

# Test helper functions
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "${BLUE}Running test:${NC} $test_name"
    
    if eval "$test_command"; then
        echo -e "${GREEN}  ✓ PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}  ✗ FAILED${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    echo
}

assert_equal() {
    local actual="$1"
    local expected="$2"
    local message="${3:-Values should be equal}"
    
    if [[ "$actual" == "$expected" ]]; then
        return 0
    else
        echo "    Assertion failed: $message"
        echo "    Expected: '$expected'"
        echo "    Actual:   '$actual'"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String should contain substring}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        return 0
    else
        echo "    Assertion failed: $message"
        echo "    String: '$haystack'"
        echo "    Should contain: '$needle'"
        return 1
    fi
}

assert_exit_code() {
    local command="$1"
    local expected_code="$2"
    local message="${3:-Command should exit with expected code}"
    
    set +e
    eval "$command" > /dev/null 2>&1
    local actual_code=$?
    set -e
    
    if [[ $actual_code -eq $expected_code ]]; then
        return 0
    else
        echo "    Assertion failed: $message"
        echo "    Expected exit code: $expected_code"
        echo "    Actual exit code:   $actual_code"
        return 1
    fi
}

# ============================================================================
# TESTS
# ============================================================================

echo -e "${YELLOW}Starting sync.sh tests...${NC}\n"

# Test 1: Script exists and is executable
run_test "Script exists and is executable" '
    [[ -f "$SYNC_SCRIPT" ]] && [[ -x "$SYNC_SCRIPT" ]]
'

# Test 2: Help flag works
run_test "Help flag (--help) works" '
    output=$("$SYNC_SCRIPT" --help 2>&1)
    assert_contains "$output" "sync.sh - Dotfiles synchronization script" "Help should show title" &&
    assert_contains "$output" "OPTIONS:" "Help should show options section" &&
    assert_contains "$output" "EXAMPLES:" "Help should show examples section"
'

# Test 3: Short help flag works
run_test "Short help flag (-h) works" '
    output=$("$SYNC_SCRIPT" -h 2>&1)
    assert_contains "$output" "sync.sh - Dotfiles synchronization script" "Help should show title"
'

# Test 4: Dry run flag works
run_test "Dry run flag (--dry-run) works" '
    output=$("$SYNC_SCRIPT" --dry-run 2>&1)
    assert_contains "$output" "DRY RUN MODE" "Should indicate dry run mode"
'

# Test 5: Short dry run flag works
run_test "Short dry run flag (-n) works" '
    output=$("$SYNC_SCRIPT" -n 2>&1)
    assert_contains "$output" "DRY RUN MODE" "Should indicate dry run mode"
'

# Test 6: Verbose flag works
run_test "Verbose flag (--verbose) can be combined with dry run" '
    output=$("$SYNC_SCRIPT" -v -n 2>&1)
    assert_contains "$output" "DRY RUN MODE" "Should indicate dry run mode"
'

# Test 7: Force flag works
run_test "Force flag (--force) works" '
    output=$("$SYNC_SCRIPT" --force -n 2>&1)
    assert_contains "$output" "FORCE MODE" "Should indicate force mode" &&
    assert_contains "$output" "DRY RUN MODE" "Should also show dry run mode"
'

# Test 8: Invalid flag handling
run_test "Invalid flag shows error" '
    assert_exit_code "\"$SYNC_SCRIPT\" --invalid-flag" 1 "Should exit with error code 1" &&
    output=$("$SYNC_SCRIPT" --invalid-flag 2>&1 || true) &&
    assert_contains "$output" "Unknown option" "Should show unknown option error"
'

# Test 9: Multiple flags can be combined
run_test "Multiple flags can be combined" '
    output=$("$SYNC_SCRIPT" -v -n -f 2>&1)
    assert_contains "$output" "DRY RUN MODE" "Should show dry run" &&
    assert_contains "$output" "FORCE MODE" "Should show force mode"
'

# Test 10: Script checks for stow installation
run_test "Script checks for stow installation" '
    # This test verifies the script has stow detection logic
    grep -q "command -v stow" "$SYNC_SCRIPT"
'

# Test 11: Script has proper error handling
run_test "Script has proper error handling" '
    grep -q "set -e" "$SYNC_SCRIPT" &&
    grep -q "if \[ \$? -eq 0 \]" "$SYNC_SCRIPT"
'

# Test 12: Script resolves paths correctly
run_test "Script resolves paths correctly" '
    grep -q "SCRIPT_DIR=" "$SYNC_SCRIPT" &&
    grep -q "DOTFILES_DIR=" "$SYNC_SCRIPT"
'

# ============================================================================
# TEST SUMMARY
# ============================================================================

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Test Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Tests run:    ${TESTS_RUN}"
echo -e "Tests passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests failed: ${RED}${TESTS_FAILED}${NC}"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}✗ Some tests failed${NC}"
    exit 1
fi