module mem_wb (
    // MEMORY -> WRITEBACK
    input clk,
    input reset,
    input enable,

    // Inputs

    // Data Values
    input [31:0] alu_result ,    // Arithmetic Instructions
    input [31:0] mem_data,
    input [31:0] pc_plus_4,
    
    // Register Address
    input [4:0] rd,

    // Control Signals
    input mem_to_reg,            // select ALU or mem data
    input reg_write,              // enable register write 

    // Outputs
    output reg [31:0] wb_alu_result,
    output reg [31:0] wb_mem_data,
    output reg [31:0] wb_pc_plus_4,

    output reg [4:0] wb_rd,

    output reg wb_mem_to_reg,
    output reg wb_reg_write
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wb_alu_result <= 32'h00000000;
            wb_mem_data <= 32'h00000000;
            wb_pc_plus_4 <= 32'h00000000;

            wb_rd <= 5'b00000;

            wb_mem_to_reg = 0;
            wb_reg_write = 0;
        end
        else if (enable) begin
            wb_alu_result <= alu_result;
            wb_mem_data <= mem_data;
            wb_pc_plus_4 <= pc_plus_4;
            
            wb_rd <= rd;

            wb_mem_to_reg = mem_to_reg;
            wb_reg_write = reg_write;
        end
    end
endmodule;