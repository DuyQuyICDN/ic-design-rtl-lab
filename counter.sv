`timescale 1ns/1ps

// Bo dem tu 0 den 9
module counter (
    input logic clk,
    input logic rst,
    input logic en,
    output logic [3:0] q,
    output logic tc
);

    logic [3:0] q_next;

    always_comb begin
        if (q == 4'd9)
            q_next = 4'd0;
        else
            q_next = q + 4'd1;
    end

    always_ff @(posedge clk) begin
        if (rst)
            q <= 4'd0;
        else if (en)
            q <= q_next;
    end

    assign tc = (q == 4'd9);

endmodule
