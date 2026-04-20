`timescale 1ns/1ps

module ex_mem_tb;
    reg clk;
    reg reset;
    reg enable;

    reg [31:0] alu_result;
    reg [31:0] read_data2;

    reg [4:0] rd;

    reg mem_write;
    reg mem_read;
    reg mem_to_reg;
    reg reg_write;

    reg [31:0] pc_plus_4;

    wire [31:0] mem_alu_result;
    wire [31:0] mem_read_data2;

    wire [4:0] mem_rd;

    wire mem_mem_write;
    wire mem_mem_read;
    wire mem_mem_to_reg;
    wire mem_reg_write;

    wire [31:0] mem_pc_plus_4;

    ex_mem ex_mem_instance (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .alu_result(alu_result),
        .read_data2(read_data2),
        .rd(rd),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .pc_plus_4(pc_plus_4),

        .mem_alu_result(mem_alu_result),
        .mem_read_data2(mem_read_data2),
        .mem_rd(mem_rd),
        .mem_mem_write(mem_mem_write),
        .mem_mem_read(mem_mem_read),
        .mem_mem_to_reg(mem_mem_to_reg),
        .mem_reg_write(mem_reg_write),
        .mem_pc_plus_4(mem_pc_plus_4)
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

        if (mem_alu_result == 0 && mem_read_data2 == 0 &&
            mem_rd == 0 &&
            mem_mem_write == 0 && mem_mem_read == 0 &&
            mem_mem_to_reg == 0 && mem_reg_write == 0 && 
            mem_pc_plus_4 == 0
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

        rd = 5'b0010;
        
        mem_write = 1;
        mem_read = 0;
        mem_to_reg = 0;
        reg_write = 0;

        pc_plus_4 = 32'h0000_0008;

        @(posedge clk);
        #1;

        if (mem_alu_result == 32'hAAAA_AAAA && 
            mem_read_data2 == 32'hBBBB_BBBB &&
            mem_rd == 5'b0010 &&
            mem_mem_write == 1 && mem_mem_read == 0 &&
            mem_mem_to_reg == 0 && mem_reg_write == 0 && 
            mem_pc_plus_4 == 32'h0000_0008
        )
            $display("Enable PASSED");
        else
            $display ("Enable FAILED (use waveform to debug)");
        $display("--------------------------------");

        // Test 3: Stall
        enable = 0;

        alu_result = 32'h1111_1111;
        read_data2 = 32'h2222_2222;

        rd = 5'b11111;
        
        mem_write = 0;
        mem_read = 0;
        mem_to_reg = 0;
        reg_write = 0;

        pc_plus_4 = 32'hDEAD_BEEF;

        @(posedge clk);
        #1;
        
        if (mem_alu_result == 32'hAAAA_AAAA && 
            mem_read_data2 == 32'hBBBB_BBBB &&
            mem_rd == 5'b0010 &&
            mem_mem_write == 1 && mem_mem_read == 0 &&
            mem_mem_to_reg == 0 && mem_reg_write == 0 && 
            mem_pc_plus_4 == 32'h0000_0008
        )
            $display("Stall PASSED");
        else
            $display ("Stall FAILED (use waveform to debug)");
        $display("--------------------------------");
        $finish;
    end 
endmodule