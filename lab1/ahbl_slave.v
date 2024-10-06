module ahbl_slave #(parameter ID = 32'hABCD_EF00) (
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
    output  wire [31:0] HRDATA
    
);
    reg [31:0] HADDR_d;
    reg [1:0]  HTRANS_d;
    reg [2:0]  HSIZE_d;
    reg        HWRITE_d;
    reg        HSEL_d;
    always @(posedge HCLK or negedge HRESETn) begin
        if(HRESETn == 1'b0) begin
            HADDR_d     <= 0;
            HTRANS_d    <= 0;
            HSIZE_d     <= 0;
            HWRITE_d    <= 0;
            HSEL_d      <= 0;
        end else if(HREADY == 1'b1) begin
            HADDR_d     <= HADDR;
            HTRANS_d    <= HTRANS;
            HSIZE_d     <= HSIZE;
            HWRITE_d    <= HWRITE;
            HSEL_d      <= HSEL;
        end 
    end

    wire ahbl_we = HTRANS_d[1] & HSEL_d & HWRITE_d;
    always @(posedge HCLK) begin
        if(HRESETn & ahbl_we)
            $display("Slave %h: WRITE 0x%8x to 0x%8x", ID, HWDATA, HADDR_d);
    end

    assign HREADYOUT = 1;
    assign HRDATA = ID;
endmodule
