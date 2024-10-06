module Hazard2_SoC_tb;
    reg         HCLK;
    reg         HRESETn;

    wire [31:0] GPIO_OUT;
    wire [31:0] GPIO_OE;
    wire [31:0] GPIO_IN;
    
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
        #100_000;
        $display("Test Failed: Timeout");
        $finish;
    end

    Hazard2_SoC MUV (
        .HCLK(HCLK),
        .HRESETn(HRESETn),

        .GPIO_OUT(GPIO_OUT),
        .GPIO_OE(GPIO_OE),
        .GPIO_IN(GPIO_IN)
    );

    // Simulate the GPIO
    tri [31:0] PORT;
    assign PORT = GPIO_OE ? GPIO_OUT : 32'hZZZZ_ZZZZ;
    assign GPIO_IN = PORT;

    // FInish when yoiu see a special pattern on the GPIO
    always@*
        if (GPIO_OUT == 32'hF00F_E00E) begin
            #100;
            $display("Test Passed");
            $finish;
        end

endmodule
