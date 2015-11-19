module tri_buffer(
    input [63:0] signal_in,
    input ctrl,
    output reg [63:0] signal_out
);

    always @(*)
    begin
        if (ctrl == 0)
           signal_out = 64'bz;
        else
           signal_out = signal_in;
    end
endmodule
