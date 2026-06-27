# test_load_store.S — Test LW/SW, LH/SH/LHU, LB/SB/LBU instructions
.include "Tests/asm/test_macros.S"

INIT_TEST

    li x20, 0x4000

    # ===== Word Load/Store =====
    # Test 1: SW then LW
    li x1, 0xDEADBEEF
    sw x1, 0(x20)
    lw x3, 0(x20)
    TEST_CASE 1, x3, 0xDEADBEEF

    # Test 2: SW/LW at offset
    li x1, 0x12345678
    sw x1, 4(x20)
    lw x3, 4(x20)
    TEST_CASE 2, x3, 0x12345678

    # Test 3: Multiple words
    li x1, 0xAAAAAAAA
    li x2, 0xBBBBBBBB
    sw x1, 8(x20)
    sw x2, 12(x20)
    lw x3, 8(x20)
    lw x4, 12(x20)
    TEST_CASE 3, x3, 0xAAAAAAAA
    TEST_CASE 4, x4, 0xBBBBBBBB

    # ===== Byte Load/Store =====
    # Test 5: SB then LB (positive byte)
    li x1, 0x42
    sb x1, 16(x20)
    lb x3, 16(x20)
    TEST_CASE 5, x3, 0x42

    # Test 6: SB then LB (negative byte — sign extension)
    li x1, 0x80           # -128 as signed byte
    sb x1, 17(x20)
    lb x3, 17(x20)
    TEST_CASE 6, x3, 0xFFFFFF80

    # Test 7: SB then LBU (unsigned — zero extension)
    li x1, 0x80
    sb x1, 18(x20)
    lbu x3, 18(x20)
    TEST_CASE 7, x3, 0x80

    # Test 8: Store word, load individual bytes
    li x1, 0x04030201
    sw x1, 20(x20)
    lbu x3, 20(x20)       # byte 0 = 0x01
    TEST_CASE 8, x3, 0x01
    lbu x3, 21(x20)       # byte 1 = 0x02
    TEST_CASE 9, x3, 0x02
    lbu x3, 22(x20)       # byte 2 = 0x03
    TEST_CASE 10, x3, 0x03
    lbu x3, 23(x20)       # byte 3 = 0x04
    TEST_CASE 11, x3, 0x04

    # ===== Halfword Load/Store =====
    # Test 12: SH then LH (positive)
    li x1, 0x1234
    sh x1, 24(x20)
    lh x3, 24(x20)
    TEST_CASE 12, x3, 0x1234

    # Test 13: SH then LH (negative — sign extension)
    li x1, 0x8000          # -32768 as signed halfword
    sh x1, 26(x20)
    lh x3, 26(x20)
    TEST_CASE 13, x3, 0xFFFF8000

    # Test 14: SH then LHU (unsigned — zero extension)
    li x1, 0x8000
    sh x1, 28(x20)
    lhu x3, 28(x20)
    TEST_CASE 14, x3, 0x8000

    # Test 15: Store word, load halfwords
    li x1, 0xBEEFCAFE
    sw x1, 32(x20)
    lhu x3, 32(x20)       # lower half = 0xCAFE
    TEST_CASE 15, x3, 0xCAFE
    lhu x3, 34(x20)       # upper half = 0xBEEF
    TEST_CASE 16, x3, 0xBEEF

    TEST_PASS
    TEST_FAIL
