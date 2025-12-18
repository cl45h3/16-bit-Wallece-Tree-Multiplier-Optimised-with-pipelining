`timescale 1ns / 1ps

module tb_walllacetree;

    reg clk;
    reg rst;
    reg [15:0] a, b;

    wire [31:0] product;

    reg [31:0] expected;

    walllacetree dut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .product(product)
    );

    reg [15:0] test_a [0:9];
    reg [15:0] test_b [0:9];

    integer i;
    integer errors;

    always #2 clk = ~clk;

    initial begin
        test_a[0] = 16'h0000; test_b[0] = 16'h0000; // 0 * 0
        test_a[1] = 16'h0001; test_b[1] = 16'h0001; // 1 * 1
        test_a[2] = 16'h0003; test_b[2] = 16'h0004; // 3 * 4
        test_a[3] = 16'h00FF; test_b[3] = 16'h000F; // 255 * 15
        test_a[4] = 16'h0F0F; test_b[4] = 16'h00F0; // 3855 * 240
        test_a[5] = 16'hAAAA; test_b[5] = 16'h5555; // alternating bits
        test_a[6] = 16'h1234; test_b[6] = 16'h5678; // random mid values
        test_a[7] = 16'h8000; test_b[7] = 16'h0002; // 32768 * 2
        test_a[8] = 16'h7FFF; test_b[8] = 16'h7FFF; // (max-1)*(max-1)
        test_a[9] = 16'hFFFF; test_b[9] = 16'hFFFF; // max * max

        clk = 0;
        rst = 1;
        a = 0;
        b = 0;
        errors = 0;
        #20;
        rst = 0;

        $display("============================================================");
        $display("        TESTBENCH FOR WALLACE TREE (16x16) MULTIPLIER       ");
        $display("============================================================");
        $display("  # |     A (hex)     |     B (hex)     | Expected (dec) | DUT Output (dec) | Result");
        $display("------------------------------------------------------------------------------------");

        for (i = 0; i < 10; i = i + 1) begin
            @(negedge clk);
            a <= test_a[i];
            b <= test_b[i];
            expected = test_a[i] * test_b[i];
            
            repeat(12) @(posedge clk);

            if (product !== expected) begin
                $display("%2d | 0x%04h (%5d) | 0x%04h (%5d) | %10d | %10d |  FAIL",
                         i, test_a[i], test_a[i], test_b[i], test_b[i], expected, product);
                errors = errors + 1;
            end else begin
                $display("%2d | 0x%04h (%5d) | 0x%04h (%5d) | %10d | %10d | PASS",
                         i, test_a[i], test_a[i], test_b[i], test_b[i], expected, product);
            end
        end

        $display("------------------------------------------------------------------------------------");
        if (errors == 0)
            $display("All 10 test cases PASSED successfully!");
        else
            $display(" Test completed with %0d errors.", errors);
        $display("============================================================");

        $finish;
    end

endmodule
