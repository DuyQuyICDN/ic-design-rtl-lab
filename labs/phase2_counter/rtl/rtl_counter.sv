`default_nettype none
// Phase 2 DUT: parameterized up-counter with active-low asynchronous reset.
module rtl_counter #(
    parameter integer WIDTH = 4
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             enable,
    output logic [WIDTH-1:0] count
);
    // When disabled, the FF retains its previous state.
    // WIDTH-bit arithmetic intentionally wraps modulo 2**WIDTH.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
        end else if (enable) begin
            count <= count + {{(WIDTH-1){1'b0}}, 1'b1};
        end
    end
endmodule
`default_nettype wire
