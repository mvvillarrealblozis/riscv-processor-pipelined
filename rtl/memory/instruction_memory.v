module instruction_memory(
    input [31:0] address,       // Byte address from PC
    output [31:0] instruction   // 32-bit instruction at that address
);

    reg [31:0] memory [0:255];
    integer i;
    
    initial begin
        memory[0] = 32'h00500093;   // 0x00: ADDI x1, x0, 5
        memory[1] = 32'h00c000ef;   // 0x04: JAL x1, 12          → 0x10, x1=0x08
        memory[2] = 32'h06300193;   // 0x08: ADDI x3, x0, 99     (target for JALR)
        memory[3] = 32'h00c0006f;   // 0x0C: JAL x0, 12          → 0x18 (skip ahead)
        
        memory[4] = 32'h00008067;   // 0x10: JALR x0, 0(x1)      → 0x08
        // After JALR: at 0x08, x3=99, then 0x0C jumps to 0x18
        
        memory[5] = 32'h00000013;   // 0x14: NOP
        memory[6] = 32'h00900093;   // 0x18: ADDI x1, x0, 9
        memory[7] = 32'h00008167;   // 0x1C: JALR x2, 0(x1)      → 8, x2=0x20
        // After this JALR: at 0x08 again, then 0x0C jumps to 0x18, then 0x1C jumps to 0x08... LOOP!
        
        memory[8] = 32'h0000006f;   // 0x20: JAL x0, 0           HALT
        
        for (i = 9; i < 256; i = i + 1)
            memory[i] = 32'h00000000;
    end

    assign instruction = memory[address >> 2];

endmodule