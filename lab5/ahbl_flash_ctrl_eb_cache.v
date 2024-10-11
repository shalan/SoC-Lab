module ahbl_flash_ctrl_eb_cache #(parameter LW=32*8, NL=32) (
    // AHB-Lite Slave Interface
    input   wire                HCLK,
    input   wire                HRESETn,
    input   wire                HSEL,
    input   wire [31:0]         HADDR,
    input   wire [1:0]          HTRANS,
    input   wire                HWRITE,
    input   wire                HREADY,
    output  wire                HREADYOUT,
    output  wire [31:0]         HRDATA,

    // External Interface to Quad I/O
    output wire                 csn,
    output wire                 sck,
    output wire [3:0]           doe,
    output wire [3:0]           do,
    input  wire [3:0]           di
);

    //AHB-Lite Address Phase Regs
    reg             last_HSEL;
    reg [31:0]      last_HADDR;
    reg             last_HWRITE;
    reg [1:0]       last_HTRANS;
    reg             last_valid;

    wire            valid = HSEL & HTRANS[1] & HREADY;

    wire            cpu_hit;
    wire [31:0]     cpu_data;
    wire [LW-1:0]   D;
    wire [31:0]     m_data;
    wire [31:0]     m_addr;

    always@ (posedge HCLK or negedge HRESETn)
        if(~HRESETn) begin
            last_HSEL   <= 'b0;
            last_HADDR  <= 'b0;
            last_HWRITE <= 'b0;
            last_HTRANS <= 'b0;
            last_valid  <= 'b0;
        end
        else if(HREADY) begin
            last_HSEL   <= HSEL;
            last_HADDR  <= HADDR;
            last_HWRITE <= HWRITE;
            last_HTRANS <= HTRANS;
            last_valid  <= valid;
        end

    reg         start;
    wire        done;

    //wire [23:0]  A;
    //wire [31:0]  D;

    flash_ctrl_eb #(.LW(LW)) flash_ctrl (
        .clk(HCLK),
        .rst_n(HRESETn),
        .start(m_start),
        .done(done),
        .A(last_HADDR[23:0]),
        .D(D),
        .csn(csn),
        .sck(sck),
        .doe(doe),
        .do(do),
        .di(di)
    );

    ro_dmc #(.LW(LW), .NL(NL)) cache (
        .clk(HCLK),
        .rst_n(HRESETn),
        // CPU/Bus Interface
        .cpu_rd(valid),
        .cpu_aaddr(HADDR),
        .cpu_daddr(last_HADDR),
        .cpu_hit(cpu_hit),
        .cpu_data(HRDATA),
        // Slow Memory Interface
        .m_data(D),
        //.m_addr(m_addr),
        .m_start(m_start),
        .m_done(done)
    );

    always@ (posedge HCLK or negedge HRESETn) 
        if(~HRESETn) start <= 1'b0;
        else if(valid & ~cpu_hit) start <= 'b1;
        else start <= 'b0;

    reg hready;
    always@ (posedge HCLK or negedge HRESETn) 
        if(~HRESETn) hready <= 1'b1;
        else if(valid & ~cpu_hit)  hready <= 'b0;
        else if(done & ~start)   hready <= 1'b1;

    assign HREADYOUT = hready;

endmodule