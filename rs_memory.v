module rs_memory(  //includes load and store buffers and their datastructures
                   //the book's diagram does not show one of the op data
                   //for load and store each
                   //if there are too many loads/stores then there are structural
                   //hazards
    //clk input
    input clk,

    input incoming, //means new load/store instruction is inbound
    input mem_ready, //means memory is ready for wb

    //data inputs
    input [63:0] vj,  //the two operand values
    input [63:0] vk,
    input [3:0] qj,  //the two operand tags (if value not available)
    input [3:0] qk,
    input [63:0] A,   //offset
	input [1:0] rob_slot,

    //CONTROL inputs
    input CTRL_ld, //says whether the ld or st unit should
    input CTRL_st, //accept instruction

    input [3:0] cdb_id, //data id of cdb i.e. who sent the data
    input [63:0] cdb_data, // data incoming on the cdb

	//ROB inputs
	input CTRL_rob_storeDataReady,
	input [63:0] rob_store_val,
	input [63:0] rob_store_addr,
	
    // CONTROL outputs
    // -- to issue control
    output ld_busy, //means ld reservation station is full
    output st_busy,  //means store reservation station is full
    // -- to the arbiter
    output  ready_to_write,
    output [3:0]  cdb_write_id,
	output reg [1:0] rob_dest,

    // DATA to the memory unit
    output [63:0] mem_data,
    output [63:0] mem_address,
    output reg [1:0] control,  //says whether ld or store or nothing

    //tag to the regfile (for load)
    output [3:0] ld_free_tag,
    output [3:0] st_free_tag

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

function [63:0] get_val;
input [3:0] tag;
input [64*5 - 1:0] address_bus;
    case(tag)
        st_1 : get_val =  address_bus[63:0];
        st_2 : get_val =  address_bus[127:64];
        ld_1 : get_val =  address_bus[191:128];
        ld_2 : get_val =  address_bus[255:192];
        ld_3 : get_val =  address_bus[319:256];
        default : get_val = 0;
    endcase
endfunction


   assign busy = ld_busy & st_busy ; // means both load and store are busy


   //LOAD STORE data structures
   wire wr_en;
   reg rd_en;
   wire [3:0] tag_out;
   wire [3:0] tag_in;
   reg [3:0] query_tag_ld, query_tag_st;
   reg affinity_calc_ready;
   wire [3:0] mem_tag;
   reg remove;

  // buses
   wire [64*5 -1 : 0] address_bus;
   wire [64*5 -1 : 0] data_bus;
   wire [64*3 -1 :0] ld_data_bus;
   wire [64*2 -1 :0] st_data_bus;
   wire [64*3 -1 :0] ld_address_bus;
   wire [64*2 -1 :0] st_address_bus;
   wire [4:0] ready_bus;
   wire [2:0] ld_ready_bus;
   wire [1:0] st_ready_bus;

  //calc affinity wires
  wire [63:0] ld_affinity_op;
  wire [63:0] st_affinity_op;
  wire [63:0] ld_affinity_offset;
  wire [63:0] st_affinity_offset;
  reg [63:0] op, offset;
  wire [63:0] address;
  reg lsq_rst;

  assign address_bus = { ld_address_bus, st_address_bus };
  assign data_bus = { ld_data_bus, st_data_bus  };
  assign ready_bus = { ld_ready_bus, st_ready_bus } ;
  assign tag_in = CTRL_ld ? ld_free_tag : st_free_tag;
  assign wr_en = incoming;

   always @(*)
   begin
      // -- decide whether to read from load store queue
       if (tag_out == notag) rd_en = 1;
       else rd_en = affinity_calc_ready;
   end


  initial 
  begin
      lsq_rst = 0;
      #1
      lsq_rst = 1;
      #1
      lsq_rst = 0;
  end


   load_store_queue lsq(clk, tag_in, wr_en, rd_en, lsq_rst, tag_out);

   mem_order mo(clk, affinity_calc_ready, ready_bus, address_bus,  tag_out, remove, mem_tag ); //order entry goes to mem

   rs_load rs_load (clk, vj, qj, A, address, query_tag_ld, CTRL_ld, remove, mem_tag,
                     cdb_id, cdb_data, ld_free_tag, ld_address_bus, ld_data_bus,
                     ld_ready_bus, ld_busy, ld_aff_ready,ld_affinity_op, ld_affinity_offset );

					 
	//delete this Reservation Station
	//input comes from the ROB
   //rs_store rs_store (clk, vj, vk, qj, qk, A, address, query_tag_st, CTRL_st, remove,
    //                  mem_tag, cdb_id, cdb_data, st_free_tag, st_address_bus, st_data_bus,
     //                 st_ready_bus,st_busy, st_aff_ready, st_affinity_op, st_affinity_offset );

   address_calc address_calc(op,  offset, address);

   
   //mux here with store input from ROB, rob_store_addr and rob_store_val
  assign mem_address = get_val(mem_tag, address_bus);
  assign mem_data = get_val(mem_tag, data_bus);
  assign ready_to_write = (ready_bus[4] | ready_bus[3] | ready_bus[2]) & mem_ready ;
  
  //mux mem tag here with str1
  assign cdb_write_id = mem_tag;


  always @(*)
  begin
      // --- control input to memory
      case (mem_tag)
          ld_1, ld_2, ld_3 : control = 2'b01;
          st_1, st_2 : control = 2'b00;
          default : control = 2'b11;
      endcase
  end

  always @(*)
  begin
      // --- remove logic
      if(mem_ready == 1)
      begin
         if ((mem_tag == st_1) || (mem_tag == st_2) )
         begin
              remove = 1;
         end
         else if((cdb_id == ld_1) || (cdb_id == ld_2) || (cdb_id == ld_3))
         begin
              remove = 1;
         end
         else  remove = 0;
      end
      else remove = 0;
  end

   always @(*)
   begin
      // --decide the reservation station whose affinity is to be calculated
      if ( tag_out == ld_1 || tag_out == ld_2 || tag_out == ld_3 )
      begin
          query_tag_ld = tag_out;
          query_tag_st = notag;
      end
      else
      begin
          query_tag_st = tag_out;
          query_tag_ld = notag;
      end
   end

   always @(*)
   begin
      // -- either load or store affinity is ready to be calculated
      affinity_calc_ready = ld_aff_ready | st_aff_ready ;
   end

   //ADDRESS logic unit
   always @(*)
   begin
      if (ld_aff_ready)
      begin
          op = ld_affinity_op;
          offset = ld_affinity_offset;
      end
      else if (st_aff_ready)
      begin
          //$display ("Store aff ready !");
          op = st_affinity_op;
          offset = st_affinity_offset;
      end
   end
endmodule
