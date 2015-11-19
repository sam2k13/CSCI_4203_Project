module multiplier (

    input clk,
    input [63:0] a,
    input [63:0] b,
    input arbiter,
    input some_input, 

    output [63:0] c,
    output ready
);

    reg compute_wait ;

    initial
    begin
        compute_wait = 3;
    end

    assign ready =  ~compute_wait;

    //CONTROL logic for the multiplier
    always @(posedge clk)
    begin
            if (compute_wait == 0)    
            begin
                if(arbiter) compute_wait <= 3;
            end
            else
            begin
              if(some_input)
                 compute_wait <= compute_wait -1;
              else
                 compute_wait <= 3;
            end
    end

    //DATA output
    assign c = a*b;

endmodule
