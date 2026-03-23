module alu (
    input [31:0] a,
    input [31:0] b,
    input [3:0] alu_op,
    output reg [31:0] result
);
    always @(*) begin
        case(alu_op)
            4'b0000: result = a + b;
            4'b0001: result = a - b;
            4'b0010: result = a & b;
            4'b0011: result = a | b;
            4'b0100: result = a ^ b;
            
            default result = 32'b0;
        endcase
    end
endmodule

/*
ADD - Addition                      // 0000 - R
SUB - Subtraction                   // 0001 - R
AND - Bitwise AND                   // 0010 - R
OR - Bitwise OR                     // 0011 - R
XOR - Bitwise XOR                   // 0100 - R
SLT - Set less than (signed)        // 0101 - R
SLTU - Set less than (unsigned)     // 0110 - R
SLL - Shift left logical            // 0111 - R
SRL - Shift right logical           // 1000 - R
SRA - Shift right arithmetic        // 1001 - R
*/