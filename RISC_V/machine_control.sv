typedef enum logic [1:0] {PC_RESET, PC_TRAP, PC_EPC, PC_NEXT} pc_source;

module machine_controller(input i_clk,
                           input i_rst_n,
                           input insn_vld,
                           input mret,
                           input e_irq, t_irq,
                           input [3:0] vecto_no,
                           input logic mtip, meip,
                           input logic meie, mie, mtie,
                           output logic intr_en, excep_en,
                           output pc_source pc_src,
                           output logic trans_trigger,
                           output logic mret_status,
                           output logic flush_ID,
                           output logic flush_EX,
                           output logic [3:0] intr_cause,
                           output logic [3:0] exception_cause
                           );


      typedef enum logic [1:0] {IDLE, OPERATING, TRAP_TAKEN, TRAP_RETURN} mc_state;


      logic intr_vld, exception_vld;
      mc_state state, nxt_state;

      // assign exception_vld = !insn_vld;
      // assign intr_vld = (meie&(e_irq|meip))|(mtie&(t_irq|mtip));
      
      //day la minh chung cho doan neu co ngat dang xu ly,
      //0 co ma luc do co ngat va da cho phep ngat thi se co intr_vld
      //con 0 co ngat, no se cho toi khi ngat kia xong roi xu ly

   //----------------STATE MACHINE-----------------------

   always @(posedge i_clk or negedge i_rst_n) begin
      if (!i_rst_n) state <= IDLE;
      else state <= nxt_state;
   end

   always @(posedge i_clk) begin                      //signal để cân bằng align giữa các tầng
      if (state == nxt_state) trans_trigger <= 1'b1;
      else trans_trigger <= 1'b0;
   end

   always @(posedge i_clk) begin
      exception_vld <= !insn_vld;
      intr_vld <= ((meie&(e_irq|meip))|(mtie&(t_irq|mtip))&&mie);
   end

   always_comb begin
      case (state)
         IDLE: nxt_state = OPERATING;
         OPERATING: nxt_state = ((((meie&(e_irq|meip))|(mtie&(t_irq|mtip)))&&mie)
                                                                           ||!insn_vld)? TRAP_TAKEN
                                                                                          : mret? TRAP_RETURN : OPERATING;
         TRAP_TAKEN, TRAP_RETURN: nxt_state = OPERATING;
         default: nxt_state = IDLE;
      endcase
   end

   always_comb begin
      case (state)
         IDLE: begin
            pc_src = PC_RESET;
            flush_ID = 1'b1;
            flush_EX = 1'b1;
            intr_en = 1'b0;
            excep_en = 1'b0;
            mret_status = 1'b0;
         end
         OPERATING: begin
            pc_src = PC_NEXT;
            flush_ID = 1'b1;
            flush_EX = 1'b1;
            intr_en = 1'b0;
            excep_en = 1'b0;
            mret_status = 1'b0;
         end
         TRAP_TAKEN: begin
            pc_src = PC_TRAP;
            flush_ID = 1'b0;
            flush_EX = 1'b0;
            intr_en = intr_vld;
            excep_en = exception_vld & !intr_vld;
            mret_status = 1'b0;
         end
         TRAP_RETURN: begin
            pc_src = PC_EPC;
            flush_ID = 1'b1;
            flush_EX = 1'b1;
            intr_en = 1'b0;
            excep_en = 1'b0;
            mret_status = 1'b1;
         end
         default: begin
            pc_src = PC_NEXT;
            flush_ID = 1'b1;
            flush_EX = 1'b1;
            intr_en = 1'b0;
            excep_en = 1'b0;
            mret_status = 1'b0;
         end
      endcase
   end

   //----------------STATE MACHINE---------------------

   always_comb begin
      intr_cause = 4'b0;
      exception_cause = 4'b0;
      if (mie & meip) begin        //dang co ngat ngoai va ngat cuc bo cho phep ngat
         case (vecto_no)
            4'h1: intr_cause = 4'b1000;
            4'h2: intr_cause = 4'b1001;
            4'h3: intr_cause = 4'b1010;
            4'h4: intr_cause = 4'b1011;
            4'h5: intr_cause = 4'b1100;
            4'h6: intr_cause = 4'b1101;
            4'h7: intr_cause = 4'b1110;
            4'h8: intr_cause = 4'b1111;
            default: intr_cause = 4'b0000;
         endcase
            exception_cause = exception_cause;
      end
      else if (mie & mtip) begin    //ngat do timer gay ra
            intr_cause = 4'b0111;
            exception_cause = exception_cause;
      end
      else if (exception_vld) begin        //lenh 0 decode duoc
            intr_cause = 4'b0;
            exception_cause = 4'b0010;
      end
      else begin
         intr_cause = intr_cause;
         exception_cause = exception_cause;
      end
   end

endmodule