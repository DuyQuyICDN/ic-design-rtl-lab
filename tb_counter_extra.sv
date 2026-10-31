
`timescale 1ns/1ps

module tb_counter_extra;

    reg clk = 0;
    reg rst = 1;
    reg en = 0;

    wire [3:0] q;
    wire tc;

    reg [3:0] expected_q = 0;
    integer checks = 0;
    integer hits [0:9];
    integer seed = 12345;
    reg [31:0] random_value;
    integer i;

    counter dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .q(q),
        .tc(tc)
    );

    // Clock 10 ns
    always #5 clk = ~clk;

    // Kiem tra output
    task automatic check_outputs;
        begin
            if (q !== expected_q ||
                tc !== (expected_q == 4'd9)) begin
                $display("FAIL time=%0t", $time);
                $display("q=%0d expected=%0d",
                          q, expected_q);
                $display("tc=%b", tc);
                $fatal(1, "Verification failed");
            end
            checks = checks + 1;
        end
    endtask

    // Kiem tra mot chu ky clock
    task automatic step(
        input reg next_rst,
        input reg next_en
    );
        begin
            @(negedge clk);
            rst = next_rst;
            en = next_en;

            @(posedge clk);

            if (next_rst)
                expected_q = 0;
            else if (next_en)
                expected_q = (expected_q == 9)
                           ? 0 : expected_q + 1'b1;

            // Cho NBA cap nhat
            #1;
            check_outputs();
        end
    endtask

    initial begin

        $dumpfile("counter_extra.vcd");
        $dumpvars(0, tb_counter_extra);

        // Khoi tao bang coverage
        for (i = 0; i < 10; i = i + 1)
            hits[i] = 0;

        // Reset ban dau
        @(posedge clk);
        #1;
        check_outputs();

        repeat (3)
            step(0, 1);

        // TEST 8: Reset glitch giua hai posedge
        $display("TEST 8: RESET GLITCH");

        @(negedge clk);
        rst = 0;
        en = 0;
        #1 rst = 1;
        #1 rst = 0;
        #1 check_outputs();

        @(posedge clk);
        #1 check_outputs();

        // TEST 9: Enable glitch giua hai posedge
        $display("TEST 9: ENABLE GLITCH");

        @(negedge clk);
        rst = 0;
        en = 0;
        #1 en = 1;
        #1 en = 0;
        #1 check_outputs();

        @(posedge clk);
        #1 check_outputs();

        // TEST 10: Reset nhieu chu ky
        $display("TEST 10: MULTIPLE RESET");

        repeat (5)
            step(1, 1);

        // TEST 11: Random 200 cycles
        $display("TEST 11: RANDOM TEST");

        repeat (200) begin
            random_value = $random(seed);

            step(
                random_value[2:0] == 3'b000,
                random_value[3]
            );
        end

        // TEST 12: Long simulation
        $display("TEST 12: LONG SIMULATION");

        step(1, 0);

        repeat (1000) begin
            step(0, 1);
            hits[q] = hits[q] + 1;
        end

        // Thong ke state coverage
        $display("STATE COVERAGE:");

        for (i = 0; i < 10; i = i + 1) begin
            $display("State %0d: %0d hits",
                     i, hits[i]);

            if (hits[i] == 0)
                $fatal(1, "State not visited");
        end

        $display("==========================");
        $display("PASS: TEST 8-12");
        $display("Checks: %0d", checks);
        $display("==========================");

        $finish;
    end

endmodule
