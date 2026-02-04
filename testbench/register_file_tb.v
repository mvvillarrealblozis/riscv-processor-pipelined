`timescale 1ns/1ps 

module register_file_tb;
    // Inputs
    reg clk;
    reg reset;
    reg [4:0] rs1;             // Read register 1 (5 bits = 0-31)
    reg [4:0] rs2;             // Read register 2
    reg [4:0] rd;              // Write register
    reg [31:0] write_data;     // Data to write
    reg reg_write;             // Write enable

    // Outputs
    wire [31:0] rdata1;         // Data from rs1
    wire [31:0] rdata2; 

    register_file register_file_instance (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .reg_write(reg_write),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("register_file.vcd");
        $dumpvars(0, register_file_tb);
        
        // Test 1: Reset
        rd = 5'd5;
        write_data = 32'h000AAAAA;
        reg_write = 1;
        @(posedge clk);

        rd = 5'd10;
        write_data = 32'h000BBBBB;
        @(posedge clk);

        reg_write = 0;

        reset = 1;
        @(posedge clk);
        reset = 0;
        @(posedge clk);

        rs1 = 5'd5;
        rs2 = 5'd10;
        #1;

        if (rdata1 == 32'h0 && rdata2 == 32'h0)
            $display("Reset Test PASSED");
        else
            $display("Reset Test FAILED: reg[5]=%h, reg[10]=%h", rdata1, rdata2);

        reg_write = 1;

        // Test 2: Writing to the 0 register
        rd = 5'd0;
        write_data = 32'h000AAAAA;
        reg_write = 1;
        @(posedge clk);
        
        rs1 = 5'd0;
        @(posedge clk);
        #1;

        if(rdata1 == 32'h0)
            $display("Zero Register Test PASSED");
        else
            $display("Zero Register Test Failed: reg[0]=%h",rdata1);

        // Reset register file for next test
        reset = 1;
        @(posedge clk);
        reset = 0;
        @(posedge clk);

        // Test 3: Writing to the same register
        rd = 5'd9;
        write_data = 32'h000DDDDD;
        reg_write = 1;
        @(posedge clk);

        write_data = 32'h000CCCCC;
        @(posedge clk);

        reg_write = 0;
        rs1 = 5'd9;
        @(posedge clk);
        #1;

        if(rdata1 == 32'h000CCCCC)
            $display("Same Register Test PASSED");
        else
            $display("Same Register Test Failed: reg[9]=%h",rdata1);


        // Reset register file for next test
        reset = 1;
        @(posedge clk);
        reset = 0;
        @(posedge clk);

        // Test 4: Write and read
        rd = 5'd11; 
        write_data = 32'h000AAAAA;
        reg_write = 1;
        @(posedge clk);

        rd = 5'd12; 
        write_data = 32'h000BBBBB; 
        @(posedge clk);

        rd = 5'd13;
        write_data = 32'h000CCCCC; 
        @(posedge clk);

        rd = 5'd14; 
        write_data = 32'h000DDDDD; 
        @(posedge clk);

        rd = 5'd15; 
        write_data = 32'h000EEEEE; 
        @(posedge clk);

        reg_write = 0;

        // Test outputs
        rs1 = 5'd11;
        rs2 = 5'd12;
        #1;
        @(posedge clk);

        if(rdata1 == 32'h000AAAAA && rdata2 == 32'h000BBBBB)
            $display("1st Write and Read Test: PASSED");
        else
            $display("1st Write and Read Test Failed: reg[11]=%h | reg[12]=%h",rdata1, rdata2);

        rs1 = 5'd13;
        rs2 = 5'd14;
        #1;
        @(posedge clk);

        if(rdata1 == 32'h000CCCCC && rdata2 == 32'h000DDDDD)
            $display("2nd Write and Read Test: PASSED");
        else
            $display("2nd Write and Read Test Failed: reg[13]=%h | reg[14]=%h",rdata1, rdata2);

        rs1 = 5'd15;
        #1;
        @(posedge clk);
        
        if(rdata1 == 32'h000EEEEE)
            $display("3rd Write and Read Test: PASSED");
        else
            $display("3rd Write and Read Test Failed: reg[15]=%h",rdata1);
        
        #100;
        $finish;
    end
endmodule
