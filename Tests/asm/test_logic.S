# test_logic.S — Test AND, OR, XOR instructions
.include "Tests/asm/test_macros.S"

INIT_TEST

    # Test 1: AND
    li x1, 0xFF00FF00
    li x2, 0x0F0F0F0F
    and x3, x1, x2
    TEST_CASE 1, x3, 0x0F000F00

    # Test 2: AND with zero
    li x1, 0xDEADBEEF
    and x3, x1, x0
    TEST_CASE 2, x3, 0

    # Test 3: OR
    li x1, 0xFF00FF00
    li x2, 0x00FF00FF
    or x3, x1, x2
    TEST_CASE 3, x3, 0xFFFFFFFF

    # Test 4: OR with zero
    li x1, 0x12345678
    or x3, x1, x0
    TEST_CASE 4, x3, 0x12345678

    # Test 5: XOR
    li x1, 0xFF00FF00
    li x2, 0x0F0F0F0F
    xor x3, x1, x2
    TEST_CASE 5, x3, 0xF00FF00F

    # Test 6: XOR with self = 0
    li x1, 0xABCD1234
    xor x3, x1, x1
    TEST_CASE 6, x3, 0

    TEST_PASS
    TEST_FAIL
