# test_imm_shift.S — Test SLLI, SRLI, SRAI instructions
.include "Tests/asm/test_macros.S"

INIT_TEST

    # Test 1: SLLI by 1
    li x1, 1
    slli x3, x1, 1
    TEST_CASE 1, x3, 2

    # Test 2: SLLI by 4
    li x1, 0x0F
    slli x3, x1, 4
    TEST_CASE 2, x3, 0xF0

    # Test 3: SLLI by 0 (no shift)
    li x1, 0xABCD
    slli x3, x1, 0
    TEST_CASE 3, x3, 0xABCD

    # Test 4: SLLI by 31
    li x1, 1
    slli x3, x1, 31
    TEST_CASE 4, x3, 0x80000000

    # Test 5: SRLI by 1
    li x1, 4
    srli x3, x1, 1
    TEST_CASE 5, x3, 2

    # Test 6: SRLI of negative (logical, zero fills)
    li x1, 0x80000000
    srli x3, x1, 4
    TEST_CASE 6, x3, 0x08000000

    # Test 7: SRAI of negative (arithmetic, sign extends)
    li x1, 0x80000000
    srai x3, x1, 4
    TEST_CASE 7, x3, 0xF8000000

    # Test 8: SRAI of positive
    li x1, 0x40000000
    srai x3, x1, 4
    TEST_CASE 8, x3, 0x04000000

    TEST_PASS
    TEST_FAIL
