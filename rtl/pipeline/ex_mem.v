module ex_mem(
    // EXECUTE -> MEMORY
    input clk,
    input reset,
    input enable,

    // Inputs
    // Computed Values
    input [31:0] alu_result,
    input [31:0] read_data2,

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
    output reg [31:0] mem_alu_result,
    output reg [31:0] mem_read_data2,

    output reg [4:0] mem_rd,

    output reg mem_mem_write,
    output reg mem_mem_read,
    output reg mem_mem_to_reg,
    output reg mem_reg_write,

    output reg [31:0] mem_pc_plus_4
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_alu_result <= 32'h00000000;
            mem_read_data2 <= 32'h00000000;
            mem_rd <= 5'b0;

            mem_mem_write <= 0;
            mem_mem_read <= 0;
            mem_mem_to_reg <= 0;
            mem_reg_write <= 0;

            mem_pc_plus_4 <= 32'h00000000;
        end 
        else if (enable) begin
            mem_alu_result <= alu_result;
            mem_read_data2 <= read_data2;
            mem_rd <= rd;

            mem_mem_write <= mem_write;
            mem_mem_read <= mem_read;
            mem_mem_to_reg <= mem_to_reg;
            mem_reg_write <= reg_write;

            mem_pc_plus_4 <= pc_plus_4;
        end
    end
endmodule;