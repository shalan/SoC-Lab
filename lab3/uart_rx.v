module uart_rx (
    input wire clk,             // System clock
    input wire rst_n,           // Active-low reset
    input wire rx,              // UART receive input
    input wire [15:0] baud_div, // Baud rate divisor
    output reg [7:0] rx_data,   // Received data byte
    output reg rx_data_valid    // Data valid signal
);

    // UART Receiver States
    parameter STATE_IDLE  = 2'b00;
    parameter STATE_START = 2'b01;
    parameter STATE_DATA  = 2'b10;
    parameter STATE_STOP  = 2'b11;

    reg [1:0] state;
    reg [15:0] baud_cnt;
    reg [3:0] bit_idx;
    reg [7:0] rx_shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= STATE_IDLE;
            baud_cnt      <= 16'd0;
            bit_idx       <= 4'd0;
            rx_shift_reg  <= 8'd0;
            rx_data       <= 8'd0;
            rx_data_valid <= 1'b0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    rx_data_valid <= 1'b0;
                    if (rx == 1'b0) begin
                        // Start bit detected
                        state    <= STATE_START;
                        baud_cnt <= 16'd0;
                    end
                end
                STATE_START: begin
                    if (baud_cnt == (baud_div >> 1)) begin
                        // Midpoint of start bit
                        if (rx == 1'b0) begin
                            // Valid start bit
                            state    <= STATE_DATA;
                            baud_cnt <= 16'd0;
                            bit_idx  <= 4'd0;
                        end else begin
                            // False start bit, return to idle
                            state <= STATE_IDLE;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                STATE_DATA: begin
                    if (baud_cnt == baud_div - 1) begin
                        baud_cnt <= 16'd0;
                        rx_shift_reg[bit_idx] <= rx;
                        if (bit_idx == 7) begin
                            state <= STATE_STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                STATE_STOP: begin
                    if (baud_cnt == baud_div - 1) begin
                        baud_cnt <= 16'd0;
                        if (rx == 1'b1) begin
                            // Valid stop bit
                            rx_data       <= rx_shift_reg;
                            rx_data_valid <= 1'b1;
                        end
                        state <= STATE_IDLE;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                default: state <= STATE_IDLE;
            endcase
        end
    end

endmodule
