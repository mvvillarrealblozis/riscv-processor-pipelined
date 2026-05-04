module hazard_detection_unit (
    // ID Stage inputs
    input [4:0] id_rs1,
    input [4:0] id_rs2,

    // EX stage inputs
    input [4:0] ex_rd,
    input ex_mem_read,

    // Control output 1 = stall 
    output reg stall
);
    always @(*)
        if (ex_mem_read && ex_rd != 0 && (ex_rd == id_rs1 || ex_rd == id_rs2)) begin
            stall = 1;
        end else
            stall = 0;
    
endmodule