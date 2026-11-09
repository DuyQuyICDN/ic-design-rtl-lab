`timescale 1ns/1ps
`default_nettype none
module tb_uart_tx;
    localparam integer CPB=4;
    logic clk=0, rst_n=1, start=0;
    logic [7:0] data_in=0;
    wire tx, ready;
    integer tests=0, i, j;
    uart_tx #(.CLKS_PER_BIT(CPB)) dut(
        .clk(clk), .rst_n(rst_n), .start(start), .data_in(data_in), .tx(tx), .ready(ready)
    );
    always #5 clk = ~clk;
    task automatic ck(input logic cond, input string label_text);
        begin if (cond !== 1'b1) $fatal(1,"UART_FAIL %s time=%0t",label_text,$time); tests=tests+1; end
    endtask
    task automatic ticks(input integer n);
        integer k;
        begin for (k=0;k<n;k=k+1) begin @(posedge clk); #1; end end
    endtask
    task automatic send(input logic [7:0] payload);
        integer b;
        begin
            @(negedge clk); start=1; data_in=payload;
            ticks(1); ck(tx===0,"start low"); ck(ready===0,"busy start");
            @(negedge clk); start=0;
            ticks(CPB); ck(tx===payload[0],"data bit 0");
            for (b=1;b<8;b=b+1) begin
                ticks(CPB); ck(tx===payload[b],"data bit");
            end
            ticks(CPB); ck(tx===1'b1,"stop high");
            ticks(CPB); ck(tx===1'b1 && ready===1'b1,"idle ready");
        end
    endtask
    initial begin
        $dumpfile("uart_tx.vcd"); $dumpvars(0,tb_uart_tx);
        #1; rst_n=1'b0;
        #2; ck(tx===1'b1,"async reset idle");
        @(negedge clk); rst_n=1;
        ticks(1); ck(ready===1,"ready after reset");
        send(8'h55); send(8'hA6); send(8'h00); send(8'hFF);
        $display("UART_TX_PASS checks=%0d",tests); $finish;
    end
    initial begin #20000; $fatal(1,"UART_TIMEOUT"); end
endmodule
`default_nettype wire
