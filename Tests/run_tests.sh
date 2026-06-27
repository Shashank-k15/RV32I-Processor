#!/usr/bin/env bash
# run_tests.sh — Assemble, compile, and run all RV32I test programs
#
# Usage:
#   ./Tests/run_tests.sh           # run all tests
#   ./Tests/run_tests.sh --trace   # run all tests with VCD waveform output

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ASM_DIR="$SCRIPT_DIR/asm"
COMPILE_SCRIPT="$PROJECT_DIR/toolchain/compile.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

TRACE_FLAG=""
if [[ "${1:-}" == "--trace" ]]; then
    TRACE_FLAG="--trace"
fi

# Build the test executable first
echo -e "${BOLD}${CYAN}══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}  RV32I Processor — Test Suite${NC}"
echo -e "${BOLD}${CYAN}══════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}Building test harness...${NC}"
cd "$PROJECT_DIR"

# Build the rv32i_test executable using verilator
verilator -j 0 -Wall --cc --trace \
    -Wno-UNUSEDSIGNAL -Wno-PINCONNECTEMPTY \
    dataPath.sv --exe Tests/rv32i_test.cpp \
    2>&1 | grep -v "^$" || true
make -C obj_dir -f VdataPath.mk VdataPath 2>&1 | tail -1

echo -e "${GREEN}Build successful.${NC}"
echo ""

# Counters
PASS=0
FAIL=0
SKIP=0
TOTAL=0

# Find all test files
TEST_FILES=($(ls "$ASM_DIR"/test_*.S 2>/dev/null | grep -v test_macros.S | sort))

if [ ${#TEST_FILES[@]} -eq 0 ]; then
    echo -e "${RED}No test files found in $ASM_DIR${NC}"
    exit 1
fi

echo -e "${BOLD}Running ${#TEST_FILES[@]} tests...${NC}"
echo -e "${CYAN}──────────────────────────────────────────────────────────${NC}"

for test_file in "${TEST_FILES[@]}"; do
    test_name=$(basename "$test_file" .S)
    TOTAL=$((TOTAL + 1))

    # Compile assembly to hex
    if ! bash "$COMPILE_SCRIPT" "$test_file" "$PROJECT_DIR/program.hex" > /dev/null 2>&1; then
        echo -e "  ${RED}[SKIP]${NC} ${test_name} — assembly failed"
        SKIP=$((SKIP + 1))
        continue
    fi

    # Run the simulation
    result=$(./obj_dir/VdataPath $TRACE_FLAG 2>&1) || true
    exit_code=${PIPESTATUS[0]:-0}

    if echo "$result" | grep -q "\[PASS\]"; then
        cycles=$(echo "$result" | grep -oE '[0-9]+ cycles' | head -1)
        echo -e "  ${GREEN}[PASS]${NC} ${test_name} (${cycles})"
        PASS=$((PASS + 1))
    elif echo "$result" | grep -q "\[TIMEOUT\]"; then
        echo -e "  ${RED}[TIMEOUT]${NC} ${test_name}"
        FAIL=$((FAIL + 1))
    else
        fail_info=$(echo "$result" | grep "\[FAIL\]" | head -1)
        echo -e "  ${RED}[FAIL]${NC} ${test_name} — ${fail_info}"
        FAIL=$((FAIL + 1))
        # Show register dump if available
        if echo "$result" | grep -q "Register dump"; then
            echo "$result" | grep -A 40 "Register dump" | head -20 | sed 's/^/    /'
        fi
    fi

    # Move waveform if tracing
    if [[ -n "$TRACE_FLAG" && -f "waveform.vcd" ]]; then
        mv waveform.vcd "waveform_${test_name}.vcd" 2>/dev/null || true
    fi
done

echo -e "${CYAN}──────────────────────────────────────────────────────────${NC}"
echo ""
echo -e "${BOLD}Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}, ${YELLOW}${SKIP} skipped${NC} / ${TOTAL} total"

if [ $FAIL -eq 0 ] && [ $SKIP -eq 0 ]; then
    echo -e "${GREEN}${BOLD}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "${RED}${BOLD}Some tests failed.${NC}"
    exit 1
fi
