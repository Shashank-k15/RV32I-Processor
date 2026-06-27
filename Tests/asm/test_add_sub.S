# test_add_sub.S — Test ADD and SUB instructions
.include "Tests/asm/test_macros.S"

INIT_TEST

    # Test 1: ADD basic
    li x1, 5
    li x2, 10
    add x3, x1, x2
    TEST_CASE 1, x3, 15

    # Test 2: ADD zero
    li x1, 42
    add x3, x1, x0
    TEST_CASE 2, x3, 42

    # Test 3: ADD negative numbers
    li x1, -10
    li x2, 20
    add x3, x1, x2
    TEST_CASE 3, x3, 10

    # Test 4: ADD overflow (wraps around)
    li x1, 0x7FFFFFFF
    li x2, 1
    add x3, x1, x2
    TEST_CASE 4, x3, 0x80000000

    # Test 5: SUB basic
    li x1, 15
    li x2, 5
    sub x3, x1, x2
    TEST_CASE 5, x3, 10

    # Test 6: SUB resulting in negative
    li x1, 5
    li x2, 15
    sub x3, x1, x2
    TEST_CASE 6, x3, -10

    # Test 7: SUB from zero
    li x1, 0
    li x2, 1
    sub x3, x1, x2
    TEST_CASE 7, x3, -1

    # Test 8: SUB same values
    li x1, 100
    sub x3, x1, x1
    TEST_CASE 8, x3, 0

    TEST_PASS
    TEST_FAIL
