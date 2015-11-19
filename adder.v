module adder (
    input clk,
    input [63:0] a,
    input [63:0] b,
    input arbiter, //indicates that arbiter wants to write to the cdb
    input some_input, //indicates that one of the reservation stations
                      //is providing an input

    input [63:0] incrPC, 
    input [63:0] offset, 
    input [63:0] opcode,

    output reg [63:0] c,
    output ready, //says that result is ready
    output reg CTRL_PC,
    output reg [63:0] branchPC,
    output br_stall
);

  initial
  begin
        c =0;
        CTRL_PC = 0;
        branchPC = 0;
        #1
        CTRL_PC = 1;
        #1
        CTRL_PC = 0;
  end

  //Instruction opcodes
  // RR, RI type instructions Op field
  parameter op_addq = 6'b010000,
            op_subq = 6'b010000,
            op_bis = 6'b010001,
            op_xor = 6'b010001,
            op_cmoveq = 6'b010001,
            op_cmplt = 6'b010001,
            op_mulq =  6'b010011,
  //RR, RI type instructions funct field
            funct_addq = 7'b0100000,
            funct_subq = 7'b0101001,
            funct_bis = 7'b0100000,
            funct_xor = 7'b1000000,
            funct_cmoveq = 7'b0100100,
            funct_cmplt = 7'b1001101,
            funct_mulq = 7'b0100000,
  //Load/store instructions op field
            op_ldq = 6'b101001,
            op_stq = 6'b101101,
  //branch instructions op field
            op_beq = 6'b111001,
            op_bne = 6'b111101,
            op_br = 6'b110000,
            op_bsr = 6'b110100,
  //jmp instruction (transfer of control)
            op_jmp = 6'b011010,
            op_jsr = 6'b011010,
            op_ret = 6'b011010,
  //jmp instruction hint
            hint_jmp = 8'h00,
            hint_jsr = 8'h01,
            hint_ret = 8'h10;



    wire [2:0] branch;

    reg compute_wait ;

    initial
    begin
        compute_wait = 1;
    end

    assign ready  = ~compute_wait;

    always @(posedge clk )
    begin
    // CONTROL logic for the adder
        if (compute_wait == 0 )
        begin
            if(arbiter) compute_wait <= 1;
        end
        else
        begin
          if (some_input)
            compute_wait <= compute_wait - 1;
          else
            compute_wait <= 1;
        end
    end

    assign br_stall = ready;

    // DATA output
    always @(*)
    begin
        case (opcode)
            op_addq :
            begin
                  c = a+b;                                
            end            
            op_beq :
            begin
                  c = 0; //wb 0, but no destination
                  if(a == 0) 
                  begin
                    CTRL_PC = 1;     
                  end
                  branchPC = offset + incrPC; 
            end
            op_jmp :
            begin
                  c = incrPC;
                  CTRL_PC = 1;
                  branchPC = b;
            end
            default : 
            begin
                  CTRL_PC = 0;
                  c = 0;
            end
        endcase
    end

endmodule
