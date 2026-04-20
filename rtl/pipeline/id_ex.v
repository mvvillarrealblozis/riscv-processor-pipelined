module id_ex (
    // INSTRUCTION DECODE -> INSTRUCTION EXECUTE
    input clk,
    input reset,
    input enable,

    // Inputs from ID stage
    input [31:0] pc,
    input [31:0] read_data1,
    input [31:0] read_data2,
    input [31:0] imm_val,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [2:0] funct3,
    input [3:0] alu_op,
    input alu_src,
    input reg_write,
    input mem_write,
    input mem_read,
    input mem_to_reg,
    input branch,
    input jump,
    input jump_jal,
    input jump_jalr,
    input pc_to_alu,

    // Outputs to EX stage
    output reg [31:0] ex_pc,
    output reg [31:0] ex_read_data1,
    output reg [31:0] ex_read_data2,
    output reg [31:0] ex_imm_val,
    output reg [4:0] ex_rs1,
    output reg [4:0] ex_rs2,
    output reg [4:0] ex_rd,
    output reg [2:0] ex_funct3,
    output reg [3:0] ex_alu_op,
    output reg ex_alu_src,
    output reg ex_reg_write,
    output reg ex_mem_write,
    output reg ex_mem_read,
    output reg ex_mem_to_reg,
    output reg ex_branch,
    output reg ex_jump,
    output reg ex_jump_jal,
    output reg ex_jump_jalr,
    output reg ex_pc_to_alu
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ex_read_data1 <= 32'h0;
            ex_read_data2 <= 32'h0;
            ex_pc <= 32'h0;
            ex_rs1 <= 5'b0;
            ex_rs2 <= 5'b0;
            ex_rd <= 5'b0;
            ex_funct3 <= 3'b0;
            ex_imm_val <= 32'h0;
            ex_alu_op <= 4'b0;
            ex_alu_src <= 1'b0;
            ex_reg_write <= 1'b0;
            ex_mem_write <= 1'b0;
            ex_mem_read <= 1'b0;
            ex_mem_to_reg <= 1'b0;
            ex_branch <= 1'b0;
            ex_jump <= 1'b0;
            ex_jump_jal <= 1'b0;
            ex_jump_jalr <= 1'b0;
            ex_pc_to_alu <= 1'b0;
        end else if (enable) begin
            ex_read_data1 <= read_data1;
            ex_read_data2 <= read_data2;
            ex_pc <= pc;

            ex_rs1 <= rs1;
            ex_rs2 <= rs2;
            ex_rd <= rd;
            ex_funct3 <= funct3;

            ex_imm_val <= imm_val;

            ex_alu_op <= alu_op;
            ex_alu_src <= alu_src;
            ex_reg_write <= reg_write;
            ex_mem_write <= mem_write;
            ex_mem_read <= mem_read;
            ex_mem_to_reg <= mem_to_reg;
            ex_branch <= branch;
            ex_jump <= jump;
            ex_jump_jal <= jump_jal;
            ex_jump_jalr <= jump_jalr;
            ex_pc_to_alu <= pc_to_alu;
        end
    end
endmodule