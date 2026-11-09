`timescale 1ns/1ps
`default_nettype none
module tb_sync_fifo;
    logic clk=0, rst_n=1, wr_en=0, rd_en=0;
    logic [7:0] wr_data=0;
    wire [7:0] rd_data;
    wire full, empty;
    wire [2:0] used;
    integer tests=0;
    sync_fifo #(.WIDTH(8),.DEPTH(4)) dut(
        .clk(clk),.rst_n(rst_n),.wr_en(wr_en),.rd_en(rd_en),
        .wr_data(wr_data),.rd_data(rd_data),.full(full),.empty(empty),.used(used)
    );
    always #5 clk=~clk;
    task automatic ck(input logic good, input string label_text);
        begin if (good !== 1'b1) $fatal(1,"FIFO_FAIL %s time=%0t",label_text,$time); tests=tests+1; end
    endtask
    task automatic step(input logic w, input logic r, input logic [7:0] data);
        begin
            @(negedge clk); wr_en=w; rd_en=r; wr_data=data;
            @(posedge clk); #1;
        end
    endtask
    initial begin
        $dumpfile("sync_fifo.vcd"); $dumpvars(0,tb_sync_fifo);
        #1; rst_n=1'b0;
        #2; ck(empty && !full && used==0,"reset empty");
        @(negedge clk); rst_n=1;
        step(1,0,8'h11); ck(used==1,"write 1");
        step(1,0,8'h22); ck(used==2,"write 2");
        step(1,0,8'h33); ck(used==3,"write 3");
        step(1,0,8'h44); ck(full && used==4,"full");
        step(1,0,8'h99); ck(full && used==4,"overflow rejected");
        step(1,1,8'h55); ck(full && used==4 && rd_data==8'h11,"full simultaneous read/write");
        step(0,1,0); ck(used==3 && rd_data==8'h22,"read 22");
        step(0,1,0); ck(used==2 && rd_data==8'h33,"read 33");
        step(0,1,0); ck(used==1 && rd_data==8'h44,"read 44");
        step(0,1,0); ck(empty && rd_data==8'h55,"read 55");
        step(0,1,0); ck(empty && used==0 && rd_data==8'h55,"underflow rejected");
        step(1,1,8'hAB); ck(used==1,"empty simult treated as write");
        step(0,1,0); ck(empty && rd_data==8'hAB,"read AB");
        $display("SYNC_FIFO_PASS checks=%0d",tests); $finish;
    end
    initial begin #20000; $fatal(1,"FIFO_TIMEOUT"); end
endmodule
`default_nettype wire
