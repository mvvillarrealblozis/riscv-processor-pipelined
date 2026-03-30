module ex_mem(
    // EXECUTE -> MEMORY
    input clk,
    input reset,
    input enable,

    // Inputs
    // Computed Values
    input [31:0] alu_result,
    input [31:0] read_data2,
    input [1:0] writeback_sel, // 00 ALU , 01 Mem , 10 PC+4

    // Register Address
    input [4:0] rd,

    // Control Signals
    input mem_write,
    input mem_read,
    input mem_to_reg,
    input reg_write,

    // Jumps 
    input [31:0] pc_plus_4,

    // Outputs
    output reg [31:0] ex_alu_result,
    output reg [31:0] ex_read_data2,
    output reg [1:0] ex_writeback_sel,

    output reg [4:0] ex_rd,

    output reg ex_mem_write,
    output reg ex_mem_read,
    output reg ex_mem_to_reg,
    output reg ex_reg_write,

    output reg [31:0] ex_pc_plus_4
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ex_alu_result <= 32'h00000000;
            ex_read_data2 <= 32'h00000000;
            ex_writeback_sel <= 2'b0;
            ex_rd <= 5'b0;

            ex_mem_write <= 0;
            ex_mem_read <= 0;
            ex_mem_to_reg <= 0;
            ex_reg_write <= 0;

            ex_pc_plus_4 <= 32'h00000000;
        end 
        else if (enable) begin
            ex_alu_result <= alu_result;
            ex_read_data2 <= read_data2;
            ex_writeback_sel <= writeback_sel;
            ex_rd <= rd;

            ex_mem_write <= mem_write;
            ex_mem_read <= mem_read;
            ex_mem_to_reg <= mem_to_reg;
            ex_reg_write <= reg_write;

            ex_pc_plus_4 <= pc_plus_4;
        end
    end
endmodule;