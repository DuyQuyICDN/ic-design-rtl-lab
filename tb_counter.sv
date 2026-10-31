`timescale 1ns/1ps
module tb_counter;
    logic clk = 0;
    logic rst, en;
    logic [3:0] q;
    logic tc;
    logic [3:0] expected;
    int errors = 0;

    counter dut (.clk(clk), .rst(rst), .en(en), .q(q), .tc(tc));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("counter.vcd");
        $dumpvars(0, tb_counter);

        rst = 1; en = 0; expected = 4'd0;
        @(posedge clk); #1;
        rst = 0; en = 1;

        repeat (25) begin
            @(posedge clk); #1;
            expected = (expected == 4'd9) ? 4'd0 : expected + 4'd1;
            if (q !== expected) begin
                $display("LOI q: %0d, mong doi %0d", q, expected);
                errors = errors + 1;
            end
            if (tc !== (expected == 4'd9)) begin
                $display("LOI tc khi q = %0d", q);
                errors = errors + 1;
            end
        end

        if (errors == 0)
            $display("PASS: bo dem chay dung 25 chu ky");
        else
            $display("FAIL: %0d loi", errors);
        $finish;
    end
endmodule