module arbiter(

    input status_rs_ld,
    input status_rs_store,
    input status_rs_add,
    input status_rs_mult,

    output CTRL_cdb_ld,
    output CTRL_cdb_store,
    output CTRL_cdb_add,
    output CTRL_cdb_mult

);

  reg [4:0] ctrl_output;
 //edit
  //precedence order is
  // load > store >  mult > adder

  always @(*)
  begin
      if (status_rs_ld == 1) ctrl_output = 4'b0001;
      else if (status_rs_store == 1) ctrl_output = 4'b0010;
      else if (status_rs_mult == 1) ctrl_output = 4'b0100;
      else if (status_rs_add == 1) ctrl_output = 4'b1000;
      else ctrl_output = 4'b0000;
  end

  assign CTRL_cdb_ld = ctrl_output[0];
  assign CTRL_cdb_store = ctrl_output[1];
  assign CTRL_cdb_mult = ctrl_output[2];
  assign CTRL_cdb_add = ctrl_output[3];

endmodule
