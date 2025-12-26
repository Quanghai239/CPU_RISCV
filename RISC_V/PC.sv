module PC (
    input logic i_clk,
    input logic in_rst,
    input pc_enable,
    input logic [31:0] nxt_pc,
    output logic [31:0] pc
    // ,input i_stall
);

    logic [31:0] pc_r;
    assign pc = pc_r;

    always_ff @(posedge i_clk or negedge in_rst) begin
        if (!in_rst) pc_r <= 32'd0;
        // else if (!i_stall) pc <= nxt_pc;
        else if (pc_enable) pc_r <= nxt_pc;
        else pc_r <= pc_r;
    end
endmodule
