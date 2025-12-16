module programCounter(
    input logic clk,
    input logic reset,
    input logic [31:0] nextAddress,

    output logic [31:0] currentAddress
);

    always_ff @( posedge clk, posedge reset ) begin 
        if (reset) begin
            currentAddress <= 32'b0;
        end else begin
            currentAddress <= nextAddress; 
        end
    end

endmodule

