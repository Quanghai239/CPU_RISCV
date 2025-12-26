module sll(
    input logic [31:0] i_data,
    input logic [4:0] amount,

    output logic [31:0] o_data
);

    logic [31:0] temp;
    always_comb begin
    case (amount)
        5'd0:  temp = i_data[31:0];
        5'd1:  temp = {i_data[30:0],1'b0};
        5'd2:  temp = {i_data[29:0],2'b0};
        5'd3:  temp = {i_data[28:0],3'b0};
        5'd4:  temp = {i_data[27:0],4'b0};
        5'd5:  temp = {i_data[26:0],5'b0};
        5'd6:  temp = {i_data[25:0],6'b0};
        5'd7:  temp = {i_data[24:0],7'b0};
        5'd8:  temp = {i_data[23:0],8'b0};
        5'd9:  temp = {i_data[22:0],9'b0};
        5'd10: temp = {i_data[21:0],10'b0};
        5'd11: temp = {i_data[20:0],11'b0};
        5'd12: temp = {i_data[19:0],12'b0};
        5'd13: temp = {i_data[18:0],13'b0};
        5'd14: temp = {i_data[17:0],14'b0};
        5'd15: temp = {i_data[16:0],15'b0};
        5'd16: temp = {i_data[15:0],16'b0};
        5'd17: temp = {i_data[14:0],17'b0};
        5'd18: temp = {i_data[13:0],18'b0};
        5'd19: temp = {i_data[12:0],19'b0};
        5'd20: temp = {i_data[11:0],20'b0};
        5'd21: temp = {i_data[10:0],21'b0};
        5'd22: temp = {i_data[9:0],22'b0};
        5'd23: temp = {i_data[8:0],23'b0};
        5'd24: temp = {i_data[7:0],24'b0};
        5'd25: temp = {i_data[6:0],25'b0};
        5'd26: temp = {i_data[5:0],26'b0};
        5'd27: temp = {i_data[4:0],27'b0};
        5'd28: temp = {i_data[3:0],28'b0};
        5'd29: temp = {i_data[2:0],29'b0};
        5'd30: temp = {i_data[1:0],30'b0};
        5'd31: temp = {i_data[0],31'b0};
        default: temp = 32'b0;
    endcase
    end
    
    assign o_data = temp;
endmodule

   

    
