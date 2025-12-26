`timescale 1ns/1ps

module interrupt_controller_tb;

   // Clock & reset
   reg pclk;
   reg preset_n;

   // APB signals
   reg pwrite;
   reg psel;
   reg penable;
   reg [31:0] paddr;
   reg [31:0] pwdata;
   wire [31:0] prdata;
   wire pready;
   wire pslverr;

   // IRQ signals
   reg [7:0] IRQ;
   reg I_flag;

   wire intr_ev;
   wire [3:0] vecto_no;

   // DUT
   interrupt_controller DUT(
      .pclk(pclk),
      .preset_n(preset_n),
      .pwrite(pwrite),
      .psel(psel),
      .penable(penable),
      .pready(pready),
      .paddr(paddr),
      .pwdata(pwdata),
      .prdata(prdata),
      .IRQ(IRQ),
      .pslverr(pslverr),
      .intr_ev(intr_ev),
      .vecto_no(vecto_no),
      .I_flag(I_flag)
   );

   // Clock generation
   always #5 pclk = ~pclk;

   // APB Write Task
   task apb_write(input [31:0] addr, input [31:0] data);
   begin
      @(posedge pclk);
      psel   <= 1;
      pwrite <= 1;
      penable <= 0;
      paddr  <= addr;
      pwdata <= data;

      @(posedge pclk);
      penable <= 1;

      @(posedge pclk);
      psel <= 0;
      pwrite <= 0;
      penable <= 0;
   end
   endtask


   initial begin
      // Init
      pclk = 0;
      preset_n = 0;
      psel = 0;
      pwrite = 0;
      penable = 0;
      paddr = 0;
      pwdata = 0;
      IRQ = 8'b0;
      I_flag = 0;

 #5     preset_n = 1;
 apb_write(8'h0c,32'haaaaaaaa);
 #5 
 apb_write(8'h08,32'hffffffff);
 #5

 IRQ=8'hff;
 #5 IRQ=8'h00;
 
 end
 

endmodule
