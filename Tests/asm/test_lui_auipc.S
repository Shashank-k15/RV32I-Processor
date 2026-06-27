# test_lui_auipc.S — Test LUI and AUIPC instructions
.include "Tests/asm/test_macros.S"

INIT_TEST

    # Test 1: LUI basic — loads upper 20 bits
    lui x3, 0x12345
    TEST_CASE 1, x3, 0x12345000

    # Test 2: LUI with 1
    lui x3, 1
    TEST_CASE 2, x3, 0x1000

    # Test 3: LUI with max positive
    lui x3, 0x7FFFF
    TEST_CASE 3, x3, 0x7FFFF000

    # Test 4: LUI with upper bit set
    lui x3, 0x80000
    TEST_CASE 4, x3, 0x80000000

    # Test 5: LUI + ADDI to construct arbitrary 32-bit value
    # Construct 0x12345678
    lui x3, 0x12345
    addi x3, x3, 0x678
    TEST_CASE 5, x3, 0x12345678

    # Test 6: AUIPC — adds upper immediate to PC
    # We can't check exact value easily, but we can check relative behavior
    auipc x3, 0         # x3 = PC of this instruction
    auipc x4, 0         # x4 = PC of this instruction (PC + 4 from previous)
    sub x5, x4, x3      # difference should be 4
    TEST_CASE 6, x5, 4

    # Test 7: AUIPC with non-zero immediate
    auipc x3, 1         # x3 = PC + 0x1000
    auipc x4, 0         # x4 = PC of this instruction
    sub x5, x3, x4      # x3 - x4 = (prev_PC + 0x1000) - curr_PC = 0x1000 - 4
    TEST_CASE 7, x5, 0xFFC

    TEST_PASS
    TEST_FAIL
