module rs_store(
    input clk,

    //DATA inputs
    input [63:0] vj,
    input [63:0] vk, 
    input [3:0] qj,
    input [3:0] qk,
    input [63:0] offset,
	input [1:0] rob_slot,

    input [63:0] address, //from affinity calc
    input [3:0] query_tag, //for affinity calc

    //CONTROL inputs
    input CTRL_st,

    //FREE a reservation entry
    input free_tag_flag,
    input [3:0] free_this_tag,

    //cdb
    input [3:0] cdb_id,
    input [63:0] cdb_data,

    //OUTPUT data
    output reg [3:0] free_tag,
    output  [64*2 -1:0] st_addr, 
    output  [64*2 -1:0] st_data, 
    output [1:0] ready_bus,
	output reg [1:0] rob_dest,

    //OUTPUT control signals
    output busy,
    output reg st_aff_ready,
    output reg [63:0] st_affinity_op,
    output reg [63:0] st_affinity_offset
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

  //fields of the reservation station
  reg [63:0] op1 [0:1] ; //it is a value of the register to store
  reg [63:0] op2 [0:1] ; //It is an address
  reg [3:0] tag1 [0:1] ; //tag if the address is not available
  reg [3:0] tag2 [0:1] ; //tag if the value is not available
  reg [63:0] A [0:1] ; //It is the address + affinity
  reg [1:0] rob [0:2];
  reg free [0:1] ; //says whether the slot is free
  wire ready [0:1];
  

  assign busy  = ~( free [0] | free[1] ); //says whether any reservation station is free
  assign ready[0] = ~(tag1[0][0] | tag1[0][1] | tag1[0][2] | tag1[0][3]  | tag2[0][0] | tag2[0][1] | tag2[0][2] | tag2[0][3] | free[0]);
  assign ready[1] = ~(tag1[1][0] | tag1[1][1] | tag1[1][2] | tag1[1][3]  | tag2[1][0] | tag2[1][1] | tag2[1][2] | tag2[1][3] | free[1]);



  assign st_addr[63:0] = A[0];
  assign st_addr[127:64] = A[1];
  assign st_data[63:0] = op1[0];
  assign st_data[127:64] = op1[1];
  assign ready_bus [1] = ready[0]; 
  assign ready_bus [0] = ready[1]; 


  initial 
  begin
        op1[0]=0;op2[0]=0;tag1[0]=0;tag2[0]=0;A[0]=0;free[0]=1;
        op1[1]=0;op2[1]=0;tag1[1]=0;tag2[1]=0;A[1]=0;free[1]=1;
        st_aff_ready = 0;
        st_affinity_op = 0;
        st_affinity_offset =0; 
        free_tag = st_1;
  end


  //the free reservation station
  always @(*)
  begin
      if(free[0]) free_tag = st_1;
      else if (free[1]) free_tag = st_2;
      else free_tag = notag;
  end

    always @(*)
    begin
        //-- information for affinity calculation
        case (query_tag)
            st_1 : 
                   begin
                          st_aff_ready = ready[0];
                          st_affinity_op = op2[0];
                          st_affinity_offset = A[0];
                   end
            st_2 : 
                   begin
                          st_aff_ready = ready[1];
                          st_affinity_op = op2[1];
                          st_affinity_offset = A[1];
                   end
            default : 
                      st_aff_ready = 0;
        endcase
    end


  //write the tag
  always @(posedge clk)
  begin
    //ISSUE
    if (CTRL_st)
    begin 
      if(free[0])
      begin
          if(qj == cdb_id)
          begin
              tag1[0] <= 0;
              op1[0] <= cdb_data;
          end
          else 
          begin
              tag1[0] <= qj;
              op1[0] <= vj;
          end

          if(qk == cdb_id)
          begin
             tag2[0] <= 0;        
             op2[0] <= cdb_data;
          end  
          else
          begin
             tag2[0] <= qk; 
             op2[0] <= vk;
          end
          
          A[0] <= offset;
          free[0] <= 0;
      end
      else if (free[1])
      begin
          if(qj == cdb_id)
          begin
              tag1[1] <= 0;
              op1[1] <= cdb_data;
          end
          else 
          begin
              tag1[1] <= qj;
              op1[1] <= vj;
          end

          if(qk == cdb_id)
          begin
             tag2[1] <= 0;        
             op2[1] <= cdb_data;
          end  
          else
          begin
             tag2[1] <= qk; 
             op2[1] <= vk;
          end


          A[1] <= offset;
          free[1] <= 0;
      end
    end

        //EXECUTE (Calc Affinity)
        if(st_aff_ready)
        begin
            case (query_tag)
                st_1 : 
                      begin
                          A[0] <= address;
                      end
                st_2 : 
                      begin
                          A[1] <= address;
                      end
                default : ;
            endcase 
        end

        //EXECUTE (Memory)
        //clear the entry from the reservation station
        if(free_tag_flag)
            case(free_this_tag) 
                st_1 : free[0] <= 1;
                st_2 : free[1] <= 1;
                default : ;
            endcase

        //WRITE (from cdb)
       begin
             if(tag1[0] == cdb_id)
             begin
                 op1[0] <= cdb_data;
                 tag1[0] <= 0;
             end
             if(tag2[0] == cdb_id)
             begin
                 op2[0] <= cdb_data;
                 tag2[0] <= 0;
             end
             if(tag1[1] == cdb_id)
             begin
                 op1[1] <= cdb_data;
                 tag1[1] <= 0;
             end
             if(tag2[1] == cdb_id)
             begin
                 op2[1] <= cdb_data;
                 tag2[1] <= 0;
             end
       end
  end

endmodule
