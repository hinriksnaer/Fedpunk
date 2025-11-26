#!/usr/bin/env fish
# CLI Dispatcher Tests
#
# Run: fish tests/cli-dispatcher.fish
# Or:  cd $FEDPUNK_ROOT && fish tests/cli-dispatcher.fish

set -g FEDPUNK_ROOT (dirname (dirname (status -f)))
set -g FEDPUNK_BIN "$FEDPUNK_ROOT/bin/fedpunk"
set -g TEST_PASSED 0
set -g TEST_FAILED 0

function test_pass
    set -g TEST_PASSED (math $TEST_PASSED + 1)
    echo "  ✓ $argv"
end

function test_fail
    set -g TEST_FAILED (math $TEST_FAILED + 1)
    echo "  ✗ $argv"
end

function assert_contains
    set -l output $argv[1]
    set -l expected $argv[2]
    set -l msg $argv[3]

    if string match -q "*$expected*" "$output"
        test_pass "$msg"
    else
        test_fail "$msg (expected '$expected')"
    end
end

function assert_not_contains
    set -l output $argv[1]
    set -l unexpected $argv[2]
    set -l msg $argv[3]

    if not string match -q "*$unexpected*" "$output"
        test_pass "$msg"
    else
        test_fail "$msg (should not contain '$unexpected')"
    end
end

function assert_exit_code
    set -l actual $argv[1]
    set -l expected $argv[2]
    set -l msg $argv[3]

    if test "$actual" -eq "$expected"
        test_pass "$msg"
    else
        test_fail "$msg (expected exit $expected, got $actual)"
    end
end

# ============================================
# Test: Main Help
# ============================================
echo "Testing: Main Help"

set output (fish $FEDPUNK_BIN 2>&1)
assert_contains "$output" "fedpunk" "Shows fedpunk in help"
assert_contains "$output" "Usage:" "Shows usage"
assert_contains "$output" "Commands:" "Shows commands section"
assert_contains "$output" "doctor" "Lists doctor command"

set output (fish $FEDPUNK_BIN help 2>&1)
assert_contains "$output" "Commands:" "help shows commands"

set output (fish $FEDPUNK_BIN --help 2>&1)
assert_contains "$output" "Commands:" "--help shows commands"

# ============================================
# Test: Version
# ============================================
echo ""
echo "Testing: Version"

set output (fish $FEDPUNK_BIN version 2>&1)
assert_contains "$output" "fedpunk" "version shows fedpunk"

set output (fish $FEDPUNK_BIN --version 2>&1)
assert_contains "$output" "fedpunk" "--version shows fedpunk"

# ============================================
# Test: Command Discovery
# ============================================
echo ""
echo "Testing: Command Discovery"

set output (fish $FEDPUNK_BIN 2>&1)
assert_contains "$output" "doctor" "Discovers doctor command"
assert_contains "$output" "System diagnostics" "Shows doctor description"

# ============================================
# Test: Command Help
# ============================================
echo ""
echo "Testing: Command Help"

set output (fish $FEDPUNK_BIN doctor 2>&1)
assert_contains "$output" "Subcommands:" "doctor shows subcommands"
assert_contains "$output" "ping" "Lists ping subcommand"
assert_contains "$output" "greet" "Lists greet subcommand"
assert_contains "$output" "fail" "Lists fail subcommand"
assert_contains "$output" "args" "Lists args subcommand"
assert_not_contains "$output" "_secret" "Does not list private _secret"

set output (fish $FEDPUNK_BIN doctor --help 2>&1)
assert_contains "$output" "Subcommands:" "doctor --help shows subcommands"

# ============================================
# Test: Subcommand Execution
# ============================================
echo ""
echo "Testing: Subcommand Execution"

set output (fish $FEDPUNK_BIN doctor ping hello world 2>&1)
assert_contains "$output" "Ping:" "ping executes"
assert_contains "$output" "hello" "ping receives args"
assert_contains "$output" "world" "ping receives all args"

set output (fish $FEDPUNK_BIN doctor greet punk 2>&1)
assert_contains "$output" "Hey punk" "greet uses argument"

set output (fish $FEDPUNK_BIN doctor greet 2>&1)
assert_contains "$output" "Hey punk" "greet uses default"

set output (fish $FEDPUNK_BIN doctor args one two three 2>&1)
assert_contains "$output" "Argument count: 3" "args counts correctly"
assert_contains "$output" "[1]: one" "args shows first"
assert_contains "$output" "[3]: three" "args shows third"

# ============================================
# Test: Subcommand Help
# ============================================
echo ""
echo "Testing: Subcommand Help"

set output (fish $FEDPUNK_BIN doctor ping --help 2>&1)
assert_contains "$output" "Echo back" "ping --help shows description"
assert_contains "$output" "Usage:" "ping --help shows usage"

set output (fish $FEDPUNK_BIN doctor greet --help 2>&1)
assert_contains "$output" "Greet a user" "greet --help shows description"

# ============================================
# Test: Error Handling
# ============================================
echo ""
echo "Testing: Error Handling"

set output (fish $FEDPUNK_BIN nonexistent 2>&1)
set code $status
assert_contains "$output" "Unknown command" "Unknown command error message"
assert_exit_code $code 1 "Unknown command exits 1"

set output (fish $FEDPUNK_BIN doctor nonexistent 2>&1)
set code $status
assert_contains "$output" "Unknown subcommand" "Unknown subcommand error message"
assert_exit_code $code 1 "Unknown subcommand exits 1"

# ============================================
# Test: Private Function Protection
# ============================================
echo ""
echo "Testing: Private Function Protection"

set output (fish $FEDPUNK_BIN doctor _secret 2>&1)
set code $status
assert_contains "$output" "Unknown subcommand" "Private function rejected"
assert_exit_code $code 1 "Private function call exits 1"

# ============================================
# Test: Exit Codes
# ============================================
echo ""
echo "Testing: Exit Codes"

fish $FEDPUNK_BIN doctor fail 42 >/dev/null 2>&1
assert_exit_code $status 42 "fail returns specified code"

fish $FEDPUNK_BIN doctor fail >/dev/null 2>&1
assert_exit_code $status 1 "fail defaults to 1"

fish $FEDPUNK_BIN doctor ping >/dev/null 2>&1
assert_exit_code $status 0 "Successful command exits 0"

# ============================================
# Summary
# ============================================
echo ""
echo "========================================"
echo "Results: $TEST_PASSED passed, $TEST_FAILED failed"
echo "========================================"

if test $TEST_FAILED -gt 0
    exit 1
else
    exit 0
end
