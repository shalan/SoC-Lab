module uart_tx_tb ;
    reg          clk = 0;
    reg          rst_n = 0;
    reg          en;
    reg          start;
    reg  [7:0]   data;
    reg  [15:0]  baud_div;
    wire         tx;
    wire         done;

    uart_tx duv (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .start(start),
        .data(data),
        .baud_div(baud_div),
        .tx(tx),
        .done(done)
    );

    always #10 clk = !clk;

    initial begin
        #777;
        @(posedge clk);
        #1 rst_n = 1;
    end

    initial begin
        $dumpfile("uart_tx_tb.vcd");
        $dumpvars;
    end

    initial begin
        en = 0;
        start = 0;
        wait(rst_n == 1'b1);
        @(posedge clk);
        en = 1;
        baud_div = 9;
        putchar(8'hA5);
        putchar(8'hF0);
        
        #100;
        $finish;
    end
  
    task putchar;
    input[7:0] char;
    begin
        @(posedge clk);
        data = char;
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        wait(done == 1'b1);
    end
    endtask

endmodule