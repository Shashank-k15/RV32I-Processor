# ============================================================================
# test_macros.S — Shared macros for RV32I test programs
# ============================================================================
# Convention:
#   - TOHOST is at address 0x2000 in data memory
#   - Writing 1 to TOHOST = PASS
#   - Writing (test_num << 1 | 1) to TOHOST = FAIL
#   - After writing, enter infinite loop
# ============================================================================

.macro INIT_TEST
    .section .text.init
    .globl _start
_start:
    # x0 is always zero (hardwired)
    # Clear some working registers
    li x1, 0
    li x2, 0
    li x3, 0
    li x4, 0
    li x5, 0
    li x6, 0
    li x7, 0
    li x10, 0
    li x11, 0
    li x12, 0
.endm

# TEST_CASE: Run a test, check result against expected
# testnum: test case number (for debugging)
# reg: register containing the result
# expected: expected value
.macro TEST_CASE testnum, reg, expected
    li x30, \expected
    li x31, \testnum
    bne \reg, x30, test_fail
.endm

# PASS: Signal test success
.macro TEST_PASS
    li x1, 1
    li x2, 0x2000
    sw x1, 0(x2)
pass_loop:
    j pass_loop
.endm

# FAIL: Signal test failure (x31 has the test number)
.macro TEST_FAIL
test_fail:
    slli x31, x31, 1
    ori x31, x31, 1
    li x2, 0x2000
    sw x31, 0(x2)
fail_loop:
    j fail_loop
.endm
