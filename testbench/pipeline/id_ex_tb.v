`timescale 1ns/1ps
module id_ex_tb;
    reg clk;
    reg reset;
    reg enable;

    reg [31:0] read_data1;
    reg [31:0] read_data2;
    reg [31:0] pc;
    reg [31:0] imm_val;

    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;
    reg [2:0] funct3;

    reg [3:0] alu_op;
    reg alu_src;
    reg reg_write;
    reg mem_write;
    reg mem_read;
    reg mem_to_reg;
    reg branch;
    reg jump;
    reg jump_jal;
    reg jump_jalr;
    reg pc_to_alu;

    wire [31:0] ex_read_data1;
    wire [31:0] ex_read_data2;
    wire [31:0] ex_pc;
    wire [31:0] ex_imm_val;

    wire [4:0] ex_rs1;
    wire [4:0] ex_rs2;
    wire [4:0] ex_rd;
    wire [2:0] ex_funct3;

    wire [3:0] ex_alu_op;
    wire ex_alu_src;
    wire ex_reg_write;
    wire ex_mem_write;
    wire ex_mem_read;
    wire ex_mem_to_reg;
    wire ex_branch;
    wire ex_jump;
    wire ex_jump_jal;
    wire ex_jump_jalr;
    wire ex_pc_to_alu;

    id_ex id_ex_instance (
        .clk(clk),
        .reset(reset),
        .enable(enable),

        .pc(pc),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .imm_val(imm_val),

        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .funct3(funct3),

        .alu_op(alu_op),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump),
        .jump_jal(jump_jal),
        .jump_jalr(jump_jalr),
        .pc_to_alu(pc_to_alu),

        .ex_pc(ex_pc),
        .ex_read_data1(ex_read_data1),
        .ex_read_data2(ex_read_data2),
        .ex_imm_val(ex_imm_val),

        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .ex_rd(ex_rd),
        .ex_funct3(ex_funct3),

        .ex_alu_op(ex_alu_op),
        .ex_alu_src(ex_alu_src),
        .ex_reg_write(ex_reg_write),
        .ex_mem_write(ex_mem_write),
        .ex_mem_read(ex_mem_read),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_branch(ex_branch),
        .ex_jump(ex_jump),
        .ex_jump_jal(ex_jump_jal),
        .ex_jump_jalr(ex_jump_jalr),
        .ex_pc_to_alu(ex_pc_to_alu)
    );

    initial begin 
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("id_ex.vcd");
        $dumpvars(0, id_ex_tb);

        // Test 1: Reset
        reset = 1;
        enable = 0;

        @(posedge clk);
        #1;

        if (
            ex_read_data1 == 0 && ex_read_data2 == 0 &&
            ex_pc == 0 && ex_imm_val == 0 &&
            ex_rs1 == 0 && ex_rs2 == 0 && ex_rd == 0 &&
            ex_funct3 == 0 &&
            ex_alu_op == 0 &&
            ex_alu_src == 0 &&
            ex_reg_write == 0 &&
            ex_mem_write == 0 &&
            ex_mem_read == 0 &&
            ex_mem_to_reg == 0 &&
            ex_branch == 0 &&
            ex_jump == 0 &&
            ex_jump_jal == 0 &&
            ex_jump_jalr == 0 &&
            ex_pc_to_alu == 0
        )
            $display("Reset PASSED");
        else
            $display("Reset FAILED (use waveform to debug)");
        $display("--------------------------------");

        // Test 2: Enable (load values)
        reset = 0;
        enable = 1;

        read_data1 = 32'hAAAA_AAAA;
        read_data2 = 32'hBBBB_BBBB;
        pc     = 32'h00000010;
        imm_val    = 32'h12345678;

        rs1 = 5'd1;
        rs2 = 5'd2;
        rd  = 5'd3;
        funct3 = 3'b101;

        alu_op = 4'b1100;
        alu_src = 1;
        reg_write = 1;
        mem_write = 1;
        mem_read  = 0;
        mem_to_reg = 1;
        branch = 0;
        jump = 1;
        jump_jal = 0;
        jump_jalr = 1;
        pc_to_alu = 1;

        @(posedge clk);
        #1;

        if (
            ex_read_data1 == 32'hAAAA_AAAA &&
            ex_read_data2 == 32'hBBBB_BBBB &&
            ex_pc == 32'h00000010 &&
            ex_imm_val == 32'h12345678 &&
            ex_rs1 == 5'd1 &&
            ex_rs2 == 5'd2 &&
            ex_rd  == 5'd3 &&
            ex_funct3 == 3'b101 &&
            ex_alu_op == 4'b1100 &&
            ex_alu_src == 1 &&
            ex_reg_write == 1 &&
            ex_mem_write == 1 &&
            ex_mem_read == 0 &&
            ex_mem_to_reg == 1 &&
            ex_branch == 0 &&
            ex_jump == 1 &&
            ex_jump_jal == 0 &&
            ex_jump_jalr == 1 &&
            ex_pc_to_alu == 1
        )
            $display("Enable PASSED");
        else
            $display("Enable FAILED");
        $display("--------------------------------");

        // Test 3: Stall (hold values)
        enable = 0;

        // Change inputs (these should NOT propagate)
        read_data1 = 32'h11111111;
        read_data2 = 32'h22222222;
        pc     = 32'h00000020;
        imm_val    = 32'hDEADBEEF;

        rs1 = 5'd10;
        rs2 = 5'd11;
        rd  = 5'd12;
        funct3 = 3'b010;

        alu_op = 4'b0011;
        alu_src = 0;
        reg_write = 0;
        mem_write = 0;
        mem_read  = 1;
        mem_to_reg = 0;
        branch = 1;
        jump = 0;
        jump_jal = 1;
        jump_jalr = 0;
        pc_to_alu = 0;

        @(posedge clk);
        #1;

        // Should still hold previous values
        if (
            ex_read_data1 == 32'hAAAA_AAAA &&
            ex_read_data2 == 32'hBBBB_BBBB &&
            ex_pc == 32'h00000010 &&
            ex_imm_val == 32'h12345678 &&
            ex_rs1 == 5'd1 &&
            ex_rs2 == 5'd2 &&
            ex_rd  == 5'd3 &&
            ex_funct3 == 3'b101 &&
            ex_alu_op == 4'b1100 &&
            ex_alu_src == 1 &&
            ex_reg_write == 1 &&
            ex_mem_write == 1 &&
            ex_mem_read == 0 &&
            ex_mem_to_reg == 1 &&
            ex_branch == 0 &&
            ex_jump == 1 &&
            ex_jump_jal == 0 &&
            ex_jump_jalr == 1 &&
            ex_pc_to_alu == 1
        )
            $display("Stall PASSED");
        else
            $display("Stall FAILED");
        $display("--------------------------------");

        $finish;
    end
endmodule