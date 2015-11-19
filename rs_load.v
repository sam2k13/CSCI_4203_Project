module rs_load(
    input clk,

    //DATA inputs
    input [63:0] vj,  //the operand
    input [3:0]  qj,  //the tag
    input [63:0] offset,   //offset

    //query reservation entry by tag
    input [63:0] address, //from affinity calc
    input [3:0] query_tag,

    //CONTROL
    input CTRL_ld,

    //INPUT which tag should be freed
    input free_tag_flag,
    input [3:0] free_this_tag,

    //cdb
    input [3:0] cdb_id,
    input [63:0] cdb_data,


    //OUTPUT data
    output  reg [3:0] free_tag,
    output  [64*3 -1:0] load_addr,
    output  [64*3 -1:0] load_data,
    output [2:0] ready_bus,


    //OUTPUT control signal
    output busy,
    output reg ld_aff_ready,
    output reg [63:0] ld_affinity_op,
    output reg [63:0] ld_affinity_offset


);

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
          st_2 = 10;
    //fields of the reservation station
    reg [63:0] op [0:2] ; //it is an address, which is 64 bits
    reg [3:0] tag [0:2] ; //tag if the address is not available
    reg [63:0] A [0:2] ; //affinity -- it is address + offset
    reg free [0:2] ; //says whether the slot is free
    wire ready [0:2] ;

  initial
  begin
      free[0] = 1;
      free[1] = 1;
      free[2] = 1;
      ld_aff_ready = 0;
      ld_affinity_op = 0;
      ld_affinity_offset = 0;
      free_tag = ld_1;
  end



    assign load_addr[63:0] = A[0];
    assign load_addr[127:64] = A[1];
    assign load_addr[191:128] = A[2];
    assign load_data[63:0] = op[0]; //does not matter
    assign load_data[127:64] = op[1];
    assign load_data[191:128] = op[2];
    assign ready_bus[2] = ready[0];
    assign ready_bus[1] = ready[1];
    assign ready_bus[0] = ready[2];

   assign busy = (~free[0]) && (~free[1]) && (~free[2]);
   assign ready[0] = ~(tag[0][0] | tag[0][1] | tag[0][2] | tag[0][3] | free[0]);
   assign ready[1] = ~(tag[1][0] | tag[1][1] | tag[1][2] | tag[1][3] | free[1]);
   assign ready[2] = ~(tag[2][0] | tag[2][1] | tag[2][2] | tag[2][3] | free[2]);

    always @(*)
    begin
        if(free[0]) free_tag = ld_1;
        else if (free[1]) free_tag = ld_2;
        else if (free[2]) free_tag = ld_3;
        else free_tag = notag;
    end

    always @(*)
    begin
        //-- information for affinity calculation
        case (query_tag)
            ld_1 :
                   begin
                          ld_aff_ready = ready[0];
                          ld_affinity_op = op[0];
                          ld_affinity_offset = A[0];
                   end
            ld_2 :
                   begin
                          ld_aff_ready = ready[1];
                          ld_affinity_op = op[1];
                          ld_affinity_offset = A[1];
                   end
            ld_3 :
                   begin
                          ld_aff_ready = ready[2];
                          ld_affinity_op = op[2];
                          ld_affinity_offset = A[2];
                   end
            default : 
                   begin
                          ld_aff_ready = 0 ;
                          ld_affinity_op = 0;
                          ld_affinity_offset = 0;
                   end
        endcase
    end

    always @(posedge clk)
    begin

        //ISSUE
        if (CTRL_ld)
        begin
          if (free[0])
          begin
              tag[0] <= qj;
              A[0] <= offset;
              op[0] <= vj;
              free[0] <= 0;
          end
          else if (free[1])
          begin
              tag[1] <= qj;
              A[1] <= offset;
              op[1] <= vj;
              free[1] <= 0;
          end
          else if (free[2])
          begin
              tag[2] <= qj;
              A[2] <= offset;
              op[2] <= vj;
              free[2] <= 0;
          end
        end

        //EXECUTE (Calc Affinity)
        if(ld_aff_ready)
        begin
            case (query_tag)
                ld_1 :
                      begin
                          A[0] <= address;
                      end
                ld_2 :
                      begin
                          A[1] <= address;
                      end
                ld_2 :
                      begin
                          A[2] <= address;
                      end
                default : ;
            endcase
        end

        // WRITEBACK
        //clear the entry from the reservation station
        if(free_tag_flag)
        begin
            case(free_this_tag)
                ld_1 :
                       free[0] <= 1;
                ld_2 : free[1] <= 1;
                ld_3 : free[2] <= 1;
            endcase
        end

        begin
             if(tag[0] == cdb_id)
             begin
                 op[0] <= cdb_data;
                 tag[0] <= 0;
             end
             if(tag[1] == cdb_id)
             begin
                 op[1] <= cdb_data;
                 tag[1] <= 0;
             end
             if(tag[2] == cdb_id)
             begin
                 op[2] <= cdb_data;
                 tag[2] <= 0;
             end
        end
    end
endmodule
