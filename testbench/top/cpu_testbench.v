`timescale 1ns/1ps

module cpu_testbench;

    reg clk;
    reg reset;

    integer cycle;

    cpu cpu_instance (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    always @(posedge clk) begin
        if (reset)
            cycle <= 0;
        else
            cycle <= cycle + 1;
    end

    initial begin
        $dumpfile("cpu_testbench.vcd");
        $dumpvars(0, cpu_testbench);
    end

    // ================================
    // Pipeline Trace (every cycle)
    // ================================
    always @(posedge clk) begin
        if (!reset) begin
            $display("============================================================");
            $display("Cycle %0d: stall=%b, id_reg_write=%b, ex_reg_write=%b, mem_reg_write=%b, wb_reg_write=%b",
        cycle, cpu_instance.stall, cpu_instance.id_reg_write, cpu_instance.ex_reg_write, cpu_instance.mem_reg_write, cpu_instance.wb_reg_write);
            
        // ================= IF =================
            $display("IF  : PC=%h INST=%h",
                cpu_instance.pc_inst.pc_out,
                cpu_instance.if_id_instance.id_instruction
            );

            // ================= ID =================
            $display("ID  : PC=%h rs1=%0d rs2=%0d rd=%0d imm=%h | r1=%h r2=%h",
                cpu_instance.id_ex_instance.ex_pc,
                cpu_instance.id_ex_instance.ex_rs1,
                cpu_instance.id_ex_instance.ex_rs2,
                cpu_instance.id_ex_instance.ex_rd,
                cpu_instance.id_ex_instance.ex_imm_val,
                cpu_instance.id_ex_instance.ex_read_data1,
                cpu_instance.id_ex_instance.ex_read_data2
            );

            $display("      CTRL: alu_op=%b alu_src=%b regW=%b memW=%b memR=%b mem2reg=%b br=%b j=%b jal=%b jalr=%b",
                cpu_instance.id_ex_instance.ex_alu_op,
                cpu_instance.id_ex_instance.ex_alu_src,
                cpu_instance.id_ex_instance.ex_reg_write,
                cpu_instance.id_ex_instance.ex_mem_write,
                cpu_instance.id_ex_instance.ex_mem_read,
                cpu_instance.id_ex_instance.ex_mem_to_reg,
                cpu_instance.id_ex_instance.ex_branch,
                cpu_instance.id_ex_instance.ex_jump,
                cpu_instance.id_ex_instance.ex_jump_jal,
                cpu_instance.id_ex_instance.ex_jump_jalr
            );

            // ================= EX =================
            $display("EX  : ALU=%h rd=%0d | regW=%b memW=%b memR=%b mem2reg=%b",
                cpu_instance.ex_mem_instance.mem_alu_result,
                cpu_instance.ex_mem_instance.mem_rd,
                cpu_instance.ex_mem_instance.mem_reg_write,
                cpu_instance.ex_mem_instance.mem_mem_write,
                cpu_instance.ex_mem_instance.mem_mem_read,
                cpu_instance.ex_mem_instance.mem_mem_to_reg
            );

            // ================= MEM =================
            $display("MEM : ALU=%h MEM_DATA=%h rd=%0d | regW=%b mem2reg=%b",
                cpu_instance.mem_wb_instance.wb_alu_result,
                cpu_instance.mem_wb_instance.wb_mem_data,
                cpu_instance.mem_wb_instance.wb_rd,
                cpu_instance.mem_wb_instance.wb_reg_write,
                cpu_instance.mem_wb_instance.wb_mem_to_reg
            );

            // ================= WB =================
            if (cpu_instance.regf_inst.reg_write) begin
                $display("WB  : WRITE x%0d = %h",
                    cpu_instance.regf_inst.rd,
                    cpu_instance.regf_inst.write_data
                );
            end else begin
                $display("WB  : ---");
            end

            $display("============================================================\n");
        end
    end

    // // ================================
    // // Writeback Monitor
    // // ================================
    // always @(posedge clk) begin
    //     if (!reset && cpu_instance.regf_inst.reg_write) begin
    //         $display(">>> WB: x%0d = %h",
    //             cpu_instance.regf_inst.rd,
    //             cpu_instance.regf_inst.write_data
    //         );
    //     end
    // end

    // Forward Monitor
    always @(posedge clk) begin
        if (cpu_instance.forward_a != 2'b00 || cpu_instance.forward_b != 2'b00) begin
            $display("Forwarding Detected at Cycle %t: A=%b, B=%b", 
                    $time, cpu_instance.forward_a, cpu_instance.forward_b);
        end
    end

    // ================================
    // Test Sequence
    // ================================
    initial begin
        reset = 1;
        repeat (2) @(posedge clk);
        reset = 0;

        cpu_instance.data_mem_inst.memory[0] = 32'h00000020; // 32 in decimal
        
        repeat (20) @(posedge clk);
        #1;

        // if (cpu_instance.regf_inst.rf[1] == 32'h5 && cpu_instance.regf_inst.rf[2] == 32'h0F)
        //     $display("Stall Test PASSED: x1=5, x2=15");
        // else
        //     $display("Stall Test FAILED: x1=%h, x2=%h", 
        //         cpu_instance.regf_inst.rf[1], cpu_instance.regf_inst.rf[2]);

        // LW x1, 0(x0) -> x1 = 32
        // ADDI x2, x1, 10 -> x2 = 42 (32 + 10)
        $display("x1: %h (Expected: 00000020)", cpu_instance.regf_inst.rf[1]);
        $display("x2: %h (Expected: 0000002a)", cpu_instance.regf_inst.rf[2]);

        if (cpu_instance.regf_inst.rf[2] == 32'h2a)
            $display("Load-Use Test PASSED!");
        else
            $display("Load-Use Test FAILED!");
        $finish;
    end

endmodule