module apb(
    input wire          PCLK,
    input wire          PRESETn,
    input wire          PWRITE,
    input wire [31:0]   PWDATA,
    input wire [31:0]   PADDR,
    input wire          PENABLE,
    output wire         PREADY,
    output wire [31:0]  PRDATA
);

    // Slave Decoding/Selection
    // The 3rd Most Significant Byte is used for decoding
    wire PSEL_S0 = (PADDR[23:16] == 24'h0);

    wire        PREADY_S0;
    wire [31:0] PRDATA_S0;


    apb_slave APB_S0 (
        apb_slave (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PWRITE(PWRITE),
        .PWDATA(PWDATA),
        .PADDR(PADDR),
        .PENABLE(PENABLE),
        .PSEL(PSEL_S0),
        .PREADY(PREADY_S0),
        .PRDATA(PRDATA_S0)
    );

    assign PREADY   =   PSEL_S0 ? PREADY_S0 : 1'b1;
    assign PRDATA   =   PSEL_S0 ? PRDATA_S0 : 32'hDEADBEEF; 

endmodule