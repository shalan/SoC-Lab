`include "tb.vh"

module ro_dmc_tb;
    localparam LW = 32*16, NL=64;
    reg             cpu_rd;
    reg [31:0]      cpu_aaddr;
    reg [31:0]      cpu_daddr;
    wire            cpu_hit;
    wire [31:0]     cpu_data;

    reg [LW-1:0]    m_data;
    wire [32:0]     m_addr;
    wire            m_start;
    reg             m_done;

    `TB(ro_dmc_tb, clk, rst_n, 1'b0, 100_000)

    ro_dmc #(.LW(LW), .NL(NL)) duv (
        .clk(clk),
        .rst_n(rst_n),
        .cpu_rd(cpu_rd),
        .cpu_aaddr(cpu_aaddr),
        .cpu_daddr(cpu_daddr),
        .cpu_hit(cpu_hit),
        .cpu_data(cpu_data),
        .m_data(m_data),
        .m_addr(m_addr),
        .m_start(m_start),
        .m_done(m_don)
    );

    initial begin
        cpu_rd = 0;
        @(posedge rst_n);
        @(posedge clk);
        cpu_aaddr = 0;
        @(posedge clk);
        cpu_rd = 1;
        @(posedge clk);
        cpu_rd = 0;
        @(posedge clk);
        cpu_aaddr = 32'hABCDEF88;
        #100;
        $finish;
    end

endmodule
