`default_nettype none
// Single-clock FIFO, DEPTH must be power of two and >=2.
// rd_data updates on accepted read, otherwise holds previous value.
// Simultaneous read/write at full is accepted, at empty only write is accepted.
module sync_fifo #(
    parameter integer WIDTH = 8,
    parameter integer DEPTH = 4
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             wr_en,
    input  logic             rd_en,
    input  logic [WIDTH-1:0] wr_data,
    output logic [WIDTH-1:0] rd_data,
    output logic             full,
    output logic             empty,
    output logic [$clog2(DEPTH+1)-1:0] used
);
    localparam integer AW = $clog2(DEPTH);
    logic [WIDTH-1:0] mem [0:DEPTH-1];
    logic [AW-1:0] wp, rp;
    logic push_ok, pop_ok;
    assign full = used[AW];
    assign empty = (used == 0);
    assign pop_ok = rd_en && !empty;
    assign push_ok = wr_en && (!full || pop_ok);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            used <= '0; wp <= '0; rp <= '0; rd_data <= '0;
        end else begin
            if (push_ok) begin
                mem[wp] <= wr_data;
                wp <= wp + 1'b1;
            end
            if (pop_ok) begin
                rd_data <= mem[rp];
                rp <= rp + 1'b1;
            end
            case ({push_ok,pop_ok})
                2'b10: used <= used + 1'b1;
                2'b01: used <= used - 1'b1;
                default: ;
            endcase
        end
    end
endmodule
`default_nettype wire
