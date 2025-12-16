module imem(
    input logic [31:0]address,
    output logic [31:0]data_at_memory_address
);
    // 2^14 words of memory
    logic [31:0] mem_array [0:16383];

    initial begin
        $readmemh("program.hex", mem_array);
    end

    assign data_at_memory_address= mem_array[address[15:2]];




endmodule

