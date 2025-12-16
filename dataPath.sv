`include "Modules/programCounter.sv"
`include "Modules/imem.sv"
`include "Modules/controlUnit.sv"
`include "Modules/immExtract.sv"
`include "Modules/register.sv"
`include "Modules/alu.sv"
`include "Modules/programCounterLogic.sv"
`include "Modules/dmemLogic.sv"
`include "Modules/dmem.sv"

module dataPath(
    input logic clk,
    input logic rst
);

    // ===================================
    // Control Signal Wires
    // ===================================
    logic write_enable_reg;
    logic write_enable_dmem;
    logic read_enable_dmem; 
    logic [3:0] controlUnitOpcode;
    logic alu_imm;
    logic pc_or_alu;
    logic [1:0] WriteBackSel;

    // ===================================
    // Data Path Wires
    // ===================================
    logic [31:0] instruction;
    logic [31:0] currentAddress, nextAddress;
    logic [31:0] immediate;
    logic [31:0] rdata1, rdata2;
    logic [31:0] alu_result;
    logic [31:0] pc_logic_result;
    logic [31:0] dmem_rdata_raw;
    logic [31:0] dmem_rdata_final;
    logic [31:0] dmem_wdata_final;
    logic [3:0]  dmem_byte_enable;
    logic [31:0] wdata_to_reg_file;
    logic [4:0]  rs1_addr, rs2_addr, rd_addr;
    logic [31:0] alu_src_b;
    logic zero_flag_from_alu;

    // ===================================
    // 1 Fetch Stage
    // ===================================
    programCounter pc_inst (
        .clk(clk),
        .reset(rst),
        .nextAddress(nextAddress),
        .currentAddress(currentAddress)
    );

    imem imem_inst (
        .address(currentAddress),
        .data_at_memory_address(instruction)
    );

    // ===================================
    // 2  Decode Stage
    // ===================================
    controlUnit cu_inst (
        .instruction(instruction),
        .write_enable_reg(write_enable_reg),
        .write_enable_dmem(write_enable_dmem),
        .read_enable_dmem(read_enable_dmem),
        .controlUnitOpcode(controlUnitOpcode),
        .alu_imm(alu_imm),
        .pc_or_alu(pc_or_alu),
        .WriteBackSel(WriteBackSel)
    );

    immExtract imm_inst (
        .instruction(instruction),
        .immediate(immediate)
    );

    assign rs1_addr = instruction[19:15];
    assign rs2_addr = instruction[24:20];
    assign rd_addr  = instruction[11:7];

    register reg_file_inst (
        .write_enable(write_enable_reg),
        .clk(clk),
        .wdata(wdata_to_reg_file),
        .rd(rd_addr),
        .rs1(rs1_addr),
        .rs2(rs2_addr),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );

    // ===================================
    // 3 Execution Stage
    // ===================================

    // ALU's second operand Mux
    assign alu_src_b = (alu_imm) ? immediate : rdata2;

    alu alu_inst (
        .a(rdata1),
        .b(alu_src_b),
        .opcode(controlUnitOpcode),
        .pc_or_alu(pc_or_alu),
        .result(alu_result),
        .zero(zero_flag_from_alu)
    );

    programCounterLogic pc_logic_inst (
        .rs1(rdata1),
        .rs2(rdata2), 
        .immediate(immediate),
        .opcode(controlUnitOpcode),
        .pc_or_alu(pc_or_alu),
        .currentAddress(currentAddress),
        .rd(pc_logic_result),
        .nextAddress(nextAddress)
    );

    // ===================================
    // 4 
    // ===================================
    dmemLogic dmem_logic_inst (
        .read_enable(read_enable_dmem),
        .write_enable(write_enable_dmem),
        .funct3(instruction[14:12]),
        .alu_address(alu_result),
        .wdata_from_reg(rdata2),
        .rdata_from_mem(dmem_rdata_raw),
        .byte_enable_to_mem(dmem_byte_enable),
        .wdata_to_mem(dmem_wdata_final),
        .rdata_to_reg(dmem_rdata_final)
    );

    dmem dmem_inst (
        .clk(clk),
        .write_enable(write_enable_dmem),
        .byte_enable(dmem_byte_enable),
        .address(alu_result),
        .wdata(dmem_wdata_final),
        .rdata(dmem_rdata_raw)
    );

    // ===================================
    // 5 Write Back Stage
    // ===================================
    localparam WB_ALU = 2'b00;
    localparam WB_PC  = 2'b01;
    localparam WB_MEM = 2'b10;

    always_comb begin
        case (WriteBackSel)
            WB_ALU: wdata_to_reg_file = alu_result;
            WB_PC:  wdata_to_reg_file = pc_logic_result;
            WB_MEM: wdata_to_reg_file = dmem_rdata_final;
            default: wdata_to_reg_file = 32'b0;
        endcase
    end

endmodule
