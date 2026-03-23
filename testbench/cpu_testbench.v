`timescale 1ns/1ps

module cpu_testbench;
    reg clk;
    reg reset;

    cpu cpu_instance (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("cpu_testbench.vcd");
        $dumpvars(0, cpu_testbench);


        reset = 1;
        @(posedge clk);
        @(negedge clk);
        reset = 0;

        // Test 1: JAL saves return address in x1 and jumps to 0x10
        wait(cpu_instance.pc_inst.pc_out == 32'h10);
        @(negedge clk);
        #1;

        if (cpu_instance.regf_inst.rf[1] == 32'h08)  
            $display("JAL saved return address PASSED");
        else 
            $display("JAL did not save return address FAIL: x1=%h", cpu_instance.regf_inst.rf[1]);
        $display("--------------------------------");

        if (cpu_instance.regf_inst.rf[3] == 32'h0)
            $display("JAL skipped instruction PASSED");
        else 
            $display("JAL did not skip FAIL: x3=%d", cpu_instance.regf_inst.rf[3]);
        $display("--------------------------------");

        // Test 2: JALR returns to 0x08
        wait(cpu_instance.pc_inst.pc_out == 32'h08);
        @(posedge clk);  // Let x3 get written
        @(negedge clk);
        #1;

        if (cpu_instance.regf_inst.rf[3] == 32'd99)
            $display("JALR returned to 0x08 PASSED");
        else 
            $display("JALR did not return FAIL: x3=%d", cpu_instance.regf_inst.rf[3]);
        $display("--------------------------------");

        // Test 3: Odd address masking
        wait(cpu_instance.pc_inst.pc_out == 32'h18);
        @(posedge clk);
        @(negedge clk);
        #1;

        if (cpu_instance.regf_inst.rf[1] == 32'd9)
            $display("ADDI x1=9 PASSED");
        else 
            $display("ADDI x1=9 FAIL: x1=%d", cpu_instance.regf_inst.rf[1]);
        $display("--------------------------------");
        
        wait(cpu_instance.pc_inst.pc_out == 32'h1C);
        @(posedge clk);
        @(negedge clk);
        #1;

        if (cpu_instance.pc_inst.pc_out == 32'h08)
            $display("JALR odd address masking (PC=8) PASSED");
        else 
            $display("JALR odd address masking FAIL: PC=%h", cpu_instance.pc_inst.pc_out);
        $display("--------------------------------");

        if (cpu_instance.regf_inst.rf[2] == 32'h20)
            $display("JALR saved return address PASSED");
        else
            $display("JALR did not save return address FAIL: x2=%h", cpu_instance.regf_inst.rf[2]);

        $finish;
        /*
        if (cpu_instance.regf_inst.rf[3] == 32'h0)
            $display("Branches skipped instructions PASSED");
        else 
            $display("Branches did not skip instructions FAIL: x3=%d", cpu_instance.regf_inst.rf[3]);

        $display("--------------------------------");

        if (cpu_instance.regf_inst.rf[5] == 32'd15)
            $display("Instructions executed properly PASSED");
        else 
            $display("Instructions not executed properly FAIL: x5=%d", cpu_instance.regf_inst.rf[5]);


        // Test 1: ADDI x1, x0, 5
        if (cpu_instance.regf_inst.rf[1] == 32'd5)
            $display("Test 1 PASSED: x1 = %0d", cpu_instance.regf_inst.rf[1]);
        else
            $display("Test 1 FAILED: x1 = %0d (expected 5)", cpu_instance.regf_inst.rf[1]);
        
        $display("--------------------------------");

        // Test 2: ADDI x2, x0, 10
        if (cpu_instance.regf_inst.rf[2] == 32'd10)
            $display("Test 2 PASSED: x2 = %0d", cpu_instance.regf_inst.rf[2]);
        else
            $display("Test 2 FAILED: x2 = %0d (expected 10)", cpu_instance.regf_inst.rf[2]);
        
        $display("--------------------------------");

        // Test 3: ADD x3, x1, x2
        if (cpu_instance.regf_inst.rf[3] == 32'd15)
            $display("Test 3 PASSED: x3 = %0d", cpu_instance.regf_inst.rf[3]);
        else
            $display("Test 3 FAILED: x3 = %0d (expected 15)", cpu_instance.regf_inst.rf[3]);
        
        $display("--------------------------------");

        // Test 4: SUB x4, x1, x2
        if (cpu_instance.regf_inst.rf[4] == 32'hFFFFFFFB)
            $display("Test 4 PASSED: x4 = %0h", cpu_instance.regf_inst.rf[4]);
        else
            $display("Test 4 FAILED: x4 = %0h (expected FFFFFFFB)", cpu_instance.regf_inst.rf[4]);
        
        $display("--------------------------------");

        // Test 5: AND x5, x1, x2
        if (cpu_instance.regf_inst.rf[5] == 32'b0)
            $display("Test 5 PASSED: x5 = %0b", cpu_instance.regf_inst.rf[5]);
        else
            $display("Test 5 FAILED: x5 = %0b (expected 0)", cpu_instance.regf_inst.rf[5]);
        */

        /*
        // Test 1: ADDI x1, x0, 10
        if (cpu_instance.regf_inst.rf[1] == 32'd10)
            $display("Test 1 PASSED: x1 = %0d", cpu_instance.regf_inst.rf[1]);
        else
            $display("Test 1 FAILED: x1 = %0d (expected 10)", cpu_instance.regf_inst.rf[1]);

        $display("--------------------------------");

        // Test 2: ADDI x2, x0, 20
        if (cpu_instance.regf_inst.rf[2] == 32'd20)
            $display("Test 2 PASSED: x2 = %0d", cpu_instance.regf_inst.rf[2]);
        else
            $display("Test 2 FAILED: x2 = %0d (expected 20)", cpu_instance.regf_inst.rf[2]);

        $display("--------------------------------");

        // Test 3: LW x3, 0(x0)
        if (cpu_instance.regf_inst.rf[3] == 32'd10)
            $display("Test 3 PASSED: x3 = %0d", cpu_instance.regf_inst.rf[3]);
        else
            $display("Test 3 FAILED: x3 = %0d (expected 10)", cpu_instance.regf_inst.rf[3]);

        $display("--------------------------------");

        // Test 4: LW x4, 4(x0)
        if (cpu_instance.regf_inst.rf[4] == 32'd20)
            $display("Test 4 PASSED: x4 = %0d", cpu_instance.regf_inst.rf[4]);
        else
            $display("Test 4 FAILED: x4 = %0d (expected 20)", cpu_instance.regf_inst.rf[4]);

        $display("--------------------------------");
        
        // Test 5: ADD x5, x3, x4
        if (cpu_instance.regf_inst.rf[5] == 32'd30)
            $display("Test 5 PASSED: x5 = %0d", cpu_instance.regf_inst.rf[5]);
        else
            $display("Test 5 FAILED: x5 = %0d (expected 30)", cpu_instance.regf_inst.rf[5]);

        $finish;
        */
    end

endmodule
