module program_counter(
    input clk,              // Clock - PC updates on rising edge
    input reset,            // Reset signal
    input pc_enable,        // Enable Signal (1 = update PC, 0 = hold)
    input [31:0] next_pc,

    output reg [31:0] pc_out    // Current PC value
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 0;
        end else if (pc_enable) begin
                pc_out <= next_pc;
            end
    end

endmodule