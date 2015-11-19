module tomasulo(
    input clk,
    output [64*32 -1:0] tb_regs,
    output [64*64 -1:0] tb_mem
);

  //program counter
  wire [63:0] PC_input, PC_output, incrPC, branchPC;

  //instruction queue wires
  wire [31:0] iq_inst_in, iq_inst_out;
  wire [63:0] incrPC_out;
  wire iq_empty, iq_full, flush;
  wire rd_en, wr_en;

  //issue control wires
  wire [3:0] rs_mult_free;
  wire [3:0] rs_adder_free;
  wire [3:0] rs_ld_free;
  wire [3:0] rs_st_free;
  wire [3:0] rs_br_free;

  wire [4:0] reg_src1;
  wire [4:0] reg_src2;
  wire [4:0] reg_dest;
  wire [3:0] rs_tag; //tag indicates rs
  wire nodest; //for st and beq instructions
  wire CTRL_ld; //says whether to accept instruction or not
  wire CTRL_st;
  wire CTRL_mem;
  wire CTRL_add;
  wire CTRL_mult;
  wire CTRL_br;
  wire [5:0] opcode;
  wire stall;
  assign CTRL_mem = CTRL_ld | CTRL_st;

  //offset_data wires
  wire [15:0] offset_ldst;
  wire [20:0] offset_beq;
  wire [63:0] beq_out;
  wire [63:0] ldst_out;

  //register file wires
  wire [63:0] op_1;  //operand buses
  wire [63:0] op_2;
  wire [3:0] tag_1;
  wire [3:0] tag_2;
  wire [63:0] offset;

  //FUNCTIONAL UNIT wires
  // --- 1.Adder wires
  wire [63:0] add_a;
  wire [63:0] add_b;
  wire [63:0] add_c;
  wire [63:0] adder_incrPC;
  wire [63:0] adder_offset;
  wire [63:0] adder_opcode;
  wire CTRL_PC;
  wire br_stall;

  // --- 2.Multiplier wires
  wire [63:0] mult_a;
  wire [63:0] mult_b;
  wire [63:0] mult_c;

  // --- 3.Memory wires
  wire [63:0] datIn,addr;
  wire [1:0] control;
  wire [63:0] wb_data;


   //RESERVATION STATION wires
   //  -- 1. Memory rs

   wire mem_ready;
   wire rs_mem_ready; //controller says write to the cdb
   wire [3:0] rs_mem_cdb_id;
   wire ld_busy; //means the buffer is full and cannot accept
   wire st_busy; //means the buffer is full and cannot accept

   // -- 2. Adder rs
    wire adder_ready;
    wire rs_adder_ready; //means at least one entry has both operands
    wire rs_adder_busy;
    wire [3:0] rs_adder_cdb_id;
    wire rs_adder_input;

    // -- 3. Mult rs
    wire mult_ready;
    wire rs_mult_ready;
    wire rs_mult_busy; 
    wire [3:0] rs_mult_cdb_id;
    wire rs_mult_input;


  //ARBITER wires

  wire status_cdb_ld;
  wire status_cdb_store; 
  wire status_cdb_add;
  wire status_cdb_mult;

  wire CTRL_cdb_ld;
  wire CTRL_cdb_store;
  wire CTRL_cdb_add;
  wire CTRL_cdb_mult;

  //CDB (common data bus)
  wire [63:0] CDB;
  wire [3:0] cdb_id;

  //initial
  //begin
    //$display ("| time | clock | PC_output | PC_input | iq_empty | CTRL_PC/flush | stall");
    //$monitor(" clk is %d, stall is %d", clk, stall);
    //$monitor (" clk is %d, inst_in is %b ", clk, iq_inst_in);
    //$monitor (" | %2t | %d | %d | %d | %d | %d | %d |" , $time, clk, PC_output, PC_input, iq_empty, CTRL_PC, stall );
  //end

  //FETCH
  pipeline_latch_64 PC( clk, PC_input, {1'b0, stall}, PC_output );
  ifetch FETCH(PC_output, clk, iq_inst_in, incrPC);
  multiplexer_2_64bit multiplexer_PC(incrPC, branchPC,  CTRL_PC, PC_input);

  //INSTRUCTION QUEUE
  inst_queue IQ(clk, iq_inst_in, incrPC,  wr_en, rd_en, flush,  iq_empty, iq_full, iq_inst_out, incrPC_out);
  assign wr_en = ~stall;
  assign rd_en = ~stall;
  assign flush = CTRL_PC;

  //ISSUE CONTROL
  issue issue(clk, iq_inst_out, rs_mult_free, rs_adder_free, rs_ld_free, rs_st_free, rs_br_free, br_stall,
              reg_src1, reg_src2, reg_dest, rs_tag, nodest, CTRL_ld, CTRL_st, CTRL_add,
              CTRL_mult, CTRL_br, opcode, stall);

  //OFFSET data
  assign offset_ldst = iq_inst_out[15:0];
  assign offset_beq = iq_inst_out[20:0];
  offset_data offset_data(offset_ldst, offset_beq, beq_out, ldst_out);

  //REGISTER FILE
  regfile regfile(clk, stall, rs_tag, opcode, reg_src1, reg_src2, reg_dest, nodest,
                  cdb_id, CDB,op_1,op_2,tag_1, tag_2, tb_regs);
                                                //regfile

  //RESERVATION STATIONS

  //---   1. memory unit -- reservation stations and logic
  rs_memory rs_memory ( clk, CTRL_mem, mem_ready, op_1, op_2, tag_1, tag_2, ldst_out, CTRL_ld,
                        CTRL_st, cdb_id, CDB, ld_busy, st_busy, rs_mem_ready,
                        rs_mem_cdb_id, datIn, addr, control, rs_ld_free, rs_st_free   );


  //---   2. adder reservation stations
  rs_adder rs_adder (clk, CTRL_add, opcode, adder_ready,
                     tag_1, tag_2, op_1, op_2, incrPC_out, beq_out, 
                     cdb_id, CDB, rs_adder_ready, rs_adder_busy,
                     rs_adder_free, rs_adder_cdb_id, add_a, add_b,
                     adder_incrPC, adder_offset, adder_opcode, rs_adder_input );

  //---   3. multiplier reservation station
  rs_mult  rs_mult( clk, CTRL_mult, mult_ready,
                     tag_1, tag_2, op_1, op_2,
                     cdb_id, CDB, rs_mult_ready, rs_mult_busy,
                     rs_mult_free, rs_mult_cdb_id, mult_a, mult_b, rs_mult_input );

  //FUNCTIONAL UNITS

  //---   1. Adders and adder logic
  adder adder(clk,add_a, add_b, status_cdb_add, rs_adder_input, adder_incrPC,
              adder_offset, adder_opcode,  add_c, adder_ready, CTRL_PC, 
              branchPC,  br_stall );

  //---   2. Multiplier and multiplier logic
  multiplier multiplier(clk, mult_a, mult_b, status_cdb_mult, rs_mult_input,  mult_c, mult_ready);

  //---  3. Memory unit and logic
  memory memory(clk, datIn, addr, control, CTRL_cdb_ld, wb_data, mem_ready, tb_mem);

  //bus arbiter

  arbiter arbiter( status_cdb_ld, status_cdb_store, status_cdb_add, status_cdb_mult,
                  CTRL_cdb_ld, CTRL_cdb_store, CTRL_cdb_add, CTRL_cdb_mult );

  assign status_cdb_ld = rs_mem_ready & mem_ready;
  assign status_cdb_st = 0; //store never results in wb
  assign status_cdb_add = rs_adder_ready & adder_ready;
  assign status_cdb_mult = rs_mult_ready & mult_ready;


  //CDB
  tri_buffer b1(add_c, CTRL_cdb_add, CDB);
  tri_buffer b2(mult_c, CTRL_cdb_mult, CDB);
  tri_buffer b4(wb_data, CTRL_cdb_ld, CDB);

  tri_buffer_4bit b11(rs_adder_cdb_id, CTRL_cdb_add, cdb_id);
  tri_buffer_4bit b21(rs_mult_cdb_id, CTRL_cdb_mult, cdb_id);
  tri_buffer_4bit b31(rs_mem_cdb_id, CTRL_cdb_ld, cdb_id);

endmodule
