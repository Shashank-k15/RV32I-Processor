# test_imm_alu.S — Test I-type ALU instructions (ADDI, ANDI, ORI, XORI, SLTI, SLTIU)
.include "Tests/asm/test_macros.S"

INIT_TEST

    # Test 1: ADDI basic
    li x1, 10
    addi x3, x1, 5
    TEST_CASE 1, x3, 15

    # Test 2: ADDI negative immediate
    li x1, 10
    addi x3, x1, -3
    TEST_CASE 2, x3, 7

    # Test 3: ADDI to zero register
    addi x3, x0, 42
    TEST_CASE 3, x3, 42

    # Test 4: ANDI
    li x1, 0xFF
    andi x3, x1, 0x0F
    TEST_CASE 4, x3, 0x0F

    # Test 5: ORI
    li x1, 0xF0
    ori x3, x1, 0x0F
    TEST_CASE 5, x3, 0xFF

    # Test 6: XORI
    li x1, 0xFF
    xori x3, x1, 0x0F
    TEST_CASE 6, x3, 0xF0

    # Test 7: SLTI true
    li x1, 5
    slti x3, x1, 10
    TEST_CASE 7, x3, 1

    # Test 8: SLTI false
    li x1, 10
    slti x3, x1, 5
    TEST_CASE 8, x3, 0

    # Test 9: SLTI with negative
    li x1, -5
    slti x3, x1, 1
    TEST_CASE 9, x3, 1

    # Test 10: SLTIU
    li x1, 5
    sltiu x3, x1, 10
    TEST_CASE 10, x3, 1

    # Test 11: SLTIU false
    li x1, 10
    sltiu x3, x1, 5
    TEST_CASE 11, x3, 0

    TEST_PASS
    TEST_FAIL
