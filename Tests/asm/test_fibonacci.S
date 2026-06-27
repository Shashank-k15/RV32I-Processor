# test_fibonacci.S — Integration test: compute fib(10) = 55
.include "Tests/asm/test_macros.S"

INIT_TEST

    # Compute fibonacci(10)
    li x10, 10          # n = 10
    li x11, 0           # fib(0) = a
    li x12, 1           # fib(1) = b
    li x13, 0           # counter i = 0

fib_loop:
    beq x13, x10, fib_done   # if i == n, done
    add x14, x11, x12        # temp = a + b
    mv x11, x12              # a = b
    mv x12, x14              # b = temp
    addi x13, x13, 1         # i++
    j fib_loop

fib_done:
    # x11 should be fib(10) = 55
    TEST_CASE 1, x11, 55

    TEST_PASS
    TEST_FAIL
