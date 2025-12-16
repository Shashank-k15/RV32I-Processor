#include "VdataPath.h"
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);

  VdataPath *dut = new VdataPath;

  Verilated::traceEverOn(true);
  VerilatedVcdC *m_trace = new VerilatedVcdC;
  dut->trace(m_trace, 99);
  m_trace->open("waveform.vcd");

  vluint64_t sim_time = 0;

  // Reset the CPU
  dut->rst = 1;
  dut->clk = 0;
  dut->eval();
  m_trace->dump(sim_time++);

  dut->clk = 1;
  dut->eval();
  m_trace->dump(sim_time++);

  dut->rst = 0;

  // Run for 30 cycles (60 ticks)
  for (int i = 0; i < 30; i++) {
    dut->clk = 0;
    dut->eval();
    m_trace->dump(sim_time++);

    dut->clk = 1;
    dut->eval();
    m_trace->dump(sim_time++);
  }

  std::cout << "Simulation finished. Check waveform.vcd." << std::endl;

  m_trace->close();
  delete dut;

  return 0;
}
