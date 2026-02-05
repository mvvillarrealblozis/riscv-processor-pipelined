module program_counter(
    input clk,              // Clock
    input reset,            // Reset signal
    input pc_enable,        // Enable Signal (1 = update PC, 0 = hold)
    output [31:0] pc_out    // Current PC value
);
endmodule