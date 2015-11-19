module address_calc(
    input [63:0] op,
    input [63:0] offset,
    output reg [63:0] address
);
  reg compute_wait;

  always @(*)
  begin
      address = op + offset; 
  end


endmodule
