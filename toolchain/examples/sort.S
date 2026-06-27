# sort.S — Bubble sort implementation in RV32I assembly
# Sorts an array of 8 integers in ascending order

.section .text.init
.globl _start

_start:
    li x20, 0x4000       # base address

    # Store unsorted array: [8, 3, 7, 1, 5, 2, 6, 4]
    li x1, 8
    sw x1, 0(x20)
    li x1, 3
    sw x1, 4(x20)
    li x1, 7
    sw x1, 8(x20)
    li x1, 1
    sw x1, 12(x20)
    li x1, 5
    sw x1, 16(x20)
    li x1, 2
    sw x1, 20(x20)
    li x1, 6
    sw x1, 24(x20)
    li x1, 4
    sw x1, 28(x20)

    # Bubble sort
    li x10, 8             # n = array length
    addi x10, x10, -1     # n-1 (outer loop bound)

outer_loop:
    beqz x10, sort_done
    li x11, 0             # j = 0 (inner loop counter)
    mv x12, x10           # inner loop bound = current pass limit

inner_loop:
    beq x11, x12, outer_dec

    # Calculate addresses: arr[j] and arr[j+1]
    slli x13, x11, 2      # j * 4 (byte offset)
    add x14, x20, x13     # &arr[j]
    lw x15, 0(x14)        # arr[j]
    lw x16, 4(x14)        # arr[j+1]

    # Compare and swap if arr[j] > arr[j+1]
    ble x15, x16, no_swap
    sw x16, 0(x14)        # arr[j] = arr[j+1]
    sw x15, 4(x14)        # arr[j+1] = arr[j]

no_swap:
    addi x11, x11, 1      # j++
    j inner_loop

outer_dec:
    addi x10, x10, -1     # pass--
    j outer_loop

sort_done:

done:
    j done                 # halt
