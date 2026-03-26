`timescale 1ns/1ps

module program_counter_tb;
    // Inputs
    reg clk;              // Clock - PC updates on rising edge
    reg reset;            // Reset signal
    reg pc_enable;        // Enable Signal (1 = update PC, 0 = hold)
    reg [31:0] next_pc;

    // Outputs
    wire [31:0] pc_out;    // Current PC value

    program_counter program_counter_instance (
        .clk(clk),
        .reset(reset),
        .pc_enable(pc_enable),
        .next_pc(next_pc),
        .pc_out(pc_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        $dumpfile("program_counter.vcd");
        $dumpvars(0, program_counter_tb);

        // Test 1: Reset
        reset = 1;
        @(posedge clk);
        if (pc_out == 32'h00000000)
            $display("Reset Test PASSED");
        else
            $display("Reset Test Failed: pc=%h", pc_out);

        reset = 0;
        @(posedge clk);
        if (pc_out == 32'h00000000)
            $display("Reset Test PASSED");
        else
            $display("Reset Test Failed: pc=%h", pc_out);

        // Test 2: Increment
        reset = 1;
        pc_enable = 0;
        @(posedge clk);
        
        @(negedge clk);
        reset = 0;
        pc_enable = 1;

        repeat(5) begin
            @(posedge clk);
            #1;
            $display("Time: %0t | PC Value: %0d (Hex: %h)", $time, pc_out, pc_out);
        end
        
        if (pc_out == 32'd20)
            $display("Increment Test PASSED");
        else 
            $display("Increment Test FAILED: pc_dec=%0d, pc_hex=%h", pc_out, pc_out);
        
        // Test 3: Hold
        reset = 1;
        pc_enable = 0;
        @(posedge clk);

        @(negedge clk);
        reset = 0;
        pc_enable = 1;

        repeat(4) begin
            @(posedge clk);
            #1;
        end
        
        pc_enable = 0;
        @(posedge clk);

        repeat(3) begin
            @(posedge clk);
            #1;
        end

        if (pc_out == 32'h00000010)
            $display("Hold Test PASSED");
        else
            $display("Hold Test Failed: pc=%h", pc_out);

        //Test 4: Reset Override
        reset = 1;
        pc_enable = 0;
        @(posedge clk);

        @(negedge clk);
        pc_enable = 1;

        repeat(5) begin
            @(posedge clk);
            #1;
        end
        
        reset = 1;

        @(posedge clk);

        if (pc_out == 32'h00000000)
            $display("Reset Override 0 Check Test PASSED");
        else
            $display("Reset Override 0 Check Test Failed: pc=%h", pc_out);

        @(negedge clk);
        reset = 0;
        
        repeat(1) begin
            @(posedge clk);
            #1;
        end
        
        if (pc_out == 32'h00000004)
            $display("Reset Override Recovery Test PASSED");
        else
            $display("Reset Override Recover Test Failed: pc=%h", pc_out);
        
        // Test 5: Enable/Disable Toggle
        reset = 1;
        pc_enable = 0;
        @(posedge clk);

        @(posedge clk);
        reset = 0;
        pc_enable = 1;

        repeat(5) begin
            @(posedge clk);
            pc_enable = ~pc_enable;
            #1;
            $display("pc=%h | pc_enable=%b", pc_out, pc_enable);
        end

        if (pc_out == 32'h0000000C)
            $display("Toggle Test PASSED");
        else
            $display("Toggle Test Failed: pc=%h", pc_out);
        
        // Test 6: Branch Target 
        reset = 1;
        pc_enable = 0;
        @(posedge clk);

        @(posedge clk);
        reset = 0;
        pc_enable = 1;

        @(posedge clk);
        #1;

        if (pc_out == 32'h00000044)
            $display("Branch Target Test PASSED");
        else 
            $display("Branch Target Test FAILED: pc=%h (expected 00000044)", pc_out);

        $finish;
    end
endmodule

