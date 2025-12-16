module programCounterLogic(
    input logic [31:0] rs1,
    input logic [31:0] rs2, 
    input logic [31:0] immediate,
    input logic [3:0] opcode,
    input logic pc_or_alu,

    input logic [31:0] currentAddress,
    output logic [31:0] rd,
    output logic [31:0] nextAddress
);
    localparam jal=4'b0001;
    localparam jalr=4'b0010;
    localparam beq=4'b0011;
    localparam bne=4'b0100;
    localparam blt=4'b0101;
    localparam bge=4'b0110;
    localparam bltu=4'b0111;
    localparam bgeu=4'b1000;
    localparam auipc=4'b1001;
    localparam lui=4'b1010; 

    always_comb begin
        nextAddress = currentAddress + 4;
        rd = 32'b0;

        if (pc_or_alu) begin 
            case (opcode)
                jal:begin
                    nextAddress = currentAddress + immediate;
                    rd = currentAddress + 4;
                end
                jalr:begin
                    nextAddress = (rs1 + immediate) & ~32'b1;
                    rd = currentAddress + 4;
                end
                beq: begin
                    if (rs1 == rs2) nextAddress = currentAddress + immediate;
                    else            nextAddress = currentAddress + 4;
                    rd = 32'b0;
                end
                bne: begin
                    if (rs1 != rs2) nextAddress = currentAddress + immediate;
                    else            nextAddress = currentAddress + 4;
                    rd = 32'b0;
                end
                blt: begin
                    if ($signed(rs1) < $signed(rs2)) nextAddress = currentAddress + immediate;    
                    else                             nextAddress = currentAddress + 4;
                    rd = 32'b0;
                end
                bge: begin
                    if ($signed(rs1) >= $signed(rs2)) nextAddress = currentAddress + immediate;    
                    else                              nextAddress = currentAddress + 4;
                    rd = 32'b0;
                end
                bltu: begin
                    if (rs1 < rs2) nextAddress = currentAddress + immediate;    
                    else           nextAddress = currentAddress + 4;
                    rd = 32'b0;
                end
                bgeu: begin
                    if (rs1 >= rs2) nextAddress = currentAddress + immediate;    
                    else            nextAddress = currentAddress + 4;
                    rd = 32'b0;
                end
                auipc: begin
                    nextAddress = currentAddress + 4;
                    rd = currentAddress + immediate;
                end
                lui: begin 
                    nextAddress = currentAddress + 4;
                    rd = immediate;
                end
                default:begin 
                    nextAddress = currentAddress + 4;
                    rd = 32'b0;
                end
            endcase
        end
    end
endmodule
