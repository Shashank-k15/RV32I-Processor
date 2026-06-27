# test_shift.S — Test SLL, SRL, SRA instructions
.include "Tests/asm/test_macros.S"

INIT_TEST

    # Test 1: SLL by 1
    li x1, 1
    li x2, 1
    sll x3, x1, x2
    TEST_CASE 1, x3, 2

    # Test 2: SLL by 4
    li x1, 0x0F
    li x2, 4
    sll x3, x1, x2
    TEST_CASE 2, x3, 0xF0

    # Test 3: SLL by 0
    li x1, 0xABCD
    li x2, 0
    sll x3, x1, x2
    TEST_CASE 3, x3, 0xABCD

    # Test 4: SRL by 1
    li x1, 4
    li x2, 1
    srl x3, x1, x2
    TEST_CASE 4, x3, 2

    # Test 5: SRL of negative number (logical, zero-fills)
    li x1, 0x80000000
    li x2, 4
    srl x3, x1, x2
    TEST_CASE 5, x3, 0x08000000

    # Test 6: SRA of negative number (arithmetic, sign-extends)
    li x1, 0x80000000
    li x2, 4
    sra x3, x1, x2
    TEST_CASE 6, x3, 0xF8000000

    # Test 7: SRA of positive number
    li x1, 0x7FFFFFFF
    li x2, 4
    sra x3, x1, x2
    TEST_CASE 7, x3, 0x07FFFFFF

    # Test 8: SLL only uses lower 5 bits of shift amount
    li x1, 1
    li x2, 33       # should shift by 1 (33 & 0x1F = 1)
    sll x3, x1, x2
    TEST_CASE 8, x3, 2

    TEST_PASS
    TEST_FAIL
