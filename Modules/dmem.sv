module dmem(
    input logic clk,
    input logic write_enable,
    input logic [3:0] byte_enable,
    input logic [31:0] address,
    input logic [31:0] wdata,
    output logic [31:0] rdata
);

    logic [31:0] mem_array [0:16383];

    assign rdata = mem_array[address[15:2]];

    always_ff @( posedge clk ) begin 
        if (write_enable) begin
            if (byte_enable[0]) mem_array[address[15:2]][7:0]   <= wdata[7:0];
            if (byte_enable[1]) mem_array[address[15:2]][15:8]  <= wdata[15:8];
            if (byte_enable[2]) mem_array[address[15:2]][23:16] <= wdata[23:16];
            if (byte_enable[3]) mem_array[address[15:2]][31:24] <= wdata[31:24];
        end
    end

endmodule
