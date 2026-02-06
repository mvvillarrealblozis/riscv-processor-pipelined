module instruction_memory(
    input [31:0] address,       // Byte address from PC
    output [31:0] instruction   // 32-bit instruction at that address
);

    reg [31:0] memory [0:255];
    integer i;
    
    initial begin
        memory[0] = 32'h00500093;
        memory[1] = 32'h00A00113;
        memory[2] = 32'h002081B3;
        memory[3] = 32'h40208233;
        memory[4] = 32'h0020F2B3;

        for (i = 5; i < 256; i = i + 1)
            memory[i] = 32'h00000000;
    end

    assign instruction = memory[address >> 2];

endmodule