`define CSR_W           2'b01
`define CSR_S           2'b10
`define CSR_C           2'b11

`define MTVEC_DIRECT    2'b00
`define MTVEC_VECTORED  2'b01

module CSR(input i_clk,
            input i_rst_n,
            input e_irq, t_irq,      //nguon ngat do external va timer gay ra
            input csr_en,
            input pcsel_urg,
            input [11:0] csr_addr,
            input [2:0] csr_op,
            input [31:0] csr_data,
            input [31:0] pc,     //chua biet nen dung pc j
            input [31:0] pcsaveurg,
            input excep_en, intr_en,
            input mret,
            input [3:0] intr_cause, exception_cause,
            output logic [31:0] csr_rdata,
            output logic [31:0] pc_trap,
            output logic [31:0] mepc,
            output logic mie, meie, mtie,
            output logic meip, mtip
);

   parameter MSTATUS = 12'h300;
   parameter MIE = 12'h304;
   parameter MEPC = 12'h341;
   parameter MCAUSE = 12'h342;
   parameter MTVEC = 12'h305;
   parameter MIP = 12'h344;

   logic [31:0] csr_wdata;
   logic mpie, csr_write_en, csr_write;
   logic [31:0] mcause;
   logic mstatus_addr, mie_addr, mepc_addr, mcause_addr, mtvec_addr, mip_addr;
   logic [29:0] mtvec_base, mepc_base;
   logic [1:0] mtvec_mode;

   //---------CSR ADDRESS--------
   assign mstatus_addr = (csr_addr == MSTATUS);
   assign mie_addr = (csr_addr == MIE);
   assign mepc_addr = (csr_addr == MEPC);
   assign mcause_addr = (csr_addr == MCAUSE);
   assign mtvec_addr = (csr_addr == MTVEC);
   assign mip_addr = (csr_addr == MIP);
   //mip register

   //---------READ CSR CONTENT--------
   always_comb begin
      case (csr_addr)
         MSTATUS: csr_rdata = {24'b0, mpie, 3'b0, mie, 3'b0};
         MCAUSE: csr_rdata = mcause;
         MEPC: csr_rdata = {mepc_base, 2'b00};
         MIE: csr_rdata = {20'b0, meie, 3'b0, mtie,7'b0};
         MTVEC: csr_rdata = {mtvec_base, mtvec_mode};
         MIP: csr_rdata = {20'b0, meip, 3'b0, mtip, 7'b0};
         default: csr_rdata = 32'h0;
      endcase
   end

   //----------WRITE DATA------------------
   always_comb begin
      case (csr_op[1:0])
         `CSR_W: csr_wdata = csr_data;
         `CSR_S: csr_wdata = csr_rdata | csr_data;  //bat cac bit nao cua thanh ghi csr = 1 tuong duong vs or ket qua muon ghi vao 
         `CSR_C: csr_wdata = csr_rdata &~ csr_data; //tuong tu, clear bit nao cua thanh ghi csr =1 tuong duong vs nand ket qua muon ghi vao
         default: csr_wdata = csr_rdata;
      endcase
   end

   assign csr_write = !(csr_op == 3'b000); //co 6 loai, neu thuoc thi cho phep ghi
   assign csr_write_en = csr_en & csr_write & ~excep_en;  //cho phep ghi, lenh ghi va khong co sai sot j ve lenh

   always @(posedge i_clk) begin
      if (!i_rst_n) begin
         mie <= 1'b0;   
         mpie <= 1'b1;
      end
      else if (intr_en|excep_en) begin
         mie <= 1'b0;  //đang có ngắt được xử lý, nên phải tắt chế độ ngắt đi
         mpie <= mie;   //lấy trạng thái bit cho phép hiện tại lưu để lần sau sử dụng
      end
      else if (mret) begin
         mie <= mpie;      //đã thoát ngắt, nên ta phải lấy trạng thái mie trước đó ra
         mpie <= 1'b1;
      end
      else if (csr_write_en && mstatus_addr) begin
         mie <= csr_wdata[3]; //nếu ta chủ động ghi data mà không phải do ngắt
         mpie <= 1'b1;
      end
      else begin
         mie <= mie;
         mpie <= mpie;
      end
   end


   always @(posedge i_clk) begin
      if (!i_rst_n) mcause <= 32'h0;    //
      else if (intr_en) mcause <= {1'b1,27'b0,intr_cause};  //ngắt, nên bit 31 được bật
      else if (excep_en) mcause <= {28'b0,exception_cause};     //exception, nên bit 31 tắt
      else if (csr_write_en && mcause_addr) mcause <= csr_wdata; //nếu ta chủ động ghi data mà không phải do ngắt
      else mcause <= mcause;
   end

   always @(posedge i_clk) begin
      if (!i_rst_n) mepc <= 32'h0;    //
      else if (intr_en|excep_en) mepc <= pc;  //pc j thì chưa biết
      else if (pcsel_urg) mepc <= pcsaveurg;
      else if (csr_write_en && mepc_addr) mepc <= csr_wdata; //nếu ta chủ động ghi data mà không phải do ngắt
      else mepc <= mepc;
   end

   always @(posedge i_clk) begin
      if (!i_rst_n) mtvec_base <= 30'h0;    //
      else if (csr_write_en && mtvec_addr) mtvec_base <= csr_wdata[31:2]; //nếu ta chủ động ghi data mà không phải do ngắt
      else mtvec_base <= mtvec_base;
   end

   always @(posedge i_clk) begin
      if (!i_rst_n) mtvec_mode <= 2'h0;    //
      else if (csr_write_en && mtvec_addr && (csr_wdata[1] == 1'b0)) mtvec_mode <= csr_wdata[1:0]; //nếu ta chủ động ghi data mà không phải do ngắt
      else mtvec_mode <= mtvec_mode;
   end

   always @(posedge i_clk) begin
      if (!i_rst_n) begin
         meie <= 1'b0;    //
         mtie <= 1'b0;     //
      end
      else if (csr_write_en && mie_addr) begin
         meie <= csr_wdata[11]; //nếu ta chủ động ghi data mà không phải do ngắt
         mtie <= csr_wdata[7];
      end
      else begin
         meie <= meie;
         mtie <= mtie;
      end
   end

   always @(posedge i_clk) begin    //phong truong hop co ngat dang duoc xu ly
      if (!i_rst_n) begin
         meip <= 1'b0;
         mtip <= 1'b0;
      end
      else begin
         meip <= e_irq;
         mtip <= t_irq;
      end
   end

   //--------------------TRAP CONDITIONS--------------------


   // assign pc_trap = (intr_en|excep_en)? 
   //    mtvec_mode[0]? {mtvec_base + (intr_en? {26'b0,intr_cause} : 30'b0), 2'b0}
   //                   : {mtvec_base,2'b0} : 32'b0;

   always_comb begin
      pc_trap = 32'b0;
      if (intr_en|excep_en) begin
         if (mtvec_mode[0]) begin
            if (intr_en) pc_trap = {mtvec_base+intr_cause,2'b0};
            else pc_trap = {mtvec_base,2'b0};
         end
         else pc_trap = {mtvec_base,2'b0};
      end
   end


endmodule