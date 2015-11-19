`include "macro.v" 

module inst_queue(

  //clock
  input clk,

  //data input
  input [31:0] inst_in,
  input [63:0] incrPC_in, 

  //read/write control
  input wr_en, rd_en,

  //flush 
  input rst,

  //control output
  output buf_empty, buf_full,

  //data output
  output [31:0] inst_out,
  output [63:0] incrPC_out

);

  wire [`BUF_WIDTH : 0] fifo_counter;

  fifo fifo_1 (clk, rst, inst_in, inst_out, wr_en, rd_en, 
             buf_empty, buf_full, fifo_counter);

  fifo_64bit fifo_2 (clk, rst, incrPC_in, incrPC_out, wr_en, rd_en, 
             buf_empty, buf_full, fifo_counter);

endmodule
