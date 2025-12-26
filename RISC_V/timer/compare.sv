module compare(input pclk,
               input preset_n,
               input [1:0] trig_clr,
               input [31:0] last_cnt,
               input [31:0] cnt,
               input load,
	           input en,
               input updown,
               output ovf_trig,
               output udf_trig
               );


reg ovf_trig_reg, udf_trig_reg;



always @(posedge pclk or negedge preset_n) begin
	if (!preset_n) ovf_trig_reg <= 1'b0;
	else if (trig_clr[0]) ovf_trig_reg <= 1'b0;
	else if ((last_cnt == 32'hffffffff ) && (cnt == 0) && (!updown) && en && (!load)) ovf_trig_reg <= 1'b1;
	else ovf_trig_reg <= 1'b0;
end

assign ovf_trig = ovf_trig_reg;



always @(posedge pclk or negedge preset_n) begin
	if (!preset_n) udf_trig_reg <= 1'b0;
	else if (trig_clr[1]) udf_trig_reg <= 1'b0;	
	else if (en && (last_cnt == 0) && (cnt == 32'hffffffff) && updown && (!load)) udf_trig_reg <= 1'b1;
	else udf_trig_reg <= 1'b0;	
end

assign udf_trig = udf_trig_reg;



endmodule
