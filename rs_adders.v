module rs_adder(
// ---- INPUTS -------
//clock input
    input clk,

// CONTROL inputs
    // -- issue control
    input incoming,
    input [5:0] opcode,
    // --adder
    input adder_ready,

//  DATA inputs
    // -- rs station entry
    input [3:0] tag_1,
    input [3:0] tag_2,
    input [63:0] op_1,
    input [63:0] op_2,
    input [63:0] incrPC,
    input [63:0] offset,

    // -- cdb
    input [3:0] cdb_id,
    input [63:0] cdb_data,

// ---- OUTPUTS -------

//  CONTROL outputs
    // -- arbiter
    output  ready_to_write,
    // --issue control logic
    output busy,
    // -- to issue logic
    output reg [3:0] free_rs,

//  DATA outputs
    // -- arbiter
    output reg [3:0] cdb_write_id,
    // --to adder
    output reg [63:0] adder_A,
    output reg [63:0] adder_B,
    output reg [63:0] adder_incrPC,
    output reg [63:0] adder_offset,
    output reg [63:0] adder_opcode,
    output adder_flag

);

  //dummy counter variable
  reg [1:0] i;


  parameter  op_beq = 6'b111001,
             op_jmp = 6'b011010 ;

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

   //adder reservation data
   reg [63:0] op1 [0:2];
   reg [63:0] op2 [0:2];
   reg [3:0] tag1 [0:2];
   reg [3:0] tag2 [0:2];
   reg free [0:2];
   wire ready [0:2];

   //branch reservation data
   reg [63:0] rs_incrPC [0:2];
   reg [63:0] rs_offset [0:2];
   reg [5:0] rs_opcode [0:2]; //can be add, sub, branch etc ..
                                   //we have only implemented add, 
                                   //beq and jmp

   initial
   begin
      op1[0]=0;op2[0]=0;tag1[0]=0;tag2[0]=0;free[0]=1; rs_opcode[0]=0; rs_offset[0]=0; rs_incrPC[0]=0;
      op1[1]=0;op2[1]=0;tag1[1]=0;tag2[1]=0;free[1]=1; rs_opcode[1]=0; rs_offset[1]=0; rs_incrPC[1]=0;
      op1[2]=0;op2[2]=0;tag1[2]=0;tag2[2]=0;free[2]=1; rs_opcode[2]=0; rs_offset[2]=0; rs_incrPC[2]=0;
   end

   //OUTPUT CONTROL SIGNALS

   // -- issue-control logic
   assign busy = (~free[0]) & (~free[1])  & (~free[2]) ;
   assign ready[0] = ~(tag1[0][0] | tag1[0][1] | tag1[0][2] | tag1[0][3] | tag2[0][0] | tag2[0][1] | tag2[0][2] | tag2[0][3] | free[0]);
   assign ready[1] = ~(tag1[1][0] | tag1[1][1] | tag1[1][2] | tag1[1][3] | tag2[1][0] | tag2[1][1] | tag2[1][2] | tag2[1][3] | free[1]);
   assign ready[2] = ~(tag1[2][0] | tag1[2][1] | tag1[2][2] | tag1[2][3] | tag2[2][0] | tag2[2][1] | tag2[2][2] | tag2[2][3] | free[2]);
   assign ready_to_write = (ready[0] | ready[1] | ready[2]) & adder_ready ;
   assign adder_flag = ready[0] | ready[1] | ready[2];

   always @(*)
   begin
      // -- which is the next free reservation station
      if (free[0]) free_rs = add_1 ;
      else if (free[1]) free_rs = add_2;
      else if (free[2]) free_rs = add_3;
      else free_rs = notag;
   end

   //OUTPUT DATA

  always @(ready[0], ready[1], ready[2])
  begin
      // -- give adder inputs
      if ((ready[0] == 1) && (ready[1] != 1) && (ready[2] != 1))
      begin
         adder_A = op1[0];
         adder_B = op2[0];
         adder_incrPC = rs_incrPC[0];
         adder_offset = rs_offset[0];
         adder_opcode = rs_opcode[0];
         cdb_write_id = add_1;
      end
      else if ((ready[1] == 1) && (ready[2] != 1))
      begin
         adder_A = op1[1];
         adder_B = op2[1];
         adder_incrPC = rs_incrPC[1];
         adder_offset = rs_offset[1];
         adder_opcode = rs_opcode[1];
         cdb_write_id = add_2;
      end
      else if (ready[2] == 1 )
      begin
         adder_A = op1[2];
         adder_B = op2[2];
         adder_incrPC = rs_incrPC[2];
         adder_offset = rs_offset[2];
         adder_opcode = rs_opcode[2];
         cdb_write_id = add_3;
      end
      else
      begin
         adder_opcode = 0;
      end
  end

   //WRITES
  always @(posedge clk)
  begin
      // -- free a reservation station
      if(adder_ready )
      begin
          if(cdb_id == add_1)
          begin
              free[0] <= 1;
              tag1[0] <= notag;
              tag2[0] <= notag;
              op1[0] <= 0;
              op2[0] <= 0;
          end
          else if(cdb_id == add_2)
          begin
              free[1] <= 1;
              tag1[1] <= notag;
              tag2[1] <= notag;
              op1[1] <= 0;
              op2[1] <= 0;
          end
          else if(cdb_id == add_3)
          begin
              free[2] <= 1;
              tag1[2] <= notag;
              tag2[2] <= notag;
              op1[2] <= 0;
              op2[2] <= 0;
          end
      end
  end

   always @(posedge clk)
   begin
      // --- new instruction writes to reservation station
      if(incoming)
      begin
         if(free[0])
         begin
            if(tag_1 == cdb_id)
            begin
                op1[0] <= cdb_data;
                tag1[0] <= 0;
            end
            else
            begin
                op1[0] <= op_1;
                tag1[0] <= tag_1;
            end

            if (tag_2 == cdb_id)
            begin
                op2[0] <= cdb_data;
                tag2[0] <= 0;
            end
            else
            begin
                op2[0] <= op_2;
                tag2[0] <= tag_2;
            end

            free[0] <= 0;
            rs_incrPC[0] <= incrPC;
            rs_offset[0] <= offset;
            rs_opcode[0] <= opcode;
         end
         else if (free[1])
         begin
            if(tag_1 == cdb_id)
            begin
                op1[1] <= cdb_data;
                tag1[1] <= 0;
            end
            else
            begin
                op1[1] <= op_1;
                tag1[1] <= tag_1;
            end

            if (tag_2 == cdb_id)
            begin
                op2[1] <= cdb_data;
                tag2[1] <= 0;
            end
            else
            begin
                op2[1] <= op_2;
                tag2[1] <= tag_2;
            end

            free[1] <= 0;
            rs_incrPC[1] <= incrPC;
            rs_offset[1] <= offset;
            rs_opcode[1] <= opcode;
         end
         else if (free[2])
         begin
            if(tag_1 == cdb_id)
            begin
                op1[2] <= cdb_data;
                tag1[2] <= 0;
            end
            else
            begin
                op1[2] <= op_1;
                tag1[2] <= tag_1;
            end

            if (tag_2 == cdb_id)
            begin
                op2[2] <= cdb_data;
                tag2[2] <= 0;
            end
            else
            begin
                op2[2] <= op_2;
                tag2[2] <= tag_2;
            end

            free[2] <= 0;
            rs_incrPC[2] <= incrPC;
            rs_offset[2] <= offset;
            rs_opcode[2] <= opcode;
         end
      end
   end

   always @(posedge clk)
   begin
      // --- cdb writes to the reservation station
            for(i=0; i<3; i=i+1)
            begin
                if(tag1[i] == cdb_id )
                begin
                    op1[i] <= cdb_data;
                    tag1[i] <= 0;
                end
                if(tag2[i] == cdb_id )
                begin
                    op2[i] <= cdb_data;
                    tag2[i] <= 0;
                end
            end
   end
endmodule
