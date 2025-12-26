module processor(input i_clk,
                  input i_rst_n,
                  // input e_irq,
                  input [31:0] i_io_sw,
                  input [3:0] i_io_btn,
                  output [31:0] o_io_ledr, o_io_ledg,
                  output [6:0] o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3, o_io_hex4, o_io_hex5, o_io_hex6, o_io_hex7,
                  output [31:0] o_io_lcd
                  );

   logic pready_tmr, pready_plic, pready_uart, pready;
   logic t_irq;
   bit intr_uart;
   logic I_flag, i_bit;
   logic [3:0] vecto_no;

   logic [31:0] prdata_timer, prdata_uart, prdata_plic, pwdata, paddr;
   logic psel_timer, psel_uart, psel_plic, penable, pwrite;

   assign pready = pready_tmr|pready_plic|pready_uart;

   pipelined CPU(.i_clk(i_clk),
                  .i_rst_n(i_rst_n),
                  .e_irq(intr_ev),
                  .t_irq(t_irq),
                  .vecto_no(vecto_no),
                  .o_io_ledr(o_io_ledr),
                  .o_io_ledg(o_io_ledg),
                  .o_io_hex0(o_io_hex0),
                  .o_io_hex1(o_io_hex1),
                  .o_io_hex2(o_io_hex2),
                  .o_io_hex3(o_io_hex3),
                  .o_io_hex4(o_io_hex4),
                  .o_io_hex5(o_io_hex5),
                  .o_io_hex6(o_io_hex6),
                  .o_io_hex7(o_io_hex7),
                  .o_io_lcd(o_io_lcd),
                  .i_io_sw(i_io_sw),
                  .i_io_btn(i_io_btn),
                  .pready(pready),
                  .prdata_timer(prdata_timer),
                  .prdata_uart(prdata_uart),
                  .prdata_plic(prdata_plic),
                  .psel_timer(psel_timer),
                  .psel_uart(psel_uart),
                  .psel_plic(psel_plic),
                  .penable(penable),
                  .pwrite(pwrite),
                  .paddr(paddr),
                  .pwdata(pwdata),
                  .I_flag(I_flag));

   assign i_bit = !I_flag&(intr_ev|t_irq);


   timer timer(.pclk(i_clk),
                  .preset_n(i_rst_n),
                  .psel(psel_timer),
                  .pwrite(pwrite),
                  .penable(penable),
                  .pwdata(pwdata),
                  .paddr(paddr),
                  .prdata(prdata_timer),
                  .pready(pready_tmr),
                  .pslverr(),
                  .intr_timer(t_irq));

   interrupt_controller plic(.pclk(i_clk),
            .preset_n(i_rst_n),
            .pwrite(pwrite),
            .psel(psel_plic),
            .penable(penable),
            .pready(pready_plic),
            .paddr(paddr&32'hFF),
            .pwdata(pwdata),
            .prdata(prdata_plic),
            .IRQ({3'b0,intr_uart,i_io_btn}),
            .pslverr(),
            .intr_ev(intr_ev),
            .vecto_no(vecto_no),
            .I_flag(i_bit)
            );

   APB_UART_top uart(.pclk(i_clk),
                     .presetn(i_rst_n),
                     .psel(psel_uart),
                     .paddr(paddr&32'hFFFF),
                     .penable(penable),
                     .pwrite(pwrite),
                     .pwdata(pwdata),
                     .rxd(),
                     .pready(pready_uart),
                     .pslverr(),
                     .prdata(prdata_uart),
                     .txd(),
                     .itx_thr(),
                     .irx_thr(),
                     .irx_ov(),
                     .i_pe(),
                     .i_fre(),
                     .totalint(intr_uart));
   
endmodule