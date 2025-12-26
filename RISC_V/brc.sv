module brc(input i_br_un,
                input [31:0] i_rs1_data,
                input [31:0] i_rs2_data,
                output o_br_less,
                output o_br_equal);

    logic [31:0] temp;

    assign temp = i_rs1_data + (~i_rs2_data) + 1'b1;

    assign o_br_equal = !temp? 1'b1:1'b0;

    assign o_br_less = i_br_un? 
            ((i_rs1_data[31]^i_rs2_data[31])?
                (i_rs1_data[31]? 1'b1:1'b0):(temp[31]? 1'b1:1'b0)):
            ((i_rs1_data[31]^i_rs2_data[31])?
                (i_rs2_data[31]? 1'b1:1'b0):(temp[31]? 1'b1:1'b0));

endmodule