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
        
        reset = 1;
        @(posedge clk);
        reset = 0;
        @(posedge clk);

        rd = 5'd5;
        write_data = 32'hABCDE;
        reg_write = 1;
        @(posedge clk); 

        // 3. Read it back
        reg_write = 0;  
        rs1 = 5'd5;     
        #1;
        $display("At Address 5, Read Data 1: %h (Expected ABCDE)", rdata1);

        
        rd = 5'd0;    
        write_data = 32'hFFFFFFFF;
        reg_write = 1;
        @(posedge clk);
        
        rs2 = 5'd0;
        #1;
        $display("At Address 0, Read Data 2: %h (Expected 00000000)", rdata2);

        #100;
        $finish;
    end
endmodule
