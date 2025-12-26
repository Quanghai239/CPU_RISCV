module pc_intr(input i_clk,
            input i_rst_n,
            input intr,
            input excep,
            input flush_ID, flush_EX,
            input [31:0] pc_IF, pc_ID, pc_EX,
            output logic [31:0] pc4save);

   logic flush_ID_q, flush_ID_qq, flush_EX_q;

   always @(posedge i_clk) begin
      flush_ID_q <= flush_ID;
      flush_EX_q <= flush_EX;
      flush_ID_qq <= flush_ID_q;
   end

   always @(posedge i_clk, negedge i_rst_n) begin
      if (!i_rst_n) pc4save <= 32'b0;
      else if ((!flush_ID_q && !flush_EX_q) || excep) pc4save <= pc_IF;    //nếu ngắt xảy ra thì phải lưu thằng còn tồn tại trước khi nó bị xóa
      else if (!flush_EX_q || (!flush_ID_qq && intr)) pc4save <= pc_ID;     //tương tự, ta sẽ lưu thằng EX nhất nếu có hazard
      else pc4save <= pc_EX;        //cuối cùng, nếu 0 còn cái gì đặc biệt, ta cứ lưu EX
   end
endmodule