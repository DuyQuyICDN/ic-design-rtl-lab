`timescale 1ns/1ps
`default_nettype none
module tb_rtl_counter;
    localparam integer WIDTH = 4;
    logic clk = 1'b0;
    logic rst_n;
    logic enable;
    logic [WIDTH-1:0] count;
    logic [WIDTH-1:0] expected;
    integer checks = 0;
    integer i;

    rtl_counter #(.WIDTH(WIDTH)) dut (
        .clk(clk), .rst_n(rst_n), .enable(enable), .count(count)
    );

    always #5 clk = ~clk;

    task automatic check_count(
        input logic [WIDTH-1:0] want,
        input string test_label
    );
        begin
            checks = checks + 1;
            if (count !== want) begin
                $display("TEST_FAIL: %s expected=%0d actual=%0d at %0t",
                         test_label, want, count, $time);
                $fatal(1, "Counter mismatch");
            end
        end
    endtask

    task automatic tick(
        input logic new_enable,
        input logic [WIDTH-1:0] want,
        input string test_label
    );
        begin
            @(negedge clk);
            enable = new_enable;
            @(posedge clk);
            #1;  // Check after nonblocking assignment update.
            check_count(want, test_label);
        end
    endtask

    initial begin
        $dumpfile("counter.vcd");
        $dumpvars(0, tb_rtl_counter);
        rst_n = 1'b1;
        enable = 1'b0;
        expected = '0;

        // Assert reset between clock edges; Q must clear without a clock edge.
        #2;
        rst_n = 1'b0;
        #1;
        check_count('0, "initial asynchronous reset");
        @(negedge clk);
        rst_n = 1'b1;

        // Exhaustively exercise all 16 values, including 15 -> 0 rollover.
        for (i = 1; i <= 16; i = i + 1) begin
            expected = expected + 1'b1;
            tick(1'b1, expected, "increment and rollover");
        end

        // Build a non-zero state, then hold it while enable=0.
        expected = expected + 1'b1;
        tick(1'b1, expected, "increment after rollover");
        tick(1'b0, expected, "hold when disabled 1");
        tick(1'b0, expected, "hold when disabled 2");

        // Reset while Q is nonzero, not at a clock edge.
        #2;
        rst_n = 1'b0;
        #1;
        expected = '0;
        check_count(expected, "asynchronous reset while nonzero");
        tick(1'b1, expected, "reset overrides enable");
        @(negedge clk);
        // Disable counting before releasing reset. Otherwise the next
        // posedge increments Q before the mixed-regression scoreboard starts.
        enable = 1'b0;
        rst_n = 1'b1;

        // Deterministic mixed enable/hold regression.
        for (i = 0; i < 64; i = i + 1) begin
            if ((i % 3) == 0) begin
                tick(1'b0, expected, "mixed hold");
            end else begin
                expected = expected + 1'b1;
                tick(1'b1, expected, "mixed increment");
            end
        end

        $display("TEST_PASS: tb_rtl_counter checks=%0d", checks);
        $finish;
    end

    initial begin
        #5000;
        $fatal(1, "TEST_FAIL: simulation timeout");
    end
endmodule
`default_nettype wire
