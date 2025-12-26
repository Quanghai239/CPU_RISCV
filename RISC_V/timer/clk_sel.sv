module clk_sel(input pclk,
	       input preset_n,
	       input [1:0] cks,
		   output clk_ena,
               output internal_clk
               );

wire pclk2, pclk4, pclk8, pclk16;
reg clk2, clk4, clk8, clk16;
reg internal_clk_reg;
reg pre_clk_in, reg_clk_in_ena;

always @(pclk2 or pclk4 or pclk8 or pclk16) begin
	case (cks)
	2'b00: internal_clk_reg = pclk2;
	2'b01: internal_clk_reg = pclk4;
	2'b10: internal_clk_reg = pclk8;
	2'b11: internal_clk_reg = pclk16;
	default: internal_clk_reg = 1'b0;
	endcase
end

assign internal_clk = internal_clk_reg;

 always @(posedge pclk) begin
    pre_clk_in <= internal_clk_reg;
    reg_clk_in_ena <= (internal_clk_reg & ~pre_clk_in);
  end

  assign clk_ena = reg_clk_in_ena;


always @(posedge pclk or negedge preset_n) begin
	if (!preset_n) clk2 <= 1'b0;
	else clk2 <= !clk2;	
end

assign pclk2 = clk2; 

always @(posedge pclk2 or negedge preset_n) begin
	if (!preset_n) clk4 <= 1'b0;
	else clk4 <= !clk4;
end

assign pclk4 = clk4; 

always @(posedge pclk4 or negedge preset_n) begin
	if (!preset_n) clk8 <= 1'b0;
	else clk8 <= !clk8;
end

assign pclk8 = clk8; 
always @(posedge pclk8 or negedge preset_n) begin
	if (!preset_n) clk16 <= 1'b0;
	else clk16 <= !clk16;
end

assign pclk16 = clk16; 


endmodule
