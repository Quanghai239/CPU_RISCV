
module uart_transmitter (
    //Input
    input clk,
    input bclk,
    input resetn,
    input [7:0] data_in,
    input logic parity_en,
    input logic parity_type,
    input logic write_en,
    input logic tx_en,
    input logic [1:0] tx_thr_val,

    //Output
    output logic txd,
    output logic tx_bclk_en,
    output logic tx_thr
);
  // Setup fifo state
  parameter FIFOLENGTH = 16;
  parameter FIFOWIDTH = 7;
  parameter IDLE = 2'b00;
  parameter LOADING = 2'b01;
  parameter START_TX = 2'b10;
  parameter WAIT_TX = 2'b11;

  //Setup fifo_tx
  logic [4:0] write_pt;
  logic [4:0] read_pt;
  logic [4:0] length;
  logic [FIFOWIDTH : 0] fifo_mem[15:0];
  logic [FIFOWIDTH:0] rdata;
  logic read_en;
  logic [1:0] fifo_state;
  logic fifo_full;
  logic fifo_empty;

  //Set up logic and signal for uart
  logic txd_d, txd_q;
  logic [1:0] state;
  logic [3:0] counter;
  logic [3:0] index;
  logic [1:0] state_next;
  logic [3:0] counter_next;
  logic [3:0] index_next;
  logic [3:0] datalength;
  logic [8:0] data_temp;
  logic start_tx;

  //BCLKs per bit
  parameter bclk_length = 16;



  //FIFO emty
  assign fifo_empty = (write_pt[4:0] == read_pt[4:0]) ? 1 : 0;

  //FIFO full	
  assign fifo_full  = ({~write_pt[4], write_pt[3:0]} == read_pt[4:0]) ? 1 : 0;

  //Reset, write and read
  always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
      write_pt <= 0;
      read_pt  <= 0;
      length   <= 0;
    end else if (write_en == 1 & fifo_full == 0 & tx_en) begin
      fifo_mem[write_pt] <= data_in;
      write_pt <= write_pt + 1;
      length <= length + 1;
    end else if (read_en == 1 & fifo_empty == 0) begin
      rdata   <= fifo_mem[read_pt];
      read_pt <= read_pt + 1;
    end
  end

  //Setting threshold
  logic threshold;
  always @(*) begin
    case (tx_thr_val)
      00: threshold = (length > 8);
      01: threshold = (length > 6);
      10: threshold = (length >4);
      11: threshold = (length > 2);
      default: threshold = (length > 2);
    endcase
  end

  assign tx_thr = threshold;

  //Loading or wait fifo
  always @(posedge clk or negedge resetn) begin
    if (~resetn) fifo_state <= IDLE;
    else
      case (fifo_state)
        IDLE: begin
          if (tx_en & ~fifo_empty) fifo_state <= LOADING;
        end
        LOADING: begin
          if (tx_en) fifo_state <= START_TX;
        end
        START_TX: begin
          if (state == 2'b10) fifo_state <= WAIT_TX;
        end
        WAIT_TX: begin
          if (state == 2'b00) fifo_state <= IDLE;
        end
        default: fifo_state <= IDLE;
      endcase
  end
  assign read_en  = (fifo_state == LOADING) ? 1 : 0;
  assign start_tx = (fifo_state == START_TX) ? 1 : 0;

  //Setup uart_tx
  parameter IDLE_STATE = 2'b00;
  parameter START_STATE = 2'b01;
  parameter DATA_STATE = 2'b10;
  parameter STOP_STATE = 2'b11;

  logic tx_done;

  always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
      state <= IDLE_STATE;
      counter <= 0;
      index <= 0;
      datalength <= 7;
      data_temp <= 9'bxxxxxxxxx;
      txd_q <= 1'b0;
    end else begin
      state <= state_next;
      counter <= counter_next;
      index <= index_next;
      data_temp[7:0] <= rdata;
      txd_q <= txd_d;
      if (parity_en) begin
        datalength <= 8;
        if (parity_type) data_temp[8] <= ~(^data_temp[7:0]);
        else data_temp[8] <= (^data_temp[7:0]);
      end else begin
        datalength   <= 7;
        data_temp[8] <= 0;
      end
    end
  end


  always_comb
  begin
    state_next = state;
    counter_next = counter;
    index_next = index;
    tx_done = 0;
    txd_d = txd_q;
    case (state)
      IDLE_STATE: begin
        tx_done = 1;
        txd_d = 1;
        if (start_tx) begin
          state_next   = START_STATE;
          counter_next = 0;
        end

      end
      START_STATE: begin
        if (bclk)
          if (counter == bclk_length-1) begin
            state_next   = DATA_STATE;
            counter_next = 0;
          end else begin
            counter_next = counter_next + 5'b1;
            txd_d = 0;
          end

      end
      DATA_STATE: begin
        txd_d = data_temp[index];
        if (bclk) begin
          if (counter == bclk_length - 1) begin
            counter_next = 0;
            if (index == datalength) state_next = STOP_STATE;
            else begin
              index_next = index_next + 4'b1;
              state_next = DATA_STATE;
            end
          end else counter_next = counter_next + 5'b1;
        end

      end
      STOP_STATE: begin
        if (bclk) begin
          if (counter == bclk_length - 1) begin
            counter_next = 0;
            index_next = 0;
            state_next = IDLE_STATE;
            txd_d = 1;
          end else counter_next = counter_next + 5'b1;
        end

      end
    endcase
  end

  assign tx_busy = (state == IDLE) ? 0 : 1;
  assign txd = txd_q;
  assign tx_bclk_en = tx_busy;

endmodule
