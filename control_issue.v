module issue(
  input clk,
  input [31:0] instruction,

  //says whether the rs has a free spot
  input [3:0] rs_mult,  
  input [3:0] rs_adder,
  input [3:0] rs_ld, 
  input [3:0] rs_st,  
  input [3:0] rs_br,

  //stall in case of branch
  input br_stall,

  //CTRL output to regfile
  output reg [4:0] reg_src1,
  output reg [4:0] reg_src2,
  output reg [4:0] reg_dest, 
  output reg [3:0] rs_tag, //tag indicates rs
  output reg nodest, //for st, br and jmp instructions

  //output to reservation stations
  //CONTROL
  output reg CTRL_ld, //says whether to accept instruction or not
  output reg CTRL_st,
  output reg CTRL_add,
  output reg CTRL_mult,
  output reg CTRL_br,

  //send the op code to the reservation station
  output [5:0] opcode,
  
  //output to instruction queue
  output reg stall
);

  initial
  begin
      stall = 0;
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

  //reservation station
  parameter notag = 0,
            add_1 = 1,
            add_2 = 2,
            add_3 = 3,
            mult_1 = 4,
            mult_2 = 5,
            ld_1 = 6,
            ld_2 = 7,
            ld_3 = 8,
            st_1 = 9,
            st_2 = 10,
            br = 11;

  wire [5:0] OP = instruction[31:26];
  wire [6:0] FUNCT = instruction[11:5];
  wire [4:0] REGA = instruction[25:21];
  wire [4:0] REGB = instruction[20:16];
  wire [4:0] REGC = instruction[4:0];


  //the issue control sends the opcode to the 
  //reservation station
  assign opcode = OP;

  always @(*)
  begin
      if (((OP == op_addq)  || (OP == op_beq) || (OP == op_jmp)) && (rs_adder != notag) ) CTRL_add = 1;
      else CTRL_add = 0;

      if ((OP == op_stq) && ( rs_st != notag))
            CTRL_st = 1;
      else 
            CTRL_st = 0;
      if ((OP == op_ldq) && (rs_ld != notag)) CTRL_ld = 1;
      else CTRL_ld = 0;

      if ((OP == op_mulq) && (rs_mult != notag)) CTRL_mult = 1;
      else CTRL_mult = 0;

      if (((OP == op_beq) || (OP == op_jmp)) && (rs_adder != notag)) CTRL_add =1;
  end  


  always @(*)
  begin
    // -- stall control
    case(OP)
       op_addq, op_beq, op_jmp : 
       begin
          if(rs_adder == notag) stall = 1;
          else stall = 0;
       end
       op_stq : 
       begin
          if(rs_st == notag) stall = 1;
          else stall = 0;
       end
       op_ldq : 
       begin
          if(rs_ld == notag) stall = 1;
          else stall = 0;
       end
       op_mulq : 
       begin
          if(rs_mult== notag) stall = 1;
          else stall = 0;
       end
    endcase
  end
 
  always @(*)
  begin
     case (OP) 
        op_addq : 
        begin
           reg_src1 = REGA;
           reg_src2 = REGB;
           reg_dest = REGC;
           rs_tag = rs_adder; 
           nodest = 0;
        end
        op_ldq :
        begin
           reg_src1 = REGB;
           reg_dest = REGA;
           rs_tag = rs_ld; 
           nodest = 0;
        end
        op_stq : 
        begin
           reg_src1 = REGA;
           reg_src2 = REGB;
           rs_tag = rs_st; 
           nodest = 1;
        end
        op_mulq :
        begin
           reg_src1 = REGA;
           reg_src2 = REGB;
           reg_dest = REGC;
           rs_tag = rs_mult; 
           nodest = 0;
        end
        op_beq : //TODO
        begin
            reg_src1 = REGA;
            reg_dest = 4'bz;
            rs_tag = rs_adder;
            nodest = 1;
        end
        op_jmp :
        begin
            reg_src2 = REGB;  
            reg_dest = REGA;
            rs_tag = rs_adder; 
            nodest = 0;
        end
        default :   //NOP
        begin
            rs_tag = 0;
            nodest = 1;
        end
     endcase
  end
endmodule
