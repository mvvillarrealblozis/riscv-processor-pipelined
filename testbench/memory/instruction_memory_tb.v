`timescale 1ns/1ps

module instruction_memory_tb;
    // Inputs
    reg [31:0] address;

    // Outputs
    wire [31:0] instruction;

    instruction_memory instruction_memory_instance (
        .address(address),
        .instruction(instruction)
    );

    initial begin
        $dumpfile("instruction_memory.vcd");
        $dumpvars(0, instruction_memory_tb);

        // Test 1: Sequential Read
        address = 32'h00000000;
        #1;

        if (instruction == 32'h00500093)
            $display("First Sequential Read Test PASSED");
        else
            $display("First Sequential Read Test Failed: Got %h", instruction);

        address = 32'h00000004;
        #1;

        if (instruction == 32'h00A00113)
            $display("Second Sequential Read Test PASSED");
        else
            $display("Second Sequential Read Test Failed: Got %h", instruction);

        address = 32'h00000008;
        #1;

        if (instruction == 32'h002081B3)
            $display("Third Sequential Read Test PASSED");
        else
            $display("Third Sequential Read Test Failed: Got %h", instruction);

        address = 32'h0000000C;
        #1;

        if (instruction == 32'h40208233)
            $display("Fourth Sequential Read Test PASSED");
        else
            $display("Fourth Sequential Read Test Failed: Got %h", instruction);

        address = 32'h00000010;
        #1;

        if (instruction == 32'h0020F2B3)
            $display("Fifth Sequential Read Test PASSED");
        else
            $display("Fifth Sequential Read Test Failed: Got %h", instruction);

        $display("--------------------------------");

        // Test 2: Random Access
        address = 32'h00000008;
        #1;

        if (instruction == 32'h002081B3)
            $display("First Random Access Test PASSED");
        else
            $display("First Random Access Test Failed: Got %h", instruction);

        address = 32'h00000000;
        #1;

        if (instruction == 32'h00500093)
            $display("Second Random Access Test PASSED");
        else
            $display("Second Random Access Test Failed: Got %h", instruction);

        address = 32'h0000000C;
        #1;

        if (instruction == 32'h40208233)
            $display("Third Random Access Test PASSED");
        else
            $display("Third Random Access Test Failed: Got %h", instruction);

        $display("--------------------------------");

        // Test 3: Address Alignment
        address = 32'h00000000;
        #1;

        if (instruction == 32'h00500093)
            $display("First Address Alignment Test PASSED");
        else
            $display("First Address Alignment Test Failed: Got %h", instruction);

        address = 32'h00000004;
        #1;

        if (instruction == 32'h00A00113)
            $display("Second Address Alignment Test PASSED");
        else
            $display("Second Address Alignment Test Failed: Got %h", instruction);

        address = 32'h00000008;
        #1;

        if (instruction == 32'h002081B3)
            $display("Third Address Alignment Test PASSED");
        else
            $display("Third Address Alignment Test Failed: Got %h", instruction);

        address = 32'h0000000C;
        #1;

        if (instruction == 32'h40208233)
            $display("Fourth Address Alignment Test PASSED");
        else
            $display("Fourth Address Alignment Test Failed: Got %h", instruction);

        $display("--------------------------------");

        // Test 4: Combinational Behavior
        address = 32'h00000000;
        #1;

        repeat(5) begin
            $display("address=%h | instruction=%h", address, instruction);
            if (address < 32'h00000010) begin
                address = address + 4;
            end
            #1;
        end

        if (address == 32'h00000010 && instruction == 32'h0020f2b3)
            $display("Combinational Behavior Test PASSED");
        else
            $display("Combinational Behavior Test Failed: Got %h", instruction);

        $display("--------------------------------");

        // Test 5: Boundary Test
        address = 32'h000003FC; // Index 255 in memory array
        #1;
        
        if (instruction == 32'h00000000)
            $display("Boundary Test PASSED");
        else
            $display("Boundary Test FAILED: instruction=%h", instruction);
    end
endmodule

