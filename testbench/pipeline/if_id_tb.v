`timescale 1ns/1ps

module if_id_tb;
    // Inputs
    reg clk;
    reg reset;
    reg enable;

    reg [31:0] pc;
    reg [31:0] instruction;

    // Outputs
    wire [31:0] if_pc;
    wire [31:0] if_instruction;

    if_id if_id_instance (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .pc(pc),
        .instruction(instruction),
        .id_pc(if_pc),
        .id_instruction(if_instruction)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("if_id.vcd");
        $dumpvars(0, if_id_tb);

        // Test 1: Reset 
        reset = 1;
        @(posedge clk);
        #1;

        if (if_pc == 32'h00000000 && if_instruction == 32'h00000013)
            $display("Reset PASSED");
        else
            $display("Reset FAILED: if_pc=%h (expected 0) | if_instruction=%h (expected NOP)", if_pc, if_instruction);
        $display("--------------------------------");

        // Test 2: Enable
        reset = 0;
        enable = 1;

        pc = 32'h00000008;
        instruction = 32'h00500093;

        @(posedge clk);
        #1;

        if (if_pc == 32'h00000008 && if_instruction == 32'h00500093)
            $display("Enable PASSED");
        else
            $display("Enable FAILED: if_pc=%h (expected 0x08) | if_instruction=%h (expected 0x00500093)", if_pc, if_instruction);
        $display("--------------------------------");

        // Test 3: Stall
        enable = 1;
        pc = 32'h00000008;
        instruction = 32'h00500093; // JAL x0, 12

        @(posedge clk);
        #1;

        enable = 0;
        pc = 32'h0000000C;
        instruction = 32'h00c0006f;

        @(posedge clk);
        #1;

        if (if_pc == 32'h00000008 && if_instruction == 32'h00500093)
            $display("Stall PASSED");
        else
            $display("Stall FAILED: if_pc=%h (expected 0x08) | if_instruction=%h (expected 0x00500093)", if_pc, if_instruction);
        $display("--------------------------------");
        
        $finish;
    end
endmodule