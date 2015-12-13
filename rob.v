//rob.v

module rob(

	//instructin inputs

	input [5:0] instr_op,
	input [63:0] instr_dst,
	input nodest,
	input [1:0] instr_dst_type,
	input CTRL_instr_incoming, //if 1, there is an instruction ready to be added to ROB
	
	//branch input
	
	input CTRL_PC,
	
	//cdb inputs
	
	input [1:0] cdb_rob_dest,
	input [63:0] cdb_data,
	input CTRL_incoming_data,
	
	
	
	//outputs to regfile	
	
	output [3:0] rob_id,
	output [63:0] rob_data,
	
	//CTRL outputs
	
	output CTRL_flushRegFile,
	output CTRL_regFileDataReady,
	output CTRL_storeDataReady,
	output CTRL_rob_full,
	
	
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
reg  ROB_branch_taken [0:1]; //4 ROB ready registers

//implement adding to the reorder buffer
//use instr_op, instr_dst, set rob_ready = 0
//use for loop to find empty rob slot
//check for first slot where ROB_open == 1

always @(posedge clk)
  begin
      
	  //receive incoming data from the instruction queue
	  
	  if(CTRL_instr_incoming)
	  begin
		for(int i = 0; i < 3; i++)
		begin
			if(ROB_open[i]) // slot found!
			begin
				ROB_open[i] = 0;
				ROB_op[i] = instr_op;
				ROB_dst[i] = instr_dst;
				ROB_dst_type[i] = instr_dst_type;
				ROB_ready[i] = 0;
				ROB_val[i] = 0;
			break;
			end
		end
	  end 
	  
	  // --receive input data from the cdb
      if (CTRL_incoming_data)
      begin
			if(ROB_op[cbd_rob_dest] == 6'b111001 | ROB_op[cbd_rob_dest] == 6'b111101 | ROB_op[cbd_rob_dest] == 6'b110000 | ROB_op[cbd_rob_dest] == 6'b110100 )//branch instruction
			begin
				ROB_branch_taken[cbd_rob_dest] = CTRL_PC;
			end
                ROB_val[cbd_rob_dest] = cbd_data;
				ROB_ready[cbd_rob_dest] = 1;              
			end
      end
	  //check if first value is ready...
	  if(ROB_ready[0])
	  begin
		
		//check if dest type is no destination
		if(ROB_dst_type == 2'b00)
		begin
				if(ROB_branch_taken[0])
				begin
					//CTRL_rob_outputReady = 0;
					CTRL_rob_store = 0;
					CTRL_flushRegFile = 1;
					CTRL_rob_outputReady = 0;
					for(int x = 0; x < 3; x++)
					begin
						ROB_op[x] = 0;
						ROB_dst[x] = 0;
						ROB_dst_type[x] = 0;
						ROB_val[x] = 0;
						ROB_open[x] = 1;
						ROB_ready[x] = 0;
						ROB_branch_taken[x] = 0;
					end
				end
				
			
		end	
		else if(ROB_dst_type == 2'b01) // dest type is register
		begin
			rob_id = ROB_op[0];
			rob_data = ROB_val[0];
			CTRL_regFileDataReady = 1;
			//clear rob entry
			//sent to regfile
		end
		else if(ROB_dst_type == 2'b10) // dest type is memory
		begin
			CTRL_storeDataReady = 1;
			rob_store_addr = ROB_dst[0];
			rob_store_val = ROB_val[0];	
		end
		//shift everything up in the reorder buffer
		for(int x = 0; x < 2; x++)
		begin
			ROB_op[x] = ROB_op[x + 1];
			ROB_dst[x] = ROB_dst[x + 1];
			ROB_dst_type[x] = ROB_dst_type[x + 1];
			ROB_val[x] = ROB_val[x + 1];
			ROB_open[x] = ROB_open[x + 1];
			ROB_ready[x] = ROB_ready[x + 1];
		end
		
		//clear last slot since it has been shifted up
		ROB_op[3] = 0;
		ROB_dst[3] = 0;
		ROB_dst_type[3] = 0;
		ROB_val[3] = 0;
		ROB_open[3] = 1;
		ROB_ready[3] = 0;	
	  end
	  
	  CTRL_rob_full = !ROB_open[0] && !ROB_open[1] && !ROB_open[2] && !ROB_open[3];
	  
	   
  end


	
