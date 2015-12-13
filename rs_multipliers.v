module rs_mult(

// ---- INPUTS -------

//clock input
    input clk,

// CONTROL inputs
    // -- issue control
    input incoming,
    // --adder 
    input multiplier_ready,

//  DATA inputs
    // -- rs station entry
    input [3:0] tag_1,
    input [3:0] tag_2,
    input [63:0] op_1,
    input [63:0] op_2,
	input [1:0] rob_slot,
    // -- cdb
    input [3:0] cdb_id,
    input [63:0] cdb_data,

// ---- OUTPUTS -------

//  CONTROL outputs
    // -- arbiter
    output  ready_to_write,
    // --issue control logic
    output busy,
    output reg [3:0] free_rs, 

//  DATA outputs
    // -- arbiter
    output reg [3:0] cdb_write_id,
	output reg [1:0] rob_dest,
    // --to adder 
    output reg [63:0] multiplier_A,
    output reg [63:0] multiplier_B,
    output  mult_flag

);

  //dummy counter variable
  reg [1:0] i;

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
   reg [1:0] rob [0:2];
   reg [63:0] op1 [0:1];
   reg [63:0] op2 [0:1];
   reg [3:0] tag1 [0:1];
   reg [3:0] tag2 [0:1];
   reg free [0:1];
   wire ready [0:1];

   initial
   begin
      op1[0]=0; op2[0]=0; tag1[0]=0;tag2[0]=0; free[0]=1; 
      op1[1]=0; op2[1]=0; tag1[1]=0;tag2[1]=0; free[1]=1; 
   end

   //adder reservation CONTROL


   //OUTPUT CONTROL SIGNALS

   // -- issue-control logic
   assign busy = ((~free[0]) & (~free[1])) ;
   assign ready[0] = ~(tag1[0][0] | tag1[0][1] | tag1[0][2] | tag1[0][3] | tag2[0][0] | tag2[0][1] | tag2[0][2] | tag2[0][3] | free[0]);
   assign ready[1] = ~(tag1[1][0] | tag1[1][1] | tag1[1][2] | tag1[1][3] | tag2[1][0] | tag2[1][1] | tag2[1][2] | tag2[1][3] | free[1]);
   assign ready_to_write = (ready[0] | ready[1] ) & multiplier_ready ;
   assign mult_flag = ready[0] | ready[1] ;


   always @(*)
   begin
      // --- which reservation station is the next one 
      if(free[0]) free_rs = mult_1; 
      else if (free[1]) free_rs = mult_2;
      else free_rs = notag;
   end

   //OUTPUT DATA
  always @(*)
  begin
      // -- give multiplier inputs
      if ((ready[0] == 1) && (ready[1] != 1))
      begin
		 rob_dest = rob[0];
         multiplier_A = op1[0];
         multiplier_B = op2[0];
         cdb_write_id = mult_1;
      end
      else if (ready[1] == 1)
      begin
		 rob_dest = rob[1];
         multiplier_A = op1[1];
         multiplier_B = op2[1];
         cdb_write_id = mult_2;
      end
  end

   //WRITES
  always @(posedge clk)
  begin
      // -- free a reservation station
      if(multiplier_ready )
      begin
          if(cdb_id ==mult_1)
          begin
              free[0] <= 1;
              tag1[0] <= notag;
              tag2[0] <= notag;
              op1[0] <= 0;
              op2[0] <= 0;
          end
          else if(cdb_id == mult_2)
          begin
              free[1] <= 1;
              tag1[1] <= notag;
              tag2[1] <= notag;
              op1[1] <= 0;
              op2[1] <= 0;
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
            if (cdb_id == tag_1)
            begin
                op1[0] <= cdb_data;
                tag1[0] <= 0; 
            end
            else
            begin
                op1[0] <= op_1; 
                tag1[0] <= tag_1; 
            end
            if (cdb_id == tag_2)
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
         end
         else if (free[1])
         begin
            if (cdb_id == tag_1)
            begin
                op1[1] <= cdb_data;
                tag1[1] <= 0; 
            end
            else
            begin
                op1[1] <= op_1; 
                tag1[1] <= tag_1; 
            end
            if (cdb_id == tag_2)
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
         end
      end
   end

   always @(posedge clk)
   begin
      // --- cdb writes to the reservation station
            for(i=0; i<2; i=i+1)
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
