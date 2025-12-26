module int_sensing(input pclk,
                  input preset_n,
                  input IRQ0, IRQ1, IRQ2, IRQ3, IRQ4, IRQ5, IRQ6, IRQ7,
                  input [7:0] IRQ_enable,
                  input [15:0] IRQ_sense,
                  output IRQ0_req, IRQ1_req, IRQ2_req, IRQ3_req, IRQ4_req, IRQ5_req, IRQ6_req, IRQ7_req
                  );

   logic IRQ0_hit, IRQ1_hit, IRQ2_hit, IRQ3_hit, IRQ4_hit, IRQ5_hit, IRQ6_hit, IRQ7_hit;

   logic irq0_fall, irq0_rise, irq0_both, irq0_is_0;
   logic irq1_fall, irq1_rise, irq1_both, irq1_is_0;
   logic irq2_fall, irq2_rise, irq2_both, irq2_is_0;
   logic irq3_fall, irq3_rise, irq3_both, irq3_is_0;
   logic irq4_fall, irq4_rise, irq4_both, irq4_is_0;
   logic irq5_fall, irq5_rise, irq5_both, irq5_is_0;
   logic irq6_fall, irq6_rise, irq6_both, irq6_is_0;
   logic irq7_fall, irq7_rise, irq7_both, irq7_is_0;

   logic IRQ0_hit_r, IRQ1_hit_r, IRQ2_hit_r, IRQ3_hit_r, IRQ4_hit_r, IRQ5_hit_r, IRQ6_hit_r, IRQ7_hit_r;

   edge_detection IRQ0_detector(.pclk(pclk),
                           .preset_n(preset_n),
                           .data_d(IRQ0),
                           .rs_det(irq0_rise),
                           .fl_det(irq0_fall),
                           .ed_det(irq0_both),
                           .lv_det(irq0_is_0));

   edge_detection IRQ1_detector(.pclk(pclk),
                           .preset_n(preset_n),
                           .data_d(IRQ1),
                           .rs_det(irq1_rise),
                           .fl_det(irq1_fall),
                           .ed_det(irq1_both),
                           .lv_det(irq1_is_0));

edge_detection IRQ2_detector(.pclk(pclk),
                           .preset_n(preset_n),
                           .data_d(IRQ2),
                           .rs_det(irq2_rise),
                           .fl_det(irq2_fall),
                           .ed_det(irq2_both),
                           .lv_det(irq2_is_0));

edge_detection IRQ3_detector(.pclk(pclk),
                           .preset_n(preset_n),
                           .data_d(IRQ3),
                           .rs_det(irq3_rise),
                           .fl_det(irq3_fall),
                           .ed_det(irq3_both),
                           .lv_det(irq3_is_0));

edge_detection IRQ4_detector(.pclk(pclk),
                           .preset_n(preset_n),
                           .data_d(IRQ4),
                           .rs_det(irq4_rise),
                           .fl_det(irq4_fall),
                           .ed_det(irq4_both),
                           .lv_det(irq4_is_0));

edge_detection IRQ5_detector(.pclk(pclk),
                           .preset_n(preset_n),
                           .data_d(IRQ5),
                           .rs_det(irq5_rise),
                           .fl_det(irq5_fall),
                           .ed_det(irq5_both),
                           .lv_det(irq5_is_0));

edge_detection IRQ6_detector(.pclk(pclk),
                           .preset_n(preset_n),
                           .data_d(IRQ6),
                           .rs_det(irq6_rise),
                           .fl_det(irq6_fall),
                           .ed_det(irq6_both),
                           .lv_det(irq6_is_0));

edge_detection IRQ7_detector(.pclk(pclk),
                           .preset_n(preset_n),
                           .data_d(IRQ7),
                           .rs_det(irq7_rise),
                           .fl_det(irq7_fall),
                           .ed_det(irq7_both),
                           .lv_det(irq7_is_0));

   //NMI has been hit?
   always_comb begin
      IRQ0_hit = 1'b0;
      case (IRQ_sense[1:0])
         2'b00: IRQ0_hit = irq0_is_0;
         2'b01: IRQ0_hit = irq0_fall;
         2'b10: IRQ0_hit = irq0_rise;
         2'b11: IRQ0_hit = irq0_both;
         default: IRQ0_hit = 1'b0;
      endcase
   end  

//External Interrupt has been hit?

   always_comb begin
      IRQ1_hit = 1'b0;
      case (IRQ_sense[3:2])
         2'b00: IRQ1_hit = irq1_is_0;
         2'b01: IRQ1_hit = irq1_fall;
         2'b10: IRQ1_hit = irq1_rise;
         2'b11: IRQ1_hit = irq1_both;
         default: IRQ1_hit = 1'b0;
      endcase
   end 

   always_comb begin
      IRQ2_hit = 1'b0;
      case (IRQ_sense[5:4])
         2'b00: IRQ2_hit = irq2_is_0;
         2'b01: IRQ2_hit = irq2_fall;
         2'b10: IRQ2_hit = irq2_rise;
         2'b11: IRQ2_hit = irq2_both;
         default: IRQ2_hit = 1'b0;
      endcase
   end 

   always_comb begin
      IRQ3_hit = 1'b0;
      case (IRQ_sense[7:6])
         2'b00: IRQ3_hit = irq3_is_0;
         2'b01: IRQ3_hit = irq3_fall;
         2'b10: IRQ3_hit = irq3_rise;
         2'b11: IRQ3_hit = irq3_both;
         default: IRQ3_hit = 1'b0;
      endcase
   end 

   always_comb begin
      IRQ4_hit = 1'b0;
      case (IRQ_sense[9:8])
         2'b00: IRQ4_hit = irq4_is_0;
         2'b01: IRQ4_hit = irq4_fall;
         2'b10: IRQ4_hit = irq4_rise;
         2'b11: IRQ4_hit = irq4_both;
         default: IRQ4_hit = 1'b0;
      endcase
   end 

   always_comb begin
      IRQ5_hit = 1'b0;
      case (IRQ_sense[11:10])
         2'b00: IRQ5_hit = irq5_is_0;
         2'b01: IRQ5_hit = irq5_fall;
         2'b10: IRQ5_hit = irq5_rise;
         2'b11: IRQ5_hit = irq5_both;
         default: IRQ5_hit = 1'b0;
      endcase
   end 

   always_comb begin
      IRQ6_hit = 1'b0;
      case (IRQ_sense[13:12])
         2'b00: IRQ6_hit = irq6_is_0;
         2'b01: IRQ6_hit = irq6_fall;
         2'b10: IRQ6_hit = irq6_rise;
         2'b11: IRQ6_hit = irq6_both;
         default: IRQ6_hit = 1'b0;
      endcase
   end 

   always_comb begin
      IRQ7_hit = 1'b0;
      case (IRQ_sense[15:14])
         2'b00: IRQ7_hit = irq7_is_0;
         2'b01: IRQ7_hit = irq7_fall;
         2'b10: IRQ7_hit = irq7_rise;
         2'b11: IRQ7_hit = irq7_both;
         default: IRQ7_hit = 1'b0;
      endcase
   end

   //Internal Interrupt has been hit?

            
   always@(posedge pclk, negedge preset_n) begin
    if(!preset_n) begin
      IRQ0_hit_r     <= 1'b0;
      IRQ1_hit_r     <= 1'b0;
      IRQ2_hit_r     <= 1'b0;
      IRQ3_hit_r     <= 1'b0;
      IRQ4_hit_r     <= 1'b0;
      IRQ5_hit_r     <= 1'b0;
      IRQ6_hit_r     <= 1'b0;
      IRQ7_hit_r     <= 1'b0;
    end else begin
      IRQ0_hit_r     <= IRQ0_hit;
      IRQ1_hit_r     <= IRQ1_hit;
      IRQ2_hit_r     <= IRQ2_hit;
      IRQ3_hit_r     <= IRQ3_hit;
      IRQ4_hit_r     <= IRQ4_hit;
      IRQ5_hit_r     <= IRQ5_hit;
      IRQ6_hit_r     <= IRQ6_hit;
      IRQ7_hit_r     <= IRQ7_hit;
    end
end

   //trừ NMI ra, thì phải được kích hoạt cho phép ngắt thì mới tạo ra tín hiệu ngắt thật sự
  assign    IRQ0_req = IRQ0_hit_r & IRQ_enable[0];
  assign    IRQ1_req = IRQ1_hit_r & IRQ_enable[1];
  assign    IRQ2_req = IRQ2_hit_r & IRQ_enable[2];
  assign    IRQ3_req = IRQ3_hit_r & IRQ_enable[3];
  assign    IRQ4_req = IRQ4_hit_r & IRQ_enable[4];
  assign    IRQ5_req = IRQ5_hit_r & IRQ_enable[5];
  assign    IRQ6_req = IRQ6_hit_r & IRQ_enable[6];
  assign    IRQ7_req = IRQ7_hit_r & IRQ_enable[7];

endmodule