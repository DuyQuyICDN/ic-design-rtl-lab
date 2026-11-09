`default_nettype none
// Reference model intentionally implements hold as addition by zero.
// Fixed WIDTH=4 for the Phase 3 equivalence gate.
module counter_reference (
    input wire clk,
    input wire rst_n,
    input wire enable,
    output reg [3:0] count
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 4'd0;
        else
            count <= count + (enable ? 4'd1 : 4'd0);
    end
endmodule
`default_nettype wire
