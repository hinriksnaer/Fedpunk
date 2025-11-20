#!/usr/bin/env fish
# Test script for Phase 2 modules (gh and claude)
# Verifies that gh and claude modules are properly installed and configured

set -l SCRIPT_DIR (dirname (status -f))
source "$SCRIPT_DIR/lib/fish/ui.fish"

echo ""
ui-style --foreground 39 --bold "=== Phase 2 Module Test ==="
echo ""
ui-info "Testing gh and claude module installation"
echo ""

# Test counters
set -l tests_passed 0
set -l tests_failed 0

# Test gh module
echo ""
ui-style --foreground 39 --bold "Testing gh module..."
echo ""

# Test 1: gh command exists
if command -v gh >/dev/null 2>&1
    ui-success "gh command is available"
    set tests_passed (math $tests_passed + 1)

    # Show version
    set -l gh_version (gh --version | head -n1)
    ui-info "Version: $gh_version"
else
    ui-error "gh command not found"
    set tests_failed (math $tests_failed + 1)
end

# Test 2: gh module.yaml exists
if test -f "$SCRIPT_DIR/modules/gh/module.yaml"
    ui-success "gh module.yaml exists"
    set tests_passed (math $tests_passed + 1)
else
    ui-error "gh module.yaml not found"
    set tests_failed (math $tests_failed + 1)
end

# Test claude module
echo ""
ui-style --foreground 39 --bold "Testing claude module..."
echo ""

# Test 3: claude command exists or npm package is installed
if command -v claude >/dev/null 2>&1
    ui-success "claude command is available"
    set tests_passed (math $tests_passed + 1)

    # Show version if available
    if claude --version >/dev/null 2>&1
        set -l claude_version (claude --version 2>&1)
        ui-info "Version: $claude_version"
    end
else if npm list -g @anthropic-ai/claude-code >/dev/null 2>&1
    ui-success "claude npm package is installed (command may not be in PATH yet)"
    set tests_passed (math $tests_passed + 1)
else
    ui-error "claude command not found and npm package not installed"
    set tests_failed (math $tests_failed + 1)
end

# Test 4: claude module.yaml exists
if test -f "$SCRIPT_DIR/modules/claude/module.yaml"
    ui-success "claude module.yaml exists"
    set tests_passed (math $tests_passed + 1)
else
    ui-error "claude module.yaml not found"
    set tests_failed (math $tests_failed + 1)
end

# Test 5: claude config exists in module
if test -f "$SCRIPT_DIR/modules/claude/config/.config/claude/config.json"
    ui-success "claude config.json exists in module"
    set tests_passed (math $tests_passed + 1)
else
    ui-error "claude config.json not found in module"
    set tests_failed (math $tests_failed + 1)
end

# Test 6: walkthrough command exists in module
if test -f "$SCRIPT_DIR/modules/claude/config/.claude/commands/walkthrough.md"
    ui-success "walkthrough slash command exists in module"
    set tests_passed (math $tests_passed + 1)
else
    ui-error "walkthrough slash command not found in module"
    set tests_failed (math $tests_failed + 1)
end

# Test profile updates
echo ""
ui-style --foreground 39 --bold "Testing profile configuration..."
echo ""

# Test 7: container profile includes gh and claude
if grep -q "gh" "$SCRIPT_DIR/profiles/dev/modes/container.yaml" && grep -q "claude" "$SCRIPT_DIR/profiles/dev/modes/container.yaml"
    ui-success "container.yaml includes gh and claude modules"
    set tests_passed (math $tests_passed + 1)
else
    ui-error "container.yaml missing gh or claude modules"
    set tests_failed (math $tests_failed + 1)
end

# Test 8: desktop profile includes gh and claude
if grep -q "gh" "$SCRIPT_DIR/profiles/dev/modes/desktop.yaml" && grep -q "claude" "$SCRIPT_DIR/profiles/dev/modes/desktop.yaml"
    ui-success "desktop.yaml includes gh and claude modules"
    set tests_passed (math $tests_passed + 1)
else
    ui-error "desktop.yaml missing gh or claude modules"
    set tests_failed (math $tests_failed + 1)
end

# Summary
echo ""
ui-style --foreground 39 --bold "=== Test Summary ==="
echo ""

set -l total_tests (math $tests_passed + $tests_failed)
echo "Total tests: $total_tests"
echo "Passed: $tests_passed"
echo "Failed: $tests_failed"
echo ""

if test $tests_failed -eq 0
    ui-success "All tests passed!"
    echo ""
    ui-info "Phase 2 modules (gh and claude) are properly configured"
    echo ""
    exit 0
else
    ui-error "Some tests failed!"
    echo ""
    ui-warning "Please review the failures above"
    echo ""
    exit 1
end
