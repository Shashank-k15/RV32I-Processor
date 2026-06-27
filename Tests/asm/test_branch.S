# test_branch.S — Test BEQ, BNE, BLT, BGE, BLTU, BGEU instructions
.include "Tests/asm/test_macros.S"

INIT_TEST

    # ---- BEQ ----
    # Test 1: BEQ taken
    li x1, 42
    li x2, 42
    li x3, 0
    beq x1, x2, beq_taken
    li x3, 0           # should be skipped
    j test2
beq_taken:
    li x3, 1
test2:
    TEST_CASE 1, x3, 1

    # Test 2: BEQ not taken
    li x1, 42
    li x2, 43
    li x3, 1
    beq x1, x2, beq_not_taken_fail
    j test3
beq_not_taken_fail:
    li x3, 0
test3:
    TEST_CASE 2, x3, 1

    # ---- BNE ----
    # Test 3: BNE taken
    li x1, 10
    li x2, 20
    li x3, 0
    bne x1, x2, bne_taken
    li x3, 0
    j test4
bne_taken:
    li x3, 1
test4:
    TEST_CASE 3, x3, 1

    # Test 4: BNE not taken
    li x1, 10
    li x2, 10
    li x3, 1
    bne x1, x2, bne_not_taken_fail
    j test5
bne_not_taken_fail:
    li x3, 0
test5:
    TEST_CASE 4, x3, 1

    # ---- BLT ----
    # Test 5: BLT taken (signed: -1 < 1)
    li x1, -1
    li x2, 1
    li x3, 0
    blt x1, x2, blt_taken
    j test6
blt_taken:
    li x3, 1
test6:
    TEST_CASE 5, x3, 1

    # Test 6: BLT not taken (1 < -1 = false)
    li x1, 1
    li x2, -1
    li x3, 1
    blt x1, x2, blt_not_taken_fail
    j test7
blt_not_taken_fail:
    li x3, 0
test7:
    TEST_CASE 6, x3, 1

    # ---- BGE ----
    # Test 7: BGE taken (equal)
    li x1, 5
    li x2, 5
    li x3, 0
    bge x1, x2, bge_taken
    j test8
bge_taken:
    li x3, 1
test8:
    TEST_CASE 7, x3, 1

    # Test 8: BGE taken (greater)
    li x1, 10
    li x2, 5
    li x3, 0
    bge x1, x2, bge_taken2
    j test9
bge_taken2:
    li x3, 1
test9:
    TEST_CASE 8, x3, 1

    # Test 9: BGE not taken
    li x1, 4
    li x2, 5
    li x3, 1
    bge x1, x2, bge_not_taken_fail
    j test10
bge_not_taken_fail:
    li x3, 0
test10:
    TEST_CASE 9, x3, 1

    # ---- BLTU ----
    # Test 10: BLTU taken (unsigned)
    li x1, 5
    li x2, 10
    li x3, 0
    bltu x1, x2, bltu_taken
    j test11
bltu_taken:
    li x3, 1
test11:
    TEST_CASE 10, x3, 1

    # Test 11: BLTU not taken (-1 unsigned is large)
    li x1, -1         # 0xFFFFFFFF
    li x2, 5
    li x3, 1
    bltu x1, x2, bltu_not_taken_fail
    j test12
bltu_not_taken_fail:
    li x3, 0
test12:
    TEST_CASE 11, x3, 1

    # ---- BGEU ----
    # Test 12: BGEU taken (equal)
    li x1, 100
    li x2, 100
    li x3, 0
    bgeu x1, x2, bgeu_taken
    j test13
bgeu_taken:
    li x3, 1
test13:
    TEST_CASE 12, x3, 1

    # Test 13: BGEU taken (-1 unsigned >= 5)
    li x1, -1         # 0xFFFFFFFF
    li x2, 5
    li x3, 0
    bgeu x1, x2, bgeu_taken2
    j test14
bgeu_taken2:
    li x3, 1
test14:
    TEST_CASE 13, x3, 1

    TEST_PASS
    TEST_FAIL
