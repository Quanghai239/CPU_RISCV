module ID_EX(input i_clk,
            input i_rst_n,
            input enable,
            // input flush,
            input i_insn_vld,
            input [31:0] i_pc,
            input [31:0] i_instr,
            input i_rd_wren,
            input [2:0] i_ld_en,
            input i_opa_sel,
            input [1:0] i_opb_sel,
            input i_lsu_wren,
            input [3:0] i_alu_op,
            input i_br_un,
            input [1:0] i_wb_sel,
            input [31:0] i_rs1_data, i_rs2_data,
            input [31:0] i_imm_data,
            input [31:0] i_csr_rdata,
            input i_pc_sel_BTB,
            input [31:0] i_predict_pc,
            output logic o_insn_vld,
            output logic [31:0] o_pc,
            output logic [31:0] o_instr,
            output logic o_rd_wren,
            output logic [2:0] o_ld_en,
            output logic o_opa_sel,
            output logic [1:0] o_opb_sel,
            output logic o_lsu_wren,
            output logic [3:0] o_alu_op,
            output logic o_br_un,
            output logic [1:0] o_wb_sel,
            output logic [31:0] o_rs1_data, o_rs2_data,
            output logic [31:0] o_imm_data,
            output logic [31:0] o_csr_rdata,
            output logic o_pc_sel_BTB,
            output logic [31:0] o_predict_pc
            );

   always_ff @(posedge i_clk) begin
      if (!i_rst_n) begin
         o_pc <= 32'b0;
         o_instr <= 32'h00000013;   //flush là xóa xong chèn NOP thay thế
         o_rd_wren <= 1'b0;
         o_ld_en <= 3'b0;
         o_opa_sel <= 1'b0;
         o_opb_sel <= 1'b0;
         o_lsu_wren <= 1'b0;
         o_alu_op <= 4'h0;
         o_br_un <= 1'b0;
         o_insn_vld <= 1'b0;
         o_wb_sel <= 2'b0;
         o_rs1_data <= 32'h0;
         o_rs2_data <= 32'h0;
         o_pc_sel_BTB <= 1'b0;
         o_predict_pc <= 32'b0;
         o_imm_data <= 32'b0;
         o_csr_rdata <= 32'b0;
      end
      else if (enable) begin
         o_pc <= i_pc;
         o_instr <= i_instr;   //flush là xóa xong chèn NOP thay thế
         o_rd_wren <= i_rd_wren;
         o_ld_en <= i_ld_en;
         o_opa_sel <= i_opa_sel;
         o_opb_sel <= i_opb_sel;
         o_lsu_wren <= i_lsu_wren;
         o_alu_op <= i_alu_op;
         o_br_un <= i_br_un;
         o_insn_vld <= i_insn_vld;
         o_wb_sel <= i_wb_sel;
         o_rs1_data <= i_rs1_data;
         o_rs2_data <= i_rs2_data;
         o_pc_sel_BTB <= i_pc_sel_BTB;
         o_predict_pc <= i_predict_pc;
         o_imm_data <= i_imm_data;
         o_csr_rdata <= i_csr_rdata;
      end
   end

endmodule