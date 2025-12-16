# Compiler
VERILATOR = verilator

# Verilator flags
VERILATOR_FLAGS = -j 0 -Wall --cc --trace
# ADDED FLAGS to suppress benign warnings.
# We will NOT suppress CASEINCOMPLETE, as that's a real bug.
VERILATOR_FLAGS += -Wno-UNUSEDSIGNAL
VERILATOR_FLAGS += -Wno-PINCONNECTEMPTY

# Simulation source files
TOP_MODULE = dataPath
TB_CPP_FILE = Tests/dataPath_test.cpp
DESIGN_FILE = $(TOP_MODULE).sv

# Output executable name
EXECUTABLE = V$(TOP_MODULE)

# Rule to build the executable
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

# Rule to clean up generated files
clean:
	@echo "Cleaning up..."
	rm -rf obj_dir
	rm -f waveform.vcd

.PHONY: all sim wave clean
