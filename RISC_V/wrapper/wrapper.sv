module wrapper(
	input logic CLOCK_50,
	input logic [17:0] SW,
	input logic [3:0] KEY,
	output logic [16:0] LEDR,
	output logic [7:0] LEDG,
	output logic [6:0] HEX0,
	output logic [6:0] HEX1,
	output logic [6:0] HEX2,
	output logic [6:0] HEX3,
	output logic [6:0] HEX4,
	output logic [6:0] HEX5,
	output logic [6:0] HEX6,
	output logic [6:0] HEX7,
	output logic LCD_EN,
	output logic LCD_RW,
	output logic LCD_RS,
	output logic LCD_ON,
	output logic [7:0] LCD_DATA
	);

	logic [3:0] btn;

	logic [10:0] LCD_OUT;
	logic [20:0] temp;
	assign LCD_ON = 1'b1; //power on
	assign LCD_RW = LCD_OUT[8]; //write
	assign LCD_EN = LCD_OUT[10];
    assign LCD_RS = LCD_OUT[9];
    assign LCD_DATA = LCD_OUT[7:0];
	processor dut(
		.i_clk(CLOCK_50),
		.i_rst_n(SW[17]),
		// .e_irq(SW[16]),
		// .t_irq(SW[15]),
		.i_io_sw({15'b0,SW[16:0]}),
		.o_io_lcd({temp, LCD_OUT}),
		.o_io_ledg({24'b0,LEDG}),
		.o_io_ledr({15'b0,LEDR}),
		.o_io_hex0(HEX0),
		.o_io_hex1(HEX1),
		.o_io_hex2(HEX2),
		.o_io_hex3(HEX3),
		.o_io_hex4(HEX4),
		.o_io_hex5(HEX5),
		.o_io_hex6(HEX6),
		.o_io_hex7(HEX7),
      .i_io_btn(btn)
		);


		db_fsm inst1(
			.clk(CLOCK_50),
			.rst_n(SW[17]),
			.btn(~KEY[0]),
			.db(btn[0])
		);

		db_fsm inst2(
			.clk(CLOCK_50),
			.rst_n(SW[17]),
			.btn(~KEY[1]),
			.db(btn[1])
		);

		db_fsm inst3(
			.clk(CLOCK_50),
			.rst_n(SW[17]),
			.btn(~KEY[2]),
			.db(btn[2])
		);

		db_fsm inst4(
			.clk(CLOCK_50),
			.rst_n(SW[17]),
			.btn(~KEY[3]),
			.db(btn[3])
		);
	
endmodule
