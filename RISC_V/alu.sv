// `include "../00_src/define.sv"
`define ADD             4'b0000
`define SUB             4'b1000
`define SLT             4'b0010
`define SLTU            4'b0011
`define XOR             4'b0100
`define OR              4'b0110
`define AND             4'b0111
`define SLL             4'b0001
`define SRL             4'b0101
`define SRA             4'b1101
`define PASS            4'b1111

module alu(
    input logic [31:0] i_operand_a,
    input logic [31:0] i_operand_b,
    input logic [3:0] i_alu_op,

    output logic [31:0] o_alu_data
);

    logic [31:0] sub_data;
    logic [31:0] sll_data;
    logic [31:0] srl_data;
    logic [31:0] sra_data;
    logic [32:0] carry_flag, i_operand_a_33bit, i_operand_b_33bit;

    sll SLLdut(.i_data (i_operand_a),.amount (i_operand_b[4:0]),.o_data(sll_data));
    srl SRLdut(.i_data (i_operand_a),.amount (i_operand_b[4:0]),.o_data(srl_data));
    sra SRAdut(.i_data (i_operand_a),.amount (i_operand_b[4:0]),.o_data(sra_data));

    assign sub_data =  i_operand_a[31:0] + ~(i_operand_b[31:0]) + 1'b1;
    assign i_operand_a_33bit = {1'b0, i_operand_a};
    assign i_operand_b_33bit = {1'b0, i_operand_b};
    assign carry_flag = (i_operand_a_33bit + ~i_operand_b_33bit + 1'b1); //kiểm tra nếu có cờ tràn cho TH không dấu

    always_comb begin 
        case (i_alu_op)
            `ADD: o_alu_data = i_operand_a + i_operand_b; //ADD
            `SUB: o_alu_data = sub_data;                  //SUB
            `SLT: if (i_operand_a[31] ^ i_operand_b[31]) o_alu_data = i_operand_a[31] ? 1 : 0;  // khác dấu thì xét dấu a
                    else o_alu_data = sub_data[31]; // cùng dấu thì xét kết quả hiệu     //SLT
            `SLTU: o_alu_data = carry_flag[32] ? 1'b1 : 1'b0;  //SLTU
            `XOR: o_alu_data = i_operand_a ^ i_operand_b; //XOR
            `OR: o_alu_data = i_operand_a | i_operand_b;  //OR
            `AND: o_alu_data = i_operand_a & i_operand_b; //AND
            `SLL: o_alu_data = sll_data;                  //SLL
            `SRL: o_alu_data = srl_data;                  //SRL
            `SRA: o_alu_data = sra_data;                  //SRA
			`PASS: o_alu_data = i_operand_b;
            default: o_alu_data = 32'b0;                 //
        endcase    
    end
endmodule