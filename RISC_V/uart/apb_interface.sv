
module APB_Interface (
    //Input from APB
    input pclk,
    input presetn,
    input psel,
    input [31:0] paddr,
    input penable,
    input pwrite,
    input [31:0] pwdata,


    //Input from UART
    input [7:0] data_rx,
    input tx_thr,
    input rx_thr,
    input rx_ov,
    input rx_pe,
    input rx_fre,

    //Ouput from APB
    output pready,
    output pslverr,
    output [31:0] prdata,

    //Output to UART
    output wire write_en,
    output wire read_en,
    output wire [7:0] data_tx,
    output wire [1:0] tx_thr_val,
    output wire [1:0] rx_thr_val,
    output wire ip_en,
    output wire parity_en,
    output wire parity_type,

    //Output to baudrate generator
    output wire [10:0] baud_val,

    //Interrupt	signal
    output wire itx_thr,
    output wire irx_thr,
    output wire irx_ov,
    output wire i_pe,
    output wire i_fre,
    output wire totalint
);
  //Reg for APB
  //Ouput reg
  reg pslverr_reg;
  reg [31:0] prdata_reg;



  //Parameter
  parameter IDLE = 2'b00;
  parameter SETUP = 2'b01;
  parameter ACCESS = 2'b10;
  parameter WAIT = 2'b11;

  //UART
  reg write_reg;
  reg read_reg;


  //Enable interrupt signal
  wire txthr_en;
  wire rxthr_en;
  wire rxov_en;
  wire pe_en;
  wire fre_en;

  //Register
  reg [7:0] reg_data;
  reg [10:0] reg_bclk;
  reg [7:0] reg_en;  //Include 6 interrupt enbale signal and ip enable, parity enable
  reg [3:0] reg_thr;

  //Write and read transfer
  reg [1:0] state;
  reg [3:0] reg_sel;


  //Control write_en and read_en
  always @(posedge pclk or negedge presetn) begin
    if (~presetn) state <= IDLE;
    else begin
      case (state)
        IDLE: begin
          write_reg  <= 0;
          read_reg   <= 0;
          if (psel == 1) state <= SETUP;
          else state <= IDLE;
        end
        SETUP: begin
          if (penable == 1) begin
            state <= ACCESS;
            if (pwrite) write_reg <= 1 & reg_sel[0];
            else read_reg <= 1 & reg_sel[0];
          end
        end
        ACCESS: begin
          write_reg <= 0;
          read_reg <= 0;
          state <= IDLE;
        end
        default: state <= IDLE;
      endcase
    end
  end


  //Write enable for transmiter
  assign write_en = write_reg;
  assign read_en  = read_reg;

  //Adress decoder
  always @(*) begin
    case (paddr[15:0])
      16'h0100: reg_sel = 4'b0001;  //Data reg for transmiter
      16'h0101: reg_sel = 4'b0010;  //Value for baudrate generator
      16'h0110: reg_sel = 4'b0100;  //Enable signal reg
      16'h0111: reg_sel = 4'b1000;  //Enable interrupt reg
      default: reg_sel = 4'b0000;
    endcase
  end


  //Data reg
  always @(posedge pclk or negedge presetn) begin
    if (~presetn) reg_data <= 8'd0;
    else if (reg_sel[0] & psel & penable )
      if (pwrite) reg_data[7:0] <= pwdata[7:0];
      else reg_data[7:0] <= data_rx[7:0];

  end


  //Baudrate Setting
  always @(posedge pclk or negedge presetn) begin
    if (~presetn) reg_bclk <= 10'd977;
    else if (reg_sel[1] & psel & penable )
      if (pwrite) reg_bclk[10:0] <= pwdata[10:0];

  end

  //Enable Setting
  always @(posedge pclk or negedge presetn) begin
    if (~presetn) reg_en <= 8'd0;
    else if (reg_sel[2] & psel & penable ) if (pwrite) reg_en[7:0] <= pwdata[7:0];
  end


  //Threshold setting
  always @(posedge pclk or negedge presetn) begin
    if (~presetn) reg_thr <= 4'd0;
    else if (reg_sel[3] & psel & penable ) if (pwrite) reg_thr[3:0] <= pwdata[3:0];
  end


  //Read address decoder
  always @(*) begin
    case (paddr[15:0])
      16'h0100: prdata_reg = {24'd0, reg_data[7:0]};
      16'h0101: prdata_reg = {24'd0, reg_bclk[7:0]};
      16'h0110: prdata_reg = {26'd0, reg_en[6:0]};
      16'h0111: prdata_reg = {28'd0, reg_thr[3:0]};
      default: prdata_reg = 32'b0;
    endcase
  end
  assign prdata[31:0] = prdata_reg[31:0];

  //Set up plsverr
  always @(posedge pclk or negedge presetn) begin
    if (~presetn) pslverr_reg <= 0;
    else if ((paddr[0] | paddr[1]) )
      pslverr_reg <= 1;
    else pslverr_reg <= 0;
  end



  //Assign tx_data
  assign data_tx[7:0] = reg_data[7:0];

  //Assign baudrate value
  assign baud_val[10:0] = reg_bclk[10:0];

  //Assign threshold signal
  assign tx_thr_val[1:0] = reg_thr[1:0];
  assign rx_thr_val[1:0] = reg_thr[3:2];

  //Assign pready and pslverr
  assign pready = 1;
  assign pslverr = pslverr_reg;
  
  reg itx_thr_reg, irx_thr_reg, irx_ov_reg, i_pe_reg, i_fre_reg;

// Tín hiệu interrupt đầu vào đã enable
  wire itx_pulse = txthr_en & tx_thr;
  wire irx_pulse = rxthr_en & rx_thr;
  wire iov_pulse = rxov_en & rx_ov;
  wire ipe_pulse = pe_en & rx_pe;
  wire ifre_pulse = fre_en & rx_fre;
  
  logic itx_clear;
  logic irx_clear;
  logic iov_clear;
  logic ipe_clear;
  logic ifre_clear;
  
  
  always @(posedge pclk or negedge presetn) begin
      if (~presetn) begin
          itx_thr_reg <= 0;
          irx_thr_reg <= 0;
          irx_ov_reg  <= 0;
          i_pe_reg    <= 0;
          i_fre_reg   <= 0;
          itx_clear   <= 0;
          irx_clear   <= 0;
          iov_clear   <= 0;
          ipe_clear   <= 0;
          ifre_clear  <= 0;
      end else if(itx_pulse) begin
          itx_thr_reg <= 1; // Phát xung 1 chu kỳ
          itx_clear <= itx_thr_reg; 
      end else if(irx_pulse) begin
          irx_thr_reg <= 1; // Phát xung 1 chu kỳ
          irx_clear <= irx_thr_reg; // Tự động xóa
      end else if(iov_pulse) begin
          irx_ov_reg <= 1; // Phát xung 1 chu kỳ
          iov_clear <= irx_ov_reg; // Tự động xóa
   end else if(ipe_pulse) begin
          i_pe_reg <= 1; // Phát xung 1 chu kỳ
          ipe_clear <= i_pe_reg;
      end else if(ifre_pulse) begin
         i_fre_reg <= 1; // Phát xung 1 chu kỳ
          ifre_clear <= i_fre_reg;
      end else begin
        itx_thr_reg <= itx_thr_reg;
        irx_thr_reg <= irx_thr_reg;
        irx_ov_reg  <= irx_ov_reg;
        i_pe_reg    <= i_pe_reg;
        i_fre_reg   <= i_fre_reg;
    end
  end


  // Output
  assign itx_thr = itx_thr_reg & ~itx_clear;
  assign irx_thr = irx_thr_reg & ~irx_clear;
  assign irx_ov  = irx_ov_reg & ~iov_clear;
  assign i_pe    = i_pe_reg & ~ipe_clear;
  assign i_fre   = i_fre_reg & ~ifre_clear;
  
  // Tổng ngắt
  assign totalint = itx_thr | irx_thr | irx_ov | i_pe | i_fre;
  


  //Assign enable signal
  assign txthr_en = reg_en[0];
  assign rxthr_en = reg_en[1];
  assign rxov_en = reg_en[2];
  assign pe_en = reg_en[3];
  assign fre_en = reg_en[4];
  assign ip_en = reg_en[5];
  assign parity_en = reg_en[6];
  assign parity_type = reg_en[7];




endmodule