module apb_master(input pclk,
                  input preset_n,
                  input [11:0] apb_region,   //vùng apb
                  input apb_en,           //lệnh đó có liên quan tới vùng apb
                  input [31:0] wdata,      //data store vào lsu
                  input wr_en,         //tín hiệu cho phép ghi(có phải là lệnh store 0)
                  input pready,
                  input [31:0] prdata_timer, prdata_uart, prdata_plic,
                  output psel_timer, psel_uart, psel_plic,
                  output logic penable, pwrite,
                  output logic [31:0] paddr, pwdata,
                  output logic [31:0] to_cpu_data
                  );

   typedef enum bit [1:0] {IDLE, SETUP, ACCESS} state; 

   state cs, ns;

   logic [31:0] prdata;
   
   //----------------------APB STATE MACHINE--------------------------
   always @(posedge pclk or negedge preset_n) begin
      if (!preset_n) cs <= IDLE;
      else cs <= ns;
   end

   logic psel_q, psel_d, penable_q, penable_d, pwrite_q, pwrite_d;
   logic [31:0] pwdata_q, pwdata_d, paddr_q, paddr_d, to_cpu_data_q, to_cpu_data_d;

   assign penable = penable_d;
   assign pwrite = pwrite_d;
   assign paddr = paddr_d;
   assign pwdata = pwdata_d;
   assign to_cpu_data = to_cpu_data_d;


   always @(posedge pclk) begin
      if (!preset_n) begin
         psel_q <= 1'b0;
         penable_q <= 1'b0;
         pwrite_q <= 1'b0;
         pwdata_q <= 32'h0;
         paddr_q <= 32'h0;
         to_cpu_data_q <= 32'h0;
      end
      else begin
         psel_q <= psel_d;
         penable_q <= penable_d;
         pwrite_q <= pwrite_d;
         pwdata_q <= pwdata_d;
         paddr_q <= paddr_d;
         to_cpu_data_q <= to_cpu_data_d;
      end
   end

   always_comb begin
      case (cs)
         IDLE: ns = apb_en? SETUP : IDLE;
         SETUP: ns = ACCESS;
         ACCESS: ns = pready&apb_en? SETUP :                           //vẫn còn lệnh chờ đợi để ghi data vào IP
                                          (!pready&apb_en)? ACCESS : IDLE;    //nếu vẫn còn lệnh, nhưng chưa sẵn sàng thì đợi
         default: ns = IDLE;
      endcase
   end

   always_comb begin       //always_comb điều kiện rất chặt, 0 khuyến khích dùng khi có case
      case (cs)
         IDLE: begin
            psel_d = 1'b0;
            penable_d = 1'b0;
            pwrite_d = 1'b0;
            paddr_d = 32'b0;
            pwdata_d = 32'h0;
            to_cpu_data_d = to_cpu_data_q;
         end
         SETUP: begin
            psel_d = 1'b1;
            penable_d = 1'b0;
            pwrite_d = wr_en;
            paddr_d = {20'b0,apb_region};
            pwdata_d = wr_en? wdata : pwdata_q;
            to_cpu_data_d = to_cpu_data_q;
         end
         ACCESS: begin
            psel_d = 1'b1;
            penable_d = 1'b1;
            pwrite_d = pwrite_q;
            paddr_d = paddr_q;
            pwdata_d = pwdata_q;
            to_cpu_data_d = !pwrite_d&pready? prdata : to_cpu_data_q;
         end
         default: begin
            psel_d = 1'b0;
            penable_d = 1'b0;
            pwrite_d = 1'b0;
            paddr_d = 32'b0;
            pwdata_d = 32'h0;
            to_cpu_data_d = to_cpu_data_q;
         end
      endcase
   end

   //-------------------ADDRESS DECODE IP------------------------

   assign {psel_plic, psel_uart, psel_timer, prdata} = (paddr_d[11:8] == 4'b0000)? {2'b0, psel_d, prdata_timer} :
                                                (paddr_d[11:8] == 4'b0001)? {1'b0, psel_d, 1'b0, prdata_uart} : {psel_d, 2'b0, prdata_plic};

endmodule