`timescale 1ns/1ps
`default_nettype none
module tb_spi_master_mode0;
    logic clk=0, rst_n=1, start=0, miso=0;
    logic [7:0] tx_data=0;
    wire mosi,sclk,cs_n,busy,done;
    wire [7:0] rx_data;
    integer tests=0, b;
    spi_master_mode0 #(.CLK_DIV(2)) dut(
        .clk(clk),.rst_n(rst_n),.start(start),.tx_data(tx_data),.miso(miso),
        .mosi(mosi),.sclk(sclk),.cs_n(cs_n),.busy(busy),.done(done),.rx_data(rx_data)
    );
    always #5 clk=~clk;
    task automatic ck(input logic good,input string label_text);
        begin if (good !== 1'b1) $fatal(1,"SPI_FAIL %s time=%0t",label_text,$time); tests=tests+1; end
    endtask
    task automatic transfer(input logic [7:0] sent, input logic [7:0] received);
        integer k;
        begin
            @(negedge clk); tx_data=sent; miso=received[7]; start=1;
            @(posedge clk); #1;
            ck(busy && !cs_n && !sclk,"transfer started");
            @(negedge clk); start=0;
            for(k=7;k>=0;k=k-1) begin
                @(posedge sclk); #1;
                ck(mosi===sent[k],"MOSI MSB first");
                @(negedge sclk); #1;
                if (k>0) miso=received[k-1];
            end
            ck(done && !busy && cs_n && rx_data==received,"RX, done and CS");
            @(posedge clk); #1;
            ck(!done && cs_n && !busy,"one-cycle done");
        end
    endtask
    initial begin
        $dumpfile("spi_master_mode0.vcd"); $dumpvars(0,tb_spi_master_mode0);
        #1; rst_n=1'b0;
        #2; ck(cs_n && !busy && !sclk,"async reset");
        @(negedge clk); rst_n=1;
        transfer(8'hA5,8'h3C);
        transfer(8'h00,8'hFF);
        $display("SPI_MODE0_PASS checks=%0d",tests); $finish;
    end
    initial begin #20000; $fatal(1,"SPI_TIMEOUT"); end
endmodule
`default_nettype wire
