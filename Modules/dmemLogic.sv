module dmemLogic(
    // Inputs from Control Unit
    input logic read_enable,
    input logic write_enable,
    input logic [2:0] funct3,
    
    // Inputs from Datapath
    input logic [31:0] alu_address,
    input logic [31:0] wdata_from_reg, // Data from rs2
    input logic [31:0] rdata_from_mem, // Data from dmem

    // Outputs to dmem
    output logic [3:0] byte_enable_to_mem,
    output logic [31:0] wdata_to_mem,

    // Output to Register File
    output logic [31:0] rdata_to_reg
);

    // Handles byte/half-word selection and sign/zero extension
    logic [7:0]  selected_byte;
    logic [15:0] selected_half;

    // Load Opcodes (funct3)
    localparam lb  = 3'b000;
    localparam lh  = 3'b001;
    localparam lw  = 3'b010;
    localparam lbu = 3'b100;
    localparam lhu = 3'b101;

    // Store Opcodes (funct3)
    localparam sb = 3'b000;
    localparam sh = 3'b001;
    localparam sw = 3'b010;

    always_comb begin
        rdata_to_reg       = 32'b0;
        wdata_to_mem       = 32'b0;
        byte_enable_to_mem = 4'b0000;
        selected_byte      = 8'b0;
        selected_half      = 16'b0;

        // Laod Logic
        if (read_enable) begin
            case (alu_address[1:0])
                2'b00: selected_byte = rdata_from_mem[7:0];
                2'b01: selected_byte = rdata_from_mem[15:8];
                2'b10: selected_byte = rdata_from_mem[23:16];
                2'b11: selected_byte = rdata_from_mem[31:24];
            endcase
            
            case (alu_address[1])
                1'b0: selected_half = rdata_from_mem[15:0];
                1'b1: selected_half = rdata_from_mem[31:16];
            endcase

            case (funct3)
                lb:  rdata_to_reg = {{24{selected_byte[7]}}, selected_byte};
                lh:  rdata_to_reg = {{16{selected_half[15]}}, selected_half};
                lw:  rdata_to_reg = rdata_from_mem;
                lbu: rdata_to_reg = {24'b0, selected_byte};
                lhu: rdata_to_reg = {16'b0, selected_half};
                default: rdata_to_reg = 32'b0;
            endcase
        end

        // Store Logic
        if (write_enable) begin
            case (funct3)
                sb: begin
                    // Replicate the byte across all 4 byte lanes
                    wdata_to_mem = {4{wdata_from_reg[7:0]}};
                    // Enable the correct byte lane based on address
                    case (alu_address[1:0])
                        2'b00: byte_enable_to_mem = 4'b0001;
                        2'b01: byte_enable_to_mem = 4'b0010;
                        2'b10: byte_enable_to_mem = 4'b0100;
                        2'b11: byte_enable_to_mem = 4'b1000;
                    endcase
                end
                
                sh: begin
                    // Replicate the half-word across both half-word lanes
                    wdata_to_mem = {2{wdata_from_reg[15:0]}};
                    // Enable the correct half-word lane based on address
                    case (alu_address[1])
                        1'b0: byte_enable_to_mem = 4'b0011;
                        1'b1: byte_enable_to_mem = 4'b1100;
                    endcase
                end

                sw: begin
                    wdata_to_mem       = wdata_from_reg;
                    byte_enable_to_mem = 4'b1111;
                end
                
                default: begin
                    wdata_to_mem       = 32'b0;
                    byte_enable_to_mem = 4'b0000;
                end
            endcase
        end
    end

endmodule
