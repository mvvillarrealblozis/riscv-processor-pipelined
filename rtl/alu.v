module alu (
    input [31:0] a, // first operand
    input [31:0] b, // second operand
    input [3:0] alu_op,
    output reg [31:0] result
);
    always @(*) begin
        case(alu_op)
            4'b0000: result = a + b; // add
            4'b0001: result = a - b; // subtract
            4'b0010: result = a & b; // bitwise AND 
            4'b0011: result = a | b; // bitwise OR
            4'b0100: result = a ^ b; // bitwise XOR
    end

endmodule

/*
ADD - Addition
SUB - Subtraction
AND - Bitwise AND
OR - Bitwise OR
XOR - Bitwise XOR
SLT - Set less than (signed)
SLTU - Set less than (unsigned)
SLL - Shift left logical
SRL - Shift right logical
SRA - Shift right arithmetic
*/