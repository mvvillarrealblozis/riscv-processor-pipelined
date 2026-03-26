module control_unit (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,

    output reg [3:0] alu_op,        // ALU op select
    output reg alu_src,             // ALU source: 0=register, 1=imm
    output reg reg_write,           // Register file write enable
    output reg mem_write,           // Memory write enable
    output reg mem_read,            // Memory read enable
    output reg mem_to_reg,          // Register write data: 0=ALU, 1=memory
    output reg branch,              // Branch
    output reg jump,                // Jump (for pc)
    output reg jump_jal,            // JAL
    output reg jump_jalr,           // JALR
    output reg pc_to_alu
);

    always @(*) begin
        alu_op = 4'b0000;
        alu_src = 0;
        reg_write = 0;
        mem_write = 0;
        mem_read = 0;
        mem_to_reg = 0;
        branch = 0;
        jump = 0;
        jump_jal = 0;
        jump_jalr = 0;
        pc_to_alu = 0;

        case(opcode) 
            // R-Type Instructions
            7'b0110011: begin
                // Set R-Type Signals
                alu_src = 0;
                reg_write = 1;
                mem_to_reg = 0;
                
                // Determine ALU operation
                case(funct3)
                    3'b000: begin
                        if (funct7 == 7'b0000000)
                            alu_op = 4'b0000;   // ADD
                        else if (funct7 == 7'b0100000)
                            alu_op = 4'b0001;   // SUB
                    end
                    3'b111: alu_op = 4'b0010;   // AND
                    3'b110: alu_op = 4'b0011;   // OR
                    3'b100: alu_op = 4'b0100;   // XOR
                    //3'b010: alu_op = 4'b0101;   // SLT
                    //3'b011: alu_op = 4'b0110;   // SLTU
                    //3'b001: alu_op = 4'b0111;   // SLL
                    //3'b101: alu_op = 4'b1000;   // SRL
                    default: alu_op = 4'b0000;
                endcase
            end
            
            // I-type Instructions
            7'b0010011: begin
                alu_src = 1;
                reg_write = 1;

                case (funct3) 
                    3'b000: alu_op = 4'b0000;   // ADDI
                    3'b111: alu_op = 4'b0010;   // ANDI
                    3'b110: alu_op = 4'b0011;   // ORI
                    3'b100: alu_op = 4'b0100;   // XORI
                    default: alu_op = 4'b0000;
                endcase
            end
            
            // Load Word
            7'b0000011: begin
                alu_src = 1;
                reg_write = 1;
                mem_read = 1;
                mem_to_reg = 1;

                case (funct3) 
                    3'b010: alu_op = 4'b0000;
                    default: alu_op = 4'b0000;
                endcase
            end

            // Store Word
            7'b0100011: begin
                mem_write = 1;
                alu_src = 1;

                case (funct3)
                    3'b010: alu_op = 4'b0000;
                    default: alu_op = 4'b0000;
                endcase
            end

            // Branch Instructions
            7'b1100011: begin
                alu_op = 4'b0001;
                branch = 1;
            end
            
            // JAL
            7'b1101111: begin
                reg_write = 1;
                jump = 1;
                jump_jal = 1;
                pc_to_alu = 1;
                alu_src = 1;
            end

            // JALR
            7'b1100111: begin
                reg_write = 1;
                jump = 1;
                jump_jalr = 1;
                alu_src = 1;
                pc_to_alu = 0;
                case(funct3)
                    3'b000: alu_op = 4'b0000;
                    default: alu_op = 4'b0000;
                endcase
            end

            default: begin
                alu_op = 4'b0000;
                alu_src = 0;
                reg_write = 0;
                mem_write = 0;
                mem_read = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 0;
                jump_jal = 0;
                jump_jalr = 0;
                pc_to_alu = 0;
            end
        endcase
    end
endmodule