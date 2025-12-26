module edge_detection(input pclk,
                           input preset_n,
                           input data_d,
                           output rs_det,
                           output fl_det,
                           output ed_det,
                           output lv_det);

   bit data_q;

   always @(posedge pclk, negedge preset_n) begin
      if (!preset_n) data_q <= 1'b0;
      else data_q <= data_d;
   end

   assign rs_det = ~data_q&data_d;
   assign fl_det = data_q&~data_d;
   assign ed_det = (data_d != data_q);
   assign lv_det = !data_q;

endmodule