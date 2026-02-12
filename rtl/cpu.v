module cpu(
    input clk,
    input reset
);
    // ─── FETCH STAGE ────────────────────────────────────────────────────────
    wire [31:0] pc_out;         // Current instruction address → instruction memory
    wire [31:0] instruction;    // Raw 32-bit instruction → decoder

    // ─── DECODED FIELDS (from decoder → control unit + register file) ────────
    wire [6:0] opcode;          // Instruction type → control unit
    wire [4:0] rd;              // Destination register address → register file write port
    wire [2:0] funct3;          // Sub-operation code → control unit
    wire [4:0] rs1;             // Source register 1 address → register file read port 1
    wire [4:0] rs2;             // Source register 2 address → register file read port 2
    wire [6:0] funct7;          // Sub-operation code (R-type) → control unit

    // ─── IMMEDIATE VALUES (from decoder → immediate selector) ────────────────
    wire [31:0] imm_i;          // I-type immediate (ADDI, LW, etc.)
    wire [31:0] imm_s;          // S-type immediate (SW)
    wire [31:0] imm_b;          // B-type immediate (branches - future)
    wire [31:0] imm_u;          // U-type immediate (LUI - future)
    wire [31:0] imm_j;          // J-type immediate (JAL - future)
    
    // ─── CONTROL SIGNALS (from control unit → all other modules) ─────────────
    wire [3:0] alu_op;          // Tells ALU which operation to perform
    wire alu_src;               // 0=use register rs2, 1=use immediate
    wire reg_write;             // 1=write result to register file
    wire mem_write;             // 1=write to data memory (SW)
    wire mem_read;              // 1=read from data memory (LW)
    wire mem_to_reg;            // 0=write ALU result to reg, 1=write memory data to reg
    wire branch;                // 1=branch instruction (future)
    wire jump;                  // 1=jump instruction (future)

    // ─── REGISTER FILE DATA ──────────────────────────────────────────────────
    wire [31:0] read_data1;     // Value of rs1 → ALU input A
    wire [31:0] read_data2;     // Value of rs2 → ALU input B (R-type) or data memory write (SW)

    // ─── ALU SIGNALS ─────────────────────────────────────────────────────────
    wire [31:0] alu_input_b;    // Second ALU operand (after alu_src MUX)
    wire [31:0] alu_result;     // ALU output → data memory address OR register write data

    // ─── IMMEDIATE SELECTOR ──────────────────────────────────────────────────
    reg [31:0] imm_val;         // Correct immediate for current instruction type → alu_src MUX

    // ─── MEMORY / WRITEBACK ──────────────────────────────────────────────────
    wire [31:0] mem_read_data;  // Data loaded from memory (LW) → mem_to_reg MUX
    wire [31:0] reg_write_data; // Final data to write to register (after mem_to_reg MUX)

    // ════════════════════════════════════════════════════════════════════════
    // MODULE INSTANTIATIONS
    // ════════════════════════════════════════════════════════════════════════

    // FETCH: PC holds current address, increments by 4 each cycle
    program_counter pc_inst (
        .clk(clk),
        .reset(reset),
        .pc_enable(1'b1),       // Always incrementing (no stalls yet)
        .pc_out(pc_out)         // → instruction memory address
    );

    // FETCH: Instruction memory outputs instruction at current PC address
    instruction_memory imem_inst (
        .address(pc_out),       // ← PC tells us where to fetch from
        .instruction(instruction) // → decoder breaks this apart
    );

    // DECODE: Decoder splits 32-bit instruction into fields
    instruction_decoder decoder_inst (
        .instruction(instruction), // ← raw instruction from memory
        .opcode(opcode),        // → control unit (what type of instruction?)
        .rd(rd),                // → register file (where to write result)
        .funct3(funct3),        // → control unit (which operation?)
        .rs1(rs1),              // → register file (read first source)
        .rs2(rs2),              // → register file (read second source)
        .funct7(funct7),        // → control unit (distinguishes ADD vs SUB)
        .imm_i(imm_i),          // → immediate selector (I-type: ADDI, LW)
        .imm_s(imm_s),          // → immediate selector (S-type: SW)
        .imm_b(imm_b),          // → immediate selector (B-type: branches, future)
        .imm_u(imm_u),          // → immediate selector (U-type: LUI, future)
        .imm_j(imm_j)           // → immediate selector (J-type: JAL, future)
    );

    // CONTROL: Generates all control signals from instruction type
    control_unit control_inst (
        .opcode(opcode),        // ← what type of instruction?
        .funct3(funct3),        // ← which operation within that type?
        .funct7(funct7),        // ← distinguishes ADD vs SUB etc.
        .alu_op(alu_op),        // → ALU (which operation to perform)
        .alu_src(alu_src),      // → alu_src MUX (register or immediate?)
        .reg_write(reg_write),  // → register file (write result or not?)
        .mem_write(mem_write),  // → data memory (store to memory?)
        .mem_read(mem_read),    // → data memory (load from memory?)
        .mem_to_reg(mem_to_reg),// → mem_to_reg MUX (ALU result or memory data?)
        .branch(branch),        // → PC logic (future)
        .jump(jump)             // → PC logic (future)
    );

    // EXECUTE: Register file reads source registers, writes result
    register_file regf_inst (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),              // ← address of first source register
        .rs2(rs2),              // ← address of second source register
        .rd(rd),                // ← address of destination register
        .write_data(reg_write_data), // ← result to write (from mem_to_reg MUX)
        .reg_write(reg_write),  // ← control signal: should we write?
        .rdata1(read_data1),    // → ALU input A
        .rdata2(read_data2)     // → ALU input B MUX / data memory write_data
    );

    // EXECUTE: ALU performs the operation
    alu alu_inst (
        .a(read_data1),         // ← always comes from rs1
        .b(alu_input_b),        // ← comes from alu_src MUX (register or immediate)
        .alu_op(alu_op),        // ← control unit tells us which operation
        .result(alu_result)     // → data memory address OR register write data
    );

    // MEMORY: Data memory for loads and stores
    data_memory data_mem_inst (
        .clk(clk),
        .address(alu_result),   // ← ALU computed base + offset address
        .write_data(read_data2),// ← rs2 value (the data to store for SW)
        .mem_write(mem_write),  // ← control signal: are we storing?
        .mem_read(mem_read),    // ← control signal: are we loading?
        .read_data(mem_read_data) // → mem_to_reg MUX (loaded data for LW)
    );

    // ════════════════════════════════════════════════════════════════════════
    // MUX LOGIC
    // ════════════════════════════════════════════════════════════════════════

    // IMMEDIATE SELECTOR: Pick the right immediate format for this instruction
    // (Different instruction types encode immediates in different bit positions)
    always @(*) begin
        case (opcode)
            7'b0010011: imm_val = imm_i;    // I-type arithmetic (ADDI, ORI, etc.)
            7'b0000011: imm_val = imm_i;    // I-type load (LW) - same format as above
            7'b0100011: imm_val = imm_s;    // S-type store (SW) - split immediate
            7'b0110111: imm_val = imm_u;    // U-type (LUI) - upper 20 bits
            default:    imm_val = 32'b0;    // R-type and others don't use immediate
        endcase
    end

    // ALU SOURCE MUX: Choose second ALU operand
    // R-type: ALU operates on two registers (rs1 op rs2)
    // I-type / Load / Store: ALU operates on register + immediate (rs1 + imm)
    assign alu_input_b = (alu_src) ? imm_val : read_data2;

    // WRITEBACK MUX: Choose what data to write back to register file
    // Arithmetic: write ALU result (e.g. result of ADD, SUB)
    // Load:       write data loaded from memory (LW reads from memory, not ALU)
    assign reg_write_data = (mem_to_reg) ? mem_read_data : alu_result;

endmodule