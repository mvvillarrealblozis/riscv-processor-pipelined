`timescale 1ns/1ps

module id_ex_tb;
    reg clk;
    reg reset;
    reg enable;

    // Data values
    reg [31:0] rdata1;            // rs1 | alu_input A 
    reg [31:0] rdata2;            // rs2 | alu_input B
    reg [31:0] pc;
    reg [31:0] imm;

    // Register Addresses
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;
    reg [2:0] funct3; 

    // Control Signals
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

    // Output Signals
    // Register Values
    wire [31:0] id_rdata1;    // rs1 | alu_input A 
    wire [31:0] id_rdata2;    // rs2 | alu_input B
    wire [31:0] id_pc;
    wire [31:0] id_imm;

    // Register Addresses
    wire [4:0] id_rs1;
    wire [4:0] id_rs2;
    wire [4:0] id_rd;
    wire [2:0] id_funct3;

    // Control Signals
    wire [3:0] id_alu_op;
    wire id_alu_src;
    wire id_reg_write;
    wire id_mem_write;
    wire id_mem_read;
    wire id_mem_to_reg;
    wire id_branch;
    wire id_jump;
    wire id_jump_jal;
    wire id_jump_jalr;
    wire id_pc_to_alu;

    id_ex id_ex_instance (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .pc(pc),
        .imm(imm),
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
        .id_rdata1(id_rdata1),
        .id_rdata2(id_rdata2),
        .id_pc(id_pc),
        .id_imm(id_imm),
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .id_rd(id_rd),
        .id_funct3(id_funct3),
        .id_alu_op(id_alu_op),
        .id_alu_src(id_alu_src),
        .id_reg_write(id_reg_write),
        .id_mem_write(id_mem_write),
        .id_mem_read(id_mem_read),
        .id_mem_to_reg(id_mem_to_reg),
        .id_branch(id_branch),
        .id_jump(id_jump),
        .id_jump_jal(id_jump_jal),
        .id_jump_jalr(id_jump_jalr),
        .id_pc_to_alu(id_pc_to_alu)
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
            id_rdata1 == 0 && id_rdata2 == 0 &&
            id_pc == 0 && id_imm == 0 &&
            id_rs1 == 0 && id_rs2 == 0 && id_rd == 0 &&
            id_funct3 == 0 &&
            id_alu_op == 0 &&
            id_alu_src == 0 &&
            id_reg_write == 0 &&
            id_mem_write == 0 &&
            id_mem_read == 0 &&
            id_mem_to_reg == 0 &&
            id_branch == 0 &&
            id_jump == 0 &&
            id_jump_jal == 0 &&
            id_jump_jalr == 0 &&
            id_pc_to_alu == 0
        )
            $display("Reset PASSED");
        else
            $display("Reset FAILED (use waveform to debug)");
        $display("--------------------------------");

        // Test 2: Enable (load values)
        reset = 0;
        enable = 1;

        rdata1 = 32'hAAAA_AAAA;
        rdata2 = 32'hBBBB_BBBB;
        pc     = 32'h00000010;
        imm    = 32'h12345678;

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
            id_rdata1 == 32'hAAAA_AAAA &&
            id_rdata2 == 32'hBBBB_BBBB &&
            id_pc == 32'h00000010 &&
            id_imm == 32'h12345678 &&
            id_rs1 == 5'd1 &&
            id_rs2 == 5'd2 &&
            id_rd  == 5'd3 &&
            id_funct3 == 3'b101 &&
            id_alu_op == 4'b1100 &&
            id_alu_src == 1 &&
            id_reg_write == 1 &&
            id_mem_write == 1 &&
            id_mem_read == 0 &&
            id_mem_to_reg == 1 &&
            id_branch == 0 &&
            id_jump == 1 &&
            id_jump_jal == 0 &&
            id_jump_jalr == 1 &&
            id_pc_to_alu == 1
        )
            $display("Enable PASSED");
        else
            $display("Enable FAILED");
        $display("--------------------------------");

        // Test 3: Stall (hold values)
        enable = 0;

        // Change inputs (these should NOT propagate)
        rdata1 = 32'h11111111;
        rdata2 = 32'h22222222;
        pc     = 32'h00000020;
        imm    = 32'hDEADBEEF;

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
            id_rdata1 == 32'hAAAA_AAAA &&
            id_rdata2 == 32'hBBBB_BBBB &&
            id_pc == 32'h00000010 &&
            id_imm == 32'h12345678 &&
            id_rs1 == 5'd1 &&
            id_rs2 == 5'd2 &&
            id_rd  == 5'd3 &&
            id_funct3 == 3'b101 &&
            id_alu_op == 4'b1100 &&
            id_alu_src == 1 &&
            id_reg_write == 1 &&
            id_mem_write == 1 &&
            id_mem_read == 0 &&
            id_mem_to_reg == 1 &&
            id_branch == 0 &&
            id_jump == 1 &&
            id_jump_jal == 0 &&
            id_jump_jalr == 1 &&
            id_pc_to_alu == 1
        )
            $display("Stall PASSED");
        else
            $display("Stall FAILED");
        $display("--------------------------------");

        $finish;
    end
endmodule