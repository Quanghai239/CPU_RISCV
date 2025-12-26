module db_fsm
(
    input logic clk, rst_n,
    input logic btn,
    output logic db
);

// symbolic state declaration
localparam logic [2:0]
    zero    = 3'b000,
    wait1_1 = 3'b001,
    wait1_2 = 3'b010,
    wait1_3 = 3'b011,
    one     = 3'b100,
    wait0_1 = 3'b101,
    wait0_2 = 3'b110,
    wait0_3 = 3'b111;

// number of counter bits (2^N * 20ns = 10ms tick)
localparam int N = 18;

// signal declaration
logic [N-1:0] q_reg;
logic [N-1:0] q_next;
logic m_tick;
logic [2:0] state_reg, state_next;

// body
// ========================================================
// counter to generate 10 ms tick
// ========================================================
always_ff @(posedge clk)
    q_reg <= q_next;

// next-state logic
assign q_next = q_reg + 1;

// output tick
assign m_tick = (q_reg == 0) ? 1'b1 : 1'b0;

// ========================================================
// debouncing FSM
// ========================================================
// state register
always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
        state_reg <= zero;
    else
        state_reg <= state_next;

// next-state logic and output logic
always_comb
begin
    state_next = state_reg; // default next state: the same
    db = 1'b0;              // default output: 0
    case (state_reg)
        zero: begin
            if (btn)
                state_next = wait1_1;
        end
        wait1_1: begin
            if (~btn)
                state_next = zero;
            else if (m_tick)
                state_next = wait1_2;
        end
        wait1_2: begin
            if (~btn)
                state_next = zero;
            else if (m_tick)
                state_next = wait1_3;
        end
        wait1_3: begin
            if (~btn)
                state_next = zero;
            else
                state_next = one;
        end
        one: begin
            db = 1'b1;
            if (~btn)
                state_next = wait0_1;
            else if (m_tick)
                state_next = one;
        end
        wait0_1: begin
            db = 1'b1;
            if (btn)
                state_next = one;
            else if (m_tick)
                state_next = wait0_2;
        end
        wait0_2: begin
            db = 1'b1;
            if (btn)
                state_next = one;
            else if (m_tick)
                state_next = wait0_3;
        end
        wait0_3: begin
            db = 1'b1;
            if (btn)
                state_next = one;
            else if (m_tick)
                state_next = zero;
        end
        default: state_next = zero; // Handle unexpected states
    endcase
end

endmodule