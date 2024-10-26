`define     TB(tb_name, clk, rst, rst_pol, duration) reg clk = 0, rst = 'bx;\
                                            always #10 clk = !clk;\
                                            initial begin\
                                                #33 rst = rst_pol;\
                                                #777;\
                                                @(posedge clk);\
                                                #1 rst = ~rst_pol;\
                                            end\
                                            initial begin\
                                                $dumpfile("``tb_name``.vcd");\
                                                $dumpvars;\
                                                #duration;\
                                                $finish;\
                                            end\