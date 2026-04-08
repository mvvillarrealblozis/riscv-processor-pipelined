module mem_wb (
    // MEMORY -> WRITEBACK
    input clk,
    input reset,
    input enable,

    // Inputs

    // Data Values
    input [31:0] alu_result ,    // Arithmetic Instructions
    input [31:0] read_data2,     // For loads

    // Register Address
    input [4:0] rd,

    // Control Signals
    input mem_to_reg,            // select ALU or mem data
    input reg_write,              // enable register write 

    // Outputs
    output reg [31:0] mem_alu_result,
    output reg [31:0] mem_read_data2,
    
    output reg [4:0] mem_rd,

    output reg mem_mem_to_reg,
    output reg mem_reg_write
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_alu_result <= 32'h00000000;
            mem_read_data2 <= 32'h00000000;

            mem_rd <= 5'b00000;

            mem_mem_to_reg = 0;
            mem_reg_write = 0;
        end
        else if (enable) begin
            mem_alu_result <= alu_result;
            mem_read_data2 <= read_data2;

            mem_rd <= rd;

            mem_mem_to_reg = mem_to_reg;
            mem_reg_write = reg_write;
        end
    end
endmodule;