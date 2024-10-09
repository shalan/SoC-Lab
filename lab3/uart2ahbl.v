// ================================================================
// UART to AHB-Lite Bridge Module
// ================================================================
module uart2ahbl (
    input wire clk,
    input wire rst_n,
    input wire uart_rx,
    output wire uart_tx,
    // AHB-Lite Master Interface
    output reg [31:0] HADDR,
    output reg [2:0]  HBURST,
    output reg        HMASTLOCK,
    output reg [3:0]  HPROT,
    output reg [2:0]  HSIZE,
    output reg [1:0]  HTRANS,
    output reg [31:0] HWDATA,
    output reg        HWRITE,
    input wire [31:0] HRDATA,
    input wire        HREADY,
    input wire        HRESP
);
    // Parameters
    parameter integer CLK_FREQ = 50000000; // System clock frequency in Hz

    // UART Baud Rate Divisor Calculation (Example for 115200 bps)
    parameter integer BAUD_RATE = 115200;
    parameter integer BAUD_DIV = CLK_FREQ / BAUD_RATE;

    // UART Receiver Signals
    wire [7:0] rx_data;
    wire       rx_data_valid;

    // UART Transmitter Signals
    reg [7:0]  tx_data;
    reg        tx_data_valid;
    wire       tx_busy;

    // Command Parsing Registers
    reg [7:0]  cmd_opcode;
    reg [31:0] cmd_address;
    reg [31:0] cmd_data;
    reg [3:0]  cmd_byte_count;
    reg        cmd_ready;

    // AHB State Machine
    typedef enum reg [1:0] {
        STATE_IDLE   = 2'b00,
        STATE_ACCESS = 2'b01
    } ahb_state_t;
    reg [1:0] ahb_state;

    // UART Transmit State Machine
    typedef enum reg [1:0] {
        TX_IDLE          = 2'b00,
        TX_SEND_STATUS   = 2'b01,
        TX_SEND_DATA     = 2'b10
    } tx_state_t;
    reg [1:0] tx_state;

    reg        ahb_transaction_done;
    reg [31:0] read_data_reg;
    reg [1:0]  tx_data_byte_counter;

    // Baud rate divisor register
    reg [15:0] baud_div_reg;

    // Initialize baud_div_reg
    initial begin
        baud_div_reg = BAUD_DIV;
    end

    // Instantiate UART Receiver
    uart_rx uart_receiver (
        .clk(clk),
        .rst_n(rst_n),
        .rx_in(uart_rx),
        .baud_div(baud_div_reg),
        .rx_data(rx_data),
        .rx_data_valid(rx_data_valid)
    );

    // Instantiate UART Transmitter
    uart_tx uart_transmitter (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .tx_data_valid(tx_data_valid),
        .baud_div(baud_div_reg),
        .tx_out(uart_tx),
        .tx_busy(tx_busy)
    );

    // Command Parsing Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cmd_opcode     <= 8'd0;
            cmd_address    <= 32'd0;
            cmd_data       <= 32'd0;
            cmd_byte_count <= 4'd0;
            cmd_ready      <= 1'b0;
        end else begin
            if (rx_data_valid) begin
                case (cmd_byte_count)
                    4'd0: begin
                        cmd_opcode     <= rx_data;
                        cmd_byte_count <= cmd_byte_count + 1;
                    end
                    4'd1: begin
                        cmd_address[31:24] <= rx_data;
                        cmd_byte_count     <= cmd_byte_count + 1;
                    end
                    4'd2: begin
                        cmd_address[23:16] <= rx_data;
                        cmd_byte_count     <= cmd_byte_count + 1;
                    end
                    4'd3: begin
                        cmd_address[15:8] <= rx_data;
                        cmd_byte_count    <= cmd_byte_count + 1;
                    end
                    4'd4: begin
                        cmd_address[7:0] <= rx_data;
                        cmd_byte_count   <= cmd_byte_count + 1;
                        if (cmd_opcode == 8'h01) begin // Read command
                            cmd_ready <= 1'b1;
                        end
                    end
                    4'd5: begin
                        cmd_data[31:24] <= rx_data;
                        cmd_byte_count  <= cmd_byte_count + 1;
                    end
                    4'd6: begin
                        cmd_data[23:16] <= rx_data;
                        cmd_byte_count  <= cmd_byte_count + 1;
                    end
                    4'd7: begin
                        cmd_data[15:8] <= rx_data;
                        cmd_byte_count <= cmd_byte_count + 1;
                    end
                    4'd8: begin
                        cmd_data[7:0]   <= rx_data;
                        cmd_byte_count  <= cmd_byte_count + 1;
                        cmd_ready       <= 1'b1;
                    end
                    default: begin
                        cmd_byte_count <= 4'd0;
                    end
                endcase
            end else if (cmd_ready && ahb_transaction_done) begin
                // Reset for next command after processing
                cmd_opcode     <= 8'd0;
                cmd_address    <= 32'd0;
                cmd_data       <= 32'd0;
                cmd_byte_count <= 4'd0;
                cmd_ready      <= 1'b0;
            end
        end
    end

    // AHB-Lite Master Interface Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ahb_state <= STATE_IDLE;
            HADDR     <= 32'd0;
            HBURST    <= 3'd0;
            HMASTLOCK <= 1'b0;
            HPROT     <= 4'd0;
            HSIZE     <= 3'd0;
            HTRANS    <= 2'd0;
            HWDATA    <= 32'd0;
            HWRITE    <= 1'b0;
            ahb_transaction_done <= 1'b0;
        end else begin
            case (ahb_state)
                STATE_IDLE: begin
                    if (cmd_ready & ~ahb_transaction_done) begin
                        HADDR     <= cmd_address;
                        HBURST    <= 3'b000; // Single transfer
                        HMASTLOCK <= 1'b0;
                        HPROT     <= 4'b0011; // Non-cacheable, non-bufferable, privileged data access
                        HSIZE     <= 3'b010; // Word transfer (32 bits)
                        HTRANS    <= 2'b10;  // Non-sequential transfer
                        HWRITE    <= (cmd_opcode == 8'h02) ? 1'b1 : 1'b0; // Write if opcode is 0x02
                        if (cmd_opcode == 8'h02) begin // Write command
                            HWDATA <= cmd_data;
                        end
                        ahb_state <= STATE_ACCESS;
                    end else begin
                        HTRANS <= 2'b00; // IDLE
                    end
                end
                STATE_ACCESS: begin
                    if (HREADY) begin
                        ahb_state          <= STATE_IDLE;
                        HTRANS             <= 2'b00; // Set HTRANS to IDLE
                        ahb_transaction_done <= 1'b1;
                        if (HWRITE == 1'b0 && HRESP == 1'b0) begin // Read command, OKAY response
                            read_data_reg <= HRDATA;
                        end
                    end 
                    //else begin
                    //    HTRANS <= HTRANS; // Keep HTRANS same
                    //end
                end
                default: begin
                    ahb_state <= STATE_IDLE;
                end
            endcase
        end
    end

    // UART Transmit Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_state             <= TX_IDLE;
            tx_data              <= 8'd0;
            tx_data_valid        <= 1'b0;
            tx_data_byte_counter <= 2'd0;
            ahb_transaction_done <= 1'b0;
        end else begin
            case (tx_state)
                TX_IDLE: begin
                    if (ahb_transaction_done) begin
                        if (HRESP == 1'b0) begin // OKAY response
                            tx_data <= 8'h00; // Status code 0x00 (success)
                        end else begin
                            tx_data <= 8'hFF; // Status code 0xFF (error)
                        end
                        tx_data_valid <= 1'b1;
                        tx_state      <= TX_SEND_STATUS;
                    end else begin
                        tx_data_valid <= 1'b0;
                    end
                end
                TX_SEND_STATUS: begin
                    if (!tx_busy) begin
                        tx_data_valid <= 1'b0;
                        if (HWRITE == 1'b0 && HRESP == 1'b0) begin // Read command, OKAY response
                            tx_data_byte_counter <= 2'd3;
                            tx_data             <= read_data_reg[31:24];
                            tx_data_valid       <= 1'b1;
                            tx_state            <= TX_SEND_DATA;
                        end else begin
                            tx_state <= TX_IDLE;
                            ahb_transaction_done <= 1'b0; // Reset transaction done flag
                        end
                    end
                end
                TX_SEND_DATA: begin
                    if (!tx_busy) begin
                        tx_data_valid <= 1'b0;
                        case (tx_data_byte_counter)
                            2'd3: begin
                                tx_data <= read_data_reg[31:24];
                                tx_data_valid <= 1'b1;
                                tx_data_byte_counter <= tx_data_byte_counter - 1;
                            end
                            2'd2: begin
                                tx_data <= read_data_reg[23:16];
                                tx_data_valid <= 1'b1;
                                tx_data_byte_counter <= tx_data_byte_counter - 1;
                            end
                            2'd1: begin
                                tx_data <= read_data_reg[15:8];
                                tx_data_valid <= 1'b1;
                                tx_data_byte_counter <= tx_data_byte_counter - 1;
                            end
                            2'd0: begin
                                tx_data <= read_data_reg[7:0];
                                tx_data_valid <= 1'b1;
                                tx_data_byte_counter <= tx_data_byte_counter - 1;
                                tx_state <= TX_IDLE;
                                ahb_transaction_done <= 1'b0; // Reset transaction done flag
                            end
                        endcase
                    end
                end
                default: begin
                    tx_state      <= TX_IDLE;
                    tx_data_valid <= 1'b0;
                    ahb_transaction_done <= 1'b0;
                end
            endcase
        end
    end

endmodule

// ================================================================
// UART Transmitter Module with Programmable Baud Rate
// ================================================================
module uart_tx (
    input wire clk,
    input wire rst_n,
    input wire [7:0] tx_data,
    input wire       tx_data_valid,
    input wire [15:0] baud_div,    // Programmable baud rate divisor
    output reg       tx_out,
    output reg       tx_busy
);
    // Width of the baud counter based on the maximum possible baud_div
    localparam integer BAUD_DIV_WIDTH = 16;

    // State definitions
    typedef enum reg [1:0] {
        STATE_IDLE  = 2'b00,
        STATE_START = 2'b01,
        STATE_DATA  = 2'b10,
        STATE_STOP  = 2'b11
    } tx_state_t;
    reg [1:0] state;

    reg [BAUD_DIV_WIDTH-1:0] baud_cnt;
    reg [2:0] bit_idx;
    reg [7:0] tx_shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_out       <= 1'b1; // Idle state is high
            tx_busy      <= 1'b0;
            baud_cnt     <= 0;
            bit_idx      <= 0;
            tx_shift_reg <= 8'd0;
            state        <= STATE_IDLE;
        end else begin
            case (state)
                STATE_IDLE: begin
                    tx_out  <= 1'b1; // Line idle
                    tx_busy <= 1'b0;
                    if (tx_data_valid) begin
                        tx_shift_reg <= tx_data;
                        tx_busy      <= 1'b1;
                        state        <= STATE_START;
                        baud_cnt     <= 0;
                    end
                end
                STATE_START: begin
                    tx_out <= 1'b0; // Start bit
                    if (baud_cnt < baud_div - 1) begin
                        baud_cnt <= baud_cnt + 1;
                    end else begin
                        baud_cnt <= 0;
                        state    <= STATE_DATA;
                        bit_idx  <= 0;
                    end
                end
                STATE_DATA: begin
                    tx_out <= tx_shift_reg[bit_idx];
                    if (baud_cnt < baud_div - 1) begin
                        baud_cnt <= baud_cnt + 1;
                    end else begin
                        baud_cnt <= 0;
                        if (bit_idx < 7) begin
                            bit_idx <= bit_idx + 1;
                        end else begin
                            state <= STATE_STOP;
                        end
                    end
                end
                STATE_STOP: begin
                    tx_out <= 1'b1; // Stop bit
                    if (baud_cnt < baud_div - 1) begin
                        baud_cnt <= baud_cnt + 1;
                    end else begin
                        baud_cnt <= 0;
                        state    <= STATE_IDLE;
                        tx_busy  <= 1'b0;
                    end
                end
                default: state <= STATE_IDLE;
            endcase
        end
    end
endmodule

// ================================================================
// UART Receiver Module with Programmable Baud Rate
// ================================================================
module uart_rx (
    input wire clk,
    input wire rst_n,
    input wire rx_in,
    input wire [15:0] baud_div,     // Programmable baud rate divisor
    output reg [7:0] rx_data,
    output reg       rx_data_valid
);
    // Width of the baud counter based on the maximum possible baud_div
    localparam integer BAUD_DIV_WIDTH = 16;

    // State definitions
    typedef enum reg [1:0] {
        STATE_IDLE  = 2'b00,
        STATE_START = 2'b01,
        STATE_DATA  = 2'b10,
        STATE_STOP  = 2'b11
    } rx_state_t;
    reg [1:0] state;

    reg [BAUD_DIV_WIDTH-1:0] baud_cnt;
    reg [2:0] bit_idx;
    reg [7:0] rx_shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= STATE_IDLE;
            rx_data       <= 8'd0;
            rx_data_valid <= 1'b0;
            baud_cnt      <= 0;
            bit_idx       <= 0;
            rx_shift_reg  <= 8'd0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    rx_data_valid <= 1'b0;
                    if (rx_in == 1'b0) begin
                        // Start bit detected
                        state    <= STATE_START;
                        baud_cnt <= 0;
                    end
                end
                STATE_START: begin
                    if (baud_cnt < (baud_div >> 1) - 1) begin
                        baud_cnt <= baud_cnt + 1;
                    end else begin
                        // Middle of start bit
                        if (rx_in == 1'b0) begin
                            // Valid start bit
                            baud_cnt <= 0;
                            bit_idx  <= 0;
                            state    <= STATE_DATA;
                        end else begin
                            // False start bit, return to idle
                            state <= STATE_IDLE;
                        end
                    end
                end
                STATE_DATA: begin
                    if (baud_cnt < baud_div - 1) begin
                        baud_cnt <= baud_cnt + 1;
                    end else begin
                        baud_cnt                   <= 0;
                        rx_shift_reg[bit_idx] <= rx_in;
                        if (bit_idx < 7) begin
                            bit_idx <= bit_idx + 1;
                        end else begin
                            state <= STATE_STOP;
                        end
                    end
                end
                STATE_STOP: begin
                    if (baud_cnt < baud_div - 1) begin
                        baud_cnt <= baud_cnt + 1;
                    end else begin
                        baud_cnt <= 0;
                        if (rx_in == 1'b1) begin
                            // Valid stop bit
                            rx_data       <= rx_shift_reg;
                            rx_data_valid <= 1'b1;
                        end
                        state <= STATE_IDLE;
                    end
                end
                default: state <= STATE_IDLE;
            endcase
        end
    end
endmodule
