`timescale 1ns/1ps

module ex_mem_tb;
    // regs
    reg clk;
    reg reset;
    reg enable;

    reg [31:0] alu_result;
    reg [31:0] read_data2;
    reg [1:0] writeback_sel; // 00 ALU ; 01 Mem ; 10 PC+4

    // Register Address
    reg [4:0] rd;

    // Control Signals
    reg mem_write;
    reg mem_read;
    reg mem_to_reg;
    reg reg_write;

    // Jumps 
    reg [31:0] pc_plus_4;

    // Outputs
    wire [31:0] ex_alu_result;
    wire [31:0] ex_read_data2;
    wire [1:0] ex_writeback_sel;

    wire [4:0] ex_rd;

    wire ex_mem_write;
    wire ex_mem_read;
    wire ex_mem_to_reg;
    wire ex_reg_write;

    wire [31:0] ex_pc_plus_4;

    ex_mem ex_mem_instance (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .alu_result(alu_result),
        .read_data2(read_data2),
        .writeback_sel(writeback_sel),
        .rd(rd),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .pc_plus_4(pc_plus_4),
        .ex_alu_result(ex_alu_result),
        .ex_read_data2(ex_read_data2),
        .ex_writeback_sel(ex_writeback_sel),
        .ex_rd(ex_rd),
        .ex_mem_write(ex_mem_write),
        .ex_mem_read(ex_mem_read),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_reg_write(ex_reg_write),
        .ex_pc_plus_4(ex_pc_plus_4)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("ex_mem.vcd");
        $dumpvars(0, ex_mem_tb);

        // Test 1: Reset 
        reset = 1;
        enable = 0;

        @(posedge clk);
        #1; 

        if (ex_alu_result == 0 && ex_read_data2 == 0 &&
            ex_writeback_sel == 0 && ex_rd == 0 &&
            ex_mem_write == 0 && ex_mem_read == 0 &&
            ex_mem_to_reg == 0 && ex_reg_write == 0 && 
            ex_pc_plus_4 == 0
        )
            $display("Reset PASSED");
        else
            $display ("Reset FAILED (use waveform to debug)");
        $display("--------------------------------");

        // Test 2: Enable 
        reset = 0;
        enable = 1; 

        alu_result = 32'hAAAA_AAAA;
        read_data2 = 32'hBBBB_BBBB;

        writeback_sel = 2'b10;

        rd = 5'b0010;
        
        mem_write = 1;
        mem_read = 0;
        mem_to_reg = 0;
        reg_write = 0;

        pc_plus_4 = 32'h0000_0008;

        @(posedge clk);
        #1;

        if (ex_alu_result == 32'hAAAA_AAAA && 
            ex_read_data2 == 32'hBBBB_BBBB &&
            ex_writeback_sel == 2'b10 && ex_rd == 5'b0010 &&
            ex_mem_write == 1 && ex_mem_read == 0 &&
            ex_mem_to_reg == 0 && ex_reg_write == 0 && 
            ex_pc_plus_4 == 32'h0000_0008
        )
            $display("Enable PASSED");
        else
            $display ("Enable FAILED (use waveform to debug)");
        $display("--------------------------------");

        // Test 3: Stall
        enable = 0;

        alu_result = 32'h1111_1111;
        read_data2 = 32'h2222_2222;

        writeback_sel = 2'b11;

        rd = 5'b11111;
        
        mem_write = 0;
        mem_read = 0;
        mem_to_reg = 0;
        reg_write = 0;

        pc_plus_4 = 32'hDEAD_BEEF;

        @(posedge clk);
        #1;
        
        if (ex_alu_result == 32'hAAAA_AAAA && 
            ex_read_data2 == 32'hBBBB_BBBB &&
            ex_writeback_sel == 2'b10 && ex_rd == 5'b0010 &&
            ex_mem_write == 1 && ex_mem_read == 0 &&
            ex_mem_to_reg == 0 && ex_reg_write == 0 && 
            ex_pc_plus_4 == 32'h0000_0008
        )
            $display("Stall PASSED");
        else
            $display ("Stall FAILED (use waveform to debug)");
        $display("--------------------------------");
        $finish;
    end 
endmodule