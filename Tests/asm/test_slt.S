# test_slt.S — Test SLT and SLTU instructions
.include "Tests/asm/test_macros.S"

INIT_TEST

    # Test 1: SLT positive < positive (true)
    li x1, 5
    li x2, 10
    slt x3, x1, x2
    TEST_CASE 1, x3, 1

    # Test 2: SLT positive < positive (false)
    li x1, 10
    li x2, 5
    slt x3, x1, x2
    TEST_CASE 2, x3, 0

    # Test 3: SLT equal
    li x1, 42
    li x2, 42
    slt x3, x1, x2
    TEST_CASE 3, x3, 0

    # Test 4: SLT negative < positive
    li x1, -1
    li x2, 1
    slt x3, x1, x2
    TEST_CASE 4, x3, 1

    # Test 5: SLT positive < negative (false)
    li x1, 1
    li x2, -1
    slt x3, x1, x2
    TEST_CASE 5, x3, 0

    # Test 6: SLTU basic
    li x1, 5
    li x2, 10
    sltu x3, x1, x2
    TEST_CASE 6, x3, 1

    # Test 7: SLTU — -1 is large unsigned, so NOT < 5
    li x1, -1          # 0xFFFFFFFF
    li x2, 5
    sltu x3, x1, x2
    TEST_CASE 7, x3, 0

    # Test 8: SLTU — 5 < 0xFFFFFFFF
    li x1, 5
    li x2, -1          # 0xFFFFFFFF
    sltu x3, x1, x2
    TEST_CASE 8, x3, 1

    TEST_PASS
    TEST_FAIL
