module ahbl_master_tb;
    reg         HCLK;
    reg         HRESETn;
    wire [31:0] HADDR;
    wire [1:0]  HTRANS;
    wire [2:0] 	HSIZE;
    wire        HWRITE;
    wire [31:0] HWDATA;
    reg         HREADY;
    reg  [31:0] HRDATA;

    // clock
    initial HCLK = 0;
    always #5 HCLK = ~HCLK;

    // Reset
    initial begin
        HRESETn = 0;
        #100;
        @(posedge HCLK);
        HRESETn = 1;
    end

    // TB infrastructure
    initial begin
        $dumpfile("ahbl_master_tb.vcd");
        $dumpvars(0);
        #10_000;
        $finish;
    end

    // simulate a simple bus
    initial begin
        HREADY = 1;
        HRDATA = 32'hBADDBEEF;
    end

    ahbl_master MASTER (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HADDR(HADDR),
        .HTRANS(HTRANS),
        .HSIZE(HSIZE),
        .HWRITE(HWRITE),
        .HWDATA(HWDATA),
        .HREADY(HREADY),
        .HRDATA(HRDATA)
    );

endmodule
