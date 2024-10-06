module ahbl_flash_ctrl_eb_tb;

    reg         HCLK;
    reg         HRESETn;
    reg [31:0] HADDR;
    reg [1:0]  HTRANS;
    reg [2:0] 	HSIZE;
    reg        HWRITE;
    wire [31:0] HWDATA;
    wire         HREADYOUT;
    wire         HREADY;
    
    wire  [31:0] HRDATA;

    wire         csn;
    wire         sck;
    wire [3:0]   doe;
    wire [3:0]   do;
    wire [3:0]   di;

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
        $dumpfile("ahbl_flash_ctrl_eb_tb.vcd");
        $dumpvars(0);
        #10_000;
        $finish;
    end

    // A small test
    initial begin
        // Load the flash with some data
        #1 $readmemh("init.hex", FLASH.I0.memory);
        // wait for HRESETn to be deasserted
        @(posedge HRESETn);
        #100;
        ahbl_read(0, 2);
        #100;
        ahbl_read(4, 2);
        #100;
        $finish;
    end

    wire [3:0] SIO = (doe==4'b1111) ? do : 4'bzzzz;
    assign di = SIO;
    sst26wf080b FLASH (.SCK(sck),.SIO(SIO),.CEb(csn));

    ahbl_flash_ctrl_eb_cache duv (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        
        .HSEL(1'b1),
        .HADDR(HADDR),
        .HTRANS(HTRANS),
        //.HWDATA(HWDATA),
        .HWRITE(HWRITE),
        .HREADY(HREADY),
        .HREADYOUT(HREADYOUT),
        .HRDATA(HRDATA),

        .csn(csn),
        .sck(sck),
        .doe(doe),
        .do(do),
        .di(di)
    );

    assign HREADY = HREADYOUT;

    task ahbl_read;
    input [31:0]    addr;
    input [2:0]     size;
    begin
        wait (HREADY == 1'b1);
        // Address Phase
        @(posedge HCLK);
        #1;
        HTRANS = 2'b10;
        HADDR = addr;
        HWRITE = 1'b0;
        HSIZE = size;
        @(posedge HCLK);
        HTRANS = 2'b00;
        #2;
        wait (HREADY == 1'b1);
        @(negedge HCLK) begin
            if(size == 0) 
                #1 $display("Read 0x%8X from 0x%8x", HRDATA & 32'hFF, addr);
            else if(size == 1) 
                #1 $display("Read 0x%8X from 0x%8x", HRDATA & 32'hFFFF, addr);
            else if(size == 2)
                #1 $display("Read 0x%8X from 0x%8x", HRDATA, addr);
        end
    end
endtask

endmodule