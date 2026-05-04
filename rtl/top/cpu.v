module cpu(
    input clk,
    input reset
);
    // ─── FETCH STAGE ────────────────────────────────────────────────────────
    wire [31:0] pc_out;         // Current instruction address → instruction memory
    wire [31:0] instruction;    // Raw 32-bit instruction → decoder

    // PIPELINE REGISTERS
    wire [31:0] next_pc;
    // ========================================================================
    // ID STAGE SIGNALS (outputs of IF/ID register)
    // ========================================================================
    wire [31:0] id_pc;
    wire [31:0] id_instruction;

    // ID stage - decoded fields
    wire [6:0] id_opcode;
    wire [4:0] id_rd;
    wire [2:0] id_funct3;
    wire [4:0] id_rs1;
    wire [4:0] id_rs2;
    wire [6:0] id_funct7;
    
    // Imm value signals
    wire [31:0] id_imm_i;
    wire [31:0] id_imm_s;
    wire [31:0] id_imm_b;
    wire [31:0] id_imm_u;
    wire [31:0] id_imm_j;

    // ID stage - control signals
    wire [3:0] id_alu_op;
    wire id_alu_src;
    wire id_reg_write;
    wire id_mem_write;
    wire id_mem_read;
    wire id_mem_to_reg;
    wire id_branch;
    wire id_jump;
    wire id_jump_jal;
    wire id_jump_jalr;
    wire id_pc_to_alu;

    // ID stage - register file outputs
    wire [31:0] id_read_data1;
    wire [31:0] id_read_data2;

    // ID stage - selected immediate
    reg [31:0] id_imm_val;

    // ========================================================================
    // EX STAGE SIGNALS (outputs of ID/EX register)
    // ========================================================================
    wire [31:0] ex_pc;
    wire [31:0] ex_read_data1;
    wire [31:0] ex_read_data2;
    wire [31:0] ex_imm_val;

    // Register addresses (for hazard detection in Phase 2)
    wire [4:0] ex_rs1;
    wire [4:0] ex_rs2;
    wire [4:0] ex_rd;
    wire [2:0] ex_funct3;

    // Control signals
    wire [3:0] ex_alu_op;
    wire ex_alu_src;
    wire ex_reg_write;
    wire ex_mem_write;
    wire ex_mem_read;
    wire ex_mem_to_reg;
    wire ex_branch;
    wire ex_jump;
    wire ex_jump_jal;
    wire ex_jump_jalr;
    wire ex_pc_to_alu;

    // Computed values (EX stage logic)
    wire [31:0] ex_alu_input_a;     // ALU input A (from MUX)
    wire [31:0] ex_alu_input_b;     // ALU input B (from MUX)
    wire [31:0] ex_alu_result;      // ALU output
    wire ex_branch_taken;           // Branch decision
    wire [31:0] ex_branch_target;   // Branch target address

    wire [31:0] ex_pc_plus_4;

    // ========================================================================
    // MEM STAGE SIGNALS (outputs of EX/MEM register)
    // ========================================================================
    wire [31:0] mem_alu_result;     // ALU result forwarded from EX
    wire [31:0] mem_read_data2;     // Data to write to memory (for SW)
    wire [31:0] mem_pc_plus_4;      // PC+4 for jump return addresses

    // Register address
    wire [4:0] mem_rd;

    // Control signals
    wire mem_reg_write;
    wire mem_mem_write;
    wire mem_mem_read;
    wire mem_mem_to_reg;

    // Data memory output
    wire [31:0] mem_read_data;      // Data loaded from memory

    // ========================================================================
    // WB STAGE SIGNALS (outputs of MEM/WB register)
    // ========================================================================
    wire [31:0] wb_alu_result;      // ALU result forwarded from MEM
    wire [31:0] wb_mem_data;        // Memory data forwarded from MEM
    wire [31:0] wb_pc_plus_4;       // PC+4 forwarded from MEM

    // Register address
    wire [4:0] wb_rd;

    // Control signals
    wire wb_reg_write;
    wire wb_mem_to_reg;

    // Final writeback data (after final MUX)
    wire [31:0] wb_reg_write_data;
    
    wire [1:0] forward_a;
    wire [1:0] forward_b;

    wire stall;
    
    reg [31:0] forwarded_rdata1;
    reg [31:0] forwarded_rdata2;

    // ========================================================================
    // MODULE INSTANTIATIONS
    // ========================================================================

    // ========================================================================
    // IF: FETCH STAGE
    // ========================================================================
    program_counter pc_inst (
        .clk(clk),
        .reset(reset),
        .pc_enable(!stall),       // Always incrementing (no stalls yet)
        .next_pc(next_pc),
        .pc_out(pc_out)        // → instruction memory address
    );

    instruction_memory imem_inst (
        .address(pc_out),       // ← PC tells us where to fetch from
        .instruction(instruction) // → decoder breaks this apart
    );

    if_id if_id_instance (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        .pc(pc_out),
        .instruction(instruction),
        .id_pc(id_pc),
        .id_instruction(id_instruction)
    );

    // ========================================================================
    // ID: DECODE STAGE
    // ========================================================================

    // DECODE: Decoder splits 32-bit instruction into fields
    instruction_decoder decoder_inst (
        .instruction(id_instruction), // ← raw instruction from memory
        .opcode(id_opcode),        // → control unit (what type of instruction?)
        .rd(id_rd),                // → register file (where to write result)
        .funct3(id_funct3),        // → control unit (which operation?)
        .rs1(id_rs1),              // → register file (read first source)
        .rs2(id_rs2),              // → register file (read second source)
        .funct7(id_funct7),        // → control unit (distinguishes ADD vs SUB)
        .imm_i(id_imm_i),          // → immediate selector (I-type: ADDI, LW)
        .imm_s(id_imm_s),          // → immediate selector (S-type: SW)
        .imm_b(id_imm_b),          // → immediate selector (B-type: branches, future)
        .imm_u(id_imm_u),          // → immediate selector (U-type: LUI, future)
        .imm_j(id_imm_j)           // → immediate selector (J-type: JAL, future)
    );

    // CONTROL: Generates all control signals from instruction type
    control_unit control_inst (
        .opcode(id_opcode),        // ← what type of instruction?
        .funct3(id_funct3),        // ← which operation within that type?
        .funct7(id_funct7),        // ← distinguishes ADD vs SUB etc.
        .alu_op(id_alu_op),        // → ALU (which operation to perform)
        .alu_src(id_alu_src),      // → alu_src MUX (register or immediate?)
        .reg_write(id_reg_write),  // → register file (write result or not?)
        .mem_write(id_mem_write),  // → data memory (store to memory?)
        .mem_read(id_mem_read),    // → data memory (load from memory?)
        .mem_to_reg(id_mem_to_reg),// → mem_to_reg MUX (ALU result or memory data?)
        .branch(id_branch),        // → PC logic (future)
        .jump(id_jump),            // → PC logic (future)
        .jump_jal(id_jump_jal),
        .jump_jalr(id_jump_jalr),
        .pc_to_alu(id_pc_to_alu)
    );

    // EXECUTE: Register file reads source registers, writes result
    register_file regf_inst (
        .clk(clk),
        .reset(reset),
        .rs1(id_rs1),              // ← address of first source register
        .rs2(id_rs2),              // ← address of second source register
        .rd(wb_rd),                // ← address of destination register
        .write_data(wb_reg_write_data), // ← result to write (from mem_to_reg MUX)
        .reg_write(wb_reg_write),  // ← control signal: should we write?
        .rdata1(id_read_data1),    // → ALU input A
        .rdata2(id_read_data2)     // → ALU input B MUX / data memory write_data
    );

    id_ex id_ex_instance (
        .clk(clk),
        .reset(reset),
        .enable(!stall),
        .pc(id_pc),

        // ===== INPUTS from ID stage (id_* signals) =====
        .read_data1(id_read_data1),
        .read_data2(id_read_data2),
        .imm_val(id_imm_val),
        .rs1(id_rs1),
        .rs2(id_rs2),
        .rd(id_rd),
        .funct3(id_funct3),
        .alu_op(id_alu_op),
        .alu_src(id_alu_src),
        .reg_write(stall ? 1'b0 : id_reg_write),
        .mem_write(stall ? 1'b0 : id_mem_write),
        .mem_read(stall ? 1'b0 : id_mem_read),
        .mem_to_reg(stall ? 1'b0 : id_mem_to_reg),
        .branch(stall ? 1'b0 : id_branch),
        .jump(stall ? 1'b0 : id_jump),
        .jump_jal(stall ? 1'b0 : id_jump_jal),
        .jump_jalr(stall ? 1'b0 : id_jump_jalr),
        .pc_to_alu(stall ? 1'b0 : id_pc_to_alu),

        .ex_pc(ex_pc),
        .ex_read_data1(ex_read_data1),
        .ex_read_data2(ex_read_data2),
        .ex_imm_val(ex_imm_val),
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .ex_rd(ex_rd),
        .ex_funct3(ex_funct3),
        .ex_alu_op(ex_alu_op),
        .ex_alu_src(ex_alu_src),
        .ex_reg_write(ex_reg_write),
        .ex_mem_write(ex_mem_write),
        .ex_mem_read(ex_mem_read),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_branch(ex_branch),
        .ex_jump(ex_jump),
        .ex_jump_jal(ex_jump_jal),
        .ex_jump_jalr(ex_jump_jalr),
        .ex_pc_to_alu(ex_pc_to_alu)
    );

    // ========================================================================
    // EX: EXECUTE STAGE
    // ========================================================================

    // EXECUTE: ALU performs the operation
    alu alu_inst (
        .a(ex_alu_input_a),         // ← always comes from rs1
        .b(ex_alu_input_b),        // ← comes from alu_src MUX (register or immediate)
        .alu_op(ex_alu_op),        // ← control unit tells us which operation
        .result(ex_alu_result)     // → data memory address OR register write data
    );

    forwarding_unit forwarding_unit_instance (
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .mem_rd(mem_rd),
        .mem_reg_write(mem_reg_write),
        .wb_rd(wb_rd),
        .wb_reg_write(wb_reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    hazard_detection_unit hazard_detection_unit_instance (
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .ex_rd(ex_rd),
        .ex_mem_read(ex_mem_read),
        .stall(stall)
    );

    ex_mem ex_mem_instance (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),

        // ===== INPUTS from EX stage (ex_* signals) =====
        .alu_result(ex_alu_result),
        .read_data2(forwarded_rdata2),
        .rd(ex_rd),
        .mem_write(ex_mem_write),
        .mem_read(ex_mem_read),
        .mem_to_reg(ex_mem_to_reg),
        .reg_write(ex_reg_write),
        .pc_plus_4(ex_pc_plus_4),

        .mem_alu_result(mem_alu_result),
        .mem_read_data2(mem_read_data2),
        .mem_rd(mem_rd),
        .mem_mem_write(mem_mem_write),
        .mem_mem_read(mem_mem_read),
        .mem_mem_to_reg(mem_mem_to_reg),
        .mem_reg_write(mem_reg_write),
        .mem_pc_plus_4(mem_pc_plus_4)
    );

    // ========================================================================
    // MEM: MEMORY STAGE
    // ========================================================================

    // MEMORY: Data memory for loads and stores
    data_memory data_mem_inst (
        .clk(clk),
        .address(mem_alu_result),   // ← ALU computed base + offset address
        .write_data(mem_read_data2),// ← rs2 value (the data to store for SW)
        .mem_write(mem_mem_write),  // ← control signal: are we storing?
        .mem_read(mem_mem_read),    // ← control signal: are we loading?
        .read_data(mem_read_data) // → mem_to_reg MUX (loaded data for LW)
    );

    mem_wb mem_wb_instance (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),

        .alu_result(mem_alu_result),
        .mem_data(mem_read_data),
        .pc_plus_4(mem_pc_plus_4),
        .rd(mem_rd),
        .mem_to_reg(mem_mem_to_reg),
        .reg_write(mem_reg_write),

        .wb_alu_result(wb_alu_result),
        .wb_mem_data(wb_mem_data),
        .wb_pc_plus_4(wb_pc_plus_4),
        .wb_rd(wb_rd),
        .wb_mem_to_reg(wb_mem_to_reg),
        .wb_reg_write(wb_reg_write)
    );

    // Branch Unit
    branch_unit branch_unit_instance (
        .rdata1(forwarded_rdata1),
        .rdata2(forwarded_rdata2),
        .funct3(ex_funct3),
        .branch(ex_branch),
        .branch_taken(ex_branch_taken)
    );

    // ========================================================================
    // WB: WRITEBACK STAGE
    // ========================================================================

    assign wb_reg_write_data = (wb_mem_to_reg) ? wb_mem_data : wb_alu_result;

    // ========================================================================
    // MUX LOGIC
    // ========================================================================

    // IMMEDIATE SELECTOR: Pick the right immediate format for this instruction
    // (Different instruction types encode immediates in different bit positions)
    always @(*) begin
        case (id_opcode)
            7'b0010011: id_imm_val = id_imm_i;    // I-type arithmetic (ADDI, ORI, etc.)
            7'b0000011: id_imm_val = id_imm_i;    // I-type load (LW) - same format as above
            7'b0100011: id_imm_val = id_imm_s;    // S-type store (SW) - split immediate
            7'b0110111: id_imm_val = id_imm_u;    // U-type (LUI) - upper 20 bits
            7'b1100011: id_imm_val = id_imm_b;    // B-type
            7'b1101111: id_imm_val = id_imm_j;    // J-type JAL
            7'b1100111: id_imm_val = id_imm_i;    // JALR
            default:    id_imm_val = 32'b0;    // R-type and others don't use immediate
        endcase
    end

    // ALU SOURCE A MUX
    always @(*) begin
        case (forward_a)
            2'b10: forwarded_rdata1 = mem_alu_result;
            2'b01: forwarded_rdata1 = wb_reg_write_data;
            default: forwarded_rdata1 = ex_read_data1;
        endcase
    end

    assign ex_alu_input_a = (ex_pc_to_alu) ? ex_pc : forwarded_rdata1;

    // ALU SOURCE B MUX
    always @(*) begin
        case (forward_b)
            2'b10: forwarded_rdata2 = mem_alu_result;
            2'b01: forwarded_rdata2 = wb_reg_write_data;
            default: forwarded_rdata2 = ex_read_data2;
        endcase
    end

    assign ex_alu_input_b = (ex_alu_src) ? ex_imm_val : forwarded_rdata2;

    assign ex_branch_target = ex_pc + ex_imm_val;

    assign ex_pc_plus_4 = ex_pc + 4;

    assign next_pc = pc_out + 4;

endmodule