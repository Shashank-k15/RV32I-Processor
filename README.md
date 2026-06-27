# RV32I-Processor

A single-cycle RISC-V processor design written in SystemVerilog, fully compliant with the [RV32I Base Integer Instruction Set, Version 2.1](https://five-embeddev.com/riscv-user-isa-manual/Priv-v1.12/rv32.html).

---

### Overview

This project implements a complete RV32I CPU that can execute any RV32I-compliant machine code program. It uses [Verilator](https://www.veripool.org/verilator/) for fast cycle-accurate simulation and includes a compilation toolchain that lets you write programs in **assembly or C** and run them on the processor.

**Key Features:**

- Full RV32I instruction set support (37 instructions)
- Automated test suite covering all instruction types
- Compilation toolchain for assembly (`.S`) and C (`.c`) programs
- VCD waveform output viewable with [GTKWave](https://gtkwave.sourceforge.net/)
- Single-cycle datapath — one instruction per clock cycle

---

### Architecture

The processor follows a classic single-cycle datapath design with 5 stages:

```
┌─────────┐    ┌─────────┐    ┌───────────┐    ┌──────────┐    ┌───────────┐
│  FETCH   │───▶│  DECODE  │───▶│  EXECUTE   │───▶│  MEMORY   │───▶│ WRITE BACK │
│          │    │          │    │            │    │           │    │            │
│ PC, IMEM │    │ CU, Regs │    │ ALU, PC    │    │ DMEM      │    │ WB Mux     │
│          │    │ ImmExt   │    │ Logic      │    │ Logic     │    │            │
└─────────┘    └─────────┘    └───────────┘    └──────────┘    └───────────┘
```

### Supported Instructions

All 37 RV32I base integer instructions are supported:

| Type                           | Instructions                                                           |
| ------------------------------ | ---------------------------------------------------------------------- |
| **R-type** (register-register) | `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLL`, `SRL`, `SRA`, `SLT`, `SLTU`   |
| **I-type** (immediate ALU)     | `ADDI`, `ANDI`, `ORI`, `XORI`, `SLLI`, `SRLI`, `SRAI`, `SLTI`, `SLTIU` |
| **I-type** (loads)             | `LB`, `LH`, `LW`, `LBU`, `LHU`                                         |
| **S-type** (stores)            | `SB`, `SH`, `SW`                                                       |
| **B-type** (branches)          | `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`                             |
| **J-type** (jumps)             | `JAL`, `JALR`                                                          |
| **U-type** (upper immediate)   | `LUI`, `AUIPC`                                                         |

---

### Try it out

### Dependencies

Dependencies:
To build and simulate this project, you need the following tools installed on your system:

1. **Verilator** (v4.0 or later)
   - _Install (Ubuntu):_ `sudo apt-get install verilator`
   - _Install (MacOS):_ `brew install verilator`
2. **Make**
   - _Install:_ Usually pre-installed (part of `build-essential` on Linux).
3. **GTKWave**
   - _Install (Ubuntu):_ `sudo apt-get install gtkwave` \*
   - _Install (MacOS):_ `brew install gtkwave`---

#### 1. Run the existing simulation

```bash
# Build and simulate with the included program.hex
make sim

# View the waveform in GTKWave
make wave
```

#### 2. Run the test suite

```bash
# Run all 12 automated tests (covers every RV32I instruction)
make test
```

#### 3. Compile and run your own program

**Assembly:**

```bash
# Compile an assembly file to program.hex
make compile SRC=toolchain/examples/hello.S

# Run it
make sim
```

**C:**

```bash
# Compile a C file to program.hex
make compile SRC=toolchain/examples/sum.c

# Run it
make sim
```

You can also use the compile script directly:

```bash
./toolchain/compile.sh my_program.S            # → program.hex
./toolchain/compile.sh my_program.S output.hex  # → output.hex
```

> **Note:** C programs run without libc (no `printf`, `malloc`, etc.). Use memory-mapped I/O to observe results via the waveform.

---
