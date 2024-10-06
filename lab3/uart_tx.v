module uart_tx(
    input wire          clk,
    input wire          rst_n,
    input wire          en,
    input wire          start,
    input wire  [7:0]   data,
    input wire  [15:0]  baud_div,
    output wire         tx,
    output wire         done
);

    reg         run;
    wire        tick;
    reg [9:0]   tx_reg;
    reg [15:0]  baud_cntr;

    // baud rate counter enable/diable T-FF
    always @(posedge clk, negedge rst_n)
        if(!rst_n)
            run <= 1'b0;
        else
            if(start)
                run <= 'b1;
            else if(done)
                run <= 'b0;

    // the baud rate counter
    assign tick = (baud_cntr == 'b0);
    always @(posedge clk, negedge rst_n)
        if(!rst_n)
            baud_cntr <= 16'hFFFF;
        else
            if(tick | start)
                baud_cntr <= baud_div;
            else if(en & run)
                baud_cntr <= baud_cntr - 'b1;

    // the shift register
    always @(posedge clk, negedge rst_n)
        if(!rst_n)
            tx_reg <= 'h3FF;
        else 
            if(tick)
                tx_reg <= {1'b1, tx_reg[9:1]};
            else if(start)
                tx_reg <= {1'b1, data, 1'b0};

    // Bit Counter
    reg [3:0] bit_cntr;
    always @(posedge clk, negedge rst_n)
        if(!rst_n) 
            bit_cntr <= 'd10;
        else if(start)
            bit_cntr <= 'd10;
        else if(tick & ~done)
            bit_cntr <= bit_cntr - 'b1;

    assign done = (bit_cntr == 'h0);

    assign tx = tx_reg[0];

endmodule