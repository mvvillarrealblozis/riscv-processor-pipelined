module cpu(
    input clk,
    input reset
);
    wire [31:0] pc_out;
    wire [31:0] instruction;

    wire [6:0] opcode;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [6:0] funct7;
    wire [31:0] imm_i;
    wire [31:0] imm_s;
    wire [31:0] imm_b;  
    wire [31:0] imm_u;
    wire [31:0] imm_j;
    
    wire [3:0] alu_op;
    wire alu_src;
    wire reg_write;
    wire mem_write;
    wire mem_read;
    wire mem_to_reg;
    wire branch;
    wire jump;

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    wire [31:0] alu_input_b;
    wire [31:0] alu_result;

    reg [31:0] imm_val;

    wire [31:0] mem_read_data;
    wire [31:0] reg_write_data;

    program_counter pc_inst (
        .clk(clk),
        .reset(reset),
        .pc_enable(1'b1),
        .pc_out(pc_out)
    );

    instruction_memory imem_inst (
        .address(pc_out),
        .instruction(instruction)
    );

    instruction_decoder decoder_inst (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7),
        .imm_i(imm_i),
        .imm_s(imm_s),
        .imm_b(imm_b),
        .imm_u(imm_u),
        .imm_j(imm_j)
    );

    control_unit control_inst (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_op(alu_op),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump)
    );

    register_file regf_inst (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(reg_write_data),
        .reg_write(reg_write),
        .rdata1(read_data1),
        .rdata2(read_data2)
    );

    alu alu_inst (
        .a(read_data1),
        .b(alu_input_b),
        .alu_op(alu_op),
        .result(alu_result)
    );

    data_memory data_mem_inst (
        .clk(clk),
        .address(alu_result),
        .write_data(read_data2),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .read_data(mem_read_data)
    );

    always @(*) begin
        case (opcode)
            7'b0010011: imm_val = imm_i;
            7'b0100011: imm_val = imm_s;
            7'b0110111: imm_val = imm_u;
            7'b0000011: imm_val = imm_i; // LW
            default: imm_val = 32'b0;
        endcase
    end

    assign alu_input_b = (alu_src) ? imm_val : read_data2;

    assign reg_write_data = (mem_to_reg) ? mem_read_data : alu_result;

endmodule
