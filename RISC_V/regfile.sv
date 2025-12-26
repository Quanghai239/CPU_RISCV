module regfile(
    input logic i_clk,
    input logic i_rst,
    input logic i_rd_wren,
    input logic [4:0] i_rs1_addr,
    input logic [4:0] i_rs2_addr,
    input logic [4:0] i_rd_addr,
    input logic [31:0] i_rd_data,
    // input i_stall,
    output logic [31:0] o_rs1_data,
    output logic [31:0] o_rs2_data
);

    logic [31:0] reg_addr [0:31] ;

   /* assign o_rs1_data = reg[i_rs1_addr];
    assign o_rs2_data = reg[i_rs2_addr]; */

    always_comb begin //đọc dữ liệu các thanh ghi
        if (i_rs1_addr == 5'b0) o_rs1_data = 32'b0;
        else o_rs1_data = reg_addr[i_rs1_addr]; 
        if (i_rs2_addr == 5'b0) o_rs2_data = 32'b0;
        else o_rs2_data = reg_addr[i_rs2_addr];
    end

    always_ff @(posedge i_clk, posedge i_rst) begin //sao 0 dung bat dong bo?
        if (i_rst) begin
            reg_addr[0] <= 32'd0; 
            reg_addr[1] <= 32'd0; 
            reg_addr[2] <= 32'd0; 
            reg_addr[3] <= 32'd0; 
            reg_addr[4] <= 32'd0; 
            reg_addr[5] <= 32'd0; 
            reg_addr[6] <= 32'd0; 
            reg_addr[7] <= 32'd0; 
            reg_addr[8] <= 32'd0; 
            reg_addr[9] <= 32'd0; 
            reg_addr[10] <= 32'd0; 
            reg_addr[11] <= 32'd0; 
            reg_addr[12] <= 32'd0; 
            reg_addr[13] <= 32'd0; 
            reg_addr[14] <= 32'd0; 
            reg_addr[15] <= 32'd0; 
            reg_addr[16] <= 32'd0; 
            reg_addr[17] <= 32'd0; 
            reg_addr[18] <= 32'd0; 
            reg_addr[19] <= 32'd0; 
            reg_addr[20] <= 32'd0; 
            reg_addr[21] <= 32'd0; 
            reg_addr[22] <= 32'd0; 
            reg_addr[23] <= 32'd0; 
            reg_addr[24] <= 32'd0; 
            reg_addr[25] <= 32'd0; 
            reg_addr[26] <= 32'd0; 
            reg_addr[27] <= 32'd0; 
            reg_addr[28] <= 32'd0; 
            reg_addr[29] <= 32'd0; 
            reg_addr[30] <= 32'd0; 
            reg_addr[31] <= 32'd0;
        end
        // else if ((i_rd_wren == 1) && (i_rd_addr != 5'b0) && (!i_stall)) reg_addr[i_rd_addr] <= i_rd_data;
        else if ((i_rd_wren == 1) && (i_rd_addr != 5'b0)) reg_addr[i_rd_addr] <= i_rd_data;
        else reg_addr[i_rd_addr] <= reg_addr[i_rd_addr];
    end
endmodule
