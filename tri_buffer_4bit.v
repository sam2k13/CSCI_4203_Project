module tri_buffer_4bit(
    input [3:0] signal_in,
    input ctrl,
    output reg [3:0] signal_out
);

    always @(*)
    begin
        if (ctrl == 0)
           signal_out = 4'bz;
        else if (ctrl == 1)
           signal_out = signal_in;
    end


endmodule

