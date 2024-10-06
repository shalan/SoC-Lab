module Hazard2 (
    input   wire        HCLK,
    input   wire        HRESETn,

    output  wire [31:0] HADDR,
    output  wire [1:0]  HTRANS,
    output  wire [2:0] 	HSIZE,
    output  wire        HWRITE,
    output  wire [31:0] HWDATA,
    input   wire        HREADY,
    input   wire [31:0] HRDATA
);

    hazard2_cpu CPU (
        .clk(HCLK), 
        .rst(~HRESETn),

        .hwrite(HWRITE), 
        .hsize(HSIZE), 
        .haddr(HADDR), 
        .hwdata(HWDATA), 
        .hrdata(HRDATA), 
        .hready(HREADY),  
        .htrans(HTRANS)
    );

endmodule