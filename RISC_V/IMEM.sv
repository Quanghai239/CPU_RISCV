module IMEM #(parameter SIZE = 1024)(
    input logic i_clk,
    input logic in_rst,
    input logic [31:0] pc,
    output logic [31:0] instr
);

    bit [31:0] memory [0:SIZE-1];
    assign instr = memory[pc[13:2]];

    initial begin
         $readmemh("D:/lamviec/tailieu/tailieu/DATN_FINAL/DATN_FINAL/test_sim.txt", memory);
    end
endmodule
