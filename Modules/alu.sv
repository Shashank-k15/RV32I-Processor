module alu(
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [3:0] opcode,
    input logic pc_or_alu,
    output logic [31:0] result,
    output logic zero
);

    localparam AND = 4'b0000;
    localparam OR  = 4'b0001;
    localparam ADD  = 4'b0010;
    localparam SUB  = 4'b0011;
    localparam SLT  = 4'b0100;
    localparam SLTU  = 4'b0101;
    localparam XOR  = 4'b0110;
    localparam SLL  = 4'b0111;
    localparam SRL  = 4'b1000;
    localparam SRA  = 4'b1001;
    
    always_comb begin 
        result = 32'b0; 

        if (!pc_or_alu) begin
            case (opcode)
                AND: result = a & b;
                OR: result = a | b;
                ADD: result = a + b;
                SUB: result = a - b;
                XOR: result = a ^ b;
                SLL: result = a << b[4:0];
                SRL: result = a >> b[4:0];
                SRA: result = $signed(a) >>> b[4:0];
                SLT: result =  ($signed(a) < $signed(b)) ? 32'b1 : 32'b0; 
                SLTU: result =  (a < b) ? 32'b1 : 32'b0; 
                default: result = 32'b0;
            endcase
        end
    end

    assign zero = (result == 32'b0) ? 1'b1 : 1'b0;
        
endmodule
