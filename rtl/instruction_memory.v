module instruction_memory(
    input [31:0] address,       // Byte address from PC
    output [31:0] instruction   // 32-bit instruction at that address
);

    reg [31:0] memory [0:255];
    integer i;
    
    initial begin
        memory[0] = 32'h00500093;   // ADDI x1, x0, 5 | x1 = 5
        memory[1] = 32'h00a00113;   // ADDI x2, x0, 10 | x2 = 10
        memory[2] = 32'h00208463;   // BEQ x1, x2, 8 | 5 == 10? (F)
        memory[3] = 32'h00209463;   // BNE x1, x2, 8 | 5 != 10? (T)
        memory[4] = 32'h00100193;   // ADDI x3, x0, 1 | x3 = 1 (SHOULD BE SKIPPED)
        memory[5] = 32'h00114463;   // BLT x2, x1 8 | 10 < 5? (F)
        memory[6] = 32'h00115463;   // BGE x2, x1, 8 | 10 > 5? (T) actually just BLT x1, x2
        memory[7] = 32'h00200193;   // ADDI x3, x0, 2 (SHOULD BE SKIPPED)
        memory[8] = 32'h002082b3;   // ADD x5, x1, x2 | 5 + 10 = 15

        for (i = 9; i < 256; i = i + 1)
            memory[i] = 32'h00000000;
    end

    assign instruction = memory[address >> 2];

endmodule