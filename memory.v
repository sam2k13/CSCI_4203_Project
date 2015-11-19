module memory(
    input clk,

    //data inputs
    input [63:0] datIn,
    input [63:0] addr,

    //control inputs
    input [1:0] control,
    
    //-- arbiter
    input arbiter,

    output[63:0] wb_data, //It is z in case of store
    
    output mem_ready, 

    output [64*64 -1 : 0 ] tb_mem

); //memory unit ... used by load and store operations


   data_mem data_mem(datIn, addr, clk, control, arbiter,  wb_data, mem_ready,  tb_mem);


endmodule
