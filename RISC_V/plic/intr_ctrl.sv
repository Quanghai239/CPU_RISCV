module interrupt_controller(input pclk,
                           input preset_n,
                           input pwrite,
                           input psel,
                           input penable,
                           output pready,
                           input [31:0] paddr,
                           input [31:0] pwdata,
                           output logic [31:0] prdata,
                           input [7:0] IRQ,
                           output pslverr,
                           output intr_ev,
                           output logic [3:0] vecto_no,
                           input I_flag
);

   logic [31:0] ipr;
   logic [31:0] iscr;
   logic [31:0] ier;
   logic [31:0] isr;
   logic [31:0] tmo;
   logic [31:0] ssr;
   logic [31:0] syscr;
   logic [7:0] IRQ_state;

   logic IRQ0_req;
   logic IRQ1_req;
   logic IRQ2_req;
   logic IRQ3_req;
   logic IRQ4_req;
   logic IRQ5_req;
   logic IRQ6_req;
   logic IRQ7_req;

   //ghép lại 1 cụm để nhét vào APB ghi data vào phần R/w*
   assign IRQ_state = {IRQ7_req, IRQ6_req, IRQ5_req, IRQ4_req, IRQ3_req, IRQ2_req, IRQ1_req, IRQ0_req};
   apb_rw apb_protocol(
      .pclk(pclk),
      .preset_n(preset_n),
      .psel(psel),
      .paddr(paddr),
      .penable(penable),
      .pwrite(pwrite),
      .pwdata(pwdata),
      .prdata(prdata),
      .pready(pready),
      .pslverr(pslverr),
      .syscr(syscr),
      .ipr(ipr),
      .iscr(iscr),
      .ier(ier),
      .isr(isr),
      .tmo(tmo),
      .ssr(ssr),
      .IRQ_state(IRQ_state),
      .I_flag(I_flag)
   );

   int_sensing int_sense(
      .pclk(pclk),
      .preset_n(preset_n),
      .IRQ0(IRQ[0]),
      .IRQ1(IRQ[1]),
      .IRQ2(IRQ[2]),
      .IRQ3(IRQ[3]),
      .IRQ4(IRQ[4]),
      .IRQ5(IRQ[5]),
      .IRQ6(IRQ[6]),
      .IRQ7(IRQ[7]),
      .IRQ_enable(ier[7:0]),
      .IRQ_sense(iscr[15:0]),
      .IRQ0_req(IRQ0_req),
      .IRQ1_req(IRQ1_req),
      .IRQ2_req(IRQ2_req),
      .IRQ3_req(IRQ3_req),
      .IRQ4_req(IRQ4_req),
      .IRQ5_req(IRQ5_req),
      .IRQ6_req(IRQ6_req),
      .IRQ7_req(IRQ7_req)
   );

   prio_deter prio_deter(.pclk(pclk),
               .preset_n(preset_n),
               .IRQ0_req(IRQ0_req),
      .IRQ1_req(IRQ1_req),
      .IRQ2_req(IRQ2_req),
      .IRQ3_req(IRQ3_req),
      .IRQ4_req(IRQ4_req),
      .IRQ5_req(IRQ5_req),
      .IRQ6_req(IRQ6_req),
      .IRQ7_req(IRQ7_req),
      .prio_config_A(ipr[7:0]),
      .prio_config_B(ipr[15:8]),
      .prio_config_C(ipr[23:16]),
      .prio_config_D(ipr[31:24]),
      .intr_ev(intr_ev),
      .vecto_no(vecto_no),
      .I_flag(I_flag));
endmodule