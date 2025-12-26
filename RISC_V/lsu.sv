module lsu(
  input logic i_clk,
  input logic i_rst,
  input logic i_lsu_wren,
  input logic [31:0] i_lsu_addr,
  input logic [31:0] i_st_data,
  input logic [31:0] i_io_sw,
  input logic [3:0] i_io_btn,
  input logic [2:0] i_ld_en,
  output logic [31:0] o_ld_data,
  output logic [31:0] o_io_lcd,
  output logic [31:0] o_io_ledg,
  output logic [31:0] o_io_ledr,
  output logic [6:0] o_io_hex0,
  output logic [6:0] o_io_hex1,
  output logic [6:0] o_io_hex2,
  output logic [6:0] o_io_hex3,
  output logic [6:0] o_io_hex4,
  output logic [6:0] o_io_hex5,
  output logic [6:0] o_io_hex6,
  output logic [6:0] o_io_hex7
);
  logic [3:0] byte_en;
  logic [3:0][7:0] datadmem, dataoutbuf, datainbuf, temp;
  logic [3:0][7:0] data_memory[64];
  logic [3:0][7:0] indata;
  logic [1:0] addrsel;

  parameter LW = 3'b010;
  parameter LB = 3'b000;
  parameter LBU = 3'b100;
  parameter LH = 3'b001;
  parameter LHU = 3'b101;

  localparam inputbuf = 2'b10;
  localparam outputbuf = 2'b01;
  localparam DMEM = 2'b00;

  // Clock gating logic
  logic clk_en;
  logic gclk;

  assign clk_en = i_lsu_wren | (i_ld_en != 3'b000);
  assign gclk = i_clk & clk_en;

  always_comb begin
      case (i_lsu_addr[15:12])
          4'b0111:
              if (i_lsu_addr[11:8] == 4'b1000)
                  addrsel = inputbuf;
              else if (i_lsu_addr[11:8] == 4'b0000 && i_lsu_addr[7:6] == 2'b00)
                  addrsel = outputbuf;
              else
                  addrsel = DMEM;
          4'b0010, 4'b0011:
              addrsel = DMEM;
          default:
              addrsel = DMEM;
      endcase
  end

  always_comb begin
      case (addrsel)
          inputbuf:   o_ld_data = datainbuf;
          outputbuf:  o_ld_data = dataoutbuf;
          DMEM:       o_ld_data = datadmem;
          default:    o_ld_data = datadmem;
      endcase
  end

  always_comb begin
      case(i_ld_en)
          LB, LBU: byte_en = 4'b0001;
          LH, LHU: byte_en = 4'b0011;
          LW:      byte_en = 4'b1111;
          default: byte_en = 4'b1111;
      endcase
  end

  // Input peripheral
  assign indata = i_io_sw;

  always_comb begin
      if (!i_lsu_wren && (addrsel == inputbuf)) begin
          case (i_ld_en)
              LB:  datainbuf = {{24{indata[0][7]}}, indata[0]};
              LBU: datainbuf = {24'b0, indata[0]};
              LH:  datainbuf = {{16{indata[1][7]}}, indata[1:0]};
              LHU: datainbuf = {16'b0, indata[1:0]};
              LW:  datainbuf = indata;
              default: datainbuf = indata;
          endcase
      end else datainbuf = 32'b0;
  end

  // Output peripheral store
  logic [7:0] out_data [64];

  always_ff @(posedge gclk) begin
      if ((addrsel == outputbuf) && i_lsu_wren) begin
          case (byte_en)
              4'b0001: begin
                  out_data[i_lsu_addr[5:0]] <= i_st_data[7:0];
              end
              4'b0011: begin
                  out_data[i_lsu_addr[5:0]] <= i_st_data[7:0];
                  out_data[i_lsu_addr[5:0]+1] <= i_st_data[15:8];
              end
              4'b1111: begin
                  out_data[i_lsu_addr[5:0]] <= i_st_data[7:0];
                  out_data[i_lsu_addr[5:0]+1] <= i_st_data[15:8];
                  out_data[i_lsu_addr[5:0]+2] <= i_st_data[23:16];
                  out_data[i_lsu_addr[5:0]+3] <= i_st_data[31:24];
              end
          endcase
      end
  end

  always_comb begin
      if (!i_lsu_wren && (addrsel == outputbuf)) begin
          temp = {out_data[i_lsu_addr[5:0]+3], out_data[i_lsu_addr[5:0]+2], out_data[i_lsu_addr[5:0]+1], out_data[i_lsu_addr[5:0]]};
          case (i_ld_en)
              LB:  dataoutbuf = {{24{temp[0][7]}}, temp[0]};
              LBU: dataoutbuf = {24'b0, temp[0]};
              LH:  dataoutbuf = {{16{temp[1][7]}}, temp[1:0]};
              LHU: dataoutbuf = {16'b0, temp[1:0]};
              LW:  dataoutbuf = temp;
              default: dataoutbuf = 32'b0;
          endcase
      end else dataoutbuf = 32'b0;
  end

  assign o_io_ledr = {out_data[3], out_data[2], out_data[1], out_data[0]};
  assign o_io_ledg = {out_data[19], out_data[18], out_data[17], out_data[16]};
  assign o_io_hex0 = out_data[32];
  assign o_io_hex1 = out_data[33];
  assign o_io_hex2 = out_data[34];
  assign o_io_hex3 = out_data[35];
  assign o_io_hex4 = out_data[36];
  assign o_io_hex5 = out_data[37];
  assign o_io_hex6 = out_data[38];
  assign o_io_hex7 = out_data[39];
  assign o_io_lcd  = {out_data[51], out_data[50], out_data[49], out_data[48]};

  bit [7:0] mem[256];
  logic [15:0] mem_addr;
  assign mem_addr = i_lsu_addr[15:0] - 16'h2000;

  always_ff @(posedge gclk) begin
      if ((addrsel == DMEM) && i_lsu_wren) begin
          case (byte_en)
              4'b0001: mem[mem_addr] <= i_st_data[7:0];
              4'b0011: begin
                  mem[mem_addr] <= i_st_data[7:0];
                  mem[mem_addr+1] <= i_st_data[15:8];
              end
              4'b1111: begin
                  mem[mem_addr] <= i_st_data[7:0];
                  mem[mem_addr+1] <= i_st_data[15:8];
                  mem[mem_addr+2] <= i_st_data[23:16];
                  mem[mem_addr+3] <= i_st_data[31:24];
              end
          endcase
      end
  end

  always_comb begin
      if (!i_lsu_wren && (addrsel == DMEM)) begin
          data_memory[i_lsu_addr[9:2]] = {mem[mem_addr+3], mem[mem_addr+2], mem[mem_addr+1], mem[mem_addr]};
          case (i_ld_en)
              LB:  datadmem = {{24{data_memory[i_lsu_addr[9:2]][0][7]}}, data_memory[i_lsu_addr[9:2]][0]};
              LBU: datadmem = {24'b0, data_memory[i_lsu_addr[9:2]][0]};
              LH:  datadmem = {{16{data_memory[i_lsu_addr[9:2]][1][7]}}, data_memory[i_lsu_addr[9:2]][1:0]};
              LHU: datadmem = {16'b0, data_memory[i_lsu_addr[9:2]][1:0]};
              LW:  datadmem = data_memory[i_lsu_addr[9:2]];
              default: datadmem = 32'h0;
          endcase
      end else datadmem = 32'b0;
  end

endmodule: lsu


