`default_nettype none

module ahbl_uart_tx (
    // AHB-Lite Interface
    input  wire        HCLK,
    input  wire        HRESETn,
    input  wire [31:0] HADDR,
    input  wire [1:0]  HTRANS,
    input  wire        HWRITE,
    input  wire [2:0]  HSIZE,
    input  wire [31:0] HWDATA,
    input  wire        HSEL,
    input  wire        HREADY,

    output wire [31:0] HRDATA,
    output wire        HREADYOUT,
    //output wire        HRESP,

    // UART Transmitter Output
    output wire        tx
);

    localparam  CTRL_REG_OFF    = 'h00,
                BAUDDIV_REG_OFF = 'h04,
                STATUS_REG_OFF  = 'h08,
                DATA_REG_OFF    = 'h0C;

    wire        done;

    // store the address phase signals
    reg [32:0]  HADDR_d;
    reg [2:0]   HSIZE_d;
    reg [1:0]   HTRANS_d;
    reg         HWRITE_d;
    reg         HSEL_d;

    wire DATA_REG_sel       = (HADDR_d[23:0] == DATA_REG_OFF);
    wire CTRL_REG_sel       = (HADDR_d[23:0] == CTRL_REG_OFF);
    wire STATUS_REG_sel     = (HADDR_d[23:0] == STATUS_REG_OFF);
    wire BAUDDIV_REG_sel    = (HADDR_d[23:0] == BAUDDIV_REG_OFF);
    

    wire ahbl_we        = HTRANS_d[1] & HSEL_d & HWRITE_d;

    always @(posedge HCLK) begin
        if(!HRESETn) begin
            HADDR_d     <= 'h0;
            HSIZE_d     <= 'h0;
            HTRANS_d    <= 'h00;
            HWRITE_d    <= 'h0;
            HSEL_d      <= 'h00;
        end else if(HREADY) begin
            HADDR_d     <= HADDR;
            HSIZE_d     <= HSIZE;
            HTRANS_d    <= HTRANS;
            HWRITE_d    <= HWRITE;
            HSEL_d      <= HSEL;
        end
    end

    reg [ 0:0]  STATUS_REG;
    reg [ 7:0]  DATA_REG;
    reg [ 1:0]  CTRL_REG;
    reg [15:0]  BAUDDIV_REG;

    reg         start_pulse;

    always @ (posedge HCLK or negedge HRESETn)
        if(~HRESETn)
            DATA_REG <= 'h0;
        else if(ahbl_we & DATA_REG_sel)
            DATA_REG <= HWDATA;

    always @ (posedge HCLK or negedge HRESETn)
        if(~HRESETn)
            CTRL_REG <= 'h0;
        else if(ahbl_we & CTRL_REG_sel)
            CTRL_REG <= HWDATA[1:0];

    always @ (posedge HCLK or negedge HRESETn)
    if(~HRESETn)
        BAUDDIV_REG <= 'h0;
    else if(ahbl_we & BAUDDIV_REG_sel)
        BAUDDIV_REG <= HWDATA[15:0];

    always @ (posedge HCLK or negedge HRESETn)
        if(~HRESETn)
            STATUS_REG <= 1'b1;
        else if(start_pulse)
            STATUS_REG <= 1'b0;    
        else if(done)
            STATUS_REG <= 1'b1;
        
    always @ (posedge HCLK or negedge HRESETn)
        if(~HRESETn)
            start_pulse <= 1'b0;
        else if(ahbl_we & CTRL_REG_sel & HWDATA[1])
            start_pulse <= 1'b1;
        else
            start_pulse <= 1'b0;

    //wire [31:0] rd; 
    assign HRDATA = DATA_REG_sel    ? {24'h0, DATA_REG}     :
                    CTRL_REG_sel    ? {30'h0, CTRL_REG}     :
                    BAUDDIV_REG_sel ? {16'h0, BAUDDIV_REG}  :
                    STATUS_REG_sel  ? {31'h0, STATUS_REG}   :
                    32'hBADDBEEF;

    assign HREADYOUT = 1'b1; // Always ready

    uart_tx uart_transmitter (
        .clk(HCLK),
        .rst_n(HRESETn),
        .en(CTRL_REG[0]),
        .start(start_pulse),
        .data(DATA_REG),
        .baud_div(BAUDDIV_REG),
        .tx(tx),
        .done(done)
    );

endmodule
