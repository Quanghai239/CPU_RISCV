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
`define CSR             7'b1110011

module immgen(
    input logic [31:0] i_instr,
    output logic [31:0] o_immgen
);
    
    always_comb begin 
        case(i_instr[6:0])
            `LUI, `AUIPC: o_immgen = {i_instr[31:12], 12'b0}; //LUI và AUIPC chỉ sử dụng 20 bit lớn đầu, 12 bit sau là 0, slide 27,28 ppt
            `JAL: begin 
                if (i_instr[31]) o_immgen = {11'h7FF, i_instr[31], i_instr[19:12], i_instr[20], i_instr[30:21], 1'b0}; //imm 20 bit
                else o_immgen = {11'h0, i_instr[31], i_instr[19:12], i_instr[20], i_instr[30:21], 1'b0};  //slide 25ppt L12, địa chỉ phải chia hết cho 2
            end
            `B_type: begin  //slide 16 L12
                if (i_instr[31]) o_immgen = {19'h7FFFF, i_instr[31], i_instr[7], i_instr[30:25], i_instr[11:8], 1'b0}; //imm 12 bit
                else o_immgen = {19'h0, i_instr[31], i_instr[7], i_instr[30:25], i_instr[11:8], 1'b0};
            end
            `JALR, `I_type_load: begin  //slide 34 L12, slide 28 L11, imm 12 bit
                if (i_instr[31]) o_immgen = {20'hFFFFF, i_instr[31:20]};
                else o_immgen = {20'h0, i_instr[31:20]};
            end
            `S_type: begin  //imm 12 bit, slide 31 L11
                if (i_instr[31]) o_immgen = {20'hFFFFF, i_instr[31:25], i_instr[11:7]};
                else o_immgen = {20'h0, i_instr[31:25], i_instr[11:7]};
            end
            `I_type: begin //slide 27 L11
                if (i_instr[14:12] == 3'b001 || i_instr[14:12] == 3'b101) begin
                    o_immgen = {27'h0, i_instr[24:20]}; 
                end 
                else begin
                    if (i_instr[31]) o_immgen = {20'hFFFFF, i_instr[31:20]};
                    else o_immgen = {20'h0, i_instr[31:20]};
                end
            end
            `CSR: o_immgen = {27'b0,i_instr[19:15]};
            default: o_immgen = 32'b0;
        endcase
    end
endmodule