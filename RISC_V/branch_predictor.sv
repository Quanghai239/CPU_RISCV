// clock gating
`define STRONG_TAKEN       2'b11
`define WEAK_TAKEN         2'b10
`define WEAK_NOT_TAKEN     2'b01
`define STRONG_NOT_TAKEN   2'b00

`define R_type          7'b0110011
`define I_type          7'b0010011
`define I_type_load     7'b0000011
`define JAL             7'b1101111
`define JALR            7'b1100111
`define S_type          7'b0100011
`define B_type          7'b1100011
`define LUI             7'b0110111
`define AUIPC           7'b0010111

module branch_predictor(
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic [31:0] i_alu_data,
    input  logic [31:0] instr_EX,
    input  logic [31:0] pc_IF,
    input  logic [31:0] pc_EX,
    input  logic        i_taken,
    output logic [31:0] o_pc,
    output logic        o_pc_sel_BTB
);

    // Branch Target Buffer (BTB)
    logic [31:0] predicted_pc [64];
    logic [23:0] tag          [64];
    logic [1:0]  state        [64];  

    // Indexing
    logic [6:0] index_W;
    logic [6:0] index_R;
    assign index_W = pc_EX[7:2];
    assign index_R = pc_IF[7:2];

    // Clock gating
    logic        clock_enable;
    logic        clk_gated;
    assign clock_enable = (instr_EX[6:0] == `B_type || instr_EX[6:0] == `JAL || instr_EX[6:0] == `JALR);
    assign clk_gated    = i_clk & clock_enable;

    // Gated-clock controlled write to BTB and FSM update
    always_ff @(posedge clk_gated or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state[index_W]         <= `STRONG_NOT_TAKEN;
            tag[index_W]           <= 24'd0;
            predicted_pc[index_W]  <= 32'd0;
        end else begin
            tag[index_W]          <= pc_EX[31:8];
            predicted_pc[index_W] <= i_alu_data;

            case (state[index_W])
                `STRONG_NOT_TAKEN: state[index_W] <= i_taken ? `WEAK_NOT_TAKEN   : `STRONG_NOT_TAKEN;
                `WEAK_NOT_TAKEN:   state[index_W] <= i_taken ? `STRONG_TAKEN    : `STRONG_NOT_TAKEN;
                `WEAK_TAKEN:       state[index_W] <= i_taken ? `STRONG_TAKEN    : `STRONG_NOT_TAKEN;
                `STRONG_TAKEN:     state[index_W] <= i_taken ? `STRONG_TAKEN    : `WEAK_TAKEN;
                default:           state[index_W] <= `STRONG_NOT_TAKEN;
            endcase
        end
    end

    // Read logic: Prediction decision
    always_comb begin
        if (!i_rst_n) begin
            o_pc = 32'd0;
            o_pc_sel_BTB = 1'b0;
        end else if ((pc_IF[31:8] == tag[index_R]) && 
                     (state[index_R] == `WEAK_TAKEN || state[index_R] == `STRONG_TAKEN)) begin
            o_pc = predicted_pc[index_R];
            o_pc_sel_BTB = 1'b1;
        end else begin
            o_pc = pc_IF + 32'd4;
            o_pc_sel_BTB = 1'b0;
        end
    end

endmodule