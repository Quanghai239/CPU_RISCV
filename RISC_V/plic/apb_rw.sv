module apb_rw(input pclk,
            input preset_n,
            input pwrite,
            input psel,
            input penable,
            input [31:0] paddr,
            input [31:0] pwdata,
            output logic [31:0] prdata,
            output pready,
            output pslverr,
            output logic [31:0] syscr,
            output logic [31:0] ipr,
            output logic [31:0] iscr,
            output logic [31:0] ier,
            output logic [31:0] isr,
            // output logic [31:0] tmo,
            output logic [31:0] tmo,
            output logic [31:0] ssr,
            input [7:0] IRQ_state,
            input I_flag
            );

   
   assign pready = 1'b1;      //?

   logic [6:0] psel_reg;
   logic tmo_en;

   always @(*) begin
      case (paddr[7:0])
         8'h00:psel_reg = 7'b0000001; //SYSCR
         8'h04:psel_reg = 7'b0000010; //IPR
         8'h08:psel_reg = 7'b0000100; //IER
         8'h0C:psel_reg = 7'b0001000; //ISCR
         8'h10:psel_reg = 7'b0010000; //ISR
         8'h14:psel_reg = 7'b0100000; //TMO
         8'h18:psel_reg = 7'b1000000; //SSR
         default: psel_reg = 7'h0;
      endcase
   end

   always @(posedge pclk, negedge preset_n) begin
      if (!preset_n) syscr <= 32'h0;
      else if (I_flag) syscr <= syscr | 32'h4;      //nếu có có ngắt đang chờ thì bật tmo_en lên
      else if (tmo_en&&((tmo == 32'h0)||((tmo != 32'h0)&&(!I_flag)))) syscr <= syscr & 32'hFFFFFFFB; 
      else if (psel&pwrite&&penable&&pready&&psel_reg[0]) syscr <= {28'b0,pwdata[3:2],2'b0};   //vậy tín hiệu TMO_EN và SLVERR_EN là gì?
      else syscr <= syscr;
   end

   assign tmo_en = syscr[2];

   //---------------Interrupt priority register---------------------------
   always @(posedge pclk, negedge preset_n) begin
      if (!preset_n) ipr <= 32'h0;
      else if (psel&pwrite&&penable&&pready&&psel_reg[1]) ipr <= {1'b0,pwdata[30:28],1'b0,pwdata[26:24],1'b0,pwdata[22:20],1'b0,pwdata[18:16],1'b0,pwdata[14:12],1'b0,pwdata[10:8],1'b0,pwdata[6:4],1'b0,pwdata[2:0]};
      else ipr <= ipr;
   end

   always @(posedge pclk, negedge preset_n) begin
      if (!preset_n) ier <= 32'h0;
      else if (psel&pwrite&&penable&&pready&&psel_reg[2]) ier <= pwdata;
      else ier <= ier;
   end

   always @(posedge pclk, negedge preset_n) begin
      if (!preset_n) iscr <= 32'h0;
      else if (psel&pwrite&&penable&&pready&&psel_reg[3]) iscr <= pwdata;
      else iscr <= iscr;
   end


   // IRQ Status Register have special register
   //R/W*: which means write 1 only, other value are unacceptable
   //ISRA for external interrupt, so it's depend on statue of external interrupt
   always @(posedge pclk, negedge preset_n) begin
      if (!preset_n) isr <= 32'h0;
      else if (psel&pwrite&&penable&&pready&&psel_reg[4]) isr <= ~pwdata&isr;
      else isr <= isr|IRQ_state;
   end

   always @(posedge pclk, negedge preset_n) begin
      if (!preset_n) tmo <= 32'hFF;   //set về giá trị default mặc định để đếm nếu có time out
      // if (!preset_n) tmo <= 32'hFFFFFFFF;
      else if (psel&pwrite&&penable&&pready&&psel_reg[5]) tmo <= pwdata&32'hFF;
      else if (tmo_en) tmo <= tmo-1;
      else tmo <= 32'hFF;
      // else tmo <= 32'hFFFFFFFF;
   end

   always @(posedge pclk, negedge preset_n) begin
      if (!preset_n) ssr <= 32'h0;
      else if (psel&pwrite&&penable&&pready&&psel_reg[6]) ssr <= {30'b0,pwdata[1:0]};    //vẫn được ghi bởi APB?
      else ssr <= ssr;
   end

   always @(*) begin
      if (psel&&(~pwrite)&&penable&&pready) begin
         case (psel_reg)
            7'h01: prdata = syscr;
            7'h02: prdata = ipr;
            7'h04: prdata = ier;
            7'h08: prdata = iscr;
            7'h10: prdata = isr;
            7'h20: prdata = tmo;
            7'h40: prdata = ssr;
            default: prdata = 32'h0;
         endcase
      end
      else prdata = prdata;
   end

   assign pslverr = psel & ~|psel_reg;
endmodule