module regfile(
  //clock
  input clk,

  //CTRL input
  input CTRL_stall,

  //add this tag to destination reg
  input [3:0] rs_tag,
  input [5:0] opcode,

  //reg src, destination and offset
  input [4:0] reg_src_1,
  input [4:0] reg_src_2,
  input [4:0] reg_dest,
  input nodest,

  //input from the rob
  input [3:0] rob_id,
  input [63:0] rob_data,

  //operand bus for add
  output reg [63:0] op_1,
  output reg [63:0] op_2,
  output reg [3:0] tag_1,
  output reg [3:0] tag_2,

  //tb values
  output [64*32 - 1 : 0] tb_Regs
);

  reg [63:0] Regs [0:31]; //32 FP registers
  reg [3:0] Tags [0:31];  //32 tags
  reg [5:0] i;

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
            st_2 = 10;

  parameter op_beq =  6'b111001,
            op_jmp = 6'b011010;


  //initialize the register file to 0 val and no tags
  initial
  begin
      //set the register value
      for (i=0; i<32; i=i+1)
      begin
          Regs[i]=0;
          Tags[i]=0;
      end
  end

  //assign tb_Regs
  assign tb_Regs [63:0] = Regs[0];
  assign tb_Regs [127:64] = Regs[1];
  assign tb_Regs [191:128] = Regs[2];
  assign tb_Regs [255:192] = Regs[3];
  assign tb_Regs [319:256] = Regs[4];
  assign tb_Regs [383:320] = Regs[5];
  assign tb_Regs [447:384] = Regs[6];
  assign tb_Regs [511:448] = Regs[7];
  assign tb_Regs [575:512] = Regs[8];
  assign tb_Regs [639:576] = Regs[9];
  assign tb_Regs [703:640] = Regs[10];
  assign tb_Regs [767:704] = Regs[11];
  assign tb_Regs [831:768] = Regs[12];
  assign tb_Regs [895:832] = Regs[13];
  assign tb_Regs [959:896] = Regs[14];
  assign tb_Regs [1023:960] = Regs[15];
  assign tb_Regs [1087:1024] = Regs[16];
  assign tb_Regs [1151:1088] = Regs[17];
  assign tb_Regs [1215:1152] = Regs[18];
  assign tb_Regs [1279:1216] = Regs[19];
  assign tb_Regs [1343:1280] = Regs[20];
  assign tb_Regs [1407:1344] = Regs[21];
  assign tb_Regs [1471:1408] = Regs[22];
  assign tb_Regs [1535:1472] = Regs[23];
  assign tb_Regs [1599:1536] = Regs[24];
  assign tb_Regs [1663:1600] = Regs[25];
  assign tb_Regs [1727:1664] = Regs[26];
  assign tb_Regs [1791:1728] = Regs[27];
  assign tb_Regs [1855:1792] = Regs[28];
  assign tb_Regs [1919:1856] = Regs[29];
  assign tb_Regs [1983:1920] = Regs[30];
  assign tb_Regs [2047:1984] = Regs[31];
 

  always @(posedge clk)
  begin
    if(~CTRL_stall)
    begin
      case (rs_tag )
          notag, st_1, st_2  : ;
          default : 
          begin
                if(!nodest)
                Tags[reg_dest] <= rs_tag;
          end
      endcase
    end
  end

  always @(posedge clk)
  begin
      // --receive input data from the rob
      if ((rob_id != notag))
      begin
          for (i=0; i<32; i= i +1)
          begin
                if(Tags[i] == rob_id)
                begin
                      Regs[i] = rob_data;
                      Tags[i] = 0;
                end
          end
      end
  end

  always @(*)
  begin
      case (rs_tag)
          notag :
          begin
               op_1 = 0; 
               op_2 = 0;
               tag_1 = 0;
               tag_2 = 0;
          end
          default :
          begin
                // -- in rs, only use the operands 
                // -- that make sense
                op_1 = Regs[reg_src_1];
                op_2 = Regs[reg_src_2];
                tag_2 = Tags[reg_src_2];
                tag_1 = Tags[reg_src_1];
                if(opcode == op_beq)
                    tag_2 = 0;
                if (opcode == op_jmp)
                    tag_1 = 0;
          end
       endcase
  end
endmodule
