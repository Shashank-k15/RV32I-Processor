# ============================================================================
# RV32I-Processor Makefile
# ============================================================================
# Targets:
#   make sim         — Build and run the simulation with program.hex
#   make wave        — Run simulation and open waveform in GTKWave
#   make test        — Run the full RV32I compliance test suite
#   make compile     — Compile assembly/C to program.hex (SRC=file.S)
#   make clean       — Remove generated files
# ============================================================================

# Compiler
VERILATOR = verilator

# Verilator flags
VERILATOR_FLAGS = -j 0 -Wall --cc --trace
# ADDED FLAGS to suppress benign warnings.
VERILATOR_FLAGS += -Wno-UNUSEDSIGNAL
VERILATOR_FLAGS += -Wno-PINCONNECTEMPTY

# Simulation source files
TOP_MODULE = dataPath
DESIGN_FILE = $(TOP_MODULE).sv

TB_CPP_FILE = Tests/dataPath_test.cpp
EXECUTABLE = V$(TOP_MODULE)

obj_dir/$(EXECUTABLE): $(DESIGN_FILE) $(TB_CPP_FILE)
	@echo "Verilating $(DESIGN_FILE)..."
	$(VERILATOR) $(VERILATOR_FLAGS) $(DESIGN_FILE) --exe $(TB_CPP_FILE)
	@echo "Building executable..."
	make -C obj_dir -f $(EXECUTABLE).mk $(EXECUTABLE)

all: sim

# Rule to run the simulation
sim: obj_dir/$(EXECUTABLE)
	./obj_dir/$(EXECUTABLE)

# Rule to generate and view waveforms
wave: sim
	gtkwave waveform.vcd

# ── Test suite ──────────────────────────────────────────
# Runs all assembly tests in Tests/asm/ against the RTL
test:
	@bash Tests/run_tests.sh

# ── Compilation toolchain ───────────────────────────────
# Usage: make compile SRC=path/to/source.S
#        make compile SRC=path/to/source.c
compile:
ifndef SRC
	@echo "Usage: make compile SRC=<source_file.S|.c>"
	@echo "Example: make compile SRC=toolchain/examples/hello.S"
	@exit 1
endif
	@bash toolchain/compile.sh $(SRC)

# ── Clean ───────────────────────────────────────────────
clean:
	@echo "Cleaning up..."
	rm -rf obj_dir
	rm -f waveform.vcd
	rm -f waveform_*.vcd

.PHONY: all sim wave clean test compile
