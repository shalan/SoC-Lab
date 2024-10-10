/*
    A 32-bit GPIO Port
*/

module ahbl_gpio(
    input   wire        HCLK,
    input   wire        HRESETn,

    input   wire [31:0] HADDR,
    input   wire [1:0]  HTRANS,
    input   wire     	HREADY,
    input   wire [2:0]  HSIZE,
    input   wire        HWRITE,
    input   wire        HSEL,
    input   wire [31:0] HWDATA,

    output  wire        HREADYOUT,
    output  wire [31:0] HRDATA,
    
    input  wire [31:0]   GPIO_IN,
    output wire [31:0]   GPIO_OUT,
    output wire [31:0]   GPIO_OE
);

localparam  DATA_REG_OFF = 'h00,
            DIR_REG_OFF  = 'h04;
            
// store the address phase signals
reg [32:0]  HADDR_d;
reg [2:0]   HSIZE_d;
reg [1:0]   HTRANS_d;
reg         HWRITE_d;
reg         HSEL_d;

wire DATA_REG_sel   = (HADDR_d[23:0] == DATA_REG_OFF);
wire DIR_REG_sel    = (HADDR_d[23:0] == DIR_REG_OFF);

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

    reg [31:0] DATAO_REG, DATAI_REG_d, DATAI_REG, DIR_REG;
    always @ (posedge HCLK or negedge HRESETn)
        if(~HRESETn)
            DATAO_REG <= 'h0;
        else if(ahbl_we & DATA_REG_sel)
            DATAO_REG <= HWDATA;

    always @ (posedge HCLK or negedge HRESETn)
        if(~HRESETn)
            DIR_REG <= 'h0;
        else if(ahbl_we & DIR_REG_sel)
            DIR_REG <= HWDATA;

    always @ (posedge HCLK or negedge HRESETn)
        if(~HRESETn) begin
            DATAI_REG_d <= 'h0;
            DATAI_REG <= 'h0;
        end else begin
            DATAI_REG_d <= GPIO_IN;
            DATAI_REG <= DATAI_REG_d;
        end

    assign HRDATA = DATA_REG_sel ? DATAI_REG :
                    DIR_REG_sel  ? DIR_REG :
                    32'hBADDBEEF;

    assign HREADYOUT = 1'b1; // Always ready

    assign GPIO_OUT   = DATAO_REG;
    assign GPIO_OE  = DIR_REG;

endmodule