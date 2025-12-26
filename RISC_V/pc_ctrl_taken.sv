// `include "../00_src/define.sv"
`define B_type          7'b1100011
`define JAL             7'b1101111
`define JALR            7'b1100111

`define BEQ             3'b000
`define BNE             3'b001
`define BLT             3'b100
`define BGE             3'b101
`define BLTU            3'b110
`define BGEU            3'b111

module pc_ctrl_taken(input i_br_less,
                     input i_br_equal,
                     input i_br_un,
                     input [6:0] opcode,
                     input [2:0] funct3,
                     // input [31:0] i_alu_data,
                     output o_pc_sel
                     // ,output [31:0] o_alu_data
                     );

   // always_comb begin
   //    case (opcode)
   //       `BEQ: o_pc_sel = i_br_equal? 1'b1 : 1'b0;
   //       `BNE: o_pc_sel = !i_br_equal? 1'b1 : 1'b0;
   //       `BLT: o_pc_sel = (i_br_un&&i_br_less)? 1'b1 : 1'b0;
   //       `BLTU: o_pc_sel = (!i_br_un&&i_br_less)? 1'b1 : 1'b0;
   //       `BGE: o_pc_sel = (i_br_un&&!i_br_less)? 1'b1 : 1'b0;
   //       `BGEU: o_pc_sel = (!i_br_un&&!i_br_less)? 1'b1 : 1'b0;
   //       default: o_pc_sel = 1'bx;
   //    endcase
   // end

   assign o_pc_sel = (((opcode == `B_type)&&(funct3 == `BEQ)&&i_br_equal)||
                     ((opcode == `B_type)&&(funct3 == `BNE)&&!i_br_equal)||
                     ((opcode == `B_type)&&(funct3 == `BLT)&&i_br_un&&i_br_less)||
                     ((opcode == `B_type)&&(funct3 == `BLTU)&&!i_br_un&&i_br_less)||
                     ((opcode == `B_type)&&(funct3 == `BGE)&&i_br_un&&!i_br_less)||
                     ((opcode == `B_type)&&(funct3 == `BGEU)&&!i_br_un&&!i_br_less)||
                     ((opcode == `JAL)||(opcode == `JALR)))? 1'b1 : 1'b0;

endmodule