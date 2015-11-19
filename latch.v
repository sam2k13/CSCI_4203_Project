//NOTE -- here we mean latch in the sense of flip flop (i.e. edge triggered)
module pipeline_latch_64( //64 bit latch

   //inputs
    input clk,
    input [63:0] latch_input,
    input [1:0] control_signal,

   //outputs
    output reg [63:0] latch_output
    );

    reg [63:0] data;

    initial
    begin
        data <= 64'b0_0; //initialize latch with no data
        latch_output <= 64'b0_0;
    end

    //initial
    //$monitor("Data is %d",data);

    always @(posedge clk)
    begin
        case(control_signal)
          2'b00 :begin
                     latch_output <= latch_input; //transfer
                 end
          2'b01 :begin
                     latch_output <= latch_output; //stall:
                 end
          2'b10 :begin
                      data <= 0; //bubble
                      latch_output <= data;
                 end
          default : latch_output <= 0; //do nothing
        endcase
    end

endmodule

module pipeline_latch_32( //32 bit latch

   //inputs
    input clk,
    input [31:0] latch_input,
    input [1:0] control_signal,

   //outputs
    output reg [31:0] latch_output
    );

    reg [31:0] data;

    initial
    begin
        data <= 32'b0_0; //initialize latch with no data
        latch_output <= 32'b0_0;
    end


    always @(posedge clk)
    begin
        case(control_signal)
          2'b00 :begin
                     latch_output <= latch_input;
                 end
          2'b01 :begin
                     latch_output <= latch_output; //stall:
                 end
          2'b10 :begin 
                      data <= 0; //bubble
                      latch_output <= data;
                 end
          default : latch_output <= 0; //do nothing
        endcase
    end

endmodule

module pipeline_latch_8( //8 bit latch

   //inputs
    input clk,
    input [7:0] latch_input,
    input [1:0] control_signal,

   //outputs
    output reg [7:0] latch_output
    );

    reg [7:0] data;

    initial 
    begin
        data <= 8'b0_0; //initialize latch with no data
        latch_output <= 8'b0_0;
    end

    always @(posedge clk)
    begin
        case(control_signal)
          2'b00 :begin
                     latch_output <= latch_input; //transfer
                 end
          2'b01 :begin
                     latch_output <= latch_output; //stall:
                 end
          2'b10 :begin 
                      data <= 0; //bubble
                      latch_output <= data;
                 end
          default : latch_output <= 0; //do nothing
        endcase
    end


endmodule

module pipeline_latch_5( //5 bit latch

   //inputs
    input clk,
    input [4:0] latch_input,
    input [1:0] control_signal,

   //outputs
    output reg [4:0] latch_output
    );

    reg [4:0] data;

    initial 
    begin
        data <= 4'b0_0; //initialize latch with no data
        latch_output <= 4'b0_0;
    end


    always @(posedge clk)
    begin
        case(control_signal)
          2'b00 :begin
                     latch_output <= latch_input; //transfer
                 end
          2'b01 :begin
                     latch_output <= latch_output; //stall:
                 end
        2'b10 :begin 
                      data <= 0; //bubble
                      latch_output <= data;
                 end
          default : latch_output <= 0; //do nothing
        endcase
    end



endmodule

module pipeline_latch_1( //1 bit latch

   //inputs
    input clk,
    input latch_input,
    input [1:0] control_signal,

   //outputs
    output reg latch_output
    );

    reg  data;

    initial
    begin
        data <= 0; //init6ialize latch with no data
        latch_output <= 0;
    end


    always @(posedge clk)
    begin
        case(control_signal)
          2'b00 :begin
                     latch_output <= latch_input; //transfer
                 end
          2'b01 :begin
                     latch_output <= latch_output; //stall:
                 end
          2'b10 :begin 
                      data <= 0; //bubble
                      latch_output <= data;
                 end
          default : latch_output <= 0; //do nothing
        endcase
    end

endmodule
