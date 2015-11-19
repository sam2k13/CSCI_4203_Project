//xtnd
module pad_15(
  input [15:0] signal,
  output reg [63:0] pad_signal 
);

  initial 
  begin
      pad_signal = 64'b0_0;
  end

  always @(*)
  begin
      if(signal < 0)
          pad_signal = { {49{1'b1}}, signal };
      else
          pad_signal = { {49{1'b0}}, signal };
  end

endmodule

//xtnd << 2 
module pad_21_shift(
  input [20:0] signal,
  output reg [63:0] pad_signal 
);

  initial 
  begin
      pad_signal = 64'b0_0;
  end

  always @(*)
  begin
      if(signal > 20'b1 )
          pad_signal =  ( { {43{1'b1}}, signal } << 2) ;
      else
          pad_signal = { {43{1'b0}}, signal } << 2;
  end

endmodule

module offset_data(
    input [15:0] offset_ldst,
    input [20:0] offset_beq,
    output [63:0] beq_out, 
    output [63:0] ldst_out
);

    pad_15 pad_15 (offset_ldst, ldst_out);
    pad_21_shift pad_21_shift (offset_beq, beq_out);

endmodule
