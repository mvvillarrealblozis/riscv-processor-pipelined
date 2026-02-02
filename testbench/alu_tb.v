`timescale 1ns/1ps

module alu_tb;
    // inputs
    reg [31:0] a;
    reg [31:0] b;
    reg [2:0] alu_op;

    // output 
    wire [31:0] result;

    alu uut(
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result)
    );

    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, alu_tb);

        // add 
        a = 32'd10;
        b = 32'd5;
        alu_op = 3'b000;
        #10;
        $display("ADD: %d + %d = %d (expected 15)", a, b, result);
        
        // sub
        alu_op = 3'b001;
        #10;
        $display("SUB: %d - %d = %d (expected 5)", a, b, result);

        // and
        a = 32'hFFFF0000;
        b = 32'h0000FFFF;
        alu_op = 3'b010;
        #10;
        $display("AND: %h & %h = %h (expected 0)", a, b, result);
        
        // or
        alu_op = 3'b011;
        #10;
        $display("OR: %h | %h = %h (expected FFFFFFFF)", a, b, result);

        // xor
        a = 32'hAAAAAAAA;
        b = 32'h55555555;
        alu_op = 3'b100;  
        #10;
        $display("XOR: %h ^ %h = %h (expected FFFFFFFF)", a, b, result);

        $finish;
    end
endmodule    
