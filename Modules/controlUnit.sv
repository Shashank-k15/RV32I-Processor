module controlUnit(
    input logic [31:0] instruction,

    output logic write_enable_reg,
    output logic write_enable_dmem,
    output logic read_enable_dmem, 
    output logic [3:0] controlUnitOpcode,
    output logic alu_imm,
    output logic pc_or_alu,
    output logic [1:0] WriteBackSel
);

// OPcode classification
localparam R_type_opcode       = 7'b0110011;
localparam I_type_opcode_alu   = 7'b0010011; 
localparam I_type_opcode_load  = 7'b0000011; 
localparam I_type_opcode_jump  = 7'b1100111; // JALR
localparam S_type_opcode       = 7'b0100011;
localparam U_type_opcode_lui   = 7'b0110111;
localparam U_type_opcode_auipc = 7'b0010111;
localparam J_type_opcode       = 7'b1101111; // JAL
localparam B_type_opcode       = 7'b1100011;

// ALU Opcodes 
localparam ALU_AND  = 4'b0000;
localparam ALU_OR   = 4'b0001;
localparam ALU_ADD  = 4'b0010;
localparam ALU_SUB  = 4'b0011;
localparam ALU_SLT  = 4'b0100;
localparam ALU_SLTU = 4'b0101;
localparam ALU_XOR  = 4'b0110;
localparam ALU_SLL  = 4'b0111;
localparam ALU_SRL  = 4'b1000;
localparam ALU_SRA  = 4'b1001;

// PC Logic Opcodes 
localparam PC_JAL   = 4'b0001;
localparam PC_JALR  = 4'b0010;
localparam PC_BEQ   = 4'b0011;
localparam PC_BNE   = 4'b0100;
localparam PC_BLT   = 4'b0101;
localparam PC_BGE   = 4'b0110;
localparam PC_BLTU  = 4'b0111;
localparam PC_BGEU  = 4'b1000;
localparam PC_AUIPC = 4'b1001;
localparam PC_LUI   = 4'b1010; 

// WriteBackSel Mux
localparam WB_ALU = 2'b00;
localparam WB_PC  = 2'b01;
localparam WB_MEM = 2'b10;

always_comb begin
    write_enable_reg  = 1'b0;
    write_enable_dmem = 1'b0;
    read_enable_dmem  = 1'b0;
    controlUnitOpcode = ALU_ADD; // Default to ADD
    alu_imm           = 1'b0;
    pc_or_alu         = 1'b0;    // Default to ALU
    WriteBackSel      = WB_ALU;  // Default to ALU result

    case(instruction[6:0])

        R_type_opcode: begin
            pc_or_alu        = 1'b0;
            alu_imm          = 1'b0;
            write_enable_reg = 1'b1;
            WriteBackSel     = WB_ALU;

            case(instruction[14:12]) // funct3
                3'b000: begin // ADD or SUB
                    if (instruction[31:25] == 7'b0100000) controlUnitOpcode = ALU_SUB;
                    else                                  controlUnitOpcode = ALU_ADD;
                end
                3'b001: controlUnitOpcode = ALU_SLL;
                3'b010: controlUnitOpcode = ALU_SLT;
                3'b011: controlUnitOpcode = ALU_SLTU;
                3'b100: controlUnitOpcode = ALU_XOR;
                3'b101: begin // SRL or SRA
                    if (instruction[31:25] == 7'b0100000) controlUnitOpcode = ALU_SRA;
                    else                                  controlUnitOpcode = ALU_SRL;
                end
                3'b110: controlUnitOpcode = ALU_OR;
                3'b111: controlUnitOpcode = ALU_AND;
                default: controlUnitOpcode = ALU_ADD; 
            endcase
        end

        I_type_opcode_alu: begin
            pc_or_alu        = 1'b0;
            alu_imm          = 1'b1;
            write_enable_reg = 1'b1;
            WriteBackSel     = WB_ALU;

            case(instruction[14:12]) // funct3
                3'b000: controlUnitOpcode = ALU_ADD;  // addi
                3'b010: controlUnitOpcode = ALU_SLT;  // slti
                3'b011: controlUnitOpcode = ALU_SLTU; // sltiu
                3'b100: controlUnitOpcode = ALU_XOR;  // xori
                3'b110: controlUnitOpcode = ALU_OR;   // ori
                3'b111: controlUnitOpcode = ALU_AND;  // andi
                3'b001: controlUnitOpcode = ALU_SLL;  // slli
                3'b101: begin // SRLI or SRAI
                    if (instruction[31:25] == 7'b0100000) controlUnitOpcode = ALU_SRA;
                    else                                  controlUnitOpcode = ALU_SRL;
                end
                default: controlUnitOpcode = ALU_ADD; 
            endcase
        end

        I_type_opcode_load: begin
            pc_or_alu         = 1'b0;
            alu_imm           = 1'b1;
            controlUnitOpcode = ALU_ADD;
            read_enable_dmem  = 1'b1;
            write_enable_reg  = 1'b1;
            WriteBackSel      = WB_MEM;
        end

        S_type_opcode: begin
            pc_or_alu         = 1'b0;
            alu_imm           = 1'b1;
            controlUnitOpcode = ALU_ADD;
            write_enable_dmem = 1'b1;
        end

        B_type_opcode: begin
            pc_or_alu = 1'b1;
            alu_imm   = 1'b0;
            case(instruction[14:12]) // funct3
                3'b000: controlUnitOpcode = PC_BEQ;
                3'b001: controlUnitOpcode = PC_BNE;
                3'b100: controlUnitOpcode = PC_BLT;
                3'b101: controlUnitOpcode = PC_BGE;
                3'b110: controlUnitOpcode = PC_BLTU;
                3'b111: controlUnitOpcode = PC_BGEU;
                default: controlUnitOpcode = PC_BEQ; 
            endcase
        end

        U_type_opcode_lui: begin
            pc_or_alu         = 1'b1;
            alu_imm           = 1'b1;
            controlUnitOpcode = PC_LUI;
            write_enable_reg  = 1'b1;
            WriteBackSel      = WB_PC;
        end

        U_type_opcode_auipc: begin
            pc_or_alu         = 1'b1;
            alu_imm           = 1'b1;
            controlUnitOpcode = PC_AUIPC;
            write_enable_reg  = 1'b1;
            WriteBackSel      = WB_PC;
        end

        J_type_opcode: begin // JAL
            pc_or_alu         = 1'b1;
            alu_imm           = 1'b1;
            controlUnitOpcode = PC_JAL;
            write_enable_reg  = 1'b1;
            WriteBackSel      = WB_PC;
        end

        I_type_opcode_jump: begin // JALR
            pc_or_alu         = 1'b1;
            alu_imm           = 1'b1;
            controlUnitOpcode = PC_JALR;
            write_enable_reg  = 1'b1;
            WriteBackSel      = WB_PC;
        end

        default: begin
        end
    endcase
end

endmodule
