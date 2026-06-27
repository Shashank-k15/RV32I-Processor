# hello.S — Simple register exercise program
# This program computes the sum 1 + 2 + 3 + ... + 10 = 55

.section .text.init
.globl _start

_start:
    li x10, 0           # sum = 0
    li x11, 1           # i = 1
    li x12, 10          # limit = 10

loop:
    add x10, x10, x11   # sum += i
    addi x11, x11, 1    # i++
    ble x11, x12, loop  # if i <= 10, continue

    # Result: x10 = 55

    li x20, 0x4000
    sw x10, 0(x20)

done:
    j done               # infinite loop (halt)
