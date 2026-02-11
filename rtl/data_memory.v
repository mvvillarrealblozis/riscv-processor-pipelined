module data_memory(
    input clk,                  // Clock Signal
    input [31:0] address,       // 32 bit address from ALU
    input [31:0] write_data,    // 32 bit data to write from register
    input mem_write,            // 1 write 0 don't write
    input mem_read,             // 1 read 0 don't read

    output reg [31:0] read_data
);
    reg [31:0] memory [0:255];

    always @(posedge clk) begin
        if (mem_write) begin
            memory[address >> 2] = write_data;
        end
    end

    always @(*) begin
        if (mem_read) begin
            read_data = memory[address >> 2];
        end else begin
            read_data = 32'h0;
        end
    end
endmodule