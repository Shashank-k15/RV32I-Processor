# test_factorial.S — Integration test: compute factorial(7) = 5040
.include "Tests/asm/test_macros.S"

INIT_TEST

    # Compute factorial(7)
    # x10 = n (input)
    # x11 = result (accumulator)
    li x10, 7           # n = 7
    li x11, 1           # result = 1

factorial_loop:
    beq x10, x0, factorial_done   # if n == 0, done
    mul_start:
        # Multiply x11 = x11 * x10 using repeated addition cuz in mul instruction. 
        li x12, 0       # x12 = product accumulator
        mv x13, x10     # x13 = multiplier counter
    mul_loop:
        beq x13, x0, mul_done
        add x12, x12, x11
        addi x13, x13, -1
        j mul_loop
    mul_done:
        mv x11, x12     # result = product
        addi x10, x10, -1   # n--
        j factorial_loop

factorial_done:
    # x11 should now be 7!
    TEST_CASE 1, x11, 5040

    TEST_PASS
    TEST_FAIL
