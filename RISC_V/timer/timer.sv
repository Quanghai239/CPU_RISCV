module timer(input pclk,
	     input preset_n,
	     input psel,
	     input pwrite,
	     input penable,
	     input [31:0] pwdata,
	     input [31:0] paddr,
	     output logic [31:0] prdata,
	     output pready,
	     output pslverr,
		  output intr_timer
	     );

// khai bao trung gian


//wire
wire en, load, updown;
wire [1:0] cks;
wire [1:0] clr_flag;
wire clk_int;
wire ovf_flag, udf_flag;
wire [31:0] tdr, last_cnt, cnt;
wire count_ena;
//clock select

assign intr_timer = ovf_flag||udf_flag;

clk_sel sys_clk (.pclk(pclk),
		 .preset_n(preset_n),
		 .cks(cks),
		 .internal_clk(clk_int),
		 .clk_ena(count_ena)
		 );

//counter

counter counter_module (.pclk(pclk),
			.preset_n(preset_n),
			.load(load),
			.en(en),
			.updown(updown),
			.tdr(tdr),
			.clk_int(clk_int),
			.cnt(cnt),
			.last_cnt(last_cnt),
			.count_enable(count_ena)
			);

//compare

compare compare_module (.pclk(pclk),
			.preset_n(preset_n),
			.trig_clr(clr_flag),
			.last_cnt(last_cnt),
			.cnt(cnt),
			.en(en),
			.load(load),
			.updown(updown),
			.ovf_trig(ovf_flag),
			.udf_trig(udf_flag)
			);

//write read control
rw_control reg_control (.pclk(pclk),
			.preset_n(preset_n),
			.psel(psel),
			.pwrite(pwrite),
			.penable(penable),
			.ovf_trig(ovf_flag),
			.udf_trig(udf_flag),
			.paddr(paddr),
			.pwdata(pwdata),
			.prdata(prdata),
			.pready(pready),
			.pslverr(pslverr),
			.en(en),
			.load(load),
			.updown(updown),
			.tdr(tdr),
			.clr_trig(clr_flag),
			.cks(cks)
			);


endmodule
