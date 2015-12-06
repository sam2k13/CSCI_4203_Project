//rob.v

module rob(

	//instructin inputs

	input [3:0] instr_op,
	input [31:0] instr_dst,
	
	//branch input
	
	input CTRL_PC,
	
	//cdb inputs
	
	input [3:0] cdb_id,
	input [63:0] cdb_data,
		
	//outputs to regfile	
	
	output [3:0] rob_id,
	output [63:0] rob_data,
	
	//CTRL outputs
	
	output CTRL_flush,
	output CTRL_rob_full,
	output CTRL_rob_store,
	
	//outputs to the store memory unit
	
	output [63:0] rob_store_addr,
	output [63:0] rob_store_val
	
	
);

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


			
reg [3:0] ROB_op [0:1]; //4 ROB op registers
reg [63:0] ROB_dst [0:1]; //4 ROB Dst registers
reg [1:0] ROB_dst_type [0:1]; // r ROB type registers 0 = no destination, 1 = register, 2 = memory
reg [63:0] ROB_val [0:1]; //4 ROB val registers
reg  ROB_ready [0:1]; //4 ROB ready registers
reg  ROB_open [0:1]; //4 ROB ready registers


//implement adding to the reorder buffer
//use instr_op, instr_dst, set rob_ready = 0
//use for loop to find empty rob slot
//check for first slot where ROB_open == 1



always @(posedge clk)
  begin
      // --receive input data from the rob
      if ((cdb_id != notag))
      begin
          for (i=0; i<3; i=i+1)
          begin
                if(ROB_op[i] == cdb_id)
                begin
                    ROB_val[i] = cbd_data;
					ROB_ready[i] = 1;
                end
          end
      end
	  
	  //check if first value is ready...
	  if(ROB_ready[0])
	  begin
		
		//check if dest type is no destination
		if(ROB_dst_type == 2'b00)
		begin
			if(cdb_id == add_1 | cdb_id == add_2 | cdb_id == add_3)
			begin
				if(CTRL_PC)
				begin
					//flush ROB
					//clear all rob values
					//set rob_open == 1
				end
			end
		end	
		else if(ROB_dst_type == 2'b01) // dest type is register
		begin
			rob_id = ROB_op[0];
			rob_data = ROB_val[0];
			//clear rob entry
			//sent to regfile
		end
		else if(ROB_dst_type == 2'b10) // dest type is memory
		begin
			//store to mem
			CTRL_rob_store = 1;
			rob_store_addr = ROB_dst[0];
			rob_store_val = ROB_val[0];	
			//clear ROB Entry
		end
		
		
		//shift up ROB here
		//check ROB_open for values to shift
		//set the rob slot that was the last shifted to rob open
		
		
	  
	  end
	  
	  
	   
  end


	
