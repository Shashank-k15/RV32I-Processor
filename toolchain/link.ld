/* Linker script for RV32I-Processor
 * - .text starts at 0x0 (instruction memory base)
 * - .data starts at 0x4000 (data memory, word-aligned)
 * - TOHOST at 0x2000 is the pass/fail signaling address
 */

OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
    IMEM (rx)  : ORIGIN = 0x00000000, LENGTH = 64K
    DMEM (rwx) : ORIGIN = 0x00004000, LENGTH = 64K
}

SECTIONS
{
    .text :
    {
        *(.text.init)
        *(.text)
        *(.text.*)
    } > IMEM

    .data :
    {
        *(.data)
        *(.data.*)
        *(.rodata)
        *(.rodata.*)
        *(.bss)
        *(.bss.*)
        *(.sbss)
        *(.sbss.*)
    } > DMEM

}
