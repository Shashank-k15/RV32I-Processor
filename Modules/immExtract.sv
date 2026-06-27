module immExtract(
    input logic [31:0] instruction,
    output logic [31:0] immediate
);
localparam I_type_opcode_alu= 7'b0010011; 
localparam I_type_opcode_load= 7'b0000011; 
localparam I_type_opcode_jump = 7'b1100111; 
localparam S_type_opcode= 7'b0100011;
localparam U_type_opcode_lui= 7'b0110111;
localparam U_type_opcode_auipc= 7'b0010111;
localparam J_type_opcode= 7'b1101111;
localparam B_type_opcode= 7'b1100011;

always_comb begin
    immediate = 32'b0;
    
    case(instruction[6:0])
        I_type_opcode_alu : begin
            logic [2:0] funct3;
            funct3 = instruction[14:12];
            case(funct3)
            // for slli, srli, srai instructions only
                3'b001, 3'b101: begin
                    immediate = { 27'b0, instruction[24:20] };
                end
                default: begin
                    immediate = { {20{instruction[31]}}, instruction[31:20] };
                end
            endcase
        end

        // Loads and JALR always use the full 12-bit sign-extended immediate
        I_type_opcode_load, I_type_opcode_jump : begin
            immediate = { {20{instruction[31]}}, instruction[31:20] };
        end

        S_type_opcode :begin
            immediate = { {20{instruction[31]}}, instruction[31:25], instruction[11:7] };
        end

        B_type_opcode :begin
            immediate = { {19{instruction[31]}}, instruction[31], instruction[7], 
                          instruction[30:25], instruction[11:8], 1'b0 };
        end

        J_type_opcode :begin
            immediate = {{11{instruction[31]}}, instruction[31], instruction[19:12],
                                  instruction[20], instruction[30:21], 1'b0};
        end

        U_type_opcode_auipc, U_type_opcode_lui :begin
            immediate = { instruction[31:12], 12'b0};
        end

        default: begin
            immediate = 32'b0;
        end
    endcase
end

endmodule
