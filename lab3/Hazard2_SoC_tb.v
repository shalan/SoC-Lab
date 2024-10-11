module Hazard2_SoC_tb;

    localparam SIMTIME = 50_000;

    reg         HCLK;
    reg         HRESETn;

    wire [31:0] GPIO_OUT;
    wire [31:0] GPIO_OE;
    wire [31:0] GPIO_IN;

    wire        UART_TX;
    
    // clock
    initial HCLK = 0;
    always #5 HCLK = ~HCLK;

    // Reset
    initial begin
        HRESETn = 0;
        #47;
        @(posedge HCLK);
        HRESETn = 1;
    end

    // TB infrastructure
    initial begin
        $dumpfile("Hazard2_SoC_tb.vcd");
        $dumpvars(0, Hazard2_SoC_tb);
        #SIMTIME;
        $display("TB: Test Failed: Timeout");
        $finish;
    end

    Hazard2_SoC MUV (
        .HCLK(HCLK),
        .HRESETn(HRESETn),

        .GPIO_OUT(GPIO_OUT),
        .GPIO_OE(GPIO_OE),
        .GPIO_IN(GPIO_IN),

        .UART_TX(UART_TX)
    );

    // Simulate the GPIO
    tri [31:0] PORT;
    assign PORT = GPIO_OE ? GPIO_OUT : 32'hZZZZ_ZZZZ;
    assign GPIO_IN = PORT;

    // A serial Terminal
    serial_terminal terminal (
        .clk(HCLK),             
        .rst_n(HRESETn),           
        .rx(UART_TX),           
        .baud_div(10)  
    );

    // FInish when yoiu see a special pattern on the GPIO
    always@*
        if (GPIO_OUT == 32'hF00F_E00E) begin
            #1000;
            $display("TB: Test Passed");
            $finish;
        end

endmodule
