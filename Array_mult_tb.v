`timescale 1ns / 1ps

module tb_mult16x16;

    reg [15:0] a, b;

    wire [31:0] out;

    reg [31:0] expected;

    mult16x16 dut (
        .a(a),
        .b(b),
        .out(out)
    );

    integer i;
    integer errors;

   
    reg [31:0] test_vectors_a [0:9];
    reg [31:0] test_vectors_b [0:9];

    initial begin
        
        test_vectors_a[0] = 16'h0000; test_vectors_b[0] = 16'h0000; // 0 * 0
        test_vectors_a[1] = 16'h0001; test_vectors_b[1] = 16'h0001; // 1 * 1
        test_vectors_a[2] = 16'h0003; test_vectors_b[2] = 16'h0004; // 3 * 4
        test_vectors_a[3] = 16'h00FF; test_vectors_b[3] = 16'h000F; // 255 * 15
        test_vectors_a[4] = 16'h0F0F; test_vectors_b[4] = 16'h00F0; // 3855 * 240
        test_vectors_a[5] = 16'hAAAA; test_vectors_b[5] = 16'h5555; // alternating bits
        test_vectors_a[6] = 16'h1234; test_vectors_b[6] = 16'h5678; // random mid values
        test_vectors_a[7] = 16'h8000; test_vectors_b[7] = 16'h0002; // 32768 * 2
        test_vectors_a[8] = 16'h7FFF; test_vectors_b[8] = 16'h7FFF; // (max-1)*(max-1)
        test_vectors_a[9] = 16'hFFFF; test_vectors_b[9] = 16'hFFFF; // 65535 * 65535 (max case)

        errors = 0;

        $display("==============================================");
        $display("         TESTBENCH FOR mult16x16 MODULE       ");
        $display("==============================================");
        $display("   # |       A (hex)      |       B (hex)      | Expected (dec) |  DUT Out (dec) | Result");
        $display("------------------------------------------------------------------------------------------");

        for (i = 0; i < 10; i = i + 1) begin
            a = test_vectors_a[i];
            b = test_vectors_b[i];
            #5; 

            expected = a * b;

            if (out !== expected) begin
                $display("%3d |  0x%04h (%5d) | 0x%04h (%5d) | %10d | %10d | FAIL",
                          i, a, a, b, b, expected, out);
                errors = errors + 1;
            end else begin
                $display("%3d |  0x%04h (%5d) | 0x%04h (%5d) | %10d | %10d | PASS",
                          i, a, a, b, b, expected, out);
            end
        end

        $display("------------------------------------------------------------------------------------------");
        if (errors == 0)
            $display("All 10 test cases PASSED successfully!");
        else
            $display("Test completed with %0d errors.", errors);
        $display("==============================================");

        $finish;
    end

endmodule
