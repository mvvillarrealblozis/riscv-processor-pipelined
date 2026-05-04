module instruction_memory(
    input [31:0] address,       // Byte address from PC
    output [31:0] instruction   // 32-bit instruction at that address
);

    reg [31:0] memory [0:255];
    integer i;
    
    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000013;

        memory[0] = 32'h00002083;   // LW   x1, 0(x0)
        memory[1] = 32'h00a08113;   // ADDI x2, x1, 10 

        // memory[5] = 32'h00500093;
        // memory[6] = 32'h00000013;
        // memory[7] = 32'h00a08113;


    end

    assign instruction = memory[address >> 2];

endmodule