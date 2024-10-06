module flash_ctrl_eb_tb ;
    reg          clk = 0;
    reg          rst_n = 0;
    reg          start;
    wire         done;

    reg [23:0]   A;
    wire [31:0]  D;
    wire         csn;
    wire         sck;
    wire [3:0]   doe;
    wire [3:0]   do;
    wire  [3:0]   di;

    flash_ctrl_eb duv (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .done(done),
        .A(A),
        .D(D),
        .csn(csn),
        .sck(sck),
        .doe(doe),
        .do(do),
        .di(di)
    );

    wire [3:0] SIO = (doe==4'b1111) ? do : 4'bzzzz;
    assign di = SIO;
    sst26wf080b FLASH (.SCK(sck),.SIO(SIO),.CEb(csn));

    always #10 clk = !clk;

    initial begin
        #777;
        @(posedge clk);
        #1 rst_n = 1;
    end

    initial begin
        $dumpfile("flash_ctrl_eb_tb.vcd");
        $dumpvars;
        #1 $readmemh("init.hex", FLASH.I0.memory);
        #10_000;
        $finish;
    end

    initial begin
        start = 0;
        wait(rst_n == 1'b1);
        @(posedge clk);
        flash_fetch(0);
        #100;
        $finish;
    end

    task flash_fetch;
    input[23:0] addr;
    begin
        @(posedge clk);
        A = addr;
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        wait(done == 1'b1);
    end
    endtask

endmodule