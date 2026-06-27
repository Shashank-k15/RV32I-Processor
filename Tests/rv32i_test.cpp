#include "VdataPath.h"
#include "VdataPath___024root.h"
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <string>
#include <verilated.h>
#include <verilated_vcd_c.h>

// ANSI color codes
#define RESET "\033[0m"
#define RED "\033[31m"
#define GREEN "\033[32m"
#define YELLOW "\033[33m"
#define CYAN "\033[36m"
#define BOLD "\033[1m"

// Test convention:
//   - TOHOST address: 0x2000 (word index 0x2000 >> 2 = 0x800 = 2048)
//   - Writing 1 to TOHOST = PASS
//   - Writing any other non-zero value to TOHOST = FAIL (value = test case
//   number that failed)
//   - The test enters an infinite loop after writing TOHOST
//

static const uint32_t TOHOST_WORD_ADDR = 0x2000 >> 2;
static const int MAX_CYCLES = 10000;

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);

  // We expect: ./rv32i_test [--trace]
  bool do_trace = false;
  for (int i = 1; i < argc; i++) {
    if (strcmp(argv[i], "--trace") == 0) {
      do_trace = true;
    }
  }

  VdataPath *dut = new VdataPath;

  VerilatedVcdC *m_trace = nullptr;
  if (do_trace) {
    Verilated::traceEverOn(true);
    m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 99);
    m_trace->open("waveform.vcd");
  }

  vluint64_t sim_time = 0;

  // Reset the CPU
  dut->rst = 1;
  dut->clk = 0;
  dut->eval();
  if (m_trace)
    m_trace->dump(sim_time++);

  dut->clk = 1;
  dut->eval();
  if (m_trace)
    m_trace->dump(sim_time++);

  dut->rst = 0;

  // Run simulation
  uint32_t prev_pc = 0xFFFFFFFF;
  int stall_count = 0;
  bool finished = false;
  int cycles = 0;

  for (cycles = 0; cycles < MAX_CYCLES; cycles++) {
    // Negative edge
    dut->clk = 0;
    dut->eval();
    if (m_trace)
      m_trace->dump(sim_time++);

    // Positive edge
    dut->clk = 1;
    dut->eval();
    if (m_trace)
      m_trace->dump(sim_time++);

    // Read current PC
    uint32_t cur_pc = dut->rootp->dataPath__DOT__currentAddress;

    // Detect infinite loop: PC unchanged for 2 cycles
    if (cur_pc == prev_pc) {
      stall_count++;
      if (stall_count >= 2) {
        finished = true;
        break;
      }
    } else {
      stall_count = 0;
    }
    prev_pc = cur_pc;
  }

  // Read TOHOST from data memory
  uint32_t tohost_val =
      dut->rootp->dataPath__DOT__dmem_inst__DOT__mem_array[TOHOST_WORD_ADDR];

  if (m_trace) {
    m_trace->close();
    delete m_trace;
  }

  if (!finished) {
    std::cout << RED << "[TIMEOUT]" << RESET
              << " Simulation did not halt within " << MAX_CYCLES << " cycles."
              << std::endl;
    delete dut;
    return 2;
  }

  if (tohost_val == 1) {
    std::cout << GREEN << "[PASS]" << RESET << " Test passed in " << cycles
              << " cycles." << std::endl;
    delete dut;
    return 0;
  } else {
    // tohost_val contains the failing test number (by convention: test_num << 1
    // | 1)
    uint32_t failing_test = tohost_val >> 1;
    std::cout << RED << "[FAIL]" << RESET
              << " Test FAILED. TOHOST = " << tohost_val;
    if (failing_test > 0) {
      std::cout << " (test case #" << failing_test << ")";
    }
    std::cout << " after " << cycles << " cycles." << std::endl;

    // Dump register state for debugging
    std::cout << CYAN << "Register dump:" << RESET << std::endl;
    for (int i = 0; i < 32; i++) {
      uint32_t regval =
          dut->rootp->dataPath__DOT__reg_file_inst__DOT__registers[i];
      if (regval != 0) {
        printf("  x%-2d = 0x%08X (%d)\n", i, regval, (int32_t)regval);
      }
    }

    delete dut;
    return 1;
  }
}
