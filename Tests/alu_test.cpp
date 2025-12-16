#include "Valu.h"
#include <iostream>
#include <string>
#include <verilated.h>
#include <verilated_vcd_c.h>

// color codes
#define RESET "\033[0m"
#define RED "\033[31m"
#define GREEN "\033[32m"
#define YELLOW "\033[33m"

// Helper function to run a single test case
void run_test_case(Valu *dut, VerilatedVcdC *m_trace, vluint64_t &sim_time,
                   uint32_t a, uint32_t b, uint8_t opcode,
                   uint32_t expected_result, bool expected_zero,
                   const std::string &test_name) {

  // Set DUT inputs
  dut->a = a;
  dut->b = b;
  dut->opcode = opcode;

  // Evaluate the model
  dut->eval();

  // Dump waveform data for this timestep
  m_trace->dump(sim_time);

  // Check the results
  bool pass = true;

  if (dut->result != expected_result) {
    std::cout << RED << "[FAIL] " << RESET << test_name << " (Result)"
              << " | Expected: " << expected_result << ", Got: " << dut->result
              << std::endl;
    pass = false;
  }

  if (dut->zero != expected_zero) {
    std::cout << RED << "[FAIL] " << RESET << test_name << " (Zero Flag)"
              << " | Expected: " << expected_zero << ", Got: " << (int)dut->zero
              << std::endl;
    pass = false;
  }

  if (pass) {
    std::cout << GREEN << "[PASS] " << RESET << test_name << std::endl;
  }

  // Advance simulation time
  sim_time++;
}

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);

  Valu *dut = new Valu;

  Verilated::traceEverOn(true);
  VerilatedVcdC *m_trace = new VerilatedVcdC;
  dut->trace(m_trace, 99);
  m_trace->open("waveform.vcd");

  vluint64_t sim_time = 0;

  // --- Define opcodes ---
  const uint8_t ALU_ADD = 0b0010;
  const uint8_t ALU_SUB = 0b0011;
  const uint8_t ALU_AND = 0b0000;
  const uint8_t ALU_OR = 0b0001;
  const uint8_t ALU_XOR = 0b0110;
  const uint8_t ALU_SLL = 0b0111;
  const uint8_t ALU_SRL = 0b1000;
  const uint8_t ALU_SRA = 0b1001;
  const uint8_t ALU_SLT = 0b0100;
  const uint8_t ALU_SLTU = 0b0101;

  std::cout << YELLOW << "Starting ALU Testbench..." << RESET << std::endl;

  run_test_case(dut, m_trace, sim_time, 10, 5, ALU_ADD, 15, false,
                "Test 1: ADD: 10 + 5");
  run_test_case(dut, m_trace, sim_time, 0, 0, ALU_ADD, 0, true,
                "Test 2: ADD: 0 + 0 (Zero check)");
  run_test_case(dut, m_trace, sim_time, 10, 5, ALU_SUB, 5, false,
                "Test 3: SUB: 10 - 5");
  run_test_case(dut, m_trace, sim_time, 5, 10, ALU_SUB, (uint32_t)-5, false,
                "Test 4: SUB: 5 - 10 (Negative result)");
  run_test_case(dut, m_trace, sim_time, 10, 10, ALU_SUB, 0, true,
                "Test 5: SUB: 10 - 10 (Zero check)");
  run_test_case(dut, m_trace, sim_time, 0b1100, 0b1010, ALU_AND, 0b1000, false,
                "Test 6: AND: 12 & 10");
  run_test_case(dut, m_trace, sim_time, 0b1100, 0b1010, ALU_OR, 0b1110, false,
                "Test 7: OR: 12 | 10");
  run_test_case(dut, m_trace, sim_time, 0b1100, 0b1010, ALU_XOR, 0b0110, false,
                "Test 8: XOR: 12 ^ 10");
  run_test_case(dut, m_trace, sim_time, 0b1, 2, ALU_SLL, 0b100, false,
                "Test 9: SLL: 1 << 2");
  run_test_case(dut, m_trace, sim_time, 0b1000, 2, ALU_SRL, 0b10, false,
                "Test 10: SRL: 8 >> 2");
  run_test_case(dut, m_trace, sim_time, 0x80000000, 4, ALU_SRA, 0xF8000000,
                false, "Test 11: SRA: Negative number");
  run_test_case(dut, m_trace, sim_time, 5, 10, ALU_SLT, 1, false,
                "Test 12: SLT: 5 < 10 (signed)");
  run_test_case(dut, m_trace, sim_time, 10, 5, ALU_SLT, 0, true,
                "Test 13: SLT: 10 < 5 (signed)");
  run_test_case(dut, m_trace, sim_time, (uint32_t)-10, 5, ALU_SLT, 1, false,
                "Test 14: SLT: -10 < 5 (signed)");
  run_test_case(dut, m_trace, sim_time, 5, 10, ALU_SLTU, 1, false,
                "Test 15: SLTU: 5 < 10 (unsigned)");
  run_test_case(dut, m_trace, sim_time, (uint32_t)-10, 5, ALU_SLTU, 0, true,
                "Test 16: SLTU: -10 (large unsigned) < 5");

  std::cout << YELLOW << "All test cases completed." << RESET << std::endl;

  m_trace->close();
  delete dut;

  return 0;
}
