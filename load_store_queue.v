`include "macro.v"
//datastructure to determine which address is calculated first

module load_store_queue(
    input clk,
    input [3:0] tag_in, //says which tag should go into queue next
    input wr_en, rd_en, //says whether to read or write into the datastructure
    input rst,
    output [3:0] tag_out //says which reservation stations's affinity should be calculated next
);

    wire empty, full;  //does not matter
    wire[`BUF_WIDTH :0] tag_counter; //does not matter


    fifo_4bit ld_st_queue(clk, rst, tag_in, tag_out, wr_en,
                          rd_en, empty, full, tag_counter); //queue data struct determines who is the last processd

endmodule
