module MEM_WB(input i_clk,
            input i_rst_n,
            input enable,
            // input flush,
            input [31:0] i_pc,
            input [31:0] i_instr,
            input i_insn_vld,
            input i_rd_wren,
            input [31:0] i_ld_data,
            input [1:0] i_wb_sel,
            input [31:0] i_alu_data,
            output logic [31:0] o_pc,
            output logic [31:0] o_instr,
            output logic o_insn_vld,
            output logic o_rd_wren,
            output logic [31:0] o_ld_data,
            output logic [1:0] o_wb_sel,
            output logic [31:0] o_alu_data
            );

   always_ff @(posedge i_clk) begin
      if (!i_rst_n) begin
         o_pc <= 32'b0;
         o_instr <= 32'h00000013;   //flush là xóa xong chèn NOP thay thế
         o_wb_sel <= 2'b0;
         o_insn_vld <= 1'b0;
         o_ld_data <= 32'h0;
         o_rd_wren <= 1'b0;
         o_alu_data <= 32'h0;
      end
      else if (enable) begin
         o_pc <= i_pc;
         o_instr <= i_instr;   //flush là xóa xong chèn NOP thay thế
         o_insn_vld <= i_insn_vld;
         o_rd_wren <= i_rd_wren;
         o_wb_sel <= i_wb_sel;
         o_ld_data <= i_ld_data;
         o_alu_data <= i_alu_data;
      end
   end

endmodule