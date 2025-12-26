module EX_MEM(input i_clk,
            input i_rst_n,
            input enable,
            // input flush,
            input i_insn_vld,
            input [31:0] i_pc,
            input [31:0] i_rs2_data,
            input [31:0] i_instr,
            input [2:0] i_ld_en,
            input i_lsu_wren,
            input i_rd_wren,
            input [1:0] i_wb_sel,
            input [31:0] i_alu_data,
            output logic o_insn_vld,
            output logic [31:0] o_pc,
            output logic [31:0] o_rs2_data,
            output logic [31:0] o_instr,
            output logic [2:0] o_ld_en,
            output logic o_rd_wren,
            output logic o_lsu_wren,
            output logic [1:0] o_wb_sel,
            output logic [31:0] o_alu_data
            );

   always_ff @(posedge i_clk) begin
      if (!i_rst_n) begin
         o_pc <= 32'b0;
         o_instr <= 32'h00000013;   //flush là xóa xong chèn NOP thay thế
         o_ld_en <= 3'b0;
         o_lsu_wren <= 1'b0;
         o_rd_wren <= 1'b0;
         o_insn_vld <= 1'b0;
         o_wb_sel <= 2'b0;
         o_alu_data <= 32'h0;
         o_rs2_data <= 32'h0;
      end
      else if (enable) begin
         o_pc <= i_pc;
         o_instr <= i_instr;   //flush là xóa xong chèn NOP thay thế
         o_ld_en <= i_ld_en;
         o_rd_wren <= i_rd_wren;
         o_lsu_wren <= i_lsu_wren;
         o_insn_vld <= i_insn_vld;
         o_wb_sel <= i_wb_sel;
         o_alu_data <= i_alu_data;
         o_rs2_data <= i_rs2_data;
      end
   end

endmodule