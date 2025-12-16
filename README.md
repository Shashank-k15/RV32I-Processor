
# RV32I-Processor
RV32I-Processor is a processor design written in SystemVerylog to be compliant with RISC-V [RV32I Base Integer Instruction Set, Version 2.1](https://five-embeddev.com/riscv-user-isa-manual/Priv-v1.12/rv32.html) 

---

### Overview
* Given a RV32I compliant machine code `program.hex` file it generates a waveform for all the registers.
* Uses [Verilator](https://www.veripool.org/verilator/) to simulate the processor behaviour when running the program, this is fast as verilator compiles the sim to a c++ file which runs as a binary.
* The waveform generated can be seen using another open-source tool [GTKWave](https://gtkwave.sourceforge.net/) 

---
### Try It Out!
Dependencies:
To build and simulate this project, you need the following tools installed on your system: 
1. **Verilator** (v4.0 or later)
	 * *Install (Ubuntu):* `sudo apt-get install verilator` 
	 * *Install (MacOS):* `brew install verilator` 
 2. **Make** 
	 * *Install:* Usually pre-installed (part of `build-essential` on Linux). 
 3. **GTKWave** 
	  * *Install (Ubuntu):* `sudo apt-get install gtkwave` *
	  * *Install (MacOS):* `brew install gtkwave`
---
Create the machine code in the root directory as program.hex

* To compile the design and run the testbench in the terminal:
```
bash make sim
```

* To run the simulation _and_ immediately open the results in GTKWave:
```
bash make wave
