module flash_ctrl_eb #(parameter DW = 256) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire             start,
    output wire             done,
    input  wire [23:0]      A,
    output wire [DW-1:0]    D,
    output wire             csn,
    output wire             sck,
    output wire [3:0]       doe,
    output wire [3:0]       do,
    input  wire [3:0]       di
);
    localparam ENDCNT = 80 + DW/2;
    localparam CNTRW = $clog2(80+DW/2);
    wire trans_off = (bit_cntr == 'd8) | (bit_cntr == 'd18) | (cntr == ENDCNT);
    wire trans_on = (start) | (cntr == 'd19) | (cntr == 'd39);

    reg run;
    always@(posedge clk, negedge rst_n)
        if(!rst_n)
            run <= 1'b0;
        else if(start)
            run <= 1'b1;
        else if(done)
            run <= 1'b0;

    reg first;
    always@(posedge clk, negedge rst_n)
        if(!rst_n)
            first <= 1'b1;
        else if(bit_cntr == 'd40) 
            first <= 1'b0;

    reg csn_reg;
    assign csn = csn_reg;
    always@(posedge clk, negedge rst_n)
        if(!rst_n)
            csn_reg <= 'b1;
        else if(trans_on)
            csn_reg <= 1'b0;
        else if(trans_off)
            csn_reg <= 1'b1;

    reg [CNTRW-1:0] cntr;
    wire [CNTRW-2:0] bit_cntr = cntr [CNTRW-1:1];
    always@(posedge clk, negedge rst_n)
        if(!rst_n)
            cntr <= 'b0;
        else if(start & first)
            cntr <= 'b0;
        else if(start & ~first)
            cntr <= 'd56;
        else if(run)
            cntr <= cntr + 'b1;

    reg [3:0] do_reg;
    assign do = do_reg;
    always @* begin
        case(bit_cntr)
            // 66
            6'd0  : do_reg = 4'b0000;
            6'd1  : do_reg = 4'b0001;
            6'd2  : do_reg = 4'b0001;
            6'd3  : do_reg = 4'b0000;
            6'd4  : do_reg = 4'b0000;
            6'd5  : do_reg = 4'b0001;
            6'd6  : do_reg = 4'b0001;
            6'd7  : do_reg = 4'b0000;
            // 99
            6'd10 : do_reg = 4'b0001;
            6'd11 : do_reg = 4'b0000;
            6'd12 : do_reg = 4'b0000;
            6'd13 : do_reg = 4'b0001;
            6'd14 : do_reg = 4'b0001;
            6'd15 : do_reg = 4'b0000;
            6'd16 : do_reg = 4'b0000;
            6'd17 : do_reg = 4'b0001;
            // EB
            6'd20 : do_reg = 4'b0001;
            6'd21 : do_reg = 4'b0001;
            6'd22 : do_reg = 4'b0001;
            6'd23 : do_reg = 4'b0000;
            6'd24 : do_reg = 4'b0001;
            6'd25 : do_reg = 4'b0000;
            6'd26 : do_reg = 4'b0001;
            6'd27 : do_reg = 4'b0001;

            // The address
            6'd28 : do_reg = A[23:20];
            6'd29 : do_reg = A[19:16];
            6'd30 : do_reg = A[15:12];
            6'd31 : do_reg = A[11:8];
            6'd32 : do_reg = A[7:4];
            6'd33 : do_reg = A[3:0];

            // The M Byte
            6'd34 : do_reg = 4'b1010;
            6'd35 : do_reg = 4'b0000;

            // Dummy Bytes
            6'd36 : do_reg = 4'b0000;
            6'd37 : do_reg = 4'b0000;
            6'd38 : do_reg = 4'b0000;
            6'd39 : do_reg = 4'b0000;
            default: do_reg = 0;
        endcase
    end
    assign do = do_reg;

    assign doe = (bit_cntr > 39) ? 4'h0 : 4'hF;

    reg [DW-1:0] data;
    reg [7:0] dbyte;
    always@(posedge clk, negedge rst_n)
        if(!rst_n)
            dbyte <= 'b0;
        else
            if(bit_cntr > 39)
                case (bit_cntr[0])
                    0: dbyte[7:4] <= di;
                    1: dbyte[3:0] <= di;
                endcase

    always@(posedge clk, negedge rst_n)
        if(!rst_n)
            data <= 'b0;
        else if(cntr > 80)
            if(cntr[1:0] == 2'b0)
                data <= {dbyte, data[DW-1:8]};

    //assign sck = cntr[0] & ~csn;
    reg sck_reg;
    always@(posedge clk, negedge rst_n)
        if(!rst_n)
            sck_reg <= 1'b0;
        else if(trans_off)
            sck_reg <= 1'b0;
        else if(~csn)
            sck_reg <= ~sck_reg;
        
    assign sck = sck_reg;

    assign done = (cntr > ENDCNT); //first ? (cntr>48) : csn;
    assign D = data;
endmodule
