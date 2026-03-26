module branch_unit (
    input [31:0] rdata1,
    input [31:0] rdata2,
    input [2:0] funct3,
    input branch,

    output reg branch_taken
);  
    always @(*)
    if (~branch) begin          // Not a branch instruction
        branch_taken = 0;
    end else begin
        case(funct3)
            3'b000: branch_taken = (rdata1 == rdata2);                      // BEQ
            3'b001: branch_taken = (rdata1 != rdata2);                      // BNE
            3'b100: branch_taken = ($signed(rdata1) < $signed(rdata2));     // BLT
            3'b101: branch_taken = ($signed(rdata1) >= $signed(rdata2));    // BGE

            default: branch_taken = 0;
        endcase
    end
endmodule