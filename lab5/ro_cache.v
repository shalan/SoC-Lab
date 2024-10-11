module ro_dmc #(parameter LW=32*16, NL=64) (
    input   wire            clk,
    input   wire            rst_n,

    // CPU/Bus Interface
    input   wire            cpu_rd,
    input   wire [31:0]     cpu_aaddr,
    input   wire [31:0]     cpu_daddr,
    output  wire            cpu_hit,
    output  wire [31:0]     cpu_data,

    // Slow Memory Interface
    input   wire [LW-1:0]   m_data,
    output  wire [32:0]     m_addr,
    output  wire            m_start,
    input   wire            m_done
);

    localparam      LWB = LW/8;
    localparam      LFW = $clog2(NL);
    localparam      OFW = $clog2(LWB);
    localparam      TFW = 32 - LFW - OFW;
    localparam      OFS = 0;
    localparam      LFS = $clog2(LWB);
    localparam      TFS = LFW + OFW;
    localparam      OFE = $clog2(LWB) - 1;
    localparam      LFE = OFE + LFW;
    localparam      TFE = 31;

    reg[LW-1:0]     DATA[NL-1:0];
    reg[TFW-1:0]    TAG[NL-1:0];
    reg             VALID[NL-1:0];

    wire [LFW-1:0]  dline_no= cpu_daddr[LFE:LFS];
    wire [LFW-1:0]  line_no = cpu_aaddr[LFE:LFS];
    wire [TFW-1:0]  tag     = cpu_daddr[TFE:TFS];
    wire [OFW-1:0]  off     = cpu_daddr[OFW-1:0];


    wire ahit   =   (TAG[line_no] == tag) & (VALID[line_no] == 1'b1);
    wire dhit   =   (TAG[dline_no] == tag) & (VALID[dline_no] == 1'b1); 

    integer i;
    always@(posedge clk, negedge rst_n)
        if(!rst_n)
            for(i=0; i<NL; i=i+1) begin
                VALID[i] <= 'b0;
                TAG[i] <= 'b0;
            end
        else if(m_done) begin
            DATA[dline_no] <= m_data;
            VALID[dline_no] <= 'b1;
            TAG[dline_no] <= tag;
        end
    
    assign cpu_hit = cpu_rd ? ahit : dhit;
    assign m_start = cpu_rd & ~ahit;

    assign m_addr = cpu_aaddr;

    localparam NW = LW/32;
    wire [31:0] words [NW-1:0];
    wire [LW-1:0] data = DATA[dline_no];
    wire [OFW-3:0] woff = off[OFW-1:2];
    generate
        genvar gi;
        for(gi=0; gi<NW; gi=gi+1)
            assign words[gi] = data[gi*32+31:gi*32];
    endgenerate


    assign cpu_data = words[woff];

endmodule

