module wrapper_processor(
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic [31:0] i_io_sw,
    input  logic [3:0]  i_io_btn,
    output logic [31:0] o_io_ledr,
    output logic [31:0] o_io_ledg,
    output logic [6:0]  o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3,
                        o_io_hex4, o_io_hex5, o_io_hex6, o_io_hex7,
    output logic [31:0] o_io_lcd
);

   // Flip-flop registered inputs
   logic [31:0] i_io_sw_ff;
   logic [3:0]  i_io_btn_ff;

   // Flip-flop registered outputs
   logic [31:0] o_io_ledr_int, o_io_ledg_int;
   logic [6:0]  o_io_hex0_int, o_io_hex1_int, o_io_hex2_int, o_io_hex3_int;
   logic [6:0]  o_io_hex4_int, o_io_hex5_int, o_io_hex6_int, o_io_hex7_int;
   logic [31:0] o_io_lcd_int;

   // Input FF stage
   always_ff @(posedge i_clk or negedge i_rst_n) begin
      if (!i_rst_n) begin
         i_io_sw_ff  <= 32'b0;
         i_io_btn_ff <= 4'b0;
      end else begin
         i_io_sw_ff  <= i_io_sw;
         i_io_btn_ff <= i_io_btn;
      end
   end

   // Instantiate the DUT (processor)
   processor dut (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .i_io_sw(i_io_sw_ff),
      .i_io_btn(i_io_btn_ff),
      .o_io_ledr(o_io_ledr_int),
      .o_io_ledg(o_io_ledg_int),
      .o_io_hex0(o_io_hex0_int),
      .o_io_hex1(o_io_hex1_int),
      .o_io_hex2(o_io_hex2_int),
      .o_io_hex3(o_io_hex3_int),
      .o_io_hex4(o_io_hex4_int),
      .o_io_hex5(o_io_hex5_int),
      .o_io_hex6(o_io_hex6_int),
      .o_io_hex7(o_io_hex7_int),
      .o_io_lcd(o_io_lcd_int)
   );

   // Output FF stage
   always_ff @(posedge i_clk or negedge i_rst_n) begin
      if (!i_rst_n) begin
         o_io_ledr <= 32'b0;
         o_io_ledg <= 32'b0;
         o_io_hex0 <= 7'b0;
         o_io_hex1 <= 7'b0;
         o_io_hex2 <= 7'b0;
         o_io_hex3 <= 7'b0;
         o_io_hex4 <= 7'b0;
         o_io_hex5 <= 7'b0;
         o_io_hex6 <= 7'b0;
         o_io_hex7 <= 7'b0;
         o_io_lcd  <= 32'b0;
      end else begin
         o_io_ledr <= o_io_ledr_int;
         o_io_ledg <= o_io_ledg_int;
         o_io_hex0 <= o_io_hex0_int;
         o_io_hex1 <= o_io_hex1_int;
         o_io_hex2 <= o_io_hex2_int;
         o_io_hex3 <= o_io_hex3_int;
         o_io_hex4 <= o_io_hex4_int;
         o_io_hex5 <= o_io_hex5_int;
         o_io_hex6 <= o_io_hex6_int;
         o_io_hex7 <= o_io_hex7_int;
         o_io_lcd  <= o_io_lcd_int;
      end
   end

endmodule
