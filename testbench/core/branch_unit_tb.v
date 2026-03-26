`timescale 1ns/1ps

module branch_unit_tb;
    reg [31:0] rdata1;
    reg [31:0] rdata2;
    reg [2:0] funct3;
    reg branch;

    wire branch_taken;

    branch_unit branch_unit_instance (
        .rdata1(rdata1),
        .rdata2(rdata2),
        .funct3(funct3),
        .branch(branch),
        .branch_taken(branch_taken)
    );

    initial begin
        $dumpfile("branch_unit_tb.vcd");
        $dumpvars(0, branch_unit_tb);

        // Test 1: BEQ
        rdata1 = 32'd5;
        rdata2 = 32'd5;
        funct3 = 3'b000;
        branch = 1;
        #1;

        if (branch_taken) 
            $display("TEST 1 PASSED");
        else
            $display("TEST 1 FAILED: rdata1=%d | rdata2=%d | funct3=%b | branch=%b", rdata1, rdata2, funct3, branch);

        $display("--------------------------------");

        // Test 2: BNE
        rdata1 = 32'd4;
        rdata2 = 32'd5;
        funct3 = 3'b001;
        branch = 1;
        #1;

        if (branch_taken) 
            $display("TEST 2 PASSED");
        else
            $display("TEST 2 FAILED: rdata1=%d | rdata2=%d | funct3=%b | branch=%b", rdata1, rdata2, funct3, branch);

        $display("--------------------------------");

        // Test 3: BLT
        rdata1 = 32'd4;
        rdata2 = 32'd5;
        funct3 = 3'b100;
        branch = 1;
        #1;

        if (branch_taken) 
            $display("TEST 3 PASSED");
        else
            $display("TEST 3 FAILED: rdata1=%d | rdata2=%d | funct3=%b | branch=%b", rdata1, rdata2, funct3, branch);

        $display("--------------------------------");

        // Test 4: BGT
        rdata1 = 32'd6;
        rdata2 = 32'd5;
        funct3 = 3'b011;
        branch = 1;
        #1;

        if (branch_taken) 
            $display("TEST 4 PASSED");
        else
            $display("TEST 4 FAILED: rdata1=%d | rdata2=%d | funct3=%b | branch=%b", rdata1, rdata2, funct3, branch);

        $display("--------------------------------");

        $finish;
    end
    
endmodule