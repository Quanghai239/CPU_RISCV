module sra(
    input logic [31:0] i_data, 
    input logic [4:0] amount, // 5-bit shift amount
    output logic [31:0] o_data
);
    // Initialize the output
    logic [31:0] temp;

    always_comb begin
        case (amount)
            5'd0:  temp = i_data[31:0];
            5'd1:  temp = { {1{i_data[31]}}, i_data[31:1] };
            5'd2:  temp = { {2{i_data[31]}}, i_data[31:2] };
            5'd3:  temp = { {3{i_data[31]}}, i_data[31:3] };
            5'd4:  temp = { {4{i_data[31]}}, i_data[31:4] };
            5'd5:  temp = { {5{i_data[31]}}, i_data[31:5] };
            5'd6:  temp = { {6{i_data[31]}}, i_data[31:6] };
            5'd7:  temp = { {7{i_data[31]}}, i_data[31:7] };
            5'd8:  temp = { {8{i_data[31]}}, i_data[31:8] };
            5'd9:  temp = { {9{i_data[31]}}, i_data[31:9] };
            5'd10: temp = { {10{i_data[31]}}, i_data[31:10] };
            5'd11: temp = { {11{i_data[31]}}, i_data[31:11] };
            5'd12: temp = { {12{i_data[31]}}, i_data[31:12] };
            5'd13: temp = { {13{i_data[31]}}, i_data[31:13] };
            5'd14: temp = { {14{i_data[31]}}, i_data[31:14] };
            5'd15: temp = { {15{i_data[31]}}, i_data[31:15] };
            5'd16: temp = { {16{i_data[31]}}, i_data[31:16] };
            5'd17: temp = { {17{i_data[31]}}, i_data[31:17] };
            5'd18: temp = { {18{i_data[31]}}, i_data[31:18] };
            5'd19: temp = { {19{i_data[31]}}, i_data[31:19] };
            5'd20: temp = { {20{i_data[31]}}, i_data[31:20] };
            5'd21: temp = { {21{i_data[31]}}, i_data[31:21] };
            5'd22: temp = { {22{i_data[31]}}, i_data[31:22] };
            5'd23: temp = { {23{i_data[31]}}, i_data[31:23] };
            5'd24: temp = { {24{i_data[31]}}, i_data[31:24] };
            5'd25: temp = { {25{i_data[31]}}, i_data[31:25] };
            5'd26: temp = { {26{i_data[31]}}, i_data[31:26] };
            5'd27: temp = { {27{i_data[31]}}, i_data[31:27] };
            5'd28: temp = { {28{i_data[31]}}, i_data[31:28] };
            5'd29: temp = { {29{i_data[31]}}, i_data[31:29] };
            5'd30: temp = { {30{i_data[31]}}, i_data[31:30] };
            5'd31: temp = { {31{i_data[31]}}, i_data[31] };
            default: temp = {32{i_data[31]}};
        endcase
    end

    assign o_data = temp;
endmodule

