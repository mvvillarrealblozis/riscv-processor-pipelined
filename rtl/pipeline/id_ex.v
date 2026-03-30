module id_ex (
    // INSTRUCTION DECODE -> INSTRUCTION EXECUTE
    input clk,
    input reset,
    input enable,

    // Data values
    input [31:0] rdata1,            // rs1 | alu_input A 
    input [31:0] rdata2,            // rs2 | alu_input B
    input [31:0] pc,
    input [31:0] imm,

    // Register Addresses
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [2:0] funct3, 

    // Control Signals
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

    // Output Signals
    
    // Register Values
    output reg [31:0] id_rdata1,    // rs1 | alu_input A 
    output reg [31:0] id_rdata2,    // rs2 | alu_input B
    output reg [31:0] id_pc,
    output reg [31:0] id_imm,

    // Register Addresses
    output reg [4:0] id_rs1,
    output reg [4:0] id_rs2,
    output reg [4:0] id_rd,
    output reg [2:0] id_funct3,

    // Control Signals
    output reg [3:0] id_alu_op,
    output reg id_alu_src,
    output reg id_reg_write,
    output reg id_mem_write,
    output reg id_mem_read,
    output reg id_mem_to_reg,
    output reg id_branch,
    output reg id_jump,
    output reg id_jump_jal,
    output reg id_jump_jalr,
    output reg id_pc_to_alu
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            id_rdata1 <= 32'h0;
            id_rdata2 <= 32'h0;
            id_pc <= 32'h0;
            id_imm <= 32'h0;

            id_rs1 <= 5'b0;
            id_rs2 <= 5'b0;
            id_rd <= 5'b0;
            id_funct3 <= 3'b0;

            id_alu_op <= 4'b0;
            id_alu_src <= 1'b0;
            id_reg_write <= 1'b0;
            id_mem_write <= 1'b0;
            id_mem_read <= 1'b0;
            id_mem_to_reg <= 1'b0;
            id_branch <= 1'b0;
            id_jump <= 1'b0;
            id_jump_jal <= 1'b0;
            id_jump_jalr <= 1'b0;
            id_pc_to_alu <= 1'b0;
        end else if (enable) begin
            id_rdata1 <= rdata1;
            id_rdata2 <= rdata2;
            id_pc <= pc;
            id_imm <= imm;

            id_rs1 <= rs1;
            id_rs2 <= rs2;
            id_rd <= rd;
            id_funct3 <= funct3;

            id_alu_op <= alu_op;
            id_alu_src <= alu_src;
            id_reg_write <= reg_write;
            id_mem_write <= mem_write;
            id_mem_read <= mem_read;
            id_mem_to_reg <= mem_to_reg;
            id_branch <= branch;
            id_jump <= jump;
            id_jump_jal <= jump_jal;
            id_jump_jalr <= jump_jalr;
            id_pc_to_alu <= pc_to_alu;
        end
    end
endmodule