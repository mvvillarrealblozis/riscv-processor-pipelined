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
            if (cpu_instance.regf_inst.reg_write && cpu_instance.regf_inst.rd !=  5'b0) begin
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

    // Monitors
    always @(posedge clk) begin
        if (cpu_instance.forward_a != 2'b00 || cpu_instance.forward_b != 2'b00) begin
            $display("Forwarding Detected at Cycle %t: A=%b, B=%b", 
                    $time, cpu_instance.forward_a, cpu_instance.forward_b);
        end
    end 

    always @(posedge clk) begin
        if (cpu_instance.stall) begin
            $display(">>> STALL detected at cycle %0d", cycle);
        end
    end

    always @(posedge clk) begin
        if (!reset) begin
            $display("DEBUG MEM->WB: mem_reg_write=%b, wb_reg_write=%b, mem_rd=%0d, wb_rd=%0d",
                    cpu_instance.mem_reg_write, 
                    cpu_instance.wb_reg_write,
                    cpu_instance.mem_rd,
                    cpu_instance.wb_rd);
        end
    end

    always @(posedge clk) begin
        if (cpu_instance.flush) begin
            $display(">>> FLUSH at cycle %0d, target PC=%h", cycle, cpu_instance.next_pc);
        end
    end

    // ================================
    // Test Sequence
    // ================================
    initial begin
        reset = 1;
        repeat (2) @(posedge clk);
        reset = 0;

        // load Data Memory for the LW test (Test 3)
        cpu_instance.data_mem_inst.memory[0] = 32'h00000020; // 32 decimal

        repeat (70) @(posedge clk);
        #1; 


        // Test 1: EX Hazard (x1=5, x2=15)
        $display("Test 1 (EX Hazard):  x1=%d, x2=%d (Expected: 5, 15)", 
                cpu_instance.regf_inst.rf[1], cpu_instance.regf_inst.rf[2]);

        // Test 2: MEM Hazard (x3=5, x4=15)
        $display("Test 2 (MEM Hazard): x3=%d, x4=%d (Expected: 5, 15)", 
                cpu_instance.regf_inst.rf[3], cpu_instance.regf_inst.rf[4]);

        // Test 3: Load-Use Hazard (x5=32, x6=42)
        $display("Test 3 (Load-Use):  x5=%d, x6=%d (Expected: 32, 42)", 
                cpu_instance.regf_inst.rf[5], cpu_instance.regf_inst.rf[6]);

        // Test 4: Complex Dependencies (x1=5, x2=15, x3=20)
        $display("Test 4 (Complex):   x7=%d, x8=%d, x9=%d (Expected: 5, 15, 20)", 
                cpu_instance.regf_inst.rf[7], cpu_instance.regf_inst.rf[8], cpu_instance.regf_inst.rf[9]);
        
        // Test 5: Branch Taken
        $display("Test 5 (Branch Taken): x10=%d, x11=%d, x12=%d, x13=%d, x14=%d (Expected: 5, 5, 0, 0, 10)", 
            cpu_instance.regf_inst.rf[10], 
            cpu_instance.regf_inst.rf[11],
            cpu_instance.regf_inst.rf[12],
            cpu_instance.regf_inst.rf[13],
            cpu_instance.regf_inst.rf[14]);
        
        // Test 6: Branch Not Take
        $display("Test 6 (Branch Not Taken): x15=%d, x16=%d, x17=%d, x18=%d (Expected: 5, 10, 1, 2)", 
            cpu_instance.regf_inst.rf[15],
            cpu_instance.regf_inst.rf[16],
            cpu_instance.regf_inst.rf[17],
            cpu_instance.regf_inst.rf[18]);
        
        // Test 7: JAL
        $display("Test 7 (JAL): x25=%h, x19=%d, x20=%d, x21=%d (Expected: 0x74, 0, 0, 10)", 
            cpu_instance.regf_inst.rf[25],
            cpu_instance.regf_inst.rf[19],
            cpu_instance.regf_inst.rf[20],
            cpu_instance.regf_inst.rf[21]);

        // Test 8: JALR
        $display("Test 8 (JALR): x25=%h, x22=%d, x23=%d, x24=%d (Expected: 0x88, 16, 0, 10)", 
            cpu_instance.regf_inst.rf[25],
            cpu_instance.regf_inst.rf[22],
            cpu_instance.regf_inst.rf[23],
            cpu_instance.regf_inst.rf[24]);

        // Final Pass/Fail Check
        if (cpu_instance.regf_inst.rf[1] == 32'd5 && 
            cpu_instance.regf_inst.rf[2] == 32'd15 &&
            cpu_instance.regf_inst.rf[3] == 32'd5 &&
            cpu_instance.regf_inst.rf[4] == 32'd15 &&
            cpu_instance.regf_inst.rf[5] == 32'd32 &&
            cpu_instance.regf_inst.rf[6] == 32'd42 &&
            cpu_instance.regf_inst.rf[7] == 32'd5 &&
            cpu_instance.regf_inst.rf[8] == 32'd15 &&
            cpu_instance.regf_inst.rf[9] == 32'd20 &&
            cpu_instance.regf_inst.rf[10] == 32'd5 &&
            cpu_instance.regf_inst.rf[11] == 32'd5 &&
            cpu_instance.regf_inst.rf[12] == 32'd0 &&
            cpu_instance.regf_inst.rf[13] == 32'd0 &&
            cpu_instance.regf_inst.rf[14] == 32'd10 &&
            cpu_instance.regf_inst.rf[15] == 32'd5 &&
            cpu_instance.regf_inst.rf[16] == 32'd10 &&
            cpu_instance.regf_inst.rf[17] == 32'd1 &&
            cpu_instance.regf_inst.rf[18] == 32'd2 &&
            cpu_instance.regf_inst.rf[19] == 32'd0 &&
            cpu_instance.regf_inst.rf[20] == 32'd0 &&
            cpu_instance.regf_inst.rf[21] == 32'd10 &&
            cpu_instance.regf_inst.rf[22] == 32'd16 &&
            cpu_instance.regf_inst.rf[23] == 32'd0 &&
            cpu_instance.regf_inst.rf[24] == 32'd10 &&
            cpu_instance.regf_inst.rf[25] == 32'h88)
            $display("\nALL TESTS PASSED");
        else
            $display("\nTESTS FAILED - Check Waveforms for Forwarding/Stall issues.");

        $finish;
    end

endmodule