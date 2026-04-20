module if_id (
    // INSTRUCTION FETCH -> INSTRUCTION DECODE
    input clk,
    input reset,
    input enable,                       // 1 = update, 0 = stall
    
    // Instruction fetch stage inputs
    input [31:0] pc,
    input [31:0] instruction,

    // Instruction fetch stage outputs
    output reg [31:0] id_pc,
    output reg [31:0] id_instruction
);

    // 0x00000013 is addi x0, x0, 0 or NOP 
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            id_pc <= 32'h00000000;
            id_instruction <= 32'h00000013;
        end
        else if (enable) begin
            id_pc <= pc;
            id_instruction <= instruction;
        end
    end

endmodule