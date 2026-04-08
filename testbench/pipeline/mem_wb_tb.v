`timescale 1ns/1ps

module mem_wb_tb;
    // Inputs
    reg clk;
    reg reset;
    reg enable;

    reg [31:0] alu_result;
    reg [31:0] read_data2;

    reg [4:0] rd;

    reg mem_to_reg;
    reg reg_write;

    // Outputs

    wire [31:0] mem_alu_result;
    wire [31:0] mem_read_data2;

    wire [4:0] mem_rd;

    wire mem_mem_to_reg;
    wire mem_reg_write;

    mem_wb mem_wb_instance (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .alu_result(alu_result),
        .read_data2(read_data2),
        .rd(rd),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .mem_alu_result(mem_alu_result),
        .mem_read_data2(mem_read_data2),
        .mem_rd(mem_rd),
        .mem_mem_to_reg(mem_mem_to_reg),
        .mem_reg_write(mem_reg_write)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("mem_wb.vcd");
        $dumpvars(0, mem_wb_tb);

        // Test 1: Reset
        reset = 1;
        enable = 0;

        @(posedge clk);
        #1;

        if (mem_alu_result == 32'h00000000 &&
            mem_read_data2 == 32'h00000000 &&
            mem_rd == 5'b00000 &&
            mem_mem_to_reg == 0 &&
            mem_reg_write == 0
        )
            $display("Reset Test PASSED");
        else
            $display("Reset Test FAILED (use waveform)");

        $display("--------------------------------");
        
        // Test 2: Enable
        reset = 0;
        enable = 1;

        alu_result = 32'hAAAA_AAAA;
        read_data2 = 32'hBBBB_BBBB;
        
        rd = 5'b00011;

        mem_to_reg = 1;
        reg_write = 1;
        
        @(posedge clk);
        #1;

        if (mem_alu_result == 32'hAAAA_AAAA &&
            mem_read_data2 == 32'hBBBB_BBBB &&
            mem_rd == 5'b00011 &&
            mem_mem_to_reg == 1 &&
            mem_reg_write == 1
        )
            $display("Enable Test PASSED");
        else
            $display("Enable Test FAILED (use waveform)");

        $display("--------------------------------");

        // Test 3: Stall
        enable = 0;

        alu_result = 32'h1111_1111;
        read_data2 = 32'h2222_2222;
        
        rd = 5'b1111;

        mem_to_reg = 0;
        reg_write = 0;
        
        @(posedge clk);
        #1;

        if (mem_alu_result == 32'hAAAA_AAAA &&
            mem_read_data2 == 32'hBBBB_BBBB &&
            mem_rd == 5'b00011 &&
            mem_mem_to_reg == 1 &&
            mem_reg_write == 1
        )
            $display("Stall Test PASSED");
        else
            $display("Stall Test FAILED (use waveform)");

        $display("--------------------------------");

        $finish;
    end
endmodule;