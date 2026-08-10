#!/bin/bash
# Xiaohongshu Hop — Smoke Tests
# Usage: bash test.sh
# Verifies the script handles all input types without runtime errors.
# Note: tests open real browser tabs (search page / note pages).

PASS=0
FAIL=0

# Switch to script directory so tests work from any working directory
cd "$(dirname "$0")"

SCRIPT="xiaohongshu-hop.popclipext/Source/xiaohongshu-hop.sh"
# Verify the target exists before running tests
if [ ! -f "$SCRIPT" ]; then
  echo "❌ $SCRIPT not found — run tests from the project root"
  exit 1
fi

pass() { PASS=$((PASS+1)); echo "  ✅ $1"; }
fail() { FAIL=$((FAIL+1)); echo "  ❌ $1 (expected: $2, got: $3)"; }

# Test 1: plain text → search page
output=$(POPCLIP_TEXT="AI 效率工具" bash "$SCRIPT" 2>&1; echo "EXIT:$?")
code=$(echo "$output" | grep "^EXIT:[0-9]*$" | cut -d: -f2)
[ "$code" = "0" ] && pass "plain text → exit 0" || fail "plain text → exit 0" "0" "$code"

# Test 2: full link → direct jump
output=$(POPCLIP_TEXT="https://www.xiaohongshu.com/explore/66a1b2c3" bash "$SCRIPT" 2>&1; echo "EXIT:$?")
code=$(echo "$output" | grep "^EXIT:[0-9]*$" | cut -d: -f2)
[ "$code" = "0" ] && pass "full link → exit 0" || fail "full link → exit 0" "0" "$code"

# Test 3: short link → direct jump
output=$(POPCLIP_TEXT="xhslink.com/AbC123" bash "$SCRIPT" 2>&1; echo "EXIT:$?")
code=$(echo "$output" | grep "^EXIT:[0-9]*$" | cut -d: -f2)
[ "$code" = "0" ] && pass "short link → exit 0" || fail "short link → exit 0" "0" "$code"

# Test 4: quoted empty text (trimmed to empty → exit 1)
output=$(POPCLIP_TEXT='""' bash "$SCRIPT" 2>&1; echo "EXIT:$?")
code=$(echo "$output" | grep "^EXIT:[0-9]*$" | cut -d: -f2)
[ "$code" = "1" ] && pass "empty quotes → exit 1" || fail "empty quotes → exit 1" "1" "$code"

# Test 5: pure whitespace
output=$(POPCLIP_TEXT="   " bash "$SCRIPT" 2>&1; echo "EXIT:$?")
code=$(echo "$output" | grep "^EXIT:[0-9]*$" | cut -d: -f2)
[ "$code" = "1" ] && pass "whitespace only → exit 1" || fail "whitespace only → exit 1" "1" "$code"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
