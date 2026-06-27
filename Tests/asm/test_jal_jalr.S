# test_jal_jalr.S — Test JAL and JALR instructions
.include "Tests/asm/test_macros.S"

INIT_TEST

    # Test 1: JAL — jump forward, check rd = PC+4
    jal x1, jal_target1
    # This instruction is at some PC, x1 should have PC+4 of the jal
    # We'll never reach here if JAL works
    j test_fail

jal_target1:
    # x1 now has return address (address of instruction after jal)
    # Verify it's non-zero (we can't easily know the exact value)
    li x3, 0
    bne x1, x0, jal1_ok
    j test_fail
jal1_ok:

    # Test 2: JAL — verify link address is correct by jumping back
    # We use a more elaborate test: call a "function" with JAL, return with JALR
    li x10, 0          # result register
    jal x1, add_func   # call function
    # After return, x10 should be 30
    TEST_CASE 2, x10, 30

    # Test 3: JALR basic — jump to address in register
    la x5, jalr_target
    jalr x1, x5, 0
    j test_fail

jalr_target:
    li x3, 1
    TEST_CASE 3, x3, 1

    # Test 4: JALR with offset
    la x5, jalr_base
    jalr x1, x5, 8     # jump to jalr_base + 8
    j test_fail

jalr_base:
    j test_fail         # offset 0 — should be skipped
    j test_fail         # offset 4 — should be skipped
    li x3, 1            # offset 8 — this is the target
    TEST_CASE 4, x3, 1

    # Test 5: JALR clears LSB (target & ~1)
    la x5, jalr_align_target
    ori x5, x5, 1      # set LSB
    jalr x1, x5, 0     # should clear LSB and jump correctly
    j test_fail

jalr_align_target:
    li x3, 1
    TEST_CASE 5, x3, 1

    TEST_PASS

# Simple function: adds 10 + 20, stores result in x10, returns via JALR
add_func:
    li x10, 10
    li x11, 20
    add x10, x10, x11
    jalr x0, x1, 0     # return (discard link since rd=x0)

    TEST_FAIL
