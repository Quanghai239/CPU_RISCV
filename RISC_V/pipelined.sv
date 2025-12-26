`define NO_FORWARD      2'b00
`define MEM_FORWARD     2'b01
`define WB_FORWARD      2'b10

module pipelined(input i_clk,
                  input i_rst_n,
                  // output [31:0] o_pc_debug,
                  input e_irq, t_irq,
                  input [3:0] vecto_no,
                  output [31:0] o_io_ledr,
                  output [31:0] o_io_ledg,
                  output [6:0] o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3, o_io_hex4, o_io_hex5, o_io_hex6, o_io_hex7,
                  output [31:0] o_io_lcd,
                  input [31:0] i_io_sw,
                  input [3:0] i_io_btn,
                  input pready,
                  input [31:0] prdata_timer, prdata_uart, prdata_plic,
                  output psel_timer, psel_uart, psel_plic,
                  output logic penable, pwrite,
                  output logic [31:0] paddr, pwdata,
                  output logic I_flag);

      // typedef enum logic [1:0] {PC_RESET, PC_TRAP, PC_EPC, PC_NEXT} pc_source;
      // pc_source pc_src;

      logic [1:0] pc_src;
      localparam PC_RESET = 2'b00;
      localparam PC_TRAP = 2'b01;
      localparam PC_EPC = 2'b10;
      localparam PC_NEXT = 2'b11;

      logic pc_sel;              //PC chon nhay hay 0
      logic [31:0] nxt_pc;
      logic pc_enable;
      logic restore_pc;
      logic [31:0] pc_IF, instr_IF;
      logic stall_ID, flush_ID;
      logic [31:0] pc_ID, instr_ID;
      logic pc_sel_BTB_IF, pc_sel_BTB_ID;
      logic [31:0] predict_pc_IF, predict_pc_ID;
      logic rd_wren_ID, br_un_ID, opa_sel_ID, lsu_wren_ID;
      logic [1:0] opb_sel_ID;
      logic [3:0] alu_op_ID;
      logic [1:0] wb_sel_ID;
      logic [2:0] ld_en_ID;
      logic [31:0] rs1_data_ID, rs2_data_ID;
      logic [31:0] imm_data_ID;     //immediate sau de thuc hien phep lien quan toi hang so
      logic [31:0] csr_rdata_ID;                //
      logic insn_vld_ID;
      logic flush_EX, stall_EX, insn_vld_EX;
      logic [31:0] pc_EX, instr_EX;
      logic rd_wren_EX, opa_sel_EX, lsu_wren_EX, br_un_EX;
      logic [1:0] opb_sel_EX;
      logic [31:0] operand_a, operand_b;
      logic [3:0] alu_op_EX;
      logic [1:0] wb_sel_EX;
      logic [2:0] ld_en_EX;
      logic [31:0] rs1_data_EX, rs2_data_EX;
      logic [31:0] imm_data_EX;                 //
      logic [31:0] csr_rdata_EX;                //
      logic pc_sel_BTB_EX;
      logic [31:0] predict_pc_EX;
      logic [31:0] alu_data_EX;
      logic flush_MEM, stall_MEM; 
      logic [31:0] pc_MEM, instr_MEM, alu_data_MEM, rs2_data_MEM;
      logic [2:0] ld_en_MEM;
      logic rd_wren_MEM, lsu_wren_MEM;
      logic [1:0] wb_sel_MEM;
      logic [31:0] ld_data_MEM;
      logic [31:0] ld_data_WB, pc_WB, instr_WB, alu_data_WB;
      logic insn_vld_WB, rd_wren_WB;
      logic [1:0] wb_sel_WB;
      logic flush_WB, stall_WB;
      logic [31:0] wb_data_WB;
      logic [1:0] forward_ASel, forward_BSel;
      logic [31:0] rs1_data_sel, rs2_data_sel;
      //signal for csr instruction
      
      logic [31:0] pc_trap, mepc;
      logic csr_en;
      logic [31:0] data4wrcsr;
      logic mret, mret_status;
      logic [2:0] csr_op;
      logic intr_en, excep_en;
      logic [3:0] intr_cause, exception_cause;
      logic meie, mtie, meip, mtip;
      logic flush_ID_trap, flush_EX_trap;
      logic trans_trigger;

      logic status_IF, status_ID, status_EX;


   // ------------------ IF STAGE ---------------------

   branch_predictor bp(.i_clk(i_clk),
                        .i_rst_n(i_rst_n),
                        .i_alu_data(alu_data_EX),
                        .instr_EX(instr_EX),
                        .pc_IF(pc_IF),
                        .pc_EX(pc_EX),
                        .i_taken(pc_sel),
                        .o_pc(predict_pc_IF),
                        .o_pc_sel_BTB(pc_sel_BTB_IF))
                        ;

//    assign nxt_pc = pc_sel? alu_data_EX : pc_IF+4;        //MUX1 chon nhay hay 0

      // always_comb begin
      //       if (restore_pc) nxt_pc = pc_sel? alu_data_EX : pc_EX + 32'h4;
      //       else nxt_pc = pc_sel_BTB_IF? predict_pc_IF : pc_IF + 32'h4;
      // end

      // always_comb begin
      //       if (pc_src == PC_RESET) nxt_pc = 32'b0;
      //       else if (pc_src == PC_TRAP) nxt_pc = pc_trap;
      //       else if (pc_src == PC_EPC) nxt_pc = mepc;
      //       else if (restore_pc) nxt_pc = pc_sel? alu_data_EX : pc_EX + 32'h4;
      //       else nxt_pc = pc_sel_BTB_IF? predict_pc_IF : pc_IF + 32'h4;
      // end

      logic hazard_full;

      PCNEXT PCNEXT(.i_clk(i_clk),
                  .i_rst_n(i_rst_n),
                  .pc_src(pc_src),
                  .hazard_full(hazard_full),
                  .status_IF(status_IF),
                  .status_EX(status_EX),
                  .restore_pc(restore_pc),
                  .pc_sel(pc_sel),
                  .pc_sel_BTB(pc_sel_BTB_IF),
                  .pc_trap(pc_trap),
                  .mepc(mepc),
                  .br_pc_real(alu_data_EX),
                  .pc_real(pc_EX),
                  .predict_br_pc(predict_pc_IF),
                  .predict_pc(pc_IF),
                  .nxt_pc(nxt_pc));

   PC PC(.i_clk(i_clk),
         .in_rst(i_rst_n),
         .pc_enable(pc_enable),
         .nxt_pc(nxt_pc),     
         .pc(pc_IF)
         // ,.i_stall(i_stall)
         );           

   IMEM IMEM(.i_clk(i_clk),
            .in_rst(!i_rst_n),
            .pc(pc_IF),          
            .instr(instr_IF));

   IF_ID IF_ID(.i_clk(i_clk),
         .i_rst_n(flush_ID),
         .enable(stall_ID),
         .pc_IF(pc_IF),
         .instr_IF(instr_IF),
         .i_pc_sel_BTB(pc_sel_BTB_IF),
         .i_predict_pc(predict_pc_IF),
         .pc_ID(pc_ID),
         .instr_ID(instr_ID),
         .o_pc_sel_BTB(pc_sel_BTB_ID),
         .o_predict_pc(predict_pc_ID));

   // ------------------ IF STAGE ---------------------

   // ------------------ ID STAGE ---------------------

      ctrl_unit ctrl_unit(.i_instr(instr_ID),
                .flush_ID(flush_ID),
                  .csr_en(csr_en),
                .csr_op(csr_op),
                .o_rd_wren(rd_wren_ID),
                .o_br_un(br_un_ID),
                .o_opa_sel(opa_sel_ID),
                .o_opb_sel(opb_sel_ID),
                .o_alu_op(alu_op_ID),
                .o_lsu_wren(lsu_wren_ID),
                .o_wb_sel(wb_sel_ID),
                .o_ld_en(ld_en_ID),
                .o_insn_vld(insn_vld_ID),
                .mret(mret));


   regfile regfile(.i_clk(i_clk),
                  .i_rst(!i_rst_n),
                  .i_rd_wren(rd_wren_WB),       
                  .i_rs1_addr(instr_ID[19:15]),
                  .i_rs2_addr(instr_ID[24:20]),
                  .i_rd_addr(instr_WB[11:7]),
                  // .i_stall(i_stall),
                  .i_rd_data(wb_data_WB),
                  .o_rs1_data(rs1_data_ID),
                  .o_rs2_data(rs2_data_ID));

      immgen immgen(.i_instr(instr_ID),
                  .o_immgen(imm_data_ID));

ID_EX ID_EX(.i_clk(i_clk),
            .i_rst_n(flush_EX),
            .enable(stall_EX&(pc_src == PC_NEXT)&&trans_trigger),
            // input flush,
            .i_insn_vld(insn_vld_ID),
            .i_pc(pc_ID),
            .i_instr(instr_ID),
            .i_rd_wren(rd_wren_ID),
            .i_ld_en(ld_en_ID),
            .i_opa_sel(opa_sel_ID),
            .i_opb_sel(opb_sel_ID),
            .i_lsu_wren(lsu_wren_ID),
            .i_alu_op(alu_op_ID),
            .i_br_un(br_un_ID),
            .i_wb_sel(wb_sel_ID),
            .i_rs1_data(rs1_data_ID),
            .i_rs2_data(rs2_data_ID),
            .i_imm_data(imm_data_ID),
            .i_pc_sel_BTB(pc_sel_BTB_ID),
            .i_predict_pc(predict_pc_ID),
            .i_csr_rdata(csr_rdata_ID),
            .o_insn_vld(insn_vld_EX),
            .o_pc(pc_EX),
            .o_instr(instr_EX),
            .o_rd_wren(rd_wren_EX),
            .o_ld_en(ld_en_EX),
            .o_opa_sel(opa_sel_EX),
            .o_opb_sel(opb_sel_EX),
            .o_lsu_wren(lsu_wren_EX),
            .o_alu_op(alu_op_EX),
            .o_br_un(br_un_EX),
            .o_wb_sel(wb_sel_EX),
            .o_rs1_data(rs1_data_EX),
            .o_rs2_data(rs2_data_EX),
            .o_pc_sel_BTB(pc_sel_BTB_EX),
            .o_predict_pc(predict_pc_EX),
            .o_imm_data(imm_data_EX),
            .o_csr_rdata(csr_rdata_EX)
            );

      // ------------------------- ID STAGE --------------------------

      // ------------------------- EX STAGE --------------------------

      // immgen immgen(.i_instr(instr_EX),
      //             .o_immgen(imm_data));

      brc brc(.i_rs1_data(rs1_data_sel),
            .i_rs2_data(rs2_data_sel),
            .i_br_un(br_un_EX),           
            .o_br_less(br_less),       
            .o_br_equal(br_equal));

      //2 mux lựa chọn giá trị cho toán hạng của alu

      assign operand_a = opa_sel_EX? pc_EX : rs1_data_sel;
      assign operand_b = (opb_sel_EX == 2'b10)? csr_rdata_EX : (opb_sel_EX == 2'b01) ? imm_data_EX : rs2_data_sel;


      assign rs1_data_sel = (forward_ASel == `MEM_FORWARD)? alu_data_MEM :
                              (forward_ASel == `WB_FORWARD)? wb_data_WB : rs1_data_EX;

      assign rs2_data_sel = (forward_BSel == `MEM_FORWARD)? alu_data_MEM :
                              (forward_BSel == `WB_FORWARD)? wb_data_WB : rs2_data_EX;


      alu alu(.i_operand_a(operand_a),
            .i_operand_b(operand_b),
            .i_alu_op(alu_op_EX),   
            .o_alu_data(alu_data_EX));

      pc_ctrl_taken pc_ctrl_taken(.i_br_less(br_less),
                                    .i_br_equal(br_equal),
                                    .i_br_un(br_un_EX),
                                    .opcode(instr_EX[6:0]),
                                    .funct3(instr_EX[14:12]),
                                    // .i_alu_data(),    //
                                    .o_pc_sel(pc_sel)
                                    // ,.o_alu_data()
                                    );   //biến chưa biết làm gì

      EX_MEM EX_MEM(.i_clk(i_clk),
            .i_rst_n(flush_MEM),
            .enable(stall_MEM&(pc_src == PC_NEXT)),
            // input flush,
            .i_insn_vld(insn_vld_EX),
            .i_pc(pc_EX),
            .i_rs2_data(rs2_data_sel),
            .i_instr(instr_EX),
            .i_ld_en(ld_en_EX),
            .i_lsu_wren(lsu_wren_EX),
            .i_rd_wren(rd_wren_EX),
            .i_wb_sel(wb_sel_EX),
            .i_alu_data(alu_data_EX),
            .o_insn_vld(insn_vld_MEM),
            .o_pc(pc_MEM),
            .o_rs2_data(rs2_data_MEM),
            .o_instr(instr_MEM),
            .o_ld_en(ld_en_MEM),
            .o_rd_wren(rd_wren_MEM),
            .o_lsu_wren(lsu_wren_MEM),
            .o_wb_sel(wb_sel_MEM),
            .o_alu_data(alu_data_MEM)
            );

      // ------------------------- EX STAGE --------------------------

      // ------------------------- MEM STAGE --------------------------

      lsu lsu(.i_clk(i_clk),
            .i_rst(!i_rst_n),
            .i_lsu_addr(alu_data_MEM),
            .i_st_data(rs2_data_MEM),
            .i_lsu_wren(lsu_wren_MEM),     
            .i_io_sw(i_io_sw),
            .i_io_btn(i_io_btn),
            .i_ld_en(ld_en_MEM),   
            // .instr(instr[6:0]),        
            .o_ld_data(ld_data_MEM),
            .o_io_ledr(o_io_ledr),
            .o_io_ledg(o_io_ledg),
            .o_io_hex0(o_io_hex0),
            .o_io_hex1(o_io_hex1),
            .o_io_hex2(o_io_hex2),
            .o_io_hex3(o_io_hex3),
            .o_io_hex4(o_io_hex4),
            .o_io_hex5(o_io_hex5),
            .o_io_hex6(o_io_hex6),
            .o_io_hex7(o_io_hex7),
            .o_io_lcd(o_io_lcd)
            // ,.SRAM_ADDR(SRAM_ADDR),
            // .SRAM_DQ(SRAM_DQ),
            // .SRAM_CE_N(SRAM_CE_N),
            // .SRAM_WE_N(SRAM_WE_N),
            // .SRAM_LB_N(SRAM_LB_N),
            // .SRAM_UB_N(SRAM_UB_N),
            // .SRAM_OE_N(SRAM_OE_N),
            // .i_stall(i_stall)
            );

      MEM_WB MEM_WB(.i_clk(i_clk),
            .i_rst_n(flush_WB),
            .enable(stall_WB&(pc_src == PC_NEXT)),
            // input flush,
            .i_pc(pc_MEM),
            .i_instr(instr_MEM),
            .i_insn_vld(insn_vld_MEM),
            .i_rd_wren(rd_wren_MEM),
            .i_ld_data(ld_data_MEM),
            .i_wb_sel(wb_sel_MEM),
            .i_alu_data(alu_data_MEM),
            .o_pc(pc_WB),
            .o_instr(instr_WB),
            .o_insn_vld(insn_vld_WB),
            .o_rd_wren(rd_wren_WB),
            .o_ld_data(ld_data_WB),
            .o_wb_sel(wb_sel_WB),
            .o_alu_data(alu_data_WB)
            );

      // ------------------------- MEM STAGE --------------------------

      // ------------------------- WB STAGE --------------------------

      logic [31:0] ld_data_sel, to_cpu_data;
      //lựa chọn giữa data được lấy từ DMEM hoặc đọc ra từ các IP

      assign ld_data_sel = (instr_WB[6:2] == 5'b0)&&(alu_data_WB[11:7] == 4'b0)? to_cpu_data : ld_data_WB;

      assign wb_data_WB = (wb_sel_WB == 2'b00)? ld_data_sel : (wb_sel_WB == 2'b01)? alu_data_WB : pc_WB+4;

      // ------------------------- WB STAGE --------------------------

      hazard_unit HU(.i_pc_sel(pc_sel&&!(status_IF^status_EX)),
                  .ex_rd_wren(rd_wren_EX),
                  .mem_rd_wren(rd_wren_MEM),
                  .wb_rd_wren(rd_wren_WB),
                  .ex_rd_addr(instr_EX[11:7]),
                  .mem_rd_addr(instr_MEM[11:7]),
                  .wb_rd_addr(instr_WB[11:7]),
                  .id_rs1_addr(instr_ID[19:15]),
                  .id_rs2_addr(instr_ID[24:20]),
                  .i_pc_sel_BTB(pc_sel_BTB_EX),
                  .i_pc_BTB(predict_pc_EX),
                  .i_alu_data(alu_data_EX),
                  .id_opcode(instr_ID[6:0]),
                  .ex_opcode(instr_EX[6:0]),
                  .mem_opcode(instr_MEM[6:0]),
                  .stall_ID(stall_ID),
                  .stall_EX(stall_EX),
                  .stall_MEM(stall_MEM),
                  .stall_WB(stall_WB),
                  .pc_enable(pc_enable),    //thêm vào làm j?
                  .flush_ID(flush_ID),
                  .flush_EX(flush_EX),
                  .flush_MEM(flush_MEM),
                  .flush_WB(flush_WB),
                  .restore_pc(restore_pc),
                  .hazard_full(hazard_full),
                  .status_IF(status_IF),
                  .status_EX(status_EX),
                  .intr_en(intr_en)
                  );


      forward_unit FU(.instr_MEM(instr_MEM),
      .instr_WB(instr_WB),
      .instr_EX(instr_EX),
      .rd_wren_MEM(rd_wren_MEM),
      .rd_wren_WB(rd_wren_WB),
      .forward_ASel(forward_ASel),
      .forward_BSel(forward_BSel));

      //------------------------INTERRUPT PROCESSOR----------------------------

      logic [31:0] rs1_csr_op;            //1 trong các ứng viên chọn làm data
      logic [31:0] pc4save;


      assign rs1_csr_op = (instr_EX[11:7] == instr_ID[19:15]) && rd_wren_EX && (instr_EX[11:7] != 5'd0)? alu_data_EX :   //liền kề nhau
                        (instr_MEM[11:7] == instr_ID[19:15]) && rd_wren_MEM && (instr_MEM[11:7] != 5'd0)? (instr_MEM[6:2] == 5'd0) ? ld_data_MEM :     //trong tầng MEM có load và alu data
                                                                                                                        alu_data_MEM :
                        (instr_WB[11:7] == instr_ID[19:15]) && rd_wren_WB && (instr_WB[11:7] == 5'd0)? wb_data_WB :
                                                                                                rs1_data_ID;


      assign data4wrcsr = (csr_en && csr_op[2])? imm_data_ID : rs1_csr_op;

      always_ff @(posedge i_clk) begin
            if (!i_rst_n) {status_IF, status_ID, status_EX} <= 3'b0;
            else begin
                  status_IF <= (status_IF|intr_en)&~mret;
                  status_ID <= stall_ID? status_IF : status_ID;
                  status_EX <= stall_EX? status_ID : status_EX;
            end
      end

      logic pcsel_urg;

      assign pcsel_urg = pc_sel&&(status_IF^status_EX);


      CSR CSR(.i_clk(i_clk),
            .i_rst_n(i_rst_n),
            .e_irq(e_irq),
            .t_irq(t_irq),
            .csr_en(csr_en),
            .pcsel_urg(pcsel_urg),
            .pcsaveurg(alu_data_EX),
            .csr_addr(instr_ID[31:20]),
            .csr_op(csr_op),
            .csr_data(data4wrcsr),
            .pc(pc4save),
            .excep_en(excep_en),
            .intr_en(intr_en),
            .mret(mret_status),
            .intr_cause(intr_cause),
            .exception_cause(exception_cause),
            .csr_rdata(csr_rdata_ID),
            .pc_trap(pc_trap),
            .mepc(mepc),
            .mie(mie),
            .meie(meie),
            .mtie(mtie),
            .meip(meip),
            .mtip(mtip));

      pc_intr pc_intr(.i_clk(i_clk),
                        .i_rst_n(i_rst_n),
                        .intr(t_irq|e_irq),
                        .excep(insn_vld_ID^flush_ID),
                        .flush_ID(flush_ID),
                        .flush_EX(flush_EX),
                        .pc_IF(pc_IF),
                        .pc_ID(pc_ID),
                        .pc_EX(pc_EX),
                        .pc4save(pc4save));

      //trong control unit, ta cho insn_vld, vậy nếu như có thứ gì đó làm cho 2 cái 0 giống nhau
      //chỉ có thể là lệnh sai
      machine_controller MC(.i_clk(i_clk),
                              .i_rst_n(i_rst_n),
                              .insn_vld(insn_vld_ID^~flush_ID),
                              .mret(mret),
                              .e_irq(e_irq),
                              .t_irq(t_irq),
                              .mtip(mtip),
                              .meip(meip),
                              .meie(meie),
                              .mtie(mtie),
                              .mie(mie),
                              .vecto_no(vecto_no),
                              .intr_en(intr_en),
                              .excep_en(excep_en),
                              .pc_src(pc_src),
                              .trans_trigger(trans_trigger),
                              .mret_status(mret_status),
                              .flush_ID(flush_ID_trap),
                              .flush_EX(flush_EX_trap),
                              .intr_cause(intr_cause),
                              .exception_cause(exception_cause));


      always_comb begin
            I_flag = 1'b1;
            if (!mie) I_flag = 1'b0;
      end

      //------------------------INTERRUPT PROCESSOR----------------------------


      logic apb_en;

      assign apb_en = ((instr_EX[6:2] == 5'b0)||(instr_EX[6:2] == 5'h08))&&(alu_data_EX[31:12] == 20'h0);


      apb_master AM(.pclk(i_clk),
                  .preset_n(i_rst_n),
                  .apb_region(alu_data_MEM[11:0]),     //chọn địa chỉ nóng hổi mới ra lò
                  .apb_en(apb_en),
                  .wdata(rs2_data_MEM),
                  .wr_en(lsu_wren_MEM),
                  .pready(pready),
                  .prdata_timer(prdata_timer),
                  .prdata_uart(prdata_uart),
                  .prdata_plic(prdata_plic),
                  .psel_timer(psel_timer),
                  .psel_uart(psel_uart),
                  .psel_plic(psel_plic),
                  .penable(penable),
                  .pwrite(pwrite),
                  .paddr(paddr),
                  .pwdata(pwdata),
                  .to_cpu_data(to_cpu_data));
endmodule