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

        // Test 1: Verify add instructions and NOP's
        wait(cpu_instance.pc_inst.pc_out == 32'h14);
        @(negedge clk);
        #1;

        if (cpu_instance.regf_inst.rf[1] == 32'h05)  
            $display("First ADD PASSED");
        else 
            $display("First ADD FAILED: x1=%h", cpu_instance.regf_inst.rf[1]);
        $display("--------------------------------");

        if (cpu_instance.regf_inst.rf[2] == 32'h15)
            $display("Second ADD PASSED");
        else 
            $display("Second ADD FAILED: x2=%d", cpu_instance.regf_inst.rf[2]);
        $display("--------------------------------");
        
        $finish;
    end

endmodule
