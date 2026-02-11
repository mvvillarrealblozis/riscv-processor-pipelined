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

        repeat(5) begin
            $display("PC =%h | Instruction =%h", 
                cpu_instance.pc_inst.pc_out,
                cpu_instance.imem_inst.instruction);
            @(posedge clk);
            #1;
        end

        $display("--------------------------------");

        repeat (10) @(posedge clk);
        #1;

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
        
        $finish;
    end
endmodule
