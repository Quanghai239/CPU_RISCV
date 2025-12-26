
module BCLK_Generator(

//Input from clock generator, system, apb interface, tx and rx
input pclk,
input presetn,
input [10:0] div_val,
input tx_bclk_en,
input rx_bclk_en,

//Input from tx and rx 
output bclk_rx,
output bclk_tx) ;

reg [10:0] b_regrx;
reg [10:0] b_regrx_next;

reg [10:0] b_regtx;
reg [10:0] b_regtx_next;


always@(posedge pclk or negedge presetn) begin
	if(~presetn) begin
		b_regrx <= 0;
		b_regtx <= 0;
		end
	else begin
		b_regrx <= b_regrx_next;
		b_regtx <= b_regtx_next;
		end
	end

//bclk generator for rx
always@(*) begin
	if(rx_bclk_en) 
		if(b_regrx == div_val)
			b_regrx_next = 1;
		else
			b_regrx_next = b_regrx + 1;
	else
		b_regrx_next = 0;
	end
	
//bclk generator for tx
always@(*) begin
	if(tx_bclk_en) 
		if(b_regtx == div_val)
			b_regtx_next = 1;
		else
			b_regtx_next = b_regtx + 1;
	else 
		b_regtx_next = 0;
	end

assign bclk_rx = (b_regrx == 1);
assign bclk_tx = (b_regtx == 1);

endmodule