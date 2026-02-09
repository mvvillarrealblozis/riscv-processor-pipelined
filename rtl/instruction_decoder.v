module instruction_decoder (
    input [31:0] instruction,

    output [6:0] opcode,    // Bits [6:0]
    output [4:0] rd,        // Bits [11:7]          destination register
    output [2:0] funct3,    // Bits [14:12]         function code
    output [4:0] rs1,       // Bits [19:15]         source register 1
    output [4:0] rs2,       // Bits [24:20]         source register 2
    output [6:0] funct7,    // Bits [31:25]         function code (R-Type)
    output [31:0] imm_i,    // I-type immediate     (sign-extended)
    output [31:0] imm_s,    // S-type immediate     (sign-extended)
    output [31:0] imm_b,    // B-type immediate     (sign-extended)
    output [31:0] imm_u,    // U-type immediate
    output [31:0] imm_j     // J-type immediate     (sign-extended)
);

    assign opcode = instruction[6:0];
    assign rd = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign funct7 = instruction[31:25];

    // Immediate Value Extraction
    assign imm_i = {{20{instruction[31]}}, instruction[31:20]};

    assign imm_s = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

    assign imm_b = {{19{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};

    assign imm_u = {instruction[31:12], 12'b0};

    assign imm_j = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
endmodule