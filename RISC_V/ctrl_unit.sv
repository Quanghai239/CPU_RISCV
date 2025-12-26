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

`define ADD             4'b0000
`define PASS            4'b1111

`define BEQ             3'b000
`define BNE             3'b001
`define BLT             3'b100
`define BGE             3'b101
`define BLTU            3'b110
`define BGEU            3'b111

module ctrl_unit(input [31:0] i_instr,
                input flush_ID,
                output csr_en,            //
                output [2:0] csr_op,  //
                output o_rd_wren,
                output o_br_un,
                output o_opa_sel,
                output [1:0] o_opb_sel,
                output [3:0] o_alu_op,
                output o_lsu_wren,
                output [1:0] o_wb_sel,
                output [2:0] o_ld_en,
                output o_insn_vld,
                output mret);

    logic insn_vld_r;
    logic rd_wren_r;
    logic br_un_r;
    logic opa_sel_r;
    logic [1:0] opb_sel_r;
    logic [3:0] alu_op_r;
    logic lsu_wren_r;
    logic [1:0] wb_sel_r;
  	logic [6:0] opcode;
  	logic [2:0] funct3;
  	logic [6:0] funct7;

    assign opcode = i_instr[6:0];     //xac dinh day la cau lenh j
    assign funct3 = i_instr[14:12];   //1 phan trong bien select cua ALU
    assign funct7 = i_instr[31:25];   //bit thu 6 cua bien nay la 1 bien cua ALU
    assign o_rd_wren = rd_wren_r;
    assign o_br_un = br_un_r;
    assign o_opa_sel = opa_sel_r;
    assign o_opb_sel = opb_sel_r;
    assign o_alu_op = alu_op_r;
    assign o_lsu_wren = lsu_wren_r;
    assign o_wb_sel = wb_sel_r;
    assign o_insn_vld = insn_vld_r;
    assign o_ld_en = i_instr[14:12];  //ld_en bang funct3
    
    assign csr_en = opcode == `CSR;
    assign csr_op = (opcode == `CSR)? funct3 : 3'b0;  //khong co chuyen j xay ra
    

    assign mret = (opcode == `CSR) & (i_instr[31:20] == 12'h302);


    always_comb begin
        case (opcode)
            `I_type_load: begin
                rd_wren_r = 1'b1;
                alu_op_r = `ADD;
                br_un_r = 1'bx;
                lsu_wren_r = 1'b0;
                wb_sel_r = 2'b0;
                opb_sel_r = 2'b01;
                opa_sel_r = 1'b0;
                insn_vld_r = flush_ID ? 1'b1 : 1'b0;        //việc ta cho lệnh này ăn theo flush vậy thôi
                //chứ bản chất flush là tầng đó bị rỗng(0 có lệnh)
            end
            `S_type: begin
                rd_wren_r = 1'b0;
                opb_sel_r = 2'b01;
                opa_sel_r = 1'b0;
                alu_op_r = `ADD;
                br_un_r = 1'bx;
                lsu_wren_r = 1'b1;
                wb_sel_r = 2'bxx;
                insn_vld_r = flush_ID ? 1'b1 : 1'b0;
            end
            `B_type: begin
                rd_wren_r = 1'b0;
                opb_sel_r = 2'b01;
                opa_sel_r = 1'b1;
                alu_op_r = `ADD;
                lsu_wren_r = 1'b0;
                wb_sel_r = 2'bxx;
                br_un_r = ((funct3 == `BLTU)||(funct3 == `BGEU))? 1'b0:1'b1;
                insn_vld_r = flush_ID ? 1'b1 : 1'b0;
            end
            `JAL: begin
                rd_wren_r = 1'b1;
                opb_sel_r = 2'b01;
                br_un_r = 1'bx;
                opa_sel_r = 1'b1;
                alu_op_r = `ADD;
                lsu_wren_r = 1'b0;
                wb_sel_r = 2'b10;
                insn_vld_r = flush_ID ? 1'b1 : 1'b0;
            end
            `JALR: begin
                rd_wren_r = 1'b1;
                opb_sel_r = 2'b01;
                br_un_r = 1'bx;
                opa_sel_r = 1'b0;
                alu_op_r = `ADD;
                lsu_wren_r = 1'b0;
                wb_sel_r = 2'b10;
                insn_vld_r = flush_ID ? 1'b1 : 1'b0;
            end
            `LUI: begin
                rd_wren_r = 1'b1;
                opb_sel_r = 2'b01;
                br_un_r = 1'bx;
                opa_sel_r = 1'bx;
                alu_op_r = `PASS;
                lsu_wren_r = 1'b0;
                wb_sel_r = 2'b01;
                insn_vld_r = flush_ID ? 1'b1 : 1'b0;
            end
            `AUIPC: begin
                rd_wren_r = 1'b1;
                opb_sel_r = 2'b01;
                br_un_r = 1'bx;
                opa_sel_r = 1'b1;
                alu_op_r = `ADD;
                lsu_wren_r = 1'b0;
                wb_sel_r = 2'b01;
                insn_vld_r = flush_ID ? 1'b1 : 1'b0;
            end
            `I_type: begin
                if (!(({funct7,funct3} == 10'h1)||
                ({funct7,funct3} == 10'h5)||
                ({funct7,funct3} == 10'b0100000101)||
                (funct3 == 3'b000)||
                (funct3 == 3'b010)||
                (funct3 == 3'b011)||
                (funct3 == 3'b100)||
                (funct3 == 3'b110)||
                (funct3 == 3'b111))) begin
                  rd_wren_r = 1'b0;
                  opa_sel_r = 1'b0;
                  opb_sel_r = 2'b00;
                  br_un_r = 1'b0;
                  alu_op_r = 4'b0;
                  lsu_wren_r = 1'b0;
                  wb_sel_r = 2'b0;
                  insn_vld_r = 1'b0;
                end
                else begin
                  rd_wren_r = 1'b1;
                  opa_sel_r = 1'b0;
                  opb_sel_r = 2'b01;
              	  alu_op_r = ((funct3 == 3'b101)||(funct3 == 3'b001))? {funct7[5],funct3}:{1'b0,funct3}; 
                  br_un_r = 1'bx;
                  lsu_wren_r = 1'b0;
                  wb_sel_r = 2'b01;
                  insn_vld_r = flush_ID ? 1'b1 : 1'b0;
                end
            end
            `R_type: begin
              if (!(({funct7,funct3} == 10'h0)||
              ({funct7,funct3} == 10'b0100000000)||
              ({funct7,funct3} == 10'b0000000001)||
              ({funct7,funct3} == 10'b0000000010)||
              ({funct7,funct3} == 10'b0000000011)||
              ({funct7,funct3} == 10'b0000000100)||
              ({funct7,funct3} == 10'b0000000101)||
              ({funct7,funct3} == 10'b0100000101)||
              ({funct7,funct3} == 10'b0000000110)||
              ({funct7,funct3} == 10'b0000000111))) begin
                  rd_wren_r = 1'b0;
                  opa_sel_r = 1'b0;
                  opb_sel_r = 2'b00;
                  br_un_r = 1'b0;
                  alu_op_r = 4'b0;
                  lsu_wren_r = 1'b0;
                  wb_sel_r = 2'b0;
                  insn_vld_r = 1'b0;
                end
                else begin
                  rd_wren_r = 1'b1;
                  opa_sel_r = 1'b0;
                  opb_sel_r = 2'b00;
                  br_un_r = 1'bx;
              	  alu_op_r = {funct7[5],funct3};
                  lsu_wren_r = 1'b0;
                  wb_sel_r = 2'b01;
                  insn_vld_r = flush_ID ? 1'b1 : 1'b0;
                end
            end
            `CSR: begin
                rd_wren_r = 1'b1;       //lo co ghi 0 vao thi no cung khong nhan gia tri do
                opb_sel_r = funct3[2]? 2'b01 : 2'b10;       //xem opcode funct3
                opa_sel_r = 1'bx;
                lsu_wren_r = 1'bx;
                br_un_r = 1'bx;
                alu_op_r = `PASS;
                wb_sel_r = 2'b01;
                insn_vld_r = flush_ID ? 1'b1 : 1'b0;
            end
            //kha nang se co them opcode lenh mret
            default: begin
                rd_wren_r = 1'b0;
                br_un_r = 1'b0;
                opa_sel_r = 1'b0;
                opb_sel_r = 2'b00;
                alu_op_r = 4'b0;
                lsu_wren_r = 1'b0;
                wb_sel_r = 2'b0;
                insn_vld_r = 1'b0;
            end
        endcase
    end


endmodule