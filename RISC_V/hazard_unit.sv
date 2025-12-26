// `include "../00_src/define.sv"
`define R_type          7'b0110011
`define I_type          7'b0010011
`define I_type_load     7'b0000011
`define JAL             7'b1101111
`define JALR            7'b1100111
`define S_type          7'b0100011
`define B_type          7'b1100011
`define LUI             7'b0110111
`define AUIPC           7'b0010111

module hazard_unit(input i_pc_sel,
                  input ex_rd_wren,
                  input mem_rd_wren,
                  input wb_rd_wren,
                  input [4:0] ex_rd_addr,
                  input [4:0] mem_rd_addr,
                  input [4:0] wb_rd_addr,
                  input [4:0] id_rs1_addr,
                  input [4:0] id_rs2_addr,
                  input [6:0] id_opcode,
                  input [6:0] ex_opcode,
                  input [6:0] mem_opcode,
                  input [31:0] i_alu_data,
                  input i_pc_sel_BTB,
                  input [31:0] i_pc_BTB,
                input status_IF, status_EX,
                input intr_en,
                  output logic restore_pc,
                  output logic stall_ID,
                  output logic stall_EX,
                  output logic stall_MEM,
                  output logic stall_WB,
                  output logic pc_enable,    //thêm vào làm j?
                  output logic flush_ID,
                  output logic flush_EX,
                  output logic flush_MEM,
                  output logic flush_WB,
                  output hazard_full
                  );

   logic hazard_1, hazard_2, hazard_3, hazard_4, hazard_5;
   logic id_rs2;
   //detect hazard
   assign id_rs2 = (id_opcode == `R_type)||(id_opcode == `B_type)||(id_opcode == `S_type);
   assign hazard_1 = wb_rd_wren&&(wb_rd_addr != 5'b0)&&
                     ((wb_rd_addr == id_rs1_addr)||((wb_rd_addr == id_rs2_addr)&&id_rs2));
   // IF | ID | EX | MEM | WB
   //      IF | ID | EX  | MEM | WB
   //           IF | ID  | EX  | MEM | WB
   assign hazard_2 = ex_rd_wren&&(ex_rd_addr != 5'b0)&&(ex_opcode == `I_type_load)&&
                     ((ex_rd_addr == id_rs1_addr)||((ex_rd_addr == id_rs2_addr)&&id_rs2));
   assign hazard_3 = ex_rd_wren&&(ex_rd_addr != 5'b0)&&(ex_opcode == `I_type_load)&&
                     mem_rd_wren&&(mem_rd_addr != 5'b0)&&(mem_opcode == `I_type_load)&&
                     ((mem_rd_addr == id_rs1_addr)||((mem_rd_addr == id_rs2_addr)&&id_rs2))&&
                     ((ex_rd_addr == id_rs1_addr)||((ex_rd_addr == id_rs2_addr)&&id_rs2));

   assign hazard_4 = ((ex_opcode == `B_type)||(ex_opcode == `JAL)||(ex_opcode == `JALR))&&(i_pc_sel != i_pc_sel_BTB);
   assign hazard_5 = ((ex_opcode == `B_type)||(ex_opcode == `JAL)||(ex_opcode == `JALR))&&(i_pc_sel == i_pc_sel_BTB)&&i_pc_sel&&i_pc_sel_BTB&&(i_alu_data != i_pc_BTB);

   assign hazard_full = (hazard_1|hazard_2|hazard_3)&&(hazard_4|hazard_5);      //đầy đủ 2 loại hazard để báo cho CPU xử lý

   always_comb begin
        //default settings
        stall_ID  = 1'b1;
        stall_EX  = 1'b1;
        stall_MEM = 1'b1;
        stall_WB  = 1'b1;
        pc_enable  = 1'b1;
        flush_ID  = 1'b1;
        flush_EX  = 1'b1;
        flush_MEM = 1'b1;
        flush_WB  = 1'b1;
        restore_pc   = 1'b0;
        //hazard setting => delay
        //Jump-Branch instruction => restore PC
        if(hazard_4 || hazard_5) begin
            flush_ID = status_IF^status_EX;
            flush_EX = status_IF^status_EX;
            restore_pc  = !(status_IF^status_EX);
            if (hazard_1 || hazard_2 || hazard_3) begin
                pc_enable = 1'b0;     //dừng lại để xử lý thằng control trước   
                stall_ID = 1'b0;
            end
        end
        else if (hazard_1 || hazard_2 || hazard_3) begin
            flush_EX = 1'b0;
            stall_ID = 1'b0;
            pc_enable = intr_en? 1'b1 : i_pc_sel;
        end
    end

endmodule