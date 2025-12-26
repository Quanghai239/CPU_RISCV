// `include "../00_src/define.sv"
`define NO_FORWARD      2'b00
`define MEM_FORWARD     2'b01
`define WB_FORWARD      2'b10

module forward_unit(input [31:0] instr_MEM, instr_WB, instr_EX,
                  input rd_wren_MEM, rd_wren_WB,
                  output bit [1:0] forward_ASel, forward_BSel);

   logic [4:0] wb_rd_addr, mem_rd_addr, ex_rs1_addr, ex_rs2_addr;

   assign wb_rd_addr = instr_WB[11:7];
   assign mem_rd_addr = instr_MEM[11:7];
   assign ex_rs1_addr = instr_EX[19:15];
   assign ex_rs2_addr = instr_EX[24:20];

   assign forward_ASel = (rd_wren_MEM&&(mem_rd_addr != 5'b0)&&(mem_rd_addr == ex_rs1_addr))? `MEM_FORWARD : 
   (rd_wren_WB&&(wb_rd_addr != 5'b0)&&(wb_rd_addr == ex_rs1_addr))? `WB_FORWARD : `NO_FORWARD;
   assign forward_BSel = (rd_wren_MEM&&(mem_rd_addr != 5'b0)&&(mem_rd_addr == ex_rs2_addr))? `MEM_FORWARD : 
   (rd_wren_WB&&(wb_rd_addr != 5'b0)&&(wb_rd_addr == ex_rs2_addr))? `WB_FORWARD : `NO_FORWARD;

endmodule