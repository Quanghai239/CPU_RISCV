`timescale 1ns/1ps

module tb;

    logic i_clk;
    logic i_rst_n;
    logic [31:0] i_io_sw = 0;
    logic [3:0]  i_io_btn = 0;

    wrapper_processor uut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_io_sw(i_io_sw),
        .i_io_btn(i_io_btn),
        .o_io_ledr(),
        .o_io_ledg(),
        .o_io_hex0(),
        .o_io_hex1(),
        .o_io_hex2(),
        .o_io_hex3(),
        .o_io_hex4(),
        .o_io_hex5(),
        .o_io_hex6(),
        .o_io_hex7(),
        .o_io_lcd()
    );
	 
always #5 i_clk = ~i_clk;

initial begin
        i_clk = 0;
        i_rst_n = 0;
        i_io_sw = 32'd0;
        i_io_btn = 4'd0;

	#20 i_rst_n = 1;
	#1000;
        i_io_btn = 4'h8;
        #1000;
        i_io_btn = 4'h6;
	
    end
endmodule