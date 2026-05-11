module instruction_memory(
    input [31:0] address,       // Byte address from PC
    output [31:0] instruction   // 32-bit instruction at that address
);

    reg [31:0] memory [0:255];
    integer i;
    
    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000013;

            // --- Test 1: EX Hazard (Forward from EX/MEM) ---
            // ADDI x1, x0, 5  (0x00500093)
            // ADDI x2, x1, 10 (0x00a08113)
            memory[0] = 32'h00500093;   
            memory[1] = 32'h00a08113;   
            
            memory[2] = 32'h00000013;   // NOP Buffer
            memory[3] = 32'h00000013;   // NOP Buffer

            // --- Test 2: MEM Hazard (Forward from MEM/WB) ---
            // ADDI x3, x0, 5  (0x00500193)
            // NOP             (0x00000013)
            // ADDI x4, x3, 10 (0x00a18213)
            memory[4] = 32'h00500193;   
            memory[5] = 32'h00000013;   
            memory[6] = 32'h00a18213;   

            memory[7] = 32'h00000013;   // NOP Buffer
            memory[8] = 32'h00000013;   // NOP Buffer

            // --- Test 3: Load-Use Hazard (Requires 1-Cycle Stall) ---
            // LW   x5, 0(x0)  (0x00002283)
            // ADDI x6, x5, 10 (0x00a28313)
            memory[9]  = 32'h00002283;  
            memory[10] = 32'h00a28313;  

            memory[11] = 32'h00000013;  // NOP Buffer
            memory[12] = 32'h00000013;  // NOP Buffer

            // --- Test 4: Complex Dependencies ---
            // ADDI x7, x0, 5   (0x00500093)
            // ADDI x8, x7, 10  (0x00a08113)
            // ADD  x9, x8, x7  (0x001101b3)
            memory[13] = 32'h00500393;  
            memory[14] = 32'h00a38413;  
            memory[15] = 32'h007404b3;  
    end

    assign instruction = memory[address >> 2];

endmodule