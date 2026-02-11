module instruction_memory(
    input [31:0] address,       // Byte address from PC
    output [31:0] instruction   // 32-bit instruction at that address
);

    reg [31:0] memory [0:255];
    integer i;
    
    initial begin
        memory[0] = 32'h00a00093;   // ADDI x1, x0, 10  x1 = 10
        memory[1] = 32'h01400113;   // ADDI x2, x0, 20  x2 = 20
        memory[2] = 32'h00102023;   // SW x1, 0(x0) Store x1 (10) to memory address 0
        memory[3] = 32'h00202223;   // SW x2, 4(x0) Store x2 (20) to memory address 4
        memory[4] = 32'h00002183;   // LW x3, 0(x0) Load from address 0 into x3 (should get 10)
        memory[5] = 32'h00402203;   // LW x4, 4(x0) Load from address 4 into x4 (should get 20)
        memory[6] = 32'h004182b3;   // ADD x5, x3, x4  x5 = x3 + x4 = 10 + 20 = 30

        for (i = 7; i < 256; i = i + 1)
            memory[i] = 32'h00000000;
    end

    assign instruction = memory[address >> 2];

endmodule