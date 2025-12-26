module counter (
    input pclk,
    input preset_n,
    input load,
    input en,
    input updown,
    input clk_int,
    input count_enable,
    input [31:0] tdr,
    output [31:0] cnt,
    output [31:0] last_cnt
);



  reg [31:0] last_cnt_reg, cnt_reg;
  reg last_clk_int;



  always @(posedge pclk or negedge preset_n) begin
    if (!preset_n) cnt_reg <= 32'd0;
    else if (load) cnt_reg <= tdr;
    else if (en) cnt_reg <= count_enable ? (updown ? cnt_reg - 1'b1 : cnt_reg + 1'b1) : cnt_reg;
    else cnt_reg <= cnt_reg;

  end

  assign cnt = cnt_reg;

  always @(posedge pclk or negedge preset_n) begin
    if (!preset_n) last_cnt_reg <= 32'd0;
    else last_cnt_reg <= cnt_reg;
  end
  assign last_cnt = last_cnt_reg;

endmodule

