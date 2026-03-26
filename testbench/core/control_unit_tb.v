`timescale 1ns/1ps

module control_unit_tb;
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;

    wire [3:0] alu_op;
    wire alu_src;
    wire reg_write;
    wire mem_write;
    wire mem_read;
    wire mem_to_reg;
    wire branch;
    wire jump;
    wire pc_to_alu;

    control_unit control_unit_instance (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_op(alu_op),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump),
        .pc_to_alu(pc_to_alu)
    );

    initial begin
        $dumpfile("control_unit_tb.vcd");
        $dumpvars(0, control_unit_tb);

        // Test 1: ADD
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #1;

        if (alu_op == 4'b0000 && alu_src == 0 && reg_write == 1 && mem_write == 0 && mem_read == 0 && mem_to_reg == 0 && branch == 0 && jump == 0)
            $display("ADD Test Passed");
        else
            $display("ADD Test Failed: alu_op=%b | alu_src=%b | reg_write=%b | mem_write=%b | mem_read=%b | mem_to_reg=%b | branch=%b | jump=%b", alu_op, alu_src, reg_write, mem_write, mem_read, mem_to_reg, branch, jump);

        $display("--------------------------------");

        // Test 2: SUB
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0100000;
        #1;

        if (alu_op == 4'b0001 && alu_src == 0 && reg_write == 1 && mem_write == 0 && mem_read == 0 && mem_to_reg == 0 && branch == 0 && jump == 0)
            $display("SUB Test Passed");
        else
            $display("SUB Test Failed: alu_op=%b | alu_src=%b | reg_write=%b | mem_write=%b | mem_read=%b | mem_to_reg=%b | branch=%b | jump=%b", alu_op, alu_src, reg_write, mem_write, mem_read, mem_to_reg, branch, jump);

        $display("--------------------------------");

        // Test 3: AND
        opcode = 7'b0110011;
        funct3 = 3'b111;
        funct7 = 7'b0000000;
        #1;

        if (alu_op == 4'b0010 && alu_src == 0 && reg_write == 1 && mem_write == 0 && mem_read == 0 && mem_to_reg == 0 && branch == 0 && jump == 0)
            $display("AND Test Passed");
        else
            $display("AND Test Failed: alu_op=%b | alu_src=%b | reg_write=%b | mem_write=%b | mem_read=%b | mem_to_reg=%b | branch=%b | jump=%b", alu_op, alu_src, reg_write, mem_write, mem_read, mem_to_reg, branch, jump);

        $display("--------------------------------");

        // Test 4: OR
        opcode = 7'b0110011;
        funct3 = 3'b110;
        funct7 = 7'b0000000;
        #1;

        if (alu_op == 4'b0011 && alu_src == 0 && reg_write == 1 && mem_write == 0 && mem_read == 0 && mem_to_reg == 0 && branch == 0 && jump == 0)
            $display("OR Test Passed");
        else
            $display("OR Test Failed: alu_op=%b | alu_src=%b | reg_write=%b | mem_write=%b | mem_read=%b | mem_to_reg=%b | branch=%b | jump=%b", alu_op, alu_src, reg_write, mem_write, mem_read, mem_to_reg, branch, jump);

        $display("--------------------------------");

        // Test 5: XOR
        opcode = 7'b0110011;
        funct3 = 3'b100;
        funct7 = 7'b0000000;
        #1;

        if (alu_op == 4'b0100 && alu_src == 0 && reg_write == 1 && mem_write == 0 && mem_read == 0 && mem_to_reg == 0 && branch == 0 && jump == 0)
            $display("XOR Test Passed");
        else
            $display("XOR Test Failed: alu_op=%b | alu_src=%b | reg_write=%b | mem_write=%b | mem_read=%b | mem_to_reg=%b | branch=%b | jump=%b", alu_op, alu_src, reg_write, mem_write, mem_read, mem_to_reg, branch, jump);

        $display("--------------------------------");

        // Test 6: ADDI
        opcode = 7'b0010011;
        funct3 = 3'b000;
        #1;

        if (alu_op == 4'b0000 && alu_src == 1 && reg_write == 1 && mem_write == 0 && mem_read == 0 && mem_to_reg == 0 && branch == 0 && jump == 0)
            $display("ADDI Test Passed");
        else
            $display("ADDI Test Failed: alu_op=%b | alu_src=%b | reg_write=%b | mem_write=%b | mem_read=%b | mem_to_reg=%b | branch=%b | jump=%b", alu_op, alu_src, reg_write, mem_write, mem_read, mem_to_reg, branch, jump);

        $display("--------------------------------");

        // Test 7: ADD1 2
        opcode = 7'b0010011;
        funct3 = 3'b000;
        #1;

        if (alu_op == 4'b0000 && alu_src == 1 && reg_write == 1 && mem_write == 0 && mem_read == 0 && mem_to_reg == 0 && branch == 0 && jump == 0)
            $display("ADDI Test Passed");
        else
            $display("ADDI Test Failed: alu_op=%b | alu_src=%b | reg_write=%b | mem_write=%b | mem_read=%b | mem_to_reg=%b | branch=%b | jump=%b", alu_op, alu_src, reg_write, mem_write, mem_read, mem_to_reg, branch, jump);

        $display("--------------------------------");

        // Test 8: ANDI
        opcode = 7'b0010011;
        funct3 = 3'b111;
        #1;

        if (alu_op == 4'b0010 && alu_src == 1 && reg_write == 1 && mem_write == 0 && mem_read == 0 && mem_to_reg == 0 && branch == 0 && jump == 0)
            $display("ANDI Test Passed");
        else
            $display("ANDI Test Failed: alu_op=%b | alu_src=%b | reg_write=%b | mem_write=%b | mem_read=%b | mem_to_reg=%b | branch=%b | jump=%b", alu_op, alu_src, reg_write, mem_write, mem_read, mem_to_reg, branch, jump);

        $display("--------------------------------");

        // Test 8: ORI
        opcode = 7'b0010011;
        funct3 = 3'b110;
        #1;

        if (alu_op == 4'b0011 && alu_src == 1 && reg_write == 1 && mem_write == 0 && mem_read == 0 && mem_to_reg == 0 && branch == 0 && jump == 0)
            $display("ORI Test Passed");
        else
            $display("ORI Test Failed: alu_op=%b | alu_src=%b | reg_write=%b | mem_write=%b | mem_read=%b | mem_to_reg=%b | branch=%b | jump=%b", alu_op, alu_src, reg_write, mem_write, mem_read, mem_to_reg, branch, jump);

        $display("--------------------------------");

        // Test 8: XORI
        opcode = 7'b0010011;
        funct3 = 3'b100;
        #1;

        if (alu_op == 4'b0100 && alu_src == 1 && reg_write == 1 && mem_write == 0 && mem_read == 0 && mem_to_reg == 0 && branch == 0 && jump == 0)
            $display("XORI Test Passed");
        else
            $display("XORI Test Failed: alu_op=%b | alu_src=%b | reg_write=%b | mem_write=%b | mem_read=%b | mem_to_reg=%b | branch=%b | jump=%b", alu_op, alu_src, reg_write, mem_write, mem_read, mem_to_reg, branch, jump);

        $display("--------------------------------");

        // Test 9: JAL
        opcode = 7'b1101111;
        funct3 = 3'b000;
        #1;

        if (alu_op == 4'b0000 && alu_src == 1 && reg_write == 1 && mem_write == 0 && mem_read == 0 && mem_to_reg == 0 && branch == 0 && jump == 1 && pc_to_alu == 1)
            $display("JAL Test Passed");
        else
            $display("JAL Test Failed: alu_op=%b | alu_src=%b | reg_write=%b | mem_write=%b | mem_read=%b | mem_to_reg=%b | branch=%b | jump=%b", alu_op, alu_src, reg_write, mem_write, mem_read, mem_to_reg, branch, jump);

        $display("--------------------------------");

        // Test 10: JALR
        opcode = 7'b1100111;
        funct3 = 3'b000;
        #1;

        if (alu_op == 4'b0000 && alu_src == 1 && reg_write == 1 && mem_write == 0 && mem_read == 0 && mem_to_reg == 0 && branch == 0 && jump == 1 && pc_to_alu == 0)
            $display("JALR Test Passed");
        else
            $display("JALR Test Failed: alu_op=%b | alu_src=%b | reg_write=%b | mem_write=%b | mem_read=%b | mem_to_reg=%b | branch=%b | jump=%b", alu_op, alu_src, reg_write, mem_write, mem_read, mem_to_reg, branch, jump);

    end
endmodule