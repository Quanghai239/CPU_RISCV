module PCNEXT (input i_clk,
               input i_rst_n,
               input [1:0] pc_src,
               input hazard_full,
               input status_IF, status_EX,
               input restore_pc,
               input pc_sel, pc_sel_BTB,
               input [31:0] pc_trap,
               input [31:0] mepc,
               input [31:0] br_pc_real, pc_real,
               input [31:0] predict_br_pc, predict_pc,
               output logic [31:0] nxt_pc);

   localparam PC_RESET = 2'b00;
   localparam PC_TRAP = 2'b01;
   localparam PC_EPC = 2'b10;
   localparam PC_NEXT = 2'b11;
   
   logic [31:0] nxt_pc_temp;
   logic hazard_full_q;

   always_ff @(posedge i_clk, negedge i_rst_n) begin
      if (!i_rst_n) hazard_full_q <= 1'b0;
      else hazard_full_q <= hazard_full;
   end

   always_comb begin
      if (pc_src == PC_RESET) nxt_pc = 32'b0;
      else if (pc_src == PC_TRAP) nxt_pc = pc_trap;
      else if (pc_src == PC_EPC) nxt_pc = mepc;
      else if (hazard_full_q) nxt_pc = nxt_pc_temp;
      else if (status_IF^status_EX) nxt_pc = predict_pc + 32'h4;
      else if (restore_pc) nxt_pc = pc_sel? br_pc_real : pc_real + 32'h4;
      else nxt_pc = pc_sel_BTB? predict_br_pc : predict_pc + 32'h4;
   end

   always_ff @(posedge i_clk, negedge i_rst_n) begin
      if (!i_rst_n) nxt_pc_temp <= 32'b0;
      else if (hazard_full) nxt_pc_temp <= nxt_pc;       //giữ lại để cycle sau mik dùng để đúng flow
      else nxt_pc_temp <= nxt_pc_temp;
   end

endmodule