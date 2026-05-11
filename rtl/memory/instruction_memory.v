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

            // --- Test 2: MEM Hazard (Forward from MEM/WB) ---
            // ADDI x3, x0, 5  (0x00500193)
            // NOP             (0x00000013)
            // ADDI x4, x3, 10 (0x00a18213)
            memory[4] = 32'h00500193;   
            memory[5] = 32'h00000013;   
            memory[6] = 32'h00a18213;   

            // --- Test 3: Load-Use Hazard (Requires 1-Cycle Stall) ---
            // LW   x5, 0(x0)  (0x00002283)
            // ADDI x6, x5, 10 (0x00a28313)
            memory[9]  = 32'h00002283;  
            memory[10] = 32'h00a28313;  

            // --- Test 4: Complex Dependencies ---
            // ADDI x7, x0, 5   (0x00500093)
            // ADDI x8, x7, 10  (0x00a08113)
            // ADD  x9, x8, x7  (0x001101b3)
            memory[13] = 32'h00500393;  
            memory[14] = 32'h00a38413;  
            memory[15] = 32'h007404b3;  

            // Test 5: Branch Taken
            memory[17] = 32'h00500513;  // ADDI x10, x0, 5
            memory[18] = 32'h00500593;  // ADDI x11, x0, 5 
            memory[19] = 32'h00b50663;  // BEQ x10, x11, 12 (ONLY change this line!)
            memory[20] = 32'h00100613;  // ADDI x12, x0, 1
            memory[21] = 32'h00200693;  // ADDI x13, x0, 2
            memory[22] = 32'h00a00713;  // ADDI x14, x0, 10

            // Test 6: Branch Not Taken  
            memory[23] = 32'h00500793;  // ADDI x15, x0, 5
            memory[24] = 32'h00a00813;  // ADDI x16, x0, 10
            memory[25] = 32'h01088463;  // BEQ x17, x16, 8 (keep as is!)
            memory[26] = 32'h00100893;  // ADDI x17, x0, 1
            memory[27] = 32'h00200913;  // ADDI x18, x0, 2

            // Test 7: JAL (unconditional jump, save return address)
            memory[28] = 32'h00c00cef;  // JAL x25, 12  (jump forward 12 bytes, save PC+4 to x1)
            memory[29] = 32'h00200993;  // ADDI x19, x0, 2  ← Should NOT execute
            memory[30] = 32'h00300a13;  // ADDI x20, x0, 3  ← Should NOT execute
            memory[31] = 32'h00a00a93;  // ADDI x21, x0, 10 ← Target

            // Test 8: JALR (jump to register + offset)
            memory[32] = 32'h01000b13;  // ADDI x22, x0, 16
            memory[33] = 32'h07cb0ce7;  // JALR x1, 124(x22) (jump to 16+124=140)
            memory[34] = 32'h00100b93;  // ADDI x23, x0, 1   ← Should NOT execute
            memory[35] = 32'h00a00c13;  // ADDI x24, x0, 10  ← Target (at address 140)
    end
    assign instruction = memory[address >> 2];

endmodule