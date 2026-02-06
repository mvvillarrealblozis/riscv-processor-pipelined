module program_counter(
    input clk,              // Clock - PC updates on rising edge
    input reset,            // Reset signal
    input pc_enable,        // Enable Signal (1 = update PC, 0 = hold)
    output reg [31:0] pc_out    // Current PC value
);
    // needs to reset to 0 when reset is called
    // increment by 4 each clock cycle
    // hold its value when its not in use
    // output current PC value 

    always @(posedge clk or posedge reset) begin
        // Reset behavior
        if (reset) begin
            pc_out <= 0;
        end else if (pc_enable) begin
            pc_out <= pc_out + 32'h00000004;
        end
    end

endmodule