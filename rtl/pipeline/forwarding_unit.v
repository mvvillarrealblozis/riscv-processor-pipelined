module forwarding_unit (
    // EX stage inputs
    input [4:0] ex_rs1,
    input [4:0] ex_rs2,

    // MEM stage inputs
    input [4:0] mem_rd,
    input mem_reg_write,

    // WB stage inputs
    input [4:0] wb_rd,
    input wb_reg_write,

    // forward_a:
    //     00 = Use register file (id_read_data1) - no hazard
    //     01 = Forward from WB stage (wb_reg_write_data) - MEM hazard
    //     10 = Forward from MEM stage (mem_alu_result) - EX hazard

    // forward_b:
    //     00 = Use register file (id_read_data2) - no hazard
    //     01 = Forward from WB stage (wb_reg_write_data) - MEM hazard
    //     10 = Forward from MEM stage (mem_alu_result) - EX hazard
    // Forwarding control outputs
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);

    always @(*) begin
        if (mem_reg_write && mem_rd == ex_rs1 && mem_rd != 0) begin
            forward_a = 2'b10;
        end else if (wb_reg_write && wb_rd == ex_rs1 && wb_rd != 0) begin
            forward_a = 2'b01;
        end else begin
            forward_a = 2'b00;
        end

        if (mem_reg_write && mem_rd == ex_rs2 && mem_rd != 0) begin
            forward_b = 2'b10;
        end else if (wb_reg_write && wb_rd == ex_rs2 && wb_rd != 0) begin
            forward_b = 2'b01;
        end else begin
            forward_b = 2'b00;
        end
    end
endmodule
