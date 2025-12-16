module register(
    input logic write_enable,
    input logic clk,
    input logic [31:0] wdata,

    input logic [4:0] rd,
    input logic [4:0] rs1,
    input logic [4:0] rs2,

    output logic [31:0] rdata1,
    output logic [31:0] rdata2
);

// 32 registers 
logic [31:0] registers [0:31];

// Reading data
assign rdata1 = (rs1==5'b0) ? 32'b0:registers[rs1]; 
assign rdata2 = (rs2==5'b0) ? 32'b0:registers[rs2];

// Writing data
always_ff @( posedge clk ) begin 
    if (write_enable && rd!=5'b0) begin
        registers[rd] <= wdata;
    end
end

endmodule

