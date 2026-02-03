module register_file (
    input clk,
    input reset,
    input [4:0] rs1,             // Read register 1 (5 bits = 0-31)
    input [4:0] rs2,             // Read register 2
    input [4:0] rd,              // Write register
    input [31:0] write_data,     // Data to write
    input reg_write,             // Write enable
    output [31:0] rdata1,        // Data from rs1
    output [31:0] rdata2         // Data from rs2
);  
    // Create a 2D array: rf[32 entries][32 bits wide]
    reg [31:0] rf [31:0];
    integer i;

    /*
    If address_1 == 0: 
    Return 32-bits of zeros Else: Return the value inside rf[address_1]
    */
    assign rdata1 = (rs1 == 5'b0) ? 32'b0 : rf[rs1];
    assign rdata2 = (rs2 == 5'b0) ? 32'b0 : rf[rs2];

    /*
    On the Rising Edge of Clock or Reset Signal: 
    If Reset is Active: Set all 32 boxes in rf to 0 
    Else If reg_write is TRUE AND destination_address is NOT 0: 
    Take the data from write_data and put it into rf[destination_address]
    */
    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            for (i = 0; i < 32; i = i + 1)
                rf[i] <= 32'b0;
        end else if (reg_write && rd != 5'b0) begin
            rf[rd] <= write_data;    
        end
    end
endmodule