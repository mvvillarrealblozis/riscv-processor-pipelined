`timescale 1ns/1ps
module instruction_decoder_tb;
    // Inputs 
    reg [31:0] instruction;

    // Ouputs
    wire [6:0] opcode;    
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [6:0] funct7;
    wire [31:0] imm_i;
    wire [31:0] imm_s;
    wire [31:0] imm_b;
    wire [31:0] imm_u;
    wire [31:0] imm_j;

    instruction_decoder instruction_decoder_instance (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7),
        .imm_i(imm_i),
        .imm_s(imm_s),
        .imm_b(imm_b),
        .imm_u(imm_u),
        .imm_j(imm_j)
    );

    initial begin
        $dumpfile("instruction_decoder.vcd");
        $dumpvars(0, instruction_decoder_tb);
        
        // Test 1: ADDI x1, x0, 5 -> 32'h00500093
        // I-type: opcode=0010011, rd=1, funct3=000, rs1=0, imm_i=5

        instruction = 32'h00500093;
        #1;

        if (opcode == 7'b0010011 && rd == 5'd1 && rs1 == 5'd0 && imm_i == 32'd5)
            $display("Test 1 PASSED");
        else begin
            $display("Test 1 FAILED");
            $display("  opcode: %b (expected 0010011)", opcode);
            $display("  rd: %d (expected 1)", rd);
            $display("  rs1: %d (expected 0)", rs1);
            $display("  imm_i: %d (expected 5)", imm_i);
        end

        $display("--------------------------------");
        // Test 2: ADDI x2, x0, 10 -> 32'h00A00113  
        // I-type: opcode=0010011, rd=2, funct3=000, rs1=0, imm_i=10

        instruction = 32'h00A00113;
        #1;

        if (opcode == 7'b0010011 && rd == 5'd2 && rs1 == 5'd0 && imm_i == 32'd10)
            $display("Test 2 PASSED");
        else begin
            $display("Test 2 FAILED");
            $display("  opcode: %b (expected 0010011)", opcode);
            $display("  rd: %d (expected 2)", rd);
            $display("  rs1: %d (expected 0)", rs1);
            $display("  imm_i: %d (expected 10)", imm_i);
        end 

        $display("--------------------------------");

        // Test 3: ADD x3, x1, x2 -> 32'h002081B3
        // R-type: opcode=0110011, rd=3, funct3=000, rs1=1, rs2=2, funct7=0000000
        
        instruction = 32'h002081B3;
        #1;

        if (opcode == 7'b0110011 && rd == 5'd3 && rs1 == 5'd1 && rs2 == 5'd2)
            $display("Test 3 PASSED");
        else begin
            $display("Test 3 FAILED");
            $display("  opcode: %b (expected 0110011)", opcode);
            $display("  rd: %d (expected 2)", rd);
            $display("  rs1: %d (expected 1)", rs1);
            $display("  rs2: %d (expected 2)", rs2);
        end 

        $display("--------------------------------");

        // Test 4: SUB x4, x1, x2 -> 32'h40208233
        // R-type: opcode=0110011, rd=4, funct3=000, rs1=1, rs2=2, funct7=0100000
        
        instruction = 32'h40208233;
        #1;

        if (opcode == 7'b0110011 && rd == 5'd4 && rs1 == 5'd1 && rs2 == 5'd2 && funct7 == 7'b0100000)
            $display("Test 4 PASSED");
        else begin
            $display("Test 4 FAILED");
            $display("  opcode: %b (expected 0110011)", opcode);
            $display("  rd: %d (expected 4)", rd);
            $display("  rs1: %d (expected 1)", rs1);
            $display("  rs2: %d (expected 2)", rs2);
            $display("  funct7: %b (expected 0100000)", funct7);
        end 

        $display("--------------------------------");

        // Test 5: AND x5, x1, x2 -> 32'h0020F2B3
        // R-type: opcode=0110011, rd=5, funct3=111, rs1=1, rs2=2, funct7=0000000

        instruction = 32'h0020F2B3;
        #1;

        if (opcode == 7'b0110011 && rd == 5'd5 && funct3 == 3'b111 && rs1 == 5'd1 && rs2 == 5'd2)
            $display("Test 5 PASSED");
        else begin
            $display("Test 5 FAILED");
            $display("  opcode: %b (expected 0110011)", opcode);
            $display("  rd: %d (expected 5)", rd);
            $display("  funct3: %b (expected 111)", funct3);
            $display("  rs1: %d (expected 1)", rs1);
            $display("  rs2: %d (expected 2)", rs2);
        end
        $display("--------------------------------");

        // Test 6: JAL x2, 8 Jump to 0x0C, x2 = 0x08 (PC+4) -> 32'h0000016f
        // J-type: opcode=1101111, rd=2, funct3=000, rs1=1, rs2=2, funct7=0100000
        
        instruction = 32'h0080016f;
        #1;

        if (opcode == 7'b1101111 && rd == 5'd2)
            $display("Test 6 PASSED");
        else begin
            $display("Test 6 FAILED");
            $display("  opcode: %b (expected 1101111)", opcode);
            $display("  rd: %d (expected 2)", rd);
        end 

    end

endmodule   