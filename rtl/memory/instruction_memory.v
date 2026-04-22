module instruction_memory(
    input [31:0] address,       // Byte address from PC
    output [31:0] instruction   // 32-bit instruction at that address
);

    reg [31:0] memory [0:255];
    integer i;
    
    initial begin
        memory[0] = 32'h00500093;   // ADDI x1, x0, 5
        memory[1] = 32'h00000013;   // NOP
        memory[2] = 32'h00000013;   // NOP
        memory[3] = 32'h00000013;   // NOP
        memory[4] = 32'h00000013;   // NOP
        memory[5] = 32'h00000013;
        memory[6] = 32'h00a08113;   //ADDI x2, x1, 10

        for (i = 7; i < 256; i = i + 1)
            memory[i] = 32'h00000000;
    end

    assign instruction = memory[address >> 2];

endmodule