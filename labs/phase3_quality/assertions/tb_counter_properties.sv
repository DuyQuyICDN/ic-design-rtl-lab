`timescale 1ns/1ps
`default_nettype none
module tb_counter_properties;
    reg clk = 1'b0;
    reg rst_n = 1'b1;
    reg enable = 1'b0;
    wire [3:0] count;
    reg [3:0] expected = 4'd0;
    integer i, checks = 0;
    rtl_counter #(.WIDTH(4)) dut (.clk(clk), .rst_n(rst_n), .enable(enable), .count(count));
    always #5 clk = ~clk;
    initial begin
        // Assert asynchronously (not at a clock edge).
        #2; rst_n = 1'b0;
        #1;
        assert (count === 4'd0) else $fatal(1, "ASSERT_FAIL asynchronous reset");
        checks = checks + 1;
        @(negedge clk); enable = 1'b0; rst_n = 1'b1;
        // Test each update after NBA settlement (#1), not in the active event region.
        for (i = 0; i < 256; i = i + 1) begin
            @(negedge clk);
            enable = ((i % 7) != 0);
            if (enable) expected = expected + 4'd1;
            @(posedge clk); #1;
            assert (count === expected) else
              $fatal(1, "ASSERT_FAIL cycle %0d expected=%0d actual=%0d", i, expected, count);
            checks = checks + 1;
        end
        // Reset again from a nonzero state and verify off-edge response.
        @(negedge clk); enable = 1'b0;
        #2; rst_n = 1'b0; #1;
        assert (count === 4'd0) else $fatal(1, "ASSERT_FAIL reset from nonzero");
        checks = checks + 1;
        $display("ASSERT_PASS checks=%0d", checks);
        $finish;
    end
    initial begin #10000; $fatal(1, "ASSERT_FAIL timeout"); end
endmodule
`default_nettype wire
