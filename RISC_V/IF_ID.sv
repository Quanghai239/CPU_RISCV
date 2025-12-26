module IF_ID(input i_clk,
            input i_rst_n,
            input enable,
            input [31:0] pc_IF,
            input [31:0] instr_IF,
            input i_pc_sel_BTB,
            input [31:0] i_predict_pc,
            output logic [31:0] pc_ID,
            output logic [31:0] instr_ID,
            output logic o_pc_sel_BTB,
            output logic [31:0] o_predict_pc);

   always_ff @(posedge i_clk) begin
      if (!i_rst_n) begin
         pc_ID <= 32'h0;
         instr_ID <= 32'h00000013;
         o_pc_sel_BTB <= 1'b0;
         o_predict_pc <= 32'b0;
      end
      else if (enable) begin
         pc_ID <= pc_IF;
         instr_ID <= instr_IF;
         o_pc_sel_BTB <= i_pc_sel_BTB;
         o_predict_pc <= i_predict_pc;
      end
   end
endmodule