module apb_slave (
    input wire          PCLK,
    input wire          PRESETn,
    input wire          PWRITE,
    input wire [31:0]   PWDATA,
    input wire [31:0]   PADDR,
    input wire          PENABLE,
    input wire          PSEL,
    output wire         PREADY,
    output wire [31:0]  PRDATA
);

    localparam	IO_REG_OFFSET = 16'h0000;

    wire		apb_access  =   PSEL & PENABLE;
    wire		apb_we	    =   PWRITE & apb_access;
    wire		apb_re	    =   ~PWRITE & apb_access;


    reg [31:0]	IO_REG;
	always @(posedge PCLK or negedge PRESETn) 
        if(~PRESETn) 
            IO_REG <= 0;
        else if(apb_we & (PADDR[15:0] == IO_REG_OFFSET))
            IO_REG <= PWDATA[32-1:0];

    assign	PRDATA = (PADDR[15:0] == IO_REG_OFFSET)	? IO_REG : 32'hDEADBEEF;

    assign PREADY = 1;

endmodule

