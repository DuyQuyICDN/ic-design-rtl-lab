`default_nettype none
// Simple 8-bit SPI master, mode 0, MSB first, CLK_DIV >= 2.
// One transfer at a time; done pulses for one system clock.
module spi_master_mode0 #(
    parameter integer CLK_DIV = 2
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    input  logic [7:0] tx_data,
    input  logic       miso,
    output logic       mosi,
    output logic       sclk,
    output logic       cs_n,
    output logic       busy,
    output logic       done,
    output logic [7:0] rx_data
);
    localparam integer DW = (CLK_DIV>1) ? $clog2(CLK_DIV) : 1;
    localparam logic [31:0] DIV_LAST_32 = CLK_DIV - 1;
    localparam logic [DW-1:0] LAST_TICK = DIV_LAST_32[DW-1:0];
    logic [DW-1:0] div_count;
    logic [2:0] bit_index;
    logic [7:0] tx_reg, rx_shift;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mosi<=0; sclk<=0; cs_n<=1; busy<=0; done<=0; rx_data<=0;
            div_count<='0; bit_index<=0; tx_reg<=0; rx_shift<=0;
        end else begin
            done <= 1'b0;
            if (!busy) begin
                sclk <= 1'b0;
                cs_n <= 1'b1;
                if (start) begin
                    busy <= 1'b1;
                    cs_n <= 1'b0;
                    tx_reg <= tx_data;
                    rx_shift <= 8'h00;
                    bit_index <= 3'd7;
                    mosi <= tx_data[7];
                    div_count <= '0;
                end
            end else if (div_count == LAST_TICK) begin
                div_count <= '0;
                if (!sclk) begin
                    sclk <= 1'b1;
                    rx_shift[bit_index] <= miso;
                end else begin
                    sclk <= 1'b0;
                    if (bit_index == 3'd0) begin
                        busy <= 1'b0;
                        cs_n <= 1'b1;
                        rx_data <= rx_shift;
                        done <= 1'b1;
                    end else begin
                        bit_index <= bit_index - 1'b1;
                        mosi <= tx_reg[bit_index - 3'd1];
                    end
                end
            end else div_count <= div_count + 1'b1;
        end
    end
endmodule
`default_nettype wire
