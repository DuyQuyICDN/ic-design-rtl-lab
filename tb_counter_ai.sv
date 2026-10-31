
`timescale 1ns/1ps

module tb_counter_ai;

    // 1. Tin hieu cua DUT
    logic clk;
    logic rst;
    logic en;
    logic [3:0] q;
    logic tc;

    // 2. Scoreboard
    logic [3:0] expected_q;
    logic expected_tc;

    integer test_count = 0;

    // 3. Ket noi DUT
    counter dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .q(q),
        .tc(tc)
    );

    // 4. Clock chu ky 10 ns
    initial clk = 0;
    always #5 clk = ~clk;

    // 5. Mot buoc kiem tra
    task automatic check_step(
        input logic next_rst,
        input logic next_en
    );
        begin
            // Thay doi input o canh xuong
            @(negedge clk);
            rst = next_rst;
            en  = next_en;

            // Cho DUT cap nhat tai canh len
            @(posedge clk);

            // Tinh gia tri mong doi
            if (next_rst)
                expected_q = 4'd0;
            else if (next_en) begin
                if (expected_q == 4'd9)
                    expected_q = 4'd0;
                else
                    expected_q = expected_q + 4'd1;
            end

            expected_tc = (expected_q == 4'd9);

            // Cho nonblocking assignment cap nhat
            #1;

            test_count = test_count + 1;

            // So sanh ket qua
            if (q !== expected_q ||
                tc !== expected_tc) begin

                $display("FAIL at %0t ns", $time);
                $display("q=%0d, expected=%0d",
                         q, expected_q);
                $display("tc=%b, expected_tc=%b",
                         tc, expected_tc);

                $fatal(1, "TEST FAILED");
            end
        end
    endtask

    // 6. Chuong trinh kiem tra
    initial begin
        rst = 1;
        en  = 0;

        expected_q  = 4'd0;
        expected_tc = 1'b0;

        $dumpfile("counter_ai.vcd");
        $dumpvars(0, tb_counter_ai);

        // Test 1: Reset dong bo
        $display("TEST 1: RESET");
        check_step(1, 0);

        // Test 2: Dem 25 chu ky
        $display("TEST 2: COUNT 25 CYCLES");
        repeat (25)
            check_step(0, 1);

        // Test 3: Enable = 0, giu gia tri
        $display("TEST 3: ENABLE HOLD");
        repeat (5)
            check_step(0, 0);

        // Test 4: Dem den 9
        $display("TEST 4: TERMINAL COUNT");
        repeat (4)
            check_step(0, 1);

        // Giu q = 9, tc phai bang 1
        repeat (2)
            check_step(0, 0);

        // Test 5: Chuyen 9 ve 0
        $display("TEST 5: WRAP AROUND");
        check_step(0, 1);

        // Test 6: Reset uu tien hon enable
        $display("TEST 6: RESET PRIORITY");
        check_step(1, 1);

        // Test 7: Kiem tra sau reset
        $display("TEST 7: COUNT AFTER RESET");
        repeat (10)
            check_step(0, 1);

        $display("============================");
        $display("PASS: ALL TESTS COMPLETED");
        $display("Total checked steps: %0d",
                 test_count);
        $display("============================");

        $finish;
    end

endmodule
