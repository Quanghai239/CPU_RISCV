module APB_UART_top (
    //Input from APB
    pclk,
    presetn,
    psel,
    paddr,
    penable,
    pwrite,
    pwdata,
    //Input from Receiver
    rxd,
    //Output from APB
    pready,
    pslverr,
    prdata,
    //Output from Transmiter
    txd,
    //Interupt
    totalint,
    itx_thr,
    irx_thr,
    irx_ov,
    i_pe,
    i_fre
);

  //Input
  input pclk;
  input presetn;
  input psel;
  input [31:0] paddr;
  input penable;
  input pwrite;
  input [31:0] pwdata;
  input rxd;


  //Output
  output pready;
  output pslverr;
  output [31:0] prdata;
  output logic txd;


  //Interrupt
  output logic itx_thr;
  output logic irx_thr;
  output logic irx_ov;
  output logic i_pe;
  output logic i_fre;
  output logic totalint;

  //Data from receiver
  logic [7:0] data_rx;
  //Interrupt signal from transmiter
  logic tx_thr;
  //Interrupt signal from receiver
  logic rx_thr;
  logic rx_fre;
  logic rx_ov;
  logic rx_pe;

  //Baud val
  logic [10:0] baud_val;
  //Read data and write data
  logic read_en;
  logic write_en;
  //Enable signal
  logic ip_en;
  logic parity_en;
  logic parity_type;
  //Threshold value
  logic [1:0] tx_thr_val;
  logic [1:0] rx_thr_val;

  //Data to transmiter
  logic [7:0] data_tx;
  APB_Interface apb_interface (
      //Input
      .pclk(pclk),
      .presetn(presetn),
      .psel(psel),
      .paddr(paddr),
      .penable(penable),
      .pwrite(pwrite),
      .pwdata(pwdata),
      .data_rx(data_rx),
      .tx_thr(tx_thr),
      .rx_thr(rx_thr),
      .rx_fre(rx_fre),
      .rx_ov(rx_ov),
      .rx_pe(rx_pe),
      //Output
      .pready(pready),
      .pslverr(pslverr),
      .prdata(prdata),
      .baud_val(baud_val),
      .data_tx(data_tx),
      .read_en(read_en),
      .write_en(write_en),
      .tx_thr_val(tx_thr_val),
      .rx_thr_val(rx_thr_val),
      .ip_en(ip_en),
      .parity_en(parity_en),
      .parity_type(parity_type),
      .totalint(totalint),
      .itx_thr(itx_thr),
      .irx_thr(irx_thr),
      .irx_ov(irx_ov),
      .i_pe(i_pe),
      .i_fre(i_fre)
  );
  //Enable bclk
  logic tx_bclk_en;
  logic rx_bclk_en;
  //BCLK
  logic bclk_rx;
  logic bclk_tx;

  //Baudrate gen
  BCLK_Generator bclk_gen (
      .pclk(pclk),
      .presetn(presetn),
      .div_val(baud_val),
      .tx_bclk_en(tx_bclk_en),
      .rx_bclk_en(rx_bclk_en),
      .bclk_rx(bclk_rx),
      .bclk_tx(bclk_tx)
  );

  //Receiver			
  uart_receiver uart_rx (
      .clk(pclk),
      .bclk(bclk_rx),
      .resetn(presetn),
      .rxd(rxd),
      .read_en(read_en),
      .rx_en(ip_en),
      .parity_en(parity_en),
      .parity_type(parity_type),
      .rx_thr_val(rx_thr_val),
      .data_out(data_rx),
      .rx_bclk_en(rx_bclk_en),
      .rx_fre(rx_fre),
      .rx_pe(rx_pe),
      .rx_ov(rx_ov),
      .rx_thr(rx_thr)
  );


  //Transsmiter
  uart_transmitter uart_tx (
      .clk(pclk),
      .bclk(bclk_tx),
      .resetn(presetn),
      .data_in(data_tx),
      .parity_en(parity_en),
      .parity_type(parity_type),
      .tx_thr_val(tx_thr_val),
      .write_en(write_en),
      .tx_en(ip_en),
      .txd(txd),
      .tx_bclk_en(tx_bclk_en),
      .tx_thr(tx_thr)
  );



endmodule
