//multiplexes two signals
module multiplexer_2(

   //inputs
    input [4:0] input_signal_1,
    input [4:0] input_signal_2,
    input control_signal,

   //outputs
    output reg [4:0] output_signal );

    initial 
    begin
        output_signal = 0;
    end

    always @(*)
    begin
        if (control_signal == 0)
        begin
            output_signal = input_signal_1;
        end
        else
        begin
            output_signal = input_signal_2;
        end
    end

endmodule

//multiplexes two signals
module multiplexer_2_64bit(

   //inputs
    input [63:0] input_signal_1,
    input [63:0] input_signal_2,
    input control_signal,

   //outputs
    output reg [63:0] output_signal );

    initial 
    begin
        output_signal = 64'b0_0100;  //initialize to 4
                                     //because this is only
                                     //used to select between
                                     //incrPC and branch 
    end

    always @(*)
    begin
        if (control_signal == 0)
        begin
            output_signal = input_signal_1;
        end
        else
        begin
            output_signal = input_signal_2;
        end
    end

endmodule


//multiplexes two signals
module multiplexer_4(

   //inputs
    input [63:0] input_signal_1,
    input [63:0] input_signal_2,
    input [63:0] input_signal_3,
    input [63:0] input_signal_4,
    input [1:0]  control_signal,

   //outputs
    output reg [63:0] output_signal );

    initial
    begin
       output_signal = 0;  
    end

    always @(*)
    begin
        case (control_signal)
            2'b00: output_signal = input_signal_1;
            2'b01: output_signal = input_signal_2;
            2'b10: output_signal = input_signal_3;
            2'b11: output_signal = input_signal_4;
        endcase
    end

endmodule
