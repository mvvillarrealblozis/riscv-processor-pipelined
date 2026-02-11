`timescale 1ns/1ps

module data_memory_tb;
    reg clk;
    reg [31:0] address;
    reg [31:0] write_data;
    reg mem_write;
    reg mem_read;

    wire [31:0] read_data;

    data_memory data_memory_instance (
        .clk(clk),
        .address(address),
        .write_data(write_data),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .read_data(read_data)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    reg [31:0] x3, x4, x5;
    
    initial begin
        $dumpfile("data_memory_tb.vcd");
        $dumpvars(0, data_memory_tb);

        // Test 1: x1 == 10
        address = 32'h1;
        write_data = 32'd10;
        mem_write = 1;
        mem_read = 0;
        @(posedge clk);
        #1;

        mem_write = 0;
        
        mem_read = 1;
        @(posedge clk);
        #1;

        if (read_data == 32'd10) 
            $display("Test 1 PASSED");
        else 
            $display("Test 1 FAILED: read_data=%d (expected 10)", read_data);
        
        $display("--------------------------------");

        // Test 2: x2 == 20
        address = 32'h2;
        write_data = 32'd20;
        mem_write = 1;
        mem_read = 0;
        @(posedge clk);
        #1;

        mem_write = 0;
        
        mem_read = 1;
        @(posedge clk);
        #1;

        if (read_data == 32'd20) 
            $display("Test 2 PASSED");
        else 
            $display("Test 2 FAILED: read_data=%d (expected 20)", read_data);
        
        $display("--------------------------------");

        // Test 3: x3 == 10
        address = 32'h2;
        write_data = 32'd20;
        mem_write = 1;
        mem_read = 0;
        @(posedge clk);
        #1;

        mem_write = 0;
        
        mem_read = 1;
        @(posedge clk);
        #1;

        if (read_data == 32'd20) 
            $display("Test 3 PASSED");
        else 
            $display("Test 3 FAILED: read_data=%d (expected 20)", read_data);
        
        $display("--------------------------------");

        // Test 4: SW x1, 0(x0) Store x1 (10) to memory address 0
        address = 32'd0;
        write_data = 32'd10;
        mem_write = 1;
        mem_read = 0;
        @(posedge clk);
        #1; 

        mem_write = 0;

        mem_read = 1;
        @(posedge clk);
        #1;

        if (read_data == 32'd10) 
            $display("Test 4 PASSED");
        else 
            $display("Test 4 FAILED: read_data=%d (expected 10)", read_data);
        
        $display("--------------------------------");

        // Test 5: SW x2, 4(x0) Store x2 (20) to memory address 4
        address = 32'd4;
        write_data = 32'd20;
        mem_write = 1;
        mem_read = 0;
        @(posedge clk);
        #1; 

        mem_write = 0;

        mem_read = 1;
        @(posedge clk);
        #1;

        if (read_data == 32'd20) 
            $display("Test 5 PASSED");
        else 
            $display("Test 5 FAILED: read_data=%d (expected 20)", read_data);
        
        $display("--------------------------------");

        // Test 6: LW x3, 0(x0) Load from address 0 into x3 (should get 10)
        address = 32'd3;
        mem_write = 0;
        mem_read = 1;
        @(posedge clk);
        #1;

        if (read_data == 32'd10) 
            $display("Test 6 PASSED");
        else 
            $display("Test 6 FAILED: read_data=%d (expected 10)", read_data);
        
        $display("--------------------------------");

        // Test 7: LW x4, 4(x0) Load from address 4 into x4 (should get 20)
        address = 32'd4;
        mem_write = 0;
        mem_read = 1;
        @(posedge clk);
        #1;

        if (read_data == 32'd20) 
            $display("Test 7 PASSED");
        else 
            $display("Test 7 FAILED: read_data=%d (expected 20)", read_data);
        
        $display("--------------------------------");

        // Test 8: ADD x5, x3, x4  x5 = x3 + x4 = 10 + 20 = 30
        address = 32'd3;
        mem_read = 1;
        @(posedge clk);
        #1;
        x3 = read_data;

        address = 32'd4;
        @(posedge clk);
        #1;
        x4 = read_data;

        @(posedge clk);
        #1;

        x5 = x4 + x3;
        #1;

        if (x5 == 32'd30) 
            $display("Test 8 PASSED");
        else 
            $display("Test 8 FAILED: x5=%d (expected 30)", x5);
        
        $display("--------------------------------");

        $finish;
    end
endmodule
