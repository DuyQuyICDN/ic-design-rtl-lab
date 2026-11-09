`default_nettype none
// Educational UART transmitter, 8 data bits, no parity, 1 stop bit (8N1).
// start is sampled only when ready=1. LSB transmitted first.
module uart_tx #(
    parameter integer CLKS_PER_BIT = 4
) (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    input  logic [7:0] data_in,
    output logic       tx,
    output logic       ready
);
    localparam integer CW = (CLKS_PER_BIT > 1) ? $clog2(CLKS_PER_BIT) : 1;
    localparam logic [31:0] CPB_LAST_32 = CLKS_PER_BIT - 1;
    localparam logic [CW-1:0] LAST_TICK = CPB_LAST_32[CW-1:0];
    localparam logic [1:0] IDLE=2'd0, START=2'd1, DATA=2'd2, STOP=2'd3;
    logic [1:0] state;
    logic [CW-1:0] count;
    logic [2:0] bit_index;
    logic [7:0] payload;
    assign ready = (state == IDLE);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; count <= '0; bit_index <= '0;
            payload <= '0; tx <= 1'b1;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    count <= '0;
                    if (start) begin
                        payload <= data_in;
                        bit_index <= 3'd0;
                        tx <= 1'b0;
                        state <= START;
                    end
                end
                START: begin
                    if (count == LAST_TICK) begin
                        count <= '0;
                        tx <= payload[0];
                        state <= DATA;
                    end else count <= count + 1'b1;
                end
                DATA: begin
                    if (count == LAST_TICK) begin
                        count <= '0;
                        if (bit_index == 3'd7) begin
                            tx <= 1'b1;
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                            tx <= payload[bit_index + 3'd1];
                        end
                    end else count <= count + 1'b1;
                end
                STOP: begin
                    if (count == LAST_TICK) begin
                        count <= '0;
                        state <= IDLE;
                    end else count <= count + 1'b1;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
`default_nettype wire
